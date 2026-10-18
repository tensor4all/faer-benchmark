
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/7f713a1401f1-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000002375f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  2375f0:	push   rbp
  2375f1:	push   r15
  2375f3:	push   r14
  2375f5:	push   r13
  2375f7:	push   r12
  2375f9:	push   rbx
  2375fa:	sub    rsp,0x128
  237601:	mov    r12,QWORD PTR [rdi+0x8]
  237605:	test   r12,r12
  237608:	je     23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  23760e:	mov    r15,QWORD PTR [rdi+0x10]
  237612:	test   r15,r15
  237615:	je     23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  23761b:	mov    rbx,QWORD PTR [rdi]
  23761e:	mov    r14,QWORD PTR [rdi+0x18]
  237622:	mov    rbp,QWORD PTR [rdi+0x20]
  237626:	mov    rax,QWORD PTR [rdx+0x10]
  23762a:	mov    QWORD PTR [rsp+0x40],rax
  23762f:	test   rax,rax
  237632:	je     2376e8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf8>
  237638:	mov    DWORD PTR [rsp+0x20],r9d
  23763d:	mov    DWORD PTR [rsp+0x38],esi
  237641:	mov    DWORD PTR [rsp+0x10],ecx
  237645:	mov    r13,QWORD PTR [rdx]
  237648:	mov    rcx,QWORD PTR [rdx+0x8]
  23764c:	mov    rsi,QWORD PTR [rdx+0x18]
  237650:	test   r14,r14
  237653:	mov    QWORD PTR [rsp+0x30],rcx
  237658:	jns    237698 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa8>
  23765a:	lea    rax,[r12-0x1]
  23765f:	imul   rax,r14
  237663:	shl    rax,0x4
  237667:	add    rbx,rax
  23766a:	neg    r14
  23766d:	xor    eax,eax
  23766f:	mov    r9,rsi
  237672:	mov    rsi,rcx
  237675:	sub    rsi,0x1
  237679:	cmovb  rsi,rax
  23767d:	mov    rdi,r9
  237680:	imul   rdi,rsi
  237684:	cmp    rsi,rcx
  237687:	mov    rsi,r9
  23768a:	cmove  rdi,rax
  23768e:	shl    rdi,0x4
  237692:	add    r13,rdi
  237695:	neg    rsi
  237698:	mov    rax,QWORD PTR [rdx+0x20]
  23769c:	mov    rdi,QWORD PTR [r8]
  23769f:	mov    r10,QWORD PTR [r8+0x8]
  2376a3:	mov    r9,QWORD PTR [r8+0x10]
  2376a7:	mov    rcx,QWORD PTR [r8+0x20]
  2376ab:	test   rbp,rbp
  2376ae:	mov    QWORD PTR [rsp+0x50],r9
  2376b3:	mov    QWORD PTR [rsp+0x28],r10
  2376b8:	js     237737 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x147>
  2376ba:	mov    r11,QWORD PTR [r8+0x18]
  2376be:	test   rax,rax
  2376c1:	js     2377a5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b5>
  2376c7:	mov    QWORD PTR [rsp+0x18],r13
  2376cc:	mov    r10,QWORD PTR [rsp+0x160]
  2376d4:	cmp    r15,0x1
  2376d8:	mov    r8,QWORD PTR [rsp+0x50]
  2376dd:	je     237826 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x236>
  2376e3:	jmp    237922 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  2376e8:	test   sil,sil
  2376eb:	jne    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  2376f1:	cmp    r12,0x1
  2376f5:	je     23770b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x11b>
  2376f7:	cmp    r14,0xffffffffffffffff
  2376fb:	je     237e8e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89e>
  237701:	cmp    r14,0x1
  237705:	je     237c2b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x63b>
  23770b:	cmp    r15,0x1
  23770f:	je     237c21 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  237715:	cmp    rbp,0xffffffffffffffff
  237719:	je     237ffa <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0a>
  23771f:	cmp    rbp,0x1
  237723:	jne    237c21 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  237729:	mov    rax,r15
  23772c:	mov    r15,r12
  23772f:	mov    rbp,r14
  237732:	jmp    238012 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  237737:	lea    rdx,[r15-0x1]
  23773b:	imul   rdx,rbp
  23773f:	shl    rdx,0x4
  237743:	add    rbx,rdx
  237746:	neg    rbp
  237749:	xor    edx,edx
  23774b:	mov    r11,rsi
  23774e:	mov    rsi,r9
  237751:	sub    rsi,0x1
  237755:	cmovb  rsi,rdx
  237759:	mov    rdx,rbp
  23775c:	mov    rbp,rcx
  23775f:	mov    rcx,rdi
  237762:	mov    rdi,rbp
  237765:	imul   rdi,rsi
  237769:	cmp    rsi,r9
  23776c:	mov    rsi,r11
  23776f:	mov    r10,QWORD PTR [rsp+0x28]
  237774:	mov    r9d,0x0
  23777a:	cmove  rdi,r9
  23777e:	test   r10,r10
  237781:	cmove  rdi,r10
  237785:	shl    rdi,0x4
  237789:	add    rcx,rdi
  23778c:	mov    rdi,rcx
  23778f:	mov    rcx,rbp
  237792:	mov    rbp,rdx
  237795:	neg    rcx
  237798:	mov    r11,QWORD PTR [r8+0x18]
  23779c:	test   rax,rax
  23779f:	jns    2376c7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd7>
  2377a5:	mov    rdx,QWORD PTR [rsp+0x40]
  2377aa:	dec    rdx
  2377ad:	imul   rdx,rax
  2377b1:	mov    r8,QWORD PTR [rsp+0x30]
  2377b6:	test   r8,r8
  2377b9:	cmove  rdx,r8
  2377bd:	shl    rdx,0x4
  2377c1:	add    r13,rdx
  2377c4:	mov    QWORD PTR [rsp+0x18],r13
  2377c9:	neg    rax
  2377cc:	xor    edx,edx
  2377ce:	mov    r8,rsi
  2377d1:	mov    rsi,r10
  2377d4:	sub    rsi,0x1
  2377d8:	cmovb  rsi,rdx
  2377dc:	mov    r13,rcx
  2377df:	mov    rcx,rdi
  2377e2:	mov    rdi,r11
  2377e5:	imul   rdi,rsi
  2377e9:	mov    r9,QWORD PTR [rsp+0x50]
  2377ee:	test   r9,r9
  2377f1:	cmove  rdi,r9
  2377f5:	cmp    rsi,r10
  2377f8:	mov    rsi,r8
  2377fb:	cmove  rdi,rdx
  2377ff:	shl    rdi,0x4
  237803:	add    rcx,rdi
  237806:	mov    rdi,rcx
  237809:	mov    rcx,r13
  23780c:	neg    r11
  23780f:	mov    r10,QWORD PTR [rsp+0x160]
  237817:	cmp    r15,0x1
  23781b:	mov    r8,QWORD PTR [rsp+0x50]
  237820:	jne    237922 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  237826:	cmp    rsi,0x1
  23782a:	jne    2378a6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  23782c:	cmp    r14,0x1
  237830:	jne    2378a6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  237832:	test   rbx,rbx
  237835:	je     2378a6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  237837:	mov    rcx,QWORD PTR [rsp+0x18]
  23783c:	mov    QWORD PTR [rsp+0x90],rcx
  237844:	mov    rcx,QWORD PTR [rsp+0x30]
  237849:	mov    QWORD PTR [rsp+0x98],rcx
  237851:	mov    rcx,QWORD PTR [rsp+0x40]
  237856:	mov    QWORD PTR [rsp+0xa0],rcx
  23785e:	mov    QWORD PTR [rsp+0xa8],rax
  237866:	mov    QWORD PTR [rsp+0x60],rdi
  23786b:	mov    rax,QWORD PTR [rsp+0x28]
  237870:	mov    QWORD PTR [rsp+0x68],rax
  237875:	mov    QWORD PTR [rsp+0x70],r11
  23787a:	sub    rsp,0x8
  23787e:	movzx  eax,BYTE PTR [rsp+0x28]
  237883:	movzx  edx,BYTE PTR [rsp+0x40]
  237888:	movzx  r8d,BYTE PTR [rsp+0x18]
  23788e:	lea    rcx,[rsp+0x98]
  237896:	lea    r9,[rsp+0x68]
  23789b:	mov    rdi,rbx
  23789e:	mov    rsi,r12
  2378a1:	jmp    2379aa <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3ba>
  2378a6:	cmp    rax,0x1
  2378aa:	jne    237922 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  2378ac:	cmp    r11,0x1
  2378b0:	jne    237922 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  2378b2:	test   rdi,rdi
  2378b5:	je     237922 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  2378b7:	mov    rax,QWORD PTR [rsp+0x18]
  2378bc:	mov    QWORD PTR [rsp+0x90],rax
  2378c4:	mov    rax,QWORD PTR [rsp+0x30]
  2378c9:	mov    QWORD PTR [rsp+0x98],rax
  2378d1:	mov    rax,QWORD PTR [rsp+0x40]
  2378d6:	mov    QWORD PTR [rsp+0xa0],rax
  2378de:	mov    QWORD PTR [rsp+0xa8],rsi
  2378e6:	mov    QWORD PTR [rsp+0x60],rbx
  2378eb:	mov    QWORD PTR [rsp+0x68],r12
  2378f0:	mov    QWORD PTR [rsp+0x70],r14
  2378f5:	sub    rsp,0x8
  2378f9:	movzx  eax,BYTE PTR [rsp+0x28]
  2378fe:	movzx  esi,BYTE PTR [rsp+0x40]
  237903:	movzx  ecx,BYTE PTR [rsp+0x18]
  237908:	mov    r8,rdi
  23790b:	lea    rdi,[rsp+0x68]
  237910:	lea    rdx,[rsp+0x98]
  237918:	mov    r9,QWORD PTR [rsp+0x30]
  23791d:	jmp    237a37 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x447>
  237922:	cmp    r12,0x1
  237926:	jne    237a4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  23792c:	xor    edx,edx
  23792e:	cmp    rbp,0x1
  237932:	cmove  rdx,rbx
  237936:	cmp    rcx,0x1
  23793a:	jne    2379c2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  237940:	test   rdx,rdx
  237943:	je     2379c2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  237945:	mov    QWORD PTR [rsp+0x90],rdi
  23794d:	mov    QWORD PTR [rsp+0x98],r8
  237955:	mov    rcx,QWORD PTR [rsp+0x28]
  23795a:	mov    QWORD PTR [rsp+0xa0],rcx
  237962:	mov    QWORD PTR [rsp+0xa8],r11
  23796a:	mov    rcx,QWORD PTR [rsp+0x18]
  23796f:	mov    QWORD PTR [rsp+0x60],rcx
  237974:	mov    rcx,QWORD PTR [rsp+0x40]
  237979:	mov    QWORD PTR [rsp+0x68],rcx
  23797e:	mov    QWORD PTR [rsp+0x70],rax
  237983:	sub    rsp,0x8
  237987:	movzx  eax,BYTE PTR [rsp+0x18]
  23798c:	movzx  edx,BYTE PTR [rsp+0x40]
  237991:	movzx  r8d,BYTE PTR [rsp+0x28]
  237997:	lea    rcx,[rsp+0x98]
  23799f:	lea    r9,[rsp+0x68]
  2379a4:	mov    rdi,rbx
  2379a7:	mov    rsi,r15
  2379aa:	push   QWORD PTR [rsp+0x170]
  2379b1:	push   r10
  2379b3:	push   rax
  2379b4:	call   14ca60 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  2379b9:	add    rsp,0x20
  2379bd:	jmp    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  2379c2:	xor    edx,edx
  2379c4:	cmp    rax,0x1
  2379c8:	cmove  rdx,QWORD PTR [rsp+0x18]
  2379ce:	cmp    r11,0x1
  2379d2:	jne    237a4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  2379d4:	test   rdx,rdx
  2379d7:	je     237a4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  2379d9:	mov    QWORD PTR [rsp+0x90],rdi
  2379e1:	mov    QWORD PTR [rsp+0x98],r8
  2379e9:	mov    rax,QWORD PTR [rsp+0x28]
  2379ee:	mov    QWORD PTR [rsp+0xa0],rax
  2379f6:	mov    QWORD PTR [rsp+0xa8],rcx
  2379fe:	mov    QWORD PTR [rsp+0x60],rbx
  237a03:	mov    QWORD PTR [rsp+0x68],r15
  237a08:	mov    QWORD PTR [rsp+0x70],rbp
  237a0d:	sub    rsp,0x8
  237a11:	movzx  eax,BYTE PTR [rsp+0x18]
  237a16:	movzx  esi,BYTE PTR [rsp+0x40]
  237a1b:	movzx  ecx,BYTE PTR [rsp+0x28]
  237a20:	lea    rdi,[rsp+0x68]
  237a25:	lea    rdx,[rsp+0x98]
  237a2d:	mov    r8,QWORD PTR [rsp+0x20]
  237a32:	mov    r9,QWORD PTR [rsp+0x48]
  237a37:	push   QWORD PTR [rsp+0x170]
  237a3e:	push   r10
  237a40:	push   rax
  237a41:	call   19c640 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  237a46:	add    rsp,0x20
  237a4a:	jmp    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  237a4f:	cmp    QWORD PTR [rsp+0x40],0x1
  237a55:	jne    237b68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  237a5b:	xor    edx,edx
  237a5d:	cmp    r14,0x1
  237a61:	cmove  rdx,rbx
  237a65:	cmp    rsi,0x1
  237a69:	jne    237ad9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  237a6b:	test   rdx,rdx
  237a6e:	je     237ad9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  237a70:	mov    QWORD PTR [rsp+0x90],rdx
  237a78:	mov    QWORD PTR [rsp+0x98],r12
  237a80:	mov    QWORD PTR [rsp+0xa0],r15
  237a88:	mov    QWORD PTR [rsp+0xa8],rbp
  237a90:	mov    QWORD PTR [rsp+0x60],rdi
  237a95:	mov    QWORD PTR [rsp+0x68],r8
  237a9a:	mov    QWORD PTR [rsp+0x70],rcx
  237a9f:	sub    rsp,0x8
  237aa3:	movzx  eax,BYTE PTR [rsp+0x28]
  237aa8:	movzx  esi,BYTE PTR [rsp+0x40]
  237aad:	movzx  r8d,BYTE PTR [rsp+0x18]
  237ab3:	lea    rdi,[rsp+0x98]
  237abb:	lea    r9,[rsp+0x68]
  237ac0:	mov    rdx,QWORD PTR [rsp+0x20]
  237ac5:	mov    rcx,QWORD PTR [rsp+0x38]
  237aca:	push   QWORD PTR [rsp+0x170]
  237ad1:	push   r10
  237ad3:	push   rax
  237ad4:	jmp    237b5a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x56a>
  237ad9:	xor    edx,edx
  237adb:	cmp    rbp,0x1
  237adf:	cmove  rdx,rbx
  237ae3:	cmp    rcx,0x1
  237ae7:	jne    237b68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  237ae9:	test   rdx,rdx
  237aec:	je     237b68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  237aee:	mov    QWORD PTR [rsp+0x90],rdx
  237af6:	mov    QWORD PTR [rsp+0x98],r15
  237afe:	mov    QWORD PTR [rsp+0xa0],r12
  237b06:	mov    QWORD PTR [rsp+0xa8],r14
  237b0e:	mov    rax,QWORD PTR [rsp+0x18]
  237b13:	mov    QWORD PTR [rsp+0x60],rax
  237b18:	mov    rax,QWORD PTR [rsp+0x30]
  237b1d:	mov    QWORD PTR [rsp+0x68],rax
  237b22:	mov    QWORD PTR [rsp+0x70],rsi
  237b27:	sub    rsp,0x8
  237b2b:	movzx  r11d,BYTE PTR [rsp+0x18]
  237b31:	movzx  esi,BYTE PTR [rsp+0x40]
  237b36:	mov    rcx,r8
  237b39:	movzx  r8d,BYTE PTR [rsp+0x28]
  237b3f:	mov    rdx,rdi
  237b42:	lea    rdi,[rsp+0x98]
  237b4a:	lea    r9,[rsp+0x68]
  237b4f:	push   QWORD PTR [rsp+0x170]
  237b56:	push   r10
  237b58:	push   r11
  237b5a:	call   14c640 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  237b5f:	add    rsp,0x20
  237b63:	jmp    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  237b68:	mov    QWORD PTR [rsp+0x28],r11
  237b6d:	mov    QWORD PTR [rsp+0x50],rcx
  237b72:	mov    QWORD PTR [rsp+0x30],rdi
  237b77:	mov    QWORD PTR [rsp+0x58],rax
  237b7c:	movups xmm2,XMMWORD PTR [r10]
  237b80:	mov    rax,r12
  237b83:	mul    r15
  237b86:	mov    r13,rax
  237b89:	movaps XMMWORD PTR [rsp+0x60],xmm2
  237b8e:	seto   r11b
  237b92:	jo     23811d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb2d>
  237b98:	mul    QWORD PTR [rsp+0x40]
  237b9d:	seto   cl
  237ba0:	not    cl
  237ba2:	cmp    rax,0x1001
  237ba8:	setb   al
  237bab:	test   cl,al
  237bad:	mov    rdi,QWORD PTR [rsp+0x18]
  237bb2:	mov    r8d,DWORD PTR [rsp+0x10]
  237bb7:	mov    r9d,DWORD PTR [rsp+0x38]
  237bbc:	jne    237c17 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x627>
  237bbe:	mov    rdx,QWORD PTR [rip+0x3121b3]        # 549d78 <_DYNAMIC+0x450>
  237bc5:	mov    rax,QWORD PTR [rdx]
  237bc8:	test   rax,rax
  237bcb:	je     238129 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb39>
  237bd1:	mov    cl,0x1
  237bd3:	test   eax,0x80000
  237bd8:	jne    238212 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  237bde:	mov    rax,QWORD PTR [rdx]
  237be1:	test   rax,rax
  237be4:	je     23817c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8c>
  237bea:	test   ax,ax
  237bed:	jns    237c06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  237bef:	mov    rax,QWORD PTR [rdx]
  237bf2:	test   rax,rax
  237bf5:	je     2381cb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbdb>
  237bfb:	bt     rax,0x37
  237c00:	jb     238210 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc20>
  237c06:	test   r9b,r9b
  237c09:	jne    237e96 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a6>
  237c0f:	xorps  xmm0,xmm0
  237c12:	jmp    237e9e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  237c17:	test   r9b,r9b
  237c1a:	jne    237c33 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x643>
  237c1c:	xorps  xmm0,xmm0
  237c1f:	jmp    237c3b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x64b>
  237c21:	cmp    r14,0x1
  237c25:	jne    237de8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f8>
  237c2b:	mov    rax,r12
  237c2e:	jmp    238012 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  237c33:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe07f3d]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  237c3b:	movsd  QWORD PTR [rsp+0x38],xmm0
  237c41:	mov    r13d,DWORD PTR [rsp+0x20]
  237c46:	mov    rax,QWORD PTR [rsp+0x58]
  237c4b:	mov    rcx,QWORD PTR [rsp+0x50]
  237c50:	mov    rdx,QWORD PTR [rsp+0x28]
  237c55:	cmp    rbp,r14
  237c58:	jae    237c78 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x688>
  237c5a:	mov    BYTE PTR [rsp+0x20],r8b
  237c5f:	mov    QWORD PTR [rsp+0x10],rsi
  237c64:	mov    QWORD PTR [rsp+0x58],rax
  237c69:	mov    QWORD PTR [rsp+0x48],rdi
  237c6e:	mov    QWORD PTR [rsp+0x18],r14
  237c73:	mov    r14,r12
  237c76:	jmp    237cad <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6bd>
  237c78:	mov    BYTE PTR [rsp+0x20],r13b
  237c7d:	mov    r13d,r8d
  237c80:	mov    QWORD PTR [rsp+0x10],rcx
  237c85:	mov    QWORD PTR [rsp+0x58],rdx
  237c8a:	mov    rcx,QWORD PTR [rsp+0x30]
  237c8f:	mov    QWORD PTR [rsp+0x48],rcx
  237c94:	mov    rdx,rax
  237c97:	mov    rcx,rsi
  237c9a:	mov    QWORD PTR [rsp+0x30],rdi
  237c9f:	mov    QWORD PTR [rsp+0x18],rbp
  237ca4:	mov    rbp,r14
  237ca7:	mov    r14,r15
  237caa:	mov    r15,r12
  237cad:	movaps XMMWORD PTR [rsp+0x80],xmm2
  237cb5:	mov    QWORD PTR [rsp+0x28],rdx
  237cba:	mov    QWORD PTR [rsp+0x50],rcx
  237cbf:	cmp    rcx,0x1
  237cc3:	jne    237cf0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  237cc5:	cmp    rbp,0x1
  237cc9:	jne    237cf0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  237ccb:	lea    r8,[rip+0x30a5d6]        # 5422a8 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x3e0>
  237cd2:	lea    rdi,[rsp+0x90]
  237cda:	mov    rsi,r15
  237cdd:	mov    rdx,r14
  237ce0:	mov    r12,QWORD PTR [rsp+0x40]
  237ce5:	mov    rcx,r12
  237ce8:	call   QWORD PTR [rip+0x312382]        # 54a070 <_DYNAMIC+0x748>
  237cee:	jmp    237d13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x723>
  237cf0:	lea    r8,[rip+0x30a5c9]        # 5422c0 <anon.91a7058d41e391a160cf0b63c4502f2f.270.llvm.8155264091315598178+0x3f8>
  237cf7:	lea    rdi,[rsp+0x90]
  237cff:	mov    rsi,r15
  237d02:	mov    rdx,r14
  237d05:	mov    r12,QWORD PTR [rsp+0x40]
  237d0a:	mov    rcx,r12
  237d0d:	call   QWORD PTR [rip+0x312365]        # 54a078 <_DYNAMIC+0x750>
  237d13:	lea    rdi,[rsp+0x98]
  237d1b:	mov    rsi,QWORD PTR [rsp+0xb8]
  237d23:	mov    rdx,QWORD PTR [rsp+0xc0]
  237d2b:	movups xmm0,XMMWORD PTR [rsp+0xc8]
  237d33:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  237d3b:	movaps xmm3,xmm2
  237d3e:	unpckhpd xmm3,xmm2
  237d42:	sub    rsp,0x70
  237d46:	movups XMMWORD PTR [rsp+0x58],xmm0
  237d4b:	movzx  eax,BYTE PTR [rsp+0x90]
  237d53:	mov    DWORD PTR [rsp+0x50],eax
  237d57:	movzx  eax,r13b
  237d5b:	mov    DWORD PTR [rsp+0x48],eax
  237d5f:	mov    rax,QWORD PTR [rsp+0x80]
  237d67:	mov    QWORD PTR [rsp+0x40],rax
  237d6c:	mov    rax,QWORD PTR [rsp+0xc8]
  237d74:	mov    QWORD PTR [rsp+0x38],rax
  237d79:	mov    rax,QWORD PTR [rsp+0xb8]
  237d81:	mov    QWORD PTR [rsp+0x30],rax
  237d86:	mov    rax,QWORD PTR [rsp+0x98]
  237d8e:	mov    QWORD PTR [rsp+0x28],rax
  237d93:	mov    rax,QWORD PTR [rsp+0xc0]
  237d9b:	mov    QWORD PTR [rsp+0x20],rax
  237da0:	mov    rax,QWORD PTR [rsp+0xa0]
  237da8:	mov    QWORD PTR [rsp+0x18],rax
  237dad:	mov    rax,QWORD PTR [rsp+0x88]
  237db5:	mov    QWORD PTR [rsp+0x10],rax
  237dba:	mov    QWORD PTR [rsp+0x8],rbp
  237dbf:	mov    QWORD PTR [rsp],rbx
  237dc3:	xorps  xmm1,xmm1
  237dc6:	mov    r8,r14
  237dc9:	mov    r9,r12
  237dcc:	mov    rcx,r15
  237dcf:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  237dd8:	call   QWORD PTR [rsp+0x100]
  237ddf:	add    rsp,0x70
  237de3:	jmp    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  237de8:	lea    rax,[r12-0x1]
  237ded:	mov    ecx,r12d
  237df0:	and    ecx,0x3
  237df3:	and    r12,0xfffffffffffffffc
  237df7:	mov    rdx,r14
  237dfa:	shl    rdx,0x4
  237dfe:	lea    rsi,[rdx+rdx*2]
  237e02:	shl    rbp,0x4
  237e06:	mov    rdi,r14
  237e09:	shl    rdi,0x6
  237e0d:	shl    r14,0x5
  237e11:	xor    r8d,r8d
  237e14:	xorps  xmm0,xmm0
  237e17:	jmp    237e2f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83f>
  237e19:	nop    DWORD PTR [rax+0x0]
  237e20:	inc    r8
  237e23:	add    rbx,rbp
  237e26:	cmp    r8,r15
  237e29:	je     23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  237e2f:	cmp    rax,0x3
  237e33:	jae    237e40 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x850>
  237e35:	xor    r9d,r9d
  237e38:	jmp    237e74 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x884>
  237e3a:	nop    WORD PTR [rax+rax*1+0x0]
  237e40:	mov    r10,rbx
  237e43:	xor    r9d,r9d
  237e46:	cs nop WORD PTR [rax+rax*1+0x0]
  237e50:	movups XMMWORD PTR [r10],xmm0
  237e54:	movups XMMWORD PTR [r10+rdx*1],xmm0
  237e59:	movups XMMWORD PTR [r10+r14*1],xmm0
  237e5e:	add    r9,0x4
  237e62:	movups XMMWORD PTR [r10+rsi*1],xmm0
  237e67:	add    r10,rdi
  237e6a:	cmp    r12,r9
  237e6d:	jne    237e50 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  237e6f:	test   rcx,rcx
  237e72:	je     237e20 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  237e74:	imul   r9,rdx
  237e78:	add    r9,rbx
  237e7b:	mov    r10,rcx
  237e7e:	xchg   ax,ax
  237e80:	movups XMMWORD PTR [r9],xmm0
  237e84:	add    r9,rdx
  237e87:	dec    r10
  237e8a:	jne    237e80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x890>
  237e8c:	jmp    237e20 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  237e8e:	mov    rax,r12
  237e91:	jmp    238003 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa13>
  237e96:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe07cda]        # 3fb78 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  237e9e:	xor    r13d,r13d
  237ea1:	cmp    QWORD PTR [rsp+0x168],0x0
  237eaa:	setne  al
  237ead:	cmp    rbp,r14
  237eb0:	jge    237ed5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8e5>
  237eb2:	mov    ecx,DWORD PTR [rsp+0x20]
  237eb6:	mov    BYTE PTR [rsp+0xf],cl
  237eba:	mov    r11,QWORD PTR [rsp+0x50]
  237ebf:	mov    rdx,QWORD PTR [rsp+0x28]
  237ec4:	mov    r10,QWORD PTR [rsp+0x30]
  237ec9:	mov    QWORD PTR [rsp+0x10],r14
  237ece:	mov    QWORD PTR [rsp+0x48],r15
  237ed3:	jmp    237f0e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x91e>
  237ed5:	mov    BYTE PTR [rsp+0xf],r8b
  237eda:	mov    r11,rsi
  237edd:	mov    rdx,QWORD PTR [rsp+0x58]
  237ee2:	mov    r10,rdi
  237ee5:	mov    QWORD PTR [rsp+0x10],rbp
  237eea:	mov    QWORD PTR [rsp+0x48],r12
  237eef:	mov    r8d,DWORD PTR [rsp+0x20]
  237ef4:	mov    rsi,QWORD PTR [rsp+0x50]
  237ef9:	mov    rcx,QWORD PTR [rsp+0x28]
  237efe:	mov    QWORD PTR [rsp+0x58],rcx
  237f03:	mov    rdi,QWORD PTR [rsp+0x30]
  237f08:	mov    rbp,r14
  237f0b:	mov    r12,r15
  237f0e:	test   rbp,rbp
  237f11:	js     2380a1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab1>
  237f17:	cmp    QWORD PTR [rsp+0x10],0x0
  237f1d:	js     2380c3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad3>
  237f23:	mov    r13b,al
  237f26:	test   rdx,rdx
  237f29:	mov    QWORD PTR [rsp+0x30],r13
  237f2e:	js     2380e7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaf7>
  237f34:	mov    QWORD PTR [rsp+0x28],r11
  237f39:	mov    QWORD PTR [rsp+0x20],r10
  237f3e:	mov    QWORD PTR [rsp+0x50],rdx
  237f43:	mov    QWORD PTR [rsp+0x18],rdi
  237f48:	mov    r13,rsi
  237f4b:	mov    r15,QWORD PTR [rsp+0x40]
  237f50:	mov    rax,QWORD PTR [rip+0x3120b9]        # 54a010 <_DYNAMIC+0x6e8>
  237f57:	mov    rax,QWORD PTR [rax]
  237f5a:	test   rax,rax
  237f5d:	jne    237f92 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a2>
  237f5f:	mov    r14d,r8d
  237f62:	movaps XMMWORD PTR [rsp+0x80],xmm2
  237f6a:	movsd  QWORD PTR [rsp+0x120],xmm0
  237f73:	call   QWORD PTR [rip+0x31209f]        # 54a018 <_DYNAMIC+0x6f0>
  237f79:	movsd  xmm0,QWORD PTR [rsp+0x120]
  237f82:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  237f8a:	mov    r9d,DWORD PTR [rsp+0x38]
  237f8f:	mov    r8d,r14d
  237f92:	movaps xmm3,xmm2
  237f95:	unpckhpd xmm3,xmm2
  237f99:	movzx  r11d,r8b
  237f9d:	movzx  r14d,BYTE PTR [rsp+0xf]
  237fa3:	movzx  r10d,r9b
  237fa7:	xorps  xmm1,xmm1
  237faa:	mov    rdi,QWORD PTR [rsp+0x48]
  237faf:	mov    rsi,r12
  237fb2:	mov    rdx,r15
  237fb5:	mov    rcx,rbx
  237fb8:	mov    r8,QWORD PTR [rsp+0x10]
  237fbd:	mov    r9,rbp
  237fc0:	push   QWORD PTR [rsp+0x168]
  237fc7:	push   QWORD PTR [rsp+0x38]
  237fcb:	push   r11
  237fcd:	push   r14
  237fcf:	push   0x0
  237fd1:	push   QWORD PTR [rsp+0x80]
  237fd8:	push   r13
  237fda:	push   QWORD PTR [rsp+0x50]
  237fde:	push   QWORD PTR [rsp+0x68]
  237fe2:	push   QWORD PTR [rsp+0x98]
  237fe9:	push   QWORD PTR [rsp+0x70]
  237fed:	push   r10
  237fef:	call   rax
  237ff1:	add    rsp,0x60
  237ff5:	jmp    23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  237ffa:	mov    rax,r15
  237ffd:	mov    r15,r12
  238000:	mov    rbp,r14
  238003:	mov    ecx,0x1
  238008:	sub    rcx,rax
  23800b:	shl    rcx,0x4
  23800f:	add    rbx,rcx
  238012:	lea    rcx,[rax-0x1]
  238016:	mov    edx,eax
  238018:	and    edx,0x3
  23801b:	and    rax,0xfffffffffffffffc
  23801f:	xor    esi,esi
  238021:	xorps  xmm0,xmm0
  238024:	jmp    23803c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4c>
  238026:	cs nop WORD PTR [rax+rax*1+0x0]
  238030:	inc    rsi
  238033:	cmp    rsi,r15
  238036:	je     23832a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3a>
  23803c:	mov    rdi,rsi
  23803f:	imul   rdi,rbp
  238043:	shl    rdi,0x4
  238047:	add    rdi,rbx
  23804a:	cmp    rcx,0x3
  23804e:	jb     238081 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  238050:	xor    r8d,r8d
  238053:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  238060:	movups XMMWORD PTR [rdi],xmm0
  238063:	movups XMMWORD PTR [rdi+0x10],xmm0
  238067:	movups XMMWORD PTR [rdi+0x20],xmm0
  23806b:	movups XMMWORD PTR [rdi+0x30],xmm0
  23806f:	add    rdi,0x40
  238073:	add    r8,0x4
  238077:	cmp    rax,r8
  23807a:	jne    238060 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa70>
  23807c:	test   rdx,rdx
  23807f:	je     238030 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  238081:	xor    r8d,r8d
  238084:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  238090:	movups XMMWORD PTR [rdi],xmm0
  238093:	add    rdi,0x10
  238097:	inc    r8
  23809a:	cmp    rdx,r8
  23809d:	jne    238090 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa0>
  23809f:	jmp    238030 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  2380a1:	mov    rcx,QWORD PTR [rsp+0x48]
  2380a6:	dec    rcx
  2380a9:	imul   rcx,r11
  2380ad:	shl    rcx,0x4
  2380b1:	add    r10,rcx
  2380b4:	neg    r11
  2380b7:	cmp    QWORD PTR [rsp+0x10],0x0
  2380bd:	jns    237f23 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x933>
  2380c3:	lea    rcx,[r12-0x1]
  2380c8:	imul   rcx,rsi
  2380cc:	shl    rcx,0x4
  2380d0:	add    rdi,rcx
  2380d3:	neg    rsi
  2380d6:	mov    r13b,al
  2380d9:	test   rdx,rdx
  2380dc:	mov    QWORD PTR [rsp+0x30],r13
  2380e1:	jns    237f34 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  2380e7:	mov    rax,QWORD PTR [rsp+0x40]
  2380ec:	dec    rax
  2380ef:	mov    rcx,rdx
  2380f2:	imul   rcx,rax
  2380f6:	shl    rcx,0x4
  2380fa:	add    r10,rcx
  2380fd:	neg    rdx
  238100:	mov    rcx,QWORD PTR [rsp+0x58]
  238105:	imul   rax,rcx
  238109:	shl    rax,0x4
  23810d:	add    rdi,rax
  238110:	neg    rcx
  238113:	mov    QWORD PTR [rsp+0x58],rcx
  238118:	jmp    237f34 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  23811d:	mov    rax,0xffffffffffffffff
  238124:	jmp    237b98 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a8>
  238129:	mov    QWORD PTR [rsp+0x48],rsi
  23812e:	movaps XMMWORD PTR [rsp+0x80],xmm2
  238136:	mov    BYTE PTR [rsp+0xf],r11b
  23813b:	call   QWORD PTR [rip+0x311c3f]        # 549d80 <_DYNAMIC+0x458>
  238141:	mov    rdx,QWORD PTR [rip+0x311c30]        # 549d78 <_DYNAMIC+0x450>
  238148:	movzx  r11d,BYTE PTR [rsp+0xf]
  23814e:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  238156:	mov    rsi,QWORD PTR [rsp+0x48]
  23815b:	mov    r9d,DWORD PTR [rsp+0x38]
  238160:	mov    r8d,DWORD PTR [rsp+0x10]
  238165:	mov    rdi,QWORD PTR [rsp+0x18]
  23816a:	mov    cl,0x1
  23816c:	test   eax,0x80000
  238171:	je     237bde <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ee>
  238177:	jmp    238212 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  23817c:	mov    QWORD PTR [rsp+0x48],rsi
  238181:	movaps XMMWORD PTR [rsp+0x80],xmm2
  238189:	mov    BYTE PTR [rsp+0xf],r11b
  23818e:	call   QWORD PTR [rip+0x311bec]        # 549d80 <_DYNAMIC+0x458>
  238194:	mov    rdx,QWORD PTR [rip+0x311bdd]        # 549d78 <_DYNAMIC+0x450>
  23819b:	movzx  r11d,BYTE PTR [rsp+0xf]
  2381a1:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  2381a9:	mov    rsi,QWORD PTR [rsp+0x48]
  2381ae:	mov    r9d,DWORD PTR [rsp+0x38]
  2381b3:	mov    r8d,DWORD PTR [rsp+0x10]
  2381b8:	mov    rdi,QWORD PTR [rsp+0x18]
  2381bd:	test   ax,ax
  2381c0:	js     237bef <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ff>
  2381c6:	jmp    237c06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  2381cb:	mov    QWORD PTR [rsp+0x48],rsi
  2381d0:	movaps XMMWORD PTR [rsp+0x80],xmm2
  2381d8:	mov    BYTE PTR [rsp+0xf],r11b
  2381dd:	call   QWORD PTR [rip+0x311b9d]        # 549d80 <_DYNAMIC+0x458>
  2381e3:	movzx  r11d,BYTE PTR [rsp+0xf]
  2381e9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  2381f1:	mov    rsi,QWORD PTR [rsp+0x48]
  2381f6:	mov    r9d,DWORD PTR [rsp+0x38]
  2381fb:	mov    r8d,DWORD PTR [rsp+0x10]
  238200:	mov    rdi,QWORD PTR [rsp+0x18]
  238205:	bt     rax,0x37
  23820a:	jae    237c06 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  238210:	xor    ecx,ecx
  238212:	mov    r10,rsi
  238215:	mov    rax,QWORD PTR [rip+0x311b74]        # 549d90 <_DYNAMIC+0x468>
  23821c:	mov    rsi,QWORD PTR [rax]
  23821f:	test   r11b,r11b
  238222:	jne    23833c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd4c>
  238228:	mov    rax,r13
  23822b:	mul    QWORD PTR [rsp+0x40]
  238230:	jo     238351 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd61>
  238236:	mov    edx,esi
  238238:	and    edx,0x3
  23823b:	shr    rsi,0x2
  23823f:	cmp    rdx,0x1
  238243:	sbb    rsi,0xffffffffffffffff
  238247:	mov    rdx,QWORD PTR [rsp+0x168]
  23824f:	cmp    rdx,0x1
  238253:	adc    rdx,0x0
  238257:	cmp    rax,rsi
  23825a:	mov    eax,0x1
  23825f:	cmovae rax,rdx
  238263:	sub    rsp,0xa0
  23826a:	lea    rdx,[rsp+0x100]
  238272:	mov    QWORD PTR [rsp+0x88],rdx
  23827a:	movzx  edx,BYTE PTR [rsp+0xc0]
  238282:	mov    DWORD PTR [rsp+0x80],edx
  238289:	mov    rdx,QWORD PTR [rsp+0xf0]
  238291:	mov    QWORD PTR [rsp+0x78],rdx
  238296:	mov    rdx,QWORD PTR [rsp+0xc8]
  23829e:	mov    QWORD PTR [rsp+0x70],rdx
  2382a3:	mov    rdx,QWORD PTR [rsp+0xd0]
  2382ab:	mov    QWORD PTR [rsp+0x68],rdx
  2382b0:	xorps  xmm0,xmm0
  2382b3:	movups XMMWORD PTR [rsp+0x58],xmm0
  2382b8:	movzx  edx,r8b
  2382bc:	mov    DWORD PTR [rsp+0x50],edx
  2382c0:	mov    rdx,QWORD PTR [rsp+0xf8]
  2382c8:	mov    QWORD PTR [rsp+0x48],rdx
  2382cd:	mov    QWORD PTR [rsp+0x40],r10
  2382d2:	mov    QWORD PTR [rsp+0x38],rdi
  2382d7:	movzx  edx,r9b
  2382db:	mov    DWORD PTR [rsp+0x30],edx
  2382df:	movups XMMWORD PTR [rsp+0x18],xmm0
  2382e4:	mov    QWORD PTR [rsp+0x10],rbp
  2382e9:	mov    QWORD PTR [rsp+0x8],r14
  2382ee:	mov    QWORD PTR [rsp],rbx
  2382f2:	mov    QWORD PTR [rsp+0x90],rax
  2382fa:	mov    DWORD PTR [rsp+0x28],0x2
  238302:	movzx  edx,cl
  238305:	mov    r8,r15
  238308:	mov    edi,0x3
  23830d:	mov    r9,QWORD PTR [rsp+0xe0]
  238315:	mov    esi,0x1
  23831a:	mov    rcx,r12
  23831d:	call   QWORD PTR [rip+0x311a65]        # 549d88 <_DYNAMIC+0x460>
  238323:	add    rsp,0xa0
  23832a:	add    rsp,0x128
  238331:	pop    rbx
  238332:	pop    r12
  238334:	pop    r13
  238336:	pop    r14
  238338:	pop    r15
  23833a:	pop    rbp
  23833b:	ret
  23833c:	mov    r13,0xffffffffffffffff
  238343:	mov    rax,r13
  238346:	mul    QWORD PTR [rsp+0x40]
  23834b:	jno    238236 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc46>
  238351:	mov    rax,0xffffffffffffffff
  238358:	jmp    238236 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc46>
