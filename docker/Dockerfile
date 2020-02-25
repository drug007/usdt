FROM debian:stretch
ENV KERNELVER=4.15.3
RUN apt-get update && apt-get --yes install build-essential cmake bc curl \
	diffutils git kmod libcurl4-openssl-dev wget systemtap systemtap-sdt-dev && \
	cd / && curl -o linux-${KERNELVER}.tar.gz https://mirrors.edge.kernel.org/pub/linux/kernel/v4.x/linux-${KERNELVER}.tar.gz && \
	tar zxf linux-${KERNELVER}.tar.gz && \
	cd linux-${KERNELVER} && zcat /proc/1/root/proc/config.gz > .config && \
	make all && make modules_prepare && make headers_install && make modules_install