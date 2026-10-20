
target/faer-rev/b7715c53ba75-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000000f6230 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
   f6230:	push   rbp
   f6231:	push   r15
   f6233:	push   r14
   f6235:	push   r13
   f6237:	push   r12
   f6239:	push   rbx
   f623a:	sub    rsp,0x128
   f6241:	mov    r12,QWORD PTR [rdi+0x8]
   f6245:	test   r12,r12
   f6248:	je     f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f624e:	mov    r15,QWORD PTR [rdi+0x10]
   f6252:	test   r15,r15
   f6255:	je     f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f625b:	mov    rbx,QWORD PTR [rdi]
   f625e:	mov    r14,QWORD PTR [rdi+0x18]
   f6262:	mov    rbp,QWORD PTR [rdi+0x20]
   f6266:	mov    rax,QWORD PTR [rdx+0x10]
   f626a:	mov    QWORD PTR [rsp+0x38],rax
   f626f:	test   rax,rax
   f6272:	je     f6324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
   f6278:	mov    DWORD PTR [rsp+0x28],r9d
   f627d:	mov    DWORD PTR [rsp+0x20],esi
   f6281:	mov    DWORD PTR [rsp+0x10],ecx
   f6285:	mov    r10,QWORD PTR [rdx]
   f6288:	mov    rcx,QWORD PTR [rdx+0x8]
   f628c:	mov    r9,QWORD PTR [rdx+0x18]
   f6290:	test   r14,r14
   f6293:	jns    f62cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d>
   f6295:	lea    rax,[r12-0x1]
   f629a:	imul   rax,r14
   f629e:	shl    rax,0x4
   f62a2:	add    rbx,rax
   f62a5:	neg    r14
   f62a8:	xor    eax,eax
   f62aa:	mov    rsi,rcx
   f62ad:	sub    rsi,0x1
   f62b1:	cmovb  rsi,rax
   f62b5:	mov    rdi,r9
   f62b8:	imul   rdi,rsi
   f62bc:	cmp    rsi,rcx
   f62bf:	cmove  rdi,rax
   f62c3:	shl    rdi,0x4
   f62c7:	add    r10,rdi
   f62ca:	neg    r9
   f62cd:	mov    QWORD PTR [rsp+0x30],r9
   f62d2:	mov    rsi,QWORD PTR [rdx+0x20]
   f62d6:	mov    rdi,QWORD PTR [r8]
   f62d9:	mov    r9,QWORD PTR [r8+0x8]
   f62dd:	mov    rax,QWORD PTR [r8+0x10]
   f62e1:	mov    QWORD PTR [rsp+0x18],rax
   f62e6:	mov    rax,QWORD PTR [r8+0x20]
   f62ea:	test   rbp,rbp
   f62ed:	js     f6373 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x143>
   f62f3:	mov    r8,QWORD PTR [r8+0x18]
   f62f7:	test   rsi,rsi
   f62fa:	js     f63e1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b1>
   f6300:	mov    QWORD PTR [rsp+0x8],r10
   f6305:	mov    r10,QWORD PTR [rsp+0x168]
   f630d:	mov    r11,QWORD PTR [rsp+0x160]
   f6315:	cmp    r15,0x1
   f6319:	je     f646c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x23c>
   f631f:	jmp    f655b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
   f6324:	test   sil,sil
   f6327:	jne    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f632d:	cmp    r12,0x1
   f6331:	je     f6347 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
   f6333:	cmp    r14,0xffffffffffffffff
   f6337:	je     f6aae <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x87e>
   f633d:	cmp    r14,0x1
   f6341:	je     f6842 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x612>
   f6347:	cmp    r15,0x1
   f634b:	je     f6838 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
   f6351:	cmp    rbp,0xffffffffffffffff
   f6355:	je     f6c17 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9e7>
   f635b:	cmp    rbp,0x1
   f635f:	jne    f6838 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
   f6365:	mov    rax,r15
   f6368:	mov    r15,r12
   f636b:	mov    rbp,r14
   f636e:	jmp    f6c2f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
   f6373:	lea    rdx,[r15-0x1]
   f6377:	imul   rdx,rbp
   f637b:	shl    rdx,0x4
   f637f:	add    rbx,rdx
   f6382:	neg    rbp
   f6385:	xor    r13d,r13d
   f6388:	mov    r11,rsi
   f638b:	mov    rsi,QWORD PTR [rsp+0x18]
   f6390:	sub    rsi,0x1
   f6394:	cmovb  rsi,r13
   f6398:	mov    rdx,rcx
   f639b:	mov    rcx,r10
   f639e:	mov    r10,rax
   f63a1:	mov    rax,rdi
   f63a4:	mov    rdi,r10
   f63a7:	imul   rdi,rsi
   f63ab:	cmp    rsi,QWORD PTR [rsp+0x18]
   f63b0:	mov    rsi,r11
   f63b3:	cmove  rdi,r13
   f63b7:	test   r9,r9
   f63ba:	cmove  rdi,r9
   f63be:	shl    rdi,0x4
   f63c2:	add    rax,rdi
   f63c5:	mov    rdi,rax
   f63c8:	mov    rax,r10
   f63cb:	mov    r10,rcx
   f63ce:	mov    rcx,rdx
   f63d1:	neg    rax
   f63d4:	mov    r8,QWORD PTR [r8+0x18]
   f63d8:	test   rsi,rsi
   f63db:	jns    f6300 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd0>
   f63e1:	mov    rdx,QWORD PTR [rsp+0x38]
   f63e6:	dec    rdx
   f63e9:	imul   rdx,rsi
   f63ed:	test   rcx,rcx
   f63f0:	cmove  rdx,rcx
   f63f4:	shl    rdx,0x4
   f63f8:	add    r10,rdx
   f63fb:	mov    QWORD PTR [rsp+0x8],r10
   f6400:	neg    rsi
   f6403:	xor    edx,edx
   f6405:	mov    r10,r8
   f6408:	mov    r8,rsi
   f640b:	mov    rsi,r9
   f640e:	sub    rsi,0x1
   f6412:	cmovb  rsi,rdx
   f6416:	mov    r11,rcx
   f6419:	mov    rcx,rax
   f641c:	mov    rax,rdi
   f641f:	mov    rdi,r10
   f6422:	imul   rdi,rsi
   f6426:	mov    r13,QWORD PTR [rsp+0x18]
   f642b:	test   r13,r13
   f642e:	cmove  rdi,r13
   f6432:	cmp    rsi,r9
   f6435:	mov    rsi,r8
   f6438:	mov    r8,r10
   f643b:	cmove  rdi,rdx
   f643f:	shl    rdi,0x4
   f6443:	add    rax,rdi
   f6446:	mov    rdi,rax
   f6449:	mov    rax,rcx
   f644c:	mov    rcx,r11
   f644f:	neg    r8
   f6452:	mov    r10,QWORD PTR [rsp+0x168]
   f645a:	mov    r11,QWORD PTR [rsp+0x160]
   f6462:	cmp    r15,0x1
   f6466:	jne    f655b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
   f646c:	cmp    QWORD PTR [rsp+0x30],0x1
   f6472:	jne    f64e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
   f6474:	cmp    r14,0x1
   f6478:	jne    f64e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
   f647a:	test   rbx,rbx
   f647d:	je     f64e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
   f647f:	mov    rax,QWORD PTR [rsp+0x8]
   f6484:	mov    QWORD PTR [rsp+0x98],rax
   f648c:	mov    QWORD PTR [rsp+0xa0],rcx
   f6494:	mov    rax,QWORD PTR [rsp+0x38]
   f6499:	mov    QWORD PTR [rsp+0xa8],rax
   f64a1:	mov    QWORD PTR [rsp+0xb0],rsi
   f64a9:	mov    QWORD PTR [rsp+0x50],rdi
   f64ae:	mov    QWORD PTR [rsp+0x58],r9
   f64b3:	mov    QWORD PTR [rsp+0x60],r8
   f64b8:	sub    rsp,0x8
   f64bc:	movzx  eax,BYTE PTR [rsp+0x30]
   f64c1:	movzx  edx,BYTE PTR [rsp+0x28]
   f64c6:	movzx  r8d,BYTE PTR [rsp+0x18]
   f64cc:	lea    rcx,[rsp+0xa0]
   f64d4:	lea    r9,[rsp+0x58]
   f64d9:	mov    rdi,rbx
   f64dc:	mov    rsi,r12
   f64df:	jmp    f65df <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3af>
   f64e4:	cmp    rsi,0x1
   f64e8:	jne    f655b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
   f64ea:	cmp    r8,0x1
   f64ee:	jne    f655b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
   f64f0:	test   rdi,rdi
   f64f3:	je     f655b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
   f64f5:	mov    rax,QWORD PTR [rsp+0x8]
   f64fa:	mov    QWORD PTR [rsp+0x98],rax
   f6502:	mov    QWORD PTR [rsp+0xa0],rcx
   f650a:	mov    rax,QWORD PTR [rsp+0x38]
   f650f:	mov    QWORD PTR [rsp+0xa8],rax
   f6517:	mov    rax,QWORD PTR [rsp+0x30]
   f651c:	mov    QWORD PTR [rsp+0xb0],rax
   f6524:	mov    QWORD PTR [rsp+0x50],rbx
   f6529:	mov    QWORD PTR [rsp+0x58],r12
   f652e:	mov    QWORD PTR [rsp+0x60],r14
   f6533:	sub    rsp,0x8
   f6537:	movzx  eax,BYTE PTR [rsp+0x30]
   f653c:	movzx  esi,BYTE PTR [rsp+0x28]
   f6541:	movzx  ecx,BYTE PTR [rsp+0x18]
   f6546:	mov    r8,rdi
   f6549:	lea    rdi,[rsp+0x58]
   f654e:	lea    rdx,[rsp+0xa0]
   f6556:	jmp    f6667 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x437>
   f655b:	cmp    r12,0x1
   f655f:	jne    f667a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
   f6565:	xor    edx,edx
   f6567:	cmp    rbp,0x1
   f656b:	cmove  rdx,rbx
   f656f:	cmp    rax,0x1
   f6573:	jne    f65f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
   f6575:	test   rdx,rdx
   f6578:	je     f65f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
   f657a:	mov    QWORD PTR [rsp+0x98],rdi
   f6582:	mov    rax,QWORD PTR [rsp+0x18]
   f6587:	mov    QWORD PTR [rsp+0xa0],rax
   f658f:	mov    QWORD PTR [rsp+0xa8],r9
   f6597:	mov    QWORD PTR [rsp+0xb0],r8
   f659f:	mov    rax,QWORD PTR [rsp+0x8]
   f65a4:	mov    QWORD PTR [rsp+0x50],rax
   f65a9:	mov    rax,QWORD PTR [rsp+0x38]
   f65ae:	mov    QWORD PTR [rsp+0x58],rax
   f65b3:	mov    QWORD PTR [rsp+0x60],rsi
   f65b8:	sub    rsp,0x8
   f65bc:	movzx  eax,BYTE PTR [rsp+0x18]
   f65c1:	movzx  edx,BYTE PTR [rsp+0x28]
   f65c6:	movzx  r8d,BYTE PTR [rsp+0x30]
   f65cc:	lea    rcx,[rsp+0xa0]
   f65d4:	lea    r9,[rsp+0x58]
   f65d9:	mov    rdi,rbx
   f65dc:	mov    rsi,r15
   f65df:	push   r10
   f65e1:	push   r11
   f65e3:	push   rax
   f65e4:	call   146820 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
   f65e9:	add    rsp,0x20
   f65ed:	jmp    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f65f2:	xor    edx,edx
   f65f4:	cmp    rsi,0x1
   f65f8:	cmove  rdx,QWORD PTR [rsp+0x8]
   f65fe:	cmp    r8,0x1
   f6602:	jne    f667a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
   f6604:	test   rdx,rdx
   f6607:	je     f667a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
   f6609:	mov    QWORD PTR [rsp+0x98],rdi
   f6611:	mov    rcx,QWORD PTR [rsp+0x18]
   f6616:	mov    QWORD PTR [rsp+0xa0],rcx
   f661e:	mov    QWORD PTR [rsp+0xa8],r9
   f6626:	mov    QWORD PTR [rsp+0xb0],rax
   f662e:	mov    QWORD PTR [rsp+0x50],rbx
   f6633:	mov    QWORD PTR [rsp+0x58],r15
   f6638:	mov    QWORD PTR [rsp+0x60],rbp
   f663d:	sub    rsp,0x8
   f6641:	movzx  eax,BYTE PTR [rsp+0x18]
   f6646:	movzx  esi,BYTE PTR [rsp+0x28]
   f664b:	movzx  ecx,BYTE PTR [rsp+0x30]
   f6650:	lea    rdi,[rsp+0x58]
   f6655:	lea    rdx,[rsp+0xa0]
   f665d:	mov    r8,QWORD PTR [rsp+0x10]
   f6662:	mov    r9,QWORD PTR [rsp+0x40]
   f6667:	push   r10
   f6669:	push   r11
   f666b:	push   rax
   f666c:	call   1f6770 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
   f6671:	add    rsp,0x20
   f6675:	jmp    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f667a:	mov    QWORD PTR [rsp+0x48],r8
   f667f:	cmp    QWORD PTR [rsp+0x38],0x1
   f6685:	mov    r8,QWORD PTR [rsp+0x30]
   f668a:	jne    f678f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
   f6690:	xor    edx,edx
   f6692:	cmp    r14,0x1
   f6696:	cmove  rdx,rbx
   f669a:	cmp    r8,0x1
   f669e:	jne    f6706 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
   f66a0:	test   rdx,rdx
   f66a3:	je     f6706 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
   f66a5:	mov    QWORD PTR [rsp+0x98],rdx
   f66ad:	mov    QWORD PTR [rsp+0xa0],r12
   f66b5:	mov    QWORD PTR [rsp+0xa8],r15
   f66bd:	mov    QWORD PTR [rsp+0xb0],rbp
   f66c5:	mov    QWORD PTR [rsp+0x50],rdi
   f66ca:	mov    rdx,QWORD PTR [rsp+0x18]
   f66cf:	mov    QWORD PTR [rsp+0x58],rdx
   f66d4:	mov    QWORD PTR [rsp+0x60],rax
   f66d9:	sub    rsp,0x8
   f66dd:	movzx  eax,BYTE PTR [rsp+0x30]
   f66e2:	movzx  esi,BYTE PTR [rsp+0x28]
   f66e7:	movzx  r8d,BYTE PTR [rsp+0x18]
   f66ed:	lea    rdi,[rsp+0xa0]
   f66f5:	lea    r9,[rsp+0x58]
   f66fa:	mov    rdx,QWORD PTR [rsp+0x10]
   f66ff:	push   r10
   f6701:	push   r11
   f6703:	push   rax
   f6704:	jmp    f6781 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x551>
   f6706:	xor    edx,edx
   f6708:	cmp    rbp,0x1
   f670c:	cmove  rdx,rbx
   f6710:	cmp    rax,0x1
   f6714:	jne    f678f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
   f6716:	test   rdx,rdx
   f6719:	je     f678f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
   f671b:	mov    QWORD PTR [rsp+0x98],rdx
   f6723:	mov    QWORD PTR [rsp+0xa0],r15
   f672b:	mov    QWORD PTR [rsp+0xa8],r12
   f6733:	mov    QWORD PTR [rsp+0xb0],r14
   f673b:	mov    rax,QWORD PTR [rsp+0x8]
   f6740:	mov    QWORD PTR [rsp+0x50],rax
   f6745:	mov    QWORD PTR [rsp+0x58],rcx
   f674a:	mov    QWORD PTR [rsp+0x60],r8
   f674f:	sub    rsp,0x8
   f6753:	mov    rax,r11
   f6756:	movzx  r11d,BYTE PTR [rsp+0x18]
   f675c:	movzx  esi,BYTE PTR [rsp+0x28]
   f6761:	movzx  r8d,BYTE PTR [rsp+0x30]
   f6767:	mov    rdx,rdi
   f676a:	lea    rdi,[rsp+0xa0]
   f6772:	lea    r9,[rsp+0x58]
   f6777:	mov    rcx,QWORD PTR [rsp+0x20]
   f677c:	push   r10
   f677e:	push   rax
   f677f:	push   r11
   f6781:	call   145260 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
   f6786:	add    rsp,0x20
   f678a:	jmp    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f678f:	mov    QWORD PTR [rsp+0x70],rax
   f6794:	mov    QWORD PTR [rsp+0x18],rdi
   f6799:	mov    QWORD PTR [rsp+0x40],rsi
   f679e:	movups xmm2,XMMWORD PTR [r11]
   f67a2:	movaps XMMWORD PTR [rsp+0x50],xmm2
   f67a7:	mov    rax,r12
   f67aa:	mul    r15
   f67ad:	mov    r13,rax
   f67b0:	jo     f6d3e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb0e>
   f67b6:	mul    QWORD PTR [rsp+0x38]
   f67bb:	seto   cl
   f67be:	not    cl
   f67c0:	cmp    rax,0x1001
   f67c6:	setb   al
   f67c9:	test   cl,al
   f67cb:	mov    esi,DWORD PTR [rsp+0x10]
   f67cf:	mov    edi,DWORD PTR [rsp+0x20]
   f67d3:	jne    f682e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5fe>
   f67d5:	mov    rdx,QWORD PTR [rip+0x4554a4]        # 54bc80 <_DYNAMIC+0x498>
   f67dc:	mov    rax,QWORD PTR [rdx]
   f67df:	test   rax,rax
   f67e2:	je     f6d4a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb1a>
   f67e8:	mov    cl,0x1
   f67ea:	test   eax,0x80000
   f67ef:	jne    f6deb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
   f67f5:	mov    rax,QWORD PTR [rdx]
   f67f8:	test   rax,rax
   f67fb:	je     f6d83 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb53>
   f6801:	test   ax,ax
   f6804:	jns    f681d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
   f6806:	mov    rax,QWORD PTR [rdx]
   f6809:	test   rax,rax
   f680c:	je     f6dbb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8b>
   f6812:	bt     rax,0x37
   f6817:	jb     f6de9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbb9>
   f681d:	test   dil,dil
   f6820:	jne    f6ab6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x886>
   f6826:	xorps  xmm0,xmm0
   f6829:	jmp    f6abe <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x88e>
   f682e:	test   dil,dil
   f6831:	jne    f684a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
   f6833:	xorps  xmm0,xmm0
   f6836:	jmp    f6852 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x622>
   f6838:	cmp    r14,0x1
   f683c:	jne    f6a07 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7d7>
   f6842:	mov    rax,r12
   f6845:	jmp    f6c2f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
   f684a:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff49386]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
   f6852:	movsd  QWORD PTR [rsp+0x20],xmm0
   f6858:	mov    rax,QWORD PTR [rsp+0x8]
   f685d:	mov    rdx,QWORD PTR [rsp+0x18]
   f6862:	cmp    rbp,r14
   f6865:	jae    f6892 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x662>
   f6867:	mov    BYTE PTR [rsp+0x8],sil
   f686c:	mov    QWORD PTR [rsp+0x10],r8
   f6871:	mov    rcx,QWORD PTR [rsp+0x40]
   f6876:	mov    QWORD PTR [rsp+0x78],rcx
   f687b:	mov    QWORD PTR [rsp+0x90],rax
   f6883:	mov    QWORD PTR [rsp+0x30],r14
   f6888:	mov    r13,r12
   f688b:	mov    r8,QWORD PTR [rsp+0x70]
   f6890:	jmp    f68d5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a5>
   f6892:	mov    ecx,DWORD PTR [rsp+0x28]
   f6896:	mov    BYTE PTR [rsp+0x8],cl
   f689a:	mov    DWORD PTR [rsp+0x28],esi
   f689e:	mov    rcx,QWORD PTR [rsp+0x70]
   f68a3:	mov    QWORD PTR [rsp+0x10],rcx
   f68a8:	mov    rcx,QWORD PTR [rsp+0x48]
   f68ad:	mov    QWORD PTR [rsp+0x78],rcx
   f68b2:	mov    QWORD PTR [rsp+0x90],rdx
   f68ba:	mov    rcx,QWORD PTR [rsp+0x40]
   f68bf:	mov    QWORD PTR [rsp+0x48],rcx
   f68c4:	mov    rdx,rax
   f68c7:	mov    QWORD PTR [rsp+0x30],rbp
   f68cc:	mov    rbp,r14
   f68cf:	mov    r13,r15
   f68d2:	mov    r15,r12
   f68d5:	movaps XMMWORD PTR [rsp+0x80],xmm2
   f68dd:	mov    QWORD PTR [rsp+0x18],rdx
   f68e2:	mov    r12,r8
   f68e5:	cmp    r8,0x1
   f68e9:	jne    f6916 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
   f68eb:	cmp    rbp,0x1
   f68ef:	jne    f6916 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
   f68f1:	lea    r8,[rip+0x43ae90]        # 531788 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x3e0>
   f68f8:	lea    rdi,[rsp+0x98]
   f6900:	mov    rsi,r15
   f6903:	mov    rdx,r13
   f6906:	mov    r14,QWORD PTR [rsp+0x38]
   f690b:	mov    rcx,r14
   f690e:	call   QWORD PTR [rip+0x455374]        # 54bc88 <_DYNAMIC+0x4a0>
   f6914:	jmp    f6939 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x709>
   f6916:	lea    r8,[rip+0x43ae83]        # 5317a0 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x3f8>
   f691d:	lea    rdi,[rsp+0x98]
   f6925:	mov    rsi,r15
   f6928:	mov    rdx,r13
   f692b:	mov    r14,QWORD PTR [rsp+0x38]
   f6930:	mov    rcx,r14
   f6933:	call   QWORD PTR [rip+0x455357]        # 54bc90 <_DYNAMIC+0x4a8>
   f6939:	lea    rdi,[rsp+0xa0]
   f6941:	mov    rsi,QWORD PTR [rsp+0xc0]
   f6949:	mov    rdx,QWORD PTR [rsp+0xc8]
   f6951:	movups xmm0,XMMWORD PTR [rsp+0xd0]
   f6959:	movaps xmm2,XMMWORD PTR [rsp+0x80]
   f6961:	movaps xmm3,xmm2
   f6964:	unpckhpd xmm3,xmm2
   f6968:	sub    rsp,0x70
   f696c:	movups XMMWORD PTR [rsp+0x58],xmm0
   f6971:	movzx  eax,BYTE PTR [rsp+0x78]
   f6976:	mov    DWORD PTR [rsp+0x50],eax
   f697a:	movzx  eax,BYTE PTR [rsp+0x98]
   f6982:	mov    DWORD PTR [rsp+0x48],eax
   f6986:	mov    rax,QWORD PTR [rsp+0x80]
   f698e:	mov    QWORD PTR [rsp+0x40],rax
   f6993:	mov    rax,QWORD PTR [rsp+0xe8]
   f699b:	mov    QWORD PTR [rsp+0x38],rax
   f69a0:	mov    rax,QWORD PTR [rsp+0x100]
   f69a8:	mov    QWORD PTR [rsp+0x30],rax
   f69ad:	mov    rax,QWORD PTR [rsp+0xb8]
   f69b5:	mov    QWORD PTR [rsp+0x28],rax
   f69ba:	mov    QWORD PTR [rsp+0x20],r12
   f69bf:	mov    rax,QWORD PTR [rsp+0x88]
   f69c7:	mov    QWORD PTR [rsp+0x18],rax
   f69cc:	mov    rax,QWORD PTR [rsp+0xa0]
   f69d4:	mov    QWORD PTR [rsp+0x10],rax
   f69d9:	mov    QWORD PTR [rsp+0x8],rbp
   f69de:	mov    QWORD PTR [rsp],rbx
   f69e2:	xorps  xmm1,xmm1
   f69e5:	mov    r8,r13
   f69e8:	mov    r9,r14
   f69eb:	mov    rcx,r15
   f69ee:	movsd  xmm0,QWORD PTR [rsp+0x90]
   f69f7:	call   QWORD PTR [rsp+0x108]
   f69fe:	add    rsp,0x70
   f6a02:	jmp    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f6a07:	lea    rax,[r12-0x1]
   f6a0c:	mov    ecx,r12d
   f6a0f:	and    ecx,0x3
   f6a12:	and    r12,0xfffffffffffffffc
   f6a16:	mov    rdx,r14
   f6a19:	shl    rdx,0x4
   f6a1d:	lea    rsi,[rdx+rdx*2]
   f6a21:	shl    rbp,0x4
   f6a25:	mov    rdi,r14
   f6a28:	shl    rdi,0x6
   f6a2c:	shl    r14,0x5
   f6a30:	xor    r8d,r8d
   f6a33:	xorps  xmm0,xmm0
   f6a36:	jmp    f6a4f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x81f>
   f6a38:	nop    DWORD PTR [rax+rax*1+0x0]
   f6a40:	inc    r8
   f6a43:	add    rbx,rbp
   f6a46:	cmp    r8,r15
   f6a49:	je     f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f6a4f:	cmp    rax,0x3
   f6a53:	jae    f6a60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
   f6a55:	xor    r9d,r9d
   f6a58:	jmp    f6a94 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x864>
   f6a5a:	nop    WORD PTR [rax+rax*1+0x0]
   f6a60:	mov    r10,rbx
   f6a63:	xor    r9d,r9d
   f6a66:	cs nop WORD PTR [rax+rax*1+0x0]
   f6a70:	movups XMMWORD PTR [r10],xmm0
   f6a74:	movups XMMWORD PTR [r10+rdx*1],xmm0
   f6a79:	movups XMMWORD PTR [r10+r14*1],xmm0
   f6a7e:	add    r9,0x4
   f6a82:	movups XMMWORD PTR [r10+rsi*1],xmm0
   f6a87:	add    r10,rdi
   f6a8a:	cmp    r12,r9
   f6a8d:	jne    f6a70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
   f6a8f:	test   rcx,rcx
   f6a92:	je     f6a40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
   f6a94:	imul   r9,rdx
   f6a98:	add    r9,rbx
   f6a9b:	mov    r10,rcx
   f6a9e:	xchg   ax,ax
   f6aa0:	movups XMMWORD PTR [r9],xmm0
   f6aa4:	add    r9,rdx
   f6aa7:	dec    r10
   f6aaa:	jne    f6aa0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
   f6aac:	jmp    f6a40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
   f6aae:	mov    rax,r12
   f6ab1:	jmp    f6c20 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9f0>
   f6ab6:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff4911a]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
   f6abe:	mov    rax,QWORD PTR [rsp+0x168]
   f6ac6:	xor    r11d,r11d
   f6ac9:	test   rax,rax
   f6acc:	setne  al
   f6acf:	cmp    rbp,r14
   f6ad2:	jge    f6af5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c5>
   f6ad4:	mov    ecx,DWORD PTR [rsp+0x28]
   f6ad8:	mov    BYTE PTR [rsp+0x78],cl
   f6adc:	mov    r10,QWORD PTR [rsp+0x70]
   f6ae1:	mov    rdx,QWORD PTR [rsp+0x48]
   f6ae6:	mov    r9,QWORD PTR [rsp+0x18]
   f6aeb:	mov    r13,r14
   f6aee:	mov    QWORD PTR [rsp+0x10],r15
   f6af3:	jmp    f6b32 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x902>
   f6af5:	mov    BYTE PTR [rsp+0x78],sil
   f6afa:	mov    r10,r8
   f6afd:	mov    rdx,QWORD PTR [rsp+0x40]
   f6b02:	mov    r9,QWORD PTR [rsp+0x8]
   f6b07:	mov    r13,rbp
   f6b0a:	mov    QWORD PTR [rsp+0x10],r12
   f6b0f:	mov    esi,DWORD PTR [rsp+0x28]
   f6b13:	mov    r8,QWORD PTR [rsp+0x70]
   f6b18:	mov    rcx,QWORD PTR [rsp+0x48]
   f6b1d:	mov    QWORD PTR [rsp+0x40],rcx
   f6b22:	mov    rcx,QWORD PTR [rsp+0x18]
   f6b27:	mov    QWORD PTR [rsp+0x8],rcx
   f6b2c:	mov    rbp,r14
   f6b2f:	mov    r12,r15
   f6b32:	test   rbp,rbp
   f6b35:	js     f6cc1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
   f6b3b:	test   r13,r13
   f6b3e:	js     f6ce0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab0>
   f6b44:	mov    r11b,al
   f6b47:	test   rdx,rdx
   f6b4a:	mov    QWORD PTR [rsp+0x70],r13
   f6b4f:	js     f6d06 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad6>
   f6b55:	mov    r13,r11
   f6b58:	mov    QWORD PTR [rsp+0x48],r10
   f6b5d:	mov    QWORD PTR [rsp+0x28],r9
   f6b62:	mov    QWORD PTR [rsp+0x18],rdx
   f6b67:	mov    QWORD PTR [rsp+0x30],r8
   f6b6c:	mov    r15,QWORD PTR [rsp+0x38]
   f6b71:	mov    rax,QWORD PTR [rip+0x455120]        # 54bc98 <_DYNAMIC+0x4b0>
   f6b78:	mov    rax,QWORD PTR [rax]
   f6b7b:	test   rax,rax
   f6b7e:	jne    f6bb2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x982>
   f6b80:	mov    r14d,esi
   f6b83:	movaps XMMWORD PTR [rsp+0x80],xmm2
   f6b8b:	movsd  QWORD PTR [rsp+0x90],xmm0
   f6b94:	call   QWORD PTR [rip+0x455106]        # 54bca0 <_DYNAMIC+0x4b8>
   f6b9a:	movsd  xmm0,QWORD PTR [rsp+0x90]
   f6ba3:	movaps xmm2,XMMWORD PTR [rsp+0x80]
   f6bab:	mov    edi,DWORD PTR [rsp+0x20]
   f6baf:	mov    esi,r14d
   f6bb2:	movaps xmm3,xmm2
   f6bb5:	unpckhpd xmm3,xmm2
   f6bb9:	movzx  r11d,sil
   f6bbd:	movzx  r14d,BYTE PTR [rsp+0x78]
   f6bc3:	movzx  r10d,dil
   f6bc7:	xorps  xmm1,xmm1
   f6bca:	mov    rdi,QWORD PTR [rsp+0x10]
   f6bcf:	mov    rsi,r12
   f6bd2:	mov    rdx,r15
   f6bd5:	mov    rcx,rbx
   f6bd8:	mov    r8,QWORD PTR [rsp+0x70]
   f6bdd:	mov    r9,rbp
   f6be0:	push   QWORD PTR [rsp+0x168]
   f6be7:	push   r13
   f6be9:	push   r11
   f6beb:	push   r14
   f6bed:	push   0x0
   f6bef:	push   QWORD PTR [rsp+0x68]
   f6bf3:	push   QWORD PTR [rsp+0x60]
   f6bf7:	push   QWORD PTR [rsp+0x40]
   f6bfb:	push   QWORD PTR [rsp+0x88]
   f6c02:	push   QWORD PTR [rsp+0x60]
   f6c06:	push   QWORD PTR [rsp+0x78]
   f6c0a:	push   r10
   f6c0c:	call   rax
   f6c0e:	add    rsp,0x60
   f6c12:	jmp    f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f6c17:	mov    rax,r15
   f6c1a:	mov    r15,r12
   f6c1d:	mov    rbp,r14
   f6c20:	mov    ecx,0x1
   f6c25:	sub    rcx,rax
   f6c28:	shl    rcx,0x4
   f6c2c:	add    rbx,rcx
   f6c2f:	lea    rcx,[rax-0x1]
   f6c33:	mov    edx,eax
   f6c35:	and    edx,0x3
   f6c38:	and    rax,0xfffffffffffffffc
   f6c3c:	xor    esi,esi
   f6c3e:	xorps  xmm0,xmm0
   f6c41:	jmp    f6c5c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa2c>
   f6c43:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
   f6c50:	inc    rsi
   f6c53:	cmp    rsi,r15
   f6c56:	je     f6edb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
   f6c5c:	mov    rdi,rsi
   f6c5f:	imul   rdi,rbp
   f6c63:	shl    rdi,0x4
   f6c67:	add    rdi,rbx
   f6c6a:	cmp    rcx,0x3
   f6c6e:	jb     f6ca1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa71>
   f6c70:	xor    r8d,r8d
   f6c73:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
   f6c80:	movups XMMWORD PTR [rdi],xmm0
   f6c83:	movups XMMWORD PTR [rdi+0x10],xmm0
   f6c87:	movups XMMWORD PTR [rdi+0x20],xmm0
   f6c8b:	movups XMMWORD PTR [rdi+0x30],xmm0
   f6c8f:	add    rdi,0x40
   f6c93:	add    r8,0x4
   f6c97:	cmp    rax,r8
   f6c9a:	jne    f6c80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa50>
   f6c9c:	test   rdx,rdx
   f6c9f:	je     f6c50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
   f6ca1:	xor    r8d,r8d
   f6ca4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
   f6cb0:	movups XMMWORD PTR [rdi],xmm0
   f6cb3:	add    rdi,0x10
   f6cb7:	inc    r8
   f6cba:	cmp    rdx,r8
   f6cbd:	jne    f6cb0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa80>
   f6cbf:	jmp    f6c50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
   f6cc1:	mov    rcx,QWORD PTR [rsp+0x10]
   f6cc6:	dec    rcx
   f6cc9:	imul   rcx,r10
   f6ccd:	shl    rcx,0x4
   f6cd1:	add    r9,rcx
   f6cd4:	neg    r10
   f6cd7:	test   r13,r13
   f6cda:	jns    f6b44 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x914>
   f6ce0:	lea    rcx,[r12-0x1]
   f6ce5:	imul   rcx,r8
   f6ce9:	shl    rcx,0x4
   f6ced:	add    QWORD PTR [rsp+0x8],rcx
   f6cf2:	neg    r8
   f6cf5:	mov    r11b,al
   f6cf8:	test   rdx,rdx
   f6cfb:	mov    QWORD PTR [rsp+0x70],r13
   f6d00:	jns    f6b55 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
   f6d06:	mov    rax,QWORD PTR [rsp+0x38]
   f6d0b:	dec    rax
   f6d0e:	mov    rcx,rdx
   f6d11:	imul   rcx,rax
   f6d15:	shl    rcx,0x4
   f6d19:	add    r9,rcx
   f6d1c:	neg    rdx
   f6d1f:	mov    rcx,QWORD PTR [rsp+0x40]
   f6d24:	imul   rax,rcx
   f6d28:	shl    rax,0x4
   f6d2c:	add    QWORD PTR [rsp+0x8],rax
   f6d31:	neg    rcx
   f6d34:	mov    QWORD PTR [rsp+0x40],rcx
   f6d39:	jmp    f6b55 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
   f6d3e:	mov    rax,0xffffffffffffffff
   f6d45:	jmp    f67b6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x586>
   f6d4a:	movaps XMMWORD PTR [rsp+0x80],xmm2
   f6d52:	call   QWORD PTR [rip+0x454f50]        # 54bca8 <_DYNAMIC+0x4c0>
   f6d58:	mov    rdx,QWORD PTR [rip+0x454f21]        # 54bc80 <_DYNAMIC+0x498>
   f6d5f:	movaps xmm2,XMMWORD PTR [rsp+0x80]
   f6d67:	mov    r8,QWORD PTR [rsp+0x30]
   f6d6c:	mov    edi,DWORD PTR [rsp+0x20]
   f6d70:	mov    esi,DWORD PTR [rsp+0x10]
   f6d74:	mov    cl,0x1
   f6d76:	test   eax,0x80000
   f6d7b:	je     f67f5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5c5>
   f6d81:	jmp    f6deb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
   f6d83:	movaps XMMWORD PTR [rsp+0x80],xmm2
   f6d8b:	call   QWORD PTR [rip+0x454f17]        # 54bca8 <_DYNAMIC+0x4c0>
   f6d91:	mov    rdx,QWORD PTR [rip+0x454ee8]        # 54bc80 <_DYNAMIC+0x498>
   f6d98:	movaps xmm2,XMMWORD PTR [rsp+0x80]
   f6da0:	mov    r8,QWORD PTR [rsp+0x30]
   f6da5:	mov    edi,DWORD PTR [rsp+0x20]
   f6da9:	mov    esi,DWORD PTR [rsp+0x10]
   f6dad:	test   ax,ax
   f6db0:	js     f6806 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5d6>
   f6db6:	jmp    f681d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
   f6dbb:	movaps XMMWORD PTR [rsp+0x80],xmm2
   f6dc3:	call   QWORD PTR [rip+0x454edf]        # 54bca8 <_DYNAMIC+0x4c0>
   f6dc9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
   f6dd1:	mov    r8,QWORD PTR [rsp+0x30]
   f6dd6:	mov    edi,DWORD PTR [rsp+0x20]
   f6dda:	mov    esi,DWORD PTR [rsp+0x10]
   f6dde:	bt     rax,0x37
   f6de3:	jae    f681d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
   f6de9:	xor    ecx,ecx
   f6deb:	mov    r9,QWORD PTR [rsp+0x38]
   f6df0:	imul   r13,r9
   f6df4:	mov    rdx,QWORD PTR [rsp+0x168]
   f6dfc:	cmp    rdx,0x1
   f6e00:	adc    rdx,0x0
   f6e04:	cmp    r13,0x10000
   f6e0b:	mov    eax,0x1
   f6e10:	cmovae rax,rdx
   f6e14:	sub    rsp,0xa0
   f6e1b:	lea    rdx,[rsp+0xf0]
   f6e23:	mov    QWORD PTR [rsp+0x88],rdx
   f6e2b:	movzx  edx,BYTE PTR [rsp+0xc8]
   f6e33:	mov    DWORD PTR [rsp+0x80],edx
   f6e3a:	mov    rdx,QWORD PTR [rsp+0x110]
   f6e42:	mov    QWORD PTR [rsp+0x78],rdx
   f6e47:	mov    rdx,QWORD PTR [rsp+0xe8]
   f6e4f:	mov    QWORD PTR [rsp+0x70],rdx
   f6e54:	mov    rdx,QWORD PTR [rsp+0xb8]
   f6e5c:	mov    QWORD PTR [rsp+0x68],rdx
   f6e61:	xorps  xmm0,xmm0
   f6e64:	movups XMMWORD PTR [rsp+0x58],xmm0
   f6e69:	movzx  edx,sil
   f6e6d:	mov    DWORD PTR [rsp+0x50],edx
   f6e71:	mov    rdx,QWORD PTR [rsp+0xe0]
   f6e79:	mov    QWORD PTR [rsp+0x48],rdx
   f6e7e:	mov    QWORD PTR [rsp+0x40],r8
   f6e83:	mov    rdx,QWORD PTR [rsp+0xa8]
   f6e8b:	mov    QWORD PTR [rsp+0x38],rdx
   f6e90:	movzx  edx,dil
   f6e94:	mov    DWORD PTR [rsp+0x30],edx
   f6e98:	movups XMMWORD PTR [rsp+0x18],xmm0
   f6e9d:	mov    QWORD PTR [rsp+0x10],rbp
   f6ea2:	mov    QWORD PTR [rsp+0x8],r14
   f6ea7:	mov    QWORD PTR [rsp],rbx
   f6eab:	mov    QWORD PTR [rsp+0x90],rax
   f6eb3:	mov    DWORD PTR [rsp+0x28],0x2
   f6ebb:	movzx  edx,cl
   f6ebe:	mov    r8,r15
   f6ec1:	mov    edi,0x3
   f6ec6:	mov    esi,0x1
   f6ecb:	mov    rcx,r12
   f6ece:	call   QWORD PTR [rip+0x454ddc]        # 54bcb0 <_DYNAMIC+0x4c8>
   f6ed4:	add    rsp,0xa0
   f6edb:	add    rsp,0x128
   f6ee2:	pop    rbx
   f6ee3:	pop    r12
   f6ee5:	pop    r13
   f6ee7:	pop    r14
   f6ee9:	pop    r15
   f6eeb:	pop    rbp
   f6eec:	ret
