
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000021fe0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_>:
   21fe0:	push   rbp
   21fe1:	push   r15
   21fe3:	push   r14
   21fe5:	push   r13
   21fe7:	push   r12
   21fe9:	push   rbx
   21fea:	sub    rsp,0x118
   21ff1:	mov    r14,rsi
   21ff4:	mov    QWORD PTR [rsp+0x100],rdi
   21ffc:	call   QWORD PTR [rip+0x68186]        # 8a188 <_DYNAMIC+0x230>
   22002:	mov    QWORD PTR [rsp+0x108],rax
   2200a:	mov    DWORD PTR [rsp+0x110],edx
   22011:	lea    rdi,[rsp+0x108]
   22019:	call   QWORD PTR [rip+0x68171]        # 8a190 <_DYNAMIC+0x238>
   2201f:	test   rax,rax
   22022:	je     22874 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x894>
   22028:	call   QWORD PTR [rip+0x6816a]        # 8a198 <_DYNAMIC+0x240>
   2202e:	mov    edi,0x28
   22033:	mov    esi,0x8
   22038:	call   QWORD PTR [rip+0x68162]        # 8a1a0 <_DYNAMIC+0x248>
   2203e:	test   rax,rax
   22041:	je     22a6d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa8d>
   22047:	mov    QWORD PTR [rsp],0x5
   2204f:	mov    QWORD PTR [rsp+0x8],rax
   22054:	mov    QWORD PTR [rsp+0x10],0x0
   2205d:	call   QWORD PTR [rip+0x68125]        # 8a188 <_DYNAMIC+0x230>
   22063:	mov    QWORD PTR [rsp+0x88],rax
   2206b:	mov    DWORD PTR [rsp+0x90],edx
   22072:	mov    rax,QWORD PTR [r14+0x20]
   22076:	mov    QWORD PTR [rsp+0x70],rax
   2207b:	movups xmm0,XMMWORD PTR [r14]
   2207f:	movupd xmm1,XMMWORD PTR [r14+0x10]
   22085:	movapd XMMWORD PTR [rsp+0x60],xmm1
   2208b:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22090:	lea    rax,[rsp+0x50]
   22095:	mov    rax,QWORD PTR [rsp+0x50]
   2209a:	mov    r15,QWORD PTR [rsp+0x58]
   2209f:	mov    rcx,QWORD PTR [rsp+0x70]
   220a4:	mov    QWORD PTR [rsp+0xd0],rax
   220ac:	mov    QWORD PTR [rsp+0xd8],r15
   220b4:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   220ba:	mov    r12,QWORD PTR [rsp+0x60]
   220bf:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   220c8:	mov    QWORD PTR [rsp+0xf0],rcx
   220d0:	lea    rdi,[rsp+0x18]
   220d5:	lea    rsi,[rsp+0xd0]
   220dd:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   220e2:	mov    rdi,QWORD PTR [rsp+0x40]
   220e7:	mov    rsi,QWORD PTR [rsp+0x48]
   220ec:	cmp    rdi,r15
   220ef:	jne    22a7d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa9d>
   220f5:	cmp    rsi,r12
   220f8:	jne    22a7d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa9d>
   220fe:	mov    rax,QWORD PTR [rsp+0x18]
   22103:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22109:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2210f:	mov    QWORD PTR [rsp+0x98],rax
   22117:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22120:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   22129:	mov    QWORD PTR [rsp+0xc0],r15
   22131:	mov    QWORD PTR [rsp+0xc8],r12
   22139:	lea    rax,[rsp+0x98]
   22141:	mov    rsi,QWORD PTR [rsp+0xb8]
   22149:	test   rsi,rsi
   2214c:	je     22164 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x184>
   2214e:	mov    rdi,QWORD PTR [rsp+0x98]
   22156:	mov    rdx,QWORD PTR [rsp+0xb0]
   2215e:	call   QWORD PTR [rip+0x68044]        # 8a1a8 <_DYNAMIC+0x250>
   22164:	lea    rdi,[rsp+0x88]
   2216c:	call   QWORD PTR [rip+0x6801e]        # 8a190 <_DYNAMIC+0x238>
   22172:	mov    r15,rax
   22175:	mov    ebx,edx
   22177:	mov    r12,QWORD PTR [rsp+0x10]
   2217c:	cmp    r12,QWORD PTR [rsp]
   22180:	jne    2218a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x1aa>
   22182:	mov    rdi,rsp
   22185:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2218a:	movq   xmm0,r15
   2218f:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe5599]        # 7730 <__abi_tag+0x7434>
   22197:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe5531]        # 76d0 <__abi_tag+0x73d4>
   2219f:	movapd xmm1,xmm0
   221a3:	unpckhpd xmm1,xmm0
   221a7:	cvtsi2sd xmm2,ebx
   221ab:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe57dd]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   221b3:	addsd  xmm1,xmm0
   221b7:	addsd  xmm2,xmm1
   221bb:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe5835]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   221c3:	mov    rax,QWORD PTR [rsp+0x8]
   221c8:	movsd  QWORD PTR [rax+r12*8],xmm2
   221ce:	inc    r12
   221d1:	mov    QWORD PTR [rsp+0x10],r12
   221d6:	call   QWORD PTR [rip+0x67fac]        # 8a188 <_DYNAMIC+0x230>
   221dc:	mov    QWORD PTR [rsp+0x88],rax
   221e4:	mov    DWORD PTR [rsp+0x90],edx
   221eb:	mov    rax,QWORD PTR [r14+0x20]
   221ef:	mov    QWORD PTR [rsp+0x70],rax
   221f4:	movups xmm0,XMMWORD PTR [r14]
   221f8:	movupd xmm1,XMMWORD PTR [r14+0x10]
   221fe:	movapd XMMWORD PTR [rsp+0x60],xmm1
   22204:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22209:	lea    rax,[rsp+0x50]
   2220e:	mov    rax,QWORD PTR [rsp+0x50]
   22213:	mov    r15,QWORD PTR [rsp+0x58]
   22218:	mov    rcx,QWORD PTR [rsp+0x70]
   2221d:	mov    QWORD PTR [rsp+0xd0],rax
   22225:	mov    QWORD PTR [rsp+0xd8],r15
   2222d:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   22233:	mov    r12,QWORD PTR [rsp+0x60]
   22238:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   22241:	mov    QWORD PTR [rsp+0xf0],rcx
   22249:	lea    rdi,[rsp+0x18]
   2224e:	lea    rsi,[rsp+0xd0]
   22256:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   2225b:	mov    rdi,QWORD PTR [rsp+0x40]
   22260:	mov    rsi,QWORD PTR [rsp+0x48]
   22265:	cmp    rdi,r15
   22268:	jne    22abf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xadf>
   2226e:	cmp    rsi,r12
   22271:	jne    22abf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xadf>
   22277:	mov    rax,QWORD PTR [rsp+0x18]
   2227c:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22282:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   22288:	mov    QWORD PTR [rsp+0x98],rax
   22290:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22299:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   222a2:	mov    QWORD PTR [rsp+0xc0],r15
   222aa:	mov    QWORD PTR [rsp+0xc8],r12
   222b2:	lea    rax,[rsp+0x98]
   222ba:	mov    rsi,QWORD PTR [rsp+0xb8]
   222c2:	test   rsi,rsi
   222c5:	je     222dd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x2fd>
   222c7:	mov    rdi,QWORD PTR [rsp+0x98]
   222cf:	mov    rdx,QWORD PTR [rsp+0xb0]
   222d7:	call   QWORD PTR [rip+0x67ecb]        # 8a1a8 <_DYNAMIC+0x250>
   222dd:	lea    rdi,[rsp+0x88]
   222e5:	call   QWORD PTR [rip+0x67ea5]        # 8a190 <_DYNAMIC+0x238>
   222eb:	mov    r15,rax
   222ee:	mov    ebx,edx
   222f0:	mov    r12,QWORD PTR [rsp+0x10]
   222f5:	cmp    r12,QWORD PTR [rsp]
   222f9:	jne    22303 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x323>
   222fb:	mov    rdi,rsp
   222fe:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   22303:	movq   xmm0,r15
   22308:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe5420]        # 7730 <__abi_tag+0x7434>
   22310:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe53b8]        # 76d0 <__abi_tag+0x73d4>
   22318:	movapd xmm1,xmm0
   2231c:	unpckhpd xmm1,xmm0
   22320:	cvtsi2sd xmm2,ebx
   22324:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe5664]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   2232c:	addsd  xmm1,xmm0
   22330:	addsd  xmm2,xmm1
   22334:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe56bc]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   2233c:	mov    rax,QWORD PTR [rsp+0x8]
   22341:	movsd  QWORD PTR [rax+r12*8],xmm2
   22347:	inc    r12
   2234a:	mov    QWORD PTR [rsp+0x10],r12
   2234f:	call   QWORD PTR [rip+0x67e33]        # 8a188 <_DYNAMIC+0x230>
   22355:	mov    QWORD PTR [rsp+0x88],rax
   2235d:	mov    DWORD PTR [rsp+0x90],edx
   22364:	mov    rax,QWORD PTR [r14+0x20]
   22368:	mov    QWORD PTR [rsp+0x70],rax
   2236d:	movups xmm0,XMMWORD PTR [r14]
   22371:	movupd xmm1,XMMWORD PTR [r14+0x10]
   22377:	movapd XMMWORD PTR [rsp+0x60],xmm1
   2237d:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22382:	lea    rax,[rsp+0x50]
   22387:	mov    rax,QWORD PTR [rsp+0x50]
   2238c:	mov    r15,QWORD PTR [rsp+0x58]
   22391:	mov    rcx,QWORD PTR [rsp+0x70]
   22396:	mov    QWORD PTR [rsp+0xd0],rax
   2239e:	mov    QWORD PTR [rsp+0xd8],r15
   223a6:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   223ac:	mov    r12,QWORD PTR [rsp+0x60]
   223b1:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   223ba:	mov    QWORD PTR [rsp+0xf0],rcx
   223c2:	lea    rdi,[rsp+0x18]
   223c7:	lea    rsi,[rsp+0xd0]
   223cf:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   223d4:	mov    rdi,QWORD PTR [rsp+0x40]
   223d9:	mov    rsi,QWORD PTR [rsp+0x48]
   223de:	cmp    rdi,r15
   223e1:	jne    22b01 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb21>
   223e7:	cmp    rsi,r12
   223ea:	jne    22b01 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb21>
   223f0:	mov    rax,QWORD PTR [rsp+0x18]
   223f5:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   223fb:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   22401:	mov    QWORD PTR [rsp+0x98],rax
   22409:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22412:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2241b:	mov    QWORD PTR [rsp+0xc0],r15
   22423:	mov    QWORD PTR [rsp+0xc8],r12
   2242b:	lea    rax,[rsp+0x98]
   22433:	mov    rsi,QWORD PTR [rsp+0xb8]
   2243b:	test   rsi,rsi
   2243e:	je     22456 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x476>
   22440:	mov    rdi,QWORD PTR [rsp+0x98]
   22448:	mov    rdx,QWORD PTR [rsp+0xb0]
   22450:	call   QWORD PTR [rip+0x67d52]        # 8a1a8 <_DYNAMIC+0x250>
   22456:	lea    rdi,[rsp+0x88]
   2245e:	call   QWORD PTR [rip+0x67d2c]        # 8a190 <_DYNAMIC+0x238>
   22464:	mov    r15,rax
   22467:	mov    ebx,edx
   22469:	mov    r12,QWORD PTR [rsp+0x10]
   2246e:	cmp    r12,QWORD PTR [rsp]
   22472:	jne    2247c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x49c>
   22474:	mov    rdi,rsp
   22477:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2247c:	movq   xmm0,r15
   22481:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe52a7]        # 7730 <__abi_tag+0x7434>
   22489:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe523f]        # 76d0 <__abi_tag+0x73d4>
   22491:	movapd xmm1,xmm0
   22495:	unpckhpd xmm1,xmm0
   22499:	cvtsi2sd xmm2,ebx
   2249d:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe54eb]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   224a5:	addsd  xmm1,xmm0
   224a9:	addsd  xmm2,xmm1
   224ad:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe5543]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   224b5:	mov    rax,QWORD PTR [rsp+0x8]
   224ba:	movsd  QWORD PTR [rax+r12*8],xmm2
   224c0:	inc    r12
   224c3:	mov    QWORD PTR [rsp+0x10],r12
   224c8:	call   QWORD PTR [rip+0x67cba]        # 8a188 <_DYNAMIC+0x230>
   224ce:	mov    QWORD PTR [rsp+0x88],rax
   224d6:	mov    DWORD PTR [rsp+0x90],edx
   224dd:	mov    rax,QWORD PTR [r14+0x20]
   224e1:	mov    QWORD PTR [rsp+0x70],rax
   224e6:	movups xmm0,XMMWORD PTR [r14]
   224ea:	movupd xmm1,XMMWORD PTR [r14+0x10]
   224f0:	movapd XMMWORD PTR [rsp+0x60],xmm1
   224f6:	movaps XMMWORD PTR [rsp+0x50],xmm0
   224fb:	lea    rax,[rsp+0x50]
   22500:	mov    rax,QWORD PTR [rsp+0x50]
   22505:	mov    r15,QWORD PTR [rsp+0x58]
   2250a:	mov    rcx,QWORD PTR [rsp+0x70]
   2250f:	mov    QWORD PTR [rsp+0xd0],rax
   22517:	mov    QWORD PTR [rsp+0xd8],r15
   2251f:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   22525:	mov    r12,QWORD PTR [rsp+0x60]
   2252a:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   22533:	mov    QWORD PTR [rsp+0xf0],rcx
   2253b:	lea    rdi,[rsp+0x18]
   22540:	lea    rsi,[rsp+0xd0]
   22548:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   2254d:	mov    rdi,QWORD PTR [rsp+0x40]
   22552:	mov    rsi,QWORD PTR [rsp+0x48]
   22557:	cmp    rdi,r15
   2255a:	jne    22b40 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb60>
   22560:	cmp    rsi,r12
   22563:	jne    22b40 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb60>
   22569:	mov    rax,QWORD PTR [rsp+0x18]
   2256e:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22574:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2257a:	mov    QWORD PTR [rsp+0x98],rax
   22582:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   2258b:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   22594:	mov    QWORD PTR [rsp+0xc0],r15
   2259c:	mov    QWORD PTR [rsp+0xc8],r12
   225a4:	lea    rax,[rsp+0x98]
   225ac:	mov    rsi,QWORD PTR [rsp+0xb8]
   225b4:	test   rsi,rsi
   225b7:	je     225cf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x5ef>
   225b9:	mov    rdi,QWORD PTR [rsp+0x98]
   225c1:	mov    rdx,QWORD PTR [rsp+0xb0]
   225c9:	call   QWORD PTR [rip+0x67bd9]        # 8a1a8 <_DYNAMIC+0x250>
   225cf:	lea    rdi,[rsp+0x88]
   225d7:	call   QWORD PTR [rip+0x67bb3]        # 8a190 <_DYNAMIC+0x238>
   225dd:	mov    r15,rax
   225e0:	mov    ebx,edx
   225e2:	mov    r12,QWORD PTR [rsp+0x10]
   225e7:	cmp    r12,QWORD PTR [rsp]
   225eb:	jne    225f5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x615>
   225ed:	mov    rdi,rsp
   225f0:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   225f5:	movq   xmm0,r15
   225fa:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe512e]        # 7730 <__abi_tag+0x7434>
   22602:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe50c6]        # 76d0 <__abi_tag+0x73d4>
   2260a:	movapd xmm1,xmm0
   2260e:	unpckhpd xmm1,xmm0
   22612:	cvtsi2sd xmm2,ebx
   22616:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe5372]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   2261e:	addsd  xmm1,xmm0
   22622:	addsd  xmm2,xmm1
   22626:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe53ca]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   2262e:	mov    rax,QWORD PTR [rsp+0x8]
   22633:	movsd  QWORD PTR [rax+r12*8],xmm2
   22639:	inc    r12
   2263c:	mov    QWORD PTR [rsp+0x10],r12
   22641:	call   QWORD PTR [rip+0x67b41]        # 8a188 <_DYNAMIC+0x230>
   22647:	mov    QWORD PTR [rsp+0x88],rax
   2264f:	mov    DWORD PTR [rsp+0x90],edx
   22656:	mov    rax,QWORD PTR [r14+0x20]
   2265a:	mov    QWORD PTR [rsp+0x70],rax
   2265f:	movups xmm0,XMMWORD PTR [r14]
   22663:	movupd xmm1,XMMWORD PTR [r14+0x10]
   22669:	movapd XMMWORD PTR [rsp+0x60],xmm1
   2266f:	movaps XMMWORD PTR [rsp+0x50],xmm0
   22674:	lea    rax,[rsp+0x50]
   22679:	mov    rax,QWORD PTR [rsp+0x50]
   2267e:	mov    r14,QWORD PTR [rsp+0x58]
   22683:	mov    rcx,QWORD PTR [rsp+0x70]
   22688:	mov    QWORD PTR [rsp+0xd0],rax
   22690:	mov    QWORD PTR [rsp+0xd8],r14
   22698:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   2269e:	mov    r15,QWORD PTR [rsp+0x60]
   226a3:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   226ac:	mov    QWORD PTR [rsp+0xf0],rcx
   226b4:	lea    rdi,[rsp+0x18]
   226b9:	lea    rsi,[rsp+0xd0]
   226c1:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   226c6:	mov    rdi,QWORD PTR [rsp+0x40]
   226cb:	mov    rsi,QWORD PTR [rsp+0x48]
   226d0:	cmp    rdi,r14
   226d3:	jne    22b7f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb9f>
   226d9:	cmp    rsi,r15
   226dc:	jne    22b7f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb9f>
   226e2:	mov    rax,QWORD PTR [rsp+0x18]
   226e7:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   226ed:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   226f3:	mov    QWORD PTR [rsp+0x98],rax
   226fb:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   22704:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2270d:	mov    QWORD PTR [rsp+0xc0],r14
   22715:	mov    QWORD PTR [rsp+0xc8],r15
   2271d:	lea    rax,[rsp+0x98]
   22725:	mov    rsi,QWORD PTR [rsp+0xb8]
   2272d:	test   rsi,rsi
   22730:	je     22748 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x768>
   22732:	mov    rdi,QWORD PTR [rsp+0x98]
   2273a:	mov    rdx,QWORD PTR [rsp+0xb0]
   22742:	call   QWORD PTR [rip+0x67a60]        # 8a1a8 <_DYNAMIC+0x250>
   22748:	lea    rdi,[rsp+0x88]
   22750:	call   QWORD PTR [rip+0x67a3a]        # 8a190 <_DYNAMIC+0x238>
   22756:	mov    r14,rax
   22759:	mov    ebx,edx
   2275b:	mov    rbp,QWORD PTR [rsp+0x10]
   22760:	cmp    rbp,QWORD PTR [rsp]
   22764:	jne    2276e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x78e>
   22766:	mov    rdi,rsp
   22769:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2276e:	movq   xmm0,r14
   22773:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe4fb5]        # 7730 <__abi_tag+0x7434>
   2277b:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe4f4d]        # 76d0 <__abi_tag+0x73d4>
   22783:	movapd xmm1,xmm0
   22787:	unpckhpd xmm1,xmm0
   2278b:	addsd  xmm1,xmm0
   2278f:	xorps  xmm0,xmm0
   22792:	cvtsi2sd xmm0,ebx
   22796:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe51f2]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   2279e:	addsd  xmm0,xmm1
   227a2:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe524e]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   227aa:	mov    rax,QWORD PTR [rsp+0x8]
   227af:	movsd  QWORD PTR [rax+rbp*8],xmm0
   227b4:	lea    r12,[rbp+0x1]
   227b8:	mov    QWORD PTR [rsp+0x10],r12
   227bd:	lea    r13,[rbp*8+0x8]
   227c5:	mov    rax,r12
   227c8:	shr    rax,0x3d
   227cc:	setne  al
   227cf:	movabs rcx,0x7ffffffffffffff8
   227d9:	cmp    r13,rcx
   227dc:	seta   cl
   227df:	or     cl,al
   227e1:	je     227f7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x817>
   227e3:	xor    r15d,r15d
   227e6:	mov    rdi,r15
   227e9:	mov    rsi,r13
   227ec:	call   QWORD PTR [rip+0x679be]        # 8a1b0 <_DYNAMIC+0x258>
   227f2:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   227f7:	mov    rbx,QWORD PTR [rsp+0x8]
   227fc:	test   r13,r13
   227ff:	je     2299b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9bb>
   22805:	call   QWORD PTR [rip+0x6798d]        # 8a198 <_DYNAMIC+0x240>
   2280b:	mov    r15d,0x8
   22811:	mov    esi,0x8
   22816:	mov    rdi,r13
   22819:	call   QWORD PTR [rip+0x67981]        # 8a1a0 <_DYNAMIC+0x248>
   2281f:	test   rax,rax
   22822:	je     227e6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x806>
   22824:	mov    r14,rax
   22827:	mov    r15,r12
   2282a:	test   r12,r12
   2282d:	je     229ad <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9cd>
   22833:	mov    rdi,r14
   22836:	mov    rsi,rbx
   22839:	mov    rdx,r13
   2283c:	call   QWORD PTR [rip+0x67976]        # 8a1b8 <memcpy@GLIBC_2.14>
   22842:	lea    rax,[rsp+0x87]
   2284a:	mov    QWORD PTR [rsp+0x18],rax
   2284f:	mov    esi,0x1
   22854:	test   rbp,rbp
   22857:	jne    229b4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9d4>
   2285d:	lea    rdx,[rip+0x644bc]        # 86d20 <__frame_dummy_init_array_entry+0x30>
   22864:	mov    edi,0x2
   22869:	call   QWORD PTR [rip+0x67951]        # 8a1c0 <_DYNAMIC+0x268>
   2286f:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22874:	lea    r15,[rsp+0x18]
   22879:	lea    r13,[rsp+0x108]
   22881:	mov    r12,QWORD PTR [rip+0x67908]        # 8a190 <_DYNAMIC+0x238>
   22888:	jmp    2289f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x8bf>
   2288a:	nop    WORD PTR [rax+rax*1+0x0]
   22890:	mov    rdi,r13
   22893:	call   r12
   22896:	test   rax,rax
   22899:	jne    22028 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x48>
   2289f:	cmp    edx,0xee6b280
   228a5:	jae    22028 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x48>
   228ab:	mov    rax,QWORD PTR [r14+0x20]
   228af:	mov    QWORD PTR [rsp+0xf0],rax
   228b7:	movups xmm0,XMMWORD PTR [r14]
   228bb:	movups xmm1,XMMWORD PTR [r14+0x10]
   228c0:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   228c8:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   228d0:	lea    rax,[rsp+0xd0]
   228d8:	mov    rax,QWORD PTR [rsp+0xd0]
   228e0:	mov    rbp,QWORD PTR [rsp+0xd8]
   228e8:	mov    rcx,QWORD PTR [rsp+0xf0]
   228f0:	mov    QWORD PTR [rsp+0x98],rax
   228f8:	mov    QWORD PTR [rsp+0xa0],rbp
   22900:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   22908:	mov    rbx,QWORD PTR [rsp+0xe0]
   22910:	movups XMMWORD PTR [rsp+0xa8],xmm0
   22918:	mov    QWORD PTR [rsp+0xb8],rcx
   22920:	mov    rdi,r15
   22923:	lea    rsi,[rsp+0x98]
   2292b:	call   276e0 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   22930:	mov    rdi,QWORD PTR [rsp+0x40]
   22935:	mov    rsi,QWORD PTR [rsp+0x48]
   2293a:	cmp    rdi,rbp
   2293d:	jne    22a2a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa4a>
   22943:	cmp    rsi,rbx
   22946:	jne    22a2a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa4a>
   2294c:	mov    rax,QWORD PTR [rsp+0x18]
   22951:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   22957:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2295d:	mov    QWORD PTR [rsp+0x18],rax
   22962:	movupd XMMWORD PTR [rsp+0x20],xmm0
   22968:	movupd XMMWORD PTR [rsp+0x30],xmm1
   2296e:	mov    QWORD PTR [rsp+0x40],rbp
   22973:	mov    QWORD PTR [rsp+0x48],rbx
   22978:	mov    rsi,QWORD PTR [rsp+0x38]
   2297d:	test   rsi,rsi
   22980:	je     22890 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x8b0>
   22986:	mov    rdi,QWORD PTR [rsp+0x18]
   2298b:	mov    rdx,QWORD PTR [rsp+0x30]
   22990:	call   QWORD PTR [rip+0x67812]        # 8a1a8 <_DYNAMIC+0x250>
   22996:	jmp    22890 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x8b0>
   2299b:	mov    r14d,0x8
   229a1:	xor    r15d,r15d
   229a4:	test   r12,r12
   229a7:	jne    22833 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x853>
   229ad:	xor    esi,esi
   229af:	jmp    2285d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x87d>
   229b4:	cmp    r12,0x15
   229b8:	jae    22bbe <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbde>
   229be:	lea    rcx,[rsp+0x18]
   229c3:	mov    edx,0x1
   229c8:	mov    rdi,r14
   229cb:	mov    rsi,r12
   229ce:	call   34840 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   229d3:	cmp    r12,0x3
   229d7:	jb     22bd3 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbf3>
   229dd:	movsd  xmm0,QWORD PTR [r14+0x10]
   229e3:	mov    rax,QWORD PTR [rsp+0x10]
   229e8:	mov    rbx,QWORD PTR [rsp+0x100]
   229f0:	mov    QWORD PTR [rbx+0x18],rax
   229f4:	movups xmm1,XMMWORD PTR [rsp]
   229f8:	movups XMMWORD PTR [rbx+0x8],xmm1
   229fc:	movsd  QWORD PTR [rbx],xmm0
   22a00:	shl    r15,0x3
   22a04:	mov    edx,0x8
   22a09:	mov    rdi,r14
   22a0c:	mov    rsi,r15
   22a0f:	call   QWORD PTR [rip+0x67793]        # 8a1a8 <_DYNAMIC+0x250>
   22a15:	mov    rax,rbx
   22a18:	add    rsp,0x118
   22a1f:	pop    rbx
   22a20:	pop    r12
   22a22:	pop    r13
   22a24:	pop    r14
   22a26:	pop    r15
   22a28:	pop    rbp
   22a29:	ret
   22a2a:	lea    rax,[rip+0x644df]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22a31:	lea    r10,[rip+0xfffffffffffe4f48]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22a38:	lea    r11,[rip+0x64711]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22a3f:	lea    r14,[rip+0x64792]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22a46:	mov    r8d,0x1
   22a4c:	mov    r9d,0x1
   22a52:	mov    rdx,rbp
   22a55:	mov    rcx,rbx
   22a58:	push   rax
   22a59:	push   r10
   22a5b:	push   r11
   22a5d:	push   r14
   22a5f:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22a64:	add    rsp,0x20
   22a68:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22a6d:	mov    edi,0x8
   22a72:	mov    esi,0x28
   22a77:	call   QWORD PTR [rip+0x67733]        # 8a1b0 <_DYNAMIC+0x258>
   22a7d:	lea    rax,[rip+0x6448c]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22a84:	lea    r10,[rip+0xfffffffffffe4ef5]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22a8b:	lea    r11,[rip+0x646be]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22a92:	lea    rbx,[rip+0x6473f]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22a99:	mov    r8d,0x1
   22a9f:	mov    r9d,0x1
   22aa5:	mov    rdx,r15
   22aa8:	mov    rcx,r12
   22aab:	push   rax
   22aac:	push   r10
   22aae:	push   r11
   22ab0:	push   rbx
   22ab1:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22ab6:	add    rsp,0x20
   22aba:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22abf:	lea    rax,[rip+0x6444a]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22ac6:	lea    r10,[rip+0xfffffffffffe4eb3]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22acd:	lea    r11,[rip+0x6467c]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22ad4:	lea    rbx,[rip+0x646fd]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22adb:	mov    r8d,0x1
   22ae1:	mov    r9d,0x1
   22ae7:	mov    rdx,r15
   22aea:	mov    rcx,r12
   22aed:	push   rax
   22aee:	push   r10
   22af0:	push   r11
   22af2:	push   rbx
   22af3:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22af8:	add    rsp,0x20
   22afc:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22b01:	lea    rax,[rip+0x64408]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22b08:	lea    r10,[rip+0xfffffffffffe4e71]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22b0f:	lea    r11,[rip+0x6463a]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22b16:	lea    rbx,[rip+0x646bb]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22b1d:	mov    r8d,0x1
   22b23:	mov    r9d,0x1
   22b29:	mov    rdx,r15
   22b2c:	mov    rcx,r12
   22b2f:	push   rax
   22b30:	push   r10
   22b32:	push   r11
   22b34:	push   rbx
   22b35:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22b3a:	add    rsp,0x20
   22b3e:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22b40:	lea    rax,[rip+0x643c9]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22b47:	lea    r10,[rip+0xfffffffffffe4e32]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22b4e:	lea    r11,[rip+0x645fb]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22b55:	lea    rbx,[rip+0x6467c]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22b5c:	mov    r8d,0x1
   22b62:	mov    r9d,0x1
   22b68:	mov    rdx,r15
   22b6b:	mov    rcx,r12
   22b6e:	push   rax
   22b6f:	push   r10
   22b71:	push   r11
   22b73:	push   rbx
   22b74:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22b79:	add    rsp,0x20
   22b7d:	jmp    22bbc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbdc>
   22b7f:	lea    rax,[rip+0x6438a]        # 86f10 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1d8>
   22b86:	lea    r10,[rip+0xfffffffffffe4df3]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   22b8d:	lea    r11,[rip+0x645bc]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   22b94:	lea    rbx,[rip+0x6463d]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   22b9b:	mov    r8d,0x1
   22ba1:	mov    r9d,0x1
   22ba7:	mov    rdx,r14
   22baa:	mov    rcx,r15
   22bad:	push   rax
   22bae:	push   r10
   22bb0:	push   r11
   22bb2:	push   rbx
   22bb3:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   22bb8:	add    rsp,0x20
   22bbc:	ud2
   22bbe:	lea    rdx,[rsp+0x18]
   22bc3:	mov    rdi,r14
   22bc6:	mov    rsi,r12
   22bc9:	call   34170 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   22bce:	jmp    229dd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9fd>
   22bd3:	mov    esi,0x2
   22bd8:	jmp    2285d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x87d>
   22bdd:	jmp    22be5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc05>
   22bdf:	jmp    22be5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc05>
   22be1:	jmp    22be5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc05>
   22be3:	jmp    22be5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc05>
   22be5:	mov    rbx,rax
   22be8:	mov    rsi,QWORD PTR [rsp+0x38]
   22bed:	test   rsi,rsi
   22bf0:	je     22c41 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc61>
   22bf2:	mov    rdi,QWORD PTR [rsp+0x18]
   22bf7:	mov    rdx,QWORD PTR [rsp+0x30]
   22bfc:	call   QWORD PTR [rip+0x675a6]        # 8a1a8 <_DYNAMIC+0x250>
   22c02:	jmp    22c41 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc61>
   22c04:	mov    rbx,rax
   22c07:	mov    rsi,QWORD PTR [rsp+0x38]
   22c0c:	test   rsi,rsi
   22c0f:	je     22c5e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc7e>
   22c11:	mov    rdi,QWORD PTR [rsp+0x18]
   22c16:	mov    rdx,QWORD PTR [rsp+0x30]
   22c1b:	jmp    22c58 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc78>
   22c1d:	jmp    22c3e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc5e>
   22c1f:	mov    rbx,rax
   22c22:	test   r15,r15
   22c25:	je     22c41 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc61>
   22c27:	shl    r15,0x3
   22c2b:	mov    edx,0x8
   22c30:	mov    rdi,r14
   22c33:	mov    rsi,r15
   22c36:	call   QWORD PTR [rip+0x6756c]        # 8a1a8 <_DYNAMIC+0x250>
   22c3c:	jmp    22c41 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc61>
   22c3e:	mov    rbx,rax
   22c41:	mov    rsi,QWORD PTR [rsp]
   22c45:	test   rsi,rsi
   22c48:	je     22c5e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc7e>
   22c4a:	mov    rdi,QWORD PTR [rsp+0x8]
   22c4f:	shl    rsi,0x3
   22c53:	mov    edx,0x8
   22c58:	call   QWORD PTR [rip+0x6754a]        # 8a1a8 <_DYNAMIC+0x250>
   22c5e:	mov    rdi,rbx
   22c61:	call   85c90 <_Unwind_Resume@plt>
