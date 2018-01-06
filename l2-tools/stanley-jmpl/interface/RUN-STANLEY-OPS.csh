#!/bin/csh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: RUN-STANLEY-OPS.csh,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# RUN-STANLEY-OPS.csh
# Run STANLEY GUI in operational mode, reading messages from a file
#  written by the GPU (ground processing unit)

# Stanley requires the CORBA ior from the GPU to connect
# and expects to find it as: ~/.stanley/gpu.ior
# gpu-directory-1:
#    ./run-gpu
# gpu-directory-2:
#    cp -p stanleyengine.ior ~/.stanley/gpu.ior

# USER OPTIONS:

# specify the GPU workspace directory
# % ./RUN-STANLEY-OPS.csh -gpudir
# default is /home/wtaylor/stanley-projs/RxU/stanley_models (x-34)

# specify the GPU schematic file
# % ./RUN-STANLEY-OPS.csh -gpufile
# default is mainPropulsionSystem 

# to process the multiple window launch script, whose pathname 
# is defined by OPS_LAUNCH_SCRIPT in this file
# % ./RUN-STANLEY-OPS.csh -launch

# to run from the Smart Board PC via telnet
# % ./RUN-STANLEY-OPS.csh -sbpc

# to generate warnings if messages are not handled as expected
# % ./RUN-STANLEY-OPS.csh -warn

# DEVELOPER OPTIONS:

# to run in debug mode - DDD debugger
# % ./RUN-STANLEY-OPS.csh -debug

# to run with Tcl X at Ames - for tcl profiling
# uncomment next line in gui/stanley/c/Makefile
# cEXTERNLIBS += -L$(STANLEY_TCL_TK_LIB) -ltclx8.0.0
# uncomment #define TCL_X in gui/stanley/c/TkAppInit.c
# mbuild build/install in gui/stanley/c
# see man TclX for documentation
# see stanley/debug.tcl for profile functions
# enter via TkCon
# debugging
# cmdtrace on
# cmdtrace off

# --------------------------------------------------------

### check options
# --------------------------------------------------------
set validOption = 1
set arg_warn = 0
set arg_launch = 0
set arg_debug  = 0
set arg_sbpc = 0
set arg_gpudir = 0
set arg_gpufile = 0
set gpu_workspace_dir = ""
set gpu_schematic_file = ""

foreach arg ($*)
  if ("$arg" == "-warn") then
    set arg_warn = 1
  else if ("$arg" == "-launch") then
    set arg_launch = 1
  else if ("$arg" == "-debug") then
    set arg_debug = 1
  else if ("$arg" == "-sbpc") then
    set arg_sbpc = 1
  else if ("$arg" == "-gpudir") then
    set arg_gpudir = 1
  else if ("$arg_gpudir" == "1") then
    set gpu_workspace_dir = $arg
    set arg_gpudir = 0
  else if ("$arg" == "-gpufile") then
    set arg_gpufile = 1
  else if ("$arg_gpufile" == "1") then
    set gpu_schematic_file = $arg
    set arg_gpufile = 0
  else
    echo "$arg is an invalid option! -- USER OPTIONS : -gpudir, -gpufile, -launch, -sbpc, and -warn"
    echo " -- DEVELOPER OPTIONS : -debug"
    set validOption = 0
  endif
end
if ($validOption == 0) then
  exit
endif

# --------------------------------------------------------

# if stanley.csh has been executed, use it -- do not set env vars again
# also allows debugging settings to be used

if (! ${?STANLEY_ROOT}) then
  if (! -f RUN-STANLEY-OPS.csh) then
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

# --------------------------------------------------------
# start site configurable

## Unix
setenv UNIX_BIN /bin

## Stanley
setenv STANLEY_BIN_DIR $STANLEY_ROOT/bin

# end site configurable
# --------------------------------------------------------
# --------------------------------------------------------

# note that LIVINGSTONE_DIRECTORY > 18 chars => I cannot utilize it in this csh

# --------------------------------------------------------
# --------------------------------------------------------
# start user configurable

# being superuser allows stanley/tclIndex to be modified
# being superuser allows editing of READ_ONLY_DEFS in VMPL mode
if ("$OSTYPE" == "solaris") then
  setenv STANLEY_SUPERUSER taylor
else if ("$OSTYPE" == "linux") then
  setenv STANLEY_SUPERUSER wtaylor
else
  echo "OSTYPE $OSTYPE not handled"
  exit
endif

## defaults

# directory of operational workspace
if ("$gpu_workspace_dir" == "") then
  set gpu_workspace_dir = $HOME/stanley-projs/RxU/stanley_models
endif
# name of schematic file to be loaded in operational mode
if ("$gpu_schematic_file" == "") then
  set gpu_schematic_file = mainPropulsionSystem
endif

# these definitions can only be edited by the superuser
# the first one is the type def for displayState attribute class
setenv READ_ONLY_DEFS value:displayStateValues
# testing
# setenv READ_ONLY_DEFS value:displayStateValues:relation:willRel:symbol:rare:component:acsControlMode:module:powerRelay

# end user configurable 
# --------------------------------------------------------
# --------------------------------------------------------


### start the Stanley GUI
# --------------------------------------------------------

$STANLEY_BIN_DIR/stanley-bin $STANLEY_ROOT/src/stanley.tcl \
      -geometry 0x0+0+0 -- \
      g_NM_schematicMode operational \
      g_NM_gpuWorkspaceDir $gpu_workspace_dir \
      g_NM_gpuSchematicFile $gpu_schematic_file \
      g_NM_opsWarningsP $arg_warn \
      g_NM_smartBoardPC $arg_sbpc \
      g_NM_groundProcessingUnitP 1

# --------------------------------------------------------

