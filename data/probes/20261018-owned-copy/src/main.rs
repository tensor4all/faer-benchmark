use std::{hint::black_box, time::{Duration, Instant}};

fn measure<R>(mut f: impl FnMut() -> R) -> (f64, Vec<f64>) {
    let warm = Instant::now();
    while warm.elapsed() < Duration::from_millis(250) {
        drop(black_box(f()));
    }
    let mut samples = Vec::with_capacity(5);
    for _ in 0..5 {
        let start = Instant::now();
        drop(black_box(f()));
        samples.push(start.elapsed().as_secs_f64() * 1000.0);
    }
    let mut sorted = samples.clone();
    sorted.sort_by(f64::total_cmp);
    (sorted[2], samples)
}

macro_rules! cases {
    ($dtype:literal, $ty:ty, $value:expr, $reverse:expr) => {
        for (m,n) in [(32,32),(64,64),(96,96),(128,128),(256,256),(512,512),(1024,64),(64,1024)] {
            let value = $value;
            for order in ["c","f"] {
                let storage = if order == "c" {
                    faer::Mat::<$ty>::from_fn(n,m,|j,i| value(i,j))
                } else {
                    faer::Mat::<$ty>::from_fn(m,n,value)
                };
                let src = if order == "c" { storage.as_ref().transpose() } else { storage.as_ref() };
                assert_eq!(src.to_owned(), src.cloned());
                for method in if $reverse { ["cloned","to_owned"] } else { ["to_owned","cloned"] } {
                    let (median,samples) = if method == "to_owned" {
                        measure(|| black_box(src).to_owned())
                    } else {
                        measure(|| black_box(src).cloned())
                    };
                    println!("{},,{},{},{},{},1,{:.9},\"{:?}\"", $dtype, order, m,n,method,median,samples);
                }
            }
        }
    }
}

fn main() {
    let index: usize = std::env::args().nth(1).expect("process index0..3").parse().unwrap();
    assert!(index < 4);
    faer::set_global_parallelism(faer::Par::Seq);
    let pool = rayon::ThreadPoolBuilder::new().num_threads(1).build().unwrap();
    pool.install(|| {
        assert_eq!(rayon::current_num_threads(),1);
        eprintln!("configured_threads=1 observed_rayon_threads={} faer=Seq",rayon::current_num_threads());
        println!("dtype,note,order,m,n,method,threads,total_ms,samples_ms");
        let reverse = index == 1 || index == 2;
        cases!("f64",f64,|i,j| ((i*17+j*13+1) % 101) as f64 / 13.0,reverse);
        cases!("c64",faer::c64,|i,j| faer::c64::new(((i*17+j*13+1) % 101) as f64 / 13.0,
                                               ((i*7+j*23+3) % 97) as f64 / 11.0),reverse);
    });
}
