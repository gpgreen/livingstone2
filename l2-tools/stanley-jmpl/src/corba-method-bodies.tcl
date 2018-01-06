# $Id: corba-method-bodies.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## corba-method-bodies.tcl => handle CORBA client/server transactions
## methods are defined in corba.tcl - initializeStanleyCORBAClient

## 07apr00wmt: new
## do nothing - just catch the message
body LivingstoneEventListener_impl::start { } {

  puts stderr "LivingstoneEventListener_impl::start"

}

      
## 07apr00wmt: new
## initial report of all variables, their ranges, and initial values
## { {LivingstoneAttributeReport attributes} } 
body LivingstoneEventListener_impl::reportVariables { attributes } {
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope pirNodes 

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::reportVariables"
    return
  }
  # puts stderr "\nLivingstoneEventListener_impl::reportVariables: attributes $attributes"
  puts stderr "\nLivingstoneEventListener_impl::reportVariables:"
  set attributeList [lindex $attributes 1]
  puts stderr "   numAttributes [llength $attributeList]"
  # all initialValue values are <Unassigned>
#   foreach attForm $attributeList {
#     puts stderr "name: [assoc name attForm] initialValue: [assoc initialValue attForm]"
#   }
}


## 07apr00wmt: new
## report on a transition and all propositional values at time point
## { {float time} {long stateID} {string transition} {LivingstoneAssignmentReport assignments} } 
body LivingstoneEventListener_impl::newState { time stateID transition assignments } {
  global g_NM_commandLineLockP g_NM_livingstoneNowTime
  global g_NM_scenarioDialogRoot g_NM_inhibitPirWarningP
  global g_NM_toolsL2ViewerP pirNodes g_NM_currentCommandLineCommand 
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope 
  global g_NM_win32P

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::newState"
    return
  }
  if {$g_NM_commandLineLockP} {
    # discard all assigmnents since L2/L2Tools has returned an
    # error via CORBA msg: asynchronousMsg
    puts stderr "newState: g_NM_commandLineLockP $g_NM_commandLineLockP -- assignments discarded"
    return
  }
  set caller "newState"
  # current L2/L2Tools cmd is complete
  set g_NM_currentCommandLineCommand ""
  # erase current warning
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
  }
  standardMouseClickMsg
  update;   # make sure changes are processed
  # display new warning
  if {! $g_NM_win32P} {
    .master.canvas config -cursor { watch red yellow }
  }
  set severity 1; set msg2 ""
  set g_NM_inhibitPirWarningP 0
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    ## scenario selection and step/run buttons are disabled
    ## while processing newState
    scenarioManagerDisable
  }
  set msg  "Please Wait: Livingstone propositions being processed by Stanley ..."
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    scenarioMgrWarning $msg $severity
  } else {
    pirWarning $msg $msg2 $severity
  }
  set g_NM_inhibitPirWarningP 1
  update
  puts stderr "\nLivingstoneEventListener_impl::newState: time $time stateID $stateID"
  # puts stderr "    transition $transition numAssignments [llength [lindex $assignments 1]]"
  # puts stderr "    assignments $assignments"

  handleNewStateAndViewState $stateID $time $transition assignments $caller

  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    ## scenario selection and step/run buttons are disabled
    ## while processing newState
    scenarioManagerEnable $caller
  }
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
  }
  set g_NM_inhibitPirWarningP 0
  standardMouseClickMsg
  update;   # make sure changes are processed
}


## handle newState and viewState msgs
## 09may00 wmt
proc handleNewStateAndViewState { stateID time transition assignmentsRef caller } {
  upvar $assignmentsRef assignments 
  global g_NM_l2toolsCurrentTime g_NM_livingstoneNowTime 
  global g_NM_stanleyCurrentTime 

  set canvasRootId 0
  set previousLivingstoneNowTime $g_NM_livingstoneNowTime 
  # gotProgress does the incrementing of g_NM_livingstoneNowTime 
  set previousL2toolsCurrentTime $g_NM_l2toolsCurrentTime
  set previousStanleyCurrentTime $g_NM_stanleyCurrentTime
  set g_NM_l2toolsCurrentTime $stateID
  if {! [string match $g_NM_l2toolsCurrentTime $g_NM_stanleyCurrentTime]} {
    set g_NM_stanleyCurrentTime $g_NM_l2toolsCurrentTime 
  }
  if {$g_NM_l2toolsCurrentTime > $g_NM_livingstoneNowTime} {
    set g_NM_livingstoneNowTime $g_NM_l2toolsCurrentTime
  }

  set g_NM_stanleyCurrentTime $g_NM_l2toolsCurrentTime 
  set str "handleNewStateAndViewState: previousL2toolsCurrentTime"
  set str "$str $previousL2toolsCurrentTime g_NM_l2toolsCurrentTime"
  puts stderr "$str $g_NM_l2toolsCurrentTime"
  set str "   previousStanleyCurrentTime $previousStanleyCurrentTime"
  puts stderr "$str g_NM_stanleyCurrentTime $g_NM_stanleyCurrentTime"

  # update legend with timestamp
  displayDotWindowTitle $canvasRootId 
  if {$transition != ""} {
    set pair [split $transition "="]
    set attribute [lindex $pair 0]
    set value [lindex $pair 1]
    # puts stderr "   transition: attribute $attribute value $value"
  }
  catch { unset propAttrValList }
  set propAttrValList {}; set attrCnt 0
  lappend propAttrValList [list timeTag $stateID $time]
  if {$transition != ""} {
    lappend propAttrValList [list attrVal $attribute $value]
    incr attrCnt 
  }
  set assignmentList [lindex $assignments 1]
  foreach attForm $assignmentList {
    # puts stderr "name: [assoc name attForm] value: [assoc value attForm]"
    set attribute [assoc name attForm]
    set value [assoc value attForm]
    # change <Unassigned> values to unknown -- this happens only with
    # newState send in response to refresh
    if {$value == "<Unassigned>"} {
      set value "unknown"
    }
    lappend propAttrValList [list attrVal $attribute $value]
    incr attrCnt 
  }

  # test - add to Test->Instance 
#    lappend propAttrValList [list attrVal test.cb1.mode tripped]
#    lappend propAttrValList [list attrVal test.cb1.displayState failed]
  # invoke this from tkCon
  #   set propAttrValList {}
  #   lappend propAttrValList [list attrVal test.cb1.displayState nominal]
  #   lappend propAttrValList [list attrVal test.cb1.mode on]
  #   parseMPLPropAttrValList propAttrValList "newState"
  puts stderr "   numAssignments $attrCnt"
  # do not crash Livingstone with an error during parseMPLPropAttrValList call
  if [ catch { parseMPLPropAttrValList propAttrValList $caller } ] {
    set str "\nLivingstoneEventListener_impl::$caller =>"
    puts stderr "$str error in parseMPLPropAttrValList"
  }

  # show user the values of the commands and monitors
  # as received from Livingstone
  # do not crash Livingstone with an error during showCommandMonitorTerminalBalloons call
  if {[preferred StanleyTestPermanentBalloons] == "on"} {
    if [ catch { showCommandMonitorTerminalBalloons "current" $caller } ] {
      set str "\nLivingstoneEventListener_impl::$caller =>"
      puts stderr "$str error in showCommandMonitorTerminalBalloons"
    }
  }
}

## put Stanley into a previous state -- update schematic, but not the
## proposition histories and state viewers
## 07apr00wmt: new
## { {float time} {long stateID} {string transition} {LivingstoneAssignmentReport assignments} } 
body LivingstoneEventListener_impl::viewState { time stateID transition assignments } {
  global g_NM_scenarioDialogRoot g_NM_inhibitPirWarningP 
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global pirNodes g_NM_currentCommandLineCommand g_NM_win32P

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") || \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::viewState"
    return
  }
  set caller "viewState"
  # current L2/L2tools cmd is complete
  set g_NM_currentCommandLineCommand ""
  if {! $g_NM_win32P} {
    .master.canvas config -cursor { watch red yellow }
  }
  set severity 1; set msg2 ""
  set g_NM_inhibitPirWarningP 0
  set msg "Please Wait: Livingstone propositions being processed by Stanley ..."
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    scenarioMgrWarning $msg $severity
  } else {
    pirWarning $msg $msg2 $severity
  }
  set g_NM_inhibitPirWarningP 1
  update
  puts stderr "\nLivingstoneEventListener_impl::viewState: time $time stateID $stateID"
  # puts stderr "    transition $transition numAssignments [llength [lindex $assignments 1]]"

  handleNewStateAndViewState $stateID $time $transition assignments $caller

  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
  }
  set g_NM_inhibitPirWarningP 0
  standardMouseClickMsg
  update;   # make sure changes are processed
}


## grab L2/L2tools error msg and lock command line
## 07apr00wmt: new
## { {short state} {string msg} } 
body LivingstoneEventListener_impl::asynchronousMsg { state msg } {
  global g_NM_commandLineLockP g_NM_menuStem g_NM_scenarioDialogRoot
  global g_NM_inhibitPirWarningP pirNodes g_NM_toolsL2ViewerP 
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_asynchronousCmdReceivedP 

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::asynchronousMsg"
    return
  }
  set severity 1; set msg2 ""
  set menuRoot .master.$g_NM_menuStem
  if {$msg == ""} {
    puts stderr "Discarded null asynchronousMsg"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::asynchronousMsg: state $state msg \"$msg\""

  if {[string range $msg 0 9] == "advisory: "} {
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      set g_NM_inhibitPirWarningP 0
      scenarioMgrWarning [string range $msg 10 end] $severity
      set g_NM_inhibitPirWarningP 1
      set g_NM_asynchronousCmdReceivedP 1
    } else {
      set refWindow [getCanvasRootInfo g_NM_currentCanvas]
      # use a more informative msg
      advisoryDialog $refWindow "Livingstone/L2Tools Advisory" \
          [string range $msg 10 end] 
      set g_NM_inhibitPirWarningP 0
      standardMouseClickMsg
    }
    update;   # make sure changes are processed
  } else {
    if {! $g_NM_toolsL2ViewerP} {
      # Stanley is in control, if $g_NM_toolsL2ViewerP = 0
      set g_NM_commandLineLockP 1
    }
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      # disable Scenario Manager, so user must use reset 
      # to get fresh L2Tools command line and new Scenario Manager 
      $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
          "Open Scenario" -state disabled
      $g_NM_scenarioDialogRoot.text&button.b.single config -state disabled 
      $g_NM_scenarioDialogRoot.text&button.b.step config -state disabled 
      $g_NM_scenarioDialogRoot.text&button.b.run config -state disabled 
      $g_NM_scenarioDialogRoot.text&button.b.warp config -state disabled 
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state normal
      set severity 1; set warnMsg2 ""
      set warnMsg "Livingstone/Skunworks error has disabled the engine; click RESET"
      set g_NM_inhibitPirWarningP 0
      scenarioMgrWarning $warnMsg $severity
      set g_NM_inhibitPirWarningP 1
    }
    if {$g_NM_toolsL2ViewerP} {
      set strMsg "asynchronousMsg: "
      append strMsg $msg 
      if [ catch { l2toolsRequestError $strMsg } ] {
        set str "\nLivingstoneEventListener_impl::asynchronousMsg =>"
        puts stderr "$str error in l2toolsRequestError"
      }
    } else {
      if [ catch { showLivingstoneLoaderError $msg } ] {
        set str "\nLivingstoneEventListener_impl::asynchronousMsg =>"
        puts stderr "$str error in showLivingstoneLoaderError"
      }
    }
  }
}


## 13apr00 wmt: new
## do nothing - just catch the message
body LivingstoneEventListener_impl::finish { } {

  puts stderr "\nLivingstoneEventListener_impl::finish"

}


## 13apr00 wmt: new
## do nothing - just catch the message
body LivingstoneEventListener_impl::startReplay { } {

  puts stderr "\nLivingstoneEventListener_impl::startReplay"

}


## 13apr00 wmt: new
## do nothing - just catch the message
body LivingstoneEventListener_impl::finishReplay { } {

  puts stderr "\nLivingstoneEventListener_impl::finishReplay"

}


## Candidate Mgr now has a new set of candiates as a result
## of processing an find candidates cmd
## and advance green line in scenario text
## 31jul00 wmt: new
body LivingstoneEventListener_impl::gotCandidates { numCandidates } {
  global g_NM_scenarioExecLineNum g_NM_inhibitPirWarningP
  global g_NM_scenarioDialogRoot pirNodes g_NM_fcCommandSentP
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_currentCommandLineCommand g_NM_win32P

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0) || \
          (! $g_NM_fcCommandSentP)} {
    puts stderr "Discarded LivingstoneEventListener_impl::gotCandidates"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::gotCandidates num $numCandidates"
  set caller "gotCandidates"
  # current L2/L2Tools cmd is complete
  set g_NM_currentCommandLineCommand ""
  if {$numCandidates == 0} {
    # numCandidates = 0 means the fc found no candidates
    # clear attn msg
    set g_NM_inhibitPirWarningP 0
    standardMouseClickMsg
    set refWindow [getCanvasRootInfo g_NM_currentCanvas]
    set msg "[string toupper [preferred L2SearchMethod]]: no candidates can be found.\n"
    append msg "See Candidate Manager\n for more information."
    advisoryDialog $refWindow "Livingstone Advisory" $msg
  } elseif {$numCandidates == 1} {
    # l2tools automatically installs a single candidate
    # clear attn msg
#     set g_NM_inhibitPirWarningP 0
#     standardMouseClickMsg
    # do not clear attn msg, since delay for l2tools to process values
    # for newState msg will result in no attn msg, and user may select
    # step/run/etc while the previous newState msg is being constructed
  } else {
    # more than one candidate -- user is requested to choose one
    # do not set watch cursor, since may be to select items if
    # choose not to install a candidate
    # .master.canvas config -cursor { watch red yellow }
    set severity 1; set msg2 ""
    set msg "Select candidate from Candidate Mgr, or select Single/Step/Run buttons"
    set g_NM_inhibitPirWarningP 0
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      scenarioMgrWarning $msg $severity
    } else {
      pirWarning $msg $msg2 $severity
    }
    set g_NM_inhibitPirWarningP 1
  }
  update
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    ## scenario selection and step/run buttons are disabled
    ## bewteen fc and gotCandidates
    scenarioManagerEnable $caller

    incr g_NM_scenarioExecLineNum 
    if [ catch { moveScenarioExecMarker } ] {
      set str "\nLivingstoneEventListener_impl::gotCandidates =>" 
      puts stderr "$str error in moveScenarioExecMarker"
    }
  }
}


## User selected a candidate from the Candidate Mgr, so L2Tools is
## installing it in L2, and then sending the current propositions
## via newState ==>> turn off the Attn msg
## 31jul00 wmt: new
body LivingstoneEventListener_impl::gotInstallCandidate { index } {
  global g_NM_scenarioDialogRoot 

  puts stderr "\nLivingstoneEventListener_impl::gotInstallCandidate index $index"

  # nothing to do at this time
}


## L2Tools has received an assign directive
## modify the test value balloon and advance green line in scenario text
## 31jul00 wmt: new
body LivingstoneEventListener_impl::gotAssignment { monitorList } {
  global g_NM_firstCmdReceivedP g_NM_scenarioExecLineNum 
  global g_NM_commandMonitorConstraints pirNodes 
  global g_NM_stanleyCurrentTime g_NM_livingstoneNowTime 
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_scenarioDialogRoot g_NM_scenarioSteppingMode
  global g_NM_currentCommandLineCommand 

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::gotAssignment"
    return
  }
  set reportNotFoundP 0; set oldvalMustExistP 0
  set caller "gotAssignment"
  # current L2/L2Tools cmd is complete
  set g_NM_currentCommandLineCommand ""
  puts stdout "LivingstoneEventListener_impl::gotAssignment `$monitorList'"

  if {! $g_NM_firstCmdReceivedP} {
    # upon receipt of first cmd of a sceanrio step
    # delete test values balloons whose values are predicted by L2
    ## deleteL2TestValueBalloons
    set g_NM_firstCmdReceivedP 1
  }
  # regardless of g_NM_stanleyCurrentTime, constraints always go into 
  # g_NM_livingstoneNowTime

  set cmdMonConstraintList [assoc-array $g_NM_livingstoneNowTime \
                                g_NM_commandMonitorConstraints]
  # set str "gotAssignment: g_NM_livingstoneNowTime $g_NM_livingstoneNowTime \n"
  # puts stderr "$str    cmdMonConstraintList $cmdMonConstraintList"

  foreach monitor $monitorList {
    set constraintList [split $monitor "="]
    if {! ([lindex $constraintList 1] == "unknown")} {
      if {$cmdMonConstraintList == ""} {
        set cmdMonConstraintList [list [lindex $constraintList 0] \
                                      [lindex $constraintList 1]]
      } else {
        arepl [lindex $constraintList 0] [lindex $constraintList 1] \
            cmdMonConstraintList $reportNotFoundP $oldvalMustExistP
      }
    } else {
      # value of unknown causes L2Tools to call "unassign variable"
      # so that variable will become inferred by L2 --
      # so remove it from the constraint list
      adel [lindex $constraintList 0] cmdMonConstraintList $reportNotFoundP 
    }
  }
  set g_NM_commandMonitorConstraints($g_NM_livingstoneNowTime) \
      $cmdMonConstraintList

  # puts stderr "gotAssignment: g_NM_livingstoneNowTime $g_NM_livingstoneNowTime g_NM_stanleyCurrentTime $g_NM_stanleyCurrentTime cmdMonConstraintList $cmdMonConstraintList "
  # only display balloon if Stanley in same time slice as L2
  if {($g_NM_stanleyCurrentTime == $g_NM_livingstoneNowTime) && \
          ([preferred StanleyTestPermanentBalloons] == "on")} {
    foreach monitor $monitorList {
      if [ catch { displayUserTestValueBalloon $monitor } ] {
        set str "\nLivingstoneEventListener_impl::gotAssignment =>"
        puts stderr "$str error in displayUserTestValueBalloon $monitor"
      }
    }
  }
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    if {$g_NM_scenarioSteppingMode == "single"} {
      ## disable scenario selection and step/run buttons
      ## bewteen assign cmd and gotAssignment
      scenarioManagerEnable $caller
    }

    incr g_NM_scenarioExecLineNum 
    if [ catch { moveScenarioExecMarker } ] {
      set str "\nLivingstoneEventListener_impl::gotAssignment =>"
      puts stderr "$str error in moveScenarioExecMarker "
    }
  }
}


## L2Tools has received a progress directive
## modify the test value balloon and advance green line in scenario text
## 31jul00 wmt: new
body LivingstoneEventListener_impl::gotProgress { command } {
  global g_NM_firstCmdReceivedP g_NM_scenarioDialogRoot 
  global g_NM_scenarioExecLineNum g_NM_commandMonitorConstraints
  global g_NM_stanleyCurrentTime g_NM_l2toolsCurrentTime
  global g_NM_livingstoneNowTime pirNodes g_NM_scenarioSteppingMode
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_currentCommandLineCommand 

  # accept for both Viewer mode and Edit/Test mode
  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "") || \
          ([llength $pirNodes] == 0)} {
    puts stderr "Discarded LivingstoneEventListener_impl::gotProgress"
    return
  }
  set reportNotFoundP 0; set oldvalMustExistP 0
  set caller "gotProgress"
  # current L2/L2Tools cmd is complete
  set g_NM_currentCommandLineCommand ""
  puts stdout "LivingstoneEventListener_impl::gotProgress `$command'"
  if {! $g_NM_firstCmdReceivedP} {
    # upon receipt of first cmd of a sceanrio step
    # delete test values balloons whose values are predicted by L2
    ## deleteL2TestValueBalloons
    set g_NM_firstCmdReceivedP 1
  }

  set cmdMonConstraintList [assoc-array $g_NM_livingstoneNowTime \
                                g_NM_commandMonitorConstraints]
  # check for idle transition (no var=val)
  if {$command != ""} {
    # puts stderr "gotProgress: B g_NM_livingstoneNowTime $g_NM_livingstoneNowTime g_NM_stanleyCurrentTime $g_NM_stanleyCurrentTime g_NM_l2toolsCurrentTime $g_NM_l2toolsCurrentTime"
    set constraintList [split $command "="]
    # regardless of g_NM_stanleyCurrentTime, constraints always go into
    # g_NM_livingstoneNowTime 
    # this is the now time 
    # set str "gotProgress: B g_NM_livingstoneNowTime $g_NM_livingstoneNowTime"
    # puts stderr "$str cmdMonConstraintList [array names g_NM_commandMonitorConstraints]"
    # puts stderr "   cmdMonConstraintList $cmdMonConstraintList"
    if {$cmdMonConstraintList == ""} {
      set cmdMonConstraintList [list [lindex $constraintList 0] \
                                    [lindex $constraintList 1]]
    } else {
      arepl [lindex $constraintList 0] [lindex $constraintList 1] \
          cmdMonConstraintList $reportNotFoundP $oldvalMustExistP
    }
    set g_NM_commandMonitorConstraints($g_NM_livingstoneNowTime) \
        $cmdMonConstraintList 
  }

  # increment the L2 time count - move now settings to next time tick
  incr g_NM_livingstoneNowTime
  if {$g_NM_stanleyCurrentTime == ($g_NM_livingstoneNowTime - 1)} {
    set g_NM_stanleyCurrentTime $g_NM_livingstoneNowTime
  }
  # set str "gotProgress: A g_NM_livingstoneNowTime $g_NM_livingstoneNowTime \n"
  # puts stderr "$str    cmdMonConstraintList $cmdMonConstraintList"
  set g_NM_commandMonitorConstraints($g_NM_livingstoneNowTime) \
      $cmdMonConstraintList

  # puts stderr "gotProgress: A g_NM_livingstoneNowTime $g_NM_livingstoneNowTime g_NM_stanleyCurrentTime $g_NM_stanleyCurrentTime g_NM_l2toolsCurrentTime $g_NM_l2toolsCurrentTime"
  # only display balloon if g_NM_stanleyCurrentTime = g_NM_livingstoneNowTime 
  if {($command != "") && \
          ([preferred StanleyTestPermanentBalloons] == "on") && \
          ($g_NM_stanleyCurrentTime == $g_NM_livingstoneNowTime)} {
    if [ catch { displayUserTestValueBalloon $command } ] {
      set str "\nLivingstoneEventListener_impl::gotProgress =>"
      puts stderr "$str error in displayUserTestValueBalloon $command"
    }
  }

  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    if {$g_NM_scenarioSteppingMode == "single"} {
      ## disable scenario selection and step/run buttons
      ## bewteen progress cmd and gotProgress
      scenarioManagerEnable $caller
    }
    
    incr g_NM_scenarioExecLineNum 
    if [ catch { moveScenarioExecMarker } ] {
      set str "\nLivingstoneEventListener_impl::gotProgress =>"
      puts stderr "$str error in moveScenarioExecMarker"
    }
  }
}




## Livingstone invoking Stanley server

## unit test
##   l2tools xterm
##     cd l2-tools/stanley-jmpl/interface
##     ./l2tools
##     newEngine CBFS 5 3500 100 3 5 min prune-search
##     newEngine COVER 8 100 100 3 5 min prune-search
##     loadModel /home/wtaylor/.stanley/cbAndLeds
##     loadModel /home/wtaylor/stanley-projs/x-34-sweet/livingstone/models/modules/mainPropulsionSystem
##     loadModel /home/wtaylor/stanley-projs/x-37-poll/livingstone/models/modules/x37V1p6
##
##     stanleyViewer getWorkspaces
##     stanleyViewer loadWorkspace /home/wtaylor/L2Root/l2-tools/stanley-sample-user-files
##     stanleyViewer loadWorkspace /home/wtaylor/stanley-projs/x-37-poll
##     stanleyViewer getModules
##     stanleyViewer loadModule cbAndLeds
##     stanleyViewer getInstances terminal 
##     stanleyViewer getInstances attribute
##     stanleyViewer getInstances module 
##     stanleyViewer getInstances component 
##     stanleyViewer getInstances mode test.cb1
##     stanleyViewer metaDot terminal test.cb1.currentIn 
##     stanleyViewer metaDot attribute test.cb11.displayState 
##     stanleyViewer metaDot module test nameArgsDoc 
##     stanleyViewer metaDot module test displayAttribute 
##     stanleyViewer metaDot module test facts 
##     stanleyViewer metaDot component test.cb1 nameArgsDoc 
##     stanleyViewer metaDot component test.cb1 displayAttribute 
##     stanleyViewer metaDot component test.cb1 backgroundModel 
##     stanleyViewer metaDot component test.cb1 initialConditions 
##     stanleyViewer metaDot component test.cb1 mode off
##     stanleyViewer metaDot component test.cb1 transitions off

##   stanley xterm
##     ./stanley -exists -viewer


##     
## metaDot - Livingstone call-up on Stanley schematic info
## call-up the schematic level for the node, and the appropriate dialog
## <terminalDialog> [metaDot terminal $instanceName]
## [metaDot terminal test.cb1.currentIn "" ""]
## <attributeDialog> [metaDot attribute $instanceName]
## [metaDot attribute test.cb11.displayState "" ""]
## <moduleNameArgsDocDialog> [metaDot module $instanceName nameArgsDoc]
## metaDot module test nameArgsDoc ""]
## <moduleDisplayAttributeDialog> [metaDot module $instanceName displayAttribute]
## metaDot module test displayAttribute ""]
## <moduleFactsDialog> [metaDot module $instanceName facts]
## metaDot module test facts ""]
## <componentNameArgsDocDialog> [metaDot component $instanceName nameArgsDoc]
## metaDot component test.cb1 nameArgsDoc ""]
## <componentDisplayAttributeDialog> [metaDot component $instanceName displayAttribute]
## metaDot component test.cb1 displayAttribute ""]
## <componentBGModelDialog> [metaDot component $instanceName backgroundModel]
## metaDot component test.cb1 backgroundModel ""]
## <componentInitCondDialog> [metaDot component $instanceName initialConditions]
## metaDot component test.cb1 initialConditions ""]
## <componentModeModelDialog> [metaDot component $instanceName mode $modeName]
## metaDot component test.cb1 mode off]
## <componentModeTransitionsDialog> [metaDot component $instanceName transitions $modeName]
## metaDot component test.cb1 transitions off
## 04oct99 wmt: new
## 28nov00 wmt: revised
# proc metaDot { nodeClassType instanceName dialogType modeName } 
body LivingstoneEventListener_impl::metaDot { nodeClassType instanceName dialogType modeName } {
  global g_NM_instanceToNode pirNode g_NM_metaDotParentNodeGroupList
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_toolsL2ViewerP 

  set canvasRootId 0; set reportNotFoundP 0
  set nodeClassType [string trim $nodeClassType \"]
  set instanceName [string trim $instanceName \"]
  set dialogType [string trim $dialogType \"]
  set modeName [string trim $modeName \"]


  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::metaDot"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::metaDot $nodeClassType $instanceName $dialogType $modeName"

  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "")} {
    l2toolsRequestError "metaDot: No module loaded"
    return
  }
  set loadedModuleName $g_NM_selectedTestScope
  if [catch { set g_NM_instanceToNode($instanceName) } pirNodeIndex ] {
    set str "metaDot: $nodeClassType instance `$instanceName' not found"
    l2toolsRequestError "$str in loaded module `$loadedModuleName'"
    return 
  }
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
  if {[lsearch -exact {component module} $nodeClassType] >= 0} {
    set parentNodeGroupList [linsert $parentNodeGroupList 0 $instanceName]
  }
  # puts stderr "metaDot: instanceName $instanceName nodeClassType $nodeClassType"
  # puts stderr "         parentNodeGroupList $parentNodeGroupList"
  # puts stderr "         g_NM_metaDotParentNodeGroupList $g_NM_metaDotParentNodeGroupList"
  if {! [string match $g_NM_metaDotParentNodeGroupList $parentNodeGroupList]} {
    set g_NM_metaDotParentNodeGroupList $parentNodeGroupList 
    deleteAllViewDialogs
    set returnValue [openCanvasToInstanceParent $pirNodeIndex $canvasRootId]
    update
    if {($returnValue != -1) && \
            [lsearch -exact {component module} $nodeClassType] >= 0} {
      set canvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c
      set window [getWindowPathFromPirNodeIndex $pirNodeIndex $canvas]
      openNodeGroup $instanceName $nodeClassType $window
      update
    }    
  }
  set caller "metaDot"
  set xPos 100; set yPos 200
  # bring up appropriate dialog in read-only mode
  switch $nodeClassType {
    terminal
    { askTerminalInstance $nodeClassType $nodeClassName $pirNodeIndex $caller \
          $xPos $yPos
    }
    attribute
    { askTerminalInstance $nodeClassType $nodeClassName $pirNodeIndex $caller \
          $xPos $yPos
    }
    module
    {
      switch $dialogType {
        nameArgsDoc
        {
          askLivingstoneDefmoduleParams nameVarDoc $caller $xPos $yPos
        }
        displayAttribute
        {
          if [catch {getDisplayStatePirNodeIndex \
                         [getCanvasRootInfo g_NM_currentNodeGroup]} \
                  displayStatePirNodeIndex] {
          set str "metaDot: $dialogType for $nodeClassType"
            l2toolsRequestError "$str instance `$instanceName' not found"
            return
          }
          askTerminalInstance attribute displayState $displayStatePirNodeIndex \
              $caller $xPos $yPos
        }
        facts
        {
          askLivingstoneDefmoduleParams facts $caller $xPos $yPos
        }
        default
        {
          set str "metaDot: for module instance `$instanceName', dialogType"
          l2toolsRequestError "$str `$dialogType' not handled\!"
          return
        }
      }
    }
    component
    {
      switch $dialogType {
        nameArgsDoc
        {
          askLivingstoneDefcomponentParams nameVarDoc $caller $xPos $yPos
        }
        displayAttribute
        {
          if [catch {getDisplayStatePirNodeIndex \
                         [getCanvasRootInfo g_NM_currentNodeGroup]} \
                  displayStatePirNodeIndex] {
            set str "metaDot: $dialogType for $nodeClassType"
            l2toolsRequestError "$str instance `$instanceName' not found"
            return
          }
          askTerminalInstance attribute displayState $displayStatePirNodeIndex \
              $caller $xPos $yPos
        }
        backgroundModel
        {
          askLivingstoneDefcomponentParams backModel $caller $xPos $yPos
        }
        initialConditions
        {
          askLivingstoneDefcomponentParams initCond $caller $xPos $yPos
        }
        mode
        {
          set modeInstanceName "$instanceName.$modeName"
          if [catch { set g_NM_instanceToNode($modeInstanceName) } modeIndex] {
            set str "metaDot: `$modeName' is not a $dialogType of $nodeClassType"
            l2toolsRequestError "$str instance `$instanceName'"
            return
          }
          set nodeClassName [assoc nodeClassName pirNode($modeIndex)]
          set nodeClassType [assoc nodeClassType pirNode($modeIndex)]
          askModeInstance $nodeClassType $nodeClassName $modeIndex $caller \
              $xPos $yPos
        }
        transitions
        {
          set modeInstanceName "$instanceName.$modeName" 
          if [catch { set g_NM_instanceToNode($modeInstanceName) } modeIndex] {
            set str "metaDot: `$modeName' is not a mode of $nodeClassType"
            l2toolsRequestError "$str instance `$instanceName'"
            return
          }
          set transitionsList [assoc transitions pirNode($modeIndex) \
                           $reportNotFoundP]
          if {[string match $transitionsList ""]} {
            set str "metaDot: no transitions exist for mode `$modeName' of"
            puts stderr "$str $nodeClassType instance `$instanceName'" 
            return
          }
          set nodeClassName [assoc nodeClassName pirNode($modeIndex)]
          foreach transitionForm $transitionsList {
            set startPirNodeIndex [assoc startNode transitionForm]
            set stopPirNodeIndex [assoc stopNode transitionForm]
            editModeTransition transition transition $startPirNodeIndex \
                          $stopPirNodeIndex $caller $xPos $yPos
            incr xPos 20; incr yPos 20
          }
        }
        default
        { set str "metaDot: for component instance `$instanceName', dialogType"
          l2toolsRequestError "$str `$dialogType' not handled\!"
          return
        }
      }
    }
    default
    { l2toolsRequestError \
          "metaDot: nodeClassType `$nodeClassType' not handled\!"
      return
    }
  }
}


## load module or component for Livingstone to use for metaDot operations
## 04oct99 wmt: new
## 22nov00 wmt: revised
# proc loadModule { moduleComponentName } 
body LivingstoneEventListener_impl::loadModule { moduleComponentName } {
  global pirFileInfo g_NM_selectedTestScope g_NM_menuStem 
  global g_NM_selectedTestScopeRoot g_NM_vmplTestModeP
  global pirNodes g_NM_toolsL2ViewerP

  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::loadModule"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::loadModule: $moduleComponentName"
  set moduleComponentName [string trim $moduleComponentName \"]
  set workspacePath [lindex [preferred STANLEY_USER_DIR] 0]
  set workspaceId [file tail $workspacePath]
  set moduleComponentNameFile ${moduleComponentName}$pirFileInfo(suffix)
  set nodeClassType "module"
  pushd [getSchematicDirectory root $nodeClassType]
  set scmFiles [glob -nocomplain *$pirFileInfo(suffix)]
  popd
  if {[lsearch -exact $scmFiles $moduleComponentNameFile] == -1} {
    set nodeClassType "component"
    pushd [getSchematicDirectory root $nodeClassType]
    set scmFiles [glob -nocomplain *$pirFileInfo(suffix)]
    popd
    if {[lsearch -exact $scmFiles $moduleComponentNameFile] == -1} {
      set str "loadModule: $nodeClassType `$moduleComponentName' not found"
      l2toolsRequestError "$str in workspace `$workspacePath'"
      return
    }
  }
  # puts stderr "moduleComponentNameFile $moduleComponentNameFile scmFiles $scmFiles nodeClassType $nodeClassType "
  set resetP 0
  # always do a full instantiation
#   if {([string match $g_NM_selectedTestScopeRoot $nodeClassType] && \
#            [string match $g_NM_selectedTestScope $moduleComponentName]) \
#           && $g_NM_vmplTestModeP && ([llength $pirNodes] > 0)} {
#     # component or module is already selected and loaded in Test mode
#     set resetP 1
#   }

  selectTestScope $nodeClassType $moduleComponentName
  # this type of call from L2Tools assumes that the current
  # model is already loaded, so donot compile .jmpl and load .xmpl
#   set menuRoot .master.$g_NM_menuStem
#   if {[lindex [$menuRoot.test.m entryconfigure "Compile" -state] 4] \
#           == "normal"} {
#     compileTestScope
#   }
#   if {[lindex [$menuRoot.test.m entryconfigure "Load & Go" -state] 4] \
#           == "normal"} {
#     instantiateTestModule
#   }
  instantiateTestModule $resetP 
}


## return list of schematic modules, loadable by Stanley
## 07oct99 wmt:new
# proc getModules { } 
body LivingstoneEventListener_impl::getModules { } {
  global pirFileInfo g_NM_toolsL2ViewerP

  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::getModules"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::getModules"
  set moduleList {}
  pushd [getSchematicDirectory root module]
  set moduleScmFiles [glob -nocomplain *$pirFileInfo(suffix)]
  popd
  pushd [getSchematicDirectory root component]
  set componentScmFiles [glob -nocomplain *$pirFileInfo(suffix)]
  popd
  foreach file [concat $moduleScmFiles $componentScmFiles] {
    lappend moduleList [file rootname $file]
  }
  return "$moduleList"
}


## return list of workspaces, loadable by Stanley
## 21nov00 wmt:new
# proc getWorkSpaces { } 
body LivingstoneEventListener_impl::getWorkSpaces { } {
  global g_NM_toolsL2ViewerP

  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::getWorkSpaces"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::getWorkSpaces"
  set workspaceList [preferred STANLEY_USER_DIR]
  return "$workspaceList"
}


## 21nov00 wmt:new
# proc loadWorkSpace { workspace } 
body LivingstoneEventListener_impl::loadWorkSpace { workspace } {
  global g_NM_toolsL2ViewerP

  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::loadWorkSpace"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::loadWorkSpace $workspace"
  set workspaceList [preferred STANLEY_USER_DIR]
  if {[lsearch -exact $workspaceList $workspace] >= 0} {
    set startupP 0
    set workspaceId [file tail $workspace] 
    openWorkspace $workspace $workspaceId $startupP
  } else {
    l2toolsRequestError \
        "loadWorkSpace: workspace `$workspace' does not exist"
  }
}


## return list of instance names of the requested class type
## componentInstanceName is an optional arg, used only when nodeClassType = mode
## 07oct99 wmt:new
# proc getInstances { nodeClassType componentInstanceName } 
body LivingstoneEventListener_impl::getInstances { nodeClassType componentInstanceName } {
  global g_NM_instanceToNode g_NM_componentToNode 
  global g_NM_moduleToNode pirNode g_NM_nodeGroupToInstances
  global g_NM_toolsL2ViewerP g_NM_selectedTestScopeRoot
  global g_NM_selectedTestScope

  if {! $g_NM_toolsL2ViewerP} {
    puts stderr "Discarded LivingstoneEventListener_impl::getInstances"
    return
  }
  puts stderr "\nLivingstoneEventListener_impl::getInstances $nodeClassType $componentInstanceName"

  if {($g_NM_selectedTestScopeRoot == "") ||  \
          ($g_NM_selectedTestScope == "")} {
    l2toolsRequestError "getInstances: No module loaded"
    return
  }

  set reportNotFoundP 0
  set loadedModuleName $g_NM_selectedTestScope
  set loadedModuleType $g_NM_selectedTestScopeRoot 
  set nodeClassType [string trim $nodeClassType \"]
  set componentInstanceName [string trim $componentInstanceName \"]
  set instanceList {}
  switch $nodeClassType {
    terminal
    {
      foreach instanceName [array names g_NM_instanceToNode] {
        if {[string match $instanceName "0"]} {
          continue
        }
        set pirNodeIndex [assoc-array $instanceName g_NM_instanceToNode]
        set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)] 
        if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                 "terminal"] && \
                (! [regexp "DECLARATION" $nodeClassName])} {
          lappend instanceList $instanceName
        }
      }
    }
    attribute
    {
      foreach instanceName [array names g_NM_instanceToNode] {
        if {[string match $instanceName "0"]} {
          continue
        }
        set pirNodeIndex [assoc-array $instanceName g_NM_instanceToNode]
        if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                 "attribute"]} {
          lappend instanceList $instanceName
        }
      }
    }
    module
    {
      foreach instanceName [array names g_NM_moduleToNode] {
        if {[string match $instanceName "0"]} {
          continue
        }
        set pirNodeIndex [assoc-array $instanceName g_NM_moduleToNode]
        if {(! [string match [assoc nodeState pirNode($pirNodeIndex)]  \
                    "parent-link"]) && \
                ($instanceName != "?name")} {
          lappend instanceList $instanceName
        }
      }
    }
    component
    {
      foreach instanceName [array names g_NM_componentToNode] {
        if {[string match $instanceName "0"]} {
          continue
        }
        lappend instanceList $instanceName
      }
    }
    mode
    {
      set instanceNodePairList [assoc-array $componentInstanceName \
                                    g_NM_nodeGroupToInstances $reportNotFoundP]
      if {! [string match $instanceNodePairList ""]} {
        for {set indx 0} {$indx < [llength $instanceNodePairList]} {incr indx 2} {
          set pirNodeIndex [lindex $instanceNodePairList [expr {$indx + 1}]]
          if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                   "mode"]} {
            lappend instanceList [getComponentModeLabel \
                                      [lindex $instanceNodePairList $indx]]
          }
        }
      } else {
        set str "getInstances: component instance `$componentInstanceName'"
        l2toolsRequestError \
            "$str not found in loaded module `$loadedModuleName'"
        return ""
      }
    }
    default
    { l2toolsRequestError \
          "getInstances: nodeClassType `$nodeClassType' not handled\!"
      return ""
    }
  }
  if {[llength $instanceList] > 0} {
    return "[lsort -ascii $instanceList]"
  } else {
    # this will never happen for nodeClassType = mode, since Stanley forces
    # every component to have at least one mode
    set str "No `$nodeClassType' instances found"
    l2toolsRequestError "$str in loaded module `$loadedModuleName'" 
    return ""
  }
}








