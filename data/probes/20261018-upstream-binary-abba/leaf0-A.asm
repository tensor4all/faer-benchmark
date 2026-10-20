
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/2240b076a030-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002088e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench>:
  2088e0:	push   rbp
  2088e1:	push   r15
  2088e3:	push   r14
  2088e5:	push   r13
  2088e7:	push   r12
  2088e9:	push   rbx
  2088ea:	sub    rsp,0x148
  2088f1:	mov    rax,QWORD PTR [rdi+0x8]
  2088f5:	test   rax,rax
  2088f8:	je     2089e2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  2088fe:	mov    rcx,QWORD PTR [rdi+0x10]
  208902:	cmp    rax,rcx
  208905:	mov    rdx,rcx
  208908:	cmovb  rdx,rax
  20890c:	mov    QWORD PTR [rsp+0xd0],rdx
  208914:	test   rcx,rcx
  208917:	je     2089e2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x102>
  20891d:	mov    QWORD PTR [rsp+0xb0],rax
  208925:	mov    rax,QWORD PTR [rdi+0x40]
  208929:	mov    QWORD PTR [rsp+0x30],rax
  20892e:	mov    rax,QWORD PTR [rdi+0x48]
  208932:	mov    QWORD PTR [rsp+0x70],rax
  208937:	mov    r8,QWORD PTR [rdi+0x50]
  20893b:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  208940:	vmovsd xmm0,QWORD PTR [rdi+0x38]
  208945:	mov    rdx,QWORD PTR [rdi+0x20]
  208949:	mov    rax,QWORD PTR [rdi+0x28]
  20894d:	mov    QWORD PTR [rsp+0x78],rax
  208952:	movzx  eax,BYTE PTR [rdi+0x59]
  208956:	mov    BYTE PTR [rsp+0xf],al
  20895a:	movzx  ebp,BYTE PTR [rdi+0x58]
  20895e:	mov    r9,QWORD PTR [rdi]
  208961:	mov    r10,QWORD PTR [rdi+0x18]
  208965:	vmovddup xmm5,QWORD PTR [rip+0xffffffffffe371b3]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20896d:	vxorpd xmm6,xmm3,xmm5
  208971:	vmovapd XMMWORD PTR [rsp+0x120],xmm0
  20897a:	vxorpd xmm0,xmm0,xmm5
  20897e:	vmovapd XMMWORD PTR [rsp+0x130],xmm0
  208987:	mov    QWORD PTR [rsp+0xf8],r8
  20898f:	shl    r8,0x4
  208993:	mov    QWORD PTR [rsp+0x100],r10
  20899b:	shl    r10,0x4
  20899f:	lea    rax,[r9+0x8]
  2089a3:	mov    QWORD PTR [rsp+0xc0],rax
  2089ab:	lea    rax,[r9+0x60]
  2089af:	mov    QWORD PTR [rsp+0xb8],rax
  2089b7:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe370a1]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  2089bf:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe37101]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  2089c7:	xor    esi,esi
  2089c9:	xor    edi,edi
  2089cb:	mov    QWORD PTR [rsp+0x50],r9
  2089d0:	mov    QWORD PTR [rsp+0xc8],rcx
  2089d8:	mov    QWORD PTR [rsp+0x80],rdx
  2089e0:	jmp    208a22 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x142>
  2089e2:	xor    edx,edx
  2089e4:	xor    eax,eax
  2089e6:	jmp    2092c2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  2089eb:	nop    DWORD PTR [rax+rax*1+0x0]
  2089f0:	mov    QWORD PTR [rsp+0x60],0x0
  2089f9:	mov    rsi,QWORD PTR [rsp+0xd8]
  208a01:	add    rsi,QWORD PTR [rsp+0x60]
  208a06:	mov    rdi,r15
  208a09:	mov    rcx,QWORD PTR [rsp+0xc8]
  208a11:	cmp    r15,rcx
  208a14:	mov    rdx,QWORD PTR [rsp+0x80]
  208a1c:	jae    2092d7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9f7>
  208a22:	mov    r9,rcx
  208a25:	sub    r9,rdi
  208a28:	cmp    r9,0x8
  208a2c:	mov    eax,0x8
  208a31:	cmovae r9,rax
  208a35:	mov    QWORD PTR [rsp+0x18],r9
  208a3a:	lea    r15,[r9+rdi*1]
  208a3e:	cmp    r15,QWORD PTR [rsp+0xd0]
  208a46:	ja     209360 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa80>
  208a4c:	cmp    r15,QWORD PTR [rsp+0x70]
  208a51:	ja     209398 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xab8>
  208a57:	cmp    r15,QWORD PTR [rsp+0x78]
  208a5c:	seta   al
  208a5f:	test   rdx,rdx
  208a62:	jne    208a66 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x186>
  208a64:	xor    eax,eax
  208a66:	test   al,al
  208a68:	jne    2092fa <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa1a>
  208a6e:	test   rdi,rdi
  208a71:	js     2093ce <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  208a77:	cmp    rdi,r15
  208a7a:	ja     2093ce <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xaee>
  208a80:	mov    QWORD PTR [rsp+0xd8],rsi
  208a88:	test   r15,r15
  208a8b:	je     2089f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x110>
  208a91:	mov    rax,QWORD PTR [rsp+0x18]
  208a96:	lea    rdx,[rax-0x1]
  208a9a:	mov    r9,rdx
  208a9d:	shr    r9,1
  208aa0:	mov    eax,edx
  208aa2:	and    eax,0x1
  208aa5:	shl    eax,0xa
  208aa8:	mov    rcx,QWORD PTR [rip+0x341711]        # 54a1c0 <_DYNAMIC+0x3e8>
  208aaf:	mov    rsi,QWORD PTR [rcx+rax*1+0x400]
  208ab7:	mov    r13,QWORD PTR [rcx+rax*1+0x408]
  208abf:	mov    QWORD PTR [rsp+0xf0],rdx
  208ac7:	and    rdx,0xfffffffffffffffe
  208acb:	mov    QWORD PTR [rsp+0x38],rdx
  208ad0:	xor    eax,eax
  208ad2:	test   r9,r9
  208ad5:	setne  al
  208ad8:	lea    rdx,[rax+0x1]
  208adc:	cmp    r9,rax
  208adf:	mov    QWORD PTR [rsp+0x88],rax
  208ae7:	cmovbe rdx,rax
  208aeb:	lea    ebx,[rdx+rdx*1]
  208aee:	mov    r11d,r9d
  208af1:	and    r11d,0x3
  208af5:	movabs rax,0x7fffffffffffffff
  208aff:	lea    r14,[rax-0x3]
  208b03:	and    r14,r9
  208b06:	mov    rax,r9
  208b09:	shl    rax,0x5
  208b0d:	mov    QWORD PTR [rsp+0x40],rax
  208b12:	mov    QWORD PTR [rsp+0x110],rdx
  208b1a:	shl    edx,0x5
  208b1d:	mov    QWORD PTR [rsp+0x118],rdx
  208b25:	mov    rdx,rdi
  208b28:	shl    rdx,0x4
  208b2c:	mov    rax,QWORD PTR [rsp+0xb8]
  208b34:	add    rax,rdx
  208b37:	mov    QWORD PTR [rsp+0x98],rax
  208b3f:	mov    QWORD PTR [rsp+0xe8],r11
  208b47:	shl    r11d,0x5
  208b4b:	shl    ebx,0x4
  208b4e:	mov    QWORD PTR [rsp+0x90],rbx
  208b56:	mov    QWORD PTR [rsp+0x108],rdx
  208b5e:	mov    rax,QWORD PTR [rsp+0x50]
  208b63:	add    rax,rdx
  208b66:	mov    QWORD PTR [rsp+0xa0],rax
  208b6e:	mov    ebx,0x8
  208b73:	mov    rax,QWORD PTR [rsp+0xc0]
  208b7b:	mov    QWORD PTR [rsp+0x68],rax
  208b80:	mov    QWORD PTR [rsp+0x60],0x0
  208b89:	xor    edx,edx
  208b8b:	mov    QWORD PTR [rsp+0x28],rdi
  208b90:	mov    QWORD PTR [rsp+0xa8],r9
  208b98:	mov    QWORD PTR [rsp+0x48],r13
  208b9d:	mov    QWORD PTR [rsp+0x20],r14
  208ba2:	jmp    208c0c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x32c>
  208ba4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  208bb0:	inc    rdx
  208bb3:	mov    rax,QWORD PTR [rsp+0x38]
  208bb8:	shl    rax,0x4
  208bbc:	mov    r15,QWORD PTR [rsp+0x58]
  208bc1:	add    r15,rax
  208bc4:	mov    rax,r15
  208bc7:	lea    rcx,[rip+0x2]        # 208bd0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2f0>
  208bce:	jmp    rsi
  208bd0:	vmulpd ymm0,ymm2,ymm0
  208bd4:	lea    rcx,[rip+0x3]        # 208bde <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2fe>
  208bdb:	jmp    r13
  208bde:	add    rbx,0x10
  208be2:	add    QWORD PTR [rsp+0x68],0x10
  208be8:	add    QWORD PTR [rsp+0x98],r10
  208bf0:	add    QWORD PTR [rsp+0xa0],r10
  208bf8:	mov    r15,r12
  208bfb:	cmp    rdx,r12
  208bfe:	mov    r9,QWORD PTR [rsp+0xa8]
  208c06:	je     2089f9 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x119>
  208c0c:	test   rdx,rdx
  208c0f:	mov    r13,rdi
  208c12:	cmove  r13,rdx
  208c16:	shl    r13,0x4
  208c1a:	mov    rax,QWORD PTR [rsp+0x50]
  208c1f:	lea    r14,[rax+r13*1]
  208c23:	mov    r12,rdx
  208c26:	imul   r12,QWORD PTR [rsp+0x100]
  208c2f:	shl    r12,0x4
  208c33:	add    r12,rax
  208c36:	mov    rax,QWORD PTR [rsp+0x108]
  208c3e:	lea    rcx,[r12+rax*1]
  208c42:	cmp    QWORD PTR [rsp+0x110],r9
  208c4a:	mov    QWORD PTR [rsp+0x58],rcx
  208c4f:	jae    208d70 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x490>
  208c55:	cmp    r9,QWORD PTR [rsp+0x88]
  208c5d:	jbe    2092de <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9fe>
  208c63:	vmovupd ymm11,YMMWORD PTR [rcx]
  208c67:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  208c6c:	mov    rax,QWORD PTR [rsp+0x90]
  208c74:	vmovupd ymm13,YMMWORD PTR [rcx+rax*1]
  208c79:	mov    r13,QWORD PTR [rsp+0x38]
  208c7e:	shl    r13,0x4
  208c82:	add    r13,rcx
  208c85:	mov    rax,r13
  208c88:	lea    rcx,[rip+0x2]        # 208c91 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3b1>
  208c8f:	jmp    rsi
  208c91:	vmovapd ymm2,ymm0
  208c95:	test   rdx,rdx
  208c98:	je     208e83 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5a3>
  208c9e:	mov    QWORD PTR [rsp+0x10],r12
  208ca3:	mov    r15,rdx
  208ca6:	mov    r12,QWORD PTR [rsp+0x68]
  208cab:	mov    rdi,QWORD PTR [rsp+0x30]
  208cb0:	mov    r9,QWORD PTR [rsp+0x40]
  208cb5:	jmp    208d55 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x475>
  208cba:	nop    WORD PTR [rax+rax*1+0x0]
  208cc0:	vmovsd xmm1,QWORD PTR [r12]
  208cc6:	vxorpd xmm1,xmm1,xmm5
  208cca:	vmulsd xmm7,xmm0,QWORD PTR [r12-0x8]
  208cd1:	vmulsd xmm14,xmm0,xmm1
  208cd5:	vmovupd ymm15,YMMWORD PTR [r14]
  208cda:	vmovupd ymm4,YMMWORD PTR [r14+0x20]
  208ce0:	mov    rax,QWORD PTR [rsp+0x118]
  208ce8:	vmovupd ymm10,YMMWORD PTR [r14+rax*1]
  208cee:	lea    rax,[r14+r9*1]
  208cf2:	lea    rcx,[rip+0x2]        # 208cfb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x41b>
  208cf9:	jmp    rsi
  208cfb:	vshufpd ymm1,ymm15,ymm15,0x5
  208d01:	vbroadcastsd ymm7,xmm7
  208d06:	vbroadcastsd ymm14,xmm14
  208d0b:	vfmaddsub231pd ymm11,ymm14,ymm1
  208d10:	vfmaddsub231pd ymm11,ymm7,ymm15
  208d15:	vshufpd ymm1,ymm4,ymm4,0x5
  208d1a:	vfmaddsub231pd ymm12,ymm14,ymm1
  208d1f:	vfmaddsub231pd ymm12,ymm7,ymm4
  208d24:	vshufpd ymm1,ymm10,ymm10,0x5
  208d2a:	vfmaddsub231pd ymm13,ymm14,ymm1
  208d2f:	vfmaddsub231pd ymm13,ymm7,ymm10
  208d34:	vshufpd ymm1,ymm0,ymm0,0x5
  208d39:	vfmaddsub231pd ymm2,ymm14,ymm1
  208d3e:	vfmaddsub231pd ymm2,ymm7,ymm0
  208d43:	add    rdi,r8
  208d46:	add    r12,r10
  208d49:	add    r14,r10
  208d4c:	dec    r15
  208d4f:	je     208e70 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x590>
  208d55:	vmovapd xmm0,xmm8
  208d59:	test   bpl,bpl
  208d5c:	jne    208cc0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  208d62:	vmovsd xmm0,QWORD PTR [rdi]
  208d66:	vxorpd xmm0,xmm0,xmm5
  208d6a:	jmp    208cc0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x3e0>
  208d6f:	nop
  208d70:	test   r9,r9
  208d73:	je     208ebb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5db>
  208d79:	vmovupd ymm11,YMMWORD PTR [rcx]
  208d7d:	cmp    r9,QWORD PTR [rsp+0x88]
  208d85:	jbe    208f5f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x67f>
  208d8b:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  208d90:	mov    rax,QWORD PTR [rsp+0x38]
  208d95:	shl    rax,0x4
  208d99:	add    rax,rcx
  208d9c:	lea    rcx,[rip+0x2]        # 208da5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x4c5>
  208da3:	jmp    rsi
  208da5:	vmovapd ymm2,ymm0
  208da9:	test   rdx,rdx
  208dac:	mov    rcx,QWORD PTR [rsp+0x40]
  208db1:	je     209057 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x777>
  208db7:	mov    QWORD PTR [rsp+0xe0],rax
  208dbf:	mov    QWORD PTR [rsp+0x10],r12
  208dc4:	lea    rdi,[rcx+r13*1]
  208dc8:	mov    r15,rdx
  208dcb:	mov    r12,QWORD PTR [rsp+0x50]
  208dd0:	mov    r14,QWORD PTR [rsp+0x30]
  208dd5:	jmp    208e56 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x576>
  208dd7:	nop    WORD PTR [rax+rax*1+0x0]
  208de0:	vmovsd xmm1,QWORD PTR [r12+rbx*1]
  208de6:	vxorpd xmm1,xmm1,xmm5
  208dea:	vmulsd xmm13,xmm0,QWORD PTR [r12+rbx*1-0x8]
  208df1:	vmulsd xmm14,xmm0,xmm1
  208df5:	vmovupd ymm15,YMMWORD PTR [r12+r13*1]
  208dfb:	vmovupd ymm7,YMMWORD PTR [r12+r13*1+0x20]
  208e02:	lea    rax,[r12+rdi*1]
  208e06:	lea    rcx,[rip+0x2]        # 208e0f <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x52f>
  208e0d:	jmp    rsi
  208e0f:	vshufpd ymm1,ymm15,ymm15,0x5
  208e15:	vbroadcastsd ymm13,xmm13
  208e1a:	vbroadcastsd ymm14,xmm14
  208e1f:	vfmaddsub231pd ymm11,ymm14,ymm1
  208e24:	vfmaddsub231pd ymm11,ymm13,ymm15
  208e29:	vshufpd ymm1,ymm7,ymm7,0x5
  208e2e:	vfmaddsub231pd ymm12,ymm14,ymm1
  208e33:	vfmaddsub231pd ymm12,ymm13,ymm7
  208e38:	vshufpd ymm1,ymm0,ymm0,0x5
  208e3d:	vfmaddsub231pd ymm2,ymm14,ymm1
  208e42:	vfmaddsub231pd ymm2,ymm13,ymm0
  208e47:	add    r14,r8
  208e4a:	add    r12,r10
  208e4d:	dec    r15
  208e50:	je     20903c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75c>
  208e56:	vmovapd xmm0,xmm8
  208e5a:	test   bpl,bpl
  208e5d:	jne    208de0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  208e5f:	vmovsd xmm0,QWORD PTR [r14]
  208e64:	vxorpd xmm0,xmm0,xmm5
  208e68:	jmp    208de0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x500>
  208e6d:	nop    DWORD PTR [rax]
  208e70:	mov    rdi,QWORD PTR [rsp+0x28]
  208e75:	mov    rax,QWORD PTR [rsp+0x18]
  208e7a:	lea    r15,[rax+rdi*1]
  208e7e:	mov    r12,QWORD PTR [rsp+0x10]
  208e83:	mov    rax,QWORD PTR [rsp+0x90]
  208e8b:	mov    rcx,QWORD PTR [rsp+0x58]
  208e90:	add    rax,rcx
  208e93:	vmovupd YMMWORD PTR [rcx],ymm11
  208e97:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  208e9c:	vmovupd YMMWORD PTR [rax],ymm13
  208ea0:	mov    rax,r13
  208ea3:	vmovapd ymm0,ymm2
  208ea7:	mov    r13,QWORD PTR [rsp+0x48]
  208eac:	lea    rcx,[rip+0x3]        # 208eb6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5d6>
  208eb3:	jmp    r13
  208eb6:	jmp    2090b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  208ebb:	mov    r14,QWORD PTR [rsp+0x38]
  208ec0:	shl    r14,0x4
  208ec4:	add    r14,rcx
  208ec7:	mov    rax,r14
  208eca:	lea    rcx,[rip+0x2]        # 208ed3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x5f3>
  208ed1:	jmp    rsi
  208ed3:	vmovapd ymm2,ymm0
  208ed7:	test   rdx,rdx
  208eda:	mov    rax,QWORD PTR [rsp+0x40]
  208edf:	je     209024 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x744>
  208ee5:	mov    QWORD PTR [rsp+0x10],r12
  208eea:	add    r13,rax
  208eed:	mov    rdi,rdx
  208ef0:	mov    r15,QWORD PTR [rsp+0x50]
  208ef5:	mov    r12,QWORD PTR [rsp+0x30]
  208efa:	jmp    208f4a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x66a>
  208efc:	nop    DWORD PTR [rax+0x0]
  208f00:	vmovsd xmm1,QWORD PTR [r15+rbx*1]
  208f06:	vxorpd xmm1,xmm1,xmm5
  208f0a:	vmulsd xmm11,xmm0,QWORD PTR [r15+rbx*1-0x8]
  208f11:	vmulsd xmm12,xmm0,xmm1
  208f15:	lea    rax,[r15+r13*1]
  208f19:	lea    rcx,[rip+0x2]        # 208f22 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x642>
  208f20:	jmp    rsi
  208f22:	vshufpd ymm1,ymm0,ymm0,0x5
  208f27:	vbroadcastsd ymm11,xmm11
  208f2c:	vbroadcastsd ymm12,xmm12
  208f31:	vfmaddsub231pd ymm2,ymm1,ymm12
  208f36:	vfmaddsub231pd ymm2,ymm0,ymm11
  208f3b:	add    r12,r8
  208f3e:	add    r15,r10
  208f41:	dec    rdi
  208f44:	je     209011 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x731>
  208f4a:	vmovapd xmm0,xmm8
  208f4e:	test   bpl,bpl
  208f51:	jne    208f00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  208f53:	vmovsd xmm0,QWORD PTR [r12]
  208f59:	vxorpd xmm0,xmm0,xmm5
  208f5d:	jmp    208f00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x620>
  208f5f:	mov    r13,QWORD PTR [rsp+0x38]
  208f64:	shl    r13,0x4
  208f68:	add    r13,rcx
  208f6b:	mov    rax,r13
  208f6e:	lea    rcx,[rip+0x2]        # 208f77 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x697>
  208f75:	jmp    rsi
  208f77:	vmovapd ymm2,ymm0
  208f7b:	test   rdx,rdx
  208f7e:	mov    r9,QWORD PTR [rsp+0x40]
  208f83:	je     20908d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7ad>
  208f89:	mov    QWORD PTR [rsp+0x10],r12
  208f8e:	mov    rdi,rdx
  208f91:	mov    r15,QWORD PTR [rsp+0x68]
  208f96:	mov    r12,QWORD PTR [rsp+0x30]
  208f9b:	jmp    208ffc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x71c>
  208f9d:	nop    DWORD PTR [rax]
  208fa0:	vmovsd xmm1,QWORD PTR [r15]
  208fa5:	vxorpd xmm1,xmm1,xmm5
  208fa9:	vmulsd xmm12,xmm0,QWORD PTR [r15-0x8]
  208faf:	vmulsd xmm13,xmm0,xmm1
  208fb3:	vmovupd ymm14,YMMWORD PTR [r14]
  208fb8:	lea    rax,[r14+r9*1]
  208fbc:	lea    rcx,[rip+0x2]        # 208fc5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6e5>
  208fc3:	jmp    rsi
  208fc5:	vshufpd ymm1,ymm14,ymm14,0x5
  208fcb:	vbroadcastsd ymm12,xmm12
  208fd0:	vbroadcastsd ymm13,xmm13
  208fd5:	vfmaddsub231pd ymm11,ymm13,ymm1
  208fda:	vfmaddsub231pd ymm11,ymm12,ymm14
  208fdf:	vshufpd ymm1,ymm0,ymm0,0x5
  208fe4:	vfmaddsub231pd ymm2,ymm13,ymm1
  208fe9:	vfmaddsub231pd ymm2,ymm12,ymm0
  208fee:	add    r12,r8
  208ff1:	add    r15,r10
  208ff4:	add    r14,r10
  208ff7:	dec    rdi
  208ffa:	je     20907a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x79a>
  208ffc:	vmovapd xmm0,xmm8
  209000:	test   bpl,bpl
  209003:	jne    208fa0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  209005:	vmovsd xmm0,QWORD PTR [r12]
  20900b:	vxorpd xmm0,xmm0,xmm5
  20900f:	jmp    208fa0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x6c0>
  209011:	mov    rdi,QWORD PTR [rsp+0x28]
  209016:	mov    rax,QWORD PTR [rsp+0x18]
  20901b:	lea    r15,[rax+rdi*1]
  20901f:	mov    r12,QWORD PTR [rsp+0x10]
  209024:	mov    rax,r14
  209027:	vmovapd ymm0,ymm2
  20902b:	mov    r13,QWORD PTR [rsp+0x48]
  209030:	lea    rcx,[rip+0x3]        # 20903a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x75a>
  209037:	jmp    r13
  20903a:	jmp    2090b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20903c:	mov    rdi,QWORD PTR [rsp+0x28]
  209041:	mov    rax,QWORD PTR [rsp+0x18]
  209046:	lea    r15,[rax+rdi*1]
  20904a:	mov    r12,QWORD PTR [rsp+0x10]
  20904f:	mov    rax,QWORD PTR [rsp+0xe0]
  209057:	mov    rcx,QWORD PTR [rsp+0x58]
  20905c:	vmovupd YMMWORD PTR [rcx],ymm11
  209060:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209065:	vmovapd ymm0,ymm2
  209069:	mov    r13,QWORD PTR [rsp+0x48]
  20906e:	lea    rcx,[rip+0x3]        # 209078 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x798>
  209075:	jmp    r13
  209078:	jmp    2090b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7d0>
  20907a:	mov    rdi,QWORD PTR [rsp+0x28]
  20907f:	mov    rax,QWORD PTR [rsp+0x18]
  209084:	lea    r15,[rax+rdi*1]
  209088:	mov    r12,QWORD PTR [rsp+0x10]
  20908d:	mov    rax,QWORD PTR [rsp+0x58]
  209092:	vmovupd YMMWORD PTR [rax],ymm11
  209096:	mov    rax,r13
  209099:	vmovapd ymm0,ymm2
  20909d:	mov    r13,QWORD PTR [rsp+0x48]
  2090a2:	lea    rcx,[rip+0x3]        # 2090ac <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x7cc>
  2090a9:	jmp    r13
  2090ac:	nop    DWORD PTR [rax+0x0]
  2090b0:	mov    r14,QWORD PTR [rsp+0x20]
  2090b5:	mov    rcx,rdx
  2090b8:	imul   rcx,QWORD PTR [rsp+0xf8]
  2090c1:	shl    rcx,0x4
  2090c5:	add    rcx,QWORD PTR [rsp+0x30]
  2090ca:	mov    rax,rdx
  2090cd:	sub    rax,rdi
  2090d0:	jae    2090e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x800>
  2090d2:	vmovsd xmm0,QWORD PTR [rcx]
  2090d6:	jmp    209175 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x895>
  2090db:	nop    DWORD PTR [rax+rax*1+0x0]
  2090e0:	cmp    rax,QWORD PTR [rsp+0x18]
  2090e5:	jae    209314 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xa34>
  2090eb:	mov    rax,rdx
  2090ee:	shl    rax,0x4
  2090f2:	vmovsd xmm0,QWORD PTR [r12+rax*1]
  2090f8:	cmp    BYTE PTR [rsp+0xf],0x0
  2090fd:	je     20911c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x83c>
  2090ff:	test   bpl,bpl
  209102:	je     209218 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x938>
  209108:	vucomisd xmm3,xmm0
  20910c:	jb     209121 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x841>
  20910e:	inc    QWORD PTR [rsp+0x60]
  209113:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20911c:	test   bpl,bpl
  20911f:	je     209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  209121:	vxorpd xmm1,xmm1,xmm1
  209125:	vucomisd xmm0,xmm1
  209129:	jbe    2092b1 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9d1>
  20912f:	vsqrtsd xmm0,xmm0,xmm0
  209133:	vmovsd QWORD PTR [rcx],xmm0
  209137:	vmovq  rax,xmm0
  20913c:	mov    QWORD PTR [rcx+0x8],0x0
  209144:	mov    cl,0x3f
  209146:	bzhi   rax,rax,rcx
  20914b:	movabs rcx,0x7ff0000000000000
  209155:	cmp    rax,rcx
  209158:	setg   cl
  20915b:	sete   dil
  20915f:	test   rax,rax
  209162:	sete   al
  209165:	or     al,dil
  209168:	or     al,cl
  20916a:	mov    rdi,QWORD PTR [rsp+0x28]
  20916f:	jne    2092bd <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9dd>
  209175:	mov    r12,r15
  209178:	vdivsd xmm0,xmm9,xmm0
  20917c:	vbroadcastsd ymm2,xmm0
  209181:	cmp    QWORD PTR [rsp+0xa8],0x0
  20918a:	je     208bb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  209190:	cmp    QWORD PTR [rsp+0xf0],0x8
  209199:	jae    2091a0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8c0>
  20919b:	xor    eax,eax
  20919d:	jmp    2091f2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x912>
  20919f:	nop
  2091a0:	mov    rcx,QWORD PTR [rsp+0x98]
  2091a8:	xor    eax,eax
  2091aa:	nop    WORD PTR [rax+rax*1+0x0]
  2091b0:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  2091b5:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  2091ba:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  2091bf:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  2091c4:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  2091c9:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  2091ce:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  2091d2:	add    rax,0x4
  2091d6:	vmovupd YMMWORD PTR [rcx],ymm0
  2091da:	sub    rcx,0xffffffffffffff80
  2091de:	cmp    r14,rax
  2091e1:	jne    2091b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x8d0>
  2091e3:	cmp    QWORD PTR [rsp+0xe8],0x0
  2091ec:	je     208bb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  2091f2:	shl    rax,0x5
  2091f6:	add    rax,QWORD PTR [rsp+0xa0]
  2091fe:	xor    ecx,ecx
  209200:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  209205:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20920a:	add    rcx,0x20
  20920e:	cmp    r11,rcx
  209211:	jne    209200 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x920>
  209213:	jmp    208bb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x2d0>
  209218:	mov    rax,QWORD PTR [rsp+0x80]
  209220:	test   rax,rax
  209223:	je     20925c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x97c>
  209225:	movzx  r14d,BYTE PTR [rax+rdx*1]
  20922a:	vucomisd xmm3,xmm0
  20922e:	setae  al
  209231:	vucomisd xmm0,xmm6
  209235:	setae  dil
  209239:	cmp    r14d,0xff
  209240:	je     209294 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9b4>
  209242:	cmp    r14d,0x1
  209246:	mov    r14,QWORD PTR [rsp+0x20]
  20924b:	jne    20926b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x98b>
  20924d:	vucomisd xmm3,xmm0
  209251:	jae    20910e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x82e>
  209257:	jmp    209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20925c:	vucomisd xmm3,xmm0
  209260:	setae  al
  209263:	vucomisd xmm0,xmm6
  209267:	setae  dil
  20926b:	test   dil,dil
  20926e:	je     209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  209274:	test   al,al
  209276:	je     209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  20927c:	vxorpd xmm1,xmm1,xmm1
  209280:	vucomisd xmm1,xmm0
  209284:	ja     2092a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9c3>
  209286:	vmovapd xmm0,XMMWORD PTR [rsp+0x120]
  20928f:	jmp    209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  209294:	vucomisd xmm0,xmm6
  209298:	mov    r14,QWORD PTR [rsp+0x20]
  20929d:	jb     209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  2092a3:	vmovapd xmm0,XMMWORD PTR [rsp+0x130]
  2092ac:	jmp    209133 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x853>
  2092b1:	vmovsd QWORD PTR [rcx],xmm0
  2092b5:	mov    QWORD PTR [rcx+0x8],0x0
  2092bd:	mov    eax,0x1
  2092c2:	add    rsp,0x148
  2092c9:	pop    rbx
  2092ca:	pop    r12
  2092cc:	pop    r13
  2092ce:	pop    r14
  2092d0:	pop    r15
  2092d2:	pop    rbp
  2092d3:	vzeroupper
  2092d6:	ret
  2092d7:	mov    rdx,rsi
  2092da:	xor    eax,eax
  2092dc:	jmp    2092c2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0x9e2>
  2092de:	lea    rdi,[rip+0xffffffffffe3dd03]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  2092e5:	lea    rdx,[rip+0x33294c]        # 53bc38 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xd8>
  2092ec:	mov    esi,0x28
  2092f1:	vzeroupper
  2092f4:	call   QWORD PTR [rip+0x340f16]        # 54a210 <_DYNAMIC+0x438>
  2092fa:	lea    rcx,[rip+0x332bd7]        # 53bed8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1b0>
  209301:	xor    edi,edi
  209303:	mov    rsi,r15
  209306:	mov    rdx,QWORD PTR [rsp+0x78]
  20930b:	vzeroupper
  20930e:	call   QWORD PTR [rip+0x340dc4]        # 54a0d8 <_DYNAMIC+0x300>
  209314:	lea    r10,[rip+0x332935]        # 53bc50 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xf0>
  20931b:	lea    r11,[rip+0xffffffffffe366ae]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209322:	lea    rbx,[rip+0x3325c7]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  209329:	lea    r14,[rip+0x332fa8]        # 53c2d8 <anon.c38c26bc52a245a79a4d978676f36d04.145.llvm.17936451394092910270>
  209330:	mov    r8d,0x1
  209336:	mov    r9d,0x1
  20933c:	mov    rdi,rax
  20933f:	mov    rsi,rax
  209342:	mov    rdx,QWORD PTR [rsp+0x18]
  209347:	movabs rcx,0x7fffffffffffffff
  209351:	push   r10
  209353:	push   r11
  209355:	push   rbx
  209356:	push   r14
  209358:	vzeroupper
  20935b:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  209360:	lea    rax,[rip+0x3328a1]        # 53bc08 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xa8>
  209367:	lea    r10,[rip+0xffffffffffe36662]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20936e:	lea    r11,[rip+0x332523]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209375:	lea    rbx,[rip+0x332764]        # 53bae0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x1f0>
  20937c:	mov    r8d,0x1
  209382:	mov    r9d,0x1
  209388:	mov    rdi,r15
  20938b:	mov    rsi,r15
  20938e:	mov    rdx,QWORD PTR [rsp+0xb0]
  209396:	jmp    209406 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImplINtCs2TWkUsNwXGV_11faer_traits11ComplexImpldEEEECscfHK10Grmvq_6fbench+0xb26>
  209398:	sub    rsp,0x8
  20939c:	lea    rax,[rip+0x332605]        # 53b9a8 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0xb8>
  2093a3:	lea    rcx,[rip+0x3325b6]        # 53b960 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x70>
  2093aa:	lea    r8,[rip+0x3324cf]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  2093b1:	lea    r9,[rip+0xffffffffffe36618]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  2093b8:	mov    edx,0x1
  2093bd:	mov    rdi,r15
  2093c0:	mov    rsi,QWORD PTR [rsp+0x78]
  2093c5:	push   rax
  2093c6:	vzeroupper
  2093c9:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  2093ce:	lea    rax,[rip+0x33284b]        # 53bc20 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xc0>
  2093d5:	lea    r10,[rip+0xffffffffffe365f4]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  2093dc:	lea    r11,[rip+0x3324b5]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  2093e3:	lea    rbx,[rip+0x332f6e]        # 53c358 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x58>
  2093ea:	mov    r8d,0x1
  2093f0:	mov    r9d,0x1
  2093f6:	mov    rsi,rdi
  2093f9:	mov    rdx,r15
  2093fc:	movabs rcx,0x7fffffffffffffff
  209406:	push   rax
  209407:	push   r10
  209409:	push   r11
  20940b:	push   rbx
  20940c:	vzeroupper
  20940f:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
