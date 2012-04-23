BRAYATAN:=$(HOME)/local/brayatan
PATH:=$(BRAYATAN)/bin:$(PATH)
NUMCORES=`cat /proc/cpuinfo | grep ^processor | wc -l`

all: build-libbrayatan

clean:
	rm -fr clang-3.0.src llvm-3.0.src libffi-3.0.10 build-* CF-635/ icu/ libBlocksRuntime-0.1/ libdispatch-0~svn197/ libkqueue-1.0.6/ libobjc2-1.6/ gnustep-base-svn/ gnustep-make-svn/ gnustep-corebase-svn/ svn-gnustep-base svn-gnustep-make svn-gnustep-corebase

clean-all: clean
	rm -fr wget-* *.gz *.bz2 svn-*

wget-libffi:
	@ echo "Downloading libffi"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/libf/libffi/libffi_3.0.10.orig.tar.gz
	@ touch wget-libffi

build-libffi: wget-libffi
	@ echo "Configuring libffi"
	@ tar xfz libffi_3.0.10.orig.tar.gz
	@ cd libffi-3.0.10 && CC=gcc CXX=g++ CFLAGS="-g -O2" CCASFLAGS="-g -O2 -Wa,--gdwarf2" LDFLAGS="-Wl,-z,defs -Wl,-Bsymbolic-functions" ./configure --prefix=$(BRAYATAN) > ../build-libffi.log 2>&1
	@ echo "Building libffi"
	@ cd libffi-3.0.10 && make -j4 install >> ../build-libffi.log 2>&1
	@ mkdir -p $(BRAYATAN)/include/
	@ cp $(BRAYATAN)/lib/libffi-3.0.10/include/*.h $(BRAYATAN)/include/
	@ mv build-libffi.log build-libffi

wget-clang:
	@ echo "Downloading clang"
	@ wget -Ncq http://llvm.org/releases/3.0/clang-3.0.tar.gz
	@ touch wget-clang

wget-llvm:
	@ echo "Downloading llvm"
	@ wget -Ncq http://llvm.org/releases/3.0/llvm-3.0.tar.gz
	@ touch wget-llvm

build-llvm-clang: wget-clang wget-llvm build-libffi
	@ echo "Configuring llvm clang"
	@ tar xfz llvm-3.0.tar.gz
	@ tar xfz clang-3.0.tar.gz
	@ mv clang-3.0.src llvm-3.0.src/tools/clang
	@ cd llvm-3.0.src && LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) --disable-assertions --enable-optimized --enable-pic --enable-libffi --enable-shared > ../build-llvm-clang.log 2>&1
	@ echo "Building llvm clang"
	@ cd llvm-3.0.src && make -j4 install >> ../build-llvm-clang.log 2>&1
	@ mv build-llvm-clang.log build-llvm-clang

wget-blocksruntime:
	@ echo "Downloading blocksruntime"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/libb/libblocksruntime/libblocksruntime_0.1.orig.tar.gz
	@ touch wget-blocksruntime

build-blocksruntime: wget-blocksruntime build-llvm-clang
	@ echo "Configuring blocksruntime"
	@ tar xfz libblocksruntime_0.1.orig.tar.gz
	@ cd libBlocksRuntime-0.1 && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) > ../build-blocksruntime.log 2>&1
	@ echo "Building blocksruntime"
	@ cd libBlocksRuntime-0.1 && make -j$(NUMCORES) install >> ../build-blocksruntime.log 2>&1
	@ mv build-blocksruntime.log build-blocksruntime

wget-libobjc2:
	@ echo "Downloading libobjc2"
	@ wget -Ncq http://download.gna.org/gnustep/libobjc2-1.6.tar.bz2
	@ touch wget-libobjc2

build-libobjc2: wget-libobjc2 build-blocksruntime
	@ echo "Configuring libobjc2"
	@ tar xfj libobjc2-1.6.tar.bz2
	@ echo "Building libobjc2"
	@ cd libobjc2-1.6 && CC=clang CXX=clang++ PREFIX=$(BRAYATAN) make -f Makefile install > ../build-libobjc2.log 2>&1
	@ mv build-libobjc2.log build-libobjc2

wget-icu:
	@ echo "Downloading icu"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/i/icu/icu_4.8.1.1.orig.tar.gz
	@ touch wget-icu

build-icu: wget-icu build-libobjc2
	@ echo "Configuring icu"
	@ tar xfz icu_4.8.1.1.orig.tar.gz
	@ cd icu/source && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) --disable-maintainer-mode --disable-dependency-tracking --disable-samples --enable-static --enable-weak-threads > ../../build-icu.log 2>&1
	@ echo "Building icu"
	@ cd icu/source && make -j$(NUMCORES) install >> ../../build-icu.log 2>&1
	@ mv build-icu.log build-icu

wget-libkqueue:
	@ echo "Downloading libkqueue"
	@ wget -Ncq http://mark.heily.com/sites/mark.heily.com/files/libkqueue-1.0.6.tar.gz
	@ touch wget-libkqueue

build-libkqueue: wget-libkqueue build-icu
	@ echo "Configuring libkqueue"
	@ tar xfz libkqueue-1.0.6.tar.gz
	cd libkqueue-1.0.6 && CC=clang ./configure --prefix=$(BRAYATAN) > ../build-libkqueue.log 2>&1
	@ echo "Building libkqueue"
	@ cd libkqueue-1.0.6 && make -j$(NUMCORES) >> ../build-libkqueue.log 2>&1
	@ cd libkqueue-1.0.6 && make -j$(NUMCORES) install >> ../build-libkqueue.log 2>&1
	@ mv build-libkqueue.log build-libkqueue

wget-libdispatch:
	@ echo "Downloading libdispatch"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/libd/libdispatch/libdispatch_0~svn197.orig.tar.gz
	@ touch wget-libdispatch

build-libdispatch: wget-libdispatch build-libkqueue
	@ echo "Configuring libdispatch"
	@ tar xfz libdispatch_0~svn197.orig.tar.gz
	@ cp /usr/include/unistd.h $(BRAYATAN)/include
	@ perl -p -i -e 's/__block/___block/' $(BRAYATAN)/include/unistd.h
	@ patch -p 0 < patch-libdispatch
	@ cd libdispatch-0~svn197 && CC=clang CFLAGS="-I$(BRAYATAN)/include" KQUEUE_CFLAGS="-I$(BRAYATAN)/include/kqueue" KQUEUE_LIBS="-L$(BRAYATAN)/lib" LDFLAGS="-L$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) > ../build-libdispatch.log 2>&1
	@ echo "Building libdispatch"
	@ cd libdispatch-0~svn197 && make -j$(NUMCORES) install >> ../build-libdispatch.log 2>&1
	@ mv build-libdispatch.log build-libdispatch

wget-libcorefoundation:
	@ echo "Downloading libcorefoundation"
	@ wget -Ncq http://www.heily.com/debian/unstable/libcorefoundation_635.orig.tar.gz
	@ touch wget-libcorefoundation

build-libcorefoundation: wget-libcorefoundation build-libdispatch
	@ echo "Configuring libcorefoundation"
	@ tar xfz libcorefoundation_635.orig.tar.gz
	@ cd CF-635 && patch < ../patch-libcorefoundation > ../build-libcorefoundation.log 2>&1
	@ echo "Building libcorefoundation"
	@ cd CF-635 && BRAYATAN=$(BRAYATAN) make install >> ../build-libcorefoundation.log 2>&1
	@ mv build-libcorefoundation.log build-libcorefoundation

svn-gnustep-make:
	@ echo "SVN Cloning gnustep-make"
	@ svn co -q http://svn.gna.org/svn/gnustep/tools/make/trunk/ gnustep-make-svn
	@ touch svn-gnustep-make

build-gnustep-make: svn-gnustep-make build-libdispatch
	@ echo "Configuring gnustep-make"
	@ cd gnustep-make-svn && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) > ../build-gnustep-make.log 2>&1
	@ echo "Building gnustep-make"
	@ cd gnustep-make-svn && make -j$(NUMCORES) install >> ../build-gnustep-make.log 2>&1
	@ mv build-gnustep-make.log build-gnustep-make

svn-gnustep-corebase:
	@ echo "SVN Cloning gnustep-corebase"
	@ svn co -q http://svn.gna.org/svn/gnustep/libs/corebase/trunk/ gnustep-corebase-svn
	@ touch svn-gnustep-corebase

build-gnustep-corebase: svn-gnustep-corebase build-gnustep-base
	@ echo "Configuring gnustep-corebase"
	@ cd gnustep-corebase-svn && CC=clang CXX=clang++ CFLAGS="-I$(BRAYATAN)/include" ./configure --prefix=$(BRAYATAN) > ../build-gnustep-corebase.log 2>&1
	@ echo "Building gnustep-corebase"
	@ cd gnustep-corebase-svn && make -j$(NUMCORES) install >> ../build-gnustep-corebase.log 2>&1
	@ mv build-gnustep-corebase.log build-gnustep-corebase

svn-gnustep-base:
	@ echo "SVN Cloning gnustep-base"
	@ svn co -q http://svn.gna.org/svn/gnustep/libs/base/trunk/ gnustep-base-svn
	@ touch svn-gnustep-base

build-gnustep-base: svn-gnustep-base build-gnustep-make
	@ echo "Configuring gnustep-base"
	@ cd gnustep-base-svn && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) --disable-xml --disable-tls > ../build-gnustep-base.log 2>&1
	@ echo "Building gnustep-base"
	@ cd gnustep-base-svn && make -j$(NUMCORES) install >> ../build-gnustep-base.log 2>&1
	@ mv build-gnustep-base.log build-gnustep-base

build-libuv: build-llvm-clang
	@ echo "Building libuv"
	@ make -C ../../libuv uv.a > build-libuv.log
	@ cp ../../libuv/uv.a $(BRAYATAN)/lib/libuv.a
	@ cp -r ../../libuv/include/* $(BRAYATAN)/include/
	@ mv build-libuv.log build-libuv

build-libhttp_parser: build-llvm-clang
	@ echo "Building libhttp_parser"
	@ make -C ../../libhttp_parser package > build-libhttp_parser.log
	@ cp ../../libhttp_parser/libhttp_parser.a $(BRAYATAN)/lib/libhttp_parser.a
	@ cp -r ../../libhttp_parser/http_parser.h $(BRAYATAN)/include/
	@ mv build-libhttp_parser.log build-libhttp_parser

build-libbrayatan: build-gnustep-base build-libhttp_parser build-libuv
	@ echo "Building libbrayatan"
	@ make -C ../../libbrayatan install > build-libbrayatan.log
	@ cp ../bin/brayatan-cc $(BRAYATAN)/bin
	@ mv build-libbrayatan.log build-libbrayatan
	@ echo "DONE."
	@ echo
	@ echo '---------------------------------------------------'
	@ echo 'Do not forget to add the following to your .profile'
	@ echo
	@ echo 'export BRAYATAN=$$HOME/brayatan'
	@ echo 'export PATH=$$BRAYATAN/bin:$$PATH' 
	@ echo
	@ echo '---------------------------------------------------'
	@ echo 
