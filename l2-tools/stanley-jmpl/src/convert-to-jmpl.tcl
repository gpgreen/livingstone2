# $Id: convert-to-jmpl.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors for JMPL

global jmplDebugP 
set jmplDebugP 0

# (load "~taylor/mba/livingstone/interfaces/xml/fix-syntax.lisp")
# TP(7): *system*
# <System: (ISPP ISPP-X)>
# TP(8): (system-component-ht *system*)
# #<EQUAL hash-table with 6 entries @ #x85e4dc2>
# TP(9): (system-module-ht *system*)
# #<EQUAL hash-table with 1 entry @ #x85e4a4a>
# TP(10): (maphash #'(lambda (key val)
#                      (format t "~%~A" key))
#                  (system-module-ht *system*))

# TP(10): (maphash #'(lambda (key val)
#                      (format t "~%~A" key))
#                  (system-component-ht *system*))

# (fix-identifier-syntax '(N-C-SOLENOID-VALVE (NC-02 ISPP-X)))
# => "isppX.nc02.nCSolenoidValve"

# (fix-proposition-syntax t '(open (mass-flow-cmd ispp-x)))
# => "isppX.massFlowCmd=open"

## convert Lisp syntax identifiers to XML syntax
## 06dec99 wmt: translated from Jim Kurien's Lisp version
proc stringHyphenToCaps { string } {

  if {[regexp "_" $string]} {
    error "stringHyphenToCaps: $string contains delimiter _"
  }
  regsub -all -- "-" $string "_" delimitedString
  append delimitedString "_"
  set token ""
  set indx [string first "_" $delimitedString]
  set token [string tolower [string range $delimitedString 0 \
                                 [expr {$indx - 1}]]]
  set delimitedString [string range $delimitedString [expr {$indx + 1}] end]
  while { 1 } {
    set indx [string first "_" $delimitedString]
    if {$indx == -1} {
      break
    }
    append token [capitalizeWord \
                      [string tolower [string range $delimitedString 0 \
                                           [expr {$indx - 1}]]]]
    set delimitedString [string range $delimitedString [expr {$indx + 1}] end]
  }
  return $token 
}


## 06dec99 wmt: translated from Jim Kurien's Lisp version
proc dottedNameAux { nameList } {
  global jmplDebugP

  # Currently the MPL compiler uses list-based names.
  # (slot (slot (slot object)))
  #
  # Rather than fixing this now, we have a few functions
  # which help to translate the final output of the compile
  # into the java-style . naming scheme
  #
  # Eventually this function should be eliminated. 

  # puts stderr "dottedNameAux: nameList `$nameList'"
  # convert to tcl lists from Lisp lists
  lispListToTcl nameList
  # make sure there are no ~'s
  regsub -all "~" $nameList " " tmp; set nameList $tmp
  if {$jmplDebugP} {
    puts stderr "dottedNameAux: entry nameList $nameList len [llength $nameList]"
  }
  if {[llength $nameList] == 1} {
    return [stringHyphenToCaps $nameList]
  } elseif {[llength $nameList] == 2} {
    set str "[dottedNameAux [list [lindex $nameList 1]]]"
    append str ".[stringHyphenToCaps [lindex $nameList 0]]"
    # puts stderr "dottedNameAux: 2 nameList $nameList token $str"
    return $str

   # The translation is really on straightforward if the toplevel list form
   # is of length 2  (eg (slot object) or (slot (slot object)) etc)
   #
   # So from here on out it's pure hackery.
  } elseif {([llength $nameList] == 3) && \
                ([llength [lindex $nameList 0]] == 1) && \
                ([llength [lindex $nameList 2]] == 1)} {
    set str "[dottedNameAux [list [lindex $nameList 1]]]"
    append str ".[stringHyphenToCaps [lindex $nameList 0]]"
    append str ".[stringHyphenToCaps [lindex $nameList 2]]"
    # puts stderr "dottedNameAux: 3 nameList $nameList token $str"
    return $str
  } else {
    error "dottedNameAux: object name $nameList is too long or is null"
  }
}
   

## 06dec99 wmt: translated from Jim Kurien's Lisp version
## fixIdentifierSyntax (N-C-SOLENOID-VALVE~(NC-02~ISPP-X))
proc fixIdentifierSyntax { item } {

  dottedNameAux $item
}


## convert class names from java to lisp syntax
## e.g. pressureRegulator to pressure-regulator
## 10dec99 wmt: new
proc convertClassNameJavaToLisp { token } {

  # look for capital letter and replace with -<lower-case-letter>
  set newToken ""
  for {set i 0} {$i < [string length $token]} {incr i} {
    if {[string is upper [string index $token $i]]} {
      append newToken "-[string tolower [string index $token $i]]"
    } else {
      append newToken [string index $token $i] 
    }
  }
  # needed if first character is a digit
  set newToken [string trimleft $newToken "-"]
  # special handling for gn2
  regsub "gn-2" $newToken "gn2" tmp; set newToken $tmp
  # special handling for nC2WaySolenoidValve
  regsub "n-c2" $newToken "n-c-2" tmp; set newToken $tmp
  # special handling for nO2WaySolenoidValve
  regsub "n-o2" $newToken "n-o-2" tmp; set newToken $tmp  
  # special handling for 2In3WaySolenoidValve
  regsub "2-in3" $newToken "2-in-3" tmp; set newToken $tmp  
  # special handling for rp1
  regsub "rp1" $newToken "rp-1" tmp; set newToken $tmp  
  return $newToken 
}


## convert pirNodes pirEdges pirClasses g_NM_includedModules
## to jMpl syntax
## 08dec99 wmt: new
proc convertToJMplSyntax { classDefType } {
  global pirNodes pirEdges pirClasses g_NM_includedModules
  global pirNode pirEdge g_NM_rootInstanceName 
  global g_NM_livingstoneDefcomponentFileName g_NM_livingstoneDefcomponentName
  global g_NM_livingstoneDefcomponentNameVar g_NM_inheritedTerminals
  global g_NM_livingstoneDefmoduleFileName g_NM_livingstoneDefmoduleName
  global g_NM_livingstoneDefmoduleNameVar g_NM_canvasList
  global convertTerminalFormType 

  set reportNotFoundP 0; set oldvalMustExistP 0
  set enterListP 0; set prefix ""
  set pirNodeFilteredElems {}; set pirEdgeFilteredElems {}
  set pirClassFilteredElems {}
  getTopLevelElements pirNodeFilteredElems pirEdgeFilteredElems \
      pirClassFilteredElems $prefix

  # pirNodes
  # convert argsValues attributes input_terminals output_terminals
  #         nodeInstanceName instanceLabel nodeClassName nodeGroupName
  #         parentNodeGroupList displayStatePropName inputs outputs transitions
  foreach pirNodeIndex $pirNodeFilteredElems {
    set nodeState [assoc nodeState pirNode($pirNodeIndex)]
    puts stderr "convertToJMplSyntax: pirNodeIndex $pirNodeIndex"
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    if {$nodeState != "parent-link"} {
      set numArgsVars [assoc numArgsVars pirNode($pirNodeIndex)]
      if {$numArgsVars > 0} {
        set newArgsValues {}
        foreach argVal [assoc argsValues pirNode($pirNodeIndex)] {
          lappend newArgsValues [fixIdentifierSyntax $argVal]
        }
        arepl argsValues $newArgsValues pirNode($pirNodeIndex)
      }
    }

    if {($nodeClassType == "component") || \
            (($nodeClassType == "module") && ($nodeState != "parent-link"))} {
      set newAttributes {}
      foreach att [assoc attributes pirNode($pirNodeIndex)] {
        lappend newAttributes [fixIdentifierSyntax $att]
      }
      arepl attributes $newAttributes pirNode($pirNodeIndex)
      
      set newInput_terminals {}
      foreach input [assoc input_terminals pirNode($pirNodeIndex)] {
        lappend newInput_terminals [fixIdentifierSyntax $input]
      }
      arepl input_terminals $newInput_terminals pirNode($pirNodeIndex)
      
      set newOutput_terminals {}
      foreach output [assoc output_terminals pirNode($pirNodeIndex)] {
        lappend newOutput_terminals [fixIdentifierSyntax $output]
      }
      arepl output_terminals $newOutput_terminals pirNode($pirNodeIndex)
    }

    if {$nodeState != "parent-link"} {
      set nodeInstanceName [fixIdentifierSyntax \
                                [assoc nodeInstanceName pirNode($pirNodeIndex)]]
      maybeAddQName nodeInstanceName 
      arepl nodeInstanceName $nodeInstanceName pirNode($pirNodeIndex)

      set instanceLabel [assoc instanceLabel pirNode($pirNodeIndex)]
      if {$instanceLabel != ""} {
        arepl instanceLabel [fixIdentifierSyntax $instanceLabel] \
            pirNode($pirNodeIndex)
      }
    }

    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    arepl nodeClassName [fixIdentifierSyntax $nodeClassName] \
        pirNode($pirNodeIndex)

    if {($nodeClassType == "attribute") && \
            ([set facts [assoc facts pirNode($pirNodeIndex)]] != "")} {
      set convertedFacts [convertSexpToJmpl [string trim $facts "\{\}"]]
      if {$convertedFacts != ""} {
        append facts "\n$convertedFacts"
        arepl facts $facts  pirNode($pirNodeIndex)
      }
    }

    set nodeGroupName [fixIdentifierSyntax \
                           [assoc nodeGroupName pirNode($pirNodeIndex)]]
    maybeAddQName nodeGroupName 
    arepl nodeGroupName $nodeGroupName pirNode($pirNodeIndex)
    
    set newParentNodeGroupList {}
    foreach token [assoc parentNodeGroupList pirNode($pirNodeIndex)] {
      set token [fixIdentifierSyntax $token]
      maybeAddQName token 
      lappend newParentNodeGroupList $token
    }
    arepl parentNodeGroupList $newParentNodeGroupList pirNode($pirNodeIndex)

    if {($nodeClassType == "component") || \
            (($nodeClassType == "module") && ($nodeState != "parent-link"))} {
      set displayStatePropName [assoc displayStatePropName pirNode($pirNodeIndex)]
      arepl displayStatePropName [fixIdentifierSyntax $displayStatePropName] \
          pirNode($pirNodeIndex)
    }

    if {$nodeClassType != "mode"} {
      set newInputs {}
      set inputs [assoc inputs pirNode($pirNodeIndex)]
      convertInOutputs $nodeClassType $inputs newInputs 
      arepl inputs $newInputs pirNode($pirNodeIndex)
      set newOutputs {}
      set outputs [assoc outputs pirNode($pirNodeIndex)]
      convertInOutputs $nodeClassType $outputs newOutputs 
      arepl outputs $newOutputs pirNode($pirNodeIndex)
    } else {
      # mode transitions - convert next and when
      # mode model 
      set transitions [assoc transitions pirNode($pirNodeIndex) $reportNotFoundP]
      if {$transitions != ""} {
        set newTransitions {}
        foreach trans $transitions {
          set defs [assoc defs trans $reportNotFoundP]
          for {set i 0} {$i < [llength $defs]} {incr i 2} {
            set defKey [lindex $defs $i]
            set defForm [lindex $defs [expr {$i + 1}]]
            set next [assoc next defForm]
            arepl next [fixIdentifierSyntax $next] defForm
            set when [assoc when defForm] 
            if {$when != ""} {
              set convertedWhen [convertSexpToJmpl [string trim $when "\{\}"]]
              if {$convertedWhen != ""} {
                append when "\n$convertedWhen"
                arepl when $when defForm
              }
            }
            adel $defKey defs 
            arepl [fixIdentifierSyntax $defKey] $defForm defs \
                $reportNotFoundP $oldvalMustExistP 
          }
          if {$defs != ""} {
            arepl defs $defs trans
          }
          lappend newTransitions $trans
        }
        arepl transitions $newTransitions pirNode($pirNodeIndex)
      }

      set model [assoc model pirNode($pirNodeIndex) $reportNotFoundP]
      if {$model != ""} {
        set convertedModel [convertSexpToJmpl [string trim $model "\{\}"]]
        if {$convertedModel != ""} {
          append model "\n$convertedModel"
          arepl model $model pirNode($pirNodeIndex)
        }
      }
    }
  }
  # pirClasses
  # convert native classes: mode_class|terminal_class|attribute_class & cfg_file
  # convert user classes: name_var input_terminals output_terminals port_terminals
  #         attributes mode ok_modes fault_modes mode_transitions
  #         initial_mode recovery_modes
  set nativeClasses {INPUT OUTPUT ATTRIBUTE DISPLAY-STATE OK-MODE FAULT-MODE}
  set classAttributes {terminal_class terminal_class attribute_class attribute_class \
                           mode_class mode_class}
  foreach className $pirClassFilteredElems {
    set jmplClassName [fixIdentifierSyntax $className]
    set classForm [getClass $classDefType $className]
    lremoveClasses $classDefType $className
    unsetClass $classDefType $className 
    if {[set nativeIndex [lsearch -exact $nativeClasses $className]] >= 0} {
      # change mode_class|terminal_class|attribute_class & cfg_file
      set classAtt [assoc [lindex $classAttributes $nativeIndex] classForm]
      arepl [lindex $classAttributes $nativeIndex] [fixIdentifierSyntax $classAtt] \
          classForm
      set classFile [assoc cfg_file classForm]
      arepl cfg_file [fixIdentifierSyntax $classFile] classForm
      puts stderr "convertToJMplSyntax: native className $className => $jmplClassName"
    } else {
      # change name_var input_terminals output_terminals port_terminals
      #        attributes mode ok_modes fault_modes mode_transitions
      #        mode initial_mode recovery_modes
      set classVars [assoc class_variables classForm]
      set name_var [getClassVarDefaultValue name_var classVars]
      setClassVarDefaultValue name_var [fixIdentifierSyntax $name_var] classVars
      set args [getClassVarDefaultValue args classVars]
      if {$args != ""} {
        setClassVarDefaultValue args [fixIdentifierSyntax $args] classVars
      }
      set input_terminals [getClassVarDefaultValue input_terminals classVars]
      if {$input_terminals != ""} {
        set input_terminals [string trimleft $input_terminals " \{"]
        set input_terminals [string trimright $input_terminals " \}"] 
        set len [string length $input_terminals]
        if {[string range $input_terminals 0 4] == "(and "} {
          set input_terminals [string range $input_terminals 5 [expr {$len - 2}]]
        }
        lispListToTcl input_terminals $enterListP
        set newInTerms {}
        foreach termTriple $input_terminals {
          set newTermTriple {}
          foreach token $termTriple {
            if {[llength $token] > 1} {
              set token "\($token\)"
            }
            lappend newTermTriple [fixIdentifierSyntax $token]
            # puts stderr "token `$token' newTermTriple `$newTermTriple'"
          }
          lappend newInTerms $newTermTriple
        }
        setClassVarDefaultValue input_terminals $newInTerms classVars
      }

      set output_terminals [getClassVarDefaultValue output_terminals classVars]
      if {$output_terminals != ""} {
        set output_terminals [string trimleft $output_terminals " \{"]
        set output_terminals [string trimright $output_terminals " \}"]
        set len [string length $output_terminals]
        if {[string range $output_terminals 0 4] == "(and "} {
          set output_terminals [string range $output_terminals 5 [expr {$len - 2}]]
        }
        lispListToTcl output_terminals $enterListP
        set newOutTerms {}
        foreach termTriple $output_terminals {
          set newTermTriple {}
          foreach token $termTriple {
            if {[llength $token] > 1} {
              set token "\($token\)"
            }
            lappend newTermTriple [fixIdentifierSyntax $token]
            # puts stderr "token `$token' newTermTriple `$newTermTriple'"
          }
          lappend newOutTerms $newTermTriple
        }
        setClassVarDefaultValue output_terminals $newOutTerms classVars
      }

      set attributes [getClassVarDefaultValue attributes classVars]
      if {$attributes != ""} {
        set attributes [string trimleft $attributes " \{"]
        set attributes [string trimright $attributes " \}"]
        set len [string length $attributes]
        if {[string range $attributes 0 4] == "(and "} {
          set attributes [string range $attributes 5 [expr {$len - 2}]]
        }
        lispListToTcl attributes $enterListP
        set newOutTerms {}
        foreach termTriple $attributes {
          set newTermTriple {}
          foreach token $termTriple {
            if {[llength $token] > 1} {
              set token "\($token\)"
            }
            lappend newTermTriple [fixIdentifierSyntax $token]
            # puts stderr "token `$token' newTermTriple `$newTermTriple'"
          }
          lappend newOutTerms $newTermTriple
        }
        setClassVarDefaultValue attributes $newOutTerms classVars
      }

      if {$classDefType == "component"} {
        set mode [getClassVarDefaultValue mode classVars]
        if {$mode != ""} {
          setClassVarDefaultValue mode [fixIdentifierSyntax $mode] classVars
        }
        set ok_modes [getClassVarDefaultValue ok_modes classVars]
        if {$ok_modes != ""} {
          set newOkModes {}
          foreach mode $ok_modes {
            lappend newOkModes [fixIdentifierSyntax $mode]
          }
          setClassVarDefaultValue ok_modes $newOkModes classVars
        }
        set fault_modes [getClassVarDefaultValue fault_modes classVars]
        if {$fault_modes != ""} {
          set newFaultModes {}
          foreach mode $fault_modes {
            lappend newFaultModes [fixIdentifierSyntax $mode]
          }
          setClassVarDefaultValue fault_modes $newFaultModes classVars
        }
        set mode_transitions [getClassVarDefaultValue mode_transitions classVars]
        if {$mode_transitions != ""} {
          set newModeTrans {}
          foreach transPair $mode_transitions {
            set newPair [list [fixIdentifierSyntax [lindex $transPair 0]] \
                             [fixIdentifierSyntax [lindex $transPair 1]]]
            lappend newModeTrans $newPair 
          }
          setClassVarDefaultValue mode_transitions $newModeTrans classVars
        }
        set initial_mode [getClassVarDefaultValue initial_mode classVars]
        if {$initial_mode != ""} {
          setClassVarDefaultValue initial_mode [fixIdentifierSyntax $initial_mode] classVars
        }
        set recovery_modes [getClassVarDefaultValue recovery_modes classVars]
        if {$recovery_modes != ""} {
          set newRecoveryModes {}
          foreach mode $$recovery_modes {
            lappend newRecoveryModes [fixIdentifierSyntax $mode]
          }
          setClassVarDefaultValue recovery_modes $newRecoveryModes classVars
        }
        set bgModel [getClassVarDefaultValue background_model classVars] 
        if {$bgModel != ""} {
          set convertedBgModel [convertSexpToJmpl [string trim $bgModel "\{\}"]]
          if {$convertedBgModel != ""} {
            append bgModel "\n$convertedBgModel"
            arepl background_model $bgModel pirNode($pirNodeIndex)
          }
        }
        set initModel [getClassVarDefaultValue initially classVars] 
        if {$initModel != ""} {
          set convertedInitModel [convertSexpToJmpl [string trim $initModel "\{\}"]]
          if {$convertedInitModel != ""} {
            append initModel "\n$convertedInitModel"
            arepl initially $initModel pirNode($pirNodeIndex)
          }
        }
      }
      if {$classDefType == "module"} {
        set facts [getClassVarDefaultValue facts classVars] 
        if {$facts != ""} {
          set convertedFacts [convertSexpToJmpl [string trim $facts "\{\}"]]
          if {$convertedFacts != ""} {
            append facts "\n$convertedFacts"
            arepl facts $facts pirNode($pirNodeIndex)
          }
        }
      }
      arepl class_variables $classVars classForm
      puts stderr "convertToJMplSyntax: className $className"

    }
    lappendClasses $classDefType $jmplClassName 
    setClass $classDefType $jmplClassName classForm
  }

  # pirEdges
  # convert terminalTo terminalFrom abstractionType
  foreach pirEdgeIndex $pirEdgeFilteredElems {
    set terminalForm [assoc terminalTo pirEdge($pirEdgeIndex)]
    if {[llength $terminalForm] == 1} {
      set terminalForm [lindex $terminalForm 0]
    }
    convertTerminalForm terminal terminalForm 
    set terminalFormTypeTo $convertTerminalFormType
    arepl terminalTo $terminalForm pirEdge($pirEdgeIndex)

    set terminalForm [assoc terminalFrom pirEdge($pirEdgeIndex)]
    if {[llength $terminalForm] == 1} {
      set terminalForm [lindex $terminalForm 0]
    }
    convertTerminalForm terminal terminalForm 
    set terminalFormTypeFrom $convertTerminalFormType
    arepl terminalFrom $terminalForm pirEdge($pirEdgeIndex)
    # puts stderr "\npirEdge $pirEdge($pirEdgeIndex)"
    set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
    if {($abstractionType == "") && \
            [string match $terminalFormTypeTo $terminalFormTypeFrom]} {
      set abstractionType $terminalFormTypeTo
    }
    arepl abstractionType [fixIdentifierSyntax $abstractionType] pirEdge($pirEdgeIndex)
  }

  # g_NM_includedModules alist
  # convert key: (instanceName)
  # convert form: nodeClassName argsValues instanceLabel inputs outputs
  set newIncForms {}
  for {set indx 0} {$indx < [llength $g_NM_includedModules]} {incr indx 2} {
    set key [fixIdentifierSyntax [lindex $g_NM_includedModules $indx]]
    maybeAddQName key 
    lappend newIncForms $key
    set incForm [lindex $g_NM_includedModules [expr {$indx + 1}]] 
    set nodeClassName [assoc nodeClassName incForm]
    set classType [assoc nodeClassType incForm]
    arepl nodeClassName [fixIdentifierSyntax $nodeClassName] incForm
    set argsValues [assoc argsValues incForm]
    if {$argsValues != ""} {
      set newArgsValues {}
      foreach val $argsValues {
        lappend newArgsValues [fixIdentifierSyntax $val]
      }
      arepl argsValues $newArgsValues incForm
    }
    set instanceLabel [assoc instanceLabel incForm]
    if {$instanceLabel != ""} {
      arepl instanceLabel [fixIdentifierSyntax $instanceLabel] incForm 
    }
    set newInputs {}
    set inputs [assoc inputs incForm]
    convertInOutputs $classType $inputs newInputs $key
    arepl inputs $newInputs incForm 
    set newOutputs {}
    set outputs [assoc outputs incForm]
    convertInOutputs $classType $outputs newOutputs $key
    arepl outputs $newOutputs incForm 
    lappend newIncForms $incForm 
  }
  set g_NM_includedModules $newIncForms 

  # g_NM_inheritedTerminals
  set inputs [assoc inputs g_NM_inheritedTerminals]
  set publicInputs [assoc public inputs]
  set newPublicInputs {}
  foreach term $publicInputs {
    lappend newPublicInputs [fixIdentifierSyntax $term]
  }
  arepl public $newPublicInputs inputs
  set privateInputs [assoc private inputs]
  set newPrivateInputs {}
  foreach term $privateInputs {
    lappend newPrivateInputs [fixIdentifierSyntax $term]
  }
  arepl private $newPrivateInputs inputs

  set outputs [assoc outputs g_NM_inheritedTerminals]
  set publicOutputs [assoc public outputs]
  set newPublicOutputs {}
  foreach term $publicOutputs {
    lappend newPublicOutputs [fixIdentifierSyntax $term]
  }
  arepl public $newPublicOutputs outputs
  set privateOutputs [assoc private outputs]
  set newPrivateOutputs {}
  foreach term $privateOutputs {
    lappend newPrivateOutputs [fixIdentifierSyntax $term]
  }
  arepl private $newPrivateOutputs outputs

  arepl inputs $inputs g_NM_inheritedTerminals
  arepl outputs $outputs g_NM_inheritedTerminals 

  # miscellaneous
  set rootName $g_NM_rootInstanceName
  set g_NM_rootInstanceName [fixIdentifierSyntax $rootName]
  if {$classDefType == "component"} {
    set fileName $g_NM_livingstoneDefcomponentFileName 
    set g_NM_livingstoneDefcomponentFileName [fixIdentifierSyntax $fileName]
    set componentName $g_NM_livingstoneDefcomponentName 
    set g_NM_livingstoneDefcomponentName [fixIdentifierSyntax $componentName]
    set nameVar $g_NM_livingstoneDefcomponentNameVar
    set g_NM_livingstoneDefcomponentNameVar [fixIdentifierSyntax $nameVar]

  } elseif {$classDefType == "module"} {
    set fileName $g_NM_livingstoneDefmoduleFileName 
    set g_NM_livingstoneDefmoduleFileName [fixIdentifierSyntax $fileName]
    set moduleName $g_NM_livingstoneDefmoduleName 
    set g_NM_livingstoneDefmoduleName [fixIdentifierSyntax $moduleName]
    set nameVar $g_NM_livingstoneDefmoduleNameVar
    set g_NM_livingstoneDefmoduleNameVar [fixIdentifierSyntax $nameVar]

  }
}
 

## g_NM_canvasList - must change jmpl dotted list dots to underscore
## since dot is tcl path delimiter
## 10dec99 wmt: new
proc convertCanavsListToJmpl { canvasList } {

  set newCanvasList {}
  foreach canvas $canvasList {
    set indx [string last "." $canvas]
    set tmp [fixIdentifierSyntax [string range $canvas [expr {$indx + 1}] end]]
    maybeAddQName tmp
    regsub -all "\\\." $tmp "_" token
    lappend newCanvasList ".master.canvas.$token"
  }
  return $newCanvasList 
}


## 10dec99 wmt: new
proc convertTerminalForm { nodeClassType terminalFormRef {QName ?name} } {
  upvar $terminalFormRef terminalForm
  global convertTerminalFormType

  set reportNotFoundP 0
  set terminal_name [fixIdentifierSyntax [assoc terminal_name terminalForm]]
  maybeAddQName terminal_name $QName 
  arepl terminal_name $terminal_name terminalForm
  set terminal_label [assoc terminal_label terminalForm]
  if {$terminal_label != ""} {
    arepl terminal_label [fixIdentifierSyntax $terminal_label] terminalForm
  }
  set typeForm [assoc type terminalForm]
  set direction [string tolower [lindex $typeForm 0]]
  set type [lindex $typeForm 1]
  set convertTerminalFormType $type
  arepl type [list $direction [fixIdentifierSyntax $type]] terminalForm
  if {$nodeClassType != "attribute"} {
    set commandMonitorType [assoc commandMonitorType terminalForm]
    set monType [fixIdentifierSyntax [lindex $commandMonitorType 0]]
    if {$monType == "monitor"} { set monType "monitored" }
    if {$monType == "command"} { set monType "commanded" }
    set monDefault [lindex $commandMonitorType 1]
    if {[llength $monDefault] > 1} {
      set newMonDefault {}
      foreach def $monDefault {
        lappend newMonDefault [fixIdentifierSyntax $def]
      }
      set monDefault $newMonDefault 
    } else {
      set monDefault [fixIdentifierSyntax $monDefault]
      if {$monDefault != "noCommand"} { set monDefault "noCommand" }
    }
    arepl commandMonitorType [list $monType $monDefault] terminalForm
    set interfaceType [string tolower [assoc interfaceType terminalForm]]
    arepl interfaceType $interfaceType terminalForm 
  } else {
    adel commandMonitorType terminalForm $reportNotFoundP
    adel interfaceType terminalForm $reportNotFoundP 
  }
}


## 10dec99 wmt: new
proc convertInOutputs { nodeClassType inOutputs newInOutputsRef {QName ?name} } {
  upvar $newInOutputsRef newInOutputs

  for {set indx 0} {$indx < [llength $inOutputs]} {incr indx 2} {
    lappend newInOutputs [lindex $inOutputs $indx]
    set terminalForm [lindex $inOutputs [expr {$indx + 1}]]
    convertTerminalForm $nodeClassType terminalForm $QName 
    lappend newInOutputs $terminalForm 
  }
}


## add ?name to instance tokens, where user did not enter it
## do this for nodeInstanceName nodeGroupName parentNodeGroupList
## g_NM_canvasList
## 13dec99 wmt: new
proc maybeAddQName { tokenRef {QName ?name} } {
  upvar $tokenRef token

  if {($token != "?name") && ($token != "root") && \
          (! [regexp "\\$QName" $token])} {
    # user did not enter (<token> ?name)
    set token "$QName.$token"
  }
}


## delete Lisp syntax files and rename Java syntax files
# classDefType = component module
## 10dec99 wmt: new
proc lispToJavaDeleteRenameFiles { classDefType {dir ""} } {

  if {$dir == ""} {
    set dir [getSchematicDirectory root $classDefType]
  }
  pushd $dir

  # delete Lisp sytax files
  set lispSyntaxFiles [glob -nocomplain {*.scm}]
  foreach file $lispSyntaxFiles {
    file delete $file
  }
  set lispSyntaxFiles [glob -nocomplain {*.i-scm}]
  foreach file $lispSyntaxFiles {
    file delete $file
  }
  set lispSyntaxFiles [glob -nocomplain {*.terms}]
  foreach file $lispSyntaxFiles {
    file delete $file
  }
  set lispSyntaxFiles [glob -nocomplain {*.dep}]
  foreach file $lispSyntaxFiles {
    file delete $file
  }

  # rename Java syntax files
  set javaSyntaxFiles [glob -nocomplain {*.*-jmpl}] 
  foreach file $javaSyntaxFiles {
    set index [string last "-" $file]
    set newFile [string range $file 0 [expr {$index - 1}]]
    file rename -force $file $newFile 
  }
  popd 
}


## copy Java syntax files from convert directory to
## final direcory and rename - discard -jmpl suffixs
## classDefType = component module
## set prefs: STANLEY_USER_DIR to toDir
## 10dec99 wmt: new
proc lispToJavaCopyRenameFiles { classDefType className \
                                     {fromDir ~/stanley-projs/x-34-model-jmpl-convert} } {

  set toDir [getSchematicDirectory root $classDefType]
  pushd $toDir

  if {$classDefType == "module"} {
    append fromDir /schematics/defmodules
  } else {
    append fromDir /schematics/defcomponents
  }

  file copy $fromDir/$className.scm-jmpl $className.scm
  file copy $fromDir/$className.i-scm-jmpl $className.i-scm
  file copy $fromDir/$className.terms-jmpl $className.terms
  if {$classDefType == "module"} {
    file copy $fromDir/$className.dep-jmpl $className.dep
  }
  popd 
}


## convert class names of files
## bitmap files
## 13dec99 wmt: new
proc convertFileNames { dir } {
 
  pushd $dir
  set files [glob -nocomplain {*}]
  # puts stderr "convertFileNames: files $files"
  foreach file $files {
    if {($file != "README") && ($file != "CVS")} {
      set newFile [fixIdentifierSyntax $file]
      # keep -mask
      set len [string length $newFile]
      if {[string match [string range $newFile [expr {$len - 4}] \
                             [expr {$len - 1}]] "Mask"]} {
        set newFile [string range $newFile 0 [expr {$len - 5}]]
        append newFile "-mask"
      }
      file rename -force $file $newFile 
    }  
  }
  popd
}


proc convertIdentifierList { identList } {

  set newList {}
  foreach ident $identList {
    lappend newList [fixIdentifierSyntax $ident]
  }
  return $newList
}


## recover jmpl files which were renamed by lispToJavaRenameFiles
proc recoverJmplFiles { dir } {

  pushd $dir
  set javaSyntaxFiles [glob -nocomplain {*.*}] 
  foreach file $javaSyntaxFiles {
    set newFile ${file}-jmpl
    file rename -force $file $newFile 
  }
  popd
}


## convert Lisp s-exp tokens to JMPL syntax and
## return form 
## 16mar00 wmt: new
proc convertSexpToJmpl { form } {

  if {[string index $form 0] != "\("} {
    # not a Lisp form
    return ""
  }
  set newForm ""; set closingBracketCnt 0; set level 0
  lispListToTcl form
  # puts stderr "\n\n"
  # handle (no-data (display-state ?name)) properly
  if {[lsearch -exact {if and or} [lindex $form 0]] == -1} {
    set form [list $form]
  }

  convertSexpToJmplDoit form newForm closingBracketCnt level 

  regsub -all "\\\?name" $newForm "this" form
  for {set i 0} {$i < $closingBracketCnt} {incr i} {
    append form "\}"
  }
  if {$closingBracketCnt != 0} {
    append form ";\n"
  }
  return $form 
}

proc convertSexpToJmplDoit { formRef newFormRef closingBracketCntRef levelRef } {
  upvar $formRef form
  upvar $newFormRef newForm
  upvar $closingBracketCntRef closingBracketCnt
  upvar $levelRef level

  set ifOperators { if iff implies when }
  incr level
  set inIfFormP 0; set len2Cnt 0; set andOpP 0; set orOpP 0
  set formLen [llength $form]
  # puts stderr "level $level formLen $formLen"
  foreach element $form {
    # ensure spaces outside of {}'s for tcl's happiness
    regsub -all "\{" $element " \{" tmp
    regsub -all "\}" $tmp "\} " element 
    set len [llength $element]
    if {$len == 2} { incr len2Cnt } else { set len2Cnt 0 }
    if {$len2Cnt == 3} {
      # single if stmt else clause
      append newForm " else\n"
    }
    # puts stderr "len $len element `$element'"
    if {[llength $element] == 1} {
      incr formLen -1
      if {[lsearch -exact $ifOperators $element] >= 0} {
        append newForm "[fixIdentifierSyntax $element] "
        append newForm "\("
        set inIfFormP 1
      } elseif {$element == "not"} {
        append newForm "! "
      } elseif {$element == "and"} {
        set andOpP 1
      } elseif {$element == "or"} {
        set orOpP 1
      }
    } elseif {([llength $element] == 2)} {
      incr formLen -1
      if {[lindex $element 0] != "not"} {
        # puts stderr "el0 [lindex $element 0] el1 [lindex $element 1]"
        set ident1 [fixIdentifierSyntax "\([lindex $element 1]\)"]
        set ident2 [fixIdentifierSyntax "\([lindex $element 0]\)"]
        if {! $inIfFormP} {
          append newForm "  "
        }
        append newForm "$ident1 = $ident2"
        if {$inIfFormP && (! $andOpP) && (! $orOpP)} {
          append newForm "\)\n"
          set inIfFormP 0
        } elseif {($level > 1) && $andOpP && ($formLen > 0)} {
          # not at top level 
          append newForm " &\n"
        } elseif {$orOpP && ($formLen > 0)} {
          append newForm " |\n"
        } else {
          append newForm ";\n"
        }
      } else {
        set form [list [lindex $element 1]]
        convertSexpToJmplDoit form newForm closingBracketCnt level
      }
    } elseif {(([set len [llength $element]] == 3) || \
                  ([set len [llength $element]] == 4)) && \
                  ([lindex $element 0] != "and") && \
                  ([lindex $element 0] != "or") && \
                  ([lindex $element 0] != "not")} {
      incr formLen -1
      set operator [lindex $element 0]
      # puts stderr "operator `$operator' element `$element'"
      if {[lsearch -exact $ifOperators $operator] >= 0} {
        append newForm "else \{\n"
        incr closingBracketCnt
        convertSexpToJmplDoit element newForm closingBracketCnt level
        return
      }
      if {[regsub "pressure-values-" $operator "" tmp]} {
        set operator $tmp
      } elseif {[regsub "flow-values-" $operator "" tmp]} {
        set operator $tmp
      } elseif {[regsub "sr-values-" $operator "" tmp]} {
        set operator $tmp
      } elseif {[regsub "liquid-level-values-" $operator "" tmp]} {
        set operator $tmp
      } elseif {[regsub "pipe-values-" $operator "" tmp]} {
        set operator $tmp
      } elseif {[regsub "temperature-values-" $operator "" tmp]} {
        set operator $tmp
      }
      set arg1 [lindex $element 1]
      set arg2 [lindex $element 2]
      if {$len == 4} {
        set arg3 [lindex $element 3]
      } else {
        set arg3 ""
      }
      tclListToLisp arg1; tclListToLisp arg2 
      # puts stderr "operator $operator arg1 $arg1 arg2 $arg2 arg3 $arg3"
      set ident1 [fixIdentifierSyntax "\($operator \($arg1\)\)"]
      set ident2 [fixIdentifierSyntax "\($arg2\)"]
      append newForm "$ident1\($ident2"
      if {$len == 4} {
        set ident3 [fixIdentifierSyntax "\($arg3\)"]
        append newForm ", $ident3"
      }
      append newForm "\)"
      if {$inIfFormP && $andOpP && ($formLen > 0)} {
        # only inside if conditional forms
        append newForm " &\n"
      } elseif {$orOpP && ($formLen > 0)} {
        append newForm " |\n"
      } else {
        append newForm ";\n"
      }
    } else {
      convertSexpToJmplDoit element newForm closingBracketCnt level
    }
  }
}


## convertScenarioFiles "~/stanley-projs/x-34-model-jmpl/livingstone/models/scenarios"
## 03apr00 wmt: new
proc convertScenarioFiles { dir } {

  pushd $dir
  set files [glob -nocomplain {*.lisp}]
  # puts stderr "convertScenarioFiles : files $files"
  foreach file $files {
    convertScenario "$dir/$file"
  }
  popd
}


## convert Lisp defscenario files to Livingstone C++ script format
## do-cmd
## convertScenario "~/stanley-projs/x-34-model-jmpl/livingstone/models/scenarios/lox-engine-interface-dump.lisp"
## do-monitors
## convertScenario "~/stanley-projs/x-34-model-jmpl/livingstone/models/scenarios/lox-engine-interface-initial-conditions.lisp"
## convert Lisp defscenario files to Livingstone C++ script format
## 03apr00 wmt: new
proc convertScenario { pathname } {

  set form {}; set discardP 1
  set newForm {}
  set scenarioName [fixIdentifierSyntax [file rootname [file tail $pathname]]]
  set moduleName ""
  set fid [open $pathname r]
  while {[gets $fid line] >= 0} {
    if {$discardP} {
      if {[regexp "defscenario" $line]} {
        set discardP 0
        append form "$line\n"
      }
    } else {
      append form "$line\n"
    }
  }
  close $fid
  # discard ;
  regsub -all ";" $form "" tmp
  # discard ', if any
  regsub -all "'" $tmp "" form
  lispListToTcl form
  set indx 0
  foreach sublist $form {
    # puts stderr "indx $indx sublist $sublist"
    if {$indx == 1} {
      # use pathname instead of (defscenario <name> ... )
      ; # set scenarioName [fixIdentifierSyntax $sublist]
    } elseif {$indx == 2} {
      set moduleName $sublist
      append newForm "scenario $scenarioName [fixIdentifierSyntax $moduleName]\n"
    } elseif {($indx >= 10) && \
                  ([lindex $sublist 0] == "do-cmd")} {
      # puts stderr "do-cmd "
      set cmdIndx 0
      foreach element $sublist {
        if {$cmdIndx == 1} {
          # cmd attribute form
          # the cmd form may be wrapped with quote
          if {[lindex $element 0] == "quote"} {
            set subform [lindex $element 1]
            tclListToLisp subform
            append newForm "progress [fixIdentifierSyntax \($subform\)]="
          } else {
            tclListToLisp element
            append newForm "progress [fixIdentifierSyntax \($element\)]="
          }
        } elseif {$cmdIndx == 2} {
          # cmd value form
          # the cmd value form may be wrapped with quote
          if {[lindex $element 0] == "quote"} {
            append newForm "[fixIdentifierSyntax [lindex $element 1]]\n"
          } else {
            append newForm "[fixIdentifierSyntax $element]\n" 
          }
        } elseif {$cmdIndx == 3}  {
          # list of monitors
          if {[lindex $element 0] == "quote"} {
            set monitorFormList [lindex $element 1]
          } else {
            set monitorFormList $element
          }
          foreach monitorForm $monitorFormList {
            # puts stderr "monitorForm $monitorForm"
            set attribute [lindex $monitorForm 1]
            tclListToLisp attribute 
            append newForm "assign [fixIdentifierSyntax \($attribute\)]="
            append newForm "[fixIdentifierSyntax [lindex $monitorForm 0]]\n"
          }
        }
        incr cmdIndx 
      }
      append newForm "fc\n"
    } elseif {($indx >= 10) && \
                  ([lindex $sublist 0] == "do-monitors")} {
      # puts stderr "do-monitors"
      set element [lindex $sublist 1]
      # list of monitors
      if {[lindex $element 0] == "quote"} {
        set monitorFormList [lindex $element 1]
      } else {
        set monitorFormList $element
      }
      foreach monitorForm $monitorFormList {
        # puts stderr "monitorForm $monitorForm"
        set attribute [lindex $monitorForm 1]
        tclListToLisp attribute 
        append newForm "assign [fixIdentifierSyntax \($attribute\)]="
        append newForm "[fixIdentifierSyntax [lindex $monitorForm 0]]\n"
      }
      append newForm "fc\n"
    }
    incr indx
  }

  regsub -all "test\\\." $newForm "" tmp; set newForm $tmp
  # puts stderr "newForm \n$newForm"

  set outPathname "[file dirname $pathname]/$scenarioName.scr" 
  set fid [open $outPathname w]
  puts $fid $newForm
  close $fid
  puts stderr "Writing scenario script file"
  puts stderr "    $outPathname"
}


## prependTestToScenarioFiles "~/stanley-projs/x-34-model-jmpl/livingstone/models/scenarios"
## 19may00 wmt: new
proc prependTestToScenarioFiles { dir } {

  pushd $dir
  set files [glob -nocomplain {*.scr}]
  # puts stderr "convertScenarioFiles : files $files"
  foreach file $files {
    prependTestToScenario "$dir/$file"
  }
  popd
}


proc prependTestToScenario { pathname } {

  set tmpPathname "[file rootname $pathname].tmp"
  set fidIn [open $pathname r]
  set fidOut [open $tmpPathname w]
  while {[gets $fidIn line] >= 0} {
    if {([string range $line 0 6] == "assign ") && \
            ([string range $line 0 11] != "assign test.")} {
      regsub "assign " $line "assign test." tmp
      set line $tmp
    } elseif {([string range $line 0 8] == "progress ") && \
                  ([string range $line 0 13] != "progress test.")} {
      regsub "progress " $line "progress test." tmp
      set line $tmp
    }
    puts $fidOut $line
  }
  close $fidIn
  close $fidOut
  file delete $pathname
  file rename $tmpPathname $pathname 
}










