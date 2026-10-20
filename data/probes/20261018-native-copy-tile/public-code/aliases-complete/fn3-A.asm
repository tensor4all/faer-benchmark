
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000022260 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe>:
   22260:	mov    r10,rdx
   22263:	sub    r10,rcx
   22266:	jbe    2235e <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   2226c:	mov    rax,QWORD PTR [r8]
   2226f:	mov    rsi,QWORD PTR [rax+0x18]
   22273:	imul   r9,QWORD PTR [rax+0x20]
   22278:	shl    r9,0x4
   2227c:	add    r9,QWORD PTR [rax]
   2227f:	cmp    r10,0x4
   22283:	setae  al
   22286:	cmp    rsi,0x1
   2228a:	sete   r8b
   2228e:	and    r8b,al
   22291:	cmp    r8b,0x1
   22295:	jne    222d8 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x78>
   22297:	mov    r8,r10
   2229a:	and    r8,0xfffffffffffffffe
   2229e:	lea    rax,[rcx+r8*1]
   222a2:	shl    rcx,0x4
   222a6:	add    rcx,0x10
   222aa:	mov    r11,r8
   222ad:	nop    DWORD PTR [rax]
   222b0:	movups xmm0,XMMWORD PTR [r9+rcx*1-0x10]
   222b6:	movups xmm1,XMMWORD PTR [r9+rcx*1]
   222bb:	movups XMMWORD PTR [rdi+rcx*1-0x10],xmm0
   222c0:	movups XMMWORD PTR [rdi+rcx*1],xmm1
   222c4:	add    rcx,0x20
   222c8:	add    r11,0xfffffffffffffffe
   222cc:	jne    222b0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x50>
   222ce:	cmp    r10,r8
   222d1:	jne    222db <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x7b>
   222d3:	jmp    2235e <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   222d8:	mov    rax,rcx
   222db:	mov    r8d,edx
   222de:	sub    r8d,eax
   222e1:	lea    rcx,[rax+0x1]
   222e5:	test   r8b,0x1
   222e9:	je     22306 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xa6>
   222eb:	mov    r8,rax
   222ee:	imul   r8,rsi
   222f2:	shl    r8,0x4
   222f6:	shl    rax,0x4
   222fa:	movups xmm0,XMMWORD PTR [r9+r8*1]
   222ff:	movups XMMWORD PTR [rdi+rax*1],xmm0
   22303:	mov    rax,rcx
   22306:	cmp    rdx,rcx
   22309:	je     2235e <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   2230b:	sub    rdx,rax
   2230e:	mov    rcx,rax
   22311:	shl    rcx,0x4
   22315:	add    rcx,rdi
   22318:	add    rcx,0x10
   2231c:	mov    rdi,rax
   2231f:	imul   rdi,rsi
   22323:	shl    rdi,0x4
   22327:	mov    r8,rsi
   2232a:	shl    r8,0x5
   2232e:	inc    rax
   22331:	imul   rax,rsi
   22335:	shl    rax,0x4
   22339:	nop    DWORD PTR [rax+0x0]
   22340:	movups xmm0,XMMWORD PTR [r9+rdi*1]
   22345:	movups XMMWORD PTR [rcx-0x10],xmm0
   22349:	movups xmm0,XMMWORD PTR [r9+rax*1]
   2234e:	movups XMMWORD PTR [rcx],xmm0
   22351:	add    rcx,0x20
   22355:	add    r9,r8
   22358:	add    rdx,0xfffffffffffffffe
   2235c:	jne    22340 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2235e:	ret
