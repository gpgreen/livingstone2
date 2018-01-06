# $Id: corba.tcl,v 1.2 2006/04/29 00:47:38 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## corba.tcl => handle CORBA client/server transactions

# need [incr Tcl] to support tcl server
if {$g_NM_win32P} {
  load $STANLEY_TCL_TK_LIB/../bin/${STANLEY_ITCL_L}.dll
  load $TCL_MICO_LIB/combat.dll
} else {
  package require Itcl
  package require combat; # formerly tclmico
}

## initialize as CORBA client
## 02sep99 wmt: new
proc initializeStanleyCORBAClient { } {
  global CORBA_DIR TCL_MICO_LIB MICO_LIB PATH LD_LIBRARY_PATH
  global g_NM_interfaceRepository g_NM_firstInstantiatedScopeP 
  global _ir_LivingstoneCorba STANLEY_ROOT env
  global g_NM_livingstoneEMORBObject g_NM_livingstoneCmdLineORBObject
  global g_NM_livingstoneEvtListORBObject g_NM_commandLineLockP
  global g_NM_freshCommandLineP g_NM_toolsL2ViewerP g_NM_win32P

  # use tclmico-0.5b/demo/hello-1 server - THIS WORKS!
  # comment out client stuff in hello script to run this
  # source /home/serengeti/id1/pub/tclmico-0.5b/demo/hello-1/hello.tcl
  # corba::init -ORBBindAddr inet:serengeti.arc.nasa.gov:8123
  # mico::ir add $_ir_hello
  # set obj [mico::bind IDL:HelloWorld:1.0]
  # $obj hello
  # puts stderr "[$obj _get_interface]"


  # NameService daemon - this must be started prior to starting Livingstone,
  # which invokes bind cmd to tell NameService about Livingstone 
  # exec $MICO_LIB/../bin/nsd -ORBIIOPAddr inet:${HOST}:$g_NM_corbaPort &
  # exec sleep 2
  # puts stderr "NameService daemon started"

  # if {! [file exists $MICO_LIB/../include/mico/naming.tcl]} {
  #   pushd $MICO_LIB/../include/mico
  #   exec $TCL_MICO_LIB/idl2tcl $MICO_LIB/../include/mico/naming.idl
  #   popd
  # }
  # waitForFileToBeWritten $MICO_LIB/../include/mico/naming.tcl

  # source $MICO_LIB/../include/mico/naming.tcl

  if {$g_NM_firstInstantiatedScopeP} {
    # load IDL definition of Livingstone interface
    ### only needed by a local Interface Repository
    ### we are now using an external Interface Repository 
    # This file is generated from livingstone-corba.idl
    # by idl2tcl.
    if {! [file exists $CORBA_DIR/LivingstoneCorba.tcl]} {
      pushd $CORBA_DIR
      if {$g_NM_win32P} {
        exec $TCL_MICO_LIB/idl2tcl --impl LivingstoneCorba.idl
      } else {
	exec $TCL_MICO_LIB/../bin/idl2tcl --impl LivingstoneCorba.idl
      }
      popd

      waitForFileToBeWritten $CORBA_DIR/LivingstoneCorba.tcl 
    }

    # puts stderr "PATH $PATH"
    # puts stderr "LD_LIBRARY_PATH $LD_LIBRARY_PATH"
    # exec $TCL_MICO_LIB/../bin/idl2tcl --impl $CORBA_DIR/LivingstoneCorba.idl
    # exec $MICO_LIB/../bin/idl --config $CORBA_DIR/LivingstoneCorba.idl

    puts stderr "\nSourcing $CORBA_DIR/LivingstoneCorba.tcl & LivingstoneCorba_impl.tcl\n"
    # define local interface repository: _ir_LivingstoneCorba 
    if {$g_NM_win32P} {
      source $CORBA_DIR/LivingstoneCorba-win32.tcl
    } else {
      source $CORBA_DIR/LivingstoneCorba.tcl
    }
    # define class POA_LivingstoneCorba::LivingstoneEngineManager
    if {$g_NM_win32P} {
      source $CORBA_DIR/LivingstoneCorba-win32_impl.tcl
    } else {
      source $CORBA_DIR/LivingstoneCorba_impl.tcl
    }

    # define Stanley responses to LivingstoneEventListener 
    class LivingstoneEventListener_impl {
      inherit ::LivingstoneCorba::LivingstoneEventListener

      public method start { }
      public method reportVariables { attributes }
      public method newState { time stateID transition assignments }
      public method viewState { time stateID transition assignments }
      public method asynchronousMsg { state msg }
      public method finish { }
      public method startReplay { }
      public method finishReplay { }
      public method gotCandidates { num }
      public method gotInstallCandidate { index }
      public method gotAssignment { monitor }
      public method gotProgress { command }
      # Stanley "slave" messages
      public method metaDot { nodeClassType instanceName dialogType modeName }
      public method getWorkSpaces {}
      public method loadWorkSpace { workspace } 
      public method getModules {}
      public method loadModule { moduleName }
      public method getInstances { nodeClassType componentInstanceName }     
    }

    source $STANLEY_ROOT/src/corba-method-bodies.tcl
    set g_NM_firstInstantiatedScopeP 0
  }

  # Initialize COMBAT using Name Server to find Livingstone server
  # eval corba::init -ORBNamingAddr inet:${HOST}:$g_NM_corbaPort 

  # Initialize external Interface Repository brfore starting Stanley
  # RUN-INTERFACE-REPOSITORY.csh

  # Initialize COMBAT for reading IOR to find Livingstone server
  # and tell it about external Interface Repository 
  # corba::init -ORBDebugLevel 10 -ORBIfaceRepoAddr inet:$g_NM_interfaceRepository
  # internal Interface Repository 
  # Error in startup script: IDL:omg.org/CORBA/DATA_CONVERSION:1.0 {minor 1398079493 completed COMPLETED_NO}
  # while running with JDk1.3, rather thAN JDK1.2.2, is corrected by specifying -ORBNoCodeSets     
  if {$g_NM_win32P} {
    eval corba::init -ORBDebugLevel 10 -ORBNoCodeSets -ORBNoResolve
  } else {
    eval corba::init -ORBDebugLevel 10 -ORBNoCodeSets 
  }

  # Feed the local interface repository with information about the Livingstone
  # interface and Name Services
  ### must be done prior to corba::string_to_object operation (connecting to server)
  # puts stderr "initializeStanleyCORBAClient: add _ir_LivingstoneCorba ${_ir_LivingstoneCorba}"
  combat::ir add ${_ir_LivingstoneCorba}
  # not used
  # combat::ir add $_ir_naming

  # Connect to the Livingstone Engine Manager ORB server
  set ior_file [open $env(HOME)/.stanley/stanleyengine.ior]

  set ior [read -nonewline $ior_file]
  close $ior_file
  set g_NM_livingstoneEMORBObject [corba::string_to_object $ior]
  puts stderr "g_NM_livingstoneEMORBObject $g_NM_livingstoneEMORBObject"

  set initialServices [corba::list_initial_services]
  puts stderr "ORBinitialServices `$initialServices'"
  # ImplementationRepository InterfaceRepository LocalImplementationRepository RootPOA POACurrent
  ### this works under MICO2.3.1, but not under MICO2.3.11 -- besides
  ### it is not needed
  # set g_NM_interfaceRepository [corba::resolve_initial_references InterfaceRepository]
  # puts stderr "g_NM_interfaceRepository $g_NM_interfaceRepository"

  # if it is needed:
  # ird -ORBIIOPAddr inet::1234
  # corba::init -ORBInitRef InterfaceRepository=corbaloc::host:1234/InterfaceRepository

  # set NameServices [corba::resolve_initial_references NameService] 
  # puts stderr "NameServices $NameServices"

  # set livingstoneEMORBObject [$NameServices resolve {{id "IDL:Livingstone:1.0" kind ""}}]
  # if [catch { $NameServices resolve {{id "Livingstone" kind ""}}} livingstoneEMORBObject] {
  #   puts stderr "\n***Failed to connect to Livingstone ORB server***\n"
  #   exit
  # }

  # start LivingstoneCommandLine object
  # starting with L2Skunk_2.7.6, this is necessary before calling getCommandLine
  #  An unexpected exception has been detected in native code outside the VM.
  #  Unexpected Signal : 11 occurred at PC=0x403c4d9f
  #  Function name=(N/A)
  #  Library=/lib/libc.so.6
  puts stderr "initializeStanleyCORBAClient: getRunningCommandLine"
  set g_NM_livingstoneCmdLineORBObject \
      [$g_NM_livingstoneEMORBObject getRunningCommandLine]

  if {! $g_NM_toolsL2ViewerP} {
    set arg1 [string toupper [preferred L2SearchMethod]]
    set arg6 [preferred L2MaxHistorySteps]
    set arg7 [preferred L2NumTrajectoriesTracked]
    set arg8 [preferred L2ProgressCmdType]
    set arg9 [preferred L2FindCandidatesCmdType]
    if {$arg1 == "CBFS"} {
      set arg2 [preferred L2MaxCBFSCandidateClasses]
      set arg3 [preferred L2MaxCBFSCandidates]
      set arg4 [preferred L2MaxCBFSSearchSpace]
      set arg5 [preferred L2MaxCBFSCutoffWeight]
      puts -nonewline stderr "initializeStanleyCORBAClient: L2SearchMethod $arg1 L2MaxCBFSCandidateClasses $arg2 L2MaxCBFSCandidates $arg3 L2MaxCBFSSearchSpace $arg4 L2MaxCBFSCutoffWeight $arg5"
    } elseif {$arg1 == "COVER"} {
      set arg2 [preferred L2MaxCoverCandidateRank]
      set arg3 100 ; # dummy
      set arg4 100 ; # dummy
      set arg5 100 ; # dummy
      puts -nonewline stderr "initializeStanleyCORBAClient: L2SearchMethod $arg1 L2MaxCoverCandidateRank $arg2"
    } else {
      error "initializeStanleyCORBAClient: L2SearchMethod $arg1 not handled"
    }
    puts stderr " L2MaxHistorySteps $arg6 L2NumTrajectoriesTracked $arg7 L2ProgressCmdType $arg8 L2FindCandidatesCmdType $arg9"
    set g_NM_livingstoneCmdLineORBObject \
        [$g_NM_livingstoneEMORBObject getCommandLine $arg1 $arg2 $arg3 $arg4 $arg5 \
         $arg6 $arg7 $arg8 $arg9]
  }

  # enable command line
  set g_NM_commandLineLockP 0
  set g_NM_freshCommandLineP 1

  # start LivingstoneEventListener object on Livingstone
  set stanleyRootPOA [corba::resolve_initial_references RootPOA]
  set stanleyPOAMgr [$stanleyRootPOA the_POAManager]
  set g_NM_livingstoneEvtListORBObject [LivingstoneEventListener_impl \#auto]
  $stanleyRootPOA activate_object $g_NM_livingstoneEvtListORBObject 
  $stanleyPOAMgr activate
  # notify Livingstone - pass LivingstoneEventListener server object
  $g_NM_livingstoneCmdLineORBObject addLivingstoneEventListener \
      [$g_NM_livingstoneEvtListORBObject _this]

  # start test trace
  #   puts stderr "initializeStanleyCORBAClient: command `loadtrace will.tra'"
  #   $g_NM_livingstoneCmdLineORBObject command "loadtrace will.tra"
}


## debugging L2Tools
## XEmacs
## M-x shell
## cd ~/l2-tools/corba
## source setenv.unix
## old % java gov.nasa.arc.l2tools.commandline.ExtensibleCommandLine
## % java gov.nasa.arc.l2tools.commandline.BshCommandLine
## prompt> loadmodel /home/serengeti/id0/taylor/stanley-projs/x-34-model-jmpl/livingstone/models/modules/cbAndLeds
## prompt> scenario initialStateScript cbAndLeds
## prompt> fc

## debugging Livingstone
## XEmacs
## M-x shell
## cd ~/mba/cpp/src/test
## ./test_debug /home/serengeti/id0/taylor/stanley-projs/x-34-model-jmpl/livingstone/models/modules/cbAndLeds cbfs 100
## Livingstone> assign test.led1.ledState=on
## Livingstone> ...

## request CORBA Livingstone server to process Livingstone cmd line args
## 03aug99 wmt: new
proc livingstoneCmdLineRequest { stringForm } {
  global g_NM_livingstoneCmdLineORBObject 
  global g_NM_commandLineLockP g_NM_currentCommandLineCommand
  global g_NM_vmplUserPropArray g_NM_scenarioDialogRoot
  global g_NM_scenarioExecLineNum g_NM_inhibitPirWarningP
  global g_NM_freshCommandLineP g_NM_asynchronousCmdReceivedP
  global g_NM_fcCommandSentP g_NM_L2FindCandidatesCmdTypeList 
  global g_NM_win32P 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "livingstoneCmdLineRequest: `$backtrace'"
  set severity 1; set msg2 ""
  set reportNotFoundP 0; set oldvalMustExistP 0
  set caller "livingstoneCmdLineRequest"
  # L2Tools will not handle run .scr files at this time
  # send individual script directives
  if {[string range $stringForm 0 3] == "run "} {
    set fid [open [string range $stringForm 4 end] r]
    while {[gets $fid cmd ] != -1} {
      if {$cmd == ""} { continue }
      if {$g_NM_commandLineLockP} {
        # discard all commands since L2/L2Tools has returned an 
        # error via CORBA msg: asynchronousMsg
        set str "livingstoneCmdLineRequest: g_NM_commandLineLockP"
        puts stderr "$str $g_NM_commandLineLockP -- `$cmd' discarded"
        close $fid
        return
      }
      # skip blank lines and comments
      if {($cmd != "") && ([string range $cmd 0 1] != "//")} {
        set g_NM_asynchronousCmdReceivedP 0
        set g_NM_inhibitPirWarningP 0
        set g_NM_fcCommandSentP 0
        if {! $g_NM_win32P} {
          .master.canvas config -cursor { watch red yellow }
        }
        set msg "Please Wait: Livingstone processing command ..."
        if {[winfo exists $g_NM_scenarioDialogRoot]} {
          scenarioMgrWarning $msg $severity
        } else {
          pirWarning $msg $msg2 $severity
        }
        set g_NM_inhibitPirWarningP 1
        update

#         if {[lsearch -exact {"fc" "prune-search" "find-fresh" "extend"} $cmd] >= 0} {
#           # reset array which handles structure type proposition values
#           # for user specified assign/progress incremental test balloons
#           catch { unset g_NM_vmplUserPropArray }
#           set g_NM_vmplUserPropArray(0) 1
#         }

        convertCmdSyntax cmd

        puts stdout "\nlivingstoneCmdLineRequest: `$cmd'"
        ## disable scenario selection and step/run accelerators
        ## until Stanley receives gotCandidates CORBA msg from L2Tools
        scenarioManagerDisable

        set g_NM_currentCommandLineCommand $cmd
        set g_NM_freshCommandLineP 0
        
        if [ catch { $g_NM_livingstoneCmdLineORBObject command $cmd } message ] {
          l2toolsRequestError $message 
          puts stderr "\nlivingstoneCmdLineRequest: CORBA ERROR => $message"
          # do not send any more cmds
          set g_NM_commandLineLockP 1
        }
        # have server print out propositions being sent to Stanley
        #         if {[regexp "scenario" $cmd]} {
        #           $g_NM_livingstoneCmdLineORBObject command "addlistener"
        #         }

        # cmd = truncate <horizon-time>
        # cmd = propagate ; generated in Charles Pecheur's
        #       livingstone Path Finer scenarios
        if {[regexp "truncate" $cmd] || \
                [regexp "propagate" $cmd]} {
          # these cmds have no CORBA return message from L2Tools
          # so move marker here
          # note: fc, find-fresh, extend cause a newState to be returned
          incr g_NM_scenarioExecLineNum
          moveScenarioExecMarker 
          scenarioManagerEnable $caller
        }
        if {! $g_NM_win32P} {
          .master.canvas config -cursor top_left_arrow
        }
        # keep attention warning up for choosing candidate after fc, find-fresh, 
        # extend or prune-search
        # and asynchronous cmd received
        if {([lsearch -exact $g_NM_L2FindCandidatesCmdTypeList $cmd] >= 0) || \
                $g_NM_asynchronousCmdReceivedP} {
          # g_NM_inhibitPirWarningP already set to 1 
        } else {
          set g_NM_inhibitPirWarningP 0
        }
        standardMouseClickMsg
      }
    }
    close $fid
  } else {
    if {$g_NM_commandLineLockP} {
      # discard all commands since L2/L2Tools has returned an
      # error via CORBA msg: asynchronousMsg
      return
    }
    # single cmd
    set cmd $stringForm 
    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
    }
    set msg "Please Wait: Livingstone processing command ..."
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      scenarioMgrWarning $msg $severity
    } else {
      pirWarning $msg $msg2 $severity
    }
    set g_NM_inhibitPirWarningP 1
    set g_NM_asynchronousCmdReceivedP 0
    update
    set g_NM_currentCommandLineCommand $cmd 

    convertCmdSyntax cmd

    puts stderr "\nlivingstoneCmdLineRequest: `$cmd'"

    $g_NM_livingstoneCmdLineORBObject command $cmd

    if {! $g_NM_win32P} {
      .master.canvas config -cursor top_left_arrow
    }
    if {! $g_NM_asynchronousCmdReceivedP} {
      set g_NM_inhibitPirWarningP 0
    }
    standardMouseClickMsg
    update;   # make sure changes are processed
  }
}


## 08aug01 wmt: new
proc convertCmdSyntax { cmdRef } {
  upvar $cmdRef cmd
  global g_NM_L2FindCandidatesCmdTypeList g_NM_fcCommandSentP 
  
  # allow user explicit min-progress & full-progress,
  # otherwise, use preference
  if {[regexp "progress" $cmd] && (! [regexp "min-progress" $cmd]) && \
          (! [regexp "full-progress" $cmd])} {
    # min-progress or full-progress depending on preference
    regsub "progress" $cmd "[preferred L2ProgressCmdType]-progress" tmp
    set cmd $tmp
  }
  # allow user explicit prune-search find-fresh & extend
  # otherwise, use preference for fc
  if {$cmd == "fc"} {
    # prune-search find-fresh or extend depending on preference
    set cmd [preferred L2FindCandidatesCmdType]
  }
  if {[lsearch -exact $g_NM_L2FindCandidatesCmdTypeList $cmd] >= 0} {
    set g_NM_fcCommandSentP 1
  }
}


## Livingstone CORBA request error
## 06oct99 wmt: new
proc l2toolsRequestError { str } {

  set refWindow [getCanvasRootInfo g_NM_currentCanvas]
  advisoryDialog $refWindow "L2Tools/Stanley CORBA Request Error" $str
  bell
}


## show the user the msg returned from Livingstone error
## if it contains an instance name, give user suggested class
## definitions to inspect
## 01jun00 wmt
proc showLivingstoneLoaderError { msg } {
  global g_NM_currentCommandLineCommand 

  set sortP 0; set tokensPerLine 3
  set str ""; set dialogStr ""; set printStr ""
  # puts stderr "showLivingstoneLoaderError: msg `$msg'"
  if {[string length [lindex $g_NM_currentCommandLineCommand 1]] > 20} {
    set tokensPerLine 2
  }
  sortAndFormatList g_NM_currentCommandLineCommand formattedCurrentCmd \
      $tokensPerLine $sortP
  if {$formattedCurrentCmd != ""} {
    set str "\nWhile processing Stanley command line request --\n"
    set dialogStr $str; set printStr $str
    append dialogStr "`$formattedCurrentCmd': \n"
    append printStr "`$g_NM_currentCommandLineCommand': \n"
  }
  append dialogStr "\"$msg\"\n"
  append printStr "\"$msg\"\n"
  set classList [getClassesFromLivingstoneLoaderError $msg]
  if {[llength $classList] > 0} {
    set subStr "Inspect these class definitions:\n"
    append printStr $subStr 
    append dialogStr "\n$subStr"
    set firstP 1
    foreach cls $classList {
      if {$firstP} {
        set subStr ""
      } else {
        set subStr "\n"
      }
      append subStr "   $cls"
      append printStr $subStr
      append dialogStr $subStr 
    }
  }
  if {[regexp "loadModelJNI" $msg]} {
    append dialogStr "\nSee L2Tools/Livingstone window for more information."
  }
  # puts stderr "   '$printStr'"
  set dialogList [list tk_dialog .d "Livingstone Error" \
                      $dialogStr error 0 {DISMISS}]
  eval $dialogList
}


## start Livingstone with CORBA to create ORB server
## 19jun00 wmt
proc startL2toolsJNIandL2  { } {
  global OSTYPE JAVA_BIN env g_NM_win32P
  global g_NM_scenarioDialogRoot g_NM_inhibitPirWarningP 
  global g_NM_JVMGcInitSpace g_NM_JVMGcMaxSpace 

  if {[winfo exists .master.canvas] & [winfo exists $g_NM_scenarioDialogRoot] } {
    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
    }
    set severity 1; set msg2 ""
    set msg "Please Wait:  -- new L2Tools/Livingstone being created"
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      scenarioMgrWarning $msg $severity
    } else {
      pirWarning $msg $msg2 $severity
    }
    set g_NM_inhibitPirWarningP 1
    update
  }

# if running, kill L2Tools Server process
#   set processName "forwill.Server"
#   while {[killProcess $processName] != -1} { }

  file delete $env(HOME)/.stanley/stanleyengine.ior
  # Java wrapped C++ Livingstone 
  set pwd [pwd]
  pushd $env(HOME)/.stanley

  if {($OSTYPE == "solaris") || ($OSTYPE == "linux") || \
      $g_NM_win32P} {
    set arg1 [string toupper [preferred L2SearchMethod]]
    set arg6 [preferred L2MaxHistorySteps]
    set arg7 [preferred L2NumTrajectoriesTracked]
    set arg8 [preferred L2ProgressCmdType]
    set arg9 [preferred L2FindCandidatesCmdType]
    if {$arg1 == "CBFS"} {
      set arg2 [preferred L2MaxCBFSCandidateClasses]
      set arg3 [preferred L2MaxCBFSCandidates]
      set arg4 [preferred L2MaxCBFSSearchSpace]
      set arg5 [preferred L2MaxCBFSCutoffWeight]  
    # puts stderr "startL2toolsJNIandL2: L2SearchMethod $arg1 L2MaxCBFSCandidateClasses $arg2 L2MaxCBFSCandidates $arg3 L2MaxCBFSSearchSpace $arg4 L2MaxHistorySteps $arg5"
    } elseif {$arg1 == "COVER"} {
      set arg2 [preferred L2MaxCoverCandidateRank]
      set arg3 100 ; # dummy
      set arg4 100 ; # dummy
      set arg5 100 ; # dummy
    # puts stderr "startL2toolsJNIandL2: L2SearchMethod $arg1 L2MaxCoverCandidateRank $arg2 L2MaxHistorySteps $arg6"
    } else {
      error "startL2toolsJNIandL2: L2SearchMethod $arg1 not handled"
    }
    # -verbose:gc show user what GC is doing
    # -Xms -- initial GC space => 30mb (JVM default 2mb)
    # -Xmx -- max GC space => 192mb    (JVM default 64mb)
    # java.lang.OutOfMemoryError thrown if max GC space exceeded
    if {$OSTYPE == "linux"} {
      exec xterm -sb -sl 10000 -bg "Bisque" -fg "Black" -hold \
          -T "L2Tools/Livingstone" -n "L2TOOLS/LIVINGSTONE" \
          -geometry 80x40+250+0 -rightbar \
          -e $JAVA_BIN/java -verbose:gc -Xms${g_NM_JVMGcInitSpace}m -Xmx${g_NM_JVMGcMaxSpace}m forwill.Server $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 &

#      exec $JAVA_BIN/java -verbose:gc -Xms${g_NM_JVMGcInitSpace}m -Xmx${g_NM_JVMGcMaxSpace}m forwill.Server $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 & 
    } else {
      # Solaris X11R5 does not support -rightbar
      exec xterm -sb -sl 10000 -bg "Bisque" -fg "Black" -hold \
          -T "L2Tools/Livingstone" -n "L2TOOLS/LIVINGSTONE" \
          -geometry 80x40+250+0 \
          -e $JAVA_BIN/java -verbose:gc -Xms${g_NM_JVMGcInitSpace}m -Xmx${g_NM_JVMGcMaxSpace}m forwill.Server $arg1 $arg2 $arg3 $arg4 $arg5 $arg6 $arg7 $arg8 $arg9 & 
    }
  } else {
    error "startL2toolsJNIandL2: OSTYPE $OSTYPE not handled"
  }
  popd

  # Livingstone ORB server will write this file to be read by  Stanley client ORB
  waitForFileToBeWritten $env(HOME)/.stanley/stanleyengine.ior

  if {[winfo exists .master.canvas]} {
    set g_NM_inhibitPirWarningP 0
    standardMouseClickMsg
    if {! $g_NM_win32P} {
      .master.canvas config -cursor top_left_arrow
      update
    }
  }
}


## reset Livingstone Engine without killing L2Tools/Livingstone
## 23jun00 wmt
proc resetL2toolsJNIandL2 { } {
  global g_NM_livingstoneCmdLineORBObject g_NM_livingstoneEvtListORBObject
  global g_NM_scenarioDialogRoot g_NM_inhibitPirWarningP
  global g_NM_livingstoneEMORBObject g_NM_win32P
  global g_NM_commandLineLockP g_NM_freshCommandLineP 

  if {! $g_NM_win32P} {
    .master.canvas config -cursor { watch red yellow }
  }
  set severity 1; set msg2 ""
  set msg "Please Wait:  -- fresh Livingstone objects being created"
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    scenarioMgrWarning $msg $severity
  } else {
    pirWarning $msg $msg2 $severity
  }
  set g_NM_inhibitPirWarningP 1
  update

#   # release Livingstone event listener object
#   # release Livingstone command line object
#   puts stderr "\nRelease current Livingstone Event Listener and Command Line objects"
#   puts stderr "Create new objects ..."
#   $g_NM_livingstoneCmdLineORBObject removeLivingstoneEventListener \
#       [$g_NM_livingstoneEvtListORBObject _this]
#   $g_NM_livingstoneCmdLineORBObject release

#   # create new event listener, and command line 
#   # Test-> Scope will do that
#   initializeStanleyCORBAClient 



  # start LivingstoneCommandLine object 
  set arg1 [string toupper [preferred L2SearchMethod]]
  set arg6 [preferred L2MaxHistorySteps]
  set arg7 [preferred L2NumTrajectoriesTracked]
  set arg8 [preferred L2ProgressCmdType]
  set arg9 [preferred L2FindCandidatesCmdType]
  if {$arg1 == "CBFS"} {
    set arg2 [preferred L2MaxCBFSCandidateClasses]
    set arg3 [preferred L2MaxCBFSCandidates]
    set arg4 [preferred L2MaxCBFSSearchSpace]
    set arg5 [preferred L2MaxCBFSCutoffWeight]
    puts -nonewline stderr "resetL2toolsJNIandL2: L2SearchMethod $arg1 L2MaxCBFSCandidateClasses $arg2 L2MaxCBFSCandidates $arg3 L2MaxCBFSSearchSpace $arg4 L2MaxCBFSCutoffWeight $arg5"
  } elseif {$arg1 == "COVER"} {
    set arg2 [preferred L2MaxCoverCandidateRank]
    set arg3 100 ; # dummy
    set arg4 100 ; # dummy
    set arg5 100 ; # dummy
    puts -nonewline stderr "resetL2toolsJNIandL2: L2SearchMethod $arg1 L2MaxCoverCandidateRank $arg2"
  } else {
    error "resetL2toolsJNIandL2: L2SearchMethod $arg1 not handled"
  }
  puts stderr " L2MaxHistorySteps $arg6 L2NumTrajectoriesTracked $arg7 L2ProgressCmdType $arg8 L2FindCandidatesCmdType $arg9"
  # puts stderr "initializeStanleyCORBAClient: g_NM_livingstoneEMORBObject $g_NM_livingstoneEMORBObject"

  set g_NM_livingstoneCmdLineORBObject \
      [$g_NM_livingstoneEMORBObject getCommandLine $arg1 $arg2 $arg3 $arg4 $arg5 \
           $arg6 $arg7 $arg8 $arg9]
  # enable command line
  set g_NM_commandLineLockP 0
  set g_NM_freshCommandLineP 1

#   # start LivingstoneEventListener object on Livingstone
#   set stanleyRootPOA [corba::resolve_initial_references RootPOA]
#   set stanleyPOAMgr [$stanleyRootPOA the_POAManager]
#   set g_NM_livingstoneEvtListORBObject [LivingstoneEventListener_impl \#auto]
#   $stanleyRootPOA activate_object $g_NM_livingstoneEvtListORBObject 
#   $stanleyPOAMgr activate

  # notify Livingstone - pass LivingstoneEventListener server object
  $g_NM_livingstoneCmdLineORBObject addLivingstoneEventListener \
      [$g_NM_livingstoneEvtListORBObject _this]

  puts stderr "... Done."
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
  }
  set g_NM_inhibitPirWarningP 0
  standardMouseClickMsg
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
    update
  }
}


## initialize Stanley as CORBA client of GPU: host and port
## 05jun01 wmt: new
proc initStanleyAsGPUClient { } {
  global CORBA_DIR TCL_MICO_LIB 
  global g_NM_firstInstantiatedScopeP 
  global _ir_LivingstoneCorba STANLEY_ROOT env
  global g_NM_livingstoneEMORBObject g_NM_livingstoneCmdLineORBObject
  global g_NM_livingstoneEvtListORBObject 
  global g_NM_commandLineLockP g_NM_freshCommandLineP 

  if {$g_NM_firstInstantiatedScopeP} {
    # load IDL definition of Livingstone interface
    ### only needed by a local Interface Repository
    ### we are now using an external Interface Repository 
    # This file is generated from livingstone-corba.idl
    # by idl2tcl.
    if {! [file exists $CORBA_DIR/LivingstoneCorba.tcl]} {
      pushd $CORBA_DIR
      exec $TCL_MICO_LIB/../bin/idl2tcl --impl LivingstoneCorba.idl 
      popd

      waitForFileToBeWritten $CORBA_DIR/LivingstoneCorba.tcl 
    }

    puts stderr "\nSourcing $CORBA_DIR/LivingstoneCorba.tcl & LivingstoneCorba_impl.tcl\n"
    # define local interface repository: _ir_LivingstoneCorba 
    if {$g_NM_win32P} {
      source $CORBA_DIR/LivingstoneCorba-win32.tcl
    } else {
      source $CORBA_DIR/LivingstoneCorba.tcl
    }
    # define class POA_LivingstoneCorba::LivingstoneEngineManager
    if {$g_NM_win32P} {
      source $CORBA_DIR/LivingstoneCorba-win32_impl.tcl
    } else {
      source $CORBA_DIR/LivingstoneCorba_impl.tcl
    }

    # define Stanley responses to LivingstoneEventListener 
    class LivingstoneEventListener_impl {
      inherit ::LivingstoneCorba::LivingstoneEventListener

      # newState is actually the only method needed for the GPU
      # but corba-method-bodies.tcl references all of these
      public method start { }
      public method reportVariables { attributes }
      public method newState { time stateID transition assignments }
      public method viewState { time stateID transition assignments }
      public method asynchronousMsg { state msg }
      public method finish { }
      public method startReplay { }
      public method finishReplay { }
      public method gotCandidates { num }
      public method gotInstallCandidate { index }
      public method gotAssignment { monitor }
      public method gotProgress { command }
      # Stanley "slave" messages
      public method metaDot { nodeClassType instanceName dialogType modeName }
      public method getWorkSpaces {}
      public method loadWorkSpace { workspace } 
      public method getModules {}
      public method loadModule { moduleName }
      public method getInstances { nodeClassType componentInstanceName }     
    }

    source $STANLEY_ROOT/src/corba-method-bodies.tcl
    set g_NM_firstInstantiatedScopeP 0
  }

  corba::init -ORBDebugLevel 10 -ORBNoCodeSets 

  # Feed the local interface repository with information about the Livingstone
  # interface and Name Services
  combat::ir add ${_ir_LivingstoneCorba}

  # Connect to the Livingstone Engine Manager ORB server
  set ior_file [open $env(HOME)/.stanley/gpu.ior]

  set ior [read -nonewline $ior_file]
  close $ior_file
  set g_NM_livingstoneEMORBObject [corba::string_to_object $ior]
  # puts stderr "g_NM_livingstoneEMORBObject $g_NM_livingstoneEMORBObject"


  set initialServices [corba::list_initial_services]
  puts stderr "ORBinitialServices `$initialServices'"
  # ImplementationRepository InterfaceRepository LocalImplementationRepository RootPOA POACurrent
  ### this works under MICO2.3.1, but not under MICO2.3.11 -- besides
  ### it is not needed
  # set g_NM_interfaceRepository [corba::resolve_initial_references InterfaceRepository]
  # puts stderr "g_NM_interfaceRepository $g_NM_interfaceRepository"

  puts stderr "initStanleyAsGPUClient: getRunningCommandLine"
  set g_NM_livingstoneCmdLineORBObject \
      [$g_NM_livingstoneEMORBObject getRunningCommandLine]
  puts stderr "g_NM_livingstoneCmdLineORBObject $g_NM_livingstoneCmdLineORBObject"
  # enable command line
  set g_NM_commandLineLockP 0
  set g_NM_freshCommandLineP 1

  # start LivingstoneEventListener object on Livingstone
  set stanleyRootPOA [corba::resolve_initial_references RootPOA]
  set stanleyPOAMgr [$stanleyRootPOA the_POAManager]
  set g_NM_livingstoneEvtListORBObject [LivingstoneEventListener_impl \#auto]
  $stanleyRootPOA activate_object $g_NM_livingstoneEvtListORBObject 
  $stanleyPOAMgr activate
  # notify Livingstone - pass LivingstoneEventListener server object
  $g_NM_livingstoneCmdLineORBObject addLivingstoneEventListener \
      [$g_NM_livingstoneEvtListORBObject _this]
}






