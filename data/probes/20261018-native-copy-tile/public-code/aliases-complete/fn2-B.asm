
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002d290 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2d290:	mov    r10,rdx
   2d293:	sub    r10,rcx
   2d296:	jbe    2d3dd <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14d>
   2d29c:	push   r14
   2d29e:	push   rbx
   2d29f:	mov    r8,QWORD PTR [r8]
   2d2a2:	mov    rsi,QWORD PTR [r8]
   2d2a5:	mov    rax,QWORD PTR [r8+0x18]
   2d2a9:	imul   r9,QWORD PTR [r8+0x20]
   2d2ae:	cmp    r10,0x4
   2d2b2:	setae  r8b
   2d2b6:	cmp    rax,0x1
   2d2ba:	sete   r11b
   2d2be:	and    r11b,r8b
   2d2c1:	cmp    r11b,0x1
   2d2c5:	jne    2d319 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x89>
   2d2c7:	mov    r11,r10
   2d2ca:	and    r11,0xfffffffffffffffc
   2d2ce:	lea    r8,[rcx+r11*1]
   2d2d2:	lea    rbx,[rdi+rcx*8]
   2d2d6:	add    rbx,0x10
   2d2da:	shl    rcx,0x3
   2d2de:	lea    rcx,[rcx+r9*8]
   2d2e2:	add    rcx,rsi
   2d2e5:	add    rcx,0x10
   2d2e9:	xor    r14d,r14d
   2d2ec:	nop    DWORD PTR [rax+0x0]
   2d2f0:	movups xmm0,XMMWORD PTR [rcx+r14*8-0x10]
   2d2f6:	movups xmm1,XMMWORD PTR [rcx+r14*8]
   2d2fb:	movups XMMWORD PTR [rbx+r14*8-0x10],xmm0
   2d301:	movups XMMWORD PTR [rbx+r14*8],xmm1
   2d306:	add    r14,0x4
   2d30a:	cmp    r11,r14
   2d30d:	jne    2d2f0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x60>
   2d30f:	cmp    r10,r11
   2d312:	jne    2d31c <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x8c>
   2d314:	jmp    2d3da <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14a>
   2d319:	mov    r8,rcx
   2d31c:	mov    r10d,edx
   2d31f:	sub    r10d,r8d
   2d322:	mov    rcx,r8
   2d325:	and    r10d,0x3
   2d329:	je     2d365 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xd5>
   2d32b:	mov    rcx,r8
   2d32e:	imul   rcx,rax
   2d332:	lea    r11,[r9*8+0x0]
   2d33a:	lea    r11,[r11+rcx*8]
   2d33e:	add    r11,rsi
   2d341:	lea    rbx,[rax*8+0x0]
   2d349:	mov    rcx,r8
   2d34c:	nop    DWORD PTR [rax+0x0]
   2d350:	movsd  xmm0,QWORD PTR [r11]
   2d355:	movsd  QWORD PTR [rdi+rcx*8],xmm0
   2d35a:	inc    rcx
   2d35d:	add    r11,rbx
   2d360:	dec    r10
   2d363:	jne    2d350 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xc0>
   2d365:	sub    r8,rdx
   2d368:	cmp    r8,0xfffffffffffffffc
   2d36c:	ja     2d3da <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14a>
   2d36e:	lea    rsi,[rsi+r9*8]
   2d372:	lea    r8,[rcx+0x3]
   2d376:	imul   r8,rax
   2d37a:	mov    r9,rax
   2d37d:	shl    r9,0x5
   2d381:	lea    r10,[rcx+0x2]
   2d385:	imul   r10,rax
   2d389:	mov    r11,rcx
   2d38c:	imul   r11,rax
   2d390:	lea    rbx,[rcx+0x1]
   2d394:	imul   rbx,rax
   2d398:	nop    DWORD PTR [rax+rax*1+0x0]
   2d3a0:	movsd  xmm0,QWORD PTR [rsi+r11*8]
   2d3a6:	movsd  QWORD PTR [rdi+rcx*8],xmm0
   2d3ab:	movsd  xmm0,QWORD PTR [rsi+rbx*8]
   2d3b0:	movsd  QWORD PTR [rdi+rcx*8+0x8],xmm0
   2d3b6:	movsd  xmm0,QWORD PTR [rsi+r10*8]
   2d3bc:	movsd  QWORD PTR [rdi+rcx*8+0x10],xmm0
   2d3c2:	movsd  xmm0,QWORD PTR [rsi+r8*8]
   2d3c8:	movsd  QWORD PTR [rdi+rcx*8+0x18],xmm0
   2d3ce:	add    rcx,0x4
   2d3d2:	add    rsi,r9
   2d3d5:	cmp    rdx,rcx
   2d3d8:	jne    2d3a0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x110>
   2d3da:	pop    rbx
   2d3db:	pop    r14
   2d3dd:	ret
