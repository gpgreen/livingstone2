# $Id: terminals.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## terminals.tcl

## code which handles component and module input/output/port terminals

## instantiate input/output terminals
## 16feb96 wmt: new
## 21mar96 wmt: use process-terminals, which subsumes convert-lisp-terminals-to-tcl
## 06may96 wmt: trim prefix and suffix blanks from type
## 13may96 wmt: process inputs, outputs & ports separately
## 30may96 wmt: remove STANLEY_MISSION from pathnames
## 16oct96 wmt: handle input/output/port<-declaration> terminals
## 01may97 wmt: terminal forms do not need type values, so call to Livingstone 
##              is not necessary
## 07may97 wmt: only upper case substitution needed now
proc getTerminalInputsOutputs { inTerminalFormsRef outTerminalFormsRef \
                                    portTerminalFormsRef terminalInputsRef \
                                    terminalOutputsRef classType className \
                                    numTerminalInputsRef numTerminalOutputsRef } {
  upvar $inTerminalFormsRef inTerminalForms
  upvar $outTerminalFormsRef outTerminalForms
  upvar $portTerminalFormsRef portTerminalForms
  upvar $terminalInputsRef terminalInputs
  upvar $terminalOutputsRef terminalOutputs
  upvar $numTerminalInputsRef numTerminalInputs
  upvar $numTerminalOutputsRef numTerminalOutputs
  global g_NM_currentNodeGroup

  if {[string match $inTerminalForms ""] && \
          [string match $outTerminalForms ""] && \
          [string match $portTerminalForms ""]} {
    return
  }
  # puts stderr "getTerminalInputsOutputs: inTerminalForms $inTerminalForms"
  # puts stderr "getTerminalInputsOutputs: outTerminalForms $outTerminalForms"
  # puts stderr "getTerminalInputsOutputs: portTerminalForms $portTerminalForms"

  foreach form $inTerminalForms {
    formatTerminalForm "in" form terminalForm
    incr numTerminalInputs
    lappend terminalInputs $terminalForm
  }
  foreach form $outTerminalForms {
    formatTerminalForm "out" form terminalForm
    incr numTerminalOutputs
    lappend terminalOutputs $terminalForm
  }
  foreach form $portTerminalForms {
    # puts stderr "getTerminalInputsOutputs - port: form $form"
    formatTerminalForm "port" form terminalForm
    # puts stderr "getTerminalInputsOutputs - port: terminalForm $terminalForm"
    incr numTerminalOutputs
    lappend terminalOutputs $terminalForm
  }
}


## format the terminal form
## all terminals are by default: interfaceType public
## 01may97 wmt: new
## 16apr98 wmt: added terminalLabel 
proc formatTerminalForm { mode formRef terminalFormRef } {
  upvar $formRef form
  upvar $terminalFormRef terminalForm

  # puts stderr "formatTerminalForm: form $form"
  set terminalType [lindex $form 0]
  set typeList [list $terminalType $mode]
  set terminalName [lindex $form 1]
  set terminalLabel [lindex $form 2]
  set commandMonitorType [lindex $form 3]
  set interfaceType [lindex $form 4]
  set terminalForm [list type $typeList \
                        terminal_name $terminalName \
                        terminal_label $terminalLabel \
                        commandMonitorType $commandMonitorType \
                        interfaceType $interfaceType]
  # puts stderr "formatTerminalForm: terminalForm $terminalForm"
}


## ask user for defmodule terminal parameters; and
## allow editing of existing terminals/attributes
## 27sep96 wmt: new 
## 16oct96 wmt: add sticky input values
## 02may97 wmt: add tk_optionMenu to select terminal type
##              pirNodeIndex means instance already exists
proc askTerminalInstance { classType className pirNodeIndex caller \
                               {xPos -1} {yPos -1} } {
  global g_NM_rootInstanceName g_NM_stickyTerminalNameInput
  global g_NM_terminalDocInput g_NM_terminalTypeList
  global pirNode g_NM_attributeFactsInput g_NM_currentNodeGroup
  global g_NM_currentCanvas g_NM_nodeTypeRootWindow pirNode
  global g_NM_terminalTypeValuesArray g_NM_displayStateType 
  global g_NM_schematicMode g_NM_commandMonitorTypesList 
  global g_NM_terminalInterfaceTypesList g_NM_readableJavaFormRegexp
  global g_NM_readableJavaTokenRegexp g_NM_oldTerminalType

  # puts stderr "askTerminalInstance: caller $caller"
  set state normal; set typeState normal; set operation Instantiate
  set defValState disabled
  set reportNotFoundP 0; set cmdMonTypeP 1
  if {[string match $caller "mkNode"]} {
    set operation Edit
  }
  if {[string match $className "displayState"]} {
    set operation Edit; set typeState disabled
  }
  if {[componentModuleDefReadOnlyP] || \
          [string match $g_NM_schematicMode "operational"] || \
          (! [string match $g_NM_rootInstanceName \
                  [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
          [string match $caller "metaDot"]} {
    set state disabled; set typeState disabled; set operation View
    enableViewDialogDeletion
  }
  set initP 0
  set dialogW $g_NM_nodeTypeRootWindow.askTerminalInstance$pirNodeIndex
  set dialogId [getDialogId $dialogW]
  if {[winfo exists $dialogW]} {
    raise $dialogW
    return
  }
  # add parameter variables to g_NM_terminalTypeList, if their types
  # contain items from g_NM_terminalTypeList
  set terminalTypeList [getTerminalTypeListWithParams]

  toplevel $dialogW -class Dialog
  set nodeInstanceNameInternal $g_NM_rootInstanceName
  if {$pirNodeIndex > 0} {
    set nodeInstanceNameInternal [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set nodeInstanceNameExternal [getExternalNodeName $nodeInstanceNameInternal]
  }
  if {[string match $className attribute]} {
    set cmdMonTypeP 0
    set title $className 
  } elseif {[string match $className displayState]} {
    set title "DISPLAY ATTRIBUTE"
  } else {
    set title "$className [capitalizeWord $classType]"
  }
  if {[regexp "Declaration" $className]} {
     set cmdMonTypeP 0
  }
  regsub -all "PORT" $title "BI-DIRECTIONAL" newTitle

  wm title $dialogW "$operation $newTitle"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  $dialogW config -bg $bgcolor
  set command "terminalInstanceUpdate $dialogW"
  append command " $className $classType $pirNodeIndex $caller"
  append command " documentation (all_characters) $nodeInstanceNameInternal"
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

  set g_NM_terminalDocInput ""
  set g_NM_attributeFactsInput ""
  if {$pirNodeIndex > 0} {
    # use current values for defaults, rather than last entered in dialog
    # terminals have opposite directional sense
    if {[string match $className "output"]} {
      set termType inputs; set termAtt in1
    } else {
      set termType outputs; set termAtt out1
    }
    set terminalList [assoc $termType pirNode($pirNodeIndex)]
    set terminalDef [assoc $termAtt terminalList]
    if {[string match $className "displayState"]} {
      set instanceNameInternal [assoc nodeInstanceName pirNode($pirNodeIndex)]
    } else {
      set instanceNameInternal [assoc terminal_name terminalDef]
    }
    set nameDefault [getExternalNodeName $instanceNameInternal]
    set instanceLabelDefaultInternal [assoc instanceLabel pirNode($pirNodeIndex)]
    set labelDefault $instanceLabelDefaultInternal 
    set typeDefault [getTerminalType $terminalDef]
    set docDefault "\{[assoc nodeDescription pirNode($pirNodeIndex)]\}"
    set g_NM_terminalDocInput [string trim $docDefault "\{\}"]
    if {[string match $classType "attribute"]} {
      set factsDefault [assoc facts pirNode($pirNodeIndex)]
      set g_NM_attributeFactsInput [string trim $factsDefault "\{\}"]
    }
    if {[string match $classType "terminal"]} {
      set commandMonitorDefaultList [assoc commandMonitorType terminalDef]
      set commandMonitorTypeDefault [lindex $commandMonitorDefaultList 0]
      if {[string match $commandMonitorTypeDefault "none"]} {
        # previously none was the default -- force it to be unspecified
        set commandMonitorTypeDefault "<unspecified>"
      }
      global g_NM_optMenuCmdMonValue_$dialogId
      set g_NM_optMenuCmdMonValue_$dialogId $commandMonitorTypeDefault 

      set commandMonitorTypeValueDefault [lindex $commandMonitorDefaultList 1]
      if {[string match $commandMonitorTypeValueDefault ""]} {
        set commandMonitorTypeValueDefault "<unspecified>"
      }
      if {[llength $commandMonitorTypeValueDefault] > 1} {
        # saved as multi-dimensional (structure), but uni-dimensional in dialog
        set commandMonitorTypeValueDefault [lindex $commandMonitorTypeValueDefault 0]
      }
      global g_NM_commandMonitorTypeValuesList_$dialogId
      if {[regexp "\\\?" $typeDefault]} {
        # type name is a parameter -- type not determined until instantiation
        set cmdMonValuesList ""
      } else {
        set cmdMonValuesList [assoc-array $typeDefault g_NM_terminalTypeValuesArray]
      }
      if {[string match $commandMonitorTypeDefault "monitored"] && \
              ([lsearch -exact $cmdMonValuesList "unknown"] == -1)} {
        lappend cmdMonValuesList "unknown"
      }
      set g_NM_commandMonitorTypeValuesList_$dialogId $cmdMonValuesList

      set interfaceTypeDefault [assoc interfaceType terminalDef]
      global g_NM_optMenuInterfaceType_$dialogId
      set g_NM_optMenuInterfaceType_$dialogId $interfaceTypeDefault 
    }
  } else {
    if {[string match $className "displayState"]} {
      set nameDefault ""
      set labelDefault {}
      set typeDefault $g_NM_displayStateType 
    } else {
      set nameDefault $g_NM_stickyTerminalNameInput
      set labelDefault {}
      set typeDefault "<unspecified>"
    }
    if {[string match $classType "terminal"]} {
      set commandMonitorTypeDefault "<unspecified>" 
      set commandMonitorTypeValueDefault "<unspecified>"
      global g_NM_commandMonitorTypeValuesList_$dialogId 
      set g_NM_commandMonitorTypeValuesList_$dialogId {<unspecified>}
      set interfaceTypeDefault public
      global g_NM_optMenuInterfaceType_$dialogId 
      set g_NM_optMenuInterfaceType_$dialogId public
    }
  }
  set g_NM_oldTerminalType $typeDefault 

  # puts stderr "askTerminalInstanc; dialogId $dialogId"
  frame  $dialogW.nameLabel -background $bgcolor
  set widget $dialogW.nameLabel.fName
  mkEntryWidget $widget "" "Name " $nameDefault $state
  balloonhelp $widget.fentry.entry -side right $g_NM_readableJavaTokenRegexp

  set widget $dialogW.nameLabel.fLabel
  mkEntryWidget $widget "" " Label " $labelDefault $state
  pack $dialogW.nameLabel.fName $dialogW.nameLabel.fLabel -side left -fill x \
      -ipadx 20
  pack $dialogW.nameLabel -fill x 

  frame $dialogW.typeCommandMon
  frame $dialogW.typeCommandMon.fType -background $bgcolor
  frame $dialogW.typeCommandMon.fType.typetitle -background $bgcolor 
  label $dialogW.typeCommandMon.fType.typetitle.title -text "Type" \
      -relief flat -anchor w
  label $dialogW.typeCommandMon.fType.typetitle.filler -text "" -relief flat
  $dialogW.typeCommandMon.fType.typetitle configure -takefocus 0
  $dialogW.typeCommandMon.fType.typetitle.title configure -takefocus 0
  $dialogW.typeCommandMon.fType.typetitle.filler configure -takefocus 0

  tk_alphaOptionMenuCascade $dialogW.typeCommandMon.fType.optMenuButton \
      g_NM_optMenuTypeValue_$dialogId \
      $typeDefault terminalTypeList $typeState $cmdMonTypeP $dialogW 
  if {[regexp "\\\?" $typeDefault]} {
    # type name is a parameter -- type not determined until instantiation
    set valuesList [assoc-array [getParameterType $typeDefault] \
                        g_NM_terminalTypeValuesArray] 
  } else {
    set valuesList [assoc-array $typeDefault g_NM_terminalTypeValuesArray]
  }

  balloonhelp $dialogW.typeCommandMon.fType.optMenuButton -side right \
      "values: [multiLineList $typeDefault $valuesList values:]"
  pack $dialogW.typeCommandMon.fType.optMenuButton -side bottom -fill x
  pack $dialogW.typeCommandMon.fType.typetitle.title -side left
  pack $dialogW.typeCommandMon.fType.typetitle.filler -side left -fill x -expand 1
  pack $dialogW.typeCommandMon.fType.typetitle -side top -fill x

  if {[string match $classType "terminal"]} {
    frame $dialogW.typeCommandMon.fCmdmon -background $bgcolor
    frame $dialogW.typeCommandMon.fCmdmon.cmdmontitle -background $bgcolor 
    label $dialogW.typeCommandMon.fCmdmon.cmdmontitle.title -text \
        "Commanded or Monitored" -relief flat -anchor w
    label $dialogW.typeCommandMon.fCmdmon.cmdmontitle.filler -text "" -relief flat
    $dialogW.typeCommandMon.fCmdmon.cmdmontitle configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmon.cmdmontitle.title configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmon.cmdmontitle.filler configure -takefocus 0

    tk_alphaOptionMenuCascade $dialogW.typeCommandMon.fCmdmon.optMenuButton \
        g_NM_optMenuCmdMonValue_$dialogId \
        $commandMonitorTypeDefault g_NM_commandMonitorTypesList $typeState \
        $cmdMonTypeP $dialogW
    if {$pirNodeIndex == 0} {
      # option menu state must be normal to be built, then disabled it until
      # user selects terminal type
      $dialogW.typeCommandMon.fCmdmon.optMenuButton configure -state disabled
    }
    pack $dialogW.typeCommandMon.fCmdmon.optMenuButton -side bottom -fill x
    pack $dialogW.typeCommandMon.fCmdmon.cmdmontitle.title -side left
    pack $dialogW.typeCommandMon.fCmdmon.cmdmontitle.filler -side left -fill x -expand 1
    pack $dialogW.typeCommandMon.fCmdmon.cmdmontitle -side top -fill x
    # -------------------
    frame $dialogW.typeCommandMon.fCmdmonDefVal -background $bgcolor
    frame $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle -background $bgcolor 
    label $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.title -text \
        "Cmd/Mon Default Value" -relief flat -anchor w
    label $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.filler -text "" -relief flat
    $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.title configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.filler configure -takefocus 0

    tk_alphaOptionMenuCascade $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton \
        g_NM_optMenuCmdMonDefValue_$dialogId \
        $commandMonitorTypeValueDefault g_NM_commandMonitorTypeValuesList_$dialogId \
        $defValState
    if {$pirNodeIndex == 0} {
      # option menu state must be normal to be built, then disabled it until
      # user selects terminal type
      $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton configure -state disabled
    }
    pack $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton -side bottom -fill x
    pack $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.title -side left
    pack $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle.filler \
        -side left -fill x -expand 1
    pack $dialogW.typeCommandMon.fCmdmonDefVal.cmdmontitle -side top -fill x
    # -------------------
    frame $dialogW.typeCommandMon.fCmdmonIntTyp -background $bgcolor
    frame $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle -background $bgcolor 
    label $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.title -text \
        "Interface Type" -relief flat -anchor w
    label $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.filler -text "" -relief flat
    $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.title configure -takefocus 0
    $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.filler configure -takefocus 0

    tk_alphaOptionMenuCascade $dialogW.typeCommandMon.fCmdmonIntTyp.optMenuButton \
        g_NM_optMenuInterfaceType_$dialogId \
        $interfaceTypeDefault g_NM_terminalInterfaceTypesList $typeState
    if {$pirNodeIndex == 0} {
      # option menu state must be normal to be built, then disabled it until
      # user selects terminal type
      $dialogW.typeCommandMon.fCmdmonIntTyp.optMenuButton configure -state disabled
    }
    pack $dialogW.typeCommandMon.fCmdmonIntTyp.optMenuButton -side bottom -fill x
    pack $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.title -side left
    pack $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle.filler \
        -side left -fill x -expand 1
    pack $dialogW.typeCommandMon.fCmdmonIntTyp.cmdmontitle -side top -fill x

    pack $dialogW.typeCommandMon.fType $dialogW.typeCommandMon.fCmdmon \
        $dialogW.typeCommandMon.fCmdmonDefVal \
        $dialogW.typeCommandMon.fCmdmonIntTyp -side left -fill x -padx 5 \
        -anchor w
  } else {
    pack $dialogW.typeCommandMon.fType -side left -fill x
  }
  pack $dialogW.typeCommandMon -fill x

  # make propositions available
  bind $dialogW.typeCommandMon.fType.optMenuButton <Button-3> \
      "generateTerminalProposition $dialogW $typeDefault [list $valuesList]"
  set msg "<Mouse-R drag>: select proposition"
  bind $dialogW.typeCommandMon.fType.optMenuButton <Enter> "pirWarning \"$msg\""
  bind $dialogW.typeCommandMon.fType.optMenuButton <Leave> "standardMouseClickMsg"

  if {[string match $className "attribute"] || \
          [string match $className "displayState"]} {
    frame $dialogW.facts
    label $dialogW.facts.spacer -text "" -relief flat -anchor w 
    $dialogW.facts.spacer configure -takefocus 0
    pack $dialogW.facts.spacer -side top -fill both
    frame $dialogW.facts.ftitle -background $bgcolor
    label $dialogW.facts.ftitle.title -text "Facts" -relief flat -anchor w 
    $dialogW.facts.ftitle.title configure -takefocus 0
    pack $dialogW.facts.ftitle.title -side left
    pack $dialogW.facts.ftitle -side top -fill both
    pack $dialogW.facts -side top
    set attributeName facts; set pirEdgeIndex 0
    global g_NM_attributeFactsInput_$dialogId 
    set g_NM_attributeFactsInput_$dialogId $g_NM_attributeFactsInput
    createEmacsTextWidget $dialogId $dialogW factsEmacs $classType $attributeName \
        $state $pirEdgeIndex 
    balloonhelp $dialogW.factsEmacs.t -side top $g_NM_readableJavaFormRegexp
  } 

  label $dialogW.docspacer -text "" -relief flat
  $dialogW.docspacer configure -takefocus 0
  label $dialogW.doctitle -text "Documentation" -relief flat -anchor w
  $dialogW.doctitle configure -takefocus 0
  pack $dialogW.docspacer $dialogW.doctitle -side top -fill both

  global g_NM_terminalDocInput_$dialogId 
  set g_NM_terminalDocInput_$dialogId $g_NM_terminalDocInput
  set attributeName documentation 
  createTextWidget $dialogId $dialogW $classType $attributeName $state 
  
  frame $dialogW.doc
  label $dialogW.doc.spacer -text "" -relief flat -anchor w 
  $dialogW.doc.spacer configure -takefocus 0
  pack $dialogW.doc.spacer -side top -fill both
  pack $dialogW.doc -side top -fill x

  focus $dialogW.nameLabel.fName.fentry.entry
  keepDialogOnScreen $dialogW $xPos $yPos

  if {[winfo exists $dialogW] && (! [string match $operation "View"])} {
    ## allow tk_focusFollowsMouse to work
    ##grab set $dialogW
    tkwait window $dialogW 
  }
}


## on-the-fly generate the terminal/attribute's propositions
## 09jul98: new
proc generateTerminalProposition { dialogW type valuesList } {

  set terminalName [$dialogW.nameLabel.fName.fentry.entry get]
  selectTerminalProposition $terminalName $type $valuesList $dialogW
}


## process  defmodule terminal node entry for
## input/output/port/input-declaration/output-declaration &
## port-declaration
## 27sep96 wmt: new
## 16oct96 wmt: add sticky input values
## 02may97 wmt: add g_NM_optMenuWidgetValue
proc terminalInstanceUpdate { dialogW className classType pirNodeIndex \
                                  caller attributeName attributeType \
                                oldTerminalNameInternal } {
  global g_NM_mkformNodeCompleteP g_NM_rootInstanceName
  global g_NM_terminalInstance g_NM_livingstoneDefmoduleName
  global g_NM_stickyTerminalNameInput g_NM_currentNodeGroup
  global g_NM_terminalDocInput pirNode g_NM_currentCanvas
  global g_NM_canvasRedrawP g_NM_livingstoneDefmoduleNameVar
  global g_NM_livingstoneDefmoduleArgList g_NM_attributeFactsInput
  global g_NM_classDefType g_NM_schematicMode pirPreferences
  global g_NM_terminalTypeValuesArray pirEdge g_NM_oldTerminalType
  global g_NM_displayStateType g_NM_classToInstances 

  set reportNotFoundP 0
  set dialogId [getDialogId $dialogW]
  # puts stderr "terminalInstanceUpdate: caller $caller"
  set terminalNameInternal {}; set terminalType ""; set varInName ""
  set terminalLabelInternal {}; set terminalLabelExternal {}
  set terminalNameExternal [$dialogW.nameLabel.fName.fentry.entry get]
  set terminalNameExternal [string trim $terminalNameExternal " "]
  # puts stderr "terminalInstanceUpdate terminalNameExternal $terminalNameExternal"
  if {! [entryValueErrorCheck Name "(javaToken)" $terminalNameExternal]} {
    return
  }
  if {[string match $terminalNameExternal ""]} {
    set dialogList [list tk_dialog .d "ERROR" "Name not entered" error \
                        0 {DISMISS}]
    eval $dialogList
    return
  }
  set g_NM_stickyTerminalNameInput $terminalNameExternal
  set terminalNameInternal [getInternalNodeName $terminalNameExternal]
  if {($oldTerminalNameInternal == $g_NM_rootInstanceName) || \
          ($oldTerminalNameInternal != $terminalNameInternal)} {
    if {[checkForReservedNames $terminalNameExternal]} {
      return
    }
    if {[checkForClassNameConflict $terminalNameExternal $classType]} {
      return
    }
    # check that for this class, terminalName is not already in use
    set outputMsgP 0
    if {[checkClassInstance $classType $terminalNameInternal $outputMsgP]} {
      return
    }
    
  }

  set terminalLabelExternal [$dialogW.nameLabel.fLabel.fentry.entry get]
  # puts stderr "terminalInstanceUpdate terminalLabelExternal $terminalLabelExternal"
  # no syntax checking -- allow anything

  global g_NM_optMenuTypeValue_$dialogId
  set terminalType [subst $[subst g_NM_optMenuTypeValue_$dialogId]]
  # puts stderr "terminalInstanceUpdate terminalType $terminalType"
  if {[string match $terminalType "<unspecified>"]} {
    set dialogList [list tk_dialog .d "ERROR" "$classType `Type' not entered" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }

  if {[string match $classType "terminal"]} {
    global g_NM_optMenuCmdMonValue_$dialogId
    set commandMonitorType [subst $[subst g_NM_optMenuCmdMonValue_$dialogId]]
    if {[string match $commandMonitorType "<unspecified>"]} {
      set dialogList [list tk_dialog .d "ERROR" "`Commanded or Monitored' not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    global g_NM_optMenuCmdMonDefValue_$dialogId 
    set commandMonitorTypeValue [subst $[subst g_NM_optMenuCmdMonDefValue_$dialogId]]
    if {[string match $commandMonitorTypeValue "<unspecified>"]} {
      set dialogList [list tk_dialog .d "ERROR" "`Cmd/Mon Default Value' not entered" \
                          error 0 {DISMISS}]
      eval $dialogList
      return
    }
    # puts stderr "terminalInstanceUpdate commandMonitorType $commandMonitorType"
    # puts stderr "terminalInstanceUpdate commandMonitorTypeValue $commandMonitorTypeValue"
    global g_NM_optMenuInterfaceType_$dialogId
    set interfaceType [subst $[subst g_NM_optMenuInterfaceType_$dialogId]]
  }

  # remove old type from dependency list
  if {(! [string match $g_NM_oldTerminalType $g_NM_displayStateType]) && \
          ($g_NM_oldTerminalType != "<unspecified>") && \
          (! [regexp "\\\?" $g_NM_oldTerminalType])} {
    # ? -- type name is a parameter -- type not determined until instantiation
    set dependentClassTypeList [list [getDependentTerminalTypeClass "" "" $g_NM_oldTerminalType]]
    set dependentClassNameList [list $g_NM_oldTerminalType]
    # delete entry and check for other references before deleting
    set currentEntries [assoc-array $g_NM_oldTerminalType g_NM_classToInstances \
                            $reportNotFoundP]
    adel $oldTerminalNameInternal currentEntries
    set g_NM_classToInstances($g_NM_oldTerminalType) $currentEntries 
    # puts stderr "terminalInstanceUpdate: oldTerminalNameInternal $oldTerminalNameInternal g_NM_oldTerminalType $g_NM_oldTerminalType currentEntries $currentEntries"
    if {[llength $currentEntries] == 0} {
      updateDependentClasses $dependentClassTypeList $dependentClassNameList "delete"
    }
  }

  set oldTerminalNameExternal [getExternalNodeName $oldTerminalNameInternal]
  # instantiation variables are controlled by Stanley
  set varInOldName ?name
  # saveTextWidget puts documentation into global var
  saveTextWidget $dialogId $dialogW.text $classType $attributeName $attributeType
  global g_NM_terminalDocInput_$dialogId
  set terminalDoc [subst $[subst g_NM_terminalDocInput_$dialogId]]

  set attributeFacts {}
  if {[string match $className "attribute"] || \
          [string match $className "displayState"]} {
    # saveTextWidget puts facts into global var
    if {[saveTextWidget $dialogId $dialogW.factsEmacs attribute facts \
             (0-n_javaMplForms)]} {
      return
    }
    set attributeFacts [getTextWidgetText $dialogId attribute facts 0]
    # component/module parameters, e.g. ?active, need to have the ? removed
    # so that it will not be substituted for its value by Stanley
    # it will be its value from L2
    regsub -all "\\\?" $attributeFacts "" tmp
    set attributeFacts $tmp
    terminateJmplForm attributeFacts
    # convert JMPL code to TCL
    set printP 0
    if {[convertJmplToTcl $attributeFacts "" "" displayStateProcArgs \
             "terminalInstanceUpdate" $printP] == ""} {
      return
    }
  }

  if {[string match $caller "canvasB1Click"]} {
    set valueList [list $terminalNameInternal $terminalType $terminalDoc \
                       $attributeFacts $terminalLabelExternal]
    if {[string match $classType "terminal"]} {
      # expand number of values if multi-dimensional 1 arg structure
      set cmdMonValueList [expandCmdMonValues $terminalType $commandMonitorTypeValue]
      lappend valueList [list $commandMonitorType $cmdMonValueList] $interfaceType 
    }
    set g_NM_terminalInstance $valueList 
  } elseif {[string match $caller "mkNode"] || \
                [string match $caller "editClassDefParams"]} {
    # called by Mouse-R binding done in mkNode, or
    # called by Menu Header->Display Attribute via editClassDefParams 
    # update the existing node here
    # className = displayState is not bound by mkNode (it is not displayed to user)
    if {[string match $className "output"]} {
      set termType inputs; set termAtt in1; set dir in
    } else {
      set termType outputs; set termAtt out1; set dir out
    }
    set oldNodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    set terminalList [assoc $termType pirNode($pirNodeIndex)]
    set window [assoc window pirNode($pirNodeIndex)] 
    set terminalDef [assoc $termAtt terminalList]
    set termDirection [getTerminalDirection $terminalDef]
    set newTerminalDef [list terminal_name $terminalNameInternal \
                            terminal_label $terminalLabelExternal]
    acons type [list $terminalType $termDirection] newTerminalDef 
    if {[string match $classType "terminal"]} {
      # expand number of values if multi-dimensional 1 arg structure
      set cmdMonValueList [expandCmdMonValues $terminalType $commandMonitorTypeValue]
      lappend newTerminalDef commandMonitorType \
          [list $commandMonitorType $cmdMonValueList]
      lappend newTerminalDef interfaceType $interfaceType 
    
      # check that connections to this terminal are still valid with new type
      set invalidEdgeIndices {}
      set edgesList {}
      set edgesFromListofLists [assoc edgesFrom pirNode($pirNodeIndex)]
      foreach elist $edgesFromListofLists {
        foreach e $elist {
          if {! [string match $e ""]} { lappend edgesList $e }
        }
      }
      set edgesToListofLists [assoc edgesTo pirNode($pirNodeIndex)]
      foreach elist $edgesToListofLists {
        foreach e $elist {
          if {! [string match $e ""]} { lappend edgesList $e }
        }
      }
      foreach edgeIndex $edgesList {
        if {[string match [assoc nodeFrom pirEdge($edgeIndex)] $pirNodeIndex]} {
          set edgeType [getTerminalType [assoc terminalFrom pirEdge($edgeIndex)]]
        } else {
          set edgeType [getTerminalType [assoc terminalTo pirEdge($edgeIndex)]]
        }
        if {! [string match $edgeType $terminalType]} {
          lappend invalidEdgeIndices $edgeIndex
        }
      }
      if {! [string match $invalidEdgeIndices ""]} {
        set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
        set canvas $currentCanvas.c
        foreach edgeIndex $invalidEdgeIndices {
          set canvasId [assoc canvasId pirEdge($edgeIndex)]
          $canvas itemconfigure $canvasId \
              -fill $pirPreferences(StanleyAttentionWarningBgColor)
        }
        set dialogList [list tk_dialog .d "WARNING" \
                            "Red connections are now invalid and will be deleted\!" \
                            warning 0 {Dismiss}]
        eval $dialogList
        cutEdgeSetList $canvas invalidEdgeIndices 
      }
    }
    arepl $termAtt $newTerminalDef terminalList
    arepl $termType $terminalList pirNode($pirNodeIndex)

    arepl instanceLabel $terminalLabelExternal pirNode($pirNodeIndex)
    renameTerminalInstance $oldNodeInstanceName $terminalNameInternal \
        $className $pirNodeIndex
    if {! [string match $className "displayState"]} {
      set balloonWidget $window.$dir.b1
      if {[string match $classType "terminal"]} {
        # set button icon acccording to interfaceType
        configureTerminalButtonBitmap $balloonWidget $newTerminalDef 
      }
      # update balloon help
      set valuesList [terminalBalloonHelp newTerminalDef \
                          [list $terminalNameExternal] \
                          $terminalLabelExternal $terminalType $classType \
                          $className $balloonWidget]
      # update propositions menu
      set editInputsOutputsP 1; set msg2 ""
      buttonMouseRightOpsMenu $newTerminalDef $editInputsOutputsP \
          $window $dir 1 $terminalLabelExternal $valuesList \
          $pirNodeIndex $classType msg2 
    }
 
    if {[string match $className "attribute"] || \
            [string match $className "displayState"]} {
      arepl facts "\{$attributeFacts\}" pirNode($pirNodeIndex)
    }
    arepl nodeDescription $terminalDoc pirNode($pirNodeIndex)
  } else {
    error "terminalInstanceUpdate: caller $caller not handled"
  }

  set jmplModifiedP 1
  if {[string match $className "displayState"]} {
    # dislay state attributes do not go into jmpl code
    set jmplModifiedP 0
  }
  mark_scm_modified $jmplModifiedP 
  set g_NM_mkformNodeCompleteP 1
  destroy $dialogW
  ## slow
  ## raiseStanleyWindows 
}


## set up motion of a terminal as a main canvas window to move inside
## the node instance
## x & y are relative to the node
## 04june98 wmt:  wysiwyg terminal reordering for components & modules
proc terminalStartMotion {canvas nodePath buttonPath x y} {
  global pirDisplay pirNodes pirEdges pirNode pirEdge
  global pirWireFrame STANLEY_ROOT g_NM_reorderedButtonPath

  # puts stderr "terminalStartMotion: $canvas $buttonPath $x $y"
  # save the original cursor coordinates for the final move
  set pirWireFrame(curX) $x
  set pirWireFrame(curY) $y

  getButtonXYNodePosition $canvas $nodePath $buttonPath xx yy

  set pirWireFrame(originX) $xx
  set pirWireFrame(originY) $yy 
  set pirWireFrame(x) $x
  set pirWireFrame(y) $y
  # puts stderr "terminalStartMotion: x $x y $y Wirex $pirWireFrame(x) Wirey $pirWireFrame(y)"
  # puts stderr "terminalStartMotion: $xx $yy"

  getLocation&NumFromButton $buttonPath location dummy
  set bitmap [getTerminalButtonBitmap [getTerminalFormFromButtonPath $buttonPath] \
                  ${location}puts]

  set bg [preferred StanleySelectedColor]
  set winname [uniqueWindowName $canvas]
  frame $canvas.$winname -bd 0 -relief groove -highlightthickness 2 \
      -highlightbackground $bg -highlightcolor $bg 
  frame $canvas.$winname.button
  button $canvas.$winname.button.but -bitmap $bitmap \
      -relief flat -bd 0.0 -pady 0.0 -highlightthickness 0 -bg $bg 
  
  pack $canvas.$winname.button.but -side left -fill x -expand 1
  pack $canvas.$winname.button -side left -fill x -expand 1 
  set pirWireFrame(item) \
      [$canvas create window $xx $yy -anchor nw -tags terminal \
           -window $canvas.$winname]
  set g_NM_reorderedButtonPath $canvas.$winname
}
  

## 05jun98 wmt: wysiwyg terminal reordering -> not finished
## execute terminal motion. Move the "wire frame" only.
## actually, the  "wire frame" is a window
proc terminalMotion {canvas x y} {
  global pirWireFrame 

  # check for weird event situation which causes this to be
  # called
  if {[info exists pirWireFrame(x)] && [info exists pirWireFrame(y)]} {
    set distX [expr {$x-$pirWireFrame(x)}]
    set distY [expr {$y-$pirWireFrame(y)}]
    # puts stderr "terminalMotion: $distX $distY"
    $canvas move $pirWireFrame(item) $distX $distY
    set pirWireFrame(x) $x
    set pirWireFrame(y) $y
  }
}


## terminalMotionRelease -- delete the button window; if outside
## the component/module node -> no action; otherwise determine
## new ordering of input or output terminals, depending on where
## it was placed
## 05jun98 wmt: wysiwyg terminal reordering -> not finished
proc terminalMotionRelease {canvas  nodePath reorderedTerminalName \
                                pirNodeIndex x y} {
  global pirDisplay pirNodes pirEdges  pirNode pirEdge
  global g_NM_reorderedButtonPath pirWireFrame g_NM_classInstance
  global g_NM_terminalNameListNew_in g_NM_terminalNameListNew_out
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_mkformNodeCompleteP g_NM_canvasRedrawP

  set caller "terminalMotionRelease"
  # puts stderr "stop: x $x curX $pirWireFrame(curX) originX $pirWireFrame(originX)"
  # puts stderr "stop: y $y curY $pirWireFrame(curY) originY $pirWireFrame(originY)"

  # does not work if canvas is scrolled
  # set releasedX [expr {$pirWireFrame(originX) + ($x - $pirWireFrame(curX))}]
  # set releasedY [expr {$pirWireFrame(originY) + ($y - $pirWireFrame(curY))}]
  set releasedX [expr {$pirWireFrame(originX) + $x}]
  set releasedY [expr {$pirWireFrame(originY) + $y}]
  scan [winfo geometry $nodePath] "%dx%d+%d+%d" nodeWidth nodeHeight \
      nodeX nodeY
  # g_NM_reorderedButtonPath has canvas coords, not relative to node like
  # the existing buttons
  scan [winfo geometry $g_NM_reorderedButtonPath ] "%dx%d+%d+%d" \
      buttonWidth buttonHeight reorderedButtonX reorderedButtonY 
  # puts stderr "$g_NM_reorderedButtonPath $reorderedButtonX $reorderedButtonY"
  set xMin [$canvas canvasx $nodeX]; set xMax [expr {$xMin + $nodeWidth}]
  set yMin [expr {[$canvas canvasy $nodeY] - $buttonHeight / 2}]
  set yMax [expr $yMin + $nodeHeight]
  # puts stderr "terminalMotionRelease: xMin $xMin xMax $xMax yMin $yMin yMax $yMax"
  # puts stderr "terminalMotionRelease: releasedY $releasedY releasedX $releasedX"

  if {($releasedX < $xMin) || ($releasedX > $xMax) || \
                 ($releasedY < $yMin) || ($releasedY > $yMax)} {
    destroy $g_NM_reorderedButtonPath
    return
  }

  if {$releasedY < ($yMin + $nodeHeight / 2)} {
    set reorderLocation top
  } else {
    set reorderLocation bottom
  }
  set inIds {}; set outIds {}
  set window [assoc window pirNode($pirNodeIndex)]
  set inTypeLists [assoc inputs pirNode($pirNodeIndex)]
  set numInputs [assoc numInputs pirNode($pirNodeIndex)]
  for {set i 1} {$i <= $numInputs} {incr i} {
    set terminalForm [assoc in$i inTypeLists]
    set terminalName [assoc terminal_name terminalForm]
    if {! [string match $terminalName $reorderedTerminalName]} {
      set buttonPath $window.in.b$i
      getButtonXYNodePosition $canvas $nodePath $buttonPath x y
      lappend inIds [list $terminalName $x]
    }
  }
  if {[string match $reorderLocation top]} {
    lappend inIds [list $reorderedTerminalName $reorderedButtonX]
  }
  # puts stderr "IN inIds $inIds"
  set outTypeLists [assoc outputs pirNode($pirNodeIndex)]
  set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
  for {set i 1} {$i <= $numOutputs} {incr i} {
    set terminalForm [assoc out$i outTypeLists]
    set terminalName [assoc terminal_name terminalForm]
    if {! [string match $terminalName $reorderedTerminalName]} {
      set buttonPath $window.out.b$i
      getButtonXYNodePosition $canvas $nodePath $buttonPath x y
      lappend outIds [list $terminalName $x]
    }
  }
  if {[string match $reorderLocation bottom]} {
    lappend outIds [list $reorderedTerminalName $reorderedButtonX]
  }
  # puts stderr "OUT outIds $outIds"

  set sortedInIds [lsort -command xCoordCompare $inIds]
  set sortedOutIds [lsort -command xCoordCompare $outIds]
  set inputTerminalList {}
  foreach idPair $sortedInIds {
    set terminalName [lindex $idPair 0] 
    lappend inputTerminalList $terminalName
  }
  # puts stderr "terminalMotionRelease: IN $inputTerminalList"
  set g_NM_terminalNameListNew_in $inputTerminalList 

  set outputTerminalList {}  
  foreach idPair $sortedOutIds {
    set terminalName [lindex $idPair 0] 
    lappend outputTerminalList $terminalName 
  }
  # puts stderr "terminalMotionRelease: OUT $outputTerminalList"
  set g_NM_terminalNameListNew_out $outputTerminalList 

  # puts stderr "terminalMotionRelease: g_NM_reorderedButtonPath $g_NM_reorderedButtonPath"
  destroy $g_NM_reorderedButtonPath

  if {[terminalOrderingUpdate $pirNodeIndex]} {
    # redraw node with reordered terminals
    set interactiveP 0; set g_NM_mkformNodeCompleteP 1; set nodeDescription ""
    # needed for redrawNodeEdges
    # needed for deleteClassInstance so that module args/params are not deleted
    set  g_NM_canvasRedrawP 1
    set g_NM_classInstance [list [assoc nodeInstanceName pirNode($pirNodeIndex)] \
                                [assoc instanceLabel pirNode($pirNodeIndex)] \
                                $nodeDescription \
                                [assoc argsValues pirNode($pirNodeIndex)]]
    editComponentModule $pirNodeIndex $interactiveP $caller

  }
  update
}


## wysiwyg editing an existing component/module terminals
## 14jul98 wmt: new
proc terminalOrderingUpdate { pirNodeIndex } {
  global pirNode pirEdge 
  global g_NM_edgesOfRedrawNode 
  global g_NM_terminalNameListNew_in g_NM_terminalNameListNew_out

  set g_NM_edgesOfRedrawNode [list edgesFrom [assoc edgesFrom pirNode($pirNodeIndex)] \
                                  edgesTo [assoc edgesTo pirNode($pirNodeIndex)]]
  set inOrderChangedP 0; set outOrderChangedP 0
  # check that option menu selections are all unique
  set numInputs [assoc numInputs pirNode($pirNodeIndex)] 
  set inTypeLists [assoc inputs pirNode($pirNodeIndex)]
  for {set i 1} {$i <= $numInputs} {incr i} {
    set terminalForm [assoc in$i inTypeLists]
    set terminalName [assoc terminal_name terminalForm] 
    lappend terminalNameList_in $terminalName 
  }
  set numOutputs [assoc numOutputs pirNode($pirNodeIndex)] 
  set outTypeLists [assoc outputs pirNode($pirNodeIndex)]
  for {set i 1} {$i <= $numOutputs} {incr i} {
    set terminalForm [assoc out$i outTypeLists]
    set terminalName [assoc terminal_name terminalForm] 
    lappend terminalNameList_out $terminalName 
  }
  set edgesFrom [assoc edgesFrom pirNode($pirNodeIndex)]
  set edgesTo [assoc edgesTo pirNode($pirNodeIndex)]
  # puts stderr "terminalOrderingUpdate B: edgesFrom $edgesFrom"
  # puts stderr "terminalOrderingUpdate B: edgesTo $edgesTo"

  set numInputsNew [llength $g_NM_terminalNameListNew_in] 
  if {$numInputs != $numInputsNew} {
    arepl numInputs $numInputsNew pirNode($pirNodeIndex)
    set inOrderChangedP 1
  } else {
    for {set i 1} {$i <= $numInputs} {incr i} {
      if {! [string match [lindex $g_NM_terminalNameListNew_in $i]  \
                 [lindex $terminalNameList_in $i]]} {
        set inOrderChangedP 1
        break
      }
    }
  }
  set numOutputsNew [llength $g_NM_terminalNameListNew_out]  
  if {$numOutputs != $numOutputsNew} {
    arepl numOutputs $numOutputsNew pirNode($pirNodeIndex) 
    set outOrderChangedP 1
  } else {
    for {set i 1} {$i <= $numOutputs} {incr i} {
      if {! [string match [lindex $g_NM_terminalNameListNew_out $i]  \
                 [lindex $terminalNameList_out $i]]} {
        set outOrderChangedP 1
        break
      }
    }
  }   
  # set str "terminalOrderingUpdate: inOrderChangedP $inOrderChangedP"
  # puts stderr "$str outOrderChangedP $outOrderChangedP"

  # reorder inputs and outputs in pirNode($pirNodeIndex)

  # set str "terminalOrderingUpdate B: g_NM_terminalNameListNew_in"
  # puts stderr "$str $g_NM_terminalNameListNew_in"
  # puts stderr "terminalOrderingUpdate B: inTypeLists $inTypeLists"
  # set str "terminalOrderingUpdate B: g_NM_terminalNameListNew_out"
  # puts stderr "$str $g_NM_terminalNameListNew_out"
  # puts stderr "terminalOrderingUpdate B: outTypeLists $outTypeLists"
  if {$inOrderChangedP} {
    set new_inputs {}; set new_inputLabels {}; set new_i 1
    set newEdgesTo {}
    foreach selectedName $g_NM_terminalNameListNew_in {
      set foundP 0
      # check pirNode inputs
      for {set i 1} {$i <= $numInputs} {incr i} {
        set internalTerminalForm [assoc in$i inTypeLists]
        set externalTerminalForm $internalTerminalForm 
        set terminalName [assoc terminal_name externalTerminalForm]
        # puts stderr "terminalName 1 `$terminalName' selectedName `$selectedName'"
        if {[string match $terminalName $selectedName]} {
          lappend new_inputs in$new_i $internalTerminalForm 
          if {$pirNodeIndex != 0} {
            lappend newEdgesTo [lindex $edgesTo [expr {$i - 1}]]
          }
          set foundP 1
          break
        }
      }
      if {! $foundP} {
        # check pirNode outputs
        for {set i 1} {$i <= $numOutputs} {incr i} {
          set internalTerminalForm [assoc out$i outTypeLists]
          set externalTerminalForm $internalTerminalForm 
          set terminalName [assoc terminal_name externalTerminalForm]
          # puts stderr "terminalName 2 `$terminalName' selectedName `$selectedName'"
          if {[string match $terminalName $selectedName]} {
            lappend new_inputs in$new_i $internalTerminalForm 
            if {$pirNodeIndex != 0} {
              lappend newEdgesTo [lindex $edgesFrom [expr {$i - 1}]]
            }
            set foundP 1
            break
          }
        }
      }
      lappend new_inputLabels in$new_i 
      incr new_i  
    }
    # correct the button numbers and positions (in/out) in the pirEdge structures
    # puts stderr "terminalOrderingUpdate: newEdgesTo $newEdgesTo"
    for {set i 1} {$i <= $numInputsNew} {incr i} {
      foreach pirEdgesIndex [lindex $newEdgesTo [expr {$i - 1}]] {
        set buttonKey buttonTo
        if {$pirNodeIndex == [assoc nodeFrom pirEdge($pirEdgesIndex)]} {
          set buttonKey buttonFrom
        }
        set button [assoc $buttonKey pirEdge($pirEdgesIndex)]
        # puts stderr "button $button"
        set indx [string last "." $button]
        set tmp [string range $button 0 [expr {$indx - 1}]]
        set indx [string last "." $tmp]
        set newButton "[string range $tmp 0 $indx]in.b$i"
        arepl $buttonKey $newButton pirEdge($pirEdgesIndex)
        # set str "terminalOrderingUpdate: pirEdgesIndex $pirEdgesIndex"
        # puts stderr "$str $buttonKey $newButton"
      }
    }
    # puts stderr "terminalOrderingUpdate A: newEdgesTo $newEdgesTo"
    arepl edgesTo $newEdgesTo pirNode($pirNodeIndex)
    arepl edgesTo $newEdgesTo g_NM_edgesOfRedrawNode 
    # puts stderr "terminalOrderingUpdate A: new_inputs $new_inputs"
    arepl inputs $new_inputs pirNode($pirNodeIndex)
    arepl inputLabels $new_inputLabels pirNode($pirNodeIndex)
  }

  if {$outOrderChangedP} {
    set new_outputs {}; set new_outputLabels {}; set new_i 1
    set newEdgesFrom {}
    foreach selectedName $g_NM_terminalNameListNew_out {
      set foundP 0 
      # check pirNode outputs
      for {set i 1} {$i <= $numOutputs} {incr i} {
        set internalTerminalForm [assoc out$i outTypeLists]
        set externalTerminalForm $internalTerminalForm 
        set terminalName [assoc terminal_name externalTerminalForm] 
        if {[string match $terminalName $selectedName]} {
          lappend new_outputs out$new_i $internalTerminalForm 
          if {$pirNodeIndex != 0} {
            lappend newEdgesFrom [lindex $edgesFrom [expr {$i - 1}]]
          }
          set foundP 1 
          break
        }
      }
      if {! $foundP} {
        # check pirNode inputs
        for {set i 1} {$i <= $numInputs} {incr i} {
          set internalTerminalForm [assoc in$i inTypeLists]
          set externalTerminalForm $internalTerminalForm 
          set terminalName [assoc terminal_name externalTerminalForm]
          if {[string match $terminalName $selectedName]} {
            lappend new_outputs out$new_i $internalTerminalForm 
            if {$pirNodeIndex != 0} {
              lappend newEdgesFrom [lindex $edgesTo [expr {$i - 1}]]
            }
            set foundP 1
            break
          }
        }
      }
      lappend new_outputLabels out$new_i 
      incr new_i
    }
    # correct the button numbers and positions (in/out) in the pirEdge structures
    for {set i 1} {$i <= $numOutputsNew} {incr i} {
      foreach pirEdgesIndex [lindex $newEdgesFrom [expr {$i - 1}]] {
        set buttonKey buttonFrom
        if {$pirNodeIndex == [assoc nodeTo pirEdge($pirEdgesIndex)]} {
          set buttonKey buttonTo
        }
        set button [assoc $buttonKey pirEdge($pirEdgesIndex)]
        # puts stderr "button $button"
        set indx [string last "." $button]
        set tmp [string range $button 0 [expr {$indx - 1}]]
        set indx [string last "." $tmp]
        set newButton "[string range $tmp 0 $indx]out.b$i"
        arepl $buttonKey $newButton pirEdge($pirEdgesIndex)
        # set str "terminalOrderingUpdate: pirEdgesIndex $pirEdgesIndex"
        # puts stderr "$str $buttonKey $newButton"
      }
    }
    # puts stderr "terminalOrderingUpdate A: newEdgesFrom $newEdgesFrom"
    arepl edgesFrom $newEdgesFrom pirNode($pirNodeIndex)
    arepl edgesFrom $newEdgesFrom g_NM_edgesOfRedrawNode
    # puts stderr "terminalOrderingUpdate A: new_outputs $new_outputs"
    arepl outputs $new_outputs pirNode($pirNodeIndex)
    arepl outputLabels $new_outputLabels pirNode($pirNodeIndex)
  }
  return [expr {$inOrderChangedP || $outOrderChangedP}]
}


## compare proc for lsort of terminal node x locations
## 05may98 wmt: new
proc xCoordCompare { a b } {

  set aXCoord [lindex $a 1]
  set bXCoord [lindex $b 1]
  if {$aXCoord < $bXCoord} {
    return -1
  } else {
    return +1
  }
}


## update defcomponent/defmodule root node {input|output|port}_terminals 
## with INPUT/OUTPUT/PORT terminal
## 01oct96 wmt: new
## 04jun97 wmt: add className ATTRIBUTE; do not add terminalDoc & declaration_p
## 10jul97 wmt: renamed from updateDefmoduleTerminal 
proc updateDefmoduleDefcomponentTerminal { className instanceNameInternal } {
  global g_NM_rootInstanceName pirNode g_NM_componentToNode 
  global g_NM_terminalInstance g_NM_moduleToNode g_NM_classDefType

#   set str "updateDefmoduleDefcomponentTerminal: className $className"
#   puts stderr "$str instanceNameInternal $instanceNameInternal"
  set nodeInstanceName $g_NM_rootInstanceName
   if {[string match $g_NM_classDefType component]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_componentToNode]
  } elseif {[string match $g_NM_classDefType module]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_moduleToNode]
  } else {
    error "updateDefmoduleDefcomponentTerminal: g_NM_classDefType $g_NM_classDefType not handled"
  }
  if {[string match $className "input"]} {
    set currentEntries [assoc input_terminals pirNode($pirNodeIndex)]
    lappend currentEntries $instanceNameInternal
    arepl input_terminals $currentEntries pirNode($pirNodeIndex)
    ## directional sense is opposite
  } elseif {[string match $className "output"]} {
    set currentEntries [assoc output_terminals pirNode($pirNodeIndex)]
    lappend currentEntries $instanceNameInternal
    arepl output_terminals $currentEntries pirNode($pirNodeIndex)
    ## directional sense is opposite
  } elseif {[string match $className "port"]} {
    set currentEntries [assoc port_terminals pirNode($pirNodeIndex)]
    lappend currentEntries $instanceNameInternal
    arepl port_terminals $currentEntries pirNode($pirNodeIndex)
  } elseif {[string match $className "attribute"] || \
                [string match $className "displayState"]} {
    set currentEntries [assoc attributes pirNode($pirNodeIndex)]
    lappend currentEntries $instanceNameInternal
    arepl attributes $currentEntries pirNode($pirNodeIndex)
  } else {
    set str "updateDefmoduleDefcomponentTerminal: for classType terminal, className"
    puts stderr "$str $className not handled\!"
  }
}


## start rubber-banding connection of two component/module terminals
## 04dec97 wmt: new
proc buttonConnectStartMotion { canvas buttonWidget eventX eventY } {
  global g_NM_buttonConnectStopButtonPath pirWireFrame
  global g_NM_buttonConnectStartButtonPath pirNode 

  set g_NM_buttonConnectStopButtonPath {}
  $canvas delete wire
  getCanvasXYFromEventXY $canvas $eventX $eventY canvasX canvasY
  # set str "buttonConnectStartMotion: eventX $eventX eventY $eventY"
  # puts stderr "$str canvasX $canvasX canvasY $canvasY"
  set pirWireFrame(curX) $canvasX 
  set pirWireFrame(curY) $canvasY 
  disableSelectionMenus
  # canvas x,y for line start
  set pirWireFrame(x) $pirWireFrame(curX)
  set pirWireFrame(y) $pirWireFrame(curY)
  set pirWireFrame(deltaX) 0; set pirWireFrame(deltaY) 0

  set g_NM_buttonConnectStartButtonPath $buttonWidget 

  # put up terminal ballon help which will last until connection operation
  # is complete
  getLocation&NumFromButton $buttonWidget buttonLocation buttonNum
  set buttonDirection [getTerminalButtonDirectionType $buttonWidget]
  set pirNodeIndex [getPirNodeIndexFromButtonPath $buttonWidget]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set window [assoc window pirNode($pirNodeIndex)]
  set connectionP 1; set reportNotFoundP 0
  set typeLists [assoc ${buttonLocation}puts pirNode($pirNodeIndex)]
  set terminalList [assoc ${buttonLocation}$buttonNum typeLists]
  set terminalName [list [assoc terminal_name terminalList]]
  set labelName [assoc terminal_label terminalList $reportNotFoundP]
  set type [getTerminalType $terminalList]
  terminalBalloonHelp terminalList $terminalName $labelName $type \
      $nodeClassType $nodeClassName $window $buttonLocation $buttonNum $connectionP 
}


## during rubber-banding connection of two component/module terminals
## determine if mouse is over a potential connecting terminal, and
## if so generate balloon help 
## 04dec97 wmt: new
proc buttonConnectMotion { canvas startTerminalButton eventX eventY } {
  global g_NM_buttonConnectStopButtonPath g_NM_buttonConnectStartButtonPath
  global pirWireFrame g_NM_buttonConnectStopButtonPath 

  if {[string match $g_NM_buttonConnectStartButtonPath ""]} {
    return
  }
  getCanvasXYFromEventXY $canvas $eventX $eventY canvasX canvasY
  # puts stderr "\neventX $eventX eventY $eventY canvasX $canvasX canvasY $canvasY"
  if {($pirWireFrame(curX) != $canvasX) && ($pirWireFrame(curY) != $canvasY)} {
    $canvas delete wire
    $canvas addtag wire withtag [$canvas create line \
                                     $pirWireFrame(x) $pirWireFrame(y) \
                                     $canvasX $canvasY \
                                     -fill [preferred StanleyRubberBandColor]]
    # puts stderr "buttonConnectMotion: $pirWireFrame(x) $pirWireFrame(y) $canvasX $canvasY"
  }
  set closestList [$canvas find overlapping $canvasX $canvasY $canvasX $canvasY]
  set canvasIdList {}
  foreach i $closestList {
    # puts stderr "buttonConnectMotion: i $i tags [$canvas gettags $i]"
    if {[lsearch [$canvas gettags $i] node] != -1} {
      lappend canvasIdList $i
    }
  }
  # puts stderr "closestList $closestList canvasIdList $canvasIdList"
  set canvasId [lindex $canvasIdList 0]
  set nodePath [lindex [$canvas itemconfigure $canvasId -window] 4]
  if {(! [string match $nodePath ""]) && \
          (! [string match $nodePath [getWindowFromButton $startTerminalButton]])} {
    # set str "canvasId $canvasId nodePath $nodePath x [winfo rootx $nodePath]"
    # puts stderr "$str y [winfo rooty $nodePath]"
    set balloonHelpButton {}
    foreach inButton [winfo children ${nodePath}.in] {
      if {! [regexp "empty" [lindex [$inButton config -bitmap] 4]]} {
        set x [winfo rootx $inButton] 
        set y [winfo rooty $inButton] 
        # set str "inButton $inButton x $x [expr $x + [winfo width $inButton]]"
        # puts stderr "$str y $y [expr $y + [winfo height $inButton]]"
        if {($eventX >= $x) && \
                ($eventX <= ($x + [winfo width $inButton])) && \
                ($eventY >= $y) && \
                ($eventY <= ($y + [winfo height $inButton]))} {
          set balloonHelpButton $inButton
        }
      }
    }
    if {[string match $balloonHelpButton ""]} {
      foreach outButton [winfo children ${nodePath}.out] {
        if {! [regexp "empty" [lindex [$outButton config -bitmap] 4]]} {
          set x [winfo rootx $outButton] 
          set y [winfo rooty $outButton] 
          # set str "outButton $outButton x $x [expr $x + [winfo width $outButton]]"
          # puts stderr "$str y $y [expr $y + [winfo height $outButton]]"
          if {($eventX >= $x) && \
                  ($eventX <= ($x + [winfo width $outButton])) && \
                  ($eventY >= $y) && \
                  ($eventY <= ($y + [winfo height $outButton]))} {
            set balloonHelpButton $outButton
          }
        }
      }
    }
    # puts stderr "balloonHelpButton $balloonHelpButton"
    if {! [string match $balloonHelpButton ""]} {
      if {! [string match $balloonHelpButton $g_NM_buttonConnectStopButtonPath]} {
        set g_NM_buttonConnectStopButtonPath $balloonHelpButton 
        event generate $balloonHelpButton <Enter>
        # puts stderr "buttonConnectMotion: $balloonHelpButton <Enter>"
      }
    } elseif {! [string match $g_NM_buttonConnectStopButtonPath ""]} {
      event generate $g_NM_buttonConnectStopButtonPath <Leave>
      # puts stderr "buttonConnectMotion: $g_NM_buttonConnectStopButtonPath <Leave>"
      set g_NM_buttonConnectStopButtonPath {}
    }
  } else {
    if {! [string match $g_NM_buttonConnectStopButtonPath ""]} {
      event generate $g_NM_buttonConnectStopButtonPath <Leave>
      # puts stderr "buttonConnectMotion: $g_NM_buttonConnectStopButtonPath <Leave>"
      set g_NM_buttonConnectStopButtonPath {}
    }
  }    
}


## if checking succeeds, draw a two-break connection
## 04dec97 wmt: new
proc buttonConnectB1Release { canvas startTerminalButton eventX eventY } {
  global g_NM_termtypeRootWindow g_NM_buttonConnectStopButtonPath
  global pirWireFrame pirDisplay g_NM_permBalloonRootWindow
  global g_NM_buttonConnectStartButtonPath 

  # puts stderr "buttonConnectB1Release: canvas $canvas"

  $canvas delete wire
  # delete perm balloon of from terminal
  deleteAllPopUpWindows $g_NM_permBalloonRootWindow
  set toleranceX [winfo width $startTerminalButton]
  set toleranceY [winfo height $startTerminalButton]
  getCanvasXYFromEventXY $canvas $eventX $eventY canvasX canvasY
  if {(abs ( $pirWireFrame(curX) - $canvasX ) < $toleranceX) && \
          (abs ( $pirWireFrame(curY) - $canvasY ) < $toleranceY)} {
    # do nothing -- this is same button
  } else {
    # deleteAllPopUpWindows $g_NM_termtypeRootWindow
    # deselect input and output buttons
    nodeInDeselect; 
    nodeOutDeselect
    set bothP 1; nodePortDeselect $bothP
    set reportNotFoundP 0

    if {! [string match $g_NM_buttonConnectStopButtonPath ""]} {
      # set str "buttonConnectB1Release: startTerminalButton $startTerminalButton"
      # puts stderr "$str g_NM_buttonConnectStartButtonPath $g_NM_buttonConnectStartButtonPath"
      # puts stderr "   g_NM_buttonConnectStopButtonPath $g_NM_buttonConnectStopButtonPath"
      set numBreaks 2; set numInputs 0; set numOutputs 0
      if {[regexp "in" [getTerminalButtonDirectionType \
                            $startTerminalButton]]} {
        nodeInSelectNoshift $startTerminalButton
        incr numInputs 
      } else {
        nodeOutSelectNoshift $startTerminalButton
        incr numOutputs 
      }
      if {[regexp "in" [getTerminalButtonDirectionType \
                            $g_NM_buttonConnectStopButtonPath]]} {
        nodeInSelectNoshift $g_NM_buttonConnectStopButtonPath
        incr numInputs 
      } else {
        nodeOutSelectNoshift $g_NM_buttonConnectStopButtonPath
        incr numOutputs 
      }
      if {$numInputs == 2} {
        tk_dialog .d "ERROR" "You cannot connect two INPUT terminals." \
            error 0 DISMISS;
      } elseif {($numOutputs == 2) && \
                    [string match [assoc selectPort1 pirDisplay \
                                       $reportNotFoundP] ""] && \
                    [string match [assoc selectPort2 pirDisplay \
                                       $reportNotFoundP ] ""]} {
        tk_dialog .d "ERROR" "You cannot connect two OUTPUT terminals." \
            error 0 DISMISS;
      } else {

        mkEdge "" "" $numBreaks

      }
    }
  }
}


## delete or add nodes to defmodule input_terminals,
## output_terminals, port_terminals, or attributes lists
## 05jun97 wmt: new
proc modifyDefmoduleTerminalsAttributesList { pirNodeIndex modifyFunction} {
  global pirNode g_NM_moduleToNode g_NM_classDefType
  global g_NM_componentToNode 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "modifyDefmoduleTerminalsAttributesList: `$backtrace'"
  if {[lsearch -exact {lappend lremove} $modifyFunction] == -1} {
    error "modifyPirNodeTerminalsList: modifyFunction $modifyFunction not handled"
  }
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
#   puts stderr "modifyDefmoduleTerminalsAttributesList:"
#   puts stderr "    modifyFunction $modifyFunction nodeInstanceName $nodeInstanceName"
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeGroupName [assoc nodeGroupName pirNode($pirNodeIndex)]
  if {[string match $g_NM_classDefType module]} {
    set groupNodeIndex [assoc-array $nodeGroupName g_NM_moduleToNode]
  } elseif {[string match $g_NM_classDefType component]} {
    set groupNodeIndex [assoc-array $nodeGroupName g_NM_componentToNode]
  } else {
    error "modifyDefmoduleTerminalsAttributesList"
  }
  # inputs & outputs; inputLabels & outputLabels; numInputs & 
  # numOutputs are not modified due to addition/deletion of terminals
  # they are done in fileSave by createDefmoduleInputsOutputs
  if {[string match $nodeClassType "terminal"]} {
    if {[string match $nodeClassName "input"]} {
      set att input_terminals 
    } elseif {[string match $nodeClassName "output"]} {
      set att output_terminals 
    } elseif {[string match $nodeClassName "port"]} {
      set att port_terminals
    }
    set currentEntries [assoc $att pirNode($groupNodeIndex)]
    $modifyFunction currentEntries $nodeInstanceName 
    arepl $att $currentEntries pirNode($groupNodeIndex)
  } else {
    set currentEntries [assoc attributes pirNode($groupNodeIndex)]
    $modifyFunction currentEntries $nodeInstanceName 
    arepl attributes $currentEntries pirNode($groupNodeIndex)            
  }
}


## rebuild pirNode attributes:
## numInputs numOutputs inputs outputs outputLabels inputLabels
## from input_terminals, output_terminals & port_terminals
## create cfg model parsed forms -- cfgInputs, etc, to update pirClass:
## input_terminals, output_terminals & port_terminals
## these are written into .scm & .i-scm files
## create model forms -- inputsMplForm, etc to write into MIR model,
##  .jmpl files => return Mpl forms
## 01oct96 wmt: new
## 21nov96 wmt: set name_var in pirClass
## 05jun97 wmt: add attributes to pirClass
## 21jul97 wmt: updated to handle components: update mode, ok_modes &
##              fault_modes in pirClass entry
## 06jan98 wmt: add atttributeFactsMplList
## 01feb98 wmt: pirClassComponent or pirClassModule contents are moved
##              in to pirClass prior to calling this proc
proc createDefmoduleInputsOutputs { inputsMplStringRef outputsMplStringRef \
                                        portsMplStringRef inputDecsMplStringRef \
                                        outputDecsMplStringRef portDecsMplStringRef \
                                        attributesMplStringRef \
                                        attributeFactsMplStringRef \
                                        inherit_input_terminal_defsRef \
                                        inherit_output_terminal_defsRef \
                                        inputsMplListRef outputsMplListRef \
                                        { updateMplStringsOnly 0 } } {
  upvar $inputsMplStringRef inputsMplString
  upvar $outputsMplStringRef outputsMplString
  upvar $portsMplStringRef portsMplString
  upvar $inputDecsMplStringRef inputDecsMplString
  upvar $outputDecsMplStringRef outputDecsMplString
  upvar $portDecsMplStringRef portDecsMplString
  upvar $attributesMplStringRef attributesMplString
  upvar $attributeFactsMplStringRef attributeFactsMplString
  upvar $inherit_input_terminal_defsRef inherit_input_terminal_defs
  upvar $inherit_output_terminal_defsRef inherit_output_terminal_defs
  upvar $inputsMplListRef inputsMplList
  upvar $outputsMplListRef outputsMplList
  global g_NM_rootInstanceName g_NM_livingstoneDefmoduleNameVar
  global g_NM_instanceToNode pirNode pirClass g_NM_moduleToNode
  global g_NM_classDefType g_NM_componentToNode pirClassComponent pirClassModule 
  global g_NM_livingstoneDefcomponentNameVar pirNodes pirNode
  global g_NM_livingstoneDefcomponentArgList g_NM_livingstoneDefmoduleArgList
  global g_NM_livingstoneDefcomponentArgTypeList g_NM_livingstoneDefmoduleArgTypeList

  set reportNotFoundP 0; set oldvalMustExistP 0
  set nodeInstanceName $g_NM_rootInstanceName
  if {[string match $g_NM_classDefType module]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_moduleToNode]
  } elseif {[string match $g_NM_classDefType component]} {
    set pirNodeIndex [assoc-array $nodeInstanceName g_NM_componentToNode]
  } else {
    set str "createDefmoduleInputsOutputs: g_NM_classDefType"
    puts stderr "$str $g_NM_classDefType not handled"
    return
  }
  set port_terminals [assoc port_terminals pirNode($pirNodeIndex) \
                          $reportNotFoundP]
  set attributes [assoc attributes pirNode($pirNodeIndex) \
                      $reportNotFoundP]
  set numInputs 0; set numOutputs 0; set inputs {}; set outputs {}
  set inputLabels {}; set outputLabels {}
  set cfgInputs {}; set cfgOutputs {}; set cfgPorts {}
  set cfgAttributes {}

  set listIndex 0
  set input_terminals [alist-keys inherit_input_terminal_defs]
  set inputsMplString ""; set inputsMplList {}
  set input_terminals [lreverse $input_terminals]
  # puts stderr "createDefmoduleInputsOutputs: input_terminals $input_terminals"
  foreach terminalNodeName $input_terminals {
    set inheritList [assoc $terminalNodeName inherit_input_terminal_defs]
    set terminalP [lindex $inheritList 2] 
    if {$terminalP} {
      # input nodes have opposite directional sense
      set termAtt outputs; set inputNodeP 1
    } else {
      # this is an inherited input - normal directional sense
      set termAtt inputs; set inputNodeP 0
    }
    set termPirNodeIndex [lindex $inheritList 0]
    set termId [lindex $inheritList 1]

    # puts stderr "termPirNodeIndex input $termPirNodeIndex termAtt $termAtt termId $termId"
    set terminalList [assoc $termAtt pirNode($termPirNodeIndex) $reportNotFoundP]
    if {[string match $terminalList ""]} {
      # user has moved this inherited terminal from outputs to inputs - switch
      set termAtt inputs; set termId in1
      set terminalList [assoc $termAtt pirNode($termPirNodeIndex)]
    }
    set terminalForm [assoc $termId terminalList]
    if {$inputNodeP} {
      regsub " out\\\}" $terminalForm " in\}" formSub
      set terminalForm $formSub
      set terminalDoc [assoc nodeDescription pirNode($termPirNodeIndex)]
    } else {
      set terminalDoc ""
    }
    # puts stderr "terminalForm IN $terminalForm termPirNodeIndex $termPirNodeIndex"
    incr numInputs
    lappend inputLabels "in$numInputs"
    lappend inputs "in$numInputs" $terminalForm
    set form ""
    set externalNodeName [getExternalNodeName [assoc terminal_name terminalForm]]
    set type [getTerminalType $terminalForm]
    set interfaceType [assoc interfaceType terminalForm] 
    if {[regexp "\\\." $externalNodeName]} {
      # inherited terminal name, e.g. fl01.flowIn -- prefix interfaceType 
      lappend inputsMplList [list $interfaceType $type $externalNodeName]
    } else {
      append form "[convertDocToJmplComments terminalDoc]"
      append form "$type "
      append form "${externalNodeName};\n"
      append inputsMplString $form
    }
   
    lappend cfgInputs [list [getTerminalType $terminalForm] \
                           [assoc terminal_name terminalForm] \
                           [assoc terminal_label terminalForm $reportNotFoundP]]
    incr listIndex
  }
  # puts stderr "createDefmoduleInputsOutputs: numInputs $numInputs inputs $inputs"
  # puts stderr "createDefmoduleInputsOutputs: cfgInputs $cfgInputs"
  # puts stderr "createDefmoduleInputsOutputs: inputsMplString $inputsMplString"
  if {! $updateMplStringsOnly} {
    arepl numInputs $numInputs pirNode($pirNodeIndex)
    arepl inputs $inputs pirNode($pirNodeIndex)
    arepl inputLabels $inputLabels pirNode($pirNodeIndex)
  }

  set listIndex 0
  set output_terminals [alist-keys inherit_output_terminal_defs]
  # puts stderr "createDefmoduleInputsOutputs: output_terminals $output_terminals" 
  set outputsMplString ""
  set output_terminals [lreverse $output_terminals]
  foreach terminalNodeName $output_terminals {
   set inheritList [assoc $terminalNodeName inherit_output_terminal_defs]
    set terminalP [lindex $inheritList 2]
    if {$terminalP } {
      # output nodes have opposite directional sense
      set termAtt inputs; set outputNodeP 1
    } else {
      # this is an inherited output - normal directional sense
      set termAtt outputs; set outputNodeP 0
    }
    # puts stderr "createDefmoduleInputsOutputs: termAtt $termAtt inheritList $inheritList"
    set termPirNodeIndex [lindex $inheritList 0]
    set termId [lindex $inheritList 1]
    set nodeClassName [assoc nodeClassName pirNode($termPirNodeIndex)]
    if {[string match $nodeClassName PORT]} {
      # puts stderr "createDefmoduleInputsOutputs: port type"
      set termAtt outputs; set termId out1
    }
    
    # puts stderr "termPirNodeIndex output $termPirNodeIndex termAtt $termAtt termId $termId"
    set terminalList [assoc $termAtt pirNode($termPirNodeIndex) $reportNotFoundP]
    if {[string match $terminalList ""]} {
      # user has moved this inherited terminal from inputs to outputs - switch
      set termAtt outputs; set termId out1
      set terminalList [assoc $termAtt pirNode($termPirNodeIndex)]
    }
    set terminalForm [assoc $termId terminalList]
    if {$outputNodeP} {
      regsub " in\\\}" $terminalForm " out\}" formSub
      set terminalForm $formSub
      set terminalDoc [assoc nodeDescription pirNode($termPirNodeIndex)]
    } else {
      set terminalDoc ""
    }
    # puts stderr "terminalForm OUT $terminalForm termPirNodeIndex $termPirNodeIndex"
    incr numOutputs
    lappend outputLabels "out$numOutputs"
    lappend outputs "out$numOutputs" $terminalForm
    set form ""
    set externalNodeName [getExternalNodeName [assoc terminal_name terminalForm]]
    set type [getTerminalType $terminalForm]
    set interfaceType [assoc interfaceType terminalForm] 
    if {[regexp "\\\." $externalNodeName]} {
      # inherited terminal name, e.g. fl01.flowIn -- prefix interfaceType 
      lappend outputsMplList [list $interfaceType $type $externalNodeName]
    } else {
      append form "[convertDocToJmplComments terminalDoc]"
      append form "$type "
      append form "${externalNodeName};\n"
      append outputsMplString $form
    }

    lappend cfgOutputs [list [getTerminalType $terminalForm] \
                            [assoc terminal_name terminalForm] \
                            [assoc terminal_label terminalForm $reportNotFoundP]]
    incr listIndex
  }
  # puts stderr "createDefmoduleInputsOutputs: outputs $outputs"
  # puts stderr "createDefmoduleInputsOutputs: cfgOutputs $cfgOutputs"
  # puts stderr "createDefmoduleInputsOutputs: outputsMplString $outputsMplString"

  # puts stderr "createDefmoduleInputsOutputs: port_terminals $port_terminals"
  set portsMplString ""
  foreach terminalNodeName [lreverse $port_terminals] {
    set termPirNodeIndex [assoc-array $terminalNodeName g_NM_instanceToNode]
    set terminalList [assoc outputs pirNode($termPirNodeIndex)]
    set terminalForm [assoc out1 terminalList]
    set terminalDoc [assoc nodeDescription pirNode($termPirNodeIndex)]
    incr numOutputs
    lappend outputLabels "out$numOutputs"
    lappend outputs "out$numOutputs" $terminalForm

    set form ""
    append form "[convertDocToJmplComments terminalDoc]"
    set externalNodeName [getExternalNodeName [assoc terminal_name terminalForm]]
    if {[regexp "\\\." $externalNodeName]} {
      # inherited terminal name, e.g. fl01.flowIn -- cooment it
      append form "// "
    }
    set type [getTerminalType $terminalForm]
    append form "$type "
    append form "${externalNodeName};\n"
    append portsMplString " $form"

    lappend cfgPorts [list [getTerminalType $terminalForm] \
                          [assoc terminal_name terminalForm] \
                          [assoc terminal_label terminalForm $reportNotFoundP]]
  }
  # puts stderr "createDefmoduleInputsOutputs: cfgPorts $cfgPorts "
  # puts stderr "createDefmoduleInputsOutputs: portsMplString $portsMplString"

  # puts stderr "createDefmoduleInputsOutputs: attributes $attributes"
  set attributesMplString ""; set attributeFactsMplString "" 
  foreach terminalNodeName [lreverse $attributes] {
    set termPirNodeIndex [assoc-array $terminalNodeName g_NM_instanceToNode]
    set terminalClassName [assoc nodeClassName pirNode($termPirNodeIndex)]
    set terminalList [assoc outputs pirNode($termPirNodeIndex)]
    set terminalForm [assoc out1 terminalList]
    if {! [regexp "displayState" $terminalClassName]} {
      # do not put displayState attributes into JMPL code
      # displayState processing handled by generateDisplayStateProc, etc
      set terminalDoc [assoc nodeDescription pirNode($termPirNodeIndex)]
      set terminalFacts [assoc facts pirNode($termPirNodeIndex)]

      set form ""
      append form "[convertDocToJmplComments terminalDoc]"
      set externalNodeName [getExternalNodeName [assoc terminal_name terminalForm]]
      # currently, attributes are not inherited - so this is really not needed
      if {[regexp "\\\." $externalNodeName]} {
        # inherited terminal name, e.g. fl01.flowIn -- prefix interfaceType 
        append form "[assoc interfaceType terminalForm] "
      }
      set type [getTerminalType $terminalForm]
      append form "$type "
      append form "${externalNodeName};\n"
      set termFacts [string trim $terminalFacts "\{\}"]
      if {! [string match $termFacts ""]} {
        append attributeFactsMplString "$termFacts\n"
      }
      append attributesMplString $form 
    }
    lappend cfgAttributes [list [getTerminalType $terminalForm] \
                               [assoc terminal_name terminalForm] \
                               [assoc terminal_label terminalForm $reportNotFoundP]]
  }
  # puts stderr "createDefmoduleInputsOutputs: attributesMplString $attributesMplString"

  arepl input_terminals [alist-keys inherit_input_terminal_defs] \
      pirNode($pirNodeIndex)
  arepl output_terminals [alist-keys inherit_output_terminal_defs] \
      pirNode($pirNodeIndex)

  # puts stderr "createDefmoduleInputsOutputs: inputs $inputs"
  # puts stderr "createDefmoduleInputsOutputs: portsMplString $portsMplString"
  # puts stderr "createDefmoduleInputsOutputs: updateMplStringsOnly $updateMplStringsOnly"
  if {! $updateMplStringsOnly} {
    arepl numOutputs $numOutputs pirNode($pirNodeIndex)
    arepl outputs $outputs pirNode($pirNodeIndex)
    arepl outputLabels $outputLabels pirNode($pirNodeIndex)
    
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    set classVars [assoc class_variables pirClass($nodeClassName)]
    setClassVarDefaultValue input_terminals $cfgInputs classVars 
    setClassVarDefaultValue output_terminals $cfgOutputs classVars 
    setClassVarDefaultValue port_terminals $cfgPorts classVars
    setClassVarDefaultValue attributes $cfgAttributes classVars
    if {[string match $g_NM_classDefType module]} {
      set name_var $g_NM_livingstoneDefmoduleNameVar
      set args $g_NM_livingstoneDefmoduleArgList
      set argTypes $g_NM_livingstoneDefmoduleArgTypeList
    } elseif {[string match $g_NM_classDefType component]} {
      set name_var $g_NM_livingstoneDefcomponentNameVar
      set args $g_NM_livingstoneDefcomponentArgList
      set argTypes $g_NM_livingstoneDefcomponentArgTypeList
    } else {
      puts stderr \
          "createDefmoduleInputsOutputs-2: g_NM_classDefType $g_NM_classDefType not handled"
    }
    setClassVarDefaultValue name_var $name_var classVars
    setClassVarDefaultValue args $args classVars
    # kludge to add argTypes to classVars, so setClassVarDefaultValue
    # will not fail on old scematics
    set returnIndexP 1
    if {[assoc argTypes classVars $reportNotFoundP $returnIndexP] == -1} {
      lappend classVars argTypes [list default {}]
    }
    setClassVarDefaultValue argTypes $argTypes classVars

    if {[string match $g_NM_classDefType component]} {
      # update component pirClass mode parameters
      set ok_modes {}; set fault_modes {}; set mode_transitions {}
      set unknownFaultModeExistsP 0
      foreach pirNodeIndex $pirNodes {
        if {[string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                 mode]} {
          set className [assoc nodeClassName pirNode($pirNodeIndex)]
          set modeName [getExternalNodeName [assoc nodeInstanceName \
                                                   pirNode($pirNodeIndex)]]
          if {$modeName == "unknown"} {
            set str "mode `$modeName' is a reserved name;"
            append str "\nchoose something like `unknownFault'"
            set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
            eval $dialogList
            return 1
          }
          if {[string match $className okMode]} {
            lappend ok_modes $modeName
          } elseif {[string match $className faultMode]} {
            lappend fault_modes $modeName
            set model [assoc model pirNode($pirNodeIndex)]
            set model [string trim $model "\{\}"]
            if {$model == ""} {
              set unknownFaultModeExistsP 1
            }
          } else {
            set str "createDefmoduleInputsOutputs: mode nodeClassName $className" 
            puts stderr "$str not handled"
          }
          set transitionList [assoc transitions pirNode($pirNodeIndex) \
                                  $reportNotFoundP]
          foreach transition $transitionList {
            if {[llength $transition] > 4} {
              set startPirNodeIndex [assoc startNode transition]
              set stopPirNodeIndex [assoc stopNode transition]
              lappend mode_transitions \
                  [list [getExternalNodeName [assoc nodeInstanceName \
                                                    pirNode($startPirNodeIndex)]] \
                       [getExternalNodeName [assoc nodeInstanceName \
                                                   pirNode($stopPirNodeIndex)]]]
            }
          }
        }
      }
      if {! $unknownFaultModeExistsP} {
        set str "There is no fault mode with an empty model (\"unknown\" mode)" 
        append str "\n\nThis component definition will not be saved!"
        set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
        eval $dialogList
        return 1
      }
      set mode [getClassVarDefaultValue initial_mode classVars]
      # puts stderr "createDefmoduleInputsOutputs:"
      # puts stderr "   mode $mode ok_modes $ok_modes fault_modes $fault_modes"
      set str "Initial Mode `$mode' does not exist!"
      append str "\nUse `Edit->Header->Initial Conditions'"
      if {[lsearch -exact $ok_modes $mode] == -1} {
        set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
        eval $dialogList
        return 1
      }   
      setClassVarDefaultValue ok_modes $ok_modes classVars 
      setClassVarDefaultValue fault_modes $fault_modes classVars
      setClassVarDefaultValue mode_transitions $mode_transitions classVars
      setClassVarDefaultValue mode $mode classVars
      # update nodeState of component root
      set pirNodeIndex [assoc-array $nodeInstanceName g_NM_componentToNode]
      arepl nodeState $mode pirNode($pirNodeIndex)
    }
    arepl class_variables $classVars pirClass($nodeClassName)
    # update both generic and specific pirClass because createComponentI-SCMfile
    # and createModuleI-SCMfile copies specific into generic
    if {[string match $g_NM_classDefType module]} {
      arepl class_variables $classVars pirClassModule($nodeClassName)
    } elseif {[string match $g_NM_classDefType component]} {
       arepl class_variables $classVars pirClassComponent($nodeClassName)
    }
  }
  return 0
}


## get leaf terminal definitions by following className pointers
## from instantiated node class inputs/outputs
## 07jul98 wmt: new
proc getInheritedTerminals { nodeInstanceName nodeClassName \
                                 nodeClassType nameVarAndArgsVars \
                                 nameVarAndArgsValues instanceLabel } {
  global g_NM_terminalDefsArray 
  global pirClassModule XpirClass
  global g_NM_inputInheritedTerms g_NM_outputInheritedTerms 

  set reportNotFoundP 0; set returnIndexP 1; set oldvalMustExistP 0
  set g_NM_inputInheritedTerms {}; set g_NM_outputInheritedTerms {}
  set terminalClassParentList {} 
  set termCnt 1; set g_NM_inheritLevel [llength $terminalClassParentList]
  # set str "getInheritedTerminals: nodeInstanceName $nodeInstanceName"
  # puts stderr "$str nodeClassName $nodeClassName nodeClassType $nodeClassType"

  # follow class inheritance
  getInheritedTerminalsDoit $nodeClassName $nodeClassType $nameVarAndArgsVars \
      $nameVarAndArgsValues $instanceLabel $terminalClassParentList \
      $nodeInstanceName

  set cnt 1; set prefix in
  set newInputInheritedTerms {}
  foreach term $g_NM_inputInheritedTerms {
    lappend newInputInheritedTerms ${prefix}$cnt $term
    incr cnt
  }
  set g_NM_inputInheritedTerms $newInputInheritedTerms 
 
  set cnt 1; set prefix out
  set newOutputInheritedTerms {}
  foreach term $g_NM_outputInheritedTerms {
    lappend newOutputInheritedTerms ${prefix}$cnt $term
    incr cnt
  }
  set g_NM_outputInheritedTerms $newOutputInheritedTerms
  # puts stderr "\ngetInheritedTerminals: g_NM_inputInheritedTerms $g_NM_inputInheritedTerms"
  # puts stderr "getInheritedTerminals: g_NM_outputInheritedTerms $g_NM_outputInheritedTerms"
}


## get inherited terminals whose interfaceType = public, to pass on
## to mergeClassAndInstanceTerminals
proc getInheritedTerminalsDoit { inherit_className inherit_classType \
                                     nameAndArgsList nameAndArgsValsList \
                                     instanceLabel terminalClassParentList \
                                     nodeInstanceName } {
  global g_NM_terminalDefsArray g_NM_terminalInputDefs
  global g_NM_terminalOutputDefs g_NM_argsValuesMismatchList
  global g_NM_inheritedTerminals
  global g_NM_terminalsFilesExtension g_NM_inheritedClassInstances 
  global g_NM_inputInheritedTerms g_NM_outputInheritedTerms
  global g_NM_instanceInputInheritedTerms g_NM_instanceOutputInheritedTerms 

  set reportNotFoundP 0; set returnIndexP 1; set oldvalMustExistP 0
  set noInOutLabelsP 1
  lappend terminalClassParentList $inherit_className
  
  # puts stderr "getInheritedTerminalsDoit:  inherit_className $inherit_className"
  # set str "\n\ngetInheritedTerminalsDoit:  inherit_className $inherit_className"
  # set str "$str inherit_classType $inherit_classType nameAndArgsList $nameAndArgsList"
  # puts stderr "$str nameAndArgsValsList $nameAndArgsValsList instanceLabel $instanceLabel"
  # puts stderr "    currentLevel [llength $terminalClassParentList]"
  # puts stderr "ENTRY: nameAndArgsList $nameAndArgsList nameAndArgsValsList $nameAndArgsValsList"


  # bug in Tcl versions 8.2 and 8.3 (fixed in 8.4a2), which causes excessive memory use when
  # calling "info exists" on a non-existent array element.
  # [info exists g_NM_terminalDefsArray($inherit_className)]
  if {[lsearch -exact [array names g_NM_terminalDefsArray] $inherit_className] >= 0} {
    set terminalDefs $g_NM_terminalDefsArray($inherit_className)
    set terminalInDefs [assoc inputs terminalDefs]
    set terminalOutDefs [assoc outputs terminalDefs]
    set inheritedClassInstances [assoc inheritedClassInstances terminalDefs]
    set inheritedTerminals [assoc inheritedTerminals terminalDefs]
  } else {
    set termsPathname "[getSchematicDirectory nodeType $inherit_classType]/"
    append termsPathname $inherit_className
    append termsPathname $g_NM_terminalsFilesExtension 

    source $termsPathname
    sourcePostProcess $termsPathname 
    # puts stderr "\ngetInheritedTerminalsDoit: $termsPathname"

    # ensure that multi-dimensional types have multi-dimensional default values
    # puts stderr "getInheritedTerminalsDoit: g_NM_terminalInputDefs $g_NM_terminalInputDefs"
    set newInputs {}
    foreach terminalForm $g_NM_terminalInputDefs {
      checkTerminalFormCmdMonValues terminalForm 
      lappend newInputs $terminalForm
    }
    set g_NM_terminalInputDefs $newInputs
    # puts stderr "getInheritedTerminalsDoit: newInputs $newInputs"
    set newOutputs {}
    foreach terminalForm $g_NM_terminalOutputDefs {
      checkTerminalFormCmdMonValues terminalForm 
      lappend newOutputs $terminalForm
    }
    set g_NM_terminalOutputDefs $newOutputs 
    # puts stderr "getInheritedTerminalsDoit: g_NM_terminalInputDefs $newOutputs"

    set terminalInDefs $g_NM_terminalInputDefs
    set terminalOutDefs $g_NM_terminalOutputDefs
    set inheritedTerminals $g_NM_inheritedTerminals
    if {[string match $inherit_classType module]} {
      set inheritedClassInstances $g_NM_inheritedClassInstances
    } else {
      set inheritedClassInstances {}
    }
    set terminalDefs {}
    lappend terminalDefs inputs $g_NM_terminalInputDefs \
        outputs $g_NM_terminalOutputDefs \
        inheritedClassInstances $inheritedClassInstances \
        inheritedTerminals $inheritedTerminals 
    set g_NM_terminalDefsArray($inherit_className) $terminalDefs
  }

  foreach instanceList $inheritedClassInstances {
    # puts stderr "RECURSE [llength $terminalClassParentList] terminalClassParentList $terminalClassParentList"
    if {[llength $terminalClassParentList] == 1} {
      set g_NM_instanceInputInheritedTerms {}
      set g_NM_instanceOutputInheritedTerms {}
    }

    getInheritedTerminalsDoit [assoc nodeClassName instanceList] \
        [assoc nodeClassType instanceList] \
        [concat [assoc nameArgs instanceList] $nameAndArgsList] \
        [concat [assoc nameArgsValues instanceList] $nameAndArgsValsList] \
        "$instanceLabel.[assoc instanceLabel instanceList]" \
        $terminalClassParentList $nodeInstanceName 
  }

  # puts stderr "FINAL [llength $terminalClassParentList] terminalClassParentList $terminalClassParentList"
  if {[llength $terminalClassParentList] == 1} {
    # bind all children of root module
    set g_NM_instanceInputInheritedTerms $g_NM_inputInheritedTerms
    set g_NM_instanceOutputInheritedTerms $g_NM_outputInheritedTerms 
  }

  # apply bindings
  # puts stderr "getInheritedTerminalsDoit: nameAndArgsList $nameAndArgsList nameAndArgsValsList $nameAndArgsValsList "
  if {[llength $nameAndArgsList] != [llength $nameAndArgsValsList]} {
    set returnValue [assoc $inherit_className g_NM_argsValuesMismatchList \
                         $reportNotFoundP $returnIndexP]
    if {$returnValue >= 0} {
      set form [assoc $inherit_className g_NM_argsValuesMismatchList]
      set nameAndArgsValsList [list range $nameAndArgsValsList 0 0]
      set nameAndArgsValsList [concat $nameAndArgsValsList \
                                   [assoc argsValues form]]
    } else {
      # abort this schematic, since args/values mismatch is at a recursion
      # greater than 0 -- changes made here will not be saved, since they
      # are in a lower level schematic
      ## same logic is in instantiateDefmoduleFromIscm
      set str1 "    args $nameAndArgsList values $nameAndArgsValsList "
      set str2 "   MISMATCH args/values: className $inherit_className"
      set str ""; append str $str2 "\n" $str1
      append str "\n    Edit `Edit->Header->Name, Variables, & Documentation'"
      set len [llength $terminalClassParentList]
      append str "\n    for module [lindex $terminalClassParentList [expr {$len - 2}]]"
      puts stderr "getInheritedTerminalsDoit: $str"
      # puts stderr "terminalClassParentList $terminalClassParentList"
      set dialogList [list tk_dialog .d "WARNING" $str warning 0 {DISMISS}]
      eval $dialogList
      return
    }
  }
  # set str "     \n\nnameAndArgsList $nameAndArgsList nameAndArgsValsList"
  # puts stderr "$str $nameAndArgsValsList"
  # puts stderr "     B terminalInDefs $terminalInDefs"
  # puts stderr "     B terminalOutDefs $terminalOutDefs"
  # puts stderr "         B g_NM_instanceInputInheritedTerms $g_NM_instanceInputInheritedTerms"
  # puts stderr "         B g_NM_instanceOutputInheritedTerms $g_NM_instanceOutputInheritedTerms"
  # puts stderr "         B inheritedTerminals $inheritedTerminals"
  
  # substitute these into inherit_classArgsValues 
  set regsubArgListDot {}; set regsubArgListSpace {}
  set argValueListDot {}; set argValueListSpace {}
  buildRegsubVarValueLists nameAndArgsList nameAndArgsValsList \
      regsubArgListDot regsubArgListSpace \
      argValueListDot argValueListSpace 
  # substitute argsValues for args in inherit forms
  applyRegsub terminalInDefs \
      regsubArgListDot regsubArgListSpace \
      argValueListDot argValueListSpace 

  applyRegsub terminalOutDefs \
      regsubArgListDot regsubArgListSpace \
      argValueListDot argValueListSpace 

  applyRegsub inheritedTerminals \
      regsubArgListDot regsubArgListSpace \
      argValueListDot argValueListSpace 

  # puts stderr "     A terminalInDefs $terminalInDefs" 
  # puts stderr "\n\n     A terminalOutDefs $terminalOutDefs" 
  # puts stderr "         A inheritedTerminals $inheritedTerminals"
  # puts stderr "         A g_NM_instanceInputInheritedTerms $g_NM_instanceInputInheritedTerms"
  # puts stderr "         A g_NM_instanceOutputInheritedTerms $g_NM_instanceOutputInheritedTerms"

  # add input leaf terminals from this class
  set g_NM_instanceInputInheritedTerms  [concat $g_NM_instanceInputInheritedTerms \
                                             $terminalInDefs]
  # pass on or inherited any terminals which are typed by this class as
  # public, or not private (which means it is newly defined by
  # the lower level class)
  set newInputInheritedTerms {}
  set publicPrivateInputTerminals [assoc inputs inheritedTerminals]
  set publicInputTerminalNames [assoc public publicPrivateInputTerminals]
  set privateInputTerminalNames [assoc private publicPrivateInputTerminals]
  set publicPrivateOutputTerminals [assoc outputs inheritedTerminals]
  set publicOutputTerminalNames [assoc public publicPrivateOutputTerminals]
  set privateOutputTerminalNames [assoc private publicPrivateOutputTerminals]
  # puts stderr "  publicInputTerminalNames $publicInputTerminalNames"
  # puts stderr "  privateInputTerminalNames $privateInputTerminalNames"
  # puts stderr "  publicOutputTerminalNames $publicOutputTerminalNames"
  # puts stderr "  privateOutputTerminalNames $privateOutputTerminalNames"
  foreach terminalDef $g_NM_instanceInputInheritedTerms {
    set terminalName [assoc terminal_name terminalDef]
    # puts stderr "   terminalName $terminalName"
    if {([lsearch -exact $publicInputTerminalNames $terminalName] >= 0) || \
            ([lsearch -exact $publicOutputTerminalNames $terminalName] >= 0) || \
            (([lsearch -exact $privateInputTerminalNames $terminalName] == -1) && \
                 ([lsearch -exact $privateOutputTerminalNames $terminalName] == -1))} {
        lappend newInputInheritedTerms $terminalDef 
    }
  }
  set g_NM_instanceInputInheritedTerms $newInputInheritedTerms

  # add output leaf terminals from this class
  set g_NM_instanceOutputInheritedTerms [concat $g_NM_instanceOutputInheritedTerms \
                                             $terminalOutDefs]
  set newOutputInheritedTerms {}
  foreach terminalDef $g_NM_instanceOutputInheritedTerms {
    set terminalName [assoc terminal_name terminalDef]
    if {([lsearch -exact $publicOutputTerminalNames $terminalName] >= 0) || \
            ([lsearch -exact $publicInputTerminalNames $terminalName] >= 0) || \
            (([lsearch -exact $privateOutputTerminalNames $terminalName] == -1) && \
                 ([lsearch -exact $privateInputTerminalNames $terminalName] == -1))} {
      # puts stderr "    terminalDef $terminalDef "
      lappend newOutputInheritedTerms $terminalDef 
    }
  }
  set g_NM_instanceOutputInheritedTerms $newOutputInheritedTerms

  # puts stderr "EXIT [llength $terminalClassParentList] terminalClassParentList $terminalClassParentList"
  # puts stderr "  len g_NM_inputInheritedTerms [llength $g_NM_inputInheritedTerms]"
  # puts stderr "  len g_NM_instanceInputInheritedTerms [llength $g_NM_instanceInputInheritedTerms]" 
#   puts stderr "   g_NM_instanceInputInheritedTerms"; set inlist {}
#   foreach sublist $g_NM_instanceInputInheritedTerms {
#     lappend inlist [assoc terminal_name sublist]
#   }
#    puts stderr "   $inlist"
  # puts stderr "   g_NM_instanceOutputInheritedTerms $g_NM_instanceOutputInheritedTerms"

  if {[llength $terminalClassParentList] == 2} {
    # add substituted children to list
    set g_NM_inputInheritedTerms [concat $g_NM_inputInheritedTerms \
                                      $g_NM_instanceInputInheritedTerms]
    set g_NM_outputInheritedTerms [concat $g_NM_outputInheritedTerms \
                                      $g_NM_instanceOutputInheritedTerms]
  }
  if {[llength $terminalClassParentList] == 1} {
    # final list after substituting for root instance
    set g_NM_inputInheritedTerms $g_NM_instanceInputInheritedTerms
    set g_NM_outputInheritedTerms $g_NM_instanceOutputInheritedTerms
  }

  # puts stderr "   final inputs $g_NM_instanceInputInheritedTerms"
  # puts stderr "   outputs $g_NM_instanceOutputInheritedTerms"
  # puts stderr "   terminalClassParentList $terminalClassParentList"
}


## merge the instance terminal defs with the maybe different
## class instance terminal 
## (filtered by getInheritedTerminals)
## requirements:
##   name is unique identifier
##   match name 
##   use type, label and cmd/monitor type from inherited form
##   preserve local terminal direction
##   preserve local terminal order
##   preserve local terminal interface type
## 30apr98 wmt: new
## 08may98 wmt: now check for class inputs and outputs for occurrance of
##              of instance terminal, since terminal reordering may have
##              switched inputs and outputs in the instance
proc mergeClassAndInstanceTerminals { class_terminals other_class_terminals \
                                          instance_terminals \
                                          other_instance_terminals \
                                          nodeInstanceName terminalType } {

  set numTerms 1; set terminals {}; set addP 1
  # keep instance_terminals that are in class_terminals 
  mergeClassAndInstanceTerminalsDoit instance_terminals \
      class_terminals other_class_terminals \
      $terminalType numTerms terminals $addP
#   if {[string match $nodeInstanceName "(PALETTE-A~?name)"]} {
      # puts stderr "\nmergeClassAndInstanceTerminals 1 terminals $terminals"
#   }
#   puts stderr "\nmergeClassAndInstanceTerminals:  1 numTerms $numTerms len [llength $terminals]"
#   puts stderr "   instance_terminals $instance_terminals "
#   puts stderr "   class_terminals $class_terminals"
#   puts stderr "   terminals $terminals "
#   error "mergeClassAndInstanceTerminals"


  # remove from class_terminals any terminals which are now
  # in other_instance_terminals 
  set addP 0
  mergeClassAndInstanceTerminalsDoit other_instance_terminals \
      class_terminals other_class_terminals \
      $terminalType numTerms terminals $addP 
  
  # puts stderr "mergeClassAndInstanceTerminals:  2 numTerms $numTerms len [llength $terminals]"
#   if {[string match $nodeInstanceName "(PALETTE-A~?name)"]} {
      # puts stderr "\nmergeClassAndInstanceTerminals 2 terminals $terminals"
#   }
  # new terminals from class
  for {set i 1} {$i < [llength $class_terminals]} {incr i 2} {
    lappend terminals ${terminalType}$numTerms [lindex $class_terminals $i] 
    incr numTerms
  }
  # puts stderr "mergeClassAndInstanceTerminals:  3 numTerms $numTerms len [llength $terminals]"
#   if {[string match $nodeInstanceName "(PALETTE-A~?name)"]} {
      # puts stderr "\nmergeClassAndInstanceTerminals 3 class_terminals $class_terminals"
      # puts stderr "\nmergeClassAndInstanceTerminals 3 instance_terminals $instance_terminals "
      # puts stderr "\nmergeClassAndInstanceTerminals 3 terminals $terminals"
#   }
  return $terminals 
}


## 30jul99 wmt: compare terminal names only, not terminal name & direction/type
##              preserve instance direction -- pass on class type along 
##              with class label and cmd/mon type
proc mergeClassAndInstanceTerminalsDoit { instance_terminalsRef class_terminalsRef \
                                              other_class_terminalsRef \
                                              terminalType numTermsRef terminalsRef \
                                              addP } {
  upvar $instance_terminalsRef instance_terminals
  upvar $class_terminalsRef class_terminals
  upvar $other_class_terminalsRef other_class_terminals
  upvar $numTermsRef numTerms
  upvar $terminalsRef terminals

  set reportNotFoundP 0; set oldvalMustExistP 0; set returnIndexP 1
  for {set i 1} {$i < [llength $instance_terminals]} {incr i 2} {
    set instanceTerminal [lindex $instance_terminals $i]
    set instanceTerminalLabelIndex \
        [assoc terminal_label instanceTerminal $reportNotFoundP $returnIndexP]
    set instanceTerminalName [assoc terminal_name instanceTerminal]
    set instanceTerminalDir [getTerminalDirection $instanceTerminal]
#     puts stderr "mergeClassAndInstanceTerminals: instanceTerminalDir $instanceTerminalDir"
    set foundP 0
    # puts stderr "mergeClassAndInstanceTerminals: instanceTerminalShort $instanceTerminalShort"
    for {set j 1} {$j < [llength $class_terminals]} {incr j 2} {
      set classTerminal [lindex $class_terminals $j]
      set classTerminalLabel [assoc terminal_label classTerminal $reportNotFoundP]
      set classTerminalName [assoc terminal_name classTerminal]
      set classTerminalType [getTerminalType $classTerminal]
      set classCmdMonType [assoc commandMonitorType classTerminal $reportNotFoundP]
      if {[string match $classCmdMonType ""]} {
        set classCmdMonType [list <unspecified> <unspecified>]
      }
#       puts stderr "mergeClassAndInstanceTerminals: classTerminal $classTerminal classTerminalType $classTerminalType"
      # compare without labels => compare name
      if {[string match $classTerminalName $instanceTerminalName]} {
        if {$addP} {
          # pass on the class terminal_label to the instance
          if {$instanceTerminalLabelIndex != -1} {
            arepl terminal_label $classTerminalLabel instanceTerminal \
                $reportNotFoundP $oldvalMustExistP
          } else {
            # put terminal_label last in the terminal form
            lappend instanceTerminal terminal_label $classTerminalLabel
          }
          # pass on terminal type, but preserve terminal direction
          set typeForm [list $classTerminalType $instanceTerminalDir]
          arepl type $typeForm instanceTerminal
          # pass on cmd/mon type
          arepl commandMonitorType $classCmdMonType instanceTerminal \
              $reportNotFoundP $oldvalMustExistP
          lappend terminals ${terminalType}$numTerms $instanceTerminal
          incr numTerms
        }
        set class_terminals [lreplace $class_terminals [expr {$j - 1}] $j]
        set foundP 1
        break
      }
    }
    if {(! $foundP) && $addP} {
      for {set j 1} {$j < [llength $other_class_terminals]} {incr j 2} {
        set classTerminal [lindex $other_class_terminals $j]
        set classTerminalLabel [assoc terminal_label classTerminal $reportNotFoundP]
        set classTerminalName [assoc terminal_name classTerminal]
        set classTerminalType [getTerminalType $classTerminal]
        set classCmdMonType [assoc commandMonitorType classTerminal $reportNotFoundP]
        if {[string match $classCmdMonType ""]} {
          set classCmdMonType [list <unspecified> <unspecified>]
        }
        # set str "mergeClassAndInstanceTerminals: `$classTerminalShort'"
        # puts stderr "$str `$instanceTerminalShort'"
        # compare without labels => compare name
        if {[string match $classTerminalName $instanceTerminalName]} {
          # pass on the class terminal_label to the instance
          if {$instanceTerminalLabelIndex != -1} {
            arepl terminal_label $classTerminalLabel instanceTerminal \
                $reportNotFoundP $oldvalMustExistP
          } else {
            # put terminal_label last in the terminal form
            lappend instanceTerminal terminal_label $classTerminalLabel
          }
          # pass on terminal type, but preserve terminal direction
          set typeForm [list $classTerminalType $instanceTerminalDir]
          arepl type $typeForm instanceTerminal 
          # pass on cmd/mon type
          arepl commandMonitorType $classCmdMonType instanceTerminal \
              $reportNotFoundP $oldvalMustExistP
          lappend terminals ${terminalType}$numTerms $instanceTerminal
          incr numTerms
          break
        }
      }
    }
  }
}



















