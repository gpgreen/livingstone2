#!/bin/tcsh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: stanley-win32.csh,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## set location dependent env vars
## runs under tcsh, under Cygwin, under Windows32

set validOption = 1
set arg_reset = 0

foreach arg ($*)
  if ("$arg" == "-reset") then
    set arg_reset = 1
  else
    echo "$arg is an invalid option! -- OPTIONS : -reset"
    set validOption = 0
  endif
end
if ($validOption == 0) then
  exit
endif

if ($arg_reset == 1) then
  unsetenv STANLEY_ROOT
  # path can become too long => "Word too long."
  if (-f ~/.cshrc) then
    source ~/.cshrc
  endif
  if (-f ~/.login) then
    source ~/.login -reset
  endif
endif

if (! -f stanley-win32.csh ) then
  # needed for setting STANLEY_ROOT
  echo "stanley.csh: current directory is not <root>"
  exit
endif

## check that inherited STANLEY_ROOT is correctly set
if (${?STANLEY_ROOT}) then
  if (! -f $STANLEY_ROOT/stanley-win32.csh ) then
    echo stanley-win32.csh: STANLEY_ROOT was $STANLEY_ROOT
    unsetenv STANLEY_ROOT
  endif
endif

if (! ${?STANLEY_ROOT}) then
  # only set these vars once -- since this is called by
  # RUN-STANLEY-VJMPL.csh & RUN-STANLEY-OPS.csh

  # paths for path env var must not have D:/cygwin prefix
  setenv STANLEY_ROOT_SHORT `pwd`
  setenv STANLEY_ROOT $L2_ROOT/l2-tools/stanley-jmpl
  setenv L2TOOLS_ROOT $L2_ROOT/l2-tools
  setenv LIVINGSTONE_ROOT $L2_ROOT/mba
  setenv SUPPORT_ROOT $L2_ROOT/support

    echo stanley-win32.csh: L2_ROOT set to $L2_ROOT 
    echo stanley-win32.csh: STANLEY_ROOT set to $STANLEY_ROOT 
    echo stanley-win32.csh: set LIVINGSTONE_ROOT to $LIVINGSTONE_ROOT
    echo stanley-win32.csh: set L2TOOLS_ROOT to $L2TOOLS_ROOT 
    echo stanley-win32.csh: SUPPORT_ROOT set to $SUPPORT_ROOT 

    setenv PS_CMD /bin/ps

    # for Tcl/Tk
    setenv GENERIC_LIBS /usr/lib
    setenv STANLEY_TCL_L tcl83
    setenv STANLEY_TK_L tk83
    setenv STANLEY_ITCL_L itcl32
    setenv STANLEY_TKTABLE_L Tktable26

    setenv TCL_LIBRARY $L2_ROOT/l2-tools/stanley-jmpl/support/tclTk8.3/lib/tcl8.3
    setenv TK_LIBRARY $L2_ROOT/l2-tools/stanley-jmpl/support/tclTk8.3/lib/tk8.3
    setenv STANLEY_TCL_TK_INC $L2_ROOT/l2-tools/stanley-jmpl/support/tclTk8.3/include
    setenv STANLEY_TCL_TK_LIB $L2_ROOT/l2-tools/stanley-jmpl/support/tclTk8.3/lib
    setenv STANLEY_TCL_SRC $L2_ROOT/support/stanley-support-src/tclTk8.3/tcl8.3.3
    setenv STANLEY_TK_SRC $L2_ROOT/support/stanley-support-src/tclTk8.3/tk8.3.3
    setenv STANLEY_TKTABLE_LIB $L2_ROOT/l2-tools/stanley-jmpl/support/tclTk8.3/lib/Tktable2.6
    setenv STANLEY_TKTABLE_SRC $L2_ROOT/support/stanley-support-src/tclTk8.3/Tktable2.6/src

    # CORBA
    # combat.dll contains mico 2.3.1 + patches and combat 0.6.1
    setenv MICO_LIB $L2_ROOT/l2-tools/stanley-jmpl/support/combat-win32
    setenv TCL_MICO_LIB $L2_ROOT/l2-tools/stanley-jmpl/support/combat-win32
    setenv CORBA_DIR $L2_ROOT/l2-tools/stanley-jmpl/interface/livingstone/corba

    # for idl2tcl's invocation of ird; and tclmicosh
    set path = ($STANLEY_ROOT_SHORT/support/combat-win32 $path)

    # for tclTk .dll files
     set path = ($path $STANLEY_ROOT_SHORT/support/tclTk8.3/bin \
                 $STANLEY_ROOT_SHORT/support/tclTk8.3/lib/Tktable2.6)
 
    ## Livingstone .dll shared libraries for L2Tools JNI wrapper
    set path = ($path $STANLEY_ROOT_SHORT/../../mba/cpp/lib)

    ## add . to path for exec of compile script file
    ## generate-mpl.tcl - runJmpl
    set path = ($path .)

   # does user have JAVA_HOME set
    if (${?JAVA_HOME}) then
      rm -f config.jv
      # must be done in sh, since java is an sh script
      sh -c "$JAVA_HOME/bin/java -version 2> config.jv"
      set java_version = `cat config.jv`
      # echo java_version W $java_version
      # java version "1.3.0_02"
      set version_2 = `echo $java_version | awk -F\" '{print $2}'`
      # echo version_2 $version_2
      set match_test = `expr match $version_2 '.*1\.5\.*'`
      # echo match_test $match_test 
      if ( $match_test == 0 ) then
        echo "$JAVA_HOME not jdk1.5.*"
        exit 1
      endif
    else
      echo "JAVA_HOME not set - L2Tools requires Java JDK 1.5.* or later"
      exit 1
    endif
    setenv JAVA_BIN $JAVA_HOME/bin
    setenv THREADS_FLAG native

    ## Java class path for L2 Tools
    setenv CLASSPATH $L2_ROOT/l2-tools/jars/l2Tools.jar
    
    ## for Lint, and Compiler
    # the compiler source is now in java/src and it is jarred into l2Tools.jar
    # the 3rd party libraries are added
    setenv CLASSPATH ${CLASSPATH}\;${L2_ROOT}/l2-tools/java/lib/aelfred.jar\;${L2_ROOT}/l2-tools/java/lib/antlr.jar\;${L2_ROOT}/l2-tools/java/lib/domlight-1.0.jar\;${L2_ROOT}/l2-tools/java/lib/sax.jar\;${L2_ROOT}/l2-tools/java/lib/openjgraph.jar
    ## for other L2 tools
   setenv CLASSPATH ${CLASSPATH}\;${L2_ROOT}/l2-tools/jars/browser.jar

    ## dummy for stanley.tcl
    setenv LD_LIBRARY_PATH ${STANLEY_TCL_TK_LIB}

endif










