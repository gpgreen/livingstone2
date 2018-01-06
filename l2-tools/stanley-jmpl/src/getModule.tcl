# $Id: getModule.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## getModule.tcl

## pirGetModule returns an alist to be attached to the graphical node
## and used by the interface to prompt for needed parameters.  
## The fields are:
##   required - variables which must receive a value
##   optional - variables which may receive a value
##   fixed    - variable values displayed for information only.
## these three fields are simply paired lists {name value name value ..}
## where <name> is whatever label we want to prompt the user with.
##   outputLabels
##   inputLabels
## These two are simple lists of the dataflow labels for module IO
## Note, it is possible for a label to be "*".
## There is also a field
##   internal
## whose contents are arbitrary as far as the interface is concerned
## but which will be used by code generation.
## 18dec95 wmt: make optional, fixed, and required parameters null
## 30may96 wmt: cd to link directory, so relative path to .cfg can
##              be followed
## 10may97 wmt: strip type and description attributes from class_variables
proc pirGetModule {config_file return_alist} {
  upvar $return_alist ret
  global g_NM_class_variablesAttributeList
  global g_NM_class_variablesModuleAttList
  global g_NM_filterPirClassAttList

  # puts stderr "pirGetModule: config_file $config_file"
  set pwd [pwd]; set reportNotFoundP 0
  cd [file dirname $config_file]
  if {[file type $config_file] == "link"} {
    set config_file [file readlink $config_file]
  }
  set cfg [chomp_cfg $config_file]
  cd $pwd
  
  acons cfg_file [file tail $config_file] cfg
  acons internal $cfg ret

  # puts "pirGetModule before"; aputs stderr ret
  set internal [assoc internal ret]
  set class_variables [assoc class_variables internal]
  set attList $g_NM_class_variablesAttributeList
  if {! [string match [assoc module_class internal $reportNotFoundP] ""]} {
    set attList [concat $attList $g_NM_class_variablesModuleAttList]
  }
  # puts stderr "pirGetModule: attList $attList"
  foreach classVar $attList {
    set classVarForm [assoc $classVar class_variables $reportNotFoundP]
    if {! [string match $classVarForm ""]} {
      foreach att $g_NM_filterPirClassAttList {
        adel $att classVarForm $reportNotFoundP
      }
      arepl $classVar $classVarForm class_variables
    }
  }
  arepl class_variables $class_variables internal
  arepl internal $internal ret

  # puts "pirGetModule after"; aputs stderr ret
}

## Revert the parameters of selected modules to the state from
## the corresponding config file.  Useful if the config file has
## been changed or user wants to wipe out edited parameters.
## 13dec95 wmt: comment out check on change in number of inputs/outputs
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 01feb98 wmt: not used
proc pirRevertModule {} {
  global pirDisplay pirNodes pirEdges pirNode pirEdge pirClass

  set selectedNodes [assoc selectedNodes pirDisplay]
  if {$selectedNodes == {}} {
    pirWarning "No selected modules"
    return
  }
  foreach n $selectedNodes {
    set nodeClassName [assoc nodeClassName pirNode($n)]
    set int $pirClass($nodeClassName)
    set cfgFile [assoc cfg_file int]
    set newstuff {}
    pirGetModule "[cfgFilesDirectory]$cfgFile" newstuff
    arepl internal [assoc internal newstuff] pirNode($n)
    arepl required [assoc required newstuff] pirNode($n)
    arepl optional [assoc optional newstuff] pirNode($n)
    arepl fixed [assoc fixed newstuff] pirNode($n)
    arepl loop_index [assoc loop_index newstuff] pirNode($n)
  }
}


## Check to see if the I/O labels in a config file are consistent
## with the current terminal configuration on a node.
## (*'s may have been expanded and superterminals may have been formed.)
proc labels_changed {cfgLabels nodeLabels} {
    set inx 0
    set cfglab [lindex $cfgLabels 0]
    foreach lab_list $nodeLabels { 
	# Assume a list (though usually not)
	# Just in case there are superterminals
	foreach lab $lab_list {
	    if {$cfglab == "*"} {
		if {[string index $lab 0] == "*"} {
		    continue
		} else {
		    set cfglab [lindex $cfgLabels [incr inx]]
		}
	    } 
	    if {$cfglab != $lab} {
		return 1
	    } else {
		set cfglab [lindex $cfgLabels [incr inx]]
	    }
	}
    }
    if {$cfglab == "*"} {
	set cfglab [lindex $cfgLabels [incr inx]]
    }
    if {$cfglab == ""} {
	return 0
    } else {
	return 1
    }
}

## Give the user an optional parameter to name the module instance.
## This can be useful for readability and is needed when other
## modules require a pointer to this module_instance.
proc make_module_name_option {mod_class} {
    if [string match *_class $mod_class] {
	set node_name [string range $mod_class 0 \
                           [expr {[string length $mod_class] - 7}]]
    } else {
	set node_name "module"
    }
    set node_name [pirGenSym $node_name]
    set prompt "module_instance_name (identifier)"
    return [list $prompt $node_name]
}

## get_label_names accepts the OUTPUTS or INPUTS entry from a config file
## and extracts only the name fields, in order.
proc get_label_names {IOlist} {
    set len [llength $IOlist]
    set inx 0
    set name_list {}
    while {$inx < $len} {
	lappend name_list [lindex $IOlist $inx]
	incr inx 2
    }
    return $name_list
}

## make_entry_alist accepts a variables entry from a config file and
## formats a flat alist of <prompt, value> pairs for the user to fill in.
proc make_entry_alist {var_alist assoc_name alist_name 
                       {prompt_list {}}} {
    upvar $alist_name alist
    set inx 0
    set len [llength $var_alist]


    while {$inx < $len} {
	set name [lindex $var_alist $inx]
	incr inx
	set sub [lindex $var_alist $inx]
	incr inx
	set type [assoc type sub]
	if {$type == "loop_index"} {
	    ## The user isn't in a position to set loop index,
	    ## so we have to handle it ourselves.
	    lappend alist loop_index $name
	} else {
	    if {$type == "enumeration"} {
		set type "$type: [get_label_names [assoc values sub]]"
	    }
	    set val [assoc default sub]
	    lappend prompt_list "$name ($type)" $val
	}
    }
    acons $assoc_name $prompt_list alist
    ##return $prompt_list
}



## These prompts are also used as look-up keys during the compilation
## process, and so should be given a value only once.
proc Class_choose_message {} {
    return "Select output class:"
}
proc Type_choose_message {} {
    return "Select output type:"
}

## pirGetSensor returns an a_list of information about an IO port on 
## a graphical module.
## inputs:
##   The source node (a subscript to pirNode)
##   The output position on the source node
##   The target node 
##   The input position on the target node
## outputs:
##   adds a_list entries to  call-by-ref parameter return_list 
##
## A type check is performed.  If this edge is type-incompatible an
## error will be signalled.
## fields to add are REQUIRED OPTIONAL FIXED and INTERNAL - the first
## three containing flat alists for display similarly to those returned 
## by pirGetModule.
## Only FIXED and REQUIRED are currently used.
## The REQUIRED field has an entry only when the IO class is specified
## as an {or <multiple choices>}.
## The resulting list will be found later as the pirEdge(e) entry.
## 05jan96 wmt: check return value of pirTypeCheck, rather than 
##              signaling an error
## 19feb96 wmt: pass source_node_list rather than source_mod to pirTypeCheck, etc.
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 17may96 wmt: add portEdgeP to handle ports
## 03jan97 wmt: add optional arg checkTypesP 
proc pirGetSensor {source_node from_index from_location \
                       target_node to_index to_location return_list declNodeEdgeP \
                       { portEdgeType "" } { checkTypesP 1 } { documentation "" } \
                       { abstractionType "" } } {
  global pirNode g_NM_nodeTypeRootWindow
  upvar $return_list ret

  # puts stderr "pirGetSensor: portEdgeType `$portEdgeType'"
  # puts stderr "pirGetSensor: abstractionType $abstractionType checkTypesP $checkTypesP"
  # puts stderr "pirGetSensor: source_node $source_node target_node $target_node"
  # set str "pirGetSensor: from_index $from_index from_location $from_location"
  # puts stderr "$str to_index $to_index to_location $to_location"
  set source_node_list $pirNode($source_node)
  set nodeClassName [assoc nodeClassName pirNode($source_node)]
  set nodeClassType [assoc nodeClassType pirNode($source_node)]
  set source_mod [getClass $nodeClassType $nodeClassName]
  # puts stderr "pirGetSensor from labels [assoc ${from_location}putLabels source_node_list]"
  set sIOname [lindex [assoc ${from_location}putLabels source_node_list] $from_index]
  set sIOlocation ${from_location}puts
  if {$sIOname == ""} {
    error "No FROM label found for source node.\n \
        labels: [assoc ${from_location}putLabels source_node_list]\n \
        index: $from_index source_node $source_node"
  }
  # puts stderr "pirGetSensor: sIOname $sIOname sIOlocation $sIOlocation"
  set target_node_list $pirNode($target_node)
  set nodeClassName [assoc nodeClassName pirNode($target_node)]
  set nodeClassType [assoc nodeClassType pirNode($target_node)]
  set target_mod [getClass $nodeClassType $nodeClassName] 
  # puts "pirGetSensor to labels [assoc ${to_location}putLabels target_node_list]"
  set whichLabels ${to_location}putLabels
  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    set whichLabels outputLabels
  }
  set tIOname [lindex [assoc $whichLabels target_node_list] $to_index]
  # set str "pirGetSensor: whichLabels $whichLabels to_index $to_index"
  # puts stderr "$str target_node $target_node tIOname $tIOname"
  set tIOlocation ${to_location}puts
  if {$tIOname == ""} {
    error "No TO label found for target node.\n \
        labels: [assoc $whichLabels target_node_list]\n \
        index: $to_index target_node $target_node"
  }
  # puts "pirGetSensor: tIOname $tIOname tIOlocation $tIOlocation"

  if {$checkTypesP} {
    set id ${source_node}_${from_index}__${target_node}_${to_index}
    set dialogW $g_NM_nodeTypeRootWindow.pirGetSensor__${id}
    set dialogId [getDialogId $dialogW]
    global g_NM_optMenuWidgetValue_$dialogId
    set g_NM_optMenuWidgetValue_$dialogId $abstractionType
    global g_NM_edgeDocInput_$dialogId 
    set g_NM_edgeDocInput_$dialogId $documentation

    if {! [pirTypeCheck source_node_list $sIOname $sIOlocation \
               target_node_list $tIOname $tIOlocation $declNodeEdgeP \
               $portEdgeType $dialogW $source_node $target_node]} {
      return 0
    } else {
      set abstractionType [subst $[subst g_NM_optMenuWidgetValue_$dialogId]]
      set documentation [subst $[subst g_NM_edgeDocInput_$dialogId]]
    }
  }

  set ret [list abstractionType $abstractionType documentation $documentation]

  set sIOs [assoc $sIOlocation source_node_list]
  set sdesc [assoc $sIOname sIOs]
  # acons terminalFrom [list $sdesc] ret
  lappend ret terminalFrom $sdesc 

  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    set tIOs [assoc outputs target_node_list]
  } else {
    set tIOs [assoc $tIOlocation target_node_list]
  }
  set tdesc [assoc $tIOname tIOs]
  # acons terminalTo [list $tdesc] ret
  lappend ret terminalTo $tdesc 

  # puts "pirGetSensor ret $ret"
  return 1
}


## pirTypeCheck will return 0 if an edge between two IO ports
## is incompatible.
## inputs:
##   source module (call by ref)
##   IO name associated with source output port.
##   target module (call by ref)
##   IO name associated with target input port.
## 05jan96 wmt: return value from pirTypeCheck, rather than 
##              signaling an error; comment out compat_test with type option
## 19feb96 wmt: passing in complete node structs, not just internal
## 17may96 wmt: add portEdgeP to support ports
proc pirTypeCheck {sourceRef source_name source_location targetRef \
                       target_name target_location declNodeEdgeP \
                       portEdgeType dialogW nodeFrom nodeTo } {
  upvar $sourceRef source
  upvar $targetRef target

  if {[string index $source_name 0] == "*"} {
    set source_name "*"
  }
  if {[string index $target_name 0] == "*"} {
    set target_name "*"
  }

  set outs [assoc $source_location source]
  set terminalFrom [assoc $source_name outs]

  if {([string match $portEdgeType "portFromTo"]) || \
      ([string match $portEdgeType "port->From"])} {
    set ins [assoc outputs target]
  } else {
    set ins [assoc $target_location target]
  }
  set terminalTo [assoc $target_name ins]

  set returnValue [compat_test $terminalFrom $terminalTo $declNodeEdgeP $dialogW \
                      $nodeFrom $nodeTo]

  return $returnValue
}

		       
## Each description conforms to the nested a_list:    
##        class <IO_class>;
##        type <IO_type>;                 -- for set/item/async class
##        items                           -- only for event class
##          <simple_name> 
##            type <arg_type>;
##            description <string>;
##          ...

## For class and type fields in an IO description, make sure
## the input and output types are potentially compatible
## (have at least one common type/class element).
## 05jan96 wmt: change from invoking error to dialog/error
## 20feb96 wmt: allow illegal connections; inhibit type mismatch dialog
## 25feb96 wmt: remove class arg & check triplet values for equality
## 06oct96 wmt: added declNodeEdgeP arg to handle nodeType = terminal,
##              nodeClass = INPUT/OUTPUT/PORT-DECLARATION
proc compat_test { terminalFrom terminalTo declNodeEdgeP dialogW nodeFrom \
                     nodeTo } {
  global g_NM_inhibitEdgeTypeMismatchP g_NM_connectP

  # puts stderr "compat_test: terminalFrom $terminalFrom terminalTo $terminalTo"
  if {$terminalTo == ""} {
    set str "compat_test: invalid lists - terminalFrom $terminalFrom"
    puts stderr "$str terminalTo $terminalTo"
    return 0
  }
  set g_NM_connectP 0
  # default abstraction type is equal  - for structured and non-structured types
  # user can edit connection to change it to an allowable relation, if desired
  set abstractionType "equal"
  set documentation ""
  set dialogId [getDialogId $dialogW]
  global g_NM_optMenuWidgetValue_$dialogId
  global g_NM_edgeDocInput_$dialogId
  set g_NM_edgeDocInput_$dialogId $documentation
  if {$g_NM_inhibitEdgeTypeMismatchP || $declNodeEdgeP} {
    set g_NM_connectP 1
    set g_NM_optMenuWidgetValue_$dialogId $abstractionType 
  } elseif {[componentTerminalsEqualP $terminalFrom $terminalTo]} {
    set g_NM_connectP 1
    set g_NM_optMenuWidgetValue_$dialogId $abstractionType 
  } else {
    # types may be convertable, ask user for abstraction to make conversion
    set pirEdgeIndex 0
    askEdgeTypeAndDoc $pirEdgeIndex $dialogW $terminalFrom $terminalTo \
        $nodeFrom $nodeTo 

    if [winfo exists $dialogW] {
      ## allow tk_focusFollowsMouse to work
      ##grab set $dialogW
      tkwait window $dialogW
    }
#     if {$g_NM_connectP == 0} {  
#       set str "Type specification mismatch\n in connecting >> [list $terminalFrom]\n"
#       set str "$str to >> [list $terminalTo]" 
#       set dialogList [list tk_dialog .d "WARNING" $str warning 0 {DISMISS}]
#       eval $dialogList
#       puts stderr "compat_test: $str"
#     }
  }
  return $g_NM_connectP 
}


