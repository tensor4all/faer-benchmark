
target/faer-rev/7cd372f40449-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000021f660 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  21f660:	push   rbp
  21f661:	push   r15
  21f663:	push   r14
  21f665:	push   r13
  21f667:	push   r12
  21f669:	push   rbx
  21f66a:	sub    rsp,0x128
  21f671:	mov    DWORD PTR [rsp+0x30],ecx
  21f675:	mov    r12,QWORD PTR [rdi+0x8]
  21f679:	test   r12,r12
  21f67c:	je     2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f682:	mov    r13,QWORD PTR [rdi+0x10]
  21f686:	test   r13,r13
  21f689:	je     2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f68f:	mov    eax,r9d
  21f692:	mov    r14,QWORD PTR [rdi]
  21f695:	mov    r9,QWORD PTR [rdi+0x18]
  21f699:	mov    rcx,QWORD PTR [rdi+0x20]
  21f69d:	mov    QWORD PTR [rsp+0x10],rcx
  21f6a2:	mov    rcx,QWORD PTR [rdx+0x10]
  21f6a6:	mov    QWORD PTR [rsp+0x28],rcx
  21f6ab:	test   rcx,rcx
  21f6ae:	je     21f754 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
  21f6b4:	mov    DWORD PTR [rsp+0x18],eax
  21f6b8:	mov    rbx,QWORD PTR [rdx]
  21f6bb:	mov    rbp,QWORD PTR [rdx+0x8]
  21f6bf:	mov    r10,QWORD PTR [rdx+0x18]
  21f6c3:	test   r9,r9
  21f6c6:	jns    21f704 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4>
  21f6c8:	lea    rax,[r12-0x1]
  21f6cd:	imul   rax,r9
  21f6d1:	shl    rax,0x4
  21f6d5:	add    r14,rax
  21f6d8:	neg    r9
  21f6db:	xor    eax,eax
  21f6dd:	mov    ecx,esi
  21f6df:	mov    rsi,rbp
  21f6e2:	sub    rsi,0x1
  21f6e6:	cmovb  rsi,rax
  21f6ea:	mov    rdi,r10
  21f6ed:	imul   rdi,rsi
  21f6f1:	cmp    rsi,rbp
  21f6f4:	mov    esi,ecx
  21f6f6:	cmove  rdi,rax
  21f6fa:	shl    rdi,0x4
  21f6fe:	add    rbx,rdi
  21f701:	neg    r10
  21f704:	mov    QWORD PTR [rsp+0x48],rbp
  21f709:	mov    rcx,QWORD PTR [rdx+0x20]
  21f70d:	mov    rdi,QWORD PTR [r8]
  21f710:	mov    rbp,QWORD PTR [r8+0x8]
  21f714:	mov    r11,QWORD PTR [r8+0x10]
  21f718:	mov    rax,QWORD PTR [r8+0x20]
  21f71c:	cmp    QWORD PTR [rsp+0x10],0x0
  21f722:	mov    QWORD PTR [rsp+0x20],r11
  21f727:	mov    DWORD PTR [rsp+0x38],esi
  21f72b:	js     21f7a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x149>
  21f72d:	mov    r15,QWORD PTR [r8+0x18]
  21f731:	mov    r8,rcx
  21f734:	test   rcx,rcx
  21f737:	js     21f82b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1cb>
  21f73d:	mov    r11,QWORD PTR [rsp+0x160]
  21f745:	cmp    r13,0x1
  21f749:	je     21f8af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x24f>
  21f74f:	jmp    21f99a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f754:	test   sil,sil
  21f757:	jne    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21f75d:	cmp    r12,0x1
  21f761:	je     21f777 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
  21f763:	cmp    r9,0xffffffffffffffff
  21f767:	je     21ff0e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  21f76d:	cmp    r9,0x1
  21f771:	je     21fcea <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x68a>
  21f777:	cmp    r13,0x1
  21f77b:	je     21fce0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x680>
  21f781:	cmp    QWORD PTR [rsp+0x10],0xffffffffffffffff
  21f787:	je     21ff66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x906>
  21f78d:	cmp    QWORD PTR [rsp+0x10],0x1
  21f793:	jne    21fce0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x680>
  21f799:	mov    rax,r13
  21f79c:	mov    r13,r12
  21f79f:	mov    QWORD PTR [rsp+0x10],r9
  21f7a4:	jmp    21ff80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21f7a9:	lea    rdx,[r13-0x1]
  21f7ad:	mov    QWORD PTR [rsp+0x40],rdi
  21f7b2:	mov    rdi,rbx
  21f7b5:	mov    rbx,QWORD PTR [rsp+0x10]
  21f7ba:	imul   rdx,rbx
  21f7be:	shl    rdx,0x4
  21f7c2:	add    r14,rdx
  21f7c5:	neg    rbx
  21f7c8:	mov    QWORD PTR [rsp+0x10],rbx
  21f7cd:	xor    edx,edx
  21f7cf:	mov    r15,r10
  21f7d2:	mov    r10,rbp
  21f7d5:	mov    rbp,r13
  21f7d8:	mov    r13,rdi
  21f7db:	mov    rsi,r11
  21f7de:	sub    rsi,0x1
  21f7e2:	cmovb  rsi,rdx
  21f7e6:	mov    r11,QWORD PTR [rsp+0x40]
  21f7eb:	mov    rdi,rax
  21f7ee:	imul   rdi,rsi
  21f7f2:	cmp    rsi,QWORD PTR [rsp+0x20]
  21f7f7:	mov    rbx,r13
  21f7fa:	mov    r13,rbp
  21f7fd:	mov    rbp,r10
  21f800:	mov    r10,r15
  21f803:	cmove  rdi,rdx
  21f807:	test   rbp,rbp
  21f80a:	cmove  rdi,rbp
  21f80e:	shl    rdi,0x4
  21f812:	add    r11,rdi
  21f815:	mov    rdi,r11
  21f818:	neg    rax
  21f81b:	mov    r15,QWORD PTR [r8+0x18]
  21f81f:	mov    r8,rcx
  21f822:	test   rcx,rcx
  21f825:	jns    21f73d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xdd>
  21f82b:	mov    rcx,QWORD PTR [rsp+0x28]
  21f830:	lea    rdx,[rcx-0x1]
  21f834:	imul   rdx,r8
  21f838:	mov    rcx,QWORD PTR [rsp+0x48]
  21f83d:	test   rcx,rcx
  21f840:	cmove  rdx,rcx
  21f844:	shl    rdx,0x4
  21f848:	add    rbx,rdx
  21f84b:	neg    r8
  21f84e:	xor    edx,edx
  21f850:	mov    r11,rbx
  21f853:	mov    rbx,r10
  21f856:	mov    r10,rbp
  21f859:	sub    r10,0x1
  21f85d:	cmovb  r10,rdx
  21f861:	mov    rcx,r8
  21f864:	mov    r8,rdi
  21f867:	mov    rdi,r15
  21f86a:	imul   rdi,r10
  21f86e:	mov    rsi,rbp
  21f871:	mov    rbp,QWORD PTR [rsp+0x20]
  21f876:	test   rbp,rbp
  21f879:	cmove  rdi,rbp
  21f87d:	mov    rbp,rsi
  21f880:	cmp    r10,rsi
  21f883:	mov    r10,rbx
  21f886:	mov    rbx,r11
  21f889:	cmove  rdi,rdx
  21f88d:	shl    rdi,0x4
  21f891:	add    r8,rdi
  21f894:	mov    rdi,r8
  21f897:	mov    r8,rcx
  21f89a:	neg    r15
  21f89d:	mov    r11,QWORD PTR [rsp+0x160]
  21f8a5:	cmp    r13,0x1
  21f8a9:	jne    21f99a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f8af:	cmp    r10,0x1
  21f8b3:	jne    21f925 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f8b5:	cmp    r9,0x1
  21f8b9:	jne    21f925 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f8bb:	test   r14,r14
  21f8be:	je     21f925 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2c5>
  21f8c0:	mov    QWORD PTR [rsp+0x98],rbx
  21f8c8:	mov    rax,QWORD PTR [rsp+0x48]
  21f8cd:	mov    QWORD PTR [rsp+0xa0],rax
  21f8d5:	mov    rax,QWORD PTR [rsp+0x28]
  21f8da:	mov    QWORD PTR [rsp+0xa8],rax
  21f8e2:	mov    QWORD PTR [rsp+0xb0],r8
  21f8ea:	mov    QWORD PTR [rsp+0x50],rdi
  21f8ef:	mov    QWORD PTR [rsp+0x58],rbp
  21f8f4:	mov    QWORD PTR [rsp+0x60],r15
  21f8f9:	sub    rsp,0x8
  21f8fd:	movzx  eax,BYTE PTR [rsp+0x20]
  21f902:	movzx  edx,BYTE PTR [rsp+0x40]
  21f907:	movzx  r8d,BYTE PTR [rsp+0x38]
  21f90d:	lea    rcx,[rsp+0xa0]
  21f915:	lea    r9,[rsp+0x58]
  21f91a:	mov    rdi,r14
  21f91d:	mov    rsi,r12
  21f920:	jmp    21fa1b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3bb>
  21f925:	cmp    r8,0x1
  21f929:	jne    21f99a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f92b:	cmp    r15,0x1
  21f92f:	jne    21f99a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f931:	test   rdi,rdi
  21f934:	je     21f99a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x33a>
  21f936:	mov    QWORD PTR [rsp+0x98],rbx
  21f93e:	mov    rax,QWORD PTR [rsp+0x48]
  21f943:	mov    QWORD PTR [rsp+0xa0],rax
  21f94b:	mov    rax,QWORD PTR [rsp+0x28]
  21f950:	mov    QWORD PTR [rsp+0xa8],rax
  21f958:	mov    QWORD PTR [rsp+0xb0],r10
  21f960:	mov    QWORD PTR [rsp+0x50],r14
  21f965:	mov    QWORD PTR [rsp+0x58],r12
  21f96a:	mov    QWORD PTR [rsp+0x60],r9
  21f96f:	sub    rsp,0x8
  21f973:	movzx  eax,BYTE PTR [rsp+0x20]
  21f978:	movzx  esi,BYTE PTR [rsp+0x40]
  21f97d:	movzx  ecx,BYTE PTR [rsp+0x38]
  21f982:	mov    r8,rdi
  21f985:	lea    rdi,[rsp+0x58]
  21f98a:	lea    rdx,[rsp+0xa0]
  21f992:	mov    r9,rbp
  21f995:	jmp    21faa9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x449>
  21f99a:	cmp    r12,0x1
  21f99e:	jne    21fac1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21f9a4:	xor    edx,edx
  21f9a6:	cmp    QWORD PTR [rsp+0x10],0x1
  21f9ac:	cmove  rdx,r14
  21f9b0:	cmp    rax,0x1
  21f9b4:	jne    21fa33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d3>
  21f9b6:	test   rdx,rdx
  21f9b9:	je     21fa33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d3>
  21f9bb:	mov    QWORD PTR [rsp+0x98],rdi
  21f9c3:	mov    rax,QWORD PTR [rsp+0x20]
  21f9c8:	mov    QWORD PTR [rsp+0xa0],rax
  21f9d0:	mov    QWORD PTR [rsp+0xa8],rbp
  21f9d8:	mov    QWORD PTR [rsp+0xb0],r15
  21f9e0:	mov    QWORD PTR [rsp+0x50],rbx
  21f9e5:	mov    rax,QWORD PTR [rsp+0x28]
  21f9ea:	mov    QWORD PTR [rsp+0x58],rax
  21f9ef:	mov    QWORD PTR [rsp+0x60],r8
  21f9f4:	sub    rsp,0x8
  21f9f8:	movzx  eax,BYTE PTR [rsp+0x38]
  21f9fd:	movzx  edx,BYTE PTR [rsp+0x40]
  21fa02:	movzx  r8d,BYTE PTR [rsp+0x20]
  21fa08:	lea    rcx,[rsp+0xa0]
  21fa10:	lea    r9,[rsp+0x58]
  21fa15:	mov    rdi,r14
  21fa18:	mov    rsi,r13
  21fa1b:	push   QWORD PTR [rsp+0x170]
  21fa22:	push   r11
  21fa24:	push   rax
  21fa25:	call   14cc30 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fa2a:	add    rsp,0x20
  21fa2e:	jmp    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fa33:	xor    edx,edx
  21fa35:	cmp    r8,0x1
  21fa39:	cmove  rdx,rbx
  21fa3d:	cmp    r15,0x1
  21fa41:	jne    21fac1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21fa43:	test   rdx,rdx
  21fa46:	je     21fac1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x461>
  21fa48:	mov    QWORD PTR [rsp+0x98],rdi
  21fa50:	mov    rcx,QWORD PTR [rsp+0x20]
  21fa55:	mov    QWORD PTR [rsp+0xa0],rcx
  21fa5d:	mov    QWORD PTR [rsp+0xa8],rbp
  21fa65:	mov    QWORD PTR [rsp+0xb0],rax
  21fa6d:	mov    QWORD PTR [rsp+0x50],r14
  21fa72:	mov    QWORD PTR [rsp+0x58],r13
  21fa77:	mov    rax,QWORD PTR [rsp+0x10]
  21fa7c:	mov    QWORD PTR [rsp+0x60],rax
  21fa81:	sub    rsp,0x8
  21fa85:	movzx  eax,BYTE PTR [rsp+0x38]
  21fa8a:	mov    r8,rbx
  21fa8d:	movzx  esi,BYTE PTR [rsp+0x40]
  21fa92:	movzx  ecx,BYTE PTR [rsp+0x20]
  21fa97:	lea    rdi,[rsp+0x58]
  21fa9c:	lea    rdx,[rsp+0xa0]
  21faa4:	mov    r9,QWORD PTR [rsp+0x30]
  21faa9:	push   QWORD PTR [rsp+0x170]
  21fab0:	push   r11
  21fab2:	push   rax
  21fab3:	call   2041d0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fab8:	add    rsp,0x20
  21fabc:	jmp    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fac1:	cmp    QWORD PTR [rsp+0x28],0x1
  21fac7:	jne    21fbe1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21facd:	xor    edx,edx
  21facf:	cmp    r9,0x1
  21fad3:	cmove  rdx,r14
  21fad7:	cmp    r10,0x1
  21fadb:	jne    21fb53 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4f3>
  21fadd:	test   rdx,rdx
  21fae0:	je     21fb53 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4f3>
  21fae2:	mov    QWORD PTR [rsp+0x98],rdx
  21faea:	mov    QWORD PTR [rsp+0xa0],r12
  21faf2:	mov    QWORD PTR [rsp+0xa8],r13
  21fafa:	mov    rcx,QWORD PTR [rsp+0x10]
  21faff:	mov    QWORD PTR [rsp+0xb0],rcx
  21fb07:	mov    QWORD PTR [rsp+0x50],rdi
  21fb0c:	mov    rcx,QWORD PTR [rsp+0x20]
  21fb11:	mov    QWORD PTR [rsp+0x58],rcx
  21fb16:	mov    QWORD PTR [rsp+0x60],rax
  21fb1b:	sub    rsp,0x8
  21fb1f:	movzx  eax,BYTE PTR [rsp+0x20]
  21fb24:	mov    rdx,rbx
  21fb27:	movzx  esi,BYTE PTR [rsp+0x40]
  21fb2c:	movzx  r8d,BYTE PTR [rsp+0x38]
  21fb32:	lea    rdi,[rsp+0xa0]
  21fb3a:	lea    r9,[rsp+0x58]
  21fb3f:	mov    rcx,QWORD PTR [rsp+0x50]
  21fb44:	push   QWORD PTR [rsp+0x170]
  21fb4b:	push   r11
  21fb4d:	push   rax
  21fb4e:	jmp    21fbd3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x573>
  21fb53:	xor    edx,edx
  21fb55:	cmp    QWORD PTR [rsp+0x10],0x1
  21fb5b:	cmove  rdx,r14
  21fb5f:	cmp    rax,0x1
  21fb63:	jne    21fbe1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21fb65:	test   rdx,rdx
  21fb68:	je     21fbe1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x581>
  21fb6a:	mov    QWORD PTR [rsp+0x98],rdx
  21fb72:	mov    QWORD PTR [rsp+0xa0],r13
  21fb7a:	mov    QWORD PTR [rsp+0xa8],r12
  21fb82:	mov    QWORD PTR [rsp+0xb0],r9
  21fb8a:	mov    QWORD PTR [rsp+0x50],rbx
  21fb8f:	mov    rax,QWORD PTR [rsp+0x48]
  21fb94:	mov    QWORD PTR [rsp+0x58],rax
  21fb99:	mov    QWORD PTR [rsp+0x60],r10
  21fb9e:	sub    rsp,0x8
  21fba2:	movzx  r10d,BYTE PTR [rsp+0x38]
  21fba8:	movzx  esi,BYTE PTR [rsp+0x40]
  21fbad:	movzx  r8d,BYTE PTR [rsp+0x20]
  21fbb3:	mov    rdx,rdi
  21fbb6:	lea    rdi,[rsp+0xa0]
  21fbbe:	lea    r9,[rsp+0x58]
  21fbc3:	mov    rcx,QWORD PTR [rsp+0x28]
  21fbc8:	push   QWORD PTR [rsp+0x170]
  21fbcf:	push   r11
  21fbd1:	push   r10
  21fbd3:	call   14c810 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  21fbd8:	add    rsp,0x20
  21fbdc:	jmp    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fbe1:	mov    QWORD PTR [rsp+0x48],r15
  21fbe6:	mov    QWORD PTR [rsp+0x20],rax
  21fbeb:	movups xmm1,XMMWORD PTR [r11]
  21fbef:	mov    rax,r12
  21fbf2:	mul    r13
  21fbf5:	mov    r11,rax
  21fbf8:	movaps XMMWORD PTR [rsp+0x50],xmm1
  21fbfd:	seto   r15b
  21fc01:	jo     220063 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa03>
  21fc07:	mul    QWORD PTR [rsp+0x28]
  21fc0c:	seto   cl
  21fc0f:	not    cl
  21fc11:	cmp    rax,0x1001
  21fc17:	setb   al
  21fc1a:	test   cl,al
  21fc1c:	mov    esi,DWORD PTR [rsp+0x38]
  21fc20:	jne    21fc8b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x62b>
  21fc22:	mov    rdx,QWORD PTR [rip+0x32c28f]        # 54beb8 <_DYNAMIC+0x450>
  21fc29:	mov    rax,QWORD PTR [rdx]
  21fc2c:	test   rax,rax
  21fc2f:	mov    QWORD PTR [rsp+0x68],rbx
  21fc34:	mov    rbx,r8
  21fc37:	je     22006f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0f>
  21fc3d:	mov    cl,0x1
  21fc3f:	test   eax,0x80000
  21fc44:	mov    rbp,QWORD PTR [rsp+0x168]
  21fc4c:	jne    22019a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb3a>
  21fc52:	mov    rax,QWORD PTR [rdx]
  21fc55:	test   rax,rax
  21fc58:	je     2200da <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa7a>
  21fc5e:	test   ax,ax
  21fc61:	jns    21fc7a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  21fc63:	mov    rax,QWORD PTR [rdx]
  21fc66:	test   rax,rax
  21fc69:	je     22013e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xade>
  21fc6f:	bt     rax,0x37
  21fc74:	jb     220198 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb38>
  21fc7a:	test   sil,sil
  21fc7d:	jne    21ff13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8b3>
  21fc83:	xorps  xmm0,xmm0
  21fc86:	jmp    21ff1b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8bb>
  21fc8b:	test   sil,sil
  21fc8e:	mov    rcx,QWORD PTR [rsp+0x48]
  21fc93:	jne    21fcf2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x692>
  21fc95:	xorps  xmm0,xmm0
  21fc98:	movsd  QWORD PTR [rsp+0x38],xmm0
  21fc9e:	mov    eax,DWORD PTR [rsp+0x18]
  21fca2:	cmp    QWORD PTR [rsp+0x10],r9
  21fca7:	jb     21fd0b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6ab>
  21fca9:	mov    ebp,eax
  21fcab:	mov    eax,DWORD PTR [rsp+0x30]
  21fcaf:	mov    r15,QWORD PTR [rsp+0x20]
  21fcb4:	mov    QWORD PTR [rsp+0x30],rcx
  21fcb9:	mov    QWORD PTR [rsp+0x18],rdi
  21fcbe:	mov    QWORD PTR [rsp+0x48],r8
  21fcc3:	mov    rcx,r10
  21fcc6:	mov    rdi,rbx
  21fcc9:	mov    rdx,QWORD PTR [rsp+0x10]
  21fcce:	mov    QWORD PTR [rsp+0x68],rdx
  21fcd3:	mov    QWORD PTR [rsp+0x10],r9
  21fcd8:	mov    rbx,r13
  21fcdb:	mov    r13,r12
  21fcde:	jmp    21fd2b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6cb>
  21fce0:	cmp    r9,0x1
  21fce4:	jne    21fe66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x806>
  21fcea:	mov    rax,r12
  21fced:	jmp    21ff80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21fcf2:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1fede]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  21fcfa:	movsd  QWORD PTR [rsp+0x38],xmm0
  21fd00:	mov    eax,DWORD PTR [rsp+0x18]
  21fd04:	cmp    QWORD PTR [rsp+0x10],r9
  21fd09:	jae    21fca9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x649>
  21fd0b:	mov    ecx,DWORD PTR [rsp+0x30]
  21fd0f:	mov    ebp,ecx
  21fd11:	mov    r15,r10
  21fd14:	mov    QWORD PTR [rsp+0x30],r8
  21fd19:	mov    QWORD PTR [rsp+0x18],rbx
  21fd1e:	mov    QWORD PTR [rsp+0x68],r9
  21fd23:	mov    rbx,r12
  21fd26:	mov    rcx,QWORD PTR [rsp+0x20]
  21fd2b:	movaps XMMWORD PTR [rsp+0x80],xmm1
  21fd33:	mov    QWORD PTR [rsp+0x40],rdi
  21fd38:	mov    r12d,eax
  21fd3b:	mov    QWORD PTR [rsp+0x20],rcx
  21fd40:	cmp    rcx,0x1
  21fd44:	jne    21fd70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x710>
  21fd46:	cmp    QWORD PTR [rsp+0x10],0x1
  21fd4c:	jne    21fd70 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x710>
  21fd4e:	lea    r8,[rip+0x320ebb]        # 540c10 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x3e0>
  21fd55:	lea    rdi,[rsp+0x98]
  21fd5d:	mov    rsi,r13
  21fd60:	mov    rdx,rbx
  21fd63:	mov    rcx,QWORD PTR [rsp+0x28]
  21fd68:	call   QWORD PTR [rip+0x32c44a]        # 54c1b8 <_DYNAMIC+0x750>
  21fd6e:	jmp    21fd90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x730>
  21fd70:	lea    r8,[rip+0x320eb1]        # 540c28 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x3f8>
  21fd77:	lea    rdi,[rsp+0x98]
  21fd7f:	mov    rsi,r13
  21fd82:	mov    rdx,rbx
  21fd85:	mov    rcx,QWORD PTR [rsp+0x28]
  21fd8a:	call   QWORD PTR [rip+0x32c430]        # 54c1c0 <_DYNAMIC+0x758>
  21fd90:	lea    rdi,[rsp+0xa0]
  21fd98:	mov    rsi,QWORD PTR [rsp+0xc0]
  21fda0:	mov    rdx,QWORD PTR [rsp+0xc8]
  21fda8:	movups xmm0,XMMWORD PTR [rsp+0xd0]
  21fdb0:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  21fdb8:	movaps xmm3,xmm2
  21fdbb:	unpckhpd xmm3,xmm2
  21fdbf:	sub    rsp,0x70
  21fdc3:	movups XMMWORD PTR [rsp+0x58],xmm0
  21fdc8:	movzx  eax,bpl
  21fdcc:	mov    DWORD PTR [rsp+0x50],eax
  21fdd0:	movzx  eax,r12b
  21fdd4:	mov    DWORD PTR [rsp+0x48],eax
  21fdd8:	mov    QWORD PTR [rsp+0x40],r15
  21fddd:	mov    rax,QWORD PTR [rsp+0xa0]
  21fde5:	mov    QWORD PTR [rsp+0x38],rax
  21fdea:	mov    rax,QWORD PTR [rsp+0x88]
  21fdf2:	mov    QWORD PTR [rsp+0x30],rax
  21fdf7:	mov    rax,QWORD PTR [rsp+0xb8]
  21fdff:	mov    QWORD PTR [rsp+0x28],rax
  21fe04:	mov    rax,QWORD PTR [rsp+0x90]
  21fe0c:	mov    QWORD PTR [rsp+0x20],rax
  21fe11:	mov    rax,QWORD PTR [rsp+0xb0]
  21fe19:	mov    QWORD PTR [rsp+0x18],rax
  21fe1e:	mov    rax,QWORD PTR [rsp+0xd8]
  21fe26:	mov    QWORD PTR [rsp+0x10],rax
  21fe2b:	mov    rax,QWORD PTR [rsp+0x80]
  21fe33:	mov    QWORD PTR [rsp+0x8],rax
  21fe38:	mov    QWORD PTR [rsp],r14
  21fe3c:	xorps  xmm1,xmm1
  21fe3f:	mov    r8,rbx
  21fe42:	mov    r9,QWORD PTR [rsp+0x98]
  21fe4a:	mov    rcx,r13
  21fe4d:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  21fe56:	call   QWORD PTR [rsp+0x108]
  21fe5d:	add    rsp,0x70
  21fe61:	jmp    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21fe66:	lea    rax,[r12-0x1]
  21fe6b:	mov    ecx,r12d
  21fe6e:	and    ecx,0x3
  21fe71:	and    r12,0xfffffffffffffffc
  21fe75:	mov    rdx,r9
  21fe78:	shl    rdx,0x4
  21fe7c:	lea    rsi,[rdx+rdx*2]
  21fe80:	shl    QWORD PTR [rsp+0x10],0x4
  21fe86:	mov    rdi,r9
  21fe89:	shl    rdi,0x6
  21fe8d:	shl    r9,0x5
  21fe91:	xor    r8d,r8d
  21fe94:	xorps  xmm0,xmm0
  21fe97:	jmp    21feb1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x851>
  21fe99:	nop    DWORD PTR [rax+0x0]
  21fea0:	inc    r8
  21fea3:	add    r14,QWORD PTR [rsp+0x10]
  21fea8:	cmp    r8,r13
  21feab:	je     2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21feb1:	cmp    rax,0x3
  21feb5:	jae    21fec0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  21feb7:	xor    r10d,r10d
  21feba:	jmp    21fef4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x894>
  21febc:	nop    DWORD PTR [rax+0x0]
  21fec0:	mov    r11,r14
  21fec3:	xor    r10d,r10d
  21fec6:	cs nop WORD PTR [rax+rax*1+0x0]
  21fed0:	movups XMMWORD PTR [r11],xmm0
  21fed4:	movups XMMWORD PTR [r11+rdx*1],xmm0
  21fed9:	movups XMMWORD PTR [r11+r9*1],xmm0
  21fede:	add    r10,0x4
  21fee2:	movups XMMWORD PTR [r11+rsi*1],xmm0
  21fee7:	add    r11,rdi
  21feea:	cmp    r12,r10
  21feed:	jne    21fed0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
  21feef:	test   rcx,rcx
  21fef2:	je     21fea0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  21fef4:	imul   r10,rdx
  21fef8:	add    r10,r14
  21fefb:	mov    r11,rcx
  21fefe:	xchg   ax,ax
  21ff00:	movups XMMWORD PTR [r10],xmm0
  21ff04:	add    r10,rdx
  21ff07:	dec    r11
  21ff0a:	jne    21ff00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a0>
  21ff0c:	jmp    21fea0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  21ff0e:	mov    rax,r12
  21ff11:	jmp    21ff71 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x911>
  21ff13:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe1fcbd]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  21ff1b:	mov    eax,DWORD PTR [rsp+0x18]
  21ff1f:	mov    QWORD PTR [rsp+0x18],r10
  21ff24:	mov    QWORD PTR [rsp+0x40],rdi
  21ff29:	movaps xmm2,xmm1
  21ff2c:	unpckhpd xmm2,xmm1
  21ff30:	test   rbp,rbp
  21ff33:	je     220011 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9b1>
  21ff39:	sub    rsp,0x8
  21ff3d:	movzx  r10d,al
  21ff41:	movzx  r11d,BYTE PTR [rsp+0x38]
  21ff47:	movzx  eax,sil
  21ff4b:	mov    rdi,r12
  21ff4e:	mov    rsi,r13
  21ff51:	mov    rdx,QWORD PTR [rsp+0x30]
  21ff56:	mov    rcx,r14
  21ff59:	mov    r8,QWORD PTR [rsp+0x18]
  21ff5e:	push   rbp
  21ff5f:	push   0x1
  21ff61:	jmp    220038 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d8>
  21ff66:	mov    rax,r13
  21ff69:	mov    r13,r12
  21ff6c:	mov    QWORD PTR [rsp+0x10],r9
  21ff71:	mov    ecx,0x1
  21ff76:	sub    rcx,rax
  21ff79:	shl    rcx,0x4
  21ff7d:	add    r14,rcx
  21ff80:	lea    rcx,[rax-0x1]
  21ff84:	mov    edx,eax
  21ff86:	and    edx,0x3
  21ff89:	and    rax,0xfffffffffffffffc
  21ff8d:	xor    esi,esi
  21ff8f:	xorps  xmm0,xmm0
  21ff92:	jmp    21ffac <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x94c>
  21ff94:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  21ffa0:	inc    rsi
  21ffa3:	cmp    rsi,r13
  21ffa6:	je     2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  21ffac:	mov    rdi,rsi
  21ffaf:	imul   rdi,QWORD PTR [rsp+0x10]
  21ffb5:	shl    rdi,0x4
  21ffb9:	add    rdi,r14
  21ffbc:	cmp    rcx,0x3
  21ffc0:	jb     21fff1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x991>
  21ffc2:	xor    r8d,r8d
  21ffc5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  21ffd0:	movups XMMWORD PTR [rdi],xmm0
  21ffd3:	movups XMMWORD PTR [rdi+0x10],xmm0
  21ffd7:	movups XMMWORD PTR [rdi+0x20],xmm0
  21ffdb:	movups XMMWORD PTR [rdi+0x30],xmm0
  21ffdf:	add    rdi,0x40
  21ffe3:	add    r8,0x4
  21ffe7:	cmp    rax,r8
  21ffea:	jne    21ffd0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x970>
  21ffec:	test   rdx,rdx
  21ffef:	je     21ffa0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x940>
  21fff1:	xor    r8d,r8d
  21fff4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  220000:	movups XMMWORD PTR [rdi],xmm0
  220003:	add    rdi,0x10
  220007:	inc    r8
  22000a:	cmp    rdx,r8
  22000d:	jne    220000 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a0>
  22000f:	jmp    21ffa0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x940>
  220011:	sub    rsp,0x10
  220015:	movzx  r10d,al
  220019:	movzx  r11d,BYTE PTR [rsp+0x40]
  22001f:	movzx  eax,sil
  220023:	mov    rdi,r12
  220026:	mov    rsi,r13
  220029:	mov    rdx,QWORD PTR [rsp+0x38]
  22002e:	mov    rcx,r14
  220031:	mov    r8,QWORD PTR [rsp+0x20]
  220036:	push   0x0
  220038:	push   r10
  22003a:	push   r11
  22003c:	push   QWORD PTR [rsp+0x70]
  220040:	push   QWORD PTR [rsp+0x50]
  220044:	push   QWORD PTR [rsp+0x78]
  220048:	push   QWORD PTR [rsp+0x58]
  22004c:	push   rbx
  22004d:	push   QWORD PTR [rsp+0xb8]
  220054:	push   rax
  220055:	call   20af70 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  22005a:	add    rsp,0x60
  22005e:	jmp    2202af <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc4f>
  220063:	mov    rax,0xffffffffffffffff
  22006a:	jmp    21fc07 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a7>
  22006f:	mov    QWORD PTR [rsp+0x78],r9
  220074:	mov    QWORD PTR [rsp+0x40],rdi
  220079:	mov    QWORD PTR [rsp+0x70],r13
  22007e:	mov    ebp,r15d
  220081:	mov    r15,r10
  220084:	movaps XMMWORD PTR [rsp+0x80],xmm1
  22008c:	mov    r13,r11
  22008f:	call   QWORD PTR [rip+0x32be2b]        # 54bec0 <_DYNAMIC+0x458>
  220095:	mov    rdx,QWORD PTR [rip+0x32be1c]        # 54beb8 <_DYNAMIC+0x450>
  22009c:	mov    r11,r13
  22009f:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  2200a7:	mov    r10,r15
  2200aa:	mov    r15d,ebp
  2200ad:	mov    r13,QWORD PTR [rsp+0x70]
  2200b2:	mov    esi,DWORD PTR [rsp+0x38]
  2200b6:	mov    rdi,QWORD PTR [rsp+0x40]
  2200bb:	mov    r9,QWORD PTR [rsp+0x78]
  2200c0:	mov    cl,0x1
  2200c2:	test   eax,0x80000
  2200c7:	mov    rbp,QWORD PTR [rsp+0x168]
  2200cf:	je     21fc52 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5f2>
  2200d5:	jmp    22019a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb3a>
  2200da:	mov    QWORD PTR [rsp+0x78],r9
  2200df:	mov    QWORD PTR [rsp+0x40],rdi
  2200e4:	mov    QWORD PTR [rsp+0x70],r13
  2200e9:	mov    BYTE PTR [rsp+0xf],r15b
  2200ee:	mov    r15,r10
  2200f1:	movaps XMMWORD PTR [rsp+0x80],xmm1
  2200f9:	mov    r13,r11
  2200fc:	call   QWORD PTR [rip+0x32bdbe]        # 54bec0 <_DYNAMIC+0x458>
  220102:	mov    rdx,QWORD PTR [rip+0x32bdaf]        # 54beb8 <_DYNAMIC+0x450>
  220109:	mov    r11,r13
  22010c:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  220114:	mov    r10,r15
  220117:	movzx  r15d,BYTE PTR [rsp+0xf]
  22011d:	mov    r13,QWORD PTR [rsp+0x70]
  220122:	mov    esi,DWORD PTR [rsp+0x38]
  220126:	mov    rdi,QWORD PTR [rsp+0x40]
  22012b:	mov    r9,QWORD PTR [rsp+0x78]
  220130:	test   ax,ax
  220133:	js     21fc63 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x603>
  220139:	jmp    21fc7a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  22013e:	mov    QWORD PTR [rsp+0x78],r9
  220143:	mov    QWORD PTR [rsp+0x40],rdi
  220148:	mov    QWORD PTR [rsp+0x70],r13
  22014d:	mov    BYTE PTR [rsp+0xf],r15b
  220152:	mov    r15,r10
  220155:	movaps XMMWORD PTR [rsp+0x80],xmm1
  22015d:	mov    r13,r11
  220160:	call   QWORD PTR [rip+0x32bd5a]        # 54bec0 <_DYNAMIC+0x458>
  220166:	mov    r11,r13
  220169:	movaps xmm1,XMMWORD PTR [rsp+0x80]
  220171:	mov    r10,r15
  220174:	movzx  r15d,BYTE PTR [rsp+0xf]
  22017a:	mov    r13,QWORD PTR [rsp+0x70]
  22017f:	mov    esi,DWORD PTR [rsp+0x38]
  220183:	mov    rdi,QWORD PTR [rsp+0x40]
  220188:	mov    r9,QWORD PTR [rsp+0x78]
  22018d:	bt     rax,0x37
  220192:	jae    21fc7a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  220198:	xor    ecx,ecx
  22019a:	test   r15b,r15b
  22019d:	jne    2202c1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc61>
  2201a3:	mov    rax,r11
  2201a6:	mul    QWORD PTR [rsp+0x28]
  2201ab:	jo     2202d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc76>
  2201b1:	mov    rdx,rax
  2201b4:	shr    rdx,0x3d
  2201b8:	jne    2202d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc76>
  2201be:	shl    rax,0x3
  2201c2:	mov    rdx,QWORD PTR [rip+0x32bd07]        # 54bed0 <_DYNAMIC+0x468>
  2201c9:	mov    r8,QWORD PTR [rdx]
  2201cc:	add    r8,r8
  2201cf:	mov    edx,0x1
  2201d4:	cmp    rax,r8
  2201d7:	jb     2201e4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb84>
  2201d9:	cmp    rbp,0x1
  2201dd:	adc    rbp,0x0
  2201e1:	mov    rdx,rbp
  2201e4:	sub    rsp,0xa0
  2201eb:	mov    QWORD PTR [rsp+0x90],rdx
  2201f3:	lea    rax,[rsp+0xf0]
  2201fb:	mov    QWORD PTR [rsp+0x88],rax
  220203:	movzx  eax,BYTE PTR [rsp+0xb8]
  22020b:	mov    DWORD PTR [rsp+0x80],eax
  220212:	mov    rax,QWORD PTR [rsp+0xc0]
  22021a:	mov    QWORD PTR [rsp+0x78],rax
  22021f:	mov    rax,QWORD PTR [rsp+0xe8]
  220227:	mov    QWORD PTR [rsp+0x70],rax
  22022c:	mov    QWORD PTR [rsp+0x68],rdi
  220231:	xorps  xmm0,xmm0
  220234:	movups XMMWORD PTR [rsp+0x58],xmm0
  220239:	movzx  eax,BYTE PTR [rsp+0xd0]
  220241:	mov    DWORD PTR [rsp+0x50],eax
  220245:	mov    QWORD PTR [rsp+0x48],rbx
  22024a:	mov    QWORD PTR [rsp+0x40],r10
  22024f:	mov    rax,QWORD PTR [rsp+0x108]
  220257:	mov    QWORD PTR [rsp+0x38],rax
  22025c:	movzx  eax,sil
  220260:	mov    DWORD PTR [rsp+0x30],eax
  220264:	movups XMMWORD PTR [rsp+0x18],xmm0
  220269:	mov    rax,QWORD PTR [rsp+0xb0]
  220271:	mov    QWORD PTR [rsp+0x10],rax
  220276:	mov    QWORD PTR [rsp+0x8],r9
  22027b:	mov    QWORD PTR [rsp],r14
  22027f:	mov    DWORD PTR [rsp+0x28],0x2
  220287:	movzx  edx,cl
  22028a:	mov    r8,r13
  22028d:	mov    edi,0x3
  220292:	mov    r9,QWORD PTR [rsp+0xc8]
  22029a:	mov    esi,0x1
  22029f:	mov    rcx,r12
  2202a2:	call   QWORD PTR [rip+0x32bc20]        # 54bec8 <_DYNAMIC+0x460>
  2202a8:	add    rsp,0xa0
  2202af:	add    rsp,0x128
  2202b6:	pop    rbx
  2202b7:	pop    r12
  2202b9:	pop    r13
  2202bb:	pop    r14
  2202bd:	pop    r15
  2202bf:	pop    rbp
  2202c0:	ret
  2202c1:	mov    r11,0xffffffffffffffff
  2202c8:	mov    rax,r11
  2202cb:	mul    QWORD PTR [rsp+0x28]
  2202d0:	jno    2201b1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb51>
  2202d6:	mov    rax,QWORD PTR [rip+0x32bbf3]        # 54bed0 <_DYNAMIC+0x468>
  2202dd:	mov    rax,QWORD PTR [rax]
  2202e0:	jmp    2201d9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb79>
