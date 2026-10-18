
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/7364be5ce22d/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

0000000000023ea0 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_>:
   23ea0:	push   rbp
   23ea1:	push   r15
   23ea3:	push   r14
   23ea5:	push   r13
   23ea7:	push   r12
   23ea9:	push   rbx
   23eaa:	sub    rsp,0x118
   23eb1:	mov    r14,rsi
   23eb4:	mov    QWORD PTR [rsp+0x100],rdi
   23ebc:	call   QWORD PTR [rip+0x65c5e]        # 89b20 <_DYNAMIC+0x2b0>
   23ec2:	mov    QWORD PTR [rsp+0x108],rax
   23eca:	mov    DWORD PTR [rsp+0x110],edx
   23ed1:	lea    rdi,[rsp+0x108]
   23ed9:	call   QWORD PTR [rip+0x65c49]        # 89b28 <_DYNAMIC+0x2b8>
   23edf:	test   rax,rax
   23ee2:	je     24752 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x8b2>
   23ee8:	call   QWORD PTR [rip+0x65bf2]        # 89ae0 <_DYNAMIC+0x270>
   23eee:	mov    edi,0x28
   23ef3:	mov    esi,0x8
   23ef8:	call   QWORD PTR [rip+0x65bea]        # 89ae8 <_DYNAMIC+0x278>
   23efe:	test   rax,rax
   23f01:	je     24902 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa62>
   23f07:	mov    QWORD PTR [rsp],0x5
   23f0f:	mov    QWORD PTR [rsp+0x8],rax
   23f14:	mov    QWORD PTR [rsp+0x10],0x0
   23f1d:	call   QWORD PTR [rip+0x65bfd]        # 89b20 <_DYNAMIC+0x2b0>
   23f23:	mov    QWORD PTR [rsp+0x88],rax
   23f2b:	mov    DWORD PTR [rsp+0x90],edx
   23f32:	mov    rax,QWORD PTR [r14+0x20]
   23f36:	mov    QWORD PTR [rsp+0x70],rax
   23f3b:	movups xmm0,XMMWORD PTR [r14]
   23f3f:	movupd xmm1,XMMWORD PTR [r14+0x10]
   23f45:	movapd XMMWORD PTR [rsp+0x60],xmm1
   23f4b:	movaps XMMWORD PTR [rsp+0x50],xmm0
   23f50:	lea    rax,[rsp+0x50]
   23f55:	mov    rax,QWORD PTR [rsp+0x50]
   23f5a:	mov    r15,QWORD PTR [rsp+0x58]
   23f5f:	mov    rcx,QWORD PTR [rsp+0x70]
   23f64:	mov    QWORD PTR [rsp+0xd0],rax
   23f6c:	mov    QWORD PTR [rsp+0xd8],r15
   23f74:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   23f7a:	mov    r12,QWORD PTR [rsp+0x60]
   23f7f:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   23f88:	mov    QWORD PTR [rsp+0xf0],rcx
   23f90:	lea    rdi,[rsp+0x18]
   23f95:	lea    rcx,[rsp+0xd0]
   23f9d:	mov    rsi,r15
   23fa0:	mov    rdx,r12
   23fa3:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   23fa8:	mov    rdi,QWORD PTR [rsp+0x40]
   23fad:	mov    rsi,QWORD PTR [rsp+0x48]
   23fb2:	cmp    rdi,r15
   23fb5:	jne    24912 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa72>
   23fbb:	cmp    rsi,r12
   23fbe:	jne    24912 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa72>
   23fc4:	mov    rax,QWORD PTR [rsp+0x18]
   23fc9:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   23fcf:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   23fd5:	mov    QWORD PTR [rsp+0x98],rax
   23fdd:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   23fe6:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   23fef:	mov    QWORD PTR [rsp+0xc0],r15
   23ff7:	mov    QWORD PTR [rsp+0xc8],r12
   23fff:	lea    rax,[rsp+0x98]
   24007:	mov    rsi,QWORD PTR [rsp+0xb8]
   2400f:	test   rsi,rsi
   24012:	je     2402a <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x18a>
   24014:	mov    rdi,QWORD PTR [rsp+0x98]
   2401c:	mov    rdx,QWORD PTR [rsp+0xb0]
   24024:	call   QWORD PTR [rip+0x65aa6]        # 89ad0 <_DYNAMIC+0x260>
   2402a:	lea    rdi,[rsp+0x88]
   24032:	call   QWORD PTR [rip+0x65af0]        # 89b28 <_DYNAMIC+0x2b8>
   24038:	mov    r15,rax
   2403b:	mov    ebx,edx
   2403d:	mov    r12,QWORD PTR [rsp+0x10]
   24042:	cmp    r12,QWORD PTR [rsp]
   24046:	jne    24050 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x1b0>
   24048:	mov    rdi,rsp
   2404b:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   24050:	movq   xmm0,r15
   24055:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe8de3]        # ce40 <GCC_except_table145+0x74>
   2405d:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe8d7b]        # cde0 <GCC_except_table145+0x14>
   24065:	movapd xmm1,xmm0
   24069:	unpckhpd xmm1,xmm0
   2406d:	cvtsi2sd xmm2,ebx
   24071:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe9027]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   24079:	addsd  xmm1,xmm0
   2407d:	addsd  xmm2,xmm1
   24081:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe907f]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24089:	mov    rax,QWORD PTR [rsp+0x8]
   2408e:	movsd  QWORD PTR [rax+r12*8],xmm2
   24094:	inc    r12
   24097:	mov    QWORD PTR [rsp+0x10],r12
   2409c:	call   QWORD PTR [rip+0x65a7e]        # 89b20 <_DYNAMIC+0x2b0>
   240a2:	mov    QWORD PTR [rsp+0x88],rax
   240aa:	mov    DWORD PTR [rsp+0x90],edx
   240b1:	mov    rax,QWORD PTR [r14+0x20]
   240b5:	mov    QWORD PTR [rsp+0x70],rax
   240ba:	movups xmm0,XMMWORD PTR [r14]
   240be:	movupd xmm1,XMMWORD PTR [r14+0x10]
   240c4:	movapd XMMWORD PTR [rsp+0x60],xmm1
   240ca:	movaps XMMWORD PTR [rsp+0x50],xmm0
   240cf:	lea    rax,[rsp+0x50]
   240d4:	mov    rax,QWORD PTR [rsp+0x50]
   240d9:	mov    r15,QWORD PTR [rsp+0x58]
   240de:	mov    rcx,QWORD PTR [rsp+0x70]
   240e3:	mov    QWORD PTR [rsp+0xd0],rax
   240eb:	mov    QWORD PTR [rsp+0xd8],r15
   240f3:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   240f9:	mov    r12,QWORD PTR [rsp+0x60]
   240fe:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24107:	mov    QWORD PTR [rsp+0xf0],rcx
   2410f:	lea    rdi,[rsp+0x18]
   24114:	lea    rcx,[rsp+0xd0]
   2411c:	mov    rsi,r15
   2411f:	mov    rdx,r12
   24122:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   24127:	mov    rdi,QWORD PTR [rsp+0x40]
   2412c:	mov    rsi,QWORD PTR [rsp+0x48]
   24131:	cmp    rdi,r15
   24134:	jne    24954 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xab4>
   2413a:	cmp    rsi,r12
   2413d:	jne    24954 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xab4>
   24143:	mov    rax,QWORD PTR [rsp+0x18]
   24148:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2414e:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24154:	mov    QWORD PTR [rsp+0x98],rax
   2415c:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24165:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2416e:	mov    QWORD PTR [rsp+0xc0],r15
   24176:	mov    QWORD PTR [rsp+0xc8],r12
   2417e:	lea    rax,[rsp+0x98]
   24186:	mov    rsi,QWORD PTR [rsp+0xb8]
   2418e:	test   rsi,rsi
   24191:	je     241a9 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x309>
   24193:	mov    rdi,QWORD PTR [rsp+0x98]
   2419b:	mov    rdx,QWORD PTR [rsp+0xb0]
   241a3:	call   QWORD PTR [rip+0x65927]        # 89ad0 <_DYNAMIC+0x260>
   241a9:	lea    rdi,[rsp+0x88]
   241b1:	call   QWORD PTR [rip+0x65971]        # 89b28 <_DYNAMIC+0x2b8>
   241b7:	mov    r15,rax
   241ba:	mov    ebx,edx
   241bc:	mov    r12,QWORD PTR [rsp+0x10]
   241c1:	cmp    r12,QWORD PTR [rsp]
   241c5:	jne    241cf <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x32f>
   241c7:	mov    rdi,rsp
   241ca:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   241cf:	movq   xmm0,r15
   241d4:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe8c64]        # ce40 <GCC_except_table145+0x74>
   241dc:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe8bfc]        # cde0 <GCC_except_table145+0x14>
   241e4:	movapd xmm1,xmm0
   241e8:	unpckhpd xmm1,xmm0
   241ec:	cvtsi2sd xmm2,ebx
   241f0:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe8ea8]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   241f8:	addsd  xmm1,xmm0
   241fc:	addsd  xmm2,xmm1
   24200:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe8f00]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24208:	mov    rax,QWORD PTR [rsp+0x8]
   2420d:	movsd  QWORD PTR [rax+r12*8],xmm2
   24213:	inc    r12
   24216:	mov    QWORD PTR [rsp+0x10],r12
   2421b:	call   QWORD PTR [rip+0x658ff]        # 89b20 <_DYNAMIC+0x2b0>
   24221:	mov    QWORD PTR [rsp+0x88],rax
   24229:	mov    DWORD PTR [rsp+0x90],edx
   24230:	mov    rax,QWORD PTR [r14+0x20]
   24234:	mov    QWORD PTR [rsp+0x70],rax
   24239:	movups xmm0,XMMWORD PTR [r14]
   2423d:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24243:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24249:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2424e:	lea    rax,[rsp+0x50]
   24253:	mov    rax,QWORD PTR [rsp+0x50]
   24258:	mov    r15,QWORD PTR [rsp+0x58]
   2425d:	mov    rcx,QWORD PTR [rsp+0x70]
   24262:	mov    QWORD PTR [rsp+0xd0],rax
   2426a:	mov    QWORD PTR [rsp+0xd8],r15
   24272:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24278:	mov    r12,QWORD PTR [rsp+0x60]
   2427d:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24286:	mov    QWORD PTR [rsp+0xf0],rcx
   2428e:	lea    rdi,[rsp+0x18]
   24293:	lea    rcx,[rsp+0xd0]
   2429b:	mov    rsi,r15
   2429e:	mov    rdx,r12
   242a1:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   242a6:	mov    rdi,QWORD PTR [rsp+0x40]
   242ab:	mov    rsi,QWORD PTR [rsp+0x48]
   242b0:	cmp    rdi,r15
   242b3:	jne    24996 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xaf6>
   242b9:	cmp    rsi,r12
   242bc:	jne    24996 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xaf6>
   242c2:	mov    rax,QWORD PTR [rsp+0x18]
   242c7:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   242cd:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   242d3:	mov    QWORD PTR [rsp+0x98],rax
   242db:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   242e4:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   242ed:	mov    QWORD PTR [rsp+0xc0],r15
   242f5:	mov    QWORD PTR [rsp+0xc8],r12
   242fd:	lea    rax,[rsp+0x98]
   24305:	mov    rsi,QWORD PTR [rsp+0xb8]
   2430d:	test   rsi,rsi
   24310:	je     24328 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x488>
   24312:	mov    rdi,QWORD PTR [rsp+0x98]
   2431a:	mov    rdx,QWORD PTR [rsp+0xb0]
   24322:	call   QWORD PTR [rip+0x657a8]        # 89ad0 <_DYNAMIC+0x260>
   24328:	lea    rdi,[rsp+0x88]
   24330:	call   QWORD PTR [rip+0x657f2]        # 89b28 <_DYNAMIC+0x2b8>
   24336:	mov    r15,rax
   24339:	mov    ebx,edx
   2433b:	mov    r12,QWORD PTR [rsp+0x10]
   24340:	cmp    r12,QWORD PTR [rsp]
   24344:	jne    2434e <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x4ae>
   24346:	mov    rdi,rsp
   24349:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2434e:	movq   xmm0,r15
   24353:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe8ae5]        # ce40 <GCC_except_table145+0x74>
   2435b:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe8a7d]        # cde0 <GCC_except_table145+0x14>
   24363:	movapd xmm1,xmm0
   24367:	unpckhpd xmm1,xmm0
   2436b:	cvtsi2sd xmm2,ebx
   2436f:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe8d29]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   24377:	addsd  xmm1,xmm0
   2437b:	addsd  xmm2,xmm1
   2437f:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe8d81]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24387:	mov    rax,QWORD PTR [rsp+0x8]
   2438c:	movsd  QWORD PTR [rax+r12*8],xmm2
   24392:	inc    r12
   24395:	mov    QWORD PTR [rsp+0x10],r12
   2439a:	call   QWORD PTR [rip+0x65780]        # 89b20 <_DYNAMIC+0x2b0>
   243a0:	mov    QWORD PTR [rsp+0x88],rax
   243a8:	mov    DWORD PTR [rsp+0x90],edx
   243af:	mov    rax,QWORD PTR [r14+0x20]
   243b3:	mov    QWORD PTR [rsp+0x70],rax
   243b8:	movups xmm0,XMMWORD PTR [r14]
   243bc:	movupd xmm1,XMMWORD PTR [r14+0x10]
   243c2:	movapd XMMWORD PTR [rsp+0x60],xmm1
   243c8:	movaps XMMWORD PTR [rsp+0x50],xmm0
   243cd:	lea    rax,[rsp+0x50]
   243d2:	mov    rax,QWORD PTR [rsp+0x50]
   243d7:	mov    r15,QWORD PTR [rsp+0x58]
   243dc:	mov    rcx,QWORD PTR [rsp+0x70]
   243e1:	mov    QWORD PTR [rsp+0xd0],rax
   243e9:	mov    QWORD PTR [rsp+0xd8],r15
   243f1:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   243f7:	mov    r12,QWORD PTR [rsp+0x60]
   243fc:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24405:	mov    QWORD PTR [rsp+0xf0],rcx
   2440d:	lea    rdi,[rsp+0x18]
   24412:	lea    rcx,[rsp+0xd0]
   2441a:	mov    rsi,r15
   2441d:	mov    rdx,r12
   24420:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   24425:	mov    rdi,QWORD PTR [rsp+0x40]
   2442a:	mov    rsi,QWORD PTR [rsp+0x48]
   2442f:	cmp    rdi,r15
   24432:	jne    249d8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb38>
   24438:	cmp    rsi,r12
   2443b:	jne    249d8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb38>
   24441:	mov    rax,QWORD PTR [rsp+0x18]
   24446:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   2444c:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   24452:	mov    QWORD PTR [rsp+0x98],rax
   2445a:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   24463:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   2446c:	mov    QWORD PTR [rsp+0xc0],r15
   24474:	mov    QWORD PTR [rsp+0xc8],r12
   2447c:	lea    rax,[rsp+0x98]
   24484:	mov    rsi,QWORD PTR [rsp+0xb8]
   2448c:	test   rsi,rsi
   2448f:	je     244a7 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x607>
   24491:	mov    rdi,QWORD PTR [rsp+0x98]
   24499:	mov    rdx,QWORD PTR [rsp+0xb0]
   244a1:	call   QWORD PTR [rip+0x65629]        # 89ad0 <_DYNAMIC+0x260>
   244a7:	lea    rdi,[rsp+0x88]
   244af:	call   QWORD PTR [rip+0x65673]        # 89b28 <_DYNAMIC+0x2b8>
   244b5:	mov    r15,rax
   244b8:	mov    ebx,edx
   244ba:	mov    r12,QWORD PTR [rsp+0x10]
   244bf:	cmp    r12,QWORD PTR [rsp]
   244c3:	jne    244cd <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x62d>
   244c5:	mov    rdi,rsp
   244c8:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   244cd:	movq   xmm0,r15
   244d2:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe8966]        # ce40 <GCC_except_table145+0x74>
   244da:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe88fe]        # cde0 <GCC_except_table145+0x14>
   244e2:	movapd xmm1,xmm0
   244e6:	unpckhpd xmm1,xmm0
   244ea:	cvtsi2sd xmm2,ebx
   244ee:	divsd  xmm2,QWORD PTR [rip+0xfffffffffffe8baa]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   244f6:	addsd  xmm1,xmm0
   244fa:	addsd  xmm2,xmm1
   244fe:	mulsd  xmm2,QWORD PTR [rip+0xfffffffffffe8c02]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24506:	mov    rax,QWORD PTR [rsp+0x8]
   2450b:	movsd  QWORD PTR [rax+r12*8],xmm2
   24511:	inc    r12
   24514:	mov    QWORD PTR [rsp+0x10],r12
   24519:	call   QWORD PTR [rip+0x65601]        # 89b20 <_DYNAMIC+0x2b0>
   2451f:	mov    QWORD PTR [rsp+0x88],rax
   24527:	mov    DWORD PTR [rsp+0x90],edx
   2452e:	mov    rax,QWORD PTR [r14+0x20]
   24532:	mov    QWORD PTR [rsp+0x70],rax
   24537:	movups xmm0,XMMWORD PTR [r14]
   2453b:	movupd xmm1,XMMWORD PTR [r14+0x10]
   24541:	movapd XMMWORD PTR [rsp+0x60],xmm1
   24547:	movaps XMMWORD PTR [rsp+0x50],xmm0
   2454c:	lea    rax,[rsp+0x50]
   24551:	mov    rax,QWORD PTR [rsp+0x50]
   24556:	mov    r14,QWORD PTR [rsp+0x58]
   2455b:	mov    rcx,QWORD PTR [rsp+0x70]
   24560:	mov    QWORD PTR [rsp+0xd0],rax
   24568:	mov    QWORD PTR [rsp+0xd8],r14
   24570:	movapd xmm0,XMMWORD PTR [rsp+0x60]
   24576:	mov    r15,QWORD PTR [rsp+0x60]
   2457b:	movupd XMMWORD PTR [rsp+0xe0],xmm0
   24584:	mov    QWORD PTR [rsp+0xf0],rcx
   2458c:	lea    rdi,[rsp+0x18]
   24591:	lea    rcx,[rsp+0xd0]
   24599:	mov    rsi,r14
   2459c:	mov    rdx,r15
   2459f:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   245a4:	mov    rdi,QWORD PTR [rsp+0x40]
   245a9:	mov    rsi,QWORD PTR [rsp+0x48]
   245ae:	cmp    rdi,r14
   245b1:	jne    24a17 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb77>
   245b7:	cmp    rsi,r15
   245ba:	jne    24a17 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xb77>
   245c0:	mov    rax,QWORD PTR [rsp+0x18]
   245c5:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   245cb:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   245d1:	mov    QWORD PTR [rsp+0x98],rax
   245d9:	movupd XMMWORD PTR [rsp+0xa0],xmm0
   245e2:	movupd XMMWORD PTR [rsp+0xb0],xmm1
   245eb:	mov    QWORD PTR [rsp+0xc0],r14
   245f3:	mov    QWORD PTR [rsp+0xc8],r15
   245fb:	lea    rax,[rsp+0x98]
   24603:	mov    rsi,QWORD PTR [rsp+0xb8]
   2460b:	test   rsi,rsi
   2460e:	je     24626 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x786>
   24610:	mov    rdi,QWORD PTR [rsp+0x98]
   24618:	mov    rdx,QWORD PTR [rsp+0xb0]
   24620:	call   QWORD PTR [rip+0x654aa]        # 89ad0 <_DYNAMIC+0x260>
   24626:	lea    rdi,[rsp+0x88]
   2462e:	call   QWORD PTR [rip+0x654f4]        # 89b28 <_DYNAMIC+0x2b8>
   24634:	mov    r14,rax
   24637:	mov    ebx,edx
   24639:	mov    rbp,QWORD PTR [rsp+0x10]
   2463e:	cmp    rbp,QWORD PTR [rsp]
   24642:	jne    2464c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x7ac>
   24644:	mov    rdi,rsp
   24647:	call   2f3c0 <_RNvMs4_NtCs1C1lLj4PWSY_5alloc7raw_vecINtB5_6RawVecdE8grow_oneCskuD9mmv22aj_16owned_copy_probe>
   2464c:	movq   xmm0,r14
   24651:	punpckldq xmm0,XMMWORD PTR [rip+0xfffffffffffe87e7]        # ce40 <GCC_except_table145+0x74>
   24659:	subpd  xmm0,XMMWORD PTR [rip+0xfffffffffffe877f]        # cde0 <GCC_except_table145+0x14>
   24661:	movapd xmm1,xmm0
   24665:	unpckhpd xmm1,xmm0
   24669:	addsd  xmm1,xmm0
   2466d:	xorps  xmm0,xmm0
   24670:	cvtsi2sd xmm0,ebx
   24674:	divsd  xmm0,QWORD PTR [rip+0xfffffffffffe8a24]        # d0a0 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x10>
   2467c:	addsd  xmm0,xmm1
   24680:	mulsd  xmm0,QWORD PTR [rip+0xfffffffffffe8a80]        # d108 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521+0x78>
   24688:	mov    rax,QWORD PTR [rsp+0x8]
   2468d:	movsd  QWORD PTR [rax+rbp*8],xmm0
   24692:	lea    r12,[rbp+0x1]
   24696:	mov    QWORD PTR [rsp+0x10],r12
   2469b:	lea    r13,[rbp*8+0x8]
   246a3:	mov    rax,r12
   246a6:	shr    rax,0x3d
   246aa:	setne  al
   246ad:	movabs rcx,0x7ffffffffffffff8
   246b7:	cmp    r13,rcx
   246ba:	seta   cl
   246bd:	or     cl,al
   246bf:	je     246d5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x835>
   246c1:	xor    r15d,r15d
   246c4:	mov    rdi,r15
   246c7:	mov    rsi,r13
   246ca:	call   QWORD PTR [rip+0x65420]        # 89af0 <_DYNAMIC+0x280>
   246d0:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   246d5:	mov    rbx,QWORD PTR [rsp+0x8]
   246da:	test   r13,r13
   246dd:	je     24873 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9d3>
   246e3:	call   QWORD PTR [rip+0x653f7]        # 89ae0 <_DYNAMIC+0x270>
   246e9:	mov    r15d,0x8
   246ef:	mov    esi,0x8
   246f4:	mov    rdi,r13
   246f7:	call   QWORD PTR [rip+0x653eb]        # 89ae8 <_DYNAMIC+0x278>
   246fd:	test   rax,rax
   24700:	je     246c4 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x824>
   24702:	mov    r14,rax
   24705:	mov    r15,r12
   24708:	test   r12,r12
   2470b:	je     24885 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9e5>
   24711:	mov    rdi,r14
   24714:	mov    rsi,rbx
   24717:	mov    rdx,r13
   2471a:	call   QWORD PTR [rip+0x653f0]        # 89b10 <memcpy@GLIBC_2.14>
   24720:	lea    rax,[rsp+0x87]
   24728:	mov    QWORD PTR [rsp+0x18],rax
   2472d:	mov    esi,0x1
   24732:	test   rbp,rbp
   24735:	jne    2488c <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9ec>
   2473b:	lea    rdx,[rip+0x61ee6]        # 86628 <anon.2c393db9686f2344a1ccdcb44f907da6.0.llvm.13323335406852763521+0x18>
   24742:	mov    edi,0x2
   24747:	call   QWORD PTR [rip+0x653e3]        # 89b30 <_DYNAMIC+0x2c0>
   2474d:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   24752:	lea    r15,[rsp+0x18]
   24757:	lea    r13,[rsp+0x108]
   2475f:	mov    r12,QWORD PTR [rip+0x653c2]        # 89b28 <_DYNAMIC+0x2b8>
   24766:	cmp    edx,0xee6b280
   2476c:	jae    23ee8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x48>
   24772:	mov    rax,QWORD PTR [r14+0x20]
   24776:	mov    QWORD PTR [rsp+0xf0],rax
   2477e:	movups xmm0,XMMWORD PTR [r14]
   24782:	movups xmm1,XMMWORD PTR [r14+0x10]
   24787:	movaps XMMWORD PTR [rsp+0xe0],xmm1
   2478f:	movaps XMMWORD PTR [rsp+0xd0],xmm0
   24797:	lea    rax,[rsp+0xd0]
   2479f:	mov    rax,QWORD PTR [rsp+0xd0]
   247a7:	mov    rbp,QWORD PTR [rsp+0xd8]
   247af:	mov    rcx,QWORD PTR [rsp+0xf0]
   247b7:	mov    QWORD PTR [rsp+0x98],rax
   247bf:	mov    QWORD PTR [rsp+0xa0],rbp
   247c7:	movaps xmm0,XMMWORD PTR [rsp+0xe0]
   247cf:	mov    rbx,QWORD PTR [rsp+0xe0]
   247d7:	movups XMMWORD PTR [rsp+0xa8],xmm0
   247df:	mov    QWORD PTR [rsp+0xb8],rcx
   247e7:	mov    rdi,r15
   247ea:	mov    rsi,rbp
   247ed:	mov    rdx,rbx
   247f0:	lea    rcx,[rsp+0x98]
   247f8:	call   2d790 <_RINvMs9_NtNtCsfyJFFj4AWdU_4faer3mat6matownINtNtB8_7generic3MatINtB6_3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtBa_5utils5bound3DimB1M_EE7from_fnNCINvNvMsa_NtB8_6matrefIBF_pE6cloned3impB18_iiE0ECskuD9mmv22aj_16owned_copy_probe>
   247fd:	mov    rdi,QWORD PTR [rsp+0x40]
   24802:	mov    rsi,QWORD PTR [rsp+0x48]
   24807:	cmp    rdi,rbp
   2480a:	jne    24a56 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbb6>
   24810:	cmp    rsi,rbx
   24813:	jne    24a56 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbb6>
   24819:	mov    rax,QWORD PTR [rsp+0x18]
   2481e:	movupd xmm0,XMMWORD PTR [rsp+0x20]
   24824:	movupd xmm1,XMMWORD PTR [rsp+0x30]
   2482a:	mov    QWORD PTR [rsp+0x18],rax
   2482f:	movupd XMMWORD PTR [rsp+0x20],xmm0
   24835:	movupd XMMWORD PTR [rsp+0x30],xmm1
   2483b:	mov    QWORD PTR [rsp+0x40],rbp
   24840:	mov    QWORD PTR [rsp+0x48],rbx
   24845:	mov    rsi,QWORD PTR [rsp+0x38]
   2484a:	test   rsi,rsi
   2484d:	je     2485f <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x9bf>
   2484f:	mov    rdi,QWORD PTR [rsp+0x18]
   24854:	mov    rdx,QWORD PTR [rsp+0x30]
   24859:	call   QWORD PTR [rip+0x65271]        # 89ad0 <_DYNAMIC+0x260>
   2485f:	mov    rdi,r13
   24862:	call   r12
   24865:	test   rax,rax
   24868:	je     24766 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x8c6>
   2486e:	jmp    23ee8 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x48>
   24873:	mov    r14d,0x8
   24879:	xor    r15d,r15d
   2487c:	test   r12,r12
   2487f:	jne    24711 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x871>
   24885:	xor    esi,esi
   24887:	jmp    2473b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x89b>
   2488c:	cmp    r12,0x15
   24890:	jae    24a96 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf6>
   24896:	lea    rcx,[rsp+0x18]
   2489b:	mov    edx,0x1
   248a0:	mov    rdi,r14
   248a3:	mov    rsi,r12
   248a6:	call   34140 <_RINvNtNtNtNtCsevLNFiNqfJP_4core5slice4sort6shared9smallsort25insertion_sort_shift_leftdNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtBa_3f64d9total_cmpE0ECskuD9mmv22aj_16owned_copy_probe>
   248ab:	cmp    r12,0x3
   248af:	jb     24aab <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc0b>
   248b5:	movsd  xmm0,QWORD PTR [r14+0x10]
   248bb:	mov    rax,QWORD PTR [rsp+0x10]
   248c0:	mov    rbx,QWORD PTR [rsp+0x100]
   248c8:	mov    QWORD PTR [rbx+0x18],rax
   248cc:	movups xmm1,XMMWORD PTR [rsp]
   248d0:	movups XMMWORD PTR [rbx+0x8],xmm1
   248d4:	movsd  QWORD PTR [rbx],xmm0
   248d8:	shl    r15,0x3
   248dc:	mov    edx,0x8
   248e1:	mov    rdi,r14
   248e4:	mov    rsi,r15
   248e7:	call   QWORD PTR [rip+0x651e3]        # 89ad0 <_DYNAMIC+0x260>
   248ed:	mov    rax,rbx
   248f0:	add    rsp,0x118
   248f7:	pop    rbx
   248f8:	pop    r12
   248fa:	pop    r13
   248fc:	pop    r14
   248fe:	pop    r15
   24900:	pop    rbp
   24901:	ret
   24902:	mov    edi,0x8
   24907:	mov    esi,0x28
   2490c:	call   QWORD PTR [rip+0x651de]        # 89af0 <_DYNAMIC+0x280>
   24912:	lea    rax,[rip+0x61e6f]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   24919:	lea    r10,[rip+0xfffffffffffe8770]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   24920:	lea    r11,[rip+0x62141]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24927:	lea    rbx,[rip+0x621c2]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   2492e:	mov    r8d,0x1
   24934:	mov    r9d,0x1
   2493a:	mov    rdx,r15
   2493d:	mov    rcx,r12
   24940:	push   rax
   24941:	push   r10
   24943:	push   r11
   24945:	push   rbx
   24946:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2494b:	add    rsp,0x20
   2494f:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   24954:	lea    rax,[rip+0x61e2d]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   2495b:	lea    r10,[rip+0xfffffffffffe872e]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   24962:	lea    r11,[rip+0x620ff]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24969:	lea    rbx,[rip+0x62180]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   24970:	mov    r8d,0x1
   24976:	mov    r9d,0x1
   2497c:	mov    rdx,r15
   2497f:	mov    rcx,r12
   24982:	push   rax
   24983:	push   r10
   24985:	push   r11
   24987:	push   rbx
   24988:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   2498d:	add    rsp,0x20
   24991:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   24996:	lea    rax,[rip+0x61deb]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   2499d:	lea    r10,[rip+0xfffffffffffe86ec]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   249a4:	lea    r11,[rip+0x620bd]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   249ab:	lea    rbx,[rip+0x6213e]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   249b2:	mov    r8d,0x1
   249b8:	mov    r9d,0x1
   249be:	mov    rdx,r15
   249c1:	mov    rcx,r12
   249c4:	push   rax
   249c5:	push   r10
   249c7:	push   r11
   249c9:	push   rbx
   249ca:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   249cf:	add    rsp,0x20
   249d3:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   249d8:	lea    rax,[rip+0x61da9]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   249df:	lea    r10,[rip+0xfffffffffffe86aa]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   249e6:	lea    r11,[rip+0x6207b]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   249ed:	lea    rbx,[rip+0x620fc]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   249f4:	mov    r8d,0x1
   249fa:	mov    r9d,0x1
   24a00:	mov    rdx,r15
   24a03:	mov    rcx,r12
   24a06:	push   rax
   24a07:	push   r10
   24a09:	push   r11
   24a0b:	push   rbx
   24a0c:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   24a11:	add    rsp,0x20
   24a15:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   24a17:	lea    rax,[rip+0x61d6a]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   24a1e:	lea    r10,[rip+0xfffffffffffe866b]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   24a25:	lea    r11,[rip+0x6203c]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24a2c:	lea    rbx,[rip+0x620bd]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   24a33:	mov    r8d,0x1
   24a39:	mov    r9d,0x1
   24a3f:	mov    rdx,r14
   24a42:	mov    rcx,r15
   24a45:	push   rax
   24a46:	push   r10
   24a48:	push   r11
   24a4a:	push   rbx
   24a4b:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   24a50:	add    rsp,0x20
   24a54:	jmp    24a94 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xbf4>
   24a56:	lea    rax,[rip+0x61d2b]        # 86788 <anon.2c393db9686f2344a1ccdcb44f907da6.15.llvm.13323335406852763521+0xb8>
   24a5d:	lea    r10,[rip+0xfffffffffffe862c]        # d090 <anon.2c393db9686f2344a1ccdcb44f907da6.29.llvm.13323335406852763521>
   24a64:	lea    r11,[rip+0x61ffd]        # 86a68 <anon.811c32b620528610c647b20c5efb1c6a.2.llvm.10716373653596490299>
   24a6b:	lea    r14,[rip+0x6207e]        # 86af0 <anon.811c32b620528610c647b20c5efb1c6a.13.llvm.10716373653596490299>
   24a72:	mov    r8d,0x1
   24a78:	mov    r9d,0x1
   24a7e:	mov    rdx,rbp
   24a81:	mov    rcx,rbx
   24a84:	push   rax
   24a85:	push   r10
   24a87:	push   r11
   24a89:	push   r14
   24a8b:	call   2d450 <_RINvCsHILTPq90mD_7equator13do_panic_implINtNtB2_4expr7AndExprNtBF_3CmpBX_EECskuD9mmv22aj_16owned_copy_probe>
   24a90:	add    rsp,0x20
   24a94:	ud2
   24a96:	lea    rdx,[rsp+0x18]
   24a9b:	mov    rdi,r14
   24a9e:	mov    rsi,r12
   24aa1:	call   33a70 <_RINvNtNtNtCsevLNFiNqfJP_4core5slice4sort6stable14driftsort_maindNCINvMNtCs1C1lLj4PWSY_5alloc5sliceSd7sort_byNvMNtB8_3f64d9total_cmpE0INtNtB18_3vec3VecdEECskuD9mmv22aj_16owned_copy_probe>
   24aa6:	jmp    248b5 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xa15>
   24aab:	mov    esi,0x2
   24ab0:	jmp    2473b <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0x89b>
   24ab5:	mov    rbx,rax
   24ab8:	mov    rsi,QWORD PTR [rsp+0x38]
   24abd:	test   rsi,rsi
   24ac0:	je     24b36 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc96>
   24ac2:	mov    rdi,QWORD PTR [rsp+0x18]
   24ac7:	mov    rdx,QWORD PTR [rsp+0x30]
   24acc:	jmp    24b30 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc90>
   24ace:	jmp    24ad6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   24ad0:	jmp    24ad6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   24ad2:	jmp    24ad6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   24ad4:	jmp    24ad6 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc36>
   24ad6:	mov    rbx,rax
   24ad9:	mov    rsi,QWORD PTR [rsp+0x38]
   24ade:	test   rsi,rsi
   24ae1:	je     24b19 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   24ae3:	mov    rdi,QWORD PTR [rsp+0x18]
   24ae8:	mov    rdx,QWORD PTR [rsp+0x30]
   24aed:	call   QWORD PTR [rip+0x64fdd]        # 89ad0 <_DYNAMIC+0x260>
   24af3:	jmp    24b19 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   24af5:	jmp    24b16 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc76>
   24af7:	mov    rbx,rax
   24afa:	test   r15,r15
   24afd:	je     24b19 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   24aff:	shl    r15,0x3
   24b03:	mov    edx,0x8
   24b08:	mov    rdi,r14
   24b0b:	mov    rsi,r15
   24b0e:	call   QWORD PTR [rip+0x64fbc]        # 89ad0 <_DYNAMIC+0x260>
   24b14:	jmp    24b19 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc79>
   24b16:	mov    rbx,rax
   24b19:	mov    rsi,QWORD PTR [rsp]
   24b1d:	test   rsi,rsi
   24b20:	je     24b36 <_RINvCskuD9mmv22aj_16owned_copy_probe7measureINtNtNtCsfyJFFj4AWdU_4faer3mat7generic3MatINtNtBL_6matown3OwnINtCskC1yiOI7W9g_11num_complex7ComplexdEEENCNCNvB2_4main0s5_0EB2_+0xc96>
   24b22:	mov    rdi,QWORD PTR [rsp+0x8]
   24b27:	shl    rsi,0x3
   24b2b:	mov    edx,0x8
   24b30:	call   QWORD PTR [rip+0x64f9a]        # 89ad0 <_DYNAMIC+0x260>
   24b36:	mov    rdi,rbx
   24b39:	call   85590 <_Unwind_Resume@plt>
