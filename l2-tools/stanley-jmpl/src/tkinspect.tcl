# $Id: tkinspect.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## called by wish via ../stanley-user/RUN-tkInspect.csh

## 01nov95 wmt: needed to set auto_path properly on first build
## then not needed ???
## lappend auto_path /home/copernicus/id2/taylor/TclTk/lib/tkinspect
lappend auto_path $env(TK_LIBDIR)/tk4.2
lappend auto_path $env(TK_INSPECT_LIB)/tkinspect
## 01nov95 wmt: needed for tkinspect.tcl to set tkinspect_library properly
global tkinspect_library
## set tkinspect_library /home/copernicus/id2/taylor/TclTk/lib/tkinspect
set tkinspect_library $env(TK_INSPECT_LIB)/tkinspect

## source /home/copernicus/id2/taylor/TclTk/tkinspect-5/tkinspect.tcl
source $env(TK_INSPECT_DIR)/tkinspect.tcl
