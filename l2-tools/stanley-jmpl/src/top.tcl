# $Id: top.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## top.tcl: Create top-level window for Application Builder

# establish preferred window position
proc dpos {w {xoffset 0} {yoffset 0}} {

    set x [preferred StanleyWindowXPosition]
    if {$x == {}} {set x 0}
    set y [preferred StanleyWindowYPosition]
    if {$y == {}} {set y 0}
    incr x $xoffset
    incr y $yoffset
  wm geometry $w +$x+$y
}


# build main window for the application
## 12dec95 wmt: add Stanley identification
## 02feb96 wmt: add iconifyP 
## 04apr96 wmt: allow Help menu in all modes
## 11may96 wmt: translate DS1-R2-S1 => DS1-R2
## 07jun96 wmt: remove version, add defmodule to title
## 29jun96 wmt: implement multiple canvases
## 29apr97 wmt: remove arg iconifyP
## 26aug97 wmt: add canvasRootId arg to provide multiple main windows
proc mainWindow { canvasRootId { xPos 0 } { yPos 0 } } {
  global pirDisplay tk_version g_NM_schematicMode
  global calledByWishP STANLEY_MISSION
  global g_NM_termtypeRootWindow g_NM_statePropsRootWindow
  global g_NM_classDefType STANLEY_ROOT g_NM_advisoryRootWindow
  global g_NM_currentNodeGroup g_NM_permBalloonRootWindow
  global g_NM_classTypes g_NM_jmplCompilerRootWindow 
  global g_NM_nodeTypeRootWindow g_NM_IPCp g_NM_mir_gui_ipcP
  global g_NM_windowWidthBorder g_NM_windowHeightBorder
  global g_NM_paletteTypes 
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global g_NM_paletteStructureList g_NM_paletteTerminalList 
  global g_NM_paletteDefvalueList g_NM_paletteAttributeList
  global g_NM_paletteDefsymbolList g_NM_paletteModeList 
  global g_NM_canvasParentNode g_NM_menuStem g_NM_acceleratorStem
  global g_NM_showNodeLegendBarP g_NM_l2ToolsP
  global g_NM_componentTestList g_NM_moduleTestList 

  set caller "mainWindow"
  set canvasRoot [getCanvasRoot $canvasRootId]
  toplevel $canvasRoot
  wm minsize $canvasRoot [expr {[preferred minCanvasWidth] + $g_NM_windowWidthBorder}] \
      [expr {[preferred minCanvasHeight] + $g_NM_windowHeightBorder}] 
  wm maxsize $canvasRoot [expr {[preferred maxCanvasWidth] + $g_NM_windowWidthBorder}] \
      [expr {[preferred maxCanvasHeight] + $g_NM_windowHeightBorder}]
  wm group $canvasRoot [winfo toplevel [winfo parent $canvasRoot]]

  ## allow tk_focusFollowsMouse to work
  # focus $canvasRoot
  if {($xPos == 0) && ($yPos == 0)} {
    dpos $canvasRoot [expr {$canvasRootId * 50}] 0
  } else {
    dpos $canvasRoot $xPos $yPos
  }
  
  #-------------------------------------------------------
  # The code below create the main window, consisting of a
  # menu bar and the canvas for laying out the application
  #-------------------------------------------------------

  # get our own color map -- add  -colormap ${canvasRoot}.menu to all
  # first generation widgets of .
  # frame ${canvasRoot}.menu -relief raised -borderwidth 3 -colormap new
  # for now use default colormap - xterm logwin will have to be made a Tcl widget
  # if we have a private color map
  frame $canvasRoot.menus_accels -relief raised -borderwidth 3 \
      -bg [preferred StanleyMenuDialogBackgroundColor]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem

  frame $menuRoot -relief groove -borderwidth 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor]
  frame $acceleratorRoot -relief groove -borderwidth 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor] 
  frame $canvasRoot.canvas -bd 2 -bg [preferred StanleySchematicCanvasBackgroundColor]
  frame $canvasRoot.warnings -relief flat -bd 2 -bg black

  set g_NM_showNodeLegendBarP 0
  if {[preferred StanleyShowNodeLegendBarP]} {
    set g_NM_showNodeLegendBarP 1
    frame $canvasRoot.legend -bg black
  }

  #  puts "mainWindow . class [winfo class .]"
  #  puts  "mainWindow $canvasRoot.menu [$canvasRoot.menu configure]"
  #  puts  "mainWindow $canvasRoot.legend [$canvasRoot.legend configure]"
  # option add *Dialog.colormap $canvasRoot.menu


  #----------------------------------------------
  # Workspace path header
  #----------------------------------------------

  frame $canvasRoot.header -bg [preferred StanleyTitleBgColor] 
  label $canvasRoot.header.center -text "" -relief flat \
      -bg [preferred StanleyMenuDialogBackgroundColor] \
      -fg black -anchor c -font [preferred StanleyTerminalTypeFont]
  pack $canvasRoot.header.center -side top -fill x 

  pack $canvasRoot.header -side top -fill both -expand 0

  #-------------------------------------------------------
  # Create menus
  #-------------------------------------------------------

  #  bind $menuRoot <space> unpostMenus
  #  bind $menuRoot <Button-1> unpostMenus

  #============ File ====================== 

  menubutton $menuRoot.file -text File -menu $menuRoot.file.m \
      -underline 0 -relief flat 
    
  menu $menuRoot.file.m -tearoff 0 
  #  bind $menuRoot <f> "postMenu file"
  #  bind $menuRoot <F> "postMenu file"

  if {[string match $g_NM_schematicMode "layout"]} {
    set label "New Definition"
    $menuRoot.file.m add cascade -label $label \
        -menu $menuRoot.file.m.new 
    set newCascade [menu $menuRoot.file.m.new -tearoff 0]
    
    foreach choice $g_NM_classTypes {
      
      set superLabel "$label: [capitalizeWord $choice]"
      set command "layoutFileOperation fileNew \{$superLabel\} $choice"
      set label [capitalizeWord $choice]
      if {[lsearch -exact {component module} $choice] == -1} {
        append label " ..."
      }
      $newCascade add command -label $label -command $command 
    }
    # $menuRoot.file.m.new entryconfigure Defcomponent -state disabled
    $menuRoot.file.m add separator 
  }


  ## if {$canvasRootId == 0} ## do not do it for ops mode yet
  if {[string match $g_NM_schematicMode "layout"] || \
          ([string match $g_NM_schematicMode "operational"] && \
               ($canvasRootId == 0) && $g_NM_mir_gui_ipcP)} {
    set label "Open Definition"
    $menuRoot.file.m add cascade -label $label \
        -menu $menuRoot.file.m.open 
    menu $menuRoot.file.m.open -tearoff 0
  }

  if {[string match $g_NM_schematicMode "layout"]} {

    $menuRoot.file.m add separator 
    $menuRoot.file.m add command -label "Save Definition" -state disabled \
        -command fileSave  

    $menuRoot.file.m add separator 
    set label "Delete Definition"
    $menuRoot.file.m add cascade -label $label \
        -menu $menuRoot.file.m.delete 
    menu $menuRoot.file.m.delete -tearoff 0

    updateFileOpenDeleteCascadeMenus
  }

#   if {[string match $g_NM_schematicMode "operational"] && \
#           ($canvasRootId == 0)} {
#     # $menuRoot.file.m add separator
#     $menuRoot.file.m add command -label "Create Slave Canvas" \
#         -command "createNewRootCanvas" 
#   }

  if {[string match $g_NM_schematicMode "layout"]} {
    $menuRoot.file.m add separator 
    $menuRoot.file.m add command -label "Print Definition" \
        -command "printCurrentSchematic" 
  }

  if {[string match $g_NM_schematicMode "layout"]} {

    $menuRoot.file.m add separator 
    $menuRoot.file.m add separator 
    set startupP 0; set copyBasicClassFilesP 1
    $menuRoot.file.m add command -label "New Workspace ..." \
        -command "askNewWorkspace $copyBasicClassFilesP"

    $menuRoot.file.m add separator
    set copyBasicClassFilesP 0
    $menuRoot.file.m add command -label "New Empty Workspace ..." \
        -command "askNewWorkspace $copyBasicClassFilesP"

    $menuRoot.file.m add separator 
    $menuRoot.file.m add command -label "Import Workspace ..." \
        -command "askImportWorkspace"

    $menuRoot.file.m add separator 
    set workspaceState disabled
    if {[llength [preferred STANLEY_USER_DIR]] > 1} {
      set workspaceState normal
    }
    $menuRoot.file.m add cascade -label "Open Workspace" \
        -menu $menuRoot.file.m.openWorkspace -state $workspaceState
    set menuPath [menu $menuRoot.file.m.openWorkspace -tearoff 0]
    buildWorkspaceCascadeMenu "openWorkspace" $menuPath $startupP 

    $menuRoot.file.m add separator 
    $menuRoot.file.m add cascade -label "Forget Workspace" \
        -menu $menuRoot.file.m.forgetWorkspace -state $workspaceState
    set menuPath [menu $menuRoot.file.m.forgetWorkspace -tearoff 0]
    buildWorkspaceCascadeMenu "forgetWorkspace" $menuPath $startupP 
  }

  if {$canvasRootId == 0} {
    $menuRoot.file.m add separator
    $menuRoot.file.m add command -label "Quit ..." \
        -command "shutdown" 
    #   -activebackground red -accelerator "  C-q"
    # this does not work since we are using focusFollowsMouse
    # and "focus -force $menuRoot" is needed after every <Enter>/<Leave>
    # event (that is not realistic)
    # bind $menuRoot <Control-q> "confirm \"Quit Stanley\"; shutdown"
  }

  if {[string match $g_NM_schematicMode "operational"] && \
          ($canvasRootId != 0)} {
    $menuRoot.file.m add command -label "Close Slave Canvas" \
        -command "destroyRootCanvas $canvasRootId" 
  }

  #============ Edit ======================

  menubutton $menuRoot.edit -text "Edit" \
      -menu $menuRoot.edit.m -relief flat -underline 0 

  menu $menuRoot.edit.m -tearoff 0 

  set rootLabel "Header"
  set rootName editHeader 
  set selectFunction editClassDefParams 
  set menuLabelList [list "Name, Variables, & Documentation ..." \
                         "Display Attribute ..."]
  set menuList [list nameVarDoc displayState]
  if {[string match $g_NM_schematicMode "operational"]} {
    set rootNameState normal
  } else {
    set rootNameState disabled
  }
  generateCascadeMenu $menuRoot.edit.m $rootName $rootLabel \
      $menuList $menuLabelList $selectFunction $rootNameState 

  if {[string match $g_NM_schematicMode "layout"]} {
    $menuRoot.edit.m add separator

    set label "Instantiate"
    $menuRoot.edit.m add cascade -label $label \
        -menu $menuRoot.edit.m.instance -state disabled 

    set instanceCascade [menu $menuRoot.edit.m.instance -tearoff 0]

    $menuRoot.edit.m.instance add command -label "attribute ..." \
        -state disabled -command "instantiateDefinitionUpdate attribute attribute" 

    set selectFunction instantiateDefinitionUpdate
    set paletteTypes $g_NM_paletteTypes
    lremove paletteTypes attribute 
    foreach choice $paletteTypes {
      switch $choice {
        component {
          set menuList $g_NM_paletteDefcomponentList
          set menuLabelList $g_NM_paletteDefcomponentList 
        }
        mode {
          set menuList $g_NM_paletteModeList
          set menuLabelList $g_NM_paletteModeList 
        }
        module {
          set menuList $g_NM_paletteDefmoduleList
          set menuLabelList $g_NM_paletteDefmoduleList 
        }
        terminal {
          set menuList $g_NM_paletteTerminalList
          regsub -all "port" $g_NM_paletteTerminalList "bi-directional" \
              menuLabelList 
        }
      }
      generateCascadeMenu $instanceCascade $choice [capitalizeWord $choice] \
          $menuList $menuLabelList $selectFunction 
    }

    $menuRoot.edit.m add separator 
    $menuRoot.edit.m add command -label "Delete" \
        -state disabled -command "editCut" -activebackground red 

    $menuRoot.edit.m add separator 
    $menuRoot.edit.m add command -label "Location Gridding On" \
        -command toggleSnapToGrid -state disabled 
    $menuRoot.edit.m add command -label "Location Gridding Off"  \
        -command toggleSnapToGrid -state disabled 
  }

  $menuRoot.edit.m add separator

  set label "Preferences"
  $menuRoot.edit.m add cascade -label $label \
      -menu $menuRoot.edit.m.preferences
  set preferencesCascade [menu $menuRoot.edit.m.preferences -tearoff 0]

  set menuList {view user workspace}
  set menuLabelList {"View ..." "Edit User ..." "Edit Workspace ..."}
  set selectFunction "pirEditPreferences"
  set rootNameState normal
  set alphabetizeMenuListP 0
  generateCascadeMenu $preferencesCascade suw "L2Tools/User/Workspace" \
      $menuList $menuLabelList $selectFunction $rootNameState \
      $alphabetizeMenuListP 

  $menuRoot.edit.m.preferences add command -label "Workspace Display State Colors ..." \
      -command "pirEditDisplayStateColorPrefs"



  #============ Test ======================

  if {$g_NM_l2ToolsP} {
    menubutton $menuRoot.test -text "Test" \
        -menu $menuRoot.test.m -relief flat -underline 0  
    menu $menuRoot.test.m -tearoff 0 

    $menuRoot.test.m add cascade -label "Scope" \
        -menu $menuRoot.test.m.scope
    menu $menuRoot.test.m.scope -tearoff 0 

    $menuRoot.test.m.scope add cascade -label "component" \
        -menu $menuRoot.test.m.scope.component
    menu $menuRoot.test.m.scope.component -tearoff 0 
    $menuRoot.test.m.scope add cascade -label "module" \
        -menu $menuRoot.test.m.scope.module
    menu $menuRoot.test.m.scope.module -tearoff 0 

    set selectFunction selectTestScope
    set menuList $g_NM_componentTestList 
    generateCascadeMenu $menuRoot.test.m.scope component "component" $menuList \
        $menuList $selectFunction 
    set menuList $g_NM_moduleTestList 
    generateCascadeMenu $menuRoot.test.m.scope module "module" $menuList \
        $menuList $selectFunction 

    $menuRoot.test.m add separator
    $menuRoot.test.m add command -label "Compile" \
        -command "compileTestScope" -state disabled 

    $menuRoot.test.m add separator
    $menuRoot.test.m add command -label "Load & Go" \
        -command "instantiateTestModule" -state disabled 

    #   $menuRoot.test.m add separator
    #   $menuRoot.test.m add command -label "Truth Table" \
    #       -command "generateTruthTable" -state disabled 

    $menuRoot.test.m add separator 
    $menuRoot.test.m add command -label "Write IDD" \
        -command "writeIDD" -state disabled 

    $menuRoot.test.m add separator
    $menuRoot.test.m add command -label "Clean" \
        -command "cleanTestScope" -state disabled \
        -activebackground red
  }

  
  #============ Tools ======================

  menubutton $menuRoot.tools -text "Tools" -menu $menuRoot.tools.m \
      -underline 0 -relief flat  
  menu $menuRoot.tools.m -tearoff 0 
  # bind $menuRoot <t> "postMenu tool"
  # bind $menuRoot <T> "postMenu tool"

  # $menuRoot.tools.m add command -label "Delete All Node Terminal Type Windows" \
  #     -command "deleteAllPopUpWindows $g_NM_termtypeRootWindow"
  # if {[string match $g_NM_schematicMode "layout"]} {
  #   $menuRoot.tools.m add command -label "Delete Edit/View Windows" \
  #       -command "deleteAllPopUpWindows $g_NM_nodeTypeRootWindow"
  # }
  # $menuRoot.tools.m add separator

  $menuRoot.tools.m add command -label "Raise All Non-Canvas Windows" \
      -command "raiseStanleyWindows" 

  if {$g_NM_l2ToolsP} {
    $menuRoot.tools.m add separator
    $menuRoot.tools.m add command -label "Display Mode State Legend" \
        -command "popupDisplayStateLegend" -state normal
  }
  
  $menuRoot.tools.m add separator
  $menuRoot.tools.m add command -label "Show Test Permanent Balloons" \
      -command "showTestPermanentBalloons" -state disabled

  $menuRoot.tools.m add separator
  $menuRoot.tools.m add command -label "Hide Test Permanent Balloons" \
      -command "hideTestPermanentBalloons" -state disabled

  $menuRoot.tools.m add separator
  set cmd "deleteAllViewDialogs; deleteAllPopUpWindows $g_NM_advisoryRootWindow"
  append cmd " viewDialogs"
  $menuRoot.tools.m add command -label "Delete All View Dialogs" \
      -command $cmd -state disabled 

  $menuRoot.tools.m add separator
  # enabled only for vmpl test mode
  $menuRoot.tools.m add command -label "Display Toplevel State Viewer Windows" \
      -command "displayVmplTestViewers" -state disabled
  
  $menuRoot.tools.m add separator
  # enabled for ops mode and vmpl test mode
  set deleteState disabled 
  if {[string match $g_NM_schematicMode "operational"]} {
    set deleteState normal
  }
  $menuRoot.tools.m add command -label "Delete All State Viewer Windows" \
      -command "deleteAllPopUpWindows $g_NM_statePropsRootWindow" \
      -state $deleteState 

  $menuRoot.tools.m add separator
  $menuRoot.tools.m add command -label "Component Faults" \
      -command "showComponentFaultList $canvasRootId" \
      -state disabled 
  
  if {[string match $g_NM_schematicMode "operational"] && \
          $g_NM_mir_gui_ipcP && ($canvasRootId == 0)} {
    # $menuRoot.tools.m add separator
    # $menuRoot.tools.m add command -label "Power Thermometer"
    #     -command powerThermometer 
    #     -state disabled;          # not used for DS1-R1
    $menuRoot.tools.m add separator
    $menuRoot.tools.m add command -label "Generate MPL Completion Forms" \
        -command generateMPLCompletionForms 
    $menuRoot.tools.m add separator
    $menuRoot.tools.m add command -label "Run Scenario from File ..." \
        -command testScenario  
    $menuRoot.tools.m add separator
    $menuRoot.tools.m add command -label "Definition Instance State Change ..." \
        -command testComponentStateChange 
  }
  if {[string match $g_NM_schematicMode "operational"]} {
    $menuRoot.tools.m add separator
    $menuRoot.tools.m add command -label "Reset All Definition Instances" \
        -command "resetComponents reset $canvasRootId" -activebackground red 
#     $menuRoot.tools.m add separator
#     $menuRoot.tools.m add command -label "Start Off-line RAX Packet Viewer" \
#         -command "startRAXPacketView offline" 
#     $menuRoot.tools.m add separator
#     $menuRoot.tools.m add command -label "Start Real-time RAX Packet Viewer" \
#         -command "startRAXPacketView realtime" 
  }

  #============ Debug ======================
  ## 03nov95 wmt: new

#   if {[string match $g_NM_schematicMode "layout"] && \
#       ($calledByWishP == 0)} {
#     menubutton $menuRoot.debug -text "Debug" -menu $menuRoot.debug.m \
#         -underline 0
#     menu $menuRoot.debug.m

#     $menuRoot.debug.m add command -label "View Selected Instances's Parameters" \
#         -command "viewComponentParams" -state disabled 
#     $menuRoot.debug.m add command -label "Inspect Stanley ..." \
#         -command InspectStanley

#    $menuRoot.debug.m add separator
#    $menuRoot.debug.m add command -label "Component Detail Change Log On" \
#        -command toggleDetailLog
#    $menuRoot.debug.m add command -label "Component Detail Change Log Off" -state disabled \
#        -command toggleDetailLog

#    $menuRoot.debug.m add separator
#    $menuRoot.debug.m add command -label "Dbg_On_Immediate" \
#        -command {AutoSat_Schematic_Object_Cmd Dbg_On_Immediate}
#    $menuRoot.debug.m add command -label "Dbg_On_Next_Cmd" \
#        -command {AutoSat_Schematic_Object_Cmd Dbg_On_Next_Cmd}
#    $menuRoot.debug.m add command -label "Dbg_Off" \
#        -command {AutoSat_Schematic_Object_Cmd Dbg_Off}
#   }

  #============ Resize ======================
  
#   if {[string match $g_NM_schematicMode "operational"]} {
#     menubutton $menuRoot.resize -text "Resize" \
#         -menu $menuRoot.resize.m -relief flat -underline 0  
#     menu $menuRoot.resize.m -tearoff 0 

#     $menuRoot.resize.m add command -label "Enlarge" \
#         -command "resizeCanvas $canvasRootId enlarge" -state normal 
#     $menuRoot.resize.m add command -label "Shrink" \
#         -command "resizeCanvas $canvasRootId shrink" -state normal 
#   }

  #============ Help ======================

  if {$canvasRootId == 0} { 
    menubutton $menuRoot.help -text "HELP" -menu $menuRoot.help.m \
        -underline 0 -relief flat  
    menu $menuRoot.help.m -tearoff 0 

    $menuRoot.help.m add command -label "Help ..." -command pirHelp 
    # set helpButtonColor [lindex [$menuRoot.file config -bg] 4]
    # $menuRoot.help config -bg $helpButtonColor

    $menuRoot.help.m add separator 
    $menuRoot.help.m add command -label "About Stanley" \
        -command "aboutStanley" 
  }

  #========================================

  if {$canvasRootId == 0} { 
    pack $menuRoot.help -side right -ipadx 3
  }

  # $menuRoot.links 
  if {[string match $g_NM_schematicMode "layout"]} {
    if {$g_NM_l2ToolsP} {
      pack $menuRoot.file $menuRoot.edit \
          $menuRoot.test $menuRoot.tools -side left 

      tk_menuBar $menuRoot $menuRoot.file $menuRoot.edit \
          $menuRoot.test $menuRoot.tools $menuRoot.help
    } else {
      pack $menuRoot.file $menuRoot.edit $menuRoot.tools -side left 

      tk_menuBar $menuRoot $menuRoot.file $menuRoot.edit \
          $menuRoot.tools $menuRoot.help
    }
  } elseif {[string match $g_NM_schematicMode "operational"] && \
                ($canvasRootId != 0)} {
    # slave root canvases
    pack $menuRoot.file $menuRoot.tools -side left

#     tk_menuBar $menuRoot $menuRoot.file $menuRoot.tools \
#         $menuRoot.resize
    tk_menuBar $menuRoot $menuRoot.file $menuRoot.tools 
  } else {
#     pack $menuRoot.file $menuRoot.edit $menuRoot.tools \
#         $menuRoot.resize -side left

#     tk_menuBar $menuRoot $menuRoot.file $menuRoot.tools \
#         $menuRoot.resize $menuRoot.help
    pack $menuRoot.file $menuRoot.edit $menuRoot.tools -side left

    tk_menuBar $menuRoot $menuRoot.file $menuRoot.tools $menuRoot.help
  }

  ## bind Menu <Enter> "[bind Menu <Enter>]; focus $menuRoot"
  ## allow tk_focusFollowsMouse to work
  bind Menu <Enter> "[bind Menu <Enter>]"

  pack $menuRoot -side top -fill both


  #========== Accelerators ==================

  frame $acceleratorRoot.canvas_back -bd 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised
  button $acceleratorRoot.canvas_back.arrow -anchor e -bd 0 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief flat -padx 0 -pady 2 \
      -highlightthickness 0 -state disabled \
      -command "canvasUpAccelerator $canvasRootId" \
      -bitmap @$STANLEY_ROOT/src/bitmaps/leftarrow 
  button $acceleratorRoot.canvas_back.label -anchor w -bd 0 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief flat -padx 0 -pady 2 \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "canvasUpAccelerator $canvasRootId" -text "Back" 
  balloonhelp $acceleratorRoot.canvas_back.label -side right ""
  bind $acceleratorRoot.canvas_back <Enter> "canvasBackAccelEnter $canvasRootId"
  bind $acceleratorRoot.canvas_back <Leave> "canvasBackAccelLeave $canvasRootId"

  # show/hide icon labels
  frame $acceleratorRoot.show_labels -bd 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised
  button $acceleratorRoot.show_labels.label -anchor w -bd 0 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief flat -padx 4 -pady 2 \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state normal \
      -command "showIconLabelBalloons $caller $canvasRootId" -text "Show Labels" 
  bind $acceleratorRoot.show_labels <Enter> "showLabelsEnter $canvasRootId"
  bind $acceleratorRoot.show_labels <Leave> "showLabelsLeave $canvasRootId"
  
  frame $acceleratorRoot.hide_labels -bd 2 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief raised
  button $acceleratorRoot.hide_labels.label -anchor w -bd 0 \
      -bg [preferred StanleyMenuDialogBackgroundColor] -relief flat -padx 4 -pady 2 \
      -activebackground [preferred StanleySelectedColor] \
      -highlightthickness 0 -state disabled \
      -command "hideIconLabelBalloons $caller $canvasRootId" -text "Hide Labels" 
  bind $acceleratorRoot.hide_labels <Enter> "hideLabelsEnter $canvasRootId"
  bind $acceleratorRoot.hide_labels <Leave> "hideLabelsLeave $canvasRootId"
  
  pack $acceleratorRoot.canvas_back.arrow \
      $acceleratorRoot.canvas_back.label -side left -padx 2 -pady 2 
  pack $acceleratorRoot.show_labels.label -side left -padx 2 -pady 2
  pack $acceleratorRoot.hide_labels.label -side left -padx 2 -pady 2
  pack $acceleratorRoot.canvas_back $acceleratorRoot.show_labels \
      $acceleratorRoot.hide_labels -side left -padx 4 

  pack $acceleratorRoot -side top -fill both 

  pack $canvasRoot.menus_accels -side top -fill both 

  #----------------------------------------------
  # canvas
  #----------------------------------------------
  
  set overlayP 0
  createCanvas $canvasRoot.canvas.root 0 0 $overlayP 

  #-----------------------------------------------
  # Title, Legend, and Warnings Panels
  #-----------------------------------------------

  frame $canvasRoot.title -bg [preferred StanleyTitleBgColor] 
  label $canvasRoot.title.left -text "" -relief flat -bg [preferred StanleyTitleBgColor] \
      -fg [preferred StanleyTitleFgColor] -anchor w -font [preferred StanleyTerminalTypeFont]
  label $canvasRoot.title.right -text "" -relief flat -bg [preferred StanleyTitleBgColor] \
      -fg [preferred StanleyTitleFgColor] -anchor e -font [preferred StanleyTerminalTypeFont]
  pack $canvasRoot.title.left -side left -fill x 
  pack $canvasRoot.title.right -side right -fill x 

  frame $canvasRoot.warnings.warn1
  label $canvasRoot.warnings.warn1.lab1 -text "Attention:" -relief flat \
      -bg [preferred StanleyLegendBgColor] -anchor center -pady 1 -padx 1 \
      -width 10 -fg [preferred StanleyLegendFgColor] 
  label $canvasRoot.warnings.warn1.lab2 -text "" -relief flat \
      -bg [preferred StanleyAttentionBgColor] -pady 1 -padx 1 \
      -anchor w -fg [preferred StanleyAttentionFgColor] 
  pack $canvasRoot.warnings.warn1.lab1 -side left -fill x -ipadx 2m
  pack $canvasRoot.warnings.warn1.lab2 -side left -fill x -ipadx 2m -expand 1
  # 2nd line of attention
  frame $canvasRoot.warnings.warn2
  label $canvasRoot.warnings.warn2.lab1 -text "Attention:" -relief flat \
      -fg [preferred StanleyLegendBgColor] -bg [preferred StanleyLegendBgColor] \
      -anchor center -pady 1 -padx 1 -width 10
  label $canvasRoot.warnings.warn2.lab2 -text "" -relief flat \
      -bg [preferred StanleyAttentionBgColor] -pady 1 -padx 1 \
      -anchor w -fg [preferred StanleyAttentionFgColor]
  pack $canvasRoot.warnings.warn2.lab1 -side left -fill x -ipadx 2m 
  pack $canvasRoot.warnings.warn2.lab2 -side left -fill x -ipadx 2m -expand 1

  pack $canvasRoot.warnings.warn1 $canvasRoot.warnings.warn2 -fill x -expand 1

  if {[preferred StanleyShowNodeLegendBarP]} {
    if {[string match $g_NM_schematicMode "layout"] && (! $g_NM_IPCp)} {
      label $canvasRoot.legend.lab0 -text "Node:" -relief flat \
          -bg [preferred StanleyLegendBgColor] -anchor center \
          -fg [preferred StanleyLegendFgColor] 
      label $canvasRoot.legend.lab1 -text "Module" -relief flat \
          -bg [preferred StanleyModuleNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab2 -text "Component" -relief flat \
          -bg [preferred StanleyComponentNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab3 -text "OK Mode" -relief flat \
          -bg [preferred StanleyOkModeNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab4 -text "Fault Mode" -relief flat \
          -bg [preferred StanleyFaultModeNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab5 -text "Attribute" -relief flat \
          -bg [preferred StanleyAttributeNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab6 -text "Terminal" -relief flat \
          -bg [preferred StanleyTerminalNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab7 -text "Terminator" -relief flat \
          -bg [preferred NM_terminalTermNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab8 -text "Terminal Dec" -relief flat \
          -bg [preferred NM_terminalDeclNodeBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      pack $canvasRoot.legend.lab0 $canvasRoot.legend.lab1 \
          $canvasRoot.legend.lab2 $canvasRoot.legend.lab3 $canvasRoot.legend.lab4 \
          $canvasRoot.legend.lab5 $canvasRoot.legend.lab6 $canvasRoot.legend.lab7 \
          $canvasRoot.legend.lab8 -side left -fill x -padx 1 -expand 1

    } else {
      label $canvasRoot.legend.lab0 -text "State:" -relief flat \
          -bg [preferred StanleyLegendBgColor] -anchor center
      label $canvasRoot.legend.lab1 -text "Ok-unk" -relief flat \
          -bg [preferred NM_unknownPowerBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab2 -text "Ok-off" -relief flat \
          -bg [preferred NM_inactiveStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab3 -text "Ok-on" -relief flat \
          -bg [preferred NM_activeStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab4 -text "Recoverable" -relief flat \
          -bg [preferred NM_recoverableStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab5 -text "Degraded" -relief flat \
          -bg [preferred NM_degradedStateBgColor1] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab6 -text "  Failed  " -relief flat \
          -bg [preferred NM_failedStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab7 -text " Unknown " -relief flat \
          -bg [preferred StanleyUnknownStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      label $canvasRoot.legend.lab8 -text "No Data" -relief flat \
          -bg [preferred StanleyNodataStateBgColor] \
          -fg [preferred StanleyNodeLabelForegroundColor] -anchor center
      pack $canvasRoot.legend.lab0 $canvasRoot.legend.lab1 $canvasRoot.legend.lab2 \
          $canvasRoot.legend.lab3 $canvasRoot.legend.lab4 \
          $canvasRoot.legend.lab5 $canvasRoot.legend.lab6 \
          $canvasRoot.legend.lab7 $canvasRoot.legend.lab8 \
          -side left -fill x -padx 1 -expand 1
    }

    pack $canvasRoot.legend -side bottom -fill both -expand 0
  }
  pack $canvasRoot.warnings -side bottom -fill both -expand 0
  pack $canvasRoot.title -side bottom -fill both -expand 0

  pack $canvasRoot.canvas -side top -fill both -expand 1

  if {$canvasRootId == 0} { 
    # root windows for pop-up windows
    frame $g_NM_termtypeRootWindow
    pack $g_NM_termtypeRootWindow
    frame $g_NM_statePropsRootWindow
    pack $g_NM_statePropsRootWindow
    frame $g_NM_nodeTypeRootWindow
    pack $g_NM_nodeTypeRootWindow
    frame $g_NM_permBalloonRootWindow
    pack $g_NM_permBalloonRootWindow
    frame $g_NM_advisoryRootWindow
    pack $g_NM_advisoryRootWindow
    frame $g_NM_jmplCompilerRootWindow
    pack $g_NM_jmplCompilerRootWindow
  }
}


## change top-level legend from module to component
## in operational mode
## 21aug97 wmt: new
proc changeLegendToComponent { canvasRootId } {

  set canvasRoot [getCanvasRoot $canvasRootId]
  $canvasRoot.legend.lab0 configure -text "Mode:" \
      -bg [preferred StanleyLegendBgColor]
  $canvasRoot.legend.lab1 configure -text "(non-current)"
  $canvasRoot.legend.lab1 configure -bg [preferred StanleyNonCurrentModeBgColor] \
      -fg [preferred StanleyNodeLabelForegroundColor]
  $canvasRoot.legend.lab2 configure -text "OK(current)"
  $canvasRoot.legend.lab2 configure -bg [preferred StanleyCurrentOkModeBgColor] \
      -fg [preferred StanleyNodeLabelForegroundColor]
  $canvasRoot.legend.lab3 configure -text "FAULT(current)"
  $canvasRoot.legend.lab3 configure -bg [preferred StanleyCurrentFaultModeBgColor] \
      -fg [preferred StanleyNodeLabelForegroundColor]

  $canvasRoot.legend.lab4 configure -text "     "
  $canvasRoot.legend.lab4 configure -bg [preferred StanleyLegendBgColor] 
  $canvasRoot.legend.lab5 configure -text "     "
  $canvasRoot.legend.lab5 configure -bg [preferred StanleyLegendBgColor] 
  $canvasRoot.legend.lab6 configure -text "     "
  $canvasRoot.legend.lab6 configure -bg [preferred StanleyLegendBgColor] 
  $canvasRoot.legend.lab7 configure -text "     "
  $canvasRoot.legend.lab7 configure -bg [preferred StanleyLegendBgColor] 
  $canvasRoot.legend.lab8 configure -text "     "
  $canvasRoot.legend.lab8 configure -bg [preferred StanleyLegendBgColor] 
}


## change top-level legend from component to module
## in operational mode
## 21aug97 wmt: new
proc changeLegendToModule { canvasRootId } {
  global g_NM_displayStateColorMapping 

  set canvasRoot [getCanvasRoot $canvasRootId]
  $canvasRoot.legend.lab0 configure -text "State:" \
      -bg [preferred StanleyLegendBgColor]
  set len [llength $g_NM_displayStateColorMapping]
  set mapIndx 0
  for {set labIndx 1} {$labIndx <= 8} {incr labIndx} {
    set text [lindex $g_NM_displayStateColorMapping $mapIndx]
    set bgColor [lindex $g_NM_displayStateColorMapping [expr {$mapIndx + 1}]]
    if {[string match $bgColor ""]} {
      set bgColor StanleyLegendBgColor
    }
    $canvasRoot.legend.lab$labIndx configure -text [capitalizeWord $text] \
        -bg [preferred $bgColor ] \
        -fg [preferred StanleyNodeLabelForegroundColor]
    incr mapIndx 2
  }
}


## reset layout legend colors after preferences change
## 27feb98 wmt: new
proc resetLayoutLegendColors { canvasRootId } {
  global g_NM_schematicMode g_NM_vmplTestModeP 

  if {[string match $g_NM_schematicMode "layout"] || $g_NM_vmplTestModeP} {
    set canvasRoot [getCanvasRoot $canvasRootId]
    $canvasRoot.legend.lab0 configure -bg [preferred StanleyLegendBgColor] \
        -fg [preferred StanleyLegendFgColor] -text "Node:" 
    $canvasRoot.legend.lab1 configure -bg [preferred StanleyModuleNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Module"
    $canvasRoot.legend.lab2 configure -bg [preferred StanleyComponentNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Component"
    $canvasRoot.legend.lab3 configure -bg [preferred StanleyOkModeNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "OK Mode" 
    $canvasRoot.legend.lab4 configure -bg [preferred StanleyFaultModeNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Fault Mode" 
    $canvasRoot.legend.lab5 configure -bg [preferred StanleyAttributeNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Attribute" 
    $canvasRoot.legend.lab6 configure -bg [preferred StanleyTerminalNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Terminal" 
    $canvasRoot.legend.lab7 configure -bg [preferred NM_terminalTermNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Terminator" 
    $canvasRoot.legend.lab8 configure -bg [preferred NM_terminalDeclNodeBgColor] \
        -fg [preferred StanleyNodeLabelForegroundColor] -text "Terminal Dec" 
  }
}


## 16oct95 wmt: added puts & exit
## 31dec96 wmt: added call to killIpcStanleyProcess
## 26sep97 wmt: killIpcStanleyProcess => killProcess
proc shutdown {} {
  global g_NM_schematicMode g_NM_ipcRecorderFile
  global g_NM_ipcRecorderFileFid STANLEY_ROOT 
  global g_NM_centralPid g_NM_mir_gui_ipcP
  global g_NM_vmplTestModeP g_NM_l2ToolsP g_NM_win32P
  global g_NM_livingstoneEvtListORBObject g_NM_livingstoneCmdLineORBObject
  global g_NM_livingstoneEMORBObject g_NM_groundProcessingUnitP
  
  if {[fileQuit]} {

    if {$g_NM_groundProcessingUnitP || $g_NM_win32P} {
      set dialogList [list tk_dialog .d " " "QUIT" question -1 \
                          {STANLEY} {CANCEL}]
    } else {
      set dialogList [list tk_dialog .d " " "QUIT" question -1 \
                          {L2/L2TOOLS/STANLEY} {STANLEY only} {CANCEL}]
    }
    set retValue [eval $dialogList]

    if {((! $g_NM_win32P) && ($retValue == 2)) || \
        (($g_NM_win32P || $g_NM_groundProcessingUnitP) && \
        ($retValue == 1))} {
      return
    }

    if {$g_NM_l2ToolsP && ($retValue == 0) && (! $g_NM_win32P)} {

      # puts stderr "shutdown: releasing Livingstone objects commented out"
      #       # release Livingstone event listener object
      #       # release Livingstone command line object
      #       $g_NM_livingstoneCmdLineORBObject removeStanleyEventListener \
      #           [$g_NM_livingstoneEvtListORBObject _this]
      #       $g_NM_livingstoneCmdLineORBObject release

      # kill L2Tools Stanley Server process
      catch { $g_NM_livingstoneEMORBObject exit }

      # killing processes kills all existing servers, in addition to this one
      #       set processName "forwill.Server"
      #       while {[killProcess $processName] != -1} { }

      #       # kill L2Tools Model Browser
      #       set processName "BrowserFrame"
      #       while {[killProcess $processName] != -1} { }
    }

    if {[string match $g_NM_schematicMode "operational"]} {
      # close ipc recorder file, if active
      if {! [string match $g_NM_ipcRecorderFile NIL]} {
        close $g_NM_ipcRecorderFileFid 
      }
    }
    # if xterm that launched Stanley disappears, flush stdout will fail
    catch { flush stdout }
    exit
  }
}


## display a warning message in the main panel
## 09dec97 wmt: 2 line warning msgs
## 20feb98 wmt: add truncateLabelText to prevent Tk from expanding
##              canvas to accomodate very long msg strings
proc pirWarning {msg {msg2 ""} {severity 0} {canvasRootId 0}} {
  global g_NM_inhibitPirWarningP

  # keep warning msg displayed even though mouse is over a
  # connection or a node, when say, a menu item like
  # Reset All Definition Instances
  if {$g_NM_inhibitPirWarningP} {
    return
  }
#   puts stderr "\npirWarning: msg `$msg' msg2 `$msg2'"
#   set backtrace ""; getBackTrace backtrace
#   puts stderr "pirWarning: `$backtrace'"
  set canvasRoot [getCanvasRoot $canvasRootId]
  set widgetPath1 $canvasRoot.warnings.warn1.lab2 
  $widgetPath1 config -text [truncateLabelText $widgetPath1 $msg]
  set widgetPath2 $canvasRoot.warnings.warn2.lab2 
  $widgetPath2 config -text [truncateLabelText $widgetPath2 $msg2] 
  if {$severity} {
    $widgetPath1  config \
        -bg [preferred StanleyAttentionWarningBgColor] \
        -fg [preferred StanleyAttentionWarningFgColor] 
    $widgetPath2 config \
        -bg [preferred StanleyAttentionWarningBgColor] \
        -fg [preferred StanleyAttentionWarningFgColor] 
  } else {
    $widgetPath1  config \
        -bg [preferred StanleyAttentionBgColor] -fg [preferred StanleyAttentionFgColor]
    $widgetPath2 config \
        -bg [preferred StanleyAttentionBgColor] -fg [preferred StanleyAttentionFgColor] 
  }
  if {$canvasRootId > 0} {
    # needed for slave canvases -- somehow the option wraplength
    # is not honored
    $widgetPath1 config -wraplength 0
    $widgetPath2 config -wraplength 0
  }
}


## truncate label text to prevent Tk from expanding label widget
## to accomodate very long text strings
## 20feb98 wmt: new
proc truncateLabelText { widgetPath textString } {

  set bufferWidth 20
  set maxWidth [winfo width $widgetPath]
  set font [lindex [$widgetPath config -font] 4]
  for {set len [string length $textString]} {$len > 0} { incr len -1 } {
    set newWidth [font measure $font [string range $textString 0 $len]]
    # set str "truncateLabelText: len $len newWidth $newWidth maxWidth"
    # puts stderr "$str [expr $maxWidth - $bufferWidth ]"
    if {$newWidth < ($maxWidth - $bufferWidth)} {
      set textString [string range $textString 0 $len]
      break
    }
  }
  return $textString 
}

  
## disable/enable links menu items -- these depend on the patterns
## 09dec97 wmt: not used
proc menuMakeTerminalSet {normal_disabled {in_out out}} {
  if {$in_out == "in"} {
  set In_Out  "Input" 
  } else {
  set In_Out  "Output" 
  } 
#  $g_NM_menuStem.module.m entryconfigure "Group Selected $In_Out Terminals*" \
#    -state $normal_disabled
}

## Cause a menu to appear outside of the normal
## point and click mechanism.
## not used
proc postMenu {menu} {
  global tk_version
  global g_NM_menuStem 

  unpostMenus 
  set x [expr {[winfo x .] + [winfo x $g_NM_menuStem.$menu]}]
  set y [expr {[winfo y .] + [winfo y $g_NM_menuStem.$menu] + 22}]
  $g_NM_menuStem.$menu.m post $x $y
  if {$tk_version >= 4.0} {
    focus -force $g_NM_menuStem
  }
}

## Make any visible menus go away.
## not used
proc unpostMenus {} {
  global g_NM_menuStem 

  foreach child [winfo children $g_NM_menuStem] {
    if {$child != "$g_NM_menuStem.help"} {
      if [winfo ismapped $child.m] {
        $child.m unpost
      }
    }
  }
}


## 11dec95 wmt: new
proc aboutStanley { } {

  set w .about 
  if {[winfo exists $w]} {
    raise $w
    return
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  toplevel $w -class Dialog 
  wm title $w "About Stanley: \"Dr. Livingstone's models, I presume!\"" 
  ## create icon for icon mgr
  wm group $w [winfo toplevel [winfo parent $w]]
  frame $w.buttons -background [preferred StanleyMenuDialogBackgroundColor]
  button $w.buttons.dismiss -text DISMISS -relief raised  \
      -command "destroy $w"
  pack $w.buttons.dismiss -side bottom -padx 5m -ipadx 2m -expand 1
  pack $w.buttons -side bottom -fill x -expand 1

  createTextWidget 0 $w nil nil normal

  $w.text.t configure -wrap word
  $w.text.t configure -font [preferred StanleyHelpFont]
  $w.text.t insert end "Stanley VJMPL version [pirGetVersion]\n\n"

  set text "Stanley is designed by Will Taylor of Code IC and Bill Millar of Caelum Research.  Stanley is implemented by Will Taylor.\n\n"
#   Stanley is derived from the Pirate Data-Flow Builder developed by Phil Laird and Ron Saul of Ames Research Center - Code IC. 
  $w.text.t insert end $text
  set text "Report bugs and/or provide feedback to Will Taylor -- william.m.taylor@nasa.gov.\n"
  $w.text.t insert end $text

  $w.text.t config -state disabled

  keepDialogOnScreen $w
}


## 03jan96 wmt: new
## not used
proc InspectStanley { } {
  global STANLEY_ROOT
  set dialogList [list tk_dialog .d "Inspect Stanley" \
      "\nIn an xterm execute: \n$STANLEY_ROOT/interface/RUN-tkInspect.csh\n" \
      warning 0 {DISMISS}]
  eval $dialogList

  puts stdout "\nIn an xterm execute:\n$STANLEY_ROOT/interface/RUN-tkInspect.csh"
}


## 12jan96 wmt: new
proc disableSelectionMenus { } {
  global g_NM_schematicMode
  global g_NM_currentNodeGroup
  global g_NM_menuStem 
  
  if {[string match $g_NM_schematicMode "layout"]} {
    .master.$g_NM_menuStem.edit.m entryconfigure "Delete" \
        -state disabled
  }
}


## 12jan96 wmt: new
proc enableSelectionMenus { } {
  global g_NM_schematicMode
  global g_NM_currentNodeGroup g_NM_rootInstanceName
  global g_NM_menuStem 

  if {[string match $g_NM_schematicMode "layout"]} {
    if {[string match $g_NM_rootInstanceName \
        [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      .master.$g_NM_menuStem.edit.m entryconfigure "Delete" \
          -state normal
    }
  }
}


##              change schematic mode
## 10feb96 wmt: new
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 30jun96 wmt: remove functionArgList 
## 05oct99 wmt: change name from changeSchematicMode to layoutFileOperation
proc layoutFileOperation { functionToCall cmdName classType } {
  global g_NM_classTypes 

  set enabledDefTypes $g_NM_classTypes 
  set canvasEditingDefTypes [list component module] 
  if {[lsearch -exact $enabledDefTypes $classType] >= 0} {
    set notAvailableP 0
  } else {
    set notAvailableP 1
    notAvailable $cmdName
    set functionToCall ""
  }
  if {! $notAvailableP} {
    cd [getSchematicDirectory root $classType]
    if {[string match $functionToCall ""]} {
      ;
    } else {
      # puts "layoutFileOperation: functionToCall $functionToCall"
      set errorP [eval $functionToCall $classType]
      if {! $errorP} {
        if {[lsearch -exact $canvasEditingDefTypes $classType] >= 0} {
          set toggleSnapToGridP 0
          enableEditingMenus $toggleSnapToGridP 
        }
      }
    }
  }
}


## called from openNodeGroup with check for
## g_NM_rootInstanceName != g_NM_currentNodeGroup 
## 18oct96 wmt: new
proc disableEditingMenus { } {
  global g_NM_schematicMode 
  global g_NM_menuStem 

  if {[string match $g_NM_schematicMode "layout"]} {
    .master.$g_NM_menuStem.edit.m entryconfigure "Instantiate" \
        -state disabled
    # puts stderr "disableEditingMenus: disable Instantiate" 
    # Header is never disabled since its command handles both
    # editing and viewing
    # .master.menus_accels.menu.edit.m entryconfigure "Header" \
        #     -state disabled 
    .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding On" \
        -state disabled
    .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding Off"  \
        -state disabled
  }
}


## called from openNodeGroup with check for
## g_NM_rootInstanceName == g_NM_currentNodeGroup 
## 18oct96 wmt: new
proc enableEditingMenus { { toggleSnapToGridP 1 } } {
  global g_NM_schematicMode 
  global g_NM_menuStem 

  if {[string match $g_NM_schematicMode "layout"]} {
    if {! [componentModuleDefReadOnlyP]} {
      .master.$g_NM_menuStem.edit.m entryconfigure "Instantiate" \
          -state normal
      .master.$g_NM_menuStem.edit.m.instance entryconfigure "attribute ..." \
        -state normal 
      # puts stderr "enableEditingMenus: enable Instantiate"
      if {$toggleSnapToGridP} {
        set toggleP 0; # restore previous state
        toggleSnapToGrid $toggleP
      }
    }
    # Header is always enabled since its command handles both
    # editing and viewing
    .master.$g_NM_menuStem.edit.m entryconfigure "Header" \
        -state normal 
  }
}


## snap y coordinate to a grid
## 14oct95 wmt: new
proc snapToGrid { current x_or_y} {
  global g_NM_canvasGrid g_NM_schematicMode 

  set GridOver2 [expr {$g_NM_canvasGrid / 2}]
  set modulo1 [expr {int ($current) / $g_NM_canvasGrid}]
  set remainder [expr {int( fmod( $current, $g_NM_canvasGrid))}]
  set modulo2 [expr {$modulo1 + [expr ($remainder > $GridOver2) ? 1 : 0]}]
  set grid [expr {$modulo2 * $g_NM_canvasGrid}]
#  if {[string match $g_NM_schematicMode "layout"] == 1} {
#    puts [format {snapToGrid modulo1 %d modulo2 %d remainder %d %s %d => %d} \
#        $modulo1 $modulo2 $remainder $x_or_y [expr int( $current)] $grid]
#  }
  # puts stderr "snapToGrid: x_or_y $x_or_y current $current grid $grid"
  return $grid
}
 

## toggle boolean for g_NM_snapToGridOn
## 07mar96 wmt: new
## 20feb98 wmt: toggle both x and y 
proc toggleSnapToGrid { { toggleP 1 } } { 
  global g_NM_snapToGridOn
  global g_NM_menuStem 

  if {$toggleP} {
    set g_NM_snapToGridOn [expr {[incr g_NM_snapToGridOn] % 2}]
  }
  # puts "toggleSnapToGrid g_NM_snapToGridOn $g_NM_snapToGridOn"
  switch $g_NM_snapToGridOn {
    0 {
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding On" \
          -state normal
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding Off" \
          -state disabled
    }
    1 {
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding On" \
          -state disabled 
      .master.$g_NM_menuStem.edit.m entryconfigure "Location Gridding Off" \
          -state normal
    }
  }   
}


## display ps entry for ipc-stanley-bin to user for killing
## 31dec96 wmt: new
## 26sep97 wmt: killIpcStanleyProcess => killProcess
proc killProcess { processName { quietP 0 } } {
  global env g_NM_win32P 

  if {[winfo exists .master.canvas] && (! $g_NM_win32P)} {
    .master.canvas config -cursor { watch red yellow }
    update
  }
  set pid -1
  set psEntries [exec $env(PS_CMD) auxww]
  set entryList [split $psEntries "\n"]
  foreach entry $entryList {                     
    if {[regexp $processName $entry]} {
      # puts stderr "killProcess entry: $entry"
      set splitList [split $entry " "]
      if {[string match [lindex $splitList 0] $env(LOGNAME)]} {
        # puts stderr "splitList $splitList"
        foreach element $splitList {
          # puts stderr "element $element"
          if {! [string match $element ""]} {
            set firstChar [string index $element 0]
            if {([string compare $firstChar 0] == 0) || \
                    ([string compare $firstChar 9] == 0) || \
                    ([string compare $firstChar 0] && \
                         ([string compare $firstChar 9] == -1))} {
              set pid $element
              break
            }
          }
        }
      }
    }
    if {$pid != -1} {
      break
    }
  }
  # puts stderr "killProcess: pid $pid"
  if {$pid != -1} {
    set foundP 1
    if { [catch { exec kill -9 $pid }]} {
      set foundP 0
    }
    if {(! $quietP) && $foundP} {
      puts stderr "killProcess: $processName: $pid"
    }
  }
  if {[winfo exists .master.canvas] && (! $g_NM_win32P)} {
    .master.canvas config -cursor top_left_arrow
  }
  return $pid 
}


## shrink or enlarge the canvas, incrementally
## 04sep97 wmt: new
# proc resizeCanvas { canvasRootId direction} # {
#   global g_NM_optMenuWidgetValue 
#   global g_NM_windowWidthBorder g_NM_windowHeightBorder 

#   set numChoices 8; set midIndex [expr $numChoices / 2]
#   set canvasRoot [getCanvasRoot $canvasRootId]
#   # puts stderr "resizeCanvas: canvasRoot $canvasRoot"
#   set canvas $canvasRoot.canvas.root.c
#   set currentWidth [lindex [$canvas config -width] 4]
#   set currentHeight [lindex [$canvas config -height] 4]
#   # set str "resizeCanvas: currentWidth [expr $currentWidth + $g_NM_windowWidthBorder]"
#   # puts stderr "$str currentHeight [expr $currentHeight + $g_NM_windowHeightBorder]"
#   set maxWidth [preferred maxCanvasWidth]
#   set minWidth [preferred minCanvasWidth]
#   set widthRange [expr $maxWidth - $minWidth]
#   set widthChoices $minWidth 
#   set delta [expr round( $widthRange / $numChoices)]
#   for {set i 1} {$i < $numChoices} {incr i} {
#     lappend widthChoices [expr $minWidth + ($i * $delta)]
#   }
#   lappend widthChoices $maxWidth
#   set widthChoices [lreplace $widthChoices $midIndex $midIndex \
#                         [preferred StanleyInitialCanvasWidth]]
#   set maxHeight [preferred maxCanvasHeight]
#   set minHeight [preferred minCanvasHeight]
#   set heightRange [expr $maxHeight - $minHeight]
#   set heightChoices $minHeight 
#   set delta [expr round( $heightRange / $numChoices)]
#   for {set i 1} {$i < $numChoices} {incr i} {
#     lappend heightChoices [expr $minHeight + ($i * $delta)]
#   }
#   lappend heightChoices $maxHeight 
#   set heightChoices [lreplace $heightChoices $midIndex $midIndex \
#                         [preferred StanleyInitialCanvasHeight]]
#   # puts stderr "resizeCanvas: widthChoices $widthChoices heightChoices $heightChoices"
#   set choiceIndex -1
#   if {[string match $direction enlarge]} {
#     for {set i 0} {$i <= $numChoices} {incr i} {
#       # puts stderr "resizeCanvas: [lindex $widthChoices $i] > $currentWidth "
#       if {[expr [lindex $widthChoices $i] > $currentWidth]} {
#         set choiceIndex $i
#         break
#       }
#     }
#   } else {
#     for {set i 0} {$i <= $numChoices} {incr i} {
#       # puts stderr "resizeCanvas: $currentWidth <= [lindex $widthChoices $i]"
#       if {[expr $currentWidth <= [lindex $widthChoices $i]]} {
#         set choiceIndex [expr $i - 1]
#         break
#       }
#     }
#   }
#   # puts stderr "resizeCanvas: choiceIndex $choiceIndex"
#   if {$choiceIndex == -1} {
#     bell
#   } else {
#     set width [lindex $widthChoices $choiceIndex]
#     set height [lindex $heightChoices $choiceIndex]
#     # shrink the canvas so that the legend & attention lines will not be lost
#     $canvas config -width $width 
#     $canvas config -height $height 
#     # use window manager to override restriction of Tcl in shrinking
#     # the text in the legend & attention lines
#     set wmWidth [expr $width + $g_NM_windowWidthBorder]
#     set wmHeight [expr $height + $g_NM_windowHeightBorder]
#     # puts stderr "resizeCanvas: newWidth $wmWidth newHeight $wmHeight"
#     wm geometry $canvasRoot ${wmWidth}x${wmHeight}
#   }
# }

## shrink canvas around nodes, ignoring the parent node
proc resizeCanvas { canvasRootId direction} {
  global g_NM_optMenuWidgetValue 
  global g_NM_windowWidthBorder g_NM_windowHeightBorder
  global g_NM_nodeGroupToInstances pirNode
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global pirNodes g_NM_menuStem 

  set shrinkBorder 10
  set canvasRoot [getCanvasRoot $canvasRootId]
  # puts stderr "resizeCanvas: canvasRoot $canvasRoot"
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set rootCanvasPath $canvasRoot.canvas.root.c
  set currentWidth [lindex [$rootCanvasPath config -width] 4]
  set currentHeight [lindex [$rootCanvasPath config -height] 4]
  # set str "resizeCanvas: currentWidth [expr $currentWidth + $g_NM_windowWidthBorder]"
  # puts stderr "$str currentHeight [expr $currentHeight + $g_NM_windowHeightBorder]"
  set initialWidth [preferred StanleyInitialCanvasWidth]
  set initialHeight [preferred StanleyInitialCanvasHeight]
  if {[string match $direction enlarge]} {
    if {$currentWidth == $initialWidth} {
      bell
      return
    } else {
      set width $initialWidth
      set height $initialHeight
      $currentCanvas.c xview moveto 0.0
      $currentCanvas.c yview moveto 0.0
    }
  } else {
    if {[llength $pirNodes] <= 2} {
      bell; return
    }
    if {$currentWidth == $initialWidth} {
      set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
      set nodeGroupInstances [assoc-array $currentNodeGroup g_NM_nodeGroupToInstances] 
      set pirNodeIndices {}
      foreach index [alist-values nodeGroupInstances] {
        if {! [string match [assoc nodeState pirNode($index)] "parent-link"]} {
          lappend pirNodeIndices $index
        }
      }
      set xMin $initialWidth; set xMax 0
      set yMin $initialHeight ; set yMax 0
      foreach index $pirNodeIndices {
        set window [assoc window pirNode($index)]
        set nodeInstanceName [assoc nodeInstanceName pirNode($index)]
        set xLeft [expr {[winfo rootx $window] - $g_NM_xWindowMgrOffset}]
        set yTop [expr {[winfo rooty $window] - $g_NM_yWindowMgrOffset}]
        # puts stderr "resizeCanvas: nodeInstanceName $nodeInstanceName"
        set xRight [expr {$xLeft + [winfo width $window]}]
        set yBottom [expr {$yTop + [winfo height $window]}]
        # puts stderr "      xLeft $xLeft yTop $yTop xRight $xRight yBottom $yBottom"
        if {$xLeft < $xMin} { set xMin $xLeft }
        if {$xRight > $xMax} { set xMax $xRight }
        if {$yTop < $yMin} { set yMin $yTop }
        if {$yBottom > $yMax} { set yMax $yBottom }
      }
      set xMasterOffset [expr {[winfo x .master] - \
                                   [lindex [$canvasRoot.$g_NM_menuStem.file \
                                                config -borderwidth] 4]}]
      set yMasterOffset [expr {[winfo y .master] - \
                                   [winfo height $canvasRoot.$g_NM_menuStem.file] + \
                                   [winfo rooty .master.canvas]}]
      # puts stderr "      xMasterOffset $xMasterOffset yMasterOffset $yMasterOffset"
      set xMin [expr {$xMin - $shrinkBorder - $xMasterOffset}]
      set xMax [expr {$xMax + $shrinkBorder - $xMasterOffset}]
      set yMin [expr {$yMin - $shrinkBorder - $yMasterOffset}]
      set yMax [expr {$yMax + $shrinkBorder - $yMasterOffset}]
      # puts stderr "      xMin $xMin xMax $xMax yMin $yMin yMax $yMax"
      # draw rectangle
      ${currentCanvas}.c addtag "shrink" withtag [${currentCanvas}.c create rectangle \
                                                      $xMin $yMin $xMax $yMax \
                                                      -outline black]
      # scroll canvas
      # set xFraction [expr {$xMin / ${g_NM_absoluteCanvasWidth}.0}]
      # set yFraction [expr {$yMin / ${g_NM_absoluteCanvasHeight}.0}]
      set xFraction [expr {$xMin / ${g_NM_absoluteCanvasWidth}}]
      set yFraction [expr {$yMin / ${g_NM_absoluteCanvasHeight}}]
      puts stderr "      xFraction $xFraction yFraction $yFraction"
      $currentCanvas.c xview moveto $xFraction
      $currentCanvas.c yview moveto $yFraction

      $currentCanvas.c delete "shrink" 

      set width [expr {$xMax - $xMin}]
      set height [expr {$yMax - $yMin}]
    } else {
      bell
      return
    }
  }
  # shrink the canvas so that the legend & attention lines will not be lost
  $rootCanvasPath config -width $width 
  $rootCanvasPath config -height $height 
  # use window manager to override restriction of Tcl in shrinking
  # the text in the legend & attention lines
  set wmWidth [expr {$width + $g_NM_windowWidthBorder}]
  set wmHeight [expr {$height + $g_NM_windowHeightBorder}]
  # puts stderr "resizeCanvas: newWidth $wmWidth newHeight $wmHeight"
  wm geometry $canvasRoot ${wmWidth}x${wmHeight}
}


## enable appropriate class types depending on g_NM_classDefType
## 18nov97 wmt: new
proc enableInstantiateDefsMenu { } {
  global g_NM_classDefType
  global g_NM_menuStem 

  set menuRoot .master.$g_NM_menuStem.edit.m.instance
  if {[string match $g_NM_classDefType component]} {
    $menuRoot entryconfigure "Component" -state disabled
    $menuRoot entryconfigure "Mode" -state normal 
    $menuRoot entryconfigure "Module" -state disabled
  } elseif {[string match $g_NM_classDefType module]} {
    $menuRoot entryconfigure "Component" -state normal
    $menuRoot entryconfigure "Mode" -state disabled 
    $menuRoot entryconfigure "Module" -state normal 
  }
}


## build cascading menu from rootMenu. Use alpha cascade if
## number of entries is large
## 18nov97 wmt: new
## rootMenu = widget path to append rootName 
## rootLabel = user label for rootName
## menuList = widget names for cascade items; and param passed
##              to selectFunction 
## menuLabelList = user labels for cascade items 
proc generateCascadeMenu { rootMenu rootName rootLabel menuList \
                               menuLabelList selectFunction \
                               {rootNameState normal} \
                               {alphabetizeMenuListP 1} } {
  global g_NM_classTypes

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "generateCascadeMenu: `$backtrace'"
  # add elides for non-component, non-module types for fileOpen 
  set dialogClassTypes $g_NM_classTypes
  lremove dialogClassTypes component
  lremove dialogClassTypes module
  if {[llength $menuList] != [llength $menuLabelList]} {
    error "generateCascadeMenu: menuList & menuLabelList not the same length\!"
  }
  # set minAlphaListLength 20; set existsP 0
  set minAlphaListLength 15; set existsP 0
  # discard old cascade menu
  if {[winfo exists $rootMenu.$rootName]} {
    set existsP 1
    destroy $rootMenu.$rootName
  }
  if {! $existsP} {
    $rootMenu add cascade -label $rootLabel -menu $rootMenu.$rootName \
        -state $rootNameState  
  }
  menu $rootMenu.$rootName -tearoff 0 
  if {[llength $menuList] < $minAlphaListLength} {
    set labelList $menuList
    if {! [string match $menuLabelList ""]} {
      set labelList $menuLabelList
    }
    # sort label/command pairs
    set preSortPairList {}
    for {set i 0} {$i < [llength $menuList]} {incr i} {
      lappend preSortPairList [list [lindex $menuLabelList $i] [lindex $menuList $i]]
    }
    if {$alphabetizeMenuListP} {
      set preSortPairList [lsort -ascii -index 0 $preSortPairList]
    }
    foreach itemList $preSortPairList {
      set label [lindex $itemList 0]
      set choice [lindex $itemList 1] 
     if {(($selectFunction == "fileOpen") && \
              ([lsearch -exact $dialogClassTypes $rootName] >= 0)) || \
             ($selectFunction == "instantiateDefinitionUpdate")} {
        append label " ..."
      }
      $rootMenu.$rootName add command -label $label -command \
          "$selectFunction $rootName $choice" 
    }
  } else {
    # alpha cascade menu
    set alphabet {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
    catch { unset alphaSortArray }
    set alphaSortArray(0) 1
    foreach alpha $alphabet {
      set alphaSortArray($alpha) {}
    }
    set alphaSortArray(Other) {}
    for {set i 0} {$i < [llength $menuList]} {incr i} {
      set label [lindex $menuLabelList $i]
      set choice [lindex $menuList $i] 

      set alpha [string toupper [string range $label 0 0]]
      if {([charToAscii $alpha] >= 65) && \
              ([charToAscii $alpha] <= 90)} {
        lappend alphaSortArray($alpha) [list $label $choice]
      } else {
        lappend alphaSortArray(Other) [list $label $choice] 
      }
    }
    set bins [concat $alphabet Other] 
    foreach alpha $bins {
      if {[llength $alphaSortArray($alpha)] > 0} {
        $rootMenu.$rootName add cascade -label $alpha \
            -menu $rootMenu.$rootName.sub$alpha 
        set subM [menu $rootMenu.$rootName.sub$alpha -tearoff 0]
        if {$alphabetizeMenuListP} {
          set alphaSortArray($alpha) [lsort -ascii -index 0 $alphaSortArray($alpha)]
        }
        foreach itemList $alphaSortArray($alpha) {
          set label [lindex $itemList 0] 
          if {(($selectFunction == "fileOpen") && \
                   ([lsearch -exact $dialogClassTypes $rootName] >= 0)) || \
                  ($selectFunction == "instantiateDefinitionUpdate")} {
            append label " ..."
          }
          $subM add command -label $label -command \
              "$selectFunction $rootName [lindex $itemList 1]" 
        }
      }
    }
  }
}


## instantiate class type/class name selected by generateCascadeMenu
## 18nov97 wmt: new
proc instantiateDefinitionUpdate { rootName choice { interactiveP 1 } } {
  global g_NM_selectedClassType g_NM_selectedClassName
  global g_NM_rootInstanceName pirNode 

  getComponentModulePirNodeIndex $g_NM_rootInstanceName pirNodeIndex tmp                          
  set rootModuleClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  if {[string match $rootModuleClassName $choice]} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "You cannot instantiate a class into itself" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  # puts stderr "instantiateDefinitionUpdate: choice $choice"
  set g_NM_selectedClassType $rootName
  set g_NM_selectedClassName $choice
  set canvas [getCanvasRootInfo g_NM_currentCanvas]
#   set x [winfo pointerx $canvas]; set y [winfo pointery $canvas]
  # place instance in upper left hand corner, rather than under the
  # instance dialog
  set x 50; set y 250
  canvasB1Click $canvas.c $x $y $interactiveP 
}


## start the packet view process
## 11feb98 wmt: new
proc startRAXPacketView { mode } {
  global STANLEY_ROOT 

  if {[file exists "$STANLEY_ROOT/ra/ground/bin/rax-ground-pv-ipc-recorder"]} {
    set str "exec xterm -T \"xt: packet view\" -sl 10000 -sb"
    append str " -geometry 80x12+350+830 -e \"tcsh\""
    append str " \"-c\" '$STANLEY_ROOT/ra/ground/RUN-RAX-GROUND-PACKET-VIEW.csh"
    append str " -mode $mode -logdir [preferred PV_defaultLogDir]' &"
    AutoSat_Schematic_Object_Cmd Call_CSH $str
  } else {
    set dialogList [list tk_dialog .d "ERROR" \
                        "Packet View not built" error 0 {DISMISS}]
    eval $dialogList
  }
}


## replace canvas with its parent canvas
## via accelerator button
## 15may98 wmt: new
proc canvasUpAccelerator { canvasRootId } {
  global pirNode g_NM_processingNodeGroupP
  global g_NM_acceleratorStem 

  # puts stderr "canvasUpAccelerator"
  # disable accelerator button until openNodeGroup is finished and
  # reenables it
  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  $acceleratorRoot.canvas_back.arrow config -state disabled 
  $acceleratorRoot.canvas_back.label config -state disabled 
  update

  set canvasParentNodeIdList [getCanvasRootInfo g_NM_canvasParentNodeIdList \
                                 $canvasRootId]
  set canvasParentNodeIndex [lindex $canvasParentNodeIdList 0]
  set canvasParentNodeWindow [lindex $canvasParentNodeIdList 1]
  set nodeInstanceName [assoc nodeInstanceName \
                            pirNode($canvasParentNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($canvasParentNodeIndex)]
  openNodeGroup $nodeInstanceName $nodeClassType $canvasParentNodeWindow 

  set g_NM_processingNodeGroupP 0
}


## Enter binding proc for canvas back accelerator
## 15may98 wmt: new
proc canvasBackAccelEnter { canvasRootId } {
  global g_NM_acceleratorStem 

  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  if {[string match [lindex [$acceleratorRoot.canvas_back.arrow \
                                 config -state] 4] \
           normal]} {
    $acceleratorRoot.canvas_back.arrow \
        config -bg [preferred StanleySelectedColor]
    $acceleratorRoot.canvas_back.label \
        config -bg [preferred StanleySelectedColor]
    $acceleratorRoot.canvas_back \
        config -bg [preferred StanleySelectedColor]

    set displayLabel [getModuleParentLabel $canvasRootId]

    set msg2 {}; set severity 0
    pirWarning "<Mouse-L click>: open $displayLabel" $msg2 \
        $severity $canvasRootId 
  }
}


## Leave binding proc for canvas back accelerator
## 15may98 wmt: new
proc canvasBackAccelLeave { canvasRootId } {
  global g_NM_acceleratorStem
 
  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  $acceleratorRoot.canvas_back.arrow \
      config -bg [preferred StanleyMenuDialogBackgroundColor]
  $acceleratorRoot.canvas_back.label \
      config -bg [preferred StanleyMenuDialogBackgroundColor]
  $acceleratorRoot.canvas_back \
      config -bg [preferred StanleyMenuDialogBackgroundColor]
  set msg {}; set msg2 {}; set severity 0
  pirWarning $msg $msg2 $severity $canvasRootId 
}


## enter binding for show node icon labels accelerator
## 05nov99 wmt: new
proc showLabelsEnter { canvasRootId } {
  global g_NM_acceleratorStem  

  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  if {[string match [lindex [$acceleratorRoot.show_labels.label config -state] 4] \
           normal]} {
    $acceleratorRoot.show_labels config -bg [preferred StanleySelectedColor]
    $acceleratorRoot.show_labels.label config -bg [preferred StanleySelectedColor]

    set msg2 {}; set severity 0
    set msg "<Mouse-L click>: show node icon labels"
    pirWarning $msg $msg2 $severity $canvasRootId 
  }
}


## leave binding for show node icon labels accelerator
## 30aug99 wmt: new
proc showLabelsLeave { canvasRootId } {
  global g_NM_acceleratorStem
 
  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  $acceleratorRoot.show_labels config -bg [preferred StanleyMenuDialogBackgroundColor]
  $acceleratorRoot.show_labels.label config -bg [preferred StanleyMenuDialogBackgroundColor]
  set msg {}; set msg2 {}; set severity 0
  pirWarning $msg $msg2 $severity $canvasRootId 
}


## enter binding for hide node icon labels accelerator
## 05nov99 wmt: new
proc hideLabelsEnter { canvasRootId } {
  global g_NM_acceleratorStem  

  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  if {[string match [lindex [$acceleratorRoot.hide_labels.label config -state] 4] \
           normal]} {
    $acceleratorRoot.hide_labels config -bg [preferred StanleySelectedColor]
    $acceleratorRoot.hide_labels.label config -bg [preferred StanleySelectedColor]

    set msg2 {}; set severity 0
    set msg "<Mouse-L click>: hide node icon labels"
    pirWarning $msg $msg2 $severity $canvasRootId 
  }
}


## leave binding for hide node icon labels accelerator
## 30aug99 wmt: new
proc hideLabelsLeave { canvasRootId } {
  global g_NM_acceleratorStem
 
  set canvasRoot [getCanvasRoot $canvasRootId]
  set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
  $acceleratorRoot.hide_labels config -bg [preferred StanleyMenuDialogBackgroundColor]
  $acceleratorRoot.hide_labels.label config -bg [preferred StanleyMenuDialogBackgroundColor]
  set msg {}; set msg2 {}; set severity 0
  pirWarning $msg $msg2 $severity $canvasRootId 
}


## put up toplevel window of display state tokens/colors legend for
## VMPL test mode
## this widget expands with window manager properly
## 08nov99 wmt: new
proc popupDisplayStateLegend { } {
  global g_NM_displayStateColorMapping
  global g_NM_advisoryRootWindow 

  if {[llength $g_NM_displayStateColorMapping] == 0} {
    set msg "File [lindex [preferred STANLEY_USER_DIR] 0]/display-state-color-prefs \ndoes not exist"
    set dialogList [list tk_dialog .d "ERROR" $msg \
                        error 0 {DISMISS}]
    eval $dialogList
    return 
  }
  set textHeight 12; set textWidth 24
  set window ${g_NM_advisoryRootWindow}.state_legend
  if {[winfo exists $window]} {
    raise $window
    return
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  toplevel $window -class Dialog
  if { [winfo viewable [winfo toplevel [winfo parent $window]]] } {
    wm transient $window [winfo toplevel [winfo parent $window]]
  }    
  wm title $window "Display State Legend"
  $window config -bg $bgcolor
  frame $window.text&button -bd 0 -bg $bgcolor -relief ridge 
  frame $window.text&button.t -bd 0 -bg $bgcolor -relief ridge 
  frame $window.text&button.t.right -bd 0 -bg $bgcolor -relief ridge 
  frame $window.text&button.t.bottom -bd 0 -bg $bgcolor
  frame $window.text&button.b -bd 0 -bg $bgcolor -relief ridge 

  set txt [text $window.text&button.t.text -setgrid true \
               -xscrollcommand "$window.text&button.t.bottom.sx set" \
               -yscrollcommand "$window.text&button.t.right.sy set" \
               -wrap none -font [preferred StanleyDialogEntryFont]]

  scrollbar $window.text&button.t.bottom.sx -orient horiz \
      -command "$txt xview" -relief sunk -bd 2 
  scrollbar $window.text&button.t.right.sy -orient vertical \
      -command "$txt yview" -relief sunken -bd 2 

  button $window.text&button.b.cancel -text " DISMISS " -relief raised \
      -command "destroy $window" -padx 5 -pady 5
  pack $window.text&button.b.cancel -side bottom -padx 0 -ipadx 0 -expand 1
  pack $window.text&button.b -side bottom -fill x
  pack $window.text&button -fill both -expand 1

  pack $window.text&button.t.right.sy -side right -fill y -expand 1
  pack $window.text&button.t.right -side right -fill y
  pack $window.text&button.t.bottom.sx -side bottom -fill x -expand 1
  pack $window.text&button.t.bottom -side bottom -fill x 
  pack $window.text&button.t.text -side bottom -fill both -expand 1
  pack $window.text&button.t -side bottom -fill both -expand 1
  # characters
  $txt config -width $textWidth 
  $txt config -height $textHeight 

  for {set i 0} {$i < [llength $g_NM_displayStateColorMapping]} {incr i 2} {
    set stateName [lindex $g_NM_displayStateColorMapping $i]
    set stateBgColor [lindex $g_NM_displayStateColorMapping [expr {$i + 1}]]
    $txt insert end "$stateName\n" tag_$i
    $txt tag configure tag_$i -background [preferred $stateBgColor] \
        -spacing1 4 -spacing3 4 -justify center
  }
  $txt config -state disabled 

  keepDialogOnScreen $window
}


## enable "Delete All View Dialogs" in Tools menu
## 09nov99 wmt: new
proc enableViewDialogDeletion { {canvasRootId 0} } {
  global g_NM_menuStem 
  
  set canvasRoot [getCanvasRoot $canvasRootId]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  $menuRoot.tools.m entryconfigure "Delete All View Dialogs" \
      -state normal
}


## build the File->Open Workspace or
## File->Forget Workspace cascade menu
## 23jun00 wmt
proc buildWorkspaceCascadeMenu { command menuPath startupP } {
  global g_NM_menuStem g_NM_projectId_default 

  # current workspace is the first in the list
  set workspaceList [lrange [preferred STANLEY_USER_DIR] 1 end]
  # sort by leaf directory
  set preSortPairList {}
  foreach workspacePath $workspaceList {
    # do not allow sample workspace to be forgotten
    if {($command == "openWorkspace") || \
            (($command == "forgetWorkspace") && \
                 (! [string match [file tail $workspacePath] $g_NM_projectId_default]))} {
      lappend preSortPairList [list [file tail $workspacePath] $workspacePath]
    }
  }
  set preSortPairList [lsort -ascii -index 0 $preSortPairList]
  foreach pair $preSortPairList {
    set workspaceId [lindex $pair 0]
    set workspacePath [lindex $pair 1]
    set label "$workspacePath"
    $menuPath add command -label $label \
        -command "$command $workspacePath $workspaceId $startupP"
  }
}




