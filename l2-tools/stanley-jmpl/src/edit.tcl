# $Id: edit.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## edit.tcl -- edit menu functions

## enable edit menu patterns
## not used 
# proc enableEditMenu {patterns} {
#   global g_NM_menuStem 

#   foreach p $patterns {
#     $g_NM_menuStem.edit.m entryconfigure $p -state normal
#   }
# }


## disable edit menu patterns
## not used 
# proc disableEditMenu {patterns} {
#   global g_NM_menuStem 

#   foreach p $patterns {
#     $g_NM_menuStem.edit.m entryconfigure $p -state disabled
#   }
# }


## delete a node, and its connections, if a component or module
## called from Mouse-Right menus of node objects
## 29oct99 wmt: new
proc deleteNode { nodeClassType pirNodeIndex } {
  global pirDisplay pirNode 

  set extNodeName [getExternalNodeName [assoc nodeInstanceName \
                                            pirNode($pirNodeIndex)]]
  if {[confirm "Delete `$extNodeName'"]} {
    set reportNotFoundP 0; set oldvalMustExistP 0
    arepl selectedNodes $pirNodeIndex pirDisplay $reportNotFoundP \
        $oldvalMustExistP
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
    editCut $currentCanvas.c
  }
}


## cut: remove selected items. [No clipboard support]
## 20dec95 wmt: add deleteClassInstance
## 12jan96 wmt: add nodesOnlyP 
## 01feb96 wmt: add mark_modified in place of "set pirFileInfo(modified) 1"
## 05jun96 wmt: return last destroyed window
## 29jun96 wmt: implement multiple canvases
## 23oct96 wmt: add optional arg cutModuleDescendentsP
## 16apr97 wmt: null g_NM_livingstoneDefmoduleName here, rather than
##              in initialize_graph 
proc editCut { { canvas "" } { nodesOnlyP 0 } { widgetsExistP 1 } \
    { cutModuleDescendentsP 1 } } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge pirFileInfo
  global g_NM_processingNodeGroupP g_NM_currentCanvas
  global g_NM_rootInstanceName g_NM_canvasGroupNodeDeleteP 
  global g_NM_currentNodeGroup g_NM_canvasRedrawP
  global g_NM_livingstoneDefmoduleName

  if {[string match $canvas ""]} {
    # called from Edit->Delete menu
    set canvas [getCanvasRootInfo g_NM_currentCanvas] 
    append canvas ".c"
  }
  set reportNotFoundP 0
  nodeInDeselect
  nodeOutDeselect
  # puts "editCut selectedNodes [assoc selectedNodes pirDisplay]"
  foreach pirNodeIndex [assoc selectedNodes pirDisplay] {
    set typeAndNameList [getNodeClassTypeAndName pirNode($pirNodeIndex)]
    set nodeClassType [lindex $typeAndNameList 0]
    if {[string match $nodeClassType "module"] || \
            [string match $nodeClassType "component"]} {
      if {$cutModuleDescendentsP} {
        editCutModule $pirNodeIndex $nodesOnlyP $widgetsExistP
      } else {
        cutAndDeleteNode $pirNodeIndex $nodesOnlyP $widgetsExistP
      }
    } elseif {[string match $nodeClassType "mode"]} {
      cutAndDeleteNode $pirNodeIndex $nodesOnlyP $widgetsExistP 
    } elseif {[string match $nodeClassType "terminal"] || \
                  [string match $nodeClassType "attribute"]} {
      if {! $g_NM_canvasRedrawP} {
        set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
        if {[string match $g_NM_rootInstanceName \
            [getCanvasRootInfo g_NM_currentNodeGroup]]} {
          modifyDefmoduleTerminalsAttributesList $pirNodeIndex lremove

          cutAndDeleteNode $pirNodeIndex $nodesOnlyP $widgetsExistP 
        } else {
          set dialogList [list tk_dialog .d "ERROR" "$nodeClassType instance
          $nodeInstanceName
          cannot be deleted by itself.
          Delete its parent, instead." error \
              0 {DISMISS}]
          eval $dialogList
          deselectNode $pirNodeIndex [theNodeWindowPath $pirNodeIndex]
        }
      } else {
        cutAndDeleteNode $pirNodeIndex $nodesOnlyP $widgetsExistP 
      }
    } else {
      puts stderr "editCut: nodeClassType $nodeClassType not handled"
      error "editCut"
    }
  }
  adel selectedNodes pirDisplay
  set g_NM_canvasGroupNodeDeleteP 0

  # selectedEdges not used anymore
#   if {! $nodesOnlyP} {
#     foreach pirEdgeIndex [assoc selectedEdges pirDisplay $reportNotFoundP] {
#       cutEdge $canvas $pirEdgeIndex
#     }
#     adel selectedEdges pirDisplay $reportNotFoundP
#   }

  if {[winfo exists $canvas]} {
    $canvas delete wire
  }
  disableSelectionMenus
  if {[llength $pirNodes]} {
    if {! $g_NM_processingNodeGroupP} {
      mark_scm_modified
    }
  } else {
    mark_scm_unmodified
  }
  if {[llength $pirNodes] == 0} {
    set reinit 1
    initialize_graph $reinit
  }
  standardMouseClickMsg
}  


## recursively descend from defmodule node to all descendents,
## removing them all
## 03jul96 wmt: new
## 12sep96 wmt: when deleting a canvas, destroy its window
proc editCutModule { pirNodeIndex nodesOnlyP widgetsExistP } {
  global pirNode g_NM_nodeGroupToInstances g_NM_canvasList

  set reportNotFoundP 0
  set nodeState  [assoc nodeState pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  if {(! [string match $nodeState "NIL"]) && \
      (! [string match $nodeState "parent-link"]) && \
          (! [string match $nodeClassType "component"])} {
    set str "editCutModule: [assoc nodeInstanceName pirNode($pirNodeIndex)]" 
    puts stderr "$str is not a defmodule or a component -- quit editCutModule"
    return
  }  
  # get next generation decendents
  set moduleGroupName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set moduleGroupNameCanvas [getTclPathNodeName $moduleGroupName]
  set childCanvasParent ".master.canvas.$moduleGroupNameCanvas"
  set childCanvas "${childCanvasParent}.c"
  # puts stderr "editCutModule: childCanvas $childCanvas pirNodeIndex $pirNodeIndex nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]"
  set childAlist [assoc-array $moduleGroupName g_NM_nodeGroupToInstances \
      $reportNotFoundP]
  # puts stderr "editCutModule: childAlist $childAlist"
  for {set i 0} {$i < [llength $childAlist]} {incr i 2} {
    set childNodeName [lindex $childAlist $i]
    set childPirNodeIndex [lindex $childAlist [expr {1 + $i}]]
    set typeAndNameList [getNodeClassTypeAndName pirNode($childPirNodeIndex)]
    set nodeClassType [lindex $typeAndNameList 0]
    set nodeState [assoc nodeState pirNode($childPirNodeIndex)]
    # set str "editCutModule: childNodeName $childNodeName childPirNodeIndex"
    # set str "$str $childPirNodeIndex nodeClassType $nodeClassType"
    # puts stderr "$str nodeState $nodeState childCanvas $childCanvas"
    if {([string match $nodeClassType "module"] && \
             [string match $nodeState "NIL"]) || \
            [string match $nodeClassType "component"]} {
      editCutModule $childPirNodeIndex $nodesOnlyP $widgetsExistP
    } else {
      # cut parent node
      cutAndDeleteNode $childPirNodeIndex $nodesOnlyP $widgetsExistP 
    }
  }
  # cut the module itself
  if {[string match [assoc-array $moduleGroupName g_NM_nodeGroupToInstances \
      $reportNotFoundP] ""]} {
    cutAndDeleteNode $pirNodeIndex $nodesOnlyP $widgetsExistP
    if {[lsearch -exact $g_NM_canvasList $childCanvasParent] >= 0} {
      lremove g_NM_canvasList $childCanvasParent
      destroy $childCanvasParent
      if {[llength $childAlist] > 0} {
        set formSub $childAlist 
        set childAlist $formSub
        # puts stderr "editCutModule: deleted canvas $childCanvas with members $childAlist"
      }
    }
  } else {
    puts stderr "editCutModule: all members of $moduleGroupName are not removed\!"
  }
}


## remove node data structures
## 08jul96 wmt: new
## 07may97 wmt: use getCanvasFromWindow, since canvas attribute is gone
proc cutAndDeleteNode { pirNodeIndex nodesOnlyP widgetsExistP } {
  global pirNode

  set canvas [getCanvasFromWindow [assoc window pirNode($pirNodeIndex)]]
  # puts stderr "cutAndDeleteNode: canvas $canvas pirNodeIndex $pirNodeIndex"
  deleteClassInstance $canvas [assoc nodeClassName pirNode($pirNodeIndex)] \
      [assoc nodeInstanceName pirNode($pirNodeIndex)] \
      [assoc window pirNode($pirNodeIndex)]
  
  cutNode $canvas $pirNodeIndex $nodesOnlyP $widgetsExistP
}


## 20dec95 wmt: new
##              ask user for component label and description
## 30jan96 wmt: attach dialog to ., so it cannot get "lost"
## 09feb96 wmt: allow numbers in instance name
## 12may96 wmt: allow editing of already existing instances
## 14nov96 wmt: add sticky instance name
proc askClassInstance { classType className classArgs classArgsTypes caller \
                            { instanceNameInternal "" } { classArgsValues {} } \
                            { instanceLabel "" } } {
  global g_NM_livingstoneDefmoduleNameVar
  global g_NM_livingstoneDefcomponentNameVar g_NM_classDefType
  global g_NM_rootInstanceName g_NM_currentNodeGroup
  global g_NM_instanceToNode pirNode g_NM_currentCanvas
  global g_NM_nodeTypeRootWindow pirNode g_NM_schematicMode
  global g_NM_paletteStructureList g_NM_terminalTypeValuesArray
  global g_NM_paletteDefvalueList g_NM_vmplTestModeP
  global g_NM_instantiateTestModuleP g_NM_readableJavaTokenOrQRegexp

  set state normal; set operation Instantiate; set reportNotFoundP 0
  set nameState normal; set labelState normal
  set initP 0; set cancelState normal
  if {! [string match $instanceNameInternal ""]} {
    set operation Edit
  }
  if {$g_NM_vmplTestModeP} {
    set nameState disabled; set labelState disabled
    if {! $g_NM_instantiateTestModuleP} {
      set state disabled; set operation View
    }
  } elseif {(! [string match $g_NM_rootInstanceName \
                    [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
                [string match $g_NM_schematicMode "operational"] || \
                [componentModuleDefReadOnlyP]} {
    set state disabled; set operation View
    set nameState disabled; set labelState disabled 
    enableViewDialogDeletion
  }
  if {[string match $instanceNameInternal ""]} {
    set pirNodeIndex 0
    set instanceLabelExternal ""
  } else {
    if {[string match $caller "instantiateDefmoduleFromIscm"]} {
      # node does not yet exist -- handles mismatch of classArgs & classArgsValues 
      set pirNodeIndex 0
      set instanceLabelExternal $instanceLabel
      if {$g_NM_instantiateTestModuleP} {
        set cancelState disabled
      }
    } else {
      set pirNodeIndex [assoc-array $instanceNameInternal g_NM_instanceToNode]
      # reportNotFoundP 0 for backward compatibility
      set instanceLabelExternal [assoc instanceLabel pirNode($pirNodeIndex) \
                                     $reportNotFoundP]
      set classArgsValues [assoc argsValues pirNode($pirNodeIndex)]
    }
  }
  set dialogW $g_NM_nodeTypeRootWindow.askClassInstance$pirNodeIndex
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog 
  set instanceNameExternal [getExternalNodeName $instanceNameInternal]
  wm title $dialogW $operation
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  if {[string match $g_NM_classDefType module]} {
    set nameVar $g_NM_livingstoneDefmoduleNameVar
  } elseif {[string match $g_NM_classDefType component]} {
    set nameVar $g_NM_livingstoneDefcomponentNameVar
  } else {
    set nameVar nil
  }

  $dialogW config -bg $bgcolor

  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command [list classInstanceUpdate $dialogW $pirNodeIndex \
                    $className $classArgs $classArgsTypes $operation \
                    $instanceNameInternal \
                    $instanceLabelExternal $classArgsValues $caller] \
                    -state $state
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP" -state $cancelState
  $dialogW.buttons.cancel configure -takefocus 0

  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set text "[capitalizeWord $classType]: $className"
  label $dialogW.title -text $text -relief flat -anchor w
  $dialogW.title configure -takefocus 0
  label $dialogW.spacer -text "" -relief flat
  $dialogW.spacer configure -takefocus 0
  pack $dialogW.title $dialogW.spacer -side top -fill both

  set widget $dialogW.fName
  mkEntryWidget $widget "" "name" $instanceNameExternal $nameState
  balloonhelp $widget.fentry.entry -side right $g_NM_readableJavaTokenOrQRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;\n <shift-tab> to prev"

  set widget $dialogW.fLabel
  mkEntryWidget $widget "" " Label" $instanceLabelExternal $labelState
  if {[llength $classArgs] > 0} {
    balloonhelp $widget.pad.left -side right "<tab> to next field;\n <shift-tab> to prev"
  }

  set n 1
  foreach arg $classArgs argType $classArgsTypes valueList $classArgsValues {
    # puts stderr "askClassInstance: arg $arg argType $argType valueList $valueList"
    set widget $dialogW.fArg$n
    # strip off leading ? of param var name
    set arg [string trimleft $arg "?"]
    # check for structured types
    set subTypeList {}
    if {[lsearch -exact $g_NM_paletteStructureList $argType] >= 0} {
      # check for type => parent of children structs
      # which exist for parameterized terminal types
      if {[structIsTerminalTypeParamP $argType]} {
        set valuesList [getParameterizedTerminalTypes $argType]
      } else {
        set valuesList [assoc-array $argType g_NM_terminalTypeValuesArray]
        for {set i 0} {$i < [llength $valuesList]} {incr i 2} {
          lappend subTypeList [lindex $valuesList $i]
        }
      }
    }
    set expndArgList {}; set expndArgTypeList {}; set expndValueList {}
    set expndLabelList {}
    if {[llength $subTypeList] > 0} {
      set i 0
      foreach subT $subTypeList {
        lappend expndArgList "${arg}.$subT"
        lappend expndArgTypeList $argType
        lappend expndValueList [lindex $valueList $i]
        lappend expndLabelList ".$subT"
        incr i
      }
    } else {
      set expndArgList $arg
      set expndArgTypeList $argType
      set expndValueList $valueList
    }
    set m 1
    foreach expndArg $expndArgList expndArgType $expndArgTypeList value $expndValueList {
      if {$expndArg == ""} {
        # excess values - discard them
        continue
      }
      set expndWidget "${widget}_$m"
      set widgeLabel "$expndArg ($expndArgType[lindex $expndLabelList [expr {$m - 1}]])"
      mkEntryWidget $expndWidget "" $widgeLabel $value $state
      balloonhelp $expndWidget.fentry.entry -side right $g_NM_readableJavaTokenOrQRegexp
      if {$n < [llength $classArgs]} {
        balloonhelp $expndWidget.pad.left -side right \
            "<tab> to next field;\n <shift-tab> to prev"
      }
      # balloon help for defvalues types, but not defmodule class types
      if {[structIsTerminalTypeParamP $expndArgType]} {
        set valuesList [getParameterizedTerminalTypes $expndArgType]
      } else {
        set valuesList [assoc-array $expndArgType g_NM_terminalTypeValuesArray \
                            $reportNotFoundP]
      }
      if {$valuesList != ""} {
        if {[lsearch -exact $g_NM_paletteStructureList $expndArgType] >= 0} {
          if {[llength $subTypeList] > 0} {
            set valuesList [lindex $valuesList [expr {2 * ($m - 1) + 1}]]
          }
          balloonhelp $expndWidget.label.descrp -side right \
              "values: $valuesList"
        } elseif {[lsearch -exact $g_NM_paletteDefvalueList $expndArgType] >= 0} {
           balloonhelp $expndWidget.label.descrp -side right \
               "values: [multiLineList $expndArgType $valuesList values:]"
        }
      }
      incr m
    }
    incr n
  }

  focus $dialogW.fName.fentry.entry
  keepDialogOnScreen $dialogW 

  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    tkwait window $dialogW
  }
}


## process  class name entry
## 17dec95 wmt: new
## 22sep96 wmt: special handling for imbedded blanks in nodeInstanceName
## 14nov96 wmt: add sticky instance name
## 03may97 wmt: add ? values to g_NM_livingstoneDefmoduleArgList
## 17oct97 wmt: add operation arg to allow for editing of instances
proc classInstanceUpdate { dialogW pirNodeIndex className classArgs classArgsTypes \
                               operation instanceNameInternal instanceLabelExternal \
                               classArgsValues caller } {
  global g_NM_mkformNodeCompleteP g_NM_livingstoneDefmoduleName
  global g_NM_classInstance pirNode
  global g_NM_livingstoneDefmoduleNameVar g_NM_classDefType
  global g_NM_canvasRedrawP pirDisplay g_NM_processingNodeGroupP
  global g_NM_paletteDefvalueList g_NM_terminalTypeValuesArray
  global g_NM_paletteStructureList 
  global g_NM_testModuleArgsValues g_NM_vmplTestModeP 

  set reportNotFoundP 0; set oldvalMustExistP 0
  # disable selectEdge events which are called when rename is done
  set g_NM_processingNodeGroupP 1 
  set newInstanceNameExternal [$dialogW.fName.fentry.entry get]
  set newInstanceNameExternal [string trim $newInstanceNameExternal " "]
  # puts "classInstanceUpdate newInstanceNameExternal `$newInstanceNameExternal'"
  if {! [entryValueErrorCheck "Name" "(javaToken_or_?javaToken)" \
             $newInstanceNameExternal]} {
    return
  }
  if {[string match $newInstanceNameExternal ""]} {
    set dialogList [list tk_dialog .d "ERROR" "Name not entered" error \
        0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[checkForReservedNames $newInstanceNameExternal]} {
    return
  }

  set newInstanceNameInternal [getInternalNodeName $newInstanceNameExternal]
  # check that this  class, node label is not already in use
  set outputMsgP 0
  # puts stderr "classInstanceUpdate: instanceNameInternal $instanceNameInternal"
  # puts stderr "classInstanceUpdate: newInstanceNameInternal $newInstanceNameInternal"
  # puts stderr "     operation $operation"
  if {([string match $operation Instantiate] || \
          ([string match $operation Edit] && \
               (! [string match $instanceNameInternal $newInstanceNameInternal]))) && \
          [checkClassInstance $className $newInstanceNameInternal $outputMsgP]} {
    return
  }
  set editChangeP 0
  if {[string match $operation Edit] && \
          (! [string match $instanceNameInternal $newInstanceNameInternal])} {
    set editChangeP 1
  }

  # user is now responsible for specifying parameter vars in Edit->Header->Name, Variables,

  set newInstanceLabelExternal [$dialogW.fLabel.fentry.entry get]
  set newInstanceLabelExternal [string trim $newInstanceLabelExternal " "]
  # no input checking
  # puts "classInstanceUpdate newInstanceLabelExternal `$newInstanceLabelExternal'"
  # puts "classInstanceUpdate instanceLabelExternal `$instanceLabelExternal'"
  if {[string match $operation Instantiate] || \
          ([string match $operation Edit] && \
               (! [string match $instanceLabelExternal \
                       $newInstanceLabelExternal]))} {
    # do this to force change in mode label and Mouse-R operation menu
    set editChangeP 1
  }

  set nodeDescription ""
  # set nodeDescription [$dialogW.fDescriptionentry get]
  # ## puts "classInstanceUpdate nodeDescription 
  # ##    $nodeDescription"
  # if {! [entryValueErrorCheck description "(all_characters)" $nodeDescription]} {
  #   return
  # }
  set n 1; set argValueListofLists {}
  foreach arg $classArgs argType $classArgsTypes oldArgValue $classArgsValues {
    # check for structured types
    set subTypeList {}
    if {[lsearch -exact $g_NM_paletteStructureList $argType] >= 0} {
      set valuesList [assoc-array $argType g_NM_terminalTypeValuesArray]
      # check for type => parent of children structs
      # which exist for parameterized terminal types
      if {! [structIsTerminalTypeParamP $argType]} {
        for {set i 0} {$i < [llength $valuesList]} {incr i 2} {
          lappend subTypeList [lindex $valuesList $i]
        }
      }
    }
    set expndArgList {}; set expndArgTypeList {}
    if {[llength $subTypeList] > 0} {
      foreach subT $subTypeList {
        lappend expndArgList "${arg}.$subT"
        lappend expndArgTypeList $argType
      }
    } else {
      set expndArgList $arg
      set expndArgTypeList $argType 
    }
    set m 1; set argValueList {}
    foreach expndArg $expndArgList expndArgType $expndArgTypeList {
      if {$expndArg == ""} {
        # excess values - discard them
        continue
      }
      set argValue [$dialogW.fArg${n}_$m.fentry.entry get]
      set argValue [string trim $argValue " "]
      # strip off leading ? of param var name
      set arg [string trimleft $arg "?"] 
      if {[string match $argValue ""]} {
        set dialogList [list tk_dialog .d "ERROR" "`$arg ($argType)' not entered" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      }
      if {! [entryValueErrorCheck $arg "(javaToken_or_?javaToken)" $argValue]} {
        return
      }

      if {([lsearch -exact $g_NM_paletteDefvalueList $argType] >= 0) || \
              ([lsearch -exact $g_NM_paletteStructureList $argType] >= 0)} {
        if {[structIsTerminalTypeParamP $argType]} {
          set valuesList [getParameterizedTerminalTypes $argType]
        } else {
          set valuesList [assoc-array $argType g_NM_terminalTypeValuesArray]
        }
        if {[llength $subTypeList] > 0} {
          # structured types, e.g. sign {negative zero positive} rel {low nominal high}
          set valuesList [lindex $valuesList [expr {2 * ($m - 1) + 1}]]
        }
        if {[lsearch -exact $valuesList $argValue] == -1} {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$argValue' not a member of\n$valuesList" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      }
      # do not check arg values for duplicate instances, since they will not
      # be instantiated
      #     if {([string match $operation Instantiate] || \
          #              ([string match $operation Edit] && \
          #                   (! [string match $oldArgValue \
          #                           $argValue]))) && \
          #             [checkClassInstance $className $safeArgValueUpper $outputMsgP]} {
      #       return
      #     }
      if {[string match $operation Edit] && \
              (! [string match $oldArgValue $argValue])} {
        set editChangeP 1
      }

      # puts "classInstanceUpdate after argValue $argValue"
      lappend argValueList $argValue
      incr m
    }
    if {$argValueList != ""} {
      lappend argValueListofLists $argValueList
      incr n
    }
  }
  # puts "classInstanceUpdate argValueListofLists $argValueListofLists"

  # now that all validity checks are done
  set g_NM_classInstance [list $newInstanceNameInternal $newInstanceLabelExternal \
                              $nodeDescription $argValueListofLists]
  if {$g_NM_vmplTestModeP} {
    set g_NM_testModuleArgsValues $argValueListofLists
  }

  if {[string match $caller "instantiateDefmoduleFromIscm"]} {
      # node does not yet exist -- handles mismatch of classArgs & classArgsValues
    set g_NM_mkformNodeCompleteP 1
    destroy $dialogW
    return
  }
  if {[string match $operation Instantiate] || \
          ([string match $operation Edit] && $editChangeP)} {
    set g_NM_mkformNodeCompleteP 1
  }
  if {[string match $operation Edit] && $editChangeP} {
    ## delete old instance 
    set nodesOnlyP 1; set g_NM_canvasRedrawP 1
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
    arepl selectedNodes $pirNodeIndex pirDisplay $reportNotFoundP $oldvalMustExistP

    editCut $currentCanvas.c $nodesOnlyP
  }
  if {[string match $operation Edit] && (! $editChangeP) && \
          (! [string match $instanceLabelExternal $newInstanceLabelExternal])} {
    # editChangeP is not set for changing instance label, i.e.
    # a new node is not created (if it is, then duplicate instances occur)
    # make changes to existing node here, in case there are no
    # other changes in this dialog which set editChangeP to 1
    # set flags for backward compatibility
    mark_scm_modified
    set text $newInstanceLabelExternal
    if {[string match $text ""]} {
      set text $newInstanceNameExternal
    }
    set window [assoc window pirNode($pirNodeIndex)]
    $window.lab.label configure -text " $text "
    # reset icon label window
    set labelWindow [assoc labelWindow pirNode($pirNodeIndex) $reportNotFoundP]
    if {$labelWindow != ""} {
      $labelWindow.label configure -text $text 
    }
    update; # tricky: need to update display to pick up the new window coords

    # redraw any links due to size of node changing
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas].c
    updateEdgeLocations $currentCanvas $pirNodeIndex
    update
    set g_NM_processingNodeGroupP 0; # re-enable selectEdge events 
  }
  destroy $dialogW
}


## create a text widget for user documentation and component model code
## text has default value to handle "" doc in attribute class def
## 28may97 wmt: new
## 26jun97 wmt: add optional arg pirEdgeIndex for nodeType = edge
proc createTextWidget { dialogId dialogW nodeType attributeName state \
                            { pirEdgeIndex 0 } } {
  global g_NM_currentCanvas g_NM_nodeTypeRootWindow
  
  set heightBorder 5; set textHeight 11
  if {[string match $nodeType component] || \
          [string match $nodeType module]} {
    set textHeight 19
  }
  set windowHeight [expr {1 + $textHeight}]
  set bgColor [preferred StanleyDialogEntryBackgroundColor]

  # puts stderr "createTextWidget: -font [preferred StanleyDialogEntryFont]"
  set w $dialogW.text 
  frame $w -bg $bgColor
#   frame $w.bottom
#   -xscrollcommand "$w.bottom.sx set"
  text $w.t -setgrid true -height $textHeight -yscrollcommand "$w.sy set" \
      -wrap char -font [preferred StanleyDialogEntryFont]
  scrollbar $w.sy -orient vertical -command "$w.t yview" -relief sunken 
#   scrollbar $w.bottom.sx -orient horizontal -command "$w.t xview" -relief sunken 
#   pack $w.bottom.sx -side left -fill x -expand 1
#   pack $w.bottom -side bottom -fill x
  pack $w.sy -side right -fill y
  pack $w.t -side left -fill both -expand 1
  pack $w -side top -fill both -expand 1

#   $w.bottom.sx configure -takefocus 0
  $w.sy configure -takefocus 0

  set canvasHeight [expr {$windowHeight - $heightBorder}] 
  # characters
  $w.t config -width 80
  $w.t config -height $canvasHeight

  if {! [string match $nodeType nil]} {
    set attributeText [getTextWidgetText $dialogId $nodeType \
                           $attributeName $pirEdgeIndex]
    set attributeText [string trimleft $attributeText "\{"] 
    set attributeText [string trimright $attributeText "\}"]
    set attributeText [string trimright $attributeText "\n"]
    $w.t insert end $attributeText
  }
  $w.t configure -state $state
}


## save text entered in text widget
## 28may97 wmt: new
proc saveTextWidget { dialogId textPath nodeType attributeName \
                          attributeType { pirEdgeIndex 0 } { state normal } } {

  # puts stderr "saveTextWidget: nodeType $nodeType attributeName $attributeName"
  set errorP 0; set textEntered ""
  set textEntered [$textPath.t get 1.0 end]
  # puts stderr "saveTextWidget: B textEntered `$textEntered'"
  # trim \n put on by get
  set textEntered [string trimright $textEntered "\n"]
  # trim off indented \n maybe put on by user
  set textEntered [string trim $textEntered " "]
  set textEntered [string trimright $textEntered "\n"]
  # puts stderr "saveTextWidget: A textEntered `$textEntered'"
  if {! [entryValueErrorCheck [capitalizeWord $attributeName] \
             $attributeType $textEntered]} {
    set errorP 1 
  }
  if {! $errorP} {
    setTextWidgetText $dialogId $nodeType $attributeName \
        $textEntered $pirEdgeIndex $state
  }
  return $errorP 
}

## save text widget input in appropriate global variable
##      e.g. dialogId = 3
## write lisp widget input in appropriate file
##      e.g. dialogId = attributeFactsInput_3
## 18jul97 wmt: new
proc setTextWidgetText { dialogId nodeType attributeName textEntered \
                             pirEdgeIndex state } {
  global g_NM_terminalDocInput pirEdge g_NM_attributeFactsInput
  global g_NM_modeDocInput g_NM_modeTransitionDocInput
  global g_NM_modeTransitionPreconditionInput g_NM_modeModelInput
  global g_NM_structureFormInput g_NM_structureDocInput
  global g_NM_componentDocInput g_NM_componentBackDocInput
  global g_NM_componentBackModelInput g_NM_componentInitiallyInput 
  global g_NM_moduleDocInput g_NM_moduleFactsInput g_NM_edgeDocInput

  set foundP 0
  if {([string match $nodeType terminal] || \
           [string match $nodeType attribute]) && \
          [string match $attributeName documentation]} {
    global g_NM_terminalDocInput_$dialogId; set foundP 1
    set g_NM_terminalDocInput_$dialogId $textEntered
  } elseif {[string match $nodeType attribute] && \
                [string match $attributeName facts]} {
    global g_NM_attributeFactsInput_$dialogId; set foundP 1
    set g_NM_attributeFactsInput_$dialogId $textEntered 
  } elseif {[string match $nodeType edge] && \
                [string match $attributeName documentation]} {
    set textEntered [string trimleft $textEntered ";"]
    global g_NM_edgeDocInput_$dialogId; set foundP 1
    set g_NM_edgeDocInput_$dialogId $textEntered
    if {$pirEdgeIndex != 0} {
      arepl documentation $textEntered pirEdge($pirEdgeIndex)
      mark_scm_modified
    }
  } elseif {[string match $nodeType mode]} {
    if {[string match $attributeName documentation]} {
      global g_NM_modeDocInput_$dialogId; set foundP 1
      set g_NM_modeDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName model]} {
      global g_NM_modeModelInput_$dialogId; set foundP 1
      set g_NM_modeModelInput_$dialogId $textEntered 
    }
  } elseif {[string match $nodeType transition]} {
    if {[string match $attributeName documentation]} {
      global g_NM_modeTransitionDocInput_$dialogId; set foundP 1
      set g_NM_modeTransitionDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName precondition]} {
      global g_NM_modeTransitionPreconditionInput_$dialogId; set foundP 1
      set g_NM_modeTransitionPreconditionInput_$dialogId $textEntered
    }
  } elseif {[string match $nodeType module]} {
    if {[string match $attributeName documentation]} {
      global g_NM_moduleDocInput_$dialogId; set foundP 1
      set g_NM_moduleDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName facts]} {
      global g_NM_moduleFactsInput_$dialogId; set foundP 1
      set g_NM_moduleFactsInput_$dialogId $textEntered 
    }      
  } elseif {[string match $nodeType component]} {
    if {[string match $attributeName documentation]} {
      global g_NM_componentDocInput_$dialogId; set foundP 1
      set g_NM_componentDocInput_$dialogId $textEntered 
    } elseif {[string match $attributeName background_documentation]} {
      global g_NM_componentBackDocInput_$dialogId; set foundP 1
      set g_NM_componentBackDocInput_$dialogId $textEntered 
    } elseif {[string match $attributeName background_model]} {
      global  g_NM_componentBackModelInput_$dialogId; set foundP 1
      set g_NM_componentBackModelInput_$dialogId $textEntered
    } elseif {[string match $attributeName initially]} {
      global g_NM_componentInitiallyInput_$dialogId; set foundP 1
      set g_NM_componentInitiallyInput_$dialogId $textEntered 
    }
  } elseif {[string match $nodeType relation]} {
    if {[string match $attributeName documentation]} {
      global g_NM_relationDocInput_$dialogId; set foundP 1
      set g_NM_relationDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName form]} {
      global g_NM_relationFormInput_$dialogId; set foundP 1
      set g_NM_relationFormInput_$dialogId $textEntered
    }
  } elseif {[string match $nodeType structure]} {
    if {[string match $attributeName documentation]} {
      global g_NM_structureDocInput_$dialogId; set foundP 1
      set g_NM_structureDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName form]} {
      global g_NM_structureFormInput_$dialogId; set foundP 1
      set g_NM_structureFormInput_$dialogId $textEntered
    }
  } elseif {[string match $nodeType abstraction]} {
    if {[string match $attributeName documentation]} {
      global g_NM_abstractionDocInput_$dialogId; set foundP 1
      set g_NM_abstractionDocInput_$dialogId $textEntered
    } elseif {[string match $attributeName form]} {
      global g_NM_abstractionFormInput_$dialogId; set foundP 1
      set g_NM_abstractionFormInput_$dialogId $textEntered
    }
  } elseif {[string match $nodeType value] && \
                [string match $attributeName documentation]} {
    global g_NM_valueDocInput_$dialogId; set foundP 1
    set g_NM_valueDocInput_$dialogId $textEntered
  }
  if {! $foundP} {
    set str "setTextWidgetText: nodeType $nodeType attributeName"
    puts stderr "$str $attributeName not handled"
  }
}


## get text widget input from appropriate global variable
##      e.g. dialogId = 3
## 18jul97 wmt: new
## 08oct97 wmt: lisp code is now in auto-saved files
## 05nov97 wmt: lisp code is now handled by emacs text widget
proc getTextWidgetText { dialogId nodeType attributeName pirEdgeIndex } {
  global g_NM_terminalDocInput pirEdge g_NM_attributeFactsInput
  global g_NM_modeDocInput g_NM_modeTransitionDocInput
  global g_NM_modeTransitionPreconditionInput g_NM_modeModelInput
  global g_NM_structureFormInput g_NM_structureDocInput g_NM_edgeDocInput
  global g_NM_componentDocInput g_NM_componentBackDocInput
  global g_NM_componentBackModelInput g_NM_componentInitiallyInput 
  global g_NM_moduleDocInput g_NM_moduleFactsInput g_NM_valueDocInput
  global g_NM_relationFormInput g_NM_relationDocInput 

  set foundP 0
  if {([string match $nodeType terminal] || \
           [string match $nodeType attribute]) && \
          [string match $attributeName documentation]} {
    global g_NM_terminalDocInput_$dialogId; set foundP 1
    return [subst $[subst g_NM_terminalDocInput_$dialogId]]
  } elseif {[string match $nodeType attribute] && \
                [string match $attributeName facts]} {
    global g_NM_attributeFactsInput_$dialogId; set foundP 1
    return [subst $[subst g_NM_attributeFactsInput_$dialogId]]
  } elseif {[string match $nodeType edge] && \
                [string match $attributeName documentation]} {
    global g_NM_edgeDocInput_$dialogId; set foundP 1
    return [subst $[subst g_NM_edgeDocInput_$dialogId]]
  } elseif {[string match $nodeType mode]} {
    if {[string match $attributeName documentation]} {
      global g_NM_modeDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_modeDocInput_$dialogId]]
    } elseif {[string match $attributeName model]} {
      global g_NM_modeModelInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_modeModelInput_$dialogId]]
    }
  } elseif {[string match $nodeType transition]} {
    if {[string match $attributeName documentation]} {
      global g_NM_modeTransitionDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_modeTransitionDocInput_$dialogId]]
    } elseif {[string match $attributeName precondition]} {
      global g_NM_modeTransitionPreconditionInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_modeTransitionPreconditionInput_$dialogId]]
    }
  } elseif {[string match $nodeType module]} {
    if {[string match $attributeName documentation]} {
      global g_NM_moduleDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_moduleDocInput_$dialogId]]
    } elseif {[string match $attributeName facts]} {
      global g_NM_moduleFactsInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_moduleFactsInput_$dialogId]]
    }      
  } elseif {[string match $nodeType component]} {
    if {[string match $attributeName documentation]} {
      global g_NM_componentDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_componentDocInput_$dialogId]]
    } elseif {[string match $attributeName background_documentation]} {
      global g_NM_componentBackDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_componentBackDocInput_$dialogId]]
    } elseif {[string match $attributeName background_model]} {
      global  g_NM_componentBackModelInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_componentBackModelInput_$dialogId]]
    } elseif {[string match $attributeName initially]} {
      global g_NM_componentInitiallyInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_componentInitiallyInput_$dialogId]]
    }
  } elseif {[string match $nodeType relation]} {
    if {[string match $attributeName documentation]} {
      global g_NM_relationDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_relationDocInput_$dialogId]]
    } elseif {[string match $attributeName form]} {
      global g_NM_relationFormInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_relationFormInput_$dialogId]]
    }
  } elseif {[string match $nodeType structure]} {
    if {[string match $attributeName documentation]} {
      global g_NM_structureDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_structureDocInput_$dialogId]]
    } elseif {[string match $attributeName form]} {
      global g_NM_structureFormInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_structureFormInput_$dialogId]]
    }
  } elseif {[string match $nodeType abstraction]} {
    if {[string match $attributeName documentation]} {
      global g_NM_abstractionDocInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_abstractionDocInput_$dialogId]]
    } elseif {[string match $attributeName form]} {
      global g_NM_abstractionFormInput_$dialogId; set foundP 1
      return [subst $[subst g_NM_abstractionFormInput_$dialogId]]
    }
  } elseif {[string match $nodeType value] && \
                [string match $attributeName documentation]} {
    global g_NM_valueDocInput_$dialogId; set foundP 1
    return [subst $[subst g_NM_valueDocInput_$dialogId]]
  }
  if {! $foundP} {
    set str "getTextWidgetText: nodeType $nodeType attributeName"
    puts stderr "$str $attributeName not handled"
  }
}


## kill text widget
## 28may97 wmt: new
proc killTextWidget { textPath } {

  grab release $textPath 
  destroy $textPath
  # slow
  # raiseStanleyWindows 
}


## rename terminal class instance
## 09jun97 wmt: new
proc renameTerminalInstance { oldName terminalNameInternal className pirNodeIndex } {
  global pirNode g_NM_canvasRedrawP g_NM_currentCanvas

  # set str "renameTerminalInstance: oldName $oldName terminalNameInternal"
  # puts stderr "$str $terminalNameInternal"
  # remove old instance name from defmodule input_terminals, etc
  modifyDefmoduleTerminalsAttributesList $pirNodeIndex lremove

  arepl nodeInstanceName $terminalNameInternal pirNode($pirNodeIndex)

  # add new instance name
  modifyDefmoduleTerminalsAttributesList $pirNodeIndex lappend

  renameClassInstance $oldName $terminalNameInternal $className $pirNodeIndex 
}


## rename class instance
## 10jul97 wmt: new
## 20feb98 wmt: add attribute to list of nodeClassTypes which have
##              their new name displayed
proc renameClassInstance { oldName terminalNameInternal className pirNodeIndex } {
  global pirNode g_NM_canvasRedrawP g_NM_currentCanvas

  set reportNotFoundP 0
  arepl nodeInstanceName $terminalNameInternal pirNode($pirNodeIndex)
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set window [assoc window pirNode($pirNodeIndex)]
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas].c
  if {([lsearch -exact [list component module mode terminal attribute] \
            $nodeClassType] >= 0) && \
          (! [string match $nodeClassName "displayState"])} {
    # update displayed node label
    if {[string match $nodeClassType mode]} {
      set text [getExternalNodeName $terminalNameInternal]
    } else {
      set pirNodeAlist $pirNode($pirNodeIndex)
      set text [getDisplayLabel pirNodeAlist labelP]
      if {[string match $nodeClassType terminal] && \
              [regexp "Declaration" $nodeClassName]} {
        # strip off unique suffix off declarations 
        set text [getTerminalLabel $terminalNameInternal]
      }
    }
    set labelWindow [assoc labelWindow pirNode($pirNodeIndex) $reportNotFoundP]
    if {$labelWindow != ""} {
      # reset icon label window
      set oldLabelWidth [font measure [preferred StanleyTerminalTypeFont] \
                             [lindex [$labelWindow.label configure -text] 4]]
      set newLabelWidth [font measure [preferred StanleyTerminalTypeFont] $text]
      set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex)]
      $labelWindow.label configure -text $text
      $currentCanvas move $labelCanvasId \
          [expr {($oldLabelWidth - $newLabelWidth) / 2}] 0
    } else {
      $window.lab.label configure -text " $text "
    }
    update; # tricky: need to update display to pick up the new window coords

    # update any links due to size of node changing
    updateEdgeLocations $currentCanvas $pirNodeIndex 
  }
  # update g_NM_instanceToNode g_NM_nodeGroupToInstances
  # g_NM_classToInstances; g_NM_canvasRedrawP prevents pirClass entry
  # from being lost if this is a single instance
  set g_NM_canvasRedrawP 1
  set canvasId [assoc canvasId pirNode($pirNodeIndex)]
  set renameP 1
  deleteClassInstance $currentCanvas $className $oldName $window $renameP  
  addClassInstance $className $terminalNameInternal $pirNodeIndex $canvasId \
      $currentCanvas $window
  set g_NM_canvasRedrawP 0
}


## ask user for abstraction type and documentation for edge
## 30may97 wmt: new
## 30mar98 wmt: added abstraction
## abtractions are special cases of structures, used to
## convert related types to each other
proc askEdgeTypeAndDoc { pirEdgeIndex { dialogW  "" } { terminalFrom "" } \
                             { terminalTo "" } { nodeFrom "" } \
                             { nodeTo "" } } {
  global pirEdge g_NM_nodeTypeRootWindow g_NM_schematicMode 
  global g_NM_rootInstanceName g_NM_currentNodeGroup
  global pirNode g_NM_terminalTypeValuesArray 
  global g_NM_paletteAbstractionList

  # puts stderr "askEdgeTypeAndDoc: pirEdgeIndex $pirEdgeIndex"
  set reportNotFoundP 0
  set state normal; set operation Edit
  if {[componentModuleDefReadOnlyP] || \
          [string match $g_NM_schematicMode "operational"] || \
          (! [string match $g_NM_rootInstanceName \
                  [getCanvasRootInfo g_NM_currentNodeGroup]])} {
    set state disabled; set operation View
    enableViewDialogDeletion
  }
  if {[string match $dialogW ""]} {
    set dialogW $g_NM_nodeTypeRootWindow.edge$pirEdgeIndex
  }
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0
  set dialogId [getDialogId $dialogW]
  global g_NM_edgeDocInput_$dialogId
  global g_NM_optMenuWidgetValue_$dialogId
  if {$pirEdgeIndex != 0} {
    set terminalFrom [assoc terminalFrom pirEdge($pirEdgeIndex)]
    set terminalTo [assoc terminalTo pirEdge($pirEdgeIndex)]
    set nodeFrom [assoc nodeFrom pirEdge($pirEdgeIndex)]
    set nodeTo [assoc nodeTo pirEdge($pirEdgeIndex)]
    set g_NM_edgeDocInput_$dialogId [assoc documentation \
                                         pirEdge($pirEdgeIndex)]
  } else {
    set g_NM_edgeDocInput_$dialogId ""
  }
  set fromTerminalName [getDisplayLabelFromTerminalForm terminalFrom]
  set fromTerminalLabel [assoc terminal_label terminalFrom $reportNotFoundP]
  set toTerminalName [getDisplayLabelFromTerminalForm terminalTo]
  set toTerminalLabel [assoc terminal_label terminalTo $reportNotFoundP]
  set terminalFromType [getTerminalType $terminalFrom]
  set terminalToType [getTerminalType $terminalTo]
  set abstractionTypeList [getAbstractionTypes $terminalFromType \
                               $terminalToType]
  if {$pirEdgeIndex != 0} {
    set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
    set expandedAbstractionType [expandAbstractionType $abstractionType \
                                     abstractionTypeList]
    # puts stderr "askEdgeTypeAndDoc: abstractionType $abstractionType "
    # puts stderr "     abstractionTypeList $abstractionTypeList "
    # puts stderr "     expandedAbstractionType $expandedAbstractionType "
    set g_NM_optMenuWidgetValue_$dialogId $expandedAbstractionType 
  } else {
    set g_NM_optMenuWidgetValue_$dialogId ""
  }
  set nodeFromClassName [assoc nodeClassName pirNode($nodeFrom)]
  set nodeToClassName [assoc nodeClassName pirNode($nodeTo)]
  if {! [string match $fromTerminalLabel ""]} {
    set nodeArgsList $pirNode($nodeFrom)
    set instanceLabel [getDisplayLabel nodeArgsList labelP]
    set nodeClassType [assoc nodeClassType nodeArgsList]
    if {[lsearch -exact [list component module] $nodeClassType] >= 0} {
      set label1 "From: $instanceLabel -- $fromTerminalLabel"
    } else {
      set label1 "From: $fromTerminalLabel"
    }
  } else {
    set label1 "From: $fromTerminalName"
  }
  if {! [string match $toTerminalLabel ""]} {
    set nodeArgsList $pirNode($nodeTo)
    set instanceLabel [getDisplayLabel nodeArgsList labelP]
    set nodeClassType [assoc nodeClassType nodeArgsList]
    if {[lsearch -exact [list component module] $nodeClassType] >= 0} {
      set label2 "To:     $instanceLabel -- $toTerminalLabel"
    } else {
      set label2 "To:     $toTerminalLabel"
    }
  } else {
    set label2 "To:     $toTerminalName"
  }
  set nodeType edge
  set attributeName documentation
  set attributeType "(all_characters)"

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$operation Connection"
  ## create icon for icon mgr
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  $dialogW config -bg $bgcolor

  set command "edgeTypeAndDocUpdate $dialogW $nodeType"
  append command " $attributeName $attributeType $pirEdgeIndex"
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -relief raised -text "OK" -state $state \
      -highlightthickness 0 -width 5 -command $command
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -relief raised -text "CANCEL" \
      -highlightthickness 0 -width 5 \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  frame $dialogW.label -bg $bgcolor
  # for some reason option database setting of wrapLength 0 does not work here
  label $dialogW.label.lab1 -text $label1 -anchor w -wraplength 0 
  label $dialogW.label.lab2 -text $label2 -anchor w -wraplength 0 
  label $dialogW.label.lab3 -text "" -anchor w 
  pack $dialogW.label.lab1 $dialogW.label.lab2 $dialogW.label.lab3 \
      -side top -anchor w 
  pack $dialogW.label -side top -fill x

  set string "type:   $terminalFromType\nvalues: "
  set values [assoc-array $terminalFromType g_NM_terminalTypeValuesArray]
  append string [multiLineList $terminalFromType $values values:]
  balloonhelp $dialogW.label.lab1 -side right $string 
  set string "type:   $terminalToType\nvalues: "
  set values [assoc-array $terminalToType g_NM_terminalTypeValuesArray]
  append string [multiLineList $terminalToType $values values:] 
  balloonhelp $dialogW.label.lab2 -side right $string 

  frame $dialogW.fType -background $bgcolor
  frame $dialogW.typetitle -background $bgcolor 
  label $dialogW.typetitle.title -text "Abstraction" -relief flat -anchor w
  label $dialogW.typetitle.filler -text "" -relief flat
  $dialogW.typetitle configure -takefocus 0
  $dialogW.typetitle.title configure -takefocus 0
  $dialogW.typetitle.filler configure -takefocus 0

  if {[string match [subst $[subst g_NM_optMenuWidgetValue_$dialogId]] ""]} {
    if {[llength $abstractionTypeList] > 0} {
      set g_NM_optMenuWidgetValue_$dialogId [lindex $abstractionTypeList 0]
    }
  }
  set terminalTypeP 0
  tk_alphaOptionMenuCascade $dialogW.fType.optMenuButton \
      g_NM_optMenuWidgetValue_$dialogId \
      [subst $[subst g_NM_optMenuWidgetValue_$dialogId]] \
      abstractionTypeList $state $terminalTypeP
  pack $dialogW.fType.optMenuButton -side left -fill x
  pack $dialogW.typetitle.title -side left
  pack $dialogW.typetitle.filler -side left -fill x -expand 1
  pack $dialogW.typetitle -side top -fill x
  pack $dialogW.fType -fill x

  frame $dialogW.doc1
  label $dialogW.doc1.spacer -text "" -relief flat -anchor w 
  $dialogW.doc1.spacer configure -takefocus 0
  pack $dialogW.doc1.spacer -side top -fill both
  pack $dialogW.doc1 -side top -fill x

  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both

  createTextWidget $dialogId $dialogW $nodeType $attributeName $state $pirEdgeIndex

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x

  keepDialogOnScreen $dialogW 
}


## 31mar98 wmt: new
proc edgeTypeAndDocUpdate { dialogW nodeType attributeName attributeType \
                                pirEdgeIndex } {
  global g_NM_connectP pirEdge 

  set dialogId [getDialogId $dialogW]
  global g_NM_optMenuWidgetValue_$dialogId
  set abstractionType [subst $[subst g_NM_optMenuWidgetValue_$dialogId]]
  if {[regexp "<none-applicable>" $abstractionType]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "Abstraction not selected" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {$pirEdgeIndex != 0} {
    # puts stderr "edgeTypeAndDocUpdate: pirEdgeIndex $pirEdgeIndex abstractionType $abstractionType"
    set reducedAbstractionType [reduceAbstractionType $abstractionType]
    # puts stderr "    reducedAbstractionType $reducedAbstractionType "
    arepl abstractionType $reducedAbstractionType pirEdge($pirEdgeIndex)
  } else {
    # set this for compat_test -- a new edge
    set g_NM_connectP 1
  }

  # saveTextWidget updates pirEdge($pirEdgeIndex) or if it is 0
  # updates g_NM_edgeDocInput_$dialogId
  saveTextWidget $dialogId $dialogW.text $nodeType $attributeName \
      $attributeType $pirEdgeIndex

  destroy $dialogW
}


## call edit param procs for each class type
## 03jul97 wmt: new
## 20feb98 wmt handle calls to viewClassDefParams 
proc editClassDefParams { widget paramsType } {
  global g_NM_classDefType g_NM_rootInstanceName pirNode
  global g_NM_currentNodeGroup g_NM_livingstoneDefcomponentName
  global g_NM_livingstoneDefmoduleName 

  set caller "editClassDefParams"
  if {[string match $g_NM_rootInstanceName $g_NM_currentNodeGroup]} {
    switch $g_NM_classDefType {
      component {
        if {[string match $paramsType displayState]} {
          set displayStatePirNodeIndex [getDisplayStatePirNodeIndex \
                                            [getCanvasRootInfo g_NM_currentNodeGroup]]
          if {$displayStatePirNodeIndex == 0} {
            instantiateDefinitionUpdate attribute displayState
          } else {
            askTerminalInstance attribute displayState \
                $displayStatePirNodeIndex $caller 
          }
        } else {
          if {[classDefReadOnlyP component $g_NM_livingstoneDefcomponentName]} {   
            viewClassDefParams $widget $paramsType
          } else {
            editDefcomponentParams $paramsType
          }
        }
      }
      module {
        if {[string match $paramsType displayState]} {
          set displayStatePirNodeIndex [getDisplayStatePirNodeIndex \
                                           [getCanvasRootInfo g_NM_currentNodeGroup]] 
          if {$displayStatePirNodeIndex == 0} {
            instantiateDefinitionUpdate attribute displayState
          } else {
            askTerminalInstance attribute displayState \
                $displayStatePirNodeIndex $caller 
          }
        } else {
          if {[classDefReadOnlyP module $g_NM_livingstoneDefmoduleName]} {
            viewClassDefParams $widget $paramsType
          } else {
            editDefmoduleParams $paramsType
          }
        }
      }
      default {
        error "editClassDefParams: g_NM_classDefType $g_NM_classDefType not handled"
      }
    }
  } else {

    viewClassDefParams $widget $paramsType
  }
}


## call view param procs for each class type
## 08aug97 wmt: new
proc viewClassDefParams { widget paramsType } {
  global g_NM_classDefType g_NM_currentNodeGroup
  global g_NM_instanceToNode pirNode

  set caller "viewClassDefParams"
  switch $g_NM_classDefType {
    component {
      if {[string match $paramsType displayState]} {
        set displayStatePirNodeIndex [getDisplayStatePirNodeIndex \
                                         [getCanvasRootInfo g_NM_currentNodeGroup]] 
        askTerminalInstance attribute displayState \
            $displayStatePirNodeIndex $caller 
      } else {
        askLivingstoneDefcomponentParams $paramsType $caller 
      }
    }
    module {
      if {[string match $paramsType displayState]} {
        set displayStatePirNodeIndex [getDisplayStatePirNodeIndex \
                                         [getCanvasRootInfo g_NM_currentNodeGroup]] 
        askTerminalInstance attribute displayState \
            $displayStatePirNodeIndex $caller 
      } else {
        set pirNodeIndex [assoc-array [getCanvasRootInfo g_NM_currentNodeGroup] \
                              g_NM_instanceToNode]
        set currrentClassType [assoc nodeClassType pirNode($pirNodeIndex)]
        if {[string match $currrentClassType component]} {
          askLivingstoneDefcomponentParams $paramsType $caller 
        } else {
          askLivingstoneDefmoduleParams $paramsType $caller
        }
      }
    }
    default {
      error "viewClassDefParams: g_NM_classDefType $g_NM_classDefType not handled"
    }
  }
}

## edit component and module instances
## interactiveP == 0 is for terminalMotionRelease -- wysiwyg
## terminal reordering
## 07aug97 wmt: new
proc editComponentModule { pirNodeIndex {interactiveP 1} {caller ""} } {
  global pirNode pirDisplay 
  global g_NM_currentCanvas
  global g_NM_mkformNodeCompleteP g_NM_canvasRedrawP 
  global g_NM_moduleToNode g_NM_edgesOfRedrawNode
  global pirNodes g_NM_pendingPirEdgesList g_NM_win32P 

  set reportNotFoundP 0; set canvasRootId 0
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeState [assoc nodeState pirNode($pirNodeIndex)]

  # handle parent-link modules
  if {[string match $nodeState "parent-link"]} {
    set parentInstanceName [lindex [assoc parentNodeGroupList \
                                        pirNode($pirNodeIndex)] 1]
    set parentNodeIndex [assoc-array $parentInstanceName g_NM_moduleToNode]
    set parentNodeClassName [assoc nodeClassName pirNode($parentNodeIndex)]
    set window [assoc window pirNode($pirNodeIndex)]

    set dialogList [list tk_dialogNoGrab .d "Parent Instance" \
                        "class: `$parentNodeClassName'" \
                      error 0 {DISMISS}]
    eval $dialogList
    return
  }

  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set argsValues [assoc argsValues pirNode($pirNodeIndex)]
  set x [assoc nodeX pirNode($pirNodeIndex)]
  set y [assoc nodeY pirNode($pirNodeIndex)]
  set oldWindow [assoc window pirNode($pirNodeIndex)]
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  if {$interactiveP} {
    set g_NM_edgesOfRedrawNode [list edgesFrom [assoc edgesFrom pirNode($pirNodeIndex)] \
                                    edgesTo [assoc edgesTo pirNode($pirNodeIndex)]]
  }
  # puts stderr "editComponentModule: g_NM_edgesOfRedrawNode $g_NM_edgesOfRedrawNode"
  set edgeSetListFrom [assoc edgesFrom g_NM_edgesOfRedrawNode]
  set edgeSetListTo [assoc edgesTo g_NM_edgesOfRedrawNode]

  if {$caller == "terminalMotionRelease"} {
    # remove entries for nodeInstanceName from g_NM_pendingPirEdgesList
    # since creating a new node  with canvasB1Click will duplicate them
    set currentCanvasC "${currentCanvas}.c"
    set newEntries {}
    set currentEntries [assoc-array $currentCanvasC g_NM_pendingPirEdgesList \
                            $reportNotFoundP] 
    set matchForm [getMplRegExpression $nodeInstanceName]
    foreach entry $currentEntries {
      if {(! [regexp $matchForm [assoc nodeFrom entry]]) && \
              (! [regexp $matchForm [assoc nodeTo entry]])} {
        lappend newEntries $entry
      }
    }
    if {[string match "" $currentEntries]} {
      set reportNotFoundP 0; set oldvalMustExistP 0
    } else {
      set reportNotFoundP 1; set oldvalMustExistP 1
    }
    arepl-array $currentCanvasC $newEntries g_NM_pendingPirEdgesList \
        $reportNotFoundP $oldvalMustExistP
  }

  set newPirNodeIndex [canvasB1Click $currentCanvas.c $x $y $interactiveP \
                           $nodeClassName $nodeClassType $nodeInstanceName]
  # pirNodeIndex is deleted in classInstanceUpdate
  # g_NM_canvasRedrawP is set to 1 there, as well - for interactiveP == 1
  # for interactiveP == 0 -- it is set to 1 before calling this proc

  if {$g_NM_mkformNodeCompleteP} {
    # canvasB1Click calls recursiveDefmoduleInstantiation which turns off
    # pirWarning - turn it on here
    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
    }
    set msg2 ""; set severity 1; set trimP 1
    set pirNodeAlist $pirNode($newPirNodeIndex)
    set displayLabel [getDisplayLabel pirNodeAlist labelP $trimP]
    pirWarning [format {Please Wait: %s instance being built --} $displayLabel] \
                    $msg2 $severity 
    update
    set widgetsExistP 1
    # if recursiveDefmoduleInstantiation fails because of a duplicate node name
    # newPirNodeIndex will not exist
    if {[lsearch -exact $pirNodes $newPirNodeIndex] >= 0} {
      updateNodeEdges $newPirNodeIndex $pirNodeIndex $oldWindow 
      redrawNodeEdges $currentCanvas.c \
          [assoc nodeInstanceName pirNode($newPirNodeIndex)] $widgetsExistP
    } else {
      set ignoreEdgesFromP 1; set ignoreEdgesToP 1
      cutEdgeSetList $currentCanvas.c edgeSetListFrom $ignoreEdgesFromP \
          $ignoreEdgesToP 
      cutEdgeSetList $currentCanvas.c edgeSetListTo $ignoreEdgesFromP \
          $ignoreEdgesToP 
    }
    set g_NM_canvasRedrawP 0
    if {! $g_NM_win32P} {
      .master.canvas config -cursor top_left_arrow
    }
    standardMouseClickMsg
  } else {
    if {$interactiveP} {
      set g_NM_edgesOfRedrawNode {}
    }
  }
  update
}











