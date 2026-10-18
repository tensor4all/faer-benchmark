
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002ddb0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2ddb0:	push   rbp
   2ddb1:	push   r15
   2ddb3:	push   r14
   2ddb5:	push   r13
   2ddb7:	push   r12
   2ddb9:	push   rbx
   2ddba:	sub    rsp,0x78
   2ddbe:	mov    r12,rcx
   2ddc1:	mov    rbx,rdx
   2ddc4:	mov    r15,rsi
   2ddc7:	mov    QWORD PTR [rsp+0x20],rdi
   2ddcc:	lea    rdi,[rsp+0x28]
   2ddd1:	call   229a0 <_RNvMs1_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtB5_6RawMatdE17try_with_capacityCskuD9mmv22aj_16owned_copy_probe>
   2ddd6:	mov    rax,QWORD PTR [rsp+0x28]
   2dddb:	mov    QWORD PTR [rsp+0x10],rax
   2dde0:	test   rax,rax
   2dde3:	je     2de90 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2dde9:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2ddee:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2ddf3:	mov    r14,QWORD PTR [rsp+0x30]
   2ddf8:	mov    rax,QWORD PTR [rsp+0x40]
   2ddfd:	mov    QWORD PTR [rsp+0x18],rax
   2de02:	mov    rax,QWORD PTR [rsp+0x48]
   2de07:	mov    QWORD PTR [rsp+0x8],rax
   2de0c:	mov    QWORD PTR [rsp+0x28],r12
   2de11:	test   rbx,rbx
   2de14:	je     2de51 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xa1>
   2de16:	shl    r14,0x3
   2de1a:	xor    r13d,r13d
   2de1d:	lea    rbp,[rsp+0x28]
   2de22:	mov    r12,QWORD PTR [rsp+0x10]
   2de27:	nop    WORD PTR [rax+rax*1+0x0]
   2de30:	mov    rdi,r12
   2de33:	mov    rsi,r15
   2de36:	mov    rdx,r15
   2de39:	xor    ecx,ecx
   2de3b:	mov    r8,rbp
   2de3e:	mov    r9,r13
   2de41:	call   22530 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   2de46:	inc    r13
   2de49:	add    r12,r14
   2de4c:	cmp    rbx,r13
   2de4f:	jne    2de30 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x80>
   2de51:	mov    rax,QWORD PTR [rsp+0x20]
   2de56:	mov    rcx,QWORD PTR [rsp+0x10]
   2de5b:	mov    QWORD PTR [rax],rcx
   2de5e:	movaps xmm0,XMMWORD PTR [rsp+0x50]
   2de63:	movups XMMWORD PTR [rax+0x8],xmm0
   2de67:	mov    rcx,QWORD PTR [rsp+0x18]
   2de6c:	mov    QWORD PTR [rax+0x18],rcx
   2de70:	mov    rcx,QWORD PTR [rsp+0x8]
   2de75:	mov    QWORD PTR [rax+0x20],rcx
   2de79:	mov    QWORD PTR [rax+0x28],r15
   2de7d:	mov    QWORD PTR [rax+0x30],rbx
   2de81:	add    rsp,0x78
   2de85:	pop    rbx
   2de86:	pop    r12
   2de88:	pop    r13
   2de8a:	pop    r14
   2de8c:	pop    r15
   2de8e:	pop    rbp
   2de8f:	ret
   2de90:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2de95:	movups XMMWORD PTR [rsp+0x68],xmm0
   2de9a:	lea    rdi,[rip+0xfffffffffffe154a]        # f3eb <anon.811c32b620528610c647b20c5efb1c6a.15.llvm.10716373653596490299>
   2dea1:	lea    rcx,[rip+0x58c70]        # 86b18 <anon.811c32b620528610c647b20c5efb1c6a.14.llvm.10716373653596490299>
   2dea8:	lea    r8,[rip+0x58bc9]        # 86a78 <anon.811c32b620528610c647b20c5efb1c6a.4.llvm.10716373653596490299>
   2deaf:	lea    rdx,[rsp+0x68]
   2deb4:	mov    esi,0x2b
   2deb9:	call   QWORD PTR [rip+0x5bca9]        # 89b68 <_DYNAMIC+0x2f8>
   2debf:	mov    rbx,rax
   2dec2:	cmp    QWORD PTR [rsp+0x8],0x0
   2dec8:	je     2dedf <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x12f>
   2deca:	mov    rdi,QWORD PTR [rsp+0x10]
   2decf:	mov    rsi,QWORD PTR [rsp+0x8]
   2ded4:	mov    rdx,QWORD PTR [rsp+0x18]
   2ded9:	call   QWORD PTR [rip+0x5bbf1]        # 89ad0 <_DYNAMIC+0x260>
   2dedf:	mov    rdi,rbx
   2dee2:	call   85590 <_Unwind_Resume@plt>
