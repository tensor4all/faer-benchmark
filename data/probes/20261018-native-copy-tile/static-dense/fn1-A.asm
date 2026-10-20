
target/faer-rev/7364be5ce22d-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001e3740 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  1e3740:	push   rbp
  1e3741:	push   r15
  1e3743:	push   r14
  1e3745:	push   r13
  1e3747:	push   r12
  1e3749:	push   rbx
  1e374a:	sub    rsp,0x108
  1e3751:	mov    DWORD PTR [rsp+0x30],esi
  1e3755:	mov    r12,QWORD PTR [rdi+0x8]
  1e3759:	test   r12,r12
  1e375c:	je     1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3762:	mov    r15,QWORD PTR [rdi+0x10]
  1e3766:	test   r15,r15
  1e3769:	je     1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e376f:	mov    rbx,QWORD PTR [rdi]
  1e3772:	mov    r14,QWORD PTR [rdi+0x18]
  1e3776:	mov    rax,QWORD PTR [rdi+0x20]
  1e377a:	mov    QWORD PTR [rsp+0x8],rax
  1e377f:	mov    r13,QWORD PTR [rdx+0x10]
  1e3783:	test   r13,r13
  1e3786:	je     1e383e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  1e378c:	mov    r11,r8
  1e378f:	mov    DWORD PTR [rsp+0x38],ecx
  1e3793:	mov    rax,QWORD PTR [rdx]
  1e3796:	mov    QWORD PTR [rsp+0x10],rax
  1e379b:	mov    rcx,QWORD PTR [rdx+0x8]
  1e379f:	mov    r8,QWORD PTR [rdx+0x18]
  1e37a3:	test   r14,r14
  1e37a6:	mov    QWORD PTR [rsp+0x20],rcx
  1e37ab:	jns    1e37e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  1e37ad:	lea    rax,[r12-0x1]
  1e37b2:	imul   rax,r14
  1e37b6:	neg    r14
  1e37b9:	xor    edi,edi
  1e37bb:	mov    r10,rcx
  1e37be:	sub    r10,0x1
  1e37c2:	cmovb  r10,rdi
  1e37c6:	lea    rbx,[rbx+rax*8]
  1e37ca:	mov    rax,r8
  1e37cd:	imul   rax,r10
  1e37d1:	cmp    r10,rcx
  1e37d4:	cmove  rax,rdi
  1e37d8:	mov    rcx,QWORD PTR [rsp+0x10]
  1e37dd:	lea    rcx,[rcx+rax*8]
  1e37e1:	mov    QWORD PTR [rsp+0x10],rcx
  1e37e6:	neg    r8
  1e37e9:	mov    QWORD PTR [rsp+0x28],r8
  1e37ee:	mov    rdi,QWORD PTR [rdx+0x20]
  1e37f2:	mov    r8,QWORD PTR [r11]
  1e37f5:	mov    rax,QWORD PTR [r11+0x8]
  1e37f9:	mov    QWORD PTR [rsp+0x18],rax
  1e37fe:	mov    rcx,QWORD PTR [r11+0x10]
  1e3802:	mov    rax,QWORD PTR [r11+0x20]
  1e3806:	cmp    QWORD PTR [rsp+0x8],0x0
  1e380c:	js     1e3895 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  1e3812:	mov    rsi,QWORD PTR [r11+0x18]
  1e3816:	test   rdi,rdi
  1e3819:	js     1e3901 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  1e381f:	mov    r10,QWORD PTR [rsp+0x148]
  1e3827:	mov    r11,QWORD PTR [rsp+0x140]
  1e382f:	cmp    r15,0x1
  1e3833:	je     1e3986 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  1e3839:	jmp    1e3a74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e383e:	cmp    BYTE PTR [rsp+0x30],0x0
  1e3843:	jne    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3849:	cmp    r12,0x1
  1e384d:	je     1e3863 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  1e384f:	cmp    r14,0xffffffffffffffff
  1e3853:	je     1e3fc4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  1e3859:	cmp    r14,0x1
  1e385d:	je     1e3d8d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64d>
  1e3863:	cmp    r15,0x1
  1e3867:	je     1e3d83 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  1e386d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  1e3873:	je     1e414a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0a>
  1e3879:	cmp    QWORD PTR [rsp+0x8],0x1
  1e387f:	jne    1e3d83 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  1e3885:	mov    rax,r15
  1e3888:	mov    r15,r12
  1e388b:	mov    QWORD PTR [rsp+0x8],r14
  1e3890:	jmp    1e4161 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  1e3895:	lea    rdx,[r15-0x1]
  1e3899:	mov    rsi,QWORD PTR [rsp+0x8]
  1e389e:	imul   rdx,rsi
  1e38a2:	lea    rbx,[rbx+rdx*8]
  1e38a6:	neg    rsi
  1e38a9:	mov    QWORD PTR [rsp+0x8],rsi
  1e38ae:	xor    edx,edx
  1e38b0:	mov    r10d,r9d
  1e38b3:	mov    r9,r8
  1e38b6:	mov    r8,rdi
  1e38b9:	mov    rdi,rcx
  1e38bc:	sub    rdi,0x1
  1e38c0:	cmovb  rdi,rdx
  1e38c4:	mov    rbp,r13
  1e38c7:	mov    r13,rax
  1e38ca:	imul   r13,rdi
  1e38ce:	cmp    rdi,rcx
  1e38d1:	mov    rdi,r8
  1e38d4:	mov    r8,r9
  1e38d7:	mov    r9d,r10d
  1e38da:	mov    r10,QWORD PTR [rsp+0x18]
  1e38df:	cmove  r13,rdx
  1e38e3:	test   r10,r10
  1e38e6:	cmove  r13,r10
  1e38ea:	lea    r8,[r8+r13*8]
  1e38ee:	mov    r13,rbp
  1e38f1:	neg    rax
  1e38f4:	mov    rsi,QWORD PTR [r11+0x18]
  1e38f8:	test   rdi,rdi
  1e38fb:	jns    1e381f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  1e3901:	lea    rdx,[r13-0x1]
  1e3905:	imul   rdx,rdi
  1e3909:	mov    r10,QWORD PTR [rsp+0x20]
  1e390e:	test   r10,r10
  1e3911:	cmove  rdx,r10
  1e3915:	mov    r10,rax
  1e3918:	mov    rax,QWORD PTR [rsp+0x10]
  1e391d:	lea    rax,[rax+rdx*8]
  1e3921:	mov    QWORD PTR [rsp+0x10],rax
  1e3926:	neg    rdi
  1e3929:	xor    edx,edx
  1e392b:	mov    rax,rdi
  1e392e:	mov    rbp,r13
  1e3931:	mov    r13,rsi
  1e3934:	mov    rsi,QWORD PTR [rsp+0x18]
  1e3939:	mov    rdi,rsi
  1e393c:	sub    rdi,0x1
  1e3940:	cmovb  rdi,rdx
  1e3944:	mov    r11,r13
  1e3947:	imul   r11,rdi
  1e394b:	test   rcx,rcx
  1e394e:	cmove  r11,rcx
  1e3952:	cmp    rdi,rsi
  1e3955:	mov    rsi,r13
  1e3958:	mov    r13,rbp
  1e395b:	mov    rdi,rax
  1e395e:	mov    rax,r10
  1e3961:	cmove  r11,rdx
  1e3965:	lea    r8,[r8+r11*8]
  1e3969:	neg    rsi
  1e396c:	mov    r10,QWORD PTR [rsp+0x148]
  1e3974:	mov    r11,QWORD PTR [rsp+0x140]
  1e397c:	cmp    r15,0x1
  1e3980:	jne    1e3a74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e3986:	cmp    QWORD PTR [rsp+0x28],0x1
  1e398c:	jne    1e39ff <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e398e:	cmp    r14,0x1
  1e3992:	jne    1e39ff <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e3994:	test   rbx,rbx
  1e3997:	je     1e39ff <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e3999:	mov    rax,QWORD PTR [rsp+0x10]
  1e399e:	mov    QWORD PTR [rsp+0x78],rax
  1e39a3:	mov    rax,QWORD PTR [rsp+0x20]
  1e39a8:	mov    QWORD PTR [rsp+0x80],rax
  1e39b0:	mov    QWORD PTR [rsp+0x88],r13
  1e39b8:	mov    QWORD PTR [rsp+0x90],rdi
  1e39c0:	mov    QWORD PTR [rsp+0x60],r8
  1e39c5:	mov    rax,QWORD PTR [rsp+0x18]
  1e39ca:	mov    QWORD PTR [rsp+0x68],rax
  1e39cf:	mov    QWORD PTR [rsp+0x70],rsi
  1e39d4:	sub    rsp,0x8
  1e39d8:	movzx  eax,r9b
  1e39dc:	movzx  edx,BYTE PTR [rsp+0x38]
  1e39e1:	movzx  r8d,BYTE PTR [rsp+0x40]
  1e39e7:	lea    rcx,[rsp+0x80]
  1e39ef:	lea    r9,[rsp+0x68]
  1e39f4:	mov    rdi,rbx
  1e39f7:	mov    rsi,r12
  1e39fa:	jmp    1e3af0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  1e39ff:	cmp    rdi,0x1
  1e3a03:	jne    1e3a74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e3a05:	cmp    rsi,0x1
  1e3a09:	jne    1e3a74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e3a0b:	test   r8,r8
  1e3a0e:	je     1e3a74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e3a10:	mov    rax,QWORD PTR [rsp+0x10]
  1e3a15:	mov    QWORD PTR [rsp+0x78],rax
  1e3a1a:	mov    rax,QWORD PTR [rsp+0x20]
  1e3a1f:	mov    QWORD PTR [rsp+0x80],rax
  1e3a27:	mov    QWORD PTR [rsp+0x88],r13
  1e3a2f:	mov    rax,QWORD PTR [rsp+0x28]
  1e3a34:	mov    QWORD PTR [rsp+0x90],rax
  1e3a3c:	mov    QWORD PTR [rsp+0x60],rbx
  1e3a41:	mov    QWORD PTR [rsp+0x68],r12
  1e3a46:	mov    QWORD PTR [rsp+0x70],r14
  1e3a4b:	sub    rsp,0x8
  1e3a4f:	movzx  eax,r9b
  1e3a53:	movzx  esi,BYTE PTR [rsp+0x38]
  1e3a58:	movzx  ecx,BYTE PTR [rsp+0x40]
  1e3a5d:	lea    rdi,[rsp+0x68]
  1e3a62:	lea    rdx,[rsp+0x80]
  1e3a6a:	mov    r9,QWORD PTR [rsp+0x20]
  1e3a6f:	jmp    1e3b77 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  1e3a74:	cmp    r12,0x1
  1e3a78:	jne    1e3b8a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e3a7e:	xor    edx,edx
  1e3a80:	cmp    QWORD PTR [rsp+0x8],0x1
  1e3a86:	cmove  rdx,rbx
  1e3a8a:	cmp    rax,0x1
  1e3a8e:	jne    1e3b03 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1e3a90:	test   rdx,rdx
  1e3a93:	je     1e3b03 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1e3a95:	mov    QWORD PTR [rsp+0x78],r8
  1e3a9a:	mov    QWORD PTR [rsp+0x80],rcx
  1e3aa2:	mov    rax,QWORD PTR [rsp+0x18]
  1e3aa7:	mov    QWORD PTR [rsp+0x88],rax
  1e3aaf:	mov    QWORD PTR [rsp+0x90],rsi
  1e3ab7:	mov    rax,QWORD PTR [rsp+0x10]
  1e3abc:	mov    QWORD PTR [rsp+0x60],rax
  1e3ac1:	mov    QWORD PTR [rsp+0x68],r13
  1e3ac6:	mov    QWORD PTR [rsp+0x70],rdi
  1e3acb:	sub    rsp,0x8
  1e3acf:	movzx  eax,BYTE PTR [rsp+0x40]
  1e3ad4:	movzx  edx,BYTE PTR [rsp+0x38]
  1e3ad9:	movzx  r8d,r9b
  1e3add:	lea    rcx,[rsp+0x80]
  1e3ae5:	lea    r9,[rsp+0x68]
  1e3aea:	mov    rdi,rbx
  1e3aed:	mov    rsi,r15
  1e3af0:	push   r10
  1e3af2:	push   r11
  1e3af4:	push   rax
  1e3af5:	call   158120 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  1e3afa:	add    rsp,0x20
  1e3afe:	jmp    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3b03:	xor    edx,edx
  1e3b05:	cmp    rdi,0x1
  1e3b09:	cmove  rdx,QWORD PTR [rsp+0x10]
  1e3b0f:	cmp    rsi,0x1
  1e3b13:	jne    1e3b8a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e3b15:	test   rdx,rdx
  1e3b18:	je     1e3b8a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e3b1a:	mov    QWORD PTR [rsp+0x78],r8
  1e3b1f:	mov    QWORD PTR [rsp+0x80],rcx
  1e3b27:	mov    rcx,QWORD PTR [rsp+0x18]
  1e3b2c:	mov    QWORD PTR [rsp+0x88],rcx
  1e3b34:	mov    QWORD PTR [rsp+0x90],rax
  1e3b3c:	mov    QWORD PTR [rsp+0x60],rbx
  1e3b41:	mov    QWORD PTR [rsp+0x68],r15
  1e3b46:	mov    rax,QWORD PTR [rsp+0x8]
  1e3b4b:	mov    QWORD PTR [rsp+0x70],rax
  1e3b50:	sub    rsp,0x8
  1e3b54:	movzx  eax,BYTE PTR [rsp+0x40]
  1e3b59:	movzx  esi,BYTE PTR [rsp+0x38]
  1e3b5e:	movzx  ecx,r9b
  1e3b62:	lea    rdi,[rsp+0x68]
  1e3b67:	lea    rdx,[rsp+0x80]
  1e3b6f:	mov    r8,QWORD PTR [rsp+0x18]
  1e3b74:	mov    r9,r13
  1e3b77:	push   r10
  1e3b79:	push   r11
  1e3b7b:	push   rax
  1e3b7c:	call   1f7110 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  1e3b81:	add    rsp,0x20
  1e3b85:	jmp    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3b8a:	cmp    r13,0x1
  1e3b8e:	jne    1e3c98 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e3b94:	xor    edx,edx
  1e3b96:	cmp    r14,0x1
  1e3b9a:	cmove  rdx,rbx
  1e3b9e:	cmp    QWORD PTR [rsp+0x28],0x1
  1e3ba4:	jne    1e3c0d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1e3ba6:	test   rdx,rdx
  1e3ba9:	je     1e3c0d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1e3bab:	mov    QWORD PTR [rsp+0x78],rdx
  1e3bb0:	mov    QWORD PTR [rsp+0x80],r12
  1e3bb8:	mov    QWORD PTR [rsp+0x88],r15
  1e3bc0:	mov    rdx,QWORD PTR [rsp+0x8]
  1e3bc5:	mov    QWORD PTR [rsp+0x90],rdx
  1e3bcd:	mov    QWORD PTR [rsp+0x60],r8
  1e3bd2:	mov    QWORD PTR [rsp+0x68],rcx
  1e3bd7:	mov    QWORD PTR [rsp+0x70],rax
  1e3bdc:	sub    rsp,0x8
  1e3be0:	mov    r14,r10
  1e3be3:	movzx  r10d,r9b
  1e3be7:	movzx  esi,BYTE PTR [rsp+0x38]
  1e3bec:	movzx  r8d,BYTE PTR [rsp+0x40]
  1e3bf2:	lea    rdi,[rsp+0x80]
  1e3bfa:	lea    r9,[rsp+0x68]
  1e3bff:	mov    rdx,QWORD PTR [rsp+0x18]
  1e3c04:	mov    rcx,QWORD PTR [rsp+0x28]
  1e3c09:	push   r14
  1e3c0b:	jmp    1e3c86 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  1e3c0d:	xor    edx,edx
  1e3c0f:	cmp    QWORD PTR [rsp+0x8],0x1
  1e3c15:	cmove  rdx,rbx
  1e3c19:	cmp    rax,0x1
  1e3c1d:	jne    1e3c98 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e3c1f:	test   rdx,rdx
  1e3c22:	je     1e3c98 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e3c24:	mov    QWORD PTR [rsp+0x78],rdx
  1e3c29:	mov    QWORD PTR [rsp+0x80],r15
  1e3c31:	mov    QWORD PTR [rsp+0x88],r12
  1e3c39:	mov    QWORD PTR [rsp+0x90],r14
  1e3c41:	mov    rax,QWORD PTR [rsp+0x10]
  1e3c46:	mov    QWORD PTR [rsp+0x60],rax
  1e3c4b:	mov    rax,QWORD PTR [rsp+0x20]
  1e3c50:	mov    QWORD PTR [rsp+0x68],rax
  1e3c55:	mov    rax,QWORD PTR [rsp+0x28]
  1e3c5a:	mov    QWORD PTR [rsp+0x70],rax
  1e3c5f:	sub    rsp,0x8
  1e3c63:	mov    rax,r10
  1e3c66:	movzx  r10d,BYTE PTR [rsp+0x40]
  1e3c6c:	movzx  esi,BYTE PTR [rsp+0x38]
  1e3c71:	mov    rdx,r8
  1e3c74:	movzx  r8d,r9b
  1e3c78:	lea    rdi,[rsp+0x80]
  1e3c80:	lea    r9,[rsp+0x68]
  1e3c85:	push   rax
  1e3c86:	push   r11
  1e3c88:	push   r10
  1e3c8a:	call   155fa0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  1e3c8f:	add    rsp,0x20
  1e3c93:	jmp    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3c98:	mov    QWORD PTR [rsp+0x18],rax
  1e3c9d:	movsd  xmm1,QWORD PTR [r11]
  1e3ca2:	movsd  QWORD PTR [rsp+0x60],xmm1
  1e3ca8:	mov    rax,r12
  1e3cab:	mul    r15
  1e3cae:	mov    rbp,rax
  1e3cb1:	jo     1e41e5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  1e3cb7:	mul    r13
  1e3cba:	seto   cl
  1e3cbd:	not    cl
  1e3cbf:	cmp    rax,0x1001
  1e3cc5:	setb   al
  1e3cc8:	test   cl,al
  1e3cca:	jne    1e3d27 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5e7>
  1e3ccc:	mov    rdx,QWORD PTR [rip+0x366645]        # 54a318 <_DYNAMIC+0x540>
  1e3cd3:	mov    rax,QWORD PTR [rdx]
  1e3cd6:	test   rax,rax
  1e3cd9:	je     1e41f1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  1e3cdf:	mov    cl,0x1
  1e3ce1:	test   eax,0x80000
  1e3ce6:	jne    1e42f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  1e3cec:	mov    rax,QWORD PTR [rdx]
  1e3cef:	test   rax,rax
  1e3cf2:	je     1e424c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb0c>
  1e3cf8:	test   ax,ax
  1e3cfb:	jns    1e3d14 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1e3cfd:	mov    rax,QWORD PTR [rdx]
  1e3d00:	test   rax,rax
  1e3d03:	je     1e42a3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb63>
  1e3d09:	bt     rax,0x37
  1e3d0e:	jb     1e42f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb0>
  1e3d14:	cmp    BYTE PTR [rsp+0x30],0x0
  1e3d19:	jne    1e3fcc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  1e3d1f:	xorps  xmm0,xmm0
  1e3d22:	jmp    1e3fd4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  1e3d27:	cmp    BYTE PTR [rsp+0x30],0x0
  1e3d2c:	mov    ecx,DWORD PTR [rsp+0x38]
  1e3d30:	jne    1e3d95 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x655>
  1e3d32:	xorps  xmm0,xmm0
  1e3d35:	movsd  QWORD PTR [rsp+0x30],xmm0
  1e3d3b:	mov    rax,r13
  1e3d3e:	cmp    QWORD PTR [rsp+0x8],r14
  1e3d43:	jb     1e3dad <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66d>
  1e3d45:	mov    ebp,r9d
  1e3d48:	mov    r9d,ecx
  1e3d4b:	mov    rcx,QWORD PTR [rsp+0x18]
  1e3d50:	mov    QWORD PTR [rsp+0x38],rcx
  1e3d55:	mov    QWORD PTR [rsp+0x40],rsi
  1e3d5a:	mov    QWORD PTR [rsp+0x58],r8
  1e3d5f:	mov    rsi,rdi
  1e3d62:	mov    rcx,QWORD PTR [rsp+0x28]
  1e3d67:	mov    r8,QWORD PTR [rsp+0x10]
  1e3d6c:	mov    rdx,QWORD PTR [rsp+0x8]
  1e3d71:	mov    QWORD PTR [rsp+0x10],rdx
  1e3d76:	mov    QWORD PTR [rsp+0x8],r14
  1e3d7b:	mov    r13,r15
  1e3d7e:	mov    r15,r12
  1e3d81:	jmp    1e3dd5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x695>
  1e3d83:	cmp    r14,0x1
  1e3d87:	jne    1e3f06 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c6>
  1e3d8d:	mov    rax,r12
  1e3d90:	jmp    1e4161 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  1e3d95:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5bd2b]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1e3d9d:	movsd  QWORD PTR [rsp+0x30],xmm0
  1e3da3:	mov    rax,r13
  1e3da6:	cmp    QWORD PTR [rsp+0x8],r14
  1e3dab:	jae    1e3d45 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x605>
  1e3dad:	mov    ebp,ecx
  1e3daf:	mov    rcx,QWORD PTR [rsp+0x28]
  1e3db4:	mov    QWORD PTR [rsp+0x38],rcx
  1e3db9:	mov    QWORD PTR [rsp+0x40],rdi
  1e3dbe:	mov    rcx,QWORD PTR [rsp+0x10]
  1e3dc3:	mov    QWORD PTR [rsp+0x58],rcx
  1e3dc8:	mov    QWORD PTR [rsp+0x10],r14
  1e3dcd:	mov    r13,r12
  1e3dd0:	mov    rcx,QWORD PTR [rsp+0x18]
  1e3dd5:	movsd  QWORD PTR [rsp+0x20],xmm1
  1e3ddb:	mov    QWORD PTR [rsp+0x48],rsi
  1e3de0:	mov    QWORD PTR [rsp+0x50],r8
  1e3de5:	mov    r14d,r9d
  1e3de8:	mov    QWORD PTR [rsp+0x18],rcx
  1e3ded:	cmp    rcx,0x1
  1e3df1:	jne    1e3e1b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  1e3df3:	cmp    QWORD PTR [rsp+0x8],0x1
  1e3df9:	jne    1e3e1b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  1e3dfb:	lea    r8,[rip+0x357496]        # 53b298 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x410>
  1e3e02:	lea    rdi,[rsp+0x78]
  1e3e07:	mov    rsi,r15
  1e3e0a:	mov    rdx,r13
  1e3e0d:	mov    r12,rax
  1e3e10:	mov    rcx,rax
  1e3e13:	call   QWORD PTR [rip+0x3666a7]        # 54a4c0 <_DYNAMIC+0x6e8>
  1e3e19:	jmp    1e3e39 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f9>
  1e3e1b:	lea    r8,[rip+0x35748e]        # 53b2b0 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x428>
  1e3e22:	lea    rdi,[rsp+0x78]
  1e3e27:	mov    rsi,r15
  1e3e2a:	mov    rdx,r13
  1e3e2d:	mov    r12,rax
  1e3e30:	mov    rcx,rax
  1e3e33:	call   QWORD PTR [rip+0x36668f]        # 54a4c8 <_DYNAMIC+0x6f0>
  1e3e39:	lea    rdi,[rsp+0x80]
  1e3e41:	mov    rsi,QWORD PTR [rsp+0xa0]
  1e3e49:	mov    rdx,QWORD PTR [rsp+0xa8]
  1e3e51:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  1e3e59:	sub    rsp,0x70
  1e3e5d:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e3e62:	movzx  eax,bpl
  1e3e66:	mov    DWORD PTR [rsp+0x50],eax
  1e3e6a:	movzx  eax,r14b
  1e3e6e:	mov    DWORD PTR [rsp+0x48],eax
  1e3e72:	mov    rax,QWORD PTR [rsp+0xa8]
  1e3e7a:	mov    QWORD PTR [rsp+0x40],rax
  1e3e7f:	mov    rax,QWORD PTR [rsp+0xb0]
  1e3e87:	mov    QWORD PTR [rsp+0x38],rax
  1e3e8c:	mov    rax,QWORD PTR [rsp+0xc8]
  1e3e94:	mov    QWORD PTR [rsp+0x30],rax
  1e3e99:	mov    rax,QWORD PTR [rsp+0xb8]
  1e3ea1:	mov    QWORD PTR [rsp+0x28],rax
  1e3ea6:	mov    rax,QWORD PTR [rsp+0x88]
  1e3eae:	mov    QWORD PTR [rsp+0x20],rax
  1e3eb3:	mov    rax,QWORD PTR [rsp+0xc0]
  1e3ebb:	mov    QWORD PTR [rsp+0x18],rax
  1e3ec0:	mov    rax,QWORD PTR [rsp+0x80]
  1e3ec8:	mov    QWORD PTR [rsp+0x10],rax
  1e3ecd:	mov    rax,QWORD PTR [rsp+0x78]
  1e3ed2:	mov    QWORD PTR [rsp+0x8],rax
  1e3ed7:	mov    QWORD PTR [rsp],rbx
  1e3edb:	mov    r8,r13
  1e3ede:	mov    r9,r12
  1e3ee1:	mov    rcx,r15
  1e3ee4:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  1e3eed:	movsd  xmm1,QWORD PTR [rsp+0x90]
  1e3ef6:	call   QWORD PTR [rsp+0xe8]
  1e3efd:	add    rsp,0x70
  1e3f01:	jmp    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3f06:	lea    rax,[r12-0x1]
  1e3f0b:	mov    ecx,r12d
  1e3f0e:	and    ecx,0x3
  1e3f11:	and    r12,0xfffffffffffffffc
  1e3f15:	lea    rdx,[r14*8+0x0]
  1e3f1d:	lea    rsi,[rdx+rdx*2]
  1e3f21:	shl    QWORD PTR [rsp+0x8],0x3
  1e3f27:	mov    rdi,r14
  1e3f2a:	shl    rdi,0x5
  1e3f2e:	mov    r8,r14
  1e3f31:	shl    r8,0x4
  1e3f35:	xor    r9d,r9d
  1e3f38:	jmp    1e3f51 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  1e3f3a:	nop    WORD PTR [rax+rax*1+0x0]
  1e3f40:	inc    r9
  1e3f43:	add    rbx,QWORD PTR [rsp+0x8]
  1e3f48:	cmp    r9,r15
  1e3f4b:	je     1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e3f51:	cmp    rax,0x3
  1e3f55:	jae    1e3f60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  1e3f57:	xor    r10d,r10d
  1e3f5a:	jmp    1e3fa0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  1e3f5c:	nop    DWORD PTR [rax+0x0]
  1e3f60:	mov    r11,rbx
  1e3f63:	xor    r10d,r10d
  1e3f66:	cs nop WORD PTR [rax+rax*1+0x0]
  1e3f70:	mov    QWORD PTR [r11],0x0
  1e3f77:	mov    QWORD PTR [r11+r14*8],0x0
  1e3f7f:	mov    QWORD PTR [r11+r8*1],0x0
  1e3f87:	add    r10,0x4
  1e3f8b:	mov    QWORD PTR [r11+rsi*1],0x0
  1e3f93:	add    r11,rdi
  1e3f96:	cmp    r12,r10
  1e3f99:	jne    1e3f70 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  1e3f9b:	test   rcx,rcx
  1e3f9e:	je     1e3f40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1e3fa0:	imul   r10,rdx
  1e3fa4:	add    r10,rbx
  1e3fa7:	mov    r11,rcx
  1e3faa:	nop    WORD PTR [rax+rax*1+0x0]
  1e3fb0:	mov    QWORD PTR [r10],0x0
  1e3fb7:	add    r10,rdx
  1e3fba:	dec    r11
  1e3fbd:	jne    1e3fb0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  1e3fbf:	jmp    1e3f40 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1e3fc4:	mov    rax,r12
  1e3fc7:	jmp    1e4155 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa15>
  1e3fcc:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5baf4]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1e3fd4:	xor    r11d,r11d
  1e3fd7:	test   r10,r10
  1e3fda:	setne  dl
  1e3fdd:	cmp    QWORD PTR [rsp+0x8],r14
  1e3fe2:	jge    1e3ff9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b9>
  1e3fe4:	mov    rcx,QWORD PTR [rsp+0x18]
  1e3fe9:	mov    rbp,rsi
  1e3fec:	mov    rax,r8
  1e3fef:	mov    r8,r14
  1e3ff2:	mov    r9,QWORD PTR [rsp+0x28]
  1e3ff7:	jmp    1e4033 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f3>
  1e3ff9:	mov    rcx,QWORD PTR [rsp+0x28]
  1e3ffe:	mov    rbp,rdi
  1e4001:	mov    rax,QWORD PTR [rsp+0x10]
  1e4006:	mov    QWORD PTR [rsp+0x28],rax
  1e400b:	mov    r10,QWORD PTR [rsp+0x8]
  1e4010:	mov    rax,r12
  1e4013:	mov    r9,QWORD PTR [rsp+0x18]
  1e4018:	mov    rdi,rsi
  1e401b:	mov    QWORD PTR [rsp+0x10],r8
  1e4020:	mov    r8,r10
  1e4023:	mov    QWORD PTR [rsp+0x8],r14
  1e4028:	mov    r12,r15
  1e402b:	mov    r15,rax
  1e402e:	mov    rax,QWORD PTR [rsp+0x28]
  1e4033:	mov    r11b,dl
  1e4036:	mov    QWORD PTR [rsp+0x18],r15
  1e403b:	lea    rdx,[r15-0x1]
  1e403f:	imul   rdx,rcx
  1e4043:	mov    r14,rcx
  1e4046:	neg    r14
  1e4049:	mov    rsi,QWORD PTR [rsp+0x8]
  1e404e:	test   rsi,rsi
  1e4051:	cmovns r14,rcx
  1e4055:	mov    rcx,rsi
  1e4058:	sar    rcx,0x3f
  1e405c:	and    rcx,rdx
  1e405f:	lea    rdx,[rax+rcx*8]
  1e4063:	lea    rax,[r12-0x1]
  1e4068:	imul   rax,r9
  1e406c:	mov    r15,r9
  1e406f:	neg    r15
  1e4072:	test   r8,r8
  1e4075:	cmovns r15,r9
  1e4079:	mov    rcx,r8
  1e407c:	sar    rcx,0x3f
  1e4080:	and    rcx,rax
  1e4083:	mov    rax,QWORD PTR [rsp+0x10]
  1e4088:	lea    rsi,[rax+rcx*8]
  1e408c:	test   rbp,rbp
  1e408f:	jns    1e40ae <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x96e>
  1e4091:	lea    rax,[r13-0x1]
  1e4095:	mov    rcx,rbp
  1e4098:	imul   rcx,rax
  1e409c:	lea    rdx,[rdx+rcx*8]
  1e40a0:	neg    rbp
  1e40a3:	imul   rax,rdi
  1e40a7:	lea    rsi,[rsi+rax*8]
  1e40ab:	neg    rdi
  1e40ae:	mov    QWORD PTR [rsp+0x28],rsi
  1e40b3:	mov    QWORD PTR [rsp+0x10],rdx
  1e40b8:	mov    QWORD PTR [rsp+0x40],rdi
  1e40bd:	mov    rax,QWORD PTR [rip+0x36640c]        # 54a4d0 <_DYNAMIC+0x6f8>
  1e40c4:	mov    rax,QWORD PTR [rax]
  1e40c7:	test   rax,rax
  1e40ca:	jne    1e4104 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c4>
  1e40cc:	movsd  QWORD PTR [rsp+0x20],xmm1
  1e40d2:	movsd  QWORD PTR [rsp+0x38],xmm0
  1e40d8:	mov    QWORD PTR [rsp+0x50],rbp
  1e40dd:	mov    rbp,r11
  1e40e0:	mov    QWORD PTR [rsp+0x48],r8
  1e40e5:	call   QWORD PTR [rip+0x3663ed]        # 54a4d8 <_DYNAMIC+0x700>
  1e40eb:	mov    r8,QWORD PTR [rsp+0x48]
  1e40f0:	mov    r11,rbp
  1e40f3:	mov    rbp,QWORD PTR [rsp+0x50]
  1e40f8:	movsd  xmm0,QWORD PTR [rsp+0x38]
  1e40fe:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1e4104:	movzx  r10d,BYTE PTR [rsp+0x30]
  1e410a:	mov    rdi,QWORD PTR [rsp+0x18]
  1e410f:	mov    rsi,r12
  1e4112:	mov    rdx,r13
  1e4115:	mov    rcx,rbx
  1e4118:	mov    r9,QWORD PTR [rsp+0x8]
  1e411d:	push   QWORD PTR [rsp+0x148]
  1e4124:	push   r11
  1e4126:	push   0x0
  1e4128:	push   0x0
  1e412a:	push   0x0
  1e412c:	push   QWORD PTR [rsp+0x68]
  1e4130:	push   r15
  1e4132:	push   QWORD PTR [rsp+0x60]
  1e4136:	push   r14
  1e4138:	push   rbp
  1e4139:	push   QWORD PTR [rsp+0x60]
  1e413d:	push   r10
  1e413f:	call   rax
  1e4141:	add    rsp,0x60
  1e4145:	jmp    1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e414a:	mov    rax,r15
  1e414d:	mov    r15,r12
  1e4150:	mov    QWORD PTR [rsp+0x8],r14
  1e4155:	mov    ecx,0x1
  1e415a:	sub    rcx,rax
  1e415d:	lea    rbx,[rbx+rcx*8]
  1e4161:	lea    rcx,[rax-0x1]
  1e4165:	mov    edx,eax
  1e4167:	and    edx,0x3
  1e416a:	and    rax,0xfffffffffffffffc
  1e416e:	xor    esi,esi
  1e4170:	xorps  xmm0,xmm0
  1e4173:	jmp    1e418c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  1e4175:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e4180:	inc    rsi
  1e4183:	cmp    rsi,r15
  1e4186:	je     1e43d4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1e418c:	mov    rdi,rsi
  1e418f:	imul   rdi,QWORD PTR [rsp+0x8]
  1e4195:	lea    rdi,[rbx+rdi*8]
  1e4199:	cmp    rcx,0x3
  1e419d:	jb     1e41c9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  1e419f:	xor    r8d,r8d
  1e41a2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e41b0:	movups XMMWORD PTR [rdi],xmm0
  1e41b3:	movups XMMWORD PTR [rdi+0x10],xmm0
  1e41b7:	add    rdi,0x20
  1e41bb:	add    r8,0x4
  1e41bf:	cmp    rax,r8
  1e41c2:	jne    1e41b0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  1e41c4:	test   rdx,rdx
  1e41c7:	je     1e4180 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1e41c9:	xor    r8d,r8d
  1e41cc:	nop    DWORD PTR [rax+0x0]
  1e41d0:	mov    QWORD PTR [rdi],0x0
  1e41d7:	add    rdi,0x8
  1e41db:	inc    r8
  1e41de:	cmp    rdx,r8
  1e41e1:	jne    1e41d0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  1e41e3:	jmp    1e4180 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1e41e5:	mov    rax,0xffffffffffffffff
  1e41ec:	jmp    1e3cb7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x577>
  1e41f1:	mov    DWORD PTR [rsp+0x58],r9d
  1e41f6:	mov    QWORD PTR [rsp+0x40],rdi
  1e41fb:	mov    QWORD PTR [rsp+0x50],r8
  1e4200:	mov    QWORD PTR [rsp+0x48],rsi
  1e4205:	movsd  QWORD PTR [rsp+0x20],xmm1
  1e420b:	call   QWORD PTR [rip+0x36610f]        # 54a320 <_DYNAMIC+0x548>
  1e4211:	mov    rdx,QWORD PTR [rip+0x366100]        # 54a318 <_DYNAMIC+0x540>
  1e4218:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1e421e:	mov    rsi,QWORD PTR [rsp+0x48]
  1e4223:	mov    r10,QWORD PTR [rsp+0x148]
  1e422b:	mov    r8,QWORD PTR [rsp+0x50]
  1e4230:	mov    rdi,QWORD PTR [rsp+0x40]
  1e4235:	mov    r9d,DWORD PTR [rsp+0x58]
  1e423a:	mov    cl,0x1
  1e423c:	test   eax,0x80000
  1e4241:	je     1e3cec <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ac>
  1e4247:	jmp    1e42f2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  1e424c:	mov    DWORD PTR [rsp+0x58],r9d
  1e4251:	mov    QWORD PTR [rsp+0x40],rdi
  1e4256:	mov    QWORD PTR [rsp+0x50],r8
  1e425b:	mov    QWORD PTR [rsp+0x48],rsi
  1e4260:	movsd  QWORD PTR [rsp+0x20],xmm1
  1e4266:	call   QWORD PTR [rip+0x3660b4]        # 54a320 <_DYNAMIC+0x548>
  1e426c:	mov    rdx,QWORD PTR [rip+0x3660a5]        # 54a318 <_DYNAMIC+0x540>
  1e4273:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1e4279:	mov    rsi,QWORD PTR [rsp+0x48]
  1e427e:	mov    r10,QWORD PTR [rsp+0x148]
  1e4286:	mov    r8,QWORD PTR [rsp+0x50]
  1e428b:	mov    rdi,QWORD PTR [rsp+0x40]
  1e4290:	mov    r9d,DWORD PTR [rsp+0x58]
  1e4295:	test   ax,ax
  1e4298:	js     1e3cfd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5bd>
  1e429e:	jmp    1e3d14 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1e42a3:	mov    DWORD PTR [rsp+0x58],r9d
  1e42a8:	mov    QWORD PTR [rsp+0x40],rdi
  1e42ad:	mov    QWORD PTR [rsp+0x50],r8
  1e42b2:	mov    QWORD PTR [rsp+0x48],rsi
  1e42b7:	movsd  QWORD PTR [rsp+0x20],xmm1
  1e42bd:	call   QWORD PTR [rip+0x36605d]        # 54a320 <_DYNAMIC+0x548>
  1e42c3:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1e42c9:	mov    rsi,QWORD PTR [rsp+0x48]
  1e42ce:	mov    r10,QWORD PTR [rsp+0x148]
  1e42d6:	mov    r8,QWORD PTR [rsp+0x50]
  1e42db:	mov    rdi,QWORD PTR [rsp+0x40]
  1e42e0:	mov    r9d,DWORD PTR [rsp+0x58]
  1e42e5:	bt     rax,0x37
  1e42ea:	jae    1e3d14 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1e42f0:	xor    ecx,ecx
  1e42f2:	imul   rbp,r13
  1e42f6:	cmp    r10,0x1
  1e42fa:	adc    r10,0x0
  1e42fe:	cmp    rbp,0x8000
  1e4305:	mov    eax,0x1
  1e430a:	cmovae rax,r10
  1e430e:	sub    rsp,0xa0
  1e4315:	lea    rdx,[rsp+0x100]
  1e431d:	mov    QWORD PTR [rsp+0x88],rdx
  1e4325:	movzx  edx,r9b
  1e4329:	mov    DWORD PTR [rsp+0x80],edx
  1e4330:	mov    rdx,QWORD PTR [rsp+0xb8]
  1e4338:	mov    QWORD PTR [rsp+0x78],rdx
  1e433d:	mov    QWORD PTR [rsp+0x70],rsi
  1e4342:	mov    QWORD PTR [rsp+0x68],r8
  1e4347:	xorps  xmm0,xmm0
  1e434a:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e434f:	movzx  edx,BYTE PTR [rsp+0xd8]
  1e4357:	mov    DWORD PTR [rsp+0x50],edx
  1e435b:	mov    QWORD PTR [rsp+0x48],rdi
  1e4360:	mov    rdx,QWORD PTR [rsp+0xc8]
  1e4368:	mov    QWORD PTR [rsp+0x40],rdx
  1e436d:	mov    rdx,QWORD PTR [rsp+0xb0]
  1e4375:	mov    QWORD PTR [rsp+0x38],rdx
  1e437a:	movzx  edx,BYTE PTR [rsp+0xd0]
  1e4382:	mov    DWORD PTR [rsp+0x30],edx
  1e4386:	movups XMMWORD PTR [rsp+0x18],xmm0
  1e438b:	mov    rdx,QWORD PTR [rsp+0xa8]
  1e4393:	mov    QWORD PTR [rsp+0x10],rdx
  1e4398:	mov    QWORD PTR [rsp+0x8],r14
  1e439d:	mov    QWORD PTR [rsp],rbx
  1e43a1:	mov    QWORD PTR [rsp+0x90],rax
  1e43a9:	mov    DWORD PTR [rsp+0x28],0x2
  1e43b1:	movzx  edx,cl
  1e43b4:	mov    r8,r15
  1e43b7:	mov    edi,0x1
  1e43bc:	mov    r9,r13
  1e43bf:	mov    esi,0x1
  1e43c4:	mov    rcx,r12
  1e43c7:	call   QWORD PTR [rip+0x365f5b]        # 54a328 <_DYNAMIC+0x550>
  1e43cd:	add    rsp,0xa0
  1e43d4:	add    rsp,0x108
  1e43db:	pop    rbx
  1e43dc:	pop    r12
  1e43de:	pop    r13
  1e43e0:	pop    r14
  1e43e2:	pop    r15
  1e43e4:	pop    rbp
  1e43e5:	ret
