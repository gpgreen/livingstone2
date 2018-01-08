#!/bin/tcsh -f
# -f Fast start. do not read the  .cshrc  file
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# start L2Tools command line in current xterm
# after setting environment with stanley.csh

# default is to run L2Tools GUI front end
# rather than the command line front end

set validOption = 1
set arg_gcInit_seen = no
set arg_gcInit = "32"
set arg_gcMax_seen = no
set arg_gcMax = "192"
set arg_win32 = 0
set options = "OPTIONS : -gcinit <nn>, -gcmax <nn>, & -win32" 
# to debug core dumps
# gdb "/home/wtaylor/pub/jdk1.3.0_02/bin/i386/native_threads/java forwill.Server" core

foreach arg ($*)
  if ("$arg" == "-gcinit") then
    set arg_gcInit_seen = yes
  else if ("$arg_gcInit_seen" == "yes") then
    set arg_gcInit_seen = no
    set arg_gcInit = $arg
  else if ("$arg" == "-gcmax") then
    set arg_gcMax_seen = yes
  else if ("$arg_gcMax_seen" == "yes") then
    set arg_gcMax_seen = no
    set arg_gcMax = $arg
  else if ("$arg" == "-win32") then
    set arg_win32 = 1
  else if ("$arg" == "-help") then
    echo $options 
    set validOption = 0
  else
    echo -n "$arg is an invalid option! -- "
    echo $options 
    set validOption = 0
  endif
end
if ($validOption == 0) then
  exit
endif

echo ""
echo "Java GC initial space = ${arg_gcInit}mb"
echo "Java GC maximum space = ${arg_gcMax}mb"
echo ""

set MKDIR = /bin/mkdir

if (! -f RUN-L2TOOLS.csh) then
  # needed for relative directory usage
  echo "current directory is not ${STANLEY_ROOT}/interface/"
  exit
endif

# set environment
cd ..
# clear argument list, so stanley.csh will not get it
set n = 1
foreach arg ($*)
  # echo "n $n argv $argv[$n]"
  set argv[$n] = ""
  @ n = $n + 1
end

if ("$arg_win32" == "1") then
  source stanley-win32.csh
else
  source stanley.csh
endif
set return_flag = $?
# echo return_flag $return_flag 
if ( $return_flag != 0 ) then
  exit
endif

# move to user's home directory so that stanleyengine.ior
# is written to ${HOME}/.stanley, where Stanley expects it to be.
cd ${HOME}

if (! -d .stanley) then
  ${MKDIR} .stanley
endif

cd .stanley

# -verbose:gc show user what GC is doing
# -Xms -- initial GC space => 30mb (JVM default 2mb)
# -Xmx -- max GC space => 192mb    (JVM default 64mb)
# java.lang.OutOfMemoryError thrown if max GC space exceeded
${JAVA_BIN}/java -verbose:gc -Xms${arg_gcInit}m -Xmx${arg_gcMax}m forwill.Server



