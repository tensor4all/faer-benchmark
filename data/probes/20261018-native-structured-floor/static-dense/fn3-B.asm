
target/faer-rev/7cd372f40449-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002202f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  2202f0:	push   rbp
  2202f1:	push   r15
  2202f3:	push   r14
  2202f5:	push   r13
  2202f7:	push   r12
  2202f9:	push   rbx
  2202fa:	sub    rsp,0x108
  220301:	mov    r12,QWORD PTR [rdi+0x8]
  220305:	test   r12,r12
  220308:	je     220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  22030e:	mov    rbx,QWORD PTR [rdi+0x10]
  220312:	test   rbx,rbx
  220315:	je     220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  22031b:	mov    r10d,r9d
  22031e:	mov    ebp,esi
  220320:	mov    r14,QWORD PTR [rdi]
  220323:	mov    r9,QWORD PTR [rdi+0x18]
  220327:	mov    r15,QWORD PTR [rdi+0x20]
  22032b:	mov    rax,QWORD PTR [rdx+0x10]
  22032f:	test   rax,rax
  220332:	je     2203c9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd9>
  220338:	mov    rsi,QWORD PTR [rdx]
  22033b:	mov    r13,QWORD PTR [rdx+0x8]
  22033f:	mov    r11,QWORD PTR [rdx+0x18]
  220343:	test   r9,r9
  220346:	mov    QWORD PTR [rsp+0x30],rax
  22034b:	mov    QWORD PTR [rsp+0x20],r13
  220350:	mov    DWORD PTR [rsp+0xc],r10d
  220355:	mov    DWORD PTR [rsp+0x28],ecx
  220359:	jns    220390 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0>
  22035b:	lea    rax,[r12-0x1]
  220360:	imul   rax,r9
  220364:	neg    r9
  220367:	mov    r10,rsi
  22036a:	xor    esi,esi
  22036c:	mov    rdi,r13
  22036f:	sub    rdi,0x1
  220373:	cmovb  rdi,rsi
  220377:	lea    r14,[r14+rax*8]
  22037b:	mov    rax,r11
  22037e:	imul   rax,rdi
  220382:	cmp    rdi,r13
  220385:	cmove  rax,rsi
  220389:	lea    rsi,[r10+rax*8]
  22038d:	neg    r11
  220390:	mov    QWORD PTR [rsp+0x68],r11
  220395:	mov    r11,QWORD PTR [rdx+0x20]
  220399:	mov    rdi,QWORD PTR [r8]
  22039c:	mov    rax,QWORD PTR [r8+0x8]
  2203a0:	mov    rcx,QWORD PTR [r8+0x10]
  2203a4:	mov    r13,QWORD PTR [r8+0x20]
  2203a8:	test   r15,r15
  2203ab:	mov    QWORD PTR [rsp+0x18],rax
  2203b0:	js     220418 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x128>
  2203b2:	mov    rax,QWORD PTR [r8+0x18]
  2203b6:	test   r11,r11
  2203b9:	js     220476 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x186>
  2203bf:	mov    QWORD PTR [rsp+0x10],r11
  2203c4:	jmp    2204d1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1e1>
  2203c9:	test   bpl,bpl
  2203cc:	jne    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2203d2:	cmp    r12,0x1
  2203d6:	je     2203ec <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfc>
  2203d8:	cmp    r9,0xffffffffffffffff
  2203dc:	je     220b14 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x824>
  2203e2:	cmp    r9,0x1
  2203e6:	je     2208fc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x60c>
  2203ec:	cmp    rbx,0x1
  2203f0:	je     2208f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x602>
  2203f6:	cmp    r15,0xffffffffffffffff
  2203fa:	je     220b6f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x87f>
  220400:	cmp    r15,0x1
  220404:	jne    2208f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x602>
  22040a:	mov    rax,rbx
  22040d:	mov    rbx,r12
  220410:	mov    r15,r9
  220413:	jmp    220b84 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  220418:	lea    rdx,[rbx-0x1]
  22041c:	imul   rdx,r15
  220420:	lea    r14,[r14+rdx*8]
  220424:	neg    r15
  220427:	xor    r10d,r10d
  22042a:	mov    edx,ebp
  22042c:	mov    rbp,rsi
  22042f:	mov    rsi,rcx
  220432:	sub    rsi,0x1
  220436:	cmovb  rsi,r10
  22043a:	mov    r10,r11
  22043d:	mov    r11,rdi
  220440:	mov    rdi,r13
  220443:	imul   rdi,rsi
  220447:	cmp    rsi,rcx
  22044a:	mov    rsi,rbp
  22044d:	mov    ebp,edx
  22044f:	mov    edx,0x0
  220454:	cmove  rdi,rdx
  220458:	test   rax,rax
  22045b:	cmove  rdi,rax
  22045f:	lea    rdi,[r11+rdi*8]
  220463:	mov    r11,r10
  220466:	neg    r13
  220469:	mov    rax,QWORD PTR [r8+0x18]
  22046d:	test   r11,r11
  220470:	jns    2203bf <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf>
  220476:	mov    rdx,QWORD PTR [rsp+0x30]
  22047b:	dec    rdx
  22047e:	imul   rdx,r11
  220482:	mov    r8,QWORD PTR [rsp+0x20]
  220487:	test   r8,r8
  22048a:	cmove  rdx,r8
  22048e:	lea    rsi,[rsi+rdx*8]
  220492:	neg    r11
  220495:	mov    QWORD PTR [rsp+0x10],r11
  22049a:	xor    edx,edx
  22049c:	mov    r11,rsi
  22049f:	mov    r10,QWORD PTR [rsp+0x18]
  2204a4:	mov    rsi,r10
  2204a7:	sub    rsi,0x1
  2204ab:	cmovb  rsi,rdx
  2204af:	mov    r8,rdi
  2204b2:	mov    rdi,rax
  2204b5:	imul   rdi,rsi
  2204b9:	test   rcx,rcx
  2204bc:	cmove  rdi,rcx
  2204c0:	cmp    rsi,r10
  2204c3:	mov    rsi,r11
  2204c6:	cmove  rdi,rdx
  2204ca:	lea    rdi,[r8+rdi*8]
  2204ce:	neg    rax
  2204d1:	mov    r10,QWORD PTR [rsp+0x148]
  2204d9:	mov    r11,QWORD PTR [rsp+0x140]
  2204e1:	cmp    rbx,0x1
  2204e5:	mov    r8,QWORD PTR [rsp+0x68]
  2204ea:	jne    2205e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  2204f0:	cmp    r8,0x1
  2204f4:	jne    22056f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  2204f6:	cmp    r9,0x1
  2204fa:	jne    22056f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  2204fc:	test   r14,r14
  2204ff:	je     22056f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  220501:	mov    QWORD PTR [rsp+0x78],rsi
  220506:	mov    rcx,QWORD PTR [rsp+0x20]
  22050b:	mov    QWORD PTR [rsp+0x80],rcx
  220513:	mov    rcx,rax
  220516:	mov    rax,QWORD PTR [rsp+0x30]
  22051b:	mov    QWORD PTR [rsp+0x88],rax
  220523:	mov    rax,QWORD PTR [rsp+0x10]
  220528:	mov    QWORD PTR [rsp+0x90],rax
  220530:	mov    QWORD PTR [rsp+0x40],rdi
  220535:	mov    rax,QWORD PTR [rsp+0x18]
  22053a:	mov    QWORD PTR [rsp+0x48],rax
  22053f:	mov    QWORD PTR [rsp+0x50],rcx
  220544:	sub    rsp,0x8
  220548:	movzx  eax,BYTE PTR [rsp+0x14]
  22054d:	movzx  edx,bpl
  220551:	movzx  r8d,BYTE PTR [rsp+0x30]
  220557:	lea    rcx,[rsp+0x80]
  22055f:	lea    r9,[rsp+0x48]
  220564:	mov    rdi,r14
  220567:	mov    rsi,r12
  22056a:	jmp    220664 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x374>
  22056f:	cmp    QWORD PTR [rsp+0x10],0x1
  220575:	jne    2205e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  220577:	cmp    rax,0x1
  22057b:	jne    2205e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  22057d:	test   rdi,rdi
  220580:	je     2205e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  220582:	mov    QWORD PTR [rsp+0x78],rsi
  220587:	mov    rax,QWORD PTR [rsp+0x20]
  22058c:	mov    QWORD PTR [rsp+0x80],rax
  220594:	mov    rax,QWORD PTR [rsp+0x30]
  220599:	mov    QWORD PTR [rsp+0x88],rax
  2205a1:	mov    QWORD PTR [rsp+0x90],r8
  2205a9:	mov    QWORD PTR [rsp+0x40],r14
  2205ae:	mov    QWORD PTR [rsp+0x48],r12
  2205b3:	mov    QWORD PTR [rsp+0x50],r9
  2205b8:	sub    rsp,0x8
  2205bc:	movzx  eax,BYTE PTR [rsp+0x14]
  2205c1:	movzx  esi,bpl
  2205c5:	movzx  ecx,BYTE PTR [rsp+0x30]
  2205ca:	mov    r8,rdi
  2205cd:	lea    rdi,[rsp+0x48]
  2205d2:	lea    rdx,[rsp+0x80]
  2205da:	mov    r9,QWORD PTR [rsp+0x20]
  2205df:	jmp    2206e6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3f6>
  2205e4:	cmp    r12,0x1
  2205e8:	jne    2206f9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  2205ee:	xor    edx,edx
  2205f0:	cmp    r15,0x1
  2205f4:	cmove  rdx,r14
  2205f8:	cmp    r13,0x1
  2205fc:	jne    220677 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x387>
  2205fe:	test   rdx,rdx
  220601:	je     220677 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x387>
  220603:	mov    QWORD PTR [rsp+0x78],rdi
  220608:	mov    QWORD PTR [rsp+0x80],rcx
  220610:	mov    rcx,QWORD PTR [rsp+0x18]
  220615:	mov    QWORD PTR [rsp+0x88],rcx
  22061d:	mov    QWORD PTR [rsp+0x90],rax
  220625:	mov    QWORD PTR [rsp+0x40],rsi
  22062a:	mov    rax,QWORD PTR [rsp+0x30]
  22062f:	mov    QWORD PTR [rsp+0x48],rax
  220634:	mov    rax,QWORD PTR [rsp+0x10]
  220639:	mov    QWORD PTR [rsp+0x50],rax
  22063e:	sub    rsp,0x8
  220642:	movzx  eax,BYTE PTR [rsp+0x30]
  220647:	movzx  edx,bpl
  22064b:	movzx  r8d,BYTE PTR [rsp+0x14]
  220651:	lea    rcx,[rsp+0x80]
  220659:	lea    r9,[rsp+0x48]
  22065e:	mov    rdi,r14
  220661:	mov    rsi,rbx
  220664:	push   r10
  220666:	push   r11
  220668:	push   rax
  220669:	call   14da00 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  22066e:	add    rsp,0x20
  220672:	jmp    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220677:	xor    edx,edx
  220679:	cmp    QWORD PTR [rsp+0x10],0x1
  22067f:	cmove  rdx,rsi
  220683:	cmp    rax,0x1
  220687:	jne    2206f9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  220689:	test   rdx,rdx
  22068c:	je     2206f9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  22068e:	mov    QWORD PTR [rsp+0x78],rdi
  220693:	mov    QWORD PTR [rsp+0x80],rcx
  22069b:	mov    rax,QWORD PTR [rsp+0x18]
  2206a0:	mov    QWORD PTR [rsp+0x88],rax
  2206a8:	mov    QWORD PTR [rsp+0x90],r13
  2206b0:	mov    QWORD PTR [rsp+0x40],r14
  2206b5:	mov    QWORD PTR [rsp+0x48],rbx
  2206ba:	mov    QWORD PTR [rsp+0x50],r15
  2206bf:	sub    rsp,0x8
  2206c3:	movzx  eax,BYTE PTR [rsp+0x30]
  2206c8:	mov    r8,rsi
  2206cb:	movzx  esi,bpl
  2206cf:	movzx  ecx,BYTE PTR [rsp+0x14]
  2206d4:	lea    rdi,[rsp+0x48]
  2206d9:	lea    rdx,[rsp+0x80]
  2206e1:	mov    r9,QWORD PTR [rsp+0x38]
  2206e6:	push   r10
  2206e8:	push   r11
  2206ea:	push   rax
  2206eb:	call   204f90 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  2206f0:	add    rsp,0x20
  2206f4:	jmp    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2206f9:	mov    r10,QWORD PTR [rsp+0x30]
  2206fe:	cmp    r10,0x1
  220702:	jne    220800 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  220708:	xor    edx,edx
  22070a:	cmp    r9,0x1
  22070e:	cmove  rdx,r14
  220712:	cmp    r8,0x1
  220716:	jne    22077d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x48d>
  220718:	test   rdx,rdx
  22071b:	je     22077d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x48d>
  22071d:	mov    QWORD PTR [rsp+0x78],rdx
  220722:	mov    QWORD PTR [rsp+0x80],r12
  22072a:	mov    QWORD PTR [rsp+0x88],rbx
  220732:	mov    QWORD PTR [rsp+0x90],r15
  22073a:	mov    QWORD PTR [rsp+0x40],rdi
  22073f:	mov    QWORD PTR [rsp+0x48],rcx
  220744:	mov    QWORD PTR [rsp+0x50],r13
  220749:	sub    rsp,0x8
  22074d:	movzx  eax,BYTE PTR [rsp+0x14]
  220752:	mov    rdx,rsi
  220755:	movzx  esi,bpl
  220759:	movzx  r8d,BYTE PTR [rsp+0x30]
  22075f:	lea    rdi,[rsp+0x80]
  220767:	lea    r9,[rsp+0x48]
  22076c:	mov    rcx,QWORD PTR [rsp+0x28]
  220771:	push   QWORD PTR [rsp+0x150]
  220778:	push   r11
  22077a:	push   rax
  22077b:	jmp    2207f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x502>
  22077d:	xor    edx,edx
  22077f:	cmp    r15,0x1
  220783:	cmove  rdx,r14
  220787:	cmp    r13,0x1
  22078b:	jne    220800 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  22078d:	test   rdx,rdx
  220790:	je     220800 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  220792:	mov    QWORD PTR [rsp+0x78],rdx
  220797:	mov    QWORD PTR [rsp+0x80],rbx
  22079f:	mov    QWORD PTR [rsp+0x88],r12
  2207a7:	mov    QWORD PTR [rsp+0x90],r9
  2207af:	mov    QWORD PTR [rsp+0x40],rsi
  2207b4:	mov    rax,QWORD PTR [rsp+0x20]
  2207b9:	mov    QWORD PTR [rsp+0x48],rax
  2207be:	mov    QWORD PTR [rsp+0x50],r8
  2207c3:	sub    rsp,0x8
  2207c7:	movzx  r10d,BYTE PTR [rsp+0x30]
  2207cd:	movzx  esi,bpl
  2207d1:	movzx  r8d,BYTE PTR [rsp+0x14]
  2207d7:	mov    rdx,rdi
  2207da:	lea    rdi,[rsp+0x80]
  2207e2:	lea    r9,[rsp+0x48]
  2207e7:	push   QWORD PTR [rsp+0x150]
  2207ee:	push   r11
  2207f0:	push   r10
  2207f2:	call   14ca20 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  2207f7:	add    rsp,0x20
  2207fb:	jmp    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220800:	mov    QWORD PTR [rsp+0x18],rax
  220805:	movsd  xmm1,QWORD PTR [r11]
  22080a:	mov    rax,r12
  22080d:	mul    rbx
  220810:	movsd  QWORD PTR [rsp+0x40],xmm1
  220816:	seto   BYTE PTR [rsp+0xb]
  22081b:	mov    QWORD PTR [rsp+0x20],rax
  220820:	jo     220c37 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x947>
  220826:	mul    r10
  220829:	seto   cl
  22082c:	not    cl
  22082e:	cmp    rax,0x1001
  220834:	setb   al
  220837:	test   cl,al
  220839:	mov    r11,QWORD PTR [rsp+0x10]
  22083e:	jne    22089e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ae>
  220840:	mov    rdx,QWORD PTR [rip+0x32b671]        # 54beb8 <_DYNAMIC+0x450>
  220847:	mov    rax,QWORD PTR [rdx]
  22084a:	test   rax,rax
  22084d:	mov    QWORD PTR [rsp+0x70],rsi
  220852:	je     220c43 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x953>
  220858:	mov    cl,0x1
  22085a:	test   eax,0x80000
  22085f:	jne    220d1d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2d>
  220865:	mov    rax,QWORD PTR [rdx]
  220868:	test   rax,rax
  22086b:	je     220c91 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9a1>
  220871:	test   ax,ax
  220874:	jns    22088d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220876:	mov    rax,QWORD PTR [rdx]
  220879:	test   rax,rax
  22087c:	je     220cdb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9eb>
  220882:	bt     rax,0x37
  220887:	jb     220d1b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2b>
  22088d:	test   bpl,bpl
  220890:	jne    220b19 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x829>
  220896:	xorps  xmm0,xmm0
  220899:	jmp    220b21 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x831>
  22089e:	test   bpl,bpl
  2208a1:	mov    ecx,DWORD PTR [rsp+0x28]
  2208a5:	jne    220904 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x614>
  2208a7:	xorps  xmm0,xmm0
  2208aa:	movsd  QWORD PTR [rsp+0x20],xmm0
  2208b0:	cmp    r15,r9
  2208b3:	jb     220917 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x627>
  2208b5:	mov    eax,DWORD PTR [rsp+0xc]
  2208b9:	mov    BYTE PTR [rsp+0xb],al
  2208bd:	mov    eax,ecx
  2208bf:	mov    DWORD PTR [rsp+0xc],eax
  2208c3:	mov    QWORD PTR [rsp+0x28],r13
  2208c8:	mov    rax,QWORD PTR [rsp+0x18]
  2208cd:	mov    QWORD PTR [rsp+0x70],rax
  2208d2:	mov    QWORD PTR [rsp+0x38],rdi
  2208d7:	mov    QWORD PTR [rsp+0x18],r11
  2208dc:	mov    rax,r8
  2208df:	mov    rdi,rsi
  2208e2:	mov    QWORD PTR [rsp+0x10],r15
  2208e7:	mov    r15,r9
  2208ea:	mov    rbp,rbx
  2208ed:	mov    rbx,r12
  2208f0:	jmp    220935 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x645>
  2208f2:	cmp    r9,0x1
  2208f6:	jne    220a4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x75f>
  2208fc:	mov    rax,r12
  2208ff:	jmp    220b84 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  220904:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1f2cc]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  22090c:	movsd  QWORD PTR [rsp+0x20],xmm0
  220912:	cmp    r15,r9
  220915:	jae    2208b5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c5>
  220917:	mov    BYTE PTR [rsp+0xb],cl
  22091b:	mov    QWORD PTR [rsp+0x28],r8
  220920:	mov    QWORD PTR [rsp+0x70],r11
  220925:	mov    QWORD PTR [rsp+0x38],rsi
  22092a:	mov    QWORD PTR [rsp+0x10],r9
  22092f:	mov    rbp,r12
  220932:	mov    rax,r13
  220935:	movsd  QWORD PTR [rsp+0x58],xmm1
  22093b:	mov    QWORD PTR [rsp+0x60],rdi
  220940:	mov    r13,rax
  220943:	cmp    rax,0x1
  220947:	jne    22096f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x67f>
  220949:	cmp    r15,0x1
  22094d:	jne    22096f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x67f>
  22094f:	lea    r8,[rip+0x3202ea]        # 540c40 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x410>
  220956:	lea    rdi,[rsp+0x78]
  22095b:	mov    rsi,rbx
  22095e:	mov    rdx,rbp
  220961:	mov    rcx,r10
  220964:	mov    r12,r10
  220967:	call   QWORD PTR [rip+0x32b85b]        # 54c1c8 <_DYNAMIC+0x760>
  22096d:	jmp    22098d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x69d>
  22096f:	lea    r8,[rip+0x3202e2]        # 540c58 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x428>
  220976:	lea    rdi,[rsp+0x78]
  22097b:	mov    rsi,rbx
  22097e:	mov    rdx,rbp
  220981:	mov    rcx,r10
  220984:	mov    r12,r10
  220987:	call   QWORD PTR [rip+0x32b843]        # 54c1d0 <_DYNAMIC+0x768>
  22098d:	lea    rdi,[rsp+0x80]
  220995:	mov    rsi,QWORD PTR [rsp+0xa0]
  22099d:	mov    rdx,QWORD PTR [rsp+0xa8]
  2209a5:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  2209ad:	sub    rsp,0x70
  2209b1:	movups XMMWORD PTR [rsp+0x58],xmm0
  2209b6:	movzx  eax,BYTE PTR [rsp+0x7b]
  2209bb:	mov    DWORD PTR [rsp+0x50],eax
  2209bf:	movzx  eax,BYTE PTR [rsp+0x7c]
  2209c4:	mov    DWORD PTR [rsp+0x48],eax
  2209c8:	mov    rax,QWORD PTR [rsp+0x98]
  2209d0:	mov    QWORD PTR [rsp+0x40],rax
  2209d5:	mov    rax,QWORD PTR [rsp+0xe0]
  2209dd:	mov    QWORD PTR [rsp+0x38],rax
  2209e2:	mov    rax,QWORD PTR [rsp+0xa8]
  2209ea:	mov    QWORD PTR [rsp+0x30],rax
  2209ef:	mov    rax,QWORD PTR [rsp+0x88]
  2209f7:	mov    QWORD PTR [rsp+0x28],rax
  2209fc:	mov    QWORD PTR [rsp+0x20],r13
  220a01:	mov    rax,QWORD PTR [rsp+0xd0]
  220a09:	mov    QWORD PTR [rsp+0x18],rax
  220a0e:	mov    rax,QWORD PTR [rsp+0x80]
  220a16:	mov    QWORD PTR [rsp+0x10],rax
  220a1b:	mov    QWORD PTR [rsp+0x8],r15
  220a20:	mov    QWORD PTR [rsp],r14
  220a24:	mov    r8,rbp
  220a27:	mov    r9,r12
  220a2a:	mov    rcx,rbx
  220a2d:	movsd  xmm0,QWORD PTR [rsp+0x90]
  220a36:	movsd  xmm1,QWORD PTR [rsp+0xc8]
  220a3f:	call   QWORD PTR [rsp+0xe8]
  220a46:	add    rsp,0x70
  220a4a:	jmp    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220a4f:	lea    rax,[r12-0x1]
  220a54:	mov    ecx,r12d
  220a57:	and    ecx,0x3
  220a5a:	and    r12,0xfffffffffffffffc
  220a5e:	lea    rdx,[r9*8+0x0]
  220a66:	lea    rsi,[rdx+rdx*2]
  220a6a:	shl    r15,0x3
  220a6e:	mov    rdi,r9
  220a71:	shl    rdi,0x5
  220a75:	mov    r8,r9
  220a78:	shl    r8,0x4
  220a7c:	xor    r10d,r10d
  220a7f:	jmp    220a9f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7af>
  220a81:	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  220a90:	inc    r10
  220a93:	add    r14,r15
  220a96:	cmp    r10,rbx
  220a99:	je     220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220a9f:	cmp    rax,0x3
  220aa3:	jae    220ab0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c0>
  220aa5:	xor    r11d,r11d
  220aa8:	jmp    220af4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x804>
  220aaa:	nop    WORD PTR [rax+rax*1+0x0]
  220ab0:	mov    r13,r14
  220ab3:	xor    r11d,r11d
  220ab6:	cs nop WORD PTR [rax+rax*1+0x0]
  220ac0:	mov    QWORD PTR [r13+0x0],0x0
  220ac8:	mov    QWORD PTR [r13+r9*8+0x0],0x0
  220ad1:	mov    QWORD PTR [r13+r8*1+0x0],0x0
  220ada:	add    r11,0x4
  220ade:	mov    QWORD PTR [r13+rsi*1+0x0],0x0
  220ae7:	add    r13,rdi
  220aea:	cmp    r12,r11
  220aed:	jne    220ac0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7d0>
  220aef:	test   rcx,rcx
  220af2:	je     220a90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  220af4:	imul   r11,rdx
  220af8:	add    r11,r14
  220afb:	mov    r13,rcx
  220afe:	xchg   ax,ax
  220b00:	mov    QWORD PTR [r11],0x0
  220b07:	add    r11,rdx
  220b0a:	dec    r13
  220b0d:	jne    220b00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x810>
  220b0f:	jmp    220a90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  220b14:	mov    rax,r12
  220b17:	jmp    220b78 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x888>
  220b19:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1f0b7]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  220b21:	mov    r11,rdi
  220b24:	mov    rax,QWORD PTR [rsp+0x148]
  220b2c:	test   rax,rax
  220b2f:	je     220bf5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x905>
  220b35:	sub    rsp,0x8
  220b39:	movzx  ebp,bpl
  220b3d:	mov    rdi,r12
  220b40:	mov    rsi,rbx
  220b43:	mov    rdx,r10
  220b46:	mov    rcx,r14
  220b49:	mov    r8,r15
  220b4c:	push   rax
  220b4d:	push   0x1
  220b4f:	push   QWORD PTR [rsp+0x30]
  220b53:	push   r13
  220b55:	push   r11
  220b57:	push   QWORD PTR [rsp+0x98]
  220b5e:	push   QWORD PTR [rsp+0x48]
  220b62:	push   QWORD PTR [rsp+0xb0]
  220b69:	push   rbp
  220b6a:	jmp    220c29 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x939>
  220b6f:	mov    rax,rbx
  220b72:	mov    rbx,r12
  220b75:	mov    r15,r9
  220b78:	mov    ecx,0x1
  220b7d:	sub    rcx,rax
  220b80:	lea    r14,[r14+rcx*8]
  220b84:	lea    rcx,[rax-0x1]
  220b88:	mov    edx,eax
  220b8a:	and    edx,0x3
  220b8d:	and    rax,0xfffffffffffffffc
  220b91:	xor    esi,esi
  220b93:	xorps  xmm0,xmm0
  220b96:	jmp    220bac <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8bc>
  220b98:	nop    DWORD PTR [rax+rax*1+0x0]
  220ba0:	inc    rsi
  220ba3:	cmp    rsi,rbx
  220ba6:	je     220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220bac:	mov    rdi,rsi
  220baf:	imul   rdi,r15
  220bb3:	lea    rdi,[r14+rdi*8]
  220bb7:	cmp    rcx,0x3
  220bbb:	jb     220bd9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8e9>
  220bbd:	xor    r8d,r8d
  220bc0:	movups XMMWORD PTR [rdi],xmm0
  220bc3:	movups XMMWORD PTR [rdi+0x10],xmm0
  220bc7:	add    rdi,0x20
  220bcb:	add    r8,0x4
  220bcf:	cmp    rax,r8
  220bd2:	jne    220bc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8d0>
  220bd4:	test   rdx,rdx
  220bd7:	je     220ba0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  220bd9:	xor    r8d,r8d
  220bdc:	nop    DWORD PTR [rax+0x0]
  220be0:	mov    QWORD PTR [rdi],0x0
  220be7:	add    rdi,0x8
  220beb:	inc    r8
  220bee:	cmp    rdx,r8
  220bf1:	jne    220be0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f0>
  220bf3:	jmp    220ba0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  220bf5:	sub    rsp,0x10
  220bf9:	movzx  eax,bpl
  220bfd:	mov    rdi,r12
  220c00:	mov    rsi,rbx
  220c03:	mov    rdx,r10
  220c06:	mov    rcx,r14
  220c09:	mov    r8,r15
  220c0c:	push   0x0
  220c0e:	push   QWORD PTR [rsp+0x30]
  220c12:	push   r13
  220c14:	push   r11
  220c16:	push   QWORD PTR [rsp+0x98]
  220c1d:	push   QWORD PTR [rsp+0x48]
  220c21:	push   QWORD PTR [rsp+0xb0]
  220c28:	push   rax
  220c29:	call   20b180 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmdECscfHK10Grmvq_6fbench>
  220c2e:	add    rsp,0x50
  220c32:	jmp    220e26 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220c37:	mov    rax,0xffffffffffffffff
  220c3e:	jmp    220826 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x536>
  220c43:	mov    QWORD PTR [rsp+0x38],r9
  220c48:	mov    QWORD PTR [rsp+0x60],rdi
  220c4d:	movsd  QWORD PTR [rsp+0x58],xmm1
  220c53:	call   QWORD PTR [rip+0x32b267]        # 54bec0 <_DYNAMIC+0x458>
  220c59:	mov    rdx,QWORD PTR [rip+0x32b258]        # 54beb8 <_DYNAMIC+0x450>
  220c60:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220c66:	mov    r11,QWORD PTR [rsp+0x10]
  220c6b:	mov    r8,QWORD PTR [rsp+0x68]
  220c70:	mov    rdi,QWORD PTR [rsp+0x60]
  220c75:	mov    r10,QWORD PTR [rsp+0x30]
  220c7a:	mov    r9,QWORD PTR [rsp+0x38]
  220c7f:	mov    cl,0x1
  220c81:	test   eax,0x80000
  220c86:	je     220865 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x575>
  220c8c:	jmp    220d1d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2d>
  220c91:	mov    QWORD PTR [rsp+0x38],r9
  220c96:	mov    QWORD PTR [rsp+0x60],rdi
  220c9b:	movsd  QWORD PTR [rsp+0x58],xmm1
  220ca1:	call   QWORD PTR [rip+0x32b219]        # 54bec0 <_DYNAMIC+0x458>
  220ca7:	mov    rdx,QWORD PTR [rip+0x32b20a]        # 54beb8 <_DYNAMIC+0x450>
  220cae:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220cb4:	mov    r11,QWORD PTR [rsp+0x10]
  220cb9:	mov    r8,QWORD PTR [rsp+0x68]
  220cbe:	mov    rdi,QWORD PTR [rsp+0x60]
  220cc3:	mov    r10,QWORD PTR [rsp+0x30]
  220cc8:	mov    r9,QWORD PTR [rsp+0x38]
  220ccd:	test   ax,ax
  220cd0:	js     220876 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x586>
  220cd6:	jmp    22088d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220cdb:	mov    QWORD PTR [rsp+0x38],r9
  220ce0:	mov    QWORD PTR [rsp+0x60],rdi
  220ce5:	movsd  QWORD PTR [rsp+0x58],xmm1
  220ceb:	call   QWORD PTR [rip+0x32b1cf]        # 54bec0 <_DYNAMIC+0x458>
  220cf1:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220cf7:	mov    r11,QWORD PTR [rsp+0x10]
  220cfc:	mov    r8,QWORD PTR [rsp+0x68]
  220d01:	mov    rdi,QWORD PTR [rsp+0x60]
  220d06:	mov    r10,QWORD PTR [rsp+0x30]
  220d0b:	mov    r9,QWORD PTR [rsp+0x38]
  220d10:	bt     rax,0x37
  220d15:	jae    22088d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220d1b:	xor    ecx,ecx
  220d1d:	cmp    BYTE PTR [rsp+0xb],0x0
  220d22:	jne    220e38 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb48>
  220d28:	mov    rax,QWORD PTR [rsp+0x20]
  220d2d:	mul    r10
  220d30:	jo     220e4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb5f>
  220d36:	test   rax,rax
  220d39:	js     220e4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb5f>
  220d3f:	mov    rdx,QWORD PTR [rip+0x32b18a]        # 54bed0 <_DYNAMIC+0x468>
  220d46:	mov    rdx,QWORD PTR [rdx]
  220d49:	movabs rsi,0x7fffffffffffffff
  220d53:	and    rsi,rdx
  220d56:	mov    edx,0x1
  220d5b:	cmp    rax,rsi
  220d5e:	jb     220d70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa80>
  220d60:	mov    rdx,QWORD PTR [rsp+0x148]
  220d68:	cmp    rdx,0x1
  220d6c:	adc    rdx,0x0
  220d70:	sub    rsp,0xa0
  220d77:	mov    QWORD PTR [rsp+0x90],rdx
  220d7f:	lea    rax,[rsp+0xe0]
  220d87:	mov    QWORD PTR [rsp+0x88],rax
  220d8f:	movzx  eax,BYTE PTR [rsp+0xac]
  220d97:	mov    DWORD PTR [rsp+0x80],eax
  220d9e:	mov    QWORD PTR [rsp+0x78],r13
  220da3:	mov    rax,QWORD PTR [rsp+0xb8]
  220dab:	mov    QWORD PTR [rsp+0x70],rax
  220db0:	mov    QWORD PTR [rsp+0x68],rdi
  220db5:	xorps  xmm0,xmm0
  220db8:	movups XMMWORD PTR [rsp+0x58],xmm0
  220dbd:	movzx  eax,BYTE PTR [rsp+0xc8]
  220dc5:	mov    DWORD PTR [rsp+0x50],eax
  220dc9:	mov    QWORD PTR [rsp+0x48],r11
  220dce:	mov    QWORD PTR [rsp+0x40],r8
  220dd3:	mov    rax,QWORD PTR [rsp+0x110]
  220ddb:	mov    QWORD PTR [rsp+0x38],rax
  220de0:	movzx  eax,bpl
  220de4:	mov    DWORD PTR [rsp+0x30],eax
  220de8:	movups XMMWORD PTR [rsp+0x18],xmm0
  220ded:	mov    QWORD PTR [rsp+0x10],r15
  220df2:	mov    QWORD PTR [rsp+0x8],r9
  220df7:	mov    QWORD PTR [rsp],r14
  220dfb:	mov    DWORD PTR [rsp+0x28],0x2
  220e03:	movzx  edx,cl
  220e06:	mov    r8,rbx
  220e09:	mov    edi,0x1
  220e0e:	mov    r9,r10
  220e11:	mov    esi,0x1
  220e16:	mov    rcx,r12
  220e19:	call   QWORD PTR [rip+0x32b0a9]        # 54bec8 <_DYNAMIC+0x460>
  220e1f:	add    rsp,0xa0
  220e26:	add    rsp,0x108
  220e2d:	pop    rbx
  220e2e:	pop    r12
  220e30:	pop    r13
  220e32:	pop    r14
  220e34:	pop    r15
  220e36:	pop    rbp
  220e37:	ret
  220e38:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
  220e41:	mov    rax,QWORD PTR [rsp+0x20]
  220e46:	mul    r10
  220e49:	jno    220d36 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa46>
  220e4f:	mov    rax,QWORD PTR [rip+0x32b07a]        # 54bed0 <_DYNAMIC+0x468>
  220e56:	mov    rax,QWORD PTR [rax]
  220e59:	jmp    220d60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
