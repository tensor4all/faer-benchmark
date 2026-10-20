
target/faer-rev/f013756c7421-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000214940 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  214940:	push   rbp
  214941:	push   r15
  214943:	push   r14
  214945:	push   r13
  214947:	push   r12
  214949:	push   rbx
  21494a:	sub    rsp,0x118
  214951:	mov    r12,QWORD PTR [rdi+0x8]
  214955:	test   r12,r12
  214958:	je     2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21495e:	mov    rbx,QWORD PTR [rdi+0x10]
  214962:	test   rbx,rbx
  214965:	je     2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21496b:	mov    r10d,r9d
  21496e:	mov    r14,QWORD PTR [rdi]
  214971:	mov    r9,QWORD PTR [rdi+0x18]
  214975:	mov    r15,QWORD PTR [rdi+0x20]
  214979:	mov    rax,QWORD PTR [rdx+0x10]
  21497d:	test   rax,rax
  214980:	je     214a23 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xe3>
  214986:	mov    r13d,ecx
  214989:	mov    rdi,QWORD PTR [rdx]
  21498c:	mov    r11,QWORD PTR [rdx+0x8]
  214990:	mov    rcx,QWORD PTR [rdx+0x18]
  214994:	test   r9,r9
  214997:	mov    QWORD PTR [rsp+0x20],rax
  21499c:	mov    DWORD PTR [rsp+0x8],esi
  2149a0:	mov    QWORD PTR [rsp+0x10],r11
  2149a5:	mov    DWORD PTR [rsp+0x4],r10d
  2149aa:	jns    2149ea <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa>
  2149ac:	lea    rax,[r12-0x1]
  2149b1:	imul   rax,r9
  2149b5:	shl    rax,0x4
  2149b9:	add    r14,rax
  2149bc:	neg    r9
  2149bf:	xor    eax,eax
  2149c1:	mov    rsi,r11
  2149c4:	sub    rsi,0x1
  2149c8:	cmovb  rsi,rax
  2149cc:	mov    r10,rdi
  2149cf:	mov    rdi,rcx
  2149d2:	imul   rdi,rsi
  2149d6:	cmp    rsi,r11
  2149d9:	cmove  rdi,rax
  2149dd:	shl    rdi,0x4
  2149e1:	add    r10,rdi
  2149e4:	mov    rdi,r10
  2149e7:	neg    rcx
  2149ea:	mov    QWORD PTR [rsp+0x60],rcx
  2149ef:	mov    r11,QWORD PTR [rdx+0x20]
  2149f3:	mov    rsi,QWORD PTR [r8]
  2149f6:	mov    r10,QWORD PTR [r8+0x8]
  2149fa:	mov    rcx,QWORD PTR [r8+0x10]
  2149fe:	mov    rbp,QWORD PTR [r8+0x20]
  214a02:	test   r15,r15
  214a05:	mov    QWORD PTR [rsp+0x28],r10
  214a0a:	js     214a72 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x132>
  214a0c:	mov    rax,QWORD PTR [r8+0x18]
  214a10:	test   r11,r11
  214a13:	js     214ada <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x19a>
  214a19:	mov    QWORD PTR [rsp+0x18],r11
  214a1e:	jmp    214b39 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1f9>
  214a23:	test   sil,sil
  214a26:	jne    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214a2c:	cmp    r12,0x1
  214a30:	je     214a46 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x106>
  214a32:	cmp    r9,0xffffffffffffffff
  214a36:	je     21516e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x82e>
  214a3c:	cmp    r9,0x1
  214a40:	je     214f6a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x62a>
  214a46:	cmp    rbx,0x1
  214a4a:	je     214f60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x620>
  214a50:	cmp    r15,0xffffffffffffffff
  214a54:	je     2151d1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x891>
  214a5a:	cmp    r15,0x1
  214a5e:	jne    214f60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x620>
  214a64:	mov    rax,rbx
  214a67:	mov    rbx,r12
  214a6a:	mov    r15,r9
  214a6d:	jmp    2151e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a9>
  214a72:	lea    rdx,[rbx-0x1]
  214a76:	imul   rdx,r15
  214a7a:	shl    rdx,0x4
  214a7e:	add    r14,rdx
  214a81:	neg    r15
  214a84:	xor    edx,edx
  214a86:	mov    r10,r11
  214a89:	mov    r11,rsi
  214a8c:	mov    rsi,rcx
  214a8f:	sub    rsi,0x1
  214a93:	cmovb  rsi,rdx
  214a97:	mov    eax,r13d
  214a9a:	mov    r13,rdi
  214a9d:	mov    rdi,rbp
  214aa0:	imul   rdi,rsi
  214aa4:	cmp    rsi,rcx
  214aa7:	mov    rsi,r11
  214aaa:	mov    r11,r10
  214aad:	mov    r10,QWORD PTR [rsp+0x28]
  214ab2:	cmove  rdi,rdx
  214ab6:	test   r10,r10
  214ab9:	cmove  rdi,r10
  214abd:	shl    rdi,0x4
  214ac1:	add    rsi,rdi
  214ac4:	mov    rdi,r13
  214ac7:	mov    r13d,eax
  214aca:	neg    rbp
  214acd:	mov    rax,QWORD PTR [r8+0x18]
  214ad1:	test   r11,r11
  214ad4:	jns    214a19 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd9>
  214ada:	mov    rdx,QWORD PTR [rsp+0x20]
  214adf:	dec    rdx
  214ae2:	imul   rdx,r11
  214ae6:	mov    r8,QWORD PTR [rsp+0x10]
  214aeb:	test   r8,r8
  214aee:	cmove  rdx,r8
  214af2:	shl    rdx,0x4
  214af6:	add    rdi,rdx
  214af9:	neg    r11
  214afc:	mov    QWORD PTR [rsp+0x18],r11
  214b01:	xor    edx,edx
  214b03:	mov    r8,rsi
  214b06:	mov    rsi,r10
  214b09:	sub    rsi,0x1
  214b0d:	cmovb  rsi,rdx
  214b11:	mov    r11,rdi
  214b14:	mov    rdi,rax
  214b17:	imul   rdi,rsi
  214b1b:	test   rcx,rcx
  214b1e:	cmove  rdi,rcx
  214b22:	cmp    rsi,r10
  214b25:	mov    rsi,r8
  214b28:	cmove  rdi,rdx
  214b2c:	shl    rdi,0x4
  214b30:	add    rsi,rdi
  214b33:	mov    rdi,r11
  214b36:	neg    rax
  214b39:	mov    r10,QWORD PTR [rsp+0x158]
  214b41:	mov    r11,QWORD PTR [rsp+0x150]
  214b49:	cmp    rbx,0x1
  214b4d:	mov    r8,QWORD PTR [rsp+0x60]
  214b52:	jne    214c51 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214b58:	cmp    r8,0x1
  214b5c:	jne    214bd9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b5e:	cmp    r9,0x1
  214b62:	jne    214bd9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b64:	test   r14,r14
  214b67:	je     214bd9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x299>
  214b69:	mov    QWORD PTR [rsp+0x88],rdi
  214b71:	mov    rcx,QWORD PTR [rsp+0x10]
  214b76:	mov    QWORD PTR [rsp+0x90],rcx
  214b7e:	mov    rcx,rax
  214b81:	mov    rax,QWORD PTR [rsp+0x20]
  214b86:	mov    QWORD PTR [rsp+0x98],rax
  214b8e:	mov    rax,QWORD PTR [rsp+0x18]
  214b93:	mov    QWORD PTR [rsp+0xa0],rax
  214b9b:	mov    QWORD PTR [rsp+0x40],rsi
  214ba0:	mov    rax,QWORD PTR [rsp+0x28]
  214ba5:	mov    QWORD PTR [rsp+0x48],rax
  214baa:	mov    QWORD PTR [rsp+0x50],rcx
  214baf:	sub    rsp,0x8
  214bb3:	movzx  eax,BYTE PTR [rsp+0xc]
  214bb8:	movzx  edx,BYTE PTR [rsp+0x10]
  214bbd:	movzx  r8d,r13b
  214bc1:	lea    rcx,[rsp+0x90]
  214bc9:	lea    r9,[rsp+0x48]
  214bce:	mov    rdi,r14
  214bd1:	mov    rsi,r12
  214bd4:	jmp    214cd4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x394>
  214bd9:	cmp    QWORD PTR [rsp+0x18],0x1
  214bdf:	jne    214c51 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214be1:	cmp    rax,0x1
  214be5:	jne    214c51 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214be7:	test   rsi,rsi
  214bea:	je     214c51 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x311>
  214bec:	mov    QWORD PTR [rsp+0x88],rdi
  214bf4:	mov    rax,QWORD PTR [rsp+0x10]
  214bf9:	mov    QWORD PTR [rsp+0x90],rax
  214c01:	mov    rax,QWORD PTR [rsp+0x20]
  214c06:	mov    QWORD PTR [rsp+0x98],rax
  214c0e:	mov    QWORD PTR [rsp+0xa0],r8
  214c16:	mov    QWORD PTR [rsp+0x40],r14
  214c1b:	mov    QWORD PTR [rsp+0x48],r12
  214c20:	mov    QWORD PTR [rsp+0x50],r9
  214c25:	sub    rsp,0x8
  214c29:	movzx  eax,BYTE PTR [rsp+0xc]
  214c2e:	mov    r8,rsi
  214c31:	movzx  esi,BYTE PTR [rsp+0x10]
  214c36:	movzx  ecx,r13b
  214c3a:	lea    rdi,[rsp+0x48]
  214c3f:	lea    rdx,[rsp+0x90]
  214c47:	mov    r9,QWORD PTR [rsp+0x30]
  214c4c:	jmp    214d59 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x419>
  214c51:	cmp    r12,0x1
  214c55:	jne    214d6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214c5b:	xor    edx,edx
  214c5d:	cmp    r15,0x1
  214c61:	cmove  rdx,r14
  214c65:	cmp    rbp,0x1
  214c69:	jne    214ce7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3a7>
  214c6b:	test   rdx,rdx
  214c6e:	je     214ce7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3a7>
  214c70:	mov    QWORD PTR [rsp+0x88],rsi
  214c78:	mov    QWORD PTR [rsp+0x90],rcx
  214c80:	mov    rcx,QWORD PTR [rsp+0x28]
  214c85:	mov    QWORD PTR [rsp+0x98],rcx
  214c8d:	mov    QWORD PTR [rsp+0xa0],rax
  214c95:	mov    QWORD PTR [rsp+0x40],rdi
  214c9a:	mov    rax,QWORD PTR [rsp+0x20]
  214c9f:	mov    QWORD PTR [rsp+0x48],rax
  214ca4:	mov    rax,QWORD PTR [rsp+0x18]
  214ca9:	mov    QWORD PTR [rsp+0x50],rax
  214cae:	sub    rsp,0x8
  214cb2:	movzx  eax,r13b
  214cb6:	movzx  edx,BYTE PTR [rsp+0x10]
  214cbb:	movzx  r8d,BYTE PTR [rsp+0xc]
  214cc1:	lea    rcx,[rsp+0x90]
  214cc9:	lea    r9,[rsp+0x48]
  214cce:	mov    rdi,r14
  214cd1:	mov    rsi,rbx
  214cd4:	push   r10
  214cd6:	push   r11
  214cd8:	push   rax
  214cd9:	call   14ada0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214cde:	add    rsp,0x20
  214ce2:	jmp    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214ce7:	xor    edx,edx
  214ce9:	cmp    QWORD PTR [rsp+0x18],0x1
  214cef:	cmove  rdx,rdi
  214cf3:	cmp    rax,0x1
  214cf7:	jne    214d6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214cf9:	test   rdx,rdx
  214cfc:	je     214d6c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x42c>
  214cfe:	mov    QWORD PTR [rsp+0x88],rsi
  214d06:	mov    QWORD PTR [rsp+0x90],rcx
  214d0e:	mov    rax,QWORD PTR [rsp+0x28]
  214d13:	mov    QWORD PTR [rsp+0x98],rax
  214d1b:	mov    QWORD PTR [rsp+0xa0],rbp
  214d23:	mov    QWORD PTR [rsp+0x40],r14
  214d28:	mov    QWORD PTR [rsp+0x48],rbx
  214d2d:	mov    QWORD PTR [rsp+0x50],r15
  214d32:	sub    rsp,0x8
  214d36:	movzx  eax,r13b
  214d3a:	movzx  esi,BYTE PTR [rsp+0x10]
  214d3f:	movzx  ecx,BYTE PTR [rsp+0xc]
  214d44:	mov    r8,rdi
  214d47:	lea    rdi,[rsp+0x48]
  214d4c:	lea    rdx,[rsp+0x90]
  214d54:	mov    r9,QWORD PTR [rsp+0x28]
  214d59:	push   r10
  214d5b:	push   r11
  214d5d:	push   rax
  214d5e:	call   202240 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214d63:	add    rsp,0x20
  214d67:	jmp    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214d6c:	mov    r10,QWORD PTR [rsp+0x20]
  214d71:	cmp    r10,0x1
  214d75:	jne    214e77 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214d7b:	xor    edx,edx
  214d7d:	cmp    r9,0x1
  214d81:	cmove  rdx,r14
  214d85:	cmp    r8,0x1
  214d89:	jne    214df2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4b2>
  214d8b:	test   rdx,rdx
  214d8e:	je     214df2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4b2>
  214d90:	mov    QWORD PTR [rsp+0x88],rdx
  214d98:	mov    QWORD PTR [rsp+0x90],r12
  214da0:	mov    QWORD PTR [rsp+0x98],rbx
  214da8:	mov    QWORD PTR [rsp+0xa0],r15
  214db0:	mov    QWORD PTR [rsp+0x40],rsi
  214db5:	mov    QWORD PTR [rsp+0x48],rcx
  214dba:	mov    QWORD PTR [rsp+0x50],rbp
  214dbf:	sub    rsp,0x8
  214dc3:	movzx  eax,BYTE PTR [rsp+0xc]
  214dc8:	movzx  esi,BYTE PTR [rsp+0x10]
  214dcd:	movzx  r8d,r13b
  214dd1:	mov    rdx,rdi
  214dd4:	lea    rdi,[rsp+0x90]
  214ddc:	lea    r9,[rsp+0x48]
  214de1:	mov    rcx,QWORD PTR [rsp+0x18]
  214de6:	push   QWORD PTR [rsp+0x160]
  214ded:	push   r11
  214def:	push   rax
  214df0:	jmp    214e69 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x529>
  214df2:	xor    edx,edx
  214df4:	cmp    r15,0x1
  214df8:	cmove  rdx,r14
  214dfc:	cmp    rbp,0x1
  214e00:	jne    214e77 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214e02:	test   rdx,rdx
  214e05:	je     214e77 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x537>
  214e07:	mov    QWORD PTR [rsp+0x88],rdx
  214e0f:	mov    QWORD PTR [rsp+0x90],rbx
  214e17:	mov    QWORD PTR [rsp+0x98],r12
  214e1f:	mov    QWORD PTR [rsp+0xa0],r9
  214e27:	mov    QWORD PTR [rsp+0x40],rdi
  214e2c:	mov    rax,QWORD PTR [rsp+0x10]
  214e31:	mov    QWORD PTR [rsp+0x48],rax
  214e36:	mov    QWORD PTR [rsp+0x50],r8
  214e3b:	sub    rsp,0x8
  214e3f:	movzx  r10d,r13b
  214e43:	mov    rdx,rsi
  214e46:	movzx  esi,BYTE PTR [rsp+0x10]
  214e4b:	movzx  r8d,BYTE PTR [rsp+0xc]
  214e51:	lea    rdi,[rsp+0x90]
  214e59:	lea    r9,[rsp+0x48]
  214e5e:	push   QWORD PTR [rsp+0x160]
  214e65:	push   r11
  214e67:	push   r10
  214e69:	call   1497e0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  214e6e:	add    rsp,0x20
  214e72:	jmp    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  214e77:	mov    QWORD PTR [rsp+0x28],rax
  214e7c:	movups xmm1,XMMWORD PTR [r11]
  214e80:	movaps XMMWORD PTR [rsp+0x40],xmm1
  214e85:	mov    rax,r12
  214e88:	mul    rbx
  214e8b:	mov    QWORD PTR [rsp+0x68],rax
  214e90:	jo     2152be <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x97e>
  214e96:	mul    r10
  214e99:	seto   cl
  214e9c:	not    cl
  214e9e:	cmp    rax,0x1001
  214ea4:	setb   al
  214ea7:	test   cl,al
  214ea9:	mov    r11,QWORD PTR [rsp+0x18]
  214eae:	jne    214f0c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5cc>
  214eb0:	mov    rdx,QWORD PTR [rip+0x337001]        # 54beb8 <_DYNAMIC+0x450>
  214eb7:	mov    rax,QWORD PTR [rdx]
  214eba:	test   rax,rax
  214ebd:	je     2152ca <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x98a>
  214ec3:	mov    cl,0x1
  214ec5:	test   eax,0x80000
  214eca:	jne    2153e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa8>
  214ed0:	mov    rax,QWORD PTR [rdx]
  214ed3:	test   rax,rax
  214ed6:	je     21532c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ec>
  214edc:	test   ax,ax
  214edf:	mov    ecx,DWORD PTR [rsp+0x8]
  214ee3:	jns    214efc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  214ee5:	mov    rax,QWORD PTR [rdx]
  214ee8:	test   rax,rax
  214eeb:	je     21538e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4e>
  214ef1:	bt     rax,0x37
  214ef6:	jb     2153e6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa6>
  214efc:	test   cl,cl
  214efe:	jne    215173 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x833>
  214f04:	xorps  xmm0,xmm0
  214f07:	jmp    21517b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83b>
  214f0c:	cmp    BYTE PTR [rsp+0x8],0x0
  214f11:	jne    214f72 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x632>
  214f13:	xorps  xmm0,xmm0
  214f16:	movsd  QWORD PTR [rsp+0x8],xmm0
  214f1c:	cmp    r15,r9
  214f1f:	jb     214f85 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x645>
  214f21:	mov    eax,DWORD PTR [rsp+0x4]
  214f25:	mov    BYTE PTR [rsp+0x68],al
  214f29:	mov    DWORD PTR [rsp+0x4],r13d
  214f2e:	mov    QWORD PTR [rsp+0x38],rbp
  214f33:	mov    rax,QWORD PTR [rsp+0x28]
  214f38:	mov    QWORD PTR [rsp+0x30],rax
  214f3d:	mov    QWORD PTR [rsp+0x80],rsi
  214f45:	mov    QWORD PTR [rsp+0x28],r11
  214f4a:	mov    rax,r8
  214f4d:	mov    rsi,rdi
  214f50:	mov    QWORD PTR [rsp+0x18],r15
  214f55:	mov    r15,r9
  214f58:	mov    rbp,rbx
  214f5b:	mov    rbx,r12
  214f5e:	jmp    214fa7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x667>
  214f60:	cmp    r9,0x1
  214f64:	jne    2150cc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x78c>
  214f6a:	mov    rax,r12
  214f6d:	jmp    2151e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a9>
  214f72:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2ac5e]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  214f7a:	movsd  QWORD PTR [rsp+0x8],xmm0
  214f80:	cmp    r15,r9
  214f83:	jae    214f21 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5e1>
  214f85:	mov    BYTE PTR [rsp+0x68],r13b
  214f8a:	mov    QWORD PTR [rsp+0x38],r8
  214f8f:	mov    QWORD PTR [rsp+0x30],r11
  214f94:	mov    QWORD PTR [rsp+0x80],rdi
  214f9c:	mov    QWORD PTR [rsp+0x18],r9
  214fa1:	mov    rax,rbp
  214fa4:	mov    rbp,r12
  214fa7:	movaps XMMWORD PTR [rsp+0x70],xmm1
  214fac:	mov    QWORD PTR [rsp+0x10],rsi
  214fb1:	mov    r13,rax
  214fb4:	cmp    rax,0x1
  214fb8:	jne    214fe3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a3>
  214fba:	cmp    r15,0x1
  214fbe:	jne    214fe3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a3>
  214fc0:	lea    r8,[rip+0x32bc49]        # 540c10 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x3e0>
  214fc7:	lea    rdi,[rsp+0x88]
  214fcf:	mov    rsi,rbx
  214fd2:	mov    rdx,rbp
  214fd5:	mov    rcx,r10
  214fd8:	mov    r12,r10
  214fdb:	call   QWORD PTR [rip+0x3371d7]        # 54c1b8 <_DYNAMIC+0x750>
  214fe1:	jmp    215004 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6c4>
  214fe3:	lea    r8,[rip+0x32bc3e]        # 540c28 <anon.4dcff42e9a1accce12240a10dc27db1b.273.llvm.11572620769852878276+0x3f8>
  214fea:	lea    rdi,[rsp+0x88]
  214ff2:	mov    rsi,rbx
  214ff5:	mov    rdx,rbp
  214ff8:	mov    rcx,r10
  214ffb:	mov    r12,r10
  214ffe:	call   QWORD PTR [rip+0x3371bc]        # 54c1c0 <_DYNAMIC+0x758>
  215004:	lea    rdi,[rsp+0x90]
  21500c:	mov    rsi,QWORD PTR [rsp+0xb0]
  215014:	mov    rdx,QWORD PTR [rsp+0xb8]
  21501c:	movups xmm0,XMMWORD PTR [rsp+0xc0]
  215024:	movaps xmm2,XMMWORD PTR [rsp+0x70]
  215029:	movaps xmm3,xmm2
  21502c:	unpckhpd xmm3,xmm2
  215030:	sub    rsp,0x70
  215034:	movups XMMWORD PTR [rsp+0x58],xmm0
  215039:	movzx  eax,BYTE PTR [rsp+0xd8]
  215041:	mov    DWORD PTR [rsp+0x50],eax
  215045:	movzx  eax,BYTE PTR [rsp+0x74]
  21504a:	mov    DWORD PTR [rsp+0x48],eax
  21504e:	mov    rax,QWORD PTR [rsp+0xa8]
  215056:	mov    QWORD PTR [rsp+0x40],rax
  21505b:	mov    rax,QWORD PTR [rsp+0xa0]
  215063:	mov    QWORD PTR [rsp+0x38],rax
  215068:	mov    rax,QWORD PTR [rsp+0xf0]
  215070:	mov    QWORD PTR [rsp+0x30],rax
  215075:	mov    rax,QWORD PTR [rsp+0x98]
  21507d:	mov    QWORD PTR [rsp+0x28],rax
  215082:	mov    QWORD PTR [rsp+0x20],r13
  215087:	mov    rax,QWORD PTR [rsp+0x80]
  21508f:	mov    QWORD PTR [rsp+0x18],rax
  215094:	mov    rax,QWORD PTR [rsp+0x88]
  21509c:	mov    QWORD PTR [rsp+0x10],rax
  2150a1:	mov    QWORD PTR [rsp+0x8],r15
  2150a6:	mov    QWORD PTR [rsp],r14
  2150aa:	xorps  xmm1,xmm1
  2150ad:	mov    r8,rbp
  2150b0:	mov    r9,r12
  2150b3:	mov    rcx,rbx
  2150b6:	movsd  xmm0,QWORD PTR [rsp+0x78]
  2150bc:	call   QWORD PTR [rsp+0xf8]
  2150c3:	add    rsp,0x70
  2150c7:	jmp    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  2150cc:	lea    rax,[r12-0x1]
  2150d1:	mov    ecx,r12d
  2150d4:	and    ecx,0x3
  2150d7:	and    r12,0xfffffffffffffffc
  2150db:	mov    rdx,r9
  2150de:	shl    rdx,0x4
  2150e2:	lea    rsi,[rdx+rdx*2]
  2150e6:	shl    r15,0x4
  2150ea:	mov    rdi,r9
  2150ed:	shl    rdi,0x6
  2150f1:	shl    r9,0x5
  2150f5:	xor    r8d,r8d
  2150f8:	xorps  xmm0,xmm0
  2150fb:	jmp    21510f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7cf>
  2150fd:	nop    DWORD PTR [rax]
  215100:	inc    r8
  215103:	add    r14,r15
  215106:	cmp    r8,rbx
  215109:	je     2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21510f:	cmp    rax,0x3
  215113:	jae    215120 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7e0>
  215115:	xor    r10d,r10d
  215118:	jmp    215154 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x814>
  21511a:	nop    WORD PTR [rax+rax*1+0x0]
  215120:	mov    r11,r14
  215123:	xor    r10d,r10d
  215126:	cs nop WORD PTR [rax+rax*1+0x0]
  215130:	movups XMMWORD PTR [r11],xmm0
  215134:	movups XMMWORD PTR [r11+rdx*1],xmm0
  215139:	movups XMMWORD PTR [r11+r9*1],xmm0
  21513e:	add    r10,0x4
  215142:	movups XMMWORD PTR [r11+rsi*1],xmm0
  215147:	add    r11,rdi
  21514a:	cmp    r12,r10
  21514d:	jne    215130 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f0>
  21514f:	test   rcx,rcx
  215152:	je     215100 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7c0>
  215154:	imul   r10,rdx
  215158:	add    r10,r14
  21515b:	mov    r11,rcx
  21515e:	xchg   ax,ax
  215160:	movups XMMWORD PTR [r10],xmm0
  215164:	add    r10,rdx
  215167:	dec    r11
  21516a:	jne    215160 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x820>
  21516c:	jmp    215100 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7c0>
  21516e:	mov    rax,r12
  215171:	jmp    2151da <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89a>
  215173:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe2aa5d]        # 3fbd8 <anon.03da1a85e27060e492eed264a8d11945.309.llvm.17707249663368488368+0x108>
  21517b:	mov    eax,DWORD PTR [rsp+0x4]
  21517f:	mov    rdx,QWORD PTR [rsp+0x158]
  215187:	mov    QWORD PTR [rsp+0x8],rdi
  21518c:	mov    QWORD PTR [rsp+0x10],rsi
  215191:	movaps xmm2,xmm1
  215194:	unpckhpd xmm2,xmm1
  215198:	test   rdx,rdx
  21519b:	je     215271 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x931>
  2151a1:	sub    rsp,0x8
  2151a5:	mov    r11,rdx
  2151a8:	movzx  r10d,al
  2151ac:	movzx  r13d,r13b
  2151b0:	movzx  eax,cl
  2151b3:	mov    rdi,r12
  2151b6:	mov    rsi,rbx
  2151b9:	mov    rdx,QWORD PTR [rsp+0x28]
  2151be:	mov    rcx,r14
  2151c1:	mov    r8,r15
  2151c4:	push   r11
  2151c6:	push   0x1
  2151c8:	push   r10
  2151ca:	push   r13
  2151cc:	jmp    215297 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x957>
  2151d1:	mov    rax,rbx
  2151d4:	mov    rbx,r12
  2151d7:	mov    r15,r9
  2151da:	mov    ecx,0x1
  2151df:	sub    rcx,rax
  2151e2:	shl    rcx,0x4
  2151e6:	add    r14,rcx
  2151e9:	lea    rcx,[rax-0x1]
  2151ed:	mov    edx,eax
  2151ef:	and    edx,0x3
  2151f2:	and    rax,0xfffffffffffffffc
  2151f6:	xor    esi,esi
  2151f8:	xorps  xmm0,xmm0
  2151fb:	jmp    21520c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8cc>
  2151fd:	nop    DWORD PTR [rax]
  215200:	inc    rsi
  215203:	cmp    rsi,rbx
  215206:	je     2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  21520c:	mov    rdi,rsi
  21520f:	imul   rdi,r15
  215213:	shl    rdi,0x4
  215217:	add    rdi,r14
  21521a:	cmp    rcx,0x3
  21521e:	jb     215251 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x911>
  215220:	xor    r8d,r8d
  215223:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  215230:	movups XMMWORD PTR [rdi],xmm0
  215233:	movups XMMWORD PTR [rdi+0x10],xmm0
  215237:	movups XMMWORD PTR [rdi+0x20],xmm0
  21523b:	movups XMMWORD PTR [rdi+0x30],xmm0
  21523f:	add    rdi,0x40
  215243:	add    r8,0x4
  215247:	cmp    rax,r8
  21524a:	jne    215230 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8f0>
  21524c:	test   rdx,rdx
  21524f:	je     215200 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c0>
  215251:	xor    r8d,r8d
  215254:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  215260:	movups XMMWORD PTR [rdi],xmm0
  215263:	add    rdi,0x10
  215267:	inc    r8
  21526a:	cmp    rdx,r8
  21526d:	jne    215260 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x920>
  21526f:	jmp    215200 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c0>
  215271:	sub    rsp,0x10
  215275:	movzx  r10d,al
  215279:	movzx  r11d,r13b
  21527d:	movzx  eax,cl
  215280:	mov    rdi,r12
  215283:	mov    rsi,rbx
  215286:	mov    rdx,QWORD PTR [rsp+0x30]
  21528b:	mov    rcx,r14
  21528e:	mov    r8,r15
  215291:	push   0x0
  215293:	push   r10
  215295:	push   r11
  215297:	push   QWORD PTR [rsp+0x50]
  21529b:	push   rbp
  21529c:	push   QWORD PTR [rsp+0x48]
  2152a0:	push   QWORD PTR [rsp+0xa0]
  2152a7:	push   QWORD PTR [rsp+0x60]
  2152ab:	push   QWORD PTR [rsp+0x58]
  2152af:	push   rax
  2152b0:	call   20af50 <_RINvNtCsg5mHgTaYUa7_4gemm4gemm4gemmINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  2152b5:	add    rsp,0x60
  2152b9:	jmp    2154c8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb88>
  2152be:	mov    rax,0xffffffffffffffff
  2152c5:	jmp    214e96 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x556>
  2152ca:	mov    QWORD PTR [rsp+0x38],r9
  2152cf:	mov    QWORD PTR [rsp+0x10],rsi
  2152d4:	mov    QWORD PTR [rsp+0x30],rbp
  2152d9:	mov    ebp,r13d
  2152dc:	mov    r13,rdi
  2152df:	movaps XMMWORD PTR [rsp+0x70],xmm1
  2152e4:	call   QWORD PTR [rip+0x336bd6]        # 54bec0 <_DYNAMIC+0x458>
  2152ea:	mov    rdx,QWORD PTR [rip+0x336bc7]        # 54beb8 <_DYNAMIC+0x450>
  2152f1:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  2152f6:	mov    r11,QWORD PTR [rsp+0x18]
  2152fb:	mov    r8,QWORD PTR [rsp+0x60]
  215300:	mov    rdi,r13
  215303:	mov    r13d,ebp
  215306:	mov    rbp,QWORD PTR [rsp+0x30]
  21530b:	mov    rsi,QWORD PTR [rsp+0x10]
  215310:	mov    r10,QWORD PTR [rsp+0x20]
  215315:	mov    r9,QWORD PTR [rsp+0x38]
  21531a:	mov    cl,0x1
  21531c:	test   eax,0x80000
  215321:	je     214ed0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x590>
  215327:	jmp    2153e8 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa8>
  21532c:	mov    QWORD PTR [rsp+0x38],r9
  215331:	mov    QWORD PTR [rsp+0x10],rsi
  215336:	mov    QWORD PTR [rsp+0x30],rbp
  21533b:	mov    ebp,r13d
  21533e:	mov    r13,rdi
  215341:	movaps XMMWORD PTR [rsp+0x70],xmm1
  215346:	call   QWORD PTR [rip+0x336b74]        # 54bec0 <_DYNAMIC+0x458>
  21534c:	mov    rdx,QWORD PTR [rip+0x336b65]        # 54beb8 <_DYNAMIC+0x450>
  215353:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  215358:	mov    r11,QWORD PTR [rsp+0x18]
  21535d:	mov    r8,QWORD PTR [rsp+0x60]
  215362:	mov    rdi,r13
  215365:	mov    r13d,ebp
  215368:	mov    rbp,QWORD PTR [rsp+0x30]
  21536d:	mov    rsi,QWORD PTR [rsp+0x10]
  215372:	mov    r10,QWORD PTR [rsp+0x20]
  215377:	mov    r9,QWORD PTR [rsp+0x38]
  21537c:	test   ax,ax
  21537f:	mov    ecx,DWORD PTR [rsp+0x8]
  215383:	js     214ee5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a5>
  215389:	jmp    214efc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  21538e:	mov    QWORD PTR [rsp+0x38],r9
  215393:	mov    QWORD PTR [rsp+0x10],rsi
  215398:	mov    QWORD PTR [rsp+0x30],rbp
  21539d:	mov    ebp,r13d
  2153a0:	mov    r13,rdi
  2153a3:	movaps XMMWORD PTR [rsp+0x70],xmm1
  2153a8:	call   QWORD PTR [rip+0x336b12]        # 54bec0 <_DYNAMIC+0x458>
  2153ae:	movaps xmm1,XMMWORD PTR [rsp+0x70]
  2153b3:	mov    r11,QWORD PTR [rsp+0x18]
  2153b8:	mov    r8,QWORD PTR [rsp+0x60]
  2153bd:	mov    ecx,DWORD PTR [rsp+0x8]
  2153c1:	mov    rdi,r13
  2153c4:	mov    r13d,ebp
  2153c7:	mov    rbp,QWORD PTR [rsp+0x30]
  2153cc:	mov    rsi,QWORD PTR [rsp+0x10]
  2153d1:	mov    r10,QWORD PTR [rsp+0x20]
  2153d6:	mov    r9,QWORD PTR [rsp+0x38]
  2153db:	bt     rax,0x37
  2153e0:	jae    214efc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5bc>
  2153e6:	xor    ecx,ecx
  2153e8:	mov    DWORD PTR [rsp+0x20],ecx
  2153ec:	mov    rcx,QWORD PTR [rsp+0x68]
  2153f1:	imul   rcx,r10
  2153f5:	mov    rdx,QWORD PTR [rsp+0x158]
  2153fd:	cmp    rdx,0x1
  215401:	adc    rdx,0x0
  215405:	cmp    rcx,0x10000
  21540c:	mov    eax,0x1
  215411:	cmovae rax,rdx
  215415:	sub    rsp,0xa0
  21541c:	lea    rdx,[rsp+0xe0]
  215424:	mov    QWORD PTR [rsp+0x88],rdx
  21542c:	movzx  edx,BYTE PTR [rsp+0xa4]
  215434:	mov    DWORD PTR [rsp+0x80],edx
  21543b:	mov    QWORD PTR [rsp+0x78],rbp
  215440:	mov    rdx,QWORD PTR [rsp+0xc8]
  215448:	mov    QWORD PTR [rsp+0x70],rdx
  21544d:	mov    QWORD PTR [rsp+0x68],rsi
  215452:	xorps  xmm0,xmm0
  215455:	movups XMMWORD PTR [rsp+0x58],xmm0
  21545a:	movzx  edx,r13b
  21545e:	mov    DWORD PTR [rsp+0x50],edx
  215462:	mov    QWORD PTR [rsp+0x48],r11
  215467:	mov    QWORD PTR [rsp+0x40],r8
  21546c:	mov    QWORD PTR [rsp+0x38],rdi
  215471:	movzx  edx,BYTE PTR [rsp+0xa8]
  215479:	mov    DWORD PTR [rsp+0x30],edx
  21547d:	movups XMMWORD PTR [rsp+0x18],xmm0
  215482:	mov    QWORD PTR [rsp+0x10],r15
  215487:	mov    QWORD PTR [rsp+0x8],r9
  21548c:	mov    QWORD PTR [rsp],r14
  215490:	mov    QWORD PTR [rsp+0x90],rax
  215498:	mov    DWORD PTR [rsp+0x28],0x2
  2154a0:	movzx  edx,BYTE PTR [rsp+0xc0]
  2154a8:	mov    r8,rbx
  2154ab:	mov    edi,0x3
  2154b0:	mov    r9,r10
  2154b3:	mov    esi,0x1
  2154b8:	mov    rcx,r12
  2154bb:	call   QWORD PTR [rip+0x336a07]        # 54bec8 <_DYNAMIC+0x460>
  2154c1:	add    rsp,0xa0
  2154c8:	add    rsp,0x118
  2154cf:	pop    rbx
  2154d0:	pop    r12
  2154d2:	pop    r13
  2154d4:	pop    r14
  2154d6:	pop    r15
  2154d8:	pop    rbp
  2154d9:	ret
