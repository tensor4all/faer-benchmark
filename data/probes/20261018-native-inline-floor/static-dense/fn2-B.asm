
target/faer-rev/f013756c7421-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000021f640 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  21f640:	push   rbp
  21f641:	push   r15
  21f643:	push   r14
  21f645:	push   r13
  21f647:	push   r12
  21f649:	push   rbx
  21f64a:	sub    rsp,0x128
  21f651:	mov    DWORD PTR [rsp+0x30],ecx
  21f655:	mov    r12,QWORD PTR [rdi+0x8]
  21f659:	test   r12,r12
  21f65c:	je     22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f662:	mov    r13,QWORD PTR [rdi+0x10]
  21f666:	test   r13,r13
  21f669:	je     22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f66f:	mov    eax,r9d
  21f672:	mov    r14,QWORD PTR [rdi]
  21f675:	mov    r9,QWORD PTR [rdi+0x18]
  21f679:	mov    rcx,QWORD PTR [rdi+0x20]
  21f67d:	mov    QWORD PTR [rsp+0x10],rcx
  21f682:	mov    rcx,QWORD PTR [rdx+0x10]
  21f686:	mov    QWORD PTR [rsp+0x28],rcx
  21f68b:	test   rcx,rcx
  21f68e:	je     21f734 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
  21f694:	mov    DWORD PTR [rsp+0x18],eax
  21f698:	mov    rbx,QWORD PTR [rdx]
  21f69b:	mov    rbp,QWORD PTR [rdx+0x8]
  21f69f:	mov    r10,QWORD PTR [rdx+0x18]
  21f6a3:	test   r9,r9
  21f6a6:	jns    21f6e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4>
  21f6a8:	lea    rax,[r12-0x1]
  21f6ad:	imul   rax,r9
  21f6b1:	shl    rax,0x4
  21f6b5:	add    r14,rax
  21f6b8:	neg    r9
  21f6bb:	xor    eax,eax
  21f6bd:	mov    ecx,esi
  21f6bf:	mov    rsi,rbp
  21f6c2:	sub    rsi,0x1
  21f6c6:	cmovb  rsi,rax
  21f6ca:	mov    rdi,r10
  21f6cd:	imul   rdi,rsi
  21f6d1:	cmp    rsi,rbp
  21f6d4:	mov    esi,ecx
  21f6d6:	cmove  rdi,rax
  21f6da:	shl    rdi,0x4
  21f6de:	add    rbx,rdi
  21f6e1:	neg    r10
  21f6e4:	mov    QWORD PTR [rsp+0x48],rbp
  21f6e9:	mov    rcx,QWORD PTR [rdx+0x20]
  21f6ed:	mov    rdi,QWORD PTR [r8]
  21f6f0:	mov    rbp,QWORD PTR [r8+0x8]
  21f6f4:	mov    r11,QWORD PTR [r8+0x10]
  21f6f8:	mov    rax,QWORD PTR [r8+0x20]
  21f6fc:	cmp    QWORD PTR [rsp+0x10],0x0
  21f702:	mov    QWORD PTR [rsp+0x20],r11
  21f707:	mov    DWORD PTR [rsp+0x38],esi
  21f70b:	js     21f789 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x149>
  21f70d:	mov    r15,QWORD PTR [r8+0x18]
  21f711:	mov    r8,rcx
  21f714:	test   rcx,rcx
  21f717:	js     21f80b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1cb>
  21f71d:	mov    r11,QWORD PTR [rsp+0x160]
  21f725:	cmp    r13,0x1
  21f729:	je     21f88f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x24f>
  21f72f:	jmp    21f97a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f734:	test   sil,sil
  21f737:	jne    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f73d:	cmp    r12,0x1
  21f741:	je     21f757 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
  21f743:	cmp    r9,0xffffffffffffffff
  21f747:	je     21feee <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  21f74d:	cmp    r9,0x1
  21f751:	je     21fcca <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x68a>
  21f757:	cmp    r13,0x1
  21f75b:	je     21fcc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x680>
  21f761:	cmp    QWORD PTR [rsp+0x10],0xffffffffffffffff
  21f767:	je     21ff46 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x906>
  21f76d:	cmp    QWORD PTR [rsp+0x10],0x1
  21f773:	jne    21fcc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x680>
  21f779:	mov    rax,r13
  21f77c:	mov    r13,r12
  21f77f:	mov    QWORD PTR [rsp+0x10],r9
  21f784:	jmp    21ff60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21f789:	lea    rdx,[r13-0x1]
  21f78d:	mov    QWORD PTR [rsp+0x40],rdi
  21f792:	mov    rdi,rbx
  21f795:	mov    rbx,QWORD PTR [rsp+0x10]
  21f79a:	imul   rdx,rbx
  21f79e:	shl    rdx,0x4
  21f7a2:	add    r14,rdx
  21f7a5:	neg    rbx
  21f7a8:	mov    QWORD PTR [rsp+0x10],rbx
  21f7ad:	xor    edx,edx
  21f7af:	mov    r15,r10
  21f7b2:	mov    r10,rbp
  21f7b5:	mov    rbp,r13
  21f7b8:	mov    r13,rdi
  21f7bb:	mov    rsi,r11
  21f7be:	sub    rsi,0x1
  21f7c2:	cmovb  rsi,rdx
  21f7c6:	mov    r11,QWORD PTR [rsp+0x40]
  21f7cb:	mov    rdi,rax
  21f7ce:	imul   rdi,rsi
  21f7d2:	cmp    rsi,QWORD PTR [rsp+0x20]
  21f7d7:	mov    rbx,r13
  21f7da:	mov    r13,rbp
  21f7dd:	mov    rbp,r10
  21f7e0:	mov    r10,r15
  21f7e3:	cmove  rdi,rdx
  21f7e7:	test   rbp,rbp
  21f7ea:	cmove  rdi,rbp
  21f7ee:	shl    rdi,0x4
  21f7f2:	add    r11,rdi
  21f7f5:	mov    rdi,r11
  21f7f8:	neg    rax
  21f7fb:	mov    r15,QWORD PTR [r8+0x18]
  21f7ff:	mov    r8,rcx
  21f802:	test   rcx,rcx
  21f805:	jns    21f71d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xdd>
  21f80b:	mov    rcx,QWORD PTR [rsp+0x28]
  21f810:	lea    rdx,[rcx-0x1]
  21f814:	imul   rdx,r8
  21f818:	mov    rcx,QWORD PTR [rsp+0x48]
  21f81d:	test   rcx,rcx
  21f820:	cmove  rdx,rcx
  21f824:	shl    rdx,0x4
  21f828:	add    rbx,rdx
  21f82b:	neg    r8
  21f82e:	xor    edx,edx
  21f830:	mov    r11,rbx
  21f833:	mov    rbx,r10
  21f836:	mov    r10,rbp
  21f839:	sub    r10,0x1
  21f83d:	cmovb  r10,rdx
  21f841:	mov    rcx,r8
  21f844:	mov    r8,rdi
  21f847:	mov    rdi,r15
  21f84a:	imul   rdi,r10
  21f84e:	mov    rsi,rbp
  21f851:	mov    rbp,QWORD PTR [rsp+0x20]
  21f856:	test   rbp,rbp
  21f859:	cmove  rdi,rbp
  21f85d:	mov    rbp,rsi
  21f860:	cmp    r10,rsi
  21f863:	mov    r10,rbx
  21f866:	mov    rbx,r11
  21f869:	cmove  rdi,rdx
  21f86d:	shl    rdi,0x4
  21f871:	add    r8,rdi
  21f874:	mov    rdi,r8
  21f877:	mov    r8,rcx
  21f87a:	neg    r15
  21f87d:	mov    r11,QWORD PTR [rsp+0x160]
  21f885:	cmp    r13,0x1
  21f889:	jne    21f97a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f88f:	cmp    r10,0x1
  21f893:	jne    21f905 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f895:	cmp    r9,0x1
  21f899:	jne    21f905 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f89b:	test   r14,r14
  21f89e:	je     21f905 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f8a0:	mov    QWORD PTR [rsp+0x98],rbx
  21f8a8:	mov    rax,QWORD PTR [rsp+0x48]
  21f8ad:	mov    QWORD PTR [rsp+0xa0],rax
  21f8b5:	mov    rax,QWORD PTR [rsp+0x28]
  21f8ba:	mov    QWORD PTR [rsp+0xa8],rax
  21f8c2:	mov    QWORD PTR [rsp+0xb0],r8
  21f8ca:	mov    QWORD PTR [rsp+0x50],rdi
  21f8cf:	mov    QWORD PTR [rsp+0x58],rbp
  21f8d4:	mov    QWORD PTR [rsp+0x60],r15
  21f8d9:	sub    rsp,0x8
  21f8dd:	movzx  eax,BYTE PTR [rsp+0x20]
  21f8e2:	movzx  edx,BYTE PTR [rsp+0x40]
  21f8e7:	movzx  r8d,BYTE PTR [rsp+0x38]
  21f8ed:	lea    rcx,[rsp+0xa0]
  21f8f5:	lea    r9,[rsp+0x58]
  21f8fa:	mov    rdi,r14
  21f8fd:	mov    rsi,r12
  21f900:	jmp    21f9fb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3bb>
  21f905:	cmp    r8,0x1
  21f909:	jne    21f97a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f90b:	cmp    r15,0x1
  21f90f:	jne    21f97a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f911:	test   rdi,rdi
  21f914:	je     21f97a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f916:	mov    QWORD PTR [rsp+0x98],rbx
  21f91e:	mov    rax,QWORD PTR [rsp+0x48]
  21f923:	mov    QWORD PTR [rsp+0xa0],rax
  21f92b:	mov    rax,QWORD PTR [rsp+0x28]
  21f930:	mov    QWORD PTR [rsp+0xa8],rax
  21f938:	mov    QWORD PTR [rsp+0xb0],r10
  21f940:	mov    QWORD PTR [rsp+0x50],r14
  21f945:	mov    QWORD PTR [rsp+0x58],r12
  21f94a:	mov    QWORD PTR [rsp+0x60],r9
  21f94f:	sub    rsp,0x8
  21f953:	movzx  eax,BYTE PTR [rsp+0x20]
  21f958:	movzx  esi,BYTE PTR [rsp+0x40]
  21f95d:	movzx  ecx,BYTE PTR [rsp+0x38]
  21f962:	mov    r8,rdi
  21f965:	lea    rdi,[rsp+0x58]
  21f96a:	lea    rdx,[rsp+0xa0]
  21f972:	mov    r9,rbp
  21f975:	jmp    21fa89 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x449>
  21f97a:	cmp    r12,0x1
  21f97e:	jne    21faa1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21f984:	xor    edx,edx
  21f986:	cmp    QWORD PTR [rsp+0x10],0x1
  21f98c:	cmove  rdx,r14
  21f990:	cmp    rax,0x1
  21f994:	jne    21fa13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d3>
  21f996:	test   rdx,rdx
  21f999:	je     21fa13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d3>
  21f99b:	mov    QWORD PTR [rsp+0x98],rdi
  21f9a3:	mov    rax,QWORD PTR [rsp+0x20]
  21f9a8:	mov    QWORD PTR [rsp+0xa0],rax
  21f9b0:	mov    QWORD PTR [rsp+0xa8],rbp
  21f9b8:	mov    QWORD PTR [rsp+0xb0],r15
  21f9c0:	mov    QWORD PTR [rsp+0x50],rbx
  21f9c5:	mov    rax,QWORD PTR [rsp+0x28]
  21f9ca:	mov    QWORD PTR [rsp+0x58],rax
  21f9cf:	mov    QWORD PTR [rsp+0x60],r8
  21f9d4:	sub    rsp,0x8
  21f9d8:	movzx  eax,BYTE PTR [rsp+0x38]
  21f9dd:	movzx  edx,BYTE PTR [rsp+0x40]
  21f9e2:	movzx  r8d,BYTE PTR [rsp+0x20]
  21f9e8:	lea    rcx,[rsp+0xa0]
  21f9f0:	lea    r9,[rsp+0x58]
  21f9f5:	mov    rdi,r14
  21f9f8:	mov    rsi,r13
  21f9fb:	push   QWORD PTR [rsp+0x170]
  21fa02:	push   r11
  21fa04:	push   rax
  21fa05:	call   14cc30 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fa0a:	add    rsp,0x20
  21fa0e:	jmp    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fa13:	xor    edx,edx
  21fa15:	cmp    r8,0x1
  21fa19:	cmove  rdx,rbx
  21fa1d:	cmp    r15,0x1
  21fa21:	jne    21faa1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21fa23:	test   rdx,rdx
  21fa26:	je     21faa1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21fa28:	mov    QWORD PTR [rsp+0x98],rdi
  21fa30:	mov    rcx,QWORD PTR [rsp+0x20]
  21fa35:	mov    QWORD PTR [rsp+0xa0],rcx
  21fa3d:	mov    QWORD PTR [rsp+0xa8],rbp
  21fa45:	mov    QWORD PTR [rsp+0xb0],rax
  21fa4d:	mov    QWORD PTR [rsp+0x50],r14
  21fa52:	mov    QWORD PTR [rsp+0x58],r13
  21fa57:	mov    rax,QWORD PTR [rsp+0x10]
  21fa5c:	mov    QWORD PTR [rsp+0x60],rax
  21fa61:	sub    rsp,0x8
  21fa65:	movzx  eax,BYTE PTR [rsp+0x38]
  21fa6a:	mov    r8,rbx
  21fa6d:	movzx  esi,BYTE PTR [rsp+0x40]
  21fa72:	movzx  ecx,BYTE PTR [rsp+0x20]
  21fa77:	lea    rdi,[rsp+0x58]
  21fa7c:	lea    rdx,[rsp+0xa0]
  21fa84:	mov    r9,QWORD PTR [rsp+0x30]
  21fa89:	push   QWORD PTR [rsp+0x170]
  21fa90:	push   r11
  21fa92:	push   rax
  21fa93:	call   2041b0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fa98:	add    rsp,0x20
  21fa9c:	jmp    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21faa1:	cmp    QWORD PTR [rsp+0x28],0x1
  21faa7:	jne    21fbc1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21faad:	xor    edx,edx
  21faaf:	cmp    r9,0x1
  21fab3:	cmove  rdx,r14
  21fab7:	cmp    r10,0x1
  21fabb:	jne    21fb33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4f3>
  21fabd:	test   rdx,rdx
  21fac0:	je     21fb33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4f3>
  21fac2:	mov    QWORD PTR [rsp+0x98],rdx
  21faca:	mov    QWORD PTR [rsp+0xa0],r12
  21fad2:	mov    QWORD PTR [rsp+0xa8],r13
  21fada:	mov    rcx,QWORD PTR [rsp+0x10]
  21fadf:	mov    QWORD PTR [rsp+0xb0],rcx
  21fae7:	mov    QWORD PTR [rsp+0x50],rdi
  21faec:	mov    rcx,QWORD PTR [rsp+0x20]
  21faf1:	mov    QWORD PTR [rsp+0x58],rcx
  21faf6:	mov    QWORD PTR [rsp+0x60],rax
  21fafb:	sub    rsp,0x8
  21faff:	movzx  eax,BYTE PTR [rsp+0x20]
  21fb04:	mov    rdx,rbx
  21fb07:	movzx  esi,BYTE PTR [rsp+0x40]
  21fb0c:	movzx  r8d,BYTE PTR [rsp+0x38]
  21fb12:	lea    rdi,[rsp+0xa0]
  21fb1a:	lea    r9,[rsp+0x58]
  21fb1f:	mov    rcx,QWORD PTR [rsp+0x50]
  21fb24:	push   QWORD PTR [rsp+0x170]
  21fb2b:	push   r11
  21fb2d:	push   rax
  21fb2e:	jmp    21fbb3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x573>
  21fb33:	xor    edx,edx
  21fb35:	cmp    QWORD PTR [rsp+0x10],0x1
  21fb3b:	cmove  rdx,r14
  21fb3f:	cmp    rax,0x1
  21fb43:	jne    21fbc1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21fb45:	test   rdx,rdx
  21fb48:	je     21fbc1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21fb4a:	mov    QWORD PTR [rsp+0x98],rdx
  21fb52:	mov    QWORD PTR [rsp+0xa0],r13
  21fb5a:	mov    QWORD PTR [rsp+0xa8],r12
  21fb62:	mov    QWORD PTR [rsp+0xb0],r9
  21fb6a:	mov    QWORD PTR [rsp+0x50],rbx
  21fb6f:	mov    rax,QWORD PTR [rsp+0x48]
  21fb74:	mov    QWORD PTR [rsp+0x58],rax
  21fb79:	mov    QWORD PTR [rsp+0x60],r10
  21fb7e:	sub    rsp,0x8
  21fb82:	movzx  r10d,BYTE PTR [rsp+0x38]
  21fb88:	movzx  esi,BYTE PTR [rsp+0x40]
  21fb8d:	movzx  r8d,BYTE PTR [rsp+0x20]
  21fb93:	mov    rdx,rdi
  21fb96:	lea    rdi,[rsp+0xa0]
  21fb9e:	lea    r9,[rsp+0x58]
  21fba3:	mov    rcx,QWORD PTR [rsp+0x28]
  21fba8:	push   QWORD PTR [rsp+0x170]
  21fbaf:	push   r11
  21fbb1:	push   r10
  21fbb3:	call   14c810 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fbb8:	add    rsp,0x20
  21fbbc:	jmp    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fbc1:	mov    QWORD PTR [rsp+0x48],r15
  21fbc6:	mov    QWORD PTR [rsp+0x20],rax
  21fbcb:	movups xmm1,XMMWORD PTR [r11]
  21fbcf:	mov    rax,r12
  21fbd2:	mul    r13
  21fbd5:	mov    r11,rax
  21fbd8:	movaps XMMWORD PTR [rsp+0x50],xmm1
  21fbdd:	seto   r15b
  21fbe1:	jo     220043 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa03>
  21fbe7:	mul    QWORD PTR [rsp+0x28]
  21fbec:	seto   cl
  21fbef:	not    cl
  21fbf1:	cmp    rax,0x1001
  21fbf7:	setb   al
  21fbfa:	test   cl,al
  21fbfc:	mov    esi,DWORD PTR [rsp+0x38]
  21fc00:	jne    21fc6b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x62b>
  21fc02:	mov    rdx,QWORD PTR [rip+0x32c2af]        # 54beb8 <_DYNAMIC+0x450>
  21fc09:	mov    rax,QWORD PTR [rdx]
  21fc0c:	test   rax,rax
  21fc0f:	mov    QWORD PTR [rsp+0x68],rbx
  21fc14:	mov    rbx,r8
  21fc17:	je     22004f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0f>
  21fc1d:	mov    cl,0x1
  21fc1f:	test   eax,0x80000
  21fc24:	mov    rbp,QWORD PTR [rsp+0x168]
  21fc2c:	jne    22017a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb3a>
  21fc32:	mov    rax,QWORD PTR [rdx]
  21fc35:	test   rax,rax
  21fc38:	je     2200ba <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa7a>
  21fc3e:	test   ax,ax
  21fc41:	jns    21fc5a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  21fc43:	mov    rax,QWORD PTR [rdx]
  21fc46:	test   rax,rax
  21fc49:	je     22011e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xade>
  21fc4f:	bt     rax,0x37
  21fc54:	jb     220178 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb38>
  21fc5a:	test   sil,sil
  21fc5d:	jne    21fef3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8b3>
  21fc63:	xorps  xmm0,xmm0
  21fc66:	jmp    21fefb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8bb>
  21fc6b:	test   sil,sil
  21fc6e:	mov    rcx,QWORD PTR [rsp+0x48]
  21fc73:	jne    21fcd2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x692>
  21fc75:	xorps  xmm0,xmm0
  21fc78:	movsd  QWORD PTR [rsp+0x38],xmm0
  21fc7e:	mov    eax,DWORD PTR [rsp+0x18]
  21fc82:	cmp    QWORD PTR [rsp+0x10],r9
  21fc87:	jb     21fceb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6ab>
  21fc89:	mov    ebp,eax
  21fc8b:	mov    eax,DWORD PTR [rsp+0x30]
  21fc8f:	mov    r15,QWORD PTR [rsp+0x20]
  21fc94:	mov    QWORD PTR [rsp+0x30],rcx
  21fc99:	mov    QWORD PTR [rsp+0x18],rdi
  21fc9e:	mov    QWORD PTR [rsp+0x48],r8
  21fca3:	mov    rcx,r10
  21fca6:	mov    rdi,rbx
  21fca9:	mov    rdx,QWORD PTR [rsp+0x10]
  21fcae:	mov    QWORD PTR [rsp+0x68],rdx
  21fcb3:	mov    QWORD PTR [rsp+0x10],r9
  21fcb8:	mov    rbx,r13
  21fcbb:	mov    r13,r12
  21fcbe:	jmp    21fd0b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6cb>
  21fcc0:	cmp    r9,0x1
  21fcc4:	jne    21fe46 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x806>
  21fcca:	mov    rax,r12
  21fccd:	jmp    21ff60 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21fcd2:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1fefe]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  21fcda:	movsd  QWORD PTR [rsp+0x38],xmm0
  21fce0:	mov    eax,DWORD PTR [rsp+0x18]
  21fce4:	cmp    QWORD PTR [rsp+0x10],r9
  21fce9:	jae    21fc89 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x649>
  21fceb:	mov    ecx,DWORD PTR [rsp+0x30]
  21fcef:	mov    ebp,ecx
  21fcf1:	mov    r15,r10
  21fcf4:	mov    QWORD PTR [rsp+0x30],r8
  21fcf9:	mov    QWORD PTR [rsp+0x18],rbx
  21fcfe:	mov    QWORD PTR [rsp+0x68],r9
  21fd03:	mov    rbx,r12
  21fd06:	mov    rcx,QWORD PTR [rsp+0x20]
  21fd0b:	movaps XMMWORD PTR [rsp+0x80],xmm1
  21fd13:	mov    QWORD PTR [rsp+0x40],rdi
  21fd18:	mov    r12d,eax
  21fd1b:	mov    QWORD PTR [rsp+0x20],rcx
  21fd20:	cmp    rcx,0x1
  21fd24:	jne    21fd50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x710>
  21fd26:	cmp    QWORD PTR [rsp+0x10],0x1
  21fd2c:	jne    21fd50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x710>
  21fd2e:	lea    r8,[rip+0x320edb]        # 540c10 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x3e0>
  21fd35:	lea    rdi,[rsp+0x98]
  21fd3d:	mov    rsi,r13
  21fd40:	mov    rdx,rbx
  21fd43:	mov    rcx,QWORD PTR [rsp+0x28]
  21fd48:	call   QWORD PTR [rip+0x32c46a]        # 54c1b8 <_DYNAMIC+0x750>
  21fd4e:	jmp    21fd70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x730>
  21fd50:	lea    r8,[rip+0x320ed1]        # 540c28 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x3f8>
  21fd57:	lea    rdi,[rsp+0x98]
  21fd5f:	mov    rsi,r13
  21fd62:	mov    rdx,rbx
  21fd65:	mov    rcx,QWORD PTR [rsp+0x28]
  21fd6a:	call   QWORD PTR [rip+0x32c450]        # 54c1c0 <_DYNAMIC+0x758>
  21fd70:	lea    rdi,[rsp+0xa0]
  21fd78:	mov    rsi,QWORD PTR [rsp+0xc0]
  21fd80:	mov    rdx,QWORD PTR [rsp+0xc8]
  21fd88:	movups xmm0,XMMWORD PTR [rsp+0xd0]
  21fd90:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  21fd98:	movaps xmm3,xmm2
  21fd9b:	unpckhpd xmm3,xmm2
  21fd9f:	sub    rsp,0x70
  21fda3:	movups XMMWORD PTR [rsp+0x58],xmm0
  21fda8:	movzx  eax,bpl
  21fdac:	mov    DWORD PTR [rsp+0x50],eax
  21fdb0:	movzx  eax,r12b
  21fdb4:	mov    DWORD PTR [rsp+0x48],eax
  21fdb8:	mov    QWORD PTR [rsp+0x40],r15
  21fdbd:	mov    rax,QWORD PTR [rsp+0xa0]
  21fdc5:	mov    QWORD PTR [rsp+0x38],rax
  21fdca:	mov    rax,QWORD PTR [rsp+0x88]
  21fdd2:	mov    QWORD PTR [rsp+0x30],rax
  21fdd7:	mov    rax,QWORD PTR [rsp+0xb8]
  21fddf:	mov    QWORD PTR [rsp+0x28],rax
  21fde4:	mov    rax,QWORD PTR [rsp+0x90]
  21fdec:	mov    QWORD PTR [rsp+0x20],rax
  21fdf1:	mov    rax,QWORD PTR [rsp+0xb0]
  21fdf9:	mov    QWORD PTR [rsp+0x18],rax
  21fdfe:	mov    rax,QWORD PTR [rsp+0xd8]
  21fe06:	mov    QWORD PTR [rsp+0x10],rax
  21fe0b:	mov    rax,QWORD PTR [rsp+0x80]
  21fe13:	mov    QWORD PTR [rsp+0x8],rax
  21fe18:	mov    QWORD PTR [rsp],r14
  21fe1c:	xorps  xmm1,xmm1
  21fe1f:	mov    r8,rbx
  21fe22:	mov    r9,QWORD PTR [rsp+0x98]
  21fe2a:	mov    rcx,r13
  21fe2d:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  21fe36:	call   QWORD PTR [rsp+0x108]
  21fe3d:	add    rsp,0x70
  21fe41:	jmp    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fe46:	lea    rax,[r12-0x1]
  21fe4b:	mov    ecx,r12d
  21fe4e:	and    ecx,0x3
  21fe51:	and    r12,0xfffffffffffffffc
  21fe55:	mov    rdx,r9
  21fe58:	shl    rdx,0x4
  21fe5c:	lea    rsi,[rdx+rdx*2]
  21fe60:	shl    QWORD PTR [rsp+0x10],0x4
  21fe66:	mov    rdi,r9
  21fe69:	shl    rdi,0x6
  21fe6d:	shl    r9,0x5
  21fe71:	xor    r8d,r8d
  21fe74:	xorps  xmm0,xmm0
  21fe77:	jmp    21fe91 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x851>
  21fe79:	nop    DWORD PTR [rax+0x0]
  21fe80:	inc    r8
  21fe83:	add    r14,QWORD PTR [rsp+0x10]
  21fe88:	cmp    r8,r13
  21fe8b:	je     22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fe91:	cmp    rax,0x3
  21fe95:	jae    21fea0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  21fe97:	xor    r10d,r10d
  21fe9a:	jmp    21fed4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x894>
  21fe9c:	nop    DWORD PTR [rax+0x0]
  21fea0:	mov    r11,r14
  21fea3:	xor    r10d,r10d
  21fea6:	cs nop WORD PTR [rax+rax*1+0x0]
  21feb0:	movups XMMWORD PTR [r11],xmm0
  21feb4:	movups XMMWORD PTR [r11+rdx*1],xmm0
  21feb9:	movups XMMWORD PTR [r11+r9*1],xmm0
  21febe:	add    r10,0x4
  21fec2:	movups XMMWORD PTR [r11+rsi*1],xmm0
  21fec7:	add    r11,rdi
  21feca:	cmp    r12,r10
  21fecd:	jne    21feb0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
  21fecf:	test   rcx,rcx
  21fed2:	je     21fe80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  21fed4:	imul   r10,rdx
  21fed8:	add    r10,r14
  21fedb:	mov    r11,rcx
  21fede:	xchg   ax,ax
  21fee0:	movups XMMWORD PTR [r10],xmm0
  21fee4:	add    r10,rdx
  21fee7:	dec    r11
  21feea:	jne    21fee0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a0>
  21feec:	jmp    21fe80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  21feee:	mov    rax,r12
  21fef1:	jmp    21ff51 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x911>
  21fef3:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1fcdd]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  21fefb:	mov    eax,DWORD PTR [rsp+0x18]
  21feff:	mov    QWORD PTR [rsp+0x18],r10
  21ff04:	mov    QWORD PTR [rsp+0x40],rdi
  21ff09:	movaps xmm2,xmm1
  21ff0c:	unpckhpd xmm2,xmm1
  21ff10:	test   rbp,rbp
  21ff13:	je     21fff1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9b1>
  21ff19:	sub    rsp,0x8
  21ff1d:	movzx  r10d,al
  21ff21:	movzx  r11d,BYTE PTR [rsp+0x38]
  21ff27:	movzx  eax,sil
  21ff2b:	mov    rdi,r12
  21ff2e:	mov    rsi,r13
  21ff31:	mov    rdx,QWORD PTR [rsp+0x30]
  21ff36:	mov    rcx,r14
  21ff39:	mov    r8,QWORD PTR [rsp+0x18]
  21ff3e:	push   rbp
  21ff3f:	push   0x1
  21ff41:	jmp    220018 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d8>
  21ff46:	mov    rax,r13
  21ff49:	mov    r13,r12
  21ff4c:	mov    QWORD PTR [rsp+0x10],r9
  21ff51:	mov    ecx,0x1
  21ff56:	sub    rcx,rax
  21ff59:	shl    rcx,0x4
  21ff5d:	add    r14,rcx
  21ff60:	lea    rcx,[rax-0x1]
  21ff64:	mov    edx,eax
  21ff66:	and    edx,0x3
  21ff69:	and    rax,0xfffffffffffffffc
  21ff6d:	xor    esi,esi
  21ff6f:	xorps  xmm0,xmm0
  21ff72:	jmp    21ff8c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x94c>
  21ff74:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  21ff80:	inc    rsi
  21ff83:	cmp    rsi,r13
  21ff86:	je     22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21ff8c:	mov    rdi,rsi
  21ff8f:	imul   rdi,QWORD PTR [rsp+0x10]
  21ff95:	shl    rdi,0x4
  21ff99:	add    rdi,r14
  21ff9c:	cmp    rcx,0x3
  21ffa0:	jb     21ffd1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x991>
  21ffa2:	xor    r8d,r8d
  21ffa5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  21ffb0:	movups XMMWORD PTR [rdi],xmm0
  21ffb3:	movups XMMWORD PTR [rdi+0x10],xmm0
  21ffb7:	movups XMMWORD PTR [rdi+0x20],xmm0
  21ffbb:	movups XMMWORD PTR [rdi+0x30],xmm0
  21ffbf:	add    rdi,0x40
  21ffc3:	add    r8,0x4
  21ffc7:	cmp    rax,r8
  21ffca:	jne    21ffb0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x970>
  21ffcc:	test   rdx,rdx
  21ffcf:	je     21ff80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x940>
  21ffd1:	xor    r8d,r8d
  21ffd4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  21ffe0:	movups XMMWORD PTR [rdi],xmm0
  21ffe3:	add    rdi,0x10
  21ffe7:	inc    r8
  21ffea:	cmp    rdx,r8
  21ffed:	jne    21ffe0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a0>
  21ffef:	jmp    21ff80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x940>
  21fff1:	sub    rsp,0x10
  21fff5:	movzx  r10d,al
  21fff9:	movzx  r11d,BYTE PTR [rsp+0x40]
  21ffff:	movzx  eax,sil
  220003:	mov    rdi,r12
  220006:	mov    rsi,r13
  220009:	mov    rdx,QWORD PTR [rsp+0x38]
  22000e:	mov    rcx,r14
  220011:	mov    r8,QWORD PTR [rsp+0x20]
  220016:	push   0x0
  220018:	push   r10
  22001a:	push   r11
  22001c:	push   QWORD PTR [rsp+0x70]
  220020:	push   QWORD PTR [rsp+0x50]
  220024:	push   QWORD PTR [rsp+0x78]
  220028:	push   QWORD PTR [rsp+0x58]
  22002c:	push   rbx
  22002d:	push   QWORD PTR [rsp+0xb8]
  220034:	push   rax
  220035:	call   20af50 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  22003a:	add    rsp,0x60
  22003e:	jmp    22028f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  220043:	mov    rax,0xffffffffffffffff
  22004a:	jmp    21fbe7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a7>
  22004f:	mov    QWORD PTR [rsp+0x78],r9
  220054:	mov    QWORD PTR [rsp+0x40],rdi
  220059:	mov    QWORD PTR [rsp+0x70],r13
  22005e:	mov    ebp,r15d
  220061:	mov    r15,r10
  220064:	movaps XMMWORD PTR [rsp+0x80],xmm1
  22006c:	mov    r13,r11
  22006f:	call   QWORD PTR [rip+0x32be4b]        # 54bec0 <_DYNAMIC+0x458>
  220075:	mov    rdx,QWORD PTR [rip+0x32be3c]        # 54beb8 <_DYNAMIC+0x450>
  22007c:	mov    r11,r13
  22007f:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  220087:	mov    r10,r15
  22008a:	mov    r15d,ebp
  22008d:	mov    r13,QWORD PTR [rsp+0x70]
  220092:	mov    esi,DWORD PTR [rsp+0x38]
  220096:	mov    rdi,QWORD PTR [rsp+0x40]
  22009b:	mov    r9,QWORD PTR [rsp+0x78]
  2200a0:	mov    cl,0x1
  2200a2:	test   eax,0x80000
  2200a7:	mov    rbp,QWORD PTR [rsp+0x168]
  2200af:	je     21fc32 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5f2>
  2200b5:	jmp    22017a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb3a>
  2200ba:	mov    QWORD PTR [rsp+0x78],r9
  2200bf:	mov    QWORD PTR [rsp+0x40],rdi
  2200c4:	mov    QWORD PTR [rsp+0x70],r13
  2200c9:	mov    BYTE PTR [rsp+0xf],r15b
  2200ce:	mov    r15,r10
  2200d1:	movaps XMMWORD PTR [rsp+0x80],xmm1
  2200d9:	mov    r13,r11
  2200dc:	call   QWORD PTR [rip+0x32bdde]        # 54bec0 <_DYNAMIC+0x458>
  2200e2:	mov    rdx,QWORD PTR [rip+0x32bdcf]        # 54beb8 <_DYNAMIC+0x450>
  2200e9:	mov    r11,r13
  2200ec:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  2200f4:	mov    r10,r15
  2200f7:	movzx  r15d,BYTE PTR [rsp+0xf]
  2200fd:	mov    r13,QWORD PTR [rsp+0x70]
  220102:	mov    esi,DWORD PTR [rsp+0x38]
  220106:	mov    rdi,QWORD PTR [rsp+0x40]
  22010b:	mov    r9,QWORD PTR [rsp+0x78]
  220110:	test   ax,ax
  220113:	js     21fc43 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x603>
  220119:	jmp    21fc5a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  22011e:	mov    QWORD PTR [rsp+0x78],r9
  220123:	mov    QWORD PTR [rsp+0x40],rdi
  220128:	mov    QWORD PTR [rsp+0x70],r13
  22012d:	mov    BYTE PTR [rsp+0xf],r15b
  220132:	mov    r15,r10
  220135:	movaps XMMWORD PTR [rsp+0x80],xmm1
  22013d:	mov    r13,r11
  220140:	call   QWORD PTR [rip+0x32bd7a]        # 54bec0 <_DYNAMIC+0x458>
  220146:	mov    r11,r13
  220149:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  220151:	mov    r10,r15
  220154:	movzx  r15d,BYTE PTR [rsp+0xf]
  22015a:	mov    r13,QWORD PTR [rsp+0x70]
  22015f:	mov    esi,DWORD PTR [rsp+0x38]
  220163:	mov    rdi,QWORD PTR [rsp+0x40]
  220168:	mov    r9,QWORD PTR [rsp+0x78]
  22016d:	bt     rax,0x37
  220172:	jae    21fc5a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  220178:	xor    ecx,ecx
  22017a:	test   r15b,r15b
  22017d:	jne    2202a1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc61>
  220183:	mov    rax,r11
  220186:	mul    QWORD PTR [rsp+0x28]
  22018b:	jo     2202b6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc76>
  220191:	mov    rdx,rax
  220194:	shr    rdx,0x3d
  220198:	jne    2202b6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc76>
  22019e:	shl    rax,0x3
  2201a2:	mov    rdx,QWORD PTR [rip+0x32bd27]        # 54bed0 <_DYNAMIC+0x468>
  2201a9:	mov    r8,QWORD PTR [rdx]
  2201ac:	add    r8,r8
  2201af:	mov    edx,0x1
  2201b4:	cmp    rax,r8
  2201b7:	jb     2201c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb84>
  2201b9:	cmp    rbp,0x1
  2201bd:	adc    rbp,0x0
  2201c1:	mov    rdx,rbp
  2201c4:	sub    rsp,0xa0
  2201cb:	mov    QWORD PTR [rsp+0x90],rdx
  2201d3:	lea    rax,[rsp+0xf0]
  2201db:	mov    QWORD PTR [rsp+0x88],rax
  2201e3:	movzx  eax,BYTE PTR [rsp+0xb8]
  2201eb:	mov    DWORD PTR [rsp+0x80],eax
  2201f2:	mov    rax,QWORD PTR [rsp+0xc0]
  2201fa:	mov    QWORD PTR [rsp+0x78],rax
  2201ff:	mov    rax,QWORD PTR [rsp+0xe8]
  220207:	mov    QWORD PTR [rsp+0x70],rax
  22020c:	mov    QWORD PTR [rsp+0x68],rdi
  220211:	xorps  xmm0,xmm0
  220214:	movups XMMWORD PTR [rsp+0x58],xmm0
  220219:	movzx  eax,BYTE PTR [rsp+0xd0]
  220221:	mov    DWORD PTR [rsp+0x50],eax
  220225:	mov    QWORD PTR [rsp+0x48],rbx
  22022a:	mov    QWORD PTR [rsp+0x40],r10
  22022f:	mov    rax,QWORD PTR [rsp+0x108]
  220237:	mov    QWORD PTR [rsp+0x38],rax
  22023c:	movzx  eax,sil
  220240:	mov    DWORD PTR [rsp+0x30],eax
  220244:	movups XMMWORD PTR [rsp+0x18],xmm0
  220249:	mov    rax,QWORD PTR [rsp+0xb0]
  220251:	mov    QWORD PTR [rsp+0x10],rax
  220256:	mov    QWORD PTR [rsp+0x8],r9
  22025b:	mov    QWORD PTR [rsp],r14
  22025f:	mov    DWORD PTR [rsp+0x28],0x2
  220267:	movzx  edx,cl
  22026a:	mov    r8,r13
  22026d:	mov    edi,0x3
  220272:	mov    r9,QWORD PTR [rsp+0xc8]
  22027a:	mov    esi,0x1
  22027f:	mov    rcx,r12
  220282:	call   QWORD PTR [rip+0x32bc40]        # 54bec8 <_DYNAMIC+0x460>
  220288:	add    rsp,0xa0
  22028f:	add    rsp,0x128
  220296:	pop    rbx
  220297:	pop    r12
  220299:	pop    r13
  22029b:	pop    r14
  22029d:	pop    r15
  22029f:	pop    rbp
  2202a0:	ret
  2202a1:	mov    r11,0xffffffffffffffff
  2202a8:	mov    rax,r11
  2202ab:	mul    QWORD PTR [rsp+0x28]
  2202b0:	jno    220191 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb51>
  2202b6:	mov    rax,QWORD PTR [rip+0x32bc13]        # 54bed0 <_DYNAMIC+0x468>
  2202bd:	mov    rax,QWORD PTR [rax]
  2202c0:	jmp    2201b9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb79>
