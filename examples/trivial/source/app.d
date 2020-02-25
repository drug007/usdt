import std.stdio;

/**
 * see https://blogs.oracle.com/d/adding-dtrace-probes-to-user-code
 * 
 * compile using: `gcc source/sdt.c -osdt`
 */

/*
 * to check binary output use `readelf -x .note.stapsdt ./usdt`
 * output should like this:
 * GDC 6.3 `dub --compiler=gdc`
 * ```
 * Hex dump of section '.note.stapsdt':
 *   0x00000000 08000000 40000000 03000000 73746170 ....@.......stap
 *   0x00000010 73647400 f7ff0100 00000000 22700a00 sdt........."p..
 *   0x00000020 00000000 00000000 00000000 6d796170 ............myap
 *   0x00000030 70006675 6e635f63 616c6c00 2d34402d p.func_call.-4@-
 *   0x00000040 34282572 62702920 2d34402d 38282572 4(%rbp) -4@-8(%r
 *   0x00000050 62702900                            bp).
 * ```
 * ldc-1.18 `dub --compiler=ldc2`
 * ```
 * Hex dump of section '.note.stapsdt':
 *  0x00000000 08000000 42000000 03000000 73746170 ....B.......stap
 *  0x00000010 73647400 4af70100 00000000 00000000 sdt.J...........
 *  0x00000020 00000000 00000000 00000000 6d796170 ............myap
 *  0x00000030 70006675 6e635f63 616c6c00 2d34402d p.func_call.-4@-
 *  0x00000040 31322825 72627029 202d3440 2d313628 12(%rbp) -4@-16(
 *  0x00000050 25726270 29000000                   %rbp)...
 * ```
 */

void func(int a, int b)
{
	import sdt : STAP_PROBE;

	mixin(STAP_PROBE!("myapp", "func_call"));//, a, b));
	writefln("a=%d, b=%d", a, b);
}

void main()
{
	func(1,2);
	func(2,3);
}