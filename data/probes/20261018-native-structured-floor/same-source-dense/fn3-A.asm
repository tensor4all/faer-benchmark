
target/faer-rev/b7715c53ba75-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000101f40 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench>:
  101f40:	push   rbp
  101f41:	push   r15
  101f43:	push   r14
  101f45:	push   r13
  101f47:	push   r12
  101f49:	push   rbx
  101f4a:	sub    rsp,0x108
  101f51:	mov    DWORD PTR [rsp+0x30],esi
  101f55:	mov    r12,QWORD PTR [rdi+0x8]
  101f59:	test   r12,r12
  101f5c:	je     102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  101f62:	mov    r15,QWORD PTR [rdi+0x10]
  101f66:	test   r15,r15
  101f69:	je     102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  101f6f:	mov    rbx,QWORD PTR [rdi]
  101f72:	mov    r14,QWORD PTR [rdi+0x18]
  101f76:	mov    rax,QWORD PTR [rdi+0x20]
  101f7a:	mov    QWORD PTR [rsp+0x8],rax
  101f7f:	mov    r13,QWORD PTR [rdx+0x10]
  101f83:	test   r13,r13
  101f86:	je     10203e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xfe>
  101f8c:	mov    r11,r8
  101f8f:	mov    DWORD PTR [rsp+0x18],ecx
  101f93:	mov    rax,QWORD PTR [rdx]
  101f96:	mov    QWORD PTR [rsp+0x10],rax
  101f9b:	mov    rcx,QWORD PTR [rdx+0x8]
  101f9f:	mov    r8,QWORD PTR [rdx+0x18]
  101fa3:	test   r14,r14
  101fa6:	mov    QWORD PTR [rsp+0x28],rcx
  101fab:	jns    101fe9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa9>
  101fad:	lea    rax,[r12-0x1]
  101fb2:	imul   rax,r14
  101fb6:	neg    r14
  101fb9:	xor    edi,edi
  101fbb:	mov    r10,rcx
  101fbe:	sub    r10,0x1
  101fc2:	cmovb  r10,rdi
  101fc6:	lea    rbx,[rbx+rax*8]
  101fca:	mov    rax,r8
  101fcd:	imul   rax,r10
  101fd1:	cmp    r10,rcx
  101fd4:	cmove  rax,rdi
  101fd8:	mov    rcx,QWORD PTR [rsp+0x10]
  101fdd:	lea    rcx,[rcx+rax*8]
  101fe1:	mov    QWORD PTR [rsp+0x10],rcx
  101fe6:	neg    r8
  101fe9:	mov    QWORD PTR [rsp+0x38],r8
  101fee:	mov    rdi,QWORD PTR [rdx+0x20]
  101ff2:	mov    r8,QWORD PTR [r11]
  101ff5:	mov    rax,QWORD PTR [r11+0x8]
  101ff9:	mov    QWORD PTR [rsp+0x20],rax
  101ffe:	mov    rcx,QWORD PTR [r11+0x10]
  102002:	mov    rax,QWORD PTR [r11+0x20]
  102006:	cmp    QWORD PTR [rsp+0x8],0x0
  10200c:	js     102095 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x155>
  102012:	mov    rsi,QWORD PTR [r11+0x18]
  102016:	test   rdi,rdi
  102019:	js     102101 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x1c1>
  10201f:	mov    r10,QWORD PTR [rsp+0x148]
  102027:	mov    r11,QWORD PTR [rsp+0x140]
  10202f:	cmp    r15,0x1
  102033:	je     102186 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x246>
  102039:	jmp    102274 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  10203e:	cmp    BYTE PTR [rsp+0x30],0x0
  102043:	jne    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  102049:	cmp    r12,0x1
  10204d:	je     102063 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x123>
  10204f:	cmp    r14,0xffffffffffffffff
  102053:	je     1027c4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x884>
  102059:	cmp    r14,0x1
  10205d:	je     10258e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x64e>
  102063:	cmp    r15,0x1
  102067:	je     102584 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  10206d:	cmp    QWORD PTR [rsp+0x8],0xffffffffffffffff
  102073:	je     102947 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa07>
  102079:	cmp    QWORD PTR [rsp+0x8],0x1
  10207f:	jne    102584 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x644>
  102085:	mov    rax,r15
  102088:	mov    r15,r12
  10208b:	mov    QWORD PTR [rsp+0x8],r14
  102090:	jmp    10295e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  102095:	lea    rdx,[r15-0x1]
  102099:	mov    rsi,QWORD PTR [rsp+0x8]
  10209e:	imul   rdx,rsi
  1020a2:	lea    rbx,[rbx+rdx*8]
  1020a6:	neg    rsi
  1020a9:	mov    QWORD PTR [rsp+0x8],rsi
  1020ae:	xor    edx,edx
  1020b0:	mov    r10d,r9d
  1020b3:	mov    r9,r8
  1020b6:	mov    r8,rdi
  1020b9:	mov    rdi,rcx
  1020bc:	sub    rdi,0x1
  1020c0:	cmovb  rdi,rdx
  1020c4:	mov    rbp,r13
  1020c7:	mov    r13,rax
  1020ca:	imul   r13,rdi
  1020ce:	cmp    rdi,rcx
  1020d1:	mov    rdi,r8
  1020d4:	mov    r8,r9
  1020d7:	mov    r9d,r10d
  1020da:	mov    r10,QWORD PTR [rsp+0x20]
  1020df:	cmove  r13,rdx
  1020e3:	test   r10,r10
  1020e6:	cmove  r13,r10
  1020ea:	lea    r8,[r8+r13*8]
  1020ee:	mov    r13,rbp
  1020f1:	neg    rax
  1020f4:	mov    rsi,QWORD PTR [r11+0x18]
  1020f8:	test   rdi,rdi
  1020fb:	jns    10201f <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xdf>
  102101:	lea    rdx,[r13-0x1]
  102105:	imul   rdx,rdi
  102109:	mov    r10,QWORD PTR [rsp+0x28]
  10210e:	test   r10,r10
  102111:	cmove  rdx,r10
  102115:	mov    r10,rax
  102118:	mov    rax,QWORD PTR [rsp+0x10]
  10211d:	lea    rax,[rax+rdx*8]
  102121:	mov    QWORD PTR [rsp+0x10],rax
  102126:	neg    rdi
  102129:	xor    edx,edx
  10212b:	mov    rax,rdi
  10212e:	mov    rbp,r13
  102131:	mov    r13,rsi
  102134:	mov    rsi,QWORD PTR [rsp+0x20]
  102139:	mov    rdi,rsi
  10213c:	sub    rdi,0x1
  102140:	cmovb  rdi,rdx
  102144:	mov    r11,r13
  102147:	imul   r11,rdi
  10214b:	test   rcx,rcx
  10214e:	cmove  r11,rcx
  102152:	cmp    rdi,rsi
  102155:	mov    rsi,r13
  102158:	mov    r13,rbp
  10215b:	mov    rdi,rax
  10215e:	mov    rax,r10
  102161:	cmove  r11,rdx
  102165:	lea    r8,[r8+r11*8]
  102169:	neg    rsi
  10216c:	mov    r10,QWORD PTR [rsp+0x148]
  102174:	mov    r11,QWORD PTR [rsp+0x140]
  10217c:	cmp    r15,0x1
  102180:	jne    102274 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  102186:	cmp    QWORD PTR [rsp+0x38],0x1
  10218c:	jne    1021ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  10218e:	cmp    r14,0x1
  102192:	jne    1021ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  102194:	test   rbx,rbx
  102197:	je     1021ff <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x2bf>
  102199:	mov    rax,QWORD PTR [rsp+0x10]
  10219e:	mov    QWORD PTR [rsp+0x78],rax
  1021a3:	mov    rax,QWORD PTR [rsp+0x28]
  1021a8:	mov    QWORD PTR [rsp+0x80],rax
  1021b0:	mov    QWORD PTR [rsp+0x88],r13
  1021b8:	mov    QWORD PTR [rsp+0x90],rdi
  1021c0:	mov    QWORD PTR [rsp+0x60],r8
  1021c5:	mov    rax,QWORD PTR [rsp+0x20]
  1021ca:	mov    QWORD PTR [rsp+0x68],rax
  1021cf:	mov    QWORD PTR [rsp+0x70],rsi
  1021d4:	sub    rsp,0x8
  1021d8:	movzx  eax,r9b
  1021dc:	movzx  edx,BYTE PTR [rsp+0x38]
  1021e1:	movzx  r8d,BYTE PTR [rsp+0x20]
  1021e7:	lea    rcx,[rsp+0x80]
  1021ef:	lea    r9,[rsp+0x68]
  1021f4:	mov    rdi,rbx
  1021f7:	mov    rsi,r12
  1021fa:	jmp    1022f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3b0>
  1021ff:	cmp    rdi,0x1
  102203:	jne    102274 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  102205:	cmp    rsi,0x1
  102209:	jne    102274 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  10220b:	test   r8,r8
  10220e:	je     102274 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x334>
  102210:	mov    rax,QWORD PTR [rsp+0x10]
  102215:	mov    QWORD PTR [rsp+0x78],rax
  10221a:	mov    rax,QWORD PTR [rsp+0x28]
  10221f:	mov    QWORD PTR [rsp+0x80],rax
  102227:	mov    QWORD PTR [rsp+0x88],r13
  10222f:	mov    rax,QWORD PTR [rsp+0x38]
  102234:	mov    QWORD PTR [rsp+0x90],rax
  10223c:	mov    QWORD PTR [rsp+0x60],rbx
  102241:	mov    QWORD PTR [rsp+0x68],r12
  102246:	mov    QWORD PTR [rsp+0x70],r14
  10224b:	sub    rsp,0x8
  10224f:	movzx  eax,r9b
  102253:	movzx  esi,BYTE PTR [rsp+0x38]
  102258:	movzx  ecx,BYTE PTR [rsp+0x20]
  10225d:	lea    rdi,[rsp+0x68]
  102262:	lea    rdx,[rsp+0x80]
  10226a:	mov    r9,QWORD PTR [rsp+0x28]
  10226f:	jmp    102377 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x437>
  102274:	cmp    r12,0x1
  102278:	jne    10238a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  10227e:	xor    edx,edx
  102280:	cmp    QWORD PTR [rsp+0x8],0x1
  102286:	cmove  rdx,rbx
  10228a:	cmp    rax,0x1
  10228e:	jne    102303 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  102290:	test   rdx,rdx
  102293:	je     102303 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x3c3>
  102295:	mov    QWORD PTR [rsp+0x78],r8
  10229a:	mov    QWORD PTR [rsp+0x80],rcx
  1022a2:	mov    rax,QWORD PTR [rsp+0x20]
  1022a7:	mov    QWORD PTR [rsp+0x88],rax
  1022af:	mov    QWORD PTR [rsp+0x90],rsi
  1022b7:	mov    rax,QWORD PTR [rsp+0x10]
  1022bc:	mov    QWORD PTR [rsp+0x60],rax
  1022c1:	mov    QWORD PTR [rsp+0x68],r13
  1022c6:	mov    QWORD PTR [rsp+0x70],rdi
  1022cb:	sub    rsp,0x8
  1022cf:	movzx  eax,BYTE PTR [rsp+0x20]
  1022d4:	movzx  edx,BYTE PTR [rsp+0x38]
  1022d9:	movzx  r8d,r9b
  1022dd:	lea    rcx,[rsp+0x80]
  1022e5:	lea    r9,[rsp+0x68]
  1022ea:	mov    rdi,rbx
  1022ed:	mov    rsi,r15
  1022f0:	push   r10
  1022f2:	push   r11
  1022f4:	push   rax
  1022f5:	call   149480 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_colmajor6matvecdECscfHK10Grmvq_6fbench>
  1022fa:	add    rsp,0x20
  1022fe:	jmp    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  102303:	xor    edx,edx
  102305:	cmp    rdi,0x1
  102309:	cmove  rdx,QWORD PTR [rsp+0x10]
  10230f:	cmp    rsi,0x1
  102313:	jne    10238a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  102315:	test   rdx,rdx
  102318:	je     10238a <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x44a>
  10231a:	mov    QWORD PTR [rsp+0x78],r8
  10231f:	mov    QWORD PTR [rsp+0x80],rcx
  102327:	mov    rcx,QWORD PTR [rsp+0x20]
  10232c:	mov    QWORD PTR [rsp+0x88],rcx
  102334:	mov    QWORD PTR [rsp+0x90],rax
  10233c:	mov    QWORD PTR [rsp+0x60],rbx
  102341:	mov    QWORD PTR [rsp+0x68],r15
  102346:	mov    rax,QWORD PTR [rsp+0x8]
  10234b:	mov    QWORD PTR [rsp+0x70],rax
  102350:	sub    rsp,0x8
  102354:	movzx  eax,BYTE PTR [rsp+0x20]
  102359:	movzx  esi,BYTE PTR [rsp+0x38]
  10235e:	movzx  ecx,r9b
  102362:	lea    rdi,[rsp+0x68]
  102367:	lea    rdx,[rsp+0x80]
  10236f:	mov    r8,QWORD PTR [rsp+0x18]
  102374:	mov    r9,r13
  102377:	push   r10
  102379:	push   r11
  10237b:	push   rax
  10237c:	call   1f94a0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul15matvec_rowmajor6matvecdECscfHK10Grmvq_6fbench>
  102381:	add    rsp,0x20
  102385:	jmp    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  10238a:	cmp    r13,0x1
  10238e:	jne    102498 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  102394:	xor    edx,edx
  102396:	cmp    r14,0x1
  10239a:	cmove  rdx,rbx
  10239e:	cmp    QWORD PTR [rsp+0x38],0x1
  1023a4:	jne    10240d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1023a6:	test   rdx,rdx
  1023a9:	je     10240d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x4cd>
  1023ab:	mov    QWORD PTR [rsp+0x78],rdx
  1023b0:	mov    QWORD PTR [rsp+0x80],r12
  1023b8:	mov    QWORD PTR [rsp+0x88],r15
  1023c0:	mov    rdx,QWORD PTR [rsp+0x8]
  1023c5:	mov    QWORD PTR [rsp+0x90],rdx
  1023cd:	mov    QWORD PTR [rsp+0x60],r8
  1023d2:	mov    QWORD PTR [rsp+0x68],rcx
  1023d7:	mov    QWORD PTR [rsp+0x70],rax
  1023dc:	sub    rsp,0x8
  1023e0:	mov    r14,r10
  1023e3:	movzx  r10d,r9b
  1023e7:	movzx  esi,BYTE PTR [rsp+0x38]
  1023ec:	movzx  r8d,BYTE PTR [rsp+0x20]
  1023f2:	lea    rdi,[rsp+0x80]
  1023fa:	lea    r9,[rsp+0x68]
  1023ff:	mov    rdx,QWORD PTR [rsp+0x18]
  102404:	mov    rcx,QWORD PTR [rsp+0x30]
  102409:	push   r14
  10240b:	jmp    102486 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x546>
  10240d:	xor    edx,edx
  10240f:	cmp    QWORD PTR [rsp+0x8],0x1
  102415:	cmove  rdx,rbx
  102419:	cmp    rax,0x1
  10241d:	jne    102498 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  10241f:	test   rdx,rdx
  102422:	je     102498 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x558>
  102424:	mov    QWORD PTR [rsp+0x78],rdx
  102429:	mov    QWORD PTR [rsp+0x80],r15
  102431:	mov    QWORD PTR [rsp+0x88],r12
  102439:	mov    QWORD PTR [rsp+0x90],r14
  102441:	mov    rax,QWORD PTR [rsp+0x10]
  102446:	mov    QWORD PTR [rsp+0x60],rax
  10244b:	mov    rax,QWORD PTR [rsp+0x28]
  102450:	mov    QWORD PTR [rsp+0x68],rax
  102455:	mov    rax,QWORD PTR [rsp+0x38]
  10245a:	mov    QWORD PTR [rsp+0x70],rax
  10245f:	sub    rsp,0x8
  102463:	mov    rax,r10
  102466:	movzx  r10d,BYTE PTR [rsp+0x20]
  10246c:	movzx  esi,BYTE PTR [rsp+0x38]
  102471:	mov    rdx,r8
  102474:	movzx  r8d,r9b
  102478:	lea    rdi,[rsp+0x80]
  102480:	lea    r9,[rsp+0x68]
  102485:	push   rax
  102486:	push   r11
  102488:	push   r10
  10248a:	call   1484a0 <_RINvNtNtNtCsjouqPOLJnB9_4faer6linalg6matmul11rank_update11rank_updatedECscfHK10Grmvq_6fbench>
  10248f:	add    rsp,0x20
  102493:	jmp    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  102498:	mov    QWORD PTR [rsp+0x20],rax
  10249d:	movsd  xmm1,QWORD PTR [r11]
  1024a2:	mov    rax,r12
  1024a5:	mul    r15
  1024a8:	mov    rbp,rax
  1024ab:	movsd  QWORD PTR [rsp+0x60],xmm1
  1024b1:	seto   r11b
  1024b5:	jo     1029e5 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xaa5>
  1024bb:	mul    r13
  1024be:	seto   cl
  1024c1:	not    cl
  1024c3:	cmp    rax,0x1001
  1024c9:	setb   al
  1024cc:	test   cl,al
  1024ce:	jne    10252b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5eb>
  1024d0:	mov    rdx,QWORD PTR [rip+0x4497a9]        # 54bc80 <_DYNAMIC+0x498>
  1024d7:	mov    rax,QWORD PTR [rdx]
  1024da:	test   rax,rax
  1024dd:	je     1029f1 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xab1>
  1024e3:	mov    cl,0x1
  1024e5:	test   eax,0x80000
  1024ea:	jne    102b13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  1024f0:	mov    rax,QWORD PTR [rdx]
  1024f3:	test   rax,rax
  1024f6:	je     102a57 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb17>
  1024fc:	test   ax,ax
  1024ff:	jns    102518 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  102501:	mov    rax,QWORD PTR [rdx]
  102504:	test   rax,rax
  102507:	je     102ab9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xb79>
  10250d:	bt     rax,0x37
  102512:	jb     102b11 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd1>
  102518:	cmp    BYTE PTR [rsp+0x30],0x0
  10251d:	jne    1027cc <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x88c>
  102523:	xorps  xmm0,xmm0
  102526:	jmp    1027d4 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x894>
  10252b:	cmp    BYTE PTR [rsp+0x30],0x0
  102530:	mov    eax,DWORD PTR [rsp+0x18]
  102534:	jne    102596 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x656>
  102536:	xorps  xmm0,xmm0
  102539:	movsd  QWORD PTR [rsp+0x30],xmm0
  10253f:	cmp    QWORD PTR [rsp+0x8],r14
  102544:	jb     1025ab <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x66b>
  102546:	mov    ebp,r9d
  102549:	mov    r9d,eax
  10254c:	mov    rax,QWORD PTR [rsp+0x20]
  102551:	mov    QWORD PTR [rsp+0x18],rax
  102556:	mov    QWORD PTR [rsp+0x40],rsi
  10255b:	mov    QWORD PTR [rsp+0x58],r8
  102560:	mov    rsi,rdi
  102563:	mov    rax,QWORD PTR [rsp+0x38]
  102568:	mov    r8,QWORD PTR [rsp+0x10]
  10256d:	mov    rcx,QWORD PTR [rsp+0x8]
  102572:	mov    QWORD PTR [rsp+0x10],rcx
  102577:	mov    QWORD PTR [rsp+0x8],r14
  10257c:	mov    r14,r15
  10257f:	mov    r15,r12
  102582:	jmp    1025d3 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x693>
  102584:	cmp    r14,0x1
  102588:	jne    1026fe <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x7be>
  10258e:	mov    rax,r12
  102591:	jmp    10295e <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa1e>
  102596:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff3d63a]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
  10259e:	movsd  QWORD PTR [rsp+0x30],xmm0
  1025a4:	cmp    QWORD PTR [rsp+0x8],r14
  1025a9:	jae    102546 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x606>
  1025ab:	mov    ebp,eax
  1025ad:	mov    rax,QWORD PTR [rsp+0x38]
  1025b2:	mov    QWORD PTR [rsp+0x18],rax
  1025b7:	mov    QWORD PTR [rsp+0x40],rdi
  1025bc:	mov    rax,QWORD PTR [rsp+0x10]
  1025c1:	mov    QWORD PTR [rsp+0x58],rax
  1025c6:	mov    QWORD PTR [rsp+0x10],r14
  1025cb:	mov    r14,r12
  1025ce:	mov    rax,QWORD PTR [rsp+0x20]
  1025d3:	movsd  QWORD PTR [rsp+0x28],xmm1
  1025d9:	mov    QWORD PTR [rsp+0x48],rsi
  1025de:	mov    QWORD PTR [rsp+0x50],r8
  1025e3:	mov    r12d,r9d
  1025e6:	mov    QWORD PTR [rsp+0x20],rax
  1025eb:	cmp    rax,0x1
  1025ef:	jne    102616 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1025f1:	cmp    QWORD PTR [rsp+0x8],0x1
  1025f7:	jne    102616 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6d6>
  1025f9:	lea    r8,[rip+0x42f1b8]        # 5317b8 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x410>
  102600:	lea    rdi,[rsp+0x78]
  102605:	mov    rsi,r15
  102608:	mov    rdx,r14
  10260b:	mov    rcx,r13
  10260e:	call   QWORD PTR [rip+0x4496a4]        # 54bcb8 <_DYNAMIC+0x4d0>
  102614:	jmp    102631 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x6f1>
  102616:	lea    r8,[rip+0x42f1b3]        # 5317d0 <anon.fa098ff9344c1a267df3ea02ec15655f.270.llvm.15093372747994916050+0x428>
  10261d:	lea    rdi,[rsp+0x78]
  102622:	mov    rsi,r15
  102625:	mov    rdx,r14
  102628:	mov    rcx,r13
  10262b:	call   QWORD PTR [rip+0x44968f]        # 54bcc0 <_DYNAMIC+0x4d8>
  102631:	lea    rdi,[rsp+0x80]
  102639:	mov    rsi,QWORD PTR [rsp+0xa0]
  102641:	mov    rdx,QWORD PTR [rsp+0xa8]
  102649:	movups xmm0,XMMWORD PTR [rsp+0xb0]
  102651:	sub    rsp,0x70
  102655:	movups XMMWORD PTR [rsp+0x58],xmm0
  10265a:	movzx  eax,bpl
  10265e:	mov    DWORD PTR [rsp+0x50],eax
  102662:	movzx  eax,r12b
  102666:	mov    DWORD PTR [rsp+0x48],eax
  10266a:	mov    rax,QWORD PTR [rsp+0x88]
  102672:	mov    QWORD PTR [rsp+0x40],rax
  102677:	mov    rax,QWORD PTR [rsp+0xb0]
  10267f:	mov    QWORD PTR [rsp+0x38],rax
  102684:	mov    rax,QWORD PTR [rsp+0xc8]
  10268c:	mov    QWORD PTR [rsp+0x30],rax
  102691:	mov    rax,QWORD PTR [rsp+0xb8]
  102699:	mov    QWORD PTR [rsp+0x28],rax
  10269e:	mov    rax,QWORD PTR [rsp+0x90]
  1026a6:	mov    QWORD PTR [rsp+0x20],rax
  1026ab:	mov    rax,QWORD PTR [rsp+0xc0]
  1026b3:	mov    QWORD PTR [rsp+0x18],rax
  1026b8:	mov    rax,QWORD PTR [rsp+0x80]
  1026c0:	mov    QWORD PTR [rsp+0x10],rax
  1026c5:	mov    rax,QWORD PTR [rsp+0x78]
  1026ca:	mov    QWORD PTR [rsp+0x8],rax
  1026cf:	mov    QWORD PTR [rsp],rbx
  1026d3:	mov    r8,r14
  1026d6:	mov    r9,r13
  1026d9:	mov    rcx,r15
  1026dc:	movsd  xmm0,QWORD PTR [rsp+0xa0]
  1026e5:	movsd  xmm1,QWORD PTR [rsp+0x98]
  1026ee:	call   QWORD PTR [rsp+0xe8]
  1026f5:	add    rsp,0x70
  1026f9:	jmp    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  1026fe:	lea    rax,[r12-0x1]
  102703:	mov    ecx,r12d
  102706:	and    ecx,0x3
  102709:	and    r12,0xfffffffffffffffc
  10270d:	lea    rdx,[r14*8+0x0]
  102715:	lea    rsi,[rdx+rdx*2]
  102719:	shl    QWORD PTR [rsp+0x8],0x3
  10271f:	mov    rdi,r14
  102722:	shl    rdi,0x5
  102726:	mov    r8,r14
  102729:	shl    r8,0x4
  10272d:	xor    r9d,r9d
  102730:	jmp    102751 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x811>
  102732:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  102740:	inc    r9
  102743:	add    rbx,QWORD PTR [rsp+0x8]
  102748:	cmp    r9,r15
  10274b:	je     102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  102751:	cmp    rax,0x3
  102755:	jae    102760 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x820>
  102757:	xor    r10d,r10d
  10275a:	jmp    1027a0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x860>
  10275c:	nop    DWORD PTR [rax+0x0]
  102760:	mov    r11,rbx
  102763:	xor    r10d,r10d
  102766:	cs nop WORD PTR [rax+rax*1+0x0]
  102770:	mov    QWORD PTR [r11],0x0
  102777:	mov    QWORD PTR [r11+r14*8],0x0
  10277f:	mov    QWORD PTR [r11+r8*1],0x0
  102787:	add    r10,0x4
  10278b:	mov    QWORD PTR [r11+rsi*1],0x0
  102793:	add    r11,rdi
  102796:	cmp    r12,r10
  102799:	jne    102770 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x830>
  10279b:	test   rcx,rcx
  10279e:	je     102740 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1027a0:	imul   r10,rdx
  1027a4:	add    r10,rbx
  1027a7:	mov    r11,rcx
  1027aa:	nop    WORD PTR [rax+rax*1+0x0]
  1027b0:	mov    QWORD PTR [r10],0x0
  1027b7:	add    r10,rdx
  1027ba:	dec    r11
  1027bd:	jne    1027b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x870>
  1027bf:	jmp    102740 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x800>
  1027c4:	mov    rax,r12
  1027c7:	jmp    102952 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa12>
  1027cc:	movsd  xmm0,QWORD PTR [rip+0xfffffffffff3d404]        # 3fbd8 <anon.2d9d246202f19b33524a5205ffc23259.152.llvm.14506286412837498760+0x108>
  1027d4:	xor    r11d,r11d
  1027d7:	test   r10,r10
  1027da:	setne  dl
  1027dd:	cmp    QWORD PTR [rsp+0x8],r14
  1027e2:	jge    1027fe <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8be>
  1027e4:	mov    rcx,QWORD PTR [rsp+0x20]
  1027e9:	mov    QWORD PTR [rsp+0x18],rsi
  1027ee:	mov    rax,r8
  1027f1:	mov    r8,r14
  1027f4:	mov    rbp,r15
  1027f7:	mov    r9,QWORD PTR [rsp+0x38]
  1027fc:	jmp    10282d <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x8ed>
  1027fe:	mov    rcx,QWORD PTR [rsp+0x38]
  102803:	mov    QWORD PTR [rsp+0x18],rdi
  102808:	mov    rax,QWORD PTR [rsp+0x10]
  10280d:	mov    r10,QWORD PTR [rsp+0x8]
  102812:	mov    rbp,r12
  102815:	mov    r9,QWORD PTR [rsp+0x20]
  10281a:	mov    rdi,rsi
  10281d:	mov    QWORD PTR [rsp+0x10],r8
  102822:	mov    r8,r10
  102825:	mov    QWORD PTR [rsp+0x8],r14
  10282a:	mov    r12,r15
  10282d:	mov    r11b,dl
  102830:	lea    rdx,[rbp-0x1]
  102834:	imul   rdx,rcx
  102838:	mov    r14,rcx
  10283b:	neg    r14
  10283e:	mov    rsi,QWORD PTR [rsp+0x8]
  102843:	test   rsi,rsi
  102846:	cmovns r14,rcx
  10284a:	mov    rcx,rsi
  10284d:	sar    rcx,0x3f
  102851:	and    rcx,rdx
  102854:	lea    rsi,[rax+rcx*8]
  102858:	lea    rax,[r12-0x1]
  10285d:	imul   rax,r9
  102861:	mov    r15,r9
  102864:	neg    r15
  102867:	test   r8,r8
  10286a:	cmovns r15,r9
  10286e:	mov    rcx,r8
  102871:	sar    rcx,0x3f
  102875:	and    rcx,rax
  102878:	mov    rax,QWORD PTR [rsp+0x10]
  10287d:	lea    r9,[rax+rcx*8]
  102881:	cmp    QWORD PTR [rsp+0x18],0x0
  102887:	jns    1028b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x970>
  102889:	lea    rax,[r13-0x1]
  10288d:	mov    rdx,QWORD PTR [rsp+0x18]
  102892:	mov    rcx,rdx
  102895:	imul   rcx,rax
  102899:	lea    rsi,[rsi+rcx*8]
  10289d:	neg    rdx
  1028a0:	mov    QWORD PTR [rsp+0x18],rdx
  1028a5:	imul   rax,rdi
  1028a9:	lea    r9,[r9+rax*8]
  1028ad:	neg    rdi
  1028b0:	mov    QWORD PTR [rsp+0x20],r9
  1028b5:	mov    QWORD PTR [rsp+0x10],rsi
  1028ba:	mov    QWORD PTR [rsp+0x40],rdi
  1028bf:	mov    rax,QWORD PTR [rip+0x449402]        # 54bcc8 <_DYNAMIC+0x4e0>
  1028c6:	mov    rax,QWORD PTR [rax]
  1028c9:	test   rax,rax
  1028cc:	jne    102900 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x9c0>
  1028ce:	movsd  QWORD PTR [rsp+0x28],xmm1
  1028d4:	movsd  QWORD PTR [rsp+0x38],xmm0
  1028da:	mov    QWORD PTR [rsp+0x48],r11
  1028df:	mov    QWORD PTR [rsp+0x50],r8
  1028e4:	call   QWORD PTR [rip+0x4493e6]        # 54bcd0 <_DYNAMIC+0x4e8>
  1028ea:	mov    r8,QWORD PTR [rsp+0x50]
  1028ef:	mov    r11,QWORD PTR [rsp+0x48]
  1028f4:	movsd  xmm0,QWORD PTR [rsp+0x38]
  1028fa:	movsd  xmm1,QWORD PTR [rsp+0x28]
  102900:	movzx  r10d,BYTE PTR [rsp+0x30]
  102906:	mov    rdi,rbp
  102909:	mov    rsi,r12
  10290c:	mov    rdx,r13
  10290f:	mov    rcx,rbx
  102912:	mov    r9,QWORD PTR [rsp+0x8]
  102917:	push   QWORD PTR [rsp+0x148]
  10291e:	push   r11
  102920:	push   0x0
  102922:	push   0x0
  102924:	push   0x0
  102926:	push   QWORD PTR [rsp+0x68]
  10292a:	push   r15
  10292c:	push   QWORD PTR [rsp+0x58]
  102930:	push   r14
  102932:	push   QWORD PTR [rsp+0x60]
  102936:	push   QWORD PTR [rsp+0x60]
  10293a:	push   r10
  10293c:	call   rax
  10293e:	add    rsp,0x60
  102942:	jmp    102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  102947:	mov    rax,r15
  10294a:	mov    r15,r12
  10294d:	mov    QWORD PTR [rsp+0x8],r14
  102952:	mov    ecx,0x1
  102957:	sub    rcx,rax
  10295a:	lea    rbx,[rbx+rcx*8]
  10295e:	lea    rcx,[rax-0x1]
  102962:	mov    edx,eax
  102964:	and    edx,0x3
  102967:	and    rax,0xfffffffffffffffc
  10296b:	xor    esi,esi
  10296d:	xorps  xmm0,xmm0
  102970:	jmp    10298c <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa4c>
  102972:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  102980:	inc    rsi
  102983:	cmp    rsi,r15
  102986:	je     102c31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xcf1>
  10298c:	mov    rdi,rsi
  10298f:	imul   rdi,QWORD PTR [rsp+0x8]
  102995:	lea    rdi,[rbx+rdi*8]
  102999:	cmp    rcx,0x3
  10299d:	jb     1029c9 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa89>
  10299f:	xor    r8d,r8d
  1029a2:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  1029b0:	movups XMMWORD PTR [rdi],xmm0
  1029b3:	movups XMMWORD PTR [rdi+0x10],xmm0
  1029b7:	add    rdi,0x20
  1029bb:	add    r8,0x4
  1029bf:	cmp    rax,r8
  1029c2:	jne    1029b0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa70>
  1029c4:	test   rdx,rdx
  1029c7:	je     102980 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1029c9:	xor    r8d,r8d
  1029cc:	nop    DWORD PTR [rax+0x0]
  1029d0:	mov    QWORD PTR [rdi],0x0
  1029d7:	add    rdi,0x8
  1029db:	inc    r8
  1029de:	cmp    rdx,r8
  1029e1:	jne    1029d0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa90>
  1029e3:	jmp    102980 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xa40>
  1029e5:	mov    rax,0xffffffffffffffff
  1029ec:	jmp    1024bb <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x57b>
  1029f1:	mov    DWORD PTR [rsp+0x58],r9d
  1029f6:	mov    QWORD PTR [rsp+0x40],rdi
  1029fb:	mov    QWORD PTR [rsp+0x50],r8
  102a00:	mov    QWORD PTR [rsp+0x48],rsi
  102a05:	movsd  QWORD PTR [rsp+0x28],xmm1
  102a0b:	mov    BYTE PTR [rsp+0x7],r11b
  102a10:	call   QWORD PTR [rip+0x449292]        # 54bca8 <_DYNAMIC+0x4c0>
  102a16:	mov    rdx,QWORD PTR [rip+0x449263]        # 54bc80 <_DYNAMIC+0x498>
  102a1d:	movzx  r11d,BYTE PTR [rsp+0x7]
  102a23:	movsd  xmm1,QWORD PTR [rsp+0x28]
  102a29:	mov    rsi,QWORD PTR [rsp+0x48]
  102a2e:	mov    r10,QWORD PTR [rsp+0x148]
  102a36:	mov    r8,QWORD PTR [rsp+0x50]
  102a3b:	mov    rdi,QWORD PTR [rsp+0x40]
  102a40:	mov    r9d,DWORD PTR [rsp+0x58]
  102a45:	mov    cl,0x1
  102a47:	test   eax,0x80000
  102a4c:	je     1024f0 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5b0>
  102a52:	jmp    102b13 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbd3>
  102a57:	mov    DWORD PTR [rsp+0x58],r9d
  102a5c:	mov    QWORD PTR [rsp+0x40],rdi
  102a61:	mov    QWORD PTR [rsp+0x50],r8
  102a66:	mov    QWORD PTR [rsp+0x48],rsi
  102a6b:	movsd  QWORD PTR [rsp+0x28],xmm1
  102a71:	mov    BYTE PTR [rsp+0x7],r11b
  102a76:	call   QWORD PTR [rip+0x44922c]        # 54bca8 <_DYNAMIC+0x4c0>
  102a7c:	mov    rdx,QWORD PTR [rip+0x4491fd]        # 54bc80 <_DYNAMIC+0x498>
  102a83:	movzx  r11d,BYTE PTR [rsp+0x7]
  102a89:	movsd  xmm1,QWORD PTR [rsp+0x28]
  102a8f:	mov    rsi,QWORD PTR [rsp+0x48]
  102a94:	mov    r10,QWORD PTR [rsp+0x148]
  102a9c:	mov    r8,QWORD PTR [rsp+0x50]
  102aa1:	mov    rdi,QWORD PTR [rsp+0x40]
  102aa6:	mov    r9d,DWORD PTR [rsp+0x58]
  102aab:	test   ax,ax
  102aae:	js     102501 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5c1>
  102ab4:	jmp    102518 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  102ab9:	mov    DWORD PTR [rsp+0x58],r9d
  102abe:	mov    QWORD PTR [rsp+0x40],rdi
  102ac3:	mov    QWORD PTR [rsp+0x50],r8
  102ac8:	mov    QWORD PTR [rsp+0x48],rsi
  102acd:	movsd  QWORD PTR [rsp+0x28],xmm1
  102ad3:	mov    BYTE PTR [rsp+0x7],r11b
  102ad8:	call   QWORD PTR [rip+0x4491ca]        # 54bca8 <_DYNAMIC+0x4c0>
  102ade:	movzx  r11d,BYTE PTR [rsp+0x7]
  102ae4:	movsd  xmm1,QWORD PTR [rsp+0x28]
  102aea:	mov    rsi,QWORD PTR [rsp+0x48]
  102aef:	mov    r10,QWORD PTR [rsp+0x148]
  102af7:	mov    r8,QWORD PTR [rsp+0x50]
  102afc:	mov    rdi,QWORD PTR [rsp+0x40]
  102b01:	mov    r9d,DWORD PTR [rsp+0x58]
  102b06:	bt     rax,0x37
  102b0b:	jae    102518 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0x5d8>
  102b11:	xor    ecx,ecx
  102b13:	mov    r10d,r9d
  102b16:	mov    r9,r8
  102b19:	test   r11b,r11b
  102b1c:	jne    102c43 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd03>
  102b22:	mov    r8,rdi
  102b25:	mov    rax,rbp
  102b28:	mul    r13
  102b2b:	jo     102c59 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  102b31:	test   rax,rax
  102b34:	js     102c59 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xd19>
  102b3a:	mov    rdx,QWORD PTR [rip+0x449197]        # 54bcd8 <_DYNAMIC+0x4f0>
  102b41:	mov    rdx,QWORD PTR [rdx]
  102b44:	movabs rdi,0x7fffffffffffffff
  102b4e:	and    rdi,rdx
  102b51:	mov    edx,0x1
  102b56:	cmp    rax,rdi
  102b59:	jb     102b6b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc2b>
  102b5b:	mov    rdx,QWORD PTR [rsp+0x148]
  102b63:	cmp    rdx,0x1
  102b67:	adc    rdx,0x0
  102b6b:	sub    rsp,0xa0
  102b72:	mov    QWORD PTR [rsp+0x90],rdx
  102b7a:	lea    rax,[rsp+0x100]
  102b82:	mov    QWORD PTR [rsp+0x88],rax
  102b8a:	movzx  eax,r10b
  102b8e:	mov    DWORD PTR [rsp+0x80],eax
  102b95:	mov    rax,QWORD PTR [rsp+0xc0]
  102b9d:	mov    QWORD PTR [rsp+0x78],rax
  102ba2:	mov    QWORD PTR [rsp+0x70],rsi
  102ba7:	mov    QWORD PTR [rsp+0x68],r9
  102bac:	xorps  xmm0,xmm0
  102baf:	movups XMMWORD PTR [rsp+0x58],xmm0
  102bb4:	movzx  eax,BYTE PTR [rsp+0xb8]
  102bbc:	mov    DWORD PTR [rsp+0x50],eax
  102bc0:	mov    QWORD PTR [rsp+0x48],r8
  102bc5:	mov    rax,QWORD PTR [rsp+0xd8]
  102bcd:	mov    QWORD PTR [rsp+0x40],rax
  102bd2:	mov    rax,QWORD PTR [rsp+0xb0]
  102bda:	mov    QWORD PTR [rsp+0x38],rax
  102bdf:	movzx  eax,BYTE PTR [rsp+0xd0]
  102be7:	mov    DWORD PTR [rsp+0x30],eax
  102beb:	movups XMMWORD PTR [rsp+0x18],xmm0
  102bf0:	mov    rax,QWORD PTR [rsp+0xa8]
  102bf8:	mov    QWORD PTR [rsp+0x10],rax
  102bfd:	mov    QWORD PTR [rsp+0x8],r14
  102c02:	mov    QWORD PTR [rsp],rbx
  102c06:	mov    DWORD PTR [rsp+0x28],0x2
  102c0e:	movzx  edx,cl
  102c11:	mov    r8,r15
  102c14:	mov    edi,0x1
  102c19:	mov    r9,r13
  102c1c:	mov    esi,0x1
  102c21:	mov    rcx,r12
  102c24:	call   QWORD PTR [rip+0x449086]        # 54bcb0 <_DYNAMIC+0x4c8>
  102c2a:	add    rsp,0xa0
  102c31:	add    rsp,0x108
  102c38:	pop    rbx
  102c39:	pop    r12
  102c3b:	pop    r13
  102c3d:	pop    r14
  102c3f:	pop    r15
  102c41:	pop    rbp
  102c42:	ret
  102c43:	mov    rbp,0xffffffffffffffff
  102c4a:	mov    r8,rdi
  102c4d:	mov    rax,rbp
  102c50:	mul    r13
  102c53:	jno    102b31 <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xbf1>
  102c59:	mov    rax,QWORD PTR [rip+0x449078]        # 54bcd8 <_DYNAMIC+0x4f0>
  102c60:	mov    rax,QWORD PTR [rax]
  102c63:	jmp    102b5b <_RINvNtNtCsjouqPOLJnB9_4faer6linalg6matmul10matmul_impdECscfHK10Grmvq_6fbench+0xc1b>
