module advanced;

import std.random : uniform;
import core.thread : Thread;
import std.stdio : writefln;
import std.datetime : dur;

import sdt : STAP_PROBE;

void main() @safe nothrow
{
	try
	{
		const total = 200;
		auto counter = 1;
		while(true)
		{
			enum delay = 400;
			const kind = uniform(0, 5);

			switch (kind)
			{
				case 0:
					mixin(STAP_PROBE!("advanced", "case0", kind));
					() @trusted { Thread.sleep(dur!"msecs"(uniform(delay, 3*delay))); } ();
					mixin(STAP_PROBE!("advanced", "case0_return"));
				break;
				case 1:
					mixin(STAP_PROBE!("advanced", "case1", kind));
					() @trusted { Thread.sleep(dur!"msecs"(uniform(delay, 3*delay))); } ();
					mixin(STAP_PROBE!("advanced", "case1_return"));
				break;
				case 2:
					mixin(STAP_PROBE!("advanced", "case2", kind));
					() @trusted { Thread.sleep(dur!"msecs"(uniform(delay, 3*delay))); } ();
					mixin(STAP_PROBE!("advanced", "case2_return"));
				break;
				case 3:
					mixin(STAP_PROBE!("advanced", "case3", kind));
					() @trusted { Thread.sleep(dur!"msecs"(uniform(delay, 3*delay))); } ();
					mixin(STAP_PROBE!("advanced", "case3_return"));
				break;
				case 4:
					mixin(STAP_PROBE!("advanced", "case4", kind));
					() @trusted { Thread.sleep(dur!"msecs"(uniform(delay, 3*delay))); } ();
					mixin(STAP_PROBE!("advanced", "case4_return"));
				break;
				default:
					assert(0);
			}
			writefln("%d:\tCase %d", counter, kind);
			if (++counter > total)
				break;
		}
	}
	catch(Exception)
	{

	}
}