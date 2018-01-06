NASA Open Source Release of Livingstone2
========================================
You will receive six gzipped tar files:

support-src-unix-no-mico.tar.gz
support-src-win.tar.gz
l2-src-OSA_2.7.8.2.tar.gz
l2tools-src-OSA_2.7.8.2.tar.gz
groundworks-src-OSA-1of2_2.7.8.2.tar.gz
groundworks-src-2of2_2.7.8.2.tar.gz

which should be unpacked in the same directory to produce:
% cd <your-root-dir>
% ls
l2-regress mba l2-tools support

You will create this hierarchy on both your unix/linux platform and
your windows platform:

UNIX/LINUX:
-----------
gunziptar support-src-unix-no-mico.tar.gz
gunziptar l2-src-OSA_2.7.8.2.tar.gz
gunziptar l2tools-src-OSA_2.7.8.2.tar.gz
gunziptar groundworks-src-OSA-1of2_2.7.8.2.tar.gz
gunziptar groundworks-src-2of2_2.7.8.2.tar.gz

Follow the directions in
l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt, or
point your browser to "mba/cpp/doc/index.html"  and look for
the "Building Stanley & Oliver (Stanley II) on Unix/Linux" link.

WINDOWS: 
--------
In cygwin use gunziptar; otherwise use WinZip.
gunziptar support-src-win.tar.gz
gunziptar l2-src-OSA_2.7.8.2.tar.gz
gunziptar l2tools-src-OSA_2.7.8.2.tar.gz
gunziptar groundworks-src-OSA-1of2_2.7.8.2.tar.gz
gunziptar groundworks-src-2of2_2.7.8.2.tar.gz

Follow the directions in
l2-tools/stanley-jmpl/README-WINDOWS.txt, or
point your browser to "mba/cpp/doc/index.html"  and look for
the "Building Stanley & Oliver (Stanley II) on Windows" link.

