# $Id: assvEdit.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## editing for abstractions, structures, symbols, and values


## ask user for appropriate Lisp form and save it in a
## pirNode
## 03jul97 wmt: new
## 30mar98 wmt: added abstraction
proc editStructureSymbolValueForm { nodeClassType classDefName {caller ""}} {

  switch $nodeClassType {
    abstraction {
      editAbstractionForm $nodeClassType $classDefName $caller
    }
    relation {
      editRelationForm $nodeClassType $classDefName $caller
    }
    structure {
      editStructureForm $nodeClassType $classDefName $caller
    }
    symbol {
      editSymbolForm $nodeClassType $classDefName $caller
    }
    value {
      editValueForm $nodeClassType $classDefName $caller
    }
    default {
      error "editStructureSymbolValueForm: nodeClassType $nodeClassType no handled"
    }
  }
}


## abtractions are special cases of structures, that need to be
## grouped together, and have different dialog edit formats
## 30mar98 wmt: new
proc editAbstractionForm { nodeClassType classDefName caller } {
  global pirClassAbstraction g_NM_terminalTypeValuesArray
  global g_NM_nodeTypeRootWindow g_NM_readableJavaTokenRegexp
  global g_NM_currentCanvas g_NM_terminalTypeList 
  global g_NM_readableJavaFormRegexp 

  set pirClassIndex $classDefName
  set titleText "Edit Abstraction"
  set reportNotFoundP 0
  # make structure prefix acceptable as a tcl path
  regsub "\\\." $classDefName "_" classDefNamePath
  set dialogW $g_NM_nodeTypeRootWindow.${nodeClassType}_${classDefNamePath}
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0; set state normal
  if {[classDefReadOnlyP $nodeClassType $classDefName] || \
          ($caller == "fileDelete")} {
    set state disabled
    set titleText "View Abstraction"
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised -state $state \
      -command [list editAbstractionFormUpdate $dialogW \
                    $nodeClassType $pirClassIndex] 
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP" 
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  if {[regexp "newname" $pirClassIndex]} {
    set nameDefault {}; set argsDefault {}; set docInput {}; set formInput {}
    set defaultFromType <unspecified>; set defaultToType <unspecified>
     set defaultFromVar "this"; set defaultToVar ""
  } else {
    set indx [string first "." $classDefName]
    set nameDefault [string range $classDefName [expr {$indx + 1}] end]
    set classVars [assoc class_variables pirClassAbstraction($pirClassIndex)]
    set argsDefault [getClassVarDefaultValue args classVars]
    set docInput [getClassVarDefaultValue documentation classVars]
    set formInput [getClassVarDefaultValue form classVars]
    if {[assoc argTypes classVars $reportNotFoundP] == ""} {
      # old abstraction form
      set argsList [getClassVarDefaultValue args classVars]
      set defaultFromType [lindex $argsList 0]
      set defaultToType [lindex $argsList 1]
      set defaultFromVar "this"
      set defaultToVar ""
    } else {
      set argTypesList [getClassVarDefaultValue argTypes classVars]
      set defaultFromType [lindex $argTypesList 0]
      set defaultToType [lindex $argTypesList 1]
      set argsList [getClassVarDefaultValue args classVars]
      set defaultFromVar "this" 
      set defaultToVar [lindex $argsList 1]
    }
  }

  set widget $dialogW.fabstractionName
  set description "Name" 
  mkEntryWidget $widget  "" $description $nameDefault $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"

  set terminalTypeP 1

  frame $dialogW.fromtypeVar -background $bgcolor 
  frame $dialogW.fromtypeVar.type -background $bgcolor
  label $dialogW.fromtypeVar.type.title -text "From Type" -relief flat -anchor w
  $dialogW.fromtypeVar.type.title configure -takefocus 0
  global g_NM_optMenuWidgetValueFrom_$dialogId 
  set g_NM_optMenuWidgetValueFrom_$dialogId $defaultFromType 

  tk_alphaOptionMenuCascade $dialogW.fromtypeVar.type.optMenuButton \
      g_NM_optMenuWidgetValueFrom_$dialogId $defaultFromType \
      g_NM_terminalTypeList $state $terminalTypeP
  set valuesList [assoc-array $defaultFromType g_NM_terminalTypeValuesArray] 
  balloonhelp $dialogW.fromtypeVar.type.optMenuButton -side right \
      "values: [multiLineList $defaultFromType $valuesList values:]"
  pack $dialogW.fromtypeVar.type.title \
      $dialogW.fromtypeVar.type.optMenuButton -side top -fill x

  frame $dialogW.fromtypeVar.var -background $bgcolor
  set widget $dialogW.fromtypeVar.var.fabstractionFromVar
  set description "From Var" 
  mkEntryWidget $widget  "" $description $defaultFromVar disabled
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  pack $dialogW.fromtypeVar.var $dialogW.fromtypeVar.type -side left -fill both \
      -ipadx 20
  pack $dialogW.fromtypeVar -fill x

  frame $dialogW.totypeVar -background $bgcolor 
  frame $dialogW.totypeVar.type -background $bgcolor
  label $dialogW.totypeVar.type.title -text "To Type" -relief flat -anchor w
  $dialogW.totypeVar.type.title configure -takefocus 0
  global g_NM_optMenuWidgetValueTo_$dialogId 
  set g_NM_optMenuWidgetValueTo_$dialogId $defaultToType 

  tk_alphaOptionMenuCascade $dialogW.totypeVar.type.optMenuButton \
      g_NM_optMenuWidgetValueTo_$dialogId $defaultToType \
      g_NM_terminalTypeList $state $terminalTypeP
  set valuesList [assoc-array $defaultToType g_NM_terminalTypeValuesArray] 
  balloonhelp $dialogW.totypeVar.type.optMenuButton -side right \
      "values: [multiLineList $defaultToType $valuesList values:]"
  pack $dialogW.totypeVar.type.title \
      $dialogW.totypeVar.type.optMenuButton -side top -fill x

  frame $dialogW.totypeVar.var -background $bgcolor
  set widget $dialogW.totypeVar.var.fabstractionToVar
  set description "To Var" 
  mkEntryWidget $widget  "" $description $defaultToVar $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  pack $dialogW.totypeVar.var $dialogW.totypeVar.type -side left -fill both \
      -ipadx 20
  pack $dialogW.totypeVar -fill x

  set attributeName form
  frame $dialogW.form
  frame $dialogW.form.ftitle -background $bgcolor
  label $dialogW.form.ftitle.title -text "Constraints" -relief flat -anchor w 
  $dialogW.form.ftitle.title configure -takefocus 0
  pack $dialogW.form.ftitle.title -side left
  pack $dialogW.form.ftitle -side top -fill both
  pack $dialogW.form -side top
  set attributeName form; set pirEdgeIndex 0
  global g_NM_abstractionFormInput_$dialogId 
  set g_NM_abstractionFormInput_$dialogId $formInput
  createEmacsTextWidget $dialogId $dialogW formEmacs $nodeClassType $attributeName \
      $state $pirEdgeIndex 
  balloonhelp $dialogW.formEmacs.t -side top $g_NM_readableJavaFormRegexp

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x
  label $dialogW.doctitle -text "Documentation" -relief flat \
      -anchor w 
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both
  set attributeName documentation 
  global g_NM_abstractionDocInput_$dialogId 
  set g_NM_abstractionDocInput_$dialogId $docInput
  createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 

  frame $dialogW.sp
  label $dialogW.sp.spacer -text "" -relief flat -anchor w 
  $dialogW.sp.spacer configure -takefocus 0
  pack $dialogW.sp.spacer -side top -fill both
  pack $dialogW.sp -side top -fill x

  keepDialogOnScreen $dialogW

  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    ## focus $dialogW # handled in askClassInstance
    tkwait window $dialogW
  }
}


## abtractions are special cases of structures, that need to be
## grouped together, and have different dialog edit formats
## 30mar98 wmt: new 
proc editAbstractionFormUpdate { dialogW nodeClassType pirClassIndex } {
  global g_NM_classDefType g_NM_classTypes 
  global pirClassAbstraction pirClassesAbstraction 
  global g_NM_pirClassASSVTemplate pirFileInfo 

  set dialogId [getDialogId $dialogW]

  set inputClassDefName [$dialogW.fabstractionName.fentry.entry get]
  set inputClassDefName [string trim $inputClassDefName " "]
  if {! [entryValueErrorCheck "Name" "(javaToken)" $inputClassDefName]} {
    return
  }
  if {[string match $inputClassDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "`Name' not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  set terminalVarFrom [$dialogW.fromtypeVar.var.fabstractionFromVar.fentry.entry get]
  if {[string match $terminalVarFrom ""]} {
    set dialogList [list tk_dialog .d "ERROR" "`From Var' not entered" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  if {! [entryValueErrorCheck "From Var" "(javaToken)" $terminalVarFrom]} {
    return
  }

  global g_NM_optMenuWidgetValueFrom_$dialogId
  set terminalTypeFrom [subst $[subst g_NM_optMenuWidgetValueFrom_$dialogId]]
  if {[string match $terminalTypeFrom "<unspecified>"]} {
    set dialogList [list tk_dialog .d "ERROR" "`From Type' not entered" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }

  set classDefName "$terminalTypeFrom.$inputClassDefName"
  if {[regexp "newname" $pirClassIndex] || \
          (! [string match $pirClassIndex $classDefName])} {
    if {[classDefReadOnlyP $nodeClassType $classDefName]} {
      set str "Definition $classDefName is READ-ONLY"
      set dialogList [list tk_dialog .d "ERROR" $str error \
                          0 {DISMISS}]
      eval $dialogList
      return     
    }
    if {[checkForReservedNames $inputClassDefName]} {
      return
    }
    if {[checkForClassNameConflict $classDefName abstraction]} {
      return
    }
    if {[checkForClassNameConflict $inputClassDefName abstraction]} {
      return
    }
  }
  set argsList {}; lappend argsList $terminalVarFrom
  set argTypesList {}; lappend argTypesList $terminalTypeFrom

  set terminalVarTo [$dialogW.totypeVar.var.fabstractionToVar.fentry.entry get]
  if {[string match $terminalVarTo ""]} {
    # terminalVarTo not required
#     set dialogList [list tk_dialog .d "ERROR" "`To Var' not entered" error \
#                         0 {DISMISS}]
#     eval $dialogList
#     return
  } else {
    if {! [entryValueErrorCheck "To Var" "(javaToken)" $terminalVarTo]} {
      return
    }

    global g_NM_optMenuWidgetValueTo_$dialogId
    set terminalTypeTo [subst $[subst g_NM_optMenuWidgetValueTo_$dialogId]]
    if {[string match $terminalTypeTo "<unspecified>"]} {
      set dialogList [list tk_dialog .d "ERROR" "`To Type' not entered" error \
                          0 {DISMISS}]
      eval $dialogList
      return
    }
    lappend argsList $terminalVarTo
    lappend argTypesList $terminalTypeTo 
  }

  # saveTextWidget puts form into global var
  if {[saveTextWidget $dialogId $dialogW.formEmacs $nodeClassType form \
           "(javaMplForm)"]} {
    return
  }
  set formInput [getTextWidgetText $dialogId $nodeClassType form 0]
  terminateJmplForm formInput
  if {[string match $formInput ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "`Constraints' not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  # saveTextWidget puts documentation into global vars
  saveTextWidget $dialogId $dialogW.text $nodeClassType documentation \
      (all_characters)
  set docInput [getTextWidgetText $dialogId $nodeClassType \
                            documentation 0]

  # prefix class with fromType - structure parentClass
  set parentClassDefName $terminalTypeFrom
  set pirClassIndex $classDefName
  set internalVars $g_NM_pirClassASSVTemplate 
  set classVars [assoc class_variables internalVars]
  setClassVarDefaultValue args $argsList classVars
  setClassVarDefaultValue argTypes $argTypesList classVars
  setClassVarDefaultValue form $formInput classVars
  setClassVarDefaultValue documentation $docInput classVars
  arepl class_variables $classVars internalVars
  # if pirClassIndex is already defined, this will overlay it
  set pirClassAbstraction($pirClassIndex) $internalVars 
  acons nodeClassType $nodeClassType pirClassAbstraction($pirClassIndex)
  if {[lsearch -exact $pirClassesAbstraction $pirClassIndex] == -1} {
    lappend pirClassesAbstraction $pirClassIndex
  }
  destroy $dialogW

  # write schematic file
  set headerUpdateOnlyP 0
  set jmplModified $pirFileInfo(jmpl_modified)
  set pirFileInfo(jmpl_modified) 1

  fileSave $nodeClassType $classDefName $headerUpdateOnlyP $parentClassDefName 

  set pirFileInfo(jmpl_modified) $jmplModified 
}


## relations can be defined for value types only
proc editRelationForm { nodeClassType classDefName caller } {
  global pirClassRelation g_NM_relationDocInput
  global g_NM_nodeTypeRootWindow g_NM_terminalTypeList 
  global g_NM_relationFormInput g_NM_currentCanvas
  global g_NM_schematicMode g_NM_paletteDefvalueList 
  global g_NM_terminalTypeValuesArray g_NM_readableJavaTokenRegexp
  global g_NM_readable01JavaTokenRegexp g_NM_readableJavaFormRegexp

  set pirClassIndex $classDefName
  set titleText "Edit Relation"
  set state normal; set reportNotFoundP 0

  set dialogW $g_NM_nodeTypeRootWindow.${nodeClassType}_${classDefName}
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0
  if {[classDefReadOnlyP $nodeClassType $classDefName] || \
          ($caller == "fileDelete")} {
    set state disabled
    set titleText "View Relation"
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  if {[regexp "newname" $pirClassIndex]} {
    set nameDefault ""; set argsVarsDefaultList {}; set g_NM_relationDocInput {}
    set g_NM_relationFormInput {}
    set argsTypesDefaultList { <unspecified> <unspecified> <unspecified> <unspecified> }
    set numArgs 4
  } else {
    set nameDefault $pirClassIndex
    # puts stderr "editRelationForm: classDefName $pirClassIndex "
    set classVars [assoc class_variables pirClassRelation($pirClassIndex)]
    set argsVarsDefaultList [getClassVarDefaultValue args classVars]
    set argsTypesDefaultList [getClassVarDefaultValue argTypes classVars]
    set numArgs [expr {[llength $argsVarsDefaultList] + 2}]
    set g_NM_relationDocInput [getClassVarDefaultValue documentation classVars]
    set g_NM_relationFormInput [getClassVarDefaultValue form classVars]
  }

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised -state $state \
      -command [list editRelationFormUpdate $dialogW \
                    $nodeClassType $pirClassIndex $numArgs]
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  set cmdMonTypeP 0
  set widget $dialogW.frelationName
  set description "Name" 
  mkEntryWidget $widget  "" $description $nameDefault $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  
  for {set i 0} {$i < $numArgs} {incr i} {
    frame $dialogW.param$i -bg $bgcolor 
    frame $dialogW.param$i.fType -background $bgcolor 
    label $dialogW.param$i.fType.typetitle -text \
        "Argument Type [expr {$i + 1}]" -relief flat -anchor w 
    $dialogW.param$i.fType.typetitle configure -takefocus 0
    set defaultTypeValue [lindex $argsTypesDefaultList $i]
    if {$defaultTypeValue == ""} { set defaultTypeValue "<unspecified>" }
    tk_alphaOptionMenuCascade $dialogW.param$i.fType.optMenuButton \
        g_NM_optMenuTypeValue_${dialogId}_param$i \
        $defaultTypeValue g_NM_terminalTypeList $state \
        $cmdMonTypeP $dialogW.param$i
    set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 

    balloonhelp $dialogW.param$i.fType.optMenuButton -side right \
        "values: [multiLineList $defaultTypeValue $valuesList values:]"
    pack $dialogW.param$i.fType.typetitle \
        $dialogW.param$i.fType.optMenuButton -side top -fill x 

    set widgetVar $dialogW.param$i.var
    if {$i == 0} {
      set defaultValue this
      set varState disabled
    } else {
      set defaultValue [lindex $argsVarsDefaultList $i]
      set varState $state 
    }
    set description "Argument Variable [expr {$i + 1}]"
    mkEntryWidget $widgetVar "" $description $defaultValue $varState
    if {$i < 2} {
      # at least two args are required
      balloonhelp $widgetVar.label.descrp -side right $g_NM_readableJavaTokenRegexp
    } else {
      balloonhelp $widgetVar.label.descrp -side right \
          $g_NM_readable01JavaTokenRegexp
    }
    balloonhelp $widgetVar.pad.left -side right \
        "<tab> to next field;  <shift-tab> to prev"
    pack $dialogW.param$i.fType $widgetVar -side left \
        -fill both -ipadx 20
    pack $dialogW.param$i -side top -fill x
  }

  set attributeName form
  frame $dialogW.form
  frame $dialogW.form.ftitle -background $bgcolor
  label $dialogW.form.ftitle.title -text "Constraints" -relief flat -anchor w 
  $dialogW.form.ftitle.title configure -takefocus 0
  pack $dialogW.form.ftitle.title -side left
  pack $dialogW.form.ftitle -side top -fill both
  pack $dialogW.form -side top
  set attributeName form; set pirEdgeIndex 0
  global g_NM_relationFormInput_$dialogId 
  set g_NM_relationFormInput_$dialogId $g_NM_relationFormInput
  createEmacsTextWidget $dialogId $dialogW formEmacs $nodeClassType $attributeName \
      $state $pirEdgeIndex 
  balloonhelp $dialogW.formEmacs.t -side top $g_NM_readableJavaFormRegexp

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x
  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w 
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both
  set attributeName documentation 
  global g_NM_relationDocInput_$dialogId 
  set g_NM_relationDocInput_$dialogId $g_NM_relationDocInput
  createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 

  frame $dialogW.sp
  label $dialogW.sp.spacer -text "" -relief flat -anchor w 
  $dialogW.sp.spacer configure -takefocus 0
  pack $dialogW.sp.spacer -side top -fill both
  pack $dialogW.sp -side top -fill x

  keepDialogOnScreen $dialogW
  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    ## focus $dialogW # handled in askClassInstance
    tkwait window $dialogW
  }
}


proc editRelationFormUpdate { dialogW nodeClassType pirClassIndex numArgs } {
  global g_NM_relationFormInput g_NM_classDefType
  global pirClassRelation g_NM_relationDocInput pirFileInfo 
  global g_NM_pirClassASSVTemplate pirClassesRelation g_NM_classTypes 

  set dialogId [getDialogId $dialogW]

  set classDefName [$dialogW.frelationName.fentry.entry get]
  set classDefName [string trim $classDefName " "]

  if {! [entryValueErrorCheck "Name" "(javaToken)" $classDefName]} {
    return
  }
  if {[string match $classDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "Name not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  if {[regexp "newname" $pirClassIndex] || \
          (! [string match $pirClassIndex $classDefName])} {
    if {[classDefReadOnlyP $nodeClassType $classDefName]} {
      set str "Definition $classDefName is READ-ONLY"
      set dialogList [list tk_dialog .d "ERROR" $str error \
                          0 {DISMISS}]
      eval $dialogList
      return     
    }
    if {[checkForReservedNames $classDefName]} {
      return
    }
    if {[checkForClassNameConflict $classDefName relation]} {
      return
    }
  }

  set relationVarList {}
  set relationVarTypeList {}
  for {set i 0} {$i < $numArgs} {incr i} {
    # arg variable name
    set argVar [$dialogW.param$i.var.fentry.entry get]
    set fieldName "Argument Variable [expr {$i + 1}]"
    set argVar [string trim $argVar " "]
    if {$argVar == ""} {
      if {$i < 2} {
        # one value required
        set dialogList [list tk_dialog .d \
                            "ERROR" "$fieldName not entered" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      } else {
        # no more args
        break
      }
    }
    if {! [entryValueErrorCheck $fieldName "(javaToken)" $argVar]} {
      return
    }
    lappend relationVarList $argVar 
    # arg variable type
    global g_NM_optMenuTypeValue_${dialogId}_param$i
    set argType [subst $[subst g_NM_optMenuTypeValue_${dialogId}_param$i]]
    if {[string match $argType "<unspecified>"]} {
      set dialogList [list tk_dialog .d "ERROR" \
                          "`Argument Type [expr {$i + 1}]' not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    # puts stderr "editRelationFormUpdate: argVar $argVar argType $argType"
    lappend relationVarTypeList $argType 
  }

  # saveTextWidget puts form into global var
  if {[saveTextWidget $dialogId $dialogW.formEmacs relation form \
           "(0-n_javaMplForms)"]} {
    return
  }
  set relationFormInput [getTextWidgetText $dialogId relation form 0]
  terminateJmplForm relationFormInput
  # constraints are optional
#   if {[string match $relationFormInput ""]} {
#     set dialogList [list tk_dialog .d \
#                         "ERROR" "Form not entered" \
#                         error 0 {DISMISS}]
#     eval $dialogList
#     return
#   }

  # saveTextWidget puts documentation into global vars
  saveTextWidget $dialogId $dialogW.text relation documentation (all_characters)
  set relationDocInput [getTextWidgetText $dialogId relation documentation 0]

  set pirClassIndex $classDefName
  set internalVars $g_NM_pirClassASSVTemplate 
  set classVars [assoc class_variables internalVars]
  setClassVarDefaultValue args $relationVarList classVars
  setClassVarDefaultValue argTypes $relationVarTypeList classVars
  setClassVarDefaultValue form $relationFormInput classVars
  setClassVarDefaultValue documentation $relationDocInput classVars
  arepl class_variables $classVars internalVars
  # if pirClassIndex is already defined, this will overlay it
  set pirClassRelation($pirClassIndex) $internalVars 
  acons nodeClassType $nodeClassType pirClassRelation($pirClassIndex)
  if {[lsearch -exact $pirClassesRelation $pirClassIndex] == -1} {
    lappend pirClassesRelation $pirClassIndex
  }
  destroy $dialogW

  # write schematic file
  set jmplModified $pirFileInfo(jmpl_modified)
  set pirFileInfo(jmpl_modified) 1

  fileSave $nodeClassType $classDefName

  set pirFileInfo(jmpl_modified) $jmplModified 
}


## 14nov97 wmt: give structure the same look-and-feel as other dialogs
proc editStructureForm { nodeClassType classDefName caller } {
  global pirClassStructure g_NM_structureDocInput
  global g_NM_nodeTypeRootWindow pirClassesStructure 
  global g_NM_structureFormInput g_NM_currentCanvas
  global g_NM_schematicMode g_NM_readableJavaTokenRegexp
  global g_NM_terminalTypeList g_NM_terminalTypeValuesArray
  global g_NM_paletteStructureList g_NM_readable01JavaTokenRegexp
  global g_NM_readableJavaFormRegexp 

  set pirClassIndex $classDefName
  set titleText "Edit Structure"
  set state normal; set reportNotFoundP 0

  set dialogW $g_NM_nodeTypeRootWindow.${nodeClassType}_${classDefName}
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0
  if {[classDefReadOnlyP $nodeClassType $classDefName] || \
          ($caller == "fileDelete")} {
    set state disabled
    set titleText "View Structure"
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  if {[regexp "newname" $pirClassIndex]} {
    set nameDefault ""; set argsVarsDefaultList {}; set g_NM_structureDocInput {}
    set g_NM_structureFormInput {}
    set argsTypesDefaultList { <unspecified> <unspecified> <unspecified> }
    set argsLocationsDefaultList { <unspecified> <unspecified> <unspecified> }
    set defaultParentType <unspecified>
    set defaultTermTypeParam 0
    set numArgs 6
  } else {
    set nameDefault $pirClassIndex
    set classVars [assoc class_variables pirClassStructure($pirClassIndex)]
    if {[assoc argTypes classVars $reportNotFoundP] == ""} {
      # old structure form
      set argsVarsDefaultList [getClassVarDefaultValue args classVars]
      set argsTypesDefaultList {}; set numArgs 0
      set argsLocationsDefaultList {}
      foreach var $argsVarsDefaultList {
        lappend argsTypesDefaultList <unspecified>
        lappend argsLocationsDefaultList <unspecified>
        incr numArgs 
      }
      set defaultParentType <unspecified>
      # add three for addditional args
      lappend argsTypesDefaultList <unspecified>; incr numArgs 
      lappend argsTypesDefaultList <unspecified>; incr numArgs   
      lappend argsTypesDefaultList <unspecified>; incr numArgs   
    } else {
      set defaultParentType [getClassVarDefaultValue parentType classVars] 
      set argsVarsDefaultList [getClassVarDefaultValue args classVars]
      set argsTypesDefaultList [getClassVarDefaultValue argTypes classVars]
      if {[assoc argsLocations classVars $reportNotFoundP] == ""} {
        set argsLocationsDefaultList \
            [generateStructureArgsLocations $defaultParentType \
                 $argsVarsDefaultList $argsTypesDefaultList]
      } else {
        set argsLocationsDefaultList [getClassVarDefaultValue argLocations classVars]
      }
      # puts stderr "editStructureForm: argsLocationsDefaultList $argsLocationsDefaultList"
      set numArgs [expr {[llength $argsVarsDefaultList] + 3}]
      if {[assoc terminalTypeParamP classVars $reportNotFoundP] == ""} {
        set defaultTermTypeParam 0
      } else {
        set defaultTermTypeParam [getClassVarDefaultValue terminalTypeParamP \
                                      classVars]
      }
    }
    set g_NM_structureDocInput [getClassVarDefaultValue documentation classVars]
    set g_NM_structureFormInput [getClassVarDefaultValue form classVars]
  }
  set defaultTermTypeParam [lindex {no yes} $defaultTermTypeParam]

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised -state $state \
      -command [list editStructureFormUpdate $dialogW \
                    $nodeClassType $pirClassIndex $numArgs]
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  # structure Edit parent class type, which is a structure type
  # replace args & argTypes, if any, with parent args & argTypes,
  # and make them disabled
  set cmdMonTypeP 0
  frame $dialogW.name_parentType -bg $bgcolor
  frame $dialogW.name_parentType.pType -bg $bgcolor 
  label $dialogW.name_parentType.pType.typetitle -text \
      "Parent Type" -relief flat -anchor w 
  $dialogW.name_parentType.pType.typetitle configure -takefocus 0
  # donot let user select parentType = itself
  set cascadeList $g_NM_paletteStructureList
  lremove cascadeList $nameDefault
  lappend cascadeList "<unspecified>"
  tk_alphaOptionMenuCascade \
      $dialogW.name_parentType.pType.optMenuButton \
      g_NM_optMenuTypeValue_${dialogId}_nameParentType \
      $defaultParentType cascadeList $state $cmdMonTypeP $dialogW.name_parentType
  if {$defaultParentType == ""} {
    set valuesList {}
  } else {
    set valuesList [assoc-array $defaultParentType g_NM_terminalTypeValuesArray] 
  }
  balloonhelp $dialogW.name_parentType.pType.optMenuButton -side right \
      "values: [multiLineList $defaultParentType $valuesList values:]"
  pack $dialogW.name_parentType.pType.typetitle \
      $dialogW.name_parentType.pType.optMenuButton \
      -side top -fill x 

  frame $dialogW.name_parentType.pTermTypeParam -bg $bgcolor 
  label $dialogW.name_parentType.pTermTypeParam.title -text \
      "Parameterized Terminal Type" -relief flat -anchor w 
  $dialogW.name_parentType.pTermTypeParam.title configure -takefocus 0
  set cascadeList {no yes}
  tk_alphaOptionMenuCascade \
      $dialogW.name_parentType.pTermTypeParam.optMenuButton \
      g_NM_optMenuTypeValue_${dialogId}_termTypeParamP \
      $defaultTermTypeParam cascadeList $state $cmdMonTypeP \
      $dialogW.termTypeParamP
  pack $dialogW.name_parentType.pTermTypeParam.title \
      $dialogW.name_parentType.pTermTypeParam.optMenuButton \
      -side top 

  set widget $dialogW.name_parentType.fstructureName
  set description "Name" 
  mkEntryWidget $widget  "" $description $nameDefault $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  
  pack $widget $dialogW.name_parentType.pType $dialogW.name_parentType.pTermTypeParam \
      -side left -fill both -ipadx 20
  pack $dialogW.name_parentType -side top -fill x

  set typeCascadeList [concat $g_NM_terminalTypeList "<unspecified>"] 
  for {set i 0} {$i < $numArgs} {incr i} {


    frame $dialogW.param$i -bg $bgcolor 
    frame $dialogW.param$i.fType -background $bgcolor 
    label $dialogW.param$i.fType.typetitle -text \
        "Argument Type [expr {$i + 1}]" -relief flat -anchor w 
    $dialogW.param$i.fType.typetitle configure -takefocus 0
    set defaultTypeValue [lindex $argsTypesDefaultList $i]
    if {$defaultTypeValue == ""} { set defaultTypeValue "<unspecified>" }
    set locationState $state
    if {($state == "normal") && \
            ([lindex $argsLocationsDefaultList $i] == "parent")} {
      set locationState disabled
    }
    tk_alphaOptionMenuCascade $dialogW.param$i.fType.optMenuButton \
        g_NM_optMenuTypeValue_${dialogId}_param$i \
        $defaultTypeValue typeCascadeList $locationState $cmdMonTypeP $dialogW.param$i
    set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 

    balloonhelp $dialogW.param$i.fType.optMenuButton -side right \
        "values: [multiLineList $defaultTypeValue $valuesList values:]"
    pack $dialogW.param$i.fType.typetitle \
        $dialogW.param$i.fType.optMenuButton -side top -fill x 

    set widgetVar $dialogW.param$i.var
    set defaultValue [lindex $argsVarsDefaultList $i]
    set description "Argument Variable [expr {$i + 1}]"
    mkEntryWidget $widgetVar "" $description $defaultValue $locationState
    if {$i < 2} {
      # at least two args are required
      balloonhelp $widgetVar.label.descrp -side right $g_NM_readableJavaTokenRegexp
    } else {
      balloonhelp $widgetVar.label.descrp -side right \
          $g_NM_readable01JavaTokenRegexp
    }
    balloonhelp $widgetVar.pad.left -side right \
        "<tab> to next field;  <shift-tab> to prev"
    pack $dialogW.param$i.fType $widgetVar -side left \
        -fill both -ipadx 20
    pack $dialogW.param$i -side top -fill x
  }

  set attributeName form
  frame $dialogW.form
  frame $dialogW.form.ftitle -background $bgcolor
  label $dialogW.form.ftitle.title -text "Constraints" -relief flat -anchor w 
  $dialogW.form.ftitle.title configure -takefocus 0
  pack $dialogW.form.ftitle.title -side left
  pack $dialogW.form.ftitle -side top -fill both
  pack $dialogW.form -side top
  set attributeName form; set pirEdgeIndex 0
  global g_NM_structureFormInput_$dialogId 
  set g_NM_structureFormInput_$dialogId $g_NM_structureFormInput
  createEmacsTextWidget $dialogId $dialogW formEmacs $nodeClassType $attributeName \
      $state $pirEdgeIndex 
  balloonhelp $dialogW.formEmacs.t -side top $g_NM_readableJavaFormRegexp

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x
  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w 
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both
  set attributeName documentation 
  global g_NM_structureDocInput_$dialogId 
  set g_NM_structureDocInput_$dialogId $g_NM_structureDocInput
  createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 

  frame $dialogW.sp
  label $dialogW.sp.spacer -text "" -relief flat -anchor w 
  $dialogW.sp.spacer configure -takefocus 0
  pack $dialogW.sp.spacer -side top -fill both
  pack $dialogW.sp -side top -fill x

  keepDialogOnScreen $dialogW
  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    ## focus $dialogW # handled in askClassInstance
    tkwait window $dialogW
  }
}


## generate Structure field definition locations
## 01jul02 wmt: new
proc generateStructureArgsLocations { defaultParentType \
                                          argsVarsDefaultList argsTypesDefaultList} {
  global pirClassStructure pirClassesStructure

  set argsLocationsDefaultList {}; set silentP 1
  if {$defaultParentType != "<unspecified>"} {
    if {[lsearch -exact $pirClassesStructure $defaultParentType] == -1} { 
      read_workspace structure $defaultParentType $silentP
    }
    set parentClassVars [assoc class_variables \
                             pirClassStructure($defaultParentType)]
    set argsVarsParentDefList [getClassVarDefaultValue args parentClassVars]
    set argsTypesParentDefList [getClassVarDefaultValue argTypes parentClassVars]
  } else {
    set argsVarsParentDefList {}
    set argsTypesParentDefList {}
  }
  foreach var $argsVarsDefaultList type $argsTypesDefaultList {
    set matchP 0
    foreach parentVar $argsVarsParentDefList parentType $argsTypesParentDefList {
      if {[string match $var $parentVar] && \
              [string match $type $parentType]} {
        set matchP 1; break
      }
    }
    if {$matchP} {
      lappend argsLocationsDefaultList parent
    } else {
      lappend argsLocationsDefaultList local
    }
  }
  return $argsLocationsDefaultList;
}


## define pirClass for form
## 14nov97 wmt: new
proc editStructureFormUpdate { dialogW nodeClassType pirClassIndex numArgs } {
  global g_NM_structureFormInput g_NM_classDefType
  global pirClassStructure g_NM_structureDocInput 
  global g_NM_pirClassASSVTemplate pirClassesStructure pirFileInfo
  global g_NM_paletteStrucIsTerminalTypeParamList
  global g_NM_generatedMPLExtension 

  set dialogId [getDialogId $dialogW]

  set classDefName [$dialogW.name_parentType.fstructureName.fentry.entry get]
  set classDefName [string trim $classDefName " "]
  if {! [entryValueErrorCheck "Name" "(javaToken)" $classDefName]} {
    return
  }
  if {[string match $classDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "Name not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[regexp "newname" $pirClassIndex] || \
          (! [string match $pirClassIndex $classDefName])} {
    if {[classDefReadOnlyP $nodeClassType $classDefName]} {
      set str "Definition $classDefName is READ-ONLY"
      set dialogList [list tk_dialog .d "ERROR" $str error \
                          0 {DISMISS}]
      eval $dialogList
      return     
    }
    if {[checkForReservedNames $classDefName]} {
      return
    }
    if {[checkForClassNameConflict $classDefName structure]} {
      return
    }
  }

  # parent type
  global g_NM_optMenuTypeValue_${dialogId}_nameParentType
  set parentType [subst $[subst g_NM_optMenuTypeValue_${dialogId}_nameParentType]]

  # parameterized terminal type: yes/no
  global g_NM_optMenuTypeValue_${dialogId}_termTypeParamP 
  set terminalTypeParamP [subst $[subst g_NM_optMenuTypeValue_${dialogId}_termTypeParamP]]
  if {$terminalTypeParamP == "no"} {
    set terminalTypeParamP 0
  } else {
    set terminalTypeParamP 1
  }
  if {($parentType != "<unspecified>") && $terminalTypeParamP} {
    set str "To be a parameterized terminal type, \nthis class must *not* have a parent type"
    set dialogList [list tk_dialog .d "ERROR" $str error \
                        0 {DISMISS}]
    eval $dialogList
    return     
  }

  set structureVarList {}
  set structureVarTypeList {}
  for {set i 0} {$i < $numArgs} {incr i} {
    # arg variable name
    set argVar [$dialogW.param$i.var.fentry.entry get]
    set fieldName "Argument Variable [expr {$i + 1}]"
    set argVar [string trim $argVar " "]
    if {$argVar == ""} {
      if {(! $terminalTypeParamP) && ($i < 1)} {
        # at least one value required, when not a parameterized terminal type
        set dialogList [list tk_dialog .d \
                            "ERROR" "$fieldName not entered" \
                            error 0 {DISMISS}]
        eval $dialogList
        return
      } else {
        # no more args
        break
      }
      break
    }
    if {! [entryValueErrorCheck $fieldName "(javaToken)" $argVar]} {
      return
    }
    lappend structureVarList $argVar 
    # arg variable type
    global g_NM_optMenuTypeValue_${dialogId}_param$i
    set argType [subst $[subst g_NM_optMenuTypeValue_${dialogId}_param$i]]
    if {[string match $argType "<unspecified>"]} {
      set dialogList [list tk_dialog .d "ERROR" \
                          "`Argument Type [expr {$i + 1}]' not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    # puts stderr "editStructureFormUpdate: argVar $argVar argType $argType"
    lappend structureVarTypeList $argType 
  }

  # saveTextWidget puts form into global var
  if {[saveTextWidget $dialogId $dialogW.formEmacs structure form \
           "(0-n_javaMplForms)"]} {
    return
  }
  set structureFormInput [getTextWidgetText $dialogId structure form 0]
  terminateJmplForm structureFormInput
  # constraints are optional
#   if {[string match $structureFormInput ""]} {
#     set dialogList [list tk_dialog .d \
#                         "ERROR" "Form not entered" \
#                         error 0 {DISMISS}]
#     eval $dialogList
#     return
#   }

  # saveTextWidget puts documentation into global vars
  saveTextWidget $dialogId $dialogW.text structure documentation (all_characters)
  set structureDocInput [getTextWidgetText $dialogId structure documentation 0]

  set pirClassIndex $classDefName
  set internalVars $g_NM_pirClassASSVTemplate 
  set classVars [assoc class_variables internalVars]
  setClassVarDefaultValue parentType $parentType classVars 
  setClassVarDefaultValue args $structureVarList classVars
  setClassVarDefaultValue argTypes $structureVarTypeList classVars
  setClassVarDefaultValue form $structureFormInput classVars
  setClassVarDefaultValue documentation $structureDocInput classVars
  setClassVarDefaultValue terminalTypeParamP $terminalTypeParamP classVars 
  arepl class_variables $classVars internalVars
  # if pirClassIndex is already defined, this will overlay it
  set pirClassStructure($pirClassIndex) $internalVars 
  acons nodeClassType $nodeClassType pirClassStructure($pirClassIndex)
  if {[lsearch -exact $pirClassesStructure $pirClassIndex] == -1} {
    lappend pirClassesStructure $pirClassIndex
  }
  destroy $dialogW

  # write schematic file
  set jmplModified $pirFileInfo(jmpl_modified)
  set pirFileInfo(jmpl_modified) 1

  fileSave $nodeClassType $classDefName

  set pirFileInfo(jmpl_modified) $jmplModified

  # notify user that parameterized terminal type has changed
  # and which components/modules are effected
  set paramType ""
  if {$terminalTypeParamP} {
    set paramType $classDefName
  } elseif {[lsearch -exact $g_NM_paletteStrucIsTerminalTypeParamList \
           $parentType] >= 0} {
    set paramType $parentType
  }
  if {$paramType != ""} {
    set expndParamTypesList $paramType 
    set expndParamTypesList [concat $expndParamTypesList \
                                 [getParameterizedTerminalTypes $paramType]]
    # puts stderr "  expndParamTypesList $expndParamTypesList"
    set componentDependencyString ""; set moduleDependencyString ""
    set componentDependencyList {}; set moduleDependencyList {}
    foreach pType $expndParamTypesList {
      findModuleDependencies $pType $nodeClassType moduleDependencyList \
          moduleDependencyString 
      findComponentDependencies $pType $nodeClassType componentDependencyList \
          componentDependencyString
    }
    # puts stderr "editStructureFormUpdate: moduleDependencyString $moduleDependencyString "
    # puts stderr "editStructureFormUpdate: componentDependencyString $componentDependencyString"
    if {([llength $componentDependencyList] > 0) || \
            ([llength $moduleDependencyList] > 0)} {
      set defmodelsDirectory "[preferred LIVINGSTONE_MODELS_DIR]/" 
      set componentsDir "${defmodelsDirectory}components/" 
      pushd $componentsDir
      foreach file $componentDependencyList {
        file delete $file$g_NM_generatedMPLExtension
      }
      popd
      set modulesDir "${defmodelsDirectory}modules/" 
      pushd $modulesDir
      puts stderr "editStructureFormUpdate: moduleDependencyList $moduleDependencyList "
      foreach file $moduleDependencyList {
        file delete $file$g_NM_generatedMPLExtension
      }
      popd
      set outputStr "'$classDefName' changed ---\n\n"
      append outputStr "The .jmpl files for the following will be regenerated\n"
      set outputStrC "COMPONENTS: \n"; append outputStrC $componentDependencyString 
      set outputStrM "MODULES: \n"; append outputStrM $moduleDependencyString 
      set dialogList [list tk_dialog .d \
                          "Parameterized Terminal Type Changed" \
                          "$outputStr \n$outputStrC \n$outputStrM" \
                          error 0 {DISMISS}]
      eval $dialogList

      # ensure that users work is saved
      save_dialog
      generateIscmOrMplFiles {component module}
    }
  }
}


proc editSymbolForm { nodeClassType classDefName caller } {
  global pirClassSymbol g_NM_schematicMode 
  global g_NM_nodeTypeRootWindow g_NM_readableJavaTokenRegexp
  global g_NM_structureInput g_NM_currentCanvas

  set pirClassIndex $classDefName
  set titleText "Edit Symbol"
  set state normal

  set dialogW $g_NM_nodeTypeRootWindow.${nodeClassType}_${classDefName} 
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0
  if {[classDefReadOnlyP $nodeClassType $classDefName] || \
          ($caller == "fileDelete")} {
    set state disabled
    set titleText "View Symbol"
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised -state $state \
      -command [list editSymbolFormUpdate $dialogW \
                    $nodeClassType $pirClassIndex]
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  if {[regexp "newname" $pirClassIndex]} {
    set nameDefault {}; set symExpansionDefault {}
  } else {
    set nameDefault $pirClassIndex
    set classVars [assoc class_variables pirClassSymbol($pirClassIndex)]
    set symExpansionDefault [getClassVarDefaultValue form classVars]
  }

  set widget $dialogW.fsymbolName
  set description "Name" 
  mkEntryWidget $widget  "" $description $nameDefault $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  
  set widget $dialogW.fexpansion
  set description "Symbol Expansion"
  set entryWidth 40
  mkEntryWidget $widget "" $description $symExpansionDefault $state $entryWidth
  # this can be a floating point number or an java token 
  balloonhelp $widget.label.descrp -side right \
      "javaToken_or_number: \[a->z\], \[A->Z\], \[0->9\], _, +, -, ."

  keepDialogOnScreen $dialogW
  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    ## focus $dialogW # handled in askClassInstance
    tkwait window $dialogW
  }
}


## define pirClassSymbol element for form
## 03jul97 wmt: new
proc editSymbolFormUpdate { dialogW nodeClassType pirClassIndex } {
  global g_NM_classDefType pirClassSymbol pirClassesSymbol
  global g_NM_pirClassASSVTemplate pirFileInfo 

  set dialogId [getDialogId $dialogW]

  set classDefName [$dialogW.fsymbolName.fentry.entry get]
  set classDefName [string trim $classDefName " "]
  if {! [entryValueErrorCheck "Name" "(javaToken)" $classDefName]} {
    return
  }
  if {[string match $classDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "Name not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[regexp "newname" $pirClassIndex] || \
          (! [string match $pirClassIndex $classDefName])} {
    if {[classDefReadOnlyP $nodeClassType $classDefName]} {
      set str "Definition $classDefName is READ-ONLY"
      set dialogList [list tk_dialog .d "ERROR" $str error \
                          0 {DISMISS}]
      eval $dialogList
      return     
    }
    if {[checkForReservedNames $classDefName]} {
      return
    }
    if {[checkForClassNameConflict $classDefName symbol]} {
      return
    }
  }

  set expansion [$dialogW.fexpansion.fentry.entry get]
  # this can be a floating point number or a MPL form -- no validity 
  # checking is done
  if {[string match $expansion ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "Symbol Expansion not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {! [entryValueErrorCheck "Symbol Expansion" "(javaToken_or_number)" \
             $expansion]} {
    return
  }

  set pirClassIndex $classDefName
  set internalVars $g_NM_pirClassASSVTemplate 
  set classVars [assoc class_variables internalVars]
  setClassVarDefaultValue form $expansion classVars  
  arepl class_variables $classVars internalVars
  # if pirClassIndex is already defined, this will overlay it
  set pirClassSymbol($pirClassIndex) $internalVars 
  acons nodeClassType $nodeClassType pirClassSymbol($pirClassIndex)
  if {[lsearch -exact $pirClassesSymbol $pirClassIndex] == -1} {
    lappend pirClassesSymbol $pirClassIndex
  }
  destroy $dialogW

  # write schematic file
  set jmplModified $pirFileInfo(jmpl_modified)
  set pirFileInfo(jmpl_modified) 1

  fileSave $nodeClassType $classDefName

  set pirFileInfo(jmpl_modified) $jmplModified 
}



proc editValueForm { nodeClassType classDefName caller } {
  global pirClassValue g_NM_schematicMode 
  global g_NM_nodeTypeRootWindow g_NM_readableJavaTokenRegexp
  global g_NM_valueDocInput g_NM_currentCanvas
  global g_NM_readable1nJavaTokenRegexp 

  set pirClassIndex $classDefName
  set titleText "Edit Value"
  set state normal

  set dialogW $g_NM_nodeTypeRootWindow.${nodeClassType}_${classDefName} 
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  set initP 0
  if {[classDefReadOnlyP $nodeClassType $classDefName] || \
          ($caller == "fileDelete")} {
    set state disabled
    set titleText "View Value"
  }
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor 
  button $dialogW.buttons.ok -text OK -relief raised -state $state \
      -command [list editValueFormUpdate $dialogW \
                    $nodeClassType $pirClassIndex]
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text CANCEL -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.buttons.cancel configure -takefocus 0
  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom

  if {[regexp "newname" $pirClassIndex]} {
    set nameDefault {}; set valueListDefault {}
    set g_NM_valueDocInput {}
  } else {
    set nameDefault $pirClassIndex
    set classVars [assoc class_variables pirClassValue($pirClassIndex)]
    set valueListDefault [getClassVarDefaultValue valueList classVars]
    set g_NM_valueDocInput [getClassVarDefaultValue documentation classVars]
  }

  set widget $dialogW.fvalueName
  set description "Name" 
  mkEntryWidget $widget  "" $description $nameDefault $state
  balloonhelp $widget.label.descrp -side right $g_NM_readableJavaTokenRegexp
  balloonhelp $widget.pad.left -side right "<tab> to next field;  <shift-tab> to prev"
  
  set widget $dialogW.fvalueList
  set description "Value List"
  set entryWidth 60
  mkEntryWidget $widget "" $description $valueListDefault \
      $state $entryWidth 
  balloonhelp $widget.label.descrp -side right \
      $g_NM_readable1nJavaTokenRegexp

  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w 
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.doctitle -side top -fill both
  set attributeName documentation 
  global g_NM_valueDocInput_$dialogId 
  set g_NM_valueDocInput_$dialogId $g_NM_valueDocInput
  createTextWidget $dialogId $dialogW $nodeClassType $attributeName $state 

  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x

  keepDialogOnScreen $dialogW
  if [winfo exists $dialogW] {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    ## focus $dialogW # handled in askClassInstance
    tkwait window $dialogW
  }
}


## define pirClassValue element for form
## 03jul97 wmt: new
proc editValueFormUpdate { dialogW nodeClassType pirClassIndex } {
  global g_NM_structureInput g_NM_classDefType
  global pirClassValue g_NM_RSVInput pirFileInfo 
  global g_NM_pirClassASSVTemplate pirClassesValue

  set dialogId [getDialogId $dialogW]

  set classDefName [$dialogW.fvalueName.fentry.entry get]
  set classDefName [string trim $classDefName " "]
  if {! [entryValueErrorCheck "Name" "(javaToken)" $classDefName]} {
    return
  }
  if {[string match $classDefName ""]} {
    set dialogList [list tk_dialog .d \
                        "ERROR" "Name not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  if {[regexp "newname" $pirClassIndex] || \
          (! [string match $pirClassIndex $classDefName])} {
    if {[classDefReadOnlyP $nodeClassType $classDefName]} {
      set str "Definition $classDefName is READ-ONLY"
      set dialogList [list tk_dialog .d "ERROR" $str error \
                          0 {DISMISS}]
      eval $dialogList
      return     
    }
    if {[checkForReservedNames $classDefName]} {
      return
    }
    if {[checkForClassNameConflict $classDefName value]} {
      return
    }
  }

  set valueList [$dialogW.fvalueList.fentry.entry get]
  set fieldName "Value List"
  if {! [entryValueErrorCheck $fieldName "(1-n_javaTokens)" $valueList]} {
    return
  }

  # saveTextWidget puts documentation into global vars
  saveTextWidget $dialogId $dialogW.text value documentation (all_characters)
  set valueDocInput [getTextWidgetText $dialogId value documentation 0]

  set pirClassIndex $classDefName
  set internalVars $g_NM_pirClassASSVTemplate 
  set classVars [assoc class_variables internalVars]
  setClassVarDefaultValue valueList $valueList classVars  
  setClassVarDefaultValue documentation $valueDocInput classVars  
  arepl class_variables $classVars internalVars
  # if pirClassIndex is already defined, this will overlay it
  set pirClassValue($pirClassIndex) $internalVars 
  acons nodeClassType $nodeClassType pirClassValue($pirClassIndex)
  if {[lsearch -exact $pirClassesValue $pirClassIndex] == -1} {
    lappend pirClassesValue $pirClassIndex
  }
  destroy $dialogW

  # write schematic file
  set jmplModified $pirFileInfo(jmpl_modified)
  set pirFileInfo(jmpl_modified) 1

  fileSave $nodeClassType $classDefName

  set pirFileInfo(jmpl_modified) $jmplModified 
}


## construct MPL structure/defsymbol-expansion/defvalues form
## from pirClass structure
## 14nov97 wmt: new
proc getRSVMplFormFromScm { filePath } {
  global g_NM_paletteAbstractionList g_NM_paletteStructureList
  global pirClassAbstraction pirClassesAbstraction 
  global pirClassStructure pirClassesStructure
  global pirClassRelation pirClassesRelation 
  global g_NM_paletteDefrelationList 
  
  set reportNotFoundP 0; set silentP 1
  set startP 0; set scmForm ""
  set fid [open $filePath r]
  while {[gets $fid line] >= 0} {
    if {$startP} {
      if {[string first "global" $line] == 0} {
        break
      } else {
        append scmForm "$line\n"
      }
    }
    if {[string first "set pirClass\(" $line] != -1} {
      append scmForm "$line\n"
      set startP 1
    }
  }
  close $fid
  set index [string first "\{" $scmForm] 
  # puts stderr "getRSVLispFormFromScm: index $index scmForm `$scmForm'" 
  set scmForm [lindex [string range $scmForm $index end] 0]
  # puts stderr "getRSVLispFormFromScm: scmForm `$scmForm'"
  set nodeClassType [assoc nodeClassType scmForm]
  set classVars [assoc class_variables scmForm]
  set name [file rootname [file tail $filePath]]
  # abstractions are folded into structures
  # so there is no separate processing for them
  # relations are folded into values, and appropriate ones
  # into structures
  switch $nodeClassType {
    structure {
      set form [getClassVarDefaultValue form classVars]
      regsub -all "this\\\." $form "" tmp; set form $tmp
      set parentType [getClassVarDefaultValue parentType classVars]
      set args [getClassVarDefaultValue args classVars]
      set numArgs [llength $args]
      set argTypes [getClassVarDefaultValue argTypes classVars]
      set doc [getClassVarDefaultValue documentation classVars]
      set mplForm ""
      append mplForm [convertDocToJmplComments doc] 
      append mplForm "class $name"
      if {$parentType != "<unspecified>"} {
        append mplForm " extends $parentType"
      }
      append mplForm " \{\n"
#       if {$parentType == "<unspecified>"} {
#         for {set i 0} {$i < $numArgs} {incr i} {
#           append mplForm "[lindex $argTypes $i] [lindex $args $i];\n"
#         }
#       }
      # ouput args for extended classes
      for {set i 0} {$i < $numArgs} {incr i} {
        append mplForm "[lindex $argTypes $i] [lindex $args $i];\n"
      }
      if {$form != ""} {
        append mplForm "\n// restrictive constaints on arg types\n"
        append mplForm "relation ${name}_init \(\) \{\n"
        append mplForm $form
        append mplForm "\n\}\n"
        append mplForm "\{\n"
        append mplForm "  ${name}_init();\n"
        append mplForm "\}\n"
      }
      # abstraction methods whose from var type is a structure 
      getAbstractionFormsForStructureOrValueType $name mplForm

      # relation methods whose from var type is a structure
      getRelationFormsForStructureOrValueType $name mplForm

      append mplForm "\}\n"
    }
    symbol {
      ## 07mar00: jmpl does not allow setting of global variables
      ## and this generation, even tho it passes JmplLint does not
      ## do anyting -- users can use numerical values, rather than
      ## rare, etc in transition expression or
      ## rare likely unlikley lessLikely can be jmpl primitives
      set form [getClassVarDefaultValue form classVars]
      set mplForm "$name = \"$form\""
    }
    value {
      # enum moodType {happy,sad,sleepy};
      set valueList [getClassVarDefaultValue valueList classVars]
      set newValueString ""; set firstP 1
      foreach value $valueList {
        if {$firstP} {
          set firstP 0
        } else {
          append newValueString ", "
        }
        append newValueString $value
      }
      set doc [getClassVarDefaultValue documentation classVars]
      set mplForm ""
      append mplForm [convertDocToJmplComments doc] 
      append mplForm "enum $name \n"
      append mplForm "\{$newValueString\} \{ \n"

      # abstraction methods whose from var type is a value
      getAbstractionFormsForStructureOrValueType $name mplForm

      # relations amethods whose from var type is a value
      getRelationFormsForStructureOrValueType $name mplForm

      append mplForm "\};\n"
    }
    default {
      puts stderr "getRSVLispFormFromScm: nodeClassType $nodeClassType not handled\!"
    }
  }
  return $mplForm
}


## get relation forms for structure or value types
## relations are methods whose from var type is a structure or value
## 17mar00 wmt: new
proc getRelationFormsForStructureOrValueType { name mplFormRef } {
  upvar $mplFormRef mplForm
  global g_NM_paletteDefrelationList pirClassesRelation pirClassRelation 

  set silentP 1
  foreach relationName $g_NM_paletteDefrelationList {
    set pirClassIndex $relationName 
    if {[lsearch -exact $pirClassesRelation $pirClassIndex] == -1} {
      read_workspace relation $relationName $silentP
    }
    set classVars [assoc class_variables pirClassRelation($pirClassIndex)]
    set argsList [getClassVarDefaultValue args classVars]
    set numArgs [llength $argsList]
    set argTypesList [getClassVarDefaultValue argTypes classVars]
    set doc [getClassVarDefaultValue documentation classVars]
    set fromType [lindex $argTypesList 0]
    set form [getClassVarDefaultValue form classVars] 
    regsub -all "this\\\." $form "" tmp; set form $tmp
    if {[string match $fromType $name]} {
      append mplForm "// relation method\n"
      append mplForm [convertDocToJmplComments doc] 
      append mplForm "relation $relationName \( "
      set firstP 1
      for {set i 1} {$i < $numArgs} {incr i} {
        if {$firstP} {
          set firstP 0
        } else {
          append mplForm ", "
        }
        append mplForm "[lindex $argTypesList $i] "
        append mplForm "[lindex $argsList $i]"
      }
      append mplForm "\) \{\n"
      append mplForm "$form\n"
      append mplForm "\}\n"
    }
  }
}


## get abstraction forms for structure or value types
## abstractions are methods whose from var type is a structure or value
## 11oct00 wmt: new 
proc getAbstractionFormsForStructureOrValueType { name mplFormRef } {
  upvar $mplFormRef mplForm
  global g_NM_paletteAbstractionList pirClassesAbstraction
  global pirClassAbstraction 

  set silentP 1
  foreach abstractionName $g_NM_paletteAbstractionList {
    set pirClassIndex $abstractionName 
    if {[lsearch -exact $pirClassesAbstraction $pirClassIndex] == -1} {
      read_workspace abstraction $abstractionName $silentP
    }
    set classVars [assoc class_variables pirClassAbstraction($pirClassIndex)]
    set argsList [getClassVarDefaultValue args classVars]
    set toArg [lindex $argsList 1]
    set argTypesList [getClassVarDefaultValue argTypes classVars]
    set doc [getClassVarDefaultValue documentation classVars]
    set fromType [lindex $argTypesList 0]
    set toType [lindex $argTypesList 1]
    set form [getClassVarDefaultValue form classVars]
    # remove structure parent class prefix
    set indx [string first "." $abstractionName]
    set abstractionName [string range $abstractionName [expr {$indx + 1}] end]
    regsub -all "this\\\." $form "" tmp; set form $tmp
    if {[string match $fromType $name]} {
      append mplForm "// abstraction method\n"
      append mplForm [convertDocToJmplComments doc] 
      append mplForm "relation $abstractionName "
      append mplForm "\( $toType $toArg \) \{\n"
      append mplForm "$form\n"
      append mplForm "\}\n"
    }
  }
}










