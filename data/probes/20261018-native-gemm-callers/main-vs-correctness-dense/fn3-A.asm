
target/faer-rev/7364be5ce22d-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001ee790 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  1ee790:	push   rbp
  1ee791:	push   r15
  1ee793:	push   r14
  1ee795:	push   r13
  1ee797:	push   r12
  1ee799:	push   rbx
  1ee79a:	sub    rsp,0x108
  1ee7a1:	mov    DWORD PTR [rsp+0x30],esi
  1ee7a5:	mov    r12,QWORD PTR [rdi+0x8]
  1ee7a9:	test   r12,r12
  1ee7ac:	je     1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1ee7b2:	mov    r15,QWORD PTR [rdi+0x10]
  1ee7b6:	test   r15,r15
  1ee7b9:	je     1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1ee7bf:	mov    rbx,QWORD PTR [rdi]
  1ee7c2:	mov    r14,QWORD PTR [rdi+0x18]
  1ee7c6:	mov    rax,QWORD PTR [rdi+0x20]
  1ee7ca:	mov    QWORD PTR [rsp+0x8],rax
  1ee7cf:	mov    r13,QWORD PTR [rdx+0x10]
  1ee7d3:	test   r13,r13
  1ee7d6:	je     1ee88e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  1ee7dc:	mov    r11,r8
  1ee7df:	mov    DWORD PTR [rsp+0x18],ecx
  1ee7e3:	mov    rax,QWORD PTR [rdx]
  1ee7e6:	mov    QWORD PTR [rsp+0x10],rax
  1ee7eb:	mov    rcx,QWORD PTR [rdx+0x8]
  1ee7ef:	mov    r8,QWORD PTR [rdx+0x18]
  1ee7f3:	test   r14,r14
  1ee7f6:	mov    QWORD PTR [rsp+0x28],rcx
  1ee7fb:	jns    1ee839 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  1ee7fd:	lea    rax,[r12-0x1]
  1ee802:	imul   rax,r14
  1ee806:	neg    r14
  1ee809:	xor    edi,edi
  1ee80b:	mov    r10,rcx
  1ee80e:	sub    r10,0x1
  1ee812:	cmovb  r10,rdi
  1ee816:	lea    rbx,[rbx+rax*8]
  1ee81a:	mov    rax,r8
  1ee81d:	imul   rax,r10
  1ee821:	cmp    r10,rcx
  1ee824:	cmove  rax,rdi
  1ee828:	mov    rcx,QWORD PTR [rsp+0x10]
  1ee82d:	lea    rcx,[rcx+rax*8]
  1ee831:	mov    QWORD PTR [rsp+0x10],rcx
  1ee836:	neg    r8
  1ee839:	mov    QWORD PTR [rsp+0x38],r8
  1ee83e:	mov    rdi,QWORD PTR [rdx+0x20]
  1ee842:	mov    r8,QWORD PTR [r11]
  1ee845:	mov    rax,QWORD PTR [r11+0x8]
  1ee849:	mov    QWORD PTR [rsp+0x20],rax
  1ee84e:	mov    rcx,QWORD PTR [r11+0x10]
  1ee852:	mov    rax,QWORD PTR [r11+0x20]
  1ee856:	cmp    QWORD PTR [rsp+0x8],0x0
  1ee85c:	js     1ee8e5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  1ee862:	mov    rsi,QWORD PTR [r11+0x18]
  1ee866:	test   rdi,rdi
  1ee869:	js     1ee951 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  1ee86f:	mov    r10,QWORD PTR [rsp+0x148]
  1ee877:	mov    r11,QWORD PTR [rsp+0x140]
  1ee87f:	cmp    r15,0x1
  1ee883:	je     1ee9d6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  1ee889:	jmp    1eeac4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1ee88e:	cmp    BYTE PTR [rsp+0x30],0x0
  1ee893:	jne    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1ee899:	cmp    r12,0x1
  1ee89d:	je     1ee8b3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  1ee89f:	cmp    r14,0xffffffffffffffff
  1ee8a3:	je     1ef014 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  1ee8a9:	cmp    r14,0x1
  1ee8ad:	je     1eedde <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64e>
  1ee8b3:	cmp    r15,0x1
  1ee8b7:	je     1eedd4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  1ee8bd:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  1ee8c3:	je     1ef197 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa07>
  1ee8c9:	cmp    QWORD PTR [rsp+0x8],0x1
  1ee8cf:	jne    1eedd4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  1ee8d5:	mov    rax,r15
  1ee8d8:	mov    r15,r12
  1ee8db:	mov    QWORD PTR [rsp+0x8],r14
  1ee8e0:	jmp    1ef1ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  1ee8e5:	lea    rdx,[r15-0x1]
  1ee8e9:	mov    rsi,QWORD PTR [rsp+0x8]
  1ee8ee:	imul   rdx,rsi
  1ee8f2:	lea    rbx,[rbx+rdx*8]
  1ee8f6:	neg    rsi
  1ee8f9:	mov    QWORD PTR [rsp+0x8],rsi
  1ee8fe:	xor    edx,edx
  1ee900:	mov    r10d,r9d
  1ee903:	mov    r9,r8
  1ee906:	mov    r8,rdi
  1ee909:	mov    rdi,rcx
  1ee90c:	sub    rdi,0x1
  1ee910:	cmovb  rdi,rdx
  1ee914:	mov    rbp,r13
  1ee917:	mov    r13,rax
  1ee91a:	imul   r13,rdi
  1ee91e:	cmp    rdi,rcx
  1ee921:	mov    rdi,r8
  1ee924:	mov    r8,r9
  1ee927:	mov    r9d,r10d
  1ee92a:	mov    r10,QWORD PTR [rsp+0x20]
  1ee92f:	cmove  r13,rdx
  1ee933:	test   r10,r10
  1ee936:	cmove  r13,r10
  1ee93a:	lea    r8,[r8+r13*8]
  1ee93e:	mov    r13,rbp
  1ee941:	neg    rax
  1ee944:	mov    rsi,QWORD PTR [r11+0x18]
  1ee948:	test   rdi,rdi
  1ee94b:	jns    1ee86f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  1ee951:	lea    rdx,[r13-0x1]
  1ee955:	imul   rdx,rdi
  1ee959:	mov    r10,QWORD PTR [rsp+0x28]
  1ee95e:	test   r10,r10
  1ee961:	cmove  rdx,r10
  1ee965:	mov    r10,rax
  1ee968:	mov    rax,QWORD PTR [rsp+0x10]
  1ee96d:	lea    rax,[rax+rdx*8]
  1ee971:	mov    QWORD PTR [rsp+0x10],rax
  1ee976:	neg    rdi
  1ee979:	xor    edx,edx
  1ee97b:	mov    rax,rdi
  1ee97e:	mov    rbp,r13
  1ee981:	mov    r13,rsi
  1ee984:	mov    rsi,QWORD PTR [rsp+0x20]
  1ee989:	mov    rdi,rsi
  1ee98c:	sub    rdi,0x1
  1ee990:	cmovb  rdi,rdx
  1ee994:	mov    r11,r13
  1ee997:	imul   r11,rdi
  1ee99b:	test   rcx,rcx
  1ee99e:	cmove  r11,rcx
  1ee9a2:	cmp    rdi,rsi
  1ee9a5:	mov    rsi,r13
  1ee9a8:	mov    r13,rbp
  1ee9ab:	mov    rdi,rax
  1ee9ae:	mov    rax,r10
  1ee9b1:	cmove  r11,rdx
  1ee9b5:	lea    r8,[r8+r11*8]
  1ee9b9:	neg    rsi
  1ee9bc:	mov    r10,QWORD PTR [rsp+0x148]
  1ee9c4:	mov    r11,QWORD PTR [rsp+0x140]
  1ee9cc:	cmp    r15,0x1
  1ee9d0:	jne    1eeac4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1ee9d6:	cmp    QWORD PTR [rsp+0x38],0x1
  1ee9dc:	jne    1eea4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1ee9de:	cmp    r14,0x1
  1ee9e2:	jne    1eea4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1ee9e4:	test   rbx,rbx
  1ee9e7:	je     1eea4f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1ee9e9:	mov    rax,QWORD PTR [rsp+0x10]
  1ee9ee:	mov    QWORD PTR [rsp+0x78],rax
  1ee9f3:	mov    rax,QWORD PTR [rsp+0x28]
  1ee9f8:	mov    QWORD PTR [rsp+0x80],rax
  1eea00:	mov    QWORD PTR [rsp+0x88],r13
  1eea08:	mov    QWORD PTR [rsp+0x90],rdi
  1eea10:	mov    QWORD PTR [rsp+0x60],r8
  1eea15:	mov    rax,QWORD PTR [rsp+0x20]
  1eea1a:	mov    QWORD PTR [rsp+0x68],rax
  1eea1f:	mov    QWORD PTR [rsp+0x70],rsi
  1eea24:	sub    rsp,0x8
  1eea28:	movzx  eax,r9b
  1eea2c:	movzx  edx,BYTE PTR [rsp+0x38]
  1eea31:	movzx  r8d,BYTE PTR [rsp+0x20]
  1eea37:	lea    rcx,[rsp+0x80]
  1eea3f:	lea    r9,[rsp+0x68]
  1eea44:	mov    rdi,rbx
  1eea47:	mov    rsi,r12
  1eea4a:	jmp    1eeb40 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  1eea4f:	cmp    rdi,0x1
  1eea53:	jne    1eeac4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1eea55:	cmp    rsi,0x1
  1eea59:	jne    1eeac4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1eea5b:	test   r8,r8
  1eea5e:	je     1eeac4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1eea60:	mov    rax,QWORD PTR [rsp+0x10]
  1eea65:	mov    QWORD PTR [rsp+0x78],rax
  1eea6a:	mov    rax,QWORD PTR [rsp+0x28]
  1eea6f:	mov    QWORD PTR [rsp+0x80],rax
  1eea77:	mov    QWORD PTR [rsp+0x88],r13
  1eea7f:	mov    rax,QWORD PTR [rsp+0x38]
  1eea84:	mov    QWORD PTR [rsp+0x90],rax
  1eea8c:	mov    QWORD PTR [rsp+0x60],rbx
  1eea91:	mov    QWORD PTR [rsp+0x68],r12
  1eea96:	mov    QWORD PTR [rsp+0x70],r14
  1eea9b:	sub    rsp,0x8
  1eea9f:	movzx  eax,r9b
  1eeaa3:	movzx  esi,BYTE PTR [rsp+0x38]
  1eeaa8:	movzx  ecx,BYTE PTR [rsp+0x20]
  1eeaad:	lea    rdi,[rsp+0x68]
  1eeab2:	lea    rdx,[rsp+0x80]
  1eeaba:	mov    r9,QWORD PTR [rsp+0x28]
  1eeabf:	jmp    1eebc7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  1eeac4:	cmp    r12,0x1
  1eeac8:	jne    1eebda <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1eeace:	xor    edx,edx
  1eead0:	cmp    QWORD PTR [rsp+0x8],0x1
  1eead6:	cmove  rdx,rbx
  1eeada:	cmp    rax,0x1
  1eeade:	jne    1eeb53 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1eeae0:	test   rdx,rdx
  1eeae3:	je     1eeb53 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1eeae5:	mov    QWORD PTR [rsp+0x78],r8
  1eeaea:	mov    QWORD PTR [rsp+0x80],rcx
  1eeaf2:	mov    rax,QWORD PTR [rsp+0x20]
  1eeaf7:	mov    QWORD PTR [rsp+0x88],rax
  1eeaff:	mov    QWORD PTR [rsp+0x90],rsi
  1eeb07:	mov    rax,QWORD PTR [rsp+0x10]
  1eeb0c:	mov    QWORD PTR [rsp+0x60],rax
  1eeb11:	mov    QWORD PTR [rsp+0x68],r13
  1eeb16:	mov    QWORD PTR [rsp+0x70],rdi
  1eeb1b:	sub    rsp,0x8
  1eeb1f:	movzx  eax,BYTE PTR [rsp+0x20]
  1eeb24:	movzx  edx,BYTE PTR [rsp+0x38]
  1eeb29:	movzx  r8d,r9b
  1eeb2d:	lea    rcx,[rsp+0x80]
  1eeb35:	lea    r9,[rsp+0x68]
  1eeb3a:	mov    rdi,rbx
  1eeb3d:	mov    rsi,r15
  1eeb40:	push   r10
  1eeb42:	push   r11
  1eeb44:	push   rax
  1eeb45:	call   159fb0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  1eeb4a:	add    rsp,0x20
  1eeb4e:	jmp    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1eeb53:	xor    edx,edx
  1eeb55:	cmp    rdi,0x1
  1eeb59:	cmove  rdx,QWORD PTR [rsp+0x10]
  1eeb5f:	cmp    rsi,0x1
  1eeb63:	jne    1eebda <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1eeb65:	test   rdx,rdx
  1eeb68:	je     1eebda <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1eeb6a:	mov    QWORD PTR [rsp+0x78],r8
  1eeb6f:	mov    QWORD PTR [rsp+0x80],rcx
  1eeb77:	mov    rcx,QWORD PTR [rsp+0x20]
  1eeb7c:	mov    QWORD PTR [rsp+0x88],rcx
  1eeb84:	mov    QWORD PTR [rsp+0x90],rax
  1eeb8c:	mov    QWORD PTR [rsp+0x60],rbx
  1eeb91:	mov    QWORD PTR [rsp+0x68],r15
  1eeb96:	mov    rax,QWORD PTR [rsp+0x8]
  1eeb9b:	mov    QWORD PTR [rsp+0x70],rax
  1eeba0:	sub    rsp,0x8
  1eeba4:	movzx  eax,BYTE PTR [rsp+0x20]
  1eeba9:	movzx  esi,BYTE PTR [rsp+0x38]
  1eebae:	movzx  ecx,r9b
  1eebb2:	lea    rdi,[rsp+0x68]
  1eebb7:	lea    rdx,[rsp+0x80]
  1eebbf:	mov    r8,QWORD PTR [rsp+0x18]
  1eebc4:	mov    r9,r13
  1eebc7:	push   r10
  1eebc9:	push   r11
  1eebcb:	push   rax
  1eebcc:	call   1f8f80 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  1eebd1:	add    rsp,0x20
  1eebd5:	jmp    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1eebda:	cmp    r13,0x1
  1eebde:	jne    1eece8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1eebe4:	xor    edx,edx
  1eebe6:	cmp    r14,0x1
  1eebea:	cmove  rdx,rbx
  1eebee:	cmp    QWORD PTR [rsp+0x38],0x1
  1eebf4:	jne    1eec5d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1eebf6:	test   rdx,rdx
  1eebf9:	je     1eec5d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1eebfb:	mov    QWORD PTR [rsp+0x78],rdx
  1eec00:	mov    QWORD PTR [rsp+0x80],r12
  1eec08:	mov    QWORD PTR [rsp+0x88],r15
  1eec10:	mov    rdx,QWORD PTR [rsp+0x8]
  1eec15:	mov    QWORD PTR [rsp+0x90],rdx
  1eec1d:	mov    QWORD PTR [rsp+0x60],r8
  1eec22:	mov    QWORD PTR [rsp+0x68],rcx
  1eec27:	mov    QWORD PTR [rsp+0x70],rax
  1eec2c:	sub    rsp,0x8
  1eec30:	mov    r14,r10
  1eec33:	movzx  r10d,r9b
  1eec37:	movzx  esi,BYTE PTR [rsp+0x38]
  1eec3c:	movzx  r8d,BYTE PTR [rsp+0x20]
  1eec42:	lea    rdi,[rsp+0x80]
  1eec4a:	lea    r9,[rsp+0x68]
  1eec4f:	mov    rdx,QWORD PTR [rsp+0x18]
  1eec54:	mov    rcx,QWORD PTR [rsp+0x30]
  1eec59:	push   r14
  1eec5b:	jmp    1eecd6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  1eec5d:	xor    edx,edx
  1eec5f:	cmp    QWORD PTR [rsp+0x8],0x1
  1eec65:	cmove  rdx,rbx
  1eec69:	cmp    rax,0x1
  1eec6d:	jne    1eece8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1eec6f:	test   rdx,rdx
  1eec72:	je     1eece8 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1eec74:	mov    QWORD PTR [rsp+0x78],rdx
  1eec79:	mov    QWORD PTR [rsp+0x80],r15
  1eec81:	mov    QWORD PTR [rsp+0x88],r12
  1eec89:	mov    QWORD PTR [rsp+0x90],r14
  1eec91:	mov    rax,QWORD PTR [rsp+0x10]
  1eec96:	mov    QWORD PTR [rsp+0x60],rax
  1eec9b:	mov    rax,QWORD PTR [rsp+0x28]
  1eeca0:	mov    QWORD PTR [rsp+0x68],rax
  1eeca5:	mov    rax,QWORD PTR [rsp+0x38]
  1eecaa:	mov    QWORD PTR [rsp+0x70],rax
  1eecaf:	sub    rsp,0x8
  1eecb3:	mov    rax,r10
  1eecb6:	movzx  r10d,BYTE PTR [rsp+0x20]
  1eecbc:	movzx  esi,BYTE PTR [rsp+0x38]
  1eecc1:	mov    rdx,r8
  1eecc4:	movzx  r8d,r9b
  1eecc8:	lea    rdi,[rsp+0x80]
  1eecd0:	lea    r9,[rsp+0x68]
  1eecd5:	push   rax
  1eecd6:	push   r11
  1eecd8:	push   r10
  1eecda:	call   158fd0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  1eecdf:	add    rsp,0x20
  1eece3:	jmp    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1eece8:	mov    QWORD PTR [rsp+0x20],rax
  1eeced:	movsd  xmm1,QWORD PTR [r11]
  1eecf2:	mov    rax,r12
  1eecf5:	mul    r15
  1eecf8:	mov    rbp,rax
  1eecfb:	movsd  QWORD PTR [rsp+0x60],xmm1
  1eed01:	seto   r11b
  1eed05:	jo     1ef235 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  1eed0b:	mul    r13
  1eed0e:	seto   cl
  1eed11:	not    cl
  1eed13:	cmp    rax,0x1001
  1eed19:	setb   al
  1eed1c:	test   cl,al
  1eed1e:	jne    1eed7b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5eb>
  1eed20:	mov    rdx,QWORD PTR [rip+0x35b5f1]        # 54a318 <_DYNAMIC+0x540>
  1eed27:	mov    rax,QWORD PTR [rdx]
  1eed2a:	test   rax,rax
  1eed2d:	je     1ef241 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  1eed33:	mov    cl,0x1
  1eed35:	test   eax,0x80000
  1eed3a:	jne    1ef363 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  1eed40:	mov    rax,QWORD PTR [rdx]
  1eed43:	test   rax,rax
  1eed46:	je     1ef2a7 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb17>
  1eed4c:	test   ax,ax
  1eed4f:	jns    1eed68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1eed51:	mov    rax,QWORD PTR [rdx]
  1eed54:	test   rax,rax
  1eed57:	je     1ef309 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb79>
  1eed5d:	bt     rax,0x37
  1eed62:	jb     1ef361 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd1>
  1eed68:	cmp    BYTE PTR [rsp+0x30],0x0
  1eed6d:	jne    1ef01c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  1eed73:	xorps  xmm0,xmm0
  1eed76:	jmp    1ef024 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  1eed7b:	cmp    BYTE PTR [rsp+0x30],0x0
  1eed80:	mov    eax,DWORD PTR [rsp+0x18]
  1eed84:	jne    1eede6 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x656>
  1eed86:	xorps  xmm0,xmm0
  1eed89:	movsd  QWORD PTR [rsp+0x30],xmm0
  1eed8f:	cmp    QWORD PTR [rsp+0x8],r14
  1eed94:	jb     1eedfb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66b>
  1eed96:	mov    ebp,r9d
  1eed99:	mov    r9d,eax
  1eed9c:	mov    rax,QWORD PTR [rsp+0x20]
  1eeda1:	mov    QWORD PTR [rsp+0x18],rax
  1eeda6:	mov    QWORD PTR [rsp+0x40],rsi
  1eedab:	mov    QWORD PTR [rsp+0x58],r8
  1eedb0:	mov    rsi,rdi
  1eedb3:	mov    rax,QWORD PTR [rsp+0x38]
  1eedb8:	mov    r8,QWORD PTR [rsp+0x10]
  1eedbd:	mov    rcx,QWORD PTR [rsp+0x8]
  1eedc2:	mov    QWORD PTR [rsp+0x10],rcx
  1eedc7:	mov    QWORD PTR [rsp+0x8],r14
  1eedcc:	mov    r14,r15
  1eedcf:	mov    r15,r12
  1eedd2:	jmp    1eee23 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x693>
  1eedd4:	cmp    r14,0x1
  1eedd8:	jne    1eef4e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7be>
  1eedde:	mov    rax,r12
  1eede1:	jmp    1ef1ae <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  1eede6:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe50cda]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1eedee:	movsd  QWORD PTR [rsp+0x30],xmm0
  1eedf4:	cmp    QWORD PTR [rsp+0x8],r14
  1eedf9:	jae    1eed96 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x606>
  1eedfb:	mov    ebp,eax
  1eedfd:	mov    rax,QWORD PTR [rsp+0x38]
  1eee02:	mov    QWORD PTR [rsp+0x18],rax
  1eee07:	mov    QWORD PTR [rsp+0x40],rdi
  1eee0c:	mov    rax,QWORD PTR [rsp+0x10]
  1eee11:	mov    QWORD PTR [rsp+0x58],rax
  1eee16:	mov    QWORD PTR [rsp+0x10],r14
  1eee1b:	mov    r14,r12
  1eee1e:	mov    rax,QWORD PTR [rsp+0x20]
  1eee23:	movsd  QWORD PTR [rsp+0x28],xmm1
  1eee29:	mov    QWORD PTR [rsp+0x48],rsi
  1eee2e:	mov    QWORD PTR [rsp+0x50],r8
  1eee33:	mov    r12d,r9d
  1eee36:	mov    QWORD PTR [rsp+0x20],rax
  1eee3b:	cmp    rax,0x1
  1eee3f:	jne    1eee66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1eee41:	cmp    QWORD PTR [rsp+0x8],0x1
  1eee47:	jne    1eee66 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1eee49:	lea    r8,[rip+0x34c448]        # 53b298 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x410>
  1eee50:	lea    rdi,[rsp+0x78]
  1eee55:	mov    rsi,r15
  1eee58:	mov    rdx,r14
  1eee5b:	mov    rcx,r13
  1eee5e:	call   QWORD PTR [rip+0x35b65c]        # 54a4c0 <_DYNAMIC+0x6e8>
  1eee64:	jmp    1eee81 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f1>
  1eee66:	lea    r8,[rip+0x34c443]        # 53b2b0 <anon.3dc9f65aa8477a3cdcc84450da937ddf.270.llvm.9030206044929388573+0x428>
  1eee6d:	lea    rdi,[rsp+0x78]
  1eee72:	mov    rsi,r15
  1eee75:	mov    rdx,r14
  1eee78:	mov    rcx,r13
  1eee7b:	call   QWORD PTR [rip+0x35b647]        # 54a4c8 <_DYNAMIC+0x6f0>
  1eee81:	lea    rdi,[rsp+0x80]
  1eee89:	mov    rsi,QWORD PTR [rsp+0xa0]
  1eee91:	mov    rdx,QWORD PTR [rsp+0xa8]
  1eee99:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  1eeea1:	sub    rsp,0x70
  1eeea5:	movups XMMWORD PTR [rsp+0x58],xmm0
  1eeeaa:	movzx  eax,bpl
  1eeeae:	mov    DWORD PTR [rsp+0x50],eax
  1eeeb2:	movzx  eax,r12b
  1eeeb6:	mov    DWORD PTR [rsp+0x48],eax
  1eeeba:	mov    rax,QWORD PTR [rsp+0x88]
  1eeec2:	mov    QWORD PTR [rsp+0x40],rax
  1eeec7:	mov    rax,QWORD PTR [rsp+0xb0]
  1eeecf:	mov    QWORD PTR [rsp+0x38],rax
  1eeed4:	mov    rax,QWORD PTR [rsp+0xc8]
  1eeedc:	mov    QWORD PTR [rsp+0x30],rax
  1eeee1:	mov    rax,QWORD PTR [rsp+0xb8]
  1eeee9:	mov    QWORD PTR [rsp+0x28],rax
  1eeeee:	mov    rax,QWORD PTR [rsp+0x90]
  1eeef6:	mov    QWORD PTR [rsp+0x20],rax
  1eeefb:	mov    rax,QWORD PTR [rsp+0xc0]
  1eef03:	mov    QWORD PTR [rsp+0x18],rax
  1eef08:	mov    rax,QWORD PTR [rsp+0x80]
  1eef10:	mov    QWORD PTR [rsp+0x10],rax
  1eef15:	mov    rax,QWORD PTR [rsp+0x78]
  1eef1a:	mov    QWORD PTR [rsp+0x8],rax
  1eef1f:	mov    QWORD PTR [rsp],rbx
  1eef23:	mov    r8,r14
  1eef26:	mov    r9,r13
  1eef29:	mov    rcx,r15
  1eef2c:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  1eef35:	movsd  xmm1,QWORD PTR [rsp+0x98]
  1eef3e:	call   QWORD PTR [rsp+0xe8]
  1eef45:	add    rsp,0x70
  1eef49:	jmp    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1eef4e:	lea    rax,[r12-0x1]
  1eef53:	mov    ecx,r12d
  1eef56:	and    ecx,0x3
  1eef59:	and    r12,0xfffffffffffffffc
  1eef5d:	lea    rdx,[r14*8+0x0]
  1eef65:	lea    rsi,[rdx+rdx*2]
  1eef69:	shl    QWORD PTR [rsp+0x8],0x3
  1eef6f:	mov    rdi,r14
  1eef72:	shl    rdi,0x5
  1eef76:	mov    r8,r14
  1eef79:	shl    r8,0x4
  1eef7d:	xor    r9d,r9d
  1eef80:	jmp    1eefa1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  1eef82:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1eef90:	inc    r9
  1eef93:	add    rbx,QWORD PTR [rsp+0x8]
  1eef98:	cmp    r9,r15
  1eef9b:	je     1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1eefa1:	cmp    rax,0x3
  1eefa5:	jae    1eefb0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  1eefa7:	xor    r10d,r10d
  1eefaa:	jmp    1eeff0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  1eefac:	nop    DWORD PTR [rax+0x0]
  1eefb0:	mov    r11,rbx
  1eefb3:	xor    r10d,r10d
  1eefb6:	cs nop WORD PTR [rax+rax*1+0x0]
  1eefc0:	mov    QWORD PTR [r11],0x0
  1eefc7:	mov    QWORD PTR [r11+r14*8],0x0
  1eefcf:	mov    QWORD PTR [r11+r8*1],0x0
  1eefd7:	add    r10,0x4
  1eefdb:	mov    QWORD PTR [r11+rsi*1],0x0
  1eefe3:	add    r11,rdi
  1eefe6:	cmp    r12,r10
  1eefe9:	jne    1eefc0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  1eefeb:	test   rcx,rcx
  1eefee:	je     1eef90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1eeff0:	imul   r10,rdx
  1eeff4:	add    r10,rbx
  1eeff7:	mov    r11,rcx
  1eeffa:	nop    WORD PTR [rax+rax*1+0x0]
  1ef000:	mov    QWORD PTR [r10],0x0
  1ef007:	add    r10,rdx
  1ef00a:	dec    r11
  1ef00d:	jne    1ef000 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  1ef00f:	jmp    1eef90 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1ef014:	mov    rax,r12
  1ef017:	jmp    1ef1a2 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa12>
  1ef01c:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe50aa4]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  1ef024:	xor    r11d,r11d
  1ef027:	test   r10,r10
  1ef02a:	setne  dl
  1ef02d:	cmp    QWORD PTR [rsp+0x8],r14
  1ef032:	jge    1ef04e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8be>
  1ef034:	mov    rcx,QWORD PTR [rsp+0x20]
  1ef039:	mov    QWORD PTR [rsp+0x18],rsi
  1ef03e:	mov    rax,r8
  1ef041:	mov    r8,r14
  1ef044:	mov    rbp,r15
  1ef047:	mov    r9,QWORD PTR [rsp+0x38]
  1ef04c:	jmp    1ef07d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8ed>
  1ef04e:	mov    rcx,QWORD PTR [rsp+0x38]
  1ef053:	mov    QWORD PTR [rsp+0x18],rdi
  1ef058:	mov    rax,QWORD PTR [rsp+0x10]
  1ef05d:	mov    r10,QWORD PTR [rsp+0x8]
  1ef062:	mov    rbp,r12
  1ef065:	mov    r9,QWORD PTR [rsp+0x20]
  1ef06a:	mov    rdi,rsi
  1ef06d:	mov    QWORD PTR [rsp+0x10],r8
  1ef072:	mov    r8,r10
  1ef075:	mov    QWORD PTR [rsp+0x8],r14
  1ef07a:	mov    r12,r15
  1ef07d:	mov    r11b,dl
  1ef080:	lea    rdx,[rbp-0x1]
  1ef084:	imul   rdx,rcx
  1ef088:	mov    r14,rcx
  1ef08b:	neg    r14
  1ef08e:	mov    rsi,QWORD PTR [rsp+0x8]
  1ef093:	test   rsi,rsi
  1ef096:	cmovns r14,rcx
  1ef09a:	mov    rcx,rsi
  1ef09d:	sar    rcx,0x3f
  1ef0a1:	and    rcx,rdx
  1ef0a4:	lea    rsi,[rax+rcx*8]
  1ef0a8:	lea    rax,[r12-0x1]
  1ef0ad:	imul   rax,r9
  1ef0b1:	mov    r15,r9
  1ef0b4:	neg    r15
  1ef0b7:	test   r8,r8
  1ef0ba:	cmovns r15,r9
  1ef0be:	mov    rcx,r8
  1ef0c1:	sar    rcx,0x3f
  1ef0c5:	and    rcx,rax
  1ef0c8:	mov    rax,QWORD PTR [rsp+0x10]
  1ef0cd:	lea    r9,[rax+rcx*8]
  1ef0d1:	cmp    QWORD PTR [rsp+0x18],0x0
  1ef0d7:	jns    1ef100 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x970>
  1ef0d9:	lea    rax,[r13-0x1]
  1ef0dd:	mov    rdx,QWORD PTR [rsp+0x18]
  1ef0e2:	mov    rcx,rdx
  1ef0e5:	imul   rcx,rax
  1ef0e9:	lea    rsi,[rsi+rcx*8]
  1ef0ed:	neg    rdx
  1ef0f0:	mov    QWORD PTR [rsp+0x18],rdx
  1ef0f5:	imul   rax,rdi
  1ef0f9:	lea    r9,[r9+rax*8]
  1ef0fd:	neg    rdi
  1ef100:	mov    QWORD PTR [rsp+0x20],r9
  1ef105:	mov    QWORD PTR [rsp+0x10],rsi
  1ef10a:	mov    QWORD PTR [rsp+0x40],rdi
  1ef10f:	mov    rax,QWORD PTR [rip+0x35b3ba]        # 54a4d0 <_DYNAMIC+0x6f8>
  1ef116:	mov    rax,QWORD PTR [rax]
  1ef119:	test   rax,rax
  1ef11c:	jne    1ef150 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c0>
  1ef11e:	movsd  QWORD PTR [rsp+0x28],xmm1
  1ef124:	movsd  QWORD PTR [rsp+0x38],xmm0
  1ef12a:	mov    QWORD PTR [rsp+0x48],r11
  1ef12f:	mov    QWORD PTR [rsp+0x50],r8
  1ef134:	call   QWORD PTR [rip+0x35b39e]        # 54a4d8 <_DYNAMIC+0x700>
  1ef13a:	mov    r8,QWORD PTR [rsp+0x50]
  1ef13f:	mov    r11,QWORD PTR [rsp+0x48]
  1ef144:	movsd  xmm0,QWORD PTR [rsp+0x38]
  1ef14a:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1ef150:	movzx  r10d,BYTE PTR [rsp+0x30]
  1ef156:	mov    rdi,rbp
  1ef159:	mov    rsi,r12
  1ef15c:	mov    rdx,r13
  1ef15f:	mov    rcx,rbx
  1ef162:	mov    r9,QWORD PTR [rsp+0x8]
  1ef167:	push   QWORD PTR [rsp+0x148]
  1ef16e:	push   r11
  1ef170:	push   0x0
  1ef172:	push   0x0
  1ef174:	push   0x0
  1ef176:	push   QWORD PTR [rsp+0x68]
  1ef17a:	push   r15
  1ef17c:	push   QWORD PTR [rsp+0x58]
  1ef180:	push   r14
  1ef182:	push   QWORD PTR [rsp+0x60]
  1ef186:	push   QWORD PTR [rsp+0x60]
  1ef18a:	push   r10
  1ef18c:	call   rax
  1ef18e:	add    rsp,0x60
  1ef192:	jmp    1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1ef197:	mov    rax,r15
  1ef19a:	mov    r15,r12
  1ef19d:	mov    QWORD PTR [rsp+0x8],r14
  1ef1a2:	mov    ecx,0x1
  1ef1a7:	sub    rcx,rax
  1ef1aa:	lea    rbx,[rbx+rcx*8]
  1ef1ae:	lea    rcx,[rax-0x1]
  1ef1b2:	mov    edx,eax
  1ef1b4:	and    edx,0x3
  1ef1b7:	and    rax,0xfffffffffffffffc
  1ef1bb:	xor    esi,esi
  1ef1bd:	xorps  xmm0,xmm0
  1ef1c0:	jmp    1ef1dc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  1ef1c2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1ef1d0:	inc    rsi
  1ef1d3:	cmp    rsi,r15
  1ef1d6:	je     1ef481 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1ef1dc:	mov    rdi,rsi
  1ef1df:	imul   rdi,QWORD PTR [rsp+0x8]
  1ef1e5:	lea    rdi,[rbx+rdi*8]
  1ef1e9:	cmp    rcx,0x3
  1ef1ed:	jb     1ef219 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  1ef1ef:	xor    r8d,r8d
  1ef1f2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1ef200:	movups XMMWORD PTR [rdi],xmm0
  1ef203:	movups XMMWORD PTR [rdi+0x10],xmm0
  1ef207:	add    rdi,0x20
  1ef20b:	add    r8,0x4
  1ef20f:	cmp    rax,r8
  1ef212:	jne    1ef200 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  1ef214:	test   rdx,rdx
  1ef217:	je     1ef1d0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1ef219:	xor    r8d,r8d
  1ef21c:	nop    DWORD PTR [rax+0x0]
  1ef220:	mov    QWORD PTR [rdi],0x0
  1ef227:	add    rdi,0x8
  1ef22b:	inc    r8
  1ef22e:	cmp    rdx,r8
  1ef231:	jne    1ef220 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  1ef233:	jmp    1ef1d0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1ef235:	mov    rax,0xffffffffffffffff
  1ef23c:	jmp    1eed0b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x57b>
  1ef241:	mov    DWORD PTR [rsp+0x58],r9d
  1ef246:	mov    QWORD PTR [rsp+0x40],rdi
  1ef24b:	mov    QWORD PTR [rsp+0x50],r8
  1ef250:	mov    QWORD PTR [rsp+0x48],rsi
  1ef255:	movsd  QWORD PTR [rsp+0x28],xmm1
  1ef25b:	mov    BYTE PTR [rsp+0x7],r11b
  1ef260:	call   QWORD PTR [rip+0x35b0ba]        # 54a320 <_DYNAMIC+0x548>
  1ef266:	mov    rdx,QWORD PTR [rip+0x35b0ab]        # 54a318 <_DYNAMIC+0x540>
  1ef26d:	movzx  r11d,BYTE PTR [rsp+0x7]
  1ef273:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1ef279:	mov    rsi,QWORD PTR [rsp+0x48]
  1ef27e:	mov    r10,QWORD PTR [rsp+0x148]
  1ef286:	mov    r8,QWORD PTR [rsp+0x50]
  1ef28b:	mov    rdi,QWORD PTR [rsp+0x40]
  1ef290:	mov    r9d,DWORD PTR [rsp+0x58]
  1ef295:	mov    cl,0x1
  1ef297:	test   eax,0x80000
  1ef29c:	je     1eed40 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b0>
  1ef2a2:	jmp    1ef363 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  1ef2a7:	mov    DWORD PTR [rsp+0x58],r9d
  1ef2ac:	mov    QWORD PTR [rsp+0x40],rdi
  1ef2b1:	mov    QWORD PTR [rsp+0x50],r8
  1ef2b6:	mov    QWORD PTR [rsp+0x48],rsi
  1ef2bb:	movsd  QWORD PTR [rsp+0x28],xmm1
  1ef2c1:	mov    BYTE PTR [rsp+0x7],r11b
  1ef2c6:	call   QWORD PTR [rip+0x35b054]        # 54a320 <_DYNAMIC+0x548>
  1ef2cc:	mov    rdx,QWORD PTR [rip+0x35b045]        # 54a318 <_DYNAMIC+0x540>
  1ef2d3:	movzx  r11d,BYTE PTR [rsp+0x7]
  1ef2d9:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1ef2df:	mov    rsi,QWORD PTR [rsp+0x48]
  1ef2e4:	mov    r10,QWORD PTR [rsp+0x148]
  1ef2ec:	mov    r8,QWORD PTR [rsp+0x50]
  1ef2f1:	mov    rdi,QWORD PTR [rsp+0x40]
  1ef2f6:	mov    r9d,DWORD PTR [rsp+0x58]
  1ef2fb:	test   ax,ax
  1ef2fe:	js     1eed51 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c1>
  1ef304:	jmp    1eed68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1ef309:	mov    DWORD PTR [rsp+0x58],r9d
  1ef30e:	mov    QWORD PTR [rsp+0x40],rdi
  1ef313:	mov    QWORD PTR [rsp+0x50],r8
  1ef318:	mov    QWORD PTR [rsp+0x48],rsi
  1ef31d:	movsd  QWORD PTR [rsp+0x28],xmm1
  1ef323:	mov    BYTE PTR [rsp+0x7],r11b
  1ef328:	call   QWORD PTR [rip+0x35aff2]        # 54a320 <_DYNAMIC+0x548>
  1ef32e:	movzx  r11d,BYTE PTR [rsp+0x7]
  1ef334:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1ef33a:	mov    rsi,QWORD PTR [rsp+0x48]
  1ef33f:	mov    r10,QWORD PTR [rsp+0x148]
  1ef347:	mov    r8,QWORD PTR [rsp+0x50]
  1ef34c:	mov    rdi,QWORD PTR [rsp+0x40]
  1ef351:	mov    r9d,DWORD PTR [rsp+0x58]
  1ef356:	bt     rax,0x37
  1ef35b:	jae    1eed68 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1ef361:	xor    ecx,ecx
  1ef363:	mov    r10d,r9d
  1ef366:	mov    r9,r8
  1ef369:	test   r11b,r11b
  1ef36c:	jne    1ef493 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd03>
  1ef372:	mov    r8,rdi
  1ef375:	mov    rax,rbp
  1ef378:	mul    r13
  1ef37b:	jo     1ef4a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  1ef381:	test   rax,rax
  1ef384:	js     1ef4a9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  1ef38a:	mov    rdx,QWORD PTR [rip+0x35b07f]        # 54a410 <_DYNAMIC+0x638>
  1ef391:	mov    rdx,QWORD PTR [rdx]
  1ef394:	movabs rdi,0x7fffffffffffffff
  1ef39e:	and    rdi,rdx
  1ef3a1:	mov    edx,0x1
  1ef3a6:	cmp    rax,rdi
  1ef3a9:	jb     1ef3bb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc2b>
  1ef3ab:	mov    rdx,QWORD PTR [rsp+0x148]
  1ef3b3:	cmp    rdx,0x1
  1ef3b7:	adc    rdx,0x0
  1ef3bb:	sub    rsp,0xa0
  1ef3c2:	mov    QWORD PTR [rsp+0x90],rdx
  1ef3ca:	lea    rax,[rsp+0x100]
  1ef3d2:	mov    QWORD PTR [rsp+0x88],rax
  1ef3da:	movzx  eax,r10b
  1ef3de:	mov    DWORD PTR [rsp+0x80],eax
  1ef3e5:	mov    rax,QWORD PTR [rsp+0xc0]
  1ef3ed:	mov    QWORD PTR [rsp+0x78],rax
  1ef3f2:	mov    QWORD PTR [rsp+0x70],rsi
  1ef3f7:	mov    QWORD PTR [rsp+0x68],r9
  1ef3fc:	xorps  xmm0,xmm0
  1ef3ff:	movups XMMWORD PTR [rsp+0x58],xmm0
  1ef404:	movzx  eax,BYTE PTR [rsp+0xb8]
  1ef40c:	mov    DWORD PTR [rsp+0x50],eax
  1ef410:	mov    QWORD PTR [rsp+0x48],r8
  1ef415:	mov    rax,QWORD PTR [rsp+0xd8]
  1ef41d:	mov    QWORD PTR [rsp+0x40],rax
  1ef422:	mov    rax,QWORD PTR [rsp+0xb0]
  1ef42a:	mov    QWORD PTR [rsp+0x38],rax
  1ef42f:	movzx  eax,BYTE PTR [rsp+0xd0]
  1ef437:	mov    DWORD PTR [rsp+0x30],eax
  1ef43b:	movups XMMWORD PTR [rsp+0x18],xmm0
  1ef440:	mov    rax,QWORD PTR [rsp+0xa8]
  1ef448:	mov    QWORD PTR [rsp+0x10],rax
  1ef44d:	mov    QWORD PTR [rsp+0x8],r14
  1ef452:	mov    QWORD PTR [rsp],rbx
  1ef456:	mov    DWORD PTR [rsp+0x28],0x2
  1ef45e:	movzx  edx,cl
  1ef461:	mov    r8,r15
  1ef464:	mov    edi,0x1
  1ef469:	mov    r9,r13
  1ef46c:	mov    esi,0x1
  1ef471:	mov    rcx,r12
  1ef474:	call   QWORD PTR [rip+0x35aeae]        # 54a328 <_DYNAMIC+0x550>
  1ef47a:	add    rsp,0xa0
  1ef481:	add    rsp,0x108
  1ef488:	pop    rbx
  1ef489:	pop    r12
  1ef48b:	pop    r13
  1ef48d:	pop    r14
  1ef48f:	pop    r15
  1ef491:	pop    rbp
  1ef492:	ret
  1ef493:	mov    rbp,0xffffffffffffffff
  1ef49a:	mov    r8,rdi
  1ef49d:	mov    rax,rbp
  1ef4a0:	mul    r13
  1ef4a3:	jno    1ef381 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbf1>
  1ef4a9:	mov    rax,QWORD PTR [rip+0x35af60]        # 54a410 <_DYNAMIC+0x638>
  1ef4b0:	mov    rax,QWORD PTR [rax]
  1ef4b3:	jmp    1ef3ab <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc1b>
