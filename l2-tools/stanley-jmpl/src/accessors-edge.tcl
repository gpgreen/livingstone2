# $Id: accessors-edge.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors-edge.tcl : accessor & setter procs applied to
##              component/module edges


## given an edge structure, return the terminal component classes
## 12jan96 wmt: new
## 17may96 wmt: add support for port terminals & simplified
## 07oct96 wmt: revise to pass things as reference variables
proc getEdgeTerminals { nEdge terminalFromRef buttonFromRef \
    terminalToRef buttonToRef } {
  upvar $terminalFromRef terminalFrom
  upvar $buttonFromRef buttonFrom
  upvar $terminalToRef terminalTo
  upvar $buttonToRef buttonTo
  global pirEdge pirNode

  set terminalFrom [assoc "terminalFrom" pirEdge($nEdge)]
  set buttonFrom [assoc "buttonFrom" pirEdge($nEdge)]
  set terminalTo [assoc "terminalTo" pirEdge($nEdge)] 
  set buttonTo [assoc "buttonTo" pirEdge($nEdge)]
  # puts stderr "getEdgeTerminals terminalFrom $terminalFrom buttonFrom $buttonFrom"
  # puts stderr "getEdgeTerminals terminalTo $terminalTo buttonTo $buttonTo"
}


## determine if an edge connects two ports
## 17may96 wmt: new
## 19jun96 wmt: a port can also connect to an output or input
##              return string value
## 04oct96 wmt: handle terminalFromType not a port, but terminalToType is
proc isThisAPortEdge { nEdge { fromEdgeAttrList "" } { toEdgeAttrList "" } } {
  global pirEdge

  # puts stderr "isThisAPortEdge: nEdge $nEdge"

  set portEdgeType ""; set portFromP 0
  if {[string match $fromEdgeAttrList ""]} {
    set fromEdgeAttrList [assoc terminalFrom pirEdge($nEdge)]
  }
  set terminalFromType [getTerminalDirection $fromEdgeAttrList]
  if {[string match $terminalFromType "port"]} {
    set portFromP 1
  }
  if {[string match $toEdgeAttrList ""]} {
    set toEdgeAttrList [assoc terminalTo pirEdge($nEdge)]
  }
  set terminalToType [getTerminalDirection $toEdgeAttrList]
  if {$portFromP} {
    if {[string match $terminalToType "port"]} {
      set portEdgeType "portFromTo"
    } elseif {[string match $terminalToType "in"]} {
      set portEdgeType "port->To"
    } elseif {[string match $terminalToType "out"]} {
    set portEdgeType "port->From" 
    }
  } else {
    if {[string match $terminalFromType "in"] && \
        [string match $terminalToType "port"]} {
      set portEdgeType "port->To"
    } elseif {[string match $terminalFromType "out"] && \
        [string match $terminalToType "port"]} {
      set portEdgeType "port->From"
    }
  }
  # puts stderr "isThisAPortEdge: \"$portEdgeType\""
  return $portEdgeType 
}


## determine if this edge has a node which is an
## input/output/port-declaration
## 08oct96 wmt: new
## 05jun97 wmt: declaration_p not available anymore
##              greatly simplify using nodeClassName of terminal nodes
proc edgeHasDeclarationNodeP { pirEdgeIndex } {
  global pirEdge pirNode

  set hasDeclarationP 0; set reportNotFoundP 0
  lappend nodeIndexList [assoc nodeFrom pirEdge($pirEdgeIndex)]
  lappend nodeIndexList [assoc nodeTo pirEdge($pirEdgeIndex)]
  foreach nodeIndex $nodeIndexList {
    if {[string match [assoc nodeClassType pirNode($nodeIndex)]\
             "terminal"]} {
      set hasDeclarationP [regexp "DECLARATION" [assoc nodeClassName \
                                                     pirNode($nodeIndex)]]
      break
    }
  }
  return $hasDeclarationP
}


## does this edge connect to an immediate child of the defmodule
## 17oct96 wmt: new
proc isEdgeInDefmoduleP { pirEdgeIndex } {
  global pirEdge

  if {[isNodeInDefmoduleP [assoc nodeTo \
      pirEdge($pirEdgeIndex)]]} {
    return 1
  } else {
    return 0
  }
}


## update edge abstraction type dependency
## 18feb01 wmt: new
proc updateEdgeDependency { pirEdgeIndex nodeFromName nodeToName abstractionType \
                                currentCanvas canvasId } {
  global g_NM_classToEdgeInstances pirFileInfo

  set reportNotFoundP 0

  if {$abstractionType != "equal"} {
    getDependentClassNameList "edge" "edge" "" \
        dependentClassTypeList dependentClassNameList $abstractionType \
        "$pirFileInfo(filename):${nodeFromName}=>${nodeToName}"
    set dependentClassType [lindex $dependentClassTypeList 0]
    set dependentClassName [lindex $dependentClassNameList 0]
    if {$dependentClassName != ""} {
      # add to g_NM_classToEdgeInstances
      set currentEntries [assoc-array $dependentClassName g_NM_classToEdgeInstances \
                              $reportNotFoundP]
      if {[string match "" $currentEntries]} {
        set reportNotFoundP 0; set oldvalMustExistP 0
      } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
      lappend currentEntries "$currentCanvas.$canvasId" $pirEdgeIndex 
      arepl-array $dependentClassName $currentEntries g_NM_classToEdgeInstances \
          $reportNotFoundP $oldvalMustExistP
      updateDependentClasses $dependentClassType $dependentClassName "add"
    }
  }
}






