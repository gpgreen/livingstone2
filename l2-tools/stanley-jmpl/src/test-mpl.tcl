# $Id: test-mpl.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## test-mpl.tcl => handle Test menu selections


## select a module, either root or lower to be the scope
## of modules to be compiled.  its module children and
## itself will be eligible for execution
## set user selection and update legend
## 19sep97 wmt: new
proc selectTestScope { rootName choice {overrideP 0} } {
  global g_NM_selectedTestScope g_NM_rootInstanceName
  global g_NM_testScenarioName g_NM_menuStem
  global STANLEY_BIN_DIR CORBA_DIR g_NM_vmplTestModeP
  global g_NM_selectedTestScopeRoot env 
  global g_NM_freshCommandLineP g_NM_acceleratorStem
  global g_NM_scenarioDialogRoot g_NM_generatedMPLExtension
  global g_NM_jmplCompilerExtension g_NM_inhibitPirWarningP
  global g_NM_scenarioDialogRoot g_NM_instantiateTestModuleP
  global g_NM_selectTestScopeCalledP g_NM_toolsL2ViewerP 
  global g_NM_win32P 

  # allow stuck attention line msgs to be erased
  set g_NM_inhibitPirWarningP 0
  # ensure that current work is saved
  if {[save_dialog]} {
    return 
  }
  # reset flag in case it is left set
  set g_NM_instantiateTestModuleP 0
  set g_NM_selectedTestScopeRoot $rootName 
  set g_NM_selectedTestScope $choice

  set menuRoot .master.$g_NM_menuStem
  set acceleratorRoot .master.$g_NM_acceleratorStem

  # if compile has been successful, also enable Load & Go
  jmplCompilationDependentFileNames moduleName modulePathname 
  # for stanley-sample-user-files workspace, write .xmpl file
  # into users stanley dir, so that non-group writable umask
  # will not cause a problem for the next user
  if {[preferred projectId] == "stanley-sample-user-files"} {
    set outputPathname "$env(HOME)/.stanley/"
    append outputPathname [file rootname [file tail $modulePathname]]
  } else {
    set outputPathname [file rootname $modulePathname]
  }
  append outputPathname $g_NM_jmplCompilerExtension
  # puts stderr "selectTestScope: outputPathname $outputPathname"
  set loadGoState normal; set compileState disabled
  # always check compile/load&go status, regardless of g_NM_schematicMode
  if {[file exists $outputPathname]} {
    set compiledFileTime [file mtime $outputPathname]
    set jmplPathnameList [jmplCompilationDependentPathnameList]
    # puts stderr "selectTestScope: $outputPathname [file mtime $outputPathname] "
    foreach pathString $jmplPathnameList {
      # puts stderr "selectTestScope: $pathString [file mtime $pathString] "
      if {[expr {[file mtime $pathString] > $compiledFileTime}]} {
        set loadGoState disabled; set compileState normal
        break
      }
    }
  } else {
    set loadGoState disabled; set compileState normal
  }

  $menuRoot.test.m entryconfigure \
      "Compile" -state $compileState 
  $menuRoot.test.m entryconfigure \
      "Load & Go" -state $loadGoState 
  #     $menuRoot.test.m entryconfigure \
      #         "Truth Table" -state disabled
  $menuRoot.test.m entryconfigure \
      "Write IDD" -state disabled
  $menuRoot.test.m entryconfigure \
      "Clean" -state normal 

  .master.$g_NM_menuStem.file.m entryconfigure "Print Definition" \
      -state disabled
  # so user cannot delete the component/module they are testing
  .master.$g_NM_menuStem.file.m entryconfigure "Delete Definition" \
      -state disabled 
  # make sure that all pull-down menu operations are "read-only"
  .master.$g_NM_menuStem.edit.m entryconfigure "Header" \
      -state disabled 
  .master.$g_NM_menuStem.edit.m entryconfigure "Instantiate" \
      -state disabled 
  .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding On" \
      -state disabled 
  .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding Off"  \
      -state disabled 

  if {((! $g_NM_freshCommandLineP) || $overrideP) && (! $g_NM_toolsL2ViewerP)} {
    # reset L2/L2tools - clear Candidate Mgr
    resetL2toolsJNIandL2
  }

  # remove scenario text dialog, if present
  destroyScenarioManager  
  set g_NM_testScenarioName "<unspecified>"
  # clear canvas
  set reinit 1
  set g_NM_vmplTestModeP 1
  set g_NM_selectTestScopeCalledP 1
  initialize_graph $reinit
  .master.canvas.root.c configure -bg [preferred StanleyTestCanvasBackgroundColor]
  $acceleratorRoot.canvas_back.arrow config -state disabled 
  $acceleratorRoot.canvas_back.label config -state disabled 
  balloonhelp $acceleratorRoot.canvas_back.label -side right ""
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    $g_NM_scenarioDialogRoot.text&button.b.single config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.step config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.run config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.warp config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
  } 
  # put scope name in legend
  displayDotWindowTitle
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
    update
  }
}


# write a defsystem file for the defined test module and
## load/compile the defsystem in Livingstone
## 18sep97 wmt: new
proc compileTestScope { } {
  global g_NM_selectedTestScope 
  global g_NM_compileModuleFiles g_NM_compileComponentFiles g_NM_menuStem
  global g_NM_classTypesAList g_NM_testInstanceName 
  global g_NM_createModuleFileName g_NM_testScenarioName 
  global g_NM_selectedTestScopeRoot env g_NM_jmplCompilerExtension
  global g_NM_generatedMPLExtension g_NM_win32P
  global g_NM_inhibitPirWarningP g_NM_scenarioDialogRoot 

  # allow stuck attention line msgs to be erased
  set g_NM_inhibitPirWarningP 0
  set reinit 1
  # ensure that current work is saved
  if {[fileQuit]} {
    jmplCompilationDependentFileNames moduleName modulePathname 
    set str "\ncompileTestScope: Module Files    => $g_NM_compileModuleFiles"
    puts stderr "$str\n                  Component Files => $g_NM_compileComponentFiles"

    # compile module jmpl file to generate g_NM_jmplCompilerExtension file
    # build string of dependent files
    set jmplPathnameList [jmplCompilationDependentPathnameList \
                              $g_NM_selectedTestScopeRoot]

    set jmplOpIndx 1; set askUserP 0; set silentP 0

    maybeRunJmplLintCompiler $moduleName $modulePathname $jmplOpIndx \
        $askUserP $jmplPathnameList $silentP $g_NM_testInstanceName  

    # check that compile was succesful
    # compiled output file

    # for stanley-sample-user-files workspace, write .xmpl file
    # into users stanley dir, so that non-group writable umask
    # will not cause a problem for the next user
    if {[preferred projectId] == "stanley-sample-user-files"} {
      set compileOutputPathname "$env(HOME)/.stanley/"
      append compileOutputPathname [file rootname [file tail $modulePathname]]
    } else {
      set compileOutputPathname [file rootname $modulePathname]
    }
    append compileOutputPathname $g_NM_jmplCompilerExtension
    # puts stderr "compileTestScope: compileOutputPathname $compileOutputPathname"

    if {[file exists $compileOutputPathname]} {
      .master.$g_NM_menuStem.test.m entryconfigure \
          "Load & Go" -state normal
      .master.$g_NM_menuStem.test.m entryconfigure \
          "Clean" -state normal
      if {[winfo exists $g_NM_scenarioDialogRoot]} {
        $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
      }
    }
    set g_NM_testScenarioName "<unspecified>"
    displayDotWindowTitle
    if {! $g_NM_win32P} {
      .master.canvas config -cursor top_left_arrow
    }
    update
  }
}


## user selected component/module to instantiate -- bring
## that schematic up
## 30oct98 wmt: new
proc instantiateTestModule { {resetP 0} } {
  global g_NM_classInstance g_NM_schematicMode g_NM_menuStem
  global g_NM_testModuleArgsValues g_NM_mkformNodeCompleteP
  global g_NM_selectedTestModule g_NM_rootInstanceName
  global g_NM_testInstanceName pirNode g_NM_recursiveInstantiationP
  global g_NM_l2toolsCurrentTime 
  global g_NM_moduleToNode pirNodes g_NM_scenarioMgrHeightPixels
  global g_NM_vmplTestModeP g_NM_groundProcessingUnitP 
  global g_NM_showIconLabelBalloonsP
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_rootInstanceName g_NM_classDefType
  global g_NM_scenarioDialogRoot env 
  global pirClassComponent g_NM_nodeTypeRootWindow
  global g_NM_cmdMonExtension g_NM_scenarioExtension
  global g_NM_jmplInitExtension g_NM_componentFaultDialogRoot 
  global g_NM_commandMonitorConstraints 
  global g_NM_commandLineLockP g_NM_testPermBalloonsState 
  global g_NM_instantiateTestModuleP g_NM_toolsL2ViewerP
  global g_NM_freshCommandLineP g_NM_inhibitPirWarningP
  global g_NM_componentToNode g_NM_selectTestScopeCalledP
  global g_NM_scenarioMgrXpos g_NM_scenarioMgrYpos
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset 
  global g_NM_stanleyCurrentTime g_NM_fcCommandSentP 
  global g_NM_firstCmdReceivedP g_NM_livingstoneNowTime 
  global g_NM_win32P g_NM_testInstanceNameInternal

  if {[outstandingEditDialogsP]} {
    # outstanding Modes & Initial Conditions dialog
    return
  }
  if {! $g_NM_selectTestScopeCalledP} {
    selectTestScope $g_NM_selectedTestScopeRoot $g_NM_selectedTestScope
  }
  # to ignore l2tools generated msg gotCandidates in response to loadModel
  set g_NM_fcCommandSentP 0
  # allow stuck attention line msgs to be erased
  set g_NM_inhibitPirWarningP 0
  set caller "instantiateTestModule"
  set className $g_NM_selectedTestScope 
  set canvasRootId 0
  catch { unset g_NM_commandMonitorConstraints }
  set g_NM_commandMonitorConstraints(0) {}
  # 0 is the time of load model, 1 is now
  set g_NM_commandMonitorConstraints(1) {}
  # number of progress cmds processed by gotProgress
  # L2 "now" time
  set g_NM_livingstoneNowTime 1
  # puts stderr "instantiateTestModule: g_NM_livingstoneNowTime $g_NM_livingstoneNowTime "
  # current L2 time slice for g_NM_commandMonitorConstraints
  # determined  by Candidate Manger and newState cmd stateId
  # g_NM_stanleyCurrentTime is index for g_NM_commandMonitorConstraints 
  set g_NM_stanleyCurrentTime 1
  set g_NM_l2toolsCurrentTime "<unspecified>"
  # force test balloons to be hidden at instantiation time
  set g_NM_testPermBalloonsState hide
  set g_NM_firstCmdReceivedP 0
  .master.canvas.root.c configure -bg [preferred StanleyTestCanvasBackgroundColor]
  set g_NM_testModuleArgsValues {}

  destroyScenarioManager  
  # needed for refresh cmd issued below
  set g_NM_commandLineLockP 0

  set canvasRoot [getCanvasRoot $canvasRootId]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
      -state disabled
  $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
      -state disabled
  # disable "Step" & "Run" buttons
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    $g_NM_scenarioDialogRoot.text&button.b.step config -state disabled
    $g_NM_scenarioDialogRoot.text&button.b.run config -state disabled
    # in case previous scenario was not completed
    balloonhelp $g_NM_scenarioDialogRoot.text&button.b.step -side right ""
  }
  set nodeInstanceName $g_NM_testInstanceNameInternal
  set g_NM_selectedTestModule $className
  set instanceClassName $className
  if {! $resetP} {
    # allow editing of incomplete class instances in askClassInstance
    set g_NM_instantiateTestModuleP 1
    # Test->Load & Go puts Stanley in test mode; File->New or
    # File-> Open will set layout mode, if currently in test mode
    set g_NM_recursiveInstantiationP 1
    # g_NM_vmplTestModeP needs to be 1 when fileNew is called
    # so that initialize_graph, called by fileNew will set g_NM_currentCanvas
    # properly. g_NM_vmplTestModeP is set = 1 in compileTestScope
    fileNew module $caller

    # g_NM_schematicMode needs to be layout when fileNew is called
    # so that initialize_graph->setCanvasRootInfo is not set 
    # to "0 .master.canvas.?name", rather than ".master.canvas.?name"
    .master.$g_NM_menuStem.edit.m entryconfigure "Header" -state normal
    if {$g_NM_schematicMode != "operational"} {
      .master.$g_NM_menuStem.edit.m entryconfigure "Instantiate" -state disabled
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding On" -state disabled
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding Off" -state disabled
    }
    set g_NM_schematicMode "operational"
    # instantiate module class with dummy args
    ### set interactiveP 0; set g_NM_mkformNodeCompleteP 1
    # allow for user choosing values for parameters, if appropriate
    set interactiveP 1; set g_NM_mkformNodeCompleteP 1
    set instanceLabel $nodeInstanceName
    set nodeDescription "dummy instance name and arguments"
    # arg 4: classArgsValues is set in canvasB1Click, since we do not
    # know at this point, how many there are

    puts -nonewline stderr \
        "instantiateTestModule $g_NM_selectedTestScopeRoot `$className' => "

    # turn off node labels -- require user to click on "Show Labels"
    # to see them.  this is because otherwise they "flip-flop"
    hideIconLabelBalloons "mainWindow"

    # ask user to supply class parameter values
    set classArgsValues {}

    set g_NM_classInstance [list $nodeInstanceName $instanceLabel \
                                $nodeDescription $classArgsValues]
    set pirNodeIndex [instantiateDefinitionUpdate $g_NM_selectedTestScopeRoot \
                          $instanceClassName $interactiveP]
    # since this newly created module (or component) did not go thru askDefmoduleInfo
    acons input_terminals {} pirNode($pirNodeIndex)
    acons output_terminals {} pirNode($pirNodeIndex)
    acons port_terminals {} pirNode($pirNodeIndex)
    set displayStateAttrIndex [getDisplayStatePirNodeIndex $nodeInstanceName]
    set displayStateAttrName [assoc nodeInstanceName pirNode($displayStateAttrIndex)]
    set reportNotFoundP 0; set oldvalMustExistP 0
    arepl displayStatePropName $displayStateAttrName \
        pirNode($pirNodeIndex) $reportNotFoundP $oldvalMustExistP 

    if {$g_NM_selectedTestScopeRoot == "component"} {
      # update input_terminals, etc of component since it is not a properly
      # inlcluded component of its parent module -- this is needed for
      # resetComponents to setup the terminal propositions
      set rootInstanceName $g_NM_rootInstanceName
      set classDefType $g_NM_classDefType
      set g_NM_rootInstanceName $g_NM_testInstanceNameInternal
      set g_NM_classDefType component
      set inputs [assoc inputs pirNode($pirNodeIndex)]
      for {set i 1} {$i < [llength $inputs]} {incr i 2} {
        set terminalForm [lindex $inputs $i]
        set terminalName [assoc terminal_name terminalForm]
        updateDefmoduleDefcomponentTerminal input $terminalName 
      }
      set outputs [assoc outputs pirNode($pirNodeIndex)]
      for {set i 1} {$i < [llength $outputs]} {incr i 2} {
        set terminalForm [lindex $outputs $i]
        set terminalName [assoc terminal_name terminalForm]
        updateDefmoduleDefcomponentTerminal output $terminalName
      }
      set g_NM_rootInstanceName $rootInstanceName
      set g_NM_classDefType $classDefType
    }
    # now that all nodes are created, bring up the labels so that are
    # above the node objects
    showIconLabelBalloons "mainWindow"

    # for initial instance of Scenario Mgr
    set g_NM_scenarioMgrHeightPixels -1
  } else {
    if {$g_NM_selectedTestScopeRoot == "component"} {
      set pirNodeIndex [assoc-array $g_NM_testInstanceNameInternal \
                            g_NM_componentToNode]
    } else {
      set pirNodeIndex [assoc-array $g_NM_testInstanceNameInternal \
                            g_NM_moduleToNode]
    }
  }
  # puts stderr "instantiateTestModule: resetP $resetP pirNodeIndex $pirNodeIndex"
  if {$resetP} {
    # put schematic at top level, if not there
    putSchematicAtTopLevel
    set modeFlag "reset"
    # ensure that canvas is scrolled to 0,0 after possible scrolling by user
    set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
    $canvas xview moveto 0
    $canvas yview moveto 0
  } else {
    # fileNew puts schematic at top level
    set g_NM_instantiateTestModuleP 0
    set modeFlag "init" 
  }
  if {[winfo exists $g_NM_componentFaultDialogRoot]} {
    destroy $g_NM_componentFaultDialogRoot
  }
  resetComponents $modeFlag $canvasRootId

  # open to working level of module or component
  openNodeGroup $nodeInstanceName $g_NM_selectedTestScopeRoot \
      [assoc window pirNode($pirNodeIndex)]

  if {[preferred StanleyTestPermanentBalloons] == "on"} {
    # create user test permanent balloons with noData values
    # prior to sending initial state cmd/mon values to Livingstone
    showCommandMonitorTerminalBalloons "current" $caller
    # force test balloons to be hidden at instantiation time
    hideTestPermanentBalloons
    .master.$g_NM_menuStem.tools.m entryconfigure "Hide Test Permanent Balloons" \
        -state disabled
    .master.$g_NM_menuStem.tools.m entryconfigure "Show Test Permanent Balloons" \
        -state normal
  }

  update
  mark_scm_unmodified

  .master.$g_NM_menuStem.tools.m entryconfigure \
      "Display Toplevel State Viewer Windows" -state normal
  .master.$g_NM_menuStem.tools.m entryconfigure \
      "Delete All State Viewer Windows" -state normal
  .master.$g_NM_menuStem.tools.m entryconfigure \
      "Component Faults" -state normal 

  if {$resetP} {
    # use same .ini, .hrn, & .params files for Reset

    # force L2 start history to be greater than 0, so that
    # L2Tools EngineModelBean:setStartTimeStep has unequal args to
    # firePropertyChange -- causing it to fire
    getTruncateHorizonFromL2 minHorizon maxHorizon
    if {$minHorizon == 0} {
      # puts stderr "num progresses [expr {[preferred L2MaxHistorySteps] - $maxHorizon + 1}]"
      for {set i 0} {$i < [preferred L2MaxHistorySteps] - $maxHorizon + 1} {incr i} {
        livingstoneCmdLineRequest "progress"
      }
      # L2 "now" time: set it back to 1, since progresses will increment it
      set g_NM_livingstoneNowTime 1
    }

  } elseif {(! $g_NM_toolsL2ViewerP) && (! $g_NM_groundProcessingUnitP)} {
    # generate .ini initialization file for livingstone
    # component default modes -
    # require user to select values for any <unspecified> init modes
    global initialModeSelection
    set initialModeSelection [getOrderedComponentModes $className]
    # puts stderr "instantiateTestModule: initialModeSelection $initialModeSelection"

    # allow user to change any init mode thru one scrolling dialog
    # of all modes, grouped by module, and indented by hierarchy level
    scrollableCanvasOfOptionMenus "Modes & Initial Conditions" initialModeSelection \
        "USE DEFAULTS"

    writeMplInitFile $g_NM_selectedTestScopeRoot $className $initialModeSelection 

    # generate command/monitor "harness" file for Livingstone
    # generate initial state script file for Livingstone
    writeMplCmdMonFile $g_NM_selectedTestScopeRoot $className

    # generate L2 search params file, which are all the L2* preferences
    writeL2ParamsFile $g_NM_selectedTestScopeRoot $className
  }

  if {! $g_NM_toolsL2ViewerP} {
    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
    }
    set severity 1; set msg2 ""
    pirWarning "Please Wait: instantiating Livingstone instance --" $msg2 $severity
    update

    # instantiate Livingstone instance
    set valuesList [concat [getExternalNodeName $nodeInstanceName] \
                        $g_NM_testModuleArgsValues]
    set str "Instantiating Livingstone $g_NM_selectedTestScopeRoot `$instanceClassName' \n"
    puts stderr "$str    with values: $valuesList\n"

    # puts stderr "instantiateTestModule: g_NM_freshCommandLineP $g_NM_freshCommandLineP"
    if {! $g_NM_freshCommandLineP} {
      resetL2toolsJNIandL2
    }
    set g_NM_freshCommandLineP 0

    # for stanley-sample-user-files workspace, write .xmpl, .ini, & .hrn files
    # into users stanley dir, so that non-group writable umask
    # will not cause a problem for the next user
    if {[preferred projectId] == "stanley-sample-user-files"} {
      set directory "$env(HOME)/.stanley/"
    } else {
      set directory "[preferred LIVINGSTONE_MODELS_DIR]/"
      if {$g_NM_selectedTestScopeRoot == "module"} {
        append directory "modules/"
      } else {
        append directory "components/"
      }
    }

    if {! $g_NM_groundProcessingUnitP} {
      # send CORBA request to Livingstone to load component/module model, init &
      # test harness files
      livingstoneCmdLineRequest "loadmodel $directory$className"
      
      #   if {$g_NM_selectedTestScope == "cbAndLeds"} {
      # #     livingstoneCmdLineRequest \
          # #         "loadmodel /home/serengeti/id0/taylor/mba/cpp/tests/cb/cb"
      #     livingstoneCmdLineRequest \
          #         "loadmodel /home/serengeti/id0/taylor/stanley-projs/async-msg/cbAndLeds"
      #   } else {
      #     livingstoneCmdLineRequest "loadmodel $directory$className"
      #   }

      # send CORBA request to Livingstone to load component/module initial state scenario file
      ## livingstoneCmdLineRequest "run $directory$className$g_NM_scenarioExtension"
      # do not send an initial script file -- the initial state of the
      # commands and monitors is determined by L2 reading the .hrn file
      if {! $resetP} {
        # just send a refresh command
        livingstoneCmdLineRequest "refresh"
      } else {
        ## refresh cmd is redundant, since loadModel on a RESET results in 
        ## newState being sent
      }
      
      #   if {$g_NM_selectedTestScope == "cbAndLeds"} {
      #     puts stderr "instantiateTestModule: command `loadtrace will.tra'"
      #     livingstoneCmdLineRequest "loadtrace will.tra"
      #   }
    }
  }

  if {! $g_NM_groundProcessingUnitP} {
    $menuRoot.test.m entryconfigure "Compile" -state disabled 
    if {(! $g_NM_commandLineLockP) && (! $g_NM_toolsL2ViewerP)} {
      # get testing scenario files
      set scenarioList [getScenariosForClass $className]
      # pop-up window Scenario Manager
      createScenarioManager $scenarioList
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
    }
    #   $menuRoot.test.m entryconfigure "Truth Table" -state normal
    #   destroy $g_NM_advisoryRootWindow.constraint_table
    $menuRoot.test.m entryconfigure "Write IDD" -state normal
  }

  displayDotWindowTitle
  standardMouseClickMsg
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow
    update
  }
}


## delete all test module files generated by
## compileTestScope & instantiateTestModule
## 27oct98 wmt: new
proc cleanTestScope { } {
  global g_NM_selectedTestScope g_NM_selectedTestScopeRoot
  global g_NM_menuStem g_NM_scenarioDialogRoot

  set type testClean
  if {$g_NM_selectedTestScope != "<unspecified>"} {
    deleteMplFiles $g_NM_selectedTestScopeRoot \
        $g_NM_selectedTestScope $type 
    .master.$g_NM_menuStem.test.m entryconfigure \
        "Compile" -state normal
    .master.$g_NM_menuStem.test.m entryconfigure \
        "Load & Go" -state disabled
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      $g_NM_scenarioDialogRoot.text&button.b.reset config -state disabled
    }
  }
}


## change from vmpl test mode to vmpl edit (pure "layout") mode
## 18dec98 wmt: new
proc changeVmplTestToEdit {} {
  global g_NM_schematicMode g_NM_vmplTestModeP
  global g_NM_recursiveInstantiationP g_NM_menuStem
  global g_NM_statePropsRootWindow 
  global g_NM_showNodeLegendBarP g_NM_testScenarioName
  global g_NM_selectedTestScope g_NM_selectTestScopeCalledP
  global g_NM_inhibitPirWarningP 

  set g_NM_schematicMode "layout"
  set g_NM_vmplTestModeP 0
  set g_NM_recursiveInstantiationP 0
  set canvasRootId 0

  set menuRoot .master.$g_NM_menuStem
  $menuRoot.file.m entryconfigure "Print Definition" -state normal 
  $menuRoot.file.m entryconfigure "Delete Definition" -state normal 

  # leave Load & Go enabled so that user does not have to use Scope
  # if they are remaining in the same scope
  # $menuRoot.test.m entryconfigure "Load & Go" -state disabled
  destroyScenarioManager  

#   $menuRoot.test.m entryconfigure \
#        "Truth Table" -state disabled
  $menuRoot.test.m entryconfigure "Write IDD" -state disabled
  if {$g_NM_selectedTestScope != "<unspecified>"} {
    $menuRoot.test.m entryconfigure "Clean" -state normal
  } else {
    $menuRoot.test.m entryconfigure "Clean" -state disabled 
  }
  $menuRoot.tools.m entryconfigure \
      "Display Toplevel State Viewer Windows" -state disabled 
  $menuRoot.tools.m entryconfigure \
      "Delete All State Viewer Windows" -state disabled 
  $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
      -state disabled
  $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
      -state disabled
  set g_NM_testScenarioName "<unspecified>"
  set g_NM_selectTestScopeCalledP 0
  displayDotWindowTitle
  update
  if {$g_NM_showNodeLegendBarP} {
    resetLayoutLegendColors $canvasRootId
  }
  # clear any Attention msgs
  set g_NM_inhibitPirWarningP 0
  standardMouseClickMsg
  # change root color back to edit
  .master.canvas.root.c configure -bg [preferred StanleySchematicCanvasBackgroundColor]
}


## show user the values of the command and monitor terminals
## 20sep99 wmt: new
proc showCommandMonitorTerminalBalloons { type caller } {
  global pirNode pirNodes g_NM_moduleToNode g_NM_componentToNode
  global g_NM_selectedTestScopeRoot g_NM_testInstanceNameInternal
  global g_NM_commandMonitorIndices g_NM_commandMonitorConstraints
  global g_NM_stanleyCurrentTime

  if {[lsearch -exact [list default current] $type] == -1} {
    error "showCommandMonitorTerminalBalloons: invalid type: $type"
  }
  set currentNodeGroup $g_NM_testInstanceNameInternal
  if {[string match $type "current"]} {
    if {$g_NM_selectedTestScopeRoot == "module"} {
      set groupPirNodeIndex $g_NM_moduleToNode($currentNodeGroup)
    } else {
      set groupPirNodeIndex $g_NM_componentToNode($currentNodeGroup) 
    }
    # puts stderr "currentNodeGroup $currentNodeGroup groupPirNodeIndex $groupPirNodeIndex"
    set groupNodePropList [assoc nodePropList pirNode($groupPirNodeIndex)]
  }
  if {$caller == "instantiateTestModule"} {
    set g_NM_commandMonitorIndices {}
    set fillIndicesP 1
    set nodeList $pirNodes 
  } else {
    set nodeList $g_NM_commandMonitorIndices
    set fillIndicesP 0
  }
  # puts stderr "showCommandMonitorTerminalBalloons: commandMonitorConstraints $g_NM_commandMonitorConstraints($g_NM_stanleyCurrentTime)"
  foreach pirNodeIndex $nodeList {
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    set nodeState [assoc nodeState pirNode($pirNodeIndex)]
    if {[string match [assoc nodeGroupName pirNode($pirNodeIndex)] \
             $currentNodeGroup] && \
            (! [string match $nodeClassName "displayState"]) && \
            (! [string match $nodeClassType "attribute"]) && \
            (! [string match $nodeState "parent-link"])} {
      if {[string match $nodeClassType "terminal"] && \
              (! [regexp "Declaration" $nodeClassName])} {
        if {[string match [assoc nodeClassName pirNode($pirNodeIndex)] \
                 "input"]} {
          set outputs [assoc outputs pirNode($pirNodeIndex)]
          set terminalForm [assoc out1 outputs]
        } else {
          set inputs [assoc inputs pirNode($pirNodeIndex)]
          set terminalForm [assoc in1 inputs]
        }
        if {[assoc interfaceType terminalForm] == "public"} {
          if {$fillIndicesP} {
            lappend g_NM_commandMonitorIndices $pirNodeIndex
          }
          showCommandMonitorTerminalBalloonsDoit \
              $type $nodeClassType null terminalForm groupNodePropList \
              $pirNodeIndex null $caller
        }
      } elseif {[string match $nodeClassType "component"] || \
                    [string match $nodeClassType "module"]} {
        if {[string match $type "current"]} {
          set nodePropList [assoc nodePropList pirNode($pirNodeIndex)]
        }
        set window [assoc window pirNode($pirNodeIndex)]
        set edgesToList [assoc edgesTo pirNode($pirNodeIndex)]
        set numInputs [assoc numInputs pirNode($pirNodeIndex)]
        set inputs [assoc inputs pirNode($pirNodeIndex)]
        for {set num 1} {$num <= $numInputs} {incr num} {
          if {[string match [lindex $edgesToList [expr {$num - 1}]] ""]} {
            # not connected - thus external, if public
            set buttonPath "${window}.in.b$num"
            set terminalForm [assoc in$num inputs]
            if {[assoc interfaceType terminalForm] == "public"} {
              if {$fillIndicesP} {
                lappend g_NM_commandMonitorIndices $pirNodeIndex
              }
              showCommandMonitorTerminalBalloonsDoit \
                  $type $nodeClassType inputs terminalForm nodePropList \
                  $pirNodeIndex $buttonPath $caller
            }
          }
        }

        set edgesFromList [assoc edgesFrom pirNode($pirNodeIndex)]
        set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
        set outputs [assoc outputs pirNode($pirNodeIndex)]
        for {set num 1} {$num <= $numOutputs} {incr num} {
          if {[string match [lindex $edgesFromList [expr {$num - 1}]] ""]} {
            # not connected - thus external, if public
            set buttonPath "${window}.out.b$num"
            set terminalForm [assoc out$num outputs]
            if {[assoc interfaceType terminalForm] == "public"} {
              if {$fillIndicesP} {
                lappend g_NM_commandMonitorIndices $pirNodeIndex
              }
              showCommandMonitorTerminalBalloonsDoit \
                  $type $nodeClassType outputs terminalForm nodePropList \
                  $pirNodeIndex $buttonPath $caller 
            }
          }
        }
      }
    }
  }
}


proc showCommandMonitorTerminalBalloonsDoit { type nodeClassType terminalDirection \
                                                  terminalFormRef nodePropListRef \
                                                  pirNodeIndex buttonPath caller } {
  upvar $terminalFormRef terminalForm
  upvar $nodePropListRef nodePropList
  global g_NM_commandMonitorConstraints g_NM_stanleyCurrentTime
  global g_NM_defaultDisplayState 

  set canvasRootId 0
  set balloonType testValues
  if {[string match $type "default"]} {
    set cmdMonValueList [lindex [assoc commandMonitorType terminalForm] 1]
  } elseif {[string match $type "current"]} {
    set cmdMonValueList [getCmdMonValues terminalForm nodePropList]
  }
  if {$nodeClassType == "terminal"} {
    getPermBalloonWindows $pirNodeIndex balloonWindow rootWindow \
        xOffset yOffset
  } else {
    getPermBalloonWindows $pirNodeIndex balloonWindow rootWindow \
        xOffset yOffset $buttonPath
  }
  set terminalName [assoc terminal_name terminalForm]
  # puts stderr "showCommandMonitorTerminalBalloons: nodeClassType $nodeClassType terminalDirection $terminalDirection terminalName $terminalName"
  set expandedTerminalNames [expandStructureTerminalNames terminalForm]
  # puts stderr "\nshowCommandMonitorTerminalBalloonsDoit: expandedTerminalNames $expandedTerminalNames cmdMonValueList $cmdMonValueList"
  set commandMonitorConstraints \
      $g_NM_commandMonitorConstraints($g_NM_stanleyCurrentTime)
#   if {$caller == "displayUserTestValueBalloon"} {
#     puts stderr "showCommandMonitorTerminalBalloonsDoit: g_NM_stanleyCurrentTime $g_NM_stanleyCurrentTime commandMonitorConstraints $commandMonitorConstraints"
#   }
  set cmdMonConstraintP {}; set cmdMonConstraintValuesList {}
  foreach expTerminalName $expandedTerminalNames cmdMonValue $cmdMonValueList {
    if {($caller == "instantiateTestModule") || \
            (($caller != "instantiateTestModule") && \
                 (([lsearch -exact $commandMonitorConstraints \
                        $expTerminalName] >= 0) || \
                      [string match $cmdMonValue $g_NM_defaultDisplayState]))} {
      lappend cmdMonConstraintP 1
      if {[string match $cmdMonValue $g_NM_defaultDisplayState]} {
        lappend cmdMonConstraintValuesList $g_NM_defaultDisplayState 
      } else {
        lappend cmdMonConstraintValuesList \
            [assoc $expTerminalName commandMonitorConstraints]
      }
    } else {
      lappend cmdMonConstraintP 0
      lappend cmdMonConstraintValuesList $cmdMonValue 
    }
  }
#   if {[lindex $cmdMonConstraintP 0]} {
#     set cmdMonValueList $cmdMonConstraintValuesList
#   }
  set cmdMonValueList $cmdMonConstraintValuesList 
  permanentBalloonHelp $balloonWindow $rootWindow \
      $cmdMonValueList $balloonType $xOffset $yOffset $canvasRootId \
      $cmdMonConstraintP
}


## get defvalues & structures command/monitor values
## 20sep99 wmt: new
proc getCmdMonValues { terminalFormRef nodePropListRef } {
  upvar $terminalFormRef terminalForm
  upvar $nodePropListRef nodePropList

  set terminal_name [assoc terminal_name terminalForm]
  set terminalType [getTerminalType $terminalForm]
  set cmdMonValueList {}
  set reportNotFoundP 0
  # puts stderr "getCmdMonValues: nodePropList $nodePropList"
  # puts stderr "getCmdMonValues: expnd names [expandStructureTerminalNames terminalForm] "
  foreach propTerminalInstance [expandStructureTerminalNames terminalForm] {
    set attList [assoc $propTerminalInstance nodePropList $reportNotFoundP]
    # a standalone top-level terminal has been made private by the user
    # and thus is not inherited up to "test" and does not exist in
    # its nodePropList
    if {$attList != ""} {
      lappend cmdMonValueList [assoc value attList]
    }
  }
  # puts stderr "getCmdMonValues: cmdMonValueList $cmdMonValueList"
  return $cmdMonValueList
}


## generate truth table of instantiated component/module's
## terminal inputs & initial mode and terminal outputs and
## resultant mode.
## 15feb00 wmt: new
proc generateTruthTable { } {
  global g_NM_selectedTestScope g_NM_selectedTestScopeRoot
  global g_NM_advisoryRootWindow g_NM_testInstanceName 

  set lispProgramScript "(tt-for-stanley (>> $g_NM_testInstanceName "
  if {$g_NM_selectedTestScopeRoot == "component"} {
    append lispProgramScript "$g_NM_testInstanceName"
  }
  append lispProgramScript "))"

  # puts stderr "generateTruthTable: lispProgramScript $lispProgramScript"
  set str "Generating truth table for $g_NM_selectedTestScopeRoot"
  puts stderr "$str [string toupper $g_NM_selectedTestScope]\n"

  # send CORBA request to Livingstone 
  set returnString [evalLivingstoneForm lispProgramScript]

  if {$returnString == ""} {
    # Java truth table process is running -- it will display truth table
    return
  }

  # show user the table
  set textHeight 12; set textWidth 124
  set window ${g_NM_advisoryRootWindow}.constraint_table
  if {[winfo exists $window]} {
    raise $window
    return
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  toplevel $window -class Dialog
  set title "Truth Table for $g_NM_selectedTestScopeRoot:"
  append title " [string toupper $g_NM_selectedTestScope]"
  wm title $window $title 
  if { [winfo viewable [winfo toplevel [winfo parent $window]]] } {
    wm transient $window [winfo toplevel [winfo parent $window]]
  }    
  $window config -bg $bgcolor
  frame $window.text&button -bd 0 -bg $bgcolor -relief ridge 
  frame $window.text&button.text&header -bd 0 -bg $bgcolor -relief flat
  frame $window.text&button.text&header.h -bd 0 -bg $bgcolor -relief flat
  frame $window.text&button.text&header.t -bd 0 -bg $bgcolor -relief flat 
  frame $window.text&button.text&header.t.right -bd 0 -bg $bgcolor -relief ridge 
  frame $window.text&button.text&header.t.bottom -bd 0 -bg $bgcolor
  frame $window.text&button.b -bd 0 -bg $bgcolor -relief ridge 

  set hdr [text $window.text&button.text&header.h.text -setgrid true \
               -wrap none -font [preferred StanleyDialogEntryFont] \
               -bg $bgcolor]

  set txt [text $window.text&button.text&header.t.text -setgrid true \
               -xscrollcommand "$window.text&button.text&header.t.bottom.sx set" \
               -yscrollcommand "$window.text&button.text&header.t.right.sy set" \
               -wrap none -font [preferred StanleyDialogEntryFont]]

  scrollbar $window.text&button.text&header.t.bottom.sx -orient horiz \
      -command "$txt xview" -relief sunk -bd 2 
  scrollbar $window.text&button.text&header.t.right.sy -orient vertical \
      -command "$txt yview" -relief sunken -bd 2 

  button $window.text&button.b.cancel -text " DISMISS " -relief raised \
      -command "destroy $window" -padx 5 -pady 5
  pack $window.text&button.b.cancel -side bottom -padx 0 -ipadx 0 -expand 1
  pack $window.text&button.b -side bottom -fill x
  pack $window.text&button -fill both -expand 1

  pack $window.text&button.text&header.t.right.sy -side right -fill y -expand 1
  pack $window.text&button.text&header.t.right -side right -fill y
  pack $window.text&button.text&header.t.bottom.sx -side bottom -fill x -expand 1
  pack $window.text&button.text&header.t.bottom -side bottom -fill x 
  pack $window.text&button.text&header.t.text -side bottom -fill both -expand 1
  pack $window.text&button.text&header.t -side bottom -fill both -expand 1

  pack $window.text&button.text&header.h.text -side bottom -fill both -expand 1
  pack $window.text&button.text&header.h -side bottom -fill both -expand 1
  pack $window.text&button.text&header -fill both -expand 1

  # characters
  $txt config -width $textWidth 
  $hdr config -width $textWidth 
  $txt config -height $textHeight 

#   set scenarioDir [preferred LIVINGSTONE_MODELS_DIR]/[preferred scenario_directory]
#   set pathName "$scenarioDir/$g_NM_testScenarioName.lisp"
#   set fid [open $pathName r]
#   set stepNum 1
#   while {[set charCnt [gets $fid textLine]] != -1} {
#     if {[regexp "do-cmd" $textLine] || \
#             [regexp "do-monitors" $textLine]} {
#       $txt insert end "$textLine\n" stepNum_$stepNum
#       incr stepNum 
#     } else {
#       $txt insert end "$textLine\n" 
#     }
#   }
  set lineCnt 0; set headerP 1
  while {[string length $returnString] > 0} {
    set indx [string first "\n" $returnString]
    set textLine [string range $returnString 0 [expr {$indx - 1}]]
    if {$headerP} {
      if {[regexp -- "----" $textLine]} {
        set headerP 0
      } else {
        incr lineCnt
        $hdr insert end "$textLine\n"
      }
    } else {
      $txt insert end "$textLine\n" 
    }
    set returnString [string range $returnString [expr {$indx + 1}] end]
  }

  $hdr config -height $lineCnt 
  $hdr config -state disabled
  $txt config -state disabled
  keepDialogOnScreen $window
}


## write Interface Definition Document for current component/module
## 28feb00 wmt: new
proc writeIDD {} {
  global g_NM_rootInstanceName pirNodes
  global g_NM_livingstoneDefcomponentName g_NM_componentToNode 
  global g_NM_livingstoneDefmoduleName g_NM_moduleToNode pirNode
  global g_NM_selectedTestModule 

  if {! [validSchematicP]} {
    return
  }
  set nodeInstanceName $g_NM_rootInstanceName
  set filePath [lindex [preferred STANLEY_USER_DIR] 0]/[preferred schematic_directory]
  set modulePirNodeIndices {}; set componentPirNodeIndices {}
  append filePath "/[preferred defmodules_directory]/$g_NM_selectedTestModule.idd"
  
  set rootNodeIndex [assoc-array $g_NM_rootInstanceName g_NM_moduleToNode]
  ## get all component and module indices
  foreach pirNodeIndex $pirNodes {
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    if {$nodeClassType == "component"} {
      lappend componentPirNodeIndices [list $nodeInstanceName $pirNodeIndex]
    } elseif {($nodeClassType == "module") && \
                   (! [string match [assoc nodeState pirNode($pirNodeIndex)] \
                           "parent-link"]) && \
                  ($pirNodeIndex != $rootNodeIndex)} {
      lappend modulePirNodeIndices [list $nodeInstanceName $pirNodeIndex] 
    }
  }
  # sort by label name
  set componentPirNodeIndices [lsort -ascii -index 0 $componentPirNodeIndices]
  set modulePirNodeIndices [lsort -ascii -index 0 $modulePirNodeIndices]

  # puts stderr "writeIDD: componentPirNodeIndices $componentPirNodeIndices"
  # puts stderr "writeIDD: modulePirNodeIndices $modulePirNodeIndices"

  set fid [open $filePath w]
  puts $fid "INTERFACE DEFINTION DOCUMENT => $g_NM_selectedTestModule"
  puts -nonewline $fid "======================================================="
  puts $fid "======================"
  puts -nonewline $fid "======================================================="
  puts $fid "======================"
  foreach pairList $modulePirNodeIndices {
    writeIDD_doit module $fid [lindex $pairList 0] [lindex $pairList 1] 
  }
  foreach pairList $componentPirNodeIndices {
    writeIDD_doit component $fid [lindex $pairList 0] [lindex $pairList 1] 
  }
  close $fid
  set str "Writing `$g_NM_selectedTestModule' Interface"
  puts stderr "$str Definition Document to"
  puts stderr "    $filePath"
}


proc writeIDD_doit { nodeClassType fid nodeInstanceName pirNodeIndex } {
  global pirNode g_NM_terminalTypeValuesArray 

  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set inputs [assoc inputs pirNode($pirNodeIndex)]
  set outputs [assoc outputs pirNode($pirNodeIndex)]
  set typesList {}
  puts -nonewline $fid "\n\n[capitalizeWord $nodeClassType] Class: "
  puts -nonewline $fid "$nodeClassName;  "
  regsub -all "~" $nodeInstanceName " " tmp
  puts $fid "Instance: $tmp "
  puts -nonewline $fid "======================================================="
  puts $fid "======================\n"
  puts $fid "INPUTS >>>>>>"
  puts -nonewline $fid "Terminal Name       "
  puts -nonewline $fid "                     "
  puts -nonewline $fid "Terminal Type        "
  puts $fid "Command/Monitor"
  puts -nonewline $fid "---------------------------------------- --------------"
  puts $fid "------ ---------------"
  set nameWidth 40; set typeWidth 20; set cmdMonWidth 15
  set sortedInputs {}
  for {set i 0} {$i < [llength $inputs]} { incr i 2} {
    set terminalForm [lindex $inputs [expr {$i + 1}]]
    lappend sortedInputs $terminalForm
  }
  # sort by terminal name field
  set sortedInputs [lsort -ascii -index 3 $sortedInputs]
  foreach terminalForm $sortedInputs {
    set type [getTerminalType $terminalForm]
    if {[lsearch -exact $typesList $type] == -1} {
      lappend typesList $type
    }
    set terminalName [assoc terminal_name terminalForm]
    regsub -all "~" $terminalName " " tmp; set terminalName $tmp
    set terminalNameLength [string length $terminalName]
    if {$terminalNameLength <= $nameWidth} {
      puts $fid [format "%-${nameWidth}s %-${typeWidth}s %-${cmdMonWidth}s" \
                     $terminalName $type \
                     [lindex [assoc commandMonitorType \
                                  terminalForm] 0]]
    } else {
      puts $fid [format "%-s" $terminalName]
      puts -nonewline $fid [format "%-${nameWidth}s " " "]
      puts $fid [format "%-${typeWidth}s %-${cmdMonWidth}s" $type \
                     [lindex [assoc commandMonitorType \
                                  terminalForm] 0]]
    }
  }

  puts $fid "\nOUTPUTS >>>>>"
  puts -nonewline $fid "Terminal Name       "
  puts -nonewline $fid "                     "
  puts -nonewline $fid "Terminal Type        "
  puts $fid "Command/Monitor"
  puts -nonewline $fid "---------------------------------------- --------------"
  puts $fid "------ ---------------"
  set sortedOutputs {}
  for {set i 0} {$i < [llength $outputs]} { incr i 2} {
    set terminalForm [lindex $outputs [expr {$i + 1}]]
    lappend sortedOutputs $terminalForm
  }
  # sort by terminal name field
  set sortedOutputs [lsort -ascii -index 3 $sortedOutputs]
  foreach terminalForm $sortedOutputs {
    set type [getTerminalType $terminalForm]
    if {[lsearch -exact $typesList $type] == -1} {
      lappend typesList $type
    }
    set terminalName [assoc terminal_name terminalForm]
    regsub -all "~" $terminalName " " tmp; set terminalName $tmp
    set terminalNameLength [string length $terminalName]
    if {$terminalNameLength <= $nameWidth} {
        puts $fid [format "%-${nameWidth}s %-${typeWidth}s %-${cmdMonWidth}s" \
                       $terminalName $type \
                       [lindex [assoc commandMonitorType \
                                    terminalForm] 0]]
    } else {
      puts $fid [format "%-s" $terminalName]
      puts -nonewline $fid [format "%-${nameWidth}s " " "]
      puts $fid [format "%-${typeWidth}s %-${cmdMonWidth}s" $type \
                     [lindex [assoc commandMonitorType \
                                  terminalForm] 0]]
    }
  }

  # print type values
  set typesList [lsort -ascii $typesList]
  puts $fid [format "\n%-${typeWidth}s Type Values" Type]
  puts $fid "-------------------- -----------"
  foreach type $typesList {
    set typeLength [string length $type]
    if {$typeLength <= $typeWidth} {
      puts -nonewline $fid [format "%-${typeWidth}s " $type]
    } else {
      puts $fid [format "%-s" $type]
      puts -nonewline $fid [format "%-${typeWidth}s " " "]
    }
    set valuesList [assoc-array $type g_NM_terminalTypeValuesArray]
    puts $fid "[multiLineList $type $valuesList 12345678901234567890]"
  }
}


## get component default mode states, sorted by hierarchy and
## within each node group, by instance name
## 28mar00 wmt: new
proc getOrderedComponentModes { moduleName } {
  global initialModeSelection pirNodes pirNode
  global pirClassComponent g_NM_nodeTypeRootWindow
  global g_NM_testInstanceName g_NM_instanceToNode
  global g_NM_terminalTypeValuesArray 

  set initialModeSelection {}; set nodeGroupsList {}
  set reportNotFoundP 0
  # group components by their node group and hierarchy level by
  # using parentNodeGroupList as the key
  foreach pirNodeIndex $pirNodes {
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    if {[string match $nodeClassType "component"]} {
      set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
      set pathList [lreverse $parentNodeGroupList]
      regsub -all " " $pathList "_" key
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
      set matchP 0
      for {set i 0} {$i < [llength $nodeGroupsList]} {incr i} {
        set entry [lindex $nodeGroupsList $i]
        if {[string match $key [lindex $entry 0]]} {
          set indices [lindex $entry 1]
          lappend indices [list $nodeInstanceName $pirNodeIndex] 
          set nodeGroupsList [lreplace $nodeGroupsList $i $i [list $key $indices]]
          set matchP 1
          break
        }
      }
      if {! $matchP} {
        # new entry
        lappend nodeGroupsList [list $key [list [list $nodeInstanceName $pirNodeIndex]]]
      }
    }
  }
  # sort by group and level
  set nodeGroupsList [lsort -ascii -index 0 $nodeGroupsList]
  # puts stderr "nodeGroupsList group $nodeGroupsList"

  # now sort each group by instance name
  set newNodeGroupsList {}
  foreach keyIndices $nodeGroupsList {
    set key [lindex $keyIndices 0]
    # puts stderr "presort [lindex $keyIndices 1]"
    set sortedList [lsort -ascii -index 0 [lindex $keyIndices 1]]
    lappend newNodeGroupsList [list $key $sortedList]
  }
  set nodeGroupsList $newNodeGroupsList 
  # puts stderr "nodeGroupsList instance $nodeGroupsList"
  
  # puts stderr "\ngetOrderedComponents: Edit->Header->Initial Conditions commented out\n"
  foreach keyIndices $nodeGroupsList {
    set key [lindex $keyIndices 0]
    foreach instanceIndex [lindex $keyIndices 1] {
      set nodeInstanceName [lindex $instanceIndex 0]
      set pirNodeIndex [lindex $instanceIndex 1]
      set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
      set classVars [assoc class_variables pirClassComponent($nodeClassName)]
      set initialMode [getClassVarDefaultValue initial_mode classVars]
      set ok_modes [getClassVarDefaultValue ok_modes classVars] 
      set fault_modes [getClassVarDefaultValue fault_modes classVars]
      set mode_list [concat $ok_modes $fault_modes]
      if {$initialMode == ""} {
        set initialMode "<unspecified>"
        # ask user to select initial mode
        askUserInitialModes $moduleName [list [list $nodeInstanceName.mode \
                                                   $initialMode $mode_list]]
        set dialogW $g_NM_nodeTypeRootWindow.module_init_$moduleName 
        set dialogId [getDialogId $dialogW]
        global g_NM_optMenuInitMode_${dialogId}_mode0
        set initialMode [subst $[subst g_NM_optMenuInitMode_${dialogId}_mode0]]
      }
      # puts stderr "$nodeInstanceName.mode=$initialMode; mode_list $mode_list"
      lappend initialModeSelection [list [getExternalNodeName $nodeInstanceName.mode] \
                                        $initialMode $mode_list]
      # Edit->Header->Initial Conditions
      set initially [getClassVarDefaultValue initially classVars]
      set splitLines [split $initially "\n"]
      # puts stderr "splitLines $splitLines"
      foreach line $splitLines {
        if {[string range $line 0 1] != "//"} {
          set line [string trimright $line ";"]
          regsub -all " " $line "" tmp; set line $tmp
          if {[regexp "=" $line]} {
            set attrValPair [split $tmp "="]
            # reemove this., if present
            regsub "this\\\." [lindex $attrValPair 0] "" attr
            # prepend instanceName in order to instantiate form
            set attr "${nodeInstanceName}.$attr"
            set varTypeList {}
            # determine type values list
            set pirIndex [assoc-array $attr g_NM_instanceToNode $reportNotFoundP]
            if {$pirIndex != ""} {
              set nodeType [assoc nodeClassType pirNode($pirIndex)]
              if {($nodeType == "attribute") || ($nodeType == "terminal")} {
                set attrType [getTerminalInstanceType $pirIndex temp]
                set varTypeList [assoc-array $attrType g_NM_terminalTypeValuesArray]
              } else {
                set str "getOrderedComponentMode: nodeClassName $nodeClassName =>"
                puts stderr "$str in `Initial Conditions', pirIndex $pirIndex not handled"
              }
            }
            lappend initialModeSelection [list [getExternalNodeName $attr] \
                [lindex $attrValPair 1] $varTypeList]
          } else {
            set str "getOrderedComponentMode: nodeClassName $nodeClassName =>"
            puts stderr "$str in `Initial Conditions', not a valid assignement -> $line" 
          }
        }
      }
    }
  }
  return $initialModeSelection 
}


## return the directory for .xmpl, .ini, .hrn, & .params files
## 23apr01 wmt: new
proc getL2ModelDirectory { classType } {
  global env 

  # for stanley-sample-user-files workspace, write .hrn file
  # into users stanley dir, so that non-group writable umask
  # will not cause a problem for the next user
  if {[preferred projectId] == "stanley-sample-user-files"} {
    set directory "$env(HOME)/.stanley/"
  } else {
    set directory "[preferred LIVINGSTONE_MODELS_DIR]/"
    if {$classType == "module"} {
      append directory "modules/"
    } else {
      append directory "components/"
    }
  }
  return $directory
}


## write L2 preferences to <model>.params file for use when
## running l2test (L2 standalone) or real-time L2 (vxworks)
## 23apr01 wmt: new
proc writeL2ParamsFile { classType className } {
  global g_NM_paramsExtension g_NM_editablePrefNames
  global pirPreferences 

  set directory [getL2ModelDirectory $classType]
  set paramsPathname $directory$className$g_NM_paramsExtension
  set prefsLength [llength $g_NM_editablePrefNames]
  set fid [open $paramsPathname w]
  for {set i 0} {$i < $prefsLength} {incr i} {
    set prefname [lindex $g_NM_editablePrefNames $i]
    if {[string range $prefname 0 1] == "L2"} {
      set prefvalue $pirPreferences($prefname)
      puts $fid [format "%s = %s" $prefname $prefvalue]
    }
  }
  close $fid
  puts stderr "Writing `$className' L2 search parameters to"
  puts stderr "    $paramsPathname"
}


## ask user to select which Livingstone data state (stateID in newState msg)
## into which to put Stanley 
## 09may00 wmt
## not used 
# proc selectTestState { } {
#   global g_NM_packetTimeTagsList

#   # cascade menu
#   set numEntries [llength $g_NM_packetTimeTagsList]
#   set dialogW .testStates 
#   set menu $dialogW 
#   menubutton $menu -menu $menu.m -relief flat    
#   set rootMenu [menu $menu.m -tearoff 0]
#   set subMenu $rootMenu.items
#   $rootMenu add cascade -label "Select Test State"  -menu $subMenu 
#   menu $subMenu -tearoff 0
#   $subMenu config -font [preferred StanleyTerminalTypeFont]
#   if {$numEntries < 15} {
#     set stateIdIndex 0
#     foreach idTimePair $g_NM_packetTimeTagsList {
#       set text [format "stateId: %3d;  time %s" [lindex $idTimePair 0] \
#                     [lindex $idTimePair 1]]
#       set command "selectTestStateUpdate $dialogW $stateIdIndex"
#       $subMenu add command -label $text -command $command
#       incr stateIdIndex 
#     }
#     pack $menu -side top -fill x
#   } else {

#     set selectFunction selectTestStateUpdate
#     set subCascade 0; set stateIdIndex 0
#     set menuList {}; set menuLabelList {}
#     foreach idTimePair $g_NM_packetTimeTagsList {
#       if {(($stateIdIndex % 10) == 0) && ($stateIdIndex != 0)} {
#         generateCascadeMenu $subMenu $subCascade $subCascade \
#             $menuList $menuLabelList $selectFunction
#         set menuList {}; set menuLabelList {}
#         set subCascade $stateIdIndex 
#       }
#       lappend menuList $stateIdIndex
#       lappend menuLabelList [format "stateId: %3d;  time %s" [lindex $idTimePair 0] \
#                                  [lindex $idTimePair 1]] 
#       incr stateIdIndex 
#     }
#     # output partial list
#     if {$menuList != ""} {
#       generateCascadeMenu $subMenu $subCascade $subCascade \
#           $menuList $menuLabelList $selectFunction
#     }
#   }
#   # bury menu if user makes no selection
#   bind all <ButtonRelease-1> "disableSelectionMenu $dialogW $menu"
#   bind all <ButtonRelease-3> "disableSelectionMenu $dialogW $menu"

#   set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
#   set x [winfo pointerx $currentCanvas] 
#   set y [winfo pointery $currentCanvas]
#   # make sure that menu has been properly created before poping it up
#   # not sure why this is a problem, but this fixes it
#   if {[winfo exists $menu.m] } {
#     tk_popup $menu.m [expr {$x + 10}] $y 
#     update
#   }
# }


## not used
# proc selectTestStateUpdate { dialogW stateIdIndex } {
#   global g_NM_packetTimeTagsList

#   set idTimePair [lindex $g_NM_packetTimeTagsList $stateIdIndex] 
#   puts stderr "selectTestStateUpdate: stateId [lindex $idTimePair 0]"

#   destroy $dialogW

#   notAvailable

#   # request state id from Livingstone
#   ## livingstoneCmdLineRequest " "
# }


## disable or enable commnad/monitor terminals for specifiying
## interactive values for Step.  When Scenario->Select is seleceted
## disable interactive setting of cmd/mon values, so they will
## not interfere with the scenario.  When Test->Reset is selected
## re-enable them
## 14jun00 wmt
## 11oct00 not used
# proc setStateCmdmonTerminals { stateAction } {
#   global g_NM_allCommandMonitorForms

#   if {[lsearch -exact {enable disable} $stateAction] == -1} {
#     error "setStateCmdmonTerminals: stateAction $ stateAction not handled"
#   }
#   set disableMsg ""; set disableMsg2 ""; set reportNotFoundP 0
#   set newCommandMonitorForms {}
#   foreach cmdMonAlist $g_NM_allCommandMonitorForms {
#     set window [assoc window cmdMonAlist]
#     set direction [assoc direction cmdMonAlist]
#     set buttonNum [assoc buttonNum cmdMonAlist]
#     set buttonWidget $window.$direction.b$buttonNum
#     # puts stderr "\nsetStateCmdmonTerminals: buttonWidget $buttonWidget"
#     if {$stateAction == "disable"} {
#       set button3Bind [bind $buttonWidget <Button-3>]
#       set enterBind [bind $buttonWidget <Enter>]
#       bind $buttonWidget <Button-3> ""
#       bind $buttonWidget <Enter> "pirWarning \"$disableMsg\" \"$disableMsg2\""
#       if {[assoc button3Bind cmdMonAlist $reportNotFoundP] == ""} {
#         # prevent multiple SM File->Open Scenario's from increasing size of list
#         lappend cmdMonAlist button3Bind $button3Bind enterBind $enterBind
#       }
#       lappend newCommandMonitorForms $cmdMonAlist
#     } elseif {$stateAction == "enable"} {
#       # check that SM File->Open Scenario has been done
#       if {[assoc button3Bind cmdMonAlist $reportNotFoundP] != ""} {
#         bind $buttonWidget <Button-3> [assoc button3Bind cmdMonAlist] 
#         bind $buttonWidget <Enter> [assoc enterBind cmdMonAlist]
#       }
#     }
#   }
#   if {$stateAction == "disable"} {
#     set g_NM_allCommandMonitorForms $newCommandMonitorForms
#   }
# }



















