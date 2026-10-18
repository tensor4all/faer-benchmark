
target/faer-rev/7cd372f40449-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000214960 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  214960:	push   rbp
  214961:	push   r15
  214963:	push   r14
  214965:	push   r13
  214967:	push   r12
  214969:	push   rbx
  21496a:	sub    rsp,0x118
  214971:	mov    r12,QWORD PTR [rdi+0x8]
  214975:	test   r12,r12
  214978:	je     2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21497e:	mov    rbx,QWORD PTR [rdi+0x10]
  214982:	test   rbx,rbx
  214985:	je     2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21498b:	mov    r10d,r9d
  21498e:	mov    r14,QWORD PTR [rdi]
  214991:	mov    r9,QWORD PTR [rdi+0x18]
  214995:	mov    r15,QWORD PTR [rdi+0x20]
  214999:	mov    rax,QWORD PTR [rdx+0x10]
  21499d:	test   rax,rax
  2149a0:	je     214a43 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xe3>
  2149a6:	mov    r13d,ecx
  2149a9:	mov    rdi,QWORD PTR [rdx]
  2149ac:	mov    r11,QWORD PTR [rdx+0x8]
  2149b0:	mov    rcx,QWORD PTR [rdx+0x18]
  2149b4:	test   r9,r9
  2149b7:	mov    QWORD PTR [rsp+0x20],rax
  2149bc:	mov    DWORD PTR [rsp+0x8],esi
  2149c0:	mov    QWORD PTR [rsp+0x10],r11
  2149c5:	mov    DWORD PTR [rsp+0x4],r10d
  2149ca:	jns    214a0a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa>
  2149cc:	lea    rax,[r12-0x1]
  2149d1:	imul   rax,r9
  2149d5:	shl    rax,0x4
  2149d9:	add    r14,rax
  2149dc:	neg    r9
  2149df:	xor    eax,eax
  2149e1:	mov    rsi,r11
  2149e4:	sub    rsi,0x1
  2149e8:	cmovb  rsi,rax
  2149ec:	mov    r10,rdi
  2149ef:	mov    rdi,rcx
  2149f2:	imul   rdi,rsi
  2149f6:	cmp    rsi,r11
  2149f9:	cmove  rdi,rax
  2149fd:	shl    rdi,0x4
  214a01:	add    r10,rdi
  214a04:	mov    rdi,r10
  214a07:	neg    rcx
  214a0a:	mov    QWORD PTR [rsp+0x60],rcx
  214a0f:	mov    r11,QWORD PTR [rdx+0x20]
  214a13:	mov    rsi,QWORD PTR [r8]
  214a16:	mov    r10,QWORD PTR [r8+0x8]
  214a1a:	mov    rcx,QWORD PTR [r8+0x10]
  214a1e:	mov    rbp,QWORD PTR [r8+0x20]
  214a22:	test   r15,r15
  214a25:	mov    QWORD PTR [rsp+0x28],r10
  214a2a:	js     214a92 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x132>
  214a2c:	mov    rax,QWORD PTR [r8+0x18]
  214a30:	test   r11,r11
  214a33:	js     214afa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x19a>
  214a39:	mov    QWORD PTR [rsp+0x18],r11
  214a3e:	jmp    214b59 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1f9>
  214a43:	test   sil,sil
  214a46:	jne    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214a4c:	cmp    r12,0x1
  214a50:	je     214a66 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x106>
  214a52:	cmp    r9,0xffffffffffffffff
  214a56:	je     21518e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x82e>
  214a5c:	cmp    r9,0x1
  214a60:	je     214f8a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x62a>
  214a66:	cmp    rbx,0x1
  214a6a:	je     214f80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x620>
  214a70:	cmp    r15,0xffffffffffffffff
  214a74:	je     2151f1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x891>
  214a7a:	cmp    r15,0x1
  214a7e:	jne    214f80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x620>
  214a84:	mov    rax,rbx
  214a87:	mov    rbx,r12
  214a8a:	mov    r15,r9
  214a8d:	jmp    215209 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a9>
  214a92:	lea    rdx,[rbx-0x1]
  214a96:	imul   rdx,r15
  214a9a:	shl    rdx,0x4
  214a9e:	add    r14,rdx
  214aa1:	neg    r15
  214aa4:	xor    edx,edx
  214aa6:	mov    r10,r11
  214aa9:	mov    r11,rsi
  214aac:	mov    rsi,rcx
  214aaf:	sub    rsi,0x1
  214ab3:	cmovb  rsi,rdx
  214ab7:	mov    eax,r13d
  214aba:	mov    r13,rdi
  214abd:	mov    rdi,rbp
  214ac0:	imul   rdi,rsi
  214ac4:	cmp    rsi,rcx
  214ac7:	mov    rsi,r11
  214aca:	mov    r11,r10
  214acd:	mov    r10,QWORD PTR [rsp+0x28]
  214ad2:	cmove  rdi,rdx
  214ad6:	test   r10,r10
  214ad9:	cmove  rdi,r10
  214add:	shl    rdi,0x4
  214ae1:	add    rsi,rdi
  214ae4:	mov    rdi,r13
  214ae7:	mov    r13d,eax
  214aea:	neg    rbp
  214aed:	mov    rax,QWORD PTR [r8+0x18]
  214af1:	test   r11,r11
  214af4:	jns    214a39 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd9>
  214afa:	mov    rdx,QWORD PTR [rsp+0x20]
  214aff:	dec    rdx
  214b02:	imul   rdx,r11
  214b06:	mov    r8,QWORD PTR [rsp+0x10]
  214b0b:	test   r8,r8
  214b0e:	cmove  rdx,r8
  214b12:	shl    rdx,0x4
  214b16:	add    rdi,rdx
  214b19:	neg    r11
  214b1c:	mov    QWORD PTR [rsp+0x18],r11
  214b21:	xor    edx,edx
  214b23:	mov    r8,rsi
  214b26:	mov    rsi,r10
  214b29:	sub    rsi,0x1
  214b2d:	cmovb  rsi,rdx
  214b31:	mov    r11,rdi
  214b34:	mov    rdi,rax
  214b37:	imul   rdi,rsi
  214b3b:	test   rcx,rcx
  214b3e:	cmove  rdi,rcx
  214b42:	cmp    rsi,r10
  214b45:	mov    rsi,r8
  214b48:	cmove  rdi,rdx
  214b4c:	shl    rdi,0x4
  214b50:	add    rsi,rdi
  214b53:	mov    rdi,r11
  214b56:	neg    rax
  214b59:	mov    r10,QWORD PTR [rsp+0x158]
  214b61:	mov    r11,QWORD PTR [rsp+0x150]
  214b69:	cmp    rbx,0x1
  214b6d:	mov    r8,QWORD PTR [rsp+0x60]
  214b72:	jne    214c71 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214b78:	cmp    r8,0x1
  214b7c:	jne    214bf9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b7e:	cmp    r9,0x1
  214b82:	jne    214bf9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b84:	test   r14,r14
  214b87:	je     214bf9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b89:	mov    QWORD PTR [rsp+0x88],rdi
  214b91:	mov    rcx,QWORD PTR [rsp+0x10]
  214b96:	mov    QWORD PTR [rsp+0x90],rcx
  214b9e:	mov    rcx,rax
  214ba1:	mov    rax,QWORD PTR [rsp+0x20]
  214ba6:	mov    QWORD PTR [rsp+0x98],rax
  214bae:	mov    rax,QWORD PTR [rsp+0x18]
  214bb3:	mov    QWORD PTR [rsp+0xa0],rax
  214bbb:	mov    QWORD PTR [rsp+0x40],rsi
  214bc0:	mov    rax,QWORD PTR [rsp+0x28]
  214bc5:	mov    QWORD PTR [rsp+0x48],rax
  214bca:	mov    QWORD PTR [rsp+0x50],rcx
  214bcf:	sub    rsp,0x8
  214bd3:	movzx  eax,BYTE PTR [rsp+0xc]
  214bd8:	movzx  edx,BYTE PTR [rsp+0x10]
  214bdd:	movzx  r8d,r13b
  214be1:	lea    rcx,[rsp+0x90]
  214be9:	lea    r9,[rsp+0x48]
  214bee:	mov    rdi,r14
  214bf1:	mov    rsi,r12
  214bf4:	jmp    214cf4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x394>
  214bf9:	cmp    QWORD PTR [rsp+0x18],0x1
  214bff:	jne    214c71 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214c01:	cmp    rax,0x1
  214c05:	jne    214c71 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214c07:	test   rsi,rsi
  214c0a:	je     214c71 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214c0c:	mov    QWORD PTR [rsp+0x88],rdi
  214c14:	mov    rax,QWORD PTR [rsp+0x10]
  214c19:	mov    QWORD PTR [rsp+0x90],rax
  214c21:	mov    rax,QWORD PTR [rsp+0x20]
  214c26:	mov    QWORD PTR [rsp+0x98],rax
  214c2e:	mov    QWORD PTR [rsp+0xa0],r8
  214c36:	mov    QWORD PTR [rsp+0x40],r14
  214c3b:	mov    QWORD PTR [rsp+0x48],r12
  214c40:	mov    QWORD PTR [rsp+0x50],r9
  214c45:	sub    rsp,0x8
  214c49:	movzx  eax,BYTE PTR [rsp+0xc]
  214c4e:	mov    r8,rsi
  214c51:	movzx  esi,BYTE PTR [rsp+0x10]
  214c56:	movzx  ecx,r13b
  214c5a:	lea    rdi,[rsp+0x48]
  214c5f:	lea    rdx,[rsp+0x90]
  214c67:	mov    r9,QWORD PTR [rsp+0x30]
  214c6c:	jmp    214d79 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x419>
  214c71:	cmp    r12,0x1
  214c75:	jne    214d8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214c7b:	xor    edx,edx
  214c7d:	cmp    r15,0x1
  214c81:	cmove  rdx,r14
  214c85:	cmp    rbp,0x1
  214c89:	jne    214d07 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3a7>
  214c8b:	test   rdx,rdx
  214c8e:	je     214d07 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3a7>
  214c90:	mov    QWORD PTR [rsp+0x88],rsi
  214c98:	mov    QWORD PTR [rsp+0x90],rcx
  214ca0:	mov    rcx,QWORD PTR [rsp+0x28]
  214ca5:	mov    QWORD PTR [rsp+0x98],rcx
  214cad:	mov    QWORD PTR [rsp+0xa0],rax
  214cb5:	mov    QWORD PTR [rsp+0x40],rdi
  214cba:	mov    rax,QWORD PTR [rsp+0x20]
  214cbf:	mov    QWORD PTR [rsp+0x48],rax
  214cc4:	mov    rax,QWORD PTR [rsp+0x18]
  214cc9:	mov    QWORD PTR [rsp+0x50],rax
  214cce:	sub    rsp,0x8
  214cd2:	movzx  eax,r13b
  214cd6:	movzx  edx,BYTE PTR [rsp+0x10]
  214cdb:	movzx  r8d,BYTE PTR [rsp+0xc]
  214ce1:	lea    rcx,[rsp+0x90]
  214ce9:	lea    r9,[rsp+0x48]
  214cee:	mov    rdi,r14
  214cf1:	mov    rsi,rbx
  214cf4:	push   r10
  214cf6:	push   r11
  214cf8:	push   rax
  214cf9:	call   14ada0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214cfe:	add    rsp,0x20
  214d02:	jmp    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214d07:	xor    edx,edx
  214d09:	cmp    QWORD PTR [rsp+0x18],0x1
  214d0f:	cmove  rdx,rdi
  214d13:	cmp    rax,0x1
  214d17:	jne    214d8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214d19:	test   rdx,rdx
  214d1c:	je     214d8c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214d1e:	mov    QWORD PTR [rsp+0x88],rsi
  214d26:	mov    QWORD PTR [rsp+0x90],rcx
  214d2e:	mov    rax,QWORD PTR [rsp+0x28]
  214d33:	mov    QWORD PTR [rsp+0x98],rax
  214d3b:	mov    QWORD PTR [rsp+0xa0],rbp
  214d43:	mov    QWORD PTR [rsp+0x40],r14
  214d48:	mov    QWORD PTR [rsp+0x48],rbx
  214d4d:	mov    QWORD PTR [rsp+0x50],r15
  214d52:	sub    rsp,0x8
  214d56:	movzx  eax,r13b
  214d5a:	movzx  esi,BYTE PTR [rsp+0x10]
  214d5f:	movzx  ecx,BYTE PTR [rsp+0xc]
  214d64:	mov    r8,rdi
  214d67:	lea    rdi,[rsp+0x48]
  214d6c:	lea    rdx,[rsp+0x90]
  214d74:	mov    r9,QWORD PTR [rsp+0x28]
  214d79:	push   r10
  214d7b:	push   r11
  214d7d:	push   rax
  214d7e:	call   202260 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214d83:	add    rsp,0x20
  214d87:	jmp    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214d8c:	mov    r10,QWORD PTR [rsp+0x20]
  214d91:	cmp    r10,0x1
  214d95:	jne    214e97 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214d9b:	xor    edx,edx
  214d9d:	cmp    r9,0x1
  214da1:	cmove  rdx,r14
  214da5:	cmp    r8,0x1
  214da9:	jne    214e12 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4b2>
  214dab:	test   rdx,rdx
  214dae:	je     214e12 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4b2>
  214db0:	mov    QWORD PTR [rsp+0x88],rdx
  214db8:	mov    QWORD PTR [rsp+0x90],r12
  214dc0:	mov    QWORD PTR [rsp+0x98],rbx
  214dc8:	mov    QWORD PTR [rsp+0xa0],r15
  214dd0:	mov    QWORD PTR [rsp+0x40],rsi
  214dd5:	mov    QWORD PTR [rsp+0x48],rcx
  214dda:	mov    QWORD PTR [rsp+0x50],rbp
  214ddf:	sub    rsp,0x8
  214de3:	movzx  eax,BYTE PTR [rsp+0xc]
  214de8:	movzx  esi,BYTE PTR [rsp+0x10]
  214ded:	movzx  r8d,r13b
  214df1:	mov    rdx,rdi
  214df4:	lea    rdi,[rsp+0x90]
  214dfc:	lea    r9,[rsp+0x48]
  214e01:	mov    rcx,QWORD PTR [rsp+0x18]
  214e06:	push   QWORD PTR [rsp+0x160]
  214e0d:	push   r11
  214e0f:	push   rax
  214e10:	jmp    214e89 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x529>
  214e12:	xor    edx,edx
  214e14:	cmp    r15,0x1
  214e18:	cmove  rdx,r14
  214e1c:	cmp    rbp,0x1
  214e20:	jne    214e97 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214e22:	test   rdx,rdx
  214e25:	je     214e97 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214e27:	mov    QWORD PTR [rsp+0x88],rdx
  214e2f:	mov    QWORD PTR [rsp+0x90],rbx
  214e37:	mov    QWORD PTR [rsp+0x98],r12
  214e3f:	mov    QWORD PTR [rsp+0xa0],r9
  214e47:	mov    QWORD PTR [rsp+0x40],rdi
  214e4c:	mov    rax,QWORD PTR [rsp+0x10]
  214e51:	mov    QWORD PTR [rsp+0x48],rax
  214e56:	mov    QWORD PTR [rsp+0x50],r8
  214e5b:	sub    rsp,0x8
  214e5f:	movzx  r10d,r13b
  214e63:	mov    rdx,rsi
  214e66:	movzx  esi,BYTE PTR [rsp+0x10]
  214e6b:	movzx  r8d,BYTE PTR [rsp+0xc]
  214e71:	lea    rdi,[rsp+0x90]
  214e79:	lea    r9,[rsp+0x48]
  214e7e:	push   QWORD PTR [rsp+0x160]
  214e85:	push   r11
  214e87:	push   r10
  214e89:	call   1497e0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214e8e:	add    rsp,0x20
  214e92:	jmp    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214e97:	mov    QWORD PTR [rsp+0x28],rax
  214e9c:	movups xmm1,XMMWORD PTR [r11]
  214ea0:	movaps XMMWORD PTR [rsp+0x40],xmm1
  214ea5:	mov    rax,r12
  214ea8:	mul    rbx
  214eab:	mov    QWORD PTR [rsp+0x68],rax
  214eb0:	jo     2152de <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x97e>
  214eb6:	mul    r10
  214eb9:	seto   cl
  214ebc:	not    cl
  214ebe:	cmp    rax,0x1001
  214ec4:	setb   al
  214ec7:	test   cl,al
  214ec9:	mov    r11,QWORD PTR [rsp+0x18]
  214ece:	jne    214f2c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5cc>
  214ed0:	mov    rdx,QWORD PTR [rip+0x336fe1]        # 54beb8 <_DYNAMIC+0x450>
  214ed7:	mov    rax,QWORD PTR [rdx]
  214eda:	test   rax,rax
  214edd:	je     2152ea <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x98a>
  214ee3:	mov    cl,0x1
  214ee5:	test   eax,0x80000
  214eea:	jne    215408 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa8>
  214ef0:	mov    rax,QWORD PTR [rdx]
  214ef3:	test   rax,rax
  214ef6:	je     21534c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ec>
  214efc:	test   ax,ax
  214eff:	mov    ecx,DWORD PTR [rsp+0x8]
  214f03:	jns    214f1c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  214f05:	mov    rax,QWORD PTR [rdx]
  214f08:	test   rax,rax
  214f0b:	je     2153ae <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4e>
  214f11:	bt     rax,0x37
  214f16:	jb     215406 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa6>
  214f1c:	test   cl,cl
  214f1e:	jne    215193 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x833>
  214f24:	xorps  xmm0,xmm0
  214f27:	jmp    21519b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83b>
  214f2c:	cmp    BYTE PTR [rsp+0x8],0x0
  214f31:	jne    214f92 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x632>
  214f33:	xorps  xmm0,xmm0
  214f36:	movsd  QWORD PTR [rsp+0x8],xmm0
  214f3c:	cmp    r15,r9
  214f3f:	jb     214fa5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x645>
  214f41:	mov    eax,DWORD PTR [rsp+0x4]
  214f45:	mov    BYTE PTR [rsp+0x68],al
  214f49:	mov    DWORD PTR [rsp+0x4],r13d
  214f4e:	mov    QWORD PTR [rsp+0x38],rbp
  214f53:	mov    rax,QWORD PTR [rsp+0x28]
  214f58:	mov    QWORD PTR [rsp+0x30],rax
  214f5d:	mov    QWORD PTR [rsp+0x80],rsi
  214f65:	mov    QWORD PTR [rsp+0x28],r11
  214f6a:	mov    rax,r8
  214f6d:	mov    rsi,rdi
  214f70:	mov    QWORD PTR [rsp+0x18],r15
  214f75:	mov    r15,r9
  214f78:	mov    rbp,rbx
  214f7b:	mov    rbx,r12
  214f7e:	jmp    214fc7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x667>
  214f80:	cmp    r9,0x1
  214f84:	jne    2150ec <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x78c>
  214f8a:	mov    rax,r12
  214f8d:	jmp    215209 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a9>
  214f92:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2ac3e]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  214f9a:	movsd  QWORD PTR [rsp+0x8],xmm0
  214fa0:	cmp    r15,r9
  214fa3:	jae    214f41 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5e1>
  214fa5:	mov    BYTE PTR [rsp+0x68],r13b
  214faa:	mov    QWORD PTR [rsp+0x38],r8
  214faf:	mov    QWORD PTR [rsp+0x30],r11
  214fb4:	mov    QWORD PTR [rsp+0x80],rdi
  214fbc:	mov    QWORD PTR [rsp+0x18],r9
  214fc1:	mov    rax,rbp
  214fc4:	mov    rbp,r12
  214fc7:	movaps XMMWORD PTR [rsp+0x70],xmm1
  214fcc:	mov    QWORD PTR [rsp+0x10],rsi
  214fd1:	mov    r13,rax
  214fd4:	cmp    rax,0x1
  214fd8:	jne    215003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a3>
  214fda:	cmp    r15,0x1
  214fde:	jne    215003 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a3>
  214fe0:	lea    r8,[rip+0x32bc29]        # 540c10 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x3e0>
  214fe7:	lea    rdi,[rsp+0x88]
  214fef:	mov    rsi,rbx
  214ff2:	mov    rdx,rbp
  214ff5:	mov    rcx,r10
  214ff8:	mov    r12,r10
  214ffb:	call   QWORD PTR [rip+0x3371b7]        # 54c1b8 <_DYNAMIC+0x750>
  215001:	jmp    215024 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6c4>
  215003:	lea    r8,[rip+0x32bc1e]        # 540c28 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.7939462528399764976+0x3f8>
  21500a:	lea    rdi,[rsp+0x88]
  215012:	mov    rsi,rbx
  215015:	mov    rdx,rbp
  215018:	mov    rcx,r10
  21501b:	mov    r12,r10
  21501e:	call   QWORD PTR [rip+0x33719c]        # 54c1c0 <_DYNAMIC+0x758>
  215024:	lea    rdi,[rsp+0x90]
  21502c:	mov    rsi,QWORD PTR [rsp+0xb0]
  215034:	mov    rdx,QWORD PTR [rsp+0xb8]
  21503c:	movups xmm0,XMMWORD PTR [rsp+0xc0]
  215044:	movaps xmm2,XMMWORD PTR [rsp+0x70]
  215049:	movaps xmm3,xmm2
  21504c:	unpckhpd xmm3,xmm2
  215050:	sub    rsp,0x70
  215054:	movups XMMWORD PTR [rsp+0x58],xmm0
  215059:	movzx  eax,BYTE PTR [rsp+0xd8]
  215061:	mov    DWORD PTR [rsp+0x50],eax
  215065:	movzx  eax,BYTE PTR [rsp+0x74]
  21506a:	mov    DWORD PTR [rsp+0x48],eax
  21506e:	mov    rax,QWORD PTR [rsp+0xa8]
  215076:	mov    QWORD PTR [rsp+0x40],rax
  21507b:	mov    rax,QWORD PTR [rsp+0xa0]
  215083:	mov    QWORD PTR [rsp+0x38],rax
  215088:	mov    rax,QWORD PTR [rsp+0xf0]
  215090:	mov    QWORD PTR [rsp+0x30],rax
  215095:	mov    rax,QWORD PTR [rsp+0x98]
  21509d:	mov    QWORD PTR [rsp+0x28],rax
  2150a2:	mov    QWORD PTR [rsp+0x20],r13
  2150a7:	mov    rax,QWORD PTR [rsp+0x80]
  2150af:	mov    QWORD PTR [rsp+0x18],rax
  2150b4:	mov    rax,QWORD PTR [rsp+0x88]
  2150bc:	mov    QWORD PTR [rsp+0x10],rax
  2150c1:	mov    QWORD PTR [rsp+0x8],r15
  2150c6:	mov    QWORD PTR [rsp],r14
  2150ca:	xorps  xmm1,xmm1
  2150cd:	mov    r8,rbp
  2150d0:	mov    r9,r12
  2150d3:	mov    rcx,rbx
  2150d6:	movsd  xmm0,QWORD PTR [rsp+0x78]
  2150dc:	call   QWORD PTR [rsp+0xf8]
  2150e3:	add    rsp,0x70
  2150e7:	jmp    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  2150ec:	lea    rax,[r12-0x1]
  2150f1:	mov    ecx,r12d
  2150f4:	and    ecx,0x3
  2150f7:	and    r12,0xfffffffffffffffc
  2150fb:	mov    rdx,r9
  2150fe:	shl    rdx,0x4
  215102:	lea    rsi,[rdx+rdx*2]
  215106:	shl    r15,0x4
  21510a:	mov    rdi,r9
  21510d:	shl    rdi,0x6
  215111:	shl    r9,0x5
  215115:	xor    r8d,r8d
  215118:	xorps  xmm0,xmm0
  21511b:	jmp    21512f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7cf>
  21511d:	nop    DWORD PTR [rax]
  215120:	inc    r8
  215123:	add    r14,r15
  215126:	cmp    r8,rbx
  215129:	je     2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21512f:	cmp    rax,0x3
  215133:	jae    215140 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7e0>
  215135:	xor    r10d,r10d
  215138:	jmp    215174 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x814>
  21513a:	nop    WORD PTR [rax+rax*1+0x0]
  215140:	mov    r11,r14
  215143:	xor    r10d,r10d
  215146:	cs nop WORD PTR [rax+rax*1+0x0]
  215150:	movups XMMWORD PTR [r11],xmm0
  215154:	movups XMMWORD PTR [r11+rdx*1],xmm0
  215159:	movups XMMWORD PTR [r11+r9*1],xmm0
  21515e:	add    r10,0x4
  215162:	movups XMMWORD PTR [r11+rsi*1],xmm0
  215167:	add    r11,rdi
  21516a:	cmp    r12,r10
  21516d:	jne    215150 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f0>
  21516f:	test   rcx,rcx
  215172:	je     215120 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7c0>
  215174:	imul   r10,rdx
  215178:	add    r10,r14
  21517b:	mov    r11,rcx
  21517e:	xchg   ax,ax
  215180:	movups XMMWORD PTR [r10],xmm0
  215184:	add    r10,rdx
  215187:	dec    r11
  21518a:	jne    215180 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x820>
  21518c:	jmp    215120 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7c0>
  21518e:	mov    rax,r12
  215191:	jmp    2151fa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89a>
  215193:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2aa3d]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.2203386464427867274+0x108>
  21519b:	mov    eax,DWORD PTR [rsp+0x4]
  21519f:	mov    rdx,QWORD PTR [rsp+0x158]
  2151a7:	mov    QWORD PTR [rsp+0x8],rdi
  2151ac:	mov    QWORD PTR [rsp+0x10],rsi
  2151b1:	movaps xmm2,xmm1
  2151b4:	unpckhpd xmm2,xmm1
  2151b8:	test   rdx,rdx
  2151bb:	je     215291 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x931>
  2151c1:	sub    rsp,0x8
  2151c5:	mov    r11,rdx
  2151c8:	movzx  r10d,al
  2151cc:	movzx  r13d,r13b
  2151d0:	movzx  eax,cl
  2151d3:	mov    rdi,r12
  2151d6:	mov    rsi,rbx
  2151d9:	mov    rdx,QWORD PTR [rsp+0x28]
  2151de:	mov    rcx,r14
  2151e1:	mov    r8,r15
  2151e4:	push   r11
  2151e6:	push   0x1
  2151e8:	push   r10
  2151ea:	push   r13
  2151ec:	jmp    2152b7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x957>
  2151f1:	mov    rax,rbx
  2151f4:	mov    rbx,r12
  2151f7:	mov    r15,r9
  2151fa:	mov    ecx,0x1
  2151ff:	sub    rcx,rax
  215202:	shl    rcx,0x4
  215206:	add    r14,rcx
  215209:	lea    rcx,[rax-0x1]
  21520d:	mov    edx,eax
  21520f:	and    edx,0x3
  215212:	and    rax,0xfffffffffffffffc
  215216:	xor    esi,esi
  215218:	xorps  xmm0,xmm0
  21521b:	jmp    21522c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8cc>
  21521d:	nop    DWORD PTR [rax]
  215220:	inc    rsi
  215223:	cmp    rsi,rbx
  215226:	je     2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21522c:	mov    rdi,rsi
  21522f:	imul   rdi,r15
  215233:	shl    rdi,0x4
  215237:	add    rdi,r14
  21523a:	cmp    rcx,0x3
  21523e:	jb     215271 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x911>
  215240:	xor    r8d,r8d
  215243:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  215250:	movups XMMWORD PTR [rdi],xmm0
  215253:	movups XMMWORD PTR [rdi+0x10],xmm0
  215257:	movups XMMWORD PTR [rdi+0x20],xmm0
  21525b:	movups XMMWORD PTR [rdi+0x30],xmm0
  21525f:	add    rdi,0x40
  215263:	add    r8,0x4
  215267:	cmp    rax,r8
  21526a:	jne    215250 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8f0>
  21526c:	test   rdx,rdx
  21526f:	je     215220 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c0>
  215271:	xor    r8d,r8d
  215274:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  215280:	movups XMMWORD PTR [rdi],xmm0
  215283:	add    rdi,0x10
  215287:	inc    r8
  21528a:	cmp    rdx,r8
  21528d:	jne    215280 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21528f:	jmp    215220 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c0>
  215291:	sub    rsp,0x10
  215295:	movzx  r10d,al
  215299:	movzx  r11d,r13b
  21529d:	movzx  eax,cl
  2152a0:	mov    rdi,r12
  2152a3:	mov    rsi,rbx
  2152a6:	mov    rdx,QWORD PTR [rsp+0x30]
  2152ab:	mov    rcx,r14
  2152ae:	mov    r8,r15
  2152b1:	push   0x0
  2152b3:	push   r10
  2152b5:	push   r11
  2152b7:	push   QWORD PTR [rsp+0x50]
  2152bb:	push   rbp
  2152bc:	push   QWORD PTR [rsp+0x48]
  2152c0:	push   QWORD PTR [rsp+0xa0]
  2152c7:	push   QWORD PTR [rsp+0x60]
  2152cb:	push   QWORD PTR [rsp+0x58]
  2152cf:	push   rax
  2152d0:	call   20af70 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  2152d5:	add    rsp,0x60
  2152d9:	jmp    2154e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  2152de:	mov    rax,0xffffffffffffffff
  2152e5:	jmp    214eb6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x556>
  2152ea:	mov    QWORD PTR [rsp+0x38],r9
  2152ef:	mov    QWORD PTR [rsp+0x10],rsi
  2152f4:	mov    QWORD PTR [rsp+0x30],rbp
  2152f9:	mov    ebp,r13d
  2152fc:	mov    r13,rdi
  2152ff:	movaps XMMWORD PTR [rsp+0x70],xmm1
  215304:	call   QWORD PTR [rip+0x336bb6]        # 54bec0 <_DYNAMIC+0x458>
  21530a:	mov    rdx,QWORD PTR [rip+0x336ba7]        # 54beb8 <_DYNAMIC+0x450>
  215311:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  215316:	mov    r11,QWORD PTR [rsp+0x18]
  21531b:	mov    r8,QWORD PTR [rsp+0x60]
  215320:	mov    rdi,r13
  215323:	mov    r13d,ebp
  215326:	mov    rbp,QWORD PTR [rsp+0x30]
  21532b:	mov    rsi,QWORD PTR [rsp+0x10]
  215330:	mov    r10,QWORD PTR [rsp+0x20]
  215335:	mov    r9,QWORD PTR [rsp+0x38]
  21533a:	mov    cl,0x1
  21533c:	test   eax,0x80000
  215341:	je     214ef0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x590>
  215347:	jmp    215408 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa8>
  21534c:	mov    QWORD PTR [rsp+0x38],r9
  215351:	mov    QWORD PTR [rsp+0x10],rsi
  215356:	mov    QWORD PTR [rsp+0x30],rbp
  21535b:	mov    ebp,r13d
  21535e:	mov    r13,rdi
  215361:	movaps XMMWORD PTR [rsp+0x70],xmm1
  215366:	call   QWORD PTR [rip+0x336b54]        # 54bec0 <_DYNAMIC+0x458>
  21536c:	mov    rdx,QWORD PTR [rip+0x336b45]        # 54beb8 <_DYNAMIC+0x450>
  215373:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  215378:	mov    r11,QWORD PTR [rsp+0x18]
  21537d:	mov    r8,QWORD PTR [rsp+0x60]
  215382:	mov    rdi,r13
  215385:	mov    r13d,ebp
  215388:	mov    rbp,QWORD PTR [rsp+0x30]
  21538d:	mov    rsi,QWORD PTR [rsp+0x10]
  215392:	mov    r10,QWORD PTR [rsp+0x20]
  215397:	mov    r9,QWORD PTR [rsp+0x38]
  21539c:	test   ax,ax
  21539f:	mov    ecx,DWORD PTR [rsp+0x8]
  2153a3:	js     214f05 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a5>
  2153a9:	jmp    214f1c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  2153ae:	mov    QWORD PTR [rsp+0x38],r9
  2153b3:	mov    QWORD PTR [rsp+0x10],rsi
  2153b8:	mov    QWORD PTR [rsp+0x30],rbp
  2153bd:	mov    ebp,r13d
  2153c0:	mov    r13,rdi
  2153c3:	movaps XMMWORD PTR [rsp+0x70],xmm1
  2153c8:	call   QWORD PTR [rip+0x336af2]        # 54bec0 <_DYNAMIC+0x458>
  2153ce:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  2153d3:	mov    r11,QWORD PTR [rsp+0x18]
  2153d8:	mov    r8,QWORD PTR [rsp+0x60]
  2153dd:	mov    ecx,DWORD PTR [rsp+0x8]
  2153e1:	mov    rdi,r13
  2153e4:	mov    r13d,ebp
  2153e7:	mov    rbp,QWORD PTR [rsp+0x30]
  2153ec:	mov    rsi,QWORD PTR [rsp+0x10]
  2153f1:	mov    r10,QWORD PTR [rsp+0x20]
  2153f6:	mov    r9,QWORD PTR [rsp+0x38]
  2153fb:	bt     rax,0x37
  215400:	jae    214f1c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  215406:	xor    ecx,ecx
  215408:	mov    DWORD PTR [rsp+0x20],ecx
  21540c:	mov    rcx,QWORD PTR [rsp+0x68]
  215411:	imul   rcx,r10
  215415:	mov    rdx,QWORD PTR [rsp+0x158]
  21541d:	cmp    rdx,0x1
  215421:	adc    rdx,0x0
  215425:	cmp    rcx,0x10000
  21542c:	mov    eax,0x1
  215431:	cmovae rax,rdx
  215435:	sub    rsp,0xa0
  21543c:	lea    rdx,[rsp+0xe0]
  215444:	mov    QWORD PTR [rsp+0x88],rdx
  21544c:	movzx  edx,BYTE PTR [rsp+0xa4]
  215454:	mov    DWORD PTR [rsp+0x80],edx
  21545b:	mov    QWORD PTR [rsp+0x78],rbp
  215460:	mov    rdx,QWORD PTR [rsp+0xc8]
  215468:	mov    QWORD PTR [rsp+0x70],rdx
  21546d:	mov    QWORD PTR [rsp+0x68],rsi
  215472:	xorps  xmm0,xmm0
  215475:	movups XMMWORD PTR [rsp+0x58],xmm0
  21547a:	movzx  edx,r13b
  21547e:	mov    DWORD PTR [rsp+0x50],edx
  215482:	mov    QWORD PTR [rsp+0x48],r11
  215487:	mov    QWORD PTR [rsp+0x40],r8
  21548c:	mov    QWORD PTR [rsp+0x38],rdi
  215491:	movzx  edx,BYTE PTR [rsp+0xa8]
  215499:	mov    DWORD PTR [rsp+0x30],edx
  21549d:	movups XMMWORD PTR [rsp+0x18],xmm0
  2154a2:	mov    QWORD PTR [rsp+0x10],r15
  2154a7:	mov    QWORD PTR [rsp+0x8],r9
  2154ac:	mov    QWORD PTR [rsp],r14
  2154b0:	mov    QWORD PTR [rsp+0x90],rax
  2154b8:	mov    DWORD PTR [rsp+0x28],0x2
  2154c0:	movzx  edx,BYTE PTR [rsp+0xc0]
  2154c8:	mov    r8,rbx
  2154cb:	mov    edi,0x3
  2154d0:	mov    r9,r10
  2154d3:	mov    esi,0x1
  2154d8:	mov    rcx,r12
  2154db:	call   QWORD PTR [rip+0x3369e7]        # 54bec8 <_DYNAMIC+0x460>
  2154e1:	add    rsp,0xa0
  2154e8:	add    rsp,0x118
  2154ef:	pop    rbx
  2154f0:	pop    r12
  2154f2:	pop    r13
  2154f4:	pop    r14
  2154f6:	pop    r15
  2154f8:	pop    rbp
  2154f9:	ret
