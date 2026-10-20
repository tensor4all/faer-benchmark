
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/a53774682edd-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000209e60 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench>:
  209e60:	push   rbp
  209e61:	push   r15
  209e63:	push   r14
  209e65:	push   r13
  209e67:	push   r12
  209e69:	push   rbx
  209e6a:	sub    rsp,0x148
  209e71:	mov    rax,QWORD PTR [rdi+0x8]
  209e75:	test   rax,rax
  209e78:	je     209f62 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  209e7e:	mov    rcx,QWORD PTR [rdi+0x10]
  209e82:	cmp    rax,rcx
  209e85:	mov    rdx,rcx
  209e88:	cmovb  rdx,rax
  209e8c:	mov    QWORD PTR [rsp+0xd0],rdx
  209e94:	test   rcx,rcx
  209e97:	je     209f62 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  209e9d:	mov    QWORD PTR [rsp+0xb0],rax
  209ea5:	mov    rax,QWORD PTR [rdi+0x40]
  209ea9:	mov    QWORD PTR [rsp+0x30],rax
  209eae:	mov    rax,QWORD PTR [rdi+0x48]
  209eb2:	mov    QWORD PTR [rsp+0x70],rax
  209eb7:	mov    r8,QWORD PTR [rdi+0x50]
  209ebb:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  209ec0:	vmovsd xmm0,QWORD PTR [rdi+0x38]
  209ec5:	mov    rdx,QWORD PTR [rdi+0x20]
  209ec9:	mov    rax,QWORD PTR [rdi+0x28]
  209ecd:	mov    QWORD PTR [rsp+0x78],rax
  209ed2:	movzx  eax,BYTE PTR [rdi+0x59]
  209ed6:	mov    BYTE PTR [rsp+0xf],al
  209eda:	movzx  ebp,BYTE PTR [rdi+0x58]
  209ede:	mov    r9,QWORD PTR [rdi]
  209ee1:	mov    r10,QWORD PTR [rdi+0x18]
  209ee5:	vmovddup xmm5,QWORD PTR [rip+0xffffffffffe35c33]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  209eed:	vxorpd xmm6,xmm3,xmm5
  209ef1:	vmovapd XMMWORD PTR [rsp+0x120],xmm0
  209efa:	vxorpd xmm0,xmm0,xmm5
  209efe:	vmovapd XMMWORD PTR [rsp+0x130],xmm0
  209f07:	mov    QWORD PTR [rsp+0xf8],r8
  209f0f:	shl    r8,0x4
  209f13:	mov    QWORD PTR [rsp+0x100],r10
  209f1b:	shl    r10,0x4
  209f1f:	lea    rax,[r9+0x8]
  209f23:	mov    QWORD PTR [rsp+0xc0],rax
  209f2b:	lea    rax,[r9+0x60]
  209f2f:	mov    QWORD PTR [rsp+0xb8],rax
  209f37:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe35b21]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  209f3f:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe35b81]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  209f47:	xor    esi,esi
  209f49:	xor    edi,edi
  209f4b:	mov    QWORD PTR [rsp+0x50],r9
  209f50:	mov    QWORD PTR [rsp+0xc8],rcx
  209f58:	mov    QWORD PTR [rsp+0x80],rdx
  209f60:	jmp    209fa2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x142>
  209f62:	xor    edx,edx
  209f64:	xor    eax,eax
  209f66:	jmp    20a842 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  209f6b:	nop    DWORD PTR [rax+rax*1+0x0]
  209f70:	mov    QWORD PTR [rsp+0x60],0x0
  209f79:	mov    rsi,QWORD PTR [rsp+0xd8]
  209f81:	add    rsi,QWORD PTR [rsp+0x60]
  209f86:	mov    rdi,r15
  209f89:	mov    rcx,QWORD PTR [rsp+0xc8]
  209f91:	cmp    r15,rcx
  209f94:	mov    rdx,QWORD PTR [rsp+0x80]
  209f9c:	jae    20a857 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9f7>
  209fa2:	mov    r9,rcx
  209fa5:	sub    r9,rdi
  209fa8:	cmp    r9,0x8
  209fac:	mov    eax,0x8
  209fb1:	cmovae r9,rax
  209fb5:	mov    QWORD PTR [rsp+0x18],r9
  209fba:	lea    r15,[r9+rdi*1]
  209fbe:	cmp    r15,QWORD PTR [rsp+0xd0]
  209fc6:	ja     20a8e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa80>
  209fcc:	cmp    r15,QWORD PTR [rsp+0x70]
  209fd1:	ja     20a918 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xab8>
  209fd7:	cmp    r15,QWORD PTR [rsp+0x78]
  209fdc:	seta   al
  209fdf:	test   rdx,rdx
  209fe2:	jne    209fe6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x186>
  209fe4:	xor    eax,eax
  209fe6:	test   al,al
  209fe8:	jne    20a87a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa1a>
  209fee:	test   rdi,rdi
  209ff1:	js     20a94e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  209ff7:	cmp    rdi,r15
  209ffa:	ja     20a94e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  20a000:	mov    QWORD PTR [rsp+0xd8],rsi
  20a008:	test   r15,r15
  20a00b:	je     209f70 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x110>
  20a011:	mov    rax,QWORD PTR [rsp+0x18]
  20a016:	lea    rdx,[rax-0x1]
  20a01a:	mov    r9,rdx
  20a01d:	shr    r9,1
  20a020:	mov    eax,edx
  20a022:	and    eax,0x1
  20a025:	shl    eax,0xa
  20a028:	mov    rcx,QWORD PTR [rip+0x340191]        # 54a1c0 <_DYNAMIC+0x3e8>
  20a02f:	mov    rsi,QWORD PTR [rcx+rax*1+0x400]
  20a037:	mov    r13,QWORD PTR [rcx+rax*1+0x408]
  20a03f:	mov    QWORD PTR [rsp+0xf0],rdx
  20a047:	and    rdx,0xfffffffffffffffe
  20a04b:	mov    QWORD PTR [rsp+0x38],rdx
  20a050:	xor    eax,eax
  20a052:	test   r9,r9
  20a055:	setne  al
  20a058:	lea    rdx,[rax+0x1]
  20a05c:	cmp    r9,rax
  20a05f:	mov    QWORD PTR [rsp+0x88],rax
  20a067:	cmovbe rdx,rax
  20a06b:	lea    ebx,[rdx+rdx*1]
  20a06e:	mov    r11d,r9d
  20a071:	and    r11d,0x3
  20a075:	movabs rax,0x7fffffffffffffff
  20a07f:	lea    r14,[rax-0x3]
  20a083:	and    r14,r9
  20a086:	mov    rax,r9
  20a089:	shl    rax,0x5
  20a08d:	mov    QWORD PTR [rsp+0x40],rax
  20a092:	mov    QWORD PTR [rsp+0x110],rdx
  20a09a:	shl    edx,0x5
  20a09d:	mov    QWORD PTR [rsp+0x118],rdx
  20a0a5:	mov    rdx,rdi
  20a0a8:	shl    rdx,0x4
  20a0ac:	mov    rax,QWORD PTR [rsp+0xb8]
  20a0b4:	add    rax,rdx
  20a0b7:	mov    QWORD PTR [rsp+0x98],rax
  20a0bf:	mov    QWORD PTR [rsp+0xe8],r11
  20a0c7:	shl    r11d,0x5
  20a0cb:	shl    ebx,0x4
  20a0ce:	mov    QWORD PTR [rsp+0x90],rbx
  20a0d6:	mov    QWORD PTR [rsp+0x108],rdx
  20a0de:	mov    rax,QWORD PTR [rsp+0x50]
  20a0e3:	add    rax,rdx
  20a0e6:	mov    QWORD PTR [rsp+0xa0],rax
  20a0ee:	mov    ebx,0x8
  20a0f3:	mov    rax,QWORD PTR [rsp+0xc0]
  20a0fb:	mov    QWORD PTR [rsp+0x68],rax
  20a100:	mov    QWORD PTR [rsp+0x60],0x0
  20a109:	xor    edx,edx
  20a10b:	mov    QWORD PTR [rsp+0x28],rdi
  20a110:	mov    QWORD PTR [rsp+0xa8],r9
  20a118:	mov    QWORD PTR [rsp+0x48],r13
  20a11d:	mov    QWORD PTR [rsp+0x20],r14
  20a122:	jmp    20a18c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x32c>
  20a124:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20a130:	inc    rdx
  20a133:	mov    rax,QWORD PTR [rsp+0x38]
  20a138:	shl    rax,0x4
  20a13c:	mov    r15,QWORD PTR [rsp+0x58]
  20a141:	add    r15,rax
  20a144:	mov    rax,r15
  20a147:	lea    rcx,[rip+0x2]        # 20a150 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2f0>
  20a14e:	jmp    rsi
  20a150:	vmulpd ymm0,ymm2,ymm0
  20a154:	lea    rcx,[rip+0x3]        # 20a15e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2fe>
  20a15b:	jmp    r13
  20a15e:	add    rbx,0x10
  20a162:	add    QWORD PTR [rsp+0x68],0x10
  20a168:	add    QWORD PTR [rsp+0x98],r10
  20a170:	add    QWORD PTR [rsp+0xa0],r10
  20a178:	mov    r15,r12
  20a17b:	cmp    rdx,r12
  20a17e:	mov    r9,QWORD PTR [rsp+0xa8]
  20a186:	je     209f79 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x119>
  20a18c:	test   rdx,rdx
  20a18f:	mov    r13,rdi
  20a192:	cmove  r13,rdx
  20a196:	shl    r13,0x4
  20a19a:	mov    rax,QWORD PTR [rsp+0x50]
  20a19f:	lea    r14,[rax+r13*1]
  20a1a3:	mov    r12,rdx
  20a1a6:	imul   r12,QWORD PTR [rsp+0x100]
  20a1af:	shl    r12,0x4
  20a1b3:	add    r12,rax
  20a1b6:	mov    rax,QWORD PTR [rsp+0x108]
  20a1be:	lea    rcx,[r12+rax*1]
  20a1c2:	cmp    QWORD PTR [rsp+0x110],r9
  20a1ca:	mov    QWORD PTR [rsp+0x58],rcx
  20a1cf:	jae    20a2f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x490>
  20a1d5:	cmp    r9,QWORD PTR [rsp+0x88]
  20a1dd:	jbe    20a85e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9fe>
  20a1e3:	vmovupd ymm11,YMMWORD PTR [rcx]
  20a1e7:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20a1ec:	mov    rax,QWORD PTR [rsp+0x90]
  20a1f4:	vmovupd ymm13,YMMWORD PTR [rcx+rax*1]
  20a1f9:	mov    r13,QWORD PTR [rsp+0x38]
  20a1fe:	shl    r13,0x4
  20a202:	add    r13,rcx
  20a205:	mov    rax,r13
  20a208:	lea    rcx,[rip+0x2]        # 20a211 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3b1>
  20a20f:	jmp    rsi
  20a211:	vmovapd ymm2,ymm0
  20a215:	test   rdx,rdx
  20a218:	je     20a403 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5a3>
  20a21e:	mov    QWORD PTR [rsp+0x10],r12
  20a223:	mov    r15,rdx
  20a226:	mov    r12,QWORD PTR [rsp+0x68]
  20a22b:	mov    rdi,QWORD PTR [rsp+0x30]
  20a230:	mov    r9,QWORD PTR [rsp+0x40]
  20a235:	jmp    20a2d5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x475>
  20a23a:	nop    WORD PTR [rax+rax*1+0x0]
  20a240:	vmovsd xmm1,QWORD PTR [r12]
  20a246:	vxorpd xmm1,xmm1,xmm5
  20a24a:	vmulsd xmm7,xmm0,QWORD PTR [r12-0x8]
  20a251:	vmulsd xmm14,xmm0,xmm1
  20a255:	vmovupd ymm15,YMMWORD PTR [r14]
  20a25a:	vmovupd ymm4,YMMWORD PTR [r14+0x20]
  20a260:	mov    rax,QWORD PTR [rsp+0x118]
  20a268:	vmovupd ymm10,YMMWORD PTR [r14+rax*1]
  20a26e:	lea    rax,[r14+r9*1]
  20a272:	lea    rcx,[rip+0x2]        # 20a27b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x41b>
  20a279:	jmp    rsi
  20a27b:	vshufpd ymm1,ymm15,ymm15,0x5
  20a281:	vbroadcastsd ymm7,xmm7
  20a286:	vbroadcastsd ymm14,xmm14
  20a28b:	vfmaddsub231pd ymm11,ymm14,ymm1
  20a290:	vfmaddsub231pd ymm11,ymm7,ymm15
  20a295:	vshufpd ymm1,ymm4,ymm4,0x5
  20a29a:	vfmaddsub231pd ymm12,ymm14,ymm1
  20a29f:	vfmaddsub231pd ymm12,ymm7,ymm4
  20a2a4:	vshufpd ymm1,ymm10,ymm10,0x5
  20a2aa:	vfmaddsub231pd ymm13,ymm14,ymm1
  20a2af:	vfmaddsub231pd ymm13,ymm7,ymm10
  20a2b4:	vshufpd ymm1,ymm0,ymm0,0x5
  20a2b9:	vfmaddsub231pd ymm2,ymm14,ymm1
  20a2be:	vfmaddsub231pd ymm2,ymm7,ymm0
  20a2c3:	add    rdi,r8
  20a2c6:	add    r12,r10
  20a2c9:	add    r14,r10
  20a2cc:	dec    r15
  20a2cf:	je     20a3f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x590>
  20a2d5:	vmovapd xmm0,xmm8
  20a2d9:	test   bpl,bpl
  20a2dc:	jne    20a240 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  20a2e2:	vmovsd xmm0,QWORD PTR [rdi]
  20a2e6:	vxorpd xmm0,xmm0,xmm5
  20a2ea:	jmp    20a240 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  20a2ef:	nop
  20a2f0:	test   r9,r9
  20a2f3:	je     20a43b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5db>
  20a2f9:	vmovupd ymm11,YMMWORD PTR [rcx]
  20a2fd:	cmp    r9,QWORD PTR [rsp+0x88]
  20a305:	jbe    20a4df <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x67f>
  20a30b:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20a310:	mov    rax,QWORD PTR [rsp+0x38]
  20a315:	shl    rax,0x4
  20a319:	add    rax,rcx
  20a31c:	lea    rcx,[rip+0x2]        # 20a325 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x4c5>
  20a323:	jmp    rsi
  20a325:	vmovapd ymm2,ymm0
  20a329:	test   rdx,rdx
  20a32c:	mov    rcx,QWORD PTR [rsp+0x40]
  20a331:	je     20a5d7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x777>
  20a337:	mov    QWORD PTR [rsp+0xe0],rax
  20a33f:	mov    QWORD PTR [rsp+0x10],r12
  20a344:	lea    rdi,[rcx+r13*1]
  20a348:	mov    r15,rdx
  20a34b:	mov    r12,QWORD PTR [rsp+0x50]
  20a350:	mov    r14,QWORD PTR [rsp+0x30]
  20a355:	jmp    20a3d6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x576>
  20a357:	nop    WORD PTR [rax+rax*1+0x0]
  20a360:	vmovsd xmm1,QWORD PTR [r12+rbx*1]
  20a366:	vxorpd xmm1,xmm1,xmm5
  20a36a:	vmulsd xmm13,xmm0,QWORD PTR [r12+rbx*1-0x8]
  20a371:	vmulsd xmm14,xmm0,xmm1
  20a375:	vmovupd ymm15,YMMWORD PTR [r12+r13*1]
  20a37b:	vmovupd ymm7,YMMWORD PTR [r12+r13*1+0x20]
  20a382:	lea    rax,[r12+rdi*1]
  20a386:	lea    rcx,[rip+0x2]        # 20a38f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x52f>
  20a38d:	jmp    rsi
  20a38f:	vshufpd ymm1,ymm15,ymm15,0x5
  20a395:	vbroadcastsd ymm13,xmm13
  20a39a:	vbroadcastsd ymm14,xmm14
  20a39f:	vfmaddsub231pd ymm11,ymm14,ymm1
  20a3a4:	vfmaddsub231pd ymm11,ymm13,ymm15
  20a3a9:	vshufpd ymm1,ymm7,ymm7,0x5
  20a3ae:	vfmaddsub231pd ymm12,ymm14,ymm1
  20a3b3:	vfmaddsub231pd ymm12,ymm13,ymm7
  20a3b8:	vshufpd ymm1,ymm0,ymm0,0x5
  20a3bd:	vfmaddsub231pd ymm2,ymm14,ymm1
  20a3c2:	vfmaddsub231pd ymm2,ymm13,ymm0
  20a3c7:	add    r14,r8
  20a3ca:	add    r12,r10
  20a3cd:	dec    r15
  20a3d0:	je     20a5bc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75c>
  20a3d6:	vmovapd xmm0,xmm8
  20a3da:	test   bpl,bpl
  20a3dd:	jne    20a360 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  20a3df:	vmovsd xmm0,QWORD PTR [r14]
  20a3e4:	vxorpd xmm0,xmm0,xmm5
  20a3e8:	jmp    20a360 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  20a3ed:	nop    DWORD PTR [rax]
  20a3f0:	mov    rdi,QWORD PTR [rsp+0x28]
  20a3f5:	mov    rax,QWORD PTR [rsp+0x18]
  20a3fa:	lea    r15,[rax+rdi*1]
  20a3fe:	mov    r12,QWORD PTR [rsp+0x10]
  20a403:	mov    rax,QWORD PTR [rsp+0x90]
  20a40b:	mov    rcx,QWORD PTR [rsp+0x58]
  20a410:	add    rax,rcx
  20a413:	vmovupd YMMWORD PTR [rcx],ymm11
  20a417:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20a41c:	vmovupd YMMWORD PTR [rax],ymm13
  20a420:	mov    rax,r13
  20a423:	vmovapd ymm0,ymm2
  20a427:	mov    r13,QWORD PTR [rsp+0x48]
  20a42c:	lea    rcx,[rip+0x3]        # 20a436 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5d6>
  20a433:	jmp    r13
  20a436:	jmp    20a630 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a43b:	mov    r14,QWORD PTR [rsp+0x38]
  20a440:	shl    r14,0x4
  20a444:	add    r14,rcx
  20a447:	mov    rax,r14
  20a44a:	lea    rcx,[rip+0x2]        # 20a453 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5f3>
  20a451:	jmp    rsi
  20a453:	vmovapd ymm2,ymm0
  20a457:	test   rdx,rdx
  20a45a:	mov    rax,QWORD PTR [rsp+0x40]
  20a45f:	je     20a5a4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x744>
  20a465:	mov    QWORD PTR [rsp+0x10],r12
  20a46a:	add    r13,rax
  20a46d:	mov    rdi,rdx
  20a470:	mov    r15,QWORD PTR [rsp+0x50]
  20a475:	mov    r12,QWORD PTR [rsp+0x30]
  20a47a:	jmp    20a4ca <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x66a>
  20a47c:	nop    DWORD PTR [rax+0x0]
  20a480:	vmovsd xmm1,QWORD PTR [r15+rbx*1]
  20a486:	vxorpd xmm1,xmm1,xmm5
  20a48a:	vmulsd xmm11,xmm0,QWORD PTR [r15+rbx*1-0x8]
  20a491:	vmulsd xmm12,xmm0,xmm1
  20a495:	lea    rax,[r15+r13*1]
  20a499:	lea    rcx,[rip+0x2]        # 20a4a2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x642>
  20a4a0:	jmp    rsi
  20a4a2:	vshufpd ymm1,ymm0,ymm0,0x5
  20a4a7:	vbroadcastsd ymm11,xmm11
  20a4ac:	vbroadcastsd ymm12,xmm12
  20a4b1:	vfmaddsub231pd ymm2,ymm1,ymm12
  20a4b6:	vfmaddsub231pd ymm2,ymm0,ymm11
  20a4bb:	add    r12,r8
  20a4be:	add    r15,r10
  20a4c1:	dec    rdi
  20a4c4:	je     20a591 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x731>
  20a4ca:	vmovapd xmm0,xmm8
  20a4ce:	test   bpl,bpl
  20a4d1:	jne    20a480 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  20a4d3:	vmovsd xmm0,QWORD PTR [r12]
  20a4d9:	vxorpd xmm0,xmm0,xmm5
  20a4dd:	jmp    20a480 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  20a4df:	mov    r13,QWORD PTR [rsp+0x38]
  20a4e4:	shl    r13,0x4
  20a4e8:	add    r13,rcx
  20a4eb:	mov    rax,r13
  20a4ee:	lea    rcx,[rip+0x2]        # 20a4f7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x697>
  20a4f5:	jmp    rsi
  20a4f7:	vmovapd ymm2,ymm0
  20a4fb:	test   rdx,rdx
  20a4fe:	mov    r9,QWORD PTR [rsp+0x40]
  20a503:	je     20a60d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7ad>
  20a509:	mov    QWORD PTR [rsp+0x10],r12
  20a50e:	mov    rdi,rdx
  20a511:	mov    r15,QWORD PTR [rsp+0x68]
  20a516:	mov    r12,QWORD PTR [rsp+0x30]
  20a51b:	jmp    20a57c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x71c>
  20a51d:	nop    DWORD PTR [rax]
  20a520:	vmovsd xmm1,QWORD PTR [r15]
  20a525:	vxorpd xmm1,xmm1,xmm5
  20a529:	vmulsd xmm12,xmm0,QWORD PTR [r15-0x8]
  20a52f:	vmulsd xmm13,xmm0,xmm1
  20a533:	vmovupd ymm14,YMMWORD PTR [r14]
  20a538:	lea    rax,[r14+r9*1]
  20a53c:	lea    rcx,[rip+0x2]        # 20a545 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6e5>
  20a543:	jmp    rsi
  20a545:	vshufpd ymm1,ymm14,ymm14,0x5
  20a54b:	vbroadcastsd ymm12,xmm12
  20a550:	vbroadcastsd ymm13,xmm13
  20a555:	vfmaddsub231pd ymm11,ymm13,ymm1
  20a55a:	vfmaddsub231pd ymm11,ymm12,ymm14
  20a55f:	vshufpd ymm1,ymm0,ymm0,0x5
  20a564:	vfmaddsub231pd ymm2,ymm13,ymm1
  20a569:	vfmaddsub231pd ymm2,ymm12,ymm0
  20a56e:	add    r12,r8
  20a571:	add    r15,r10
  20a574:	add    r14,r10
  20a577:	dec    rdi
  20a57a:	je     20a5fa <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x79a>
  20a57c:	vmovapd xmm0,xmm8
  20a580:	test   bpl,bpl
  20a583:	jne    20a520 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  20a585:	vmovsd xmm0,QWORD PTR [r12]
  20a58b:	vxorpd xmm0,xmm0,xmm5
  20a58f:	jmp    20a520 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  20a591:	mov    rdi,QWORD PTR [rsp+0x28]
  20a596:	mov    rax,QWORD PTR [rsp+0x18]
  20a59b:	lea    r15,[rax+rdi*1]
  20a59f:	mov    r12,QWORD PTR [rsp+0x10]
  20a5a4:	mov    rax,r14
  20a5a7:	vmovapd ymm0,ymm2
  20a5ab:	mov    r13,QWORD PTR [rsp+0x48]
  20a5b0:	lea    rcx,[rip+0x3]        # 20a5ba <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75a>
  20a5b7:	jmp    r13
  20a5ba:	jmp    20a630 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a5bc:	mov    rdi,QWORD PTR [rsp+0x28]
  20a5c1:	mov    rax,QWORD PTR [rsp+0x18]
  20a5c6:	lea    r15,[rax+rdi*1]
  20a5ca:	mov    r12,QWORD PTR [rsp+0x10]
  20a5cf:	mov    rax,QWORD PTR [rsp+0xe0]
  20a5d7:	mov    rcx,QWORD PTR [rsp+0x58]
  20a5dc:	vmovupd YMMWORD PTR [rcx],ymm11
  20a5e0:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20a5e5:	vmovapd ymm0,ymm2
  20a5e9:	mov    r13,QWORD PTR [rsp+0x48]
  20a5ee:	lea    rcx,[rip+0x3]        # 20a5f8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x798>
  20a5f5:	jmp    r13
  20a5f8:	jmp    20a630 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a5fa:	mov    rdi,QWORD PTR [rsp+0x28]
  20a5ff:	mov    rax,QWORD PTR [rsp+0x18]
  20a604:	lea    r15,[rax+rdi*1]
  20a608:	mov    r12,QWORD PTR [rsp+0x10]
  20a60d:	mov    rax,QWORD PTR [rsp+0x58]
  20a612:	vmovupd YMMWORD PTR [rax],ymm11
  20a616:	mov    rax,r13
  20a619:	vmovapd ymm0,ymm2
  20a61d:	mov    r13,QWORD PTR [rsp+0x48]
  20a622:	lea    rcx,[rip+0x3]        # 20a62c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7cc>
  20a629:	jmp    r13
  20a62c:	nop    DWORD PTR [rax+0x0]
  20a630:	mov    r14,QWORD PTR [rsp+0x20]
  20a635:	mov    rcx,rdx
  20a638:	imul   rcx,QWORD PTR [rsp+0xf8]
  20a641:	shl    rcx,0x4
  20a645:	add    rcx,QWORD PTR [rsp+0x30]
  20a64a:	mov    rax,rdx
  20a64d:	sub    rax,rdi
  20a650:	jae    20a660 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x800>
  20a652:	vmovsd xmm0,QWORD PTR [rcx]
  20a656:	jmp    20a6f5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x895>
  20a65b:	nop    DWORD PTR [rax+rax*1+0x0]
  20a660:	cmp    rax,QWORD PTR [rsp+0x18]
  20a665:	jae    20a894 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa34>
  20a66b:	mov    rax,rdx
  20a66e:	shl    rax,0x4
  20a672:	vmovsd xmm0,QWORD PTR [r12+rax*1]
  20a678:	cmp    BYTE PTR [rsp+0xf],0x0
  20a67d:	je     20a69c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x83c>
  20a67f:	test   bpl,bpl
  20a682:	je     20a798 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x938>
  20a688:	vucomisd xmm3,xmm0
  20a68c:	jb     20a6a1 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x841>
  20a68e:	inc    QWORD PTR [rsp+0x60]
  20a693:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20a69c:	test   bpl,bpl
  20a69f:	je     20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a6a1:	vxorpd xmm1,xmm1,xmm1
  20a6a5:	vucomisd xmm0,xmm1
  20a6a9:	jbe    20a831 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9d1>
  20a6af:	vsqrtsd xmm0,xmm0,xmm0
  20a6b3:	vmovsd QWORD PTR [rcx],xmm0
  20a6b7:	vmovq  rax,xmm0
  20a6bc:	mov    QWORD PTR [rcx+0x8],0x0
  20a6c4:	mov    cl,0x3f
  20a6c6:	bzhi   rax,rax,rcx
  20a6cb:	movabs rcx,0x7ff0000000000000
  20a6d5:	cmp    rax,rcx
  20a6d8:	setg   cl
  20a6db:	sete   dil
  20a6df:	test   rax,rax
  20a6e2:	sete   al
  20a6e5:	or     al,dil
  20a6e8:	or     al,cl
  20a6ea:	mov    rdi,QWORD PTR [rsp+0x28]
  20a6ef:	jne    20a83d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9dd>
  20a6f5:	mov    r12,r15
  20a6f8:	vdivsd xmm0,xmm9,xmm0
  20a6fc:	vbroadcastsd ymm2,xmm0
  20a701:	cmp    QWORD PTR [rsp+0xa8],0x0
  20a70a:	je     20a130 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a710:	cmp    QWORD PTR [rsp+0xf0],0x8
  20a719:	jae    20a720 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8c0>
  20a71b:	xor    eax,eax
  20a71d:	jmp    20a772 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x912>
  20a71f:	nop
  20a720:	mov    rcx,QWORD PTR [rsp+0x98]
  20a728:	xor    eax,eax
  20a72a:	nop    WORD PTR [rax+rax*1+0x0]
  20a730:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  20a735:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  20a73a:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  20a73f:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  20a744:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  20a749:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  20a74e:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  20a752:	add    rax,0x4
  20a756:	vmovupd YMMWORD PTR [rcx],ymm0
  20a75a:	sub    rcx,0xffffffffffffff80
  20a75e:	cmp    r14,rax
  20a761:	jne    20a730 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8d0>
  20a763:	cmp    QWORD PTR [rsp+0xe8],0x0
  20a76c:	je     20a130 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a772:	shl    rax,0x5
  20a776:	add    rax,QWORD PTR [rsp+0xa0]
  20a77e:	xor    ecx,ecx
  20a780:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  20a785:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20a78a:	add    rcx,0x20
  20a78e:	cmp    r11,rcx
  20a791:	jne    20a780 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x920>
  20a793:	jmp    20a130 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a798:	mov    rax,QWORD PTR [rsp+0x80]
  20a7a0:	test   rax,rax
  20a7a3:	je     20a7dc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x97c>
  20a7a5:	movzx  r14d,BYTE PTR [rax+rdx*1]
  20a7aa:	vucomisd xmm3,xmm0
  20a7ae:	setae  al
  20a7b1:	vucomisd xmm0,xmm6
  20a7b5:	setae  dil
  20a7b9:	cmp    r14d,0xff
  20a7c0:	je     20a814 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9b4>
  20a7c2:	cmp    r14d,0x1
  20a7c6:	mov    r14,QWORD PTR [rsp+0x20]
  20a7cb:	jne    20a7eb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x98b>
  20a7cd:	vucomisd xmm3,xmm0
  20a7d1:	jae    20a68e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x82e>
  20a7d7:	jmp    20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7dc:	vucomisd xmm3,xmm0
  20a7e0:	setae  al
  20a7e3:	vucomisd xmm0,xmm6
  20a7e7:	setae  dil
  20a7eb:	test   dil,dil
  20a7ee:	je     20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7f4:	test   al,al
  20a7f6:	je     20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7fc:	vxorpd xmm1,xmm1,xmm1
  20a800:	vucomisd xmm1,xmm0
  20a804:	ja     20a823 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9c3>
  20a806:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20a80f:	jmp    20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a814:	vucomisd xmm0,xmm6
  20a818:	mov    r14,QWORD PTR [rsp+0x20]
  20a81d:	jb     20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a823:	vmovapd xmm0,XMMWORD PTR [rsp+0x130]
  20a82c:	jmp    20a6b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a831:	vmovsd QWORD PTR [rcx],xmm0
  20a835:	mov    QWORD PTR [rcx+0x8],0x0
  20a83d:	mov    eax,0x1
  20a842:	add    rsp,0x148
  20a849:	pop    rbx
  20a84a:	pop    r12
  20a84c:	pop    r13
  20a84e:	pop    r14
  20a850:	pop    r15
  20a852:	pop    rbp
  20a853:	vzeroupper
  20a856:	ret
  20a857:	mov    rdx,rsi
  20a85a:	xor    eax,eax
  20a85c:	jmp    20a842 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  20a85e:	lea    rdi,[rip+0xffffffffffe3c783]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  20a865:	lea    rdx,[rip+0x331594]        # 53be00 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xd8>
  20a86c:	mov    esi,0x28
  20a871:	vzeroupper
  20a874:	call   QWORD PTR [rip+0x33f996]        # 54a210 <_DYNAMIC+0x438>
  20a87a:	lea    rcx,[rip+0x33169f]        # 53bf20 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1f8>
  20a881:	xor    edi,edi
  20a883:	mov    rsi,r15
  20a886:	mov    rdx,QWORD PTR [rsp+0x78]
  20a88b:	vzeroupper
  20a88e:	call   QWORD PTR [rip+0x33f844]        # 54a0d8 <_DYNAMIC+0x300>
  20a894:	lea    r10,[rip+0x33157d]        # 53be18 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xf0>
  20a89b:	lea    r11,[rip+0xffffffffffe3512e]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a8a2:	lea    rbx,[rip+0x331047]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  20a8a9:	lea    r14,[rip+0x331a50]        # 53c300 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270>
  20a8b0:	mov    r8d,0x1
  20a8b6:	mov    r9d,0x1
  20a8bc:	mov    rdi,rax
  20a8bf:	mov    rsi,rax
  20a8c2:	mov    rdx,QWORD PTR [rsp+0x18]
  20a8c7:	movabs rcx,0x7fffffffffffffff
  20a8d1:	push   r10
  20a8d3:	push   r11
  20a8d5:	push   rbx
  20a8d6:	push   r14
  20a8d8:	vzeroupper
  20a8db:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  20a8e0:	lea    rax,[rip+0x3314e9]        # 53bdd0 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xa8>
  20a8e7:	lea    r10,[rip+0xffffffffffe350e2]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a8ee:	lea    r11,[rip+0x330fa3]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20a8f5:	lea    rbx,[rip+0x33120c]        # 53bb08 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x218>
  20a8fc:	mov    r8d,0x1
  20a902:	mov    r9d,0x1
  20a908:	mov    rdi,r15
  20a90b:	mov    rsi,r15
  20a90e:	mov    rdx,QWORD PTR [rsp+0xb0]
  20a916:	jmp    20a986 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xb26>
  20a918:	sub    rsp,0x8
  20a91c:	lea    rax,[rip+0x331145]        # 53ba68 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x178>
  20a923:	lea    rcx,[rip+0x3310f6]        # 53ba20 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x130>
  20a92a:	lea    r8,[rip+0x330f4f]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  20a931:	lea    r9,[rip+0xffffffffffe35098]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a938:	mov    edx,0x1
  20a93d:	mov    rdi,r15
  20a940:	mov    rsi,QWORD PTR [rsp+0x78]
  20a945:	push   rax
  20a946:	vzeroupper
  20a949:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  20a94e:	lea    rax,[rip+0x331493]        # 53bde8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xc0>
  20a955:	lea    r10,[rip+0xffffffffffe35074]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a95c:	lea    r11,[rip+0x330f35]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20a963:	lea    rbx,[rip+0x331a16]        # 53c380 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x80>
  20a96a:	mov    r8d,0x1
  20a970:	mov    r9d,0x1
  20a976:	mov    rsi,rdi
  20a979:	mov    rdx,r15
  20a97c:	movabs rcx,0x7fffffffffffffff
  20a986:	push   rax
  20a987:	push   r10
  20a989:	push   r11
  20a98b:	push   rbx
  20a98c:	vzeroupper
  20a98f:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
