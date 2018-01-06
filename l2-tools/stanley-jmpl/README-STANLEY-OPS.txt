# $Id: README-STANLEY-OPS.txt,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

Contents
--------
o CONFIGURING STANLEY OPS
o CREATION OF USER DIRS/FILES
o STANLEY PREFERENCES (optional)
o RUNNING STANLEY OPS SCRIPT 

o STANLEY TCL/TK PACKAGE AND ENVIRONMENT VARIABLE DEPENDENCIES
o CHECKING OUT STANLEY OPS SOURCE FILES
o SOURCE STANLEY ENVIRONMENT VARIABLES 
o BUILDING & INSTALLING STANLEY OPS 
o RUNNING STANLEY ON SMART BOARD VIA TELNET



CONFIGURING STANLEY OPS
------------------------------------------------------------
Modify these variables in the "user configurable" section of the 
RUN-STANLEY-OPS.csh file, as needed:

% cd <user's stanley-root dir>/l2-tools/stanley/interface
% cp RUN-STANLEY-OPS.csh RUN-STANLEY-OPS-<proj_id>.csh
  where you choose an appropriate proj_id

=> edit RUN-STANLEY-OPS-<proj_id>.csh in "start user configurable"
   section to specify:

# define path for generated MPL Lisp code, schematics, and 
  component/module bitmaps:
  setenv STANLEY_USER_DIR <unspecified>
    replace <unspecified> with an absolute pathname, consistent with
    RUN-STANLEY-VMPL-<proj_id>.csh

  set project_id = <unspecified> 
    replace <unspecified> with <proj_id>

# name of schematic file to be loaded in operational mode
  setenv OPS_SCHEMATIC_FILE <unspecified>

# pathname for tcl command file which launches multiple slave windows and
# configures them
  setenv OPS_LAUNCH_SCRIPT $STANLEY_USER_DIR/$LIVINGSTONE_SUBDIR/ops-launch-script.tcl



CREATION OF USER DIRS/FILES
---------------------------------------------------------
This is done the first time that RUN-STANLEY-VMPL-<proj_id>.csh 
is executed.


STANLEY PREFERENCES (optional)
------------------------------------------------------------
Menu selection "Edit->Preferences" will allow the user to set
some Stanley preferences.


RUNNING STANLEY OPS
------------------------------------------------------------
The script file to run Stanley OPS (RUN-STANLEY-OPS-<proj_id>.csh) is in:

  <your-root-dir>/l2-tools/stanley/interface

# --------------------------------------------------------
# --------------------------------------------------------

# RUN-STANLEY-OPS-<proj_id>.csh
# Run STANLEY MIR-GUI in operational mode

# USER OPTIONS:

# to process the multiple window launch script, whose pathname 
# is defined by OPS_LAUNCH_SCRIPT in this file
# % ./RUN-STANLEY-OPS-<proj_id>.csh -launch

# to run from the Smart Board PC via telnet
# % ./RUN-STANLEY-OPS-<proj_id>.csh -sbpc

# to generate warnings if IPC messages are not handled as expected
# % ./RUN-STANLEY-OPS-<proj_id>.csh -warn

# DEVELOPER OPTIONS:

# to run in debug mode - DDD debugger
# % ./RUN-STANLEY-OPS-<proj_id>.csh -debug

# to save MIR telemetry sent by MIR for use by
# Tools->Run Scenario from File
# % ./RUN-STANLEY-OPS-<proj_id>.csh -ipc-recorder-file <file-name>

# to run the interpreted version of Stanley, rather than the 
# compiled version (allows interactive development, but runs 
# ~20% slower)
# % ./RUN-STANLEY-OPS-<proj_id>.csh -nocomp


# --------------------------------------------------------
# --------------------------------------------------------


STANLEY TCL/TK PACKAGE AND ENVIRONMENT VARIABLE DEPENDENCIES 
--------------------------------------
See Stanley's environment file
        <your-root-dir>/l2-tools/stanley/stanley.csh

o Software sources
TCL/TK 8.0.3 - 
http://www.scriptics.com/software/8.0.html
TCL8.0.3 PLUS PATCH -
ftp://ftp.nici.kun.nl/pub/tkpvm/tcl8.0.3plus.patch.gz
TK8.0.3 PLUS PATCH -
ftp://ftp.nici.kun.nl/pub/tkpvm/tk8.0.3plus.patch.gz
tkTable 2.4
http://www.hobbs.wservice.com/tcl/


CHECKING OUT STANLEY OPS SOURCE FILES 
% setenv CVSROOT /home/mars/DS1-2/cvs-space/ISG-Repository
Have /usr/local2/GNU/bin in your path to locate cvs

% cd <your-root-dir>
% cvs checkout stanley-ops  ## same as stanley-vmpl ?????

stanley-ops is a CVS alias module defined as
stanley-ops -a l2-tools/stanley mba/livingstone mba/utils mba/projects/rax
------------------------------------------------------------


SOURCE STANLEY ENVIRONMENT VARIABLES 
-------------------------------------------------------------
% cd <your-root-dir>/l2-tools/stanley
% source stanley.csh


BUILDING & INSTALLING STANLEY OPS 
------------------------------------------------------------
% cd <your-root--dir>/l2-tools/stanley

% make                           # build compiled & interpreted Stanley OPS
                                 # => stanley/bin/stanley-compiled-bin
                                 # => stanley/bin/stanley-bin
                                 # and
                                 # => stanley/bin/livingstone-bin

NOTES: Compiled Stanley runs about 20-25% faster than interpreted Stanley.
       Compiled Stanley requires that the "plus patches" be applied to
         the Tcl/Tk distribution, and that stanley.csh.stage reference
         the result.



RUNNING STANLEY ON SMART BOARD VIA TELNET
------------------------------------------

o Turn on Smart Board screen with "remote" button ON
o Increase screen resolution to max, if needed ..
        - Start->Settings->Control Panels
        - Double-click Display, select Settings
        - move slider to max position of 1024x768
o Start->Program->Exceed->Exceed
o Start->Run Program->Telnet
o Logon the Stanley client machine; set DISPLAY to "sbpc:0.0"
o cd to <root>/ra/mir/gui/stanley/user-template
o ./RUN-STANLEY-OPS-<proj_id>.csh -sbpc

# --------------------------------------------------------


