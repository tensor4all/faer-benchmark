
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

00000000000257c0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_>:
   257c0:	push   rbp
   257c1:	push   r15
   257c3:	push   r14
   257c5:	push   r13
   257c7:	push   r12
   257c9:	push   rbx
   257ca:	sub    rsp,0x118
   257d1:	mov    r14,rsi
   257d4:	mov    QWORD PTR [rsp+0x100],rdi
   257dc:	call   QWORD PTR [rip+0x6433e]        # 89b20 <_DYNAMIC+0x2b0>
   257e2:	mov    QWORD PTR [rsp+0x108],rax
   257ea:	mov    DWORD PTR [rsp+0x110],edx
   257f1:	lea    rdi,[rsp+0x108]
   257f9:	call   QWORD PTR [rip+0x64329]        # 89b28 <_DYNAMIC+0x2b8>
   257ff:	test   rax,rax
   25802:	je     26072 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x8b2>
   25808:	call   QWORD PTR [rip+0x642d2]        # 89ae0 <_DYNAMIC+0x270>
   2580e:	mov    edi,0x28
   25813:	mov    esi,0x8
   25818:	call   QWORD PTR [rip+0x642ca]        # 89ae8 <_DYNAMIC+0x278>
   2581e:	test   rax,rax
   25821:	je     26222 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa62>
   25827:	mov    QWORD PTR [rsp],0x5
   2582f:	mov    QWORD PTR [rsp+0x8],rax
   25834:	mov    QWORD PTR [rsp+0x10],0x0
   2583d:	call   QWORD PTR [rip+0x642dd]        # 89b20 <_DYNAMIC+0x2b0>
   25843:	mov    QWORD PTR [rsp+0x88],rax
   2584b:	mov    DWORD PTR [rsp+0x90],edx
   25852:	mov    rax,QWORD PTR [r14+0x20]
   25856:	mov    QWORD PTR [rsp+0x70],rax
   2585b:	movups xmm0,XMMWORD PTR [r14]
   2585f:	movupd xmm1,XMMWORD PTR [r14+0x10]
   25865:	movapd XMMWORD PTR [rsp+0x60],xmm1
   2586b:	movaps XMMWORD PTR [rsp+0x50],xmm0
   25870:	lea    rax,[rsp+0x50]
   25875:	mov    rax,QWORD PTR [rsp+0x50]
   2587a:	mov    r15,QWORD PTR [rsp+0x58]
   2587f:	mov    rcx,QWORD PTR [rsp+0x70]
   25884:	mov    QWORD PTR [rsp+0xd0],rax
   2588c:	mov    QWORD PTR [rsp+0xd8],r15
   25894:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   2589a:	mov    r12,QWORD PTR [rsp+0x60]
   2589f:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   258a8:	mov    QWORD PTR [rsp+0xf0],rcx
   258b0:	lea    rdi,[rsp+0x18]
   258b5:	lea    rcx,[rsp+0xd0]
   258bd:	mov    rsi,r15
   258c0:	mov    rdx,r12
   258c3:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   258c8:	mov    rdi,QWORD PTR [rsp+0x40]
   258cd:	mov    rsi,QWORD PTR [rsp+0x48]
   258d2:	cmp    rdi,r15
   258d5:	jne    26232 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa72>
   258db:	cmp    rsi,r12
   258de:	jne    26232 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa72>
   258e4:	mov    rax,QWORD PTR [rsp+0x18]
   258e9:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   258ef:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   258f5:	mov    QWORD PTR [rsp+0x98],rax
   258fd:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25906:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2590f:	mov    QWORD PTR [rsp+0xc0],r15
   25917:	mov    QWORD PTR [rsp+0xc8],r12
   2591f:	lea    rax,[rsp+0x98]
   25927:	mov    rsi,QWORD PTR [rsp+0xb8]
   2592f:	test   rsi,rsi
   25932:	je     2594a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x18a>
   25934:	mov    rdi,QWORD PTR [rsp+0x98]
   2593c:	mov    rdx,QWORD PTR [rsp+0xb0]
   25944:	call   QWORD PTR [rip+0x64186]        # 89ad0 <_DYNAMIC+0x260>
   2594a:	lea    rdi,[rsp+0x88]
   25952:	call   QWORD PTR [rip+0x641d0]        # 89b28 <_DYNAMIC+0x2b8>
   25958:	mov    r15,rax
   2595b:	mov    ebx,edx
   2595d:	mov    r12,QWORD PTR [rsp+0x10]
   25962:	cmp    r12,QWORD PTR [rsp]
   25966:	jne    25970 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x1b0>
   25968:	mov    rdi,rsp
   2596b:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25970:	movq   xmm0,r15
   25975:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe74c3]        # ce40 <GCC_except_table145+0x74>
   2597d:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe745b]        # cde0 <GCC_except_table145+0x14>
   25985:	movapd xmm1,xmm0
   25989:	unpckhpd xmm1,xmm0
   2598d:	cvtsi2sd xmm2,ebx
   25991:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe7707]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25999:	addsd  xmm1,xmm0
   2599d:	addsd  xmm2,xmm1
   259a1:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe775f]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   259a9:	mov    rax,QWORD PTR [rsp+0x8]
   259ae:	movsd  QWORD PTR [rax+r12*8],xmm2
   259b4:	inc    r12
   259b7:	mov    QWORD PTR [rsp+0x10],r12
   259bc:	call   QWORD PTR [rip+0x6415e]        # 89b20 <_DYNAMIC+0x2b0>
   259c2:	mov    QWORD PTR [rsp+0x88],rax
   259ca:	mov    DWORD PTR [rsp+0x90],edx
   259d1:	mov    rax,QWORD PTR [r14+0x20]
   259d5:	mov    QWORD PTR [rsp+0x70],rax
   259da:	movups xmm0,XMMWORD PTR [r14]
   259de:	movupd xmm1,XMMWORD PTR [r14+0x10]
   259e4:	movapd XMMWORD PTR [rsp+0x60],xmm1
   259ea:	movaps XMMWORD PTR [rsp+0x50],xmm0
   259ef:	lea    rax,[rsp+0x50]
   259f4:	mov    rax,QWORD PTR [rsp+0x50]
   259f9:	mov    r15,QWORD PTR [rsp+0x58]
   259fe:	mov    rcx,QWORD PTR [rsp+0x70]
   25a03:	mov    QWORD PTR [rsp+0xd0],rax
   25a0b:	mov    QWORD PTR [rsp+0xd8],r15
   25a13:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   25a19:	mov    r12,QWORD PTR [rsp+0x60]
   25a1e:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   25a27:	mov    QWORD PTR [rsp+0xf0],rcx
   25a2f:	lea    rdi,[rsp+0x18]
   25a34:	lea    rcx,[rsp+0xd0]
   25a3c:	mov    rsi,r15
   25a3f:	mov    rdx,r12
   25a42:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   25a47:	mov    rdi,QWORD PTR [rsp+0x40]
   25a4c:	mov    rsi,QWORD PTR [rsp+0x48]
   25a51:	cmp    rdi,r15
   25a54:	jne    26274 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xab4>
   25a5a:	cmp    rsi,r12
   25a5d:	jne    26274 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xab4>
   25a63:	mov    rax,QWORD PTR [rsp+0x18]
   25a68:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   25a6e:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   25a74:	mov    QWORD PTR [rsp+0x98],rax
   25a7c:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25a85:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   25a8e:	mov    QWORD PTR [rsp+0xc0],r15
   25a96:	mov    QWORD PTR [rsp+0xc8],r12
   25a9e:	lea    rax,[rsp+0x98]
   25aa6:	mov    rsi,QWORD PTR [rsp+0xb8]
   25aae:	test   rsi,rsi
   25ab1:	je     25ac9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x309>
   25ab3:	mov    rdi,QWORD PTR [rsp+0x98]
   25abb:	mov    rdx,QWORD PTR [rsp+0xb0]
   25ac3:	call   QWORD PTR [rip+0x64007]        # 89ad0 <_DYNAMIC+0x260>
   25ac9:	lea    rdi,[rsp+0x88]
   25ad1:	call   QWORD PTR [rip+0x64051]        # 89b28 <_DYNAMIC+0x2b8>
   25ad7:	mov    r15,rax
   25ada:	mov    ebx,edx
   25adc:	mov    r12,QWORD PTR [rsp+0x10]
   25ae1:	cmp    r12,QWORD PTR [rsp]
   25ae5:	jne    25aef <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x32f>
   25ae7:	mov    rdi,rsp
   25aea:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25aef:	movq   xmm0,r15
   25af4:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7344]        # ce40 <GCC_except_table145+0x74>
   25afc:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe72dc]        # cde0 <GCC_except_table145+0x14>
   25b04:	movapd xmm1,xmm0
   25b08:	unpckhpd xmm1,xmm0
   25b0c:	cvtsi2sd xmm2,ebx
   25b10:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe7588]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25b18:	addsd  xmm1,xmm0
   25b1c:	addsd  xmm2,xmm1
   25b20:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe75e0]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   25b28:	mov    rax,QWORD PTR [rsp+0x8]
   25b2d:	movsd  QWORD PTR [rax+r12*8],xmm2
   25b33:	inc    r12
   25b36:	mov    QWORD PTR [rsp+0x10],r12
   25b3b:	call   QWORD PTR [rip+0x63fdf]        # 89b20 <_DYNAMIC+0x2b0>
   25b41:	mov    QWORD PTR [rsp+0x88],rax
   25b49:	mov    DWORD PTR [rsp+0x90],edx
   25b50:	mov    rax,QWORD PTR [r14+0x20]
   25b54:	mov    QWORD PTR [rsp+0x70],rax
   25b59:	movups xmm0,XMMWORD PTR [r14]
   25b5d:	movupd xmm1,XMMWORD PTR [r14+0x10]
   25b63:	movapd XMMWORD PTR [rsp+0x60],xmm1
   25b69:	movaps XMMWORD PTR [rsp+0x50],xmm0
   25b6e:	lea    rax,[rsp+0x50]
   25b73:	mov    rax,QWORD PTR [rsp+0x50]
   25b78:	mov    r15,QWORD PTR [rsp+0x58]
   25b7d:	mov    rcx,QWORD PTR [rsp+0x70]
   25b82:	mov    QWORD PTR [rsp+0xd0],rax
   25b8a:	mov    QWORD PTR [rsp+0xd8],r15
   25b92:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   25b98:	mov    r12,QWORD PTR [rsp+0x60]
   25b9d:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   25ba6:	mov    QWORD PTR [rsp+0xf0],rcx
   25bae:	lea    rdi,[rsp+0x18]
   25bb3:	lea    rcx,[rsp+0xd0]
   25bbb:	mov    rsi,r15
   25bbe:	mov    rdx,r12
   25bc1:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   25bc6:	mov    rdi,QWORD PTR [rsp+0x40]
   25bcb:	mov    rsi,QWORD PTR [rsp+0x48]
   25bd0:	cmp    rdi,r15
   25bd3:	jne    262b6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xaf6>
   25bd9:	cmp    rsi,r12
   25bdc:	jne    262b6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xaf6>
   25be2:	mov    rax,QWORD PTR [rsp+0x18]
   25be7:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   25bed:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   25bf3:	mov    QWORD PTR [rsp+0x98],rax
   25bfb:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25c04:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   25c0d:	mov    QWORD PTR [rsp+0xc0],r15
   25c15:	mov    QWORD PTR [rsp+0xc8],r12
   25c1d:	lea    rax,[rsp+0x98]
   25c25:	mov    rsi,QWORD PTR [rsp+0xb8]
   25c2d:	test   rsi,rsi
   25c30:	je     25c48 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x488>
   25c32:	mov    rdi,QWORD PTR [rsp+0x98]
   25c3a:	mov    rdx,QWORD PTR [rsp+0xb0]
   25c42:	call   QWORD PTR [rip+0x63e88]        # 89ad0 <_DYNAMIC+0x260>
   25c48:	lea    rdi,[rsp+0x88]
   25c50:	call   QWORD PTR [rip+0x63ed2]        # 89b28 <_DYNAMIC+0x2b8>
   25c56:	mov    r15,rax
   25c59:	mov    ebx,edx
   25c5b:	mov    r12,QWORD PTR [rsp+0x10]
   25c60:	cmp    r12,QWORD PTR [rsp]
   25c64:	jne    25c6e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x4ae>
   25c66:	mov    rdi,rsp
   25c69:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25c6e:	movq   xmm0,r15
   25c73:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe71c5]        # ce40 <GCC_except_table145+0x74>
   25c7b:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe715d]        # cde0 <GCC_except_table145+0x14>
   25c83:	movapd xmm1,xmm0
   25c87:	unpckhpd xmm1,xmm0
   25c8b:	cvtsi2sd xmm2,ebx
   25c8f:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe7409]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25c97:	addsd  xmm1,xmm0
   25c9b:	addsd  xmm2,xmm1
   25c9f:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe7461]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   25ca7:	mov    rax,QWORD PTR [rsp+0x8]
   25cac:	movsd  QWORD PTR [rax+r12*8],xmm2
   25cb2:	inc    r12
   25cb5:	mov    QWORD PTR [rsp+0x10],r12
   25cba:	call   QWORD PTR [rip+0x63e60]        # 89b20 <_DYNAMIC+0x2b0>
   25cc0:	mov    QWORD PTR [rsp+0x88],rax
   25cc8:	mov    DWORD PTR [rsp+0x90],edx
   25ccf:	mov    rax,QWORD PTR [r14+0x20]
   25cd3:	mov    QWORD PTR [rsp+0x70],rax
   25cd8:	movups xmm0,XMMWORD PTR [r14]
   25cdc:	movupd xmm1,XMMWORD PTR [r14+0x10]
   25ce2:	movapd XMMWORD PTR [rsp+0x60],xmm1
   25ce8:	movaps XMMWORD PTR [rsp+0x50],xmm0
   25ced:	lea    rax,[rsp+0x50]
   25cf2:	mov    rax,QWORD PTR [rsp+0x50]
   25cf7:	mov    r15,QWORD PTR [rsp+0x58]
   25cfc:	mov    rcx,QWORD PTR [rsp+0x70]
   25d01:	mov    QWORD PTR [rsp+0xd0],rax
   25d09:	mov    QWORD PTR [rsp+0xd8],r15
   25d11:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   25d17:	mov    r12,QWORD PTR [rsp+0x60]
   25d1c:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   25d25:	mov    QWORD PTR [rsp+0xf0],rcx
   25d2d:	lea    rdi,[rsp+0x18]
   25d32:	lea    rcx,[rsp+0xd0]
   25d3a:	mov    rsi,r15
   25d3d:	mov    rdx,r12
   25d40:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   25d45:	mov    rdi,QWORD PTR [rsp+0x40]
   25d4a:	mov    rsi,QWORD PTR [rsp+0x48]
   25d4f:	cmp    rdi,r15
   25d52:	jne    262f8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb38>
   25d58:	cmp    rsi,r12
   25d5b:	jne    262f8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb38>
   25d61:	mov    rax,QWORD PTR [rsp+0x18]
   25d66:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   25d6c:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   25d72:	mov    QWORD PTR [rsp+0x98],rax
   25d7a:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25d83:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   25d8c:	mov    QWORD PTR [rsp+0xc0],r15
   25d94:	mov    QWORD PTR [rsp+0xc8],r12
   25d9c:	lea    rax,[rsp+0x98]
   25da4:	mov    rsi,QWORD PTR [rsp+0xb8]
   25dac:	test   rsi,rsi
   25daf:	je     25dc7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x607>
   25db1:	mov    rdi,QWORD PTR [rsp+0x98]
   25db9:	mov    rdx,QWORD PTR [rsp+0xb0]
   25dc1:	call   QWORD PTR [rip+0x63d09]        # 89ad0 <_DYNAMIC+0x260>
   25dc7:	lea    rdi,[rsp+0x88]
   25dcf:	call   QWORD PTR [rip+0x63d53]        # 89b28 <_DYNAMIC+0x2b8>
   25dd5:	mov    r15,rax
   25dd8:	mov    ebx,edx
   25dda:	mov    r12,QWORD PTR [rsp+0x10]
   25ddf:	cmp    r12,QWORD PTR [rsp]
   25de3:	jne    25ded <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x62d>
   25de5:	mov    rdi,rsp
   25de8:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25ded:	movq   xmm0,r15
   25df2:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe7046]        # ce40 <GCC_except_table145+0x74>
   25dfa:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe6fde]        # cde0 <GCC_except_table145+0x14>
   25e02:	movapd xmm1,xmm0
   25e06:	unpckhpd xmm1,xmm0
   25e0a:	cvtsi2sd xmm2,ebx
   25e0e:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe728a]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25e16:	addsd  xmm1,xmm0
   25e1a:	addsd  xmm2,xmm1
   25e1e:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe72e2]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   25e26:	mov    rax,QWORD PTR [rsp+0x8]
   25e2b:	movsd  QWORD PTR [rax+r12*8],xmm2
   25e31:	inc    r12
   25e34:	mov    QWORD PTR [rsp+0x10],r12
   25e39:	call   QWORD PTR [rip+0x63ce1]        # 89b20 <_DYNAMIC+0x2b0>
   25e3f:	mov    QWORD PTR [rsp+0x88],rax
   25e47:	mov    DWORD PTR [rsp+0x90],edx
   25e4e:	mov    rax,QWORD PTR [r14+0x20]
   25e52:	mov    QWORD PTR [rsp+0x70],rax
   25e57:	movups xmm0,XMMWORD PTR [r14]
   25e5b:	movupd xmm1,XMMWORD PTR [r14+0x10]
   25e61:	movapd XMMWORD PTR [rsp+0x60],xmm1
   25e67:	movaps XMMWORD PTR [rsp+0x50],xmm0
   25e6c:	lea    rax,[rsp+0x50]
   25e71:	mov    rax,QWORD PTR [rsp+0x50]
   25e76:	mov    r14,QWORD PTR [rsp+0x58]
   25e7b:	mov    rcx,QWORD PTR [rsp+0x70]
   25e80:	mov    QWORD PTR [rsp+0xd0],rax
   25e88:	mov    QWORD PTR [rsp+0xd8],r14
   25e90:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   25e96:	mov    r15,QWORD PTR [rsp+0x60]
   25e9b:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   25ea4:	mov    QWORD PTR [rsp+0xf0],rcx
   25eac:	lea    rdi,[rsp+0x18]
   25eb1:	lea    rcx,[rsp+0xd0]
   25eb9:	mov    rsi,r14
   25ebc:	mov    rdx,r15
   25ebf:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   25ec4:	mov    rdi,QWORD PTR [rsp+0x40]
   25ec9:	mov    rsi,QWORD PTR [rsp+0x48]
   25ece:	cmp    rdi,r14
   25ed1:	jne    26337 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb77>
   25ed7:	cmp    rsi,r15
   25eda:	jne    26337 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb77>
   25ee0:	mov    rax,QWORD PTR [rsp+0x18]
   25ee5:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   25eeb:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   25ef1:	mov    QWORD PTR [rsp+0x98],rax
   25ef9:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   25f02:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   25f0b:	mov    QWORD PTR [rsp+0xc0],r14
   25f13:	mov    QWORD PTR [rsp+0xc8],r15
   25f1b:	lea    rax,[rsp+0x98]
   25f23:	mov    rsi,QWORD PTR [rsp+0xb8]
   25f2b:	test   rsi,rsi
   25f2e:	je     25f46 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x786>
   25f30:	mov    rdi,QWORD PTR [rsp+0x98]
   25f38:	mov    rdx,QWORD PTR [rsp+0xb0]
   25f40:	call   QWORD PTR [rip+0x63b8a]        # 89ad0 <_DYNAMIC+0x260>
   25f46:	lea    rdi,[rsp+0x88]
   25f4e:	call   QWORD PTR [rip+0x63bd4]        # 89b28 <_DYNAMIC+0x2b8>
   25f54:	mov    r14,rax
   25f57:	mov    ebx,edx
   25f59:	mov    rbp,QWORD PTR [rsp+0x10]
   25f5e:	cmp    rbp,QWORD PTR [rsp]
   25f62:	jne    25f6c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x7ac>
   25f64:	mov    rdi,rsp
   25f67:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   25f6c:	movq   xmm0,r14
   25f71:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe6ec7]        # ce40 <GCC_except_table145+0x74>
   25f79:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe6e5f]        # cde0 <GCC_except_table145+0x14>
   25f81:	movapd xmm1,xmm0
   25f85:	unpckhpd xmm1,xmm0
   25f89:	addsd  xmm1,xmm0
   25f8d:	xorps  xmm0,xmm0
   25f90:	cvtsi2sd xmm0,ebx
   25f94:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe7104]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   25f9c:	addsd  xmm0,xmm1
   25fa0:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe7160]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   25fa8:	mov    rax,QWORD PTR [rsp+0x8]
   25fad:	movsd  QWORD PTR [rax+rbp*8],xmm0
   25fb2:	lea    r12,[rbp+0x1]
   25fb6:	mov    QWORD PTR [rsp+0x10],r12
   25fbb:	lea    r13,[rbp*8+0x8]
   25fc3:	mov    rax,r12
   25fc6:	shr    rax,0x3d
   25fca:	setne  al
   25fcd:	movabs rcx,0x7ffffffffffffff8
   25fd7:	cmp    r13,rcx
   25fda:	seta   cl
   25fdd:	or     cl,al
   25fdf:	je     25ff5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x835>
   25fe1:	xor    r15d,r15d
   25fe4:	mov    rdi,r15
   25fe7:	mov    rsi,r13
   25fea:	call   QWORD PTR [rip+0x63b00]        # 89af0 <_DYNAMIC+0x280>
   25ff0:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   25ff5:	mov    rbx,QWORD PTR [rsp+0x8]
   25ffa:	test   r13,r13
   25ffd:	je     26193 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9d3>
   26003:	call   QWORD PTR [rip+0x63ad7]        # 89ae0 <_DYNAMIC+0x270>
   26009:	mov    r15d,0x8
   2600f:	mov    esi,0x8
   26014:	mov    rdi,r13
   26017:	call   QWORD PTR [rip+0x63acb]        # 89ae8 <_DYNAMIC+0x278>
   2601d:	test   rax,rax
   26020:	je     25fe4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x824>
   26022:	mov    r14,rax
   26025:	mov    r15,r12
   26028:	test   r12,r12
   2602b:	je     261a5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9e5>
   26031:	mov    rdi,r14
   26034:	mov    rsi,rbx
   26037:	mov    rdx,r13
   2603a:	call   QWORD PTR [rip+0x63ad0]        # 89b10 <memcpy@GLIBC_2.14>
   26040:	lea    rax,[rsp+0x87]
   26048:	mov    QWORD PTR [rsp+0x18],rax
   2604d:	mov    esi,0x1
   26052:	test   rbp,rbp
   26055:	jne    261ac <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9ec>
   2605b:	lea    rdx,[rip+0x605c6]        # 86628 <anon.2c393db9686f2344a1ccdcb44f907da6.0.llvm.13323335406852763521+0x18>
   26062:	mov    edi,0x2
   26067:	call   QWORD PTR [rip+0x63ac3]        # 89b30 <_DYNAMIC+0x2c0>
   2606d:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   26072:	lea    r15,[rsp+0x18]
   26077:	lea    r13,[rsp+0x108]
   2607f:	mov    r12,QWORD PTR [rip+0x63aa2]        # 89b28 <_DYNAMIC+0x2b8>
   26086:	cmp    edx,0xee6b280
   2608c:	jae    25808 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x48>
   26092:	mov    rax,QWORD PTR [r14+0x20]
   26096:	mov    QWORD PTR [rsp+0xf0],rax
   2609e:	movups xmm0,XMMWORD PTR [r14]
   260a2:	movups xmm1,XMMWORD PTR [r14+0x10]
   260a7:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   260af:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   260b7:	lea    rax,[rsp+0xd0]
   260bf:	mov    rax,QWORD PTR [rsp+0xd0]
   260c7:	mov    rbp,QWORD PTR [rsp+0xd8]
   260cf:	mov    rcx,QWORD PTR [rsp+0xf0]
   260d7:	mov    QWORD PTR [rsp+0x98],rax
   260df:	mov    QWORD PTR [rsp+0xa0],rbp
   260e7:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   260ef:	mov    rbx,QWORD PTR [rsp+0xe0]
   260f7:	movups XMMWORD PTR [rsp+0xa8],xmm0
   260ff:	mov    QWORD PTR [rsp+0xb8],rcx
   26107:	mov    rdi,r15
   2610a:	mov    rsi,rbp
   2610d:	mov    rdx,rbx
   26110:	lea    rcx,[rsp+0x98]
   26118:	call   2ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   2611d:	mov    rdi,QWORD PTR [rsp+0x40]
   26122:	mov    rsi,QWORD PTR [rsp+0x48]
   26127:	cmp    rdi,rbp
   2612a:	jne    26376 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbb6>
   26130:	cmp    rsi,rbx
   26133:	jne    26376 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbb6>
   26139:	mov    rax,QWORD PTR [rsp+0x18]
   2613e:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   26144:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2614a:	mov    QWORD PTR [rsp+0x18],rax
   2614f:	movupd XMMWORD PTR [rsp+0x20],xmm0
   26155:	movupd XMMWORD PTR [rsp+0x30],xmm1
   2615b:	mov    QWORD PTR [rsp+0x40],rbp
   26160:	mov    QWORD PTR [rsp+0x48],rbx
   26165:	mov    rsi,QWORD PTR [rsp+0x38]
   2616a:	test   rsi,rsi
   2616d:	je     2617f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9bf>
   2616f:	mov    rdi,QWORD PTR [rsp+0x18]
   26174:	mov    rdx,QWORD PTR [rsp+0x30]
   26179:	call   QWORD PTR [rip+0x63951]        # 89ad0 <_DYNAMIC+0x260>
   2617f:	mov    rdi,r13
   26182:	call   r12
   26185:	test   rax,rax
   26188:	je     26086 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x8c6>
   2618e:	jmp    25808 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x48>
   26193:	mov    r14d,0x8
   26199:	xor    r15d,r15d
   2619c:	test   r12,r12
   2619f:	jne    26031 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x871>
   261a5:	xor    esi,esi
   261a7:	jmp    2605b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x89b>
   261ac:	cmp    r12,0x15
   261b0:	jae    263b6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf6>
   261b6:	lea    rcx,[rsp+0x18]
   261bb:	mov    edx,0x1
   261c0:	mov    rdi,r14
   261c3:	mov    rsi,r12
   261c6:	call   34140 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   261cb:	cmp    r12,0x3
   261cf:	jb     263cb <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc0b>
   261d5:	movsd  xmm0,QWORD PTR [r14+0x10]
   261db:	mov    rax,QWORD PTR [rsp+0x10]
   261e0:	mov    rbx,QWORD PTR [rsp+0x100]
   261e8:	mov    QWORD PTR [rbx+0x18],rax
   261ec:	movups xmm1,XMMWORD PTR [rsp]
   261f0:	movups XMMWORD PTR [rbx+0x8],xmm1
   261f4:	movsd  QWORD PTR [rbx],xmm0
   261f8:	shl    r15,0x3
   261fc:	mov    edx,0x8
   26201:	mov    rdi,r14
   26204:	mov    rsi,r15
   26207:	call   QWORD PTR [rip+0x638c3]        # 89ad0 <_DYNAMIC+0x260>
   2620d:	mov    rax,rbx
   26210:	add    rsp,0x118
   26217:	pop    rbx
   26218:	pop    r12
   2621a:	pop    r13
   2621c:	pop    r14
   2621e:	pop    r15
   26220:	pop    rbp
   26221:	ret
   26222:	mov    edi,0x8
   26227:	mov    esi,0x28
   2622c:	call   QWORD PTR [rip+0x638be]        # 89af0 <_DYNAMIC+0x280>
   26232:	lea    rax,[rip+0x6054f]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   26239:	lea    r10,[rip+0xfffffffffffe6e50]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   26240:	lea    r11,[rip+0x60821]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   26247:	lea    rbx,[rip+0x608a2]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2624e:	mov    r8d,0x1
   26254:	mov    r9d,0x1
   2625a:	mov    rdx,r15
   2625d:	mov    rcx,r12
   26260:	push   rax
   26261:	push   r10
   26263:	push   r11
   26265:	push   rbx
   26266:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2626b:	add    rsp,0x20
   2626f:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   26274:	lea    rax,[rip+0x6050d]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   2627b:	lea    r10,[rip+0xfffffffffffe6e0e]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   26282:	lea    r11,[rip+0x607df]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   26289:	lea    rbx,[rip+0x60860]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   26290:	mov    r8d,0x1
   26296:	mov    r9d,0x1
   2629c:	mov    rdx,r15
   2629f:	mov    rcx,r12
   262a2:	push   rax
   262a3:	push   r10
   262a5:	push   r11
   262a7:	push   rbx
   262a8:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   262ad:	add    rsp,0x20
   262b1:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   262b6:	lea    rax,[rip+0x604cb]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   262bd:	lea    r10,[rip+0xfffffffffffe6dcc]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   262c4:	lea    r11,[rip+0x6079d]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   262cb:	lea    rbx,[rip+0x6081e]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   262d2:	mov    r8d,0x1
   262d8:	mov    r9d,0x1
   262de:	mov    rdx,r15
   262e1:	mov    rcx,r12
   262e4:	push   rax
   262e5:	push   r10
   262e7:	push   r11
   262e9:	push   rbx
   262ea:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   262ef:	add    rsp,0x20
   262f3:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   262f8:	lea    rax,[rip+0x60489]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   262ff:	lea    r10,[rip+0xfffffffffffe6d8a]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   26306:	lea    r11,[rip+0x6075b]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2630d:	lea    rbx,[rip+0x607dc]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   26314:	mov    r8d,0x1
   2631a:	mov    r9d,0x1
   26320:	mov    rdx,r15
   26323:	mov    rcx,r12
   26326:	push   rax
   26327:	push   r10
   26329:	push   r11
   2632b:	push   rbx
   2632c:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   26331:	add    rsp,0x20
   26335:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   26337:	lea    rax,[rip+0x6044a]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   2633e:	lea    r10,[rip+0xfffffffffffe6d4b]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   26345:	lea    r11,[rip+0x6071c]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2634c:	lea    rbx,[rip+0x6079d]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   26353:	mov    r8d,0x1
   26359:	mov    r9d,0x1
   2635f:	mov    rdx,r14
   26362:	mov    rcx,r15
   26365:	push   rax
   26366:	push   r10
   26368:	push   r11
   2636a:	push   rbx
   2636b:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   26370:	add    rsp,0x20
   26374:	jmp    263b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   26376:	lea    rax,[rip+0x6040b]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   2637d:	lea    r10,[rip+0xfffffffffffe6d0c]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   26384:	lea    r11,[rip+0x606dd]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2638b:	lea    r14,[rip+0x6075e]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   26392:	mov    r8d,0x1
   26398:	mov    r9d,0x1
   2639e:	mov    rdx,rbp
   263a1:	mov    rcx,rbx
   263a4:	push   rax
   263a5:	push   r10
   263a7:	push   r11
   263a9:	push   r14
   263ab:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   263b0:	add    rsp,0x20
   263b4:	ud2
   263b6:	lea    rdx,[rsp+0x18]
   263bb:	mov    rdi,r14
   263be:	mov    rsi,r12
   263c1:	call   33a70 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   263c6:	jmp    261d5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa15>
   263cb:	mov    esi,0x2
   263d0:	jmp    2605b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x89b>
   263d5:	mov    rbx,rax
   263d8:	mov    rsi,QWORD PTR [rsp+0x38]
   263dd:	test   rsi,rsi
   263e0:	je     26456 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc96>
   263e2:	mov    rdi,QWORD PTR [rsp+0x18]
   263e7:	mov    rdx,QWORD PTR [rsp+0x30]
   263ec:	jmp    26450 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc90>
   263ee:	jmp    263f6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   263f0:	jmp    263f6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   263f2:	jmp    263f6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   263f4:	jmp    263f6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   263f6:	mov    rbx,rax
   263f9:	mov    rsi,QWORD PTR [rsp+0x38]
   263fe:	test   rsi,rsi
   26401:	je     26439 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   26403:	mov    rdi,QWORD PTR [rsp+0x18]
   26408:	mov    rdx,QWORD PTR [rsp+0x30]
   2640d:	call   QWORD PTR [rip+0x636bd]        # 89ad0 <_DYNAMIC+0x260>
   26413:	jmp    26439 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   26415:	jmp    26436 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc76>
   26417:	mov    rbx,rax
   2641a:	test   r15,r15
   2641d:	je     26439 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   2641f:	shl    r15,0x3
   26423:	mov    edx,0x8
   26428:	mov    rdi,r14
   2642b:	mov    rsi,r15
   2642e:	call   QWORD PTR [rip+0x6369c]        # 89ad0 <_DYNAMIC+0x260>
   26434:	jmp    26439 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   26436:	mov    rbx,rax
   26439:	mov    rsi,QWORD PTR [rsp]
   2643d:	test   rsi,rsi
   26440:	je     26456 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc96>
   26442:	mov    rdi,QWORD PTR [rsp+0x8]
   26447:	shl    rsi,0x3
   2644b:	mov    edx,0x8
   26450:	call   QWORD PTR [rip+0x6367a]        # 89ad0 <_DYNAMIC+0x260>
   26456:	mov    rdi,rbx
   26459:	call   85590 <_Unwind_Resume@plt>
