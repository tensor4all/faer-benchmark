
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000023220 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_>:
   23220:	push   rbp
   23221:	push   r15
   23223:	push   r14
   23225:	push   r13
   23227:	push   r12
   23229:	push   rbx
   2322a:	sub    rsp,0x118
   23231:	mov    r14,rsi
   23234:	mov    QWORD PTR [rsp+0x100],rdi
   2323c:	call   QWORD PTR [rip+0x668de]        # 89b20 <_DYNAMIC+0x2b0>
   23242:	mov    QWORD PTR [rsp+0x108],rax
   2324a:	mov    DWORD PTR [rsp+0x110],edx
   23251:	lea    rdi,[rsp+0x108]
   23259:	call   QWORD PTR [rip+0x668c9]        # 89b28 <_DYNAMIC+0x2b8>
   2325f:	test   rax,rax
   23262:	je     23ab4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x894>
   23268:	call   QWORD PTR [rip+0x66872]        # 89ae0 <_DYNAMIC+0x270>
   2326e:	mov    edi,0x28
   23273:	mov    esi,0x8
   23278:	call   QWORD PTR [rip+0x6686a]        # 89ae8 <_DYNAMIC+0x278>
   2327e:	test   rax,rax
   23281:	je     23c5e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa3e>
   23287:	mov    QWORD PTR [rsp],0x5
   2328f:	mov    QWORD PTR [rsp+0x8],rax
   23294:	mov    QWORD PTR [rsp+0x10],0x0
   2329d:	call   QWORD PTR [rip+0x6687d]        # 89b20 <_DYNAMIC+0x2b0>
   232a3:	mov    QWORD PTR [rsp+0x88],rax
   232ab:	mov    DWORD PTR [rsp+0x90],edx
   232b2:	mov    rax,QWORD PTR [r14+0x20]
   232b6:	mov    QWORD PTR [rsp+0x70],rax
   232bb:	movups xmm0,XMMWORD PTR [r14]
   232bf:	movupd xmm1,XMMWORD PTR [r14+0x10]
   232c5:	movapd XMMWORD PTR [rsp+0x60],xmm1
   232cb:	movaps XMMWORD PTR [rsp+0x50],xmm0
   232d0:	lea    rax,[rsp+0x50]
   232d5:	mov    rax,QWORD PTR [rsp+0x50]
   232da:	mov    r15,QWORD PTR [rsp+0x58]
   232df:	mov    rcx,QWORD PTR [rsp+0x70]
   232e4:	mov    QWORD PTR [rsp+0xd0],rax
   232ec:	mov    QWORD PTR [rsp+0xd8],r15
   232f4:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   232fa:	mov    r12,QWORD PTR [rsp+0x60]
   232ff:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23308:	mov    QWORD PTR [rsp+0xf0],rcx
   23310:	lea    rdi,[rsp+0x18]
   23315:	lea    rsi,[rsp+0xd0]
   2331d:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   23322:	mov    rdi,QWORD PTR [rsp+0x40]
   23327:	mov    rsi,QWORD PTR [rsp+0x48]
   2332c:	cmp    rdi,r15
   2332f:	jne    23c6e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa4e>
   23335:	cmp    rsi,r12
   23338:	jne    23c6e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa4e>
   2333e:	mov    rax,QWORD PTR [rsp+0x18]
   23343:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23349:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2334f:	mov    QWORD PTR [rsp+0x98],rax
   23357:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23360:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23369:	mov    QWORD PTR [rsp+0xc0],r15
   23371:	mov    QWORD PTR [rsp+0xc8],r12
   23379:	lea    rax,[rsp+0x98]
   23381:	mov    rsi,QWORD PTR [rsp+0xb8]
   23389:	test   rsi,rsi
   2338c:	je     233a4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x184>
   2338e:	mov    rdi,QWORD PTR [rsp+0x98]
   23396:	mov    rdx,QWORD PTR [rsp+0xb0]
   2339e:	call   QWORD PTR [rip+0x6672c]        # 89ad0 <_DYNAMIC+0x260>
   233a4:	lea    rdi,[rsp+0x88]
   233ac:	call   QWORD PTR [rip+0x66776]        # 89b28 <_DYNAMIC+0x2b8>
   233b2:	mov    r15,rax
   233b5:	mov    ebx,edx
   233b7:	mov    r12,QWORD PTR [rsp+0x10]
   233bc:	cmp    r12,QWORD PTR [rsp]
   233c0:	jne    233ca <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x1aa>
   233c2:	mov    rdi,rsp
   233c5:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   233ca:	movq   xmm0,r15
   233cf:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe9a69]        # ce40 <GCC_except_table145+0x74>
   233d7:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe9a01]        # cde0 <GCC_except_table145+0x14>
   233df:	movapd xmm1,xmm0
   233e3:	unpckhpd xmm1,xmm0
   233e7:	cvtsi2sd xmm2,ebx
   233eb:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe9cad]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   233f3:	addsd  xmm1,xmm0
   233f7:	addsd  xmm2,xmm1
   233fb:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe9d05]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   23403:	mov    rax,QWORD PTR [rsp+0x8]
   23408:	movsd  QWORD PTR [rax+r12*8],xmm2
   2340e:	inc    r12
   23411:	mov    QWORD PTR [rsp+0x10],r12
   23416:	call   QWORD PTR [rip+0x66704]        # 89b20 <_DYNAMIC+0x2b0>
   2341c:	mov    QWORD PTR [rsp+0x88],rax
   23424:	mov    DWORD PTR [rsp+0x90],edx
   2342b:	mov    rax,QWORD PTR [r14+0x20]
   2342f:	mov    QWORD PTR [rsp+0x70],rax
   23434:	movups xmm0,XMMWORD PTR [r14]
   23438:	movupd xmm1,XMMWORD PTR [r14+0x10]
   2343e:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23444:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23449:	lea    rax,[rsp+0x50]
   2344e:	mov    rax,QWORD PTR [rsp+0x50]
   23453:	mov    r15,QWORD PTR [rsp+0x58]
   23458:	mov    rcx,QWORD PTR [rsp+0x70]
   2345d:	mov    QWORD PTR [rsp+0xd0],rax
   23465:	mov    QWORD PTR [rsp+0xd8],r15
   2346d:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23473:	mov    r12,QWORD PTR [rsp+0x60]
   23478:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23481:	mov    QWORD PTR [rsp+0xf0],rcx
   23489:	lea    rdi,[rsp+0x18]
   2348e:	lea    rsi,[rsp+0xd0]
   23496:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   2349b:	mov    rdi,QWORD PTR [rsp+0x40]
   234a0:	mov    rsi,QWORD PTR [rsp+0x48]
   234a5:	cmp    rdi,r15
   234a8:	jne    23cb0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa90>
   234ae:	cmp    rsi,r12
   234b1:	jne    23cb0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xa90>
   234b7:	mov    rax,QWORD PTR [rsp+0x18]
   234bc:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   234c2:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   234c8:	mov    QWORD PTR [rsp+0x98],rax
   234d0:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   234d9:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   234e2:	mov    QWORD PTR [rsp+0xc0],r15
   234ea:	mov    QWORD PTR [rsp+0xc8],r12
   234f2:	lea    rax,[rsp+0x98]
   234fa:	mov    rsi,QWORD PTR [rsp+0xb8]
   23502:	test   rsi,rsi
   23505:	je     2351d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x2fd>
   23507:	mov    rdi,QWORD PTR [rsp+0x98]
   2350f:	mov    rdx,QWORD PTR [rsp+0xb0]
   23517:	call   QWORD PTR [rip+0x665b3]        # 89ad0 <_DYNAMIC+0x260>
   2351d:	lea    rdi,[rsp+0x88]
   23525:	call   QWORD PTR [rip+0x665fd]        # 89b28 <_DYNAMIC+0x2b8>
   2352b:	mov    r15,rax
   2352e:	mov    ebx,edx
   23530:	mov    r12,QWORD PTR [rsp+0x10]
   23535:	cmp    r12,QWORD PTR [rsp]
   23539:	jne    23543 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x323>
   2353b:	mov    rdi,rsp
   2353e:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23543:	movq   xmm0,r15
   23548:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe98f0]        # ce40 <GCC_except_table145+0x74>
   23550:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe9888]        # cde0 <GCC_except_table145+0x14>
   23558:	movapd xmm1,xmm0
   2355c:	unpckhpd xmm1,xmm0
   23560:	cvtsi2sd xmm2,ebx
   23564:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe9b34]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   2356c:	addsd  xmm1,xmm0
   23570:	addsd  xmm2,xmm1
   23574:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe9b8c]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   2357c:	mov    rax,QWORD PTR [rsp+0x8]
   23581:	movsd  QWORD PTR [rax+r12*8],xmm2
   23587:	inc    r12
   2358a:	mov    QWORD PTR [rsp+0x10],r12
   2358f:	call   QWORD PTR [rip+0x6658b]        # 89b20 <_DYNAMIC+0x2b0>
   23595:	mov    QWORD PTR [rsp+0x88],rax
   2359d:	mov    DWORD PTR [rsp+0x90],edx
   235a4:	mov    rax,QWORD PTR [r14+0x20]
   235a8:	mov    QWORD PTR [rsp+0x70],rax
   235ad:	movups xmm0,XMMWORD PTR [r14]
   235b1:	movupd xmm1,XMMWORD PTR [r14+0x10]
   235b7:	movapd XMMWORD PTR [rsp+0x60],xmm1
   235bd:	movaps XMMWORD PTR [rsp+0x50],xmm0
   235c2:	lea    rax,[rsp+0x50]
   235c7:	mov    rax,QWORD PTR [rsp+0x50]
   235cc:	mov    r15,QWORD PTR [rsp+0x58]
   235d1:	mov    rcx,QWORD PTR [rsp+0x70]
   235d6:	mov    QWORD PTR [rsp+0xd0],rax
   235de:	mov    QWORD PTR [rsp+0xd8],r15
   235e6:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   235ec:	mov    r12,QWORD PTR [rsp+0x60]
   235f1:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   235fa:	mov    QWORD PTR [rsp+0xf0],rcx
   23602:	lea    rdi,[rsp+0x18]
   23607:	lea    rsi,[rsp+0xd0]
   2360f:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   23614:	mov    rdi,QWORD PTR [rsp+0x40]
   23619:	mov    rsi,QWORD PTR [rsp+0x48]
   2361e:	cmp    rdi,r15
   23621:	jne    23cf2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xad2>
   23627:	cmp    rsi,r12
   2362a:	jne    23cf2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xad2>
   23630:	mov    rax,QWORD PTR [rsp+0x18]
   23635:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2363b:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23641:	mov    QWORD PTR [rsp+0x98],rax
   23649:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23652:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2365b:	mov    QWORD PTR [rsp+0xc0],r15
   23663:	mov    QWORD PTR [rsp+0xc8],r12
   2366b:	lea    rax,[rsp+0x98]
   23673:	mov    rsi,QWORD PTR [rsp+0xb8]
   2367b:	test   rsi,rsi
   2367e:	je     23696 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x476>
   23680:	mov    rdi,QWORD PTR [rsp+0x98]
   23688:	mov    rdx,QWORD PTR [rsp+0xb0]
   23690:	call   QWORD PTR [rip+0x6643a]        # 89ad0 <_DYNAMIC+0x260>
   23696:	lea    rdi,[rsp+0x88]
   2369e:	call   QWORD PTR [rip+0x66484]        # 89b28 <_DYNAMIC+0x2b8>
   236a4:	mov    r15,rax
   236a7:	mov    ebx,edx
   236a9:	mov    r12,QWORD PTR [rsp+0x10]
   236ae:	cmp    r12,QWORD PTR [rsp]
   236b2:	jne    236bc <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x49c>
   236b4:	mov    rdi,rsp
   236b7:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   236bc:	movq   xmm0,r15
   236c1:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe9777]        # ce40 <GCC_except_table145+0x74>
   236c9:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe970f]        # cde0 <GCC_except_table145+0x14>
   236d1:	movapd xmm1,xmm0
   236d5:	unpckhpd xmm1,xmm0
   236d9:	cvtsi2sd xmm2,ebx
   236dd:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe99bb]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   236e5:	addsd  xmm1,xmm0
   236e9:	addsd  xmm2,xmm1
   236ed:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe9a13]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   236f5:	mov    rax,QWORD PTR [rsp+0x8]
   236fa:	movsd  QWORD PTR [rax+r12*8],xmm2
   23700:	inc    r12
   23703:	mov    QWORD PTR [rsp+0x10],r12
   23708:	call   QWORD PTR [rip+0x66412]        # 89b20 <_DYNAMIC+0x2b0>
   2370e:	mov    QWORD PTR [rsp+0x88],rax
   23716:	mov    DWORD PTR [rsp+0x90],edx
   2371d:	mov    rax,QWORD PTR [r14+0x20]
   23721:	mov    QWORD PTR [rsp+0x70],rax
   23726:	movups xmm0,XMMWORD PTR [r14]
   2372a:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23730:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23736:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2373b:	lea    rax,[rsp+0x50]
   23740:	mov    rax,QWORD PTR [rsp+0x50]
   23745:	mov    r15,QWORD PTR [rsp+0x58]
   2374a:	mov    rcx,QWORD PTR [rsp+0x70]
   2374f:	mov    QWORD PTR [rsp+0xd0],rax
   23757:	mov    QWORD PTR [rsp+0xd8],r15
   2375f:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23765:	mov    r12,QWORD PTR [rsp+0x60]
   2376a:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23773:	mov    QWORD PTR [rsp+0xf0],rcx
   2377b:	lea    rdi,[rsp+0x18]
   23780:	lea    rsi,[rsp+0xd0]
   23788:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   2378d:	mov    rdi,QWORD PTR [rsp+0x40]
   23792:	mov    rsi,QWORD PTR [rsp+0x48]
   23797:	cmp    rdi,r15
   2379a:	jne    23d34 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb14>
   237a0:	cmp    rsi,r12
   237a3:	jne    23d34 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb14>
   237a9:	mov    rax,QWORD PTR [rsp+0x18]
   237ae:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   237b4:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   237ba:	mov    QWORD PTR [rsp+0x98],rax
   237c2:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   237cb:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   237d4:	mov    QWORD PTR [rsp+0xc0],r15
   237dc:	mov    QWORD PTR [rsp+0xc8],r12
   237e4:	lea    rax,[rsp+0x98]
   237ec:	mov    rsi,QWORD PTR [rsp+0xb8]
   237f4:	test   rsi,rsi
   237f7:	je     2380f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x5ef>
   237f9:	mov    rdi,QWORD PTR [rsp+0x98]
   23801:	mov    rdx,QWORD PTR [rsp+0xb0]
   23809:	call   QWORD PTR [rip+0x662c1]        # 89ad0 <_DYNAMIC+0x260>
   2380f:	lea    rdi,[rsp+0x88]
   23817:	call   QWORD PTR [rip+0x6630b]        # 89b28 <_DYNAMIC+0x2b8>
   2381d:	mov    r15,rax
   23820:	mov    ebx,edx
   23822:	mov    r12,QWORD PTR [rsp+0x10]
   23827:	cmp    r12,QWORD PTR [rsp]
   2382b:	jne    23835 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x615>
   2382d:	mov    rdi,rsp
   23830:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   23835:	movq   xmm0,r15
   2383a:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe95fe]        # ce40 <GCC_except_table145+0x74>
   23842:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe9596]        # cde0 <GCC_except_table145+0x14>
   2384a:	movapd xmm1,xmm0
   2384e:	unpckhpd xmm1,xmm0
   23852:	cvtsi2sd xmm2,ebx
   23856:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe9842]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   2385e:	addsd  xmm1,xmm0
   23862:	addsd  xmm2,xmm1
   23866:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe989a]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   2386e:	mov    rax,QWORD PTR [rsp+0x8]
   23873:	movsd  QWORD PTR [rax+r12*8],xmm2
   23879:	inc    r12
   2387c:	mov    QWORD PTR [rsp+0x10],r12
   23881:	call   QWORD PTR [rip+0x66299]        # 89b20 <_DYNAMIC+0x2b0>
   23887:	mov    QWORD PTR [rsp+0x88],rax
   2388f:	mov    DWORD PTR [rsp+0x90],edx
   23896:	mov    rax,QWORD PTR [r14+0x20]
   2389a:	mov    QWORD PTR [rsp+0x70],rax
   2389f:	movups xmm0,XMMWORD PTR [r14]
   238a3:	movupd xmm1,XMMWORD PTR [r14+0x10]
   238a9:	movapd XMMWORD PTR [rsp+0x60],xmm1
   238af:	movaps XMMWORD PTR [rsp+0x50],xmm0
   238b4:	lea    rax,[rsp+0x50]
   238b9:	mov    rax,QWORD PTR [rsp+0x50]
   238be:	mov    r14,QWORD PTR [rsp+0x58]
   238c3:	mov    rcx,QWORD PTR [rsp+0x70]
   238c8:	mov    QWORD PTR [rsp+0xd0],rax
   238d0:	mov    QWORD PTR [rsp+0xd8],r14
   238d8:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   238de:	mov    r15,QWORD PTR [rsp+0x60]
   238e3:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   238ec:	mov    QWORD PTR [rsp+0xf0],rcx
   238f4:	lea    rdi,[rsp+0x18]
   238f9:	lea    rsi,[rsp+0xd0]
   23901:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   23906:	mov    rdi,QWORD PTR [rsp+0x40]
   2390b:	mov    rsi,QWORD PTR [rsp+0x48]
   23910:	cmp    rdi,r14
   23913:	jne    23d73 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb53>
   23919:	cmp    rsi,r15
   2391c:	jne    23d73 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb53>
   23922:	mov    rax,QWORD PTR [rsp+0x18]
   23927:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2392d:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23933:	mov    QWORD PTR [rsp+0x98],rax
   2393b:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23944:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2394d:	mov    QWORD PTR [rsp+0xc0],r14
   23955:	mov    QWORD PTR [rsp+0xc8],r15
   2395d:	lea    rax,[rsp+0x98]
   23965:	mov    rsi,QWORD PTR [rsp+0xb8]
   2396d:	test   rsi,rsi
   23970:	je     23988 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x768>
   23972:	mov    rdi,QWORD PTR [rsp+0x98]
   2397a:	mov    rdx,QWORD PTR [rsp+0xb0]
   23982:	call   QWORD PTR [rip+0x66148]        # 89ad0 <_DYNAMIC+0x260>
   23988:	lea    rdi,[rsp+0x88]
   23990:	call   QWORD PTR [rip+0x66192]        # 89b28 <_DYNAMIC+0x2b8>
   23996:	mov    r14,rax
   23999:	mov    ebx,edx
   2399b:	mov    rbp,QWORD PTR [rsp+0x10]
   239a0:	cmp    rbp,QWORD PTR [rsp]
   239a4:	jne    239ae <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x78e>
   239a6:	mov    rdi,rsp
   239a9:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   239ae:	movq   xmm0,r14
   239b3:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe9485]        # ce40 <GCC_except_table145+0x74>
   239bb:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe941d]        # cde0 <GCC_except_table145+0x14>
   239c3:	movapd xmm1,xmm0
   239c7:	unpckhpd xmm1,xmm0
   239cb:	addsd  xmm1,xmm0
   239cf:	xorps  xmm0,xmm0
   239d2:	cvtsi2sd xmm0,ebx
   239d6:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe96c2]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   239de:	addsd  xmm0,xmm1
   239e2:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe971e]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   239ea:	mov    rax,QWORD PTR [rsp+0x8]
   239ef:	movsd  QWORD PTR [rax+rbp*8],xmm0
   239f4:	lea    r12,[rbp+0x1]
   239f8:	mov    QWORD PTR [rsp+0x10],r12
   239fd:	lea    r13,[rbp*8+0x8]
   23a05:	mov    rax,r12
   23a08:	shr    rax,0x3d
   23a0c:	setne  al
   23a0f:	movabs rcx,0x7ffffffffffffff8
   23a19:	cmp    r13,rcx
   23a1c:	seta   cl
   23a1f:	or     cl,al
   23a21:	je     23a37 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x817>
   23a23:	xor    r15d,r15d
   23a26:	mov    rdi,r15
   23a29:	mov    rsi,r13
   23a2c:	call   QWORD PTR [rip+0x660be]        # 89af0 <_DYNAMIC+0x280>
   23a32:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23a37:	mov    rbx,QWORD PTR [rsp+0x8]
   23a3c:	test   r13,r13
   23a3f:	je     23bcf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9af>
   23a45:	call   QWORD PTR [rip+0x66095]        # 89ae0 <_DYNAMIC+0x270>
   23a4b:	mov    r15d,0x8
   23a51:	mov    esi,0x8
   23a56:	mov    rdi,r13
   23a59:	call   QWORD PTR [rip+0x66089]        # 89ae8 <_DYNAMIC+0x278>
   23a5f:	test   rax,rax
   23a62:	je     23a26 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x806>
   23a64:	mov    r14,rax
   23a67:	mov    r15,r12
   23a6a:	test   r12,r12
   23a6d:	je     23be1 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9c1>
   23a73:	mov    rdi,r14
   23a76:	mov    rsi,rbx
   23a79:	mov    rdx,r13
   23a7c:	call   QWORD PTR [rip+0x6608e]        # 89b10 <memcpy@GLIBC_2.14>
   23a82:	lea    rax,[rsp+0x87]
   23a8a:	mov    QWORD PTR [rsp+0x18],rax
   23a8f:	mov    esi,0x1
   23a94:	test   rbp,rbp
   23a97:	jne    23be8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9c8>
   23a9d:	lea    rdx,[rip+0x62b84]        # 86628 <anon.2c393db9686f2344a1ccdcb44f907da6.0.llvm.13323335406852763521+0x18>
   23aa4:	mov    edi,0x2
   23aa9:	call   QWORD PTR [rip+0x66081]        # 89b30 <_DYNAMIC+0x2c0>
   23aaf:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23ab4:	lea    r15,[rsp+0x18]
   23ab9:	lea    r13,[rsp+0x108]
   23ac1:	mov    r12,QWORD PTR [rip+0x66060]        # 89b28 <_DYNAMIC+0x2b8>
   23ac8:	cmp    edx,0xee6b280
   23ace:	jae    23268 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x48>
   23ad4:	mov    rax,QWORD PTR [r14+0x20]
   23ad8:	mov    QWORD PTR [rsp+0xf0],rax
   23ae0:	movups xmm0,XMMWORD PTR [r14]
   23ae4:	movups xmm1,XMMWORD PTR [r14+0x10]
   23ae9:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   23af1:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   23af9:	lea    rax,[rsp+0xd0]
   23b01:	mov    rax,QWORD PTR [rsp+0xd0]
   23b09:	mov    rbp,QWORD PTR [rsp+0xd8]
   23b11:	mov    rcx,QWORD PTR [rsp+0xf0]
   23b19:	mov    QWORD PTR [rsp+0x98],rax
   23b21:	mov    QWORD PTR [rsp+0xa0],rbp
   23b29:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   23b31:	mov    rbx,QWORD PTR [rsp+0xe0]
   23b39:	movups XMMWORD PTR [rsp+0xa8],xmm0
   23b41:	mov    QWORD PTR [rsp+0xb8],rcx
   23b49:	mov    rdi,r15
   23b4c:	lea    rsi,[rsp+0x98]
   23b54:	call   26500 <_RINvNvMsa_NtNtCsfyJFFj4AWdU_4faer3mat6matrefINtNtBa_7generic3MatpE8to_owned3impINtCskC1yiOI7W9g_11num_complex7ComplexdEiiECskuD9mmv22aj_16owned_copy_probe>
   23b59:	mov    rdi,QWORD PTR [rsp+0x40]
   23b5e:	mov    rsi,QWORD PTR [rsp+0x48]
   23b63:	cmp    rdi,rbp
   23b66:	jne    23db2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb92>
   23b6c:	cmp    rsi,rbx
   23b6f:	jne    23db2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xb92>
   23b75:	mov    rax,QWORD PTR [rsp+0x18]
   23b7a:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23b80:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23b86:	mov    QWORD PTR [rsp+0x18],rax
   23b8b:	movupd XMMWORD PTR [rsp+0x20],xmm0
   23b91:	movupd XMMWORD PTR [rsp+0x30],xmm1
   23b97:	mov    QWORD PTR [rsp+0x40],rbp
   23b9c:	mov    QWORD PTR [rsp+0x48],rbx
   23ba1:	mov    rsi,QWORD PTR [rsp+0x38]
   23ba6:	test   rsi,rsi
   23ba9:	je     23bbb <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x99b>
   23bab:	mov    rdi,QWORD PTR [rsp+0x18]
   23bb0:	mov    rdx,QWORD PTR [rsp+0x30]
   23bb5:	call   QWORD PTR [rip+0x65f15]        # 89ad0 <_DYNAMIC+0x260>
   23bbb:	mov    rdi,r13
   23bbe:	call   r12
   23bc1:	test   rax,rax
   23bc4:	je     23ac8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x8a8>
   23bca:	jmp    23268 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x48>
   23bcf:	mov    r14d,0x8
   23bd5:	xor    r15d,r15d
   23bd8:	test   r12,r12
   23bdb:	jne    23a73 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x853>
   23be1:	xor    esi,esi
   23be3:	jmp    23a9d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x87d>
   23be8:	cmp    r12,0x15
   23bec:	jae    23df2 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd2>
   23bf2:	lea    rcx,[rsp+0x18]
   23bf7:	mov    edx,0x1
   23bfc:	mov    rdi,r14
   23bff:	mov    rsi,r12
   23c02:	call   34140 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   23c07:	cmp    r12,0x3
   23c0b:	jb     23e07 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbe7>
   23c11:	movsd  xmm0,QWORD PTR [r14+0x10]
   23c17:	mov    rax,QWORD PTR [rsp+0x10]
   23c1c:	mov    rbx,QWORD PTR [rsp+0x100]
   23c24:	mov    QWORD PTR [rbx+0x18],rax
   23c28:	movups xmm1,XMMWORD PTR [rsp]
   23c2c:	movups XMMWORD PTR [rbx+0x8],xmm1
   23c30:	movsd  QWORD PTR [rbx],xmm0
   23c34:	shl    r15,0x3
   23c38:	mov    edx,0x8
   23c3d:	mov    rdi,r14
   23c40:	mov    rsi,r15
   23c43:	call   QWORD PTR [rip+0x65e87]        # 89ad0 <_DYNAMIC+0x260>
   23c49:	mov    rax,rbx
   23c4c:	add    rsp,0x118
   23c53:	pop    rbx
   23c54:	pop    r12
   23c56:	pop    r13
   23c58:	pop    r14
   23c5a:	pop    r15
   23c5c:	pop    rbp
   23c5d:	ret
   23c5e:	mov    edi,0x8
   23c63:	mov    esi,0x28
   23c68:	call   QWORD PTR [rip+0x65e82]        # 89af0 <_DYNAMIC+0x280>
   23c6e:	lea    rax,[rip+0x62b2b]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23c75:	lea    r10,[rip+0xfffffffffffe9414]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23c7c:	lea    r11,[rip+0x62de5]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23c83:	lea    rbx,[rip+0x62e66]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23c8a:	mov    r8d,0x1
   23c90:	mov    r9d,0x1
   23c96:	mov    rdx,r15
   23c99:	mov    rcx,r12
   23c9c:	push   rax
   23c9d:	push   r10
   23c9f:	push   r11
   23ca1:	push   rbx
   23ca2:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23ca7:	add    rsp,0x20
   23cab:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23cb0:	lea    rax,[rip+0x62ae9]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23cb7:	lea    r10,[rip+0xfffffffffffe93d2]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23cbe:	lea    r11,[rip+0x62da3]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23cc5:	lea    rbx,[rip+0x62e24]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23ccc:	mov    r8d,0x1
   23cd2:	mov    r9d,0x1
   23cd8:	mov    rdx,r15
   23cdb:	mov    rcx,r12
   23cde:	push   rax
   23cdf:	push   r10
   23ce1:	push   r11
   23ce3:	push   rbx
   23ce4:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23ce9:	add    rsp,0x20
   23ced:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23cf2:	lea    rax,[rip+0x62aa7]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23cf9:	lea    r10,[rip+0xfffffffffffe9390]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23d00:	lea    r11,[rip+0x62d61]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23d07:	lea    rbx,[rip+0x62de2]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23d0e:	mov    r8d,0x1
   23d14:	mov    r9d,0x1
   23d1a:	mov    rdx,r15
   23d1d:	mov    rcx,r12
   23d20:	push   rax
   23d21:	push   r10
   23d23:	push   r11
   23d25:	push   rbx
   23d26:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23d2b:	add    rsp,0x20
   23d2f:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23d34:	lea    rax,[rip+0x62a65]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23d3b:	lea    r10,[rip+0xfffffffffffe934e]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23d42:	lea    r11,[rip+0x62d1f]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23d49:	lea    rbx,[rip+0x62da0]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23d50:	mov    r8d,0x1
   23d56:	mov    r9d,0x1
   23d5c:	mov    rdx,r15
   23d5f:	mov    rcx,r12
   23d62:	push   rax
   23d63:	push   r10
   23d65:	push   r11
   23d67:	push   rbx
   23d68:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23d6d:	add    rsp,0x20
   23d71:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23d73:	lea    rax,[rip+0x62a26]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23d7a:	lea    r10,[rip+0xfffffffffffe930f]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23d81:	lea    r11,[rip+0x62ce0]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23d88:	lea    rbx,[rip+0x62d61]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23d8f:	mov    r8d,0x1
   23d95:	mov    r9d,0x1
   23d9b:	mov    rdx,r14
   23d9e:	mov    rcx,r15
   23da1:	push   rax
   23da2:	push   r10
   23da4:	push   r11
   23da6:	push   rbx
   23da7:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23dac:	add    rsp,0x20
   23db0:	jmp    23df0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xbd0>
   23db2:	lea    rax,[rip+0x629e7]        # 867a0 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xd0>
   23db9:	lea    r10,[rip+0xfffffffffffe92d0]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   23dc0:	lea    r11,[rip+0x62ca1]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   23dc7:	lea    r14,[rip+0x62d22]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   23dce:	mov    r8d,0x1
   23dd4:	mov    r9d,0x1
   23dda:	mov    rdx,rbp
   23ddd:	mov    rcx,rbx
   23de0:	push   rax
   23de1:	push   r10
   23de3:	push   r11
   23de5:	push   r14
   23de7:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   23dec:	add    rsp,0x20
   23df0:	ud2
   23df2:	lea    rdx,[rsp+0x18]
   23df7:	mov    rdi,r14
   23dfa:	mov    rsi,r12
   23dfd:	call   33a70 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   23e02:	jmp    23c11 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x9f1>
   23e07:	mov    esi,0x2
   23e0c:	jmp    23a9d <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0x87d>
   23e11:	mov    rbx,rax
   23e14:	mov    rsi,QWORD PTR [rsp+0x38]
   23e19:	test   rsi,rsi
   23e1c:	je     23e92 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc72>
   23e1e:	mov    rdi,QWORD PTR [rsp+0x18]
   23e23:	mov    rdx,QWORD PTR [rsp+0x30]
   23e28:	jmp    23e8c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc6c>
   23e2a:	jmp    23e32 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc12>
   23e2c:	jmp    23e32 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc12>
   23e2e:	jmp    23e32 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc12>
   23e30:	jmp    23e32 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc12>
   23e32:	mov    rbx,rax
   23e35:	mov    rsi,QWORD PTR [rsp+0x38]
   23e3a:	test   rsi,rsi
   23e3d:	je     23e75 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc55>
   23e3f:	mov    rdi,QWORD PTR [rsp+0x18]
   23e44:	mov    rdx,QWORD PTR [rsp+0x30]
   23e49:	call   QWORD PTR [rip+0x65c81]        # 89ad0 <_DYNAMIC+0x260>
   23e4f:	jmp    23e75 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc55>
   23e51:	jmp    23e72 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc52>
   23e53:	mov    rbx,rax
   23e56:	test   r15,r15
   23e59:	je     23e75 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc55>
   23e5b:	shl    r15,0x3
   23e5f:	mov    edx,0x8
   23e64:	mov    rdi,r14
   23e67:	mov    rsi,r15
   23e6a:	call   QWORD PTR [rip+0x65c60]        # 89ad0 <_DYNAMIC+0x260>
   23e70:	jmp    23e75 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc55>
   23e72:	mov    rbx,rax
   23e75:	mov    rsi,QWORD PTR [rsp]
   23e79:	test   rsi,rsi
   23e7c:	je     23e92 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s4_0EB2_+0xc72>
   23e7e:	mov    rdi,QWORD PTR [rsp+0x8]
   23e83:	shl    rsi,0x3
   23e87:	mov    edx,0x8
   23e8c:	call   QWORD PTR [rip+0x65c3e]        # 89ad0 <_DYNAMIC+0x260>
   23e92:	mov    rdi,rbx
   23e95:	call   85590 <_Unwind_Resume@plt>
