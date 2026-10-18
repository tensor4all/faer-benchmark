
target/faer-rev/7cd372f40449-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000215500 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  215500:	push   rbp
  215501:	push   r15
  215503:	push   r14
  215505:	push   r13
  215507:	push   r12
  215509:	push   rbx
  21550a:	sub    rsp,0x108
  215511:	mov    r12,QWORD PTR [rdi+0x8]
  215515:	test   r12,r12
  215518:	je     216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  21551e:	mov    rbx,QWORD PTR [rdi+0x10]
  215522:	test   rbx,rbx
  215525:	je     216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  21552b:	mov    r10d,r9d
  21552e:	mov    r14,QWORD PTR [rdi]
  215531:	mov    r9,QWORD PTR [rdi+0x18]
  215535:	mov    r15,QWORD PTR [rdi+0x20]
  215539:	mov    rax,QWORD PTR [rdx+0x10]
  21553d:	test   rax,rax
  215540:	je     2155d8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd8>
  215546:	mov    rdi,QWORD PTR [rdx]
  215549:	mov    rbp,QWORD PTR [rdx+0x8]
  21554d:	mov    r13,QWORD PTR [rdx+0x18]
  215551:	test   r9,r9
  215554:	mov    QWORD PTR [rsp+0x10],rax
  215559:	mov    QWORD PTR [rsp+0x28],rbp
  21555e:	mov    DWORD PTR [rsp+0x4],r10d
  215563:	mov    DWORD PTR [rsp+0x20],ecx
  215567:	jns    21559f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9f>
  215569:	lea    rax,[r12-0x1]
  21556e:	imul   rax,r9
  215572:	neg    r9
  215575:	xor    r11d,r11d
  215578:	mov    r10,rdi
  21557b:	mov    rdi,rbp
  21557e:	sub    rdi,0x1
  215582:	cmovb  rdi,r11
  215586:	lea    r14,[r14+rax*8]
  21558a:	mov    rax,r13
  21558d:	imul   rax,rdi
  215591:	cmp    rdi,rbp
  215594:	cmove  rax,r11
  215598:	lea    rdi,[r10+rax*8]
  21559c:	neg    r13
  21559f:	mov    QWORD PTR [rsp+0x68],r13
  2155a4:	mov    r11,QWORD PTR [rdx+0x20]
  2155a8:	mov    r13,QWORD PTR [r8]
  2155ab:	mov    r10,QWORD PTR [r8+0x8]
  2155af:	mov    rcx,QWORD PTR [r8+0x10]
  2155b3:	mov    rbp,QWORD PTR [r8+0x20]
  2155b7:	test   r15,r15
  2155ba:	mov    QWORD PTR [rsp+0x18],r10
  2155bf:	js     215627 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x127>
  2155c1:	mov    rax,QWORD PTR [r8+0x18]
  2155c5:	test   r11,r11
  2155c8:	js     215684 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x184>
  2155ce:	mov    QWORD PTR [rsp+0x8],r11
  2155d3:	jmp    2156da <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1da>
  2155d8:	test   sil,sil
  2155db:	jne    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  2155e1:	cmp    r12,0x1
  2155e5:	je     2155fb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfb>
  2155e7:	cmp    r9,0xffffffffffffffff
  2155eb:	je     215d04 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x804>
  2155f1:	cmp    r9,0x1
  2155f5:	je     215afb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5fb>
  2155fb:	cmp    rbx,0x1
  2155ff:	je     215af1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5f1>
  215605:	cmp    r15,0xffffffffffffffff
  215609:	je     215d64 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x864>
  21560f:	cmp    r15,0x1
  215613:	jne    215af1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5f1>
  215619:	mov    rax,rbx
  21561c:	mov    rbx,r12
  21561f:	mov    r15,r9
  215622:	jmp    215d79 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x879>
  215627:	lea    rdx,[rbx-0x1]
  21562b:	imul   rdx,r15
  21562f:	lea    r14,[r14+rdx*8]
  215633:	neg    r15
  215636:	xor    edx,edx
  215638:	mov    r10,r11
  21563b:	mov    r11,r13
  21563e:	mov    r13,rcx
  215641:	sub    r13,0x1
  215645:	cmovb  r13,rdx
  215649:	mov    rax,rdi
  21564c:	mov    rdi,rbp
  21564f:	imul   rdi,r13
  215653:	cmp    r13,rcx
  215656:	mov    r13,r11
  215659:	mov    r11,r10
  21565c:	mov    r10,QWORD PTR [rsp+0x18]
  215661:	cmove  rdi,rdx
  215665:	test   r10,r10
  215668:	cmove  rdi,r10
  21566c:	lea    r13,[r13+rdi*8+0x0]
  215671:	mov    rdi,rax
  215674:	neg    rbp
  215677:	mov    rax,QWORD PTR [r8+0x18]
  21567b:	test   r11,r11
  21567e:	jns    2155ce <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xce>
  215684:	mov    rdx,QWORD PTR [rsp+0x10]
  215689:	dec    rdx
  21568c:	imul   rdx,r11
  215690:	mov    r8,QWORD PTR [rsp+0x28]
  215695:	test   r8,r8
  215698:	cmove  rdx,r8
  21569c:	lea    rdi,[rdi+rdx*8]
  2156a0:	neg    r11
  2156a3:	mov    QWORD PTR [rsp+0x8],r11
  2156a8:	xor    edx,edx
  2156aa:	mov    r8,r13
  2156ad:	mov    r13,r10
  2156b0:	sub    r13,0x1
  2156b4:	cmovb  r13,rdx
  2156b8:	mov    r11,rdi
  2156bb:	mov    rdi,rax
  2156be:	imul   rdi,r13
  2156c2:	test   rcx,rcx
  2156c5:	cmove  rdi,rcx
  2156c9:	cmp    r13,r10
  2156cc:	cmove  rdi,rdx
  2156d0:	lea    r13,[r8+rdi*8]
  2156d4:	mov    rdi,r11
  2156d7:	neg    rax
  2156da:	mov    r10,QWORD PTR [rsp+0x148]
  2156e2:	mov    r11,QWORD PTR [rsp+0x140]
  2156ea:	cmp    rbx,0x1
  2156ee:	mov    r8,QWORD PTR [rsp+0x68]
  2156f3:	jne    2157ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  2156f9:	cmp    r8,0x1
  2156fd:	jne    215778 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  2156ff:	cmp    r9,0x1
  215703:	jne    215778 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  215705:	test   r14,r14
  215708:	je     215778 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x278>
  21570a:	mov    QWORD PTR [rsp+0x78],rdi
  21570f:	mov    rcx,QWORD PTR [rsp+0x28]
  215714:	mov    QWORD PTR [rsp+0x80],rcx
  21571c:	mov    rcx,rax
  21571f:	mov    rax,QWORD PTR [rsp+0x10]
  215724:	mov    QWORD PTR [rsp+0x88],rax
  21572c:	mov    rax,QWORD PTR [rsp+0x8]
  215731:	mov    QWORD PTR [rsp+0x90],rax
  215739:	mov    QWORD PTR [rsp+0x40],r13
  21573e:	mov    rax,QWORD PTR [rsp+0x18]
  215743:	mov    QWORD PTR [rsp+0x48],rax
  215748:	mov    QWORD PTR [rsp+0x50],rcx
  21574d:	sub    rsp,0x8
  215751:	movzx  eax,BYTE PTR [rsp+0xc]
  215756:	movzx  edx,sil
  21575a:	movzx  r8d,BYTE PTR [rsp+0x28]
  215760:	lea    rcx,[rsp+0x80]
  215768:	lea    r9,[rsp+0x48]
  21576d:	mov    rdi,r14
  215770:	mov    rsi,r12
  215773:	jmp    21586d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x36d>
  215778:	cmp    QWORD PTR [rsp+0x8],0x1
  21577e:	jne    2157ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  215780:	cmp    rax,0x1
  215784:	jne    2157ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  215786:	test   r13,r13
  215789:	je     2157ed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2ed>
  21578b:	mov    QWORD PTR [rsp+0x78],rdi
  215790:	mov    rax,QWORD PTR [rsp+0x28]
  215795:	mov    QWORD PTR [rsp+0x80],rax
  21579d:	mov    rax,QWORD PTR [rsp+0x10]
  2157a2:	mov    QWORD PTR [rsp+0x88],rax
  2157aa:	mov    QWORD PTR [rsp+0x90],r8
  2157b2:	mov    QWORD PTR [rsp+0x40],r14
  2157b7:	mov    QWORD PTR [rsp+0x48],r12
  2157bc:	mov    QWORD PTR [rsp+0x50],r9
  2157c1:	sub    rsp,0x8
  2157c5:	movzx  eax,BYTE PTR [rsp+0xc]
  2157ca:	movzx  esi,sil
  2157ce:	movzx  ecx,BYTE PTR [rsp+0x28]
  2157d3:	lea    rdi,[rsp+0x48]
  2157d8:	lea    rdx,[rsp+0x80]
  2157e0:	mov    r8,r13
  2157e3:	mov    r9,QWORD PTR [rsp+0x20]
  2157e8:	jmp    2158ef <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3ef>
  2157ed:	cmp    r12,0x1
  2157f1:	jne    215902 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  2157f7:	xor    edx,edx
  2157f9:	cmp    r15,0x1
  2157fd:	cmove  rdx,r14
  215801:	cmp    rbp,0x1
  215805:	jne    215880 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x380>
  215807:	test   rdx,rdx
  21580a:	je     215880 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x380>
  21580c:	mov    QWORD PTR [rsp+0x78],r13
  215811:	mov    QWORD PTR [rsp+0x80],rcx
  215819:	mov    rcx,QWORD PTR [rsp+0x18]
  21581e:	mov    QWORD PTR [rsp+0x88],rcx
  215826:	mov    QWORD PTR [rsp+0x90],rax
  21582e:	mov    QWORD PTR [rsp+0x40],rdi
  215833:	mov    rax,QWORD PTR [rsp+0x10]
  215838:	mov    QWORD PTR [rsp+0x48],rax
  21583d:	mov    rax,QWORD PTR [rsp+0x8]
  215842:	mov    QWORD PTR [rsp+0x50],rax
  215847:	sub    rsp,0x8
  21584b:	movzx  eax,BYTE PTR [rsp+0x28]
  215850:	movzx  edx,sil
  215854:	movzx  r8d,BYTE PTR [rsp+0xc]
  21585a:	lea    rcx,[rsp+0x80]
  215862:	lea    r9,[rsp+0x48]
  215867:	mov    rdi,r14
  21586a:	mov    rsi,rbx
  21586d:	push   r10
  21586f:	push   r11
  215871:	push   rax
  215872:	call   14bb70 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  215877:	add    rsp,0x20
  21587b:	jmp    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215880:	xor    edx,edx
  215882:	cmp    QWORD PTR [rsp+0x8],0x1
  215888:	cmove  rdx,rdi
  21588c:	cmp    rax,0x1
  215890:	jne    215902 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  215892:	test   rdx,rdx
  215895:	je     215902 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x402>
  215897:	mov    QWORD PTR [rsp+0x78],r13
  21589c:	mov    QWORD PTR [rsp+0x80],rcx
  2158a4:	mov    rax,QWORD PTR [rsp+0x18]
  2158a9:	mov    QWORD PTR [rsp+0x88],rax
  2158b1:	mov    QWORD PTR [rsp+0x90],rbp
  2158b9:	mov    QWORD PTR [rsp+0x40],r14
  2158be:	mov    QWORD PTR [rsp+0x48],rbx
  2158c3:	mov    QWORD PTR [rsp+0x50],r15
  2158c8:	sub    rsp,0x8
  2158cc:	movzx  eax,BYTE PTR [rsp+0x28]
  2158d1:	movzx  esi,sil
  2158d5:	movzx  ecx,BYTE PTR [rsp+0xc]
  2158da:	mov    r8,rdi
  2158dd:	lea    rdi,[rsp+0x48]
  2158e2:	lea    rdx,[rsp+0x80]
  2158ea:	mov    r9,QWORD PTR [rsp+0x18]
  2158ef:	push   r10
  2158f1:	push   r11
  2158f3:	push   rax
  2158f4:	call   203020 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  2158f9:	add    rsp,0x20
  2158fd:	jmp    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215902:	mov    r10,QWORD PTR [rsp+0x10]
  215907:	cmp    r10,0x1
  21590b:	jne    215a09 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  215911:	xor    edx,edx
  215913:	cmp    r9,0x1
  215917:	cmove  rdx,r14
  21591b:	cmp    r8,0x1
  21591f:	jne    215986 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x486>
  215921:	test   rdx,rdx
  215924:	je     215986 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x486>
  215926:	mov    QWORD PTR [rsp+0x78],rdx
  21592b:	mov    QWORD PTR [rsp+0x80],r12
  215933:	mov    QWORD PTR [rsp+0x88],rbx
  21593b:	mov    QWORD PTR [rsp+0x90],r15
  215943:	mov    QWORD PTR [rsp+0x40],r13
  215948:	mov    QWORD PTR [rsp+0x48],rcx
  21594d:	mov    QWORD PTR [rsp+0x50],rbp
  215952:	sub    rsp,0x8
  215956:	movzx  eax,BYTE PTR [rsp+0xc]
  21595b:	movzx  esi,sil
  21595f:	movzx  r8d,BYTE PTR [rsp+0x28]
  215965:	mov    rdx,rdi
  215968:	lea    rdi,[rsp+0x80]
  215970:	lea    r9,[rsp+0x48]
  215975:	mov    rcx,QWORD PTR [rsp+0x30]
  21597a:	push   QWORD PTR [rsp+0x150]
  215981:	push   r11
  215983:	push   rax
  215984:	jmp    2159fb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4fb>
  215986:	xor    edx,edx
  215988:	cmp    r15,0x1
  21598c:	cmove  rdx,r14
  215990:	cmp    rbp,0x1
  215994:	jne    215a09 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  215996:	test   rdx,rdx
  215999:	je     215a09 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x509>
  21599b:	mov    QWORD PTR [rsp+0x78],rdx
  2159a0:	mov    QWORD PTR [rsp+0x80],rbx
  2159a8:	mov    QWORD PTR [rsp+0x88],r12
  2159b0:	mov    QWORD PTR [rsp+0x90],r9
  2159b8:	mov    QWORD PTR [rsp+0x40],rdi
  2159bd:	mov    rax,QWORD PTR [rsp+0x28]
  2159c2:	mov    QWORD PTR [rsp+0x48],rax
  2159c7:	mov    QWORD PTR [rsp+0x50],r8
  2159cc:	sub    rsp,0x8
  2159d0:	movzx  r10d,BYTE PTR [rsp+0x28]
  2159d6:	movzx  esi,sil
  2159da:	movzx  r8d,BYTE PTR [rsp+0xc]
  2159e0:	lea    rdi,[rsp+0x80]
  2159e8:	lea    r9,[rsp+0x48]
  2159ed:	mov    rdx,r13
  2159f0:	push   QWORD PTR [rsp+0x150]
  2159f7:	push   r11
  2159f9:	push   r10
  2159fb:	call   1499f0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  215a00:	add    rsp,0x20
  215a04:	jmp    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215a09:	mov    QWORD PTR [rsp+0x18],rax
  215a0e:	movsd  xmm1,QWORD PTR [r11]
  215a13:	movsd  QWORD PTR [rsp+0x40],xmm1
  215a19:	mov    rax,r12
  215a1c:	mul    rbx
  215a1f:	mov    QWORD PTR [rsp+0x28],rax
  215a24:	jo     215e21 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x921>
  215a2a:	mul    r10
  215a2d:	seto   cl
  215a30:	not    cl
  215a32:	cmp    rax,0x1001
  215a38:	setb   al
  215a3b:	test   cl,al
  215a3d:	mov    r11,QWORD PTR [rsp+0x8]
  215a42:	jne    215a9d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x59d>
  215a44:	mov    rdx,QWORD PTR [rip+0x33646d]        # 54beb8 <_DYNAMIC+0x450>
  215a4b:	mov    rax,QWORD PTR [rdx]
  215a4e:	test   rax,rax
  215a51:	je     215e2d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x92d>
  215a57:	mov    cl,0x1
  215a59:	test   eax,0x80000
  215a5e:	jne    215f43 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa43>
  215a64:	mov    rax,QWORD PTR [rdx]
  215a67:	test   rax,rax
  215a6a:	je     215e8f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x98f>
  215a70:	test   ax,ax
  215a73:	jns    215a8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215a75:	mov    rax,QWORD PTR [rdx]
  215a78:	test   rax,rax
  215a7b:	je     215eed <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9ed>
  215a81:	bt     rax,0x37
  215a86:	jb     215f41 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa41>
  215a8c:	test   sil,sil
  215a8f:	jne    215d09 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x809>
  215a95:	xorps  xmm0,xmm0
  215a98:	jmp    215d11 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  215a9d:	test   sil,sil
  215aa0:	mov    ecx,DWORD PTR [rsp+0x20]
  215aa4:	jne    215b03 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x603>
  215aa6:	xorps  xmm0,xmm0
  215aa9:	movsd  QWORD PTR [rsp+0x28],xmm0
  215aaf:	cmp    r15,r9
  215ab2:	jb     215b16 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x616>
  215ab4:	mov    eax,DWORD PTR [rsp+0x4]
  215ab8:	mov    BYTE PTR [rsp+0x38],al
  215abc:	mov    eax,ecx
  215abe:	mov    DWORD PTR [rsp+0x4],eax
  215ac2:	mov    QWORD PTR [rsp+0x20],rbp
  215ac7:	mov    rax,QWORD PTR [rsp+0x18]
  215acc:	mov    QWORD PTR [rsp+0x30],rax
  215ad1:	mov    QWORD PTR [rsp+0x70],r13
  215ad6:	mov    QWORD PTR [rsp+0x18],r11
  215adb:	mov    rax,r8
  215ade:	mov    r13,rdi
  215ae1:	mov    QWORD PTR [rsp+0x8],r15
  215ae6:	mov    r15,r9
  215ae9:	mov    rbp,rbx
  215aec:	mov    rbx,r12
  215aef:	jmp    215b34 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x634>
  215af1:	cmp    r9,0x1
  215af5:	jne    215c4e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x74e>
  215afb:	mov    rax,r12
  215afe:	jmp    215d79 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x879>
  215b03:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2a0cd]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  215b0b:	movsd  QWORD PTR [rsp+0x28],xmm0
  215b11:	cmp    r15,r9
  215b14:	jae    215ab4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b4>
  215b16:	mov    BYTE PTR [rsp+0x38],cl
  215b1a:	mov    QWORD PTR [rsp+0x20],r8
  215b1f:	mov    QWORD PTR [rsp+0x30],r11
  215b24:	mov    QWORD PTR [rsp+0x70],rdi
  215b29:	mov    QWORD PTR [rsp+0x8],r9
  215b2e:	mov    rax,rbp
  215b31:	mov    rbp,r12
  215b34:	movsd  QWORD PTR [rsp+0x58],xmm1
  215b3a:	mov    QWORD PTR [rsp+0x60],r13
  215b3f:	mov    r13,rax
  215b42:	cmp    rax,0x1
  215b46:	jne    215b6e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66e>
  215b48:	cmp    r15,0x1
  215b4c:	jne    215b6e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66e>
  215b4e:	lea    r8,[rip+0x32b0eb]        # 540c40 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x410>
  215b55:	lea    rdi,[rsp+0x78]
  215b5a:	mov    rsi,rbx
  215b5d:	mov    rdx,rbp
  215b60:	mov    rcx,r10
  215b63:	mov    r12,r10
  215b66:	call   QWORD PTR [rip+0x33665c]        # 54c1c8 <_DYNAMIC+0x760>
  215b6c:	jmp    215b8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x68c>
  215b6e:	lea    r8,[rip+0x32b0e3]        # 540c58 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x428>
  215b75:	lea    rdi,[rsp+0x78]
  215b7a:	mov    rsi,rbx
  215b7d:	mov    rdx,rbp
  215b80:	mov    rcx,r10
  215b83:	mov    r12,r10
  215b86:	call   QWORD PTR [rip+0x336644]        # 54c1d0 <_DYNAMIC+0x768>
  215b8c:	lea    rdi,[rsp+0x80]
  215b94:	mov    rsi,QWORD PTR [rsp+0xa0]
  215b9c:	mov    rdx,QWORD PTR [rsp+0xa8]
  215ba4:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  215bac:	sub    rsp,0x70
  215bb0:	movups XMMWORD PTR [rsp+0x58],xmm0
  215bb5:	movzx  eax,BYTE PTR [rsp+0xa8]
  215bbd:	mov    DWORD PTR [rsp+0x50],eax
  215bc1:	movzx  eax,BYTE PTR [rsp+0x74]
  215bc6:	mov    DWORD PTR [rsp+0x48],eax
  215bca:	mov    rax,QWORD PTR [rsp+0x90]
  215bd2:	mov    QWORD PTR [rsp+0x40],rax
  215bd7:	mov    rax,QWORD PTR [rsp+0xa0]
  215bdf:	mov    QWORD PTR [rsp+0x38],rax
  215be4:	mov    rax,QWORD PTR [rsp+0xe0]
  215bec:	mov    QWORD PTR [rsp+0x30],rax
  215bf1:	mov    rax,QWORD PTR [rsp+0x88]
  215bf9:	mov    QWORD PTR [rsp+0x28],rax
  215bfe:	mov    QWORD PTR [rsp+0x20],r13
  215c03:	mov    rax,QWORD PTR [rsp+0xd0]
  215c0b:	mov    QWORD PTR [rsp+0x18],rax
  215c10:	mov    rax,QWORD PTR [rsp+0x78]
  215c15:	mov    QWORD PTR [rsp+0x10],rax
  215c1a:	mov    QWORD PTR [rsp+0x8],r15
  215c1f:	mov    QWORD PTR [rsp],r14
  215c23:	mov    r8,rbp
  215c26:	mov    r9,r12
  215c29:	mov    rcx,rbx
  215c2c:	movsd  xmm0,QWORD PTR [rsp+0x98]
  215c35:	movsd  xmm1,QWORD PTR [rsp+0xc8]
  215c3e:	call   QWORD PTR [rsp+0xe8]
  215c45:	add    rsp,0x70
  215c49:	jmp    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215c4e:	lea    rax,[r12-0x1]
  215c53:	mov    ecx,r12d
  215c56:	and    ecx,0x3
  215c59:	and    r12,0xfffffffffffffffc
  215c5d:	lea    rdx,[r9*8+0x0]
  215c65:	lea    rsi,[rdx+rdx*2]
  215c69:	shl    r15,0x3
  215c6d:	mov    rdi,r9
  215c70:	shl    rdi,0x5
  215c74:	mov    r8,r9
  215c77:	shl    r8,0x4
  215c7b:	xor    r10d,r10d
  215c7e:	jmp    215c8f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x78f>
  215c80:	inc    r10
  215c83:	add    r14,r15
  215c86:	cmp    r10,rbx
  215c89:	je     216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215c8f:	cmp    rax,0x3
  215c93:	jae    215ca0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7a0>
  215c95:	xor    r11d,r11d
  215c98:	jmp    215ce4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7e4>
  215c9a:	nop    WORD PTR [rax+rax*1+0x0]
  215ca0:	mov    r13,r14
  215ca3:	xor    r11d,r11d
  215ca6:	cs nop WORD PTR [rax+rax*1+0x0]
  215cb0:	mov    QWORD PTR [r13+0x0],0x0
  215cb8:	mov    QWORD PTR [r13+r9*8+0x0],0x0
  215cc1:	mov    QWORD PTR [r13+r8*1+0x0],0x0
  215cca:	add    r11,0x4
  215cce:	mov    QWORD PTR [r13+rsi*1+0x0],0x0
  215cd7:	add    r13,rdi
  215cda:	cmp    r12,r11
  215cdd:	jne    215cb0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7b0>
  215cdf:	test   rcx,rcx
  215ce2:	je     215c80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x780>
  215ce4:	imul   r11,rdx
  215ce8:	add    r11,r14
  215ceb:	mov    r13,rcx
  215cee:	xchg   ax,ax
  215cf0:	mov    QWORD PTR [r11],0x0
  215cf7:	add    r11,rdx
  215cfa:	dec    r13
  215cfd:	jne    215cf0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7f0>
  215cff:	jmp    215c80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x780>
  215d04:	mov    rax,r12
  215d07:	jmp    215d6d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x86d>
  215d09:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe29ec7]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  215d11:	mov    rax,rdi
  215d14:	mov    r11,r13
  215d17:	mov    r13,QWORD PTR [rsp+0x148]
  215d1f:	test   r13,r13
  215d22:	je     215de5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8e5>
  215d28:	sub    rsp,0x8
  215d2c:	movzx  ecx,sil
  215d30:	mov    QWORD PTR [rsp+0x18],rcx
  215d35:	mov    rdi,r12
  215d38:	mov    rsi,rbx
  215d3b:	mov    rdx,r10
  215d3e:	mov    rcx,r14
  215d41:	mov    r8,r15
  215d44:	push   r13
  215d46:	push   0x1
  215d48:	push   QWORD PTR [rsp+0x30]
  215d4c:	push   rbp
  215d4d:	push   r11
  215d4f:	push   QWORD PTR [rsp+0x98]
  215d56:	push   QWORD PTR [rsp+0x40]
  215d5a:	push   rax
  215d5b:	push   QWORD PTR [rsp+0x58]
  215d5f:	jmp    215e13 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x913>
  215d64:	mov    rax,rbx
  215d67:	mov    rbx,r12
  215d6a:	mov    r15,r9
  215d6d:	mov    ecx,0x1
  215d72:	sub    rcx,rax
  215d75:	lea    r14,[r14+rcx*8]
  215d79:	lea    rcx,[rax-0x1]
  215d7d:	mov    edx,eax
  215d7f:	and    edx,0x3
  215d82:	and    rax,0xfffffffffffffffc
  215d86:	xor    esi,esi
  215d88:	xorps  xmm0,xmm0
  215d8b:	jmp    215d9c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x89c>
  215d8d:	nop    DWORD PTR [rax]
  215d90:	inc    rsi
  215d93:	cmp    rsi,rbx
  215d96:	je     216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215d9c:	mov    rdi,rsi
  215d9f:	imul   rdi,r15
  215da3:	lea    rdi,[r14+rdi*8]
  215da7:	cmp    rcx,0x3
  215dab:	jb     215dc9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8c9>
  215dad:	xor    r8d,r8d
  215db0:	movups XMMWORD PTR [rdi],xmm0
  215db3:	movups XMMWORD PTR [rdi+0x10],xmm0
  215db7:	add    rdi,0x20
  215dbb:	add    r8,0x4
  215dbf:	cmp    rax,r8
  215dc2:	jne    215db0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b0>
  215dc4:	test   rdx,rdx
  215dc7:	je     215d90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x890>
  215dc9:	xor    r8d,r8d
  215dcc:	nop    DWORD PTR [rax+0x0]
  215dd0:	mov    QWORD PTR [rdi],0x0
  215dd7:	add    rdi,0x8
  215ddb:	inc    r8
  215dde:	cmp    rdx,r8
  215de1:	jne    215dd0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8d0>
  215de3:	jmp    215d90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x890>
  215de5:	sub    rsp,0x10
  215de9:	movzx  r13d,sil
  215ded:	mov    rdi,r12
  215df0:	mov    rsi,rbx
  215df3:	mov    rdx,r10
  215df6:	mov    rcx,r14
  215df9:	mov    r8,r15
  215dfc:	push   0x0
  215dfe:	push   QWORD PTR [rsp+0x30]
  215e02:	push   rbp
  215e03:	push   r11
  215e05:	push   QWORD PTR [rsp+0x98]
  215e0c:	push   QWORD PTR [rsp+0x40]
  215e10:	push   rax
  215e11:	push   r13
  215e13:	call   20b180 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmdECscfHK10Grmvq_6fbench>
  215e18:	add    rsp,0x50
  215e1c:	jmp    216023 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb23>
  215e21:	mov    rax,0xffffffffffffffff
  215e28:	jmp    215a2a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x52a>
  215e2d:	mov    QWORD PTR [rsp+0x38],r9
  215e32:	mov    QWORD PTR [rsp+0x60],r13
  215e37:	mov    DWORD PTR [rsp+0x30],esi
  215e3b:	mov    r13,rbp
  215e3e:	mov    rbp,rdi
  215e41:	movsd  QWORD PTR [rsp+0x58],xmm1
  215e47:	call   QWORD PTR [rip+0x336073]        # 54bec0 <_DYNAMIC+0x458>
  215e4d:	mov    rdx,QWORD PTR [rip+0x336064]        # 54beb8 <_DYNAMIC+0x450>
  215e54:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215e5a:	mov    r11,QWORD PTR [rsp+0x8]
  215e5f:	mov    r8,QWORD PTR [rsp+0x68]
  215e64:	mov    rdi,rbp
  215e67:	mov    rbp,r13
  215e6a:	mov    esi,DWORD PTR [rsp+0x30]
  215e6e:	mov    r13,QWORD PTR [rsp+0x60]
  215e73:	mov    r10,QWORD PTR [rsp+0x10]
  215e78:	mov    r9,QWORD PTR [rsp+0x38]
  215e7d:	mov    cl,0x1
  215e7f:	test   eax,0x80000
  215e84:	je     215a64 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x564>
  215e8a:	jmp    215f43 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa43>
  215e8f:	mov    QWORD PTR [rsp+0x38],r9
  215e94:	mov    QWORD PTR [rsp+0x60],r13
  215e99:	mov    DWORD PTR [rsp+0x30],esi
  215e9d:	mov    r13,rbp
  215ea0:	mov    rbp,rdi
  215ea3:	movsd  QWORD PTR [rsp+0x58],xmm1
  215ea9:	call   QWORD PTR [rip+0x336011]        # 54bec0 <_DYNAMIC+0x458>
  215eaf:	mov    rdx,QWORD PTR [rip+0x336002]        # 54beb8 <_DYNAMIC+0x450>
  215eb6:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215ebc:	mov    r11,QWORD PTR [rsp+0x8]
  215ec1:	mov    r8,QWORD PTR [rsp+0x68]
  215ec6:	mov    rdi,rbp
  215ec9:	mov    rbp,r13
  215ecc:	mov    esi,DWORD PTR [rsp+0x30]
  215ed0:	mov    r13,QWORD PTR [rsp+0x60]
  215ed5:	mov    r10,QWORD PTR [rsp+0x10]
  215eda:	mov    r9,QWORD PTR [rsp+0x38]
  215edf:	test   ax,ax
  215ee2:	js     215a75 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x575>
  215ee8:	jmp    215a8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215eed:	mov    QWORD PTR [rsp+0x38],r9
  215ef2:	mov    QWORD PTR [rsp+0x60],r13
  215ef7:	mov    DWORD PTR [rsp+0x30],esi
  215efb:	mov    r13,rbp
  215efe:	mov    rbp,rdi
  215f01:	movsd  QWORD PTR [rsp+0x58],xmm1
  215f07:	call   QWORD PTR [rip+0x335fb3]        # 54bec0 <_DYNAMIC+0x458>
  215f0d:	movsd  xmm1,QWORD PTR [rsp+0x58]
  215f13:	mov    r11,QWORD PTR [rsp+0x8]
  215f18:	mov    r8,QWORD PTR [rsp+0x68]
  215f1d:	mov    rdi,rbp
  215f20:	mov    rbp,r13
  215f23:	mov    esi,DWORD PTR [rsp+0x30]
  215f27:	mov    r13,QWORD PTR [rsp+0x60]
  215f2c:	mov    r10,QWORD PTR [rsp+0x10]
  215f31:	mov    r9,QWORD PTR [rsp+0x38]
  215f36:	bt     rax,0x37
  215f3b:	jae    215a8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x58c>
  215f41:	xor    ecx,ecx
  215f43:	mov    DWORD PTR [rsp+0x10],ecx
  215f47:	mov    rcx,QWORD PTR [rsp+0x28]
  215f4c:	imul   rcx,r10
  215f50:	mov    rdx,QWORD PTR [rsp+0x148]
  215f58:	cmp    rdx,0x1
  215f5c:	adc    rdx,0x0
  215f60:	cmp    rcx,0x8000
  215f67:	mov    eax,0x1
  215f6c:	cmovae rax,rdx
  215f70:	sub    rsp,0xa0
  215f77:	lea    rdx,[rsp+0xe0]
  215f7f:	mov    QWORD PTR [rsp+0x88],rdx
  215f87:	movzx  edx,BYTE PTR [rsp+0xa4]
  215f8f:	mov    DWORD PTR [rsp+0x80],edx
  215f96:	mov    QWORD PTR [rsp+0x78],rbp
  215f9b:	mov    rdx,QWORD PTR [rsp+0xb8]
  215fa3:	mov    QWORD PTR [rsp+0x70],rdx
  215fa8:	mov    QWORD PTR [rsp+0x68],r13
  215fad:	xorps  xmm0,xmm0
  215fb0:	movups XMMWORD PTR [rsp+0x58],xmm0
  215fb5:	movzx  edx,BYTE PTR [rsp+0xc0]
  215fbd:	mov    DWORD PTR [rsp+0x50],edx
  215fc1:	mov    QWORD PTR [rsp+0x48],r11
  215fc6:	mov    QWORD PTR [rsp+0x40],r8
  215fcb:	mov    QWORD PTR [rsp+0x38],rdi
  215fd0:	movzx  edx,sil
  215fd4:	mov    DWORD PTR [rsp+0x30],edx
  215fd8:	movups XMMWORD PTR [rsp+0x18],xmm0
  215fdd:	mov    QWORD PTR [rsp+0x10],r15
  215fe2:	mov    QWORD PTR [rsp+0x8],r9
  215fe7:	mov    QWORD PTR [rsp],r14
  215feb:	mov    QWORD PTR [rsp+0x90],rax
  215ff3:	mov    DWORD PTR [rsp+0x28],0x2
  215ffb:	movzx  edx,BYTE PTR [rsp+0xb0]
  216003:	mov    r8,rbx
  216006:	mov    edi,0x1
  21600b:	mov    r9,r10
  21600e:	mov    esi,0x1
  216013:	mov    rcx,r12
  216016:	call   QWORD PTR [rip+0x335eac]        # 54bec8 <_DYNAMIC+0x460>
  21601c:	add    rsp,0xa0
  216023:	add    rsp,0x108
  21602a:	pop    rbx
  21602b:	pop    r12
  21602d:	pop    r13
  21602f:	pop    r14
  216031:	pop    r15
  216033:	pop    rbp
  216034:	ret
