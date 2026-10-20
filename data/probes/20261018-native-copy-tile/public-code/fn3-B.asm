
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

00000000000245a0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_>:
   245a0:	push   rbp
   245a1:	push   r15
   245a3:	push   r14
   245a5:	push   r13
   245a7:	push   r12
   245a9:	push   rbx
   245aa:	sub    rsp,0x118
   245b1:	mov    r14,rsi
   245b4:	mov    QWORD PTR [rsp+0x100],rdi
   245bc:	call   QWORD PTR [rip+0x65bc6]        # 8a188 <_DYNAMIC+0x230>
   245c2:	mov    QWORD PTR [rsp+0x108],rax
   245ca:	mov    DWORD PTR [rsp+0x110],edx
   245d1:	lea    rdi,[rsp+0x108]
   245d9:	call   QWORD PTR [rip+0x65bb1]        # 8a190 <_DYNAMIC+0x238>
   245df:	test   rax,rax
   245e2:	je     24e52 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x8b2>
   245e8:	call   QWORD PTR [rip+0x65baa]        # 8a198 <_DYNAMIC+0x240>
   245ee:	mov    edi,0x28
   245f3:	mov    esi,0x8
   245f8:	call   QWORD PTR [rip+0x65ba2]        # 8a1a0 <_DYNAMIC+0x248>
   245fe:	test   rax,rax
   24601:	je     25002 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa62>
   24607:	mov    QWORD PTR [rsp],0x5
   2460f:	mov    QWORD PTR [rsp+0x8],rax
   24614:	mov    QWORD PTR [rsp+0x10],0x0
   2461d:	call   QWORD PTR [rip+0x65b65]        # 8a188 <_DYNAMIC+0x230>
   24623:	mov    QWORD PTR [rsp+0x88],rax
   2462b:	mov    DWORD PTR [rsp+0x90],edx
   24632:	mov    rax,QWORD PTR [r14+0x20]
   24636:	mov    QWORD PTR [rsp+0x70],rax
   2463b:	movups xmm0,XMMWORD PTR [r14]
   2463f:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24645:	movapd XMMWORD PTR [rsp+0x60],xmm1
   2464b:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24650:	lea    rax,[rsp+0x50]
   24655:	mov    rax,QWORD PTR [rsp+0x50]
   2465a:	mov    r15,QWORD PTR [rsp+0x58]
   2465f:	mov    rcx,QWORD PTR [rsp+0x70]
   24664:	mov    QWORD PTR [rsp+0xd0],rax
   2466c:	mov    QWORD PTR [rsp+0xd8],r15
   24674:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   2467a:	mov    r12,QWORD PTR [rsp+0x60]
   2467f:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24688:	mov    QWORD PTR [rsp+0xf0],rcx
   24690:	lea    rdi,[rsp+0x18]
   24695:	lea    rcx,[rsp+0xd0]
   2469d:	mov    rsi,r15
   246a0:	mov    rdx,r12
   246a3:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   246a8:	mov    rdi,QWORD PTR [rsp+0x40]
   246ad:	mov    rsi,QWORD PTR [rsp+0x48]
   246b2:	cmp    rdi,r15
   246b5:	jne    25012 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa72>
   246bb:	cmp    rsi,r12
   246be:	jne    25012 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa72>
   246c4:	mov    rax,QWORD PTR [rsp+0x18]
   246c9:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   246cf:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   246d5:	mov    QWORD PTR [rsp+0x98],rax
   246dd:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   246e6:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   246ef:	mov    QWORD PTR [rsp+0xc0],r15
   246f7:	mov    QWORD PTR [rsp+0xc8],r12
   246ff:	lea    rax,[rsp+0x98]
   24707:	mov    rsi,QWORD PTR [rsp+0xb8]
   2470f:	test   rsi,rsi
   24712:	je     2472a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x18a>
   24714:	mov    rdi,QWORD PTR [rsp+0x98]
   2471c:	mov    rdx,QWORD PTR [rsp+0xb0]
   24724:	call   QWORD PTR [rip+0x65a7e]        # 8a1a8 <_DYNAMIC+0x250>
   2472a:	lea    rdi,[rsp+0x88]
   24732:	call   QWORD PTR [rip+0x65a58]        # 8a190 <_DYNAMIC+0x238>
   24738:	mov    r15,rax
   2473b:	mov    ebx,edx
   2473d:	mov    r12,QWORD PTR [rsp+0x10]
   24742:	cmp    r12,QWORD PTR [rsp]
   24746:	jne    24750 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x1b0>
   24748:	mov    rdi,rsp
   2474b:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24750:	movq   xmm0,r15
   24755:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe2fd3]        # 7730 <__abi_tag+0x7434>
   2475d:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe2f6b]        # 76d0 <__abi_tag+0x73d4>
   24765:	movapd xmm1,xmm0
   24769:	unpckhpd xmm1,xmm0
   2476d:	cvtsi2sd xmm2,ebx
   24771:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3217]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   24779:	addsd  xmm1,xmm0
   2477d:	addsd  xmm2,xmm1
   24781:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe326f]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   24789:	mov    rax,QWORD PTR [rsp+0x8]
   2478e:	movsd  QWORD PTR [rax+r12*8],xmm2
   24794:	inc    r12
   24797:	mov    QWORD PTR [rsp+0x10],r12
   2479c:	call   QWORD PTR [rip+0x659e6]        # 8a188 <_DYNAMIC+0x230>
   247a2:	mov    QWORD PTR [rsp+0x88],rax
   247aa:	mov    DWORD PTR [rsp+0x90],edx
   247b1:	mov    rax,QWORD PTR [r14+0x20]
   247b5:	mov    QWORD PTR [rsp+0x70],rax
   247ba:	movups xmm0,XMMWORD PTR [r14]
   247be:	movupd xmm1,XMMWORD PTR [r14+0x10]
   247c4:	movapd XMMWORD PTR [rsp+0x60],xmm1
   247ca:	movaps XMMWORD PTR [rsp+0x50],xmm0
   247cf:	lea    rax,[rsp+0x50]
   247d4:	mov    rax,QWORD PTR [rsp+0x50]
   247d9:	mov    r15,QWORD PTR [rsp+0x58]
   247de:	mov    rcx,QWORD PTR [rsp+0x70]
   247e3:	mov    QWORD PTR [rsp+0xd0],rax
   247eb:	mov    QWORD PTR [rsp+0xd8],r15
   247f3:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   247f9:	mov    r12,QWORD PTR [rsp+0x60]
   247fe:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24807:	mov    QWORD PTR [rsp+0xf0],rcx
   2480f:	lea    rdi,[rsp+0x18]
   24814:	lea    rcx,[rsp+0xd0]
   2481c:	mov    rsi,r15
   2481f:	mov    rdx,r12
   24822:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   24827:	mov    rdi,QWORD PTR [rsp+0x40]
   2482c:	mov    rsi,QWORD PTR [rsp+0x48]
   24831:	cmp    rdi,r15
   24834:	jne    25054 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xab4>
   2483a:	cmp    rsi,r12
   2483d:	jne    25054 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xab4>
   24843:	mov    rax,QWORD PTR [rsp+0x18]
   24848:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2484e:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24854:	mov    QWORD PTR [rsp+0x98],rax
   2485c:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24865:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2486e:	mov    QWORD PTR [rsp+0xc0],r15
   24876:	mov    QWORD PTR [rsp+0xc8],r12
   2487e:	lea    rax,[rsp+0x98]
   24886:	mov    rsi,QWORD PTR [rsp+0xb8]
   2488e:	test   rsi,rsi
   24891:	je     248a9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x309>
   24893:	mov    rdi,QWORD PTR [rsp+0x98]
   2489b:	mov    rdx,QWORD PTR [rsp+0xb0]
   248a3:	call   QWORD PTR [rip+0x658ff]        # 8a1a8 <_DYNAMIC+0x250>
   248a9:	lea    rdi,[rsp+0x88]
   248b1:	call   QWORD PTR [rip+0x658d9]        # 8a190 <_DYNAMIC+0x238>
   248b7:	mov    r15,rax
   248ba:	mov    ebx,edx
   248bc:	mov    r12,QWORD PTR [rsp+0x10]
   248c1:	cmp    r12,QWORD PTR [rsp]
   248c5:	jne    248cf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x32f>
   248c7:	mov    rdi,rsp
   248ca:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   248cf:	movq   xmm0,r15
   248d4:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe2e54]        # 7730 <__abi_tag+0x7434>
   248dc:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe2dec]        # 76d0 <__abi_tag+0x73d4>
   248e4:	movapd xmm1,xmm0
   248e8:	unpckhpd xmm1,xmm0
   248ec:	cvtsi2sd xmm2,ebx
   248f0:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe3098]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   248f8:	addsd  xmm1,xmm0
   248fc:	addsd  xmm2,xmm1
   24900:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe30f0]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   24908:	mov    rax,QWORD PTR [rsp+0x8]
   2490d:	movsd  QWORD PTR [rax+r12*8],xmm2
   24913:	inc    r12
   24916:	mov    QWORD PTR [rsp+0x10],r12
   2491b:	call   QWORD PTR [rip+0x65867]        # 8a188 <_DYNAMIC+0x230>
   24921:	mov    QWORD PTR [rsp+0x88],rax
   24929:	mov    DWORD PTR [rsp+0x90],edx
   24930:	mov    rax,QWORD PTR [r14+0x20]
   24934:	mov    QWORD PTR [rsp+0x70],rax
   24939:	movups xmm0,XMMWORD PTR [r14]
   2493d:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24943:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24949:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2494e:	lea    rax,[rsp+0x50]
   24953:	mov    rax,QWORD PTR [rsp+0x50]
   24958:	mov    r15,QWORD PTR [rsp+0x58]
   2495d:	mov    rcx,QWORD PTR [rsp+0x70]
   24962:	mov    QWORD PTR [rsp+0xd0],rax
   2496a:	mov    QWORD PTR [rsp+0xd8],r15
   24972:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24978:	mov    r12,QWORD PTR [rsp+0x60]
   2497d:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24986:	mov    QWORD PTR [rsp+0xf0],rcx
   2498e:	lea    rdi,[rsp+0x18]
   24993:	lea    rcx,[rsp+0xd0]
   2499b:	mov    rsi,r15
   2499e:	mov    rdx,r12
   249a1:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   249a6:	mov    rdi,QWORD PTR [rsp+0x40]
   249ab:	mov    rsi,QWORD PTR [rsp+0x48]
   249b0:	cmp    rdi,r15
   249b3:	jne    25096 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xaf6>
   249b9:	cmp    rsi,r12
   249bc:	jne    25096 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xaf6>
   249c2:	mov    rax,QWORD PTR [rsp+0x18]
   249c7:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   249cd:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   249d3:	mov    QWORD PTR [rsp+0x98],rax
   249db:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   249e4:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   249ed:	mov    QWORD PTR [rsp+0xc0],r15
   249f5:	mov    QWORD PTR [rsp+0xc8],r12
   249fd:	lea    rax,[rsp+0x98]
   24a05:	mov    rsi,QWORD PTR [rsp+0xb8]
   24a0d:	test   rsi,rsi
   24a10:	je     24a28 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x488>
   24a12:	mov    rdi,QWORD PTR [rsp+0x98]
   24a1a:	mov    rdx,QWORD PTR [rsp+0xb0]
   24a22:	call   QWORD PTR [rip+0x65780]        # 8a1a8 <_DYNAMIC+0x250>
   24a28:	lea    rdi,[rsp+0x88]
   24a30:	call   QWORD PTR [rip+0x6575a]        # 8a190 <_DYNAMIC+0x238>
   24a36:	mov    r15,rax
   24a39:	mov    ebx,edx
   24a3b:	mov    r12,QWORD PTR [rsp+0x10]
   24a40:	cmp    r12,QWORD PTR [rsp]
   24a44:	jne    24a4e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x4ae>
   24a46:	mov    rdi,rsp
   24a49:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24a4e:	movq   xmm0,r15
   24a53:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe2cd5]        # 7730 <__abi_tag+0x7434>
   24a5b:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe2c6d]        # 76d0 <__abi_tag+0x73d4>
   24a63:	movapd xmm1,xmm0
   24a67:	unpckhpd xmm1,xmm0
   24a6b:	cvtsi2sd xmm2,ebx
   24a6f:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe2f19]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   24a77:	addsd  xmm1,xmm0
   24a7b:	addsd  xmm2,xmm1
   24a7f:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe2f71]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   24a87:	mov    rax,QWORD PTR [rsp+0x8]
   24a8c:	movsd  QWORD PTR [rax+r12*8],xmm2
   24a92:	inc    r12
   24a95:	mov    QWORD PTR [rsp+0x10],r12
   24a9a:	call   QWORD PTR [rip+0x656e8]        # 8a188 <_DYNAMIC+0x230>
   24aa0:	mov    QWORD PTR [rsp+0x88],rax
   24aa8:	mov    DWORD PTR [rsp+0x90],edx
   24aaf:	mov    rax,QWORD PTR [r14+0x20]
   24ab3:	mov    QWORD PTR [rsp+0x70],rax
   24ab8:	movups xmm0,XMMWORD PTR [r14]
   24abc:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24ac2:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24ac8:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24acd:	lea    rax,[rsp+0x50]
   24ad2:	mov    rax,QWORD PTR [rsp+0x50]
   24ad7:	mov    r15,QWORD PTR [rsp+0x58]
   24adc:	mov    rcx,QWORD PTR [rsp+0x70]
   24ae1:	mov    QWORD PTR [rsp+0xd0],rax
   24ae9:	mov    QWORD PTR [rsp+0xd8],r15
   24af1:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24af7:	mov    r12,QWORD PTR [rsp+0x60]
   24afc:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24b05:	mov    QWORD PTR [rsp+0xf0],rcx
   24b0d:	lea    rdi,[rsp+0x18]
   24b12:	lea    rcx,[rsp+0xd0]
   24b1a:	mov    rsi,r15
   24b1d:	mov    rdx,r12
   24b20:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   24b25:	mov    rdi,QWORD PTR [rsp+0x40]
   24b2a:	mov    rsi,QWORD PTR [rsp+0x48]
   24b2f:	cmp    rdi,r15
   24b32:	jne    250d8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb38>
   24b38:	cmp    rsi,r12
   24b3b:	jne    250d8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb38>
   24b41:	mov    rax,QWORD PTR [rsp+0x18]
   24b46:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24b4c:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24b52:	mov    QWORD PTR [rsp+0x98],rax
   24b5a:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24b63:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   24b6c:	mov    QWORD PTR [rsp+0xc0],r15
   24b74:	mov    QWORD PTR [rsp+0xc8],r12
   24b7c:	lea    rax,[rsp+0x98]
   24b84:	mov    rsi,QWORD PTR [rsp+0xb8]
   24b8c:	test   rsi,rsi
   24b8f:	je     24ba7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x607>
   24b91:	mov    rdi,QWORD PTR [rsp+0x98]
   24b99:	mov    rdx,QWORD PTR [rsp+0xb0]
   24ba1:	call   QWORD PTR [rip+0x65601]        # 8a1a8 <_DYNAMIC+0x250>
   24ba7:	lea    rdi,[rsp+0x88]
   24baf:	call   QWORD PTR [rip+0x655db]        # 8a190 <_DYNAMIC+0x238>
   24bb5:	mov    r15,rax
   24bb8:	mov    ebx,edx
   24bba:	mov    r12,QWORD PTR [rsp+0x10]
   24bbf:	cmp    r12,QWORD PTR [rsp]
   24bc3:	jne    24bcd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x62d>
   24bc5:	mov    rdi,rsp
   24bc8:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24bcd:	movq   xmm0,r15
   24bd2:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe2b56]        # 7730 <__abi_tag+0x7434>
   24bda:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe2aee]        # 76d0 <__abi_tag+0x73d4>
   24be2:	movapd xmm1,xmm0
   24be6:	unpckhpd xmm1,xmm0
   24bea:	cvtsi2sd xmm2,ebx
   24bee:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe2d9a]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   24bf6:	addsd  xmm1,xmm0
   24bfa:	addsd  xmm2,xmm1
   24bfe:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe2df2]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   24c06:	mov    rax,QWORD PTR [rsp+0x8]
   24c0b:	movsd  QWORD PTR [rax+r12*8],xmm2
   24c11:	inc    r12
   24c14:	mov    QWORD PTR [rsp+0x10],r12
   24c19:	call   QWORD PTR [rip+0x65569]        # 8a188 <_DYNAMIC+0x230>
   24c1f:	mov    QWORD PTR [rsp+0x88],rax
   24c27:	mov    DWORD PTR [rsp+0x90],edx
   24c2e:	mov    rax,QWORD PTR [r14+0x20]
   24c32:	mov    QWORD PTR [rsp+0x70],rax
   24c37:	movups xmm0,XMMWORD PTR [r14]
   24c3b:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24c41:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24c47:	movaps XMMWORD PTR [rsp+0x50],xmm0
   24c4c:	lea    rax,[rsp+0x50]
   24c51:	mov    rax,QWORD PTR [rsp+0x50]
   24c56:	mov    r14,QWORD PTR [rsp+0x58]
   24c5b:	mov    rcx,QWORD PTR [rsp+0x70]
   24c60:	mov    QWORD PTR [rsp+0xd0],rax
   24c68:	mov    QWORD PTR [rsp+0xd8],r14
   24c70:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24c76:	mov    r15,QWORD PTR [rsp+0x60]
   24c7b:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24c84:	mov    QWORD PTR [rsp+0xf0],rcx
   24c8c:	lea    rdi,[rsp+0x18]
   24c91:	lea    rcx,[rsp+0xd0]
   24c99:	mov    rsi,r14
   24c9c:	mov    rdx,r15
   24c9f:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   24ca4:	mov    rdi,QWORD PTR [rsp+0x40]
   24ca9:	mov    rsi,QWORD PTR [rsp+0x48]
   24cae:	cmp    rdi,r14
   24cb1:	jne    25117 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb77>
   24cb7:	cmp    rsi,r15
   24cba:	jne    25117 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xb77>
   24cc0:	mov    rax,QWORD PTR [rsp+0x18]
   24cc5:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24ccb:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24cd1:	mov    QWORD PTR [rsp+0x98],rax
   24cd9:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24ce2:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   24ceb:	mov    QWORD PTR [rsp+0xc0],r14
   24cf3:	mov    QWORD PTR [rsp+0xc8],r15
   24cfb:	lea    rax,[rsp+0x98]
   24d03:	mov    rsi,QWORD PTR [rsp+0xb8]
   24d0b:	test   rsi,rsi
   24d0e:	je     24d26 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x786>
   24d10:	mov    rdi,QWORD PTR [rsp+0x98]
   24d18:	mov    rdx,QWORD PTR [rsp+0xb0]
   24d20:	call   QWORD PTR [rip+0x65482]        # 8a1a8 <_DYNAMIC+0x250>
   24d26:	lea    rdi,[rsp+0x88]
   24d2e:	call   QWORD PTR [rip+0x6545c]        # 8a190 <_DYNAMIC+0x238>
   24d34:	mov    r14,rax
   24d37:	mov    ebx,edx
   24d39:	mov    rbp,QWORD PTR [rsp+0x10]
   24d3e:	cmp    rbp,QWORD PTR [rsp]
   24d42:	jne    24d4c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x7ac>
   24d44:	mov    rdi,rsp
   24d47:	call   2fac0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24d4c:	movq   xmm0,r14
   24d51:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe29d7]        # 7730 <__abi_tag+0x7434>
   24d59:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe296f]        # 76d0 <__abi_tag+0x73d4>
   24d61:	movapd xmm1,xmm0
   24d65:	unpckhpd xmm1,xmm0
   24d69:	addsd  xmm1,xmm0
   24d6d:	xorps  xmm0,xmm0
   24d70:	cvtsi2sd xmm0,ebx
   24d74:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe2c14]        # 7990 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x10>
   24d7c:	addsd  xmm0,xmm1
   24d80:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe2c70]        # 79f8 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477+0x78>
   24d88:	mov    rax,QWORD PTR [rsp+0x8]
   24d8d:	movsd  QWORD PTR [rax+rbp*8],xmm0
   24d92:	lea    r12,[rbp+0x1]
   24d96:	mov    QWORD PTR [rsp+0x10],r12
   24d9b:	lea    r13,[rbp*8+0x8]
   24da3:	mov    rax,r12
   24da6:	shr    rax,0x3d
   24daa:	setne  al
   24dad:	movabs rcx,0x7ffffffffffffff8
   24db7:	cmp    r13,rcx
   24dba:	seta   cl
   24dbd:	or     cl,al
   24dbf:	je     24dd5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x835>
   24dc1:	xor    r15d,r15d
   24dc4:	mov    rdi,r15
   24dc7:	mov    rsi,r13
   24dca:	call   QWORD PTR [rip+0x653e0]        # 8a1b0 <_DYNAMIC+0x258>
   24dd0:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   24dd5:	mov    rbx,QWORD PTR [rsp+0x8]
   24dda:	test   r13,r13
   24ddd:	je     24f73 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9d3>
   24de3:	call   QWORD PTR [rip+0x653af]        # 8a198 <_DYNAMIC+0x240>
   24de9:	mov    r15d,0x8
   24def:	mov    esi,0x8
   24df4:	mov    rdi,r13
   24df7:	call   QWORD PTR [rip+0x653a3]        # 8a1a0 <_DYNAMIC+0x248>
   24dfd:	test   rax,rax
   24e00:	je     24dc4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x824>
   24e02:	mov    r14,rax
   24e05:	mov    r15,r12
   24e08:	test   r12,r12
   24e0b:	je     24f85 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9e5>
   24e11:	mov    rdi,r14
   24e14:	mov    rsi,rbx
   24e17:	mov    rdx,r13
   24e1a:	call   QWORD PTR [rip+0x65398]        # 8a1b8 <memcpy@GLIBC_2.14>
   24e20:	lea    rax,[rsp+0x87]
   24e28:	mov    QWORD PTR [rsp+0x18],rax
   24e2d:	mov    esi,0x1
   24e32:	test   rbp,rbp
   24e35:	jne    24f8c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9ec>
   24e3b:	lea    rdx,[rip+0x61ede]        # 86d20 <__frame_dummy_init_array_entry+0x30>
   24e42:	mov    edi,0x2
   24e47:	call   QWORD PTR [rip+0x65373]        # 8a1c0 <_DYNAMIC+0x268>
   24e4d:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   24e52:	lea    r15,[rsp+0x18]
   24e57:	lea    r13,[rsp+0x108]
   24e5f:	mov    r12,QWORD PTR [rip+0x6532a]        # 8a190 <_DYNAMIC+0x238>
   24e66:	cmp    edx,0xee6b280
   24e6c:	jae    245e8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x48>
   24e72:	mov    rax,QWORD PTR [r14+0x20]
   24e76:	mov    QWORD PTR [rsp+0xf0],rax
   24e7e:	movups xmm0,XMMWORD PTR [r14]
   24e82:	movups xmm1,XMMWORD PTR [r14+0x10]
   24e87:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   24e8f:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   24e97:	lea    rax,[rsp+0xd0]
   24e9f:	mov    rax,QWORD PTR [rsp+0xd0]
   24ea7:	mov    rbp,QWORD PTR [rsp+0xd8]
   24eaf:	mov    rcx,QWORD PTR [rsp+0xf0]
   24eb7:	mov    QWORD PTR [rsp+0x98],rax
   24ebf:	mov    QWORD PTR [rsp+0xa0],rbp
   24ec7:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   24ecf:	mov    rbx,QWORD PTR [rsp+0xe0]
   24ed7:	movups XMMWORD PTR [rsp+0xa8],xmm0
   24edf:	mov    QWORD PTR [rsp+0xb8],rcx
   24ee7:	mov    rdi,r15
   24eea:	mov    rsi,rbp
   24eed:	mov    rdx,rbx
   24ef0:	lea    rcx,[rsp+0x98]
   24ef8:	call   2e4b0 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwndNtNtNtBa_5utils5bound3DimB19_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impdiiE0ECskuD9mmv22aj_16owned_copy_probe>
   24efd:	mov    rdi,QWORD PTR [rsp+0x40]
   24f02:	mov    rsi,QWORD PTR [rsp+0x48]
   24f07:	cmp    rdi,rbp
   24f0a:	jne    25156 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbb6>
   24f10:	cmp    rsi,rbx
   24f13:	jne    25156 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbb6>
   24f19:	mov    rax,QWORD PTR [rsp+0x18]
   24f1e:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24f24:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24f2a:	mov    QWORD PTR [rsp+0x18],rax
   24f2f:	movupd XMMWORD PTR [rsp+0x20],xmm0
   24f35:	movupd XMMWORD PTR [rsp+0x30],xmm1
   24f3b:	mov    QWORD PTR [rsp+0x40],rbp
   24f40:	mov    QWORD PTR [rsp+0x48],rbx
   24f45:	mov    rsi,QWORD PTR [rsp+0x38]
   24f4a:	test   rsi,rsi
   24f4d:	je     24f5f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x9bf>
   24f4f:	mov    rdi,QWORD PTR [rsp+0x18]
   24f54:	mov    rdx,QWORD PTR [rsp+0x30]
   24f59:	call   QWORD PTR [rip+0x65249]        # 8a1a8 <_DYNAMIC+0x250>
   24f5f:	mov    rdi,r13
   24f62:	call   r12
   24f65:	test   rax,rax
   24f68:	je     24e66 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x8c6>
   24f6e:	jmp    245e8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x48>
   24f73:	mov    r14d,0x8
   24f79:	xor    r15d,r15d
   24f7c:	test   r12,r12
   24f7f:	jne    24e11 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x871>
   24f85:	xor    esi,esi
   24f87:	jmp    24e3b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x89b>
   24f8c:	cmp    r12,0x15
   24f90:	jae    25196 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf6>
   24f96:	lea    rcx,[rsp+0x18]
   24f9b:	mov    edx,0x1
   24fa0:	mov    rdi,r14
   24fa3:	mov    rsi,r12
   24fa6:	call   34840 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   24fab:	cmp    r12,0x3
   24faf:	jb     251ab <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc0b>
   24fb5:	movsd  xmm0,QWORD PTR [r14+0x10]
   24fbb:	mov    rax,QWORD PTR [rsp+0x10]
   24fc0:	mov    rbx,QWORD PTR [rsp+0x100]
   24fc8:	mov    QWORD PTR [rbx+0x18],rax
   24fcc:	movups xmm1,XMMWORD PTR [rsp]
   24fd0:	movups XMMWORD PTR [rbx+0x8],xmm1
   24fd4:	movsd  QWORD PTR [rbx],xmm0
   24fd8:	shl    r15,0x3
   24fdc:	mov    edx,0x8
   24fe1:	mov    rdi,r14
   24fe4:	mov    rsi,r15
   24fe7:	call   QWORD PTR [rip+0x651bb]        # 8a1a8 <_DYNAMIC+0x250>
   24fed:	mov    rax,rbx
   24ff0:	add    rsp,0x118
   24ff7:	pop    rbx
   24ff8:	pop    r12
   24ffa:	pop    r13
   24ffc:	pop    r14
   24ffe:	pop    r15
   25000:	pop    rbp
   25001:	ret
   25002:	mov    edi,0x8
   25007:	mov    esi,0x28
   2500c:	call   QWORD PTR [rip+0x6519e]        # 8a1b0 <_DYNAMIC+0x258>
   25012:	lea    rax,[rip+0x61edf]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   25019:	lea    r10,[rip+0xfffffffffffe2960]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   25020:	lea    r11,[rip+0x62129]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   25027:	lea    rbx,[rip+0x621aa]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2502e:	mov    r8d,0x1
   25034:	mov    r9d,0x1
   2503a:	mov    rdx,r15
   2503d:	mov    rcx,r12
   25040:	push   rax
   25041:	push   r10
   25043:	push   r11
   25045:	push   rbx
   25046:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2504b:	add    rsp,0x20
   2504f:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   25054:	lea    rax,[rip+0x61e9d]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2505b:	lea    r10,[rip+0xfffffffffffe291e]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   25062:	lea    r11,[rip+0x620e7]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   25069:	lea    rbx,[rip+0x62168]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   25070:	mov    r8d,0x1
   25076:	mov    r9d,0x1
   2507c:	mov    rdx,r15
   2507f:	mov    rcx,r12
   25082:	push   rax
   25083:	push   r10
   25085:	push   r11
   25087:	push   rbx
   25088:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2508d:	add    rsp,0x20
   25091:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   25096:	lea    rax,[rip+0x61e5b]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2509d:	lea    r10,[rip+0xfffffffffffe28dc]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   250a4:	lea    r11,[rip+0x620a5]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   250ab:	lea    rbx,[rip+0x62126]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   250b2:	mov    r8d,0x1
   250b8:	mov    r9d,0x1
   250be:	mov    rdx,r15
   250c1:	mov    rcx,r12
   250c4:	push   rax
   250c5:	push   r10
   250c7:	push   r11
   250c9:	push   rbx
   250ca:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   250cf:	add    rsp,0x20
   250d3:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   250d8:	lea    rax,[rip+0x61e19]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   250df:	lea    r10,[rip+0xfffffffffffe289a]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   250e6:	lea    r11,[rip+0x62063]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   250ed:	lea    rbx,[rip+0x620e4]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   250f4:	mov    r8d,0x1
   250fa:	mov    r9d,0x1
   25100:	mov    rdx,r15
   25103:	mov    rcx,r12
   25106:	push   rax
   25107:	push   r10
   25109:	push   r11
   2510b:	push   rbx
   2510c:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   25111:	add    rsp,0x20
   25115:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   25117:	lea    rax,[rip+0x61dda]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2511e:	lea    r10,[rip+0xfffffffffffe285b]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   25125:	lea    r11,[rip+0x62024]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2512c:	lea    rbx,[rip+0x620a5]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   25133:	mov    r8d,0x1
   25139:	mov    r9d,0x1
   2513f:	mov    rdx,r14
   25142:	mov    rcx,r15
   25145:	push   rax
   25146:	push   r10
   25148:	push   r11
   2514a:	push   rbx
   2514b:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   25150:	add    rsp,0x20
   25154:	jmp    25194 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xbf4>
   25156:	lea    rax,[rip+0x61d9b]        # 86ef8 <anon.20f76fd8bf6088ba3a74a861e494b10f.6.llvm.12874841635327807522+0x1c0>
   2515d:	lea    r10,[rip+0xfffffffffffe281c]        # 7980 <anon.35e10629198c9cd65c5c79e980eb2fa9.18.llvm.12820947064454896477>
   25164:	lea    r11,[rip+0x61fe5]        # 87150 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   2516b:	lea    r14,[rip+0x62066]        # 871d8 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   25172:	mov    r8d,0x1
   25178:	mov    r9d,0x1
   2517e:	mov    rdx,rbp
   25181:	mov    rcx,rbx
   25184:	push   rax
   25185:	push   r10
   25187:	push   r11
   25189:	push   r14
   2518b:	call   2db50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   25190:	add    rsp,0x20
   25194:	ud2
   25196:	lea    rdx,[rsp+0x18]
   2519b:	mov    rdi,r14
   2519e:	mov    rsi,r12
   251a1:	call   34170 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   251a6:	jmp    24fb5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xa15>
   251ab:	mov    esi,0x2
   251b0:	jmp    24e3b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0x89b>
   251b5:	mov    rbx,rax
   251b8:	mov    rsi,QWORD PTR [rsp+0x38]
   251bd:	test   rsi,rsi
   251c0:	je     25236 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc96>
   251c2:	mov    rdi,QWORD PTR [rsp+0x18]
   251c7:	mov    rdx,QWORD PTR [rsp+0x30]
   251cc:	jmp    25230 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc90>
   251ce:	jmp    251d6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   251d0:	jmp    251d6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   251d2:	jmp    251d6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   251d4:	jmp    251d6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc36>
   251d6:	mov    rbx,rax
   251d9:	mov    rsi,QWORD PTR [rsp+0x38]
   251de:	test   rsi,rsi
   251e1:	je     25219 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   251e3:	mov    rdi,QWORD PTR [rsp+0x18]
   251e8:	mov    rdx,QWORD PTR [rsp+0x30]
   251ed:	call   QWORD PTR [rip+0x64fb5]        # 8a1a8 <_DYNAMIC+0x250>
   251f3:	jmp    25219 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   251f5:	jmp    25216 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc76>
   251f7:	mov    rbx,rax
   251fa:	test   r15,r15
   251fd:	je     25219 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   251ff:	shl    r15,0x3
   25203:	mov    edx,0x8
   25208:	mov    rdi,r14
   2520b:	mov    rsi,r15
   2520e:	call   QWORD PTR [rip+0x64f94]        # 8a1a8 <_DYNAMIC+0x250>
   25214:	jmp    25219 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc79>
   25216:	mov    rbx,rax
   25219:	mov    rsi,QWORD PTR [rsp]
   2521d:	test   rsi,rsi
   25220:	je     25236 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwndEENCNCNvB2_4main0s1_0EB2_+0xc96>
   25222:	mov    rdi,QWORD PTR [rsp+0x8]
   25227:	shl    rsi,0x3
   2522b:	mov    edx,0x8
   25230:	call   QWORD PTR [rip+0x64f72]        # 8a1a8 <_DYNAMIC+0x250>
   25236:	mov    rdi,rbx
   25239:	call   85c90 <_Unwind_Resume@plt>
