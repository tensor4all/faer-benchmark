
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2d790:	push   rbp
   2d791:	push   r15
   2d793:	push   r14
   2d795:	push   r13
   2d797:	push   r12
   2d799:	push   rbx
   2d79a:	sub    rsp,0x78
   2d79e:	mov    r12,rcx
   2d7a1:	mov    rbx,rdx
   2d7a4:	mov    r15,rsi
   2d7a7:	mov    QWORD PTR [rsp+0x20],rdi
   2d7ac:	lea    rdi,[rsp+0x28]
   2d7b1:	call   228e0 <_RNvMs1_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtB5_6RawMatINtCskC1yiOI7W9g_11num_complex7ComplexdEE17try_with_capacityCskuD9mmv22aj_16owned_copy_probe>
   2d7b6:	mov    rax,QWORD PTR [rsp+0x28]
   2d7bb:	mov    QWORD PTR [rsp+0x10],rax
   2d7c0:	test   rax,rax
   2d7c3:	je     2d870 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2d7c9:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2d7ce:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2d7d3:	mov    r14,QWORD PTR [rsp+0x30]
   2d7d8:	mov    rax,QWORD PTR [rsp+0x40]
   2d7dd:	mov    QWORD PTR [rsp+0x18],rax
   2d7e2:	mov    rax,QWORD PTR [rsp+0x48]
   2d7e7:	mov    QWORD PTR [rsp+0x8],rax
   2d7ec:	mov    QWORD PTR [rsp+0x28],r12
   2d7f1:	test   rbx,rbx
   2d7f4:	je     2d831 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xa1>
   2d7f6:	shl    r14,0x4
   2d7fa:	xor    r13d,r13d
   2d7fd:	lea    rbp,[rsp+0x28]
   2d802:	mov    r12,QWORD PTR [rsp+0x10]
   2d807:	nop    WORD PTR [rax+rax*1+0x0]
   2d810:	mov    rdi,r12
   2d813:	mov    rsi,r15
   2d816:	mov    rdx,r15
   2d819:	xor    ecx,ecx
   2d81b:	mov    r8,rbp
   2d81e:	mov    r9,r13
   2d821:	call   22260 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   2d826:	inc    r13
   2d829:	add    r12,r14
   2d82c:	cmp    rbx,r13
   2d82f:	jne    2d810 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x80>
   2d831:	mov    rax,QWORD PTR [rsp+0x20]
   2d836:	mov    rcx,QWORD PTR [rsp+0x10]
   2d83b:	mov    QWORD PTR [rax],rcx
   2d83e:	movaps xmm0,XMMWORD PTR [rsp+0x50]
   2d843:	movups XMMWORD PTR [rax+0x8],xmm0
   2d847:	mov    rcx,QWORD PTR [rsp+0x18]
   2d84c:	mov    QWORD PTR [rax+0x18],rcx
   2d850:	mov    rcx,QWORD PTR [rsp+0x8]
   2d855:	mov    QWORD PTR [rax+0x20],rcx
   2d859:	mov    QWORD PTR [rax+0x28],r15
   2d85d:	mov    QWORD PTR [rax+0x30],rbx
   2d861:	add    rsp,0x78
   2d865:	pop    rbx
   2d866:	pop    r12
   2d868:	pop    r13
   2d86a:	pop    r14
   2d86c:	pop    r15
   2d86e:	pop    rbp
   2d86f:	ret
   2d870:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2d875:	movups XMMWORD PTR [rsp+0x68],xmm0
   2d87a:	lea    rdi,[rip+0xfffffffffffe1b6a]        # f3eb <anon.811c32b620528610c647b20c5efb1c6a.15.llvm.10716373653596490299>
   2d881:	lea    rcx,[rip+0x59290]        # 86b18 <anon.811c32b620528610c647b20c5efb1c6a.14.llvm.10716373653596490299>
   2d888:	lea    r8,[rip+0x591e9]        # 86a78 <anon.811c32b620528610c647b20c5efb1c6a.4.llvm.10716373653596490299>
   2d88f:	lea    rdx,[rsp+0x68]
   2d894:	mov    esi,0x2b
   2d899:	call   QWORD PTR [rip+0x5c2c9]        # 89b68 <_DYNAMIC+0x2f8>
   2d89f:	mov    rbx,rax
   2d8a2:	cmp    QWORD PTR [rsp+0x8],0x0
   2d8a8:	je     2d8bf <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x12f>
   2d8aa:	mov    rdi,QWORD PTR [rsp+0x10]
   2d8af:	mov    rsi,QWORD PTR [rsp+0x8]
   2d8b4:	mov    rdx,QWORD PTR [rsp+0x18]
   2d8b9:	call   QWORD PTR [rip+0x5c211]        # 89ad0 <_DYNAMIC+0x260>
   2d8bf:	mov    rdi,rbx
   2d8c2:	call   85590 <_Unwind_Resume@plt>
