---
title: Tun-Tap-Demo
date: 2019-11-27 09:24:33
tags: 
- 原创
categories: 
- Network
- VPN
---

__阅读更多__

<!--more-->

# 1 Demo

```c
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <net/if.h>
#include <linux/if_tun.h>
#include <sys/ioctl.h>
#include <fcntl.h>

int tun_alloc(char dev[IFNAMSIZ], short flags) {
  	// Interface request structure
  	struct ifreq ifr;

  	// File descriptor
  	int fileDescriptor;

  	// Open the tun device, if it doesn't exists return the error
  	char *cloneDevice = "/dev/net/tun";
  	if ((fileDescriptor = open(cloneDevice, O_RDWR)) < 0) {
    		perror("open /dev/net/tun");
    		return fileDescriptor;
  	}

	printf("open /dev/net/tun in read/write mode successfully\n");

  	// Initialize the ifreq structure with 0s and the set flags
  	memset(&ifr, 0, sizeof(ifr));
  	ifr.ifr_flags = flags;

  	// If a device name is passed we should add it to the ifreq struct
  	// Otherwise the kernel will try to allocate the next available
  	// device of the given type
  	if (*dev) {
    		strncpy(ifr.ifr_name, dev, IFNAMSIZ);
  	}

  	// Ask the kernel to create the new device
  	int err = ioctl(fileDescriptor, TUNSETIFF, (void *) &ifr);
  	if (err < 0) {
    		// If something went wrong close the file and return
    		perror("ioctl TUNSETIFF");
    		close(fileDescriptor);
    		return err;
  	}

	printf("create %s succesfully\n", dev);

  	// Return the file descriptor
  	return fileDescriptor;
}

int send_data(int tapfd, char *packet, int len) {
  	int wlen;
  
  	wlen = write(tapfd, packet, len);
  	if (wlen < 0) {
    		perror("write");
  	}
 
  	return wlen;
}

int receive_data(int tapfd, char *packet, int bufsize) {
  	int len;
 
  	len = read(tapfd, packet, bufsize);
  	if (len < 0) {
		printf("read error\n");
  	} else if(len == 0) {
		printf("no data\n");
	} else {
		printf("read data, len=%d\n", len);
	}
 
  	return len;
}

int main() {
	int tunFd = tun_alloc("tun1", IFF_TUN | IFF_NO_PI);
	if (tunFd < 0) {
   		fprintf(stderr, "Could not open /dev/net/tun\n");
    		return -1;
  	}
	
	char buffer[1000];

	while(1) {
		receive_data(tunFd, buffer, 1000);
	}

}
```

# 2 todo

syscall

# 3 参考 

* [How to interface with the Linux tun driver](https://stackoverflow.com/questions/1003684/how-to-interface-with-the-linux-tun-driver)
* [Tun/Tap interface tutorial](https://backreference.org/2010/03/26/tuntap-interface-tutorial/)
* [Using the TUN/TAP driver to create a serial network connection](http://thgeorgiou.com/posts/2017-03-20-usb-serial-network/)
* [root/Documentation/networking/tuntap.txt](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/Documentation/networking/tuntap.txt?id=HEAD)
* [sakisds/Serial-TUN](https://github.com/sakisds/Serial-TUN)
* [Let's code a TCP/IP stack, 1: Ethernet & ARP](https://www.saminiir.com/lets-code-tcp-ip-stack-1-ethernet-arp/#sources)
* [lab11/go-tuntap](https://github.com/lab11/go-tuntap)
* [songgao/water](https://github.com/songgao/water)
* [How do I set an ip address for TUN interface on OSX (without destination address)?](https://stackoverflow.com/questions/17510101/how-do-i-set-an-ip-address-for-tun-interface-on-osx-without-destination-address)
* [Linux虚拟网络设备之tun/tap](https://segmentfault.com/a/1190000009249039?utm_source=tag-newest)
* [Linux 网络工具详解之 ip tuntap 和 tunctl 创建 tap/tun 设备](https://www.cnblogs.com/bakari/p/10449664.html)