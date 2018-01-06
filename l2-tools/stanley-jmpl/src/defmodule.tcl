# $Id: defmodule.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## procs to support visual editing of defmodule forms


## prompt user for defmodule information and build root node
## 16sep96 wmt: new
## 23nov96 wmt: automate recursive instantiation of defmodules
proc askDefmoduleInfo { canvasRootId caller } {
  global g_NM_mkformNodeCompleteP g_NM_classInstance 
  global g_NM_livingstoneDefmoduleName g_NM_currentCanvas
  global g_NM_livingstoneDefmoduleArgList pirDisplay
  global g_NM_livingstoneDefmoduleNameVar pirNode 
  global g_NM_rootInstanceName g_NM_pirClassModuleTemplate 
  global g_NM_mkformNodeUpdatedP g_NM_livingstoneDefmoduleArgTypeList 
  global g_NM_nodeTypeRootWindow pirClassModule pirClassesModule

  if {[string match $caller "fileNew"] || \
          [string match $caller "createNewRootCanvas"]} {
    ## display defmodule node
    set mkNodeArgList {}; set nodeConfig {}
    set g_NM_mkformNodeCompleteP 0
    set nodeClassName $g_NM_livingstoneDefmoduleName
    set nodeClassType "module"
    set argsValues {}
    set nodeInstanceName $g_NM_livingstoneDefmoduleNameVar
    set g_NM_rootInstanceName $nodeInstanceName
    set nodeState "NIL"; set internal {}
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
      error "askDefmoduleInfo: mkNode returned -1"
    }
    if {$canvasRootId == 0} {
      acons input_terminals {} pirNode($n)
      acons output_terminals {} pirNode($n)
      acons port_terminals {} pirNode($n)
      acons attributes {} pirNode($n)
      acons argsValues $argsValues pirNode($n)
      acons numArgsVars [llength $argsValues] pirNode($n)
      ## create pirClass entry
      set internalVars $g_NM_pirClassModuleTemplate 
      set classVars [assoc class_variables internalVars]
      setClassVarDefaultValue args $g_NM_livingstoneDefmoduleArgList classVars
      setClassVarDefaultValue argTypes $g_NM_livingstoneDefmoduleArgTypeList classVars
      arepl class_variables $classVars internalVars
      if {[lsearch -exact $pirClassesModule $nodeClassName] == -1} {
        set pirClassModule($nodeClassName) $internalVars 
        acons nodeClassType $nodeClassType pirClassModule($nodeClassName)
        lappend pirClassesModule $nodeClassName
      }
    }
    # open to working level of module
    # puts stderr "askDefmoduleInfo: g_NM_rootInstanceName $g_NM_rootInstanceName"
    set canvasRoot [getCanvasRoot $canvasRootId]
    openNodeGroup $g_NM_rootInstanceName module [assoc window pirNode($n)]
    update
  }
  # set str "askDefmoduleInfo: g_NM_mkformNodeUpdatedP"
  # puts stderr "$str $g_NM_mkformNodeUpdatedP"
  return 
}


## allow user to edit defmodule parameters and change Stanley data structs
## as necessary
## 12may97 wmt: new 
## 07jan98 wmt: parameterize into two dialogs: nameVarDoc, & facts
proc editDefmoduleParams { dialogType } {
  global g_NM_mkformNodeCompleteP 
  global pirFileInfo pirEdge g_NM_classDefType
  global pirNode g_NM_livingstoneDefmoduleName
  global g_NM_nodeGroupToInstances g_NM_livingstoneDefmoduleNameVar
  global g_NM_livingstoneDefmoduleArgList pirNodes pirEdges
  global g_NM_livingstoneDefmoduleFileName g_NM_rootInstanceName
  global g_NM_argsVarsTranslations g_NM_includedModules
  global g_NM_instanceToNode g_NM_componentToNode
  global g_NM_moduleToNode g_NM_canvasList g_NM_win32P
  global g_NM_termtypeRootWindow g_NM_moduleDocInput g_NM_currentNodeGroup
  global pirClassesModule pirClassModule g_NM_livingstoneDefmoduleArgTypeList 

  set g_NM_mkformNodeCompleteP 0
  set oldLivingstoneDefmoduleName $g_NM_livingstoneDefmoduleName
  set pirClassIndex $oldLivingstoneDefmoduleName
  set classVars [assoc class_variables pirClassModule($pirClassIndex)]
  set oldmoduleDocInput [getClassVarDefaultValue documentation classVars]
  set oldmoduleFactsInput [getClassVarDefaultValue facts classVars]
  set caller editDefmoduleParams

  askLivingstoneDefmoduleParams $dialogType $caller

  if {! $g_NM_mkformNodeCompleteP} {
    return 0
  }
  if {(! [regexp -nocase $oldLivingstoneDefmoduleName \
              $g_NM_livingstoneDefmoduleName]) || \
          ([string length $oldLivingstoneDefmoduleName] != \
               [string length $g_NM_livingstoneDefmoduleName])} {
    ## modify appropriate items in Stanley data structures  
    ## g_NM_livingstoneDefmoduleName is the .scm file name and the .jmpl file name
    set pirFileInfo(filename) $g_NM_livingstoneDefmoduleName
    # non-null g_NM_livingstoneDefmoduleFileName is check in FileSave
    set g_NM_livingstoneDefmoduleFileName $g_NM_livingstoneDefmoduleName

    set defmodName $g_NM_livingstoneDefmoduleName
    set g_NM_livingstoneDefmoduleName $defmodName
    set oldDefmodName $oldLivingstoneDefmoduleName
    set defmoduleArgList $g_NM_livingstoneDefmoduleArgList
    set defmoduleArgTypeList $g_NM_livingstoneDefmoduleArgTypeList
    set nameIndexPairs [assoc-array "root" g_NM_nodeGroupToInstances]
    set pirNodeIndex [assoc $g_NM_livingstoneDefmoduleNameVar nameIndexPairs]
    arepl nodeClassName $defmodName pirNode($pirNodeIndex)

    set nameIndexPairs [assoc-array $g_NM_livingstoneDefmoduleNameVar \
                            g_NM_nodeGroupToInstances]
    for {set index 0} {$index < [llength $nameIndexPairs]} {incr index 2} {
      set nodeInstanceName [lindex $nameIndexPairs $index]
      if {[regexp "root" $nodeInstanceName]} {
        set pirNodeIndex [lindex $nameIndexPairs [expr {1 + $index}]]
        arepl nodeClassName $defmodName pirNode($pirNodeIndex)
      }
    }
    set temp $pirClassModule($oldDefmodName)
    catch { unset pirClassModule($oldDefmodName) }
    set index [lsearch -exact $pirClassesModule $oldDefmodName]
    set pirClassesModule [lreplace $pirClassesModule $index $index $defmodName]
    set pirClassModule($defmodName) $temp
    set class_variables [assoc class_variables pirClassModule($defmodName)]
    setClassVarDefaultValue args $defmoduleArgList class_variables
    setClassVarDefaultValue argTypes $defmoduleArgTypeList class_variables
    arepl class_variables $class_variables pirClassModule($defmodName)

    mark_scm_modified
  }

  set pirClassIndex $g_NM_livingstoneDefmoduleName
  set classVars [assoc class_variables pirClassModule($pirClassIndex)]
  set newModuleDocInput [getClassVarDefaultValue documentation classVars]
  set newModuleFactsInput [getClassVarDefaultValue facts classVars]
  if {(! [string match $oldmoduleDocInput $newModuleDocInput]) || \
          (! [string match $oldmoduleFactsInput $newModuleFactsInput])} {
    mark_scm_modified
  }

  if {[llength $g_NM_argsVarsTranslations] > 0} {
    # puts stderr "editDefmoduleParams: newArgsVarsTranslations $newArgsVarsTranslations"
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

    # for tcl window path substitution
    regsub -all "\\\." $varsTransArgValues "_" varsTransArgValuesTcl
    set regsubTransListDot {}; set regsubTransListSpace {}
    buildRegsubVarValueLists varsTransArgs varsTransArgValuesTcl \
        regsubTransListDot regsubTransListSpace \
        transValueTclListDot transValueTclListSpace 

    # apply new translations to argsValues in g_NM_includedModules
    set new_includedModules {}
    foreach key [alist-keys g_NM_includedModules] {
      set module [assoc $key g_NM_includedModules] 
      applyRegsub key \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
      # special processing for tcl paths: ?name.pr01 => ?name_pr01 so as to not
      # introduce unwanted . tcl delimiters into paths
      set window [assoc window module]
      applyRegsub window \
          regsubTransListDot regsubTransListSpace \
          transValueTclListDot transValueTclListSpace 
      applyRegsub module \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
      arepl window $window module 
      lappend new_includedModules $key $module
    }
    set g_NM_includedModules $new_includedModules 

    # apply new translations to pirClassModule args, input_terminals,
    # output_terminals, attributes, facts
    set pirClassIndex $g_NM_livingstoneDefmoduleName
    applyRegsub pirClassModule($pirClassIndex) \
        regsubTransListDot regsubTransListSpace \
        transValueListDot transValueListSpace 

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
    # puts stderr "A g_NM_canvasList $g_NM_canvasList"
    ## apply argsVarsTranslations to g_NM_instanceToNode, g_NM_moduleToNode
    ## g_NM_nodeGroupToInstances
    ## convert arrays to lists
    set instanceToNodeAList [array get g_NM_instanceToNode]
    set componentToNodeAList [array get g_NM_componentToNode]
    set moduleToNodeAList [array get g_NM_moduleToNode]
    set nodeGroupToInstancesAList [array get g_NM_nodeGroupToInstances]
    foreach list [list instanceToNodeAList componentToNodeAList \
                      moduleToNodeAList nodeGroupToInstancesAList] {
      applyRegsub $list \
          regsubTransListDot regsubTransListSpace \
          transValueListDot transValueListSpace 
    }
    catch { unset g_NM_instanceToNode g_NM_componentToNode g_NM_moduleToNode \
              g_NM_nodeGroupToInstances }
    array set g_NM_instanceToNode $instanceToNodeAList 
    array set g_NM_componentToNode $componentToNodeAList
    array set g_NM_moduleToNode $moduleToNodeAList
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
  displayDotWindowTitle
} 


## 05jan96wmt: new
##              ask user for livinstone schematic filename
## 30jan96 wmt: attach dialog to ., so it cannot get "lost"
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 30apr97 wmt: remove fileNameP arg; ask for filename as well as other params
## 11jun97 wmt: now only called with defmoduleNameOnlyP == 0
## 11aug97 wmt: handle viewing of modules not at top level
## 07jan98 wmt: parameterize into three dialogs: nameVarDoc, & facts
proc askLivingstoneDefmoduleParams { dialogType caller {xPos -1} {yPos -1} } {
  global g_NM_maxDefmoduleArgs g_NM_livingstoneDefmoduleName
  global g_NM_livingstoneDefmoduleNameVar pirClassModule
  global g_NM_livingstoneDefmoduleArgList g_NM_classDefType
  global g_NM_mkformModuleDefaultValues g_NM_rootInstanceName
  global g_NM_mkformNodeModuleDefaultValues g_NM_moduleToNode 
  global g_NM_moduleDocInput g_NM_moduleFactsInput
  global g_NM_currentNodeGroup pirNode g_NM_currentCanvas
  global g_NM_nodeTypeRootWindow g_NM_schematicMode
  global g_NM_livingstoneDefmoduleFileName g_NM_mkEntryWidgetWidth
  global g_NM_livingstoneDefmoduleArgTypeList g_NM_paletteStructureList 
  global g_NM_terminalTypeList g_NM_paletteDefvalueList 
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global g_NM_terminalTypeValuesArray g_NM_readableJavaTokenRegexp
  global g_NM_readableJavaTokenOrQRegexp g_NM_readableJavaFormRegexp

  set structValueTypeList [concat $g_NM_paletteStructureList \
                               $g_NM_paletteDefvalueList <unspecified>]
  set classTypeList [concat $g_NM_paletteDefcomponentList \
                         $g_NM_paletteDefmoduleList <unspecified>]
  set pirNodeIndex [assoc-array [getCanvasRootInfo g_NM_currentNodeGroup] \
                        g_NM_moduleToNode]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  if {[string match $g_NM_rootInstanceName \
           [getCanvasRootInfo g_NM_currentNodeGroup]]} {
    set readOnlyP 0; set state normal
    set operation Edit
    set moduleClassName $g_NM_livingstoneDefmoduleName
    if {[string match $g_NM_schematicMode "operational"] || \
            [classDefReadOnlyP module $moduleClassName] || \
            [string match $caller "metaDot"]} {
      set readOnlyP 1; set state disabled
      set operation View
      set moduleValList [assoc argsValues pirNode($pirNodeIndex)]
      enableViewDialogDeletion
    }
    set moduleClassNameVar $g_NM_livingstoneDefmoduleNameVar
    set nodeInstanceName $g_NM_rootInstanceName
    set pirClassIndex $moduleClassName
    set classVars [assoc class_variables pirClassModule($pirClassIndex)]
    set maxDefmoduleArgs $g_NM_maxDefmoduleArgs
    set moduleArgList $g_NM_livingstoneDefmoduleArgList
    set numAskArgs [expr {[llength $moduleArgList] + 2}]
    set numArgs 3
    if {$numAskArgs > $numArgs} {
      set numArgs $numAskArgs
    }
    set moduleArgTypeList $g_NM_livingstoneDefmoduleArgTypeList
  } else {
    set readOnlyP 1; set state disabled
    set pirClassIndex [assoc nodeClassName pirNode($pirNodeIndex)]
    set moduleClassName $pirClassIndex
    set classVars [assoc class_variables pirClassModule($pirClassIndex)]
    set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set moduleClassNameVar $nodeInstanceName
    set operation View
    enableViewDialogDeletion
    set maxDefmoduleArgs [assoc numArgsVars pirNode($pirNodeIndex)]
    set moduleValList [assoc argsValues pirNode($pirNodeIndex)]
    set numArgs [llength $moduleValList]
    set moduleArgTypeList [getClassVarDefaultValue argTypes classVars]
  }

  set titleText "$operation Module: "
  if {[string match $dialogType nameVarDoc]} {
    if {[string match $operation "Edit"]} {
      append titleText "Name, Variables, & Documentation"
    } else {
      append titleText "Name, Values, & Documentation"
    }
  } elseif {[string match $dialogType facts]} {
    append titleText "Facts"
  } else {
    error "askLivingstoneDefmoduleParams: dialogType $dialogType not handled\!"
  }

  set initP 0
  set dialogW $g_NM_nodeTypeRootWindow.module${dialogType}_$pirClassIndex
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
  set cmd "newLivingstoneDefmoduleParamsUpdate $dialogW $dialogType $numArgs"
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised \
      -command $cmd -state $state
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0

  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set g_NM_mkformModuleDefaultValues(0) 1
  set g_NM_mkformModuleNumDefaultValues 0

  if {[string match $dialogType nameVarDoc]} {
    frame $dialogW.nameInstVar -bg $bgcolor 
    set widgetInstVar $dialogW.nameInstVar.finstanceVar
    if {[string match $operation "Edit"]} {
      set defaultValue $moduleClassNameVar
      if {$defaultValue == ""} {
        set defaultValue "?name"
      }
      set description "Instance Variable"
    } else {
      set defaultValue [getExternalNodeName $nodeInstanceName]
      set description "Instance Name"
    }
    set entryWidth $g_NM_mkEntryWidgetWidth; set takeFocusP 0
    mkEntryWidget $widgetInstVar "" $description $defaultValue disabled $entryWidth \
        $takeFocusP
    if {[string match $operation "Edit"]} {
      balloonhelp $widgetInstVar.fentry.entry -side right "read-only" 
      balloonhelp $widgetInstVar.pad.left -side right \
          "<tab> to next field;  <shift-tab> to prev"
    }
    if {! $readOnlyP} {
      incr g_NM_mkformModuleNumDefaultValues
      set g_NM_mkformModuleDefaultValues($g_NM_mkformModuleNumDefaultValues) \
          $defaultValue
    }

    set defaultValue $moduleClassName
    if {[string match $g_NM_livingstoneDefmoduleFileName ""] && \
            [string match $operation "Edit"]} {
      set defaultValue ""
    }
    set widgetName $dialogW.nameInstVar.fmoduleName
    if {[string match $operation "Edit"]} {
      set description "Name"
    } else {
      set description "Instance Type"
    }
    mkEntryWidget $widgetName "" $description $defaultValue $state
    if {[string match $operation "Edit"]} {
      balloonhelp $widgetName.fentry.entry -side right $g_NM_readableJavaTokenRegexp
      balloonhelp $widgetName.pad.left -side right \
          "<tab> to next field;  <shift-tab> to prev"
    }
    if {! $readOnlyP} {
      incr g_NM_mkformModuleNumDefaultValues
      set g_NM_mkformModuleDefaultValues($g_NM_mkformModuleNumDefaultValues) \
          $defaultValue
    }
    pack $widgetInstVar $widgetName -side left -fill x -ipadx 20
    pack $dialogW.nameInstVar -side top -fill x

    set cmdMonTypeP 0
    # disable class type parameters
    set classParamTypeState disabled
    for {set i 0} {$i < $numArgs} {incr i} {
      set index [expr {$i + 1}] 
      frame $dialogW.moduleParam$i -bg $bgcolor 
      frame $dialogW.moduleParam$i.typeParam

      set defaultType [lindex $moduleArgTypeList $i]
      if {$defaultType == ""} {
        set defaultTypeValue "<unspecified>"
        set defaultTypeClass "<unspecified>"
        set defaultType "<unspecified>" 
      } else {
        if {[lsearch -exact $g_NM_terminalTypeList $defaultType] >= 0} {
          set defaultTypeValue $defaultType
          set defaultTypeClass "<unspecified>"
        } else {
          set defaultTypeValue "<unspecified>" 
          set defaultTypeClass $defaultType
        }
      }
      global g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default
      set g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default $defaultType

      frame $dialogW.moduleParam$i.typeParam.value -background $bgcolor 
      label $dialogW.moduleParam$i.typeParam.value.typetitle -text \
          "Struct/Value Param Type $index" -relief flat -anchor w 
      $dialogW.moduleParam$i.typeParam.value.typetitle configure -takefocus 0
      tk_alphaOptionMenuCascade $dialogW.moduleParam$i.typeParam.value.optMenuButton \
          g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_value \
          $defaultTypeValue structValueTypeList $state \
          $cmdMonTypeP $dialogW.moduleParam$i
      set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 
      balloonhelp $dialogW.moduleParam$i.typeParam.value.optMenuButton -side right \
          "values: [multiLineList $defaultTypeValue $valuesList values:]"
      pack $dialogW.moduleParam$i.typeParam.value.typetitle \
          $dialogW.moduleParam$i.typeParam.value.optMenuButton \
          -side top -fill x 

      frame $dialogW.moduleParam$i.typeParam.class -background $bgcolor 
      label $dialogW.moduleParam$i.typeParam.class.typetitle -text \
          "Comp/Module Param Type $index" -relief flat -anchor w 
      $dialogW.moduleParam$i.typeParam.class.typetitle configure -takefocus 0
      tk_alphaOptionMenuCascade $dialogW.moduleParam$i.typeParam.class.optMenuButton \
          g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_class \
          $defaultTypeClass classTypeList $classParamTypeState \
          $cmdMonTypeP $dialogW.moduleParam$i
      pack $dialogW.moduleParam$i.typeParam.class.typetitle \
          $dialogW.moduleParam$i.typeParam.class.optMenuButton \
          -side top -fill x 

      set widgetVar $dialogW.moduleParam$i.typeParam.var
      if {[string match $operation "Edit"]} {
        set defaultValue [lindex $moduleArgList $i]
        set description "Parameter Variable $index"
      } else {
        set defaultValue [lindex $moduleValList $i]
        set description "Parameter Value $index"
      }
      mkEntryWidget $widgetVar "" $description $defaultValue $state 
      if {[string match $operation "Edit"]} {
        balloonhelp $widgetVar.fentry.entry -side right \
            $g_NM_readableJavaTokenOrQRegexp
        balloonhelp $widgetVar.pad.left -side right \
            "<tab> to next field;  <shift-tab> to prev"
      }
      pack $dialogW.moduleParam$i.typeParam.value \
          $dialogW.moduleParam$i.typeParam.class \
          $widgetVar -side left -fill both -ipadx 20
      pack $dialogW.moduleParam$i.typeParam -side top -fill x
      pack $dialogW.moduleParam$i -side top -fill x
      if {! $readOnlyP} {
        incr g_NM_mkformModuleNumDefaultValues
        set g_NM_mkformModuleDefaultValues($g_NM_mkformModuleNumDefaultValues) \
            $defaultValue
        incr g_NM_mkformModuleNumDefaultValues
        set g_NM_mkformModuleDefaultValues($g_NM_mkformModuleNumDefaultValues) \
            $defaultTypeValue
      }
    }
  }

  if {[string match $dialogType facts]} {
    frame $dialogW.facts
    frame $dialogW.facts.ftitle -background $bgcolor
    label $dialogW.facts.ftitle.title -text "Facts" -relief flat -anchor w 
    $dialogW.facts.ftitle.title configure -takefocus 0
    pack $dialogW.facts.ftitle.title -side left
    pack $dialogW.facts.ftitle -side top -fill both
    pack $dialogW.facts -side top 
    set attributeName facts; set pirEdgeIndex 0
    if {[string match $g_NM_rootInstanceName \
             [getCanvasRootInfo g_NM_currentNodeGroup]]} {
      set g_NM_moduleFactsInput [getClassVarDefaultValue $attributeName classVars]
    } else {
      # if parameters are used, then get properly instantiated form from node
      set g_NM_moduleFactsInput [assoc $attributeName pirNode($pirNodeIndex)]
    }
    global g_NM_moduleFactsInput_$dialogId 
    set g_NM_moduleFactsInput_$dialogId $g_NM_moduleFactsInput
    createEmacsTextWidget $dialogId $dialogW factsEmacs $nodeClassType $attributeName \
        $state $pirEdgeIndex 
    if {[string match $operation "Edit"]} {
      balloonhelp $dialogW.factsEmacs.t -side top $g_NM_readableJavaFormRegexp
    }
  }

  if {[string match $dialogType nameVarDoc]} {  
    label $dialogW.docspacer -text "" -relief flat -height 1
    $dialogW.docspacer configure -takefocus 0
    label $dialogW.doctitle -text "Documentation" -relief flat -anchor w
    $dialogW.doctitle configure -takefocus 0
    pack $dialogW.docspacer $dialogW.doctitle -side top -fill both

    set attributeName documentation
    set g_NM_moduleDocInput [getClassVarDefaultValue $attributeName classVars]
    global g_NM_moduleDocInput_$dialogId 
    set g_NM_moduleDocInput_$dialogId $g_NM_moduleDocInput 
    createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 
    if {! $readOnlyP} {
      incr g_NM_mkformModuleNumDefaultValues
      set g_NM_mkformModuleDefaultValues($g_NM_mkformModuleNumDefaultValues) \
          $g_NM_moduleDocInput 
    }
  }

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x

  if {[string match $dialogType nameVarDoc]} {  
    focus $dialogW.nameInstVar.fmoduleName.fentry.entry
  }

  keepDialogOnScreen $dialogW $xPos $yPos

  if {[winfo exists $dialogW] && (! [string match $operation "View"])} {
    ## allow tk_focusFollowsMouse to work
    ## grab set $dialogW
    tkwait window $dialogW
  }
}


## process livingstone defmodule pathname entries
## 05jan96 wmt: new
## 13sep96 wmt: add processing for variable args
## 30apr96 wmt: merge filename and other params
proc newLivingstoneDefmoduleParamsUpdate { dialogW dialogType numParmArgs } {
  global g_NM_mkformNodeCompleteP g_NM_livingstoneDefmodulePathName
  global g_NM_livingstoneDefmoduleName g_NM_maxDefmoduleArgs
  global g_NM_livingstoneDefmoduleArgList g_NM_fileOperation
  global g_NM_livingstoneDefmoduleNameVar g_NM_mkformNodeUpdatedP
  global g_NM_mkformModuleDefaultValues g_NM_mkformModuleNumDefaultValues
  global g_NM_livingstoneDefmoduleArgTypeList 
  global g_NM_livingstoneDefmoduleFileName g_NM_argsVarsTranslations
  global g_NM_moduleDocInput g_NM_moduleFactsInput pirClassModule
  global g_NM_livingstoneDefmoduleArgTypeList g_NM_classTypes 
  global g_NM_advisoryRootWindow 

  set dialogId [getDialogId $dialogW]
  set outputMsgP 0
  set defaultValueIndex 0; set g_NM_mkformNodeUpdatedP 0
  set pirClassIndex $g_NM_livingstoneDefmoduleName
  set classVars [assoc class_variables pirClassModule($pirClassIndex)]

  set argsVarsTranslations {}
  # module instance variable is always ?name -- it cannot be changed by user
  set defmoduleNameVar ?name
  incr defaultValueIndex

  if {[string match $dialogType nameVarDoc]} {
    set newLivingstoneDefmoduleName \
        [$dialogW.nameInstVar.fmoduleName.fentry.entry get]
    set newLivingstoneDefmoduleName \
        [string trim $newLivingstoneDefmoduleName " "]
    incr defaultValueIndex
    if {! [entryValueErrorCheck "Name" "(javaToken)" $newLivingstoneDefmoduleName]} {
      return
    }
    if {[string match $newLivingstoneDefmoduleName ""]} {
      set dialogList [list tk_dialog .d \
                          "ERROR" "Name not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    set tmpName $newLivingstoneDefmoduleName
    if {[string match $g_NM_fileOperation "fileNew"] || \
            (! [string match $g_NM_livingstoneDefmoduleName $tmpName])} {
      if {[classDefReadOnlyP module $tmpName]} {
        set str "Definition $tmpName is READ-ONLY"
        set dialogList [list tk_dialog .d "ERROR" $str error \
                            0 {DISMISS}]
        eval $dialogList
        return     
      }
      if {[checkForReservedNames $tmpName]} {
        return
      }
      if {[checkForClassNameConflict $tmpName module]} {
        return
      }
      if {[checkClassInstance module [getInternalNodeName $tmpName] $outputMsgP]} {
        return
      }
    }
    if {! [string match $newLivingstoneDefmoduleName \
               $g_NM_mkformModuleDefaultValues($defaultValueIndex)]} {
      set g_NM_mkformNodeUpdatedP 1
    }

    set defmoduleVarList {}
    set defmoduleVarTypeList {}
    for {set i 0} {$i < $numParmArgs} {incr i} {
      # parameter variable name
      set paramVar [$dialogW.moduleParam$i.typeParam.var.fentry.entry get]
      set paramVar [string trim $paramVar " "]
      # parameter variable type
      global g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default
      set paramType \
          [subst $[subst g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default]]
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
      lappend defmoduleVarList $paramVar 
      set oldVal $g_NM_mkformModuleDefaultValues($defaultValueIndex)
      if {! [string match $oldVal $paramVar]} {
        set g_NM_mkformNodeUpdatedP 1
        if {$oldVal != ""} {
          lappend argsVarsTranslations [list $oldVal $paramVar]
        }
      }
      incr defaultValueIndex
      # puts stderr "newLivingstoneDefmoduleParamsUpdate: paramVar $paramVar paramType $paramType"
      lappend defmoduleVarTypeList $paramType 
      set oldTypeVal $g_NM_mkformModuleDefaultValues($defaultValueIndex)
      # puts stderr "newLivingstoneDefmoduleParamsUpdate: oldVar $oldVal oldType $oldTypeVal"
      if {! [string match $oldTypeVal $paramType]} {
        set g_NM_mkformNodeUpdatedP 1
      }
    }
  }

  if {[string match $dialogType facts]} {
    # saveTextWidget puts facts into global var
    if {[saveTextWidget $dialogId $dialogW.factsEmacs module facts \
             (0-n_javaMplForms)]} {
      return
    }
    set factsInput [getTextWidgetText $dialogId module facts 0]
    terminateJmplForm factsInput 
    setClassVarDefaultValue facts $factsInput classVars
  }

  if {[string match $dialogType nameVarDoc]} {
    # saveTextWidget puts documentation into global var: g_NM_moduleDocInput_$dialogId
    saveTextWidget $dialogId $dialogW.text module documentation (all_characters)
    set docInput [getTextWidgetText $dialogId module documentation 0]
    incr defaultValueIndex
    if {! [string match $docInput \
               $g_NM_mkformModuleDefaultValues($defaultValueIndex)]} {
      set g_NM_mkformNodeUpdatedP 1
    }
  }

  # now that all validity checks are done
  if {[string match $dialogType nameVarDoc]} {
    set g_NM_livingstoneDefmoduleName $newLivingstoneDefmoduleName
    set g_NM_livingstoneDefmoduleNameVar $defmoduleNameVar
    set g_NM_livingstoneDefmoduleArgList $defmoduleVarList 
    set g_NM_livingstoneDefmoduleArgTypeList $defmoduleVarTypeList 
    set g_NM_argsVarsTranslations $argsVarsTranslations
    setClassVarDefaultValue documentation $docInput classVars
  }
  arepl class_variables $classVars pirClassModule($pirClassIndex)

  set g_NM_mkformNodeCompleteP 1 
  if {[string match $dialogType nameVarDoc]} {
    if {$g_NM_mkformNodeUpdatedP} {
      mark_scm_modified
    }
    # substitutions in editDefmoduleParams do this automatically
#     if {$argsVarsTranslations != ""} {
#       # user has changed names of parameter variables
#       set str "You have changed one or more parameter variable names.\n"
#       append str "Make changes as appropriate to module facts,\n"
#       append str "and attribute facts."
#       set dialogList [list tk_dialogNoGrab ${g_NM_advisoryRootWindow}.dfailed \
#                           "ADVISORY" $str warning 0 {DISMISS}]
#       eval $dialogList
#     }
  } else {
    # always mark dialogType = facts as modified
    mark_scm_modified 
  }
  destroy $dialogW
  # slow
  # raiseStanleyWindows 
}


## update locations of included modules
## g_NM_includedModules nodeX & nodeY are set when modules
## are instantiated -- if they are moved by the user, their
## locations must be updated
## 02apr98 wmt: also update instanceLabel
## 08jul98 wmt: also update inputs/outputs to get all terminal
##              pointer information
proc updateIncludedModuleLocations { } {
  global g_NM_includedModules pirNode

  foreach nodeInstanceName [alist-keys g_NM_includedModules] {
    set nodeAttributes [assoc $nodeInstanceName g_NM_includedModules]
    set pirNodeIndex [assoc pirNodeIndex nodeAttributes]
    set nodeX [assoc nodeX pirNode($pirNodeIndex)]
    set nodeY [assoc nodeY pirNode($pirNodeIndex)]
    set labelX [assoc labelX pirNode($pirNodeIndex)]
    set labelY [assoc labelY pirNode($pirNodeIndex)]
    set instanceLabel [assoc instanceLabel pirNode($pirNodeIndex)]
    set inputs [assoc inputs pirNode($pirNodeIndex)] 
    set outputs [assoc outputs pirNode($pirNodeIndex)] 

    arepl nodeX $nodeX nodeAttributes 
    arepl nodeY $nodeY nodeAttributes
    arepl labelX $labelX nodeAttributes 
    arepl labelY $labelY nodeAttributes
    arepl instanceLabel $instanceLabel nodeAttributes
    arepl inputs $inputs nodeAttributes
    arepl outputs $outputs nodeAttributes 
    arepl $nodeInstanceName $nodeAttributes g_NM_includedModules
  }
}


## return lists of current level terminals and the terminals of included 
## modules/components which have interfaceType = public in their terminalForms
## -- these will be inherited by their parent module.
## called by fileSave
## 06jun97 wmt: new
## 21jul97 wmt: updated to handle components, as well
proc inheritTerminalsIntoModule { inherit_input_terminal_defsRef \
                                      inherit_output_terminal_defsRef \
                                      {handleDeclarationsP 0} \
                                      {inheritAllP 0} } {
  upvar $inherit_input_terminal_defsRef inherit_input_terminal_defs
  upvar $inherit_output_terminal_defsRef inherit_output_terminal_defs
  global g_NM_rootInstanceName pirEdge pirDisplay g_NM_componentToNode 
  global pirNode g_NM_moduleToNode g_NM_nodeGroupToInstances g_NM_classDefType
  global g_NM_inheritedTerminals 

  set connected_input_terminal_nodes {}; set connected_output_terminal_nodes {}
  set connected_input_terminal_names {}; set connected_output_terminal_names {}
  set input_terminal_nodes {}; set output_terminal_nodes {}
  # create a list of all top level inputs/outputs with this structure
  # {inputs {public {} private {}} outputs {public {} private {}}}
  set g_NM_inheritedTerminals {}
  set inputPrivateTerminalNames {}; set inputPublicTerminalNames {}
  set outputPrivateTerminalNames {}; set outputPublicTerminalNames {}
  if {[string match $g_NM_classDefType module]} {
    set groupNodeIndex [assoc-array $g_NM_rootInstanceName g_NM_moduleToNode]
  } elseif {[string match $g_NM_classDefType component]} {
    set groupNodeIndex [assoc-array $g_NM_rootInstanceName g_NM_componentToNode]
  } else {
    puts stderr "inheritTerminalsIntoModule: g_NM_classDefType $g_NM_classDefType not handled"
    return
  }
  set pirNodePairList [assoc-array $g_NM_rootInstanceName g_NM_nodeGroupToInstances]
  # puts stderr "inheritTerminalsIntoModule: pirNodePairList $pirNodePairList"
  set pirNodeIndexList {}
  for {set i 1} {$i < [llength $pirNodePairList]} {incr i 2} {
    set pirNodeIndex [lindex $pirNodePairList $i]
    # puts stderr "inheritTerminalsIntoModule: pirNodeIndex $pirNodeIndex"
    set nodeState [assoc nodeState pirNode($pirNodeIndex)]
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    if {([string match $nodeClassType module] && \
             (! [string match $nodeState "parent-link"])) || \
            [string match $nodeClassType component] || \
            ([string match $nodeClassType terminal] && \
                 (! [regexp -- "-declaration" $nodeClassName]))} {
      lappend pirNodeIndexList $pirNodeIndex
    }
    if {$handleDeclarationsP} {
      if {[string match $nodeClassName input] || \
              [string match $nodeClassName input-declaration]} {
        lappend input_terminal_nodes $pirNodeIndex
      }
      if {[string match $nodeClassName output] || \
              [string match $nodeClassName output-declaration] || \
              [string match $nodeClassName port] || \
              [string match $nodeClassName port-declaration]} {
        lappend output_terminal_nodes $pirNodeIndex
      }
    }
  }
  # puts stderr "inheritTerminalsIntoModule: pirNodeIndexList $pirNodeIndexList"
  set input_terminals [assoc input_terminals pirNode($groupNodeIndex)]
  set output_terminals [assoc output_terminals pirNode($groupNodeIndex)]
  set len [llength $input_terminals]
  # puts stderr "inheritTerminalsIntoModule: \($len\) input_terminals $input_terminals"
  set len [llength $output_terminals]
  # puts stderr "inheritTerminalsIntoModule: \($len\) output_terminals $output_terminals"
  foreach nodeIndex $pirNodeIndexList {
    # puts stderr "\nin nodeIndex $nodeIndex"
    set inputs [assoc inputs pirNode($nodeIndex)]
    set edgesTo [assoc edgesTo pirNode($nodeIndex)]
    set edgeIndex 0
    set nodeClassType [assoc nodeClassType pirNode($nodeIndex)]
    foreach inLabel [assoc inputLabels pirNode($nodeIndex)] {
      set inTermDef [assoc $inLabel inputs]
      # puts stderr "inTermDef $inTermDef"
      set inTermName [assoc terminal_name inTermDef]
      if {[string match [assoc interfaceType inTermDef] public]} {
        if {[string match $nodeClassType "terminal"]} {
          # reverse direction sense
          set terminalP 1
          acons $inTermName [list $nodeIndex $inLabel $terminalP] \
              inherit_output_terminal_defs
          lappend outputPublicTerminalNames $inTermName
        } else {
          set terminalP 0
          acons $inTermName [list $nodeIndex $inLabel $terminalP] \
              inherit_input_terminal_defs
          lappend inputPublicTerminalNames $inTermName
        }
      } else {
        if {[string match $nodeClassType "terminal"]} {
          # reverse direction sense
          if {$inheritAllP} {
            set terminalP 1
            acons $inTermName [list $nodeIndex $inLabel $terminalP] \
                inherit_output_terminal_defs
          }
          lappend outputPrivateTerminalNames $inTermName
        } else {
          if {$inheritAllP} {
            set terminalP 0 
            acons $inTermName [list $nodeIndex $inLabel $terminalP] \
                inherit_input_terminal_defs
          }
          lappend inputPrivateTerminalNames $inTermName
        }
      }
      if {$handleDeclarationsP} {
        set toEdgeIndexList [lindex $edgesTo $edgeIndex]
        # puts stderr "edgeIndex $edgeIndex toEdgeIndexList $toEdgeIndexList"
        if {[string match $toEdgeIndexList ""]} {
          # unconnected terminal nodes -- do nothing
        } else {
          # connected_input_terminal_nodes => the nodeType = terminal
          # connected_input_terminal_names => the nodeType component/module
          #    inherited terminal names connected to the nodeType = terminals
          #    at this level
          foreach toEdgeIndex $toEdgeIndexList {
            set nodeFromIndex [assoc nodeFrom pirEdge($toEdgeIndex)]
            if {[string match [assoc nodeClassType pirNode($nodeFromIndex)] \
                     terminal]} {
              # From is the terminal, To is the component/module
              lappend connected_input_terminal_nodes $nodeFromIndex
              set terminalTo [assoc terminalTo pirEdge($toEdgeIndex)]
              set terminalName [assoc terminal_name terminalTo] 
              if {[lsearch -exact $connected_input_terminal_names $terminalName] == -1} {
                lappend connected_input_terminal_names $terminalName 
              }
              # puts stderr "edgeIndex $edgeIndex terminal_name [assoc terminal_name terminalTo]"
            } else {
              # To is the terminal, From is the component/module
              set nodeToIndex [assoc nodeTo pirEdge($toEdgeIndex)]
              lappend connected_output_terminal_nodes $nodeToIndex
              set terminalFrom [assoc terminalFrom pirEdge($toEdgeIndex)]
              set terminalName [assoc terminal_name terminalFrom]
              if {[lsearch -exact $connected_output_terminal_names $terminalName] == -1} {
                lappend connected_output_terminal_names $terminalName
              }
              # puts stderr "edgeIndex $edgeIndex terminal_name [assoc terminal_name terminalFrom]"
            }
          }
        }
        incr edgeIndex
      }
    }
  }
  foreach nodeIndex $pirNodeIndexList {
    # puts stderr "\nout nodeIndex $nodeIndex"
    set outputs [assoc outputs pirNode($nodeIndex)]
    set edgesFrom [assoc edgesFrom pirNode($nodeIndex)]
    set edgeIndex 0
    set nodeClassType [assoc nodeClassType pirNode($nodeIndex)]
    foreach outLabel [assoc outputLabels pirNode($nodeIndex)] {
      set outTermDef [assoc $outLabel outputs]
      # puts stderr "outTermDef $outTermDef"
      set outTermName [assoc terminal_name outTermDef]
      if {[string match [assoc interfaceType outTermDef] public]} {
        if {[string match $nodeClassType "terminal"]} {
          # reverse direction sense
          set terminalP 1
          acons $outTermName [list $nodeIndex $outLabel $terminalP] \
              inherit_input_terminal_defs
          lappend inputPublicTerminalNames $outTermName
       } else {
          set terminalP 0
          acons $outTermName [list $nodeIndex $outLabel $terminalP] \
              inherit_output_terminal_defs
         lappend outputPublicTerminalNames $outTermName
        }
      } else {
        if {[string match $nodeClassType "terminal"]} {
          # reverse direction sense
          if {$inheritAllP} {
            set terminalP 1
            acons $outTermName [list $nodeIndex $outLabel $terminalP] \
                inherit_input_terminal_defs
          }
          lappend inputPrivateTerminalNames $outTermName
        } else {
          if {$inheritAllP} {
            set terminalP 0
            acons $outTermName [list $nodeIndex $outLabel $terminalP] \
                inherit_output_terminal_defs
          }
          lappend outputPrivateTerminalNames $outTermName
        }
      }
      if {$handleDeclarationsP} {
        set fromEdgeIndexList [lindex $edgesFrom $edgeIndex]
        # puts stderr "edgeIndex $edgeIndex fromEdgeIndexList $fromEdgeIndexList"
        if {[string match $fromEdgeIndexList ""]} {
          # unconnected terminals -- do nothing
        } else {
          # connected_output_terminal_nodes => the nodeType = terminal
          # connected_output_terminal_names => the nodeType component/module
          #    inherited terminal names connected to the nodeType = terminals
          #    at this level
          foreach fromEdgeIndex $fromEdgeIndexList {
            set nodeToIndex [assoc nodeTo pirEdge($fromEdgeIndex)]
            if {[string match [assoc nodeClassType pirNode($nodeToIndex)] \
                     terminal]} {
              # To is the terminal, From is the component/module
              lappend connected_output_terminal_nodes $nodeToIndex
              set terminalFrom [assoc terminalFrom pirEdge($fromEdgeIndex)]
              set terminalName [assoc terminal_name terminalFrom]
              if {[lsearch -exact $connected_output_terminal_names $terminalName] == -1} {
                lappend connected_output_terminal_names $terminalName
              }
              # puts stderr "edgeIndex $edgeIndex terminal_name [assoc terminal_name terminalFrom]"
            } else {
              # From is the terminal, To is the component/module
              set nodeFromIndex [assoc nodeFrom pirEdge($fromEdgeIndex)]
              lappend connected_input_terminal_nodes $nodeFromIndex
              set terminalTo [assoc terminalTo pirEdge($fromEdgeIndex)]
              set terminalName [assoc terminal_name terminalTo]
              if {[lsearch -exact $connected_input_terminal_names $terminalName] == -1} {
                lappend connected_input_terminal_names [assoc terminal_name terminalTo]
              }
              # puts stderr "edgeIndex $edgeIndex terminal_name [assoc terminal_name terminalTo]"
            }
          }
        }
        incr edgeIndex
      }
    }
  }

  set g_NM_inheritedTerminals [list inputs [list public $inputPublicTerminalNames \
                                                private $inputPrivateTerminalNames] \
                                   outputs [list public $outputPublicTerminalNames \
                                                private $outputPrivateTerminalNames]]

#   set len [llength $connected_input_terminal_names]
#   set str "inheritTerminalsIntoModule: \($len\) connected_input_terminal_names"
#   puts stderr "$str $connected_input_terminal_names"
#   # puts stderr "$str"
#   set len [llength $connected_output_terminal_names]
#   set str "inheritTerminalsIntoModule: \($len\) connected_output_terminal_names"
#   puts stderr "$str $connected_output_terminal_names"
#   # puts stderr "$str"
#   set str "inheritTerminalsIntoModule: connected nodes"
#   puts stderr "$str [concat $connected_input_terminal_nodes $connected_output_terminal_nodes]"
#   puts stderr "inheritTerminalsIntoModule: terminator_terminal_nodes $terminator_terminal_nodes"

  if {$handleDeclarationsP} {
    ## delete unconnected input/output/port -declaration & -terminator terminals
    set unconnectedNodes {}; set selectedNodes {}
    set allTerminalNodes [concat $input_terminal_nodes $output_terminal_nodes \
                              $terminator_terminal_nodes]
    set allConnectedNodes [concat $connected_input_terminal_nodes \
                               $connected_output_terminal_nodes]
    foreach nodeIndex $allTerminalNodes {
      if {[lsearch -exact $allConnectedNodes $nodeIndex] == -1} {
        set nodeClassName [assoc nodeClassName pirNode($nodeIndex)]
        if {[regexp -- "-DECLARATION" $nodeClassName]} {
          lappend unconnectedNodes [assoc nodeInstanceName pirNode($nodeIndex)]
          lappend selectedNodes $nodeIndex 
        }
      }
    }
    if {[llength $unconnectedNodes] > 0} {
      set dialogList [list tk_dialog .d "WARNING" \
                          "Unconnected DECLARATION nodes will be deleted:
          $unconnectedNodes " warning \
                          0 {DISMISS}]
      eval $dialogList
    }    

    ## keep unconnected input/output/port terminals
    #   ## delete unconnected input/output/port terminals of parent module
    #   foreach nodeIndex $input_terminal_nodes {
    #     if {[lsearch -exact $connected_input_terminal_nodes $nodeIndex] == -1} {
    #       lappend selectedNodes $nodeIndex
    #     }
    #   }
    #   foreach nodeIndex $output_terminal_nodes {
    #     if {[lsearch -exact $connected_output_terminal_nodes $nodeIndex] == -1} {
    #       lappend selectedNodes $nodeIndex
    #     }
    #   }
    if {[llength $selectedNodes] > 0} {
      set reportNotFoundP 0; set oldvalMustExistP 0
      set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
      arepl selectedNodes $selectedNodes pirDisplay $reportNotFoundP $oldvalMustExistP

      editCut $currentCanvas.c
    }

    set input_terminals [assoc input_terminals pirNode($groupNodeIndex)]
    set output_terminals [assoc output_terminals pirNode($groupNodeIndex)]
    set len [llength $input_terminals]
    # set str "inheritTerminalsIntoModule: \($len\) input_terminals"
    # puts stderr "$str $input_terminals"
    set len [llength $output_terminals]
    # set str "inheritTerminalsIntoModule: \($len\) output_terminals"
    # puts stderr "$str $output_terminals"
  }
}










