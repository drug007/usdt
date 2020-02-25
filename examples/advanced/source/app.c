/**
 * see https://blogs.oracle.com/d/adding-dtrace-probes-to-user-code
 * 
 * compile using: `gcc source/sdt.c -osdt`
 */

#include <stdio.h>
#include <sys/sdt.h>
#include <assert.h>
#include <stdlib.h>
#include <unistd.h>

void main()
{
	while(1)
	{
		const int kind = rand() % 5;
		switch (kind)
		{
			case 0:
				DTRACE_PROBE1(advanced, case0, kind);
				usleep(100000);
				DTRACE_PROBE(advanced, case0.return);
			break;
			case 1:
				DTRACE_PROBE1(advanced, case1, kind);
				usleep(100000);
				DTRACE_PROBE(advanced, case1.return);
			break;
			case 2:
				DTRACE_PROBE1(advanced, case2, kind);
				usleep(100000);
				DTRACE_PROBE(advanced, case2.return);
			break;
			case 3:
				DTRACE_PROBE1(advanced, case3, kind);
				usleep(100000);
				DTRACE_PROBE(advanced, case3.return);
			break;
			case 4:
				DTRACE_PROBE1(advanced, case4, kind);
				usleep(100000);
				DTRACE_PROBE(advanced, case4.return);
			break;
			default:
				assert(0);
		}
		printf("Case %d\n", kind);
	}
}