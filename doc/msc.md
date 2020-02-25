Check if the kernel supports uprobe:
```
cat /boot/config-`uname -r` | grep CONFIG_UPROBE_EVENTS
```
Uprobe-based Event Tracing: https://www.kernel.org/doc/Documentation/trace/uprobetracer.txt
