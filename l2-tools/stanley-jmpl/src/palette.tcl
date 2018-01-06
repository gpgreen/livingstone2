# $Id: palette.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## palette.tcl: layout support for the module palette
##   Global variables:
##     pirActiveFamilyName -- save the name of the active family


## read the module names from the family directory
## 13oct95 wmt: sort module names before returning
## 25apr96 wmt: check for CVS directories
## 28may97 wmt: get defmodules from schematics dir
proc palModuleNames {path family} {
  global pirFileInfo 
  
  set excludeDirs [list "CVS" "NIL"]
  if {(! [string match $family [preferred modes_directory]]) && \
          (! [string match $family [preferred terminals_directory]]) && \
          (! [string match $family [preferred attributes_directory]])} {
    pushd [getSchematicDirectory family $family]
  } else {
    pushd "$path/$family"
  }
  # set modules [glob -nocomplain {[A-z]*}]
  set modules [glob -nocomplain {*}]
  popd
  set Files {}
  foreach file $modules {
#     if {[lsearch -exact $excludeDirs $file] == -1} {
#       lappend Files $file
#     }
    # filter out port files to disable their instantiation
    # until port type is redone to handle top/bottom placement
    if {([lsearch -exact $excludeDirs $file] == -1) && \
            ((! [string match $family [preferred terminals_directory]]) || \
                 ([string match $family [preferred terminals_directory]] && \
                      (! [regexp "port" $file]))) } {
      lappend Files $file
    }
  }
  if {(! [string match $family [preferred modes_directory]]) && \
          (! [string match $family [preferred terminals_directory]]) && \
          (! [string match $family [preferred attributes_directory]])} {
    set fileExtension $pirFileInfo(suffix)
  } else {
    set fileExtension ".cfg"
  }
  set filteredFiles {}
  foreach file $Files {
    if {[string match [file extension $file] $fileExtension]} {
      lappend filteredFiles [file rootname $file]
    }
  }
  set Files $filteredFiles

  # for component-test & module-test, filter out files which have content
  # keep empty ones
  if {[string match $family [preferred component-test_directory]] || \
          [string match $family [preferred module-test_directory]]} { 
    set filteredFiles {}
    set dir [getSchematicDirectory family $family] 
    foreach file $Files {
      set fid [open $dir/$file$pirFileInfo(suffix) r]
      set args [gets $fid]
      close $fid
      if {$args == ""} {
        lappend filteredFiles [file rootname $file]
      }
    }
    set Files $filteredFiles
  }
  
  return [lsort -ascii -increasing $Files];
}


## update palette lists used for
## defmodule/defcomponent name checking
## 18sep96 wmt: new
## 09jul97 wmt: revised 
## 18nov97 wmt: generalize to all class types
proc fillPaletteLists { { classType all } } {
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global pirClassesStructure pirClassStructure
  global g_NM_paletteStructureList g_NM_paletteTerminalList 
  global g_NM_paletteDefvalueList g_NM_paletteAttributeList
  global g_NM_paletteDefsymbolList g_NM_paletteModeList
  global g_NM_paletteAbstractionList g_NM_terminalTypeValuesArray
  global g_NM_terminalTypeList g_NM_paletteDefrelationList 
  global STANLEY_ROOT g_NM_classTypes g_NM_reservedNameList
  global pirClassesComponent pirClassComponent
  global pirClassesModule pirClassModule g_NM_checkFileDatesP
  global g_NM_componentTestList g_NM_moduleTestList
  global g_NM_paletteStrucIsTerminalTypeParamList 

  set silentP 1
  set schematicDir [lindex [preferred STANLEY_USER_DIR] 0]/[preferred schematic_directory]
  set moduleDir $STANLEY_ROOT/interface/user-template/[preferred module_directory]

  if {[string match $classType all] || [string match $classType attribute]} {
    set familyName [preferred attributes_directory] 
    set g_NM_paletteAttributeList [palModuleNames $moduleDir $familyName]
  }
  if {[string match $classType all] || [string match $classType component]} {
    set familyName [preferred defcomponents_directory] 
    set g_NM_paletteDefcomponentList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType mode]} {
    set familyName [preferred modes_directory] 
    set g_NM_paletteModeList [palModuleNames $moduleDir $familyName]
  }
  if {[string match $classType all] || [string match $classType module]} {
    set familyName [preferred defmodules_directory] 
    set g_NM_paletteDefmoduleList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType structure]} {
    set familyName [preferred structures_directory] 
    set g_NM_paletteStructureList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType abstraction]} {
    set familyName [preferred abstractions_directory] 
    set g_NM_paletteAbstractionList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType relation]} {
    set familyName [preferred defrelations_directory] 
    set g_NM_paletteDefrelationList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType symbol]} {
    set familyName [preferred defsymbols_directory] 
    set g_NM_paletteDefsymbolList [palModuleNames $schematicDir $familyName]
  }
  if {[string match $classType all] || [string match $classType terminal]} {
    set familyName [preferred terminals_directory] 
    set g_NM_paletteTerminalList [palModuleNames $moduleDir $familyName]
  }
  if {[string match $classType all] || [string match $classType value]} {
    set familyName [preferred defvalues_directory] 
    set g_NM_paletteDefvalueList [palModuleNames $schematicDir $familyName]
  }
  set g_NM_terminalTypeValuesArray(<unspecified>) {}
  set g_NM_terminalTypeList [lsort -ascii -increasing $g_NM_paletteDefvalueList]

  # mode is reserved by JMPL compiler
  # unknown is reserved by Livingstone -- variable's propositions are all = :UNKNOWN
  # g_NM_classTypes are reserved to prevent corruption of g_NM_dependentClasses
  set g_NM_reservedNameList $g_NM_classTypes
  lappend g_NM_reservedNameList "mode" "unknown"
  set g_NM_reservedNameList [concat $g_NM_reservedNameList $g_NM_paletteAttributeList \
                                 $g_NM_paletteModeList $g_NM_paletteTerminalList]
  # allow displayState (in g_NM_paletteAttributeList) to be avaialble to user
  lremove g_NM_reservedNameList displayState
  if {$g_NM_checkFileDatesP} {
    # set list of components & modules which do not have parameters
    # these will be used as Test->Select lists
    # L2 cannot handle param values set in the .ini file
    if {[file exists $schematicDir/[preferred component-test_directory]] && \
            [file exists $schematicDir/[preferred module-test_directory]]} { 
      set familyName [preferred component-test_directory]
      set g_NM_componentTestList [palModuleNames $schematicDir $familyName] 
      set familyName [preferred module-test_directory]
      set g_NM_moduleTestList [palModuleNames $schematicDir $familyName]
    } else {
      set g_NM_componentTestList $g_NM_paletteDefcomponentList
      set g_NM_moduleTestList $g_NM_paletteDefmoduleList 
    }
  }
}


## add defvalues to g_NM_terminalTypeValuesArray
## add structures to g_NM_terminalTypeValuesArray 
## 02dec97 wmt: new
proc fillTerminalTypeList { } {
  global g_NM_terminalTypeList scount 
  global g_NM_paletteDefvalueList g_NM_terminalTypeValuesArray
  global pirClassValue pirClassesValue 
  global g_NM_defaultDisplayState g_NM_displayStateType
  global g_NM_paletteStructureList pirClassStructure pirClassesStructure
  global g_NM_paletteStrucIsTerminalTypeParamList 

  set silentP 1; set reportNotFoundP 0
  # add defvalues to g_NM_terminalTypeValuesArray -- used by terminal/component/module
  # terminal balloon helps
  # puts stderr "fillTerminalTypeList: pirClassesValue $pirClassesValue"
  # puts stderr "fillTerminalTypeList: g_NM_paletteDefvalueList $g_NM_paletteDefvalueList"
  foreach valueName $g_NM_paletteDefvalueList {
    set pirClassIndex $valueName 
    if {[lsearch -exact $pirClassesValue $pirClassIndex] == -1} {
      read_workspace value $valueName $silentP
    }
    # puts stderr "fillTerminalTypeList: value pirClassIndex $pirClassIndex"
    set classVars [assoc class_variables pirClassValue($pirClassIndex)]
    set valueList [getClassVarDefaultValue valueList classVars]
    set g_NM_terminalTypeValuesArray($valueName) $valueList 
  }

  # get default display state from defvalues
  set g_NM_defaultDisplayState [lindex [assoc-array $g_NM_displayStateType \
                                            g_NM_terminalTypeValuesArray] 0]

  # add structures to g_NM_terminalTypeValuesArray -- used by terminal/component/module
  # terminal balloon helps
  # first ensure that all the latest definitions are loaded,
  # since they are interdependent
  foreach structureName $g_NM_paletteStructureList {
    set pirClassIndex $structureName
    if {[lsearch -exact $pirClassesStructure $pirClassIndex] == -1} {
      read_workspace structure $structureName $silentP
    }
  }
  # now expand the structured type definitions and fill array
  set g_NM_paletteStrucIsTerminalTypeParamList {}
  foreach structureName $g_NM_paletteStructureList {
    set pirClassIndex $structureName  
    set classVars [assoc class_variables pirClassStructure($pirClassIndex)]
    # parameterized terminal types
    if {([assoc terminalTypeParamP classVars $reportNotFoundP] != "") && \
            [getClassVarDefaultValue terminalTypeParamP classVars]} {
      lappend g_NM_paletteStrucIsTerminalTypeParamList $structureName 
    }
    set argsList [getClassVarDefaultValue args classVars]
    set argTypesList [getClassVarDefaultValue argTypes classVars]
    set valueList {}
    set scount 0
    expandStructuredType $structureName $argsList $argTypesList valueList 
    set g_NM_terminalTypeValuesArray($structureName) $valueList
    lappend g_NM_terminalTypeList $structureName
  }
  set g_NM_terminalTypeList [lsort -ascii -increasing $g_NM_terminalTypeList]
}


## expand structured type definitions
## 03mar00 wmt: new
proc expandStructuredType { structureName argsList argTypesList valueListRef } {
  upvar $valueListRef valueList

  global g_NM_terminalTypeValuesArray g_NM_paletteStructureList
  global pirClassStructure scount 

  incr scount
  if {$scount > 26} {
    error "expandStructuredType: recursive overflow"
  }
  # is this a parameterized terminal type
  if {[structIsTerminalTypeParamP $structureName]} {
    lappend valueList [getParameterizedTerminalTypes $structureName]
  }
  foreach arg $argsList argType $argTypesList {
    if {[lsearch -exact $g_NM_paletteStructureList $argType] >= 0} {
      if {[structIsTerminalTypeParamP $argType]} {
        # structure class which is parent for parameterized terminal types which
        # are the class's children
        foreach classIndex $g_NM_paletteStructureList {
          set classVars [assoc class_variables pirClassStructure($classIndex)]
          if {[string match [getClassVarDefaultValue parentType classVars] \
                   $structureName]} {
            lappend valueList $classIndex
          }
        }
      } else {
        set classVars [assoc class_variables pirClassStructure($argType)]
        set subArgsList [getClassVarDefaultValue args classVars]
        set subArgTypesList [getClassVarDefaultValue argTypes classVars]
        # puts stderr "expandStructuredType: argType $argType subArgsList $subArgsList subArgTypesList $subArgTypesList "
        foreach subArg $subArgsList subType $subArgTypesList {
          expandStructuredType $structureName $arg.$subArg $subType valueList 
        }
      }
    } else {
      lappend valueList $arg $g_NM_terminalTypeValuesArray($argType)
    }
  }
  # puts stderr "expandStructuredType: valueList $valueList"
}



## re-fill menu lists after creating or deleting a node
## 16dec97 wmt: new
proc updateMenuLists { classDefType } {
  global g_NM_terminalTypeList g_NM_terminalTypeValuesArray
  global pirEdge pirNode 

  set reportNotFoundP 0
  if {[string match $classDefType value] || \
          [string match $classDefType structure] || \
          [string match $classDefType abstraction]} {
    # if there is a current terminal edit dialog -- update it
    foreach child [winfo children .nodetype] {
      if {[regexp "askTerminalInstance" $child] || \
              [regexp "pirGetSensor" $child] || \
              [regexp "edge" $child]} {
        # .nodetype.askTerminalInstance -- new or existing terminal instance
        # .nodetype.pirGetSensor -- creating new edge instance 
        # .nodetype.edge -- existing edge instance
        if {[regexp "askTerminalInstance" $child]} {
          set optionMenuWidget $child.typeCommandMon.fType.optMenuButton
        } else {
          set optionMenuWidget $child.fType.optMenuButton
        }
        set state [lindex [$optionMenuWidget config -state] 4]
        set typeDefault [lindex [$optionMenuWidget config -text] 4]
        set dialogId [string range $child 1 end]
        set index [string first "." $dialogId]
        set dialogId [string range $dialogId [expr {1 + $index}] end] 
        # set str "updateMenuLists: child $child state $state typeDefault"
        # puts stderr "$str $typeDefault dialogId $dialogId "
        if {[string match $state normal]} {
          destroy $optionMenuWidget
          set state normal
          if {[regexp "askTerminalInstance" $child]} {
            set cmdMonTypeP 1
            tk_alphaOptionMenuCascade $optionMenuWidget \
                g_NM_optMenuTypeValue_$dialogId \
                $typeDefault g_NM_terminalTypeList $state $cmdMonTypeP $child
            pack $optionMenuWidget -side left -fill x
            set valuesList [assoc-array $typeDefault g_NM_terminalTypeValuesArray]
            balloonhelp $optionMenuWidget -side right \
                "values: [multiLineList $typeDefault $valuesList values:]"
          } else {
            if {[regexp "edge" $child]} {
              set index [string last "edge" $child]
              set pirEdgeIndex [string range $child [expr {$index + 4}] end]
              set terminalFrom [assoc terminalFrom pirEdge($pirEdgeIndex)]
              set terminalTo [assoc terminalTo pirEdge($pirEdgeIndex)]
              set terminalFromType [getTerminalType $terminalFrom]
              set terminalToType [getTerminalType $terminalTo]
            } else {
              # child => pirGetSensor__<nodeFromIndex>_<fromButtonNum>__
              #                         <nodeToIndex>_<toButtonNum>
              set indexFrom [string first "__" $child]
              set indexTo [string last "__" $child]
              set fromForm [string range $child [expr {$indexFrom + 2}] \
                                [expr {$indexTo - 1}]]
              set toForm [string range $child [expr {$indexTo + 2}] end]
              set index [string first "_" $fromForm]
              set fromPirIndex [string range $fromForm 0 [expr {$index - 1}]]
              set fromButtonNum [string range $fromForm [expr {1 + $index}] end]
              set index [string first "_" $toForm] 
              set toPirIndex [string range $toForm 0 [expr {$index - 1}]]
              set toButtonNum [string range $toForm [expr {1 + $index}] end]
              # puts stderr "fromForm $fromForm toForm $toForm"
              set outputs [assoc outputs pirNode($fromPirIndex)]
              set fromTerminalForm [assoc "out[expr {1 + $fromButtonNum}]" outputs]
              set terminalFromType [getTerminalType $fromTerminalForm]
              set inputs [assoc inputs pirNode($toPirIndex)]
              set toTerminalForm [assoc "in[expr {1 + $toButtonNum}]" inputs]
              set terminalToType [getTerminalType $toTerminalForm]
              # puts stderr "terminalFromType $terminalFromType terminalToType $terminalToType"
            }
            set abstractionTypeList [getAbstractionTypes $terminalFromType \
                                         $terminalToType]
            set terminalTypeP 0
            tk_alphaOptionMenuCascade $optionMenuWidget \
                g_NM_optMenuWidgetValue_$dialogId $typeDefault \
                abstractionTypeList $state $terminalTypeP 
            pack $optionMenuWidget -side left -fill x
          }
        }
      }
    }
  }
}


## update definitions instantiation cascade menus
## 10may98 wmt: new
proc updateInstantiationCascadeMenus { classDefType {classDefName ""} } {
  global g_NM_paletteDefcomponentList
  global g_NM_paletteDefmoduleList
  global g_NM_menuStem g_NM_l2ToolsP
  global g_NM_componentTestList g_NM_moduleTestList 
  
  # update "Edit->Instantiate" cascade menu
  set canvasRoot [getCanvasRoot 0]
  set instanceCascade $canvasRoot.$g_NM_menuStem.edit.m.instance
  set selectFunction instantiateDefinitionUpdate
  switch $classDefType {
    component {
      set menuList $g_NM_paletteDefcomponentList
      set menuLabelList $g_NM_paletteDefcomponentList 
      if {$g_NM_l2ToolsP} {
        generateCascadeMenu $canvasRoot.$g_NM_menuStem.test.m.scope \
            component "component" $g_NM_componentTestList \
            $g_NM_componentTestList selectTestScope
      }
    }
    module {
      set menuList $g_NM_paletteDefmoduleList
      set menuLabelList $g_NM_paletteDefmoduleList
      if {$g_NM_l2ToolsP} {
        generateCascadeMenu $canvasRoot.$g_NM_menuStem.test.m.scope \
            module "module" $g_NM_moduleTestList $g_NM_moduleTestList \
            selectTestScope
      }
      if {$classDefName != ""} {
        # called by fileOpen
        # do not allow module class to be instantiated into itself
        set newMenuList {}; set newMenuLabelList {}
        foreach item $menuList label $menuLabelList {
          if {$item != $classDefName} {
            lappend newMenuList $item
            lappend newMenuLabelList $label
          }
        }
        set menuList $newMenuList
        set menuLabelList $newMenuLabelList
      }
    }
  }
  # puts stderr "updateInstantiationCascadeMenus: menuList $menuList"
  generateCascadeMenu $instanceCascade $classDefType \
      [capitalizeWord $classDefType] $menuList $menuLabelList $selectFunction
}


## check for existence of maybeClassName in current class type - warn user and
##    allow replacement.
## check for existence of maybeClassName in other classe types - error
## all class names for all classe types (component, module, abstraction,
## structure, symbol, value) must be unique for jmpl
## 07mar00 wmt: new
proc checkPaletteLists { maybeClassName classType existsInClassTypePRef \
                           existsInOtherClassTypeRef } {
  upvar $existsInClassTypePRef existsInClassTypeP
  upvar $existsInOtherClassTypeRef existsInOtherClassType
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global g_NM_paletteStructureList g_NM_paletteDefvalueList 
  global g_NM_paletteDefsymbolList g_NM_paletteAbstractionList
  global g_NM_paletteDefrelationList 

  set existsInClassTypeP 0; set existsInOtherClassType ""
  # puts stderr "checkPaletteLists: classType $classType maybeClassName $maybeClassName"
  if {[lsearch -exact $g_NM_paletteAbstractionList $maybeClassName] >= 0} {
    if {[string match $classType abstraction]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType abstraction 
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteDefcomponentList $maybeClassName] >= 0} {
    if {[string match $classType component]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType component
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteDefmoduleList $maybeClassName] >= 0} {
    if {[string match $classType module]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType module
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteDefrelationList $maybeClassName] >= 0} {
    if {[string match $classType relation]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType relation
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteStructureList $maybeClassName] >= 0} {
    if {[string match $classType structure]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType structure
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteDefsymbolList $maybeClassName] >= 0} {
    if {[string match $classType symbol]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType symbol
    }
    return
  }
  if {[lsearch -exact $g_NM_paletteDefvalueList $maybeClassName] >= 0} {
    if {[string match $classType value]} {
      set existsInClassTypeP 1
    } else {
      set existsInOtherClassType value
    }
    return
  }
}


## create cascading menus for File->Open Definition
## and File->Delete Definition
## 16nov00 wmt: new
proc updateFileOpenDeleteCascadeMenus { {canvasRootId 0} } {
  global g_NM_paletteDefmoduleList g_NM_menuStem 
  global g_NM_paletteDefcomponentList 
  global g_NM_paletteStructureList g_NM_paletteDefvalueList 
  global g_NM_paletteDefsymbolList g_NM_paletteAbstractionList
  global g_NM_paletteDefrelationList g_NM_classTypes
  global g_NM_schematicMode 
  
  set canvasRoot [getCanvasRoot 0]
  set openInstanceCascade $canvasRoot.$g_NM_menuStem.file.m.open
  set deleteInstanceCascade $canvasRoot.$g_NM_menuStem.file.m.delete
  foreach classDefType $g_NM_classTypes {
    switch $classDefType {
      abstraction {
        set menuList $g_NM_paletteAbstractionList
        set menuLabelList $g_NM_paletteAbstractionList 
      }
      component {
        set menuList $g_NM_paletteDefcomponentList
        set menuLabelList $g_NM_paletteDefcomponentList 
      }
      module {
        set menuList $g_NM_paletteDefmoduleList
        set menuLabelList $g_NM_paletteDefmoduleList
      }
      relation {
        set menuList $g_NM_paletteDefrelationList
        set menuLabelList $g_NM_paletteDefrelationList 
      }
      structure {
        set menuList $g_NM_paletteStructureList
        set menuLabelList $g_NM_paletteStructureList 
      }
      symbol {
        set menuList $g_NM_paletteDefsymbolList
        set menuLabelList $g_NM_paletteDefsymbolList 
      }
      value {
        set menuList $g_NM_paletteDefvalueList
        set menuLabelList $g_NM_paletteDefvalueList 
      }
    }
    # puts stderr "updateFileOpenDeleteCascadeMenus: classDefType $classDefType menuList $menuList"
    if {[string match $g_NM_schematicMode "layout"] || \
            ([string match $g_NM_schematicMode "operational"] && \
                 ($canvasRootId == 0))} {
      generateCascadeMenu $openInstanceCascade $classDefType \
          [capitalizeWord $classDefType] $menuList $menuLabelList fileOpen
    }
    if {[string match $g_NM_schematicMode "layout"]} {
      generateCascadeMenu $deleteInstanceCascade $classDefType \
          [capitalizeWord $classDefType] $menuList $menuLabelList fileDelete
    }
  }
}


## check for conflict of instanceName with alrady instantiated class names
## 18jan02 wmt: consolidated into this proc
proc checkForClassNameConflict { instanceName className } {

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "checkForClassNameConflict: `$backtrace'"
  set conflictP 0
  checkPaletteLists $instanceName $className existsInClassTypeP \
      existsInOtherClassType
  if {$existsInClassTypeP} {
    set str "[capitalizeWord $className] definition name `$instanceName'"
    append str " exists\! \n Proceed?"
    set dialogList [list tk_dialog .d "WARNING" $str warning \
                        -1 {YES} {NO}]
    set response [eval $dialogList]
    if {$response == 1} {
      set conflictP 1
    }
  }
  if {$existsInOtherClassType != ""} {
    set str "Definition name `$instanceName' exists in"
    set str "$str [string toupper $existsInOtherClassType] class"
    set dialogList [list tk_dialog .d "ERROR" $str error \
                        -1 {DISMISS}]
    eval $dialogList
    set conflictP 1 
  }
  return $conflictP
}


## add parameter variables to g_NM_terminalTypeList, if their types
## are in g_NM_paletteStrucIsTerminalTypeParamList 
## 20feb02 wmt: new
proc getTerminalTypeListWithParams { } {
  global g_NM_classDefType g_NM_terminalTypeList 
  global g_NM_livingstoneDefcomponentArgList g_NM_livingstoneDefcomponentArgTypeList
  global g_NM_livingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgTypeList
  global g_NM_paletteStrucIsTerminalTypeParamList 

  set terminalTypeList $g_NM_terminalTypeList
  set argNameList $g_NM_livingstoneDefcomponentArgList
  set argTypeList $g_NM_livingstoneDefcomponentArgTypeList
  if {$g_NM_classDefType == "module"} {
    set argNameList $g_NM_livingstoneDefmoduleArgList
    set argTypeList $g_NM_livingstoneDefmoduleArgTypeList
  }
  foreach argName $argNameList argType $argTypeList {
    if {[lsearch -exact $g_NM_paletteStrucIsTerminalTypeParamList \
             $argType] >= 0} {
      lappend terminalTypeList $argName
    }
  }
  return $terminalTypeList
}


## 20feb02 wmt: new
proc getParameterType { parameterName } {
  global g_NM_classDefType g_NM_terminalTypeValuesArray 
  global g_NM_livingstoneDefcomponentArgList g_NM_livingstoneDefcomponentArgTypeList
  global g_NM_livingstoneDefmoduleArgList g_NM_livingstoneDefmoduleArgTypeList
  global g_NM_terminalTypeList 

  set parameterType ""
  set argNameList $g_NM_livingstoneDefcomponentArgList
  set argTypeList $g_NM_livingstoneDefcomponentArgTypeList
  if {$g_NM_classDefType == "module"} {
    set argNameList $g_NM_livingstoneDefmoduleArgList
    set argTypeList $g_NM_livingstoneDefmoduleArgTypeList
  }
  foreach argName $argNameList argType $argTypeList {
    if {[string match $parameterName $argName]} {
      set parameterType $argType
      break
    }
  }
  return $parameterType
}


## check for type => parent of children structs
## which exist for parameterized terminal types
## 28feb02 wmt: new
proc structIsTerminalTypeParamP { type } {
  global g_NM_paletteStrucIsTerminalTypeParamList 

  set terminalTypeParamP 0
  if {[lsearch -exact $g_NM_paletteStrucIsTerminalTypeParamList \
           $type] >= 0} {
    set terminalTypeParamP 1
  }
  return $terminalTypeParamP 
}


## return the parameterized terminal types which
## are the children of the structure class parent
## 28feb02 wmt: new 
proc getParameterizedTerminalTypes { structParentType } {
  global pirClassStructure g_NM_paletteStructureList 

  set valueList {}
  foreach classIndex $g_NM_paletteStructureList {
    set classVars [assoc class_variables pirClassStructure($classIndex)]
    if {[string match [getClassVarDefaultValue parentType classVars] \
             $structParentType]} {
      lappend valueList $classIndex
    }
  }
  return $valueList
}


