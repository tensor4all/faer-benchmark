
target/faer-rev/af8273f5a76f-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000000f6ef0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
   f6ef0:	push   rbp
   f6ef1:	push   r15
   f6ef3:	push   r14
   f6ef5:	push   r13
   f6ef7:	push   r12
   f6ef9:	push   rbx
   f6efa:	sub    rsp,0x108
   f6f01:	mov    DWORD PTR [rsp+0x30],esi
   f6f05:	mov    r12,QWORD PTR [rdi+0x8]
   f6f09:	test   r12,r12
   f6f0c:	je     f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f6f12:	mov    r15,QWORD PTR [rdi+0x10]
   f6f16:	test   r15,r15
   f6f19:	je     f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f6f1f:	mov    rbx,QWORD PTR [rdi]
   f6f22:	mov    r14,QWORD PTR [rdi+0x18]
   f6f26:	mov    rax,QWORD PTR [rdi+0x20]
   f6f2a:	mov    QWORD PTR [rsp+0x8],rax
   f6f2f:	mov    r13,QWORD PTR [rdx+0x10]
   f6f33:	test   r13,r13
   f6f36:	je     f6fee <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
   f6f3c:	mov    r11,r8
   f6f3f:	mov    DWORD PTR [rsp+0x38],ecx
   f6f43:	mov    rax,QWORD PTR [rdx]
   f6f46:	mov    QWORD PTR [rsp+0x10],rax
   f6f4b:	mov    rcx,QWORD PTR [rdx+0x8]
   f6f4f:	mov    r8,QWORD PTR [rdx+0x18]
   f6f53:	test   r14,r14
   f6f56:	mov    QWORD PTR [rsp+0x20],rcx
   f6f5b:	jns    f6f99 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
   f6f5d:	lea    rax,[r12-0x1]
   f6f62:	imul   rax,r14
   f6f66:	neg    r14
   f6f69:	xor    edi,edi
   f6f6b:	mov    r10,rcx
   f6f6e:	sub    r10,0x1
   f6f72:	cmovb  r10,rdi
   f6f76:	lea    rbx,[rbx+rax*8]
   f6f7a:	mov    rax,r8
   f6f7d:	imul   rax,r10
   f6f81:	cmp    r10,rcx
   f6f84:	cmove  rax,rdi
   f6f88:	mov    rcx,QWORD PTR [rsp+0x10]
   f6f8d:	lea    rcx,[rcx+rax*8]
   f6f91:	mov    QWORD PTR [rsp+0x10],rcx
   f6f96:	neg    r8
   f6f99:	mov    QWORD PTR [rsp+0x28],r8
   f6f9e:	mov    rdi,QWORD PTR [rdx+0x20]
   f6fa2:	mov    r8,QWORD PTR [r11]
   f6fa5:	mov    rax,QWORD PTR [r11+0x8]
   f6fa9:	mov    QWORD PTR [rsp+0x18],rax
   f6fae:	mov    rcx,QWORD PTR [r11+0x10]
   f6fb2:	mov    rax,QWORD PTR [r11+0x20]
   f6fb6:	cmp    QWORD PTR [rsp+0x8],0x0
   f6fbc:	js     f7045 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
   f6fc2:	mov    rsi,QWORD PTR [r11+0x18]
   f6fc6:	test   rdi,rdi
   f6fc9:	js     f70b1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
   f6fcf:	mov    r10,QWORD PTR [rsp+0x148]
   f6fd7:	mov    r11,QWORD PTR [rsp+0x140]
   f6fdf:	cmp    r15,0x1
   f6fe3:	je     f7136 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
   f6fe9:	jmp    f7224 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
   f6fee:	cmp    BYTE PTR [rsp+0x30],0x0
   f6ff3:	jne    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f6ff9:	cmp    r12,0x1
   f6ffd:	je     f7013 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
   f6fff:	cmp    r14,0xffffffffffffffff
   f7003:	je     f7774 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
   f7009:	cmp    r14,0x1
   f700d:	je     f753d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64d>
   f7013:	cmp    r15,0x1
   f7017:	je     f7533 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
   f701d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
   f7023:	je     f78fa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0a>
   f7029:	cmp    QWORD PTR [rsp+0x8],0x1
   f702f:	jne    f7533 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
   f7035:	mov    rax,r15
   f7038:	mov    r15,r12
   f703b:	mov    QWORD PTR [rsp+0x8],r14
   f7040:	jmp    f7911 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
   f7045:	lea    rdx,[r15-0x1]
   f7049:	mov    rsi,QWORD PTR [rsp+0x8]
   f704e:	imul   rdx,rsi
   f7052:	lea    rbx,[rbx+rdx*8]
   f7056:	neg    rsi
   f7059:	mov    QWORD PTR [rsp+0x8],rsi
   f705e:	xor    edx,edx
   f7060:	mov    r10d,r9d
   f7063:	mov    r9,r8
   f7066:	mov    r8,rdi
   f7069:	mov    rdi,rcx
   f706c:	sub    rdi,0x1
   f7070:	cmovb  rdi,rdx
   f7074:	mov    rbp,r13
   f7077:	mov    r13,rax
   f707a:	imul   r13,rdi
   f707e:	cmp    rdi,rcx
   f7081:	mov    rdi,r8
   f7084:	mov    r8,r9
   f7087:	mov    r9d,r10d
   f708a:	mov    r10,QWORD PTR [rsp+0x18]
   f708f:	cmove  r13,rdx
   f7093:	test   r10,r10
   f7096:	cmove  r13,r10
   f709a:	lea    r8,[r8+r13*8]
   f709e:	mov    r13,rbp
   f70a1:	neg    rax
   f70a4:	mov    rsi,QWORD PTR [r11+0x18]
   f70a8:	test   rdi,rdi
   f70ab:	jns    f6fcf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
   f70b1:	lea    rdx,[r13-0x1]
   f70b5:	imul   rdx,rdi
   f70b9:	mov    r10,QWORD PTR [rsp+0x20]
   f70be:	test   r10,r10
   f70c1:	cmove  rdx,r10
   f70c5:	mov    r10,rax
   f70c8:	mov    rax,QWORD PTR [rsp+0x10]
   f70cd:	lea    rax,[rax+rdx*8]
   f70d1:	mov    QWORD PTR [rsp+0x10],rax
   f70d6:	neg    rdi
   f70d9:	xor    edx,edx
   f70db:	mov    rax,rdi
   f70de:	mov    rbp,r13
   f70e1:	mov    r13,rsi
   f70e4:	mov    rsi,QWORD PTR [rsp+0x18]
   f70e9:	mov    rdi,rsi
   f70ec:	sub    rdi,0x1
   f70f0:	cmovb  rdi,rdx
   f70f4:	mov    r11,r13
   f70f7:	imul   r11,rdi
   f70fb:	test   rcx,rcx
   f70fe:	cmove  r11,rcx
   f7102:	cmp    rdi,rsi
   f7105:	mov    rsi,r13
   f7108:	mov    r13,rbp
   f710b:	mov    rdi,rax
   f710e:	mov    rax,r10
   f7111:	cmove  r11,rdx
   f7115:	lea    r8,[r8+r11*8]
   f7119:	neg    rsi
   f711c:	mov    r10,QWORD PTR [rsp+0x148]
   f7124:	mov    r11,QWORD PTR [rsp+0x140]
   f712c:	cmp    r15,0x1
   f7130:	jne    f7224 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
   f7136:	cmp    QWORD PTR [rsp+0x28],0x1
   f713c:	jne    f71af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
   f713e:	cmp    r14,0x1
   f7142:	jne    f71af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
   f7144:	test   rbx,rbx
   f7147:	je     f71af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
   f7149:	mov    rax,QWORD PTR [rsp+0x10]
   f714e:	mov    QWORD PTR [rsp+0x78],rax
   f7153:	mov    rax,QWORD PTR [rsp+0x20]
   f7158:	mov    QWORD PTR [rsp+0x80],rax
   f7160:	mov    QWORD PTR [rsp+0x88],r13
   f7168:	mov    QWORD PTR [rsp+0x90],rdi
   f7170:	mov    QWORD PTR [rsp+0x60],r8
   f7175:	mov    rax,QWORD PTR [rsp+0x18]
   f717a:	mov    QWORD PTR [rsp+0x68],rax
   f717f:	mov    QWORD PTR [rsp+0x70],rsi
   f7184:	sub    rsp,0x8
   f7188:	movzx  eax,r9b
   f718c:	movzx  edx,BYTE PTR [rsp+0x38]
   f7191:	movzx  r8d,BYTE PTR [rsp+0x40]
   f7197:	lea    rcx,[rsp+0x80]
   f719f:	lea    r9,[rsp+0x68]
   f71a4:	mov    rdi,rbx
   f71a7:	mov    rsi,r12
   f71aa:	jmp    f72a0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
   f71af:	cmp    rdi,0x1
   f71b3:	jne    f7224 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
   f71b5:	cmp    rsi,0x1
   f71b9:	jne    f7224 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
   f71bb:	test   r8,r8
   f71be:	je     f7224 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
   f71c0:	mov    rax,QWORD PTR [rsp+0x10]
   f71c5:	mov    QWORD PTR [rsp+0x78],rax
   f71ca:	mov    rax,QWORD PTR [rsp+0x20]
   f71cf:	mov    QWORD PTR [rsp+0x80],rax
   f71d7:	mov    QWORD PTR [rsp+0x88],r13
   f71df:	mov    rax,QWORD PTR [rsp+0x28]
   f71e4:	mov    QWORD PTR [rsp+0x90],rax
   f71ec:	mov    QWORD PTR [rsp+0x60],rbx
   f71f1:	mov    QWORD PTR [rsp+0x68],r12
   f71f6:	mov    QWORD PTR [rsp+0x70],r14
   f71fb:	sub    rsp,0x8
   f71ff:	movzx  eax,r9b
   f7203:	movzx  esi,BYTE PTR [rsp+0x38]
   f7208:	movzx  ecx,BYTE PTR [rsp+0x40]
   f720d:	lea    rdi,[rsp+0x68]
   f7212:	lea    rdx,[rsp+0x80]
   f721a:	mov    r9,QWORD PTR [rsp+0x20]
   f721f:	jmp    f7327 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
   f7224:	cmp    r12,0x1
   f7228:	jne    f733a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
   f722e:	xor    edx,edx
   f7230:	cmp    QWORD PTR [rsp+0x8],0x1
   f7236:	cmove  rdx,rbx
   f723a:	cmp    rax,0x1
   f723e:	jne    f72b3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
   f7240:	test   rdx,rdx
   f7243:	je     f72b3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
   f7245:	mov    QWORD PTR [rsp+0x78],r8
   f724a:	mov    QWORD PTR [rsp+0x80],rcx
   f7252:	mov    rax,QWORD PTR [rsp+0x18]
   f7257:	mov    QWORD PTR [rsp+0x88],rax
   f725f:	mov    QWORD PTR [rsp+0x90],rsi
   f7267:	mov    rax,QWORD PTR [rsp+0x10]
   f726c:	mov    QWORD PTR [rsp+0x60],rax
   f7271:	mov    QWORD PTR [rsp+0x68],r13
   f7276:	mov    QWORD PTR [rsp+0x70],rdi
   f727b:	sub    rsp,0x8
   f727f:	movzx  eax,BYTE PTR [rsp+0x40]
   f7284:	movzx  edx,BYTE PTR [rsp+0x38]
   f7289:	movzx  r8d,r9b
   f728d:	lea    rcx,[rsp+0x80]
   f7295:	lea    r9,[rsp+0x68]
   f729a:	mov    rdi,rbx
   f729d:	mov    rsi,r15
   f72a0:	push   r10
   f72a2:	push   r11
   f72a4:	push   rax
   f72a5:	call   1475f0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
   f72aa:	add    rsp,0x20
   f72ae:	jmp    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f72b3:	xor    edx,edx
   f72b5:	cmp    rdi,0x1
   f72b9:	cmove  rdx,QWORD PTR [rsp+0x10]
   f72bf:	cmp    rsi,0x1
   f72c3:	jne    f733a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
   f72c5:	test   rdx,rdx
   f72c8:	je     f733a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
   f72ca:	mov    QWORD PTR [rsp+0x78],r8
   f72cf:	mov    QWORD PTR [rsp+0x80],rcx
   f72d7:	mov    rcx,QWORD PTR [rsp+0x18]
   f72dc:	mov    QWORD PTR [rsp+0x88],rcx
   f72e4:	mov    QWORD PTR [rsp+0x90],rax
   f72ec:	mov    QWORD PTR [rsp+0x60],rbx
   f72f1:	mov    QWORD PTR [rsp+0x68],r15
   f72f6:	mov    rax,QWORD PTR [rsp+0x8]
   f72fb:	mov    QWORD PTR [rsp+0x70],rax
   f7300:	sub    rsp,0x8
   f7304:	movzx  eax,BYTE PTR [rsp+0x40]
   f7309:	movzx  esi,BYTE PTR [rsp+0x38]
   f730e:	movzx  ecx,r9b
   f7312:	lea    rdi,[rsp+0x68]
   f7317:	lea    rdx,[rsp+0x80]
   f731f:	mov    r8,QWORD PTR [rsp+0x18]
   f7324:	mov    r9,r13
   f7327:	push   r10
   f7329:	push   r11
   f732b:	push   rax
   f732c:	call   1f7530 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
   f7331:	add    rsp,0x20
   f7335:	jmp    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f733a:	cmp    r13,0x1
   f733e:	jne    f7448 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
   f7344:	xor    edx,edx
   f7346:	cmp    r14,0x1
   f734a:	cmove  rdx,rbx
   f734e:	cmp    QWORD PTR [rsp+0x28],0x1
   f7354:	jne    f73bd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
   f7356:	test   rdx,rdx
   f7359:	je     f73bd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
   f735b:	mov    QWORD PTR [rsp+0x78],rdx
   f7360:	mov    QWORD PTR [rsp+0x80],r12
   f7368:	mov    QWORD PTR [rsp+0x88],r15
   f7370:	mov    rdx,QWORD PTR [rsp+0x8]
   f7375:	mov    QWORD PTR [rsp+0x90],rdx
   f737d:	mov    QWORD PTR [rsp+0x60],r8
   f7382:	mov    QWORD PTR [rsp+0x68],rcx
   f7387:	mov    QWORD PTR [rsp+0x70],rax
   f738c:	sub    rsp,0x8
   f7390:	mov    r14,r10
   f7393:	movzx  r10d,r9b
   f7397:	movzx  esi,BYTE PTR [rsp+0x38]
   f739c:	movzx  r8d,BYTE PTR [rsp+0x40]
   f73a2:	lea    rdi,[rsp+0x80]
   f73aa:	lea    r9,[rsp+0x68]
   f73af:	mov    rdx,QWORD PTR [rsp+0x18]
   f73b4:	mov    rcx,QWORD PTR [rsp+0x28]
   f73b9:	push   r14
   f73bb:	jmp    f7436 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
   f73bd:	xor    edx,edx
   f73bf:	cmp    QWORD PTR [rsp+0x8],0x1
   f73c5:	cmove  rdx,rbx
   f73c9:	cmp    rax,0x1
   f73cd:	jne    f7448 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
   f73cf:	test   rdx,rdx
   f73d2:	je     f7448 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
   f73d4:	mov    QWORD PTR [rsp+0x78],rdx
   f73d9:	mov    QWORD PTR [rsp+0x80],r15
   f73e1:	mov    QWORD PTR [rsp+0x88],r12
   f73e9:	mov    QWORD PTR [rsp+0x90],r14
   f73f1:	mov    rax,QWORD PTR [rsp+0x10]
   f73f6:	mov    QWORD PTR [rsp+0x60],rax
   f73fb:	mov    rax,QWORD PTR [rsp+0x20]
   f7400:	mov    QWORD PTR [rsp+0x68],rax
   f7405:	mov    rax,QWORD PTR [rsp+0x28]
   f740a:	mov    QWORD PTR [rsp+0x70],rax
   f740f:	sub    rsp,0x8
   f7413:	mov    rax,r10
   f7416:	movzx  r10d,BYTE PTR [rsp+0x40]
   f741c:	movzx  esi,BYTE PTR [rsp+0x38]
   f7421:	mov    rdx,r8
   f7424:	movzx  r8d,r9b
   f7428:	lea    rdi,[rsp+0x80]
   f7430:	lea    r9,[rsp+0x68]
   f7435:	push   rax
   f7436:	push   r11
   f7438:	push   r10
   f743a:	call   145470 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
   f743f:	add    rsp,0x20
   f7443:	jmp    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f7448:	mov    QWORD PTR [rsp+0x18],rax
   f744d:	movsd  xmm1,QWORD PTR [r11]
   f7452:	movsd  QWORD PTR [rsp+0x60],xmm1
   f7458:	mov    rax,r12
   f745b:	mul    r15
   f745e:	mov    rbp,rax
   f7461:	jo     f7995 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
   f7467:	mul    r13
   f746a:	seto   cl
   f746d:	not    cl
   f746f:	cmp    rax,0x1001
   f7475:	setb   al
   f7478:	test   cl,al
   f747a:	jne    f74d7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5e7>
   f747c:	mov    rdx,QWORD PTR [rip+0x4547fd]        # 54bc80 <_DYNAMIC+0x498>
   f7483:	mov    rax,QWORD PTR [rdx]
   f7486:	test   rax,rax
   f7489:	je     f79a1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
   f748f:	mov    cl,0x1
   f7491:	test   eax,0x80000
   f7496:	jne    f7aa2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
   f749c:	mov    rax,QWORD PTR [rdx]
   f749f:	test   rax,rax
   f74a2:	je     f79fc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb0c>
   f74a8:	test   ax,ax
   f74ab:	jns    f74c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
   f74ad:	mov    rax,QWORD PTR [rdx]
   f74b0:	test   rax,rax
   f74b3:	je     f7a53 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb63>
   f74b9:	bt     rax,0x37
   f74be:	jb     f7aa0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb0>
   f74c4:	cmp    BYTE PTR [rsp+0x30],0x0
   f74c9:	jne    f777c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
   f74cf:	xorps  xmm0,xmm0
   f74d2:	jmp    f7784 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
   f74d7:	cmp    BYTE PTR [rsp+0x30],0x0
   f74dc:	mov    ecx,DWORD PTR [rsp+0x38]
   f74e0:	jne    f7545 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x655>
   f74e2:	xorps  xmm0,xmm0
   f74e5:	movsd  QWORD PTR [rsp+0x30],xmm0
   f74eb:	mov    rax,r13
   f74ee:	cmp    QWORD PTR [rsp+0x8],r14
   f74f3:	jb     f755d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66d>
   f74f5:	mov    ebp,r9d
   f74f8:	mov    r9d,ecx
   f74fb:	mov    rcx,QWORD PTR [rsp+0x18]
   f7500:	mov    QWORD PTR [rsp+0x38],rcx
   f7505:	mov    QWORD PTR [rsp+0x40],rsi
   f750a:	mov    QWORD PTR [rsp+0x58],r8
   f750f:	mov    rsi,rdi
   f7512:	mov    rcx,QWORD PTR [rsp+0x28]
   f7517:	mov    r8,QWORD PTR [rsp+0x10]
   f751c:	mov    rdx,QWORD PTR [rsp+0x8]
   f7521:	mov    QWORD PTR [rsp+0x10],rdx
   f7526:	mov    QWORD PTR [rsp+0x8],r14
   f752b:	mov    r13,r15
   f752e:	mov    r15,r12
   f7531:	jmp    f7585 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x695>
   f7533:	cmp    r14,0x1
   f7537:	jne    f76b6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c6>
   f753d:	mov    rax,r12
   f7540:	jmp    f7911 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
   f7545:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff4868b]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
   f754d:	movsd  QWORD PTR [rsp+0x30],xmm0
   f7553:	mov    rax,r13
   f7556:	cmp    QWORD PTR [rsp+0x8],r14
   f755b:	jae    f74f5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x605>
   f755d:	mov    ebp,ecx
   f755f:	mov    rcx,QWORD PTR [rsp+0x28]
   f7564:	mov    QWORD PTR [rsp+0x38],rcx
   f7569:	mov    QWORD PTR [rsp+0x40],rdi
   f756e:	mov    rcx,QWORD PTR [rsp+0x10]
   f7573:	mov    QWORD PTR [rsp+0x58],rcx
   f7578:	mov    QWORD PTR [rsp+0x10],r14
   f757d:	mov    r13,r12
   f7580:	mov    rcx,QWORD PTR [rsp+0x18]
   f7585:	movsd  QWORD PTR [rsp+0x20],xmm1
   f758b:	mov    QWORD PTR [rsp+0x48],rsi
   f7590:	mov    QWORD PTR [rsp+0x50],r8
   f7595:	mov    r14d,r9d
   f7598:	mov    QWORD PTR [rsp+0x18],rcx
   f759d:	cmp    rcx,0x1
   f75a1:	jne    f75cb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
   f75a3:	cmp    QWORD PTR [rsp+0x8],0x1
   f75a9:	jne    f75cb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
   f75ab:	lea    r8,[rip+0x43a206]        # 5317b8 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x410>
   f75b2:	lea    rdi,[rsp+0x78]
   f75b7:	mov    rsi,r15
   f75ba:	mov    rdx,r13
   f75bd:	mov    r12,rax
   f75c0:	mov    rcx,rax
   f75c3:	call   QWORD PTR [rip+0x4546ef]        # 54bcb8 <_DYNAMIC+0x4d0>
   f75c9:	jmp    f75e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f9>
   f75cb:	lea    r8,[rip+0x43a1fe]        # 5317d0 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x428>
   f75d2:	lea    rdi,[rsp+0x78]
   f75d7:	mov    rsi,r15
   f75da:	mov    rdx,r13
   f75dd:	mov    r12,rax
   f75e0:	mov    rcx,rax
   f75e3:	call   QWORD PTR [rip+0x4546d7]        # 54bcc0 <_DYNAMIC+0x4d8>
   f75e9:	lea    rdi,[rsp+0x80]
   f75f1:	mov    rsi,QWORD PTR [rsp+0xa0]
   f75f9:	mov    rdx,QWORD PTR [rsp+0xa8]
   f7601:	movups xmm0,XMMWORD PTR [rsp+0xb0]
   f7609:	sub    rsp,0x70
   f760d:	movups XMMWORD PTR [rsp+0x58],xmm0
   f7612:	movzx  eax,bpl
   f7616:	mov    DWORD PTR [rsp+0x50],eax
   f761a:	movzx  eax,r14b
   f761e:	mov    DWORD PTR [rsp+0x48],eax
   f7622:	mov    rax,QWORD PTR [rsp+0xa8]
   f762a:	mov    QWORD PTR [rsp+0x40],rax
   f762f:	mov    rax,QWORD PTR [rsp+0xb0]
   f7637:	mov    QWORD PTR [rsp+0x38],rax
   f763c:	mov    rax,QWORD PTR [rsp+0xc8]
   f7644:	mov    QWORD PTR [rsp+0x30],rax
   f7649:	mov    rax,QWORD PTR [rsp+0xb8]
   f7651:	mov    QWORD PTR [rsp+0x28],rax
   f7656:	mov    rax,QWORD PTR [rsp+0x88]
   f765e:	mov    QWORD PTR [rsp+0x20],rax
   f7663:	mov    rax,QWORD PTR [rsp+0xc0]
   f766b:	mov    QWORD PTR [rsp+0x18],rax
   f7670:	mov    rax,QWORD PTR [rsp+0x80]
   f7678:	mov    QWORD PTR [rsp+0x10],rax
   f767d:	mov    rax,QWORD PTR [rsp+0x78]
   f7682:	mov    QWORD PTR [rsp+0x8],rax
   f7687:	mov    QWORD PTR [rsp],rbx
   f768b:	mov    r8,r13
   f768e:	mov    r9,r12
   f7691:	mov    rcx,r15
   f7694:	movsd  xmm0,QWORD PTR [rsp+0xa0]
   f769d:	movsd  xmm1,QWORD PTR [rsp+0x90]
   f76a6:	call   QWORD PTR [rsp+0xe8]
   f76ad:	add    rsp,0x70
   f76b1:	jmp    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f76b6:	lea    rax,[r12-0x1]
   f76bb:	mov    ecx,r12d
   f76be:	and    ecx,0x3
   f76c1:	and    r12,0xfffffffffffffffc
   f76c5:	lea    rdx,[r14*8+0x0]
   f76cd:	lea    rsi,[rdx+rdx*2]
   f76d1:	shl    QWORD PTR [rsp+0x8],0x3
   f76d7:	mov    rdi,r14
   f76da:	shl    rdi,0x5
   f76de:	mov    r8,r14
   f76e1:	shl    r8,0x4
   f76e5:	xor    r9d,r9d
   f76e8:	jmp    f7701 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
   f76ea:	nop    WORD PTR [rax+rax*1+0x0]
   f76f0:	inc    r9
   f76f3:	add    rbx,QWORD PTR [rsp+0x8]
   f76f8:	cmp    r9,r15
   f76fb:	je     f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f7701:	cmp    rax,0x3
   f7705:	jae    f7710 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
   f7707:	xor    r10d,r10d
   f770a:	jmp    f7750 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
   f770c:	nop    DWORD PTR [rax+0x0]
   f7710:	mov    r11,rbx
   f7713:	xor    r10d,r10d
   f7716:	cs nop WORD PTR [rax+rax*1+0x0]
   f7720:	mov    QWORD PTR [r11],0x0
   f7727:	mov    QWORD PTR [r11+r14*8],0x0
   f772f:	mov    QWORD PTR [r11+r8*1],0x0
   f7737:	add    r10,0x4
   f773b:	mov    QWORD PTR [r11+rsi*1],0x0
   f7743:	add    r11,rdi
   f7746:	cmp    r12,r10
   f7749:	jne    f7720 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
   f774b:	test   rcx,rcx
   f774e:	je     f76f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
   f7750:	imul   r10,rdx
   f7754:	add    r10,rbx
   f7757:	mov    r11,rcx
   f775a:	nop    WORD PTR [rax+rax*1+0x0]
   f7760:	mov    QWORD PTR [r10],0x0
   f7767:	add    r10,rdx
   f776a:	dec    r11
   f776d:	jne    f7760 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
   f776f:	jmp    f76f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
   f7774:	mov    rax,r12
   f7777:	jmp    f7905 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa15>
   f777c:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff48454]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
   f7784:	xor    r11d,r11d
   f7787:	test   r10,r10
   f778a:	setne  dl
   f778d:	cmp    QWORD PTR [rsp+0x8],r14
   f7792:	jge    f77a9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b9>
   f7794:	mov    rcx,QWORD PTR [rsp+0x18]
   f7799:	mov    rbp,rsi
   f779c:	mov    rax,r8
   f779f:	mov    r8,r14
   f77a2:	mov    r9,QWORD PTR [rsp+0x28]
   f77a7:	jmp    f77e3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f3>
   f77a9:	mov    rcx,QWORD PTR [rsp+0x28]
   f77ae:	mov    rbp,rdi
   f77b1:	mov    rax,QWORD PTR [rsp+0x10]
   f77b6:	mov    QWORD PTR [rsp+0x28],rax
   f77bb:	mov    r10,QWORD PTR [rsp+0x8]
   f77c0:	mov    rax,r12
   f77c3:	mov    r9,QWORD PTR [rsp+0x18]
   f77c8:	mov    rdi,rsi
   f77cb:	mov    QWORD PTR [rsp+0x10],r8
   f77d0:	mov    r8,r10
   f77d3:	mov    QWORD PTR [rsp+0x8],r14
   f77d8:	mov    r12,r15
   f77db:	mov    r15,rax
   f77de:	mov    rax,QWORD PTR [rsp+0x28]
   f77e3:	mov    r11b,dl
   f77e6:	mov    QWORD PTR [rsp+0x18],r15
   f77eb:	lea    rdx,[r15-0x1]
   f77ef:	imul   rdx,rcx
   f77f3:	mov    r14,rcx
   f77f6:	neg    r14
   f77f9:	mov    rsi,QWORD PTR [rsp+0x8]
   f77fe:	test   rsi,rsi
   f7801:	cmovns r14,rcx
   f7805:	mov    rcx,rsi
   f7808:	sar    rcx,0x3f
   f780c:	and    rcx,rdx
   f780f:	lea    rdx,[rax+rcx*8]
   f7813:	lea    rax,[r12-0x1]
   f7818:	imul   rax,r9
   f781c:	mov    r15,r9
   f781f:	neg    r15
   f7822:	test   r8,r8
   f7825:	cmovns r15,r9
   f7829:	mov    rcx,r8
   f782c:	sar    rcx,0x3f
   f7830:	and    rcx,rax
   f7833:	mov    rax,QWORD PTR [rsp+0x10]
   f7838:	lea    rsi,[rax+rcx*8]
   f783c:	test   rbp,rbp
   f783f:	jns    f785e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x96e>
   f7841:	lea    rax,[r13-0x1]
   f7845:	mov    rcx,rbp
   f7848:	imul   rcx,rax
   f784c:	lea    rdx,[rdx+rcx*8]
   f7850:	neg    rbp
   f7853:	imul   rax,rdi
   f7857:	lea    rsi,[rsi+rax*8]
   f785b:	neg    rdi
   f785e:	mov    QWORD PTR [rsp+0x28],rsi
   f7863:	mov    QWORD PTR [rsp+0x10],rdx
   f7868:	mov    QWORD PTR [rsp+0x40],rdi
   f786d:	mov    rax,QWORD PTR [rip+0x454454]        # 54bcc8 <_DYNAMIC+0x4e0>
   f7874:	mov    rax,QWORD PTR [rax]
   f7877:	test   rax,rax
   f787a:	jne    f78b4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c4>
   f787c:	movsd  QWORD PTR [rsp+0x20],xmm1
   f7882:	movsd  QWORD PTR [rsp+0x38],xmm0
   f7888:	mov    QWORD PTR [rsp+0x50],rbp
   f788d:	mov    rbp,r11
   f7890:	mov    QWORD PTR [rsp+0x48],r8
   f7895:	call   QWORD PTR [rip+0x454435]        # 54bcd0 <_DYNAMIC+0x4e8>
   f789b:	mov    r8,QWORD PTR [rsp+0x48]
   f78a0:	mov    r11,rbp
   f78a3:	mov    rbp,QWORD PTR [rsp+0x50]
   f78a8:	movsd  xmm0,QWORD PTR [rsp+0x38]
   f78ae:	movsd  xmm1,QWORD PTR [rsp+0x20]
   f78b4:	movzx  r10d,BYTE PTR [rsp+0x30]
   f78ba:	mov    rdi,QWORD PTR [rsp+0x18]
   f78bf:	mov    rsi,r12
   f78c2:	mov    rdx,r13
   f78c5:	mov    rcx,rbx
   f78c8:	mov    r9,QWORD PTR [rsp+0x8]
   f78cd:	push   QWORD PTR [rsp+0x148]
   f78d4:	push   r11
   f78d6:	push   0x0
   f78d8:	push   0x0
   f78da:	push   0x0
   f78dc:	push   QWORD PTR [rsp+0x68]
   f78e0:	push   r15
   f78e2:	push   QWORD PTR [rsp+0x60]
   f78e6:	push   r14
   f78e8:	push   rbp
   f78e9:	push   QWORD PTR [rsp+0x60]
   f78ed:	push   r10
   f78ef:	call   rax
   f78f1:	add    rsp,0x60
   f78f5:	jmp    f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f78fa:	mov    rax,r15
   f78fd:	mov    r15,r12
   f7900:	mov    QWORD PTR [rsp+0x8],r14
   f7905:	mov    ecx,0x1
   f790a:	sub    rcx,rax
   f790d:	lea    rbx,[rbx+rcx*8]
   f7911:	lea    rcx,[rax-0x1]
   f7915:	mov    edx,eax
   f7917:	and    edx,0x3
   f791a:	and    rax,0xfffffffffffffffc
   f791e:	xor    esi,esi
   f7920:	xorps  xmm0,xmm0
   f7923:	jmp    f793c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
   f7925:	data16 cs nop WORD PTR [rax+rax*1+0x0]
   f7930:	inc    rsi
   f7933:	cmp    rsi,r15
   f7936:	je     f7b84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
   f793c:	mov    rdi,rsi
   f793f:	imul   rdi,QWORD PTR [rsp+0x8]
   f7945:	lea    rdi,[rbx+rdi*8]
   f7949:	cmp    rcx,0x3
   f794d:	jb     f7979 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
   f794f:	xor    r8d,r8d
   f7952:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
   f7960:	movups XMMWORD PTR [rdi],xmm0
   f7963:	movups XMMWORD PTR [rdi+0x10],xmm0
   f7967:	add    rdi,0x20
   f796b:	add    r8,0x4
   f796f:	cmp    rax,r8
   f7972:	jne    f7960 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
   f7974:	test   rdx,rdx
   f7977:	je     f7930 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
   f7979:	xor    r8d,r8d
   f797c:	nop    DWORD PTR [rax+0x0]
   f7980:	mov    QWORD PTR [rdi],0x0
   f7987:	add    rdi,0x8
   f798b:	inc    r8
   f798e:	cmp    rdx,r8
   f7991:	jne    f7980 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
   f7993:	jmp    f7930 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
   f7995:	mov    rax,0xffffffffffffffff
   f799c:	jmp    f7467 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x577>
   f79a1:	mov    DWORD PTR [rsp+0x58],r9d
   f79a6:	mov    QWORD PTR [rsp+0x40],rdi
   f79ab:	mov    QWORD PTR [rsp+0x50],r8
   f79b0:	mov    QWORD PTR [rsp+0x48],rsi
   f79b5:	movsd  QWORD PTR [rsp+0x20],xmm1
   f79bb:	call   QWORD PTR [rip+0x4542e7]        # 54bca8 <_DYNAMIC+0x4c0>
   f79c1:	mov    rdx,QWORD PTR [rip+0x4542b8]        # 54bc80 <_DYNAMIC+0x498>
   f79c8:	movsd  xmm1,QWORD PTR [rsp+0x20]
   f79ce:	mov    rsi,QWORD PTR [rsp+0x48]
   f79d3:	mov    r10,QWORD PTR [rsp+0x148]
   f79db:	mov    r8,QWORD PTR [rsp+0x50]
   f79e0:	mov    rdi,QWORD PTR [rsp+0x40]
   f79e5:	mov    r9d,DWORD PTR [rsp+0x58]
   f79ea:	mov    cl,0x1
   f79ec:	test   eax,0x80000
   f79f1:	je     f749c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ac>
   f79f7:	jmp    f7aa2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
   f79fc:	mov    DWORD PTR [rsp+0x58],r9d
   f7a01:	mov    QWORD PTR [rsp+0x40],rdi
   f7a06:	mov    QWORD PTR [rsp+0x50],r8
   f7a0b:	mov    QWORD PTR [rsp+0x48],rsi
   f7a10:	movsd  QWORD PTR [rsp+0x20],xmm1
   f7a16:	call   QWORD PTR [rip+0x45428c]        # 54bca8 <_DYNAMIC+0x4c0>
   f7a1c:	mov    rdx,QWORD PTR [rip+0x45425d]        # 54bc80 <_DYNAMIC+0x498>
   f7a23:	movsd  xmm1,QWORD PTR [rsp+0x20]
   f7a29:	mov    rsi,QWORD PTR [rsp+0x48]
   f7a2e:	mov    r10,QWORD PTR [rsp+0x148]
   f7a36:	mov    r8,QWORD PTR [rsp+0x50]
   f7a3b:	mov    rdi,QWORD PTR [rsp+0x40]
   f7a40:	mov    r9d,DWORD PTR [rsp+0x58]
   f7a45:	test   ax,ax
   f7a48:	js     f74ad <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5bd>
   f7a4e:	jmp    f74c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
   f7a53:	mov    DWORD PTR [rsp+0x58],r9d
   f7a58:	mov    QWORD PTR [rsp+0x40],rdi
   f7a5d:	mov    QWORD PTR [rsp+0x50],r8
   f7a62:	mov    QWORD PTR [rsp+0x48],rsi
   f7a67:	movsd  QWORD PTR [rsp+0x20],xmm1
   f7a6d:	call   QWORD PTR [rip+0x454235]        # 54bca8 <_DYNAMIC+0x4c0>
   f7a73:	movsd  xmm1,QWORD PTR [rsp+0x20]
   f7a79:	mov    rsi,QWORD PTR [rsp+0x48]
   f7a7e:	mov    r10,QWORD PTR [rsp+0x148]
   f7a86:	mov    r8,QWORD PTR [rsp+0x50]
   f7a8b:	mov    rdi,QWORD PTR [rsp+0x40]
   f7a90:	mov    r9d,DWORD PTR [rsp+0x58]
   f7a95:	bt     rax,0x37
   f7a9a:	jae    f74c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
   f7aa0:	xor    ecx,ecx
   f7aa2:	imul   rbp,r13
   f7aa6:	cmp    r10,0x1
   f7aaa:	adc    r10,0x0
   f7aae:	cmp    rbp,0x8000
   f7ab5:	mov    eax,0x1
   f7aba:	cmovae rax,r10
   f7abe:	sub    rsp,0xa0
   f7ac5:	lea    rdx,[rsp+0x100]
   f7acd:	mov    QWORD PTR [rsp+0x88],rdx
   f7ad5:	movzx  edx,r9b
   f7ad9:	mov    DWORD PTR [rsp+0x80],edx
   f7ae0:	mov    rdx,QWORD PTR [rsp+0xb8]
   f7ae8:	mov    QWORD PTR [rsp+0x78],rdx
   f7aed:	mov    QWORD PTR [rsp+0x70],rsi
   f7af2:	mov    QWORD PTR [rsp+0x68],r8
   f7af7:	xorps  xmm0,xmm0
   f7afa:	movups XMMWORD PTR [rsp+0x58],xmm0
   f7aff:	movzx  edx,BYTE PTR [rsp+0xd8]
   f7b07:	mov    DWORD PTR [rsp+0x50],edx
   f7b0b:	mov    QWORD PTR [rsp+0x48],rdi
   f7b10:	mov    rdx,QWORD PTR [rsp+0xc8]
   f7b18:	mov    QWORD PTR [rsp+0x40],rdx
   f7b1d:	mov    rdx,QWORD PTR [rsp+0xb0]
   f7b25:	mov    QWORD PTR [rsp+0x38],rdx
   f7b2a:	movzx  edx,BYTE PTR [rsp+0xd0]
   f7b32:	mov    DWORD PTR [rsp+0x30],edx
   f7b36:	movups XMMWORD PTR [rsp+0x18],xmm0
   f7b3b:	mov    rdx,QWORD PTR [rsp+0xa8]
   f7b43:	mov    QWORD PTR [rsp+0x10],rdx
   f7b48:	mov    QWORD PTR [rsp+0x8],r14
   f7b4d:	mov    QWORD PTR [rsp],rbx
   f7b51:	mov    QWORD PTR [rsp+0x90],rax
   f7b59:	mov    DWORD PTR [rsp+0x28],0x2
   f7b61:	movzx  edx,cl
   f7b64:	mov    r8,r15
   f7b67:	mov    edi,0x1
   f7b6c:	mov    r9,r13
   f7b6f:	mov    esi,0x1
   f7b74:	mov    rcx,r12
   f7b77:	call   QWORD PTR [rip+0x454133]        # 54bcb0 <_DYNAMIC+0x4c8>
   f7b7d:	add    rsp,0xa0
   f7b84:	add    rsp,0x108
   f7b8b:	pop    rbx
   f7b8c:	pop    r12
   f7b8e:	pop    r13
   f7b90:	pop    r14
   f7b92:	pop    r15
   f7b94:	pop    rbp
   f7b95:	ret
