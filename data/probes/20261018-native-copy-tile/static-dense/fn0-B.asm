
target/faer-rev/60de2ee06467-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001d8330 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  1d8330:	push   rbp
  1d8331:	push   r15
  1d8333:	push   r14
  1d8335:	push   r13
  1d8337:	push   r12
  1d8339:	push   rbx
  1d833a:	sub    rsp,0x128
  1d8341:	mov    r12,QWORD PTR [rdi+0x8]
  1d8345:	test   r12,r12
  1d8348:	je     1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d834e:	mov    r15,QWORD PTR [rdi+0x10]
  1d8352:	test   r15,r15
  1d8355:	je     1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d835b:	mov    rbx,QWORD PTR [rdi]
  1d835e:	mov    r14,QWORD PTR [rdi+0x18]
  1d8362:	mov    rbp,QWORD PTR [rdi+0x20]
  1d8366:	mov    rax,QWORD PTR [rdx+0x10]
  1d836a:	mov    QWORD PTR [rsp+0x38],rax
  1d836f:	test   rax,rax
  1d8372:	je     1d8424 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
  1d8378:	mov    DWORD PTR [rsp+0x28],r9d
  1d837d:	mov    DWORD PTR [rsp+0x20],esi
  1d8381:	mov    DWORD PTR [rsp+0x10],ecx
  1d8385:	mov    r10,QWORD PTR [rdx]
  1d8388:	mov    rcx,QWORD PTR [rdx+0x8]
  1d838c:	mov    r9,QWORD PTR [rdx+0x18]
  1d8390:	test   r14,r14
  1d8393:	jns    1d83cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d>
  1d8395:	lea    rax,[r12-0x1]
  1d839a:	imul   rax,r14
  1d839e:	shl    rax,0x4
  1d83a2:	add    rbx,rax
  1d83a5:	neg    r14
  1d83a8:	xor    eax,eax
  1d83aa:	mov    rsi,rcx
  1d83ad:	sub    rsi,0x1
  1d83b1:	cmovb  rsi,rax
  1d83b5:	mov    rdi,r9
  1d83b8:	imul   rdi,rsi
  1d83bc:	cmp    rsi,rcx
  1d83bf:	cmove  rdi,rax
  1d83c3:	shl    rdi,0x4
  1d83c7:	add    r10,rdi
  1d83ca:	neg    r9
  1d83cd:	mov    QWORD PTR [rsp+0x30],r9
  1d83d2:	mov    rsi,QWORD PTR [rdx+0x20]
  1d83d6:	mov    rdi,QWORD PTR [r8]
  1d83d9:	mov    r9,QWORD PTR [r8+0x8]
  1d83dd:	mov    rax,QWORD PTR [r8+0x10]
  1d83e1:	mov    QWORD PTR [rsp+0x18],rax
  1d83e6:	mov    rax,QWORD PTR [r8+0x20]
  1d83ea:	test   rbp,rbp
  1d83ed:	js     1d8473 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x143>
  1d83f3:	mov    r8,QWORD PTR [r8+0x18]
  1d83f7:	test   rsi,rsi
  1d83fa:	js     1d84e1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b1>
  1d8400:	mov    QWORD PTR [rsp+0x8],r10
  1d8405:	mov    r10,QWORD PTR [rsp+0x168]
  1d840d:	mov    r11,QWORD PTR [rsp+0x160]
  1d8415:	cmp    r15,0x1
  1d8419:	je     1d856c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x23c>
  1d841f:	jmp    1d865b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1d8424:	test   sil,sil
  1d8427:	jne    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d842d:	cmp    r12,0x1
  1d8431:	je     1d8447 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
  1d8433:	cmp    r14,0xffffffffffffffff
  1d8437:	je     1d8bae <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x87e>
  1d843d:	cmp    r14,0x1
  1d8441:	je     1d8942 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x612>
  1d8447:	cmp    r15,0x1
  1d844b:	je     1d8938 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  1d8451:	cmp    rbp,0xffffffffffffffff
  1d8455:	je     1d8d17 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9e7>
  1d845b:	cmp    rbp,0x1
  1d845f:	jne    1d8938 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  1d8465:	mov    rax,r15
  1d8468:	mov    r15,r12
  1d846b:	mov    rbp,r14
  1d846e:	jmp    1d8d2f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  1d8473:	lea    rdx,[r15-0x1]
  1d8477:	imul   rdx,rbp
  1d847b:	shl    rdx,0x4
  1d847f:	add    rbx,rdx
  1d8482:	neg    rbp
  1d8485:	xor    r13d,r13d
  1d8488:	mov    r11,rsi
  1d848b:	mov    rsi,QWORD PTR [rsp+0x18]
  1d8490:	sub    rsi,0x1
  1d8494:	cmovb  rsi,r13
  1d8498:	mov    rdx,rcx
  1d849b:	mov    rcx,r10
  1d849e:	mov    r10,rax
  1d84a1:	mov    rax,rdi
  1d84a4:	mov    rdi,r10
  1d84a7:	imul   rdi,rsi
  1d84ab:	cmp    rsi,QWORD PTR [rsp+0x18]
  1d84b0:	mov    rsi,r11
  1d84b3:	cmove  rdi,r13
  1d84b7:	test   r9,r9
  1d84ba:	cmove  rdi,r9
  1d84be:	shl    rdi,0x4
  1d84c2:	add    rax,rdi
  1d84c5:	mov    rdi,rax
  1d84c8:	mov    rax,r10
  1d84cb:	mov    r10,rcx
  1d84ce:	mov    rcx,rdx
  1d84d1:	neg    rax
  1d84d4:	mov    r8,QWORD PTR [r8+0x18]
  1d84d8:	test   rsi,rsi
  1d84db:	jns    1d8400 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd0>
  1d84e1:	mov    rdx,QWORD PTR [rsp+0x38]
  1d84e6:	dec    rdx
  1d84e9:	imul   rdx,rsi
  1d84ed:	test   rcx,rcx
  1d84f0:	cmove  rdx,rcx
  1d84f4:	shl    rdx,0x4
  1d84f8:	add    r10,rdx
  1d84fb:	mov    QWORD PTR [rsp+0x8],r10
  1d8500:	neg    rsi
  1d8503:	xor    edx,edx
  1d8505:	mov    r10,r8
  1d8508:	mov    r8,rsi
  1d850b:	mov    rsi,r9
  1d850e:	sub    rsi,0x1
  1d8512:	cmovb  rsi,rdx
  1d8516:	mov    r11,rcx
  1d8519:	mov    rcx,rax
  1d851c:	mov    rax,rdi
  1d851f:	mov    rdi,r10
  1d8522:	imul   rdi,rsi
  1d8526:	mov    r13,QWORD PTR [rsp+0x18]
  1d852b:	test   r13,r13
  1d852e:	cmove  rdi,r13
  1d8532:	cmp    rsi,r9
  1d8535:	mov    rsi,r8
  1d8538:	mov    r8,r10
  1d853b:	cmove  rdi,rdx
  1d853f:	shl    rdi,0x4
  1d8543:	add    rax,rdi
  1d8546:	mov    rdi,rax
  1d8549:	mov    rax,rcx
  1d854c:	mov    rcx,r11
  1d854f:	neg    r8
  1d8552:	mov    r10,QWORD PTR [rsp+0x168]
  1d855a:	mov    r11,QWORD PTR [rsp+0x160]
  1d8562:	cmp    r15,0x1
  1d8566:	jne    1d865b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1d856c:	cmp    QWORD PTR [rsp+0x30],0x1
  1d8572:	jne    1d85e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1d8574:	cmp    r14,0x1
  1d8578:	jne    1d85e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1d857a:	test   rbx,rbx
  1d857d:	je     1d85e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1d857f:	mov    rax,QWORD PTR [rsp+0x8]
  1d8584:	mov    QWORD PTR [rsp+0x98],rax
  1d858c:	mov    QWORD PTR [rsp+0xa0],rcx
  1d8594:	mov    rax,QWORD PTR [rsp+0x38]
  1d8599:	mov    QWORD PTR [rsp+0xa8],rax
  1d85a1:	mov    QWORD PTR [rsp+0xb0],rsi
  1d85a9:	mov    QWORD PTR [rsp+0x50],rdi
  1d85ae:	mov    QWORD PTR [rsp+0x58],r9
  1d85b3:	mov    QWORD PTR [rsp+0x60],r8
  1d85b8:	sub    rsp,0x8
  1d85bc:	movzx  eax,BYTE PTR [rsp+0x30]
  1d85c1:	movzx  edx,BYTE PTR [rsp+0x28]
  1d85c6:	movzx  r8d,BYTE PTR [rsp+0x18]
  1d85cc:	lea    rcx,[rsp+0xa0]
  1d85d4:	lea    r9,[rsp+0x58]
  1d85d9:	mov    rdi,rbx
  1d85dc:	mov    rsi,r12
  1d85df:	jmp    1d86df <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3af>
  1d85e4:	cmp    rsi,0x1
  1d85e8:	jne    1d865b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1d85ea:	cmp    r8,0x1
  1d85ee:	jne    1d865b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1d85f0:	test   rdi,rdi
  1d85f3:	je     1d865b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1d85f5:	mov    rax,QWORD PTR [rsp+0x8]
  1d85fa:	mov    QWORD PTR [rsp+0x98],rax
  1d8602:	mov    QWORD PTR [rsp+0xa0],rcx
  1d860a:	mov    rax,QWORD PTR [rsp+0x38]
  1d860f:	mov    QWORD PTR [rsp+0xa8],rax
  1d8617:	mov    rax,QWORD PTR [rsp+0x30]
  1d861c:	mov    QWORD PTR [rsp+0xb0],rax
  1d8624:	mov    QWORD PTR [rsp+0x50],rbx
  1d8629:	mov    QWORD PTR [rsp+0x58],r12
  1d862e:	mov    QWORD PTR [rsp+0x60],r14
  1d8633:	sub    rsp,0x8
  1d8637:	movzx  eax,BYTE PTR [rsp+0x30]
  1d863c:	movzx  esi,BYTE PTR [rsp+0x28]
  1d8641:	movzx  ecx,BYTE PTR [rsp+0x18]
  1d8646:	mov    r8,rdi
  1d8649:	lea    rdi,[rsp+0x58]
  1d864e:	lea    rdx,[rsp+0xa0]
  1d8656:	jmp    1d8767 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x437>
  1d865b:	cmp    r12,0x1
  1d865f:	jne    1d877a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1d8665:	xor    edx,edx
  1d8667:	cmp    rbp,0x1
  1d866b:	cmove  rdx,rbx
  1d866f:	cmp    rax,0x1
  1d8673:	jne    1d86f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  1d8675:	test   rdx,rdx
  1d8678:	je     1d86f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  1d867a:	mov    QWORD PTR [rsp+0x98],rdi
  1d8682:	mov    rax,QWORD PTR [rsp+0x18]
  1d8687:	mov    QWORD PTR [rsp+0xa0],rax
  1d868f:	mov    QWORD PTR [rsp+0xa8],r9
  1d8697:	mov    QWORD PTR [rsp+0xb0],r8
  1d869f:	mov    rax,QWORD PTR [rsp+0x8]
  1d86a4:	mov    QWORD PTR [rsp+0x50],rax
  1d86a9:	mov    rax,QWORD PTR [rsp+0x38]
  1d86ae:	mov    QWORD PTR [rsp+0x58],rax
  1d86b3:	mov    QWORD PTR [rsp+0x60],rsi
  1d86b8:	sub    rsp,0x8
  1d86bc:	movzx  eax,BYTE PTR [rsp+0x18]
  1d86c1:	movzx  edx,BYTE PTR [rsp+0x28]
  1d86c6:	movzx  r8d,BYTE PTR [rsp+0x30]
  1d86cc:	lea    rcx,[rsp+0xa0]
  1d86d4:	lea    r9,[rsp+0x58]
  1d86d9:	mov    rdi,rbx
  1d86dc:	mov    rsi,r15
  1d86df:	push   r10
  1d86e1:	push   r11
  1d86e3:	push   rax
  1d86e4:	call   14c410 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1d86e9:	add    rsp,0x20
  1d86ed:	jmp    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d86f2:	xor    edx,edx
  1d86f4:	cmp    rsi,0x1
  1d86f8:	cmove  rdx,QWORD PTR [rsp+0x8]
  1d86fe:	cmp    r8,0x1
  1d8702:	jne    1d877a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1d8704:	test   rdx,rdx
  1d8707:	je     1d877a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1d8709:	mov    QWORD PTR [rsp+0x98],rdi
  1d8711:	mov    rcx,QWORD PTR [rsp+0x18]
  1d8716:	mov    QWORD PTR [rsp+0xa0],rcx
  1d871e:	mov    QWORD PTR [rsp+0xa8],r9
  1d8726:	mov    QWORD PTR [rsp+0xb0],rax
  1d872e:	mov    QWORD PTR [rsp+0x50],rbx
  1d8733:	mov    QWORD PTR [rsp+0x58],r15
  1d8738:	mov    QWORD PTR [rsp+0x60],rbp
  1d873d:	sub    rsp,0x8
  1d8741:	movzx  eax,BYTE PTR [rsp+0x18]
  1d8746:	movzx  esi,BYTE PTR [rsp+0x28]
  1d874b:	movzx  ecx,BYTE PTR [rsp+0x30]
  1d8750:	lea    rdi,[rsp+0x58]
  1d8755:	lea    rdx,[rsp+0xa0]
  1d875d:	mov    r8,QWORD PTR [rsp+0x10]
  1d8762:	mov    r9,QWORD PTR [rsp+0x40]
  1d8767:	push   r10
  1d8769:	push   r11
  1d876b:	push   rax
  1d876c:	call   1c5710 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1d8771:	add    rsp,0x20
  1d8775:	jmp    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d877a:	mov    QWORD PTR [rsp+0x48],r8
  1d877f:	cmp    QWORD PTR [rsp+0x38],0x1
  1d8785:	mov    r8,QWORD PTR [rsp+0x30]
  1d878a:	jne    1d888f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1d8790:	xor    edx,edx
  1d8792:	cmp    r14,0x1
  1d8796:	cmove  rdx,rbx
  1d879a:	cmp    r8,0x1
  1d879e:	jne    1d8806 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  1d87a0:	test   rdx,rdx
  1d87a3:	je     1d8806 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  1d87a5:	mov    QWORD PTR [rsp+0x98],rdx
  1d87ad:	mov    QWORD PTR [rsp+0xa0],r12
  1d87b5:	mov    QWORD PTR [rsp+0xa8],r15
  1d87bd:	mov    QWORD PTR [rsp+0xb0],rbp
  1d87c5:	mov    QWORD PTR [rsp+0x50],rdi
  1d87ca:	mov    rdx,QWORD PTR [rsp+0x18]
  1d87cf:	mov    QWORD PTR [rsp+0x58],rdx
  1d87d4:	mov    QWORD PTR [rsp+0x60],rax
  1d87d9:	sub    rsp,0x8
  1d87dd:	movzx  eax,BYTE PTR [rsp+0x30]
  1d87e2:	movzx  esi,BYTE PTR [rsp+0x28]
  1d87e7:	movzx  r8d,BYTE PTR [rsp+0x18]
  1d87ed:	lea    rdi,[rsp+0xa0]
  1d87f5:	lea    r9,[rsp+0x58]
  1d87fa:	mov    rdx,QWORD PTR [rsp+0x10]
  1d87ff:	push   r10
  1d8801:	push   r11
  1d8803:	push   rax
  1d8804:	jmp    1d8881 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x551>
  1d8806:	xor    edx,edx
  1d8808:	cmp    rbp,0x1
  1d880c:	cmove  rdx,rbx
  1d8810:	cmp    rax,0x1
  1d8814:	jne    1d888f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1d8816:	test   rdx,rdx
  1d8819:	je     1d888f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1d881b:	mov    QWORD PTR [rsp+0x98],rdx
  1d8823:	mov    QWORD PTR [rsp+0xa0],r15
  1d882b:	mov    QWORD PTR [rsp+0xa8],r12
  1d8833:	mov    QWORD PTR [rsp+0xb0],r14
  1d883b:	mov    rax,QWORD PTR [rsp+0x8]
  1d8840:	mov    QWORD PTR [rsp+0x50],rax
  1d8845:	mov    QWORD PTR [rsp+0x58],rcx
  1d884a:	mov    QWORD PTR [rsp+0x60],r8
  1d884f:	sub    rsp,0x8
  1d8853:	mov    rax,r11
  1d8856:	movzx  r11d,BYTE PTR [rsp+0x18]
  1d885c:	movzx  esi,BYTE PTR [rsp+0x28]
  1d8861:	movzx  r8d,BYTE PTR [rsp+0x30]
  1d8867:	mov    rdx,rdi
  1d886a:	lea    rdi,[rsp+0xa0]
  1d8872:	lea    r9,[rsp+0x58]
  1d8877:	mov    rcx,QWORD PTR [rsp+0x20]
  1d887c:	push   r10
  1d887e:	push   rax
  1d887f:	push   r11
  1d8881:	call   14ae50 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1d8886:	add    rsp,0x20
  1d888a:	jmp    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d888f:	mov    QWORD PTR [rsp+0x70],rax
  1d8894:	mov    QWORD PTR [rsp+0x18],rdi
  1d8899:	mov    QWORD PTR [rsp+0x40],rsi
  1d889e:	movups xmm2,XMMWORD PTR [r11]
  1d88a2:	movaps XMMWORD PTR [rsp+0x50],xmm2
  1d88a7:	mov    rax,r12
  1d88aa:	mul    r15
  1d88ad:	mov    r13,rax
  1d88b0:	jo     1d8e3e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb0e>
  1d88b6:	mul    QWORD PTR [rsp+0x38]
  1d88bb:	seto   cl
  1d88be:	not    cl
  1d88c0:	cmp    rax,0x1001
  1d88c6:	setb   al
  1d88c9:	test   cl,al
  1d88cb:	mov    esi,DWORD PTR [rsp+0x10]
  1d88cf:	mov    edi,DWORD PTR [rsp+0x20]
  1d88d3:	jne    1d892e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5fe>
  1d88d5:	mov    rdx,QWORD PTR [rip+0x3726bc]        # 54af98 <_DYNAMIC+0x598>
  1d88dc:	mov    rax,QWORD PTR [rdx]
  1d88df:	test   rax,rax
  1d88e2:	je     1d8e4a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb1a>
  1d88e8:	mov    cl,0x1
  1d88ea:	test   eax,0x80000
  1d88ef:	jne    1d8eeb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  1d88f5:	mov    rax,QWORD PTR [rdx]
  1d88f8:	test   rax,rax
  1d88fb:	je     1d8e83 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb53>
  1d8901:	test   ax,ax
  1d8904:	jns    1d891d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1d8906:	mov    rax,QWORD PTR [rdx]
  1d8909:	test   rax,rax
  1d890c:	je     1d8ebb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8b>
  1d8912:	bt     rax,0x37
  1d8917:	jb     1d8ee9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbb9>
  1d891d:	test   dil,dil
  1d8920:	jne    1d8bb6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x886>
  1d8926:	xorps  xmm0,xmm0
  1d8929:	jmp    1d8bbe <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x88e>
  1d892e:	test   dil,dil
  1d8931:	jne    1d894a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  1d8933:	xorps  xmm0,xmm0
  1d8936:	jmp    1d8952 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x622>
  1d8938:	cmp    r14,0x1
  1d893c:	jne    1d8b07 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7d7>
  1d8942:	mov    rax,r12
  1d8945:	jmp    1d8d2f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  1d894a:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe67156]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1d8952:	movsd  QWORD PTR [rsp+0x20],xmm0
  1d8958:	mov    rax,QWORD PTR [rsp+0x8]
  1d895d:	mov    rdx,QWORD PTR [rsp+0x18]
  1d8962:	cmp    rbp,r14
  1d8965:	jae    1d8992 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x662>
  1d8967:	mov    BYTE PTR [rsp+0x8],sil
  1d896c:	mov    QWORD PTR [rsp+0x10],r8
  1d8971:	mov    rcx,QWORD PTR [rsp+0x40]
  1d8976:	mov    QWORD PTR [rsp+0x78],rcx
  1d897b:	mov    QWORD PTR [rsp+0x90],rax
  1d8983:	mov    QWORD PTR [rsp+0x30],r14
  1d8988:	mov    r13,r12
  1d898b:	mov    r8,QWORD PTR [rsp+0x70]
  1d8990:	jmp    1d89d5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a5>
  1d8992:	mov    ecx,DWORD PTR [rsp+0x28]
  1d8996:	mov    BYTE PTR [rsp+0x8],cl
  1d899a:	mov    DWORD PTR [rsp+0x28],esi
  1d899e:	mov    rcx,QWORD PTR [rsp+0x70]
  1d89a3:	mov    QWORD PTR [rsp+0x10],rcx
  1d89a8:	mov    rcx,QWORD PTR [rsp+0x48]
  1d89ad:	mov    QWORD PTR [rsp+0x78],rcx
  1d89b2:	mov    QWORD PTR [rsp+0x90],rdx
  1d89ba:	mov    rcx,QWORD PTR [rsp+0x40]
  1d89bf:	mov    QWORD PTR [rsp+0x48],rcx
  1d89c4:	mov    rdx,rax
  1d89c7:	mov    QWORD PTR [rsp+0x30],rbp
  1d89cc:	mov    rbp,r14
  1d89cf:	mov    r13,r15
  1d89d2:	mov    r15,r12
  1d89d5:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1d89dd:	mov    QWORD PTR [rsp+0x18],rdx
  1d89e2:	mov    r12,r8
  1d89e5:	cmp    r8,0x1
  1d89e9:	jne    1d8a16 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  1d89eb:	cmp    rbp,0x1
  1d89ef:	jne    1d8a16 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  1d89f1:	lea    r8,[rip+0x367158]        # 53fb50 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x3e0>
  1d89f8:	lea    rdi,[rsp+0x98]
  1d8a00:	mov    rsi,r15
  1d8a03:	mov    rdx,r13
  1d8a06:	mov    r14,QWORD PTR [rsp+0x38]
  1d8a0b:	mov    rcx,r14
  1d8a0e:	call   QWORD PTR [rip+0x3726bc]        # 54b0d0 <_DYNAMIC+0x6d0>
  1d8a14:	jmp    1d8a39 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x709>
  1d8a16:	lea    r8,[rip+0x36714b]        # 53fb68 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x3f8>
  1d8a1d:	lea    rdi,[rsp+0x98]
  1d8a25:	mov    rsi,r15
  1d8a28:	mov    rdx,r13
  1d8a2b:	mov    r14,QWORD PTR [rsp+0x38]
  1d8a30:	mov    rcx,r14
  1d8a33:	call   QWORD PTR [rip+0x37269f]        # 54b0d8 <_DYNAMIC+0x6d8>
  1d8a39:	lea    rdi,[rsp+0xa0]
  1d8a41:	mov    rsi,QWORD PTR [rsp+0xc0]
  1d8a49:	mov    rdx,QWORD PTR [rsp+0xc8]
  1d8a51:	movups xmm0,XMMWORD PTR [rsp+0xd0]
  1d8a59:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1d8a61:	movaps xmm3,xmm2
  1d8a64:	unpckhpd xmm3,xmm2
  1d8a68:	sub    rsp,0x70
  1d8a6c:	movups XMMWORD PTR [rsp+0x58],xmm0
  1d8a71:	movzx  eax,BYTE PTR [rsp+0x78]
  1d8a76:	mov    DWORD PTR [rsp+0x50],eax
  1d8a7a:	movzx  eax,BYTE PTR [rsp+0x98]
  1d8a82:	mov    DWORD PTR [rsp+0x48],eax
  1d8a86:	mov    rax,QWORD PTR [rsp+0x80]
  1d8a8e:	mov    QWORD PTR [rsp+0x40],rax
  1d8a93:	mov    rax,QWORD PTR [rsp+0xe8]
  1d8a9b:	mov    QWORD PTR [rsp+0x38],rax
  1d8aa0:	mov    rax,QWORD PTR [rsp+0x100]
  1d8aa8:	mov    QWORD PTR [rsp+0x30],rax
  1d8aad:	mov    rax,QWORD PTR [rsp+0xb8]
  1d8ab5:	mov    QWORD PTR [rsp+0x28],rax
  1d8aba:	mov    QWORD PTR [rsp+0x20],r12
  1d8abf:	mov    rax,QWORD PTR [rsp+0x88]
  1d8ac7:	mov    QWORD PTR [rsp+0x18],rax
  1d8acc:	mov    rax,QWORD PTR [rsp+0xa0]
  1d8ad4:	mov    QWORD PTR [rsp+0x10],rax
  1d8ad9:	mov    QWORD PTR [rsp+0x8],rbp
  1d8ade:	mov    QWORD PTR [rsp],rbx
  1d8ae2:	xorps  xmm1,xmm1
  1d8ae5:	mov    r8,r13
  1d8ae8:	mov    r9,r14
  1d8aeb:	mov    rcx,r15
  1d8aee:	movsd  xmm0,QWORD PTR [rsp+0x90]
  1d8af7:	call   QWORD PTR [rsp+0x108]
  1d8afe:	add    rsp,0x70
  1d8b02:	jmp    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d8b07:	lea    rax,[r12-0x1]
  1d8b0c:	mov    ecx,r12d
  1d8b0f:	and    ecx,0x3
  1d8b12:	and    r12,0xfffffffffffffffc
  1d8b16:	mov    rdx,r14
  1d8b19:	shl    rdx,0x4
  1d8b1d:	lea    rsi,[rdx+rdx*2]
  1d8b21:	shl    rbp,0x4
  1d8b25:	mov    rdi,r14
  1d8b28:	shl    rdi,0x6
  1d8b2c:	shl    r14,0x5
  1d8b30:	xor    r8d,r8d
  1d8b33:	xorps  xmm0,xmm0
  1d8b36:	jmp    1d8b4f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x81f>
  1d8b38:	nop    DWORD PTR [rax+rax*1+0x0]
  1d8b40:	inc    r8
  1d8b43:	add    rbx,rbp
  1d8b46:	cmp    r8,r15
  1d8b49:	je     1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d8b4f:	cmp    rax,0x3
  1d8b53:	jae    1d8b60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1d8b55:	xor    r9d,r9d
  1d8b58:	jmp    1d8b94 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x864>
  1d8b5a:	nop    WORD PTR [rax+rax*1+0x0]
  1d8b60:	mov    r10,rbx
  1d8b63:	xor    r9d,r9d
  1d8b66:	cs nop WORD PTR [rax+rax*1+0x0]
  1d8b70:	movups XMMWORD PTR [r10],xmm0
  1d8b74:	movups XMMWORD PTR [r10+rdx*1],xmm0
  1d8b79:	movups XMMWORD PTR [r10+r14*1],xmm0
  1d8b7e:	add    r9,0x4
  1d8b82:	movups XMMWORD PTR [r10+rsi*1],xmm0
  1d8b87:	add    r10,rdi
  1d8b8a:	cmp    r12,r9
  1d8b8d:	jne    1d8b70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  1d8b8f:	test   rcx,rcx
  1d8b92:	je     1d8b40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  1d8b94:	imul   r9,rdx
  1d8b98:	add    r9,rbx
  1d8b9b:	mov    r10,rcx
  1d8b9e:	xchg   ax,ax
  1d8ba0:	movups XMMWORD PTR [r9],xmm0
  1d8ba4:	add    r9,rdx
  1d8ba7:	dec    r10
  1d8baa:	jne    1d8ba0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
  1d8bac:	jmp    1d8b40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  1d8bae:	mov    rax,r12
  1d8bb1:	jmp    1d8d20 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9f0>
  1d8bb6:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe66eea]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1d8bbe:	mov    rax,QWORD PTR [rsp+0x168]
  1d8bc6:	xor    r11d,r11d
  1d8bc9:	test   rax,rax
  1d8bcc:	setne  al
  1d8bcf:	cmp    rbp,r14
  1d8bd2:	jge    1d8bf5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c5>
  1d8bd4:	mov    ecx,DWORD PTR [rsp+0x28]
  1d8bd8:	mov    BYTE PTR [rsp+0x78],cl
  1d8bdc:	mov    r10,QWORD PTR [rsp+0x70]
  1d8be1:	mov    rdx,QWORD PTR [rsp+0x48]
  1d8be6:	mov    r9,QWORD PTR [rsp+0x18]
  1d8beb:	mov    r13,r14
  1d8bee:	mov    QWORD PTR [rsp+0x10],r15
  1d8bf3:	jmp    1d8c32 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x902>
  1d8bf5:	mov    BYTE PTR [rsp+0x78],sil
  1d8bfa:	mov    r10,r8
  1d8bfd:	mov    rdx,QWORD PTR [rsp+0x40]
  1d8c02:	mov    r9,QWORD PTR [rsp+0x8]
  1d8c07:	mov    r13,rbp
  1d8c0a:	mov    QWORD PTR [rsp+0x10],r12
  1d8c0f:	mov    esi,DWORD PTR [rsp+0x28]
  1d8c13:	mov    r8,QWORD PTR [rsp+0x70]
  1d8c18:	mov    rcx,QWORD PTR [rsp+0x48]
  1d8c1d:	mov    QWORD PTR [rsp+0x40],rcx
  1d8c22:	mov    rcx,QWORD PTR [rsp+0x18]
  1d8c27:	mov    QWORD PTR [rsp+0x8],rcx
  1d8c2c:	mov    rbp,r14
  1d8c2f:	mov    r12,r15
  1d8c32:	test   rbp,rbp
  1d8c35:	js     1d8dc1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  1d8c3b:	test   r13,r13
  1d8c3e:	js     1d8de0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab0>
  1d8c44:	mov    r11b,al
  1d8c47:	test   rdx,rdx
  1d8c4a:	mov    QWORD PTR [rsp+0x70],r13
  1d8c4f:	js     1d8e06 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad6>
  1d8c55:	mov    r13,r11
  1d8c58:	mov    QWORD PTR [rsp+0x48],r10
  1d8c5d:	mov    QWORD PTR [rsp+0x28],r9
  1d8c62:	mov    QWORD PTR [rsp+0x18],rdx
  1d8c67:	mov    QWORD PTR [rsp+0x30],r8
  1d8c6c:	mov    r15,QWORD PTR [rsp+0x38]
  1d8c71:	mov    rax,QWORD PTR [rip+0x3723a0]        # 54b018 <_DYNAMIC+0x618>
  1d8c78:	mov    rax,QWORD PTR [rax]
  1d8c7b:	test   rax,rax
  1d8c7e:	jne    1d8cb2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x982>
  1d8c80:	mov    r14d,esi
  1d8c83:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1d8c8b:	movsd  QWORD PTR [rsp+0x90],xmm0
  1d8c94:	call   QWORD PTR [rip+0x372386]        # 54b020 <_DYNAMIC+0x620>
  1d8c9a:	movsd  xmm0,QWORD PTR [rsp+0x90]
  1d8ca3:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1d8cab:	mov    edi,DWORD PTR [rsp+0x20]
  1d8caf:	mov    esi,r14d
  1d8cb2:	movaps xmm3,xmm2
  1d8cb5:	unpckhpd xmm3,xmm2
  1d8cb9:	movzx  r11d,sil
  1d8cbd:	movzx  r14d,BYTE PTR [rsp+0x78]
  1d8cc3:	movzx  r10d,dil
  1d8cc7:	xorps  xmm1,xmm1
  1d8cca:	mov    rdi,QWORD PTR [rsp+0x10]
  1d8ccf:	mov    rsi,r12
  1d8cd2:	mov    rdx,r15
  1d8cd5:	mov    rcx,rbx
  1d8cd8:	mov    r8,QWORD PTR [rsp+0x70]
  1d8cdd:	mov    r9,rbp
  1d8ce0:	push   QWORD PTR [rsp+0x168]
  1d8ce7:	push   r13
  1d8ce9:	push   r11
  1d8ceb:	push   r14
  1d8ced:	push   0x0
  1d8cef:	push   QWORD PTR [rsp+0x68]
  1d8cf3:	push   QWORD PTR [rsp+0x60]
  1d8cf7:	push   QWORD PTR [rsp+0x40]
  1d8cfb:	push   QWORD PTR [rsp+0x88]
  1d8d02:	push   QWORD PTR [rsp+0x60]
  1d8d06:	push   QWORD PTR [rsp+0x78]
  1d8d0a:	push   r10
  1d8d0c:	call   rax
  1d8d0e:	add    rsp,0x60
  1d8d12:	jmp    1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d8d17:	mov    rax,r15
  1d8d1a:	mov    r15,r12
  1d8d1d:	mov    rbp,r14
  1d8d20:	mov    ecx,0x1
  1d8d25:	sub    rcx,rax
  1d8d28:	shl    rcx,0x4
  1d8d2c:	add    rbx,rcx
  1d8d2f:	lea    rcx,[rax-0x1]
  1d8d33:	mov    edx,eax
  1d8d35:	and    edx,0x3
  1d8d38:	and    rax,0xfffffffffffffffc
  1d8d3c:	xor    esi,esi
  1d8d3e:	xorps  xmm0,xmm0
  1d8d41:	jmp    1d8d5c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa2c>
  1d8d43:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1d8d50:	inc    rsi
  1d8d53:	cmp    rsi,r15
  1d8d56:	je     1d8fdb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1d8d5c:	mov    rdi,rsi
  1d8d5f:	imul   rdi,rbp
  1d8d63:	shl    rdi,0x4
  1d8d67:	add    rdi,rbx
  1d8d6a:	cmp    rcx,0x3
  1d8d6e:	jb     1d8da1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa71>
  1d8d70:	xor    r8d,r8d
  1d8d73:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1d8d80:	movups XMMWORD PTR [rdi],xmm0
  1d8d83:	movups XMMWORD PTR [rdi+0x10],xmm0
  1d8d87:	movups XMMWORD PTR [rdi+0x20],xmm0
  1d8d8b:	movups XMMWORD PTR [rdi+0x30],xmm0
  1d8d8f:	add    rdi,0x40
  1d8d93:	add    r8,0x4
  1d8d97:	cmp    rax,r8
  1d8d9a:	jne    1d8d80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa50>
  1d8d9c:	test   rdx,rdx
  1d8d9f:	je     1d8d50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  1d8da1:	xor    r8d,r8d
  1d8da4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1d8db0:	movups XMMWORD PTR [rdi],xmm0
  1d8db3:	add    rdi,0x10
  1d8db7:	inc    r8
  1d8dba:	cmp    rdx,r8
  1d8dbd:	jne    1d8db0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa80>
  1d8dbf:	jmp    1d8d50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  1d8dc1:	mov    rcx,QWORD PTR [rsp+0x10]
  1d8dc6:	dec    rcx
  1d8dc9:	imul   rcx,r10
  1d8dcd:	shl    rcx,0x4
  1d8dd1:	add    r9,rcx
  1d8dd4:	neg    r10
  1d8dd7:	test   r13,r13
  1d8dda:	jns    1d8c44 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x914>
  1d8de0:	lea    rcx,[r12-0x1]
  1d8de5:	imul   rcx,r8
  1d8de9:	shl    rcx,0x4
  1d8ded:	add    QWORD PTR [rsp+0x8],rcx
  1d8df2:	neg    r8
  1d8df5:	mov    r11b,al
  1d8df8:	test   rdx,rdx
  1d8dfb:	mov    QWORD PTR [rsp+0x70],r13
  1d8e00:	jns    1d8c55 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  1d8e06:	mov    rax,QWORD PTR [rsp+0x38]
  1d8e0b:	dec    rax
  1d8e0e:	mov    rcx,rdx
  1d8e11:	imul   rcx,rax
  1d8e15:	shl    rcx,0x4
  1d8e19:	add    r9,rcx
  1d8e1c:	neg    rdx
  1d8e1f:	mov    rcx,QWORD PTR [rsp+0x40]
  1d8e24:	imul   rax,rcx
  1d8e28:	shl    rax,0x4
  1d8e2c:	add    QWORD PTR [rsp+0x8],rax
  1d8e31:	neg    rcx
  1d8e34:	mov    QWORD PTR [rsp+0x40],rcx
  1d8e39:	jmp    1d8c55 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  1d8e3e:	mov    rax,0xffffffffffffffff
  1d8e45:	jmp    1d88b6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x586>
  1d8e4a:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1d8e52:	call   QWORD PTR [rip+0x372150]        # 54afa8 <_DYNAMIC+0x5a8>
  1d8e58:	mov    rdx,QWORD PTR [rip+0x372139]        # 54af98 <_DYNAMIC+0x598>
  1d8e5f:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1d8e67:	mov    r8,QWORD PTR [rsp+0x30]
  1d8e6c:	mov    edi,DWORD PTR [rsp+0x20]
  1d8e70:	mov    esi,DWORD PTR [rsp+0x10]
  1d8e74:	mov    cl,0x1
  1d8e76:	test   eax,0x80000
  1d8e7b:	je     1d88f5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5c5>
  1d8e81:	jmp    1d8eeb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  1d8e83:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1d8e8b:	call   QWORD PTR [rip+0x372117]        # 54afa8 <_DYNAMIC+0x5a8>
  1d8e91:	mov    rdx,QWORD PTR [rip+0x372100]        # 54af98 <_DYNAMIC+0x598>
  1d8e98:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1d8ea0:	mov    r8,QWORD PTR [rsp+0x30]
  1d8ea5:	mov    edi,DWORD PTR [rsp+0x20]
  1d8ea9:	mov    esi,DWORD PTR [rsp+0x10]
  1d8ead:	test   ax,ax
  1d8eb0:	js     1d8906 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5d6>
  1d8eb6:	jmp    1d891d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1d8ebb:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1d8ec3:	call   QWORD PTR [rip+0x3720df]        # 54afa8 <_DYNAMIC+0x5a8>
  1d8ec9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1d8ed1:	mov    r8,QWORD PTR [rsp+0x30]
  1d8ed6:	mov    edi,DWORD PTR [rsp+0x20]
  1d8eda:	mov    esi,DWORD PTR [rsp+0x10]
  1d8ede:	bt     rax,0x37
  1d8ee3:	jae    1d891d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1d8ee9:	xor    ecx,ecx
  1d8eeb:	mov    r9,QWORD PTR [rsp+0x38]
  1d8ef0:	imul   r13,r9
  1d8ef4:	mov    rdx,QWORD PTR [rsp+0x168]
  1d8efc:	cmp    rdx,0x1
  1d8f00:	adc    rdx,0x0
  1d8f04:	cmp    r13,0x10000
  1d8f0b:	mov    eax,0x1
  1d8f10:	cmovae rax,rdx
  1d8f14:	sub    rsp,0xa0
  1d8f1b:	lea    rdx,[rsp+0xf0]
  1d8f23:	mov    QWORD PTR [rsp+0x88],rdx
  1d8f2b:	movzx  edx,BYTE PTR [rsp+0xc8]
  1d8f33:	mov    DWORD PTR [rsp+0x80],edx
  1d8f3a:	mov    rdx,QWORD PTR [rsp+0x110]
  1d8f42:	mov    QWORD PTR [rsp+0x78],rdx
  1d8f47:	mov    rdx,QWORD PTR [rsp+0xe8]
  1d8f4f:	mov    QWORD PTR [rsp+0x70],rdx
  1d8f54:	mov    rdx,QWORD PTR [rsp+0xb8]
  1d8f5c:	mov    QWORD PTR [rsp+0x68],rdx
  1d8f61:	xorps  xmm0,xmm0
  1d8f64:	movups XMMWORD PTR [rsp+0x58],xmm0
  1d8f69:	movzx  edx,sil
  1d8f6d:	mov    DWORD PTR [rsp+0x50],edx
  1d8f71:	mov    rdx,QWORD PTR [rsp+0xe0]
  1d8f79:	mov    QWORD PTR [rsp+0x48],rdx
  1d8f7e:	mov    QWORD PTR [rsp+0x40],r8
  1d8f83:	mov    rdx,QWORD PTR [rsp+0xa8]
  1d8f8b:	mov    QWORD PTR [rsp+0x38],rdx
  1d8f90:	movzx  edx,dil
  1d8f94:	mov    DWORD PTR [rsp+0x30],edx
  1d8f98:	movups XMMWORD PTR [rsp+0x18],xmm0
  1d8f9d:	mov    QWORD PTR [rsp+0x10],rbp
  1d8fa2:	mov    QWORD PTR [rsp+0x8],r14
  1d8fa7:	mov    QWORD PTR [rsp],rbx
  1d8fab:	mov    QWORD PTR [rsp+0x90],rax
  1d8fb3:	mov    DWORD PTR [rsp+0x28],0x2
  1d8fbb:	movzx  edx,cl
  1d8fbe:	mov    r8,r15
  1d8fc1:	mov    edi,0x3
  1d8fc6:	mov    esi,0x1
  1d8fcb:	mov    rcx,r12
  1d8fce:	call   QWORD PTR [rip+0x371fcc]        # 54afa0 <_DYNAMIC+0x5a0>
  1d8fd4:	add    rsp,0xa0
  1d8fdb:	add    rsp,0x128
  1d8fe2:	pop    rbx
  1d8fe3:	pop    r12
  1d8fe5:	pop    r13
  1d8fe7:	pop    r14
  1d8fe9:	pop    r15
  1d8feb:	pop    rbp
  1d8fec:	ret
