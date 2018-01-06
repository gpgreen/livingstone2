rem
rem See the file "l2-tools/disclaimers-and-notices.txt" for 
rem information on usage and redistribution of this file, 
rem and for a DISCLAIMER OF ALL WARRANTIES.
rem
rem the file will build tclTk 8.3.3, itcl 3.2, tkTable 2.6
rem and the latest version of Stanley

rem set VC++ env variables, e.g.
rem D:\progra~1\micros~1\vc98\bin\vcvars32.bat
rem set L2 root env variable, e.g.
rem set L2_ROOT=D:\cygwin\home\wtaylor\L2

rem Tcl
rem =========================================
cd %L2_ROOT%\support\stanley-support-src\tclTk8.3\tcl8.3.3\win
rem compile
nmake -f makefile.vc

rem install - nmake must be executed on the c: drive with the win, generic,
rem and library directories of tcl8.3.3 resident.
nmake -f makefile.vc install

rem Tk
rem =========================================
cd %L2_ROOT%\support\stanley-support-src\tclTk8.3\tk8.3.3\win
rem compile
nmake -f makefile.vc

rem install - nmake must be executed on the c: drive with the win, generic,
rem and library directories of tk8.3.3 resident.
nmake -f makefile.vc install

rem Itcl
rem =========================================
cd %L2_ROOT%\support\stanley-support-src\tclTk8.3\itcl3.2
rem compile
nmake -f makefile.vc dist

rem install - nmake must be executed on the c: drive with the win, generic,
rem and library directories of itcl3.2/itcl resident.
nmake -f makefile.vc dist-install

rem TkTable
rem =========================================
cd %L2_ROOT%\support\stanley-support-src\tclTk8.3\Tktable2.6\win
rem compile
nmake -f makefile.vc 

rem install - nmake must be executed on the c: drive 
nmake -f makefile.vc install

rem Mico & Combat
rem =========================================
rem Do not need to build mico and combat; will use Windows binary:
rem l2-tools\stanley-jmpl\support\combat-win32\combat.dll

rem Stanley
rem =========================================
rem compile & install are done in same step
cd %L2_ROOT%\l2-tools\stanley-jmpl
nmake -f Makefile.win32

