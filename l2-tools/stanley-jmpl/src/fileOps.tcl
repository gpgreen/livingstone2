# $Id: fileOps.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# Extract just the "name" of a pirate workspace from a pathname.
## 28jun96 wmt: pirFileInfo(filename): is file name, not path name
proc workname {path} {

    return [file rootname $path]
}


# Put a label on the workspace window.
## 12dec95 wmt: add Stanley identification
## 07jun96 wmt: remove version, add defmodule to title
proc label_workspace { canvasRootId } {
  global g_NM_schematicMode g_NM_vmplTestModeP 

  if {$canvasRootId == 0} {
    set iconName "STANLEY"
    if {[string match $g_NM_schematicMode "layout"] || \
            $g_NM_vmplTestModeP} {
      append iconName " VJMPL"
    } else {
      append iconName " OPS"
    }
    wm iconname .master $iconName
  } else {
    wm iconname .slave_$canvasRootId "STANLEY:s_$canvasRootId"
  }
  displayDotWindowTitle $canvasRootId 
}


# File menu "Quit" option.  Check for unsaved work. Does not destroy window
# return 1 to quit, 0 not to
## 11mar96 wmt: check for nodes & edges
proc fileQuit {} {
  global pirFileInfo pirNodes g_NM_nodeTypeRootWindow 

  set rsvEditsP 1
  if {[outstandingEditDialogsP $rsvEditsP]} {
    return 0
  }
  if {$pirFileInfo(scm_modified) && [llength $pirNodes]} {
    set responseP [save_dialog]
    update
    if {$responseP} {
      return 0
    } else {
      return 1
    }
  }
  return 1
}
    

## check for existence of component/module edit dialogs
## if rsvEditsP is 1, flag structure/symbol/value edits too
## 17dec97 wmt: new
proc outstandingEditDialogsP { { rsvEditsP 0 } } {
  global g_NM_nodeTypeRootWindow 

  set outstandingP 0
  if {[llength [set children [winfo children $g_NM_nodeTypeRootWindow]]] > 0} {
    set titleString ""; set dialogPathList {}
    foreach dialogPath $children {
      if {((! $rsvEditsP) && \
               (! [regexp "abstraction" $dialogPath]) && \
               (! [regexp "relation" $dialogPath]) && \
               (! [regexp "structure" $dialogPath]) && \
               (! [regexp "symbol" $dialogPath]) && \
               (! [regexp "value" $dialogPath])) || \
              $rsvEditsP} {
        set buttonPath ${dialogPath}.buttons
        if {[regexp "editModeTransition" $dialogPath]} {
          append buttonPath ".save"
        } else {
          append buttonPath ".ok"
        }
        if {! [winfo exists $buttonPath]} {
          error "outstandingEditDialogsP: buttonPath $buttonPath does not exist"
        }
        # set str "outstandingEditDialogsP: dialogPath $buttonPath"
        # puts stderr "$str state [lindex [$buttonPath config -state] 4]"
        if {[string match [lindex [$buttonPath config -state] 4] \
                 "normal"]} {
          set outstandingP 1
          append titleString "\n[wm title $dialogPath]"
          lappend dialogPathList $dialogPath 
        }
      }
    }
    if {$outstandingP} {
      # show user the windows
      foreach dialog $dialogPathList {
        raise $dialog
      }
      set str "There are outstanding edit dialogs:$titleString"
      set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
      eval $dialogList 
    }
  }
  return $outstandingP 
}


# Establish a new workspace.
## return 1 is error, return 0 is ok
## 01feb96 wmt: add mark_unmodified in place of "set pirFileInfo(modified) 0"
## 10sep96 wmt: pass reinit = 1 to initialize_graph
## 11aug97 wmt: add arg classDefType 
proc fileNew { classDefType {caller ""} } {
  global pirFileInfo pirNodes g_NM_mkformNodeUpdatedP
  global g_NM_fileOperation g_NM_classDefType g_NM_processingFileOpenP
  global g_NM_livingstoneDefmoduleArgList g_NM_maxDefmoduleArgs
  global g_NM_livingstoneDefcomponentArgList g_NM_maxDefcomponentArgs
  global g_NM_nodeTypeRootWindow g_NM_vmplTestModeP
  global g_NM_showNodeLegendBarP g_NM_livingstoneDefmoduleArgTypeList 
  global g_NM_livingstoneDefcomponentArgTypeList g_NM_schematicMode 
  global g_NM_selectedClassType g_NM_selectedClassName 
  global g_NM_mkformNodeCompleteP g_NM_terminalInstance 
 
  # puts stderr "fileNew: g_NM_vmplTestModeP $g_NM_vmplTestModeP caller $caller"
  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    if {$g_NM_vmplTestModeP && \
            (! [string match $caller "instantiateTestModule"])} {
      # allow user to create/modify schematics after Test->...
      changeVmplTestToEdit
    }

    if {[outstandingEditDialogsP]} {
      return 1
    }
    if {[save_dialog]} {
      return 1
    }
  }
  set reinit 1; set caller fileNew; set canvasRootId 0
  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    set g_NM_fileOperation fileNew
    set g_NM_mkformNodeUpdatedP 0
    set g_NM_classDefType $classDefType

    if {$g_NM_schematicMode != "operational"} {
      enableInstantiateDefsMenu
    }

    initialize_graph $reinit
    
    if {$g_NM_schematicMode != "operational"} {
      buildInstantiateDefinitionTerminalCascade $classDefType
      buildEditDefinitionCascade $classDefType $canvasRootId
      updateInstantiationCascadeMenus $classDefType 
    }
    if {$g_NM_showNodeLegendBarP} {
      resetLayoutLegendColors $canvasRootId
    }
    # turn off node labels -- require user to click on "Show Labels"
    # to see them.  this is because otherwise they "flip-flop"
    # hideIconLabelBalloons "mainWindow"
    # not a problem now -- show them by default
    showIconLabelBalloons "mainWindow"
  }
  set g_NM_processingFileOpenP 0

  switch $classDefType {
    component {
      set g_NM_maxDefcomponentArgs 1
      set g_NM_livingstoneDefcomponentArgList {}
      set g_NM_livingstoneDefcomponentArgTypeList {}

      askDefcomponentInfo $canvasRootId $caller

      label_workspace $canvasRootId 
      # mark unmodified since user cannot see root node
      mark_scm_unmodified
      puts stderr "\nfileNew: component"

      # create the unknownFault mode automatically
      set interactiveP 0
      set g_NM_mkformNodeCompleteP 1
      set g_NM_selectedClassType "mode"
      set g_NM_selectedClassName "faultMode"
      set str "catch-all mode when L2 cannot determine the mode"
      append str "\nthis mode has no constraints"
      set g_NM_terminalInstance [list [getInternalNodeName "unknownFault"] \
                                     {} $str {} "unknownFaultRank"] 
      set x 250; set y 250
      set canvas [getCanvasRootInfo g_NM_currentCanvas]
      canvasB1Click $canvas.c $x $y $interactiveP
    }
    module {
      set g_NM_maxDefmoduleArgs 1
      set g_NM_livingstoneDefmoduleArgList {}
      set g_NM_livingstoneDefmoduleArgTypeList {}

      askDefmoduleInfo $canvasRootId $caller

      label_workspace $canvasRootId 
      # mark unmodified since user cannot see root node
      mark_scm_unmodified
      puts stderr "\nfileNew: module"
    }
    default {
      editStructureSymbolValueForm $classDefType newname[pirGenInt]
    }
  }
  return 0
}


## 0 is ok, 1 is fault
## 17sep96 wmt: new - handle both scm & mpl files
proc save_dialog {} {
  global pirFileInfo 

  set returnValue 0
  if {$pirFileInfo(scm_modified)} {
    set returnValue [save_dialog_doit "Current Class Schematic"]
  }
  return $returnValue
}


# Query the user to save a workspace. 
# Return 0 if OK to continue
# Return 1 if fault
## 01feb96 wmt: add mark_unmodified in place of "set pirFileInfo(modified) 0"
## 17sep96 wmt: renamed from save_dialog 
proc save_dialog_doit { type } {
  global g_NM_schematicMode

  if {[string match $g_NM_schematicMode "operational"]} {
    set response 1
  } else {
    set response [tk_dialog .dio "$type Modified" \
                      "Do you want to save your changes?" \
                      {} 0 \
                      {SAVE} {DISCARD} {CANCEL}]
  }
  if {$response == 2} {
    return 1
  } elseif {$response == 1} {
    mark_scm_unmodified
    return 0
  } elseif {$response == 0} {
    # fileSave returns 0 or 1
    return [fileSave]
  }
}


# Warn overwrite of a file.  0 if continue, 1 if cancel
## 11sep96 wmt: add description arg
## 03may97 wmt: hide pathname - use class name
proc exists_dialog { filenm description } {
  global pirFileInfo

  set response [tk_dialog .dio "$description Exists" \
                    [format " %s already exists. \n Replace it?" \
                         [file root [file tail $filenm]]] \
                    {} -1 \
                    {Replace} {Cancel}]
  return $response
}

# File menu "Open" option. Save any work and query for pathname.
# return 0 is ok
# return 1 is ignore place-holder cvs checked in files whose
#          contents are out of date, and thus removed;
# return 2 is failed schematic creation because a dependent
#          .i-scm file is not found
## 13oct95 wmt: ask user if current .stanley/stanley-prefs should be applied
##              to those set from the .scm file
## 15oct95 wmt: add default filenm argument
## 24jan96 wmt: do not prompt user for ~/.stanley/stanley-prefs
## 01feb96 wmt: add mark_unmodified in place of "set pirFileInfo(modified) 0"
## 17apr96 wmt: added modified1P &modified2P
## 28jun96 wmt: pirFileInfo(filename): save file name, not path name
## 27oct96 wmt: check for existence of livingstone model file
## 14nov96 wmt: replaced query_file by tk4.2 built-in proc tk_getOpenFile
## 02dec96 wmt: added optional arg checkConsistencyP & createTerminalNodesP
## 16apr97 wmt: null g_NM_livingstoneDefmoduleName here, rather than
##              in initialize_graph
## 02jul97 wmt: add recursiveFileOpenP arg
## 11aug97 wmt: add arg classDefType 
proc fileOpen { classDefType {filenm nil} {errorDialogP 1} \
                    {headerUpdateOnlyP 0} } {
  global pirFileInfo g_NM_schematicMode pirDisplay
  global g_NM_mkformNodeUpdatedP pirNode g_NM_classDefType
  global g_NM_livingstoneDefmoduleName g_NM_vmplTestModeP 
  global g_NM_livingstoneDefmoduleFileName pirEdge 
  global g_NM_schematicMode tk_version g_NM_nodeTypeRootWindow 
  global g_NM_fileOperation g_NM_dependentClasses
  global g_NM_processingNodeGroupP g_NM_instanceToNode 
  global g_NM_rootInstanceName g_NM_currentCanvas
  global g_NM_livingstoneDefmoduleArgList g_NM_maxDefmoduleArgs
  global g_NM_livingstoneDefcomponentArgList g_NM_maxDefcomponentArgs
  global g_NM_includedModules g_NM_processingFileOpenP
  global g_NM_opsWarningsP g_NM_edgeConnectionFailedList
  global g_NM_initializationCompleteP g_NM_argsValuesMismatchList
  global g_NM_recursiveInstantiationP g_NM_pendingEdgesOverrideMsgP
  global g_NM_edgeConnectionInvalidList STANLEY_ROOT
  global publicPrivateConvertP g_NM_showNodeLegendBarP g_NM_win32P
  global g_NM_advisoryRootWindow 

  set caller "fileOpen"
  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    if {[outstandingEditDialogsP]} {
      return 1
    }
    # classDefType = structure/symbol/value do not require a saved canvas
    if {(! $headerUpdateOnlyP) && [save_dialog]} {
      return 1
    }
    if {$g_NM_vmplTestModeP} {
      # allow user to create/modify schematics after Test->...
      changeVmplTestToEdit
    }
  }
  set canvasRootId 0
  # use this to prevent <Enter>/<Leave> events from being activated after
  # query_file menu is exited, when it is on top of a schematic
  # add checks to selectNode & deselectNode
  set g_NM_processingNodeGroupP 1

  # File->Open Definition passes $filenm as class name without extension
  set directory [file dirname $filenm]
  if {($directory == "") || ($directory == ".")} {
    # abstraction file names have a period in them
    set filenm "[getSchematicDirectory root $classDefType]/$filenm"
    append filenm $pirFileInfo(suffix)
  }
  # puts stderr "fileOpen: filenm `$filenm'"

  file stat $filenm stat
  if {$stat(size) < 10} {
    if {$errorDialogP} {
      set dialogList [list tk_dialog .d "ERROR" "Invalid $pirFileInfo(suffix) file" \
                          error 0 {DISMISS}]
      eval $dialogList
      standardMouseClickMsg
      .master.canvas config -cursor top_left_arrow
      update
    }
    return 1
  }
  set silentP 1
  set g_NM_fileOperation fileOpen
  set g_NM_processingFileOpenP 1
  set classDefName [file rootname [file tail $filenm]] 
  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    set g_NM_classDefType $classDefType
    set pirFileInfo(filename) $classDefName
    if {$g_NM_win32P} {
      .master.canvas config -cursor watch 
    } else {
      .master.canvas config -cursor { watch red yellow }
    }
    set reinit 1
    initialize_graph $reinit

    # turn off node labels -- require user to click on "Show Labels"
    # to see them.  this is because otherwise they "flip-flop"
    hideIconLabelBalloons "mainWindow"

    buildEditDefinitionCascade $classDefType $canvasRootId 
    if {[string match $g_NM_schematicMode layout]} {
      buildInstantiateDefinitionTerminalCascade $classDefType
      enableInstantiateDefsMenu
      # remove $classDefName from Edit->Instance, if $classDefType == module
      updateInstantiationCascadeMenus $classDefType $classDefName 
      if {$g_NM_showNodeLegendBarP} {
        resetLayoutLegendColors $canvasRootId
      }
    }
    mark_scm_unmodified
    set g_NM_edgeConnectionFailedList {}
    set g_NM_edgeConnectionInvalidList {}
    set g_NM_argsValuesMismatchList {}
  }
  if {([lsearch -exact [list component module] $classDefType] >= 0) || \
          (([lsearch -exact [list component module] $classDefType] == -1) && \
               ([lsearch -exact [getClasses $classDefType] $classDefName] == -1))} {
    # initialize_stanley => fillTerminalTypeList already calls
    # read_workspace for structure & value
    read_workspace $classDefType $classDefName $silentP $headerUpdateOnlyP
  }

  # check for user copied .scm file to another name
  if {[lsearch -exact [getClasses $classDefType] $classDefName] == -1} {
    set err_msg "Schematic file `$classDefName.scm' of type `$classDefType' is corrupt - ignored"
    puts stderr "\n$err_msg\n"
    set dialogList [list tk_dialog ${g_NM_advisoryRootWindow}.dfailed \
                            "ADVISORY" $err_msg warning  0 {DISMISS}]
    eval $dialogList
    return 2
  }
  if {[string match $classDefType component]} {
    set g_NM_includedModules {}; set g_NM_dependentClasses {}
    set g_NM_maxDefcomponentArgs \
        [expr {1 + [llength $g_NM_livingstoneDefcomponentArgList]}]
  }
  if {[string match $classDefType module]} {
    set g_NM_maxDefmoduleArgs \
        [expr {1 + [llength $g_NM_livingstoneDefmoduleArgList]}]
  }
  if {[string match $classDefType component] || \
          [string match $classDefType module]} {
    if {$errorDialogP} {
      set severity 1; set msg2 ""
      pirWarning [format {Please Wait: %s schematic being built --} \
                      `[workname $pirFileInfo(filename)]'] \
          $msg2 $severity
      update
    }
    set g_NM_pendingEdgesOverrideMsgP 0
    set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
    set xView [$canvas xview]
    set yView [$canvas yview]

    puts -nonewline stderr \
        "\nfileOpen $classDefType `$classDefName' => "
    # redrawFailedP = 1 if .i-scm file does not exist for a component or module
    set redrawFailedP [pirRedraw $errorDialogP]

    if {$redrawFailedP} {
      return 2
    }
    # now that all nodes are created, bring up the labels so that are
    # above the node objects
    showIconLabelBalloons "mainWindow"
    label_workspace 0
    set g_NM_processingNodeGroupP 0
    set g_NM_processingFileOpenP 0
    if {[string match $g_NM_schematicMode "operational"]} {
      update
      # connections are not drawn until the canvas it is on, is displayed
      # so expose all canvases with nodes not yet drawn, and
      # return to top level schematic.
      # this is done so that propostion connection highlighting will work
      # for connections which are not all the top level
      createAllEdges $canvasRootId 

      # color all components with "g_NM_defaultDisplayState" 
      resetComponents "init" $canvasRootId

      #         if {$g_NM_opsWarningsP} {
      #           # notify user of components/modules with default display-state 
      #           showNodesWithDefaultDisplayState
      #         }
    }
  } else {
    set g_NM_processingNodeGroupP 0
    set g_NM_processingFileOpenP 0

    editStructureSymbolValueForm $classDefType $classDefName
  }
  if {$errorDialogP} {
    canvasEnter
    .master.canvas config -cursor top_left_arrow
    update
  }
  if {[string match $classDefType component] || \
          [string match $classDefType module]} {
    if {[componentModuleDefReadOnlyP]} {
      disableEditingMenus        
    } else {
      enableEditingMenus
    }
    if {([llength $g_NM_edgeConnectionFailedList] == 0) && \
            ([llength $g_NM_edgeConnectionInvalidList] == 0) && \
            ([llength $g_NM_argsValuesMismatchList] == 0) && \
            (! $g_NM_pendingEdgesOverrideMsgP)} {
      mark_scm_unmodified

      set updateP 1
      displayCanvasLegendText $updateP 
    }
    if {[llength $g_NM_edgeConnectionFailedList] != 0} {
      if {! $g_NM_initializationCompleteP} {
        # fileOpen is called from generateIscmOrMplFiles during initialization
        # and we do not want the advisory dialog coming up
        return 2
      } else {
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
    # 24sep99: the following is only need to catch previously built schematics
    #          this problem will not occur on newly built schematics
    if {[llength $g_NM_edgeConnectionInvalidList] != 0} {
      if {! $g_NM_initializationCompleteP} {
        # fileOpen is called from generateIscmOrMplFiles during initialization
        # and we do not want the advisory dialog coming up
        return 2
      } else {
        set str "These connections are no longer valid due to"
        append str "\none connection restriction for input terminals:"
        foreach connection $g_NM_edgeConnectionInvalidList {
          append str "\n==>> [lindex $connection 0] [lindex $connection 1]"
          append str "\n......... [lindex $connection 2] [lindex $connection 3]"
        }
        set dialogList [list tk_dialogNoGrab ${g_NM_advisoryRootWindow}.dinvalid \
                            "ADVISORY" $str warning 0 {DISMISS}]
        eval $dialogList
      }
    }
    if {$publicPrivateConvertP} {
      # needed for schematics generated prior to 01nov99
      # set default value of interfaceType for all terminals, if not set
      setTerminalDefaultInterfaceType $canvasRootId
    }
    if {[string match $classDefType module] && $publicPrivateConvertP} {
      # needed for schematics generated prior to 01nov99
      # convert terminator nodes into private terminals
      convertTerminatorNodes
    }

    # check that argsValues still match args
    # dependent component or module could have had its number of
    # parameters reduced.  Handling increased number of params is
    # handled in instantiateDefmoduleFromIscm
    set newIncludedModules {}
    for {set i 0} {$i < [llength $g_NM_includedModules]} {incr i 2} {
      set instanceName [lindex $g_NM_includedModules $i]
      set includedForm [lindex $g_NM_includedModules [expr {$i + 1}]]
      set nodeClassType [assoc nodeClassType includedForm]
      set nodeClassName [assoc nodeClassName includedForm]
      set classVars [getClassValue $nodeClassType $nodeClassName class_variables]
      set args [getClassVarDefaultValue args classVars]
      set numArgs [llength $args]
      set pirNodeIndex [assoc pirNodeIndex includedForm]
      set argsValues [assoc argsValues pirNode($pirNodeIndex)]
      # puts stderr "numArgs $numArgs args $args len [llength $argsValues] argsValues $argsValues newArgsValues $newArgsValues"
      if {$numArgs != [llength $argsValues]} {
        set str11 "   args:    $args"
        set str12 "   values: $argsValues"
        puts stderr "\nFileOpen: $str11 $str12"
        set str2 "MISMATCH args/values: className $nodeClassName \n"
        set str2 "$str2   instanceName: [getExternalNodeName $instanceName]"
        puts stderr "   $str2"
        set str3 "Discarding the excess value(s)."
        puts stderr "   $str3"
        set dialogList [list tk_dialog ${g_NM_advisoryRootWindow}.d "ADVISORY" \
                            "$str2\n$str11\n$str12\n$str3" \
                            warning 0  {DISMISS}]
        eval $dialogList
        set argsValues [string range $argsValues 0 [expr {$numArgs - 1}]]
        arepl argsValues $argsValues includedForm
        arepl argsValues $argsValues pirNode($pirNodeIndex)
        mark_scm_modified
      }
      lappend newIncludedModules $instanceName $includedForm
    }
    set g_NM_includedModules $newIncludedModules 

    # ensure that canvas is scrolled to 0,0 after possible scrolling by
    # scrollCanvasToExposeConnectionToBeDrawn which makes sure that
    # connections that are not initially exposed, are drawn properly
    set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
    # prevent jerking by using initial values prior to pirRedraw
    $canvas xview moveto [lindex $xView 0]
    $canvas yview moveto [lindex $yView 0] 
  }
  raiseStanleyWindows
  update
  return 0
}

# File "Save" option. If unknown path, detour to "SaveAs"
## 01feb96 wmt: add mark_scm_unmodified in place of "set pirFileInfo(modified) 0"
## 09feb96 wmt: if path not $STANLEY_USER_DIR/[preferred schematic_directory]/
##              $STANLEY_MISSION, go to Save-as
## 22feb96 wmt: add validSchematicP
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 28jun96 wmt: pirFileInfo(filename): is file name, not path name; no need to
##              check directory
## 19sep96 wmt: ensure that we are in schematic directory
## 03may97 wmt: check for existence of file being saved, if
##              g_NM_fileOperation == fileNew 
## 21jul97 wmt: updated to handle schematic, rather than .cfg, components, as well
proc fileSave { {classDefType ""} {classDefName ""} {headerUpdateOnlyP 0} \
                    {parentClassDefName ""} } {
  global pirFileInfo g_NM_fileOperation
  global g_NM_livingstoneDefmoduleFileName g_NM_rootInstanceName
  global g_NM_livingstoneDefmoduleName g_NM_classDefType
  global g_NM_currentCanvas g_NM_nodeTypeRootWindow
  global g_NM_livingstoneDefcomponentFileName pirNode
  global g_NM_livingstoneDefcomponentName pirClass pirClasses
  global g_NM_displayStateType g_NM_mkformNodeCompleteP
  global g_NM_terminalInstance g_NM_defaultDisplayState
  global g_NM_componentToNode g_NM_moduleToNode
  global g_NM_canvasList g_NM_instanceToNode jMplConvertP 
  global g_NM_l2ToolsP g_NM_selectedTestScope g_NM_menuStem 

  if {[string match $classDefType ""]} {
    set classDefType $g_NM_classDefType
  }
  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    if {[outstandingEditDialogsP]} {
      return 1
    }
    if {(! $headerUpdateOnlyP) && (! [validSchematicP])} {
      return 1
    }
  }
  set capClassType [capitalizeWord $classDefType]
  set errorP 0
  switch $classDefType {
    component {
      set classDefName $g_NM_livingstoneDefcomponentName
      set rootInstancePirNodeIndex [assoc-array $g_NM_rootInstanceName \
                                       g_NM_componentToNode]
      if {[string match $g_NM_livingstoneDefcomponentFileName ""]} {
        set errorP 1 
      }
    }
    module {
      set classDefName $g_NM_livingstoneDefmoduleName
      set rootInstancePirNodeIndex [assoc-array $g_NM_rootInstanceName \
                                       g_NM_moduleToNode] 
      if {[string match $g_NM_livingstoneDefmoduleFileName ""]} {
        set errorP 1 
      }
    }
  }
  if {$errorP} {
    set str "$capClassType class name has not been specified."
    set str "$str \nUse `Edit -> Header -> Name, Variables, & Documentation'"
    set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
    eval $dialogList 
    return 1
  }

  if {! $headerUpdateOnlyP} {
    if {[string match $classDefType module] || \
            [string match $classDefType component]} {
      if {[getDisplayStatePirNodeIndex $g_NM_rootInstanceName] == 0} {
        set str "Display Attribute not defined."
        set dialogList [list tk_dialog .d "WARNING" $str warning -1 \
                            {USE DEFAULT} {DEFINE}]
        set response [eval $dialogList]
        # force schematic to top level
        set canvasRootId 0
        set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup \
                                  $canvasRootId]
        while {! [string match $currentNodeGroup $g_NM_rootInstanceName]} {
          set pirNodeIndex [getNodeGroupParentLink $currentNodeGroup]
          set window [convertCanvasPath [assoc window pirNode($pirNodeIndex)] \
                          $canvasRootId]
          # set str "fileSave: nodeInstanceName"
          # puts stderr "$str [assoc nodeInstanceName pirNode($pirNodeIndex)]"
          openNodeGroup [assoc nodeInstanceName pirNode($pirNodeIndex)] module \
              $window
          set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup \
                                    $canvasRootId]
        }
        if {$response == 0} {
          createDefaultDisplayStateAttribute $g_NM_rootInstanceName 
        } else {
          set interactiveP 1
          # puts stderr "fileSave: displayState"
          instantiateDefinitionUpdate attribute displayState $interactiveP
          if {! $g_NM_mkformNodeCompleteP} {
            # return since user can CANCEL out of dialog
            return 1
          }
        }
      }
      set displayStateAttrIndex [getDisplayStatePirNodeIndex $g_NM_rootInstanceName]
      set displayStateAttrName [assoc nodeInstanceName pirNode($displayStateAttrIndex)]
      set reportNotFoundP 0; set oldvalMustExistP 0
      # set str "displayStateAttrIndex $displayStateAttrIndex"
      # puts stderr "$str displayStateAttrName $displayStateAttrName"
      arepl displayStatePropName $displayStateAttrName \
          pirNode($rootInstancePirNodeIndex) $reportNotFoundP $oldvalMustExistP 
    }
  }
  # newLivingstoneDefmoduleParamsUpdate checks this
  # set pathName [getSchematicDirectory root]
  # append pathName $pirFileInfo(filename)$pirFileInfo(suffix)
  # if {[string match $g_NM_fileOperation "fileNew"]} {
  #   if [file exists $pathName] {
  #     if [exists_dialog $pathName "Class Definition"] {
  #       return 1
  #     }
  #   }
  # }
  # move class information from class type variables to generic variables
  set pirClasses [getClasses $classDefType]
  catch { unset pirClass }
  array set pirClass [getClassArrayContents $classDefType]

  if {[string match $classDefType module] || \
          [string match $classDefType component]} {
    # inherit current level terminals and the terminals of included modules/components
    # which have interfaceType = public in their terminalForms
    set inherit_input_terminal_defs {}; set inherit_output_terminal_defs {}
    inheritTerminalsIntoModule inherit_input_terminal_defs \
        inherit_output_terminal_defs  
    # puts stderr "fileSave: inherit_input_terminal_defs $inherit_input_terminal_defs"
    # puts stderr "fileSave: inherit_output_terminal_defs $inherit_output_terminal_defs"
 
    # set pirClassIndex $g_NM_livingstoneDefmoduleName
    set pirClassIndex $g_NM_livingstoneDefcomponentName
    # puts stderr "fileSave BB: pirClass($pirClassIndex) $pirClass($pirClassIndex)"
    # update input_terminals & output_terminals for pirClass
    set inputsMplForm ""; set outputsMplForm ""; set portsMplForm ""
    set inputDecsMplForm ""; set outputDecsMplForm ""; set portDecsMplForm ""
    set attributesMplForm ""; set atttributeFactsMplForm ""

    # errorP is set to 1 if initialMode in class def does not exist
    # and user does not want to proceed
    # also set for components if no fault mode exists with an empty model,
    # i.e. an unknown mode, which is required by L2
    set errorP \
        [createDefmoduleInputsOutputs inputsMplForm outputsMplForm \
             portsMplForm inputDecsMplForm outputDecsMplForm \
             portDecsMplForm attributesMplForm atttributeFactsMplForm \
             inherit_input_terminal_defs inherit_output_terminal_defs \
             inputsMplList outputsMplList]
    if {$errorP} {
      return 1
    }
    # puts stderr "fileSave AA: pirClass($pirClassIndex) $pirClass($pirClassIndex)"

    updateIncludedModuleLocations

  }

  if {$jMplConvertP} {
    # convert pirNodes pirEdges pirClasses g_NM_includedModules
    # to jMpl syntax
    convertToJMplSyntax $classDefType 

    # move class information from class type variables to generic variables
    set pirClasses [getClasses $classDefType]
    catch { unset pirClass }
    array set pirClass [getClassArrayContents $classDefType]
  }

  set errorP \
      [write_workspace $classDefType $classDefName $headerUpdateOnlyP \
           $parentClassDefName]
  if {$errorP} {
    return 1
  }

  # this file is not considered new anymore
  # newLivingstoneDefmoduleParamsUpdate will now not warn user of file's 
  # existence if defmodule params are changed
  set g_NM_fileOperation "fileOpen"
  if {(! $headerUpdateOnlyP) && \
          ([lsearch -exact [list component module] $classDefType] >= 0)} {
    mark_scm_unmodified
    # update canvas legend: read-only & modified
    set updateP 1
    displayCanvasLegendText $updateP
  }
  if {$g_NM_l2ToolsP && ($g_NM_selectedTestScope != "<unspecified>")} {
    # enable Test->Compile
    set menuRoot .master.$g_NM_menuStem
    $menuRoot.test.m entryconfigure "Compile" -state normal
    $menuRoot.test.m entryconfigure "Load & Go" -state disabled
  }
  update
  return 0
}


# Write a list of global variable contents to the current filename.
# Format the file as "set" commands so a "source" of the file will
# reset all the variables.
## 16oct95 wmt: make .scm portable by replacing absolute pathnames
##              with symbolic pathnames
## 20dec95 wmt: add g_NM_classToInstances to globals saved
## 01jan96 wmt: pathname => $STANLEY_USER_DIR 
## 10jan96 wmt: use whole pathname
## 13mar96 wmt: add g_NM_instanceToNode 
## 04apr96 wmt: add g_NM_mirExecTranslationsTimestamp
## 04jun96 wmt: add g_NM_nodeGroupToInstances to globals saved
## 28jun96 wmt: pirFileInfo(filename): save file name, not path name
## 29jun96 wmt: implement multiple canvases
## 23sep96 wmt: remove g_NM_mirExecTranslationsTimestamp
## 18oct96 wmt: add g_NM_rootInstanceName
## 20nov96 wmt: added g_NM_generateMPLCodeP check
## 09dec96 wmt: add g_NM_componentToNode g_NM_moduleToNode
## 06may97 wmt: use g_NM_saveWorkspaceCompactP to compact .scm files
##              remove save_globals arg -- no used
## 21jul97 wmt: updated to handle schematic, rather than .cfg, components, as well
## 22jun97 wmt: old .scm file contained  pirGenInt_global which resets it.
##              we want it to continually count: do not save it anymore
proc write_workspace { classDefType classDefName headerUpdateOnlyP \
                         parentClassDefName } {
  global pirFileInfo STANLEY_ROOT 
  global pirNode pirNodes g_NM_instantiatableSchematicExtension
  global g_NM_livingstoneDefmoduleNameVar g_NM_dependentClasses
  global g_NM_livingstoneDefmoduleName g_NM_saveWorkspaceCompactP
  global g_NM_dependentFilesExtension pirFileInfo 
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global g_NM_terminalTypeList jMplConvertP 

  set save_globals {}; set returnValue 0
  switch $classDefType {
    component {
      lappend save_globals \
          pirNodes pirNode pirEdges pirEdge pirClasses pirClass \
          g_NM_livingstoneDefcomponentFileName g_NM_livingstoneDefcomponentName \
          g_NM_livingstoneDefcomponentNameVar g_NM_livingstoneDefcomponentArgList \
          g_NM_livingstoneDefcomponentArgTypeList
      # g_NM_canvasList
      # g_NM_canvasList not saved anymore - canvases are created on demand
      # in mkNodeIcon
    }
    module {
      if {$g_NM_saveWorkspaceCompactP} {
        lappend save_globals \
            pirNodes pirNode pirEdges pirEdge pirClasses pirClass \
            g_NM_livingstoneDefmoduleFileName g_NM_livingstoneDefmoduleName \
            g_NM_livingstoneDefmoduleNameVar g_NM_livingstoneDefmoduleArgList \
            g_NM_livingstoneDefmoduleArgTypeList g_NM_includedModules
        # g_NM_canvasList 
      } else {
        set save_globals [info globals pir*]
        lappend save_globals g_NM_classToInstances \
            g_NM_instanceToNode g_NM_componentToNode g_NM_moduleToNode \
            g_NM_nodeGroupToInstances \
            g_NM_livingstoneDefmoduleFileName g_NM_includedModules \
            g_NM_livingstoneDefmoduleName g_NM_livingstoneDefmoduleNameVar \
            g_NM_livingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgTypeList
        # g_NM_canvasList 
      }
    }
    default {
      lappend save_globals pirClasses pirClass 
    }
  }
  # set fid [open $pirFileInfo(filename) w]
  # puts [format "writing workspace %s" [workname $pirFileInfo(filename)]]
  # set symbolicPathname $pirFileInfo(filename)
  # set absolutePathname  [eval format {%s} $symbolicPathname]
  set absolutePathname "[getSchematicDirectory root $classDefType]/"
  if {$jMplConvertP} {
    set classDefName [fixIdentifierSyntax $classDefName]
  }
  append absolutePathname ${classDefName}$pirFileInfo(suffix)
  if {(! [file exists $absolutePathname]) || \
          ([file exists $absolutePathname] && \
               [file writable $absolutePathname])} {
    if {$headerUpdateOnlyP} {
      append absolutePathname "-tmp"
    }
    if {$jMplConvertP} {
      append absolutePathname "-jmpl"
    }
    set fid [open $absolutePathname w]

    if {! $headerUpdateOnlyP} {
      puts [format "\nWriting STANLEY schematic: %s" $absolutePathname]
    }

    write_workspace_doit $classDefType $classDefName $fid $save_globals

    close $fid
  } else {
    set str "File: $absolutePathname \nis not writable -- change permissions"
    set dialogList [list tk_dialog .d "User Error" $str error 0 \
                          {DISMISS}]
    eval $dialogList
    error "Click OK"
  }

  if {$headerUpdateOnlyP} {
    return $returnValue
  }

  if {[string match $classDefType module] || \
          [string match $classDefType component]} {
    set schematicFilename [file rootname [file tail $absolutePathname]]
    append schematicFilename $g_NM_instantiatableSchematicExtension
  
    if {[string match $classDefType component]} {
      ## write instantiatable schematic for defcomponent
      createComponentI-SCMfile $schematicFilename

      set depPathname "[getSchematicDirectory root component]/"
    } elseif {[string match $classDefType module]} {
      ## write instaniatable schematic for defmodules 
      createModuleI-SCMfile $schematicFilename

      set depPathname "[getSchematicDirectory root module]/"
    }

    createTERMSfile $classDefType $schematicFilename 

    # delete DEP file, to make sure that writeDefmoduleSchematicMplForm
    # gets the latest version - it uses waitForFileToBeWritten
    append depPathname [file rootname $schematicFilename]
    append depPathname $g_NM_dependentFilesExtension
    file delete $depPathname 
    createDEPfile $classDefType $depPathname

    # create test enable file for "Test->Select Scope"
    createComponentModuleTestFile $classDefType $schematicFilename 
  }

  # update  palette list
  fillPaletteLists $classDefType
  if  {[lsearch -exact [list component module] $classDefType] == -1} {
    # remove old loaded definitions - fillTerminalTypeList will re-load them
    unsetClass $classDefType $classDefName
    lremoveClasses $classDefType $classDefName
  }
  fillTerminalTypeList
  # update menu lists 
  updateMenuLists $classDefType 

  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    # update "Edit->Instantiate" cascade menu
    updateInstantiationCascadeMenus $classDefType 
  }
  updateFileOpenDeleteCascadeMenus

  if {$pirFileInfo(jmpl_modified)} {
    # writeSchematicMplForm for abstraction/structure & relation/value
    # requires that palette lists be updated
    #   puts stderr "write_workspace: No MPL files are written"
    set returnValue [writeSchematicMplForm $classDefType]
  }
  return $returnValue 
}


## write a list of global varibles to file id
## 23sep96 wmt: extracted from write_workspace
## 07may97 wmt: filter out and restore some pirNode attributes
##              to reduce size of .scm files
##              to save only top level objects (others will be pointed to
##              by g_NM_includedModules; prefix allows writing of
##              XpirNodes, etc by createI-SCMfile
proc write_workspace_doit { classDefType classDefName fid save_globals \
                                { prefix "" } } {
  global g_NM_filterPirNodeAttList ${prefix}pirNode ${prefix}pirEdge
  global ${prefix}pirNodes ${prefix}pirEdges pirClasses
  global g_NM_filterRestorePirNodeAttList 
  global g_NM_filterPirClassAttList g_NM_class_variablesAttributeList
  global g_NM_class_variablesModuleAttList jMplConvertP 

  set reportNotFoundP 0; set returnOldvalP 1
  set moduleAttList $g_NM_class_variablesAttributeList
  set moduleAttList [concat $moduleAttList $g_NM_class_variablesModuleAttList]
  switch $classDefType {
    component {
      set pirNodeFilteredElems [subst $${prefix}pirNodes]
      set pirEdgeFilteredElems [subst $${prefix}pirEdges]
      set pirClassFilteredElems $pirClasses 
    }
    module {
      # only save those pirNodes & pirEdges which is visible at top level
      # pirNodes => components, terminals, parent-roots, but not modules
      set pirNodeFilteredElems {}; set pirEdgeFilteredElems {}
      set pirClassFilteredElems {}

      getTopLevelElements pirNodeFilteredElems pirEdgeFilteredElems \
          pirClassFilteredElems $prefix
    }
    default {
      # no pirNodes or pirEdges are created for defrelations, defsymbol-expands,
      # and defvalues -- only have the class defintion
      # and defrelation abstractions
      set pirClassFilteredElems $classDefName
    }
  }

  foreach glo $save_globals {
    global $glo
    upvar #0 $glo bal
    puts $fid "global $glo"
    # puts stderr "write_workspace_doit: glo $glo"
    if [catch {array names bal} elems] {
      set elems {}
    }
    if {$elems == {}} {
      if {[string match $glo ${prefix}pirNodes]} {
        puts $fid [format "set %s \{%s\}" $glo $pirNodeFilteredElems]
      } elseif {[string match $glo ${prefix}pirEdges]} {
        puts $fid [format "set %s \{%s\}" $glo $pirEdgeFilteredElems]
      } elseif {[string match $glo ${prefix}pirClasses]} {
        puts $fid [format "set %s \{%s\}" $glo $pirClassFilteredElems]
      } elseif {([string match $glo g_NM_canvasList]) && $jMplConvertP} {
        puts $fid [format "set %s \{%s\}" $glo [convertCanavsListToJmpl $bal]]
      } else {
        puts $fid [format "set %s \{%s\}" $glo $bal]
      }
    } else {
      if {[string match $glo ${prefix}pirNode]} {
        set elems $pirNodeFilteredElems
      } elseif {[string match $glo ${prefix}pirEdge]} {
        set elems $pirEdgeFilteredElems 
      } elseif {[string match $glo ${prefix}pirClass]} {
        set elems $pirClassFilteredElems
      }
      foreach elem $elems {
        if {[string match $glo ${prefix}pirClass]} {
          if {[string match [assoc nodeClassType bal($elem)] "module"]} {
            set attList $moduleAttList
          } else {
            set attList $g_NM_class_variablesAttributeList
          }
          set class_variables [assoc class_variables bal($elem)]
          foreach classVar $attList {
            set classVarForm [assoc $classVar class_variables $reportNotFoundP]
            foreach attribute $g_NM_filterPirClassAttList {
              adel $attribute classVarForm $reportNotFoundP
            }
            arepl $classVar $classVarForm class_variables $reportNotFoundP
          }
          arepl class_variables $class_variables bal($elem)
          puts $fid [format "set %s(%s) \{%s\}\n" $glo $elem $bal($elem)]

        } elseif {[string match $glo ${prefix}pirNode]} {
          # delete terminal_values from old .scms - no longer used
          set inputs [assoc inputs bal($elem)]
          # puts stderr "inputs $inputs"
          set newInputs {}
          for {set i 0} {$i < [llength $inputs]} { incr i 2} {
            set termList [lindex $inputs [expr {1 + $i}]]
            adel terminal_values termList $reportNotFoundP 
            lappend newInputs [lindex $inputs $i] $termList
          }
          # puts stderr "newInputs $newInputs"
          arepl inputs $newInputs bal($elem)
          # outputs
          set outputs [assoc outputs bal($elem)]
          # puts stderr "outputs $outputs"
          set newOutputs {}
          for {set i 0} {$i < [llength $outputs]} { incr i 2} {
            set termList [lindex $outputs [expr {1 + $i}]]
            adel terminal_values termList $reportNotFoundP 
            lappend newOutputs [lindex $outputs $i] $termList
          }
          # puts stderr "newOutputs $newOutputs"
          arepl outputs $newOutputs bal($elem)

          foreach attribute $g_NM_filterPirNodeAttList {
            adel $attribute bal($elem) $reportNotFoundP 
          }
          set valueList {}; set index 0
          foreach attribute $g_NM_filterRestorePirNodeAttList {
            set oldVal [adel $attribute bal($elem) $reportNotFoundP \
                                   $returnOldvalP]
            lispify_tcl_list oldVal 
            set valueList [concat $valueList $oldVal]
          }
          puts $fid [format "set %s(%s) \{%s\}\n" $glo $elem $bal($elem)]
          if {[llength $valueList] > 0} {
            foreach attribute $g_NM_filterRestorePirNodeAttList {
              acons $attribute [lindex $valueList $index] bal($elem)
              incr index
            }
          }

        } elseif {[string match $glo ${prefix}pirEdge]} {
          # delete terminal_values from old .scms - no longer used
          set terminalFromList [assoc terminalFrom bal($elem)]
          # puts stderr "terminalFromList $terminalFromList"
          set newTerminalFromList {}
          foreach terminalFrom $terminalFromList {
            adel terminal_values terminalFrom $reportNotFoundP 
            lappend newTerminalFromList $terminalFrom
          }
          # puts stderr "newTerminalFromList $newTerminalFromList"
          arepl terminalFrom $newTerminalFromList bal($elem)

          set terminalToList [assoc terminalTo bal($elem)]
          set newTerminalToList {}
          foreach terminalTo $terminalToList {
            adel terminal_values terminalTo $reportNotFoundP 
            lappend newTerminalToList $terminalTo
          }
          arepl terminalTo $newTerminalToList bal($elem)
          puts $fid [format "set %s(%s) \{%s\}\n" $glo $elem $bal($elem)]

        } else {
          puts $fid [format "set %s(%s) \{%s\}" $glo $elem $bal($elem)]
        }
      }
    }
  }
}


# Read a workspace from the current filename. 
# A "source" will set the global variables.
## 02jan96 wmt: add suffix
## 10jan96 wmt: use whole pathname
## 04apr96 wmt: check that g_NM_mirExecTranslationsTimestamp
##              is valid
## 11may96 wmt: strip off /tmp_mnt prefix if it is present in .scm
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 28jun96 wmt: pirFileInfo(filename): save file name, not path name
##              strip_prefixes not needed anymore
## 11jul96 wmt: revise handling of mirExecTranslations files
## 30jul96 wmt: source updated translations file
## 26aug96 wmt: output informative message in ops mode, if translations file
##              has changed; dialog to user in operational mode
## 23sep96 wmt: remove reading execToMir translations for each schematic
##              based on a time stamp -- do it whenever Stanley begins
## 22jun97 wmt: old .scm file contained  pirGenInt_global which resets it.
##              we want it to continually count
## 20oct97 wmt: do not let sourcing of structure/symbol/value .scm
##              files discard existing classes in pirClasses
## 31jan98 wmt: all class type schematics contain pirClass/pirClasses
##              put them in class type specific classes
proc read_workspace { classDefType classDefName { silentP 0 } \
                          { headerUpdateOnlyP 0 } } {
  global pirFileInfo pirGenInt_global
  global g_NM_classDefType pirClasses pirClass g_NM_livingstoneDefmoduleName

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "read_workspace: `$backtrace'"
  # puts stderr "read_workspace: classDefType $classDefType classDefName $classDefName"
  set schematicPathname "[getSchematicDirectory root $classDefType]/"
  append schematicPathname ${classDefName}$pirFileInfo(suffix)
  if {$headerUpdateOnlyP} {
    append schematicPathname "-tmp"
  }
  if {! $silentP} {
    puts [format "\nReading STANLEY schematic: %s" $schematicPathname]
  }
  set currentVal $pirGenInt_global 

  source $schematicPathname
  sourcePostProcess $schematicPathname 

  set pirGenInt_global $currentVal
  foreach className $pirClasses {
    set pirClassDef $pirClass($className)
    setClass $classDefType $className pirClassDef
  }
  concatClasses $classDefType $pirClasses 
}


## mark the current canvas modified, and activate the appropriate menu commands
## 16oct95 wmt: check for schematicMode 
proc mark_scm_modified { {jmplModifiedP 1} } {
  global pirFileInfo tk_version g_NM_schematicMode
  global g_NM_menuStem 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "mark_scm_modified: `$backtrace'"

  set pirFileInfo(scm_modified) 1; set updateP 1
  if {$jmplModifiedP} {
    # set flag so that write_workspace calls writeSchematicMplForm
    set pirFileInfo(jmpl_modified) 1
  }
  if {[string match $g_NM_schematicMode "layout"]} {
    # if {! [string match $pirFileInfo(filename) ""]} 
    .master.$g_NM_menuStem.file.m entryconfigure \
        "Save Definition" -state normal

    displayCanvasLegendText $updateP 
  }
}


## mark the current canvas unmodified, and deactivate the appropriate menu commands
## 01feb96 wmt: derived from mark_scm_modified 
proc mark_scm_unmodified {} {
  global pirFileInfo tk_version g_NM_schematicMode
  global g_NM_menuStem 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "mark_scm_unmodified: `$backtrace'"

  set pirFileInfo(scm_modified) 0; set updateP 1
  set pirFileInfo(jmpl_modified) 0
  if {[string match $g_NM_schematicMode "layout"]} {
    .master.$g_NM_menuStem.file.m entryconfigure "Save Definition" \
        -state disabled

    displayCanvasLegendText $updateP 
  }
}


## check to see if valid schematic exists
## 22feb96 wmt: new
proc validSchematicP { } {
  global pirNodes g_NM_classDefType pirNode
  global g_NM_includedModules g_NM_schematicMode 

  set validP 1
  set componentToNodeList [array names g_NM_componentToNode] 
  set moduleToNodeList [array names g_NM_moduleToNode] 
  if {[string match $g_NM_classDefType module]} {
    if {($g_NM_schematicMode == "layout") && \
            ([llength $g_NM_includedModules] == 0)} {
      # there must be at least 1 component or 1 module
      set validP 0
      set message "At least one component or one module must exist"
    }
  } elseif {[string match $g_NM_classDefType component]} {
    set aModeExists 0
    foreach pirNodeIndex $pirNodes {
      if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
               "mode"] && \
              [string match [assoc nodeClassName pirNode($pirNodeIndex)] \
                   "okMode"]} {
        set aModeExists 1
        break
      }
    }
    if {$aModeExists == 0} {
      set validP 0
      set message "At least one okMode must exist"
    }
  } else {
    set validP 0
    set message "No component or module is has been opened"
  }
  if {! $validP} {
    set dialogList [list tk_dialog .d "ERROR" $message \
        error 0 {DISMISS}]
    eval $dialogList
#     set backtrace ""; getBackTrace backtrace
#     puts stderr "validSchematicP: `$backtrace'"
#     error "validSchematicP"
  }
  return $validP 
}


## return list of pirNode, pirEdge, & pirClass elements at "top"
## visible level => parentNodeList (?name root)
## 08aug97 wmt: do not include components, since they are now
##              in their own .scm files
proc getTopLevelElements { pirNodeFilteredElemsRef pirEdgeFilteredElemsRef \
                               pirClassFilteredElemsRef { prefix "" } } {
  upvar $pirNodeFilteredElemsRef pirNodeFilteredElems
  upvar $pirEdgeFilteredElemsRef pirEdgeFilteredElems
  upvar $pirClassFilteredElemsRef pirClassFilteredElems
  global ${prefix}pirNode ${prefix}pirEdge ${prefix}pirEdges 
  global g_NM_rootInstanceName g_NM_nodeGroupToInstances
  global g_NM_groupLevelSave jMplConvertP pirClasses 

  set reportNotFoundP 0; set returnOldvalP 1; set pirNodeList {}
  set nodeGroupList [list root $g_NM_rootInstanceName]
  if {$jMplConvertP} {
    set nodeGroupList $nodeGroupList
  }
  # only save those pirNodes & pirEdges which is visible at top level
  foreach nodeGroup $nodeGroupList {
    set pairList [assoc-array $nodeGroup g_NM_nodeGroupToInstances]
    for {set i 1} {$i < [llength $pairList]} {incr i 2} {
      set pirNodeList [concat $pirNodeList [lindex $pairList $i]]
    }
  }
  # puts stderr "getTopLevelElements: pirNodeList $pirNodeList"
  # pirNodeFilteredElems => attributes, terminals, parent-roots,
  # but not modules and components
  foreach elem $pirNodeList {
    set nodeClassName [assoc nodeClassName ${prefix}pirNode($elem)]
    set nodeClassType [assoc nodeClassType ${prefix}pirNode($elem)]
    set parentNodeGroupLen [expr {[llength [assoc parentNodeGroupList \
                                                ${prefix}pirNode($elem)]] -1}]
    set nodeState [assoc nodeState ${prefix}pirNode($elem)]
    # the check on pirClasses is for the case of renaming a module and an
    # old parent-root with the old class name is still around
    if {($parentNodeGroupLen < $g_NM_groupLevelSave) || \
            (($parentNodeGroupLen == $g_NM_groupLevelSave) && \
                 (! [string match $nodeState "NIL"]) && \
                 (! [string match $nodeClassType component]) && \
                 ([lsearch -exact $pirClasses $nodeClassName] >= 0))} {
      set pirNodeFilteredElems [concat $pirNodeFilteredElems $elem]
      if {[lsearch -exact $pirClassFilteredElems $nodeClassName] == -1} {
        set pirClassFilteredElems [concat $pirClassFilteredElems $nodeClassName]
      }
    }
  }
  # puts stderr "getTopLevelElements: pirNodeFilteredElems $pirNodeFilteredElems"

  # pirNodeEdgeElems => only components and modules -- for edge checking
  set pirNodeEdgeElems {}
  foreach elem $pirNodeList {
    set nodeClassName [assoc nodeClassName ${prefix}pirNode($elem)]
    set parentNodeGroupLen [expr {[llength [assoc parentNodeGroupList \
                                                ${prefix}pirNode($elem)]] -1}]
    set nodeState [assoc nodeState ${prefix}pirNode($elem)]
    if {($parentNodeGroupLen == $g_NM_groupLevelSave) &&
             (! [string match $nodeState "parent-link"])} {
      set pirNodeEdgeElems [concat $pirNodeEdgeElems $elem]
    }
  }
  # puts stderr "getTopLevelElements: pirNodeEdgeElems $pirNodeEdgeElems"
  foreach elem [subst $${prefix}pirEdges] {
    set nodeFrom [assoc nodeFrom ${prefix}pirEdge($elem)]
    set nodeTo [assoc nodeTo ${prefix}pirEdge($elem)]
    # puts stderr "getTopLevelElements: edgeElem $elem nodeFrom $nodeFrom nodeTo $nodeTo"
    if {([lsearch -exact $pirNodeEdgeElems $nodeFrom] >= 0) || \
            ([lsearch -exact $pirNodeEdgeElems $nodeTo] >= 0)} {
      set pirEdgeFilteredElems [concat $pirEdgeFilteredElems $elem]
    }
  }
}


## generate .i-scm, .terms, .dep, and .jmpl files from .scm files, 
## if they do not exist
## Mpl files cannot be checked for being out of date since
## schematic can be written for node/link placement changes, 
## which do not trigger Mpl changes => thus the Mpl file
## may be legitimately out-of-date.
## thus check for existence only
## 12aug97 wmt: new
## 19sep97 wmt: add .dep files
## 30jan02 wmt: add component-test and module-test directories
## 26feb02 wmt: add g_NM_regenP processing -- regenerate all derived files
## (.i-scm, .terms, .dep, .jmpl), and rewrite the .scm file
## allow .scm file structure changes to be applied (e.g. sourcePostProcessing)
## % ./RUN-STANLEY-VMPL.csh -regen
proc generateIscmOrMplFiles { reorderedClassTypes } {
  global g_NM_classTypes pirFileInfo g_NM_classDefType 
  global g_NM_instantiatableSchematicExtension
  global pirFileInfo g_NM_livingstoneDefmoduleNameVar
  global g_NM_dependentFilesExtension g_NM_regenP 
  global pirNode pirNodes pirDisplay pirClass pirClasses
  global g_NM_terminalsFilesExtension g_NM_generatedMPLExtension 

#   set backtrace ""; getBackTrace backtrace
#   puts stderr "generateIscmOrMplFiles: `$backtrace'"
  set reinit 1; set redrawFailedList {}
  foreach nodeType $reorderedClassTypes {
    if {[string match $nodeType module] || 
        [string match $nodeType component]} {
      set componentModuleP 1 } else { set componentModuleP 0}
    set schematicsDir [getSchematicDirectory nodeType $nodeType]
    pushd $schematicsDir
    set printStr "generating [string toupper $nodeType] "
    append printStr "`$g_NM_instantiatableSchematicExtension'"
    set scmFiles [glob -nocomplain *$pirFileInfo(suffix)]
    set i_scmFiles [glob -nocomplain *$g_NM_instantiatableSchematicExtension]
    set termsFiles [glob -nocomplain *$g_NM_terminalsFilesExtension]
    set depFiles [glob -nocomplain *$g_NM_dependentFilesExtension]
    append printStr ", `$g_NM_terminalsFilesExtension'"
    append printStr ", & `$g_NM_dependentFilesExtension'"
    append printStr " Stanley schematic files, and "
    append printStr " `$g_NM_generatedMPLExtension' Livingstone model files"
    set generateP 0; set errorDialogP 0; set askUserP 0; set silentP 1
    if {$componentModuleP} {
      # check for schematics/component-test & module-test
      set dir [lindex [preferred STANLEY_USER_DIR] 0]/[preferred schematic_directory]
      if {$nodeType == "component"} {
        set compTestDir $dir/[preferred component-test_directory]
        if {! [file exists $compTestDir]} {
          file mkdir $compTestDir
          update
        }
        set compTestFiles [glob -nocomplain $compTestDir/*$pirFileInfo(suffix)]
      } else {
        set modTestDir $dir/[preferred module-test_directory]
        if {! [file exists $modTestDir]} {
          file mkdir $modTestDir
          update
        }
        set modTestFiles [glob -nocomplain $modTestDir/*$pirFileInfo(suffix)]
      }
    }
    if {[llength $scmFiles] > 0} {
      foreach file $scmFiles {
        set noIscmFileP 0; set noModelFileP 0; set errorDialogP 0
        set noDepFileP 0; set noTermsFileP 0; set noComponentModuleTestFileP 0
        if {$componentModuleP} {
          set iscmTestFile [file rootname $file]$g_NM_instantiatableSchematicExtension
          if {$g_NM_regenP} {
            file delete $iscmTestFile
          }
          # puts stderr "\ngenerateIscmOrMplFiles: iscmTestFile $iscmTestFile file $file"
          # puts stderr "member [lsearch -exact $i_scmFiles $iscmTestFile]"
          # puts stderr " scm  [file mtime $schematicsDir/$file]"
          # puts stderr "i-scm [file mtime $schematicsDir/$iscmTestFile]"
          if {([lsearch -exact $i_scmFiles $iscmTestFile] == -1) || \
                  (! [file exists $iscmTestFile]) || \
                  [expr {[file mtime $schematicsDir/$file] > \
                             [file mtime $schematicsDir/$iscmTestFile]}]} {
            set noIscmFileP 1
          }
          set termsTestFile [file rootname $file]$g_NM_terminalsFilesExtension
          if {$g_NM_regenP} {
            file delete $termsTestFile
          }
          if {([lsearch -exact $termsFiles $termsTestFile] == -1) || \
                  (! [file exists $termsTestFile]) || \
                  [expr {[file mtime $schematicsDir/$file] > \
                             [file mtime $schematicsDir/$termsTestFile]}]} {
            set noTermsFileP 1
          }
          set depTestFile [file rootname $file]$g_NM_dependentFilesExtension 
          if {$g_NM_regenP} {
            file delete $depTestFile
          }
            # puts stderr "generateIscmOrMplFiles: depTestFile $depTestFile file $file"
          if {([lsearch -exact $depFiles $depTestFile] == -1) || \
                  (! [file exists $depTestFile]) || \
                  [expr {[file mtime $schematicsDir/$file] > \
                             [file mtime $schematicsDir/$depTestFile]}]} {
            set noDepFileP 1
          }
          # need to do this since generateIscmOrMplFiles is called recursively
          if {$nodeType == "component"} {
            set compTestFile $compTestDir/[file rootname $file]$pirFileInfo(suffix)
            if {$g_NM_regenP} {
              file delete $compTestFile
            }
            # puts stderr "generateIscmOrMplFiles: compTestFile $compTestFile file $file"
            if {([lsearch -exact $compTestFiles $compTestFile] == -1) || \
                    (! [file exists $compTestFile]) || \
                    [expr {[file mtime $schematicsDir/$file] > \
                               [file mtime $compTestFile]}]} {
              set noComponentModuleTestFileP 1
            }
          } else {
            set modTestFile $modTestDir/[file rootname $file]$pirFileInfo(suffix)
            if {$g_NM_regenP} {
              file delete $modTestFile
            }
            # puts stderr "generateIscmOrMplFiles: modTestFile $modTestFile file $file"
            if {([lsearch -exact $modTestFiles $modTestFile] == -1) || \
                    (! [file exists $modTestFile]) || \
                    [expr {[file mtime $schematicsDir/$file] > \
                               [file mtime $modTestFile]}]} {
              set noComponentModuleTestFileP 1
            }
          }
        }
        if {($nodeType !="abstraction") && ($nodeType !="relation")} {
            #  Livingstone model .jmpl file
            # abstractions are folded into structures
            # so there is no separate processing for them
            # same for relations - folded into values
          set modelFilePathName [getModelFilePathName $schematicsDir/$file \
                                     $nodeType]
          if {$g_NM_regenP} {
            file delete $modelFilePathName
          }
          if {(! [file exists $modelFilePathName]) || \
                  ([expr {[file mtime $schematicsDir/$file] > \
                              [file mtime $modelFilePathName]}])} {
            set noModelFileP 1
            puts stderr "generateIscmOrMplFiles: file $schematicsDir/$file"
            puts stderr "    model $modelFilePathName"
            puts stderr "    exists [file exists $modelFilePathName]"
            set fileMtime [file mtime $schematicsDir/$file] 
            set formattedFileMtime [clock format $fileMtime -format "%Y-%m-%dT%H:%M:%S"]
            puts stderr "    timestamp file  $formattedFileMtime"
            if {[file exists $modelFilePathName]} {
              set modelMtime [file mtime $modelFilePathName]
              set formatedModelMtime [clock format $modelMtime -format "%Y-%m-%dT%H:%M:%S"] 
              puts stderr "    timestamp model $formatedModelMtime"
            }
          }
        }
        # puts stderr "generateIscmOrMplFiles: noIscmFileP $noIscmFileP noDepFileP $noDepFileP"
        # puts stderr "   noTermsFileP $noTermsFileP noModelFileP $noModelFileP "
        # puts stderr "   noComponentModuleTestFileP $noComponentModuleTestFileP "
        if {($noIscmFileP || $noTermsFileP || $noDepFileP || $noModelFileP || \
                 $noComponentModuleTestFileP) && \
                ($componentModuleP || \
                     [string match $nodeType structure] || \
                     [string match $nodeType symbol] || \
                     [string match $nodeType value])} {
          # Livingstone model .jmpl file
          # abstractions are folded into structures
          # so there is no separate processing for them
          # same for relations - folded into values
          if {$componentModuleP} {
            set returnFlag [fileOpen $nodeType ${schematicsDir}/$file \
                                $errorDialogP]
            if {$returnFlag > 0} {
              if {$returnFlag == 2} {
                puts stderr "generateIscmOrMplFiles: .i-scm failed for $file"

                lappend redrawFailedList $file 
                # since fileOpen had an error return, the update state was
                # left as modified -- set it to unmodified so next fileOpen
                # will not ask user about saving the partial schematic
                mark_scm_unmodified
              }
              # 0 is ok
              # 1 is ignore place-holder cvs checked in files whose
              #   contents are out of date, and thus removed;
              # 2 is failed schematic creation because a dependent
              # .i-scm file is not found or .scm file is corrupt
              continue
            } else {
              puts stderr "generateIscmOrMplFiles: .i-scm succeeded for $file"

              if {$g_NM_regenP} {
                fileSave
                set noIscmFileP 0; set noDepFileP 0; set noTermsFileP 0
                set noComponentModuleTestFileP 0
                # writeSchematicMplForm must be called here, since
                # $pirFileInfo(jmpl_modified) will not be = 1 in fileSave 
              }
            }
          }
          update
          if {(! $generateP) && $componentModuleP} {
            puts stderr "\nBEGIN $printStr \n"
            set generateP 1
          }
          if {$noIscmFileP} {
            # move class information from class type variables to generic variables
            set pirClasses [getClasses $nodeType]
            catch { unset pirClass }
            array set pirClass [getClassArrayContents $nodeType]
            if {[string match $nodeType module]} {
              ## write instaniatable schematic for defmodules
              createModuleI-SCMfile $iscmTestFile
            }
            if {[string match $nodeType component]} {
              ## write instaniatable schematic for defcomponents
              createComponentI-SCMfile $iscmTestFile 
            }
          }
          if {$noDepFileP} {
            createDEPfile $nodeType "[pwd]/$depTestFile"
          }
          if {$noTermsFileP && $componentModuleP} {
            # create g_NM_inheritedTerminals for use by createTERMSfile
            set inherit_input_terminal_defs {}; set inherit_output_terminal_defs {}
            inheritTerminalsIntoModule inherit_input_terminal_defs \
                inherit_output_terminal_defs  
            ## write terminals pointer file for defcomponents/defcomponents 
            createTERMSfile $nodeType $termsTestFile
          }
          if {$noModelFileP} {
            # write Livingstone model .jmpl file - see check above
            # abstractions are folded into structures
            # so there is no separate processing for them
            # same for relations - folded into values
            writeSchematicMplForm $nodeType $askUserP $silentP
          }
          if {$noComponentModuleTestFileP} {
            createComponentModuleTestFile $nodeType $iscmTestFile 
          }
        }
      }
      if {$generateP && $componentModuleP} {
        puts stderr "\nEND $printStr \n"
      }
    }
  }
  # clear off of canvas all nodes/links from last schematic
  set reportNotFoundP 0; set oldvalMustExistP 0
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
  foreach pirNodeIndex $pirNodes {
    if {([lsearch -exact $pirNodes $pirNodeIndex] >= 0) && \
            (! [string match [assoc nodeState pirNode($pirNodeIndex)] \
                    "parent-link"]) && \
            ([llength [assoc parentNodeGroupList pirNode($pirNodeIndex)]] > 1)} {
      arepl selectedNodes $pirNodeIndex pirDisplay $reportNotFoundP \
          $oldvalMustExistP
      catch { editCut $currentCanvas.c }
    }
  }
  set pirFileInfo(filename)  ""
  mark_scm_unmodified
  update
  popd
  set g_NM_classDefType "<type>"
  displayDotWindowTitle
  return $redrawFailedList
}


## if defmodule, write file.i-scm - an instantiatable
## version of the schematic to instantiate into
## another defmodule .scm file
## 23sep96 wmt: new
## 21jul97 wmt: renamed from createI-SCMfile 
proc createModuleI-SCMfile { schematicFileName } {
  global pirNodes pirEdges pirClass pirNode pirEdge
  global g_NM_canvasList pirFileInfo 
  global XpirNodes XpirEdges XpirClass XpirNode XpirEdge
  # global XclassToInstances XinstanceToNode XnodeGroupToInstances
  # global XcomponentToNode XmoduleToNode 
  # global g_NM_classToInstances g_NM_instanceToNode g_NM_nodeGroupToInstances
  # global g_NM_componentToNode g_NM_moduleToNode 
  global XcanvasList XrootInstanceName g_NM_rootInstanceName
  global XlivingstoneDefmoduleFileName g_NM_livingstoneDefmoduleFileName 
  global XlivingstoneDefmoduleName g_NM_livingstoneDefmoduleName 
  global XlivingstoneDefmoduleNameVar g_NM_livingstoneDefmoduleNameVar 
  global XlivingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgList 
  global XincludedModules g_NM_includedModules g_NM_classDefType
  global pirClass pirClasses jMplConvertP g_NM_livingstoneDefmoduleArgTypeList
  global XlivingstoneDefmoduleArgTypeList 

  initInstantiationVars

  set XpirNodes $pirNodes
  set XpirEdges $pirEdges
  foreach node $pirNodes {
    set XpirNode($node) $pirNode($node)
  }
  foreach edge $pirEdges {
    set XpirEdge($edge) $pirEdge($edge);
  }
  if {[llength [array get pirClass]] <= 2} {
    # called from generateIscmOrMplFiles, rather than write_workspace
    # move class information from class type variables to generic variables
    set pirClasses [getClasses module]
    catch { unset pirClass }
    array set pirClass [getClassArrayContents module]
  }
  array set XpirClass [array get pirClass]

  # set XclassToInstances $g_NM_classToInstances
  # set XinstanceToNode $g_NM_instanceToNode
  # set XcomponentToNode $g_NM_componentToNode
  # set XmoduleToNode $g_NM_moduleToNode
  # set XnodeGroupToInstances $g_NM_nodeGroupToInstances
  if {$jMplConvertP} {
    set XcanvasList [convertCanavsListToJmpl $g_NM_canvasList]
  } else {
    set XcanvasList $g_NM_canvasList
  }
  set XrootInstanceName $g_NM_rootInstanceName
  set XlivingstoneDefmoduleFileName $g_NM_livingstoneDefmoduleFileName 
  set XlivingstoneDefmoduleName $g_NM_livingstoneDefmoduleName 
  set XlivingstoneDefmoduleNameVar $g_NM_livingstoneDefmoduleNameVar 
  set XlivingstoneDefmoduleArgList $g_NM_livingstoneDefmoduleArgList 
  set XlivingstoneDefmoduleArgTypeList $g_NM_livingstoneDefmoduleArgTypeList 
  set XincludedModules $g_NM_includedModules

  set instantiationPathName "[getSchematicDirectory nodeType module]/"
  append instantiationPathName $schematicFileName
  if {$jMplConvertP} {
    append instantiationPathName "-jmpl"
  }
  ## write these globals to file
  set save_globals {}; set prefix "X"
  ## XclassToInstances XinstanceToNode XcomponentToNode XmoduleToNode XnodeGroupToInstances 
  lappend save_globals pirGenInt_global pirGenSym_global \
      XpirNodes XpirNode XpirEdges XpirEdge XpirClasses XpirClass \
      XlivingstoneDefmoduleFileName XlivingstoneDefmoduleName \
      XlivingstoneDefmoduleNameVar XlivingstoneDefmoduleArgList \
      XlivingstoneDefmoduleArgTypeList XrootInstanceName XcanvasList XincludedModules 

  set fid [open $instantiationPathName w]

  puts [format "Writing STANLEY instantiatable module schematic: %s" \
      $instantiationPathName]

  write_workspace_doit $g_NM_classDefType $g_NM_livingstoneDefmoduleName \
      $fid $save_globals $prefix

  close $fid
}


## if defcomponent, write file.i-scm - an instantiatable
## version of the schematic to instantiate into
## a defmodule .scm file
## 21jul97 wmt: derived from createModuleI-SCMfile 
proc createComponentI-SCMfile { schematicFileName } {
  global pirNodes pirEdges pirClass pirNode pirEdge
  global g_NM_canvasList pirFileInfo 
  global XpirNodes XpirClass XpirNode g_NM_classDefType
  # global XclassToInstances XinstanceToNode XnodeGroupToInstances
  # global XcomponentToNode XmoduleToNode 
  # global g_NM_classToInstances g_NM_instanceToNode g_NM_nodeGroupToInstances
  # global g_NM_componentToNode g_NM_moduleToNode 
  global XcanvasList XrootInstanceName g_NM_rootInstanceName
  global XlivingstoneDefcomponentFileName g_NM_livingstoneDefcomponentFileName 
  global XlivingstoneDefcomponentName g_NM_livingstoneDefcomponentName 
  global XlivingstoneDefcomponentNameVar g_NM_livingstoneDefcomponentNameVar 
  global XlivingstoneDefcomponentArgList g_NM_livingstoneDefcomponentArgList 
  global pirClass pirClasses jMplConvertP g_NM_livingstoneDefcomponentArgTypeList
  global XlivingstoneDefcomponentArgTypeList 

  initInstantiationVars

  set XpirNodes $pirNodes
  foreach node $pirNodes {
    set XpirNode($node) $pirNode($node)
  }
  # puts stderr "createComponentI-SCMfile: len [llength [array get pirClass]]"
  if {[llength [array get pirClass]] == 0} {
    # called from generateIscmOrMplFiles, rather than write_workspace
    # move class information from class type variables to generic variables
    set pirClasses [getClasses component]
    catch { unset pirClass }
    array set pirClass [getClassArrayContents component]
    # puts stderr "createComponentI-SCMfile: A len [llength [array get pirClass]]"
  }
  array set XpirClass [array get pirClass]

  # set XclassToInstances $g_NM_classToInstances
  # set XinstanceToNode $g_NM_instanceToNode
  # set XcomponentToNode $g_NM_componentToNode
  # set XmoduleToNode $g_NM_moduleToNode
  # set XnodeGroupToInstances $g_NM_nodeGroupToInstances
  set XcanvasList $g_NM_canvasList
  set XrootInstanceName $g_NM_rootInstanceName
  set XlivingstoneDefcomponentFileName $g_NM_livingstoneDefcomponentFileName 
  set XlivingstoneDefcomponentName $g_NM_livingstoneDefcomponentName 
  set XlivingstoneDefcomponentNameVar $g_NM_livingstoneDefcomponentNameVar 
  set XlivingstoneDefcomponentArgList $g_NM_livingstoneDefcomponentArgList 
  set XlivingstoneDefcomponentArgTypeList $g_NM_livingstoneDefcomponentArgTypeList 

  set instantiationPathName "[getSchematicDirectory nodeType component]/"
  append instantiationPathName $schematicFileName
  if {$jMplConvertP} {
    append instantiationPathName "-jmpl"
  }
  ## write these globals to file
  set save_globals {}; set prefix "X"
  ## XclassToInstances XinstanceToNode XcomponentToNode XmoduleToNode XnodeGroupToInstances 
  lappend save_globals \
      XpirNodes XpirNode XpirClasses XpirClass \
      XlivingstoneDefcomponentFileName XlivingstoneDefcomponentName \
      XlivingstoneDefcomponentNameVar XlivingstoneDefcomponentArgList \
      XlivingstoneDefcomponentArgTypeList XrootInstanceName XcanvasList 

  set fid [open $instantiationPathName w]

  puts [format "Writing STANLEY instantiatable component schematic: %s" \
      $instantiationPathName]

  write_workspace_doit $g_NM_classDefType $g_NM_livingstoneDefcomponentName \
      $fid $save_globals $prefix

  close $fid
}


## clear out instantiation variables
proc initInstantiationVars { } {

  global XpirNodes XpirEdges XpirClass XpirClasses XpirNode XpirEdge
  global XclassToInstances XinstanceToNode XnodeGroupToInstances
  global XcanvasList XcomponentToNode XmoduleToNode XincludedModules

  catch { unset XpirNode XpirEdge XpirClass }
  set XpirNode(0) 1
  set XpirEdge(0) 1
  set XpirClass(0) 1

  catch { unset XpirNodes XpirEdges XpirClasses XclassToInstances \
              XinstanceToNode XcomponentToNode XmoduleToNode \
              XnodeGroupToInstances XcanvasList XincludedModules }
  set XpirNodes {}
  set XpirEdges {}
  set XpirClasses {}
  set XclassToInstances {}
  set XinstanceToNode {}
  set XcomponentToNode {}
  set XmoduleToNode {}
  set XnodeGroupToInstances {}
  set XcanvasList {}
  set XincludedModules {}
}


## write component/module dependent classes file
## included components/modules and abstraction,
## relation, structure,symbol, and value class defs
proc createDEPfile { classDefType incPathname } {
  global g_NM_dependentClasses jMplConvertP 

  if {$jMplConvertP} {
    append incPathname "-jmpl"
  }
  set fid [open $incPathname w]
  puts $fid $g_NM_dependentClasses
  close $fid
  puts [format "Writing STANLEY $classDefType dependency file: %s" $incPathname]
}


## update Instantiate => Terminal, which is different for
## components and modules
proc buildInstantiateDefinitionTerminalCascade { classDefType } {
  global g_NM_paletteTerminalList g_NM_menuStem

  set canvasRoot [getCanvasRoot 0]
  set instanceCascade .master.$g_NM_menuStem.edit.m.instance
  set selectFunction instantiateDefinitionUpdate
  switch $classDefType {
    component {
      set menuList {}
      foreach item $g_NM_paletteTerminalList {
        if {! [regexp -- "Declaration" $item]} {
          lappend menuList $item
        }
      }
    }
    module {
      # set menuList $g_NM_paletteTerminalList
      set menuList {}
      foreach item $g_NM_paletteTerminalList {
        if {! [regexp -- "Declaration" $item]} {
          # terminators are not used anymore 19oct99
          lappend menuList $item
        }
      }
    }
  }
  regsub -all "port" $menuList "bi-directional" menuLabelList 

  generateCascadeMenu $instanceCascade terminal Terminal $menuList \
      $menuLabelList $selectFunction
}


## dynamically build cascade menus for Edit ==> Header
## 07jan98 wmt: new
proc buildEditDefinitionCascade { classDefType canvasRootId {editP 1}} {
  global g_NM_menuStem

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "buildEditDefinitionCascade: `$backtrace'"
  # puts stderr "buildEditDefinitionCascade: classDefType $classDefType"
  set canvasRoot [getCanvasRoot $canvasRootId]
  set rootLabel "Header"
  set rootName editHeader 
  set selectFunction editClassDefParams
  set rootNameState normal 
  set alphabetizeMenuListP 0
  if {$editP} {
    set menuLabelList [list "Name, Variables, & Documentation ..."]
  } else {
    set menuLabelList [list "Name, Values, & Documentation ..."]
  }
  lappend menuLabelList "Display Attribute ..."                
  set menuList [list nameVarDoc displayState]
  switch $classDefType {
    component {
      lappend menuLabelList "Background Model ..." "Initial Conditions ..."
      lappend menuList backModel initCond
    }
    module {
      lappend menuLabelList "Facts ..."
      lappend menuList facts
    }
  }
  generateCascadeMenu $canvasRoot.$g_NM_menuStem.edit.m $rootName $rootLabel \
      $menuList $menuLabelList $selectFunction $rootNameState $alphabetizeMenuListP 
}


## delete schematic file and corresponding Mpl file, if classDefType 
## is component/module. If structure/symbol/value, delete the schematic
## file and rewrite  all members of the type to the common Mpl file.
proc fileDelete { classDefType filenm } {
  global g_NM_nodeTypeRootWindow g_NM_processingNodeGroupP
  global pirFileInfo tk_version g_NM_terminalTypeValuesArray 
  global g_NM_instantiatableSchematicExtension
  global g_NM_dependentFilesExtension g_NM_classDefType
  global g_NM_livingstoneDefcomponentName g_NM_livingstoneDefmoduleName
  global g_NM_terminalsFilesExtension g_NM_generatedMPLExtension 
  global g_NM_paletteAbstractionList g_NM_paletteStructureList
  global g_NM_paletteDefrelationList g_NM_win32P
  global pirClassAbstraction pirClassesAbstraction 
  global pirClassStructure pirClassesStructure
  global pirClassRelation pirClassesRelation 

  if {[lsearch -exact [list component module] $classDefType] >= 0} {
    set rsvEditsP 1
    if {[outstandingEditDialogsP $rsvEditsP]} {
      return 1
    }
    if {[save_dialog]} {
      return 1
    }
  }
  # use this to prevent <Enter>/<Leave> events from being activated after
  # query_file menu is exited, when it is on top of a schematic
  # add checks to selectNode & deselectNode
  set g_NM_processingNodeGroupP 1; set silentP 1
  set caller "fileDelete"

  cd [getSchematicDirectory root $classDefType]
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }
  set returnValue 1 
  # File->Delete Definition passes $filenm as class name without extention
  set directory [file dirname $filenm]
  if {($directory == "") || ($directory == ".")} {
    # abstraction file names have a period in them
    set filenm "[getSchematicDirectory root $classDefType]/$filenm"
    append filenm $pirFileInfo(suffix)
  }
  set fileRootName [file rootname $filenm]
  set defName [file tail $fileRootName] 
  set tmpName $defName
  if {[classDefReadOnlyP $classDefType $defName]} {
    set str "Definition $tmpName is READ-ONLY"
    set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
    eval $dialogList
    return     
  }
  if {[string match $classDefType component] || \
          [string match $classDefType module]} {
    # find dependencies
    set modulesDir [getSchematicDirectory family defmodules]
    pushd $modulesDir
    set depFiles [glob -nocomplain *$g_NM_dependentFilesExtension]
    set dependencyList {}
    foreach fileName $depFiles {
      # puts stderr "fileDelete: fileName $fileName"
      set fid [open $fileName r]
      gets $fid dependentFilesList
      close $fid
      set componentsList [assoc component dependentFilesList]
      set modulesList [assoc module dependentFilesList]
      # puts stderr "fileDelete: componentsList $componentsList modulesList $modulesList"
      if {(($classDefType == "component") && \
               ([lsearch -exact $componentsList $defName] >= 0)) || \
              (($classDefType == "module") && \
                   ([lsearch -exact $modulesList $defName] >= 0))} {
        # puts stderr "fileDelete: found $defName in $fileName"
        lappend dependencyList [file tail [file rootname $fileName]]
      }
    }
    popd
    # puts stderr "fileDelete: $defName => dependencyList $dependencyList"

    # show user dependencies. if none, 
    # delete schematic directory files and Mpl file
    if {[llength $dependencyList] > 0} {
      sortAndFormatList dependencyList dependencyString
      set outputStr "[capitalizeWord $classDefType] definition `$defName' \nhas these MODULE dependencies:" 
      set dialogList [list tk_dialog .d "ERROR - No Deletion" \
                          "$outputStr\n\n$dependencyString" \
                          error 0 {DISMISS}]
      eval $dialogList
      puts stderr "\n$outputStr\n$dependencyString"

    } else {

      # puts stderr "fileDelete: testing -- no deletion done"
      #return 0

      if {(($classDefType == "component") && \
               (! [string match $g_NM_livingstoneDefcomponentName $defName])) || \
              (($classDefType == "module") && \
                   (! [string match $g_NM_livingstoneDefmoduleName $defName]))} {
        # show user the component/module
        set errorDialogP 0
        fileOpen $classDefType $filenm $errorDialogP
      }
      if {[confirm "Delete '$defName'?"]} {
        file delete $filenm
        puts stderr "\nDeleting STANLEY schematic: $filenm"

        file delete "$fileRootName$g_NM_instantiatableSchematicExtension"
        set str "Deleting STANLEY instantiatable schematic:"
        puts stderr "$str $fileRootName$g_NM_instantiatableSchematicExtension"

        file delete "$fileRootName$g_NM_terminalsFilesExtension"
        set str "Deleting STANLEY terminals file:"
        puts stderr "$str $fileRootName$g_NM_terminalsFilesExtension"

        file delete "$fileRootName$g_NM_dependentFilesExtension"
        set str "Deleting STANLEY dependent defmodule file:"
        puts stderr "$str $fileRootName$g_NM_dependentFilesExtension"

        # delete Mpl files
        deleteMplFiles $classDefType $defName 

        # delete test enable files
        set testPathname [lindex [preferred STANLEY_USER_DIR] 0]/
        append testPathname [preferred schematic_directory]/
        if {[string match $classDefType module]} {
          append testPathname [preferred module-test_directory]/
        } elseif {[string match $classDefType component]} {
          append testPathname [preferred component-test_directory]/
        }
        file delete "$testPathname$defName$pirFileInfo(suffix)"
        set str "Deleting STANLEY test enable file:"
        puts stderr "$str $testPathname$defName$pirFileInfo(suffix)"

        # is class defName currently displayed?
        set pirClassIndex $defName 
        if {([string match $classDefType component] && \
                 [string match $g_NM_livingstoneDefcomponentName $pirClassIndex]) || \
                ([string match $classDefType module] && \
                     [string match $g_NM_livingstoneDefmoduleName $pirClassIndex])} {
          set reinit 1
          initialize_graph $reinit
          set g_NM_classDefType "<type>"
          displayDotWindowTitle
        }
        set returnValue 0
      }
    }  


  } elseif {[lsearch -exact [list abstraction relation structure symbol value] \
                 $classDefType] >= 0} {

    set response 0
    set componentDependencyString ""; set moduleDependencyString ""
    set componentDependencyList {}; set moduleDependencyList {}
    # find module dependencies
    findModuleDependencies $defName $classDefType moduleDependencyList \
        moduleDependencyString 

    # find component dependencies
    findComponentDependencies $defName $classDefType componentDependencyList \
        componentDependencyString
    # puts stderr "fileDelete: $defName => moduleDependencyString $moduleDependencyString"
    # puts stderr "fileDelete: $defName => componentDependencyString $componentDependencyString"


    # dependencies between these classes
    set silentP 1
    if {($classDefType == "value") || ($classDefType == "structure")} {
      # check for abstractions whose argTypes are this class
      set abstractionDependencyList {}
      foreach abstractionName $g_NM_paletteAbstractionList {
        set pirClassIndex $abstractionName 
        if {[lsearch -exact $pirClassesAbstraction $pirClassIndex] == -1} {
          read_workspace abstraction $abstractionName $silentP
        }
        set pirClassIndex $abstractionName  
        set classVars [assoc class_variables pirClassAbstraction($pirClassIndex)]
        set argTypesList [getClassVarDefaultValue argTypes classVars]
        if {[lsearch -exact $argTypesList $defName] >= 0} {
          lappend abstractionDependencyList $abstractionName 
        }
      }
      # check for relations whose argTypes are this class
      set relationDependencyList {}
      foreach relationName $g_NM_paletteDefrelationList {
        set pirClassIndex $relationName 
        if {[lsearch -exact $pirClassesRelation $pirClassIndex] == -1} {
          read_workspace relation $relationName $silentP
        }
        set pirClassIndex $relationName  
        set classVars [assoc class_variables pirClassRelation($pirClassIndex)]
        set argTypesList [getClassVarDefaultValue argTypes classVars]
        if  {[lsearch -exact $argTypesList $defName] >= 0} {
          lappend relationDependencyList $relationName 
        }
      }
      # check for other structures whose args are of this class,
      # and if a structure,
      # also check for other structures which extend this class,
      set structureDependencyList {}
      foreach structureName $g_NM_paletteStructureList {
        set pirClassIndex $structureName 
        if {[lsearch -exact $pirClassesStructure $pirClassIndex] == -1} {
          read_workspace structure $structureName $silentP
        }
        set pirClassIndex $structureName
        set classVars [assoc class_variables pirClassStructure($pirClassIndex)]
        set argTypes [getClassVarDefaultValue argTypes classVars]
        if {[lsearch -exact $argTypes $defName] >= 0} {
          lappend structureDependencyList $structureName 
        }
        if {$classDefType == "structure"} {
          set parentType [getClassVarDefaultValue parentType classVars]
          if {[string match $defName $parentType]} {
             lappend structureDependencyList $structureName
          }
        }
      }

      set abstractionDependencyString ""; set relationDependencyString ""
      set structureDependencyString ""
      if {[llength $abstractionDependencyList] > 0} {
        sortAndFormatList abstractionDependencyList abstractionDependencyString
      }
      if {[llength $relationDependencyList] > 0} {
        sortAndFormatList relationDependencyList relationDependencyString
      }
      if {[llength $structureDependencyList] > 0} {
        sortAndFormatList structureDependencyList structureDependencyString
      }
      if {($moduleDependencyString != "") || \
              ($componentDependencyString != "") || \
              ($abstractionDependencyString != "") || \
              ($relationDependencyString != "") || \
              ($structureDependencyString != "")} {
        set outputStr "[capitalizeWord $classDefType] definition `$defName' \nhas these dependencies: \n"
        set outputStrA "ABSTRACTIONS -- \n$abstractionDependencyString\n"
        set outputStrC "COMPONENTS --\n$componentDependencyString\n"
        set outputStrM "MODULES --\n$moduleDependencyString \n"
        set outputStrR "RELATIONS -- \n$relationDependencyString\n"
        set outputStrS "STRUCTURES --\n$structureDependencyString"
        set dialogList [list tk_dialog .d "ERROR - No Deletion" \
                            "$outputStr \n$outputStrA \n$outputStrC \n$outputStrM \n$outputStrR \n$outputStrS" \
                            error 0 {DISMISS}]
        eval $dialogList
        set response 1
        puts stderr "\n$outputStr$outputStrA$outputStrC$outputStrM$outputStrR$outputStrS"
      }
    }

    if {$response == 0} {
      # puts stderr "fileDelete: testing -- no deletion done"
      # return 0

      # show user what may be deleted
      if {[lsearch -exact [getClasses $classDefType] $defName] == -1} {
        read_workspace $classDefType $defName $silentP 
      }
      editStructureSymbolValueForm $classDefType $defName $caller

      if {[confirm "Delete '$defName'?"]} {
        file delete $filenm
        puts stderr "\nDeleting STANLEY schematic: $filenm"

        if {($classDefType == "value") || ($classDefType == "structure")} {
          unset g_NM_terminalTypeValuesArray($defName)
        }
        # remove old loaded definition 
        unsetClass $classDefType $defName 
        lremoveClasses $classDefType $defName 

        set returnValue 0
      }
    }
  } else {
    error "fileDelete: classDefType $classDefType not handled\!"  
  }

  if {$returnValue == 0} {
    # update  palette list
    fillPaletteLists $classDefType
    # writeSchematicMplForm for abstraction/structure & relation/value
    # requires that palette lists be updated first
    if {[lsearch -exact [list abstraction relation structure symbol value] \
             $classDefType] >= 0} {
      writeSchematicMplForm $classDefType
    }

    fillTerminalTypeList

    # update menu lists  
    updateMenuLists $classDefType
    if {($classDefType == "component") || ($classDefType == "module")} {
      # update "Edit->Instantiate" cascade menu
      updateInstantiationCascadeMenus $classDefType 
    }
    updateFileOpenDeleteCascadeMenus
  }
  # reset everything like mouse-left click on canvas
  set g_NM_processingNodeGroupP 1
  canvasB1Release [getCanvasRootInfo g_NM_currentCanvas 0].c 0 0
  set g_NM_processingNodeGrouP 0
  standardMouseClickMsg
  displayDotWindowTitle
  .master.canvas config -cursor top_left_arrow
  # prevent spurios rectangular skeleton from being left on canvas
  enableMouseSelection [getCanvasRootInfo g_NM_currentCanvas]
  update
  return $returnValue
}


## find module dependencies of class types
## abstraction relation structure symbol value
## 08apr02 wmt: split out from fileDelete
proc findModuleDependencies { defName classDefType moduleDependencyListRef \
                                  moduleDependencyStringRef } {
  upvar $moduleDependencyListRef moduleDependencyList
  upvar $moduleDependencyStringRef moduleDependencyString
  global g_NM_dependentFilesExtension

  set modulesDir [getSchematicDirectory family defmodules]
  pushd $modulesDir
  set depPathnames [glob -nocomplain *$g_NM_dependentFilesExtension]
  foreach pathName $depPathnames {
    # puts stderr "fileDelete: pathName $pathName"
    set fid [open $pathName r]
    gets $fid dependentClassesList
    close $fid
    set maybeDependencyList [assoc $classDefType dependentClassesList]
    # puts stderr "fileDelete: maybeDependencyList $maybeDependencyList"
    if {[lsearch -exact $maybeDependencyList $defName] >= 0} {
      # puts stderr "fileDelete: found $defName in $pathName"
      set fileName [file tail [file rootname $pathName]]
      if {[lsearch -exact $moduleDependencyList $fileName] == -1} {
        lappend moduleDependencyList $fileName
      }
    }
  }
  if {[llength $moduleDependencyList] > 0} {
    sortAndFormatList moduleDependencyList moduleDependencyString 
  }
  popd
}


## find component dependencies of class types
## abstraction relation structure symbol value
## 08apr02 wmt: split out from fileDelete
proc findComponentDependencies { defName classDefType componentDependencyListRef \
                                     componentDependencyStringRef } {
  upvar $componentDependencyListRef componentDependencyList
  upvar $componentDependencyStringRef componentDependencyString
  global g_NM_dependentFilesExtension

  set componentsDir [getSchematicDirectory family defcomponents]
  pushd $componentsDir
  set depPathnames [glob -nocomplain *$g_NM_dependentFilesExtension]
  foreach pathName $depPathnames {
    # puts stderr "fileDelete: pathName $pathName"
    set fid [open $pathName r]
    gets $fid dependentClassesList
    close $fid
    set maybeDependencyList [assoc $classDefType dependentClassesList]
    # puts stderr "fileDelete: maybeDependencyList $maybeDependencyList"
    if {[lsearch -exact $maybeDependencyList $defName] >= 0} {
      # puts stderr "fileDelete: found $defName in $pathName"
      set fileName [file tail [file rootname $pathName]]
      if {[lsearch -exact $componentDependencyList $fileName] == -1} {
        lappend componentDependencyList $fileName
      }
    }
  }
  if {[llength $componentDependencyList] > 0} {
    sortAndFormatList componentDependencyList componentDependencyString 
  }
  popd
}


## delete MPL generated files
## 02may00 wmt
proc deleteMplFiles { classDefType defName {type all} } {
  global g_NM_paletteDefrelationList g_NM_jmplInitExtension 
  global g_NM_jmplLintExtenstion g_NM_jmplCompilerExtension 
  global g_NM_scenarioExtension g_NM_cmdMonExtension
  global g_NM_generatedMPLExtension env
  global g_NM_jmplCompilerOptExtension 

  if {[preferred projectId] == "stanley-sample-user-files"} {
    # for stanley-sample-user-files workspace, write .xmpl file
    # into users stanley dir, so that non-group writable umask
    # will not cause a problem for the next user
    # here we delete all previous files
    set mplFileRoot "$env(HOME)/.stanley/$defName"
  } else {
    set mplFileRoot "[preferred LIVINGSTONE_MODELS_DIR]/" 
    if {[string match $classDefType module]} {
      append mplFileRoot "modules/$defName"
    } else {
      append mplFileRoot "components/$defName"
    }
  }
  # generated by Test->Compile
  file delete "$mplFileRoot$g_NM_jmplCompilerExtension"
  file delete "$mplFileRoot${g_NM_jmplCompilerExtension}-err"
  file delete "$mplFileRoot${g_NM_jmplCompilerExtension}-out"

  # generated by Test->Load & Go
  file delete "$mplFileRoot$g_NM_cmdMonExtension"
  file delete "$mplFileRoot$g_NM_jmplInitExtension"
  file delete "$mplFileRoot$g_NM_scenarioExtension"
  file delete "$mplFileRoot$g_NM_jmplCompilerOptExtension"
  if {$type == "all"} {
    # generated by File->Save Definition
    file delete "$mplFileRoot$g_NM_generatedMPLExtension"
    file delete "$mplFileRoot$g_NM_jmplLintExtenstion"
    file delete "$mplFileRoot${g_NM_jmplLintExtenstion}-err"

    set str "Deleting MPL files for [capitalizeWord $classDefType]"
    puts stderr "$str `$defName': ${mplFileRoot}.*"
  } else {
    set str "Deleting MPL files for [capitalizeWord $classDefType]"
    set str "$str `$defName': ${mplFileRoot}.*"
    set str "$str \(except $g_NM_generatedMPLExtension,"
    set str "$str $g_NM_jmplLintExtenstion, and"
    puts stderr "$str ${g_NM_jmplLintExtenstion}-err\)"
  }
}


## create terminals file to follow terminal inheritance
## 07jul98 wmt: new
proc createTERMSfile { classDefType fileName } {
  global g_NM_terminalsFilesExtension pirNode
  global g_NM_rootInstanceName g_NM_moduleToNode 
  global g_NM_componentToNode pirClassModule pirClassComponent
  global g_NM_includedModules g_NM_inheritedTerminals
  global g_NM_instanceToNode jMplConvertP 

  set reportNotFoundP 0 
  set termsPathname "[getSchematicDirectory root $classDefType]/"   
  append termsPathname [file rootname $fileName]$g_NM_terminalsFilesExtension 
  if {$jMplConvertP} {
    append termsPathname "-jmpl"
  }
  set nodeInstanceName $g_NM_rootInstanceName
  if {[string match $classDefType module]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_moduleToNode]
  } elseif {[string match $classDefType component]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_componentToNode]
  } else {
    set str "createTERMSfile: classDefType"
    puts stderr "$str $classDefType not handled"
    return
  }
  set fid [open $termsPathname w]

#   set nameVar [getClassVarDefaultValue name_var classVars] 
#   set args [getClassVarDefaultValue args classVars]
#   set nameVarAndArgs $nameVar
#   puts $fid "global g_NM_nameVarAndArgs"
#   puts -nonewline $fid "set g_NM_nameVarAndArgs "
#   if {[llength $args] > 0} {
#     set nameVarAndArgs [concat $nameVarAndArgs $args]
#   }
#   puts $fid "\{$nameVarAndArgs\}"

  set inheritedClassInstances {}
  for {set i 0} {$i < [llength $g_NM_includedModules]} {incr i 2} {
    set inheritClassInstanceName [lindex $g_NM_includedModules $i] 
    set ptrForm [lindex $g_NM_includedModules [expr {$i + 1}]]
    set className [assoc nodeClassName ptrForm]
    if {$jMplConvertP} {
      # and use fixIdentifierSyntax to convert anything accessed
      set className [string toupper [convertClassNameJavaToLisp $className]]
    }
    set classType [assoc nodeClassType ptrForm]
    if {[string match $classType module]} {
      set classVars [assoc class_variables pirClassModule($className)]
    } elseif {[string match $classType component]} {
      set classVars [assoc class_variables pirClassComponent($className)]
    } else {
      set str "createTERMSfile: classType"
      puts stderr "$str $classType not handled"
      return
    }
    set argsValsList $inheritClassInstanceName 
    set argsValues [assoc argsValues ptrForm] 
    if {! [string match $argsValues ""]} {
      set argsValsList [concat $argsValsList $argsValues]
    }
    set nameVar [getClassVarDefaultValue name_var classVars] 
    if {$jMplConvertP} {
      set nameVar [fixIdentifierSyntax $nameVar]
    }
    set args [getClassVarDefaultValue args classVars]
    if {$args != ""} {
      set newArgs {}
      foreach arg $args {
        if {$jMplConvertP} {
          lappend newArgs [fixIdentifierSyntax $arg]
        } else {
          lappend newArgs $arg
        }
      }
      set args $newArgs
    }
    set nameVarAndArgs $nameVar
    if {[llength $args] > 0} {
      set nameVarAndArgs [concat $nameVarAndArgs $args]
    }
    set inheritClassName [assoc nodeClassName ptrForm]
    set inheritClassType [assoc nodeClassType ptrForm]
    set instanceLabel [assoc instanceLabel ptrForm]
    lappend inheritedClassInstances [list nodeClassName $inheritClassName \
                                         nodeClassType $inheritClassType \
                                         instanceLabel $instanceLabel \
                                         nameArgs $nameVarAndArgs \
                                         nameArgsValues $argsValsList]
  }

  puts $fid "global g_NM_inheritedClassInstances"  
  puts -nonewline $fid "set g_NM_inheritedClassInstances " 
  puts $fid "\{$inheritedClassInstances\}"

  # g_NM_terminalInputDefs/g_NM_terminalOutputDefs are the terminal forms
  # of leaf terminals only -- no inherited terminals
  set inheritInterfaceType public
  if {$jMplConvertP} {
    set inheritInterfaceType public
  }
  puts $fid "global g_NM_terminalInputDefs"
  puts -nonewline $fid "set g_NM_terminalInputDefs "
  set localInputs {}
  set inputs [assoc inputs pirNode($pirNodeIndex)]
  for {set i 1} {$i < [llength $inputs]} {incr i 2} {
    set terminalForm [lindex $inputs $i]
    set terminalName [assoc terminal_name terminalForm]
    set interfaceType [assoc interfaceType terminalForm]
    # only include terminals which are public and
    # are at the top level
    set nodeIndex [assoc-array $terminalName g_NM_instanceToNode $reportNotFoundP]
    if {[string match $interfaceType $inheritInterfaceType] && \
            ($nodeIndex != "") && \
            [string match [assoc nodeGroupName pirNode($nodeIndex)] \
                 $g_NM_rootInstanceName]} {
      lappend localInputs $terminalForm
    }
  }
  puts $fid "\{$localInputs\}"

  puts $fid "global g_NM_terminalOutputDefs"
  puts -nonewline $fid "set g_NM_terminalOutputDefs "  
  set localOutputs {}
  set outputs [assoc outputs pirNode($pirNodeIndex)]
  for {set i 1} {$i < [llength $outputs]} {incr i 2} {
    set terminalForm [lindex $outputs $i]
    # puts stderr "OUT terminalForm $terminalForm"
    set terminalName [assoc terminal_name terminalForm]
    set interfaceType [assoc interfaceType terminalForm]
    # only include terminals which are public and
    # are at the top level
    set nodeIndex [assoc-array $terminalName g_NM_instanceToNode $reportNotFoundP]
    if {[string match $interfaceType $inheritInterfaceType] && \
            ($nodeIndex != "") && \
            [string match [assoc nodeGroupName pirNode($nodeIndex)] \
                 $g_NM_rootInstanceName]} {
      lappend localOutputs $terminalForm
    }
  }
  puts $fid "\{$localOutputs\}"

  # include top-level terminalNames in this structure:
  # {inputs {public {} private {}} outputs {public {} private {}}}
  # which will be used by getInheritedTerminals
  # puts stderr "createTERMSfile: g_NM_inheritedTerminals $g_NM_inheritedTerminals"
  puts $fid "global g_NM_inheritedTerminals"  
  puts -nonewline $fid "set g_NM_inheritedTerminals \{$g_NM_inheritedTerminals\}" 

  close $fid
  puts [format "Writing STANLEY def$classDefType terminals file: %s" \
            $termsPathname]
}


## output the current schematic as an encapsulated postscript file
## which can be viewed and printed using
## > ghostview <file>.ps -bg lightblue3
## [preferred canvasBackgroundColor] =>  lightblue3
## 16feb00 wmt: new
proc printCurrentSchematic { } {
  global g_NM_currentCanvas g_NM_classDefType
  global g_NM_livingstoneDefcomponentName 
  global g_NM_livingstoneDefmoduleName 

  if {! [validSchematicP]} {
    return
  }
  set filePath [lindex [preferred STANLEY_USER_DIR] 0]/[preferred schematic_directory]
  if {[string match $g_NM_classDefType component]} {
    set className [string tolower $g_NM_livingstoneDefcomponentName]
    append filePath "/[preferred defcomponents_directory]/$className.ps"
  } elseif {[string match $g_NM_classDefType module]} {
    set className [string tolower $g_NM_livingstoneDefmoduleName]
    append filePath "/[preferred defmodules_directory]/$className.ps"
  } else {
    error "printCurrentSchematic: classDefType $g_NM_classDefType not handled"
  }

  set canvas $g_NM_currentCanvas.c
  $canvas postscript -file $filePath
  set str "\nWriting postscript of $g_NM_classDefType class definition"
  puts stderr "$str [string toupper $className] to \n    $filePath"
  set str "    View and Print with \n    > ghostview $className.ps"
  puts stderr "$str -magstep 0 -bg [preferred StanleySchematicCanvasBackgroundColor]"
}


## write file to component-test or module-test directory if
## component/module class has no parametere
## used by selectTestScope
## 30jan02 wmt: new
proc createComponentModuleTestFile { classDefType fileName } {
  global pirFileInfo pirClassModule pirClassComponent

  set reportNotFoundP 0
  set className [file rootname $fileName] 
  set testPathname [lindex [preferred STANLEY_USER_DIR] 0]/
  append testPathname [preferred schematic_directory]/
  if {[string match $classDefType module]} {
    append testPathname [preferred module-test_directory]/
    set classVars [assoc class_variables pirClassModule($className)]
  } elseif {[string match $classDefType component]} {
    append testPathname [preferred component-test_directory]/
    set classVars [assoc class_variables pirClassComponent($className)]
  } else {
    set str "createComponentModuleTestFile: classDefType"
    puts stderr "$str $classDefType not handled"
    return
  }
  # check for absence of args
  set args [getClassVarDefaultValue args classVars] 
  append testPathname $className$pirFileInfo(suffix)
  # delete it first, in case zero length file is being rewritten
  # is which case the date is not updated
  file delete $testPathname 
  set fid [open $testPathname w]
  if {$args != ""} {
    puts $fid "$className args: $args"
  }
  close $fid
  puts [format "Writing STANLEY test enable file: %s" $testPathname]
}


## post-processor for source'ing of .scm, .i-scm, & .terms
## files to convert
## outputs {out1 {type {out ?pressureInOutType} ....
## to
## outputs {out1 {type {?pressureInOutType out} ....
## so that trailing space substitution will work for
## terminal types which are parameters
## 22feb02 wmt: new
proc sourcePostProcess { filePathname } {
  global pirFileInfo g_NM_terminalsFilesExtension
  global g_NM_instantiatableSchematicExtension
  global pirNodes pirNode XpirNodes XpirNode
  global g_NM_includedModules XincludedModules
  global g_NM_terminalInputDefs g_NM_terminalOutputDefs
  global pirEdges pirEdge XpirEdges XpirEdge 

  # puts stderr "\nsourcePostProcess: $filePathname \n"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "sourcePostProcess: `$backtrace'"
  set dirPath [file dirname $filePathname]
  set index [string last "/" $dirPath]
  set parentDir [string range $dirPath [expr {$index + 1}] end]
  if {[lsearch -exact [list [preferred defcomponents_directory] \
                           [preferred defmodules_directory]] \
           $parentDir] >= 0} {
    set processNodeClassTypes [list terminal attribute component module]
    set fileExtension [file extension $filePathname]
    set fileModifiedP 0
    if {[string match $fileExtension $pirFileInfo(suffix)] || \
            [string match $fileExtension "$pirFileInfo(suffix)-tmp"]} { 
      # .scm file or .scm-tmp (used when changing component/module parameters
      foreach pirNodeIndex $pirNodes {
        if {$pirNodeIndex == 0} { continue }
        set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
        set nodeState [assoc nodeState pirNode($pirNodeIndex)]
        if {([lsearch -exact $processNodeClassTypes $nodeClassType] >= 0) && \
                ($nodeState != "parent-link")} {
          set pirNodeAList $pirNode($pirNodeIndex)
          # puts stderr "sourcePostProcess: B $pirNodeAList "
          if {[rotateInputOutputTypes pirNodeAList]} {
            set fileModifiedP 1
          }
          set pirNode($pirNodeIndex) $pirNodeAList 
          # puts stderr "sourcePostProcess: A $pirNodeAList "
        }
      }
      if {[string match $parentDir [preferred defmodules_directory]]} {
        set newIncludedModules {}
        for {set i 0} {$i < [llength $g_NM_includedModules]} {incr i 2} {
          set nodeInstanceName [lindex $g_NM_includedModules $i]
          set defmoduleAttList [lindex $g_NM_includedModules [expr {1 + $i}]]
          if {[rotateInputOutputTypes defmoduleAttList]} {
            set fileModifiedP 1
          }
          lappend newIncludedModules $nodeInstanceName $defmoduleAttList
        }
        set g_NM_includedModules $newIncludedModules
      }
      foreach pirEdgeIndex $pirEdges {
        if {$pirEdgeIndex == 0} { continue }
        # puts stderr "sourcePostProcess: B $pirEdge($pirEdgeIndex)"
        set inputs [list in1 [assoc terminalTo pirEdge($pirEdgeIndex)]]
        set outputs [list out1 [assoc terminalFrom pirEdge($pirEdgeIndex)]]
        set terminalForm [list inputs $inputs outputs $outputs]
        if {[rotateInputOutputTypes terminalForm]} {
          set fileModifiedP 1
        }
        set terminalInputs [assoc inputs terminalForm]
        arepl terminalTo [lindex $terminalInputs 1] pirEdge($pirEdgeIndex)
        set terminalOutputs [assoc outputs terminalForm]
        arepl terminalFrom [lindex $terminalOutputs 1] pirEdge($pirEdgeIndex)
        # puts stderr "sourcePostProcess: A $pirEdge($pirEdgeIndex)"
      }

    } elseif {[string match $fileExtension \
                   $g_NM_instantiatableSchematicExtension]} {
      # .i-scm file
      foreach pirNodeIndex $XpirNodes {
        if {$pirNodeIndex == 0} { continue }
        set nodeClassType [assoc nodeClassType XpirNode($pirNodeIndex)]
        set nodeState [assoc nodeState XpirNode($pirNodeIndex)]
        if {([lsearch -exact $processNodeClassTypes $nodeClassType] >= 0) && \
                ($nodeState != "parent-link")} {
          set pirNodeAList $XpirNode($pirNodeIndex)
          # puts stderr "\nsourcePostProcess:BB $pirNodeAList "
          if {[rotateInputOutputTypes pirNodeAList]} {
            set fileModifiedP 1
          }
          set XpirNode($pirNodeIndex) $pirNodeAList 
          # puts stderr "sourcePostProcess: AA $pirNodeAList "
        }
      }
      if {[string match $parentDir [preferred defmodules_directory]]} {
        set newIncludedModules {}
        for {set i 0} {$i < [llength $XincludedModules]} {incr i 2} {
          set nodeInstanceName [lindex $XincludedModules $i]
          set defmoduleAttList [lindex $XincludedModules [expr {1 + $i}]]
          if {[rotateInputOutputTypes defmoduleAttList]} {
            set fileModifiedP 1
          }
          lappend newIncludedModules $nodeInstanceName $defmoduleAttList
        }
        set XincludedModules $newIncludedModules 
      }
      foreach pirEdgeIndex $XpirEdges {
        if {$pirEdgeIndex == 0} { continue }
        # puts stderr "sourcePostProcess: B $XpirEdge($pirEdgeIndex)"
        set inputs [list in1 [assoc terminalTo XpirEdge($pirEdgeIndex)]]
        set outputs [list out1 [assoc terminalFrom XpirEdge($pirEdgeIndex)]]
        set terminalForm [list inputs $inputs outputs $outputs]
        if {[rotateInputOutputTypes terminalForm]} {
          set fileModifiedP 1
        }
        set terminalInputs [assoc inputs terminalForm]
        arepl terminalTo [lindex $terminalInputs 1] XpirEdge($pirEdgeIndex)
        set terminalOutputs [assoc outputs terminalForm]
        arepl terminalFrom [lindex $terminalOutputs 1] XpirEdge($pirEdgeIndex)
        # puts stderr "sourcePostProcess: A $XpirEdge($pirEdgeIndex)"
      }

    } elseif {[string match $fileExtension $g_NM_terminalsFilesExtension]} {
      # .terms file
      # puts stderr "B g_NM_terminalInputDefs $g_NM_terminalInputDefs"
      set inputs {}; set index 1
      foreach def $g_NM_terminalInputDefs {
        lappend inputs "in$index" $def
        incr index
      }
      set terminalForm [list inputs $inputs outputs ""]
      if {[rotateInputOutputTypes terminalForm]} {
        set fileModifiedP 1
      }
      set g_NM_terminalInputDefs {}
      set terminalInputs [assoc inputs terminalForm] 
      for {set i 0} {$i < [llength $inputs]} {incr i 2} {
        lappend g_NM_terminalInputDefs [lindex $terminalInputs [expr {1 + $i}]]
      }
      # puts stderr "A g_NM_terminalInputDefs $g_NM_terminalInputDefs"

      set outputs {}; set index 1
      foreach def $g_NM_terminalOutputDefs {
        lappend outputs "out$index" $def
        incr index
      }
      set terminalForm [list inputs "" outputs $outputs]
      if {[rotateInputOutputTypes terminalForm]} {
        set fileModifiedP 1
      }
      set g_NM_terminalOutputDefs {}
      set terminalOutputs [assoc outputs terminalForm] 
      for {set i 0} {$i < [llength $outputs]} {incr i 2} {
        lappend g_NM_terminalOutputDefs [lindex $terminalOutputs [expr {1 + $i}]]
      }

    } else {
      error "sourcePostProcess: fileExtension $fileExtension not handled"
    }
    if {$fileModifiedP} {
      puts stderr "\nsourcePostProcess: rotated $filePathname"
    }
  }
}


## 21feb02 wmt: new
proc rotateInputOutputTypes { pirNodeAListRef } {
  upvar $pirNodeAListRef pirNodeAList

  set reportNotFoundP 0; set modifiedP 0
  set inputs [assoc inputs pirNodeAList]
  set numInputs [assoc numInputs pirNodeAList $reportNotFoundP]
  if {$numInputs == ""} {
    # g_NM_includedModules does not have numInputs 
    set numInputs [expr {[llength $inputs] / 2}]
  }
  for {set index 1} {$index <= $numInputs} {incr index} {
    set terminalDefList [assoc "in$index" inputs]
    if {[rotateInputOutputTypesDoit terminalDefList]} {
      set modifiedP 1
    }
    arepl "in$index" $terminalDefList inputs
  }
  arepl inputs $inputs pirNodeAList 

  set outputs [assoc outputs pirNodeAList]
  set numOutputs [assoc numOutputs pirNodeAList $reportNotFoundP]
  if {$numOutputs == ""} {
    # g_NM_includedModules does not have numOutputs 
    set numOutputs [expr {[llength $outputs] / 2}]
  }
  for {set index 1} {$index <= $numOutputs} {incr index} {
    set terminalDefList [assoc "out$index" outputs]
    if {[rotateInputOutputTypesDoit terminalDefList]} {
      set modifiedP 1
    }
    arepl "out$index" $terminalDefList outputs
  }
  arepl outputs $outputs pirNodeAList
  return $modifiedP 
}


## 21feb02 wmt: new
proc rotateInputOutputTypesDoit { terminalDefListRef} {
  upvar $terminalDefListRef terminalDefList

  set modifiedP 0
  set directionList [list in out port]
  set type_form [assoc type terminalDefList]
  set type_list [list $type_form]
  set item1 [lindex [lindex $type_list 0] 0]
  set item2 [lindex [lindex $type_list 0] 1] 
  if {[lsearch -exact $directionList $item1] >= 0} {
    arepl type [list $item2 $item1] terminalDefList
    set modifiedP 1
  }
  return $modifiedP 
}



















