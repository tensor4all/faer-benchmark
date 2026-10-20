
target/faer-rev/f013756c7421-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002202d0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  2202d0:	push   rbp
  2202d1:	push   r15
  2202d3:	push   r14
  2202d5:	push   r13
  2202d7:	push   r12
  2202d9:	push   rbx
  2202da:	sub    rsp,0x108
  2202e1:	mov    r12,QWORD PTR [rdi+0x8]
  2202e5:	test   r12,r12
  2202e8:	je     220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2202ee:	mov    rbx,QWORD PTR [rdi+0x10]
  2202f2:	test   rbx,rbx
  2202f5:	je     220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2202fb:	mov    r10d,r9d
  2202fe:	mov    ebp,esi
  220300:	mov    r14,QWORD PTR [rdi]
  220303:	mov    r9,QWORD PTR [rdi+0x18]
  220307:	mov    r15,QWORD PTR [rdi+0x20]
  22030b:	mov    rax,QWORD PTR [rdx+0x10]
  22030f:	test   rax,rax
  220312:	je     2203a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd9>
  220318:	mov    rsi,QWORD PTR [rdx]
  22031b:	mov    r13,QWORD PTR [rdx+0x8]
  22031f:	mov    r11,QWORD PTR [rdx+0x18]
  220323:	test   r9,r9
  220326:	mov    QWORD PTR [rsp+0x30],rax
  22032b:	mov    QWORD PTR [rsp+0x20],r13
  220330:	mov    DWORD PTR [rsp+0xc],r10d
  220335:	mov    DWORD PTR [rsp+0x28],ecx
  220339:	jns    220370 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0>
  22033b:	lea    rax,[r12-0x1]
  220340:	imul   rax,r9
  220344:	neg    r9
  220347:	mov    r10,rsi
  22034a:	xor    esi,esi
  22034c:	mov    rdi,r13
  22034f:	sub    rdi,0x1
  220353:	cmovb  rdi,rsi
  220357:	lea    r14,[r14+rax*8]
  22035b:	mov    rax,r11
  22035e:	imul   rax,rdi
  220362:	cmp    rdi,r13
  220365:	cmove  rax,rsi
  220369:	lea    rsi,[r10+rax*8]
  22036d:	neg    r11
  220370:	mov    QWORD PTR [rsp+0x68],r11
  220375:	mov    r11,QWORD PTR [rdx+0x20]
  220379:	mov    rdi,QWORD PTR [r8]
  22037c:	mov    rax,QWORD PTR [r8+0x8]
  220380:	mov    rcx,QWORD PTR [r8+0x10]
  220384:	mov    r13,QWORD PTR [r8+0x20]
  220388:	test   r15,r15
  22038b:	mov    QWORD PTR [rsp+0x18],rax
  220390:	js     2203f8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x128>
  220392:	mov    rax,QWORD PTR [r8+0x18]
  220396:	test   r11,r11
  220399:	js     220456 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x186>
  22039f:	mov    QWORD PTR [rsp+0x10],r11
  2203a4:	jmp    2204b1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1e1>
  2203a9:	test   bpl,bpl
  2203ac:	jne    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2203b2:	cmp    r12,0x1
  2203b6:	je     2203cc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfc>
  2203b8:	cmp    r9,0xffffffffffffffff
  2203bc:	je     220af4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x824>
  2203c2:	cmp    r9,0x1
  2203c6:	je     2208dc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x60c>
  2203cc:	cmp    rbx,0x1
  2203d0:	je     2208d2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x602>
  2203d6:	cmp    r15,0xffffffffffffffff
  2203da:	je     220b4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x87f>
  2203e0:	cmp    r15,0x1
  2203e4:	jne    2208d2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x602>
  2203ea:	mov    rax,rbx
  2203ed:	mov    rbx,r12
  2203f0:	mov    r15,r9
  2203f3:	jmp    220b64 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  2203f8:	lea    rdx,[rbx-0x1]
  2203fc:	imul   rdx,r15
  220400:	lea    r14,[r14+rdx*8]
  220404:	neg    r15
  220407:	xor    r10d,r10d
  22040a:	mov    edx,ebp
  22040c:	mov    rbp,rsi
  22040f:	mov    rsi,rcx
  220412:	sub    rsi,0x1
  220416:	cmovb  rsi,r10
  22041a:	mov    r10,r11
  22041d:	mov    r11,rdi
  220420:	mov    rdi,r13
  220423:	imul   rdi,rsi
  220427:	cmp    rsi,rcx
  22042a:	mov    rsi,rbp
  22042d:	mov    ebp,edx
  22042f:	mov    edx,0x0
  220434:	cmove  rdi,rdx
  220438:	test   rax,rax
  22043b:	cmove  rdi,rax
  22043f:	lea    rdi,[r11+rdi*8]
  220443:	mov    r11,r10
  220446:	neg    r13
  220449:	mov    rax,QWORD PTR [r8+0x18]
  22044d:	test   r11,r11
  220450:	jns    22039f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf>
  220456:	mov    rdx,QWORD PTR [rsp+0x30]
  22045b:	dec    rdx
  22045e:	imul   rdx,r11
  220462:	mov    r8,QWORD PTR [rsp+0x20]
  220467:	test   r8,r8
  22046a:	cmove  rdx,r8
  22046e:	lea    rsi,[rsi+rdx*8]
  220472:	neg    r11
  220475:	mov    QWORD PTR [rsp+0x10],r11
  22047a:	xor    edx,edx
  22047c:	mov    r11,rsi
  22047f:	mov    r10,QWORD PTR [rsp+0x18]
  220484:	mov    rsi,r10
  220487:	sub    rsi,0x1
  22048b:	cmovb  rsi,rdx
  22048f:	mov    r8,rdi
  220492:	mov    rdi,rax
  220495:	imul   rdi,rsi
  220499:	test   rcx,rcx
  22049c:	cmove  rdi,rcx
  2204a0:	cmp    rsi,r10
  2204a3:	mov    rsi,r11
  2204a6:	cmove  rdi,rdx
  2204aa:	lea    rdi,[r8+rdi*8]
  2204ae:	neg    rax
  2204b1:	mov    r10,QWORD PTR [rsp+0x148]
  2204b9:	mov    r11,QWORD PTR [rsp+0x140]
  2204c1:	cmp    rbx,0x1
  2204c5:	mov    r8,QWORD PTR [rsp+0x68]
  2204ca:	jne    2205c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  2204d0:	cmp    r8,0x1
  2204d4:	jne    22054f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  2204d6:	cmp    r9,0x1
  2204da:	jne    22054f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  2204dc:	test   r14,r14
  2204df:	je     22054f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x27f>
  2204e1:	mov    QWORD PTR [rsp+0x78],rsi
  2204e6:	mov    rcx,QWORD PTR [rsp+0x20]
  2204eb:	mov    QWORD PTR [rsp+0x80],rcx
  2204f3:	mov    rcx,rax
  2204f6:	mov    rax,QWORD PTR [rsp+0x30]
  2204fb:	mov    QWORD PTR [rsp+0x88],rax
  220503:	mov    rax,QWORD PTR [rsp+0x10]
  220508:	mov    QWORD PTR [rsp+0x90],rax
  220510:	mov    QWORD PTR [rsp+0x40],rdi
  220515:	mov    rax,QWORD PTR [rsp+0x18]
  22051a:	mov    QWORD PTR [rsp+0x48],rax
  22051f:	mov    QWORD PTR [rsp+0x50],rcx
  220524:	sub    rsp,0x8
  220528:	movzx  eax,BYTE PTR [rsp+0x14]
  22052d:	movzx  edx,bpl
  220531:	movzx  r8d,BYTE PTR [rsp+0x30]
  220537:	lea    rcx,[rsp+0x80]
  22053f:	lea    r9,[rsp+0x48]
  220544:	mov    rdi,r14
  220547:	mov    rsi,r12
  22054a:	jmp    220644 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x374>
  22054f:	cmp    QWORD PTR [rsp+0x10],0x1
  220555:	jne    2205c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  220557:	cmp    rax,0x1
  22055b:	jne    2205c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  22055d:	test   rdi,rdi
  220560:	je     2205c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2f4>
  220562:	mov    QWORD PTR [rsp+0x78],rsi
  220567:	mov    rax,QWORD PTR [rsp+0x20]
  22056c:	mov    QWORD PTR [rsp+0x80],rax
  220574:	mov    rax,QWORD PTR [rsp+0x30]
  220579:	mov    QWORD PTR [rsp+0x88],rax
  220581:	mov    QWORD PTR [rsp+0x90],r8
  220589:	mov    QWORD PTR [rsp+0x40],r14
  22058e:	mov    QWORD PTR [rsp+0x48],r12
  220593:	mov    QWORD PTR [rsp+0x50],r9
  220598:	sub    rsp,0x8
  22059c:	movzx  eax,BYTE PTR [rsp+0x14]
  2205a1:	movzx  esi,bpl
  2205a5:	movzx  ecx,BYTE PTR [rsp+0x30]
  2205aa:	mov    r8,rdi
  2205ad:	lea    rdi,[rsp+0x48]
  2205b2:	lea    rdx,[rsp+0x80]
  2205ba:	mov    r9,QWORD PTR [rsp+0x20]
  2205bf:	jmp    2206c6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3f6>
  2205c4:	cmp    r12,0x1
  2205c8:	jne    2206d9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  2205ce:	xor    edx,edx
  2205d0:	cmp    r15,0x1
  2205d4:	cmove  rdx,r14
  2205d8:	cmp    r13,0x1
  2205dc:	jne    220657 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x387>
  2205de:	test   rdx,rdx
  2205e1:	je     220657 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x387>
  2205e3:	mov    QWORD PTR [rsp+0x78],rdi
  2205e8:	mov    QWORD PTR [rsp+0x80],rcx
  2205f0:	mov    rcx,QWORD PTR [rsp+0x18]
  2205f5:	mov    QWORD PTR [rsp+0x88],rcx
  2205fd:	mov    QWORD PTR [rsp+0x90],rax
  220605:	mov    QWORD PTR [rsp+0x40],rsi
  22060a:	mov    rax,QWORD PTR [rsp+0x30]
  22060f:	mov    QWORD PTR [rsp+0x48],rax
  220614:	mov    rax,QWORD PTR [rsp+0x10]
  220619:	mov    QWORD PTR [rsp+0x50],rax
  22061e:	sub    rsp,0x8
  220622:	movzx  eax,BYTE PTR [rsp+0x30]
  220627:	movzx  edx,bpl
  22062b:	movzx  r8d,BYTE PTR [rsp+0x14]
  220631:	lea    rcx,[rsp+0x80]
  220639:	lea    r9,[rsp+0x48]
  22063e:	mov    rdi,r14
  220641:	mov    rsi,rbx
  220644:	push   r10
  220646:	push   r11
  220648:	push   rax
  220649:	call   14da00 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  22064e:	add    rsp,0x20
  220652:	jmp    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220657:	xor    edx,edx
  220659:	cmp    QWORD PTR [rsp+0x10],0x1
  22065f:	cmove  rdx,rsi
  220663:	cmp    rax,0x1
  220667:	jne    2206d9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  220669:	test   rdx,rdx
  22066c:	je     2206d9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x409>
  22066e:	mov    QWORD PTR [rsp+0x78],rdi
  220673:	mov    QWORD PTR [rsp+0x80],rcx
  22067b:	mov    rax,QWORD PTR [rsp+0x18]
  220680:	mov    QWORD PTR [rsp+0x88],rax
  220688:	mov    QWORD PTR [rsp+0x90],r13
  220690:	mov    QWORD PTR [rsp+0x40],r14
  220695:	mov    QWORD PTR [rsp+0x48],rbx
  22069a:	mov    QWORD PTR [rsp+0x50],r15
  22069f:	sub    rsp,0x8
  2206a3:	movzx  eax,BYTE PTR [rsp+0x30]
  2206a8:	mov    r8,rsi
  2206ab:	movzx  esi,bpl
  2206af:	movzx  ecx,BYTE PTR [rsp+0x14]
  2206b4:	lea    rdi,[rsp+0x48]
  2206b9:	lea    rdx,[rsp+0x80]
  2206c1:	mov    r9,QWORD PTR [rsp+0x38]
  2206c6:	push   r10
  2206c8:	push   r11
  2206ca:	push   rax
  2206cb:	call   204f70 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  2206d0:	add    rsp,0x20
  2206d4:	jmp    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2206d9:	mov    r10,QWORD PTR [rsp+0x30]
  2206de:	cmp    r10,0x1
  2206e2:	jne    2207e0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  2206e8:	xor    edx,edx
  2206ea:	cmp    r9,0x1
  2206ee:	cmove  rdx,r14
  2206f2:	cmp    r8,0x1
  2206f6:	jne    22075d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x48d>
  2206f8:	test   rdx,rdx
  2206fb:	je     22075d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x48d>
  2206fd:	mov    QWORD PTR [rsp+0x78],rdx
  220702:	mov    QWORD PTR [rsp+0x80],r12
  22070a:	mov    QWORD PTR [rsp+0x88],rbx
  220712:	mov    QWORD PTR [rsp+0x90],r15
  22071a:	mov    QWORD PTR [rsp+0x40],rdi
  22071f:	mov    QWORD PTR [rsp+0x48],rcx
  220724:	mov    QWORD PTR [rsp+0x50],r13
  220729:	sub    rsp,0x8
  22072d:	movzx  eax,BYTE PTR [rsp+0x14]
  220732:	mov    rdx,rsi
  220735:	movzx  esi,bpl
  220739:	movzx  r8d,BYTE PTR [rsp+0x30]
  22073f:	lea    rdi,[rsp+0x80]
  220747:	lea    r9,[rsp+0x48]
  22074c:	mov    rcx,QWORD PTR [rsp+0x28]
  220751:	push   QWORD PTR [rsp+0x150]
  220758:	push   r11
  22075a:	push   rax
  22075b:	jmp    2207d2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x502>
  22075d:	xor    edx,edx
  22075f:	cmp    r15,0x1
  220763:	cmove  rdx,r14
  220767:	cmp    r13,0x1
  22076b:	jne    2207e0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  22076d:	test   rdx,rdx
  220770:	je     2207e0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x510>
  220772:	mov    QWORD PTR [rsp+0x78],rdx
  220777:	mov    QWORD PTR [rsp+0x80],rbx
  22077f:	mov    QWORD PTR [rsp+0x88],r12
  220787:	mov    QWORD PTR [rsp+0x90],r9
  22078f:	mov    QWORD PTR [rsp+0x40],rsi
  220794:	mov    rax,QWORD PTR [rsp+0x20]
  220799:	mov    QWORD PTR [rsp+0x48],rax
  22079e:	mov    QWORD PTR [rsp+0x50],r8
  2207a3:	sub    rsp,0x8
  2207a7:	movzx  r10d,BYTE PTR [rsp+0x30]
  2207ad:	movzx  esi,bpl
  2207b1:	movzx  r8d,BYTE PTR [rsp+0x14]
  2207b7:	mov    rdx,rdi
  2207ba:	lea    rdi,[rsp+0x80]
  2207c2:	lea    r9,[rsp+0x48]
  2207c7:	push   QWORD PTR [rsp+0x150]
  2207ce:	push   r11
  2207d0:	push   r10
  2207d2:	call   14ca20 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  2207d7:	add    rsp,0x20
  2207db:	jmp    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  2207e0:	mov    QWORD PTR [rsp+0x18],rax
  2207e5:	movsd  xmm1,QWORD PTR [r11]
  2207ea:	mov    rax,r12
  2207ed:	mul    rbx
  2207f0:	movsd  QWORD PTR [rsp+0x40],xmm1
  2207f6:	seto   BYTE PTR [rsp+0xb]
  2207fb:	mov    QWORD PTR [rsp+0x20],rax
  220800:	jo     220c17 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x947>
  220806:	mul    r10
  220809:	seto   cl
  22080c:	not    cl
  22080e:	cmp    rax,0x1001
  220814:	setb   al
  220817:	test   cl,al
  220819:	mov    r11,QWORD PTR [rsp+0x10]
  22081e:	jne    22087e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ae>
  220820:	mov    rdx,QWORD PTR [rip+0x32b691]        # 54beb8 <_DYNAMIC+0x450>
  220827:	mov    rax,QWORD PTR [rdx]
  22082a:	test   rax,rax
  22082d:	mov    QWORD PTR [rsp+0x70],rsi
  220832:	je     220c23 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x953>
  220838:	mov    cl,0x1
  22083a:	test   eax,0x80000
  22083f:	jne    220cfd <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2d>
  220845:	mov    rax,QWORD PTR [rdx]
  220848:	test   rax,rax
  22084b:	je     220c71 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9a1>
  220851:	test   ax,ax
  220854:	jns    22086d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220856:	mov    rax,QWORD PTR [rdx]
  220859:	test   rax,rax
  22085c:	je     220cbb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9eb>
  220862:	bt     rax,0x37
  220867:	jb     220cfb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2b>
  22086d:	test   bpl,bpl
  220870:	jne    220af9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x829>
  220876:	xorps  xmm0,xmm0
  220879:	jmp    220b01 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x831>
  22087e:	test   bpl,bpl
  220881:	mov    ecx,DWORD PTR [rsp+0x28]
  220885:	jne    2208e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x614>
  220887:	xorps  xmm0,xmm0
  22088a:	movsd  QWORD PTR [rsp+0x20],xmm0
  220890:	cmp    r15,r9
  220893:	jb     2208f7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x627>
  220895:	mov    eax,DWORD PTR [rsp+0xc]
  220899:	mov    BYTE PTR [rsp+0xb],al
  22089d:	mov    eax,ecx
  22089f:	mov    DWORD PTR [rsp+0xc],eax
  2208a3:	mov    QWORD PTR [rsp+0x28],r13
  2208a8:	mov    rax,QWORD PTR [rsp+0x18]
  2208ad:	mov    QWORD PTR [rsp+0x70],rax
  2208b2:	mov    QWORD PTR [rsp+0x38],rdi
  2208b7:	mov    QWORD PTR [rsp+0x18],r11
  2208bc:	mov    rax,r8
  2208bf:	mov    rdi,rsi
  2208c2:	mov    QWORD PTR [rsp+0x10],r15
  2208c7:	mov    r15,r9
  2208ca:	mov    rbp,rbx
  2208cd:	mov    rbx,r12
  2208d0:	jmp    220915 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x645>
  2208d2:	cmp    r9,0x1
  2208d6:	jne    220a2f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x75f>
  2208dc:	mov    rax,r12
  2208df:	jmp    220b64 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  2208e4:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1f2ec]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  2208ec:	movsd  QWORD PTR [rsp+0x20],xmm0
  2208f2:	cmp    r15,r9
  2208f5:	jae    220895 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c5>
  2208f7:	mov    BYTE PTR [rsp+0xb],cl
  2208fb:	mov    QWORD PTR [rsp+0x28],r8
  220900:	mov    QWORD PTR [rsp+0x70],r11
  220905:	mov    QWORD PTR [rsp+0x38],rsi
  22090a:	mov    QWORD PTR [rsp+0x10],r9
  22090f:	mov    rbp,r12
  220912:	mov    rax,r13
  220915:	movsd  QWORD PTR [rsp+0x58],xmm1
  22091b:	mov    QWORD PTR [rsp+0x60],rdi
  220920:	mov    r13,rax
  220923:	cmp    rax,0x1
  220927:	jne    22094f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x67f>
  220929:	cmp    r15,0x1
  22092d:	jne    22094f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x67f>
  22092f:	lea    r8,[rip+0x32030a]        # 540c40 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x410>
  220936:	lea    rdi,[rsp+0x78]
  22093b:	mov    rsi,rbx
  22093e:	mov    rdx,rbp
  220941:	mov    rcx,r10
  220944:	mov    r12,r10
  220947:	call   QWORD PTR [rip+0x32b87b]        # 54c1c8 <_DYNAMIC+0x760>
  22094d:	jmp    22096d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x69d>
  22094f:	lea    r8,[rip+0x320302]        # 540c58 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x428>
  220956:	lea    rdi,[rsp+0x78]
  22095b:	mov    rsi,rbx
  22095e:	mov    rdx,rbp
  220961:	mov    rcx,r10
  220964:	mov    r12,r10
  220967:	call   QWORD PTR [rip+0x32b863]        # 54c1d0 <_DYNAMIC+0x768>
  22096d:	lea    rdi,[rsp+0x80]
  220975:	mov    rsi,QWORD PTR [rsp+0xa0]
  22097d:	mov    rdx,QWORD PTR [rsp+0xa8]
  220985:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  22098d:	sub    rsp,0x70
  220991:	movups XMMWORD PTR [rsp+0x58],xmm0
  220996:	movzx  eax,BYTE PTR [rsp+0x7b]
  22099b:	mov    DWORD PTR [rsp+0x50],eax
  22099f:	movzx  eax,BYTE PTR [rsp+0x7c]
  2209a4:	mov    DWORD PTR [rsp+0x48],eax
  2209a8:	mov    rax,QWORD PTR [rsp+0x98]
  2209b0:	mov    QWORD PTR [rsp+0x40],rax
  2209b5:	mov    rax,QWORD PTR [rsp+0xe0]
  2209bd:	mov    QWORD PTR [rsp+0x38],rax
  2209c2:	mov    rax,QWORD PTR [rsp+0xa8]
  2209ca:	mov    QWORD PTR [rsp+0x30],rax
  2209cf:	mov    rax,QWORD PTR [rsp+0x88]
  2209d7:	mov    QWORD PTR [rsp+0x28],rax
  2209dc:	mov    QWORD PTR [rsp+0x20],r13
  2209e1:	mov    rax,QWORD PTR [rsp+0xd0]
  2209e9:	mov    QWORD PTR [rsp+0x18],rax
  2209ee:	mov    rax,QWORD PTR [rsp+0x80]
  2209f6:	mov    QWORD PTR [rsp+0x10],rax
  2209fb:	mov    QWORD PTR [rsp+0x8],r15
  220a00:	mov    QWORD PTR [rsp],r14
  220a04:	mov    r8,rbp
  220a07:	mov    r9,r12
  220a0a:	mov    rcx,rbx
  220a0d:	movsd  xmm0,QWORD PTR [rsp+0x90]
  220a16:	movsd  xmm1,QWORD PTR [rsp+0xc8]
  220a1f:	call   QWORD PTR [rsp+0xe8]
  220a26:	add    rsp,0x70
  220a2a:	jmp    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220a2f:	lea    rax,[r12-0x1]
  220a34:	mov    ecx,r12d
  220a37:	and    ecx,0x3
  220a3a:	and    r12,0xfffffffffffffffc
  220a3e:	lea    rdx,[r9*8+0x0]
  220a46:	lea    rsi,[rdx+rdx*2]
  220a4a:	shl    r15,0x3
  220a4e:	mov    rdi,r9
  220a51:	shl    rdi,0x5
  220a55:	mov    r8,r9
  220a58:	shl    r8,0x4
  220a5c:	xor    r10d,r10d
  220a5f:	jmp    220a7f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7af>
  220a61:	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  220a70:	inc    r10
  220a73:	add    r14,r15
  220a76:	cmp    r10,rbx
  220a79:	je     220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220a7f:	cmp    rax,0x3
  220a83:	jae    220a90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c0>
  220a85:	xor    r11d,r11d
  220a88:	jmp    220ad4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x804>
  220a8a:	nop    WORD PTR [rax+rax*1+0x0]
  220a90:	mov    r13,r14
  220a93:	xor    r11d,r11d
  220a96:	cs nop WORD PTR [rax+rax*1+0x0]
  220aa0:	mov    QWORD PTR [r13+0x0],0x0
  220aa8:	mov    QWORD PTR [r13+r9*8+0x0],0x0
  220ab1:	mov    QWORD PTR [r13+r8*1+0x0],0x0
  220aba:	add    r11,0x4
  220abe:	mov    QWORD PTR [r13+rsi*1+0x0],0x0
  220ac7:	add    r13,rdi
  220aca:	cmp    r12,r11
  220acd:	jne    220aa0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7d0>
  220acf:	test   rcx,rcx
  220ad2:	je     220a70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  220ad4:	imul   r11,rdx
  220ad8:	add    r11,r14
  220adb:	mov    r13,rcx
  220ade:	xchg   ax,ax
  220ae0:	mov    QWORD PTR [r11],0x0
  220ae7:	add    r11,rdx
  220aea:	dec    r13
  220aed:	jne    220ae0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x810>
  220aef:	jmp    220a70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  220af4:	mov    rax,r12
  220af7:	jmp    220b58 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x888>
  220af9:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1f0d7]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  220b01:	mov    r11,rdi
  220b04:	mov    rax,QWORD PTR [rsp+0x148]
  220b0c:	test   rax,rax
  220b0f:	je     220bd5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x905>
  220b15:	sub    rsp,0x8
  220b19:	movzx  ebp,bpl
  220b1d:	mov    rdi,r12
  220b20:	mov    rsi,rbx
  220b23:	mov    rdx,r10
  220b26:	mov    rcx,r14
  220b29:	mov    r8,r15
  220b2c:	push   rax
  220b2d:	push   0x1
  220b2f:	push   QWORD PTR [rsp+0x30]
  220b33:	push   r13
  220b35:	push   r11
  220b37:	push   QWORD PTR [rsp+0x98]
  220b3e:	push   QWORD PTR [rsp+0x48]
  220b42:	push   QWORD PTR [rsp+0xb0]
  220b49:	push   rbp
  220b4a:	jmp    220c09 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x939>
  220b4f:	mov    rax,rbx
  220b52:	mov    rbx,r12
  220b55:	mov    r15,r9
  220b58:	mov    ecx,0x1
  220b5d:	sub    rcx,rax
  220b60:	lea    r14,[r14+rcx*8]
  220b64:	lea    rcx,[rax-0x1]
  220b68:	mov    edx,eax
  220b6a:	and    edx,0x3
  220b6d:	and    rax,0xfffffffffffffffc
  220b71:	xor    esi,esi
  220b73:	xorps  xmm0,xmm0
  220b76:	jmp    220b8c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8bc>
  220b78:	nop    DWORD PTR [rax+rax*1+0x0]
  220b80:	inc    rsi
  220b83:	cmp    rsi,rbx
  220b86:	je     220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220b8c:	mov    rdi,rsi
  220b8f:	imul   rdi,r15
  220b93:	lea    rdi,[r14+rdi*8]
  220b97:	cmp    rcx,0x3
  220b9b:	jb     220bb9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8e9>
  220b9d:	xor    r8d,r8d
  220ba0:	movups XMMWORD PTR [rdi],xmm0
  220ba3:	movups XMMWORD PTR [rdi+0x10],xmm0
  220ba7:	add    rdi,0x20
  220bab:	add    r8,0x4
  220baf:	cmp    rax,r8
  220bb2:	jne    220ba0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8d0>
  220bb4:	test   rdx,rdx
  220bb7:	je     220b80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  220bb9:	xor    r8d,r8d
  220bbc:	nop    DWORD PTR [rax+0x0]
  220bc0:	mov    QWORD PTR [rdi],0x0
  220bc7:	add    rdi,0x8
  220bcb:	inc    r8
  220bce:	cmp    rdx,r8
  220bd1:	jne    220bc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f0>
  220bd3:	jmp    220b80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  220bd5:	sub    rsp,0x10
  220bd9:	movzx  eax,bpl
  220bdd:	mov    rdi,r12
  220be0:	mov    rsi,rbx
  220be3:	mov    rdx,r10
  220be6:	mov    rcx,r14
  220be9:	mov    r8,r15
  220bec:	push   0x0
  220bee:	push   QWORD PTR [rsp+0x30]
  220bf2:	push   r13
  220bf4:	push   r11
  220bf6:	push   QWORD PTR [rsp+0x98]
  220bfd:	push   QWORD PTR [rsp+0x48]
  220c01:	push   QWORD PTR [rsp+0xb0]
  220c08:	push   rax
  220c09:	call   20b160 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmdECscfHK10Grmvq_6fbench>
  220c0e:	add    rsp,0x50
  220c12:	jmp    220e06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb36>
  220c17:	mov    rax,0xffffffffffffffff
  220c1e:	jmp    220806 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x536>
  220c23:	mov    QWORD PTR [rsp+0x38],r9
  220c28:	mov    QWORD PTR [rsp+0x60],rdi
  220c2d:	movsd  QWORD PTR [rsp+0x58],xmm1
  220c33:	call   QWORD PTR [rip+0x32b287]        # 54bec0 <_DYNAMIC+0x458>
  220c39:	mov    rdx,QWORD PTR [rip+0x32b278]        # 54beb8 <_DYNAMIC+0x450>
  220c40:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220c46:	mov    r11,QWORD PTR [rsp+0x10]
  220c4b:	mov    r8,QWORD PTR [rsp+0x68]
  220c50:	mov    rdi,QWORD PTR [rsp+0x60]
  220c55:	mov    r10,QWORD PTR [rsp+0x30]
  220c5a:	mov    r9,QWORD PTR [rsp+0x38]
  220c5f:	mov    cl,0x1
  220c61:	test   eax,0x80000
  220c66:	je     220845 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x575>
  220c6c:	jmp    220cfd <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa2d>
  220c71:	mov    QWORD PTR [rsp+0x38],r9
  220c76:	mov    QWORD PTR [rsp+0x60],rdi
  220c7b:	movsd  QWORD PTR [rsp+0x58],xmm1
  220c81:	call   QWORD PTR [rip+0x32b239]        # 54bec0 <_DYNAMIC+0x458>
  220c87:	mov    rdx,QWORD PTR [rip+0x32b22a]        # 54beb8 <_DYNAMIC+0x450>
  220c8e:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220c94:	mov    r11,QWORD PTR [rsp+0x10]
  220c99:	mov    r8,QWORD PTR [rsp+0x68]
  220c9e:	mov    rdi,QWORD PTR [rsp+0x60]
  220ca3:	mov    r10,QWORD PTR [rsp+0x30]
  220ca8:	mov    r9,QWORD PTR [rsp+0x38]
  220cad:	test   ax,ax
  220cb0:	js     220856 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x586>
  220cb6:	jmp    22086d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220cbb:	mov    QWORD PTR [rsp+0x38],r9
  220cc0:	mov    QWORD PTR [rsp+0x60],rdi
  220cc5:	movsd  QWORD PTR [rsp+0x58],xmm1
  220ccb:	call   QWORD PTR [rip+0x32b1ef]        # 54bec0 <_DYNAMIC+0x458>
  220cd1:	movsd  xmm1,QWORD PTR [rsp+0x58]
  220cd7:	mov    r11,QWORD PTR [rsp+0x10]
  220cdc:	mov    r8,QWORD PTR [rsp+0x68]
  220ce1:	mov    rdi,QWORD PTR [rsp+0x60]
  220ce6:	mov    r10,QWORD PTR [rsp+0x30]
  220ceb:	mov    r9,QWORD PTR [rsp+0x38]
  220cf0:	bt     rax,0x37
  220cf5:	jae    22086d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  220cfb:	xor    ecx,ecx
  220cfd:	cmp    BYTE PTR [rsp+0xb],0x0
  220d02:	jne    220e18 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb48>
  220d08:	mov    rax,QWORD PTR [rsp+0x20]
  220d0d:	mul    r10
  220d10:	jo     220e2f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb5f>
  220d16:	test   rax,rax
  220d19:	js     220e2f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb5f>
  220d1f:	mov    rdx,QWORD PTR [rip+0x32b1aa]        # 54bed0 <_DYNAMIC+0x468>
  220d26:	mov    rdx,QWORD PTR [rdx]
  220d29:	movabs rsi,0x7fffffffffffffff
  220d33:	and    rsi,rdx
  220d36:	mov    edx,0x1
  220d3b:	cmp    rax,rsi
  220d3e:	jb     220d50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa80>
  220d40:	mov    rdx,QWORD PTR [rsp+0x148]
  220d48:	cmp    rdx,0x1
  220d4c:	adc    rdx,0x0
  220d50:	sub    rsp,0xa0
  220d57:	mov    QWORD PTR [rsp+0x90],rdx
  220d5f:	lea    rax,[rsp+0xe0]
  220d67:	mov    QWORD PTR [rsp+0x88],rax
  220d6f:	movzx  eax,BYTE PTR [rsp+0xac]
  220d77:	mov    DWORD PTR [rsp+0x80],eax
  220d7e:	mov    QWORD PTR [rsp+0x78],r13
  220d83:	mov    rax,QWORD PTR [rsp+0xb8]
  220d8b:	mov    QWORD PTR [rsp+0x70],rax
  220d90:	mov    QWORD PTR [rsp+0x68],rdi
  220d95:	xorps  xmm0,xmm0
  220d98:	movups XMMWORD PTR [rsp+0x58],xmm0
  220d9d:	movzx  eax,BYTE PTR [rsp+0xc8]
  220da5:	mov    DWORD PTR [rsp+0x50],eax
  220da9:	mov    QWORD PTR [rsp+0x48],r11
  220dae:	mov    QWORD PTR [rsp+0x40],r8
  220db3:	mov    rax,QWORD PTR [rsp+0x110]
  220dbb:	mov    QWORD PTR [rsp+0x38],rax
  220dc0:	movzx  eax,bpl
  220dc4:	mov    DWORD PTR [rsp+0x30],eax
  220dc8:	movups XMMWORD PTR [rsp+0x18],xmm0
  220dcd:	mov    QWORD PTR [rsp+0x10],r15
  220dd2:	mov    QWORD PTR [rsp+0x8],r9
  220dd7:	mov    QWORD PTR [rsp],r14
  220ddb:	mov    DWORD PTR [rsp+0x28],0x2
  220de3:	movzx  edx,cl
  220de6:	mov    r8,rbx
  220de9:	mov    edi,0x1
  220dee:	mov    r9,r10
  220df1:	mov    esi,0x1
  220df6:	mov    rcx,r12
  220df9:	call   QWORD PTR [rip+0x32b0c9]        # 54bec8 <_DYNAMIC+0x460>
  220dff:	add    rsp,0xa0
  220e06:	add    rsp,0x108
  220e0d:	pop    rbx
  220e0e:	pop    r12
  220e10:	pop    r13
  220e12:	pop    r14
  220e14:	pop    r15
  220e16:	pop    rbp
  220e17:	ret
  220e18:	mov    QWORD PTR [rsp+0x20],0xffffffffffffffff
  220e21:	mov    rax,QWORD PTR [rsp+0x20]
  220e26:	mul    r10
  220e29:	jno    220d16 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa46>
  220e2f:	mov    rax,QWORD PTR [rip+0x32b09a]        # 54bed0 <_DYNAMIC+0x468>
  220e36:	mov    rax,QWORD PTR [rax]
  220e39:	jmp    220d40 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
