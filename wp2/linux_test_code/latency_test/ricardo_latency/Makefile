ifdef ARM
   CC=arm-xilinx-linux-gnueabi-gcc
endif

latency: check_latency.c read_evt.c sock_conn.c;\
	$(CC) check_latency.c read_evt.c sock_conn.c -I. -Ifpga/ -lrt -o $@

clean:;\
	rm latency

