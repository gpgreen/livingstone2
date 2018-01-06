# $Id: util.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## util.tcl : utility procedures


## check output file name for possible problems
proc openOutputCheck {filepath} {
   if [file exists $filepath] {openOutputCheckExists $filepath}
   if [file writable [file dirname $filepath]] {return 1}
   error "$filepath cannot be created for output"
}

proc openOutputCheckExists {filepath} {
   if {![file isfile $filepath]} {
      error "$filepath exists, is not a file"
   }
   if {![file writable $filepath]} {
      error "$filepath exists, cannot be written."
   }
   return 1
}
## debug trace
proc debugPuts {msg {debugLevel 0}} {
  global DEBUG 
  if [info exists DEBUG] {
    if {$DEBUG > $debugLevel} {
      puts $msg;
    }
  }
}

## module pushd and popd
proc pushd {d} {
  global __PUSHD
  if {![info exists __PUSHD]} {
    set __PUSHD {};
  }
  lappend __PUSHD [pwd];
  if [catch {cd $d} msg] {
    puts stdout $msg
    tk_dialog .d "Error" "Internal Error: $msg" {} 0 OK;
    popd
  }
}

proc popd {} {
  global __PUSHD
  if {![info exists __PUSHD]} {
    set __PUSHD {};
  }
  if {![llength __PUSHD]} return;
  set d [lindex $__PUSHD 0]
  set __PUSHD [lrange $__PUSHD 1 end]
  cd $d
}

# ask user to confirm their choice, abort if not
## 17oct95 wmt: correct return when choice is No
proc confirm {{msg ""}} {
  set msg "${msg}?"
  set dialogList [list tk_dialog .d "CONFIRM" $msg warning 0 {YES} {NO}]
  set retValue [eval $dialogList]
  if {$retValue} {
    return 0
  } else {
    return 1
  }
}

## Useful type predicates:
    
# 1 if the arg is numeric, 0 otherwise
proc numericp x {
  regexp  {^([0-9]+)$} $x
}

# 1 if the arg is alphabetic, 0 otherwise
proc alphabeticp x {
  regexp  {^([a-zA-Z]+)$} $x
}

# 1 if the arg is alphanumeric, 0 otherwise
proc alphanumericp x {
  regexp  {^([a-zA-Z0-9]+)$} $x
}

## Scan comma-separated string and return a list of field values.
## Lexical rules for the lines:
##  1. Fields are separated by white space or commas. Final \n ignored.
##  2. Fields containing significant blanks or commas can be escaped 
##     as follows:
##     \b = blank, \c = comma, \\ = backslash.
##
## Example: commasep "  ab, cd\t e\\c "  returns a list with three values:
##    ab
##    cd
##    e,

## scan comma-separated string. limit the number of fields to $maxfields
proc commasep {line {maxfields 9999}} {
  set numfields 0
  set line [string trim $line]
  set newindex 0
  set fields {}
  set index [commasepTrim_274 line $newindex]
  while {[set newindex [commasepField_274 line $index]] > $index} {
    lappend fields [commasepEscape_274 line $index $newindex]
    incr numfields
    if {$numfields >= $maxfields} {return $fields}
    set index [commasepTrim_274 line $newindex]
  }
  return $fields;
}

## scan forward for the index past the end of the next field.
proc commasepField_274 {linename start} {
  upvar $linename line
  while {$start < [string length $line]} {
    set char [string index $line $start]
    if {[string first $char ",\t\v\r\b\f\ \n"] > -1} {
      return $start;
    }
    incr start;
  }
  return $start;
}
  
## scan forward for the index past the end of the next whitespace/comma field
proc commasepTrim_274 {linename start} {
  upvar $linename line
  while {$start < [string length $line]} {
    set char [string index $line $start]
    if {[string first $char ",\t\v\r\b\f\ \n"] == -1} {
      return $start;
    }
    incr start;
  }
  return $start;
}
  
## extract a field and convert escapes to characters
proc commasepEscape_274 {linename from to} {
  upvar $linename line
  incr to -1
  set field [string range $line $from $to]
  regsub -all {\\\b} $field " " field
  regsub -all {\\\c} $field "," field
  regsub -all {\\\\} $field "\\" field
  return $field
  }

##-----------------------------

# C-like "assert" utility. Arg is evaluated in caller's context; error
#  if result is zero. Nop unless the global DEBUG is defined.
#  Example:  assert {expr $var > 0}
proc assert {truth} {
  global DEBUG
  if [info exists DEBUG] {
    if {![uplevel $truth]} {
      error "Assertion failed: $truth"
    }
    return 1;
  }
}
        
## returns the intersection of two lists
proc intersection {la lb} {
  set intersection {}
  foreach a $la {
    if {[lsearch -exact $lb $a] != -1} {
      lappend intersection $a
    }
  }
  return $intersection
}
 
  
## "save" a file F by making a copy to F~. Return 1
##  iff successful
proc savefile {path} {
  set bkuppath "$path~"
  if [catch {exec rm -f $bkuppath} msg] {return 0}
  if {[file exists $path]} {
    if [catch {copyfile $path $bkuppath} msg] {return 0}
  }
  return 1
}

proc copyfile {from to} {
  set ffrom [open $from r]
  set fto   [open $to w]
  while {[gets $ffrom line] >= 0} {
    puts $fto $line
  }
  close $ffrom
  close $fto
}

## scan a .tcl source file for proc statements and preceding comments
proc procscan {sourcefile ostream} {
  set f [open $sourcefile r]
  set linecnt 0
  set proclist {}
  while {[gets $f line($linecnt)] >= 0} {
   if [string match "proc ?*" $line($linecnt)] {
     lappend proclist $linecnt
    }
    incr linecnt
  }
  close $f
  foreach x $proclist {
    set commentlines [expr {$x - 1}]
    while {$commentlines >= 0} {
      if {![string match "#*" $line($commentlines)]} {
	incr commentlines 
	break
      }
      incr commentlines -1
    }
    for {set i $commentlines} {$i <= $x} {incr i} {
      puts $ostream $line($i)
    }
    puts $ostream ""
  }
}

## scan all .tcl source files in a given path for proc
## statments and associated comments. Append the output to a file.
proc directoryscan {path outfilename} {
  set sources [glob ${path}/*.tcl]
  set of [open $outfilename a]
  foreach sf $sources {
    puts $of "\n***  Source File: $sf ***\n"
    puts stdout "***  Source File: $sf ***"
    procscan $sf $of
  }
  close $of
}


## check for differences in pirNode structures
## regardless of order of assoc list
## 13dec95 wmt: new
## 19mar96 wmt: remove checking for internal, fixed and required variables
## 23jul96 wmt: re-add checking for internal
## 31jul96 wmt: do not print out, or return 1 for attributesToIgnore 
## 13sep96 wmt; added schematic_file to attributesToIgnore
## 16sep96 wmt: remove restriction that both structures must be
##              strictly ordered
## 01feb98 wmt: not used
proc pirNodeDiff { pirNodeBeforeName pirNodeAfterName {beforeAfterP 0} \
    { imbeddedList {required internal} } { printOutputP 1 } } {
  upvar $pirNodeBeforeName pirNodeBefore
  upvar $pirNodeAfterName pirNodeAfter
  global g_NM_detailLogP

  set reportNotFoundP 0; set returnIndexP 1
  if {! $g_NM_detailLogP} {
    return 0
  }
  # puts stderr "pirNodeDiff: pirNodeBefore $pirNodeBefore"
  # puts stderr "pirNodeDiff: pirNodeAfter $pirNodeAfter"
  ## these attributes will not be updated into pirClass structs in .scm & .i-scm
  ## files -- they will however be up to date in .cfg files
  set attributesToIgnore [list component_file model_markers schematic_file]
  set diffsFoundP 0; set firstOutputP 1
  if {$beforeAfterP} {
    set firstTag "before"
    set secondTag "after "
  } else {
    set firstTag  "**CURR: "
    set secondTag "***NEW: "
  }
  set nodeClassName [assoc nodeClassName pirNodeBefore $reportNotFoundP]
  set nodeInstanceName [assoc nodeInstanceName pirNodeBefore $reportNotFoundP]
  # puts stderr "pirNodeDiff: nodeClassName $nodeClassName nodeInstanceName $nodeInstanceName"
  set str "======================================\n"
  if {! [string match $nodeInstanceName ""]} {
    set str "$str instance: $nodeInstanceName\n"
  }
  if {! [string match $nodeClassName ""]} {
    set str "$str class: $nodeClassName\n"
  }
  set str "${str}======================================"
  set beforeLength [llength $pirNodeBefore]
  set afterLength [llength $pirNodeAfter]
  if {$beforeLength != $afterLength} {
    puts stderr "\npirNodeDiff: beforeLength $beforeLength afterLength $afterLength"
    puts stdout "\n"
    aputs stdout pirNodeBefore
    puts stdout "\n"
    aputs stdout pirNodeAfter
    puts stdout "\n"
  }
  for {set i 0} {$i < [llength $pirNodeBefore]} {incr i} {
    set fieldname [lindex $pirNodeBefore $i]
    # puts stderr "fieldname $fieldname"
    incr i
    if {[lsearch -exact $imbeddedList $fieldname] >= 0} {
      set beforeAlist [assoc $fieldname pirNodeBefore]
      set afterAlist [assoc $fieldname pirNodeAfter]
      for {set j 0} {$j < [llength $beforeAlist]} {incr j} {
        set fieldnameB [lindex $beforeAlist $j]
        ## set fieldnameA [lindex $afterAlist $j]
        set aj [assoc-exact $fieldnameB afterAlist 1 $returnIndexP]
        set fieldnameA [lindex $afterAlist $aj] 
        # puts stderr "pirNodeDiff: i=$i; j=$j fieldnameB $fieldnameB fieldnameA $fieldnameA"
        if {! [string match $fieldnameB $fieldnameA]} {
          set str1 "pirNodeDiff: i=$i; j=$j fieldnames $fieldnameB and $fieldnameA"
          puts stderr "$str1 do not match\!"
          set diffsFoundP 1
          return $diffsFoundP
        }
        incr j
        set beforeValueList [assoc $fieldnameB beforeAlist]
        set afterValueList [assoc $fieldnameA afterAlist]
        for {set k 0} {$k < [llength $beforeValueList]} {incr k} {
          set fieldnameBb [lindex $beforeValueList $k]
          ## set fieldnameAa [lindex $afterValueList $k]
          set ak [assoc-exact $fieldnameBb afterValueList 1 $returnIndexP]
          set fieldnameAa [lindex $afterValueList $ak] 
          # set str2 "pirNodeDiff: i=$i; j=$j; k=$k; fieldnameBb $fieldnameBb"
          # puts stderr "$str2 fieldnameAa $fieldnameAa"
         if {! [string match $fieldnameBb $fieldnameAa]} {
            set str "pirNodeDiff: i=$i; j=$j; k=$k; fieldnames $fieldnameBb and $fieldnameAa"
            puts stderr "$str do not match\!"
            set diffsFoundP 1
            return $diffsFoundP
          }
          incr k
          set beforeValue [assoc $fieldnameBb beforeValueList]
          set afterValue [assoc $fieldnameAa afterValueList]
          if {! [string match $beforeValue $afterValue]} {
            set beforeValueDefault [assoc default beforeValue]
            set afterValueDefault [assoc default afterValue]
            if {! [string match $beforeValueDefault $afterValueDefault]} {
              if {[lsearch -exact $attributesToIgnore $fieldnameBb] == -1} {
                ## do not set diffsFoundP for changes in these attributes
                ## since they do not affect the schematic appearance & function
                set diffsFoundP 1
                if {$printOutputP} {
                  if {$firstOutputP} {
                    set firstOutputP 0
                    puts stderr $str
                  }
                  puts stderr "pirNodeDiff: \`$fieldname\' \`$fieldnameB\' \`$fieldnameBb\'"
                  puts stderr " $firstTag \`$beforeValueDefault\' "
                  puts stderr " $secondTag \`$afterValueDefault\'"
                }
              }
            }
          }
        }
      }
    } else {
      set beforeValue [assoc $fieldname pirNodeBefore]
      set afterValue [assoc $fieldname pirNodeAfter]
      if {! [string match $beforeValue $afterValue]} {
        set diffsFoundP 1
        if {$printOutputP} {
          if {$firstOutputP} {
            set firstOutputP 0
            puts stderr $str
          }
          puts stderr "pirNodeDiff: fieldname \`$fieldname\' \
              \n  $firstTag \`$beforeValue\' \n  $secondTag \`$afterValue\'"
        }
      }
    }
  }
  # if {! $diffsFoundP} {
  #   puts stderr "  no differences found."
  # }
  return $diffsFoundP 
}


## 17dec95 wmt: new
##              toggle boolean for pirNodeDiff output
proc toggleDetailLog { } { 
  global g_NM_detailLogP
  global g_NM_menuStem 

  set g_NM_detailLogP [expr {[incr g_NM_detailLogP] % 2}]
  ## puts "toggleDetailLog g_NM_detailLogP $g_NM_detailLogP"
  switch $g_NM_detailLogP {
    0 {
      .master.$g_NM_menuStem.debug.m entryconfigure \
          "Component Detail Change Log On" -state normal
      .master.$g_NM_menuStem.debug.m entryconfigure \
          "Component Detail Change Log Off" -state disabled
    }
    1 {
      .master.$g_NM_menuStem.debug.m entryconfigure \
          "Component Detail Change Log On" -state disabled 
      .master.$g_NM_menuStem.debug.m entryconfigure \
          "Component Detail Change Log Off" -state normal
    }
  }   
}


## add component class instance record keeping
## 20dec95 wmt: new
## 13mar96 wmt: add g_NM_instanceToNode
## 04jun96 wmt: add g_NM_nodeGroupToInstances processing
## 02jul96 wmt: implement multiple canvases
## 09dec96 wmt: add g_NM_componentToNode & g_NM_moduleToNode
## 08may97 wmt: add g_NM_includedModules & g_NM_groupLevelSavei
## 09oct98 wmt: arrays, rather than an assoc lists for long list variables
proc addClassInstance { nodeClassName nodeInstanceName pirNodeIndex canvasId \
                            currentCanvas window } {
  global g_NM_classToInstances pirNode g_NM_instanceToNode
  global g_NM_nodeGroupToInstances g_NM_currentNodeGroup
  global g_NM_canvasIdToPirNode g_NM_componentToNode pirNode
  global g_NM_moduleToNode g_NM_includedModules g_NM_groupLevelSave
  global g_NM_windowPathToPirNode g_NM_dependentClasses
  global g_NM_classDefType XpirClass XpirClasses g_NM_classTypes
  global g_NM_schematicMode 


  # puts stderr "addClassInstance: nodeInstanceName $nodeInstanceName pirNodeIndex $pirNodeIndex"
  # puts stderr "addClassInstance: canvasId $canvasId currentCanvas $currentCanvas"
  set assocReportNotFoundP 0; set returnIndexP 1
  set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]

  # add to g_NM_canvasIdToPirNode
  set currentEntries [assoc-array $currentCanvas g_NM_canvasIdToPirNode \
                          $assocReportNotFoundP]
  if {[string match "" $currentEntries]} {
    set reportNotFoundP 0; set oldvalMustExistP 0
  } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
  lappend currentEntries $canvasId $pirNodeIndex
  arepl-array $currentCanvas $currentEntries g_NM_canvasIdToPirNode \
      $reportNotFoundP $oldvalMustExistP

  # add to g_NM_windowPathToPirNode 
  set currentEntries [assoc-array $currentCanvas g_NM_windowPathToPirNode \
                          $assocReportNotFoundP]
  if {[string match "" $currentEntries]} {
    set reportNotFoundP 0; set oldvalMustExistP 0
  } else {
    set reportNotFoundP 1; set oldvalMustExistP 1
  }
  lappend currentEntries $window $pirNodeIndex
  arepl-array $currentCanvas $currentEntries g_NM_windowPathToPirNode \
      $reportNotFoundP $oldvalMustExistP

  if {[regexp "master" $currentCanvas]} {

    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    # add to g_NM_classToInstances
    # g_NM_paletteTypes + component
    set currentEntries [assoc-array $nodeClassName g_NM_classToInstances \
                            $assocReportNotFoundP]
    if {[string match "" $currentEntries]} {
      set reportNotFoundP 0; set oldvalMustExistP 0
    } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
    lappend currentEntries $nodeInstanceName $pirNodeIndex
    arepl-array $nodeClassName $currentEntries g_NM_classToInstances \
        $reportNotFoundP $oldvalMustExistP

    if {[string match $g_NM_schematicMode "layout"] && \
            ([expr {[llength $parentNodeGroupList] - 1}] == $g_NM_groupLevelSave)} {
      # this handles abstraction, relation,structure, symbol, & values classes
      getDependentClassNameList $nodeClassType $nodeClassName $pirNodeIndex \
          dependentClassTypeList dependentClassNameList
      foreach dependentClassType $dependentClassTypeList dependentClassName \
          $dependentClassNameList {
        if {[lsearch -exact {component module} $dependentClassType] == -1} {
          # add to g_NM_classToInstances
          set currentEntries [assoc-array $dependentClassName g_NM_classToInstances \
                                  $assocReportNotFoundP]
          if {[string match "" $currentEntries]} {
            set reportNotFoundP 0; set oldvalMustExistP 0
          } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
          lappend currentEntries $nodeInstanceName $pirNodeIndex
          arepl-array $dependentClassName $currentEntries g_NM_classToInstances \
              $reportNotFoundP $oldvalMustExistP
        }
        updateDependentClasses $dependentClassType $dependentClassName "add"
      }
    }

    # add to g_NM_currentNodeGroup 
    set nodeGroupNameIndex [assoc nodeGroupName pirNode($pirNodeIndex) \
                                $assocReportNotFoundP $returnIndexP]
    # set str "addClassInstance: nodeInstanceName $nodeInstanceName pirNodeIndex"
    # puts stderr "$str $pirNodeIndex nodeGroupNameIndex $nodeGroupNameIndex"
    if {$nodeGroupNameIndex == -1} {
      set nodeGroupName [getCanvasRootInfo g_NM_currentNodeGroup] 
      acons nodeGroupName $nodeGroupName pirNode($pirNodeIndex)
    } else {
      set nodeGroupName [assoc nodeGroupName pirNode($pirNodeIndex)]
    }
    # puts stderr "addClassInstance: nodeGroupName $nodeGroupName"

    # add to g_NM_nodeGroupToInstances
    set currentEntries [assoc-array $nodeGroupName g_NM_nodeGroupToInstances \
                            $assocReportNotFoundP ]
    if {[string match "" $currentEntries]} {
      set reportNotFoundP 0; set oldvalMustExistP 0
    } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
    lappend currentEntries $nodeInstanceName $pirNodeIndex
    arepl-array $nodeGroupName $currentEntries g_NM_nodeGroupToInstances \
        $reportNotFoundP $oldvalMustExistP

    # add to g_NM_instanceToNode, g_NM_componentToNode & g_NM_moduleToNode
    # all nodeClassTypes go in this array
    set g_NM_instanceToNode($nodeInstanceName) $pirNodeIndex 

    if {[string match $nodeClassType "terminal"]} {
      set terminalName $nodeInstanceName 
      set reportNotFoundP 0; set oldvalMustExistP 0
      set inheritedCmdMonP [commandMonitorTerminalInheritedP \
                                [list $terminalName] valuesList $nodeClassType]
      arepl inheritedCmdMonP $inheritedCmdMonP pirNode($pirNodeIndex) \
          $reportNotFoundP $oldvalMustExistP 
    }

    set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
    if {[string match $nodeClassType "component"]} {
      set g_NM_componentToNode($nodeInstanceName) $pirNodeIndex 
    } elseif {[string match $nodeClassType "module"]} {
      # this list will have both parent-links and regular modules
      # nodeState = "parent-link" & nodeState = "NIL"
      set g_NM_moduleToNode($nodeInstanceName) $pirNodeIndex 
    }
    if {[string match $g_NM_schematicMode "layout"] && \
            ([expr {[llength $parentNodeGroupList] - 1}] == $g_NM_groupLevelSave)} {
      set reportNotFoundP 0
      set nodeState [assoc nodeState pirNode($pirNodeIndex) $reportNotFoundP]
      if {([string match $nodeClassType "component"] || \
                 ([string match $nodeClassType "module"] && \
                      [string match $nodeState "NIL"]))} {
        # if this is a top-level included module or component, save its "pointer" for
        # re-instantiation
        # set str "addClassInstance: nodeInstanceName $nodeInstanceName parentNodeGroupList"
        # puts stderr "$str $parentNodeGroupList"

        set entry [list nodeClassName $nodeClassName nodeClassType $nodeClassType \
                       pirNodeIndex $pirNodeIndex \
                       argsValues [assoc argsValues pirNode($pirNodeIndex)] \
                       window [assoc window pirNode($pirNodeIndex)] \
                       nodeX [assoc nodeX pirNode($pirNodeIndex)] \
                       nodeY [assoc nodeY pirNode($pirNodeIndex)] \
                       labelX [assoc labelX pirNode($pirNodeIndex)] \
                       labelY [assoc labelY pirNode($pirNodeIndex)] \
                       instanceLabel [assoc instanceLabel pirNode($pirNodeIndex)] \
                       inputs [assoc inputs pirNode($pirNodeIndex)] \
                       outputs [assoc outputs pirNode($pirNodeIndex)]]
        # acons $nodeInstanceName $entry g_NM_includedModules
        lappend g_NM_includedModules $nodeInstanceName $entry 
        # puts stderr "addClassInstance: added $nodeInstanceName to g_NM_includedModules"
      }
    }
  }
}


## 15feb01 wmt: new
proc updateDependentClasses { dependentClassTypeList dependentClassNameList updateOp } {
  global g_NM_dependentClasses 

  if {($dependentClassTypeList == "") || ($dependentClassNameList == "")} {
    return
  }
  # puts stderr "updateDependentClasses: updateOp $updateOp dependentClassTypeList $dependentClassTypeList dependentClassNameList $dependentClassNameList "
  foreach dependentClassType $dependentClassTypeList dependentClassName \
      $dependentClassNameList {
        # puts stderr "    $updateOp $dependentClassType $dependentClassName"
        set entries [assoc $dependentClassType g_NM_dependentClasses]
        if {$updateOp == "add"} {
          if {[lsearch -exact $entries $dependentClassName] == -1} {
            lappend entries $dependentClassName
            arepl $dependentClassType $entries g_NM_dependentClasses      }
        } elseif {$updateOp == "delete"} {
          # only called if no more instances exist
          lremove entries $dependentClassName
          arepl $dependentClassType $entries g_NM_dependentClasses
        } else {
          error "getDependentClassType: updateOp $updateOp not handled"
        }
      }
}


## return dependent user-defined class name for node objects of type:
## attribute component mode module terminal 
## 15feb01 wmt: new
proc getDependentClassNameList { paletteType paletteClass pirNodeIndex \
                                     dependentClassTypeListRef dependentClassNameListRef \
                                     {abstractionType ""} {fromNodeToNode ""}} {
  upvar $dependentClassTypeListRef dependentClassTypeList
  upvar $dependentClassNameListRef dependentClassNameList
  global pirNode g_NM_dependentClasses g_NM_paletteTypes pirEdge
  global g_NM_paletteDefsymbolList g_NM_classDefType pirFileInfo
  global g_NM_dependencyErrorList 

  set dependentClassNameList {}; set dependentClassTypeList {}
  set reportNotFoundP 0
  # puts stderr "getDependentClassNameList: paletteType $paletteType paletteClass $paletteClass"
  set reportNotFoundP 0
  if {[lsearch -exact $g_NM_paletteTypes $paletteType] >= 0} {
    set nodeState [assoc nodeState pirNode($pirNodeIndex) $reportNotFoundP]
    if {$nodeState != "parent-link"} {
      if {[lsearch -exact {component module} $paletteType] >= 0} {
        lappend dependentClassTypeList $paletteType
        lappend dependentClassNameList $paletteClass
        # get the type of terminals inherited by the component/module
        set inputs [assoc inputs pirNode($pirNodeIndex) $reportNotFoundP]
        for {set i 1} {$i < [llength $inputs]} {incr i 2} {
          set terminalForm [lindex $inputs $i]
          set terminalType [getTerminalType $terminalForm]
          set dependentClassType \
              [getDependentTerminalTypeClass $g_NM_classDefType \
                   $pirFileInfo(filename) $terminalType]
          if {$dependentClassType != ""} {
            lappend dependentClassTypeList $dependentClassType 
            lappend dependentClassNameList $terminalType
          }
        }
        set outputs [assoc outputs pirNode($pirNodeIndex) $reportNotFoundP]
        for {set i 1} {$i < [llength $outputs]} {incr i 2} {
          set terminalForm [lindex $outputs $i]
          set terminalType [getTerminalType $terminalForm]
          set dependentClassType \
              [getDependentTerminalTypeClass $g_NM_classDefType \
                   $pirFileInfo(filename) $terminalType]
          if {$dependentClassType != ""} {
            lappend dependentClassTypeList $dependentClassType 
            lappend dependentClassNameList $terminalType
          }
        }
      } elseif {[lsearch -exact {attribute terminal} $paletteType] >= 0} {
        set terminalType [getTerminalInstanceType $pirNodeIndex terminalForm]
        set dependentClassType \
            [getDependentTerminalTypeClass $g_NM_classDefType $pirFileInfo(filename) \
                 $terminalType]
        if {$dependentClassType != ""} {
          lappend dependentClassTypeList $dependentClassType 
          lappend dependentClassNameList $terminalType
        }
      } elseif {[string match $paletteType "mode"]} {
        if {$paletteClass == "faultMode"} {
          set dependentClassName [assoc probability pirNode($pirNodeIndex)]
          if {[alphanumericp $dependentClassName]} {
            if {[lsearch -exact $g_NM_paletteDefsymbolList $dependentClassName] >= 0} {
              lappend dependentClassTypeList "symbol"
              lappend dependentClassNameList $dependentClassName
            } else {
              # component/module c/m-name reference-type reference-name
              set errorForm [list "component" $pirFileInfo(filename) modeProbability \
                                 $dependentClassName]
              if {[lsearch -exact $g_NM_dependencyErrorList $errorForm] == -1} {
                lappend g_NM_dependencyErrorList $errorForm 
              }
            }
          }
        }
      }
    }
  } elseif {$paletteType == "edge"} {
    if {$abstractionType != "equal"} {
      # puts stderr "getDependentClassNameList abstractionType $abstractionType"
      set dependentClassType \
          [getDependentTerminalTypeClass "edge" $fromNodeToNode \
               $abstractionType]
      if {$dependentClassType != ""} {
        lappend dependentClassTypeList $dependentClassType 
        lappend dependentClassNameList $abstractionType
      }
    }
  }
  # puts stderr "getDependentClassNameList   dependentClassType $dependentClassTypeList"
  # puts stderr "getDependentClassNameList   dependentClassName $dependentClassNameList"
}


## check for existence of class instance
## 20dec95 wmt: new
## 09jul96 wmt : also check that instance name is not in another class
## 17dec96 wmt: do not do extra checking in operational mode
proc checkClassInstance { nodeClassName nodeInstanceName outputMsgP } {
  global g_NM_classToInstances g_NM_instanceToNode pirNode
  global g_NM_schematicMode 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "checkClassInstance: `$backtrace'"
  # puts stderr "checkClassInstance: g_NM_classToInstances [array get g_NM_classToInstances]"
  # puts "checkClassInstance: nodeClassName $nodeClassName 
  #          nodeInstanceName $nodeInstanceName"
  set foundP 0; set reportNotFoundP 0
  set currentEntries [assoc-array $nodeClassName g_NM_classToInstances \
                          $reportNotFoundP]
  if {[lsearch -exact $currentEntries $nodeInstanceName] >= 0} {
    set indexOfMaybeDuplicate [assoc-array $nodeInstanceName g_NM_instanceToNode]
    set foundP 1
  }
  # puts "checkClassInstance: 1 foundP $foundP"
  if {(! $foundP) && (! [string match $g_NM_schematicMode "operational"])} {
    # also check that instance name is not in another class
    set indexOfMaybeDuplicate [assoc-array $nodeInstanceName g_NM_instanceToNode \
                                   $reportNotFoundP]
    if {! [string match $indexOfMaybeDuplicate ""]} {
      set foundP 1
    }
  }
  # puts "checkClassInstance: 2 foundP $foundP "
  ## allow no restriction on multiple instances of variable names
  ## set firstChar [string index $nodeInstanceName 0]
  ## if {$foundP && [string match $firstChar ?]} {
  ##   set foundP 0
  ## }

  if {$foundP} {
    set nodeClassName [assoc nodeClassName pirNode($indexOfMaybeDuplicate)]
    # set backtrace ""; getBackTrace backtrace
    # puts stderr "checkClassInstance: `$backtrace'"
    set nodeClassType [assoc nodeClassType pirNode($indexOfMaybeDuplicate)]
    set nodeGroupName [assoc nodeClassType pirNode($indexOfMaybeDuplicate)]
    set str "instance `[getExternalNodeName $nodeInstanceName]' of"
    append str "\n  $nodeClassType class `$nodeClassName' \n  already exists!"
    set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
    eval $dialogList

    if {$outputMsgP} {
      puts stderr "checkClassInstance: indexOfMaybeDuplicate $indexOfMaybeDuplicate"
      regsub -all "\\\n" $str "" flatStr
      puts stderr "      $flatStr"
    }
  }
  if {! $foundP} {
    # check transition names
    if {[checkTransitionNames [getExternalNodeName $nodeInstanceName]]} {
      set foundP 1
      set str "`[getExternalNodeName $nodeInstanceName]' already exists"
      append str "\n  as a mode transition name!"
      set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
      eval $dialogList

      if {$outputMsgP} {
        puts stderr "checkClassInstance: "
        regsub -all "\\\n" $str "" flatStr
        puts stderr "      $flatStr"
      }
    }
  }
  return $foundP
}


## delete component class instance
## 20dec95 wmt: new
## 13mar96 wmt: add g_NM_instanceToNode
## 04jun96 wmt: add g_NM_nodeGroupToInstances processing
## 02jul96 wmt: implement multiple canvases
## 02jul96 wmt: implement multiple canvases
## 12jul96 wmt: pass in canvas, so that multiple level defmodule
##              deletions will use the correct canvas; when all
##              class instances are deleted, remove the pirClass
##              entry
## 03oct96 wmt: replace adel with adel-exact to properly delete from
##              g_NM_canvasIdToPirNode, which is all integers
## 09dec96 wmt: add g_NM_componentToNode & g_NM_moduleToNode
## 08may97 wmt: add g_NM_includedModules;
##              remove entries from g_NM_livingstoneDefmoduleArgList
proc deleteClassInstance { canvas nodeClassName nodeInstanceName window \
                               {renameP 0} } {
  global g_NM_classToInstances g_NM_instanceToNode pirNode
  global g_NM_nodeGroupToInstances g_NM_canvasIdToPirNode
  global g_NM_canvasRedrawP pirNodes g_NM_rootInstanceName 
  global g_NM_componentToNode g_NM_classDefType
  global g_NM_moduleToNode g_NM_includedModules g_NM_groupLevelSave
  global g_NM_livingstoneDefmoduleNameVar g_NM_schematicMode 
  global g_NM_maxDefmoduleArgs g_NM_windowPathToPirNode
  global pirClassesComponent pirClassesModule g_NM_classTypes 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "\ndeleteClassInstance: `$backtrace'"
  # puts stderr "deleteClassInstance: nodeClassName $nodeClassName nodeInstanceName $nodeInstanceName "
  set reportNotFoundP 0; set oldvalMustExistP 0
  set pirNodeIndex [assoc-array $nodeInstanceName g_NM_instanceToNode]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]

  # delete from g_NM_classToInstances
  # g_NM_paletteTypes + component/module user defined classes
  set currentEntries [assoc-array $nodeClassName g_NM_classToInstances]
  adel $nodeInstanceName currentEntries
  if {[string match $currentEntries ""] && (! $g_NM_canvasRedrawP)} {
    adel-array $nodeClassName g_NM_classToInstances
    unsetClass $nodeClassType $nodeClassName
    lremoveClasses $nodeClassType $nodeClassName 
  } else {
    arepl-array $nodeClassName $currentEntries g_NM_classToInstances
  }

  if {[string match $g_NM_schematicMode "layout"] && \
          ([expr {[llength $parentNodeGroupList] - 1}] == $g_NM_groupLevelSave)} {
    # this handles abstraction, relation,structure, symbol, & value classes
    # as well as component and module
    getDependentClassNameList $nodeClassType $nodeClassName $pirNodeIndex \
        dependentClassTypeList dependentClassNameList
    foreach dependentClassType $dependentClassTypeList dependentClassName \
        $dependentClassNameList {
      set currentEntries [assoc-array $dependentClassName g_NM_classToInstances \
                              $reportNotFoundP]
      if {[lsearch -exact {component module} $dependentClassType] == -1} {
        adel $nodeInstanceName currentEntries $reportNotFoundP 
        if {[string match $currentEntries ""] && (! $g_NM_canvasRedrawP)} {
          adel-array $dependentClassName g_NM_classToInstances
          updateDependentClasses $dependentClassType $dependentClassName "delete"
        } else {
          arepl-array $dependentClassName $currentEntries g_NM_classToInstances \
              $reportNotFoundP 
        }
      } else {
        if {[string match $currentEntries ""] && (! $g_NM_canvasRedrawP)} {
          updateDependentClasses $dependentClassType $dependentClassName "delete"
        }
      }
    }
  }

  # delete from g_NM_nodeGroupToInstances
  set nodeGroupName [assoc nodeGroupName pirNode($pirNodeIndex)]
  if {[string match $nodeGroupName ""]} {
    set nodeGroupName "root"
  }
  set currentEntries [assoc-array $nodeGroupName g_NM_nodeGroupToInstances]
  adel $nodeInstanceName currentEntries
  if {[string match $currentEntries ""]} {
    adel-array $nodeGroupName g_NM_nodeGroupToInstances
  } else {
    arepl-array $nodeGroupName $currentEntries g_NM_nodeGroupToInstances
  }

  # delete from g_NM_canvasIdToPirNode
  set currentEntries [assoc-array $canvas g_NM_canvasIdToPirNode]
  # puts stderr "deleteClassInstance: B currentEntries $currentEntries"
  set canvasId [assoc canvasId pirNode($pirNodeIndex)]
  # puts stderr "deleteClassInstance: canvasId $canvasId pirNodeIndex $pirNodeIndex"
  adel-exact $canvasId currentEntries
  # puts stderr "deleteClassInstance: A currentEntries $currentEntries"
  if {[string match $currentEntries ""]} {
    adel-array $canvas g_NM_canvasIdToPirNode
  } else {
    arepl-array $canvas $currentEntries g_NM_canvasIdToPirNode
  }

  # delete from g_NM_windowPathToPirNode
  set currentEntries [assoc-array $canvas g_NM_windowPathToPirNode]
  # puts stderr "deleteClassInstance: B currentEntries $currentEntries"
  set canvasId [assoc canvasId pirNode($pirNodeIndex)]
  # puts stderr "deleteClassInstance: canvasId $canvasId pirNodeIndex $pirNodeIndex"
  adel-exact $window currentEntries
  # puts stderr "deleteClassInstance: A currentEntries $currentEntries"
  if {[string match $currentEntries ""]} {
    adel-array $canvas g_NM_windowPathToPirNode 
  } else {
    arepl-array $canvas $currentEntries g_NM_windowPathToPirNode
  }
  # puts stderr "deleteClassInstance: nodeInstanceName $nodeInstanceName \
  #              nodeClassType $nodeClassType pirNodeIndex $pirNodeIndex"
  adel-array $nodeInstanceName g_NM_instanceToNode
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  if {[string match $nodeClassType "component"]} {
    adel-array $nodeInstanceName g_NM_componentToNode
  } elseif {[string match $nodeClassType "module"]} {
    adel-array $nodeInstanceName g_NM_moduleToNode
  }
  if {[string match $nodeClassType "component"] || \
          [string match $nodeClassType "module"]} {
    set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
    if {([llength $parentNodeGroupList] - 1) == $g_NM_groupLevelSave} {
      adel $nodeInstanceName g_NM_includedModules
      # puts stderr 
      #     "deleteClassInstance: removed $nodeInstanceName from g_NM_includedModules"
    }
  }
  if {! $renameP} {
    set lenParentNodeGroupList [llength [getCanvasRootInfo g_NM_parentNodeGroupList]]
    if {[string match $nodeClassType "terminal"] && \
            ([string match $g_NM_classDefType module] || \
                 [string match $g_NM_classDefType component]) && \
            ([llength [assoc parentNodeGroupList pirNode($pirNodeIndex)]] == \
                 $lenParentNodeGroupList)} {
      # delete top-level terminals from root node input_terminals, output_terminals
      modifyDefmoduleTerminalsAttributesList $pirNodeIndex lremove
    }
  }
}


## 15feb96 wmt: new
proc notAvailable { { msg "" } } {

  set dialogList [list tk_dialog .d "Not Available Yet" \
      "
$msg 
" warning 0 {DISMISS}]
    eval $dialogList
}


## equality checker for component terminals
## 25feb96 wmt: new
## 11mar96 wmt: do sub-set checking
## 06may96 wmt: trim prefix and suffix blanks from type
## 16may96 wmt: type is now e.g. {OUT <type-name>}, rather than <type-name>
## 19jun96 wmt: allow a port to connect to anything
## 07oct96 wmt: only check types
proc componentTerminalsEqualP { fromTerminalList toTerminalList } {

  # set str "componentTerminalsEqualP fromTerminalList $fromTerminalList"
  # puts stderr "$str toTerminalList $toTerminalList"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "componentTerminalsEqualP: $backtrace"
  ## check types only
  set fromType [getTerminalType $fromTerminalList]
  set fromType [string trim $fromType " "]
  set toType [getTerminalType $toTerminalList]
  set toType [string trim $toType " "]
  # puts stderr "componentTerminalsEqualP: fromType `$fromType' toType `$toType'"
  if {[string match $fromType $toType]} {
    set returnVal 1
  } else {
    # puts -nonewline stderr "componentTerminalsEqualP: "
    # puts -nonewline stderr "fromType \"$fromType\"; "
    # puts -nonewline stderr "toType \"$toType\""
    # puts stderr " -- TYPE MISMATCH\!"
    set returnVal 0
  }
  return $returnVal
}


## delete child windows of root window
## 18mar96 wmt: new
## 26jul96 wmt: reset g_NM_nodeStateWindowList 
proc deleteAllPopUpWindows { rootWindow {type ""} {canvasRootId 0} } {
  global g_NM_menuStem 

  foreach wind [winfo children $rootWindow] {
    destroy $wind
  }
  set canvasRoot [getCanvasRoot $canvasRootId]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  if {[string match $type "viewDialogs"]} {
    $menuRoot.tools.m entryconfigure "Delete All View Dialogs" \
        -state disabled
  }
}


## delete all "view" dialogs
## 04oct99 wmt: new
proc deleteAllViewDialogs {} {
  global g_NM_nodeTypeRootWindow

  foreach dialogPath [winfo children $g_NM_nodeTypeRootWindow] {
    # set str "deleteAllViewDialogs: dialogPath $dialogPath"
    # puts stderr "$str state [lindex [${dialogPath}.buttons.ok config -state] 4]"
    set dialogButtonPath ".buttons"
    if {[regexp "editModeTransition" $dialogPath]} {
      append dialogButtonPath ".save"
    } else {
      append dialogButtonPath ".ok"
    }
    if {[string match [lindex [${dialogPath}$dialogButtonPath config -state] 4] \
             "disabled"]} {
      destroy $dialogPath
    }
  }
}


## raise Stanley main window, terminal windows, state windows, &
## state-diagram windows after being buried
## 20mar96 wmt: new
## 26jul96 wmt: add g_NM_componentStateRootDiagramWindow and
##              g_NM_paletteItemRootWindow 
proc raiseStanleyWindows { {canvasRootId 0} } {
  global g_NM_termtypeRootWindow 
  global g_NM_nodeTypeRootWindow
  global g_NM_schematicMode g_NM_statePropsRootWindow
  global g_NM_canvasRootIdCnt g_NM_componentFaultDialogRoot
  global g_NM_menuStem g_NM_advisoryRootWindow
  global g_NM_editPrefsRootWindow g_NM_scenarioNameRootWindow
  global g_NM_scenarioDialogRoot g_NM_jmplCompilerRootWindow
  global g_NM_editDSColorPrefsRootWindow g_NM_newWorkspaceRootWindow

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "raiseStanleyWindows: `$backtrace'"

  # in operational mode, do not change visibility of master and slave
  # canvases -- just the terminal type, & component state windows
  ## this is very slow -- 
#   if {[string match $g_NM_schematicMode layout] || \
#           ([string match $g_NM_schematicMode operational] && \
#                ($g_NM_canvasRootIdCnt < 2))} {
#     raise .master
#   }
  if {[winfo exists .about]} {
    raise .about
  }
  if {[winfo exists .help]} {
    raise .help
    foreach wind [winfo children .help] {
      raise $wind
    }
  }
  if {[string match $g_NM_schematicMode operational]} {
    foreach wind [winfo children $g_NM_statePropsRootWindow] {
      raise $wind
    }
    if {[winfo exists $g_NM_scenarioDialogRoot]} {
      raise $g_NM_scenarioDialogRoot
    }
  }
  # defmodule class editing dialog
  set wind .cfilename
  if {[winfo exists $wind]} {
    raise $wind
  }
  # Edit->Preferences dialog
  set wind $g_NM_editPrefsRootWindow
  if {[winfo exists $wind]} {
    raise $wind
  }
  # Edit->Display State Color Preferences dialog
  set wind $g_NM_editDSColorPrefsRootWindow
  if {[winfo exists $wind]} {
    raise $wind
  }
  # File->New Workspace dialog
  set wind $g_NM_newWorkspaceRootWindow
  if {[winfo exists $wind]} {
    raise $wind
  }
  foreach wind [winfo children $g_NM_nodeTypeRootWindow] {
    raise $wind
  }
  # Scenario Manager File->Save Scenario asks user for a file name
  if {[winfo exists $g_NM_scenarioNameRootWindow]} {
    raise $g_NM_scenarioNameRootWindow 
  }

  # display state legend window is hung under advisory root
  foreach wind [winfo children $g_NM_advisoryRootWindow] {
    raise $wind
  }

  if {[winfo exist $g_NM_jmplCompilerRootWindow]} {
    foreach wind [winfo children $g_NM_jmplCompilerRootWindow] {
      raise $wind
    }
  }
    
  update
}


## delete files from multiple sub-directories of input directory
## 25apr96 wmt: new
## 02oct96 wmt: do not delete files from terminals subDir
proc deleteFilesFromSubDirectories { directoryPath sourceExt} {

  set doNotDeleteDirs [list "CVS" [preferred terminals_directory]]
  set sub_dirs [glob -nocomplain $directoryPath/*]
  foreach dir_path $sub_dirs {
    if {[file isdirectory $dir_path]} {
      set dir [file tail $dir_path]
      if {[lsearch -exact $doNotDeleteDirs $dir] == -1} {
        pushd $directoryPath/$dir
        file delete *$sourceExt
        popd
      }
    }
  }
}


## strip off /tmp_mnt prefix if it is present
## 11may96 wmt: new
proc strip_prefixes { path } {
  if {[string match [string range $path 0 7] "/tmp_mnt"]} {
    set path [string range $path 8 end]
  }
  return $path
}


## display . root window title
## 07jun96 wmt: new
## 16sep96 wmt: revise to include defmodule name as well
##              as schematic file name
## 23nov96 wmt: put current module after mission
## 02dec97 wmt: move title from window title bar to title label
proc displayDotWindowTitle { { canvasRootId 0 } } {
  global g_NM_currentNodeGroup STANLEY_MISSION
  global g_NM_schematicMode pirNode g_NM_classDefType
  global g_NM_instanceToNode g_NM_canvasList
  global g_NM_livingstoneDefmoduleName g_NM_livingstoneDefmoduleNameVar
  global g_NM_fileOperation g_NM_currentCanvas
  global g_NM_rootInstanceName g_NM_toolsL2ViewerP
  global g_NM_livingstoneDefcomponentName g_NM_groundProcessingUnitP 
  global g_NM_selectedTestScope g_NM_livingstoneDefcomponentFileName
  global g_NM_livingstoneDefmoduleFileName g_NM_vmplTestModeP
  global g_NM_selectedTestModule env g_NM_l2ToolsP 
  global g_NM_testScenarioName g_NM_l2toolsCurrentTime

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "displayDotWindowTitle: `$backtrace'"
  # puts stderr "displayDotWindowTitle g_NM_currentCanvas $g_NM_currentCanvas"
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  set canvasRoot {}
  getCanvasRootId $currentCanvas canvasRoot
  set windowTitle "STANLEY"
  if {$g_NM_toolsL2ViewerP} {
    append windowTitle " Viewer"
  } elseif {$g_NM_groundProcessingUnitP} {
    append windowTitle " GPU VIEWER"
  } elseif {[string match $g_NM_schematicMode "layout"] || $g_NM_vmplTestModeP} {
    # append windowTitle " VMPL"
    append windowTitle " VJMPL"
  } else {
    append windowTitle " OPS"
  }
  if {$canvasRootId > 0} {
    append windowTitle " ([string trimleft $canvasRoot .])"
  }
  if {[info exists env(GROUND_UNIX_IDENT)]} {
    append windowTitle " - $env(GROUND_UNIX_IDENT)"
  }
  wm title $canvasRoot $windowTitle

  $canvasRoot.header.center configure -text [lindex [preferred STANLEY_USER_DIR] 0]

  set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
  set titleLeft ""; set titleRight ""
  # puts stderr "displayDotWindowTitle: g_NM_classDefType $g_NM_classDefType"
  ## do not output title for root for component & module
  if {(! [string match $currentNodeGroup "root"]) && \
          (! [string match $g_NM_classDefType "<type>"])} {
    set longDefType $g_NM_classDefType

    if {[string match $g_NM_classDefType component]} {
      set className $g_NM_livingstoneDefcomponentName
      if {[string match $g_NM_livingstoneDefcomponentFileName ""]} {
        set className "<unspecified>"
      }
      append titleLeft " [capitalizeWord $longDefType]: $className"
    } elseif {[string match $g_NM_classDefType module]} {
      set pirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
      # puts stderr "displayDotWindowTitle: pirNodeIndex $pirNodeIndex"
      set longDefType [assoc nodeClassType pirNode($pirNodeIndex)]
      set className [assoc nodeClassName pirNode($pirNodeIndex)]
      if {[string match $currentNodeGroup \
               $g_NM_livingstoneDefmoduleNameVar] && \
              [string match $g_NM_livingstoneDefmoduleFileName ""]} {
        if {! $g_NM_vmplTestModeP} {
          set className "<unspecified>"
        } else {
          set className $g_NM_selectedTestModule
        }
      }
      if {! [string match $currentNodeGroup $g_NM_rootInstanceName]} {
        set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
        set currentNodeGroupTmp [getExternalNodeName $nodeInstanceName]
        append titleLeft "  [capitalizeWord $longDefType]: $className "
        append titleLeft " Instance: $currentNodeGroupTmp      "
      } else {
        append titleLeft "  [capitalizeWord $longDefType]: $className "
      }
    }
  }
  if {([string match $g_NM_schematicMode layout] && $g_NM_l2ToolsP) \
           || $g_NM_vmplTestModeP} {
    append titleRight " Scope: $g_NM_selectedTestScope  "
    # scenario name is now in Scenario Window
    # append titleRight " Scenario: $g_NM_testScenarioName  "
    append titleRight " Time: $g_NM_l2toolsCurrentTime  "
  }
  $canvasRoot.title.left config -text $titleLeft 
  $canvasRoot.title.right config -text $titleRight 
  # puts stderr "displayDotWindowTitle: titleLeft $titleLeft titleRight $titleRight"

  if {! [string match $g_NM_rootInstanceName ""]} {
    # update canvas legend
    set updateP 1
    displayCanvasLegendText $updateP
  }
  update
}


## text for top-level canvas legend
## read-only and modified indicators
## 03jul97 wmt: new
proc displayCanvasLegendText { { updateP 0 } } {
  global g_NM_schematicMode g_NM_canvasList 
  global pirFileInfo g_NM_currentNodeGroup
  global g_NM_rootInstanceName g_NM_vmplTestModeP 

  set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup] 
  set topLevelNodeP [expr {[string match $g_NM_rootInstanceName \
                                $currentNodeGroup]}]
  # puts stderr "displayCanvasLegendText: topLevelNodeP $topLevelNodeP"
  set text ""
  set fg [preferred StanleyLegendBgColor] 
  if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
    if {[componentModuleDefReadOnlyP] || \
            ((! $topLevelNodeP) && (! $g_NM_vmplTestModeP)) || \
            $g_NM_vmplTestModeP} {
      append text "read-only"
    } elseif {$pirFileInfo(scm_modified)} {
      append text "modified"
    }
    if {$updateP} {
      foreach canvasPath $g_NM_canvasList {
        append canvasPath .bottom.viewlabel
        $canvasPath config -text $text
      }
    }
  }
  return $text
}


## put either module_class or component_class into list
## 27sep96 wmt: use nodeClassType, rather than component_class/module_class 
##              handle terminal type
## 04jun97 wmt: add attribute
proc addClassTypeToList { classType className inputListName } {
  upvar $inputListName inputList

  if {[string match $classType "component"]} {
    ;
  } elseif {[string match $classType "module"]} {
    ;
  } elseif {[string match $classType "terminal"]} {
    ;
  } elseif {[string match $classType "attribute"]} {
    ;
  } elseif {[string match $classType "mode"]} {
    ;
  } else {
    puts stderr "addClassTypeToList: classType $classType not handled\!"
    return 0
  }
  acons nodeClassType $classType inputList
  return $classType
}

  
## standard pirWarning msg
## 16jun96 wmt: new
proc standardMouseClickMsg { { canvasRootId 0 } } {
  global g_NM_schematicMode g_NM_currentNodeGroup pirNode
  global g_NM_instanceToNode pirNodes g_NM_rootInstanceName
  global g_NM_processingFileOpenP g_NM_inhibitPirWarningP
  global g_NM_scenarioDialogRoot 

#   set backtrace ""; getBackTrace backtrace
#   puts stderr "\nstandardMouseClickMsg: `$backtrace'"
  if {$g_NM_processingFileOpenP} {
    # discard event call from button <Enter> & <Leave> bindings
    return
  }
  # do not turn off g_NM_inhibitPirWarningP, since it will allow
  # pirWarning severity 1 to be erased
  if {$g_NM_inhibitPirWarningP} {
    return
  }
  # set g_NM_inhibitPirWarningP 0
  if {[string match $g_NM_schematicMode "layout"] && \
          [string match $g_NM_rootInstanceName \
               [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]] && \
          (! [componentModuleDefReadOnlyP])} {
    set msg "<Mouse-L click>: reset selection;  <Mouse-L drag>: select nodes"
    set msg2 ""
  } else {
    #     set currentNodeGroup [getCanvasRootInfo g_NM_currentNodeGroup $canvasRootId]
#     if {[string match $currentNodeGroup root]} {
#       set nodeClassType module
#     } else {
#       set pirNodeIndex [assoc-array $currentNodeGroup g_NM_instanceToNode]
#       set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
#     }
#     if {[string match $nodeClassType module]} {
#       set msg "<Mouse-L>: show mode or type;"
#     } else {
#       set msg ""
#     }
    set msg ""
    set msg2 ""
  }
  if {(! [info exists pirNodes]) || ([llength $pirNodes] == 0)} {
    set msg ""; set msg2 ""
  }
  set severity 0
  pirWarning $msg $msg2 $severity $canvasRootId
  if {[winfo exists $g_NM_scenarioDialogRoot]} {
    scenarioMgrWarning "" $severity $canvasRootId 
  }
}


## generate a unique integer for pirNode & pirEdge arrays
## uniquePirNodeIndex & uniquePirEdgeIndex & uniqueWindowName
proc pirGenInt {} {
  global pirGenInt_global

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "pirGenInt: `$backtrace'"
  if [info exists pirGenInt_global] {
    # puts stderr "pirGenInt: pirGenInt_global [expr 1 + $pirGenInt_global]"
    return [incr pirGenInt_global]
  } else {
    return [set pirGenInt_global 1]
  }
}
    
## generate a unique variable name. Optional argument replaces symbol prefix
## 15sep96 wmt: add optional arg separator 
proc pirGenSym { { s "gensym"} { separator "" } } {
  global pirGenSym_global
  
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "pirGenSym: `$backtrace'"
  if [info exists pirGenSym_global] {
    if {$s != "gensym"} {
      set pirGenSym_global $s
    }
  } else {
    set pirGenSym_global $s
  }
  return [format "%s%s%s" $pirGenSym_global $separator [pirGenInt]] 
}
    

## multiple canvases each are numbered unrelated to the others, so we must
## ensure a unique number for pirNode & pirNodes
## maybeNum comes from tcl window canvas id which continually counts
## for every window which has been created in that canvas
## 29jun96 wmt: new
proc uniquePirNodeIndex { maybeNum } {
  global pirNodes pirGenInt_global

  set newNum $maybeNum
  # puts stderr "uniquePirNodeIndex: maybeNum $maybeNum - "
  while {1} {
    if {[lsearch -exact $pirNodes $newNum] >= 0} {
      # puts stderr "                   newNum $newNum is not unique\!"
      set newNum [pirGenInt]
      # set str "uniquePirNodeIndex: maybeNum $maybeNum newNum $newNum"
      # puts stderr "$str pirGenInt_global $pirGenInt_global pirNodes $pirNodes"
    } else {
      break
    }
  }
  return $newNum
}


## multiple canvases each are numbered unrelated to the others, so we must
## ensure a unique number for pirEdge & pirEdges
## 01jul96 wmt: new
proc uniquePirEdgeIndex { maybeNum } {
  global pirEdges pirGenInt_global

  set newNum $maybeNum
  # puts stderr "uniquePirEdgeIndex: maybeNum $maybeNum - "
  while {1} {
    if {[lsearch -exact $pirEdges $newNum] >= 0} {
      # puts stderr "                   newNum $newNum is not unique\!"
      set newNum [pirGenInt]
      # set str "uniquePirEdgeIndex: maybeNum $maybeNum newNum $newNum"
      # puts stderr "$str pirGenInt_global $pirGenInt_global pirEdges $pirEdges"
    } else {
      break
    }
  }
  return $newNum
}


## generate unique window path, which does not already exist
## 13may97 wmt: new
proc uniqueWindowName { root } {

  while {1} {
    set winname [pirGenSym "w"]
    if {! [winfo exists "$root.$winname"]} {
      break
    }
  }
  return $winname
}


## generate a unique id for edit/view dialogs
## 14aug97 wmt: new
proc uniqueDialogId {} {
  global uniqueDialogId_global

  # puts stderr "uniqueDialogId: [expr 1 + $uniqueDialogId_global]"
  if [info exists uniqueDialogId_global] {
    return [incr uniqueDialogId_global]
  } else {
    return [set uniqueDialogId_global 1]
  }
}
    

## add an instance of an edge to canvas oriented db
## 02jul96 wmt: new
proc addEdgeInstance { canvasId pirEdgeIndex currentCanvas } {
  global g_NM_canvasIdToPirEdge g_NM_schematicMode pirEdge
  global g_NM_classToEdgeInstances pirNode 

  # add to g_NM_canvasIdToPirEdge
  set assocReportNotFoundP 0
  set currentEntries [assoc-array $currentCanvas g_NM_canvasIdToPirEdge \
                          $assocReportNotFoundP]
  if {[string match "" $currentEntries]} {
    set reportNotFoundP 0; set oldvalMustExistP 0
  } else { set reportNotFoundP 1; set oldvalMustExistP 1 }
  lappend currentEntries $canvasId $pirEdgeIndex
  arepl-array $currentCanvas $currentEntries g_NM_canvasIdToPirEdge $reportNotFoundP \
      $oldvalMustExistP
  # puts stderr "addEdgeInstance: canvasId $canvasId pirEdgeIndex $pirEdgeIndex"

  # update type dependent classes, if at schematic top-level
  if {($g_NM_schematicMode == "layout") && \
          ($currentCanvas == ".master.canvas.?name.c")} {
    # this handles abstraction classes
    set abstractionType [assoc abstractionType pirEdge($pirEdgeIndex)]
    set nodeFromName [assoc nodeInstanceName pirNode([assoc nodeFrom \
                                                          pirEdge($pirEdgeIndex)])]
    set nodeToName [assoc nodeInstanceName pirNode([assoc nodeTo \
                                                          pirEdge($pirEdgeIndex)])]
     updateEdgeDependency $pirEdgeIndex $nodeFromName $nodeToName $abstractionType \
                                $currentCanvas $canvasId 
  }
}


## delete an instance of an edge to canvas oriented db
## this does not depend on either the from or to pirNodes existing
## 02jul96 wmt: new
proc deleteEdgeInstance { canvasId pirEdgeIndex currentCanvas abstractionType \
                            nodeFromToName } {
  global g_NM_canvasIdToPirEdge pirEdge g_NM_classToEdgeInstances
  global g_NM_schematicMode g_NM_canvasRedrawP 

  set reportNotFoundP 1; set returnOldvalP 1
  # delete from g_NM_canvasIdToPirEdge
  set currentEntries [assoc-array $currentCanvas g_NM_canvasIdToPirEdge]
  set oldVal [adel $canvasId currentEntries \
                  $reportNotFoundP $returnOldvalP]
  if {$oldVal == $pirEdgeIndex} {
    arepl-array $currentCanvas $currentEntries g_NM_canvasIdToPirEdge
    # puts stderr "deleteEdgeInstance: deleted canvasId $canvasId pirEdgeIndex $pirEdgeIndex"
  } else {
    set str "deleteEdgeInstance: canvasId $canvasId on canvas $currentCanvas was NOT"
    puts stderr "$str pirEdgeIndex $pirEdgeIndex"
  }


  # update type dependent classes, if at schematic top-level
  if {($g_NM_schematicMode == "layout") && \
          ($currentCanvas == ".master.canvas.?name.c") && \
          ($abstractionType != "equal")} {
    # this handles abstraction classes
    getDependentClassNameList "edge" "edge" "" \
        dependentClassTypeList dependentClassNameList $abstractionType $nodeFromToName 
    set dependentClassType [lindex $dependentClassTypeList 0]
    set dependentClassName [lindex $dependentClassNameList 0]
    # abstractionType is not "equal"
    # delete from g_NM_classToEdgeInstances
    # puts stderr "deleteEdgeInstance: dependentClassName $dependentClassName"
    # puts stderr "deleteEdgeInstance: g_NM_classToEdgeInstances [array names g_NM_classToEdgeInstances]"
    # check for non-repeatable error, i.e. dependentClassName = ""
    if {[string length $dependentClassName] > 0} {
      set currentEntries [assoc-array $dependentClassName g_NM_classToEdgeInstances \
                              $reportNotFoundP]
      adel "$currentCanvas.$canvasId" currentEntries
      if {[string match $currentEntries ""] && (! $g_NM_canvasRedrawP)} {
        adel-array $dependentClassName g_NM_classToEdgeInstances
        updateDependentClasses $dependentClassType $dependentClassName "delete"
      } else {
        arepl-array $dependentClassName $currentEntries g_NM_classToEdgeInstances 
      }
    }
  }
}



## LISP COMPATIBILITY PROCS
########################################################

## convert Lisp list structure to Tcl list structure
## 23nov96 wmt: new
proc lispListToTcl { lispListRef { enterListP 1 } } {
  upvar $lispListRef lispList

  ## convert Lisp list syntax to Tcl list syntax
  regsub -all "\\\(" $lispList "\{" lispTclListTmp 
  regsub -all "\\\)" $lispTclListTmp  "\}" lispList
  set lispList [string trim $lispList " "]
  if {$enterListP} {
    # there is a "hidden" pair of {} around the form
    set lispList [lindex $lispList 0]
  }
}


## convert Tcl list structure to Lisp list structure
## 07may97 wmt: new
proc tclListToLisp { tclListRef } {
  upvar $tclListRef tclList

  if {[string match $tclList "{}"]} {
    set tclList ""
  } else {
    ## convert Tcl list syntax to Lisp list syntax
    regsub -all "\\\{" $tclList "\(" listTmp 
    regsub -all "\\\}" $listTmp  "\)" tclList
  }
}


## convert arbitrary tcl "list" to Lisp-style tcl syntax
## 09may97 wmt: new
proc lispify_tcl_list { tcl_listRef } {
  upvar $tcl_listRef tcl_list

  if {[string match $tcl_list ""]} {
    set tcl_list "\{\}"
  } elseif {[llength $tcl_list] > 1} {
    set tcl_list "\{$tcl_list\}"
  }
}

########################################################

## get random number
## will be available in Tcl8.0 as rand()
## from comp.lang.tcl # 62126
set _ran [pid]
proc random {range} {
  global _ran

  set _ran [expr {($_ran * 9301 + 49297) % 233280}]
  return [expr {int($range * ($_ran / double(233280)))}]
}


## capitalize word
## 11jun97 wmt: new
proc capitalizeWord { word } {

  set firstLetter [string toupper [string range $word 0 0]]
  return ${firstLetter}[string tolower [string range $word 1 end]]
}


## return parent path of widget pathname
## 27aug97 wmt: new
proc widgetPathParent { path } {

  set index [string last "." $path]
  return [string range $path 0 [expr {$index - 1}]]
}


## return descents of widget pathname
## 29aug97 wmt: new
proc widgetPathDescendents { path } {

  set index [string first "." [string range $path 1 end]]
  return [string range $path [expr {1 + $index}] end]
}


## return canvas path based on canvas root id
## 29aug97 wmt: new
proc convertCanvasPath { canvas canvasRootId } {

  set canvasRoot [getCanvasRoot $canvasRootId]
  if {[string match [string range $canvas 1 6] "canvas"]} {
    set canvas "$canvasRoot$canvas"
  } else {
    set canvas "$canvasRoot[widgetPathDescendents $canvas]"
  }
  return $canvas
}


## get group name from widget path
## .slave_2.canvas.(rt-module~sru-a).c
## 30aug97 wmt: new
proc getGroupNameFromWidgetPath { widgetPath } {

  set index [string first "canvas" $widgetPath]
  set shortPath [string range $widgetPath [expr {$index + 7}] end]
  set index2 [string first "." $shortPath] 
  return [string range $shortPath 0 [expr {$index2 - 1}]]
}


## keep dialog whose default x,y is taken from the mouse cursor position,
## on the screen
##13oct97 wmt: new
proc keepDialogOnScreen { window { xPos -1 } { yPos -1 } } {
  global g_NM_win32P 

  # puts stderr "keepDialogOnScreen xPos $xPos yPos $yPos"
  wm withdraw $window 
  update idletasks
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
  if {$xPos == -1} {
    set xPos [expr {[winfo pointerx $currentCanvas] + 20}]
  }
  if {$yPos == -1} {
    set yPos [winfo pointery $currentCanvas]
  }
  set canvasWidth [winfo reqwidth $window]
  set canvasHeight [winfo reqheight $window]

  if {$yPos != 0} {
    set canvasHeight [expr {round( $canvasHeight * 1.15)}]
    if {($yPos + $canvasHeight) > [winfo screenheight $window]} {
      set yPos [expr {[winfo screenheight $window] - $canvasHeight}]
      if {$yPos < 0} {
        set yPos 0
      }
    }
  }
  set canvasWidth [expr {round( $canvasWidth * 1.1)}]
  if {($xPos + $canvasWidth) > [winfo screenwidth $window]} {
    set xPos [expr {[winfo screenwidth $window] - $canvasWidth}]
    if {$xPos < 0} {
      set xPos 0
    }
  }
  wm geometry $window +$xPos+$yPos
  wm deiconify $window 
  if {$g_NM_win32P} {
    update
    raise $window
  }
}


## convert ascii number to char
## 02dec97 wmt: new
proc asciiToChar { asciiNum } {
  
  return [format "%c" $asciiNum]
}


## convert char to ascii number 
## 02dec97 wmt: new
proc charToAscii { char } {

  scan $char "%c" asciiNum 
  return $asciiNum
}


## is string an integer
## 02dec97 wmt: new
proc integerStringP { string } {

  set numericP 1
  set stringLength [string length $string]
  for {set i 0} {$i < $stringLength} {incr i} {
    set asciiNum [charToAscii [string index $string $i]]
    if {($asciiNum < 48) || ($asciiNum > 57)} {
      set numericP 0
      break
    }
  }
  return $numericP
}


## wait for the file to be created
## 26oct98 wmt: new
proc waitForFileToBeWritten { pathname } {

  set firstP 1; set fileExistsP 0; set oldFileSize 0
  set filePreExistsP [file exists $pathname] 
  while {1} {
    # if the file is not pre-existing,
    # check for two successive file sizes are the same to insure
    # that the file is completly written before sourcing it
    if {[set fileExistsP [file exists $pathname]] && \
            [expr {$oldFileSize == \
                       [set fileSize [file size $pathname]]}]} {
      break
    } else {
      if {! $filePreExistsP} {
        if {$firstP} {
          puts stderr "Waiting for $pathname to be written"
          set firstP 0
        }
        puts -nonewline stderr "."
      }
      if {$fileExistsP} {
        set oldFileSize $fileSize
      }
    }
    if {! $filePreExistsP} {
      after 1000 ;        # one second wait
    }
  }
  if {(! $firstP) && (! $filePreExistsP)} {
    puts stderr " Done."
  }
} 


## convert from ephemeris time to GMT time
## 18apr99 wmt: new
proc convertEphemerisTimeToGmtTime { ephemTime } {
 # acl
 # (setf et1998Epoch (+ .816d0 (encode-universal-time 56 58 11 1 1 1998 0))) 
 # 3.092644736816d+9
 # (setf clockEpoch (encode-universal-time 0 0 0 1 1 1970 0))
 # 2208988800
 # (setf et98ClockOffset (- 3.092644736816d+9 2208988800))
 set et98ClockOffset 883655936.816
 set gmtTime [expr {$ephemTime + $et98ClockOffset}]
 parseFloat $gmtTime gmtTimeWhole gmtTimeFraction
 set gmtTimeString [clock format $gmtTimeWhole -format "%Y-%jT%H:%M:%S" \
                        -gmt 1]
 return [append gmtTimeString ".$gmtTimeFraction"]
}


## append file contents to a string 
## 21mar00 wmt: new
proc appendFileToString { filePathname classJavaFormStringRef } {
  upvar $classJavaFormStringRef classJavaFormString

  set fid [open $filePathname r]
  while {[gets $fid inputLine] >= 0} {
    append classJavaFormString "$inputLine\n"
  }
  close $fid
}


## in a text widget, scroll a tagged line to the top of the window
## 11apr00 wmt
proc scrollTextTagToTop { textWidget tag } {
  
  set totalLines [$textWidget index end]
  set tagLine [lindex [$textWidget tag nextrange $tag 1.1] 0]
  # puts stderr "scrollTextTagToTop: tag $tag tags [$textWidget tag names]"
  $textWidget yview moveto [expr { $tagLine / $totalLines }] 
}


## in a text widget, scroll a tagged line to the middle of the window
## 03oct00 wmt
proc scrollTextTagToMiddle { textWidget tag } {
  
  set totalLines [$textWidget index end]
  set tagLine [lindex [$textWidget tag nextrange $tag 1.1] 0]
  # puts stderr "scrollTextTagToTop: tag $tag tags [$textWidget tag names]"
  $textWidget yview moveto [expr { $tagLine / $totalLines }]
  # at the top, now scroll up half way
  set windowLines [lindex [$textWidget config -height] 4]
  # puts stderr "scrollTextTagToMiddle: tagLine $tagLine totalLines $totalLines windowLines $windowLines"
  if {($windowLines / 2) < ($totalLines - $tagLine)} {
    $textWidget yview scroll [expr - {int ( $windowLines / 2)}] units
  }
}


## sort and format list of tokens
## 21feb01 wmt: new
proc sortAndFormatList { inputListRef outputStringRef {tokensPerLine 3} {sortP 1}} {
  upvar $inputListRef inputList
  upvar $outputStringRef outputString
  global g_NM_win32P

  if {$sortP} {
    set sortedInputList [lsort -ascii $inputList]
  } else {
    set sortedInputList $inputList
  }
  set outputString ""
  set tokenCnt 0
  foreach name $sortedInputList {
    if {$g_NM_win32P} {
      # if this is path name, convert back-slashes to slashes
      regsub "\\" $name "/" tmp; set name $tmp
    }
    append outputString $name
    incr tokenCnt
    if {$tokenCnt >= $tokensPerLine} {
      append outputString "\n"
      set tokenCnt 0
    } else {
      append outputString "  "
    }
  }
}


## check for input name being in reserved named list
## 18jan02 wmt
proc checkForReservedNames { inputName } {
  global g_NM_reservedNameList

  set foundP 0
  # reserved list built by fillPaletteLists
  if {[lsearch -exact $g_NM_reservedNameList $inputName] >= 0} {
    set dialogList [list tk_dialog .d "ERROR" \
                        "`$inputName' is a reserved name" \
                        error 0 {DISMISS}]
    eval $dialogList
    set foundP 1
  }
  return $foundP 
}






















