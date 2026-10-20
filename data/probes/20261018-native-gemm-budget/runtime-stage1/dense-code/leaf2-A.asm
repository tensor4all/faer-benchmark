
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/b7715c53ba75-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001011c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  1011c0:	push   rbp
  1011c1:	push   r15
  1011c3:	push   r14
  1011c5:	push   r13
  1011c7:	push   r12
  1011c9:	push   rbx
  1011ca:	sub    rsp,0x128
  1011d1:	mov    r12,QWORD PTR [rdi+0x8]
  1011d5:	test   r12,r12
  1011d8:	je     101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1011de:	mov    r15,QWORD PTR [rdi+0x10]
  1011e2:	test   r15,r15
  1011e5:	je     101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1011eb:	mov    rbx,QWORD PTR [rdi]
  1011ee:	mov    r14,QWORD PTR [rdi+0x18]
  1011f2:	mov    rbp,QWORD PTR [rdi+0x20]
  1011f6:	mov    rax,QWORD PTR [rdx+0x10]
  1011fa:	mov    QWORD PTR [rsp+0x40],rax
  1011ff:	test   rax,rax
  101202:	je     1012b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf8>
  101208:	mov    DWORD PTR [rsp+0x20],r9d
  10120d:	mov    DWORD PTR [rsp+0x38],esi
  101211:	mov    DWORD PTR [rsp+0x10],ecx
  101215:	mov    r13,QWORD PTR [rdx]
  101218:	mov    rcx,QWORD PTR [rdx+0x8]
  10121c:	mov    rsi,QWORD PTR [rdx+0x18]
  101220:	test   r14,r14
  101223:	mov    QWORD PTR [rsp+0x30],rcx
  101228:	jns    101268 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa8>
  10122a:	lea    rax,[r12-0x1]
  10122f:	imul   rax,r14
  101233:	shl    rax,0x4
  101237:	add    rbx,rax
  10123a:	neg    r14
  10123d:	xor    eax,eax
  10123f:	mov    r9,rsi
  101242:	mov    rsi,rcx
  101245:	sub    rsi,0x1
  101249:	cmovb  rsi,rax
  10124d:	mov    rdi,r9
  101250:	imul   rdi,rsi
  101254:	cmp    rsi,rcx
  101257:	mov    rsi,r9
  10125a:	cmove  rdi,rax
  10125e:	shl    rdi,0x4
  101262:	add    r13,rdi
  101265:	neg    rsi
  101268:	mov    rax,QWORD PTR [rdx+0x20]
  10126c:	mov    rdi,QWORD PTR [r8]
  10126f:	mov    r10,QWORD PTR [r8+0x8]
  101273:	mov    r9,QWORD PTR [r8+0x10]
  101277:	mov    rcx,QWORD PTR [r8+0x20]
  10127b:	test   rbp,rbp
  10127e:	mov    QWORD PTR [rsp+0x50],r9
  101283:	mov    QWORD PTR [rsp+0x28],r10
  101288:	js     101307 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x147>
  10128a:	mov    r11,QWORD PTR [r8+0x18]
  10128e:	test   rax,rax
  101291:	js     101375 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b5>
  101297:	mov    QWORD PTR [rsp+0x18],r13
  10129c:	mov    r10,QWORD PTR [rsp+0x160]
  1012a4:	cmp    r15,0x1
  1012a8:	mov    r8,QWORD PTR [rsp+0x50]
  1012ad:	je     1013f6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x236>
  1012b3:	jmp    1014f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1012b8:	test   sil,sil
  1012bb:	jne    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1012c1:	cmp    r12,0x1
  1012c5:	je     1012db <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x11b>
  1012c7:	cmp    r14,0xffffffffffffffff
  1012cb:	je     101a5e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89e>
  1012d1:	cmp    r14,0x1
  1012d5:	je     1017fb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x63b>
  1012db:	cmp    r15,0x1
  1012df:	je     1017f1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1012e5:	cmp    rbp,0xffffffffffffffff
  1012e9:	je     101bca <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0a>
  1012ef:	cmp    rbp,0x1
  1012f3:	jne    1017f1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1012f9:	mov    rax,r15
  1012fc:	mov    r15,r12
  1012ff:	mov    rbp,r14
  101302:	jmp    101be2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  101307:	lea    rdx,[r15-0x1]
  10130b:	imul   rdx,rbp
  10130f:	shl    rdx,0x4
  101313:	add    rbx,rdx
  101316:	neg    rbp
  101319:	xor    edx,edx
  10131b:	mov    r11,rsi
  10131e:	mov    rsi,r9
  101321:	sub    rsi,0x1
  101325:	cmovb  rsi,rdx
  101329:	mov    rdx,rbp
  10132c:	mov    rbp,rcx
  10132f:	mov    rcx,rdi
  101332:	mov    rdi,rbp
  101335:	imul   rdi,rsi
  101339:	cmp    rsi,r9
  10133c:	mov    rsi,r11
  10133f:	mov    r10,QWORD PTR [rsp+0x28]
  101344:	mov    r9d,0x0
  10134a:	cmove  rdi,r9
  10134e:	test   r10,r10
  101351:	cmove  rdi,r10
  101355:	shl    rdi,0x4
  101359:	add    rcx,rdi
  10135c:	mov    rdi,rcx
  10135f:	mov    rcx,rbp
  101362:	mov    rbp,rdx
  101365:	neg    rcx
  101368:	mov    r11,QWORD PTR [r8+0x18]
  10136c:	test   rax,rax
  10136f:	jns    101297 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd7>
  101375:	mov    rdx,QWORD PTR [rsp+0x40]
  10137a:	dec    rdx
  10137d:	imul   rdx,rax
  101381:	mov    r8,QWORD PTR [rsp+0x30]
  101386:	test   r8,r8
  101389:	cmove  rdx,r8
  10138d:	shl    rdx,0x4
  101391:	add    r13,rdx
  101394:	mov    QWORD PTR [rsp+0x18],r13
  101399:	neg    rax
  10139c:	xor    edx,edx
  10139e:	mov    r8,rsi
  1013a1:	mov    rsi,r10
  1013a4:	sub    rsi,0x1
  1013a8:	cmovb  rsi,rdx
  1013ac:	mov    r13,rcx
  1013af:	mov    rcx,rdi
  1013b2:	mov    rdi,r11
  1013b5:	imul   rdi,rsi
  1013b9:	mov    r9,QWORD PTR [rsp+0x50]
  1013be:	test   r9,r9
  1013c1:	cmove  rdi,r9
  1013c5:	cmp    rsi,r10
  1013c8:	mov    rsi,r8
  1013cb:	cmove  rdi,rdx
  1013cf:	shl    rdi,0x4
  1013d3:	add    rcx,rdi
  1013d6:	mov    rdi,rcx
  1013d9:	mov    rcx,r13
  1013dc:	neg    r11
  1013df:	mov    r10,QWORD PTR [rsp+0x160]
  1013e7:	cmp    r15,0x1
  1013eb:	mov    r8,QWORD PTR [rsp+0x50]
  1013f0:	jne    1014f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1013f6:	cmp    rsi,0x1
  1013fa:	jne    101476 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1013fc:	cmp    r14,0x1
  101400:	jne    101476 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  101402:	test   rbx,rbx
  101405:	je     101476 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  101407:	mov    rcx,QWORD PTR [rsp+0x18]
  10140c:	mov    QWORD PTR [rsp+0x90],rcx
  101414:	mov    rcx,QWORD PTR [rsp+0x30]
  101419:	mov    QWORD PTR [rsp+0x98],rcx
  101421:	mov    rcx,QWORD PTR [rsp+0x40]
  101426:	mov    QWORD PTR [rsp+0xa0],rcx
  10142e:	mov    QWORD PTR [rsp+0xa8],rax
  101436:	mov    QWORD PTR [rsp+0x60],rdi
  10143b:	mov    rax,QWORD PTR [rsp+0x28]
  101440:	mov    QWORD PTR [rsp+0x68],rax
  101445:	mov    QWORD PTR [rsp+0x70],r11
  10144a:	sub    rsp,0x8
  10144e:	movzx  eax,BYTE PTR [rsp+0x28]
  101453:	movzx  edx,BYTE PTR [rsp+0x40]
  101458:	movzx  r8d,BYTE PTR [rsp+0x18]
  10145e:	lea    rcx,[rsp+0x98]
  101466:	lea    r9,[rsp+0x68]
  10146b:	mov    rdi,rbx
  10146e:	mov    rsi,r12
  101471:	jmp    10157a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3ba>
  101476:	cmp    rax,0x1
  10147a:	jne    1014f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  10147c:	cmp    r11,0x1
  101480:	jne    1014f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  101482:	test   rdi,rdi
  101485:	je     1014f2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  101487:	mov    rax,QWORD PTR [rsp+0x18]
  10148c:	mov    QWORD PTR [rsp+0x90],rax
  101494:	mov    rax,QWORD PTR [rsp+0x30]
  101499:	mov    QWORD PTR [rsp+0x98],rax
  1014a1:	mov    rax,QWORD PTR [rsp+0x40]
  1014a6:	mov    QWORD PTR [rsp+0xa0],rax
  1014ae:	mov    QWORD PTR [rsp+0xa8],rsi
  1014b6:	mov    QWORD PTR [rsp+0x60],rbx
  1014bb:	mov    QWORD PTR [rsp+0x68],r12
  1014c0:	mov    QWORD PTR [rsp+0x70],r14
  1014c5:	sub    rsp,0x8
  1014c9:	movzx  eax,BYTE PTR [rsp+0x28]
  1014ce:	movzx  esi,BYTE PTR [rsp+0x40]
  1014d3:	movzx  ecx,BYTE PTR [rsp+0x18]
  1014d8:	mov    r8,rdi
  1014db:	lea    rdi,[rsp+0x68]
  1014e0:	lea    rdx,[rsp+0x98]
  1014e8:	mov    r9,QWORD PTR [rsp+0x30]
  1014ed:	jmp    101607 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x447>
  1014f2:	cmp    r12,0x1
  1014f6:	jne    10161f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1014fc:	xor    edx,edx
  1014fe:	cmp    rbp,0x1
  101502:	cmove  rdx,rbx
  101506:	cmp    rcx,0x1
  10150a:	jne    101592 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  101510:	test   rdx,rdx
  101513:	je     101592 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  101515:	mov    QWORD PTR [rsp+0x90],rdi
  10151d:	mov    QWORD PTR [rsp+0x98],r8
  101525:	mov    rcx,QWORD PTR [rsp+0x28]
  10152a:	mov    QWORD PTR [rsp+0xa0],rcx
  101532:	mov    QWORD PTR [rsp+0xa8],r11
  10153a:	mov    rcx,QWORD PTR [rsp+0x18]
  10153f:	mov    QWORD PTR [rsp+0x60],rcx
  101544:	mov    rcx,QWORD PTR [rsp+0x40]
  101549:	mov    QWORD PTR [rsp+0x68],rcx
  10154e:	mov    QWORD PTR [rsp+0x70],rax
  101553:	sub    rsp,0x8
  101557:	movzx  eax,BYTE PTR [rsp+0x18]
  10155c:	movzx  edx,BYTE PTR [rsp+0x40]
  101561:	movzx  r8d,BYTE PTR [rsp+0x28]
  101567:	lea    rcx,[rsp+0x98]
  10156f:	lea    r9,[rsp+0x68]
  101574:	mov    rdi,rbx
  101577:	mov    rsi,r15
  10157a:	push   QWORD PTR [rsp+0x170]
  101581:	push   r10
  101583:	push   rax
  101584:	call   1486b0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  101589:	add    rsp,0x20
  10158d:	jmp    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  101592:	xor    edx,edx
  101594:	cmp    rax,0x1
  101598:	cmove  rdx,QWORD PTR [rsp+0x18]
  10159e:	cmp    r11,0x1
  1015a2:	jne    10161f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1015a4:	test   rdx,rdx
  1015a7:	je     10161f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1015a9:	mov    QWORD PTR [rsp+0x90],rdi
  1015b1:	mov    QWORD PTR [rsp+0x98],r8
  1015b9:	mov    rax,QWORD PTR [rsp+0x28]
  1015be:	mov    QWORD PTR [rsp+0xa0],rax
  1015c6:	mov    QWORD PTR [rsp+0xa8],rcx
  1015ce:	mov    QWORD PTR [rsp+0x60],rbx
  1015d3:	mov    QWORD PTR [rsp+0x68],r15
  1015d8:	mov    QWORD PTR [rsp+0x70],rbp
  1015dd:	sub    rsp,0x8
  1015e1:	movzx  eax,BYTE PTR [rsp+0x18]
  1015e6:	movzx  esi,BYTE PTR [rsp+0x40]
  1015eb:	movzx  ecx,BYTE PTR [rsp+0x28]
  1015f0:	lea    rdi,[rsp+0x68]
  1015f5:	lea    rdx,[rsp+0x98]
  1015fd:	mov    r8,QWORD PTR [rsp+0x20]
  101602:	mov    r9,QWORD PTR [rsp+0x48]
  101607:	push   QWORD PTR [rsp+0x170]
  10160e:	push   r10
  101610:	push   rax
  101611:	call   1f86e0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  101616:	add    rsp,0x20
  10161a:	jmp    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  10161f:	cmp    QWORD PTR [rsp+0x40],0x1
  101625:	jne    101738 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  10162b:	xor    edx,edx
  10162d:	cmp    r14,0x1
  101631:	cmove  rdx,rbx
  101635:	cmp    rsi,0x1
  101639:	jne    1016a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  10163b:	test   rdx,rdx
  10163e:	je     1016a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  101640:	mov    QWORD PTR [rsp+0x90],rdx
  101648:	mov    QWORD PTR [rsp+0x98],r12
  101650:	mov    QWORD PTR [rsp+0xa0],r15
  101658:	mov    QWORD PTR [rsp+0xa8],rbp
  101660:	mov    QWORD PTR [rsp+0x60],rdi
  101665:	mov    QWORD PTR [rsp+0x68],r8
  10166a:	mov    QWORD PTR [rsp+0x70],rcx
  10166f:	sub    rsp,0x8
  101673:	movzx  eax,BYTE PTR [rsp+0x28]
  101678:	movzx  esi,BYTE PTR [rsp+0x40]
  10167d:	movzx  r8d,BYTE PTR [rsp+0x18]
  101683:	lea    rdi,[rsp+0x98]
  10168b:	lea    r9,[rsp+0x68]
  101690:	mov    rdx,QWORD PTR [rsp+0x20]
  101695:	mov    rcx,QWORD PTR [rsp+0x38]
  10169a:	push   QWORD PTR [rsp+0x170]
  1016a1:	push   r10
  1016a3:	push   rax
  1016a4:	jmp    10172a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x56a>
  1016a9:	xor    edx,edx
  1016ab:	cmp    rbp,0x1
  1016af:	cmove  rdx,rbx
  1016b3:	cmp    rcx,0x1
  1016b7:	jne    101738 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1016b9:	test   rdx,rdx
  1016bc:	je     101738 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1016be:	mov    QWORD PTR [rsp+0x90],rdx
  1016c6:	mov    QWORD PTR [rsp+0x98],r15
  1016ce:	mov    QWORD PTR [rsp+0xa0],r12
  1016d6:	mov    QWORD PTR [rsp+0xa8],r14
  1016de:	mov    rax,QWORD PTR [rsp+0x18]
  1016e3:	mov    QWORD PTR [rsp+0x60],rax
  1016e8:	mov    rax,QWORD PTR [rsp+0x30]
  1016ed:	mov    QWORD PTR [rsp+0x68],rax
  1016f2:	mov    QWORD PTR [rsp+0x70],rsi
  1016f7:	sub    rsp,0x8
  1016fb:	movzx  r11d,BYTE PTR [rsp+0x18]
  101701:	movzx  esi,BYTE PTR [rsp+0x40]
  101706:	mov    rcx,r8
  101709:	movzx  r8d,BYTE PTR [rsp+0x28]
  10170f:	mov    rdx,rdi
  101712:	lea    rdi,[rsp+0x98]
  10171a:	lea    r9,[rsp+0x68]
  10171f:	push   QWORD PTR [rsp+0x170]
  101726:	push   r10
  101728:	push   r11
  10172a:	call   148290 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  10172f:	add    rsp,0x20
  101733:	jmp    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  101738:	mov    QWORD PTR [rsp+0x28],r11
  10173d:	mov    QWORD PTR [rsp+0x50],rcx
  101742:	mov    QWORD PTR [rsp+0x30],rdi
  101747:	mov    QWORD PTR [rsp+0x58],rax
  10174c:	movups xmm2,XMMWORD PTR [r10]
  101750:	mov    rax,r12
  101753:	mul    r15
  101756:	mov    r13,rax
  101759:	movaps XMMWORD PTR [rsp+0x60],xmm2
  10175e:	seto   r10b
  101762:	jo     101ced <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb2d>
  101768:	mul    QWORD PTR [rsp+0x40]
  10176d:	seto   cl
  101770:	not    cl
  101772:	cmp    rax,0x1001
  101778:	setb   al
  10177b:	test   cl,al
  10177d:	mov    rdi,QWORD PTR [rsp+0x18]
  101782:	mov    r8d,DWORD PTR [rsp+0x10]
  101787:	mov    r9d,DWORD PTR [rsp+0x38]
  10178c:	jne    1017e7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x627>
  10178e:	mov    rdx,QWORD PTR [rip+0x44a4eb]        # 54bc80 <_DYNAMIC+0x498>
  101795:	mov    rax,QWORD PTR [rdx]
  101798:	test   rax,rax
  10179b:	je     101cf9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb39>
  1017a1:	mov    cl,0x1
  1017a3:	test   eax,0x80000
  1017a8:	jne    101de2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  1017ae:	mov    rax,QWORD PTR [rdx]
  1017b1:	test   rax,rax
  1017b4:	je     101d4c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8c>
  1017ba:	test   ax,ax
  1017bd:	jns    1017d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1017bf:	mov    rax,QWORD PTR [rdx]
  1017c2:	test   rax,rax
  1017c5:	je     101d9b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbdb>
  1017cb:	bt     rax,0x37
  1017d0:	jb     101de0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc20>
  1017d6:	test   r9b,r9b
  1017d9:	jne    101a66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a6>
  1017df:	xorps  xmm0,xmm0
  1017e2:	jmp    101a6e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  1017e7:	test   r9b,r9b
  1017ea:	jne    101803 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x643>
  1017ec:	xorps  xmm0,xmm0
  1017ef:	jmp    10180b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x64b>
  1017f1:	cmp    r14,0x1
  1017f5:	jne    1019b8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f8>
  1017fb:	mov    rax,r12
  1017fe:	jmp    101be2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  101803:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff3e3cd]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
  10180b:	movsd  QWORD PTR [rsp+0x38],xmm0
  101811:	mov    r13d,DWORD PTR [rsp+0x20]
  101816:	mov    rax,QWORD PTR [rsp+0x58]
  10181b:	mov    rcx,QWORD PTR [rsp+0x50]
  101820:	mov    rdx,QWORD PTR [rsp+0x28]
  101825:	cmp    rbp,r14
  101828:	jae    101848 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x688>
  10182a:	mov    BYTE PTR [rsp+0x20],r8b
  10182f:	mov    QWORD PTR [rsp+0x10],rsi
  101834:	mov    QWORD PTR [rsp+0x58],rax
  101839:	mov    QWORD PTR [rsp+0x48],rdi
  10183e:	mov    QWORD PTR [rsp+0x18],r14
  101843:	mov    r14,r12
  101846:	jmp    10187d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6bd>
  101848:	mov    BYTE PTR [rsp+0x20],r13b
  10184d:	mov    r13d,r8d
  101850:	mov    QWORD PTR [rsp+0x10],rcx
  101855:	mov    QWORD PTR [rsp+0x58],rdx
  10185a:	mov    rcx,QWORD PTR [rsp+0x30]
  10185f:	mov    QWORD PTR [rsp+0x48],rcx
  101864:	mov    rdx,rax
  101867:	mov    rcx,rsi
  10186a:	mov    QWORD PTR [rsp+0x30],rdi
  10186f:	mov    QWORD PTR [rsp+0x18],rbp
  101874:	mov    rbp,r14
  101877:	mov    r14,r15
  10187a:	mov    r15,r12
  10187d:	movaps XMMWORD PTR [rsp+0x80],xmm2
  101885:	mov    QWORD PTR [rsp+0x28],rdx
  10188a:	mov    QWORD PTR [rsp+0x50],rcx
  10188f:	cmp    rcx,0x1
  101893:	jne    1018c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  101895:	cmp    rbp,0x1
  101899:	jne    1018c0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  10189b:	lea    r8,[rip+0x42fee6]        # 531788 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x3e0>
  1018a2:	lea    rdi,[rsp+0x90]
  1018aa:	mov    rsi,r15
  1018ad:	mov    rdx,r14
  1018b0:	mov    r12,QWORD PTR [rsp+0x40]
  1018b5:	mov    rcx,r12
  1018b8:	call   QWORD PTR [rip+0x44a3ca]        # 54bc88 <_DYNAMIC+0x4a0>
  1018be:	jmp    1018e3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x723>
  1018c0:	lea    r8,[rip+0x42fed9]        # 5317a0 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x3f8>
  1018c7:	lea    rdi,[rsp+0x90]
  1018cf:	mov    rsi,r15
  1018d2:	mov    rdx,r14
  1018d5:	mov    r12,QWORD PTR [rsp+0x40]
  1018da:	mov    rcx,r12
  1018dd:	call   QWORD PTR [rip+0x44a3ad]        # 54bc90 <_DYNAMIC+0x4a8>
  1018e3:	lea    rdi,[rsp+0x98]
  1018eb:	mov    rsi,QWORD PTR [rsp+0xb8]
  1018f3:	mov    rdx,QWORD PTR [rsp+0xc0]
  1018fb:	movups xmm0,XMMWORD PTR [rsp+0xc8]
  101903:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  10190b:	movaps xmm3,xmm2
  10190e:	unpckhpd xmm3,xmm2
  101912:	sub    rsp,0x70
  101916:	movups XMMWORD PTR [rsp+0x58],xmm0
  10191b:	movzx  eax,BYTE PTR [rsp+0x90]
  101923:	mov    DWORD PTR [rsp+0x50],eax
  101927:	movzx  eax,r13b
  10192b:	mov    DWORD PTR [rsp+0x48],eax
  10192f:	mov    rax,QWORD PTR [rsp+0x80]
  101937:	mov    QWORD PTR [rsp+0x40],rax
  10193c:	mov    rax,QWORD PTR [rsp+0xc8]
  101944:	mov    QWORD PTR [rsp+0x38],rax
  101949:	mov    rax,QWORD PTR [rsp+0xb8]
  101951:	mov    QWORD PTR [rsp+0x30],rax
  101956:	mov    rax,QWORD PTR [rsp+0x98]
  10195e:	mov    QWORD PTR [rsp+0x28],rax
  101963:	mov    rax,QWORD PTR [rsp+0xc0]
  10196b:	mov    QWORD PTR [rsp+0x20],rax
  101970:	mov    rax,QWORD PTR [rsp+0xa0]
  101978:	mov    QWORD PTR [rsp+0x18],rax
  10197d:	mov    rax,QWORD PTR [rsp+0x88]
  101985:	mov    QWORD PTR [rsp+0x10],rax
  10198a:	mov    QWORD PTR [rsp+0x8],rbp
  10198f:	mov    QWORD PTR [rsp],rbx
  101993:	xorps  xmm1,xmm1
  101996:	mov    r8,r14
  101999:	mov    r9,r12
  10199c:	mov    rcx,r15
  10199f:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  1019a8:	call   QWORD PTR [rsp+0x100]
  1019af:	add    rsp,0x70
  1019b3:	jmp    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1019b8:	lea    rax,[r12-0x1]
  1019bd:	mov    ecx,r12d
  1019c0:	and    ecx,0x3
  1019c3:	and    r12,0xfffffffffffffffc
  1019c7:	mov    rdx,r14
  1019ca:	shl    rdx,0x4
  1019ce:	lea    rsi,[rdx+rdx*2]
  1019d2:	shl    rbp,0x4
  1019d6:	mov    rdi,r14
  1019d9:	shl    rdi,0x6
  1019dd:	shl    r14,0x5
  1019e1:	xor    r8d,r8d
  1019e4:	xorps  xmm0,xmm0
  1019e7:	jmp    1019ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83f>
  1019e9:	nop    DWORD PTR [rax+0x0]
  1019f0:	inc    r8
  1019f3:	add    rbx,rbp
  1019f6:	cmp    r8,r15
  1019f9:	je     101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1019ff:	cmp    rax,0x3
  101a03:	jae    101a10 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x850>
  101a05:	xor    r9d,r9d
  101a08:	jmp    101a44 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x884>
  101a0a:	nop    WORD PTR [rax+rax*1+0x0]
  101a10:	mov    r10,rbx
  101a13:	xor    r9d,r9d
  101a16:	cs nop WORD PTR [rax+rax*1+0x0]
  101a20:	movups XMMWORD PTR [r10],xmm0
  101a24:	movups XMMWORD PTR [r10+rdx*1],xmm0
  101a29:	movups XMMWORD PTR [r10+r14*1],xmm0
  101a2e:	add    r9,0x4
  101a32:	movups XMMWORD PTR [r10+rsi*1],xmm0
  101a37:	add    r10,rdi
  101a3a:	cmp    r12,r9
  101a3d:	jne    101a20 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  101a3f:	test   rcx,rcx
  101a42:	je     1019f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  101a44:	imul   r9,rdx
  101a48:	add    r9,rbx
  101a4b:	mov    r10,rcx
  101a4e:	xchg   ax,ax
  101a50:	movups XMMWORD PTR [r9],xmm0
  101a54:	add    r9,rdx
  101a57:	dec    r10
  101a5a:	jne    101a50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x890>
  101a5c:	jmp    1019f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  101a5e:	mov    rax,r12
  101a61:	jmp    101bd3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa13>
  101a66:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff3e16a]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
  101a6e:	xor    r13d,r13d
  101a71:	cmp    QWORD PTR [rsp+0x168],0x0
  101a7a:	setne  al
  101a7d:	cmp    rbp,r14
  101a80:	jge    101aa5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8e5>
  101a82:	mov    ecx,DWORD PTR [rsp+0x20]
  101a86:	mov    BYTE PTR [rsp+0xf],cl
  101a8a:	mov    r11,QWORD PTR [rsp+0x50]
  101a8f:	mov    rdx,QWORD PTR [rsp+0x28]
  101a94:	mov    r10,QWORD PTR [rsp+0x30]
  101a99:	mov    QWORD PTR [rsp+0x10],r14
  101a9e:	mov    QWORD PTR [rsp+0x48],r15
  101aa3:	jmp    101ade <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x91e>
  101aa5:	mov    BYTE PTR [rsp+0xf],r8b
  101aaa:	mov    r11,rsi
  101aad:	mov    rdx,QWORD PTR [rsp+0x58]
  101ab2:	mov    r10,rdi
  101ab5:	mov    QWORD PTR [rsp+0x10],rbp
  101aba:	mov    QWORD PTR [rsp+0x48],r12
  101abf:	mov    r8d,DWORD PTR [rsp+0x20]
  101ac4:	mov    rsi,QWORD PTR [rsp+0x50]
  101ac9:	mov    rcx,QWORD PTR [rsp+0x28]
  101ace:	mov    QWORD PTR [rsp+0x58],rcx
  101ad3:	mov    rdi,QWORD PTR [rsp+0x30]
  101ad8:	mov    rbp,r14
  101adb:	mov    r12,r15
  101ade:	test   rbp,rbp
  101ae1:	js     101c71 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab1>
  101ae7:	cmp    QWORD PTR [rsp+0x10],0x0
  101aed:	js     101c93 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad3>
  101af3:	mov    r13b,al
  101af6:	test   rdx,rdx
  101af9:	mov    QWORD PTR [rsp+0x30],r13
  101afe:	js     101cb7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaf7>
  101b04:	mov    QWORD PTR [rsp+0x28],r11
  101b09:	mov    QWORD PTR [rsp+0x20],r10
  101b0e:	mov    QWORD PTR [rsp+0x50],rdx
  101b13:	mov    QWORD PTR [rsp+0x18],rdi
  101b18:	mov    r13,rsi
  101b1b:	mov    r15,QWORD PTR [rsp+0x40]
  101b20:	mov    rax,QWORD PTR [rip+0x44a171]        # 54bc98 <_DYNAMIC+0x4b0>
  101b27:	mov    rax,QWORD PTR [rax]
  101b2a:	test   rax,rax
  101b2d:	jne    101b62 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a2>
  101b2f:	mov    r14d,r8d
  101b32:	movaps XMMWORD PTR [rsp+0x80],xmm2
  101b3a:	movsd  QWORD PTR [rsp+0x120],xmm0
  101b43:	call   QWORD PTR [rip+0x44a157]        # 54bca0 <_DYNAMIC+0x4b8>
  101b49:	movsd  xmm0,QWORD PTR [rsp+0x120]
  101b52:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  101b5a:	mov    r9d,DWORD PTR [rsp+0x38]
  101b5f:	mov    r8d,r14d
  101b62:	movaps xmm3,xmm2
  101b65:	unpckhpd xmm3,xmm2
  101b69:	movzx  r11d,r8b
  101b6d:	movzx  r14d,BYTE PTR [rsp+0xf]
  101b73:	movzx  r10d,r9b
  101b77:	xorps  xmm1,xmm1
  101b7a:	mov    rdi,QWORD PTR [rsp+0x48]
  101b7f:	mov    rsi,r12
  101b82:	mov    rdx,r15
  101b85:	mov    rcx,rbx
  101b88:	mov    r8,QWORD PTR [rsp+0x10]
  101b8d:	mov    r9,rbp
  101b90:	push   QWORD PTR [rsp+0x168]
  101b97:	push   QWORD PTR [rsp+0x38]
  101b9b:	push   r11
  101b9d:	push   r14
  101b9f:	push   0x0
  101ba1:	push   QWORD PTR [rsp+0x80]
  101ba8:	push   r13
  101baa:	push   QWORD PTR [rsp+0x50]
  101bae:	push   QWORD PTR [rsp+0x68]
  101bb2:	push   QWORD PTR [rsp+0x98]
  101bb9:	push   QWORD PTR [rsp+0x70]
  101bbd:	push   r10
  101bbf:	call   rax
  101bc1:	add    rsp,0x60
  101bc5:	jmp    101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  101bca:	mov    rax,r15
  101bcd:	mov    r15,r12
  101bd0:	mov    rbp,r14
  101bd3:	mov    ecx,0x1
  101bd8:	sub    rcx,rax
  101bdb:	shl    rcx,0x4
  101bdf:	add    rbx,rcx
  101be2:	lea    rcx,[rax-0x1]
  101be6:	mov    edx,eax
  101be8:	and    edx,0x3
  101beb:	and    rax,0xfffffffffffffffc
  101bef:	xor    esi,esi
  101bf1:	xorps  xmm0,xmm0
  101bf4:	jmp    101c0c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4c>
  101bf6:	cs nop WORD PTR [rax+rax*1+0x0]
  101c00:	inc    rsi
  101c03:	cmp    rsi,r15
  101c06:	je     101efb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  101c0c:	mov    rdi,rsi
  101c0f:	imul   rdi,rbp
  101c13:	shl    rdi,0x4
  101c17:	add    rdi,rbx
  101c1a:	cmp    rcx,0x3
  101c1e:	jb     101c51 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  101c20:	xor    r8d,r8d
  101c23:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  101c30:	movups XMMWORD PTR [rdi],xmm0
  101c33:	movups XMMWORD PTR [rdi+0x10],xmm0
  101c37:	movups XMMWORD PTR [rdi+0x20],xmm0
  101c3b:	movups XMMWORD PTR [rdi+0x30],xmm0
  101c3f:	add    rdi,0x40
  101c43:	add    r8,0x4
  101c47:	cmp    rax,r8
  101c4a:	jne    101c30 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa70>
  101c4c:	test   rdx,rdx
  101c4f:	je     101c00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  101c51:	xor    r8d,r8d
  101c54:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  101c60:	movups XMMWORD PTR [rdi],xmm0
  101c63:	add    rdi,0x10
  101c67:	inc    r8
  101c6a:	cmp    rdx,r8
  101c6d:	jne    101c60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa0>
  101c6f:	jmp    101c00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  101c71:	mov    rcx,QWORD PTR [rsp+0x48]
  101c76:	dec    rcx
  101c79:	imul   rcx,r11
  101c7d:	shl    rcx,0x4
  101c81:	add    r10,rcx
  101c84:	neg    r11
  101c87:	cmp    QWORD PTR [rsp+0x10],0x0
  101c8d:	jns    101af3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x933>
  101c93:	lea    rcx,[r12-0x1]
  101c98:	imul   rcx,rsi
  101c9c:	shl    rcx,0x4
  101ca0:	add    rdi,rcx
  101ca3:	neg    rsi
  101ca6:	mov    r13b,al
  101ca9:	test   rdx,rdx
  101cac:	mov    QWORD PTR [rsp+0x30],r13
  101cb1:	jns    101b04 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  101cb7:	mov    rax,QWORD PTR [rsp+0x40]
  101cbc:	dec    rax
  101cbf:	mov    rcx,rdx
  101cc2:	imul   rcx,rax
  101cc6:	shl    rcx,0x4
  101cca:	add    r10,rcx
  101ccd:	neg    rdx
  101cd0:	mov    rcx,QWORD PTR [rsp+0x58]
  101cd5:	imul   rax,rcx
  101cd9:	shl    rax,0x4
  101cdd:	add    rdi,rax
  101ce0:	neg    rcx
  101ce3:	mov    QWORD PTR [rsp+0x58],rcx
  101ce8:	jmp    101b04 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  101ced:	mov    rax,0xffffffffffffffff
  101cf4:	jmp    101768 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a8>
  101cf9:	mov    QWORD PTR [rsp+0x48],rsi
  101cfe:	movaps XMMWORD PTR [rsp+0x80],xmm2
  101d06:	mov    BYTE PTR [rsp+0xf],r10b
  101d0b:	call   QWORD PTR [rip+0x449f97]        # 54bca8 <_DYNAMIC+0x4c0>
  101d11:	mov    rdx,QWORD PTR [rip+0x449f68]        # 54bc80 <_DYNAMIC+0x498>
  101d18:	movzx  r10d,BYTE PTR [rsp+0xf]
  101d1e:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  101d26:	mov    rsi,QWORD PTR [rsp+0x48]
  101d2b:	mov    r9d,DWORD PTR [rsp+0x38]
  101d30:	mov    r8d,DWORD PTR [rsp+0x10]
  101d35:	mov    rdi,QWORD PTR [rsp+0x18]
  101d3a:	mov    cl,0x1
  101d3c:	test   eax,0x80000
  101d41:	je     1017ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ee>
  101d47:	jmp    101de2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  101d4c:	mov    QWORD PTR [rsp+0x48],rsi
  101d51:	movaps XMMWORD PTR [rsp+0x80],xmm2
  101d59:	mov    BYTE PTR [rsp+0xf],r10b
  101d5e:	call   QWORD PTR [rip+0x449f44]        # 54bca8 <_DYNAMIC+0x4c0>
  101d64:	mov    rdx,QWORD PTR [rip+0x449f15]        # 54bc80 <_DYNAMIC+0x498>
  101d6b:	movzx  r10d,BYTE PTR [rsp+0xf]
  101d71:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  101d79:	mov    rsi,QWORD PTR [rsp+0x48]
  101d7e:	mov    r9d,DWORD PTR [rsp+0x38]
  101d83:	mov    r8d,DWORD PTR [rsp+0x10]
  101d88:	mov    rdi,QWORD PTR [rsp+0x18]
  101d8d:	test   ax,ax
  101d90:	js     1017bf <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ff>
  101d96:	jmp    1017d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  101d9b:	mov    QWORD PTR [rsp+0x48],rsi
  101da0:	movaps XMMWORD PTR [rsp+0x80],xmm2
  101da8:	mov    BYTE PTR [rsp+0xf],r10b
  101dad:	call   QWORD PTR [rip+0x449ef5]        # 54bca8 <_DYNAMIC+0x4c0>
  101db3:	movzx  r10d,BYTE PTR [rsp+0xf]
  101db9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  101dc1:	mov    rsi,QWORD PTR [rsp+0x48]
  101dc6:	mov    r9d,DWORD PTR [rsp+0x38]
  101dcb:	mov    r8d,DWORD PTR [rsp+0x10]
  101dd0:	mov    rdi,QWORD PTR [rsp+0x18]
  101dd5:	bt     rax,0x37
  101dda:	jae    1017d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  101de0:	xor    ecx,ecx
  101de2:	test   r10b,r10b
  101de5:	jne    101f0d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd4d>
  101deb:	mov    r10,rsi
  101dee:	mov    rax,r13
  101df1:	mul    QWORD PTR [rsp+0x40]
  101df6:	jo     101f25 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  101dfc:	mov    rdx,rax
  101dff:	shr    rdx,0x3d
  101e03:	jne    101f25 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  101e09:	shl    rax,0x3
  101e0d:	mov    rdx,QWORD PTR [rip+0x449ec4]        # 54bcd8 <_DYNAMIC+0x4f0>
  101e14:	mov    rsi,QWORD PTR [rdx]
  101e17:	add    rsi,rsi
  101e1a:	mov    edx,0x1
  101e1f:	cmp    rax,rsi
  101e22:	jb     101e34 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc74>
  101e24:	mov    rdx,QWORD PTR [rsp+0x168]
  101e2c:	cmp    rdx,0x1
  101e30:	adc    rdx,0x0
  101e34:	sub    rsp,0xa0
  101e3b:	mov    QWORD PTR [rsp+0x90],rdx
  101e43:	lea    rax,[rsp+0x100]
  101e4b:	mov    QWORD PTR [rsp+0x88],rax
  101e53:	movzx  eax,BYTE PTR [rsp+0xc0]
  101e5b:	mov    DWORD PTR [rsp+0x80],eax
  101e62:	mov    rax,QWORD PTR [rsp+0xf0]
  101e6a:	mov    QWORD PTR [rsp+0x78],rax
  101e6f:	mov    rax,QWORD PTR [rsp+0xc8]
  101e77:	mov    QWORD PTR [rsp+0x70],rax
  101e7c:	mov    rax,QWORD PTR [rsp+0xd0]
  101e84:	mov    QWORD PTR [rsp+0x68],rax
  101e89:	xorps  xmm0,xmm0
  101e8c:	movups XMMWORD PTR [rsp+0x58],xmm0
  101e91:	movzx  eax,r8b
  101e95:	mov    DWORD PTR [rsp+0x50],eax
  101e99:	mov    rax,QWORD PTR [rsp+0xf8]
  101ea1:	mov    QWORD PTR [rsp+0x48],rax
  101ea6:	mov    QWORD PTR [rsp+0x40],r10
  101eab:	mov    QWORD PTR [rsp+0x38],rdi
  101eb0:	movzx  eax,r9b
  101eb4:	mov    DWORD PTR [rsp+0x30],eax
  101eb8:	movups XMMWORD PTR [rsp+0x18],xmm0
  101ebd:	mov    QWORD PTR [rsp+0x10],rbp
  101ec2:	mov    QWORD PTR [rsp+0x8],r14
  101ec7:	mov    QWORD PTR [rsp],rbx
  101ecb:	mov    DWORD PTR [rsp+0x28],0x2
  101ed3:	movzx  edx,cl
  101ed6:	mov    r8,r15
  101ed9:	mov    edi,0x3
  101ede:	mov    r9,QWORD PTR [rsp+0xe0]
  101ee6:	mov    esi,0x1
  101eeb:	mov    rcx,r12
  101eee:	call   QWORD PTR [rip+0x449dbc]        # 54bcb0 <_DYNAMIC+0x4c8>
  101ef4:	add    rsp,0xa0
  101efb:	add    rsp,0x128
  101f02:	pop    rbx
  101f03:	pop    r12
  101f05:	pop    r13
  101f07:	pop    r14
  101f09:	pop    r15
  101f0b:	pop    rbp
  101f0c:	ret
  101f0d:	mov    r13,0xffffffffffffffff
  101f14:	mov    r10,rsi
  101f17:	mov    rax,r13
  101f1a:	mul    QWORD PTR [rsp+0x40]
  101f1f:	jno    101dfc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc3c>
  101f25:	mov    rax,QWORD PTR [rip+0x449dac]        # 54bcd8 <_DYNAMIC+0x4f0>
  101f2c:	mov    rax,QWORD PTR [rax]
  101f2f:	jmp    101e24 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc64>
