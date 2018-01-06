# $Id: defcomponent.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## procs to support visual editing of defcomponent forms


## prompt user for defcomponent information and build pirClassComponent entry
## adapted from askDefmoduleInfo 
## 08jul97 wmt: new
proc askDefcomponentInfo { canvasRootId caller } {
  global g_NM_mkformNodeCompleteP g_NM_classInstance 
  global g_NM_livingstoneDefcomponentName g_NM_currentCanvas
  global g_NM_livingstoneDefcomponentArgList pirDisplay
  global g_NM_livingstoneDefcomponentNameVar pirNode 
  global g_NM_rootInstanceName g_NM_pirClassComponentTemplate 
  global g_NM_mkformNodeUpdatedP g_NM_livingstoneDefcomponentArgTypeList 
  global g_NM_nodeTypeRootWindow pirClassComponent pirClassesComponent

  if {[string match $caller "fileNew"]} {
    ## display defcomponent node
    set mkNodeArgList {}; set nodeConfig {}
    set g_NM_mkformNodeCompleteP 0
    set nodeClassName $g_NM_livingstoneDefcomponentName
    set nodeClassType "component"
    set argsValues {}
    set nodeInstanceName $g_NM_livingstoneDefcomponentNameVar
    set g_NM_rootInstanceName $nodeInstanceName
    set nodeState {}; set internal {}
    acons internal $internal nodeConfig
    lappend mkNodeArgList \
        nodeInstanceName $nodeInstanceName \
        nodeState $nodeState nodeStateBgColor [preferred StanleyModuleNodeBgColor] \
        nodeClassName $nodeClassName numInputs 0 numOutputs 0 \
        fgColor black nodeGroupName "root" parentNodeGroupList "root" \
        nodeClassType $nodeClassType inputs {} outputs {} \
        inputLabels {} outputLabels {}
    set n [mkNode [getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c 100 100 \
               -1 -1 mkNodeArgList $nodeClassType]
    if {$n == -1} {
      error "askDefcomponentInfo: mkNode returned -1"
    }
    if {$canvasRootId == 0} {
      acons input_terminals {} pirNode($n)
      acons output_terminals {} pirNode($n)
      acons port_terminals {} pirNode($n)
      acons attributes {} pirNode($n)
      acons argsValues $argsValues pirNode($n)
      acons numArgsVars [llength $argsValues] pirNode($n)
      ## create pirClassComponent entry
      set internalVars $g_NM_pirClassComponentTemplate 
      set classVars [assoc class_variables internalVars]
      setClassVarDefaultValue args $g_NM_livingstoneDefcomponentArgList classVars
      setClassVarDefaultValue argTypes $g_NM_livingstoneDefcomponentArgTypeList classVars
      arepl class_variables $classVars internalVars 
      if {[lsearch -exact $pirClassesComponent $nodeClassName] == -1} {
        set pirClassComponent($nodeClassName) $internalVars 
        acons nodeClassType $nodeClassType pirClassComponent($nodeClassName)
        lappend pirClassesComponent $nodeClassName
      }
    }

    # open to working level of component
    # puts stderr "askDefcomponentInfo: g_NM_rootInstanceName $g_NM_rootInstanceName"
    set canvasRoot [getCanvasRoot $canvasRootId]
    openNodeGroup $g_NM_rootInstanceName component [assoc window pirNode($n)]
    update
  }
  # set str "askDefcomponentInfo: g_NM_mkformNodeUpdatedP"
  # puts stderr "$str $g_NM_mkformNodeUpdatedP"
  return 
}


## allow user to edit defcomponent parameters and change Stanley data structs
## as necessary
## 08jul97 wmt: new
## 07jan98 wmt: parameterize into three dialogs: nameVarDoc, backModel,
##              & initCond 
proc editDefcomponentParams { dialogType } {
  global g_NM_mkformNodeCompleteP 
  global pirFileInfo pirEdge g_NM_classDefType
  global pirNode g_NM_livingstoneDefcomponentName
  global g_NM_nodeGroupToInstances g_NM_livingstoneDefcomponentNameVar
  global g_NM_livingstoneDefcomponentArgList pirNodes pirEdges
  global g_NM_livingstoneDefcomponentFileName g_NM_rootInstanceName
  global g_NM_argsVarsTranslations g_NM_nodeTypeRootWindow
  global g_NM_instanceToNode g_NM_moduleToNode 
  global g_NM_componentToNode g_NM_nodeGroupToInstances g_NM_canvasList
  global g_NM_termtypeRootWindow g_NM_componentDocInput g_NM_currentNodeGroup
  global g_NM_livingstoneDefcomponentInitMode pirClassComponent pirClassesComponent
  global g_NM_livingstoneDefcomponentArgTypeList g_NM_win32P

  set g_NM_mkformNodeCompleteP 0
  set caller "editDefcomponentParams"
  set oldLivingstoneDefcomponentName $g_NM_livingstoneDefcomponentName
  set pirClassIndex $oldLivingstoneDefcomponentName
  set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
  set oldcomponentDocInput [getClassVarDefaultValue documentation classVars]
  set oldbackgroundDocInput [getClassVarDefaultValue background_documentation \
                                 classVars]
  set oldbackgroundModelInput [getClassVarDefaultValue background_model \
                                   classVars]
  set oldinitially [getClassVarDefaultValue initially classVars]
  set oldinitialMode [getClassVarDefaultValue initial_mode classVars] 

  askLivingstoneDefcomponentParams $dialogType $caller

  if {! $g_NM_mkformNodeCompleteP} {
    return 0
  }
  if {(! [regexp -nocase $oldLivingstoneDefcomponentName \
              $g_NM_livingstoneDefcomponentName]) || \
          ([string length $oldLivingstoneDefcomponentName] != \
               [string length $g_NM_livingstoneDefcomponentName])} {
    ## modify appropriate items in Stanley data structures  
    ## g_NM_livingstoneDefcomponentName is the .scm file name and the .jmpl file name
    set pirFileInfo(filename) $g_NM_livingstoneDefcomponentName
    # non-null g_NM_livingstoneDefcomponentFileName is check in FileSave
    set g_NM_livingstoneDefcomponentFileName $g_NM_livingstoneDefcomponentName

    set defcompName $g_NM_livingstoneDefcomponentName
    set oldDefcompName $oldLivingstoneDefcomponentName
    set defcomponentArgList $g_NM_livingstoneDefcomponentArgList
    set defcomponentArgTypeList $g_NM_livingstoneDefcomponentArgTypeList
    set nameIndexPairs [assoc-array "root" g_NM_nodeGroupToInstances]
    set pirNodeIndex [assoc $g_NM_livingstoneDefcomponentNameVar nameIndexPairs]
    arepl nodeClassName $defcompName pirNode($pirNodeIndex)

    set nameIndexPairs [assoc-array $g_NM_livingstoneDefcomponentNameVar \
                            g_NM_nodeGroupToInstances]
    for {set index 0} {$index < [llength $nameIndexPairs]} {incr index 2} {
      set nodeInstanceName [lindex $nameIndexPairs $index]
      if {[regexp "root" $nodeInstanceName]} {
        set pirNodeIndex [lindex $nameIndexPairs [expr {1 + $index}]]
        arepl nodeClassName $defcompName pirNode($pirNodeIndex)
      }
    }
    set temp $pirClassComponent($oldDefcompName)
    catch { unset pirClassComponent($oldDefcompName) }
    set index [lsearch -exact $pirClassesComponent $oldDefcompName]
    set pirClassesComponent [lreplace $pirClassesComponent $index $index \
                                 $defcompName]
    set pirClassComponent($defcompName) $temp
    set class_variables [assoc class_variables pirClassComponent($defcompName)]
    setClassVarDefaultValue args $defcomponentArgList class_variables
    setClassVarDefaultValue argTypes $defcomponentArgTypeList class_variables
    arepl class_variables $class_variables pirClassComponent($defcompName)

    displayDotWindowTitle

    mark_scm_modified
  }

  set pirClassIndex $g_NM_livingstoneDefcomponentName
  set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
  set newComponentDocInput [getClassVarDefaultValue documentation classVars]
  set newbackgroundDocInput [getClassVarDefaultValue background_documentation \
                                 classVars]
  set newbackgroundModelInput [getClassVarDefaultValue background_model \
                                   classVars]
  set newinitially [getClassVarDefaultValue initially classVars]
  set newinitialMode [getClassVarDefaultValue initial_mode classVars] 
  if {(! [string match $oldcomponentDocInput $newComponentDocInput]) || \
          (! [string match $oldbackgroundDocInput $newbackgroundDocInput]) || \
          (! [string match $oldbackgroundModelInput $newbackgroundModelInput]) || \
          (! [string match $oldinitially $newinitially]) || \
          (! [string match $oldinitialMode $newinitialMode])} {
    mark_scm_modified
  }

  if {[llength $g_NM_argsVarsTranslations] > 0} {
    # puts stderr "editDefcomponentParams: g_NM_argsVarsTranslations $g_NM_argsVarsTranslations"
    if {! $g_NM_win32P} {
      .master.canvas config -cursor { watch red yellow }
      update
    }
    set regsubTransListDot {}; set regsubTransListSpace {}
    set transValueListDot {}; set transValueListSpace {}
    set varsTransArgs {}; set varsTransArgValues {}
    foreach pair $g_NM_argsVarsTranslations {
      set varsTransArgs [concat [lindex $pair 0] $varsTransArgs]
      set varsTransArgValues [concat [lindex $pair 1] $varsTransArgValues]
    }
    buildRegsubVarValueLists varsTransArgs varsTransArgValues \
        regsubTransListDot regsubTransListSpace \
        transValueListDot transValueListSpace 

    # apply new translations to pirClassComponent args, input_terminals,
    # output_terminals, attributes
    set pirClassIndex $g_NM_livingstoneDefcomponentName
    applyRegsub pirClassComponent($pirClassIndex) \
        regsubTransListDot regsubTransListSpace \
        transValueListDot transValueListSpace 

    # for tcl window path substitution
    regsub -all "\\\." $varsTransArgValues "_" varsTransArgValuesTcl
    set regsubTransListDot {}; set regsubTransListSpace {}
    buildRegsubVarValueLists varsTransArgs varsTransArgValuesTcl \
        regsubTransListDot regsubTransListSpace \
        transValueTclListDot transValueTclListSpace 

    # update displyed nodes and links structure
    foreach pirNodeIndex $pirNodes {
      ## apply argsVarsTranslations to pirNode($pirNodeIndex)
      # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to not
      # introduce unwanted . tcl delimiters into paths
      set window [assoc window pirNode($pirNodeIndex)]
      applyRegsub window \
          regsubTransListDot regsubTransListSpace \
          transValueTclListDot transValueTclListSpace 
      applyRegsub pirNode($pirNodeIndex) \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
      arepl window $window pirNode($pirNodeIndex)
    }

    foreach pirEdgeIndex $pirEdges {
      ## apply argsVars/argsValues to pirEdge($pirEdgeIndex)
      # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to not
      # introduce unwanted . tcl delimiters into paths
      set buttonFrom [assoc buttonFrom pirEdge($pirEdgeIndex)]
      applyRegsub buttonFrom \
          regsubTransListDot regsubTransListSpace \
          transValueTclListDot transValueTclListSpace 
      set buttonTo [assoc buttonTo pirEdge($pirEdgeIndex)]
      applyRegsub buttonTo \
          regsubTransListDot regsubTransListSpace \
          transValueTclListDot transValueTclListSpace 
      applyRegsub pirEdge($pirEdgeIndex) \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
      arepl buttonFrom $buttonFrom pirEdge($pirEdgeIndex)
      arepl buttonTo $buttonTo pirEdge($pirEdgeIndex)
    }
    ## apply argsVarsTranslations to g_NM_canvasList 
    applyRegsub g_NM_canvasList \
        regsubTransListDot regsubTransListSpace \
        transValueTclListDot transValueTclListSpace 
    ## apply argsVarsTranslations to g_NM_instanceToNode, g_NM_componentToNode
    ## g_NM_nodeGroupToInstances
    ## convert arrays to lists
    set instanceToNodeAList [array get g_NM_instanceToNode]
    set componentToNodeAList [array get g_NM_componentToNode]
    set moduleToNodeAlist [array get g_NM_moduleToNode]
    set nodeGroupToInstancesAList [array get g_NM_nodeGroupToInstances]
    foreach list [list instanceToNodeAList componentToNodeAList \
                      moduleToNodeAlist nodeGroupToInstancesAList] {
      applyRegsub $list \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
    }
    catch { unset g_NM_instanceToNode g_NM_componentToNode g_NM_moduleToNode \
              g_NM_nodeGroupToInstances }
    array set g_NM_instanceToNode $instanceToNodeAList 
    array set g_NM_componentToNode $componentToNodeAList
    array set g_NM_moduleToNode $moduleToNodeAlist
    array set g_NM_nodeGroupToInstances $nodeGroupToInstancesAList 
    
    # to rename widget hierarchy (e.g. .master.canvas.?name.* => .master.canvas.?new-name.*)
    # and to re-display node labels
    # save schematic and redraw
    set classDefType ""; set classDefName ""; set headerUpdateOnlyP 1
    set errorDialogP 1
    fileSave $classDefType $classDefName $headerUpdateOnlyP
    set absolutePathname "[getSchematicDirectory root $g_NM_classDefType]/"
    append absolutePathname $pirFileInfo(filename)$pirFileInfo(suffix)
    append absolutePathname "-tmp"
    fileOpen $g_NM_classDefType $absolutePathname $errorDialogP $headerUpdateOnlyP 
    # delete this .scm-tmp file,  since it is just a means to rename the widget hierarchy
    file delete $absolutePathname 
    # reset modified since fileSave turns it off
    mark_scm_modified
    # translations have been applied to this schematic, and they are only
    # relevent to this schematic so they should not be propogated to others
    # thru inheritance
    set g_NM_argsVarsTranslations {}
  }
}


## adapted from askLivingstoneDefmoduleParams 
## 08jul97 wmt: new
## 11aug97 wmt: handle viewing of components not at top level
## 07jan98 wmt: parameterize into three dialogs: nameVarDoc, backModel,
##              & initCond 
proc askLivingstoneDefcomponentParams { dialogType caller {xPos -1} {yPos -1} } {
  global g_NM_maxDefcomponentArgs g_NM_livingstoneDefcomponentName
  global g_NM_livingstoneDefcomponentNameVar pirClassComponent
  global g_NM_livingstoneDefcomponentArgList g_NM_classDefType
  global g_NM_mkformComponentDefaultValues g_NM_rootInstanceName
  global g_NM_mkformComponentNumDefaultValues g_NM_currentNodeGroup 
  global g_NM_componentDocInput g_NM_componentBackDocInput
  global g_NM_componentBackModelInput g_NM_componentInitiallyInput
  global g_NM_componentToNode pirNode g_NM_currentCanvas
  global g_NM_nodeTypeRootWindow g_NM_schematicMode
  global g_NM_livingstoneDefcomponentFileName g_NM_mkEntryWidgetWidth
  global g_NM_livingstoneDefcomponentArgTypeList
  global g_NM_readableJavaTokenRegexp g_NM_readableJavaFormRegexp 
  global g_NM_terminalTypeValuesArray g_NM_readableJavaTokenOrQRegexp 
  global g_NM_paletteStructureList g_NM_paletteDefvalueList 

  set structValueTypeList [concat $g_NM_paletteStructureList \
                               $g_NM_paletteDefvalueList <unspecified>]
  set pirNodeIndex [assoc-array [getCanvasRootInfo g_NM_currentNodeGroup] \
                        g_NM_componentToNode]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  if {[string match $g_NM_rootInstanceName \
           [getCanvasRootInfo g_NM_currentNodeGroup]]} {
    set readOnlyP 0; set state normal
    set operation Edit
    set componentClassName $g_NM_livingstoneDefcomponentName 
    if {[string match $g_NM_schematicMode "operational"] || \
            [classDefReadOnlyP component $componentClassName] || \
            [string match $caller "metaDot"]} {
      set readOnlyP 1; set state disabled
      set operation View
      set componentValList [assoc argsValues pirNode($pirNodeIndex)]
      enableViewDialogDeletion
    }
    set componentClassNameVar $g_NM_livingstoneDefcomponentNameVar
    set nodeInstanceName $g_NM_rootInstanceName
    set pirClassIndex $componentClassName
    set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
    set componentArgList $g_NM_livingstoneDefcomponentArgList
    set numAskArgs [expr {[llength $componentArgList] + 2}]
    set numArgs 3
    if {$numAskArgs > $numArgs} {
      set numArgs $numAskArgs
    }
    set componentArgTypeList $g_NM_livingstoneDefcomponentArgTypeList
  } else {
    set readOnlyP 1; set state disabled
    set pirClassIndex [assoc nodeClassName pirNode($pirNodeIndex)]
    set componentClassName $pirClassIndex

    set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
    set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set componentClassNameVar $nodeInstanceName
    set operation View
    enableViewDialogDeletion
    set componentValList [assoc argsValues pirNode($pirNodeIndex)]
    set componentArgList $g_NM_livingstoneDefcomponentArgList
    set numArgs [llength $componentValList]
    set componentArgTypeList [getClassVarDefaultValue argTypes classVars]
  }
  set titleText "$operation Component: "
  if {[string match $dialogType nameVarDoc]} {
    if {[string match $operation "Edit"]} {
      append titleText "Name, Variables, & Documentation"
    } else {
      append titleText "Name, Values, & Documentation"
    }
  } elseif {[string match $dialogType backModel]} {
    append titleText "Background Model"
  } elseif {[string match $dialogType initCond]} {
    append titleText "Initial Conditions"
  } else {
    error "askLivingstoneDefcomponentParams: dialogType $dialogType not handled\!"
  }

  set initP 0
  set dialogW $g_NM_nodeTypeRootWindow.comp${dialogType}_$pirClassIndex
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  set cmd "newLivingstoneDefcomponentParamsUpdate $dialogW $dialogType $numArgs"
  button $dialogW.buttons.ok -text OK -relief raised \
      -command $cmd -state $state
  $dialogW.buttons.ok configure -takefocus 0
  set cmd "mkformNodeCancel $dialogW $initP"
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command $cmd
  $dialogW.buttons.cancel configure -takefocus 0

  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set g_NM_mkformComponentDefaultValues(0) 1
  set g_NM_mkformComponentNumDefaultValues 0

  if {[string match $dialogType nameVarDoc]} {
    frame $dialogW.nameInstVar -bg $bgcolor 
    set widgetInstVar $dialogW.nameInstVar.finstanceVar
    if {[string match $operation "Edit"]} {
      set defaultValue $componentClassNameVar
      if {$defaultValue == ""} {
        set defaultValue "?name"
      }
      set description "Instance Variable"
    } else {
      set defaultValue [getExternalNodeName $nodeInstanceName]
      set description "Instance Name"
    }
    set entryWidth $g_NM_mkEntryWidgetWidth; set takeFocusP 0
    mkEntryWidget $widgetInstVar  "" $description $defaultValue disabled $entryWidth \
        $takeFocusP 
    if {[string match $operation "Edit"]} {
      balloonhelp $widgetInstVar.fentry.entry -side right "read-only" 
      balloonhelp $widgetInstVar.pad.left -side right \
          "<tab> to next field;  <shift-tab> to prev"
    }
    if {! $readOnlyP} {
      incr g_NM_mkformComponentNumDefaultValues
      set g_NM_mkformComponentDefaultValues($g_NM_mkformComponentNumDefaultValues) \
          $defaultValue
    }

    set defaultValue $componentClassName
    if {[string match $g_NM_livingstoneDefcomponentFileName ""] && \
            [string match $operation "Edit"]} {
      set defaultValue ""
    }
    set widgetName $dialogW.nameInstVar.fcomponentName
    if {[string match $operation "Edit"]} {
      set description "Name"
    } else {
      set description "Instance Type"
    }
    mkEntryWidget $widgetName  "" $description $defaultValue $state
    if {[string match $operation "Edit"]} {
      balloonhelp $widgetName.fentry.entry -side right $g_NM_readableJavaTokenRegexp
      balloonhelp $widgetName.pad.left -side right \
          "<tab> to next field;  <shift-tab> to prev"
    }
    if {! $readOnlyP} {
      incr g_NM_mkformComponentNumDefaultValues
      set g_NM_mkformComponentDefaultValues($g_NM_mkformComponentNumDefaultValues) \
          $defaultValue
    }
    pack $widgetInstVar $widgetName -side left -fill x -ipadx 20
    pack $dialogW.nameInstVar -side top -fill x

    set cmdMonTypeP 0
    for {set i 0} {$i < $numArgs} {incr i} {
      frame $dialogW.componentParam$i -bg $bgcolor 
      frame $dialogW.componentParam$i.typeParam
      frame $dialogW.componentParam$i.typeParam.fType -background $bgcolor 
      label $dialogW.componentParam$i.typeParam.fType.typetitle -text \
          "Struct/Value Parameter Type [expr {$i + 1}]" -relief flat -anchor w 
      $dialogW.componentParam$i.typeParam.fType.typetitle configure -takefocus 0

      set defaultParamValue [lindex $componentArgList $i]
      set defaultTypeValue [lindex $componentArgTypeList $i]
      if {$defaultTypeValue == ""} { set defaultTypeValue "<unspecified>" }
      tk_alphaOptionMenuCascade $dialogW.componentParam$i.typeParam.fType.optMenuButton \
          g_NM_optMenuTypeValue_${dialogId}_componentParam$i \
          $defaultTypeValue structValueTypeList $state \
          $cmdMonTypeP $dialogW.componentParam$i
      set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 

      balloonhelp $dialogW.componentParam$i.typeParam.fType.optMenuButton -side right \
          "values: [multiLineList $defaultTypeValue $valuesList values:]"
      pack $dialogW.componentParam$i.typeParam.fType.typetitle \
          $dialogW.componentParam$i.typeParam.fType.optMenuButton \
          -side top -fill x 

      set widgetVar $dialogW.componentParam$i.typeParam.var
      if {[string match $operation "Edit"]} {
        set defaultValue [lindex $componentArgList $i]
        set description "Parameter Variable [expr {$i + 1}]"
      } else {
        set defaultValue [lindex $componentValList $i]
        set description "Parameter Value [expr {$i + 1}]"
      }
      mkEntryWidget $widgetVar "" $description $defaultValue $state 
      if {[string match $operation "Edit"]} {
        balloonhelp $widgetVar.fentry.entry -side right \
            $g_NM_readableJavaTokenOrQRegexp
        balloonhelp $widgetVar.pad.left -side right \
            "<tab> to next field;  <shift-tab> to prev"
      }
      pack $dialogW.componentParam$i.typeParam.fType $widgetVar -side left \
          -fill both -ipadx 20
      pack $dialogW.componentParam$i.typeParam -side top -fill x
      pack $dialogW.componentParam$i -side top -fill x
      if {! $readOnlyP} {
        incr g_NM_mkformComponentNumDefaultValues
        set g_NM_mkformComponentDefaultValues($g_NM_mkformComponentNumDefaultValues) \
            $defaultValue
        incr g_NM_mkformComponentNumDefaultValues
        set g_NM_mkformComponentDefaultValues($g_NM_mkformComponentNumDefaultValues) \
            $defaultTypeValue
      }
    }
  }

  if {[string match $dialogType backModel]} {
    frame $dialogW.bgmodel
    frame $dialogW.bgmodel.ftitle -background $bgcolor
    label $dialogW.bgmodel.ftitle.title -text "Background Model" \
        -relief flat -anchor w 
    $dialogW.bgmodel.ftitle.title configure -takefocus 0
    pack $dialogW.bgmodel.ftitle.title -side left
    pack $dialogW.bgmodel.ftitle -side top -fill both
    pack $dialogW.bgmodel -side top
    set attributeName background_model ; set pirEdgeIndex 0
    if {[string match $g_NM_rootInstanceName \
             [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      set backGndModelDefault [getClassVarDefaultValue $attributeName classVars]
    } else {
      # if parameters are used, then get properly instantiated form from node
      set backGndModelDefault [assoc $attributeName pirNode($pirNodeIndex)]
    }
    set g_NM_componentBackModelInput $backGndModelDefault 
    global g_NM_componentBackModelInput_$dialogId 
    set g_NM_componentBackModelInput_$dialogId $g_NM_componentBackModelInput 
    createEmacsTextWidget $dialogId $dialogW bgmodelEmacs $nodeClassType $attributeName \
        $state $pirEdgeIndex 
    if {[string match $operation "Edit"]} {
      balloonhelp $dialogW.bgmodelEmacs.t -side top $g_NM_readableJavaFormRegexp
    }
  }

  if {[string match $dialogType initCond]} {
    frame $dialogW.initially
#     label $dialogW.initially.spacer -text "" \
#         -relief flat -anchor w 
#     $dialogW.initially.spacer configure -takefocus 0
#     pack $dialogW.initially.spacer -side top -fill both
    frame $dialogW.initially.ftitle -background $bgcolor
    label $dialogW.initially.ftitle.title -text "Initially" \
        -relief flat -anchor w 
    $dialogW.initially.ftitle.title configure -takefocus 0
    pack $dialogW.initially.ftitle.title -side left
    pack $dialogW.initially.ftitle -side top -fill both
    pack $dialogW.initially -side top
    set attributeName initially; set pirEdgeIndex 0
    if {[string match $g_NM_rootInstanceName \
             [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      set initiallyDefault [getClassVarDefaultValue $attributeName classVars]
    } else {
      # if parameters are used, then get properly instantiated form from node
      set initiallyDefault [assoc $attributeName pirNode($pirNodeIndex)]
    }
    set g_NM_componentInitiallyInput $initiallyDefault 
    global g_NM_componentInitiallyInput_$dialogId 
    set g_NM_componentInitiallyInput_$dialogId $g_NM_componentInitiallyInput 
    createEmacsTextWidget $dialogId $dialogW initiallyEmacs $nodeClassType $attributeName \
        $state $pirEdgeIndex 
    if {[string match $operation "Edit"]} {
      balloonhelp $dialogW.initiallyEmacs.t -side top $g_NM_readableJavaFormRegexp 
    }

    frame $dialogW.init
    label $dialogW.init.spacer -text "" -relief flat -anchor w 
    $dialogW.init.spacer configure -takefocus 0
    pack $dialogW.init.spacer -side top -fill both
    pack $dialogW.init -side top -fill x
    set attributeName initial_mode
    set defaultValue [getClassVarDefaultValue $attributeName classVars]
    set widget $dialogW.fcomponentInitialmode
    set description "Initial Mode" 
    mkEntryWidget $widget "" $description $defaultValue $state
    if {[string match $operation "Edit"]} {
      balloonhelp $widget.fentry.entry -side right $g_NM_readableJavaTokenRegexp
    }
  }
  
  if {[string match $dialogType nameVarDoc]} {
    label $dialogW.doctitle -text "Documentation" -relief flat -anchor w 
    $dialogW.doctitle configure -takefocus 0
    pack $dialogW.doctitle -side top -fill both

    set attributeName documentation 
    set g_NM_componentDocInput [getClassVarDefaultValue $attributeName classVars]
    global g_NM_componentDocInput_$dialogId 
    set g_NM_componentDocInput_$dialogId $g_NM_componentDocInput
    createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 
    if {! $readOnlyP} {
      incr g_NM_mkformComponentNumDefaultValues
      set g_NM_mkformComponentDefaultValues($g_NM_mkformComponentNumDefaultValues) \
          $g_NM_componentDocInput 
    }
  }

  if {! [string match $dialogType initCond]} {
    frame $dialogW.doc
    label $dialogW.doc.spacer -text "" -relief flat -anchor w 
    $dialogW.doc.spacer configure -takefocus 0
    pack $dialogW.doc.spacer -side top -fill both
    pack $dialogW.doc -side top -fill x
  }
  
  if {[string match $dialogType nameVarDoc]} {
    focus $dialogW.nameInstVar.fcomponentName.fentry.entry
  }
  keepDialogOnScreen $dialogW $xPos $yPos

  if {[winfo exists $dialogW] && (! [string match $operation "View"])} {
    ## allow tk_focusFollowsMouse to work
    ## grab set $dialogW
    tkwait window $dialogW
  }
}


## process livingstone defcomponent entries
## 05jan96 wmt: new
## 13sep96 wmt: add processing for variable args
## 30apr96 wmt: merge filename and other params
proc newLivingstoneDefcomponentParamsUpdate { dialogW dialogType numParmArgs } {
  global g_NM_mkformNodeCompleteP g_NM_livingstoneDefcomponentPathName
  global g_NM_livingstoneDefcomponentName g_NM_maxDefcomponentArgs
  global g_NM_livingstoneDefcomponentArgList g_NM_fileOperation
  global g_NM_livingstoneDefcomponentNameVar g_NM_mkformNodeUpdatedP
  global g_NM_mkformComponentDefaultValues g_NM_mkformComponentNumDefaultValues
  global pirClassComponent pirNodes pirNode g_NM_classTypes 
  global g_NM_livingstoneDefcomponentFileName g_NM_argsVarsTranslations
  global g_NM_componentDocInput g_NM_componentBackDocInput
  global g_NM_componentBackModelInput g_NM_componentInitiallyInput
  global g_NM_livingstoneDefcomponentArgTypeList
  global g_NM_advisoryRootWindow 

  set dialogId [getDialogId $dialogW]
  set outputMsgP 0
  set defaultValueIndex 0; set g_NM_mkformNodeUpdatedP 0
  set pirClassIndex $g_NM_livingstoneDefcomponentName
  set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
  set oldDefcomponentInitMode [getClassVarDefaultValue initial_mode classVars] 

    set argsVarsTranslations {}
    # component instance variable is always ?name -- it cannot be changed by user
    set defcomponentNameVar ?name
    incr defaultValueIndex
  if {[string match $dialogType nameVarDoc]} {
    set newLivingstoneDefcomponentName \
        [$dialogW.nameInstVar.fcomponentName.fentry.entry get]
    set newLivingstoneDefcomponentName \
        [string trim $newLivingstoneDefcomponentName " "]
    incr defaultValueIndex
    if {! [entryValueErrorCheck "Name" "(javaToken)" $newLivingstoneDefcomponentName]} {
      return
    }
    if {[string match $newLivingstoneDefcomponentName ""]} {
      set dialogList [list tk_dialog .d \
                          "ERROR" "Name not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    set tmpName $newLivingstoneDefcomponentName
    if {[string match $g_NM_fileOperation "fileNew"] || \
            (! [string match $g_NM_livingstoneDefcomponentName \
                    $tmpName])} {
      if {[classDefReadOnlyP component $tmpName]} {
        set str "Definition $tmpName is READ-ONLY"
        set dialogList [list tk_dialog .d "ERROR" $str error \
                            0 {DISMISS}]
        eval $dialogList
        return     
      }
      if {[checkForReservedNames $tmpName]} {
        return
      }
      if {[checkForClassNameConflict $tmpName component]} {
        return
      }
      if {[checkClassInstance component [getInternalNodeName $tmpName] $outputMsgP]} {
        return
      }
    }
    if {! [string match $newLivingstoneDefcomponentName \
               $g_NM_mkformComponentDefaultValues($defaultValueIndex)]} {
      set g_NM_mkformNodeUpdatedP 1
    }

    set defcomponentVarList {}
    set defcomponentVarTypeList {}
    for {set i 0} {$i < $numParmArgs} {incr i} {
      # parameter variable name
      set paramVar [$dialogW.componentParam$i.typeParam.var.fentry.entry get]
      set paramVar [string trim $paramVar " "]
      # parameter variable type
      global g_NM_optMenuTypeValue_${dialogId}_componentParam$i
      set paramType [subst $[subst g_NM_optMenuTypeValue_${dialogId}_componentParam$i]]
      if {($paramVar == "") && ($paramType == "<unspecified>")} {
        # no more parameters
        break
      } elseif {($paramVar != "") && ($paramType == "<unspecified>")} {
        set dialogList [list tk_dialog .d "ERROR" \
                            "`Parameter Type [expr {$i + 1}]' not entered" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      } elseif {($paramVar == "") && ($paramType != "<unspecified>")} {
        set dialogList [list tk_dialog .d "ERROR" \
                            "`Parameter Variable [expr {$i + 1}]' not entered" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      }        
      incr defaultValueIndex
      set fieldName "Parameter Variable [expr {$i + 1}]"
      if {! [entryValueErrorCheck $fieldName "(0-1_?javaToken)" $paramVar]} {
        return
      }
      lappend defcomponentVarList $paramVar 
      set oldVal $g_NM_mkformComponentDefaultValues($defaultValueIndex)
      if {! [string match $oldVal $paramVar]} {
        set g_NM_mkformNodeUpdatedP 1
        if {$oldVal != ""} {
          lappend argsVarsTranslations [list $oldVal $paramVar]
        }
      }
      incr defaultValueIndex
      # puts stderr "newLivingstoneDefcomponentParamsUpdate: paramVar $paramVar paramType $paramType"
      lappend defcomponentVarTypeList $paramType 
      set oldTypeVal $g_NM_mkformComponentDefaultValues($defaultValueIndex)
      # puts stderr "newLivingstoneDefcomponentParamsUpdate: oldVar $oldVal oldType $oldTypeVal"
      if {! [string match $oldTypeVal $paramType]} {
        set g_NM_mkformNodeUpdatedP 1
      }
    }
  }

  if {[string match $dialogType backModel ]} {
    # saveTextWidget puts model into global var
    if {[saveTextWidget $dialogId $dialogW.bgmodelEmacs component background_model \
             (0-n_javaMplForms)]} {
      return
    }
    set modelInput [getTextWidgetText $dialogId component background_model 0]
    terminateJmplForm modelInput 
    setClassVarDefaultValue background_model $modelInput classVars
  }

  if {[string match $dialogType initCond]} {
    # saveTextWidget puts initially into global var
    if {[saveTextWidget $dialogId $dialogW.initiallyEmacs component initially \
             (0-n_javaMplForms)]} {
      return
    }
    set initiallyInput [getTextWidgetText $dialogId component initially 0]
    terminateJmplForm initiallyInput 
    setClassVarDefaultValue initially $initiallyInput classVars

    set newDefcomponentInitMode [$dialogW.fcomponentInitialmode.fentry.entry get]
    set fieldName "Initial Mode"
    if {! [entryValueErrorCheck $fieldName "(0-1_javaToken)" $newDefcomponentInitMode]} {
      return
    }
    if {[string match $newDefcomponentInitMode ""]} {
      set dialogList [list tk_dialog .d \
                          "WARNING" "Initial Mode not entered\nProceed?" \
                          warning -1 {YES} {NO}]
      if {[eval $dialogList] == 1} {
        return
      }
    } else {
      set foundP 0
      foreach pirNodeIndex $pirNodes {
        if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                 mode]} {
          set className [assoc nodeClassName pirNode($pirNodeIndex)]
          set modeName [getExternalNodeName [assoc nodeInstanceName \
                                                   pirNode($pirNodeIndex)]]
          if {[string match $className okMode] && \
                  [string match $modeName $newDefcomponentInitMode]} {
            set foundP 1
            break
          }
        }
      }
      if {! $foundP} {
        set dialogList [list tk_dialog .d "WARNING" \
                            "Initial Mode `$newDefcomponentInitMode' does not exist\nProceed?" \
                            warning -1 {YES} {NO}]
        if {[eval $dialogList] == 1} {
          return
        }
      }
    }
  }

  if {[string match $dialogType nameVarDoc]} {
    # saveTextWidget puts documentation into global vars
    saveTextWidget $dialogId $dialogW.text component documentation (all_characters)
    set docInput [getTextWidgetText $dialogId component documentation 0]
    incr defaultValueIndex
    if {! [string match $docInput \
               $g_NM_mkformComponentDefaultValues($defaultValueIndex)]} {
      set g_NM_mkformNodeUpdatedP 1
    }
  }

  # now that all validity checks are done
  if {[string match $dialogType nameVarDoc]} {
    set g_NM_livingstoneDefcomponentName $newLivingstoneDefcomponentName 
    set g_NM_livingstoneDefcomponentNameVar $defcomponentNameVar 
    set g_NM_livingstoneDefcomponentArgList $defcomponentVarList 
    set g_NM_livingstoneDefcomponentArgTypeList $defcomponentVarTypeList 
    set g_NM_argsVarsTranslations $argsVarsTranslations
    setClassVarDefaultValue documentation $docInput classVars
  }
  if {[string match $dialogType initCond]} {
    setClassVarDefaultValue initial_mode $newDefcomponentInitMode classVars
  }
  arepl class_variables $classVars pirClassComponent($pirClassIndex)

  set g_NM_mkformNodeCompleteP 1
  if {[string match $dialogType nameVarDoc]} {
    if {$g_NM_mkformNodeUpdatedP} {
      mark_scm_modified
    }
    # substitutions in editDefcomponentParams do this automatically
#     if {$argsVarsTranslations != ""} {
#       # user has changed names of parameter variables
#       set str "You have changed one or more parameter variable names.\n"
#       append str "Make changes as appropriate to mode models, background model,\n"
#       append str "initial conditions (initially), and attribute facts."
#       set dialogList [list tk_dialogNoGrab ${g_NM_advisoryRootWindow}.dfailed \
#                           "ADVISORY" $str warning 0 {DISMISS}]
#       eval $dialogList
#     }
  } else {
    # always mark dialogType = backModel & dialogType = initCond as modified
    mark_scm_modified 
  }
  destroy $dialogW
  # slow
  # raiseStanleyWindows 
}


## ask user for info for component modes
## 10jul97 wmt: new
proc askModeInstance { classType className pirNodeIndex caller \
                           {xPos -1} {yPos -1} } {
  global g_NM_rootInstanceName g_NM_nodeTypeRootWindow
  global pirNode g_NM_currentNodeGroup g_NM_schematicMode 
  global g_NM_classDefType g_NM_currentCanvas
  global g_NM_modeDocInput g_NM_modeModelInput
  global g_NM_readableJavaTokenRegexp g_NM_readableJavaFormRegexp

  set dialogW $g_NM_nodeTypeRootWindow.askModeInstance$pirNodeIndex
  # puts stderr "askModeInstance: dialogW $dialogW "
  set dialogId [getDialogId $dialogW]
  set readOnlyP 0; set state normal
  set operation Instantiate
  if {$pirNodeIndex > 0} {
    set operation Edit
  }
  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [string match $g_NM_schematicMode "operational"] || \
          [string match $caller "metaDot"] || \
          [componentModuleDefReadOnlyP]} {
    set readOnlyP 1; set state disabled; set operation View
    enableViewDialogDeletion
  }
  set textClassName OK
  if {[string match $className faultMode]} {
    set textClassName FAULT
  }
  set initP 0
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$operation $textClassName [capitalizeWord $classType] "
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  set command "modeInstanceUpdate $dialogW"
  append command " $className $classType $pirNodeIndex $caller"
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command $command -state $state
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0

  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set g_NM_modeDocInput {}; set g_NM_modeModelInput {}
  set probDefault ""; set nameDefault ""
  if {$pirNodeIndex > 0} {
    # use current values for defaults, rather than last entered in dialog
    set docDefault "\{[assoc nodeDescription pirNode($pirNodeIndex)]\}"
    set g_NM_modeDocInput [string trim $docDefault "\{\}"]
    set modelDefault "\{[assoc model pirNode($pirNodeIndex)]\}"
    set g_NM_modeModelInput [string trim $modelDefault "\{\}"]
    if {[string match $className faultMode]} {
      set probDefault [assoc probability pirNode($pirNodeIndex)]
    }
    set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set nameDefault [getExternalNodeName $nodeInstanceName]
  }
  set widget $dialogW.fName
  set description "Name"
  mkEntryWidget $widget "" $description $nameDefault $state
  if {$operation != "View"} {
    balloonhelp $widget.fentry.entry -side right $g_NM_readableJavaTokenRegexp
  }

  frame $dialogW.model
  frame $dialogW.model.ftitle -background $bgcolor
  label $dialogW.model.ftitle.title -text "Model" -relief flat -anchor w 
  $dialogW.model.ftitle.title configure -takefocus 0
  pack $dialogW.model.ftitle.title -side left
  pack $dialogW.model.ftitle -side top -fill both
  pack $dialogW.model -side top
  set attributeName model; set pirEdgeIndex 0 
  global g_NM_modeModelInput_$dialogId 
  set g_NM_modeModelInput_$dialogId $g_NM_modeModelInput
  createEmacsTextWidget $dialogId $dialogW modelEmacs $classType $attributeName \
      $state $pirEdgeIndex 
  if {$operation != "View"} {
    balloonhelp $dialogW.modelEmacs.t -side top $g_NM_readableJavaFormRegexp
  }

  frame $dialogW.spacer -background $bgcolor 
  label $dialogW.spacer.space -text "" -relief flat -anchor w 
  $dialogW.spacer.space configure -takefocus 0
  pack $dialogW.spacer.space -side top -fill both
  pack $dialogW.spacer -side top -fill both 

  if {[string match $className faultMode]} {
    set widget $dialogW.fProb
    set description "Probability" 
    mkEntryWidget $widget "" $description  $probDefault $state
    if {$operation != "View"} {
      set string $g_NM_readableJavaTokenRegexp
      append string " or\n number: \[0->9\], ., +, -, e"
      balloonhelp $widget.fentry.entry -side right $string
    }
  }

  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w 
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both
  global g_NM_modeDocInput_$dialogId 
  set g_NM_modeDocInput_$dialogId $g_NM_modeDocInput
  set attributeName documentation 
  createTextWidget $dialogId $dialogW $classType $attributeName $state 

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x

  focus $dialogW.fName.fentry.entry
  keepDialogOnScreen $dialogW $xPos $yPos

  if {[winfo exists $dialogW] && (! [string match $operation "View"])} {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    tkwait window $dialogW
  }
}
 

## process defcomponent mode instance
## 27sep96 wmt: new
## 16oct96 wmt: add sticky input values
## 02may97 wmt: add g_NM_optMenuWidgetValue
proc modeInstanceUpdate { dialogW className classType pirNodeIndex caller } {
  global g_NM_mkformNodeCompleteP g_NM_rootInstanceName
  global g_NM_terminalInstance pirNode g_NM_currentCanvas
  global g_NM_classDefType g_NM_modeDocInput g_NM_modeModelInput
  global g_NM_paletteDefsymbolList g_NM_instanceToNode
  global pirClassesSymbol 

  set dialogId [getDialogId $dialogW]
  set reportNotFoundP 0; set silentP 1; set nameDefault ""
  set modeName [$dialogW.fName.fentry.entry get]
  set modeName [string trim $modeName " "]
  if {! [entryValueErrorCheck "Name" "(javaToken)" $modeName]} {
    return
  }
  if {[string match $modeName ""]} {
    set dialogList [list tk_dialog .d "ERROR" "no NAME entered" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  if {$pirNodeIndex > 0} {
    set oldNodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set nameDefault [getExternalNodeName $oldNodeInstanceName]
  }
  set maybeInstanceName "$g_NM_rootInstanceName.$modeName"
  if {($pirNodeIndex == 0) || ($oldNodeInstanceName != $maybeInstanceName)} {
    if {[checkForReservedNames $modeName]} {
      return
    }
    if {[checkForClassNameConflict $modeName mode]} {
      return
    }

    # check that for this class, modeName is not already in use
    set outputMsgP 0
    if {[checkClassInstance $className $maybeInstanceName $outputMsgP]} {
      return
    }
  }

  # saveTextWidget puts model into global var
  if {[saveTextWidget $dialogId $dialogW.modelEmacs mode model (0-n_javaMplForms)]} {
    return
  }
  set modeModel [getTextWidgetText $dialogId mode model 0]
  terminateJmplForm modeModel 
#   if {[string match $modeModel ""]} {
#     set dialogList [list tk_dialog .d "ERROR" "no MODEL entered" \
#                         error 0 {DISMISS}]
#     eval $dialogList
#     return
#   }

  set modeProb ""
  if {[string match $className faultMode]} {
    set modeProb [$dialogW.fProb.fentry.entry get]
    if {[string match $modeProb ""]} {
      set dialogList [list tk_dialog .d "ERROR" "no PROBABILITY entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    if {! [entryValueErrorCheck "Probability" "(javaToken_or_number)" $modeProb]} {
      return
    }
    set alphaP [regsub -nocase -all {^[a-z][A-Z]+} $modeProb "A" formSub]
    if {$alphaP} {
      if {[lsearch -exact $g_NM_paletteDefsymbolList \
               $modeProb] == -1} {
        set dialogList [list tk_dialog .d "ERROR" \
                            "probability `$modeProb' not a SYMBOL definition" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      }
      # convert to numerical value
      set pirClassName $modeProb 
      if {[lsearch -exact $pirClassesSymbol $pirClassName] == -1} {
        read_workspace symbol $pirClassName $silentP
      }
      set classVars [getClassValue symbol $pirClassName class_variables]
      set modeProbNumber [getClassVarDefaultValue form classVars]
      # puts stderr "modeInstanceUpdate: pirClassName $pirClassName modeProbNumber $modeProbNumber"
    } else {
      set modeProbNumber $modeProb 
    }
    if {($modeProbNumber <= 0.0) || ($modeProbNumber >= 1.0)} {
      set str "probability `$modeProbNumber' "
      if {$alphaP} {
        append str "($modeProb) "
      }
      append str "is not > 0.0 and < 1.0"
      set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
      eval $dialogList
      return
    }
    # puts stderr "modeInstanceUpdate: modeProb $modeProb "
  }

  # saveTextWidget puts documentation into global vars
  saveTextWidget $dialogId $dialogW.text $classType documentation (all_characters)
  global g_NM_modeDocInput_$dialogId
  set modeDoc [subst $[subst g_NM_modeDocInput_$dialogId]]

  if {[string match $caller "canvasB1Click"]} {
    set g_NM_terminalInstance [list [getInternalNodeName $modeName] nil \
                                   $modeDoc $modeModel $modeProb]
  } elseif {[string match $caller "mkNode"]} {
    # called by Mouse-R menu binding done in mkNode
    # update the existing node here
    set oldNodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]

    renameClassInstance $oldNodeInstanceName [getInternalNodeName $modeName] \
        $className $pirNodeIndex

    # update propositions menu
    set caller "mkNode"
    set currentNodeGroup [assoc nodeGroupName pirNode($pirNodeIndex)]
    set groupPirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
    set groupNodeClassName [assoc nodeClassName pirNode($groupPirNodeIndex)] 
    set modeAttribute "[assoc nodeInstanceName pirNode($groupPirNodeIndex)]"
    append modeAttribute ".$groupNodeClassName"
    # pass modeAttribute in terminalForm syntax
    set terminalForm [list terminal_name $modeAttribute type [list out mode]]
    modeMouseRightOpsMenu $terminalForm $className $pirNodeIndex $caller \
        $modeName 

    if {[string match $className faultMode]} {
      arepl probability $modeProb pirNode($pirNodeIndex)
    }
    arepl nodeDescription $modeDoc pirNode($pirNodeIndex)
    arepl model "\{$modeModel\}" pirNode($pirNodeIndex)
    
    # update "next" field in transition attribute list of nodes which
    # have connecting transitions, since mode name may
    # have chnaged
    set transitionList [assoc transitions pirNode($pirNodeIndex) \
                            $reportNotFoundP]
    set oldModeName [getExternalNodeName $oldNodeInstanceName]
    foreach transition $transitionList {
      if {[llength $transition] == 4} {
        set startNode [assoc startNode transition]
        set otherTransitionList [assoc transitions pirNode($startNode) \
                                     $reportNotFoundP] 
        set newOtherTransitionList {}
        foreach otherTransition $otherTransitionList {
          if {[llength $otherTransition] > 4} {
            set transitionDefs [assoc defs otherTransition]
            set transitionNames [alist-keys transitionDefs]
            foreach name $transitionNames {
              set transDef [assoc $name transitionDefs]
              set next [assoc next transDef]
              # puts stderr "oldModeName $oldModeName next $next startNode $startNode"
              if {[string match $next $oldModeName]} {
                arepl next $modeName transDef 
                arepl $name $transDef transitionDefs
                arepl defs $transitionDefs otherTransition 
              }
            }
          }
          lappend newOtherTransitionList $otherTransition 
        }
        # puts stderr "newOtherTransitionList $newOtherTransitionList "
        if {[llength $newOtherTransitionList] > 0} {
          arepl transitions $newOtherTransitionList pirNode($startNode)
        }
      }
    }
  } else {
    error "modeInstanceUpdate: caller $caller not handled"
  }

  mark_scm_modified
  set g_NM_mkformNodeCompleteP 1
  # puts stderr "modeInstanceUpdate: destroy dialogW $dialogW "
  destroy $dialogW
  # slow
  # raiseStanleyWindows 
}


## does a transition exist between these two modes
## return 1 if yes, 0 if no
## 17jul97 wmt: new
proc transitionExists { pirNodeIndex startPirNodeIndex stopPirNodeIndex } {
  global pirNode 

  set existsP 0; set reportNotFoundP 0
  set currentEntries [assoc transitions pirNode($pirNodeIndex) \
                          $reportNotFoundP]
  foreach transition $currentEntries {
    if {([assoc startNode transition] == $startPirNodeIndex) && \
            ([assoc stopNode transition] == $stopPirNodeIndex)} {
      set existsP 1
      break
    }
  }
  return $existsP 
}


## does a transition line exist between these two modes
## return 1 if yes, 0 if no
## 17jul97 wmt: new
proc transitionLineExists { pirNodeIndex startPirNodeIndex stopPirNodeIndex } {
  global pirNode 

  set existsP 0; set reportNotFoundP 0
  # puts stderr "transitionLineExists: pirNodeIndex $pirNodeIndex"
  # puts stderr "transitionLineExists: startPirNodeIndex $startPirNodeIndex stopPirNodeIndex $stopPirNodeIndex"
  set currentEntries [assoc transitions pirNode($pirNodeIndex) \
                          $reportNotFoundP]
  foreach transition $currentEntries {
    if {([assoc startNode transition] == $startPirNodeIndex) && \
            ([assoc stopNode transition] == $stopPirNodeIndex) && \
            ([assoc lineId transition] != -1)} {
      set existsP 1
      # puts stderr "transitionLineExists: lineId [assoc lineId transition] existsP $existsP"
      break
    }
  }
  return $existsP 
}


## return transition attributes for start & stop node:
## startNode stopNode lineId arrowId defs
## attribute defs is a list of transition definitions =>
## name { documentation {} when {} next {} cost {} }
## 17jul97 wmt: new
proc getComponentModeTransition { pirNodeIndex startPirNodeIndex \
                                      stopPirNodeIndex transitionRef} {
  upvar $transitionRef transition
  global pirNode 
 
  set reportNotFoundP 0; set returnIndexP 1
  set transitionList [assoc transitions pirNode($pirNodeIndex)\
                         $reportNotFoundP]
  foreach maybeTransition $transitionList {
    if {([assoc startNode maybeTransition] == $startPirNodeIndex) && \
            ([assoc stopNode maybeTransition] == $stopPirNodeIndex)} {
      set transition $maybeTransition
      break
    }
  }
}


## replace transition attribute with value
## this works for toplevel attributes: startNode stopNode lineId arrowId defs
## 17jul97 wmt: new
proc setComponentModeTransition { pirNodeIndex startPirNodeIndex \
                                      stopPirNodeIndex attribute value} {
  global pirNode 
 
  set reportNotFoundP 0; set returnIndexP 1
  set transitionList [assoc transitions pirNode($pirNodeIndex)]
  set newTransitionList {}
  foreach transition $transitionList {
    if {([assoc startNode transition] == $startPirNodeIndex) && \
            ([assoc stopNode transition] == $stopPirNodeIndex)} {
      arepl $attribute $value transition
    }
    lappend newTransitionList $transition 
  }
  arepl transitions $newTransitionList pirNode($pirNodeIndex)
}


## remove transition entry from transitions attribute of mode
## 17jul97 wmt: new
proc removeTransitionEntry { pirNodeIndex startPirNodeIndex stopPirNodeIndex } {
  global pirNode

  set transitionList [assoc transitions pirNode($pirNodeIndex)]
  set newTransitionList {}
  foreach transition $transitionList {
    if {([assoc startNode transition] == $startPirNodeIndex) && \
            ([assoc stopNode transition] == $stopPirNodeIndex)} {
      ; # do not pass this one on to new list
    } else {
      lappend newTransitionList $transition
    }
  }
  arepl transitions $newTransitionList pirNode($pirNodeIndex)
}


## ask user whether to add new def, edit existing def, or delete def
## 18jul97 wmt: new
## 14oct97 wmt: add listbox for list of transitions for startPirNodeIndex 
##              and stopPirNodeIndex; and Emacs overlaid widget to edit
##              code of selected transition (changed to text widget
##              because of CLEAR option
proc editModeTransition { nodeClassType nodeClassName startPirNodeIndex
                          stopPirNodeIndex caller {xPos -1} {yPos -1} } {
  global pirNode g_NM_currentCanvas g_NM_rootInstanceName
  global g_NM_currentNodeGroup g_NM_nodeTypeRootWindow 
  global g_NM_transitionRightCanvasWidth g_NM_transitionRightCanvasHeight
  global g_NM_dialogTransitionSelection g_NM_modeTransitionEditState
  global g_NM_schematicMode 

  set readOnlyP 0; set state normal
  set g_NM_dialogTransitionSelection ""
  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [string match $g_NM_schematicMode "operational"] || \
          [string match $caller "metaDot"] || \
          [componentModuleDefReadOnlyP] } {
    set readOnlyP 1; set state disabled
    enableViewDialogDeletion
  }
  set dialogW $g_NM_nodeTypeRootWindow.editModeTransition
  append dialogW ${startPirNodeIndex}_${stopPirNodeIndex}
  set dialogId [getDialogId $dialogW]
  set initP 0
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  toplevel $dialogW -class Dialog
  if {$readOnlyP} {
    set title "View Transitions" 
  } else {
    set title "Edit Transitions"
  }
  wm title $dialogW $title
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set fromMode [getExternalNodeName \
                    [assoc nodeInstanceName pirNode($startPirNodeIndex)]]
  set toMode [getExternalNodeName \
                    [assoc nodeInstanceName pirNode($stopPirNodeIndex)]]
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  frame $dialogW.pair -bg $bgcolor 
  set leftW [frame $dialogW.pair.left -bd 2 -bg $bgcolor -relief ridge]
  set rightW [frame $dialogW.pair.right -bg $bgcolor]

  frame $leftW.label -bg $bgcolor 
  label $leftW.label.lab1 -text "from $fromMode" -anchor w 
  label $leftW.label.lab2 -text "to      $toMode" -anchor w 
  frame $leftW.label.spacer -bg $bgcolor 
  label $leftW.label.spacer.lab3 -text "                " -anchor w 
  pack $leftW.label.spacer.lab3 -side left
  balloonhelp $leftW.label.spacer.lab3 -side right "select transition from list"
  pack $leftW.label.lab1 $leftW.label.lab2 $leftW.label.spacer -side top -fill x
  pack $leftW.label -side top -fill x

  frame $leftW.listbox -bg $bgcolor  -relief ridge -bd 2
  frame $leftW.listbox.bottom -bg $bgcolor
  listbox $leftW.listbox.lbox -height 10 -width 20 -relief sunken -bd 2 \
      -bg  [preferred StanleyDialogEntryBackgroundColor] \
      -yscrollcommand "$leftW.listbox.yscroll set" \
      -xscrollcommand "$leftW.listbox.bottom.xscroll set" \
      -font [preferred StanleyDialogEntryFont] \
      
  scrollbar $leftW.listbox.yscroll -command "$leftW.listbox.lbox yview" \
      -relief sunk -bd 2  
  scrollbar $leftW.listbox.bottom.xscroll -orient horiz \
      -command "$leftW.listbox.lbox xview" -relief sunk -bd 2 
  pack $leftW.listbox.bottom.xscroll -side left -fill x -expand 1
  pack $leftW.listbox.bottom -side bottom -fill x
  pack $leftW.listbox.yscroll -side right -fill y
  pack $leftW.listbox.lbox -side top -fill x 
  pack $leftW.listbox -side top

  # fill listbox
  set transition {}
  getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex transition
  set nameList {}
  set transitionDefList [assoc defs transition]
  set nameList [alist-keys transitionDefList]
  foreach name $nameList {
    $leftW.listbox.lbox insert 0 $name
  }
  bind $leftW.listbox.lbox <ButtonRelease-1> \
      "dialogSelectTransition $leftW.listbox.lbox $dialogW.buttons $state \
                  $rightW $startPirNodeIndex $stopPirNodeIndex"

  editModeTransitionParams $rightW $nodeClassType $nodeClassName \
      $startPirNodeIndex $stopPirNodeIndex $leftW $dialogId

  set g_NM_modeTransitionEditState(Name) \
      [$rightW.fmodeTransitionname.fentry.entry get]
  set g_NM_modeTransitionEditState(Cost) \
      [$rightW.fmodeTransitioncost.fentry.entry get]
  set g_NM_modeTransitionEditState(Precondition) \
      [$rightW.preconditionEmacs.t get 1.0 end]
  set g_NM_modeTransitionEditState(Documentation) \
      [$rightW.text.t get 1.0 end]
  # buttons
  frame $dialogW.buttons -bg $bgcolor
  button $dialogW.buttons.clear -text CLEAR -relief raised \
      -state $state -command "dialogClearTransition $rightW $state $leftW.listbox.lbox"
  $dialogW.buttons.clear configure -takefocus 0
  balloonhelp $dialogW.buttons.clear -side top "clear the transition template" 

  button $dialogW.buttons.delete -text DELETE -relief raised \
      -state disabled \
      -command "dialogDeleteTransition $leftW.listbox.lbox $dialogW.buttons \
                        $startPirNodeIndex $stopPirNodeIndex $rightW"
  $dialogW.buttons.delete configure -takefocus 0
  balloonhelp $dialogW.buttons.delete -side top "delete the selected transition" 

  button $dialogW.buttons.save -text SAVE -relief raised -state $state \
      -command "dialogSaveTransition $dialogW $dialogW.buttons $state $rightW \
                        $nodeClassType $nodeClassName $startPirNodeIndex \
                        $stopPirNodeIndex $leftW.listbox.lbox"
  $dialogW.buttons.save configure -takefocus 0
  balloonhelp $dialogW.buttons.save -side top "save the transition" 

  button $dialogW.buttons.exit -text EXIT -relief raised \
      -command "dialogExitTransition $dialogW $dialogW.buttons $state $rightW \
                        $nodeClassType $nodeClassName $startPirNodeIndex \
                        $stopPirNodeIndex $leftW.listbox.lbox $initP"
  $dialogW.buttons.exit configure -takefocus 0
  balloonhelp $dialogW.buttons.exit -side top "exit dialog" 

  pack $dialogW.buttons.clear $dialogW.buttons.delete $dialogW.buttons.save \
      $dialogW.buttons.exit -side left -padx 5m -ipadx 2m

  pack $dialogW.pair.left -side left -fill y
  pack $dialogW.pair.right -side right -fill both -expand 1
  pack $dialogW.pair -side top -fill both -expand 1
  pack $dialogW.buttons -side top 

  keepDialogOnScreen $dialogW $xPos $yPos
}


## save listbox selection of transition
## 14oct97 wmt: new
proc dialogSelectTransition { selectWidgetPath buttonWidgetPath state \
                                  rightW startPirNodeIndex stopPirNodeIndex } {
  global g_NM_dialogTransitionSelection g_NM_modeTransitionEditState 

  set index [$selectWidgetPath curselection]
  if {$index == ""} {
    return
  }
  set name [$selectWidgetPath get $index]

  if {[string match $state normal]} {
    # enable delete save buttons
    $buttonWidgetPath.delete configure -state normal
  }
  dialogClearTransition $rightW $state ""
  # fill right side of dialog with transition selected
  set transition {}
  getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex transition
  set transitionDefList [assoc defs transition]
  set transitionDef [assoc $name transitionDefList]
  set cost [assoc cost transitionDef]
  set precondition [assoc when transitionDef]
  set doc [assoc documentation transitionDef]
  if {[string match $state disabled]} {
    $rightW.fmodeTransitionname.fentry.entry config -state normal
    $rightW.fmodeTransitioncost.fentry.entry config -state normal 
    $rightW.preconditionEmacs.t config -state normal 
    $rightW.text.t config -state normal 
  }
  $rightW.fmodeTransitionname.fentry.entry insert 0 $name
  $rightW.fmodeTransitioncost.fentry.entry insert 0 $cost
  $rightW.preconditionEmacs.t insert 0.0 $precondition 
  $rightW.text.t insert 0.0 $doc
  if {[string match $state disabled]} {
    $rightW.fmodeTransitionname.fentry.entry config -state disabled
    $rightW.fmodeTransitioncost.fentry.entry config -state disabled
    $rightW.preconditionEmacs.t config -state disabled
    $rightW.text.t config -state disabled
  }
  # ensure that  $rightW.fmodeTransitionname.fentry.entry, etc
  # get updated prior to using their values
  update
  set g_NM_dialogTransitionSelection $name
  set g_NM_modeTransitionEditState(Name) \
      [$rightW.fmodeTransitionname.fentry.entry get]
  set g_NM_modeTransitionEditState(Cost) \
      [$rightW.fmodeTransitioncost.fentry.entry get ]
  set g_NM_modeTransitionEditState(Precondition) \
      [$rightW.preconditionEmacs.t get 1.0 end]
  set g_NM_modeTransitionEditState(Documentation) \
      [$rightW.text.t get 1.0 end]
}


## give user clear transition template
## 14oct97 wmt: new
proc dialogClearTransition { rightW state listboxWidgetPath } { 
  global g_NM_dialogTransitionSelection
  global g_NM_modeTransitionEditState

  if {[string match $state disabled]} {
    $rightW.fmodeTransitionname.fentry.entry config -state normal
    $rightW.fmodeTransitioncost.fentry.entry config -state normal 
    $rightW.preconditionEmacs.t config -state normal 
    $rightW.text.t config -state normal 
  }
  $rightW.fmodeTransitionname.fentry.entry delete 0 end
  $rightW.fmodeTransitioncost.fentry.entry delete 0 end
  $rightW.preconditionEmacs.t delete 0.0 end
  $rightW.text.t delete 0.0 end
  if {[string match $state disabled]} {
    $rightW.fmodeTransitionname.fentry.entry config -state disabled
    $rightW.fmodeTransitioncost.fentry.entry config -state disabled
    $rightW.preconditionEmacs.t config -state disabled
    $rightW.text.t config -state disabled
  }
  if {! [string match $listboxWidgetPath ""]} {
    set g_NM_dialogTransitionSelection ""
    $listboxWidgetPath selection clear 0 end
  }
  set g_NM_modeTransitionEditState(Name) ""
  set g_NM_modeTransitionEditState(Cost) ""
  set g_NM_modeTransitionEditState(Precondition) "\n"
  set g_NM_modeTransitionEditState(Documentation) "\n"
}


## save an edited transition, but do not exit
## 14oct97 wmt: new
proc dialogSaveTransition { dialogW buttonWidgetPath state rightW nodeClassType \
                             nodeClassName startPirNodeIndex \
                             stopPirNodeIndex selectWidgetPath } {
  global g_NM_dialogTransitionSelection
  global g_NM_modeTransitionEditState

  set operation Save
  editModeTransitionParamsUpdate $dialogW $rightW \
      $startPirNodeIndex $stopPirNodeIndex $selectWidgetPath $operation

  set g_NM_modeTransitionEditState(Name) \
      [$rightW.fmodeTransitionname.fentry.entry get]
  set g_NM_modeTransitionEditState(Cost) \
      [$rightW.fmodeTransitioncost.fentry.entry get ]
  set g_NM_modeTransitionEditState(Precondition) \
      [$rightW.preconditionEmacs.t get 1.0 end]
  set g_NM_modeTransitionEditState(Documentation) \
      [$rightW.text.t get 1.0 end]
}


## exit after checking for unsaved work
## 22feb98 wmt: new
proc dialogExitTransition { dialogW buttonWidgetPath state rightW nodeClassType \
                                nodeClassName startPirNodeIndex \
                                stopPirNodeIndex selectWidgetPath initP } {
  global g_NM_modeTransitionEditState 

#   puts stderr "dialogExitTransition: Name `$g_NM_modeTransitionEditState(Name)' \
#       `[$rightW.fmodeTransitionname.fentry.entry get]'"
#   puts stderr "dialogExitTransition: Cost `$g_NM_modeTransitionEditState(Cost)' \
#       `[$rightW.fmodeTransitioncost.fentry.entry get]'"
#   puts stderr "dialogExitTransition: Precondition `$g_NM_modeTransitionEditState(Precondition)' \
#       `[$rightW.preconditionEmacs.t get 1.0 end]'"
#   puts stderr "dialogExitTransition: Documentation `$g_NM_modeTransitionEditState(Documentation)' \
#       `[$rightW.text.t get 1.0 end]'"

  if {(! [string match $g_NM_modeTransitionEditState(Name) \
              [$rightW.fmodeTransitionname.fentry.entry get]]) || \
          (! [string match $g_NM_modeTransitionEditState(Cost) \
                  [$rightW.fmodeTransitioncost.fentry.entry get]]) || \
          (! [string match $g_NM_modeTransitionEditState(Precondition) \
                  [$rightW.preconditionEmacs.t get 1.0 end]]) || \
          (! [string match $g_NM_modeTransitionEditState(Documentation) \
                  [$rightW.text.t get 1.0 end]])} {
    set dialogList [list tk_dialog .d "WARNING" \
                        "Do you want to save your changes?" warning \
                        -1 {SAVE} {DISCARD} {CANCEL}]
    set response [eval $dialogList]
    if {$response == 0} {
      
      dialogSaveTransition $dialogW $buttonWidgetPath $state $rightW $nodeClassType \
          $nodeClassName $startPirNodeIndex $stopPirNodeIndex $selectWidgetPath
    } elseif {$response == 2} {
      return
    }
  }
  # reset global values
  set g_NM_modeTransitionEditState(Name) ""
  set g_NM_modeTransitionEditState(Cost) ""
  set g_NM_modeTransitionEditState(Precondition) "\n"
  set g_NM_modeTransitionEditState(Documentation) "\n"
  # force balloon help to be hidden
  event generate $dialogW.buttons.exit <Leave>
  mkformNodeCancel $dialogW $initP
}


## delete an existing transition
## 14oct97 wmt: new
proc dialogDeleteTransition { selectWidgetPath buttonWidgetPath startPirNodeIndex \
                                  stopPirNodeIndex rightW } {
  global g_NM_dialogTransitionSelection

  set state normal; # delete is only enabled when state = normal
  if {! [string match $g_NM_dialogTransitionSelection ""]} {
    set transition {}
    getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
        $stopPirNodeIndex transition
    set transitionDefList [assoc defs transition]
    adel $g_NM_dialogTransitionSelection transitionDefList 
    setComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
        $stopPirNodeIndex defs $transitionDefList

    # update listbox list of transitions
    set index [$selectWidgetPath curselection]
    $selectWidgetPath delete $index

    dialogClearTransition $rightW $state ""

    $buttonWidgetPath.delete configure -state disabled

    mark_scm_modified
    if {[llength $transitionDefList] == 0} {
      cutModeTransition [getCanvasRootInfo g_NM_currentCanvas].c \
          $startPirNodeIndex $stopPirNodeIndex
    }
  } else {
    bell
  }
}


## edit parameters of a mode transition
## name documentation when next cost
## 18jul97 wmt: new
## 14oct97 wmt: modified to be a sub-widget
proc editModeTransitionParams { rightW nodeClassType nodeClassName \
                                    startPirNodeIndex stopPirNodeIndex \
                                    leftW dialogId } {
  global pirNode g_NM_mkEntryWidgetWidth g_NM_rootInstanceName 
  global g_NM_modeTransitionDocInput g_NM_modeTransitionPreconditionInput
  global g_NM_currentNodeGroup g_NM_currentCanvas g_NM_nodeTypeRootWindow
  global g_NM_transitionRightCanvasWidth g_NM_transitionRightCanvasHeight
  global g_NM_dialogTransitionSelection g_NM_readableJavaTokenRegexp
  global g_NM_readableJavaFormRegexp

  set readOnlyP 0; set state normal
  if {! [string match $g_NM_rootInstanceName \
             [getCanvasRootInfo g_NM_currentNodeGroup]]} {
    set readOnlyP 1; set state disabled
  }
  set g_NM_modeTransitionDocInput {}
  set g_NM_modeTransitionPreconditionInput {}
  set reportNotFoundP 0; set initP 0
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $rightW config -bg $bgcolor

  set transition {}; set transitionDef {}
  if {! [string match $g_NM_dialogTransitionSelection ""]} {
    getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
        $stopPirNodeIndex transition
    set transitionDefList [assoc defs transition]
    set transitionDef [assoc $g_NM_dialogTransitionSelection transitionDefList]
    set defaultName $g_NM_dialogTransitionSelection
  } else {
    set defaultName ""
  }
  set widget $rightW.fmodeTransitionname
  set description "Name"
  mkEntryWidget $widget "" $description $defaultName $state
  balloonhelp $widget.fentry.entry -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"

  set cost [assoc cost transitionDef $reportNotFoundP]
  set widget $rightW.fmodeTransitioncost
  set description "Cost"
  mkEntryWidget $widget "" $description $cost $state
  balloonhelp $widget.fentry.entry -side right "number: \[0->9\], ."
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"

  frame $rightW.precondition
  frame $rightW.precondition.ftitle -background $bgcolor
  label $rightW.precondition.ftitle.title -text "Precondition" \
      -relief flat -anchor w 
  $rightW.precondition.ftitle.title configure -takefocus 0
  pack $rightW.precondition.ftitle.title -side left
  pack $rightW.precondition.ftitle -side top -fill both
  pack $rightW.precondition -side top
  set attributeName precondition
  set preconditionInput [assoc when transitionDef $reportNotFoundP]
  set g_NM_modeTransitionPreconditionInput $preconditionInput
  global g_NM_modeTransitionPreconditionInput_$dialogId 
  set g_NM_modeTransitionPreconditionInput_$dialogId \
      $g_NM_modeTransitionPreconditionInput
  createEmacsTextWidget $dialogId $rightW preconditionEmacs $nodeClassType $attributeName \
      $state 0
  balloonhelp $rightW.preconditionEmacs.t -side top $g_NM_readableJavaFormRegexp

  frame $rightW.doc
  label $rightW.doc.spacer -text "" -relief flat -anchor w 
  $rightW.doc.spacer configure -takefocus 0
  label $rightW.doc.title -text "Documentation" -relief flat -anchor w 
  $rightW.doc.title configure -takefocus 0
  pack $rightW.doc.spacer $rightW.doc.title -side top -fill both
  pack $rightW.doc -side top
  set attributeName documentation
  set g_NM_modeTransitionDocInput [assoc documentation transitionDef \
                                       $reportNotFoundP]
  global g_NM_modeTransitionDocInput_$dialogId 
  set g_NM_modeTransitionDocInput_$dialogId $g_NM_modeTransitionDocInput
  createTextWidget $dialogId $rightW $nodeClassType $attributeName $state 

  frame $rightW.sp
  label $rightW.sp.spacer -text "" -relief flat -anchor w 
  $rightW.sp.spacer configure -takefocus 0
  pack $rightW.sp.spacer -side top -fill both
  pack $rightW.sp -side top -fill x

  focus $rightW.fmodeTransitionname.fentry.entry
}


## process component mode transition parameters
## 18jul97 wmt: new
proc editModeTransitionParamsUpdate { dialogW rightW startPirNodeIndex stopPirNodeIndex \
                                          selectWidgetPath operation } {
  global g_NM_mkformNodeCompleteP pirNode g_NM_dialogTransitionSelection
  global g_NM_modeTransitionDocInput g_NM_modeTransitionPreconditionInput

  set outputMsgP 0
  set dialogId [getDialogId $dialogW]
  set newTransitionDefName [$rightW.fmodeTransitionname.fentry.entry get]
  set newTransitionDefName [string trim $newTransitionDefName " "]
  if {[string match $newTransitionDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "no NAME entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {! [entryValueErrorCheck "Name" "(javaToken)" $newTransitionDefName]} {
    return
  }
  if {($g_NM_dialogTransitionSelection == "") || \
          ($g_NM_dialogTransitionSelection != $newTransitionDefName)} {
    if {[checkForReservedNames $newTransitionDefName]} {
      return
    }
    if {[checkForClassNameConflict $newTransitionDefName transition]} {
      return
    }
    set maybeInstanceName [getInternalNodeName $newTransitionDefName]
    if {[checkClassInstance transition $maybeInstanceName $outputMsgP]} {
      return
    }
  }

  set nextMode [getExternalNodeName \
                    [assoc nodeInstanceName pirNode($stopPirNodeIndex)]]
  set transition {}
  getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex transition
  set transitionDefList [assoc defs transition]
  if {((! [string match $g_NM_dialogTransitionSelection ""]) && \
           (! [string match $g_NM_dialogTransitionSelection \
                   $newTransitionDefName])) || \
          [string match $g_NM_dialogTransitionSelection ""]} {
    set nameList [alist-keys transitionDefList]
    if {[lsearch -exact $nameList $newTransitionDefName] >= 0} {
      set msg "`$newTransitionDefName' exists for this transition" 
      set dialogList [list tk_dialog .d \
                          "ERROR" $msg error 0 {DISMISS}]
      eval $dialogList
      return
    }
  }

  set newTransitionCost  [$rightW.fmodeTransitioncost.fentry.entry get]
  if {[string match $newTransitionCost ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "no COST entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {! [entryValueErrorCheck "Cost" "(number)" $newTransitionCost]} {
    return
  }

  # saveTextWidget puts precondition into global var
  if {[saveTextWidget $dialogId $rightW.preconditionEmacs transition precondition \
           (0-n_javaMplForms)]} {
    return
  }
  set preconditionInput [getTextWidgetText $dialogId transition precondition 0]
  terminateJmplForm preconditionInput 

  # update transitions listbox
  if {((! [string match $g_NM_dialogTransitionSelection ""]) && \
           (! [string match $g_NM_dialogTransitionSelection \
                   $newTransitionDefName])) || \
          [string match $g_NM_dialogTransitionSelection ""]} {
    $selectWidgetPath selection clear 0 end
    set index [$selectWidgetPath index end] 
    $selectWidgetPath insert end $newTransitionDefName
    $selectWidgetPath selection set $index end
  }
  
  # saveTextWidget puts documentation into global var
  saveTextWidget $dialogId $rightW.text transition documentation (all_characters)
  set docInput [getTextWidgetText $dialogId transition documentation 0]

  set transitionDef [list documentation $docInput \
                         when $preconditionInput \
                         next $nextMode \
                         cost $newTransitionCost]
  set reportNotFoundP 0; set oldvalMustExistP 0
  arepl $newTransitionDefName $transitionDef transitionDefList \
          $reportNotFoundP $oldvalMustExistP 
  setComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex defs $transitionDefList

  if {[string match $operation Ok]} {
    destroy $dialogW
  }
  set g_NM_mkformNodeCompleteP 1 
  mark_scm_modified
  ## very slow
  ## raiseStanleyWindows
}


## erase transition arrow and line, unless this is a double
## transition
## 17jul97 wmt: new
proc cutModeTransition { canvas startPirNodeIndex stopPirNodeIndex \
                             { moveTransitionP 0 } } {
  global pirDisplay pirNode 

  set reportNotFoundP 0
  arepl selectedTransition {} pirDisplay $reportNotFoundP
  # .master.menus_accels.menu.links.m entryconfigure "Delete Connection" -state disabled
  set transition {}
  getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex transition
  set arrowId [assoc arrowId transition]
  set tags [$canvas gettags $arrowId]
  if {[lsearch -exact $tags transitionArrow] >= 0} {
    # puts stderr "cutModeTransition: delete arrowId $arrowId"
    $canvas delete $arrowId
    set lineId [assoc lineId transition]
    if {$lineId != -1} {
      if {(! [transitionExists $stopPirNodeIndex $stopPirNodeIndex \
                  $startPirNodeIndex]) || $moveTransitionP} {
        # puts stderr "cutModeTransition: delete lineId $lineId"
        $canvas delete $lineId
      } elseif {! $moveTransitionP} {
        # move lineId to other transition
        setComponentModeTransition $stopPirNodeIndex $stopPirNodeIndex \
            $startPirNodeIndex lineId $lineId 
      }
    }
    if {! $moveTransitionP} {
      removeTransitionEntry $startPirNodeIndex $startPirNodeIndex \
          $stopPirNodeIndex
      removeTransitionEntry $stopPirNodeIndex $startPirNodeIndex \
          $stopPirNodeIndex
    }
  }
}


## delete all the transitions of a mode
## 10sep97 wmt: new
proc deleteAllModeTransitions { transitionListRef } {
  upvar $transitionListRef transitionList
  global pirNodes

  set reportNotFoundP 0
  # puts stderr "deleteAllModeTransitions: transitionList $transitionList"
  foreach transition $transitionList {
    # puts stderr "deleteAllModeTransitions: transition $transition"
    set startPirNodeIndex [assoc startNode transition]
    set stopPirNodeIndex [assoc stopNode transition]
    set transition {}
    if {([lsearch -exact $pirNodes $startPirNodeIndex] >= 0) && \
            ([lsearch -exact $pirNodes $stopPirNodeIndex] >= 0)} {
      # set str "deleteAllModeTransitions: startPirNodeIndex $startPirNodeIndex"
      # puts stderr "$str stopPirNodeIndex $stopPirNodeIndex"
      getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
          $stopPirNodeIndex transition
      set nameList {}
      set transitionDefs [assoc defs transition $reportNotFoundP]
      foreach selectedName [alist-keys transitionDefs] {
        # delete existing definition
        adel $selectedName transitionDefs
        setComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
            $stopPirNodeIndex defs $transitionDefs
        if {[llength $transitionDefs] == 0} {
          cutModeTransition [getCanvasRootInfo g_NM_currentCanvas].c \
              $startPirNodeIndex $stopPirNodeIndex
        }
      }
    }
  }
}


## unhighlight unless this transition has been selected
## 17jul97 wmt: new
proc highlightModeTransition { arrowCanvas arrowId startPirNodeIndex \
                                 stopPirNodeIndex } {
  global pirDisplay g_NM_rootInstanceName g_NM_schematicMode 

  set reportNotFoundP 0; set returnIndexP 1
  set dehighlightP 1
  set returnIndex [assoc selectedTransition pirDisplay \
                       $reportNotFoundP $returnIndexP]
  if {$returnIndex != -1} {
    set transition [assoc selectedTransition pirDisplay]
    if {([lindex $transition 0] == $startPirNodeIndex) && \
            ([lindex $transition 1] == $stopPirNodeIndex)} {
      set dehighlightP 0
    }
  }
  if {$dehighlightP} {
    set color [assoc selectColor pirDisplay] 
    $arrowCanvas itemconfigure $arrowId -fill $color
  }
  set operation edit
  if {(! [string match $g_NM_rootInstanceName \
              [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [string match $g_NM_schematicMode "operational"] || \
          [componentModuleDefReadOnlyP] } {
    set operation view
  }
  set msg "<Mouse-R menu>: $operation transitions"
  set msg2 ""; set severity 0
  pirWarning $msg $msg2 $severity [getCanvasRootId $arrowCanvas tmp]
}


## highlight unless this transition has been selected
## 17jul97 wmt: new
proc dehighlightModeTransition { arrowCanvas arrowId startPirNodeIndex \
                                   stopPirNodeIndex } {
  global pirDisplay 

  set reportNotFoundP 0; set returnIndexP 1
  set dehighlightP 1
  set returnIndex [assoc selectedTransition pirDisplay \
                       $reportNotFoundP $returnIndexP]
  if {$returnIndex != -1} {
    set transition [assoc selectedTransition pirDisplay]
    if {([lindex $transition 0] == $startPirNodeIndex) && \
            ([lindex $transition 1] == $stopPirNodeIndex)} {
      set dehighlightP 0
    }
  }
  if {$dehighlightP} {
    set color [preferred StanleyModeTransitionBgColor] 
    $arrowCanvas itemconfigure $arrowId -fill $color
  }
}


## 17jul97 wmt: new
proc selectModeTransition { arrowCanvas arrowId startPirNodeIndex \
                              stopPirNodeIndex } {
  global pirDisplay 

  # if another transition is selected, deselect it
  deselectModeTransition $arrowCanvas 

  set reportNotFoundP 0; set oldvalMustExistP 0
  $arrowCanvas itemconfigure $arrowId -fill black
  arepl selectedTransition [list $startPirNodeIndex $stopPirNodeIndex] \
      pirDisplay $reportNotFoundP $oldvalMustExistP
  # .master.menus_accels.menu.links.m entryconfigure "Delete Connection" -state normal
  # focus -force .master.menus_accels.menu
}


## 17jul97 wmt: new
proc deselectModeTransition { canvas } {
  global pirDisplay pirNode

  set reportNotFoundP 0; set returnIndexP 1; set transition {}
  set returnIndex [assoc selectedTransition pirDisplay \
                       $reportNotFoundP $returnIndexP]
  if {$returnIndex != -1} {
    set selectedTransition [assoc selectedTransition pirDisplay]
    if {! [string match $selectedTransition ""]} {
      getComponentModeTransition [lindex $selectedTransition 0] \
          [lindex $selectedTransition 0] \
          [lindex $selectedTransition 1] transition 
      set color [preferred StanleyModeTransitionBgColor] 
      set arrowId [assoc arrowId transition]
      set tags [$canvas gettags $arrowId]
      if {[string match $tags transitionArrow]} {
        $canvas itemconfigure $arrowId -fill $color
        arepl selectedTransition {} pirDisplay $reportNotFoundP
        # .master.menus_accels.menu.links.m entryconfigure "Delete Connection" \
        #   -state disabled
      }
    }
  }
}


## move mode transitions, after mode has been moved by user
## 17jul97 wmt: new
proc moveModeTransitions { canvas pirNodeIndex } {
  global pirNode

  set reportNotFoundP 0; set moveTransitionP 1
  set transitionsList [assoc transitions pirNode($pirNodeIndex) \
                           $reportNotFoundP]
  foreach transition $transitionsList {

    cutModeTransition $canvas [assoc startNode transition] \
        [assoc stopNode transition] $moveTransitionP
    # this line will not be removed by cutModeTransition
    set lineId [assoc lineId transition $reportNotFoundP]
    if {($lineId != -1) && (! [string match $lineId ""])} {
      $canvas delete $lineId
    }
  }
  set arrowIdList {}
  foreach transition $transitionsList {
    set startNode [assoc startNode transition]
    set stopNode [assoc stopNode transition]
    # set str "moveModeTransitions: pirNodeIndex $pirNodeIndex startNode"
    # puts stderr "$str $startNode stopNode $stopNode"

    drawModeTransition $canvas [assoc window pirNode($startNode)] \
        [assoc window pirNode($stopNode)] lineId arrowId \
        $startNode $stopNode
    lappend arrowIdList $arrowId 
    # puts stderr "moveModeTransitions: lineId $lineId arrowId $arrowId"
    setComponentModeTransition $startNode $startNode $stopNode \
        lineId $lineId 
    setComponentModeTransition $startNode $startNode $stopNode \
        arrowId $arrowId
  }
  # if arrow is overlapped by line , raise it to top
  foreach arrowId $arrowIdList {
    $canvas raise $arrowId
  }
}


## interpret a dragging motion with Button 2, starting in a node
## of type mode, as an line draw operation
## 11jul97 wmt: adapted from canvasB1StartMotion 
proc modeB2StartMotion {c winpath x y pirNodeIndex} {
  global pirWireFrame g_NM_transitionStartPirIndex

  set g_NM_transitionStartPirIndex $pirNodeIndex
  # x, y: mouse position referenced to upper left corner of winpath.lab
  # pirWireFrame(x), pirWireFrame(y): center of winpath referenced to 
  # canvas uppper left corner
  $c delete wire
  set pirWireFrame(curX) $x
  set pirWireFrame(curY) $y
  disableSelectionMenus
  # canvas x,y for line start
  set pirWireFrame(x) 0; set pirWireFrame(y) 0
  set deltaX 0; set deltaY 0
  getWidgetCenter $winpath pirWireFrame(x) pirWireFrame(y) deltaX deltaY 
  scan [winfo geometry "$winpath.lab"] "%dx%d+%d+%d" width height xx yy
  set pirWireFrame(deltaX) [expr {$deltaX - $xx}]
  set pirWireFrame(deltaY)  [expr {$deltaY - $yy}]
  # puts stderr "modeB2StartMotion c $c winpath $winpath x $x y $y"
  # puts stderr "pirWireFrame(x) $pirWireFrame(x) pirWireFrame(y) $pirWireFrame(y)"
  # puts stderr "deltaX $deltaX deltaY $deltaY"
}


## 14jul97 wmt: handle node type = mode transition line drawing
proc modeB2Motion {c winpath x y} {
  global pirWireFrame g_NM_transitionStartPirIndex
  global g_NM_rootInstanceName 

  # x, y: mouse position referenced to upper left corner of winpath.lab
  # pirWireFrame(x), pirWireFrame(y): center of winpath referenced to 
  # canvas uppper left corner
  # puts stderr "modeB2Motion $c x $x y $y"
  if {$g_NM_transitionStartPirIndex == 0} {
    return
  }
  if {($pirWireFrame(curX) != $x) && ($pirWireFrame(curY) != $y)} {
    $c delete wire
    set xx [expr {$pirWireFrame(x) + $x - $pirWireFrame(deltaX)}]
    set yy [expr {$pirWireFrame(y) + $y - $pirWireFrame(deltaY)}]
    if {(! [componentModuleDefReadOnlyP]) && \
            [string match $g_NM_rootInstanceName \
                 [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      $c addtag wire withtag [$c create line \
                                  $pirWireFrame(x) \
                                  $pirWireFrame(y) $xx $yy \
                                  -fill [preferred StanleyRubberBandColor]]
    }
  }
}

 
## draw directional line from start transition to node found at
## x,y -- if none found, erase line
## 14jul97 wmt: new
proc modeB2Release {canvas winpath x y} {
  global g_NM_transitionStartPirIndex pirWireFrame
  global pirNode g_NM_nodeTypeRootWindow g_NM_rootInstanceName 

  set caller "modeB2Release"
  if {[componentModuleDefReadOnlyP] || \
          (! [string match $g_NM_rootInstanceName \
                  [getCanvasRootInfo g_NM_currentNodeGroup]])} {
    return
  }
  # set str "modeB2Release: g_NM_transitionStartPirIndex"
  # puts stderr "$str $g_NM_transitionStartPirIndex"
  if {$g_NM_transitionStartPirIndex == 0} {
    return
  }
  set reportNotFoundP 0
  set xx [expr {$pirWireFrame(x) + $x - $pirWireFrame(deltaX)}]
  set yy [expr {$pirWireFrame(y) + $y - $pirWireFrame(deltaY)}]
  set stopNodeCanvasIdList [$canvas find overlapping $xx $yy $xx $yy]
  # puts stderr "\nmodeB2Release: overlapping $stopNodeCanvasIdList"
  set stopNodeCanvasId -1
  set pirNodeIdList [$canvas find withtag node]
  foreach canvasId $stopNodeCanvasIdList {
    if {[lsearch -exact $pirNodeIdList $canvasId] >= 0} {
      set stopNodeCanvasId $canvasId
      break
    }
  }
  if {$stopNodeCanvasId == -1} {
    if {(! [componentModuleDefReadOnlyP]) && \
            [string match $g_NM_rootInstanceName \
                 [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      $canvas delete wire; bell
    }
    set g_NM_transitionStartPirIndex 0
    return
  }
  # puts stderr "modeB2Release: stopNodeCanvasId $stopNodeCanvasId"
  set stopNodeWidget [$canvas itemcget $stopNodeCanvasId -window]
  # puts stderr "modeB2Release: stopNodeWidget $stopNodeWidget"
  set stopPirNodeIndex [getPirNodeIndexFromWindowPath $stopNodeWidget]
  set nodeClassType [assoc nodeClassType pirNode($stopPirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($stopPirNodeIndex)]
  if {$stopPirNodeIndex == $g_NM_transitionStartPirIndex} {
    # start, stop nodes are the same
    $canvas delete wire; bell
    set g_NM_transitionStartPirIndex 0
    return
  }
  set startNodeClassName [assoc nodeClassName pirNode($g_NM_transitionStartPirIndex)]
  if {(! [string match $nodeClassType mode]) || \
          ([string match $startNodeClassName okMode] && \
               [string match $nodeClassName faultMode])} {
    # node is not of type mode; or 
    # start node is an okMode and stop node is a faultMode
    # faultMode to faultMode is allowable
    $canvas delete wire; bell
    set g_NM_transitionStartPirIndex 0
    return
  }
  # is a transition graphic already in existence
  set transition {}
  getComponentModeTransition $g_NM_transitionStartPirIndex \
      $g_NM_transitionStartPirIndex $stopPirNodeIndex transition 
  if {([llength [assoc defs transition $reportNotFoundP]] > 0)} {
    # graphic arrow already exists
    $canvas delete wire; bell
    set g_NM_transitionStartPirIndex 0
    return
  }    

  # puts stderr "modeB2Release: stopPirNodeIndex $stopPirNodeIndex"
  $canvas delete wire
  set lineId 0; set arrowId 0
  set startNodeWidget [assoc window pirNode($g_NM_transitionStartPirIndex)]
  drawModeTransition $canvas $startNodeWidget $stopNodeWidget lineId arrowId \
      $g_NM_transitionStartPirIndex $stopPirNodeIndex 

  # add transition data structs to pirNode's
  set reportNotFoundP 0; set returnIndexP 1
  set startPirNodeIndex $g_NM_transitionStartPirIndex 
  # puts stderr "modeB2Release: startPirNodeIndex $startPirNodeIndex"
  # puts stderr "modeB2Release: stopPirNodeIndex $stopPirNodeIndex"
  if {[assoc transitions pirNode($startPirNodeIndex) \
           $reportNotFoundP $returnIndexP] == -1} {
    acons transitions {} pirNode($startPirNodeIndex)
  }
  if {[assoc transitions pirNode($stopPirNodeIndex) \
           $reportNotFoundP $returnIndexP] == -1} {
    acons transitions {} pirNode($stopPirNodeIndex)
  }
  set currentEntries [assoc transitions pirNode($startPirNodeIndex)]
  lappend currentEntries [list startNode $startPirNodeIndex \
                              stopNode $stopPirNodeIndex \
                              lineId $lineId  arrowId $arrowId \
                              defs {}]
  arepl transitions $currentEntries pirNode($startPirNodeIndex)
  # puts stderr "modeB2Release: currentEntries $currentEntries"
  set currentEntries [assoc transitions pirNode($stopPirNodeIndex)]
  lappend currentEntries [list startNode $startPirNodeIndex \
                              stopNode $stopPirNodeIndex]
  arepl transitions $currentEntries pirNode($stopPirNodeIndex)
  
  set g_NM_transitionStartPirIndex 0
  update
  # ask user to define a transition
  set nodeClassType transition; set nodeClassName transition
  editModeTransition $nodeClassType $nodeClassName $startPirNodeIndex \
      $stopPirNodeIndex $caller

  set dialogW $g_NM_nodeTypeRootWindow.editModeTransition
  append dialogW ${startPirNodeIndex}_${stopPirNodeIndex}
  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ## grab set $dialogW
    tkwait window $dialogW
  }
  set transition {}
  getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
      $stopPirNodeIndex transition
  if {[llength [assoc defs transition]] == 0} {
    # no defintion saved
    cutModeTransition $canvas $startPirNodeIndex $stopPirNodeIndex
  }
}


## check if external node name matches any transition name for any
## mode of the component
## derived from deleteAllModeTransitions
## 17jan02: wmt
proc checkTransitionNames { externalNodeName } {
  global pirNodes pirNode

  set reportNotFoundP 0; set foundP 0
  foreach pirNodeIndex $pirNodes {
    # puts stderr "checkTransitionNames:pirNodeIndex $pirNodeIndex externalNodeName `$externalNodeName'"
    if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
             mode]} {
      set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
      set modeName [getExternalNodeName [assoc nodeInstanceName \
                                             pirNode($pirNodeIndex)]]
      set transitionList [assoc transitions pirNode($pirNodeIndex) \
                             $reportNotFoundP]
      # puts stderr "checkTransitionNames: transitionList $transitionList"
      foreach transition $transitionList {
        # puts stderr "checkTransitionNames: transition $transition"
        set startPirNodeIndex [assoc startNode transition]
        set stopPirNodeIndex [assoc stopNode transition]
        set transition {}
        if {([lsearch -exact $pirNodes $startPirNodeIndex] >= 0) && \
                ([lsearch -exact $pirNodes $stopPirNodeIndex] >= 0)} {
          # set str "checkTransitionNames: startPirNodeIndex $startPirNodeIndex"
          # puts stderr "$str stopPirNodeIndex $stopPirNodeIndex"
          getComponentModeTransition $startPirNodeIndex $startPirNodeIndex \
              $stopPirNodeIndex transition
          set nameList {}
          set transitionDefs [assoc defs transition $reportNotFoundP]
          foreach selectedName [alist-keys transitionDefs] {
            # puts stderr "checkTransitionNames: mode $modeName transition `$selectedName'"
            if {[string match $externalNodeName $selectedName]} {
              set foundP 1
              break
            }
          }
          if {$foundP} { break }
        }
      }
      if {$foundP} { break }
      if {[string match $nodeClassName faultMode]} {
        # JMPL generation creates a transition from all modes to
        # each failure mode, with the name of to<capitalized-mode-name>
        # puts stderr "$externalNodeName to[string toupper $modeName 0 0]"
        if {[string match $externalNodeName \
                 "to[string toupper $modeName 0 0]"]} {
          set foundP 1
          break
        }
      }
    }
  }
  return $foundP 
}


















