BRAYATAN=$(HOME)/local/brayatan

CC=clang
CFLAGS=-fblocks -fobjc-nonfragile-abi -I$(BRAYATAN)/include -I$(BRAYATAN)/include/kqueue -I$(BRAYATAN)/include/GRMustache -include $(BRAYATAN)/include/GRMustache/brayatan-osx-compat.h -I/usr/include/kqueue -D_NATIVE_OBJC_EXCEPTIONS -O2
ARC=-fobjc-arc

libbrayatan.a: Http.o Request.o Response.o linux-miniruntime.o brayatan-core.o
	ar rcs libbrayatan.a Http.o Request.o Response.o linux-miniruntime.o brayatan-core.o

install: libbrayatan.a
	cp libbrayatan.a $(BRAYATAN)/lib
	mkdir -p $(BRAYATAN)/include/brayatan/
	cp *.h $(BRAYATAN)/include/brayatan/

linux-miniruntime.o: linux-miniruntime.m
	$(CC) $(CFLAGS) -c -o linux-miniruntime.o linux-miniruntime.m

brayatan-core.o: brayatan-core.m
	$(CC) $(CFLAGS) $(ARC) -c -o brayatan-core.o brayatan-core.m

Http.o: Http.h Http.m
	$(CC) $(CFLAGS) $(ARC) -c -o Http.o Http.m

Request.o: Request.h Request.m
	$(CC) $(CFLAGS) $(ARC) -c -o Request.o Request.m

Response.o: Response.h Response.m
	$(CC) $(CFLAGS) $(ARC) -c -o Response.o Response.m

clean:
	rm -f *.o *.a
