# $Id: README-L2-release.txt,v 1.2 2006/04/29 00:47:37 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# generate diff patch files of working space vs. repository
  cvs diff -c3 <file-name> > patch-file

# update release documentation
  mba/cpp/doc/index.html
  mba/cpp/doc/starting/*.html
  mba/cpp/doc/oliver/*.html
  mba/cpp/doc/releases/*.html
  mba/cpp/doc/*/*

# build l2-tools/jars/l2Tools.jar with .class files only
  Ant
  ===
  cd ~/L2Root/l2-tools/jars
  ant -buildfile l2Tools.xml "jar l2 tools"

  Shell cmds
  ==========
  cd ~/junk/2.7.8.2-jar
  dcp ~/L2Root/l2-tools/java/src .
  find * -type f -name "*.java*" -print
  find * -type f -name "*.java*" -print | xargs /bin/rm
  find * -type f -name "*~" -print
  find * -type f -name "*~" -print | xargs /bin/rm
  find . -name CVS -print
  find . -name CVS -print | xargs /bin/rm -rf
  $JAVA_HOME/bin/jar cvf l2Tools.jar *
  cp l2Tools.jar ~/L2Root/l2-tools/jars/

  Run Stanley to verify l2Tools.jar


#  See mba/cpp/RELEASE for details on releasing L2
   mba/cpp/src/livingstone/version.c
   mba/cpp/ChangeLog

# update to new version
  mba/cpp/doc/oliver/starting.html
  mba/cpp/doc/starting/stanley.html
  mba/cpp/doc/starting/stanley-build.html
  mba/cpp/doc/starting/stanley-build-win32.html
  l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt
  l2-tools/stanley-jmpl/README-WINDOWS.txt
  l2-tools/stanley-jmpl/README-L2-release.txt
  l2-tools/stanley-jmpl/src/version.tcl 

# commit on Linux
  Instead of `cvs ci mba/cpp' ---
  cp l2-tools/stanley-jmpl/cvs-changed.sh .
  ./cvs-changed.sh
  # list of files, spit to the screen and to the file "changed"
  emacs ChangeLog  # update ChangeLog 
  cvs ci -m "..." mba/cpp/ChangeLog `cat changed`
  Note: if you create a new file or deleted an old one, that doesn't show up
        in 'changed'

  cvs ci -m "..." mba/cpp/ChangeLog mba/cpp/src/livingstone/version.c
  cvs ci -m "..." mba/cpp/doc
  cvs ci -m "..." l2-tools/jars
  cvs ci -m "..." l2-tools/java/src
  cvs ci -m "..." l2-tools/java/lib
  cvs ci -m "..." l2-tools/preferences
  cvs ci -m "..." l2-tools/html
  cvs ci -m "..." l2-tools/stanley-jmpl
  cvs ci -m "..." l2-tools/stanley-sample-user-files

# Tag files
  cd ~/junk/2.7.8.2
  cvs co L2
      # cvs co mba/cpp
      # cvs co mba/xml
      # cvs co l2-regress
      # cvs co l2-tools/jars
      # cvs co l2-tools/java/lib
      # cvs co l2-tools-data
  cvs co stanley-vjmpl
  cvs co l2tools-src
  cvs co oliver
      # cvs co l2-tools/groundworks/oliver
      # cvs co l2-tools/groundworks/docs
      # cvs co l2-tools/groundworks/examples
      # cvs co l2-tools/groundworks/jars/oliver.xml
      # cvs co l2-tools/groundworks/jars/oliverfull.jar
      # cvs co l2-tools/groundworks/lib
      # cvs co l2-tools/groundworks/src/livdll
      # cvs co l2-tools/groundworks/src/oliver
      ## delete other files ##

  # set combat.dll executable
  chmod a+x l2-tools/stanley-jmpl/support/combat-win32/combat.dll

  # delete unneeded source files
  cd ~/junk/2.7.8.2
  ~/L2/l2-tools/stanley-jmpl/delete-l2tools-src.csh

  cvs tag L2_2_7_8_2 mba
  cvs tag L2_2_7_8_2 l2-regress
  cvs tag L2_2_7_8_2 l2-tools

  # branch tag
  cvs tag -b L2_2_7_8_2_beta mba
  cvs tag -b L2_2_7_8_2_beta l2-regress

  Acessing Branches
  http://sunland.gsfc.nasa.gov/info/cvs/Accessing_branches.html
  Merging an entire branch
  after tagging the branch to L2_2_7_8_2, merge L2_2_7_8_2 into mainline
  ** mainline is `cvs co mba/cpp', *not* `cvs co -r HEAD mba/cpp' **

  http://sunland.gsfc.nasa.gov/info/cvs/Merging_a_branch.html

  # normal tag 
  cvs tag L2_2_7_8_2 l2-tools

  # cvs tag -F L2_2_7_8_2 l2-tools  # to force tag to latest file versions

# Build on Solaris  (l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt)
  update ~taylor/L2Root/released/stanley
  update ~taylor/L2Root/released/stanley-gpu-sun


# Release e-mail message

# copy L2 doc files to Sol8 working web files
  scp futures.html taylor@wow:/home/mba/public_html/projects/L2/doc/releases/
  # copy all doc files
  cd mba/cpp/doc
  scp -r * taylor@serengeti:/home/mba/public_html/projects/L2/doc

# notify Sonie Lau for export review and mirroring to external web server
# internal web server is armstrong (http://armstrong.arc.nasa.gov/~mba)
# Do not send email to Sonie, rather
# http://armstrong/admin -- login with Solaris name/password -- request export control

  DO NOT use admin template to make changes -- only click on Export when manual
  changes are made to ~mba/public_html/projects/L2/index.html.
  Export will copy ~mba/public_html/projects/L2/**/*.* to external sever.

# Create external release source -- gzipped, tar files
  See ~/L2Root/released_2.7.8.2/README     # copied/modified from previous release

# Update GNATS for stanley-jmpl & l2-tools PRs and CRs
 

# E-mail instructions for SUA Release
=====================================
I will be sending you six gzipped tar files
(support-src-unix-gcc3.2.tar.gz, support-src-win.tar.gz, l2-src_2.7.8.2.tar.gz, 
l2tools-src_2.7.8.2.tar.gz, groundworks-src-1of2_2.7.8.2.tar.gz, &
groundworks-src-2of2_2.7.8.2.tar.gz) of the source file hierarchy, which 
should be unpacked in the same directory to produce:
% cd <your-root-dir>
% ls
l2-regress mba l2-tools support

You will create this hierarchy on both your unix/linux platform and
your windows platform:

UNIX/LINUX:
gunziptar support-src-unix-gcc3.2.tar.gz
gunziptar l2-src-SUA_2.7.8.2.tar.gz
gunziptar l2tools-src-SUA_2.7.8.2.tar.gz
gunziptar groundworks-src-SUA-1of2_2.7.8.2.tar.gz
gunziptar groundworks-src-2of2_2.7.8.2.tar.gz

Follow the directions in
l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt, or
point your browser to "mba/cpp/doc/index.html"  and look for
the "Building Stanley & Oliver (Stanley II) on Unix/Linux" link.

WINDOWS: (In cygwin use gunziptar; otherwise use WinZip)
gunziptar support-src-win.tar.gz
gunziptar l2-src-SUA_2.7.8.2.tar.gz
gunziptar l2tools-src-SUA_2.7.8.2.tar.gz
gunziptar groundworks-src-SUA-1of2_2.7.8.2.tar.gz
gunziptar groundworks-src-2of2_2.7.8.2.tar.gz

Follow the directions in
l2-tools/stanley-jmpl/README-WINDOWS.txt, or
point your browser to "mba/cpp/doc/index.html"  and look for
the "Building Stanley & Oliver (Stanley II) on Windows" link.

For unix/linux there is available a support tar file compatible with gcc2.95 --
please let me know if you want this tar file.

The support directory files will not change with new L2/L2-Tools releases.

However, with each new release, I will sent new complete
l2_<n.m.o>.tar.gz, l2tools_<n.m.o>.tar.gz, & groundworks_<n.m.o>.tar.gz files.
Delete the l2-regress, mba, and l2-tools directory contents.
Rebuild L2, and Stanley.  L2 Tools, and Oliver (Stanley II) do not have
to be rebuilt, since they are distributed as Java jar files.



