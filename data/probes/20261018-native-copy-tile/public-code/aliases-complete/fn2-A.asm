
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000022530 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>:
   22530:	mov    r10,rdx
   22533:	sub    r10,rcx
   22536:	jbe    2267d <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14d>
   2253c:	push   r14
   2253e:	push   rbx
   2253f:	mov    r8,QWORD PTR [r8]
   22542:	mov    rsi,QWORD PTR [r8]
   22545:	mov    rax,QWORD PTR [r8+0x18]
   22549:	imul   r9,QWORD PTR [r8+0x20]
   2254e:	cmp    r10,0x4
   22552:	setae  r8b
   22556:	cmp    rax,0x1
   2255a:	sete   r11b
   2255e:	and    r11b,r8b
   22561:	cmp    r11b,0x1
   22565:	jne    225b9 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x89>
   22567:	mov    r11,r10
   2256a:	and    r11,0xfffffffffffffffc
   2256e:	lea    r8,[rcx+r11*1]
   22572:	lea    rbx,[rdi+rcx*8]
   22576:	add    rbx,0x10
   2257a:	shl    rcx,0x3
   2257e:	lea    rcx,[rcx+r9*8]
   22582:	add    rcx,rsi
   22585:	add    rcx,0x10
   22589:	xor    r14d,r14d
   2258c:	nop    DWORD PTR [rax+0x0]
   22590:	movups xmm0,XMMWORD PTR [rcx+r14*8-0x10]
   22596:	movups xmm1,XMMWORD PTR [rcx+r14*8]
   2259b:	movups XMMWORD PTR [rbx+r14*8-0x10],xmm0
   225a1:	movups XMMWORD PTR [rbx+r14*8],xmm1
   225a6:	add    r14,0x4
   225aa:	cmp    r11,r14
   225ad:	jne    22590 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x60>
   225af:	cmp    r10,r11
   225b2:	jne    225bc <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x8c>
   225b4:	jmp    2267a <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14a>
   225b9:	mov    r8,rcx
   225bc:	mov    r10d,edx
   225bf:	sub    r10d,r8d
   225c2:	mov    rcx,r8
   225c5:	and    r10d,0x3
   225c9:	je     22605 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xd5>
   225cb:	mov    rcx,r8
   225ce:	imul   rcx,rax
   225d2:	lea    r11,[r9*8+0x0]
   225da:	lea    r11,[r11+rcx*8]
   225de:	add    r11,rsi
   225e1:	lea    rbx,[rax*8+0x0]
   225e9:	mov    rcx,r8
   225ec:	nop    DWORD PTR [rax+0x0]
   225f0:	movsd  xmm0,QWORD PTR [r11]
   225f5:	movsd  QWORD PTR [rdi+rcx*8],xmm0
   225fa:	inc    rcx
   225fd:	add    r11,rbx
   22600:	dec    r10
   22603:	jne    225f0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0xc0>
   22605:	sub    r8,rdx
   22608:	cmp    r8,0xfffffffffffffffc
   2260c:	ja     2267a <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x14a>
   2260e:	lea    rsi,[rsi+r9*8]
   22612:	lea    r8,[rcx+0x3]
   22616:	imul   r8,rax
   2261a:	mov    r9,rax
   2261d:	shl    r9,0x5
   22621:	lea    r10,[rcx+0x2]
   22625:	imul   r10,rax
   22629:	mov    r11,rcx
   2262c:	imul   r11,rax
   22630:	lea    rbx,[rcx+0x1]
   22634:	imul   rbx,rax
   22638:	nop    DWORD PTR [rax+rax*1+0x0]
   22640:	movsd  xmm0,QWORD PTR [rsi+r11*8]
   22646:	movsd  QWORD PTR [rdi+rcx*8],xmm0
   2264b:	movsd  xmm0,QWORD PTR [rsi+rbx*8]
   22650:	movsd  QWORD PTR [rdi+rcx*8+0x8],xmm0
   22656:	movsd  xmm0,QWORD PTR [rsi+r10*8]
   2265c:	movsd  QWORD PTR [rdi+rcx*8+0x10],xmm0
   22662:	movsd  xmm0,QWORD PTR [rsi+r8*8]
   22668:	movsd  QWORD PTR [rdi+rcx*8+0x18],xmm0
   2266e:	add    rcx,0x4
   22672:	add    rsi,r9
   22675:	cmp    rdx,rcx
   22678:	jne    22640 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotatedNtNtNtB6_5utils5bound3DimBT_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe+0x110>
   2267a:	pop    rbx
   2267b:	pop    r14
   2267d:	ret
