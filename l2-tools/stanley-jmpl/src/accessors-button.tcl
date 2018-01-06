# $Id: accessors-button.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## button-accessors.tcl : accessor procs for button widgets,
## e.g. .master.canvas.?name.c.w55.in.b2 

# parse the button path name to obtain the button number
## 12oct95 wmt: since children are .left .b1 .right, subtract 1
## 01mar96 wmt: add returnIndexP
## 05jun96 wmt: do not assume that node & buttons currently exist
proc pirButtonNum { button in_or_out {returnIndexP 1} } {

  # this determines the position of the button in the children of
  # its containing frame. Simply extracting the final integer doesn't work 
#  set framename \
#   [string range $button 0 \
#    [expr [string length $in_or_out]+[string last ".${in_or_out}" $button]]]
#  ## puts [format {pirbuttonnum framename => %s} $framename]
#  ## puts [format {pirbuttonnum children => %s} [winfo children $framename]]
#  set returnval [lsearch -exact [winfo children $framename] $button]
#  if {$returnIndexP} {
#    set returnVal [expr $returnVal -1]
#    # index of the button in the list of buttons (0, 1, 2, ...)
#  }
  set pos [string last "." $button]
  set returnVal [string range $button [expr {$pos + 2}] end]
  set returnVal [expr {$returnVal - 1}]
  # puts stderr "pirButtonNum $button $in_or_out index $returnVal"  
  return $returnVal
}


## determine if port terminal button is a "From" or "To" button
proc isThisPortTerminalFromOrTo { button_widget edgeNum } {
  global pirEdge
  
  set portEdgeType [isThisAPortEdge $edgeNum]
  if {! [string match $portEdgeType ""]} {
    if {[string match $button_widget [assoc buttonFrom pirEdge($edgeNum)]]} {
      set direction To
    } else {
      set direction From
    }
  } else {
    puts stderr "isThisPortTerminalFromOrTo: this is not a port edge\!"
    set direction ""
  }
  # puts stderr "isThisPortTerminalFromOrTo: direction $direction portEdgeType $portEdgeType"
  return $direction 
}


## get canvas from pirEdge buttonFrom or buttonTo
## .slave_1.canvas.?name.c.w54.in.b1 => .slave_1.canvas.?name.c
## 07may97 wmt: new
proc getCanvasFromButton { buttonPath } {

  set pathList [split $buttonPath "."]
  set numElements [llength $pathList]
  return [join [lrange $pathList 0 [expr {$numElements - 4}]] "."]
}


## get canvas parent from pirEdge buttonFrom or buttonTo
## .slave_1.canvas.?name.c.w54.in.b1 => .slave_1.canvas.?name
## 07may97 wmt: new
proc getCanvasParentFromButton { buttonPath } {

  set pathList [split $buttonPath "."]
  set numElements [llength $pathList]
  return [join [lrange $pathList 0 [expr {$numElements - 5}]] "."]
}


## get window from pirEdge buttonFrom or buttonTo
## .slave_1.canvas.?name.c.w54.in.b1 => .slave_1.canvas.?name.c.w54
## 07may97 wmt: new
proc getWindowFromButton { buttonPath } {

  set pathList [split $buttonPath "."]
  set numElements [llength $pathList]
  return [join [lrange $pathList 0 [expr {$numElements - 3}]] "."]
}


## get node location (in[top] or out[bottom]), and button number
##  from pirEdge buttonFrom or buttonTo
## .slave_1.canvas.?name.c.w54.in.b1 => in 1
## 07may97 wmt: new
proc getLocation&NumFromButton { buttonPath locationRef numRef } {
  upvar $locationRef location
  upvar $numRef num

  set pathList [split $buttonPath "."]
  set numElements [llength $pathList]
  set location [lindex $pathList [expr {$numElements - 2}]]
  set num [string range [lindex $pathList [expr {$numElements - 1}]] 1 end]
}


## get terminal button direction 
## input -- in  output -- out  port -- port 
## from button widget path
## 06dec97 wmt: new
proc getTerminalButtonDirectionType { button } {
  global pirNode

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "getTerminalButtonDirectionType: `$backtrace'"
  set directionType {}
  set buttonNodeIndex [getPirNodeIndexFromButtonPath $button]
  # puts stderr "getTerminalButtonDirectionType: button $button buttonNodeIndex $buttonNodeIndex"
  getLocation&NumFromButton $button buttonLocation buttonNum
  set inOutType "${buttonLocation}puts"
  set multipleTerminalList [assoc $inOutType pirNode($buttonNodeIndex)]
  set terminalList [assoc "${buttonLocation}${buttonNum}" \
                        multipleTerminalList]
  set directionType [getTerminalDirection $terminalList]
  # puts stderr "getTerminalButtonDirectionType: button $button directionType $directionType"
  # puts stderr "      nodeInstanceName [assoc nodeInstanceName pirNode($buttonNodeIndex)]"
  # puts stderr "   buttonLocation $buttonLocation"
  return $directionType
}


## get pirNodeIndex from button path, e.g. .master.canvas.?name.c.w12.in.b1
## this can return pirNodeIndex for nodeType terminal, component, or module
## 01sep97 wmt: new
proc getPirNodeIndexFromButtonPath { buttonPath {caller ""}} {
  global g_NM_windowPathToPirNode g_NM_canvasList 

  if {$caller == "mkPendingEdge"} {
    # getCanvasFromButton returns e.g. .master.canvas.?name.c
    # g_NM_canvasList canvases are e.g. .master.canvas.?name
    set pathList [split $buttonPath "."]
    set numElements [llength $pathList]
    set canvasParent [getCanvasParentFromButton $buttonPath] 

    if {[lsearch -exact $g_NM_canvasList $canvasParent] == -1} {
      # not a valid canvas -- buttonPath is bad
      return 0
    }
  }
  set canvas [getCanvasFromButton $buttonPath]
  set windowPath [getWindowFromButton $buttonPath]
  # puts stderr "getPirNodeIndexFromButtonPath: buttonPath $buttonPath canvas $canvas"
  set windowPathPirNodeAlist [assoc-array $canvas g_NM_windowPathToPirNode]
  # puts stderr "getPirNodeIndexFromButtonPath: buttonPath $buttonPath windowPath $windowPath"
  # puts stderr "     windowPathPirNodeAlist $windowPathPirNodeAlist"
  set pirNodeIndex ""
  for {set i 0} {$i < [llength $windowPathPirNodeAlist]} {incr i 2} {
    if {[string match [lindex $windowPathPirNodeAlist $i] $windowPath]} {
      set pirNodeIndex [lindex $windowPathPirNodeAlist [expr {1 + $i}]]
      break
    }
  }
  # puts stderr "     pirNodeIndex $pirNodeIndex"
  return $pirNodeIndex
}


## this always return the pirNodeIndex of a terminal nodeType
## 13aug99 wmt: new
proc getTerminalPirNodeIndexFromButtonPath { buttonPath } {
  global pirNode g_NM_instanceToNode 

  set nodePirNodeIndex [getPirNodeIndexFromButtonPath $buttonPath]
  if {[string match [assoc nodeClassType pirNode($nodePirNodeIndex)] \
           "terminal"]} {
    return $nodePirNodeIndex
  } else {
    getLocation&NumFromButton $buttonPath location num
    set terminalFormsAList [assoc ${location}puts pirNode($nodePirNodeIndex)]
    set terminalForm [assoc ${location}$num terminalFormsAList]
    set terminalName [assoc terminal_name terminalForm]
    set terminalNameInternal $terminalName 
    set terminalPirNodeIndex [assoc-array $terminalNameInternal \
                                  g_NM_instanceToNode]
    return $terminalPirNodeIndex 
  }
}


## get terminalFrom from button path
## variation of getTerminalPirNodeIndexFromButtonPath 
## 21oct99 wmt: new
proc getTerminalFormFromButtonPath { buttonPath } {
  global pirNode 

  set nodePirNodeIndex [getPirNodeIndexFromButtonPath $buttonPath]
  getLocation&NumFromButton $buttonPath location num
  set terminalFormsAList [assoc ${location}puts pirNode($nodePirNodeIndex)]
  set terminalForm [assoc ${location}$num terminalFormsAList]
  return $terminalForm 
}

  
## set terminalFrom of button path
## 21oct99 wmt: new
proc setTerminalFormOfButtonPath { buttonPath terminalForm } {
  global pirNode 

  set nodePirNodeIndex [getPirNodeIndexFromButtonPath $buttonPath]
  getLocation&NumFromButton $buttonPath location num
  set terminalFormsAList [assoc ${location}puts pirNode($nodePirNodeIndex)]
  arepl ${location}$num $terminalForm terminalFormsAList
  arepl ${location}puts $terminalFormsAList pirNode($nodePirNodeIndex)
}

  
## get edge type (edgesFrom [node bottom] or edgesTo [node top]) and
## terminal button index
## 06may98 wmt: new
proc getEdgeTypeAndIndexFromButtonPath { buttonPath indexRef typeRef } {
  upvar $indexRef index
  upvar $typeRef type

  set type edgesTo
  if {[regexp ".out." $buttonPath]} {
    set type edgesFrom
  }
  set pos [string last "." $buttonPath]
  set index [expr {[string range $buttonPath [expr $pos + 2] end] - 1}]
  # puts stderr "getEdgeTypeAndIndexFromButtonPath: $buttonPath index $index type $type"
}

## get perm balloon window pathname and root window name from
## button pathname
## 14aug99 wmt: new
proc getPermBalloonWindows { pirNodeIndex balloonWindowRef \
                                 rootWindowRef xOffsetRef yOffsetRef \
                                 { buttonPath {} } } {
  upvar $balloonWindowRef balloonWindow
  upvar $rootWindowRef rootWindow
  upvar $xOffsetRef xOffset
  upvar $yOffsetRef yOffset
  global pirNode

  set balloonWindow [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set window [assoc window pirNode($pirNodeIndex)]
  set xOffset 0; set yOffset 0
  if {! [string match [assoc nodeClassType pirNode($pirNodeIndex)] \
             "terminal"]} {
    getLocation&NumFromButton $buttonPath location num
    append balloonWindow "-${location}-${num}"
    set rootWindow $window.${location}.b${num}
    set xOffset [winfo width $rootWindow]
    set yOffset [expr { ( 3 * $num) * [winfo height $rootWindow]}]
    if {[string match $location "in"]} {
      set yOffset [expr { - ((( 3 * $num) * [winfo height $rootWindow]) + 4)}] 
    } else {
      set yOffset [expr { ((( 3 * $num) - 1) * [winfo height $rootWindow]) - 2}] 
    }
  } else {
    if {[string match [assoc nodeClassName pirNode($pirNodeIndex)] \
             "output"]} {
      set rootWindow $window.in.b1
      set yOffset [expr { - ( 3 * [winfo height $rootWindow])}]
    } else {
      set rootWindow $window.out.b1
      set yOffset [expr { 2 * [winfo height $rootWindow]}] 
    }
    set xOffset [winfo width $rootWindow]
  }
}


## get terminal connector bitmap
## location => inputs => top-terminals  => terminal location designation
## location => outputs => bottom-terminals  => terminal location designation
## 21oct99 wmt: new
proc getTerminalButtonBitmap { terminalForm location } {
  global STANLEY_ROOT

  if {[lsearch -exact [list inputs outputs] $location] == -1} {
    error "getTerminalButtonBitmap: location $location not handled"
  }
  # puts stderr "getTerminalButtonBitmap: terminalForm $terminalForm"
  set reportNotFoundP 0
  set terminalDirection [getTerminalDirection $terminalForm]
  set interfaceType [assoc interfaceType terminalForm $reportNotFoundP]
  # default is public -- interfaceType == ""
  if {[string match $interfaceType "public"] || \
          [string match $interfaceType ""]} {
    # public terminal - inheritable to the next level up
    if {[string match $terminalDirection "in"]} {
      if {[string match $location inputs]} {
        set bitmap @$STANLEY_ROOT/src/bitmaps/downtriangle
      } else {
        set bitmap @$STANLEY_ROOT/src/bitmaps/uptriangle
      }
    } elseif {[string match $terminalDirection "out"]} {
      if {[string match $location inputs]} {
        set bitmap @$STANLEY_ROOT/src/bitmaps/uptriangle
      } else {
        set bitmap @$STANLEY_ROOT/src/bitmaps/downtriangle
      }
    } elseif {[string match $terminalDirection "port"]} {
      set bitmap @$STANLEY_ROOT/src/bitmaps/ball
    } else {
      set str "getTerminalButtonBitmap: terminalDirection"
      error "$str $terminalDirection not handled\!"
    }
  } elseif {[string match $interfaceType "private"]} {
    # private terminal - not inheritable
    if {[string match $terminalDirection "in"]} {
      if {[string match $location inputs]} {
        set bitmap @$STANLEY_ROOT/src/bitmaps/downtriangle-private
      } else {
        set bitmap @$STANLEY_ROOT/src/bitmaps/uptriangle-private
      }
    } elseif {[string match $terminalDirection "out"]} {
      if {[string match $location inputs]} {
        set bitmap @$STANLEY_ROOT/src/bitmaps/uptriangle-private
      } else {
        set bitmap @$STANLEY_ROOT/src/bitmaps/downtriangle-private
      }
    } elseif {[string match $terminalDirection "port"]} {
      set bitmap @$STANLEY_ROOT/src/bitmaps/circle
    } else {
      set str "getTerminalButtonBitmap: terminalDirection"
      error "$str $terminalDirection not handled\!"
    }
  } else {
    error "getTerminalButtonBitmap: interfaceType $interfaceType not handled\!"
  }
  return $bitmap
}
       

## configure terminal button bitmap
## assumes that terminalForm is obtained from pirNode structure
## 21oct99 wmt: new
proc configureTerminalButtonBitmap { buttonPath {terminalForm ""} } {
  global pirNode

  getLocation&NumFromButton $buttonPath location num
  if {[string match $terminalForm ""]} {
    set nodePirNodeIndex [getPirNodeIndexFromButtonPath $buttonPath]
    set terminalFormsAList [assoc ${location}puts pirNode($nodePirNodeIndex)]
    set terminalForm [assoc ${location}$num terminalFormsAList]
  }
  if {[string match $location "in"]} {
    $buttonPath config \
        -bitmap [getTerminalButtonBitmap $terminalForm inputs] \
        -anchor c
  } else {
    $buttonPath config \
        -bitmap [getTerminalButtonBitmap $terminalForm outputs] \
        -anchor c
  }
}


## for terminal button, set terminalForm interfaceType, 
## change button bitmap, and update the balloonhelp
## do this only for component/module terminal buttons (creating/deleting
## edges), unless toggleP is 1 -- which is user request from Mouse-R menu
## 21oct99 wmt: new
proc setTerminalButtonInterfaceType { buttonPath interfaceType {toggleP 0} } {
  global pirNode

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "setTerminalButtonInterfaceType: `$backtrace'"
  getLocation&NumFromButton $buttonPath location num
  set buttonPathPirNodeIndex [getPirNodeIndexFromButtonPath $buttonPath]
  # check that node still exists
  if {$buttonPathPirNodeIndex != ""} {
    set nodeInstanceName [assoc nodeInstanceName pirNode($buttonPathPirNodeIndex)]
    # puts stderr "setTerminalButtonInterfaceType: nodeInstanceName $nodeInstanceName"
    # check for node having been deleted
    if {! [string match $buttonPathPirNodeIndex ""]} {
      #   set str "setTerminalButtonInterfaceType: buttonPath $buttonPath"
      #   puts stderr "$str buttonPathPirNodeIndex $buttonPathPirNodeIndex"
      set nodeClassType [assoc nodeClassType pirNode($buttonPathPirNodeIndex)] 
      if {((! $toggleP) && (! [string match $nodeClassType "terminal"])) || \
              $toggleP} {
        set nodeClassName [assoc nodeClassName pirNode($buttonPathPirNodeIndex)] 
        set window [assoc window pirNode($buttonPathPirNodeIndex)] 
        set terminalForm [getTerminalFormFromButtonPath $buttonPath]
        if {! [string match [assoc interfaceType terminalForm] $interfaceType]} {
          arepl interfaceType $interfaceType terminalForm 
          setTerminalFormOfButtonPath $buttonPath $terminalForm
          configureTerminalButtonBitmap $buttonPath $terminalForm
          # update balloon help
          callTerminalBalloonHelp terminalForm $nodeClassType $nodeClassName \
              $window $location $num
          mark_scm_modified
        }
      }
    }
  }
}


## 01nov99 wmt: new
proc getTerminalButtonInterfaceType { buttonPath } {

  set terminalForm [getTerminalFormFromButtonPath $buttonPath]
  return [assoc interfaceType terminalForm]
}


## toggle the terminal button interfaceType between public/private
## for nodeClassType terminal component module
## 01nov99 wmt: new
proc toggleButtonInterfaceType { buttonPath } {

  set interfaceType [getTerminalButtonInterfaceType $buttonPath]
  set toggleP 1
  if {[string match $interfaceType "public"]} {
    set newInterfaceType "private"
  } else {
    set newInterfaceType "public"
  }
  setTerminalButtonInterfaceType $buttonPath $newInterfaceType \
      $toggleP 
} 


## get pirEdgeIndex from inbut and output
## 20feb96 wmt: new - abstracted from unmkEdge
## 21may96 wmt: handle port edges
## 06dec97 wm: make this smarter - figure out direction of terminal buttons
proc getEdgeIndexFromButtons { inbut outbut } {
  global pirNode

  # puts stderr "getEdgeIndexFromButtons: inbut $inbut outbut $outbut"
  set inPirNodeIndex [getPirNodeIndexFromButtonPath $inbut]
  set outPirNodeIndex [getPirNodeIndexFromButtonPath $outbut]
  getLocation&NumFromButton $inbut inButDir inButNum
  getLocation&NumFromButton $outbut outButDir outButNum
  set inWhichEdges edgesTo
  if {[string match $inButDir out]} {
    set inWhichEdges edgesFrom
  }
  set outWhichEdges edgesFrom
  if {[string match $outButDir in]} {
    set outWhichEdges edgesTo
  }
  set inindex [pirButtonNum $inbut $inButDir]
  set outindex [pirButtonNum $outbut $outButDir]
  # set str "getEdgeIndexFromButtons inPirNodeIndex $inPirNodeIndex"
  # puts stderr "$str outPirNodeIndex $outPirNodeIndex"
  # puts stderr "getEdgeIndexFromButtons inindex $inindex outindex $outindex"
  set edgesToList [lindex [assoc $inWhichEdges pirNode($inPirNodeIndex)] $inindex]
  set edgesFromList [lindex [assoc $outWhichEdges pirNode($outPirNodeIndex)] $outindex]
  # puts "getEdgeIndexFromButtons edgesToList $edgesToList"
  # puts "getEdgeIndexFromButtons edgesFromList $edgesFromList"
  set pirEdgeIndex 0
  foreach edge_from $edgesFromList {
    foreach edge_to $edgesToList {
      if {$edge_from == $edge_to} {
        set pirEdgeIndex $edge_from
        break
      }
    }
  }
  return $pirEdgeIndex
}









