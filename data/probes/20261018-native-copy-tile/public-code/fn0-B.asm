
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2e4b0:	push   rbp
   2e4b1:	push   r15
   2e4b3:	push   r14
   2e4b5:	push   r13
   2e4b7:	push   r12
   2e4b9:	push   rbx
   2e4ba:	sub    rsp,0x78
   2e4be:	mov    r12,rcx
   2e4c1:	mov    rbx,rdx
   2e4c4:	mov    r15,rsi
   2e4c7:	mov    QWORD PTR [rsp+0x20],rdi
   2e4cc:	lea    rdi,[rsp+0x28]
   2e4d1:	call   2d750 <_RNvMs1_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtB5_6RawMatdE17try_with_capacityCskuD9mmv22aj_16owned_copy_probe>
   2e4d6:	mov    rax,QWORD PTR [rsp+0x28]
   2e4db:	mov    QWORD PTR [rsp+0x10],rax
   2e4e0:	test   rax,rax
   2e4e3:	je     2e590 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2e4e9:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2e4ee:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2e4f3:	mov    r14,QWORD PTR [rsp+0x30]
   2e4f8:	mov    rax,QWORD PTR [rsp+0x40]
   2e4fd:	mov    QWORD PTR [rsp+0x18],rax
   2e502:	mov    rax,QWORD PTR [rsp+0x48]
   2e507:	mov    QWORD PTR [rsp+0x8],rax
   2e50c:	mov    QWORD PTR [rsp+0x28],r12
   2e511:	test   rbx,rbx
   2e514:	je     2e551 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xa1>
   2e516:	shl    r14,0x3
   2e51a:	xor    r13d,r13d
   2e51d:	lea    rbp,[rsp+0x28]
   2e522:	mov    r12,QWORD PTR [rsp+0x10]
   2e527:	nop    WORD PTR [rax+rax*1+0x0]
   2e530:	mov    rdi,r12
   2e533:	mov    rsi,r15
   2e536:	mov    rdx,r15
   2e539:	xor    ecx,ecx
   2e53b:	mov    r8,rbp
   2e53e:	mov    r9,r13
   2e541:	call   2d290 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   2e546:	inc    r13
   2e549:	add    r12,r14
   2e54c:	cmp    rbx,r13
   2e54f:	jne    2e530 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x80>
   2e551:	mov    rax,QWORD PTR [rsp+0x20]
   2e556:	mov    rcx,QWORD PTR [rsp+0x10]
   2e55b:	mov    QWORD PTR [rax],rcx
   2e55e:	movaps xmm0,XMMWORD PTR [rsp+0x50]
   2e563:	movups XMMWORD PTR [rax+0x8],xmm0
   2e567:	mov    rcx,QWORD PTR [rsp+0x18]
   2e56c:	mov    QWORD PTR [rax+0x18],rcx
   2e570:	mov    rcx,QWORD PTR [rsp+0x8]
   2e575:	mov    QWORD PTR [rax+0x20],rcx
   2e579:	mov    QWORD PTR [rax+0x28],r15
   2e57d:	mov    QWORD PTR [rax+0x30],rbx
   2e581:	add    rsp,0x78
   2e585:	pop    rbx
   2e586:	pop    r12
   2e588:	pop    r13
   2e58a:	pop    r14
   2e58c:	pop    r15
   2e58e:	pop    rbp
   2e58f:	ret
   2e590:	movups xmm0,XMMWORD PTR [rsp+0x30]
   2e595:	movups XMMWORD PTR [rsp+0x68],xmm0
   2e59a:	lea    rdi,[rip+0xfffffffffffdb73a]        # 9cdb <anon.811c32b620528610c647b20c5efb1c6a.15.llvm.10716373653596490299>
   2e5a1:	lea    rcx,[rip+0x58c58]        # 87200 <anon.811c32b620528610c647b20c5efb1c6a.14.llvm.10716373653596490299>
   2e5a8:	lea    r8,[rip+0x58bb1]        # 87160 <anon.811c32b620528610c647b20c5efb1c6a.4.llvm.10716373653596490299>
   2e5af:	lea    rdx,[rsp+0x68]
   2e5b4:	mov    esi,0x2b
   2e5b9:	call   QWORD PTR [rip+0x5bc51]        # 8a210 <_DYNAMIC+0x2b8>
   2e5bf:	mov    rbx,rax
   2e5c2:	cmp    QWORD PTR [rsp+0x8],0x0
   2e5c8:	je     2e5df <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x12f>
   2e5ca:	mov    rdi,QWORD PTR [rsp+0x10]
   2e5cf:	mov    rsi,QWORD PTR [rsp+0x8]
   2e5d4:	mov    rdx,QWORD PTR [rsp+0x18]
   2e5d9:	call   QWORD PTR [rip+0x5bbc9]        # 8a1a8 <_DYNAMIC+0x250>
   2e5df:	mov    rdi,rbx
   2e5e2:	call   85c90 <_Unwind_Resume@plt>
