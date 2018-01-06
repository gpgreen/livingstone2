# $Id: layout.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## layout.tcl: layout support for Application Builder
##   Global variables:
##     pirDisplay -- parameters pertaining the to the entire view
##     pirNodes, pirEdges -- lists of all node and edge items
##     pirWireFrame -- used in moving nodes around the canvas
##   Node alists: pirNode(n) = an alist containing these fields: (& = optional)
##   Edge alists: pirEdge(e) = an alist containing these fields: (& = optional)
##     

## NODE TERMINAL NAMING CONVENTIONS
##
## pirNode array element attributes
## --------------------------------
## inputs => top-terminals  => terminal location designation
## outputs => bottom-terminals  => terminal location designation
##         example inputs/outputs forms: 
## in1 {type {IN ON-OFF-VALUES} terminal_name {(POWER-IN C1)} terminal_label {}}
##      in1 => first or leftmost location on top of node
##      IN  => terminal direction
## in2 {type {OUT ON-OFF-VALUES} terminal_name {(STATUS-OUT C1)} terminal_label {}}
##      in2 => second location on top of node
##      OUT  => terminal direction
##
##      edgesTo   => edgesTop    => edges (pirEdgeIndex) at top of node
##      edgesFrom => edgesBottom => edges (pirEdgeIndex) at bottom of node
##
## inputLabels & outputLabels MAY NOT BE NEEDED ANYMORE
##
## terminal button widget naming conventions 
## -----------------------------------------
##
## .in. => .top. => button is on top of node
## .out. => .bottom. => button is on bottom of node
##      example
## .master.canvas.?name.c.w4.out.b1
##      first or leftmost button on bottom of node whose window is w4
## .master.canvas.?name.c.w35.in.b1
##      first or leftmost button on top of node whose window is w35
##
## pirEdge array element attributes
## --------------------------------
##
## nodeTo     => pirNodeIndex of node to which connection goes
## nodeFrom   => pirNodeIndex of node from which connection comes
## buttonTo   => button widget to which connection goes
## buttonFrom => button widget from which connection comes
##
## ------------------------------------------------------------
## ------------------------------------------------------------


## return a window representing a node
## 09oct95 wmt: top half of window => label, bottom half => node state
## 11oct95 wmt: add icon_classes => make bottom half an icon
## 19oct95 wmt: remove labelWidth from arg list
## 25oct95 wmt: add  -highlightthickness 0 to all widgets (Tk4.0)
## 16may96 wmt: add support for ports on the "out" side of the icon
## 03jun96 wmt: added  nodeClassType arg
## 23jul96 wmt: added g_NM_pendingModelModsByClass
## 27sep96 wmt: add terminal_class processing
## 13may97 wmt: add call to uniqueWindowName to prevent duplicate windows
proc mkNodeIcon { canvas label numInputs numOutputs nodeState nodeClassName \
    inputsList outputsList nodeClassType childAttributesP iconLabelRef} {
  upvar $iconLabelRef iconLabel
  global STANLEY_ROOT g_NM_terminalNodeWidth 
  global g_NM_schematicMode g_NM_IPCp g_NM_nodeTypesHaveIcons 
  global g_NM_nodeHasIconP g_NM_vmplTestModeP 

  set reportNotFoundP 0; set iconLabel ""
  set winname [uniqueWindowName $canvas]
  if {! [winfo exists $canvas]} {
    # if canvas does not exist, create it
    # strip off the trailing ".c"
    set overlayP 0; set createOnlyP 1
    set index [string last "." $canvas]
    set canvasRoot [string range $canvas 0 [expr {$index - 1}]]
    # puts stderr "\nmkNodeIcon: create canvas $canvas"
    createCanvas $canvasRoot 0 0 $overlayP $createOnlyP 
  }
  # puts stderr "mkNodeIcon: nodeClassType $nodeClassType nodeClassName $nodeClassName"
  # puts stderr "mkNodeIcon: label $label nodeState $nodeState"
  if {[string match $nodeClassType "terminal"]} {
    set iconFile $STANLEY_ROOT/src/bitmaps/terminal-node
    if {[regexp "DECLARATION" $nodeClassName]} {
      set nodeBackgroundColor [preferred NM_terminalDeclNodeBgColor]
    } else {
      set nodeBackgroundColor [preferred StanleyTerminalNodeBgColor]
    }
  } elseif {[string match $nodeClassType "attribute"]} {
    set iconFile $STANLEY_ROOT/src/bitmaps/attribute-node
    set nodeBackgroundColor [preferred StanleyAttributeNodeBgColor]
  } elseif {[string match $nodeClassType "component"]} {
    set iconFile [lindex [preferred STANLEY_USER_DIR] 0]/bitmaps/$nodeClassName
    set nodeBackgroundColor [preferred StanleyComponentNodeBgColor]
  } elseif {[string match $nodeClassType "mode"]} {
    if {[string match $nodeClassName "okMode"]} {
      set iconFile $STANLEY_ROOT/src/bitmaps/okMode-node
      set nodeBackgroundColor [preferred StanleyOkModeNodeBgColor]
    } else {
      set iconFile $STANLEY_ROOT/src/bitmaps/faultMode-node
      set nodeBackgroundColor [preferred StanleyFaultModeNodeBgColor]
    }
  } elseif {[string match $nodeClassType "module"]} {
    set iconFile [lindex [preferred STANLEY_USER_DIR] 0]/bitmaps/$nodeClassName
    set nodeBackgroundColor [preferred StanleyModuleNodeBgColor]
  } else {
    set iconFile ""
    set nodeBackgroundColor [preferred StanleyComponentNodeBgColor] 
  }
  # puts stderr "nodeClassType $nodeClassType"
  set g_NM_nodeHasIconP 0
  set nodeForegroundColor [preferred StanleyNodeLabelForegroundColor]
  set imageForegroundColor $nodeForegroundColor 
  set imageBackgroundColor $nodeBackgroundColor 
  set nodeSelectColor [preferred StanleySelectedColor]
  # puts stderr "mkNodeIcon: iconFile $iconFile existsP [file exists $iconFile]"
  if {(! [string match $nodeState "parent-link"]) && [file exists $iconFile]} {
    set g_NM_nodeHasIconP 1
    # puts stderr "mkNodeIcon: label $label g_NM_nodeHasIconP $g_NM_nodeHasIconP"
    # hack to get around bug which leaves a horizontal line, 1 pixel thick
    # at bottom of rectangle tcl/tk 8.0.3
    set canvasBgColor [preferred StanleySchematicCanvasBackgroundColor]
    if {$g_NM_vmplTestModeP} {
      set canvasBgColor [preferred StanleyTestCanvasBackgroundColor]
    }
    option add *Frame.background $canvasBgColor
    set nodeBackgroundColor $canvasBgColor
    frame $canvas.$winname -borderwidth 0 -relief flat -highlightthickness 0 \
        -background $canvasBgColor
  } elseif {[string match $nodeClassType "module"] || \
                [string match $nodeClassType "component"]} {
    frame $canvas.$winname -relief flat -highlightthickness 1 \
        -highlightbackground black
  } else {
    puts stderr "mkNodeIcon: nodeClassType $nodeClassType not handled\!"
  }
  frame $canvas.$winname.in  -background $nodeBackgroundColor \
      -bd 0 -highlightthickness 0
  if {(! [string match $nodeClassType "terminal"]) && \
          (! [string match $nodeClassType "attribute"])} {
    button $canvas.$winname.in.left -bitmap @$STANLEY_ROOT/src/bitmaps/empty \
        -relief flat -bd 0.0 -pady 0.0 -highlightthickness 0 \
        -background $nodeBackgroundColor 
    
    pack $canvas.$winname.in.left -side left -fill x -expand 1;
  }
  # puts stderr "mkNodeIcon: inputsList $inputsList"
  for {set i 1} {$i <= $numInputs} {incr i} {
    set terminalList [assoc in$i inputsList]
    # puts stderr "mkNodeIcon: in i $i label $label terminalList $terminalList"
    button $canvas.$winname.in.b$i \
        -bitmap [getTerminalButtonBitmap $terminalList inputs] \
        -relief flat -activebackground $nodeSelectColor \
        -borderwidth -0.0 -padx 2.0 -pady 0.0 -highlightthickness 0 \
        -width $g_NM_terminalNodeWidth -fg $nodeForegroundColor \
        -activeforeground $nodeForegroundColor \
        -background $nodeBackgroundColor  -height 4 -anchor c
    pack $canvas.$winname.in.b$i -side left -fill x -expand 1;
    # <Button-1> binding is now done in mkNode
    # bind $canvas.$winname.in.b$i <Shift-ButtonPress-1> \
    #     "nodeInSelectShift $canvas.$winname.in.b$i"
  }
  if {(! [string match $nodeClassType "terminal"]) && \
          (! [string match $nodeClassType "attribute"])} {
    button $canvas.$winname.in.right -bitmap @$STANLEY_ROOT/src/bitmaps/empty \
        -relief flat -bd 0.0 -pady 0.0 -highlightthickness 0 \
        -background $nodeBackgroundColor 
    pack $canvas.$winname.in.right -side left -fill x -expand 1;
  }
  frame $canvas.$winname.lab  -background $nodeBackgroundColor  \
      -borderwidth 0 -highlightthickness 0 -relief flat
  if {[string match $nodeClassType "module"] && \
          [string match $nodeState "parent-link"]} {
    # strip off unique integer appended to _P and the _P
    set label [getModuleParentLinkLabel $label]
  } elseif {[string match $nodeClassType "terminal"]} {
    # strip off unique suffix of declarations & terminators
    set label [getTerminalLabel $label]
  }
  # puts stderr "mkNodeIcon: label $label"
  set text " $label "
  label $canvas.$winname.lab.label -text $text -anchor c \
      -font [preferred StanleyTerminalTypeFont] \
      -highlightthickness 0 -fg $nodeForegroundColor -wraplength 60i
  ## -wraplength 60i -> donot wrap long labels
  set bitmapP 0
  if {([lsearch -exact $g_NM_nodeTypesHaveIcons $nodeClassType] >= 0) && \
          $g_NM_nodeHasIconP} {
    set image [image create bitmap -file $iconFile -maskfile ${iconFile}-mask \
                   -foreground $imageForegroundColor -background $imageBackgroundColor]
    set bitmapP 1
  }
  if {$bitmapP} {
    # allow select color to show around terminals
    set borderwidth 2
    if {[string match $nodeClassType "mode"]} {
      set borderwidth 0
    }
    label $canvas.$winname.lab.icon -image $image -anchor c \
        -foreground $nodeForegroundColor -borderwidth $borderwidth \
        -relief flat -highlightthickness 0 -background $nodeBackgroundColor
    pack $canvas.$winname.lab.icon -side left -fill both -expand 1
    # creating a canvas text object for the icon label must
    # be done in mkNode after the node window is added to the canvas
    set iconLabel $label 
  } else {
    if {(! [string match $nodeClassType "terminal"]) && \
            (! [string match $nodeClassType "attribute"])} {
      drawFiller $canvas.$winname.lab
      pack $canvas.$winname.lab.icon $canvas.$winname.lab.label \
          -side top -fill both -expand 1
    } else {
      pack $canvas.$winname.lab.label -side top -fill both -expand 1
    }
  }
  frame $canvas.$winname.out  -background $nodeBackgroundColor \
      -borderwidth 0 -highlightthickness 0 -relief flat  
  if {! [string match $nodeClassType "terminal"]} {
    button $canvas.$winname.out.left -bitmap @$STANLEY_ROOT/src/bitmaps/empty \
        -relief flat -bd 0.0 -pady 0.0 -highlightthickness 0 \
        -background $nodeBackgroundColor 
    pack $canvas.$winname.out.left -side left -fill x -expand 1;
  }
  # puts stderr "mkNodeIcon: numOutputs $numOutputs outputsList $outputsList"
  for {set i 1} {$i <= $numOutputs} {incr i} {
    set terminalList [assoc out$i outputsList]
    if {[string match $nodeClassType "attribute"]} {
      set bitmap @$STANLEY_ROOT/src/bitmaps/square
    } else { 
      set bitmap [getTerminalButtonBitmap $terminalList outputs]
    }
    # puts stderr "mkNodeIcon: out i $i label $label terminalList $terminalList"
    button $canvas.$winname.out.b$i \
      -bitmap $bitmap -relief flat -activebackground $nodeSelectColor \
        -bd 0 -padx 2.0 -pady 0 -borderwidth 0 -highlightthickness 0 \
        -width $g_NM_terminalNodeWidth -fg $nodeForegroundColor \
        -activeforeground $nodeForegroundColor \
        -background $nodeBackgroundColor -height 4 -anchor c
    pack $canvas.$winname.out.b$i -side left -fill x -expand 1
  }
  if {(! [string match $nodeClassType "terminal"])} {
    if {[string match $g_NM_schematicMode "layout"] && $childAttributesP} {
      set bitmap @$STANLEY_ROOT/src/bitmaps/square
    } else {
      set bitmap @$STANLEY_ROOT/src/bitmaps/empty
    }
    button $canvas.$winname.out.right -bitmap $bitmap \
        -relief flat -bd 0.0 -pady 0.0 -highlightthickness 0 \
        -fg [preferred StanleyAttributeNodeBgColor] -anchor e \
        -activeforeground $nodeSelectColor \
        -background $nodeBackgroundColor 
    pack $canvas.$winname.out.right -side left -fill x -expand 1 
  }

  pack $canvas.$winname.in -side top -fill x
  ##  pack $canvas.$winname.lab $canvas.$winname.out -side top -fill x
  pack $canvas.$winname.lab -side top -fill x
  pack $canvas.$winname.out -side bottom  -fill x

  if {$g_NM_nodeHasIconP} {
    # undo hack to get around bug which leaves a horizontal line, 1 pixel thick
    # at bottom of rectangle
    option add *Frame.background [preferred StanleyMenuDialogBackgroundColor]
  }
  # puts stderr "mkNodeIcon: label $label winpath $canvas.$winname"
  return "$canvas.$winname"
}


## set up motion of a node using wire-frame graphics
## node can also be the nodes label, which is also a window
proc nodeStartMotion {canvas winpath x y} {
  global pirDisplay pirNodes pirEdges  pirNode pirEdge
  global pirWireFrame g_NM_canvasGroupNodeDeleteP

  if {[componentModuleDefReadOnlyP] || \
          $g_NM_canvasGroupNodeDeleteP} {
    # do not reset deleting a group of nodes/edges with Mouse-L: drag
    return
  }
  # force creation of wire rectangle after cursor moves from off
  # Stanley window, on to it
  canvasB1Release [getCanvasRootInfo g_NM_currentCanvas 0].c $x $y
  # puts stderr "nodeStartMotion: $canvas $winpath $x $y"
  # save the original cursor coordinates for the final move
  set pirWireFrame(curX) $x
  set pirWireFrame(curY) $y  
  scan [winfo geometry $winpath] "%dx%d+%d+%d" width height xx yy
  set xx [$canvas canvasx $xx]
  set yy [$canvas canvasy $yy]
  set pirWireFrame(width) $width
  set pirWireFrame(height) $height
  set pirWireFrame(x) $x
  set pirWireFrame(y) $y
  set pirWireFrame(item) \
      [$canvas create rectangle $xx $yy [expr {$xx+$width}] [expr {$yy+$height}] \
           -tags wire -outline [preferred StanleyRubberBandColor]]
}

  
## execute node motion. Move the "wire frame" only.
## node can also be the nodes label, which is also a window
## 20feb96 wmt: allow multiple input terminals
proc nodeMotion {canvas x y} {
  global pirDisplay pirNodes pirEdges  pirNode pirEdge
  global pirWireFrame g_NM_processingNodeGroupP

  if {[componentModuleDefReadOnlyP]} {
    return
  }
  if {! [info exists pirWireFrame(item)]} {
    return
  }
  set distX [expr {$x-$pirWireFrame(x)}]
  set distY [expr {$y-$pirWireFrame(y)}]
  # puts stderr "nodeMotion: $canvas  x $x y $y distX $distX distY $distY"
  $canvas move $pirWireFrame(item) $distX $distY
  update
  set pirWireFrame(x) $x
  set pirWireFrame(y) $y
} 


## nodeMotionRelease -- actually move the node and delete the
##   wire frame
## node can also be the nodes label, which is also a window
## 14oct95 wmt: snap x & y to grid - 1st try
## 01nov95 wmt: snap to grid works
## 07mar96 wmt: add g_NM_snapToGridOn
## 01jul96 wmt: implement multiple canvases - add arg: pirNodeIndex
## 07oct96 wmt: set g_NM_processingNodeGroupP to prevent
##              connectDefmoduleDeclTerminal from being called
##              when the edges to this node are redrawn
## 17jul97 wmt: handle transitions of component modes
## 20feb98 wmt: g_NM_snapToGridOn works on both x & y
proc nodeMotionRelease {canvas canvasId pirNodeIndex x y} {
  global pirDisplay pirNodes pirEdges  pirNode pirEdge
  global pirWireFrame g_NM_snapToGridOn g_NM_processingNodeGroupP
  global g_NM_win32P 

  set jmplModifiedP 0
  if {[componentModuleDefReadOnlyP]} {
    return
  }
  if {! [info exists pirWireFrame(item)]} {
    return
  }
  set objectType node
  if {[lindex [$canvas itemconfigure $canvasId -tags] 4] == \
          "iconLabels"} {
    set objectType label
  }
  # set str "nodeMotionRelease $canvas $canvasId $x $y. From"
  # puts stderr "$str $pirWireFrame(curX) $pirWireFrame(curY). "
  set labelReportNotFoundP 0
  set g_NM_processingNodeGroupP 1
  $canvas delete wire
  catch { unset pirWireFrame(item) }
  set distX [expr {$x - $pirWireFrame(curX)}]
  set distY [expr {$y - $pirWireFrame(curY)}]
  # puts stderr "nodeMotionRelease: distX $distX distY $distY"
  $canvas move $canvasId $distX $distY
  if {$objectType == "node"} {
    # also move node icon label
    set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $labelReportNotFoundP]
    if {$labelCanvasId != ""} {
      $canvas move $labelCanvasId $distX $distY 
    }
  }
  if {$objectType == "node"} {
    set nodeX [expr {$distX + [assoc nodeX pirNode($pirNodeIndex)]}]
    set nodeY [expr {$distY + [assoc nodeY pirNode($pirNodeIndex)]}]
  } else {
    set nodeX [expr {$distX + [assoc labelX pirNode($pirNodeIndex)]}]
    set nodeY [expr {$distY + [assoc labelY pirNode($pirNodeIndex)]}]
  }
  if {($objectType == "node") && $g_NM_snapToGridOn} {
    set nodeX1 [snapToGrid $nodeX "x"]
    set nodeY1 [snapToGrid $nodeY "y"]
    set distX2 [expr {$nodeX1 - $nodeX}]
    set distY2 [expr {$nodeY1 - $nodeY}] 
    # puts stderr "nodeMotionRelease: after snap distX2 $distX2 distY2 $distY2"
    $canvas move $canvasId $distX2 $distY2
    # also move node icon label
    if {$labelCanvasId != ""} {
      $canvas move $labelCanvasId $distX2 $distY2
    }

    # puts [format "nodeMotionRelease: nodeX %d newNodeX %d nodeY %d newNodeY %d"
    #      $nodeX $nodeX1 $nodeY $nodeY1]
    set nodeX $nodeX1
    set nodeY $nodeY1
  } else {
    set distX2 0; set distY2 0
  }

  if {(($distX + $distX2) != 0) || (($distY + $distY2) != 0)} {
    # only mark modified if the node net location change is non-zero
    mark_scm_modified $jmplModifiedP 

    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
    }

    if {$objectType == "node"} {
      arepl nodeX $nodeX pirNode($pirNodeIndex)
      arepl nodeY $nodeY pirNode($pirNodeIndex)
      # also reset label location
      set labelX [assoc labelX pirNode($pirNodeIndex)]
      arepl labelX [expr {$labelX + $distX + $distX2}] pirNode($pirNodeIndex)
      set labelY [assoc labelY pirNode($pirNodeIndex)]
      arepl labelY [expr {$labelY + $distY + $distY2}] pirNode($pirNodeIndex)
      # puts stderr "nodeMotionRelease A nodeX $nodeX nodeY $nodeY"
      update; # tricky: need to update display to pick up the new window coords

      updateEdgeLocations $canvas $pirNodeIndex 

      # move component mode transitions, if needed
      if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
               mode]} {
        moveModeTransitions $canvas $pirNodeIndex 
      }
    } else {
      arepl labelX $nodeX pirNode($pirNodeIndex)
      arepl labelY $nodeY pirNode($pirNodeIndex)
    }
    if {! $g_NM_win32P} {
      .master.canvas config -cursor top_left_arrow
    }
  }
  set g_NM_processingNodeGroupP 0
  update
}


## redraw an edge during a nodeMotionRelease operation
## 20feb96 wmt: inhibit type mismatch dialog when calling
##              mkEdge
## 18mar96 wmt: pass numBreaks to mkEdge to prevent dialog
##              asking for 2 or 4 breaks
## 21may96 wmt: handle port edges
proc edgeMove { canvas pirEdgeIndex pirNodeIndex } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_inhibitEdgeTypeMismatchP

  set yBuffer 0
  # puts stderr "\nedgeMove: canvas $canvas pirEdgeIndex $pirEdgeIndex"
  # puts stderr "    pirNodeIndex $pirNodeIndex"
  set reportNotFoundP 0; set checkTypesP 0
  # redraw outedge
  if {! $pirEdgeIndex} return;  # 0 edges are dummies
  set portEdgeType [isThisAPortEdge $pirEdgeIndex]
  set buttonTo [assoc buttonTo pirEdge($pirEdgeIndex)]
  set buttonFrom [assoc buttonFrom pirEdge($pirEdgeIndex)]
  set documentation [assoc documentation pirEdge($pirEdgeIndex)]
  set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
  set interimXYList [assoc interimXYList pirEdge($pirEdgeIndex)]
  # puts stderr "edgeMove: interimXYList $interimXYList"
  set numBreaks 2; set interimY 0; set interimY1 0; set interimY2 0
  if {[assoc interimX interimXYList $reportNotFoundP] != ""} {
    set numBreaks 4
    set interimY1 [assoc interimY1 interimXYList]
    set interimY2 [assoc interimY2 interimXYList]
  } else {
    set interimY [assoc interimY interimXYList]
  }
  # preserve edge color & propSelectedP 
  set edgeCanvasId [assoc canvasId pirEdge($pirEdgeIndex)]
  set edgeColor [lindex [$canvas itemconfigure $edgeCanvasId -fill] 4]

  cutEdge $canvas $pirEdgeIndex
  set g_NM_inhibitEdgeTypeMismatchP 1
  # pass interimXYList as {} to force the calculation of a new break
  # NO, use the existing interimXYList -- unless the new position
  # has moved past the interimY values (interimY2 interimY1)
  # then recompute them
  ## NO - do not compute new postion, keep user specified position
#   set upperNodeY [assoc nodeY pirNode($pirNodeIndex)]
#   set window [assoc window pirNode($pirNodeIndex)]
#   set windowHeight [winfo height $window]
#   set lowerNodeY [expr $upperNodeY + $windowHeight + $yBuffer]
#   set upperNodeY [expr $upperNodeY - $yBuffer]
#   # set str "edgeMove: upperNodeY $upperNodeY windowHeight"
#   # puts stderr "$str $windowHeight lowerNodeY $lowerNodeY"
#   # now determine whether interimY2 interimY1 should be lower or higher than
#   # upperNodeY & lowerNodeY
#   getTerminalLocations $canvas $buttonTo $buttonFrom inCanvasX inCanvasY \
#       outCanvasX outCanvasY 
#   # puts stderr "edgeMove: out xy $outCanvasX $outCanvasY in xy $inCanvasX $inCanvasY"
#   if {[expr $upperNodeY > $outCanvasY]} {
#     if {$interimY == 0} {
#       set interimY1 [expr $interimY1 + $yBuffer]
#       set interimY2 [expr $interimY2 + $yBuffer]
#       if {[expr $upperNodeY < $interimY2]} {
#         arepl interimY2 0 interimXYList 
#       }
#       if {[expr $upperNodeY < $interimY1]} {
#         set interimXYList {} 
#       }
#     } else {
#       set interimY [expr $interimY + $yBuffer]
#       if {[expr $upperNodeY < $interimY]} {
#         set interimXYList {}
#       }
#     }
#   } else {
#     if {$interimY == 0} {
#       set interimY1 [expr $interimY1 - $yBuffer]
#       set interimY2 [expr $interimY2 - $yBuffer]
#       if {[expr $lowerNodeY > $interimY1]} {
#         arepl interimY1 0 interimXYList 
#       }
#       if {[expr $lowerNodeY > $interimY2]} {
#         set interimXYList {} 
#       }
#     } else {
#       set interimY [expr $interimY - $yBuffer]
#       if {[expr $lowerNodeY > $interimY]} {
#         set interimXYList {}
#       }
#     }
#   }
  # puts stderr "edgeMove: interimXYList $interimXYList"
  set newedge \
      [mkEdge $buttonTo $buttonFrom $numBreaks $interimXYList $portEdgeType \
           $canvas $checkTypesP $documentation $abstractionType $edgeColor]

  set g_NM_inhibitEdgeTypeMismatchP 0
}


## redraw connections (edges) to align appropriate terminal button
## and connection link, because 1) component/module with its
## terminals has moved; 2) component/module label name has changed
## length and hence button locations; and 3) label font has changed
## due to user Preferences selection
## 04mar98 wmt: new
proc updateEdgeLocations { currentCanvas pirNodeIndex } {
  global pirNode 

  set templist [assoc edgesFrom pirNode($pirNodeIndex)]
  # puts stderr "updateEdgeLocations: edgesFrom $templist"
  foreach e1 $templist { 
    foreach e $e1 {
      if {$e} {
        edgeMove $currentCanvas $e $pirNodeIndex 
      }
    }
  }
  set templist [assoc edgesTo pirNode($pirNodeIndex)]
  # puts stderr "updateEdgeLocations: edgesTo $templist"
  foreach e1 $templist {
    foreach e $e1 {
      if {$e} {
        edgeMove $currentCanvas $e $pirNodeIndex 
      }
    }
  }
}


## invoke updateEdgeLocations for all canvases: master and slave
## 04mar98 wmt: new
proc updateEdgeLocationsAll { masterCanvas pirNodeIndex } {
  global g_NM_canvasRootIdCnt pirNode 

  # set str "updateEdgeLocationsAll: masterCanvas $masterCanvas"
  # puts stderr "$str pirNodeIndex $pirNodeIndex"
  for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId} {
    set canvas [convertCanvasPath $masterCanvas $canvasRootId]
    # puts stderr "updateEdgeLocationsAll: canvas $canvas"
    updateEdgeLocations $canvas $pirNodeIndex 
  }
}

## get the fg and bg node colors, if specified (defaults if not), and
## reconfigure the node. The bgColor and fgColor fields in the node alist
## will have already been set by the caller.
## 09oct95 wmt: modified to use nodeStateBgColor, nodePower
## 29sep96 wmt: add nodeClassType = terminal
proc node_color_config { window nodeAlistName numInputs numOutputs } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_schematicMode g_NM_classDefType g_NM_instanceToNode
  upvar $nodeAlistName nodeAlist
  global g_NM_nodeTypesHaveIcons STANLEY_ROOT g_NM_vmplTestModeP

  set nodeForegroundColor [preferred StanleyNodeLabelForegroundColor] 
  $window.lab.label config -fg $nodeForegroundColor 

  set stateBg [assoc nodeStateBgColor nodeAlist]
  set nodeBackgroundColor $stateBg 
  set nodeClassType [assoc nodeClassType nodeAlist]
  set nodeClassName [assoc nodeClassName nodeAlist]
  set nodeInstanceName [assoc nodeInstanceName nodeAlist]
  # puts stderr "node_color_config: nodeInstanceName $nodeInstanceName stateBg `$stateBg'"
  # puts stderr "node_color_config: nodeClassType $nodeClassType"
  # puts stderr "node_color_config: nodeHasIconP [assoc nodeHasIconP nodeAlist]"

  if {([lsearch -exact $g_NM_nodeTypesHaveIcons $nodeClassType] >= 0) && \
          [assoc nodeHasIconP nodeAlist]} {
    if {([string match $nodeClassType "component"] || \
                 [string match $nodeClassType "module"] || \
                 [string match $nodeClassType "mode"])} {
      # change background color of component and module icons due to
      # display-state attribute changes from Livingstone
      # componentModulePropChange => node_config_all => node_color_config 
      if {[string match $nodeClassType "component"] || \
              [string match $nodeClassType "module"]} {
        set iconFile [lindex [preferred STANLEY_USER_DIR] 0]/bitmaps/$nodeClassName
      } else {
        set iconFile "${STANLEY_ROOT}/src/bitmaps/${nodeClassName}-node"
      }
      set imageForegroundColor $nodeForegroundColor 
      set imageBackgroundColor $nodeBackgroundColor 
      set image [image create bitmap -file $iconFile -maskfile ${iconFile}-mask \
                     -foreground $imageForegroundColor \
                     -background $imageBackgroundColor]
      $window.lab.icon configure -image $image
    }
    # make rest of node transparent
    set stateBg [preferred StanleySchematicCanvasBackgroundColor]
    if {$g_NM_vmplTestModeP} {
      set stateBg [preferred StanleyTestCanvasBackgroundColor]
    }
  }
    
  if {$stateBg != ""} {
    set currentNodeGroup [assoc nodeGroupName nodeAlist]
    if {[string match $currentNodeGroup "root"]} {
      set groupDefType $g_NM_classDefType
    } else {
      set groupPirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
      set groupDefType [assoc nodeClassType pirNode($groupPirNodeIndex)]
    }
    $window.lab.label config -bg $stateBg
    if {! [string match $nodeClassType "attribute"]} {
      $window.lab.icon config -background $stateBg
    }
    if {(! [string match $nodeClassType "terminal"]) && \
            (! [string match $nodeClassType "attribute"])} {
      $window.in.left config -background $stateBg -activebackground $stateBg
      # color gap caused by centering the buttons
      $window.in config -background $stateBg -background $stateBg
    }
    for {set i 1} {$i <= $numInputs} {incr i} {
      # check for ?name components/modules which have not been saved 
      # and reloaded to create terminal buttons
      if {[winfo exists $window.in.b$i]} {
        $window.in.b$i config -background $stateBg 
#         if {[string match $groupDefType component] && \
#                 ([string match $nodeClassType "terminal"] || \
#                      [string match $nodeClassType "attribute"])} {
#           # do not allow Enter/Leave to show selected color
#           $window.in.b$i config -activebackground $stateBg 
#         }
      }
    }
    if {(! [string match $nodeClassType "terminal"])} {
      # do not allow Enter/Leave to show selected color
      $window.out.left config -background $stateBg -activebackground $stateBg
      # color gap caused by centering the buttons
      $window.out config -background $stateBg -background $stateBg
      if {[string match $nodeClassType "attribute"]} {
        set fgColor $stateBg
      } else {
        set fgColor [preferred StanleyAttributeNodeBgColor]
      }
      # this is an square representing child attributes of components & modules
      # show selected color 
      $window.out.right config -background $stateBg -activebackground $stateBg \
          -fg $fgColor 
    }
    for {set i 1} {$i <= $numOutputs} {incr i} {
      # check for ?name components/modules which have not been saved 
      # and reloaded to create terminal buttons
      if {[winfo exists $window.out.b$i]} {
        $window.out.b$i config -background $stateBg 
#         if {[string match $groupDefType component] && \
#                 ([string match $nodeClassType "terminal"] || \
#                      [string match $nodeClassType "attribute"])} {
#           # do not allow Enter/Leave to show selected color
#           $window.out.b$i config -activebackground $stateBg
#         }
      }
    }

    # make button active background go away
    #  if {[string match {operational} $g_NM_schematicMode]} {
    #    for {set i 1} {$i <= $numInputs} {incr i} {
    #      $window.in.b$i config -activebackground $stateBg
    #    }
    #    for {set i 1} {$i <= $numOutputs} {incr i} {
    #      $window.out.b$i config -activebackground $stateBg
    #    }
    #  }
    set nodePowerBg $stateBg
    ## do not set power indicator
    #  set nodePower [assoc nodePower nodeAlist]
    #  if {[string match $nodePower "ON"]} {
    #    set nodePowerBg [preferred NM_powerOnBgColor]
    #  }
    if {(! [string match $nodeClassType "terminal"]) && \
            (! [string match $nodeClassType "attribute"])} {
      $window.in.right config -background $nodePowerBg -activebackground $nodePowerBg
    }
  } else {
    set str "node_color_config: nodeStateBgColor not defined for"
    puts stderr "$str nodeInstanceName $nodeInstanceName"
  }
}


## invoke node_color_config for all canvases: master and slave
## 03sep97 wmt: new
## 04mar98 wmt: handle label font
proc node_config_all { masterWindow pirNodeIndex numInputs numOutputs \
                           type } {
  global g_NM_canvasRootIdCnt pirNode 

  if {[lsearch -exact [list color font both] $type] == -1} {
    puts stderr "node_config_all: type $type not handled\!"
    return
  }
  # puts stderr "node_config_all: masterWindow pirNodeIndex $pirNodeIndex $masterWindow"
  set canvas [getCanvasFromWindow $masterWindow]
  # puts stderr "node_config_all: master canvas $canvas"
  for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId} {
    set canvas [convertCanvasPath $canvas $canvasRootId]
    # puts stderr "node_config_all: canvas $canvas"
    if {[winfo exists $canvas]} {
      set window [getWindowPathFromPirNodeIndex $pirNodeIndex $canvas]
      # check for root parent nodes which have been "destroy"ed
      if {[winfo exists $window]} {
        # puts stderr "node_config_all: canvas $canvas window $window"
        if {[string match $type color] || [string match $type both]} {
          node_color_config $window pirNode($pirNodeIndex) $numInputs $numOutputs
        }
        if {[string match $type font] || [string match $type both]} {
           $window.lab.label configure -font [preferred StanleyComponentLabelFont]
        }
      }
    }
  }
}


## change color of mode transitions on master and slave canvases
## 04mar98 wmt: new
proc transition_color_config_all { masterCanvas lineId arrowId } {
  global g_NM_canvasRootIdCnt 

  # set str "transition_color_config_all: masterCanvas $masterCanvas"
  # puts stderr "$str pirNodeIndex $pirNodeIndex"
  for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId} {
    set canvas [convertCanvasPath $masterCanvas $canvasRootId]
    # puts stderr "transition_color_config_all: canvas $canvas"
    if {[winfo exists $canvas]} {
      # puts stderr "transition_color_config_all: canvas $canvas"
      if {$lineId != -1} {
        $canvas itemconfig $lineId -fill [preferred StanleyModeTransitionBgColor] 
      }
      $canvas  itemconfig $arrowId -fill [preferred StanleyModeTransitionBgColor] 

    }
  }
}


## change color of edges on master and slave canvases
## 04mar98 wmt: new
proc edge_color_config_all { masterCanvas pirEdgeIndex } {
  global g_NM_canvasRootIdCnt pirNode 

  # set str "edge_color_config_all: masterCanvas $masterCanvas"
  # puts stderr "$str pirNodeIndex $pirNodeIndex"
  for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId} {
    set canvas [convertCanvasPath $masterCanvas $canvasRootId]
    # puts stderr "edge_color_config_all: canvas $canvas"
    edge_color_config $canvas $pirEdgeIndex 
  }
}


## set the fill color for the edge and redraw
proc edge_color_config {canvas edge} {
  global pirEdge

  $canvas itemconfig $edge -fill [assoc fillColor pirEdge($edge)]
}


## remove the edge 
## 20feb96 wmt: allow multiple input terminals
## 21may96 wmt: handle port edges
## 29jun96 wmt: implement multiple canvases
## 21feb98 wmt: check if deleting edge is enabled
proc unmkEdge { pirEdgeIndex caller {redrawEdgeP 0} }  {
  global pirDisplay g_NM_currentCanvas g_NM_rootInstanceName 

  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [componentModuleDefReadOnlyP]} {
    return
  }
  if {($caller != "mkEdge") || \
          (($caller == "mkEdge") && [confirm "Delete connection"])} {
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
    set canvas $currentCanvas.c
    # disable terminal node selections
    deselectEdge $pirEdgeIndex 
    # puts stderr "unmkEdge: pirEdgeIndex $pirEdgeIndex"
    set ignoreEdgesFromP 0; set ignoreEdgesToP 0; set widgetsExistP 1
    set caller "unmkEdge"
    cutEdge $canvas $pirEdgeIndex $ignoreEdgesFromP $ignoreEdgesToP \
        $widgetsExistP $caller $redrawEdgeP 
  }
}


## return the pirNodeIndex corresponding to the window
## 30jun96 wmt: widget items are now .canvas.c.module.w$n
##              rather than .canvas.c.w$n
## 28aug97 wmt: now .master.canvas.module.c.w$n
proc theItemContaining {w} {
  global pirDisplay 

  error "theItemContaining: not functional"
  set temp1 [lrange [split $w "."] 0 5]
  set pirNodeIndex [assoc [join $temp1 "."] pirDisplay]
  if {$pirNodeIndex == ""} {
    error "Internal error: $w pirNodeIndex not found in pirDisplay!"
  }
  return $pirNodeIndex
}


## return the (in)(out)put index of the terminal (0 for first, 1 for second, ...)
## THIS ROUTINE REPLACED BY pirButtonNUM
##proc theEdgeIndex {button} {
##  # button is of the form: .master.canvas.c.w$n.$inout.b$k, where k is 1, 2, ...
##  set temp1 [lrange [split $button "."] 5 5]  
##  set indexnum [string trimleft $temp1 "b"]
##  if [numericp $indexnum] {
##     return [expr $indexnum-1];
##  } else {
##     error "Internal error: button $button name parse error!"
##  }
##}


## return the name of the window corresponding to node n.
## 30jun96 wmt: now simple to do
proc theNodeWindowPath {pirNodeIndex} {
  global pirNode

  ## set winconfig [.master.canvas.c itemconfig $pirNodeIndex -window]
  ## puts [format {theNodeWindowPath n %d winconfig => %s} $pirNodeIndex $winconfig]
  ## if {$winconfig != ""} {
  ##   set n [scan $winconfig "-window %*s %*s %*s %s" windowpath]
  ##   if {$pirNodeIndex} {return $windowpath} else {return ""};
  ## }
  if {$pirNodeIndex} {
    return [assoc window pirNode($pirNodeIndex)]
  } else {
    return ""
  }
}


## compute the coordinates of the edge and create the line on the canvas,
##  returning the item
## 12oct95 wmt: allow for side by side nodes by having 2 interim points
## 06mar96 wmt: replace interimY with interimXYList; interimX now absolute
## 18mar96 wmt: allow use to get 4 edge breaks, even when 2 is the default
## 29jun96 wmt: implement multiple canvases
proc drawEdge {canvas inbut innode inindex outbut outnode outindex \
                   interimXYListRef numBreaks { edgeColor "" } } {
  upvar $interimXYListRef interimXYList
  global pirDisplay pirNodes pirEdges pirNode pirEdge 

  # puts stderr "drawEdge: $canvas $inbut $innode $inindex $outbut $outnode $outindex"
  # puts stderr "drawEdge: interimXYList $interimXYList"
  set numIntermimYPoints 1; set minY 10; set minDeltaY 20
  set inCanvasX 0; set inCanvasY 0; set outCanvasX 0; set outCanvasY 0
  set reportNotFoundP 0
  if {[string match $edgeColor ""]} {
    set edgeColor [preferred StanleyNodeConnectionBgColor]
  }
      
  getTerminalLocations $canvas $inbut $outbut inCanvasX inCanvasY \
      outCanvasX outCanvasY 
  # puts stderr "drawEdge initial inCanvasY $inCanvasY outCanvasY $outCanvasY"
  if {[llength $interimXYList] == 0} {
    if {$numBreaks == 0} {
      set 2BreaksP 0
      if {($inCanvasY - $outCanvasY) > $minDeltaY} {
        set 2BreaksP 1
        set dialogList [list tk_dialog .d "CHOOSE" \
            "Do you want this connection to have 2 breaks or 4 breaks?" \
                            questhead 0 {2} {4}]
        if {[eval $dialogList] == 1} {
          set 2BreaksP 0
        }
      }
    } elseif {$numBreaks == 2} {
      set 2BreaksP 1 
    } else {
      set 2BreaksP 0
    }
  } else {
    if {[string match [assoc interimX interimXYList $reportNotFoundP] ""]} {
      set 2BreaksP 1
    } else {
      set 2BreaksP 0
    }
  }
  if {$2BreaksP} {
    set interimy [assoc interimY interimXYList $reportNotFoundP]
    if {$interimy == ""} {
      set interimy [drawEdgeInterimY $inCanvasY $outCanvasY]
      set interimXYList {}
      acons interimY $interimy interimXYList
    }
    # puts stderr "drawEdge: outCanvasY $outCanvasY interimy $interimy"
    set edge [$canvas create line $outCanvasX $outCanvasY \
                  $outCanvasX $interimy \
                  $inCanvasX  $interimy \
                  $inCanvasX  $inCanvasY  \
                  -width 2 -tags edge -fill [preferred StanleyNodeConnectionBgColor] \
                  -capstyle projecting]
  } else {
    set interimx [assoc interimX interimXYList $reportNotFoundP]
    if {$interimx == ""} {
      set diffX [expr {abs($inCanvasX - $outCanvasX) / 2}]
#       set diff_min [expr 2 * $minDeltaY]
#       if {$diff_min > $diffX} {
#         set diffX $diff_min
#       }
      if {$inCanvasX > $outCanvasX} {
        set interimx [expr {$outCanvasX + $diffX}]
      } else {
        set interimx [expr {$inCanvasX + $diffX}]
      }
      # set interimy1 [expr $outCanvasY + ($minDeltaY / 2)]
      # set interimy2 [expr $inCanvasY - ($minDeltaY / 2)]
      set diffY [expr {abs($inCanvasY - $outCanvasY) / 3}]
      if {$inCanvasY > $outCanvasY} { 
        set interimy1 [expr {$outCanvasY + $diffY}]
        set interimy2 [expr {$inCanvasY - $diffY}]
      } else {
        set interimy1 [expr {$outCanvasY - $diffY}]
        set interimy2 [expr {$inCanvasY + $diffY}]
      }
      set interimy1 [expr {($interimy1 > $minY) ? $interimy1 : $minY}]
      set interimy2 [expr {($interimy2 > $minY) ? $interimy2 : $minY}]
      set interimXYList {}
      acons interimX $interimx interimXYList
      acons interimY1 $interimy1 interimXYList
      acons interimY2 $interimy2 interimXYList
    } else {
      # only one of these can be zero if interimX exists
      set interimy1 [assoc interimY1 interimXYList]
      set interimy2 [assoc interimY2 interimXYList]
      if {$interimy2 == 0} {
        set diffY [expr {abs($inCanvasY - $interimy1) / 2}]
        set interimy2 [expr {$interimy1 + $diffY}] 
      }
      if {$interimy1 == 0} {
        set diffY [expr {abs($interimy2 - $outCanvasY) / 2}]
        set interimy1 [expr {$outCanvasY + $diffY}]
      }
    }
    # puts stderr "interimXYList $interimXYList"

    set edge [$canvas create line $outCanvasX $outCanvasY \
                  $outCanvasX $interimy1 \
                  $interimx $interimy1 \
                  $interimx $interimy2 \
                  $inCanvasX $interimy2 \
                  $inCanvasX $inCanvasY  \
                  -width 2 -tags edge -fill $edgeColor \
                  -capstyle projecting]
  }
  # puts "drawEdge interimXYList $interimXYList"
  # puts "drawEdge outCanvasX $outCanvasX outCanvasY $outCanvasY"
  # puts "drawEdge inCanvasX $inCanvasX inCanvasY $inCanvasY"
  return $edge
}
 

## select an intermediate y value to turn the corner on the edge line
## 14oct95 wmt: snap y to grid; use 5 rather than 4 interim values
## 02jul96 wmt: just use half the distance, since we can now move
##              edges with Mouse-2
proc drawEdgeInterimY {y1 y2} {
  global g_NM_canvasGrid 
  
  if {$y1 < $y2} {return [drawEdgeInterimY $y2 $y1]}
  if {$y1 == $y2} {return $y1}
  ## set quintile [expr (1 + [pirGenInt] % 5)]; # 1, 2, 3, 4, or 5
  ## puts [format {drawEdgeInterimY quintile %d} $quintile]
  ##  set y1 [expr $y2 + floor($quintile * (($y1 - $y2)/6.0))]
  ## set y1 [expr $y2 + ($quintile * (($y1 - $y2)/6.0))]
  # puts stderr "drawEdgeInterimY: y1 $y1 y2 $y2"
  set diff [expr {$y1 - $y2}]
  set y1 [expr {$y2 + (($y1 - $y2) / 2.0)}]
  if {$diff > $g_NM_canvasGrid} {
    set y [snapToGrid $y1 "y"]
  } else {
    set y $y1
  }
  # puts stderr "drawEdgeInterimY: y1 $y1 y $y"
  return $y
}

## select a new or additional set of nodes.
## 04jan96 wmt: modified which menus are enabled
## 05jun96 wmt: added widgetsExistP arg
## 02jul96 wmt: implement multiple canvases
## 24oct96 wmt: remove canvas arg
## 22nov96 wmt: change check for "" pirNodeIndex
## 30aug97 wmt: add canvas arg to handle slave canvases
proc selectNodes { canvas pirNodeIndexList { widgetsExistP 1 } \
                       { canvasRootId 0} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge

  # puts stderr "selectNodes: pirNodeIndexList $pirNodeIndexList"
  # puts stderr "selectNodes: listlen [llength $pirNodeIndexList]"
  # deselectNodes $c -- removed to allow for shift-select
  set enableMouseClicksP 0
  set reportNotFoundP 0; set oldvalMustExistP 0
  set listLength [llength $pirNodeIndexList]
  if {$listLength > 0} {
    foreach pirNodeIndex $pirNodeIndexList {
      # puts stderr "selectNodes: pirNodeIndex `$pirNodeIndex'"
      if {! [string match $pirNodeIndex ""]} {
        set nodeState [assoc nodeState pirNode($pirNodeIndex)]
        if {[string match $nodeState "parent-link"]} {
          set dialogList [list tk_dialog .d "WARNING" \
              "You cannot remove a \"parent-link\" node\!" \
              warning 0 {Dismiss}]
          eval $dialogList
          return
        }
        set windowpath [getWindowPathFromPirNodeIndex $pirNodeIndex $canvas]
        selectNode $pirNodeIndex $windowpath $widgetsExistP $enableMouseClicksP \
            $canvasRootId 
      }
    }
    arepl selectedNodes $pirNodeIndexList pirDisplay \
        $reportNotFoundP $oldvalMustExistP

    enableSelectionMenus
  }
}


## 05jun96 wmt: added widgetsExistP arg
## 24oct96 wmt: remove canvas arg
## 17dec96 wmt: return if g_NM_processingNodeGroupP is 1
proc selectNode { pirNodeIndex windowpath { widgetsExistP 1 } \
    { enableMouseClicksP 0 } { canvasRootId 0} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_processingNodeGroupP g_NM_rootInstanceName
  global g_NM_schematicMode 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight

  # puts stderr "selectNode: pirNodeIndex $pirNodeIndex"
  if {$g_NM_processingNodeGroupP} {
    return
  }
  set reportNotFoundP 0
  # puts stderr "selectNode: pirNodeIndex $pirNodeIndex"
  set maybeSelectedNodes [assoc selectedNodes pirDisplay $reportNotFoundP]
  if {$enableMouseClicksP && \
      ([lsearch -exact $maybeSelectedNodes $pirNodeIndex] >= 0)} {
    return
  }
  set color [preferred StanleySelectedColor]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeState [assoc nodeState pirNode($pirNodeIndex)] 
  if {[string match $nodeClassType module] && \
          [string match $nodeState "parent-link"]} {
    # strip off unique integer appended to _P and the _P
    set nodeDisplayName [getModuleParentLinkLabel $nodeInstanceName]
  } elseif {[string match $nodeClassType "mode"]} {
    set nodeDisplayName [getExternalNodeName $nodeInstanceName]
  } else {
    set trimP 1; # trim : and blanks from long labels
    set pirNodeIndexAlist $pirNode($pirNodeIndex)
    set nodeDisplayName [getDisplayLabel pirNodeIndexAlist labelP $trimP]
  }
  if {$widgetsExistP} {
    # puts stderr "selectNode: pirNodeIndex $pirNodeIndex windowpath $windowpath"
    $windowpath.lab.icon configure -background $color
    $windowpath.lab.label configure -background $color
    # show icon label
    set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $reportNotFoundP]
    if {$labelCanvasId != ""} {
      if {[assoc labelWindowSeenP pirNode($pirNodeIndex)] == 0} {
        # move it from off-screen to where user can see it
        set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
        $currentCanvas.c move $labelCanvasId -$g_NM_absoluteCanvasWidth \
            -$g_NM_absoluteCanvasHeight
        raise [assoc labelWindow pirNode($pirNodeIndex)]
        arepl labelWindowSeenP 1 pirNode($pirNodeIndex)
      }
    }
  }
  set msg "";   set msg2 ""; set severity 0
  if {[string match $nodeClassType component] || \
          [string match $nodeClassType module]} {
    set msg "<Control-Mouse-L click>: open $nodeDisplayName"
  }
  if {[string match $g_NM_schematicMode "layout"]} {
    if {(! [string match $g_NM_rootInstanceName \
                [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
            [componentModuleDefReadOnlyP]} {
      set operation view
    } else {
      set operation edit
    }
    set msg2 "<Mouse-R menu>: $operation $nodeDisplayName"
    if {[string match $operation edit]} {
      if {! [string match $msg ""]} {
        append msg ";  "
      }
      append msg2 ";  delete $nodeDisplayName"
      append msg "<Mouse-L drag>: move $nodeDisplayName"
    }
    if {[string match $nodeClassType "mode"]} {
      append msg2 ";  select $nodeDisplayName proposition"
    }
  } else {
    # operational mode
    set operation view
    set msg2 "<Mouse-R menu>: $operation $nodeDisplayName"
    if {[string match $nodeClassType component]} {
      append msg2 ";  show $nodeDisplayName mode & propositions"
    } elseif {[string match $nodeClassType module] && \
                  (! [string match $nodeState "parent-link"])} {
      append msg2 ";  show $nodeDisplayName propositions"
    }
  }

  if {[string match $g_NM_rootInstanceName \
           [getCanvasRootInfo g_NM_currentNodeGroup]] && \
          (! [componentModuleDefReadOnlyP]) && \
          [string match $nodeClassType mode]} {
    # transitions can go from fault mode to ok mode, and
    # from ok mode to ok mode
    append msg ";  <Mouse-M drag>: create transition"
  }
  # puts stderr "selectNode: msg $msg msg2 $msg2"
  
  pirWarning $msg $msg2 $severity [getCanvasRootId $windowpath tmp]
}


## 03jul96 wmt: changed bgColor to nodeStateBgColor
## 24oct96 wmt: remove canvas arg
## 30aug97 wmt: add canvas arg to handle slave canvases
proc deselectNodes { canvas {canvasRootId 0} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "deselectNodes: `$backtrace'"
  set reportNotFoundP 0; set enableMouseClicksP 0
  foreach pirNodeIndex [assoc selectedNodes pirDisplay $reportNotFoundP] {
    # puts stderr "deselectNodes:::: pirNodeIndex $pirNodeIndex"
    set windowpath [getWindowPathFromPirNodeIndex $pirNodeIndex $canvas]
    deselectNode $pirNodeIndex $windowpath $enableMouseClicksP \
        $canvasRootId 
  }
  arepl selectedNodes {} pirDisplay $reportNotFoundP
  disableSelectionMenus
}  


## 03jul96 wmt: separate from deselectNodes 
## 10sep96 wmt: check for valid pirNodeIndex
## 24oct96 wmt: remove canvas arg
## 17dec96 wmt: return if g_NM_processingNodeGroupP is 1
proc deselectNode { pirNodeIndex windowpath {enableMouseClicksP 0} \
                      {canvasRootId 0} } {
  global pirNode pirDisplay pirNodes g_NM_processingNodeGroupP
  global g_NM_schematicMode g_NM_processingFileOpenP
  global g_NM_nodeTypesHaveIcons 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight 

  if {$g_NM_processingNodeGroupP || \
          ([string match $g_NM_schematicMode "operational"] && \
               $g_NM_processingFileOpenP)} {
    return
  }
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set reportNotFoundP 0
  set maybeSelectedNodes [assoc selectedNodes pirDisplay $reportNotFoundP]
  if {$enableMouseClicksP && \
      ([lsearch -exact $maybeSelectedNodes $pirNodeIndex] >= 0)} {
    return
  }
  if {[lsearch -exact $pirNodes $pirNodeIndex] == -1} {
    return
  }
  if {! [winfo exists $windowpath]} {
    return
  }
  # set str "deselectNode: pirNodeIndex pirNodeIndex nodeStateBgColor"
  # puts stderr "$str [assoc nodeStateBgColor pirNode($pirNodeIndex)]"
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  if {([lsearch -exact $g_NM_nodeTypesHaveIcons $nodeClassType] >= 0) && \
          [assoc nodeHasIconP pirNode($pirNodeIndex)]} {
    # -image has background color defined by create image
    # rest of node is transparent to canvas
    set color [lindex ["$currentCanvas.c" config -bg] 4]
  } else {

    set color [assoc nodeStateBgColor pirNode($pirNodeIndex)]
  }
  if {$color==""} {
    set color white
  }
  $windowpath.lab.icon configure -background $color
  # puts stderr "deselectNode: pirNodeIndex $pirNodeIndex"
  $windowpath.lab.label configure -background $color
  # bury icon label
  set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $reportNotFoundP]
  if {$labelCanvasId != ""} {
    if {[assoc labelWindowSeenP pirNode($pirNodeIndex)] == 1} {
      # move it off-screen to where user can not see it
      $currentCanvas.c move $labelCanvasId $g_NM_absoluteCanvasWidth \
          $g_NM_absoluteCanvasHeight
      arepl labelWindowSeenP 0 pirNode($pirNodeIndex)
    }
  }

  if {! $g_NM_processingFileOpenP} {
    standardMouseClickMsg [getCanvasRootId $windowpath tmp]
  }
}


## 12oct00 wmt: new
proc selectLabel { pirNodeIndex windowpath {canvasRootId 0} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_processingNodeGroupP g_NM_rootInstanceName
  global g_NM_schematicMode 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight

  # puts stderr "selectNode: pirNodeIndex $pirNodeIndex"
  if {$g_NM_processingNodeGroupP} {
    return
  }
  set reportNotFoundP 0
  # puts stderr "selectNode: pirNodeIndex $pirNodeIndex"
  set maybeSelectedNodes [assoc selectedNodes pirDisplay $reportNotFoundP]
  if {[lsearch -exact $maybeSelectedNodes $pirNodeIndex] >= 0} {
    return
  }
  set color [preferred StanleySelectedColor]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeState [assoc nodeState pirNode($pirNodeIndex)] 
  if {[string match $nodeClassType module] && \
          [string match $nodeState "parent-link"]} {
    # strip off unique integer appended to _P and the _P
    set nodeDisplayName [getModuleParentLinkLabel $nodeInstanceName]
  } elseif {[string match $nodeClassType "mode"]} {
    set nodeDisplayName [getExternalNodeName $nodeInstanceName]
  } else {
    set trimP 1; # trim : and blanks from long labels
    set pirNodeIndexAlist $pirNode($pirNodeIndex)
    set nodeDisplayName [getDisplayLabel pirNodeIndexAlist labelP $trimP]
  }
  $windowpath.label configure -background $color

  set msg "";   set msg2 ""; set severity 0
  if {[string match $g_NM_schematicMode "layout"]} {
    if {(! [string match $g_NM_rootInstanceName \
                [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
            [componentModuleDefReadOnlyP]} {
      set operation view
    } else {
      set operation edit
    }
    if {[string match $operation edit]} {
      if {! [string match $msg ""]} {
        append msg ";  "
      }
      append msg "<Mouse-L drag>: move $nodeDisplayName label"
    }
  }
  # puts stderr "selectNode: msg $msg msg2 $msg2"
  
  pirWarning $msg $msg2 $severity [getCanvasRootId $windowpath tmp]
}


## 12oct00 wmt: new
proc deselectLabel { pirNodeIndex windowpath {canvasRootId 0} } {
  global pirNode pirDisplay pirNodes g_NM_processingNodeGroupP
  global g_NM_schematicMode g_NM_processingFileOpenP
  global g_NM_nodeTypesHaveIcons 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight 

  if {$g_NM_processingNodeGroupP || \
          ([string match $g_NM_schematicMode "operational"] && \
               $g_NM_processingFileOpenP)} {
    return
  }
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set reportNotFoundP 0
  set maybeSelectedNodes [assoc selectedNodes pirDisplay $reportNotFoundP]
  if {[lsearch -exact $maybeSelectedNodes $pirNodeIndex] >= 0} {
    return
  }
  if {[lsearch -exact $pirNodes $pirNodeIndex] == -1} {
    return
  }
  if {! [winfo exists $windowpath]} {
    return
  }
  set color [lindex ["$currentCanvas.c" config -bg] 4]
  $windowpath.label configure -background $color

  if {! $g_NM_processingFileOpenP} {
    standardMouseClickMsg [getCanvasRootId $windowpath tmp]
  }
}


## 13oct95 wmt: set windowpath first, before changing any data
##              structs -- when is was done after [lremove $pirNodes $node], 
##              it was set to {}. then [adel {} pirDisplay] corrupted
##              pirDisplay 
## 12jan96 wmt: add nodesOnlyP & g_NM_edgesOfRedrawNode 
## 20feb96 wmt: allow multiple input terminals
## 05jun96 wmt: return destroyed window
## 01jul96 wmt: implement multiple canvases
## 07may97 wmt: use getCanvasFromWindow since canvas attribute is gone
## 15oct97 wmt: if node is of type mode delete any transitions
proc cutNode {canvas pirNodeIndex {nodesOnlyP 0} { widgetsExistP 1 } } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge

  set reportNotFoundP 0
  # puts stderr "cutNode: $canvas $pirNodeIndex"
  set window [assoc window pirNode($pirNodeIndex)]
  ## set windowpath [theNodeWindowPath $pirNodeIndex]
  set canvasId [assoc canvasId pirNode($pirNodeIndex)]
  set nodeCanvas [getCanvasFromWindow $window]
  if {! [string match $canvas $nodeCanvas]} {
    puts stderr "cutNode: pirNodeIndex $pirNodeIndex not in canvas $canvas"
    return
  }
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  # set str "cutNode $nodeInstanceName ($nodeClassName) nodesOnlyP $nodesOnlyP"
  # puts stderr "$str widgetsExistP $widgetsExistP"
  if {$widgetsExistP} {
    # delete node window
    $canvas delete $canvasId
    destroy $window
    # delete node icon label window
    set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $reportNotFoundP]
    if {$labelCanvasId != ""} {
      $canvas delete [assoc labelCanvasId pirNode($pirNodeIndex)]
      destroy [assoc labelWindow pirNode($pirNodeIndex)] 
    }
  }
  if {[string match $nodeClassType mode]} {
    # delete any transitions
    set reportNotFoundP 0
    set transitionList [assoc transitions pirNode($pirNodeIndex) \
                            $reportNotFoundP] 
    deleteAllModeTransitions transitionList  
  }
  processEdgesForCutNode $canvas $pirNodeIndex $nodesOnlyP

  unset pirNode($pirNodeIndex)
  lremove pirNodes $pirNodeIndex
 
  return $window
}


## create list of edges from node defn and optionally delete edges
## 05jun96 wmt: new
## 10sep97 wmt: if node is a mode, delete any transitions
proc processEdgesForCutNode { canvas pirNodeIndex nodesOnlyP } {
  global pirNode 

  if {! $nodesOnlyP} {
    set edgeSetList [assoc edgesFrom pirNode($pirNodeIndex)]
    cutEdgeSetList $canvas edgeSetList 

    set edgeSetList [assoc edgesTo pirNode($pirNodeIndex)]
    cutEdgeSetList $canvas edgeSetList 
  }
}


proc cutEdgeSetList { canvas edgeSetListRef {ignoreEdgesFromP 0} \
                        {ignoreEdgesToP 0} } {
  upvar $edgeSetListRef edgeSetList

  set widgetsExistP 1; set caller "cutEdgeSetList"
  foreach edgeset $edgeSetList {
    foreach pirEdgeIndex $edgeset {
      if {$pirEdgeIndex} {
        cutEdge $canvas $pirEdgeIndex $ignoreEdgesFromP $ignoreEdgesToP \
            $widgetsExistP $caller 
      }
    }
  }
}

  
## remove an edge from the display
## 12jan96 wmt: add ignoreEdgesFromP & ignoreEdgesToP 
## 01feb96 wmt: add mark_modified
## 20feb96 wmt: allow multiple input terminals
## 17may96 wmt: support edges which connect ports
## 01jul96 wmt: implement multiple canvases
## 28jul96 wmt: remove pirEdgeIndex from g_NM_highlightedEdgeList, if there
## 07may97 wmt: canvas attribute no longer in pirEdge - use getCanvasFromButton
proc cutEdge {canvas pirEdgeIndex {ignoreEdgesFromP 0} {ignoreEdgesToP 0} \
                  {widgetsExistP 1} {caller ""} {redrawEdgeP 0} } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_processingNodeGroupP g_NM_highlightedEdgeList

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "cutEdge: `$backtrace'"
  set reportNotFoundP 0
  if {!$pirEdgeIndex} return; # zero edges are dummies, and sometimes creep in
  # puts stderr "cutEdge: $canvas pirEdgeIndex $pirEdgeIndex widgetsExistP $widgetsExistP"
  set edgeCanvas [getCanvasFromButton [assoc buttonTo pirEdge($pirEdgeIndex)]]
  if {! [string match $canvas $edgeCanvas]} {
    puts stderr "cutEdge: pirEdgeIndex $pirEdgeIndex ($edgeCanvas) not in canvas $canvas\!"
    return
  }
  set innode [assoc nodeTo pirEdge($pirEdgeIndex)]
  set outnode [assoc nodeFrom pirEdge($pirEdgeIndex)]
  set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
  # outnode and innode may be deleted already
  set nodeFromToName "nodeFromName:nodeToName"
  set canvasId [assoc canvasId pirEdge($pirEdgeIndex)]
  # puts stderr "cutEdge: innode $innode outnode $outnode"
  lremove pirEdges $pirEdgeIndex
  # puts stderr "cutEdge ignoreEdgesFromP $ignoreEdgesFromP ignoreEdgesToP $ignoreEdgesToP"
  set portEdgeType [isThisAPortEdge $pirEdgeIndex]
  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    set whichEdges edgesFrom
  } elseif {([string match $portEdgeType ""]) || \
      ([string match $portEdgeType "port->To"])} {
    set whichEdges edgesTo
  } else {
    puts stderr "cutEdge: portEdgeType $portEdgeType not handled\!"
    return
  }

  # puts stderr "cutEdge portEdgeType $portEdgeType whichEdges $whichEdges"
  if {! $ignoreEdgesToP} {
    # Here we walk thru the edgesFrom looking for the target $pirEdgeIndex.
    set foundInedge 0; # tells us if we find it
    # puts stderr "cutEdge: whichEdges $whichEdges innode $innode"
    # puts stderr "cutEdge before edgesTo [assoc edgesTo pirNode($innode)]"
    # set edgesetTolist [assoc $whichEdges pirNode($innode) $reportNotFoundP]
    set edgesetTolist [assoc edgesTo pirNode($innode) $reportNotFoundP]
    for {set i 0} {$i < [llength $edgesetTolist]} {incr i} {
      set edgeset [lindex $edgesetTolist $i]
      # puts stderr "cutEdge: edgesTo edgeset $edgeset pirEdgeIndex $pirEdgeIndex"
      set ix [lsearch -exact $edgeset $pirEdgeIndex]
      if {$ix != -1} {
        set foundInedge 1
        set edgeset [lreplace $edgeset $ix $ix]
        set edgesetTolist [lreplace $edgesetTolist $i $i $edgeset]
        arepl edgesTo $edgesetTolist pirNode($innode)
        set innodeEdges $edgeset 
        break;
      }
    }
    if {! $foundInedge} {
      # since terminals can be on either top (in) or bottom (from)
      # look here too
      set edgesetTolist [assoc edgesFrom pirNode($innode) $reportNotFoundP]
      for {set i 0} {$i < [llength $edgesetTolist]} {incr i} {
        set edgeset [lindex $edgesetTolist $i]
        # puts stderr "cutEdge: edgesFrom edgeset $edgeset pirEdgeIndex $pirEdgeIndex"
        set ix [lsearch -exact $edgeset $pirEdgeIndex]
        if {$ix != -1} {
          set foundInedge 1
          set edgeset [lreplace $edgeset $ix $ix]
          set edgesetTolist [lreplace $edgesetTolist $i $i $edgeset]
          arepl edgesFrom $edgesetTolist pirNode($innode)
          set innodeEdges $edgeset 
          break;
        }
      }
    }
  } else {
    set foundInedge 1
  }
  if {! $ignoreEdgesFromP} {
    # Here we walk thru the edgesFrom looking for the target $pirEdgeIndex.
    set foundOutedge 0; # tells us if we find it
    # puts stderr "cutEdge: outnode $outnode"
    # puts stderr "cutEdge before edgesFrom [assoc edgesFrom pirNode($outnode)]"
    # puts stderr "cutEdge before edgesTo [assoc edgesTo pirNode($outnode)]"
    # set str "cutEdge: edgesFrom [assoc edgesFrom pirNode($outnode)]"
    # puts stderr "$str pirEdgeIndex $pirEdgeIndex"
    set edgesetFromlist [assoc edgesFrom pirNode($outnode) $reportNotFoundP]
    for {set i 0} {$i < [llength $edgesetFromlist]} {incr i} {
      set edgeset [lindex $edgesetFromlist $i]
      # puts stderr "cutEdge: edgesFrom edgeset $edgeset pirEdgeIndex $pirEdgeIndex"
      set ix [lsearch -exact $edgeset $pirEdgeIndex]
      if {$ix != -1} {
        set foundOutedge 1
        set edgeset [lreplace $edgeset $ix $ix]
        set edgesetFromlist [lreplace $edgesetFromlist $i $i $edgeset]
        arepl edgesFrom $edgesetFromlist  pirNode($outnode)
        set outnodeEdges $edgeset 
        break;
      }
    }
    if {! $foundOutedge} {
      # since terminals can be on either top (in) or bottom (from)
      # look here too
      set edgesetTolist [assoc edgesTo pirNode($outnode) $reportNotFoundP]
      for {set i 0} {$i < [llength $edgesetTolist]} {incr i} {
        set edgeset [lindex $edgesetTolist $i]
        # puts stderr "cutEdge: edgesTo edgeset $edgeset pirEdgeIndex $pirEdgeIndex"
        set ix [lsearch -exact $edgeset $pirEdgeIndex]
        if {$ix != -1} {
          set foundOutedge 1
          set edgeset [lreplace $edgeset $ix $ix]
          set edgesetTolist [lreplace $edgesetTolist $i $i $edgeset]
           arepl edgesTo $edgesetTolist  pirNode($outnode)
          set outnodeEdges $edgeset 
          break;
        }
      }
    }
  } else {
    set foundOutedge 1
  }
  if {! $foundInedge} \
   {error "Internal consistency error: cutEdge To pirNode($innode)"}
  if {! $foundOutedge} \
   {error "Internal consistency error: cutEdge From pirNode($outnode)"}
  # puts "cutEdge after edgesTo [assoc $whichEdges pirNode($innode)]"
  # puts "cutEdge after edgesFrom [assoc edgesFrom pirNode($outnode)]"
  # if this is the last edge to a button, change the terminalForm
  # redrawEdgeP is passed in from toggleConnectionBreaks which toggles 2->4/4->2 breaks
  if {(! $redrawEdgeP) && \
          ([string match $caller "unmkEdge"] || \
               [string match $caller "cutEdgeSetList"])} {
    # user requests deletion via edge delete or node delete; otherwise it is just
    # a redraw due to terminal changes, edge move, node move, ...
    # interfaceType from private to public
    if {[string match $innodeEdges ""]} {
      setTerminalButtonInterfaceType [assoc buttonTo pirEdge($pirEdgeIndex)] public
    }
    if {[string match $outnodeEdges ""]} {
      setTerminalButtonInterfaceType [assoc buttonFrom pirEdge($pirEdgeIndex)] public
    }
  }
  if {$widgetsExistP} {
    $canvas delete $canvasId
  }
  unset pirEdge($pirEdgeIndex)
  deleteEdgeInstance $canvasId $pirEdgeIndex $canvas $abstractionType $nodeFromToName
  set index [lsearch -exact $g_NM_highlightedEdgeList $pirEdgeIndex]
  if {$index >= 0} {
    set g_NM_highlightedEdgeList [lreplace $g_NM_highlightedEdgeList $index $index]
  }
  if {! $g_NM_processingNodeGroupP} {
    mark_scm_modified
  }
}
  

# check for existing edges from any of the buttons in the list
# if found, print an error message and return 1. else return 0.
proc exist_edges_out {buttonlist node} {
  global pirEdge pirNode
  foreach e [assoc edgesFrom pirNode($node)] {
    if {$e} {
       if {[lsearch -exact $buttonlist [assoc buttonFrom pirEdge($e)]] > -1} {
         tk_dialog .d "Error" "An output link exists from selected terminal!" {} 0 OK
         return 1
       }
     }
  }
  return 0
}

# check for existing edges to any of the buttons in the list
# if found, print an error message and return 1. else return 0.
proc exist_edges_in {buttonlist node} {
  global pirEdge pirNode
  foreach e [assoc edgesTo pirNode($node)] {
    if {$e} {
       if {[lsearch -exact $buttonlist [assoc buttonTo pirEdge($e)]] > -1} {
         tk_dialog .d "Error" "An input link exists to selected terminal!" {} 0 OK
         return 1
      }
    }
  }
  return 0
}


## pop-up window for terminal selection
## 22feb96 wmt: new
## 07mar96 wmt: allow each input/output terminal to have a pop-up window,
##              instead of just one for the component
## 20may98 wmt: not used anymore
proc showButtonType { button pirNodeIndex buttonNum terminalNameList \
                          in_or_out { type_list {} } } {
  global g_NM_termtypeRootWindow g_NM_currentNodeGroup
  global pirNode 

  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set window ${g_NM_termtypeRootWindow}.$nodeInstanceName
  if {[regexp ".in." $button]} {
    append window "-in$buttonNum"
  } else {
    append window "-out$buttonNum"
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  catch {destroy $window};      # only one instance can be created
  toplevel $window -class Dialog 
  # wm geometry $window ${minWidth}x${minHeight}+${xPos}+${yPos}
  # do not cover up terminal button
  set xPos [winfo rootx $button]
  set yPos [expr {[winfo rooty $button] + 8}]
  wm geometry $window +${xPos}+${yPos}
#   if {[string match $nodeClassType "terminal"]} {
#     if {[string match $nodeClassName "INPUT"] || \
#         [string match $nodeClassName "INPUT-DECLARATION"] } {
#       set exp "_I_"
#     } elseif {[string match $nodeClassName "OUTPUT"] || \
#         [string match $nodeClassName "OUTPUT-DECLARATION"] } {
#       set exp "_O_"
#     } elseif {[string match $nodeClassName "PORT"] || \
#         [string match $nodeClassName "PORT-DECLARATION"] } {
#       set exp "_P_"
#     }
#     append exp "\[0-9\]*"
#     regsub -nocase -all $exp $terminalNameList "" safeTerminalNameList
#     set terminalNameList $safeTerminalNameList
#     # input/output sense is opposite
#     # if {[string match $in_or_out "in"]} {
#     #   set in_or_out "out"
#     # } else {
#     #   set in_or_out "in"
#     # }
#   }
  if {[string match $nodeClassType "terminal"] || \
          [string match $nodeClassType "attribute"]} {
    set nodeInstanceName [getCanvasRootInfo g_NM_currentNodeGroup]
    # to pick up edits of terminals/attributes get the current values, not
    # the initial ones
    set terminalNameList [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set index [string first "_" $terminalNameList]
    if {$index != -1} {
      # strip off declaration/terminator suffixs
      set terminalNameList [string range $terminalNameList 0 [expr {$index -1}]]
    }
    if {[string match $nodeClassName "output"] || \
            [string match $nodeClassName "outputDeclaration"]} {
      set termType inputs; set termAtt in1
    } else {
      set termType outputs; set termAtt out1
    }
    set terminalList [assoc $termType pirNode($pirNodeIndex)]
    set terminalDef [assoc $termAtt terminalList]
    set type_list [assoc type terminalDef]
  }    
  if {[string match $nodeClassType "terminal"] || \
          [string match $nodeClassType "attribute"]} {
     set title "${nodeInstanceName} : $nodeClassName"
  } else {
    set title "${nodeInstanceName} : ${in_or_out}${buttonNum}"
    if {[string match [getTerminalTypeFromType_List $type_list] "port"]} {
      append title " (port)"
    }
  }
  wm title $window $title
  wm transient $window [winfo toplevel [winfo parent $window]]
  # puts "showButtonType terminalNameList $terminalNameList"
  $window config -bg $bgcolor
  frame $window.label&button -bd 0 -bg $bgcolor -relief ridge 
  frame $window.label&button.l -bd 0 -bg $bgcolor -relief ridge 
  label $window.label&button.l.label2 -anchor w \
      -text " name : $terminalNameList " -font [preferred StanleyTerminalTypeFont]
  label $window.label&button.l.label3 -anchor w \
      -text " type : [getTerminalTypeFromType_List $type_list] " \
      -font [preferred StanleyTerminalTypeFont]
  pack $window.label&button.l.label2 $window.label&button.l.label3 -side top -fill x
      ## $window.label&button.l.label -side top -fill x
  pack $window.label&button.l -side top -fill x
  frame $window.label&button.b -bd 0 -bg red -relief ridge 
  button $window.label&button.b.cancel -text " dismiss " -relief raised \
      -command "destroy $window" -padx 0 -pady 0
  pack $window.label&button.b.cancel -side left -padx 0 -ipadx 0 -expand 1
  pack $window.label&button.b -side top -fill x
  pack $window.label&button.l $window.label&button.b -side left -fill x
  pack $window.label&button -fill both -expand true
  ## puts "showButtonType button [$window.label&button.b.cancel config]"
}


## check for user attempting to create a connection which already
## exists
## 30sep96 wmt: new
## 08dec97 wmt: add numBreaks; if existing edge is not the same number
##              of breaks, delete it
proc duplicateEdgeCheck { innode outnode inbut outbut numBreaks } {
  global pirNode pirEdge

  set dupExistsP 0; set redrawEdgeP 1; set caller "duplicateEdgeCheck"
  getEdgeTypeAndIndexFromButtonPath $inbut inbutNum inbutEdgeType
  set existingEdges [assoc $inbutEdgeType pirNode($innode)]
  set numEdges [llength $existingEdges]
  # puts stderr "duplicateEdgeCheck: numEdges $numEdges existingEdges $existingEdges"
  # puts stderr \
  #     "duplicateEdgeCheck: innode $innode outnode $outnode inbut $inbut outbut $outbut"
  for {set i 0} {$i <$numEdges} {incr i} {
    set edgeSet [lindex $existingEdges $i]
    foreach edgeNum $edgeSet {
      # puts stderr "duplicateEdgeCheck: edgeNum $edgeNum"
      if {[info exists pirEdge($edgeNum)]} {
        set existingOutbut [assoc buttonFrom pirEdge($edgeNum)]
        set existingInbut [assoc buttonTo pirEdge($edgeNum)]
        # set str "duplicateEdgeCheck: edgeNum $edgeNum existingOutbut $existingOutbut"
        # puts stderr "$str existingInbut $existingInbut"
        if {[string match $inbut $existingInbut] && \
            [string match $outbut $existingOutbut]} {
          # found a duplicate edge
          set interimXYList [assoc interimXYList pirEdge($edgeNum)]
          if {(([llength $interimXYList] == 2) && ($numBreaks == 2)) || \
                  (([llength $interimXYList] > 2) && ($numBreaks == 4))} {
            set dupExistsP 1
            break
          } else {
            # delete edge so that requested edge with different number of 
            # breaks can be drawn
            unmkEdge $edgeNum $caller $redrawEdgeP 
          }
        }
      }
    }
  }
  return $dupExistsP
}


## make pending edges for recursive building of multiple canvases done by
## pirRedraw; new nodes have been created for the old edge
## 01oct97 wmt: for non-recursive instantiation, return 1 if nodes
##              do not exist yet
## 07dec97 wmt: handle port to port edges
## 30jul99 wmt: use type from current terminals, rather than type from
##              pending edge form -- so as to pickup type changes made
##              to under lying components
proc mkPendingEdge { edgeFormRef canvasRootId } {
  upvar $edgeFormRef edgeForm
  global g_NM_instanceToNode pirNode g_NM_recursiveInstantiationP
  global g_NM_edgeConnectionFailedList g_NM_pendingEdgesOverrideMsgP
  global pirNode 

  set debugP 0; set caller "mkPendingEdge"

  # puts stderr "mkPendingEdge: edgeForm $edgeForm"
  set terminalFrom [assoc terminalFrom edgeForm]
#   if {[regexp "FSC_PASM_SW1" $terminalFrom]} {
#     puts stderr "mkPendingEdge: terminalFrom [assoc terminalFrom edgeForm] "
#     puts stderr "mkPendingEdge: terminalTo   [assoc terminalTo edgeForm]"
#     set debugP 1
#   }
  # puts stderr "mkPendingEdge: canvasRootId $canvasRootId"
  # puts stderr "mkPendingEdge: edgeForm $edgeForm"
  set newFromNum 0; set newToNum 0; set reportNotFoundP 0
  set checkTypesP 0; set numBreaks 0
  set abstractionType [assoc abstractionType edgeForm]
  set documentation [assoc documentation edgeForm]
  set interimXYList [assoc interimXYList edgeForm]
  # do not use oldButtonFrom & oldButtonTo to get fromNum & toNum
  # since button order may have changed
  set oldButtonFrom [assoc buttonFrom edgeForm]
  set fromIndex [string last "." $oldButtonFrom]
  set oldFromNum [string range $oldButtonFrom $fromIndex end] 
  set oldButtonTo [assoc buttonTo edgeForm]
  set toIndex [string last "." $oldButtonTo]
  set oldToNum [string range $oldButtonTo $toIndex end]
  set reportNotFoundP 1
  if {! $g_NM_recursiveInstantiationP} {
    set reportNotFoundP 0
  }
  set fromPirNodeIndex [assoc-array [assoc nodeFrom edgeForm] g_NM_instanceToNode \
                            $reportNotFoundP]
  set toPirNodeIndex [assoc-array [assoc nodeTo edgeForm] g_NM_instanceToNode \
                          $reportNotFoundP]
  if {(! $g_NM_recursiveInstantiationP) && \
          ([string match $fromPirNodeIndex ""] || \
               [string match $toPirNodeIndex ""])} {
    # layout mode
    return 1 
  }

  # convert to appropriate canvas
  set canvas [getCanvasFromButton $oldButtonFrom]
  # puts stderr "mkPendingEdge: canvas $canvas canvasRootId $canvasRootId" 
  set canvas [convertCanvasPath $canvas $canvasRootId]
  # set str "mkPendingEdge: canvas $canvas g_NM_currentCanvas"
  # puts stderr "$str [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]"
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId] 
  if {$g_NM_recursiveInstantiationP && \
          (! [string match $canvas $currentCanvas.c])} {
    # operational mode
    return 1
  }
  set windowFrom [getWindowPathFromPirNodeIndex $fromPirNodeIndex $canvas]
  set windowTo [getWindowPathFromPirNodeIndex $toPirNodeIndex $canvas]
  if {(! $g_NM_recursiveInstantiationP) && \
          ([string match $windowFrom ""] || \
               [string match $windowTo ""])} {
    # layout mode
    # edges are loaded with module, but components to which the edges connect
    # are loaded later when that module is opened up.  But if two different
    # modules have 2 components of the same component classes with the same
    # instance names, then the pending edge can be seen here when its canvas
    # has not been populated with its components
    return 1 
  }
  set numInputs [assoc numInputs pirNode($fromPirNodeIndex)]
  set inputs [assoc inputs pirNode($fromPirNodeIndex)]
  set numOutputs [assoc numOutputs pirNode($fromPirNodeIndex)]
  set outputs [assoc outputs pirNode($fromPirNodeIndex)]
  set terminalFrom [assoc terminalFrom edgeForm]
  set newFromType "<unspecified>"
  set pendingTerminalName [assoc terminal_name terminalFrom]
  set pendingTerminalFromType [getTerminalType $terminalFrom]
  set foundP 0
  for {set fromNum 1} {$fromNum <= $numOutputs} {incr fromNum} {
    set maybeTerminalFrom [assoc "out$fromNum" outputs]
    set maybeTerminalName [assoc terminal_name maybeTerminalFrom]
    set maybeTerminalType [getTerminalType $maybeTerminalFrom]
    if {$debugP} {
      set str "pendingTerminalName FROMNUM OUTPUTS $pendingTerminalName"
      puts stderr "$str maybeTerminalName $maybeTerminalName"
      puts stderr "maybeTerminalType $maybeTerminalType"
    }
    if {[string match $pendingTerminalName $maybeTerminalName]} {
      set newFromNum $fromNum; set fromPrefix out
      set newFromType $maybeTerminalType 
      set foundP 1
      break
    }
  }
  if {! $foundP} {
    # look in inputs -- terminal may have been moved from outputs to
    # inputs by the user
    for {set fromNum 1} {$fromNum <= $numInputs} {incr fromNum} {
      set maybeTerminalFrom [assoc "in$fromNum" inputs]
      set maybeTerminalName [assoc terminal_name maybeTerminalFrom]
      set maybeTerminalType [getTerminalType $maybeTerminalFrom]
      if {$debugP} {
        set str "pendingTerminalName FROMNUM INPUTS $pendingTerminalName"
        puts stderr "$str maybeTerminalName $maybeTerminalName"
        puts stderr "maybeTerminalType $maybeTerminalType"
      }
      if {[string match $pendingTerminalName $maybeTerminalName]} {
        set newFromNum $fromNum; set fromPrefix in
        set newFromType $maybeTerminalType 
        break
      }
    }
  }
  if {$newFromNum == 0} {
    # could not find the matching terminal
    # if the number of component or mode terminals has changed, $oldFromNum 
    # and .b$newFromNum can be different, but will still be non zero
    set buttonFrom ""
    if {$debugP} {
      puts stderr "\nmkPendingEdge: oldFromNum $oldFromNum newFromNum $newFromNum"
    }
  } else {
    set buttonFrom "${windowFrom}.$fromPrefix.b$newFromNum"
  }

  set numInputs [assoc numInputs pirNode($toPirNodeIndex)]
  set numOutputs [assoc numOutputs pirNode($toPirNodeIndex)]
  set inputs [assoc inputs pirNode($toPirNodeIndex)]
  set outputs [assoc outputs pirNode($toPirNodeIndex)]
  set terminalTo [assoc terminalTo edgeForm]
  set newToType "<unspecified>"
  set pendingTerminalName [assoc terminal_name terminalTo]
  set pendingTerminalToType [getTerminalType $terminalTo]
  # set str "mkPendingEdge: pendingTerminalName $pendingTerminalName"
  # puts stderr "$str terminalTo $terminalTo"
  set foundP 0
  for {set toNum 1} {$toNum <= $numInputs} {incr toNum} {
    set maybeTerminalTo [assoc "in$toNum" inputs]
    set maybeTerminalName [assoc terminal_name maybeTerminalTo]
    set maybeTerminalType [getTerminalType $maybeTerminalTo]
    if {$debugP} {
      set str "pendingTerminalName TONUM INPUTS $pendingTerminalName"
      puts stderr "$str maybeTerminalName $maybeTerminalName"
      puts stderr "maybeTerminalType $maybeTerminalType"
    }
    if {[string match $pendingTerminalName $maybeTerminalName]} {
      set newToNum $toNum; set toPrefix in
      set newToType $maybeTerminalType 
      set foundP 1
      break
    }
  }
  if {! $foundP} {
    for {set toNum 1} {$toNum <= $numOutputs} {incr toNum} {
      set maybeTerminalTo [assoc "out$toNum" outputs]
      set maybeTerminalName [assoc terminal_name maybeTerminalTo]
      set maybeTerminalType [getTerminalType $maybeTerminalTo]
      if {$debugP} {
        set str "pendingTerminalName TONUM OUTPUTS $pendingTerminalName"
        puts stderr "$str maybeTerminalName $maybeTerminalName"
        puts stderr "maybeTerminalType $maybeTerminalType"
      }
      if {[string match $pendingTerminalName $maybeTerminalName]} {
        set newToNum $toNum; set toPrefix out
        set newToType $maybeTerminalType 
        break
      }
    }
  }
  if {$newToNum == 0} {
    # could not find the matching terminal
    # if the number of component or mode terminals has changed, $oldToNum 
    # and .b$newToNum can be different, but will still be non zero
    set buttonTo ""
    if {$debugP} {
      puts stderr "\nmkPendingEdge: oldToNum $oldToNum newToNum $newToNum"
    }
  } else {
    set buttonTo "${windowTo}.$toPrefix.b$newToNum"
  }

  # puts stderr "mkPendingEdge: canvas $canvas buttonTo $buttonTo buttonFrom $buttonFrom"
  # set str "mkPendingEdge: newFromNum $newFromNum newToNum $newToNum"
  # puts stderr "$str newFromType $newFromType newToType $newToType"
  set fromEdgeAttrList [assoc terminalFrom edgeForm]
  set toEdgeAttrList [assoc terminalTo edgeForm]
  set portEdgeType [isThisAPortEdge "" $fromEdgeAttrList $toEdgeAttrList]
  set abstractionTypeList [getAbstractionTypes $newFromType $newToType]
  set expandedAbstractionType [expandAbstractionType $abstractionType \
                                   abstractionTypeList]
  if {($newFromNum > 0) && ($newToNum > 0) && \
          ([string match $newFromType $newToType]) || \
          ([lsearch -exact $abstractionTypeList $expandedAbstractionType] >= 0)} {
    if {(! $g_NM_pendingEdgesOverrideMsgP) && \
            ((! [string match $pendingTerminalFromType $newFromType]) || \
            (! [string match $pendingTerminalToType $newToType]))} {
      set g_NM_pendingEdgesOverrideMsgP 1
      ## inherited terminal types have overridden module's knowledge
      ## of terminal types in g_NM_includedModules
      set str "Inherited terminal type(s) have overridden module's\n"
      append str "knowledge of terminal types."
      set str2 "You may have lost some connections."
      puts stderr "\n\nmkPendingEdge: $str\n               $str2"
      set dialogList [list tk_dialog .d "WARNING" "$str\n\n$str2" warning 0 {DISMISS}]
      eval $dialogList
      mark_scm_modified
    }
    mkEdge $buttonTo $buttonFrom $numBreaks $interimXYList \
        $portEdgeType $canvas $checkTypesP $documentation $expandedAbstractionType 
  } else {
    # puts stderr "      buttonTo $oldButtonTo buttonFrom $oldButtonFrom canvas $canvas"
    puts stderr "\nmkPendingEdge: CONNECTION NO LONGER VALID"
    puts stderr "               terminal name or type mismatch"
    set terminalFrom [assoc terminalFrom edgeForm]
    set terminalTo [assoc terminalTo edgeForm]
    set fromDirection [getTerminalDirection $terminalFrom]
    set fromText "from"
    if {[string match $fromDirection "in"]} { set fromText "to  " }
    set toDirection [getTerminalDirection $terminalTo]
    set toText "to  "
    if {[string match $toDirection "out"]} { set toText "from" }
    puts stderr "    $fromText: [getExternalNodeName [assoc terminal_name terminalFrom]]"
    puts stderr "          direction & type: $fromDirection $newFromType"
    puts stderr "    $toText: [getExternalNodeName [assoc terminal_name terminalTo]]"
    puts stderr "          direction & type: $toDirection $newToType"
    puts stderr "    abstractionType: $expandedAbstractionType"
    lappend g_NM_edgeConnectionFailedList \
        [list [string trimright $fromText " "] \
             [getExternalNodeName [assoc terminal_name terminalFrom]] \
             [string trimright $toText " "] \
             [getExternalNodeName [assoc terminal_name terminalTo]]]
    if {$expandedAbstractionType != "equal"} {
      # force an entry in g_NM_dependencyErrorList for abstraction types
      # which are not equal
      set fromPirNodeIndex [getPirNodeIndexFromButtonPath $buttonFrom $caller]
      if {$fromPirNodeIndex != 0} {
        set nodeFromName [getExternalNodeName [assoc nodeInstanceName \
                                                   pirNode($fromPirNodeIndex)]]
        set toPirNodeIndex [getPirNodeIndexFromButtonPath $buttonTo $caller]
        if {$toPirNodeIndex != 0} {
          set nodeToName [getExternalNodeName [assoc nodeInstanceName \
                                                   pirNode($toPirNodeIndex)]]
          updateEdgeDependency 0 $nodeFromName $nodeToName $expandedAbstractionType \
              $currentCanvas 0
        }
      }
    }
  }
  return 0
}


## 26jun97 wmt: adapted from selectNode
proc selectEdge { pirEdgeIndex canvasRootId canvasId { widgetsExistP 1 } } {
  global pirEdge g_NM_currentCanvas pirDisplay pirEdges 
  global g_NM_processingNodeGroupP g_NM_highlightedEdgeList 
  global g_NM_rootInstanceName g_NM_schematicMode 

  if {$g_NM_processingNodeGroupP || \
          ([lsearch -exact $pirEdges $pirEdgeIndex] == -1)} {
    return
  }
  set reportNotFoundP 0; set oldvalMustExistP 0
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  # if edge is overlapped, raise it to top
  $currentCanvas.c raise $canvasId
  # color it selected
  $currentCanvas.c itemconfigure $canvasId \
      -fill [preferred StanleySelectedColor]
  if {[lsearch -exact $g_NM_highlightedEdgeList $canvasId] == -1} {
    lappend g_NM_highlightedEdgeList $canvasId
  }
  deselectEdges $currentCanvas
  arepl selectedEdges $pirEdgeIndex pirDisplay $reportNotFoundP \
          $oldvalMustExistP
  # puts stderr "selectEdge: pirEdgeIndex $pirEdgeIndex canvasRootId $canvasRootId "
  set interimXYList [assoc interimXYList pirEdge($pirEdgeIndex)]
  # puts stderr "selectEdge: interimXYList $interimXYList"
  set reportNotFoundP 0; set returnIndexP 1
  if {[assoc interimY1 interimXYList $reportNotFoundP $returnIndexP] \
          == -1} {
    # current edge is 2-Break Connection
    set numBreaks 4
  } else {
    #current edge is 4-Break Connection
    set numBreaks 2
  }
  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [componentModuleDefReadOnlyP] || \
          [string match $g_NM_schematicMode "operational"]} {
    set operation view
  } else {
    set operation edit
  }
  set msg ""; set severity 0
  set msg2 "<Mouse-R menu>: $operation connection"
  if {[string match $operation edit]} {
    set msg "<Mouse-L drag>: move connection"
    append msg2 ";  delete connection"
    append msg2 ";  create $numBreaks break connection"
  }
  pirWarning $msg $msg2 $severity $canvasRootId 

  if {$canvasRootId == 0} {
    set buttonTo [assoc buttonTo pirEdge($pirEdgeIndex)]
    set buttonFrom [assoc buttonFrom pirEdge($pirEdgeIndex)]
    # puts stderr "selectEdge: buttonTo $buttonTo buttonFrom $buttonFrom"
    if {[regexp "in" [getTerminalButtonDirectionType $buttonTo]]} {
      nodeInSelectNoshift $buttonTo
    } else {
      nodeOutSelectNoshift $buttonTo
    }
    if {[regexp "in" [getTerminalButtonDirectionType $buttonFrom]]} {
      nodeInSelectNoshift $buttonFrom
    } else {
      nodeOutSelectNoshift $buttonFrom
    }
  }
}


proc deselectEdges { canvas } {
  global pirDisplay g_NM_canvasIdToPirEdge 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "deselectEdges: `$backtrace'"
  set reportNotFoundP 0; set oldvalMustExistP 0
  set canvasRootId [getCanvasRootId $canvas canvasRoot]
  foreach pirEdgeIndex [assoc selectedEdges pirDisplay $reportNotFoundP] {
    # puts stderr "deselectEdges:::: pirEdgeIndex $pirEdgeIndex canvas $canvas"
    set currentEntries [assoc-array $canvas.c g_NM_canvasIdToPirEdge $reportNotFoundP]
    set canvasId [assoc-value-exact $pirEdgeIndex currentEntries $reportNotFoundP]
    # a moved edge has a new pirEdgeIndex
    if {$canvasId != ""} {
      deselectEdge $pirEdgeIndex $canvasRootId $canvasId
    }
  }
  arepl selectedEdges {} pirDisplay $reportNotFoundP $oldvalMustExistP
}  


## 26jun97 wmt: adapted from deselectNode
proc deselectEdge { { pirEdgeIndex 0 } { canvasRootId 0 } { canvasId 0 } } {
  global pirEdge g_NM_processingNodeGroupP
  global g_NM_currentCanvas pirEdges pirDisplay g_NM_selectedEdge
  global g_NM_highlightedEdgeList 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "deselectEdge: `$backtrace'"
  set reportNotFoundP 0; set oldvalMustExistP 0
  if {$g_NM_processingNodeGroupP} {
    return
  }
  if {($pirEdgeIndex != 0) && \
          ([lsearch -exact $pirEdges $pirEdgeIndex] >= 0)} {
    set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
    if {$canvasRootId == 0} {
      set canvasId [assoc canvasId pirEdge($pirEdgeIndex)]
    }
    set fillColor [preferred StanleyNodeConnectionBgColor]
    if {! [string match [assoc propSelectedP pirEdge($pirEdgeIndex) \
                             $reportNotFoundP] ""]} {
      set fillColor [preferred NM_propsTerminalConnectionColor]
    }
    $currentCanvas.c itemconfigure $canvasId -fill $fillColor 
  }
  # puts stderr "deselectEdge: pirEdgeIndex $pirEdgeIndex"
  set currentEntries [assoc selectedEdges pirDisplay $reportNotFoundP \
                         $oldvalMustExistP]
  lremove currentEntries $pirEdgeIndex
  arepl selectedEdges $currentEntries pirDisplay $reportNotFoundP \
      $oldvalMustExistP
  set index [lsearch -exact $g_NM_highlightedEdgeList $pirEdgeIndex]
  if {$index >= 0} {
    set g_NM_highlightedEdgeList [lreplace $g_NM_highlightedEdgeList $index $index]
  }
  if {($canvasRootId == 0) && [string match $g_NM_selectedEdge ""]} {
    # reset Attention -- only if we are not moving an edge
    canvasEnter
  }
}


## update the buttonTo/buttonFrom & nodeFrom/nodeTo in a pirEdge 
## structure for a new pirNode
## 04aug97 wmt: taken from redrawNode
proc updateNodeEdges { newPirNodeIndex oldPirNodeIndex oldWindow } {
  global g_NM_edgesOfRedrawNode pirNode pirEdge 

  set reportNotFoundP 0; set oldvalMustExistP 1; set returnOldvalP 1
  set edgesFrom [assoc edgesFrom g_NM_edgesOfRedrawNode $reportNotFoundP]
  arepl edgesFrom $edgesFrom pirNode($newPirNodeIndex)
  set edgesTo [assoc edgesTo g_NM_edgesOfRedrawNode $reportNotFoundP]
  arepl edgesTo $edgesTo pirNode($newPirNodeIndex)

  # update edges of destroyed node 
  set newWindow [assoc window pirNode($newPirNodeIndex)]
  # create regsub expression
  set indx [string first "?" $oldWindow]
  if {$indx == -1} {
    set oldWindowRegsub $oldWindow
  } else {
    set oldWindowRegsub [string range $oldWindow 0 [expr {$indx - 1}]]
    append oldWindowRegsub \\\?
    append oldWindowRegsub [string range $oldWindow [expr {1 + $indx}] end]
  }
  # puts stderr "updateNodeEdges: oldWindowRegsub `$oldWindowRegsub' oldWindow $oldWindow newWindow $newWindow"
  # puts stderr "updateNodeEdges: edgesFrom [assoc edgesFrom g_NM_edgesOfRedrawNode]"
  # puts stderr "updateNodeEdges: edgesTo [assoc edgesTo g_NM_edgesOfRedrawNode]"
  # delimit (with '.') regsub expressions to prevent
  # w7 to be repleced by w275, being applied to w75 => w2755 -- bogus!!
  # 09apr02 wmt
  foreach numList $edgesFrom {
    foreach n $numList {
      regsub -all "$oldWindowRegsub\\\." $pirEdge($n) "$newWindow." tmp
      set pirEdge($n) $tmp
      set nodeFrom [assoc nodeFrom pirEdge($n)]
      if {$nodeFrom == $oldPirNodeIndex} {
        arepl nodeFrom $newPirNodeIndex pirEdge($n)
      } else {
        set nodeTo [assoc nodeTo pirEdge($n)]
        if {$nodeTo == $oldPirNodeIndex} {
          arepl nodeTo $newPirNodeIndex pirEdge($n)
        } else {
          set str "updateNodeEdges: oldPirNodeIndex $oldPirNodeIndex"
          error "$str not found in pirEdge($n)"
        }
      }
    }
  }

  foreach numList $edgesTo {
    foreach n $numList {
      regsub -all "$oldWindowRegsub\\\." $pirEdge($n) "$newWindow." tmp
      set pirEdge($n) $tmp
      set nodeFrom [assoc nodeFrom pirEdge($n)]
      if {$nodeFrom == $oldPirNodeIndex} {
        arepl nodeFrom $newPirNodeIndex pirEdge($n)
      } else {
        set nodeTo [assoc nodeTo pirEdge($n)]
        if {$nodeTo == $oldPirNodeIndex} {
          arepl nodeTo $newPirNodeIndex pirEdge($n)
        } else {
          set str "updateNodeEdges: oldPirNodeIndex $oldPirNodeIndex"
          error "$str not found in pirEdge($n)"
        }
      }
    }
  }
}


## redraw a node's edges
## 05jun96 wmt: new
## 15jun96 wmt: do not redraw edges already drawn via displayGroupNodes
## 24oct96 wmt: add g_NM_canvasRedrawP checks for displayGroupNodes
proc redrawNodeEdges { canvas nodeInstanceName widgetsExistP } {
  global g_NM_edgesOfRedrawNode pirEdge g_NM_newEdgeNumList
  global g_NM_canvasRedrawP

  # do not redraw edges if same term type terminals do not exist
  # puts stderr "redrawNodeEdges g_NM_edgesOfRedrawNode $g_NM_edgesOfRedrawNode"
  set numBreaks 0; set newEdgeNumList {}
  set ignoreEdgesFromP 1; set ignoreEdgesToP 0
  if {(! $widgetsExistP) || $g_NM_canvasRedrawP} {
    set ignoreEdgesFromP 0
  }
  foreach numList [assoc edgesFrom g_NM_edgesOfRedrawNode] {
    foreach n $numList {
      if {[lsearch -exact $g_NM_newEdgeNumList $n] == -1} {
        set interimXYList [assoc interimXYList pirEdge($n)]
        set newEdgeNum [redrawEdge $canvas $n $ignoreEdgesFromP $ignoreEdgesToP \
            $numBreaks $interimXYList $nodeInstanceName $widgetsExistP]
        if {$newEdgeNum != 0} {
          lappend newEdgeNumList $newEdgeNum
        }
      }
    }
  }

  set ignoreEdgesFromP 0; set ignoreEdgesToP 1
  if {(! $widgetsExistP) || $g_NM_canvasRedrawP} {
    set ignoreEdgesToP 0
  }
  foreach numList [assoc edgesTo g_NM_edgesOfRedrawNode] {
    foreach n $numList {
      if {[lsearch -exact $g_NM_newEdgeNumList $n] == -1} {
        set interimXYList [assoc interimXYList pirEdge($n)]
        set newEdgeNum [redrawEdge $canvas $n $ignoreEdgesFromP $ignoreEdgesToP \
            $numBreaks $interimXYList $nodeInstanceName $widgetsExistP]
        if {$newEdgeNum != 0} {
          lappend newEdgeNumList $newEdgeNum
        }
      }
    }
  }
  set g_NM_edgesOfRedrawNode {}
}


## 12jan96 wmt: new
##              redraw an edge between two nodes, if matching terminal
##              component types exist
## 06mar96 wmt: replace interimY with interimXYList
## 17may96 wmt: handle port edges
## 07jun96 wmt: return edge number
proc redrawEdge {canvas pirEdgeIndex ignoreEdgesFromP ignoreEdgesToP \
    numBreaks interimXYList nodeInstanceName widgetsExistP } {
  global pirNode pirEdges g_NM_newEdgeNumList pirEdge

  set edge1 0; set checkTypesP 0
  # set str "redrawEdge pirEdgeIndex $pirEdgeIndex"
  # puts stderr "$str g_NM_newEdgeNumList $g_NM_newEdgeNumList"
  if {[lsearch -exact $g_NM_newEdgeNumList $pirEdgeIndex] == -1} {
    getEdgeTerminals $pirEdgeIndex terminalFrom buttonFrom \
        terminalTo buttonTo
    set portEdgeType [isThisAPortEdge $pirEdgeIndex]
    set documentation [assoc documentation pirEdge($pirEdgeIndex)]
    set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]

    cutEdge $canvas $pirEdgeIndex $ignoreEdgesFromP $ignoreEdgesToP $widgetsExistP

    # if {[componentTerminalsEqualP $terminalFrom $terminalTo]}  
      # redraw edge
      # puts stderr "redrawEdge buttonTo $buttonTo buttonFrom $buttonFrom"
      set newPirEdgeIndex [mkEdge $buttonTo $buttonFrom $numBreaks $interimXYList \
          $portEdgeType $canvas $checkTypesP $documentation $abstractionType]
      # puts stderr "redrawEdge old $pirEdgeIndex new $newPirEdgeIndex"
      global pirEdge($newPirEdgeIndex)
    
  }
  return $newPirEdgeIndex
}


## do not create input/output/port terminals for component or module
## if those terminals are of class name *TERMINATOR
## 26mar98 wmt: new
proc removeTerminatorTerminals { mkNodeArgsListRef } {
  upvar $mkNodeArgsListRef mkNodeArgsList

  set nodeClassType [assoc nodeClassType mkNodeArgsList]
  set nodeState [assoc nodeState mkNodeArgsList]
  set nodeInstanceName [assoc nodeInstanceName mkNodeArgsList]
  set reportNotFoundP 0
  
  # newly instantiated modules do not have input_terminals, etc.
  # they are created when the module/component is saved
  if {[string match $nodeClassType component] || \
          ([string match $nodeClassType module] && \
               (! [string match $nodeState "parent-link"]))} {
#     if {[string match $nodeInstanceName "MOD-TEST-A"]} {
#       puts stderr "\nremoveTerminatorTerminals B: mkNodeArgsList $mkNodeArgsList"
#     }
    set input_terminals [assoc input_terminals mkNodeArgsList $reportNotFoundP]
    set inputs [assoc inputs mkNodeArgsList]
    set numInputs [assoc numInputs mkNodeArgsList]
    set newInputs {}; set newInCnt 1
    for {set i 0} {$i < [llength $inputs]} {incr i 2} {
      set terminalForm [lindex $inputs [expr {1 + $i}]]
      set inputIsTerminatorP 0 
      foreach internalTerminalName $input_terminals {
        if {[regexp "&IT_" $internalTerminalName]} {
          # this is a terminator
          set terminalName [getTerminalName $internalTerminalName]
          # remove it from `inputs'
          if {[string match $terminalName [assoc terminal_name terminalForm]]} {
            set inputIsTerminatorP 1
            break
          }
        }
      }
      if {! $inputIsTerminatorP} {
        lappend newInputs "in$newInCnt" $terminalForm
        incr newInCnt
      }
    }
    arepl inputs $newInputs mkNodeArgsList 
    arepl numInputs [expr {$newInCnt - 1}] mkNodeArgsList

    set output_terminals [assoc output_terminals mkNodeArgsList $reportNotFoundP]
    set outputs [assoc outputs mkNodeArgsList]
    set numOutputs [assoc numOutputs mkNodeArgsList]
    set newOutputs {}; set newOutCnt 1
    for {set i 0} {$i < [llength $outputs]} {incr i 2} {
      set terminalForm [lindex $outputs [expr {1 + $i}]]
      set outputIsTerminatorP 0
      foreach internalTerminalName $output_terminals {
        if {[regexp "&OT_" $internalTerminalName]} {
          # this is a terminator
          set terminalName [getTerminalName $internalTerminalName]
          # remove it from `outputs'
          if {[string match $terminalName [assoc terminal_name terminalForm]]} {
            set outputIsTerminatorP 1
            break
          }
        }
      }
      if {! $outputIsTerminatorP} {
        lappend newOutputs "out$newOutCnt" $terminalForm
        incr newOutCnt
      }
    }
    arepl outputs $newOutputs mkNodeArgsList 
    arepl numOutputs [expr {$newOutCnt - 1}] mkNodeArgsList

    set port_terminals [assoc port_terminals mkNodeArgsList $reportNotFoundP]
    set outputs [assoc outputs mkNodeArgsList]
    set numOutputs [assoc numOutputs mkNodeArgsList]
    set newOutputs {}; set newOutCnt 1
    for {set i 0} {$i < [llength $outputs]} {incr i 2} {
      set terminalForm [lindex $outputs [expr {1 + $i}]]
      set portIsTerminatorP 0
      foreach internalTerminalName $port_terminals {
        if {[regexp "&PT_" $internalTerminalName]} {
          # this is a terminator
          set terminalName [getTerminalName $internalTerminalName]
          # remove it from `outputs'
          if {[string match $terminalName [assoc terminal_name terminalForm]]} {
            set portIsTerminatorP 1
            break
          }
        }
      }
      if {! $portIsTerminatorP} {
        lappend newOutputs "out$newOutCnt" $terminalForm
        incr newOutCnt
      }
    }
    arepl outputs $newOutputs mkNodeArgsList 
    arepl numOutputs [expr {$newOutCnt - 1}] mkNodeArgsList

#     if {[string match $nodeInstanceName "MOD-TEST-A"]} {
#       puts stderr "\nremoveTerminatorTerminals A: mkNodeArgsList $mkNodeArgsList"
#     }
  }
}


## 11oct95 wmt: new
## 25oct95 wmt: add  -highlightThickness 0 to all widgets (Tk4.0)
proc drawFiller { windowPath } {
  global g_NM_icon_width 
  canvas $windowPath.icon -width $g_NM_icon_width -height 0.0 \
      -highlightthickness 0 -borderwidth 1.0
}



        










