BRAYATAN=$(HOME)/local/brayatan

CC=clang
CFLAGS=-fblocks -fobjc-arc -fobjc-nonfragile-abi -g -I$(BRAYATAN)/include -fexceptions -fobjc-exceptions -fnative-objc-exceptions -D_NATIVE_OBJC_EXCEPTIONS

libbrayatan.a: Http.o Request.o Response.o
	ar rcs libbrayatan.a Http.o Request.o Response.o

install: libbrayatan.a
	cp libbrayatan.a $(BRAYATAN)/lib
	mkdir -p $(BRAYATAN)/include/brayatan/
	cp *.h $(BRAYATAN)/include/brayatan/

Http.o: Http.h Http.m
	$(CC) $(CFLAGS) -c -o Http.o Http.m

Request.o: Request.h Request.m
	$(CC) $(CFLAGS) -c -o Request.o Request.m

Response.o: Response.h Response.m
	$(CC) $(CFLAGS) -c -o Response.o Response.m

clean:
	rm *.o
