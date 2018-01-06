# $Id: README-STANLEY-VJMPL.txt,v 1.2 2006/04/29 00:47:37 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

LINUX/UNIX README
=================
Contents
--------
o RUNNING STANLEY
o RUNNING OLIVER (STANLEY II)
o L2TOOLS/USER/WORKSPACE PREFERENCES 
o ADDITIONAL WORKSPACE CONFIGURATION
o MANAGING WORKSPACES 
o THE STANLEY VJMPL SCRIPT
o BUILDING SCHEMATICS

o STANLEY SOFTWARE DEPENDENCIES
o CHECKING OUT STANLEY VJMPL, LIVINGSTONE, L2TOOLS, & OLIVER SOURCE FILES 
o UNTARRING SUPPORT, LIVINGSTONE, L2TOOLS, & OLIVER TAR SOURCE FILES
o BUILDING & INSTALLING STANLEY VJMPL (AND LIVINGSTONE, L2TOOLS & OLIVER TOO)
o .CSHRC & .LOGIN FILES

RUNNING STANLEY
------------------------------------------------------------
In fresh xterm1:
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME /home/wtaylor/pub/jdk1.5.0_06

% cd {release root}/l2-tools/stanley-jmpl/interface
% ./l2tools
# wait for "======>" prompt to appear

In fresh xterm2:
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME /home/wtaylor/pub/jdk1.5.0_06

% cd {release root}/l2-tools/stanley-jmpl/interface
% ./stanley -exists


RUNNING OLIVER (STANLEY II)
------------------------------------------------------------
In a fresh xterm:
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME /home/wtaylor/pub/jdk1.5.0_06

% cd {release root}/l2-tools/groundworks
% ./oliver


L2TOOLS/USER/WORKSPACE PREFERENCES 
------------------------------------------------------------
Stanley "pull-down" menu selection
"Edit->Preferences->L2Tools/User/Workspace"
cascades into "View", "Edit User", and "Edit Workspace".  
Current preference values are determined from loading the L2Tools 
defaults, 
  {release root}/l2-tools/preferences/prefLabels
  {release root}/l2-tools/preferences/prefDefaults
then the user preferences, 
  ${HOME}/.stanley/userPrefs
and then the workspace preferences
  ${workspace root}/workspacePrefs

For workspaces other than stanley-sample-user-files, the
default Stanley and Livingstone preferences, defined in
{release root}/l2-tools/preferences/pref*, can be overriden
at the user level, by selecting "Edit User", or at the workspace 
level, by selecting "Edit Workspace".

Normally the stanley-sample-user-files workspace is read-only,
because it may be shared with multiple users.  If you
desire it to be writable, edit
{release root}/l2-tools/stanley-jmpl/interface/RUN-STANLEY-VJMPL.csh
and change "setenv STANLEY_SUPERUSER taylor", replacing taylor
with your login name, for the appropriate operation system.


ADDITIONAL WORKSPACE CONFIGURATION
------------------------------------------------------------
Since each workspace is a unique directory, addition 
configuration can be done for each workspace.

o Component/Module Bitmaps In Lieu Of Rectangles

Directory {workspace root}/bitmaps optionally contains pairs of 
files, created by the unix bitmap utility:
{nodeClassName} => bitmap; 1 = foreground; 0 = background 
{nodeClassName}-mask => bitmap; 1 = show fg/bg; 0 = transparent 
(nodes are either components or modules)

o Component/Module Mode State Names and Colors

Having entries in file {workspace root}/display-state-color-prefs 
is optional.  It can contain pairs of mode state names (Java syntax) 
and associated X11 color names, one pair per line, e.g.
lowPressure lightBlue
nominalPressure lawnGreen
highPressure brickRed
...

To add or modify entries in this file, use
"Edit->Preferences->Workspace Display State Colors".  The mode 
state names are used in the "Edit->Header->Display Attribute" 
code to provide background colors representing the current 
Livingstone mode states.  The number of pairs has no practical 
limit, and are displayed using "Tools->Display Mode State Legend".


MANAGING WORKSPACES 
------------------------------------------------------------
The default read-only workspace is "stanley-sample-user-files".
It contains two simple schematics: "car", a very simple 
representation of an automobile, and "cbAndLeds" a simple
set of a power source, fifteen circuit breakers and
eight leds.  Also a more complex schematic/model named
"mainPropulsionSystem", with sub-modules 
"pneumaticValveAndMicroSwitches", 
"pressurizationLineSolenoidValveAndMicroSwitch", and
"solenoidValveAndMicroSwitch" is included.  These are
useful as guides to modeling physical systems.

You may create new "template" workspaces with "File->New Workspace",
which will create a file hierarchy with no component or module
class definitions.  There will, however, be abstraction, relation, 
structure, symbol, and value definitions.  "File->New Empty Workspace",
on the other hand, will have no definitions, at all.

If you have a populated workspace outside of Stanley, and want 
Stanley to be able to "know" about it, use "File->Import Workspace",
which brings up a directory browser.  When you make a selection,
Stanley does validity checking to make sure this is a valid workspace,
and if so, it becomes your current workspace.  Stanley them creates
auxiliary files which it needs by loading each component and module
and writing out the files -- it may take a few minutes to complete.

Use menu command "File->Open Workspace" to change between "known"
workspaces.  

"File->Forget Workspace" will make a "known" workspace, "unknown" 
-- it will no longer appear in the "File->Open Workspace" menu list.


 STANLEY VJMPL SCRIPT
------------------------------------------------------------
The script file to run Stanley VJMPL (RUN-STANLEY-VJMPL.csh) 
is located in:

  <released dir>/l2-tools/stanley-jmpl/interface

stanley is a "soft-link" to RUN-STANLEY-VJMPL.csh.

# --------------------------------------------------------
# RUN-STANLEY-VJMPL.csh
# Run STANLEY in VJMPL (visual Java-like Model-based Programing Language)
#       mode to build schematics, and generate JMPL code.
# --------------------------------------------------------

# USER OPTIONS:

# notify Stanley that L2Tools/Livingstone exists and 
# has been started in $HOME/.stanley
# % ./RUN-STANLEY-VMPL.csh -exists

# pass to the Java Virtual Machine the value for -Xms
# the initial GC space (default 32), in mb
# % ./RUN-STANLEY-VMPL.csh -gcinit

# pass to the Java Virtual Machine the value for -Xmx
# the maximum GC space (default 192), in mb
# % ./RUN-STANLEY-VMPL.csh -gcmax

# during initialization do not check for out-of-date files 
# derived from .scm files (.i-scm, .terms, .inc, .jmpl)
# % ./RUN-STANLEY-VMPL.csh -nochk

# to *not* run with CORBA interface to Livingstone L2Tools 
# % ./RUN-STANLEY-VJMPL.csh -notools

# during initialization regenerate all derived files
# (.i-scm, .terms, .dep, .jmpl), and rewrite the .scm file
# allow .scm file structure changes to be applied
# % ./RUN-STANLEY-VMPL.csh -regen

# to run from the Smart Board PC via telnet
# % ./RUN-STANLEY-VJMPL.csh -sbpc

# to run as a passive viewer for L2Tools/Livingstone
# % ./RUN-STANLEY-VJMPL.csh -viewer

# to run in a Windows environment under CygWin
# % ./RUN-STANLEY-VJMPL.csh -win32

# DEVELOPER OPTIONS:

# to run in debug mode - DDD debugger
# % ./RUN-STANLEY-VJMPL.csh -debug

# to run with Sage Tcl/Tk profiler
# % ./RUN-STANLEY-VJMPL.csh -profile



BUILDING SCHEMATICS
------------------------------------------------------
Invoke <released dir>/l2-tools/stanley-jmpl/interface/RUN-STANLEY-VJMPL.csh

See menu selection "HELP->Help ...->Building Schematics with Stanley VJMPL"



STANLEY SOFTWARE DEPENDENCIES
------------------------------------------------------------
Stanley and the L2Tools wrapper around Livingstone communicate
using CORBA Object Request Brokers, which necessitates extensive 
supporting software.
All this software is provided in the "support/stanley-support-src"
node of CVS, except for:

o C/C++ Compiler & Assembler for Solaris & Linux
  SunOS 5.6:
        GNU gcc >= 3.2.2 (not 2.96 or 3.0)
        GNU as >= 2.9.1
        GNU ld >= 2.9.5
        (SunWorkshop native assembler does not work)
  SunOS 5.8:
        GNU gcc >= 3.2.2 (not 2.96 or 3.0)
        SunWorkshop native assembler (Sun WorkShop 6 99/08/18)
        SunWorkshop native linker (Solaris-ELF (4.0))
        (GNU asembler & linker do not work:
         undefined reference to `towupper@@SUNW_0.7')
  Linux:
        GNU gcc >= 3.2.2 (not 2.96 or 3.0)
        GNU as >= 2.9.1; GNU ld >= 2.9.5

  http://www.gnu.org/software/gcc/gcc.html

  Specify "--enable-shared" (which by default is NOT enabled) 
  when building gcc. 

o GNU make version 3.78 or better (version 3.77 does not work under Solaris)
  http://www.gnu.org/software/make/make.html

o JDK 1.4 - Java Development Kit (actually L2Tools & Oliver use this)
  http://java.sun.com/j2se/1.4/

o X windows window managers under Solaris or Linux: ctwm is known not
  to work; CDE (Solaris only), fvwm, and KDE (Linux only) are known to work.

The Stanley support applications which are built the first time
you build Stanley, are: (included in support-src-unix.tar.gz)

o Tcl/Tk 8.3.2 - Tool Control Language and Toolkit
  http://www.tcltk.com

o Itcl 3.1.0 -  Object-oriented extension of Tcl.
  http://www.tcltk.com/itcl/

o TkTable 2.6 - Tk table widget
  http://sourceforge.net/projects/tktable

o MICO 2.3.12 - Object Request Broker for Stanley
  http://www.mico.org/   

o Combat 0.7.3 - Tcl/Tk language bindings for Mico
  http://www.fpx.de/Combat/

NOTE: If you have received this software under the NASA Open Source Agreement,
      the Mico/Combat source is NOT included due to the restrictive nature of 
      the MICO GNU Public License.  See instructions on installing it on your 
      system in README.install-MicoCombat.


CHECKING OUT STANLEY VJMPL, LIVINGSTONE, L2TOOLS, & OLIVER SOURCE FILES 
------------------------------------------------------------
You must be inside Ames to checkout files from CVS.  Otherwise
source "tar balls" are available from Will Taylor.  See next
section.

Solaris 5.8 -- 
% setenv CVSROOT <user_name>@ids:/home/cvs/ISG-Repository
% setenv CVS_RSH /opt/ssh/bin/ssh

Linux --
% setenv CVSROOT <user_name>@ids.arc.nasa.gov:/home/cvs/ISG-Repository
% setenv CVS_RSH /usr/bin/ssh

% cd <your-root-dir>

To checkout Stanley and tcl/Tk & CORBA support:
% cvs checkout stanley-support-unix   (gcc2.95.2/3)        # a CVS "module"
% cvs checkout stanley-support-unix-gcc3.2 (gcc >= 3.2.2)  # a CVS "module"
% cvs checkout -r L2_2_7_8_2 stanley-vjmpl                 # a CVS "module"


To checkout C++-Livingstone:
% cvs checkout xml-solaris-gcc                         # a CVS "module"
% cvs checkout -r L2_2_7_8_2 L2                        # a CVS "module"

To checkout L2Tools compiled Java code and data:
% cvs checkout -r L2_2_7_8_2 l2tools-jars      # (usually checked out as a part of L2)
% cvs checkout -r L2_2_7_8_2 l2tools-data      # (usually checked out as a part of L2)

To checkout Oliver (Stanley II):
% cvs checkout -r L2_2_7_8_2 oliver


UNTARRING SUPPORT, LIVINGSTONE, L2TOOLS, & OLIVER TAR SOURCE FILES
-------------------------------------------------------------
Remote (to Ames) users will be e-mailed four gzipped tar files:
support-src-unix.tar.gz, l2-src_{n.m}.tar.gz, l2tools-src_{n.m}.tar.gz, &
groundworks-src_{n.m}.tar.gz which comprise the source file hierarchy.  
They should be unpacked in the same directory to produce:
% cd {your-root-dir}
% ls
l2-regress mba l2-tools support

NOTE: These tar files are built using GNU gtar and GNU gzip.
      Unpack them with GNU gunzip and GNU gtar, not unix tar, 
      or checksum errors may occur. Also CR/LF issues between
      unix/linux and windows are handled properly by gunzip/
      gtar.

Follow the directions below 
(l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt)
or from our division web server:
http://ic.arc.nasa.gov/projects/L2/doc/starting/stanley-build.html

The support files will not change with new L2/L2Tools releases,
except for version 2.7.7 (MICO-2.3.11, compatible with GNU gcc-3.2.2).

However, with each new release, you will be e-mailed new tar files:
l2-src_{n.m}.tar.gz, l2tools-src_{n.m}.tar.gz, & groundworks-src_{n.m}.tar.gz.
Discard all the top directories, except for support:
% /bin/rm -rf  mba l2-regress l2-tools 
Unpack the new tar files and re-build.

NOTE: If you have received this software under the NASA Open Source Agreement,
      support-src-unix.tar.gz will be replaced by support-src-unix-no-mico.tar.gz.
      See instructions on installing MICO on your system in README.install-MicoCombat.


BUILDING & INSTALLING STANLEY VJMPL (AND LIVINGSTONE, L2TOOLS, & OLIVER TOO)
------------------------------------------------------------
To build Stanley:
=================

% cd <your-root-dir>/l2-tools/stanley-jmpl

The first time that Stanley is built, its support applications
(tcl/Tk, itcl, tkTable, mico, and combat) are built.

Solaris -- 
-------
% ./configure 

Linux --
-----
% ./configure 


% make                           # build interpreted Stanley VJMPL
                                 # => stanley-jmpl/bin/stanley-bin

To build C++-Livingstone and L2Tools/Stanley/Oliver Compatible L2 Shared Library
===================================================================================

% cd <your-root-dir>/mba/cpp
% ./l2_update -t  # make sure generated files have the right timestamp

Solaris -- 
-------
% ./configure --prefix=`pwd` --no-recur --enable-xmpl2l2 --enable-apigen \
     --enable-rti --enable-names2ids --enable-l2flight --enable-recovery

Linux --
-----
% ./configure --prefix=`pwd` --enable-xmpl2l2 --enable-apigen \
     --enable-rti --enable-names2ids --enable-l2flight --enable-recovery

% make install


L2Test Regression Tests
-----------------------
% cd ../../l2-regress
% touch configure
% ./configure

Run the regression tests:
% ./runtests checkin

To run the recovery tests, you must have built L2 with
--enable-recovery specified in configure
% ./runtests recovery

# executables api_gen, api_scr, l2flight, l2test, names2ids, 
# scr2names, and xmpl2l2 will reside in <your-root-dir>/mba/cpp/bin
see <your-root-dir>/mba/cpp/BUILD for further details

L2Tools & Oliver
-------------------
No build operation is required for L2Tools or Oliver.


.CSHRC & .LOGIN FILES
---------------------
The user's login environment requires certain declarations.  Here are example
files from a Linux RedHat Enterprise Linux WS release 3 (Taroon Update 4) system.

.cshrc
-----------------------------
#!/bin/tcsh

# Every shell sources .cshrc on startup. Login shells source .login also.
# =======================================================================

# this echo breaks scp from another host to this one
# echo ".cshrc"

# Set default file protection of files created by editors to rw-rw-r-- :
umask 002

setenv HOST_SHORT `hostname | awk -F. '{print $1}' `

# /usr/X11R6/bin not set on remote login
if ($PATH !~ *X11R6*) then
  set path=( $path /usr/X11R6/bin )
endif

# /sbin contains ldconfig needed when building mico
if ($PATH !~ *sbin*) then
  set path=( $path /sbin )
endif

# .login is not called automatically by Linux
# if (! ${?JAVA_HOME}) then
  # call it only for new top-level xterm
  ### call it all the time to get up to date CLASSPATH without having to
  ### source ~/.login or logout/login
  source $HOME/.login
  # echo ".login"
# endif
----------------------------------------------------------------------

.login
------------------------------
#!/bin/tcsh

# echo ".login"

# .login 
#  it is called by cshrc 
#  what it sets is applied to all shells/windows opened on the host r/login'ed to 
#  whereas cshrc is called for each shell started, and by certain unix functions

setenv FONTPATH /usr/X11R6/lib/X11/fonts/misc

setenv MANPATH /usr/man:/usr/local/man:/usr/X11R6/man:/usr/share/man

setenv LD_LIBRARY_PATH /usr/X11R6/lib:/usr/lib:/usr/local/lib

setenv JAVA_HOME /usr/java/j2sdk1.4.2_05

# default to native threads - required by Tcl
setenv THREADS_FLAG native

setenv CC gcc               # configure uses path to find proper version
setenv CXX g++              # configure uses path to find proper version

setenv TERM xterm
------------------------------------------------------------------------------------
