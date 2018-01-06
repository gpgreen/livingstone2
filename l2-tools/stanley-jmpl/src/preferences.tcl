# $Id: preferences.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## preferences.tcl

## maintains the preferences menu and values derived therefrom
## Globals:  pirPreferences = an alist of preferences
## Files:    $HOME/.stanley/stanley-prefs  (a database of preferences)

## The preferences facility is supported as follows:
## pirPreferencesInit : "factory" settings
## pirReadPreferences : reads in the "pirpreferences" file and overrides defaults
## pirSavePreferences : writes current preferences in the prefs. database,
##   saves the old database as "pirpreferences~"
## pirEditPreferences : lets the user change the values, 
##   temporarily or permanently
## preferred : gets the currently preferred value of a parameter
 

## return to default "factory" settings
## also used to determine factory settings without rewriting them
## 08oct95 wmt: added newmaap colors; change other preferences
## 16oct95 wmt: replace pirate_directory with STANLEY_ROOT
## 05feb96 wmt: add *_directories
## 09oct98 wmt: pirPreferences is now an array, rather than an assoc list
## "-*-times-bold-r-normal-*-14-*-*-*-*-*-*-*"
proc pirPreferencesInit { } {
  global pirPreferences g_NM_STANLEY_USER_DIR_default
  global g_NM_projectId_default g_NM_l2toolsPrefsP 

  set pirPreferences(0) 1
  # non Edit-Preferences preferences
  set pirPreferences(module_directory) "modules"
  set pirPreferences(link_directory) "links"
  set pirPreferences(livingstone_directory) "livingstone"
  set pirPreferences(models_directory) "models"
  set pirPreferences(schematic_directory) "schematics"
  set pirPreferences(canned_directory) "canned"
  set pirPreferences(scenario_directory) "scenarios"
  set pirPreferences(defcomponents_directory) "defcomponents"
  set pirPreferences(defmodules_directory) "defmodules"
  set pirPreferences(abstractions_directory) "abstractions"
  set pirPreferences(defrelations_directory) "defrelations"
  set pirPreferences(structures_directory) "structures"
  set pirPreferences(defsymbols_directory) "defsymbols"
  set pirPreferences(defvalues_directory) "defvalues"
  set pirPreferences(variantStructures_directory) "variantStructures"
  set pirPreferences(spec_item_directory) "specs"
  set pirPreferences(terminals_directory) "terminals"
  set pirPreferences(attributes_directory) "attributes"
  set pirPreferences(modes_directory) "modes"
  set pirPreferences(component-test_directory) "component-test"
  set pirPreferences(module-test_directory) "module-test"
  set pirPreferences(minCanvasWidth) 400
  set pirPreferences(minCanvasHeight) 400
  set pirPreferences(maxCanvasWidth) 1200
  set pirPreferences(maxCanvasHeight) 1000
  set pirPreferences(NM_powerOnBgColor) Gold1
  set pirPreferences(NM_powerAvailableSliderBg) lightPink
  set pirPreferences(NM_powerAvailableSliderFg) blue
  set pirPreferences(NM_powerAvailableSliderMaxFg) red
  set pirPreferences(NM_powerAvailableLabelBg) lightPink
  set pirPreferences(NM_powerAvailableLabelFg) black
  set pirPreferences(propStateLabelBgColor) gray60
  set pirPreferences(propStateLabelFont) {helvetica 12 bold}
  set pirPreferences(NM_terminalDeclNodeBgColor) black
  set pirPreferences(NM_terminalTermNodeBgColor)  black
  set pirPreferences(NM_unknownPowerBgColor)  gray60
  set pirPreferences(NM_inactiveStateBgColor)  LightBlue
  set pirPreferences(NM_activeStateBgColor)  lawnGreen
  set pirPreferences(NM_recoverableStateBgColor)  Gold1
  set pirPreferences(NM_failedStateBgColor)  red
  set pirPreferences(NM_degradedStateBgColor1)  magenta2
  set pirPreferences(NM_degradedStateBgColor2)  magenta2
  set pirPreferences(NM_degradedStateBgColor3)  magenta2
  set pirPreferences(NM_degradedStateBgColor4)  magenta2
  set pirPreferences(NM_degradedStateBgColor5)  magenta2
  set pirPreferences(NM_propsTerminalConnectionColor) orange
  set pirPreferences(PV_defaultLogDir)  /home/mars/DS1-1/R3

  set pirPreferences(STANLEY_USER_DIR) $g_NM_STANLEY_USER_DIR_default 
  set pirPreferences(projectId) $g_NM_projectId_default 
  set pirPreferences(LIVINGSTONE_MODELS_DIR) <unspecified>

  if {! $g_NM_l2toolsPrefsP} {
    # Edit->Preferences preferences -- the defaults
    # these defaults are now also in l2tools/preferences/prefDefaults
    # Candidate Mgr comes up at 0,0 -- allow it to be seen
    set pirPreferences(L2SearchMethod) cbfs
    # 0 indicates unbounded classes
    set pirPreferences(L2MaxCBFSCandidateClasses) 0
    set pirPreferences(L2MaxCBFSCandidates) 5
    set pirPreferences(L2MaxCBFSSearchSpace) 3500
    set pirPreferences(L2MaxCBFSCutoffWeight) 100
    set pirPreferences(L2MaxCoverCandidateRank) 8
    # 0 indicates unbounded history 
    set pirPreferences(L2MaxHistorySteps) 3
    set pirPreferences(L2ProgressCmdType) min
    set pirPreferences(L2NumTrajectoriesTracked) 5
    set pirPreferences(L2FindCandidatesCmdType) prune-search

    set pirPreferences(StanleyEliminateUnreferencedJmplVars) off
    set pirPreferences(StanleyTestPermanentBalloons) off
    set pirPreferences(StanleyShowNodeLegendBarP) 0
    set pirPreferences(StanleyWindowXPosition)  200
    set pirPreferences(StanleyWindowYPosition)  100
    set pirPreferences(StanleyInitialCanvasWidth)  950
    set pirPreferences(StanleyInitialCanvasHeight)  645
    set pirPreferences(StanleySchematicCanvasBackgroundColor)  lightblue3
    set pirPreferences(StanleyTestCanvasBackgroundColor)  MediumSeaGreen
    set pirPreferences(StanleySelectedColor)  yellow
    set pirPreferences(StanleyNodeConnectionBgColor)  black
    set pirPreferences(StanleyModeTransitionBgColor)  black
    set pirPreferences(StanleyMenuDialogBackgroundColor)  gray77
    set pirPreferences(StanleyMenuDialogForegroundColor)  black
    set pirPreferences(StanleyDialogButtonColor)  gray77
    set pirPreferences(StanleyDialogEntryBackgroundColor)  white
    set pirPreferences(StanleyDialogEntryForegroundColor)  black
    set pirPreferences(StanleyLegendBgColor)  gray77
    set pirPreferences(StanleyLegendFgColor)  black
    set pirPreferences(StanleyTitleBgColor)  maroon
    set pirPreferences(StanleyTitleFgColor)  white
    set pirPreferences(StanleyRubberBandColor)  yellow
    set pirPreferences(StanleyBalloonHelpBackgroundColor)  lightYellow
    set pirPreferences(StanleyBalloonHelpForegroundColor)  black
    set pirPreferences(StanleyNodeLabelForegroundColor)  black
    set pirPreferences(StanleyScrollBarColor)  gray77
    set pirPreferences(StanleyScrollBarTroughColor)  gray60
    set pirPreferences(StanleyAttentionBgColor)  gray77
    set pirPreferences(StanleyAttentionFgColor)  black
    set pirPreferences(StanleyAttentionWarningBgColor)  red
    set pirPreferences(StanleyAttentionWarningFgColor)  white
    set pirPreferences(StanleyComponentLabelFont) -adobe-fixed-normal-r-normal-*-10-*-*-*-*-*-*-*
    # Windows platforms running Exceed to a unix host, cannot handle size 14, use 13
    set pirPreferences(StanleyDialogEntryFont) -adobe-fixed-normal-r-normal-*-13-*-*-*-*-*-*-*
    set pirPreferences(StanleyDefaultFont)  -adobe-helvetica-normal-r-normal-*-12-*-*-*-*-*-*-*
    set pirPreferences(StanleyTerminalTypeFont)  -adobe-fixed-normal-r-normal-*-13-*-*-*-*-*-*-*
    set pirPreferences(StanleyHelpFont)  -adobe-helvetica-normal-r-normal-*-12-*-*-*-*-*-*-*
    set pirPreferences(StanleyModuleNodeBgColor)  gray90
    set pirPreferences(StanleyComponentNodeBgColor)  gray90
    set pirPreferences(StanleyOkModeNodeBgColor)  lightgreen
    set pirPreferences(StanleyFaultModeNodeBgColor)  red1
    set pirPreferences(StanleyAttributeNodeBgColor)  orange
    set pirPreferences(StanleyTerminalNodeBgColor)  gray90
    set pirPreferences(StanleyNodataStateBgColor) pink
    set pirPreferences(StanleyIndeterminateStateBgColor) hotPink
    set pirPreferences(StanleyUnknownL2ValueStateBgColor) magenta
    set pirPreferences(StanleyNonCurrentModeBgColor)  gray60
    set pirPreferences(StanleyCurrentOkModeBgColor)  LawnGreen
    set pirPreferences(StanleyCurrentFaultModeBgColor)  red
    # not used
    # set pirPreferences(StanleyPropsWaveformColor) lawnGreen
    set pirPreferences(StanleyScenarioMgrExecColor) lawnGreen
    set pirPreferences(StanleyScenarioMgrEditColor) yellow
    set pirPreferences(StanleyScenarioMgrBreakPointColor) red
  }
}


## returns the path name of the module config path (cfgpath)
## a soft link to the .cfg file
## 11feb96 wmt: added [modeSubDirectory]
## 30may96 wmt: remove STANLEY_MISSION from pathnames
proc cfgpathFiles {family module {modeSubDirType ""} } {

  set path "[cfgFilesDirectory]"
  if {[string length $modeSubDirType] == 0} {
    return "$path/$family/${module}.cfg"
  } else {
    return "$path/$modeSubDirType/${module}.cfg"
  }
}


## returns the path name of the module config path (cfgpath)
## a soft link to the .cfg file
## 11feb96 wmt: added [modeSubDirectory]
## 30may96 wmt: remove STANLEY_MISSION from pathnames
proc cfgpathLinks {family module {modeSubDirType ""} } {

  # puts stderr "cfgpathLinks: family $family module $module"
  set path "[cfgLinksDirectory]"
  # path has trailing /
  if {[string length $modeSubDirType] == 0} {
    return "${path}$family/${module}"
  } else {
    return "${path}$modeSubDirType/${module}"
  }
}


## Returns the preferred or default module directory path.
## 16oct95 wmt: replace pirate_directory with BUILDER_LIBRARY
## 18dec95 wmt: replace BUILDER_LIBRARY with STANLEY_ROOT 
proc cfgFilesDirectory {} {
  global STANLEY_ROOT

  set cfg_directory $STANLEY_ROOT/interface/user-template
  set module_directory [preferred module_directory]
  return "${cfg_directory}/${module_directory}/"
}


## 18dec95 wmt: new
proc cfgLinksDirectory {} {
  global STANLEY_ROOT

  set cfg_directory $STANLEY_ROOT/interface/user-template
  set link_directory [preferred link_directory]
  return "${cfg_directory}/${link_directory}/"
}


## obtain preference. Return default if not set
## 07apr96 wmt: comment out substituted outcome
## 20nov96 wmt: added reportNotFoundP; reload defaults if 
##              preference value not found in schematic file
##              values
## 09oct98 wmt: pirPreferences is now an array, rather than an assoc list
proc preferred { field {type current} } {
  global pirPreferences l2toolsPreferences userPreferences
  global workspacePreferences defaultPreferences 

  if {$type == "current"} {
    set pValue $pirPreferences($field)
  } elseif {$type == "default"} {
    set pValue $defaultPreferences($field)
  } elseif {$type == "l2tools"} {
    set pValue $l2toolsPreferences($field)
  } elseif {$type == "user"} {
    set pValue $userPreferences($field)
  } elseif {$type == "workspace"} {
    set pValue $workspacePreferences($field)
  } else {
    error "preferred: type $type not handled"
  }
  return $pValue
}


## save user preferences
## mode: editUser & editWorkspace
## 12jan97 wmt: adapt to g_NM_editablePrefNames 
proc pirSavePreferences { mode } {
  global env g_NM_editablePrefNames 
  global userPreferences workspacePreferences defaultPreferences 

  # determine default preferences
  pirDefaultPreferences $mode

  if {$mode == "user"} {
    set path "$env(HOME)/.stanley/userPrefs"
  } elseif {$mode == "workspace"} {
    set path "[lindex [preferred STANLEY_USER_DIR] 0]/workspacePrefs"
  } else {
    error "pirSavePreferences: mode $mode not handled"
  }
  if {! [savefile $path]} {
    error "Error: Attempt to save the file $path failed. Please check your permissions and HOME environment variable." 
  }

  if [catch {set f [open $path w]} msg] {
    error "Error while trying to write to $path. $msg\n Please check your permissions and the HOME environment." 
  }
  if {$mode == "user"} {
    puts $f [format "%s = %s" STANLEY_USER_DIR [preferred STANLEY_USER_DIR]]
    puts $f [format "%s = %s" projectId [preferred projectId]]
  }
  set prefsLength [llength $g_NM_editablePrefNames]
  for {set i 0} {$i < $prefsLength} {incr i} {
    set prefname [lindex $g_NM_editablePrefNames $i]
    if {$mode == "user"} {
      # only write to file those prefs which were entered by Edit->Prefreences->Edit User
      if {[info exists userPreferences($prefname)]} {
        set prefvalue $userPreferences($prefname)
        puts $f [format "%s = %s" $prefname $prefvalue]
     }
    } elseif {$mode == "workspace"} {
      # only write to file those prefs which were entered by Edit->Prefreences->Edit Workspace
      if {[info exists workspacePreferences($prefname)]} {
        set prefvalue $workspacePreferences($prefname)
        puts $f [format "%s = %s" $prefname $prefvalue]
      }
    } else {
      error "pirSavePreferences: mode $mode not handled"
    }
  }
  close $f
  puts stdout "Writing $path\n"
}


## read user "preferences" if it exists and override current settings
## 13oct95 wmt: allow comment lines of form "# # comment ..."
## 20oct95 wmt: use schematicMode to determine which .stanley/stanley-prefs 
##              to read; allow blank lines in pirpreferences 
## 24jan96 wmt: in definition mode look for user .stanley/stanley-prefs first
## 20feb98 wmt: in all modes look for user .stanley/stanley-prefs first
##              no more comments in prefs file
## 09oct98 wmt: pirPreferences is now an array, rather than an assoc list
proc pirReadPreferences { mode } {
  global pirPreferences env userPreferences workspacePreferences 

  if {$mode == "user"} {
    set path "$env(HOME)/.stanley/userPrefs"
    catch { unset userPreferences }
    set userPreferences(0) 1
  } elseif {$mode == "workspace"} {
    set path "[lindex [preferred STANLEY_USER_DIR] 0]/workspacePrefs"
    catch { unset workspacePreferences }
    set workspacePreferences(0) 1
  } else {
    error "pirReadPreferences: mode $mode not handled"
  }
  if {! [file exists $path]} {
    return
  }

  if [catch {set f [open $path r]} msg] {
    puts stderr "Preferences file ($path) not found or not readable."
    exit
  }
  puts stdout "Reading $path"
  # puts stderr "pirReadPreferences: before pirPreferences $pirPreferences"
  while {[gets $f line] >= 0} {
    if {([string index $line 0] != "#") && ($line != "")} {
      set splitList [split $line "="]
      set prefname [string trim [lindex $splitList 0] " "]
      set prefvalue [string trim [lindex $splitList 1] " "]
      # puts stderr [format {pirReadPreferences %s %s} $prefname $prefvalue]
      if {[string match $prefname StanleyDialogEntryFont] && \
              (! [regexp fixed $prefvalue])} {
        set str "pirReadPreferences: $prefname value ignored --\n" 
        puts stderr "$str     it is not a fixed width font\!\n    $prefvalue"
        bell
      } else {
        # puts [format {pirReadPreferences before %s} [preferred $prefname]]
        if {$mode == "user"} {
          set userPreferences($prefname) $prefvalue
          # override current prefs
          set pirPreferences($prefname) $prefvalue
        } elseif {$mode == "workspace"} {
          set workspacePreferences($prefname) $prefvalue
        } else {
          error "pirReadPreferences: mode $mode not handled"
        }
        # puts [format {pirReadPreferences after %s} [preferred $prefname]]
        # flush stdout
      }
    } elseif {[string length $line] == 0} {
      ;         # skip empty line
    } else {
      puts stderr "Invalid preference ignored: $line"
    }
  }
  close $f
  # puts stderr "pirReadPreferences: after pirPreferences $pirPreferences" 
}


## apply l2tools user and current workspace preferences to
## get current preferences
## 01dec00 wmt: new
proc pirLoadPreferences { } {
  global pirPreferences userPreferences workspacePreferences
  global l2toolsPreferences

  # do not unset pirPreferences, since it has other internal prefs
  set arrayInitList [array get l2toolsPreferences]
  array set pirPreferences $arrayInitList 

  set arrayInitList [array get userPreferences]
  array set pirPreferences $arrayInitList 

  set arrayInitList [array get workspacePreferences]
  array set pirPreferences $arrayInitList 
}


## fill pirDefaultPreferences depending on upToMode 
## 01dec00 wmt: new
proc pirDefaultPreferences { upToMode } {
  global pirPreferences userPreferences workspacePreferences
  global l2toolsPreferences defaultPreferences 

  catch { unset defaultPreferences }
  set defaultPreferences(0) 1
  set arrayInitList [array get l2toolsPreferences]
  array set defaultPreferences $arrayInitList

  if {$upToMode == "user"} {
    return
  }
  set arrayInitList [array get userPreferences]
  adel STANLEY_USER_DIR arrayInitList
  adel projectId arrayInitList 
  array set defaultPreferences $arrayInitList 
}


## edit preferences
## choose colors under Solaris using /opt/local/bin/xcolorsel
## mode => editWorkspace editUser view
## 12jan97 wmt: allow user to edit selected preferences
proc pirEditPreferences { preferencesLiteral mode {startupP 0} } {
  global env g_NM_vmplPrefNames g_NM_schematicMode
  global g_NM_editablePrefNames g_NM_editablePrefDescriptions
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_prefsAppliedAtRestart g_NM_yWindowMgrOffset
  global g_NM_xWindowMgrOffset g_NM_prefsAppliedAtOpsReset
  global g_NM_editPrefsRootWindow userPreferences
  global workspacePreferences defaultPreferences
  global g_NM_STANLEY_USER_DIR_default STANLEY_SUPERUSER 

  # determine default preferences
  pirDefaultPreferences $mode

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  set w $g_NM_editPrefsRootWindow 
  set xPos -1; set yPos -1
  if {[winfo exists $w]} {
    set xPos [expr {[winfo rootx $w] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $w] - $g_NM_yWindowMgrOffset}]
  }
  catch {destroy $w}
  toplevel $w -class Dialog
  set modeLabel [capitalizeWord $mode] 
  set title "Edit $modeLabel Preferences"
  set entryState normal
  set legendPhrase "will be saved"
  set buttonState normal
  if {$mode == "view"} {
    set title "View Preferences"
    set entryState disabled
    set modeLabel "L2Tools"
  } elseif {$mode == "user"} {
    set path "$env(HOME)/.stanley/userPrefs"
    set defaultStr ""
  } elseif {$mode == "workspace"} {
    set path "[lindex [preferred STANLEY_USER_DIR] 0]/workspacePrefs"
    set defaultStr ", then user preferences"
    if {(! [string match $env(LOGNAME) $STANLEY_SUPERUSER]) && \
            [string match [lindex [preferred STANLEY_USER_DIR] 0] \
                 $g_NM_STANLEY_USER_DIR_default]} {
      set title "View [capitalizeWord $mode] Preferences"
      set entryState disabled
      set legendPhrase "are"
      set buttonState disabled
    }
  } else {
    error "pirEditPreferences: mode $mode not handled"
  }

  wm title $w $title
  wm group $w [winfo toplevel [winfo parent $w]]
  frame $w.f -bd 2 -relief ridge -bg $bgcolor 
  if {$mode != "view"} {
    message $w.m -text "The preferences $legendPhrase in the file '$path'.\nPulldown menu fonts, legend fonts, and other settings marked with * will not take effect \nuntil you restart Stanley.\nDefault values are determined from loading L2Tools defaults$defaultStr." \
        -aspect 1000 -bg $bgcolor -font [preferred StanleyDefaultFont] -justify center \
        -foreground [preferred StanleyMenuDialogForegroundColor] 
  } else {
    message $w.m -text "Preference values are determined from loading L2Tools defaults, then user preferences, and then workspace preferences." \
        -aspect 1000 -bg $bgcolor -font [preferred StanleyDefaultFont] -justify center \
        -foreground [preferred StanleyMenuDialogForegroundColor] 
  }
  pack $w.m $w.f -side top -fill both -expand 1
  if {[llength $g_NM_editablePrefNames] != [llength $g_NM_editablePrefDescriptions]} {
    set str "pirEditPreferences: g_NM_editablePrefNames & g_NM_editablePrefDescriptions"
    error "$str are not the same length"
  }

  set canvasPath $w.f
  frame $canvasPath.bottom
  canvas $canvasPath.c -height 400  -scrollregion [list 0 0 1200 2000] \
      -yscrollcommand "$canvasPath.yscroll set" -bg $bgcolor \
      -xscrollcommand "$canvasPath.bottom.xscroll set" -bg $bgcolor
  scrollbar $canvasPath.bottom.xscroll -orient horiz -command "$canvasPath.c xview" \
      -relief sunk -bd 2 
  scrollbar $canvasPath.yscroll -command "$canvasPath.c yview" \
      -relief sunk -bd 2 
  pack $canvasPath.bottom.xscroll -side left -fill x -expand 1
  pack $canvasPath.bottom -side bottom -fill x
  pack $canvasPath.yscroll -side right -fill y
  pack $canvasPath.c -side left -fill both -expand 1 

  set numPrefs 0; set y 20
  set prefsLength [llength $g_NM_editablePrefNames]
  set dialogPrefNames {}; set oldPrefValues {}
  set prefEntryWidth 0
  set labelTextCharWidth 60; set labelColorCharWidth 6; set labelRestartCharWidth 1
  set labelWidthList [list $labelTextCharWidth $labelColorCharWidth \
                          $labelRestartCharWidth]
  for {set i 0} {$i < $prefsLength} {incr i} {
    set prefname [lindex $g_NM_editablePrefNames $i]
    # STANLEY_USER_DIR & projectId are not editable, but are saved with the user
    # preferences. They are managed by askNewWorkspace & openWorkspace
    if {([lsearch -exact {STANLEY_USER_DIR projectId} $prefname] == -1) && \
            ([string match $g_NM_schematicMode layout] || \
                 ([string match $g_NM_schematicMode operational] && \
                      ([lsearch -exact $g_NM_vmplPrefNames $prefname] == -1)))} {
      lappend dialogPrefNames $prefname
      if {$mode == "view"} {
        set prefvalue [preferred $prefname]
        set editValue $prefvalue 
      } elseif {$mode == "user"} {
        if {[info exists userPreferences($prefname)]} {
          set prefvalue $userPreferences($prefname)
          set editValue $prefvalue 
        } else {
          set prefvalue $defaultPreferences($prefname) 
          set editValue ""
        }
      } elseif {$mode == "workspace"} {
        if {[info exists workspacePreferences($prefname)]} {
          set prefvalue $workspacePreferences($prefname)
          set editValue $prefvalue 
          # puts stderr "workspace $workspacePreferences($prefname) default $defaultPreferences($prefname)"
        } else {
          set prefvalue $defaultPreferences($prefname) 
          set editValue ""
          # puts stderr "          default $defaultPreferences($prefname)"
        }
      } else {
        error "pirEditPreferences: no prefvalue for mode $mode"
      }
      lappend oldPrefValues $editValue 
      incr numPrefs
      frame $canvasPath.c.f$numPrefs -relief flat \
          -highlightthickness 1 -highlightcolor black -highlightbackground black
      set labelFont [preferred StanleyDefaultFont]
      set labelBgColor $bgcolor
      set labelColorBgColor $bgcolor
      set highlightColor $bgcolor
      # pref label
      set labelText [string trim [lindex $g_NM_editablePrefDescriptions $i] "\""]
      if {[regexp -nocase "font" $prefname]} {
        set labelFont $prefvalue
      }
      label $canvasPath.c.f$numPrefs.l \
          -bg $labelBgColor -font $labelFont -width $labelTextCharWidth \
          -anchor w -text $labelText 
      if {[regexp -nocase "color" $prefname]} {
        set labelColorBgColor $prefvalue
        set highlightColor black
      }

      # if pref is a color, put in a color rectangle
      label $canvasPath.c.f$numPrefs.c \
          -bg $labelColorBgColor -font $labelFont -width $labelColorCharWidth \
          -text "" -highlightthickness 1 -highlightcolor $highlightColor \
          -highlightbackground $highlightColor

      # restart required for pref application
      set restartText " "
      if {$mode != "view"} {
        if {(! $startupP) && \
                [lsearch -exact $g_NM_prefsAppliedAtRestart $prefname] >= 0} {
          set restartText "*"
        }
        if {[lsearch -exact $g_NM_prefsAppliedAtOpsReset $prefname] >= 0} {
          set restartText "#"
        }
      }
      label $canvasPath.c.f$numPrefs.r \
          -bg $labelBgColor -font $labelFont \
            -width $labelRestartCharWidth -anchor e -text $restartText 

      if {$mode != "view"} {
        # default value from l2tools for user prefs
        # default value from l2tools & user  for workspace prefs
        entry $canvasPath.c.f$numPrefs.d -relief flat -bd 2 -width 52 \
            -font [preferred StanleyDialogEntryFont]
        $canvasPath.c.f$numPrefs.d configure -bg $bgcolor
        $canvasPath.c.f$numPrefs.d insert 0 $defaultPreferences($prefname)
        $canvasPath.c.f$numPrefs.d config -state disabled
      }

      # user edit value
      entry $canvasPath.c.f$numPrefs.e -relief sunk -bd 2 -width 52 \
          -font [preferred StanleyDialogEntryFont]
      $canvasPath.c.f$numPrefs.e insert 0 "$editValue"
      $canvasPath.c.f$numPrefs.e config -state $entryState 

      if {$mode == "view"} {
        pack $canvasPath.c.f$numPrefs.l $canvasPath.c.f$numPrefs.c \
            $canvasPath.c.f$numPrefs.r $canvasPath.c.f$numPrefs.e \
            -side left -expand 1 -fill x
        set defaultColumnReqWidth 0
      } else {
        pack $canvasPath.c.f$numPrefs.l $canvasPath.c.f$numPrefs.c \
            $canvasPath.c.f$numPrefs.r $canvasPath.c.f$numPrefs.d \
            $canvasPath.c.f$numPrefs.e \
            -side left -expand 1 -fill x
        # set deaultColumnReqWidth [winfo reqwidth $canvasPath.c.f$numPrefs.d] 
        set defaultColumnReqWidth 20
      }
      pack $canvasPath.c.f$numPrefs -side top -fill both -expand 1 -fill x
      $canvasPath.c create window 0 $y -window $canvasPath.c.f$numPrefs \
          -anchor w
      # puts stderr "prefname $prefname width [winfo reqwidth $canvasPath.c.f$numPrefs.l]"
      set yDelta [winfo reqheight $canvasPath.c.f$numPrefs.l]
      set prefEntryWidthNew [expr {[winfo reqwidth $canvasPath.c.f$numPrefs.l] + \
                                       [winfo reqwidth $canvasPath.c.f$numPrefs.c] + \
                                       [winfo reqwidth $canvasPath.c.f$numPrefs.r] + \
                                       $defaultColumnReqWidth + \
                                       [winfo reqwidth $canvasPath.c.f$numPrefs.e] + 2}]
      if {$prefEntryWidthNew > $prefEntryWidth} {
        set prefEntryWidth $prefEntryWidthNew
      }
      # puts stderr "pirEditPreferences: prefEntryWidth $prefEntryWidth"
      set y [expr {$y + $yDelta + 2}]
      if {$numPrefs == 1} {
        # compute standard label widget length in pixels
        set labelRefPixelWidth [list [winfo reqwidth $canvasPath.c.f$numPrefs.l] \
                                    [winfo reqwidth $canvasPath.c.f$numPrefs.c] \
                                    [winfo reqwidth $canvasPath.c.f$numPrefs.r]]
      } elseif {[regexp -nocase "font" $prefname]} {
        set widgetList [list $canvasPath.c.f$numPrefs.l \
                            $canvasPath.c.f$numPrefs.c \
                            $canvasPath.c.f$numPrefs.r]
        for {set j 0} {$j < [llength $widgetList]} {incr j} {
          set initPixelWidth [winfo reqwidth [lindex $widgetList $j]]
          set charPixelWidth [expr {"$initPixelWidth.0" / \
                                        [lindex $labelWidthList $j]}]
          # puts stderr "    charPixelWidth $charPixelWidth"
          # puts stderr "    initPixelWidth $initPixelWidth"
          set newLabelCharWidth [expr {round( [lindex $labelWidthList $j] + \
                                                 ([lindex $labelRefPixelWidth $j] - \
                                                      $initPixelWidth) / \
                                                  $charPixelWidth)}]
          if {($j == 0) && [expr {$charPixelWidth < 7.0}]} {
            incr newLabelCharWidth
          }
          # puts stderr "  newLabelCharWidth $newLabelCharWidth"
          [lindex $widgetList $j] configure -width $newLabelCharWidth
        }
      }
    }
  }
  # set size of widget
  $canvasPath.c config -width $prefEntryWidth
  # set size of scrolling
  set scrollWidth $prefEntryWidth
  if {$mode != "view"} {
    set scrollWidth [expr {$prefEntryWidth + \
                               [winfo reqwidth $canvasPath.c.f$numPrefs.d]}]
  }
  $canvasPath.c config -scrollregion [list 0 0 $scrollWidth $y] 

  # bottom buttons
  frame $w.bot -bd 2 -bg $bgcolor
  pack $w.bot -side top -fill x
  if {($mode == "view") || ($buttonState == "disabled")} {
    button $w.bot.cancel -text DISMISS -relief raised -command "destroy $w" 
    balloonhelp $w.bot.cancel -side right "dismiss"
    pack $w.bot.cancel -side left -padx 5m -ipadx 2m -expand 1
  } else {
    set prefNamesAndOldValues [list [list $dialogPrefNames $oldPrefValues]]
    button $w.bot.ok -text OK -relief raised \
        -command "pirEditPrefsOK $w ok $startupP $mode $prefNamesAndOldValues"
    if {$mode == "user"} {
      set balloonStrSuffix "user's home directory"
    } else {
      set balloonStrSuffix "workspace [preferred projectId] directory"
    }
    balloonhelp $w.bot.ok -side right \
        "apply these $modeLabel preferences and \nsave to $balloonStrSuffix"

    set noKillP 1
    button $w.bot.apply -text APPLY -relief raised \
        -command "pirEditPrefsOK $w apply $startupP $mode $prefNamesAndOldValues $noKillP" 
    balloonhelp $w.bot.apply -side right "apply these $modeLabel preferences"

    # do not know why I used the next line -- it does not work for <unspecified> defaults
    # set cmd "pirPreferencesInit; pirEditPrefsOK $w defaults $startupP $mode {} $noKillP"
    button $w.bot.defaults -text DEFAULTS -relief raised \
        -command "pirApplyDefaultPreferences $mode" 
    balloonhelp $w.bot.defaults -side right \
        "restore\n$modeLabel preferences"

    set cmd "pirLoadPreferences; pirEditPrefsOK $w cancel $startupP $mode"
    button $w.bot.cancel -text CANCEL -relief raised -command $cmd
    balloonhelp $w.bot.cancel -side right \
        "restore saved L2Tools/User/Workspace \npreferences and exit"
    pack $w.bot.ok $w.bot.apply $w.bot.defaults $w.bot.cancel \
        -side left -padx 5m -ipadx 2m -expand 1
  }

  if {! $startupP} {
    keepDialogOnScreen $w $xPos $yPos
  } else {
    wm geometry $w +0+0
  }
}


## apply l2tools default preferences, while preserving users STANLEY_USER_DIR value
## 19aug00 wmt
proc pirApplyDefaultPreferences { mode } {
  global pirPreferences userPreferences workspacePreferences
  global L2TOOLS_ROOT l2toolsPreferences 

  if {$mode == "user"} {
    catch { unset userPreferences }
    set userPreferences(0) 1
    set arrayInitList [array get l2toolsPreferences]
    array set userPreferences $arrayInitList 
    set userPreferences(STANLEY_USER_DIR) [preferred STANLEY_USER_DIR] 
    set userPreferences(projectId) [preferred projectId]
  } elseif {$mode == "workspace"} {
    catch { unset workspacePreferences }
    set workspacePreferences(0) 1
    set arrayInitList [array get l2toolsPreferences]
    array set workspacePreferences $arrayInitList 
  } else {
    error "pirApplyDefaultPreferences: mode $mode not handled"
  }
  pirEditPreferences preferences $mode 
}


## 12jan97 wmt: adapt to g_NM_editablePrefNames
## 02mar98 wmt: apply color pref changes
## 09oct98 wmt: pirPreferences is now an array, rather than an assoc list
proc pirEditPrefsOK { w userCmd startupP mode {prefNamesAndOldValues ""} {noKillP 0} } {
  global pirPreferences g_NM_schematicMode pirNodes pirEdges
  global g_NM_instanceToNode pirNode g_NM_canvasRootIdCnt
  global pirNode pirEdge g_NM_canvasList pirDisplay pirFileInfo
  global g_NM_inhibitPirWarningP g_NM_processingFileOpenP
  global g_NM_editablePrefNames g_NM_editablePrefDescriptions
  global g_NM_showNodeLegendBarP STANLEY_ROOT 
  global g_NM_editPrefsRootWindow g_NM_L2SearchMethods
  global g_NM_minL2MaxCBFSCandidateClasses g_NM_maxL2MaxCBFSCandidateClasses 
  global g_NM_minL2MaxCBFSCandidates g_NM_maxL2MaxCBFSCandidates 
  global g_NM_minL2MaxCBFSSearchSpace g_NM_maxL2MaxCBFSSearchSpace
  global g_NM_minL2MaxHistorySteps g_NM_maxL2MaxHistorySteps
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_minL2MaxCoverCandidateRank g_NM_maxL2MaxCoverCandidateRank
  global g_NM_vmplTestModeP g_NM_L2ProgressCmdTypeList
  global g_NM_toolsL2ViewerP userPreferences g_NM_win32P
  global workspacePreferences defaultPreferences 
  global g_NM_L2minTrajectoriesTracked g_NM_L2maxTrajectoriesTracked 
  global g_NM_minL2MaxCBFSCutoffWeight g_NM_maxL2MaxCBFSCutoffWeight
  global g_NM_L2FindCandidatesCmdTypeList g_NM_freshCommandLineP 

  # determine default preferences
  pirDefaultPreferences $mode

  set reportNotFoundP 0; set oldvalMustExistP 0
  set stanleyPrefsChangeP 0
  set currentL2SearchMethod [preferred L2SearchMethod]
  set currentL2MaxCBFSCandidateClasses [preferred L2MaxCBFSCandidateClasses]
  set currentL2MaxCBFSCandidates [preferred L2MaxCBFSCandidates]
  set currentL2MaxCBFSSearchSpace [preferred L2MaxCBFSSearchSpace]
  set currentL2MaxCBFSCutoffWeight [preferred L2MaxCBFSCutoffWeight]
  set currentL2MaxCoverCandidateRank [preferred L2MaxCoverCandidateRank]
  set currentL2MaxHistorySteps [preferred L2MaxHistorySteps]
  set currentL2NumTrajectoriesTracked [preferred L2NumTrajectoriesTracked]
  set currentL2ProgressCmdType [preferred L2ProgressCmdType]
  set currentL2FindCandidatesCmdType [preferred L2FindCandidatesCmdType]
  set dialogPrefNames [lindex $prefNamesAndOldValues 0]
  set oldPrefValues [lindex $prefNamesAndOldValues 1]
  set i 0
  foreach prefname $dialogPrefNames oldPrefvalue $oldPrefValues {
    # set prefname [lindex [$w.f.c.f[expr 1 + $i].l config -text] 4]
    set prefvalue [$w.f.c.f[expr {1 + $i}].e get]
    # puts stderr "i $i prefname $prefname prefvalue `$prefvalue'"
    if {$prefvalue != ""} {
      # user entered a value
      set indx [lsearch -exact $g_NM_editablePrefNames $prefname]
      set prefDescrip [string trim [lindex $g_NM_editablePrefDescriptions $i] "\""]
      if {[regexp "Color" $prefname]} {
        # validate color name
        if [catch {winfo rgb $g_NM_editPrefsRootWindow $prefvalue} result] {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$prefDescrip':\n$prefvalue is not a valid color name" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        } 
      } elseif {[string match $prefname PV_defaultLogDir]} {
        # validate path
        if {! [file exists $prefvalue]} {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$prefDescrip':\n$prefvalue is not a valid pathname" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname StanleyShowNodeLegendBarP]} {
        if {($prefvalue != 0) && ($prefvalue != 1)} {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$prefDescrip':\nvalues may only be 0 or 1" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname StanleyEliminateUnreferencedJmplVars]} {
        if {($prefvalue != "on") && ($prefvalue != "off")} {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$prefDescrip':\nvalues may only be on or off" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname StanleyTestPermanentBalloons]} {
        if {($prefvalue != "on") && ($prefvalue != "off")} {
          set dialogList [list tk_dialog .d "ERROR" \
                              "`$prefDescrip':\nvalues may only be on or off" \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2SearchMethod]} {
        if {[lsearch -exact $g_NM_L2SearchMethods $prefvalue] == -1} {
          set str "`$prefDescrip':\nvalue may only be one of "
          append str $g_NM_L2SearchMethods
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2MaxCBFSCandidateClasses]} {
        if {($prefvalue < $g_NM_minL2MaxCBFSCandidateClasses) || \
                ($prefvalue > $g_NM_maxL2MaxCBFSCandidateClasses)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_minL2MaxCBFSCandidateClasses to "
          append str "$g_NM_maxL2MaxCBFSCandidateClasses"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2MaxCBFSCandidates]} {
        if {($prefvalue < $g_NM_minL2MaxCBFSCandidates) || \
                ($prefvalue > $g_NM_maxL2MaxCBFSCandidates)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_minL2MaxCBFSCandidates to $g_NM_maxL2MaxCBFSCandidates"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2MaxCBFSSearchSpace]} {
        if {($prefvalue < $g_NM_minL2MaxCBFSSearchSpace) || \
                ($prefvalue > $g_NM_maxL2MaxCBFSSearchSpace)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_minL2MaxCBFSSearchSpace to $g_NM_maxL2MaxCBFSSearchSpace"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2MaxHistorySteps]} {
        if {($prefvalue < $g_NM_minL2MaxHistorySteps) || \
                ($prefvalue > $g_NM_maxL2MaxHistorySteps)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_minL2MaxHistorySteps to $g_NM_maxL2MaxHistorySteps"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
      } elseif {[string match $prefname L2ProgressCmdType]} {
        if {[lsearch -exact $g_NM_L2ProgressCmdTypeList $prefvalue] == -1} {
          set str "`$prefDescrip':\nvalue must be one of: $g_NM_L2ProgressCmdTypeList"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }        
      } elseif {[string match $prefname L2NumTrajectoriesTracked]} {
        if {($prefvalue < $g_NM_L2minTrajectoriesTracked) || \
                ($prefvalue > $g_NM_L2maxTrajectoriesTracked)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_L2minTrajectoriesTracked to $g_NM_L2maxTrajectoriesTracked"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }        
      } elseif {[string match $prefname L2MaxCBFSCutoffWeight]} {
        if {($prefvalue < $g_NM_minL2MaxCBFSCutoffWeight) || \
                ($prefvalue > $g_NM_maxL2MaxCBFSCutoffWeight)} {
          set str "`$prefDescrip':\nvalue must be in the range of: "
          append str "$g_NM_minL2MaxCBFSCutoffWeight to $g_NM_maxL2MaxCBFSCutoffWeight"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }        
      } elseif {[string match $prefname L2FindCandidatesCmdType]} {
        if {[lsearch -exact $g_NM_L2FindCandidatesCmdTypeList $prefvalue] == -1} {
          set str "`$prefDescrip':\nvalue must be one of: $g_NM_L2FindCandidatesCmdTypeList"
          set dialogList [list tk_dialog .d "ERROR" $str \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }        
      }
    } else {
      # in case user blanked out a user or workspace value
      set prefvalue ""
    }
    
    # puts stderr "i $i prefname $prefname prefvalue `$prefvalue' oldPrefvalue `$oldPrefvalue'"
    if {(! [string match $prefvalue $oldPrefvalue]) && \
            ([string range $prefname 0 6] == "Stanley")} {
      set stanleyPrefsChangeP 1
    }

    if {$mode == "user"} {
      if {$prefvalue != ""} {
        set userPreferences($prefname) $prefvalue
      } else {
        # in case value was previously set 
        catch { unset userPreferences($prefname) }
      }
    } elseif {$mode == "workspace"} {
      if {$prefvalue != ""} {
        set workspacePreferences($prefname) $prefvalue
      } else {
        # in case value was previously set 
        catch { unset workspacePreferences($prefname) }
      }
    } else {
      error "pirEditPrefsOK: mode $mode not handled"
    }
    incr i
  }
  # update current prefs
  pirLoadPreferences

  if {! $noKillP} {
    # force balloon help to be hidden
    event generate $w.bot.cancel <Leave>
    event generate $w.bot.ok <Leave>
    if {! $startupP} {
      destroy $w
    }
  }
  # ensure that window is destroyed before pirWarning (below)
  # is invoked, to prevent canvasEnter binding from turning off pirWarning
  update
  if {(! $startupP) && $stanleyPrefsChangeP} {
    # do not update other preferences if this is startup
    # we only want STANLEY_USER_DIR & projectId to get set
    applyPreferenceChanges
  }

  set newL2EngineP 0
  if {(! $startupP) && \
          ((! [string match $currentL2SearchMethod \
                   [preferred L2SearchMethod]]) || \
               (($currentL2SearchMethod == "cover") && \
                    (! [string match $currentL2MaxCoverCandidateRank \
                            [preferred L2MaxCoverCandidateRank]])) || \
               (($currentL2SearchMethod == "cbfs") && \
                    (! [string match $currentL2MaxCBFSCandidateClasses \
                            [preferred L2MaxCBFSCandidateClasses]]) || \
                    (! [string match $currentL2MaxCBFSCandidates \
                            [preferred L2MaxCBFSCandidates]]) || \
                    (! [string match $currentL2MaxCBFSSearchSpace \
                            [preferred L2MaxCBFSSearchSpace]]) || \
                    (! [string match $currentL2MaxCBFSCutoffWeight \
                       [preferred L2MaxCBFSCutoffWeight]])) || \
               (! [string match $currentL2MaxHistorySteps \
                       [preferred L2MaxHistorySteps]]) || \
               (! [string match $currentL2NumTrajectoriesTracked \
                       [preferred L2NumTrajectoriesTracked]]) || \
               (! [string match $currentL2ProgressCmdType \
                       [preferred L2ProgressCmdType]]) || \
               (! [string match $currentL2FindCandidatesCmdType\
                       [preferred L2FindCandidatesCmdType]]))} {
    set newL2EngineP 1
  }
  if {[string match $userCmd "ok"]} {
    pirSavePreferences $mode

    if {$startupP} {
      destroy $w
    }
    if {$newL2EngineP} {
      if {$g_NM_selectedTestScope == "<unspecified>"} {
        if {(! $g_NM_toolsL2ViewerP) && \
                [confirm "Create new L2 engine"]} {
          resetL2toolsJNIandL2
        }
      } else {
        if {[confirm "Create new L2 engine and reload `test'"]} {
          # reset L2/L2Tools and Stanley Test functions
          set overrideP 1
          selectTestScope $g_NM_selectedTestScopeRoot $g_NM_selectedTestScope \
              $overrideP
          # force new engine to be built
          set g_NM_freshCommandLineP 0
          instantiateTestModule 
        } else {
          # write .params file, in case user does a Scenario Mgr RESET
          # rather than a Test->Load & Go
          # generate L2 search params file, which are all the L2* preferences
          writeL2ParamsFile $g_NM_selectedTestScopeRoot $g_NM_selectedTestScope 
        }
      }
    }
  } elseif {[string match $userCmd "apply"]} {
    advisoryDialog $w "Advisory" \
        "L2 engine preferences are not being applied - select `ok' to do so"
    
  } elseif {[string match $userCmd "defaults"]} {
    pirEditPreferences preferences $mode 
  } elseif {[string match $userCmd "cancel"]} {
    destroy $w
  }
}


proc applyPreferenceChanges { } {
  global g_NM_win32P g_NM_inhibitPirWarningP g_NM_processingFileOpenP
  global g_NM_canvasRootIdCnt g_NM_vmplTestModeP g_NM_canvasList
  global g_NM_schematicMode g_NM_showNodeLegendBarP
  global pirNodes pirNode pirDisplay pirFileInfo pirEdges pirEdge
  global g_NM_currentNodeGroup g_NM_instanceToNode
  global g_NM_statePropsRootWindow g_NM_rootInstanceName 

  set reportNotFoundP 0; set modesList {}; set oldvalMustExistP 0
  if {! $g_NM_win32P} {
    .master.canvas config -cursor [list watch red yellow] 
  }
  set severity 1; set msg2 ""
  pirWarning " Please Wait: applying preferences --" $msg2 $severity 
  update
  
  # prevent canvasEnter binding from turning off pirWarning
  set g_NM_inhibitPirWarningP 1
  # prevent deselectNode from calling standardMouseClickMsg, which
  # resets g_NM_inhibitPirWarningP
  set g_NM_processingFileOpenP 1
  # reset option database for widget colors
  resetOptionDatabase

  # mouse selection color
  arepl selectColor [preferred StanleySelectedColor] pirDisplay 

  # update canvases background color
  set rootCanvasList {}
  for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId } {
    lappend rootCanvasList [getCanvasRoot $canvasRootId].canvas.root
  }
  set bgColor [preferred StanleySchematicCanvasBackgroundColor] 
  if {$g_NM_vmplTestModeP} {
    set bgColor [preferred StanleyTestCanvasBackgroundColor]
  }
  foreach canvas [concat $g_NM_canvasList $rootCanvasList] {
    # canvas background color
    $canvas.c config -bg $bgColor 
  } 
  if {[string match $g_NM_schematicMode layout]} {
    set canvasRootId 0
    if {$g_NM_showNodeLegendBarP} {
      # update legend colors 
      resetLayoutLegendColors $canvasRootId
    } 
    # recolor all nodes and reset font

    foreach pirNodeIndex $pirNodes {
      # skip toplevel module root node
      if {! [string match $g_NM_rootInstanceName \
                 [assoc nodeInstanceName pirNode($pirNodeIndex)]]} {
        set window [assoc window pirNode($pirNodeIndex)]
        # check for root parent nodes which have been "destroy"ed
        if {[winfo exists $window]} {
          set nodeStateBgColor [getNodeStateBgColor $pirNodeIndex]
          arepl nodeStateBgColor $nodeStateBgColor pirNode($pirNodeIndex)
          set numInputs [assoc numInputs pirNode($pirNodeIndex)]
          set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
          set window [assoc window pirNode($pirNodeIndex)]
          set pirNodeAlist $pirNode($pirNodeIndex)

          node_color_config $window pirNodeAlist $numInputs $numOutputs
          $window.lab.label configure -font [preferred StanleyComponentLabelFont]
          for {set i 1} {$i <= $numInputs} {incr i} {
            # check for ?name components/modules which have not been saved 
            # and reloaded to create terminal buttons
            if {[winfo exists $window.in.b$i]} {
              $window.in.b$i configure \
                  -fg [preferred StanleyNodeLabelForegroundColor] \
                  -activeforeground [preferred StanleyNodeLabelForegroundColor] 
            }
          }
          for {set i 1} {$i <= $numOutputs} {incr i} {
            # check for ?name components/modules which have not been saved 
            # and reloaded to create terminal buttons
            if {[winfo exists $window.out.b$i]} {
              $window.out.b$i configure \
                  -fg [preferred StanleyNodeLabelForegroundColor] \
                  -activeforeground [preferred StanleyNodeLabelForegroundColor] 
            }
          }
          if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                   mode]} {
            lappend modesList $pirNodeIndex [getCanvasFromWindow $window]
          }
        }
      }
    }
    update; # force pending changes to be applied
    
    # redraw edges in case node label font size changed
    arepl selectedEdges {} pirDisplay $reportNotFoundP $oldvalMustExistP 
    set scm_modified $pirFileInfo(scm_modified)
    foreach pirNodeIndex $pirNodes {
      set window [assoc window pirNode($pirNodeIndex)]
      # check for root parent nodes which have been "destroy"ed
      if {[winfo exists $window]} {
        updateEdgeLocations [getCanvasFromWindow $window] $pirNodeIndex
      }
    }
    if {! $scm_modified} {
      # negate the edgeMove (updateEdgeLocations) setting of mark_scm_modified 
      mark_scm_unmodified
    }
    # recolor modes
    for {set i 0} {$i < [llength $modesList]} {incr i 2} {
      set modeIndex [lindex $modesList $i]
      set canvas [lindex $modesList [expr {1 + $i}]]

      set transitionList [assoc transitions pirNode($modeIndex) $reportNotFoundP]
      foreach transition $transitionList {
        if {[llength $transition] > 4} {
          set lineId [assoc lineId transition]
          set arrowId [assoc arrowId transition]
          if {$lineId != -1} {
            # transition line may not be drawn yet, if this canvas has not
            # been exposed
            if {[lsearch -exact [lindex [$canvas itemconfig $lineId -tags] 4] \
                     "transitionLine"] >= 0} {
              $canvas itemconfig $lineId -fill [preferred StanleyModeTransitionBgColor]
            }
          }
          if {[lsearch -exact [lindex [$canvas itemconfig $arrowId -tags] 4] \
                   "transitionArrow"] >= 0} {
            $canvas  itemconfig $arrowId -fill [preferred StanleyModeTransitionBgColor]
          }
        }
      }
    }
    # recolor edges
    foreach pirEdgeIndex $pirEdges {
      set canvas [getCanvasFromButton [assoc buttonFrom pirEdge($pirEdgeIndex)]]
      arepl fillColor [preferred StanleyNodeConnectionBgColor] pirEdge($pirEdgeIndex)
      edge_color_config $canvas $pirEdgeIndex
    }

  } else {
    set legendPath .master.legend
    set canvasRootId 0
    set nodeInstanceName [lindex [getCanvasRootInfo g_NM_currentNodeGroup \
                                      $canvasRootId] 0]
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_instanceToNode \
                          $reportNotFoundP]
    if {$pirNodeIndex != ""} {
      set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
      for {set canvasRootId 0} {$canvasRootId < $g_NM_canvasRootIdCnt} {incr canvasRootId} {
        set canvasRoot [getCanvasRoot $canvasRootId]
        if {[winfo exists $canvasRoot.legend]} {
          # update legend colors
          if {[string match $nodeClassType module]} {
            changeLegendToModule $canvasRootId
          } else {
            changeLegendToComponent $canvasRootId 
          }
        }
      }
    }
    # recolor all nodes and reset font
    foreach pirNodeIndex $pirNodes {
      # skip toplevel module root node
      if {[llength [assoc nodePropList pirNode($pirNodeIndex) $reportNotFoundP]] != 0} {
        set window [assoc window pirNode($pirNodeIndex)]
        # check for root parent nodes which have been "destroy"ed
        if {[winfo exists $window]} {
          set numInputs [assoc numInputs pirNode($pirNodeIndex)]
          set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
          set nodeStateBgColor [getNodeStateBgColor $pirNodeIndex]
          arepl nodeStateBgColor $nodeStateBgColor pirNode($pirNodeIndex)
          node_config_all $window $pirNodeIndex $numInputs $numOutputs both
          if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                   mode]} {
            lappend modesList $pirNodeIndex [getCanvasFromWindow $window]
          }
        }
      }
    }
    update; # force pending changes to be applied

    # redraw edges in case node label font size changed
    arepl selectedEdges {} pirDisplay $reportNotFoundP $oldvalMustExistP 
    set scm_modified $pirFileInfo(scm_modified)
    foreach pirNodeIndex $pirNodes {
      set window [assoc window pirNode($pirNodeIndex)]
      # check for root parent nodes which have been "destroy"ed
      if {[winfo exists $window]} {
        updateEdgeLocationsAll [getCanvasFromWindow $window] $pirNodeIndex
      }
    }
    if {! $scm_modified} {
      # negate the edgeMove (updateEdgeLocationsAll) setting of mark_scm_modified 
      mark_scm_unmodified
    }

    # recolor modes
    for {set i 0} {$i < [llength $modesList]} {incr i 2} {
      set modeIndex [lindex $modesList $i]
      set canvas [lindex $modesList [expr {1 + $i}]]
      set transitionList [assoc transitions pirNode($modeIndex) $reportNotFoundP]
      foreach transition $transitionList {
        if {[llength $transition] > 4} {
          # puts stderr " pirEditPrefsOK: transition $transition"
          transition_color_config_all $canvas [assoc lineId transition] \
              [assoc arrowId transition] 
        }
      }
    }
    # recolor edges 
    foreach pirEdgeIndex $pirEdges {
      set canvas [getCanvasFromButton [assoc buttonFrom pirEdge($pirEdgeIndex)]]
      set fillColor [preferred StanleyNodeConnectionBgColor]
      if {! [string match [assoc propSelectedP pirEdge($pirEdgeIndex) \
                               $reportNotFoundP] ""]} {
        set fillColor [preferred NM_propsTerminalConnectionColor]
      }
      arepl fillColor $fillColor pirEdge($pirEdgeIndex)
      edge_color_config_all $canvas $pirEdgeIndex
    }
  }
  # update all active state viewer windows
  if {[winfo exists $g_NM_statePropsRootWindow]} {
    updateStateViewerWindows
  }
  # get all events with pirWarning calls processed prior to zeroing flag
  update
  set g_NM_inhibitPirWarningP 0; set g_NM_processingFileOpenP 0
  standardMouseClickMsg
  displayDotWindowTitle 
  if {! $g_NM_win32P} {
    .master.canvas config -cursor top_left_arrow 
  }
  update
}


## color preferences
## 03mar98 wmt: not used
proc pirColorPreferences {{w .colors}} {
  global pirTempfield pirTempcolor tk_version
  set select_flag [expr {($tk_version < 4.0) ? "selector" : "selectcolor"}]
  catch {destroy $w}
  toplevel $w
  wm title $w "Color Preferences"
  wm minsize $w 320 0
  message $w.m1 -text "Select a Preference Item and a Color for the Option" \
   -width 300 -fg [preferred labelForegroundColor]
  pack $w.m1 -side top
  frame $w.fieldframe -relief raised
  pack $w.fieldframe -side top -fill x -pady 10
  foreach f { \
                  StanleyMenuDialogBackgroundColor  \
                  StanleyDialogButtonColor  \
                  edgeColor  \
                  StanleyModuleNodeBgColor  \
                  StanleySelectedColor  \
                  multiButtonColor \
                  nodeCompleteColor \
                  StanleyNodeConnectionBgColor \
                  StanleySchematicCanvasBackgroundColor \
                  StanleyTestCanvasBackgroundColor \
                  buttonBackgroundColor \
                  labelBackgroundColor \
                  titleTextColor \
                  labelForegroundColor} {
     radiobutton $w.fieldframe.$f -text $f -variable pirTempfield \
          -value $f -anchor w \
          -relief flat -$select_flag black
     pack $w.fieldframe.$f -side top -fill x
  }
  frame $w.colframe -relief raised
  pack $w.colframe -side top -fill x -pady 5
  foreach c { \
    red green blue pink yellow gold turquoise maroon coral white black \
    LavenderBlush1 burlywood1 LawnGreen LightPink LightYellow1 LightBlue} {
     frame $w.colframe.f$c -relief flat
     radiobutton $w.colframe.f$c.a -text $c -variable pirTempcolor \
       -value $c -anchor w \
       -$select_flag $c -relief flat
     frame $w.colframe.f$c.b -width 15 -height 5 -relief raised -bg $c
     pack $w.colframe.f$c.a $w.colframe.f$c.b -side left -fill x -padx 5 
     pack $w.colframe.f$c -side top -fill x -padx 20
  }
  # bottom buttons
  frame $w.bot -bd 2
  pack $w.bot -side top -fill x
  button $w.bot.ok -text OK -relief raised \
     -command "pirColorPrefsOK $mode $w"
  button $w.bot.cancel -text CANCEL -relief raised \
     -command "destroy $w"
  pack $w.bot.ok $w.bot.cancel \
     -side left -padx 5m -pady 2m -ipadx 2m -ipady 2m -expand 1
}


## 09oct98 wmt: pirPreferences is now an array, rather than an assoc list
## not used
proc pirColorPrefsOK {w} {
  global pirTempfield pirTempcolor pirPreferences

  set pirPreferences($pirTempfield) $pirTempcolor 
  destroy $w
  pirSavePreferences 
}


## use option database to pass color preferences to widgets
## 19may98 wmt: new
proc resetOptionDatabase { } {

  option clear
  ## override fp 100dpi fonts from .xinitrc
  option add *font [preferred StanleyDefaultFont]
  # Button class
  option add *Button.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Button.activeForeground [preferred StanleyMenuDialogForegroundColor]
  option add *Button.background [preferred StanleyDialogButtonColor]
  option add *Button.activeBackground [preferred StanleySelectedColor]
  # Canvas class
  # for tk_getOpenFile
  option add *Canvas.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Canvas.background [preferred StanleyMenuDialogBackgroundColor]  
  # Checkbutton class
  option add *Checkbutton.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Checkbutton.activeForeground [preferred StanleyMenuDialogForegroundColor]
  option add *Checkbutton.background [preferred StanleyMenuDialogBackgroundColor ]
  option add *Checkbutton.activeBackground [preferred StanleyMenuDialogBackgroundColor]
  # Dialog class
  # see dialog.tcl
  option add *Dialog.msg.wrapLength 20i 
  option add *Dialog.msg.font [preferred StanleyDialogEntryFont]
  # Entry class
  option add *Entry.foreground [preferred StanleyDialogEntryForegroundColor]
  option add *Entry.selectForeground [preferred StanleyDialogEntryForegroundColor]
  option add *Entry.background [preferred StanleyDialogEntryBackgroundColor]
  option add *Entry.selectBackground [preferred StanleySelectedColor]
  # Frame class
  option add *Frame.background [preferred StanleyMenuDialogBackgroundColor]
  # Label class 
  option add *Label.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Label.background [preferred StanleyMenuDialogBackgroundColor ]
  # no wrapping
  option add *Label.wrapLength 0
  # Listbox class
  option add *Listbox.foreground [preferred StanleyDialogEntryForegroundColor]
  option add *Listbox.selectForeground [preferred StanleyDialogEntryForegroundColor]
  option add *Listbox.background [preferred StanleyDialogEntryBackgroundColor]
  option add *Listbox.selectBackground [preferred StanleySelectedColor]
  # Menu class
  option add *Menu.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Menu.activeForeground [preferred StanleyMenuDialogForegroundColor]
  option add *Menu.background [preferred StanleyMenuDialogBackgroundColor ]
  option add *Menu.activeBackground [preferred StanleySelectedColor]
  # Menubutton class
  option add *Menubutton.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Menubutton.activeForeground [preferred StanleyMenuDialogForegroundColor]
  option add *Menubutton.background [preferred StanleyMenuDialogBackgroundColor]
  option add *Menubutton.activeBackground [preferred StanleyMenuDialogBackgroundColor]
  # Message class
  option add *Message.foreground [preferred StanleyMenuDialogForegroundColor]
  option add *Message.background [preferred StanleyMenuDialogBackgroundColor ]
  # Scrollbar Class
  option add *Scrollbar.background [preferred StanleyScrollBarColor]
  option add *Scrollbar.activeBackground [preferred StanleySelectedColor]
  option add *Scrollbar.troughColor [preferred StanleyScrollBarTroughColor]
  # Text class
  option add *Text.foreground [preferred StanleyDialogEntryForegroundColor]
  option add *Text.selectForeground [preferred StanleyDialogEntryForegroundColor]
  option add *Text.background [preferred StanleyDialogEntryBackgroundColor]
  option add *Text.selectBackground [preferred StanleySelectedColor]
  # special for stack trace
  option add *bgerrorTrace.text.foreground black
  option add *bgerrorTrace.text.background gray60
}


## editor for display state color prefs
## 12jan01 wmt: new
proc pirEditDisplayStateColorPrefs { } {
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset env 
  global g_NM_editDSColorPrefsRootWindow g_NM_colorPrefsList
  global STANLEY_SUPERUSER g_NM_STANLEY_USER_DIR_default
  global g_NM_stateColorList g_NM_stateIndirectColorList 

  set colorPrefsList $g_NM_colorPrefsList
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  set w $g_NM_editDSColorPrefsRootWindow 
  set xPos -1; set yPos -1
  if {[winfo exists $w]} {
    set xPos [expr {[winfo rootx $w] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $w] - $g_NM_yWindowMgrOffset}]
    destroy $w
  }
  set operation "Edit"
  set state normal
  set legendPhrase "will be saved"
  set exitButtonLabel "CANCEL"
  if {(! [string match $env(LOGNAME) $STANLEY_SUPERUSER]) && \
          [string match [lindex [preferred STANLEY_USER_DIR] 0] \
               $g_NM_STANLEY_USER_DIR_default]} {
    set operation "View"
    set state disabled
    set legendPhrase "are"
    set exitButtonLabel "DISMISS"
  }
  set path "[lindex [preferred STANLEY_USER_DIR] 0]/display-state-color-prefs"
  # puts stderr "\npirEditDisplayStateColorPrefs: colorPrefsList $colorPrefsList"
  set canvasWindowHeight 400
  toplevel $w -class Dialog
  wm title $w "$operation Display State Color Prefs"
  wm group $w [winfo toplevel [winfo parent $w]]
  frame $w.text&button -bd 0 -bg $bgcolor
  frame $w.text&button.f -bd 2 -relief ridge -bg $bgcolor 
  set text "The workspace preferences $legendPhrase in file \n'$path'."
  append text "\n `$g_NM_stateColorList' colors are changed with"
  append text "\n Edit->Preferences->L2Tools/User/Workspace"
  message $w.text&button.m -text $text \
      -aspect 1000 -bg $bgcolor -font [preferred StanleyDefaultFont] -justify center \
      -foreground [preferred StanleyMenuDialogForegroundColor] 
  pack $w.text&button.m -side top -fill both -expand 1

  set canvasPath $w.text&button.f
  canvas $canvasPath.c -height $canvasWindowHeight -scrollregion [list 0 0 200 2000] \
      -yscrollcommand "$canvasPath.yscroll set" -bg $bgcolor 
  scrollbar $canvasPath.yscroll -command "$canvasPath.c yview" \
      -relief sunk -bd 2 
  pack $canvasPath.yscroll -side right -fill y
  pack $canvasPath.c -side left -fill both -expand 1 

  set mode "edit"
  if {$colorPrefsList == ""} {
    # prefix entries with non-editable noData & indeterminate entries
    for {set i 0} {$i < [llength $g_NM_stateIndirectColorList]} {incr i 2} {
      lappend colorPrefsList [list [lindex $g_NM_stateIndirectColorList $i] \
                                  [preferred [lindex $g_NM_stateIndirectColorList \
                                                  [expr {$i + 1}]]]]
    }
    set mode "view"
    set fid [open $path r]
    while {[set lineLength [gets $fid line]] >= 0} {
      # skip blank lines
      if {$lineLength > 0} {
        set pair [split $line " "]
        set prefName [lindex $pair 0]
        # no-data => noData
        if {[regexp -- - $prefName]} {
          set prefName [fixIdentifierSyntax $prefName]
        }
        # ignore noData & indeterminate if present
        if {[lsearch -exact $g_NM_stateColorList $prefName] == -1} {
          lappend colorPrefsList $pair
        }
      }
    }
    close $fid
  } else {
    set numPrefs 1
    set canvasPath $w.text&button.f
    # clear out existing prefname/prefvalues
    while {[winfo exist $canvasPath.c.f$numPrefs]} {
      destroy $canvasPath.c.f$numPrefs
      incr numPrefs
    }
  }
  # add an editable line at the bottom to allow new entry
  lappend colorPrefsList [list "" ""]

  set numPrefs 0; set y 20
  set dialogPrefNames {}; set prefEntryWidth 0
  set editTextCharWidth 25
  set labelTextCharWidth 25; set labelColorCharWidth 6
  set labelWidthList [list $labelTextCharWidth $labelColorCharWidth]
  set labelFont [preferred StanleyDefaultFont]
  set labelBgColor $bgcolor
  set labelColorBgColor $bgcolor
  set highlightColor $bgcolor
  set maxIndexReservedPrefs [expr {[llength $g_NM_stateColorList] - 1}]
  foreach pair $colorPrefsList { 
    set prefname [lindex $pair 0]
    lappend dialogPrefNames $prefname
    set prefvalue [lindex $pair 1]
    if {$numPrefs <= $maxIndexReservedPrefs} {
      # do not allow editing (removing/changing) of noData & unknown
      set labelState disabled
      set colorState disabled 
    } else {
      set labelState $state
      set colorState $state
    }
    incr numPrefs
    frame $canvasPath.c.f$numPrefs -relief flat \
        -highlightthickness 1 -highlightcolor black -highlightbackground black

    # user edit label - allow entry to be removed, as long as value is "" too
    entry $canvasPath.c.f$numPrefs.l -relief sunk -bd 2 -width $labelTextCharWidth \
        -font $labelFont 
    $canvasPath.c.f$numPrefs.l insert 0 "$prefname"
    $canvasPath.c.f$numPrefs.l config -state $labelState 

    # put in a color rectangle
    if {$prefvalue == ""} {
      set labelColorBgColor white
      set text "n/a"
    } else {
      set labelColorBgColor $prefvalue
      set text ""
    }
    set highlightColor black
    label $canvasPath.c.f$numPrefs.c \
        -bg $labelColorBgColor -font $labelFont -width $labelColorCharWidth \
        -text $text -highlightthickness 1 -highlightcolor $highlightColor \
        -highlightbackground $highlightColor -state disabled

    # user edit value
    entry $canvasPath.c.f$numPrefs.e -relief sunk -bd 2 -width $editTextCharWidth \
        -font $labelFont 
    $canvasPath.c.f$numPrefs.e insert 0 "$prefvalue"
    $canvasPath.c.f$numPrefs.e config -state $colorState 

    pack $canvasPath.c.f$numPrefs.l $canvasPath.c.f$numPrefs.c \
        $canvasPath.c.f$numPrefs.e -side left -expand 1 -fill x
    set defaultColumnReqWidth 0
    # set deaultColumnReqWidth [winfo reqwidth $canvasPath.c.f$numPrefs.d] 
    # set defaultColumnReqWidth 15
   
    pack $canvasPath.c.f$numPrefs -side top -expand 1 -fill x
    $canvasPath.c create window 0 $y -window $canvasPath.c.f$numPrefs \
        -anchor w
    # puts stderr "prefname $prefname width [winfo reqwidth $canvasPath.c.f$numPrefs.l]"
    set yDelta [winfo reqheight $canvasPath.c.f$numPrefs.l]
    set prefEntryWidthNew [expr {[winfo reqwidth $canvasPath.c.f$numPrefs.l] + \
                                     [winfo reqwidth $canvasPath.c.f$numPrefs.c] + \
                                     $defaultColumnReqWidth + \
                                     [winfo reqwidth $canvasPath.c.f$numPrefs.e] + 2}]
    if {$prefEntryWidthNew > $prefEntryWidth} {
      set prefEntryWidth $prefEntryWidthNew
    }
    # puts stderr "pirEditDisplayStateColorPrefs: prefEntryWidth $prefEntryWidth"
    set y [expr {$y + $yDelta + 2}]
    if {$numPrefs == 1} {
      # compute standard label widget length in pixels
      set labelRefPixelWidth [list [winfo reqwidth $canvasPath.c.f$numPrefs.l] \
                                  [winfo reqwidth $canvasPath.c.f$numPrefs.c]]
    }
  }
  $canvasPath.c config -width $prefEntryWidth

  # bottom buttons
  frame $w.text&button.bot -bd 2 -bg $bgcolor
#  pack $w.text&button.bot -side top -fill x
  button $w.text&button.bot.apply -text APPLY -relief raised -state $state \
      -command "pirEditDisplayStateColorPrefsOK $w apply $numPrefs $path"
  balloonhelp $w.text&button.bot.apply -side right \
      "apply these preferences"

  button $w.text&button.bot.save -text SAVE -relief raised -state $state \
      -command "pirEditDisplayStateColorPrefsOK $w save $numPrefs $path"
  balloonhelp $w.text&button.bot.save -side right \
      "apply these preferences and save to workspace"

  set cmd "destroy $w"
  button $w.text&button.bot.cancel -text $exitButtonLabel -relief raised -command $cmd
  pack $w.text&button.bot.apply $w.text&button.bot.save $w.text&button.bot.cancel \
      -side left -padx 5m -ipadx 2m -expand 1

  pack $w.text&button.bot -side bottom

  pack $canvasPath.c -side top -expand 1
  pack $canvasPath -side top -expand 1
  pack $w.text&button -fill both -expand 1

  if {$mode == "view"} {
    set cancelBalloonMsg "exit"
  } else {
    set cancelBalloonMsg "discard changes and exit"
  }
  balloonhelp $w.text&button.bot.cancel -side right $cancelBalloonMsg 
 
  # reduce scroll region to just include entries
  set canvasHeight [expr {($numPrefs + 1) * ($yDelta + 2)}]
  if {$canvasHeight < $canvasWindowHeight} {
    set canvasHeight $canvasWindowHeight
  }
  set scrollRegion [list 0 0 200 $canvasHeight]
  $canvasPath.c config -scrollregion $scrollRegion 
  keepDialogOnScreen $w $xPos $yPos
}


## apply & save actions for display state color prefs
## 12jan01 wmt: new
proc pirEditDisplayStateColorPrefsOK { w operation numPrefs path } {
  global g_NM_editDSColorPrefsRootWindow
  global g_NM_stateColorList g_NM_colorPrefsList

  set colorPrefsList {}
  for {set i 0} {$i < $numPrefs }  {incr i} {
    if {[winfo exists $w.text&button.f.c.f[expr 1 + $i]]} {
      # use fixIdentifierSyntax in case user entered dash
      set prefname [$w.text&button.f.c.f[expr 1 + $i].l get]
      set prefvalue [$w.text&button.f.c.f[expr {1 + $i}].e get]
      # puts stderr "i $i prefname `$prefname' prefvalue `$prefvalue'"
      if {($prefname == "") && ($prefvalue != "")} {
        set errorMsg "Line #[expr {1 + $i}]: No display state label\n"
        append errorMsg "for color value `$prefvalue'"
        set dialogList [list tk_dialog .d "ERROR" $errorMsg \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      } elseif {($prefname != "") && ($prefvalue == "")} {
        set errorMsg "Line #[expr {1 + $i}]: No color value for\n"
        append errorMsg "display state label `$prefname'"
        set dialogList [list tk_dialog .d "ERROR" $errorMsg \
                            error 0 {DISMISS}]
        eval $dialogList
        return
        
      } elseif {($prefname != "") && ($prefvalue != "")} {
        # user entered a name and color value
        # validate name
        if {! [entryValueErrorCheck \
                   "Line #[expr {1 + $i}]: `$prefname' display state label" \
                   "(javaToken)" $prefname]} {
          return
        }
        # check for duplicate name
        set lineNum 1
        foreach pair $colorPrefsList {
          if {[string match [lindex $pair 0] $prefname]} {
            set errorMsg "Line #[expr {1 + $i}]: Display state label `$prefname',\n"
            append errorMsg "is a duplicate of line #$lineNum"
            set dialogList [list tk_dialog .d "ERROR" $errorMsg \
                                error 0 {DISMISS}]
            eval $dialogList
            return
          }
          incr lineNum 
        }
        # validate color value
        if [catch {winfo rgb $g_NM_editDSColorPrefsRootWindow $prefvalue} result] {
          set errorMsg "Line #[expr {1 + $i}]: For display state label `$prefname',\n"
          append errorMsg "color value `$prefvalue' is not a valid color name"
          set dialogList [list tk_dialog .d "ERROR" $errorMsg \
                              error 0 {DISMISS}]
          eval $dialogList
          return
        }
        lappend colorPrefsList [list $prefname $prefvalue]
      }
      # discard null name/value entries
    }
  }
  if {[lsearch -exact [list apply save] $operation] == -1} {
    puts stderr "pirEditDisplayStateColorPrefsOK: operation $operation not handled"
    return
  }
  # puts stderr "pirEditDisplayStateColorPrefsOK: colorPrefsList $colorPrefsList "
  set g_NM_colorPrefsList $colorPrefsList 
  # filter out reserved colors
  set newColorPrefsList {}
  foreach pair $colorPrefsList {
    if {[lsearch -exact $g_NM_stateColorList [lindex $pair 0]] == -1} {
      lappend newColorPrefsList [list [lindex $pair 0] [lindex $pair 1]]
    }
  }
  # we need to reinit some globals so that initializeDisplayStateBgColors 
  # will not crunch after initialize_graph has been called from fileOpen
  fillPaletteLists
  fillTerminalTypeList
  if {$operation == "apply"} {
    pirEditDisplayStateColorPrefs

    initializeDisplayStateBgColors $newColorPrefsList 
  } elseif {$operation == "save"} {
    set numPrefs 0
    set fid [open $path w]
    foreach pair $newColorPrefsList {
      puts $fid "[lindex $pair 0] [lindex $pair 1]"
    }
    close $fid
    puts stdout "Writing $path\n"
    destroy $w
    update
    initializeDisplayStateBgColors
  }
  # update schematic
  applyPreferenceChanges 
}












