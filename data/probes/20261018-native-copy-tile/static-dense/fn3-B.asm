
target/faer-rev/60de2ee06467-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001e4040 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  1e4040:	push   rbp
  1e4041:	push   r15
  1e4043:	push   r14
  1e4045:	push   r13
  1e4047:	push   r12
  1e4049:	push   rbx
  1e404a:	sub    rsp,0x108
  1e4051:	mov    DWORD PTR [rsp+0x30],esi
  1e4055:	mov    r12,QWORD PTR [rdi+0x8]
  1e4059:	test   r12,r12
  1e405c:	je     1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4062:	mov    r15,QWORD PTR [rdi+0x10]
  1e4066:	test   r15,r15
  1e4069:	je     1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e406f:	mov    rbx,QWORD PTR [rdi]
  1e4072:	mov    r14,QWORD PTR [rdi+0x18]
  1e4076:	mov    rax,QWORD PTR [rdi+0x20]
  1e407a:	mov    QWORD PTR [rsp+0x8],rax
  1e407f:	mov    r13,QWORD PTR [rdx+0x10]
  1e4083:	test   r13,r13
  1e4086:	je     1e413e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  1e408c:	mov    r11,r8
  1e408f:	mov    DWORD PTR [rsp+0x18],ecx
  1e4093:	mov    rax,QWORD PTR [rdx]
  1e4096:	mov    QWORD PTR [rsp+0x10],rax
  1e409b:	mov    rcx,QWORD PTR [rdx+0x8]
  1e409f:	mov    r8,QWORD PTR [rdx+0x18]
  1e40a3:	test   r14,r14
  1e40a6:	mov    QWORD PTR [rsp+0x28],rcx
  1e40ab:	jns    1e40e9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  1e40ad:	lea    rax,[r12-0x1]
  1e40b2:	imul   rax,r14
  1e40b6:	neg    r14
  1e40b9:	xor    edi,edi
  1e40bb:	mov    r10,rcx
  1e40be:	sub    r10,0x1
  1e40c2:	cmovb  r10,rdi
  1e40c6:	lea    rbx,[rbx+rax*8]
  1e40ca:	mov    rax,r8
  1e40cd:	imul   rax,r10
  1e40d1:	cmp    r10,rcx
  1e40d4:	cmove  rax,rdi
  1e40d8:	mov    rcx,QWORD PTR [rsp+0x10]
  1e40dd:	lea    rcx,[rcx+rax*8]
  1e40e1:	mov    QWORD PTR [rsp+0x10],rcx
  1e40e6:	neg    r8
  1e40e9:	mov    QWORD PTR [rsp+0x38],r8
  1e40ee:	mov    rdi,QWORD PTR [rdx+0x20]
  1e40f2:	mov    r8,QWORD PTR [r11]
  1e40f5:	mov    rax,QWORD PTR [r11+0x8]
  1e40f9:	mov    QWORD PTR [rsp+0x20],rax
  1e40fe:	mov    rcx,QWORD PTR [r11+0x10]
  1e4102:	mov    rax,QWORD PTR [r11+0x20]
  1e4106:	cmp    QWORD PTR [rsp+0x8],0x0
  1e410c:	js     1e4195 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  1e4112:	mov    rsi,QWORD PTR [r11+0x18]
  1e4116:	test   rdi,rdi
  1e4119:	js     1e4201 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  1e411f:	mov    r10,QWORD PTR [rsp+0x148]
  1e4127:	mov    r11,QWORD PTR [rsp+0x140]
  1e412f:	cmp    r15,0x1
  1e4133:	je     1e4286 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  1e4139:	jmp    1e4374 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e413e:	cmp    BYTE PTR [rsp+0x30],0x0
  1e4143:	jne    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4149:	cmp    r12,0x1
  1e414d:	je     1e4163 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  1e414f:	cmp    r14,0xffffffffffffffff
  1e4153:	je     1e48c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  1e4159:	cmp    r14,0x1
  1e415d:	je     1e468e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64e>
  1e4163:	cmp    r15,0x1
  1e4167:	je     1e4684 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  1e416d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  1e4173:	je     1e4a47 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa07>
  1e4179:	cmp    QWORD PTR [rsp+0x8],0x1
  1e417f:	jne    1e4684 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  1e4185:	mov    rax,r15
  1e4188:	mov    r15,r12
  1e418b:	mov    QWORD PTR [rsp+0x8],r14
  1e4190:	jmp    1e4a5e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  1e4195:	lea    rdx,[r15-0x1]
  1e4199:	mov    rsi,QWORD PTR [rsp+0x8]
  1e419e:	imul   rdx,rsi
  1e41a2:	lea    rbx,[rbx+rdx*8]
  1e41a6:	neg    rsi
  1e41a9:	mov    QWORD PTR [rsp+0x8],rsi
  1e41ae:	xor    edx,edx
  1e41b0:	mov    r10d,r9d
  1e41b3:	mov    r9,r8
  1e41b6:	mov    r8,rdi
  1e41b9:	mov    rdi,rcx
  1e41bc:	sub    rdi,0x1
  1e41c0:	cmovb  rdi,rdx
  1e41c4:	mov    rbp,r13
  1e41c7:	mov    r13,rax
  1e41ca:	imul   r13,rdi
  1e41ce:	cmp    rdi,rcx
  1e41d1:	mov    rdi,r8
  1e41d4:	mov    r8,r9
  1e41d7:	mov    r9d,r10d
  1e41da:	mov    r10,QWORD PTR [rsp+0x20]
  1e41df:	cmove  r13,rdx
  1e41e3:	test   r10,r10
  1e41e6:	cmove  r13,r10
  1e41ea:	lea    r8,[r8+r13*8]
  1e41ee:	mov    r13,rbp
  1e41f1:	neg    rax
  1e41f4:	mov    rsi,QWORD PTR [r11+0x18]
  1e41f8:	test   rdi,rdi
  1e41fb:	jns    1e411f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  1e4201:	lea    rdx,[r13-0x1]
  1e4205:	imul   rdx,rdi
  1e4209:	mov    r10,QWORD PTR [rsp+0x28]
  1e420e:	test   r10,r10
  1e4211:	cmove  rdx,r10
  1e4215:	mov    r10,rax
  1e4218:	mov    rax,QWORD PTR [rsp+0x10]
  1e421d:	lea    rax,[rax+rdx*8]
  1e4221:	mov    QWORD PTR [rsp+0x10],rax
  1e4226:	neg    rdi
  1e4229:	xor    edx,edx
  1e422b:	mov    rax,rdi
  1e422e:	mov    rbp,r13
  1e4231:	mov    r13,rsi
  1e4234:	mov    rsi,QWORD PTR [rsp+0x20]
  1e4239:	mov    rdi,rsi
  1e423c:	sub    rdi,0x1
  1e4240:	cmovb  rdi,rdx
  1e4244:	mov    r11,r13
  1e4247:	imul   r11,rdi
  1e424b:	test   rcx,rcx
  1e424e:	cmove  r11,rcx
  1e4252:	cmp    rdi,rsi
  1e4255:	mov    rsi,r13
  1e4258:	mov    r13,rbp
  1e425b:	mov    rdi,rax
  1e425e:	mov    rax,r10
  1e4261:	cmove  r11,rdx
  1e4265:	lea    r8,[r8+r11*8]
  1e4269:	neg    rsi
  1e426c:	mov    r10,QWORD PTR [rsp+0x148]
  1e4274:	mov    r11,QWORD PTR [rsp+0x140]
  1e427c:	cmp    r15,0x1
  1e4280:	jne    1e4374 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e4286:	cmp    QWORD PTR [rsp+0x38],0x1
  1e428c:	jne    1e42ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e428e:	cmp    r14,0x1
  1e4292:	jne    1e42ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e4294:	test   rbx,rbx
  1e4297:	je     1e42ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1e4299:	mov    rax,QWORD PTR [rsp+0x10]
  1e429e:	mov    QWORD PTR [rsp+0x78],rax
  1e42a3:	mov    rax,QWORD PTR [rsp+0x28]
  1e42a8:	mov    QWORD PTR [rsp+0x80],rax
  1e42b0:	mov    QWORD PTR [rsp+0x88],r13
  1e42b8:	mov    QWORD PTR [rsp+0x90],rdi
  1e42c0:	mov    QWORD PTR [rsp+0x60],r8
  1e42c5:	mov    rax,QWORD PTR [rsp+0x20]
  1e42ca:	mov    QWORD PTR [rsp+0x68],rax
  1e42cf:	mov    QWORD PTR [rsp+0x70],rsi
  1e42d4:	sub    rsp,0x8
  1e42d8:	movzx  eax,r9b
  1e42dc:	movzx  edx,BYTE PTR [rsp+0x38]
  1e42e1:	movzx  r8d,BYTE PTR [rsp+0x20]
  1e42e7:	lea    rcx,[rsp+0x80]
  1e42ef:	lea    r9,[rsp+0x68]
  1e42f4:	mov    rdi,rbx
  1e42f7:	mov    rsi,r12
  1e42fa:	jmp    1e43f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  1e42ff:	cmp    rdi,0x1
  1e4303:	jne    1e4374 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e4305:	cmp    rsi,0x1
  1e4309:	jne    1e4374 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e430b:	test   r8,r8
  1e430e:	je     1e4374 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1e4310:	mov    rax,QWORD PTR [rsp+0x10]
  1e4315:	mov    QWORD PTR [rsp+0x78],rax
  1e431a:	mov    rax,QWORD PTR [rsp+0x28]
  1e431f:	mov    QWORD PTR [rsp+0x80],rax
  1e4327:	mov    QWORD PTR [rsp+0x88],r13
  1e432f:	mov    rax,QWORD PTR [rsp+0x38]
  1e4334:	mov    QWORD PTR [rsp+0x90],rax
  1e433c:	mov    QWORD PTR [rsp+0x60],rbx
  1e4341:	mov    QWORD PTR [rsp+0x68],r12
  1e4346:	mov    QWORD PTR [rsp+0x70],r14
  1e434b:	sub    rsp,0x8
  1e434f:	movzx  eax,r9b
  1e4353:	movzx  esi,BYTE PTR [rsp+0x38]
  1e4358:	movzx  ecx,BYTE PTR [rsp+0x20]
  1e435d:	lea    rdi,[rsp+0x68]
  1e4362:	lea    rdx,[rsp+0x80]
  1e436a:	mov    r9,QWORD PTR [rsp+0x28]
  1e436f:	jmp    1e4477 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  1e4374:	cmp    r12,0x1
  1e4378:	jne    1e448a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e437e:	xor    edx,edx
  1e4380:	cmp    QWORD PTR [rsp+0x8],0x1
  1e4386:	cmove  rdx,rbx
  1e438a:	cmp    rax,0x1
  1e438e:	jne    1e4403 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1e4390:	test   rdx,rdx
  1e4393:	je     1e4403 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1e4395:	mov    QWORD PTR [rsp+0x78],r8
  1e439a:	mov    QWORD PTR [rsp+0x80],rcx
  1e43a2:	mov    rax,QWORD PTR [rsp+0x20]
  1e43a7:	mov    QWORD PTR [rsp+0x88],rax
  1e43af:	mov    QWORD PTR [rsp+0x90],rsi
  1e43b7:	mov    rax,QWORD PTR [rsp+0x10]
  1e43bc:	mov    QWORD PTR [rsp+0x60],rax
  1e43c1:	mov    QWORD PTR [rsp+0x68],r13
  1e43c6:	mov    QWORD PTR [rsp+0x70],rdi
  1e43cb:	sub    rsp,0x8
  1e43cf:	movzx  eax,BYTE PTR [rsp+0x20]
  1e43d4:	movzx  edx,BYTE PTR [rsp+0x38]
  1e43d9:	movzx  r8d,r9b
  1e43dd:	lea    rcx,[rsp+0x80]
  1e43e5:	lea    r9,[rsp+0x68]
  1e43ea:	mov    rdi,rbx
  1e43ed:	mov    rsi,r15
  1e43f0:	push   r10
  1e43f2:	push   r11
  1e43f4:	push   rax
  1e43f5:	call   14f070 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  1e43fa:	add    rsp,0x20
  1e43fe:	jmp    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4403:	xor    edx,edx
  1e4405:	cmp    rdi,0x1
  1e4409:	cmove  rdx,QWORD PTR [rsp+0x10]
  1e440f:	cmp    rsi,0x1
  1e4413:	jne    1e448a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e4415:	test   rdx,rdx
  1e4418:	je     1e448a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1e441a:	mov    QWORD PTR [rsp+0x78],r8
  1e441f:	mov    QWORD PTR [rsp+0x80],rcx
  1e4427:	mov    rcx,QWORD PTR [rsp+0x20]
  1e442c:	mov    QWORD PTR [rsp+0x88],rcx
  1e4434:	mov    QWORD PTR [rsp+0x90],rax
  1e443c:	mov    QWORD PTR [rsp+0x60],rbx
  1e4441:	mov    QWORD PTR [rsp+0x68],r15
  1e4446:	mov    rax,QWORD PTR [rsp+0x8]
  1e444b:	mov    QWORD PTR [rsp+0x70],rax
  1e4450:	sub    rsp,0x8
  1e4454:	movzx  eax,BYTE PTR [rsp+0x20]
  1e4459:	movzx  esi,BYTE PTR [rsp+0x38]
  1e445e:	movzx  ecx,r9b
  1e4462:	lea    rdi,[rsp+0x68]
  1e4467:	lea    rdx,[rsp+0x80]
  1e446f:	mov    r8,QWORD PTR [rsp+0x18]
  1e4474:	mov    r9,r13
  1e4477:	push   r10
  1e4479:	push   r11
  1e447b:	push   rax
  1e447c:	call   1c82c0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  1e4481:	add    rsp,0x20
  1e4485:	jmp    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e448a:	cmp    r13,0x1
  1e448e:	jne    1e4598 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e4494:	xor    edx,edx
  1e4496:	cmp    r14,0x1
  1e449a:	cmove  rdx,rbx
  1e449e:	cmp    QWORD PTR [rsp+0x38],0x1
  1e44a4:	jne    1e450d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1e44a6:	test   rdx,rdx
  1e44a9:	je     1e450d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1e44ab:	mov    QWORD PTR [rsp+0x78],rdx
  1e44b0:	mov    QWORD PTR [rsp+0x80],r12
  1e44b8:	mov    QWORD PTR [rsp+0x88],r15
  1e44c0:	mov    rdx,QWORD PTR [rsp+0x8]
  1e44c5:	mov    QWORD PTR [rsp+0x90],rdx
  1e44cd:	mov    QWORD PTR [rsp+0x60],r8
  1e44d2:	mov    QWORD PTR [rsp+0x68],rcx
  1e44d7:	mov    QWORD PTR [rsp+0x70],rax
  1e44dc:	sub    rsp,0x8
  1e44e0:	mov    r14,r10
  1e44e3:	movzx  r10d,r9b
  1e44e7:	movzx  esi,BYTE PTR [rsp+0x38]
  1e44ec:	movzx  r8d,BYTE PTR [rsp+0x20]
  1e44f2:	lea    rdi,[rsp+0x80]
  1e44fa:	lea    r9,[rsp+0x68]
  1e44ff:	mov    rdx,QWORD PTR [rsp+0x18]
  1e4504:	mov    rcx,QWORD PTR [rsp+0x30]
  1e4509:	push   r14
  1e450b:	jmp    1e4586 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  1e450d:	xor    edx,edx
  1e450f:	cmp    QWORD PTR [rsp+0x8],0x1
  1e4515:	cmove  rdx,rbx
  1e4519:	cmp    rax,0x1
  1e451d:	jne    1e4598 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e451f:	test   rdx,rdx
  1e4522:	je     1e4598 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1e4524:	mov    QWORD PTR [rsp+0x78],rdx
  1e4529:	mov    QWORD PTR [rsp+0x80],r15
  1e4531:	mov    QWORD PTR [rsp+0x88],r12
  1e4539:	mov    QWORD PTR [rsp+0x90],r14
  1e4541:	mov    rax,QWORD PTR [rsp+0x10]
  1e4546:	mov    QWORD PTR [rsp+0x60],rax
  1e454b:	mov    rax,QWORD PTR [rsp+0x28]
  1e4550:	mov    QWORD PTR [rsp+0x68],rax
  1e4555:	mov    rax,QWORD PTR [rsp+0x38]
  1e455a:	mov    QWORD PTR [rsp+0x70],rax
  1e455f:	sub    rsp,0x8
  1e4563:	mov    rax,r10
  1e4566:	movzx  r10d,BYTE PTR [rsp+0x20]
  1e456c:	movzx  esi,BYTE PTR [rsp+0x38]
  1e4571:	mov    rdx,r8
  1e4574:	movzx  r8d,r9b
  1e4578:	lea    rdi,[rsp+0x80]
  1e4580:	lea    r9,[rsp+0x68]
  1e4585:	push   rax
  1e4586:	push   r11
  1e4588:	push   r10
  1e458a:	call   14e090 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  1e458f:	add    rsp,0x20
  1e4593:	jmp    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4598:	mov    QWORD PTR [rsp+0x20],rax
  1e459d:	movsd  xmm1,QWORD PTR [r11]
  1e45a2:	mov    rax,r12
  1e45a5:	mul    r15
  1e45a8:	mov    rbp,rax
  1e45ab:	movsd  QWORD PTR [rsp+0x60],xmm1
  1e45b1:	seto   r11b
  1e45b5:	jo     1e4ae5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  1e45bb:	mul    r13
  1e45be:	seto   cl
  1e45c1:	not    cl
  1e45c3:	cmp    rax,0x1001
  1e45c9:	setb   al
  1e45cc:	test   cl,al
  1e45ce:	jne    1e462b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5eb>
  1e45d0:	mov    rdx,QWORD PTR [rip+0x3669c1]        # 54af98 <_DYNAMIC+0x598>
  1e45d7:	mov    rax,QWORD PTR [rdx]
  1e45da:	test   rax,rax
  1e45dd:	je     1e4af1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  1e45e3:	mov    cl,0x1
  1e45e5:	test   eax,0x80000
  1e45ea:	jne    1e4c13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  1e45f0:	mov    rax,QWORD PTR [rdx]
  1e45f3:	test   rax,rax
  1e45f6:	je     1e4b57 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb17>
  1e45fc:	test   ax,ax
  1e45ff:	jns    1e4618 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1e4601:	mov    rax,QWORD PTR [rdx]
  1e4604:	test   rax,rax
  1e4607:	je     1e4bb9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb79>
  1e460d:	bt     rax,0x37
  1e4612:	jb     1e4c11 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd1>
  1e4618:	cmp    BYTE PTR [rsp+0x30],0x0
  1e461d:	jne    1e48cc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  1e4623:	xorps  xmm0,xmm0
  1e4626:	jmp    1e48d4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  1e462b:	cmp    BYTE PTR [rsp+0x30],0x0
  1e4630:	mov    eax,DWORD PTR [rsp+0x18]
  1e4634:	jne    1e4696 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x656>
  1e4636:	xorps  xmm0,xmm0
  1e4639:	movsd  QWORD PTR [rsp+0x30],xmm0
  1e463f:	cmp    QWORD PTR [rsp+0x8],r14
  1e4644:	jb     1e46ab <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66b>
  1e4646:	mov    ebp,r9d
  1e4649:	mov    r9d,eax
  1e464c:	mov    rax,QWORD PTR [rsp+0x20]
  1e4651:	mov    QWORD PTR [rsp+0x18],rax
  1e4656:	mov    QWORD PTR [rsp+0x40],rsi
  1e465b:	mov    QWORD PTR [rsp+0x58],r8
  1e4660:	mov    rsi,rdi
  1e4663:	mov    rax,QWORD PTR [rsp+0x38]
  1e4668:	mov    r8,QWORD PTR [rsp+0x10]
  1e466d:	mov    rcx,QWORD PTR [rsp+0x8]
  1e4672:	mov    QWORD PTR [rsp+0x10],rcx
  1e4677:	mov    QWORD PTR [rsp+0x8],r14
  1e467c:	mov    r14,r15
  1e467f:	mov    r15,r12
  1e4682:	jmp    1e46d3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x693>
  1e4684:	cmp    r14,0x1
  1e4688:	jne    1e47fe <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7be>
  1e468e:	mov    rax,r12
  1e4691:	jmp    1e4a5e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  1e4696:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5b40a]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1e469e:	movsd  QWORD PTR [rsp+0x30],xmm0
  1e46a4:	cmp    QWORD PTR [rsp+0x8],r14
  1e46a9:	jae    1e4646 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x606>
  1e46ab:	mov    ebp,eax
  1e46ad:	mov    rax,QWORD PTR [rsp+0x38]
  1e46b2:	mov    QWORD PTR [rsp+0x18],rax
  1e46b7:	mov    QWORD PTR [rsp+0x40],rdi
  1e46bc:	mov    rax,QWORD PTR [rsp+0x10]
  1e46c1:	mov    QWORD PTR [rsp+0x58],rax
  1e46c6:	mov    QWORD PTR [rsp+0x10],r14
  1e46cb:	mov    r14,r12
  1e46ce:	mov    rax,QWORD PTR [rsp+0x20]
  1e46d3:	movsd  QWORD PTR [rsp+0x28],xmm1
  1e46d9:	mov    QWORD PTR [rsp+0x48],rsi
  1e46de:	mov    QWORD PTR [rsp+0x50],r8
  1e46e3:	mov    r12d,r9d
  1e46e6:	mov    QWORD PTR [rsp+0x20],rax
  1e46eb:	cmp    rax,0x1
  1e46ef:	jne    1e4716 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1e46f1:	cmp    QWORD PTR [rsp+0x8],0x1
  1e46f7:	jne    1e4716 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1e46f9:	lea    r8,[rip+0x35b480]        # 53fb80 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x410>
  1e4700:	lea    rdi,[rsp+0x78]
  1e4705:	mov    rsi,r15
  1e4708:	mov    rdx,r14
  1e470b:	mov    rcx,r13
  1e470e:	call   QWORD PTR [rip+0x3669cc]        # 54b0e0 <_DYNAMIC+0x6e0>
  1e4714:	jmp    1e4731 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f1>
  1e4716:	lea    r8,[rip+0x35b47b]        # 53fb98 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x428>
  1e471d:	lea    rdi,[rsp+0x78]
  1e4722:	mov    rsi,r15
  1e4725:	mov    rdx,r14
  1e4728:	mov    rcx,r13
  1e472b:	call   QWORD PTR [rip+0x3669b7]        # 54b0e8 <_DYNAMIC+0x6e8>
  1e4731:	lea    rdi,[rsp+0x80]
  1e4739:	mov    rsi,QWORD PTR [rsp+0xa0]
  1e4741:	mov    rdx,QWORD PTR [rsp+0xa8]
  1e4749:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  1e4751:	sub    rsp,0x70
  1e4755:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e475a:	movzx  eax,bpl
  1e475e:	mov    DWORD PTR [rsp+0x50],eax
  1e4762:	movzx  eax,r12b
  1e4766:	mov    DWORD PTR [rsp+0x48],eax
  1e476a:	mov    rax,QWORD PTR [rsp+0x88]
  1e4772:	mov    QWORD PTR [rsp+0x40],rax
  1e4777:	mov    rax,QWORD PTR [rsp+0xb0]
  1e477f:	mov    QWORD PTR [rsp+0x38],rax
  1e4784:	mov    rax,QWORD PTR [rsp+0xc8]
  1e478c:	mov    QWORD PTR [rsp+0x30],rax
  1e4791:	mov    rax,QWORD PTR [rsp+0xb8]
  1e4799:	mov    QWORD PTR [rsp+0x28],rax
  1e479e:	mov    rax,QWORD PTR [rsp+0x90]
  1e47a6:	mov    QWORD PTR [rsp+0x20],rax
  1e47ab:	mov    rax,QWORD PTR [rsp+0xc0]
  1e47b3:	mov    QWORD PTR [rsp+0x18],rax
  1e47b8:	mov    rax,QWORD PTR [rsp+0x80]
  1e47c0:	mov    QWORD PTR [rsp+0x10],rax
  1e47c5:	mov    rax,QWORD PTR [rsp+0x78]
  1e47ca:	mov    QWORD PTR [rsp+0x8],rax
  1e47cf:	mov    QWORD PTR [rsp],rbx
  1e47d3:	mov    r8,r14
  1e47d6:	mov    r9,r13
  1e47d9:	mov    rcx,r15
  1e47dc:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  1e47e5:	movsd  xmm1,QWORD PTR [rsp+0x98]
  1e47ee:	call   QWORD PTR [rsp+0xe8]
  1e47f5:	add    rsp,0x70
  1e47f9:	jmp    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e47fe:	lea    rax,[r12-0x1]
  1e4803:	mov    ecx,r12d
  1e4806:	and    ecx,0x3
  1e4809:	and    r12,0xfffffffffffffffc
  1e480d:	lea    rdx,[r14*8+0x0]
  1e4815:	lea    rsi,[rdx+rdx*2]
  1e4819:	shl    QWORD PTR [rsp+0x8],0x3
  1e481f:	mov    rdi,r14
  1e4822:	shl    rdi,0x5
  1e4826:	mov    r8,r14
  1e4829:	shl    r8,0x4
  1e482d:	xor    r9d,r9d
  1e4830:	jmp    1e4851 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  1e4832:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e4840:	inc    r9
  1e4843:	add    rbx,QWORD PTR [rsp+0x8]
  1e4848:	cmp    r9,r15
  1e484b:	je     1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4851:	cmp    rax,0x3
  1e4855:	jae    1e4860 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  1e4857:	xor    r10d,r10d
  1e485a:	jmp    1e48a0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  1e485c:	nop    DWORD PTR [rax+0x0]
  1e4860:	mov    r11,rbx
  1e4863:	xor    r10d,r10d
  1e4866:	cs nop WORD PTR [rax+rax*1+0x0]
  1e4870:	mov    QWORD PTR [r11],0x0
  1e4877:	mov    QWORD PTR [r11+r14*8],0x0
  1e487f:	mov    QWORD PTR [r11+r8*1],0x0
  1e4887:	add    r10,0x4
  1e488b:	mov    QWORD PTR [r11+rsi*1],0x0
  1e4893:	add    r11,rdi
  1e4896:	cmp    r12,r10
  1e4899:	jne    1e4870 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  1e489b:	test   rcx,rcx
  1e489e:	je     1e4840 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1e48a0:	imul   r10,rdx
  1e48a4:	add    r10,rbx
  1e48a7:	mov    r11,rcx
  1e48aa:	nop    WORD PTR [rax+rax*1+0x0]
  1e48b0:	mov    QWORD PTR [r10],0x0
  1e48b7:	add    r10,rdx
  1e48ba:	dec    r11
  1e48bd:	jne    1e48b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  1e48bf:	jmp    1e4840 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1e48c4:	mov    rax,r12
  1e48c7:	jmp    1e4a52 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa12>
  1e48cc:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe5b1d4]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1e48d4:	xor    r11d,r11d
  1e48d7:	test   r10,r10
  1e48da:	setne  dl
  1e48dd:	cmp    QWORD PTR [rsp+0x8],r14
  1e48e2:	jge    1e48fe <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8be>
  1e48e4:	mov    rcx,QWORD PTR [rsp+0x20]
  1e48e9:	mov    QWORD PTR [rsp+0x18],rsi
  1e48ee:	mov    rax,r8
  1e48f1:	mov    r8,r14
  1e48f4:	mov    rbp,r15
  1e48f7:	mov    r9,QWORD PTR [rsp+0x38]
  1e48fc:	jmp    1e492d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8ed>
  1e48fe:	mov    rcx,QWORD PTR [rsp+0x38]
  1e4903:	mov    QWORD PTR [rsp+0x18],rdi
  1e4908:	mov    rax,QWORD PTR [rsp+0x10]
  1e490d:	mov    r10,QWORD PTR [rsp+0x8]
  1e4912:	mov    rbp,r12
  1e4915:	mov    r9,QWORD PTR [rsp+0x20]
  1e491a:	mov    rdi,rsi
  1e491d:	mov    QWORD PTR [rsp+0x10],r8
  1e4922:	mov    r8,r10
  1e4925:	mov    QWORD PTR [rsp+0x8],r14
  1e492a:	mov    r12,r15
  1e492d:	mov    r11b,dl
  1e4930:	lea    rdx,[rbp-0x1]
  1e4934:	imul   rdx,rcx
  1e4938:	mov    r14,rcx
  1e493b:	neg    r14
  1e493e:	mov    rsi,QWORD PTR [rsp+0x8]
  1e4943:	test   rsi,rsi
  1e4946:	cmovns r14,rcx
  1e494a:	mov    rcx,rsi
  1e494d:	sar    rcx,0x3f
  1e4951:	and    rcx,rdx
  1e4954:	lea    rsi,[rax+rcx*8]
  1e4958:	lea    rax,[r12-0x1]
  1e495d:	imul   rax,r9
  1e4961:	mov    r15,r9
  1e4964:	neg    r15
  1e4967:	test   r8,r8
  1e496a:	cmovns r15,r9
  1e496e:	mov    rcx,r8
  1e4971:	sar    rcx,0x3f
  1e4975:	and    rcx,rax
  1e4978:	mov    rax,QWORD PTR [rsp+0x10]
  1e497d:	lea    r9,[rax+rcx*8]
  1e4981:	cmp    QWORD PTR [rsp+0x18],0x0
  1e4987:	jns    1e49b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x970>
  1e4989:	lea    rax,[r13-0x1]
  1e498d:	mov    rdx,QWORD PTR [rsp+0x18]
  1e4992:	mov    rcx,rdx
  1e4995:	imul   rcx,rax
  1e4999:	lea    rsi,[rsi+rcx*8]
  1e499d:	neg    rdx
  1e49a0:	mov    QWORD PTR [rsp+0x18],rdx
  1e49a5:	imul   rax,rdi
  1e49a9:	lea    r9,[r9+rax*8]
  1e49ad:	neg    rdi
  1e49b0:	mov    QWORD PTR [rsp+0x20],r9
  1e49b5:	mov    QWORD PTR [rsp+0x10],rsi
  1e49ba:	mov    QWORD PTR [rsp+0x40],rdi
  1e49bf:	mov    rax,QWORD PTR [rip+0x366662]        # 54b028 <_DYNAMIC+0x628>
  1e49c6:	mov    rax,QWORD PTR [rax]
  1e49c9:	test   rax,rax
  1e49cc:	jne    1e4a00 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c0>
  1e49ce:	movsd  QWORD PTR [rsp+0x28],xmm1
  1e49d4:	movsd  QWORD PTR [rsp+0x38],xmm0
  1e49da:	mov    QWORD PTR [rsp+0x48],r11
  1e49df:	mov    QWORD PTR [rsp+0x50],r8
  1e49e4:	call   QWORD PTR [rip+0x366646]        # 54b030 <_DYNAMIC+0x630>
  1e49ea:	mov    r8,QWORD PTR [rsp+0x50]
  1e49ef:	mov    r11,QWORD PTR [rsp+0x48]
  1e49f4:	movsd  xmm0,QWORD PTR [rsp+0x38]
  1e49fa:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1e4a00:	movzx  r10d,BYTE PTR [rsp+0x30]
  1e4a06:	mov    rdi,rbp
  1e4a09:	mov    rsi,r12
  1e4a0c:	mov    rdx,r13
  1e4a0f:	mov    rcx,rbx
  1e4a12:	mov    r9,QWORD PTR [rsp+0x8]
  1e4a17:	push   QWORD PTR [rsp+0x148]
  1e4a1e:	push   r11
  1e4a20:	push   0x0
  1e4a22:	push   0x0
  1e4a24:	push   0x0
  1e4a26:	push   QWORD PTR [rsp+0x68]
  1e4a2a:	push   r15
  1e4a2c:	push   QWORD PTR [rsp+0x58]
  1e4a30:	push   r14
  1e4a32:	push   QWORD PTR [rsp+0x60]
  1e4a36:	push   QWORD PTR [rsp+0x60]
  1e4a3a:	push   r10
  1e4a3c:	call   rax
  1e4a3e:	add    rsp,0x60
  1e4a42:	jmp    1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4a47:	mov    rax,r15
  1e4a4a:	mov    r15,r12
  1e4a4d:	mov    QWORD PTR [rsp+0x8],r14
  1e4a52:	mov    ecx,0x1
  1e4a57:	sub    rcx,rax
  1e4a5a:	lea    rbx,[rbx+rcx*8]
  1e4a5e:	lea    rcx,[rax-0x1]
  1e4a62:	mov    edx,eax
  1e4a64:	and    edx,0x3
  1e4a67:	and    rax,0xfffffffffffffffc
  1e4a6b:	xor    esi,esi
  1e4a6d:	xorps  xmm0,xmm0
  1e4a70:	jmp    1e4a8c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  1e4a72:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e4a80:	inc    rsi
  1e4a83:	cmp    rsi,r15
  1e4a86:	je     1e4d31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1e4a8c:	mov    rdi,rsi
  1e4a8f:	imul   rdi,QWORD PTR [rsp+0x8]
  1e4a95:	lea    rdi,[rbx+rdi*8]
  1e4a99:	cmp    rcx,0x3
  1e4a9d:	jb     1e4ac9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  1e4a9f:	xor    r8d,r8d
  1e4aa2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1e4ab0:	movups XMMWORD PTR [rdi],xmm0
  1e4ab3:	movups XMMWORD PTR [rdi+0x10],xmm0
  1e4ab7:	add    rdi,0x20
  1e4abb:	add    r8,0x4
  1e4abf:	cmp    rax,r8
  1e4ac2:	jne    1e4ab0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  1e4ac4:	test   rdx,rdx
  1e4ac7:	je     1e4a80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1e4ac9:	xor    r8d,r8d
  1e4acc:	nop    DWORD PTR [rax+0x0]
  1e4ad0:	mov    QWORD PTR [rdi],0x0
  1e4ad7:	add    rdi,0x8
  1e4adb:	inc    r8
  1e4ade:	cmp    rdx,r8
  1e4ae1:	jne    1e4ad0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  1e4ae3:	jmp    1e4a80 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1e4ae5:	mov    rax,0xffffffffffffffff
  1e4aec:	jmp    1e45bb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x57b>
  1e4af1:	mov    DWORD PTR [rsp+0x58],r9d
  1e4af6:	mov    QWORD PTR [rsp+0x40],rdi
  1e4afb:	mov    QWORD PTR [rsp+0x50],r8
  1e4b00:	mov    QWORD PTR [rsp+0x48],rsi
  1e4b05:	movsd  QWORD PTR [rsp+0x28],xmm1
  1e4b0b:	mov    BYTE PTR [rsp+0x7],r11b
  1e4b10:	call   QWORD PTR [rip+0x366492]        # 54afa8 <_DYNAMIC+0x5a8>
  1e4b16:	mov    rdx,QWORD PTR [rip+0x36647b]        # 54af98 <_DYNAMIC+0x598>
  1e4b1d:	movzx  r11d,BYTE PTR [rsp+0x7]
  1e4b23:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1e4b29:	mov    rsi,QWORD PTR [rsp+0x48]
  1e4b2e:	mov    r10,QWORD PTR [rsp+0x148]
  1e4b36:	mov    r8,QWORD PTR [rsp+0x50]
  1e4b3b:	mov    rdi,QWORD PTR [rsp+0x40]
  1e4b40:	mov    r9d,DWORD PTR [rsp+0x58]
  1e4b45:	mov    cl,0x1
  1e4b47:	test   eax,0x80000
  1e4b4c:	je     1e45f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b0>
  1e4b52:	jmp    1e4c13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  1e4b57:	mov    DWORD PTR [rsp+0x58],r9d
  1e4b5c:	mov    QWORD PTR [rsp+0x40],rdi
  1e4b61:	mov    QWORD PTR [rsp+0x50],r8
  1e4b66:	mov    QWORD PTR [rsp+0x48],rsi
  1e4b6b:	movsd  QWORD PTR [rsp+0x28],xmm1
  1e4b71:	mov    BYTE PTR [rsp+0x7],r11b
  1e4b76:	call   QWORD PTR [rip+0x36642c]        # 54afa8 <_DYNAMIC+0x5a8>
  1e4b7c:	mov    rdx,QWORD PTR [rip+0x366415]        # 54af98 <_DYNAMIC+0x598>
  1e4b83:	movzx  r11d,BYTE PTR [rsp+0x7]
  1e4b89:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1e4b8f:	mov    rsi,QWORD PTR [rsp+0x48]
  1e4b94:	mov    r10,QWORD PTR [rsp+0x148]
  1e4b9c:	mov    r8,QWORD PTR [rsp+0x50]
  1e4ba1:	mov    rdi,QWORD PTR [rsp+0x40]
  1e4ba6:	mov    r9d,DWORD PTR [rsp+0x58]
  1e4bab:	test   ax,ax
  1e4bae:	js     1e4601 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c1>
  1e4bb4:	jmp    1e4618 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1e4bb9:	mov    DWORD PTR [rsp+0x58],r9d
  1e4bbe:	mov    QWORD PTR [rsp+0x40],rdi
  1e4bc3:	mov    QWORD PTR [rsp+0x50],r8
  1e4bc8:	mov    QWORD PTR [rsp+0x48],rsi
  1e4bcd:	movsd  QWORD PTR [rsp+0x28],xmm1
  1e4bd3:	mov    BYTE PTR [rsp+0x7],r11b
  1e4bd8:	call   QWORD PTR [rip+0x3663ca]        # 54afa8 <_DYNAMIC+0x5a8>
  1e4bde:	movzx  r11d,BYTE PTR [rsp+0x7]
  1e4be4:	movsd  xmm1,QWORD PTR [rsp+0x28]
  1e4bea:	mov    rsi,QWORD PTR [rsp+0x48]
  1e4bef:	mov    r10,QWORD PTR [rsp+0x148]
  1e4bf7:	mov    r8,QWORD PTR [rsp+0x50]
  1e4bfc:	mov    rdi,QWORD PTR [rsp+0x40]
  1e4c01:	mov    r9d,DWORD PTR [rsp+0x58]
  1e4c06:	bt     rax,0x37
  1e4c0b:	jae    1e4618 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  1e4c11:	xor    ecx,ecx
  1e4c13:	mov    r10d,r9d
  1e4c16:	mov    r9,r8
  1e4c19:	test   r11b,r11b
  1e4c1c:	jne    1e4d43 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd03>
  1e4c22:	mov    r8,rdi
  1e4c25:	mov    rax,rbp
  1e4c28:	mul    r13
  1e4c2b:	jo     1e4d59 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  1e4c31:	test   rax,rax
  1e4c34:	js     1e4d59 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  1e4c3a:	mov    rdx,QWORD PTR [rip+0x36637f]        # 54afc0 <_DYNAMIC+0x5c0>
  1e4c41:	mov    rdx,QWORD PTR [rdx]
  1e4c44:	movabs rdi,0x7fffffffffffffff
  1e4c4e:	and    rdi,rdx
  1e4c51:	mov    edx,0x1
  1e4c56:	cmp    rax,rdi
  1e4c59:	jb     1e4c6b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc2b>
  1e4c5b:	mov    rdx,QWORD PTR [rsp+0x148]
  1e4c63:	cmp    rdx,0x1
  1e4c67:	adc    rdx,0x0
  1e4c6b:	sub    rsp,0xa0
  1e4c72:	mov    QWORD PTR [rsp+0x90],rdx
  1e4c7a:	lea    rax,[rsp+0x100]
  1e4c82:	mov    QWORD PTR [rsp+0x88],rax
  1e4c8a:	movzx  eax,r10b
  1e4c8e:	mov    DWORD PTR [rsp+0x80],eax
  1e4c95:	mov    rax,QWORD PTR [rsp+0xc0]
  1e4c9d:	mov    QWORD PTR [rsp+0x78],rax
  1e4ca2:	mov    QWORD PTR [rsp+0x70],rsi
  1e4ca7:	mov    QWORD PTR [rsp+0x68],r9
  1e4cac:	xorps  xmm0,xmm0
  1e4caf:	movups XMMWORD PTR [rsp+0x58],xmm0
  1e4cb4:	movzx  eax,BYTE PTR [rsp+0xb8]
  1e4cbc:	mov    DWORD PTR [rsp+0x50],eax
  1e4cc0:	mov    QWORD PTR [rsp+0x48],r8
  1e4cc5:	mov    rax,QWORD PTR [rsp+0xd8]
  1e4ccd:	mov    QWORD PTR [rsp+0x40],rax
  1e4cd2:	mov    rax,QWORD PTR [rsp+0xb0]
  1e4cda:	mov    QWORD PTR [rsp+0x38],rax
  1e4cdf:	movzx  eax,BYTE PTR [rsp+0xd0]
  1e4ce7:	mov    DWORD PTR [rsp+0x30],eax
  1e4ceb:	movups XMMWORD PTR [rsp+0x18],xmm0
  1e4cf0:	mov    rax,QWORD PTR [rsp+0xa8]
  1e4cf8:	mov    QWORD PTR [rsp+0x10],rax
  1e4cfd:	mov    QWORD PTR [rsp+0x8],r14
  1e4d02:	mov    QWORD PTR [rsp],rbx
  1e4d06:	mov    DWORD PTR [rsp+0x28],0x2
  1e4d0e:	movzx  edx,cl
  1e4d11:	mov    r8,r15
  1e4d14:	mov    edi,0x1
  1e4d19:	mov    r9,r13
  1e4d1c:	mov    esi,0x1
  1e4d21:	mov    rcx,r12
  1e4d24:	call   QWORD PTR [rip+0x366276]        # 54afa0 <_DYNAMIC+0x5a0>
  1e4d2a:	add    rsp,0xa0
  1e4d31:	add    rsp,0x108
  1e4d38:	pop    rbx
  1e4d39:	pop    r12
  1e4d3b:	pop    r13
  1e4d3d:	pop    r14
  1e4d3f:	pop    r15
  1e4d41:	pop    rbp
  1e4d42:	ret
  1e4d43:	mov    rbp,0xffffffffffffffff
  1e4d4a:	mov    r8,rdi
  1e4d4d:	mov    rax,rbp
  1e4d50:	mul    r13
  1e4d53:	jno    1e4c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbf1>
  1e4d59:	mov    rax,QWORD PTR [rip+0x366260]        # 54afc0 <_DYNAMIC+0x5c0>
  1e4d60:	mov    rax,QWORD PTR [rax]
  1e4d63:	jmp    1e4c5b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc1b>
