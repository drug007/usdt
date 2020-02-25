module usdt;

version(UsdtProbesDisabled)
	enum UsdtProbesDisabled = true;
else
	enum UsdtProbesDisabled = false;

@safe @nogc pure nothrow
template USDT_PROBE(string provider, string name, Args...) if (UsdtProbesDisabled)
{
	enum USDT_PROBE = "{}";
}

@safe @nogc pure nothrow
template USDT_PROBE(string provider, string name, Args...) if (!UsdtProbesDisabled)
{
	static if (Args.length > 12)
	{
		import std.conv : text;
		pragma(msg, "Warning! SystemTap supports up to 12 arguments for probe. ");
		pragma(msg, "You use " ~ Args.length.text ~ " arguments");
		static assert(0);
	}

	private enum USDT_PROBE_GDC = `
		asm @trusted {
			"990: nop
				.pushsection .note.stapsdt,\"?\",\"note\"
				.balign 4
				.4byte 992f-991f, 994f-993f, 3
			991: .asciz \"stapsdt\"
			992: .balign 4
			993: .8byte 990b
				.8byte _.stapsdt.base
				.8byte 0
				.asciz \"%1$s\"
				.asciz \"%2$s\"
				.asciz \"%3$s\"
			994: .balign 4
				.popsection

				.ifndef _.stapsdt.base
					.pushsection .stapsdt.base,\"aG\",\"progbits\", .stapsdt.base, comdat
					.weak _.stapsdt.base
					.hidden _.stapsdt.base
					_.stapsdt.base: .space 1
					.size _.stapsdt.base,1
					.popsection
				.endif"
				:: %4$s;
		}`;

	private enum USDT_PROBE_LDC = "
		import ldc.llvmasm;

		__asm_trusted (
			`990: nop
				.pushsection .note.stapsdt,\"?\",\"note\"
				.balign 4
				.4byte 992f-991f, 994f-993f, 3
			991: .asciz \"stapsdt\"
			992: .balign 4
			993: .8byte 990b
				.8byte _.stapsdt.base
				.8byte 0
				.asciz \"%1$s\"
				.asciz \"%2$s\"
				.asciz \"%3$s\"
			994: .balign 4
				.popsection

				.ifndef _.stapsdt.base
				.pushsection .stapsdt.base,\"aG\",\"progbits\", .stapsdt.base, comdat
				.weak _.stapsdt.base
				.hidden _.stapsdt.base
				_.stapsdt.base: .space 1
				.size _.stapsdt.base,1
				.popsection
				.endif`, \"%4$s\", %5$s
	);";

	import std.format : format;
	version(GNU)
		enum USDT_PROBE = USDT_PROBE_GDC.format(
			provider, 
			name, 
			gdcInputOperands!Args,
			gdcInputOperandValues!Args,
		);
	else version(LDC)
		enum USDT_PROBE = USDT_PROBE_LDC.format(
			provider, 
			name, 
			ldcInputOperands!Args,
			ldcInputOperandConstraints!Args,
			ldcInputOperandValues!Args,
		);
	else version(DigitalMars)
		enum USDT_PROBE = "{}";
	else
		static assert(0, "Unsupported compiler");
}

static this()
{
	version(GNU)
	{

	}
	else version(LDC)
	{

	}
	else version(DigitalMars)
	{
		pragma(msg, "\t[usdt] Attention!");
		pragma(msg, "\t[usdt] Digital Mars compiler (dmd) does not support stap probes.");
		pragma(msg, "\t[usdt] Stap probes are unavailable.");
	}
}

// Helpers

private template ArgSize(Arg)
{
	import std.traits : isSigned;
	static if (isSigned!Arg)
		enum ArgSize = cast(int)  Arg.sizeof;
	else
		enum ArgSize = cast(int) -Arg.sizeof;
}

unittest
{
	assert( ArgSize!int == 4 );
	assert( ArgSize!uint == -4 );
}

private template gdcInputOperands(Args...) if (Args.length == 0)
{
	enum gdcInputOperands = "";
}

private template gdcInputOperands(Args...) if (Args.length)
{
	import std.format : format;
	static if (Args.length > 1)
		enum fmt = "%%n[_SDT_S%1$d]@%%[_SDT_A%1$d] ";
	else
		enum fmt = "%%n[_SDT_S%1$d]@%%[_SDT_A%1$d]";

	enum gdcInputOperands = format(fmt, Args.length) ~ gdcInputOperands!(Args[1..$]);
}

unittest
{
	void func(int a, int b)
	{
		int c;
		assert( gdcInputOperands!() == "" );
		assert( gdcInputOperands!c == "%n[_SDT_S1]@%[_SDT_A1]" );
		assert( gdcInputOperands!(a, b) == "%n[_SDT_S2]@%[_SDT_A2] %n[_SDT_S1]@%[_SDT_A1]" );
	}

	func(1, 2);
}

private template gdcInputOperandValues(Args...) if (Args.length == 0)
{
	enum gdcInputOperandValues = "";
}

private template gdcInputOperandValues(Args...) if (Args.length)
{
	static if (Args.length > 1)
		enum fmt = `[_SDT_S%1$d] "n" (%3$s), [_SDT_A%1$d] "nor" (%2$s), `;
	else
		enum fmt = `[_SDT_S%1$d] "n" (%3$s), [_SDT_A%1$d] "nor" (%2$s)`;

	import std.format : format;

	enum size = ArgSize!(typeof(Args[0]));
	enum gdcInputOperandValues = 
		format(fmt, Args.length, __traits(identifier, Args[0]), size) ~
		gdcInputOperandValues!(Args[1..$]);
}

unittest
{
	void func(int a, short b)
	{
		ubyte c;
		assert( gdcInputOperandValues!() == "" );
		assert( gdcInputOperandValues!(c) == "[_SDT_S1] \"n\" (-1), [_SDT_A1] \"nor\" (c)" );
		assert( gdcInputOperandValues!(a, c) == "[_SDT_S2] \"n\" (4), [_SDT_A2] \"nor\" (a), [_SDT_S1] \"n\" (-1), [_SDT_A1] \"nor\" (c)" );
		assert( gdcInputOperandValues!(a, b, c) == "[_SDT_S3] \"n\" (4), [_SDT_A3] \"nor\" (a), [_SDT_S2] \"n\" (2), [_SDT_A2] \"nor\" (b), [_SDT_S1] \"n\" (-1), [_SDT_A1] \"nor\" (c)" );
	}

	func(1, 2);
}

private template ldcInputOperands(Args...) if (Args.length == 0)
{
	enum ldcInputOperands = "";
}

private template ldcInputOperands(Args...) if (Args.length)
{
	import std.format : format;
	static if (Args.length > 1)
		enum fmt = " ${%d:n}@${%d}";
	else
		enum fmt = "${%d:n}@${%d}";

	enum i = (Args.length-1)*2;
	enum ldcInputOperands = ldcInputOperands!(Args[1..$]) ~ format(fmt, i, i+1);
}

unittest
{
	void func(int a, int b)
	{
		int c;
		assert( ldcInputOperands!() == "" );
		assert( ldcInputOperands!(c) == "${0:n}@${1}" );
		assert( ldcInputOperands!(a, c) == "${0:n}@${1} ${2:n}@${3}" );
	}

	func(1, 2);
}

private template ldcInputOperandConstraints(Args...) if (Args.length == 0)
{
	enum ldcInputOperandConstraints = "";
}

private template ldcInputOperandConstraints(Args...) if (Args.length)
{
	static if (Args.length > 1)
		enum prefix = "n, nor, ";
	else
		enum prefix = "n, nor";

	enum ldcInputOperandConstraints = prefix ~ ldcInputOperandConstraints!(Args[1..$]);
}

unittest
{
	void func(int a, int b)
	{
		int c;
		assert( ldcInputOperandConstraints!() == "" );
		assert( ldcInputOperandConstraints!(c) == "n, nor" );
		assert( ldcInputOperandConstraints!(a, c) == "n, nor, n, nor" );
	}

	func(1, 2);
}

private template ldcInputOperandValues(Args...) if (Args.length == 0)
{
	enum ldcInputOperandValues = "";
}

private template ldcInputOperandValues(Args...) if (Args.length)
{
	import std.format : format;
	static if (Args.length > 1)
		enum fmt = `%1$s, (%2$s), `;
	else
		enum fmt = `%1$s, (%2$s)`;

	enum size = ArgSize!(typeof(Args[0]));
	enum ldcInputOperandValues = format(fmt, size, __traits(identifier, Args[0])) ~ ldcInputOperandValues!(Args[1..$]);
}

unittest
{
	void func(int a, short b)
	{
		ubyte c;
		assert( ldcInputOperandValues!() == "" );
		assert( ldcInputOperandValues!(c) == "-1, (c)" );
		assert( ldcInputOperandValues!(a, c) == "4, (a), -1, (c)" );
		assert( ldcInputOperandValues!(a, b, c) == "4, (a), 2, (b), -1, (c)" );
	}

	func(1, 2);
}

@safe @nogc nothrow pure
unittest
{
	mixin USDT_PROBE!("unit", "test");
}