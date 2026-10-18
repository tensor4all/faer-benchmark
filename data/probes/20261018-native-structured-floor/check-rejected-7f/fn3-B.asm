
faer-benchmark/target/faer-rev/7f713a1401f1-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000238360 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  238360:	push   rbp
  238361:	push   r15
  238363:	push   r14
  238365:	push   r13
  238367:	push   r12
  238369:	push   rbx
  23836a:	sub    rsp,0x108
  238371:	mov    DWORD PTR [rsp+0x30],esi
  238375:	mov    r12,QWORD PTR [rdi+0x8]
  238379:	test   r12,r12
  23837c:	je     23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238382:	mov    r15,QWORD PTR [rdi+0x10]
  238386:	test   r15,r15
  238389:	je     23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  23838f:	mov    rbx,QWORD PTR [rdi]
  238392:	mov    r14,QWORD PTR [rdi+0x18]
  238396:	mov    rax,QWORD PTR [rdi+0x20]
  23839a:	mov    QWORD PTR [rsp+0x8],rax
  23839f:	mov    r13,QWORD PTR [rdx+0x10]
  2383a3:	test   r13,r13
  2383a6:	je     23845e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  2383ac:	mov    r11,r8
  2383af:	mov    DWORD PTR [rsp+0x38],ecx
  2383b3:	mov    rax,QWORD PTR [rdx]
  2383b6:	mov    QWORD PTR [rsp+0x10],rax
  2383bb:	mov    rcx,QWORD PTR [rdx+0x8]
  2383bf:	mov    r8,QWORD PTR [rdx+0x18]
  2383c3:	test   r14,r14
  2383c6:	mov    QWORD PTR [rsp+0x20],rcx
  2383cb:	jns    238409 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  2383cd:	lea    rax,[r12-0x1]
  2383d2:	imul   rax,r14
  2383d6:	neg    r14
  2383d9:	xor    edi,edi
  2383db:	mov    r10,rcx
  2383de:	sub    r10,0x1
  2383e2:	cmovb  r10,rdi
  2383e6:	lea    rbx,[rbx+rax*8]
  2383ea:	mov    rax,r8
  2383ed:	imul   rax,r10
  2383f1:	cmp    r10,rcx
  2383f4:	cmove  rax,rdi
  2383f8:	mov    rcx,QWORD PTR [rsp+0x10]
  2383fd:	lea    rcx,[rcx+rax*8]
  238401:	mov    QWORD PTR [rsp+0x10],rcx
  238406:	neg    r8
  238409:	mov    QWORD PTR [rsp+0x28],r8
  23840e:	mov    rdi,QWORD PTR [rdx+0x20]
  238412:	mov    r8,QWORD PTR [r11]
  238415:	mov    rax,QWORD PTR [r11+0x8]
  238419:	mov    QWORD PTR [rsp+0x18],rax
  23841e:	mov    rcx,QWORD PTR [r11+0x10]
  238422:	mov    rax,QWORD PTR [r11+0x20]
  238426:	cmp    QWORD PTR [rsp+0x8],0x0
  23842c:	js     2384b5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  238432:	mov    rsi,QWORD PTR [r11+0x18]
  238436:	test   rdi,rdi
  238439:	js     238521 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  23843f:	mov    r10,QWORD PTR [rsp+0x148]
  238447:	mov    r11,QWORD PTR [rsp+0x140]
  23844f:	cmp    r15,0x1
  238453:	je     2385a6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  238459:	jmp    238694 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  23845e:	cmp    BYTE PTR [rsp+0x30],0x0
  238463:	jne    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238469:	cmp    r12,0x1
  23846d:	je     238483 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  23846f:	cmp    r14,0xffffffffffffffff
  238473:	je     238be4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  238479:	cmp    r14,0x1
  23847d:	je     2389ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64e>
  238483:	cmp    r15,0x1
  238487:	je     2389a4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  23848d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  238493:	je     238d6a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0a>
  238499:	cmp    QWORD PTR [rsp+0x8],0x1
  23849f:	jne    2389a4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  2384a5:	mov    rax,r15
  2384a8:	mov    r15,r12
  2384ab:	mov    QWORD PTR [rsp+0x8],r14
  2384b0:	jmp    238d81 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  2384b5:	lea    rdx,[r15-0x1]
  2384b9:	mov    rsi,QWORD PTR [rsp+0x8]
  2384be:	imul   rdx,rsi
  2384c2:	lea    rbx,[rbx+rdx*8]
  2384c6:	neg    rsi
  2384c9:	mov    QWORD PTR [rsp+0x8],rsi
  2384ce:	xor    edx,edx
  2384d0:	mov    r10d,r9d
  2384d3:	mov    r9,r8
  2384d6:	mov    r8,rdi
  2384d9:	mov    rdi,rcx
  2384dc:	sub    rdi,0x1
  2384e0:	cmovb  rdi,rdx
  2384e4:	mov    rbp,r13
  2384e7:	mov    r13,rax
  2384ea:	imul   r13,rdi
  2384ee:	cmp    rdi,rcx
  2384f1:	mov    rdi,r8
  2384f4:	mov    r8,r9
  2384f7:	mov    r9d,r10d
  2384fa:	mov    r10,QWORD PTR [rsp+0x18]
  2384ff:	cmove  r13,rdx
  238503:	test   r10,r10
  238506:	cmove  r13,r10
  23850a:	lea    r8,[r8+r13*8]
  23850e:	mov    r13,rbp
  238511:	neg    rax
  238514:	mov    rsi,QWORD PTR [r11+0x18]
  238518:	test   rdi,rdi
  23851b:	jns    23843f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  238521:	lea    rdx,[r13-0x1]
  238525:	imul   rdx,rdi
  238529:	mov    r10,QWORD PTR [rsp+0x20]
  23852e:	test   r10,r10
  238531:	cmove  rdx,r10
  238535:	mov    r10,rax
  238538:	mov    rax,QWORD PTR [rsp+0x10]
  23853d:	lea    rax,[rax+rdx*8]
  238541:	mov    QWORD PTR [rsp+0x10],rax
  238546:	neg    rdi
  238549:	xor    edx,edx
  23854b:	mov    rax,rdi
  23854e:	mov    rbp,r13
  238551:	mov    r13,rsi
  238554:	mov    rsi,QWORD PTR [rsp+0x18]
  238559:	mov    rdi,rsi
  23855c:	sub    rdi,0x1
  238560:	cmovb  rdi,rdx
  238564:	mov    r11,r13
  238567:	imul   r11,rdi
  23856b:	test   rcx,rcx
  23856e:	cmove  r11,rcx
  238572:	cmp    rdi,rsi
  238575:	mov    rsi,r13
  238578:	mov    r13,rbp
  23857b:	mov    rdi,rax
  23857e:	mov    rax,r10
  238581:	cmove  r11,rdx
  238585:	lea    r8,[r8+r11*8]
  238589:	neg    rsi
  23858c:	mov    r10,QWORD PTR [rsp+0x148]
  238594:	mov    r11,QWORD PTR [rsp+0x140]
  23859c:	cmp    r15,0x1
  2385a0:	jne    238694 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  2385a6:	cmp    QWORD PTR [rsp+0x28],0x1
  2385ac:	jne    23861f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  2385ae:	cmp    r14,0x1
  2385b2:	jne    23861f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  2385b4:	test   rbx,rbx
  2385b7:	je     23861f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  2385b9:	mov    rax,QWORD PTR [rsp+0x10]
  2385be:	mov    QWORD PTR [rsp+0x78],rax
  2385c3:	mov    rax,QWORD PTR [rsp+0x20]
  2385c8:	mov    QWORD PTR [rsp+0x80],rax
  2385d0:	mov    QWORD PTR [rsp+0x88],r13
  2385d8:	mov    QWORD PTR [rsp+0x90],rdi
  2385e0:	mov    QWORD PTR [rsp+0x60],r8
  2385e5:	mov    rax,QWORD PTR [rsp+0x18]
  2385ea:	mov    QWORD PTR [rsp+0x68],rax
  2385ef:	mov    QWORD PTR [rsp+0x70],rsi
  2385f4:	sub    rsp,0x8
  2385f8:	movzx  eax,r9b
  2385fc:	movzx  edx,BYTE PTR [rsp+0x38]
  238601:	movzx  r8d,BYTE PTR [rsp+0x40]
  238607:	lea    rcx,[rsp+0x80]
  23860f:	lea    r9,[rsp+0x68]
  238614:	mov    rdi,rbx
  238617:	mov    rsi,r12
  23861a:	jmp    238710 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  23861f:	cmp    rdi,0x1
  238623:	jne    238694 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  238625:	cmp    rsi,0x1
  238629:	jne    238694 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  23862b:	test   r8,r8
  23862e:	je     238694 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  238630:	mov    rax,QWORD PTR [rsp+0x10]
  238635:	mov    QWORD PTR [rsp+0x78],rax
  23863a:	mov    rax,QWORD PTR [rsp+0x20]
  23863f:	mov    QWORD PTR [rsp+0x80],rax
  238647:	mov    QWORD PTR [rsp+0x88],r13
  23864f:	mov    rax,QWORD PTR [rsp+0x28]
  238654:	mov    QWORD PTR [rsp+0x90],rax
  23865c:	mov    QWORD PTR [rsp+0x60],rbx
  238661:	mov    QWORD PTR [rsp+0x68],r12
  238666:	mov    QWORD PTR [rsp+0x70],r14
  23866b:	sub    rsp,0x8
  23866f:	movzx  eax,r9b
  238673:	movzx  esi,BYTE PTR [rsp+0x38]
  238678:	movzx  ecx,BYTE PTR [rsp+0x40]
  23867d:	lea    rdi,[rsp+0x68]
  238682:	lea    rdx,[rsp+0x80]
  23868a:	mov    r9,QWORD PTR [rsp+0x20]
  23868f:	jmp    238797 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  238694:	cmp    r12,0x1
  238698:	jne    2387aa <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  23869e:	xor    edx,edx
  2386a0:	cmp    QWORD PTR [rsp+0x8],0x1
  2386a6:	cmove  rdx,rbx
  2386aa:	cmp    rax,0x1
  2386ae:	jne    238723 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  2386b0:	test   rdx,rdx
  2386b3:	je     238723 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  2386b5:	mov    QWORD PTR [rsp+0x78],r8
  2386ba:	mov    QWORD PTR [rsp+0x80],rcx
  2386c2:	mov    rax,QWORD PTR [rsp+0x18]
  2386c7:	mov    QWORD PTR [rsp+0x88],rax
  2386cf:	mov    QWORD PTR [rsp+0x90],rsi
  2386d7:	mov    rax,QWORD PTR [rsp+0x10]
  2386dc:	mov    QWORD PTR [rsp+0x60],rax
  2386e1:	mov    QWORD PTR [rsp+0x68],r13
  2386e6:	mov    QWORD PTR [rsp+0x70],rdi
  2386eb:	sub    rsp,0x8
  2386ef:	movzx  eax,BYTE PTR [rsp+0x40]
  2386f4:	movzx  edx,BYTE PTR [rsp+0x38]
  2386f9:	movzx  r8d,r9b
  2386fd:	lea    rcx,[rsp+0x80]
  238705:	lea    r9,[rsp+0x68]
  23870a:	mov    rdi,rbx
  23870d:	mov    rsi,r15
  238710:	push   r10
  238712:	push   r11
  238714:	push   rax
  238715:	call   14d830 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  23871a:	add    rsp,0x20
  23871e:	jmp    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238723:	xor    edx,edx
  238725:	cmp    rdi,0x1
  238729:	cmove  rdx,QWORD PTR [rsp+0x10]
  23872f:	cmp    rsi,0x1
  238733:	jne    2387aa <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  238735:	test   rdx,rdx
  238738:	je     2387aa <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  23873a:	mov    QWORD PTR [rsp+0x78],r8
  23873f:	mov    QWORD PTR [rsp+0x80],rcx
  238747:	mov    rcx,QWORD PTR [rsp+0x18]
  23874c:	mov    QWORD PTR [rsp+0x88],rcx
  238754:	mov    QWORD PTR [rsp+0x90],rax
  23875c:	mov    QWORD PTR [rsp+0x60],rbx
  238761:	mov    QWORD PTR [rsp+0x68],r15
  238766:	mov    rax,QWORD PTR [rsp+0x8]
  23876b:	mov    QWORD PTR [rsp+0x70],rax
  238770:	sub    rsp,0x8
  238774:	movzx  eax,BYTE PTR [rsp+0x40]
  238779:	movzx  esi,BYTE PTR [rsp+0x38]
  23877e:	movzx  ecx,r9b
  238782:	lea    rdi,[rsp+0x68]
  238787:	lea    rdx,[rsp+0x80]
  23878f:	mov    r8,QWORD PTR [rsp+0x18]
  238794:	mov    r9,r13
  238797:	push   r10
  238799:	push   r11
  23879b:	push   rax
  23879c:	call   19d380 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  2387a1:	add    rsp,0x20
  2387a5:	jmp    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  2387aa:	cmp    r13,0x1
  2387ae:	jne    2388b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  2387b4:	xor    edx,edx
  2387b6:	cmp    r14,0x1
  2387ba:	cmove  rdx,rbx
  2387be:	cmp    QWORD PTR [rsp+0x28],0x1
  2387c4:	jne    23882d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  2387c6:	test   rdx,rdx
  2387c9:	je     23882d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  2387cb:	mov    QWORD PTR [rsp+0x78],rdx
  2387d0:	mov    QWORD PTR [rsp+0x80],r12
  2387d8:	mov    QWORD PTR [rsp+0x88],r15
  2387e0:	mov    rdx,QWORD PTR [rsp+0x8]
  2387e5:	mov    QWORD PTR [rsp+0x90],rdx
  2387ed:	mov    QWORD PTR [rsp+0x60],r8
  2387f2:	mov    QWORD PTR [rsp+0x68],rcx
  2387f7:	mov    QWORD PTR [rsp+0x70],rax
  2387fc:	sub    rsp,0x8
  238800:	mov    r14,r10
  238803:	movzx  r10d,r9b
  238807:	movzx  esi,BYTE PTR [rsp+0x38]
  23880c:	movzx  r8d,BYTE PTR [rsp+0x40]
  238812:	lea    rdi,[rsp+0x80]
  23881a:	lea    r9,[rsp+0x68]
  23881f:	mov    rdx,QWORD PTR [rsp+0x18]
  238824:	mov    rcx,QWORD PTR [rsp+0x28]
  238829:	push   r14
  23882b:	jmp    2388a6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  23882d:	xor    edx,edx
  23882f:	cmp    QWORD PTR [rsp+0x8],0x1
  238835:	cmove  rdx,rbx
  238839:	cmp    rax,0x1
  23883d:	jne    2388b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  23883f:	test   rdx,rdx
  238842:	je     2388b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  238844:	mov    QWORD PTR [rsp+0x78],rdx
  238849:	mov    QWORD PTR [rsp+0x80],r15
  238851:	mov    QWORD PTR [rsp+0x88],r12
  238859:	mov    QWORD PTR [rsp+0x90],r14
  238861:	mov    rax,QWORD PTR [rsp+0x10]
  238866:	mov    QWORD PTR [rsp+0x60],rax
  23886b:	mov    rax,QWORD PTR [rsp+0x20]
  238870:	mov    QWORD PTR [rsp+0x68],rax
  238875:	mov    rax,QWORD PTR [rsp+0x28]
  23887a:	mov    QWORD PTR [rsp+0x70],rax
  23887f:	sub    rsp,0x8
  238883:	mov    rax,r10
  238886:	movzx  r10d,BYTE PTR [rsp+0x40]
  23888c:	movzx  esi,BYTE PTR [rsp+0x38]
  238891:	mov    rdx,r8
  238894:	movzx  r8d,r9b
  238898:	lea    rdi,[rsp+0x80]
  2388a0:	lea    r9,[rsp+0x68]
  2388a5:	push   rax
  2388a6:	push   r11
  2388a8:	push   r10
  2388aa:	call   14c850 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  2388af:	add    rsp,0x20
  2388b3:	jmp    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  2388b8:	mov    QWORD PTR [rsp+0x18],rax
  2388bd:	movsd  xmm1,QWORD PTR [r11]
  2388c2:	mov    rax,r12
  2388c5:	mul    r15
  2388c8:	mov    rbp,rax
  2388cb:	movsd  QWORD PTR [rsp+0x60],xmm1
  2388d1:	seto   r11b
  2388d5:	jo     238e05 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  2388db:	mul    r13
  2388de:	seto   cl
  2388e1:	not    cl
  2388e3:	cmp    rax,0x1001
  2388e9:	setb   al
  2388ec:	test   cl,al
  2388ee:	jne    23894b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5eb>
  2388f0:	mov    rdx,QWORD PTR [rip+0x311481]        # 549d78 <_DYNAMIC+0x450>
  2388f7:	mov    rax,QWORD PTR [rdx]
  2388fa:	test   rax,rax
  2388fd:	je     238e11 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  238903:	mov    cl,0x1
  238905:	test   eax,0x80000
  23890a:	jne    238f33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  238910:	mov    rax,QWORD PTR [rdx]
  238913:	test   rax,rax
  238916:	je     238e77 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb17>
  23891c:	test   ax,ax
  23891f:	jns    238938 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  238921:	mov    rax,QWORD PTR [rdx]
  238924:	test   rax,rax
  238927:	je     238ed9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb79>
  23892d:	bt     rax,0x37
  238932:	jb     238f31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd1>
  238938:	cmp    BYTE PTR [rsp+0x30],0x0
  23893d:	jne    238bec <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  238943:	xorps  xmm0,xmm0
  238946:	jmp    238bf4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  23894b:	cmp    BYTE PTR [rsp+0x30],0x0
  238950:	mov    eax,DWORD PTR [rsp+0x38]
  238954:	jne    2389b6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x656>
  238956:	xorps  xmm0,xmm0
  238959:	movsd  QWORD PTR [rsp+0x30],xmm0
  23895f:	cmp    QWORD PTR [rsp+0x8],r14
  238964:	jb     2389cb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66b>
  238966:	mov    ebp,r9d
  238969:	mov    r9d,eax
  23896c:	mov    rax,QWORD PTR [rsp+0x18]
  238971:	mov    QWORD PTR [rsp+0x38],rax
  238976:	mov    QWORD PTR [rsp+0x40],rsi
  23897b:	mov    QWORD PTR [rsp+0x58],r8
  238980:	mov    rsi,rdi
  238983:	mov    rax,QWORD PTR [rsp+0x28]
  238988:	mov    r8,QWORD PTR [rsp+0x10]
  23898d:	mov    rcx,QWORD PTR [rsp+0x8]
  238992:	mov    QWORD PTR [rsp+0x10],rcx
  238997:	mov    QWORD PTR [rsp+0x8],r14
  23899c:	mov    r14,r15
  23899f:	mov    r15,r12
  2389a2:	jmp    2389f3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x693>
  2389a4:	cmp    r14,0x1
  2389a8:	jne    238b1e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7be>
  2389ae:	mov    rax,r12
  2389b1:	jmp    238d81 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  2389b6:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe071ba]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  2389be:	movsd  QWORD PTR [rsp+0x30],xmm0
  2389c4:	cmp    QWORD PTR [rsp+0x8],r14
  2389c9:	jae    238966 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x606>
  2389cb:	mov    ebp,eax
  2389cd:	mov    rax,QWORD PTR [rsp+0x28]
  2389d2:	mov    QWORD PTR [rsp+0x38],rax
  2389d7:	mov    QWORD PTR [rsp+0x40],rdi
  2389dc:	mov    rax,QWORD PTR [rsp+0x10]
  2389e1:	mov    QWORD PTR [rsp+0x58],rax
  2389e6:	mov    QWORD PTR [rsp+0x10],r14
  2389eb:	mov    r14,r12
  2389ee:	mov    rax,QWORD PTR [rsp+0x18]
  2389f3:	movsd  QWORD PTR [rsp+0x20],xmm1
  2389f9:	mov    QWORD PTR [rsp+0x48],rsi
  2389fe:	mov    QWORD PTR [rsp+0x50],r8
  238a03:	mov    r12d,r9d
  238a06:	mov    QWORD PTR [rsp+0x18],rax
  238a0b:	cmp    rax,0x1
  238a0f:	jne    238a36 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  238a11:	cmp    QWORD PTR [rsp+0x8],0x1
  238a17:	jne    238a36 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  238a19:	lea    r8,[rip+0x3098b8]        # 5422d8 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x410>
  238a20:	lea    rdi,[rsp+0x78]
  238a25:	mov    rsi,r15
  238a28:	mov    rdx,r14
  238a2b:	mov    rcx,r13
  238a2e:	call   QWORD PTR [rip+0x31164c]        # 54a080 <_DYNAMIC+0x758>
  238a34:	jmp    238a51 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f1>
  238a36:	lea    r8,[rip+0x3098b3]        # 5422f0 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x428>
  238a3d:	lea    rdi,[rsp+0x78]
  238a42:	mov    rsi,r15
  238a45:	mov    rdx,r14
  238a48:	mov    rcx,r13
  238a4b:	call   QWORD PTR [rip+0x311637]        # 54a088 <_DYNAMIC+0x760>
  238a51:	lea    rdi,[rsp+0x80]
  238a59:	mov    rsi,QWORD PTR [rsp+0xa0]
  238a61:	mov    rdx,QWORD PTR [rsp+0xa8]
  238a69:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  238a71:	sub    rsp,0x70
  238a75:	movups XMMWORD PTR [rsp+0x58],xmm0
  238a7a:	movzx  eax,bpl
  238a7e:	mov    DWORD PTR [rsp+0x50],eax
  238a82:	movzx  eax,r12b
  238a86:	mov    DWORD PTR [rsp+0x48],eax
  238a8a:	mov    rax,QWORD PTR [rsp+0xa8]
  238a92:	mov    QWORD PTR [rsp+0x40],rax
  238a97:	mov    rax,QWORD PTR [rsp+0xb0]
  238a9f:	mov    QWORD PTR [rsp+0x38],rax
  238aa4:	mov    rax,QWORD PTR [rsp+0xc8]
  238aac:	mov    QWORD PTR [rsp+0x30],rax
  238ab1:	mov    rax,QWORD PTR [rsp+0xb8]
  238ab9:	mov    QWORD PTR [rsp+0x28],rax
  238abe:	mov    rax,QWORD PTR [rsp+0x88]
  238ac6:	mov    QWORD PTR [rsp+0x20],rax
  238acb:	mov    rax,QWORD PTR [rsp+0xc0]
  238ad3:	mov    QWORD PTR [rsp+0x18],rax
  238ad8:	mov    rax,QWORD PTR [rsp+0x80]
  238ae0:	mov    QWORD PTR [rsp+0x10],rax
  238ae5:	mov    rax,QWORD PTR [rsp+0x78]
  238aea:	mov    QWORD PTR [rsp+0x8],rax
  238aef:	mov    QWORD PTR [rsp],rbx
  238af3:	mov    r8,r14
  238af6:	mov    r9,r13
  238af9:	mov    rcx,r15
  238afc:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  238b05:	movsd  xmm1,QWORD PTR [rsp+0x90]
  238b0e:	call   QWORD PTR [rsp+0xe8]
  238b15:	add    rsp,0x70
  238b19:	jmp    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238b1e:	lea    rax,[r12-0x1]
  238b23:	mov    ecx,r12d
  238b26:	and    ecx,0x3
  238b29:	and    r12,0xfffffffffffffffc
  238b2d:	lea    rdx,[r14*8+0x0]
  238b35:	lea    rsi,[rdx+rdx*2]
  238b39:	shl    QWORD PTR [rsp+0x8],0x3
  238b3f:	mov    rdi,r14
  238b42:	shl    rdi,0x5
  238b46:	mov    r8,r14
  238b49:	shl    r8,0x4
  238b4d:	xor    r9d,r9d
  238b50:	jmp    238b71 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  238b52:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  238b60:	inc    r9
  238b63:	add    rbx,QWORD PTR [rsp+0x8]
  238b68:	cmp    r9,r15
  238b6b:	je     23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238b71:	cmp    rax,0x3
  238b75:	jae    238b80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  238b77:	xor    r10d,r10d
  238b7a:	jmp    238bc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  238b7c:	nop    DWORD PTR [rax+0x0]
  238b80:	mov    r11,rbx
  238b83:	xor    r10d,r10d
  238b86:	cs nop WORD PTR [rax+rax*1+0x0]
  238b90:	mov    QWORD PTR [r11],0x0
  238b97:	mov    QWORD PTR [r11+r14*8],0x0
  238b9f:	mov    QWORD PTR [r11+r8*1],0x0
  238ba7:	add    r10,0x4
  238bab:	mov    QWORD PTR [r11+rsi*1],0x0
  238bb3:	add    r11,rdi
  238bb6:	cmp    r12,r10
  238bb9:	jne    238b90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  238bbb:	test   rcx,rcx
  238bbe:	je     238b60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  238bc0:	imul   r10,rdx
  238bc4:	add    r10,rbx
  238bc7:	mov    r11,rcx
  238bca:	nop    WORD PTR [rax+rax*1+0x0]
  238bd0:	mov    QWORD PTR [r10],0x0
  238bd7:	add    r10,rdx
  238bda:	dec    r11
  238bdd:	jne    238bd0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  238bdf:	jmp    238b60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  238be4:	mov    rax,r12
  238be7:	jmp    238d75 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa15>
  238bec:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe06f84]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  238bf4:	xor    r11d,r11d
  238bf7:	test   r10,r10
  238bfa:	setne  dl
  238bfd:	cmp    QWORD PTR [rsp+0x8],r14
  238c02:	jge    238c19 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b9>
  238c04:	mov    rcx,QWORD PTR [rsp+0x18]
  238c09:	mov    rbp,rsi
  238c0c:	mov    rax,r8
  238c0f:	mov    r8,r14
  238c12:	mov    r9,QWORD PTR [rsp+0x28]
  238c17:	jmp    238c53 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f3>
  238c19:	mov    rcx,QWORD PTR [rsp+0x28]
  238c1e:	mov    rbp,rdi
  238c21:	mov    rax,QWORD PTR [rsp+0x10]
  238c26:	mov    QWORD PTR [rsp+0x28],rax
  238c2b:	mov    r10,QWORD PTR [rsp+0x8]
  238c30:	mov    rax,r12
  238c33:	mov    r9,QWORD PTR [rsp+0x18]
  238c38:	mov    rdi,rsi
  238c3b:	mov    QWORD PTR [rsp+0x10],r8
  238c40:	mov    r8,r10
  238c43:	mov    QWORD PTR [rsp+0x8],r14
  238c48:	mov    r12,r15
  238c4b:	mov    r15,rax
  238c4e:	mov    rax,QWORD PTR [rsp+0x28]
  238c53:	mov    r11b,dl
  238c56:	mov    QWORD PTR [rsp+0x18],r15
  238c5b:	lea    rdx,[r15-0x1]
  238c5f:	imul   rdx,rcx
  238c63:	mov    r14,rcx
  238c66:	neg    r14
  238c69:	mov    rsi,QWORD PTR [rsp+0x8]
  238c6e:	test   rsi,rsi
  238c71:	cmovns r14,rcx
  238c75:	mov    rcx,rsi
  238c78:	sar    rcx,0x3f
  238c7c:	and    rcx,rdx
  238c7f:	lea    rdx,[rax+rcx*8]
  238c83:	lea    rax,[r12-0x1]
  238c88:	imul   rax,r9
  238c8c:	mov    r15,r9
  238c8f:	neg    r15
  238c92:	test   r8,r8
  238c95:	cmovns r15,r9
  238c99:	mov    rcx,r8
  238c9c:	sar    rcx,0x3f
  238ca0:	and    rcx,rax
  238ca3:	mov    rax,QWORD PTR [rsp+0x10]
  238ca8:	lea    rsi,[rax+rcx*8]
  238cac:	test   rbp,rbp
  238caf:	jns    238cce <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x96e>
  238cb1:	lea    rax,[r13-0x1]
  238cb5:	mov    rcx,rbp
  238cb8:	imul   rcx,rax
  238cbc:	lea    rdx,[rdx+rcx*8]
  238cc0:	neg    rbp
  238cc3:	imul   rax,rdi
  238cc7:	lea    rsi,[rsi+rax*8]
  238ccb:	neg    rdi
  238cce:	mov    QWORD PTR [rsp+0x28],rsi
  238cd3:	mov    QWORD PTR [rsp+0x10],rdx
  238cd8:	mov    QWORD PTR [rsp+0x40],rdi
  238cdd:	mov    rax,QWORD PTR [rip+0x31133c]        # 54a020 <_DYNAMIC+0x6f8>
  238ce4:	mov    rax,QWORD PTR [rax]
  238ce7:	test   rax,rax
  238cea:	jne    238d24 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c4>
  238cec:	movsd  QWORD PTR [rsp+0x20],xmm1
  238cf2:	movsd  QWORD PTR [rsp+0x38],xmm0
  238cf8:	mov    QWORD PTR [rsp+0x50],rbp
  238cfd:	mov    rbp,r11
  238d00:	mov    QWORD PTR [rsp+0x48],r8
  238d05:	call   QWORD PTR [rip+0x31131d]        # 54a028 <_DYNAMIC+0x700>
  238d0b:	mov    r8,QWORD PTR [rsp+0x48]
  238d10:	mov    r11,rbp
  238d13:	mov    rbp,QWORD PTR [rsp+0x50]
  238d18:	movsd  xmm0,QWORD PTR [rsp+0x38]
  238d1e:	movsd  xmm1,QWORD PTR [rsp+0x20]
  238d24:	movzx  r10d,BYTE PTR [rsp+0x30]
  238d2a:	mov    rdi,QWORD PTR [rsp+0x18]
  238d2f:	mov    rsi,r12
  238d32:	mov    rdx,r13
  238d35:	mov    rcx,rbx
  238d38:	mov    r9,QWORD PTR [rsp+0x8]
  238d3d:	push   QWORD PTR [rsp+0x148]
  238d44:	push   r11
  238d46:	push   0x0
  238d48:	push   0x0
  238d4a:	push   0x0
  238d4c:	push   QWORD PTR [rsp+0x68]
  238d50:	push   r15
  238d52:	push   QWORD PTR [rsp+0x60]
  238d56:	push   r14
  238d58:	push   rbp
  238d59:	push   QWORD PTR [rsp+0x60]
  238d5d:	push   r10
  238d5f:	call   rax
  238d61:	add    rsp,0x60
  238d65:	jmp    23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238d6a:	mov    rax,r15
  238d6d:	mov    r15,r12
  238d70:	mov    QWORD PTR [rsp+0x8],r14
  238d75:	mov    ecx,0x1
  238d7a:	sub    rcx,rax
  238d7d:	lea    rbx,[rbx+rcx*8]
  238d81:	lea    rcx,[rax-0x1]
  238d85:	mov    edx,eax
  238d87:	and    edx,0x3
  238d8a:	and    rax,0xfffffffffffffffc
  238d8e:	xor    esi,esi
  238d90:	xorps  xmm0,xmm0
  238d93:	jmp    238dac <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  238d95:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  238da0:	inc    rsi
  238da3:	cmp    rsi,r15
  238da6:	je     23903d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcdd>
  238dac:	mov    rdi,rsi
  238daf:	imul   rdi,QWORD PTR [rsp+0x8]
  238db5:	lea    rdi,[rbx+rdi*8]
  238db9:	cmp    rcx,0x3
  238dbd:	jb     238de9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  238dbf:	xor    r8d,r8d
  238dc2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  238dd0:	movups XMMWORD PTR [rdi],xmm0
  238dd3:	movups XMMWORD PTR [rdi+0x10],xmm0
  238dd7:	add    rdi,0x20
  238ddb:	add    r8,0x4
  238ddf:	cmp    rax,r8
  238de2:	jne    238dd0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  238de4:	test   rdx,rdx
  238de7:	je     238da0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  238de9:	xor    r8d,r8d
  238dec:	nop    DWORD PTR [rax+0x0]
  238df0:	mov    QWORD PTR [rdi],0x0
  238df7:	add    rdi,0x8
  238dfb:	inc    r8
  238dfe:	cmp    rdx,r8
  238e01:	jne    238df0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  238e03:	jmp    238da0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  238e05:	mov    rax,0xffffffffffffffff
  238e0c:	jmp    2388db <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x57b>
  238e11:	mov    DWORD PTR [rsp+0x58],r9d
  238e16:	mov    QWORD PTR [rsp+0x40],rdi
  238e1b:	mov    QWORD PTR [rsp+0x50],r8
  238e20:	mov    QWORD PTR [rsp+0x48],rsi
  238e25:	movsd  QWORD PTR [rsp+0x20],xmm1
  238e2b:	mov    BYTE PTR [rsp+0x7],r11b
  238e30:	call   QWORD PTR [rip+0x310f4a]        # 549d80 <_DYNAMIC+0x458>
  238e36:	mov    rdx,QWORD PTR [rip+0x310f3b]        # 549d78 <_DYNAMIC+0x450>
  238e3d:	movzx  r11d,BYTE PTR [rsp+0x7]
  238e43:	movsd  xmm1,QWORD PTR [rsp+0x20]
  238e49:	mov    rsi,QWORD PTR [rsp+0x48]
  238e4e:	mov    r10,QWORD PTR [rsp+0x148]
  238e56:	mov    r8,QWORD PTR [rsp+0x50]
  238e5b:	mov    rdi,QWORD PTR [rsp+0x40]
  238e60:	mov    r9d,DWORD PTR [rsp+0x58]
  238e65:	mov    cl,0x1
  238e67:	test   eax,0x80000
  238e6c:	je     238910 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b0>
  238e72:	jmp    238f33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  238e77:	mov    DWORD PTR [rsp+0x58],r9d
  238e7c:	mov    QWORD PTR [rsp+0x40],rdi
  238e81:	mov    QWORD PTR [rsp+0x50],r8
  238e86:	mov    QWORD PTR [rsp+0x48],rsi
  238e8b:	movsd  QWORD PTR [rsp+0x20],xmm1
  238e91:	mov    BYTE PTR [rsp+0x7],r11b
  238e96:	call   QWORD PTR [rip+0x310ee4]        # 549d80 <_DYNAMIC+0x458>
  238e9c:	mov    rdx,QWORD PTR [rip+0x310ed5]        # 549d78 <_DYNAMIC+0x450>
  238ea3:	movzx  r11d,BYTE PTR [rsp+0x7]
  238ea9:	movsd  xmm1,QWORD PTR [rsp+0x20]
  238eaf:	mov    rsi,QWORD PTR [rsp+0x48]
  238eb4:	mov    r10,QWORD PTR [rsp+0x148]
  238ebc:	mov    r8,QWORD PTR [rsp+0x50]
  238ec1:	mov    rdi,QWORD PTR [rsp+0x40]
  238ec6:	mov    r9d,DWORD PTR [rsp+0x58]
  238ecb:	test   ax,ax
  238ece:	js     238921 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c1>
  238ed4:	jmp    238938 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  238ed9:	mov    DWORD PTR [rsp+0x58],r9d
  238ede:	mov    QWORD PTR [rsp+0x40],rdi
  238ee3:	mov    QWORD PTR [rsp+0x50],r8
  238ee8:	mov    QWORD PTR [rsp+0x48],rsi
  238eed:	movsd  QWORD PTR [rsp+0x20],xmm1
  238ef3:	mov    BYTE PTR [rsp+0x7],r11b
  238ef8:	call   QWORD PTR [rip+0x310e82]        # 549d80 <_DYNAMIC+0x458>
  238efe:	movzx  r11d,BYTE PTR [rsp+0x7]
  238f04:	movsd  xmm1,QWORD PTR [rsp+0x20]
  238f0a:	mov    rsi,QWORD PTR [rsp+0x48]
  238f0f:	mov    r10,QWORD PTR [rsp+0x148]
  238f17:	mov    r8,QWORD PTR [rsp+0x50]
  238f1c:	mov    rdi,QWORD PTR [rsp+0x40]
  238f21:	mov    r9d,DWORD PTR [rsp+0x58]
  238f26:	bt     rax,0x37
  238f2b:	jae    238938 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  238f31:	xor    ecx,ecx
  238f33:	mov    r10d,r9d
  238f36:	mov    r9,r8
  238f39:	mov    r8,rdi
  238f3c:	mov    rax,QWORD PTR [rip+0x310e4d]        # 549d90 <_DYNAMIC+0x468>
  238f43:	mov    rdi,QWORD PTR [rax]
  238f46:	test   r11b,r11b
  238f49:	jne    23904f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcef>
  238f4f:	mov    rax,rbp
  238f52:	mul    r13
  238f55:	jo     239062 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd02>
  238f5b:	mov    rdx,QWORD PTR [rsp+0x148]
  238f63:	cmp    rdx,0x1
  238f67:	adc    rdx,0x0
  238f6b:	cmp    rax,rdi
  238f6e:	mov    eax,0x1
  238f73:	cmovae rax,rdx
  238f77:	sub    rsp,0xa0
  238f7e:	lea    rdx,[rsp+0x100]
  238f86:	mov    QWORD PTR [rsp+0x88],rdx
  238f8e:	movzx  edx,r10b
  238f92:	mov    DWORD PTR [rsp+0x80],edx
  238f99:	mov    rdx,QWORD PTR [rsp+0xb8]
  238fa1:	mov    QWORD PTR [rsp+0x78],rdx
  238fa6:	mov    QWORD PTR [rsp+0x70],rsi
  238fab:	mov    QWORD PTR [rsp+0x68],r9
  238fb0:	xorps  xmm0,xmm0
  238fb3:	movups XMMWORD PTR [rsp+0x58],xmm0
  238fb8:	movzx  edx,BYTE PTR [rsp+0xd8]
  238fc0:	mov    DWORD PTR [rsp+0x50],edx
  238fc4:	mov    QWORD PTR [rsp+0x48],r8
  238fc9:	mov    rdx,QWORD PTR [rsp+0xc8]
  238fd1:	mov    QWORD PTR [rsp+0x40],rdx
  238fd6:	mov    rdx,QWORD PTR [rsp+0xb0]
  238fde:	mov    QWORD PTR [rsp+0x38],rdx
  238fe3:	movzx  edx,BYTE PTR [rsp+0xd0]
  238feb:	mov    DWORD PTR [rsp+0x30],edx
  238fef:	movups XMMWORD PTR [rsp+0x18],xmm0
  238ff4:	mov    rdx,QWORD PTR [rsp+0xa8]
  238ffc:	mov    QWORD PTR [rsp+0x10],rdx
  239001:	mov    QWORD PTR [rsp+0x8],r14
  239006:	mov    QWORD PTR [rsp],rbx
  23900a:	mov    QWORD PTR [rsp+0x90],rax
  239012:	mov    DWORD PTR [rsp+0x28],0x2
  23901a:	movzx  edx,cl
  23901d:	mov    r8,r15
  239020:	mov    edi,0x1
  239025:	mov    r9,r13
  239028:	mov    esi,0x1
  23902d:	mov    rcx,r12
  239030:	call   QWORD PTR [rip+0x310d52]        # 549d88 <_DYNAMIC+0x460>
  239036:	add    rsp,0xa0
  23903d:	add    rsp,0x108
  239044:	pop    rbx
  239045:	pop    r12
  239047:	pop    r13
  239049:	pop    r14
  23904b:	pop    r15
  23904d:	pop    rbp
  23904e:	ret
  23904f:	mov    rbp,0xffffffffffffffff
  239056:	mov    rax,rbp
  239059:	mul    r13
  23905c:	jno    238f5b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbfb>
  239062:	mov    rax,0xffffffffffffffff
  239069:	jmp    238f5b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbfb>
