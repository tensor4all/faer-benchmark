
target/faer-rev/60de2ee06467-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001e32c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  1e32c0:	push   rbp
  1e32c1:	push   r15
  1e32c3:	push   r14
  1e32c5:	push   r13
  1e32c7:	push   r12
  1e32c9:	push   rbx
  1e32ca:	sub    rsp,0x128
  1e32d1:	mov    r12,QWORD PTR [rdi+0x8]
  1e32d5:	test   r12,r12
  1e32d8:	je     1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e32de:	mov    r15,QWORD PTR [rdi+0x10]
  1e32e2:	test   r15,r15
  1e32e5:	je     1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e32eb:	mov    rbx,QWORD PTR [rdi]
  1e32ee:	mov    r14,QWORD PTR [rdi+0x18]
  1e32f2:	mov    rbp,QWORD PTR [rdi+0x20]
  1e32f6:	mov    rax,QWORD PTR [rdx+0x10]
  1e32fa:	mov    QWORD PTR [rsp+0x40],rax
  1e32ff:	test   rax,rax
  1e3302:	je     1e33b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf8>
  1e3308:	mov    DWORD PTR [rsp+0x20],r9d
  1e330d:	mov    DWORD PTR [rsp+0x38],esi
  1e3311:	mov    DWORD PTR [rsp+0x10],ecx
  1e3315:	mov    r13,QWORD PTR [rdx]
  1e3318:	mov    rcx,QWORD PTR [rdx+0x8]
  1e331c:	mov    rsi,QWORD PTR [rdx+0x18]
  1e3320:	test   r14,r14
  1e3323:	mov    QWORD PTR [rsp+0x30],rcx
  1e3328:	jns    1e3368 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa8>
  1e332a:	lea    rax,[r12-0x1]
  1e332f:	imul   rax,r14
  1e3333:	shl    rax,0x4
  1e3337:	add    rbx,rax
  1e333a:	neg    r14
  1e333d:	xor    eax,eax
  1e333f:	mov    r9,rsi
  1e3342:	mov    rsi,rcx
  1e3345:	sub    rsi,0x1
  1e3349:	cmovb  rsi,rax
  1e334d:	mov    rdi,r9
  1e3350:	imul   rdi,rsi
  1e3354:	cmp    rsi,rcx
  1e3357:	mov    rsi,r9
  1e335a:	cmove  rdi,rax
  1e335e:	shl    rdi,0x4
  1e3362:	add    r13,rdi
  1e3365:	neg    rsi
  1e3368:	mov    rax,QWORD PTR [rdx+0x20]
  1e336c:	mov    rdi,QWORD PTR [r8]
  1e336f:	mov    r10,QWORD PTR [r8+0x8]
  1e3373:	mov    r9,QWORD PTR [r8+0x10]
  1e3377:	mov    rcx,QWORD PTR [r8+0x20]
  1e337b:	test   rbp,rbp
  1e337e:	mov    QWORD PTR [rsp+0x50],r9
  1e3383:	mov    QWORD PTR [rsp+0x28],r10
  1e3388:	js     1e3407 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x147>
  1e338a:	mov    r11,QWORD PTR [r8+0x18]
  1e338e:	test   rax,rax
  1e3391:	js     1e3475 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b5>
  1e3397:	mov    QWORD PTR [rsp+0x18],r13
  1e339c:	mov    r10,QWORD PTR [rsp+0x160]
  1e33a4:	cmp    r15,0x1
  1e33a8:	mov    r8,QWORD PTR [rsp+0x50]
  1e33ad:	je     1e34f6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x236>
  1e33b3:	jmp    1e35f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1e33b8:	test   sil,sil
  1e33bb:	jne    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e33c1:	cmp    r12,0x1
  1e33c5:	je     1e33db <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x11b>
  1e33c7:	cmp    r14,0xffffffffffffffff
  1e33cb:	je     1e3b5e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89e>
  1e33d1:	cmp    r14,0x1
  1e33d5:	je     1e38fb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x63b>
  1e33db:	cmp    r15,0x1
  1e33df:	je     1e38f1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1e33e5:	cmp    rbp,0xffffffffffffffff
  1e33e9:	je     1e3cca <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0a>
  1e33ef:	cmp    rbp,0x1
  1e33f3:	jne    1e38f1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1e33f9:	mov    rax,r15
  1e33fc:	mov    r15,r12
  1e33ff:	mov    rbp,r14
  1e3402:	jmp    1e3ce2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  1e3407:	lea    rdx,[r15-0x1]
  1e340b:	imul   rdx,rbp
  1e340f:	shl    rdx,0x4
  1e3413:	add    rbx,rdx
  1e3416:	neg    rbp
  1e3419:	xor    edx,edx
  1e341b:	mov    r11,rsi
  1e341e:	mov    rsi,r9
  1e3421:	sub    rsi,0x1
  1e3425:	cmovb  rsi,rdx
  1e3429:	mov    rdx,rbp
  1e342c:	mov    rbp,rcx
  1e342f:	mov    rcx,rdi
  1e3432:	mov    rdi,rbp
  1e3435:	imul   rdi,rsi
  1e3439:	cmp    rsi,r9
  1e343c:	mov    rsi,r11
  1e343f:	mov    r10,QWORD PTR [rsp+0x28]
  1e3444:	mov    r9d,0x0
  1e344a:	cmove  rdi,r9
  1e344e:	test   r10,r10
  1e3451:	cmove  rdi,r10
  1e3455:	shl    rdi,0x4
  1e3459:	add    rcx,rdi
  1e345c:	mov    rdi,rcx
  1e345f:	mov    rcx,rbp
  1e3462:	mov    rbp,rdx
  1e3465:	neg    rcx
  1e3468:	mov    r11,QWORD PTR [r8+0x18]
  1e346c:	test   rax,rax
  1e346f:	jns    1e3397 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd7>
  1e3475:	mov    rdx,QWORD PTR [rsp+0x40]
  1e347a:	dec    rdx
  1e347d:	imul   rdx,rax
  1e3481:	mov    r8,QWORD PTR [rsp+0x30]
  1e3486:	test   r8,r8
  1e3489:	cmove  rdx,r8
  1e348d:	shl    rdx,0x4
  1e3491:	add    r13,rdx
  1e3494:	mov    QWORD PTR [rsp+0x18],r13
  1e3499:	neg    rax
  1e349c:	xor    edx,edx
  1e349e:	mov    r8,rsi
  1e34a1:	mov    rsi,r10
  1e34a4:	sub    rsi,0x1
  1e34a8:	cmovb  rsi,rdx
  1e34ac:	mov    r13,rcx
  1e34af:	mov    rcx,rdi
  1e34b2:	mov    rdi,r11
  1e34b5:	imul   rdi,rsi
  1e34b9:	mov    r9,QWORD PTR [rsp+0x50]
  1e34be:	test   r9,r9
  1e34c1:	cmove  rdi,r9
  1e34c5:	cmp    rsi,r10
  1e34c8:	mov    rsi,r8
  1e34cb:	cmove  rdi,rdx
  1e34cf:	shl    rdi,0x4
  1e34d3:	add    rcx,rdi
  1e34d6:	mov    rdi,rcx
  1e34d9:	mov    rcx,r13
  1e34dc:	neg    r11
  1e34df:	mov    r10,QWORD PTR [rsp+0x160]
  1e34e7:	cmp    r15,0x1
  1e34eb:	mov    r8,QWORD PTR [rsp+0x50]
  1e34f0:	jne    1e35f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1e34f6:	cmp    rsi,0x1
  1e34fa:	jne    1e3576 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1e34fc:	cmp    r14,0x1
  1e3500:	jne    1e3576 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1e3502:	test   rbx,rbx
  1e3505:	je     1e3576 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1e3507:	mov    rcx,QWORD PTR [rsp+0x18]
  1e350c:	mov    QWORD PTR [rsp+0x90],rcx
  1e3514:	mov    rcx,QWORD PTR [rsp+0x30]
  1e3519:	mov    QWORD PTR [rsp+0x98],rcx
  1e3521:	mov    rcx,QWORD PTR [rsp+0x40]
  1e3526:	mov    QWORD PTR [rsp+0xa0],rcx
  1e352e:	mov    QWORD PTR [rsp+0xa8],rax
  1e3536:	mov    QWORD PTR [rsp+0x60],rdi
  1e353b:	mov    rax,QWORD PTR [rsp+0x28]
  1e3540:	mov    QWORD PTR [rsp+0x68],rax
  1e3545:	mov    QWORD PTR [rsp+0x70],r11
  1e354a:	sub    rsp,0x8
  1e354e:	movzx  eax,BYTE PTR [rsp+0x28]
  1e3553:	movzx  edx,BYTE PTR [rsp+0x40]
  1e3558:	movzx  r8d,BYTE PTR [rsp+0x18]
  1e355e:	lea    rcx,[rsp+0x98]
  1e3566:	lea    r9,[rsp+0x68]
  1e356b:	mov    rdi,rbx
  1e356e:	mov    rsi,r12
  1e3571:	jmp    1e367a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3ba>
  1e3576:	cmp    rax,0x1
  1e357a:	jne    1e35f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1e357c:	cmp    r11,0x1
  1e3580:	jne    1e35f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1e3582:	test   rdi,rdi
  1e3585:	je     1e35f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1e3587:	mov    rax,QWORD PTR [rsp+0x18]
  1e358c:	mov    QWORD PTR [rsp+0x90],rax
  1e3594:	mov    rax,QWORD PTR [rsp+0x30]
  1e3599:	mov    QWORD PTR [rsp+0x98],rax
  1e35a1:	mov    rax,QWORD PTR [rsp+0x40]
  1e35a6:	mov    QWORD PTR [rsp+0xa0],rax
  1e35ae:	mov    QWORD PTR [rsp+0xa8],rsi
  1e35b6:	mov    QWORD PTR [rsp+0x60],rbx
  1e35bb:	mov    QWORD PTR [rsp+0x68],r12
  1e35c0:	mov    QWORD PTR [rsp+0x70],r14
  1e35c5:	sub    rsp,0x8
  1e35c9:	movzx  eax,BYTE PTR [rsp+0x28]
  1e35ce:	movzx  esi,BYTE PTR [rsp+0x40]
  1e35d3:	movzx  ecx,BYTE PTR [rsp+0x18]
  1e35d8:	mov    r8,rdi
  1e35db:	lea    rdi,[rsp+0x68]
  1e35e0:	lea    rdx,[rsp+0x98]
  1e35e8:	mov    r9,QWORD PTR [rsp+0x30]
  1e35ed:	jmp    1e3707 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x447>
  1e35f2:	cmp    r12,0x1
  1e35f6:	jne    1e371f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1e35fc:	xor    edx,edx
  1e35fe:	cmp    rbp,0x1
  1e3602:	cmove  rdx,rbx
  1e3606:	cmp    rcx,0x1
  1e360a:	jne    1e3692 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  1e3610:	test   rdx,rdx
  1e3613:	je     1e3692 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  1e3615:	mov    QWORD PTR [rsp+0x90],rdi
  1e361d:	mov    QWORD PTR [rsp+0x98],r8
  1e3625:	mov    rcx,QWORD PTR [rsp+0x28]
  1e362a:	mov    QWORD PTR [rsp+0xa0],rcx
  1e3632:	mov    QWORD PTR [rsp+0xa8],r11
  1e363a:	mov    rcx,QWORD PTR [rsp+0x18]
  1e363f:	mov    QWORD PTR [rsp+0x60],rcx
  1e3644:	mov    rcx,QWORD PTR [rsp+0x40]
  1e3649:	mov    QWORD PTR [rsp+0x68],rcx
  1e364e:	mov    QWORD PTR [rsp+0x70],rax
  1e3653:	sub    rsp,0x8
  1e3657:	movzx  eax,BYTE PTR [rsp+0x18]
  1e365c:	movzx  edx,BYTE PTR [rsp+0x40]
  1e3661:	movzx  r8d,BYTE PTR [rsp+0x28]
  1e3667:	lea    rcx,[rsp+0x98]
  1e366f:	lea    r9,[rsp+0x68]
  1e3674:	mov    rdi,rbx
  1e3677:	mov    rsi,r15
  1e367a:	push   QWORD PTR [rsp+0x170]
  1e3681:	push   r10
  1e3683:	push   rax
  1e3684:	call   14e2a0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e3689:	add    rsp,0x20
  1e368d:	jmp    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3692:	xor    edx,edx
  1e3694:	cmp    rax,0x1
  1e3698:	cmove  rdx,QWORD PTR [rsp+0x18]
  1e369e:	cmp    r11,0x1
  1e36a2:	jne    1e371f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1e36a4:	test   rdx,rdx
  1e36a7:	je     1e371f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1e36a9:	mov    QWORD PTR [rsp+0x90],rdi
  1e36b1:	mov    QWORD PTR [rsp+0x98],r8
  1e36b9:	mov    rax,QWORD PTR [rsp+0x28]
  1e36be:	mov    QWORD PTR [rsp+0xa0],rax
  1e36c6:	mov    QWORD PTR [rsp+0xa8],rcx
  1e36ce:	mov    QWORD PTR [rsp+0x60],rbx
  1e36d3:	mov    QWORD PTR [rsp+0x68],r15
  1e36d8:	mov    QWORD PTR [rsp+0x70],rbp
  1e36dd:	sub    rsp,0x8
  1e36e1:	movzx  eax,BYTE PTR [rsp+0x18]
  1e36e6:	movzx  esi,BYTE PTR [rsp+0x40]
  1e36eb:	movzx  ecx,BYTE PTR [rsp+0x28]
  1e36f0:	lea    rdi,[rsp+0x68]
  1e36f5:	lea    rdx,[rsp+0x98]
  1e36fd:	mov    r8,QWORD PTR [rsp+0x20]
  1e3702:	mov    r9,QWORD PTR [rsp+0x48]
  1e3707:	push   QWORD PTR [rsp+0x170]
  1e370e:	push   r10
  1e3710:	push   rax
  1e3711:	call   1c7580 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e3716:	add    rsp,0x20
  1e371a:	jmp    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e371f:	cmp    QWORD PTR [rsp+0x40],0x1
  1e3725:	jne    1e3838 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1e372b:	xor    edx,edx
  1e372d:	cmp    r14,0x1
  1e3731:	cmove  rdx,rbx
  1e3735:	cmp    rsi,0x1
  1e3739:	jne    1e37a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  1e373b:	test   rdx,rdx
  1e373e:	je     1e37a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  1e3740:	mov    QWORD PTR [rsp+0x90],rdx
  1e3748:	mov    QWORD PTR [rsp+0x98],r12
  1e3750:	mov    QWORD PTR [rsp+0xa0],r15
  1e3758:	mov    QWORD PTR [rsp+0xa8],rbp
  1e3760:	mov    QWORD PTR [rsp+0x60],rdi
  1e3765:	mov    QWORD PTR [rsp+0x68],r8
  1e376a:	mov    QWORD PTR [rsp+0x70],rcx
  1e376f:	sub    rsp,0x8
  1e3773:	movzx  eax,BYTE PTR [rsp+0x28]
  1e3778:	movzx  esi,BYTE PTR [rsp+0x40]
  1e377d:	movzx  r8d,BYTE PTR [rsp+0x18]
  1e3783:	lea    rdi,[rsp+0x98]
  1e378b:	lea    r9,[rsp+0x68]
  1e3790:	mov    rdx,QWORD PTR [rsp+0x20]
  1e3795:	mov    rcx,QWORD PTR [rsp+0x38]
  1e379a:	push   QWORD PTR [rsp+0x170]
  1e37a1:	push   r10
  1e37a3:	push   rax
  1e37a4:	jmp    1e382a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x56a>
  1e37a9:	xor    edx,edx
  1e37ab:	cmp    rbp,0x1
  1e37af:	cmove  rdx,rbx
  1e37b3:	cmp    rcx,0x1
  1e37b7:	jne    1e3838 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1e37b9:	test   rdx,rdx
  1e37bc:	je     1e3838 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1e37be:	mov    QWORD PTR [rsp+0x90],rdx
  1e37c6:	mov    QWORD PTR [rsp+0x98],r15
  1e37ce:	mov    QWORD PTR [rsp+0xa0],r12
  1e37d6:	mov    QWORD PTR [rsp+0xa8],r14
  1e37de:	mov    rax,QWORD PTR [rsp+0x18]
  1e37e3:	mov    QWORD PTR [rsp+0x60],rax
  1e37e8:	mov    rax,QWORD PTR [rsp+0x30]
  1e37ed:	mov    QWORD PTR [rsp+0x68],rax
  1e37f2:	mov    QWORD PTR [rsp+0x70],rsi
  1e37f7:	sub    rsp,0x8
  1e37fb:	movzx  r11d,BYTE PTR [rsp+0x18]
  1e3801:	movzx  esi,BYTE PTR [rsp+0x40]
  1e3806:	mov    rcx,r8
  1e3809:	movzx  r8d,BYTE PTR [rsp+0x28]
  1e380f:	mov    rdx,rdi
  1e3812:	lea    rdi,[rsp+0x98]
  1e381a:	lea    r9,[rsp+0x68]
  1e381f:	push   QWORD PTR [rsp+0x170]
  1e3826:	push   r10
  1e3828:	push   r11
  1e382a:	call   14de80 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e382f:	add    rsp,0x20
  1e3833:	jmp    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3838:	mov    QWORD PTR [rsp+0x28],r11
  1e383d:	mov    QWORD PTR [rsp+0x50],rcx
  1e3842:	mov    QWORD PTR [rsp+0x30],rdi
  1e3847:	mov    QWORD PTR [rsp+0x58],rax
  1e384c:	movups xmm2,XMMWORD PTR [r10]
  1e3850:	mov    rax,r12
  1e3853:	mul    r15
  1e3856:	mov    r13,rax
  1e3859:	movaps XMMWORD PTR [rsp+0x60],xmm2
  1e385e:	seto   r10b
  1e3862:	jo     1e3ded <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb2d>
  1e3868:	mul    QWORD PTR [rsp+0x40]
  1e386d:	seto   cl
  1e3870:	not    cl
  1e3872:	cmp    rax,0x1001
  1e3878:	setb   al
  1e387b:	test   cl,al
  1e387d:	mov    rdi,QWORD PTR [rsp+0x18]
  1e3882:	mov    r8d,DWORD PTR [rsp+0x10]
  1e3887:	mov    r9d,DWORD PTR [rsp+0x38]
  1e388c:	jne    1e38e7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x627>
  1e388e:	mov    rdx,QWORD PTR [rip+0x367703]        # 54af98 <_DYNAMIC+0x598>
  1e3895:	mov    rax,QWORD PTR [rdx]
  1e3898:	test   rax,rax
  1e389b:	je     1e3df9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb39>
  1e38a1:	mov    cl,0x1
  1e38a3:	test   eax,0x80000
  1e38a8:	jne    1e3ee2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  1e38ae:	mov    rax,QWORD PTR [rdx]
  1e38b1:	test   rax,rax
  1e38b4:	je     1e3e4c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8c>
  1e38ba:	test   ax,ax
  1e38bd:	jns    1e38d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1e38bf:	mov    rax,QWORD PTR [rdx]
  1e38c2:	test   rax,rax
  1e38c5:	je     1e3e9b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbdb>
  1e38cb:	bt     rax,0x37
  1e38d0:	jb     1e3ee0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc20>
  1e38d6:	test   r9b,r9b
  1e38d9:	jne    1e3b66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a6>
  1e38df:	xorps  xmm0,xmm0
  1e38e2:	jmp    1e3b6e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  1e38e7:	test   r9b,r9b
  1e38ea:	jne    1e3903 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x643>
  1e38ec:	xorps  xmm0,xmm0
  1e38ef:	jmp    1e390b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x64b>
  1e38f1:	cmp    r14,0x1
  1e38f5:	jne    1e3ab8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f8>
  1e38fb:	mov    rax,r12
  1e38fe:	jmp    1e3ce2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  1e3903:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5c19d]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1e390b:	movsd  QWORD PTR [rsp+0x38],xmm0
  1e3911:	mov    r13d,DWORD PTR [rsp+0x20]
  1e3916:	mov    rax,QWORD PTR [rsp+0x58]
  1e391b:	mov    rcx,QWORD PTR [rsp+0x50]
  1e3920:	mov    rdx,QWORD PTR [rsp+0x28]
  1e3925:	cmp    rbp,r14
  1e3928:	jae    1e3948 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x688>
  1e392a:	mov    BYTE PTR [rsp+0x20],r8b
  1e392f:	mov    QWORD PTR [rsp+0x10],rsi
  1e3934:	mov    QWORD PTR [rsp+0x58],rax
  1e3939:	mov    QWORD PTR [rsp+0x48],rdi
  1e393e:	mov    QWORD PTR [rsp+0x18],r14
  1e3943:	mov    r14,r12
  1e3946:	jmp    1e397d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6bd>
  1e3948:	mov    BYTE PTR [rsp+0x20],r13b
  1e394d:	mov    r13d,r8d
  1e3950:	mov    QWORD PTR [rsp+0x10],rcx
  1e3955:	mov    QWORD PTR [rsp+0x58],rdx
  1e395a:	mov    rcx,QWORD PTR [rsp+0x30]
  1e395f:	mov    QWORD PTR [rsp+0x48],rcx
  1e3964:	mov    rdx,rax
  1e3967:	mov    rcx,rsi
  1e396a:	mov    QWORD PTR [rsp+0x30],rdi
  1e396f:	mov    QWORD PTR [rsp+0x18],rbp
  1e3974:	mov    rbp,r14
  1e3977:	mov    r14,r15
  1e397a:	mov    r15,r12
  1e397d:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3985:	mov    QWORD PTR [rsp+0x28],rdx
  1e398a:	mov    QWORD PTR [rsp+0x50],rcx
  1e398f:	cmp    rcx,0x1
  1e3993:	jne    1e39c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  1e3995:	cmp    rbp,0x1
  1e3999:	jne    1e39c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  1e399b:	lea    r8,[rip+0x35c1ae]        # 53fb50 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x3e0>
  1e39a2:	lea    rdi,[rsp+0x90]
  1e39aa:	mov    rsi,r15
  1e39ad:	mov    rdx,r14
  1e39b0:	mov    r12,QWORD PTR [rsp+0x40]
  1e39b5:	mov    rcx,r12
  1e39b8:	call   QWORD PTR [rip+0x367712]        # 54b0d0 <_DYNAMIC+0x6d0>
  1e39be:	jmp    1e39e3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x723>
  1e39c0:	lea    r8,[rip+0x35c1a1]        # 53fb68 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x3f8>
  1e39c7:	lea    rdi,[rsp+0x90]
  1e39cf:	mov    rsi,r15
  1e39d2:	mov    rdx,r14
  1e39d5:	mov    r12,QWORD PTR [rsp+0x40]
  1e39da:	mov    rcx,r12
  1e39dd:	call   QWORD PTR [rip+0x3676f5]        # 54b0d8 <_DYNAMIC+0x6d8>
  1e39e3:	lea    rdi,[rsp+0x98]
  1e39eb:	mov    rsi,QWORD PTR [rsp+0xb8]
  1e39f3:	mov    rdx,QWORD PTR [rsp+0xc0]
  1e39fb:	movups xmm0,XMMWORD PTR [rsp+0xc8]
  1e3a03:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3a0b:	movaps xmm3,xmm2
  1e3a0e:	unpckhpd xmm3,xmm2
  1e3a12:	sub    rsp,0x70
  1e3a16:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e3a1b:	movzx  eax,BYTE PTR [rsp+0x90]
  1e3a23:	mov    DWORD PTR [rsp+0x50],eax
  1e3a27:	movzx  eax,r13b
  1e3a2b:	mov    DWORD PTR [rsp+0x48],eax
  1e3a2f:	mov    rax,QWORD PTR [rsp+0x80]
  1e3a37:	mov    QWORD PTR [rsp+0x40],rax
  1e3a3c:	mov    rax,QWORD PTR [rsp+0xc8]
  1e3a44:	mov    QWORD PTR [rsp+0x38],rax
  1e3a49:	mov    rax,QWORD PTR [rsp+0xb8]
  1e3a51:	mov    QWORD PTR [rsp+0x30],rax
  1e3a56:	mov    rax,QWORD PTR [rsp+0x98]
  1e3a5e:	mov    QWORD PTR [rsp+0x28],rax
  1e3a63:	mov    rax,QWORD PTR [rsp+0xc0]
  1e3a6b:	mov    QWORD PTR [rsp+0x20],rax
  1e3a70:	mov    rax,QWORD PTR [rsp+0xa0]
  1e3a78:	mov    QWORD PTR [rsp+0x18],rax
  1e3a7d:	mov    rax,QWORD PTR [rsp+0x88]
  1e3a85:	mov    QWORD PTR [rsp+0x10],rax
  1e3a8a:	mov    QWORD PTR [rsp+0x8],rbp
  1e3a8f:	mov    QWORD PTR [rsp],rbx
  1e3a93:	xorps  xmm1,xmm1
  1e3a96:	mov    r8,r14
  1e3a99:	mov    r9,r12
  1e3a9c:	mov    rcx,r15
  1e3a9f:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  1e3aa8:	call   QWORD PTR [rsp+0x100]
  1e3aaf:	add    rsp,0x70
  1e3ab3:	jmp    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3ab8:	lea    rax,[r12-0x1]
  1e3abd:	mov    ecx,r12d
  1e3ac0:	and    ecx,0x3
  1e3ac3:	and    r12,0xfffffffffffffffc
  1e3ac7:	mov    rdx,r14
  1e3aca:	shl    rdx,0x4
  1e3ace:	lea    rsi,[rdx+rdx*2]
  1e3ad2:	shl    rbp,0x4
  1e3ad6:	mov    rdi,r14
  1e3ad9:	shl    rdi,0x6
  1e3add:	shl    r14,0x5
  1e3ae1:	xor    r8d,r8d
  1e3ae4:	xorps  xmm0,xmm0
  1e3ae7:	jmp    1e3aff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83f>
  1e3ae9:	nop    DWORD PTR [rax+0x0]
  1e3af0:	inc    r8
  1e3af3:	add    rbx,rbp
  1e3af6:	cmp    r8,r15
  1e3af9:	je     1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3aff:	cmp    rax,0x3
  1e3b03:	jae    1e3b10 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x850>
  1e3b05:	xor    r9d,r9d
  1e3b08:	jmp    1e3b44 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x884>
  1e3b0a:	nop    WORD PTR [rax+rax*1+0x0]
  1e3b10:	mov    r10,rbx
  1e3b13:	xor    r9d,r9d
  1e3b16:	cs nop WORD PTR [rax+rax*1+0x0]
  1e3b20:	movups XMMWORD PTR [r10],xmm0
  1e3b24:	movups XMMWORD PTR [r10+rdx*1],xmm0
  1e3b29:	movups XMMWORD PTR [r10+r14*1],xmm0
  1e3b2e:	add    r9,0x4
  1e3b32:	movups XMMWORD PTR [r10+rsi*1],xmm0
  1e3b37:	add    r10,rdi
  1e3b3a:	cmp    r12,r9
  1e3b3d:	jne    1e3b20 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  1e3b3f:	test   rcx,rcx
  1e3b42:	je     1e3af0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1e3b44:	imul   r9,rdx
  1e3b48:	add    r9,rbx
  1e3b4b:	mov    r10,rcx
  1e3b4e:	xchg   ax,ax
  1e3b50:	movups XMMWORD PTR [r9],xmm0
  1e3b54:	add    r9,rdx
  1e3b57:	dec    r10
  1e3b5a:	jne    1e3b50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x890>
  1e3b5c:	jmp    1e3af0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1e3b5e:	mov    rax,r12
  1e3b61:	jmp    1e3cd3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa13>
  1e3b66:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5bf3a]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1e3b6e:	xor    r13d,r13d
  1e3b71:	cmp    QWORD PTR [rsp+0x168],0x0
  1e3b7a:	setne  al
  1e3b7d:	cmp    rbp,r14
  1e3b80:	jge    1e3ba5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8e5>
  1e3b82:	mov    ecx,DWORD PTR [rsp+0x20]
  1e3b86:	mov    BYTE PTR [rsp+0xf],cl
  1e3b8a:	mov    r11,QWORD PTR [rsp+0x50]
  1e3b8f:	mov    rdx,QWORD PTR [rsp+0x28]
  1e3b94:	mov    r10,QWORD PTR [rsp+0x30]
  1e3b99:	mov    QWORD PTR [rsp+0x10],r14
  1e3b9e:	mov    QWORD PTR [rsp+0x48],r15
  1e3ba3:	jmp    1e3bde <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x91e>
  1e3ba5:	mov    BYTE PTR [rsp+0xf],r8b
  1e3baa:	mov    r11,rsi
  1e3bad:	mov    rdx,QWORD PTR [rsp+0x58]
  1e3bb2:	mov    r10,rdi
  1e3bb5:	mov    QWORD PTR [rsp+0x10],rbp
  1e3bba:	mov    QWORD PTR [rsp+0x48],r12
  1e3bbf:	mov    r8d,DWORD PTR [rsp+0x20]
  1e3bc4:	mov    rsi,QWORD PTR [rsp+0x50]
  1e3bc9:	mov    rcx,QWORD PTR [rsp+0x28]
  1e3bce:	mov    QWORD PTR [rsp+0x58],rcx
  1e3bd3:	mov    rdi,QWORD PTR [rsp+0x30]
  1e3bd8:	mov    rbp,r14
  1e3bdb:	mov    r12,r15
  1e3bde:	test   rbp,rbp
  1e3be1:	js     1e3d71 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab1>
  1e3be7:	cmp    QWORD PTR [rsp+0x10],0x0
  1e3bed:	js     1e3d93 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad3>
  1e3bf3:	mov    r13b,al
  1e3bf6:	test   rdx,rdx
  1e3bf9:	mov    QWORD PTR [rsp+0x30],r13
  1e3bfe:	js     1e3db7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaf7>
  1e3c04:	mov    QWORD PTR [rsp+0x28],r11
  1e3c09:	mov    QWORD PTR [rsp+0x20],r10
  1e3c0e:	mov    QWORD PTR [rsp+0x50],rdx
  1e3c13:	mov    QWORD PTR [rsp+0x18],rdi
  1e3c18:	mov    r13,rsi
  1e3c1b:	mov    r15,QWORD PTR [rsp+0x40]
  1e3c20:	mov    rax,QWORD PTR [rip+0x3673f1]        # 54b018 <_DYNAMIC+0x618>
  1e3c27:	mov    rax,QWORD PTR [rax]
  1e3c2a:	test   rax,rax
  1e3c2d:	jne    1e3c62 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a2>
  1e3c2f:	mov    r14d,r8d
  1e3c32:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3c3a:	movsd  QWORD PTR [rsp+0x120],xmm0
  1e3c43:	call   QWORD PTR [rip+0x3673d7]        # 54b020 <_DYNAMIC+0x620>
  1e3c49:	movsd  xmm0,QWORD PTR [rsp+0x120]
  1e3c52:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3c5a:	mov    r9d,DWORD PTR [rsp+0x38]
  1e3c5f:	mov    r8d,r14d
  1e3c62:	movaps xmm3,xmm2
  1e3c65:	unpckhpd xmm3,xmm2
  1e3c69:	movzx  r11d,r8b
  1e3c6d:	movzx  r14d,BYTE PTR [rsp+0xf]
  1e3c73:	movzx  r10d,r9b
  1e3c77:	xorps  xmm1,xmm1
  1e3c7a:	mov    rdi,QWORD PTR [rsp+0x48]
  1e3c7f:	mov    rsi,r12
  1e3c82:	mov    rdx,r15
  1e3c85:	mov    rcx,rbx
  1e3c88:	mov    r8,QWORD PTR [rsp+0x10]
  1e3c8d:	mov    r9,rbp
  1e3c90:	push   QWORD PTR [rsp+0x168]
  1e3c97:	push   QWORD PTR [rsp+0x38]
  1e3c9b:	push   r11
  1e3c9d:	push   r14
  1e3c9f:	push   0x0
  1e3ca1:	push   QWORD PTR [rsp+0x80]
  1e3ca8:	push   r13
  1e3caa:	push   QWORD PTR [rsp+0x50]
  1e3cae:	push   QWORD PTR [rsp+0x68]
  1e3cb2:	push   QWORD PTR [rsp+0x98]
  1e3cb9:	push   QWORD PTR [rsp+0x70]
  1e3cbd:	push   r10
  1e3cbf:	call   rax
  1e3cc1:	add    rsp,0x60
  1e3cc5:	jmp    1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3cca:	mov    rax,r15
  1e3ccd:	mov    r15,r12
  1e3cd0:	mov    rbp,r14
  1e3cd3:	mov    ecx,0x1
  1e3cd8:	sub    rcx,rax
  1e3cdb:	shl    rcx,0x4
  1e3cdf:	add    rbx,rcx
  1e3ce2:	lea    rcx,[rax-0x1]
  1e3ce6:	mov    edx,eax
  1e3ce8:	and    edx,0x3
  1e3ceb:	and    rax,0xfffffffffffffffc
  1e3cef:	xor    esi,esi
  1e3cf1:	xorps  xmm0,xmm0
  1e3cf4:	jmp    1e3d0c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4c>
  1e3cf6:	cs nop WORD PTR [rax+rax*1+0x0]
  1e3d00:	inc    rsi
  1e3d03:	cmp    rsi,r15
  1e3d06:	je     1e3ffb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1e3d0c:	mov    rdi,rsi
  1e3d0f:	imul   rdi,rbp
  1e3d13:	shl    rdi,0x4
  1e3d17:	add    rdi,rbx
  1e3d1a:	cmp    rcx,0x3
  1e3d1e:	jb     1e3d51 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  1e3d20:	xor    r8d,r8d
  1e3d23:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e3d30:	movups XMMWORD PTR [rdi],xmm0
  1e3d33:	movups XMMWORD PTR [rdi+0x10],xmm0
  1e3d37:	movups XMMWORD PTR [rdi+0x20],xmm0
  1e3d3b:	movups XMMWORD PTR [rdi+0x30],xmm0
  1e3d3f:	add    rdi,0x40
  1e3d43:	add    r8,0x4
  1e3d47:	cmp    rax,r8
  1e3d4a:	jne    1e3d30 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa70>
  1e3d4c:	test   rdx,rdx
  1e3d4f:	je     1e3d00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  1e3d51:	xor    r8d,r8d
  1e3d54:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e3d60:	movups XMMWORD PTR [rdi],xmm0
  1e3d63:	add    rdi,0x10
  1e3d67:	inc    r8
  1e3d6a:	cmp    rdx,r8
  1e3d6d:	jne    1e3d60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa0>
  1e3d6f:	jmp    1e3d00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  1e3d71:	mov    rcx,QWORD PTR [rsp+0x48]
  1e3d76:	dec    rcx
  1e3d79:	imul   rcx,r11
  1e3d7d:	shl    rcx,0x4
  1e3d81:	add    r10,rcx
  1e3d84:	neg    r11
  1e3d87:	cmp    QWORD PTR [rsp+0x10],0x0
  1e3d8d:	jns    1e3bf3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x933>
  1e3d93:	lea    rcx,[r12-0x1]
  1e3d98:	imul   rcx,rsi
  1e3d9c:	shl    rcx,0x4
  1e3da0:	add    rdi,rcx
  1e3da3:	neg    rsi
  1e3da6:	mov    r13b,al
  1e3da9:	test   rdx,rdx
  1e3dac:	mov    QWORD PTR [rsp+0x30],r13
  1e3db1:	jns    1e3c04 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  1e3db7:	mov    rax,QWORD PTR [rsp+0x40]
  1e3dbc:	dec    rax
  1e3dbf:	mov    rcx,rdx
  1e3dc2:	imul   rcx,rax
  1e3dc6:	shl    rcx,0x4
  1e3dca:	add    r10,rcx
  1e3dcd:	neg    rdx
  1e3dd0:	mov    rcx,QWORD PTR [rsp+0x58]
  1e3dd5:	imul   rax,rcx
  1e3dd9:	shl    rax,0x4
  1e3ddd:	add    rdi,rax
  1e3de0:	neg    rcx
  1e3de3:	mov    QWORD PTR [rsp+0x58],rcx
  1e3de8:	jmp    1e3c04 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  1e3ded:	mov    rax,0xffffffffffffffff
  1e3df4:	jmp    1e3868 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a8>
  1e3df9:	mov    QWORD PTR [rsp+0x48],rsi
  1e3dfe:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3e06:	mov    BYTE PTR [rsp+0xf],r10b
  1e3e0b:	call   QWORD PTR [rip+0x367197]        # 54afa8 <_DYNAMIC+0x5a8>
  1e3e11:	mov    rdx,QWORD PTR [rip+0x367180]        # 54af98 <_DYNAMIC+0x598>
  1e3e18:	movzx  r10d,BYTE PTR [rsp+0xf]
  1e3e1e:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3e26:	mov    rsi,QWORD PTR [rsp+0x48]
  1e3e2b:	mov    r9d,DWORD PTR [rsp+0x38]
  1e3e30:	mov    r8d,DWORD PTR [rsp+0x10]
  1e3e35:	mov    rdi,QWORD PTR [rsp+0x18]
  1e3e3a:	mov    cl,0x1
  1e3e3c:	test   eax,0x80000
  1e3e41:	je     1e38ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ee>
  1e3e47:	jmp    1e3ee2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  1e3e4c:	mov    QWORD PTR [rsp+0x48],rsi
  1e3e51:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3e59:	mov    BYTE PTR [rsp+0xf],r10b
  1e3e5e:	call   QWORD PTR [rip+0x367144]        # 54afa8 <_DYNAMIC+0x5a8>
  1e3e64:	mov    rdx,QWORD PTR [rip+0x36712d]        # 54af98 <_DYNAMIC+0x598>
  1e3e6b:	movzx  r10d,BYTE PTR [rsp+0xf]
  1e3e71:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3e79:	mov    rsi,QWORD PTR [rsp+0x48]
  1e3e7e:	mov    r9d,DWORD PTR [rsp+0x38]
  1e3e83:	mov    r8d,DWORD PTR [rsp+0x10]
  1e3e88:	mov    rdi,QWORD PTR [rsp+0x18]
  1e3e8d:	test   ax,ax
  1e3e90:	js     1e38bf <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ff>
  1e3e96:	jmp    1e38d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1e3e9b:	mov    QWORD PTR [rsp+0x48],rsi
  1e3ea0:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3ea8:	mov    BYTE PTR [rsp+0xf],r10b
  1e3ead:	call   QWORD PTR [rip+0x3670f5]        # 54afa8 <_DYNAMIC+0x5a8>
  1e3eb3:	movzx  r10d,BYTE PTR [rsp+0xf]
  1e3eb9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3ec1:	mov    rsi,QWORD PTR [rsp+0x48]
  1e3ec6:	mov    r9d,DWORD PTR [rsp+0x38]
  1e3ecb:	mov    r8d,DWORD PTR [rsp+0x10]
  1e3ed0:	mov    rdi,QWORD PTR [rsp+0x18]
  1e3ed5:	bt     rax,0x37
  1e3eda:	jae    1e38d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1e3ee0:	xor    ecx,ecx
  1e3ee2:	test   r10b,r10b
  1e3ee5:	jne    1e400d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd4d>
  1e3eeb:	mov    r10,rsi
  1e3eee:	mov    rax,r13
  1e3ef1:	mul    QWORD PTR [rsp+0x40]
  1e3ef6:	jo     1e4025 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  1e3efc:	mov    rdx,rax
  1e3eff:	shr    rdx,0x3d
  1e3f03:	jne    1e4025 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  1e3f09:	shl    rax,0x3
  1e3f0d:	mov    rdx,QWORD PTR [rip+0x3670ac]        # 54afc0 <_DYNAMIC+0x5c0>
  1e3f14:	mov    rsi,QWORD PTR [rdx]
  1e3f17:	add    rsi,rsi
  1e3f1a:	mov    edx,0x1
  1e3f1f:	cmp    rax,rsi
  1e3f22:	jb     1e3f34 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc74>
  1e3f24:	mov    rdx,QWORD PTR [rsp+0x168]
  1e3f2c:	cmp    rdx,0x1
  1e3f30:	adc    rdx,0x0
  1e3f34:	sub    rsp,0xa0
  1e3f3b:	mov    QWORD PTR [rsp+0x90],rdx
  1e3f43:	lea    rax,[rsp+0x100]
  1e3f4b:	mov    QWORD PTR [rsp+0x88],rax
  1e3f53:	movzx  eax,BYTE PTR [rsp+0xc0]
  1e3f5b:	mov    DWORD PTR [rsp+0x80],eax
  1e3f62:	mov    rax,QWORD PTR [rsp+0xf0]
  1e3f6a:	mov    QWORD PTR [rsp+0x78],rax
  1e3f6f:	mov    rax,QWORD PTR [rsp+0xc8]
  1e3f77:	mov    QWORD PTR [rsp+0x70],rax
  1e3f7c:	mov    rax,QWORD PTR [rsp+0xd0]
  1e3f84:	mov    QWORD PTR [rsp+0x68],rax
  1e3f89:	xorps  xmm0,xmm0
  1e3f8c:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e3f91:	movzx  eax,r8b
  1e3f95:	mov    DWORD PTR [rsp+0x50],eax
  1e3f99:	mov    rax,QWORD PTR [rsp+0xf8]
  1e3fa1:	mov    QWORD PTR [rsp+0x48],rax
  1e3fa6:	mov    QWORD PTR [rsp+0x40],r10
  1e3fab:	mov    QWORD PTR [rsp+0x38],rdi
  1e3fb0:	movzx  eax,r9b
  1e3fb4:	mov    DWORD PTR [rsp+0x30],eax
  1e3fb8:	movups XMMWORD PTR [rsp+0x18],xmm0
  1e3fbd:	mov    QWORD PTR [rsp+0x10],rbp
  1e3fc2:	mov    QWORD PTR [rsp+0x8],r14
  1e3fc7:	mov    QWORD PTR [rsp],rbx
  1e3fcb:	mov    DWORD PTR [rsp+0x28],0x2
  1e3fd3:	movzx  edx,cl
  1e3fd6:	mov    r8,r15
  1e3fd9:	mov    edi,0x3
  1e3fde:	mov    r9,QWORD PTR [rsp+0xe0]
  1e3fe6:	mov    esi,0x1
  1e3feb:	mov    rcx,r12
  1e3fee:	call   QWORD PTR [rip+0x366fac]        # 54afa0 <_DYNAMIC+0x5a0>
  1e3ff4:	add    rsp,0xa0
  1e3ffb:	add    rsp,0x128
  1e4002:	pop    rbx
  1e4003:	pop    r12
  1e4005:	pop    r13
  1e4007:	pop    r14
  1e4009:	pop    r15
  1e400b:	pop    rbp
  1e400c:	ret
  1e400d:	mov    r13,0xffffffffffffffff
  1e4014:	mov    r10,rsi
  1e4017:	mov    rax,r13
  1e401a:	mul    QWORD PTR [rsp+0x40]
  1e401f:	jno    1e3efc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc3c>
  1e4025:	mov    rax,QWORD PTR [rip+0x366f94]        # 54afc0 <_DYNAMIC+0x5c0>
  1e402c:	mov    rax,QWORD PTR [rax]
  1e402f:	jmp    1e3f24 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc64>
