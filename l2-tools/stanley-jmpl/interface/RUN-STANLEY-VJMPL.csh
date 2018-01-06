#!/bin/tcsh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: RUN-STANLEY-VJMPL.csh,v 1.2 2006/04/29 00:47:38 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

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
# derived from .scm files (.i-scm, .terms, .dep, .jmpl)
# % ./RUN-STANLEY-VMPL.csh -nochk

# to *not* run with CORBA interface to Livingstone tools
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

# note: max length of set vars evaluated in csh = 18 chars
# --------------------------------------------------------

### check options
# --------------------------------------------------------
set validOption = 1
set arg_debug  = 0
set arg_gcInit_seen = no
set arg_gcInit = "32"
set arg_gcMax_seen = no
set arg_gcMax = "192"
set arg_profile = 0
set arg_sbpc = 0
set arg_tools = 1
set arg_fileChk = 1
set arg_exists = 0
set arg_viewer = 0
set arg_win32 = 0
set arg_regen = 0
set options_1 = " -- USER OPTIONS : -exists, -gcinit <nn>, -gcmax <nn>, -nochk, -notools, -regen, -sbpc, -viewer, & -win32"
set options_2 = " -- DEVELOPER OPTIONS : -debug, and -profile"  
echo "windoz"
foreach arg ($*)
  if ("$arg" == "-debug") then
    set arg_debug = 1
  else if ("$arg" == "-gcinit") then
    set arg_gcInit_seen = yes
  else if ("$arg_gcInit_seen" == "yes") then
    set arg_gcInit_seen = no
    set arg_gcInit = $arg
  else if ("$arg" == "-gcmax") then
    set arg_gcMax_seen = yes
  else if ("$arg_gcMax_seen" == "yes") then
    set arg_gcMax_seen = no
    set arg_gcMax = $arg
  else if ("$arg" == "-profile") then
    set arg_profile = 1
  else if ("$arg" == "-notools") then
    set arg_tools = 0
  else if ("$arg" == "-sbpc") then
    set arg_sbpc = 1
  else if ("$arg" == "-nochk") then
    set arg_fileChk = 0
  else if ("$arg" == "-exists") then
    set arg_exists = 1
  else if ("$arg" == "-viewer") then
    set arg_viewer = 1
  else if ("$arg" == "-win32") then
    set arg_win32 = 1
  else if ("$arg" == "-regen") then
    set arg_regen = 1
  else if ("$arg" == "-help") then 
    echo $options_1 
    echo $options_2 
    set validOption = 0
  else
    echo "$arg is an invalid option!"
    echo $options_1 
    echo $options_2 
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
  if (! -f RUN-STANLEY-VJMPL.csh) then
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

    if ("$arg_win32" == "1") then
      source stanley-win32.csh
    else
      source stanley.csh
    endif

    # Solaris8 gets a variable syntax error on the next line,
    # if executed in the csh, so change top line of script
    # tcsh, which works
    set return_flag = $?
    # echo return_flag $return_flag 
    if ( $return_flag != 0 ) then
      exit
    endif
    cd interface
  endif
endif
# --------------------------------------------------------
# --------------------------------------------------------
# start site configurable

## Unix
setenv UNIX_BIN /bin

## Stanley
setenv STANLEY_BIN_DIR $STANLEY_ROOT/bin


# end site    configurable
# --------------------------------------------------------
# --------------------------------------------------------

# note that LIVINGSTONE_DIRECTORY > 18 chars => I cannot utilize it in this csh

# --------------------------------------------------------
# --------------------------------------------------------
# start user configurable

# all class definition schematics created by Stanley VJMPL will go here
# as well as generated MPL code
# setenv STANLEY_USER_DIR <unspecified>
# this is now specified by each user in Edit->Preferences

# $STANLEY_USER_DIR/bitmaps optionally contains pairs of files 
# for image maps of component/module class names:
# {nodeClassName} => bitmap; 1 = foreground; 0 = background (created by bitmap)
# {nodeClassName}-mask => bitmap; 1 = show fg/bg; 0 = transparent (created by bitmap) 

# the project id on the Stanley window mgr title bar
# set project_id = <unspecified>
# this is now specified by each user in Edit->Preferences

# being superuser allows stanley/tclIndex to be modified
# being superuser allows editing of READ_ONLY_DEFS in VJMPL mode
if ("$OSTYPE" == "solaris") then
  setenv STANLEY_SUPERUSER taylor
else if ("$OSTYPE" == "linux") then
  setenv STANLEY_SUPERUSER wtaylor
else if ("$arg_win32" == "1") then
  setenv STANLEY_SUPERUSER wtaylor
else
  echo "OSTYPE $OSTYPE not handled"
  exit
endif

# testing
# setenv STANLEY_SUPERUSER taylorxx

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

if ( ! -f $STANLEY_BIN_DIR/stanley-bin ) then
  echo "$STANLEY_BIN_DIR/stanley-bin does not exist"
  exit
endif

# set num_entries1 = `$PS_CMD uxww | grep stanley-bin | grep -v grep | wc -l`
# set num_entries2 = `$PS_CMD uxww | grep stanley-compiled-bin | grep -v grep | wc -l`

# allow two Stanleys to run at the same time
set num_entries1 = 0
set num_entries2 = 0
if (("$num_entries1"  == "0") && ("$num_entries2"  == "0")) then
  if ("$arg_debug" == "1") then
    ## Tcl debugger - Tuba
    ## cannot handle the -geometry 0x0+0+0 -- args
    # -w "" -- 
    #            Sets the working directory to be in when debugging your application. 
    #            If <workingdir> is set to "", then it will default to the same 
    #            directory the application resides in.
    # -c <cache_dir>
    # -e <proc inclusion file> # invert exclusion to inclusion by hack
    #     in tuba_lib.tcl - isProcExcluded
    # /home/serengeti/id1/pub/tclTk8.3/tuba-2.5.b1/tuba \
    #   -i $STANLEY_BIN_DIR/stanley-bin \
    #   -w $STANLEY_ROOT/interface \
    #   -c /home/serengeti/id1/pub/tclTk8.3/tuba-2.5.b1/cache \
    #   -e $STANLEY_ROOT/src/tuba-proc-includes \
    #   $STANLEY_ROOT/src/stanley.tcl \
    #   g_NM_schematicMode layout \
    #   g_NM_smartBoardPC $arg_sbpc \
    #   g_NM_l2ToolsP $arg_tools \
    #   g_NM_checkFileDatesP $arg_fileChk \
    #   g_NM_toolsL2ExistsP $arg_exists \
    #   g_NM_toolsL2ViewerP $arg_viewer \
    #   g_NM_win32P $arg_win32 \
    #   g_NM_profileP $arg_profile \
    #   g_NM_JVMGcInitSpace $arg_gcInit \
    #   g_NM_JVMGcMaxSpace $arg_gcMax \
    #   g_NM_regenP $arg_regen

    ### TclPro - prodebug
    ## cannot handle the -geometry 0x0+0+0 -- args

    # this crashes prodebug
    # Error in startup script: invalid command name "console"
    ## setenv TCL_LIBRARY /home/wtaylor/L2Root/l2-tools/stanley-jmpl/support/tclTk8.3/lib/tcl8.3
    ## setenv TCL_LIBRARY /home/wtaylor/pub/TclPro1.4/lib/tcl8.3
    ## setenv ITCL_LIBRARY /home/wtaylor/pub/TclPro1.4/lib/itcl3.2

    # args are set in project file: stanley.prj
    ## /home/wtaylor/pub/TclPro1.4/linux-ix86/bin/prodebug
    ## running prodebug causes "locale" to be redefined on Linux, resulting in
#     perl: warning: Setting locale failed.
#     perl: warning: Please check that your locale settings:
#         LANGUAGE = "en",
#         LC_ALL = "en",
#         LANG = "en"
#     are supported and installed on your system.
#     perl: warning: Falling back to the standard locale ("C").
    ## when running mba/cpp make install

    # and
#   Warning: locale not supported by C library, locale unchanged
    ## when runnning ./stanley

    echo "debug not functional"


    ## C code debugger
    ## ~taylor/bin/ddd-3.1.6-sparc-sun-solaris2.6
    # file/open program: l2-tools/stanley/bin/stanley-bin
    # % run $STANLEY_ROOT/src/stanley.tcl -geometry 0x0+0+0 -- g_NM_schematicMode layout \
    # % run g_NM_schematicMode layout \
    #         g_NM_compiledTcl 0 \
    #         g_NM_smartBoardPC 0 \
    #         g_NM_l2ToolsP 0 \
    #         g_NM_checkFileDatesP 0 \
    #         g_NM_toolsL2ExistsP 0 

#   else if ("$arg_profile" == "1") then
#     # Tcl/Tk profiler
#     $STANLEY_BIN_DIR/stanley-bin \
#       /home/mars/DS1-1/tcltk-80/sage-1.0/sage -w -data ~/sage.out \
#       $STANLEY_ROOT/src/stanley.tcl -geometry 0x0+0+0 -- \
#       g_NM_schematicMode layout \
#       g_NM_smartBoardPC $arg_sbpc \
#       g_NM_l2ToolsP $arg_tools \
#       g_NM_checkFileDatesP $arg_fileChk \
#       g_NM_toolsL2ExistsP $arg_exists \
#       g_NM_toolsL2ViewerP $arg_viewer \
#       g_NM_win32P $arg_win32 \
#       g_NM_profileP $arg_profile \
#       g_NM_JVMGcInitSpace $arg_gcInit \
#       g_NM_JVMGcMaxSpace $arg_gcMax \
#       g_NM_regenP $arg_regen
  else
    set stanleyExec = "$STANLEY_BIN_DIR/stanley-bin $STANLEY_ROOT/src/stanley.tcl"
    # use -geometry to reduce size of default wish window and not require mouse click
    $stanleyExec -geometry 0x0+0+0 -- \
      g_NM_schematicMode layout \
      g_NM_smartBoardPC $arg_sbpc \
      g_NM_l2ToolsP $arg_tools \
      g_NM_checkFileDatesP $arg_fileChk \
      g_NM_toolsL2ExistsP $arg_exists \
      g_NM_toolsL2ViewerP $arg_viewer \
      g_NM_win32P $arg_win32 \
      g_NM_profileP $arg_profile \
      g_NM_JVMGcInitSpace $arg_gcInit \
      g_NM_JVMGcMaxSpace $arg_gcMax \
      g_NM_regenP $arg_regen
  endif
else
  echo ""
  echo "Stanley is already running\!"
endif
# --------------------------------------------------------
# to view profiling results
# /home/mars/DS1-1/tcltk-80/sage-1.0/sageview -data ~/sage.out


