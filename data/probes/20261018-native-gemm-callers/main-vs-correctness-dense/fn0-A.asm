
target/faer-rev/7364be5ce22d-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001e2a80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>:
  1e2a80:	push   rbp
  1e2a81:	push   r15
  1e2a83:	push   r14
  1e2a85:	push   r13
  1e2a87:	push   r12
  1e2a89:	push   rbx
  1e2a8a:	sub    rsp,0x128
  1e2a91:	mov    r12,QWORD PTR [rdi+0x8]
  1e2a95:	test   r12,r12
  1e2a98:	je     1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2a9e:	mov    r15,QWORD PTR [rdi+0x10]
  1e2aa2:	test   r15,r15
  1e2aa5:	je     1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2aab:	mov    rbx,QWORD PTR [rdi]
  1e2aae:	mov    r14,QWORD PTR [rdi+0x18]
  1e2ab2:	mov    rbp,QWORD PTR [rdi+0x20]
  1e2ab6:	mov    rax,QWORD PTR [rdx+0x10]
  1e2aba:	mov    QWORD PTR [rsp+0x38],rax
  1e2abf:	test   rax,rax
  1e2ac2:	je     1e2b74 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xf4>
  1e2ac8:	mov    DWORD PTR [rsp+0x28],r9d
  1e2acd:	mov    DWORD PTR [rsp+0x20],esi
  1e2ad1:	mov    DWORD PTR [rsp+0x10],ecx
  1e2ad5:	mov    r10,QWORD PTR [rdx]
  1e2ad8:	mov    rcx,QWORD PTR [rdx+0x8]
  1e2adc:	mov    r9,QWORD PTR [rdx+0x18]
  1e2ae0:	test   r14,r14
  1e2ae3:	jns    1e2b1d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9d>
  1e2ae5:	lea    rax,[r12-0x1]
  1e2aea:	imul   rax,r14
  1e2aee:	shl    rax,0x4
  1e2af2:	add    rbx,rax
  1e2af5:	neg    r14
  1e2af8:	xor    eax,eax
  1e2afa:	mov    rsi,rcx
  1e2afd:	sub    rsi,0x1
  1e2b01:	cmovb  rsi,rax
  1e2b05:	mov    rdi,r9
  1e2b08:	imul   rdi,rsi
  1e2b0c:	cmp    rsi,rcx
  1e2b0f:	cmove  rdi,rax
  1e2b13:	shl    rdi,0x4
  1e2b17:	add    r10,rdi
  1e2b1a:	neg    r9
  1e2b1d:	mov    QWORD PTR [rsp+0x30],r9
  1e2b22:	mov    rsi,QWORD PTR [rdx+0x20]
  1e2b26:	mov    rdi,QWORD PTR [r8]
  1e2b29:	mov    r9,QWORD PTR [r8+0x8]
  1e2b2d:	mov    rax,QWORD PTR [r8+0x10]
  1e2b31:	mov    QWORD PTR [rsp+0x18],rax
  1e2b36:	mov    rax,QWORD PTR [r8+0x20]
  1e2b3a:	test   rbp,rbp
  1e2b3d:	js     1e2bc3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x143>
  1e2b43:	mov    r8,QWORD PTR [r8+0x18]
  1e2b47:	test   rsi,rsi
  1e2b4a:	js     1e2c31 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x1b1>
  1e2b50:	mov    QWORD PTR [rsp+0x8],r10
  1e2b55:	mov    r10,QWORD PTR [rsp+0x168]
  1e2b5d:	mov    r11,QWORD PTR [rsp+0x160]
  1e2b65:	cmp    r15,0x1
  1e2b69:	je     1e2cbc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x23c>
  1e2b6f:	jmp    1e2dab <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1e2b74:	test   sil,sil
  1e2b77:	jne    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2b7d:	cmp    r12,0x1
  1e2b81:	je     1e2b97 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x117>
  1e2b83:	cmp    r14,0xffffffffffffffff
  1e2b87:	je     1e32fe <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x87e>
  1e2b8d:	cmp    r14,0x1
  1e2b91:	je     1e3092 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x612>
  1e2b97:	cmp    r15,0x1
  1e2b9b:	je     1e3088 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  1e2ba1:	cmp    rbp,0xffffffffffffffff
  1e2ba5:	je     1e3467 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9e7>
  1e2bab:	cmp    rbp,0x1
  1e2baf:	jne    1e3088 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x608>
  1e2bb5:	mov    rax,r15
  1e2bb8:	mov    r15,r12
  1e2bbb:	mov    rbp,r14
  1e2bbe:	jmp    1e347f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  1e2bc3:	lea    rdx,[r15-0x1]
  1e2bc7:	imul   rdx,rbp
  1e2bcb:	shl    rdx,0x4
  1e2bcf:	add    rbx,rdx
  1e2bd2:	neg    rbp
  1e2bd5:	xor    r13d,r13d
  1e2bd8:	mov    r11,rsi
  1e2bdb:	mov    rsi,QWORD PTR [rsp+0x18]
  1e2be0:	sub    rsi,0x1
  1e2be4:	cmovb  rsi,r13
  1e2be8:	mov    rdx,rcx
  1e2beb:	mov    rcx,r10
  1e2bee:	mov    r10,rax
  1e2bf1:	mov    rax,rdi
  1e2bf4:	mov    rdi,r10
  1e2bf7:	imul   rdi,rsi
  1e2bfb:	cmp    rsi,QWORD PTR [rsp+0x18]
  1e2c00:	mov    rsi,r11
  1e2c03:	cmove  rdi,r13
  1e2c07:	test   r9,r9
  1e2c0a:	cmove  rdi,r9
  1e2c0e:	shl    rdi,0x4
  1e2c12:	add    rax,rdi
  1e2c15:	mov    rdi,rax
  1e2c18:	mov    rax,r10
  1e2c1b:	mov    r10,rcx
  1e2c1e:	mov    rcx,rdx
  1e2c21:	neg    rax
  1e2c24:	mov    r8,QWORD PTR [r8+0x18]
  1e2c28:	test   rsi,rsi
  1e2c2b:	jns    1e2b50 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xd0>
  1e2c31:	mov    rdx,QWORD PTR [rsp+0x38]
  1e2c36:	dec    rdx
  1e2c39:	imul   rdx,rsi
  1e2c3d:	test   rcx,rcx
  1e2c40:	cmove  rdx,rcx
  1e2c44:	shl    rdx,0x4
  1e2c48:	add    r10,rdx
  1e2c4b:	mov    QWORD PTR [rsp+0x8],r10
  1e2c50:	neg    rsi
  1e2c53:	xor    edx,edx
  1e2c55:	mov    r10,r8
  1e2c58:	mov    r8,rsi
  1e2c5b:	mov    rsi,r9
  1e2c5e:	sub    rsi,0x1
  1e2c62:	cmovb  rsi,rdx
  1e2c66:	mov    r11,rcx
  1e2c69:	mov    rcx,rax
  1e2c6c:	mov    rax,rdi
  1e2c6f:	mov    rdi,r10
  1e2c72:	imul   rdi,rsi
  1e2c76:	mov    r13,QWORD PTR [rsp+0x18]
  1e2c7b:	test   r13,r13
  1e2c7e:	cmove  rdi,r13
  1e2c82:	cmp    rsi,r9
  1e2c85:	mov    rsi,r8
  1e2c88:	mov    r8,r10
  1e2c8b:	cmove  rdi,rdx
  1e2c8f:	shl    rdi,0x4
  1e2c93:	add    rax,rdi
  1e2c96:	mov    rdi,rax
  1e2c99:	mov    rax,rcx
  1e2c9c:	mov    rcx,r11
  1e2c9f:	neg    r8
  1e2ca2:	mov    r10,QWORD PTR [rsp+0x168]
  1e2caa:	mov    r11,QWORD PTR [rsp+0x160]
  1e2cb2:	cmp    r15,0x1
  1e2cb6:	jne    1e2dab <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1e2cbc:	cmp    QWORD PTR [rsp+0x30],0x1
  1e2cc2:	jne    1e2d34 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1e2cc4:	cmp    r14,0x1
  1e2cc8:	jne    1e2d34 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1e2cca:	test   rbx,rbx
  1e2ccd:	je     1e2d34 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x2b4>
  1e2ccf:	mov    rax,QWORD PTR [rsp+0x8]
  1e2cd4:	mov    QWORD PTR [rsp+0x98],rax
  1e2cdc:	mov    QWORD PTR [rsp+0xa0],rcx
  1e2ce4:	mov    rax,QWORD PTR [rsp+0x38]
  1e2ce9:	mov    QWORD PTR [rsp+0xa8],rax
  1e2cf1:	mov    QWORD PTR [rsp+0xb0],rsi
  1e2cf9:	mov    QWORD PTR [rsp+0x50],rdi
  1e2cfe:	mov    QWORD PTR [rsp+0x58],r9
  1e2d03:	mov    QWORD PTR [rsp+0x60],r8
  1e2d08:	sub    rsp,0x8
  1e2d0c:	movzx  eax,BYTE PTR [rsp+0x30]
  1e2d11:	movzx  edx,BYTE PTR [rsp+0x28]
  1e2d16:	movzx  r8d,BYTE PTR [rsp+0x18]
  1e2d1c:	lea    rcx,[rsp+0xa0]
  1e2d24:	lea    r9,[rsp+0x58]
  1e2d29:	mov    rdi,rbx
  1e2d2c:	mov    rsi,r12
  1e2d2f:	jmp    1e2e2f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3af>
  1e2d34:	cmp    rsi,0x1
  1e2d38:	jne    1e2dab <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1e2d3a:	cmp    r8,0x1
  1e2d3e:	jne    1e2dab <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1e2d40:	test   rdi,rdi
  1e2d43:	je     1e2dab <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x32b>
  1e2d45:	mov    rax,QWORD PTR [rsp+0x8]
  1e2d4a:	mov    QWORD PTR [rsp+0x98],rax
  1e2d52:	mov    QWORD PTR [rsp+0xa0],rcx
  1e2d5a:	mov    rax,QWORD PTR [rsp+0x38]
  1e2d5f:	mov    QWORD PTR [rsp+0xa8],rax
  1e2d67:	mov    rax,QWORD PTR [rsp+0x30]
  1e2d6c:	mov    QWORD PTR [rsp+0xb0],rax
  1e2d74:	mov    QWORD PTR [rsp+0x50],rbx
  1e2d79:	mov    QWORD PTR [rsp+0x58],r12
  1e2d7e:	mov    QWORD PTR [rsp+0x60],r14
  1e2d83:	sub    rsp,0x8
  1e2d87:	movzx  eax,BYTE PTR [rsp+0x30]
  1e2d8c:	movzx  esi,BYTE PTR [rsp+0x28]
  1e2d91:	movzx  ecx,BYTE PTR [rsp+0x18]
  1e2d96:	mov    r8,rdi
  1e2d99:	lea    rdi,[rsp+0x58]
  1e2d9e:	lea    rdx,[rsp+0xa0]
  1e2da6:	jmp    1e2eb7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x437>
  1e2dab:	cmp    r12,0x1
  1e2daf:	jne    1e2eca <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1e2db5:	xor    edx,edx
  1e2db7:	cmp    rbp,0x1
  1e2dbb:	cmove  rdx,rbx
  1e2dbf:	cmp    rax,0x1
  1e2dc3:	jne    1e2e42 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  1e2dc5:	test   rdx,rdx
  1e2dc8:	je     1e2e42 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x3c2>
  1e2dca:	mov    QWORD PTR [rsp+0x98],rdi
  1e2dd2:	mov    rax,QWORD PTR [rsp+0x18]
  1e2dd7:	mov    QWORD PTR [rsp+0xa0],rax
  1e2ddf:	mov    QWORD PTR [rsp+0xa8],r9
  1e2de7:	mov    QWORD PTR [rsp+0xb0],r8
  1e2def:	mov    rax,QWORD PTR [rsp+0x8]
  1e2df4:	mov    QWORD PTR [rsp+0x50],rax
  1e2df9:	mov    rax,QWORD PTR [rsp+0x38]
  1e2dfe:	mov    QWORD PTR [rsp+0x58],rax
  1e2e03:	mov    QWORD PTR [rsp+0x60],rsi
  1e2e08:	sub    rsp,0x8
  1e2e0c:	movzx  eax,BYTE PTR [rsp+0x18]
  1e2e11:	movzx  edx,BYTE PTR [rsp+0x28]
  1e2e16:	movzx  r8d,BYTE PTR [rsp+0x30]
  1e2e1c:	lea    rcx,[rsp+0xa0]
  1e2e24:	lea    r9,[rsp+0x58]
  1e2e29:	mov    rdi,rbx
  1e2e2c:	mov    rsi,r15
  1e2e2f:	push   r10
  1e2e31:	push   r11
  1e2e33:	push   rax
  1e2e34:	call   157350 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e2e39:	add    rsp,0x20
  1e2e3d:	jmp    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2e42:	xor    edx,edx
  1e2e44:	cmp    rsi,0x1
  1e2e48:	cmove  rdx,QWORD PTR [rsp+0x8]
  1e2e4e:	cmp    r8,0x1
  1e2e52:	jne    1e2eca <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1e2e54:	test   rdx,rdx
  1e2e57:	je     1e2eca <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x44a>
  1e2e59:	mov    QWORD PTR [rsp+0x98],rdi
  1e2e61:	mov    rcx,QWORD PTR [rsp+0x18]
  1e2e66:	mov    QWORD PTR [rsp+0xa0],rcx
  1e2e6e:	mov    QWORD PTR [rsp+0xa8],r9
  1e2e76:	mov    QWORD PTR [rsp+0xb0],rax
  1e2e7e:	mov    QWORD PTR [rsp+0x50],rbx
  1e2e83:	mov    QWORD PTR [rsp+0x58],r15
  1e2e88:	mov    QWORD PTR [rsp+0x60],rbp
  1e2e8d:	sub    rsp,0x8
  1e2e91:	movzx  eax,BYTE PTR [rsp+0x18]
  1e2e96:	movzx  esi,BYTE PTR [rsp+0x28]
  1e2e9b:	movzx  ecx,BYTE PTR [rsp+0x30]
  1e2ea0:	lea    rdi,[rsp+0x58]
  1e2ea5:	lea    rdx,[rsp+0xa0]
  1e2ead:	mov    r8,QWORD PTR [rsp+0x10]
  1e2eb2:	mov    r9,QWORD PTR [rsp+0x40]
  1e2eb7:	push   r10
  1e2eb9:	push   r11
  1e2ebb:	push   rax
  1e2ebc:	call   1f63d0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e2ec1:	add    rsp,0x20
  1e2ec5:	jmp    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2eca:	mov    QWORD PTR [rsp+0x48],r8
  1e2ecf:	cmp    QWORD PTR [rsp+0x38],0x1
  1e2ed5:	mov    r8,QWORD PTR [rsp+0x30]
  1e2eda:	jne    1e2fdf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1e2ee0:	xor    edx,edx
  1e2ee2:	cmp    r14,0x1
  1e2ee6:	cmove  rdx,rbx
  1e2eea:	cmp    r8,0x1
  1e2eee:	jne    1e2f56 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  1e2ef0:	test   rdx,rdx
  1e2ef3:	je     1e2f56 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x4d6>
  1e2ef5:	mov    QWORD PTR [rsp+0x98],rdx
  1e2efd:	mov    QWORD PTR [rsp+0xa0],r12
  1e2f05:	mov    QWORD PTR [rsp+0xa8],r15
  1e2f0d:	mov    QWORD PTR [rsp+0xb0],rbp
  1e2f15:	mov    QWORD PTR [rsp+0x50],rdi
  1e2f1a:	mov    rdx,QWORD PTR [rsp+0x18]
  1e2f1f:	mov    QWORD PTR [rsp+0x58],rdx
  1e2f24:	mov    QWORD PTR [rsp+0x60],rax
  1e2f29:	sub    rsp,0x8
  1e2f2d:	movzx  eax,BYTE PTR [rsp+0x30]
  1e2f32:	movzx  esi,BYTE PTR [rsp+0x28]
  1e2f37:	movzx  r8d,BYTE PTR [rsp+0x18]
  1e2f3d:	lea    rdi,[rsp+0xa0]
  1e2f45:	lea    r9,[rsp+0x58]
  1e2f4a:	mov    rdx,QWORD PTR [rsp+0x10]
  1e2f4f:	push   r10
  1e2f51:	push   r11
  1e2f53:	push   rax
  1e2f54:	jmp    1e2fd1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x551>
  1e2f56:	xor    edx,edx
  1e2f58:	cmp    rbp,0x1
  1e2f5c:	cmove  rdx,rbx
  1e2f60:	cmp    rax,0x1
  1e2f64:	jne    1e2fdf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1e2f66:	test   rdx,rdx
  1e2f69:	je     1e2fdf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x55f>
  1e2f6b:	mov    QWORD PTR [rsp+0x98],rdx
  1e2f73:	mov    QWORD PTR [rsp+0xa0],r15
  1e2f7b:	mov    QWORD PTR [rsp+0xa8],r12
  1e2f83:	mov    QWORD PTR [rsp+0xb0],r14
  1e2f8b:	mov    rax,QWORD PTR [rsp+0x8]
  1e2f90:	mov    QWORD PTR [rsp+0x50],rax
  1e2f95:	mov    QWORD PTR [rsp+0x58],rcx
  1e2f9a:	mov    QWORD PTR [rsp+0x60],r8
  1e2f9f:	sub    rsp,0x8
  1e2fa3:	mov    rax,r11
  1e2fa6:	movzx  r11d,BYTE PTR [rsp+0x18]
  1e2fac:	movzx  esi,BYTE PTR [rsp+0x28]
  1e2fb1:	movzx  r8d,BYTE PTR [rsp+0x30]
  1e2fb7:	mov    rdx,rdi
  1e2fba:	lea    rdi,[rsp+0xa0]
  1e2fc2:	lea    r9,[rsp+0x58]
  1e2fc7:	mov    rcx,QWORD PTR [rsp+0x20]
  1e2fcc:	push   r10
  1e2fce:	push   rax
  1e2fcf:	push   r11
  1e2fd1:	call   155d90 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updateINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench>
  1e2fd6:	add    rsp,0x20
  1e2fda:	jmp    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e2fdf:	mov    QWORD PTR [rsp+0x70],rax
  1e2fe4:	mov    QWORD PTR [rsp+0x18],rdi
  1e2fe9:	mov    QWORD PTR [rsp+0x40],rsi
  1e2fee:	movups xmm2,XMMWORD PTR [r11]
  1e2ff2:	movaps XMMWORD PTR [rsp+0x50],xmm2
  1e2ff7:	mov    rax,r12
  1e2ffa:	mul    r15
  1e2ffd:	mov    r13,rax
  1e3000:	jo     1e358e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb0e>
  1e3006:	mul    QWORD PTR [rsp+0x38]
  1e300b:	seto   cl
  1e300e:	not    cl
  1e3010:	cmp    rax,0x1001
  1e3016:	setb   al
  1e3019:	test   cl,al
  1e301b:	mov    esi,DWORD PTR [rsp+0x10]
  1e301f:	mov    edi,DWORD PTR [rsp+0x20]
  1e3023:	jne    1e307e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5fe>
  1e3025:	mov    rdx,QWORD PTR [rip+0x3672ec]        # 54a318 <_DYNAMIC+0x540>
  1e302c:	mov    rax,QWORD PTR [rdx]
  1e302f:	test   rax,rax
  1e3032:	je     1e359a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb1a>
  1e3038:	mov    cl,0x1
  1e303a:	test   eax,0x80000
  1e303f:	jne    1e363b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  1e3045:	mov    rax,QWORD PTR [rdx]
  1e3048:	test   rax,rax
  1e304b:	je     1e35d3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb53>
  1e3051:	test   ax,ax
  1e3054:	jns    1e306d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1e3056:	mov    rax,QWORD PTR [rdx]
  1e3059:	test   rax,rax
  1e305c:	je     1e360b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xb8b>
  1e3062:	bt     rax,0x37
  1e3067:	jb     1e3639 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbb9>
  1e306d:	test   dil,dil
  1e3070:	jne    1e3306 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x886>
  1e3076:	xorps  xmm0,xmm0
  1e3079:	jmp    1e330e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x88e>
  1e307e:	test   dil,dil
  1e3081:	jne    1e309a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x61a>
  1e3083:	xorps  xmm0,xmm0
  1e3086:	jmp    1e30a2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x622>
  1e3088:	cmp    r14,0x1
  1e308c:	jne    1e3257 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x7d7>
  1e3092:	mov    rax,r12
  1e3095:	jmp    1e347f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9ff>
  1e309a:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5ca26]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1e30a2:	movsd  QWORD PTR [rsp+0x20],xmm0
  1e30a8:	mov    rax,QWORD PTR [rsp+0x8]
  1e30ad:	mov    rdx,QWORD PTR [rsp+0x18]
  1e30b2:	cmp    rbp,r14
  1e30b5:	jae    1e30e2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x662>
  1e30b7:	mov    BYTE PTR [rsp+0x8],sil
  1e30bc:	mov    QWORD PTR [rsp+0x10],r8
  1e30c1:	mov    rcx,QWORD PTR [rsp+0x40]
  1e30c6:	mov    QWORD PTR [rsp+0x78],rcx
  1e30cb:	mov    QWORD PTR [rsp+0x90],rax
  1e30d3:	mov    QWORD PTR [rsp+0x30],r14
  1e30d8:	mov    r13,r12
  1e30db:	mov    r8,QWORD PTR [rsp+0x70]
  1e30e0:	jmp    1e3125 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6a5>
  1e30e2:	mov    ecx,DWORD PTR [rsp+0x28]
  1e30e6:	mov    BYTE PTR [rsp+0x8],cl
  1e30ea:	mov    DWORD PTR [rsp+0x28],esi
  1e30ee:	mov    rcx,QWORD PTR [rsp+0x70]
  1e30f3:	mov    QWORD PTR [rsp+0x10],rcx
  1e30f8:	mov    rcx,QWORD PTR [rsp+0x48]
  1e30fd:	mov    QWORD PTR [rsp+0x78],rcx
  1e3102:	mov    QWORD PTR [rsp+0x90],rdx
  1e310a:	mov    rcx,QWORD PTR [rsp+0x40]
  1e310f:	mov    QWORD PTR [rsp+0x48],rcx
  1e3114:	mov    rdx,rax
  1e3117:	mov    QWORD PTR [rsp+0x30],rbp
  1e311c:	mov    rbp,r14
  1e311f:	mov    r13,r15
  1e3122:	mov    r15,r12
  1e3125:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e312d:	mov    QWORD PTR [rsp+0x18],rdx
  1e3132:	mov    r12,r8
  1e3135:	cmp    r8,0x1
  1e3139:	jne    1e3166 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  1e313b:	cmp    rbp,0x1
  1e313f:	jne    1e3166 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x6e6>
  1e3141:	lea    r8,[rip+0x358120]        # 53b268 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x3e0>
  1e3148:	lea    rdi,[rsp+0x98]
  1e3150:	mov    rsi,r15
  1e3153:	mov    rdx,r13
  1e3156:	mov    r14,QWORD PTR [rsp+0x38]
  1e315b:	mov    rcx,r14
  1e315e:	call   QWORD PTR [rip+0x36733c]        # 54a4a0 <_DYNAMIC+0x6c8>
  1e3164:	jmp    1e3189 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x709>
  1e3166:	lea    r8,[rip+0x358113]        # 53b280 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x3f8>
  1e316d:	lea    rdi,[rsp+0x98]
  1e3175:	mov    rsi,r15
  1e3178:	mov    rdx,r13
  1e317b:	mov    r14,QWORD PTR [rsp+0x38]
  1e3180:	mov    rcx,r14
  1e3183:	call   QWORD PTR [rip+0x36731f]        # 54a4a8 <_DYNAMIC+0x6d0>
  1e3189:	lea    rdi,[rsp+0xa0]
  1e3191:	mov    rsi,QWORD PTR [rsp+0xc0]
  1e3199:	mov    rdx,QWORD PTR [rsp+0xc8]
  1e31a1:	movups xmm0,XMMWORD PTR [rsp+0xd0]
  1e31a9:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e31b1:	movaps xmm3,xmm2
  1e31b4:	unpckhpd xmm3,xmm2
  1e31b8:	sub    rsp,0x70
  1e31bc:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e31c1:	movzx  eax,BYTE PTR [rsp+0x78]
  1e31c6:	mov    DWORD PTR [rsp+0x50],eax
  1e31ca:	movzx  eax,BYTE PTR [rsp+0x98]
  1e31d2:	mov    DWORD PTR [rsp+0x48],eax
  1e31d6:	mov    rax,QWORD PTR [rsp+0x80]
  1e31de:	mov    QWORD PTR [rsp+0x40],rax
  1e31e3:	mov    rax,QWORD PTR [rsp+0xe8]
  1e31eb:	mov    QWORD PTR [rsp+0x38],rax
  1e31f0:	mov    rax,QWORD PTR [rsp+0x100]
  1e31f8:	mov    QWORD PTR [rsp+0x30],rax
  1e31fd:	mov    rax,QWORD PTR [rsp+0xb8]
  1e3205:	mov    QWORD PTR [rsp+0x28],rax
  1e320a:	mov    QWORD PTR [rsp+0x20],r12
  1e320f:	mov    rax,QWORD PTR [rsp+0x88]
  1e3217:	mov    QWORD PTR [rsp+0x18],rax
  1e321c:	mov    rax,QWORD PTR [rsp+0xa0]
  1e3224:	mov    QWORD PTR [rsp+0x10],rax
  1e3229:	mov    QWORD PTR [rsp+0x8],rbp
  1e322e:	mov    QWORD PTR [rsp],rbx
  1e3232:	xorps  xmm1,xmm1
  1e3235:	mov    r8,r13
  1e3238:	mov    r9,r14
  1e323b:	mov    rcx,r15
  1e323e:	movsd  xmm0,QWORD PTR [rsp+0x90]
  1e3247:	call   QWORD PTR [rsp+0x108]
  1e324e:	add    rsp,0x70
  1e3252:	jmp    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e3257:	lea    rax,[r12-0x1]
  1e325c:	mov    ecx,r12d
  1e325f:	and    ecx,0x3
  1e3262:	and    r12,0xfffffffffffffffc
  1e3266:	mov    rdx,r14
  1e3269:	shl    rdx,0x4
  1e326d:	lea    rsi,[rdx+rdx*2]
  1e3271:	shl    rbp,0x4
  1e3275:	mov    rdi,r14
  1e3278:	shl    rdi,0x6
  1e327c:	shl    r14,0x5
  1e3280:	xor    r8d,r8d
  1e3283:	xorps  xmm0,xmm0
  1e3286:	jmp    1e329f <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x81f>
  1e3288:	nop    DWORD PTR [rax+rax*1+0x0]
  1e3290:	inc    r8
  1e3293:	add    rbx,rbp
  1e3296:	cmp    r8,r15
  1e3299:	je     1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e329f:	cmp    rax,0x3
  1e32a3:	jae    1e32b0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x830>
  1e32a5:	xor    r9d,r9d
  1e32a8:	jmp    1e32e4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x864>
  1e32aa:	nop    WORD PTR [rax+rax*1+0x0]
  1e32b0:	mov    r10,rbx
  1e32b3:	xor    r9d,r9d
  1e32b6:	cs nop WORD PTR [rax+rax*1+0x0]
  1e32c0:	movups XMMWORD PTR [r10],xmm0
  1e32c4:	movups XMMWORD PTR [r10+rdx*1],xmm0
  1e32c9:	movups XMMWORD PTR [r10+r14*1],xmm0
  1e32ce:	add    r9,0x4
  1e32d2:	movups XMMWORD PTR [r10+rsi*1],xmm0
  1e32d7:	add    r10,rdi
  1e32da:	cmp    r12,r9
  1e32dd:	jne    1e32c0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x840>
  1e32df:	test   rcx,rcx
  1e32e2:	je     1e3290 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  1e32e4:	imul   r9,rdx
  1e32e8:	add    r9,rbx
  1e32eb:	mov    r10,rcx
  1e32ee:	xchg   ax,ax
  1e32f0:	movups XMMWORD PTR [r9],xmm0
  1e32f4:	add    r9,rdx
  1e32f7:	dec    r10
  1e32fa:	jne    1e32f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x870>
  1e32fc:	jmp    1e3290 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x810>
  1e32fe:	mov    rax,r12
  1e3301:	jmp    1e3470 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x9f0>
  1e3306:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5c7ba]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1e330e:	mov    rax,QWORD PTR [rsp+0x168]
  1e3316:	xor    r11d,r11d
  1e3319:	test   rax,rax
  1e331c:	setne  al
  1e331f:	cmp    rbp,r14
  1e3322:	jge    1e3345 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x8c5>
  1e3324:	mov    ecx,DWORD PTR [rsp+0x28]
  1e3328:	mov    BYTE PTR [rsp+0x78],cl
  1e332c:	mov    r10,QWORD PTR [rsp+0x70]
  1e3331:	mov    rdx,QWORD PTR [rsp+0x48]
  1e3336:	mov    r9,QWORD PTR [rsp+0x18]
  1e333b:	mov    r13,r14
  1e333e:	mov    QWORD PTR [rsp+0x10],r15
  1e3343:	jmp    1e3382 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x902>
  1e3345:	mov    BYTE PTR [rsp+0x78],sil
  1e334a:	mov    r10,r8
  1e334d:	mov    rdx,QWORD PTR [rsp+0x40]
  1e3352:	mov    r9,QWORD PTR [rsp+0x8]
  1e3357:	mov    r13,rbp
  1e335a:	mov    QWORD PTR [rsp+0x10],r12
  1e335f:	mov    esi,DWORD PTR [rsp+0x28]
  1e3363:	mov    r8,QWORD PTR [rsp+0x70]
  1e3368:	mov    rcx,QWORD PTR [rsp+0x48]
  1e336d:	mov    QWORD PTR [rsp+0x40],rcx
  1e3372:	mov    rcx,QWORD PTR [rsp+0x18]
  1e3377:	mov    QWORD PTR [rsp+0x8],rcx
  1e337c:	mov    rbp,r14
  1e337f:	mov    r12,r15
  1e3382:	test   rbp,rbp
  1e3385:	js     1e3511 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa91>
  1e338b:	test   r13,r13
  1e338e:	js     1e3530 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xab0>
  1e3394:	mov    r11b,al
  1e3397:	test   rdx,rdx
  1e339a:	mov    QWORD PTR [rsp+0x70],r13
  1e339f:	js     1e3556 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xad6>
  1e33a5:	mov    r13,r11
  1e33a8:	mov    QWORD PTR [rsp+0x48],r10
  1e33ad:	mov    QWORD PTR [rsp+0x28],r9
  1e33b2:	mov    QWORD PTR [rsp+0x18],rdx
  1e33b7:	mov    QWORD PTR [rsp+0x30],r8
  1e33bc:	mov    r15,QWORD PTR [rsp+0x38]
  1e33c1:	mov    rax,QWORD PTR [rip+0x3670e8]        # 54a4b0 <_DYNAMIC+0x6d8>
  1e33c8:	mov    rax,QWORD PTR [rax]
  1e33cb:	test   rax,rax
  1e33ce:	jne    1e3402 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x982>
  1e33d0:	mov    r14d,esi
  1e33d3:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e33db:	movsd  QWORD PTR [rsp+0x90],xmm0
  1e33e4:	call   QWORD PTR [rip+0x3670ce]        # 54a4b8 <_DYNAMIC+0x6e0>
  1e33ea:	movsd  xmm0,QWORD PTR [rsp+0x90]
  1e33f3:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e33fb:	mov    edi,DWORD PTR [rsp+0x20]
  1e33ff:	mov    esi,r14d
  1e3402:	movaps xmm3,xmm2
  1e3405:	unpckhpd xmm3,xmm2
  1e3409:	movzx  r11d,sil
  1e340d:	movzx  r14d,BYTE PTR [rsp+0x78]
  1e3413:	movzx  r10d,dil
  1e3417:	xorps  xmm1,xmm1
  1e341a:	mov    rdi,QWORD PTR [rsp+0x10]
  1e341f:	mov    rsi,r12
  1e3422:	mov    rdx,r15
  1e3425:	mov    rcx,rbx
  1e3428:	mov    r8,QWORD PTR [rsp+0x70]
  1e342d:	mov    r9,rbp
  1e3430:	push   QWORD PTR [rsp+0x168]
  1e3437:	push   r13
  1e3439:	push   r11
  1e343b:	push   r14
  1e343d:	push   0x0
  1e343f:	push   QWORD PTR [rsp+0x68]
  1e3443:	push   QWORD PTR [rsp+0x60]
  1e3447:	push   QWORD PTR [rsp+0x40]
  1e344b:	push   QWORD PTR [rsp+0x88]
  1e3452:	push   QWORD PTR [rsp+0x60]
  1e3456:	push   QWORD PTR [rsp+0x78]
  1e345a:	push   r10
  1e345c:	call   rax
  1e345e:	add    rsp,0x60
  1e3462:	jmp    1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e3467:	mov    rax,r15
  1e346a:	mov    r15,r12
  1e346d:	mov    rbp,r14
  1e3470:	mov    ecx,0x1
  1e3475:	sub    rcx,rax
  1e3478:	shl    rcx,0x4
  1e347c:	add    rbx,rcx
  1e347f:	lea    rcx,[rax-0x1]
  1e3483:	mov    edx,eax
  1e3485:	and    edx,0x3
  1e3488:	and    rax,0xfffffffffffffffc
  1e348c:	xor    esi,esi
  1e348e:	xorps  xmm0,xmm0
  1e3491:	jmp    1e34ac <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa2c>
  1e3493:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e34a0:	inc    rsi
  1e34a3:	cmp    rsi,r15
  1e34a6:	je     1e372b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xcab>
  1e34ac:	mov    rdi,rsi
  1e34af:	imul   rdi,rbp
  1e34b3:	shl    rdi,0x4
  1e34b7:	add    rdi,rbx
  1e34ba:	cmp    rcx,0x3
  1e34be:	jb     1e34f1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa71>
  1e34c0:	xor    r8d,r8d
  1e34c3:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e34d0:	movups XMMWORD PTR [rdi],xmm0
  1e34d3:	movups XMMWORD PTR [rdi+0x10],xmm0
  1e34d7:	movups XMMWORD PTR [rdi+0x20],xmm0
  1e34db:	movups XMMWORD PTR [rdi+0x30],xmm0
  1e34df:	add    rdi,0x40
  1e34e3:	add    r8,0x4
  1e34e7:	cmp    rax,r8
  1e34ea:	jne    1e34d0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa50>
  1e34ec:	test   rdx,rdx
  1e34ef:	je     1e34a0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  1e34f1:	xor    r8d,r8d
  1e34f4:	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e3500:	movups XMMWORD PTR [rdi],xmm0
  1e3503:	add    rdi,0x10
  1e3507:	inc    r8
  1e350a:	cmp    rdx,r8
  1e350d:	jne    1e3500 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa80>
  1e350f:	jmp    1e34a0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xa20>
  1e3511:	mov    rcx,QWORD PTR [rsp+0x10]
  1e3516:	dec    rcx
  1e3519:	imul   rcx,r10
  1e351d:	shl    rcx,0x4
  1e3521:	add    r9,rcx
  1e3524:	neg    r10
  1e3527:	test   r13,r13
  1e352a:	jns    1e3394 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x914>
  1e3530:	lea    rcx,[r12-0x1]
  1e3535:	imul   rcx,r8
  1e3539:	shl    rcx,0x4
  1e353d:	add    QWORD PTR [rsp+0x8],rcx
  1e3542:	neg    r8
  1e3545:	mov    r11b,al
  1e3548:	test   rdx,rdx
  1e354b:	mov    QWORD PTR [rsp+0x70],r13
  1e3550:	jns    1e33a5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  1e3556:	mov    rax,QWORD PTR [rsp+0x38]
  1e355b:	dec    rax
  1e355e:	mov    rcx,rdx
  1e3561:	imul   rcx,rax
  1e3565:	shl    rcx,0x4
  1e3569:	add    r9,rcx
  1e356c:	neg    rdx
  1e356f:	mov    rcx,QWORD PTR [rsp+0x40]
  1e3574:	imul   rax,rcx
  1e3578:	shl    rax,0x4
  1e357c:	add    QWORD PTR [rsp+0x8],rax
  1e3581:	neg    rcx
  1e3584:	mov    QWORD PTR [rsp+0x40],rcx
  1e3589:	jmp    1e33a5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x925>
  1e358e:	mov    rax,0xffffffffffffffff
  1e3595:	jmp    1e3006 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x586>
  1e359a:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e35a2:	call   QWORD PTR [rip+0x366d78]        # 54a320 <_DYNAMIC+0x548>
  1e35a8:	mov    rdx,QWORD PTR [rip+0x366d69]        # 54a318 <_DYNAMIC+0x540>
  1e35af:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e35b7:	mov    r8,QWORD PTR [rsp+0x30]
  1e35bc:	mov    edi,DWORD PTR [rsp+0x20]
  1e35c0:	mov    esi,DWORD PTR [rsp+0x10]
  1e35c4:	mov    cl,0x1
  1e35c6:	test   eax,0x80000
  1e35cb:	je     1e3045 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5c5>
  1e35d1:	jmp    1e363b <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0xbbb>
  1e35d3:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e35db:	call   QWORD PTR [rip+0x366d3f]        # 54a320 <_DYNAMIC+0x548>
  1e35e1:	mov    rdx,QWORD PTR [rip+0x366d30]        # 54a318 <_DYNAMIC+0x540>
  1e35e8:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e35f0:	mov    r8,QWORD PTR [rsp+0x30]
  1e35f5:	mov    edi,DWORD PTR [rsp+0x20]
  1e35f9:	mov    esi,DWORD PTR [rsp+0x10]
  1e35fd:	test   ax,ax
  1e3600:	js     1e3056 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5d6>
  1e3606:	jmp    1e306d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1e360b:	movaps XMMWORD PTR [rsp+0x80],xmm2
  1e3613:	call   QWORD PTR [rip+0x366d07]        # 54a320 <_DYNAMIC+0x548>
  1e3619:	movaps xmm2,XMMWORD PTR [rsp+0x80]
  1e3621:	mov    r8,QWORD PTR [rsp+0x30]
  1e3626:	mov    edi,DWORD PTR [rsp+0x20]
  1e362a:	mov    esi,DWORD PTR [rsp+0x10]
  1e362e:	bt     rax,0x37
  1e3633:	jae    1e306d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impINtCskC1yiOI7W9g_11num_complex7ComplexdEECscfHK10Grmvq_6fbench+0x5ed>
  1e3639:	xor    ecx,ecx
  1e363b:	mov    r9,QWORD PTR [rsp+0x38]
  1e3640:	imul   r13,r9
  1e3644:	mov    rdx,QWORD PTR [rsp+0x168]
  1e364c:	cmp    rdx,0x1
  1e3650:	adc    rdx,0x0
  1e3654:	cmp    r13,0x10000
  1e365b:	mov    eax,0x1
  1e3660:	cmovae rax,rdx
  1e3664:	sub    rsp,0xa0
  1e366b:	lea    rdx,[rsp+0xf0]
  1e3673:	mov    QWORD PTR [rsp+0x88],rdx
  1e367b:	movzx  edx,BYTE PTR [rsp+0xc8]
  1e3683:	mov    DWORD PTR [rsp+0x80],edx
  1e368a:	mov    rdx,QWORD PTR [rsp+0x110]
  1e3692:	mov    QWORD PTR [rsp+0x78],rdx
  1e3697:	mov    rdx,QWORD PTR [rsp+0xe8]
  1e369f:	mov    QWORD PTR [rsp+0x70],rdx
  1e36a4:	mov    rdx,QWORD PTR [rsp+0xb8]
  1e36ac:	mov    QWORD PTR [rsp+0x68],rdx
  1e36b1:	xorps  xmm0,xmm0
  1e36b4:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e36b9:	movzx  edx,sil
  1e36bd:	mov    DWORD PTR [rsp+0x50],edx
  1e36c1:	mov    rdx,QWORD PTR [rsp+0xe0]
  1e36c9:	mov    QWORD PTR [rsp+0x48],rdx
  1e36ce:	mov    QWORD PTR [rsp+0x40],r8
  1e36d3:	mov    rdx,QWORD PTR [rsp+0xa8]
  1e36db:	mov    QWORD PTR [rsp+0x38],rdx
  1e36e0:	movzx  edx,dil
  1e36e4:	mov    DWORD PTR [rsp+0x30],edx
  1e36e8:	movups XMMWORD PTR [rsp+0x18],xmm0
  1e36ed:	mov    QWORD PTR [rsp+0x10],rbp
  1e36f2:	mov    QWORD PTR [rsp+0x8],r14
  1e36f7:	mov    QWORD PTR [rsp],rbx
  1e36fb:	mov    QWORD PTR [rsp+0x90],rax
  1e3703:	mov    DWORD PTR [rsp+0x28],0x2
  1e370b:	movzx  edx,cl
  1e370e:	mov    r8,r15
  1e3711:	mov    edi,0x3
  1e3716:	mov    esi,0x1
  1e371b:	mov    rcx,r12
  1e371e:	call   QWORD PTR [rip+0x366c04]        # 54a328 <_DYNAMIC+0x550>
  1e3724:	add    rsp,0xa0
  1e372b:	add    rsp,0x128
  1e3732:	pop    rbx
  1e3733:	pop    r12
  1e3735:	pop    r13
  1e3737:	pop    r14
  1e3739:	pop    r15
  1e373b:	pop    rbp
  1e373c:	ret
