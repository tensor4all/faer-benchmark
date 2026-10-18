
target/faer-rev/7364be5ce22d-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001eda10 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  1eda10:	push   rbp
  1eda11:	push   r15
  1eda13:	push   r14
  1eda15:	push   r13
  1eda17:	push   r12
  1eda19:	push   rbx
  1eda1a:	sub    rsp,0x128
  1eda21:	mov    r12,QWORD PTR [rdi+0x8]
  1eda25:	test   r12,r12
  1eda28:	je     1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1eda2e:	mov    r15,QWORD PTR [rdi+0x10]
  1eda32:	test   r15,r15
  1eda35:	je     1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1eda3b:	mov    rbx,QWORD PTR [rdi]
  1eda3e:	mov    r14,QWORD PTR [rdi+0x18]
  1eda42:	mov    rbp,QWORD PTR [rdi+0x20]
  1eda46:	mov    rax,QWORD PTR [rdx+0x10]
  1eda4a:	mov    QWORD PTR [rsp+0x40],rax
  1eda4f:	test   rax,rax
  1eda52:	je     1edb08 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf8>
  1eda58:	mov    DWORD PTR [rsp+0x20],r9d
  1eda5d:	mov    DWORD PTR [rsp+0x38],esi
  1eda61:	mov    DWORD PTR [rsp+0x10],ecx
  1eda65:	mov    r13,QWORD PTR [rdx]
  1eda68:	mov    rcx,QWORD PTR [rdx+0x8]
  1eda6c:	mov    rsi,QWORD PTR [rdx+0x18]
  1eda70:	test   r14,r14
  1eda73:	mov    QWORD PTR [rsp+0x30],rcx
  1eda78:	jns    1edab8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa8>
  1eda7a:	lea    rax,[r12-0x1]
  1eda7f:	imul   rax,r14
  1eda83:	shl    rax,0x4
  1eda87:	add    rbx,rax
  1eda8a:	neg    r14
  1eda8d:	xor    eax,eax
  1eda8f:	mov    r9,rsi
  1eda92:	mov    rsi,rcx
  1eda95:	sub    rsi,0x1
  1eda99:	cmovb  rsi,rax
  1eda9d:	mov    rdi,r9
  1edaa0:	imul   rdi,rsi
  1edaa4:	cmp    rsi,rcx
  1edaa7:	mov    rsi,r9
  1edaaa:	cmove  rdi,rax
  1edaae:	shl    rdi,0x4
  1edab2:	add    r13,rdi
  1edab5:	neg    rsi
  1edab8:	mov    rax,QWORD PTR [rdx+0x20]
  1edabc:	mov    rdi,QWORD PTR [r8]
  1edabf:	mov    r10,QWORD PTR [r8+0x8]
  1edac3:	mov    r9,QWORD PTR [r8+0x10]
  1edac7:	mov    rcx,QWORD PTR [r8+0x20]
  1edacb:	test   rbp,rbp
  1edace:	mov    QWORD PTR [rsp+0x50],r9
  1edad3:	mov    QWORD PTR [rsp+0x28],r10
  1edad8:	js     1edb57 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x147>
  1edada:	mov    r11,QWORD PTR [r8+0x18]
  1edade:	test   rax,rax
  1edae1:	js     1edbc5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b5>
  1edae7:	mov    QWORD PTR [rsp+0x18],r13
  1edaec:	mov    r10,QWORD PTR [rsp+0x160]
  1edaf4:	cmp    r15,0x1
  1edaf8:	mov    r8,QWORD PTR [rsp+0x50]
  1edafd:	je     1edc46 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x236>
  1edb03:	jmp    1edd42 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1edb08:	test   sil,sil
  1edb0b:	jne    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1edb11:	cmp    r12,0x1
  1edb15:	je     1edb2b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x11b>
  1edb17:	cmp    r14,0xffffffffffffffff
  1edb1b:	je     1ee2ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x89e>
  1edb21:	cmp    r14,0x1
  1edb25:	je     1ee04b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x63b>
  1edb2b:	cmp    r15,0x1
  1edb2f:	je     1ee041 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1edb35:	cmp    rbp,0xffffffffffffffff
  1edb39:	je     1ee41a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa0a>
  1edb3f:	cmp    rbp,0x1
  1edb43:	jne    1ee041 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x631>
  1edb49:	mov    rax,r15
  1edb4c:	mov    r15,r12
  1edb4f:	mov    rbp,r14
  1edb52:	jmp    1ee432 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  1edb57:	lea    rdx,[r15-0x1]
  1edb5b:	imul   rdx,rbp
  1edb5f:	shl    rdx,0x4
  1edb63:	add    rbx,rdx
  1edb66:	neg    rbp
  1edb69:	xor    edx,edx
  1edb6b:	mov    r11,rsi
  1edb6e:	mov    rsi,r9
  1edb71:	sub    rsi,0x1
  1edb75:	cmovb  rsi,rdx
  1edb79:	mov    rdx,rbp
  1edb7c:	mov    rbp,rcx
  1edb7f:	mov    rcx,rdi
  1edb82:	mov    rdi,rbp
  1edb85:	imul   rdi,rsi
  1edb89:	cmp    rsi,r9
  1edb8c:	mov    rsi,r11
  1edb8f:	mov    r10,QWORD PTR [rsp+0x28]
  1edb94:	mov    r9d,0x0
  1edb9a:	cmove  rdi,r9
  1edb9e:	test   r10,r10
  1edba1:	cmove  rdi,r10
  1edba5:	shl    rdi,0x4
  1edba9:	add    rcx,rdi
  1edbac:	mov    rdi,rcx
  1edbaf:	mov    rcx,rbp
  1edbb2:	mov    rbp,rdx
  1edbb5:	neg    rcx
  1edbb8:	mov    r11,QWORD PTR [r8+0x18]
  1edbbc:	test   rax,rax
  1edbbf:	jns    1edae7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd7>
  1edbc5:	mov    rdx,QWORD PTR [rsp+0x40]
  1edbca:	dec    rdx
  1edbcd:	imul   rdx,rax
  1edbd1:	mov    r8,QWORD PTR [rsp+0x30]
  1edbd6:	test   r8,r8
  1edbd9:	cmove  rdx,r8
  1edbdd:	shl    rdx,0x4
  1edbe1:	add    r13,rdx
  1edbe4:	mov    QWORD PTR [rsp+0x18],r13
  1edbe9:	neg    rax
  1edbec:	xor    edx,edx
  1edbee:	mov    r8,rsi
  1edbf1:	mov    rsi,r10
  1edbf4:	sub    rsi,0x1
  1edbf8:	cmovb  rsi,rdx
  1edbfc:	mov    r13,rcx
  1edbff:	mov    rcx,rdi
  1edc02:	mov    rdi,r11
  1edc05:	imul   rdi,rsi
  1edc09:	mov    r9,QWORD PTR [rsp+0x50]
  1edc0e:	test   r9,r9
  1edc11:	cmove  rdi,r9
  1edc15:	cmp    rsi,r10
  1edc18:	mov    rsi,r8
  1edc1b:	cmove  rdi,rdx
  1edc1f:	shl    rdi,0x4
  1edc23:	add    rcx,rdi
  1edc26:	mov    rdi,rcx
  1edc29:	mov    rcx,r13
  1edc2c:	neg    r11
  1edc2f:	mov    r10,QWORD PTR [rsp+0x160]
  1edc37:	cmp    r15,0x1
  1edc3b:	mov    r8,QWORD PTR [rsp+0x50]
  1edc40:	jne    1edd42 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1edc46:	cmp    rsi,0x1
  1edc4a:	jne    1edcc6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1edc4c:	cmp    r14,0x1
  1edc50:	jne    1edcc6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1edc52:	test   rbx,rbx
  1edc55:	je     1edcc6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b6>
  1edc57:	mov    rcx,QWORD PTR [rsp+0x18]
  1edc5c:	mov    QWORD PTR [rsp+0x90],rcx
  1edc64:	mov    rcx,QWORD PTR [rsp+0x30]
  1edc69:	mov    QWORD PTR [rsp+0x98],rcx
  1edc71:	mov    rcx,QWORD PTR [rsp+0x40]
  1edc76:	mov    QWORD PTR [rsp+0xa0],rcx
  1edc7e:	mov    QWORD PTR [rsp+0xa8],rax
  1edc86:	mov    QWORD PTR [rsp+0x60],rdi
  1edc8b:	mov    rax,QWORD PTR [rsp+0x28]
  1edc90:	mov    QWORD PTR [rsp+0x68],rax
  1edc95:	mov    QWORD PTR [rsp+0x70],r11
  1edc9a:	sub    rsp,0x8
  1edc9e:	movzx  eax,BYTE PTR [rsp+0x28]
  1edca3:	movzx  edx,BYTE PTR [rsp+0x40]
  1edca8:	movzx  r8d,BYTE PTR [rsp+0x18]
  1edcae:	lea    rcx,[rsp+0x98]
  1edcb6:	lea    r9,[rsp+0x68]
  1edcbb:	mov    rdi,rbx
  1edcbe:	mov    rsi,r12
  1edcc1:	jmp    1eddca <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3ba>
  1edcc6:	cmp    rax,0x1
  1edcca:	jne    1edd42 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1edccc:	cmp    r11,0x1
  1edcd0:	jne    1edd42 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1edcd2:	test   rdi,rdi
  1edcd5:	je     1edd42 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x332>
  1edcd7:	mov    rax,QWORD PTR [rsp+0x18]
  1edcdc:	mov    QWORD PTR [rsp+0x90],rax
  1edce4:	mov    rax,QWORD PTR [rsp+0x30]
  1edce9:	mov    QWORD PTR [rsp+0x98],rax
  1edcf1:	mov    rax,QWORD PTR [rsp+0x40]
  1edcf6:	mov    QWORD PTR [rsp+0xa0],rax
  1edcfe:	mov    QWORD PTR [rsp+0xa8],rsi
  1edd06:	mov    QWORD PTR [rsp+0x60],rbx
  1edd0b:	mov    QWORD PTR [rsp+0x68],r12
  1edd10:	mov    QWORD PTR [rsp+0x70],r14
  1edd15:	sub    rsp,0x8
  1edd19:	movzx  eax,BYTE PTR [rsp+0x28]
  1edd1e:	movzx  esi,BYTE PTR [rsp+0x40]
  1edd23:	movzx  ecx,BYTE PTR [rsp+0x18]
  1edd28:	mov    r8,rdi
  1edd2b:	lea    rdi,[rsp+0x68]
  1edd30:	lea    rdx,[rsp+0x98]
  1edd38:	mov    r9,QWORD PTR [rsp+0x30]
  1edd3d:	jmp    1ede57 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x447>
  1edd42:	cmp    r12,0x1
  1edd46:	jne    1ede6f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1edd4c:	xor    edx,edx
  1edd4e:	cmp    rbp,0x1
  1edd52:	cmove  rdx,rbx
  1edd56:	cmp    rcx,0x1
  1edd5a:	jne    1edde2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  1edd60:	test   rdx,rdx
  1edd63:	je     1edde2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3d2>
  1edd65:	mov    QWORD PTR [rsp+0x90],rdi
  1edd6d:	mov    QWORD PTR [rsp+0x98],r8
  1edd75:	mov    rcx,QWORD PTR [rsp+0x28]
  1edd7a:	mov    QWORD PTR [rsp+0xa0],rcx
  1edd82:	mov    QWORD PTR [rsp+0xa8],r11
  1edd8a:	mov    rcx,QWORD PTR [rsp+0x18]
  1edd8f:	mov    QWORD PTR [rsp+0x60],rcx
  1edd94:	mov    rcx,QWORD PTR [rsp+0x40]
  1edd99:	mov    QWORD PTR [rsp+0x68],rcx
  1edd9e:	mov    QWORD PTR [rsp+0x70],rax
  1edda3:	sub    rsp,0x8
  1edda7:	movzx  eax,BYTE PTR [rsp+0x18]
  1eddac:	movzx  edx,BYTE PTR [rsp+0x40]
  1eddb1:	movzx  r8d,BYTE PTR [rsp+0x28]
  1eddb7:	lea    rcx,[rsp+0x98]
  1eddbf:	lea    r9,[rsp+0x68]
  1eddc4:	mov    rdi,rbx
  1eddc7:	mov    rsi,r15
  1eddca:	push   QWORD PTR [rsp+0x170]
  1eddd1:	push   r10
  1eddd3:	push   rax
  1eddd4:	call   1591e0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1eddd9:	add    rsp,0x20
  1edddd:	jmp    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1edde2:	xor    edx,edx
  1edde4:	cmp    rax,0x1
  1edde8:	cmove  rdx,QWORD PTR [rsp+0x18]
  1eddee:	cmp    r11,0x1
  1eddf2:	jne    1ede6f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1eddf4:	test   rdx,rdx
  1eddf7:	je     1ede6f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x45f>
  1eddf9:	mov    QWORD PTR [rsp+0x90],rdi
  1ede01:	mov    QWORD PTR [rsp+0x98],r8
  1ede09:	mov    rax,QWORD PTR [rsp+0x28]
  1ede0e:	mov    QWORD PTR [rsp+0xa0],rax
  1ede16:	mov    QWORD PTR [rsp+0xa8],rcx
  1ede1e:	mov    QWORD PTR [rsp+0x60],rbx
  1ede23:	mov    QWORD PTR [rsp+0x68],r15
  1ede28:	mov    QWORD PTR [rsp+0x70],rbp
  1ede2d:	sub    rsp,0x8
  1ede31:	movzx  eax,BYTE PTR [rsp+0x18]
  1ede36:	movzx  esi,BYTE PTR [rsp+0x40]
  1ede3b:	movzx  ecx,BYTE PTR [rsp+0x28]
  1ede40:	lea    rdi,[rsp+0x68]
  1ede45:	lea    rdx,[rsp+0x98]
  1ede4d:	mov    r8,QWORD PTR [rsp+0x20]
  1ede52:	mov    r9,QWORD PTR [rsp+0x48]
  1ede57:	push   QWORD PTR [rsp+0x170]
  1ede5e:	push   r10
  1ede60:	push   rax
  1ede61:	call   1f8240 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1ede66:	add    rsp,0x20
  1ede6a:	jmp    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1ede6f:	cmp    QWORD PTR [rsp+0x40],0x1
  1ede75:	jne    1edf88 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1ede7b:	xor    edx,edx
  1ede7d:	cmp    r14,0x1
  1ede81:	cmove  rdx,rbx
  1ede85:	cmp    rsi,0x1
  1ede89:	jne    1edef9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  1ede8b:	test   rdx,rdx
  1ede8e:	je     1edef9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4e9>
  1ede90:	mov    QWORD PTR [rsp+0x90],rdx
  1ede98:	mov    QWORD PTR [rsp+0x98],r12
  1edea0:	mov    QWORD PTR [rsp+0xa0],r15
  1edea8:	mov    QWORD PTR [rsp+0xa8],rbp
  1edeb0:	mov    QWORD PTR [rsp+0x60],rdi
  1edeb5:	mov    QWORD PTR [rsp+0x68],r8
  1edeba:	mov    QWORD PTR [rsp+0x70],rcx
  1edebf:	sub    rsp,0x8
  1edec3:	movzx  eax,BYTE PTR [rsp+0x28]
  1edec8:	movzx  esi,BYTE PTR [rsp+0x40]
  1edecd:	movzx  r8d,BYTE PTR [rsp+0x18]
  1eded3:	lea    rdi,[rsp+0x98]
  1ededb:	lea    r9,[rsp+0x68]
  1edee0:	mov    rdx,QWORD PTR [rsp+0x20]
  1edee5:	mov    rcx,QWORD PTR [rsp+0x38]
  1edeea:	push   QWORD PTR [rsp+0x170]
  1edef1:	push   r10
  1edef3:	push   rax
  1edef4:	jmp    1edf7a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x56a>
  1edef9:	xor    edx,edx
  1edefb:	cmp    rbp,0x1
  1edeff:	cmove  rdx,rbx
  1edf03:	cmp    rcx,0x1
  1edf07:	jne    1edf88 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1edf09:	test   rdx,rdx
  1edf0c:	je     1edf88 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x578>
  1edf0e:	mov    QWORD PTR [rsp+0x90],rdx
  1edf16:	mov    QWORD PTR [rsp+0x98],r15
  1edf1e:	mov    QWORD PTR [rsp+0xa0],r12
  1edf26:	mov    QWORD PTR [rsp+0xa8],r14
  1edf2e:	mov    rax,QWORD PTR [rsp+0x18]
  1edf33:	mov    QWORD PTR [rsp+0x60],rax
  1edf38:	mov    rax,QWORD PTR [rsp+0x30]
  1edf3d:	mov    QWORD PTR [rsp+0x68],rax
  1edf42:	mov    QWORD PTR [rsp+0x70],rsi
  1edf47:	sub    rsp,0x8
  1edf4b:	movzx  r11d,BYTE PTR [rsp+0x18]
  1edf51:	movzx  esi,BYTE PTR [rsp+0x40]
  1edf56:	mov    rcx,r8
  1edf59:	movzx  r8d,BYTE PTR [rsp+0x28]
  1edf5f:	mov    rdx,rdi
  1edf62:	lea    rdi,[rsp+0x98]
  1edf6a:	lea    r9,[rsp+0x68]
  1edf6f:	push   QWORD PTR [rsp+0x170]
  1edf76:	push   r10
  1edf78:	push   r11
  1edf7a:	call   158dc0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1edf7f:	add    rsp,0x20
  1edf83:	jmp    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1edf88:	mov    QWORD PTR [rsp+0x28],r11
  1edf8d:	mov    QWORD PTR [rsp+0x50],rcx
  1edf92:	mov    QWORD PTR [rsp+0x30],rdi
  1edf97:	mov    QWORD PTR [rsp+0x58],rax
  1edf9c:	movups xmm2,XMMWORD PTR [r10]
  1edfa0:	mov    rax,r12
  1edfa3:	mul    r15
  1edfa6:	mov    r13,rax
  1edfa9:	movaps XMMWORD PTR [rsp+0x60],xmm2
  1edfae:	seto   r10b
  1edfb2:	jo     1ee53d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb2d>
  1edfb8:	mul    QWORD PTR [rsp+0x40]
  1edfbd:	seto   cl
  1edfc0:	not    cl
  1edfc2:	cmp    rax,0x1001
  1edfc8:	setb   al
  1edfcb:	test   cl,al
  1edfcd:	mov    rdi,QWORD PTR [rsp+0x18]
  1edfd2:	mov    r8d,DWORD PTR [rsp+0x10]
  1edfd7:	mov    r9d,DWORD PTR [rsp+0x38]
  1edfdc:	jne    1ee037 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x627>
  1edfde:	mov    rdx,QWORD PTR [rip+0x35c333]        # 54a318 <_DYNAMIC+0x540>
  1edfe5:	mov    rax,QWORD PTR [rdx]
  1edfe8:	test   rax,rax
  1edfeb:	je     1ee549 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb39>
  1edff1:	mov    cl,0x1
  1edff3:	test   eax,0x80000
  1edff8:	jne    1ee632 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  1edffe:	mov    rax,QWORD PTR [rdx]
  1ee001:	test   rax,rax
  1ee004:	je     1ee59c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8c>
  1ee00a:	test   ax,ax
  1ee00d:	jns    1ee026 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1ee00f:	mov    rax,QWORD PTR [rdx]
  1ee012:	test   rax,rax
  1ee015:	je     1ee5eb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbdb>
  1ee01b:	bt     rax,0x37
  1ee020:	jb     1ee630 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc20>
  1ee026:	test   r9b,r9b
  1ee029:	jne    1ee2b6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8a6>
  1ee02f:	xorps  xmm0,xmm0
  1ee032:	jmp    1ee2be <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8ae>
  1ee037:	test   r9b,r9b
  1ee03a:	jne    1ee053 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x643>
  1ee03c:	xorps  xmm0,xmm0
  1ee03f:	jmp    1ee05b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x64b>
  1ee041:	cmp    r14,0x1
  1ee045:	jne    1ee208 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7f8>
  1ee04b:	mov    rax,r12
  1ee04e:	jmp    1ee432 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa22>
  1ee053:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe51a6d]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1ee05b:	movsd  QWORD PTR [rsp+0x38],xmm0
  1ee061:	mov    r13d,DWORD PTR [rsp+0x20]
  1ee066:	mov    rax,QWORD PTR [rsp+0x58]
  1ee06b:	mov    rcx,QWORD PTR [rsp+0x50]
  1ee070:	mov    rdx,QWORD PTR [rsp+0x28]
  1ee075:	cmp    rbp,r14
  1ee078:	jae    1ee098 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x688>
  1ee07a:	mov    BYTE PTR [rsp+0x20],r8b
  1ee07f:	mov    QWORD PTR [rsp+0x10],rsi
  1ee084:	mov    QWORD PTR [rsp+0x58],rax
  1ee089:	mov    QWORD PTR [rsp+0x48],rdi
  1ee08e:	mov    QWORD PTR [rsp+0x18],r14
  1ee093:	mov    r14,r12
  1ee096:	jmp    1ee0cd <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6bd>
  1ee098:	mov    BYTE PTR [rsp+0x20],r13b
  1ee09d:	mov    r13d,r8d
  1ee0a0:	mov    QWORD PTR [rsp+0x10],rcx
  1ee0a5:	mov    QWORD PTR [rsp+0x58],rdx
  1ee0aa:	mov    rcx,QWORD PTR [rsp+0x30]
  1ee0af:	mov    QWORD PTR [rsp+0x48],rcx
  1ee0b4:	mov    rdx,rax
  1ee0b7:	mov    rcx,rsi
  1ee0ba:	mov    QWORD PTR [rsp+0x30],rdi
  1ee0bf:	mov    QWORD PTR [rsp+0x18],rbp
  1ee0c4:	mov    rbp,r14
  1ee0c7:	mov    r14,r15
  1ee0ca:	mov    r15,r12
  1ee0cd:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1ee0d5:	mov    QWORD PTR [rsp+0x28],rdx
  1ee0da:	mov    QWORD PTR [rsp+0x50],rcx
  1ee0df:	cmp    rcx,0x1
  1ee0e3:	jne    1ee110 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  1ee0e5:	cmp    rbp,0x1
  1ee0e9:	jne    1ee110 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x700>
  1ee0eb:	lea    r8,[rip+0x34d176]        # 53b268 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x3e0>
  1ee0f2:	lea    rdi,[rsp+0x90]
  1ee0fa:	mov    rsi,r15
  1ee0fd:	mov    rdx,r14
  1ee100:	mov    r12,QWORD PTR [rsp+0x40]
  1ee105:	mov    rcx,r12
  1ee108:	call   QWORD PTR [rip+0x35c392]        # 54a4a0 <_DYNAMIC+0x6c8>
  1ee10e:	jmp    1ee133 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x723>
  1ee110:	lea    r8,[rip+0x34d169]        # 53b280 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x3f8>
  1ee117:	lea    rdi,[rsp+0x90]
  1ee11f:	mov    rsi,r15
  1ee122:	mov    rdx,r14
  1ee125:	mov    r12,QWORD PTR [rsp+0x40]
  1ee12a:	mov    rcx,r12
  1ee12d:	call   QWORD PTR [rip+0x35c375]        # 54a4a8 <_DYNAMIC+0x6d0>
  1ee133:	lea    rdi,[rsp+0x98]
  1ee13b:	mov    rsi,QWORD PTR [rsp+0xb8]
  1ee143:	mov    rdx,QWORD PTR [rsp+0xc0]
  1ee14b:	movups xmm0,XMMWORD PTR [rsp+0xc8]
  1ee153:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1ee15b:	movaps xmm3,xmm2
  1ee15e:	unpckhpd xmm3,xmm2
  1ee162:	sub    rsp,0x70
  1ee166:	movups XMMWORD PTR [rsp+0x58],xmm0
  1ee16b:	movzx  eax,BYTE PTR [rsp+0x90]
  1ee173:	mov    DWORD PTR [rsp+0x50],eax
  1ee177:	movzx  eax,r13b
  1ee17b:	mov    DWORD PTR [rsp+0x48],eax
  1ee17f:	mov    rax,QWORD PTR [rsp+0x80]
  1ee187:	mov    QWORD PTR [rsp+0x40],rax
  1ee18c:	mov    rax,QWORD PTR [rsp+0xc8]
  1ee194:	mov    QWORD PTR [rsp+0x38],rax
  1ee199:	mov    rax,QWORD PTR [rsp+0xb8]
  1ee1a1:	mov    QWORD PTR [rsp+0x30],rax
  1ee1a6:	mov    rax,QWORD PTR [rsp+0x98]
  1ee1ae:	mov    QWORD PTR [rsp+0x28],rax
  1ee1b3:	mov    rax,QWORD PTR [rsp+0xc0]
  1ee1bb:	mov    QWORD PTR [rsp+0x20],rax
  1ee1c0:	mov    rax,QWORD PTR [rsp+0xa0]
  1ee1c8:	mov    QWORD PTR [rsp+0x18],rax
  1ee1cd:	mov    rax,QWORD PTR [rsp+0x88]
  1ee1d5:	mov    QWORD PTR [rsp+0x10],rax
  1ee1da:	mov    QWORD PTR [rsp+0x8],rbp
  1ee1df:	mov    QWORD PTR [rsp],rbx
  1ee1e3:	xorps  xmm1,xmm1
  1ee1e6:	mov    r8,r14
  1ee1e9:	mov    r9,r12
  1ee1ec:	mov    rcx,r15
  1ee1ef:	movsd  xmm0,QWORD PTR [rsp+0xa8]
  1ee1f8:	call   QWORD PTR [rsp+0x100]
  1ee1ff:	add    rsp,0x70
  1ee203:	jmp    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1ee208:	lea    rax,[r12-0x1]
  1ee20d:	mov    ecx,r12d
  1ee210:	and    ecx,0x3
  1ee213:	and    r12,0xfffffffffffffffc
  1ee217:	mov    rdx,r14
  1ee21a:	shl    rdx,0x4
  1ee21e:	lea    rsi,[rdx+rdx*2]
  1ee222:	shl    rbp,0x4
  1ee226:	mov    rdi,r14
  1ee229:	shl    rdi,0x6
  1ee22d:	shl    r14,0x5
  1ee231:	xor    r8d,r8d
  1ee234:	xorps  xmm0,xmm0
  1ee237:	jmp    1ee24f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x83f>
  1ee239:	nop    DWORD PTR [rax+0x0]
  1ee240:	inc    r8
  1ee243:	add    rbx,rbp
  1ee246:	cmp    r8,r15
  1ee249:	je     1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1ee24f:	cmp    rax,0x3
  1ee253:	jae    1ee260 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x850>
  1ee255:	xor    r9d,r9d
  1ee258:	jmp    1ee294 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x884>
  1ee25a:	nop    WORD PTR [rax+rax*1+0x0]
  1ee260:	mov    r10,rbx
  1ee263:	xor    r9d,r9d
  1ee266:	cs nop WORD PTR [rax+rax*1+0x0]
  1ee270:	movups XMMWORD PTR [r10],xmm0
  1ee274:	movups XMMWORD PTR [r10+rdx*1],xmm0
  1ee279:	movups XMMWORD PTR [r10+r14*1],xmm0
  1ee27e:	add    r9,0x4
  1ee282:	movups XMMWORD PTR [r10+rsi*1],xmm0
  1ee287:	add    r10,rdi
  1ee28a:	cmp    r12,r9
  1ee28d:	jne    1ee270 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x860>
  1ee28f:	test   rcx,rcx
  1ee292:	je     1ee240 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1ee294:	imul   r9,rdx
  1ee298:	add    r9,rbx
  1ee29b:	mov    r10,rcx
  1ee29e:	xchg   ax,ax
  1ee2a0:	movups XMMWORD PTR [r9],xmm0
  1ee2a4:	add    r9,rdx
  1ee2a7:	dec    r10
  1ee2aa:	jne    1ee2a0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x890>
  1ee2ac:	jmp    1ee240 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1ee2ae:	mov    rax,r12
  1ee2b1:	jmp    1ee423 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa13>
  1ee2b6:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5180a]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1ee2be:	xor    r13d,r13d
  1ee2c1:	cmp    QWORD PTR [rsp+0x168],0x0
  1ee2ca:	setne  al
  1ee2cd:	cmp    rbp,r14
  1ee2d0:	jge    1ee2f5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8e5>
  1ee2d2:	mov    ecx,DWORD PTR [rsp+0x20]
  1ee2d6:	mov    BYTE PTR [rsp+0xf],cl
  1ee2da:	mov    r11,QWORD PTR [rsp+0x50]
  1ee2df:	mov    rdx,QWORD PTR [rsp+0x28]
  1ee2e4:	mov    r10,QWORD PTR [rsp+0x30]
  1ee2e9:	mov    QWORD PTR [rsp+0x10],r14
  1ee2ee:	mov    QWORD PTR [rsp+0x48],r15
  1ee2f3:	jmp    1ee32e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x91e>
  1ee2f5:	mov    BYTE PTR [rsp+0xf],r8b
  1ee2fa:	mov    r11,rsi
  1ee2fd:	mov    rdx,QWORD PTR [rsp+0x58]
  1ee302:	mov    r10,rdi
  1ee305:	mov    QWORD PTR [rsp+0x10],rbp
  1ee30a:	mov    QWORD PTR [rsp+0x48],r12
  1ee30f:	mov    r8d,DWORD PTR [rsp+0x20]
  1ee314:	mov    rsi,QWORD PTR [rsp+0x50]
  1ee319:	mov    rcx,QWORD PTR [rsp+0x28]
  1ee31e:	mov    QWORD PTR [rsp+0x58],rcx
  1ee323:	mov    rdi,QWORD PTR [rsp+0x30]
  1ee328:	mov    rbp,r14
  1ee32b:	mov    r12,r15
  1ee32e:	test   rbp,rbp
  1ee331:	js     1ee4c1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab1>
  1ee337:	cmp    QWORD PTR [rsp+0x10],0x0
  1ee33d:	js     1ee4e3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad3>
  1ee343:	mov    r13b,al
  1ee346:	test   rdx,rdx
  1ee349:	mov    QWORD PTR [rsp+0x30],r13
  1ee34e:	js     1ee507 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaf7>
  1ee354:	mov    QWORD PTR [rsp+0x28],r11
  1ee359:	mov    QWORD PTR [rsp+0x20],r10
  1ee35e:	mov    QWORD PTR [rsp+0x50],rdx
  1ee363:	mov    QWORD PTR [rsp+0x18],rdi
  1ee368:	mov    r13,rsi
  1ee36b:	mov    r15,QWORD PTR [rsp+0x40]
  1ee370:	mov    rax,QWORD PTR [rip+0x35c139]        # 54a4b0 <_DYNAMIC+0x6d8>
  1ee377:	mov    rax,QWORD PTR [rax]
  1ee37a:	test   rax,rax
  1ee37d:	jne    1ee3b2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9a2>
  1ee37f:	mov    r14d,r8d
  1ee382:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1ee38a:	movsd  QWORD PTR [rsp+0x120],xmm0
  1ee393:	call   QWORD PTR [rip+0x35c11f]        # 54a4b8 <_DYNAMIC+0x6e0>
  1ee399:	movsd  xmm0,QWORD PTR [rsp+0x120]
  1ee3a2:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1ee3aa:	mov    r9d,DWORD PTR [rsp+0x38]
  1ee3af:	mov    r8d,r14d
  1ee3b2:	movaps xmm3,xmm2
  1ee3b5:	unpckhpd xmm3,xmm2
  1ee3b9:	movzx  r11d,r8b
  1ee3bd:	movzx  r14d,BYTE PTR [rsp+0xf]
  1ee3c3:	movzx  r10d,r9b
  1ee3c7:	xorps  xmm1,xmm1
  1ee3ca:	mov    rdi,QWORD PTR [rsp+0x48]
  1ee3cf:	mov    rsi,r12
  1ee3d2:	mov    rdx,r15
  1ee3d5:	mov    rcx,rbx
  1ee3d8:	mov    r8,QWORD PTR [rsp+0x10]
  1ee3dd:	mov    r9,rbp
  1ee3e0:	push   QWORD PTR [rsp+0x168]
  1ee3e7:	push   QWORD PTR [rsp+0x38]
  1ee3eb:	push   r11
  1ee3ed:	push   r14
  1ee3ef:	push   0x0
  1ee3f1:	push   QWORD PTR [rsp+0x80]
  1ee3f8:	push   r13
  1ee3fa:	push   QWORD PTR [rsp+0x50]
  1ee3fe:	push   QWORD PTR [rsp+0x68]
  1ee402:	push   QWORD PTR [rsp+0x98]
  1ee409:	push   QWORD PTR [rsp+0x70]
  1ee40d:	push   r10
  1ee40f:	call   rax
  1ee411:	add    rsp,0x60
  1ee415:	jmp    1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1ee41a:	mov    rax,r15
  1ee41d:	mov    r15,r12
  1ee420:	mov    rbp,r14
  1ee423:	mov    ecx,0x1
  1ee428:	sub    rcx,rax
  1ee42b:	shl    rcx,0x4
  1ee42f:	add    rbx,rcx
  1ee432:	lea    rcx,[rax-0x1]
  1ee436:	mov    edx,eax
  1ee438:	and    edx,0x3
  1ee43b:	and    rax,0xfffffffffffffffc
  1ee43f:	xor    esi,esi
  1ee441:	xorps  xmm0,xmm0
  1ee444:	jmp    1ee45c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa4c>
  1ee446:	cs nop WORD PTR [rax+rax*1+0x0]
  1ee450:	inc    rsi
  1ee453:	cmp    rsi,r15
  1ee456:	je     1ee74b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd3b>
  1ee45c:	mov    rdi,rsi
  1ee45f:	imul   rdi,rbp
  1ee463:	shl    rdi,0x4
  1ee467:	add    rdi,rbx
  1ee46a:	cmp    rcx,0x3
  1ee46e:	jb     1ee4a1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  1ee470:	xor    r8d,r8d
  1ee473:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1ee480:	movups XMMWORD PTR [rdi],xmm0
  1ee483:	movups XMMWORD PTR [rdi+0x10],xmm0
  1ee487:	movups XMMWORD PTR [rdi+0x20],xmm0
  1ee48b:	movups XMMWORD PTR [rdi+0x30],xmm0
  1ee48f:	add    rdi,0x40
  1ee493:	add    r8,0x4
  1ee497:	cmp    rax,r8
  1ee49a:	jne    1ee480 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa70>
  1ee49c:	test   rdx,rdx
  1ee49f:	je     1ee450 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  1ee4a1:	xor    r8d,r8d
  1ee4a4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1ee4b0:	movups XMMWORD PTR [rdi],xmm0
  1ee4b3:	add    rdi,0x10
  1ee4b7:	inc    r8
  1ee4ba:	cmp    rdx,r8
  1ee4bd:	jne    1ee4b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xaa0>
  1ee4bf:	jmp    1ee450 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa40>
  1ee4c1:	mov    rcx,QWORD PTR [rsp+0x48]
  1ee4c6:	dec    rcx
  1ee4c9:	imul   rcx,r11
  1ee4cd:	shl    rcx,0x4
  1ee4d1:	add    r10,rcx
  1ee4d4:	neg    r11
  1ee4d7:	cmp    QWORD PTR [rsp+0x10],0x0
  1ee4dd:	jns    1ee343 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x933>
  1ee4e3:	lea    rcx,[r12-0x1]
  1ee4e8:	imul   rcx,rsi
  1ee4ec:	shl    rcx,0x4
  1ee4f0:	add    rdi,rcx
  1ee4f3:	neg    rsi
  1ee4f6:	mov    r13b,al
  1ee4f9:	test   rdx,rdx
  1ee4fc:	mov    QWORD PTR [rsp+0x30],r13
  1ee501:	jns    1ee354 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  1ee507:	mov    rax,QWORD PTR [rsp+0x40]
  1ee50c:	dec    rax
  1ee50f:	mov    rcx,rdx
  1ee512:	imul   rcx,rax
  1ee516:	shl    rcx,0x4
  1ee51a:	add    r10,rcx
  1ee51d:	neg    rdx
  1ee520:	mov    rcx,QWORD PTR [rsp+0x58]
  1ee525:	imul   rax,rcx
  1ee529:	shl    rax,0x4
  1ee52d:	add    rdi,rax
  1ee530:	neg    rcx
  1ee533:	mov    QWORD PTR [rsp+0x58],rcx
  1ee538:	jmp    1ee354 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x944>
  1ee53d:	mov    rax,0xffffffffffffffff
  1ee544:	jmp    1edfb8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5a8>
  1ee549:	mov    QWORD PTR [rsp+0x48],rsi
  1ee54e:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1ee556:	mov    BYTE PTR [rsp+0xf],r10b
  1ee55b:	call   QWORD PTR [rip+0x35bdbf]        # 54a320 <_DYNAMIC+0x548>
  1ee561:	mov    rdx,QWORD PTR [rip+0x35bdb0]        # 54a318 <_DYNAMIC+0x540>
  1ee568:	movzx  r10d,BYTE PTR [rsp+0xf]
  1ee56e:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1ee576:	mov    rsi,QWORD PTR [rsp+0x48]
  1ee57b:	mov    r9d,DWORD PTR [rsp+0x38]
  1ee580:	mov    r8d,DWORD PTR [rsp+0x10]
  1ee585:	mov    rdi,QWORD PTR [rsp+0x18]
  1ee58a:	mov    cl,0x1
  1ee58c:	test   eax,0x80000
  1ee591:	je     1edffe <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ee>
  1ee597:	jmp    1ee632 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc22>
  1ee59c:	mov    QWORD PTR [rsp+0x48],rsi
  1ee5a1:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1ee5a9:	mov    BYTE PTR [rsp+0xf],r10b
  1ee5ae:	call   QWORD PTR [rip+0x35bd6c]        # 54a320 <_DYNAMIC+0x548>
  1ee5b4:	mov    rdx,QWORD PTR [rip+0x35bd5d]        # 54a318 <_DYNAMIC+0x540>
  1ee5bb:	movzx  r10d,BYTE PTR [rsp+0xf]
  1ee5c1:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1ee5c9:	mov    rsi,QWORD PTR [rsp+0x48]
  1ee5ce:	mov    r9d,DWORD PTR [rsp+0x38]
  1ee5d3:	mov    r8d,DWORD PTR [rsp+0x10]
  1ee5d8:	mov    rdi,QWORD PTR [rsp+0x18]
  1ee5dd:	test   ax,ax
  1ee5e0:	js     1ee00f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ff>
  1ee5e6:	jmp    1ee026 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1ee5eb:	mov    QWORD PTR [rsp+0x48],rsi
  1ee5f0:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1ee5f8:	mov    BYTE PTR [rsp+0xf],r10b
  1ee5fd:	call   QWORD PTR [rip+0x35bd1d]        # 54a320 <_DYNAMIC+0x548>
  1ee603:	movzx  r10d,BYTE PTR [rsp+0xf]
  1ee609:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1ee611:	mov    rsi,QWORD PTR [rsp+0x48]
  1ee616:	mov    r9d,DWORD PTR [rsp+0x38]
  1ee61b:	mov    r8d,DWORD PTR [rsp+0x10]
  1ee620:	mov    rdi,QWORD PTR [rsp+0x18]
  1ee625:	bt     rax,0x37
  1ee62a:	jae    1ee026 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x616>
  1ee630:	xor    ecx,ecx
  1ee632:	test   r10b,r10b
  1ee635:	jne    1ee75d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd4d>
  1ee63b:	mov    r10,rsi
  1ee63e:	mov    rax,r13
  1ee641:	mul    QWORD PTR [rsp+0x40]
  1ee646:	jo     1ee775 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  1ee64c:	mov    rdx,rax
  1ee64f:	shr    rdx,0x3d
  1ee653:	jne    1ee775 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd65>
  1ee659:	shl    rax,0x3
  1ee65d:	mov    rdx,QWORD PTR [rip+0x35bdac]        # 54a410 <_DYNAMIC+0x638>
  1ee664:	mov    rsi,QWORD PTR [rdx]
  1ee667:	add    rsi,rsi
  1ee66a:	mov    edx,0x1
  1ee66f:	cmp    rax,rsi
  1ee672:	jb     1ee684 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc74>
  1ee674:	mov    rdx,QWORD PTR [rsp+0x168]
  1ee67c:	cmp    rdx,0x1
  1ee680:	adc    rdx,0x0
  1ee684:	sub    rsp,0xa0
  1ee68b:	mov    QWORD PTR [rsp+0x90],rdx
  1ee693:	lea    rax,[rsp+0x100]
  1ee69b:	mov    QWORD PTR [rsp+0x88],rax
  1ee6a3:	movzx  eax,BYTE PTR [rsp+0xc0]
  1ee6ab:	mov    DWORD PTR [rsp+0x80],eax
  1ee6b2:	mov    rax,QWORD PTR [rsp+0xf0]
  1ee6ba:	mov    QWORD PTR [rsp+0x78],rax
  1ee6bf:	mov    rax,QWORD PTR [rsp+0xc8]
  1ee6c7:	mov    QWORD PTR [rsp+0x70],rax
  1ee6cc:	mov    rax,QWORD PTR [rsp+0xd0]
  1ee6d4:	mov    QWORD PTR [rsp+0x68],rax
  1ee6d9:	xorps  xmm0,xmm0
  1ee6dc:	movups XMMWORD PTR [rsp+0x58],xmm0
  1ee6e1:	movzx  eax,r8b
  1ee6e5:	mov    DWORD PTR [rsp+0x50],eax
  1ee6e9:	mov    rax,QWORD PTR [rsp+0xf8]
  1ee6f1:	mov    QWORD PTR [rsp+0x48],rax
  1ee6f6:	mov    QWORD PTR [rsp+0x40],r10
  1ee6fb:	mov    QWORD PTR [rsp+0x38],rdi
  1ee700:	movzx  eax,r9b
  1ee704:	mov    DWORD PTR [rsp+0x30],eax
  1ee708:	movups XMMWORD PTR [rsp+0x18],xmm0
  1ee70d:	mov    QWORD PTR [rsp+0x10],rbp
  1ee712:	mov    QWORD PTR [rsp+0x8],r14
  1ee717:	mov    QWORD PTR [rsp],rbx
  1ee71b:	mov    DWORD PTR [rsp+0x28],0x2
  1ee723:	movzx  edx,cl
  1ee726:	mov    r8,r15
  1ee729:	mov    edi,0x3
  1ee72e:	mov    r9,QWORD PTR [rsp+0xe0]
  1ee736:	mov    esi,0x1
  1ee73b:	mov    rcx,r12
  1ee73e:	call   QWORD PTR [rip+0x35bbe4]        # 54a328 <_DYNAMIC+0x550>
  1ee744:	add    rsp,0xa0
  1ee74b:	add    rsp,0x128
  1ee752:	pop    rbx
  1ee753:	pop    r12
  1ee755:	pop    r13
  1ee757:	pop    r14
  1ee759:	pop    r15
  1ee75b:	pop    rbp
  1ee75c:	ret
  1ee75d:	mov    r13,0xffffffffffffffff
  1ee764:	mov    r10,rsi
  1ee767:	mov    rax,r13
  1ee76a:	mul    QWORD PTR [rsp+0x40]
  1ee76f:	jno    1ee64c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc3c>
  1ee775:	mov    rax,QWORD PTR [rip+0x35bc94]        # 54a410 <_DYNAMIC+0x638>
  1ee77c:	mov    rax,QWORD PTR [rax]
  1ee77f:	jmp    1ee674 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xc64>
