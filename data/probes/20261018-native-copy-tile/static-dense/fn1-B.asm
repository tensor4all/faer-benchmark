
target/faer-rev/60de2ee06467-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

00000000001d8ff0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  1d8ff0:	push   rbp
  1d8ff1:	push   r15
  1d8ff3:	push   r14
  1d8ff5:	push   r13
  1d8ff7:	push   r12
  1d8ff9:	push   rbx
  1d8ffa:	sub    rsp,0x108
  1d9001:	mov    DWORD PTR [rsp+0x30],esi
  1d9005:	mov    r12,QWORD PTR [rdi+0x8]
  1d9009:	test   r12,r12
  1d900c:	je     1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d9012:	mov    r15,QWORD PTR [rdi+0x10]
  1d9016:	test   r15,r15
  1d9019:	je     1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d901f:	mov    rbx,QWORD PTR [rdi]
  1d9022:	mov    r14,QWORD PTR [rdi+0x18]
  1d9026:	mov    rax,QWORD PTR [rdi+0x20]
  1d902a:	mov    QWORD PTR [rsp+0x8],rax
  1d902f:	mov    r13,QWORD PTR [rdx+0x10]
  1d9033:	test   r13,r13
  1d9036:	je     1d90ee <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  1d903c:	mov    r11,r8
  1d903f:	mov    DWORD PTR [rsp+0x38],ecx
  1d9043:	mov    rax,QWORD PTR [rdx]
  1d9046:	mov    QWORD PTR [rsp+0x10],rax
  1d904b:	mov    rcx,QWORD PTR [rdx+0x8]
  1d904f:	mov    r8,QWORD PTR [rdx+0x18]
  1d9053:	test   r14,r14
  1d9056:	mov    QWORD PTR [rsp+0x20],rcx
  1d905b:	jns    1d9099 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  1d905d:	lea    rax,[r12-0x1]
  1d9062:	imul   rax,r14
  1d9066:	neg    r14
  1d9069:	xor    edi,edi
  1d906b:	mov    r10,rcx
  1d906e:	sub    r10,0x1
  1d9072:	cmovb  r10,rdi
  1d9076:	lea    rbx,[rbx+rax*8]
  1d907a:	mov    rax,r8
  1d907d:	imul   rax,r10
  1d9081:	cmp    r10,rcx
  1d9084:	cmove  rax,rdi
  1d9088:	mov    rcx,QWORD PTR [rsp+0x10]
  1d908d:	lea    rcx,[rcx+rax*8]
  1d9091:	mov    QWORD PTR [rsp+0x10],rcx
  1d9096:	neg    r8
  1d9099:	mov    QWORD PTR [rsp+0x28],r8
  1d909e:	mov    rdi,QWORD PTR [rdx+0x20]
  1d90a2:	mov    r8,QWORD PTR [r11]
  1d90a5:	mov    rax,QWORD PTR [r11+0x8]
  1d90a9:	mov    QWORD PTR [rsp+0x18],rax
  1d90ae:	mov    rcx,QWORD PTR [r11+0x10]
  1d90b2:	mov    rax,QWORD PTR [r11+0x20]
  1d90b6:	cmp    QWORD PTR [rsp+0x8],0x0
  1d90bc:	js     1d9145 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  1d90c2:	mov    rsi,QWORD PTR [r11+0x18]
  1d90c6:	test   rdi,rdi
  1d90c9:	js     1d91b1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  1d90cf:	mov    r10,QWORD PTR [rsp+0x148]
  1d90d7:	mov    r11,QWORD PTR [rsp+0x140]
  1d90df:	cmp    r15,0x1
  1d90e3:	je     1d9236 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  1d90e9:	jmp    1d9324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1d90ee:	cmp    BYTE PTR [rsp+0x30],0x0
  1d90f3:	jne    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d90f9:	cmp    r12,0x1
  1d90fd:	je     1d9113 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  1d90ff:	cmp    r14,0xffffffffffffffff
  1d9103:	je     1d9874 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  1d9109:	cmp    r14,0x1
  1d910d:	je     1d963d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64d>
  1d9113:	cmp    r15,0x1
  1d9117:	je     1d9633 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  1d911d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  1d9123:	je     1d99fa <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa0a>
  1d9129:	cmp    QWORD PTR [rsp+0x8],0x1
  1d912f:	jne    1d9633 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x643>
  1d9135:	mov    rax,r15
  1d9138:	mov    r15,r12
  1d913b:	mov    QWORD PTR [rsp+0x8],r14
  1d9140:	jmp    1d9a11 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  1d9145:	lea    rdx,[r15-0x1]
  1d9149:	mov    rsi,QWORD PTR [rsp+0x8]
  1d914e:	imul   rdx,rsi
  1d9152:	lea    rbx,[rbx+rdx*8]
  1d9156:	neg    rsi
  1d9159:	mov    QWORD PTR [rsp+0x8],rsi
  1d915e:	xor    edx,edx
  1d9160:	mov    r10d,r9d
  1d9163:	mov    r9,r8
  1d9166:	mov    r8,rdi
  1d9169:	mov    rdi,rcx
  1d916c:	sub    rdi,0x1
  1d9170:	cmovb  rdi,rdx
  1d9174:	mov    rbp,r13
  1d9177:	mov    r13,rax
  1d917a:	imul   r13,rdi
  1d917e:	cmp    rdi,rcx
  1d9181:	mov    rdi,r8
  1d9184:	mov    r8,r9
  1d9187:	mov    r9d,r10d
  1d918a:	mov    r10,QWORD PTR [rsp+0x18]
  1d918f:	cmove  r13,rdx
  1d9193:	test   r10,r10
  1d9196:	cmove  r13,r10
  1d919a:	lea    r8,[r8+r13*8]
  1d919e:	mov    r13,rbp
  1d91a1:	neg    rax
  1d91a4:	mov    rsi,QWORD PTR [r11+0x18]
  1d91a8:	test   rdi,rdi
  1d91ab:	jns    1d90cf <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  1d91b1:	lea    rdx,[r13-0x1]
  1d91b5:	imul   rdx,rdi
  1d91b9:	mov    r10,QWORD PTR [rsp+0x20]
  1d91be:	test   r10,r10
  1d91c1:	cmove  rdx,r10
  1d91c5:	mov    r10,rax
  1d91c8:	mov    rax,QWORD PTR [rsp+0x10]
  1d91cd:	lea    rax,[rax+rdx*8]
  1d91d1:	mov    QWORD PTR [rsp+0x10],rax
  1d91d6:	neg    rdi
  1d91d9:	xor    edx,edx
  1d91db:	mov    rax,rdi
  1d91de:	mov    rbp,r13
  1d91e1:	mov    r13,rsi
  1d91e4:	mov    rsi,QWORD PTR [rsp+0x18]
  1d91e9:	mov    rdi,rsi
  1d91ec:	sub    rdi,0x1
  1d91f0:	cmovb  rdi,rdx
  1d91f4:	mov    r11,r13
  1d91f7:	imul   r11,rdi
  1d91fb:	test   rcx,rcx
  1d91fe:	cmove  r11,rcx
  1d9202:	cmp    rdi,rsi
  1d9205:	mov    rsi,r13
  1d9208:	mov    r13,rbp
  1d920b:	mov    rdi,rax
  1d920e:	mov    rax,r10
  1d9211:	cmove  r11,rdx
  1d9215:	lea    r8,[r8+r11*8]
  1d9219:	neg    rsi
  1d921c:	mov    r10,QWORD PTR [rsp+0x148]
  1d9224:	mov    r11,QWORD PTR [rsp+0x140]
  1d922c:	cmp    r15,0x1
  1d9230:	jne    1d9324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1d9236:	cmp    QWORD PTR [rsp+0x28],0x1
  1d923c:	jne    1d92af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1d923e:	cmp    r14,0x1
  1d9242:	jne    1d92af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1d9244:	test   rbx,rbx
  1d9247:	je     1d92af <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  1d9249:	mov    rax,QWORD PTR [rsp+0x10]
  1d924e:	mov    QWORD PTR [rsp+0x78],rax
  1d9253:	mov    rax,QWORD PTR [rsp+0x20]
  1d9258:	mov    QWORD PTR [rsp+0x80],rax
  1d9260:	mov    QWORD PTR [rsp+0x88],r13
  1d9268:	mov    QWORD PTR [rsp+0x90],rdi
  1d9270:	mov    QWORD PTR [rsp+0x60],r8
  1d9275:	mov    rax,QWORD PTR [rsp+0x18]
  1d927a:	mov    QWORD PTR [rsp+0x68],rax
  1d927f:	mov    QWORD PTR [rsp+0x70],rsi
  1d9284:	sub    rsp,0x8
  1d9288:	movzx  eax,r9b
  1d928c:	movzx  edx,BYTE PTR [rsp+0x38]
  1d9291:	movzx  r8d,BYTE PTR [rsp+0x40]
  1d9297:	lea    rcx,[rsp+0x80]
  1d929f:	lea    r9,[rsp+0x68]
  1d92a4:	mov    rdi,rbx
  1d92a7:	mov    rsi,r12
  1d92aa:	jmp    1d93a0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  1d92af:	cmp    rdi,0x1
  1d92b3:	jne    1d9324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1d92b5:	cmp    rsi,0x1
  1d92b9:	jne    1d9324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1d92bb:	test   r8,r8
  1d92be:	je     1d9324 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  1d92c0:	mov    rax,QWORD PTR [rsp+0x10]
  1d92c5:	mov    QWORD PTR [rsp+0x78],rax
  1d92ca:	mov    rax,QWORD PTR [rsp+0x20]
  1d92cf:	mov    QWORD PTR [rsp+0x80],rax
  1d92d7:	mov    QWORD PTR [rsp+0x88],r13
  1d92df:	mov    rax,QWORD PTR [rsp+0x28]
  1d92e4:	mov    QWORD PTR [rsp+0x90],rax
  1d92ec:	mov    QWORD PTR [rsp+0x60],rbx
  1d92f1:	mov    QWORD PTR [rsp+0x68],r12
  1d92f6:	mov    QWORD PTR [rsp+0x70],r14
  1d92fb:	sub    rsp,0x8
  1d92ff:	movzx  eax,r9b
  1d9303:	movzx  esi,BYTE PTR [rsp+0x38]
  1d9308:	movzx  ecx,BYTE PTR [rsp+0x40]
  1d930d:	lea    rdi,[rsp+0x68]
  1d9312:	lea    rdx,[rsp+0x80]
  1d931a:	mov    r9,QWORD PTR [rsp+0x20]
  1d931f:	jmp    1d9427 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  1d9324:	cmp    r12,0x1
  1d9328:	jne    1d943a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1d932e:	xor    edx,edx
  1d9330:	cmp    QWORD PTR [rsp+0x8],0x1
  1d9336:	cmove  rdx,rbx
  1d933a:	cmp    rax,0x1
  1d933e:	jne    1d93b3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1d9340:	test   rdx,rdx
  1d9343:	je     1d93b3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  1d9345:	mov    QWORD PTR [rsp+0x78],r8
  1d934a:	mov    QWORD PTR [rsp+0x80],rcx
  1d9352:	mov    rax,QWORD PTR [rsp+0x18]
  1d9357:	mov    QWORD PTR [rsp+0x88],rax
  1d935f:	mov    QWORD PTR [rsp+0x90],rsi
  1d9367:	mov    rax,QWORD PTR [rsp+0x10]
  1d936c:	mov    QWORD PTR [rsp+0x60],rax
  1d9371:	mov    QWORD PTR [rsp+0x68],r13
  1d9376:	mov    QWORD PTR [rsp+0x70],rdi
  1d937b:	sub    rsp,0x8
  1d937f:	movzx  eax,BYTE PTR [rsp+0x40]
  1d9384:	movzx  edx,BYTE PTR [rsp+0x38]
  1d9389:	movzx  r8d,r9b
  1d938d:	lea    rcx,[rsp+0x80]
  1d9395:	lea    r9,[rsp+0x68]
  1d939a:	mov    rdi,rbx
  1d939d:	mov    rsi,r15
  1d93a0:	push   r10
  1d93a2:	push   r11
  1d93a4:	push   rax
  1d93a5:	call   14d1e0 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  1d93aa:	add    rsp,0x20
  1d93ae:	jmp    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d93b3:	xor    edx,edx
  1d93b5:	cmp    rdi,0x1
  1d93b9:	cmove  rdx,QWORD PTR [rsp+0x10]
  1d93bf:	cmp    rsi,0x1
  1d93c3:	jne    1d943a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1d93c5:	test   rdx,rdx
  1d93c8:	je     1d943a <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  1d93ca:	mov    QWORD PTR [rsp+0x78],r8
  1d93cf:	mov    QWORD PTR [rsp+0x80],rcx
  1d93d7:	mov    rcx,QWORD PTR [rsp+0x18]
  1d93dc:	mov    QWORD PTR [rsp+0x88],rcx
  1d93e4:	mov    QWORD PTR [rsp+0x90],rax
  1d93ec:	mov    QWORD PTR [rsp+0x60],rbx
  1d93f1:	mov    QWORD PTR [rsp+0x68],r15
  1d93f6:	mov    rax,QWORD PTR [rsp+0x8]
  1d93fb:	mov    QWORD PTR [rsp+0x70],rax
  1d9400:	sub    rsp,0x8
  1d9404:	movzx  eax,BYTE PTR [rsp+0x40]
  1d9409:	movzx  esi,BYTE PTR [rsp+0x38]
  1d940e:	movzx  ecx,r9b
  1d9412:	lea    rdi,[rsp+0x68]
  1d9417:	lea    rdx,[rsp+0x80]
  1d941f:	mov    r8,QWORD PTR [rsp+0x18]
  1d9424:	mov    r9,r13
  1d9427:	push   r10
  1d9429:	push   r11
  1d942b:	push   rax
  1d942c:	call   1c6450 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  1d9431:	add    rsp,0x20
  1d9435:	jmp    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d943a:	cmp    r13,0x1
  1d943e:	jne    1d9548 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1d9444:	xor    edx,edx
  1d9446:	cmp    r14,0x1
  1d944a:	cmove  rdx,rbx
  1d944e:	cmp    QWORD PTR [rsp+0x28],0x1
  1d9454:	jne    1d94bd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1d9456:	test   rdx,rdx
  1d9459:	je     1d94bd <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1d945b:	mov    QWORD PTR [rsp+0x78],rdx
  1d9460:	mov    QWORD PTR [rsp+0x80],r12
  1d9468:	mov    QWORD PTR [rsp+0x88],r15
  1d9470:	mov    rdx,QWORD PTR [rsp+0x8]
  1d9475:	mov    QWORD PTR [rsp+0x90],rdx
  1d947d:	mov    QWORD PTR [rsp+0x60],r8
  1d9482:	mov    QWORD PTR [rsp+0x68],rcx
  1d9487:	mov    QWORD PTR [rsp+0x70],rax
  1d948c:	sub    rsp,0x8
  1d9490:	mov    r14,r10
  1d9493:	movzx  r10d,r9b
  1d9497:	movzx  esi,BYTE PTR [rsp+0x38]
  1d949c:	movzx  r8d,BYTE PTR [rsp+0x40]
  1d94a2:	lea    rdi,[rsp+0x80]
  1d94aa:	lea    r9,[rsp+0x68]
  1d94af:	mov    rdx,QWORD PTR [rsp+0x18]
  1d94b4:	mov    rcx,QWORD PTR [rsp+0x28]
  1d94b9:	push   r14
  1d94bb:	jmp    1d9536 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  1d94bd:	xor    edx,edx
  1d94bf:	cmp    QWORD PTR [rsp+0x8],0x1
  1d94c5:	cmove  rdx,rbx
  1d94c9:	cmp    rax,0x1
  1d94cd:	jne    1d9548 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1d94cf:	test   rdx,rdx
  1d94d2:	je     1d9548 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  1d94d4:	mov    QWORD PTR [rsp+0x78],rdx
  1d94d9:	mov    QWORD PTR [rsp+0x80],r15
  1d94e1:	mov    QWORD PTR [rsp+0x88],r12
  1d94e9:	mov    QWORD PTR [rsp+0x90],r14
  1d94f1:	mov    rax,QWORD PTR [rsp+0x10]
  1d94f6:	mov    QWORD PTR [rsp+0x60],rax
  1d94fb:	mov    rax,QWORD PTR [rsp+0x20]
  1d9500:	mov    QWORD PTR [rsp+0x68],rax
  1d9505:	mov    rax,QWORD PTR [rsp+0x28]
  1d950a:	mov    QWORD PTR [rsp+0x70],rax
  1d950f:	sub    rsp,0x8
  1d9513:	mov    rax,r10
  1d9516:	movzx  r10d,BYTE PTR [rsp+0x40]
  1d951c:	movzx  esi,BYTE PTR [rsp+0x38]
  1d9521:	mov    rdx,r8
  1d9524:	movzx  r8d,r9b
  1d9528:	lea    rdi,[rsp+0x80]
  1d9530:	lea    r9,[rsp+0x68]
  1d9535:	push   rax
  1d9536:	push   r11
  1d9538:	push   r10
  1d953a:	call   14b060 <_RINvNtNtNtCsiVB0znSuPaP_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  1d953f:	add    rsp,0x20
  1d9543:	jmp    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d9548:	mov    QWORD PTR [rsp+0x18],rax
  1d954d:	movsd  xmm1,QWORD PTR [r11]
  1d9552:	movsd  QWORD PTR [rsp+0x60],xmm1
  1d9558:	mov    rax,r12
  1d955b:	mul    r15
  1d955e:	mov    rbp,rax
  1d9561:	jo     1d9a95 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  1d9567:	mul    r13
  1d956a:	seto   cl
  1d956d:	not    cl
  1d956f:	cmp    rax,0x1001
  1d9575:	setb   al
  1d9578:	test   cl,al
  1d957a:	jne    1d95d7 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5e7>
  1d957c:	mov    rdx,QWORD PTR [rip+0x371a15]        # 54af98 <_DYNAMIC+0x598>
  1d9583:	mov    rax,QWORD PTR [rdx]
  1d9586:	test   rax,rax
  1d9589:	je     1d9aa1 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  1d958f:	mov    cl,0x1
  1d9591:	test   eax,0x80000
  1d9596:	jne    1d9ba2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  1d959c:	mov    rax,QWORD PTR [rdx]
  1d959f:	test   rax,rax
  1d95a2:	je     1d9afc <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb0c>
  1d95a8:	test   ax,ax
  1d95ab:	jns    1d95c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1d95ad:	mov    rax,QWORD PTR [rdx]
  1d95b0:	test   rax,rax
  1d95b3:	je     1d9b53 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb63>
  1d95b9:	bt     rax,0x37
  1d95be:	jb     1d9ba0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb0>
  1d95c4:	cmp    BYTE PTR [rsp+0x30],0x0
  1d95c9:	jne    1d987c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  1d95cf:	xorps  xmm0,xmm0
  1d95d2:	jmp    1d9884 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  1d95d7:	cmp    BYTE PTR [rsp+0x30],0x0
  1d95dc:	mov    ecx,DWORD PTR [rsp+0x38]
  1d95e0:	jne    1d9645 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x655>
  1d95e2:	xorps  xmm0,xmm0
  1d95e5:	movsd  QWORD PTR [rsp+0x30],xmm0
  1d95eb:	mov    rax,r13
  1d95ee:	cmp    QWORD PTR [rsp+0x8],r14
  1d95f3:	jb     1d965d <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66d>
  1d95f5:	mov    ebp,r9d
  1d95f8:	mov    r9d,ecx
  1d95fb:	mov    rcx,QWORD PTR [rsp+0x18]
  1d9600:	mov    QWORD PTR [rsp+0x38],rcx
  1d9605:	mov    QWORD PTR [rsp+0x40],rsi
  1d960a:	mov    QWORD PTR [rsp+0x58],r8
  1d960f:	mov    rsi,rdi
  1d9612:	mov    rcx,QWORD PTR [rsp+0x28]
  1d9617:	mov    r8,QWORD PTR [rsp+0x10]
  1d961c:	mov    rdx,QWORD PTR [rsp+0x8]
  1d9621:	mov    QWORD PTR [rsp+0x10],rdx
  1d9626:	mov    QWORD PTR [rsp+0x8],r14
  1d962b:	mov    r13,r15
  1d962e:	mov    r15,r12
  1d9631:	jmp    1d9685 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x695>
  1d9633:	cmp    r14,0x1
  1d9637:	jne    1d97b6 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7c6>
  1d963d:	mov    rax,r12
  1d9640:	jmp    1d9a11 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa21>
  1d9645:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe6645b]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1d964d:	movsd  QWORD PTR [rsp+0x30],xmm0
  1d9653:	mov    rax,r13
  1d9656:	cmp    QWORD PTR [rsp+0x8],r14
  1d965b:	jae    1d95f5 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x605>
  1d965d:	mov    ebp,ecx
  1d965f:	mov    rcx,QWORD PTR [rsp+0x28]
  1d9664:	mov    QWORD PTR [rsp+0x38],rcx
  1d9669:	mov    QWORD PTR [rsp+0x40],rdi
  1d966e:	mov    rcx,QWORD PTR [rsp+0x10]
  1d9673:	mov    QWORD PTR [rsp+0x58],rcx
  1d9678:	mov    QWORD PTR [rsp+0x10],r14
  1d967d:	mov    r13,r12
  1d9680:	mov    rcx,QWORD PTR [rsp+0x18]
  1d9685:	movsd  QWORD PTR [rsp+0x20],xmm1
  1d968b:	mov    QWORD PTR [rsp+0x48],rsi
  1d9690:	mov    QWORD PTR [rsp+0x50],r8
  1d9695:	mov    r14d,r9d
  1d9698:	mov    QWORD PTR [rsp+0x18],rcx
  1d969d:	cmp    rcx,0x1
  1d96a1:	jne    1d96cb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  1d96a3:	cmp    QWORD PTR [rsp+0x8],0x1
  1d96a9:	jne    1d96cb <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6db>
  1d96ab:	lea    r8,[rip+0x3664ce]        # 53fb80 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x410>
  1d96b2:	lea    rdi,[rsp+0x78]
  1d96b7:	mov    rsi,r15
  1d96ba:	mov    rdx,r13
  1d96bd:	mov    r12,rax
  1d96c0:	mov    rcx,rax
  1d96c3:	call   QWORD PTR [rip+0x371a17]        # 54b0e0 <_DYNAMIC+0x6e0>
  1d96c9:	jmp    1d96e9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f9>
  1d96cb:	lea    r8,[rip+0x3664c6]        # 53fb98 <anon.2fb42cb4e2e00236b157a5fd65326bc6.270.llvm.7523574441357572234+0x428>
  1d96d2:	lea    rdi,[rsp+0x78]
  1d96d7:	mov    rsi,r15
  1d96da:	mov    rdx,r13
  1d96dd:	mov    r12,rax
  1d96e0:	mov    rcx,rax
  1d96e3:	call   QWORD PTR [rip+0x3719ff]        # 54b0e8 <_DYNAMIC+0x6e8>
  1d96e9:	lea    rdi,[rsp+0x80]
  1d96f1:	mov    rsi,QWORD PTR [rsp+0xa0]
  1d96f9:	mov    rdx,QWORD PTR [rsp+0xa8]
  1d9701:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  1d9709:	sub    rsp,0x70
  1d970d:	movups XMMWORD PTR [rsp+0x58],xmm0
  1d9712:	movzx  eax,bpl
  1d9716:	mov    DWORD PTR [rsp+0x50],eax
  1d971a:	movzx  eax,r14b
  1d971e:	mov    DWORD PTR [rsp+0x48],eax
  1d9722:	mov    rax,QWORD PTR [rsp+0xa8]
  1d972a:	mov    QWORD PTR [rsp+0x40],rax
  1d972f:	mov    rax,QWORD PTR [rsp+0xb0]
  1d9737:	mov    QWORD PTR [rsp+0x38],rax
  1d973c:	mov    rax,QWORD PTR [rsp+0xc8]
  1d9744:	mov    QWORD PTR [rsp+0x30],rax
  1d9749:	mov    rax,QWORD PTR [rsp+0xb8]
  1d9751:	mov    QWORD PTR [rsp+0x28],rax
  1d9756:	mov    rax,QWORD PTR [rsp+0x88]
  1d975e:	mov    QWORD PTR [rsp+0x20],rax
  1d9763:	mov    rax,QWORD PTR [rsp+0xc0]
  1d976b:	mov    QWORD PTR [rsp+0x18],rax
  1d9770:	mov    rax,QWORD PTR [rsp+0x80]
  1d9778:	mov    QWORD PTR [rsp+0x10],rax
  1d977d:	mov    rax,QWORD PTR [rsp+0x78]
  1d9782:	mov    QWORD PTR [rsp+0x8],rax
  1d9787:	mov    QWORD PTR [rsp],rbx
  1d978b:	mov    r8,r13
  1d978e:	mov    r9,r12
  1d9791:	mov    rcx,r15
  1d9794:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  1d979d:	movsd  xmm1,QWORD PTR [rsp+0x90]
  1d97a6:	call   QWORD PTR [rsp+0xe8]
  1d97ad:	add    rsp,0x70
  1d97b1:	jmp    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d97b6:	lea    rax,[r12-0x1]
  1d97bb:	mov    ecx,r12d
  1d97be:	and    ecx,0x3
  1d97c1:	and    r12,0xfffffffffffffffc
  1d97c5:	lea    rdx,[r14*8+0x0]
  1d97cd:	lea    rsi,[rdx+rdx*2]
  1d97d1:	shl    QWORD PTR [rsp+0x8],0x3
  1d97d7:	mov    rdi,r14
  1d97da:	shl    rdi,0x5
  1d97de:	mov    r8,r14
  1d97e1:	shl    r8,0x4
  1d97e5:	xor    r9d,r9d
  1d97e8:	jmp    1d9801 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  1d97ea:	nop    WORD PTR [rax+rax*1+0x0]
  1d97f0:	inc    r9
  1d97f3:	add    rbx,QWORD PTR [rsp+0x8]
  1d97f8:	cmp    r9,r15
  1d97fb:	je     1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d9801:	cmp    rax,0x3
  1d9805:	jae    1d9810 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  1d9807:	xor    r10d,r10d
  1d980a:	jmp    1d9850 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  1d980c:	nop    DWORD PTR [rax+0x0]
  1d9810:	mov    r11,rbx
  1d9813:	xor    r10d,r10d
  1d9816:	cs nop WORD PTR [rax+rax*1+0x0]
  1d9820:	mov    QWORD PTR [r11],0x0
  1d9827:	mov    QWORD PTR [r11+r14*8],0x0
  1d982f:	mov    QWORD PTR [r11+r8*1],0x0
  1d9837:	add    r10,0x4
  1d983b:	mov    QWORD PTR [r11+rsi*1],0x0
  1d9843:	add    r11,rdi
  1d9846:	cmp    r12,r10
  1d9849:	jne    1d9820 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  1d984b:	test   rcx,rcx
  1d984e:	je     1d97f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1d9850:	imul   r10,rdx
  1d9854:	add    r10,rbx
  1d9857:	mov    r11,rcx
  1d985a:	nop    WORD PTR [rax+rax*1+0x0]
  1d9860:	mov    QWORD PTR [r10],0x0
  1d9867:	add    r10,rdx
  1d986a:	dec    r11
  1d986d:	jne    1d9860 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  1d986f:	jmp    1d97f0 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1d9874:	mov    rax,r12
  1d9877:	jmp    1d9a05 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa15>
  1d987c:	movsd  xmm0,QWORD PTR [rip+0xffffffffffe66224]        # 3faa8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.17307493437619026958+0xf8>
  1d9884:	xor    r11d,r11d
  1d9887:	test   r10,r10
  1d988a:	setne  dl
  1d988d:	cmp    QWORD PTR [rsp+0x8],r14
  1d9892:	jge    1d98a9 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8b9>
  1d9894:	mov    rcx,QWORD PTR [rsp+0x18]
  1d9899:	mov    rbp,rsi
  1d989c:	mov    rax,r8
  1d989f:	mov    r8,r14
  1d98a2:	mov    r9,QWORD PTR [rsp+0x28]
  1d98a7:	jmp    1d98e3 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8f3>
  1d98a9:	mov    rcx,QWORD PTR [rsp+0x28]
  1d98ae:	mov    rbp,rdi
  1d98b1:	mov    rax,QWORD PTR [rsp+0x10]
  1d98b6:	mov    QWORD PTR [rsp+0x28],rax
  1d98bb:	mov    r10,QWORD PTR [rsp+0x8]
  1d98c0:	mov    rax,r12
  1d98c3:	mov    r9,QWORD PTR [rsp+0x18]
  1d98c8:	mov    rdi,rsi
  1d98cb:	mov    QWORD PTR [rsp+0x10],r8
  1d98d0:	mov    r8,r10
  1d98d3:	mov    QWORD PTR [rsp+0x8],r14
  1d98d8:	mov    r12,r15
  1d98db:	mov    r15,rax
  1d98de:	mov    rax,QWORD PTR [rsp+0x28]
  1d98e3:	mov    r11b,dl
  1d98e6:	mov    QWORD PTR [rsp+0x18],r15
  1d98eb:	lea    rdx,[r15-0x1]
  1d98ef:	imul   rdx,rcx
  1d98f3:	mov    r14,rcx
  1d98f6:	neg    r14
  1d98f9:	mov    rsi,QWORD PTR [rsp+0x8]
  1d98fe:	test   rsi,rsi
  1d9901:	cmovns r14,rcx
  1d9905:	mov    rcx,rsi
  1d9908:	sar    rcx,0x3f
  1d990c:	and    rcx,rdx
  1d990f:	lea    rdx,[rax+rcx*8]
  1d9913:	lea    rax,[r12-0x1]
  1d9918:	imul   rax,r9
  1d991c:	mov    r15,r9
  1d991f:	neg    r15
  1d9922:	test   r8,r8
  1d9925:	cmovns r15,r9
  1d9929:	mov    rcx,r8
  1d992c:	sar    rcx,0x3f
  1d9930:	and    rcx,rax
  1d9933:	mov    rax,QWORD PTR [rsp+0x10]
  1d9938:	lea    rsi,[rax+rcx*8]
  1d993c:	test   rbp,rbp
  1d993f:	jns    1d995e <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x96e>
  1d9941:	lea    rax,[r13-0x1]
  1d9945:	mov    rcx,rbp
  1d9948:	imul   rcx,rax
  1d994c:	lea    rdx,[rdx+rcx*8]
  1d9950:	neg    rbp
  1d9953:	imul   rax,rdi
  1d9957:	lea    rsi,[rsi+rax*8]
  1d995b:	neg    rdi
  1d995e:	mov    QWORD PTR [rsp+0x28],rsi
  1d9963:	mov    QWORD PTR [rsp+0x10],rdx
  1d9968:	mov    QWORD PTR [rsp+0x40],rdi
  1d996d:	mov    rax,QWORD PTR [rip+0x3716b4]        # 54b028 <_DYNAMIC+0x628>
  1d9974:	mov    rax,QWORD PTR [rax]
  1d9977:	test   rax,rax
  1d997a:	jne    1d99b4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c4>
  1d997c:	movsd  QWORD PTR [rsp+0x20],xmm1
  1d9982:	movsd  QWORD PTR [rsp+0x38],xmm0
  1d9988:	mov    QWORD PTR [rsp+0x50],rbp
  1d998d:	mov    rbp,r11
  1d9990:	mov    QWORD PTR [rsp+0x48],r8
  1d9995:	call   QWORD PTR [rip+0x371695]        # 54b030 <_DYNAMIC+0x630>
  1d999b:	mov    r8,QWORD PTR [rsp+0x48]
  1d99a0:	mov    r11,rbp
  1d99a3:	mov    rbp,QWORD PTR [rsp+0x50]
  1d99a8:	movsd  xmm0,QWORD PTR [rsp+0x38]
  1d99ae:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1d99b4:	movzx  r10d,BYTE PTR [rsp+0x30]
  1d99ba:	mov    rdi,QWORD PTR [rsp+0x18]
  1d99bf:	mov    rsi,r12
  1d99c2:	mov    rdx,r13
  1d99c5:	mov    rcx,rbx
  1d99c8:	mov    r9,QWORD PTR [rsp+0x8]
  1d99cd:	push   QWORD PTR [rsp+0x148]
  1d99d4:	push   r11
  1d99d6:	push   0x0
  1d99d8:	push   0x0
  1d99da:	push   0x0
  1d99dc:	push   QWORD PTR [rsp+0x68]
  1d99e0:	push   r15
  1d99e2:	push   QWORD PTR [rsp+0x60]
  1d99e6:	push   r14
  1d99e8:	push   rbp
  1d99e9:	push   QWORD PTR [rsp+0x60]
  1d99ed:	push   r10
  1d99ef:	call   rax
  1d99f1:	add    rsp,0x60
  1d99f5:	jmp    1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d99fa:	mov    rax,r15
  1d99fd:	mov    r15,r12
  1d9a00:	mov    QWORD PTR [rsp+0x8],r14
  1d9a05:	mov    ecx,0x1
  1d9a0a:	sub    rcx,rax
  1d9a0d:	lea    rbx,[rbx+rcx*8]
  1d9a11:	lea    rcx,[rax-0x1]
  1d9a15:	mov    edx,eax
  1d9a17:	and    edx,0x3
  1d9a1a:	and    rax,0xfffffffffffffffc
  1d9a1e:	xor    esi,esi
  1d9a20:	xorps  xmm0,xmm0
  1d9a23:	jmp    1d9a3c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  1d9a25:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  1d9a30:	inc    rsi
  1d9a33:	cmp    rsi,r15
  1d9a36:	je     1d9c84 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc94>
  1d9a3c:	mov    rdi,rsi
  1d9a3f:	imul   rdi,QWORD PTR [rsp+0x8]
  1d9a45:	lea    rdi,[rbx+rdi*8]
  1d9a49:	cmp    rcx,0x3
  1d9a4d:	jb     1d9a79 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  1d9a4f:	xor    r8d,r8d
  1d9a52:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1d9a60:	movups XMMWORD PTR [rdi],xmm0
  1d9a63:	movups XMMWORD PTR [rdi+0x10],xmm0
  1d9a67:	add    rdi,0x20
  1d9a6b:	add    r8,0x4
  1d9a6f:	cmp    rax,r8
  1d9a72:	jne    1d9a60 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  1d9a74:	test   rdx,rdx
  1d9a77:	je     1d9a30 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1d9a79:	xor    r8d,r8d
  1d9a7c:	nop    DWORD PTR [rax+0x0]
  1d9a80:	mov    QWORD PTR [rdi],0x0
  1d9a87:	add    rdi,0x8
  1d9a8b:	inc    r8
  1d9a8e:	cmp    rdx,r8
  1d9a91:	jne    1d9a80 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  1d9a93:	jmp    1d9a30 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1d9a95:	mov    rax,0xffffffffffffffff
  1d9a9c:	jmp    1d9567 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x577>
  1d9aa1:	mov    DWORD PTR [rsp+0x58],r9d
  1d9aa6:	mov    QWORD PTR [rsp+0x40],rdi
  1d9aab:	mov    QWORD PTR [rsp+0x50],r8
  1d9ab0:	mov    QWORD PTR [rsp+0x48],rsi
  1d9ab5:	movsd  QWORD PTR [rsp+0x20],xmm1
  1d9abb:	call   QWORD PTR [rip+0x3714e7]        # 54afa8 <_DYNAMIC+0x5a8>
  1d9ac1:	mov    rdx,QWORD PTR [rip+0x3714d0]        # 54af98 <_DYNAMIC+0x598>
  1d9ac8:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1d9ace:	mov    rsi,QWORD PTR [rsp+0x48]
  1d9ad3:	mov    r10,QWORD PTR [rsp+0x148]
  1d9adb:	mov    r8,QWORD PTR [rsp+0x50]
  1d9ae0:	mov    rdi,QWORD PTR [rsp+0x40]
  1d9ae5:	mov    r9d,DWORD PTR [rsp+0x58]
  1d9aea:	mov    cl,0x1
  1d9aec:	test   eax,0x80000
  1d9af1:	je     1d959c <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5ac>
  1d9af7:	jmp    1d9ba2 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbb2>
  1d9afc:	mov    DWORD PTR [rsp+0x58],r9d
  1d9b01:	mov    QWORD PTR [rsp+0x40],rdi
  1d9b06:	mov    QWORD PTR [rsp+0x50],r8
  1d9b0b:	mov    QWORD PTR [rsp+0x48],rsi
  1d9b10:	movsd  QWORD PTR [rsp+0x20],xmm1
  1d9b16:	call   QWORD PTR [rip+0x37148c]        # 54afa8 <_DYNAMIC+0x5a8>
  1d9b1c:	mov    rdx,QWORD PTR [rip+0x371475]        # 54af98 <_DYNAMIC+0x598>
  1d9b23:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1d9b29:	mov    rsi,QWORD PTR [rsp+0x48]
  1d9b2e:	mov    r10,QWORD PTR [rsp+0x148]
  1d9b36:	mov    r8,QWORD PTR [rsp+0x50]
  1d9b3b:	mov    rdi,QWORD PTR [rsp+0x40]
  1d9b40:	mov    r9d,DWORD PTR [rsp+0x58]
  1d9b45:	test   ax,ax
  1d9b48:	js     1d95ad <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5bd>
  1d9b4e:	jmp    1d95c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1d9b53:	mov    DWORD PTR [rsp+0x58],r9d
  1d9b58:	mov    QWORD PTR [rsp+0x40],rdi
  1d9b5d:	mov    QWORD PTR [rsp+0x50],r8
  1d9b62:	mov    QWORD PTR [rsp+0x48],rsi
  1d9b67:	movsd  QWORD PTR [rsp+0x20],xmm1
  1d9b6d:	call   QWORD PTR [rip+0x371435]        # 54afa8 <_DYNAMIC+0x5a8>
  1d9b73:	movsd  xmm1,QWORD PTR [rsp+0x20]
  1d9b79:	mov    rsi,QWORD PTR [rsp+0x48]
  1d9b7e:	mov    r10,QWORD PTR [rsp+0x148]
  1d9b86:	mov    r8,QWORD PTR [rsp+0x50]
  1d9b8b:	mov    rdi,QWORD PTR [rsp+0x40]
  1d9b90:	mov    r9d,DWORD PTR [rsp+0x58]
  1d9b95:	bt     rax,0x37
  1d9b9a:	jae    1d95c4 <_RINvNtNtCsiVB0znSuPaP_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d4>
  1d9ba0:	xor    ecx,ecx
  1d9ba2:	imul   rbp,r13
  1d9ba6:	cmp    r10,0x1
  1d9baa:	adc    r10,0x0
  1d9bae:	cmp    rbp,0x8000
  1d9bb5:	mov    eax,0x1
  1d9bba:	cmovae rax,r10
  1d9bbe:	sub    rsp,0xa0
  1d9bc5:	lea    rdx,[rsp+0x100]
  1d9bcd:	mov    QWORD PTR [rsp+0x88],rdx
  1d9bd5:	movzx  edx,r9b
  1d9bd9:	mov    DWORD PTR [rsp+0x80],edx
  1d9be0:	mov    rdx,QWORD PTR [rsp+0xb8]
  1d9be8:	mov    QWORD PTR [rsp+0x78],rdx
  1d9bed:	mov    QWORD PTR [rsp+0x70],rsi
  1d9bf2:	mov    QWORD PTR [rsp+0x68],r8
  1d9bf7:	xorps  xmm0,xmm0
  1d9bfa:	movups XMMWORD PTR [rsp+0x58],xmm0
  1d9bff:	movzx  edx,BYTE PTR [rsp+0xd8]
  1d9c07:	mov    DWORD PTR [rsp+0x50],edx
  1d9c0b:	mov    QWORD PTR [rsp+0x48],rdi
  1d9c10:	mov    rdx,QWORD PTR [rsp+0xc8]
  1d9c18:	mov    QWORD PTR [rsp+0x40],rdx
  1d9c1d:	mov    rdx,QWORD PTR [rsp+0xb0]
  1d9c25:	mov    QWORD PTR [rsp+0x38],rdx
  1d9c2a:	movzx  edx,BYTE PTR [rsp+0xd0]
  1d9c32:	mov    DWORD PTR [rsp+0x30],edx
  1d9c36:	movups XMMWORD PTR [rsp+0x18],xmm0
  1d9c3b:	mov    rdx,QWORD PTR [rsp+0xa8]
  1d9c43:	mov    QWORD PTR [rsp+0x10],rdx
  1d9c48:	mov    QWORD PTR [rsp+0x8],r14
  1d9c4d:	mov    QWORD PTR [rsp],rbx
  1d9c51:	mov    QWORD PTR [rsp+0x90],rax
  1d9c59:	mov    DWORD PTR [rsp+0x28],0x2
  1d9c61:	movzx  edx,cl
  1d9c64:	mov    r8,r15
  1d9c67:	mov    edi,0x1
  1d9c6c:	mov    r9,r13
  1d9c6f:	mov    esi,0x1
  1d9c74:	mov    rcx,r12
  1d9c77:	call   QWORD PTR [rip+0x371323]        # 54afa0 <_DYNAMIC+0x5a0>
  1d9c7d:	add    rsp,0xa0
  1d9c84:	add    rsp,0x108
  1d9c8b:	pop    rbx
  1d9c8c:	pop    r12
  1d9c8e:	pop    r13
  1d9c90:	pop    r14
  1d9c92:	pop    r15
  1d9c94:	pop    rbp
  1d9c95:	ret
