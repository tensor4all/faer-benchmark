
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000024b40 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_>:
   24b40:	push   rbp
   24b41:	push   r15
   24b43:	push   r14
   24b45:	push   r13
   24b47:	push   r12
   24b49:	push   rbx
   24b4a:	sub    rsp,0x118
   24b51:	mov    r14,rsi
   24b54:	mov    QWORD PTR [rsp+0x100],rdi
   24b5c:	call   QWORD PTR [rip+0x64fbe]        # 89b20 <_DYNAMIC+0x2b0>
   24b62:	mov    QWORD PTR [rsp+0x108],rax
   24b6a:	mov    DWORD PTR [rsp+0x110],edx
   24b71:	lea    rdi,[rsp+0x108]
   24b79:	call   QWORD PTR [rip+0x64fa9]        # 89b28 <_DYNAMIC+0x2b8>
   24b7f:	test   rax,rax
   24b82:	je     253d4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x894>
   24b88:	call   QWORD PTR [rip+0x64f52]        # 89ae0 <_DYNAMIC+0x270>
   24b8e:	mov    edi,0x28
   24b93:	mov    esi,0x8
   24b98:	call   QWORD PTR [rip+0x64f4a]        # 89ae8 <_DYNAMIC+0x278>
   24b9e:	test   rax,rax
   24ba1:	je     2557e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa3e>
   24ba7:	mov    QWORD PTR [rsp],0x5
   24baf:	mov    QWORD PTR [rsp+0x8],rax
   24bb4:	mov    QWORD PTR [rsp+0x10],0x0
   24bbd:	call   QWORD PTR [rip+0x64f5d]        # 89b20 <_DYNAMIC+0x2b0>
   24bc3:	mov    QWORD PTR [rsp+0x88],rax
   24bcb:	mov    DWORD PTR [rsp+0x90],edx
   24bd2:	mov    rax,QWORD PTR [r14+0x20]
   24bd6:	mov    QWORD PTR [rsp+0x70],rax
   24bdb:	movups xmm0,XMMWORD PTR [r14]
   24bdf:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24be5:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24beb:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24bf0:	lea    rax,[rsp+0x50]
   24bf5:	mov    rax,QWORD PTR [rsp+0x50]
   24bfa:	mov    r15,QWORD PTR [rsp+0x58]
   24bff:	mov    rcx,QWORD PTR [rsp+0x70]
   24c04:	mov    QWORD PTR [rsp+0xd0],rax
   24c0c:	mov    QWORD PTR [rsp+0xd8],r15
   24c14:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24c1a:	mov    r12,QWORD PTR [rsp+0x60]
   24c1f:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24c28:	mov    QWORD PTR [rsp+0xf0],rcx
   24c30:	lea    rdi,[rsp+0x18]
   24c35:	lea    rsi,[rsp+0xd0]
   24c3d:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   24c42:	mov    rdi,QWORD PTR [rsp+0x40]
   24c47:	mov    rsi,QWORD PTR [rsp+0x48]
   24c4c:	cmp    rdi,r15
   24c4f:	jne    2558e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa4e>
   24c55:	cmp    rsi,r12
   24c58:	jne    2558e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa4e>
   24c5e:	mov    rax,QWORD PTR [rsp+0x18]
   24c63:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24c69:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24c6f:	mov    QWORD PTR [rsp+0x98],rax
   24c77:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24c80:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   24c89:	mov    QWORD PTR [rsp+0xc0],r15
   24c91:	mov    QWORD PTR [rsp+0xc8],r12
   24c99:	lea    rax,[rsp+0x98]
   24ca1:	mov    rsi,QWORD PTR [rsp+0xb8]
   24ca9:	test   rsi,rsi
   24cac:	je     24cc4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x184>
   24cae:	mov    rdi,QWORD PTR [rsp+0x98]
   24cb6:	mov    rdx,QWORD PTR [rsp+0xb0]
   24cbe:	call   QWORD PTR [rip+0x64e0c]        # 89ad0 <_DYNAMIC+0x260>
   24cc4:	lea    rdi,[rsp+0x88]
   24ccc:	call   QWORD PTR [rip+0x64e56]        # 89b28 <_DYNAMIC+0x2b8>
   24cd2:	mov    r15,rax
   24cd5:	mov    ebx,edx
   24cd7:	mov    r12,QWORD PTR [rsp+0x10]
   24cdc:	cmp    r12,QWORD PTR [rsp]
   24ce0:	jne    24cea <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x1aa>
   24ce2:	mov    rdi,rsp
   24ce5:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24cea:	movq   xmm0,r15
   24cef:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe8149]        # ce40 <GCC_except_table145+0x74>
   24cf7:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe80e1]        # cde0 <GCC_except_table145+0x14>
   24cff:	movapd xmm1,xmm0
   24d03:	unpckhpd xmm1,xmm0
   24d07:	cvtsi2sd xmm2,ebx
   24d0b:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe838d]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   24d13:	addsd  xmm1,xmm0
   24d17:	addsd  xmm2,xmm1
   24d1b:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe83e5]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24d23:	mov    rax,QWORD PTR [rsp+0x8]
   24d28:	movsd  QWORD PTR [rax+r12*8],xmm2
   24d2e:	inc    r12
   24d31:	mov    QWORD PTR [rsp+0x10],r12
   24d36:	call   QWORD PTR [rip+0x64de4]        # 89b20 <_DYNAMIC+0x2b0>
   24d3c:	mov    QWORD PTR [rsp+0x88],rax
   24d44:	mov    DWORD PTR [rsp+0x90],edx
   24d4b:	mov    rax,QWORD PTR [r14+0x20]
   24d4f:	mov    QWORD PTR [rsp+0x70],rax
   24d54:	movups xmm0,XMMWORD PTR [r14]
   24d58:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24d5e:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24d64:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24d69:	lea    rax,[rsp+0x50]
   24d6e:	mov    rax,QWORD PTR [rsp+0x50]
   24d73:	mov    r15,QWORD PTR [rsp+0x58]
   24d78:	mov    rcx,QWORD PTR [rsp+0x70]
   24d7d:	mov    QWORD PTR [rsp+0xd0],rax
   24d85:	mov    QWORD PTR [rsp+0xd8],r15
   24d8d:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24d93:	mov    r12,QWORD PTR [rsp+0x60]
   24d98:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24da1:	mov    QWORD PTR [rsp+0xf0],rcx
   24da9:	lea    rdi,[rsp+0x18]
   24dae:	lea    rsi,[rsp+0xd0]
   24db6:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   24dbb:	mov    rdi,QWORD PTR [rsp+0x40]
   24dc0:	mov    rsi,QWORD PTR [rsp+0x48]
   24dc5:	cmp    rdi,r15
   24dc8:	jne    255d0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa90>
   24dce:	cmp    rsi,r12
   24dd1:	jne    255d0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xa90>
   24dd7:	mov    rax,QWORD PTR [rsp+0x18]
   24ddc:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24de2:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24de8:	mov    QWORD PTR [rsp+0x98],rax
   24df0:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24df9:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   24e02:	mov    QWORD PTR [rsp+0xc0],r15
   24e0a:	mov    QWORD PTR [rsp+0xc8],r12
   24e12:	lea    rax,[rsp+0x98]
   24e1a:	mov    rsi,QWORD PTR [rsp+0xb8]
   24e22:	test   rsi,rsi
   24e25:	je     24e3d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x2fd>
   24e27:	mov    rdi,QWORD PTR [rsp+0x98]
   24e2f:	mov    rdx,QWORD PTR [rsp+0xb0]
   24e37:	call   QWORD PTR [rip+0x64c93]        # 89ad0 <_DYNAMIC+0x260>
   24e3d:	lea    rdi,[rsp+0x88]
   24e45:	call   QWORD PTR [rip+0x64cdd]        # 89b28 <_DYNAMIC+0x2b8>
   24e4b:	mov    r15,rax
   24e4e:	mov    ebx,edx
   24e50:	mov    r12,QWORD PTR [rsp+0x10]
   24e55:	cmp    r12,QWORD PTR [rsp]
   24e59:	jne    24e63 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x323>
   24e5b:	mov    rdi,rsp
   24e5e:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24e63:	movq   xmm0,r15
   24e68:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7fd0]        # ce40 <GCC_except_table145+0x74>
   24e70:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe7f68]        # cde0 <GCC_except_table145+0x14>
   24e78:	movapd xmm1,xmm0
   24e7c:	unpckhpd xmm1,xmm0
   24e80:	cvtsi2sd xmm2,ebx
   24e84:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe8214]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   24e8c:	addsd  xmm1,xmm0
   24e90:	addsd  xmm2,xmm1
   24e94:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe826c]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24e9c:	mov    rax,QWORD PTR [rsp+0x8]
   24ea1:	movsd  QWORD PTR [rax+r12*8],xmm2
   24ea7:	inc    r12
   24eaa:	mov    QWORD PTR [rsp+0x10],r12
   24eaf:	call   QWORD PTR [rip+0x64c6b]        # 89b20 <_DYNAMIC+0x2b0>
   24eb5:	mov    QWORD PTR [rsp+0x88],rax
   24ebd:	mov    DWORD PTR [rsp+0x90],edx
   24ec4:	mov    rax,QWORD PTR [r14+0x20]
   24ec8:	mov    QWORD PTR [rsp+0x70],rax
   24ecd:	movups xmm0,XMMWORD PTR [r14]
   24ed1:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24ed7:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24edd:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24ee2:	lea    rax,[rsp+0x50]
   24ee7:	mov    rax,QWORD PTR [rsp+0x50]
   24eec:	mov    r15,QWORD PTR [rsp+0x58]
   24ef1:	mov    rcx,QWORD PTR [rsp+0x70]
   24ef6:	mov    QWORD PTR [rsp+0xd0],rax
   24efe:	mov    QWORD PTR [rsp+0xd8],r15
   24f06:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24f0c:	mov    r12,QWORD PTR [rsp+0x60]
   24f11:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24f1a:	mov    QWORD PTR [rsp+0xf0],rcx
   24f22:	lea    rdi,[rsp+0x18]
   24f27:	lea    rsi,[rsp+0xd0]
   24f2f:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   24f34:	mov    rdi,QWORD PTR [rsp+0x40]
   24f39:	mov    rsi,QWORD PTR [rsp+0x48]
   24f3e:	cmp    rdi,r15
   24f41:	jne    25612 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xad2>
   24f47:	cmp    rsi,r12
   24f4a:	jne    25612 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xad2>
   24f50:	mov    rax,QWORD PTR [rsp+0x18]
   24f55:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24f5b:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24f61:	mov    QWORD PTR [rsp+0x98],rax
   24f69:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24f72:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   24f7b:	mov    QWORD PTR [rsp+0xc0],r15
   24f83:	mov    QWORD PTR [rsp+0xc8],r12
   24f8b:	lea    rax,[rsp+0x98]
   24f93:	mov    rsi,QWORD PTR [rsp+0xb8]
   24f9b:	test   rsi,rsi
   24f9e:	je     24fb6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x476>
   24fa0:	mov    rdi,QWORD PTR [rsp+0x98]
   24fa8:	mov    rdx,QWORD PTR [rsp+0xb0]
   24fb0:	call   QWORD PTR [rip+0x64b1a]        # 89ad0 <_DYNAMIC+0x260>
   24fb6:	lea    rdi,[rsp+0x88]
   24fbe:	call   QWORD PTR [rip+0x64b64]        # 89b28 <_DYNAMIC+0x2b8>
   24fc4:	mov    r15,rax
   24fc7:	mov    ebx,edx
   24fc9:	mov    r12,QWORD PTR [rsp+0x10]
   24fce:	cmp    r12,QWORD PTR [rsp]
   24fd2:	jne    24fdc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x49c>
   24fd4:	mov    rdi,rsp
   24fd7:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24fdc:	movq   xmm0,r15
   24fe1:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7e57]        # ce40 <GCC_except_table145+0x74>
   24fe9:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe7def]        # cde0 <GCC_except_table145+0x14>
   24ff1:	movapd xmm1,xmm0
   24ff5:	unpckhpd xmm1,xmm0
   24ff9:	cvtsi2sd xmm2,ebx
   24ffd:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe809b]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25005:	addsd  xmm1,xmm0
   25009:	addsd  xmm2,xmm1
   2500d:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe80f3]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   25015:	mov    rax,QWORD PTR [rsp+0x8]
   2501a:	movsd  QWORD PTR [rax+r12*8],xmm2
   25020:	inc    r12
   25023:	mov    QWORD PTR [rsp+0x10],r12
   25028:	call   QWORD PTR [rip+0x64af2]        # 89b20 <_DYNAMIC+0x2b0>
   2502e:	mov    QWORD PTR [rsp+0x88],rax
   25036:	mov    DWORD PTR [rsp+0x90],edx
   2503d:	mov    rax,QWORD PTR [r14+0x20]
   25041:	mov    QWORD PTR [rsp+0x70],rax
   25046:	movups xmm0,XMMWORD PTR [r14]
   2504a:	movupd xmm1,XMMWORD PTR [r14+0x10]
   25050:	movapd XMMWORD PTR [rsp+0x60],xmm1
   25056:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2505b:	lea    rax,[rsp+0x50]
   25060:	mov    rax,QWORD PTR [rsp+0x50]
   25065:	mov    r15,QWORD PTR [rsp+0x58]
   2506a:	mov    rcx,QWORD PTR [rsp+0x70]
   2506f:	mov    QWORD PTR [rsp+0xd0],rax
   25077:	mov    QWORD PTR [rsp+0xd8],r15
   2507f:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   25085:	mov    r12,QWORD PTR [rsp+0x60]
   2508a:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   25093:	mov    QWORD PTR [rsp+0xf0],rcx
   2509b:	lea    rdi,[rsp+0x18]
   250a0:	lea    rsi,[rsp+0xd0]
   250a8:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   250ad:	mov    rdi,QWORD PTR [rsp+0x40]
   250b2:	mov    rsi,QWORD PTR [rsp+0x48]
   250b7:	cmp    rdi,r15
   250ba:	jne    25654 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb14>
   250c0:	cmp    rsi,r12
   250c3:	jne    25654 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb14>
   250c9:	mov    rax,QWORD PTR [rsp+0x18]
   250ce:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   250d4:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   250da:	mov    QWORD PTR [rsp+0x98],rax
   250e2:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   250eb:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   250f4:	mov    QWORD PTR [rsp+0xc0],r15
   250fc:	mov    QWORD PTR [rsp+0xc8],r12
   25104:	lea    rax,[rsp+0x98]
   2510c:	mov    rsi,QWORD PTR [rsp+0xb8]
   25114:	test   rsi,rsi
   25117:	je     2512f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x5ef>
   25119:	mov    rdi,QWORD PTR [rsp+0x98]
   25121:	mov    rdx,QWORD PTR [rsp+0xb0]
   25129:	call   QWORD PTR [rip+0x649a1]        # 89ad0 <_DYNAMIC+0x260>
   2512f:	lea    rdi,[rsp+0x88]
   25137:	call   QWORD PTR [rip+0x649eb]        # 89b28 <_DYNAMIC+0x2b8>
   2513d:	mov    r15,rax
   25140:	mov    ebx,edx
   25142:	mov    r12,QWORD PTR [rsp+0x10]
   25147:	cmp    r12,QWORD PTR [rsp]
   2514b:	jne    25155 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x615>
   2514d:	mov    rdi,rsp
   25150:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25155:	movq   xmm0,r15
   2515a:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7cde]        # ce40 <GCC_except_table145+0x74>
   25162:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe7c76]        # cde0 <GCC_except_table145+0x14>
   2516a:	movapd xmm1,xmm0
   2516e:	unpckhpd xmm1,xmm0
   25172:	cvtsi2sd xmm2,ebx
   25176:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe7f22]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   2517e:	addsd  xmm1,xmm0
   25182:	addsd  xmm2,xmm1
   25186:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe7f7a]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   2518e:	mov    rax,QWORD PTR [rsp+0x8]
   25193:	movsd  QWORD PTR [rax+r12*8],xmm2
   25199:	inc    r12
   2519c:	mov    QWORD PTR [rsp+0x10],r12
   251a1:	call   QWORD PTR [rip+0x64979]        # 89b20 <_DYNAMIC+0x2b0>
   251a7:	mov    QWORD PTR [rsp+0x88],rax
   251af:	mov    DWORD PTR [rsp+0x90],edx
   251b6:	mov    rax,QWORD PTR [r14+0x20]
   251ba:	mov    QWORD PTR [rsp+0x70],rax
   251bf:	movups xmm0,XMMWORD PTR [r14]
   251c3:	movupd xmm1,XMMWORD PTR [r14+0x10]
   251c9:	movapd XMMWORD PTR [rsp+0x60],xmm1
   251cf:	movaps XMMWORD PTR [rsp+0x50],xmm0
   251d4:	lea    rax,[rsp+0x50]
   251d9:	mov    rax,QWORD PTR [rsp+0x50]
   251de:	mov    r14,QWORD PTR [rsp+0x58]
   251e3:	mov    rcx,QWORD PTR [rsp+0x70]
   251e8:	mov    QWORD PTR [rsp+0xd0],rax
   251f0:	mov    QWORD PTR [rsp+0xd8],r14
   251f8:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   251fe:	mov    r15,QWORD PTR [rsp+0x60]
   25203:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   2520c:	mov    QWORD PTR [rsp+0xf0],rcx
   25214:	lea    rdi,[rsp+0x18]
   25219:	lea    rsi,[rsp+0xd0]
   25221:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   25226:	mov    rdi,QWORD PTR [rsp+0x40]
   2522b:	mov    rsi,QWORD PTR [rsp+0x48]
   25230:	cmp    rdi,r14
   25233:	jne    25693 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb53>
   25239:	cmp    rsi,r15
   2523c:	jne    25693 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb53>
   25242:	mov    rax,QWORD PTR [rsp+0x18]
   25247:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2524d:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   25253:	mov    QWORD PTR [rsp+0x98],rax
   2525b:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25264:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2526d:	mov    QWORD PTR [rsp+0xc0],r14
   25275:	mov    QWORD PTR [rsp+0xc8],r15
   2527d:	lea    rax,[rsp+0x98]
   25285:	mov    rsi,QWORD PTR [rsp+0xb8]
   2528d:	test   rsi,rsi
   25290:	je     252a8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x768>
   25292:	mov    rdi,QWORD PTR [rsp+0x98]
   2529a:	mov    rdx,QWORD PTR [rsp+0xb0]
   252a2:	call   QWORD PTR [rip+0x64828]        # 89ad0 <_DYNAMIC+0x260>
   252a8:	lea    rdi,[rsp+0x88]
   252b0:	call   QWORD PTR [rip+0x64872]        # 89b28 <_DYNAMIC+0x2b8>
   252b6:	mov    r14,rax
   252b9:	mov    ebx,edx
   252bb:	mov    rbp,QWORD PTR [rsp+0x10]
   252c0:	cmp    rbp,QWORD PTR [rsp]
   252c4:	jne    252ce <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x78e>
   252c6:	mov    rdi,rsp
   252c9:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   252ce:	movq   xmm0,r14
   252d3:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7b65]        # ce40 <GCC_except_table145+0x74>
   252db:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe7afd]        # cde0 <GCC_except_table145+0x14>
   252e3:	movapd xmm1,xmm0
   252e7:	unpckhpd xmm1,xmm0
   252eb:	addsd  xmm1,xmm0
   252ef:	xorps  xmm0,xmm0
   252f2:	cvtsi2sd xmm0,ebx
   252f6:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe7da2]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   252fe:	addsd  xmm0,xmm1
   25302:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe7dfe]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   2530a:	mov    rax,QWORD PTR [rsp+0x8]
   2530f:	movsd  QWORD PTR [rax+rbp*8],xmm0
   25314:	lea    r12,[rbp+0x1]
   25318:	mov    QWORD PTR [rsp+0x10],r12
   2531d:	lea    r13,[rbp*8+0x8]
   25325:	mov    rax,r12
   25328:	shr    rax,0x3d
   2532c:	setne  al
   2532f:	movabs rcx,0x7ffffffffffffff8
   25339:	cmp    r13,rcx
   2533c:	seta   cl
   2533f:	or     cl,al
   25341:	je     25357 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x817>
   25343:	xor    r15d,r15d
   25346:	mov    rdi,r15
   25349:	mov    rsi,r13
   2534c:	call   QWORD PTR [rip+0x6479e]        # 89af0 <_DYNAMIC+0x280>
   25352:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   25357:	mov    rbx,QWORD PTR [rsp+0x8]
   2535c:	test   r13,r13
   2535f:	je     254ef <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9af>
   25365:	call   QWORD PTR [rip+0x64775]        # 89ae0 <_DYNAMIC+0x270>
   2536b:	mov    r15d,0x8
   25371:	mov    esi,0x8
   25376:	mov    rdi,r13
   25379:	call   QWORD PTR [rip+0x64769]        # 89ae8 <_DYNAMIC+0x278>
   2537f:	test   rax,rax
   25382:	je     25346 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x806>
   25384:	mov    r14,rax
   25387:	mov    r15,r12
   2538a:	test   r12,r12
   2538d:	je     25501 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9c1>
   25393:	mov    rdi,r14
   25396:	mov    rsi,rbx
   25399:	mov    rdx,r13
   2539c:	call   QWORD PTR [rip+0x6476e]        # 89b10 <memcpy@GLIBC_2.14>
   253a2:	lea    rax,[rsp+0x87]
   253aa:	mov    QWORD PTR [rsp+0x18],rax
   253af:	mov    esi,0x1
   253b4:	test   rbp,rbp
   253b7:	jne    25508 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9c8>
   253bd:	lea    rdx,[rip+0x61264]        # 86628 <anon.2c393db9686f2344a1ccdcb44f907da6.0.llvm.13323335406852763521+0x18>
   253c4:	mov    edi,0x2
   253c9:	call   QWORD PTR [rip+0x64761]        # 89b30 <_DYNAMIC+0x2c0>
   253cf:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   253d4:	lea    r15,[rsp+0x18]
   253d9:	lea    r13,[rsp+0x108]
   253e1:	mov    r12,QWORD PTR [rip+0x64740]        # 89b28 <_DYNAMIC+0x2b8>
   253e8:	cmp    edx,0xee6b280
   253ee:	jae    24b88 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x48>
   253f4:	mov    rax,QWORD PTR [r14+0x20]
   253f8:	mov    QWORD PTR [rsp+0xf0],rax
   25400:	movups xmm0,XMMWORD PTR [r14]
   25404:	movups xmm1,XMMWORD PTR [r14+0x10]
   25409:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   25411:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   25419:	lea    rax,[rsp+0xd0]
   25421:	mov    rax,QWORD PTR [rsp+0xd0]
   25429:	mov    rbp,QWORD PTR [rsp+0xd8]
   25431:	mov    rcx,QWORD PTR [rsp+0xf0]
   25439:	mov    QWORD PTR [rsp+0x98],rax
   25441:	mov    QWORD PTR [rsp+0xa0],rbp
   25449:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   25451:	mov    rbx,QWORD PTR [rsp+0xe0]
   25459:	movups XMMWORD PTR [rsp+0xa8],xmm0
   25461:	mov    QWORD PTR [rsp+0xb8],rcx
   25469:	mov    rdi,r15
   2546c:	lea    rsi,[rsp+0x98]
   25474:	call   26620 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impdiiECskuD9mmv22aj_16owned_copy_probe>
   25479:	mov    rdi,QWORD PTR [rsp+0x40]
   2547e:	mov    rsi,QWORD PTR [rsp+0x48]
   25483:	cmp    rdi,rbp
   25486:	jne    256d2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb92>
   2548c:	cmp    rsi,rbx
   2548f:	jne    256d2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xb92>
   25495:	mov    rax,QWORD PTR [rsp+0x18]
   2549a:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   254a0:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   254a6:	mov    QWORD PTR [rsp+0x18],rax
   254ab:	movupd XMMWORD PTR [rsp+0x20],xmm0
   254b1:	movupd XMMWORD PTR [rsp+0x30],xmm1
   254b7:	mov    QWORD PTR [rsp+0x40],rbp
   254bc:	mov    QWORD PTR [rsp+0x48],rbx
   254c1:	mov    rsi,QWORD PTR [rsp+0x38]
   254c6:	test   rsi,rsi
   254c9:	je     254db <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x99b>
   254cb:	mov    rdi,QWORD PTR [rsp+0x18]
   254d0:	mov    rdx,QWORD PTR [rsp+0x30]
   254d5:	call   QWORD PTR [rip+0x645f5]        # 89ad0 <_DYNAMIC+0x260>
   254db:	mov    rdi,r13
   254de:	call   r12
   254e1:	test   rax,rax
   254e4:	je     253e8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x8a8>
   254ea:	jmp    24b88 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x48>
   254ef:	mov    r14d,0x8
   254f5:	xor    r15d,r15d
   254f8:	test   r12,r12
   254fb:	jne    25393 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x853>
   25501:	xor    esi,esi
   25503:	jmp    253bd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x87d>
   25508:	cmp    r12,0x15
   2550c:	jae    25712 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd2>
   25512:	lea    rcx,[rsp+0x18]
   25517:	mov    edx,0x1
   2551c:	mov    rdi,r14
   2551f:	mov    rsi,r12
   25522:	call   34140 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   25527:	cmp    r12,0x3
   2552b:	jb     25727 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbe7>
   25531:	movsd  xmm0,QWORD PTR [r14+0x10]
   25537:	mov    rax,QWORD PTR [rsp+0x10]
   2553c:	mov    rbx,QWORD PTR [rsp+0x100]
   25544:	mov    QWORD PTR [rbx+0x18],rax
   25548:	movups xmm1,XMMWORD PTR [rsp]
   2554c:	movups XMMWORD PTR [rbx+0x8],xmm1
   25550:	movsd  QWORD PTR [rbx],xmm0
   25554:	shl    r15,0x3
   25558:	mov    edx,0x8
   2555d:	mov    rdi,r14
   25560:	mov    rsi,r15
   25563:	call   QWORD PTR [rip+0x64567]        # 89ad0 <_DYNAMIC+0x260>
   25569:	mov    rax,rbx
   2556c:	add    rsp,0x118
   25573:	pop    rbx
   25574:	pop    r12
   25576:	pop    r13
   25578:	pop    r14
   2557a:	pop    r15
   2557c:	pop    rbp
   2557d:	ret
   2557e:	mov    edi,0x8
   25583:	mov    esi,0x28
   25588:	call   QWORD PTR [rip+0x64562]        # 89af0 <_DYNAMIC+0x280>
   2558e:	lea    rax,[rip+0x6120b]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   25595:	lea    r10,[rip+0xfffffffffffe7af4]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   2559c:	lea    r11,[rip+0x614c5]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   255a3:	lea    rbx,[rip+0x61546]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   255aa:	mov    r8d,0x1
   255b0:	mov    r9d,0x1
   255b6:	mov    rdx,r15
   255b9:	mov    rcx,r12
   255bc:	push   rax
   255bd:	push   r10
   255bf:	push   r11
   255c1:	push   rbx
   255c2:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   255c7:	add    rsp,0x20
   255cb:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   255d0:	lea    rax,[rip+0x611c9]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   255d7:	lea    r10,[rip+0xfffffffffffe7ab2]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   255de:	lea    r11,[rip+0x61483]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   255e5:	lea    rbx,[rip+0x61504]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   255ec:	mov    r8d,0x1
   255f2:	mov    r9d,0x1
   255f8:	mov    rdx,r15
   255fb:	mov    rcx,r12
   255fe:	push   rax
   255ff:	push   r10
   25601:	push   r11
   25603:	push   rbx
   25604:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   25609:	add    rsp,0x20
   2560d:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   25612:	lea    rax,[rip+0x61187]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   25619:	lea    r10,[rip+0xfffffffffffe7a70]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   25620:	lea    r11,[rip+0x61441]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   25627:	lea    rbx,[rip+0x614c2]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2562e:	mov    r8d,0x1
   25634:	mov    r9d,0x1
   2563a:	mov    rdx,r15
   2563d:	mov    rcx,r12
   25640:	push   rax
   25641:	push   r10
   25643:	push   r11
   25645:	push   rbx
   25646:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2564b:	add    rsp,0x20
   2564f:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   25654:	lea    rax,[rip+0x61145]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   2565b:	lea    r10,[rip+0xfffffffffffe7a2e]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   25662:	lea    r11,[rip+0x613ff]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   25669:	lea    rbx,[rip+0x61480]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   25670:	mov    r8d,0x1
   25676:	mov    r9d,0x1
   2567c:	mov    rdx,r15
   2567f:	mov    rcx,r12
   25682:	push   rax
   25683:	push   r10
   25685:	push   r11
   25687:	push   rbx
   25688:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2568d:	add    rsp,0x20
   25691:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   25693:	lea    rax,[rip+0x61106]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   2569a:	lea    r10,[rip+0xfffffffffffe79ef]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   256a1:	lea    r11,[rip+0x613c0]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   256a8:	lea    rbx,[rip+0x61441]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   256af:	mov    r8d,0x1
   256b5:	mov    r9d,0x1
   256bb:	mov    rdx,r14
   256be:	mov    rcx,r15
   256c1:	push   rax
   256c2:	push   r10
   256c4:	push   r11
   256c6:	push   rbx
   256c7:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   256cc:	add    rsp,0x20
   256d0:	jmp    25710 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xbd0>
   256d2:	lea    rax,[rip+0x610c7]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   256d9:	lea    r10,[rip+0xfffffffffffe79b0]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   256e0:	lea    r11,[rip+0x61381]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   256e7:	lea    r14,[rip+0x61402]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   256ee:	mov    r8d,0x1
   256f4:	mov    r9d,0x1
   256fa:	mov    rdx,rbp
   256fd:	mov    rcx,rbx
   25700:	push   rax
   25701:	push   r10
   25703:	push   r11
   25705:	push   r14
   25707:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2570c:	add    rsp,0x20
   25710:	ud2
   25712:	lea    rdx,[rsp+0x18]
   25717:	mov    rdi,r14
   2571a:	mov    rsi,r12
   2571d:	call   33a70 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   25722:	jmp    25531 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x9f1>
   25727:	mov    esi,0x2
   2572c:	jmp    253bd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0x87d>
   25731:	mov    rbx,rax
   25734:	mov    rsi,QWORD PTR [rsp+0x38]
   25739:	test   rsi,rsi
   2573c:	je     257b2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc72>
   2573e:	mov    rdi,QWORD PTR [rsp+0x18]
   25743:	mov    rdx,QWORD PTR [rsp+0x30]
   25748:	jmp    257ac <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc6c>
   2574a:	jmp    25752 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc12>
   2574c:	jmp    25752 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc12>
   2574e:	jmp    25752 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc12>
   25750:	jmp    25752 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc12>
   25752:	mov    rbx,rax
   25755:	mov    rsi,QWORD PTR [rsp+0x38]
   2575a:	test   rsi,rsi
   2575d:	je     25795 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc55>
   2575f:	mov    rdi,QWORD PTR [rsp+0x18]
   25764:	mov    rdx,QWORD PTR [rsp+0x30]
   25769:	call   QWORD PTR [rip+0x64361]        # 89ad0 <_DYNAMIC+0x260>
   2576f:	jmp    25795 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc55>
   25771:	jmp    25792 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc52>
   25773:	mov    rbx,rax
   25776:	test   r15,r15
   25779:	je     25795 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc55>
   2577b:	shl    r15,0x3
   2577f:	mov    edx,0x8
   25784:	mov    rdi,r14
   25787:	mov    rsi,r15
   2578a:	call   QWORD PTR [rip+0x64340]        # 89ad0 <_DYNAMIC+0x260>
   25790:	jmp    25795 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc55>
   25792:	mov    rbx,rax
   25795:	mov    rsi,QWORD PTR [rsp]
   25799:	test   rsi,rsi
   2579c:	je     257b2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s0_0EB2_+0xc72>
   2579e:	mov    rdi,QWORD PTR [rsp+0x8]
   257a3:	shl    rsi,0x3
   257a7:	mov    edx,0x8
   257ac:	call   QWORD PTR [rip+0x6431e]        # 89ad0 <_DYNAMIC+0x260>
   257b2:	mov    rdi,rbx
   257b5:	call   85590 <_Unwind_Resume@plt>
