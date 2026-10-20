
/home/shinaoka/projects/tensor4all/faer-benchmark/target/faer-rev/2240b076a030-mkl/release/fbench:     file format elf64-x86-64


Disassembly of section .text:

000000000020a990 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench>:
  20a990:	push   rbp
  20a991:	push   r15
  20a993:	push   r14
  20a995:	push   r13
  20a997:	push   r12
  20a999:	push   rbx
  20a99a:	sub    rsp,0x118
  20a9a1:	mov    rax,QWORD PTR [rdi+0x8]
  20a9a5:	test   rax,rax
  20a9a8:	je     20aa95 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20a9ae:	mov    rcx,QWORD PTR [rdi+0x10]
  20a9b2:	cmp    rax,rcx
  20a9b5:	mov    rdx,rcx
  20a9b8:	cmovb  rdx,rax
  20a9bc:	mov    QWORD PTR [rsp+0xd0],rdx
  20a9c4:	test   rcx,rcx
  20a9c7:	je     20aa95 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x105>
  20a9cd:	mov    QWORD PTR [rsp+0xb8],rax
  20a9d5:	mov    r9,QWORD PTR [rdi+0x40]
  20a9d9:	mov    rax,QWORD PTR [rdi+0x48]
  20a9dd:	mov    QWORD PTR [rsp+0x80],rax
  20a9e5:	mov    rsi,QWORD PTR [rdi+0x50]
  20a9e9:	vmovsd xmm3,QWORD PTR [rdi+0x30]
  20a9ee:	vmovsd xmm4,QWORD PTR [rdi+0x38]
  20a9f3:	mov    r10,QWORD PTR [rdi+0x20]
  20a9f7:	mov    rax,QWORD PTR [rdi+0x28]
  20a9fb:	mov    QWORD PTR [rsp+0x88],rax
  20aa03:	movzx  eax,BYTE PTR [rdi+0x59]
  20aa07:	mov    BYTE PTR [rsp+0x7],al
  20aa0b:	movzx  edx,BYTE PTR [rdi+0x58]
  20aa0f:	mov    rax,QWORD PTR [rdi]
  20aa12:	mov    rdi,QWORD PTR [rdi+0x18]
  20aa16:	vmovddup xmm0,QWORD PTR [rip+0xffffffffffe35102]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20aa1e:	vxorpd xmm5,xmm3,xmm0
  20aa22:	vxorpd xmm6,xmm4,xmm0
  20aa26:	mov    QWORD PTR [rsp+0xf8],rsi
  20aa2e:	lea    rsi,[rsi*8+0x0]
  20aa36:	mov    QWORD PTR [rsp+0x48],rsi
  20aa3b:	mov    QWORD PTR [rsp+0x100],rdi
  20aa43:	lea    r8,[rdi*8+0x0]
  20aa4b:	mov    QWORD PTR [rsp+0x40],rax
  20aa50:	add    rax,0x60
  20aa54:	mov    QWORD PTR [rsp+0xc0],rax
  20aa5c:	vmovddup xmm7,QWORD PTR [rip+0xffffffffffe350bc]        # 3fb20 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x150>
  20aa64:	vmovsd xmm8,QWORD PTR [rip+0xffffffffffe34ff4]        # 3fa60 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0x90>
  20aa6c:	vmovsd xmm9,QWORD PTR [rip+0xffffffffffe35054]        # 3fac8 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867+0xf8>
  20aa74:	vxorpd xmm10,xmm10,xmm10
  20aa79:	xor    r14d,r14d
  20aa7c:	xor    edi,edi
  20aa7e:	mov    QWORD PTR [rsp+0x18],r9
  20aa83:	mov    QWORD PTR [rsp+0xc8],rcx
  20aa8b:	mov    QWORD PTR [rsp+0x90],r10
  20aa93:	jmp    20aad2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x142>
  20aa95:	xor    r14d,r14d
  20aa98:	xor    eax,eax
  20aa9a:	jmp    20b260 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20aa9f:	nop
  20aaa0:	mov    QWORD PTR [rsp+0x50],0x0
  20aaa9:	mov    r14,QWORD PTR [rsp+0xd8]
  20aab1:	add    r14,QWORD PTR [rsp+0x50]
  20aab6:	mov    rdi,rsi
  20aab9:	mov    rcx,QWORD PTR [rsp+0xc8]
  20aac1:	cmp    rsi,rcx
  20aac4:	mov    r10,QWORD PTR [rsp+0x90]
  20aacc:	jae    20b278 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8e8>
  20aad2:	mov    rsi,rcx
  20aad5:	sub    rsi,rdi
  20aad8:	cmp    rsi,0x10
  20aadc:	mov    eax,0x10
  20aae1:	cmovae rsi,rax
  20aae5:	mov    QWORD PTR [rsp+0x8],rsi
  20aaea:	add    rsi,rdi
  20aaed:	cmp    rsi,QWORD PTR [rsp+0xd0]
  20aaf5:	ja     20b2fe <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x96e>
  20aafb:	cmp    rsi,QWORD PTR [rsp+0x80]
  20ab03:	ja     20b333 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9a3>
  20ab09:	cmp    rsi,QWORD PTR [rsp+0x88]
  20ab11:	seta   al
  20ab14:	test   r10,r10
  20ab17:	jne    20ab1b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x18b>
  20ab19:	xor    eax,eax
  20ab1b:	test   al,al
  20ab1d:	jne    20b298 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x908>
  20ab23:	test   rdi,rdi
  20ab26:	js     20b36c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  20ab2c:	cmp    rdi,rsi
  20ab2f:	ja     20b36c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x9dc>
  20ab35:	mov    QWORD PTR [rsp+0xd8],r14
  20ab3d:	test   rsi,rsi
  20ab40:	je     20aaa0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x110>
  20ab46:	mov    rax,QWORD PTR [rsp+0x8]
  20ab4b:	lea    r10,[rax-0x1]
  20ab4f:	mov    r12,r10
  20ab52:	shr    r12,0x2
  20ab56:	mov    eax,r10d
  20ab59:	and    eax,0x3
  20ab5c:	shl    eax,0x9
  20ab5f:	mov    rcx,QWORD PTR [rip+0x33f65a]        # 54a1c0 <_DYNAMIC+0x3e8>
  20ab66:	mov    rbp,QWORD PTR [rcx+rax*1+0x200]
  20ab6e:	mov    r15,QWORD PTR [rcx+rax*1+0x208]
  20ab76:	mov    QWORD PTR [rsp+0xf0],r10
  20ab7e:	and    r10,0xfffffffffffffffc
  20ab82:	mov    QWORD PTR [rsp+0x28],r10
  20ab87:	xor    eax,eax
  20ab89:	test   r12,r12
  20ab8c:	setne  al
  20ab8f:	lea    rcx,[rax+0x1]
  20ab93:	cmp    r12,rax
  20ab96:	mov    QWORD PTR [rsp+0x98],rax
  20ab9e:	cmovbe rcx,rax
  20aba2:	lea    eax,[rcx*4+0x0]
  20aba9:	mov    QWORD PTR [rsp+0xa0],rax
  20abb1:	mov    ebx,r12d
  20abb4:	and    ebx,0x3
  20abb7:	mov    r13,r12
  20abba:	and    r13,0xfffffffffffffffc
  20abbe:	mov    r11,r12
  20abc1:	shl    r11,0x5
  20abc5:	mov    QWORD PTR [rsp+0x108],rcx
  20abcd:	shl    ecx,0x5
  20abd0:	mov    QWORD PTR [rsp+0x110],rcx
  20abd8:	mov    rax,QWORD PTR [rsp+0xc0]
  20abe0:	lea    r10,[rax+rdi*8]
  20abe4:	mov    rax,QWORD PTR [rsp+0x40]
  20abe9:	lea    rcx,[rax+rdi*8]
  20abed:	mov    QWORD PTR [rsp+0xa8],rcx
  20abf5:	mov    QWORD PTR [rsp+0xe0],rbx
  20abfd:	shl    ebx,0x5
  20ac00:	mov    QWORD PTR [rsp+0x70],rax
  20ac05:	mov    QWORD PTR [rsp+0x68],0x0
  20ac0e:	mov    QWORD PTR [rsp+0x50],0x0
  20ac17:	xor    r14d,r14d
  20ac1a:	mov    QWORD PTR [rsp+0x60],rdi
  20ac1f:	mov    QWORD PTR [rsp+0x58],r12
  20ac24:	mov    QWORD PTR [rsp+0x20],r15
  20ac29:	mov    QWORD PTR [rsp+0x38],r13
  20ac2e:	mov    QWORD PTR [rsp+0xe8],rsi
  20ac36:	jmp    20ac88 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2f8>
  20ac38:	nop    DWORD PTR [rax+rax*1+0x0]
  20ac40:	inc    r14
  20ac43:	mov    rax,QWORD PTR [rsp+0x28]
  20ac48:	mov    rcx,QWORD PTR [rsp+0x78]
  20ac4d:	lea    rax,[rcx+rax*8]
  20ac51:	lea    rcx,[rip+0x2]        # 20ac5a <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2ca>
  20ac58:	jmp    rbp
  20ac5a:	vmulpd ymm0,ymm2,ymm0
  20ac5e:	lea    rcx,[rip+0x3]        # 20ac68 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2d8>
  20ac65:	jmp    r15
  20ac68:	add    QWORD PTR [rsp+0x68],0x8
  20ac6e:	add    QWORD PTR [rsp+0x70],0x8
  20ac74:	add    r10,r8
  20ac77:	add    QWORD PTR [rsp+0xa8],r8
  20ac7f:	cmp    r14,rsi
  20ac82:	je     20aaa9 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x119>
  20ac88:	test   r14,r14
  20ac8b:	mov    r15,rdi
  20ac8e:	cmove  r15,r14
  20ac92:	mov    rax,r14
  20ac95:	imul   rax,QWORD PTR [rsp+0x100]
  20ac9e:	mov    rcx,QWORD PTR [rsp+0x40]
  20aca3:	lea    r13,[rcx+r15*8]
  20aca7:	lea    rax,[rcx+rax*8]
  20acab:	mov    QWORD PTR [rsp+0xb0],rax
  20acb3:	lea    rcx,[rax+rdi*8]
  20acb7:	cmp    QWORD PTR [rsp+0x108],r12
  20acbf:	mov    QWORD PTR [rsp+0x30],r10
  20acc4:	mov    QWORD PTR [rsp+0x78],rcx
  20acc9:	jae    20ad90 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x400>
  20accf:	cmp    r12,QWORD PTR [rsp+0x98]
  20acd7:	jbe    20b27c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8ec>
  20acdd:	vmovupd ymm11,YMMWORD PTR [rcx]
  20ace1:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20ace6:	mov    rax,QWORD PTR [rsp+0xa0]
  20acee:	vmovupd ymm13,YMMWORD PTR [rcx+rax*8]
  20acf3:	mov    rax,QWORD PTR [rsp+0x28]
  20acf8:	lea    rax,[rcx+rax*8]
  20acfc:	mov    rsi,rax
  20acff:	lea    rcx,[rip+0x2]        # 20ad08 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x378>
  20ad06:	jmp    rbp
  20ad08:	vmovapd ymm2,ymm0
  20ad0c:	test   r14,r14
  20ad0f:	je     20aee2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x552>
  20ad15:	mov    rdi,r14
  20ad18:	mov    r12,QWORD PTR [rsp+0x70]
  20ad1d:	mov    r10,r9
  20ad20:	mov    r15,QWORD PTR [rsp+0x20]
  20ad25:	jmp    20ad7c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3ec>
  20ad27:	nop    WORD PTR [rax+rax*1+0x0]
  20ad30:	vmulsd xmm0,xmm0,QWORD PTR [r12]
  20ad36:	vbroadcastsd ymm14,xmm0
  20ad3b:	lea    rax,[r11+r13*1]
  20ad3f:	vfmadd231pd ymm11,ymm14,YMMWORD PTR [r13+0x0]
  20ad45:	vfmadd231pd ymm12,ymm14,YMMWORD PTR [r13+0x20]
  20ad4b:	mov    rcx,QWORD PTR [rsp+0x110]
  20ad53:	vfmadd231pd ymm13,ymm14,YMMWORD PTR [r13+rcx*1+0x0]
  20ad5a:	lea    rcx,[rip+0x2]        # 20ad63 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3d3>
  20ad61:	jmp    rbp
  20ad63:	vfmadd231pd ymm2,ymm14,ymm0
  20ad68:	add    r10,QWORD PTR [rsp+0x48]
  20ad6d:	add    r12,r8
  20ad70:	add    r13,r8
  20ad73:	dec    rdi
  20ad76:	je     20ae40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4b0>
  20ad7c:	vmovapd xmm0,xmm8
  20ad80:	test   dl,dl
  20ad82:	jne    20ad30 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20ad84:	vmovsd xmm0,QWORD PTR [r10]
  20ad89:	vxorpd xmm0,xmm0,xmm7
  20ad8d:	jmp    20ad30 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x3a0>
  20ad8f:	nop
  20ad90:	test   r12,r12
  20ad93:	je     20ae54 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4c4>
  20ad99:	vmovupd ymm11,YMMWORD PTR [rcx]
  20ad9d:	cmp    r12,QWORD PTR [rsp+0x98]
  20ada5:	jbe    20af25 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x595>
  20adab:	vmovupd ymm12,YMMWORD PTR [rcx+0x20]
  20adb0:	mov    rax,QWORD PTR [rsp+0x28]
  20adb5:	lea    rax,[rcx+rax*8]
  20adb9:	lea    rcx,[rip+0x2]        # 20adc2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x432>
  20adc0:	jmp    rbp
  20adc2:	vmovapd ymm2,ymm0
  20adc6:	test   r14,r14
  20adc9:	je     20b005 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x675>
  20adcf:	mov    QWORD PTR [rsp+0x10],rax
  20add4:	lea    r10,[r11+r15*8]
  20add8:	shl    r15,0x3
  20addc:	mov    r12,r14
  20addf:	mov    r13,QWORD PTR [rsp+0x40]
  20ade4:	mov    rsi,QWORD PTR [rsp+0x68]
  20ade9:	jmp    20ae2d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x49d>
  20adeb:	nop    DWORD PTR [rax+rax*1+0x0]
  20adf0:	vmulsd xmm0,xmm0,QWORD PTR [r13+rsi*1+0x0]
  20adf7:	vbroadcastsd ymm13,xmm0
  20adfc:	vfmadd231pd ymm11,ymm13,YMMWORD PTR [r13+r15*1+0x0]
  20ae03:	vfmadd231pd ymm12,ymm13,YMMWORD PTR [r13+r15*1+0x20]
  20ae0a:	lea    rax,[r10+r13*1]
  20ae0e:	lea    rcx,[rip+0x2]        # 20ae17 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x487>
  20ae15:	jmp    rbp
  20ae17:	vfmadd231pd ymm2,ymm13,ymm0
  20ae1c:	add    r9,QWORD PTR [rsp+0x48]
  20ae21:	add    r13,r8
  20ae24:	dec    r12
  20ae27:	je     20afe3 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x653>
  20ae2d:	vmovapd xmm0,xmm8
  20ae31:	test   dl,dl
  20ae33:	jne    20adf0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  20ae35:	vmovsd xmm0,QWORD PTR [r9]
  20ae3a:	vxorpd xmm0,xmm0,xmm7
  20ae3e:	jmp    20adf0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x460>
  20ae40:	mov    rdi,QWORD PTR [rsp+0x60]
  20ae45:	mov    r12,QWORD PTR [rsp+0x58]
  20ae4a:	mov    r10,QWORD PTR [rsp+0x30]
  20ae4f:	jmp    20aee7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x557>
  20ae54:	mov    rax,QWORD PTR [rsp+0x28]
  20ae59:	lea    rax,[rcx+rax*8]
  20ae5d:	mov    QWORD PTR [rsp+0x10],rax
  20ae62:	lea    rcx,[rip+0x2]        # 20ae6b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x4db>
  20ae69:	jmp    rbp
  20ae6b:	vmovapd ymm2,ymm0
  20ae6f:	test   r14,r14
  20ae72:	mov    r13,QWORD PTR [rsp+0x38]
  20ae77:	je     20afc6 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x636>
  20ae7d:	lea    rdi,[r11+r15*8]
  20ae81:	mov    r12,r9
  20ae84:	mov    r9,r14
  20ae87:	mov    r10,QWORD PTR [rsp+0x40]
  20ae8c:	mov    rsi,QWORD PTR [rsp+0x68]
  20ae91:	jmp    20aece <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x53e>
  20ae93:	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20aea0:	vmulsd xmm0,xmm0,QWORD PTR [r10+rsi*1]
  20aea6:	vbroadcastsd ymm11,xmm0
  20aeab:	lea    rax,[r10+rdi*1]
  20aeaf:	lea    rcx,[rip+0x2]        # 20aeb8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x528>
  20aeb6:	jmp    rbp
  20aeb8:	vfmadd231pd ymm2,ymm11,ymm0
  20aebd:	add    r12,QWORD PTR [rsp+0x48]
  20aec2:	add    r10,r8
  20aec5:	dec    r9
  20aec8:	je     20afa9 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x619>
  20aece:	vmovapd xmm0,xmm8
  20aed2:	test   dl,dl
  20aed4:	jne    20aea0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  20aed6:	vmovsd xmm0,QWORD PTR [r12]
  20aedc:	vxorpd xmm0,xmm0,xmm7
  20aee0:	jmp    20aea0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x510>
  20aee2:	mov    r15,QWORD PTR [rsp+0x20]
  20aee7:	mov    rcx,QWORD PTR [rsp+0x78]
  20aeec:	vmovupd YMMWORD PTR [rcx],ymm11
  20aef0:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20aef5:	mov    rax,QWORD PTR [rsp+0xa0]
  20aefd:	vmovupd YMMWORD PTR [rcx+rax*8],ymm13
  20af02:	mov    rax,rsi
  20af05:	vmovapd ymm0,ymm2
  20af09:	lea    rcx,[rip+0x3]        # 20af13 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x583>
  20af10:	jmp    r15
  20af13:	mov    r13,QWORD PTR [rsp+0x38]
  20af18:	mov    rsi,QWORD PTR [rsp+0xe8]
  20af20:	jmp    20b063 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  20af25:	mov    rax,QWORD PTR [rsp+0x28]
  20af2a:	lea    rax,[rcx+rax*8]
  20af2e:	mov    QWORD PTR [rsp+0x10],rax
  20af33:	lea    rcx,[rip+0x2]        # 20af3c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ac>
  20af3a:	jmp    rbp
  20af3c:	vmovapd ymm2,ymm0
  20af40:	test   r14,r14
  20af43:	mov    r15,QWORD PTR [rsp+0x20]
  20af48:	je     20b03b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ab>
  20af4e:	mov    rsi,r14
  20af51:	mov    r10,r9
  20af54:	mov    r9,QWORD PTR [rsp+0x70]
  20af59:	jmp    20af96 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x606>
  20af5b:	nop    DWORD PTR [rax+rax*1+0x0]
  20af60:	vmulsd xmm0,xmm0,QWORD PTR [r9]
  20af65:	vbroadcastsd ymm12,xmm0
  20af6a:	lea    rax,[r11+r13*1]
  20af6e:	vfmadd231pd ymm11,ymm12,YMMWORD PTR [r13+0x0]
  20af74:	lea    rcx,[rip+0x2]        # 20af7d <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5ed>
  20af7b:	jmp    rbp
  20af7d:	vfmadd231pd ymm2,ymm12,ymm0
  20af82:	add    r10,QWORD PTR [rsp+0x48]
  20af87:	add    r9,r8
  20af8a:	add    r13,r8
  20af8d:	dec    rsi
  20af90:	je     20b028 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x698>
  20af96:	vmovapd xmm0,xmm8
  20af9a:	test   dl,dl
  20af9c:	jne    20af60 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  20af9e:	vmovsd xmm0,QWORD PTR [r10]
  20afa3:	vxorpd xmm0,xmm0,xmm7
  20afa7:	jmp    20af60 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x5d0>
  20afa9:	mov    rdi,QWORD PTR [rsp+0x60]
  20afae:	mov    rax,QWORD PTR [rsp+0x8]
  20afb3:	lea    rsi,[rax+rdi*1]
  20afb7:	mov    r9,QWORD PTR [rsp+0x18]
  20afbc:	mov    r12,QWORD PTR [rsp+0x58]
  20afc1:	mov    r10,QWORD PTR [rsp+0x30]
  20afc6:	mov    rax,QWORD PTR [rsp+0x10]
  20afcb:	vmovapd ymm0,ymm2
  20afcf:	mov    r15,QWORD PTR [rsp+0x20]
  20afd4:	lea    rcx,[rip+0x3]        # 20afde <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x64e>
  20afdb:	jmp    r15
  20afde:	jmp    20b063 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6d3>
  20afe3:	mov    rdi,QWORD PTR [rsp+0x60]
  20afe8:	mov    rax,QWORD PTR [rsp+0x8]
  20afed:	lea    rsi,[rax+rdi*1]
  20aff1:	mov    r9,QWORD PTR [rsp+0x18]
  20aff6:	mov    r12,QWORD PTR [rsp+0x58]
  20affb:	mov    r10,QWORD PTR [rsp+0x30]
  20b000:	mov    rax,QWORD PTR [rsp+0x10]
  20b005:	mov    rcx,QWORD PTR [rsp+0x78]
  20b00a:	vmovupd YMMWORD PTR [rcx],ymm11
  20b00e:	vmovupd YMMWORD PTR [rcx+0x20],ymm12
  20b013:	vmovapd ymm0,ymm2
  20b017:	mov    r15,QWORD PTR [rsp+0x20]
  20b01c:	lea    rcx,[rip+0x3]        # 20b026 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x696>
  20b023:	jmp    r15
  20b026:	jmp    20b05e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  20b028:	mov    rax,QWORD PTR [rsp+0x8]
  20b02d:	lea    rsi,[rax+rdi*1]
  20b031:	mov    r9,QWORD PTR [rsp+0x18]
  20b036:	mov    r10,QWORD PTR [rsp+0x30]
  20b03b:	mov    rax,QWORD PTR [rsp+0xb0]
  20b043:	lea    rax,[rax+rdi*8]
  20b047:	vmovupd YMMWORD PTR [rax],ymm11
  20b04b:	mov    rax,QWORD PTR [rsp+0x10]
  20b050:	vmovapd ymm0,ymm2
  20b054:	lea    rcx,[rip+0x3]        # 20b05e <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x6ce>
  20b05b:	jmp    r15
  20b05e:	mov    r13,QWORD PTR [rsp+0x38]
  20b063:	mov    rcx,r14
  20b066:	imul   rcx,QWORD PTR [rsp+0xf8]
  20b06f:	mov    rax,r14
  20b072:	sub    rax,rdi
  20b075:	jae    20b090 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x700>
  20b077:	vmovsd xmm0,QWORD PTR [r9+rcx*8]
  20b07d:	jmp    20b116 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x786>
  20b082:	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  20b090:	cmp    rax,QWORD PTR [rsp+0x8]
  20b095:	jae    20b2b2 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x922>
  20b09b:	mov    rax,QWORD PTR [rsp+0xb0]
  20b0a3:	vmovsd xmm0,QWORD PTR [rax+r14*8]
  20b0a9:	cmp    BYTE PTR [rsp+0x7],0x0
  20b0ae:	je     20b0c7 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x737>
  20b0b0:	test   dl,dl
  20b0b2:	je     20b1b8 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x828>
  20b0b8:	vucomisd xmm3,xmm0
  20b0bc:	jb     20b0cb <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x73b>
  20b0be:	inc    QWORD PTR [rsp+0x50]
  20b0c3:	vmovapd xmm0,xmm4
  20b0c7:	test   dl,dl
  20b0c9:	je     20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b0cb:	vucomisd xmm0,xmm10
  20b0d0:	jbe    20b255 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8c5>
  20b0d6:	vsqrtsd xmm0,xmm0,xmm0
  20b0da:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  20b0e0:	vmovq  rax,xmm0
  20b0e5:	mov    cl,0x3f
  20b0e7:	bzhi   rax,rax,rcx
  20b0ec:	movabs rcx,0x7ff0000000000000
  20b0f6:	cmp    rax,rcx
  20b0f9:	setg   cl
  20b0fc:	sete   r10b
  20b100:	test   rax,rax
  20b103:	sete   al
  20b106:	or     al,r10b
  20b109:	or     al,cl
  20b10b:	mov    r10,QWORD PTR [rsp+0x30]
  20b110:	jne    20b25b <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8cb>
  20b116:	vdivsd xmm0,xmm9,xmm0
  20b11a:	vbroadcastsd ymm2,xmm0
  20b11f:	test   r12,r12
  20b122:	je     20ac40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b128:	cmp    QWORD PTR [rsp+0xf0],0x10
  20b131:	jae    20b140 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7b0>
  20b133:	xor    eax,eax
  20b135:	jmp    20b192 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x802>
  20b137:	nop    WORD PTR [rax+rax*1+0x0]
  20b140:	mov    rcx,r10
  20b143:	xor    eax,eax
  20b145:	data16 cs nop WORD PTR [rax+rax*1+0x0]
  20b150:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x60]
  20b155:	vmovupd YMMWORD PTR [rcx-0x60],ymm0
  20b15a:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x40]
  20b15f:	vmovupd YMMWORD PTR [rcx-0x40],ymm0
  20b164:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx-0x20]
  20b169:	vmovupd YMMWORD PTR [rcx-0x20],ymm0
  20b16e:	vmulpd ymm0,ymm2,YMMWORD PTR [rcx]
  20b172:	add    rax,0x4
  20b176:	vmovupd YMMWORD PTR [rcx],ymm0
  20b17a:	sub    rcx,0xffffffffffffff80
  20b17e:	cmp    r13,rax
  20b181:	jne    20b150 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x7c0>
  20b183:	cmp    QWORD PTR [rsp+0xe0],0x0
  20b18c:	je     20ac40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b192:	shl    rax,0x5
  20b196:	add    rax,QWORD PTR [rsp+0xa8]
  20b19e:	xor    ecx,ecx
  20b1a0:	vmulpd ymm0,ymm2,YMMWORD PTR [rax+rcx*1]
  20b1a5:	vmovupd YMMWORD PTR [rax+rcx*1],ymm0
  20b1aa:	add    rcx,0x20
  20b1ae:	cmp    rbx,rcx
  20b1b1:	jne    20b1a0 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x810>
  20b1b3:	jmp    20ac40 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x2b0>
  20b1b8:	mov    rax,QWORD PTR [rsp+0x90]
  20b1c0:	test   rax,rax
  20b1c3:	je     20b205 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x875>
  20b1c5:	movzx  r9d,BYTE PTR [rax+r14*1]
  20b1ca:	vucomisd xmm3,xmm0
  20b1ce:	setae  al
  20b1d1:	vucomisd xmm0,xmm5
  20b1d5:	setae  r10b
  20b1d9:	cmp    r9d,0xff
  20b1e0:	je     20b234 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8a4>
  20b1e2:	cmp    r9d,0x1
  20b1e6:	mov    rsi,QWORD PTR [rsp+0x8]
  20b1eb:	lea    rsi,[rsi+rdi*1]
  20b1ef:	mov    r9,QWORD PTR [rsp+0x18]
  20b1f4:	jne    20b214 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x884>
  20b1f6:	vucomisd xmm3,xmm0
  20b1fa:	jae    20b0be <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x72e>
  20b200:	jmp    20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b205:	vucomisd xmm3,xmm0
  20b209:	setae  al
  20b20c:	vucomisd xmm0,xmm5
  20b210:	setae  r10b
  20b214:	test   r10b,r10b
  20b217:	je     20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b21d:	test   al,al
  20b21f:	je     20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b225:	vucomisd xmm10,xmm0
  20b229:	ja     20b24c <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8bc>
  20b22b:	vmovapd xmm0,xmm4
  20b22f:	jmp    20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b234:	vucomisd xmm0,xmm5
  20b238:	mov    rax,QWORD PTR [rsp+0x8]
  20b23d:	lea    rsi,[rax+rdi*1]
  20b241:	mov    r9,QWORD PTR [rsp+0x18]
  20b246:	jb     20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b24c:	vmovapd xmm0,xmm6
  20b250:	jmp    20b0da <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x74a>
  20b255:	vmovsd QWORD PTR [r9+rcx*8],xmm0
  20b25b:	mov    eax,0x1
  20b260:	mov    rdx,r14
  20b263:	add    rsp,0x118
  20b26a:	pop    rbx
  20b26b:	pop    r12
  20b26d:	pop    r13
  20b26f:	pop    r14
  20b271:	pop    r15
  20b273:	pop    rbp
  20b274:	vzeroupper
  20b277:	ret
  20b278:	xor    eax,eax
  20b27a:	jmp    20b260 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0x8d0>
  20b27c:	lea    rdi,[rip+0xffffffffffe3bd65]        # 46fe8 <anon.c38c26bc52a245a79a4d978676f36d04.41.llvm.17936451394092910270+0x2b>
  20b283:	lea    rdx,[rip+0x330b76]        # 53be00 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xd8>
  20b28a:	mov    esi,0x28
  20b28f:	vzeroupper
  20b292:	call   QWORD PTR [rip+0x33ef78]        # 54a210 <_DYNAMIC+0x438>
  20b298:	lea    rcx,[rip+0x330c81]        # 53bf20 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0x1f8>
  20b29f:	xor    edi,edi
  20b2a1:	mov    rdx,QWORD PTR [rsp+0x88]
  20b2a9:	vzeroupper
  20b2ac:	call   QWORD PTR [rip+0x33ee26]        # 54a0d8 <_DYNAMIC+0x300>
  20b2b2:	lea    r10,[rip+0x330b5f]        # 53be18 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xf0>
  20b2b9:	lea    r11,[rip+0xffffffffffe34710]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b2c0:	lea    rbx,[rip+0x330629]        # 53b8f0 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270>
  20b2c7:	lea    r14,[rip+0x331032]        # 53c300 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270>
  20b2ce:	movabs rcx,0x7fffffffffffffff
  20b2d8:	mov    r8d,0x1
  20b2de:	mov    r9d,0x1
  20b2e4:	mov    rdi,rax
  20b2e7:	mov    rsi,rax
  20b2ea:	mov    rdx,QWORD PTR [rsp+0x8]
  20b2ef:	push   r10
  20b2f1:	push   r11
  20b2f3:	push   rbx
  20b2f4:	push   r14
  20b2f6:	vzeroupper
  20b2f9:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
  20b2fe:	lea    rax,[rip+0x330acb]        # 53bdd0 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xa8>
  20b305:	lea    r10,[rip+0xffffffffffe346c4]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b30c:	lea    r11,[rip+0x330585]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20b313:	lea    rbx,[rip+0x3307ee]        # 53bb08 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x218>
  20b31a:	mov    r8d,0x1
  20b320:	mov    rdi,rsi
  20b323:	mov    r9d,0x1
  20b329:	mov    rdx,QWORD PTR [rsp+0xb8]
  20b331:	jmp    20b3a4 <_RINvNvMsc_NtNtCs6SqwH2l26qc_4pulp3x862v3NtB8_2V39vectorize3impINtNvXs1_B8_BC_NtBc_4Simd9vectorize4ImplINtNvNtNtNtNtCsjouqPOLJnB9_4faer6linalg8cholesky4ldlt6factor13simd_cholesky4ImpldEEECscfHK10Grmvq_6fbench+0xa14>
  20b333:	sub    rsp,0x8
  20b337:	lea    rax,[rip+0x33072a]        # 53ba68 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x178>
  20b33e:	lea    rcx,[rip+0x3306db]        # 53ba20 <anon.c38c26bc52a245a79a4d978676f36d04.8.llvm.17936451394092910270+0x130>
  20b345:	lea    r8,[rip+0x330534]        # 53b880 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270>
  20b34c:	mov    rdi,rsi
  20b34f:	lea    r9,[rip+0xffffffffffe3467a]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b356:	mov    edx,0x1
  20b35b:	mov    rsi,QWORD PTR [rsp+0x88]
  20b363:	push   rax
  20b364:	vzeroupper
  20b367:	call   1b4ce0 <_RINvCsHILTPq90mD_7equator13do_panic_implNtNtB2_4expr3CmpECscfHK10Grmvq_6fbench>
  20b36c:	lea    rax,[rip+0x330a75]        # 53bde8 <anon.c38c26bc52a245a79a4d978676f36d04.90.llvm.17936451394092910270+0xc0>
  20b373:	lea    r10,[rip+0xffffffffffe34656]        # 3f9d0 <anon.13dd319df1c1c818450302147399c1ac.76.llvm.9503590296746000867>
  20b37a:	lea    r11,[rip+0x330517]        # 53b898 <anon.c38c26bc52a245a79a4d978676f36d04.2.llvm.17936451394092910270+0x18>
  20b381:	lea    rbx,[rip+0x330ff8]        # 53c380 <anon.c38c26bc52a245a79a4d978676f36d04.146.llvm.17936451394092910270+0x80>
  20b388:	movabs rcx,0x7fffffffffffffff
  20b392:	mov    r8d,0x1
  20b398:	mov    rdx,rsi
  20b39b:	mov    r9d,0x1
  20b3a1:	mov    rsi,rdi
  20b3a4:	push   rax
  20b3a5:	push   r10
  20b3a7:	push   r11
  20b3a9:	push   rbx
  20b3aa:	vzeroupper
  20b3ad:	call   1b4a50 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECscfHK10Grmvq_6fbench>
