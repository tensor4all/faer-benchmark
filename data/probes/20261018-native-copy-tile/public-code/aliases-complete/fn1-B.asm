
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2de90:	push   rbp
   2de91:	push   r15
   2de93:	push   r14
   2de95:	push   r13
   2de97:	push   r12
   2de99:	push   rbx
   2de9a:	sub    rsp,0x78
   2de9e:	mov    r12,rcx
   2dea1:	mov    rbx,rdx
   2dea4:	mov    r15,rsi
   2dea7:	mov    QWORD PTR [rsp+0x20],rdi
   2deac:	lea    rdi,[rsp+0x28]
   2deb1:	call   2d690 <_RNvMs1_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtB5_6RawMatINtCskC1yiOI7W9g_11num_complex7ComplexdEE17try_with_capacityCskuD9mmv22aj_16owned_copy_probe>
   2deb6:	mov    rax,QWORD PTR [rsp+0x28]
   2debb:	mov    QWORD PTR [rsp+0x10],rax
   2dec0:	test   rax,rax
   2dec3:	je     2df70 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2dec9:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2dece:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2ded3:	mov    r14,QWORD PTR [rsp+0x30]
   2ded8:	mov    rax,QWORD PTR [rsp+0x40]
   2dedd:	mov    QWORD PTR [rsp+0x18],rax
   2dee2:	mov    rax,QWORD PTR [rsp+0x48]
   2dee7:	mov    QWORD PTR [rsp+0x8],rax
   2deec:	mov    QWORD PTR [rsp+0x28],r12
   2def1:	test   rbx,rbx
   2def4:	je     2df31 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xa1>
   2def6:	shl    r14,0x4
   2defa:	xor    r13d,r13d
   2defd:	lea    rbp,[rsp+0x28]
   2df02:	mov    r12,QWORD PTR [rsp+0x10]
   2df07:	nop    WORD PTR [rax+rax*1+0x0]
   2df10:	mov    rdi,r12
   2df13:	mov    rsi,r15
   2df16:	mov    rdx,r15
   2df19:	xor    ecx,ecx
   2df1b:	mov    r8,rbp
   2df1e:	mov    r9,r13
   2df21:	call   2cfc0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   2df26:	inc    r13
   2df29:	add    r12,r14
   2df2c:	cmp    rbx,r13
   2df2f:	jne    2df10 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x80>
   2df31:	mov    rax,QWORD PTR [rsp+0x20]
   2df36:	mov    rcx,QWORD PTR [rsp+0x10]
   2df3b:	mov    QWORD PTR [rax],rcx
   2df3e:	movaps xmm0,XMMWORD PTR [rsp+0x50]
   2df43:	movups XMMWORD PTR [rax+0x8],xmm0
   2df47:	mov    rcx,QWORD PTR [rsp+0x18]
   2df4c:	mov    QWORD PTR [rax+0x18],rcx
   2df50:	mov    rcx,QWORD PTR [rsp+0x8]
   2df55:	mov    QWORD PTR [rax+0x20],rcx
   2df59:	mov    QWORD PTR [rax+0x28],r15
   2df5d:	mov    QWORD PTR [rax+0x30],rbx
   2df61:	add    rsp,0x78
   2df65:	pop    rbx
   2df66:	pop    r12
   2df68:	pop    r13
   2df6a:	pop    r14
   2df6c:	pop    r15
   2df6e:	pop    rbp
   2df6f:	ret
   2df70:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2df75:	movups XMMWORD PTR [rsp+0x68],xmm0
   2df7a:	lea    rdi,[rip+0xfffffffffffdbd5a]        # 9cdb <anon.811c32b620528610c647b20c5efb1c6a.15.llvm.10716373653596490299>
   2df81:	lea    rcx,[rip+0x59278]        # 87200 <anon.811c32b620528610c647b20c5efb1c6a.14.llvm.10716373653596490299>
   2df88:	lea    r8,[rip+0x591d1]        # 87160 <anon.811c32b620528610c647b20c5efb1c6a.4.llvm.10716373653596490299>
   2df8f:	lea    rdx,[rsp+0x68]
   2df94:	mov    esi,0x2b
   2df99:	call   QWORD PTR [rip+0x5c271]        # 8a210 <_DYNAMIC+0x2b8>
   2df9f:	mov    rbx,rax
   2dfa2:	cmp    QWORD PTR [rsp+0x8],0x0
   2dfa8:	je     2dfbf <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x12f>
   2dfaa:	mov    rdi,QWORD PTR [rsp+0x10]
   2dfaf:	mov    rsi,QWORD PTR [rsp+0x8]
   2dfb4:	mov    rdx,QWORD PTR [rsp+0x18]
   2dfb9:	call   QWORD PTR [rip+0x5c1e9]        # 8a1a8 <_DYNAMIC+0x250>
   2dfbf:	mov    rdi,rbx
   2dfc2:	call   85c90 <_Unwind_Resume@plt>
