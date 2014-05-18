BRAYATAN:=$(HOME)/local/brayatan
PATH:=$(BRAYATAN)/bin:$(PATH)
NUMCORES=`cat /proc/cpuinfo | grep -i ^processor | wc -l`

all: .make-libbrayatan

clean:
	rm -fr clang-*.src llvm-*.src libffi-3.0.11 .make-* CF-635/ icu/ libBlocksRuntime-0.1/ libdispatch-0~svn197/ libkqueue-1.0.6/ libobjc2-1.6/ gnustep-base-svn/ gnustep-make-svn/ gnustep-corebase-svn/ svn-gnustep-base svn-gnustep-make svn-gnustep-corebase gnustep-corebase gnustep-base gnustep-libobjc2

clean-all: clean
	rm -fr .wget-* .conf-* *.gz *.bz2 svn-* .clone-* *.log *.tar

.backup: .wget-libffi .wget-clang .wget-llvm .wget-blocksruntime .wget-libobjc2 .wget-icu .wget-libkqueue .wget-libdispatch .wget-libcorefoundation .clone-gnustep-make .clone-gnustep-corebase .clone-gnustep-base
	@ mkdir -p .backup
	@ tar cf gnustep.tar gnustep-*
	@ cp -r *.tar.gz *.tar.bz2 *.tar .backup

.all-but-llvm: .backup clean-all
	@ cp -r .backup/* .
	@ rm -fr gnustep-*
	@ tar xf gnustep.tar
	@ touch .wget-libffi .wget-clang .wget-llvm .wget-blocksruntime .wget-libobjc2 .wget-icu .wget-libkqueue .wget-libdispatch .wget-libcorefoundation .clone-gnustep-make .clone-gnustep-corebase .clone-gnustep-base
	@ make .make-libffi
	@ touch .make-llvm-clang .conf-llvm-clang

all-but-llvm: .all-but-llvm all

libffi: .make-libffi
llvm-clang: .make-llvm-clang
libffi-2: .make-libffi-2
blocksruntime: .make-blocksruntime
libobjc2: .make-libobjc2
icu: .make-icu
libkqueue: .make-libkqueue
libdispatch: .make-libdispatch
libcorefoundation: .make-libcorefoundation
gnustep-make: .make-gnustep-make
gnustep-corebase: .make-gnustep-corebase
gnustep-base: .make-gnustep-base
libhttp_parser: .make-libhttp_parser
libbrayatan: .make-libbrayatan

.wget-libffi:
	@ echo `date +%s` `date` "Downloading libffi"
	@ wget -Ncq ftp://sourceware.org/pub/libffi//libffi-3.0.11.tar.gz
	@ touch .wget-libffi

.conf-libffi: .wget-libffi
	@ echo `date +%s` `date` "Configuring libffi"
	@ rm -fr libffi-3.0.11
	@ tar xfz libffi-3.0.11.tar.gz
	@ cd libffi-3.0.11 && CC=gcc CXX=g++ CFLAGS="-g -O2" CCASFLAGS="-g -O2 -Wa,--gdwarf2" LDFLAGS="-Wl,-z,defs -Wl,-Bsymbolic-functions" ./configure --prefix=$(BRAYATAN) > ../conf-libffi.log 2>&1
	@ mv conf-libffi.log .conf-libffi

.make-libffi: .conf-libffi
	@ echo `date +%s` `date` "Building libffi"
	@ cd libffi-3.0.11 && make -j$(NUMCORES) install > ../make-libffi.log 2>&1
	@ mkdir -p $(BRAYATAN)/include/
	@ cp $(BRAYATAN)/lib/libffi-3.0.11/include/*.h $(BRAYATAN)/include
	@ mv make-libffi.log .make-libffi

clean-libffi:
	@ rm -fr libffi-3.0.11

.wget-clang:
	@ echo `date +%s` `date` "Downloading clang"
	@ wget -Ncq http://llvm.org/releases/3.2/clang-3.2.src.tar.gz
	@ touch .wget-clang

.wget-llvm:
	@ echo `date +%s` `date` "Downloading llvm"
	@ wget -Ncq http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz
	@ touch .wget-llvm

.conf-llvm-clang: .wget-clang .wget-llvm .make-libffi
	@ echo `date +%s` `date` "Configuring llvm clang"
	@ rm -fr llvm-3.2.src
	@ tar xfz llvm-3.2.src.tar.gz
	@ tar xfz clang-3.2.src.tar.gz
	@ mv clang-3.2.src llvm-3.2.src/tools/clang
	@ cd llvm-3.2.src && LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) --disable-assertions --enable-optimized --enable-pic --enable-libffi --enable-shared > ../conf-llvm-clang.log 2>&1
	@ mv conf-llvm-clang.log .conf-llvm-clang

.make-llvm-clang: .conf-llvm-clang
	@ echo `date +%s` `date` "Building llvm clang"
	@ cd llvm-3.2.src && make -j$(NUMCORES) install > ../make-llvm-clang.log 2>&1
	@ mv make-llvm-clang.log .make-llvm-clang

clean-llvm-clang:
	@ rm -fr llvm-3.2.src

.conf-libffi-2: .wget-libffi
	@ echo `date +%s` `date` "Configuring libffi-2"
	@ rm -fr libffi-3.0.11
	@ tar xfz libffi-3.0.11.tar.gz
	@ cd libffi-3.0.11 && CC=clang CXX=clang++ CFLAGS="-g -O2" CCASFLAGS="-g -O2" LDFLAGS="-Wl,-z,defs -Wl,-Bsymbolic-functions -L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) > ../conf-libffi-2.log 2>&1
	@ mv conf-libffi-2.log .conf-libffi-2

.make-libffi-2: .conf-libffi-2
	@ echo `date +%s` `date` "Building libffi"
	@ cd libffi-3.0.11 && make -j$(NUMCORES) install > ../make-libffi-2.log 2>&1
	@ mkdir -p $(BRAYATAN)/include/
	@ cp $(BRAYATAN)/lib/libffi-3.0.11/include/*.h $(BRAYATAN)/include
	@ mv make-libffi-2.log .make-libffi-2

.wget-blocksruntime:
	@ echo `date +%s` `date` "Downloading blocksruntime"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/libb/libblocksruntime/libblocksruntime_0.1.orig.tar.gz
	@ touch .wget-blocksruntime

.conf-blocksruntime: .wget-blocksruntime .make-llvm-clang
	@ echo `date +%s` `date` "Configuring blocksruntime"
	@ tar xfz libblocksruntime_0.1.orig.tar.gz
	@ cd libBlocksRuntime-0.1 && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) > ../conf-blocksruntime.log 2>&1
	@ mv conf-blocksruntime.log .conf-blocksruntime

.make-blocksruntime: .conf-blocksruntime
	@ echo `date +%s` `date` "Building blocksruntime"
	@ cd libBlocksRuntime-0.1 && make -j$(NUMCORES) install >> ../make-blocksruntime.log 2>&1
	@ mv make-blocksruntime.log .make-blocksruntime

clean-blocksruntime:
	@ rm -fr libBlocksRuntime-0.1

.wget-libobjc2:
	@ echo `date +%s` `date` "Downloading libobjc2"
	@ wget -Ncq http://download.gna.org/gnustep/libobjc2-1.6.tar.bz2
	@ touch .wget-libobjc2

.conf-libobjc2: .wget-libobjc2 .make-blocksruntime
	@ echo `date +%s` `date` "Configuring libobjc2"
	@ rm -fr libobjc2-1.6
	@ tar xfj libobjc2-1.6.tar.bz2
	@ touch .conf-libobjc2
  
.make-libobjc2: .conf-libobjc2
	@ echo `date +%s` `date` "Building libobjc2"
	@ cd libobjc2-1.6 && CC=clang CXX=clang++ PREFIX=$(BRAYATAN) make -f Makefile install > ../make-libobjc2.log 2>&1
	@ mv make-libobjc2.log .make-libobjc2

clean-libobjc2:
	@ rm -fr libobjc2-1.6

.wget-icu:
	@ echo `date +%s` `date` "Downloading icu"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/i/icu/icu_4.8.1.1.orig.tar.gz
	@ touch .wget-icu

.conf-icu: .wget-icu .make-libobjc2
	@ echo `date +%s` `date` "Configuring icu"
	@ tar xfz icu_4.8.1.1.orig.tar.gz
	@ cd icu/source && CC=clang CXX=clang++ ./configure --prefix=$(BRAYATAN) --disable-maintainer-mode --disable-dependency-tracking --disable-samples --enable-static --enable-weak-threads > ../../conf-icu.log 2>&1
	@ mv conf-icu.log .conf-icu

.make-icu: .conf-icu
	@ echo `date +%s` `date` "Building icu"
	@ cd icu/source && make -j$(NUMCORES) install > ../../make-icu.log 2>&1
	@ mv make-icu.log .make-icu

clean-icu:
	@ rm -fr icu

.wget-libkqueue:
	@ echo `date +%s` `date` "Downloading libkqueue"
	@ wget -Ncq http://sourceforge.net/projects/libkqueue/files/libkqueue-1.0/libkqueue-1.0.6.tar.gz/download -O libkqueue-1.0.6.tar.gz
	@ touch .wget-libkqueue

.conf-libkqueue: .wget-libkqueue .make-icu
	@ echo `date +%s` `date` "Configuring libkqueue"
	@ rm -fr libkqueue-1.0.6
	@ tar xfz libkqueue-1.0.6.tar.gz
	@ cd libkqueue-1.0.6 && CC=clang CFLAGS="-O2" ./configure --prefix=$(BRAYATAN) > ../conf-libkqueue.log 2>&1
	@ mv conf-libkqueue.log .conf-libkqueue

.make-libkqueue: .conf-libkqueue
	@ echo `date +%s` `date` "Building libkqueue"
	@ cd libkqueue-1.0.6 && make -j$(NUMCORES) > ../make-libkqueue.log 2>&1
	@ cd libkqueue-1.0.6 && make -j$(NUMCORES) install >> ../make-libkqueue.log 2>&1
	@ mv make-libkqueue.log .make-libkqueue

clean-libkqueue:
	@ rm -fr libkqueue-1.0.6

.wget-libdispatch:
	@ echo `date +%s` `date` "Downloading libdispatch"
	@ wget -Ncq http://ftp.de.debian.org/debian/pool/main/libd/libdispatch/libdispatch_0~svn197.orig.tar.gz
	@ touch .wget-libdispatch

.conf-libdispatch: .wget-libdispatch .make-libkqueue
	@ echo `date +%s` `date` "Configuring libdispatch"
	@ tar xfz libdispatch_0~svn197.orig.tar.gz
	@ cp /usr/include/unistd.h $(BRAYATAN)/include
	@ perl -p -i -e 's/__block/___block/' $(BRAYATAN)/include/unistd.h
	@ patch -p 0 < patch-libdispatch
	@ cd libdispatch-0~svn197 && CC=clang CFLAGS="-I$(BRAYATAN)/include -O2 -DDISPATCH_LINUX_COMPAT" KQUEUE_CFLAGS="-I$(BRAYATAN)/include/kqueue" KQUEUE_LIBS="-L$(BRAYATAN)/lib" LDFLAGS="-L$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) > ../conf-libdispatch.log 2>&1
	@ mv conf-libdispatch.log .conf-libdispatch

.make-libdispatch: .conf-libdispatch
	@ echo `date +%s` `date` "Building libdispatch"
	@ cd libdispatch-0~svn197 && make -j$(NUMCORES) install > ../make-libdispatch.log 2>&1
	@ mv make-libdispatch.log .make-libdispatch

clean-libdispatch:
	@ rm -fr libdispatch-0~svn197

.wget-libcorefoundation:
	@ echo `date +%s` `date` "Downloading libcorefoundation"
	@ wget -Ncq http://www.heily.com/debian/unstable/libcorefoundation_635.orig.tar.gz
	@ touch .wget-libcorefoundation

.conf-libcorefoundation: .wget-libcorefoundation .make-libdispatch
	@ echo `date +%s` `date` "Configuring libcorefoundation"
	@ tar xfz libcorefoundation_635.orig.tar.gz
	@ cd CF-635 && patch < ../patch-libcorefoundation > ../conf-libcorefoundation.log 2>&1
	@ mv conf-libcorefoundation.log .conf-libcorefoundation

.make-libcorefoundation: .conf-libcorefoundation
	@ echo `date +%s` `date` "Building libcorefoundation"
	@ cd CF-635 && BRAYATAN=$(BRAYATAN) make install > ../make-libcorefoundation.log 2>&1
	@ mv make-libcorefoundation.log .make-libcorefoundation

clean-libcorefoundation:
	@ rm -fr CF-635

.clone-gnustep-make:
	@ echo `date +%s` `date` "SVN Cloning gnustep-make"
	@ svn co -q http://svn.gna.org/svn/gnustep/tools/make/trunk/ gnustep-make-svn
	@ touch .clone-gnustep-make

.conf-gnustep-make: .clone-gnustep-make .make-libdispatch
	@ echo `date +%s` `date` "Configuring gnustep-make"
	@ cd gnustep-make-svn && CC=clang CXX=clang++ LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) > ../conf-gnustep-make.log 2>&1
	@ mv conf-gnustep-make.log .conf-gnustep-make

.make-gnustep-make: .conf-gnustep-make
	@ echo `date +%s` `date` "Building gnustep-make"
	@ cd gnustep-make-svn && make -j$(NUMCORES) install > ../make-gnustep-make.log 2>&1
	@ mv make-gnustep-make.log .make-gnustep-make

clean-gnustep-make:
	@ rm -fr gnustep-make-svn

.clone-gnustep-corebase:
	@ echo `date +%s` `date` "GIT Cloning gnustep-corebase"
	@ git clone https://github.com/gnustep/gnustep-corebase.git
	@ touch .clone-gnustep-corebase

.conf-gnustep-corebase: .clone-gnustep-corebase .make-gnustep-base
	@ echo `date +%s` `date` "Configuring gnustep-corebase"
	@ cd gnustep-corebase && CC=clang CXX=clang++ CPPFLAGS="-I$(BRAYATAN)/include" LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) --disable-gcd > ../conf-gnustep-corebase.log 2>&1
	@ mv conf-gnustep-corebase.log .conf-gnustep-corebase

.make-gnustep-corebase: .conf-gnustep-corebase
	@ echo `date +%s` `date` "Building gnustep-corebase"
	@ cd gnustep-corebase && make -j$(NUMCORES) install > ../make-gnustep-corebase.log 2>&1
	@ mv make-gnustep-corebase.log .make-gnustep-corebase

clean-gnustep-corebase:
	@ rm -fr gnustep-corebase-svn

.clone-gnustep-base:
	@ echo `date +%s` `date` "SVN Cloning gnustep-base"
	@ svn co -q http://svn.gna.org/svn/gnustep/libs/base/trunk/ gnustep-base-svn
	@ touch .clone-gnustep-base

.conf-gnustep-base: .clone-gnustep-base .make-gnustep-make
	@ echo `date +%s` `date` "Configuring gnustep-base"
	@ cd gnustep-base-svn && CC=clang CXX=clang++ LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib" ./configure --prefix=$(BRAYATAN) --disable-xml --disable-tls > ../conf-gnustep-base.log 2>&1
	@ mv conf-gnustep-base.log .conf-gnustep-base

.make-gnustep-base: .conf-gnustep-base
	@ echo `date +%s` `date` "Building gnustep-base"
	@ cd gnustep-base-svn && make -j$(NUMCORES) install > ../make-gnustep-base.log 2>&1
	@ mv make-gnustep-base.log .make-gnustep-base

clean-gnustep-base:
	@ rm -fr gnustep-base-svn

.make-libhttp_parser: .make-llvm-clang
	@ echo `date +%s` `date` "Building libhttp_parser"
	@ +make -C ../../libhttp_parser -j$(NUMCORES) package > make-libhttp_parser.log
	@ cp ../../libhttp_parser/libhttp_parser.a $(BRAYATAN)/lib/libhttp_parser.a
	@ cp -r ../../libhttp_parser/http_parser.h $(BRAYATAN)/include/
	@ mv make-libhttp_parser.log .make-libhttp_parser

clean-libhttp_parser:
	@ +make -C ../../libhttp_parser -j$(NUMCORES) clean

.make-libbrayatan: .make-gnustep-base .make-gnustep-corebase .make-libhttp_parser
	@ echo `date +%s` `date` "Building libbrayatan"
	@ +make -C ../../libbrayatan -j$(NUMCORES) install > make-libbrayatan.log
	@ cp ../bin/brayatan-cc $(BRAYATAN)/bin
	@ mv make-libbrayatan.log .make-libbrayatan
	@ echo `date +%s` `date` "DONE."
	@ echo `date +%s` `date`
	@ echo `date +%s` `date` '---------------------------------------------------'
	@ echo `date +%s` `date` 'Do not forget to add the following to your .profile'
	@ echo `date +%s` `date`
	@ echo `date +%s` `date` 'export BRAYATAN=$$HOME/local/brayatan'
	@ echo `date +%s` `date` 'export PATH=$$BRAYATAN/bin:$$PATH' 
	@ echo `date +%s` `date`
	@ echo `date +%s` `date` '---------------------------------------------------'
	@ echo `date +%s` `date` 

clean-libbrayatan:
	@ +make -C ../../libbrayatan -j$(NUMCORES) clean
	@ +make -C ../../libhttp_parser -j$(NUMCORES) clean
