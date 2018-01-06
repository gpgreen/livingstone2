## $Id: canvasBindings.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####
## canvasBindings.tcl: implement the button/mouse actions for the main canvas
##
## Globals: 
##  pirWireFrame : an array containing the information needed to
##     support wire-frame images while moving a node window.


## interpret a dragging motion with Button 1 as an area select operation
## 29jan96 wmt: disable menu items
proc canvasB1StartMotion {c x y} {
  global pirWireFrame g_NM_selectedEdge g_NM_canvasStartMotionP 

  # only if we are not moving an edge
  if {! [string match $g_NM_selectedEdge ""]} { return }
  if {! [componentModuleDefReadOnlyP]} {
    # puts stderr "canvasB1StartMotion $c $x $y"
    set pirWireFrame(curX) [$c canvasx $x]
    set pirWireFrame(curY) [$c canvasy $y]
    $c delete wire
    set g_NM_canvasStartMotionP 1
  }
  disableSelectionMenus
}


## during motion with B1 down, change the lower right corner of the
##   wire frame rectangle
## 11oct95 wmt: change pirWarning call
## 11jul97 wmt: handle node type = mode transition line drawing
proc canvasB1Motion {c x y} {
  global pirWireFrame g_NM_schematicMode
  global g_NM_rootInstanceName g_NM_currentNodeGroup
  global g_NM_mir_gui_ipcP g_NM_selectedEdge
  global g_NM_canvasStartMotionP 
  
  # puts stderr "canvasB1Motion enter"
  # only if we are not moving an edge OR
  # prevent spurious skeletons after File->Open Def dialog
  if {(! [string match $g_NM_selectedEdge ""]) || \
          (! $g_NM_canvasStartMotionP)} {
    return
  }
  # puts stderr "canvasB1Motion $c $x $y"
  ## pirWarning ""; # clear away any warnings
  set x [$c canvasx $x]
  set y [$c canvasy $y]
  if {(! [componentModuleDefReadOnlyP]) && \
          (([string match $g_NM_schematicMode "layout"] && \
                [string match $g_NM_rootInstanceName \
                     [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
               ([string match $g_NM_schematicMode "operational"] && \
                    $g_NM_mir_gui_ipcP)) && \
          ($pirWireFrame(curX) != $x) && ($pirWireFrame(curY) != $y)} {
    $c delete wire
    $c addtag wire withtag [$c create rectangle \
                                $pirWireFrame(curX) \
                                $pirWireFrame(curY) $x $y \
                                -outline [preferred StanleyRubberBandColor]]
  }
}

## when B1 is release on the canvas, we either
##  - select the enclosed nodes, if the mouse has moved since the
##    button was depressed, or
##  - treat the mouse action as a click-in-place action.
## 11oct95 wmt: change pirWarning call
## 07feb96 wmt: use snapToGrid when placing node
## 16may96 wmt: added g_NM_highlightedEdge
## 01jul96 wmt: reset g_NM_processingNodeGroupP
## 02jul96 wmt: implement multiple canvases
## 18jul96 wmt: g_NM_highlightedEdge => g_NM_highlightedEdgeList
proc canvasB1Release {c x y { b "" } { s "" } } {
  global pirWireFrame g_NM_highlightedEdgeList g_NM_processingNodeGroupP
  global g_NM_schematicMode g_NM_canvasIdToPirNode pirEdge
  global g_NM_rootInstanceName g_NM_currentNodeGroup 
  global g_NM_transitionStartPirIndex g_NM_mir_gui_ipcP
  global g_NM_menuStem g_NM_processingFileOpenP g_NM_selectedEdge 
  global g_NM_canvasStartMotionP g_NM_inhibitPirWarningP
  global g_NM_canvasGroupNodeDeleteP pirEdges 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "\ncanvasB1Release: `$backtrace'"
  # puts stderr "  g_NM_processingFileOpenP $g_NM_processingFileOpenP"
  # %b => button number
  # %s => state -- button click that triggered this event B1 -> 256, C-B1 -> 260
  # puts stderr "canvasB1Release: b `$b' s `$s'"
  if {($b == 1) && ($s == 260)} {
    # Control-Button-1 bindings on node windows generate this call
    # Control-Button-1 triggered this call -- ignore it
    return
  }
  set reportNotFoundP 0
  # set str "canvasB1Release: x $x y $y wireX $pirWireFrame(curX)"
  # set str "$str wireY $pirWireFrame(curY)"
  # puts stderr "$str g_NM_processingNodeGroupP $g_NM_processingNodeGroupP"
  # puts stderr "canvasB1Release: g_NM_highlightedEdgeList $g_NM_highlightedEdgeList"
  if {[llength $g_NM_highlightedEdgeList] > 0} {
    foreach pirEdgeIndex $g_NM_highlightedEdgeList {
      # make sure that edge still exists
      if {[lsearch -exact $pirEdges $pirEdgeIndex] >= 0} {
        set canvasId [assoc canvasId pirEdge($pirEdgeIndex)]
        # sometimes even the above check does not catch bad canvasId's
        catch { $c itemconfigure $canvasId \
                    -fill [preferred StanleyNodeConnectionBgColor] }
      }
    }
    set g_NM_highlightedEdgeList {}
  } else {
    # reset moving an edge selection
    # puts stderr "canvasB1Release: g_NM_selectedEdge = null"
    set g_NM_selectedEdge {}
  }
  if {! $g_NM_processingNodeGroupP} {
    standardMouseClickMsg
  }
  if {(! $g_NM_inhibitPirWarningP)} {
    .master.canvas config -cursor top_left_arrow
    update
  }

  # reset creating a mode transition
  # do not do this, since for Dean Oswald (Interface Control Inc -
  # on a LinuxRedHat platform, this zeros out g_NM_transitionStartPirIndex
  # after modeB2StartMotion sets it and modeB2Motion then returns
  # without drawing the transition line.
  # set g_NM_transitionStartPirIndex 0

  # reset deleting a group of nodes/edges with Mouse-L: drag
  set g_NM_canvasGroupNodeDeleteP 0

  if {[string match $g_NM_schematicMode "operational"] && \
          (! $g_NM_mir_gui_ipcP)} {
    set g_NM_processingNodeGroupP 0
    return
  }
#   if {[string match $g_NM_schematicMode "layout"]} {
#     .master.$g_NM_menuStem.links.m entryconfigure "Create 2-Break Connection" -state disabled
#     .master.$g_NM_menuStem.links.m entryconfigure "Create 4-Break Connection" -state disabled
#   }
  # check for ephemeral canvases
  if [ catch { set canvasIdList [$c find overlapping $x $y $x $y] } ] {
    return
  }
  set transitionArrowP 0
  foreach id $canvasIdList {
    set tags [$c itemcget $id -tags] 
    if {[lsearch -exact $tags transitionArrow] >= 0} {
      set transitionArrowP 1
      break
    }
  }

#   if {(! $transitionArrowP) && [string match $g_NM_schematicMode "layout"]} {
#     # do not disable if click is over a component transition arrow
#     .master.$g_NM_menuStem.links.m entryconfigure "Delete Connection" -state disabled
#   }
  # .master.$g_NM_menuStem.links.m entryconfigure "Move Breakpoint for Selected Connection"
  #     -state disabled
  set x [$c canvasx $x]
  set y [$c canvasy $y]
  # puts stderr "canvasB1Release: g_NM_processingNodeGroupP $g_NM_processingNodeGroupP"
  # ensure that canvasB1Release does not create a skeleton rectangle
  # except when there is a selected edge
  # puts stderr "     g_NM_selectedEdge $g_NM_selectedEdge"
  if {$g_NM_processingNodeGroupP && [llength $g_NM_selectedEdge] == 0} {
    # puts stderr "canvasB1Release: set = 0 g_NM_processingNodeGroupP $g_NM_processingNodeGroupP"
    # puts stderr "canvasB1Release: pirWireFrame(curX) $x pirWireFrame(curY) $y"
    set g_NM_processingNodeGroupP 0
    set pirWireFrame(curX) $x
    set pirWireFrame(curY) $y
    $c delete wire
  }
  # puts stderr "canvasB1Release: x $x y $y curX $pirWireFrame(curX) curY $pirWireFrame(curY)"
  # g_NM_processingNodeGroupP must be 0 for node deselection to work
  deselectNodes $c
  deselectModeTransition $c
  if {$g_NM_canvasStartMotionP && \
          ($pirWireFrame(curX) != $x) && ($pirWireFrame(curY) != $y)} {
    if {(! [componentModuleDefReadOnlyP]) && \
            ([string match $g_NM_schematicMode "layout"] && \
                 [string match $g_NM_rootInstanceName \
                      [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
            ([string match $g_NM_schematicMode "operational"] && \
                 $g_NM_mir_gui_ipcP)} {
      # puts stderr "canvasB1Release: create wire"
      $c delete wire
      $c addtag wire withtag [$c create rect \
                                  $pirWireFrame(curX) $pirWireFrame(curY) $x $y \
                                  -outline [preferred StanleyRubberBandColor]]
      
      set canvasIdList ""
      set enclosed [$c find enclosed $pirWireFrame(curX) $pirWireFrame(curY) $x $y]
      # puts stderr "canvasB1Release: find-enclosed $enclosed"
      foreach i $enclosed {
        # puts stderr "canvasB1Release: i $i tags [$c gettags $i]"
        if {[lsearch [$c gettags $i] node] != -1} {
          lappend canvasIdList $i
        }
      }
      # puts stderr "canvasB1Release: canvasIdList `$canvasIdList'"
      set pirNodeIndexList {}
      set canvasIdPirNodeAlist [assoc-array $c g_NM_canvasIdToPirNode $reportNotFoundP]
      # puts stderr "canvasB1Release: canvasIdPirNodeAlist $canvasIdPirNodeAlist"
      foreach canvasId $canvasIdList {
        lappend pirNodeIndexList [assoc-exact $canvasId canvasIdPirNodeAlist]
      }
      if {[llength $pirNodeIndexList] != [llength $canvasIdList]} {
        puts stderr "canvasB1Release: all pirNode indices were not found for canvasId's\!"
        return
      }
      # puts stderr "canvasB1Release: pirNodeIndexList `$pirNodeIndexList'"
      selectNodes $c $pirNodeIndexList
      # set deleting a group of nodes/edges with Mouse-L: drag
      set g_NM_canvasGroupNodeDeleteP 1
    }
  } elseif {[string match $g_NM_schematicMode "layout"]} {
    # puts "canvasB1Release: c $c x $x y $y"
    set gridX [snapToGrid $x "x"]
    set gridY [snapToGrid $y "y"]
    # puts "canvasB1Release: c $c gridX $gridX gridY $gridY"
    canvasB1Click $c $gridX $gridY 
  }
  # reset drawing an enclosing rectangle on the canvas
  set g_NM_canvasStartMotionP 0
} 


## interpret a point/click with Button 1 as a "put selected module here"
## 08oct95 wmt: added call to parseNewNodeState to get additional params
##              for mkNode
## 19oct95 wmt: remove labelWidth from arg list to mkNode
## 20dec95 wmt: add askClassInstance
## 02jan96 wmt: removed call to display_item_completed: bgColor not added
##              to pirNode(n)
## 07feb96 wmt: remove wire frame position check, since snap to grid
##              changes x & y
## 21feb96 wmt: process forall input/output terminals
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 19apr96 wmt: add redrawP arg; return pirNodes index -- n
## 29apr96 wmt: allow other "family" items besides decomponents
##              to be read
## 01oct96 wmt: call updateDefmoduleTerminal
## 25feb98 wmt: add interactiveP to allow creation of nodes with input
##              from Stanley rather than the user (replaces redrawP)
proc canvasB1Click { c x y {interactiveP 1} {paletteClassName ""} \
                         {paletteClassType ""} {oldInstanceName ""} \
                         {calledFrom ""} } {
  global pirWireFrame pirDisplay g_NM_mkformNodeCompleteP 
  global g_NM_classInstance pirNode 
  global g_NM_instantiatableSchematicExtension 
  global g_NM_rootInstanceName g_NM_currentNodeGroup
  global g_NM_terminalInstance 
  global g_NM_livingstoneDefmoduleName g_NM_livingstoneDefmoduleNameVar
  global g_NM_livingstoneDefmoduleArgList 
  global g_NM_fileOperation g_NM_terminalInputs g_NM_terminalOutputs
  global XrootInstanceName XpirNodes XpirNode
  global XpirClass XpirClasses g_NM_vmplTestModeP 
  global pirFileInfo pirGenInt_global g_NM_nodeTypeRootWindow
  global g_NM_processingFileOpenP g_NM_classDefType
  global g_NM_livingstoneDefcomponentName g_NM_paletteTypesAList
  global g_NM_selectedClassType g_NM_selectedClassName
  global g_NM_cfgInputs g_NM_cfgOutputs g_NM_cfgPorts g_NM_cfgAttributes
  global g_NM_instantiateTestModuleP 

  # puts stderr "canvasB1Click: c `$c' x `$x' y `$y'"
  # puts stderr "canvasB1Click module $paletteClassName family $paletteClassType"
  set n 0; set caller "canvasB1Click"
  set reportNotFoundP 0; set oldvalMustExistP 0; set errorDialogP 1
  if {[string match $paletteClassName ""]} {
    set paletteClassName $g_NM_selectedClassName 
  }
  if {[string match $paletteClassType ""]} {
    set paletteClassType $g_NM_selectedClassType
  }
  # puts stderr "canvasB1Click after module $paletteClassName family $paletteClassType"
  # deselect so user doesn't accidentally create another instance later on
  set g_NM_selectedClassType {}; set g_NM_selectedClassName {}
  # puts stderr "canvasB1Click: className $paletteClassName classType $paletteClassType"
  if {$paletteClassName != ""} {
    set paletteClassTypeDir [assoc $paletteClassType g_NM_paletteTypesAList]
    if {(! [string match $paletteClassTypeDir [preferred defcomponents_directory]]) && \
            (! [string match $paletteClassTypeDir [preferred defmodules_directory]]) && \
            (! [string match $paletteClassTypeDir [preferred terminals_directory]]) && \
            (! [string match $paletteClassTypeDir [preferred attributes_directory]]) && \
            (! [string match $paletteClassTypeDir [preferred modes_directory]])} {
      # e.g. structure, defsymbol-expansion, & defvalues
      # set filePath [getSchematicDirectory family $paletteClassTypeDir]
      # append filePath "/$paletteClassName$pirFileInfo(suffix)"
      # showPaletteItem $filePath $paletteClassTypeDir $paletteClassName $x $y
    } else {
      if {[string match $oldInstanceName ""] && \
              (! [string match $g_NM_rootInstanceName \
                      [getCanvasRootInfo g_NM_currentNodeGroup]])} {
        set text [getRootClassNameErrorString]
        set dialogList [list tk_dialog .d "ERROR" $text error 0 {DISMISS}]
        eval $dialogList
        .master.canvas config -cursor top_left_arrow
        update
        return
      }
      # common inits
      set mkNodeArgList {}; set nodeConfig {}
      set inputs {}; set outputs {}
      set inputLabels {}; set outputLabels {}
      if {[string match $paletteClassTypeDir [preferred defcomponents_directory]] || \
              [string match $paletteClassTypeDir [preferred defmodules_directory]]} {
        # get info from .scm files for components & modules
        set className $paletteClassName
        if {[string match $paletteClassTypeDir [preferred defcomponents_directory]]} {
          set classType component
        } else {
          set classType module 
        }
        addClassTypeToList $classType $className mkNodeArgList 

       # this is needed since fileOpen is not recursive -- it is on
        # demand from openNodeGroup -- always read .i-scm file or XpirNode
        # structures get corrupted
        set schematicFileName $className
        append schematicFileName $g_NM_instantiatableSchematicExtension   
        set schematicFilePath "[getSchematicDirectory family $paletteClassTypeDir]/"
        append schematicFilePath $schematicFileName 
        if {! [file exists $schematicFilePath]} {
          set str "canvasB1Click: File not found\n$schematicFilePath"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList 
          return 
        }
        initInstantiationVars 
        ## 22jun97 wmt: old .scm files contained  pirGenInt_global which resets it.
        ##              we want it to continually count
        set currentVal $pirGenInt_global

        source $schematicFilePath
        sourcePostProcess $schematicFilePath 

        # puts stderr "canvasB1Click: sourced $schematicFilePath"
        set pirGenInt_global $currentVal
        set classVars [assoc class_variables XpirClass($className)]
        set internalVars {}
        acons class_variables $classVars internalVars 
        acons internal $internalVars nodeConfig 
        set nameVar [getClassVarDefaultValue name_var classVars] 
        if {[string match $paletteClassTypeDir [preferred defcomponents_directory]]} { 
          set nodeState [getClassVarDefaultValue mode classVars] 
        } else {
          set nodeState NIL
        }
        set classArgsVars [getClassVarDefaultValue "args" classVars]
        set classArgsTypes [getClassVarDefaultValue "argTypes" classVars]
      } else {
        # get info from .cfg files for modes, terminals, & attributes
        pirGetModule [cfgpathLinks $paletteClassTypeDir $paletteClassName] nodeConfig 

        # puts stderr "canvasB1Click"; aputs stderr nodeConfig 
        # add parameters to mkNode list
        set mkNodeArgList {} 
        set internalVars [assoc internal nodeConfig]
        set classVars [assoc class_variables internalVars]
        set nodeState [getClassVarDefaultValue mode classVars] 
        set classArgsVars [getClassVarDefaultValue args classVars] 
        set nameVar [getClassVarDefaultValue name_var classVars] 
        # puts stderr "canvasB1Click: internalVars $internalVars"
        set typeAndNameList [getNodeClassTypeAndName internalVars] 
        set classType [lindex $typeAndNameList 0] 
        set className [lindex $typeAndNameList 1] 
        # put classType & className in mkNodeArgList, so it gets into pirNode 
        addClassTypeToList $classType $className mkNodeArgList
      }
      if {[string match $classType ""]} {
        return  
      }
      if {$interactiveP} {
        set g_NM_mkformNodeCompleteP 0
        if {(! [string match $classType "terminal"]) && \
                (! [string match $classType "attribute"]) && \
                (! [string match $classType "mode"])} {
          # defcomponents & defmodules
          # askClassInstance is now done after terminal forms are created
          set g_NM_mkformNodeCompleteP 1
        } else {
          if {[string match $classType "mode"]} {
            askModeInstance $classType $className 0 $caller
          } else {
            askTerminalInstance $classType $className 0 $caller
          }
        }
      }
      if {$g_NM_mkformNodeCompleteP} {
        if {[string match $classType "terminal"] || \
                [string match $classType "attribute"] || \
                [string match $classType "mode"]} {
          set inTerminalForms [getClassVarDefaultValue input_terminals classVars]
          set outTerminalForms [getClassVarDefaultValue output_terminals classVars]
          set portTerminalForms [getClassVarDefaultValue port_terminals classVars]
          set classArgsVars ""; set classArgsValues "" 
          set terminalName [lindex $g_NM_terminalInstance 0]
          set terminalType [lindex $g_NM_terminalInstance 1]
          set terminalDoc [lindex $g_NM_terminalInstance 2]
          set instanceName  $terminalName
          set instanceLabel {}
          lappend g_NM_terminalInstance $instanceName
          acons nodeDescription $terminalDoc mkNodeArgList
          if {[string match $classType "attribute"]} {
            set attributeFacts [lindex $g_NM_terminalInstance 3]
            acons facts "\{$attributeFacts\}" mkNodeArgList
          }
          set outTerminalForms {}; set inTerminalForms {}; set portTerminalForms {}
          if {[string match $classType "mode"]} {
            set modeModel [lindex $g_NM_terminalInstance 3]
            acons model "\{$modeModel\}" mkNodeArgList
            if {[string match $className "faultMode"]} {
              set modeProb [lindex $g_NM_terminalInstance 4]
              acons probability $modeProb mkNodeArgList
            }
          } else {
            set terminalLabel [lindex $g_NM_terminalInstance 4]
            set instanceLabel $terminalLabel
            set commandMonitorType [lindex $g_NM_terminalInstance 5]
            set interfaceType [lindex $g_NM_terminalInstance 6]
            set terminalForm [list [list $terminalType $terminalName $terminalLabel \
                                        $commandMonitorType $interfaceType]]
            # pass internal instance name
            set safeTerminalForm $terminalForm 
            # puts stderr "canvasB1Click: terminalForm $terminalForm"
            if {[string match $className "input"] || \
                    [string match $className "attribute"] || \
                    [string match $className "displayState"]} {
              ## directional sense is opposite
              set outTerminalForms $safeTerminalForm 
            } elseif {[string match $className "output"]} {
              ## directional sense is opposite
              set inTerminalForms $safeTerminalForm
            } elseif {[string match $className "port"]} {
              set portTerminalForms $safeTerminalForm
            } else {
              set str "canvasB1Click: for classType $classType, className"
              puts stderr "$str $className not handled\!"
            }
          }
          set terminalInputs {}; set terminalOutputs {}
          set numInputs 0; set numOutputs 0
          getTerminalInputsOutputs inTerminalForms outTerminalForms \
              portTerminalForms terminalInputs terminalOutputs $classType $className \
              numInputs numOutputs
          set nameVar $g_NM_rootInstanceName 
        } else {
          # get input/output terminals from root node of instantiated
          # component/module node group (sourced above), rather than from
          # class definition
          foreach XpirNodeIndex $XpirNodes {
            if {[string match [assoc nodeInstanceName XpirNode($XpirNodeIndex)] \
                     $XrootInstanceName]} {
              set Xinputs [assoc inputs XpirNode($XpirNodeIndex)]
              # puts stderr "canvasB1Click: Xinputs $Xinputs"
              set terminalInputs [alist-values Xinputs]
              set numInputs [llength $terminalInputs]
              set Xoutputs [assoc outputs XpirNode($XpirNodeIndex)]
              set terminalOutputs [alist-values Xoutputs]
              set numOutputs [llength $terminalOutputs]
              set attributes [assoc attributes XpirNode($XpirNodeIndex)]
              acons attributes $attributes mkNodeArgList
              # puts stderr "canvasB1Click:  get input/output terminals for $XrootInstanceName"
              break
            }
          }
        }
        set inLabelIndex 1; set outLabelIndex 1
        ## out1 {type STATUS-VALUES terminal_name (STATUS-OUT ?name)}
        for {set i 0} {$i < $numInputs} {incr i} {
          lappend inputLabels "in$inLabelIndex"
          lappend inputs "in$inLabelIndex" [lindex $terminalInputs $i]
          incr inLabelIndex
        }
        acons numInputs $numInputs mkNodeArgList 
        acons inputLabels $inputLabels mkNodeArgList
        # puts stderr "canvasB1Click: numInputs $numInputs inputs $inputs"
        acons inputs $inputs mkNodeArgList 
        for {set i 0} {$i < $numOutputs} {incr i} {
          lappend outputLabels "out$outLabelIndex"
          lappend outputs "out$outLabelIndex" [lindex $terminalOutputs $i]
          incr outLabelIndex
        }
        # puts stderr "outputs $outputs"
        acons numOutputs $numOutputs mkNodeArgList 
        acons outputLabels $outputLabels mkNodeArgList
        acons outputs $outputs mkNodeArgList  
        if {([string match $classType "terminal"] || \
                 [string match $classType "attribute"]) && \
                [string match $g_NM_rootInstanceName \
                     [getCanvasRootInfo g_NM_currentNodeGroup]]} {
          updateDefmoduleDefcomponentTerminal $className $terminalName
        }

        # now that terminals are prepared, ask user for parameters
        if {(! [string match $classType "terminal"]) && \
                (! [string match $classType "attribute"]) && \
                (! [string match $classType "mode"])} {
          # defcomponents & defmodules
          if {! [string match $oldInstanceName ""]} {
            # since this is a current, possibly modified instance of the
            # class, use the current terminal configuration, rather than
            # the class default
            set oldInstancePirNodeIndex ""; set oldInstanceNodeClassType ""
            getComponentModulePirNodeIndex $oldInstanceName \
                oldInstancePirNodeIndex oldInstanceNodeClassType
            arepl numInputs [assoc numInputs pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList 
            arepl inputLabels [assoc inputLabels pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList
            arepl inputs [assoc inputs pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList 
            arepl numOutputs [assoc numOutputs pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList 
            arepl outputLabels [assoc outputLabels pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList
            arepl outputs [assoc outputs pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList
            arepl attributes [assoc attributes pirNode($oldInstancePirNodeIndex)] \
                mkNodeArgList
            set oldArgsValues [assoc argsValues pirNode($oldInstancePirNodeIndex)]
            # puts stderr "canvasB1Click: oldInstanceName outputs [assoc outputs mkNodeArgList]"
          }
          if {$interactiveP} {
            if {(! $g_NM_vmplTestModeP) || \
                    ($g_NM_vmplTestModeP && (! $g_NM_instantiateTestModuleP)) || \
                    ($g_NM_vmplTestModeP && $g_NM_instantiateTestModuleP && \
                         ([llength $classArgsVars] > 0))} {
              # for g_NM_vmplTestModeP = 1, ask for arg values
              set g_NM_mkformNodeCompleteP 0
              # oldInstanceName is deleted in classInstanceUpdate
              
              askClassInstance $classType $className $classArgsVars $classArgsTypes \
                  $caller $oldInstanceName
            }
          } elseif {! [string match $oldInstanceName ""]} {
            ## delete old instance when interactiveP == 0
            set reportNotFoundP 0; set oldvalMustExistP 0; set nodesOnlyP 1
            set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
            arepl selectedNodes $oldInstancePirNodeIndex pirDisplay \
                $reportNotFoundP $oldvalMustExistP
            editCut $currentCanvas.c $nodesOnlyP
          }
          if {$g_NM_mkformNodeCompleteP} {
            if {! [string match $nameVar ""]} {
              set instanceName [lindex $g_NM_classInstance 0]
              set instanceLabel [lindex $g_NM_classInstance 1]
              acons nodeDescription [lindex $g_NM_classInstance 2] mkNodeArgList
              set classArgsValues [lindex $g_NM_classInstance 3]
              # puts stderr "canvasB1click: classArgsValues $classArgsValues"
            } else {
              set instanceName $XrootInstanceName
              set classArgsValues ""; acons nodeDescription "" mkNodeArgList
            }
           
            if {! [string match $oldInstanceName ""]} {
              # editing existing instance
              # substitute instanceName for oldInstanceName in terminal forms
              # oldInstanceName may have imbedded "?"s
              set regExpVarList [list $oldInstanceName]
              set regExpValueList [list $instanceName]
              set regExpVarList [concat $regExpVarList $oldArgsValues]
              set regExpValueList [concat $regExpValueList $classArgsValues]
            } else {
              # instantiation
              # substitute instanceName for nameVar in terminal forms
              # nameVar may have leading "?"
              set regExpVarList [list $nameVar]
              set regExpValueList [list $instanceName]
              # and to handle terminals which have classArgsVars in them
              set regExpVarList [concat $regExpVarList $classArgsVars]
              set regExpValueList [concat $regExpValueList $classArgsValues]
            }
            # do this with high-fidelity replacement (avoid acs & acs-a problems)
            set oldInstanceNameListDot {}; set oldInstanceNameListSpace {}
            set nameVarValueListDot {}; set nameVarValueListSpace {}
            # puts stderr "canvasB1Click: vars $regExpVarList values $regExpValueList"
            # puts stderr "canvasB1Click: classVars $classVars"
            buildRegsubVarValueLists regExpVarList regExpValueList \
                oldInstanceNameListDot oldInstanceNameListSpace \
                nameVarValueListDot nameVarValueListSpace 

            set inputs [assoc inputs mkNodeArgList]
            set outputs [assoc outputs mkNodeArgList]
            # puts stderr "\ncanvasB1Click: B inputs $inputs"
            applyRegsub inputs \
                oldInstanceNameListDot oldInstanceNameListSpace \
                nameVarValueListDot nameVarValueListSpace 
            applyRegsub outputs \
                oldInstanceNameListDot oldInstanceNameListSpace \
                nameVarValueListDot nameVarValueListSpace 

            set attributes [assoc attributes mkNodeArgList]
            applyRegsub attributes \
                oldInstanceNameListDot oldInstanceNameListSpace \
                nameVarValueListDot nameVarValueListSpace 
            # puts stderr "canvasB1Click: A attributes $attributes"
            arepl attributes $attributes mkNodeArgList

            # handle parameter substitution in background_model, initially, & facts
            # askLivingstoneDefcomponentParams & askLivingstoneDefmoduleParams
            set skipNameVarP 1
            if {$classType == "component"} {
              set componentSubList \
                  [list background_model \
                       [getClassVarDefaultValue background_model classVars] \
                       initially [getClassVarDefaultValue initially classVars]]
              applyRegsub componentSubList \
                  oldInstanceNameListDot oldInstanceNameListSpace \
                  nameVarValueListDot nameVarValueListSpace $skipNameVarP
              arepl background_model [assoc background_model componentSubList] \
                  mkNodeArgList $reportNotFoundP $oldvalMustExistP
              # puts stderr "canvasB1Click: background_model [assoc background_model componentSubList] "
              arepl initially [assoc initially  componentSubList] \
                  mkNodeArgList $reportNotFoundP $oldvalMustExistP
            }
            if {$classType == "module"} {
              set moduleSubList \
                  [list facts [getClassVarDefaultValue facts classVars]]
              applyRegsub moduleSubList \
                  oldInstanceNameListDot oldInstanceNameListSpace \
                  nameVarValueListDot nameVarValueListSpace $skipNameVarP
              arepl facts [assoc facts moduleSubList] \
                  mkNodeArgList $reportNotFoundP $oldvalMustExistP
            }
            if {[string match $oldInstanceName ""]} {
              # apply terminal inheritance to instantiation of class instance
              # if this is a new instantiation, only (not an existing instance name)
              set instance_inputs $inputs
              set instance_outputs $outputs
              set local_class_inputs $inputs 
              set local_class_outputs $outputs
              applyTerminalInheritance $instanceName \
                  $classType $className $regExpVarList $regExpValueList \
                  $instanceLabel instance_inputs instance_outputs \
                  local_class_inputs local_class_outputs inputs numInputs \
                  outputs numOutputs
            # puts stderr "\ncanvasB1Click: A inheritance inputs $inputs"
            }
            arepl inputs $inputs mkNodeArgList 
            arepl numInputs [expr {[llength $inputs] / 2}] mkNodeArgList 
            arepl outputs $outputs mkNodeArgList 
            arepl numOutputs [expr {[llength $outputs] / 2}] mkNodeArgList 
          } else {
            return
          }
        }
        # puts stderr "\n\ncanvasB1Click: instanceName $instanceName inputs $inputs outputs $outputs"
        acons argsValues $classArgsValues mkNodeArgList 
        acons numArgsVars [llength $classArgsVars] mkNodeArgList
        lappend mkNodeArgList nodeInstanceName $instanceName \
            nodeState $nodeState nodeStateBgColor nil nodeClassName $className \
            fgColor black instanceLabel $instanceLabel
        # puts stderr "canvasB1Click mkNodeArgList $mkNodeArgList"
        set outputMsgP 1; set callerRedrawP 0
        set nodeX [assoc nodeX mkNodeArgList $reportNotFoundP]
        if {$nodeX  == ""} { set nodeX 0 }
        set nodeY [assoc nodeY mkNodeArgList $reportNotFoundP]
        if {$nodeY  == ""} { set nodeY 0 }
        set labelX [assoc labelX mkNodeArgList $reportNotFoundP]
        if {$labelX  == ""} { set labelX -1 } else {
          set labelX [expr {$labelX + $x - $nodeX}]
        }
        set labelY [assoc labelY mkNodeArgList $reportNotFoundP]
        if {$labelY == ""} { set labelY -1 } else {
          set labelY [expr {$labelY + $y - $nodeY}]
        }

        set n [mkNode $c $x $y $labelX $labelY mkNodeArgList $classType \
                   $outputMsgP $callerRedrawP $oldInstanceName] 
        if {$n == -1} {
          # instance already exists 
          return 
        }
        set nodeStruct [concat $pirNode($n) $nodeConfig]
        set internalVars [assoc internal nodeStruct] 
        adel internal nodeStruct 
        set pirNode($n) $nodeStruct
        if {[lsearch -exact [getClasses $classType] $className] == -1} { 
          setClass $classType $className internalVars
          setClassValue $classType $className nodeClassType $classType \
              $reportNotFoundP $oldvalMustExistP
          if {[string match $classType "component"]} {
            # create recovery_modes from fault_modes and mode_transitions
            createRecoveryModes $className
          }
          lappendClasses $classType $className 
        }
        if {[string match $classType "module"] || \
                [string match $classType "component"]} {
          set severity 1; set msg2 ""; set trimP 1
          set pirNodeAlist $pirNode($n)
          set canvasRootId 0
          set displayLabel [getDisplayLabel pirNodeAlist labelP $trimP]
          pirWarning [format {Please Wait: %s instance being built --} \
                          $displayLabel] $msg2 $severity
          update
          # set g_NM_terminalInputs $terminalInputs
          # set g_NM_terminalOutputs $terminalOutputs
          # build includedModules form
          set includedModules {}; set recursionLevel 0
          set defmoduleArgsVars {}; set defmoduleArgsValues {}
          set g_NM_processingFileOpenP 1
          acons $instanceName [list nodeClassName $className \
                                   nodeClassType $classType \
                                   pirNodeIndex $n \
                                   argsValues $classArgsValues \
                                   window [assoc window pirNode($n)] \
                                   nodeX $x nodeY $y \
                                   instanceLabel $instanceLabel \
                                   inputs $terminalInputs \
                                   outputs $terminalOutputs] \
              includedModules
          recursiveDefmoduleInstantiation $g_NM_rootInstanceName \
              $includedModules $defmoduleArgsVars \
              $defmoduleArgsValues $caller \
              $recursionLevel $classType $canvasRootId $errorDialogP

          # not needed since overlayCurrentCanvas does not go to lower canvases
          # during File Open
          # changeCanvasToWorkingLevel
          set g_NM_processingFileOpenP 0
          pirWarning ""
        }
      } 
    }
  }
  return $n
}


## interpret a dragging motion with Button 1 as an edge select 
## 06mar96 wmt: new
## 02jul96 wmt: implement multiple canvases
proc edgeB1StartMotion {c x y canvasId pirEdgeIndex} {
  global pirWireFrame pirEdge g_NM_selectedEdge g_NM_canvasGrid
  global g_NM_currentCanvas g_NM_canvasIdToPirEdge
  global g_NM_selectedEdgeMovedP g_NM_canvasGroupNodeDeleteP

  if {[componentModuleDefReadOnlyP] || \
          $g_NM_canvasGroupNodeDeleteP} {
    # do not reset deleting a group of nodes/edges with Mouse-L: drag
    return
  }
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "\nedgeB1StartMotion: `$backtrace'"
  set reportNotFoundP 0
  # set grabTolerance [expr $g_NM_canvasGrid / 2]
  # set grabTolerance [expr {$g_NM_canvasGrid / 5}]
  set grabTolerance 4
  # puts stderr "edgeB1StartMotion: type `$type'"
  set g_NM_selectedEdge {}; set g_NM_selectedEdgeMovedP 0
  # puts stderr "edgeB1StartMotion $canvasId $x $y"
  set pirWireFrame(curX) [$c canvasx $x]
  set pirWireFrame(curY) [$c canvasy $y]

  $c delete wire
  disableSelectionMenus
  # is this a vertical edge segment or a horizontal edge segment
  # puts stderr "edgeB1StartMotion g_NM_selectedEdge $pirEdge($pirEdgeIndex)"
  set fromButtonWidget [assoc buttonFrom pirEdge($pirEdgeIndex)]
  set toButtonWidget [assoc buttonTo pirEdge($pirEdgeIndex)]
  set fromX 0; set fromY 0; set toX 0; set toY 0
  getTerminalLocations $c $fromButtonWidget $toButtonWidget fromX \
      fromY toX toY
  # puts "edgeB1StartMotion fromX $fromX fromY $fromY toX $toX toY $toY"
  if {$fromX > $toX} {
    set maxX $fromX
    set minX $toX
  } else {
    set maxX $toX
    set minX $fromX 
  }
  set interimXYList [assoc interimXYList pirEdge($pirEdgeIndex)]
  set interimY1 [assoc interimY1 interimXYList $reportNotFoundP]
  if {! ([string match $interimY1 ""])} {
    set interimX [assoc interimX interimXYList]
    if {$interimX > $maxX} {
      set maxX $interimX
    }
    if {$interimX < $minX} {
      set minX $interimX
    }
    set interimY2 [assoc interimY2 interimXYList]
    if {$interimY1 > $interimY2} {
      set maxY [expr {$interimY1 - $grabTolerance}]
      set minY [expr {$interimY2 + $grabTolerance}] 
    } else {
      set maxY [expr {$interimY2 - $grabTolerance}]
      set minY [expr {$interimY1 + $grabTolerance}]
    }
    # puts stderr "\nedgeB1StartMotion: x $x y $y minX $minX maxX $maxX minY $minY maxY $maxY"
    # puts stderr "                   interimY1 $interimY1 interimY2 $interimY2"
    # puts stderr "                   toX $toX fromX $fromX toY $toY fromY $fromY"
    if {($y > $minY) && ($y < $maxY)} {
      # puts stderr "edgeB1StartMotion vertical interimX "
      set g_NM_selectedEdge [list $pirEdgeIndex interimX \
                                 [expr {$minY - $grabTolerance}] \
                                 [expr {$maxY + $grabTolerance}] \
                                 [expr {$maxX + $grabTolerance}]]
    } elseif {($y > ($interimY1 - $grabTolerance)) && \
                  ($y < ($interimY1 + $grabTolerance))} {
      # puts stderr "edgeB1StartMotion horizontal interimY1 "
      constrainMinMaxX minX maxX interimY1 $fromX $fromY $toX $toY
      set g_NM_selectedEdge [list $pirEdgeIndex interimY1 $minX $maxX]
    } elseif {($y > ($interimY2 - $grabTolerance)) && \
                  ($y < ($interimY2 + $grabTolerance))} {
      # puts stderr "edgeB1StartMotion horizontal interimY2 "
      constrainMinMaxX minX maxX interimY2 $fromX $fromY $toX $toY
      set g_NM_selectedEdge [list $pirEdgeIndex interimY2 $minX $maxX]
    } else {
      puts stderr "edgeB1StartMotion: 4-break g_NM_selectedEdge not set"
    }
  } else {
    if {($x > $minX) && ($x < $maxX)} {
      # puts stderr "edgeB1StartMotion horizontal interimY "
      set g_NM_selectedEdge [list $pirEdgeIndex interimY $minX $maxX]
    } else {
      puts stderr "edgeB1StartMotion: 2-break g_NM_selectedEdge not set"
    }
  }
  # puts stderr "edgeB1StartMotion: g_NM_selectedEdge $g_NM_selectedEdge"
}


## contrain the minX maxX values to remove extraneous skeleton line extent
## 02noc99 wmt: new
proc constrainMinMaxX { minXRef maxXRef type fromX fromY toX toY } {
  upvar $minXRef minX
  upvar $maxXRef maxX

  if {[string match $type "interimY1"]} {
    if {($toY > $fromY)} {
      if {$fromX > $minX} { set minX $fromX }
      if {$fromX < $maxX} { set maxX $fromX }
      # puts stderr "constrainMinMaxX interimY1 toY > fromY"
    } else {
      # $fromY > $toY
      if {$fromX > $minX} { set minX $fromX }
      if {$fromX < $maxX} { set maxX $fromX }
      # puts stderr "constrainMinMaxX interimY1 fromY > toY"
    }
  } else { ; # interimY2
    if {($toY > $fromY)} {
      if {$toX > $minX} { set minX $toX }
      if {$toX < $maxX} { set maxX $toX }
      # puts stderr "constrainMinMaxX interimY2 toY > fromY"
    } else {
      # $fromY > $toY
      if {$toX > $minX} { set minX $toX }
      if {$toX < $maxX} { set maxX $toX }
      # puts stderr "constrainMinMaxX interimY2 fromY > toY"
    }
  }
}


## 06mar96 wmt: new
## 19dec97 wmt: changed rectangle to restricted 3-sided rectangle 
proc edgeB1Motion {c x y} {
  global pirWireFrame g_NM_selectedEdge pirEdge
  global g_NM_selectedEdgeMovedP

  # puts stderr "edgeB1Motion $x $y g_NM_selectedEdge `$g_NM_selectedEdge'"
  ## pirWarning ""; # clear away any warnings
  if {[componentModuleDefReadOnlyP]} {
    return
  }
  set reportNotFoundP 0
  if {[llength $g_NM_selectedEdge] == 0} {
    return
  }
  set x_or_y [lindex $g_NM_selectedEdge 1]
  set x [$c canvasx $x]
  set y [$c canvasy $y]
  # puts stderr "edgeB1Motion: $pirWireFrame(curX) $x $pirWireFrame(curY) $y"
  if {($pirWireFrame(curX) != $x) && ($pirWireFrame(curY) != $y)} {
    $c delete wire
    set g_NM_selectedEdgeMovedP 1
    set interimXYList [assoc interimXYList \
                           pirEdge([lindex $g_NM_selectedEdge 0])]
    if {[lsearch -exact [list interimY interimY1 interimY2] $x_or_y ] >= 0} {
      set minX [lindex $g_NM_selectedEdge 2]
      set interimX [assoc interimX interimXYList $reportNotFoundP]
      if {! [string match $interimX ""]} {
        if {$x < $interimX} {
          set maxX $interimX
        } else {
          set minX $interimX
          set maxX [lindex $g_NM_selectedEdge 3]
        }
      } else {
        set maxX [lindex $g_NM_selectedEdge 3]
      }
      $c addtag wire withtag [$c create line $minX $y $maxX $y \
                                  -fill [preferred StanleyRubberBandColor]]
      $c addtag wire withtag [$c create line $minX $pirWireFrame(curY) \
                                  $minX $y -fill [preferred StanleyRubberBandColor]]
      $c addtag wire withtag [$c create line $maxX $pirWireFrame(curY) \
                                  $maxX $y -fill [preferred StanleyRubberBandColor]]
      # puts stderr "edgeB1Motion: minX $minX pirWireFrame(curY) $pirWireFrame(curY) maxX $maxX y $y"
      # rectangle => $minX $pirWireFrame(curY) $maxX $y 
    } else {
      set minY [lindex $g_NM_selectedEdge 2] 
      set maxY [lindex $g_NM_selectedEdge 3] 
      $c addtag wire withtag [$c create line $x $minY $x $maxY \
                                  -fill [preferred StanleyRubberBandColor]]
      $c addtag wire withtag [$c create line $pirWireFrame(curX) $minY \
                                  $x $minY -fill [preferred StanleyRubberBandColor]]
      $c addtag wire withtag [$c create line $pirWireFrame(curX) $maxY \
                                  $x $maxY -fill [preferred StanleyRubberBandColor]]
      # puts stderr "edgeB1Motion: pirWireFrame(curX) $pirWireFrame(curX) minY $minY x $x maxY $maxY"
      # rectangle => $pirWireFrame(curX) $minY $x $maxY
    }
  }
}


##  redraw link in new position
## 11oct95 wmt: change pirWarning call
## 06mar96 wmt: new
## 27sep96 wmt: set g_NM_inhibitEdgeTypeMismatchP 1, so moving
##              lines with type mismatch will not generate dialog
proc edgeB1MotionRelease {c x y} {
  global pirWireFrame g_NM_selectedEdge pirEdge
  global g_NM_inhibitEdgeTypeMismatchP
  global g_NM_processingNodeGroupP g_NM_selectedEdgeMovedP

  if {[componentModuleDefReadOnlyP]} {
    return
  }
  set g_NM_inhibitEdgeTypeMismatchP 1
  # prevent input/output/port-declarations update from running
  # when edge is redrawn
  set g_NM_processingNodeGroupP 1
  standardMouseClickMsg
  if {[llength $g_NM_selectedEdge] == 0} {
    # do a canvas Mouse-L click to reset selections and selection highlighting
    canvasEnter 
    return
  }
  set pirEdgeIndex [lindex $g_NM_selectedEdge 0]
  set interimXYList [assoc interimXYList pirEdge($pirEdgeIndex)]
  set x_or_y [lindex $g_NM_selectedEdge 1]
  set x [$c canvasx $x]
  set y [$c canvasy $y]
  if {$g_NM_selectedEdgeMovedP} {
    # puts stderr "edgeB1MotionRelease:"
    if {[lsearch -exact [list interimY interimY1 interimY2] $x_or_y ] >= 0} {
      set minX [lindex $g_NM_selectedEdge 2] 
      set maxX [lindex $g_NM_selectedEdge 3] 
      $c addtag wire withtag [$c create rect \
          $minX $pirWireFrame(curY) $maxX $y \
          -outline [preferred StanleyRubberBandColor]]
      arepl $x_or_y [expr {round( $y)}] interimXYList
    } elseif {[string match $x_or_y interimX]} {
      set minY [lindex $g_NM_selectedEdge 2] 
      set maxY [lindex $g_NM_selectedEdge 3] 
      set maxX [lindex $g_NM_selectedEdge 4]
      # puts stderr "edgeB1MotionRelease minY $minY maxY $maxY maxX $maxX"
      # puts stderr "edgeB1MotionRelease x_or_y $x_or_y x $x y $y"
      $c addtag wire withtag [$c create rect \
          $pirWireFrame(curX) $minY $x $maxY \
          -outline [preferred StanleyRubberBandColor]]
      arepl $x_or_y [expr {round( $x)}] interimXYList
    } else {
      puts stderr "edgeB1MotionRelease x_or_y $x_or_y not handled"
    }
    set numBreaks 0; set jmplModifiedP 0
    set ignoreEdgesFromP 0; set ignoreEdgesToP 0
    set nodeInstanceName ""; set widgetsExistP 1
    # puts stderr "edgeB1MotionRelease interimXYList $interimXYList"
    redrawEdge $c $pirEdgeIndex $ignoreEdgesFromP $ignoreEdgesToP $numBreaks \
        $interimXYList $nodeInstanceName $widgetsExistP
    $c delete wire
    mark_scm_modified $jmplModifiedP 
  }
  # clear all button selections
  set bothP 1; nodePortDeselect $bothP; nodeInDeselect; nodeOutDeselect
  set g_NM_inhibitEdgeTypeMismatchP 0
  set g_NM_processingNodeGroupP 0
}


## create a canvas as a child of .master.canvas
## 29jun96 wmt: new
## 09spe96 wmt: revise to make scroll bars actually work
proc createCanvas { canvasPath { x 0 } { y 0 } { overlayP 1 } \
                        { createOnlyP 0 } } {
  global g_NM_schematicMode g_NM_currentCanvas g_NM_fileOperation
  global g_NM_canvasList g_NM_rootInstanceName 
  global g_NM_mir_gui_ipcP g_NM_vmplTestModeP 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight

  # puts stderr "createCanvas: IN canvasPath $canvasPath"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "createCanvas: `$backtrace'"

  if {[lsearch -exact g_NM_canvasList $canvasPath] >= 0} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "canvas $canvasPath already exists" \
                        error 0 {DISMISS}]
    eval $dialogList
    return 1
  }
  # backward compatibility for schematic files with .canvas.---, 
  # rather than .master.canvas.---
  set canvasRoot {}
  set canvasRootId [getCanvasRootId $canvasPath canvasRoot]
  set oldCanvasPath [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]

  frame $canvasPath
  frame $canvasPath.bottom
  set canvasBgColor [preferred StanleySchematicCanvasBackgroundColor] 
  if {$g_NM_vmplTestModeP} {
    set canvasBgColor [preferred StanleyTestCanvasBackgroundColor]
  }
  canvas $canvasPath.c \
      -scrollregion [list 0 0 $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight] \
      -yscrollcommand "$canvasPath.yscroll set" \
      -xscrollcommand "$canvasPath.bottom.xscroll set" \
      -bg $canvasBgColor 
  scrollbar $canvasPath.yscroll -command "$canvasPath.c yview" \
      -relief sunk -bd 2 
  scrollbar $canvasPath.bottom.xscroll -orient horiz -command "$canvasPath.c xview" \
      -relief sunk -bd 2  
  set bgColor [preferred StanleyLegendBgColor]
  label $canvasPath.bottom.viewlabel -text [displayCanvasLegendText] \
      -relief sunken -bd 2 -bg [preferred StanleyLegendBgColor] \
      -fg [preferred StanleyLegendFgColor] -width 10 -anchor center
  pack $canvasPath.bottom.viewlabel -side left -fill y
  pack $canvasPath.bottom.xscroll -side left -fill x -expand 1
  pack $canvasPath.bottom -side bottom -fill x
  pack $canvasPath.yscroll -side right -fill y
  pack $canvasPath.c -side left -fill both -expand 1 

  set splitList [split $canvasPath "."]
  set currentNodeGroup [lindex $splitList 3]
  if {[string match $g_NM_schematicMode "layout"] || \
          ([string match $g_NM_schematicMode "operational"] && \
               $g_NM_mir_gui_ipcP)} {
      bind $canvasPath.c <Button-1> "canvasB1StartMotion $canvasPath.c %x %y"
      bind $canvasPath.c <B1-Motion> "canvasB1Motion $canvasPath.c %x %y"
  }
  # bind $canvasPath.c <ButtonRelease-1> "canvasB1Release $canvasPath.c %x %y"
  # %b => button number
  # %s => state -- button click that triggered this event B1 -> 256, C-B1 -> 260
  bind $canvasPath.c <ButtonRelease-1> "canvasB1Release $canvasPath.c %x %y %b %s"
  bind $canvasPath.c <Enter> "canvasEnter"
  bind $canvasPath.c <Leave> "canvasLeave"
  if {! [regexp "root" $canvasPath]} {
    lappend g_NM_canvasList $canvasPath
  } else {
    # pack => display .master and .slave_n toplevel windows
    $canvasPath.c config -width [preferred StanleyInitialCanvasWidth] 
    $canvasPath.c config -height [preferred StanleyInitialCanvasHeight] 
    pack $canvasPath -side top -fill both -expand 1
    # the next line is done in mainWindow, so that window mgr shrinking works
    # pack [widgetPathParent $canvasPath] -side top -fill both -expand 1
  }
  if {[llength $g_NM_canvasList] == 0} {
    ## discard wish default toplevel window
    wm withdraw .
  }
  if {! $createOnlyP} {
    if {$overlayP} {
      overlayCurrentCanvas $canvasPath $oldCanvasPath nil $x $y
    } else {
      setCanvasRootInfo g_NM_currentCanvas $canvasPath $canvasRootId 
      # set str "createCanvas: g_NM_currentCanvas $canvasPath"
      # puts stderr "$str canvasRootId $canvasRootId"
    }
  }
  # puts stderr "createCanvas: canvasPath $canvasPath g_NM_canvasList $g_NM_canvasList"
  return 0
}


proc canvasEnter { } {
  global g_NM_processingFileOpenP g_NM_processingNodeGroupP
  global g_NM_initializationCompleteP g_NM_inhibitPirWarningP
  global g_NM_canvasGroupNodeDeleteP 

  # puts stderr "canvasEnter: g_NM_processingFileOpenP $g_NM_processingFileOpenP"
  if {$g_NM_initializationCompleteP && (! $g_NM_processingFileOpenP) && \
          (! $g_NM_inhibitPirWarningP)} {
    # reset everything like mouse-left click on canvas
    # do not reset deleting a group of nodes/edges with Mouse-L: drag
    set canvas [getCanvasRootInfo g_NM_currentCanvas 0].c
    if {(! $g_NM_canvasGroupNodeDeleteP) && [winfo exists $canvas]} {
      # ensure that canvasB1Release does not create a skeleton rectangle
      set g_NM_processingNodeGroupP 1
      canvasB1Release $canvas 0 0
    }
    standardMouseClickMsg    
  }
}


proc canvasLeave { } {
  global g_NM_processingFileOpenP

  # puts stderr "canvasLeave: g_NM_processingFileOpenP $g_NM_processingFileOpenP"
  if {! $g_NM_processingFileOpenP} {
    pirWarning ""
  }
}


## create a node of a given type  at canvas coords x and y. 
##  The module is an alist containing the fields: 
##    label labelWidth numInputs numOutputs ...
## Returns the itemnumber of the node within the canvas
## 09oct95 wmt: pass nodeState to mkNodeIcon; bind lab.label & lab.state
## 19oct95 wmt: remove labelWidth from arg list to mkNodeIcon
## 13nov95 wmt: add nodeShowStateDiagram event binding
## 20dec95 wmt: add g_NM_componentInstances
## 29jun96 wmt: implement multiple canvases
## 26jul96 wmt: determine nodeStateBgColor to override that in .scm file
## 03dec96 wmt: do not produce node if nodeClassName/nodeInstanceName
##              already exists
## 03dec96 wmt: added optional arg outputMsgP
## 10dec96 wmt: added optional arg callerRedrawP
## 07may97 wmt: remove canvas attribute from pirNode; create inputLabels &
##              outputLabels if not present (on calls from pirRedraw)
## 20oct97 wmt: added optional arg oldInstanceName to handle editing
##              instance names of existing instances
proc mkNode {canvas x y labelX labelY mkNodeArgsListRef nodeClassType \
                 {outputMsgP 1} {callerRedrawP 0} {oldInstanceName ""} } {
  upvar 1 $mkNodeArgsListRef mkNodeArgsList
  global pirDisplay pirNodes pirEdges pirNode pirEdge 
  global g_NM_schematicMode g_NM_processingNodeGroupP 
  global g_NM_currentNodeGroup g_NM_parentNodeGroupList
  global g_NM_rootInstanceName g_NM_vmplTestModeP 
  global g_NM_nodeTypeRootWindow g_NM_nodeGroupToInstances
  global g_NM_instanceToNode g_NM_classDefType
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_terminalTypeValuesArray g_NM_commandMonitorTypesList
  global g_NM_selectedTestModule pirClassComponent
  global g_NM_nodeHasIconP g_NM_smartBoardPC g_NM_showIconLabelBalloonsP 

  set reportNotFoundP 0; set oldvalMustExistP 0; set returnIndexP 1
  set callerMkNodeP 1; set caller mkNode; set canvasRoot {}
  set canvasRootId [getCanvasRootId $canvas canvasRoot]
  # set str "\nmkNode: canvas $canvas nodeInstanceName"
  # puts stderr  "$str [assoc nodeInstanceName mkNodeArgsList]"
  # puts stderr "mkNode: mkNodeArgsList $mkNodeArgsList "
  # puts stderr "mkNode: oldInstanceName $oldInstanceName"
  # puts stderr "mkNode: mkNodeArgsList $mkNodeArgsList"
  # puts stderr "mkNode: nodeGroupName [assoc nodeGroupName mkNodeArgsList]"
  # puts stderr  "    currentCanvas [getCanvasRootInfo g_NM_currentCanvas]"
  # puts stderr  "mkNode: x $x y $y labelX $labelX labelY $labelY"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "mkNode: `$backtrace'"
  set nodeInstanceName [assoc nodeInstanceName mkNodeArgsList]
  set nodeClassName [assoc nodeClassName mkNodeArgsList]
  if {($canvasRootId == 0) && [string match $oldInstanceName ""] && \
          [checkClassInstance $nodeClassName $nodeInstanceName $outputMsgP]} {
    return -1
  }
  # do not create input/output/port terminals for component or module
  # if those terminals are of class name *TERMINATOR
  # removeTerminatorTerminals mkNodeArgsList 

  set numInputs [assoc numInputs mkNodeArgsList]
  set numOutputs [assoc numOutputs mkNodeArgsList]
  set parentNodeGroupListIndex [assoc parentNodeGroupList mkNodeArgsList \
                                    $reportNotFoundP $returnIndexP]
  if {$parentNodeGroupListIndex == -1} {
    lappend mkNodeArgsList parentNodeGroupList \
        [getCanvasRootInfo g_NM_parentNodeGroupList]
  }
  # parentNodeGroupList required by getDisplayLabel 
  set displayLabel [getDisplayLabel mkNodeArgsList labelP]
  set nodeState [assoc nodeState mkNodeArgsList] 
  # set str "mkNode nodeInstanceName $nodeInstanceName"
  # puts stderr "$str displayLabel `$displayLabel' nodeState $nodeState"
  # puts stderr "$str numInputs $numInputs numOutputs $numOutputs"
  # puts stderr "\n\nmkNode: mkNodeArgsList $mkNodeArgsList"

  # check for immediate children attributes of component/modules
  set childAttributesP 0
  if {([string match $nodeClassType component] || \
           ([string match $nodeClassType module] && \
                (! [string match $nodeState "parent-link"])))} {
    set childAttributesP 1
  }

  set windo \
      [mkNodeIcon $canvas $displayLabel $numInputs $numOutputs \
           $nodeState  $nodeClassName [assoc inputs mkNodeArgsList] \
           [assoc outputs mkNodeArgsList] $nodeClassType \
           $childAttributesP iconLabel]
  set canvasId \
      [$canvas create window $x $y -anchor nw -tags node -window $windo]
  update
  if {$iconLabel != ""} {
    # create a canvas text object for the icon label
    set xOffset "default"; set yOffset "default"; set balloonType iconLabel
    set constraintP 1
#     if {$displayLabel == "sspcController28vA2"} {
#       puts stderr "\nmkNode: iconLabel $iconLabel labelX $labelX labelY $labelY "
#     }
    set labelWindow [mkCanvasLabelBalloon $windo $x $y $iconLabel $canvas labelX \
                         labelY $balloonType $constraintP $xOffset $yOffset]
#     if {$displayLabel == "sspcController28vA2"} {
#       puts stderr "      labelX $labelX labelY $labelY "
#     }
    # initially created as invisible -- cannot bury or lower it below canvas
    # and canvas windows obscure other canvas objets, so move it off screen
    set labelCanvasId \
        [$canvas create window $labelX $labelY -anchor nw -tags iconLabels \
             -window $labelWindow]
    # puts stderr "mkNode: labelX $labelX labelY $labelY labelCanvasId $labelCanvasId "
    if {! $g_NM_showIconLabelBalloonsP} {
      $canvas move $labelCanvasId $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight
      set seenValue 0
    } else {
      # in case the Show Labels accelerator has been selected
      # set this to -1 so that selectNode & deselectNode will NOT change the label
      set seenValue -1
    }
  }

  if {$canvasRootId == 0} {
    # puts stderr "mkNode nodeClassType $nodeClassType box $box windo $windo"
    ## multiple canvases each are numbered unrelated to the others, so we must
    ## ensure a unique number for pirNode & pirNodes
    set pirNodeIndex [uniquePirNodeIndex $canvasId]
    # puts stderr "mkNode: canvas $canvas canvasId $canvasId pirNodeIndex $pirNodeIndex"
    lappend pirNodes $pirNodeIndex

    set moreAlistPairs [list nodeX $x nodeY $y labelX $labelX labelY $labelY \
                            window $windo canvasId $canvasId]
    if {$iconLabel != ""} {
      lappend moreAlistPairs labelCanvasId $labelCanvasId labelWindow $labelWindow \
          labelWindowSeenP $seenValue  
    }
    if {[assoc inputLabels mkNodeArgsList $reportNotFoundP $returnIndexP] == -1} {
      set inputLabels [get_label_names [assoc inputs mkNodeArgsList]]
      lappend moreAlistPairs inputLabels $inputLabels
    }
    if {[assoc outputLabels mkNodeArgsList $reportNotFoundP $returnIndexP] == -1} {
      set outputLabels [get_label_names [assoc outputs mkNodeArgsList]]
      lappend moreAlistPairs outputLabels $outputLabels
    }
    # old attribute nodes with no facts pair
    if {[string match $nodeClassType attribute] && \
            ([assoc facts mkNodeArgsList $reportNotFoundP $returnIndexP] == -1)} {
      lappend moreAlistPairs facts {}
    }
    if {[string match $nodeClassType component] && \
            ([assoc transitionModesToDraw mkNodeArgsList $reportNotFoundP \
                  $returnIndexP] == -1)} {
      lappend moreAlistPairs transitionModesToDraw {}
    }
    # the following is here rather than having to be in both
    # instantiateDefmoduleFromIscm and pirRedraw (both call mkNode)
    if {([lsearch -exact {terminal component module} $nodeClassType] >= 0) && \
            ([assoc nodeState mkNodeArgsList] != "parent-link")} {
      set newInputs {}; set index 0
      foreach terminalForm [assoc inputs mkNodeArgsList] {
        if {$index % 2} {
#           if {[assoc terminal_label terminalForm $reportNotFoundP \
#                    $returnIndexP] == -1} {
#             arepl terminal_label {} terminalForm $reportNotFoundP \
#                 $oldvalMustExistP
#           }
#           if {[assoc commandMonitorType terminalForm $reportNotFoundP \
#                    $returnIndexP] == -1} {
#             arepl commandMonitorType [assoc commandMonitorType mkNodeArgsList] \
#                 terminalForm $reportNotFoundP $oldvalMustExistP
#           }
          set cmdMonTypeValueList [assoc commandMonitorType terminalForm]
          if {[lindex $cmdMonTypeValueList 0] == "command"} {
            set cmdMonTypeValueList [lreplace $cmdMonTypeValueList 0 0 "commanded"]
            arepl commandMonitorType $cmdMonTypeValueList terminalForm 
          } elseif {[lindex $cmdMonTypeValueList 0]  == "monitor"} {
            set cmdMonTypeValueList [lreplace $cmdMonTypeValueList 0 0 "monitored"]
            arepl commandMonitorType $cmdMonTypeValueList terminalForm
          }
          # ensure that multi-dimensional types have multi-dimensional default values
          checkTerminalFormCmdMonValues terminalForm 
        }
        lappend newInputs $terminalForm
        incr index
      }
      arepl inputs $newInputs mkNodeArgsList 
      set newOutputs {}; set index 0
      foreach terminalForm [assoc outputs mkNodeArgsList] {
        if {$index % 2} {
#           if {[assoc terminal_label terminalForm $reportNotFoundP \
#                    $returnIndexP] == -1} {
#             arepl terminal_label {} terminalForm $reportNotFoundP \
#                 $oldvalMustExistP
#           }
#           if {[assoc commandMonitorType terminalForm $reportNotFoundP \
#                    $returnIndexP] == -1} {
#             arepl commandMonitorType [assoc commandMonitorType mkNodeArgsList] \
#                 terminalForm $reportNotFoundP $oldvalMustExistP
#           }
          set cmdMonTypeValueList [assoc commandMonitorType terminalForm]
          if {[lindex $cmdMonTypeValueList 0] == "command"} {
            set cmdMonTypeValueList [lreplace $cmdMonTypeValueList 0 0 "commanded"]
            arepl commandMonitorType $cmdMonTypeValueList terminalForm 
          } elseif {[lindex $cmdMonTypeValueList 0]  == "monitor"} {
            set cmdMonTypeValueList [lreplace $cmdMonTypeValueList 0 0 "monitored"]
            arepl commandMonitorType $cmdMonTypeValueList terminalForm
          }
          # ensure that multi-dimensional types have multi-dimensional default values
          checkTerminalFormCmdMonValues terminalForm 
        }
        lappend newOutputs $terminalForm
        incr index
      }
      arepl outputs $newOutputs mkNodeArgsList
    }

    set pirNode($pirNodeIndex) [concat $mkNodeArgsList $moreAlistPairs]
    # puts "\nmkNode: pirNodeIndex $pirNodeIndex $pirNode($pirNodeIndex)"

    set templist {}
    for {set i 0} {$i < [assoc numInputs mkNodeArgsList]} {incr i} {
      lappend templist {}; # in edges are lists
    }
    acons edgesTo $templist pirNode($pirNodeIndex)
    set templist {}
    for {set i 0} {$i < [assoc numOutputs mkNodeArgsList]} {incr i} {
      lappend templist {}; # out edges are lists
    }
    acons edgesFrom $templist pirNode($pirNodeIndex)

    # nodeHealthState & nodePower are no longer used 03mar98
    adel nodeHealthState pirNode($pirNodeIndex) $reportNotFoundP
    adel nodePower pirNode($pirNodeIndex) $reportNotFoundP

    if {[string match $g_NM_schematicMode "operational"] && \
            ([string match $nodeClassType "component"] || \
                 [string match $nodeClassType "module"])} {
      arepl nodePropList {} pirNode($pirNodeIndex) $reportNotFoundP \
          $oldvalMustExistP
    } else {
      # does not apply to terminals, and attributes 
      # or in layout mode
      adel nodePropList pirNode($pirNodeIndex) $reportNotFoundP
    }
    set nodeStateBgColor [getNodeStateBgColor $pirNodeIndex $callerMkNodeP]
    arepl nodeStateBgColor $nodeStateBgColor pirNode($pirNodeIndex)

    arepl nodeHasIconP $g_NM_nodeHasIconP pirNode($pirNodeIndex) \
        $reportNotFoundP $oldvalMustExistP

  } else {
    if {[string match [assoc nodeState mkNodeArgsList] "parent-link"]} {
      set nodeGroupName [getGroupNameFromWidgetPath $canvas]
      # first name:index pair is the parent node
      set nodeGroup [assoc-array $nodeGroupName g_NM_nodeGroupToInstances]
      set pirNodeIndex [lindex $nodeGroup 1]
      # force slave parent instance name to be the same as master
      # so that bindings that pass the instance name will refer to the
      # master (and only) pirIndex, via g_NM_instanceToNode
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    } else {
      set pirNodeIndex [assoc-array $nodeInstanceName g_NM_instanceToNode]
    }
  }
  ## window pirNodeIndex alist is used by theItemContaining which is called
  ## by mkEdge, which is called by pirRedraw, so it is needed in all
  ## g_NM_schematicMode modes
  ## acons $windo $pirNodeIndex pirDisplay

  ## theItemContaining is replaced by getPirNodeIndexFromWindowPath 
  ## which is built in addClassInstance 

  # when $oldInstanceName != "", addClassInstance is called in
  # editComponentModule. this indexing into cross-ref global vars
  # does not work properly if two instances of nodeInstanceName exist at
  # the same time -- which happens when an existing instance is renamed
  # if {[string match $oldInstanceName ""]}
  # 13mar98 wmt: it seems to work now, and fixes a problem with calling
  # node_color_config
  update
  addClassInstance $nodeClassName $nodeInstanceName $pirNodeIndex $canvasId \
      $canvas $windo
  
  if {($canvasRootId == 0) && (! [string match $oldInstanceName ""])} {
    set nodeGroupNameIndex [assoc nodeGroupName pirNode($pirNodeIndex) \
                                $reportNotFoundP $returnIndexP]
    if {$nodeGroupNameIndex == -1} {
      acons nodeGroupName [getCanvasRootInfo g_NM_currentNodeGroup] \
          pirNode($pirNodeIndex)
    }
  }
  node_color_config $windo pirNode($pirNodeIndex) $numInputs $numOutputs
  
  set currentNodeGroup [assoc nodeGroupName pirNode($pirNodeIndex)]
  # puts stderr "mkNode: currentNodeGroup $currentNodeGroup"
  if {[string match $currentNodeGroup root]} {
    set groupDefType $g_NM_classDefType
  } else {
    set groupPirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
    # puts stderr "mkNode: groupPirNodeIndex $groupPirNodeIndex"
    set groupDefType [assoc nodeClassType pirNode($groupPirNodeIndex)]
  }
  # puts stderr "mkNode: groupDefType $groupDefType"

  set topLevelNodeP [expr {[string match $g_NM_rootInstanceName \
                                [assoc nodeGroupName pirNode($pirNodeIndex)]]}]
  
  if {[string match $g_NM_schematicMode "layout"] && $topLevelNodeP} {
    set b1Start "nodeStartMotion $canvas $windo %x %y"
    set b1Motion "nodeMotion $canvas %x %y"
    set b1Release "nodeMotionRelease $canvas $canvasId $pirNodeIndex %x %y"
  } else {
    set b1Start ""
    set b1Motion "" 
    set b1Release ""
  }
  bind $windo.lab.label <Button-1> $b1Start
  bind $windo.lab.label <B1-Motion> $b1Motion
  bind $windo.lab.label <ButtonRelease-1> $b1Release
  bind $windo.lab.icon <Button-1> $b1Start
  bind $windo.lab.icon <B1-Motion> $b1Motion 
  bind $windo.lab.icon <ButtonRelease-1> $b1Release

  if {$iconLabel != ""} {
    if {[string match $g_NM_schematicMode "layout"] && $topLevelNodeP} {
      set b1Start "nodeStartMotion $canvas $labelWindow %x %y"
      set b1Motion "nodeMotion $canvas %x %y"
      set b1Release "nodeMotionRelease $canvas $labelCanvasId $pirNodeIndex %x %y"
    } else {
      set b1Start ""
      set b1Motion "" 
      set b1Release ""
    }
    bind $labelWindow.label <Button-1> $b1Start
    bind $labelWindow.label <B1-Motion> $b1Motion
    bind $labelWindow.label <ButtonRelease-1> $b1Release
  }

  if {[string match $nodeClassType "component"]} {
    bind $windo.lab.label <Control-Button-1> \
        "openNodeGroup $nodeInstanceName $nodeClassType $windo"
    bind $windo.lab.icon <Control-Button-1> \
        "openNodeGroup $nodeInstanceName $nodeClassType $windo"
    set selectLabelList [list l1 [list editOrView displayLabel] \
                             l2 [list delete displayLabel]]
    set selectCmdList [list c1 [list editComponentModule $pirNodeIndex] \
                           c2 [list deleteNode $nodeClassType $pirNodeIndex]]
    if {[string match $g_NM_schematicMode "operational"]} {
      lappend selectLabelList l3 [list show displayLabel mode & propositions]
      lappend selectCmdList c3 [list nodeShowModeAndProps $windo.lab.label \
                                          $pirNodeIndex $nodeClassType]              
    }
    bind $windo.lab.label <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"
    bind $windo.lab.icon <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"

  } elseif {[string match $nodeClassType "module"]} {
    bind $windo.lab.label <Control-Button-1> \
        "openNodeGroup $nodeInstanceName $nodeClassType $windo"
    bind $windo.lab.icon <Control-Button-1> \
        "openNodeGroup $nodeInstanceName $nodeClassType $windo"
    set selectLabelList [list l1 [list editOrView displayLabel] \
                             l2 [list delete displayLabel]]
    set selectCmdList [list c1 [list editComponentModule $pirNodeIndex] \
                           c2 [list deleteNode $nodeClassType $pirNodeIndex]]
    if {[string match $g_NM_schematicMode "operational"]} {
      lappend selectLabelList l3 [list show displayLabel propositions]
      lappend selectCmdList c3 [list nodeShowModeAndProps $windo.lab.label \
                                          $pirNodeIndex $nodeClassType]              
    }
    bind $windo.lab.label <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"
    bind $windo.lab.icon <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"

  } elseif {[string match $nodeClassType "terminal"]} {
    set selectLabelList [list l1 [list editOrView displayLabel] \
                             l2 [list delete displayLabel]]
    set selectCmdList [list c1 [list askTerminalInstance $nodeClassType \
                                    $nodeClassName $pirNodeIndex $caller] \
                           c2 [list deleteNode $nodeClassType $pirNodeIndex]]
    bind $windo.lab.icon <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"

  } elseif {[string match $nodeClassType "attribute"]} {
    set selectLabelList [list l1 [list editOrView displayLabel] \
                             l2 [list delete displayLabel]]
    set selectCmdList [list c1 [list askTerminalInstance $nodeClassType \
                                    $nodeClassName $pirNodeIndex $caller] \
                           c2 [list deleteNode $nodeClassType $pirNodeIndex]]  
    bind $windo.lab.icon <Button-3> \
        "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"

  } elseif {[string match $nodeClassType "mode"]} {
    # this is the attribute name of the mode attr-val
    set groupNodeClassName [assoc nodeClassName pirNode($groupPirNodeIndex)] 
    set modeAttribute "[assoc nodeInstanceName pirNode($groupPirNodeIndex)]"
    append modeAttribute ".$groupNodeClassName"
    # pass modeAttribute in terminalForm syntax
    set terminalForm [list terminal_name $modeAttribute type [list out mode]]
    set modeDisplayLabel [getExternalNodeName $nodeInstanceName]
    if {[string match $g_NM_schematicMode "layout"] && $topLevelNodeP} {
      bind $windo.lab.icon <B2-Motion> "modeB2Motion $canvas $windo %x %y"
      bind $windo.lab.icon <Button-2> \
          "modeB2StartMotion $canvas $windo %x %y $pirNodeIndex"
      bind $windo.lab.icon <ButtonRelease-2> \
          "modeB2Release $canvas $windo %x %y"
    }
    modeMouseRightOpsMenu $terminalForm $nodeClassName $pirNodeIndex $caller \
        $modeDisplayLabel 
  }

  set enableMouseClicksP 1; set widgetsExistP 1 
  bind $windo.lab.label <Enter> \
      "selectNode $pirNodeIndex $windo $widgetsExistP $enableMouseClicksP"
  bind $windo.lab.label <Leave> "deselectNode $pirNodeIndex $windo $enableMouseClicksP"
  bind $windo.lab.icon <Enter> \
      "selectNode $pirNodeIndex $windo $widgetsExistP $enableMouseClicksP"
  bind $windo.lab.icon <Leave> "deselectNode $pirNodeIndex $windo $enableMouseClicksP"
  if {($iconLabel != "") && \
          [string match $g_NM_schematicMode "layout"] && $topLevelNodeP} {
    bind $labelWindow.label <Enter> "selectLabel $pirNodeIndex $labelWindow"
    bind $labelWindow.label <Leave> "deselectLabel $pirNodeIndex $labelWindow"
  }

  set lengthParentNodeGroupList [llength [assoc parentNodeGroupList \
                                              pirNode($pirNodeIndex)]]
  set recursionLevel [expr {$lengthParentNodeGroupList - 2}]
  set editInputsOutputsP \
      [expr {(([string match $g_NM_schematicMode "layout"] && \
                   (! $g_NM_vmplTestModeP) && $topLevelNodeP) || \
                  ([string match $g_NM_schematicMode "operational"] && \
                       $g_NM_vmplTestModeP && ($recursionLevel < 2) && \
                       ($recursionLevel >= 0))) && \
                 ([string match $groupDefType component] || \
                      [string match $groupDefType module]) && \
                 (! $g_NM_vmplTestModeP)}]

  set inTypeLists [assoc inputs pirNode($pirNodeIndex)]
  for {set i 1} {$i <= $numInputs} {incr i} {
    set terminalForm [assoc in$i inTypeLists]
    set terminalName [assoc terminal_name terminalForm]
    set type [getTerminalType $terminalForm]
    set labelName [assoc terminal_label terminalForm $reportNotFoundP]
    set valuesList [terminalBalloonHelp terminalForm $terminalName \
                        $labelName $type $nodeClassType $nodeClassName \
                        $windo in $i]

    set msg ""; set msg2 ""
    if {(! $g_NM_vmplTestModeP) || ($g_NM_vmplTestModeP && \
                                        [commandMonitorTerminalInheritedP \
                                             $terminalName valuesList \
                                             $nodeClassType])} {
      buttonMouseRightOpsMenu $terminalForm $editInputsOutputsP \
          $windo in $i $displayLabel $valuesList $pirNodeIndex \
          $nodeClassType msg2 
    }
    if {$editInputsOutputsP} {
      if {! [string match $nodeClassType "terminal"]} {
        ## wysiwyg terminal reordering 
        set b1Start "terminalStartMotion $canvas $windo $windo.in.b$i %x %y"
        set b1Motion "terminalMotion $canvas %x %y"
        # break is to discard default button class binding: lib/button.tcl
        # bind Button <ButtonRelease-1> "tkButtonUp %W", which
        # generates an error
        set b1Release "terminalMotionRelease $canvas $windo"
        append b1Release " $terminalName $pirNodeIndex %x %y; break"
        bind $windo.in.b$i <Button-1> $b1Start 
        bind $windo.in.b$i <B1-Motion> $b1Motion
        bind $windo.in.b$i <ButtonRelease-1> $b1Release
        append msg "<Mouse-L drag>: move terminal"
      }
      if {[string match $groupDefType module]} {
        bind $windo.in.b$i <Button-2> \
            "buttonConnectStartMotion $canvas %W %X %Y"
        bind $windo.in.b$i <ButtonRelease-2> \
            "buttonConnectB1Release $canvas %W %X %Y"
        bind $windo.in.b$i <B2-Motion> \
            "buttonConnectMotion $canvas %W %X %Y"
        # selection color is done by button's activebackground color
        if {! [string match $msg ""]} {
          append msg ";  "
        }
        append msg "<Mouse-M drag>: create connection"
      }
    }
    bind $windo.in.b$i <Enter> "pirWarning \"$msg\" \"$msg2\""
    # reset Attention (canvasEnter)
    bind $windo.in.b$i <Leave> "canvasEnter;standardMouseClickMsg"
  }

  set outTypeLists [assoc outputs pirNode($pirNodeIndex)]
  # puts stderr "mkNode: nodeInstanceName $nodeInstanceName pirNodeIndex $pirNodeIndex"
  # puts "mkNode out numOutputs $numOutputs outTypeLists $outTypeLists"
  for {set i 1} {$i <= $numOutputs} {incr i} {
    set terminalForm [assoc out$i outTypeLists]
    set terminalName [assoc terminal_name terminalForm]
    set type [getTerminalType $terminalForm]
    set labelName [assoc terminal_label terminalForm $reportNotFoundP]
    set valuesList [terminalBalloonHelp terminalForm $terminalName \
                        $labelName $type $nodeClassType $nodeClassName \
                        $windo out $i]

    set msg ""; set msg2 ""
    if {(! $g_NM_vmplTestModeP) || ($g_NM_vmplTestModeP && \
                                        [commandMonitorTerminalInheritedP \
                                             $terminalName valuesList \
                                             $nodeClassType])} {
      buttonMouseRightOpsMenu $terminalForm $editInputsOutputsP \
          $windo out $i $displayLabel $valuesList $pirNodeIndex \
          $nodeClassType msg2 
    }
    if {$editInputsOutputsP} {
      if {(! [string match $nodeClassType "terminal"]) && \
              (! [string match $nodeClassType "attribute"])} {
        ## wysiwyg terminal reordering 
        set b1Start "terminalStartMotion $canvas $windo $windo.out.b$i %x %y"
        set b1Motion "terminalMotion $canvas %x %y"
        # break is to discard default button class binding: lib/button.tcl
        # bind Button <ButtonRelease-1> "tkButtonUp %W", which
        # generates an error
        set b1Release "terminalMotionRelease $canvas $windo"
        append b1Release " $terminalName $pirNodeIndex %x %y; break"
        bind $windo.out.b$i <Button-1> $b1Start 
        bind $windo.out.b$i <B1-Motion> $b1Motion
        bind $windo.out.b$i <ButtonRelease-1> $b1Release
        append msg "<Mouse-L drag>: move terminal"
      }
      if {[string match $groupDefType module] && \
              (! [string match $nodeClassType "attribute"])} {
        bind $windo.out.b$i <Button-2> \
            "buttonConnectStartMotion $canvas %W %X %Y"
        bind $windo.out.b$i <ButtonRelease-2> \
            "buttonConnectB1Release $canvas %W %X %Y"
        bind $windo.out.b$i <B2-Motion> \
            "buttonConnectMotion $canvas %W %X %Y"
        # selection color is done by button's activebackground color
        if {! [string match $msg ""]} {
          append msg ";  "
        }
        append msg "<Mouse-M drag>: create connection"
      } 
    }
    bind $windo.out.b$i <Enter> "pirWarning \"$msg\" \"$msg2\""
    # reset Attention (canvasEnter)
    bind $windo.out.b$i <Leave> "canvasEnter;standardMouseClickMsg"
  }

  if {[string match $g_NM_schematicMode "layout"] && $childAttributesP} {
    bind $windo.out.right <Button-3> \
        "selectAttributeProposition $pirNodeIndex %W"
    bind $windo.out.right <Enter> \
        "pirWarning \"<Mouse-R menu>: copy $displayLabel proposition\""
    bind $windo.out.right <Leave> "standardMouseClickMsg"
    balloonhelp $windo.out.right -side right -font [preferred StanleyTerminalTypeFont] \
        -delay 100 "attributes"
  }
  if {([string match $nodeClassType attribute] && \
          [string match $nodeClassName "displayState"]) || \
          [string match [assoc nodeState pirNode($pirNodeIndex)] \
               "parent-link"] || \
          [string match [assoc nodeGroupName pirNode($pirNodeIndex)] \
               root]} {
    # do not show display state attributes to the user
    #  move it off canvas
    $canvas move $canvasId $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight
    if {($iconLabel != "") && $g_NM_showIconLabelBalloonsP} {
      # move display state label
      $canvas move $labelCanvasId $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight
    }
  }
  if {! $g_NM_processingNodeGroupP} {
    mark_scm_modified
  }
  return $pirNodeIndex
}


## mouse right operation menu binding for component/module/terminal/
## attribute buttons
## 15nov99 wmt: extracted from mkNode
proc buttonMouseRightOpsMenu { terminalForm editInputsOutputsP window \
                                   direction buttonNum displayLabel \
                                   valuesList pirNodeIndex nodeClassType \
                                   msg2Ref } {
  upvar $msg2Ref msg2
  global g_NM_vmplTestModeP 

  if {$editInputsOutputsP && (! [string match $nodeClassType "attribute"])} {
    set msg2 "<Mouse-R menu>: toggle public/private"
    set selectLabelList [list l1 [list toggle public/private]]
    set selectCmdList [list c1 [list toggleButtonInterfaceType \
                                    $window.$direction.b$buttonNum]]
  }
  if {[string match $msg2 ""]} {
    set msg2 "<Mouse-R menu>: "
    set labelKey l1; set cmdKey c1
  } else {
    append msg2 ";  "
    set labelKey l2; set cmdKey c2
  }
  if {$g_NM_vmplTestModeP} {
    set selectVerb "select"
    set selectObj "value(s)"
  } else {
    set selectVerb "copy"
    set selectObj "proposition"
  }
  append msg2 "$selectVerb $selectObj"
  lappend selectLabelList $labelKey [list $selectVerb displayLabel $selectObj]
  lappend selectCmdList $cmdKey [list selectTerminalPropMenu $terminalForm \
                                     $valuesList %W $pirNodeIndex]
  bind $window.$direction.b$buttonNum <Button-3> \
      "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"
}


## mouse right operation menu binding for modes
## 16dec99wmt: extracted from mkNode
proc modeMouseRightOpsMenu { terminalForm nodeClassName pirNodeIndex caller \
                                 modeDisplayLabel } {
  global pirNode g_NM_schematicMode 

  set selectLabelList [list l1 [list editOrView modeDisplayLabel] \
                           l2 [list delete modeDisplayLabel]]
  set selectCmdList [list c1 [list askModeInstance mode $nodeClassName \
                                  $pirNodeIndex $caller] \
                         c2 [list deleteNode mode $pirNodeIndex]]
  if {$g_NM_schematicMode == "layout"} {
    lappend selectLabelList l3 [list select modeDisplayLabel proposition]
    lappend selectCmdList c3 [list selectTerminalPropMenu $terminalForm \
                                  $modeDisplayLabel %W $pirNodeIndex]
  }
  bind [assoc window pirNode($pirNodeIndex)].lab.icon <Button-3> \
      "operationMenu %W $pirNodeIndex [list $selectLabelList] [list $selectCmdList]"
}


## input unselect
proc nodeInDeselect {} {
  global pirDisplay pirNodes pirEdges  pirNode pirEdge

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "nodeInDeselect: `$backtrace'"
  set reportNotFoundP 0; set returnOldvalP 1
  set oldIn [adel selectIn pirDisplay $reportNotFoundP $returnOldvalP]
  foreach win $oldIn {
    if {[winfo exists $win]} {
      $win config -state normal
      bind $win <Any-Leave> {};   #revert to default binding
    }
  }
  # menuMakeTerminalSet disabled in
  return $oldIn
}


## output unselect
proc nodeOutDeselect {} {
  global pirDisplay 

  set reportNotFoundP 0; set returnOldvalP 1
  set oldOut [adel selectOut pirDisplay $reportNotFoundP $returnOldvalP]
  foreach win $oldOut {
    if {[winfo exists $win]} {
      $win config -state normal
      bind $win <Any-Leave> {};   #revert to default binding
    }
  }
  # menuMakeTerminalSet disabled out
  return $oldOut
}


## port unselect
## 16may96 wmt: new -derived from nodeOutDeselect 
proc nodePortDeselect { {bothP 0} } {
  global pirDisplay

  set reportNotFoundP 0; set returnOldvalP 1
  set lastPortButton [adel selectPort2 pirDisplay $reportNotFoundP \
      $returnOldvalP]
  set discardPortButton [adel selectPort1 pirDisplay $reportNotFoundP \
      $returnOldvalP]
  # puts stderr "nodePortDeselect discardPortButton \"$discardPortButton\""
  foreach win $discardPortButton {
    # puts stderr "nodePortDeselect 1 win \"$win\""
    if {(! [string match $win ""]) && ([winfo exists $win])} {
      $win config -state normal
      bind $win <Any-Leave> {};   #revert to default binding
    }
  }
  if {$bothP} {
    foreach win $lastPortButton {
      # puts stderr "nodePortDeselect 2 win \"$win\""
      if {(! [string match $win ""]) && ([winfo exists $win])} {
        $win config -state normal
        bind $win <Any-Leave> {};   #revert to default binding
      }
    }
  } elseif {! [string match $lastPortButton ""]} {
    # puts stderr "nodePortDeselect: selectPort1 $lastPortButton"
    acons selectPort1 [list $lastPortButton] pirDisplay
  }
  return $lastPortButton
}


## mark this button as the selected in/output button in preparation for
## possible edge creation/deletion.
## 22feb96 wmt: allow multiple inputs; pop-up window with terminal type
## 03jul96 wmt: turn off active background color in operational mode
proc nodeInSelectNoshift { button { pirNodeIndex 0} { buttonNum 0 } \
    { terminal_name_list {} } { type_list {}} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge g_NM_schematicMode 

  # puts stderr "nodeInSelectNoshift: button $button"
  if {$buttonNum == 0} {
    set oldIn [nodeInDeselect]
    ## set bothP 1; nodePortDeselect $bothP
    ## allow multiple port outputs to different inputs
    ## nodePortDeselect
    # this causes twice selecting the same button (edge) to
    # remove SelectIn from pirDisplay 
#     if {$oldIn == "$button"} {
#       return }

    # do not show active background color 
    # if {[string match $g_NM_schematicMode "layout"]} {
    #   # keep the active background color on
    #   $button config -state active
    #   bind $button <Any-Leave> {break;};     # remove the default binding
    # }
    acons selectIn [list $button] pirDisplay
  } else {
    # showButtonType $button $pirNodeIndex $buttonNum $terminal_name_list \
    #     in $type_list
  }
}


## select an output button, simple (no shift key)
## 22feb96 wmt: pop-up window with terminal type
## 16may96 wmt: add nodePortDeselect
## 03jul96 wmt: turn off active background color in operational mode
proc nodeOutSelectNoshift { button { pirNodeIndex 0} { buttonNum 0 } \
    { terminal_name_list {} } { type_list {}} } {
  global pirDisplay g_NM_schematicMode
  global pirNode 

  # puts stderr "nodeOutSelectNoshift: button $button"
  # puts stderr "nodeOutSelectNoshift: terminal_name_list $terminal_name_list"
  # puts stderr "nodeOutSelectNoshift: type_list $type_list"
  if {$buttonNum == 0} {
    set portEdgeP 0
    # puts stderr "nodeOutSelectNoshift: DirectionType [getTerminalButtonDirectionType $button]"
    if {[string match [getTerminalButtonDirectionType $button] "PORT"]} {
      set portEdgeP 1
      set oldOut [nodePortDeselect];
      ## nodeInDeselect
      ## nodeOutDeselect 
    } else {
      set oldOut [nodeOutDeselect];
      ## set bothP 1; nodePortDeselect $bothP
      nodePortDeselect
    }
    # this causes twice selecting the same button (edge) to
    # remove SelectIn from pirDisplay 
#    if {$oldOut == "$button"} return; #just a simple unselect

    # do not show active background color 
    # if {[string match $g_NM_schematicMode "layout"]} {
    #   # keep the active background color on
    #   $button config -state active
    #   bind $button <Any-Leave> {break;}; # remove the default binding
    # }
    if {$portEdgeP} {
      # puts stderr "nodeOutSelectNoshift: selectPort2 $button"
      acons selectPort2 [list $button] pirDisplay
    } else {
      # puts stderr "nodeOutSelectNoshift: selectOut $button"
      acons selectOut [list $button] pirDisplay
    }
  } else {
    # showButtonType $button $pirNodeIndex $buttonNum $terminal_name_list \
    #     out $type_list
  }
}


## determine number of breaks in selected edge and call mkEdge
## selectEdge sets up node selections in pirDisplay
## 09dec97 wmt: new
## 21feb98 wmt: check if making connection is enabled
proc toggleConnectionBreaks  { pirEdgeIndex } {
  global pirEdge g_NM_rootInstanceName pirDisplay

  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [componentModuleDefReadOnlyP]} {
    return
  }
  set reportNotFoundP 0
  #puts stderr "toggleConnectionBreaks: pirEdgeIndex $pirEdgeIndex pirDisplay [set pirDisplay]"
  set interimXYList [assoc interimXYList pirEdge($pirEdgeIndex)]
  # puts stderr "toggleConnectionBreaks: interimXYList $interimXYList"
  set reportNotFoundP 0; set returnIndexP 1; set checkTypesP 0
  set documentation [assoc documentation pirEdge($pirEdgeIndex)]
  set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
  set inBut [assoc selectIn pirDisplay $reportNotFoundP]
  set outBut [assoc selectOut pirDisplay $reportNotFoundP]
  if {(! [string match $inBut ""]) && (! [string match $outBut ""])} {
    if {[assoc interimY1 interimXYList $reportNotFoundP $returnIndexP] \
            == -1} {
      # current edge is 2-Break Connection
      mkEdge $inBut $outBut 4 "" "" "" $checkTypesP $documentation \
          $abstractionType
    } else {
      # current edge is 4-Break Connection
      mkEdge $inBut $outBut 2 "" "" "" $checkTypesP $documentation \
          $abstractionType 
    }
  }
}

#   "port->To"                   "port->From"
#    --------                    ---------
#    |      |                    |       |
#    |      |                    |       |
#    ----O---                    ----O----
#
#    ----V---                    ---------
#    |      |                    |       |
#    |      |                    |       |
#    --------                    ----V----
## create an edge from the selected input to the selected output button
## 05jan96 wmt: check return value of pirGetSensor
## 01feb96 wmt: add mark_modified
## 05feb96 wmt: add check for g_NM_edgesOfRedrawNode
## 20feb96 wmt: allow multiple input edges
## 06mar96 wmt: replace interimY with interimXYList
## 16may96 wmt: handle port edges
## 14jun96 wmt: determine, by y location, which port button is To/From
## 29jun96 wmt: implement multiple canvases
## 30sep96 wmt: check for duplicate edges
## 04oct96 wmt: update terminal name & type for input/output/port-declarations
## 03jan97 wmt: add optional arg checkTypesP
## 07may97 wmt: remove canvas attribute from pirEdge
## 25jun97 wmt: add documentation arg
proc mkEdge { {inbut ""} {outbut ""} {numBreaks 0} {interimXYList {}} \
                  {portEdgeType ""} { canvas "" } { checkTypesP 1 } \
                  { documentation "" } { abstractionType "" } \
                  { edgeColor "" } } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_edgesOfRedrawNode g_NM_schematicMode
  global g_NM_processingNodeGroupP g_NM_currentNodeGroup
  global g_NM_currentCanvas g_NM_edgeConnectionInvalidList
  global g_NM_initializationCompleteP g_NM_processingFileOpenP
  global publicPrivateConvertP g_NM_rootInstanceName 

  set caller "mkEdge"
#   set backtrace ""; getBackTrace backtrace
#   puts stderr "mkEdge: `$backtrace'"
  if {[string match $canvas ""]} {
    # puts stderr "mkEdge: canvas $canvas"
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
    set canvas $currentCanvas.c
  }
  set canvasRootId [getCanvasRootId $canvas tmp]
  set reportNotFoundP 0
  if {[string match $edgeColor ""]} {
    set edgeColor [preferred StanleyNodeConnectionBgColor]
  }
  set newEdgeP 0
  if {([string match $inbut ""]) && ([string match $outbut ""])} {
    set newEdgeP 1
  }
  # puts stderr "mkEdge: entry inbut $inbut outbut $outbut portEdgeType $portEdgeType" 
  # set str "mkEdge: in [assoc selectIn pirDisplay] out [assoc selectOut pirDisplay]"
  # set str "$str port1 [assoc selectPort1 pirDisplay $reportNotFoundP]"
  # puts stderr "$str port2 [assoc selectPort2 pirDisplay $reportNotFoundP]"
  if {[string match $inbut ""]} {
    set inbut [assoc selectIn pirDisplay $reportNotFoundP]
  }
  if {[string match $outbut ""]} {
    set outbut [assoc selectOut pirDisplay $reportNotFoundP]
  }
  set yTo 0; set yFrom 0
  if {([string match $inbut ""]) && ([string match $outbut ""])} {
    ## port connected to a port
    set inbut [assoc selectPort1 pirDisplay $reportNotFoundP]
    set outbut [assoc selectPort2 pirDisplay $reportNotFoundP]
    set portEdgeType "portFromTo"
  }
  if {([string match $inbut ""]) || ([string match $outbut ""])} {
    ## input or output connected to a port
    set but [assoc selectPort2 pirDisplay $reportNotFoundP]
    if {[string match $but ""]} {
      set but [assoc selectPort1 pirDisplay $reportNotFoundP]
    }
    if {[string match $inbut ""]} {
      set inbut $but
      set portEdgeType "port->From"
    }
    if {[string match $outbut ""]} {
      set outbut $but
      set portEdgeType "port->To"
    }
  }
  # puts stderr "mkEdge: early exit inbut $inbut outbut $outbut portEdgeType $portEdgeType" 
  if {[string match $inbut ""] || [string match $outbut ""]} {
    bell; return
  }
  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    # make button with smallest y location the outnode
    set button1 [lindex $inbut 0]; set button2 [lindex $outbut 0]
    set yTo [winfo rooty $button1]; set yFrom [winfo rooty $button2]
    # puts stderr "mkEdge: port Edge yTo $yTo yFrom $yFrom"
    if {$yTo == $yFrom} {
      set dialogList [list tk_dialog .d "ERROR" \
                          "You cannot connect two port terminals with the same y location" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    # puts stderr "mkEdge: before inbut $inbut outbut $outbut"
    if {$yTo < $yFrom} {
      set temp $inbut; set inbut $outbut; set outbut $temp
      set temp $yTo; set yTo $yFrom; set yFrom $temp
    }
  }
  # puts stderr "mkEdge: after inbut $inbut outbut $outbut"
  set innode [getPirNodeIndexFromButtonPath $inbut]
  set outnode [getPirNodeIndexFromButtonPath $outbut]
  # puts stderr "mkEdge: innode $innode outnode $outnode"
  if {$innode == $outnode} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "You cannot connect a node to itself (flow graph must be acyclic)." \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[string match [assoc nodeClassType pirNode($innode)] "terminal"] && \
          [string match [assoc nodeClassType pirNode($outnode)] "terminal"]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "You cannot connect two terminal nodes." \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[string match [assoc nodeClassType pirNode($innode)] "attribute"] || \
          [string match [assoc nodeClassType pirNode($outnode)] "attribute"]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "You cannot connect an attribute node to any other node." \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  # check for duplicate edges
  if {[duplicateEdgeCheck $innode $outnode $inbut $outbut $numBreaks]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "This connection already exists\!" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }  
  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    getEdgeTypeAndIndexFromButtonPath $inbut inIndex inEdgesType
    getLocation&NumFromButton $inbut inLocation tmp
  } elseif {([string match $portEdgeType ""]) || \
      ([string match $portEdgeType "port->To"])} {
    getEdgeTypeAndIndexFromButtonPath $inbut inIndex inEdgesType 
    getLocation&NumFromButton $inbut inLocation tmp
  } else {
    puts stderr "mkEdge: portEdgeType $portEdgeType not handled\!"
  }

  getEdgeTypeAndIndexFromButtonPath $outbut outIndex outEdgesType
  getLocation&NumFromButton $outbut outLocation tmp

#   puts stderr "mkEdge: innode $innode inbut $inbut inIndex $inIndex inEdgesType $inEdgesType"
#   puts stderr "mkEdge: outnode $outnode outbut $outbut outIndex $outIndex outEdgesType $outEdgesType"
#   puts stderr "mkEdge: inbutLoc $inLocation inIndex $inIndex innode $innode inEdgesType $inEdgesType"
#   puts stderr "mkEdge: outbutLoc $outLocation outIndex $outIndex outnode $outnode outEdgesType $outEdgesType"
  # do not allow multiple input terminals -- check that the in-terminal is free
  set edgeList [lindex [assoc $inEdgesType pirNode($innode)] $inIndex]
  # puts stderr "mkEdge: edgeList $edgeList"
  if {$edgeList != ""} {
    # puts "mkEdge Input Edge already exists g_NM_edgesOfRedrawNode $g_NM_edgesOfRedrawNode"
    if {[llength $g_NM_edgesOfRedrawNode] == 0} {
      # not sure what the above check is for
      if {$g_NM_initializationCompleteP && (! $g_NM_processingFileOpenP)} {
        # fileOpen is called from generateIscmOrMplFiles during initialization
        # and we do not want the dialog coming up
        set dialogList [list tk_dialog .d "ERROR" \
                            "A connection already exists: you must first delete it." \
                            error 0 {DISMISS}]
        eval $dialogList
      }
      # 24sep99: the following is only need to catch previously built schematics
      #          this problem will not occur on newly built schematics
      if {$g_NM_processingFileOpenP} {
        puts stderr "\nmkEdge: CONNECTION NO LONGER VALID"
        puts stderr "        one connection restriction on input terminal"
        set outputs [assoc outputs pirNode($outnode)]
        set terminalFrom [assoc out[expr {$outIndex + 1}] outputs]
        set fromTerminalName [assoc terminal_name terminalFrom] 
        set fromType [getTerminalType $terminalFrom]
        set fromDirection [getTerminalDirection $terminalFrom]
        set fromText "from"
        if {[string match $fromDirection "in"]} { set fromText "to  " }
        set inputs [assoc inputs pirNode($innode)]
        set terminalTo [assoc in[expr {$inIndex + 1}] inputs]
        set toTerminalName [assoc terminal_name terminalTo] 
        set toType [getTerminalType $terminalTo]
        set toDirection [getTerminalDirection $terminalTo]
        set toText "to  "
        if {[string match $toDirection "out"]} { set toText "from" }
        puts stderr "    $fromText: [getExternalNodeName $fromTerminalName]"
        puts stderr "          direction & type: $fromDirection $fromType"
        puts stderr "    $toText: [getExternalNodeName $toTerminalName]"
        puts stderr "          direction & type: $toDirection $toType"
        puts stderr "    abstractionType: $abstractionType"
        lappend g_NM_edgeConnectionInvalidList [list $fromText $fromTerminalName \
                                                    $toText $toTerminalName]
      }
      return
    }
  }

  # check and revise the levels of the two nodes
  ## not used
  ## adjustLevel $innode $outnode

  # check the type compatibility of the two sensors, and
  # look up information about them in the .cfg files
  set edgeInfo {}; set declNodeEdgeP 0
  set outNodeClassName [assoc nodeClassName pirNode($outnode)]
  set inNodeClassName [assoc nodeClassName pirNode($innode)]
  if {[regexp "DECLARATION" $outNodeClassName] || \
      [regexp "DECLARATION" $inNodeClassName]} {
    set declNodeEdgeP 1
  }
  if {! [pirGetSensor $outnode $outIndex $outLocation $innode $inIndex \
             $inLocation edgeInfo $declNodeEdgeP $portEdgeType $checkTypesP \
             $documentation $abstractionType]} {
    return -1
  }
  # puts stderr "\nmkEdge outIndex $outIndex outnode $outnode inIndex $inIndex innode $innode "
  # draw and record the edge
  set canvasId [drawEdge $canvas $inbut $innode $inIndex \
      $outbut $outnode $outIndex interimXYList $numBreaks $edgeColor]
  ## multiple canvases each are numbered unrelated to the others, so we must
  ## ensure a unique number for pirEdge & pirEdges
  set pirEdgeIndex [uniquePirEdgeIndex $canvasId]
  # puts stderr "mkEdge: canvas $canvas canvasId $canvasId pirEdgeIndex $pirEdgeIndex"

  lappend pirEdges $pirEdgeIndex
  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    set edgeset [lindex [assoc edgesFrom pirNode($innode)] $inIndex]
    set edgeset [linsert $edgeset 0 $pirEdgeIndex]
    set oldEdgesTo [assoc edgesFrom pirNode($innode)]
    set newEdgesTo [lreplace $oldEdgesTo $inIndex $inIndex $edgeset]
    adel edgesFrom pirNode($innode)
    acons edgesFrom $newEdgesTo pirNode($innode)
  } elseif {([string match $portEdgeType ""]) || \
      ([string match $portEdgeType "port->To"])} {
    set edgeset [lindex [assoc $inEdgesType pirNode($innode)] $inIndex]
    set edgeset [linsert $edgeset 0 $pirEdgeIndex]
    set oldEdgesTo [assoc $inEdgesType pirNode($innode)]
    set newEdgesTo [lreplace $oldEdgesTo $inIndex $inIndex $edgeset]
    adel $inEdgesType pirNode($innode)
    acons $inEdgesType $newEdgesTo pirNode($innode)
  } else {
    puts stderr "mkEdge(2): portEdgeType $portEdgeType not handled\!"
  }
  # puts stderr "mkEdge: newEdgesTo $newEdgesTo"

  # puts stderr "mkEdge: edgesFrom [assoc edgesFrom pirNode($outnode)]"
  set edgeset [lindex [assoc $outEdgesType pirNode($outnode)] $outIndex]
  set edgeset [linsert $edgeset 0 $pirEdgeIndex]
  set oldEdgesfrom [assoc $outEdgesType pirNode($outnode)]
  set newEdgesFrom [lreplace $oldEdgesfrom $outIndex $outIndex $edgeset]
  adel $outEdgesType pirNode($outnode)
  acons $outEdgesType $newEdgesFrom pirNode($outnode)
  # puts stderr "mkEdge: newEdgesFrom $newEdgesFrom"

  # puts stderr "mkEdge edgeInfo $edgeInfo"
  #  abstractionType & documentation are in edgeInfo 
  set pirEdge($pirEdgeIndex) \
   [concat \
     [list nodeFrom $outnode nodeTo $innode interimXYList $interimXYList \
          buttonFrom $outbut buttonTo $inbut fillColor $edgeColor  \
          yFrom $yFrom yTo $yTo canvasId $canvasId] \
     $edgeInfo]

  if {$newEdgeP && (! $g_NM_processingNodeGroupP) && (! $publicPrivateConvertP)} {
    # do not do this during fileOpen or openNodeGroup processing
    # if component/module terminal buttons are public, make them private
    setTerminalButtonInterfaceType $inbut private 
    setTerminalButtonInterfaceType $outbut private 
  }
  set widgetsExistP 1
  $canvas bind $canvasId <Enter> \
      "selectEdge $pirEdgeIndex $canvasRootId $canvasId $widgetsExistP"
  $canvas bind $canvasId <Leave> \
      "deselectEdge $pirEdgeIndex $canvasRootId $canvasId "

  set selectLabelList [list l1 [list editOrView connection] \
                           l2 [list delete connection]]
  set selectCmdList [list c1 [list askEdgeTypeAndDoc $pirEdgeIndex] \
                         c2 [list unmkEdge $pirEdgeIndex $caller]]
  if {[string match $g_NM_schematicMode "layout"] && \
          [string match $g_NM_rootInstanceName \
               [getCanvasRootInfo g_NM_currentNodeGroup]] && \
          (! [componentModuleDefReadOnlyP])} {
    # toggle num breaks 2->4, 4->2
    lappend selectLabelList l3 [list toggle num breaks]
    lappend selectCmdList c3 [list toggleConnectionBreaks $pirEdgeIndex]
    # move edge
    $canvas bind $canvasId <Button-1> \
        "edgeB1StartMotion $canvas %x %y $canvasId $pirEdgeIndex; break"
    $canvas bind $canvasId <B1-Motion> "edgeB1Motion $canvas %x %y; break"
    $canvas bind $canvasId <ButtonRelease-1> "edgeB1MotionRelease $canvas %x %y; break"
  }
  $canvas bind $canvasId <Button-3> \
      "operationMenu %W edge [list $selectLabelList] [list $selectCmdList]"

  addEdgeInstance $canvasId $pirEdgeIndex $canvas

  # clear all button selections
  set bothP 1; nodePortDeselect $bothP; nodeInDeselect; nodeOutDeselect

  # puts stderr "mkEdge: g_NM_processingNodeGroupP $g_NM_processingNodeGroupP"
  if {! $g_NM_processingNodeGroupP} {
    mark_scm_modified
  }
  return $pirEdgeIndex
}


## draw transition line and arrow
## redrawP = 1 when drawing is the result of a mode being moved by user
## 17jul97 wmt: new
proc drawModeTransition { canvas startNodeWidget stopNodeWidget lineIdRef \
                              arrowIdRef startPirNodeIndex stopPirNodeIndex } {
  upvar $lineIdRef lineId
  upvar $arrowIdRef arrowId
  global g_NM_schematicMode g_NM_currentNodeGroup g_NM_rootInstanceName

  set caller "drawModeTransition"
  # draw arrow point at 75% of line length
  set arrowLength 25; set arrowWidthHalf 10; set arrowPercent 0.75
  # connect to centers of widgets
  set xStartCenter 0; set yStartCenter 0; set xStopCenter 0; set yStopCenter 0
  set deltaX 0; set deltaY 0
  getWidgetCenter $startNodeWidget xStartCenter yStartCenter deltaX deltaY 
  # puts stderr "xStartCenter $xStartCenter yStartCenter $yStartCenter"
  getWidgetCenter $stopNodeWidget xStopCenter yStopCenter deltaX deltaY 
  # puts stderr "xStopCenter $xStopCenter yStopCenter $yStopCenter"

  set xArrowPt 0; set yArrowPt 0; set xArrowBt 0; set yArrowBt 0
  getArrowLocation $xStartCenter $yStartCenter $xStopCenter $yStopCenter \
      $arrowPercent $arrowLength xArrowPt yArrowPt xArrowBt yArrowBt 
  # puts stderr "xArrowPt $xArrowPt yArrowPt $yArrowPt xArrowBt $xArrowBt yArrowBt $yArrowBt"

  # if this transition makes a double transition, do not draw the line
  if {[transitionLineExists $stopPirNodeIndex $stopPirNodeIndex \
           $startPirNodeIndex]} {
    set lineId -1
  } else {
    set lineId [$canvas create line $xStartCenter $yStartCenter  \
                    $xStopCenter $yStopCenter \
                    -fill [preferred StanleyModeTransitionBgColor] \
                    -width 2 -tags transitionLine]
  }
  set arrowId [$canvas create line $xArrowBt $yArrowBt $xArrowPt $yArrowPt \
                   -fill [preferred StanleyModeTransitionBgColor] \
                   -width 2 -tags transitionArrow -arrow last \
                   -arrowshape [list $arrowLength $arrowLength $arrowWidthHalf]]

  set nodeClassType transition; set nodeClassName transition 

  $canvas bind $arrowId <Enter> \
      "highlightModeTransition $canvas $arrowId $startPirNodeIndex $stopPirNodeIndex"
  $canvas bind $arrowId <Leave> \
      "dehighlightModeTransition $canvas $arrowId $startPirNodeIndex $stopPirNodeIndex"
  # enableMouseSelection prevents adjacent modes from being "selected"
  # by canvasB1Release
  set selectLabelList [list l1 [list editOrView transitions]]
  # multiple commands have a standalone \; separating them
#   set selectCmdList [list c1 [list enableMouseSelection $canvas \; editModeTransition \
#                                   $nodeClassType $nodeClassName $startPirNodeIndex \
#                                   $stopPirNodeIndex $caller]]
  # enableMouseSelection causes skeleton rectangle on canvas (adjacent modes
  # does not seem to be a problem)
  set selectCmdList [list c1 [list editModeTransition \
                                  $nodeClassType $nodeClassName $startPirNodeIndex \
                                  $stopPirNodeIndex $caller]]
  $canvas bind $arrowId <Button-3> \
        "operationMenu %W transition [list $selectLabelList] [list $selectCmdList]"
}















