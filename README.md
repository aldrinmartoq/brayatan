Brayatan
========

Brayatan is a high performance, memory efficient runtime for building web services. It is part of
«Brayatan Azikalao Pa las Nenas», a new platform for building the next generation of web applications and services.

Brayatan is based in core OS X technologies, like:
* Objective-C 2.0
* Blocks
* Foundation framework
* ARC Automatic Reference Counting
* GCD Grand Central Dispatch

We are using http-parser and libuv from nodejs project, but they will be dumped as soon as we can rewrite them using blocks instead of callbacks.



Building
--------

### Mac OS X


Download the latest Xcode from the App Store. Choose the scheme "sample01" and hit Run.


### Linux

Add the following to your .bashrc, .profile or equivalent:

    export BRAYATAN=$HOME/local/brayatan
    export PATH=$BRAYATAN/bin:$PATH

Go to the linux/build folder and run make. Everything will be installed in your $HOME/local/brayatan folder. To build the sample01 source code, go to samples/sample01 and build it with brayatan-cc compiler:

    $ cd samples/sample01
    $ brayatan-cc main.m
    $ ./main.m
