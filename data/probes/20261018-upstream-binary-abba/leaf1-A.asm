
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/2240b076a030-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000209420 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench>:
  209420:	push   rbp
  209421:	push   r15
  209423:	push   r14
  209425:	push   r13
  209427:	push   r12
  209429:	push   rbx
  20942a:	sub    rsp,0x118
  209431:	mov    rax,QWORD PTR [rdi+0x8]
  209435:	test   rax,rax
  209438:	je     209525 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20943e:	mov    rcx,QWORD PTR [rdi+0x10]
  209442:	cmp    rax,rcx
  209445:	mov    rdx,rcx
  209448:	cmovb  rdx,rax
  20944c:	mov    QWORD PTR [rsp+0xd0],rdx
  209454:	test   rcx,rcx
  209457:	je     209525 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20945d:	mov    QWORD PTR [rsp+0xb8],rax
  209465:	mov    r9,QWORD PTR [rdi+0x40]
  209469:	mov    rax,QWORD PTR [rdi+0x48]
  20946d:	mov    QWORD PTR [rsp+0x80],rax
  209475:	mov    rsi,QWORD PTR [rdi+0x50]
  209479:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  20947e:	vmovsd xmm4,QWORD PTR [rdi+0x38]
  209483:	mov    r10,QWORD PTR [rdi+0x20]
  209487:	mov    rax,QWORD PTR [rdi+0x28]
  20948b:	mov    QWORD PTR [rsp+0x88],rax
  209493:	movzx  eax,BYTE PTR [rdi+0x59]
  209497:	mov    BYTE PTR [rsp+0x7],al
  20949b:	movzx  edx,BYTE PTR [rdi+0x58]
  20949f:	mov    rax,QWORD PTR [rdi]
  2094a2:	mov    rdi,QWORD PTR [rdi+0x18]
  2094a6:	vmovddup xmm0,QWORD PTR [rip+0xffffffffffe36672]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  2094ae:	vxorpd xmm5,xmm3,xmm0
  2094b2:	vxorpd xmm6,xmm4,xmm0
  2094b6:	mov    QWORD PTR [rsp+0xf8],rsi
  2094be:	lea    rsi,[rsi*8+0x0]
  2094c6:	mov    QWORD PTR [rsp+0x48],rsi
  2094cb:	mov    QWORD PTR [rsp+0x100],rdi
  2094d3:	lea    r8,[rdi*8+0x0]
  2094db:	mov    QWORD PTR [rsp+0x40],rax
  2094e0:	add    rax,0x60
  2094e4:	mov    QWORD PTR [rsp+0xc0],rax
  2094ec:	vmovddup xmm7,QWORD PTR [rip+0xffffffffffe3662c]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  2094f4:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe36564]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  2094fc:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe365c4]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  209504:	vxorpd xmm10,xmm10,xmm10
  209509:	xor    r14d,r14d
  20950c:	xor    edi,edi
  20950e:	mov    QWORD PTR [rsp+0x18],r9
  209513:	mov    QWORD PTR [rsp+0xc8],rcx
  20951b:	mov    QWORD PTR [rsp+0x90],r10
  209523:	jmp    209562 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x142>
  209525:	xor    r14d,r14d
  209528:	xor    eax,eax
  20952a:	jmp    209cf0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20952f:	nop
  209530:	mov    QWORD PTR [rsp+0x50],0x0
  209539:	mov    r14,QWORD PTR [rsp+0xd8]
  209541:	add    r14,QWORD PTR [rsp+0x50]
  209546:	mov    rdi,rsi
  209549:	mov    rcx,QWORD PTR [rsp+0xc8]
  209551:	cmp    rsi,rcx
  209554:	mov    r10,QWORD PTR [rsp+0x90]
  20955c:	jae    209d08 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8e8>
  209562:	mov    rsi,rcx
  209565:	sub    rsi,rdi
  209568:	cmp    rsi,0x10
  20956c:	mov    eax,0x10
  209571:	cmovae rsi,rax
  209575:	mov    QWORD PTR [rsp+0x8],rsi
  20957a:	add    rsi,rdi
  20957d:	cmp    rsi,QWORD PTR [rsp+0xd0]
  209585:	ja     209d8e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x96e>
  20958b:	cmp    rsi,QWORD PTR [rsp+0x80]
  209593:	ja     209dc3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9a3>
  209599:	cmp    rsi,QWORD PTR [rsp+0x88]
  2095a1:	seta   al
  2095a4:	test   r10,r10
  2095a7:	jne    2095ab <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x18b>
  2095a9:	xor    eax,eax
  2095ab:	test   al,al
  2095ad:	jne    209d28 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x908>
  2095b3:	test   rdi,rdi
  2095b6:	js     209dfc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  2095bc:	cmp    rdi,rsi
  2095bf:	ja     209dfc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  2095c5:	mov    QWORD PTR [rsp+0xd8],r14
  2095cd:	test   rsi,rsi
  2095d0:	je     209530 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x110>
  2095d6:	mov    rax,QWORD PTR [rsp+0x8]
  2095db:	lea    r10,[rax-0x1]
  2095df:	mov    r12,r10
  2095e2:	shr    r12,0x2
  2095e6:	mov    eax,r10d
  2095e9:	and    eax,0x3
  2095ec:	shl    eax,0x9
  2095ef:	mov    rcx,QWORD PTR [rip+0x340bca]        # 54a1c0 <_DYNAMIC+0x3e8>
  2095f6:	mov    rbp,QWORD PTR [rcx+rax*1+0x200]
  2095fe:	mov    r15,QWORD PTR [rcx+rax*1+0x208]
  209606:	mov    QWORD PTR [rsp+0xf0],r10
  20960e:	and    r10,0xfffffffffffffffc
  209612:	mov    QWORD PTR [rsp+0x28],r10
  209617:	xor    eax,eax
  209619:	test   r12,r12
  20961c:	setne  al
  20961f:	lea    rcx,[rax+0x1]
  209623:	cmp    r12,rax
  209626:	mov    QWORD PTR [rsp+0x98],rax
  20962e:	cmovbe rcx,rax
  209632:	lea    eax,[rcx*4+0x0]
  209639:	mov    QWORD PTR [rsp+0xa0],rax
  209641:	mov    ebx,r12d
  209644:	and    ebx,0x3
  209647:	mov    r13,r12
  20964a:	and    r13,0xfffffffffffffffc
  20964e:	mov    r11,r12
  209651:	shl    r11,0x5
  209655:	mov    QWORD PTR [rsp+0x108],rcx
  20965d:	shl    ecx,0x5
  209660:	mov    QWORD PTR [rsp+0x110],rcx
  209668:	mov    rax,QWORD PTR [rsp+0xc0]
  209670:	lea    r10,[rax+rdi*8]
  209674:	mov    rax,QWORD PTR [rsp+0x40]
  209679:	lea    rcx,[rax+rdi*8]
  20967d:	mov    QWORD PTR [rsp+0xa8],rcx
  209685:	mov    QWORD PTR [rsp+0xe0],rbx
  20968d:	shl    ebx,0x5
  209690:	mov    QWORD PTR [rsp+0x70],rax
  209695:	mov    QWORD PTR [rsp+0x68],0x0
  20969e:	mov    QWORD PTR [rsp+0x50],0x0
  2096a7:	xor    r14d,r14d
  2096aa:	mov    QWORD PTR [rsp+0x60],rdi
  2096af:	mov    QWORD PTR [rsp+0x58],r12
  2096b4:	mov    QWORD PTR [rsp+0x20],r15
  2096b9:	mov    QWORD PTR [rsp+0x38],r13
  2096be:	mov    QWORD PTR [rsp+0xe8],rsi
  2096c6:	jmp    209718 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2f8>
  2096c8:	nop    DWORD PTR [rax+rax*1+0x0]
  2096d0:	inc    r14
  2096d3:	mov    rax,QWORD PTR [rsp+0x28]
  2096d8:	mov    rcx,QWORD PTR [rsp+0x78]
  2096dd:	lea    rax,[rcx+rax*8]
  2096e1:	lea    rcx,[rip+0x2]        # 2096ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2ca>
  2096e8:	jmp    rbp
  2096ea:	vmulpd ymm0,ymm2,ymm0
  2096ee:	lea    rcx,[rip+0x3]        # 2096f8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2d8>
  2096f5:	jmp    r15
  2096f8:	add    QWORD PTR [rsp+0x68],0x8
  2096fe:	add    QWORD PTR [rsp+0x70],0x8
  209704:	add    r10,r8
  209707:	add    QWORD PTR [rsp+0xa8],r8
  20970f:	cmp    r14,rsi
  209712:	je     209539 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x119>
  209718:	test   r14,r14
  20971b:	mov    r15,rdi
  20971e:	cmove  r15,r14
  209722:	mov    rax,r14
  209725:	imul   rax,QWORD PTR [rsp+0x100]
  20972e:	mov    rcx,QWORD PTR [rsp+0x40]
  209733:	lea    r13,[rcx+r15*8]
  209737:	lea    rax,[rcx+rax*8]
  20973b:	mov    QWORD PTR [rsp+0xb0],rax
  209743:	lea    rcx,[rax+rdi*8]
  209747:	cmp    QWORD PTR [rsp+0x108],r12
  20974f:	mov    QWORD PTR [rsp+0x30],r10
  209754:	mov    QWORD PTR [rsp+0x78],rcx
  209759:	jae    209820 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x400>
  20975f:	cmp    r12,QWORD PTR [rsp+0x98]
  209767:	jbe    209d0c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8ec>
  20976d:	vmovupd ymm11,YMMWORD PTR [rcx]
  209771:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  209776:	mov    rax,QWORD PTR [rsp+0xa0]
  20977e:	vmovupd ymm13,YMMWORD PTR [rcx+rax*8]
  209783:	mov    rax,QWORD PTR [rsp+0x28]
  209788:	lea    rax,[rcx+rax*8]
  20978c:	mov    rsi,rax
  20978f:	lea    rcx,[rip+0x2]        # 209798 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x378>
  209796:	jmp    rbp
  209798:	vmovapd ymm2,ymm0
  20979c:	test   r14,r14
  20979f:	je     209972 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x552>
  2097a5:	mov    rdi,r14
  2097a8:	mov    r12,QWORD PTR [rsp+0x70]
  2097ad:	mov    r10,r9
  2097b0:	mov    r15,QWORD PTR [rsp+0x20]
  2097b5:	jmp    20980c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3ec>
  2097b7:	nop    WORD PTR [rax+rax*1+0x0]
  2097c0:	vmulsd xmm0,xmm0,QWORD PTR [r12]
  2097c6:	vbroadcastsd ymm14,xmm0
  2097cb:	lea    rax,[r11+r13*1]
  2097cf:	vfmadd231pd ymm11,ymm14,YMMWORD PTR [r13+0x0]
  2097d5:	vfmadd231pd ymm12,ymm14,YMMWORD PTR [r13+0x20]
  2097db:	mov    rcx,QWORD PTR [rsp+0x110]
  2097e3:	vfmadd231pd ymm13,ymm14,YMMWORD PTR [r13+rcx*1+0x0]
  2097ea:	lea    rcx,[rip+0x2]        # 2097f3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3d3>
  2097f1:	jmp    rbp
  2097f3:	vfmadd231pd ymm2,ymm14,ymm0
  2097f8:	add    r10,QWORD PTR [rsp+0x48]
  2097fd:	add    r12,r8
  209800:	add    r13,r8
  209803:	dec    rdi
  209806:	je     2098d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4b0>
  20980c:	vmovapd xmm0,xmm8
  209810:	test   dl,dl
  209812:	jne    2097c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  209814:	vmovsd xmm0,QWORD PTR [r10]
  209819:	vxorpd xmm0,xmm0,xmm7
  20981d:	jmp    2097c0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20981f:	nop
  209820:	test   r12,r12
  209823:	je     2098e4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4c4>
  209829:	vmovupd ymm11,YMMWORD PTR [rcx]
  20982d:	cmp    r12,QWORD PTR [rsp+0x98]
  209835:	jbe    2099b5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x595>
  20983b:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  209840:	mov    rax,QWORD PTR [rsp+0x28]
  209845:	lea    rax,[rcx+rax*8]
  209849:	lea    rcx,[rip+0x2]        # 209852 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x432>
  209850:	jmp    rbp
  209852:	vmovapd ymm2,ymm0
  209856:	test   r14,r14
  209859:	je     209a95 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x675>
  20985f:	mov    QWORD PTR [rsp+0x10],rax
  209864:	lea    r10,[r11+r15*8]
  209868:	shl    r15,0x3
  20986c:	mov    r12,r14
  20986f:	mov    r13,QWORD PTR [rsp+0x40]
  209874:	mov    rsi,QWORD PTR [rsp+0x68]
  209879:	jmp    2098bd <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x49d>
  20987b:	nop    DWORD PTR [rax+rax*1+0x0]
  209880:	vmulsd xmm0,xmm0,QWORD PTR [r13+rsi*1+0x0]
  209887:	vbroadcastsd ymm13,xmm0
  20988c:	vfmadd231pd ymm11,ymm13,YMMWORD PTR [r13+r15*1+0x0]
  209893:	vfmadd231pd ymm12,ymm13,YMMWORD PTR [r13+r15*1+0x20]
  20989a:	lea    rax,[r10+r13*1]
  20989e:	lea    rcx,[rip+0x2]        # 2098a7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x487>
  2098a5:	jmp    rbp
  2098a7:	vfmadd231pd ymm2,ymm13,ymm0
  2098ac:	add    r9,QWORD PTR [rsp+0x48]
  2098b1:	add    r13,r8
  2098b4:	dec    r12
  2098b7:	je     209a73 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x653>
  2098bd:	vmovapd xmm0,xmm8
  2098c1:	test   dl,dl
  2098c3:	jne    209880 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  2098c5:	vmovsd xmm0,QWORD PTR [r9]
  2098ca:	vxorpd xmm0,xmm0,xmm7
  2098ce:	jmp    209880 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  2098d0:	mov    rdi,QWORD PTR [rsp+0x60]
  2098d5:	mov    r12,QWORD PTR [rsp+0x58]
  2098da:	mov    r10,QWORD PTR [rsp+0x30]
  2098df:	jmp    209977 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x557>
  2098e4:	mov    rax,QWORD PTR [rsp+0x28]
  2098e9:	lea    rax,[rcx+rax*8]
  2098ed:	mov    QWORD PTR [rsp+0x10],rax
  2098f2:	lea    rcx,[rip+0x2]        # 2098fb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4db>
  2098f9:	jmp    rbp
  2098fb:	vmovapd ymm2,ymm0
  2098ff:	test   r14,r14
  209902:	mov    r13,QWORD PTR [rsp+0x38]
  209907:	je     209a56 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x636>
  20990d:	lea    rdi,[r11+r15*8]
  209911:	mov    r12,r9
  209914:	mov    r9,r14
  209917:	mov    r10,QWORD PTR [rsp+0x40]
  20991c:	mov    rsi,QWORD PTR [rsp+0x68]
  209921:	jmp    20995e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x53e>
  209923:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  209930:	vmulsd xmm0,xmm0,QWORD PTR [r10+rsi*1]
  209936:	vbroadcastsd ymm11,xmm0
  20993b:	lea    rax,[r10+rdi*1]
  20993f:	lea    rcx,[rip+0x2]        # 209948 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x528>
  209946:	jmp    rbp
  209948:	vfmadd231pd ymm2,ymm11,ymm0
  20994d:	add    r12,QWORD PTR [rsp+0x48]
  209952:	add    r10,r8
  209955:	dec    r9
  209958:	je     209a39 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x619>
  20995e:	vmovapd xmm0,xmm8
  209962:	test   dl,dl
  209964:	jne    209930 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  209966:	vmovsd xmm0,QWORD PTR [r12]
  20996c:	vxorpd xmm0,xmm0,xmm7
  209970:	jmp    209930 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  209972:	mov    r15,QWORD PTR [rsp+0x20]
  209977:	mov    rcx,QWORD PTR [rsp+0x78]
  20997c:	vmovupd YMMWORD PTR [rcx],ymm11
  209980:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209985:	mov    rax,QWORD PTR [rsp+0xa0]
  20998d:	vmovupd YMMWORD PTR [rcx+rax*8],ymm13
  209992:	mov    rax,rsi
  209995:	vmovapd ymm0,ymm2
  209999:	lea    rcx,[rip+0x3]        # 2099a3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x583>
  2099a0:	jmp    r15
  2099a3:	mov    r13,QWORD PTR [rsp+0x38]
  2099a8:	mov    rsi,QWORD PTR [rsp+0xe8]
  2099b0:	jmp    209af3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  2099b5:	mov    rax,QWORD PTR [rsp+0x28]
  2099ba:	lea    rax,[rcx+rax*8]
  2099be:	mov    QWORD PTR [rsp+0x10],rax
  2099c3:	lea    rcx,[rip+0x2]        # 2099cc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ac>
  2099ca:	jmp    rbp
  2099cc:	vmovapd ymm2,ymm0
  2099d0:	test   r14,r14
  2099d3:	mov    r15,QWORD PTR [rsp+0x20]
  2099d8:	je     209acb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ab>
  2099de:	mov    rsi,r14
  2099e1:	mov    r10,r9
  2099e4:	mov    r9,QWORD PTR [rsp+0x70]
  2099e9:	jmp    209a26 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x606>
  2099eb:	nop    DWORD PTR [rax+rax*1+0x0]
  2099f0:	vmulsd xmm0,xmm0,QWORD PTR [r9]
  2099f5:	vbroadcastsd ymm12,xmm0
  2099fa:	lea    rax,[r11+r13*1]
  2099fe:	vfmadd231pd ymm11,ymm12,YMMWORD PTR [r13+0x0]
  209a04:	lea    rcx,[rip+0x2]        # 209a0d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ed>
  209a0b:	jmp    rbp
  209a0d:	vfmadd231pd ymm2,ymm12,ymm0
  209a12:	add    r10,QWORD PTR [rsp+0x48]
  209a17:	add    r9,r8
  209a1a:	add    r13,r8
  209a1d:	dec    rsi
  209a20:	je     209ab8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x698>
  209a26:	vmovapd xmm0,xmm8
  209a2a:	test   dl,dl
  209a2c:	jne    2099f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  209a2e:	vmovsd xmm0,QWORD PTR [r10]
  209a33:	vxorpd xmm0,xmm0,xmm7
  209a37:	jmp    2099f0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  209a39:	mov    rdi,QWORD PTR [rsp+0x60]
  209a3e:	mov    rax,QWORD PTR [rsp+0x8]
  209a43:	lea    rsi,[rax+rdi*1]
  209a47:	mov    r9,QWORD PTR [rsp+0x18]
  209a4c:	mov    r12,QWORD PTR [rsp+0x58]
  209a51:	mov    r10,QWORD PTR [rsp+0x30]
  209a56:	mov    rax,QWORD PTR [rsp+0x10]
  209a5b:	vmovapd ymm0,ymm2
  209a5f:	mov    r15,QWORD PTR [rsp+0x20]
  209a64:	lea    rcx,[rip+0x3]        # 209a6e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x64e>
  209a6b:	jmp    r15
  209a6e:	jmp    209af3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  209a73:	mov    rdi,QWORD PTR [rsp+0x60]
  209a78:	mov    rax,QWORD PTR [rsp+0x8]
  209a7d:	lea    rsi,[rax+rdi*1]
  209a81:	mov    r9,QWORD PTR [rsp+0x18]
  209a86:	mov    r12,QWORD PTR [rsp+0x58]
  209a8b:	mov    r10,QWORD PTR [rsp+0x30]
  209a90:	mov    rax,QWORD PTR [rsp+0x10]
  209a95:	mov    rcx,QWORD PTR [rsp+0x78]
  209a9a:	vmovupd YMMWORD PTR [rcx],ymm11
  209a9e:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209aa3:	vmovapd ymm0,ymm2
  209aa7:	mov    r15,QWORD PTR [rsp+0x20]
  209aac:	lea    rcx,[rip+0x3]        # 209ab6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x696>
  209ab3:	jmp    r15
  209ab6:	jmp    209aee <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  209ab8:	mov    rax,QWORD PTR [rsp+0x8]
  209abd:	lea    rsi,[rax+rdi*1]
  209ac1:	mov    r9,QWORD PTR [rsp+0x18]
  209ac6:	mov    r10,QWORD PTR [rsp+0x30]
  209acb:	mov    rax,QWORD PTR [rsp+0xb0]
  209ad3:	lea    rax,[rax+rdi*8]
  209ad7:	vmovupd YMMWORD PTR [rax],ymm11
  209adb:	mov    rax,QWORD PTR [rsp+0x10]
  209ae0:	vmovapd ymm0,ymm2
  209ae4:	lea    rcx,[rip+0x3]        # 209aee <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  209aeb:	jmp    r15
  209aee:	mov    r13,QWORD PTR [rsp+0x38]
  209af3:	mov    rcx,r14
  209af6:	imul   rcx,QWORD PTR [rsp+0xf8]
  209aff:	mov    rax,r14
  209b02:	sub    rax,rdi
  209b05:	jae    209b20 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x700>
  209b07:	vmovsd xmm0,QWORD PTR [r9+rcx*8]
  209b0d:	jmp    209ba6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x786>
  209b12:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  209b20:	cmp    rax,QWORD PTR [rsp+0x8]
  209b25:	jae    209d42 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x922>
  209b2b:	mov    rax,QWORD PTR [rsp+0xb0]
  209b33:	vmovsd xmm0,QWORD PTR [rax+r14*8]
  209b39:	cmp    BYTE PTR [rsp+0x7],0x0
  209b3e:	je     209b57 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x737>
  209b40:	test   dl,dl
  209b42:	je     209c48 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x828>
  209b48:	vucomisd xmm3,xmm0
  209b4c:	jb     209b5b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x73b>
  209b4e:	inc    QWORD PTR [rsp+0x50]
  209b53:	vmovapd xmm0,xmm4
  209b57:	test   dl,dl
  209b59:	je     209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209b5b:	vucomisd xmm0,xmm10
  209b60:	jbe    209ce5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8c5>
  209b66:	vsqrtsd xmm0,xmm0,xmm0
  209b6a:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  209b70:	vmovq  rax,xmm0
  209b75:	mov    cl,0x3f
  209b77:	bzhi   rax,rax,rcx
  209b7c:	movabs rcx,0x7ff0000000000000
  209b86:	cmp    rax,rcx
  209b89:	setg   cl
  209b8c:	sete   r10b
  209b90:	test   rax,rax
  209b93:	sete   al
  209b96:	or     al,r10b
  209b99:	or     al,cl
  209b9b:	mov    r10,QWORD PTR [rsp+0x30]
  209ba0:	jne    209ceb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8cb>
  209ba6:	vdivsd xmm0,xmm9,xmm0
  209baa:	vbroadcastsd ymm2,xmm0
  209baf:	test   r12,r12
  209bb2:	je     2096d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209bb8:	cmp    QWORD PTR [rsp+0xf0],0x10
  209bc1:	jae    209bd0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7b0>
  209bc3:	xor    eax,eax
  209bc5:	jmp    209c22 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x802>
  209bc7:	nop    WORD PTR [rax+rax*1+0x0]
  209bd0:	mov    rcx,r10
  209bd3:	xor    eax,eax
  209bd5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  209be0:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  209be5:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  209bea:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  209bef:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  209bf4:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  209bf9:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  209bfe:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  209c02:	add    rax,0x4
  209c06:	vmovupd YMMWORD PTR [rcx],ymm0
  209c0a:	sub    rcx,0xffffffffffffff80
  209c0e:	cmp    r13,rax
  209c11:	jne    209be0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7c0>
  209c13:	cmp    QWORD PTR [rsp+0xe0],0x0
  209c1c:	je     2096d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209c22:	shl    rax,0x5
  209c26:	add    rax,QWORD PTR [rsp+0xa8]
  209c2e:	xor    ecx,ecx
  209c30:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  209c35:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  209c3a:	add    rcx,0x20
  209c3e:	cmp    rbx,rcx
  209c41:	jne    209c30 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x810>
  209c43:	jmp    2096d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209c48:	mov    rax,QWORD PTR [rsp+0x90]
  209c50:	test   rax,rax
  209c53:	je     209c95 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x875>
  209c55:	movzx  r9d,BYTE PTR [rax+r14*1]
  209c5a:	vucomisd xmm3,xmm0
  209c5e:	setae  al
  209c61:	vucomisd xmm0,xmm5
  209c65:	setae  r10b
  209c69:	cmp    r9d,0xff
  209c70:	je     209cc4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8a4>
  209c72:	cmp    r9d,0x1
  209c76:	mov    rsi,QWORD PTR [rsp+0x8]
  209c7b:	lea    rsi,[rsi+rdi*1]
  209c7f:	mov    r9,QWORD PTR [rsp+0x18]
  209c84:	jne    209ca4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x884>
  209c86:	vucomisd xmm3,xmm0
  209c8a:	jae    209b4e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x72e>
  209c90:	jmp    209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209c95:	vucomisd xmm3,xmm0
  209c99:	setae  al
  209c9c:	vucomisd xmm0,xmm5
  209ca0:	setae  r10b
  209ca4:	test   r10b,r10b
  209ca7:	je     209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cad:	test   al,al
  209caf:	je     209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cb5:	vucomisd xmm10,xmm0
  209cb9:	ja     209cdc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8bc>
  209cbb:	vmovapd xmm0,xmm4
  209cbf:	jmp    209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cc4:	vucomisd xmm0,xmm5
  209cc8:	mov    rax,QWORD PTR [rsp+0x8]
  209ccd:	lea    rsi,[rax+rdi*1]
  209cd1:	mov    r9,QWORD PTR [rsp+0x18]
  209cd6:	jb     209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cdc:	vmovapd xmm0,xmm6
  209ce0:	jmp    209b6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209ce5:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  209ceb:	mov    eax,0x1
  209cf0:	mov    rdx,r14
  209cf3:	add    rsp,0x118
  209cfa:	pop    rbx
  209cfb:	pop    r12
  209cfd:	pop    r13
  209cff:	pop    r14
  209d01:	pop    r15
  209d03:	pop    rbp
  209d04:	vzeroupper
  209d07:	ret
  209d08:	xor    eax,eax
  209d0a:	jmp    209cf0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  209d0c:	lea    rdi,[rip+0xffffffffffe3d2d5]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  209d13:	lea    rdx,[rip+0x331f1e]        # 53bc38 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xd8>
  209d1a:	mov    esi,0x28
  209d1f:	vzeroupper
  209d22:	call   QWORD PTR [rip+0x3404e8]        # 54a210 <_DYNAMIC+0x438>
  209d28:	lea    rcx,[rip+0x3321a9]        # 53bed8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1b0>
  209d2f:	xor    edi,edi
  209d31:	mov    rdx,QWORD PTR [rsp+0x88]
  209d39:	vzeroupper
  209d3c:	call   QWORD PTR [rip+0x340396]        # 54a0d8 <_DYNAMIC+0x300>
  209d42:	lea    r10,[rip+0x331f07]        # 53bc50 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xf0>
  209d49:	lea    r11,[rip+0xffffffffffe35c80]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209d50:	lea    rbx,[rip+0x331b99]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  209d57:	lea    r14,[rip+0x33257a]        # 53c2d8 <anon.c38c26bc52a245a79a4d978676f36d04.145.llvm.17936451394092910270>
  209d5e:	movabs rcx,0x7fffffffffffffff
  209d68:	mov    r8d,0x1
  209d6e:	mov    r9d,0x1
  209d74:	mov    rdi,rax
  209d77:	mov    rsi,rax
  209d7a:	mov    rdx,QWORD PTR [rsp+0x8]
  209d7f:	push   r10
  209d81:	push   r11
  209d83:	push   rbx
  209d84:	push   r14
  209d86:	vzeroupper
  209d89:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  209d8e:	lea    rax,[rip+0x331e73]        # 53bc08 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xa8>
  209d95:	lea    r10,[rip+0xffffffffffe35c34]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209d9c:	lea    r11,[rip+0x331af5]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209da3:	lea    rbx,[rip+0x331d36]        # 53bae0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x1f0>
  209daa:	mov    r8d,0x1
  209db0:	mov    rdi,rsi
  209db3:	mov    r9d,0x1
  209db9:	mov    rdx,QWORD PTR [rsp+0xb8]
  209dc1:	jmp    209e34 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0xa14>
  209dc3:	sub    rsp,0x8
  209dc7:	lea    rax,[rip+0x331bda]        # 53b9a8 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0xb8>
  209dce:	lea    rcx,[rip+0x331b8b]        # 53b960 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x70>
  209dd5:	lea    r8,[rip+0x331aa4]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  209ddc:	mov    rdi,rsi
  209ddf:	lea    r9,[rip+0xffffffffffe35bea]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209de6:	mov    edx,0x1
  209deb:	mov    rsi,QWORD PTR [rsp+0x88]
  209df3:	push   rax
  209df4:	vzeroupper
  209df7:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  209dfc:	lea    rax,[rip+0x331e1d]        # 53bc20 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xc0>
  209e03:	lea    r10,[rip+0xffffffffffe35bc6]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209e0a:	lea    r11,[rip+0x331a87]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209e11:	lea    rbx,[rip+0x332540]        # 53c358 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x58>
  209e18:	movabs rcx,0x7fffffffffffffff
  209e22:	mov    r8d,0x1
  209e28:	mov    rdx,rsi
  209e2b:	mov    r9d,0x1
  209e31:	mov    rsi,rdi
  209e34:	push   rax
  209e35:	push   r10
  209e37:	push   r11
  209e39:	push   rbx
  209e3a:	vzeroupper
  209e3d:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
