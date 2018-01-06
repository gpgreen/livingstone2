# $Id: accessors-node.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors-node.tcl : accessor & setter procs applied to
##              nodes -- component/module/terminal/mode/attribute


## is this node an immediate child of the defmodule
## 17oct96 wmt: new
proc isNodeInDefmoduleP { pirNodeIndex } {
  global pirNode

  if {[llength [assoc parentNodeGroupList \
      pirNode($pirNodeIndex)]] == 2} {
    return 1
  } else {
    return 0
  }
}


## get nodeInstanceName from g_NM_includedModules
## with pirNodeIndex as the key
## as the key
## 09may97 wmt: new
proc getNodeInstanceNameFromIncludedModules { pirNodeIndex includedModulesRef } {
  upvar $includedModulesRef includedModules

  set nodeInstanceName ""
  for {set i 0} {$i < [llength $includedModules]} {incr i 2} {
    set maybeNodeInstanceName [lindex $includedModules $i]
    set attList [lindex $includedModules [expr {1 + $i}]]
    if {[assoc pirNodeIndex attList] == $pirNodeIndex} {
      set nodeInstanceName $maybeNodeInstanceName
      break
    }
  }
  if {[string match $nodeInstanceName ""]} {
    set str "getNodeInstanceNameFromIncludedModules: instance name not found"
    puts stderr "$str for pirNodeIndex $pirNodeIndex"
    # puts stderr "\nincludedModules $includedModules "
    error "getNodeInstanceNameFromIncludedModules"
  }
  return $nodeInstanceName
}





## get window path from pirNodeIndex and canvas
## 01sep97 wmt: new
proc getWindowPathFromPirNodeIndex { pirNodeIndex canvas } {
  global g_NM_canvasIdToPirNode 

  set cnt [regsub -all "\\\." $canvas "." tmp]
  if {$cnt != 4} {
    puts stderr "getWindowPathFromPirNodeIndex: canvas $canvas does not have 4 .'s"
  }
  set canvasIdPirNodeAlist [assoc-array $canvas g_NM_canvasIdToPirNode]
  # puts stderr "getWindowPathFromPirNodeIndex: canvas $canvas pirNodeIndex $pirNodeIndex"
  # puts stderr "   canvasIdPirNodeAlist $canvasIdPirNodeAlist"
  set windowPath ""
  for {set i 0} {$i < [llength $canvasIdPirNodeAlist]} {incr i 2} {
    if {[lindex $canvasIdPirNodeAlist [expr {1 + $i}]] == $pirNodeIndex} {
      set canvasId [lindex $canvasIdPirNodeAlist $i]
      set windowPath [lindex [$canvas itemconfigure $canvasId -window] 4]
      break
    }
  }
  # puts stderr "getWindowPathFromPirNodeIndex: windowPath $windowPath"
  return $windowPath
}


## return read only status of class definition schematic file
## 20feb98 wmt: new
proc classDefReadOnlyP { nodeClassType nodeClassName } {
  global g_NM_readOnlyDefsAlist STANLEY_SUPERUSER env
  global g_NM_readOnlyWorkspaceList 

  set readOnlyP 0
  if {[string match $STANLEY_SUPERUSER $env(LOGNAME)]} {
    return $readOnlyP
  } elseif {[lsearch -exact $g_NM_readOnlyWorkspaceList \
                 [preferred projectId]] >= 0} {
     set readOnlyP 1
  } else {
    # set str "classDefReadOnlyP: nodeClassType $nodeClassType nodeClassName"
    # puts stderr "$str $nodeClassName"
    for {set i 0} {$i < [llength $g_NM_readOnlyDefsAlist]} {incr i 2} {
      # set str "classDefReadOnlyP: type [lindex $g_NM_readOnlyDefsAlist $i]"
      # puts stderr "$str name [lindex $g_NM_readOnlyDefsAlist [expr 1 + $i]]"
      if {[string match [lindex $g_NM_readOnlyDefsAlist $i] \
               $nodeClassType] && \
              [string match [lindex $g_NM_readOnlyDefsAlist [expr {1 + $i}]] \
                   $nodeClassName]} {
        set readOnlyP 1
        break
      }
    }
    # set backtrace ""; getBackTrace backtrace
    # puts stderr "classDefReadOnlyP: `$backtrace'"
    # puts stderr "classDefReadOnlyP: readOnlyP $readOnlyP"
    return $readOnlyP
  }
}


## return read only status of component/module schematic file
## based on g_NM_classDefType
## 21feb98 wmt: new
proc componentModuleDefReadOnlyP { } {
  global g_NM_classDefType g_NM_livingstoneDefcomponentName
  global g_NM_livingstoneDefmoduleName 

  switch $g_NM_classDefType {
    component {
      return [classDefReadOnlyP component $g_NM_livingstoneDefcomponentName]
    }
    module {
      return [classDefReadOnlyP module $g_NM_livingstoneDefmoduleName]
    }
    <type> {
      return 0
    }
    default {
      set str "componentModuleDefReadOnlyP: g_NM_classDefType"
      error "$str $g_NM_classDefType not handled"
    }
  }
}


## return the pirNode index of the component/module display state 
## attribute to use in menu Edit->Header->Display Attribute
## call it with g_NM_rootInstanceName to get top-level
## call it with g_NM_currentNodeGroup to get current level
## 24feb98 wmt: new
proc getDisplayStatePirNodeIndex { nodeGroup } {
  global g_NM_nodeGroupToInstances pirNode jMplConvertP

  set displayStatePirNodeIndex 0
  set nameIndexPairList [assoc-array $nodeGroup g_NM_nodeGroupToInstances]
  set displayStateAttName displayState
  if {$jMplConvertP} {
    set displayStateAttName DISPLAY-STATE
  }
  for {set i 0} {$i < [llength $nameIndexPairList]} {incr i 2} {
    set pirNodeIndex [lindex $nameIndexPairList [expr {1 + $i}]]
    if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
             attribute] && \
            [string match [assoc nodeClassName pirNode($pirNodeIndex)] \
                 $displayStateAttName]} {
      set displayStatePirNodeIndex $pirNodeIndex
      break
    }
  }
  # set str "getDisplayStatePirNodeIndex: displayStatePirNodeIndex"
  # puts stderr "$str $displayStatePirNodeIndex"
  return $displayStatePirNodeIndex
}


## get the displayed label from the instance name for a
## node, e.g. ?name.nominal => nominal
## or massFlowSpec.nominal => nominal 
proc getExternalNodeName { nodeInstanceName } {

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "getExternalNodeName: `$backtrace'"  
  if {[regexp "\\\?name" $nodeInstanceName]} {
    set indx [string first "." $nodeInstanceName]
    set externalName [string range $nodeInstanceName [expr {$indx + 1}] end]
  } else {
    set externalName $nodeInstanceName
  }
  return $externalName 
}


## get the internal instance name for a displayed node name
## e.g. nominal => ?name.nominal
proc getInternalNodeName { displayName } {

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "getInternalNodeName: `$backtrace'"  
  if {[regexp "\\\?name" $displayName]} {
    return $displayName
  } else {
    return "?name.$displayName"
  }
}


## get the tcl path name for an instance name
## canvas and window tcl path names used . for delimiters
## do not substitute ?name.pr01 for .master.canvas.?name.c.w12
## rather substitute ?name_pr01 to get .master.canvas.?name_pr01.c.w12
## 06jan00 wmt: new
proc getTclPathNodeName { nodeInstanceName } {

  regsub -all "\\\." $nodeInstanceName "_" instanceNamePath
  # first letter must be lower case
  set firstLetter [string tolower [string range $instanceNamePath 0 0]]
  return ${firstLetter}[string range $instanceNamePath 1 end]
}

  
## get the "base" mode name from the instance name for a
## component mode, e.g. ?name.nominal => nominal
proc getComponentModeLabel { nodeInstanceName } {

  set indx [string last "." $nodeInstanceName]
  set outName [string range $nodeInstanceName [expr {$indx + 1}] end]
  return $outName 
}


## get the displayed label from the instance name for a
## module parent link node, e.g. MOD-TEST_P17 => MOD-TEST
proc getModuleParentLinkLabel { label } {

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "getModuleParentLinkLabel: `$backtrace'"
  # strip off unique integer appended to _P and the _P
  set index [string last "_P" $label]
  set newLabel [string range $label 0 [expr {$index - 1}]]
  if {[string match $newLabel ""]} {
    puts stderr "getModuleParentLinkLabel: \"_P\" not found in `$label'"
  }
  return $newLabel 
}


## get the displayed label of the parent of a
## module parent link node, e.g. MOD-TEST_P17 => MOD-TEST
## get label of MOD-TEST 
proc getModuleParentLabel { canvasRootId } {
  global pirNode g_NM_moduleToNode g_NM_rootInstanceName 

  set parentNodeGroupList [getCanvasRootInfo g_NM_parentNodeGroupList \
                               $canvasRootId]
  # puts stderr "getModuleParentLabel: canvasRootId $canvasRootId"
  # puts stderr "getModuleParentLabel: parentNodeGroupList $parentNodeGroupList"
  if {[llength $parentNodeGroupList] < 2} {
    return ""
  }
  set parentInstanceName [lindex $parentNodeGroupList 1]
  set pirNodeIndex [assoc-array $parentInstanceName g_NM_moduleToNode]
  if {[string match $parentInstanceName $g_NM_rootInstanceName]} {
    set label [assoc nodeClassName pirNode($pirNodeIndex)]
  } else {
    set pirNodeAlist $pirNode($pirNodeIndex)
    set label [getDisplayLabel pirNodeAlist labelP]
  }
  return $label 
}


## get the displayed label from the instance name for a
## terminal node, e.g. (PORT1~C1)&PT_85 => " ";
## others get internal name
proc getTerminalLabel { label } {

  if {[regexp "&IT_" $label] || [regexp "&OT_" $label] || \
          [regexp "&PT_" $label]} {
    # for terminators just display 1 blank character
    set label " "
  } else {
    # strip off unique suffix of declarations 
    set index [string first "&" $label]
    if {$index != -1} {
      set label [string range $label 0 [expr {$index - 1}]]
    }
  }
  # puts stderr "getTerminalLabel: `$label'"
  return $label 
}


## get instance name for a
## terminal node, e.g. (PORT1~C1)&PT_85 => (PORT1~C1)
proc getTerminalName { name } {

  # strip off unique suffix of declarations 
  set index [string first "&" $name]
  if {$index != -1} {
    set name [string range $name 0 [expr {$index - 1}]]
  }
  # puts stderr "getTerminalName: `$name'"
  return $name 
}


## return component, module, attribute, & terminal display label
## if instanceLabel is not present, or has no value,
## return nodeInstanceName
## use for node labels -- use nodeInstanceName for bubble help
proc getDisplayLabel { pirNodeAlistRef labelPRef { trimP 0 } } {
  upvar $pirNodeAlistRef pirNodeAlist
  upvar $labelPRef labelP
  global pirNode g_NM_componentToNode

  set reportNotFoundP 0; set labelP 0
  set nodeClassType [assoc nodeClassType pirNodeAlist]
  set nodeInstanceName [assoc nodeInstanceName pirNodeAlist]
  if {[lsearch -exact [list attribute component module terminal] \
           $nodeClassType] >= 0} {
    # instance label is a raw string, embedded blanks, etc
    # no filtering
    set maybeDisplayLabel [assoc instanceLabel pirNodeAlist \
                          $reportNotFoundP]
    if {[string match $maybeDisplayLabel ""] || \
            [string match $maybeDisplayLabel $nodeInstanceName]} {
      # set displayLabel [getExternalNodeName $nodeInstanceName]
      # return local instance name
      set indx [string last "." $nodeInstanceName]
      set displayLabel [string range $nodeInstanceName [expr {$indx + 1}] end]
    } else {
      set labelP 1
      if {$trimP} {
        set maybeDisplayLabel [string trim $maybeDisplayLabel ": "]
      }
      set displayLabel $maybeDisplayLabel 
    }
  } else {
    # set displayLabel [getExternalNodeName $nodeInstanceName]
    # return local instance name
    set indx [string last "." $nodeInstanceName]
    set displayLabel [string range $nodeInstanceName [expr {$indx + 1}] end]
  }
  return $displayLabel 
}


## return the display label given the attribute/terminal instance name,
## given that the instance must be instantiated as a pirNode
## 16apr98 wmt: new
proc getPropositionDisplayLabel { propositionName nodeInstanceName nodeLabelName \
                                    expndStructureP } {
  global g_NM_instanceToNode pirNode g_NM_moduleToNode
  global g_NM_schematicMode

  if {[string match $g_NM_schematicMode layout]} {
    error "getPropositionDisplayLabel cannot be called in layout mode"
  }
  set reportNotFoundP 0
  # ensure that propositionName is in internal syntax

  # puts stderr "getPropositionDisplayLabel: propositionName $propositionName"
  # terminal instance names may be "{(IN1 OO)}"
  set propositionName [lindex $propositionName 0]
  # since expanded structure proposition names are now entries in g_NM_instanceToNode
  # the following lopping off procedure does not work since the expanded name
  # is found ==> get the root name to prevent this
  # puts stderr "IN propositionName $propositionName expndStructureP $expndStructureP"
  if {$expndStructureP} {
    set returnPair [reduceStructurePropname $propositionName ] 
    set propositionName [lindex $returnPair 0]
    set expandSuffix ".[lindex $returnPair 1]"
    # puts stderr "IN propositionName $propositionName expandSuffix $expandSuffix"
  } else {
    set expandSuffix ""
  }
  # lope off succeeding levels of qualification looking for an
  # instance -- this happens when structures expand as terminal types.
  # add qualifications to the label
  set labelPrefixes ""
  while {[string length $propositionName] > 0} {
    # puts stderr "WHILE propositionName $propositionName expndStructureP $expndStructureP"
    set pirNodeIndex [assoc-array $propositionName g_NM_instanceToNode $reportNotFoundP]
    if {[string match $pirNodeIndex ""]} {
      if {[string match [string index $propositionName 0] "\("]} {
        set len [string length $propositionName]
        set propositionName [string range $propositionName 1 [expr {$len - 2}]]
        set index [string first "\(" $propositionName]
        append labelPrefixes [string range $propositionName 0 [expr {$index - 2}]]
        append labelPrefixes "."
        set propositionName [string range $propositionName $index end]
        # puts stderr "     propositionName `$propositionName'"
      } else {
        break
      }
    } else {
      break
    }
  }
  if {[string match $pirNodeIndex ""]} {
    puts stderr "getPropositionDisplayLabel: no pirNodeIndex exists for $propositionName"
    return "no_label"
  }
  set pirNodeAlist $pirNode($pirNodeIndex)
  set maybeDisplayLabel [getDisplayLabel pirNodeAlist labelP]
#   if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#     puts stderr "maybeDisplayLabel $maybeDisplayLabel labelP $labelP"
#   }
  if {$labelP} {
    set nodeGroupInstanceName [assoc nodeGroupName pirNode($pirNodeIndex)]
    set pirNodeIndex [assoc-array $nodeGroupInstanceName g_NM_instanceToNode] 
    set pirNodeAlist $pirNode($pirNodeIndex)
    set nodeGroupDisplayLabel [getDisplayLabel pirNodeAlist labelP]
#     if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#       puts stderr "nodeLabelName $nodeLabelName nodeGroupDisplayLabel $nodeGroupDisplayLabel"
#     }
    if {[string match $nodeLabelName $nodeGroupDisplayLabel]} {
      set returnLabel $labelPrefixes$maybeDisplayLabel$expandSuffix
    } else {
      set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
#       if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#         puts stderr "    parentNodeGroupList $parentNodeGroupList"
#       }
      set foundInstanceP 0; set foundPropositionP 0
      # go up inheritance list looking for this proposition in inputs/outputs.
      # attributes are not inherited, so they are not handled here
      foreach instanceName $parentNodeGroupList {
#         if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#           puts stderr "    instanceName $instanceName"
#         }
        if {[string match $nodeInstanceName $instanceName]} {
          set foundInstanceP 1
          break
        }
      }
      if {! $foundInstanceP} {
        set str "getPropositionDisplayLabel: could not find nodeInstanceName"
        error "$str $nodeInstanceName in parentNodeGroupList $parentNodeGroupList"
      }
      set pirNodeIndex [assoc-array $instanceName g_NM_moduleToNode]
#       if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#         puts stderr "  instanceName $instanceName pirNodeIndex $pirNodeIndex"
#       }
      set inputs [assoc inputs pirNode($pirNodeIndex)]
      foreach terminalForm [alist-values inputs] {
        set terminalName [assoc terminal_name terminalForm]
        # puts stderr "   IN terminalName $terminalName propositionName $propositionName"
        if {[string match $terminalName $propositionName]} {
          set terminalLabel [assoc terminal_label terminalForm]
#           # remove top label
#           set index [string first "." $terminalLabel]
#           set terminalLabel [string range $terminalLabel [expr $index + 1] end]
          set returnLabel $labelPrefixes$terminalLabel$expandSuffix
          set foundPropositionP 1
          break
        }
      }
      if {! $foundPropositionP} {
        # check outputs
        set outputs [assoc outputs pirNode($pirNodeIndex)]
        foreach terminalForm [alist-values outputs] {
          set terminalName [assoc terminal_name terminalForm]
          # puts stderr "   OUT terminalName $terminalName propositionName $propositionName"
          if {[string match $terminalName $propositionName]} {
            set terminalLabel [assoc terminal_label terminalForm]
#             # remove top label
#             set index [string first "." $terminalLabel]
#             set terminalLabel [string range $terminalLabel [expr $index + 1] end]
            set returnLabel $labelPrefixes$terminalLabel$expandSuffix
            set foundPropositionP 1
            break
          }
        }
      }
      if {! $foundPropositionP} {
        set backtrace ""; getBackTrace backtrace
        set str "getPropositionDisplayLabel: could not find propositionName"
        error "$str $propositionName in nodeInstanceName $instanceName"
      }
    }
  } else {
    set returnLabel $labelPrefixes$maybeDisplayLabel$expandSuffix
  }
#   if {[string match $propositionName (THRUST~(THRUSTER~(PALETTE-C~RCS-A)~X))]} {
#     puts stderr "getDisplayLabelFromInstanceName: returnLabel $returnLabel"
#     puts stderr "    labelPrefixes $labelPrefixes"
#   }
  return $returnLabel
}


## get pirNodeIndex and nodeClassType for component or module
## instance name
## 21apr98 wmt: new
proc getComponentModulePirNodeIndex { instanceName pirNodeIndexRef \
                                          nodeClassTypeRef } {
  upvar $pirNodeIndexRef pirNodeIndex
  upvar $nodeClassTypeRef nodeClassType
  global g_NM_moduleToNode g_NM_componentToNode 

  set reportNotFoundP 0
  # convert to internal syntax
  set instanceNameInternal $instanceName 
  set pirNodeIndex [assoc-array $instanceNameInternal g_NM_moduleToNode \
                        $reportNotFoundP]
  set nodeClassType module
  if {[string match $pirNodeIndex ""]} {
    set pirNodeIndex [assoc-array $instanceNameInternal g_NM_componentToNode \
                         $reportNotFoundP]
    set nodeClassType component
  }
  if {[string match $pirNodeIndex ""]} {
    set nodeClassType ""
  }
}
    

## get input/output/port terminal names lists from inputs & outputs
## 21apr98 wmt: new
proc getTerminalNames { pirNodeIndex input_terminalsRef output_terminalsRef \
                            port_terminalsRef } {
  upvar $input_terminalsRef input_terminals
  upvar $output_terminalsRef output_terminals
  upvar $port_terminalsRef port_terminals
  global pirNode

  set inputs [assoc inputs pirNode($pirNodeIndex)]
  set outputs [assoc outputs pirNode($pirNodeIndex)]
  for {set i 1} {$i < [llength $inputs]} { incr i 2 } {
    set inputForm [lindex $inputs $i]
    set nameList [assoc terminal_name inputForm]
    set terminalNameInternal $nameList 
    lappend input_terminals $terminalNameInternal
  }

  # outputs and ports
  for {set i 1} {$i < [llength $outputs]} { incr i 2 } {
    set outputForm [lindex $outputs $i]
    set nameList [assoc terminal_name outputForm]
    set terminalNameInternal $nameList 
    if {[getTerminalDirection $outputForm] == "out"]} {
      lappend output_terminals $terminalNameInternal
    } else {
      lappend port_terminals $terminalNameInternal
    }
  }
}


## get node type and name
## varList pirNode($pirNodeIndex)
## 12may96 wmt: new
## 27sep96 wmt: start using nodeTypeName & nodeClassName, rather than
## module_class/component_class in pirNode structs -- use nodeClassType 
## & nodeClassName instead; module_class/component_class/terminal_class
## used to parse .cfg file contents in canvasB1Click
## 04jun97 wmt: add maybe_attribute_class 
proc getNodeClassTypeAndName { varsListName } {
  upvar $varsListName varsList

  # puts stderr "getNodeClassTypeAndName: varsList $varsList"
  set classType ""; set className ""; set reportNotFoundP 0
  set maybe_type [assoc nodeClassType varsList $reportNotFoundP]
  if {! [string match $maybe_type ""]} {
    set classType $maybe_type
    set className [assoc nodeClassName varsList]
  } else {
    set maybe_component_class [assoc component_class varsList $reportNotFoundP]
    set maybe_module_class [assoc module_class varsList $reportNotFoundP]
    set maybe_terminal_class [assoc terminal_class varsList $reportNotFoundP]
    set maybe_attribute_class [assoc attribute_class varsList $reportNotFoundP]
    set maybe_mode_class [assoc mode_class varsList $reportNotFoundP]
    if {! [string match $maybe_component_class ""]} {
      set classType component
      set className $maybe_component_class 
    } elseif {! [string match $maybe_module_class ""]} {
      set classType module
      set className $maybe_module_class
    } elseif {! [string match $maybe_terminal_class ""]} {
      set classType terminal
      set className $maybe_terminal_class
    } elseif {! [string match $maybe_attribute_class ""]} {
      set classType attribute
      set className $maybe_attribute_class
    } elseif {! [string match $maybe_mode_class ""]} {
      set classType mode
      set className $maybe_mode_class
    } else {
      puts stderr "getNodeClassTypeAndName: classType & className not found\!"
      # set str "maybe_component_class $maybe_component_class maybe_module_class"
      # puts stderr "$str $maybe_module_class maybe_terminal_class $maybe_terminal_class"
      # error "getNodeClassTypeAndName"
    }
  }
  return [list $classType $className]
}


## determine background color for node
## 01dec95 wmt: new
## 06mar96 wmt: pass in node alist, rather than node state & faultModeP
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 07apr96 wmt: handle control mode status
## 14may96 wmt: add arg nodeClassType to handle defmodules
## 25jul96 wmt: revise handling to reflect R2S3 MIR Problem Statement
## 27aug96 wmt: ACS-MODE-A => ACS-A
## 19nov96 wmt: add colors for recoverable & unknown
## 03dec96 wmt: add g_NM_acsModeRCSDVStatus g_NM_acsModeSRUACQStatus
##              g_NM_acsModeIDLEStatus
## 09dec96 wmt: determine nodeHealthState for components from nodeState(mode) 
##              and nodePower
## 03mar98 wmt: pass pirNodeIndex rather than a bunch of values
proc getNodeStateBgColor { pirNodeIndex { callerMkNodeP 0 } } {
  global pirNode g_NM_schematicMode g_NM_propsWarnMsgsP 
  global g_NM_opsWarningsP g_NM_instanceToNode env 
  global g_NM_defaultDisplayState g_NM_defaultDisplayState
  global g_NM_displayStateColorMapping

  set nodeState [assoc nodeState pirNode($pirNodeIndex)]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeStateBgColor white

  set reportNotFoundP 0
  # set str "getNodeStateBgColor: nodeInstanceName $nodeInstanceName nodeState"
  # puts stderr "$str $nodeState pirNodeIndex $pirNodeIndex"

  if {[string match $nodeClassType "terminal"]} {
    if {[regexp "declaration" $nodeClassName]} {
      set nodeStateBgColor [preferred NM_terminalDeclNodeBgColor]
    } else {
      set nodeStateBgColor [preferred StanleyTerminalNodeBgColor]
    }
  } elseif {[string match $nodeClassType "attribute"]} {
    set nodeStateBgColor [preferred StanleyAttributeNodeBgColor]
  } elseif {[string match $nodeState "parent-link"]} {
    set nodeStateBgColor [preferred StanleyModuleNodeBgColor]

  } elseif {[string match $g_NM_schematicMode "layout"]} {
    if {[string match $nodeState "NIL"]} {
      # this is a defmodule
      set nodeStateBgColor [preferred StanleyModuleNodeBgColor]
    } elseif {[string match $nodeClassType "component"]} {
      set nodeStateBgColor [preferred StanleyComponentNodeBgColor] 
    } elseif {[string match $nodeClassType "mode"]} {
      if {[string match $nodeClassName "okMode"]} {
        set nodeStateBgColor [preferred StanleyOkModeNodeBgColor]
      } elseif {[string match $nodeClassName "faultMode"]} {
        set nodeStateBgColor [preferred StanleyFaultModeNodeBgColor]
      }
    } 
  } elseif {[string match $g_NM_schematicMode "operational"]} {
    if {$callerMkNodeP} {
      if {[string match $nodeClassType "component"]} {
        set nodeStateBgColor [preferred StanleyComponentNodeBgColor]
      } elseif {[string match $nodeClassType "module"]} {
        set nodeStateBgColor [preferred StanleyModuleNodeBgColor]
      } elseif {[string match $nodeClassType "mode"]} {
        set nodeStateBgColor [preferred StanleyNonCurrentModeBgColor]
      }
    } elseif {[string match $nodeClassType "component"] || \
                  [string match $nodeClassType "module"]} {
      set nodePropList [assoc nodePropList pirNode($pirNodeIndex)]
      set displayStatePropName [assoc displayStatePropName pirNode($pirNodeIndex) \
                                    $reportNotFoundP]
      set nodeStateBgColor [preferred [assoc-exact $g_NM_defaultDisplayState \
                                           g_NM_displayStateColorMapping]]
      # puts stderr "getNodeStateBgColor: $nodeInstanceName nodeState `$nodeState' pirNodeIndex $pirNodeIndex"
      if {($displayStatePropName == "") || \
              [string match $nodeState $g_NM_defaultDisplayState]} {
        # nodeState = noData, when Stanley does not have a value for nodeState
        set nodeDisplayState $g_NM_defaultDisplayState
        if {$g_NM_propsWarnMsgsP} {
          # set str "getNodeStateBgColor: $nodeInstanceName"
          # puts stderr "$str has no displayStatePropName: default used"
          puts stderr "... $nodeInstanceName: no displayStatePropName"
        }
      } else {
        # evaluate displayStateProc with displayStateProcArgs to generate
        # nodeDisplayState -- this is done wholly in Stanley to eliminate
        # displayState propositions from L2
        set nodeDisplayState ""; set validP 1
        # puts stderr "\nnodeInstanceName $nodeInstanceName nodePropList $nodePropList" 
        set displayStateIndex [assoc-array $displayStatePropName g_NM_instanceToNode]
        set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
        # puts stderr "\nnodeInstanceName $nodeInstanceName nodeClassName $nodeClassName"
        set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
        set displayStateProc [assoc displayStateProc pirNode($displayStateIndex)]
        set displayStateProcArgs [assoc displayStateProcArgs pirNode($displayStateIndex)]
#         if {[regexp "sv03" $nodeInstanceName]} {
#           puts stderr "\ngetNodeStateBackgroundColor nodeInstanceName $nodeInstanceName"
        # puts stderr "displayStateProc `$displayStateProc' displayStateProcArgs $displayStateProcArgs"
#         }
        # get fully qualified (expanded) args
        set expandedArgs {}; set expndP {}
        foreach arg $displayStateProcArgs {
          if {[regexp "\\\." $arg]} {
            # maybe arg is in another instance at this level
            set numLevels [expr {[llength [split $arg "."]] - 1}]
            set splitInstance [split $nodeInstanceName "."]
            set reducedInst [join [lrange $splitInstance 0 $numLevels] "."]
            set maybeArg "$reducedInst.$arg"
            # is it ?
            if {[assoc-array $maybeArg g_NM_instanceToNode $reportNotFoundP] \
                    != ""} {
              lappend expandedArgs $maybeArg 
            } else {
              # maybe it is at a lower level
              set maybeArg "$nodeInstanceName.$arg"
              if {[assoc-array $maybeArg g_NM_instanceToNode $reportNotFoundP] \
                      != ""} {
                lappend expandedArgs $maybeArg
              } else {
                set str "While expanding display state attribute arguments for\n"
                append str "instance `[getExternalNodeName $nodeInstanceName]' of "
                append str "class `$nodeClassName',\n"
                append str "arg `$arg' could not be expanded.\n"
                append str "nodeDisplayState = `indeterminate' used instead.\n"
                append str "Revise \"Edit->Header->Display Attribute\" code to correct error."
                set dialogList [list tk_dialog .d "Recoverable Error" \
                                    $str error 0 {DISMISS}]
                eval $dialogList
                puts stderr "\n$str"
                set  validP 0
              }
            }
            lappend expndP 1
          } else {
            lappend expandedArgs "$nodeInstanceName.$arg"
            lappend expndP 0
          }
        }
        if {$validP} {
#           if {[regexp "sv03" $nodeInstanceName]} {
#             puts stderr "expandedArgs $expandedArgs"
#           }
          set evalList [list getDisplayState]
          # get arg values 
          foreach expArg $expandedArgs exp $expndP {
            if {$exp} {
              # get appropriate nodePropList for another instance
              set pirIndex [assoc-array $expArg g_NM_instanceToNode]
              set nodeGroupName [assoc nodeGroupName pirNode($pirIndex)]
              set pirIndex [assoc-array $nodeGroupName g_NM_instanceToNode]
              set propList [assoc nodePropList pirNode($pirIndex)]
            } else {
              # assumes arg values in this instance
              set propList $nodePropList
            }
            # puts stderr "propList $propList "
            set labelValueList [assoc-exact $expArg propList $reportNotFoundP]
            lappend evalList [assoc value labelValueList $reportNotFoundP]
          }
#           if {[regexp "sv03" $nodeInstanceName]} {
#             puts stderr "evalList $evalList"
#           }
          # puts stderr "getNodeStateBgColor: nodeInstanceName $nodeInstanceName "
#           if {[regexp "sv01" $nodeInstanceName]} {
#             puts stderr "getNodeStateBgColor: displayStateProc $displayStateProc "
#           }
          # source displayStateProc for evaluation
          set stanleyHomeDir $env(HOME)/.stanley
          set fileName $stanleyHomeDir/getDisplayState.tcl
          file delete $fileName 
          set fid [open $fileName w]
          puts $fid $displayStateProc
          close $fid
          if { [catch { source $fileName } errorMsg ]} {
            set str "While sourcing display state attribute code for\n"
            append str "instance `[getExternalNodeName $nodeInstanceName]' of "
            append str "class `$nodeClassName',\n"
            append str "an error occurred:\n"
            append str "\"$errorMsg\".\n"
            append str "Stanley incorrectly converted JMPL code to TCL --\n"
            append str "offending code is in `$fileName'."
            set dialogList [list tk_dialog .d "Unrecoverable Error" \
                                $str error 0 {DISMISS}]
            eval $dialogList
            puts stderr "\n$str"
            set nodeDisplayState ""
          } else {
            # set nodeDisplayState [eval $evalList]
            if { [catch { eval $evalList } nodeDisplayState ]} {
              set str "While executing display state attribute code for\n"
              append str "instance `[getExternalNodeName $nodeInstanceName]' of "
              append str "class `$nodeClassName',\n"
              append str "an error occurred:\n"
              append str "\"$nodeDisplayState\".\n"
              append str "nodeDisplayState = `indeterminate' used instead.\n"
              append str "Revise \"Edit->Header->Display Attribute\" code to correct error."
              set dialogList [list tk_dialog .d "Recoverable Error" \
                                  $str error 0 {DISMISS}]
              eval $dialogList
              puts stderr "\n$str"
              set nodeDisplayState ""
              # puts stderr "getNodeStateBgColor: nodeInstanceName $nodeInstanceName evalList $evalList"
              # puts stderr "    displayStateProc $displayStateProc "
            }
          }
        }
        if {[string match $nodeDisplayState ""]} {
          set nodeDisplayState "indeterminate"
          if {$g_NM_propsWarnMsgsP} {
            set str "getNodeStateBgColor: [getExternalNodeName $nodeInstanceName] "
            append str "(pirNodeIndex $pirNodeIndex)"
            set str "$str has no value for displayStatePropName $displayStatePropName:"
            puts stderr "$str `indeterminate' used"
            ### test # set str "... $nodeInstanceName: displayStatePropName"
            ### test # puts stderr "$str $displayStatePropName has no value" 
          }
        }
        # puts stderr "getNodeStateBgColor: $nodeInstanceName nodeDisplayState `$nodeDisplayState' pirNodeIndex $pirNodeIndex"
        set nodeStateBgColorIndirect [assoc-exact $nodeDisplayState \
                                          g_NM_displayStateColorMapping \
                                          $reportNotFoundP]
        if {$nodeStateBgColorIndirect == ""} {
          set str "While executing display state attribute code for\n"
          append str "instance `[getExternalNodeName $nodeInstanceName]' of "
          append str "class `$nodeClassName',\n"
          append str "an error occurred:\n"
          append str "nodeDisplayState `$nodeDisplayState' is not defined in displayStateValues.\n"
          append str "nodeDisplayState = `indeterminate' used instead.\n"
          append str "Revise \"Edit->Header->Display Attribute\" code to correct error."
          set dialogList [list tk_dialog .d "Recoverable Error" \
                              $str error 0 {DISMISS}]
          eval $dialogList
          puts stderr "\n$str"
          set nodeStateBgColor [preferred [assoc-exact "indeterminate" \
                                               g_NM_displayStateColorMapping]]
        } else {
          set nodeStateBgColor [preferred $nodeStateBgColorIndirect]
          # puts stderr "nodeStateBgColor $nodeStateBgColor"
        }
        # update displayState value, since it is not a proposition anymore
        set labelValueList [assoc-exact $displayStatePropName \
                                nodePropList $reportNotFoundP]
        arepl value $nodeDisplayState labelValueList 
        arepl $displayStatePropName $labelValueList nodePropList 
        arepl nodePropList $nodePropList pirNode($pirNodeIndex)
      }
    } elseif {[string match $nodeClassType "mode"]} { 
      if {[string match $nodeClassName "okMode"]} {
        set nodeStateBgColor [preferred StanleyCurrentOkModeBgColor]
      } elseif {[string match $nodeClassName "faultMode"]} {
        set nodeStateBgColor [preferred StanleyCurrentFaultModeBgColor]
      }
    }
  }
  if {[string match $nodeStateBgColor white] && \
          ([string match $g_NM_schematicMode layout] || \
               ([string match $g_NM_schematicMode operational] && \
                    $g_NM_opsWarningsP))} {
    # set backtrace ""; getBackTrace backtrace
    # puts stderr "getNodeStateBgColor: `$backtrace'"
    puts stderr "getNodeStateBgColor: nodeStateBgColor $nodeStateBgColor"
    set str "getNodeStateBgColor: nodeInstanceName $nodeInstanceName nodeState"
    puts stderr "$str $nodeState"
  }
  return $nodeStateBgColor
}


## get parent-link pirNodeIndex for a node group
## 25nov96 wmt: new
proc getNodeGroupParentLink { nodeGroup } {
  global g_NM_nodeGroupToInstances pirNode

  set pirNodeIndex ""
  set nodeGroupAlist [assoc-array $nodeGroup g_NM_nodeGroupToInstances]
  for {set i 1} {$i < [llength $nodeGroupAlist]} {incr i 2} {
    set index [lindex $nodeGroupAlist $i]
    if {[string match [assoc nodeState pirNode($index)] \
        "parent-link"]} {
      set pirNodeIndex $index
      break
    }
  }
  if {[string match $pirNodeIndex ""]} {
    puts stderr "getNodeGroupParentLink: parent-link not found"
    error "getNodeGroupParentLink"
  }
  return $pirNodeIndex 
}







  






