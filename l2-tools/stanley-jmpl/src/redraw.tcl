# $Id: redraw.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## redraw.tcl

## redraw the display from the information stored in global (pir...) 
## variables
## 05jan95 wmt: do not add fixed, required, or optional fields to edge object
## 06mar96 wmt: call getNodeStateBgColor in case active/inactive colors have 
##              been redefined; call mkEdge with interimXYList
## 22mar96 wmt: CVS version 2-1 change: add processAllComponentInstances 
## 26apr96 wmt: preserve pirClass around initialize_graph
## 21may96 wmt: handle port edges
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 31may96 wmt: correct bug in using checkFileModificationDates
## 04jun96 wmt: add g_NM_nodeGroupToInstances processing
## 29jun96 wmt: implement multiple canvases
## 24jul96 wmt: add call to checkPendingModelUpdates
## 26aug96 wmt: in install mode, save schematic extension of .scm, not .scm-template
## 22oct96 wmt: add optional arg checkConsistencyP
## 27oct96 wmt: only apply checkPendingModelUpdates to new classes, 
##              rather than new and old -- introduce pirClasses
## 16apr97 wmt: null g_NM_livingstoneDefmoduleName here, rather than
##              in initialize_graph - for second call to initialize_graph 
## 02jul97 wmt: add recursiveFileOpenP arg
proc pirRedraw { errorDialogP } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global STANLEY_ROOT pirFileInfo g_NM_schematicMode
  global g_NM_instanceToNode
  global g_NM_inhibitEdgeTypeMismatchP g_NM_defmoduleFilePath
  global g_NM_currentCanvas g_NM_currentNodeGroup g_NM_canvasList 
  global g_NM_processingNodeGroupP g_NM_IPCp 
  global g_NM_includedModules g_NM_classDefType pirClass pirClasses
  global g_NM_pendingPirEdgesList g_NM_instantiatableSchematicExtension
  global g_NM_rootModuleCanvasXY g_NM_rootInstanceName
  global g_NM_livingstoneDefmoduleArgList g_NM_win32P
  global g_NM_livingstoneDefmoduleNameVar g_NM_livingstoneDefcomponentNameVar

  set reportNotFoundP 0; set oldvalMustExistP 0; set redrawFailedP 0
  set caller "pirRedraw"
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }
  set canvasRootId 0
  # global xxxNewNode xxxOldNode xxxEdge xxxNode xxxEdges xxxNodes
  # first copy what we had
  set xxxDisplay $pirDisplay
  set xxxNodes $pirNodes
  set xxxEdges $pirEdges
  set xxxClasses $pirClasses
  foreach node $pirNodes {
    set xxxNode($node) $pirNode($node)
  }
  foreach edge $pirEdges {
    set xxxEdge($edge) $pirEdge($edge);
  }
  foreach class $pirClasses {
    set xxxClass($class) $pirClass($class)
  }
  # puts stderr "pirRedraw: xxxClass -> [array names xxxClass]"
  set xxxcanvasList $g_NM_canvasList
  set xxxincludedModules $g_NM_includedModules

  set severity 1; set reinit 0; set makeNewDefmoduleNameP 0; set msg2 ""
  pirWarning [format {Please Wait: %s schematic being built --} \
      `[workname $pirFileInfo(filename)]'] \
      $msg2 $severity
  update
  # next, clean out and start over; do not reset g_NM_livingstoneDefmoduleName
  initialize_graph $reinit $makeNewDefmoduleNameP 

  # do not need version check
  # acons application [assoc application xxxDisplay] pirDisplay
  # pirUpVersion \
  #   [lindex [assoc version xxxDisplay] 2] \
  #  [pirSetVersion]

  # reconstruct multiple canvases
  set overlayP 0
  # puts stderr "pirRedraw: xxxcanvasList $xxxcanvasList"
  # g_NM_rootInstanceName needs to be set for createCanvas
  if {[string match $g_NM_classDefType module]} {
    set g_NM_rootInstanceName $g_NM_livingstoneDefmoduleNameVar
  } elseif {[string match $g_NM_classDefType component]} {
    set g_NM_rootInstanceName $g_NM_livingstoneDefcomponentNameVar
  } else {
    set g_NM_rootInstanceName ?name
  }
  # canvases are not created here anymore - canvases are created on demand
  # in mkNodeIcon
#   foreach canvas $xxxcanvasList {
#     set canvas [convertCanvasPath $canvas $canvasRootId]
#     # redrawFailedP = 2 occurs when a duplicate canvas is discovered
#     if {[createCanvas $canvas 0 0 $overlayP]} {
#       set redrawFailedP 2
#       return $redrawFailedP 
#     }
#   }
  setCanvasRootInfo g_NM_currentCanvas .master.canvas.root
  set g_NM_processingNodeGroupP 1

  # next line is done is fileOpen
  # puts -nonewline stderr "\npirRedraw=>"
  # reconstruct each node
  # a variation of this code is in instantiateDefmodule
  set outputMsgP 1; set callerRedrawP 0
  if {[string match $g_NM_schematicMode "operational"]} {
    set callerRedrawP 1
  }
  set xxxNewNodes {}; set newModes {}
  foreach node $xxxNodes {
    # puts stderr "pirRedraw: node $node $xxxNode($node)"
    set nodeX [assoc nodeX xxxNode($node)]
    set nodeY [assoc nodeY xxxNode($node)]
    set labelX [assoc labelX xxxNode($node) $reportNotFoundP]
    if {$labelX  == ""} { set labelX -1 }
    set labelY [assoc labelY xxxNode($node) $reportNotFoundP]
    if {$labelY == ""} { set labelY -1 }
    set canvas [getCanvasFromWindow [assoc window xxxNode($node)]]
    # backward compatibility for schematic files with .canvas.---, 
    # rather than .master.canvas.---
    set canvas [convertCanvasPath $canvas $canvasRootId]
    set tempNode $xxxNode($node)
    set nodeState [assoc nodeState xxxNode($node)]
    set nodeInstanceName [assoc nodeInstanceName xxxNode($node)]
    # puts stderr "\npirRedraw: nodeInstanceName $nodeInstanceName"
    set nodeClassName [assoc nodeClassName xxxNode($node)]
    if {[string match $nodeState "parent-link"]} {
      # openNodeGroup (below) creates the parent-link node
#       buildParentNode $nodeInstanceName $canvas $nodeClassName tempNode
#       # puts stderr "pirRedraw: p nodeInstanceName $nodeInstanceName"
#       puts -nonewline stderr "p"
    } else {
      foreach field [list nodeX nodeY labelX labelY canvasId edgesTo \
                         edgesFrom window ] {
        adel $field tempNode $reportNotFoundP
      }
      # puts stderr "pirRedraw: tempNode $tempNode"
      set nodeClassType [lindex [getNodeClassTypeAndName tempNode] 0]
      setCanvasRootInfo g_NM_currentNodeGroup \
          [assoc nodeGroupName xxxNode($node)] $canvasRootId
      # attribute, and terminal instances
      # component, and module instances are done in recursive instantiation
      set instanceLabel [assoc instanceLabel xxxNode($node) $reportNotFoundP]
      arepl instanceLabel $instanceLabel tempNode $reportNotFoundP $oldvalMustExistP
      if {([string match $nodeClassType component] || \
              [string match $nodeClassType module]) && \
              (! [string match $g_NM_rootInstanceName $nodeInstanceName])} {
        # check that args and argsValues are equal in length
        set classVars [assoc class_variables xxxClass($nodeClassName)]
        set args [getClassVarDefaultValue args classVars]
        set argTypes [getClassVarDefaultValue argTypes classVars]
        set argsValues [assoc argsValues xxxNode($node)]
        set mismatchP 0
        set mismatchStringArg ""; set mismatchStringType ""; set mismatchStringValue ""
        foreach arg $args argType $argTypes argValue $argsValues {
          set expndArgList {}; set expndArgTypeList {}; set expndValueList {}
          expandArgNamesTypesValues $arg $argType $argValue expndArgList \
                                     expndArgTypeList expndValueList
          if {[llength $expndArgList] != [llength $expndValueList]} {
            set mismatchP 1
            append mismatchStringArg " $expndArgList"
            append mismatchStringType " $expndArgTypeList"
            append mismatchStringValue " $expndValueList"
          }
        }
        if {$mismatchP} {
          set str "   MISMATCH args/values: className $nodeClassName\n"
          set mismatchString "   expndArgList:    $mismatchStringArg \n"
          append mismatchString "   expndArgTypeList:$mismatchStringType \n"
          append mismatchString "   expndValueList:  $mismatchStringValue" 
          append str $mismatchString  
          puts stderr "pirRedraw: $nodeInstanceName $str"
          if {$errorDialogP} {
            set dialogList [list tk_dialog .d "WARNING" $str warning 0 {DISMISS}]
            eval $dialogList
          }
        }
      }
      set newNum [mkNode $canvas $nodeX $nodeY $labelX $labelY tempNode \
                      $nodeClassType $outputMsgP $callerRedrawP]
      if {$newNum == -1} {
        error "pirRedraw: mkNode returned -1"
      }
      switch -exact $nodeClassType {
        terminal {puts -nonewline stderr "t"}
        attribute {puts -nonewline stderr "a"}
        module {puts -nonewline stderr "m"} 
        component {puts -nonewline stderr "c"} 
        mode {
          puts -nonewline stderr "o"
          lappend newModes $newNum
        } 
        default {puts -nonewline stderr "?"} 
      }
      set xxxNewNode($node) $newNum
      lappend xxxNewNodes $node
      # puts stderr "pirRedraw: nodeClassName $nodeClassName"
      ## next stmt must follow mkNode call, or it screws up pirNode entries
      if {[lsearch -exact [getClasses $nodeClassType] $nodeClassName] == -1} {
        set xxxClassDef $xxxClass($nodeClassName)
        setClass $nodeClassType $nodeClassName xxxClassDef 
        if {[string match $nodeClassType "component"]} {
          # create recovery_modes from fault_modes and mode_transitions
          createRecoveryModes $nodeClassName
        }
        lappendClasses $nodeClassType $nodeClassName
      }
      # set str "pirRedraw: nodeInstanceName $nodeInstanceName"
      # puts stderr "$str g_NM_rootInstanceName $g_NM_rootInstanceName"
      if {[string match $nodeInstanceName $g_NM_rootInstanceName]} {
        set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
        set window [getWindowPathFromPirNodeIndex $newNum $currentCanvas.c]
        openNodeGroup $nodeInstanceName $nodeClassType $window
        puts -nonewline stderr "p"
        update
      }
    }
  }
  update

  set numBreaks 0;      # use info in interimXYList 
  # reconstruct each edge
  # a variation of this code is in instantiateDefmodule
  set g_NM_inhibitEdgeTypeMismatchP 1; set pendingPirEdgesList {}
  foreach edge $xxxEdges {
    # ensure that multi-dimensional types have multi-dimensional default values
    set terminalForm [assoc terminalFrom xxxEdge($edge)] 
    checkTerminalFormCmdMonValues terminalForm 
    arepl terminalFrom $terminalForm  xxxEdge($edge)
    # puts stderr "pirRedraw: terminalFrom $terminalForm"
    set terminalForm [assoc terminalTo xxxEdge($edge)] 
    checkTerminalFormCmdMonValues terminalForm 
    arepl terminalTo $terminalForm  xxxEdge($edge)
    # puts stderr "pirRedraw: terminalTo $terminalForm"

    set fromEdgeAttrList [assoc terminalFrom xxxEdge($edge)]
    set toEdgeAttrList [assoc terminalTo xxxEdge($edge)]
    set portEdgeType [isThisAPortEdge $edge $fromEdgeAttrList $toEdgeAttrList]
    if {([string match $portEdgeType "portFromTo"]) || \
            ([string match $portEdgeType "port->From"])} {
      set whichEdges edgesFrom
      set direction out
    } elseif {([string match $portEdgeType ""]) || \
                  ([string match $portEdgeType "port->To"])} {
      set whichEdges edgesTo
      set direction in
    } else {
      puts stderr "pirRedraw: portEdgeType $portEdgeType not handled\!"
    }
    set checkTypesP 0
    set canvas [getCanvasFromButton [assoc buttonTo xxxEdge($edge)]]
    set canvas [convertCanvasPath $canvas $canvasRootId]  
    set interimXYList [assoc interimXYList xxxEdge($edge)]
    set oldNodeFrom [assoc nodeFrom xxxEdge($edge)]
    set oldNodeTo [assoc nodeTo xxxEdge($edge)]
    set documentation [assoc documentation xxxEdge($edge) $reportNotFoundP]
    set abstractionType [assoc abstractionType xxxEdge($edge) $reportNotFoundP]
    # are these nodes in this current module; if not replace node nums
    # with node instance names, and create after all nodes are created
    set includedFromP 1; set includedToP 1
    if {[lsearch -exact $xxxNodes $oldNodeFrom] == -1} { 
      set includedFromP 0
      set oldNodeFromName [getNodeInstanceNameFromIncludedModules $oldNodeFrom \
                               xxxincludedModules]
    } else {
      set oldNodeFromName [assoc nodeInstanceName xxxNode($oldNodeFrom)]
    }
    if {[lsearch -exact $xxxNodes $oldNodeTo] == -1} {
      set includedToP 0
      set oldNodeToName [getNodeInstanceNameFromIncludedModules $oldNodeTo \
                             xxxincludedModules]
    } else {
      set oldNodeToName [assoc nodeInstanceName xxxNode($oldNodeTo)]
    }
    set oldNodeFromNum [assoc nodeFrom xxxEdge($edge)]
    set oldNodeToNum [assoc nodeTo xxxEdge($edge)]
    if {(! $includedFromP) || (! $includedToP)} {
      arepl nodeFrom $oldNodeFromName xxxEdge($edge)
      arepl nodeTo $oldNodeToName xxxEdge($edge)
      lappend pendingPirEdgesList $xxxEdge($edge)
      continue
    }
    set fromButtonNum [pirEdgeIndex $edge [assoc edgesFrom xxxNode($oldNodeFrom)]]
    set toButtonNum [pirEdgeIndex $edge [assoc $whichEdges xxxNode($oldNodeTo)]]
    set nodeFrom $xxxNewNode($oldNodeFromNum)
    set nodeTo $xxxNewNode($olodNodeToNum)
    set inbut [assoc window pirNode($nodeTo)].$direction.b$toButtonNum
    set outbut [assoc window pirNode($nodeFrom)].out.b$fromButtonNum
    set edge1 [mkEdge $inbut $outbut $numBreaks $interimXYList $portEdgeType \
                   $canvas $checkTypesP $documentation $abstractionType]
    global pirEdge($edge1)
    ## puts "pirRedraw edge $edge edge1 $edge1"
    # if [required_completed_p edge $edge1] {
    #   display_item_completed $canvas edge $edge1;
    # }
    puts -nonewline stderr "e"
  }
  if {[llength $pendingPirEdgesList] > 0} {
    # puts stderr "pirRedraw: canvas $canvas"
    # puts stderr "     g_NM_pendingPirEdgesList [llength $pendingPirEdgesList]"
    arepl-array $canvas $pendingPirEdgesList g_NM_pendingPirEdgesList \
        $reportNotFoundP $oldvalMustExistP
  }
  
  # for nodeType = mode, replace pirNode indices with new values in transitions
  # attribute
  foreach modeIndex $newModes {
    set transitionList [assoc transitions pirNode($modeIndex) $reportNotFoundP]
    if {[llength $transitionList] > 0} {
      set newTransitionList {}
      foreach transition $transitionList {
        set startNodeInstanceName [assoc nodeInstanceName \
                                       xxxNode([assoc startNode transition])]
        set startPirNodeIndex [assoc-array $startNodeInstanceName g_NM_instanceToNode]
        arepl startNode $startPirNodeIndex transition 
        set stopNodeInstanceName [assoc nodeInstanceName \
                                      xxxNode([assoc stopNode transition])]
        set stopPirNodeIndex [assoc-array $stopNodeInstanceName g_NM_instanceToNode]
        arepl stopNode $stopPirNodeIndex transition
        lappend newTransitionList $transition
      }
      arepl transitions $newTransitionList pirNode($modeIndex)
    }
  }
 
  # redraw transitions
  # since this is top level component, its canvas is exposed and thus its
  # mode windows are expanded and have valid winfo geometries.
  # therefore transitionModesToDraw is not set
  set arrowIdList {}
  foreach modeIndex $newModes {
    set canvas [getCanvasFromWindow [assoc window pirNode($modeIndex)]]
    set transitionList [assoc transitions pirNode($modeIndex) $reportNotFoundP]
    foreach transition $transitionList {
      if {[llength $transition] > 4} {
        puts -nonewline stderr "x"
        set startPirNodeIndex [assoc startNode transition]
        set stopPirNodeIndex [assoc stopNode transition]
        # set widget [assoc window pirNode($startPirNodeIndex)]
        # puts stderr "reDraw: geometry widget $widget `[winfo geometry $widget]'"
        # set widget [assoc window pirNode($stopPirNodeIndex)]
        # puts stderr "reDraw: geometry widget $widget `[winfo geometry $widget]'"
        lappend arrowIdList \
            [redrawModeTransitions $canvas $startPirNodeIndex $stopPirNodeIndex]
      }
    }
  }
  # if arrow is overlapped by line , raise it to top
  foreach arrowId $arrowIdList {
    $canvas raise $arrowId
  }
  # puts stderr "pirRedraw: g_NM_pendingPirEdgesList $g_NM_pendingPirEdgesList"

  set g_NM_inhibitEdgeTypeMismatchP 0; set canvasRootId 0
  set defmoduleArgsVars {}; set recursionLevel 0
  set defmoduleArgsValues {}
  set nodeClassType [assoc nodeClassType \
                         pirNode([assoc-array $g_NM_rootInstanceName \
                                      g_NM_instanceToNode])]
  # puts stderr "pirRedraw: nodeClassType $nodeClassType"
  ## recursively create "branch" nodes and edges from g_NM_includedModules
  # redrawFailedP = 1 occurs when a dependent .i-scm file is not found
  set redrawFailedP [recursiveDefmoduleInstantiation $g_NM_rootInstanceName \
                         $xxxincludedModules $defmoduleArgsVars \
                         $defmoduleArgsValues $caller $recursionLevel \
                         $nodeClassType $canvasRootId $errorDialogP]
  # puts stderr "pirRedraw: redrawFailedP $redrawFailedP"
  # not needed since overlayCurrentCanvas does not go to lower canvases
  # during File Open
  # changeCanvasToWorkingLevel

  puts stderr " "
  standardMouseClickMsg
  set g_NM_processingNodeGroupP 0
  .master.canvas config -cursor top_left_arrow
  update
  return $redrawFailedP
}


# determines the index (1 relative) of the edge in the list
proc pirEdgeIndex {edge edgesList} {

  set n 1
  foreach edgeset $edgesList {
    if {[lsearch -exact $edgeset $edge] > -1} {
      return $n
    }
    incr n
  }
  error "Internal error: pirEdgeIndex edge `$edge' edgesList `$edgesList'"
}
  

## recursively construct multi-canvas schematic from multiple .i-scm and/or
## .cfg files (if no .i-scm file has been saved)
## 12may97 wmt: new
## 21jul97 wmt: updated to handle schematic, rather than .cfg, components, as well
proc recursiveDefmoduleInstantiation { localRootInstanceName includedModules \
                                           defmoduleArgsVars defmoduleArgsValues \
                                           caller recursionLevel nodeClassType \
                                           canvasRootId errorDialogP } {
  global g_NM_pendingPirEdgesList 
  global g_NM_instantiatableSchematicExtension g_NM_currentNodeGroup
  global g_NM_terminalInputs g_NM_terminalOutputs pirNode pirDisplay
  global g_NM_parentNodeGroupList g_NM_rootInstanceName g_NM_includedModules
  global g_NM_instanceToNode pirNode g_NM_recursiveInstantiationP
  global g_NM_processingNodeGroupP g_NM_recursiveTraceOutputP
  global g_NM_win32P

  set reportNotFoundP 0; set redrawFailedP 0
  set canvasRoot [getCanvasRoot $canvasRootId]
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }
  if {$g_NM_recursiveTraceOutputP} {
    set str "\nrecursiveDefmoduleInstantiation: recursionLevel $recursionLevel"
    set str "$str localRootInstanceName $localRootInstanceName"
    puts stderr "$str \n     includedModules [alist-keys includedModules]"
    puts stderr "$str \n     includedModules $includedModules"
  }
  if {[string match $caller "pirRedraw"] && \
          (! [string match $localRootInstanceName $g_NM_rootInstanceName])} {
    # open module/component to next lower level
    set pirNodeIndex [assoc-array $localRootInstanceName g_NM_instanceToNode]
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
    set window [getWindowPathFromPirNodeIndex $pirNodeIndex $currentCanvas.c]
    # set str "recursiveDefmoduleInstantiation: pirNodeIndex $pirNodeIndex"
    # set str "$str currentCanvas $currentCanvas window $window nodeClassType"
    # puts stderr "$str $nodeClassType"
    openNodeGroup $localRootInstanceName $nodeClassType $window
    update
  }
  # includedModules are included components & modules
  set invalidInstantiationP 0
  for {set i 0} {$i < [llength $includedModules]} {incr i 2} {
    set nodeInstanceName [lindex $includedModules $i]
    set defmoduleAttList [lindex $includedModules [expr {1 + $i}]]
    set nodeClassName [assoc nodeClassName defmoduleAttList]
    set nodeClassType [assoc nodeClassType defmoduleAttList $reportNotFoundP]
    # for backward compatibility
    if {[string match $nodeClassType ""]} {
      set nodeClassType module
    }
    set pirNodeIndex [assoc pirNodeIndex defmoduleAttList]
    set iScmDir "[getSchematicDirectory nodeType $nodeClassType]/"
    set iScmFile "$nodeClassName$g_NM_instantiatableSchematicExtension"
    set iScmPath ${iScmDir}${iScmFile}
    if {[file exists $iScmPath]} {

      set invalidInstantiationP \
          [instantiateDefmoduleFromIscm $nodeClassName \
               $nodeInstanceName $iScmFile $defmoduleArgsVars \
               $defmoduleArgsValues $defmoduleAttList \
               $caller $recursionLevel $canvasRootId $errorDialogP]
      # do not exit -- continue with recursion and let user work with result
      # if {$invalidInstantiationP} {
      #   break
      # }
    } else {
      ## if .i-scm file does not exist for module
      set str "\nrecursiveDefmoduleInstantiation: cannot include instance $nodeInstanceName;"
      append str " class definition $nodeClassName not found. \n    "
      puts stderr "$str \($iScmPath\)"
      if {$errorDialogP} {
        set dialogList [list tk_dialog .d "ERROR" $str \
                            error 0 {DISMISS}]
        eval $dialogList
      }
      set redrawFailedP 1
      $canvasRoot.canvas config -cursor top_left_arrow
      standardMouseClickMsg
      pirWarning ""
      update
      return $redrawFailedP

      #       enter -auto mode and create it
      #       puts stderr "$str creating it ..."
      #       set internalVars [assoc internal pirClass($nodeClassName)]
      #       set class_variables [assoc class_variables internalVars]
      #       set structureList [getClassVarDefaultValue structure class_variables]
      #       set connectionsList [getClassVarDefaultValue connections class_variables]
      #       if {[string match $caller "canvasB1Click"]} {
      #         set terminalInputs $g_NM_terminalInputs
      #         set terminalOutputs $g_NM_terminalOutputs
      #       } else {
      #         set terminalInputs [assoc inputs XpirNode($pirNodeIndex)]
      #         set terminalOutputs [assoc outputs XpirNode($pirNodeIndex)]
      #       }
      #       set str1 "\nrecursiveDefmoduleInstantiation: for defmodule $nodeClassName:\n"
      #       set str1 "$str1    INPUT_TERMINALS $terminalInputs\n"
      #       set str1 "$str1    OUTPUT/PORT_TERMINALS $terminalOutputs\n"
      #       set str1 "$str1    STRUCTURE: $structureList\n"
      #       # puts stderr "$str1    CONNECTIONS $connectionsList\n"

      #       instantiateDefmoduleFromCfg $pirNodeIndex $nodeClassName $defmoduleArgsVars \
          #           $defmoduleArgsValues $terminalInputs $terminalOutputs $structureList \
          #           $connectionsList 
    }
  }
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
  if {$invalidInstantiationP} {
    if {$invalidInstantiationP == 1} {
      # delete this instantiation, since one of its children already exists 
      puts stderr "\nrecursiveDefmoduleInstantiation: delete includedModule $nodeInstanceName"
      puts stderr "     since it contains an existing node"
      set selectedNodes [assoc-array $nodeInstanceName g_NM_instanceToNode]
      set reportNotFoundP 0; set oldvalMustExistP 0
      arepl selectedNodes $selectedNodes pirDisplay $reportNotFoundP $oldvalMustExistP

      editCut $currentCanvas.c

      set g_NM_processingNodeGroupP 0
      $canvasRoot.canvas config -cursor top_left_arrow
      standardMouseClickMsg
      update
    }
    # invalidInstantiationP == 2: included component/module already exists
    # nothing was instantiated - nothing to delete

    # do not exit -- continue with recursion and let user work with result
    # return 0
  }
  # puts stderr "recursiveDefmoduleInstantiation: len
  #               [llength [assoc-array $currentCanvas.c g_NM_pendingPirEdgesList
  #               $reportNotFoundP] ] 
  #               g_NM_recursiveInstantiationP $g_NM_recursiveInstantiationP 
  #               recursionLevel $recursionLevel"
  if {[llength [assoc-array $currentCanvas.c g_NM_pendingPirEdgesList \
                    $reportNotFoundP]] > 0} {
    if {! $g_NM_recursiveInstantiationP} {
      # layout mode

      createPendingEdges $canvasRootId 
    }
    if {$g_NM_recursiveInstantiationP && ($recursionLevel == 0)} {
      # operational mode top level connections are drawn here
      # operational mode lower level connections are drawn in openNodeGroup

      createPendingEdges $canvasRootId
    }
  }
  if {($g_NM_recursiveInstantiationP && ($recursionLevel == 0)) || \
          (! $g_NM_recursiveInstantiationP)} {
    # layout & operational modes
    set g_NM_processingNodeGroupP 0
    $canvasRoot.canvas config -cursor top_left_arrow
    standardMouseClickMsg
    update
  }

  # return to parent canvas, if not there already
  returnToRootCanvas $localRootInstanceName $canvasRootId 
  return 0
}


## return to parent canvas, if not there already
## 10feb99 wmt: extracted from recursiveDefmoduleInstantiation
proc returnToRootCanvas { instanceName canvasRootId } {
  global g_NM_rootInstanceName g_NM_recursiveInstantiationP
  global pirNode 
  
  if {(! [string match $instanceName $g_NM_rootInstanceName]) && \
          $g_NM_recursiveInstantiationP} {
    set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
    set pirNodeIndex [getNodeGroupParentLink $currentNodeGroup]
    set window [convertCanvasPath [assoc window pirNode($pirNodeIndex)] \
                    $canvasRootId]
    openNodeGroup [assoc nodeInstanceName pirNode($pirNodeIndex)] module \
        $window
  }
}


## create edges from pending list for current canvas
## 23feb98 wmt: new
## 04mar98 wmt: make it work for operational slave canvases also
proc createPendingEdges { canvasRootId } {
  global g_NM_recursiveTraceOutputP g_NM_pendingPirEdgesList 

  set stillPendingEdgesList {}
  set reportNotFoundP 0
  set currentCanvasC "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  set pendingEdgeList [assoc-array $currentCanvasC g_NM_pendingPirEdgesList \
                           $reportNotFoundP] 
  set beginLength [llength $pendingEdgeList] 
  foreach edgeForm $pendingEdgeList {
    # puts stderr "\n\ncreatePendingEdges: edgeForm $edgeForm"
    if {[mkPendingEdge edgeForm $canvasRootId]} {
      lappend stillPendingEdgesList $edgeForm
    }
  }
  # puts stderr "createPendingEdges: canvas $currentCanvasC"
  # puts stderr "    pendingEdgeList [llength $pendingEdgeList] stillPendingEdgesList [llength $stillPendingEdgesList]"
  if {[string match "" $pendingEdgeList]} {
    set reportNotFoundP 0; set oldvalMustExistP 0
  } else {
    set reportNotFoundP 1; set oldvalMustExistP 1
  }
  arepl-array $currentCanvasC $stillPendingEdgesList g_NM_pendingPirEdgesList \
      $reportNotFoundP $oldvalMustExistP
  
  set endLength [llength $stillPendingEdgesList]
  set diffLength [expr {$beginLength - $endLength}]
  if {($diffLength > 0) && $g_NM_recursiveTraceOutputP} {
    set str "\ncreatePendingEdges: creating $diffLength edges"
    set str "$str from g_NM_pendingPirEdgesList"
    # set str "$str $g_NM_pendingPirEdgesList"
    puts stderr "$str"
  }
}


## automaticallly instantiate a defmodule and its children using
## predefined schematic layout
## 22sep96 wmt: derived from pirRedraw
## 21nov96 wmt: added: lappend pirClasses $nodeClassName
##              correct bug in binding children variable labels 
##              with defmodule arg values
## 09dec96 wmt: change from g_NM_instanceToNode to g_NM_componentToNode
## 04may97 wmt: substitute "?acs ", rather than "?acs" to differentiate 
##              between "acs-a" and "acs-turn-a" for nodeInstanceName;  and
##              "?acs)", rather than "?acs" for terminalName; and
##              "?acs}", rather than "?acs" for XcanvasList
## 10may97 wmt: pass argsValues into this proc; add caller arg
##              to differentiate between calls from canvasB1Click & pirRedraw
proc instantiateDefmoduleFromIscm { className instanceName schematicFileName \
                                        defmoduleArgsVars defmoduleArgsValues \
                                        defmoduleAttList caller recursionLevel \
                                        canvasRootId errorDialogP } {
  global g_NM_currentCanvas pirNode XpirClass
  global XpirNodes XpirEdges XpirClasses XpirNode XpirEdge
  global XcanvasList XincludedModules
  global g_NM_inhibitEdgeTypeMismatchP g_NM_parentNodeGroupList
  global g_NM_currentNodeGroup g_NM_processingNodeGroupP 
  global XincludedModules g_NM_pendingPirEdgesList g_NM_instanceToNode 
  global g_NM_livingstoneDefmoduleName 
  global pirGenInt_global g_NM_recursiveInstantiationP g_NM_canvasList
  global g_NM_recursiveIncludeModulesTree g_NM_schematicMode
  global g_NM_componentToNode g_NM_recursiveTraceOutputP
  global g_NM_argsValuesMismatchList g_NM_vmplTestModeP 
  global g_NM_inputInheritedTerms g_NM_outputInheritedTerms
  global g_NM_classInstance g_NM_mkformNodeCompleteP g_NM_win32P
  global g_NM_advisoryRootWindow 

  # puts stderr "instantiateDefmoduleFromIscm: instanceName $instanceName"
  if {! [string match $caller "canvasB1Click"]} {
    # check for existence of included component/module
    set outputMsgP 1
    if {($canvasRootId == 0) && \
            [checkClassInstance $className $instanceName $outputMsgP]} {
      return 2
    }
  }
  set reportNotFoundP 0; set oldvalMustExistP 0
  set canvasRoot [getCanvasRoot $canvasRootId]
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }

  set nodeClassType [assoc nodeClassType defmoduleAttList $reportNotFoundP]
  # for backward compatibility
  if {[string match $nodeClassType ""]} {
    set nodeClassType module
  }

  set schematicFilePath "[getSchematicDirectory nodeType $nodeClassType]/"
  append schematicFilePath $schematicFileName
  if {$g_NM_recursiveTraceOutputP} {
    set str "\nR$recursionLevel: Instantiating def${nodeClassType} $className"
    puts stderr "$str as instance $instanceName from"
    puts stderr "    $schematicFilePath"
    puts stderr "    caller $caller canvasRootId $canvasRootId"
    puts stderr "    currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]"
  }

  ## this is already done in canvasB1Click, but if this is a result of a call
  ## from editComponentModule or instantiateDefinitionUpdate, the user may
  ## open another component/module, thus causing the loss of the source class info
  ## => so do it again
  if {[string match $caller "pirRedraw"] || \
          [string match $caller "createNewRootCanvas"] || \
          [string match $caller "openNodeGroup"] || \
          [string match $caller "canvasB1Click"]} {
    initInstantiationVars

    ## old .scm file contained  pirGenInt_global which resets it.
    ##              we want it to continually count
    set currentVal $pirGenInt_global

    source $schematicFilePath
    sourcePostProcess $schematicFilePath 

    # puts stderr "instantiateDefmoduleFromIscm: sourced $schematicFilePath"
    set pirGenInt_global $currentVal
  }
  # puts stderr "instantiateDefmoduleFromIscm: caller $caller"
  # puts stderr "className $className XpirClass [array names XpirClass]"
  set classVars [assoc class_variables XpirClass($className)]
  set nameVar [getClassVarDefaultValue name_var classVars]
  set nameVarP 0
  if {! [string match $nameVar ""]} {
    set nameVarP 1
  }
  set argsValues [assoc argsValues defmoduleAttList]
  # puts stderr "instantiateDefmoduleFromIscm: instanceName $instanceName argsValues $argsValues"
  # get list of defmodule arg vars
  set argVarsList [getClassVarDefaultValue "args" classVars]
  set argTypesList [getClassVarDefaultValue "argTypes" classVars]

  # add argVarsList/argsValues to defmoduleArgsVars/defmoduleArgsValues
  # put lower regsubs before higher
  # keep ordering
  set argsValuesReverse [lreverse $argsValues]
  set argVarsListReverse [lreverse $argVarsList]
  set argTypesListReverse [lreverse $argTypesList]
  set defmoduleArgsTypes {}
  foreach arg $argVarsListReverse type $argTypesListReverse value $argsValuesReverse { 
    if {([lsearch -exact $defmoduleArgsVars $arg] == -1) || \
            ($arg == "")} {
      ## allow excess values to be put into lists
      if {$arg != ""} {
        set defmoduleArgsVars [linsert $defmoduleArgsVars 0 $arg]
      }
      if {$type != ""} {
        set defmoduleArgsTypes [linsert $defmoduleArgsTypes 0 $type]
      }
      if {$value != ""} {
        set defmoduleArgsValues [linsert $defmoduleArgsValues 0 $value]
      }
    }
  }
 
#   set str "\ninstantiateDefmoduleFromIscm: nameVar $nameVar defmoduleArgsVars"
#   puts stderr "$str $defmoduleArgsVars"
#   set str "instantiateDefmoduleFromIscm: instanceName $instanceName defmoduleArgsValues"
#   puts stderr "$str $defmoduleArgsValues"
  # reconstruct multiple canvases
  set overlayP 0
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]

  set regsubVar "\\$nameVar"
  if {! [string match [string index $nameVar 0] "?"]} {
    set regsubVar [string trimleft $regsubVar "\\"]
  }
  set regsubVal $instanceName
  set regsubValCanvas [getTclPathNodeName $instanceName]

  set regsubArgListDot {}; set regsubArgListSpace {}
  set argValueListDot {}; set argValueListSpace {}

  set mismatchP 0
  set mismatchStringArg ""; set mismatchStringType ""; set mismatchStringValue ""
  foreach arg $defmoduleArgsVars argType $defmoduleArgsTypes argValue $defmoduleArgsValues {
    set expndArgList {}; set expndArgTypeList {}; set expndValueList {}
    expandArgNamesTypesValues $arg $argType $argValue expndArgList \
        expndArgTypeList expndValueList
    # puts stderr "arg $arg argType $argType argValue $argValue "
    # puts stderr "expndArgList $expndArgList expndArgTypeList $expndArgTypeList expndValueList $expndValueList "
    if {[llength $expndArgList] != [llength $expndValueList]} {
      set mismatchP 1
      append mismatchStringArg " $expndArgList"
      append mismatchStringType " $expndArgTypeList"
      append mismatchStringValue " $expndValueList"
    }
  }
  if {$mismatchP} {
    # there is a mismatch between nameVarAndArgsVars & nameValAndArgsValues
    # because the class definition's nameVarAndArgsVars has increased or decreased.
    # prompt user for instance values using current args
    ## force schematic to be marked modified
    lappend g_NM_argsValuesMismatchList $className 
    puts stderr "\ninstantiateDefmoduleFromIscm:"
    if {$g_NM_vmplTestModeP} {
      # ask user to supply param arg values
      set str2 "Supply arg values -- \n   className:    $className \n   "
    } else {
      set str2 "MISMATCH args/values -- \n   className:    $className \n   "
    }
    append str2 "instanceName: [getExternalNodeName $instanceName]"
    set mismatchString "   expndArgList:    $mismatchStringArg \n"
    append mismatchString "   expndArgTypeList:$mismatchStringType \n"
    append mismatchString "   expndValueList:  $mismatchStringValue"
    puts stderr "$str2\n\n$mismatchString"
    # puts stderr "recursionLevel $recursionLevel"
    if {$recursionLevel == 0} {
      if {$errorDialogP} {
        # alert user to what is going on
        set dialogList [list tk_dialog ${g_NM_advisoryRootWindow}.d "ADVISORY" \
                            "$str2\n\n$mismatchString" warning 0 {DISMISS}]
        eval $dialogList
      }
      # these are editable instances
      # puts stderr "defmoduleAttList $defmoduleAttList"
      set g_NM_mkformNodeCompleteP 0
      askClassInstance [assoc nodeClassType defmoduleAttList] $className \
          $defmoduleArgsVars $argTypesList "instantiateDefmoduleFromIscm" \
          $instanceName $defmoduleArgsValues [assoc instanceLabel defmoduleAttList]
      if {! $g_NM_mkformNodeCompleteP} {
        # user cancelled dialog
        return 2
      } else {
        # apply user specified values
        # puts stderr "g_NM_classInstance $g_NM_classInstance"
        set instanceName [lindex $g_NM_classInstance 0]
        set instanceLabel [lindex $g_NM_classInstance 1]
        set defmoduleArgsValues [lindex $g_NM_classInstance 3]
        arepl instanceLabel $instanceLabel defmoduleAttList 
        arepl argsValues $defmoduleArgsValues defmoduleAttList
        lappend g_NM_argsValuesMismatchList [list argsValues $defmoduleArgsValues]
      }
    } else {
      # abort this schematic, since args/values mismatch is at a recursion
      # greater than 0 -- changes made here will not be saved, since they
      # are in a lower level schematic
      set str "\nDo `File->Open Definition' for "
      append str "[assoc nodeClassType defmoduleAttList] $className"
      puts stderr $str
      if {$errorDialogP} {
        set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
        eval $dialogList
      }
      return 2 
    }
  }
  set nameVarAndArgsVars $defmoduleArgsVars
  set nameValAndArgsValues $defmoduleArgsValues 
  # set str "instantiateDefmoduleFromIscm: B nameVarAndArgsVars $nameVarAndArgsVars"
  # puts stderr "$str nameValAndArgsValues $nameValAndArgsValues"
  if {$nameVarP} {
    # add nameVar/instanceName to argVarsargValues regsub list
    set nameVarAndArgsVars [concat $regsubVar $defmoduleArgsVars]
    set nameValAndArgsValues [concat $regsubVal $defmoduleArgsValues]
  }
  # set str "instantiateDefmoduleFromIscm: A nameVarAndArgsVars $nameVarAndArgsVars"
  # puts stderr "$str nameValAndArgsValues $nameValAndArgsValues"

  buildRegsubVarValueLists nameVarAndArgsVars nameValAndArgsValues \
      regsubArgListDot regsubArgListSpace \
      argValueListDot argValueListSpace 

  # puts stderr "instantiateDefmoduleFromIscm: regsubArgListDot $regsubArgListDot"
  set skipNameVarP 0
  if {[string match $caller "pirRedraw"] && $nameVarP} {
    set skipNameVarP 1
  }
  if {! [string match $caller "openNodeGroup"]} {
    # already done if called by openNodeGroup 
    # apply argsVars/argsValues to defmoduleAttList
    # for parameter variables only, not instance variable (nameVar)
    # puts stderr "instantiateDefmoduleFromIscm: applyRegsub defmoduleAttList"
    applyRegsub defmoduleAttList \
        regsubArgListDot regsubArgListSpace \
        argValueListDot argValueListSpace $skipNameVarP 
  }

  if {[string match [assoc nodeClassType XpirClass($className)] "component"]} {
    # apply argsVars/argsValues to class definition 
    # so that initially and background_model will be properly instantiated
    # for parameter variables only, not instance variable (nameVar)
    set componentSubList [list background_model \
                              [getClassVarDefaultValue background_model classVars] \
                              initially [getClassVarDefaultValue initially classVars]]
    applyRegsub componentSubList \
        regsubArgListDot regsubArgListSpace \
        argValueListDot argValueListSpace $skipNameVarP
    setClassVarDefaultValue background_model [assoc background_model componentSubList] \
        classVars 
    setClassVarDefaultValue initially [assoc initially componentSubList] classVars 
    arepl class_variables $classVars XpirClass($className)
  }
  if {[string match [assoc nodeClassType XpirClass($className)] "module"]} {
    # apply argsVars/argsValues to class definition 
    # so that facts will be properly instantiated
    # for parameter variables only, not instance variable (nameVar)
    set moduleSubList [list facts [getClassVarDefaultValue facts classVars]]
    applyRegsub moduleSubList \
        regsubArgListDot regsubArgListSpace \
        argValueListDot argValueListSpace $skipNameVarP
    setClassVarDefaultValue facts [assoc facts moduleSubList] \
        classVars 
    arepl class_variables $classVars XpirClass($className)
  }
  # canvases are not created here anymore - canvases are created on demand
  # in mkNodeIcon
#   # parent module instantiation creates canvas for child
#   if {[string match $caller "canvasB1Click"] || \
#           [string match $caller "createNewRootCanvas"]} {
#     foreach canvas $XcanvasList {
#       set canvas [convertCanvasPath $canvas $canvasRootId]
#       # puts stderr "instantiateDefmoduleFromIscm: canvas $canvas g_NM_canvasList 
#       #                  $g_NM_canvasList"
#       if {[lsearch -exact $g_NM_canvasList $canvas] == -1} {
#         createCanvas $canvas 0 0 $overlayP
#       }
#     }
#   }
  setCanvasRootInfo g_NM_currentCanvas $currentCanvas $canvasRootId
  set g_NM_processingNodeGroupP 1

  set outputMsgP 1; set callerRedrawP 1
  set newModes {}; # component mode nodes
  set XpirNewNodes {}; set XterminalAttributeNodes {}
  # reconstruct each node
  # a variation of this code is in pirRedraw
  foreach node $XpirNodes {
    # puts stderr "BB [assoc nodeInstanceName XpirNode($node)] type [assoc nodeClassType XpirNode($node)] class [assoc nodeClassName XpirNode($node)]"
#     if {[assoc nodeInstanceName XpirNode($node)] == "?name.pressIn"} {
#       puts stderr "BB $XpirNode($node)"
#     }
#     if {[string match [assoc nodeClassType XpirNode($node)] attribute]} {
#       puts stderr "BB [assoc nodeInstanceName XpirNode($node)] $XpirNode($node)"
#     }
    ## apply argsVars/argsValues to XpirNode($node)
    # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to
    # introduce unwanted . tcl delimiters into paths
    set window [assoc window XpirNode($node)]
    regsub $regsubVar $window $regsubValCanvas tmpWindow
    applyRegsub XpirNode($node) \
        regsubArgListDot regsubArgListSpace \
        argValueListDot argValueListSpace 

    arepl window $tmpWindow XpirNode($node)
#     if {[assoc nodeInstanceName XpirNode($node)] == "?name.line1.pressIn"} {
#       puts stderr "AA $XpirNode($node)"
#     }

    ## add nodeClassName facts to nodeClassType modules to be used by
    ## generateMPLCompletionForms
    if {[string match [assoc nodeClassType XpirNode($node)] "module"] && \
            (! [string match [assoc nodeState XpirNode($node)] "parent-link"])} { 
      arepl facts [assoc facts moduleSubList] \
          XpirNode($node) $reportNotFoundP $oldvalMustExistP
    }

    # if parameters are referenced in the background model or initial conditions
    # then pirClassComponent must be added to node instance
    # to be accessed by askLivingstoneDefcomponentParams in view mode
    if {[string match [assoc nodeClassType XpirNode($node)] "component"]} {
      arepl background_model [assoc background_model componentSubList] \
          XpirNode($node) $reportNotFoundP $oldvalMustExistP
      arepl initially [assoc initially componentSubList] \
          XpirNode($node) $reportNotFoundP $oldvalMustExistP
    }

    set nodeX [assoc nodeX XpirNode($node)]
    set nodeY [assoc nodeY XpirNode($node)]
    set labelX [assoc labelX XpirNode($node) $reportNotFoundP]
    if {$labelX  == ""} { set labelX -1 }
    set labelY [assoc labelY XpirNode($node) $reportNotFoundP]
    if {$labelY == ""} { set labelY -1 }
    set canvas [getCanvasFromWindow [assoc window XpirNode($node)]]
    set canvas [convertCanvasPath $canvas $canvasRootId]  
    set nodeState [assoc nodeState XpirNode($node)]
    set nodeInstanceName [assoc nodeInstanceName XpirNode($node)]
    set nodeClassName [assoc nodeClassName XpirNode($node)] 
    set nodeClassType [assoc nodeClassType XpirNode($node)]
    set nodeGroupName [assoc nodeGroupName XpirNode($node)]

    ## parentNodeGroupList e.g. {?name root}
    set parentNodeGroupList [assoc parentNodeGroupList XpirNode($node)]
    set len [llength $parentNodeGroupList]
    set parentNodeGroupList [lrange $parentNodeGroupList 0 [expr {$len - 2}]]
    ## current - g_NM_parentNodeGroupList 
    foreach groupName [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId] {
      set parentNodeGroupList [linsert $parentNodeGroupList end $groupName]
    }
    arepl parentNodeGroupList $parentNodeGroupList XpirNode($node)
    # puts stderr "nodeInstanceName $nodeInstanceName nodeClassType $nodeClassType"
    # puts stderr "nodeState $nodeState nodeGroupName $nodeGroupName"
    # puts stderr "nodeClassName $nodeClassName className $className"
    if {[string match $nodeGroupName "root"] && \
            ([string match $nodeState "NIL"] || \
                 [string match $nodeClassType component])} {
      arepl nodeGroupName [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId] \
          XpirNode($node)
    }
    ## if {[string match $nodeClassName $className] && 
    ##         ([string match $nodeState "NIL"] || 
    ##              [string match $nodeClassType component])}
    if {[regexp "canvas\\\.root" $canvas]} {
      set localRootInstanceName $nodeInstanceName
      if {[string match $caller "canvasB1Click"]} {
        # do not instantiate root module if called by canvasB1Click (done there)
        # puts stderr "instantiateDefmoduleFromIscm: nodeInstanceName $nodeInstanceName continue"
        continue
      } elseif {! [string match $caller "createNewRootCanvas"]} {
        # reset canvas, nodeX, nodeY, labelX, & labelY from g_NM_includedModule
        # (recursiveDefmoduleInstantiation) caller pirRedraw or openNodeGroup
        set canvas [getCanvasFromWindow [assoc window defmoduleAttList]]
        set canvas [convertCanvasPath $canvas $canvasRootId]  
        set nodeX [assoc nodeX defmoduleAttList]
        set nodeY [assoc nodeY defmoduleAttList]
        set labelX [assoc labelX defmoduleAttList $reportNotFoundP]
        if {$labelX  == ""} { set labelX -1 }
        set labelY [assoc labelY defmoduleAttList $reportNotFoundP]
        if {$labelY == ""} { set labelY -1 }
        # pass argsValues from includedModules to pirNode args
        # which inturn goes into current g_NM_includedModules via addClassInstance
        set argsValues [assoc argsValues defmoduleAttList]
        arepl argsValues $argsValues XpirNode($node)
        arepl numArgsVars [llength $argsValues] XpirNode($node)
      }
    }
    # set str "instantiateDefmoduleFromIscm: nodeInstanceName $nodeInstanceName"
    # puts stderr "$str nodeClassName $nodeClassName caller $caller canvas $canvas"
    set tempNode $XpirNode($node)
    # puts stderr "instantiateDefmoduleFromIscm: node $node tempNode $tempNode"
    # puts stderr "instantiateDefmoduleFromIscm: parentNodeGroupList $parentNodeGroupList"
    # puts stderr "instantiateDefmoduleFromIscm: canvas $canvas nodeClassName $nodeClassName"
    if {[string match $nodeState "parent-link"]} {
      if {[string match $nodeInstanceName $instanceName]} {
        set index 0
      } else {
        set index 1
      }
      set parentNodeName [lindex $parentNodeGroupList $index]
      append parentNodeName "_P"
      set uniqueParentNodeName [pirGenSym $parentNodeName]
      buildParentNode $uniqueParentNodeName $canvas $nodeClassName tempNode
      # puts stderr "instantiateDefmoduleFromIscm: p uniqueParentNodeName $uniqueParentNodeName"
      puts -nonewline stderr "p"
    } else {
      foreach field [list nodeX nodeY labelX labelY canvasId window edgesTo \
                         edgesFrom canvas] {
        adel $field tempNode $reportNotFoundP
      }
      set nodeClassType [lindex [getNodeClassTypeAndName tempNode] 0]
      set nodeClassName [assoc nodeClassName XpirNode($node)]
      # puts stderr "instantiateDefmoduleFromIscm: nodeClassType $nodeClassType"
      if {[string match $nodeClassType component] || \
              [string match $nodeClassType module]} {
        set instanceLabel [assoc instanceLabel defmoduleAttList $reportNotFoundP]
        # override default class input/output terminal ordering with that
        # specified by the instance, except that terminal labels in the class_inputs
        # will be passed to the instance, as well as new terminals.
        # terminals not in class_inputs will be deleted from instance_inputs

        set instance_inputs [assoc inputs defmoduleAttList $reportNotFoundP]
        set instance_outputs [assoc outputs defmoduleAttList $reportNotFoundP]
        set local_class_inputs [assoc inputs tempNode]
        set local_class_outputs [assoc outputs tempNode]

        applyTerminalInheritance $nodeInstanceName $nodeClassType $nodeClassName \
            $nameVarAndArgsVars $nameValAndArgsValues $instanceLabel \
            instance_inputs instance_outputs \
            local_class_inputs local_class_outputs inputs numInputs \
            outputs numOutputs

        arepl inputs $inputs tempNode
        arepl numInputs [expr {[llength $inputs] / 2}] tempNode
        arepl outputs $outputs tempNode
        arepl numOutputs [expr {[llength $outputs] / 2}] tempNode
      } else {
        set instanceLabel [assoc instanceLabel XpirNode($node) $reportNotFoundP]
      }
      arepl instanceLabel $instanceLabel tempNode $reportNotFoundP $oldvalMustExistP

      set newNum [mkNode $canvas $nodeX $nodeY $labelX $labelY tempNode \
                      $nodeClassType $outputMsgP $callerRedrawP]
      if {$newNum == -1} {
        return 1
      }
      set XpirNewNode($node) $newNum
      lappend XpirNewNodes $newNum 
      if {[string match $nodeClassType mode]} {
        lappend newModes $newNum
      }
      switch -exact $nodeClassType {
        terminal {puts -nonewline stderr "t"}
        attribute {puts -nonewline stderr "a"}
        module {puts -nonewline stderr "m"} 
        component {puts -nonewline stderr "c"} 
        mode {puts -nonewline stderr "o"} 
        default {puts -nonewline stderr "?"} 
      }
      # puts stderr "instantiateDefmoduleFromIscm: nodeClassName $nodeClassName"
      ## set pirClass stmt must follow mkNode call, or it screws up pirNode entries
      if {[string match $caller "pirRedraw"] || \
              [string match $caller "openNodeGroup"] || \
              ([string match $caller "canvasB1Click"] && \
                   (! [string match $nodeClassName $className]))} {
        if {[lsearch -exact [getClasses $nodeClassType] $nodeClassName] == -1} {
          set XpirClassDef $XpirClass($nodeClassName)
          setClass $nodeClassType $nodeClassName XpirClassDef
          if {[string match $nodeClassType "component"]} {
            # create recovery_modes from fault_modes and mode_transitions
            createRecoveryModes $nodeClassName
          }
          lappendClasses $nodeClassType $nodeClassName 
        } else {
          ; # puts stderr "instantiateDefmoduleFromIscm: pirClass $nodeClassName already exists\!"
        }
      }
    }
  }
  update;       # ensure that nodes are totally processed
  # reconstruct each edge
  # a variation of this code is in pirRedraw
  set numBreaks 0;      # use info in interimXYList 
  set g_NM_inhibitEdgeTypeMismatchP 1
  set pendingPirEdgesList {}
  foreach edge $XpirEdges {
    ## apply argsVars/argsValues to XpirEdge($edge)
    # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to not
    # introduce unwanted . tcl delimiters into paths
    set buttonFrom [assoc buttonFrom XpirEdge($edge)]
    regsub $regsubVar $buttonFrom $regsubValCanvas tmpButtonFrom
    set buttonTo [assoc buttonTo XpirEdge($edge)]
    regsub $regsubVar $buttonTo $regsubValCanvas tmpButtonTo
    applyRegsub XpirEdge($edge) \
        regsubArgListDot regsubArgListSpace \
        argValueListDot argValueListSpace 
    arepl buttonFrom $tmpButtonFrom XpirEdge($edge)
    arepl buttonTo $tmpButtonTo XpirEdge($edge)

    set fromEdgeAttrList [assoc terminalFrom XpirEdge($edge)]
    set toEdgeAttrList [assoc terminalTo XpirEdge($edge)]
    set portEdgeType [isThisAPortEdge $edge $fromEdgeAttrList $toEdgeAttrList]
    if {([string match $portEdgeType "portFromTo"]) || \
        ([string match $portEdgeType "port->From"])} {
      set whichEdges edgesFrom
      set direction out
    } elseif {([string match $portEdgeType ""]) || \
        ([string match $portEdgeType "port->To"])} {
      set whichEdges edgesTo
      set direction in

    } else {
      puts stderr "instantiateDefmoduleFromIscm: portEdgeType $portEdgeType not handled\!"
    }
    set canvas [getCanvasFromButton [assoc buttonFrom XpirEdge($edge)]]
    set canvas [convertCanvasPath $canvas $canvasRootId]  
    set interimXYList [assoc interimXYList XpirEdge($edge)]
    set oldNodeFrom [assoc nodeFrom XpirEdge($edge)]
    set oldNodeTo [assoc nodeTo XpirEdge($edge)]
    set documentation [assoc documentation XpirEdge($edge) $reportNotFoundP]
    set abstractionType [assoc abstractionType XpirEdge($edge) $reportNotFoundP]
    # are both these nodes in this current module; if not replace node nums
    # with node instance names, and create after all nodes are created
    set includedFromP 1; set includedToP 1
    if {[lsearch -exact $XpirNodes $oldNodeFrom] == -1} {
      set includedFromP 0
      set oldNodeFromName [getNodeInstanceNameFromIncludedModules $oldNodeFrom \
                               XincludedModules]
      # handle ?name.?svName - ?svName requires delimiting . for substitution
      append oldNodeFromName "."
      applyRegsub oldNodeFromName \
          regsubArgListDot regsubArgListSpace \
          argValueListDot argValueListSpace 
      set oldNodeFromName [string trimright $oldNodeFromName "."]
    } else {
      set oldNodeFromName [assoc nodeInstanceName XpirNode($oldNodeFrom)]
    }      
    if {[lsearch -exact $XpirNodes $oldNodeTo] == -1} {
      set includedToP 0
      set oldNodeToName [getNodeInstanceNameFromIncludedModules $oldNodeTo \
                             XincludedModules]
      # handle ?name.?svName - ?svName requires delimiting . for substitution
      append oldNodeToName "."
      applyRegsub oldNodeToName \
          regsubArgListDot regsubArgListSpace \
          argValueListDot argValueListSpace 
      set oldNodeToName [string trimright $oldNodeToName "."]
    } else {
      set oldNodeToName [assoc nodeInstanceName XpirNode($oldNodeTo)]
    }
    set oldNodeFromNum [assoc nodeFrom XpirEdge($edge)]
    set oldNodeToNum [assoc nodeTo XpirEdge($edge)]
    if {(! $includedFromP) || (! $includedToP)} {
      arepl nodeFrom $oldNodeFromName XpirEdge($edge)
      arepl nodeTo $oldNodeToName XpirEdge($edge)
      lappend pendingPirEdgesList $XpirEdge($edge)
      continue
    }
    set fromButtonNum [pirEdgeIndex $edge [assoc edgesFrom XpirNode($oldNodeFrom)]]
    set toButtonNum [pirEdgeIndex $edge [assoc $whichEdges XpirNode($oldNodeTo)]]
    set nodeFromNum $XpirNewNode($oldNodeToNum)
    set nodeToNum $XpirNewNode($oldNodeToNum)
    set checkTypesP 0
    set inbut [assoc window pirNode($nodeToNum)].$direction.b$toButtonNum
    set outbut [assoc window pirNode($nodeFromNum)].out.b$fromButtonNum
    set edge1 [mkEdge $inbut $outbut $numBreaks $interimXYList $portEdgeType \
                   $canvas $checkTypesP $documentation $abstractionType]
    global pirEdge($edge1)
    ## puts stderr "instantiateDefmoduleFromIscm: edge $edge edge1 $edge1"
  }

  if {$canvasRootId == 0} {
    # for nodeType = mode, replace pirNode indices with new values in transitions
    # attribute
    foreach modeIndex $newModes {
      set transitionList [assoc transitions pirNode($modeIndex) $reportNotFoundP]
      if {[llength $transitionList] > 0} {
        set newTransitionList {}
        foreach transition $transitionList {
          set startNodeInstanceName [assoc nodeInstanceName \
                                         XpirNode([assoc startNode transition])]
          set startPirNodeIndex [assoc-array $startNodeInstanceName g_NM_instanceToNode]
          arepl startNode $startPirNodeIndex transition 
          set stopNodeInstanceName [assoc nodeInstanceName \
                                        XpirNode([assoc stopNode transition])]
          set stopPirNodeIndex [assoc-array $stopNodeInstanceName g_NM_instanceToNode]
          arepl stopNode $stopPirNodeIndex transition
          lappend newTransitionList $transition
        }
        arepl transitions $newTransitionList pirNode($modeIndex)
      }
    }
  }
  # since this is *not* a top level component, its canvas is not exposed and thus its
  # mode windows are not expanded and at this point it has invalid winfo geometries
  # the transistions will be drawn by overlayCurrentCanvas
  if {[llength $newModes] > 0} {
    set parentNodeInstanceName  [lindex [assoc parentNodeGroupList \
                                             pirNode([lindex $newModes 0])] 0]
    set parentNodeIndex [assoc-array $parentNodeInstanceName g_NM_componentToNode]
    # keep a copy of newModes for master and slave canvases
    set transitionModesToDraw [assoc transitionModesToDraw \
                                   pirNode($parentNodeIndex) $reportNotFoundP]
    set currentEntries [assoc $canvasRootId transitionModesToDraw $reportNotFoundP]
    if {[string match "" $currentEntries]} {
      set reportNotFoundP 0; set oldvalMustExistP 0
    } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
    set currentEntries [concat $currentEntries $newModes]
    arepl $canvasRootId $currentEntries transitionModesToDraw $reportNotFoundP \
        $oldvalMustExistP
    arepl transitionModesToDraw $transitionModesToDraw pirNode($parentNodeIndex)
  }

  # bug in Tcl versions 8.2 and 8.3 (fixed in 8.4a2), which causes excessive memory use when
  # calling "info exists" on a non-existent array element.
  # [info exists XincludedModules] 
  # puts stderr "instantiate: exists [info exists XincludedModules] len [llength $XincludedModules] nodeClassType [assoc nodeClassType XpirClass($className)] className $className "
  if {([assoc nodeClassType XpirClass($className)] == "module") && \
          [llength $XincludedModules] > 0} {
    set newXincludedModules {}; set indx 0
    foreach element $XincludedModules {
      ## apply argsVars/argsValues to XincludedModules
      # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to not
      # introduce unwanted . tcl delimiters into paths
      if {($indx % 2) != 0} {
        set window [assoc window element]
        regsub $regsubVar $window $regsubValCanvas tmpWindow
      } else {
        # handle ?name.?svName - ?svName requires delimiting . for substitution
        append element "."
      }
      applyRegsub element \
          regsubArgListDot regsubArgListSpace \
          argValueListDot argValueListSpace 
      if {($indx % 2) != 0} {
        arepl window $tmpWindow element
      } else {
        set element [string trimright $element "."]
      }
      lappend newXincludedModules $element
      incr indx
    }
    set XincludedModules $newXincludedModules 
    # applyRegsub changes instance names
    set incInstanceNamelist {}
    for {set i 0} {$i < [llength $XincludedModules]} { incr i 2} {
      lappend incInstanceNamelist [lindex $XincludedModules $i]
    }
    if {! $g_NM_recursiveInstantiationP} {
      # add to g_NM_recursiveIncludeModulesTree

      # bug in Tcl versions 8.2 and 8.3 (fixed in 8.4a2), which causes excessive memory use when
      # calling "info exists" on a non-existent array element.
      # [info exists g_NM_recursiveIncludeModulesTree($recursionLevel)]
      if {[lsearch -exact [array names g_NM_recursiveIncludeModulesTree] \
               $recursionLevel] == -1} {
        set g_NM_recursiveIncludeModulesTree($recursionLevel) {}
      }
      acons $instanceName $XincludedModules \
          g_NM_recursiveIncludeModulesTree($recursionLevel)
      # puts stderr "recursiveDefmoduleInstantiation: recursionLevel $recursionLevel"
      # puts stderr "    includedModules $g_NM_recursiveIncludeModulesTree($recursionLevel)"
    }
  }
  if {[llength $pendingPirEdgesList] > 0} {
    set currentEntries [assoc-array $canvas g_NM_pendingPirEdgesList \
                            $reportNotFoundP] 
    # puts stderr "instantiateDefmoduleFromIscm: canvas $canvas"
    # puts stderr "    g_NM_pendingPirEdgesList [llength $currentEntries] pendingPirEdgesList [llength $pendingPirEdgesList]"
    if {[string match "" $currentEntries]} {
      set lReportNotFoundP 0; set lOldvalMustExistP 0
    } else {
      set lReportNotFoundP 1; set lOldvalMustExistP 1
    }
    set currentEntries [concat $currentEntries $pendingPirEdgesList]
    arepl-array $canvas $currentEntries g_NM_pendingPirEdgesList \
        $lReportNotFoundP $lOldvalMustExistP
    # puts stderr "recursiveDefmoduleInstantiation: g_NM_pendingPirEdgesList $currentEntries"
  }

  # puts stderr "recurse: recursionLevel $recursionLevel"
  # puts stderr "recurse: g_NM_recursiveInstantiationP $g_NM_recursiveInstantiationP"
  # bug in Tcl versions 8.2 and 8.3 (fixed in 8.4a2), which causes excessive memory use when
  # calling "info exists" on a non-existent array element.
  # puts stderr "instantiate: 2 exists [info exists XincludedModules] len [llength $XincludedModules] nodeClassType [assoc nodeClassType XpirClass($className)] className $className "
  if {($g_NM_recursiveInstantiationP || \
           ((! $g_NM_recursiveInstantiationP) && ($recursionLevel < 0))) && \
          ([assoc nodeClassType XpirClass($className)] == "module") && \
          [llength $XincludedModules] > 0} {
    ## components do not have included modules 
    # recurse
    set caller "pirRedraw"; incr recursionLevel
    set pirNodeIndex [assoc-array $localRootInstanceName g_NM_instanceToNode]
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    recursiveDefmoduleInstantiation $localRootInstanceName $XincludedModules \
        $defmoduleArgsVars $defmoduleArgsValues $caller $recursionLevel \
        $nodeClassType $canvasRootId $errorDialogP
    set g_NM_processingNodeGroupP 0
  }
  set g_NM_inhibitEdgeTypeMismatchP 0
  if {[string match $caller "canvasB1Click"]} {
    mark_scm_modified
  }
  return 0
}


## build regsub exp and subSpec args for variables right delimited by
## " ", "~", "_", ")", "}", & "."
## 22may97 wmt: new
## 23jul97 wmt: add option for case: upper or lower
## 08sep97 wmt: add ~ as delimiter
## -----01 wmt: reduce delimiters to " ", & "."
proc buildRegsubVarValueLists { varListRef valueListRef \
                                    regsubVarListDotRef regsubVarListSpaceRef \
                                    argValueListDotRef argValueListSpaceRef } {
  upvar $varListRef varList
  upvar $valueListRef valueList
  upvar $regsubVarListSpaceRef regsubVarListSpace
  upvar $regsubVarListDotRef regsubVarListDot

  upvar $argValueListSpaceRef argValueListSpace
  upvar $argValueListDotRef argValueListDot

  # puts stderr "buildRegsubVarValueLists: varList $varList valueList $valueList"
  for {set i 0} {$i < [llength $varList]} {incr i} {
    set arg [lindex $varList $i]
    # must escape ? and .
    set regsubArg [getMplRegExpression $arg]

    # for java syntax, only . and <space> delimiters are needed

    set regsubArgDot "$regsubArg\\\."
    lappend regsubVarListDot $regsubArgDot
    set regsubArgSpace "$regsubArg "
    lappend regsubVarListSpace $regsubArgSpace

    set value [lindex $valueList $i]
    set valueDot "$value\."
    lappend argValueListDot $valueDot
    set valueSpace "$value "
    lappend argValueListSpace $valueSpace
  }
}


## java syntax substitution is much easier than Lisp substitution.
## Lisp needed <space> dot underscore AND braces parens tilde
## for ?name terminating delimiters, e.g. to differentiate ?acs from ?acs-mode
## because of the s-exps:
## parens (DISPLAY-STATE~?NAME)
## braces ?NAME was transformed to {?NAME} for substituion
## tilde  (INPUT (THRSTR-VALVE~?NAME~X))
##
## because substituting the whole form with these terminators could lead
## to unwanted multiple substitution, e.g.
## dot then paren of arg ?name & value (bus~?name) for
## .master.canvas.?name.w12 would give
## .master.canvas.(bus~?name).w12 then
## .master.canvas.(bus~(bus~?name)).w12
## the forms were subdivided into smaller and smaller forms and then only
## one delimiter type substitution was allowed
## 18dec99 wmt: new
proc applyRegsub { formRef regsubArgListDotRef regsubArgListSpaceRef \
                       argValueListDotRef argValueListSpaceRef \
                       { skipNameVarP 0 } { debugOutputP 0 } } {
  upvar $formRef form
  upvar $regsubArgListSpaceRef regsubArgListSpace
  upvar $regsubArgListDotRef regsubArgListDot

  upvar $argValueListSpaceRef argValueListSpace
  upvar $argValueListDotRef argValueListDot

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "applyRegsub: `$backtrace'"

  set debugOutputP 0
  set numArgs [llength $regsubArgListSpace]
  if {$numArgs  == 0} {
    return 0
  }
  set startIndx 0; set totalCnt 0
  if {$skipNameVarP} {
    set startIndx 1
  }

  if {$debugOutputP} {
    puts stderr "applyRegsub: BEFORE FORM `$form'"
  }
  set dotCnt 0; set spaceCnt 0
  # instance varaiablea (nameVar) args will have ? as first character
  # However, parameter variables will not

  # most forms may have both . and <space> substitutions, so do both for each arg
  # window and canvas forms will have . and _ substitutions, and will be
  # done separately without calling applyRegsub:
  for {set indx $startIndx} {$indx < $numArgs} {incr indx} {
    incr dotCnt [regsub -all [lindex $regsubArgListDot $indx] $form \
                       [lindex $argValueListDot $indx] instForm]
    if {$debugOutputP} {
      puts stderr "    DOT  dotCnt $dotCnt"
    }
    set form $instForm; incr totalCnt $dotCnt

    incr spaceCnt [regsub -all [lindex $regsubArgListSpace $indx] $form \
                       [lindex $argValueListSpace $indx] instForm]
    if {$debugOutputP} {
      puts stderr "    SPACE spaceCnt $spaceCnt"
    }
    set form $instForm; incr totalCnt $spaceCnt
  }
  if {$debugOutputP} {
    puts stderr "applyRegsub: AFTER FORM `$form' dotCnt $dotCnt spaceCnt $spaceCnt"
  }
  return $totalCnt
}


## return regexp regular expression with escaped "?"s and "."s
## both may occur in expression 
## 02jun98 wmt: new
proc getMplRegExpression { expression } {

  set regexpForm [getRegExpressionDoit $expression "?" foundItP]
  set regexpForm [getRegExpressionDoit $regexpForm "." foundItP]
  return $regexpForm
}
  

## return escaped regular expression for char for all possible
## regular expression characters
## 02jun98 wmt: new
proc getCharRegExpression { char } {

  # set specialChars "?.*+?{}()"
  # don't know why ? appears twice ???
  set specialChars "?.*+{}()"
  for {set i 0} {$i < [string length $specialChars]} {incr i} {
    set regexpForm [getRegExpressionDoit $char [lindex $specialChars $i] foundItP]
    if {$foundItP} {
      break
    }
  }
  return $regexpForm
}
  

## return regexp regular expression with escaped specialChar 
## 02jun98 wmt: new
proc getRegExpressionDoit { expression specialChar foundItPRef } {
  upvar $foundItPRef foundItP

  set regexpForm ""
  set index [string first $specialChar $expression]
  if {$index == -1} {
    set regexpForm $expression
    set foundItP 0
  } else {
    set lastIndex 0; set cntMax 10; set cnt 0; set foundItP 1
    while {$index != -1} {
      # puts stderr "getRegExpressionDoit: lastIndex $lastIndex index $index"
      append regexpForm [string range $expression $lastIndex [expr {$index - 1}]]
      append regexpForm "\\"
      set subExpression [string range $expression [expr {1 + $index}] end]
      # puts stderr "getRegExpressionDoit: regexpForm $regexpForm subExpression $subExpression"
      set secondIndex [string first $specialChar $subExpression]
      if {$secondIndex == -1} {
        append regexpForm [string range $expression $index end]
        set index $secondIndex 
      } else {
        set lastIndex $index 
        set index [expr {$secondIndex + $index + 1}]
      }
      # puts stderr "getRegExpressionDoit: regexpForm $regexpForm"
      incr cnt
      if {$cnt > $cntMax} {
        break
      }
    }
  }
  return $regexpForm 
} 


## redraw mode transitions form transition defintion
## 20jul97 wmt: new
proc redrawModeTransitions { canvas startPirNodeIndex stopPirNodeIndex } {
  global pirNode 

  set canvasRoot {}
  set canvasRootId [getCanvasRootId $canvas canvasRoot]
  set startNodeWindow [getWindowPathFromPirNodeIndex $startPirNodeIndex $canvas]
  set stopNodeWindow [getWindowPathFromPirNodeIndex $stopPirNodeIndex $canvas]
  drawModeTransition $canvas $startNodeWindow $stopNodeWindow lineId arrowId \
      $startPirNodeIndex $stopPirNodeIndex 

  if {$canvasRootId == 0} {
    # puts stderr "redrawModeTransitions: lineId $lineId arrowId $arrowId"
    # update transition definitions
    setComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
        $stopPirNodeIndex lineId $lineId 
    setComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
        $stopPirNodeIndex arrowId $arrowId
  }
  return $arrowId 
}


## create recovery_modes from fault_modes and mode_transitions
## for components
## 09dec96 wmt: new 
proc createRecoveryModes { nodeClassName } {
  global pirClassComponent

  set reportNotFoundP 0; set oldvalMustExistP 0
  set internalVars $pirClassComponent($nodeClassName)
  set classVars [assoc class_variables internalVars]
  set fault_modes [getClassVarDefaultValue fault_modes classVars]
  set mode_transitions [getClassVarDefaultValue mode_transitions classVars]
  set recovery_modesDefault {}
  foreach mode $fault_modes {
    foreach transition $mode_transitions {
      if {[lsearch -exact $transition $mode] >= 0} {
        lappend recovery_modesDefault $mode
        break
      }
    }
  }
  # set str "createRecoveryModes: nodeClassName $nodeClassName"
  # puts stderr "$str recovery_modesDefault $recovery_modesDefault"
  arepl recovery_modes "default {$recovery_modesDefault}" classVars \
      $reportNotFoundP $oldvalMustExistP
  arepl class_variables $classVars pirClassComponent($nodeClassName)
}


## do the terminal inheritance for a component/module inputs/outputs
## 03nov99 wmt: extracted from instantiateDefmoduleFromIscm
proc applyTerminalInheritance { nodeInstanceName nodeClassType nodeClassName \
                                    nameVarAndArgsVars nameValAndArgsValues \
                                    instanceLabel \
                                    instance_inputsRef instance_outputsRef \
                                    local_class_inputsRef local_class_outputsRef \
                                    inputsRef numInputsRef \
                                    outputsRef numOutputsRef } {
  upvar $instance_inputsRef instance_inputs
  upvar $instance_outputsRef instance_outputs
  upvar $local_class_inputsRef local_class_inputs
  upvar $local_class_outputsRef local_class_outputs
  upvar $inputsRef inputs
  upvar $numInputsRef numInputs
  upvar $outputsRef outputs
  upvar $numOutputsRef numOutputs
  global g_NM_inputInheritedTerms g_NM_outputInheritedTerms
  global g_NM_argsValuesMismatchList

  # commented to allow g_NM_argsValuesMismatchList to say non-nil, if
  # set by instantiateDefmoduleFromIscm
  # does it effect applyTerminalInheritance ?? 21feb02
  # set g_NM_argsValuesMismatchList {}
  if {[string match $nodeClassType module]} {
    # do not apply "top-level" label to inherited label
    # set inheritInstanceLabel $instanceLabel
    set inheritInstanceLabel ""
    getInheritedTerminals $nodeInstanceName $nodeClassName \
        $nodeClassType $nameVarAndArgsVars $nameValAndArgsValues \
        $inheritInstanceLabel 
    set class_inputs $g_NM_inputInheritedTerms
    set class_outputs $g_NM_outputInheritedTerms 
  } else {
    set class_inputs $local_class_inputs
    set class_outputs $local_class_outputs
  }
  # puts stderr "applyTerminalInheritance: get -> class_inputs $class_inputs"
  # puts stderr "applyTerminalInheritance: get -> class_outputs $class_outputs"

  set inputs [mergeClassAndInstanceTerminals $class_inputs $class_outputs \
                  $instance_inputs $instance_outputs $nodeInstanceName in]
  # set str "applyTerminalInheritance: nodeInstanceName $nodeInstanceName"
  # puts stderr "$str instanceLabel $instanceLabel"
  #         if {(! [string match $instance_inputs $inputs]) && \
      #                 [string match $nodeInstanceName "SRU-MODULE"]} {
  #           puts stderr "\ninstance_inputs $instance_inputs"
  #           puts stderr "\nlocal_class_inputs $local_class_inputs"
  #           puts stderr "\nclass_inputs $class_inputs"
  #           puts stderr "\ninputs $inputs"
  #           puts stderr "\nnumInputs [expr [llength $inputs] / 2]"
  #         }
  if {! [string match $instance_inputs $inputs]} {
    # since these class changes are inherited from dependent
    # *.terms files, they do not change this class and its
    # schematic
    # puts stderr "nodeInstanceName $nodeInstanceName IN terminal inheritance modified"
  }

  set outputs [mergeClassAndInstanceTerminals $class_outputs $class_inputs \
                   $instance_outputs $instance_inputs $nodeInstanceName out]
  #         if {! [string match $instance_outputs $outputs]} {
#              puts stderr "\ninstance_outputs $instance_outputs"
#              puts stderr "\nlocal_class_outputs $local_class_outputs"
#             puts stderr "\nclass_outputs $class_outputs"
#              puts stderr "\noutputs $outputs"
#             puts stderr "\nnumOutputs [expr [llength $outputs] / 2]"
  #         }
  if {! [string match $instance_outputs $outputs]} {
    # since these class changes are inherited from dependent
    # *.terms files, they do not change this class and its
    # schematic
    # puts stderr "nodeInstanceName $nodeInstanceName OUT terminal inheritance modified"
  }
}


## expand argument name, type and value lists to handle
## structured types
## 30may00 wmt
proc expandArgNamesTypesValues { arg argType valueList expndArgListRef \
                                     expndArgTypeListRef expndValueListRef } {
  upvar $expndArgListRef expndArgList
  upvar $expndArgTypeListRef expndArgTypeList
  upvar $expndValueListRef expndValueList
  global g_NM_paletteStructureList  g_NM_terminalTypeValuesArray 

  # puts stderr "\nexpandArgNamesTypesValues: arg $arg argType $argType value $valueList"
  # strip off leading ? of param var name
  set arg [string trimleft $arg "?"]
  # check for structured types
  set subTypeList {}
  if {[lsearch -exact $g_NM_paletteStructureList $argType] >= 0} {
    # check for type => parent of children structs
    # which exist for parameterized terminal types
    if {! [structIsTerminalTypeParamP $argType]} {
      set valuesList [assoc-array $argType g_NM_terminalTypeValuesArray]
      for {set i 0} {$i < [llength $valuesList]} {incr i 2} {
        lappend subTypeList [lindex $valuesList $i]
      }
    }
  }
  if {[llength $subTypeList] > 0} {
    set i 0
    foreach subT $subTypeList {
      lappend expndArgList "${arg}.$subT"
      lappend expndArgTypeList $argType
      if {[lindex $valueList $i] != ""} {
        lappend expndValueList [lindex $valueList $i]
      }
      incr i
    }
  } else {
    set expndArgList $arg
    set expndArgTypeList $argType
    set expndValueList $valueList
  }
  # puts stderr "expandArgNamesTypesValues: expndArgList $expndArgList expndArgTypeList $expndArgTypeList expndValueList $expndValueList"
}








