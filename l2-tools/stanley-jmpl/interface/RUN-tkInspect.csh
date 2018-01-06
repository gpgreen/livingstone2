#!/bin/csh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: RUN-tkInspect.csh,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# RUN-tkInspect.csh
# Run tkInspect
# --------------------------------------------------------

if (! ${?DS1_ROOT}) then
  echo "RUN-tkInspect.csh: DS1_ROOT has not been set\!"
  exit
endif
# --------------------------------------------------------
# --------------------------------------------------------
# start site configurable

if (-d /home/tove/p/autosat/stanley ) then  # AMES - muir/jabberwock (development)
  set site = ames_jabberwock
else if (-d /home/copernicus/id2/taylor ) then  # AMES - copernicus (MIR release)
  set site = ames_copernicus
else if (-d /proj/nm-ds1 ) then # JPL - FST (FST release)
  set site = jpl_fst
else
  echo "cannot determine on which host I am"
  exit
endif
## echo "site determined to be $site"

## Tcl/Tk
if (("$site" == "ames_jabberwock") || ("$site" == "ames_copernicus")) then
#   ## Tcl version 7.6
#   setenv TCL_LIBRARY /home/copernicus/id2/taylor/TclTk/lib/tcl7.6
#   ## setenv TCL_LIBDIR /home/copernicus/id2/taylor/TclTk/lib
#   ## setenv TCL_INCDIR /home/copernicus/id2/taylor/TclTk/include/tcl7.6-tk4.2
#   ## Tk version 4.2
  setenv TK_LIBRARY /home/copernicus/id2/taylor/TclTk/lib/tk4.2
  setenv TK_LIBDIR /home/copernicus/id2/taylor/TclTk/lib
  set wishPath =   /home/copernicus/id2/taylor/TclTk/bin/wish4.2
  setenv TK_INSPECT_DIR /home/copernicus/id2/taylor/TclTk/tkinspect-5
  setenv TK_INSPECT_LIB /home/copernicus/id2/taylor/TclTk/lib
else if ("$site" == "jpl_fst") then
#   setenv TCL_LIBRARY /usr/local/auto/opt/tcltk-7642/lib/tcl7.6
#   ##  setenv TCL_LIBDIR /usr/local/auto/opt/tcltk-7642/lib
#   ##  setenv TCL_INCDIR /usr/local/auto/opt/tcltk-7642/include
  setenv TK_LIBRARY /usr/local/auto/opt/tcltk-7642/lib/tk4.2
  setenv TK_LIBDIR /usr/local/auto/opt/tcltk-7642/lib
  set wishPath = /usr/local/auto/opt/tcltk-7642/bin/wish4.2
  setenv TK_INSPECT_DIR /home/taylor/TclTk/tkinspect-5
  setenv TK_INSPECT_LIB /home/taylor/TclTk/lib
endif

## Stanley
setenv STANLEY_DIR $DS1_ROOT/ra/mir/gui/stanley

# --------------------------------------------------------

cd $STANLEY_DIR

$wishPath -f $STANLEY_DIR/tkinspect.tcl

# --------------------------------------------------------
