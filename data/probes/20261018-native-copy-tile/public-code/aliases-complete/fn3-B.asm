
/home/shinaoka/projects/tensor4all/faer-benchmark/target/probe-native-copy/60de2ee06467/release/owned-copy-probe:     file format elf64-x86-64


Disassembly of section .text:

000000000002cfc0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe>:
   2cfc0:	mov    r10,rdx
   2cfc3:	sub    r10,rcx
   2cfc6:	jbe    2d0be <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   2cfcc:	mov    rax,QWORD PTR [r8]
   2cfcf:	mov    rsi,QWORD PTR [rax+0x18]
   2cfd3:	imul   r9,QWORD PTR [rax+0x20]
   2cfd8:	shl    r9,0x4
   2cfdc:	add    r9,QWORD PTR [rax]
   2cfdf:	cmp    r10,0x4
   2cfe3:	setae  al
   2cfe6:	cmp    rsi,0x1
   2cfea:	sete   r8b
   2cfee:	and    r8b,al
   2cff1:	cmp    r8b,0x1
   2cff5:	jne    2d038 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x78>
   2cff7:	mov    r8,r10
   2cffa:	and    r8,0xfffffffffffffffe
   2cffe:	lea    rax,[rcx+r8*1]
   2d002:	shl    rcx,0x4
   2d006:	add    rcx,0x10
   2d00a:	mov    r11,r8
   2d00d:	nop    DWORD PTR [rax]
   2d010:	movups xmm0,XMMWORD PTR [r9+rcx*1-0x10]
   2d016:	movups xmm1,XMMWORD PTR [r9+rcx*1]
   2d01b:	movups XMMWORD PTR [rdi+rcx*1-0x10],xmm0
   2d020:	movups XMMWORD PTR [rdi+rcx*1],xmm1
   2d024:	add    rcx,0x20
   2d028:	add    r11,0xfffffffffffffffe
   2d02c:	jne    2d010 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x50>
   2d02e:	cmp    r10,r8
   2d031:	jne    2d03b <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0x7b>
   2d033:	jmp    2d0be <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   2d038:	mov    rax,rcx
   2d03b:	mov    r8d,edx
   2d03e:	sub    r8d,eax
   2d041:	lea    rcx,[rax+0x1]
   2d045:	test   r8b,0x1
   2d049:	je     2d066 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xa6>
   2d04b:	mov    r8,rax
   2d04e:	imul   r8,rsi
   2d052:	shl    r8,0x4
   2d056:	shl    rax,0x4
   2d05a:	movups xmm0,XMMWORD PTR [r9+r8*1]
   2d05f:	movups XMMWORD PTR [rdi+rax*1],xmm0
   2d063:	mov    rax,rcx
   2d066:	cmp    rdx,rcx
   2d069:	je     2d0be <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xfe>
   2d06b:	sub    rdx,rax
   2d06e:	mov    rcx,rax
   2d071:	shl    rcx,0x4
   2d075:	add    rcx,rdi
   2d078:	add    rcx,0x10
   2d07c:	mov    rdi,rax
   2d07f:	imul   rdi,rsi
   2d083:	shl    rdi,0x4
   2d087:	mov    r8,rsi
   2d08a:	shl    r8,0x5
   2d08e:	inc    rax
   2d091:	imul   rax,rsi
   2d095:	shl    rax,0x4
   2d099:	nop    DWORD PTR [rax+0x0]
   2d0a0:	movups xmm0,XMMWORD PTR [r9+rdi*1]
   2d0a5:	movups XMMWORD PTR [rcx-0x10],xmm0
   2d0a9:	movups xmm0,XMMWORD PTR [r9+rax*1]
   2d0ae:	movups XMMWORD PTR [rcx],xmm0
   2d0b1:	add    rcx,0x20
   2d0b5:	add    r9,r8
   2d0b8:	add    rdx,0xfffffffffffffffe
   2d0bc:	jne    2d0a0 <_RINvNtNtCsfyJFFj4AWdU_4faer3mat6matown16noalias_annotateINtCskC1yiOI7W9g_11num_complex7ComplexdENtNtNtB6_5utils5bound3DimB1w_NCINvNvMsa_NtB4_6matrefINtNtB4_7generic3MatpE6cloned3impBS_iiE0ECskuD9mmv22aj_16owned_copy_probe+0xe0>
   2d0be:	ret
