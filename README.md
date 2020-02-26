# Userland Statically Defined Tracing

USDT is a mechanism for user land applications to embed their own probes into executables. The goal is near zero overhead when not invoked.

The steps involved in a USDT probe are as follows:

- Add probe calls, via STAP_PROBE mixin to the source code of the application, probe call is a NOP instruction
- Compile code using either gdc or ldc compiler, dmd does not support USDT probes currently
- Whilst the application is running, you can use external tools to monitor these probes at any granularity you like (eg all probes from the process, or specific probes from all such processes).
- When you monitors the probe, the site where the NOP instruction is placed is modified and an INT3 (breakpoint instruction) is placed at the site of the original NOP instruction. When the breakpoint is hit, kernel takes control and actions the probe. You can use different tools to define actions.

Note: ldc by default enables option "-linker-strip-dead" that eliminates usdt specific section as dead one. Use "-disable-linker-strip-dead" option to prevent this, see [dub.sdl](dub.sdl)

Possible frontends to access the linux kernel tracing subsystem are:
- [systemtap](https://www.sourceware.org/systemtap/)
- [bcc](https://github.com/iovisor/bcc)/[bpftrace](https://github.com/iovisor/bpftrace)
- [lttng](https://github.com/lttng)
- [perf](https://github.com/brendangregg/perf-tools)
- [gdb](https://www.gnu.org/software/gdb/)
- others, not listed here

Brendan Gregg's blog is one of very useful source of important information, for example in [this](http://www.brendangregg.com/blog/2015-07-03/hacking-linux-usdt-ftrace.html) post he writes about USDT and [ftrace](https://www.kernel.org/doc/html/v5.2/trace/ftrace.html).

Usage example:
```D
mixin(USDT_PROBE!("ProviderName", "ProbeName", args...));
```
where `ProviderName` and `ProbeName` describe the probe, args count should be equal or less than 12.

## Known issues
Semaphores currently are not supported