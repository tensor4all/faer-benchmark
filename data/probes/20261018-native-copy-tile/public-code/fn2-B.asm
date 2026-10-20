
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000023910 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_>:
   23910:	push   rbp
   23911:	push   r15
   23913:	push   r14
   23915:	push   r13
   23917:	push   r12
   23919:	push   rbx
   2391a:	sub    rsp,0x118
   23921:	mov    r14,rsi
   23924:	mov    QWORD PTR [rsp+0x100],rdi
   2392c:	call   QWORD PTR [rip+0x66856]        # 8a188 <_DYNAMIC+0x230>
   23932:	mov    QWORD PTR [rsp+0x108],rax
   2393a:	mov    DWORD PTR [rsp+0x110],edx
   23941:	lea    rdi,[rsp+0x108]
   23949:	call   QWORD PTR [rip+0x66841]        # 8a190 <_DYNAMIC+0x238>
   2394f:	test   rax,rax
   23952:	je     241a4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x894>
   23958:	call   QWORD PTR [rip+0x6683a]        # 8a198 <_DYNAMIC+0x240>
   2395e:	mov    edi,0x28
   23963:	mov    esi,0x8
   23968:	call   QWORD PTR [rip+0x66832]        # 8a1a0 <_DYNAMIC+0x248>
   2396e:	test   rax,rax
   23971:	je     2439d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa8d>
   23977:	mov    QWORD PTR [rsp],0x5
   2397f:	mov    QWORD PTR [rsp+0x8],rax
   23984:	mov    QWORD PTR [rsp+0x10],0x0
   2398d:	call   QWORD PTR [rip+0x667f5]        # 8a188 <_DYNAMIC+0x230>
   23993:	mov    QWORD PTR [rsp+0x88],rax
   2399b:	mov    DWORD PTR [rsp+0x90],edx
   239a2:	mov    rax,QWORD PTR [r14+0x20]
   239a6:	mov    QWORD PTR [rsp+0x70],rax
   239ab:	movups xmm0,XMMWORD PTR [r14]
   239af:	movupd xmm1,XMMWORD PTR [r14+0x10]
   239b5:	movapd XMMWORD PTR [rsp+0x60],xmm1
   239bb:	movaps XMMWORD PTR [rsp+0x50],xmm0
   239c0:	lea    rax,[rsp+0x50]
   239c5:	mov    rax,QWORD PTR [rsp+0x50]
   239ca:	mov    r15,QWORD PTR [rsp+0x58]
   239cf:	mov    rcx,QWORD PTR [rsp+0x70]
   239d4:	mov    QWORD PTR [rsp+0xd0],rax
   239dc:	mov    QWORD PTR [rsp+0xd8],r15
   239e4:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   239ea:	mov    r12,QWORD PTR [rsp+0x60]
   239ef:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   239f8:	mov    QWORD PTR [rsp+0xf0],rcx
   23a00:	lea    rdi,[rsp+0x18]
   23a05:	lea    rsi,[rsp+0xd0]
   23a0d:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   23a12:	mov    rdi,QWORD PTR [rsp+0x40]
   23a17:	mov    rsi,QWORD PTR [rsp+0x48]
   23a1c:	cmp    rdi,r15
   23a1f:	jne    243ad <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa9d>
   23a25:	cmp    rsi,r12
   23a28:	jne    243ad <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa9d>
   23a2e:	mov    rax,QWORD PTR [rsp+0x18]
   23a33:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23a39:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23a3f:	mov    QWORD PTR [rsp+0x98],rax
   23a47:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23a50:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23a59:	mov    QWORD PTR [rsp+0xc0],r15
   23a61:	mov    QWORD PTR [rsp+0xc8],r12
   23a69:	lea    rax,[rsp+0x98]
   23a71:	mov    rsi,QWORD PTR [rsp+0xb8]
   23a79:	test   rsi,rsi
   23a7c:	je     23a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x184>
   23a7e:	mov    rdi,QWORD PTR [rsp+0x98]
   23a86:	mov    rdx,QWORD PTR [rsp+0xb0]
   23a8e:	call   QWORD PTR [rip+0x66714]        # 8a1a8 <_DYNAMIC+0x250>
   23a94:	lea    rdi,[rsp+0x88]
   23a9c:	call   QWORD PTR [rip+0x666ee]        # 8a190 <_DYNAMIC+0x238>
   23aa2:	mov    r15,rax
   23aa5:	mov    ebx,edx
   23aa7:	mov    r12,QWORD PTR [rsp+0x10]
   23aac:	cmp    r12,QWORD PTR [rsp]
   23ab0:	jne    23aba <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x1aa>
   23ab2:	mov    rdi,rsp
   23ab5:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23aba:	movq   xmm0,r15
   23abf:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe3c69]        # 7730 <__abi_tag+0x7434>
   23ac7:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe3c01]        # 76d0 <__abi_tag+0x73d4>
   23acf:	movapd xmm1,xmm0
   23ad3:	unpckhpd xmm1,xmm0
   23ad7:	cvtsi2sd xmm2,ebx
   23adb:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3ead]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   23ae3:	addsd  xmm1,xmm0
   23ae7:	addsd  xmm2,xmm1
   23aeb:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe3f05]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23af3:	mov    rax,QWORD PTR [rsp+0x8]
   23af8:	movsd  QWORD PTR [rax+r12*8],xmm2
   23afe:	inc    r12
   23b01:	mov    QWORD PTR [rsp+0x10],r12
   23b06:	call   QWORD PTR [rip+0x6667c]        # 8a188 <_DYNAMIC+0x230>
   23b0c:	mov    QWORD PTR [rsp+0x88],rax
   23b14:	mov    DWORD PTR [rsp+0x90],edx
   23b1b:	mov    rax,QWORD PTR [r14+0x20]
   23b1f:	mov    QWORD PTR [rsp+0x70],rax
   23b24:	movups xmm0,XMMWORD PTR [r14]
   23b28:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23b2e:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23b34:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23b39:	lea    rax,[rsp+0x50]
   23b3e:	mov    rax,QWORD PTR [rsp+0x50]
   23b43:	mov    r15,QWORD PTR [rsp+0x58]
   23b48:	mov    rcx,QWORD PTR [rsp+0x70]
   23b4d:	mov    QWORD PTR [rsp+0xd0],rax
   23b55:	mov    QWORD PTR [rsp+0xd8],r15
   23b5d:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23b63:	mov    r12,QWORD PTR [rsp+0x60]
   23b68:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23b71:	mov    QWORD PTR [rsp+0xf0],rcx
   23b79:	lea    rdi,[rsp+0x18]
   23b7e:	lea    rsi,[rsp+0xd0]
   23b86:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   23b8b:	mov    rdi,QWORD PTR [rsp+0x40]
   23b90:	mov    rsi,QWORD PTR [rsp+0x48]
   23b95:	cmp    rdi,r15
   23b98:	jne    243ef <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xadf>
   23b9e:	cmp    rsi,r12
   23ba1:	jne    243ef <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xadf>
   23ba7:	mov    rax,QWORD PTR [rsp+0x18]
   23bac:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23bb2:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23bb8:	mov    QWORD PTR [rsp+0x98],rax
   23bc0:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23bc9:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23bd2:	mov    QWORD PTR [rsp+0xc0],r15
   23bda:	mov    QWORD PTR [rsp+0xc8],r12
   23be2:	lea    rax,[rsp+0x98]
   23bea:	mov    rsi,QWORD PTR [rsp+0xb8]
   23bf2:	test   rsi,rsi
   23bf5:	je     23c0d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x2fd>
   23bf7:	mov    rdi,QWORD PTR [rsp+0x98]
   23bff:	mov    rdx,QWORD PTR [rsp+0xb0]
   23c07:	call   QWORD PTR [rip+0x6659b]        # 8a1a8 <_DYNAMIC+0x250>
   23c0d:	lea    rdi,[rsp+0x88]
   23c15:	call   QWORD PTR [rip+0x66575]        # 8a190 <_DYNAMIC+0x238>
   23c1b:	mov    r15,rax
   23c1e:	mov    ebx,edx
   23c20:	mov    r12,QWORD PTR [rsp+0x10]
   23c25:	cmp    r12,QWORD PTR [rsp]
   23c29:	jne    23c33 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x323>
   23c2b:	mov    rdi,rsp
   23c2e:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23c33:	movq   xmm0,r15
   23c38:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe3af0]        # 7730 <__abi_tag+0x7434>
   23c40:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe3a88]        # 76d0 <__abi_tag+0x73d4>
   23c48:	movapd xmm1,xmm0
   23c4c:	unpckhpd xmm1,xmm0
   23c50:	cvtsi2sd xmm2,ebx
   23c54:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3d34]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   23c5c:	addsd  xmm1,xmm0
   23c60:	addsd  xmm2,xmm1
   23c64:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe3d8c]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23c6c:	mov    rax,QWORD PTR [rsp+0x8]
   23c71:	movsd  QWORD PTR [rax+r12*8],xmm2
   23c77:	inc    r12
   23c7a:	mov    QWORD PTR [rsp+0x10],r12
   23c7f:	call   QWORD PTR [rip+0x66503]        # 8a188 <_DYNAMIC+0x230>
   23c85:	mov    QWORD PTR [rsp+0x88],rax
   23c8d:	mov    DWORD PTR [rsp+0x90],edx
   23c94:	mov    rax,QWORD PTR [r14+0x20]
   23c98:	mov    QWORD PTR [rsp+0x70],rax
   23c9d:	movups xmm0,XMMWORD PTR [r14]
   23ca1:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23ca7:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23cad:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23cb2:	lea    rax,[rsp+0x50]
   23cb7:	mov    rax,QWORD PTR [rsp+0x50]
   23cbc:	mov    r15,QWORD PTR [rsp+0x58]
   23cc1:	mov    rcx,QWORD PTR [rsp+0x70]
   23cc6:	mov    QWORD PTR [rsp+0xd0],rax
   23cce:	mov    QWORD PTR [rsp+0xd8],r15
   23cd6:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23cdc:	mov    r12,QWORD PTR [rsp+0x60]
   23ce1:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23cea:	mov    QWORD PTR [rsp+0xf0],rcx
   23cf2:	lea    rdi,[rsp+0x18]
   23cf7:	lea    rsi,[rsp+0xd0]
   23cff:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   23d04:	mov    rdi,QWORD PTR [rsp+0x40]
   23d09:	mov    rsi,QWORD PTR [rsp+0x48]
   23d0e:	cmp    rdi,r15
   23d11:	jne    24431 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb21>
   23d17:	cmp    rsi,r12
   23d1a:	jne    24431 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb21>
   23d20:	mov    rax,QWORD PTR [rsp+0x18]
   23d25:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23d2b:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23d31:	mov    QWORD PTR [rsp+0x98],rax
   23d39:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23d42:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23d4b:	mov    QWORD PTR [rsp+0xc0],r15
   23d53:	mov    QWORD PTR [rsp+0xc8],r12
   23d5b:	lea    rax,[rsp+0x98]
   23d63:	mov    rsi,QWORD PTR [rsp+0xb8]
   23d6b:	test   rsi,rsi
   23d6e:	je     23d86 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x476>
   23d70:	mov    rdi,QWORD PTR [rsp+0x98]
   23d78:	mov    rdx,QWORD PTR [rsp+0xb0]
   23d80:	call   QWORD PTR [rip+0x66422]        # 8a1a8 <_DYNAMIC+0x250>
   23d86:	lea    rdi,[rsp+0x88]
   23d8e:	call   QWORD PTR [rip+0x663fc]        # 8a190 <_DYNAMIC+0x238>
   23d94:	mov    r15,rax
   23d97:	mov    ebx,edx
   23d99:	mov    r12,QWORD PTR [rsp+0x10]
   23d9e:	cmp    r12,QWORD PTR [rsp]
   23da2:	jne    23dac <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x49c>
   23da4:	mov    rdi,rsp
   23da7:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23dac:	movq   xmm0,r15
   23db1:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe3977]        # 7730 <__abi_tag+0x7434>
   23db9:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe390f]        # 76d0 <__abi_tag+0x73d4>
   23dc1:	movapd xmm1,xmm0
   23dc5:	unpckhpd xmm1,xmm0
   23dc9:	cvtsi2sd xmm2,ebx
   23dcd:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3bbb]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   23dd5:	addsd  xmm1,xmm0
   23dd9:	addsd  xmm2,xmm1
   23ddd:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe3c13]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23de5:	mov    rax,QWORD PTR [rsp+0x8]
   23dea:	movsd  QWORD PTR [rax+r12*8],xmm2
   23df0:	inc    r12
   23df3:	mov    QWORD PTR [rsp+0x10],r12
   23df8:	call   QWORD PTR [rip+0x6638a]        # 8a188 <_DYNAMIC+0x230>
   23dfe:	mov    QWORD PTR [rsp+0x88],rax
   23e06:	mov    DWORD PTR [rsp+0x90],edx
   23e0d:	mov    rax,QWORD PTR [r14+0x20]
   23e11:	mov    QWORD PTR [rsp+0x70],rax
   23e16:	movups xmm0,XMMWORD PTR [r14]
   23e1a:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23e20:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23e26:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23e2b:	lea    rax,[rsp+0x50]
   23e30:	mov    rax,QWORD PTR [rsp+0x50]
   23e35:	mov    r15,QWORD PTR [rsp+0x58]
   23e3a:	mov    rcx,QWORD PTR [rsp+0x70]
   23e3f:	mov    QWORD PTR [rsp+0xd0],rax
   23e47:	mov    QWORD PTR [rsp+0xd8],r15
   23e4f:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23e55:	mov    r12,QWORD PTR [rsp+0x60]
   23e5a:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23e63:	mov    QWORD PTR [rsp+0xf0],rcx
   23e6b:	lea    rdi,[rsp+0x18]
   23e70:	lea    rsi,[rsp+0xd0]
   23e78:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   23e7d:	mov    rdi,QWORD PTR [rsp+0x40]
   23e82:	mov    rsi,QWORD PTR [rsp+0x48]
   23e87:	cmp    rdi,r15
   23e8a:	jne    24470 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb60>
   23e90:	cmp    rsi,r12
   23e93:	jne    24470 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb60>
   23e99:	mov    rax,QWORD PTR [rsp+0x18]
   23e9e:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23ea4:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23eaa:	mov    QWORD PTR [rsp+0x98],rax
   23eb2:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23ebb:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23ec4:	mov    QWORD PTR [rsp+0xc0],r15
   23ecc:	mov    QWORD PTR [rsp+0xc8],r12
   23ed4:	lea    rax,[rsp+0x98]
   23edc:	mov    rsi,QWORD PTR [rsp+0xb8]
   23ee4:	test   rsi,rsi
   23ee7:	je     23eff <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x5ef>
   23ee9:	mov    rdi,QWORD PTR [rsp+0x98]
   23ef1:	mov    rdx,QWORD PTR [rsp+0xb0]
   23ef9:	call   QWORD PTR [rip+0x662a9]        # 8a1a8 <_DYNAMIC+0x250>
   23eff:	lea    rdi,[rsp+0x88]
   23f07:	call   QWORD PTR [rip+0x66283]        # 8a190 <_DYNAMIC+0x238>
   23f0d:	mov    r15,rax
   23f10:	mov    ebx,edx
   23f12:	mov    r12,QWORD PTR [rsp+0x10]
   23f17:	cmp    r12,QWORD PTR [rsp]
   23f1b:	jne    23f25 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x615>
   23f1d:	mov    rdi,rsp
   23f20:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23f25:	movq   xmm0,r15
   23f2a:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe37fe]        # 7730 <__abi_tag+0x7434>
   23f32:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe3796]        # 76d0 <__abi_tag+0x73d4>
   23f3a:	movapd xmm1,xmm0
   23f3e:	unpckhpd xmm1,xmm0
   23f42:	cvtsi2sd xmm2,ebx
   23f46:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3a42]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   23f4e:	addsd  xmm1,xmm0
   23f52:	addsd  xmm2,xmm1
   23f56:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe3a9a]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23f5e:	mov    rax,QWORD PTR [rsp+0x8]
   23f63:	movsd  QWORD PTR [rax+r12*8],xmm2
   23f69:	inc    r12
   23f6c:	mov    QWORD PTR [rsp+0x10],r12
   23f71:	call   QWORD PTR [rip+0x66211]        # 8a188 <_DYNAMIC+0x230>
   23f77:	mov    QWORD PTR [rsp+0x88],rax
   23f7f:	mov    DWORD PTR [rsp+0x90],edx
   23f86:	mov    rax,QWORD PTR [r14+0x20]
   23f8a:	mov    QWORD PTR [rsp+0x70],rax
   23f8f:	movups xmm0,XMMWORD PTR [r14]
   23f93:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23f99:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23f9f:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23fa4:	lea    rax,[rsp+0x50]
   23fa9:	mov    rax,QWORD PTR [rsp+0x50]
   23fae:	mov    r14,QWORD PTR [rsp+0x58]
   23fb3:	mov    rcx,QWORD PTR [rsp+0x70]
   23fb8:	mov    QWORD PTR [rsp+0xd0],rax
   23fc0:	mov    QWORD PTR [rsp+0xd8],r14
   23fc8:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23fce:	mov    r15,QWORD PTR [rsp+0x60]
   23fd3:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23fdc:	mov    QWORD PTR [rsp+0xf0],rcx
   23fe4:	lea    rdi,[rsp+0x18]
   23fe9:	lea    rsi,[rsp+0xd0]
   23ff1:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   23ff6:	mov    rdi,QWORD PTR [rsp+0x40]
   23ffb:	mov    rsi,QWORD PTR [rsp+0x48]
   24000:	cmp    rdi,r14
   24003:	jne    244af <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb9f>
   24009:	cmp    rsi,r15
   2400c:	jne    244af <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb9f>
   24012:	mov    rax,QWORD PTR [rsp+0x18]
   24017:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2401d:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24023:	mov    QWORD PTR [rsp+0x98],rax
   2402b:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24034:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2403d:	mov    QWORD PTR [rsp+0xc0],r14
   24045:	mov    QWORD PTR [rsp+0xc8],r15
   2404d:	lea    rax,[rsp+0x98]
   24055:	mov    rsi,QWORD PTR [rsp+0xb8]
   2405d:	test   rsi,rsi
   24060:	je     24078 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x768>
   24062:	mov    rdi,QWORD PTR [rsp+0x98]
   2406a:	mov    rdx,QWORD PTR [rsp+0xb0]
   24072:	call   QWORD PTR [rip+0x66130]        # 8a1a8 <_DYNAMIC+0x250>
   24078:	lea    rdi,[rsp+0x88]
   24080:	call   QWORD PTR [rip+0x6610a]        # 8a190 <_DYNAMIC+0x238>
   24086:	mov    r14,rax
   24089:	mov    ebx,edx
   2408b:	mov    rbp,QWORD PTR [rsp+0x10]
   24090:	cmp    rbp,QWORD PTR [rsp]
   24094:	jne    2409e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x78e>
   24096:	mov    rdi,rsp
   24099:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2409e:	movq   xmm0,r14
   240a3:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe3685]        # 7730 <__abi_tag+0x7434>
   240ab:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe361d]        # 76d0 <__abi_tag+0x73d4>
   240b3:	movapd xmm1,xmm0
   240b7:	unpckhpd xmm1,xmm0
   240bb:	addsd  xmm1,xmm0
   240bf:	xorps  xmm0,xmm0
   240c2:	cvtsi2sd xmm0,ebx
   240c6:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe38c2]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   240ce:	addsd  xmm0,xmm1
   240d2:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe391e]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   240da:	mov    rax,QWORD PTR [rsp+0x8]
   240df:	movsd  QWORD PTR [rax+rbp*8],xmm0
   240e4:	lea    r12,[rbp+0x1]
   240e8:	mov    QWORD PTR [rsp+0x10],r12
   240ed:	lea    r13,[rbp*8+0x8]
   240f5:	mov    rax,r12
   240f8:	shr    rax,0x3d
   240fc:	setne  al
   240ff:	movabs rcx,0x7ffffffffffffff8
   24109:	cmp    r13,rcx
   2410c:	seta   cl
   2410f:	or     cl,al
   24111:	je     24127 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x817>
   24113:	xor    r15d,r15d
   24116:	mov    rdi,r15
   24119:	mov    rsi,r13
   2411c:	call   QWORD PTR [rip+0x6608e]        # 8a1b0 <_DYNAMIC+0x258>
   24122:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   24127:	mov    rbx,QWORD PTR [rsp+0x8]
   2412c:	test   r13,r13
   2412f:	je     242cb <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9bb>
   24135:	call   QWORD PTR [rip+0x6605d]        # 8a198 <_DYNAMIC+0x240>
   2413b:	mov    r15d,0x8
   24141:	mov    esi,0x8
   24146:	mov    rdi,r13
   24149:	call   QWORD PTR [rip+0x66051]        # 8a1a0 <_DYNAMIC+0x248>
   2414f:	test   rax,rax
   24152:	je     24116 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x806>
   24154:	mov    r14,rax
   24157:	mov    r15,r12
   2415a:	test   r12,r12
   2415d:	je     242dd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9cd>
   24163:	mov    rdi,r14
   24166:	mov    rsi,rbx
   24169:	mov    rdx,r13
   2416c:	call   QWORD PTR [rip+0x66046]        # 8a1b8 <memcpy@GLIBC_2.14>
   24172:	lea    rax,[rsp+0x87]
   2417a:	mov    QWORD PTR [rsp+0x18],rax
   2417f:	mov    esi,0x1
   24184:	test   rbp,rbp
   24187:	jne    242e4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9d4>
   2418d:	lea    rdx,[rip+0x62b8c]        # 86d20 <__frame_dummy_init_array_entry+0x30>
   24194:	mov    edi,0x2
   24199:	call   QWORD PTR [rip+0x66021]        # 8a1c0 <_DYNAMIC+0x268>
   2419f:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   241a4:	lea    r15,[rsp+0x18]
   241a9:	lea    r13,[rsp+0x108]
   241b1:	mov    r12,QWORD PTR [rip+0x65fd8]        # 8a190 <_DYNAMIC+0x238>
   241b8:	jmp    241cf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x8bf>
   241ba:	nop    WORD PTR [rax+rax*1+0x0]
   241c0:	mov    rdi,r13
   241c3:	call   r12
   241c6:	test   rax,rax
   241c9:	jne    23958 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x48>
   241cf:	cmp    edx,0xee6b280
   241d5:	jae    23958 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x48>
   241db:	mov    rax,QWORD PTR [r14+0x20]
   241df:	mov    QWORD PTR [rsp+0xf0],rax
   241e7:	movups xmm0,XMMWORD PTR [r14]
   241eb:	movups xmm1,XMMWORD PTR [r14+0x10]
   241f0:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   241f8:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   24200:	lea    rax,[rsp+0xd0]
   24208:	mov    rax,QWORD PTR [rsp+0xd0]
   24210:	mov    rbp,QWORD PTR [rsp+0xd8]
   24218:	mov    rcx,QWORD PTR [rsp+0xf0]
   24220:	mov    QWORD PTR [rsp+0x98],rax
   24228:	mov    QWORD PTR [rsp+0xa0],rbp
   24230:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   24238:	mov    rbx,QWORD PTR [rsp+0xe0]
   24240:	movups XMMWORD PTR [rsp+0xa8],xmm0
   24248:	mov    QWORD PTR [rsp+0xb8],rcx
   24250:	mov    rdi,r15
   24253:	lea    rsi,[rsp+0x98]
   2425b:	call   27800 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   24260:	mov    rdi,QWORD PTR [rsp+0x40]
   24265:	mov    rsi,QWORD PTR [rsp+0x48]
   2426a:	cmp    rdi,rbp
   2426d:	jne    2435a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa4a>
   24273:	cmp    rsi,rbx
   24276:	jne    2435a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa4a>
   2427c:	mov    rax,QWORD PTR [rsp+0x18]
   24281:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24287:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2428d:	mov    QWORD PTR [rsp+0x18],rax
   24292:	movupd XMMWORD PTR [rsp+0x20],xmm0
   24298:	movupd XMMWORD PTR [rsp+0x30],xmm1
   2429e:	mov    QWORD PTR [rsp+0x40],rbp
   242a3:	mov    QWORD PTR [rsp+0x48],rbx
   242a8:	mov    rsi,QWORD PTR [rsp+0x38]
   242ad:	test   rsi,rsi
   242b0:	je     241c0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x8b0>
   242b6:	mov    rdi,QWORD PTR [rsp+0x18]
   242bb:	mov    rdx,QWORD PTR [rsp+0x30]
   242c0:	call   QWORD PTR [rip+0x65ee2]        # 8a1a8 <_DYNAMIC+0x250>
   242c6:	jmp    241c0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x8b0>
   242cb:	mov    r14d,0x8
   242d1:	xor    r15d,r15d
   242d4:	test   r12,r12
   242d7:	jne    24163 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x853>
   242dd:	xor    esi,esi
   242df:	jmp    2418d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x87d>
   242e4:	cmp    r12,0x15
   242e8:	jae    244ee <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbde>
   242ee:	lea    rcx,[rsp+0x18]
   242f3:	mov    edx,0x1
   242f8:	mov    rdi,r14
   242fb:	mov    rsi,r12
   242fe:	call   34840 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   24303:	cmp    r12,0x3
   24307:	jb     24503 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbf3>
   2430d:	movsd  xmm0,QWORD PTR [r14+0x10]
   24313:	mov    rax,QWORD PTR [rsp+0x10]
   24318:	mov    rbx,QWORD PTR [rsp+0x100]
   24320:	mov    QWORD PTR [rbx+0x18],rax
   24324:	movups xmm1,XMMWORD PTR [rsp]
   24328:	movups XMMWORD PTR [rbx+0x8],xmm1
   2432c:	movsd  QWORD PTR [rbx],xmm0
   24330:	shl    r15,0x3
   24334:	mov    edx,0x8
   24339:	mov    rdi,r14
   2433c:	mov    rsi,r15
   2433f:	call   QWORD PTR [rip+0x65e63]        # 8a1a8 <_DYNAMIC+0x250>
   24345:	mov    rax,rbx
   24348:	add    rsp,0x118
   2434f:	pop    rbx
   24350:	pop    r12
   24352:	pop    r13
   24354:	pop    r14
   24356:	pop    r15
   24358:	pop    rbp
   24359:	ret
   2435a:	lea    rax,[rip+0x62baf]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   24361:	lea    r10,[rip+0xfffffffffffe3618]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   24368:	lea    r11,[rip+0x62de1]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2436f:	lea    r14,[rip+0x62e62]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   24376:	mov    r8d,0x1
   2437c:	mov    r9d,0x1
   24382:	mov    rdx,rbp
   24385:	mov    rcx,rbx
   24388:	push   rax
   24389:	push   r10
   2438b:	push   r11
   2438d:	push   r14
   2438f:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   24394:	add    rsp,0x20
   24398:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   2439d:	mov    edi,0x8
   243a2:	mov    esi,0x28
   243a7:	call   QWORD PTR [rip+0x65e03]        # 8a1b0 <_DYNAMIC+0x258>
   243ad:	lea    rax,[rip+0x62b5c]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   243b4:	lea    r10,[rip+0xfffffffffffe35c5]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   243bb:	lea    r11,[rip+0x62d8e]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   243c2:	lea    rbx,[rip+0x62e0f]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   243c9:	mov    r8d,0x1
   243cf:	mov    r9d,0x1
   243d5:	mov    rdx,r15
   243d8:	mov    rcx,r12
   243db:	push   rax
   243dc:	push   r10
   243de:	push   r11
   243e0:	push   rbx
   243e1:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   243e6:	add    rsp,0x20
   243ea:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   243ef:	lea    rax,[rip+0x62b1a]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   243f6:	lea    r10,[rip+0xfffffffffffe3583]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   243fd:	lea    r11,[rip+0x62d4c]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24404:	lea    rbx,[rip+0x62dcd]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2440b:	mov    r8d,0x1
   24411:	mov    r9d,0x1
   24417:	mov    rdx,r15
   2441a:	mov    rcx,r12
   2441d:	push   rax
   2441e:	push   r10
   24420:	push   r11
   24422:	push   rbx
   24423:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   24428:	add    rsp,0x20
   2442c:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   24431:	lea    rax,[rip+0x62ad8]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   24438:	lea    r10,[rip+0xfffffffffffe3541]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   2443f:	lea    r11,[rip+0x62d0a]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24446:	lea    rbx,[rip+0x62d8b]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2444d:	mov    r8d,0x1
   24453:	mov    r9d,0x1
   24459:	mov    rdx,r15
   2445c:	mov    rcx,r12
   2445f:	push   rax
   24460:	push   r10
   24462:	push   r11
   24464:	push   rbx
   24465:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2446a:	add    rsp,0x20
   2446e:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   24470:	lea    rax,[rip+0x62a99]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   24477:	lea    r10,[rip+0xfffffffffffe3502]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   2447e:	lea    r11,[rip+0x62ccb]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24485:	lea    rbx,[rip+0x62d4c]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2448c:	mov    r8d,0x1
   24492:	mov    r9d,0x1
   24498:	mov    rdx,r15
   2449b:	mov    rcx,r12
   2449e:	push   rax
   2449f:	push   r10
   244a1:	push   r11
   244a3:	push   rbx
   244a4:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   244a9:	add    rsp,0x20
   244ad:	jmp    244ec <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbdc>
   244af:	lea    rax,[rip+0x62a5a]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   244b6:	lea    r10,[rip+0xfffffffffffe34c3]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   244bd:	lea    r11,[rip+0x62c8c]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   244c4:	lea    rbx,[rip+0x62d0d]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   244cb:	mov    r8d,0x1
   244d1:	mov    r9d,0x1
   244d7:	mov    rdx,r14
   244da:	mov    rcx,r15
   244dd:	push   rax
   244de:	push   r10
   244e0:	push   r11
   244e2:	push   rbx
   244e3:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   244e8:	add    rsp,0x20
   244ec:	ud2
   244ee:	lea    rdx,[rsp+0x18]
   244f3:	mov    rdi,r14
   244f6:	mov    rsi,r12
   244f9:	call   34170 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   244fe:	jmp    2430d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9fd>
   24503:	mov    esi,0x2
   24508:	jmp    2418d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x87d>
   2450d:	jmp    24515 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc05>
   2450f:	jmp    24515 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc05>
   24511:	jmp    24515 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc05>
   24513:	jmp    24515 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc05>
   24515:	mov    rbx,rax
   24518:	mov    rsi,QWORD PTR [rsp+0x38]
   2451d:	test   rsi,rsi
   24520:	je     24571 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc61>
   24522:	mov    rdi,QWORD PTR [rsp+0x18]
   24527:	mov    rdx,QWORD PTR [rsp+0x30]
   2452c:	call   QWORD PTR [rip+0x65c76]        # 8a1a8 <_DYNAMIC+0x250>
   24532:	jmp    24571 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc61>
   24534:	mov    rbx,rax
   24537:	mov    rsi,QWORD PTR [rsp+0x38]
   2453c:	test   rsi,rsi
   2453f:	je     2458e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc7e>
   24541:	mov    rdi,QWORD PTR [rsp+0x18]
   24546:	mov    rdx,QWORD PTR [rsp+0x30]
   2454b:	jmp    24588 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc78>
   2454d:	jmp    2456e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc5e>
   2454f:	mov    rbx,rax
   24552:	test   r15,r15
   24555:	je     24571 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc61>
   24557:	shl    r15,0x3
   2455b:	mov    edx,0x8
   24560:	mov    rdi,r14
   24563:	mov    rsi,r15
   24566:	call   QWORD PTR [rip+0x65c3c]        # 8a1a8 <_DYNAMIC+0x250>
   2456c:	jmp    24571 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc61>
   2456e:	mov    rbx,rax
   24571:	mov    rsi,QWORD PTR [rsp]
   24575:	test   rsi,rsi
   24578:	je     2458e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc7e>
   2457a:	mov    rdi,QWORD PTR [rsp+0x8]
   2457f:	shl    rsi,0x3
   24583:	mov    edx,0x8
   24588:	call   QWORD PTR [rip+0x65c1a]        # 8a1a8 <_DYNAMIC+0x250>
   2458e:	mov    rdi,rbx
   24591:	call   85c90 <_Unwind_Resume@plt>
