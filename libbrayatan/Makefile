BRAYATAN=$(HOME)/local/brayatan

CC=clang
CFLAGS=-fblocks -fobjc-nonfragile-abi -g -I$(BRAYATAN)/include -D_NATIVE_OBJC_EXCEPTIONS
ARC=-fobjc-arc

libbrayatan.a: Http.o Request.o Response.o linux-miniruntime.o
	ar rcs libbrayatan.a Http.o Request.o Response.o linux-miniruntime.o

install: libbrayatan.a
	cp libbrayatan.a $(BRAYATAN)/lib
	mkdir -p $(BRAYATAN)/include/brayatan/
	cp *.h $(BRAYATAN)/include/brayatan/

linux-miniruntime.o: linux-miniruntime.m
	$(CC) $(CFLAGS) -c -o linux-miniruntime.o linux-miniruntime.m

Http.o: Http.h Http.m
	$(CC) $(CFLAGS) $(ARC) -c -o Http.o Http.m

Request.o: Request.h Request.m
	$(CC) $(CFLAGS) $(ARC) -c -o Request.o Request.m

Response.o: Response.h Response.m
	$(CC) $(CFLAGS) $(ARC) -c -o Response.o Response.m

clean:
	rm *.o *.a
