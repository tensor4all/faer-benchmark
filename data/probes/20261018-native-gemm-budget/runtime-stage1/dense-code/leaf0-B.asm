
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/7f713a1401f1-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000022c660 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  22c660:	push   rbp
  22c661:	push   r15
  22c663:	push   r14
  22c665:	push   r13
  22c667:	push   r12
  22c669:	push   rbx
  22c66a:	sub    rsp,0x128
  22c671:	mov    r12,QWORD PTR [rdi+0x8]
  22c675:	test   r12,r12
  22c678:	je     22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22c67e:	mov    r15,QWORD PTR [rdi+0x10]
  22c682:	test   r15,r15
  22c685:	je     22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22c68b:	mov    rbx,QWORD PTR [rdi]
  22c68e:	mov    r14,QWORD PTR [rdi+0x18]
  22c692:	mov    rbp,QWORD PTR [rdi+0x20]
  22c696:	mov    rax,QWORD PTR [rdx+0x10]
  22c69a:	mov    QWORD PTR [rsp+0x38],rax
  22c69f:	test   rax,rax
  22c6a2:	je     22c754 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
  22c6a8:	mov    DWORD PTR [rsp+0x28],r9d
  22c6ad:	mov    DWORD PTR [rsp+0x20],esi
  22c6b1:	mov    DWORD PTR [rsp+0x10],ecx
  22c6b5:	mov    r10,QWORD PTR [rdx]
  22c6b8:	mov    rcx,QWORD PTR [rdx+0x8]
  22c6bc:	mov    r9,QWORD PTR [rdx+0x18]
  22c6c0:	test   r14,r14
  22c6c3:	jns    22c6fd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d>
  22c6c5:	lea    rax,[r12-0x1]
  22c6ca:	imul   rax,r14
  22c6ce:	shl    rax,0x4
  22c6d2:	add    rbx,rax
  22c6d5:	neg    r14
  22c6d8:	xor    eax,eax
  22c6da:	mov    rsi,rcx
  22c6dd:	sub    rsi,0x1
  22c6e1:	cmovb  rsi,rax
  22c6e5:	mov    rdi,r9
  22c6e8:	imul   rdi,rsi
  22c6ec:	cmp    rsi,rcx
  22c6ef:	cmove  rdi,rax
  22c6f3:	shl    rdi,0x4
  22c6f7:	add    r10,rdi
  22c6fa:	neg    r9
  22c6fd:	mov    QWORD PTR [rsp+0x30],r9
  22c702:	mov    rsi,QWORD PTR [rdx+0x20]
  22c706:	mov    rdi,QWORD PTR [r8]
  22c709:	mov    r9,QWORD PTR [r8+0x8]
  22c70d:	mov    rax,QWORD PTR [r8+0x10]
  22c711:	mov    QWORD PTR [rsp+0x18],rax
  22c716:	mov    rax,QWORD PTR [r8+0x20]
  22c71a:	test   rbp,rbp
  22c71d:	js     22c7a3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x143>
  22c723:	mov    r8,QWORD PTR [r8+0x18]
  22c727:	test   rsi,rsi
  22c72a:	js     22c811 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b1>
  22c730:	mov    QWORD PTR [rsp+0x8],r10
  22c735:	mov    r10,QWORD PTR [rsp+0x168]
  22c73d:	mov    r11,QWORD PTR [rsp+0x160]
  22c745:	cmp    r15,0x1
  22c749:	je     22c89c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x23c>
  22c74f:	jmp    22c98b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  22c754:	test   sil,sil
  22c757:	jne    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22c75d:	cmp    r12,0x1
  22c761:	je     22c777 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
  22c763:	cmp    r14,0xffffffffffffffff
  22c767:	je     22cede <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x87e>
  22c76d:	cmp    r14,0x1
  22c771:	je     22cc72 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x612>
  22c777:	cmp    r15,0x1
  22c77b:	je     22cc68 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  22c781:	cmp    rbp,0xffffffffffffffff
  22c785:	je     22d047 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9e7>
  22c78b:	cmp    rbp,0x1
  22c78f:	jne    22cc68 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  22c795:	mov    rax,r15
  22c798:	mov    r15,r12
  22c79b:	mov    rbp,r14
  22c79e:	jmp    22d05f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  22c7a3:	lea    rdx,[r15-0x1]
  22c7a7:	imul   rdx,rbp
  22c7ab:	shl    rdx,0x4
  22c7af:	add    rbx,rdx
  22c7b2:	neg    rbp
  22c7b5:	xor    r13d,r13d
  22c7b8:	mov    r11,rsi
  22c7bb:	mov    rsi,QWORD PTR [rsp+0x18]
  22c7c0:	sub    rsi,0x1
  22c7c4:	cmovb  rsi,r13
  22c7c8:	mov    rdx,rcx
  22c7cb:	mov    rcx,r10
  22c7ce:	mov    r10,rax
  22c7d1:	mov    rax,rdi
  22c7d4:	mov    rdi,r10
  22c7d7:	imul   rdi,rsi
  22c7db:	cmp    rsi,QWORD PTR [rsp+0x18]
  22c7e0:	mov    rsi,r11
  22c7e3:	cmove  rdi,r13
  22c7e7:	test   r9,r9
  22c7ea:	cmove  rdi,r9
  22c7ee:	shl    rdi,0x4
  22c7f2:	add    rax,rdi
  22c7f5:	mov    rdi,rax
  22c7f8:	mov    rax,r10
  22c7fb:	mov    r10,rcx
  22c7fe:	mov    rcx,rdx
  22c801:	neg    rax
  22c804:	mov    r8,QWORD PTR [r8+0x18]
  22c808:	test   rsi,rsi
  22c80b:	jns    22c730 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd0>
  22c811:	mov    rdx,QWORD PTR [rsp+0x38]
  22c816:	dec    rdx
  22c819:	imul   rdx,rsi
  22c81d:	test   rcx,rcx
  22c820:	cmove  rdx,rcx
  22c824:	shl    rdx,0x4
  22c828:	add    r10,rdx
  22c82b:	mov    QWORD PTR [rsp+0x8],r10
  22c830:	neg    rsi
  22c833:	xor    edx,edx
  22c835:	mov    r10,r8
  22c838:	mov    r8,rsi
  22c83b:	mov    rsi,r9
  22c83e:	sub    rsi,0x1
  22c842:	cmovb  rsi,rdx
  22c846:	mov    r11,rcx
  22c849:	mov    rcx,rax
  22c84c:	mov    rax,rdi
  22c84f:	mov    rdi,r10
  22c852:	imul   rdi,rsi
  22c856:	mov    r13,QWORD PTR [rsp+0x18]
  22c85b:	test   r13,r13
  22c85e:	cmove  rdi,r13
  22c862:	cmp    rsi,r9
  22c865:	mov    rsi,r8
  22c868:	mov    r8,r10
  22c86b:	cmove  rdi,rdx
  22c86f:	shl    rdi,0x4
  22c873:	add    rax,rdi
  22c876:	mov    rdi,rax
  22c879:	mov    rax,rcx
  22c87c:	mov    rcx,r11
  22c87f:	neg    r8
  22c882:	mov    r10,QWORD PTR [rsp+0x168]
  22c88a:	mov    r11,QWORD PTR [rsp+0x160]
  22c892:	cmp    r15,0x1
  22c896:	jne    22c98b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  22c89c:	cmp    QWORD PTR [rsp+0x30],0x1
  22c8a2:	jne    22c914 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  22c8a4:	cmp    r14,0x1
  22c8a8:	jne    22c914 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  22c8aa:	test   rbx,rbx
  22c8ad:	je     22c914 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  22c8af:	mov    rax,QWORD PTR [rsp+0x8]
  22c8b4:	mov    QWORD PTR [rsp+0x98],rax
  22c8bc:	mov    QWORD PTR [rsp+0xa0],rcx
  22c8c4:	mov    rax,QWORD PTR [rsp+0x38]
  22c8c9:	mov    QWORD PTR [rsp+0xa8],rax
  22c8d1:	mov    QWORD PTR [rsp+0xb0],rsi
  22c8d9:	mov    QWORD PTR [rsp+0x50],rdi
  22c8de:	mov    QWORD PTR [rsp+0x58],r9
  22c8e3:	mov    QWORD PTR [rsp+0x60],r8
  22c8e8:	sub    rsp,0x8
  22c8ec:	movzx  eax,BYTE PTR [rsp+0x30]
  22c8f1:	movzx  edx,BYTE PTR [rsp+0x28]
  22c8f6:	movzx  r8d,BYTE PTR [rsp+0x18]
  22c8fc:	lea    rcx,[rsp+0xa0]
  22c904:	lea    r9,[rsp+0x58]
  22c909:	mov    rdi,rbx
  22c90c:	mov    rsi,r12
  22c90f:	jmp    22ca0f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3af>
  22c914:	cmp    rsi,0x1
  22c918:	jne    22c98b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  22c91a:	cmp    r8,0x1
  22c91e:	jne    22c98b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  22c920:	test   rdi,rdi
  22c923:	je     22c98b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  22c925:	mov    rax,QWORD PTR [rsp+0x8]
  22c92a:	mov    QWORD PTR [rsp+0x98],rax
  22c932:	mov    QWORD PTR [rsp+0xa0],rcx
  22c93a:	mov    rax,QWORD PTR [rsp+0x38]
  22c93f:	mov    QWORD PTR [rsp+0xa8],rax
  22c947:	mov    rax,QWORD PTR [rsp+0x30]
  22c94c:	mov    QWORD PTR [rsp+0xb0],rax
  22c954:	mov    QWORD PTR [rsp+0x50],rbx
  22c959:	mov    QWORD PTR [rsp+0x58],r12
  22c95e:	mov    QWORD PTR [rsp+0x60],r14
  22c963:	sub    rsp,0x8
  22c967:	movzx  eax,BYTE PTR [rsp+0x30]
  22c96c:	movzx  esi,BYTE PTR [rsp+0x28]
  22c971:	movzx  ecx,BYTE PTR [rsp+0x18]
  22c976:	mov    r8,rdi
  22c979:	lea    rdi,[rsp+0x58]
  22c97e:	lea    rdx,[rsp+0xa0]
  22c986:	jmp    22ca97 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x437>
  22c98b:	cmp    r12,0x1
  22c98f:	jne    22caaa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  22c995:	xor    edx,edx
  22c997:	cmp    rbp,0x1
  22c99b:	cmove  rdx,rbx
  22c99f:	cmp    rax,0x1
  22c9a3:	jne    22ca22 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  22c9a5:	test   rdx,rdx
  22c9a8:	je     22ca22 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  22c9aa:	mov    QWORD PTR [rsp+0x98],rdi
  22c9b2:	mov    rax,QWORD PTR [rsp+0x18]
  22c9b7:	mov    QWORD PTR [rsp+0xa0],rax
  22c9bf:	mov    QWORD PTR [rsp+0xa8],r9
  22c9c7:	mov    QWORD PTR [rsp+0xb0],r8
  22c9cf:	mov    rax,QWORD PTR [rsp+0x8]
  22c9d4:	mov    QWORD PTR [rsp+0x50],rax
  22c9d9:	mov    rax,QWORD PTR [rsp+0x38]
  22c9de:	mov    QWORD PTR [rsp+0x58],rax
  22c9e3:	mov    QWORD PTR [rsp+0x60],rsi
  22c9e8:	sub    rsp,0x8
  22c9ec:	movzx  eax,BYTE PTR [rsp+0x18]
  22c9f1:	movzx  edx,BYTE PTR [rsp+0x28]
  22c9f6:	movzx  r8d,BYTE PTR [rsp+0x30]
  22c9fc:	lea    rcx,[rsp+0xa0]
  22ca04:	lea    r9,[rsp+0x58]
  22ca09:	mov    rdi,rbx
  22ca0c:	mov    rsi,r15
  22ca0f:	push   r10
  22ca11:	push   r11
  22ca13:	push   rax
  22ca14:	call   14abd0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  22ca19:	add    rsp,0x20
  22ca1d:	jmp    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22ca22:	xor    edx,edx
  22ca24:	cmp    rsi,0x1
  22ca28:	cmove  rdx,QWORD PTR [rsp+0x8]
  22ca2e:	cmp    r8,0x1
  22ca32:	jne    22caaa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  22ca34:	test   rdx,rdx
  22ca37:	je     22caaa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  22ca39:	mov    QWORD PTR [rsp+0x98],rdi
  22ca41:	mov    rcx,QWORD PTR [rsp+0x18]
  22ca46:	mov    QWORD PTR [rsp+0xa0],rcx
  22ca4e:	mov    QWORD PTR [rsp+0xa8],r9
  22ca56:	mov    QWORD PTR [rsp+0xb0],rax
  22ca5e:	mov    QWORD PTR [rsp+0x50],rbx
  22ca63:	mov    QWORD PTR [rsp+0x58],r15
  22ca68:	mov    QWORD PTR [rsp+0x60],rbp
  22ca6d:	sub    rsp,0x8
  22ca71:	movzx  eax,BYTE PTR [rsp+0x18]
  22ca76:	movzx  esi,BYTE PTR [rsp+0x28]
  22ca7b:	movzx  ecx,BYTE PTR [rsp+0x30]
  22ca80:	lea    rdi,[rsp+0x58]
  22ca85:	lea    rdx,[rsp+0xa0]
  22ca8d:	mov    r8,QWORD PTR [rsp+0x10]
  22ca92:	mov    r9,QWORD PTR [rsp+0x40]
  22ca97:	push   r10
  22ca99:	push   r11
  22ca9b:	push   rax
  22ca9c:	call   19a7c0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  22caa1:	add    rsp,0x20
  22caa5:	jmp    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22caaa:	mov    QWORD PTR [rsp+0x48],r8
  22caaf:	cmp    QWORD PTR [rsp+0x38],0x1
  22cab5:	mov    r8,QWORD PTR [rsp+0x30]
  22caba:	jne    22cbbf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  22cac0:	xor    edx,edx
  22cac2:	cmp    r14,0x1
  22cac6:	cmove  rdx,rbx
  22caca:	cmp    r8,0x1
  22cace:	jne    22cb36 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  22cad0:	test   rdx,rdx
  22cad3:	je     22cb36 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  22cad5:	mov    QWORD PTR [rsp+0x98],rdx
  22cadd:	mov    QWORD PTR [rsp+0xa0],r12
  22cae5:	mov    QWORD PTR [rsp+0xa8],r15
  22caed:	mov    QWORD PTR [rsp+0xb0],rbp
  22caf5:	mov    QWORD PTR [rsp+0x50],rdi
  22cafa:	mov    rdx,QWORD PTR [rsp+0x18]
  22caff:	mov    QWORD PTR [rsp+0x58],rdx
  22cb04:	mov    QWORD PTR [rsp+0x60],rax
  22cb09:	sub    rsp,0x8
  22cb0d:	movzx  eax,BYTE PTR [rsp+0x30]
  22cb12:	movzx  esi,BYTE PTR [rsp+0x28]
  22cb17:	movzx  r8d,BYTE PTR [rsp+0x18]
  22cb1d:	lea    rdi,[rsp+0xa0]
  22cb25:	lea    r9,[rsp+0x58]
  22cb2a:	mov    rdx,QWORD PTR [rsp+0x10]
  22cb2f:	push   r10
  22cb31:	push   r11
  22cb33:	push   rax
  22cb34:	jmp    22cbb1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x551>
  22cb36:	xor    edx,edx
  22cb38:	cmp    rbp,0x1
  22cb3c:	cmove  rdx,rbx
  22cb40:	cmp    rax,0x1
  22cb44:	jne    22cbbf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  22cb46:	test   rdx,rdx
  22cb49:	je     22cbbf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  22cb4b:	mov    QWORD PTR [rsp+0x98],rdx
  22cb53:	mov    QWORD PTR [rsp+0xa0],r15
  22cb5b:	mov    QWORD PTR [rsp+0xa8],r12
  22cb63:	mov    QWORD PTR [rsp+0xb0],r14
  22cb6b:	mov    rax,QWORD PTR [rsp+0x8]
  22cb70:	mov    QWORD PTR [rsp+0x50],rax
  22cb75:	mov    QWORD PTR [rsp+0x58],rcx
  22cb7a:	mov    QWORD PTR [rsp+0x60],r8
  22cb7f:	sub    rsp,0x8
  22cb83:	mov    rax,r11
  22cb86:	movzx  r11d,BYTE PTR [rsp+0x18]
  22cb8c:	movzx  esi,BYTE PTR [rsp+0x28]
  22cb91:	movzx  r8d,BYTE PTR [rsp+0x30]
  22cb97:	mov    rdx,rdi
  22cb9a:	lea    rdi,[rsp+0xa0]
  22cba2:	lea    r9,[rsp+0x58]
  22cba7:	mov    rcx,QWORD PTR [rsp+0x20]
  22cbac:	push   r10
  22cbae:	push   rax
  22cbaf:	push   r11
  22cbb1:	call   149610 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  22cbb6:	add    rsp,0x20
  22cbba:	jmp    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22cbbf:	mov    QWORD PTR [rsp+0x70],rax
  22cbc4:	mov    QWORD PTR [rsp+0x18],rdi
  22cbc9:	mov    QWORD PTR [rsp+0x40],rsi
  22cbce:	movups xmm2,XMMWORD PTR [r11]
  22cbd2:	movaps XMMWORD PTR [rsp+0x50],xmm2
  22cbd7:	mov    rax,r12
  22cbda:	mul    r15
  22cbdd:	mov    r13,rax
  22cbe0:	jo     22d16e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb0e>
  22cbe6:	mul    QWORD PTR [rsp+0x38]
  22cbeb:	seto   cl
  22cbee:	not    cl
  22cbf0:	cmp    rax,0x1001
  22cbf6:	setb   al
  22cbf9:	test   cl,al
  22cbfb:	mov    esi,DWORD PTR [rsp+0x10]
  22cbff:	mov    edi,DWORD PTR [rsp+0x20]
  22cc03:	jne    22cc5e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5fe>
  22cc05:	mov    rdx,QWORD PTR [rip+0x31d16c]        # 549d78 <_DYNAMIC+0x450>
  22cc0c:	mov    rax,QWORD PTR [rdx]
  22cc0f:	test   rax,rax
  22cc12:	je     22d17a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb1a>
  22cc18:	mov    cl,0x1
  22cc1a:	test   eax,0x80000
  22cc1f:	jne    22d21b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  22cc25:	mov    rax,QWORD PTR [rdx]
  22cc28:	test   rax,rax
  22cc2b:	je     22d1b3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb53>
  22cc31:	test   ax,ax
  22cc34:	jns    22cc4d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  22cc36:	mov    rax,QWORD PTR [rdx]
  22cc39:	test   rax,rax
  22cc3c:	je     22d1eb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8b>
  22cc42:	bt     rax,0x37
  22cc47:	jb     22d219 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbb9>
  22cc4d:	test   dil,dil
  22cc50:	jne    22cee6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x886>
  22cc56:	xorps  xmm0,xmm0
  22cc59:	jmp    22ceee <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x88e>
  22cc5e:	test   dil,dil
  22cc61:	jne    22cc7a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  22cc63:	xorps  xmm0,xmm0
  22cc66:	jmp    22cc82 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x622>
  22cc68:	cmp    r14,0x1
  22cc6c:	jne    22ce37 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7d7>
  22cc72:	mov    rax,r12
  22cc75:	jmp    22d05f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  22cc7a:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe12ef6]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  22cc82:	movsd  QWORD PTR [rsp+0x20],xmm0
  22cc88:	mov    rax,QWORD PTR [rsp+0x8]
  22cc8d:	mov    rdx,QWORD PTR [rsp+0x18]
  22cc92:	cmp    rbp,r14
  22cc95:	jae    22ccc2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x662>
  22cc97:	mov    BYTE PTR [rsp+0x8],sil
  22cc9c:	mov    QWORD PTR [rsp+0x10],r8
  22cca1:	mov    rcx,QWORD PTR [rsp+0x40]
  22cca6:	mov    QWORD PTR [rsp+0x78],rcx
  22ccab:	mov    QWORD PTR [rsp+0x90],rax
  22ccb3:	mov    QWORD PTR [rsp+0x30],r14
  22ccb8:	mov    r13,r12
  22ccbb:	mov    r8,QWORD PTR [rsp+0x70]
  22ccc0:	jmp    22cd05 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a5>
  22ccc2:	mov    ecx,DWORD PTR [rsp+0x28]
  22ccc6:	mov    BYTE PTR [rsp+0x8],cl
  22ccca:	mov    DWORD PTR [rsp+0x28],esi
  22ccce:	mov    rcx,QWORD PTR [rsp+0x70]
  22ccd3:	mov    QWORD PTR [rsp+0x10],rcx
  22ccd8:	mov    rcx,QWORD PTR [rsp+0x48]
  22ccdd:	mov    QWORD PTR [rsp+0x78],rcx
  22cce2:	mov    QWORD PTR [rsp+0x90],rdx
  22ccea:	mov    rcx,QWORD PTR [rsp+0x40]
  22ccef:	mov    QWORD PTR [rsp+0x48],rcx
  22ccf4:	mov    rdx,rax
  22ccf7:	mov    QWORD PTR [rsp+0x30],rbp
  22ccfc:	mov    rbp,r14
  22ccff:	mov    r13,r15
  22cd02:	mov    r15,r12
  22cd05:	movaps XMMWORD PTR [rsp+0x80],xmm2
  22cd0d:	mov    QWORD PTR [rsp+0x18],rdx
  22cd12:	mov    r12,r8
  22cd15:	cmp    r8,0x1
  22cd19:	jne    22cd46 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  22cd1b:	cmp    rbp,0x1
  22cd1f:	jne    22cd46 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  22cd21:	lea    r8,[rip+0x315580]        # 5422a8 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x3e0>
  22cd28:	lea    rdi,[rsp+0x98]
  22cd30:	mov    rsi,r15
  22cd33:	mov    rdx,r13
  22cd36:	mov    r14,QWORD PTR [rsp+0x38]
  22cd3b:	mov    rcx,r14
  22cd3e:	call   QWORD PTR [rip+0x31d32c]        # 54a070 <_DYNAMIC+0x748>
  22cd44:	jmp    22cd69 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x709>
  22cd46:	lea    r8,[rip+0x315573]        # 5422c0 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x3f8>
  22cd4d:	lea    rdi,[rsp+0x98]
  22cd55:	mov    rsi,r15
  22cd58:	mov    rdx,r13
  22cd5b:	mov    r14,QWORD PTR [rsp+0x38]
  22cd60:	mov    rcx,r14
  22cd63:	call   QWORD PTR [rip+0x31d30f]        # 54a078 <_DYNAMIC+0x750>
  22cd69:	lea    rdi,[rsp+0xa0]
  22cd71:	mov    rsi,QWORD PTR [rsp+0xc0]
  22cd79:	mov    rdx,QWORD PTR [rsp+0xc8]
  22cd81:	movups xmm0,XMMWORD PTR [rsp+0xd0]
  22cd89:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  22cd91:	movaps xmm3,xmm2
  22cd94:	unpckhpd xmm3,xmm2
  22cd98:	sub    rsp,0x70
  22cd9c:	movups XMMWORD PTR [rsp+0x58],xmm0
  22cda1:	movzx  eax,BYTE PTR [rsp+0x78]
  22cda6:	mov    DWORD PTR [rsp+0x50],eax
  22cdaa:	movzx  eax,BYTE PTR [rsp+0x98]
  22cdb2:	mov    DWORD PTR [rsp+0x48],eax
  22cdb6:	mov    rax,QWORD PTR [rsp+0x80]
  22cdbe:	mov    QWORD PTR [rsp+0x40],rax
  22cdc3:	mov    rax,QWORD PTR [rsp+0xe8]
  22cdcb:	mov    QWORD PTR [rsp+0x38],rax
  22cdd0:	mov    rax,QWORD PTR [rsp+0x100]
  22cdd8:	mov    QWORD PTR [rsp+0x30],rax
  22cddd:	mov    rax,QWORD PTR [rsp+0xb8]
  22cde5:	mov    QWORD PTR [rsp+0x28],rax
  22cdea:	mov    QWORD PTR [rsp+0x20],r12
  22cdef:	mov    rax,QWORD PTR [rsp+0x88]
  22cdf7:	mov    QWORD PTR [rsp+0x18],rax
  22cdfc:	mov    rax,QWORD PTR [rsp+0xa0]
  22ce04:	mov    QWORD PTR [rsp+0x10],rax
  22ce09:	mov    QWORD PTR [rsp+0x8],rbp
  22ce0e:	mov    QWORD PTR [rsp],rbx
  22ce12:	xorps  xmm1,xmm1
  22ce15:	mov    r8,r13
  22ce18:	mov    r9,r14
  22ce1b:	mov    rcx,r15
  22ce1e:	movsd  xmm0,QWORD PTR [rsp+0x90]
  22ce27:	call   QWORD PTR [rsp+0x108]
  22ce2e:	add    rsp,0x70
  22ce32:	jmp    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22ce37:	lea    rax,[r12-0x1]
  22ce3c:	mov    ecx,r12d
  22ce3f:	and    ecx,0x3
  22ce42:	and    r12,0xfffffffffffffffc
  22ce46:	mov    rdx,r14
  22ce49:	shl    rdx,0x4
  22ce4d:	lea    rsi,[rdx+rdx*2]
  22ce51:	shl    rbp,0x4
  22ce55:	mov    rdi,r14
  22ce58:	shl    rdi,0x6
  22ce5c:	shl    r14,0x5
  22ce60:	xor    r8d,r8d
  22ce63:	xorps  xmm0,xmm0
  22ce66:	jmp    22ce7f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x81f>
  22ce68:	nop    DWORD PTR [rax+rax*1+0x0]
  22ce70:	inc    r8
  22ce73:	add    rbx,rbp
  22ce76:	cmp    r8,r15
  22ce79:	je     22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22ce7f:	cmp    rax,0x3
  22ce83:	jae    22ce90 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  22ce85:	xor    r9d,r9d
  22ce88:	jmp    22cec4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x864>
  22ce8a:	nop    WORD PTR [rax+rax*1+0x0]
  22ce90:	mov    r10,rbx
  22ce93:	xor    r9d,r9d
  22ce96:	cs nop WORD PTR [rax+rax*1+0x0]
  22cea0:	movups XMMWORD PTR [r10],xmm0
  22cea4:	movups XMMWORD PTR [r10+rdx*1],xmm0
  22cea9:	movups XMMWORD PTR [r10+r14*1],xmm0
  22ceae:	add    r9,0x4
  22ceb2:	movups XMMWORD PTR [r10+rsi*1],xmm0
  22ceb7:	add    r10,rdi
  22ceba:	cmp    r12,r9
  22cebd:	jne    22cea0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  22cebf:	test   rcx,rcx
  22cec2:	je     22ce70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  22cec4:	imul   r9,rdx
  22cec8:	add    r9,rbx
  22cecb:	mov    r10,rcx
  22cece:	xchg   ax,ax
  22ced0:	movups XMMWORD PTR [r9],xmm0
  22ced4:	add    r9,rdx
  22ced7:	dec    r10
  22ceda:	jne    22ced0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
  22cedc:	jmp    22ce70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  22cede:	mov    rax,r12
  22cee1:	jmp    22d050 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9f0>
  22cee6:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe12c8a]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  22ceee:	mov    rax,QWORD PTR [rsp+0x168]
  22cef6:	xor    r11d,r11d
  22cef9:	test   rax,rax
  22cefc:	setne  al
  22ceff:	cmp    rbp,r14
  22cf02:	jge    22cf25 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c5>
  22cf04:	mov    ecx,DWORD PTR [rsp+0x28]
  22cf08:	mov    BYTE PTR [rsp+0x78],cl
  22cf0c:	mov    r10,QWORD PTR [rsp+0x70]
  22cf11:	mov    rdx,QWORD PTR [rsp+0x48]
  22cf16:	mov    r9,QWORD PTR [rsp+0x18]
  22cf1b:	mov    r13,r14
  22cf1e:	mov    QWORD PTR [rsp+0x10],r15
  22cf23:	jmp    22cf62 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x902>
  22cf25:	mov    BYTE PTR [rsp+0x78],sil
  22cf2a:	mov    r10,r8
  22cf2d:	mov    rdx,QWORD PTR [rsp+0x40]
  22cf32:	mov    r9,QWORD PTR [rsp+0x8]
  22cf37:	mov    r13,rbp
  22cf3a:	mov    QWORD PTR [rsp+0x10],r12
  22cf3f:	mov    esi,DWORD PTR [rsp+0x28]
  22cf43:	mov    r8,QWORD PTR [rsp+0x70]
  22cf48:	mov    rcx,QWORD PTR [rsp+0x48]
  22cf4d:	mov    QWORD PTR [rsp+0x40],rcx
  22cf52:	mov    rcx,QWORD PTR [rsp+0x18]
  22cf57:	mov    QWORD PTR [rsp+0x8],rcx
  22cf5c:	mov    rbp,r14
  22cf5f:	mov    r12,r15
  22cf62:	test   rbp,rbp
  22cf65:	js     22d0f1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  22cf6b:	test   r13,r13
  22cf6e:	js     22d110 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab0>
  22cf74:	mov    r11b,al
  22cf77:	test   rdx,rdx
  22cf7a:	mov    QWORD PTR [rsp+0x70],r13
  22cf7f:	js     22d136 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad6>
  22cf85:	mov    r13,r11
  22cf88:	mov    QWORD PTR [rsp+0x48],r10
  22cf8d:	mov    QWORD PTR [rsp+0x28],r9
  22cf92:	mov    QWORD PTR [rsp+0x18],rdx
  22cf97:	mov    QWORD PTR [rsp+0x30],r8
  22cf9c:	mov    r15,QWORD PTR [rsp+0x38]
  22cfa1:	mov    rax,QWORD PTR [rip+0x31d068]        # 54a010 <_DYNAMIC+0x6e8>
  22cfa8:	mov    rax,QWORD PTR [rax]
  22cfab:	test   rax,rax
  22cfae:	jne    22cfe2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x982>
  22cfb0:	mov    r14d,esi
  22cfb3:	movaps XMMWORD PTR [rsp+0x80],xmm2
  22cfbb:	movsd  QWORD PTR [rsp+0x90],xmm0
  22cfc4:	call   QWORD PTR [rip+0x31d04e]        # 54a018 <_DYNAMIC+0x6f0>
  22cfca:	movsd  xmm0,QWORD PTR [rsp+0x90]
  22cfd3:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  22cfdb:	mov    edi,DWORD PTR [rsp+0x20]
  22cfdf:	mov    esi,r14d
  22cfe2:	movaps xmm3,xmm2
  22cfe5:	unpckhpd xmm3,xmm2
  22cfe9:	movzx  r11d,sil
  22cfed:	movzx  r14d,BYTE PTR [rsp+0x78]
  22cff3:	movzx  r10d,dil
  22cff7:	xorps  xmm1,xmm1
  22cffa:	mov    rdi,QWORD PTR [rsp+0x10]
  22cfff:	mov    rsi,r12
  22d002:	mov    rdx,r15
  22d005:	mov    rcx,rbx
  22d008:	mov    r8,QWORD PTR [rsp+0x70]
  22d00d:	mov    r9,rbp
  22d010:	push   QWORD PTR [rsp+0x168]
  22d017:	push   r13
  22d019:	push   r11
  22d01b:	push   r14
  22d01d:	push   0x0
  22d01f:	push   QWORD PTR [rsp+0x68]
  22d023:	push   QWORD PTR [rsp+0x60]
  22d027:	push   QWORD PTR [rsp+0x40]
  22d02b:	push   QWORD PTR [rsp+0x88]
  22d032:	push   QWORD PTR [rsp+0x60]
  22d036:	push   QWORD PTR [rsp+0x78]
  22d03a:	push   r10
  22d03c:	call   rax
  22d03e:	add    rsp,0x60
  22d042:	jmp    22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22d047:	mov    rax,r15
  22d04a:	mov    r15,r12
  22d04d:	mov    rbp,r14
  22d050:	mov    ecx,0x1
  22d055:	sub    rcx,rax
  22d058:	shl    rcx,0x4
  22d05c:	add    rbx,rcx
  22d05f:	lea    rcx,[rax-0x1]
  22d063:	mov    edx,eax
  22d065:	and    edx,0x3
  22d068:	and    rax,0xfffffffffffffffc
  22d06c:	xor    esi,esi
  22d06e:	xorps  xmm0,xmm0
  22d071:	jmp    22d08c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa2c>
  22d073:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  22d080:	inc    rsi
  22d083:	cmp    rsi,r15
  22d086:	je     22d30b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  22d08c:	mov    rdi,rsi
  22d08f:	imul   rdi,rbp
  22d093:	shl    rdi,0x4
  22d097:	add    rdi,rbx
  22d09a:	cmp    rcx,0x3
  22d09e:	jb     22d0d1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa71>
  22d0a0:	xor    r8d,r8d
  22d0a3:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  22d0b0:	movups XMMWORD PTR [rdi],xmm0
  22d0b3:	movups XMMWORD PTR [rdi+0x10],xmm0
  22d0b7:	movups XMMWORD PTR [rdi+0x20],xmm0
  22d0bb:	movups XMMWORD PTR [rdi+0x30],xmm0
  22d0bf:	add    rdi,0x40
  22d0c3:	add    r8,0x4
  22d0c7:	cmp    rax,r8
  22d0ca:	jne    22d0b0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa50>
  22d0cc:	test   rdx,rdx
  22d0cf:	je     22d080 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  22d0d1:	xor    r8d,r8d
  22d0d4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  22d0e0:	movups XMMWORD PTR [rdi],xmm0
  22d0e3:	add    rdi,0x10
  22d0e7:	inc    r8
  22d0ea:	cmp    rdx,r8
  22d0ed:	jne    22d0e0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa80>
  22d0ef:	jmp    22d080 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  22d0f1:	mov    rcx,QWORD PTR [rsp+0x10]
  22d0f6:	dec    rcx
  22d0f9:	imul   rcx,r10
  22d0fd:	shl    rcx,0x4
  22d101:	add    r9,rcx
  22d104:	neg    r10
  22d107:	test   r13,r13
  22d10a:	jns    22cf74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x914>
  22d110:	lea    rcx,[r12-0x1]
  22d115:	imul   rcx,r8
  22d119:	shl    rcx,0x4
  22d11d:	add    QWORD PTR [rsp+0x8],rcx
  22d122:	neg    r8
  22d125:	mov    r11b,al
  22d128:	test   rdx,rdx
  22d12b:	mov    QWORD PTR [rsp+0x70],r13
  22d130:	jns    22cf85 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  22d136:	mov    rax,QWORD PTR [rsp+0x38]
  22d13b:	dec    rax
  22d13e:	mov    rcx,rdx
  22d141:	imul   rcx,rax
  22d145:	shl    rcx,0x4
  22d149:	add    r9,rcx
  22d14c:	neg    rdx
  22d14f:	mov    rcx,QWORD PTR [rsp+0x40]
  22d154:	imul   rax,rcx
  22d158:	shl    rax,0x4
  22d15c:	add    QWORD PTR [rsp+0x8],rax
  22d161:	neg    rcx
  22d164:	mov    QWORD PTR [rsp+0x40],rcx
  22d169:	jmp    22cf85 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  22d16e:	mov    rax,0xffffffffffffffff
  22d175:	jmp    22cbe6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x586>
  22d17a:	movaps XMMWORD PTR [rsp+0x80],xmm2
  22d182:	call   QWORD PTR [rip+0x31cbf8]        # 549d80 <_DYNAMIC+0x458>
  22d188:	mov    rdx,QWORD PTR [rip+0x31cbe9]        # 549d78 <_DYNAMIC+0x450>
  22d18f:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  22d197:	mov    r8,QWORD PTR [rsp+0x30]
  22d19c:	mov    edi,DWORD PTR [rsp+0x20]
  22d1a0:	mov    esi,DWORD PTR [rsp+0x10]
  22d1a4:	mov    cl,0x1
  22d1a6:	test   eax,0x80000
  22d1ab:	je     22cc25 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5c5>
  22d1b1:	jmp    22d21b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  22d1b3:	movaps XMMWORD PTR [rsp+0x80],xmm2
  22d1bb:	call   QWORD PTR [rip+0x31cbbf]        # 549d80 <_DYNAMIC+0x458>
  22d1c1:	mov    rdx,QWORD PTR [rip+0x31cbb0]        # 549d78 <_DYNAMIC+0x450>
  22d1c8:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  22d1d0:	mov    r8,QWORD PTR [rsp+0x30]
  22d1d5:	mov    edi,DWORD PTR [rsp+0x20]
  22d1d9:	mov    esi,DWORD PTR [rsp+0x10]
  22d1dd:	test   ax,ax
  22d1e0:	js     22cc36 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5d6>
  22d1e6:	jmp    22cc4d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  22d1eb:	movaps XMMWORD PTR [rsp+0x80],xmm2
  22d1f3:	call   QWORD PTR [rip+0x31cb87]        # 549d80 <_DYNAMIC+0x458>
  22d1f9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  22d201:	mov    r8,QWORD PTR [rsp+0x30]
  22d206:	mov    edi,DWORD PTR [rsp+0x20]
  22d20a:	mov    esi,DWORD PTR [rsp+0x10]
  22d20e:	bt     rax,0x37
  22d213:	jae    22cc4d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  22d219:	xor    ecx,ecx
  22d21b:	mov    r9,QWORD PTR [rsp+0x38]
  22d220:	imul   r13,r9
  22d224:	mov    rdx,QWORD PTR [rsp+0x168]
  22d22c:	cmp    rdx,0x1
  22d230:	adc    rdx,0x0
  22d234:	cmp    r13,0x10000
  22d23b:	mov    eax,0x1
  22d240:	cmovae rax,rdx
  22d244:	sub    rsp,0xa0
  22d24b:	lea    rdx,[rsp+0xf0]
  22d253:	mov    QWORD PTR [rsp+0x88],rdx
  22d25b:	movzx  edx,BYTE PTR [rsp+0xc8]
  22d263:	mov    DWORD PTR [rsp+0x80],edx
  22d26a:	mov    rdx,QWORD PTR [rsp+0x110]
  22d272:	mov    QWORD PTR [rsp+0x78],rdx
  22d277:	mov    rdx,QWORD PTR [rsp+0xe8]
  22d27f:	mov    QWORD PTR [rsp+0x70],rdx
  22d284:	mov    rdx,QWORD PTR [rsp+0xb8]
  22d28c:	mov    QWORD PTR [rsp+0x68],rdx
  22d291:	xorps  xmm0,xmm0
  22d294:	movups XMMWORD PTR [rsp+0x58],xmm0
  22d299:	movzx  edx,sil
  22d29d:	mov    DWORD PTR [rsp+0x50],edx
  22d2a1:	mov    rdx,QWORD PTR [rsp+0xe0]
  22d2a9:	mov    QWORD PTR [rsp+0x48],rdx
  22d2ae:	mov    QWORD PTR [rsp+0x40],r8
  22d2b3:	mov    rdx,QWORD PTR [rsp+0xa8]
  22d2bb:	mov    QWORD PTR [rsp+0x38],rdx
  22d2c0:	movzx  edx,dil
  22d2c4:	mov    DWORD PTR [rsp+0x30],edx
  22d2c8:	movups XMMWORD PTR [rsp+0x18],xmm0
  22d2cd:	mov    QWORD PTR [rsp+0x10],rbp
  22d2d2:	mov    QWORD PTR [rsp+0x8],r14
  22d2d7:	mov    QWORD PTR [rsp],rbx
  22d2db:	mov    QWORD PTR [rsp+0x90],rax
  22d2e3:	mov    DWORD PTR [rsp+0x28],0x2
  22d2eb:	movzx  edx,cl
  22d2ee:	mov    r8,r15
  22d2f1:	mov    edi,0x3
  22d2f6:	mov    esi,0x1
  22d2fb:	mov    rcx,r12
  22d2fe:	call   QWORD PTR [rip+0x31ca84]        # 549d88 <_DYNAMIC+0x460>
  22d304:	add    rsp,0xa0
  22d30b:	add    rsp,0x128
  22d312:	pop    rbx
  22d313:	pop    r12
  22d315:	pop    r13
  22d317:	pop    r14
  22d319:	pop    r15
  22d31b:	pop    rbp
  22d31c:	ret
