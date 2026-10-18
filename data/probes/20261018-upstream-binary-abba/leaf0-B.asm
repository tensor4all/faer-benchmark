
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/a53774682edd-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002088f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench>:
  2088f0:	push   rbp
  2088f1:	push   r15
  2088f3:	push   r14
  2088f5:	push   r13
  2088f7:	push   r12
  2088f9:	push   rbx
  2088fa:	sub    rsp,0x148
  208901:	mov    rax,QWORD PTR [rdi+0x8]
  208905:	test   rax,rax
  208908:	je     2089f2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  20890e:	mov    rcx,QWORD PTR [rdi+0x10]
  208912:	cmp    rax,rcx
  208915:	mov    rdx,rcx
  208918:	cmovb  rdx,rax
  20891c:	mov    QWORD PTR [rsp+0xd0],rdx
  208924:	test   rcx,rcx
  208927:	je     2089f2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  20892d:	mov    QWORD PTR [rsp+0xb0],rax
  208935:	mov    rax,QWORD PTR [rdi+0x40]
  208939:	mov    QWORD PTR [rsp+0x30],rax
  20893e:	mov    rax,QWORD PTR [rdi+0x48]
  208942:	mov    QWORD PTR [rsp+0x70],rax
  208947:	mov    r8,QWORD PTR [rdi+0x50]
  20894b:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  208950:	vmovsd xmm0,QWORD PTR [rdi+0x38]
  208955:	mov    rdx,QWORD PTR [rdi+0x20]
  208959:	mov    rax,QWORD PTR [rdi+0x28]
  20895d:	mov    QWORD PTR [rsp+0x78],rax
  208962:	movzx  eax,BYTE PTR [rdi+0x59]
  208966:	mov    BYTE PTR [rsp+0xf],al
  20896a:	movzx  ebp,BYTE PTR [rdi+0x58]
  20896e:	mov    r9,QWORD PTR [rdi]
  208971:	mov    r10,QWORD PTR [rdi+0x18]
  208975:	vmovddup xmm5,QWORD PTR [rip+0xffffffffffe371a3]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20897d:	vxorpd xmm6,xmm3,xmm5
  208981:	vmovapd XMMWORD PTR [rsp+0x120],xmm0
  20898a:	vxorpd xmm0,xmm0,xmm5
  20898e:	vmovapd XMMWORD PTR [rsp+0x130],xmm0
  208997:	mov    QWORD PTR [rsp+0xf8],r8
  20899f:	shl    r8,0x4
  2089a3:	mov    QWORD PTR [rsp+0x100],r10
  2089ab:	shl    r10,0x4
  2089af:	lea    rax,[r9+0x8]
  2089b3:	mov    QWORD PTR [rsp+0xc0],rax
  2089bb:	lea    rax,[r9+0x60]
  2089bf:	mov    QWORD PTR [rsp+0xb8],rax
  2089c7:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe37091]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  2089cf:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe370f1]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  2089d7:	xor    esi,esi
  2089d9:	xor    edi,edi
  2089db:	mov    QWORD PTR [rsp+0x50],r9
  2089e0:	mov    QWORD PTR [rsp+0xc8],rcx
  2089e8:	mov    QWORD PTR [rsp+0x80],rdx
  2089f0:	jmp    208a32 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x142>
  2089f2:	xor    edx,edx
  2089f4:	xor    eax,eax
  2089f6:	jmp    2092d2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  2089fb:	nop    DWORD PTR [rax+rax*1+0x0]
  208a00:	mov    QWORD PTR [rsp+0x60],0x0
  208a09:	mov    rsi,QWORD PTR [rsp+0xd8]
  208a11:	add    rsi,QWORD PTR [rsp+0x60]
  208a16:	mov    rdi,r15
  208a19:	mov    rcx,QWORD PTR [rsp+0xc8]
  208a21:	cmp    r15,rcx
  208a24:	mov    rdx,QWORD PTR [rsp+0x80]
  208a2c:	jae    2092e7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9f7>
  208a32:	mov    r9,rcx
  208a35:	sub    r9,rdi
  208a38:	cmp    r9,0x8
  208a3c:	mov    eax,0x8
  208a41:	cmovae r9,rax
  208a45:	mov    QWORD PTR [rsp+0x18],r9
  208a4a:	lea    r15,[r9+rdi*1]
  208a4e:	cmp    r15,QWORD PTR [rsp+0xd0]
  208a56:	ja     209370 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa80>
  208a5c:	cmp    r15,QWORD PTR [rsp+0x70]
  208a61:	ja     2093a8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xab8>
  208a67:	cmp    r15,QWORD PTR [rsp+0x78]
  208a6c:	seta   al
  208a6f:	test   rdx,rdx
  208a72:	jne    208a76 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x186>
  208a74:	xor    eax,eax
  208a76:	test   al,al
  208a78:	jne    20930a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa1a>
  208a7e:	test   rdi,rdi
  208a81:	js     2093de <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  208a87:	cmp    rdi,r15
  208a8a:	ja     2093de <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  208a90:	mov    QWORD PTR [rsp+0xd8],rsi
  208a98:	test   r15,r15
  208a9b:	je     208a00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x110>
  208aa1:	mov    rax,QWORD PTR [rsp+0x18]
  208aa6:	lea    rdx,[rax-0x1]
  208aaa:	mov    r9,rdx
  208aad:	shr    r9,1
  208ab0:	mov    eax,edx
  208ab2:	and    eax,0x1
  208ab5:	shl    eax,0xa
  208ab8:	mov    rcx,QWORD PTR [rip+0x341701]        # 54a1c0 <_DYNAMIC+0x3e8>
  208abf:	mov    rsi,QWORD PTR [rcx+rax*1+0x400]
  208ac7:	mov    r13,QWORD PTR [rcx+rax*1+0x408]
  208acf:	mov    QWORD PTR [rsp+0xf0],rdx
  208ad7:	and    rdx,0xfffffffffffffffe
  208adb:	mov    QWORD PTR [rsp+0x38],rdx
  208ae0:	xor    eax,eax
  208ae2:	test   r9,r9
  208ae5:	setne  al
  208ae8:	lea    rdx,[rax+0x1]
  208aec:	cmp    r9,rax
  208aef:	mov    QWORD PTR [rsp+0x88],rax
  208af7:	cmovbe rdx,rax
  208afb:	lea    ebx,[rdx+rdx*1]
  208afe:	mov    r11d,r9d
  208b01:	and    r11d,0x3
  208b05:	movabs rax,0x7fffffffffffffff
  208b0f:	lea    r14,[rax-0x3]
  208b13:	and    r14,r9
  208b16:	mov    rax,r9
  208b19:	shl    rax,0x5
  208b1d:	mov    QWORD PTR [rsp+0x40],rax
  208b22:	mov    QWORD PTR [rsp+0x110],rdx
  208b2a:	shl    edx,0x5
  208b2d:	mov    QWORD PTR [rsp+0x118],rdx
  208b35:	mov    rdx,rdi
  208b38:	shl    rdx,0x4
  208b3c:	mov    rax,QWORD PTR [rsp+0xb8]
  208b44:	add    rax,rdx
  208b47:	mov    QWORD PTR [rsp+0x98],rax
  208b4f:	mov    QWORD PTR [rsp+0xe8],r11
  208b57:	shl    r11d,0x5
  208b5b:	shl    ebx,0x4
  208b5e:	mov    QWORD PTR [rsp+0x90],rbx
  208b66:	mov    QWORD PTR [rsp+0x108],rdx
  208b6e:	mov    rax,QWORD PTR [rsp+0x50]
  208b73:	add    rax,rdx
  208b76:	mov    QWORD PTR [rsp+0xa0],rax
  208b7e:	mov    ebx,0x8
  208b83:	mov    rax,QWORD PTR [rsp+0xc0]
  208b8b:	mov    QWORD PTR [rsp+0x68],rax
  208b90:	mov    QWORD PTR [rsp+0x60],0x0
  208b99:	xor    edx,edx
  208b9b:	mov    QWORD PTR [rsp+0x28],rdi
  208ba0:	mov    QWORD PTR [rsp+0xa8],r9
  208ba8:	mov    QWORD PTR [rsp+0x48],r13
  208bad:	mov    QWORD PTR [rsp+0x20],r14
  208bb2:	jmp    208c1c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x32c>
  208bb4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  208bc0:	inc    rdx
  208bc3:	mov    rax,QWORD PTR [rsp+0x38]
  208bc8:	shl    rax,0x4
  208bcc:	mov    r15,QWORD PTR [rsp+0x58]
  208bd1:	add    r15,rax
  208bd4:	mov    rax,r15
  208bd7:	lea    rcx,[rip+0x2]        # 208be0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2f0>
  208bde:	jmp    rsi
  208be0:	vmulpd ymm0,ymm2,ymm0
  208be4:	lea    rcx,[rip+0x3]        # 208bee <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2fe>
  208beb:	jmp    r13
  208bee:	add    rbx,0x10
  208bf2:	add    QWORD PTR [rsp+0x68],0x10
  208bf8:	add    QWORD PTR [rsp+0x98],r10
  208c00:	add    QWORD PTR [rsp+0xa0],r10
  208c08:	mov    r15,r12
  208c0b:	cmp    rdx,r12
  208c0e:	mov    r9,QWORD PTR [rsp+0xa8]
  208c16:	je     208a09 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x119>
  208c1c:	test   rdx,rdx
  208c1f:	mov    r13,rdi
  208c22:	cmove  r13,rdx
  208c26:	shl    r13,0x4
  208c2a:	mov    rax,QWORD PTR [rsp+0x50]
  208c2f:	lea    r14,[rax+r13*1]
  208c33:	mov    r12,rdx
  208c36:	imul   r12,QWORD PTR [rsp+0x100]
  208c3f:	shl    r12,0x4
  208c43:	add    r12,rax
  208c46:	mov    rax,QWORD PTR [rsp+0x108]
  208c4e:	lea    rcx,[r12+rax*1]
  208c52:	cmp    QWORD PTR [rsp+0x110],r9
  208c5a:	mov    QWORD PTR [rsp+0x58],rcx
  208c5f:	jae    208d80 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x490>
  208c65:	cmp    r9,QWORD PTR [rsp+0x88]
  208c6d:	jbe    2092ee <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9fe>
  208c73:	vmovupd ymm11,YMMWORD PTR [rcx]
  208c77:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  208c7c:	mov    rax,QWORD PTR [rsp+0x90]
  208c84:	vmovupd ymm13,YMMWORD PTR [rcx+rax*1]
  208c89:	mov    r13,QWORD PTR [rsp+0x38]
  208c8e:	shl    r13,0x4
  208c92:	add    r13,rcx
  208c95:	mov    rax,r13
  208c98:	lea    rcx,[rip+0x2]        # 208ca1 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3b1>
  208c9f:	jmp    rsi
  208ca1:	vmovapd ymm2,ymm0
  208ca5:	test   rdx,rdx
  208ca8:	je     208e93 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5a3>
  208cae:	mov    QWORD PTR [rsp+0x10],r12
  208cb3:	mov    r15,rdx
  208cb6:	mov    r12,QWORD PTR [rsp+0x68]
  208cbb:	mov    rdi,QWORD PTR [rsp+0x30]
  208cc0:	mov    r9,QWORD PTR [rsp+0x40]
  208cc5:	jmp    208d65 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x475>
  208cca:	nop    WORD PTR [rax+rax*1+0x0]
  208cd0:	vmovsd xmm1,QWORD PTR [r12]
  208cd6:	vxorpd xmm1,xmm1,xmm5
  208cda:	vmulsd xmm7,xmm0,QWORD PTR [r12-0x8]
  208ce1:	vmulsd xmm14,xmm0,xmm1
  208ce5:	vmovupd ymm15,YMMWORD PTR [r14]
  208cea:	vmovupd ymm4,YMMWORD PTR [r14+0x20]
  208cf0:	mov    rax,QWORD PTR [rsp+0x118]
  208cf8:	vmovupd ymm10,YMMWORD PTR [r14+rax*1]
  208cfe:	lea    rax,[r14+r9*1]
  208d02:	lea    rcx,[rip+0x2]        # 208d0b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x41b>
  208d09:	jmp    rsi
  208d0b:	vshufpd ymm1,ymm15,ymm15,0x5
  208d11:	vbroadcastsd ymm7,xmm7
  208d16:	vbroadcastsd ymm14,xmm14
  208d1b:	vfmaddsub231pd ymm11,ymm14,ymm1
  208d20:	vfmaddsub231pd ymm11,ymm7,ymm15
  208d25:	vshufpd ymm1,ymm4,ymm4,0x5
  208d2a:	vfmaddsub231pd ymm12,ymm14,ymm1
  208d2f:	vfmaddsub231pd ymm12,ymm7,ymm4
  208d34:	vshufpd ymm1,ymm10,ymm10,0x5
  208d3a:	vfmaddsub231pd ymm13,ymm14,ymm1
  208d3f:	vfmaddsub231pd ymm13,ymm7,ymm10
  208d44:	vshufpd ymm1,ymm0,ymm0,0x5
  208d49:	vfmaddsub231pd ymm2,ymm14,ymm1
  208d4e:	vfmaddsub231pd ymm2,ymm7,ymm0
  208d53:	add    rdi,r8
  208d56:	add    r12,r10
  208d59:	add    r14,r10
  208d5c:	dec    r15
  208d5f:	je     208e80 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x590>
  208d65:	vmovapd xmm0,xmm8
  208d69:	test   bpl,bpl
  208d6c:	jne    208cd0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  208d72:	vmovsd xmm0,QWORD PTR [rdi]
  208d76:	vxorpd xmm0,xmm0,xmm5
  208d7a:	jmp    208cd0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  208d7f:	nop
  208d80:	test   r9,r9
  208d83:	je     208ecb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5db>
  208d89:	vmovupd ymm11,YMMWORD PTR [rcx]
  208d8d:	cmp    r9,QWORD PTR [rsp+0x88]
  208d95:	jbe    208f6f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x67f>
  208d9b:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  208da0:	mov    rax,QWORD PTR [rsp+0x38]
  208da5:	shl    rax,0x4
  208da9:	add    rax,rcx
  208dac:	lea    rcx,[rip+0x2]        # 208db5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x4c5>
  208db3:	jmp    rsi
  208db5:	vmovapd ymm2,ymm0
  208db9:	test   rdx,rdx
  208dbc:	mov    rcx,QWORD PTR [rsp+0x40]
  208dc1:	je     209067 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x777>
  208dc7:	mov    QWORD PTR [rsp+0xe0],rax
  208dcf:	mov    QWORD PTR [rsp+0x10],r12
  208dd4:	lea    rdi,[rcx+r13*1]
  208dd8:	mov    r15,rdx
  208ddb:	mov    r12,QWORD PTR [rsp+0x50]
  208de0:	mov    r14,QWORD PTR [rsp+0x30]
  208de5:	jmp    208e66 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x576>
  208de7:	nop    WORD PTR [rax+rax*1+0x0]
  208df0:	vmovsd xmm1,QWORD PTR [r12+rbx*1]
  208df6:	vxorpd xmm1,xmm1,xmm5
  208dfa:	vmulsd xmm13,xmm0,QWORD PTR [r12+rbx*1-0x8]
  208e01:	vmulsd xmm14,xmm0,xmm1
  208e05:	vmovupd ymm15,YMMWORD PTR [r12+r13*1]
  208e0b:	vmovupd ymm7,YMMWORD PTR [r12+r13*1+0x20]
  208e12:	lea    rax,[r12+rdi*1]
  208e16:	lea    rcx,[rip+0x2]        # 208e1f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x52f>
  208e1d:	jmp    rsi
  208e1f:	vshufpd ymm1,ymm15,ymm15,0x5
  208e25:	vbroadcastsd ymm13,xmm13
  208e2a:	vbroadcastsd ymm14,xmm14
  208e2f:	vfmaddsub231pd ymm11,ymm14,ymm1
  208e34:	vfmaddsub231pd ymm11,ymm13,ymm15
  208e39:	vshufpd ymm1,ymm7,ymm7,0x5
  208e3e:	vfmaddsub231pd ymm12,ymm14,ymm1
  208e43:	vfmaddsub231pd ymm12,ymm13,ymm7
  208e48:	vshufpd ymm1,ymm0,ymm0,0x5
  208e4d:	vfmaddsub231pd ymm2,ymm14,ymm1
  208e52:	vfmaddsub231pd ymm2,ymm13,ymm0
  208e57:	add    r14,r8
  208e5a:	add    r12,r10
  208e5d:	dec    r15
  208e60:	je     20904c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75c>
  208e66:	vmovapd xmm0,xmm8
  208e6a:	test   bpl,bpl
  208e6d:	jne    208df0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  208e6f:	vmovsd xmm0,QWORD PTR [r14]
  208e74:	vxorpd xmm0,xmm0,xmm5
  208e78:	jmp    208df0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  208e7d:	nop    DWORD PTR [rax]
  208e80:	mov    rdi,QWORD PTR [rsp+0x28]
  208e85:	mov    rax,QWORD PTR [rsp+0x18]
  208e8a:	lea    r15,[rax+rdi*1]
  208e8e:	mov    r12,QWORD PTR [rsp+0x10]
  208e93:	mov    rax,QWORD PTR [rsp+0x90]
  208e9b:	mov    rcx,QWORD PTR [rsp+0x58]
  208ea0:	add    rax,rcx
  208ea3:	vmovupd YMMWORD PTR [rcx],ymm11
  208ea7:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  208eac:	vmovupd YMMWORD PTR [rax],ymm13
  208eb0:	mov    rax,r13
  208eb3:	vmovapd ymm0,ymm2
  208eb7:	mov    r13,QWORD PTR [rsp+0x48]
  208ebc:	lea    rcx,[rip+0x3]        # 208ec6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5d6>
  208ec3:	jmp    r13
  208ec6:	jmp    2090c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  208ecb:	mov    r14,QWORD PTR [rsp+0x38]
  208ed0:	shl    r14,0x4
  208ed4:	add    r14,rcx
  208ed7:	mov    rax,r14
  208eda:	lea    rcx,[rip+0x2]        # 208ee3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5f3>
  208ee1:	jmp    rsi
  208ee3:	vmovapd ymm2,ymm0
  208ee7:	test   rdx,rdx
  208eea:	mov    rax,QWORD PTR [rsp+0x40]
  208eef:	je     209034 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x744>
  208ef5:	mov    QWORD PTR [rsp+0x10],r12
  208efa:	add    r13,rax
  208efd:	mov    rdi,rdx
  208f00:	mov    r15,QWORD PTR [rsp+0x50]
  208f05:	mov    r12,QWORD PTR [rsp+0x30]
  208f0a:	jmp    208f5a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x66a>
  208f0c:	nop    DWORD PTR [rax+0x0]
  208f10:	vmovsd xmm1,QWORD PTR [r15+rbx*1]
  208f16:	vxorpd xmm1,xmm1,xmm5
  208f1a:	vmulsd xmm11,xmm0,QWORD PTR [r15+rbx*1-0x8]
  208f21:	vmulsd xmm12,xmm0,xmm1
  208f25:	lea    rax,[r15+r13*1]
  208f29:	lea    rcx,[rip+0x2]        # 208f32 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x642>
  208f30:	jmp    rsi
  208f32:	vshufpd ymm1,ymm0,ymm0,0x5
  208f37:	vbroadcastsd ymm11,xmm11
  208f3c:	vbroadcastsd ymm12,xmm12
  208f41:	vfmaddsub231pd ymm2,ymm1,ymm12
  208f46:	vfmaddsub231pd ymm2,ymm0,ymm11
  208f4b:	add    r12,r8
  208f4e:	add    r15,r10
  208f51:	dec    rdi
  208f54:	je     209021 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x731>
  208f5a:	vmovapd xmm0,xmm8
  208f5e:	test   bpl,bpl
  208f61:	jne    208f10 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  208f63:	vmovsd xmm0,QWORD PTR [r12]
  208f69:	vxorpd xmm0,xmm0,xmm5
  208f6d:	jmp    208f10 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  208f6f:	mov    r13,QWORD PTR [rsp+0x38]
  208f74:	shl    r13,0x4
  208f78:	add    r13,rcx
  208f7b:	mov    rax,r13
  208f7e:	lea    rcx,[rip+0x2]        # 208f87 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x697>
  208f85:	jmp    rsi
  208f87:	vmovapd ymm2,ymm0
  208f8b:	test   rdx,rdx
  208f8e:	mov    r9,QWORD PTR [rsp+0x40]
  208f93:	je     20909d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7ad>
  208f99:	mov    QWORD PTR [rsp+0x10],r12
  208f9e:	mov    rdi,rdx
  208fa1:	mov    r15,QWORD PTR [rsp+0x68]
  208fa6:	mov    r12,QWORD PTR [rsp+0x30]
  208fab:	jmp    20900c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x71c>
  208fad:	nop    DWORD PTR [rax]
  208fb0:	vmovsd xmm1,QWORD PTR [r15]
  208fb5:	vxorpd xmm1,xmm1,xmm5
  208fb9:	vmulsd xmm12,xmm0,QWORD PTR [r15-0x8]
  208fbf:	vmulsd xmm13,xmm0,xmm1
  208fc3:	vmovupd ymm14,YMMWORD PTR [r14]
  208fc8:	lea    rax,[r14+r9*1]
  208fcc:	lea    rcx,[rip+0x2]        # 208fd5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6e5>
  208fd3:	jmp    rsi
  208fd5:	vshufpd ymm1,ymm14,ymm14,0x5
  208fdb:	vbroadcastsd ymm12,xmm12
  208fe0:	vbroadcastsd ymm13,xmm13
  208fe5:	vfmaddsub231pd ymm11,ymm13,ymm1
  208fea:	vfmaddsub231pd ymm11,ymm12,ymm14
  208fef:	vshufpd ymm1,ymm0,ymm0,0x5
  208ff4:	vfmaddsub231pd ymm2,ymm13,ymm1
  208ff9:	vfmaddsub231pd ymm2,ymm12,ymm0
  208ffe:	add    r12,r8
  209001:	add    r15,r10
  209004:	add    r14,r10
  209007:	dec    rdi
  20900a:	je     20908a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x79a>
  20900c:	vmovapd xmm0,xmm8
  209010:	test   bpl,bpl
  209013:	jne    208fb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  209015:	vmovsd xmm0,QWORD PTR [r12]
  20901b:	vxorpd xmm0,xmm0,xmm5
  20901f:	jmp    208fb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  209021:	mov    rdi,QWORD PTR [rsp+0x28]
  209026:	mov    rax,QWORD PTR [rsp+0x18]
  20902b:	lea    r15,[rax+rdi*1]
  20902f:	mov    r12,QWORD PTR [rsp+0x10]
  209034:	mov    rax,r14
  209037:	vmovapd ymm0,ymm2
  20903b:	mov    r13,QWORD PTR [rsp+0x48]
  209040:	lea    rcx,[rip+0x3]        # 20904a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75a>
  209047:	jmp    r13
  20904a:	jmp    2090c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20904c:	mov    rdi,QWORD PTR [rsp+0x28]
  209051:	mov    rax,QWORD PTR [rsp+0x18]
  209056:	lea    r15,[rax+rdi*1]
  20905a:	mov    r12,QWORD PTR [rsp+0x10]
  20905f:	mov    rax,QWORD PTR [rsp+0xe0]
  209067:	mov    rcx,QWORD PTR [rsp+0x58]
  20906c:	vmovupd YMMWORD PTR [rcx],ymm11
  209070:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209075:	vmovapd ymm0,ymm2
  209079:	mov    r13,QWORD PTR [rsp+0x48]
  20907e:	lea    rcx,[rip+0x3]        # 209088 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x798>
  209085:	jmp    r13
  209088:	jmp    2090c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20908a:	mov    rdi,QWORD PTR [rsp+0x28]
  20908f:	mov    rax,QWORD PTR [rsp+0x18]
  209094:	lea    r15,[rax+rdi*1]
  209098:	mov    r12,QWORD PTR [rsp+0x10]
  20909d:	mov    rax,QWORD PTR [rsp+0x58]
  2090a2:	vmovupd YMMWORD PTR [rax],ymm11
  2090a6:	mov    rax,r13
  2090a9:	vmovapd ymm0,ymm2
  2090ad:	mov    r13,QWORD PTR [rsp+0x48]
  2090b2:	lea    rcx,[rip+0x3]        # 2090bc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7cc>
  2090b9:	jmp    r13
  2090bc:	nop    DWORD PTR [rax+0x0]
  2090c0:	mov    r14,QWORD PTR [rsp+0x20]
  2090c5:	mov    rcx,rdx
  2090c8:	imul   rcx,QWORD PTR [rsp+0xf8]
  2090d1:	shl    rcx,0x4
  2090d5:	add    rcx,QWORD PTR [rsp+0x30]
  2090da:	mov    rax,rdx
  2090dd:	sub    rax,rdi
  2090e0:	jae    2090f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x800>
  2090e2:	vmovsd xmm0,QWORD PTR [rcx]
  2090e6:	jmp    209185 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x895>
  2090eb:	nop    DWORD PTR [rax+rax*1+0x0]
  2090f0:	cmp    rax,QWORD PTR [rsp+0x18]
  2090f5:	jae    209324 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa34>
  2090fb:	mov    rax,rdx
  2090fe:	shl    rax,0x4
  209102:	vmovsd xmm0,QWORD PTR [r12+rax*1]
  209108:	cmp    BYTE PTR [rsp+0xf],0x0
  20910d:	je     20912c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x83c>
  20910f:	test   bpl,bpl
  209112:	je     209228 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x938>
  209118:	vucomisd xmm3,xmm0
  20911c:	jb     209131 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x841>
  20911e:	inc    QWORD PTR [rsp+0x60]
  209123:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20912c:	test   bpl,bpl
  20912f:	je     209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  209131:	vxorpd xmm1,xmm1,xmm1
  209135:	vucomisd xmm0,xmm1
  209139:	jbe    2092c1 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9d1>
  20913f:	vsqrtsd xmm0,xmm0,xmm0
  209143:	vmovsd QWORD PTR [rcx],xmm0
  209147:	vmovq  rax,xmm0
  20914c:	mov    QWORD PTR [rcx+0x8],0x0
  209154:	mov    cl,0x3f
  209156:	bzhi   rax,rax,rcx
  20915b:	movabs rcx,0x7ff0000000000000
  209165:	cmp    rax,rcx
  209168:	setg   cl
  20916b:	sete   dil
  20916f:	test   rax,rax
  209172:	sete   al
  209175:	or     al,dil
  209178:	or     al,cl
  20917a:	mov    rdi,QWORD PTR [rsp+0x28]
  20917f:	jne    2092cd <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9dd>
  209185:	mov    r12,r15
  209188:	vdivsd xmm0,xmm9,xmm0
  20918c:	vbroadcastsd ymm2,xmm0
  209191:	cmp    QWORD PTR [rsp+0xa8],0x0
  20919a:	je     208bc0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  2091a0:	cmp    QWORD PTR [rsp+0xf0],0x8
  2091a9:	jae    2091b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8c0>
  2091ab:	xor    eax,eax
  2091ad:	jmp    209202 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x912>
  2091af:	nop
  2091b0:	mov    rcx,QWORD PTR [rsp+0x98]
  2091b8:	xor    eax,eax
  2091ba:	nop    WORD PTR [rax+rax*1+0x0]
  2091c0:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  2091c5:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  2091ca:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  2091cf:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  2091d4:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  2091d9:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  2091de:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  2091e2:	add    rax,0x4
  2091e6:	vmovupd YMMWORD PTR [rcx],ymm0
  2091ea:	sub    rcx,0xffffffffffffff80
  2091ee:	cmp    r14,rax
  2091f1:	jne    2091c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8d0>
  2091f3:	cmp    QWORD PTR [rsp+0xe8],0x0
  2091fc:	je     208bc0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  209202:	shl    rax,0x5
  209206:	add    rax,QWORD PTR [rsp+0xa0]
  20920e:	xor    ecx,ecx
  209210:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  209215:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20921a:	add    rcx,0x20
  20921e:	cmp    r11,rcx
  209221:	jne    209210 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x920>
  209223:	jmp    208bc0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  209228:	mov    rax,QWORD PTR [rsp+0x80]
  209230:	test   rax,rax
  209233:	je     20926c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x97c>
  209235:	movzx  r14d,BYTE PTR [rax+rdx*1]
  20923a:	vucomisd xmm3,xmm0
  20923e:	setae  al
  209241:	vucomisd xmm0,xmm6
  209245:	setae  dil
  209249:	cmp    r14d,0xff
  209250:	je     2092a4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9b4>
  209252:	cmp    r14d,0x1
  209256:	mov    r14,QWORD PTR [rsp+0x20]
  20925b:	jne    20927b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x98b>
  20925d:	vucomisd xmm3,xmm0
  209261:	jae    20911e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x82e>
  209267:	jmp    209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20926c:	vucomisd xmm3,xmm0
  209270:	setae  al
  209273:	vucomisd xmm0,xmm6
  209277:	setae  dil
  20927b:	test   dil,dil
  20927e:	je     209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  209284:	test   al,al
  209286:	je     209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20928c:	vxorpd xmm1,xmm1,xmm1
  209290:	vucomisd xmm1,xmm0
  209294:	ja     2092b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9c3>
  209296:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20929f:	jmp    209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  2092a4:	vucomisd xmm0,xmm6
  2092a8:	mov    r14,QWORD PTR [rsp+0x20]
  2092ad:	jb     209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  2092b3:	vmovapd xmm0,XMMWORD PTR [rsp+0x130]
  2092bc:	jmp    209143 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  2092c1:	vmovsd QWORD PTR [rcx],xmm0
  2092c5:	mov    QWORD PTR [rcx+0x8],0x0
  2092cd:	mov    eax,0x1
  2092d2:	add    rsp,0x148
  2092d9:	pop    rbx
  2092da:	pop    r12
  2092dc:	pop    r13
  2092de:	pop    r14
  2092e0:	pop    r15
  2092e2:	pop    rbp
  2092e3:	vzeroupper
  2092e6:	ret
  2092e7:	mov    rdx,rsi
  2092ea:	xor    eax,eax
  2092ec:	jmp    2092d2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  2092ee:	lea    rdi,[rip+0xffffffffffe3dcf3]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  2092f5:	lea    rdx,[rip+0x33293c]        # 53bc38 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xd8>
  2092fc:	mov    esi,0x28
  209301:	vzeroupper
  209304:	call   QWORD PTR [rip+0x340f06]        # 54a210 <_DYNAMIC+0x438>
  20930a:	lea    rcx,[rip+0x332bc7]        # 53bed8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1b0>
  209311:	xor    edi,edi
  209313:	mov    rsi,r15
  209316:	mov    rdx,QWORD PTR [rsp+0x78]
  20931b:	vzeroupper
  20931e:	call   QWORD PTR [rip+0x340db4]        # 54a0d8 <_DYNAMIC+0x300>
  209324:	lea    r10,[rip+0x332925]        # 53bc50 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xf0>
  20932b:	lea    r11,[rip+0xffffffffffe3669e]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209332:	lea    rbx,[rip+0x3325b7]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  209339:	lea    r14,[rip+0x332f98]        # 53c2d8 <anon.c38c26bc52a245a79a4d978676f36d04.145.llvm.17936451394092910270>
  209340:	mov    r8d,0x1
  209346:	mov    r9d,0x1
  20934c:	mov    rdi,rax
  20934f:	mov    rsi,rax
  209352:	mov    rdx,QWORD PTR [rsp+0x18]
  209357:	movabs rcx,0x7fffffffffffffff
  209361:	push   r10
  209363:	push   r11
  209365:	push   rbx
  209366:	push   r14
  209368:	vzeroupper
  20936b:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  209370:	lea    rax,[rip+0x332891]        # 53bc08 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xa8>
  209377:	lea    r10,[rip+0xffffffffffe36652]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20937e:	lea    r11,[rip+0x332513]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209385:	lea    rbx,[rip+0x332754]        # 53bae0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x1f0>
  20938c:	mov    r8d,0x1
  209392:	mov    r9d,0x1
  209398:	mov    rdi,r15
  20939b:	mov    rsi,r15
  20939e:	mov    rdx,QWORD PTR [rsp+0xb0]
  2093a6:	jmp    209416 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xb26>
  2093a8:	sub    rsp,0x8
  2093ac:	lea    rax,[rip+0x3325f5]        # 53b9a8 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0xb8>
  2093b3:	lea    rcx,[rip+0x3325a6]        # 53b960 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x70>
  2093ba:	lea    r8,[rip+0x3324bf]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  2093c1:	lea    r9,[rip+0xffffffffffe36608]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  2093c8:	mov    edx,0x1
  2093cd:	mov    rdi,r15
  2093d0:	mov    rsi,QWORD PTR [rsp+0x78]
  2093d5:	push   rax
  2093d6:	vzeroupper
  2093d9:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  2093de:	lea    rax,[rip+0x33283b]        # 53bc20 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xc0>
  2093e5:	lea    r10,[rip+0xffffffffffe365e4]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  2093ec:	lea    r11,[rip+0x3324a5]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  2093f3:	lea    rbx,[rip+0x332f5e]        # 53c358 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x58>
  2093fa:	mov    r8d,0x1
  209400:	mov    r9d,0x1
  209406:	mov    rsi,rdi
  209409:	mov    rdx,r15
  20940c:	movabs rcx,0x7fffffffffffffff
  209416:	push   rax
  209417:	push   r10
  209419:	push   r11
  20941b:	push   rbx
  20941c:	vzeroupper
  20941f:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
