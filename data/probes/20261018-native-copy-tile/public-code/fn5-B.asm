
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000022c70 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_>:
   22c70:	push   rbp
   22c71:	push   r15
   22c73:	push   r14
   22c75:	push   r13
   22c77:	push   r12
   22c79:	push   rbx
   22c7a:	sub    rsp,0x118
   22c81:	mov    r14,rsi
   22c84:	mov    QWORD PTR [rsp+0x100],rdi
   22c8c:	call   QWORD PTR [rip+0x674f6]        # 8a188 <_DYNAMIC+0x230>
   22c92:	mov    QWORD PTR [rsp+0x108],rax
   22c9a:	mov    DWORD PTR [rsp+0x110],edx
   22ca1:	lea    rdi,[rsp+0x108]
   22ca9:	call   QWORD PTR [rip+0x674e1]        # 8a190 <_DYNAMIC+0x238>
   22caf:	test   rax,rax
   22cb2:	je     23522 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x8b2>
   22cb8:	call   QWORD PTR [rip+0x674da]        # 8a198 <_DYNAMIC+0x240>
   22cbe:	mov    edi,0x28
   22cc3:	mov    esi,0x8
   22cc8:	call   QWORD PTR [rip+0x674d2]        # 8a1a0 <_DYNAMIC+0x248>
   22cce:	test   rax,rax
   22cd1:	je     236d2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa62>
   22cd7:	mov    QWORD PTR [rsp],0x5
   22cdf:	mov    QWORD PTR [rsp+0x8],rax
   22ce4:	mov    QWORD PTR [rsp+0x10],0x0
   22ced:	call   QWORD PTR [rip+0x67495]        # 8a188 <_DYNAMIC+0x230>
   22cf3:	mov    QWORD PTR [rsp+0x88],rax
   22cfb:	mov    DWORD PTR [rsp+0x90],edx
   22d02:	mov    rax,QWORD PTR [r14+0x20]
   22d06:	mov    QWORD PTR [rsp+0x70],rax
   22d0b:	movups xmm0,XMMWORD PTR [r14]
   22d0f:	movupd xmm1,XMMWORD PTR [r14+0x10]
   22d15:	movapd XMMWORD PTR [rsp+0x60],xmm1
   22d1b:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22d20:	lea    rax,[rsp+0x50]
   22d25:	mov    rax,QWORD PTR [rsp+0x50]
   22d2a:	mov    r15,QWORD PTR [rsp+0x58]
   22d2f:	mov    rcx,QWORD PTR [rsp+0x70]
   22d34:	mov    QWORD PTR [rsp+0xd0],rax
   22d3c:	mov    QWORD PTR [rsp+0xd8],r15
   22d44:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   22d4a:	mov    r12,QWORD PTR [rsp+0x60]
   22d4f:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   22d58:	mov    QWORD PTR [rsp+0xf0],rcx
   22d60:	lea    rdi,[rsp+0x18]
   22d65:	lea    rcx,[rsp+0xd0]
   22d6d:	mov    rsi,r15
   22d70:	mov    rdx,r12
   22d73:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   22d78:	mov    rdi,QWORD PTR [rsp+0x40]
   22d7d:	mov    rsi,QWORD PTR [rsp+0x48]
   22d82:	cmp    rdi,r15
   22d85:	jne    236e2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa72>
   22d8b:	cmp    rsi,r12
   22d8e:	jne    236e2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa72>
   22d94:	mov    rax,QWORD PTR [rsp+0x18]
   22d99:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22d9f:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   22da5:	mov    QWORD PTR [rsp+0x98],rax
   22dad:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22db6:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   22dbf:	mov    QWORD PTR [rsp+0xc0],r15
   22dc7:	mov    QWORD PTR [rsp+0xc8],r12
   22dcf:	lea    rax,[rsp+0x98]
   22dd7:	mov    rsi,QWORD PTR [rsp+0xb8]
   22ddf:	test   rsi,rsi
   22de2:	je     22dfa <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x18a>
   22de4:	mov    rdi,QWORD PTR [rsp+0x98]
   22dec:	mov    rdx,QWORD PTR [rsp+0xb0]
   22df4:	call   QWORD PTR [rip+0x673ae]        # 8a1a8 <_DYNAMIC+0x250>
   22dfa:	lea    rdi,[rsp+0x88]
   22e02:	call   QWORD PTR [rip+0x67388]        # 8a190 <_DYNAMIC+0x238>
   22e08:	mov    r15,rax
   22e0b:	mov    ebx,edx
   22e0d:	mov    r12,QWORD PTR [rsp+0x10]
   22e12:	cmp    r12,QWORD PTR [rsp]
   22e16:	jne    22e20 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x1b0>
   22e18:	mov    rdi,rsp
   22e1b:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   22e20:	movq   xmm0,r15
   22e25:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4903]        # 7730 <__abi_tag+0x7434>
   22e2d:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe489b]        # 76d0 <__abi_tag+0x73d4>
   22e35:	movapd xmm1,xmm0
   22e39:	unpckhpd xmm1,xmm0
   22e3d:	cvtsi2sd xmm2,ebx
   22e41:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe4b47]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   22e49:	addsd  xmm1,xmm0
   22e4d:	addsd  xmm2,xmm1
   22e51:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe4b9f]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   22e59:	mov    rax,QWORD PTR [rsp+0x8]
   22e5e:	movsd  QWORD PTR [rax+r12*8],xmm2
   22e64:	inc    r12
   22e67:	mov    QWORD PTR [rsp+0x10],r12
   22e6c:	call   QWORD PTR [rip+0x67316]        # 8a188 <_DYNAMIC+0x230>
   22e72:	mov    QWORD PTR [rsp+0x88],rax
   22e7a:	mov    DWORD PTR [rsp+0x90],edx
   22e81:	mov    rax,QWORD PTR [r14+0x20]
   22e85:	mov    QWORD PTR [rsp+0x70],rax
   22e8a:	movups xmm0,XMMWORD PTR [r14]
   22e8e:	movupd xmm1,XMMWORD PTR [r14+0x10]
   22e94:	movapd XMMWORD PTR [rsp+0x60],xmm1
   22e9a:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22e9f:	lea    rax,[rsp+0x50]
   22ea4:	mov    rax,QWORD PTR [rsp+0x50]
   22ea9:	mov    r15,QWORD PTR [rsp+0x58]
   22eae:	mov    rcx,QWORD PTR [rsp+0x70]
   22eb3:	mov    QWORD PTR [rsp+0xd0],rax
   22ebb:	mov    QWORD PTR [rsp+0xd8],r15
   22ec3:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   22ec9:	mov    r12,QWORD PTR [rsp+0x60]
   22ece:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   22ed7:	mov    QWORD PTR [rsp+0xf0],rcx
   22edf:	lea    rdi,[rsp+0x18]
   22ee4:	lea    rcx,[rsp+0xd0]
   22eec:	mov    rsi,r15
   22eef:	mov    rdx,r12
   22ef2:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   22ef7:	mov    rdi,QWORD PTR [rsp+0x40]
   22efc:	mov    rsi,QWORD PTR [rsp+0x48]
   22f01:	cmp    rdi,r15
   22f04:	jne    23724 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xab4>
   22f0a:	cmp    rsi,r12
   22f0d:	jne    23724 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xab4>
   22f13:	mov    rax,QWORD PTR [rsp+0x18]
   22f18:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22f1e:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   22f24:	mov    QWORD PTR [rsp+0x98],rax
   22f2c:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22f35:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   22f3e:	mov    QWORD PTR [rsp+0xc0],r15
   22f46:	mov    QWORD PTR [rsp+0xc8],r12
   22f4e:	lea    rax,[rsp+0x98]
   22f56:	mov    rsi,QWORD PTR [rsp+0xb8]
   22f5e:	test   rsi,rsi
   22f61:	je     22f79 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x309>
   22f63:	mov    rdi,QWORD PTR [rsp+0x98]
   22f6b:	mov    rdx,QWORD PTR [rsp+0xb0]
   22f73:	call   QWORD PTR [rip+0x6722f]        # 8a1a8 <_DYNAMIC+0x250>
   22f79:	lea    rdi,[rsp+0x88]
   22f81:	call   QWORD PTR [rip+0x67209]        # 8a190 <_DYNAMIC+0x238>
   22f87:	mov    r15,rax
   22f8a:	mov    ebx,edx
   22f8c:	mov    r12,QWORD PTR [rsp+0x10]
   22f91:	cmp    r12,QWORD PTR [rsp]
   22f95:	jne    22f9f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x32f>
   22f97:	mov    rdi,rsp
   22f9a:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   22f9f:	movq   xmm0,r15
   22fa4:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4784]        # 7730 <__abi_tag+0x7434>
   22fac:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe471c]        # 76d0 <__abi_tag+0x73d4>
   22fb4:	movapd xmm1,xmm0
   22fb8:	unpckhpd xmm1,xmm0
   22fbc:	cvtsi2sd xmm2,ebx
   22fc0:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe49c8]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   22fc8:	addsd  xmm1,xmm0
   22fcc:	addsd  xmm2,xmm1
   22fd0:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe4a20]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   22fd8:	mov    rax,QWORD PTR [rsp+0x8]
   22fdd:	movsd  QWORD PTR [rax+r12*8],xmm2
   22fe3:	inc    r12
   22fe6:	mov    QWORD PTR [rsp+0x10],r12
   22feb:	call   QWORD PTR [rip+0x67197]        # 8a188 <_DYNAMIC+0x230>
   22ff1:	mov    QWORD PTR [rsp+0x88],rax
   22ff9:	mov    DWORD PTR [rsp+0x90],edx
   23000:	mov    rax,QWORD PTR [r14+0x20]
   23004:	mov    QWORD PTR [rsp+0x70],rax
   23009:	movups xmm0,XMMWORD PTR [r14]
   2300d:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23013:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23019:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2301e:	lea    rax,[rsp+0x50]
   23023:	mov    rax,QWORD PTR [rsp+0x50]
   23028:	mov    r15,QWORD PTR [rsp+0x58]
   2302d:	mov    rcx,QWORD PTR [rsp+0x70]
   23032:	mov    QWORD PTR [rsp+0xd0],rax
   2303a:	mov    QWORD PTR [rsp+0xd8],r15
   23042:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23048:	mov    r12,QWORD PTR [rsp+0x60]
   2304d:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23056:	mov    QWORD PTR [rsp+0xf0],rcx
   2305e:	lea    rdi,[rsp+0x18]
   23063:	lea    rcx,[rsp+0xd0]
   2306b:	mov    rsi,r15
   2306e:	mov    rdx,r12
   23071:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   23076:	mov    rdi,QWORD PTR [rsp+0x40]
   2307b:	mov    rsi,QWORD PTR [rsp+0x48]
   23080:	cmp    rdi,r15
   23083:	jne    23766 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xaf6>
   23089:	cmp    rsi,r12
   2308c:	jne    23766 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xaf6>
   23092:	mov    rax,QWORD PTR [rsp+0x18]
   23097:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2309d:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   230a3:	mov    QWORD PTR [rsp+0x98],rax
   230ab:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   230b4:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   230bd:	mov    QWORD PTR [rsp+0xc0],r15
   230c5:	mov    QWORD PTR [rsp+0xc8],r12
   230cd:	lea    rax,[rsp+0x98]
   230d5:	mov    rsi,QWORD PTR [rsp+0xb8]
   230dd:	test   rsi,rsi
   230e0:	je     230f8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x488>
   230e2:	mov    rdi,QWORD PTR [rsp+0x98]
   230ea:	mov    rdx,QWORD PTR [rsp+0xb0]
   230f2:	call   QWORD PTR [rip+0x670b0]        # 8a1a8 <_DYNAMIC+0x250>
   230f8:	lea    rdi,[rsp+0x88]
   23100:	call   QWORD PTR [rip+0x6708a]        # 8a190 <_DYNAMIC+0x238>
   23106:	mov    r15,rax
   23109:	mov    ebx,edx
   2310b:	mov    r12,QWORD PTR [rsp+0x10]
   23110:	cmp    r12,QWORD PTR [rsp]
   23114:	jne    2311e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x4ae>
   23116:	mov    rdi,rsp
   23119:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2311e:	movq   xmm0,r15
   23123:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4605]        # 7730 <__abi_tag+0x7434>
   2312b:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe459d]        # 76d0 <__abi_tag+0x73d4>
   23133:	movapd xmm1,xmm0
   23137:	unpckhpd xmm1,xmm0
   2313b:	cvtsi2sd xmm2,ebx
   2313f:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe4849]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   23147:	addsd  xmm1,xmm0
   2314b:	addsd  xmm2,xmm1
   2314f:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe48a1]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23157:	mov    rax,QWORD PTR [rsp+0x8]
   2315c:	movsd  QWORD PTR [rax+r12*8],xmm2
   23162:	inc    r12
   23165:	mov    QWORD PTR [rsp+0x10],r12
   2316a:	call   QWORD PTR [rip+0x67018]        # 8a188 <_DYNAMIC+0x230>
   23170:	mov    QWORD PTR [rsp+0x88],rax
   23178:	mov    DWORD PTR [rsp+0x90],edx
   2317f:	mov    rax,QWORD PTR [r14+0x20]
   23183:	mov    QWORD PTR [rsp+0x70],rax
   23188:	movups xmm0,XMMWORD PTR [r14]
   2318c:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23192:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23198:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2319d:	lea    rax,[rsp+0x50]
   231a2:	mov    rax,QWORD PTR [rsp+0x50]
   231a7:	mov    r15,QWORD PTR [rsp+0x58]
   231ac:	mov    rcx,QWORD PTR [rsp+0x70]
   231b1:	mov    QWORD PTR [rsp+0xd0],rax
   231b9:	mov    QWORD PTR [rsp+0xd8],r15
   231c1:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   231c7:	mov    r12,QWORD PTR [rsp+0x60]
   231cc:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   231d5:	mov    QWORD PTR [rsp+0xf0],rcx
   231dd:	lea    rdi,[rsp+0x18]
   231e2:	lea    rcx,[rsp+0xd0]
   231ea:	mov    rsi,r15
   231ed:	mov    rdx,r12
   231f0:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   231f5:	mov    rdi,QWORD PTR [rsp+0x40]
   231fa:	mov    rsi,QWORD PTR [rsp+0x48]
   231ff:	cmp    rdi,r15
   23202:	jne    237a8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb38>
   23208:	cmp    rsi,r12
   2320b:	jne    237a8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb38>
   23211:	mov    rax,QWORD PTR [rsp+0x18]
   23216:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2321c:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23222:	mov    QWORD PTR [rsp+0x98],rax
   2322a:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23233:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2323c:	mov    QWORD PTR [rsp+0xc0],r15
   23244:	mov    QWORD PTR [rsp+0xc8],r12
   2324c:	lea    rax,[rsp+0x98]
   23254:	mov    rsi,QWORD PTR [rsp+0xb8]
   2325c:	test   rsi,rsi
   2325f:	je     23277 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x607>
   23261:	mov    rdi,QWORD PTR [rsp+0x98]
   23269:	mov    rdx,QWORD PTR [rsp+0xb0]
   23271:	call   QWORD PTR [rip+0x66f31]        # 8a1a8 <_DYNAMIC+0x250>
   23277:	lea    rdi,[rsp+0x88]
   2327f:	call   QWORD PTR [rip+0x66f0b]        # 8a190 <_DYNAMIC+0x238>
   23285:	mov    r15,rax
   23288:	mov    ebx,edx
   2328a:	mov    r12,QWORD PTR [rsp+0x10]
   2328f:	cmp    r12,QWORD PTR [rsp]
   23293:	jne    2329d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x62d>
   23295:	mov    rdi,rsp
   23298:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2329d:	movq   xmm0,r15
   232a2:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4486]        # 7730 <__abi_tag+0x7434>
   232aa:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe441e]        # 76d0 <__abi_tag+0x73d4>
   232b2:	movapd xmm1,xmm0
   232b6:	unpckhpd xmm1,xmm0
   232ba:	cvtsi2sd xmm2,ebx
   232be:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe46ca]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   232c6:	addsd  xmm1,xmm0
   232ca:	addsd  xmm2,xmm1
   232ce:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe4722]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   232d6:	mov    rax,QWORD PTR [rsp+0x8]
   232db:	movsd  QWORD PTR [rax+r12*8],xmm2
   232e1:	inc    r12
   232e4:	mov    QWORD PTR [rsp+0x10],r12
   232e9:	call   QWORD PTR [rip+0x66e99]        # 8a188 <_DYNAMIC+0x230>
   232ef:	mov    QWORD PTR [rsp+0x88],rax
   232f7:	mov    DWORD PTR [rsp+0x90],edx
   232fe:	mov    rax,QWORD PTR [r14+0x20]
   23302:	mov    QWORD PTR [rsp+0x70],rax
   23307:	movups xmm0,XMMWORD PTR [r14]
   2330b:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23311:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23317:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2331c:	lea    rax,[rsp+0x50]
   23321:	mov    rax,QWORD PTR [rsp+0x50]
   23326:	mov    r14,QWORD PTR [rsp+0x58]
   2332b:	mov    rcx,QWORD PTR [rsp+0x70]
   23330:	mov    QWORD PTR [rsp+0xd0],rax
   23338:	mov    QWORD PTR [rsp+0xd8],r14
   23340:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23346:	mov    r15,QWORD PTR [rsp+0x60]
   2334b:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23354:	mov    QWORD PTR [rsp+0xf0],rcx
   2335c:	lea    rdi,[rsp+0x18]
   23361:	lea    rcx,[rsp+0xd0]
   23369:	mov    rsi,r14
   2336c:	mov    rdx,r15
   2336f:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   23374:	mov    rdi,QWORD PTR [rsp+0x40]
   23379:	mov    rsi,QWORD PTR [rsp+0x48]
   2337e:	cmp    rdi,r14
   23381:	jne    237e7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb77>
   23387:	cmp    rsi,r15
   2338a:	jne    237e7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb77>
   23390:	mov    rax,QWORD PTR [rsp+0x18]
   23395:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2339b:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   233a1:	mov    QWORD PTR [rsp+0x98],rax
   233a9:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   233b2:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   233bb:	mov    QWORD PTR [rsp+0xc0],r14
   233c3:	mov    QWORD PTR [rsp+0xc8],r15
   233cb:	lea    rax,[rsp+0x98]
   233d3:	mov    rsi,QWORD PTR [rsp+0xb8]
   233db:	test   rsi,rsi
   233de:	je     233f6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x786>
   233e0:	mov    rdi,QWORD PTR [rsp+0x98]
   233e8:	mov    rdx,QWORD PTR [rsp+0xb0]
   233f0:	call   QWORD PTR [rip+0x66db2]        # 8a1a8 <_DYNAMIC+0x250>
   233f6:	lea    rdi,[rsp+0x88]
   233fe:	call   QWORD PTR [rip+0x66d8c]        # 8a190 <_DYNAMIC+0x238>
   23404:	mov    r14,rax
   23407:	mov    ebx,edx
   23409:	mov    rbp,QWORD PTR [rsp+0x10]
   2340e:	cmp    rbp,QWORD PTR [rsp]
   23412:	jne    2341c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x7ac>
   23414:	mov    rdi,rsp
   23417:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2341c:	movq   xmm0,r14
   23421:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4307]        # 7730 <__abi_tag+0x7434>
   23429:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe429f]        # 76d0 <__abi_tag+0x73d4>
   23431:	movapd xmm1,xmm0
   23435:	unpckhpd xmm1,xmm0
   23439:	addsd  xmm1,xmm0
   2343d:	xorps  xmm0,xmm0
   23440:	cvtsi2sd xmm0,ebx
   23444:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe4544]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   2344c:	addsd  xmm0,xmm1
   23450:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe45a0]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   23458:	mov    rax,QWORD PTR [rsp+0x8]
   2345d:	movsd  QWORD PTR [rax+rbp*8],xmm0
   23462:	lea    r12,[rbp+0x1]
   23466:	mov    QWORD PTR [rsp+0x10],r12
   2346b:	lea    r13,[rbp*8+0x8]
   23473:	mov    rax,r12
   23476:	shr    rax,0x3d
   2347a:	setne  al
   2347d:	movabs rcx,0x7ffffffffffffff8
   23487:	cmp    r13,rcx
   2348a:	seta   cl
   2348d:	or     cl,al
   2348f:	je     234a5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x835>
   23491:	xor    r15d,r15d
   23494:	mov    rdi,r15
   23497:	mov    rsi,r13
   2349a:	call   QWORD PTR [rip+0x66d10]        # 8a1b0 <_DYNAMIC+0x258>
   234a0:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   234a5:	mov    rbx,QWORD PTR [rsp+0x8]
   234aa:	test   r13,r13
   234ad:	je     23643 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9d3>
   234b3:	call   QWORD PTR [rip+0x66cdf]        # 8a198 <_DYNAMIC+0x240>
   234b9:	mov    r15d,0x8
   234bf:	mov    esi,0x8
   234c4:	mov    rdi,r13
   234c7:	call   QWORD PTR [rip+0x66cd3]        # 8a1a0 <_DYNAMIC+0x248>
   234cd:	test   rax,rax
   234d0:	je     23494 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x824>
   234d2:	mov    r14,rax
   234d5:	mov    r15,r12
   234d8:	test   r12,r12
   234db:	je     23655 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9e5>
   234e1:	mov    rdi,r14
   234e4:	mov    rsi,rbx
   234e7:	mov    rdx,r13
   234ea:	call   QWORD PTR [rip+0x66cc8]        # 8a1b8 <memcpy@GLIBC_2.14>
   234f0:	lea    rax,[rsp+0x87]
   234f8:	mov    QWORD PTR [rsp+0x18],rax
   234fd:	mov    esi,0x1
   23502:	test   rbp,rbp
   23505:	jne    2365c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9ec>
   2350b:	lea    rdx,[rip+0x6380e]        # 86d20 <__frame_dummy_init_array_entry+0x30>
   23512:	mov    edi,0x2
   23517:	call   QWORD PTR [rip+0x66ca3]        # 8a1c0 <_DYNAMIC+0x268>
   2351d:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   23522:	lea    r15,[rsp+0x18]
   23527:	lea    r13,[rsp+0x108]
   2352f:	mov    r12,QWORD PTR [rip+0x66c5a]        # 8a190 <_DYNAMIC+0x238>
   23536:	cmp    edx,0xee6b280
   2353c:	jae    22cb8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x48>
   23542:	mov    rax,QWORD PTR [r14+0x20]
   23546:	mov    QWORD PTR [rsp+0xf0],rax
   2354e:	movups xmm0,XMMWORD PTR [r14]
   23552:	movups xmm1,XMMWORD PTR [r14+0x10]
   23557:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   2355f:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   23567:	lea    rax,[rsp+0xd0]
   2356f:	mov    rax,QWORD PTR [rsp+0xd0]
   23577:	mov    rbp,QWORD PTR [rsp+0xd8]
   2357f:	mov    rcx,QWORD PTR [rsp+0xf0]
   23587:	mov    QWORD PTR [rsp+0x98],rax
   2358f:	mov    QWORD PTR [rsp+0xa0],rbp
   23597:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   2359f:	mov    rbx,QWORD PTR [rsp+0xe0]
   235a7:	movups XMMWORD PTR [rsp+0xa8],xmm0
   235af:	mov    QWORD PTR [rsp+0xb8],rcx
   235b7:	mov    rdi,r15
   235ba:	mov    rsi,rbp
   235bd:	mov    rdx,rbx
   235c0:	lea    rcx,[rsp+0x98]
   235c8:	call   2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   235cd:	mov    rdi,QWORD PTR [rsp+0x40]
   235d2:	mov    rsi,QWORD PTR [rsp+0x48]
   235d7:	cmp    rdi,rbp
   235da:	jne    23826 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbb6>
   235e0:	cmp    rsi,rbx
   235e3:	jne    23826 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbb6>
   235e9:	mov    rax,QWORD PTR [rsp+0x18]
   235ee:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   235f4:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   235fa:	mov    QWORD PTR [rsp+0x18],rax
   235ff:	movupd XMMWORD PTR [rsp+0x20],xmm0
   23605:	movupd XMMWORD PTR [rsp+0x30],xmm1
   2360b:	mov    QWORD PTR [rsp+0x40],rbp
   23610:	mov    QWORD PTR [rsp+0x48],rbx
   23615:	mov    rsi,QWORD PTR [rsp+0x38]
   2361a:	test   rsi,rsi
   2361d:	je     2362f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9bf>
   2361f:	mov    rdi,QWORD PTR [rsp+0x18]
   23624:	mov    rdx,QWORD PTR [rsp+0x30]
   23629:	call   QWORD PTR [rip+0x66b79]        # 8a1a8 <_DYNAMIC+0x250>
   2362f:	mov    rdi,r13
   23632:	call   r12
   23635:	test   rax,rax
   23638:	je     23536 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x8c6>
   2363e:	jmp    22cb8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x48>
   23643:	mov    r14d,0x8
   23649:	xor    r15d,r15d
   2364c:	test   r12,r12
   2364f:	jne    234e1 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x871>
   23655:	xor    esi,esi
   23657:	jmp    2350b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x89b>
   2365c:	cmp    r12,0x15
   23660:	jae    23866 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf6>
   23666:	lea    rcx,[rsp+0x18]
   2366b:	mov    edx,0x1
   23670:	mov    rdi,r14
   23673:	mov    rsi,r12
   23676:	call   34840 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   2367b:	cmp    r12,0x3
   2367f:	jb     2387b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc0b>
   23685:	movsd  xmm0,QWORD PTR [r14+0x10]
   2368b:	mov    rax,QWORD PTR [rsp+0x10]
   23690:	mov    rbx,QWORD PTR [rsp+0x100]
   23698:	mov    QWORD PTR [rbx+0x18],rax
   2369c:	movups xmm1,XMMWORD PTR [rsp]
   236a0:	movups XMMWORD PTR [rbx+0x8],xmm1
   236a4:	movsd  QWORD PTR [rbx],xmm0
   236a8:	shl    r15,0x3
   236ac:	mov    edx,0x8
   236b1:	mov    rdi,r14
   236b4:	mov    rsi,r15
   236b7:	call   QWORD PTR [rip+0x66aeb]        # 8a1a8 <_DYNAMIC+0x250>
   236bd:	mov    rax,rbx
   236c0:	add    rsp,0x118
   236c7:	pop    rbx
   236c8:	pop    r12
   236ca:	pop    r13
   236cc:	pop    r14
   236ce:	pop    r15
   236d0:	pop    rbp
   236d1:	ret
   236d2:	mov    edi,0x8
   236d7:	mov    esi,0x28
   236dc:	call   QWORD PTR [rip+0x66ace]        # 8a1b0 <_DYNAMIC+0x258>
   236e2:	lea    rax,[rip+0x6380f]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   236e9:	lea    r10,[rip+0xfffffffffffe4290]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   236f0:	lea    r11,[rip+0x63a59]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   236f7:	lea    rbx,[rip+0x63ada]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   236fe:	mov    r8d,0x1
   23704:	mov    r9d,0x1
   2370a:	mov    rdx,r15
   2370d:	mov    rcx,r12
   23710:	push   rax
   23711:	push   r10
   23713:	push   r11
   23715:	push   rbx
   23716:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2371b:	add    rsp,0x20
   2371f:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   23724:	lea    rax,[rip+0x637cd]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2372b:	lea    r10,[rip+0xfffffffffffe424e]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   23732:	lea    r11,[rip+0x63a17]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23739:	lea    rbx,[rip+0x63a98]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23740:	mov    r8d,0x1
   23746:	mov    r9d,0x1
   2374c:	mov    rdx,r15
   2374f:	mov    rcx,r12
   23752:	push   rax
   23753:	push   r10
   23755:	push   r11
   23757:	push   rbx
   23758:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2375d:	add    rsp,0x20
   23761:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   23766:	lea    rax,[rip+0x6378b]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2376d:	lea    r10,[rip+0xfffffffffffe420c]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   23774:	lea    r11,[rip+0x639d5]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2377b:	lea    rbx,[rip+0x63a56]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23782:	mov    r8d,0x1
   23788:	mov    r9d,0x1
   2378e:	mov    rdx,r15
   23791:	mov    rcx,r12
   23794:	push   rax
   23795:	push   r10
   23797:	push   r11
   23799:	push   rbx
   2379a:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2379f:	add    rsp,0x20
   237a3:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   237a8:	lea    rax,[rip+0x63749]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   237af:	lea    r10,[rip+0xfffffffffffe41ca]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   237b6:	lea    r11,[rip+0x63993]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   237bd:	lea    rbx,[rip+0x63a14]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   237c4:	mov    r8d,0x1
   237ca:	mov    r9d,0x1
   237d0:	mov    rdx,r15
   237d3:	mov    rcx,r12
   237d6:	push   rax
   237d7:	push   r10
   237d9:	push   r11
   237db:	push   rbx
   237dc:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   237e1:	add    rsp,0x20
   237e5:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   237e7:	lea    rax,[rip+0x6370a]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   237ee:	lea    r10,[rip+0xfffffffffffe418b]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   237f5:	lea    r11,[rip+0x63954]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   237fc:	lea    rbx,[rip+0x639d5]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23803:	mov    r8d,0x1
   23809:	mov    r9d,0x1
   2380f:	mov    rdx,r14
   23812:	mov    rcx,r15
   23815:	push   rax
   23816:	push   r10
   23818:	push   r11
   2381a:	push   rbx
   2381b:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23820:	add    rsp,0x20
   23824:	jmp    23864 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   23826:	lea    rax,[rip+0x636cb]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2382d:	lea    r10,[rip+0xfffffffffffe414c]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   23834:	lea    r11,[rip+0x63915]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2383b:	lea    r14,[rip+0x63996]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23842:	mov    r8d,0x1
   23848:	mov    r9d,0x1
   2384e:	mov    rdx,rbp
   23851:	mov    rcx,rbx
   23854:	push   rax
   23855:	push   r10
   23857:	push   r11
   23859:	push   r14
   2385b:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23860:	add    rsp,0x20
   23864:	ud2
   23866:	lea    rdx,[rsp+0x18]
   2386b:	mov    rdi,r14
   2386e:	mov    rsi,r12
   23871:	call   34170 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   23876:	jmp    23685 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa15>
   2387b:	mov    esi,0x2
   23880:	jmp    2350b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x89b>
   23885:	mov    rbx,rax
   23888:	mov    rsi,QWORD PTR [rsp+0x38]
   2388d:	test   rsi,rsi
   23890:	je     23906 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc96>
   23892:	mov    rdi,QWORD PTR [rsp+0x18]
   23897:	mov    rdx,QWORD PTR [rsp+0x30]
   2389c:	jmp    23900 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc90>
   2389e:	jmp    238a6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   238a0:	jmp    238a6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   238a2:	jmp    238a6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   238a4:	jmp    238a6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   238a6:	mov    rbx,rax
   238a9:	mov    rsi,QWORD PTR [rsp+0x38]
   238ae:	test   rsi,rsi
   238b1:	je     238e9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   238b3:	mov    rdi,QWORD PTR [rsp+0x18]
   238b8:	mov    rdx,QWORD PTR [rsp+0x30]
   238bd:	call   QWORD PTR [rip+0x668e5]        # 8a1a8 <_DYNAMIC+0x250>
   238c3:	jmp    238e9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   238c5:	jmp    238e6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc76>
   238c7:	mov    rbx,rax
   238ca:	test   r15,r15
   238cd:	je     238e9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   238cf:	shl    r15,0x3
   238d3:	mov    edx,0x8
   238d8:	mov    rdi,r14
   238db:	mov    rsi,r15
   238de:	call   QWORD PTR [rip+0x668c4]        # 8a1a8 <_DYNAMIC+0x250>
   238e4:	jmp    238e9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   238e6:	mov    rbx,rax
   238e9:	mov    rsi,QWORD PTR [rsp]
   238ed:	test   rsi,rsi
   238f0:	je     23906 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc96>
   238f2:	mov    rdi,QWORD PTR [rsp+0x8]
   238f7:	shl    rsi,0x3
   238fb:	mov    edx,0x8
   23900:	call   QWORD PTR [rip+0x668a2]        # 8a1a8 <_DYNAMIC+0x250>
   23906:	mov    rdi,rbx
   23909:	call   85c90 <_Unwind_Resume@plt>
