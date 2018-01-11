#!/bin/csh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: RUN-wish.csh,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# RUN-wish.csh

# --------------------------------------------------------

## check for args
set validOption = 1
set arg_tkcon = 0

foreach arg ($*)
  if ("$arg" == "-tkcon") then
    set arg_tkcon = 1
  else
    echo "$arg is an invalid option! -- USER OPTIONS : -tkcon"
    set validOption = 0
  endif
end
if ($validOption == 0) then
  exit
endif

## set STANLEY_ROOT
# if stanley.csh has been executed, use it -- do not set env vars again
# also allows debugging settings to be used

if (! ${?STANLEY_ROOT}) then
  if (! -f RUN-wish.csh) then
    # needed for setting STANLEY_ROOT 
    echo "current directory is not <STANLEY_ROOT>/interface/"
    exit
  else
    # this is being called from the shell in this directory
    # source Stanley environment variables
    set base = `pwd`
    cd `dirname $base`
    # clear argument list, so stanley.csh will not get it
    set n = 1
    foreach arg ($*)
      # echo "n $n argv $argv[$n]"
      set argv[$n] = ""
      @ n = $n + 1
    end
    source stanley.csh
    cd interface
  endif
endif


## Tcl/Tk
if ("$arg_tkcon" == "1") then
  $STANLEY_ROOT/support/tclTk8.3/bin/wish8.3 \
        $STANLEY_ROOT/support/tkcon-1.6/tkcon.tcl
else
  $STANLEY_ROOT/support/tclTk8.3/bin/wish8.3
endif


# --------------------------------------------------------

