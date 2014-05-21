BRAYATAN:=$(HOME)/local/brayatan
PATH:=$(BRAYATAN)/bin:$(PATH)
NUMCORES:=4
CC=clang
CXX=clang++
CPPFLAGS="-I$(BRAYATAN)/include"
LDFLAGS="-L$(BRAYATAN)/lib -Wl,-rpath,$(BRAYATAN)/lib"

all: install

install: .inst-libbrayatan

clean:
	rm -fr gnustep-* libobjc2* make-* .conf-*

dist-clean: clean
	rm -fr .inst-* .down-* .download

install-clean:
	rm -fr $(BRAYATAN)

.download: .down-gnustep-make .down-gnustep-base .down-gnustep-gui .down-gnustep-back .down-gnustep-corebase .down-gnustep-libobjc2
	@ mkdir -p .download
	@ mv -f *.gz *.bz2 .download

.down-gnustep-make:
	@ echo `date +%s` `date` "Downloading gnustep-make 2.6.6"
	@ wget -Ncq http://w.a0.cl/gnustep/gnustep-make-2.6.6.tar.gz
	@ touch $@
.down-gnustep-base:
	@ echo `date +%s` `date` "Downloading gnustep-base 1.24.6"
	@ wget -Ncq http://w.a0.cl/gnustep/gnustep-base-1.24.6.tar.gz
	@ touch $@
.down-gnustep-gui:
	@ echo `date +%s` `date` "Downloading gnustep-gui 0.24.0"
	@ wget -Ncq http://w.a0.cl/gnustep/gnustep-gui-0.24.0.tar.gz
	@ touch $@
.down-gnustep-back:
	@ echo `date +%s` `date` "Downloading gnustep-back 0.24.0"
	@ wget -Ncq http://w.a0.cl/gnustep/gnustep-back-0.24.0.tar.gz
	@ touch $@
.down-gnustep-corebase:
	@ echo `date +%s` `date` "Downloading gnustep-corebase 0.1.1"
	@ wget -Ncq http://w.a0.cl/gnustep/gnustep-corebase-0.1.1.tar.gz
	@ touch $@
.down-gnustep-libobjc2:
	@ echo `date +%s` `date` "Downloading gnustep-libobjc2 1.7"
	@ wget -Ncq http://w.a0.cl/gnustep/libobjc2-1.7.tar.bz2
	@ touch $@

.pre-packages: .download
	@ echo `date +%s` `date` "Uninstalling libdispatch-dev"
	@ sudo apt-get --purge remove libdispatch-dev -y > .conf-packages.log 2>&1
	@ echo `date +%s` `date` "Installing packages"
	@ sudo apt-get install build-essential clang libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev gobjc libxml2-dev libjpeg-dev libtiff-dev libpng12-dev libcups2-dev libfreetype6-dev libcairo2-dev libxt-dev libgl1-mesa-dev libicu-dev libc6-dev-i386 libc6-dev -y >> .conf-packages.log 2>&1

.pos-packages: .inst-gnustep-back
	@ echo `date +%s` `date` "Installing libdispatch-dev"
	@ sudo apt-get install libdispatch-dev -y >> .conf-packages.log 2>&1

.inst-gnustep-libobjc2: .pre-packages
	@ echo `date +%s` `date` "Installing gnustep-libobjc2"
	@ rm -fr libobjc2-1.7
	@ tar xfj .download/libobjc2-1.7.tar.bz2
	@ cd libobjc2-1.7 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) PREFIX=$(BRAYATAN) make -j $(NUMCORES) install > ../make-gnustep-libobjc2.log 2>&1
	@ mv make-gnustep-libobjc2.log .inst-gnustep-libobjc2

.inst-gnustep-make: .inst-gnustep-libobjc2
	@ echo `date +%s` `date` "Installing gnustep-make"
	@ rm -fr gnustep-make-2.6.6
	@ tar xfz .download/gnustep-make-2.6.6.tar.gz
	@ cd gnustep-make-2.6.6 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) ./configure --prefix=$(BRAYATAN) > ../.conf-gnustep-make.log 2>&1
	@ cd gnustep-make-2.6.6 && make -j $(NUMCORES) install > ../make-gnustep-make.log 2>&1
	@ mv make-gnustep-make.log .inst-gnustep-make

.inst-gnustep-base: .inst-gnustep-make
	@ echo `date +%s` `date` "Installing gnustep-base"
	@ rm -fr gnustep-base-1.24.6
	@ tar xfz .download/gnustep-base-1.24.6.tar.gz
	@ cd gnustep-base-1.24.6 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) ./configure --prefix=$(BRAYATAN) > ../.conf-gnustep-base.log 2>&1
	@ cd gnustep-base-1.24.6 && make -j $(NUMCORES) install > ../make-gnustep-base.log 2>&1
	@ mv make-gnustep-base.log .inst-gnustep-base

.inst-gnustep-corebase: .inst-gnustep-base
	@ echo `date +%s` `date` "Installing gnustep-corebase"
	@ rm -fr gnustep-corebase-0.1.1
	@ tar xfz .download/gnustep-corebase-0.1.1.tar.gz
	@ cd gnustep-corebase-0.1.1 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) ./configure --prefix=$(BRAYATAN) > ../.conf-gnustep-corebase.log 2>&1
	@ cd gnustep-corebase-0.1.1 && make -j $(NUMCORES) install > ../make-gnustep-corebase.log 2>&1
	@ mv make-gnustep-corebase.log .inst-gnustep-corebase

.inst-gnustep-gui: .inst-gnustep-corebase
	@ echo `date +%s` `date` "Installing gnustep-gui"
	@ rm -fr gnustep-gui-0.24.0
	@ tar xfz .download/gnustep-gui-0.24.0.tar.gz
	@ cd gnustep-gui-0.24.0 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) ./configure --prefix=$(BRAYATAN) > ../.conf-gnustep-gui.log 2>&1
	@ cd gnustep-gui-0.24.0 && make -j $(NUMCORES) install > ../make-gnustep-gui.log 2>&1
	@ mv make-gnustep-gui.log .inst-gnustep-gui

.inst-gnustep-back: .inst-gnustep-gui
	@ echo `date +%s` `date` "Installing gnustep-back"
	@ rm -fr gnustep-back-0.24.0
	@ tar xfz .download/gnustep-back-0.24.0.tar.gz
	@ cd gnustep-back-0.24.0 && CC=$(CC) CXX=$(CXX) CPPFLAGS=$(CPPFLAGS) LDFLAGS=$(LDFLAGS) ./configure --prefix=$(BRAYATAN) > ../.conf-gnustep-back.log 2>&1
	@ cd gnustep-back-0.24.0 && make -j $(NUMCORES) install > ../make-gnustep-back.log 2>&1
	@ mv make-gnustep-back.log .inst-gnustep-back

.inst-libhttp-parser: .pos-packages
	@ echo `date +%s` `date` "Installing libhttp-parser"
	@ +make -C ../../libhttp_parser -j$(NUMCORES) clean > make-libhttp-parser.log
	@ +make -C ../../libhttp_parser -j$(NUMCORES) package > make-libhttp-parser.log
	@ cp ../../libhttp_parser/libhttp_parser.a $(BRAYATAN)/lib/libhttp-parser.a
	@ cp -r ../../libhttp_parser/http_parser.h $(BRAYATAN)/include/
	@ mv make-libhttp-parser.log .inst-libhttp-parser

.inst-libgrmustache: .pos-packages
	@ echo `date +%s` `date` "Installing libGRMustache"
	@ +make -C ../../libbrayatan/GRMustache -j$(NUMCORES) -f Makefile.linux clean > make-libhttp-parser.log
	@ +make -C ../../libbrayatan/GRMustache -j$(NUMCORES) -f Makefile.linux install > make-libhttp-parser.log


.inst-libbrayatan: .inst-libhttp-parser .inst-libgrmustache
	@ echo `date +%s` `date` "Installing libbrayatan"
	@ +make -C ../../libbrayatan -j$(NUMCORES) clean > make-libbrayatan.log
	@ +make -C ../../libbrayatan -j$(NUMCORES) install > make-libbrayatan.log
	@ cp brayatan-cc $(BRAYATAN)/bin
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

