# $Id: accessors-terminal.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors-terminal.tcl : accessor & setter procs applied to
##              terminal definition forms


## return terminal type from terminal form
## pirEdgeP 0 => element of inputs/outputs of pirNode
## pirEdgeP 1 => terminalFrom/terminalTo of pirEdge
## 06may98 wmt: new
proc getTerminalType { terminalForm } {

  set type_list [list [assoc type terminalForm]]
  return [lindex [lindex $type_list 0] 0] 
}

proc getTerminalTypeFromType_List { type_list } {

  return [lindex [lindex $type_list 0] 0] 
}


## return terminal/attribute type class (abstraction/relation/structure/value)
## 16feb01 wmt: new
proc getDependentTerminalTypeClass { nodeOrEdgeType nodeOrEdgeName terminalType } {
  global g_NM_paletteStructureList g_NM_paletteDefrelationList 
  global g_NM_paletteDefvalueList g_NM_paletteAbstractionList
  global g_NM_dependencyErrorList g_NM_classDefType 

  if {[lsearch -exact $g_NM_paletteAbstractionList $terminalType] >= 0} {
    set dependentTypeClass abstraction
  } elseif {[lsearch -exact $g_NM_paletteDefrelationList $terminalType] >= 0} {
    set dependentTypeClass relation
  } elseif {[lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0} {
    set dependentTypeClass structure
  } elseif {[lsearch -exact $g_NM_paletteDefvalueList $terminalType] >= 0} {
    set dependentTypeClass value
  } else {
    if {$nodeOrEdgeType == "edge"} {
      set referenceType edgeType
    } else {
      set referenceType terminalType
    }
    # component/module c/m/e-name reference-type reference-name
    set errorForm [list $g_NM_classDefType $nodeOrEdgeName $referenceType \
                       $terminalType]
    if {[lsearch -exact $g_NM_dependencyErrorList $errorForm] == -1} {
      lappend g_NM_dependencyErrorList $errorForm
    }
    set dependentTypeClass ""
  }
  return $dependentTypeClass 
}
  

## return terminal direction from terminal form
## 06may98 wmt: new
proc getTerminalDirection { terminalForm } {

  set type_list [list [assoc type terminalForm]]
  return [lindex [lindex $type_list 0] 1]
}


## return terminal direction from terminal form
## as a pretty formatted string for the user
## 14may98 wmt: new
proc getTerminalDirectionPretty { terminalForm nodeClassType nodeClassName } {

  set prettyString ""
  set direction [getTerminalDirection $terminalForm]
  if {[regexp "port" $direction]} {
    append prettyString "bi-directional"
  } elseif {[string match $nodeClassType terminal] && \
                [string match $direction out]} {
    append prettyString input
  } elseif {[string match $nodeClassType terminal] && \
                [string match $direction in]} {
    append prettyString output
  } elseif {[string match $nodeClassType attribute]} {
    append prettyString attribute 
  } elseif {[string match $nodeClassType mode]} {
    append prettyString mode
  } else {
    append prettyString ${direction}put
  }
  if {[string match $nodeClassType terminal]} {
    append prettyString " terminal"
  }
  if {[lsearch -exact [list component module terminal] $nodeClassType] \
          >= 0} {
    append prettyString " -- [assoc interfaceType terminalForm]"
  }
  set len [string length $prettyString]
  if {! [string match $nodeClassType mode]} {
    append prettyString "\n"
    for {set i 0} {$i < $len} {incr i} {
      append prettyString "-"
    }
  }
  return $prettyString 
}


## return list of abstraction types whose args are
## terminalFromType and terminalToType
## 31mar98 wmt: new
proc getAbstractionTypes { terminalFromType terminalToType \
                               {stripFromTypePrefixP 0} } {
  global g_NM_paletteAbstractionList pirClassesAbstraction
  global pirClassAbstraction g_NM_paletteDefrelationList
  global pirClassesRelation pirClassRelation 

  # set str "\ngetAbstractionTypes: terminalFromType $terminalFromType"
  # puts stderr "$str terminalToType $terminalToType"
  set abstractionTypeList {}
  # default abstraction type is equal  - for structured and non-structured types
  # user can edit connection to change it to an allowable relation, if desired
  if {[string match $terminalFromType $terminalToType]} {
    lappend abstractionTypeList "equal"
  }
  # search abstraction and relation forms
  # relations are to values, what abstractions are to structures
  set silentP 1
  # puts stderr "getAbstractionTypes: g_NM_paletteAbstractionList $g_NM_paletteAbstractionList"
  set pirClassIndexList {}; set pirClassTypeList {}
  foreach abstractionName $g_NM_paletteAbstractionList {
    lappend pirClassIndexList $abstractionName
    lappend pirClassTypeList abstraction
  }
  foreach relationName $g_NM_paletteDefrelationList {
    lappend pirClassIndexList $relationName 
    lappend pirClassTypeList relation
  }
  foreach pirClassIndex $pirClassIndexList pirClassType $pirClassTypeList {
    if {$pirClassType == "abstraction"} {
      if {[lsearch -exact $pirClassesAbstraction $pirClassIndex] == -1} {
        read_workspace abstraction $pirClassIndex $silentP
      }
      set classVars [assoc class_variables pirClassAbstraction($pirClassIndex)]
    } elseif {$pirClassType == "relation"} {
      if {[lsearch -exact $pirClassesRelation $pirClassIndex] == -1} {
        read_workspace relation $pirClassIndex $silentP
      }
      set classVars [assoc class_variables pirClassRelation($pirClassIndex)]
    }
    set argTypesList [getClassVarDefaultValue argTypes classVars]
    set fromType [lindex $argTypesList 0]
    set toType [lindex $argTypesList 1]
    # puts stderr "\ngetAbstractionTypes: pirClassIndex $pirClassIndex pirClassType $pirClassType"
    # puts stderr "getAbstractionTypes: fromType $fromType terminalFromType $terminalFromType"
    # puts stderr "getAbstractionTypes: toType $toType terminalToType $terminalToType"
    if {[string match $fromType $terminalFromType] && \
            [string match $toType $terminalToType]} {
      if {$pirClassType == "abstraction"} {
        if {$stripFromTypePrefixP} {
          # strip off from type prefix
          set indx [string first "." $pirClassIndex]
          lappend abstractionTypeList [string range $pirClassIndex \
                                           [expr {$indx + 1}] end]
        } else {
          lappend abstractionTypeList $pirClassIndex 
        }
      } elseif {$pirClassType == "relation"} {
        lappend abstractionTypeList $pirClassIndex 
      }
    }
  }
  if {[llength $abstractionTypeList] > 1} {
    set abstractionTypeList [lsort -ascii -increasing $abstractionTypeList]
  }
  # puts stderr "getAbstractionTypes: $abstractionTypeList"
  if {[llength $abstractionTypeList] == 0} {
    lappend abstractionTypeList "<none-applicable>"
  }
  return $abstractionTypeList
}


## expand abstraction methodName to fromType.methodName
## 17nov00 wmt:new
proc expandAbstractionType { abstractionType expndAbstractionTypeListRef } {
  upvar $expndAbstractionTypeListRef expndAbstractionTypeList

  set expndAbstractionType $abstractionType 
  set splitList [split $abstractionType "."]
  # if already expanded, just return it
  if {[llength $splitList] == 2} {
    set expndAbstractionType $abstractionType
  } else {
    foreach expndType $expndAbstractionTypeList {
      if {[regexp $abstractionType $expndType]} {
        set expndAbstractionType $expndType
        break
      }
    }
  }
  return $expndAbstractionType 
}


## reduce abstraction fromType.methodName to methodName 
## 17nov00 wmt:new
proc reduceAbstractionType { expndAbstractionType } {

  set reducedAbstractionType $expndAbstractionType 
  set splitList [split $expndAbstractionType "."]
  if {[llength $splitList] == 2} {
    # strip off from type prefix
    set indx [string first "." $expndAbstractionType]
    set reducedAbstractionType [string range $expndAbstractionType \
                                    [expr {$indx + 1}] end]
  } else {
    set reducedAbstractionType $expndAbstractionType 
  }
  return $reducedAbstractionType 
}


## return the display label given the terminal from
## 16apr98 wmt: new
proc getDisplayLabelFromTerminalForm { terminalFormRef } {
  upvar $terminalFormRef terminalForm

  set reportNotFoundP 0
  set displayLabel [assoc terminal_label terminalForm $reportNotFoundP]
  # puts stderr "\ngetDisplayLabelFromTerminalForm: terminalForm $terminalForm"
  # puts stderr "getDisplayLabelFromTerminalForm: displayLabel $displayLabel"
  if {[string match $displayLabel ""]} {
    set displayLabel [getExternalNodeName [assoc terminal_name terminalForm]]
    # puts stderr "getDisplayLabelFromTerminalForm: displayLabel $displayLabel"
  }
  return $displayLabel
}


## present user with listbox of terminal's legal propositions
## selecting one puts it into the X copy-and=paste buffer
## so it can be pasted into an emacs buffer
## or
## present user with proposition values to choose for vmpl test STEPing
## if type is a 1 arg structure, selectTerminalPropositionUpdate will
## call back with increasing values of valueNum until all dimensions
## of the structure are presented to the user
## 29may98 wmt: new
proc selectTerminalProposition { terminalName type typeValuesList terminalWidget \
                                     { pirNodeIndex 0 } {valueNum 1 } \
                                     { valueList nil } {menu nil} {dialogW nil} } {
  global g_NM_rootInstanceName pirNode g_NM_terminalTypeValuesArray 
  global g_NM_vmplTestModeP g_NM_paletteStructureList 

  set terminalName [getExternalNodeName $terminalName]
  # puts stderr "selectTerminalProposition: terminalName $terminalName type $type"
  # puts stderr "    typeValuesList $typeValuesList terminalWidget $terminalWidget"
  # puts stderr "    pirNodeIndex $pirNodeIndex valueNum $valueNum valueList $valueList"
  # puts stderr "    menu $menu"
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  set reportNotFoundP 0
  if {$typeValuesList == "nil"} {
    set typeValuesList [assoc-array $type g_NM_terminalTypeValuesArray]
  }
  if {[string match $menu "nil"]} {
    # this is a call for a type which has multiple values; 2nd and subseqent
    set dialogW .selectprop$valueNum 
    catch {destroy $dialogW}
    # not a top level window -- just a standalone  menu selection 
    set menu $dialogW
    menubutton $menu -menu $menu.m -relief flat   
    menu $menu.m -tearoff 0
    $menu.m configure -font [preferred StanleyTerminalTypeFont]
    set cascadeP 0
  } else {
    # this is a cascade call from a Mouse-R operation menu for
    # selecting the first type value
    # passing in the menu to cascade from and the dialogW to kill
    # when the selection is made
    set cascadeP 1
  }

  if {[lsearch -exact $g_NM_paletteStructureList $type] >= 0} {
    set numValues [expr {[llength $typeValuesList] / 2}]
    if {$g_NM_vmplTestModeP} {
      # filter props one structured attribute at a time
      # find structure suffix to terminalName
      set numAttributes $numValues
      set attributes {}; set attributeValues {}
      for {set i 0} {$i < [llength $typeValuesList]} {incr i 2} {
        lappend attributes [lindex $typeValuesList $i]
        lappend attributeValues [lindex $typeValuesList [expr {$i + 1}]]
      }
      set propositions {}
      set propNameSuffix [lindex $attributes [expr {$valueNum - 1}]]
      foreach value [lindex $attributeValues [expr {$valueNum - 1}]] {
        lappend propositions "${terminalName}.$propNameSuffix = $value"
      }
    } else {
      # all structured attributes generated
      set propositions [expandTerminalPropositions $terminalName "terminal" $type]
    }
  } else {
    set numValues 1
    set propositions {}
    foreach typeValue $typeValuesList {
      lappend propositions "${terminalName} = $typeValue" 
    }
  }

  if {$g_NM_vmplTestModeP} {
    # trim off leading "?name."
    regsub -all "\\\?name." $propositions "" newProps
    set propositions $newProps 
    # in vmpl test mode (aka operational mode), all nodes are instantiated
    set terminalPirNodeIndex [getTerminalPirNodeIndexFromButtonPath $terminalWidget]
    if {[string match [assoc nodeClassName pirNode($terminalPirNodeIndex)] \
             "input"]} {
      set outputs [assoc outputs pirNode($terminalPirNodeIndex)]
      set terminalForm [assoc out1 outputs]
    } else {
      set inputs [assoc inputs pirNode($terminalPirNodeIndex)]
      set terminalForm [assoc in1 inputs]
    }
    set cmdMonType [lindex [assoc commandMonitorType terminalForm] 0]
    if {[string match $cmdMonType "monitored"]} {
      # add unknown to list of prop values for user to choose
      set prop [lindex $propositions 0] 
      set index [string first " " $prop]
      lappend propositions "[string range $prop 0 [expr {$index - 1}]] = unknown"
    }
  } else {
    set cmdMonType none
  }
  # fill menu
  
  # puts stderr "selectTerminalProposition: propositions $propositions"
  foreach proposition $propositions {
    set command "selectTerminalPropositionUpdate $dialogW $terminalWidget"
    append command " [list $proposition] [list $terminalName] $type"
    append command " $valueNum $numValues [list $valueList]"
    if {$g_NM_vmplTestModeP} {
      # get proposition value - e.g. pipeIn.pressure.sign = positive
      set index [string last " " $proposition]
      set propValue [string range $proposition [expr {$index + 1}] end]
      # set label $propValue 
      set label $proposition  
    } else {
      set propValue {}
      set label $proposition 
    }
    set label $proposition 
    append command " $propValue $pirNodeIndex $cmdMonType" 
    # puts stderr "selectTerminalProposition: proposition $proposition"
    if {$cascadeP} {
      $menu add command -label $label -command $command
    } else {
      $menu.m add command -label $label -command $command
    }
  }
  if {! $cascadeP} {
    pack $menu -side top -fill x -expand 1

    # bury menu if user makes no selection
    ## comment this out since it loses all the mouse bindings,
    ## if the user trys again
    # bind all <ButtonRelease-3> "disableSelectionMenu $dialogW $menu"
    
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
    set x [winfo pointerx $currentCanvas] 
    set y [winfo pointery $currentCanvas]
    tk_popup $menu.m [expr {$x + 10}] $y
    keepDialogOnScreen $menu.m 

    # turn off terminal widget selection
    event generate $terminalWidget <Leave>
  }
  update
}


## do cascade menu of the component or module's
## immediate children attributes => their propositions
## 03jun98 wmt: new
proc selectAttributeProposition { pirNodeIndex attributeWidget } {
  global pirNode g_NM_instanceToNode 

  set dialogW .selectprop
  catch {destroy $dialogW}
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  set reportNotFoundP 0
  # not a top level window -- just as menu selection 
  set menu $dialogW
  menubutton $menu -menu $menu.m -relief flat 
    
  set rootMenu [menu $menu.m -tearoff 0]
  foreach attInstanceNameInternal [assoc attributes pirNode($pirNodeIndex)] {
    # what to do if attribute instance has not been created yet ?????
    set attPirNodeIndex [assoc-array $attInstanceNameInternal g_NM_instanceToNode]
    set outputs [assoc outputs pirNode($attPirNodeIndex)]
    set terminalForm [assoc out1 outputs]
    set pirNodeAlist $pirNode($attPirNodeIndex)
    set attDisplayLabel [getDisplayLabel pirNodeAlist labelP]
    set attInstanceNamePath [getTclPathNodeName $attInstanceNameInternal]
    set subMenu $rootMenu.$attInstanceNamePath
    $rootMenu add cascade -label $attDisplayLabel -menu $subMenu 
    menu $subMenu -tearoff 0 
    fillPropositionSubMenu [assoc nodeClassType pirNode($attPirNodeIndex)] \
        $terminalForm $subMenu $attributeWidget $dialogW 
  }
  pack $menu -side top -fill x

  # bury menu if user makes no selection
  bind all <ButtonRelease-3> "disableSelectionMenu $dialogW $menu"

  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
  set x [winfo pointerx $currentCanvas] 
  set y [winfo pointery $currentCanvas]
  tk_popup $menu.m [expr {$x + 10}] $y 

  # turn off attribute widget selection
  event generate $attributeWidget <Leave>
  update
}


## fill cascade submenu with terminalForm propositions.
## adapted from selectAttributeProposition
## 29oct99 wmt: new
proc fillPropositionSubMenu { nodeClassType terminalForm subMenu terminalWidget \
                                  dialogW {valuesList ""} } {

  if {$nodeClassType == "mode"} {
    set terminalName "mode"
  } else {
    set terminalName [getExternalNodeName [assoc terminal_name terminalForm]]
  }
  set terminalType [getTerminalType $terminalForm]

  set propositions [expandTerminalPropositions $terminalName $nodeClassType \
                        $terminalType $valuesList]

  # puts stderr "fillPropositionSubMenu: propositions $propositions"
  # fill menu
  foreach proposition $propositions {
    set command "selectTerminalPropositionUpdate $dialogW $terminalWidget"
    append command " [list $proposition]"
    # puts stderr "fillPropositionSubMenu: proposition $proposition"
    $subMenu add command -label $proposition -command $command
  }
}


## put proposition into the X copy-and=paste buffer, 
## if in g_NM_vmplTestModeP mode, place command monitor propositions
## in appropriate globals for STEP button
## 01jun98 wmt: new
proc selectTerminalPropositionUpdate { dialogW terminalWidget proposition \
                                       {terminalName nil} {type nil} \
                                           {valueNum 1} {numValues 1} \
                                           {valueList nil} {propValue nil} \
                                           {pirNodeIndex nil} {cmdMonType nil} } {
  global g_NM_schematicMode g_NM_vmplTestModeP 
  global g_NM_stepCommandsMonitors pirNode 
  global g_NM_scenarioDialogRoot 


  set canvasRootId 0; set reportNotFoundP 0; set oldvalMustExistP 0
  set balloonType testValues
  if {! $g_NM_vmplTestModeP} {
    # puts stderr "selectTerminalPropositionUpdate: proposition $proposition"
    # clear the PRIMARY selection so the CLIPBOARD selection is used

    ## Jeff Hobbs code example of getting stuff from clipboard
# 	if {[catch {selection get -displayof $w -selection CLIPBOARD} data]} {
# 	    return
# 	}
    selection clear
    clipboard clear 
    clipboard append $proposition
    destroy $dialogW 
  } else {
    # set str "selectTerminalPropositionUpdate: pirNodeIndex $pirNodeIndex"
    # puts stderr "$str cmdMonType $cmdMonType"
    if {[string match $cmdMonType commanded]} {
      lappend g_NM_stepCommandsMonitors [list $proposition progress] 
      # puts stderr "selectTerminalPropositionUpdate: proposition $proposition progress"

      # not needed since multiple commands are now allowed
#       if {(! [string match $g_NM_permBalloonCmdWindow ""]) && \
#               [winfo exists $g_NM_permBalloonCmdWindow]} {
#         # replace user selected values with default values
#         set oldPirNodeIndex [getPirNodeIndexFromButtonPath $g_NM_permBalloonCmdWindow]
#         set nodeClassType [assoc nodeClassType pirNode($oldPirNodeIndex)]
#         getLocation&NumFromButton $g_NM_permBalloonCmdWindow loc num
#         if {$loc == "in"} {
#           set inputs [assoc inputs pirNode($oldPirNodeIndex)]
#           set terminalForm [assoc in$num inputs] 
#         } else {
#           set outputs [assoc outputs pirNode($oldPirNodeIndex)]
#           set terminalForm [assoc out$num outputs]
#         }
#         set cmdMonValue [lindex [assoc commandMonitorType terminalForm] 1]
#         # structured types have a list of values
#         set cmdMonConstraintP {}
#         foreach val $cmdMonValue {
#           lappend cmdMonConstraintP 1
#         }
#         getPermBalloonWindows $oldPirNodeIndex balloonWindow rootWindow xOffset \
#         yOffset $g_NM_permBalloonCmdWindow 
#         permanentBalloonHelp $balloonWindow $rootWindow $cmdMonValue $balloonType \
#             $xOffset $yOffset $canvasRootId $cmdMonConstraintP 
#       }
#       set g_NM_permBalloonCmdWindow $terminalWidget 
    } else {
      # monitored
      lappend g_NM_stepCommandsMonitors [list $proposition assign] 
      # puts stderr "selectTerminalPropositionUpdate: proposition $proposition assign"
    }
    destroy $dialogW
    lappend valueList $propValue 
    incr valueNum
    # puts stderr "selectTerminalPropositionUpdate: valueNum $valueNum numValues $numValues"
    if {$valueNum <= $numValues} {
      # if this is a structure type, call back to get the other values
      selectTerminalProposition $terminalName $type nil $terminalWidget \
                                     $pirNodeIndex $valueNum $valueList
    } else {
      set scenarioName ""
      addToScenarioFile $scenarioName
      raise $g_NM_scenarioDialogRoot

      # do not display perm balloons for cmd/mon selection
      # they are only displayed whent the cmd/mon is executed
#       getPermBalloonWindows $pirNodeIndex balloonWindow rootWindow xOffset \
#           yOffset $terminalWidget
#       # puts stderr "selectTerminalPropositionUpdate: valueList $valueList"
#       # discard nil placeholder in valueList
#       set valueList [lrange $valueList 1 end] 
#       # structured types have a list of values
#       set cmdMonConstraintP {}
#       foreach val $valueList {
#         lappend cmdMonConstraintP 1
#       }
#       permanentBalloonHelp $balloonWindow $rootWindow $valueList \
#           $balloonType $xOffset $yOffset $canvasRootId $cmdMonConstraintP
    }
  }
}


## 01jun98 wmt: new
proc disableSelectionMenu { dialogW menu } {
  
  if {[winfo exists $dialogW]} {
    lower $dialogW
    lower $menu.m
    tkMenuUnpost $menu
    destroy $dialogW 
  }
}


## check for inherited terminals which occur in inputs/outputs, not in
## input_terminals/output_terminals/port_terminals
## propNameList is created from input_terminals/output_terminals/port_terminals 
## 19jun98 wmt: new
proc getInheritedPropositions { pirNodeAlistRef } {
  upvar $pirNodeAlistRef pirNodeAlist

  set inheritedPropNameList {}
  set inputs [assoc inputs pirNodeAlist]
  for {set i 1} {$i < [llength $inputs]} { incr i 2} {
    set terminalForm [lindex $inputs $i]
    set terminalName [assoc terminal_name terminalForm]
    set terminalType [getTerminalType $terminalForm]
    set expandedPropNames [expandStructurePropNames $terminalName \
                               $terminalType expndStructPList]
    foreach name $expandedPropNames flag $expndStructPList {
      lappend inheritedPropNameList [list $name $flag]
    }
  }

  set outputs [assoc outputs pirNodeAlist]
  for {set i 1} {$i < [llength $outputs]} { incr i 2} {
    set terminalForm [lindex $outputs $i]
    set terminalName [assoc terminal_name terminalForm]
    set terminalType [getTerminalType $terminalForm]
    set expandedPropNames [expandStructurePropNames $terminalName \
                               $terminalType expndStructPList]
    foreach name $expandedPropNames flag $expndStructPList {
      lappend inheritedPropNameList [list $name $flag]
    }
  }
  # puts stderr "getInheritedPropositions: inheritedPropNameList $inheritedPropNameList"
  return $inheritedPropNameList 
}


## return button x,y position relative to its node
## 16jul98 wmt: new
proc getButtonXYNodePosition { canvas nodePath buttonPath xRef yRef } {
  upvar $xRef x
  upvar $yRef y

  scan [winfo geometry $nodePath] "%dx%d+%d+%d" nodeWidth nodeHeight \
      nodeX nodeY
  set index [string last "." $buttonPath]
  set outPath [string range $buttonPath 0 [expr {$index - 1}]]
  scan [winfo geometry $outPath] "%dx%d+%d+%d" outWidth outHeight \
      outX outY
  # puts stderr "getButtonXYNodePosition: outX $outX outY $outY outWidth $outWidth"
  scan [winfo geometry $buttonPath] "%dx%d+%d+%d" buttonWidth buttonHeight \
      buttonX buttonY
  # set str "getButtonXYNodePosition: buttonX $buttonX buttonY $buttonY"
  # puts stderr "$str buttonWidth $buttonWidth"

  set x [expr {[$canvas canvasx $nodeX] + $buttonX + $outX + \
                   ($buttonWidth / 2) - 6}]         
  set y [expr {[$canvas canvasy $nodeY] + $buttonY + $outY - 2}]
}


## get termInstanceName type
## return terminalForm found
## 29oct98 wmt: new
proc getTerminalInstanceType { pirNodeIndex terminalFormRef \
                                   { reportNotFoundP 1 } } {
  upvar $terminalFormRef terminalForm
  global pirNode

  set type ""
  set inputs [assoc inputs pirNode($pirNodeIndex) $reportNotFoundP]
  # puts stderr "getTerminalInstanceType: inputs $inputs"
  if {! [string match $inputs ""]} {
    set terminalForm [assoc in1 inputs] 
    set type [getTerminalType $terminalForm]
    # puts stderr "in type $type"
  } else {
    set outputs [assoc outputs pirNode($pirNodeIndex) $reportNotFoundP]
    # puts stderr "getTerminalInstanceType: outputs $outputs"
    if {! [string match $outputs ""]} {
      set terminalForm [assoc out1 outputs] 
      set type [getTerminalType $terminalForm]
      # puts stderr "out type $type"
    }
  }
  # check for parameterized terminal type
  if {[regexp "\\\?" [string range $type 0 1]]} {
    set type [getParameterType $type]
  }
  return $type
}


## expand terminal name to its structured components
## output is the same as expandStructurePropNames, except that
## expndStructPList is not produced
## 08apr00 wmt: new
proc expandStructureTerminalNames { terminalFormRef } {
  upvar $terminalFormRef terminalForm
  global g_NM_paletteStructureList g_NM_terminalTypeValuesArray 

  set terminalInstance [assoc terminal_name terminalForm]
  set terminalType [getTerminalType $terminalForm]
  if {[lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0} {
    set typeValuesList [assoc-array $terminalType g_NM_terminalTypeValuesArray]
    set attributes {}; set terminalInstanceExpanded {}
    for {set indx 0} {$indx < [llength $typeValuesList]} {incr indx 2} {
      lappend attributes [lindex $typeValuesList $indx]
    }
    foreach propNameSuffix $attributes {
      lappend terminalInstanceExpanded $terminalInstance.$propNameSuffix
    } 
  } else {
    set terminalInstanceExpanded $terminalInstance
  }
  return $terminalInstanceExpanded 
}


## expand terminal name and type to proposition names
## if type is a structure type 
## 01dec98 wnt: new
proc expandStructurePropNames { terminalName terminalType expndStructPListRef } {
  upvar $expndStructPListRef expndStructPList
  global g_NM_terminalTypeValuesArray g_NM_paletteStructureList

  set expndStructPList 0
  set propNameList $terminalName
  # puts stderr "expandStructurePropNames B: terminalName $terminalName terminalType $terminalType"
  # check for structure - if so, and not a parameterized termial type, expand
  if {([lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0) &&
      (! [structIsTerminalTypeParamP $terminalType])} {
    set typeValuesList [assoc-array $terminalType g_NM_terminalTypeValuesArray]
    set attributeList {}; set attributeValueList {}
    for {set i 0} {$i < [llength $typeValuesList]} {incr i 2} {
      lappend attributeList [getInternalNodeName [lindex $typeValuesList $i]]
    }
    if {[llength $attributeList] == 0} {
      set attributeList ?name
    } else {
      # mark expanded structures only
      set expndStructPList {}
      for {set i 0} {$i < [llength $attributeList]} {incr i} {
        lappend expndStructPList 1
      }
    }      
    # substitute terminalName for ?name
    regsub -all "\\\?name" $attributeList $terminalName tmp
    set propNameList $tmp
  }
  # puts stderr "expandStructurePropNames A: propNameList $propNameList"
  return $propNameList 
}


## reduce expanded proposition name by one qualification level
## former lmpl usage
## (sign~(presure~(pipeIn~?name))) => (presure~(pipeIn~?name))
## jmpl usage 
## pipeIn.pressure.sign => pipeIn.pressure
## 03dec98 wmt: new
proc reduceStructurePropname { propName } {

  set indx [string last "." $propName]
  set len [string length $propName]
  set terminalInstanceName [string range $propName 0 [expr {$indx - 1}]]
  set expandedToken [string range $propName [expr {$indx + 1}] end ]
  return [list $terminalInstanceName $expandedToken]
}


## reduce expanded proposition name to its root, i.e.
## the terminal instance to which it is tied 
## 30jan00 wmt: new
proc reduceStructurePropnameToRoot { propName terminalInstanceNameRef \
                                           terminalNodeIndexRef } {
  upvar $terminalInstanceNameRef terminalInstanceName
  upvar $terminalNodeIndexRef terminalNodeIndex
  global g_NM_instanceToNode g_NM_vmplTestModeP g_NM_schematicMode 

  set reportNotFoundP 0
  if {($g_NM_schematicMode == "operational") && \
          $g_NM_vmplTestModeP} {
    set terminalInstanceName $propName
  } else {
    set terminalInstanceName [getInternalNodeName $propName]
  }
  # puts stderr "\nreduceStructurePropnameToRoot: propName $propName terminalInstanceName $terminalInstanceName"
  set terminalNodeIndex [assoc-array $terminalInstanceName \
                             g_NM_instanceToNode $reportNotFoundP]
  set maxLoopCnt 20; set loopCnt 0
  while {[string match $terminalNodeIndex ""]} {
    # lop off another level of structure
    set terminalInstanceName [lindex [reduceStructurePropname \
                                          $terminalInstanceName] 0]
    # puts stderr "    terminalInstanceName $terminalInstanceName"
    if {$terminalInstanceName != ""} {
      set terminalNodeIndex [assoc-array $terminalInstanceName \
                                 g_NM_instanceToNode $reportNotFoundP]
    }
    incr loopCnt
    if {$loopCnt > $maxLoopCnt} {
      error "reduceStructurePropnameToRoot: terminal root of $propName not found"
    }
  }
}


## expand terminal name using its type values to get propositions
## 22mar00 wmt: new
proc expandTerminalPropositions { terminalName nodeClassType terminalType \
                                       {valuesList ""} } {
  global g_NM_paletteStructureList
  global g_NM_terminalTypeValuesArray 

  # passing in valuesList is a special case for mode propositions
  if {[string match $valuesList ""]} {
    set valuesList [assoc-array $terminalType g_NM_terminalTypeValuesArray]
  }
  # puts stderr "expandTerminalPropositions: terminalName $terminalName valuesList $valuesList"
  set propositions {}
  if {[lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0} {
    # format structured type value lists
    for {set i 0} {$i < [llength $valuesList]} {incr i 2} {
      set expandSuffix [lindex $valuesList $i]
      set expandValuesList [lindex $valuesList [expr {$i + 1}]]
      foreach typeValue $expandValuesList {
        lappend propositions "$terminalName.$expandSuffix = $typeValue;"
      }
    }
  } else {
    foreach typeValue $valuesList {
      lappend propositions "$terminalName = $typeValue;"
    }
  }
  return $propositions 
} 


## is this terminal defined as a command or monitor terminal
## and is it inherited to the top level of the current scope
## if it is a monitor, add unknown to the values list
## 11dec98 wmt: new
proc commandMonitorTerminalInheritedP { terminalName valuesListRef \
                                            nodeClassType } {
  upvar $valuesListRef valuesList
  global g_NM_testInstanceNameInternal pirNode g_NM_moduleToNode
  global g_NM_instanceToNode g_NM_rootInstanceName g_NM_vmplTestModeP

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "commandMonitorTerminalInheritedP: `$backtrace'"
  # when called from mkNode, the terminal node which is associated
  # with this button does not exist yet -- so I cannot add
  # inheritedCmdMonP to it at this point.  Do it in addClassInstance
  # 
  set inheritedCmdMonP 0
  set terminalName [lindex $terminalName 0]
  if {$g_NM_vmplTestModeP} {
    set nodeInstanceName $g_NM_testInstanceNameInternal
  } else {
    set nodeInstanceName $g_NM_rootInstanceName
  }
  set groupPirNodeIndex [assoc-array $nodeInstanceName g_NM_instanceToNode]
  # puts stderr "\n commandMonitorTerminalInheritedP: terminalName `$terminalName'"
  # puts stderr "groupPirNodeIndex $groupPirNodeIndex"
  set inputs [assoc inputs pirNode($groupPirNodeIndex)]
  for {set index 0} {$index < [llength $inputs]} {incr index 2} {
    set terminalForm [lindex $inputs [expr { $index + 1}]]
    set topLevelTerminalName [assoc terminal_name terminalForm]
#     if {[regexp "Ruddervator.cmdIn" $terminalName]} {
#       puts stderr "   IN terminal_name `$topLevelTerminalName'"
#     }
    if {[string match $terminalName $topLevelTerminalName]} {
      set inheritedCmdMonP 1
      break
    }
  }
  # puts stderr "inheritedCmdMonP $inheritedCmdMonP"
  if {! $inheritedCmdMonP} {
     # puts stderr "outputs [assoc outputs pirNode($groupPirNodeIndex)]"
    set outputs [assoc outputs pirNode($groupPirNodeIndex)]
    for {set index 0} {$index < [llength $outputs]} {incr index 2} {
      set terminalForm [lindex $outputs [expr { $index + 1}]]
      set topLevelTerminalName [assoc terminal_name terminalForm]
#       if {[regexp "Ruddervator.cmdIn" $terminalName]} {
#         puts stderr "   OUT terminal_name $topLevelTerminalName"
#       }
      if {[string match $terminalName $topLevelTerminalName]} {
        set inheritedCmdMonP 1
        break
      }
    }
  }
#   if {[regexp "led" $terminalName]} {
#   set str "commandMonitorTerminalInheritedP: terminalName $terminalName"
#   puts stderr "$str inheritedCmdMonP $inheritedCmdMonP"
#   }
  return $inheritedCmdMonP
}


## expand number of values if multi-dimensional 1 arg structure
## 15aug99 wmt: new
proc expandCmdMonValues { terminalType commandMonitorTypeValue } {
  global g_NM_paletteStructureList g_NM_terminalTypeValuesArray

  if {[lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0} {
    set numDimensions [expr {[llength [assoc-array $terminalType \
                                           g_NM_terminalTypeValuesArray]] / 2}]
    set cmdMonValueList {}
    for {set i 0} {$i < $numDimensions} {incr i} {
      lappend cmdMonValueList $commandMonitorTypeValue
    }
  } else {
    # non-structured type
    set cmdMonValueList $commandMonitorTypeValue
  }
  return $cmdMonValueList 
}


## ensure that multi-dimensional types have multi-dimensional default values.
## this also resets cmdMonTypeValueList if terminal type changes
## resulting in its number of structured slot values changing
## 08apr00: wmt
proc checkTerminalFormCmdMonValues { terminalFormRef } {
  upvar $terminalFormRef terminalForm

  set cmdMonTypeValueList [assoc commandMonitorType terminalForm]
  set currentDefaultVales [lindex $cmdMonTypeValueList 1]
  set terminalType [getTerminalType $terminalForm]
  # there is always at least one value
  set defaultVales [expandCmdMonValues $terminalType [lindex $currentDefaultVales 0]]
  if {[llength $currentDefaultVales] != [llength $defaultVales]} {
    set cmdMonTypeValueList [lreplace $cmdMonTypeValueList 1 1 \
                                 $defaultVales]
    arepl commandMonitorType $cmdMonTypeValueList terminalForm
  }
}


## return list of constrained by user(1)or inferred by L2(0)
## for a structured terminal type
## commands generally have the value noCommand, and marked inferred
## except when the progress that sets the command was in the
## last time step, then they are exogenous.
## Their values are passed back in commandTerminalValues, 
## L2 sets all command variables immediately back to noCommand
## after it processes the progress
## derived from showCommandMonitorTerminalBalloonsDoit
## 24jan01 wmt:new
proc terminalValuesConstrainedOrInferred { terminalFormRef pirNodeIndex \
                                             cmdMonitorValuesRef } {
  upvar $terminalFormRef terminalForm
  upvar $cmdMonitorValuesRef cmdMonitorValues
  global g_NM_commandMonitorConstraints g_NM_stanleyCurrentTime pirNode
  global g_NM_defaultDisplayState g_NM_groundProcessingUnitP

  set reportNotFoundP 0
  set terminalName [assoc terminal_name terminalForm]
  set expandedTerminalNames [expandStructureTerminalNames terminalForm]
  if {$g_NM_groundProcessingUnitP} {
    set commandMonitorConstraints {}
  } else {
    # in Scenario Mgr Warp mode, cmdmon constraints are not saved
    if { [catch { set commandMonitorConstraints \
                      $g_NM_commandMonitorConstraints($g_NM_stanleyCurrentTime) }] } {
      set commandMonitorConstraints {}
    }
  }
  set nodePropList [assoc nodePropList pirNode($pirNodeIndex)]
  set cmdMonValueList [getCmdMonValues terminalForm nodePropList]
  set commandMonitorType [assoc commandMonitorType terminalForm $reportNotFoundP]
  set cmdMonConstraintP {}
  # attributes cannot be commanded or monitored
  # puts stderr "terminalValuesConstrainedOrInferred: commandMonitorConstraints $commandMonitorConstraints "
  if {[llength $commandMonitorType] > 0} {
    foreach expTerminalName $expandedTerminalNames cmdMonValue $cmdMonValueList {
      # puts stderr "terminalValuesConstrainedOrInferred: expTerminalName [getExternalNodeName $expTerminalName] "
      set expTerminalName [getExternalNodeName $expTerminalName] 
      if {([lsearch -exact $commandMonitorConstraints $expTerminalName] >= 0) || \
              [string match $cmdMonValue $g_NM_defaultDisplayState]} {
        lappend cmdMonConstraintP 1
      } else {
        lappend cmdMonConstraintP 0
      }
      lappend cmdMonitorValues [assoc $expTerminalName commandMonitorConstraints \
                                    $reportNotFoundP]
    }
  }
  # puts stderr "terminalValuesConstrainedOrInferred: terminalName $terminalName cmdMonConstraintP $cmdMonConstraintP cmdMonitorValues $cmdMonitorValues"
  return $cmdMonConstraintP 
}



















