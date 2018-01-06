#! /bin/csh -f
# -f Fast start. do not read the  .cshrc  file
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# this is invoked from L2Tools via the StanleyViewer cmd
# stanley.csh is assumed to have already been sourced by
# RUN-L2TOOLS.csh


set validOption = 1
set arg_2 = 

foreach arg ($*)
  if ("$arg" == "-viewer") then
    set arg_2 = -viewer
  else
    echo "$arg is an invalid option! -- OPTIONS : -viewer"
    set validOption = 0
  endif
end
if ($validOption == 0) then
  exit
endif

if (${OSTYPE} == "linux") then
  xterm -sb -sl 10000 -bg "Gray60" -fg "Black" \
       -T "Stanley Viewer Xterm" -n "STANLEY VIEWER XTERM" \
       -geometry 80x40+300+0 -rightbar \
       -e $STANLEY_ROOT/interface/RUN-STANLEY-VJMPL.csh -exists $arg_2 &
else if (${OSTYPE} == "solaris") then
  # Solaris X11R5 does not support -rightbar
  xterm -sb -sl 10000 -bg "Gray60" -fg "Black" \
       -T "Stanley Viewer Xterm" -n "STANLEY VIEWER XTERM" \
       -geometry 80x40+300+0 \
       -e $STANLEY_ROOT/interface/RUN-STANLEY-VJMPL.csh -exists $arg_2 &
else 
  echo "OSTYPE ${OSTYPE} not handled"
endif
