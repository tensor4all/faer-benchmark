
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/7f713a1401f1-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000022d320 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  22d320:	push   rbp
  22d321:	push   r15
  22d323:	push   r14
  22d325:	push   r13
  22d327:	push   r12
  22d329:	push   rbx
  22d32a:	sub    rsp,0x108
  22d331:	mov    DWORD PTR [rsp+0x30],esi
  22d335:	mov    r12,QWORD PTR [rdi+0x8]
  22d339:	test   r12,r12
  22d33c:	je     22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d342:	mov    r15,QWORD PTR [rdi+0x10]
  22d346:	test   r15,r15
  22d349:	je     22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d34f:	mov    rbx,QWORD PTR [rdi]
  22d352:	mov    r14,QWORD PTR [rdi+0x18]
  22d356:	mov    rax,QWORD PTR [rdi+0x20]
  22d35a:	mov    QWORD PTR [rsp+0x8],rax
  22d35f:	mov    r13,QWORD PTR [rdx+0x10]
  22d363:	test   r13,r13
  22d366:	je     22d41e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  22d36c:	mov    r11,r8
  22d36f:	mov    DWORD PTR [rsp+0x38],ecx
  22d373:	mov    rax,QWORD PTR [rdx]
  22d376:	mov    QWORD PTR [rsp+0x10],rax
  22d37b:	mov    rcx,QWORD PTR [rdx+0x8]
  22d37f:	mov    r8,QWORD PTR [rdx+0x18]
  22d383:	test   r14,r14
  22d386:	mov    QWORD PTR [rsp+0x20],rcx
  22d38b:	jns    22d3c9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  22d38d:	lea    rax,[r12-0x1]
  22d392:	imul   rax,r14
  22d396:	neg    r14
  22d399:	xor    edi,edi
  22d39b:	mov    r10,rcx
  22d39e:	sub    r10,0x1
  22d3a2:	cmovb  r10,rdi
  22d3a6:	lea    rbx,[rbx+rax*8]
  22d3aa:	mov    rax,r8
  22d3ad:	imul   rax,r10
  22d3b1:	cmp    r10,rcx
  22d3b4:	cmove  rax,rdi
  22d3b8:	mov    rcx,QWORD PTR [rsp+0x10]
  22d3bd:	lea    rcx,[rcx+rax*8]
  22d3c1:	mov    QWORD PTR [rsp+0x10],rcx
  22d3c6:	neg    r8
  22d3c9:	mov    QWORD PTR [rsp+0x28],r8
  22d3ce:	mov    rdi,QWORD PTR [rdx+0x20]
  22d3d2:	mov    r8,QWORD PTR [r11]
  22d3d5:	mov    rax,QWORD PTR [r11+0x8]
  22d3d9:	mov    QWORD PTR [rsp+0x18],rax
  22d3de:	mov    rcx,QWORD PTR [r11+0x10]
  22d3e2:	mov    rax,QWORD PTR [r11+0x20]
  22d3e6:	cmp    QWORD PTR [rsp+0x8],0x0
  22d3ec:	js     22d475 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  22d3f2:	mov    rsi,QWORD PTR [r11+0x18]
  22d3f6:	test   rdi,rdi
  22d3f9:	js     22d4e1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  22d3ff:	mov    r10,QWORD PTR [rsp+0x148]
  22d407:	mov    r11,QWORD PTR [rsp+0x140]
  22d40f:	cmp    r15,0x1
  22d413:	je     22d566 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  22d419:	jmp    22d654 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  22d41e:	cmp    BYTE PTR [rsp+0x30],0x0
  22d423:	jne    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d429:	cmp    r12,0x1
  22d42d:	je     22d443 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  22d42f:	cmp    r14,0xffffffffffffffff
  22d433:	je     22dba4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  22d439:	cmp    r14,0x1
  22d43d:	je     22d96d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64d>
  22d443:	cmp    r15,0x1
  22d447:	je     22d963 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  22d44d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  22d453:	je     22dd2a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0a>
  22d459:	cmp    QWORD PTR [rsp+0x8],0x1
  22d45f:	jne    22d963 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  22d465:	mov    rax,r15
  22d468:	mov    r15,r12
  22d46b:	mov    QWORD PTR [rsp+0x8],r14
  22d470:	jmp    22dd41 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  22d475:	lea    rdx,[r15-0x1]
  22d479:	mov    rsi,QWORD PTR [rsp+0x8]
  22d47e:	imul   rdx,rsi
  22d482:	lea    rbx,[rbx+rdx*8]
  22d486:	neg    rsi
  22d489:	mov    QWORD PTR [rsp+0x8],rsi
  22d48e:	xor    edx,edx
  22d490:	mov    r10d,r9d
  22d493:	mov    r9,r8
  22d496:	mov    r8,rdi
  22d499:	mov    rdi,rcx
  22d49c:	sub    rdi,0x1
  22d4a0:	cmovb  rdi,rdx
  22d4a4:	mov    rbp,r13
  22d4a7:	mov    r13,rax
  22d4aa:	imul   r13,rdi
  22d4ae:	cmp    rdi,rcx
  22d4b1:	mov    rdi,r8
  22d4b4:	mov    r8,r9
  22d4b7:	mov    r9d,r10d
  22d4ba:	mov    r10,QWORD PTR [rsp+0x18]
  22d4bf:	cmove  r13,rdx
  22d4c3:	test   r10,r10
  22d4c6:	cmove  r13,r10
  22d4ca:	lea    r8,[r8+r13*8]
  22d4ce:	mov    r13,rbp
  22d4d1:	neg    rax
  22d4d4:	mov    rsi,QWORD PTR [r11+0x18]
  22d4d8:	test   rdi,rdi
  22d4db:	jns    22d3ff <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  22d4e1:	lea    rdx,[r13-0x1]
  22d4e5:	imul   rdx,rdi
  22d4e9:	mov    r10,QWORD PTR [rsp+0x20]
  22d4ee:	test   r10,r10
  22d4f1:	cmove  rdx,r10
  22d4f5:	mov    r10,rax
  22d4f8:	mov    rax,QWORD PTR [rsp+0x10]
  22d4fd:	lea    rax,[rax+rdx*8]
  22d501:	mov    QWORD PTR [rsp+0x10],rax
  22d506:	neg    rdi
  22d509:	xor    edx,edx
  22d50b:	mov    rax,rdi
  22d50e:	mov    rbp,r13
  22d511:	mov    r13,rsi
  22d514:	mov    rsi,QWORD PTR [rsp+0x18]
  22d519:	mov    rdi,rsi
  22d51c:	sub    rdi,0x1
  22d520:	cmovb  rdi,rdx
  22d524:	mov    r11,r13
  22d527:	imul   r11,rdi
  22d52b:	test   rcx,rcx
  22d52e:	cmove  r11,rcx
  22d532:	cmp    rdi,rsi
  22d535:	mov    rsi,r13
  22d538:	mov    r13,rbp
  22d53b:	mov    rdi,rax
  22d53e:	mov    rax,r10
  22d541:	cmove  r11,rdx
  22d545:	lea    r8,[r8+r11*8]
  22d549:	neg    rsi
  22d54c:	mov    r10,QWORD PTR [rsp+0x148]
  22d554:	mov    r11,QWORD PTR [rsp+0x140]
  22d55c:	cmp    r15,0x1
  22d560:	jne    22d654 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  22d566:	cmp    QWORD PTR [rsp+0x28],0x1
  22d56c:	jne    22d5df <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  22d56e:	cmp    r14,0x1
  22d572:	jne    22d5df <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  22d574:	test   rbx,rbx
  22d577:	je     22d5df <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  22d579:	mov    rax,QWORD PTR [rsp+0x10]
  22d57e:	mov    QWORD PTR [rsp+0x78],rax
  22d583:	mov    rax,QWORD PTR [rsp+0x20]
  22d588:	mov    QWORD PTR [rsp+0x80],rax
  22d590:	mov    QWORD PTR [rsp+0x88],r13
  22d598:	mov    QWORD PTR [rsp+0x90],rdi
  22d5a0:	mov    QWORD PTR [rsp+0x60],r8
  22d5a5:	mov    rax,QWORD PTR [rsp+0x18]
  22d5aa:	mov    QWORD PTR [rsp+0x68],rax
  22d5af:	mov    QWORD PTR [rsp+0x70],rsi
  22d5b4:	sub    rsp,0x8
  22d5b8:	movzx  eax,r9b
  22d5bc:	movzx  edx,BYTE PTR [rsp+0x38]
  22d5c1:	movzx  r8d,BYTE PTR [rsp+0x40]
  22d5c7:	lea    rcx,[rsp+0x80]
  22d5cf:	lea    r9,[rsp+0x68]
  22d5d4:	mov    rdi,rbx
  22d5d7:	mov    rsi,r12
  22d5da:	jmp    22d6d0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  22d5df:	cmp    rdi,0x1
  22d5e3:	jne    22d654 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  22d5e5:	cmp    rsi,0x1
  22d5e9:	jne    22d654 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  22d5eb:	test   r8,r8
  22d5ee:	je     22d654 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  22d5f0:	mov    rax,QWORD PTR [rsp+0x10]
  22d5f5:	mov    QWORD PTR [rsp+0x78],rax
  22d5fa:	mov    rax,QWORD PTR [rsp+0x20]
  22d5ff:	mov    QWORD PTR [rsp+0x80],rax
  22d607:	mov    QWORD PTR [rsp+0x88],r13
  22d60f:	mov    rax,QWORD PTR [rsp+0x28]
  22d614:	mov    QWORD PTR [rsp+0x90],rax
  22d61c:	mov    QWORD PTR [rsp+0x60],rbx
  22d621:	mov    QWORD PTR [rsp+0x68],r12
  22d626:	mov    QWORD PTR [rsp+0x70],r14
  22d62b:	sub    rsp,0x8
  22d62f:	movzx  eax,r9b
  22d633:	movzx  esi,BYTE PTR [rsp+0x38]
  22d638:	movzx  ecx,BYTE PTR [rsp+0x40]
  22d63d:	lea    rdi,[rsp+0x68]
  22d642:	lea    rdx,[rsp+0x80]
  22d64a:	mov    r9,QWORD PTR [rsp+0x20]
  22d64f:	jmp    22d757 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  22d654:	cmp    r12,0x1
  22d658:	jne    22d76a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  22d65e:	xor    edx,edx
  22d660:	cmp    QWORD PTR [rsp+0x8],0x1
  22d666:	cmove  rdx,rbx
  22d66a:	cmp    rax,0x1
  22d66e:	jne    22d6e3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  22d670:	test   rdx,rdx
  22d673:	je     22d6e3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  22d675:	mov    QWORD PTR [rsp+0x78],r8
  22d67a:	mov    QWORD PTR [rsp+0x80],rcx
  22d682:	mov    rax,QWORD PTR [rsp+0x18]
  22d687:	mov    QWORD PTR [rsp+0x88],rax
  22d68f:	mov    QWORD PTR [rsp+0x90],rsi
  22d697:	mov    rax,QWORD PTR [rsp+0x10]
  22d69c:	mov    QWORD PTR [rsp+0x60],rax
  22d6a1:	mov    QWORD PTR [rsp+0x68],r13
  22d6a6:	mov    QWORD PTR [rsp+0x70],rdi
  22d6ab:	sub    rsp,0x8
  22d6af:	movzx  eax,BYTE PTR [rsp+0x40]
  22d6b4:	movzx  edx,BYTE PTR [rsp+0x38]
  22d6b9:	movzx  r8d,r9b
  22d6bd:	lea    rcx,[rsp+0x80]
  22d6c5:	lea    r9,[rsp+0x68]
  22d6ca:	mov    rdi,rbx
  22d6cd:	mov    rsi,r15
  22d6d0:	push   r10
  22d6d2:	push   r11
  22d6d4:	push   rax
  22d6d5:	call   14b9a0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  22d6da:	add    rsp,0x20
  22d6de:	jmp    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d6e3:	xor    edx,edx
  22d6e5:	cmp    rdi,0x1
  22d6e9:	cmove  rdx,QWORD PTR [rsp+0x10]
  22d6ef:	cmp    rsi,0x1
  22d6f3:	jne    22d76a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  22d6f5:	test   rdx,rdx
  22d6f8:	je     22d76a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  22d6fa:	mov    QWORD PTR [rsp+0x78],r8
  22d6ff:	mov    QWORD PTR [rsp+0x80],rcx
  22d707:	mov    rcx,QWORD PTR [rsp+0x18]
  22d70c:	mov    QWORD PTR [rsp+0x88],rcx
  22d714:	mov    QWORD PTR [rsp+0x90],rax
  22d71c:	mov    QWORD PTR [rsp+0x60],rbx
  22d721:	mov    QWORD PTR [rsp+0x68],r15
  22d726:	mov    rax,QWORD PTR [rsp+0x8]
  22d72b:	mov    QWORD PTR [rsp+0x70],rax
  22d730:	sub    rsp,0x8
  22d734:	movzx  eax,BYTE PTR [rsp+0x40]
  22d739:	movzx  esi,BYTE PTR [rsp+0x38]
  22d73e:	movzx  ecx,r9b
  22d742:	lea    rdi,[rsp+0x68]
  22d747:	lea    rdx,[rsp+0x80]
  22d74f:	mov    r8,QWORD PTR [rsp+0x18]
  22d754:	mov    r9,r13
  22d757:	push   r10
  22d759:	push   r11
  22d75b:	push   rax
  22d75c:	call   19b500 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  22d761:	add    rsp,0x20
  22d765:	jmp    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d76a:	cmp    r13,0x1
  22d76e:	jne    22d878 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  22d774:	xor    edx,edx
  22d776:	cmp    r14,0x1
  22d77a:	cmove  rdx,rbx
  22d77e:	cmp    QWORD PTR [rsp+0x28],0x1
  22d784:	jne    22d7ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  22d786:	test   rdx,rdx
  22d789:	je     22d7ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  22d78b:	mov    QWORD PTR [rsp+0x78],rdx
  22d790:	mov    QWORD PTR [rsp+0x80],r12
  22d798:	mov    QWORD PTR [rsp+0x88],r15
  22d7a0:	mov    rdx,QWORD PTR [rsp+0x8]
  22d7a5:	mov    QWORD PTR [rsp+0x90],rdx
  22d7ad:	mov    QWORD PTR [rsp+0x60],r8
  22d7b2:	mov    QWORD PTR [rsp+0x68],rcx
  22d7b7:	mov    QWORD PTR [rsp+0x70],rax
  22d7bc:	sub    rsp,0x8
  22d7c0:	mov    r14,r10
  22d7c3:	movzx  r10d,r9b
  22d7c7:	movzx  esi,BYTE PTR [rsp+0x38]
  22d7cc:	movzx  r8d,BYTE PTR [rsp+0x40]
  22d7d2:	lea    rdi,[rsp+0x80]
  22d7da:	lea    r9,[rsp+0x68]
  22d7df:	mov    rdx,QWORD PTR [rsp+0x18]
  22d7e4:	mov    rcx,QWORD PTR [rsp+0x28]
  22d7e9:	push   r14
  22d7eb:	jmp    22d866 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  22d7ed:	xor    edx,edx
  22d7ef:	cmp    QWORD PTR [rsp+0x8],0x1
  22d7f5:	cmove  rdx,rbx
  22d7f9:	cmp    rax,0x1
  22d7fd:	jne    22d878 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  22d7ff:	test   rdx,rdx
  22d802:	je     22d878 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  22d804:	mov    QWORD PTR [rsp+0x78],rdx
  22d809:	mov    QWORD PTR [rsp+0x80],r15
  22d811:	mov    QWORD PTR [rsp+0x88],r12
  22d819:	mov    QWORD PTR [rsp+0x90],r14
  22d821:	mov    rax,QWORD PTR [rsp+0x10]
  22d826:	mov    QWORD PTR [rsp+0x60],rax
  22d82b:	mov    rax,QWORD PTR [rsp+0x20]
  22d830:	mov    QWORD PTR [rsp+0x68],rax
  22d835:	mov    rax,QWORD PTR [rsp+0x28]
  22d83a:	mov    QWORD PTR [rsp+0x70],rax
  22d83f:	sub    rsp,0x8
  22d843:	mov    rax,r10
  22d846:	movzx  r10d,BYTE PTR [rsp+0x40]
  22d84c:	movzx  esi,BYTE PTR [rsp+0x38]
  22d851:	mov    rdx,r8
  22d854:	movzx  r8d,r9b
  22d858:	lea    rdi,[rsp+0x80]
  22d860:	lea    r9,[rsp+0x68]
  22d865:	push   rax
  22d866:	push   r11
  22d868:	push   r10
  22d86a:	call   149820 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  22d86f:	add    rsp,0x20
  22d873:	jmp    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22d878:	mov    QWORD PTR [rsp+0x18],rax
  22d87d:	movsd  xmm1,QWORD PTR [r11]
  22d882:	movsd  QWORD PTR [rsp+0x60],xmm1
  22d888:	mov    rax,r12
  22d88b:	mul    r15
  22d88e:	mov    rbp,rax
  22d891:	jo     22ddc5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  22d897:	mul    r13
  22d89a:	seto   cl
  22d89d:	not    cl
  22d89f:	cmp    rax,0x1001
  22d8a5:	setb   al
  22d8a8:	test   cl,al
  22d8aa:	jne    22d907 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5e7>
  22d8ac:	mov    rdx,QWORD PTR [rip+0x31c4c5]        # 549d78 <_DYNAMIC+0x450>
  22d8b3:	mov    rax,QWORD PTR [rdx]
  22d8b6:	test   rax,rax
  22d8b9:	je     22ddd1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  22d8bf:	mov    cl,0x1
  22d8c1:	test   eax,0x80000
  22d8c6:	jne    22ded2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  22d8cc:	mov    rax,QWORD PTR [rdx]
  22d8cf:	test   rax,rax
  22d8d2:	je     22de2c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb0c>
  22d8d8:	test   ax,ax
  22d8db:	jns    22d8f4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  22d8dd:	mov    rax,QWORD PTR [rdx]
  22d8e0:	test   rax,rax
  22d8e3:	je     22de83 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb63>
  22d8e9:	bt     rax,0x37
  22d8ee:	jb     22ded0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb0>
  22d8f4:	cmp    BYTE PTR [rsp+0x30],0x0
  22d8f9:	jne    22dbac <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  22d8ff:	xorps  xmm0,xmm0
  22d902:	jmp    22dbb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  22d907:	cmp    BYTE PTR [rsp+0x30],0x0
  22d90c:	mov    ecx,DWORD PTR [rsp+0x38]
  22d910:	jne    22d975 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x655>
  22d912:	xorps  xmm0,xmm0
  22d915:	movsd  QWORD PTR [rsp+0x30],xmm0
  22d91b:	mov    rax,r13
  22d91e:	cmp    QWORD PTR [rsp+0x8],r14
  22d923:	jb     22d98d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66d>
  22d925:	mov    ebp,r9d
  22d928:	mov    r9d,ecx
  22d92b:	mov    rcx,QWORD PTR [rsp+0x18]
  22d930:	mov    QWORD PTR [rsp+0x38],rcx
  22d935:	mov    QWORD PTR [rsp+0x40],rsi
  22d93a:	mov    QWORD PTR [rsp+0x58],r8
  22d93f:	mov    rsi,rdi
  22d942:	mov    rcx,QWORD PTR [rsp+0x28]
  22d947:	mov    r8,QWORD PTR [rsp+0x10]
  22d94c:	mov    rdx,QWORD PTR [rsp+0x8]
  22d951:	mov    QWORD PTR [rsp+0x10],rdx
  22d956:	mov    QWORD PTR [rsp+0x8],r14
  22d95b:	mov    r13,r15
  22d95e:	mov    r15,r12
  22d961:	jmp    22d9b5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x695>
  22d963:	cmp    r14,0x1
  22d967:	jne    22dae6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c6>
  22d96d:	mov    rax,r12
  22d970:	jmp    22dd41 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  22d975:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe121fb]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  22d97d:	movsd  QWORD PTR [rsp+0x30],xmm0
  22d983:	mov    rax,r13
  22d986:	cmp    QWORD PTR [rsp+0x8],r14
  22d98b:	jae    22d925 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x605>
  22d98d:	mov    ebp,ecx
  22d98f:	mov    rcx,QWORD PTR [rsp+0x28]
  22d994:	mov    QWORD PTR [rsp+0x38],rcx
  22d999:	mov    QWORD PTR [rsp+0x40],rdi
  22d99e:	mov    rcx,QWORD PTR [rsp+0x10]
  22d9a3:	mov    QWORD PTR [rsp+0x58],rcx
  22d9a8:	mov    QWORD PTR [rsp+0x10],r14
  22d9ad:	mov    r13,r12
  22d9b0:	mov    rcx,QWORD PTR [rsp+0x18]
  22d9b5:	movsd  QWORD PTR [rsp+0x20],xmm1
  22d9bb:	mov    QWORD PTR [rsp+0x48],rsi
  22d9c0:	mov    QWORD PTR [rsp+0x50],r8
  22d9c5:	mov    r14d,r9d
  22d9c8:	mov    QWORD PTR [rsp+0x18],rcx
  22d9cd:	cmp    rcx,0x1
  22d9d1:	jne    22d9fb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  22d9d3:	cmp    QWORD PTR [rsp+0x8],0x1
  22d9d9:	jne    22d9fb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  22d9db:	lea    r8,[rip+0x3148f6]        # 5422d8 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x410>
  22d9e2:	lea    rdi,[rsp+0x78]
  22d9e7:	mov    rsi,r15
  22d9ea:	mov    rdx,r13
  22d9ed:	mov    r12,rax
  22d9f0:	mov    rcx,rax
  22d9f3:	call   QWORD PTR [rip+0x31c687]        # 54a080 <_DYNAMIC+0x758>
  22d9f9:	jmp    22da19 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f9>
  22d9fb:	lea    r8,[rip+0x3148ee]        # 5422f0 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x428>
  22da02:	lea    rdi,[rsp+0x78]
  22da07:	mov    rsi,r15
  22da0a:	mov    rdx,r13
  22da0d:	mov    r12,rax
  22da10:	mov    rcx,rax
  22da13:	call   QWORD PTR [rip+0x31c66f]        # 54a088 <_DYNAMIC+0x760>
  22da19:	lea    rdi,[rsp+0x80]
  22da21:	mov    rsi,QWORD PTR [rsp+0xa0]
  22da29:	mov    rdx,QWORD PTR [rsp+0xa8]
  22da31:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  22da39:	sub    rsp,0x70
  22da3d:	movups XMMWORD PTR [rsp+0x58],xmm0
  22da42:	movzx  eax,bpl
  22da46:	mov    DWORD PTR [rsp+0x50],eax
  22da4a:	movzx  eax,r14b
  22da4e:	mov    DWORD PTR [rsp+0x48],eax
  22da52:	mov    rax,QWORD PTR [rsp+0xa8]
  22da5a:	mov    QWORD PTR [rsp+0x40],rax
  22da5f:	mov    rax,QWORD PTR [rsp+0xb0]
  22da67:	mov    QWORD PTR [rsp+0x38],rax
  22da6c:	mov    rax,QWORD PTR [rsp+0xc8]
  22da74:	mov    QWORD PTR [rsp+0x30],rax
  22da79:	mov    rax,QWORD PTR [rsp+0xb8]
  22da81:	mov    QWORD PTR [rsp+0x28],rax
  22da86:	mov    rax,QWORD PTR [rsp+0x88]
  22da8e:	mov    QWORD PTR [rsp+0x20],rax
  22da93:	mov    rax,QWORD PTR [rsp+0xc0]
  22da9b:	mov    QWORD PTR [rsp+0x18],rax
  22daa0:	mov    rax,QWORD PTR [rsp+0x80]
  22daa8:	mov    QWORD PTR [rsp+0x10],rax
  22daad:	mov    rax,QWORD PTR [rsp+0x78]
  22dab2:	mov    QWORD PTR [rsp+0x8],rax
  22dab7:	mov    QWORD PTR [rsp],rbx
  22dabb:	mov    r8,r13
  22dabe:	mov    r9,r12
  22dac1:	mov    rcx,r15
  22dac4:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  22dacd:	movsd  xmm1,QWORD PTR [rsp+0x90]
  22dad6:	call   QWORD PTR [rsp+0xe8]
  22dadd:	add    rsp,0x70
  22dae1:	jmp    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22dae6:	lea    rax,[r12-0x1]
  22daeb:	mov    ecx,r12d
  22daee:	and    ecx,0x3
  22daf1:	and    r12,0xfffffffffffffffc
  22daf5:	lea    rdx,[r14*8+0x0]
  22dafd:	lea    rsi,[rdx+rdx*2]
  22db01:	shl    QWORD PTR [rsp+0x8],0x3
  22db07:	mov    rdi,r14
  22db0a:	shl    rdi,0x5
  22db0e:	mov    r8,r14
  22db11:	shl    r8,0x4
  22db15:	xor    r9d,r9d
  22db18:	jmp    22db31 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  22db1a:	nop    WORD PTR [rax+rax*1+0x0]
  22db20:	inc    r9
  22db23:	add    rbx,QWORD PTR [rsp+0x8]
  22db28:	cmp    r9,r15
  22db2b:	je     22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22db31:	cmp    rax,0x3
  22db35:	jae    22db40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  22db37:	xor    r10d,r10d
  22db3a:	jmp    22db80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  22db3c:	nop    DWORD PTR [rax+0x0]
  22db40:	mov    r11,rbx
  22db43:	xor    r10d,r10d
  22db46:	cs nop WORD PTR [rax+rax*1+0x0]
  22db50:	mov    QWORD PTR [r11],0x0
  22db57:	mov    QWORD PTR [r11+r14*8],0x0
  22db5f:	mov    QWORD PTR [r11+r8*1],0x0
  22db67:	add    r10,0x4
  22db6b:	mov    QWORD PTR [r11+rsi*1],0x0
  22db73:	add    r11,rdi
  22db76:	cmp    r12,r10
  22db79:	jne    22db50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  22db7b:	test   rcx,rcx
  22db7e:	je     22db20 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  22db80:	imul   r10,rdx
  22db84:	add    r10,rbx
  22db87:	mov    r11,rcx
  22db8a:	nop    WORD PTR [rax+rax*1+0x0]
  22db90:	mov    QWORD PTR [r10],0x0
  22db97:	add    r10,rdx
  22db9a:	dec    r11
  22db9d:	jne    22db90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  22db9f:	jmp    22db20 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  22dba4:	mov    rax,r12
  22dba7:	jmp    22dd35 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa15>
  22dbac:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe11fc4]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  22dbb4:	xor    r11d,r11d
  22dbb7:	test   r10,r10
  22dbba:	setne  dl
  22dbbd:	cmp    QWORD PTR [rsp+0x8],r14
  22dbc2:	jge    22dbd9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b9>
  22dbc4:	mov    rcx,QWORD PTR [rsp+0x18]
  22dbc9:	mov    rbp,rsi
  22dbcc:	mov    rax,r8
  22dbcf:	mov    r8,r14
  22dbd2:	mov    r9,QWORD PTR [rsp+0x28]
  22dbd7:	jmp    22dc13 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f3>
  22dbd9:	mov    rcx,QWORD PTR [rsp+0x28]
  22dbde:	mov    rbp,rdi
  22dbe1:	mov    rax,QWORD PTR [rsp+0x10]
  22dbe6:	mov    QWORD PTR [rsp+0x28],rax
  22dbeb:	mov    r10,QWORD PTR [rsp+0x8]
  22dbf0:	mov    rax,r12
  22dbf3:	mov    r9,QWORD PTR [rsp+0x18]
  22dbf8:	mov    rdi,rsi
  22dbfb:	mov    QWORD PTR [rsp+0x10],r8
  22dc00:	mov    r8,r10
  22dc03:	mov    QWORD PTR [rsp+0x8],r14
  22dc08:	mov    r12,r15
  22dc0b:	mov    r15,rax
  22dc0e:	mov    rax,QWORD PTR [rsp+0x28]
  22dc13:	mov    r11b,dl
  22dc16:	mov    QWORD PTR [rsp+0x18],r15
  22dc1b:	lea    rdx,[r15-0x1]
  22dc1f:	imul   rdx,rcx
  22dc23:	mov    r14,rcx
  22dc26:	neg    r14
  22dc29:	mov    rsi,QWORD PTR [rsp+0x8]
  22dc2e:	test   rsi,rsi
  22dc31:	cmovns r14,rcx
  22dc35:	mov    rcx,rsi
  22dc38:	sar    rcx,0x3f
  22dc3c:	and    rcx,rdx
  22dc3f:	lea    rdx,[rax+rcx*8]
  22dc43:	lea    rax,[r12-0x1]
  22dc48:	imul   rax,r9
  22dc4c:	mov    r15,r9
  22dc4f:	neg    r15
  22dc52:	test   r8,r8
  22dc55:	cmovns r15,r9
  22dc59:	mov    rcx,r8
  22dc5c:	sar    rcx,0x3f
  22dc60:	and    rcx,rax
  22dc63:	mov    rax,QWORD PTR [rsp+0x10]
  22dc68:	lea    rsi,[rax+rcx*8]
  22dc6c:	test   rbp,rbp
  22dc6f:	jns    22dc8e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x96e>
  22dc71:	lea    rax,[r13-0x1]
  22dc75:	mov    rcx,rbp
  22dc78:	imul   rcx,rax
  22dc7c:	lea    rdx,[rdx+rcx*8]
  22dc80:	neg    rbp
  22dc83:	imul   rax,rdi
  22dc87:	lea    rsi,[rsi+rax*8]
  22dc8b:	neg    rdi
  22dc8e:	mov    QWORD PTR [rsp+0x28],rsi
  22dc93:	mov    QWORD PTR [rsp+0x10],rdx
  22dc98:	mov    QWORD PTR [rsp+0x40],rdi
  22dc9d:	mov    rax,QWORD PTR [rip+0x31c37c]        # 54a020 <_DYNAMIC+0x6f8>
  22dca4:	mov    rax,QWORD PTR [rax]
  22dca7:	test   rax,rax
  22dcaa:	jne    22dce4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c4>
  22dcac:	movsd  QWORD PTR [rsp+0x20],xmm1
  22dcb2:	movsd  QWORD PTR [rsp+0x38],xmm0
  22dcb8:	mov    QWORD PTR [rsp+0x50],rbp
  22dcbd:	mov    rbp,r11
  22dcc0:	mov    QWORD PTR [rsp+0x48],r8
  22dcc5:	call   QWORD PTR [rip+0x31c35d]        # 54a028 <_DYNAMIC+0x700>
  22dccb:	mov    r8,QWORD PTR [rsp+0x48]
  22dcd0:	mov    r11,rbp
  22dcd3:	mov    rbp,QWORD PTR [rsp+0x50]
  22dcd8:	movsd  xmm0,QWORD PTR [rsp+0x38]
  22dcde:	movsd  xmm1,QWORD PTR [rsp+0x20]
  22dce4:	movzx  r10d,BYTE PTR [rsp+0x30]
  22dcea:	mov    rdi,QWORD PTR [rsp+0x18]
  22dcef:	mov    rsi,r12
  22dcf2:	mov    rdx,r13
  22dcf5:	mov    rcx,rbx
  22dcf8:	mov    r9,QWORD PTR [rsp+0x8]
  22dcfd:	push   QWORD PTR [rsp+0x148]
  22dd04:	push   r11
  22dd06:	push   0x0
  22dd08:	push   0x0
  22dd0a:	push   0x0
  22dd0c:	push   QWORD PTR [rsp+0x68]
  22dd10:	push   r15
  22dd12:	push   QWORD PTR [rsp+0x60]
  22dd16:	push   r14
  22dd18:	push   rbp
  22dd19:	push   QWORD PTR [rsp+0x60]
  22dd1d:	push   r10
  22dd1f:	call   rax
  22dd21:	add    rsp,0x60
  22dd25:	jmp    22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22dd2a:	mov    rax,r15
  22dd2d:	mov    r15,r12
  22dd30:	mov    QWORD PTR [rsp+0x8],r14
  22dd35:	mov    ecx,0x1
  22dd3a:	sub    rcx,rax
  22dd3d:	lea    rbx,[rbx+rcx*8]
  22dd41:	lea    rcx,[rax-0x1]
  22dd45:	mov    edx,eax
  22dd47:	and    edx,0x3
  22dd4a:	and    rax,0xfffffffffffffffc
  22dd4e:	xor    esi,esi
  22dd50:	xorps  xmm0,xmm0
  22dd53:	jmp    22dd6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  22dd55:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  22dd60:	inc    rsi
  22dd63:	cmp    rsi,r15
  22dd66:	je     22dfb4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  22dd6c:	mov    rdi,rsi
  22dd6f:	imul   rdi,QWORD PTR [rsp+0x8]
  22dd75:	lea    rdi,[rbx+rdi*8]
  22dd79:	cmp    rcx,0x3
  22dd7d:	jb     22dda9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  22dd7f:	xor    r8d,r8d
  22dd82:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  22dd90:	movups XMMWORD PTR [rdi],xmm0
  22dd93:	movups XMMWORD PTR [rdi+0x10],xmm0
  22dd97:	add    rdi,0x20
  22dd9b:	add    r8,0x4
  22dd9f:	cmp    rax,r8
  22dda2:	jne    22dd90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  22dda4:	test   rdx,rdx
  22dda7:	je     22dd60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  22dda9:	xor    r8d,r8d
  22ddac:	nop    DWORD PTR [rax+0x0]
  22ddb0:	mov    QWORD PTR [rdi],0x0
  22ddb7:	add    rdi,0x8
  22ddbb:	inc    r8
  22ddbe:	cmp    rdx,r8
  22ddc1:	jne    22ddb0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  22ddc3:	jmp    22dd60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  22ddc5:	mov    rax,0xffffffffffffffff
  22ddcc:	jmp    22d897 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x577>
  22ddd1:	mov    DWORD PTR [rsp+0x58],r9d
  22ddd6:	mov    QWORD PTR [rsp+0x40],rdi
  22dddb:	mov    QWORD PTR [rsp+0x50],r8
  22dde0:	mov    QWORD PTR [rsp+0x48],rsi
  22dde5:	movsd  QWORD PTR [rsp+0x20],xmm1
  22ddeb:	call   QWORD PTR [rip+0x31bf8f]        # 549d80 <_DYNAMIC+0x458>
  22ddf1:	mov    rdx,QWORD PTR [rip+0x31bf80]        # 549d78 <_DYNAMIC+0x450>
  22ddf8:	movsd  xmm1,QWORD PTR [rsp+0x20]
  22ddfe:	mov    rsi,QWORD PTR [rsp+0x48]
  22de03:	mov    r10,QWORD PTR [rsp+0x148]
  22de0b:	mov    r8,QWORD PTR [rsp+0x50]
  22de10:	mov    rdi,QWORD PTR [rsp+0x40]
  22de15:	mov    r9d,DWORD PTR [rsp+0x58]
  22de1a:	mov    cl,0x1
  22de1c:	test   eax,0x80000
  22de21:	je     22d8cc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ac>
  22de27:	jmp    22ded2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  22de2c:	mov    DWORD PTR [rsp+0x58],r9d
  22de31:	mov    QWORD PTR [rsp+0x40],rdi
  22de36:	mov    QWORD PTR [rsp+0x50],r8
  22de3b:	mov    QWORD PTR [rsp+0x48],rsi
  22de40:	movsd  QWORD PTR [rsp+0x20],xmm1
  22de46:	call   QWORD PTR [rip+0x31bf34]        # 549d80 <_DYNAMIC+0x458>
  22de4c:	mov    rdx,QWORD PTR [rip+0x31bf25]        # 549d78 <_DYNAMIC+0x450>
  22de53:	movsd  xmm1,QWORD PTR [rsp+0x20]
  22de59:	mov    rsi,QWORD PTR [rsp+0x48]
  22de5e:	mov    r10,QWORD PTR [rsp+0x148]
  22de66:	mov    r8,QWORD PTR [rsp+0x50]
  22de6b:	mov    rdi,QWORD PTR [rsp+0x40]
  22de70:	mov    r9d,DWORD PTR [rsp+0x58]
  22de75:	test   ax,ax
  22de78:	js     22d8dd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5bd>
  22de7e:	jmp    22d8f4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  22de83:	mov    DWORD PTR [rsp+0x58],r9d
  22de88:	mov    QWORD PTR [rsp+0x40],rdi
  22de8d:	mov    QWORD PTR [rsp+0x50],r8
  22de92:	mov    QWORD PTR [rsp+0x48],rsi
  22de97:	movsd  QWORD PTR [rsp+0x20],xmm1
  22de9d:	call   QWORD PTR [rip+0x31bedd]        # 549d80 <_DYNAMIC+0x458>
  22dea3:	movsd  xmm1,QWORD PTR [rsp+0x20]
  22dea9:	mov    rsi,QWORD PTR [rsp+0x48]
  22deae:	mov    r10,QWORD PTR [rsp+0x148]
  22deb6:	mov    r8,QWORD PTR [rsp+0x50]
  22debb:	mov    rdi,QWORD PTR [rsp+0x40]
  22dec0:	mov    r9d,DWORD PTR [rsp+0x58]
  22dec5:	bt     rax,0x37
  22deca:	jae    22d8f4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  22ded0:	xor    ecx,ecx
  22ded2:	imul   rbp,r13
  22ded6:	cmp    r10,0x1
  22deda:	adc    r10,0x0
  22dede:	cmp    rbp,0x8000
  22dee5:	mov    eax,0x1
  22deea:	cmovae rax,r10
  22deee:	sub    rsp,0xa0
  22def5:	lea    rdx,[rsp+0x100]
  22defd:	mov    QWORD PTR [rsp+0x88],rdx
  22df05:	movzx  edx,r9b
  22df09:	mov    DWORD PTR [rsp+0x80],edx
  22df10:	mov    rdx,QWORD PTR [rsp+0xb8]
  22df18:	mov    QWORD PTR [rsp+0x78],rdx
  22df1d:	mov    QWORD PTR [rsp+0x70],rsi
  22df22:	mov    QWORD PTR [rsp+0x68],r8
  22df27:	xorps  xmm0,xmm0
  22df2a:	movups XMMWORD PTR [rsp+0x58],xmm0
  22df2f:	movzx  edx,BYTE PTR [rsp+0xd8]
  22df37:	mov    DWORD PTR [rsp+0x50],edx
  22df3b:	mov    QWORD PTR [rsp+0x48],rdi
  22df40:	mov    rdx,QWORD PTR [rsp+0xc8]
  22df48:	mov    QWORD PTR [rsp+0x40],rdx
  22df4d:	mov    rdx,QWORD PTR [rsp+0xb0]
  22df55:	mov    QWORD PTR [rsp+0x38],rdx
  22df5a:	movzx  edx,BYTE PTR [rsp+0xd0]
  22df62:	mov    DWORD PTR [rsp+0x30],edx
  22df66:	movups XMMWORD PTR [rsp+0x18],xmm0
  22df6b:	mov    rdx,QWORD PTR [rsp+0xa8]
  22df73:	mov    QWORD PTR [rsp+0x10],rdx
  22df78:	mov    QWORD PTR [rsp+0x8],r14
  22df7d:	mov    QWORD PTR [rsp],rbx
  22df81:	mov    QWORD PTR [rsp+0x90],rax
  22df89:	mov    DWORD PTR [rsp+0x28],0x2
  22df91:	movzx  edx,cl
  22df94:	mov    r8,r15
  22df97:	mov    edi,0x1
  22df9c:	mov    r9,r13
  22df9f:	mov    esi,0x1
  22dfa4:	mov    rcx,r12
  22dfa7:	call   QWORD PTR [rip+0x31bddb]        # 549d88 <_DYNAMIC+0x460>
  22dfad:	add    rsp,0xa0
  22dfb4:	add    rsp,0x108
  22dfbb:	pop    rbx
  22dfbc:	pop    r12
  22dfbe:	pop    r13
  22dfc0:	pop    r14
  22dfc2:	pop    r15
  22dfc4:	pop    rbp
  22dfc5:	ret
