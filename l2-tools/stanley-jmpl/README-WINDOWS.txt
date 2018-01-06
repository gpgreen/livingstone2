####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

WINDOWS README
==============
Tested on Windows 98 ed 2, Windows 2000, Windows NT ed 4, &
Windows XP!

Contents
--------
o RUNNING STANLEY VJMPL
o RUNNING OLIVER (STANLEY II)

See l2-tools/stanley-vjmpl/README-STANLEY-VJMPL.txt for
    o L2TOOLS/USER/WORKSPACE PREFERENCES 
    o ADDITIONAL WORKSPACE CONFIGURATION
    o MANAGING WORKSPACES 
    o THE STANLEY VJMPL SCRIPT
    o BUILDING SCHEMATICS

o SOFTWARE DEPENDENCIES
o CHECKING OUT STANLEY VJMPL, LIVINGSTONE, L2TOOLS, & OLIVER SOURCE FILES
o UNTARRING SUPPORT, LIVINGSTONE, L2TOOLS, & OLIVER TAR SOURCE FILES
o BUILDING & INSTALLING STANLEY VJMPL (AND LIVINGSTONE, L2TOOLS, & OLIVER TOO)


RUNNING STANLEY VJMPL
------------------------------------------------------------
In Cygwin window #1
-------------------
% tcsh
# set your L2_ROOT, e.g.
% setenv L2_ROOT D:/cygwin/home/wtaylor/L2
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME D:/progra~1/jdk1.4.1_01

% cd $L2_ROOT/l2-tools/stanley-jmpl/interface
% ./l2tools -win32

Optional parameters to "l2tools":
  pass to the Java Virtual Machine the value for -Xms
  the initial GC space (L2Tools default 32), in mb
  e.g. -gcinit 64

  pass to the Java Virtual Machine the value for -Xmx
  the maximum GC space (L2Tools default 192), in mb
  e.g. -gcmax 258

In Cygwin window #2
-------------------
% tcsh
# set your L2_ROOT, e.g.
% setenv L2_ROOT D:/cygwin/home/wtaylor/L2
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME D:/progra~1/jdk1.4.1_01

% cd $L2_ROOT/l2-tools/stanley-jmpl/interface
% ./stanley -win32 -exists


RUNNING OLIVER (STANLEY II)
------------------------------------------------------------
In Cygwin window
-------------------
% tcsh
# set your JAVA_HOME, e.g.
% setenv JAVA_HOME D:/progra~1/jdk1.4.1_01

% cd D:/cygwin/home/wtaylor/L2/l2-tools/groundworks
% ./oliver -win32



SOFTWARE DEPENDENCIES
------------------------------------------------------------
o Visual C++ 6.0 SP5

o Cygwin 1.3.3
  http://www.cygnus.com

  install at <drive>:\cygwin
             <drive>:\cygwin-packages
  When the cvs portion of cygwin is being loaded, specify 'dos'
  for the default file mode, so that Visual C++ will recognize
  .dsw and .dsp files.

  Choose the "Shells" category, in addition to "Base", for Cygwin installation.

o JDK 1.4 - Java Development Kit (actually L2Tools & Oliver use this)
  http://java.sun.com/j2se/1.4/

The Stanley support applications which are built the first time
you build Stanley, are: (included in support-src-win.tar.gz)

o Tcl/Tk 8.3.3 - Tool Control Language and Toolkit
  http://www.tcltk.com

o Itcl 3.2 -  Object-oriented extension of Tcl.
  http://www.tcltk.com/itcl/

o TkTable 2.6 - Tk table widget
  http://sourceforge.net/projects/tktable

Mico/Combat pre-built .dll loadable module: (included in l2tools-src_l.m.n.tar.gz)

o MICO 2.3.6 - Object Request Broker for Stanley
  http://www.mico.org/   

o Combat 0.6 - Tcl/Tk language bindings for Mico
  http://www.fpx.de/Combat/

NOTE: If you have received this software under the NASA Open Source Agreement,
      the Mico/Combat pre-built .dll loadable module is NOT included due to
      the restrictive nature of the MICO GNU Public License.  See instructions
      on installing it on your system in README.install-MicoCombat.


CHECKING OUT STANLEY VJMPL, LIVINGSTONE, L2TOOLS, & OLIVER SOURCE FILES 
------------------------------------------------------------
You must be inside Ames to checkout files from CVS.  Otherwise
source "tar balls" are available from Will Taylor 
<taylor@email.arc.nasa.gov>

WinCVS
------
http://sg  => "Downloads & Software Info" => "Windows Downloads"
o Cvs/SSH - A stable SSH version known to work with WinCVS.
o WinCVS 1.3.6b - Known version of WinCVS to work with SSH.

WinCVS Preferences:
CVSROOT - <user-name>@wow.arc.nasa.gov:/home/cvs/ISG-Repository
Authentication - SSH server

Alternatively, you can run 'cvs' under cygwin.

To checkout C++-Livingstone:
cvs checkout xml-windows                             # a CVS "module" 
cvs checkout -r L2_2_7_8_2 L2                   # a CVS "module" 

To checkout Stanley and tcl/Tk & CORBA support:
cvs checkout stanley-support-windows                 # a CVS "module"
cvs checkout -r L2_2_7_8_2 stanley-vjmpl        # a CVS "module"

To checkout L2Tools compiled Java code and data:
% cvs checkout -r L2_2_7_8_2 l2tools-jars    # (usually checked out as a part of L2)
% cvs checkout -r L2_2_7_8_2 l2tools-data    # (usually checked out as a part of L2)

To checkout Oliver (Stanley II)
cvs checkout -r L2_2_7_8_2 oliver


UNTARRING SUPPORT, LIVINGSTONE, L2TOOLS, & OLIVER TAR SOURCE FILES
-------------------------------------------------------------
Remote (to Ames) users will be e-mailed four gzipped tar files:
support-src-win.tar.gz, l2-src_<n.m>.tar.gz, 
l2tools-src_<n.m>.tar.gz, and groundworks-src_<n.m>.tar.gz
which comprise the source file hierarchy.  They should be
unpacked in the same directory to produce:
% cd <your-root-dir>
% ls
l2-regress mba l2-tools support

NOTE: These tar files are built using GNU gtar and GNU gzip.
      Unpack them with WinZip.

Follow the directions below 
(l2-tools/stanley-jmpl/README-WINDOWS.txt)
or from our division web server:
http://ic.arc.nasa.gov/projects/L2/doc/starting/stanley-build-win32.html

The support files will not change with new L2/L2Tools releases.

However, with each new release, you will be e-mailed new tar files:
l2-src_<n.m>.tar.gz, l2tools-src_<n.m>.tar.gz, and
groundworks-src_<n.m>.tar.gz.  Discard all the top directories, 
except for support:
% /bin/rm -rf  mba l2-regress l2-tools 
Unpack the new tar files and re-build.

NOTE: If you have received this software under the NASA Open Source Agreement,
      l2tools-src_<n.m>.tar.gz will be replaced by l2tools-src-no-mico_<n.m>.tar.gz.
      See instructions on installing MICO on your system in README.install-MicoCombat.


BUILDING & INSTALLING STANLEY VJMPL (AND LIVINGSTONE, L2TOOLS, & OLIVER TOO)
------------------------------------------------------------

Setting Environment Variables
=============================
HOME can be set in autoexec.bat, as done immediately below.  However,
if the autoexec.bat setting of HOME is required to be something
different, it can be done in cygwin.

autoexec.bat
---------------------
SET HOME=C:\cygwin\home\wtaylor

REM May already be set on some Windows releases
SET WINTEMP=C:\TEMP
SET TEMP=C:\TEMP
SET TMP=C:\TEMP

REM CVS vars only used internal to Ames
SET CVSROOT=:ext:taylor@serengeti.arc.nasa.gov:/home/cvs/ISG-Repository
SET CVS_RSH=ssh.exe

Setting HOME in Cygwin
======================
Edit the /etc/profile file. You can edit this file under cygwin 
or windows. In the cygwin environment, vi /etc/profile. In windows, 
open /cygwin/etc/profile with WinWord (Notepad doesn't handle the 
formatting properly). Comment out the if check for $HOME containing 
no characters and change the path to your desired cygwin/home.
For example, below the user has installed cygwin on e:\cygwin.

/etc/profile
------------
PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

USER="`id -un`"

# Set up USER's home directory
# Force the cygwin HOME directory
#if [ -z "$HOME" ]; then
  HOME="/cygdrive/e/cygwin/home/$USER"
#fi
...
...

To build C++-Livingstone:
=========================

o Microsoft Visual C++ 6.0

To enable mode recovery, ensure that ENABLE_RECOVERY is defined in the 
project files for readers, debuggers and transition.

  L2Tools/Stanley/Oliver Compatible L2 Shared Library
  -----------------------------------------------
  File->Open Workspace: mba/mba.dsw 
  Project->Set Active Project: livdll 
  Build->Rebuild All
  Project->Set Active Project: l2test
  Build->Build l2test.exe


To build Stanley and its support programs
=========================================

"Start->Programs->MS-DOS Prompt"
----------------

# set VC++ env variables, e.g.
D:\progra~1\micros~1\vc98\bin\vcvars32.bat
# set L2 root env variable, e.g.
set L2_ROOT=D:\cygwin\home\wtaylor\L2

cd %L2_ROOT%\l2-tools\stanley-jmpl
Makefile-all.bat

# Make .dll file executable, if not already so
----------------------------------------------
# In a Cygwin window
% cd $L2_ROOT/l2-tools/stanley-jmpl/support/combat-win32
% chmod a+x combat.dll


--------------------


