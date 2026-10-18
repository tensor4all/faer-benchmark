
target/faer-rev/f013756c7421-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002154e0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  2154e0:	push   rbp
  2154e1:	push   r15
  2154e3:	push   r14
  2154e5:	push   r13
  2154e7:	push   r12
  2154e9:	push   rbx
  2154ea:	sub    rsp,0x108
  2154f1:	mov    r12,QWORD PTR [rdi+0x8]
  2154f5:	test   r12,r12
  2154f8:	je     216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  2154fe:	mov    rbx,QWORD PTR [rdi+0x10]
  215502:	test   rbx,rbx
  215505:	je     216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  21550b:	mov    r10d,r9d
  21550e:	mov    r14,QWORD PTR [rdi]
  215511:	mov    r9,QWORD PTR [rdi+0x18]
  215515:	mov    r15,QWORD PTR [rdi+0x20]
  215519:	mov    rax,QWORD PTR [rdx+0x10]
  21551d:	test   rax,rax
  215520:	je     2155b8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd8>
  215526:	mov    rdi,QWORD PTR [rdx]
  215529:	mov    rbp,QWORD PTR [rdx+0x8]
  21552d:	mov    r13,QWORD PTR [rdx+0x18]
  215531:	test   r9,r9
  215534:	mov    QWORD PTR [rsp+0x10],rax
  215539:	mov    QWORD PTR [rsp+0x28],rbp
  21553e:	mov    DWORD PTR [rsp+0x4],r10d
  215543:	mov    DWORD PTR [rsp+0x20],ecx
  215547:	jns    21557f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9f>
  215549:	lea    rax,[r12-0x1]
  21554e:	imul   rax,r9
  215552:	neg    r9
  215555:	xor    r11d,r11d
  215558:	mov    r10,rdi
  21555b:	mov    rdi,rbp
  21555e:	sub    rdi,0x1
  215562:	cmovb  rdi,r11
  215566:	lea    r14,[r14+rax*8]
  21556a:	mov    rax,r13
  21556d:	imul   rax,rdi
  215571:	cmp    rdi,rbp
  215574:	cmove  rax,r11
  215578:	lea    rdi,[r10+rax*8]
  21557c:	neg    r13
  21557f:	mov    QWORD PTR [rsp+0x68],r13
  215584:	mov    r11,QWORD PTR [rdx+0x20]
  215588:	mov    r13,QWORD PTR [r8]
  21558b:	mov    r10,QWORD PTR [r8+0x8]
  21558f:	mov    rcx,QWORD PTR [r8+0x10]
  215593:	mov    rbp,QWORD PTR [r8+0x20]
  215597:	test   r15,r15
  21559a:	mov    QWORD PTR [rsp+0x18],r10
  21559f:	js     215607 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x127>
  2155a1:	mov    rax,QWORD PTR [r8+0x18]
  2155a5:	test   r11,r11
  2155a8:	js     215664 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x184>
  2155ae:	mov    QWORD PTR [rsp+0x8],r11
  2155b3:	jmp    2156ba <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1da>
  2155b8:	test   sil,sil
  2155bb:	jne    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  2155c1:	cmp    r12,0x1
  2155c5:	je     2155db <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfb>
  2155c7:	cmp    r9,0xffffffffffffffff
  2155cb:	je     215ce4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x804>
  2155d1:	cmp    r9,0x1
  2155d5:	je     215adb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5fb>
  2155db:	cmp    rbx,0x1
  2155df:	je     215ad1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5f1>
  2155e5:	cmp    r15,0xffffffffffffffff
  2155e9:	je     215d44 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x864>
  2155ef:	cmp    r15,0x1
  2155f3:	jne    215ad1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5f1>
  2155f9:	mov    rax,rbx
  2155fc:	mov    rbx,r12
  2155ff:	mov    r15,r9
  215602:	jmp    215d59 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x879>
  215607:	lea    rdx,[rbx-0x1]
  21560b:	imul   rdx,r15
  21560f:	lea    r14,[r14+rdx*8]
  215613:	neg    r15
  215616:	xor    edx,edx
  215618:	mov    r10,r11
  21561b:	mov    r11,r13
  21561e:	mov    r13,rcx
  215621:	sub    r13,0x1
  215625:	cmovb  r13,rdx
  215629:	mov    rax,rdi
  21562c:	mov    rdi,rbp
  21562f:	imul   rdi,r13
  215633:	cmp    r13,rcx
  215636:	mov    r13,r11
  215639:	mov    r11,r10
  21563c:	mov    r10,QWORD PTR [rsp+0x18]
  215641:	cmove  rdi,rdx
  215645:	test   r10,r10
  215648:	cmove  rdi,r10
  21564c:	lea    r13,[r13+rdi*8+0x0]
  215651:	mov    rdi,rax
  215654:	neg    rbp
  215657:	mov    rax,QWORD PTR [r8+0x18]
  21565b:	test   r11,r11
  21565e:	jns    2155ae <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xce>
  215664:	mov    rdx,QWORD PTR [rsp+0x10]
  215669:	dec    rdx
  21566c:	imul   rdx,r11
  215670:	mov    r8,QWORD PTR [rsp+0x28]
  215675:	test   r8,r8
  215678:	cmove  rdx,r8
  21567c:	lea    rdi,[rdi+rdx*8]
  215680:	neg    r11
  215683:	mov    QWORD PTR [rsp+0x8],r11
  215688:	xor    edx,edx
  21568a:	mov    r8,r13
  21568d:	mov    r13,r10
  215690:	sub    r13,0x1
  215694:	cmovb  r13,rdx
  215698:	mov    r11,rdi
  21569b:	mov    rdi,rax
  21569e:	imul   rdi,r13
  2156a2:	test   rcx,rcx
  2156a5:	cmove  rdi,rcx
  2156a9:	cmp    r13,r10
  2156ac:	cmove  rdi,rdx
  2156b0:	lea    r13,[r8+rdi*8]
  2156b4:	mov    rdi,r11
  2156b7:	neg    rax
  2156ba:	mov    r10,QWORD PTR [rsp+0x148]
  2156c2:	mov    r11,QWORD PTR [rsp+0x140]
  2156ca:	cmp    rbx,0x1
  2156ce:	mov    r8,QWORD PTR [rsp+0x68]
  2156d3:	jne    2157cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  2156d9:	cmp    r8,0x1
  2156dd:	jne    215758 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  2156df:	cmp    r9,0x1
  2156e3:	jne    215758 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  2156e5:	test   r14,r14
  2156e8:	je     215758 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  2156ea:	mov    QWORD PTR [rsp+0x78],rdi
  2156ef:	mov    rcx,QWORD PTR [rsp+0x28]
  2156f4:	mov    QWORD PTR [rsp+0x80],rcx
  2156fc:	mov    rcx,rax
  2156ff:	mov    rax,QWORD PTR [rsp+0x10]
  215704:	mov    QWORD PTR [rsp+0x88],rax
  21570c:	mov    rax,QWORD PTR [rsp+0x8]
  215711:	mov    QWORD PTR [rsp+0x90],rax
  215719:	mov    QWORD PTR [rsp+0x40],r13
  21571e:	mov    rax,QWORD PTR [rsp+0x18]
  215723:	mov    QWORD PTR [rsp+0x48],rax
  215728:	mov    QWORD PTR [rsp+0x50],rcx
  21572d:	sub    rsp,0x8
  215731:	movzx  eax,BYTE PTR [rsp+0xc]
  215736:	movzx  edx,sil
  21573a:	movzx  r8d,BYTE PTR [rsp+0x28]
  215740:	lea    rcx,[rsp+0x80]
  215748:	lea    r9,[rsp+0x48]
  21574d:	mov    rdi,r14
  215750:	mov    rsi,r12
  215753:	jmp    21584d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x36d>
  215758:	cmp    QWORD PTR [rsp+0x8],0x1
  21575e:	jne    2157cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  215760:	cmp    rax,0x1
  215764:	jne    2157cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  215766:	test   r13,r13
  215769:	je     2157cd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  21576b:	mov    QWORD PTR [rsp+0x78],rdi
  215770:	mov    rax,QWORD PTR [rsp+0x28]
  215775:	mov    QWORD PTR [rsp+0x80],rax
  21577d:	mov    rax,QWORD PTR [rsp+0x10]
  215782:	mov    QWORD PTR [rsp+0x88],rax
  21578a:	mov    QWORD PTR [rsp+0x90],r8
  215792:	mov    QWORD PTR [rsp+0x40],r14
  215797:	mov    QWORD PTR [rsp+0x48],r12
  21579c:	mov    QWORD PTR [rsp+0x50],r9
  2157a1:	sub    rsp,0x8
  2157a5:	movzx  eax,BYTE PTR [rsp+0xc]
  2157aa:	movzx  esi,sil
  2157ae:	movzx  ecx,BYTE PTR [rsp+0x28]
  2157b3:	lea    rdi,[rsp+0x48]
  2157b8:	lea    rdx,[rsp+0x80]
  2157c0:	mov    r8,r13
  2157c3:	mov    r9,QWORD PTR [rsp+0x20]
  2157c8:	jmp    2158cf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3ef>
  2157cd:	cmp    r12,0x1
  2157d1:	jne    2158e2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  2157d7:	xor    edx,edx
  2157d9:	cmp    r15,0x1
  2157dd:	cmove  rdx,r14
  2157e1:	cmp    rbp,0x1
  2157e5:	jne    215860 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x380>
  2157e7:	test   rdx,rdx
  2157ea:	je     215860 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x380>
  2157ec:	mov    QWORD PTR [rsp+0x78],r13
  2157f1:	mov    QWORD PTR [rsp+0x80],rcx
  2157f9:	mov    rcx,QWORD PTR [rsp+0x18]
  2157fe:	mov    QWORD PTR [rsp+0x88],rcx
  215806:	mov    QWORD PTR [rsp+0x90],rax
  21580e:	mov    QWORD PTR [rsp+0x40],rdi
  215813:	mov    rax,QWORD PTR [rsp+0x10]
  215818:	mov    QWORD PTR [rsp+0x48],rax
  21581d:	mov    rax,QWORD PTR [rsp+0x8]
  215822:	mov    QWORD PTR [rsp+0x50],rax
  215827:	sub    rsp,0x8
  21582b:	movzx  eax,BYTE PTR [rsp+0x28]
  215830:	movzx  edx,sil
  215834:	movzx  r8d,BYTE PTR [rsp+0xc]
  21583a:	lea    rcx,[rsp+0x80]
  215842:	lea    r9,[rsp+0x48]
  215847:	mov    rdi,r14
  21584a:	mov    rsi,rbx
  21584d:	push   r10
  21584f:	push   r11
  215851:	push   rax
  215852:	call   14bb70 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  215857:	add    rsp,0x20
  21585b:	jmp    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215860:	xor    edx,edx
  215862:	cmp    QWORD PTR [rsp+0x8],0x1
  215868:	cmove  rdx,rdi
  21586c:	cmp    rax,0x1
  215870:	jne    2158e2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  215872:	test   rdx,rdx
  215875:	je     2158e2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  215877:	mov    QWORD PTR [rsp+0x78],r13
  21587c:	mov    QWORD PTR [rsp+0x80],rcx
  215884:	mov    rax,QWORD PTR [rsp+0x18]
  215889:	mov    QWORD PTR [rsp+0x88],rax
  215891:	mov    QWORD PTR [rsp+0x90],rbp
  215899:	mov    QWORD PTR [rsp+0x40],r14
  21589e:	mov    QWORD PTR [rsp+0x48],rbx
  2158a3:	mov    QWORD PTR [rsp+0x50],r15
  2158a8:	sub    rsp,0x8
  2158ac:	movzx  eax,BYTE PTR [rsp+0x28]
  2158b1:	movzx  esi,sil
  2158b5:	movzx  ecx,BYTE PTR [rsp+0xc]
  2158ba:	mov    r8,rdi
  2158bd:	lea    rdi,[rsp+0x48]
  2158c2:	lea    rdx,[rsp+0x80]
  2158ca:	mov    r9,QWORD PTR [rsp+0x18]
  2158cf:	push   r10
  2158d1:	push   r11
  2158d3:	push   rax
  2158d4:	call   203000 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  2158d9:	add    rsp,0x20
  2158dd:	jmp    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  2158e2:	mov    r10,QWORD PTR [rsp+0x10]
  2158e7:	cmp    r10,0x1
  2158eb:	jne    2159e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  2158f1:	xor    edx,edx
  2158f3:	cmp    r9,0x1
  2158f7:	cmove  rdx,r14
  2158fb:	cmp    r8,0x1
  2158ff:	jne    215966 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x486>
  215901:	test   rdx,rdx
  215904:	je     215966 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x486>
  215906:	mov    QWORD PTR [rsp+0x78],rdx
  21590b:	mov    QWORD PTR [rsp+0x80],r12
  215913:	mov    QWORD PTR [rsp+0x88],rbx
  21591b:	mov    QWORD PTR [rsp+0x90],r15
  215923:	mov    QWORD PTR [rsp+0x40],r13
  215928:	mov    QWORD PTR [rsp+0x48],rcx
  21592d:	mov    QWORD PTR [rsp+0x50],rbp
  215932:	sub    rsp,0x8
  215936:	movzx  eax,BYTE PTR [rsp+0xc]
  21593b:	movzx  esi,sil
  21593f:	movzx  r8d,BYTE PTR [rsp+0x28]
  215945:	mov    rdx,rdi
  215948:	lea    rdi,[rsp+0x80]
  215950:	lea    r9,[rsp+0x48]
  215955:	mov    rcx,QWORD PTR [rsp+0x30]
  21595a:	push   QWORD PTR [rsp+0x150]
  215961:	push   r11
  215963:	push   rax
  215964:	jmp    2159db <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4fb>
  215966:	xor    edx,edx
  215968:	cmp    r15,0x1
  21596c:	cmove  rdx,r14
  215970:	cmp    rbp,0x1
  215974:	jne    2159e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  215976:	test   rdx,rdx
  215979:	je     2159e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  21597b:	mov    QWORD PTR [rsp+0x78],rdx
  215980:	mov    QWORD PTR [rsp+0x80],rbx
  215988:	mov    QWORD PTR [rsp+0x88],r12
  215990:	mov    QWORD PTR [rsp+0x90],r9
  215998:	mov    QWORD PTR [rsp+0x40],rdi
  21599d:	mov    rax,QWORD PTR [rsp+0x28]
  2159a2:	mov    QWORD PTR [rsp+0x48],rax
  2159a7:	mov    QWORD PTR [rsp+0x50],r8
  2159ac:	sub    rsp,0x8
  2159b0:	movzx  r10d,BYTE PTR [rsp+0x28]
  2159b6:	movzx  esi,sil
  2159ba:	movzx  r8d,BYTE PTR [rsp+0xc]
  2159c0:	lea    rdi,[rsp+0x80]
  2159c8:	lea    r9,[rsp+0x48]
  2159cd:	mov    rdx,r13
  2159d0:	push   QWORD PTR [rsp+0x150]
  2159d7:	push   r11
  2159d9:	push   r10
  2159db:	call   1499f0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  2159e0:	add    rsp,0x20
  2159e4:	jmp    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  2159e9:	mov    QWORD PTR [rsp+0x18],rax
  2159ee:	movsd  xmm1,QWORD PTR [r11]
  2159f3:	movsd  QWORD PTR [rsp+0x40],xmm1
  2159f9:	mov    rax,r12
  2159fc:	mul    rbx
  2159ff:	mov    QWORD PTR [rsp+0x28],rax
  215a04:	jo     215e01 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x921>
  215a0a:	mul    r10
  215a0d:	seto   cl
  215a10:	not    cl
  215a12:	cmp    rax,0x1001
  215a18:	setb   al
  215a1b:	test   cl,al
  215a1d:	mov    r11,QWORD PTR [rsp+0x8]
  215a22:	jne    215a7d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  215a24:	mov    rdx,QWORD PTR [rip+0x33648d]        # 54beb8 <_DYNAMIC+0x450>
  215a2b:	mov    rax,QWORD PTR [rdx]
  215a2e:	test   rax,rax
  215a31:	je     215e0d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x92d>
  215a37:	mov    cl,0x1
  215a39:	test   eax,0x80000
  215a3e:	jne    215f23 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa43>
  215a44:	mov    rax,QWORD PTR [rdx]
  215a47:	test   rax,rax
  215a4a:	je     215e6f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x98f>
  215a50:	test   ax,ax
  215a53:	jns    215a6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215a55:	mov    rax,QWORD PTR [rdx]
  215a58:	test   rax,rax
  215a5b:	je     215ecd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9ed>
  215a61:	bt     rax,0x37
  215a66:	jb     215f21 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa41>
  215a6c:	test   sil,sil
  215a6f:	jne    215ce9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x809>
  215a75:	xorps  xmm0,xmm0
  215a78:	jmp    215cf1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  215a7d:	test   sil,sil
  215a80:	mov    ecx,DWORD PTR [rsp+0x20]
  215a84:	jne    215ae3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x603>
  215a86:	xorps  xmm0,xmm0
  215a89:	movsd  QWORD PTR [rsp+0x28],xmm0
  215a8f:	cmp    r15,r9
  215a92:	jb     215af6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x616>
  215a94:	mov    eax,DWORD PTR [rsp+0x4]
  215a98:	mov    BYTE PTR [rsp+0x38],al
  215a9c:	mov    eax,ecx
  215a9e:	mov    DWORD PTR [rsp+0x4],eax
  215aa2:	mov    QWORD PTR [rsp+0x20],rbp
  215aa7:	mov    rax,QWORD PTR [rsp+0x18]
  215aac:	mov    QWORD PTR [rsp+0x30],rax
  215ab1:	mov    QWORD PTR [rsp+0x70],r13
  215ab6:	mov    QWORD PTR [rsp+0x18],r11
  215abb:	mov    rax,r8
  215abe:	mov    r13,rdi
  215ac1:	mov    QWORD PTR [rsp+0x8],r15
  215ac6:	mov    r15,r9
  215ac9:	mov    rbp,rbx
  215acc:	mov    rbx,r12
  215acf:	jmp    215b14 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x634>
  215ad1:	cmp    r9,0x1
  215ad5:	jne    215c2e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x74e>
  215adb:	mov    rax,r12
  215ade:	jmp    215d59 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x879>
  215ae3:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2a0ed]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  215aeb:	movsd  QWORD PTR [rsp+0x28],xmm0
  215af1:	cmp    r15,r9
  215af4:	jae    215a94 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b4>
  215af6:	mov    BYTE PTR [rsp+0x38],cl
  215afa:	mov    QWORD PTR [rsp+0x20],r8
  215aff:	mov    QWORD PTR [rsp+0x30],r11
  215b04:	mov    QWORD PTR [rsp+0x70],rdi
  215b09:	mov    QWORD PTR [rsp+0x8],r9
  215b0e:	mov    rax,rbp
  215b11:	mov    rbp,r12
  215b14:	movsd  QWORD PTR [rsp+0x58],xmm1
  215b1a:	mov    QWORD PTR [rsp+0x60],r13
  215b1f:	mov    r13,rax
  215b22:	cmp    rax,0x1
  215b26:	jne    215b4e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66e>
  215b28:	cmp    r15,0x1
  215b2c:	jne    215b4e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66e>
  215b2e:	lea    r8,[rip+0x32b10b]        # 540c40 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x410>
  215b35:	lea    rdi,[rsp+0x78]
  215b3a:	mov    rsi,rbx
  215b3d:	mov    rdx,rbp
  215b40:	mov    rcx,r10
  215b43:	mov    r12,r10
  215b46:	call   QWORD PTR [rip+0x33667c]        # 54c1c8 <_DYNAMIC+0x760>
  215b4c:	jmp    215b6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x68c>
  215b4e:	lea    r8,[rip+0x32b103]        # 540c58 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x428>
  215b55:	lea    rdi,[rsp+0x78]
  215b5a:	mov    rsi,rbx
  215b5d:	mov    rdx,rbp
  215b60:	mov    rcx,r10
  215b63:	mov    r12,r10
  215b66:	call   QWORD PTR [rip+0x336664]        # 54c1d0 <_DYNAMIC+0x768>
  215b6c:	lea    rdi,[rsp+0x80]
  215b74:	mov    rsi,QWORD PTR [rsp+0xa0]
  215b7c:	mov    rdx,QWORD PTR [rsp+0xa8]
  215b84:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  215b8c:	sub    rsp,0x70
  215b90:	movups XMMWORD PTR [rsp+0x58],xmm0
  215b95:	movzx  eax,BYTE PTR [rsp+0xa8]
  215b9d:	mov    DWORD PTR [rsp+0x50],eax
  215ba1:	movzx  eax,BYTE PTR [rsp+0x74]
  215ba6:	mov    DWORD PTR [rsp+0x48],eax
  215baa:	mov    rax,QWORD PTR [rsp+0x90]
  215bb2:	mov    QWORD PTR [rsp+0x40],rax
  215bb7:	mov    rax,QWORD PTR [rsp+0xa0]
  215bbf:	mov    QWORD PTR [rsp+0x38],rax
  215bc4:	mov    rax,QWORD PTR [rsp+0xe0]
  215bcc:	mov    QWORD PTR [rsp+0x30],rax
  215bd1:	mov    rax,QWORD PTR [rsp+0x88]
  215bd9:	mov    QWORD PTR [rsp+0x28],rax
  215bde:	mov    QWORD PTR [rsp+0x20],r13
  215be3:	mov    rax,QWORD PTR [rsp+0xd0]
  215beb:	mov    QWORD PTR [rsp+0x18],rax
  215bf0:	mov    rax,QWORD PTR [rsp+0x78]
  215bf5:	mov    QWORD PTR [rsp+0x10],rax
  215bfa:	mov    QWORD PTR [rsp+0x8],r15
  215bff:	mov    QWORD PTR [rsp],r14
  215c03:	mov    r8,rbp
  215c06:	mov    r9,r12
  215c09:	mov    rcx,rbx
  215c0c:	movsd  xmm0,QWORD PTR [rsp+0x98]
  215c15:	movsd  xmm1,QWORD PTR [rsp+0xc8]
  215c1e:	call   QWORD PTR [rsp+0xe8]
  215c25:	add    rsp,0x70
  215c29:	jmp    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215c2e:	lea    rax,[r12-0x1]
  215c33:	mov    ecx,r12d
  215c36:	and    ecx,0x3
  215c39:	and    r12,0xfffffffffffffffc
  215c3d:	lea    rdx,[r9*8+0x0]
  215c45:	lea    rsi,[rdx+rdx*2]
  215c49:	shl    r15,0x3
  215c4d:	mov    rdi,r9
  215c50:	shl    rdi,0x5
  215c54:	mov    r8,r9
  215c57:	shl    r8,0x4
  215c5b:	xor    r10d,r10d
  215c5e:	jmp    215c6f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x78f>
  215c60:	inc    r10
  215c63:	add    r14,r15
  215c66:	cmp    r10,rbx
  215c69:	je     216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215c6f:	cmp    rax,0x3
  215c73:	jae    215c80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  215c75:	xor    r11d,r11d
  215c78:	jmp    215cc4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7e4>
  215c7a:	nop    WORD PTR [rax+rax*1+0x0]
  215c80:	mov    r13,r14
  215c83:	xor    r11d,r11d
  215c86:	cs nop WORD PTR [rax+rax*1+0x0]
  215c90:	mov    QWORD PTR [r13+0x0],0x0
  215c98:	mov    QWORD PTR [r13+r9*8+0x0],0x0
  215ca1:	mov    QWORD PTR [r13+r8*1+0x0],0x0
  215caa:	add    r11,0x4
  215cae:	mov    QWORD PTR [r13+rsi*1+0x0],0x0
  215cb7:	add    r13,rdi
  215cba:	cmp    r12,r11
  215cbd:	jne    215c90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7b0>
  215cbf:	test   rcx,rcx
  215cc2:	je     215c60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x780>
  215cc4:	imul   r11,rdx
  215cc8:	add    r11,r14
  215ccb:	mov    r13,rcx
  215cce:	xchg   ax,ax
  215cd0:	mov    QWORD PTR [r11],0x0
  215cd7:	add    r11,rdx
  215cda:	dec    r13
  215cdd:	jne    215cd0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7f0>
  215cdf:	jmp    215c60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x780>
  215ce4:	mov    rax,r12
  215ce7:	jmp    215d4d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x86d>
  215ce9:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe29ee7]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  215cf1:	mov    rax,rdi
  215cf4:	mov    r11,r13
  215cf7:	mov    r13,QWORD PTR [rsp+0x148]
  215cff:	test   r13,r13
  215d02:	je     215dc5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8e5>
  215d08:	sub    rsp,0x8
  215d0c:	movzx  ecx,sil
  215d10:	mov    QWORD PTR [rsp+0x18],rcx
  215d15:	mov    rdi,r12
  215d18:	mov    rsi,rbx
  215d1b:	mov    rdx,r10
  215d1e:	mov    rcx,r14
  215d21:	mov    r8,r15
  215d24:	push   r13
  215d26:	push   0x1
  215d28:	push   QWORD PTR [rsp+0x30]
  215d2c:	push   rbp
  215d2d:	push   r11
  215d2f:	push   QWORD PTR [rsp+0x98]
  215d36:	push   QWORD PTR [rsp+0x40]
  215d3a:	push   rax
  215d3b:	push   QWORD PTR [rsp+0x58]
  215d3f:	jmp    215df3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x913>
  215d44:	mov    rax,rbx
  215d47:	mov    rbx,r12
  215d4a:	mov    r15,r9
  215d4d:	mov    ecx,0x1
  215d52:	sub    rcx,rax
  215d55:	lea    r14,[r14+rcx*8]
  215d59:	lea    rcx,[rax-0x1]
  215d5d:	mov    edx,eax
  215d5f:	and    edx,0x3
  215d62:	and    rax,0xfffffffffffffffc
  215d66:	xor    esi,esi
  215d68:	xorps  xmm0,xmm0
  215d6b:	jmp    215d7c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x89c>
  215d6d:	nop    DWORD PTR [rax]
  215d70:	inc    rsi
  215d73:	cmp    rsi,rbx
  215d76:	je     216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215d7c:	mov    rdi,rsi
  215d7f:	imul   rdi,r15
  215d83:	lea    rdi,[r14+rdi*8]
  215d87:	cmp    rcx,0x3
  215d8b:	jb     215da9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8c9>
  215d8d:	xor    r8d,r8d
  215d90:	movups XMMWORD PTR [rdi],xmm0
  215d93:	movups XMMWORD PTR [rdi+0x10],xmm0
  215d97:	add    rdi,0x20
  215d9b:	add    r8,0x4
  215d9f:	cmp    rax,r8
  215da2:	jne    215d90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  215da4:	test   rdx,rdx
  215da7:	je     215d70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x890>
  215da9:	xor    r8d,r8d
  215dac:	nop    DWORD PTR [rax+0x0]
  215db0:	mov    QWORD PTR [rdi],0x0
  215db7:	add    rdi,0x8
  215dbb:	inc    r8
  215dbe:	cmp    rdx,r8
  215dc1:	jne    215db0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8d0>
  215dc3:	jmp    215d70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x890>
  215dc5:	sub    rsp,0x10
  215dc9:	movzx  r13d,sil
  215dcd:	mov    rdi,r12
  215dd0:	mov    rsi,rbx
  215dd3:	mov    rdx,r10
  215dd6:	mov    rcx,r14
  215dd9:	mov    r8,r15
  215ddc:	push   0x0
  215dde:	push   QWORD PTR [rsp+0x30]
  215de2:	push   rbp
  215de3:	push   r11
  215de5:	push   QWORD PTR [rsp+0x98]
  215dec:	push   QWORD PTR [rsp+0x40]
  215df0:	push   rax
  215df1:	push   r13
  215df3:	call   20b160 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmdECscfHK10Grmvq_6fbench>
  215df8:	add    rsp,0x50
  215dfc:	jmp    216003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215e01:	mov    rax,0xffffffffffffffff
  215e08:	jmp    215a0a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x52a>
  215e0d:	mov    QWORD PTR [rsp+0x38],r9
  215e12:	mov    QWORD PTR [rsp+0x60],r13
  215e17:	mov    DWORD PTR [rsp+0x30],esi
  215e1b:	mov    r13,rbp
  215e1e:	mov    rbp,rdi
  215e21:	movsd  QWORD PTR [rsp+0x58],xmm1
  215e27:	call   QWORD PTR [rip+0x336093]        # 54bec0 <_DYNAMIC+0x458>
  215e2d:	mov    rdx,QWORD PTR [rip+0x336084]        # 54beb8 <_DYNAMIC+0x450>
  215e34:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215e3a:	mov    r11,QWORD PTR [rsp+0x8]
  215e3f:	mov    r8,QWORD PTR [rsp+0x68]
  215e44:	mov    rdi,rbp
  215e47:	mov    rbp,r13
  215e4a:	mov    esi,DWORD PTR [rsp+0x30]
  215e4e:	mov    r13,QWORD PTR [rsp+0x60]
  215e53:	mov    r10,QWORD PTR [rsp+0x10]
  215e58:	mov    r9,QWORD PTR [rsp+0x38]
  215e5d:	mov    cl,0x1
  215e5f:	test   eax,0x80000
  215e64:	je     215a44 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x564>
  215e6a:	jmp    215f23 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa43>
  215e6f:	mov    QWORD PTR [rsp+0x38],r9
  215e74:	mov    QWORD PTR [rsp+0x60],r13
  215e79:	mov    DWORD PTR [rsp+0x30],esi
  215e7d:	mov    r13,rbp
  215e80:	mov    rbp,rdi
  215e83:	movsd  QWORD PTR [rsp+0x58],xmm1
  215e89:	call   QWORD PTR [rip+0x336031]        # 54bec0 <_DYNAMIC+0x458>
  215e8f:	mov    rdx,QWORD PTR [rip+0x336022]        # 54beb8 <_DYNAMIC+0x450>
  215e96:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215e9c:	mov    r11,QWORD PTR [rsp+0x8]
  215ea1:	mov    r8,QWORD PTR [rsp+0x68]
  215ea6:	mov    rdi,rbp
  215ea9:	mov    rbp,r13
  215eac:	mov    esi,DWORD PTR [rsp+0x30]
  215eb0:	mov    r13,QWORD PTR [rsp+0x60]
  215eb5:	mov    r10,QWORD PTR [rsp+0x10]
  215eba:	mov    r9,QWORD PTR [rsp+0x38]
  215ebf:	test   ax,ax
  215ec2:	js     215a55 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x575>
  215ec8:	jmp    215a6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215ecd:	mov    QWORD PTR [rsp+0x38],r9
  215ed2:	mov    QWORD PTR [rsp+0x60],r13
  215ed7:	mov    DWORD PTR [rsp+0x30],esi
  215edb:	mov    r13,rbp
  215ede:	mov    rbp,rdi
  215ee1:	movsd  QWORD PTR [rsp+0x58],xmm1
  215ee7:	call   QWORD PTR [rip+0x335fd3]        # 54bec0 <_DYNAMIC+0x458>
  215eed:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215ef3:	mov    r11,QWORD PTR [rsp+0x8]
  215ef8:	mov    r8,QWORD PTR [rsp+0x68]
  215efd:	mov    rdi,rbp
  215f00:	mov    rbp,r13
  215f03:	mov    esi,DWORD PTR [rsp+0x30]
  215f07:	mov    r13,QWORD PTR [rsp+0x60]
  215f0c:	mov    r10,QWORD PTR [rsp+0x10]
  215f11:	mov    r9,QWORD PTR [rsp+0x38]
  215f16:	bt     rax,0x37
  215f1b:	jae    215a6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215f21:	xor    ecx,ecx
  215f23:	mov    DWORD PTR [rsp+0x10],ecx
  215f27:	mov    rcx,QWORD PTR [rsp+0x28]
  215f2c:	imul   rcx,r10
  215f30:	mov    rdx,QWORD PTR [rsp+0x148]
  215f38:	cmp    rdx,0x1
  215f3c:	adc    rdx,0x0
  215f40:	cmp    rcx,0x8000
  215f47:	mov    eax,0x1
  215f4c:	cmovae rax,rdx
  215f50:	sub    rsp,0xa0
  215f57:	lea    rdx,[rsp+0xe0]
  215f5f:	mov    QWORD PTR [rsp+0x88],rdx
  215f67:	movzx  edx,BYTE PTR [rsp+0xa4]
  215f6f:	mov    DWORD PTR [rsp+0x80],edx
  215f76:	mov    QWORD PTR [rsp+0x78],rbp
  215f7b:	mov    rdx,QWORD PTR [rsp+0xb8]
  215f83:	mov    QWORD PTR [rsp+0x70],rdx
  215f88:	mov    QWORD PTR [rsp+0x68],r13
  215f8d:	xorps  xmm0,xmm0
  215f90:	movups XMMWORD PTR [rsp+0x58],xmm0
  215f95:	movzx  edx,BYTE PTR [rsp+0xc0]
  215f9d:	mov    DWORD PTR [rsp+0x50],edx
  215fa1:	mov    QWORD PTR [rsp+0x48],r11
  215fa6:	mov    QWORD PTR [rsp+0x40],r8
  215fab:	mov    QWORD PTR [rsp+0x38],rdi
  215fb0:	movzx  edx,sil
  215fb4:	mov    DWORD PTR [rsp+0x30],edx
  215fb8:	movups XMMWORD PTR [rsp+0x18],xmm0
  215fbd:	mov    QWORD PTR [rsp+0x10],r15
  215fc2:	mov    QWORD PTR [rsp+0x8],r9
  215fc7:	mov    QWORD PTR [rsp],r14
  215fcb:	mov    QWORD PTR [rsp+0x90],rax
  215fd3:	mov    DWORD PTR [rsp+0x28],0x2
  215fdb:	movzx  edx,BYTE PTR [rsp+0xb0]
  215fe3:	mov    r8,rbx
  215fe6:	mov    edi,0x1
  215feb:	mov    r9,r10
  215fee:	mov    esi,0x1
  215ff3:	mov    rcx,r12
  215ff6:	call   QWORD PTR [rip+0x335ecc]        # 54bec8 <_DYNAMIC+0x460>
  215ffc:	add    rsp,0xa0
  216003:	add    rsp,0x108
  21600a:	pop    rbx
  21600b:	pop    r12
  21600d:	pop    r13
  21600f:	pop    r14
  216011:	pop    r15
  216013:	pop    rbp
  216014:	ret
