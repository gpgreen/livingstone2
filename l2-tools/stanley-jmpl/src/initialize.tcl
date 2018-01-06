# $Id: initialize.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## initialization for global variables and modal entries
## 08oct95 wmt: add call to NM_globalInitialize
## 13oct95 wmt: add checking for schematicMode
## 01jan95 wmt: change suffix from .prw to .scm (schematic)
## 30apr97 wmt: add pirActiveFamilyName
proc globalInitialize {} {
  global pirFileInfo g_NM_schematicMode pirPreferences 
  global pirActiveFamilyName g_NM_smartBoardPC
  global STANLEY_ROOT g_NM_STANLEY_USER_DIR_default g_NM_projectId_default
  global g_NM_readOnlyWorkspaceList L2TOOLS_ROOT
  global g_NM_l2toolsPrefsP g_NM_editablePrefDescriptions
  global g_NM_editablePrefNames pirPreferences l2toolsPreferences 
  global userPreferences workspacePreferences defaultPreferences 

  # for changes to schematic node locations, & display state attribute
  # which do not require recompilation of .jmpl file
  set pirFileInfo(scm_modified) 0;
  # for mpl code changes that require recompilation of .jmpl file
  set pirFileInfo(jmpl_modified) 0;
  set pirFileInfo(filename) "";
  set pirFileInfo(suffix) ".scm";

  set pirActiveFamilyName ""

  # project == workspace
  # default workspace for user files - needed by pirPreferencesInit
  # get absolute pathname
  set pathname [file nativename "$STANLEY_ROOT/../stanley-sample-user-files"]
  set currentDir [pwd]
  cd $pathname
  set g_NM_STANLEY_USER_DIR_default [pwd]
  cd $currentDir 
  set g_NM_projectId_default stanley-sample-user-files
  set g_NM_readOnlyWorkspaceList { stanley-sample-user-files }

  # check for L2Tools preferences files
  set g_NM_l2toolsPrefsP 0
  set l2toolsPreferences(0) 1
  set userPreferences(0) 1
  set workspacePreferences(0) 1
  set defaultPreferences(0) 1
  if {[file exists $L2TOOLS_ROOT/preferences/prefLabels] && \
          [file exists $L2TOOLS_ROOT/preferences/prefDefaults]} {
    set g_NM_l2toolsPrefsP 1
    puts stderr "Reading $L2TOOLS_ROOT/preferences/prefLabels"
    set fid [open $L2TOOLS_ROOT/preferences/prefLabels r]
    set g_NM_editablePrefDescriptions {}
    while {[gets $fid line] >= 0} {
      if {([string index $line 0] != "#") && ($line != "")} {
        lappend g_NM_editablePrefDescriptions "\"$line\"" 
      }
    } 
    close $fid

    puts stderr "Reading $L2TOOLS_ROOT/preferences/prefDefaults"
    set fid [open $L2TOOLS_ROOT/preferences/prefDefaults r]
    set g_NM_editablePrefNames {}
    while {[gets $fid line] >= 0} {
      if {([string index $line 0] != "#") && ($line != "")} {
        set splitList [split $line "="]
        set prefName [string trim [lindex $splitList 0] " "]
        set prefDefault [string trim [lindex $splitList 1] " "]
        lappend g_NM_editablePrefNames $prefName
        # current l2tools/user/workspace prefs - first step
        set pirPreferences($prefName) $prefDefault
        # l2tools default prefs
        set l2toolsPreferences($prefName) $prefDefault 
      }
    } 
    close $fid

    # puts stderr "g_NM_editablePrefDescriptions: $g_NM_editablePrefDescriptions"
    # puts stderr "g_NM_editablePrefNames $g_NM_editablePrefNames"
    # check that lengths are equal
    if {[llength $g_NM_editablePrefDescriptions] != \
            [llength $g_NM_editablePrefNames]} {
      set dialogList [list tk_dialog .d "ERROR" \
                          "L2Tools preference files have inconsistent lengths:
$L2TOOLS_ROOT/preferences/prefLabels
$L2TOOLS_ROOT/preferences/prefDefaults" \
                          error 0 {DISMISS}]
      eval $dialogList
      exit 
    }
  } else {
    puts stderr "globalInitialize: L2Tools preference files not found"
    puts stderr "    using Stanley defaults, instead."
  }

  pirPreferencesInit;  # establish default preferences
  if {! $g_NM_l2toolsPrefsP} {
    set arrayInitList [array get pirPreferences]
    array set l2toolsPreferences $arrayInitList 
  }
  # override l2tools defaults with user preferences
  pirReadPreferences user

  if {$g_NM_smartBoardPC} {
    # Stanley is being run via telnet from the Smart Board PC
    # override the x/y dimensions of the Stanley window
    set pirPreferences(StanleyInitialCanvasWidth)  950
    set pirPreferences(StanleyInitialCanvasHeight)  540
  }
  # reset option database for widget colors
  resetOptionDatabase
 
  NM_globalInitialize;  # initial globals

  # set gobal vars for beth package -- paren matching for Lisp text widget
  bethInitialize
  if {[string match $g_NM_schematicMode "layout"]} {
    ## modify class Text for Emacs key-bindings
    ## used by  createEmacsTextWidget 
    foreach key [bind Text] {
      bind Text $key {}
    }
    source $STANLEY_ROOT/src/tkbind-text.tcl
    source $STANLEY_ROOT/src/tkbind-bindxtnd.tcl
    source $STANLEY_ROOT/src/tkbind-prompt.tcl
    source $STANLEY_ROOT/src/tkbind-rectangle.tcl
    source $STANLEY_ROOT/src/tkbind-isearch.tcl
  }
  # class bindings for tkTable
  bind Table <Motion> "displayTableCellBalloon %W %x %y"
  bind Table <Leave> "destroyTableCellBalloon"
}
  

## establish a name for this application
## 10feb96 wmt: add g_NM_schematicMode 
proc setApplicationName {ap} {  
  global pirDisplay g_NM_schematicMode

  arepl application $ap pirDisplay
  puts stdout "$g_NM_schematicMode name: $ap"
  return
}


## initial NewMAAP globals
## 08oct95 wmt: new
proc NM_globalInitialize {} {
  global g_NM_l2toolsPrefsP 

  global g_NM_schematicMode 
  global g_NM_icon_width g_NM_icon_height 
  global g_NM_canvasGrid
  global g_NM_powerAvailable g_NM_powerMaxScale g_NM_powerAvailableWidth
  global g_NM_powerAvailableWidgetPaths g_NM_powerAvailableSliderTag
  global g_NM_powerMaxAvailable g_NM_powerAvailableSliderMaxTag
  global g_NM_nodeStateWindowList 
  global g_NM_detailLogP g_NM_mkformNodeCompleteP g_NM_classInstance
  global g_NM_instanceToNode g_NM_componentToNode g_NM_moduleToNode 
  global g_NM_nodeGroupToInstances g_NM_canvasParentNodeIdList
  global g_NM_currentNodeGroup g_NM_parentNodeGroupList g_NM_className
  global g_NM_livingstoneDefmoduleFileName 
  global g_NM_livingstoneDefmoduleName g_NM_edgesOfRedrawNode
  global g_NM_paletteDefcomponentList g_NM_paletteDefspecList
  global g_NM_paletteAbstractionList g_NM_paletteDefrelationList 
  global g_NM_paletteDefmoduleList g_NM_paletteStructureList
  global g_NM_paletteStrucIsTerminalTypeParamList g_NM_paletteDefvalueList 
  global g_NM_paletteTerminalList g_NM_paletteAttributeList
  global g_NM_paletteModeList 
  global g_NM_paletteDefsymbolList g_NM_terminalTypeList g_NM_terminalTypeValuesArray 
  global g_NM_inhibitEdgeTypeMismatchP
  global g_NM_mkEntryWidgetWidth g_NM_defmoduleFilePath
  global g_NM_termtypeRootWindow g_NM_statePropsRootWindow
  global g_NM_nodeTypeRootWindow g_NM_permBalloonRootWindow
  global g_NM_advisoryRootWindow g_NM_editDSColorPrefsRootWindow
  global g_NM_editPrefsRootWindow  g_NM_scenarioNameRootWindow
  global g_NM_scenarioCommentRootWindow 
  global g_NM_jmplCompilerRootWindow g_NM_newWorkspaceRootWindow 
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset g_NM_snapToGridOn 
  global g_NM_terminalNodeWidth g_NM_selectedEdge g_NM_selectedEdgeMovedP 
  global g_NM_defvaluesAList
  global g_NM_highlightedEdgeList g_NM_newEdgeNumList
  global g_NM_processingNodeGroupP 
  global g_NM_currentCanvas g_NM_canvasList g_NM_canvasIdToPirNode
  global g_NM_windowPathToPirNode 
  global g_NM_canvasIdToPirEdge g_NM_classToEdgeInstances
  global g_NM_passedModelModsByClass 
  global g_NM_livingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgTypeList 
  global g_NM_livingstoneDefmoduleNameVar
  global g_NM_maxDefmoduleArgs g_NM_instantiatableSchematicExtension
  global g_NM_generatedMPLExtension 
  global g_NM_dependentFilesExtension g_NM_terminalsFilesExtension
  global g_NM_pirClassComponentTemplate g_NM_pirClassModuleTemplate 
  global g_NM_pirClassASSVTemplate g_NM_mkformNodeUpdatedP 
  global g_NM_mkformModuleDefaultValues g_NM_mkformModuleNumDefaultValues
  global g_NM_mkformComponentDefaultValues g_NM_mkformComponenTNumDefaultValues
  global g_NM_terminalInstance g_NM_stickyTerminalNameInput
  global g_NM_stickyTerminalTypeInput g_NM_terminalDocInput 
  global g_NM_rootInstanceName g_NM_canvasRedrawP 
  global g_NM_fileOperation g_NM_classDefType g_NM_propsWarnMsgsP
  global g_NM_moduleGroupsUpdatedSinceReset
  global g_NM_onboardFileSelectedP g_NM_groundFileSelectedP
  global mirPlayBackMsgNames mirPlayBackMsgCnt tcl_precision
  global groundOnboardTimeDelta g_NM_optMenuWidget g_NM_optMenuWidgetValue
  global g_NM_saveWorkspaceCompactP g_NM_filterPirNodeAttList
  global g_NM_filterRestorePirNodeAttList g_NM_filterPirClassAttList
  global g_NM_includedModules g_NM_dependentClasses g_NM_dependencyErrorList
  global g_NM_groupLevelSave g_NM_pendingPirEdgesList 
  global g_NM_class_variablesAttributeList g_NM_class_variablesModuleAttList
  global g_NM_terminalInputs g_NM_terminalOutputs g_NM_argsVarsTranslations
  global g_NM_classTypes
  global g_NM_classTypesAList 
  global g_NM_paletteTypes g_NM_paletteTypesAList
  global g_NM_structureFormInput g_NM_structureDocInput g_NM_valueDocInput 
  global g_NM_livingstoneDefcomponentName g_NM_livingstoneDefcomponentNameVar
  global g_NM_livingstoneDefcomponentFileName
  global g_NM_livingstoneDefcomponentArgList g_NM_livingstoneDefcomponentArgTypeList 
  global g_NM_maxDefcomponentArgs
  global g_NM_modeDocInput g_NM_modeModelInput g_NM_transitionStartPirIndex
  global g_NM_modeTransitionDocInput g_NM_modeTransitionPreconditionInput
  global g_NM_componentDocInput g_NM_componentBackDocInput
  global g_NM_componentBackModelInput g_NM_componentInitiallyInput
  global g_NM_moduleDocInput g_NM_moduleFactsInput g_NM_edgeDocInput
  global uniqueDialogId_global g_NM_processingFileOpenP g_NM_canvasRootIdCnt
  global g_NM_windowWidthBorder g_NM_windowHeightBorder 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight g_NM_selectedTestScope
  global g_NM_firstInstantiatedScopeP
  global g_NM_recursiveInstantiationP g_NM_recursiveIncludeModulesTree
  global g_NM_dialogTransitionSelection 
  global g_NM_selectedClassType g_NM_selectedClassName
  global g_NM_buttonConnectStartButtonPath g_NM_buttonConnectStopButtonPath
  global g_NM_editablePrefNames g_NM_prefsAppliedAtRestart
  global g_NM_editablePrefDescriptions g_NM_prefsAppliedAtOpsReset 
  global g_NM_recursiveTraceOutputP g_NM_vmplPrefNames
  global g_NM_readOnlyDefsAlist READ_ONLY_DEFS
  global g_NM_modeTransitionEditState g_NM_displayStateType g_NM_defaultDisplayState
  global g_NM_displayStateColorMapping 
  global g_NM_acsModeHealthValues
  global g_NM_acsModeHealthColorMapping g_NM_stateColorList g_NM_stateIndirectColorList 
  global g_NM_colorPrefsList g_NM_notComponentModuleList
  global g_NM_notModuleList g_NM_edgeConnectionFailedList
  global g_NM_edgeConnectionInvalidList 
  global g_NM_menuStem g_NM_acceleratorStem g_NM_inhibitPirWarningP
  global g_NM_componentFaultDialogRoot g_NM_componentFaultIndexList
  global g_NM_componentFaultIndexList_1
  global g_NM_terminalDefsArray g_NM_commandMonitorTypesList
  global g_NM_terminalInterfaceTypesList 
  global g_NM_propValuesColorMap g_NM_propValuesCount g_NM_propValuesArray
  global g_NM_propsTerminalConnectionsSet g_NM_createModuleFileName
  global g_NM_vmplTestModeP g_NM_testInstanceName g_NM_testInstanceNameInternal
  global g_NM_testModuleArgsValues g_NM_stepCommandsMonitors
  global goodPropCnt badPropCnt nextPropCnt unknownPropCnt
  global g_NM_packetTimeTagsList g_NM_groundRefTime g_NM_currentTableWidgetCol
  global g_NM_showModeInstances g_NM_nodeHasIconP g_NM_pendingEdgesOverrideMsgP 
  global g_NM_testScenarioName 
  global g_NM_nodeTypesHaveIcons
  global g_NM_metaDotParentNodeGroupList 
  global g_NM_showIconLabelBalloonsP g_NM_showNodeLegendBarP
  global g_NM_canvasStartMotionP g_NM_testValuesBalloons 
  global g_NM_jmplLintExtenstion g_NM_jmplCompilerExtension g_NM_scenarioExtension
  global g_NM_scenarioDebugExtension 
  global g_NM_cmdMonExtension g_NM_jmplInitExtension
  global g_NM_paramsExtension g_NM_jmplCompilerOptExtension 
  global g_NM_commandMonitorConstraints g_NM_allCommandMonitorForms 
  global g_NM_L2SearchMethods g_NM_minL2MaxCBFSCandidates g_NM_maxL2MaxCBFSCandidates
  global g_NM_minL2MaxCBFSCandidateClasses g_NM_maxL2MaxCBFSCandidateClasses
  global g_NM_minL2MaxCBFSSearchSpace g_NM_maxL2MaxCBFSSearchSpace
  global g_NM_minL2MaxCoverCandidateRank g_NM_maxL2MaxCoverCandidateRank 
  global g_NM_minL2MaxHistorySteps g_NM_maxL2MaxHistorySteps
  global g_NM_minL2MaxCBFSCutoffWeight g_NM_maxL2MaxCBFSCutoffWeight 
  global g_NM_L2ProgressCmdTypeList
  global g_NM_L2minTrajectoriesTracked g_NM_L2maxTrajectoriesTracked 
  global g_NM_L2FindCandidatesCmdTypeList 
  global g_NM_scenarioDialogRoot g_NM_l2toolsCurrentTime
  global g_NM_instantiateTestModuleP
  global g_NM_readableJavaTokenRegexp g_NM_readableJavaTokenOrQRegexp
  global g_NM_readable01JavaTokenRegexp g_NM_readable1nJavaTokenRegexp
  global g_NM_readableJavaFormRegexp
  global g_NM_scenarioMgrXpos g_NM_scenarioMgrYpos g_NM_scenarioEobLine
  global g_NM_selectedTestScopeRoot g_NM_selectedTestScope
  global g_NM_canvasGroupNodeDeleteP g_NM_reservedNameList
  global g_NM_componentTestList g_NM_moduleTestList 

  set g_NM_icon_width 25;
  set g_NM_icon_height 20;
  set g_NM_canvasGrid 10;
  set g_NM_powerAvailable 0;            # scale units
  set g_NM_powerMaxScale 200;           # scale units
  set g_NM_powerMaxAvailable 190;       # scale units
  set g_NM_powerAvailableWidth 200;     # pixels
  set g_NM_powerAvailableWidgetPaths {};
  set g_NM_powerAvailableSliderTag "";
  set g_NM_powerAvailableSliderMaxTag "";
  set g_NM_nodeStateWindowList {};
  set g_NM_detailLogP 0;
  set g_NM_mkformNodeCompleteP 0;
  set g_NM_classInstance {};
  set g_NM_instanceToNode(0) 1;   # all node types: component, module, terminal
  set g_NM_componentToNode(0) 1;  # only node type component
  set g_NM_moduleToNode(0) 1;     # only node type module
  set g_NM_nodeGroupToInstances(0) 1;
  # array keys are currentCanvas
  set g_NM_pendingPirEdgesList(0) 1;
  # use getCanvasRootInfo/setCanvasRootInfo accessors
  if {[string match $g_NM_schematicMode layout]} {
    set g_NM_currentCanvas .master.canvas.root
    set g_NM_parentNodeGroupList {root}
    set g_NM_currentNodeGroup root
    set g_NM_canvasParentNodeIdList {}
    # to handle edges which are connected thru a module "pointer"
  } else {
    ## alists based on canvasRootId - 0 is master canvas
    set g_NM_currentCanvas {0 .master.canvas.root}
    set g_NM_parentNodeGroupList {0 {root}};
    set g_NM_currentNodeGroup {0 root}
    set g_NM_canvasParentNodeIdList {0 {}}
  }
  set g_NM_className {};
  set g_NM_livingstoneDefmoduleFileName "";
  set g_NM_livingstoneDefmoduleName "";
  set g_NM_edgesOfRedrawNode {};        # list of fromNodes sublist & toNodes sublist
  set g_NM_paletteDefcomponentList {};
  set g_NM_paletteDefmoduleList {};
  set g_NM_paletteAbstractionList {};
  set g_NM_paletteDefrelationList {};
  set g_NM_paletteStructureList {};
  # structs which are parameterized terminal types
  set g_NM_paletteStrucIsTerminalTypeParamList {}
  set g_NM_paletteDefvalueList {};
  set g_NM_paletteDefspecList {};
  set g_NM_paletteTerminalList {};
  set g_NM_paletteAttributeList {};
  set g_NM_paletteModeList {};
  set g_NM_paletteDefsymbolList {};
  set g_NM_terminalTypeList {}
  set g_NM_terminalTypeValuesArray(0) 1;
  set g_NM_inhibitEdgeTypeMismatchP 0;
  set g_NM_mkEntryWidgetWidth 30;
  set g_NM_defmoduleFilePath {};
  set g_NM_termtypeRootWindow ".termtype"
  set g_NM_statePropsRootWindow ".stateprops"
  set g_NM_nodeTypeRootWindow ".nodetype"
  set g_NM_permBalloonRootWindow ".permballoon"
  set g_NM_advisoryRootWindow ".advisorydialog"
  set g_NM_editPrefsRootWindow ".tPrefs"
  set g_NM_editDSColorPrefsRootWindow ".tDSColorPrefs"
  set g_NM_scenarioNameRootWindow ".scenarioName"
  set g_NM_scenarioCommentRootWindow ".scenarioComment"
  set g_NM_jmplCompilerRootWindow ".jmpl"
  set g_NM_newWorkspaceRootWindow ".askNewWorkspace"
  set g_NM_xWindowMgrOffset 0;
  set g_NM_yWindowMgrOffset 0;
  set g_NM_terminalNodeWidth 12;        # pixels
  set g_NM_selectedEdge "";             # for edgeB1StartMotion, etc
  set g_NM_selectedEdgeMovedP 0;        # for edgeB1StartMotion, etc
  set g_NM_snapToGridOn 1;
  set g_NM_defvaluesAList {};
  set g_NM_highlightedEdgeList {};
  set g_NM_newEdgeNumList {};
  set g_NM_processingNodeGroupP 0;
  # not used 
#   set g_NM_nodeStateBGColorLevels [list [preferred NM_unknownPowerBgColor] 0 \
#       [preferred StanleyModuleNodeBgColor] 1 \
#       [preferred NM_inactiveStateBgColor] 2 \
#       [preferred NM_activeStateBgColor] 3 \
#       [preferred NM_recoverableStateBgColor] 4 \
#       [preferred NM_unknownStateBgColor] 5 \
#       [preferred NM_degradedStateBgColor1] 6 \
#       [preferred NM_failedStateBgColor] 7]
  # list of all canvases existing in a schematic
  set g_NM_canvasList {}
  set g_NM_canvasIdToPirNode(0) 1
  set g_NM_windowPathToPirNode(0) 1
  set g_NM_canvasIdToPirEdge(0) 1
  set g_NM_classToEdgeInstances(0) 1
  # { thrust-value thruster rcs-palette }
  set g_NM_passedModelModsByClass {}
  set g_NM_livingstoneDefmoduleArgList {}
  set g_NM_livingstoneDefmoduleArgTypeList {}
  set g_NM_livingstoneDefmoduleNameVar ""
  set g_NM_maxDefmoduleArgs 10;
  set g_NM_instantiatableSchematicExtension ".i-scm"
  set g_NM_generatedMPLExtension ".jmpl"
  set g_NM_dependentFilesExtension ".dep"
  set g_NM_terminalsFilesExtension ".terms"
  ## do [acons nodeClassType $classType pirClassComponent($className)] to these forms
  set g_NM_pirClassComponentTemplate {inputs {} outputs {} class_variables {name_var {default {}} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} attributes {default { {nil}}} mode {default {NIL}} ok_modes {default {}} fault_modes {default {}} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default {}}}}
    set g_NM_pirClassModuleTemplate {inputs {} outputs {} class_variables {name_var {default {}} args {default {}} argTypes {default {}} documentation {default {}} facts {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} attributes {default { {nil}}}}}
  # use form, rather than facts for structure symbol & value (g_NM_classDefType)
  set g_NM_pirClassASSVTemplate {class_variables {name_var {default {}} parentType {default {}} args {default {}} argTypes {default {}} documentation {default {}} form {default {}} valueList {default {}} terminalTypeParamP {default {0}}}}
  set g_NM_mkformNodeUpdatedP 0;
  set g_NM_mkformModuleDefaultValues(0) 1
  set g_NM_mkformModuleNumDefaultValues 0
  set g_NM_mkformComponentDefaultValues(0) 1
  set g_NM_mkformComponentNumDefaultValues 0
  set g_NM_terminalInstance {}
  set g_NM_stickyTerminalNameInput "";
  set g_NM_stickyTerminalTypeInput "";
  set g_NM_terminalDocInput "";
  set g_NM_rootInstanceName "";
  set g_NM_canvasRedrawP 0;
  set g_NM_fileOperation "";
  set g_NM_classDefType "<type>";
  set g_NM_propsWarnMsgsP 0;
  set g_NM_moduleGroupsUpdatedSinceReset {}
  set g_NM_onboardFileSelectedP 0
  set g_NM_groundFileSelectedP 0
  set mirPlayBackMsgNames "GROUND_FROM_TLM_MIR_TELEMETRY "
  set mirPlayBackMsgCnt 0
  ## handle > 9 significant digit floating point numbers
  set tcl_precision 17
  ## for operational playback mode -- sent to ipc-rec-viz
  set groundOnboardTimeDelta 0
  set g_NM_optMenuWidget ""
  set g_NM_optMenuWidgetValue "<unspecified>"
  set g_NM_saveWorkspaceCompactP 1; # 1 means compact .scm files; 0 for debugging
  # g_NM_filterPirNodeAttList used in write_workspace_doit
  # commandMonitorType is not a stand-alone pirNode attribute anymore --
  # it is encapsulated into inputs/outputs terminal forms.
  # componentHasIconP has been replaced by nodeHasIconP, since modules can 
  # also have icons
  set g_NM_filterPirNodeAttList { optional fixed nodeGroupBGLevel commandMonitorType \
                                      componentHasIconP }
  set g_NM_filterRestorePirNodeAttList { inputLabels outputLabels \
                                             nodePropList canvasId labelWindowSeenP \
                                             labelCanvasId labelWindow }
  set g_NM_filterPirClassAttList { type description }
  # ptrs to defcomponent/defmodule .scm's included in this module .scm
  set g_NM_includedModules {}
  # list of dependent schematic class file names for components/modules
  set g_NM_dependentClasses {abstraction {} component {} module {} relation {} structure {} symbol {} value {}}
  set g_NM_dependencyErrorList {}
  # [expr [llength $parentNodeGroupList] -1] <= g_NM_groupLevelSave
  # will be saved by write_workspace; == will be "ptrs" in g_NM_includedModules 
  set g_NM_groupLevelSave 1
  # used by pirGetModule to strip description & type atts from class_variables
  set g_NM_class_variablesModuleAttList {structure connections schematic_file}
  set g_NM_class_variablesAttributeList {name_var args input_terminals output_terminals \
                                              port_terminals mode ok_modes fault_modes \
                                              steady_state_power steady_state_power_modes \
                                              mode_transitions component_file \
                                              model_markers}
  # used to pass terminalInputs & terminalOutputs from canvasB1Click to
  # recursiveDefmoduleInstantiation
  set g_NM_terminalInputs {}
  set g_NM_terminalOutputs {}
  # save defmodule arg vars changes by user -- to be applied to upper & lower
  # modules of current
  set g_NM_argsVarsTranslations {}
  # next two values must be consistent
  set g_NM_classTypesAList [list abstraction [preferred abstractions_directory] \
                                component [preferred defcomponents_directory] \
                                module [preferred defmodules_directory] \
                                relation [preferred defrelations_directory] \
                                structure [preferred structures_directory] \
                                symbol [preferred defsymbols_directory] \
                                value [preferred defvalues_directory]]
  set g_NM_classTypes [list abstraction component module relation structure \
                           symbol value]
#   set g_NM_classTypesAList [list abstraction [preferred abstractions_directory] \
#                                 component [preferred defcomponents_directory] \
#                                 module [preferred defmodules_directory] \
#                                 relation [preferred defrelations_directory] \
#                                 structure [preferred structures_directory] \
#                                 symbol [preferred defsymbols_directory] \
#                                 value [preferred defvalues_directory] \
#                                 variantStructure [preferred variantStructures_directory]]
#   set g_NM_classTypes [list abstraction component module relation structure \
#                            symbol value variantStructure]

  set g_NM_paletteTypes [list attribute component mode module terminal]
  set g_NM_paletteTypesAList [list attribute [preferred attributes_directory] \
                                  component [preferred defcomponents_directory] \
                                  mode [preferred modes_directory] \
                                  module [preferred defmodules_directory] \
                                  terminal [preferred terminals_directory]]
  set g_NM_structureFormInput {}
  set g_NM_structureDocInput {}
  set g_NM_valueDocInput {}
  ## defcomponent global variables
  set g_NM_livingstoneDefcomponentName ""
  set g_NM_livingstoneDefcomponentNameVar ""
  set g_NM_livingstoneDefcomponentFileName ""
  set g_NM_livingstoneDefcomponentArgList {}
  set g_NM_livingstoneDefcomponentArgTypeList {}
  set g_NM_maxDefcomponentArgs 0
  set g_NM_modeDocInput ""
  set g_NM_modeModelInput {}
  set g_NM_transitionStartPirIndex 0
  set g_NM_modeTransitionDocInput {}
  set g_NM_modeTransitionPreconditionInput {}
  set g_NM_componentDocInput {}
  set g_NM_componentBackDocInput {}
  set g_NM_componentBackModelInput {}
  set g_NM_componentInitiallyInput {}
  set g_NM_moduleDocInput {}
  set g_NM_moduleFactsInput {}
  set g_NM_edgeDocInput {}
  set uniqueDialogId_global 1
  set g_NM_processingFileOpenP 0
  set g_NM_canvasRootIdCnt 0
  # width & height of scollbars and legends of overall Stanley window
  set g_NM_windowWidthBorder 27;
  set g_NM_windowHeightBorder 114;
  set g_NM_windowHeightTopBorder 0;
  # -scrollregion args for canvases
  set g_NM_absoluteCanvasWidth 3000
  set g_NM_absoluteCanvasHeight 2000
  set g_NM_selectedTestScope "<unspecified>"
  set g_NM_firstInstantiatedScopeP 1
  set g_NM_recursiveInstantiationP 0
  # array indexed by recursive level [expr [llength g_NM_parentNodeGroupList] - 2]
  # included module pointers from each class's g_NM_includedModules less any
  # components
  set g_NM_recursiveIncludeModulesTree(0) {}
  set g_NM_dialogTransitionSelection {}
  # set by Definiions->Instantiate
  set g_NM_selectedClassType {}
  set g_NM_selectedClassName {}
  set g_NM_buttonConnectStartButtonPath {}
  set g_NM_buttonConnectStopButtonPath {}
  if {! $g_NM_l2toolsPrefsP} {
    # all pref names which are colors must have "Color" in their name
    set g_NM_editablePrefNames \
        { L2SearchMethod L2MaxCBFSCandidateClasses L2MaxCBFSCandidates \
              L2MaxCBFSSearchSpace L2MaxCBFSCutoffWeight \
              L2MaxCoverCandidateRank \
              L2MaxHistorySteps L2ProgressCmdType L2NumTrajectoriesTracked \
              L2FindCandidatesCmdType StanleyEliminateUnreferencedJmplVars \
              StanleyTestPermanentBalloons StanleyShowNodeLegendBarP \
              StanleyWindowXPosition StanleyWindowYPosition \
              StanleyInitialCanvasWidth StanleyInitialCanvasHeight \
              StanleySchematicCanvasBackgroundColor StanleyTestCanvasBackgroundColor \
              StanleySelectedColor StanleyNodeConnectionBgColor StanleyModeTransitionBgColor \
              StanleyMenuDialogBackgroundColor StanleyMenuDialogForegroundColor \
              StanleyDialogButtonColor StanleyDialogEntryBackgroundColor \
              StanleyDialogEntryForegroundColor \
              StanleyLegendBgColor StanleyLegendFgColor StanleyTitleBgColor \
              StanleyTitleFgColor StanleyRubberBandColor \
              StanleyBalloonHelpBackgroundColor StanleyBalloonHelpForegroundColor \
              StanleyNodeLabelForegroundColor StanleyScrollBarColor \
              StanleyScrollBarTroughColor StanleyAttentionBgColor StanleyAttentionFgColor \
              StanleyAttentionWarningBgColor StanleyAttentionWarningFgColor \
              StanleyComponentLabelFont StanleyDialogEntryFont \
              StanleyDefaultFont StanleyTerminalTypeFont StanleyHelpFont \
              StanleyModuleNodeBgColor StanleyComponentNodeBgColor StanleyOkModeNodeBgColor \
              StanleyFaultModeNodeBgColor StanleyAttributeNodeBgColor \
              StanleyTerminalNodeBgColor StanleyNodataStateBgColor \
              StanleyNonCurrentModeBgColor StanleyCurrentOkModeBgColor \
              StanleyCurrentFaultModeBgColor \
              StanleyScenarioMgrExecColor StanleyScenarioMgrEditColor \
              StanleyScenarioMgrBreakPointColor 
            }
    # StanleyPropsWaveformColor 
    #  PV_defaultLogDir NM_terminalDeclNodeBgColor NM_terminalTermNodeBgColor
    # NM_propsTerminalConnectionColor
  }

  # initializeDisplayStateBgColors replaces these
#             NM_unknownPowerBgColor NM_inactiveStateBgColor NM_activeStateBgColor 
#             NM_recoverableStateBgColor NM_unknownStateBgColor NM_failedStateBgColor 
#             NM_degradedStateBgColor1 NM_degradedStateBgColor2 NM_degradedStateBgColor3 
#             NM_degradedStateBgColor4 NM_degradedStateBgColor5 

  set g_NM_prefsAppliedAtRestart \
      { StanleyShowNodeLegendBarP \
            StanleyWindowXPosition StanleyWindowYPosition \
            StanleyInitialCanvasWidth StanleyInitialCanvasHeight \
            StanleyMenuDialogBackgroundColor StanleyMenuDialogForegroundColor \
            StanleyLegendBgColor StanleyLegendFgColor StanleyTitleBgColor \
            StanleyTitleFgColor StanleyScrollBarColor \
            StanleyScrollBarTroughColor StanleyAttentionBgColor StanleyAttentionFgColor \
            StanleyAttentionWarningBgColor StanleyAttentionWarningFgColor \
            StanleyBalloonHelpBackgroundColor StanleyBalloonHelpForegroundColor \
          }
        # StanleyPropsWaveformColor
#   set g_NM_prefsAppliedAtOpsReset { StanleyPropsWaveformColor \
#                                         NM_propsTerminalConnectionColor }
  set g_NM_prefsAppliedAtOpsReset {}

  if {! $g_NM_l2toolsPrefsP} {
    set g_NM_editablePrefDescriptions \
        {"Livingstone search (cover or cbfs)" \
             "Livingstone max candidates returned (cbfs)" \
             "Livingstone max candidates searched (cbfs)" \
             "Livingstone max candidate rank (cbfs)" \
             "Livingstone max candidate rank (cover)" \
             "Livingstone history length (0 = none)" \
             "Livingstone progress style (min [opt=on] or full [opt=off])" \
             "Livingstone max candidates tracked" \
             "Livingstone find candidate style (prune-search, find-fresh, or extend)" \
             "Stanley test permanent balloons (on or off)" \
             "Stanley node legend bar shown" \
             "Stanley window x screen position" \
             "Stanley window y screen position" \
             "Stanley window screen width" \
             "Stanley window screen height" \
             "Stanley canvas background color (schematic)" \
             "Stanley canvas background color (test)" \
             "Stanley mouse selection color" \
             "Stanley node connection color" \
             "Stanley mode transition color" \
             "Stanley menu & dialog background color" \
             "Stanley menu & dialog foreground color" \
             "Stanley dialog button background color" \
             "Stanley dialog entry background color" \
             "Stanley dialog entry foreground color" \
             "Stanley legend background color" \
             "Stanley legend foreground color" \
             "Stanley title background color" \
             "Stanley title foreground color" \
             "Stanley rubber-band color" \
             "Stanley balloon help background color" \
             "Stanley balloon help foreground color" \
             "Stanley node label foreground color" \
             "Stanley scroll bar background color" \
             "Stanley scroll trough background color" \
             "Stanley attention msg background color" \
             "Stanley attention msg foreground color" \
             "Stanley attention warning msg background color" \
             "Stanley attention warning msg foreground color" \
             "Stanley node label font" \
             "Stanley dialog entry font" \
             "Stanley menu, & dialog title font" \
             "Stanley terminal & balloon help pop-up font" \
             "Stanley help text font" \
             "Stanley module node color" \
             "Stanley component node color" \
             "Stanley ok mode node color" \
             "Stanley fault mode node color" \
             "Stanley attribute node color" \
             "Stanley terminal node color" \
             "Stanley no data mode state color" \
             "Stanley non-current mode color" \
             "Stanley current ok mode color" \
             "Stanley current fault mode color" \
             "Stanley scenario mgr exec color" \
             "Stanley scenario mgr edit color" \
             "Stanley scenario mgr break point color" \
           }
  }
  # "Stanley state viewer waveform color"
  # "Packet View default ipc-recorder file directory" 
  #          "VMPL terminal declaration node color" 
  #          "VMPL terminator node color" 
  #       "Proposition highlight color" 

  # initializeDisplayStateBgColors replaces these
#             "OPS ok power unknown state color" 
#             "OPS ok power off state color" 
#             "OPS ok power on state color" 
#             "OPS recoverable state color" 
#             "OPS no data state color" 
#             "OPS failed state color" 
#             "OPS degraded 1 state color" 
#             "OPS degraded 2 state color" 
#             "OPS degraded 3 state color" 
#             "OPS degraded 4 state color" 
#             "OPS degraded 5 state color" 
  
  set g_NM_recursiveTraceOutputP 0
  set g_NM_vmplPrefNames { StanleyModuleNodeBgColor StanleyComponentNodeBgColor \
                               StanleyOkModeNodeBgColor StanleyFaultModeNodeBgColor \
                               StanleyAttributeNodeBgColor StanleyTerminalNodeBgColor \
                               NM_terminalTermNodeBgColor \
                             }
  set g_NM_readOnlyDefsAlist [split $READ_ONLY_DEFS ":"]
  # the first one of READ_ONLY_DEFS is the type def for displayState attribute class
  set g_NM_displayStateType [lindex $g_NM_readOnlyDefsAlist 1]
  # the first value of the g_NM_displayStateType is the default display state
  # see fillTerminalTypeList
  set g_NM_defaultDisplayState ""
  # reset in initializeDisplayStateBgColors using
  # [lindex [preferred STANLEY_USER_DIR] 0]/display-state-color-prefs
  set g_NM_displayStateColorMapping [list noData StanleyNodataStateBgColor \
                                         indeterminate StanleyIndeterminateStateBgColor \
                                         unknownL2Value StanleyUnknownL2ValueStateBgColor \
                                         okUnk NM_unknownPowerBgColor \
                                         okOff NM_inactiveStateBgColor \
                                         okOn NM_activeStateBgColor \
                                         recoverable NM_recoverableStateBgColor \
                                         failed NM_failedStateBgColor \
                                         degraded NM_degradedStateBgColor1]
  set g_NM_stateColorList {noData indeterminate unknownL2Value}
  set g_NM_stateIndirectColorList {noData StanleyNodataStateBgColor \
                                       indeterminate StanleyIndeterminateStateBgColor \
                                       unknownL2Value StanleyUnknownL2ValueStateBgColor}
  set g_NM_colorPrefsList {}
  # next two are not used anymore
#   set g_NM_acsModeHealthValues [list OK FAILED DEGRADED UNKNOWN]
#   set g_NM_acsModeHealthColorMapping [list OK [preferred NM_activeStateBgColor] \
#                                           FAILED [preferred NM_failedStateBgColor] \
#                                           DEGRADED [preferred NM_degradedStateBgColor1] \
#                                           UNKNOWN [preferred NM_unknownStateBgColor] \
#                                           NO-DATA [preferred StanleyNodataStateBgColor]]
  # array to place editing state -- used to check for editing changes
  set g_NM_modeTransitionEditState(0) 1
  set g_NM_modeTransitionEditState(Name) ""
  set g_NM_modeTransitionEditState(Cost) ""
  set g_NM_modeTransitionEditState(Precondition) ""
  set g_NM_modeTransitionEditState(Documentation) ""
  set g_NM_notComponentModuleList {}
  set g_NM_notModuleList {}
  # edges that cannot be connected because terminal name/type matching fails
  set g_NM_edgeConnectionFailedList {}
  # edges that cannot be connected because input terminals can only have 1 connection
  set g_NM_edgeConnectionInvalidList {}
  set g_NM_menuStem menus_accels.menu 
  set g_NM_acceleratorStem menus_accels.accelerators 
  set g_NM_inhibitPirWarningP 0
  set g_NM_componentFaultDialogRoot ".compfault"
  set g_NM_componentFaultIndexList {}
  set g_NM_componentFaultIndexList_1 {}
  # array with indices of nodeClassName whose values are inputs &
  # outputs of class root node - recursively bound with name_avr/args & 
  # nodeInstanceName/argsValues
  set g_NM_terminalDefsArray(0) 1
  # set g_NM_commandMonitorTypesList {monitor command prop-monitor}
  # prop-monitor says monitor this proposition and when its state changes
  # translate its propositional value to the seond arg for the exec or whatever
  set g_NM_commandMonitorTypesList {monitored commanded}
  set g_NM_terminalInterfaceTypesList {public private} 
  set g_NM_propValuesColorMap [list [preferred StanleyIndeterminateStateBgColor] \
                                   [preferred StanleyAttributeNodeBgColor] \
                                   [preferred NM_inactiveStateBgColor] \
                                   [preferred NM_activeStateBgColor] \
                                   [preferred NM_recoverableStateBgColor] \
                                   [preferred NM_failedStateBgColor] \
                                   [preferred NM_degradedStateBgColor1]]
  set g_NM_propValuesCount 0
  set g_NM_propValuesArray(0) 1
  # contains info on component/module terminals and connections set by
  # received propositions
  set g_NM_propsTerminalConnectionsSet {}
  # name of filename to hold create module common functions
  set g_NM_createModuleFileName "create-module"
  # VMPL schematic mode (g_NM_schematicMode = layout) is in test mode
  set g_NM_vmplTestModeP 0
  set g_NM_testInstanceName "test"
  set g_NM_testInstanceNameInternal "?name.test"
  set g_NM_testModuleArgsValues ""
  # comamnd and montor propositions selected by the user
  set g_NM_stepCommandsMonitors ""
  # proposition counters in handleIPCMessage
  set goodPropCnt 0; set badPropCnt 0; set nextPropCnt 0; set unknownPropCnt 0
  set g_NM_packetTimeTagsList {}
  set g_NM_groundRefTime 0
  set g_NM_currentTableWidgetCol -99
  # component modes which drive parent component or module node labels
  set g_NM_showModeInstances \
      { ACS-A { displayNode ACS-MODULE displayLabel ACS } \
            (RCS-MODE~ACS-A) { displayNode ACS-MODULE displayLabel ACS } \
            IPS-A { displayNode IPS-MODULE displayLabel IPS } \
            (COMM-STATUS-OUT~(RT~LPE-A)) { displayNode (RT-MODULE~LPE-A) displayLabel LPE } \
            (POWER-INPUT~CAM-ELEC) { displayNode CAM-ELEC displayLabel MICAS } \
            (POWER-INPUT~SRU-A) { displayNode SRU-MODULE displayLabel SRU } \
            (POWER-INPUT~PDE-A) { displayNode PDE-MODULE displayLabel PDE } \
          }
  # node has image bitmap for display rather than rectangle
  set g_NM_nodeHasIconP 0
  # inherited terminal types have overridden module's knowledge
  # of terminal types in g_NM_includedModules
  set g_NM_pendingEdgesOverrideMsgP 0
  set g_NM_testScenarioName "<unspecified>"
  set g_NM_nodeTypesHaveIcons [list attribute component mode module terminal]
  set g_NM_metaDotParentNodeGroupList {}
  # set by accelerator buttons Show (Icon) Labels/Hide (Icon) Labels
  set g_NM_showIconLabelBalloonsP 0
  # current VMPL GUI instance has/has not node legend bar
  set g_NM_showNodeLegendBarP 0
  # used in canvasB1Motion to prevent spurious skeletons after File->Open Def dialog
  set g_NM_canvasStartMotionP 0
  # array of Test mode terminal canvas label balloons - key: terminal node widget;
  # value: {canvasWindow canvasId text constraintP}
  set g_NM_testValuesBalloons(0) 1
  set g_NM_jmplLintExtenstion ".lint"
  set g_NM_jmplCompilerExtension ".xmpl"
  set g_NM_scenarioExtension ".scr"
  set g_NM_scenarioDebugExtension ".dbg"
  set g_NM_cmdMonExtension ".hrn"
  set g_NM_jmplInitExtension ".ini"
  set g_NM_paramsExtension ".params"
  set g_NM_jmplCompilerOptExtension ".xmpl-opt"
  # constraint values set by scenario scripts - index is time step
  set g_NM_commandMonitorConstraints(0) {}
  # triplets of window direction buttonNum for cmd/mon terminals
  set g_NM_allCommandMonitorForms {}
  # allowable search methods for Livingstone
  set g_NM_L2SearchMethods { cbfs cover }
  # allowable range of values for number of CBFS candidate classes to return
  # 0 indicates unbounded classes
  set g_NM_minL2MaxCBFSCandidateClasses 0
  set g_NM_maxL2MaxCBFSCandidateClasses 100
  # allowable range of values for number of CBFS candidates to return
  set g_NM_minL2MaxCBFSCandidates 1
  set g_NM_maxL2MaxCBFSCandidates 1000
  # allowable range of values for size of CBFS candidate search space
  set g_NM_minL2MaxCBFSSearchSpace 100
  set g_NM_maxL2MaxCBFSSearchSpace 100000
  #  allowable range of values for max COVER candidate rank
  set g_NM_minL2MaxCoverCandidateRank 2
  set g_NM_maxL2MaxCoverCandidateRank 20
  # 0 indicates no history truncation
  set g_NM_minL2MaxHistorySteps 0
  set g_NM_maxL2MaxHistorySteps 100
  # allowable values of L2ProgressCmdType
  set g_NM_L2ProgressCmdTypeList {min full}
  # allowable range for values of max num of trajectories tracked
  set g_NM_L2minTrajectoriesTracked 1
  set g_NM_L2maxTrajectoriesTracked 64
  # allowable range for values of CBFS max cutoff weight
  set g_NM_minL2MaxCBFSCutoffWeight 1
  set g_NM_maxL2MaxCBFSCutoffWeight 1000
  set g_NM_L2FindCandidatesCmdTypeList {prune-search find-fresh extend}
  # root window for Scenario Window test and accelerator cmds
  set g_NM_scenarioDialogRoot ".scenario"
  # set by stateID field of newState/viewState CORBA msgs
  set g_NM_l2toolsCurrentTime "<unspecified>"
  # set to 1 when invoking Test->Load & Go -- used in askClassInstance
  set g_NM_instantiateTestModuleP 0
  set g_NM_readableJavaTokenRegexp "javaToken: \[a->z\], \[A->Z\], \[0->9\], _"
  set g_NM_readableJavaTokenOrQRegexp \
      "javaToken or ?javaToken: \[a->z\],\n \[A->Z\], \[0->9\], _, leading ?"
  set g_NM_readable01JavaTokenRegexp "0-1 javaToken: \[a->z\], \[A->Z\], \[0->9\], _"
  set g_NM_readable1nJavaTokenRegexp "1-n javaToken(s): \[a->z\], \[A->Z\], \[0->9\], _"
  set g_NM_readableJavaFormRegexp "Java MPL form: \[a->z\], \[A->Z\], \[0->9\], ()\{\}\[\]=!&|,:;.?_"
  # used to keep Scenario Manager is same location
  set g_NM_scenarioMgrXpos -1
  set g_NM_scenarioMgrYpos -1
  # scneario mgr end-of-buffer text line
  set g_NM_scenarioEobLine "-- end-of-buffer --"
  set g_NM_selectedTestScopeRoot ""
  set g_NM_selectedTestScope ""
  # = 1 if deleting a group of nodes/edges with Mouse-L: drag
  set g_NM_canvasGroupNodeDeleteP 0
  # names which cannot be used for class or instance names
  set g_NM_reservedNameList {}
  # build list of components & modules which do not have parameters
  set g_NM_componentTestList {}
  set g_NM_moduleTestList {}
}

## initialize Stanley window; fill palette lists; expand structures, etc
## 17nov99 wmt: consolidated from stanley.tcl
proc initialize_stanley { startupP } {
  global STANLEY_ROOT g_NM_windowWidthBorder
  global g_NM_windowHeightBorder g_NM_showNodeLegendBarP 
  global g_NM_instantiatableSchematicExtension g_NM_classTypes
  global g_NM_menuStem g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_generatedMPLExtension initialize_graphCalledP
  global g_NM_l2ToolsP g_NM_checkFileDatesP
  global env g_NM_readOnlyWorkspaceList STANLEY_SUPERUSER
  global g_NM_toolsL2ViewerP g_NM_dependencyErrorList
  global g_NM_schematicMode g_NM_win32P


  set reinit 1
  if {$startupP} {
    set reinit 0
  }
  initialize_graph $reinit

  # generate palette menu lists - required for createNewRootCanvas 
  fillPaletteLists 

  if {$startupP} {
    # createNewRootCanvas -> mainWindow -> updateFileOpenDeleteCascadeMenus 
    createNewRootCanvas
  } else {
    updateFileOpenDeleteCascadeMenus
  }
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }
  set severity 1; set msg2 ""
  pirWarning "Please Wait: Stanley being initialized ..." $msg2 $severity
  update

  # requires pirClasses to be defined and needed prior to
  # calling generateIscmOrMplFiles
  fillTerminalTypeList

  if {$startupP} {
    # compute window manager decoration offsets for top-level Tcl windows
    set window .x
    toplevel $window -class Dialog
    set xPos 100; set yPos 100
    wm geometry $window +${xPos}+${yPos}
    wm title $window "Hi There!"
    frame $window.label

    set logo [image create photo -format GIF \
                  -file $STANLEY_ROOT/src/images/tcllogo.gif]
    button $window.label.logo -image $logo -bg [preferred StanleyMenuDialogBackgroundColor]

    label $window.label.l -anchor w -foreground black -background yellow \
        -text "  Welcome to Stanley  "
    pack  $window.label.logo $window.label.l -side top -fill x
    pack $window.label -fill both -expand true
    update
    after 2000

    set newXPos [winfo rootx $window]
    set newYPos [winfo rooty $window]
    # puts "main_window xPos $xPos yPos $yPos newXPos $newXPos newYPos $newYPos"
    set g_NM_xWindowMgrOffset [expr {$newXPos - $xPos}]
    set g_NM_yWindowMgrOffset [expr {$newYPos - $yPos}]

    set g_NM_windowWidthBorder [expr {[winfo width .master.canvas.root.yscroll] + \
                                          3 * [lindex [.master.canvas.root.yscroll config \
                                                           -borderwidth] 4]}]
    set g_NM_windowHeightBorder [expr {[winfo rooty .master.canvas] + \
                                           [winfo height .master.canvas.root.bottom.xscroll] + \
                                           [winfo height .master.header] + \
                                           [winfo height .master.title] + \
                                           [winfo height .master.warnings] + \
                                           5 * [lindex [.master.warnings config \
                                                            -borderwidth] 4]}]
    if {$g_NM_showNodeLegendBarP} {
      set g_NM_windowHeightBorder [expr {$g_NM_windowHeightBorder + \
                                             [winfo height .master.legend]}]
    }
    # puts stderr "g_NM_windowWidthBorder $g_NM_windowWidthBorder"
    # puts stderr "g_NM_windowHeightBorder $g_NM_windowHeightBorder"

    # resize Stanley window for smaller screens
    # does not work properly
#     set initXPos [preferred StanleyWindowXPosition]
#     set initYPos [preferred StanleyWindowYPosition]
#     set initWidth [expr { $initXPos + [preferred StanleyInitialCanvasWidth] + \
#                               $g_NM_windowWidthBorder}]
#     set initHeight [expr { $initYPos + [preferred StanleyInitialCanvasHeight] + \
#                                $g_NM_windowHeightBorder}]
#     set screenWidth [winfo screenwidth .master]
#     set screenHeight [winfo screenheight .master]
#     puts stderr "initialize_stanley: width $screenWidth height $screenHeight"
#     puts stderr "initialize_stanley: initXPos $initXPos initYPos $initYPos "
#     set resizedP 0
#     # testing ;
#     set screenWidth 600
#     # set screenHeight 400
#     if {$initWidth > $screenWidth} {
#       set newInitWidth $screenWidth
#       set initXPos 0
#       set resizedP 1
#     }
#     if {$initHeight > $screenHeight} {
#       set newInitHeight $screenHeight
#       set initYPos 0
#       set resizedP 1
#     }
#     if {$resizedP} {
#       wm geometry .master ${newInitWidth}x${newInitHeight}+${initXPos}+${initYPos}
#       puts stderr "initialize_stanley: resized from ${initWidth}x${initHeight} to ${newInitWidth}x${newInitHeight}"
#     }
  } else {
    # update Edit->Instantiate cascades 
    updateInstantiationCascadeMenus component
    updateInstantiationCascadeMenus module
    .master.$g_NM_menuStem.edit.m entryconfigure "Header" -state disabled 
    .master.$g_NM_menuStem.edit.m entryconfigure "Instantiate" -state disabled 
  }

  set initialize_graphCalledP 0
  if {$g_NM_schematicMode == "layout"} {
    if {$g_NM_checkFileDatesP} {

      # .i-scm files are needed in operational mode, since recursive
      # loading of schematic files is now implemented.
      # generate .i-scm files from .scm files, if they do not exist
      # generate .terms files from .scm files, if they do not exist
      # generate .dep files from .scm files, if they do not exist
      # puts stderr "\nstanley.tcl: generateIscmOrMplFiles .i-scm, .dep, .terms commented out"
      set g_NM_dependencyErrorList {}
      set previousRedrawFailedList {}
      while {[llength [set redrawFailedList \
                           [generateIscmOrMplFiles $g_NM_classTypes]]] > 0} {
        # repeat until all defmodules have been recursively created
        # from dependent .i-scm files.  This is needed to handle
        # the fact that the .i-scm files are not created in any order
        if {[string match $previousRedrawFailedList $redrawFailedList]} {
          # prevent loop from incorrect schematic
          break
        }
        set previousRedrawFailedList $redrawFailedList
      }
      if {[llength $g_NM_dependencyErrorList] > 0} {
        # show user dependency errors
        set str "Class Dependency Errors\n"
        foreach formList $g_NM_dependencyErrorList {
          # component/module c/m-name reference-type reference-name
          append str "\nFor [lindex $formList 0] `[lindex $formList 1]'\n"
          append str "    [lindex $formList 2] `[lindex $formList 3]' not found"
        }
        set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
        eval $dialogList
        puts stderr $str
      }
    } else {
      puts stderr "\ninitialize_stanley: `generateIscmOrMplFiles .i-scm/.terms/.dep/.jmpl' not called"
    }
  }

  # if initialize_graph has been called by fileOpen from generateIscmOrMplFiles 
  # we need to reinit some globals so that initializeDisplayStateBgColors 
  # will not crunch
  if {$initialize_graphCalledP} {
    fillPaletteLists
    fillTerminalTypeList
    # call these to update Test->Select Scope lists
    updateInstantiationCascadeMenus component
    updateInstantiationCascadeMenus module
  }

  # read displayStateValues states and colors
  # requires that a Stanley window to exist, so it cannot be done in openWorkspace
  initializeDisplayStateBgColors

  update
  if {$startupP} {
    # destroy welcome window
    destroy $window
  }

  if {[string match $g_NM_schematicMode "layout"]} {
    if {$g_NM_toolsL2ViewerP} {
      .master.$g_NM_menuStem.file.m entryconfigure "New Definition"  \
          -state disabled
      .master.$g_NM_menuStem.file.m entryconfigure "Open Definition"  \
          -state disabled
      .master.$g_NM_menuStem.file.m entryconfigure "Delete Definition"  \
          -state disabled
      .master.$g_NM_menuStem.file.m entryconfigure "Print Definition"  \
          -state disabled
      .master.$g_NM_menuStem.file.m entryconfigure "New Workspace ..."  \
          -state disabled
      .master.$g_NM_menuStem.file.m entryconfigure "Open Workspace"  \
          -state disabled
      .master.$g_NM_menuStem.edit configure -state disabled 
      .master.$g_NM_menuStem.test configure -state disabled 
      .master.$g_NM_menuStem.tools configure -state disabled 

    } else {
      if {([lsearch -exact $g_NM_readOnlyWorkspaceList \
                [preferred projectId]] >= 0) && \
              (! [string match $STANLEY_SUPERUSER $env(LOGNAME)])} { 
        .master.$g_NM_menuStem.file.m entryconfigure "New Definition"  \
            -state disabled
        .master.$g_NM_menuStem.file.m entryconfigure "Delete Definition"  \
            -state disabled
      } else {
        .master.$g_NM_menuStem.file.m entryconfigure "New Definition"  \
            -state normal
        .master.$g_NM_menuStem.file.m entryconfigure "Delete Definition"  \
            -state normal
      }
    }
  }
  pirWarning ""
  .master.canvas config -cursor top_left_arrow
  update
}


## re-initialization. If reinit is 1, we reuse the same application
## 11dec95 wmt: change announcement msg
## 08jan96 wmt: reset g_NM_classToInstances 
## 13mar96 wmt: reset g_NM_instanceToNode
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 04jun96 wmt: reset g_NM_nodeGroupToInstances, g_NM_currentNodeGroup, &
##              g_NM_parentNodeGroupList
## 29jun96 wmt: implement multiple canvases
## 09jul96 wmt: set pirGenInt_global to 0
## 26jul96 wmt: delete all schematic sub windows
## 24nov96 wmt: init for g_NM_autoDefModInstanP
## 30apr97 wmt: set pirGenSym value for g_NM_livingstoneDefmoduleName, if
##              makeNewDefmoduleNameP == 1
## 08may97 wmt: add g_NM_includedModules
proc initialize_graph { {reinit 0} { makeNewDefNameP 1 } } {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global g_NM_classToInstances g_NM_schematicMode
  global g_NM_instanceToNode g_NM_nodeGroupToInstances
  global g_NM_currentNodeGroup g_NM_parentNodeGroupList
  global g_NM_canvasList pirWireFrame g_NM_passedModelModsByClass
  global g_NM_canvasIdToPirNode g_NM_canvasIdToPirEdge
  global g_NM_classToEdgeInstances pirFileInfo
  global pirGenInt_global g_NM_metaDotParentNodeGroupList
  global g_NM_termtypeRootWindow g_NM_statePropsRootWindow
  global g_NM_nodeTypeRootWindow g_NM_permBalloonRootWindow
  global g_NM_advisoryRootWindow
  global g_NM_componentToNode g_NM_moduleToNode 
  global g_NM_livingstoneDefmoduleName
  global g_NM_livingstoneDefmoduleFileName g_NM_livingstoneDefmoduleNameVar
  global g_NM_includedModules g_NM_pendingPirEdgesList
  global g_NM_defmoduleArgsVars g_NM_defmoduleArgsValues
  global g_NM_argsVarsTranslations pirActiveFamilyName
  global g_NM_livingstoneDefcomponentName g_NM_rootInstanceName
  global g_NM_livingstoneDefcomponentFileName g_NM_livingstoneDefcomponentNameVar
  global g_NM_transitionStartPirIndex uniqueDialogId_global
  global g_NM_windowPathToPirNode g_NM_dependentClasses g_NM_dependencyErrorList
  global g_NM_recursiveIncludeModulesTree 
  global pirClassComponent pirClassesComponent 
  global pirClassModule pirClassesModule
  global pirClassRelation pirClassesRelation 
  global pirClassStructure pirClassesStructure 
  global pirClassAbstraction pirClassesAbstraction 
  global pirClassSymbol pirClassesSymbol g_NM_edgesOfRedrawNode
  global pirClassValue pirClassesValue g_NM_currentCanvas
  global pirClass pirClasses g_NM_stickyTerminalNameInput
  global g_NM_stickyTerminalTypeInput 
  global g_NM_propositionToNode g_NM_canvasParentNodeIdList
  global g_NM_terminalDefsArray g_NM_vmplTestModeP 
  global g_NM_propsTerminalConnectionsSet initialize_graphCalledP
  global g_NM_acceleratorStem g_NM_componentFaultDialogRoot 
  global g_NM_livingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgTypeList 
  global g_NM_livingstoneDefcomponentArgList g_NM_livingstoneDefcomponentArgTypeList
  global g_NM_highlightedEdgeList g_NM_testValuesBalloons 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "initialize_graph: `$backtrace'"
  # puts stderr "initialize_graph: "
  set initialize_graphCalledP 1
  catch { unset pirNodes pirEdges pirClassesComponent pirClassesModule \
              pirClassesStructure pirClassesSymbol pirClassesAbstraction \
              pirClassesRelation pirClassesValue pirClasses pirDisplay }
  set pirNodes {}
  set pirEdges {}
  set pirClassesComponent {}; set pirClassesModule {}
  set pirClassesStructure {}; set pirClassesSymbol {}
  set pirClassesAbstraction {}; set pirClassesRelation {}
  set pirClassesValue {}; set pirClasses {}
  set pirDisplay {}
  catch { unset g_NM_instanceToNode g_NM_componentToNode g_NM_moduleToNode \
            g_NM_nodeGroupToInstances g_NM_classToInstances g_NM_includedModules \
            g_NM_dependentClasses }
  set g_NM_instanceToNode(0) 1
  set g_NM_componentToNode(0) 1
  set g_NM_moduleToNode(0) 1
  set g_NM_nodeGroupToInstances(0) 1
  set g_NM_classToInstances(0) 1
  set g_NM_includedModules {}
  set g_NM_dependentClasses {abstraction {} component {} module {} relation {} \
                                 structure {} symbol {} value {}}
  set g_NM_dependencyErrorList {}
  set g_NM_argsVarsTranslations {}
  set g_NM_transitionStartPirIndex 0
  if {$makeNewDefNameP} {
    # unique value to use until user defines it
    set defName [pirGenSym "def" "-"] 
    set g_NM_livingstoneDefmoduleName $defName
    set g_NM_livingstoneDefmoduleFileName ""
    set g_NM_livingstoneDefmoduleNameVar "?name"
    set g_NM_livingstoneDefmoduleArgList {}
    set g_NM_livingstoneDefmoduleArgTypeList {}
    set g_NM_livingstoneDefcomponentName $defName
    set g_NM_livingstoneDefcomponentFileName ""
    set g_NM_livingstoneDefcomponentNameVar "?name"
    set g_NM_livingstoneDefcomponentArgList {}
    set g_NM_livingstoneDefcomponentArgTypeList {}
  }
  # use getCanvasRootInfo/setCanvasRootInfo accessors
  catch { unset g_NM_currentCanvas g_NM_parentNodeGroupList \
              g_NM_currentNodeGroup g_NM_canvasParentNodeIdList }
  if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
    set g_NM_currentCanvas .master.canvas.root
    set g_NM_parentNodeGroupList {root}
    set g_NM_currentNodeGroup root
    set g_NM_canvasParentNodeIdList {}
  } else {
    set g_NM_currentCanvas {0 .master.canvas.root}
    set g_NM_parentNodeGroupList {0 {root}}
    set g_NM_currentNodeGroup {0 root}
    set g_NM_canvasParentNodeIdList {0 {}}
  }
  set g_NM_metaDotParentNodeGroupList {}
  set g_NM_rootInstanceName root
  set g_NM_canvasList {}
  catch { unset g_NM_canvasIdToPirNode g_NM_windowPathToPirNode \
             g_NM_canvasIdToPirEdge g_NM_classToEdgeInstances \
            g_NM_pendingPirEdgesList g_NM_testValuesBalloons }
  set g_NM_canvasIdToPirNode(0) 1
  set g_NM_windowPathToPirNode(0) 1
  set g_NM_canvasIdToPirEdge(0) 1
  set g_NM_classToEdgeInstances(0) 1
  set g_NM_pendingPirEdgesList(0) 1
  set g_NM_testValuesBalloons(0) 1
  set g_NM_passedModelModsByClass {}
  set g_NM_defmoduleArgsVars {}
  set g_NM_defmoduleArgsValues {}
  set g_NM_stickyTerminalNameInput "";
  set g_NM_stickyTerminalTypeInput "";
  set g_NM_edgesOfRedrawNode {}

  pirSetVersion
  acons selectColor [preferred StanleySelectedColor] pirDisplay
  acons selectedNodes {} pirDisplay
  catch { unset pirNode pirEdge pirWireFrame }
  catch { unset pirClassComponent pirClassModule pirClassAbstraction pirClassRelation \
              pirClassStructure \
              pirClassSymbol pirClassValue pirClass }
  set pirNode(0) 1
  set pirEdge(0) 1
  set pirClassComponent(0) 1; set pirClassModule(0) 1
  set pirClassStructure(0) 1; set pirClassSymbol(0) 1
  set pirClassAbstraction(0) 1; set pirClassStructure(0) 1
  set pirClassValue(0) 1; set pirClass(0) 1
  set pirWireFrame(curX) 0
  set pirWireFrame(curY) 0
  set pirGenInt_global 1
  set pirActiveFamilyName ""
  catch { unset g_NM_recursiveIncludeModulesTree }
  set g_NM_recursiveIncludeModulesTree(0) {}
  catch { unset g_NM_propositionToNode g_NM_terminalDefsArray }
  set g_NM_propositionToNode(0) 1
  set g_NM_terminalDefsArray(0) 1
  set g_NM_highlightedEdgeList {}

  if {$reinit} {
    if {[winfo exists .master.canvas]} {
      # puts stderr "initialize: .master.canvas exists"
      # place root canvas on top as current canvas
      set canvasRootId 0; set xOverlay 0; set yOverlay 0
#       overlayCurrentCanvas .master.canvas.root \
#           [getCanvasRootInfo g_NM_currentCanvas $canvasRootId] \
#           nil $xOverlay $yOverlay
      # the following will destroy all canvases except root, so set
      # appropriate global to the only remaining canvas
      setCanvasRootInfo g_NM_currentCanvas .master.canvas.root $canvasRootId   
      # destroy all other canvases and delete all canvas items on root canvas
      foreach c [winfo children .master.canvas] {
        # puts stderr "initialize_graph: c $c"
        if {[string match $c .master.canvas.root]} {
          .master.canvas.root.c delete all
          foreach child [winfo children .master.canvas.root.c] {
            # puts stderr "initialize_graph: child $child"
            catch { destroy $child }
          }
        } else {
          catch { destroy $c }
        }
      }
      # create root canvas
      # set overlayP 0
      # createCanvas .master.canvas.root 0 0 $overlayP
    }

    # deleteAllPopUpWindows $g_NM_termtypeRootWindow
    deleteAllPopUpWindows $g_NM_statePropsRootWindow
    deleteAllPopUpWindows $g_NM_permBalloonRootWindow
    deleteAllPopUpWindows $g_NM_advisoryRootWindow
    if {[winfo exists $g_NM_componentFaultDialogRoot]} {
      destroy $g_NM_componentFaultDialogRoot
    }

    # do not delete node editing windows here
    # all File-> operations check for existence of component/module
    # editing dialogs and force user to close them.
    # File-> operations are not blocked by existence of structure/symbol/value
    # dialogs -- they should not be deleted here since
    # initialize_graph should just reset component/module schematics
    # deleteAllPopUpWindows $g_NM_nodeTypeRootWindow

    deleteAllViewDialogs

    if {[winfo exists .d]} {
      # tk_dialog window
      destroy .d
    }
    #  selectTerminalProposition may leave this if user does not make a selection
    if {[winfo exists .selectprop]} {
      destroy .selectprop
    }
  }
}


## set gobal vars for beth package -- paren matching for Lisp text widget
## 27oct97 wmt: new
proc bethInitialize { } {
  global overwrite_mode edit_flag flash_time paren_match_p

  set overwrite_mode 0
  set edit_flag 1
  set flash_time 2000
  set paren_match_p 1
}


## convert setenv syntax to Tcl suntax; lower case to upper case
## 06mar96 wmt: new
proc convertSetenvToTcl { setenvStringRef tclListRef } {
  upvar $setenvStringRef setenvString
  upvar $tclListRef tclList

  set tempList [split $setenvString :]
  foreach item $tempList {
    lappend tclList [string toupper $item]
  }
}


## read project display-state-values states and colors
## read from file at startup time
## read from arg list for applying Edit->Prefences->Workspace Display State Colors
## for OPS and vmplTest modes
## 10sep99 wmt: new
proc initializeDisplayStateBgColors { {colorPrefsList ""} } {
  global pirPreferences pirFileInfo 
  global g_NM_displayStateColorMapping pirClassValue
  global g_NM_stateColorList g_NM_stateIndirectColorList
  global g_NM_advisoryRootWindow 

  set canvasRootId 0; set savePrefsP 1
  set canvasRoot [getCanvasRoot $canvasRootId]
  # puts stderr "initializeDisplayStateBgColors: pirClassValue [array names pirClassValue]"
  # noData - Stanley has received no value from L2
  # indeterminate - Stanley cannot determine the display state color
  # unknownL2Value - Stanley has received the value "unknown" from L2
  if {$colorPrefsList == ""} {
    set pathName [lindex [preferred STANLEY_USER_DIR] 0]/display-state-color-prefs
    if {[file exists $pathName]} {
      puts stderr "\ninitializeDisplayStateBgColors from \n    $pathName"
      set fid [open $pathName r]
      while {[set lineLength [gets $fid stateColorPair]] >= 0} {
        # skip blank lines
        if {$lineLength > 0} {
          set displayState [lindex $stateColorPair 0]
          # in case user specified tokens with dashes
          if {[regexp -- - $displayState]} {
            set displayState [fixIdentifierSyntax $displayState]
          }
          lappend colorPrefsList [list $displayState [lindex $stateColorPair 1]]
        }
      }
      close $fid
    } else {
      # write null file
      set fid [open $pathName w]
      puts $fid ""
      close $fid
      puts stderr "Writing $pathName"
    }
  } else {
    # this is an "apply" call from pirEditDisplayStateColorPrefsOK or
    # Edit->Preferences->Workspace Display State Colors after the
    # first call
    set savePrefsP 0
  }
  # process colorPrefsList 
  set cnt 1
  # add to local variables
  set stateColorList $g_NM_stateColorList
  set stateIndirectColorList $g_NM_stateIndirectColorList 
  foreach stateColorPair $colorPrefsList {
    set displayState [lindex $stateColorPair 0]
    set displayStateColorValue [lindex $stateColorPair 1] 
    # check color value for validity 
    if [catch {winfo rgb $canvasRoot $displayStateColorValue } result] {
      set str "\n    `$displayStateColorValue' is not a valid color name\n"
      append str "    `$stateColorPair' discarded"
      puts stderr $str
      set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
      eval $dialogList
    } elseif {[lsearch -exact $g_NM_stateColorList $displayState] >= 0} {
      set str "\n    `$stateColorPair' ignored \n"
      append str "    Use Edit->Preferences->L2Tools/User/Workspace"
      append str "([assoc $displayState g_NM_stateIndirectColorList])"
      puts stderr $str
      set dialogList [list tk_dialog ${g_NM_advisoryRootWindow}.d "ADVISORY" \
                          $str warning 0 {DISMISS}]
      eval $dialogList   
    } else {
      lappend stateColorList $displayState
      lappend stateIndirectColorList $displayState OPS_displayStateBgColor_$cnt
      # color value indirection
      set pirPreferences(OPS_displayStateBgColor_$cnt) $displayStateColorValue 
      incr cnt
    }
  }

  # set str "initializeDisplayStateBgColors: stateIndirectColorList"
  # puts stderr "$str $stateIndirectColorList"
  # puts stderr "initializeDisplayStateBgColors: stateColorList $stateColorList"
  set g_NM_displayStateColorMapping $stateIndirectColorList
  if {$savePrefsP} {
    # has defvalues display-state-values already been updated with
    # [lindex [preferred STANLEY_USER_DIR] 0]/display-state-color-prefs
    set classDefName displayStateValues 
    set classDefType value
    set classPathname "[getSchematicDirectory root $classDefType]/"
    append classPathname ${classDefName}$pirFileInfo(suffix)
    set pirClassIndex $classDefName
    set classVars [assoc class_variables pirClassValue($pirClassIndex)]
    set valueListDefault [getClassVarDefaultValue valueList classVars]
    # puts stderr "initializeDisplayStateBgColors: valueListDefault $valueListDefault"
    if {(! [string match $stateColorList $valueListDefault]) || \
            (! [file exists $classPathname])} {
      setClassVarDefaultValue valueList $stateColorList classVars  
      arepl class_variables $classVars pirClassValue($pirClassIndex)
      # write schematic file & Java MPL files
      fileSave $classDefType $classDefName 
    }
  }
}


## open user files workspace => set directories into user files,
## re/initialize Stanley, and re/start Tools/L2
## 22jun00 wmt
proc openWorkspace { stanleyUserDir workspaceId startupP {setDirsP 1} } {
  global g_NM_l2ToolsP env g_NM_schematicMode 
  global pirPreferences g_NM_toolsL2ExistsP g_NM_menuStem
  global g_NM_l2toolsCurrentTime g_NM_selectedTestScope
  global g_NM_toolsL2ViewerP userPreferences defaultPreferences
  global workspacePreferences g_NM_projectId_default 

  if {(! $startupP) && [string match [lindex $pirPreferences(STANLEY_USER_DIR) 0] \
                            $stanleyUserDir]} {
    return
  }
  if {! [file exists $stanleyUserDir]} {
    set msg "`$stanleyUserDir' does not exist"
    append msg "\ncheck $env(HOME)/.stanley/userPrefs (STANLEY_USER_DIR)"
    set dialogList [list tk_dialog .d "ERROR" $msg error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {! $startupP} {
    set rsvEditsP 1
    if {[outstandingEditDialogsP $rsvEditsP] || [save_dialog]} {
      return
    }
  }
  destroyScenarioManager

  # puts stderr "openWorkspace: stanleyUserDir $stanleyUserDir workspaceId $workspaceId "
  set menuRoot .master.$g_NM_menuStem
  if {$setDirsP} {
    set pirPreferences(LIVINGSTONE_MODELS_DIR) \
        $stanleyUserDir/[preferred livingstone_directory]/[preferred models_directory]
    set oldUserDirList [preferred STANLEY_USER_DIR] 
    set newUserDirList {}
    # put selected workspace first in the list of workspaces
    lappend newUserDirList $stanleyUserDir 
    foreach workspacePath [preferred STANLEY_USER_DIR] {
      if {! [string match $workspacePath $stanleyUserDir]} {
        lappend newUserDirList $workspacePath
      }
    }
    # puts stderr "openWorkspace: oldUserDirList $oldUserDirList newUserDirList $newUserDirList"
    if {! [string match $oldUserDirList $newUserDirList]} {
      set pirPreferences(projectId) $workspaceId 
      set pirPreferences(STANLEY_USER_DIR) $newUserDirList 
      set userPreferences(projectId) $workspaceId 
      set userPreferences(STANLEY_USER_DIR) $newUserDirList 
      # write ~/.stanley/userPrefs
      pirSavePreferences user
    }
    if {! $startupP} {
      # rebuild cascade menus, so that current workspace is not a selection
      destroy $menuRoot.file.m.openWorkspace
      set menuPath [menu $menuRoot.file.m.openWorkspace -tearoff 0]
      buildWorkspaceCascadeMenu "openWorkspace" $menuPath $startupP 
      destroy $menuRoot.file.m.forgetWorkspace
      set menuPath [menu $menuRoot.file.m.forgetWorkspace -tearoff 0]
      buildWorkspaceCascadeMenu "forgetWorkspace" $menuPath $startupP 

      if {([llength [preferred STANLEY_USER_DIR]] > 2) || \
              (([llength [preferred STANLEY_USER_DIR]] == 2) && \
                   [string match [preferred projectId] $g_NM_projectId_default])} {
        $menuRoot.file.m entryconfigure "Forget Workspace" -state normal
      }
    }
  }
  # update preferences: l2tools user workspace
  set workspacePrefpath "[lindex [preferred STANLEY_USER_DIR] 0]/workspacePrefs"
  if {[file exists $workspacePrefpath]} {
    pirReadPreferences workspace
  } else {
    catch { unset workspacePreferences }
    set workspacePreferences(0) 1
    # initial workspacePrefs is empty set
    pirSavePreferences workspace
  }
  # now merge them
  pirLoadPreferences

  if {$g_NM_l2ToolsP} {
    if {$startupP} {
      if {! $g_NM_toolsL2ExistsP} {
        # start Livingstone with CORBA to create ORB server
        startL2toolsJNIandL2
      }
      # initialize as CORBA client
      initializeStanleyCORBAClient 
    } elseif {! $g_NM_toolsL2ViewerP} {

      resetL2toolsJNIandL2 
    }
    if {[winfo exists .master]} {
      # disable all Test menu selections, if we have been in Test
      changeVmplTestToEdit
      set menuRoot .master.$g_NM_menuStem
      $menuRoot.test.m entryconfigure "Compile" -state disabled
    }
  } elseif {[string match $g_NM_schematicMode "operational"]} {

    initStanleyAsGPUClient

  }

  if {! $startupP} {
    raiseStanleyWindows
  }
  puts stderr "\nOpen Workspace $stanleyUserDir\n"

  # reset Test scope and time
  set g_NM_l2toolsCurrentTime "<unspecified>"
  set g_NM_selectedTestScope "<unspecified>"
  if {[winfo exists $menuRoot.test.m]} {
    $menuRoot.test.m entryconfigure "Compile" -state disabled 
    $menuRoot.test.m entryconfigure "Load & Go" -state disabled
  }

  initialize_stanley $startupP
}


## ask the user to enter the pathname of a new workspace
## if it does not exist, create the file hierarchy
## 23jun00 wmt
proc askNewWorkspace { copyBasicClassFilesP} {
  global g_NM_newWorkspaceRootWindow HOME 

  set rsvEditsP 1
  if {[outstandingEditDialogsP $rsvEditsP]} {
    return
  }
  if {[save_dialog]} {
    return
  }
  set currentDir [pwd]
  pushd $currentDir 
  cd $HOME 
  set parentDirectory \
      [tk_chooseDirectory -title "Select New Workspace Parent Directory" \
           -parent .master.canvas]
  # puts stderr "askNewWorkspace: parentDirectory $parentDirectory"
  popd
  if {$parentDirectory == ""} {
    # respond to dialog cancel
    return
  }


  set initP 0
  set dialogW $g_NM_newWorkspaceRootWindow 
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog 
  wm title $dialogW "New Workspace Name"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  $dialogW config -bg $bgcolor

  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command "askNewWorkspaceUpdate $dialogW $parentDirectory $copyBasicClassFilesP"
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP" 
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set widget $dialogW.fName
  mkEntryWidget $widget "" "" "" normal

  focus $dialogW.fName.fentry.entry
  keepDialogOnScreen $dialogW 

  if [winfo exists $dialogW] {
    tkwait window $dialogW
  }
}


proc askNewWorkspaceUpdate { dialogW parentDirectory copyBasicClassFilesP } {
  global STANLEY_ROOT pirPreferences g_NM_menuStem
  global g_NM_projectId_default g_NM_win32P

  set startupP 0
  set stanleyUserName [$dialogW.fName.fentry.entry get]
  set stanleyUserName [string trim $stanleyUserName " "]
  # make sure this is just a name and not a path
  if {! [entryValueErrorCheck "New Workspace Name" "(directory_name)" \
             $stanleyUserName]} {
    return
  }
  set stanleyUserPathname "${parentDirectory}/"
  append stanleyUserPathname $stanleyUserName
  # puts stderr "askNewWorkspaceUpdate: stanleyUserPathname $stanleyUserPathname"

  # check that workspace name does not already exist in Stanley's known
  # workspaces
  set stanleyUserLeafName [file tail $stanleyUserPathname]
  foreach workspacePath [preferred STANLEY_USER_DIR] {
    set workspaceId [file tail $workspacePath]
    if {[string match $stanleyUserLeafName $workspaceId]} {
      set str "workspace name not unique -- already exists\n"
      append str "`$workspacePath'"
      set dialogList [list tk_dialog .d "ERROR" $str \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
  }
  # do not obliterate any other directory
  if {[file exists $stanleyUserPathname]} {
    set str "workspace pathname not unique -- already exists\n"
    append str "`$stanleyUserPathname'"
    set dialogList [list tk_dialog .d "ERROR" $str \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  destroy $dialogW 

  file mkdir $stanleyUserPathname
  puts stderr "Workspace directory '$stanleyUserPathname' created"
  # create directory and setup basic files
  puts stderr "\nUser directories created in"
  puts stderr "    $stanleyUserPathname ...\n"
  if {$copyBasicClassFilesP} {
    puts stderr "Basic abstraction, relation, structure, symbol, "
    puts stderr "    and value class definitions added ... \n"
  }

  set currentDir [pwd]
  pushd $currentDir 
  # needed for use of relative pathnames
  cd $STANLEY_ROOT/interface
  if {! $g_NM_win32P} {
    # exec create-stanley-user-dirs.csh $stanleyUserPathname
    # needs to use absolute path, or get file not-found error
    exec $STANLEY_ROOT/interface/create-stanley-user-dirs.csh $stanleyUserPathname \
        $copyBasicClassFilesP
  } else {
    set splitList [split $stanleyUserPathname "/"]
    set windowsPath [join $splitList "\\"]
    exec $STANLEY_ROOT/interface/create-stanley-user-dirs.bat \
        $windowsPath $copyBasicClassFilesP 
  }
  popd
  update

  # puts stderr "askNewWorkspaceUpdate: stanleyUserPathname $stanleyUserPathname"
  openWorkspace $stanleyUserPathname [file tail $stanleyUserPathname] $startupP

  # now at least two workspace paths are available to user
  set menuRoot .master.$g_NM_menuStem
  $menuRoot.file.m entryconfigure "Open Workspace" -state normal
  if {([llength [preferred STANLEY_USER_DIR]] > 2) || \
          (([llength [preferred STANLEY_USER_DIR]] == 2) && \
               [string match [preferred projectId] $g_NM_projectId_default])} {
    $menuRoot.file.m entryconfigure "Forget Workspace" -state normal
  }
}


## import an existing workspace tree of populated files
## 13feb01 wmt: new
proc askImportWorkspace { } {
  global HOME g_NM_menuStem g_NM_projectId_default

  set rsvEditsP 1; set startupP 0
  if {[outstandingEditDialogsP $rsvEditsP]} {
    return
  }
  if {[save_dialog]} {
    return
  }
  set currentDir [pwd]
  pushd $currentDir 
  cd $HOME 
  set workspacePathname \
      [tk_chooseDirectory -title "Import Workspace Directory" \
           -parent .master.canvas]
  # puts stderr "askImportWorkspace: workspacePathname $workspacePathname"
  popd

  if {$workspacePathname == ""} {
    # respond to dialog cancel
    return
  }
  # is it a valid Stanley workspace?
  if {(! [file exists $workspacePathname/schematics]) || \
          (! [file exists $workspacePathname/livingstone]) || \
          (! [file exists $workspacePathname/bitmaps]) || \
          (! [file exists $workspacePathname/display-state-color-prefs]) } {
    
    set str "workspace is not valid \n"
    append str "`$workspacePathname'"
    set dialogList [list tk_dialog .d "ERROR" $str \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  foreach workspacePath [preferred STANLEY_USER_DIR] {
    if {[string match $workspacePathname $workspacePath]} {
      set str "Workspace `$workspacePathname' \nalready in Stanley workspace list"
      set dialogList [list tk_dialog .d "ERROR" $str \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
  }

  openWorkspace $workspacePathname [file tail $workspacePathname] $startupP

  # now at least two workspace paths are available to user
  set menuRoot .master.$g_NM_menuStem
  $menuRoot.file.m entryconfigure "Open Workspace" -state normal
  if {([llength [preferred STANLEY_USER_DIR]] > 2) || \
          (([llength [preferred STANLEY_USER_DIR]] == 2) && \
               [string match [preferred projectId] $g_NM_projectId_default])} {
    $menuRoot.file.m entryconfigure "Forget Workspace" -state normal
  }
}


## remove a workspace name form the list of known workspaces
## 26feb01 wmt: new
proc forgetWorkspace { stanleyUserDir workspaceId startupP } {
  global g_NM_menuStem pirPreferences g_NM_projectId_default 

  set menuRoot .master.$g_NM_menuStem
  # current workspace is the first in the list
  # do not forget it
  set oldUserDirList [preferred STANLEY_USER_DIR] 
  set newUserDirList [lindex [preferred STANLEY_USER_DIR] 0]
  foreach workspacePath [lrange [preferred STANLEY_USER_DIR] 1 end] {
    if {! [string match $workspacePath $stanleyUserDir]} {
      lappend newUserDirList $workspacePath
    }
  }
  if {! [string match $oldUserDirList $newUserDirList]} {
    set pirPreferences(STANLEY_USER_DIR) $newUserDirList 
    set userPreferences(STANLEY_USER_DIR) $newUserDirList 
    # write ~/.stanley/userPrefs
    pirSavePreferences user
    # rebuild cascade menus, so that current workspace is not a selection
    destroy $menuRoot.file.m.openWorkspace
    set menuPath [menu $menuRoot.file.m.openWorkspace -tearoff 0]
    buildWorkspaceCascadeMenu "openWorkspace" $menuPath $startupP 
    destroy $menuRoot.file.m.forgetWorkspace
    set menuPath [menu $menuRoot.file.m.forgetWorkspace -tearoff 0]
    buildWorkspaceCascadeMenu "forgetWorkspace" $menuPath $startupP 
    # if only 1 workspace left, disable menu cmds
    if {[llength [preferred STANLEY_USER_DIR]] == 1} {
      $menuRoot.file.m entryconfigure "Open Workspace" -state disabled
    }
    if {([llength [preferred STANLEY_USER_DIR]] == 1) || \
            (([llength [preferred STANLEY_USER_DIR]] == 2) && \
                 (! [string match [preferred projectId] $g_NM_projectId_default]))} {
      $menuRoot.file.m entryconfigure "Forget Workspace" -state disabled

    }
    puts stderr "\nForget Workspace: $stanleyUserDir\n"
  }
}











