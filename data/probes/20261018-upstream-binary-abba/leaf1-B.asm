
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/a53774682edd-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

0000000000209430 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench>:
  209430:	push   rbp
  209431:	push   r15
  209433:	push   r14
  209435:	push   r13
  209437:	push   r12
  209439:	push   rbx
  20943a:	sub    rsp,0x118
  209441:	mov    rax,QWORD PTR [rdi+0x8]
  209445:	test   rax,rax
  209448:	je     209535 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20944e:	mov    rcx,QWORD PTR [rdi+0x10]
  209452:	cmp    rax,rcx
  209455:	mov    rdx,rcx
  209458:	cmovb  rdx,rax
  20945c:	mov    QWORD PTR [rsp+0xd0],rdx
  209464:	test   rcx,rcx
  209467:	je     209535 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20946d:	mov    QWORD PTR [rsp+0xb8],rax
  209475:	mov    r9,QWORD PTR [rdi+0x40]
  209479:	mov    rax,QWORD PTR [rdi+0x48]
  20947d:	mov    QWORD PTR [rsp+0x80],rax
  209485:	mov    rsi,QWORD PTR [rdi+0x50]
  209489:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  20948e:	vmovsd xmm4,QWORD PTR [rdi+0x38]
  209493:	mov    r10,QWORD PTR [rdi+0x20]
  209497:	mov    rax,QWORD PTR [rdi+0x28]
  20949b:	mov    QWORD PTR [rsp+0x88],rax
  2094a3:	movzx  eax,BYTE PTR [rdi+0x59]
  2094a7:	mov    BYTE PTR [rsp+0x7],al
  2094ab:	movzx  edx,BYTE PTR [rdi+0x58]
  2094af:	mov    rax,QWORD PTR [rdi]
  2094b2:	mov    rdi,QWORD PTR [rdi+0x18]
  2094b6:	vmovddup xmm0,QWORD PTR [rip+0xffffffffffe36662]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  2094be:	vxorpd xmm5,xmm3,xmm0
  2094c2:	vxorpd xmm6,xmm4,xmm0
  2094c6:	mov    QWORD PTR [rsp+0xf8],rsi
  2094ce:	lea    rsi,[rsi*8+0x0]
  2094d6:	mov    QWORD PTR [rsp+0x48],rsi
  2094db:	mov    QWORD PTR [rsp+0x100],rdi
  2094e3:	lea    r8,[rdi*8+0x0]
  2094eb:	mov    QWORD PTR [rsp+0x40],rax
  2094f0:	add    rax,0x60
  2094f4:	mov    QWORD PTR [rsp+0xc0],rax
  2094fc:	vmovddup xmm7,QWORD PTR [rip+0xffffffffffe3661c]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  209504:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe36554]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  20950c:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe365b4]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  209514:	vxorpd xmm10,xmm10,xmm10
  209519:	xor    r14d,r14d
  20951c:	xor    edi,edi
  20951e:	mov    QWORD PTR [rsp+0x18],r9
  209523:	mov    QWORD PTR [rsp+0xc8],rcx
  20952b:	mov    QWORD PTR [rsp+0x90],r10
  209533:	jmp    209572 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x142>
  209535:	xor    r14d,r14d
  209538:	xor    eax,eax
  20953a:	jmp    209d00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20953f:	nop
  209540:	mov    QWORD PTR [rsp+0x50],0x0
  209549:	mov    r14,QWORD PTR [rsp+0xd8]
  209551:	add    r14,QWORD PTR [rsp+0x50]
  209556:	mov    rdi,rsi
  209559:	mov    rcx,QWORD PTR [rsp+0xc8]
  209561:	cmp    rsi,rcx
  209564:	mov    r10,QWORD PTR [rsp+0x90]
  20956c:	jae    209d18 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8e8>
  209572:	mov    rsi,rcx
  209575:	sub    rsi,rdi
  209578:	cmp    rsi,0x10
  20957c:	mov    eax,0x10
  209581:	cmovae rsi,rax
  209585:	mov    QWORD PTR [rsp+0x8],rsi
  20958a:	add    rsi,rdi
  20958d:	cmp    rsi,QWORD PTR [rsp+0xd0]
  209595:	ja     209d9e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x96e>
  20959b:	cmp    rsi,QWORD PTR [rsp+0x80]
  2095a3:	ja     209dd3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9a3>
  2095a9:	cmp    rsi,QWORD PTR [rsp+0x88]
  2095b1:	seta   al
  2095b4:	test   r10,r10
  2095b7:	jne    2095bb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x18b>
  2095b9:	xor    eax,eax
  2095bb:	test   al,al
  2095bd:	jne    209d38 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x908>
  2095c3:	test   rdi,rdi
  2095c6:	js     209e0c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  2095cc:	cmp    rdi,rsi
  2095cf:	ja     209e0c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  2095d5:	mov    QWORD PTR [rsp+0xd8],r14
  2095dd:	test   rsi,rsi
  2095e0:	je     209540 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x110>
  2095e6:	mov    rax,QWORD PTR [rsp+0x8]
  2095eb:	lea    r10,[rax-0x1]
  2095ef:	mov    r12,r10
  2095f2:	shr    r12,0x2
  2095f6:	mov    eax,r10d
  2095f9:	and    eax,0x3
  2095fc:	shl    eax,0x9
  2095ff:	mov    rcx,QWORD PTR [rip+0x340bba]        # 54a1c0 <_DYNAMIC+0x3e8>
  209606:	mov    rbp,QWORD PTR [rcx+rax*1+0x200]
  20960e:	mov    r15,QWORD PTR [rcx+rax*1+0x208]
  209616:	mov    QWORD PTR [rsp+0xf0],r10
  20961e:	and    r10,0xfffffffffffffffc
  209622:	mov    QWORD PTR [rsp+0x28],r10
  209627:	xor    eax,eax
  209629:	test   r12,r12
  20962c:	setne  al
  20962f:	lea    rcx,[rax+0x1]
  209633:	cmp    r12,rax
  209636:	mov    QWORD PTR [rsp+0x98],rax
  20963e:	cmovbe rcx,rax
  209642:	lea    eax,[rcx*4+0x0]
  209649:	mov    QWORD PTR [rsp+0xa0],rax
  209651:	mov    ebx,r12d
  209654:	and    ebx,0x3
  209657:	mov    r13,r12
  20965a:	and    r13,0xfffffffffffffffc
  20965e:	mov    r11,r12
  209661:	shl    r11,0x5
  209665:	mov    QWORD PTR [rsp+0x108],rcx
  20966d:	shl    ecx,0x5
  209670:	mov    QWORD PTR [rsp+0x110],rcx
  209678:	mov    rax,QWORD PTR [rsp+0xc0]
  209680:	lea    r10,[rax+rdi*8]
  209684:	mov    rax,QWORD PTR [rsp+0x40]
  209689:	lea    rcx,[rax+rdi*8]
  20968d:	mov    QWORD PTR [rsp+0xa8],rcx
  209695:	mov    QWORD PTR [rsp+0xe0],rbx
  20969d:	shl    ebx,0x5
  2096a0:	mov    QWORD PTR [rsp+0x70],rax
  2096a5:	mov    QWORD PTR [rsp+0x68],0x0
  2096ae:	mov    QWORD PTR [rsp+0x50],0x0
  2096b7:	xor    r14d,r14d
  2096ba:	mov    QWORD PTR [rsp+0x60],rdi
  2096bf:	mov    QWORD PTR [rsp+0x58],r12
  2096c4:	mov    QWORD PTR [rsp+0x20],r15
  2096c9:	mov    QWORD PTR [rsp+0x38],r13
  2096ce:	mov    QWORD PTR [rsp+0xe8],rsi
  2096d6:	jmp    209728 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2f8>
  2096d8:	nop    DWORD PTR [rax+rax*1+0x0]
  2096e0:	inc    r14
  2096e3:	mov    rax,QWORD PTR [rsp+0x28]
  2096e8:	mov    rcx,QWORD PTR [rsp+0x78]
  2096ed:	lea    rax,[rcx+rax*8]
  2096f1:	lea    rcx,[rip+0x2]        # 2096fa <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2ca>
  2096f8:	jmp    rbp
  2096fa:	vmulpd ymm0,ymm2,ymm0
  2096fe:	lea    rcx,[rip+0x3]        # 209708 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2d8>
  209705:	jmp    r15
  209708:	add    QWORD PTR [rsp+0x68],0x8
  20970e:	add    QWORD PTR [rsp+0x70],0x8
  209714:	add    r10,r8
  209717:	add    QWORD PTR [rsp+0xa8],r8
  20971f:	cmp    r14,rsi
  209722:	je     209549 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x119>
  209728:	test   r14,r14
  20972b:	mov    r15,rdi
  20972e:	cmove  r15,r14
  209732:	mov    rax,r14
  209735:	imul   rax,QWORD PTR [rsp+0x100]
  20973e:	mov    rcx,QWORD PTR [rsp+0x40]
  209743:	lea    r13,[rcx+r15*8]
  209747:	lea    rax,[rcx+rax*8]
  20974b:	mov    QWORD PTR [rsp+0xb0],rax
  209753:	lea    rcx,[rax+rdi*8]
  209757:	cmp    QWORD PTR [rsp+0x108],r12
  20975f:	mov    QWORD PTR [rsp+0x30],r10
  209764:	mov    QWORD PTR [rsp+0x78],rcx
  209769:	jae    209830 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x400>
  20976f:	cmp    r12,QWORD PTR [rsp+0x98]
  209777:	jbe    209d1c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8ec>
  20977d:	vmovupd ymm11,YMMWORD PTR [rcx]
  209781:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  209786:	mov    rax,QWORD PTR [rsp+0xa0]
  20978e:	vmovupd ymm13,YMMWORD PTR [rcx+rax*8]
  209793:	mov    rax,QWORD PTR [rsp+0x28]
  209798:	lea    rax,[rcx+rax*8]
  20979c:	mov    rsi,rax
  20979f:	lea    rcx,[rip+0x2]        # 2097a8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x378>
  2097a6:	jmp    rbp
  2097a8:	vmovapd ymm2,ymm0
  2097ac:	test   r14,r14
  2097af:	je     209982 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x552>
  2097b5:	mov    rdi,r14
  2097b8:	mov    r12,QWORD PTR [rsp+0x70]
  2097bd:	mov    r10,r9
  2097c0:	mov    r15,QWORD PTR [rsp+0x20]
  2097c5:	jmp    20981c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3ec>
  2097c7:	nop    WORD PTR [rax+rax*1+0x0]
  2097d0:	vmulsd xmm0,xmm0,QWORD PTR [r12]
  2097d6:	vbroadcastsd ymm14,xmm0
  2097db:	lea    rax,[r11+r13*1]
  2097df:	vfmadd231pd ymm11,ymm14,YMMWORD PTR [r13+0x0]
  2097e5:	vfmadd231pd ymm12,ymm14,YMMWORD PTR [r13+0x20]
  2097eb:	mov    rcx,QWORD PTR [rsp+0x110]
  2097f3:	vfmadd231pd ymm13,ymm14,YMMWORD PTR [r13+rcx*1+0x0]
  2097fa:	lea    rcx,[rip+0x2]        # 209803 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3d3>
  209801:	jmp    rbp
  209803:	vfmadd231pd ymm2,ymm14,ymm0
  209808:	add    r10,QWORD PTR [rsp+0x48]
  20980d:	add    r12,r8
  209810:	add    r13,r8
  209813:	dec    rdi
  209816:	je     2098e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4b0>
  20981c:	vmovapd xmm0,xmm8
  209820:	test   dl,dl
  209822:	jne    2097d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  209824:	vmovsd xmm0,QWORD PTR [r10]
  209829:	vxorpd xmm0,xmm0,xmm7
  20982d:	jmp    2097d0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20982f:	nop
  209830:	test   r12,r12
  209833:	je     2098f4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4c4>
  209839:	vmovupd ymm11,YMMWORD PTR [rcx]
  20983d:	cmp    r12,QWORD PTR [rsp+0x98]
  209845:	jbe    2099c5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x595>
  20984b:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  209850:	mov    rax,QWORD PTR [rsp+0x28]
  209855:	lea    rax,[rcx+rax*8]
  209859:	lea    rcx,[rip+0x2]        # 209862 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x432>
  209860:	jmp    rbp
  209862:	vmovapd ymm2,ymm0
  209866:	test   r14,r14
  209869:	je     209aa5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x675>
  20986f:	mov    QWORD PTR [rsp+0x10],rax
  209874:	lea    r10,[r11+r15*8]
  209878:	shl    r15,0x3
  20987c:	mov    r12,r14
  20987f:	mov    r13,QWORD PTR [rsp+0x40]
  209884:	mov    rsi,QWORD PTR [rsp+0x68]
  209889:	jmp    2098cd <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x49d>
  20988b:	nop    DWORD PTR [rax+rax*1+0x0]
  209890:	vmulsd xmm0,xmm0,QWORD PTR [r13+rsi*1+0x0]
  209897:	vbroadcastsd ymm13,xmm0
  20989c:	vfmadd231pd ymm11,ymm13,YMMWORD PTR [r13+r15*1+0x0]
  2098a3:	vfmadd231pd ymm12,ymm13,YMMWORD PTR [r13+r15*1+0x20]
  2098aa:	lea    rax,[r10+r13*1]
  2098ae:	lea    rcx,[rip+0x2]        # 2098b7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x487>
  2098b5:	jmp    rbp
  2098b7:	vfmadd231pd ymm2,ymm13,ymm0
  2098bc:	add    r9,QWORD PTR [rsp+0x48]
  2098c1:	add    r13,r8
  2098c4:	dec    r12
  2098c7:	je     209a83 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x653>
  2098cd:	vmovapd xmm0,xmm8
  2098d1:	test   dl,dl
  2098d3:	jne    209890 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  2098d5:	vmovsd xmm0,QWORD PTR [r9]
  2098da:	vxorpd xmm0,xmm0,xmm7
  2098de:	jmp    209890 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  2098e0:	mov    rdi,QWORD PTR [rsp+0x60]
  2098e5:	mov    r12,QWORD PTR [rsp+0x58]
  2098ea:	mov    r10,QWORD PTR [rsp+0x30]
  2098ef:	jmp    209987 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x557>
  2098f4:	mov    rax,QWORD PTR [rsp+0x28]
  2098f9:	lea    rax,[rcx+rax*8]
  2098fd:	mov    QWORD PTR [rsp+0x10],rax
  209902:	lea    rcx,[rip+0x2]        # 20990b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4db>
  209909:	jmp    rbp
  20990b:	vmovapd ymm2,ymm0
  20990f:	test   r14,r14
  209912:	mov    r13,QWORD PTR [rsp+0x38]
  209917:	je     209a66 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x636>
  20991d:	lea    rdi,[r11+r15*8]
  209921:	mov    r12,r9
  209924:	mov    r9,r14
  209927:	mov    r10,QWORD PTR [rsp+0x40]
  20992c:	mov    rsi,QWORD PTR [rsp+0x68]
  209931:	jmp    20996e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x53e>
  209933:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  209940:	vmulsd xmm0,xmm0,QWORD PTR [r10+rsi*1]
  209946:	vbroadcastsd ymm11,xmm0
  20994b:	lea    rax,[r10+rdi*1]
  20994f:	lea    rcx,[rip+0x2]        # 209958 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x528>
  209956:	jmp    rbp
  209958:	vfmadd231pd ymm2,ymm11,ymm0
  20995d:	add    r12,QWORD PTR [rsp+0x48]
  209962:	add    r10,r8
  209965:	dec    r9
  209968:	je     209a49 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x619>
  20996e:	vmovapd xmm0,xmm8
  209972:	test   dl,dl
  209974:	jne    209940 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  209976:	vmovsd xmm0,QWORD PTR [r12]
  20997c:	vxorpd xmm0,xmm0,xmm7
  209980:	jmp    209940 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  209982:	mov    r15,QWORD PTR [rsp+0x20]
  209987:	mov    rcx,QWORD PTR [rsp+0x78]
  20998c:	vmovupd YMMWORD PTR [rcx],ymm11
  209990:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209995:	mov    rax,QWORD PTR [rsp+0xa0]
  20999d:	vmovupd YMMWORD PTR [rcx+rax*8],ymm13
  2099a2:	mov    rax,rsi
  2099a5:	vmovapd ymm0,ymm2
  2099a9:	lea    rcx,[rip+0x3]        # 2099b3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x583>
  2099b0:	jmp    r15
  2099b3:	mov    r13,QWORD PTR [rsp+0x38]
  2099b8:	mov    rsi,QWORD PTR [rsp+0xe8]
  2099c0:	jmp    209b03 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  2099c5:	mov    rax,QWORD PTR [rsp+0x28]
  2099ca:	lea    rax,[rcx+rax*8]
  2099ce:	mov    QWORD PTR [rsp+0x10],rax
  2099d3:	lea    rcx,[rip+0x2]        # 2099dc <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ac>
  2099da:	jmp    rbp
  2099dc:	vmovapd ymm2,ymm0
  2099e0:	test   r14,r14
  2099e3:	mov    r15,QWORD PTR [rsp+0x20]
  2099e8:	je     209adb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ab>
  2099ee:	mov    rsi,r14
  2099f1:	mov    r10,r9
  2099f4:	mov    r9,QWORD PTR [rsp+0x70]
  2099f9:	jmp    209a36 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x606>
  2099fb:	nop    DWORD PTR [rax+rax*1+0x0]
  209a00:	vmulsd xmm0,xmm0,QWORD PTR [r9]
  209a05:	vbroadcastsd ymm12,xmm0
  209a0a:	lea    rax,[r11+r13*1]
  209a0e:	vfmadd231pd ymm11,ymm12,YMMWORD PTR [r13+0x0]
  209a14:	lea    rcx,[rip+0x2]        # 209a1d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ed>
  209a1b:	jmp    rbp
  209a1d:	vfmadd231pd ymm2,ymm12,ymm0
  209a22:	add    r10,QWORD PTR [rsp+0x48]
  209a27:	add    r9,r8
  209a2a:	add    r13,r8
  209a2d:	dec    rsi
  209a30:	je     209ac8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x698>
  209a36:	vmovapd xmm0,xmm8
  209a3a:	test   dl,dl
  209a3c:	jne    209a00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  209a3e:	vmovsd xmm0,QWORD PTR [r10]
  209a43:	vxorpd xmm0,xmm0,xmm7
  209a47:	jmp    209a00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  209a49:	mov    rdi,QWORD PTR [rsp+0x60]
  209a4e:	mov    rax,QWORD PTR [rsp+0x8]
  209a53:	lea    rsi,[rax+rdi*1]
  209a57:	mov    r9,QWORD PTR [rsp+0x18]
  209a5c:	mov    r12,QWORD PTR [rsp+0x58]
  209a61:	mov    r10,QWORD PTR [rsp+0x30]
  209a66:	mov    rax,QWORD PTR [rsp+0x10]
  209a6b:	vmovapd ymm0,ymm2
  209a6f:	mov    r15,QWORD PTR [rsp+0x20]
  209a74:	lea    rcx,[rip+0x3]        # 209a7e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x64e>
  209a7b:	jmp    r15
  209a7e:	jmp    209b03 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  209a83:	mov    rdi,QWORD PTR [rsp+0x60]
  209a88:	mov    rax,QWORD PTR [rsp+0x8]
  209a8d:	lea    rsi,[rax+rdi*1]
  209a91:	mov    r9,QWORD PTR [rsp+0x18]
  209a96:	mov    r12,QWORD PTR [rsp+0x58]
  209a9b:	mov    r10,QWORD PTR [rsp+0x30]
  209aa0:	mov    rax,QWORD PTR [rsp+0x10]
  209aa5:	mov    rcx,QWORD PTR [rsp+0x78]
  209aaa:	vmovupd YMMWORD PTR [rcx],ymm11
  209aae:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  209ab3:	vmovapd ymm0,ymm2
  209ab7:	mov    r15,QWORD PTR [rsp+0x20]
  209abc:	lea    rcx,[rip+0x3]        # 209ac6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x696>
  209ac3:	jmp    r15
  209ac6:	jmp    209afe <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  209ac8:	mov    rax,QWORD PTR [rsp+0x8]
  209acd:	lea    rsi,[rax+rdi*1]
  209ad1:	mov    r9,QWORD PTR [rsp+0x18]
  209ad6:	mov    r10,QWORD PTR [rsp+0x30]
  209adb:	mov    rax,QWORD PTR [rsp+0xb0]
  209ae3:	lea    rax,[rax+rdi*8]
  209ae7:	vmovupd YMMWORD PTR [rax],ymm11
  209aeb:	mov    rax,QWORD PTR [rsp+0x10]
  209af0:	vmovapd ymm0,ymm2
  209af4:	lea    rcx,[rip+0x3]        # 209afe <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  209afb:	jmp    r15
  209afe:	mov    r13,QWORD PTR [rsp+0x38]
  209b03:	mov    rcx,r14
  209b06:	imul   rcx,QWORD PTR [rsp+0xf8]
  209b0f:	mov    rax,r14
  209b12:	sub    rax,rdi
  209b15:	jae    209b30 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x700>
  209b17:	vmovsd xmm0,QWORD PTR [r9+rcx*8]
  209b1d:	jmp    209bb6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x786>
  209b22:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  209b30:	cmp    rax,QWORD PTR [rsp+0x8]
  209b35:	jae    209d52 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x922>
  209b3b:	mov    rax,QWORD PTR [rsp+0xb0]
  209b43:	vmovsd xmm0,QWORD PTR [rax+r14*8]
  209b49:	cmp    BYTE PTR [rsp+0x7],0x0
  209b4e:	je     209b67 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x737>
  209b50:	test   dl,dl
  209b52:	je     209c58 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x828>
  209b58:	vucomisd xmm3,xmm0
  209b5c:	jb     209b6b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x73b>
  209b5e:	inc    QWORD PTR [rsp+0x50]
  209b63:	vmovapd xmm0,xmm4
  209b67:	test   dl,dl
  209b69:	je     209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209b6b:	vucomisd xmm0,xmm10
  209b70:	jbe    209cf5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8c5>
  209b76:	vsqrtsd xmm0,xmm0,xmm0
  209b7a:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  209b80:	vmovq  rax,xmm0
  209b85:	mov    cl,0x3f
  209b87:	bzhi   rax,rax,rcx
  209b8c:	movabs rcx,0x7ff0000000000000
  209b96:	cmp    rax,rcx
  209b99:	setg   cl
  209b9c:	sete   r10b
  209ba0:	test   rax,rax
  209ba3:	sete   al
  209ba6:	or     al,r10b
  209ba9:	or     al,cl
  209bab:	mov    r10,QWORD PTR [rsp+0x30]
  209bb0:	jne    209cfb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8cb>
  209bb6:	vdivsd xmm0,xmm9,xmm0
  209bba:	vbroadcastsd ymm2,xmm0
  209bbf:	test   r12,r12
  209bc2:	je     2096e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209bc8:	cmp    QWORD PTR [rsp+0xf0],0x10
  209bd1:	jae    209be0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7b0>
  209bd3:	xor    eax,eax
  209bd5:	jmp    209c32 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x802>
  209bd7:	nop    WORD PTR [rax+rax*1+0x0]
  209be0:	mov    rcx,r10
  209be3:	xor    eax,eax
  209be5:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  209bf0:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  209bf5:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  209bfa:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  209bff:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  209c04:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  209c09:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  209c0e:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  209c12:	add    rax,0x4
  209c16:	vmovupd YMMWORD PTR [rcx],ymm0
  209c1a:	sub    rcx,0xffffffffffffff80
  209c1e:	cmp    r13,rax
  209c21:	jne    209bf0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7c0>
  209c23:	cmp    QWORD PTR [rsp+0xe0],0x0
  209c2c:	je     2096e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209c32:	shl    rax,0x5
  209c36:	add    rax,QWORD PTR [rsp+0xa8]
  209c3e:	xor    ecx,ecx
  209c40:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  209c45:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  209c4a:	add    rcx,0x20
  209c4e:	cmp    rbx,rcx
  209c51:	jne    209c40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x810>
  209c53:	jmp    2096e0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  209c58:	mov    rax,QWORD PTR [rsp+0x90]
  209c60:	test   rax,rax
  209c63:	je     209ca5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x875>
  209c65:	movzx  r9d,BYTE PTR [rax+r14*1]
  209c6a:	vucomisd xmm3,xmm0
  209c6e:	setae  al
  209c71:	vucomisd xmm0,xmm5
  209c75:	setae  r10b
  209c79:	cmp    r9d,0xff
  209c80:	je     209cd4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8a4>
  209c82:	cmp    r9d,0x1
  209c86:	mov    rsi,QWORD PTR [rsp+0x8]
  209c8b:	lea    rsi,[rsi+rdi*1]
  209c8f:	mov    r9,QWORD PTR [rsp+0x18]
  209c94:	jne    209cb4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x884>
  209c96:	vucomisd xmm3,xmm0
  209c9a:	jae    209b5e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x72e>
  209ca0:	jmp    209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209ca5:	vucomisd xmm3,xmm0
  209ca9:	setae  al
  209cac:	vucomisd xmm0,xmm5
  209cb0:	setae  r10b
  209cb4:	test   r10b,r10b
  209cb7:	je     209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cbd:	test   al,al
  209cbf:	je     209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cc5:	vucomisd xmm10,xmm0
  209cc9:	ja     209cec <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8bc>
  209ccb:	vmovapd xmm0,xmm4
  209ccf:	jmp    209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cd4:	vucomisd xmm0,xmm5
  209cd8:	mov    rax,QWORD PTR [rsp+0x8]
  209cdd:	lea    rsi,[rax+rdi*1]
  209ce1:	mov    r9,QWORD PTR [rsp+0x18]
  209ce6:	jb     209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cec:	vmovapd xmm0,xmm6
  209cf0:	jmp    209b7a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  209cf5:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  209cfb:	mov    eax,0x1
  209d00:	mov    rdx,r14
  209d03:	add    rsp,0x118
  209d0a:	pop    rbx
  209d0b:	pop    r12
  209d0d:	pop    r13
  209d0f:	pop    r14
  209d11:	pop    r15
  209d13:	pop    rbp
  209d14:	vzeroupper
  209d17:	ret
  209d18:	xor    eax,eax
  209d1a:	jmp    209d00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  209d1c:	lea    rdi,[rip+0xffffffffffe3d2c5]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  209d23:	lea    rdx,[rip+0x331f0e]        # 53bc38 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xd8>
  209d2a:	mov    esi,0x28
  209d2f:	vzeroupper
  209d32:	call   QWORD PTR [rip+0x3404d8]        # 54a210 <_DYNAMIC+0x438>
  209d38:	lea    rcx,[rip+0x332199]        # 53bed8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1b0>
  209d3f:	xor    edi,edi
  209d41:	mov    rdx,QWORD PTR [rsp+0x88]
  209d49:	vzeroupper
  209d4c:	call   QWORD PTR [rip+0x340386]        # 54a0d8 <_DYNAMIC+0x300>
  209d52:	lea    r10,[rip+0x331ef7]        # 53bc50 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xf0>
  209d59:	lea    r11,[rip+0xffffffffffe35c70]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209d60:	lea    rbx,[rip+0x331b89]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  209d67:	lea    r14,[rip+0x33256a]        # 53c2d8 <anon.c38c26bc52a245a79a4d978676f36d04.145.llvm.17936451394092910270>
  209d6e:	movabs rcx,0x7fffffffffffffff
  209d78:	mov    r8d,0x1
  209d7e:	mov    r9d,0x1
  209d84:	mov    rdi,rax
  209d87:	mov    rsi,rax
  209d8a:	mov    rdx,QWORD PTR [rsp+0x8]
  209d8f:	push   r10
  209d91:	push   r11
  209d93:	push   rbx
  209d94:	push   r14
  209d96:	vzeroupper
  209d99:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  209d9e:	lea    rax,[rip+0x331e63]        # 53bc08 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xa8>
  209da5:	lea    r10,[rip+0xffffffffffe35c24]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209dac:	lea    r11,[rip+0x331ae5]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209db3:	lea    rbx,[rip+0x331d26]        # 53bae0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x1f0>
  209dba:	mov    r8d,0x1
  209dc0:	mov    rdi,rsi
  209dc3:	mov    r9d,0x1
  209dc9:	mov    rdx,QWORD PTR [rsp+0xb8]
  209dd1:	jmp    209e44 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsiVB0znSuPaP_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0xa14>
  209dd3:	sub    rsp,0x8
  209dd7:	lea    rax,[rip+0x331bca]        # 53b9a8 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0xb8>
  209dde:	lea    rcx,[rip+0x331b7b]        # 53b960 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x70>
  209de5:	lea    r8,[rip+0x331a94]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  209dec:	mov    rdi,rsi
  209def:	lea    r9,[rip+0xffffffffffe35bda]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209df6:	mov    edx,0x1
  209dfb:	mov    rsi,QWORD PTR [rsp+0x88]
  209e03:	push   rax
  209e04:	vzeroupper
  209e07:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  209e0c:	lea    rax,[rip+0x331e0d]        # 53bc20 <anon.c38c26bc52a245a79a4d978676f36d04.68.llvm.17936451394092910270+0xc0>
  209e13:	lea    r10,[rip+0xffffffffffe35bb6]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  209e1a:	lea    r11,[rip+0x331a77]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  209e21:	lea    rbx,[rip+0x332530]        # 53c358 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x58>
  209e28:	movabs rcx,0x7fffffffffffffff
  209e32:	mov    r8d,0x1
  209e38:	mov    rdx,rsi
  209e3b:	mov    r9d,0x1
  209e41:	mov    rsi,rdi
  209e44:	push   rax
  209e45:	push   r10
  209e47:	push   r11
  209e49:	push   rbx
  209e4a:	vzeroupper
  209e4d:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
