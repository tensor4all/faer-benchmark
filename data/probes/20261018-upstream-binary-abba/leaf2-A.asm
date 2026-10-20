
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/2240b076a030-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000209e50 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench>:
  209e50:	push   rbp
  209e51:	push   r15
  209e53:	push   r14
  209e55:	push   r13
  209e57:	push   r12
  209e59:	push   rbx
  209e5a:	sub    rsp,0x148
  209e61:	mov    rax,QWORD PTR [rdi+0x8]
  209e65:	test   rax,rax
  209e68:	je     209f52 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  209e6e:	mov    rcx,QWORD PTR [rdi+0x10]
  209e72:	cmp    rax,rcx
  209e75:	mov    rdx,rcx
  209e78:	cmovb  rdx,rax
  209e7c:	mov    QWORD PTR [rsp+0xd0],rdx
  209e84:	test   rcx,rcx
  209e87:	je     209f52 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  209e8d:	mov    QWORD PTR [rsp+0xb0],rax
  209e95:	mov    rax,QWORD PTR [rdi+0x40]
  209e99:	mov    QWORD PTR [rsp+0x30],rax
  209e9e:	mov    rax,QWORD PTR [rdi+0x48]
  209ea2:	mov    QWORD PTR [rsp+0x70],rax
  209ea7:	mov    r8,QWORD PTR [rdi+0x50]
  209eab:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  209eb0:	vmovsd xmm0,QWORD PTR [rdi+0x38]
  209eb5:	mov    rdx,QWORD PTR [rdi+0x20]
  209eb9:	mov    rax,QWORD PTR [rdi+0x28]
  209ebd:	mov    QWORD PTR [rsp+0x78],rax
  209ec2:	movzx  eax,BYTE PTR [rdi+0x59]
  209ec6:	mov    BYTE PTR [rsp+0xf],al
  209eca:	movzx  ebp,BYTE PTR [rdi+0x58]
  209ece:	mov    r9,QWORD PTR [rdi]
  209ed1:	mov    r10,QWORD PTR [rdi+0x18]
  209ed5:	vmovddup xmm5,QWORD PTR [rip+0xffffffffffe35c43]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  209edd:	vxorpd xmm6,xmm3,xmm5
  209ee1:	vmovapd XMMWORD PTR [rsp+0x120],xmm0
  209eea:	vxorpd xmm0,xmm0,xmm5
  209eee:	vmovapd XMMWORD PTR [rsp+0x130],xmm0
  209ef7:	mov    QWORD PTR [rsp+0xf8],r8
  209eff:	shl    r8,0x4
  209f03:	mov    QWORD PTR [rsp+0x100],r10
  209f0b:	shl    r10,0x4
  209f0f:	lea    rax,[r9+0x8]
  209f13:	mov    QWORD PTR [rsp+0xc0],rax
  209f1b:	lea    rax,[r9+0x60]
  209f1f:	mov    QWORD PTR [rsp+0xb8],rax
  209f27:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe35b31]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  209f2f:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe35b91]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  209f37:	xor    esi,esi
  209f39:	xor    edi,edi
  209f3b:	mov    QWORD PTR [rsp+0x50],r9
  209f40:	mov    QWORD PTR [rsp+0xc8],rcx
  209f48:	mov    QWORD PTR [rsp+0x80],rdx
  209f50:	jmp    209f92 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x142>
  209f52:	xor    edx,edx
  209f54:	xor    eax,eax
  209f56:	jmp    20a832 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  209f5b:	nop    DWORD PTR [rax+rax*1+0x0]
  209f60:	mov    QWORD PTR [rsp+0x60],0x0
  209f69:	mov    rsi,QWORD PTR [rsp+0xd8]
  209f71:	add    rsi,QWORD PTR [rsp+0x60]
  209f76:	mov    rdi,r15
  209f79:	mov    rcx,QWORD PTR [rsp+0xc8]
  209f81:	cmp    r15,rcx
  209f84:	mov    rdx,QWORD PTR [rsp+0x80]
  209f8c:	jae    20a847 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9f7>
  209f92:	mov    r9,rcx
  209f95:	sub    r9,rdi
  209f98:	cmp    r9,0x8
  209f9c:	mov    eax,0x8
  209fa1:	cmovae r9,rax
  209fa5:	mov    QWORD PTR [rsp+0x18],r9
  209faa:	lea    r15,[r9+rdi*1]
  209fae:	cmp    r15,QWORD PTR [rsp+0xd0]
  209fb6:	ja     20a8d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa80>
  209fbc:	cmp    r15,QWORD PTR [rsp+0x70]
  209fc1:	ja     20a908 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xab8>
  209fc7:	cmp    r15,QWORD PTR [rsp+0x78]
  209fcc:	seta   al
  209fcf:	test   rdx,rdx
  209fd2:	jne    209fd6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x186>
  209fd4:	xor    eax,eax
  209fd6:	test   al,al
  209fd8:	jne    20a86a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa1a>
  209fde:	test   rdi,rdi
  209fe1:	js     20a93e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  209fe7:	cmp    rdi,r15
  209fea:	ja     20a93e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  209ff0:	mov    QWORD PTR [rsp+0xd8],rsi
  209ff8:	test   r15,r15
  209ffb:	je     209f60 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x110>
  20a001:	mov    rax,QWORD PTR [rsp+0x18]
  20a006:	lea    rdx,[rax-0x1]
  20a00a:	mov    r9,rdx
  20a00d:	shr    r9,1
  20a010:	mov    eax,edx
  20a012:	and    eax,0x1
  20a015:	shl    eax,0xa
  20a018:	mov    rcx,QWORD PTR [rip+0x3401a1]        # 54a1c0 <_DYNAMIC+0x3e8>
  20a01f:	mov    rsi,QWORD PTR [rcx+rax*1+0x400]
  20a027:	mov    r13,QWORD PTR [rcx+rax*1+0x408]
  20a02f:	mov    QWORD PTR [rsp+0xf0],rdx
  20a037:	and    rdx,0xfffffffffffffffe
  20a03b:	mov    QWORD PTR [rsp+0x38],rdx
  20a040:	xor    eax,eax
  20a042:	test   r9,r9
  20a045:	setne  al
  20a048:	lea    rdx,[rax+0x1]
  20a04c:	cmp    r9,rax
  20a04f:	mov    QWORD PTR [rsp+0x88],rax
  20a057:	cmovbe rdx,rax
  20a05b:	lea    ebx,[rdx+rdx*1]
  20a05e:	mov    r11d,r9d
  20a061:	and    r11d,0x3
  20a065:	movabs rax,0x7fffffffffffffff
  20a06f:	lea    r14,[rax-0x3]
  20a073:	and    r14,r9
  20a076:	mov    rax,r9
  20a079:	shl    rax,0x5
  20a07d:	mov    QWORD PTR [rsp+0x40],rax
  20a082:	mov    QWORD PTR [rsp+0x110],rdx
  20a08a:	shl    edx,0x5
  20a08d:	mov    QWORD PTR [rsp+0x118],rdx
  20a095:	mov    rdx,rdi
  20a098:	shl    rdx,0x4
  20a09c:	mov    rax,QWORD PTR [rsp+0xb8]
  20a0a4:	add    rax,rdx
  20a0a7:	mov    QWORD PTR [rsp+0x98],rax
  20a0af:	mov    QWORD PTR [rsp+0xe8],r11
  20a0b7:	shl    r11d,0x5
  20a0bb:	shl    ebx,0x4
  20a0be:	mov    QWORD PTR [rsp+0x90],rbx
  20a0c6:	mov    QWORD PTR [rsp+0x108],rdx
  20a0ce:	mov    rax,QWORD PTR [rsp+0x50]
  20a0d3:	add    rax,rdx
  20a0d6:	mov    QWORD PTR [rsp+0xa0],rax
  20a0de:	mov    ebx,0x8
  20a0e3:	mov    rax,QWORD PTR [rsp+0xc0]
  20a0eb:	mov    QWORD PTR [rsp+0x68],rax
  20a0f0:	mov    QWORD PTR [rsp+0x60],0x0
  20a0f9:	xor    edx,edx
  20a0fb:	mov    QWORD PTR [rsp+0x28],rdi
  20a100:	mov    QWORD PTR [rsp+0xa8],r9
  20a108:	mov    QWORD PTR [rsp+0x48],r13
  20a10d:	mov    QWORD PTR [rsp+0x20],r14
  20a112:	jmp    20a17c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x32c>
  20a114:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20a120:	inc    rdx
  20a123:	mov    rax,QWORD PTR [rsp+0x38]
  20a128:	shl    rax,0x4
  20a12c:	mov    r15,QWORD PTR [rsp+0x58]
  20a131:	add    r15,rax
  20a134:	mov    rax,r15
  20a137:	lea    rcx,[rip+0x2]        # 20a140 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2f0>
  20a13e:	jmp    rsi
  20a140:	vmulpd ymm0,ymm2,ymm0
  20a144:	lea    rcx,[rip+0x3]        # 20a14e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2fe>
  20a14b:	jmp    r13
  20a14e:	add    rbx,0x10
  20a152:	add    QWORD PTR [rsp+0x68],0x10
  20a158:	add    QWORD PTR [rsp+0x98],r10
  20a160:	add    QWORD PTR [rsp+0xa0],r10
  20a168:	mov    r15,r12
  20a16b:	cmp    rdx,r12
  20a16e:	mov    r9,QWORD PTR [rsp+0xa8]
  20a176:	je     209f69 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x119>
  20a17c:	test   rdx,rdx
  20a17f:	mov    r13,rdi
  20a182:	cmove  r13,rdx
  20a186:	shl    r13,0x4
  20a18a:	mov    rax,QWORD PTR [rsp+0x50]
  20a18f:	lea    r14,[rax+r13*1]
  20a193:	mov    r12,rdx
  20a196:	imul   r12,QWORD PTR [rsp+0x100]
  20a19f:	shl    r12,0x4
  20a1a3:	add    r12,rax
  20a1a6:	mov    rax,QWORD PTR [rsp+0x108]
  20a1ae:	lea    rcx,[r12+rax*1]
  20a1b2:	cmp    QWORD PTR [rsp+0x110],r9
  20a1ba:	mov    QWORD PTR [rsp+0x58],rcx
  20a1bf:	jae    20a2e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x490>
  20a1c5:	cmp    r9,QWORD PTR [rsp+0x88]
  20a1cd:	jbe    20a84e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9fe>
  20a1d3:	vmovupd ymm11,YMMWORD PTR [rcx]
  20a1d7:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20a1dc:	mov    rax,QWORD PTR [rsp+0x90]
  20a1e4:	vmovupd ymm13,YMMWORD PTR [rcx+rax*1]
  20a1e9:	mov    r13,QWORD PTR [rsp+0x38]
  20a1ee:	shl    r13,0x4
  20a1f2:	add    r13,rcx
  20a1f5:	mov    rax,r13
  20a1f8:	lea    rcx,[rip+0x2]        # 20a201 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3b1>
  20a1ff:	jmp    rsi
  20a201:	vmovapd ymm2,ymm0
  20a205:	test   rdx,rdx
  20a208:	je     20a3f3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5a3>
  20a20e:	mov    QWORD PTR [rsp+0x10],r12
  20a213:	mov    r15,rdx
  20a216:	mov    r12,QWORD PTR [rsp+0x68]
  20a21b:	mov    rdi,QWORD PTR [rsp+0x30]
  20a220:	mov    r9,QWORD PTR [rsp+0x40]
  20a225:	jmp    20a2c5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x475>
  20a22a:	nop    WORD PTR [rax+rax*1+0x0]
  20a230:	vmovsd xmm1,QWORD PTR [r12]
  20a236:	vxorpd xmm1,xmm1,xmm5
  20a23a:	vmulsd xmm7,xmm0,QWORD PTR [r12-0x8]
  20a241:	vmulsd xmm14,xmm0,xmm1
  20a245:	vmovupd ymm15,YMMWORD PTR [r14]
  20a24a:	vmovupd ymm4,YMMWORD PTR [r14+0x20]
  20a250:	mov    rax,QWORD PTR [rsp+0x118]
  20a258:	vmovupd ymm10,YMMWORD PTR [r14+rax*1]
  20a25e:	lea    rax,[r14+r9*1]
  20a262:	lea    rcx,[rip+0x2]        # 20a26b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x41b>
  20a269:	jmp    rsi
  20a26b:	vshufpd ymm1,ymm15,ymm15,0x5
  20a271:	vbroadcastsd ymm7,xmm7
  20a276:	vbroadcastsd ymm14,xmm14
  20a27b:	vfmaddsub231pd ymm11,ymm14,ymm1
  20a280:	vfmaddsub231pd ymm11,ymm7,ymm15
  20a285:	vshufpd ymm1,ymm4,ymm4,0x5
  20a28a:	vfmaddsub231pd ymm12,ymm14,ymm1
  20a28f:	vfmaddsub231pd ymm12,ymm7,ymm4
  20a294:	vshufpd ymm1,ymm10,ymm10,0x5
  20a29a:	vfmaddsub231pd ymm13,ymm14,ymm1
  20a29f:	vfmaddsub231pd ymm13,ymm7,ymm10
  20a2a4:	vshufpd ymm1,ymm0,ymm0,0x5
  20a2a9:	vfmaddsub231pd ymm2,ymm14,ymm1
  20a2ae:	vfmaddsub231pd ymm2,ymm7,ymm0
  20a2b3:	add    rdi,r8
  20a2b6:	add    r12,r10
  20a2b9:	add    r14,r10
  20a2bc:	dec    r15
  20a2bf:	je     20a3e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x590>
  20a2c5:	vmovapd xmm0,xmm8
  20a2c9:	test   bpl,bpl
  20a2cc:	jne    20a230 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  20a2d2:	vmovsd xmm0,QWORD PTR [rdi]
  20a2d6:	vxorpd xmm0,xmm0,xmm5
  20a2da:	jmp    20a230 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  20a2df:	nop
  20a2e0:	test   r9,r9
  20a2e3:	je     20a42b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5db>
  20a2e9:	vmovupd ymm11,YMMWORD PTR [rcx]
  20a2ed:	cmp    r9,QWORD PTR [rsp+0x88]
  20a2f5:	jbe    20a4cf <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x67f>
  20a2fb:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20a300:	mov    rax,QWORD PTR [rsp+0x38]
  20a305:	shl    rax,0x4
  20a309:	add    rax,rcx
  20a30c:	lea    rcx,[rip+0x2]        # 20a315 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x4c5>
  20a313:	jmp    rsi
  20a315:	vmovapd ymm2,ymm0
  20a319:	test   rdx,rdx
  20a31c:	mov    rcx,QWORD PTR [rsp+0x40]
  20a321:	je     20a5c7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x777>
  20a327:	mov    QWORD PTR [rsp+0xe0],rax
  20a32f:	mov    QWORD PTR [rsp+0x10],r12
  20a334:	lea    rdi,[rcx+r13*1]
  20a338:	mov    r15,rdx
  20a33b:	mov    r12,QWORD PTR [rsp+0x50]
  20a340:	mov    r14,QWORD PTR [rsp+0x30]
  20a345:	jmp    20a3c6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x576>
  20a347:	nop    WORD PTR [rax+rax*1+0x0]
  20a350:	vmovsd xmm1,QWORD PTR [r12+rbx*1]
  20a356:	vxorpd xmm1,xmm1,xmm5
  20a35a:	vmulsd xmm13,xmm0,QWORD PTR [r12+rbx*1-0x8]
  20a361:	vmulsd xmm14,xmm0,xmm1
  20a365:	vmovupd ymm15,YMMWORD PTR [r12+r13*1]
  20a36b:	vmovupd ymm7,YMMWORD PTR [r12+r13*1+0x20]
  20a372:	lea    rax,[r12+rdi*1]
  20a376:	lea    rcx,[rip+0x2]        # 20a37f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x52f>
  20a37d:	jmp    rsi
  20a37f:	vshufpd ymm1,ymm15,ymm15,0x5
  20a385:	vbroadcastsd ymm13,xmm13
  20a38a:	vbroadcastsd ymm14,xmm14
  20a38f:	vfmaddsub231pd ymm11,ymm14,ymm1
  20a394:	vfmaddsub231pd ymm11,ymm13,ymm15
  20a399:	vshufpd ymm1,ymm7,ymm7,0x5
  20a39e:	vfmaddsub231pd ymm12,ymm14,ymm1
  20a3a3:	vfmaddsub231pd ymm12,ymm13,ymm7
  20a3a8:	vshufpd ymm1,ymm0,ymm0,0x5
  20a3ad:	vfmaddsub231pd ymm2,ymm14,ymm1
  20a3b2:	vfmaddsub231pd ymm2,ymm13,ymm0
  20a3b7:	add    r14,r8
  20a3ba:	add    r12,r10
  20a3bd:	dec    r15
  20a3c0:	je     20a5ac <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75c>
  20a3c6:	vmovapd xmm0,xmm8
  20a3ca:	test   bpl,bpl
  20a3cd:	jne    20a350 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  20a3cf:	vmovsd xmm0,QWORD PTR [r14]
  20a3d4:	vxorpd xmm0,xmm0,xmm5
  20a3d8:	jmp    20a350 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  20a3dd:	nop    DWORD PTR [rax]
  20a3e0:	mov    rdi,QWORD PTR [rsp+0x28]
  20a3e5:	mov    rax,QWORD PTR [rsp+0x18]
  20a3ea:	lea    r15,[rax+rdi*1]
  20a3ee:	mov    r12,QWORD PTR [rsp+0x10]
  20a3f3:	mov    rax,QWORD PTR [rsp+0x90]
  20a3fb:	mov    rcx,QWORD PTR [rsp+0x58]
  20a400:	add    rax,rcx
  20a403:	vmovupd YMMWORD PTR [rcx],ymm11
  20a407:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20a40c:	vmovupd YMMWORD PTR [rax],ymm13
  20a410:	mov    rax,r13
  20a413:	vmovapd ymm0,ymm2
  20a417:	mov    r13,QWORD PTR [rsp+0x48]
  20a41c:	lea    rcx,[rip+0x3]        # 20a426 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5d6>
  20a423:	jmp    r13
  20a426:	jmp    20a620 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a42b:	mov    r14,QWORD PTR [rsp+0x38]
  20a430:	shl    r14,0x4
  20a434:	add    r14,rcx
  20a437:	mov    rax,r14
  20a43a:	lea    rcx,[rip+0x2]        # 20a443 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5f3>
  20a441:	jmp    rsi
  20a443:	vmovapd ymm2,ymm0
  20a447:	test   rdx,rdx
  20a44a:	mov    rax,QWORD PTR [rsp+0x40]
  20a44f:	je     20a594 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x744>
  20a455:	mov    QWORD PTR [rsp+0x10],r12
  20a45a:	add    r13,rax
  20a45d:	mov    rdi,rdx
  20a460:	mov    r15,QWORD PTR [rsp+0x50]
  20a465:	mov    r12,QWORD PTR [rsp+0x30]
  20a46a:	jmp    20a4ba <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x66a>
  20a46c:	nop    DWORD PTR [rax+0x0]
  20a470:	vmovsd xmm1,QWORD PTR [r15+rbx*1]
  20a476:	vxorpd xmm1,xmm1,xmm5
  20a47a:	vmulsd xmm11,xmm0,QWORD PTR [r15+rbx*1-0x8]
  20a481:	vmulsd xmm12,xmm0,xmm1
  20a485:	lea    rax,[r15+r13*1]
  20a489:	lea    rcx,[rip+0x2]        # 20a492 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x642>
  20a490:	jmp    rsi
  20a492:	vshufpd ymm1,ymm0,ymm0,0x5
  20a497:	vbroadcastsd ymm11,xmm11
  20a49c:	vbroadcastsd ymm12,xmm12
  20a4a1:	vfmaddsub231pd ymm2,ymm1,ymm12
  20a4a6:	vfmaddsub231pd ymm2,ymm0,ymm11
  20a4ab:	add    r12,r8
  20a4ae:	add    r15,r10
  20a4b1:	dec    rdi
  20a4b4:	je     20a581 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x731>
  20a4ba:	vmovapd xmm0,xmm8
  20a4be:	test   bpl,bpl
  20a4c1:	jne    20a470 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  20a4c3:	vmovsd xmm0,QWORD PTR [r12]
  20a4c9:	vxorpd xmm0,xmm0,xmm5
  20a4cd:	jmp    20a470 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  20a4cf:	mov    r13,QWORD PTR [rsp+0x38]
  20a4d4:	shl    r13,0x4
  20a4d8:	add    r13,rcx
  20a4db:	mov    rax,r13
  20a4de:	lea    rcx,[rip+0x2]        # 20a4e7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x697>
  20a4e5:	jmp    rsi
  20a4e7:	vmovapd ymm2,ymm0
  20a4eb:	test   rdx,rdx
  20a4ee:	mov    r9,QWORD PTR [rsp+0x40]
  20a4f3:	je     20a5fd <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7ad>
  20a4f9:	mov    QWORD PTR [rsp+0x10],r12
  20a4fe:	mov    rdi,rdx
  20a501:	mov    r15,QWORD PTR [rsp+0x68]
  20a506:	mov    r12,QWORD PTR [rsp+0x30]
  20a50b:	jmp    20a56c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x71c>
  20a50d:	nop    DWORD PTR [rax]
  20a510:	vmovsd xmm1,QWORD PTR [r15]
  20a515:	vxorpd xmm1,xmm1,xmm5
  20a519:	vmulsd xmm12,xmm0,QWORD PTR [r15-0x8]
  20a51f:	vmulsd xmm13,xmm0,xmm1
  20a523:	vmovupd ymm14,YMMWORD PTR [r14]
  20a528:	lea    rax,[r14+r9*1]
  20a52c:	lea    rcx,[rip+0x2]        # 20a535 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6e5>
  20a533:	jmp    rsi
  20a535:	vshufpd ymm1,ymm14,ymm14,0x5
  20a53b:	vbroadcastsd ymm12,xmm12
  20a540:	vbroadcastsd ymm13,xmm13
  20a545:	vfmaddsub231pd ymm11,ymm13,ymm1
  20a54a:	vfmaddsub231pd ymm11,ymm12,ymm14
  20a54f:	vshufpd ymm1,ymm0,ymm0,0x5
  20a554:	vfmaddsub231pd ymm2,ymm13,ymm1
  20a559:	vfmaddsub231pd ymm2,ymm12,ymm0
  20a55e:	add    r12,r8
  20a561:	add    r15,r10
  20a564:	add    r14,r10
  20a567:	dec    rdi
  20a56a:	je     20a5ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x79a>
  20a56c:	vmovapd xmm0,xmm8
  20a570:	test   bpl,bpl
  20a573:	jne    20a510 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  20a575:	vmovsd xmm0,QWORD PTR [r12]
  20a57b:	vxorpd xmm0,xmm0,xmm5
  20a57f:	jmp    20a510 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  20a581:	mov    rdi,QWORD PTR [rsp+0x28]
  20a586:	mov    rax,QWORD PTR [rsp+0x18]
  20a58b:	lea    r15,[rax+rdi*1]
  20a58f:	mov    r12,QWORD PTR [rsp+0x10]
  20a594:	mov    rax,r14
  20a597:	vmovapd ymm0,ymm2
  20a59b:	mov    r13,QWORD PTR [rsp+0x48]
  20a5a0:	lea    rcx,[rip+0x3]        # 20a5aa <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75a>
  20a5a7:	jmp    r13
  20a5aa:	jmp    20a620 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a5ac:	mov    rdi,QWORD PTR [rsp+0x28]
  20a5b1:	mov    rax,QWORD PTR [rsp+0x18]
  20a5b6:	lea    r15,[rax+rdi*1]
  20a5ba:	mov    r12,QWORD PTR [rsp+0x10]
  20a5bf:	mov    rax,QWORD PTR [rsp+0xe0]
  20a5c7:	mov    rcx,QWORD PTR [rsp+0x58]
  20a5cc:	vmovupd YMMWORD PTR [rcx],ymm11
  20a5d0:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20a5d5:	vmovapd ymm0,ymm2
  20a5d9:	mov    r13,QWORD PTR [rsp+0x48]
  20a5de:	lea    rcx,[rip+0x3]        # 20a5e8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x798>
  20a5e5:	jmp    r13
  20a5e8:	jmp    20a620 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20a5ea:	mov    rdi,QWORD PTR [rsp+0x28]
  20a5ef:	mov    rax,QWORD PTR [rsp+0x18]
  20a5f4:	lea    r15,[rax+rdi*1]
  20a5f8:	mov    r12,QWORD PTR [rsp+0x10]
  20a5fd:	mov    rax,QWORD PTR [rsp+0x58]
  20a602:	vmovupd YMMWORD PTR [rax],ymm11
  20a606:	mov    rax,r13
  20a609:	vmovapd ymm0,ymm2
  20a60d:	mov    r13,QWORD PTR [rsp+0x48]
  20a612:	lea    rcx,[rip+0x3]        # 20a61c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7cc>
  20a619:	jmp    r13
  20a61c:	nop    DWORD PTR [rax+0x0]
  20a620:	mov    r14,QWORD PTR [rsp+0x20]
  20a625:	mov    rcx,rdx
  20a628:	imul   rcx,QWORD PTR [rsp+0xf8]
  20a631:	shl    rcx,0x4
  20a635:	add    rcx,QWORD PTR [rsp+0x30]
  20a63a:	mov    rax,rdx
  20a63d:	sub    rax,rdi
  20a640:	jae    20a650 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x800>
  20a642:	vmovsd xmm0,QWORD PTR [rcx]
  20a646:	jmp    20a6e5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x895>
  20a64b:	nop    DWORD PTR [rax+rax*1+0x0]
  20a650:	cmp    rax,QWORD PTR [rsp+0x18]
  20a655:	jae    20a884 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa34>
  20a65b:	mov    rax,rdx
  20a65e:	shl    rax,0x4
  20a662:	vmovsd xmm0,QWORD PTR [r12+rax*1]
  20a668:	cmp    BYTE PTR [rsp+0xf],0x0
  20a66d:	je     20a68c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x83c>
  20a66f:	test   bpl,bpl
  20a672:	je     20a788 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x938>
  20a678:	vucomisd xmm3,xmm0
  20a67c:	jb     20a691 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x841>
  20a67e:	inc    QWORD PTR [rsp+0x60]
  20a683:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20a68c:	test   bpl,bpl
  20a68f:	je     20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a691:	vxorpd xmm1,xmm1,xmm1
  20a695:	vucomisd xmm0,xmm1
  20a699:	jbe    20a821 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9d1>
  20a69f:	vsqrtsd xmm0,xmm0,xmm0
  20a6a3:	vmovsd QWORD PTR [rcx],xmm0
  20a6a7:	vmovq  rax,xmm0
  20a6ac:	mov    QWORD PTR [rcx+0x8],0x0
  20a6b4:	mov    cl,0x3f
  20a6b6:	bzhi   rax,rax,rcx
  20a6bb:	movabs rcx,0x7ff0000000000000
  20a6c5:	cmp    rax,rcx
  20a6c8:	setg   cl
  20a6cb:	sete   dil
  20a6cf:	test   rax,rax
  20a6d2:	sete   al
  20a6d5:	or     al,dil
  20a6d8:	or     al,cl
  20a6da:	mov    rdi,QWORD PTR [rsp+0x28]
  20a6df:	jne    20a82d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9dd>
  20a6e5:	mov    r12,r15
  20a6e8:	vdivsd xmm0,xmm9,xmm0
  20a6ec:	vbroadcastsd ymm2,xmm0
  20a6f1:	cmp    QWORD PTR [rsp+0xa8],0x0
  20a6fa:	je     20a120 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a700:	cmp    QWORD PTR [rsp+0xf0],0x8
  20a709:	jae    20a710 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8c0>
  20a70b:	xor    eax,eax
  20a70d:	jmp    20a762 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x912>
  20a70f:	nop
  20a710:	mov    rcx,QWORD PTR [rsp+0x98]
  20a718:	xor    eax,eax
  20a71a:	nop    WORD PTR [rax+rax*1+0x0]
  20a720:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  20a725:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  20a72a:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  20a72f:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  20a734:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  20a739:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  20a73e:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  20a742:	add    rax,0x4
  20a746:	vmovupd YMMWORD PTR [rcx],ymm0
  20a74a:	sub    rcx,0xffffffffffffff80
  20a74e:	cmp    r14,rax
  20a751:	jne    20a720 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8d0>
  20a753:	cmp    QWORD PTR [rsp+0xe8],0x0
  20a75c:	je     20a120 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a762:	shl    rax,0x5
  20a766:	add    rax,QWORD PTR [rsp+0xa0]
  20a76e:	xor    ecx,ecx
  20a770:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  20a775:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20a77a:	add    rcx,0x20
  20a77e:	cmp    r11,rcx
  20a781:	jne    20a770 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x920>
  20a783:	jmp    20a120 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  20a788:	mov    rax,QWORD PTR [rsp+0x80]
  20a790:	test   rax,rax
  20a793:	je     20a7cc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x97c>
  20a795:	movzx  r14d,BYTE PTR [rax+rdx*1]
  20a79a:	vucomisd xmm3,xmm0
  20a79e:	setae  al
  20a7a1:	vucomisd xmm0,xmm6
  20a7a5:	setae  dil
  20a7a9:	cmp    r14d,0xff
  20a7b0:	je     20a804 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9b4>
  20a7b2:	cmp    r14d,0x1
  20a7b6:	mov    r14,QWORD PTR [rsp+0x20]
  20a7bb:	jne    20a7db <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x98b>
  20a7bd:	vucomisd xmm3,xmm0
  20a7c1:	jae    20a67e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x82e>
  20a7c7:	jmp    20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7cc:	vucomisd xmm3,xmm0
  20a7d0:	setae  al
  20a7d3:	vucomisd xmm0,xmm6
  20a7d7:	setae  dil
  20a7db:	test   dil,dil
  20a7de:	je     20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7e4:	test   al,al
  20a7e6:	je     20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a7ec:	vxorpd xmm1,xmm1,xmm1
  20a7f0:	vucomisd xmm1,xmm0
  20a7f4:	ja     20a813 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9c3>
  20a7f6:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20a7ff:	jmp    20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a804:	vucomisd xmm0,xmm6
  20a808:	mov    r14,QWORD PTR [rsp+0x20]
  20a80d:	jb     20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a813:	vmovapd xmm0,XMMWORD PTR [rsp+0x130]
  20a81c:	jmp    20a6a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20a821:	vmovsd QWORD PTR [rcx],xmm0
  20a825:	mov    QWORD PTR [rcx+0x8],0x0
  20a82d:	mov    eax,0x1
  20a832:	add    rsp,0x148
  20a839:	pop    rbx
  20a83a:	pop    r12
  20a83c:	pop    r13
  20a83e:	pop    r14
  20a840:	pop    r15
  20a842:	pop    rbp
  20a843:	vzeroupper
  20a846:	ret
  20a847:	mov    rdx,rsi
  20a84a:	xor    eax,eax
  20a84c:	jmp    20a832 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  20a84e:	lea    rdi,[rip+0xffffffffffe3c793]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  20a855:	lea    rdx,[rip+0x3315a4]        # 53be00 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xd8>
  20a85c:	mov    esi,0x28
  20a861:	vzeroupper
  20a864:	call   QWORD PTR [rip+0x33f9a6]        # 54a210 <_DYNAMIC+0x438>
  20a86a:	lea    rcx,[rip+0x3316af]        # 53bf20 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1f8>
  20a871:	xor    edi,edi
  20a873:	mov    rsi,r15
  20a876:	mov    rdx,QWORD PTR [rsp+0x78]
  20a87b:	vzeroupper
  20a87e:	call   QWORD PTR [rip+0x33f854]        # 54a0d8 <_DYNAMIC+0x300>
  20a884:	lea    r10,[rip+0x33158d]        # 53be18 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xf0>
  20a88b:	lea    r11,[rip+0xffffffffffe3513e]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a892:	lea    rbx,[rip+0x331057]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  20a899:	lea    r14,[rip+0x331a60]        # 53c300 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270>
  20a8a0:	mov    r8d,0x1
  20a8a6:	mov    r9d,0x1
  20a8ac:	mov    rdi,rax
  20a8af:	mov    rsi,rax
  20a8b2:	mov    rdx,QWORD PTR [rsp+0x18]
  20a8b7:	movabs rcx,0x7fffffffffffffff
  20a8c1:	push   r10
  20a8c3:	push   r11
  20a8c5:	push   rbx
  20a8c6:	push   r14
  20a8c8:	vzeroupper
  20a8cb:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  20a8d0:	lea    rax,[rip+0x3314f9]        # 53bdd0 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xa8>
  20a8d7:	lea    r10,[rip+0xffffffffffe350f2]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a8de:	lea    r11,[rip+0x330fb3]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20a8e5:	lea    rbx,[rip+0x33121c]        # 53bb08 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x218>
  20a8ec:	mov    r8d,0x1
  20a8f2:	mov    r9d,0x1
  20a8f8:	mov    rdi,r15
  20a8fb:	mov    rsi,r15
  20a8fe:	mov    rdx,QWORD PTR [rsp+0xb0]
  20a906:	jmp    20a976 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs3THqHrzqLL7_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xb26>
  20a908:	sub    rsp,0x8
  20a90c:	lea    rax,[rip+0x331155]        # 53ba68 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x178>
  20a913:	lea    rcx,[rip+0x331106]        # 53ba20 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x130>
  20a91a:	lea    r8,[rip+0x330f5f]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  20a921:	lea    r9,[rip+0xffffffffffe350a8]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a928:	mov    edx,0x1
  20a92d:	mov    rdi,r15
  20a930:	mov    rsi,QWORD PTR [rsp+0x78]
  20a935:	push   rax
  20a936:	vzeroupper
  20a939:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  20a93e:	lea    rax,[rip+0x3314a3]        # 53bde8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xc0>
  20a945:	lea    r10,[rip+0xffffffffffe35084]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20a94c:	lea    r11,[rip+0x330f45]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20a953:	lea    rbx,[rip+0x331a26]        # 53c380 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x80>
  20a95a:	mov    r8d,0x1
  20a960:	mov    r9d,0x1
  20a966:	mov    rsi,rdi
  20a969:	mov    rdx,r15
  20a96c:	movabs rcx,0x7fffffffffffffff
  20a976:	push   rax
  20a977:	push   r10
  20a979:	push   r11
  20a97b:	push   rbx
  20a97c:	vzeroupper
  20a97f:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
