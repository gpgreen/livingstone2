# $Id: test-scenario.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## test-scenario.tcl => handle Test scenario management


## select scenario in Livingstone
## 27aug99 wmt: new
proc selectScenario { rootName scenarioName } {
  global g_NM_scenarioDialogRoot g_NM_scenarioScriptModifiedP 
  global g_NM_testScenarioName g_NM_scenarioExtension
  global g_NM_scenarioExecLineNum g_NM_scenarioDebugEntries
  global g_NM_scenarioCurrentEditLineNum g_NM_scenarioNewEditLineNum
  global g_NM_scenarioScriptDbgModifiedP g_NM_scenarioDebugEntriesSeen
  global g_NM_scenarioSteppingMode g_NM_scenarioPrevSteppingMode
  global g_NM_inhibitPirWarningP g_NM_selectedTestModule 

  set displayP 1; set severity 1
  # clearing the text, and tags of a very large scenario script is
  # much slower than destroying the Scenario Mgr and recreating it
  freshScenarioManager

  set msg  "Please Wait: Scenario being loaded ..."
  scenarioMgrWarning $msg $severity
  # do not let mouse over scenario line replace this msg with
  # "set edit marker", etc
  set g_NM_inhibitPirWarningP 1

  set g_NM_testScenarioName $scenarioName
  set g_NM_scenarioScriptModifiedP 0
  set g_NM_scenarioScriptDbgModifiedP 0
  $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
      "Save Scenario ..." -state disabled
  $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure \
      "Delete Line" -state normal 
  set g_NM_scenarioExecLineNum 2
  # initial value for loaded scenarios
  set g_NM_scenarioCurrentEditLineNum 1
  set g_NM_scenarioNewEditLineNum 1
  set g_NM_scenarioDebugEntries [getScenarioDebugEntries]
  set g_NM_scenarioDebugEntriesSeen {}
  set g_NM_scenarioSteppingMode ""
  set g_NM_scenarioPrevSteppingMode ""
  addToScenarioFile $scenarioName

  set txt $g_NM_scenarioDialogRoot.text&button.t.text
  scrollTextTagToMiddle $txt lineNum_$g_NM_scenarioExecLineNum 
  # move edit line marker to where user can see it
  set g_NM_scenarioNewEditLineNum [expr {$g_NM_scenarioExecLineNum + 1}]
  set g_NM_scenarioCurrentEditLineNum $g_NM_scenarioNewEditLineNum 
  moveScenarioEditMarker $displayP

  set g_NM_inhibitPirWarningP 0
  scenarioMgrWarning "" 
}


## add to working scenario file: vmplTestScenario
## with either input scenarioName files or
## interactively with g_NM_stepCommandsMonitors 
## 14dec98 wmt: new
proc addToScenarioFile { scenarioName {displayP 1} {deleteLineP 0} } {
  global g_NM_stepCommandsMonitors g_NM_testScenarioName 
  global g_NM_freshCommandLineP g_NM_scenarioScriptModifiedP
  global g_NM_scenarioExtension g_NM_selectedTestScope
  global g_NM_commandLineLockP g_NM_scenarioCurrentEditLineNum 
  global g_NM_firstCmdReceivedP g_NM_scenarioDialogRoot
  global g_NM_scenarioEobLine g_NM_scenarioNewEditLineNum env
  global g_NM_scenarioExecLineNum 

  set lineCnt 1; set newCmdCnt 0
  set scenarioDir "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # puts stderr "addToScenarioFile: g_NM_stepCommandsMonitors `$g_NM_stepCommandsMonitors'"
  # formatted form for use in scenario files
  # complete scenario file
  set formattedStepForm ""
  # edit change to scenario file
  set incFormattedStepForm ""
  # put stanleyStep, vmplTestScenario, & incVmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set accumScenarioDir "$env(HOME)/.stanley/"
  set accumScenarioPathname ${accumScenarioDir}vmplTestScenario$g_NM_scenarioExtension
  set incScenarioPathname ${accumScenarioDir}incVmplTestScenario$g_NM_scenarioExtension
  # puts stderr "addToScenarioFile: scenarioName `$scenarioName'"
  if {$scenarioName == ""} {
    # set str "addToScenarioFile: g_NM_scenarioCurrentEditLineNum"
    # puts stderr "$str $g_NM_scenarioCurrentEditLineNum"
    # add to working scenario file
    set g_NM_scenarioScriptModifiedP 1; set newFileP 0
    $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
        "Save Scenario ..." -state normal
    $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure \
        "Delete Line" -state normal
    if {[file exists $accumScenarioPathname]} {
      set fid [open $accumScenarioPathname r]
      while {($lineCnt < $g_NM_scenarioCurrentEditLineNum) && \
                 ([gets $fid cmd ] != -1)} {
        append formattedStepForm "$cmd\n"
        incr lineCnt 
      }
    } else {
      set newFileP 1
      # put scenario cmd as first line of new accum file
      append formattedStepForm \
          "scenario $g_NM_testScenarioName $g_NM_selectedTestScope\n"
    }
    set firstP 1; set stepForm ""
    foreach form $g_NM_stepCommandsMonitors {
      set cmdOrCommentText [lindex $form 1]
      if {$firstP} {
        set stepForm $cmdOrCommentText
        set firstP 0
      }
      set propositionOrComment [lindex $form 0]
      if {(! [string match $cmdOrCommentText $propositionOrComment]) && \
              ($propositionOrComment != "comment")} {
        set attr [lindex $propositionOrComment 0]
        set val [lindex $propositionOrComment 2]
        append stepForm " ${attr}=$val"
      }
    }
    if {$stepForm != ""} {
      append formattedStepForm "$stepForm\n"
      append incFormattedStepForm "$stepForm\n"
      incr newCmdCnt 
    }
    set g_NM_stepCommandsMonitors {}
    if {! $newFileP} {
      if {$deleteLineP} {
        # discard marked line, but not eob line
        gets $fid cmd
        if {([lindex [$g_NM_scenarioDialogRoot.text&button.b.reset config -state] 4] \
                 == "disabled") && \
                ($g_NM_scenarioCurrentEditLineNum <= $g_NM_scenarioExecLineNum)} {
          # deleted line is the exec line or a comment line above it
          # so decrement exec line number
          incr g_NM_scenarioExecLineNum -1
        }
        if {[string match $cmd $g_NM_scenarioEobLine]} {
          append formattedStepForm "$g_NM_scenarioEobLine\n"
        }
      }
      # copy in balance of accum file
      while {[gets $fid cmd ] != -1} {
        append formattedStepForm "$cmd\n"
      }
      close $fid
    } else {
      append formattedStepForm "$g_NM_scenarioEobLine\n"
    }
  } else {
    set newFileP 1
    # throw away existing working scenario file and replace with this
    set fid [open $scenarioDir/$scenarioName$g_NM_scenarioExtension r]
    while {[gets $fid line] >= 0} {
      if {$line != ""} {
        append formattedStepForm "$line\n"
        incr newCmdCnt
      }
    }
    close $fid
    append formattedStepForm "$g_NM_scenarioEobLine\n"
  }
  if {$newCmdCnt > 0} {
    # reset edit mark line
    # puts stderr "addToScenarioFile: newCmdCnt $newCmdCnt g_NM_scenarioNewEditLineNum $g_NM_scenarioNewEditLineNum "
    set g_NM_scenarioNewEditLineNum [expr {$g_NM_scenarioNewEditLineNum + \
                                               $newCmdCnt}]
  }
  # puts stderr "addToScenarioFile: formattedStepForm $formattedStepForm "
  # write updated complete scenario file
  set fid [open $accumScenarioPathname w]
  puts $fid [string trimright $formattedStepForm "\n"]
  close $fid
  if {($scenarioName == "") && (! $newFileP)} {
    # write scenario file change 
    set fid [open $incScenarioPathname w]
    puts $fid [string trimright $incFormattedStepForm "\n"]
    close $fid
  }

  if {$displayP} {
    # show scenario text with cursor at current step
    showScenarioText $newFileP $deleteLineP
#     set timeString [time {showScenarioText $newFileP $deleteLineP}]
#     set splitList [split $timeString " "]
#     puts stderr "showScenarioText: [expr { [lindex $splitList 0]/ 1000000.0}] "

    $g_NM_scenarioDialogRoot.text&button.b.single config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.step config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.run config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.warp config -state normal
  }
}


## handle mouse click on STEP accelerator button
## manual (set values with Mouse-R) or scripted
## 14dec98 wmt: new
proc vmplTestStep { {singleLineP 0} } {
  global g_NM_testScenarioName g_NM_scenarioSteppingMode 
  global g_NM_freshCommandLineP g_NM_commandLineLockP 
  global g_NM_scenarioExtension g_NM_selectedTestScope 
  global g_NM_firstCmdReceivedP g_NM_scenarioDialogRoot env
  global g_NM_scenarioExecLineNum g_NM_scenarioResetButtonActiveP
  global g_NM_scenarioPrevSteppingMode g_NM_L2FindCandidatesCmdTypeList 

  set caller "vmplTestStep"
  if {$g_NM_scenarioPrevSteppingMode == ""} {
    set g_NM_scenarioPrevSteppingMode "step"
  }
  set g_NM_scenarioSteppingMode "step"
  if {$singleLineP == 1} {
    set g_NM_scenarioSteppingMode "single"
  }
  # set scenarioDir "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # put stanleyStep & vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set scenarioDir "$env(HOME)/.stanley/"
  set accumScenarioPathname ${scenarioDir}vmplTestScenario$g_NM_scenarioExtension
  set cmdCnt [generateScenarioStep $g_NM_selectedTestScope $g_NM_testScenarioName \
                  $accumScenarioPathname $singleLineP breakpointP stanleyStepOutput]
  # puts stderr "vmplTestStep: singleLineP $singleLineP cmdCnt $cmdCnt "
  if {$cmdCnt > 0} {
    # set flag for gotAssignment and gotProgress so they can
    # invoke deleteL2TestValueBalloons 
    set g_NM_firstCmdReceivedP 0

    set stanleyStepPath ${scenarioDir}stanleyStep$g_NM_scenarioExtension
    # this screws up L2 and the Candidate Mgr, i.e the progress messes
    # up the time state
    # if they did not causes this problem, then they would be used only
    # when one of any outstanding list of candidates has been installed
    # if none installed do not use them
    if {$singleLineP == 1} {   
      ## check for fc by reading stanleyStep as in livingstoneCmdLineRequest 
      set fid [open  $stanleyStepPath r]
      set cmd ""
      while {[gets $fid line ] != -1} {
        set line [string trim $line " "]
        if {$line != ""} {
          set cmd $line
        }
      }
      close $fid
    }
    # enable reset for the step processing
    if {! $g_NM_commandLineLockP} {
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state normal
    }
    if {($singleLineP == 1) && $breakpointP} {
      # send no cmd
    } else {
      # send CORBA request to Livingstone to load step scenario file
      livingstoneCmdLineRequest "run $stanleyStepPath"

      if {($singleLineP == 1) && \
              ($cmd != "fc") && \
              ([lsearch -exact $g_NM_L2FindCandidatesCmdTypeList $cmd] == -1)} {
        livingstoneCmdLineRequest "singleStep"
      }
    }
    if {$breakpointP} {
      scenarioManagerEnable $caller
    }
    if {! $g_NM_commandLineLockP} {
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state normal
    }
  }
  set g_NM_scenarioPrevSteppingMode $g_NM_scenarioSteppingMode 
  set g_NM_scenarioSteppingMode ""
  # puts stderr "vmplTestStep: finish"
  if {$g_NM_scenarioResetButtonActiveP} {
    instantiateTestModule $g_NM_scenarioResetButtonActiveP 
  }
}



## handle mouse click on RUN accelerator button
## interactive (set values with Mouse-R) or scripted (Scenario Mgr: File->Open Scenario)
## 30aug99 wmt: new
proc vmplTestRun { } {
  global g_NM_acceleratorStem g_NM_testScenarioName
  global g_NM_scenarioDialogRoot g_NM_firstCmdReceivedP 
  global g_NM_selectedTestScopeRoot g_NM_scenarioSteppingMode 
  global g_NM_scenarioExtension g_NM_selectedTestScope
  global g_NM_commandLineLockP g_NM_freshCommandLineP env
  global g_NM_scenarioExecLineNum g_NM_scenarioResetButtonActiveP
  global g_NM_scenarioPrevSteppingMode g_NM_livingstoneCmdLineORBObject

  if {$g_NM_scenarioPrevSteppingMode == ""} {
    set g_NM_scenarioPrevSteppingMode "run"
  }
  set g_NM_scenarioSteppingMode "run"
  set caller "vmplTestRun"
  # invoke scenario file in Livingstone
  # set scenarioDir "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # put stanleyStep & vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set scenarioDir "$env(HOME)/.stanley/"
  set accumScenarioPathname ${scenarioDir}vmplTestScenario$g_NM_scenarioExtension
  set singleLineP 0
  # tell L2 not to update Candidate Mgr, History Table, or Stanley -- if we
  # are in warp mode
  while {! $g_NM_commandLineLockP} {
    set cmdCnt [generateScenarioStep $g_NM_selectedTestScope $g_NM_testScenarioName \
                    $accumScenarioPathname $singleLineP breakpointP stanleyStepOutput]
    if {$cmdCnt > 0} {
      # set flag for gotAssignment and gotProgress so they can
      # invoke deleteL2TestValueBalloons 
      set g_NM_firstCmdReceivedP 0

      # send CORBA request to Livingstone to load step scenario file
      livingstoneCmdLineRequest "run ${scenarioDir}stanleyStep$g_NM_scenarioExtension"

      set g_NM_freshCommandLineP 0
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state normal 
      if {$breakpointP} {
        scenarioManagerEnable $caller
        break
      }
    } else {
      break
    }
  }
  set g_NM_scenarioPrevSteppingMode $g_NM_scenarioSteppingMode 
  set g_NM_scenarioSteppingMode ""
  if {$g_NM_scenarioResetButtonActiveP} {
    instantiateTestModule $g_NM_scenarioResetButtonActiveP 
  }
}


## handle mouse click on WARP accelerator button
## interactive (set values with Mouse-R) or scripted (Scenario Mgr: File->Open Scenario)
## 07aug01 wmt: new
proc vmplTestWarp { } {
  global g_NM_acceleratorStem g_NM_testScenarioName
  global g_NM_scenarioDialogRoot g_NM_firstCmdReceivedP 
  global g_NM_selectedTestScopeRoot g_NM_scenarioSteppingMode 
  global g_NM_scenarioExtension g_NM_selectedTestScope
  global g_NM_commandLineLockP g_NM_freshCommandLineP env
  global g_NM_scenarioExecLineNum g_NM_scenarioResetButtonActiveP
  global g_NM_scenarioPrevSteppingMode g_NM_livingstoneCmdLineORBObject 
  global g_NM_livingstoneEvtListORBObject

  if {$g_NM_scenarioPrevSteppingMode == ""} {
    set g_NM_scenarioPrevSteppingMode "warp"
  }
  set g_NM_scenarioSteppingMode "warp"
  set caller "vmplTestWarp"
  # invoke scenario file in Livingstone
  # set scenarioDir "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # put stanleyStep & vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set scenarioDir "$env(HOME)/.stanley/"
  set accumScenarioPathname ${scenarioDir}vmplTestScenario$g_NM_scenarioExtension
  set singleLineP 0
  set cmdCnt [generateScenarioStep $g_NM_selectedTestScope $g_NM_testScenarioName \
                  $accumScenarioPathname $singleLineP breakpointP stanleyStepOutput]
  if {$cmdCnt > 0} {
    # set flag for gotAssignment and gotProgress so they can
    # invoke deleteL2TestValueBalloons 
    set g_NM_firstCmdReceivedP 0
    scenarioManagerDisable 

    # send CORBA request to Livingstone to load warp scenario file
    puts stderr "\nvmplTestWarp: $cmdCnt commands from $g_NM_testScenarioName"
    if [ catch { $g_NM_livingstoneCmdLineORBObject warpCommands $stanleyStepOutput } \
             message ] {
      l2toolsRequestError $message 
      puts stderr "\nlivingstoneCmdLineRequest: CORBA ERROR => $message"
      # do not send any more cmds
      set g_NM_commandLineLockP 1
    }

    # move exec marker to break point 
    moveScenarioExecMarker
    set g_NM_freshCommandLineP 0
    $g_NM_scenarioDialogRoot.text&button.b.reset config -state normal 
    if {$breakpointP} {
      scenarioManagerEnable $caller
    }
  }
  set g_NM_scenarioPrevSteppingMode $g_NM_scenarioSteppingMode 
  set g_NM_scenarioSteppingMode ""
  if {$g_NM_scenarioResetButtonActiveP} {
    instantiateTestModule $g_NM_scenarioResetButtonActiveP 
  }
}


## handle insertion of Edit->Insert commands to active
## scenario script
## 25sep00 wmt: new
proc insertScenarioEditCommands { menuRootName cmd } {
  global g_NM_stepCommandsMonitors 

  set scenarioName ""
  if {$cmd == "truncate"} {
    # truncate needs a argument: the horizon, behind which history is truncated
    getTruncateHorizon 
  } else {
    lappend g_NM_stepCommandsMonitors [list $cmd $cmd]
    addToScenarioFile $scenarioName
#     set timeString [time {addToScenarioFile $scenarioName}]
#     set splitList [split $timeString " "]
#     puts stderr "addToScenarioFile: [expr { [lindex $splitList 0]/ 1000000.0}] "
  }
}


## truncate needs a argument: the horizon, behind which history is truncated
## 31july01 wmt: new
proc getTruncateHorizon { } {
  global g_NM_scenarioNameRootWindow 

  set g_NM_scenarioSaveCancelP 0
  set dialogW $g_NM_scenarioNameRootWindow  
  toplevel $dialogW -class Dialog
  wm title $dialogW "Truncate Horizon"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  getTruncateHorizonFromL2 minHorizon maxHorizon

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command "getTruncateHorizonDoit $dialogW $minHorizon $maxHorizon"
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "destroy $dialogW" 
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set widget $dialogW.fHorizon

  mkEntryWidget $widget "" "($minHorizon - $maxHorizon)" \
      $minHorizon normal
  balloonhelp $widget.label.descrp -side right "(number)"
  focus $dialogW.fHorizon.fentry.entry
  keepDialogOnScreen $dialogW 

  if [winfo exists $dialogW] {
    tkwait window $dialogW
  }
}


## 31july01 wmt: new
proc getTruncateHorizonDoit { dialogW minHorizon maxHorizon } {
  global g_NM_stepCommandsMonitors 

  set horizonValue [$dialogW.fHorizon.fentry.entry get]
  set horizonValue [string trim $horizonValue " "] 
  if {! [entryValueErrorCheck Horizon "(number)" $horizonValue]} {
    return
  }
  if {($horizonValue < $minHorizon) || \
          ($horizonValue > $maxHorizon)} {
    set str "horizon `$horizonValue' is not in range of "
    append str "$minHorizon - $maxHorizon"
    set dialogList [list tk_dialog .d "ERROR" $str error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  destroy $dialogW 

  set scenarioName ""
  set cmd [list truncate $horizonValue]
  lappend g_NM_stepCommandsMonitors [list $cmd $cmd]
  addToScenarioFile $scenarioName
}


## calculate the horizon min/max
## 31july01 wmt: new
proc getTruncateHorizonFromL2 { minHorizonRef maxHorizonRef } {
  upvar $minHorizonRef minHorizon
  upvar $maxHorizonRef maxHorizon
  global g_NM_livingstoneCmdLineORBObject 

  # get history start, stop times from L2
  set startStopString [$g_NM_livingstoneCmdLineORBObject getHistoryTimes]
  set splitList [split $startStopString " "] 
  # puts stderr "getTruncateHorizon: `$startStopString' splitList $splitList "
  if {[llength $splitList] != 0} {
    set minHorizon [lindex $splitList 0]
    # max is 1 less than current time, unless it is 1
    set maybeMaxHorizon [lindex $splitList 1] 
    if {$maybeMaxHorizon > 1} {
      set maxHorizon [expr {$maybeMaxHorizon - 1}]
    } else {
      set maxHorizon $maybeMaxHorizon 
    }
  } else {
    set minHorizon 0
    set maxHorizon 0
  }
  # puts stderr "getTruncateHorizon: $minHorizon $maxHorizon"
}
  

## 28sep00 wmt: new
proc deleteScenarioLine { } {

  set scenarioName ""; set displayP 1; set deleteLineP 1
  addToScenarioFile $scenarioName $displayP $deleteLineP
}


## create the Scenario Manager Window
## 18sep00 wmt
proc createScenarioManager { scenarioList } {
  global g_NM_testScenarioName g_NM_scenarioMgrHeightPixels
  global g_NM_scenarioDialogRoot g_NM_stepCommandsMonitors 
  global g_NM_scenarioExtension g_NM_currentScenarioExecTag 
  global g_NM_scenarioScriptModifiedP env 
  global g_NM_scenarioExecLineNum g_NM_scenarioMgrMaxLines 
  global g_NM_scenarioMgrXpos g_NM_scenarioMgrYpos 
  global g_NM_scenarioCurrentEditLineNum g_NM_scenarioNewEditLineNum
  global g_NM_scenarioSteppingMode g_NM_scenarioResetButtonActiveP
  global g_NM_scenarioDebugEntries g_NM_scenarioScriptDbgModifiedP
  global g_NM_scenarioDebugEntriesSeen g_NM_scenarioPrevSteppingMode
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset 

  set g_NM_stepCommandsMonitors {}
  set g_NM_scenarioDebugEntries {}
  set g_NM_scenarioDebugEntriesSeen {}
  set g_NM_testScenarioName "<unspecified>"
  set g_NM_scenarioScriptModifiedP 0
  set g_NM_scenarioScriptDbgModifiedP 0
  set g_NM_currentScenarioExecTag ""
  set g_NM_scenarioMgrMaxLines 0
  # set for STEP & RUN
  set g_NM_scenarioSteppingMode ""
  set g_NM_scenarioPrevSteppingMode ""
  set g_NM_scenarioResetButtonActiveP 0
  # delete file that holds accumulated manual scenario cmds
  # set directory "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # put vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set directory "$env(HOME)/.stanley/"
  file delete ${directory}vmplTestScenario$g_NM_scenarioExtension 
  set g_NM_scenarioExecLineNum 2
  # initlal value for interactive scenarios
  set g_NM_scenarioCurrentEditLineNum 2
  set g_NM_scenarioNewEditLineNum 2

  set textHeight 12; set textWidth 60; set canvasRootId 0
  set window $g_NM_scenarioDialogRoot
  if {[winfo exists $window]} {
    set g_NM_scenarioMgrXpos [expr {[winfo rootx $window] - $g_NM_xWindowMgrOffset}]
    set g_NM_scenarioMgrYpos [expr {[winfo rooty $window] - $g_NM_yWindowMgrOffset}]
    destroy $window
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  toplevel $window -class Dialog
  if { [winfo viewable [winfo toplevel [winfo parent $window]]] } {
    wm transient $window [winfo toplevel [winfo parent $window]]
  }    
  set title "Stanley Scenario Manager"
  wm title $window $title 
  $window config -bg $bgcolor

  # menu bar
  set menuRoot $window.menu
  frame $menuRoot -relief groove -borderwidth 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor]
  # File
  menubutton $menuRoot.file -text "File" -menu $menuRoot.file.m \
      -underline 0 -relief flat 
  menu $menuRoot.file.m -tearoff 0 

  $menuRoot.file.m add command -label "New Scenario" \
      -command "freshScenarioManager" -state normal

  $menuRoot.file.m add separator
  set selectFunction selectScenario
  generateCascadeMenu $menuRoot.file.m open "Open Scenario" $scenarioList \
      $scenarioList $selectFunction normal

  $menuRoot.file.m add separator
  $menuRoot.file.m add command -label "Save Scenario ..." \
      -command "vmplTestSaveScenario" -state disabled

  $menuRoot.file.m add separator
  set selectFunction deleteScenario
  generateCascadeMenu $menuRoot.file.m delete "Delete Scenario" $scenarioList \
      $scenarioList $selectFunction normal

  # Edit
  menubutton $menuRoot.edit -text "Edit" -menu $menuRoot.edit.m \
      -underline 0 -relief flat 
  menu $menuRoot.edit.m -tearoff 0 

  set selectFunction insertScenarioEditCommands
  set searchMethod [preferred L2SearchMethod] 
  if {$searchMethod == "cbfs"} {
    set menuList {extend fc find-fresh progress prune-search truncate}
    set menuLabelList {"Extend Candidates " "Find Candidates" \
                           "Find Fresh Candidates" "Idle Progress" \
                           "Prune & Search" "Truncate"}
  } elseif {$searchMethod == "cover"} {
    set menuList {fc find-fresh progress prune-search truncate}
    set menuLabelList {"Find Candidates" "Find Fresh Candidates" \
                           "Idle Progress" "Prune & Search" "Truncate"}
  } else {
    error "createScenarioManager: L2SearchMethod [preferred L2SearchMethod] not handled"
  }
  generateCascadeMenu $menuRoot.edit.m insert "Insert Command" $menuList \
      $menuLabelList $selectFunction normal

  $menuRoot.edit.m add separator
  $menuRoot.edit.m add command -label "Insert Comment ..." \
      -command "insertScenarioComment" -state normal

  $menuRoot.edit.m add separator
  $menuRoot.edit.m add command -label "Delete Line" \
      -command "deleteScenarioLine" -state disabled

  $menuRoot.edit.m add separator
  $menuRoot.edit.m add command -label "Proposition Logging On" \
      -command togglePropsWarnMsgsP -state normal
  $menuRoot.edit.m add command -label "Proposition Logging Off"  \
      -command togglePropsWarnMsgsP -state disabled
  # set menu items to last value selected by user
  set toggleP 0
  togglePropsWarnMsgsP $toggleP

  pack $menuRoot.file $menuRoot.edit -side left 
  tk_menuBar $menuRoot $menuRoot.file $menuRoot.edit
  bind Menu <Enter> "[bind Menu <Enter>]"
  pack $menuRoot -side top -fill both
 
  # text and buttons
  frame $window.text&button -bd 0 -bg $bgcolor
  frame $window.text&button.t -bd 0 -bg $bgcolor
  frame $window.text&button.t.right -bd 0 -bg $bgcolor
  frame $window.text&button.t.bottom -bd 0 -bg $bgcolor
  frame $window.text&button.b -bd 0 -bg $bgcolor
  frame $window.text&button.h -bd 0 -bg $bgcolor 
  frame $window.text&button.w -bd 2 -bg $bgcolor -relief ridge 

  set txt [text $window.text&button.t.text -setgrid true \
               -xscrollcommand "$window.text&button.t.bottom.sx set" \
               -yscrollcommand "$window.text&button.t.right.sy set" \
               -wrap word -font [preferred StanleyDialogEntryFont]]

  scrollbar $window.text&button.t.bottom.sx -orient horiz \
      -command "$txt xview" -relief sunk -bd 2 
  scrollbar $window.text&button.t.right.sy -orient vertical \
      -command "$txt yview" -relief sunken -bd 2 

  set singleLineP 1
  button $window.text&button.b.single -anchor w \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "vmplTestStep $singleLineP" -text "SINGLE" 
  set string "execute the command on green line"
  balloonhelp $window.text&button.b.single -side right $string

  button $window.text&button.b.step -anchor w \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "vmplTestStep" -text "STEP" 
  set string "execute commands from green line to next breakpoint/\nfc/find-fresh/extend/prune-search or end-of-buffer"
  balloonhelp $window.text&button.b.step -side right $string

  button $window.text&button.b.run -anchor w \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "vmplTestRun" -text "RUN" 
  set string "execute commands from green line to next \nbreakpoint or end-of-buffer" 
  balloonhelp $window.text&button.b.run -side right $string

  button $window.text&button.b.warp -anchor w \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "vmplTestWarp" -text "WARP" 
  set string "execute commands from green line to next \nbreakpoint or end-of-buffer\nno Stanley/Candidate Manager/History Table updates" 
  balloonhelp $window.text&button.b.warp -side right $string

  button $window.text&button.b.reset -anchor w \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "resetScenarioManager" -text "RESET" 
  set string "Discard L2 state and scenario; create new engine" 
  balloonhelp $window.text&button.b.reset -side right $string

  pack $window.text&button.b.single $window.text&button.b.step \
      $window.text&button.b.run $window.text&button.b.warp \
      $window.text&button.b.reset \
      -side left -padx 5m -ipadx 2m -expand 1


  label $window.text&button.w.warn -text "" -relief flat \
      -bg [preferred StanleyLegendBgColor] -anchor w -pady 1 -padx 1 \
      -fg [preferred StanleyLegendFgColor] 
  pack $window.text&button.w.warn -side left -fill x 
  pack $window.text&button.w -side bottom -fill x 

  pack $window.text&button.b -side bottom

  pack $window.text&button.t.right.sy -side right -fill y -expand 1
  pack $window.text&button.t.right -side right -fill y
  pack $window.text&button.t.bottom.sx -side bottom -fill x -expand 1
  pack $window.text&button.t.bottom -side bottom -fill x 
  pack $window.text&button.t.text -side bottom -fill both -expand 1
  pack $window.text&button.t -side bottom -fill both -expand 1

  set text ""
  label $window.text&button.h.label -text $text \
      -bg [preferred StanleyMenuDialogBackgroundColor] -highlightthickness 0 \
      -font [preferred StanleyTerminalTypeFont]
  pack $window.text&button.h.label -side bottom
  pack $window.text&button.h -side bottom
      
  pack $window.text&button -fill both -expand 1

  # bind Mouse-L to set edit marker
  set displayP 1
  bind $txt <ButtonRelease-1> "moveScenarioEditMarker $displayP %x %y"
  # set window siz in characters
  $txt config -width $textWidth
  if {$g_NM_scenarioMgrHeightPixels != -1} {
    set txtFont [lindex [$txt config -font] 4]
    set lineheightPixels [font metrics $txtFont -linespace]
    set textHeight [expr { $g_NM_scenarioMgrHeightPixels / $lineheightPixels}]
  }
  $txt config -height $textHeight
  keepDialogOnScreen $window $g_NM_scenarioMgrXpos $g_NM_scenarioMgrYpos 
}


## destroy Scenario Mgr 
## 04apr01 wmt: new
proc destroyScenarioManager { } {
  global g_NM_scenarioDialogRoot
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_scenarioMgrXpos g_NM_scenarioMgrYpos
  global g_NM_scenarioMgrHeightPixels 

  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    # save scenario file, if modified
    saveModifiedScenarioFile

    set g_NM_scenarioMgrXpos [expr {[winfo rootx $g_NM_scenarioDialogRoot] - \
                                        $g_NM_xWindowMgrOffset}]
    set g_NM_scenarioMgrYpos [expr {[winfo rooty $g_NM_scenarioDialogRoot] - \
                                        $g_NM_yWindowMgrOffset}]
    set g_NM_scenarioMgrHeightPixels \
        [winfo height $g_NM_scenarioDialogRoot.text&button.t.text]

    destroy $g_NM_scenarioDialogRoot
    update
  }
}


## create a fresh Scenario Mgr
## 23aug01 wmt: new
proc freshScenarioManager { } {
  global g_NM_scenarioDialogRoot g_NM_selectedTestModule 

  # clearing the text, and tags of a very large scenario script is
  # much slower than destroying the Scenario Mgr and recreating it
  destroyScenarioManager
  set scenarioList [getScenariosForClass $g_NM_selectedTestModule]
  createScenarioManager $scenarioList
  $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
}


## process the scenario manager RESET cmd
## 24sep00 wmt
proc resetScenarioManager { } {
  global g_NM_commandLineLockP g_NM_scenarioSteppingMode 
  global g_NM_scenarioResetButtonActiveP 

  set resetP 1
  # if script is not running, restart from here
  # otherwise do it at end of vmplTestStep or vmplTestRun
  if {$g_NM_scenarioSteppingMode == ""} {
    # do the restart -- which also calls saveModifiedScenarioFile 
    instantiateTestModule $resetP
  } else {
    # is case user is currently running a script -- stop it
    set g_NM_commandLineLockP 1
    # puts stderr "resetScenarioManager: g_NM_commandLineLockP 1"
    set g_NM_scenarioResetButtonActiveP 1

    saveModifiedScenarioFile
  }
}


## save mofified scenario file
## 04apr01 wmt: extracted from resetScenarioManager 
proc saveModifiedScenarioFile { } {
  global g_NM_scenarioScriptModifiedP g_NM_testScenarioName
  global g_NM_scenarioScriptDbgModifiedP

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "saveModifiedScenarioFile: `$backtrace'"
  if {$g_NM_scenarioScriptModifiedP} {
    set dialogList [list tk_dialog .d "CONFIRM" \
                        "Do you want to save scenario `$g_NM_testScenarioName \[modified\]'?" \
                        question -1 {YES} {NO}]
    set returnValue [eval $dialogList]
    if {$returnValue == 0} {
      vmplTestSaveScenario
      saveScenarioDebugFile
    }
  }
  if {(! $g_NM_scenarioScriptModifiedP) && $g_NM_scenarioScriptDbgModifiedP} {
    set dialogList [list tk_dialog .d "CONFIRM" \
                        "Do you want to save scenario `$g_NM_testScenarioName' break points?" \
                        question -1 {YES} {NO}]
    set returnValue [eval $dialogList]
    if {$returnValue == 0} {
      saveScenarioDebugFile
    }
  }
}


## show user scenario text; scroll to current step
# if not a new file, insert or delete the appropriate line(s)
## 28nov99 wmt: new
proc showScenarioText { newFileP deleteLineP} {
  global g_NM_testScenarioName g_NM_scenarioExecLineNum 
  global g_NM_scenarioExtension g_NM_scenarioDialogRoot 
  global g_NM_currentScenarioExecTag g_NM_scenarioMgrMaxLines env 
  global g_NM_scenarioScriptModifiedP g_NM_scenarioCurrentEditLineNum
  global g_NM_scenarioEobLine g_NM_scenarioDebugEntries 

  # when newFileP == 1, text does not have to be cleared since
  # selectScenario destroys and creates a new one
  if {$g_NM_testScenarioName == "vmplTestScenario"} {
    set text "<unspecified>"
  } else {
    set text "$g_NM_testScenarioName"
  }
  if {$g_NM_scenarioScriptModifiedP && \
          ($g_NM_testScenarioName != "<unspecified>")} {
    append text "  \[modified\]"
  }

  # set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
  # put vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set scenarioDir "$env(HOME)/.stanley/"
  if {! $newFileP} {
    set file incVmplTestScenario
  } else {
    set file vmplTestScenario
  }
  set window $g_NM_scenarioDialogRoot
  $window.text&button.h.label config -text $text
  set txt $window.text&button.t.text
  # puts stderr "showScenarioText: txt $txt"
  set textWidth 60

  $txt config -state normal
  set pathName "$scenarioDir$file$g_NM_scenarioExtension"
  
  if {! $newFileP} {
    if {$deleteLineP} {
      set g_NM_scenarioMgrMaxLines \
          [expr {$g_NM_scenarioMgrMaxLines - 1}]
      set g_NM_scenarioNewEditLineNum $g_NM_scenarioCurrentEditLineNum 
    } else {
      # inserted line(s)
      # get number of lines to insert
      set fid [open $pathName r]
      set lineNum $g_NM_scenarioCurrentEditLineNum 
      while {[set charCnt [gets $fid textLine]] != -1} {
        # puts stderr "showScenarioText: (insert) textLine `$textLine' lineNum_$lineNum"
        incr lineNum
      }
      close $fid
      set newLineCnt [expr {$lineNum - $g_NM_scenarioCurrentEditLineNum}] 
      set g_NM_scenarioMgrMaxLines \
          [expr {$g_NM_scenarioMgrMaxLines + $newLineCnt}]
      set g_NM_scenarioNewEditLineNum [expr { $g_NM_scenarioCurrentEditLineNum + \
                                                  $newLineCnt }]
    }

    # re-number tags of all lines below insertion
    set oldLineNum $g_NM_scenarioCurrentEditLineNum 
    if {$deleteLineP} {
      set newLineNum [expr { $g_NM_scenarioCurrentEditLineNum - 1}]
    } else {
      set newLineNum $lineNum
    }
    renumberTags $txt $oldLineNum $newLineNum $deleteLineP 
    renumberBPTags $oldLineNum $newLineNum $deleteLineP 
  }

  if {$newFileP} {
    set lineNum 1
    set index end
    set spaceAppendIndex end
    set textAppendIndex end
  } else {
    set g_NM_scenarioScriptModifiedP 1
    set lineNum $g_NM_scenarioCurrentEditLineNum
    set insertIndex $g_NM_scenarioCurrentEditLineNum 
    set index $insertIndex.0
    set spaceAppendIndex $insertIndex.2
    set textAppendIndex $insertIndex.3
  }

  set txtFont [lindex [$txt config -font] 4]
  if {$deleteLineP} {
    $txt delete $index "$insertIndex.end +1 char"
  } else {
    set fid [open $pathName r]
    # blank lines are not returned by gets -- ($textLine != "") is really not needed
    while {[set charCnt [gets $fid textLine]] != -1} {
      # puts stderr "showScenarioText: textLine `$textLine' lineNum_$lineNum"
      if {[regexp "//" $textLine]} {
        set tag "commentNum_$lineNum"
        $txt insert $index "$textLine\n" $tag 
        $txt tag bind $tag <Enter> "scenarioMgrWarning \"set edit marker\""
        $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""
        # puts stderr "comment textLine `$textLine' lineNum_$lineNum"
      } elseif {[string range $textLine 0 9] == "breakpoint"} {
        # convert old break point tokens to new scheme
        lappend g_NM_scenarioDebugEntries "breakPoint_$lineNum"
        incr lineNum -1
        if {($g_NM_testScenarioName != "<unspecified>") && \
                (! [regexp "\\\[modified\\\]" $g_NM_testScenarioName])} {
          set text "$g_NM_testScenarioName  \[modified\]"
          $window.text&button.h.label config -text $text
          $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
              "Save Scenario ..." -state normal
        }
      } elseif {($textLine != "") && \
                    ([string range $textLine 0 8] != "scenario ")} {
        if {! [string match $textLine $g_NM_scenarioEobLine]} {
          set tag "breakPoint_$lineNum"
          set breakPointState "off"
          if {[lsearch -exact $g_NM_scenarioDebugEntries $tag] >= 0} {
            set breakPointState "on"
          }
          $txt insert $index "BP" [list $tag $breakPointState]
          if {$breakPointState == "on"} {
            $txt tag configure $tag \
                -background [preferred StanleyScenarioMgrBreakPointColor]
            $txt tag bind $tag <Enter> "scenarioMgrWarning \"unset break point\""
            $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""

          } else {
            $txt tag bind $tag <Enter> "scenarioMgrWarning \"set break point\""
            $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""
          }
          $txt insert $spaceAppendIndex " " 
        }
        # eob line must be tagged for edit marker
        set tag "lineNum_$lineNum"
        $txt insert $textAppendIndex "$textLine\n" $tag
        $txt tag bind $tag <Enter> "scenarioMgrWarning \"set edit marker\""
        $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""
        # puts stderr "exec textLine `$textLine' lineNum_$lineNum"
      } else {
        set tag ""
        $txt insert $index "$textLine\n" 
        # puts stderr "other textLine `$textLine'"
      }
      if {[regexp "lineNum_" $tag]} {
        set firstP 1
        foreach token $textLine {
          if {$firstP} {
            set indentToken $token
            append indentToken "    "
            set indentTokenLen [string length $indentToken]
            set firstP 0
          }
          set tokenLen [string length $token]
          if {($indentTokenLen + $tokenLen) > $textWidth} {
            set textWidth [expr {$indentTokenLen + $tokenLen}]
          }
        }
        # wrap and indent lineNum_$lineNum var=val tokens
        set indentPixels [font measure $txtFont $indentToken]
        $txt tag configure lineNum_$lineNum -lmargin2 $indentPixels
      } else {
        # comment and other lines
        if {[string length $textLine] > $textWidth} {
          set textWidth [string length $textLine]
        }
      }
      # puts stderr "textLine $textLine textWidth $textWidth"
      incr lineNum 
    }
    close $fid
  }

  if {$newFileP} {
    set g_NM_scenarioMgrMaxLines [expr {$lineNum - 1}]
    # keep tokens on the same line 
    $txt config -width [expr {$textWidth + 1}]
  }

  # skip over comment lines to get to a command line
  set tag "lineNum_$g_NM_scenarioExecLineNum"
  set tagRanges ""
  while {($g_NM_scenarioExecLineNum <= $g_NM_scenarioMgrMaxLines) && \
             ([set tagRanges [$txt tag ranges $tag]] == "")} {
    incr g_NM_scenarioExecLineNum
    set tag "lineNum_$g_NM_scenarioExecLineNum"
  }
  if {$tagRanges == ""} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "showScenario: invalid scenario"  error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  # puts stderr "showScenario: tags [.scenario.text&button.t.text tag names]"
  # scroll to current exec line - in case window was dismissed in between steps
  # puts stderr "showScenarioText: tag $tag names [$txt tag names]"
  # puts stderr "showScenarioText: g_NM_scenarioExecLineNum $g_NM_scenarioExecLineNum"
  $txt tag configure $tag -background [preferred StanleyScenarioMgrExecColor]
  set g_NM_currentScenarioExecTag $tag
  # do not move to exec line
  # $txt see [lindex [$txt tag ranges $tag] 0]

  $txt config -state disabled

  set displayP 1
  moveScenarioEditMarker $displayP

  # force edit line to be shown
  $txt see "${g_NM_scenarioCurrentEditLineNum}.0"
}


## renumber text line tags for insertion or deletion of lines.
## "..end +1 char" includes the \n, so that the green and yellow lines
## are moved properly
## 10aug01 wmt: new
proc renumberTags { txt oldLineNum newLineNum deleteLineP } {
  global g_NM_scenarioMgrMaxLines g_NM_scenarioEobLine
  global g_NM_scenarioDebugEntries 

  # puts stderr "oldLineNum $oldLineNum newLineNum $newLineNum "
  # puts stderr "tag names [$txt tag names]"
  set firstP 1
  while {$newLineNum <= $g_NM_scenarioMgrMaxLines } {
    set tagNames [$txt tag names ${oldLineNum}.0]
    if {$deleteLineP && $firstP} {
      # skip line to be deleted
      if {[lsearch -exact $tagNames "on"] >= 0} {
        $txt tag configure "breakPoint_$oldLineNum" -background white
      }
      set firstP 0
    } else {
      # BP chars
      if {[lsearch -exact $tagNames "breakPoint_$oldLineNum"] >= 0} {
        # puts stderr " [$txt get ${oldLineNum}.0 ${oldLineNum}.end]"
        # puts stderr "oldLineNum $oldLineNum tagNames $tagNames"
        if {[lsearch -exact $tagNames "on"] >= 0} {
          $txt tag configure "breakPoint_$oldLineNum" -background white
        }
        $txt tag remove "breakPoint_$oldLineNum" "$oldLineNum.0" "$oldLineNum.2"
        
        $txt tag add "breakPoint_$newLineNum" "$oldLineNum.0" "$oldLineNum.2"
        if {[lsearch -exact $tagNames "on"] >= 0} {
          $txt tag configure "breakPoint_$newLineNum" \
              -background [preferred StanleyScenarioMgrBreakPointColor]
        }
        # set tagNames [$txt tag names ${oldLineNum}.0]
        # puts stderr "newLineNum $newLineNum tagNames $tagNames"
      }
      # comment lines
      if {[lsearch -exact $tagNames "commentNum_$oldLineNum"] >= 0} {
        # puts stderr " [$txt get ${oldLineNum}.0 ${oldLineNum}.end]"
        # puts stderr "oldLineNum $oldLineNum tagNames $tagNames"
        $txt tag remove "commentNum_$oldLineNum" "$oldLineNum.0" \
            "$oldLineNum.end +1 char"
        
        $txt tag add "commentNum_$newLineNum" "$oldLineNum.0" \
            "$oldLineNum.end +1 char"
        # set tagNames [$txt tag names ${oldLineNum}.0]
        # puts stderr "newLineNum $newLineNum tagNames $tagNames"
      }
      # end-of-buffer line
      set textLine [$txt get $oldLineNum.0 $oldLineNum.end]
      if {([lsearch -exact $tagNames "lineNum_$oldLineNum"] >= 0) && \
              ([string match $textLine $g_NM_scenarioEobLine])} {
        # puts stderr " [$txt get ${oldLineNum}.0 ${oldLineNum}.end]"
        # puts stderr "oldLineNum $oldLineNum tagNames $tagNames"
        $txt tag remove "lineNum_$oldLineNum" "$oldLineNum.0" "$oldLineNum.end +1 char"
        
        $txt tag add "lineNum_$newLineNum" "$oldLineNum.0" "$oldLineNum.end +1 char"
        # set tagNames [$txt tag names ${oldLineNum}.0]
        # puts stderr "newLineNum $newLineNum tagNames $tagNames"
      }

      set tagNames [$txt tag names ${oldLineNum}.3]
      if {([lsearch -exact $tagNames "lineNum_$oldLineNum"] >= 0) && \
              (! [string match $textLine $g_NM_scenarioEobLine])} {
        # puts stderr " [$txt get ${newLineNum}.0 ${newLineNum}.end]"
        # puts stderr "oldLineNum $oldLineNum tagNames $tagNames"
        $txt tag remove "lineNum_$oldLineNum" "$oldLineNum.3" "$oldLineNum.end +1 char"
        
        $txt tag add "lineNum_$newLineNum" "$oldLineNum.3" "$oldLineNum.end +1 char"
        # set tagNames [$txt tag names ${oldLineNum}.3]
        # puts stderr "newLineNum $newLineNum tagNames $tagNames"
      }
    }
    incr oldLineNum; incr newLineNum 
  }
  # puts stderr "tag names [$txt tag names]"
}


## renumber breakpoint tags in current list
## 21aug01 wmt: new
proc renumberBPTags { oldLineNum newLineNum deleteLineP } {
  global g_NM_scenarioDebugEntries 

  set breakpointTagList $g_NM_scenarioDebugEntries 
  if {$deleteLineP} {
    set newTaglist {}
    foreach tag $breakpointTagList {
      # remove deleted bp
      if {! [regexp "breakPoint_$oldLineNum" $tag]} {
        # renumber bp's after deleted one
        set lineNum [lindex [split $tag "_"] 1]
        if {$lineNum > $oldLineNum} {
          lappend newTaglist "breakPoint_[expr {$lineNum - 1}]"
        } else {
          lappend newTaglist $tag
        }
      }
    }
    set breakpointTagList $newTaglist 
  } else {
    set newTaglist {}
    set delta [expr { $newLineNum - $oldLineNum }]
    foreach tag $breakpointTagList {
      # renumber bp's after inserted lines
      set lineNum [lindex [split $tag "_"] 1]
      if {$lineNum >= $oldLineNum} {
        lappend newTaglist "breakPoint_[expr {$lineNum + $delta}]"
      } else {
        lappend newTaglist $tag
      }
    }
    set breakpointTagList $newTaglist 
  }
  set g_NM_scenarioDebugEntries $breakpointTagList
}


## position the edit marker line
## 28sep00 wmt
proc moveScenarioEditMarker { displayP {x -1} {y -1} } {
  global g_NM_scenarioCurrentEditLineNum g_NM_scenarioNewEditLineNum
  global g_NM_scenarioDialogRoot g_NM_currentScenarioExecTag
  global g_NM_scenarioExecLineNum g_NM_scenarioDebugEntries
  global g_NM_scenarioScriptDbgModifiedP 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "moveScenarioEditMarker: `$backtrace'"
  set txt $g_NM_scenarioDialogRoot.text&button.t.text
  # puts stderr "\nmoveScenarioEditMarker: x $x y $y"
  if {$y != -1} {
    # this is called by Mouse-L binding 
    # determine g_NM_scenarioNewEditLineNum
    # or breakpoint set/unset
    set lineIndex [$txt index "@$x,$y"]
    set lineNum [lindex [split $lineIndex "."] 0]
    set tagList [$txt tag names $lineIndex]
    # puts stderr "moveScenarioEditMarker: x $x y $y lineIndex $lineIndex lineNum $lineNum"
    # puts stderr "     tagList $tagList"
    set maybeEditTag ""
    set resetState [lindex [$g_NM_scenarioDialogRoot.text&button.b.reset config -state] 4]
    if {($resetState == "disabled") || \
            (($resetState == "normal") && ($lineNum > $g_NM_scenarioExecLineNum))} {
      # is this line a comment line ?
      foreach tag $tagList {
        if {[regexp "commentNum" $tag]} {
          set g_NM_scenarioNewEditLineNum $lineNum
          set maybeEditTag $tag
          break
        }
      }
    }
    # puts stderr "moveScenarioEditMarker: lineNum $lineNum tagList $tagList"
    if {$maybeEditTag == ""} {
      foreach tag $tagList {
        if {[regexp "lineNum" $tag]} {
          if {$lineNum < $g_NM_scenarioExecLineNum} {
            # can only edit downstream of exec line
            bell
            # puts stderr "bell"
            return
          } else {
            set g_NM_scenarioNewEditLineNum $lineNum
            break
          }
        } elseif {[regexp "breakPoint" $tag]} {
          # set break points anywhere in scenario -- those prior to exec-line
          # will only be executed if scenario is saved and run again
          if {[lsearch -exact $tagList "off"] >= 0} {
            # set break point
            $txt tag configure $tag \
                -background [preferred StanleyScenarioMgrBreakPointColor]
            $txt tag remove "off" "$lineNum.0" "$lineNum.2"
            $txt tag add "on" "$lineNum.0" "$lineNum.2"
            scenarioMgrWarning ""
            $txt tag bind $tag <Enter> "scenarioMgrWarning \"unset break point\""
            $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""
            lappend g_NM_scenarioDebugEntries $tag
            # puts stderr "lineNum $lineNum g_NM_scenarioDebugEntries $g_NM_scenarioDebugEntries"
          } elseif {[lsearch -exact $tagList "on"] >= 0} {
            # unset break point
            $txt tag configure $tag -background white
            $txt tag remove "on" "$lineNum.0" "$lineNum.2"
            $txt tag add "off" "$lineNum.0" "$lineNum.2"
            scenarioMgrWarning ""
            $txt tag bind $tag <Enter> "scenarioMgrWarning \"set break point\""
            $txt tag bind $tag <Leave> "scenarioMgrWarning \"\""
            set g_NM_scenarioDebugEntries [ldelete $g_NM_scenarioDebugEntries $tag]
          }
          set g_NM_scenarioScriptDbgModifiedP 1
          return
        }
      }
    }
    # puts stderr " g_NM_scenarioNewEditLineNum $g_NM_scenarioNewEditLineNum"
  }
  # set new edit line
  $txt config -state normal
    # use char 3, not 0 -- to skip over BP token
  set tagList [$txt tag names "${g_NM_scenarioCurrentEditLineNum}.3"]
  # puts stderr "moveScenarioEditMarker: g_NM_scenarioCurrentEditLineNum $g_NM_scenarioCurrentEditLineNum tagList $tagList "
  set currentEditTag ""
  foreach tag $tagList {
    if {([regexp "lineNum" $tag]) || ([regexp "commentNum" $tag])} {
      set currentEditTag $tag
      break
    }
  }
  # puts stderr "moveScenarioEditMarker: currentEditTag $currentEditTag g_NM_currentScenarioExecTag $g_NM_currentScenarioExecTag "
  if {$currentEditTag == ""} {
    return
  }
  if {[string match $currentEditTag $g_NM_currentScenarioExecTag]} {
    # restore green exec line
    $txt tag configure $g_NM_currentScenarioExecTag \
        -background [preferred StanleyScenarioMgrExecColor]
  } else {
    # puts stderr "showScenario: currentEditTag $currentEditTag"
    $txt tag configure $currentEditTag -background white
  }

  # do not color edit mark if being pushed by exec marker (displayP = 0)
  if {$displayP} {
    # use char 3, not 0 -- to skip over BP token
    set tagList [$txt tag names "${g_NM_scenarioNewEditLineNum}.3"]
    set newEditTag ""
    foreach tag $tagList {
      if {([regexp "lineNum" $tag]) || ([regexp "commentNum" $tag])} {
        set newEditTag $tag
        break
      }
    }
    # puts stderr "moveScenarioEditMarker: newEditTag $newEditTag"
    $txt tag configure $newEditTag -background [preferred StanleyScenarioMgrEditColor]
  }
  # puts stderr "moveScenarioEditMarker: g_NM_scenarioNewEditLineNum $g_NM_scenarioNewEditLineNum g_NM_scenarioCurrentEditLineNum $g_NM_scenarioCurrentEditLineNum "
  set g_NM_scenarioCurrentEditLineNum $g_NM_scenarioNewEditLineNum

  $txt config -state disabled
}


## move line marker to progress/assign/fc directives
## 03aug00 wmt
proc moveScenarioExecMarker { } {
  global g_NM_scenarioDialogRoot g_NM_currentScenarioExecTag
  global g_NM_scenarioEobLine g_NM_scenarioMgrMaxLines 
  global g_NM_testScenarioName g_NM_scenarioExecLineNum 
  global g_NM_scenarioCurrentEditLineNum g_NM_scenarioNewEditLineNum

  # puts stderr "moveScenarioExecMarker: g_NM_scenarioExecLineNum $g_NM_scenarioExecLineNum g_NM_scenarioMgrMaxLines $g_NM_scenarioMgrMaxLines"
  set scenarioWindow $g_NM_scenarioDialogRoot 
  if {[winfo exists $scenarioWindow]} {
    set txt $scenarioWindow.text&button.t.text
    # disable comment lines above previous exec line, in order to
    # disable header comment line - those above first exec line
    if {$g_NM_scenarioExecLineNum < 25} {
      for {set num 2} {$num < [expr {$g_NM_scenarioExecLineNum - 1}]} {incr num} {
        # puts stderr "\nmoveScenarioExecMarker: num $num tags [$txt tag names $num.0] "
        foreach tag [$txt tag names "$num.0"] {
          if {[regexp "commentNum" $tag]} {
            $txt tag bind $tag <Enter> "scenarioMgrWarning \"\""
          }
        }
      }
    }
    # disable previous line
    $txt tag configure $g_NM_currentScenarioExecTag -background white
    # disable "set edit marker"
    $txt tag bind $g_NM_currentScenarioExecTag <Enter> "scenarioMgrWarning \"\""
    # disable "set break point"
    ## allow setting break points prior to exec line
#     $txt tag bind "breakPoint_[expr {$g_NM_scenarioExecLineNum - 1}]" \
#         <Enter> "scenarioMgrWarning \"\""

    set scenarioTag "lineNum_$g_NM_scenarioExecLineNum"
    set tagRanges ""
    # skip over comment lines to get to a command line
    while {($g_NM_scenarioExecLineNum <= $g_NM_scenarioMgrMaxLines) && \
               ([set tagRanges [$txt tag ranges $scenarioTag]] == "")} {
      # puts stderr "   tagRanges $tagRanges scenarioTag $scenarioTag "
      incr g_NM_scenarioExecLineNum
      set scenarioTag "lineNum_$g_NM_scenarioExecLineNum"
    }
    if {$tagRanges == ""} {
      puts stderr "moveScenarioExecMarker: no next line"
      return
    }
    # puts stderr "moveScenarioExecMarker: tag `$scenarioTag' prev tag `$g_NM_currentScenarioExecTag'" 
    # puts stderr "moveScenarioExecMarker: names [$txt tag names]"
    if {[lsearch -exact [$txt tag names] $scenarioTag] >= 0} {
      # do not mark eob text line
      set startRange [lindex [$txt tag ranges $scenarioTag] 0]
      set lineNum [lindex [split $startRange "."] 0]
      set text [$txt get "${lineNum}.0" "${lineNum}.end"]
      # puts stderr "$scenarioTag $scenarioTag text $text"
      set editMarkDisplayP 1
      if {! [string match $text $g_NM_scenarioEobLine]} {
        $txt tag configure $scenarioTag -background [preferred StanleyScenarioMgrExecColor]
        set editMarkDisplayP 0
      }
      # this is faster, but put line at bottom of window, rather than in middle
      # $txt see ${scenarioTag}.first
      scrollTextTagToMiddle $txt $scenarioTag

      # set the tag, even tho it may be eob line - moveScenarioEditMarker needs it
      set g_NM_currentScenarioExecTag $scenarioTag
      # if we are past the edit line, move it to be equal to the exec line
      if {$g_NM_scenarioExecLineNum > $g_NM_scenarioCurrentEditLineNum} {
        set g_NM_scenarioNewEditLineNum $g_NM_scenarioExecLineNum
        moveScenarioEditMarker $editMarkDisplayP
      }
    }
    # this is very slow -- do not use
    # raise $scenarioWindow
    update
  }
}


## save manual Step forms to create scenario file
## 18jan00 wmt: new
proc vmplTestSaveScenario { } {
  global g_NM_scenarioNameRootWindow g_NM_readableJavaTokenRegexp
  global g_NM_testScenarioName g_NM_scenarioSaveCancelP 

  set g_NM_scenarioSaveCancelP 0
  set dialogW $g_NM_scenarioNameRootWindow  
  toplevel $dialogW -class Dialog
  wm title $dialogW "Scenario Name"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command "vmplTestSaveScenarioDoit $dialogW"
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "set g_NM_scenarioSaveCancelP 1; destroy $dialogW" 
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set widget $dialogW.fName
  set defaultName $g_NM_testScenarioName
  if {$defaultName == "<unspecified>"} {
    set defaultName ""
  }
  mkEntryWidget $widget "" " Name" $defaultName normal
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  focus $dialogW.fName.fentry.entry
  keepDialogOnScreen $dialogW 

  if [winfo exists $dialogW] {
    tkwait window $dialogW
  }
}


## read users input for scenario file name
## and create the file from accumulated cmds
## 18jan00 wmt: new
proc vmplTestSaveScenarioDoit { dialogW } {
  global g_NM_selectedTestModule g_NM_scenarioEobLine 
  global g_NM_scenarioExtension g_NM_selectedTestScope
  global g_NM_stepCommandsMonitors g_NM_scenarioDialogRoot
  global g_NM_selectedTestScope g_NM_scenarioScriptModifiedP
  global g_NM_testScenarioName LOGNAME STANLEY_SUPERUSER env 

  set className $g_NM_selectedTestScope
  set canvasRootId 0
  set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
  set scenarioName [$dialogW.fName.fentry.entry get]
  set scenarioName [string trim $scenarioName " "] 
  if {! [entryValueErrorCheck Name "(javaToken)" $scenarioName]} {
    return
  }
  # manual mode multi-step scenario file
  if {[string match $scenarioName "vmplTestScenario"]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "`vmplTestScenario' is a reserved scenario name" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  # single step scenario file created from multi-step scenario file
  if {[string match $scenarioName "stanleyStep"]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "`stanleyStep' is a reserved scenario name" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  set defscenarioFilename "$scenarioDir/$scenarioName$g_NM_scenarioExtension"
  # do not allow modificatio of stanley-sample-user-files scenarios
  # this allows user to save a modified read-only file under a different
  # name, but then they cannot modify the modified file - forget for now
#   if {(! [string match $LOGNAME $STANLEY_SUPERUSER]) && \
#           [regexp "stanley-sample-user-files" $scenarioDir] && \
#           [string match $scenarioName $g_NM_testScenarioName]} {
#     set dialogList [list tk_dialog .d "ERROR" \
#                         "$scenarioName is a read-only file" error \
#                         0 {DISMISS}]
#     eval $dialogList
#     return
#   }
  if {[file exists $defscenarioFilename]} {
    set msg "Scenario file `$scenarioName' exists -- continue?"
    set dialogList [list tk_dialog .d "WARNING" $msg warning 0 {YES} {NO}]
    set retValue [eval $dialogList]
    if {$retValue == 1} {
      return
    }
  }
  destroy $dialogW 

  set g_NM_testScenarioName $scenarioName 
  set scenarioFilename "$scenarioDir/$scenarioName$g_NM_scenarioExtension"
  puts stderr "Wrote user specified scenario output to"
  puts stderr "    $scenarioFilename"
  set fidOut [open $scenarioFilename w]

  # put vmplTestScenario in user's home dir to prevent
  # multi user conflicts
  set accumScenarioDir "$env(HOME)/.stanley/"
  set accumScenarioPathname ${accumScenarioDir}/vmplTestScenario$g_NM_scenarioExtension
  if {[file exists $accumScenarioPathname]} {
    set fidIn [open $accumScenarioPathname r]
    set firstLineP 1
    while {[gets $fidIn cmd ] != -1} {
      if {$firstLineP} {
        regsub -all "<unspecified>" $cmd $scenarioName tmp; set cmd $tmp
        set firstLineP 0
      }
      if {(! [string match $cmd $g_NM_scenarioEobLine]) && \
              ([string range $cmd 0 9] != "breakpoint")} {
        puts $fidOut $cmd
      }
    }
    close $fidIn
  }
  close $fidOut

  update
  set g_NM_scenarioScriptModifiedP 0
  $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
      "Save Scenario ..." -state disabled
  # update Open Scenario cascade menu
  set scenarioList [getScenariosForClass $className]
  set menuRoot $g_NM_scenarioDialogRoot.menu
  set selectFunction selectScenario
  generateCascadeMenu $menuRoot.file.m open "Open Scenario" $scenarioList \
      $scenarioList $selectFunction normal
  set selectFunction deleteScenario
  generateCascadeMenu $menuRoot.file.m delete "Delete Scenario" $scenarioList \
      $scenarioList $selectFunction normal
  $g_NM_scenarioDialogRoot.text&button.h.label config -text $scenarioName 
}


## delete a scenario file
## 19sep00 wmt
proc deleteScenario { rootName scenarioName } {
  global g_NM_menuStem g_NM_scenarioExtension
  global g_NM_selectedTestScope g_NM_scenarioDialogRoot
  global g_NM_menuStem g_NM_scenarioDebugExtension

  set menuRoot $g_NM_scenarioDialogRoot.menu
  set className $g_NM_selectedTestScope
  set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
  set scenarioFilename "$scenarioDir/$scenarioName$g_NM_scenarioExtension"
  file delete $scenarioFilename 
  set scenarioDbgFilename "$scenarioDir/$scenarioName$g_NM_scenarioDebugExtension"
  file delete $scenarioDbgFilename 
  puts stderr "Deleted scenario file"
  puts stderr "    $scenarioFilename"
  update
  # update Open Scenario cascade menu
  set scenarioList [getScenariosForClass $className]
  set selectFunction selectScenario
  generateCascadeMenu $menuRoot.file.m open "Open Scenario" $scenarioList \
      $scenarioList $selectFunction normal
  set selectFunction deleteScenario
  generateCascadeMenu $menuRoot.file.m delete "Delete Scenario" $scenarioList \
      $scenarioList $selectFunction normal
}


## create a single step scenario script file from a multi-step scenario
## by selecting cmds up to & including next fc or end-of-file
## 09apr00 wmt: new
proc generateScenarioStep { className scenarioName scenarioPathname singleLineP \
                              breakpointPRef stanleyStepOutputRef} {
  upvar $breakpointPRef breakpointP
  upvar $stanleyStepOutputRef stanleyStepOutput
  global g_NM_scenarioExtension env g_NM_scenarioDialogRoot
  global g_NM_scenarioExecLineNum g_NM_scenarioEobLine
  global g_NM_scenarioDebugEntriesSeen g_NM_scenarioPrevSteppingMode
  global g_NM_scenarioSteppingMode g_NM_L2FindCandidatesCmdTypeList

  # puts stderr "\ngenerateScenarioStep: single $singleLineP g_NM_scenarioExecLineNum $g_NM_scenarioExecLineNum "
  # set directory "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]/"
  # put stanleyStep in user's home dir to prevent
  # multi user conflicts
  set directory "$env(HOME)/.stanley/"
  set stepPathname "${directory}stanleyStep$g_NM_scenarioExtension"
  set stanleyStepOutput ""; set selectOutputP 0
  set fid [open $scenarioPathname r]
  set lineNum 0; set cmdCnt 0; set newLineCnt 0
  set breakpointP 0
  set txt $g_NM_scenarioDialogRoot.text&button.t.text
  while {[set charCnt [gets $fid textLine]] != -1} {
    set textLine [string trim $textLine " "]
    # skip to g_NM_scenarioExecLineNum 
    incr lineNum
    # puts stderr "textLine $textLine lineNum $lineNum "
    if {$lineNum >= $g_NM_scenarioExecLineNum} {
      incr newLineCnt
      if {($textLine == "") || ([string range $textLine 0 1] == "//") || \
              ([string range $textLine 0 8] == "scenario ") || \
              [string match $textLine $g_NM_scenarioEobLine]} {
        # skip blank, comment, eob & scenario lines
        if {[string match $textLine $g_NM_scenarioEobLine]} {
          # keep eob line editable
          incr newLineCnt -1
        }
      } else {
        # puts stderr " generateScenarioStep: textLine `$textLine'"
        incr cmdCnt
        set tagList [$txt tag names $lineNum.0]
        # puts stderr "generateScenarioStep: textLine $textLine tagList $tagList prev $g_NM_scenarioPrevSteppingMode cmdCnt $cmdCnt "
        # is there a break point prior to this command
        set maybeBreakPoint ""
        foreach tag $tagList {
          if {[regexp "breakPoint" $tag] && \
                  ([lsearch -exact $g_NM_scenarioDebugEntriesSeen $tag] == -1)} {
            set maybeBreakPoint $tag
          }
        }
        if {$maybeBreakPoint != ""} {
          foreach tag $tagList {
            if {$tag == "on"} {
              lappend g_NM_scenarioDebugEntriesSeen $maybeBreakPoint
              # donot know why I did this -- it causes bp's not to be
              # found by Run, if Step was done first
#               if {(($g_NM_scenarioPrevSteppingMode == "run") && \
#                        ($g_NM_scenarioSteppingMode == "run")) || \
#                       (($g_NM_scenarioPrevSteppingMode == "warp") && \
#                            ($g_NM_scenarioSteppingMode == "warp")) || \
#                       ((($g_NM_scenarioPrevSteppingMode == "step") || \
#                             ($g_NM_scenarioSteppingMode == "step")) && \
#                            ($cmdCnt > 1))} {
#                 # puts stderr "BP BP"
#                 set breakpointP 1
#                 break
#               }
              set breakpointP 1
              break
            }
          }
        }
        if {$breakpointP} {
          break
        } elseif {$singleLineP} {
          # no \n, since this output will be appended by vmplTestStep
          append stanleyStepOutput "$textLine"
          incr lineNum
          break
        } elseif {($textLine == "fc") || \
                  [lsearch -exact $g_NM_L2FindCandidatesCmdTypeList $textLine] >= 0} {
          # found next fc, find-fresh, prune-search, or extend 
          append stanleyStepOutput "$textLine\n"
          # puts stderr "fc  $textLine lineNum $lineNum"
          if {$g_NM_scenarioSteppingMode != "warp"} {
            incr lineNum
            break
          }
        } else {
          append stanleyStepOutput "$textLine\n"
          # puts stderr "else $textLine lineNum $lineNum "
        }
      }
    }
    # puts stderr "   w newLineCnt $newLineCnt cmdCnt $cmdCnt lineNum $lineNum "
    # puts stderr "     textLine `$textLine' stanleyStepOutput `$stanleyStepOutput'"
  }
  close $fid
  # puts stderr "   e newLineCnt $newLineCnt cmdCnt $cmdCnt lineNum $lineNum "
  # puts stderr "     textLine `$textLine' stanleyStepOutput `$stanleyStepOutput'"

  if {$g_NM_scenarioSteppingMode == "warp"} {
    set g_NM_scenarioExecLineNum $lineNum
    # puts stderr "generateScenarioStep: g_NM_scenarioExecLineNum $g_NM_scenarioExecLineNum"
  }
  set fid [open $stepPathname w] 
  puts $fid $stanleyStepOutput 
  close $fid
  return $cmdCnt
}


## get testing scenario files
## 19sep00 wmt
proc getScenariosForClass { className } {
  global g_NM_scenarioExtension 
  
  set scenarioList {}
  set pwd [pwd]
  set scenarioDir "[preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]"
  cd $scenarioDir
  set files [glob -nocomplain *$g_NM_scenarioExtension]
  foreach file $files {
    if {($file != "stanleyStep$g_NM_scenarioExtension") && \
            ($file != "vmplTestScenario$g_NM_scenarioExtension")} {
      set fid [open $file r]
      set notFoundP 1
      while {[gets $fid line] >= 0} {
        if {[string range $line 0 8] == "scenario "} {
          if {[string match [lindex $line 2] $className]} {
            # puts stderr "line [lindex $line 2] className $className"
            lappend scenarioList [file rootname $file]
          }
          set notFoundP 0
          break
        } elseif {[string range $line 0 1] == "//"} {
          ; # do nothing skip comment lines
        } else {
          # not a comment line and not a scenario line
          break
        }
      }
      close $fid
      if {$notFoundP} {
        puts stderr "`scenario <scenario-name> <module-name>' not found in"
        puts stderr "    ${scenarioDir}/$file"
      }
    }
  }
  cd $pwd
  # puts stderr "getScenariosForClass: scenarioList $scenarioList len [llength $scenarioList]"
  return $scenarioList
}


## toggle boolean for g_NM_propsWarnMsgsP
## 30sep00 wmt: new
proc togglePropsWarnMsgsP { { toggleP 1 } } { 
  global g_NM_propsWarnMsgsP g_NM_scenarioDialogRoot

  if {$toggleP} {
    set g_NM_propsWarnMsgsP [expr {[incr g_NM_propsWarnMsgsP] % 2}]
  }
  # puts "togglePropsWarnMsgsP: g_NM_propsWarnMsgsP $g_NM_propsWarnMsgsP"
  switch $g_NM_propsWarnMsgsP {
    0 {
      $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure "Proposition Logging On" \
          -state normal
      $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure "Proposition Logging Off" \
          -state disabled
    }
    1 {
      $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure "Proposition Logging On" \
          -state disabled 
      $g_NM_scenarioDialogRoot.menu.edit.m entryconfigure "Proposition Logging Off" \
          -state normal
    }
  }   
}


## disable scenario selection and step/run accelerators
## bewteen fc and newState commands, since the user
## must use the Candidates Mgr to select which candidate
## to install in L2 - this then triggers newState
## 11jul00 wmt
proc scenarioManagerDisable { } {
  global g_NM_menuStem g_NM_scenarioDialogRoot 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "scenarioManagerDisable: `$backtrace'"
  # puts stderr "scenarioManagerDisable "
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
        "Open Scenario" -state disabled

    $g_NM_scenarioDialogRoot.text&button.b.single config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.step config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.run config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.warp config -state disabled
    update
  }
}


proc scenarioManagerEnable { caller } {
  global g_NM_menuStem g_NM_scenarioDialogRoot
  global g_NM_commandLineLockP 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "scenarioManagerEnable: `$backtrace'"
  # puts stderr "scenarioManagerEnable "
  if {[winfo exists $g_NM_scenarioDialogRoot] && \
          (! $g_NM_commandLineLockP)} {
    $g_NM_scenarioDialogRoot.menu.file.m entryconfigure \
        "Open Scenario" -state normal
    $g_NM_scenarioDialogRoot.text&button.b.single config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.step config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.run config -state normal
    $g_NM_scenarioDialogRoot.text&button.b.warp config -state normal
    update
  }
}


## attention/warning msg for scenario mgr
## 24oct00 wmt: new
proc scenarioMgrWarning { msg {severity 0} {canvasRootId 0}} {
  global g_NM_scenarioDialogRoot g_NM_inhibitPirWarningP 

  # keep warning msg displayed even though mouse is over a
  # connection or a node, when say, a menu item like
  # Reset All Definition Instances
  # puts stderr "scenarioMgrWarning: g_NM_inhibitPirWarningP $g_NM_inhibitPirWarningP msg $msg"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "scenarioMgrWarning: `$backtrace'"
  if {$g_NM_inhibitPirWarningP} {
    return
  }
  # puts stderr "\nscenarioMgrWarning: msg `$msg'"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "scenarioMgrWarning: `$backtrace'"
  set canvasRoot [getCanvasRoot $canvasRootId]
  set widgetPath1 $g_NM_scenarioDialogRoot.text&button.w.warn
  # $widgetPath1 config -text [truncateLabelText $widgetPath1 $msg]
  $widgetPath1 config -text $msg
  if {$severity} {
    $widgetPath1  config \
        -bg [preferred StanleyAttentionWarningBgColor] \
        -fg [preferred StanleyAttentionWarningFgColor] 
  } else {
    $widgetPath1  config \
        -bg [preferred StanleyAttentionBgColor] \
        -fg [preferred StanleyAttentionFgColor]
  }
  update
}


## allow user to insert comment before yellow edit line
## 03apr01 wmt: new
proc insertScenarioComment { } {
  global g_NM_scenarioCommentRootWindow 

  set entryWidth 60
  set dialogW $g_NM_scenarioCommentRootWindow  
  toplevel $dialogW -class Dialog
  wm title $dialogW "Scenario Comment"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command "insertScenarioCommentDoit $dialogW"
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "destroy $dialogW" 
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set widget $dialogW.fComment
  mkEntryWidget $widget "" "" "" normal $entryWidth
  focus $dialogW.fComment.fentry.entry
  keepDialogOnScreen $dialogW 

  if [winfo exists $dialogW] {
    tkwait window $dialogW
  }
}



## 03apr01 wmt: new
proc insertScenarioCommentDoit { dialogW } {
  global g_NM_stepCommandsMonitors 

  set scenarioComment [$dialogW.fComment.fentry.entry get]
  set scenarioComment [string trim $scenarioComment " "] 
  set scenarioComment [string trimleft $scenarioComment "/"] 

  set scenarioName ""
  lappend g_NM_stepCommandsMonitors [list comment "// $scenarioComment"]
  addToScenarioFile $scenarioName
  destroy $dialogW
}


## save scenario debug file
## 06apr01 wmt: new
proc saveScenarioDebugFile { {silentP 0} } {
  global g_NM_scenarioDebugExtension g_NM_testScenarioName
  global g_NM_scenarioDebugEntries g_NM_scenarioScriptDbgModifiedP

  if {$g_NM_scenarioScriptDbgModifiedP} {
    set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
    set scenarioDbgPathname "$scenarioDir/$g_NM_testScenarioName$g_NM_scenarioDebugExtension"
    set dbgEntries [lsort -ascii $g_NM_scenarioDebugEntries]
    if {! $silentP} {
      puts stderr "\nWriting $scenarioDbgPathname"
    }
    set fid [open $scenarioDbgPathname w]
    foreach entry $dbgEntries {
      puts $fid $entry
    }
    close $fid
    set g_NM_scenarioScriptDbgModifiedP 0
  }
}


## return scenario debug file entries
## 06apr01 wmt: new
proc getScenarioDebugEntries { } {
  global g_NM_scenarioDebugExtension g_NM_testScenarioName

  set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
  set scenarioDbgPathname "$scenarioDir/$g_NM_testScenarioName$g_NM_scenarioDebugExtension"
  set dbgEntries {}
  if {[file exists $scenarioDbgPathname]} {
    set fid [open $scenarioDbgPathname r]
    while {[gets $fid line] >= 0} {
      lappend dbgEntries $line
    }
    close $fid
  }
  return $dbgEntries
}













  








