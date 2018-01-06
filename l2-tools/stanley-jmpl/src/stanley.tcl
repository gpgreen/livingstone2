# $Id: stanley.tcl,v 1.2 2006/04/29 00:47:38 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## stanley.tcl

# package require BLT 

# puts stderr "stanley.tcl"
global publicPrivateConvertP
set publicPrivateConvertP 0
# puts stderr "\n\npublicPrivateConvertP is $publicPrivateConvertP\n\n"

global jMplConvertP
set jMplConvertP 0
# puts stderr "\n\njMplConvertP is $jMplConvertP\n\n"

global g_NM_schematicMode calledByWishP 
global g_NM_schematicMode_options 
global g_NM_defvaluesAList 
global g_NM_rootInstanceName tk_version
global g_NM_opsWarningsP DEBUG env
global g_NM_livingstoneDefmoduleName
global g_NM_classTypes g_NM_classDefType 
global g_NM_initializationCompleteP stanleyFilesUpdateDoneP 
global STANLEY_SUPERUSER STANLEY_ROOT auto_path STANLEY_TCL_TK_LIB
global g_NM_instantiatableSchematicExtension 
global g_NM_smartBoardPC g_NM_l2ToolsP g_NM_checkFileDatesP
global g_NM_toolsL2ViewerP 
global g_NM_gpuWorkspaceDir 
global g_NM_gpuSchematicFile 
global g_NM_groundProcessingUnitP
global g_NM_win32P g_NM_profileP 
global g_NM_JVMGcInitSpace g_NM_JVMGcMaxSpace
global g_NM_regenP

set DEBUG 0
set g_NM_schematicMode_options { layout operational }
set NM_allowableInputArgs \
    { g_NM_schematicMode g_NM_opsWorkspacePath \
          g_NM_smartBoardPC g_NM_l2ToolsP \
          g_NM_opsWarningsP g_NM_checkFileDatesP g_NM_toolsL2ExistsP \
          g_NM_toolsL2ViewerP g_NM_gpuWorkspaceDir g_NM_gpuSchematicFile \
          g_NM_groundProcessingUnitP g_NM_win32P g_NM_profileP \
          g_NM_JVMGcInitSpace g_NM_JVMGcMaxSpace g_NM_regenP }

set g_NM_schematicMode ""
set g_NM_opsWorkspacePath ""
set calledByWishP 0
set stanleyFilesUpdateDoneP 0
set g_NM_IPCp 0
set g_NM_opsWarningsP 0
set g_NM_mir_gui_ipcP 0
set g_NM_ipcRecorderFile NIL
set g_NM_initializationCompleteP 0
set g_NM_smartBoardPC 0
set g_NM_l2ToolsP 0
set g_NM_checkFileDatesP 1
set g_NM_toolsL2ExistsP 0
set g_NM_toolsL2ViewerP 0
set g_NM_gpuWorkspaceDir ""
set g_NM_gpuSchematicFile ""
set g_NM_groundProcessingUnitP 0
set g_NM_win32P 0
set g_NM_profileP 0
set g_NM_JVMGcInitSpace 32
set g_NM_JVMGcMaxSpace 192
set g_NM_regenP 0

if {$argc > 0} {
  ## process arguments
  # puts stderr "stanley.tcl argc $argc argv $argv"
  set argi 0
  while {$argc > 0} {
    # puts stderr "stanley.tcl: argi $argi argv [lindex $argv $argi]"
    if {[lsearch -exact $NM_allowableInputArgs [lindex $argv $argi]] >= 0} {
      set [lindex $argv $argi] [lindex $argv [expr {$argi + 1}]]
      puts [format {stanley arg pair: %s %s} [lindex $argv $argi] \
                [lindex $argv [expr {$argi + 1}]]]
    } else {
      puts stderr "\nWARNING: [lindex $argv $argi] is an invalid argument to Stanley\n"
    }
    incr argi 2
    incr argc -2
  }
} else {
  # when called by source stanley.tcl, under wish
  set calledByWishP 1
  set g_NM_schematicMode layout
}

if {[lsearch -exact $g_NM_schematicMode_options $g_NM_schematicMode] < 0} {
  puts stderr [format {WARNING: Invalid value, %s, for g_NM_schematicMode.
    Allowable values are:%s} $g_NM_schematicMode $g_NM_schematicMode_options]
  exit;       # exit tcl
}
## puts [format {stanley g_NM_schematicMode %s, g_NM_opsWorkspacePath %s} \
    ##    $g_NM_schematicMode $g_NM_opsWorkspacePath]

## AUTOPATH setup: include current directory
## NB: if the environment variable STANLEY_ROOT is not set,
##   it assumes that "." (cwd) is also the library directory
set envVarList [list STANLEY_ROOT MICO_LIB TCL_MICO_LIB STANLEY_ITCL_L \
                    PS_CMD STANLEY_BIN_DIR OSTYPE LOGNAME \
                    HOME STANLEY_SUPERUSER SUPPORT_ROOT \
                    STANLEY_ROOT LIVINGSTONE_ROOT L2TOOLS_ROOT \
                    STANLEY_TCL_TK_LIB STANLEY_TK_L \
                    READ_ONLY_DEFS CORBA_DIR JAVA_BIN PATH LD_LIBRARY_PATH]
if {[string match $g_NM_schematicMode "layout"]} {
  # lappend envVarList .....
}
if {[string match $g_NM_schematicMode "operational"]} {
  # lappend envVarList 
}
foreach envVar $envVarList {
  set have_it [expr {[lsearch -exact [array names env] $envVar] >= 0}]
  if {$have_it} {
    global $envVar
    set $envVar $env($envVar)
    ## puts "envVar $envVar [eval {set $envVar}]"
  } else {
    error "Shell environment variable $envVar not set!"
  }
}

# prodebug resets OSTYPE = linux to linux-gnu
if {$OSTYPE == "linux-gnu"} {
  set OSTYPE "linux"
}

# Tcl Profiler
if { $g_NM_profileP} {
  set auto_path \
      [linsert $auto_path 0 /home/wtaylor/pub/tclprofiler]
  package require profiler 0.1
  ::profiler::init

  # in tkcon: ::profiler::print ?pattern?  ::profiler::reset
}

# establish C interface to commands - defined in stanley/c/stanley.c
# mainly Call_CSH
# Call_Emacs is now handled by ORB request evalLivingstoneForm 
AutoSat_Schematic_Tcl_Cmds

# puts stderr "stanley.tcl: LOGNAME $env(LOGNAME) STANLEY_SUPERUSER $STANLEY_SUPERUSER"
if {[string match $env(LOGNAME) $STANLEY_SUPERUSER] || \
        (! [file exists "${STANLEY_ROOT}/src/tclIndex"])} {
  # only build new tclIndex when I am the user
  # or it does not exist
  auto_mkindex $STANLEY_ROOT/src "*.tcl"
  # puts stderr "stanley.tcl: built new tclIndex"
}

set auto_path \
    [linsert $auto_path 0 $STANLEY_ROOT/src]
# puts stderr "stanley.tcl: auto_path $auto_path "

# create global environment 
globalInitialize

# make delete (rubout) key work the same as backspace
# for entry widgets
bind Entry <Delete> "[ bind Entry <Key-BackSpace> ]"
# for text widgets
bind Text <Delete> "[ bind Text <Key-BackSpace> ]"

# allow user to do other Stanley functions while in a dialog
tk_focusFollowsMouse

# Tix preferences - with my preferences
# source $STANLEY_ROOT/src/prefTixGray.csc
# tixPref:SetScheme-Color:TixGray

###################

# create $env(HOME)/.stanley directory, if it does not exist
set stanleyHomeDir $env(HOME)/.stanley
if {[file exists $stanleyHomeDir] && \
        (! [file isdirectory $stanleyHomeDir])} {
  file delete $stanleyHomeDir
}
if {! [file exists $stanleyHomeDir]} {
  file mkdir $stanleyHomeDir
  puts stderr "stanley.tcl: directory $env(HOME)/.stanley created"
}
# put $env(HOME)/.stanley-prefs in $env(HOME)/.stanley/stanley-prefs
# if not there already
# if {[file exists $env(HOME)/.stanley-prefs]} {
#   if {! [file exists $env(HOME)/.stanley/stanley-prefs]} {
#     file rename $env(HOME)/.stanley-prefs $env(HOME)/.stanley/stanley-prefs
#     set str "stanley.tcl: moved $env(HOME)/.stanley-prefs to"
#     puts stderr "$str $env(HOME)/.stanley/stanley-prefs"
#   } else {
#     file delete $env(HOME)/.stanley-prefs
#     puts stderr "stanley.tcl: file $env(HOME)/.stanley-prefs deleted"
#   }
# }

set oldStanleyPrefPath $env(HOME)/.stanley/stanley-prefs
set l2toolsPrefsPath $L2TOOLS_ROOT/preferences/prefDefaults
set userPrefsPath $env(HOME)/.stanley/userPrefs
if {[file exists $oldStanleyPrefPath] && (! [file exists $userPrefsPath])} {
  # copy in first 8 items: STANLEY_USER_DIR projectId & L2* params
  # from $oldStanleyPrefPath 
  set fidIn [open $oldStanleyPrefPath r]
  set fidTools [open $l2toolsPrefsPath r]
  set fidOut [open $userPrefsPath w]
  for {set i 0} {$i < 8} {incr i} {
    gets $fidIn line
    set splitList [split $line "="]
    set prefName [string trim [lindex $splitList 0] " "]
    set prefDefault [string trim [lindex $splitList 1] " "]
    if {$prefName == "STANLEY_USER_DIR"} {
      set pirPreferences(STANLEY_USER_DIR) $prefDefault 
    }
    puts $fidOut $line
  }
  # skip the 6 L2 params - add all the others
  set paramCnt 0
  while {[gets $fidTools line] >= 0} {
    if {([string index $line 0] != "#") && ($line != "")} {
      if {$paramCnt > 5} {
         puts $fidOut $line
      }
      incr paramCnt 
    }
    # puts stderr "$paramCnt $line "
  }
  close $fidIn
  close $fidTools
  close $fidOut 
  puts stdout "Writing $userPrefsPath\n"
  # fill userPreferences array
  pirReadPreferences user
}

if {! [file exists $userPrefsPath]} {
  # create file, if none exists
  # with default STANLEY_USER_DIR projectId
  set fidOut [open $userPrefsPath w]
  puts $fidOut "STANLEY_USER_DIR = $g_NM_STANLEY_USER_DIR_default"
  puts $fidOut "projectId = $g_NM_projectId_default"
  close $fidOut 
  puts stdout "Writing $userPrefsPath\n"
  # fill userPreferences array
  pirReadPreferences user
}

if {[file exists $userPrefsPath]} {
  # make sure STANLEY_USER_DIR & projectId are consistent with defaults
  # l2tools default preferences have been overriden by .stanley/userPrefs 
  set newWorkspaceList {}; set changedP 0
  # puts stderr "STANLEY_USER_DIR [preferred STANLEY_USER_DIR]"
  foreach workspacePath [preferred STANLEY_USER_DIR] {
    set workspaceId [file tail $workspacePath]
    # puts stderr "workspaceId '$workspaceId' g_NM_projectId_default '$g_NM_projectId_default' match [string match $workspaceId $g_NM_projectId_default] "
    # puts stderr "workspacePath '$workspacePath' g_NM_STANLEY_USER_DIR_default '$g_NM_STANLEY_USER_DIR_default' match [string match $workspacePath $g_NM_STANLEY_USER_DIR_default] "
    if {[string match $workspaceId $g_NM_projectId_default] && \
            (! [string match $workspacePath $g_NM_STANLEY_USER_DIR_default])} {
      # could be old sample files with different path
      lappend newWorkspaceList $g_NM_STANLEY_USER_DIR_default
      set changedP 1
    } else {
      lappend newWorkspaceList $workspacePath
    }
  }
  if {[lsearch -exact $newWorkspaceList $g_NM_STANLEY_USER_DIR_default] == -1} {
    # ensure that stanley-sample-user-files is in STANLEY_USER_DIR 
    lappend newWorkspaceList $g_NM_STANLEY_USER_DIR_default
    set changedP 1
  }
  if {$changedP} {
    set pirPreferences(STANLEY_USER_DIR) $newWorkspaceList
    set pirPreferences(projectId) [file tail [lindex $newWorkspaceList 0]]
    set userPreferences(STANLEY_USER_DIR) $newWorkspaceList 
    set userPreferences(projectId) [file tail [lindex $newWorkspaceList 0]]
    # write ~/.stanley/userPrefs
    pirSavePreferences user
  }
}

# if more than 1 path in STANLEY_USER_DIR, ask user to select
# NO - choose the first one in the list, if the user
# wants to change workspaces, they can use "File->Open Workspace" or
# "File->New Workspace"
# l2-tools/stanley-sample-user-files is the default
# puts stderr "stanley.tcl: STANLEY_USER_DIR `[preferred STANLEY_USER_DIR]' len [llength [preferred STANLEY_USER_DIR]]"
set startupP 1
# if {[llength [preferred STANLEY_USER_DIR]] > 1} {
#   set dialogW .selectworkspace
#   catch {destroy $dialogW}
#   set bgcolor [preferred StanleyMenuDialogBackgroundColor]
#   # not a top level window -- just as menu selection 
#   set menu $dialogW
#   menubutton $menu -menu $menu.m -relief flat 
#   set rootMenu [menu $menu.m -tearoff 0]

#   set subMenu $rootMenu.select
#   $rootMenu add cascade -label "Open Workspace" -menu $subMenu 
#   menu $subMenu -tearoff 0 

#   foreach workspacePath [preferred STANLEY_USER_DIR] {
#     set workspaceId [file tail $workspacePath] 
#     set command "openWorkspace $workspacePath $workspaceId $startupP"
#     $subMenu add command -label $workspaceId -command $command 
#   }
#   pack $menu -side top -fill x
#   set x [winfo pointerx .] 
#   set y [winfo pointery .]
#   tk_popup $menu.m [expr {$x + 10}] $y 

#   if [winfo exists $dialogW] {
#     tkwait window $dialogW
#   }
# } else {
#   set workspacePath [preferred STANLEY_USER_DIR] 
#   openWorkspace $workspacePath [file tail $workspacePath] $startupP 
# }

if {[string match $g_NM_schematicMode "layout"]} {
  set workspacePath [lindex [preferred STANLEY_USER_DIR] 0]
  openWorkspace $workspacePath [file tail $workspacePath] $startupP
} elseif {$g_NM_schematicMode == "operational"} {
  if {! [file exists $g_NM_gpuWorkspaceDir]} {
    error "\n\n-gpudir $g_NM_gpuWorkspaceDir does not exist\n\n"
  }
  openWorkspace  $g_NM_gpuWorkspaceDir [file tail $g_NM_gpuWorkspaceDir] \
      $startupP 
} else {
  error " stanley.tcl: g_NM_schematicMode $g_NM_schematicMode not handled"
}

#########################################################

pirSetVersion
set tkAppname [tk appname]

if {[string match $g_NM_schematicMode "operational"]} {
  if {$g_NM_opsWarningsP} {
    set g_NM_propsWarnMsgsP 1
  }
  ## non-recursive instantiation does not handle pending edges
  ## need to have a separate list for each slave window
  ## need to not add to g_NM_recursiveIncludeModulesTree when
  ## processing slave and entry already exists
  set g_NM_recursiveInstantiationP 1

  set schematicFilePath [getSchematicDirectory root module]
  # strip off .scm if specified by user
  set gpuSchematicFile [file rootname $g_NM_gpuSchematicFile]
  append schematicFilePath "/$gpuSchematicFile$pirFileInfo(suffix)"
  if {! [file exists $schematicFilePath]} {
    error "\n\n-gpufile $g_NM_gpuSchematicFile does not exist in $schematicFilePath\n\n"
  }
  selectTestScope module [file rootname $g_NM_gpuSchematicFile]
  instantiateTestModule 
} 

# enable canvasEnter which is bound to  "bind $canvasPath.c <Enter>"
set g_NM_initializationCompleteP 1

set msg "\nReady: "
puts stderr "$msg tk appname => $tkAppname VJMPL \(version [pirGetVersion]\)\n"


#########################################################

