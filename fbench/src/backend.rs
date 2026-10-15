//! The per-crate adapter.
//!
//! `faer_fork` (`t4a-faer`) and `faer_upstream` (`faer`) are distinct dependency
//! keys with distinct `Mat`, `Par` and trait types, so the glue that turns a plain
//! `&[T]` and a shape into that crate's calls is written twice. `define_backend!`
//! expands the same body once per crate; the family logic and every correctness
//! check it drives are written once, in the macro body and in `shared`.
//!
//! Each family returns an [`Op`]: `prepare` restores the caller-visible inputs,
//! `run` is the measured call, and `check` is a residual or norm identity computed
//! from that provider's own result against provider-independent reference math.
//! A family that is not implemented returns `Err(note)`; the caller records it as
//! `skipped`, never as a number.

macro_rules! define_backend {
    ($modname:ident, $krate:ident) => {
        pub mod $modname {
            use crate::op::{op_from, Op};
            use crate::shared::*;
            use num_complex::Complex64;
            use std::hint::black_box;

            use $krate::dyn_stack::{MemBuffer, MemStack, StackReq};
            use $krate::linalg::householder;
            use $krate::linalg::qr::no_pivoting::factor as qrf;
            use $krate::linalg::solvers::{DenseSolveCore, Solve};
            use $krate::traits::ComplexField;
            use $krate::{get_global_parallelism, Accum, Conj, MatMut, MatRef, Par, Side};

            /// Set this crate's own global parallelism from the row's budget.
            pub fn set_threads(threads: usize) {
                let par = if threads <= 1 {
                    Par::Seq
                } else {
                    Par::rayon(threads)
                };
                $krate::set_global_parallelism(par);
            }

            fn strides(m: usize, n: usize, order: Order) -> (isize, isize) {
                match order {
                    Order::C => (n as isize, 1),
                    Order::F => (1, m as isize),
                }
            }

            fn mref<'a, T: ComplexField>(d: &'a [T], m: usize, n: usize, order: Order) -> MatRef<'a, T> {
                let (rs, cs) = strides(m, n, order);
                // SAFETY: the caller owns `d` for the view's lifetime and the strides
                // describe exactly that buffer.
                unsafe { MatRef::from_raw_parts(d.as_ptr(), m, n, rs, cs) }
            }

            fn mmut<'a, T: ComplexField>(d: &'a mut [T], m: usize, n: usize, order: Order) -> MatMut<'a, T> {
                let (rs, cs) = strides(m, n, order);
                // SAFETY: as `mref`, with an exclusive borrow of the buffer.
                unsafe { MatMut::from_raw_parts_mut(d.as_mut_ptr(), m, n, rs, cs) }
            }

            /// Copy a matrix into a flat buffer in the requested layout.
            fn to_layout<T: ComplexField>(mat: MatRef<'_, T>, m: usize, n: usize, order: Order) -> Vec<T> {
                let mut out = vec![T::zero_impl(); m * n];
                for j in 0..n {
                    for i in 0..m {
                        out[idx(i, j, m, n, order)] = mat[(i, j)].clone();
                    }
                }
                out
            }

            fn diag_vec<T: ComplexField>(diag: $krate::diag::DiagRef<'_, T>) -> Vec<T> {
                (0..diag.dim()).map(|i| diag[i].clone()).collect()
            }

            /// The case seed, so `verify` and `run` see the same matrices.
            fn seed(m: usize, n: usize, k: usize) -> u64 {
                (m as u64)
                    .wrapping_mul(0x9E37_79B9)
                    .wrapping_add((n as u64).wrapping_mul(0x85EB_CA6B))
                    .wrapping_add((k as u64).wrapping_mul(0xC2B2_AE35))
                    .wrapping_add(0x5EED)
            }

            /// The residual check: `max|residual| <= tol * scale`.
            fn within<T: Scalar>(residual: f64, scale: f64, size: usize, what: &str) -> Result<(), String> {
                let tol = tol_of::<T>(size) * scale.max(1.0);
                if residual.is_finite() && residual <= tol {
                    Ok(())
                } else {
                    Err(format!("{what} residual {residual:e} exceeds {tol:e}"))
                }
            }

            fn square(case: Case, family: &str) -> Result<(), String> {
                if case.m == case.n {
                    Ok(())
                } else {
                    Err(format!(
                        "{family} needs a square matrix; {} is not",
                        case.shape()
                    ))
                }
            }

            /// Build the ops for one case, per dtype.
            pub fn ops(dtype: Dtype, family: &str, case: Case, order: Order) -> Result<Vec<Op>, String> {
                match dtype {
                    Dtype::F64 => ops_typed::<f64>(family, case, order),
                    Dtype::C64 => ops_typed::<Complex64>(family, case, order),
                }
            }

            fn ops_typed<T: Scalar + ComplexField<Real = f64>>(
                family: &str,
                case: Case,
                order: Order,
            ) -> Result<Vec<Op>, String> {
                let m = case.m;
                let n = case.n;
                let batch = case.batch;
                match family {
                    "gemm" => Ok(vec![gemm_op::<T>(m, case.k.unwrap_or(m), n, batch, order)?]),
                    "qr_factor" => Ok(vec![qr_factor_op::<T>(m, n, batch, order)?]),
                    "qr" => Ok(vec![qr_op::<T>(m, n, batch, order)?]),
                    "lu" => {
                        square(case, family)?;
                        Ok(vec![lu_op::<T>(m, batch, order)?])
                    }
                    "full_piv_lu" => {
                        square(case, family)?;
                        Ok(vec![full_piv_lu_op::<T>(m, batch, order)?])
                    }
                    "cholesky" => {
                        square(case, family)?;
                        Ok(vec![cholesky_op::<T>(m, batch, order)?])
                    }
                    "solve" => {
                        square(case, family)?;
                        Ok(vec![solve_op::<T>(m, batch, order)?])
                    }
                    "triangular_solve" => {
                        square(case, family)?;
                        Ok(vec![triangular_solve_op::<T>(m, batch, order)?])
                    }
                    "svd_values" => Ok(vec![svd_values_op::<T>(m, n, batch, order)?]),
                    "svd_thin" => Ok(vec![svd_thin_op::<T>(m, n, batch, order)?]),
                    "eigh" => {
                        square(case, family)?;
                        Ok(vec![eigh_op::<T>(m, batch, order)?])
                    }
                    "householder_apply" => householder_ops::<T>(m, n, batch, order),
                    // Deliberately not written yet. `upgrade_factor` needs a valid
                    // blocked-tau layout built by hand to be measured and checked
                    // honestly, and `eig` is the non-symmetric solver the first
                    // version does not touch. Both are recorded as skipped.
                    other => Err(format!(
                        "{other} is not implemented for the faer arms in this harness"
                    )),
                }
            }

            // ---------------------------------------------------------- gemm

            fn gemm_op<T: Scalar + ComplexField>(
                m: usize,
                k: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a = fill_seeded::<T>(m * k * batch, seed(m, k, n));
                let b = fill_seeded::<T>(k * n * batch, seed(k, n, m));
                let mut c_ref = vec![T::zero(); m * n * batch];
                for bi in 0..batch {
                    mul(
                        m,
                        k,
                        n,
                        order,
                        &a[bi * m * k..(bi + 1) * m * k],
                        &b[bi * k * n..(bi + 1) * k * n],
                        &mut c_ref[bi * m * n..(bi + 1) * m * n],
                    );
                }
                struct S<T> {
                    a: Vec<T>,
                    b: Vec<T>,
                    c: Vec<T>,
                    c_ref: Vec<T>,
                    m: usize,
                    k: usize,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let par = get_global_parallelism();
                let state = S {
                    a,
                    b,
                    c: vec![T::zero(); m * n * batch],
                    c_ref,
                    m,
                    k,
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |s| {
                        s.c.fill(T::zero());
                        Ok(())
                    },
                    move |s| {
                        for bi in 0..s.batch {
                            let dst = mmut(&mut s.c[bi * s.m * s.n..], s.m, s.n, s.order);
                            let lhs = mref(&s.a[bi * s.m * s.k..], s.m, s.k, s.order);
                            let rhs = mref(&s.b[bi * s.k * s.n..], s.k, s.n, s.order);
                            $krate::linalg::matmul::matmul(dst, Accum::Replace, lhs, rhs, T::one(), par);
                        }
                        Ok(())
                    },
                    |s| {
                        let diff = max_diff(&s.c, &s.c_ref);
                        within::<T>(diff, frob(&s.c_ref), s.n.max(s.m), "gemm")
                    },
                ))
            }

            // ------------------------------------------------------- qr_factor

            fn qr_factor_op<T: Scalar + ComplexField>(
                m: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let size = m.min(n);
                let block_size = qrf::recommended_block_size::<T>(m, n);
                let a0 = fill_seeded::<T>(m * n * batch, seed(m, n, size));
                let par = get_global_parallelism();
                let scratch = qrf::qr_in_place_scratch::<T>(m, n, block_size, par, Default::default());
                struct S<T> {
                    a: Vec<T>,
                    a0: Vec<T>,
                    qc: Vec<T>,
                    mem: MemBuffer,
                    m: usize,
                    n: usize,
                    block_size: usize,
                    size: usize,
                    batch: usize,
                    order: Order,
                    par: Par,
                }
                let state = S {
                    a: a0.clone(),
                    a0,
                    qc: vec![T::zero(); block_size * size * batch],
                    mem: MemBuffer::new(scratch),
                    m,
                    n,
                    block_size,
                    size,
                    batch,
                    order,
                    par,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |s| {
                        s.a.copy_from_slice(&s.a0);
                        s.qc.fill(T::zero());
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a = mmut(&mut s.a[bi * s.m * s.n..], s.m, s.n, s.order);
                            let qc = mmut(
                                &mut s.qc[bi * s.block_size * s.size..],
                                s.block_size,
                                s.size,
                                Order::F,
                            );
                            qrf::qr_in_place(
                                a,
                                qc,
                                s.par,
                                MemStack::new(&mut s.mem),
                                Default::default(),
                            );
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let qr = mref(a0, s.m, s.n, s.order).qr();
                            let recon = to_layout(qr.reconstruct().as_ref(), s.m, s.n, s.order);
                            within::<T>(max_diff(a0, &recon), frob(a0), s.n.max(s.m), "qr_factor")?;
                            // Only the first `size` columns of Q enter A = QR; the
                            // remaining columns of the full Q are an arbitrary unitary
                            // completion that the reconstruction above never touches, so
                            // orthonormality of the compact Q is the factorization's own
                            // acceptance criterion. Checking the full Q costs O(m^2 size)
                            // to form and O(m^3) to reduce here, which is what made a
                            // 4096x256 verify run for minutes.
                            let q = to_layout(qr.compute_thin_Q().as_ref(), s.m, s.size, s.order);
                            within::<T>(gram_residual(&q, s.m, s.size, s.order), 1.0, s.m, "qr Q")?;
                        }
                        Ok(())
                    },
                ))
            }

            // -------------------------------------------------------- qr (composite)

            fn qr_op<T: Scalar + ComplexField>(
                m: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a0 = fill_seeded::<T>(m * n * batch, seed(m, n, 3));
                struct S<T> {
                    a0: Vec<T>,
                    sink: T,
                    m: usize,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: T::zero(),
                    m,
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let qr = mref(a0, s.m, s.n, s.order).qr();
                            // The composite returns explicit Q and R, and the Q it
                            // returns is the one the check below consumes and the one
                            // the vendor route builds: `m x min(m, n)`. Asking for the
                            // full `m x m` completion instead made this row 8x the
                            // vendor's work on a tall shape while the check, and the
                            // vendor's `orgqr(m, min(m, n))`, both stopped at the
                            // compact factor. A black box keeps the work from being
                            // optimised away.
                            let q = qr.compute_thin_Q();
                            let r = qr.R();
                            black_box((q.as_ref()[(0, 0)].clone(), r[(0, 0)].clone()));
                            acc(&mut s.sink, q.as_ref()[(0, 0)].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let qr = mref(a0, s.m, s.n, s.order).qr();
                            let recon = to_layout(qr.reconstruct().as_ref(), s.m, s.n, s.order);
                            within::<T>(max_diff(a0, &recon), frob(a0), s.n.max(s.m), "qr")?;
                            // Same acceptance criterion as `qr_factor`: the compact Q is
                            // the factor that multiplies R, and the full Q's remaining
                            // columns are an arbitrary completion.
                            let size = s.m.min(s.n);
                            let q = to_layout(qr.compute_thin_Q().as_ref(), s.m, size, s.order);
                            within::<T>(gram_residual(&q, s.m, size, s.order), 1.0, s.m, "qr Q")?;
                        }
                        Ok(())
                    },
                ))
            }

            // ------------------------------------------------------------ lu

            fn lu_op<T: Scalar + ComplexField>(n: usize, batch: usize, order: Order) -> Result<Op, String> {
                let a0 = fill_seeded::<T>(n * n * batch, seed(n, n, 5));
                struct S<T> {
                    a0: Vec<T>,
                    sink: T,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: T::zero(),
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let lu = mref(a0, s.n, s.n, s.order).partial_piv_lu();
                            black_box(lu.L()[(0, 0)].clone());
                            acc(&mut s.sink, lu.U()[(0, 0)].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let lu = mref(a0, s.n, s.n, s.order).partial_piv_lu();
                            let recon = to_layout(lu.reconstruct().as_ref(), s.n, s.n, s.order);
                            within::<T>(max_diff(a0, &recon), frob(a0), s.n, "lu")?;
                        }
                        Ok(())
                    },
                ))
            }

            fn full_piv_lu_op<T: Scalar + ComplexField>(
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a0 = fill_seeded::<T>(n * n * batch, seed(n, n, 7));
                struct S<T> {
                    a0: Vec<T>,
                    sink: T,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: T::zero(),
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let lu = mref(a0, s.n, s.n, s.order).full_piv_lu();
                            black_box(lu.L()[(0, 0)].clone());
                            acc(&mut s.sink, lu.U()[(0, 0)].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let lu = mref(a0, s.n, s.n, s.order).full_piv_lu();
                            let recon = to_layout(lu.reconstruct().as_ref(), s.n, s.n, s.order);
                            within::<T>(max_diff(a0, &recon), frob(a0), s.n, "full_piv_lu")?;
                        }
                        Ok(())
                    },
                ))
            }

            // ------------------------------------------------------ cholesky

            fn cholesky_op<T: Scalar + ComplexField>(
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a0 = spd::<T>(n, batch, order, seed(n, n, 11));
                struct S<T> {
                    a0: Vec<T>,
                    sink: T,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: T::zero(),
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let llt = mref(a0, s.n, s.n, s.order)
                                .llt(Side::Lower)
                                .map_err(|e| format!("llt failed: {e:?}"))?;
                            black_box(llt.L()[(0, 0)].clone());
                            acc(&mut s.sink, llt.L()[(s.n - 1, s.n - 1)].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let llt = mref(a0, s.n, s.n, s.order)
                                .llt(Side::Lower)
                                .map_err(|e| format!("llt failed: {e:?}"))?;
                            let recon = to_layout(llt.reconstruct().as_ref(), s.n, s.n, s.order);
                            within::<T>(max_diff(a0, &recon), frob(a0), s.n, "cholesky")?;
                        }
                        Ok(())
                    },
                ))
            }

            // ----------------------------------------------------------- solve

            fn solve_op<T: Scalar + ComplexField>(n: usize, batch: usize, order: Order) -> Result<Op, String> {
                let a0 = diag_dominant::<T>(n, batch, order, seed(n, n, 13));
                let b0 = fill_seeded::<T>(n * batch, seed(n, 1, 17));
                struct S<T> {
                    a0: Vec<T>,
                    b0: Vec<T>,
                    b: Vec<T>,
                    sink: T,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    b0: b0.clone(),
                    b: b0.clone(),
                    sink: T::zero(),
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |s| {
                        s.b.copy_from_slice(&s.b0);
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a = mref(&s.a0[bi * s.n * s.n..], s.n, s.n, s.order);
                            let lu = a.partial_piv_lu();
                            let rhs = mmut(&mut s.b[bi * s.n..], s.n, 1, s.order);
                            lu.solve_in_place(rhs);
                            acc(&mut s.sink, s.b[bi * s.n].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let b0 = &s.b0[bi * s.n..(bi + 1) * s.n];
                            let x = &s.b[bi * s.n..(bi + 1) * s.n];
                            let mut ax = vec![T::zero(); s.n];
                            mul(s.n, s.n, 1, s.order, a0, x, &mut ax);
                            within::<T>(max_diff(&ax, b0), frob(b0), s.n, "solve")?;
                        }
                        Ok(())
                    },
                ))
            }

            // -------------------------------------------------- triangular_solve

            fn triangular_solve_op<T: Scalar + ComplexField>(
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let u0 = upper_triangular::<T>(n, batch, order, seed(n, n, 19));
                let b0 = fill_seeded::<T>(n * batch, seed(n, 1, 23));
                struct S<T> {
                    u0: Vec<T>,
                    b0: Vec<T>,
                    b: Vec<T>,
                    sink: T,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    u0,
                    b0: b0.clone(),
                    b: b0.clone(),
                    sink: T::zero(),
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |s| {
                        s.b.copy_from_slice(&s.b0);
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let u = mref(&s.u0[bi * s.n * s.n..], s.n, s.n, s.order);
                            let rhs = mmut(&mut s.b[bi * s.n..], s.n, 1, s.order);
                            u.solve_upper_triangular_in_place(rhs);
                            acc(&mut s.sink, s.b[bi * s.n].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let u0 = &s.u0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let b0 = &s.b0[bi * s.n..(bi + 1) * s.n];
                            let x = &s.b[bi * s.n..(bi + 1) * s.n];
                            let mut ux = vec![T::zero(); s.n];
                            mul(s.n, s.n, 1, s.order, u0, x, &mut ux);
                            within::<T>(max_diff(&ux, b0), frob(b0), s.n, "triangular_solve")?;
                        }
                        Ok(())
                    },
                ))
            }

            // ----------------------------------------------------- svd_values

            fn svd_values_op<T: Scalar + ComplexField<Real = f64>>(
                m: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a0 = fill_seeded::<T>(m * n * batch, seed(m, n, 29));
                struct S<T> {
                    a0: Vec<T>,
                    sink: f64,
                    m: usize,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: 0.0,
                    m,
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let sv = mref(a0, s.m, s.n, s.order)
                                .singular_values()
                                .map_err(|e| format!("singular_values failed: {e:?}"))?;
                            s.sink += sv.first().copied().unwrap_or(0.0);
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let sv = mref(a0, s.m, s.n, s.order)
                                .singular_values()
                                .map_err(|e| format!("singular_values failed: {e:?}"))?;
                            let r = sv.len();
                            let eps = tol_of::<T>(s.n.max(s.m));
                            for i in 0..r {
                                if !sv[i].is_finite() || sv[i] < -eps {
                                    return Err(format!("singular value {i} is negative: {}", sv[i]));
                                }
                                if i + 1 < r && sv[i] < sv[i + 1] - eps {
                                    return Err("singular values are not sorted".to_owned());
                                }
                            }
                            let sum: f64 = sv.iter().map(|x| x * x).sum();
                            let scale = frob(a0);
                            within::<T>(
                                (sum.sqrt() - scale).abs(),
                                scale,
                                s.n.max(s.m),
                                "svd_values norm identity",
                            )?;
                        }
                        Ok(())
                    },
                ))
            }

            // ------------------------------------------------------- svd_thin

            fn svd_thin_op<T: Scalar + ComplexField>(
                m: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Op, String> {
                let a0 = fill_seeded::<T>(m * n * batch, seed(m, n, 31));
                struct S<T> {
                    a0: Vec<T>,
                    sink: T,
                    m: usize,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    sink: T::zero(),
                    m,
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let svd = mref(a0, s.m, s.n, s.order)
                                .thin_svd()
                                .map_err(|e| format!("thin_svd failed: {e:?}"))?;
                            black_box(svd.U()[(0, 0)].clone());
                            acc(&mut s.sink, svd.S()[0].clone());
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n];
                            let svd = mref(a0, s.m, s.n, s.order)
                                .thin_svd()
                                .map_err(|e| format!("thin_svd failed: {e:?}"))?;
                            let r = svd.S().dim();
                            let u = to_layout(svd.U(), s.m, r, s.order);
                            let v = to_layout(svd.V(), s.n, r, s.order);
                            let scale = frob(a0);
                            within::<T>(gram_residual(&u, s.m, r, s.order), 1.0, s.m, "svd_thin U")?;
                            within::<T>(gram_residual(&v, s.n, r, s.order), 1.0, s.n, "svd_thin V")?;
                            let s_diag = diag_vec(svd.S());
                            let scaled_v = scale_cols(&v, s.n, r, &s_diag, s.order);
                            let mut recon = vec![T::zero(); s.m * s.n];
                            mul_adj_b(s.m, r, s.n, s.order, &u, &scaled_v, &mut recon);
                            within::<T>(max_diff(a0, &recon), scale, s.n.max(s.m), "svd_thin")?;
                        }
                        Ok(())
                    },
                ))
            }

            // ---------------------------------------------------------- eigh

            fn eigh_op<T: Scalar + ComplexField>(n: usize, batch: usize, order: Order) -> Result<Op, String> {
                let a0 = hermitian::<T>(n, order, seed(n, n, 37));
                let a0 = replicate(&a0, batch);
                struct S<T> {
                    a0: Vec<T>,
                    n: usize,
                    batch: usize,
                    order: Order,
                }
                let state = S {
                    a0,
                    n,
                    batch,
                    order,
                };
                Ok(op_from(
                    state,
                    String::new(),
                    |_s| Ok(()),
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let evd = mref(a0, s.n, s.n, s.order)
                                .self_adjoint_eigen(Side::Lower)
                                .map_err(|e| format!("self_adjoint_eigen failed: {e:?}"))?;
                            black_box(&evd);
                        }
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a0 = &s.a0[bi * s.n * s.n..(bi + 1) * s.n * s.n];
                            let evd = mref(a0, s.n, s.n, s.order)
                                .self_adjoint_eigen(Side::Lower)
                                .map_err(|e| format!("self_adjoint_eigen failed: {e:?}"))?;
                            let u = to_layout(evd.U(), s.n, s.n, s.order);
                            let scale = frob(a0);
                            within::<T>(gram_residual(&u, s.n, s.n, s.order), 1.0, s.n, "eigh U")?;
                            let s_diag = diag_vec(evd.S());
                            let mut au = vec![T::zero(); s.n * s.n];
                            mul(s.n, s.n, s.n, s.order, a0, &u, &mut au);
                            let us = scale_cols(&u, s.n, s.n, &s_diag, s.order);
                            within::<T>(max_diff(&au, &us), scale, s.n, "eigh")?;
                        }
                        Ok(())
                    },
                ))
            }

            // -------------------------------------------------- householder_apply

            fn householder_ops<T: Scalar + ComplexField>(
                m: usize,
                n: usize,
                batch: usize,
                order: Order,
            ) -> Result<Vec<Op>, String> {
                let size = m.min(n);
                let target = n;
                let a0 = fill_seeded::<T>(m * n * batch, seed(m, n, 41));
                let c0 = fill_seeded::<T>(m * target * batch, seed(m, target, 43));
                let par = get_global_parallelism();
                let block_scratch = householder::apply_block_householder_on_the_left_in_place_scratch::<T>(
                    m, size, target,
                );
                let seq_scratch =
                    householder::apply_block_householder_sequence_on_the_left_in_place_scratch::<T>(
                        m, size, target,
                    );
                let scratch = StackReq::any_of(&[
                    block_scratch,
                    seq_scratch,
                    qrf::qr_in_place_scratch::<T>(m, n, size, par, Default::default()),
                ]);
                struct S<T> {
                    a: Vec<T>,
                    a0: Vec<T>,
                    qc: Vec<T>,
                    c0: Vec<T>,
                    c: Vec<T>,
                    mem: MemBuffer,
                    m: usize,
                    n: usize,
                    size: usize,
                    target: usize,
                    batch: usize,
                    order: Order,
                    par: Par,
                }
                let state = S {
                    a: a0.clone(),
                    a0,
                    qc: vec![T::zero(); size * size * batch],
                    c0: c0.clone(),
                    c: c0,
                    mem: MemBuffer::new(scratch),
                    m,
                    n,
                    size,
                    target,
                    batch,
                    order,
                    par,
                };
                let block = op_from(
                    state,
                    "block".to_owned(),
                    |s| {
                        s.a.copy_from_slice(&s.a0);
                        s.qc.fill(T::zero());
                        s.c.copy_from_slice(&s.c0);
                        Ok(())
                    },
                    |s| {
                        for bi in 0..s.batch {
                            let a = mmut(&mut s.a[bi * s.m * s.n..], s.m, s.n, s.order);
                            let qc = mmut(&mut s.qc[bi * s.size * s.size..], s.size, s.size, Order::F);
                            qrf::qr_in_place(a, qc, s.par, MemStack::new(&mut s.mem), Default::default());
                            let basis = mref(&s.a[bi * s.m * s.n..], s.m, s.n, s.order).get(.., ..s.size);
                            let factor = mref(&s.qc[bi * s.size * s.size..], s.size, s.size, Order::F);
                            let dst = mmut(&mut s.c[bi * s.m * s.target..], s.m, s.target, s.order);
                            householder::apply_block_householder_on_the_left_in_place_with_conj(
                                basis,
                                factor,
                                Conj::No,
                                dst,
                                s.par,
                                MemStack::new(&mut s.mem),
                            );
                        }
                        Ok(())
                    },
                    |s| {
                        // The same transform, applied by the sequence form, must agree.
                        for bi in 0..s.batch {
                            let mut a = s.a0[bi * s.m * s.n..(bi + 1) * s.m * s.n].to_vec();
                            let mut qc = vec![T::zero(); s.size * s.size];
                            qrf::qr_in_place(
                                mmut(&mut a, s.m, s.n, s.order),
                                mmut(&mut qc, s.size, s.size, Order::F),
                                s.par,
                                MemStack::new(&mut s.mem),
                                Default::default(),
                            );
                            let mut reference = s.c0[bi * s.m * s.target..(bi + 1) * s.m * s.target].to_vec();
                            householder::apply_block_householder_sequence_on_the_left_in_place_with_conj(
                                mref(&a, s.m, s.n, s.order).get(.., ..s.size),
                                mref(&qc, s.size, s.size, Order::F),
                                Conj::No,
                                mmut(&mut reference, s.m, s.target, s.order),
                                s.par,
                                MemStack::new(&mut s.mem),
                            );
                            let got = &s.c[bi * s.m * s.target..(bi + 1) * s.m * s.target];
                            within::<T>(
                                max_diff(got, &reference),
                                frob(&reference),
                                s.target.max(s.m),
                                "householder_apply",
                            )?;
                        }
                        Ok(())
                    },
                );
                Ok(vec![block])
            }

            fn replicate<T: Copy>(values: &[T], batch: usize) -> Vec<T> {
                let mut out = Vec::with_capacity(values.len() * batch);
                for _ in 0..batch {
                    out.extend_from_slice(values);
                }
                out
            }

            /// `M + n I`: general, well conditioned.
            fn diag_dominant<T: Scalar>(n: usize, batch: usize, order: Order, seed: u64) -> Vec<T> {
                let mut out = fill_seeded::<T>(n * n, seed);
                for i in 0..n {
                    out[idx(i, i, n, n, order)].add_assign(T::from_f64(n as f64));
                }
                replicate(&out, batch)
            }

            /// A diagonally dominant upper triangular matrix.
            fn upper_triangular<T: Scalar>(n: usize, batch: usize, order: Order, seed: u64) -> Vec<T> {
                let raw = fill_seeded::<T>(n * n, seed);
                let mut out = vec![T::zero(); n * n];
                for j in 0..n {
                    for i in 0..n {
                        if i <= j {
                            out[idx(i, j, n, n, order)] = raw[idx(i, j, n, n, order)];
                        }
                    }
                    out[idx(j, j, n, n, order)].add_assign(T::from_f64(n as f64 + 1.0));
                }
                replicate(&out, batch)
            }

            /// `M M^H + n I`: a Hermitian positive-definite matrix of shape `n x n`,
            /// replicated `batch` times.
            fn spd<T: Scalar>(n: usize, batch: usize, order: Order, seed: u64) -> Vec<T> {
                let m = fill_seeded::<T>(n * n, seed);
                let mut mm = vec![T::zero(); n * n];
                mul_adj_b(n, n, n, order, &m, &m, &mut mm);
                for i in 0..n {
                    mm[idx(i, i, n, n, order)].add_assign(T::from_f64(n as f64 + 1.0));
                }
                replicate(&mm, batch)
            }
        }
    };
}

define_backend!(fork, faer_fork);
define_backend!(upstream, faer_upstream);
