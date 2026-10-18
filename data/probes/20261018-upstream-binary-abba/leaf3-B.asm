
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/a53774682edd-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000020a9a0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench>:
  20a9a0:	push   rbp
  20a9a1:	push   r15
  20a9a3:	push   r14
  20a9a5:	push   r13
  20a9a7:	push   r12
  20a9a9:	push   rbx
  20a9aa:	sub    rsp,0x118
  20a9b1:	mov    rax,QWORD PTR [rdi+0x8]
  20a9b5:	test   rax,rax
  20a9b8:	je     20aaa5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20a9be:	mov    rcx,QWORD PTR [rdi+0x10]
  20a9c2:	cmp    rax,rcx
  20a9c5:	mov    rdx,rcx
  20a9c8:	cmovb  rdx,rax
  20a9cc:	mov    QWORD PTR [rsp+0xd0],rdx
  20a9d4:	test   rcx,rcx
  20a9d7:	je     20aaa5 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20a9dd:	mov    QWORD PTR [rsp+0xb8],rax
  20a9e5:	mov    r9,QWORD PTR [rdi+0x40]
  20a9e9:	mov    rax,QWORD PTR [rdi+0x48]
  20a9ed:	mov    QWORD PTR [rsp+0x80],rax
  20a9f5:	mov    rsi,QWORD PTR [rdi+0x50]
  20a9f9:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  20a9fe:	vmovsd xmm4,QWORD PTR [rdi+0x38]
  20aa03:	mov    r10,QWORD PTR [rdi+0x20]
  20aa07:	mov    rax,QWORD PTR [rdi+0x28]
  20aa0b:	mov    QWORD PTR [rsp+0x88],rax
  20aa13:	movzx  eax,BYTE PTR [rdi+0x59]
  20aa17:	mov    BYTE PTR [rsp+0x7],al
  20aa1b:	movzx  edx,BYTE PTR [rdi+0x58]
  20aa1f:	mov    rax,QWORD PTR [rdi]
  20aa22:	mov    rdi,QWORD PTR [rdi+0x18]
  20aa26:	vmovddup xmm0,QWORD PTR [rip+0xffffffffffe350f2]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20aa2e:	vxorpd xmm5,xmm3,xmm0
  20aa32:	vxorpd xmm6,xmm4,xmm0
  20aa36:	mov    QWORD PTR [rsp+0xf8],rsi
  20aa3e:	lea    rsi,[rsi*8+0x0]
  20aa46:	mov    QWORD PTR [rsp+0x48],rsi
  20aa4b:	mov    QWORD PTR [rsp+0x100],rdi
  20aa53:	lea    r8,[rdi*8+0x0]
  20aa5b:	mov    QWORD PTR [rsp+0x40],rax
  20aa60:	add    rax,0x60
  20aa64:	mov    QWORD PTR [rsp+0xc0],rax
  20aa6c:	vmovddup xmm7,QWORD PTR [rip+0xffffffffffe350ac]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20aa74:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe34fe4]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  20aa7c:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe35044]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  20aa84:	vxorpd xmm10,xmm10,xmm10
  20aa89:	xor    r14d,r14d
  20aa8c:	xor    edi,edi
  20aa8e:	mov    QWORD PTR [rsp+0x18],r9
  20aa93:	mov    QWORD PTR [rsp+0xc8],rcx
  20aa9b:	mov    QWORD PTR [rsp+0x90],r10
  20aaa3:	jmp    20aae2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x142>
  20aaa5:	xor    r14d,r14d
  20aaa8:	xor    eax,eax
  20aaaa:	jmp    20b270 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20aaaf:	nop
  20aab0:	mov    QWORD PTR [rsp+0x50],0x0
  20aab9:	mov    r14,QWORD PTR [rsp+0xd8]
  20aac1:	add    r14,QWORD PTR [rsp+0x50]
  20aac6:	mov    rdi,rsi
  20aac9:	mov    rcx,QWORD PTR [rsp+0xc8]
  20aad1:	cmp    rsi,rcx
  20aad4:	mov    r10,QWORD PTR [rsp+0x90]
  20aadc:	jae    20b288 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8e8>
  20aae2:	mov    rsi,rcx
  20aae5:	sub    rsi,rdi
  20aae8:	cmp    rsi,0x10
  20aaec:	mov    eax,0x10
  20aaf1:	cmovae rsi,rax
  20aaf5:	mov    QWORD PTR [rsp+0x8],rsi
  20aafa:	add    rsi,rdi
  20aafd:	cmp    rsi,QWORD PTR [rsp+0xd0]
  20ab05:	ja     20b30e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x96e>
  20ab0b:	cmp    rsi,QWORD PTR [rsp+0x80]
  20ab13:	ja     20b343 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9a3>
  20ab19:	cmp    rsi,QWORD PTR [rsp+0x88]
  20ab21:	seta   al
  20ab24:	test   r10,r10
  20ab27:	jne    20ab2b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x18b>
  20ab29:	xor    eax,eax
  20ab2b:	test   al,al
  20ab2d:	jne    20b2a8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x908>
  20ab33:	test   rdi,rdi
  20ab36:	js     20b37c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  20ab3c:	cmp    rdi,rsi
  20ab3f:	ja     20b37c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  20ab45:	mov    QWORD PTR [rsp+0xd8],r14
  20ab4d:	test   rsi,rsi
  20ab50:	je     20aab0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x110>
  20ab56:	mov    rax,QWORD PTR [rsp+0x8]
  20ab5b:	lea    r10,[rax-0x1]
  20ab5f:	mov    r12,r10
  20ab62:	shr    r12,0x2
  20ab66:	mov    eax,r10d
  20ab69:	and    eax,0x3
  20ab6c:	shl    eax,0x9
  20ab6f:	mov    rcx,QWORD PTR [rip+0x33f64a]        # 54a1c0 <_DYNAMIC+0x3e8>
  20ab76:	mov    rbp,QWORD PTR [rcx+rax*1+0x200]
  20ab7e:	mov    r15,QWORD PTR [rcx+rax*1+0x208]
  20ab86:	mov    QWORD PTR [rsp+0xf0],r10
  20ab8e:	and    r10,0xfffffffffffffffc
  20ab92:	mov    QWORD PTR [rsp+0x28],r10
  20ab97:	xor    eax,eax
  20ab99:	test   r12,r12
  20ab9c:	setne  al
  20ab9f:	lea    rcx,[rax+0x1]
  20aba3:	cmp    r12,rax
  20aba6:	mov    QWORD PTR [rsp+0x98],rax
  20abae:	cmovbe rcx,rax
  20abb2:	lea    eax,[rcx*4+0x0]
  20abb9:	mov    QWORD PTR [rsp+0xa0],rax
  20abc1:	mov    ebx,r12d
  20abc4:	and    ebx,0x3
  20abc7:	mov    r13,r12
  20abca:	and    r13,0xfffffffffffffffc
  20abce:	mov    r11,r12
  20abd1:	shl    r11,0x5
  20abd5:	mov    QWORD PTR [rsp+0x108],rcx
  20abdd:	shl    ecx,0x5
  20abe0:	mov    QWORD PTR [rsp+0x110],rcx
  20abe8:	mov    rax,QWORD PTR [rsp+0xc0]
  20abf0:	lea    r10,[rax+rdi*8]
  20abf4:	mov    rax,QWORD PTR [rsp+0x40]
  20abf9:	lea    rcx,[rax+rdi*8]
  20abfd:	mov    QWORD PTR [rsp+0xa8],rcx
  20ac05:	mov    QWORD PTR [rsp+0xe0],rbx
  20ac0d:	shl    ebx,0x5
  20ac10:	mov    QWORD PTR [rsp+0x70],rax
  20ac15:	mov    QWORD PTR [rsp+0x68],0x0
  20ac1e:	mov    QWORD PTR [rsp+0x50],0x0
  20ac27:	xor    r14d,r14d
  20ac2a:	mov    QWORD PTR [rsp+0x60],rdi
  20ac2f:	mov    QWORD PTR [rsp+0x58],r12
  20ac34:	mov    QWORD PTR [rsp+0x20],r15
  20ac39:	mov    QWORD PTR [rsp+0x38],r13
  20ac3e:	mov    QWORD PTR [rsp+0xe8],rsi
  20ac46:	jmp    20ac98 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2f8>
  20ac48:	nop    DWORD PTR [rax+rax*1+0x0]
  20ac50:	inc    r14
  20ac53:	mov    rax,QWORD PTR [rsp+0x28]
  20ac58:	mov    rcx,QWORD PTR [rsp+0x78]
  20ac5d:	lea    rax,[rcx+rax*8]
  20ac61:	lea    rcx,[rip+0x2]        # 20ac6a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2ca>
  20ac68:	jmp    rbp
  20ac6a:	vmulpd ymm0,ymm2,ymm0
  20ac6e:	lea    rcx,[rip+0x3]        # 20ac78 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2d8>
  20ac75:	jmp    r15
  20ac78:	add    QWORD PTR [rsp+0x68],0x8
  20ac7e:	add    QWORD PTR [rsp+0x70],0x8
  20ac84:	add    r10,r8
  20ac87:	add    QWORD PTR [rsp+0xa8],r8
  20ac8f:	cmp    r14,rsi
  20ac92:	je     20aab9 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x119>
  20ac98:	test   r14,r14
  20ac9b:	mov    r15,rdi
  20ac9e:	cmove  r15,r14
  20aca2:	mov    rax,r14
  20aca5:	imul   rax,QWORD PTR [rsp+0x100]
  20acae:	mov    rcx,QWORD PTR [rsp+0x40]
  20acb3:	lea    r13,[rcx+r15*8]
  20acb7:	lea    rax,[rcx+rax*8]
  20acbb:	mov    QWORD PTR [rsp+0xb0],rax
  20acc3:	lea    rcx,[rax+rdi*8]
  20acc7:	cmp    QWORD PTR [rsp+0x108],r12
  20accf:	mov    QWORD PTR [rsp+0x30],r10
  20acd4:	mov    QWORD PTR [rsp+0x78],rcx
  20acd9:	jae    20ada0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x400>
  20acdf:	cmp    r12,QWORD PTR [rsp+0x98]
  20ace7:	jbe    20b28c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8ec>
  20aced:	vmovupd ymm11,YMMWORD PTR [rcx]
  20acf1:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20acf6:	mov    rax,QWORD PTR [rsp+0xa0]
  20acfe:	vmovupd ymm13,YMMWORD PTR [rcx+rax*8]
  20ad03:	mov    rax,QWORD PTR [rsp+0x28]
  20ad08:	lea    rax,[rcx+rax*8]
  20ad0c:	mov    rsi,rax
  20ad0f:	lea    rcx,[rip+0x2]        # 20ad18 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x378>
  20ad16:	jmp    rbp
  20ad18:	vmovapd ymm2,ymm0
  20ad1c:	test   r14,r14
  20ad1f:	je     20aef2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x552>
  20ad25:	mov    rdi,r14
  20ad28:	mov    r12,QWORD PTR [rsp+0x70]
  20ad2d:	mov    r10,r9
  20ad30:	mov    r15,QWORD PTR [rsp+0x20]
  20ad35:	jmp    20ad8c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3ec>
  20ad37:	nop    WORD PTR [rax+rax*1+0x0]
  20ad40:	vmulsd xmm0,xmm0,QWORD PTR [r12]
  20ad46:	vbroadcastsd ymm14,xmm0
  20ad4b:	lea    rax,[r11+r13*1]
  20ad4f:	vfmadd231pd ymm11,ymm14,YMMWORD PTR [r13+0x0]
  20ad55:	vfmadd231pd ymm12,ymm14,YMMWORD PTR [r13+0x20]
  20ad5b:	mov    rcx,QWORD PTR [rsp+0x110]
  20ad63:	vfmadd231pd ymm13,ymm14,YMMWORD PTR [r13+rcx*1+0x0]
  20ad6a:	lea    rcx,[rip+0x2]        # 20ad73 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3d3>
  20ad71:	jmp    rbp
  20ad73:	vfmadd231pd ymm2,ymm14,ymm0
  20ad78:	add    r10,QWORD PTR [rsp+0x48]
  20ad7d:	add    r12,r8
  20ad80:	add    r13,r8
  20ad83:	dec    rdi
  20ad86:	je     20ae50 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4b0>
  20ad8c:	vmovapd xmm0,xmm8
  20ad90:	test   dl,dl
  20ad92:	jne    20ad40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20ad94:	vmovsd xmm0,QWORD PTR [r10]
  20ad99:	vxorpd xmm0,xmm0,xmm7
  20ad9d:	jmp    20ad40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20ad9f:	nop
  20ada0:	test   r12,r12
  20ada3:	je     20ae64 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4c4>
  20ada9:	vmovupd ymm11,YMMWORD PTR [rcx]
  20adad:	cmp    r12,QWORD PTR [rsp+0x98]
  20adb5:	jbe    20af35 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x595>
  20adbb:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20adc0:	mov    rax,QWORD PTR [rsp+0x28]
  20adc5:	lea    rax,[rcx+rax*8]
  20adc9:	lea    rcx,[rip+0x2]        # 20add2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x432>
  20add0:	jmp    rbp
  20add2:	vmovapd ymm2,ymm0
  20add6:	test   r14,r14
  20add9:	je     20b015 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x675>
  20addf:	mov    QWORD PTR [rsp+0x10],rax
  20ade4:	lea    r10,[r11+r15*8]
  20ade8:	shl    r15,0x3
  20adec:	mov    r12,r14
  20adef:	mov    r13,QWORD PTR [rsp+0x40]
  20adf4:	mov    rsi,QWORD PTR [rsp+0x68]
  20adf9:	jmp    20ae3d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x49d>
  20adfb:	nop    DWORD PTR [rax+rax*1+0x0]
  20ae00:	vmulsd xmm0,xmm0,QWORD PTR [r13+rsi*1+0x0]
  20ae07:	vbroadcastsd ymm13,xmm0
  20ae0c:	vfmadd231pd ymm11,ymm13,YMMWORD PTR [r13+r15*1+0x0]
  20ae13:	vfmadd231pd ymm12,ymm13,YMMWORD PTR [r13+r15*1+0x20]
  20ae1a:	lea    rax,[r10+r13*1]
  20ae1e:	lea    rcx,[rip+0x2]        # 20ae27 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x487>
  20ae25:	jmp    rbp
  20ae27:	vfmadd231pd ymm2,ymm13,ymm0
  20ae2c:	add    r9,QWORD PTR [rsp+0x48]
  20ae31:	add    r13,r8
  20ae34:	dec    r12
  20ae37:	je     20aff3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x653>
  20ae3d:	vmovapd xmm0,xmm8
  20ae41:	test   dl,dl
  20ae43:	jne    20ae00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  20ae45:	vmovsd xmm0,QWORD PTR [r9]
  20ae4a:	vxorpd xmm0,xmm0,xmm7
  20ae4e:	jmp    20ae00 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  20ae50:	mov    rdi,QWORD PTR [rsp+0x60]
  20ae55:	mov    r12,QWORD PTR [rsp+0x58]
  20ae5a:	mov    r10,QWORD PTR [rsp+0x30]
  20ae5f:	jmp    20aef7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x557>
  20ae64:	mov    rax,QWORD PTR [rsp+0x28]
  20ae69:	lea    rax,[rcx+rax*8]
  20ae6d:	mov    QWORD PTR [rsp+0x10],rax
  20ae72:	lea    rcx,[rip+0x2]        # 20ae7b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4db>
  20ae79:	jmp    rbp
  20ae7b:	vmovapd ymm2,ymm0
  20ae7f:	test   r14,r14
  20ae82:	mov    r13,QWORD PTR [rsp+0x38]
  20ae87:	je     20afd6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x636>
  20ae8d:	lea    rdi,[r11+r15*8]
  20ae91:	mov    r12,r9
  20ae94:	mov    r9,r14
  20ae97:	mov    r10,QWORD PTR [rsp+0x40]
  20ae9c:	mov    rsi,QWORD PTR [rsp+0x68]
  20aea1:	jmp    20aede <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x53e>
  20aea3:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20aeb0:	vmulsd xmm0,xmm0,QWORD PTR [r10+rsi*1]
  20aeb6:	vbroadcastsd ymm11,xmm0
  20aebb:	lea    rax,[r10+rdi*1]
  20aebf:	lea    rcx,[rip+0x2]        # 20aec8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x528>
  20aec6:	jmp    rbp
  20aec8:	vfmadd231pd ymm2,ymm11,ymm0
  20aecd:	add    r12,QWORD PTR [rsp+0x48]
  20aed2:	add    r10,r8
  20aed5:	dec    r9
  20aed8:	je     20afb9 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x619>
  20aede:	vmovapd xmm0,xmm8
  20aee2:	test   dl,dl
  20aee4:	jne    20aeb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  20aee6:	vmovsd xmm0,QWORD PTR [r12]
  20aeec:	vxorpd xmm0,xmm0,xmm7
  20aef0:	jmp    20aeb0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  20aef2:	mov    r15,QWORD PTR [rsp+0x20]
  20aef7:	mov    rcx,QWORD PTR [rsp+0x78]
  20aefc:	vmovupd YMMWORD PTR [rcx],ymm11
  20af00:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20af05:	mov    rax,QWORD PTR [rsp+0xa0]
  20af0d:	vmovupd YMMWORD PTR [rcx+rax*8],ymm13
  20af12:	mov    rax,rsi
  20af15:	vmovapd ymm0,ymm2
  20af19:	lea    rcx,[rip+0x3]        # 20af23 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x583>
  20af20:	jmp    r15
  20af23:	mov    r13,QWORD PTR [rsp+0x38]
  20af28:	mov    rsi,QWORD PTR [rsp+0xe8]
  20af30:	jmp    20b073 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  20af35:	mov    rax,QWORD PTR [rsp+0x28]
  20af3a:	lea    rax,[rcx+rax*8]
  20af3e:	mov    QWORD PTR [rsp+0x10],rax
  20af43:	lea    rcx,[rip+0x2]        # 20af4c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ac>
  20af4a:	jmp    rbp
  20af4c:	vmovapd ymm2,ymm0
  20af50:	test   r14,r14
  20af53:	mov    r15,QWORD PTR [rsp+0x20]
  20af58:	je     20b04b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ab>
  20af5e:	mov    rsi,r14
  20af61:	mov    r10,r9
  20af64:	mov    r9,QWORD PTR [rsp+0x70]
  20af69:	jmp    20afa6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x606>
  20af6b:	nop    DWORD PTR [rax+rax*1+0x0]
  20af70:	vmulsd xmm0,xmm0,QWORD PTR [r9]
  20af75:	vbroadcastsd ymm12,xmm0
  20af7a:	lea    rax,[r11+r13*1]
  20af7e:	vfmadd231pd ymm11,ymm12,YMMWORD PTR [r13+0x0]
  20af84:	lea    rcx,[rip+0x2]        # 20af8d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ed>
  20af8b:	jmp    rbp
  20af8d:	vfmadd231pd ymm2,ymm12,ymm0
  20af92:	add    r10,QWORD PTR [rsp+0x48]
  20af97:	add    r9,r8
  20af9a:	add    r13,r8
  20af9d:	dec    rsi
  20afa0:	je     20b038 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x698>
  20afa6:	vmovapd xmm0,xmm8
  20afaa:	test   dl,dl
  20afac:	jne    20af70 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  20afae:	vmovsd xmm0,QWORD PTR [r10]
  20afb3:	vxorpd xmm0,xmm0,xmm7
  20afb7:	jmp    20af70 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  20afb9:	mov    rdi,QWORD PTR [rsp+0x60]
  20afbe:	mov    rax,QWORD PTR [rsp+0x8]
  20afc3:	lea    rsi,[rax+rdi*1]
  20afc7:	mov    r9,QWORD PTR [rsp+0x18]
  20afcc:	mov    r12,QWORD PTR [rsp+0x58]
  20afd1:	mov    r10,QWORD PTR [rsp+0x30]
  20afd6:	mov    rax,QWORD PTR [rsp+0x10]
  20afdb:	vmovapd ymm0,ymm2
  20afdf:	mov    r15,QWORD PTR [rsp+0x20]
  20afe4:	lea    rcx,[rip+0x3]        # 20afee <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x64e>
  20afeb:	jmp    r15
  20afee:	jmp    20b073 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  20aff3:	mov    rdi,QWORD PTR [rsp+0x60]
  20aff8:	mov    rax,QWORD PTR [rsp+0x8]
  20affd:	lea    rsi,[rax+rdi*1]
  20b001:	mov    r9,QWORD PTR [rsp+0x18]
  20b006:	mov    r12,QWORD PTR [rsp+0x58]
  20b00b:	mov    r10,QWORD PTR [rsp+0x30]
  20b010:	mov    rax,QWORD PTR [rsp+0x10]
  20b015:	mov    rcx,QWORD PTR [rsp+0x78]
  20b01a:	vmovupd YMMWORD PTR [rcx],ymm11
  20b01e:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20b023:	vmovapd ymm0,ymm2
  20b027:	mov    r15,QWORD PTR [rsp+0x20]
  20b02c:	lea    rcx,[rip+0x3]        # 20b036 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x696>
  20b033:	jmp    r15
  20b036:	jmp    20b06e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  20b038:	mov    rax,QWORD PTR [rsp+0x8]
  20b03d:	lea    rsi,[rax+rdi*1]
  20b041:	mov    r9,QWORD PTR [rsp+0x18]
  20b046:	mov    r10,QWORD PTR [rsp+0x30]
  20b04b:	mov    rax,QWORD PTR [rsp+0xb0]
  20b053:	lea    rax,[rax+rdi*8]
  20b057:	vmovupd YMMWORD PTR [rax],ymm11
  20b05b:	mov    rax,QWORD PTR [rsp+0x10]
  20b060:	vmovapd ymm0,ymm2
  20b064:	lea    rcx,[rip+0x3]        # 20b06e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  20b06b:	jmp    r15
  20b06e:	mov    r13,QWORD PTR [rsp+0x38]
  20b073:	mov    rcx,r14
  20b076:	imul   rcx,QWORD PTR [rsp+0xf8]
  20b07f:	mov    rax,r14
  20b082:	sub    rax,rdi
  20b085:	jae    20b0a0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x700>
  20b087:	vmovsd xmm0,QWORD PTR [r9+rcx*8]
  20b08d:	jmp    20b126 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x786>
  20b092:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20b0a0:	cmp    rax,QWORD PTR [rsp+0x8]
  20b0a5:	jae    20b2c2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x922>
  20b0ab:	mov    rax,QWORD PTR [rsp+0xb0]
  20b0b3:	vmovsd xmm0,QWORD PTR [rax+r14*8]
  20b0b9:	cmp    BYTE PTR [rsp+0x7],0x0
  20b0be:	je     20b0d7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x737>
  20b0c0:	test   dl,dl
  20b0c2:	je     20b1c8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x828>
  20b0c8:	vucomisd xmm3,xmm0
  20b0cc:	jb     20b0db <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x73b>
  20b0ce:	inc    QWORD PTR [rsp+0x50]
  20b0d3:	vmovapd xmm0,xmm4
  20b0d7:	test   dl,dl
  20b0d9:	je     20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b0db:	vucomisd xmm0,xmm10
  20b0e0:	jbe    20b265 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8c5>
  20b0e6:	vsqrtsd xmm0,xmm0,xmm0
  20b0ea:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  20b0f0:	vmovq  rax,xmm0
  20b0f5:	mov    cl,0x3f
  20b0f7:	bzhi   rax,rax,rcx
  20b0fc:	movabs rcx,0x7ff0000000000000
  20b106:	cmp    rax,rcx
  20b109:	setg   cl
  20b10c:	sete   r10b
  20b110:	test   rax,rax
  20b113:	sete   al
  20b116:	or     al,r10b
  20b119:	or     al,cl
  20b11b:	mov    r10,QWORD PTR [rsp+0x30]
  20b120:	jne    20b26b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8cb>
  20b126:	vdivsd xmm0,xmm9,xmm0
  20b12a:	vbroadcastsd ymm2,xmm0
  20b12f:	test   r12,r12
  20b132:	je     20ac50 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b138:	cmp    QWORD PTR [rsp+0xf0],0x10
  20b141:	jae    20b150 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7b0>
  20b143:	xor    eax,eax
  20b145:	jmp    20b1a2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x802>
  20b147:	nop    WORD PTR [rax+rax*1+0x0]
  20b150:	mov    rcx,r10
  20b153:	xor    eax,eax
  20b155:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  20b160:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  20b165:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  20b16a:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  20b16f:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  20b174:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  20b179:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  20b17e:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  20b182:	add    rax,0x4
  20b186:	vmovupd YMMWORD PTR [rcx],ymm0
  20b18a:	sub    rcx,0xffffffffffffff80
  20b18e:	cmp    r13,rax
  20b191:	jne    20b160 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7c0>
  20b193:	cmp    QWORD PTR [rsp+0xe0],0x0
  20b19c:	je     20ac50 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b1a2:	shl    rax,0x5
  20b1a6:	add    rax,QWORD PTR [rsp+0xa8]
  20b1ae:	xor    ecx,ecx
  20b1b0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  20b1b5:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20b1ba:	add    rcx,0x20
  20b1be:	cmp    rbx,rcx
  20b1c1:	jne    20b1b0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x810>
  20b1c3:	jmp    20ac50 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b1c8:	mov    rax,QWORD PTR [rsp+0x90]
  20b1d0:	test   rax,rax
  20b1d3:	je     20b215 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x875>
  20b1d5:	movzx  r9d,BYTE PTR [rax+r14*1]
  20b1da:	vucomisd xmm3,xmm0
  20b1de:	setae  al
  20b1e1:	vucomisd xmm0,xmm5
  20b1e5:	setae  r10b
  20b1e9:	cmp    r9d,0xff
  20b1f0:	je     20b244 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8a4>
  20b1f2:	cmp    r9d,0x1
  20b1f6:	mov    rsi,QWORD PTR [rsp+0x8]
  20b1fb:	lea    rsi,[rsi+rdi*1]
  20b1ff:	mov    r9,QWORD PTR [rsp+0x18]
  20b204:	jne    20b224 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x884>
  20b206:	vucomisd xmm3,xmm0
  20b20a:	jae    20b0ce <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x72e>
  20b210:	jmp    20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b215:	vucomisd xmm3,xmm0
  20b219:	setae  al
  20b21c:	vucomisd xmm0,xmm5
  20b220:	setae  r10b
  20b224:	test   r10b,r10b
  20b227:	je     20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b22d:	test   al,al
  20b22f:	je     20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b235:	vucomisd xmm10,xmm0
  20b239:	ja     20b25c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8bc>
  20b23b:	vmovapd xmm0,xmm4
  20b23f:	jmp    20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b244:	vucomisd xmm0,xmm5
  20b248:	mov    rax,QWORD PTR [rsp+0x8]
  20b24d:	lea    rsi,[rax+rdi*1]
  20b251:	mov    r9,QWORD PTR [rsp+0x18]
  20b256:	jb     20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b25c:	vmovapd xmm0,xmm6
  20b260:	jmp    20b0ea <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b265:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  20b26b:	mov    eax,0x1
  20b270:	mov    rdx,r14
  20b273:	add    rsp,0x118
  20b27a:	pop    rbx
  20b27b:	pop    r12
  20b27d:	pop    r13
  20b27f:	pop    r14
  20b281:	pop    r15
  20b283:	pop    rbp
  20b284:	vzeroupper
  20b287:	ret
  20b288:	xor    eax,eax
  20b28a:	jmp    20b270 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20b28c:	lea    rdi,[rip+0xffffffffffe3bd55]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  20b293:	lea    rdx,[rip+0x330b66]        # 53be00 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xd8>
  20b29a:	mov    esi,0x28
  20b29f:	vzeroupper
  20b2a2:	call   QWORD PTR [rip+0x33ef68]        # 54a210 <_DYNAMIC+0x438>
  20b2a8:	lea    rcx,[rip+0x330c71]        # 53bf20 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1f8>
  20b2af:	xor    edi,edi
  20b2b1:	mov    rdx,QWORD PTR [rsp+0x88]
  20b2b9:	vzeroupper
  20b2bc:	call   QWORD PTR [rip+0x33ee16]        # 54a0d8 <_DYNAMIC+0x300>
  20b2c2:	lea    r10,[rip+0x330b4f]        # 53be18 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xf0>
  20b2c9:	lea    r11,[rip+0xffffffffffe34700]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b2d0:	lea    rbx,[rip+0x330619]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  20b2d7:	lea    r14,[rip+0x331022]        # 53c300 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270>
  20b2de:	movabs rcx,0x7fffffffffffffff
  20b2e8:	mov    r8d,0x1
  20b2ee:	mov    r9d,0x1
  20b2f4:	mov    rdi,rax
  20b2f7:	mov    rsi,rax
  20b2fa:	mov    rdx,QWORD PTR [rsp+0x8]
  20b2ff:	push   r10
  20b301:	push   r11
  20b303:	push   rbx
  20b304:	push   r14
  20b306:	vzeroupper
  20b309:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  20b30e:	lea    rax,[rip+0x330abb]        # 53bdd0 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xa8>
  20b315:	lea    r10,[rip+0xffffffffffe346b4]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b31c:	lea    r11,[rip+0x330575]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20b323:	lea    rbx,[rip+0x3307de]        # 53bb08 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x218>
  20b32a:	mov    r8d,0x1
  20b330:	mov    rdi,rsi
  20b333:	mov    r9d,0x1
  20b339:	mov    rdx,QWORD PTR [rsp+0xb8]
  20b341:	jmp    20b3b4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0xa14>
  20b343:	sub    rsp,0x8
  20b347:	lea    rax,[rip+0x33071a]        # 53ba68 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x178>
  20b34e:	lea    rcx,[rip+0x3306cb]        # 53ba20 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x130>
  20b355:	lea    r8,[rip+0x330524]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  20b35c:	mov    rdi,rsi
  20b35f:	lea    r9,[rip+0xffffffffffe3466a]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b366:	mov    edx,0x1
  20b36b:	mov    rsi,QWORD PTR [rsp+0x88]
  20b373:	push   rax
  20b374:	vzeroupper
  20b377:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  20b37c:	lea    rax,[rip+0x330a65]        # 53bde8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xc0>
  20b383:	lea    r10,[rip+0xffffffffffe34646]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b38a:	lea    r11,[rip+0x330507]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20b391:	lea    rbx,[rip+0x330fe8]        # 53c380 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x80>
  20b398:	movabs rcx,0x7fffffffffffffff
  20b3a2:	mov    r8d,0x1
  20b3a8:	mov    rdx,rsi
  20b3ab:	mov    r9d,0x1
  20b3b1:	mov    rsi,rdi
  20b3b4:	push   rax
  20b3b5:	push   r10
  20b3b7:	push   r11
  20b3b9:	push   rbx
  20b3ba:	vzeroupper
  20b3bd:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
