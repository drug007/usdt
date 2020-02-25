/**
 * this is the version of sdt.c with manual expansion of the DTRACE_PROBE2 macro
 * 
 * compile using: `gcc source/sdt_expanded.c -ocsdt` or `clang source/sdt_expanded.c -ocsdt`
 */

#include <stdio.h>
#include <sys/sdt.h>

void func(int a, int b)
{
	// the macro DTRACE_PROBE2(myapp, func_call, a, b); expanded to the following:
	// start of the macro expansion
	__asm__ __volatile__ (
		"990: nop\n"                                                              \
		".pushsection .note.stapsdt,\"?\",\"note\"\n"                             \
		".balign 4\n"                                                             \
		".4byte 992f-991f, 994f-993f, 3\n"                                        \
		"991: .asciz \"stapsdt\"\n"                                               \
		"992: .balign 4\n"                                                        \
		"993: .8byte 990b\n"                                                      \
		".8byte _.stapsdt.base\n"                                                 \
		".8byte 0\n"                                                              \
		".asciz \"myapp\"\n"                                                      \
		".asciz \"func_call\"\n"                                                  \
		".asciz \"%n[_SDT_S1]@%[_SDT_A1] %n[_SDT_S2]@%[_SDT_A2]\"\n"              \
		"994: .balign 4\n"                                                        \
		".popsection\n"
		:: [_SDT_S1] "n" (4),
			[_SDT_A1] "nor" ((a)), 
			[_SDT_S2] "n" (4), 
			[_SDT_A2] "nor" ((b))
	); 

	__asm__ __volatile__ (
		".ifndef _.stapsdt.base\n"                                                \
		".pushsection .stapsdt.base,\"aG\",\"progbits\", .stapsdt.base, comdat\n" \
		".weak _.stapsdt.base\n"                                                  \
		".hidden _.stapsdt.base\n"                                                \
		"_.stapsdt.base: .space 1\n"                                              \
		".size _.stapsdt.base,1\n"                                                \
		".popsection\n"                                                           \
		".endif"
	);
	// end of the macro expansion
	printf("a=%i, b=%i\n", a, b);
}

void main()
{
	func(1,2);
	func(2,3);
}
