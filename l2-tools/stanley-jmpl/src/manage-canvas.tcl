# $Id: manage-canvas.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## manage multiple canvases

## open a "defmodule" to display its components
## eventWindowPath widget is not deleted since it is active 
## as the key-stroke bound event.  it is deleted on next group event
## eventWindowPath == "" when called by pirRedraw
## 04jun96 wmt: new
## 29jun96 wmt: implement multiple canvases
## 09dec96 wmt: change from g_NM_instanceToNode to g_NM_componentToNode
proc openNodeGroup { nodeInstanceName nodeClassType eventWindowPath } {
  global g_NM_currentNodeGroup g_NM_parentNodeGroupList
  global pirNode pirEdges pirDisplay pirNode 
  global g_NM_processingNodeGroupP pirNodes g_NM_moduleToNode
  global g_NM_currentCanvas pirGenInt_global
  global g_NM_rootInstanceName g_NM_componentToNode
  global g_NM_schematicMode g_NM_IPCp g_NM_processingFileOpenP
  global g_NM_recursiveInstantiationP g_NM_canvasIdToPirNode
  global g_NM_instantiatableSchematicExtension
  global g_NM_recursiveIncludeModulesTree g_NM_vmplTestModeP 
  global g_NM_pendingPirEdgesList g_NM_showIconLabelBalloonsP
  global g_NM_acceleratorStem g_NM_nodeGroupToInstances
  global g_NM_showNodeLegendBarP g_NM_testInstanceName
  global g_NM_testPermBalloonsState g_NM_menuStem
  global g_NM_edgeConnectionFailedList g_NM_advisoryRootWindow 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "openNodeGroup: `$backtrace'"
  # puts stderr "   g_NM_processingFileOpenP $g_NM_processingFileOpenP"
  # set str "openNodeGroup: eventWindowPath $eventWindowPath"
  # puts stderr "$str nodeInstanceName $nodeInstanceName"
  # puts stderr "openNodeGroup: nodeClassType $nodeClassType "
  set canvasRoot {}; set reportNotFoundP 0; set errorDialogP 1
  set caller "openNodeGroup"
  set canvasRootId [getCanvasRootId $eventWindowPath canvasRoot]
  if {[string match $nodeClassType module]} {
    set nodeNum [assoc-array $nodeInstanceName g_NM_moduleToNode]
    set componentNodeNum nil
  } elseif {[string match $nodeClassType component]} {
    set nodeNum [assoc-array $nodeInstanceName g_NM_componentToNode]
    set componentNodeNum $nodeNum
  } else {
    error "openNodeGroup: nodeClassType $nodeClassType not handled"
  }
  if {$g_NM_showIconLabelBalloonsP} {
    hideIconLabelBalloons $caller $canvasRootId
  }
  # puts stderr "openNodeGroup: nodeInstanceName $nodeInstanceName nodeNum $nodeNum"
  set g_NM_processingNodeGroupP 0
  deselectNode $nodeNum $eventWindowPath
  # this is set to be used by canvasB1Release to prevent "skeleton" rectangles
  set g_NM_processingNodeGroupP 1
  set xOverlay 0; set yOverlay 0
  set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  set xView [$canvas xview]
  set yView [$canvas yview]
  # puts stderr "openNodeGroup: g_NM_processingNodeGroupP $g_NM_processingNodeGroupP"
  set nodeState [assoc nodeState pirNode($nodeNum)]
  # puts stderr "openNodeGroup: nodeState $nodeState"
  set nodeClassName [assoc nodeClassName pirNode($nodeNum)]
  set parentNodeGroupList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
  # puts stderr "openNodeGroup: in parentNodeGroupList $parentNodeGroupList"
  if {[string match $nodeState "parent-link"]} {
    # this is a parent link 
    # moving up a level
    set openDirection up
    set parentNodeGroupList [lrange $parentNodeGroupList 1 end]
    setCanvasRootInfo g_NM_parentNodeGroupList $parentNodeGroupList $canvasRootId
    set currentNodeGroup [lindex $parentNodeGroupList 0]
    setCanvasRootInfo g_NM_currentNodeGroup $currentNodeGroup $canvasRootId
  } else {
    # this is a defmodule
    # moving down a level
    set openDirection down
    set parentNodeGroupList [linsert $parentNodeGroupList 0 $nodeInstanceName]
    setCanvasRootInfo g_NM_parentNodeGroupList $parentNodeGroupList $canvasRootId
    set currentNodeGroup $nodeInstanceName 
    setCanvasRootInfo g_NM_currentNodeGroup $nodeInstanceName $canvasRootId 
  }
  # set str "openNodeGroup: canvasRootId $canvasRootId currentCanvas"
  # puts stderr "$str [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]"
  # puts stderr "openNodeGroup: out parentNodeGroupList $parentNodeGroupList"

  if {[string match $g_NM_rootInstanceName $currentNodeGroup]} {
    enableEditingMenus
    set editP 1
  } else {
    disableEditingMenus
    set editP 0
  }
  buildEditDefinitionCascade $nodeClassType $canvasRootId $editP 
  if {! $g_NM_processingFileOpenP} {
    standardMouseClickMsg $canvasRootId
  }
  
  if {[string match $g_NM_schematicMode "operational"] && \
          (! $g_NM_processingFileOpenP) && $g_NM_showNodeLegendBarP} {
    set nodeClassType [assoc nodeClassType pirNode($nodeNum)]
    if {[string match $nodeClassType module]} {
      changeLegendToModule $canvasRootId
    } else {
      changeLegendToComponent $canvasRootId 
    }
  }
  # puts stderr "\nopenNodeGroup: g_NM_currentNodeGroup $currentNodeGroup"
  # puts stderr "openNodeGroup: g_NM_parentNodeGroupList $parentNodeGroupList"
  # window names must be lower case
  # puts stderr "openNodeGroup: canvasRootId `$canvasRootId'"
  set canvasRoot [getCanvasRoot $canvasRootId]
  set canvas "$canvasRoot.canvas.[convertToTclSyntax $currentNodeGroup]"
  if {! [winfo exists $canvas]} {
    createCanvas $canvas $xOverlay $yOverlay
    if {! [string match $eventWindowPath ""]} {
      set parentNodeName [lindex $parentNodeGroupList 1]
      append parentNodeName "_P"
      set uniqueParentNodeName [pirGenSym $parentNodeName]
      buildParentNode $uniqueParentNodeName $canvas.c $nodeClassName
    }
    displayDotWindowTitle $canvasRootId 
  } else {
    overlayCurrentCanvas $canvas \
        [getCanvasRootInfo g_NM_currentCanvas $canvasRootId] \
        $componentNodeNum $xOverlay $yOverlay
    # displayDotWindowTitle call done in overlayCurrentCanvas
  }
  set lengthParentNodeGroupList [llength $parentNodeGroupList]
  set recursionLevel [expr {$lengthParentNodeGroupList - 2}]
  # puts stderr "openNodeGroup: recursionLevel $recursionLevel canvasRootId $canvasRootId"
  if {[string match $openDirection down] && [string match $nodeClassType module] && \
          ($recursionLevel > 0)} {
    if {! $g_NM_recursiveInstantiationP} {
      # layout mode
      # get list of instance names on current canvas
      set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
      set currentInstanceNames {}
      set idIndexAlist [assoc-array $currentCanvas.c g_NM_canvasIdToPirNode] 
      for {set i 0} {$i < [llength $idIndexAlist]} {incr i 2} {
        set pirIndex [lindex $idIndexAlist [expr {1 + $i}]]
        lappend currentInstanceNames [assoc nodeInstanceName pirNode($pirIndex)]
      }
      # get included modules from parent recursion level
      set includedModulesAList \
          [assoc $nodeInstanceName \
               g_NM_recursiveIncludeModulesTree([expr {$recursionLevel - 1}])]
      set nodesExistP 1
      foreach instanceName [alist-keys includedModulesAList] {
        if {[lsearch -exact $currentInstanceNames $instanceName] == -1} {
          set nodesExistP 0; break
        }
      }
      if {! $nodesExistP} {
        set defmoduleArgsVars {}; set defmoduleArgsValues {}
        # create nodes and links on the opened canvas
        recursiveDefmoduleInstantiation $nodeInstanceName $includedModulesAList \
            $defmoduleArgsVars $defmoduleArgsValues $caller $recursionLevel \
            $nodeClassType $canvasRootId $errorDialogP 
      }
      # this notifies user of invalid connections when opening lower level
      # modules, which have leaf components with changed terminal types
      # inherited up to this level
      if {[llength $g_NM_edgeConnectionFailedList] != 0} {
        set str "These connections are no longer valid due to"
        append str "\nterminal name or type mismatches:"
        foreach connection $g_NM_edgeConnectionFailedList {
          append str "\n==>> [lindex $connection 0] [lindex $connection 1]"
          append str "\n......... [lindex $connection 2] [lindex $connection 3]"
        }
        set dialogList [list tk_dialogNoGrab ${g_NM_advisoryRootWindow}.dfailed \
                            "ADVISORY" $str warning 0 {DISMISS}]
        eval $dialogList
      }
    }
    if {$g_NM_recursiveInstantiationP && (! $g_NM_processingFileOpenP)} {
      # operational mode
      # draw links on the opened canvas 
      # set str "\n\nopenNodeGroup: g_NM_pendingPirEdgesList"
      # puts stderr "$str $g_NM_pendingPirEdgesList"

      createPendingEdges $canvasRootId 

      # set str "\n\nopenNodeGroup: still g_NM_pendingPirEdgesList"
      # puts stderr "$str $g_NM_pendingPirEdgesList"
    }
  }

  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  if {$recursionLevel > 0} {
    ## handle canvas parent back accelerator
    # find new parent node
    set canvasParentNodeIndex 0
    set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
    set instanceIndexPairList [assoc-array $currentNodeGroup g_NM_nodeGroupToInstances]
    for {set i 0} {$i < [llength $instanceIndexPairList]} {incr i 2} {
      set nodeInstanceName [lindex $instanceIndexPairList $i]
      set pirNodeIndex [lindex $instanceIndexPairList [expr {1 + $i}]]
      if {[string match [assoc nodeState pirNode($pirNodeIndex)] \
               "parent-link"]} {
        set canvasParentNodeIndex $pirNodeIndex
        # make eventWindowPath a non-existant window -- it is just needed
        # to get the canvasRootId.  If the actual eventWindowPath, its
        # select coloring gets screwed up
        set parentList [list $pirNodeIndex ${eventWindowPath}99]
        setCanvasRootInfo g_NM_canvasParentNodeIdList $parentList \
            $canvasRootId 
        break
      }
    }
    if {$canvasParentNodeIndex == 0} {
      error "openNodeGroup: could not find parent node in group $g_NM_currentNodeGroup"
    }
    set displayLabel [getModuleParentLabel $canvasRootId]
    balloonhelp $acceleratorRoot.canvas_back.label -side right $displayLabel
    # puts stderr "acceleratorRoot $acceleratorRoot.canvas_back.arrow"
    $acceleratorRoot.canvas_back.arrow config -state normal 
    $acceleratorRoot.canvas_back.label config -state normal 
  } else {
    $acceleratorRoot.canvas_back.arrow config -state disabled 
    $acceleratorRoot.canvas_back.label config -state disabled 
    balloonhelp $acceleratorRoot.canvas_back.label -side right ""
  }
  # puts stderr "openNodeGroup: g_NM_showIconLabelBalloonsP $g_NM_showIconLabelBalloonsP"
  if {$g_NM_showIconLabelBalloonsP} {
    showIconLabelBalloons $caller $canvasRootId
  }
  # ensure that canvas is scrolled to 0,0 after possible scrolling by
  # scrollCanvasToExposeConnectionToBeDrawn which makes sure that
  # connections that are not initially exposed, are drawn properly
  set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  # prevent jerking by using initial values prior to pirRedraw
  $canvas xview moveto [lindex $xView 0]
  $canvas yview moveto [lindex $yView 0] 

  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  if {$g_NM_vmplTestModeP && \
          ([preferred StanleyTestPermanentBalloons] == "on") && \
          (! [string match $currentCanvas \
                  "${canvasRoot}.canvas.$g_NM_rootInstanceName"])} {
    set menuRoot $canvasRoot.$g_NM_menuStem
    if {[string match $currentCanvas \
             "${canvasRoot}.canvas.$g_NM_testInstanceName"]} {
      if {$g_NM_testPermBalloonsState == "show"} {
        $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
            -state disabled
        $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
            -state normal
      } else {
        $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
            -state disabled
        $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
            -state normal
      }
    } else {
      # do not let user mess with test perm balloons unless they are
      # at the level of the test instance
      $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
          -state disabled
      $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
          -state disabled
    }
  }
  # enable node selection coloring => yellow background
  enableMouseSelection $canvas
  update
}


## display a node with no inputs/outputs/ports
## 04jun96 wmt: new
## 29jun96 wmt: implement multiple canvases
## 10sep96 wmt: pass in parentNodeClassName
## 30apr97 wmt: hide ROOT_P nodes from user
## 02oct97 wmt: replace variable root node name with module class
proc buildParentNode { parentNodeInstanceName canvasC parentNodeClassName \
    { tempNodeRef "" } } {
  upvar $tempNodeRef tempNode
  global pirNode g_NM_livingstoneDefmoduleName
  global g_NM_rootInstanceName 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "buildParentNode: `$backtrace'"
  # puts stderr "buildParentNode B parentNodeInstanceName $parentNodeInstanceName"
  set prefix ""; set postfix ""
  if {[string match [string index $parentNodeInstanceName 0] "?"]} {
    set index [string first "_P" $parentNodeInstanceName]
    set prefix [string range $parentNodeInstanceName 0 [expr {$index - 1}]]
    if {[string match $prefix $g_NM_rootInstanceName]} {
      set postfix [string range $parentNodeInstanceName $index end]
      # hang all parent nodes off the root module
      set parentNodeInstanceName "${prefix}.$g_NM_livingstoneDefmoduleName"
      append parentNodeInstanceName $postfix
    }
  }
  # puts stderr "buildParentNode A parentNodeInstanceName $parentNodeInstanceName "
  # puts stderr "   g_NM_rootInstanceName $g_NM_rootInstanceName  prefix $prefix postfix $postfix "
  # set str "buildParentNode: parentNodeInstanceName $parentNodeInstanceName"
  # puts stderr "$str canvasC $canvasC"
  set mkNodeArgList {}; set outputMsgP 0
  lappend mkNodeArgList nodeInstanceName $parentNodeInstanceName \
      nodeState "parent-link" nodeStateBgColor [preferred StanleyModuleNodeBgColor] \
      nodeClassName $parentNodeClassName numInputs 0 numOutputs 0 \
      fgColor black nodeClassType "module" inputs {} outputs {} 
  if {[info exists tempNode]} {
    # being called by pirRedraw
    lappend mkNodeArgList nodeGroupName [assoc nodeGroupName tempNode] \
         parentNodeGroupList [assoc parentNodeGroupList tempNode]
  }
  set nodeNum [mkNode $canvasC 5 5 -1 -1 mkNodeArgList "module" $outputMsgP]
  # if {$nodeNum  == -1} then parent node already exists
  # puts stderr "buildParentNode: nodeNum $nodeNum"
#   if {$nodeNum  == -1} {
#     ## older scm files have duplicate parent-link instance names
#     set parentNodeInstanceNameRoot [getModuleParentLinkLabel \
#                                         $parentNodeInstanceName]
#     append parentNodeInstanceNameRoot "_P"
#     set uniqueName [pirGenSym $parentNodeInstanceNameRoot]
#     arepl nodeInstanceName $uniqueName mkNodeArgList
#     # puts stderr "\nbuildParentNode: uniqueName $uniqueName\n"
#     set nodeNum [mkNode $canvasC 5 5 -1 -1 mkNodeArgList "module"]
#     puts stderr "buildParentNode: 2 nodeNum $nodeNum"
#   }
}


## use place geometry mgr to overlay current canvas
## 29jun96 wmt: new
proc overlayCurrentCanvas { newCanvasPath oldCanvasPath componentNodeNum \
                                { x 0} { y 0} } {
  global g_NM_currentCanvas g_NM_classDefType g_NM_processingFileOpenP
  global g_NM_livingstoneDefcomponentNameVar pirNode
  global g_NM_livingstoneDefmoduleNameVar g_NM_rootInstanceName
  global g_NM_schematicMode 

  if {(! [string match $g_NM_rootInstanceName root]) && \
          [string match $newCanvasPath $oldCanvasPath]} {
    set str "overlayCurrentCanvas: newCanvasPath $newCanvasPath and "
    error "$str oldCanvasPath $oldCanvasPath are the same"
  }
  set canvasRoot {}; set reportNotFoundP 0
  set canvasRootId [getCanvasRootId $newCanvasPath canvasRoot]
#   if {[string match $g_NM_classDefType component]} {
#     set userCanvas "$canvasRoot.canvas.$g_NM_livingstoneDefcomponentNameVar"
#   } else {
#     set userCanvas "$canvasRoot.canvas.$g_NM_livingstoneDefmoduleNameVar" 
#   }
  set userCanvas "$canvasRoot.canvas.$g_NM_rootInstanceName"
  # puts stderr "overlayCurrentCanvas: userCanvas $userCanvas newCanvasPath $newCanvasPath"
  # puts stderr "  g_NM_processingFileOpenP $g_NM_processingFileOpenP"
  # puts stderr "  componentNodeNum $componentNodeNum"
  if {(! $g_NM_processingFileOpenP) || \
          ($g_NM_processingFileOpenP && \
               [string match $newCanvasPath $userCanvas])} {
    # during File->Open Class Def, this prevents lower canvases from being
    # exposed to the user.
    # However with Tcl/Tk 8.0, x/y locations of canvas window buttons are not
    # computed until the canvas is exposed.  For layout mode, this is
    # ok since canvases are exposed as the user opens them -- creating
    # nodes and links for the exposed canvas.
    # In operational mode, all nodes must be drawn at init time so they
    # can respond to telemetry -- thus to have links between components/
    # modules drawn, we draw them the user first opens that canvas.

    # set str "overlayCurrentCanvas: newCanvasPath $newCanvasPath"
    # puts stderr "$str oldCanvasPath $oldCanvasPath x $x y $y"
    # place it in the parent: .master.canvas or .slave_n.canvas
    place $newCanvasPath -in $canvasRoot.canvas -relwidth 1 -relheight 1 -x $x -y $y
    place forget $oldCanvasPath

    update

    if {! [string match $componentNodeNum nil]} {
      # redraw mode transitions for non-top-level canvases
      set transitionModesToDraw [assoc transitionModesToDraw \
                                     pirNode($componentNodeNum)]
      set canvasRoot [getCanvasRoot $canvasRootId]
      if {[llength $transitionModesToDraw] > 0} {
        set arrowIdList {}
        foreach modeIndex [assoc $canvasRootId transitionModesToDraw] {
          set transitionList [assoc transitions pirNode($modeIndex) \
                                  $reportNotFoundP]
          set canvas [getCanvasFromWindow [assoc window \
                                               pirNode($modeIndex)]]
          set canvas "$canvasRoot[widgetPathDescendents $canvas]"
          foreach transition $transitionList {
            if {[llength $transition] > 4} {
              set startPirNodeIndex [assoc startNode transition]
              set stopPirNodeIndex [assoc stopNode transition]
              lappend arrowIdList \
                  [redrawModeTransitions $canvas $startPirNodeIndex \
                       $stopPirNodeIndex]
              # puts stderr " redrawModeTransitions "
            }
          }
        }
        arepl $canvasRootId {} transitionModesToDraw 
        arepl transitionModesToDraw $transitionModesToDraw \
            pirNode($componentNodeNum)
        # if arrow is overlapped by line , raise it to top
        foreach arrowId $arrowIdList {
          $canvas raise $arrowId
        }
      }
    }
    displayDotWindowTitle $canvasRootId
  }
  setCanvasRootInfo g_NM_currentCanvas $newCanvasPath $canvasRootId 
  # puts stderr "overlayCurrentCanvas: g_NM_currentCanvas $newCanvasPath"
}


## enable mouse selection of nodes and edges
## enable node selection coloring => yellow background
## 15may97 wmt: new
proc enableMouseSelection { canvas } {
  global g_NM_currentCanvas g_NM_processingNodeGroupP

  set canvasRoot {}
  set canvasRootId [getCanvasRootId $canvas canvasRoot]
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set g_NM_processingNodeGroupP 1
  set mouseX [winfo pointerx $currentCanvas]
  set mouseY [winfo pointery $currentCanvas]
  # puts stderr "enableMouseSelection: pointerx $mouseX pointery $mouseY"
  set rootX [winfo rootx $currentCanvas]
  set rootY [winfo rooty $currentCanvas]
  # puts stderr "enableMouseSelection: rootx $rootX rooty $rootY"
  canvasB1Release $currentCanvas.c [expr {$mouseX - $rootX}] \
      [expr {$mouseY - $rootY}]
  set g_NM_processingNodeGroupP 0
  update
}


## create a new root canvas under . -- provide
## multiple canvas view for user
## 26aug97 wmt: new
proc createNewRootCanvas { { xPos 0 } { yPos 0 } } {
  global g_NM_canvasRootIdCnt g_NM_classDefType pirNode
  global g_NM_rootInstanceName
  global g_NM_moduleToNode g_NM_livingstoneDefmoduleName
  global g_NM_livingstoneDefmoduleNameVar pirFileInfo 
  global g_NM_livingstoneDefmoduleFileName 
  global g_NM_instantiatableSchematicExtension
  global g_NM_processingFileOpenP 

  set errorDialogP 1
  # puts stderr "createNewRootCanvas: g_NM_canvasRootIdCnt $g_NM_canvasRootIdCnt"
  mainWindow $g_NM_canvasRootIdCnt $xPos $yPos 

  set canvasRoot [getCanvasRoot $g_NM_canvasRootIdCnt]
  tkwait visibility $canvasRoot 

  if {$g_NM_canvasRootIdCnt > 0} {
    set severity 1; set g_NM_processingFileOpenP 1; set msg2 ""
    pirWarning [format {Please Wait: %s schematic being built --} \
                      [workname $pirFileInfo(filename)]] \
        $msg2 $severity $g_NM_canvasRootIdCnt
    update
    # g_NM_currentCanvas is set by mainWindow call
    setCanvasRootInfo g_NM_currentNodeGroup root $g_NM_canvasRootIdCnt
    setCanvasRootInfo g_NM_parentNodeGroupList {root} $g_NM_canvasRootIdCnt 
    set caller "createNewRootCanvas"
    # cannot use read_workspace & pirRedraw to populate slave canvas
    # because they will overwrite pirNode, pirEdge arrays, etc
    # recursionLevel is -1, since instantiateDefmoduleFromIscm is called,
    # not recursiveDefmoduleInstantiation
    set defmoduleArgsVars {}; set defmoduleArgsValues {}
    set nodeClassType module 
    set pirClassIndex $g_NM_livingstoneDefmoduleName
    set classVars [getClassValue $nodeClassType $pirClassIndex class_variables]
    set argsVars [getClassVarDefaultValue "args" classVars]
    if {[string match $argsVars ""]} {
      # defdevice has no args - hence no values
      set argsValues {}
    } else {
      # but if instantiating a defmodule which has arguments
      set argsValues $argsVars
    }
    set recursionLevel -1
    set pirNodeIndex [assoc-array $g_NM_rootInstanceName g_NM_moduleToNode]
    ## build included module entry for toplevel defmodule
    set window $canvasRoot.canvas.root.c.w99
    set attList [list nodeClassName $g_NM_livingstoneDefmoduleName \
                     nodeClassType $nodeClassType \
                     pirNodeIndex $pirNodeIndex argsValues $argsValues \
                     window $window nodeX 220 nodeY 170]

    openNodeGroup $g_NM_rootInstanceName $nodeClassType $window 
    update

    set schematicFileName $g_NM_livingstoneDefmoduleFileName
    append schematicFileName $g_NM_instantiatableSchematicExtension
    instantiateDefmoduleFromIscm $g_NM_livingstoneDefmoduleName \
        $g_NM_rootInstanceName $schematicFileName \
        $defmoduleArgsVars $defmoduleArgsValues \
        $attList $caller $recursionLevel $g_NM_canvasRootIdCnt $errorDialogP

    puts stderr "\ncreateNewRootCanvas: creating slave canvas $g_NM_canvasRootIdCnt" 
  }
  label_workspace $g_NM_canvasRootIdCnt
  standardMouseClickMsg $g_NM_canvasRootIdCnt
  pirWarning {} {} 0 $g_NM_canvasRootIdCnt 
  update
  set g_NM_processingFileOpenP 0
  mark_scm_unmodified
  incr g_NM_canvasRootIdCnt
}


## destroy a slave canvas
## 26aug97 wmt: new
proc destroyRootCanvas { canvasRootId } {
  global g_NM_canvasRootIdCnt g_NM_canvasIdToPirNode
  global g_NM_parentNodeGroupList g_NM_canvasParentNodeIdList
  global g_NM_currentCanvas g_NM_currentNodeGroup
  global g_NM_windowPathToPirNode g_NM_menuStem g_NM_acceleratorStem
  global g_NM_processingFileOpenP g_NM_showNodeLegendBarP 

  # this causes:
  # bgerror failed to handle background error.
  #  Original error: bad window path name ".slave_1.menu"
  # when File->Quit is selected on the master canvas root
  # destroy ".slave_$canvasRootId"

  set canvasRoot [getCanvasRoot $canvasRootId]
  destroy $canvasRoot.canvas
  destroy $canvasRoot.warnings
  if {$g_NM_showNodeLegendBarP} {
    destroy $canvasRoot.legend
  }
  destroy $canvasRoot.$g_NM_menuStem 
  destroy $canvasRoot.$g_NM_acceleratorStem
  # to make the file menu disappear

  wm withdraw $canvasRoot

  foreach key [array names g_NM_canvasIdToPirNode] {
    if {[string match $key 0]} { continue }
    if {[regexp "\\$canvasRoot\\\.canvas" $key]} {
      adel-array $key g_NM_canvasIdToPirNode
    }
  }
  foreach key [array names g_NM_windowPathToPirNode] {
    if {[string match $key 0]} { continue }
    if {[regexp "\\$canvasRoot\\\.canvas" $key]} {
      adel-array $key g_NM_windowPathToPirNode 
    }
  }
  adel $canvasRootId g_NM_parentNodeGroupList
  adel $canvasRootId g_NM_currentCanvas
  adel $canvasRootId g_NM_currentNodeGroup
  adel $canvasRootId g_NM_canvasParentNodeIdList

  # safety feature -- if slave canvas does not properly complete
  # creation
  set g_NM_processingFileOpenP 0
  puts stderr "\ndestroyRootCanvas: closing slave canvas $canvasRootId"
}


## open canvas to parent of instance 
## 29jun98 wmt: new
proc openCanvasToInstanceParent { pirNodeIndex { canvasRootId 0 } } {
  global pirNode g_NM_nodeGroupToInstances

  # determine path of instances from current canvas to component
  # defined by pirNodeIndex
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
  set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
  # puts stderr "openCanvasToInstanceParent: currentNodeGroup $currentNodeGroup"
  # puts stderr "   parentNodeGroupList (downlist) $parentNodeGroupList"
  # puts stderr "   pirNodeIndex $pirNodeIndex"
  if {[string match $currentNodeGroup \
           [assoc nodeInstanceName pirNode($pirNodeIndex)]]} {
    # we are where we want to be
    return -1
  }
  set instancePathNameList {}; set foundStartP 0
  if {[lsearch -exact $parentNodeGroupList $currentNodeGroup] >= 0} {
    foreach instance [lreverse $parentNodeGroupList] {
      if {! $foundStartP} {
        if {[string match $instance $currentNodeGroup]} {
          set foundStartP 1
        }
      } else {
        lappend instancePathNameList $instance
      }
    }
  } else {
    # we need to go up to a common instance
    getComponentModulePirNodeIndex $currentNodeGroup currentInstanceIndex \
        nodeClassType
    set upList [assoc parentNodeGroupList pirNode($currentInstanceIndex)]
    set downList $parentNodeGroupList
    set upList [linsert $upList 0 $currentNodeGroup]
    set downList [lreverse $parentNodeGroupList]
    # puts stderr "  upList $upList downList $downList"
    foreach instance $upList {
      set index [lsearch -exact $downList $instance]
      # puts stderr "instance $instance index $index"
      if {$index == -1} {
        # find parent-link node to go back up the hierarchy
        set nameIndexAList [assoc-array $instance g_NM_nodeGroupToInstances] 
        for {set i 1} {$i < [llength $nameIndexAList]} {incr i 2} {
          set nodeIndex [lindex $nameIndexAList $i]
          if {[string match [assoc nodeState pirNode($nodeIndex)] \
                   "parent-link"]} {
            set parentLinkInstance [assoc nodeInstanceName pirNode($nodeIndex)]
            break
          }
        }
        lappend instancePathNameList $parentLinkInstance
      } else {
        set instancePathNameList [concat $instancePathNameList \
                                      [lrange $downList [expr {$index + 1}] end]]
        break
      }
    }
  }
  # puts stderr "openCanvasToInstanceParent: instancePathNameList $instancePathNameList"
  openCanvasToInstanceParentDoit $instancePathNameList $canvasRootId
  return $instancePathNameList 
}


## open a canvas via a given module/component path
## 13sep97 wmt: new
proc openCanvasToInstanceParentDoit { instancePathNameList canvasRootId } {

  foreach instanceName $instancePathNameList {
    getComponentModulePirNodeIndex $instanceName pirNodeIndex nodeClassType 
    set canvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c
    set window [getWindowPathFromPirNodeIndex $pirNodeIndex $canvas]

    # puts stderr "openCanvasToInstanceParentDoit: pirNodeIndex $pirNodeIndex window $window"
    openNodeGroup $instanceName $nodeClassType $window
  }
}


## force all edges (connections) to be created, since
## connections are not drawn until the canvas it is on, is displayed.
## so expose all canvases with nodes not yet drawn, then
## return to top canvas
proc createAllEdges { {canvasRootId 0 } } {
  global g_NM_instanceToNode pirNode g_NM_pendingPirEdgesList

  set reportNotFoundP 0
  set currrentCanvasC "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  # createPendingEdges updates g_NM_pendingPirEdgesList 
  while {[llength [set pendingEdges [assoc-array $currrentCanvasC \
                                         g_NM_pendingPirEdgesList \
                                         $reportNotFoundP]]] > 0} {
    foreach edgeForm $pendingEdges {
      set nodeFrom [assoc nodeFrom edgeForm]
      set pirNodeIndex [assoc-array $nodeFrom g_NM_instanceToNode]
      set nodeInstanceName [lindex [assoc parentNodeGroupList pirNode($pirNodeIndex)] 0]
      openCanvasToInstanceParent $pirNodeIndex $canvasRootId

      createPendingEdges $canvasRootId

      puts stderr "Drawing edges for instance $nodeInstanceName"
      break
    }
  }
  # return to top level schematic
  set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
  set pirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
  set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
  set parentNodeGroupList [linsert $parentNodeGroupList 0 $currentNodeGroup]
  set len [llength $parentNodeGroupList]
  # puts stderr "currentNodeGroup $currentNodeGroup parentNodeGroupList $parentNodeGroupList"
  if {$len >= 3} {
    set topInstanceName [lindex $parentNodeGroupList [expr {$len - 3}]]
    set topPirNodeIndex [assoc-array $topInstanceName g_NM_instanceToNode]
    openCanvasToInstanceParent $topPirNodeIndex $canvasRootId
  }
}


## return list of indicies showing on canvas
## 25jun99 wmt: new
proc getNodeIndicesShowing { } {
  global g_NM_nodeGroupToInstances pirNode 
  global g_NM_currentCanvas

  # get list of indices currently displayed 
  # discard parent-links, attributes, and terminators
  set nodeIndicesShowing {}
  set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup]
  set lenParentNodeGroupList [llength [getCanvasRootInfo g_NM_parentNodeGroupList]]
  set instanceIndexPairs $g_NM_nodeGroupToInstances($currentNodeGroup)
  for {set i 1} {$i < [llength $instanceIndexPairs]} {incr i 2} {
    set pirNodeIndex [lindex $instanceIndexPairs $i]
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)] 
    if {([llength [assoc parentNodeGroupList pirNode($pirNodeIndex)]] == \
             $lenParentNodeGroupList) && \
            (! [string match [assoc nodeState pirNode($pirNodeIndex)] \
                    "parent-link"]) && \
            (! [string match $nodeClassName "displayState"]) && \
            (! [string match $nodeClassName "attribute"])} {
      lappend nodeIndicesShowing $pirNodeIndex
    }
  }
}


## set default value of interfaceType for all terminals, if not set
## at the top (editable) level only -- called by fileOpen
## needed for schematics generated prior to 01nov99
## 20oct99 wmt: new
proc setTerminalDefaultInterfaceType { canvasRootId } {
  global g_NM_instanceToNode pirNode pirEdge STANLEY_ROOT 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "setTerminalDefaultInterfaceType: `$backtrace'"
  set reportNotFoundP 0; set returnIndexP 1; set oldvalMustExistP 0
  if {$canvasRootId != 0} {
    return
  }
  set lenParentNodeGroupList [llength [getCanvasRootInfo g_NM_parentNodeGroupList]]
  foreach instanceName [array names g_NM_instanceToNode] {
    if {[string match $instanceName "0"]} {
      continue
    }
    set pirNodeIndex [assoc-array $instanceName g_NM_instanceToNode]
    if {[llength [assoc parentNodeGroupList pirNode($pirNodeIndex)]] == \
            $lenParentNodeGroupList} {
      # at the top (editable) level only
      set nodeState [assoc nodeState pirNode($pirNodeIndex)] 
      set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)] 
      if {[string match $nodeClassType "terminal"] || \
              [string match $nodeClassType "component"] || \
              ([string match $nodeClassType "module"] && \
                   (! [string match $nodeState "parent-link"]))} {
        # set defaults for public/private terminal property, if not already there
        set newInputs {}; set index 0
        set edgesTo [assoc edgesTo pirNode($pirNodeIndex)]
        foreach terminalForm [assoc inputs pirNode($pirNodeIndex)] {
          if {$index % 2} {
            if {[assoc interfaceType terminalForm $reportNotFoundP $returnIndexP] == -1} {
              set edgesToSublist [lindex $edgesTo [expr {$index / 2}]]
              set connectedP [expr {! [string match $edgesToSublist ""]}]
              if {[string match $nodeClassType "terminal"]} {
                set interfaceType public
              } elseif {$connectedP} {
                set interfaceType private
                # change button bitmap from public to private
                set pirEdgeIndex [lindex $edgesToSublist 0]
                set terminalDirection [getTerminalDirection $terminalForm]
                set button buttonTo
                if {$terminalDirection == "OUT"} {
                  set button buttonFrom
                }
                set compModButton [assoc $button pirEdge($pirEdgeIndex)]
                set str "setTerminalDefaultInterfaceType : node $pirNodeIndex connected"
                set str "$str input terminal [expr {($index / 2) + 1}] defaulted to private =>"
                puts stderr "$str \"File->Save Definition\" suggested"
              } else {
                set interfaceType public
              }
              arepl interfaceType $interfaceType terminalForm $reportNotFoundP \
                  $oldvalMustExistP
              if {[string match $interfaceType private]} {
                $compModButton config \
                    -bitmap [getTerminalButtonBitmap $terminalForm inputs]
              }
              mark_scm_modified
            }
          }
          lappend newInputs $terminalForm
          incr index
        }
        arepl inputs $newInputs pirNode($pirNodeIndex)

        set newOutputs {}; set index 0
        set edgesFrom [assoc edgesFrom pirNode($pirNodeIndex)]
        foreach terminalForm [assoc outputs pirNode($pirNodeIndex)] {
          if {$index % 2} {
            if {[assoc interfaceType terminalForm $reportNotFoundP $returnIndexP] == -1} {
              set edgesFromSublist [lindex $edgesFrom [expr {$index / 2}]] 
              set connectedP [expr {! [string match $edgesFromSublist ""]}]
              if {[string match $nodeClassType "terminal"]} {
                set interfaceType public
              } elseif {$connectedP} {
                set interfaceType private
                # change button bitmap from public to private
                set pirEdgeIndex [lindex $edgesFromSublist 0]
                set terminalDirection [getTerminalDirection $terminalForm]
                set button buttonFrom
                if {$terminalDirection == "in"} {
                  set button buttonTo
                }
                set compModButton [assoc $button pirEdge($pirEdgeIndex)]
                set str "setTerminalDefaultInterfaceType: node $pirNodeIndex connected"
                set str "$str output terminal [expr {($index / 2) + 1}] defaulted to private =>"
                puts stderr "$str \"File->Save Definition\" suggested"
              } else {
                set interfaceType public
              }
              arepl interfaceType $interfaceType terminalForm $reportNotFoundP \
                  $oldvalMustExistP 
              if {[string match $interfaceType private]} {
                $compModButton config \
                    -bitmap [getTerminalButtonBitmap $terminalForm outputs] \
                    -anchor center
              }
              mark_scm_modified
            }
          }
          lappend newOutputs $terminalForm
          incr index
        }
        arepl outputs $newOutputs pirNode($pirNodeIndex)
      }
    }
  }
}


## convert instance name or group name from Java dotted-list
## syntax to underscores to be compatible with tcl dotted-path
## syntax
## 18dec99 wmt: new
proc convertToTclSyntax { token } {

  regsub -all "\\\." $token "_" convertedToken
  return $convertedToken
}


## get a window's canvas coordinates, taking into account
## scrolling of the canvas (e.g. .master.canvas.?name.c)
## 13jan00 wmt: new
proc getWindowCanvasXY { canvas window xRootRef yRootRef } {
  upvar $xRootRef xRoot
  upvar $yRootRef yRoot 

  set xScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 2]
  set yScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 3]
  set xFractionOffScreen [lindex [$canvas xview] 0]
  set yFractionOffScreen [lindex [$canvas yview] 0]
  set xScrollOffset [expr {int($xScrollRegion * $xFractionOffScreen)}]
  set yScrollOffset [expr {int($yScrollRegion * $yFractionOffScreen)}]
  # puts stderr "getWindowCanvasXY: xScrollOffset $xScrollOffset yScrollOffset $yScrollOffset"
  set xRoot [expr {[winfo rootx $window] - [winfo rootx .master.canvas] + \
                       $xScrollOffset}]
  set yRoot [expr {[winfo rooty $window] - [winfo rooty .master.canvas] + \
                       $yScrollOffset}]
}


## get canvas visible x/y extents
## 14jan00 wmt: new
proc exposedCanvasExtent { canvas xLeftRef xRightRef yTopRef yBottomRef } {
  upvar $xLeftRef xLeft
  upvar $xRightRef xRight
  upvar $yTopRef yTop
  upvar $yBottomRef yBottom

  set xScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 2]
  set yScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 3]
  set xFractionOffScreen [lindex [$canvas xview] 0]
  set xFractionOnScreen [lindex [$canvas xview] 1] 
  set yFractionOffScreen [lindex [$canvas yview] 0]
  set yFractionOnScreen [lindex [$canvas yview] 1]
  set xLeft [expr {int($xScrollRegion * $xFractionOffScreen)}]
  set yTop [expr {int($yScrollRegion * $yFractionOffScreen)}]
  set xRight [expr {int($xScrollRegion * $xFractionOnScreen)}]
  set yBottom [expr {int($yScrollRegion * $yFractionOnScreen)}]
  # puts stderr "exposedCanvasExtent: xLeft $xLeft xRight $xRight yTop $yTop yBottom $yBottom"
}


## scroll canvas to expose a connection to be drawn by
## x/y coorinates
## use this prior to calling $canvas create line ...
## in drawEdge
## 14jan00 wmt: new
proc scrollCanvasToExposeConnectionToBeDrawn { canvas outCanvasX outCanvasY \
                                                   inCanvasX inCanvasY } {

  # puts stderr "\nscrollCanvasToExposeConnectionToBeDrawn: before"
  exposedCanvasExtent $canvas xLeft xRight yTop yBottom

  set xMin $outCanvasX
  if {$inCanvasX < $outCanvasX} {
    set xMin $inCanvasX
  }  
  set xMax $outCanvasX
  if {$inCanvasX > $outCanvasX} {
    set xMax $inCanvasX
  }
  set yMin $outCanvasY
  if {$inCanvasY < $outCanvasY} {
    set yMin $inCanvasY
  }  
  set yMax $outCanvasY
  if {$inCanvasY > $outCanvasY} {
    set yMax $inCanvasY
  }
  # puts stderr "scrollCanvasToExposeConnectionToBeDrawn: xMin $xMin xMax $xMax yMin $yMin yMax $yMax"
  # puts stderr "  outCanvasX $outCanvasX outCanvasY $outCanvasY inCanvasX $inCanvasX inCanvasY $inCanvasY"
  set connectionOffLeftP 0; set connectionOffRightP 0
  set connectionOffTopP 0; set connectionOffBottomP 0
  if {$xMin < $xLeft} { set connectionOffLeftP 1 }
  if {$xMax > $xRight} { set connectionOffRightP 1 }
  if {$yMin < $yTop} { set connectionOffTopP 1 }
  if {$yMax > $yBottom} { set connectionOffBottomP 1 }
  # set str "scrollCanvasToExposeConnectionToBeDrawn: connectionOffLeftP $connectionOffLeftP"
  # set str "$str connectionOffRightP $connectionOffRightP"
  # set str "$str connectionOffTopP $connectionOffTopP"
  # puts stderr "$str connectionOffBottomP $connectionOffBottomP"
  if {($connectionOffLeftP && $connectionOffRightP) || \
          ($connectionOffTopP && $connectionOffBottomP)} {
    # cannot handle this connection
    error "scrollCanvasToExposeConnectionToBeDrawn: cannot handle this connection"
    return
  }

  set xScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 2]
  set margin 25
  if {$connectionOffBottomP || $connectionOffTopP} {
    set yScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 3]
    set yScrollRegionFloat "${yScrollRegion}.0"
    if {$connectionOffBottomP} {
      set offSet [expr {$yMax + $yTop - $yBottom + $margin}]
    } else {
      # connectionOffTopP
      set offSet [expr {$yMin - $margin}]
    }
    append $offSet ".0"
    set offSetFraction [expr { $offSet / $yScrollRegionFloat }]
    # set str "scrollCanvasToExposeConnectionToBeDrawn: offSetFraction"
    # puts stderr "$str $offSetFraction offSet $offSet"
    $canvas yview moveto $offSetFraction 
  } elseif {$connectionOffRightP || $connectionOffLeftP} {
    set xScrollRegion [lindex [lindex [$canvas configure -scrollregion] 4] 2]
    set xScrollRegionFloat "${xScrollRegion}.0"
    if {$connectionOffRightP} {
      set offSet [expr {$xMax + $xLeft - $xRight + $margin}]
    } else {
      # connectionOffLeftP
      set offSet [expr {$xMin - $margin}]
    }
    append $offSet ".0"
    set offSetFraction [expr { $offSet / $xScrollRegionFloat }]
    # set str "scrollCanvasToExposeConnectionToBeDrawn: offSetFraction"
    # puts stderr "$str $offSetFraction offSet $offSet"
    $canvas xview moveto $offSetFraction 
  } else {
    # no scrolling needed
    return
  }
  # puts stderr "scrollCanvasToExposeConnectionToBeDrawn: after"
  # exposedCanvasExtent $canvas xLeft xRight yTop yBottom
  update
}


## move up schematic hierarchy to show top level 
## 12jun00 wmt
proc putSchematicAtTopLevel { {canvasRootId 0} } {
  global g_NM_acceleratorStem 
  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  # check Back accelerator button, which will be enabled if
  # the scematic is not at the top level
  # set state [lindex [$acceleratorRoot.canvas_back.arrow config -state] 4]
  # set parentList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
  # puts stderr "\nputSchematicAtTopLevel: state $state parentList $parentList"
  while {[lindex [$acceleratorRoot.canvas_back.arrow config -state] 4] == \
             "normal"} {
    canvasUpAccelerator $canvasRootId
    # set parentList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
    # set state [lindex [$acceleratorRoot.canvas_back.arrow config -state] 4] 
    # puts stderr "   state $state parentList $parentList"
  }

}












