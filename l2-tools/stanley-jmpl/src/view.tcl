# $Id: view.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## view.tcl - contains routines implementing the options
## found on the View menu - displaying internal structures.


## Create a text window containing the config file 
## information about a node.
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 01feb98 wmt: not used
proc pirShowModule {node} {
  global pirNode pirClass

  set nodeClassName [assoc nodeClassName pirNode($node)]
  set config $pirClass($nodeClassName)

  set w .showModule[pirGenInt]
  toplevel $w -class Dialog

  wm title $w "Module Description $node"
  button_row $w buts bottom 0\
      OK "destroy $w" 

  set name $w.text
  set scr $w.scroll

  text $name -relief raised -bd 2 -yscrollcommand "$scr set"
  scrollbar $scr -command "$name yview"
  pack $scr -side right -fill y
  pack $name -side left

  $name delete 1.0 end
  doConfigInserts $name $config ""
  $name config -state disabled
}


## Copy config file info into window in semi-formatted way
proc doConfigInserts {window list indent} {

    set len [llength $list]
    for {set inx 0} {$inx < $len} {incr inx 2} {
	set label [lindex $list $inx]
      set rest [lindex $list [expr {$inx + 1}]]
	if {[llength $rest] <= 1} {
	    $window insert end "$indent$label $rest\n"
	} else {
	    $window insert end "$indent$label\n"
	    doConfigInserts $window $rest "$indent    "
	}
    }
}


## Present a text file for the user's perusal. nothing fancy.
proc pirShowFile {filename} {
    if {![file exists $filename]} {
	error "File $filename does not exist."
    }

    set w .showfile[pirGenInt]
    toplevel $w -class Dialog

    wm title $w [file tail $filename]
    button_row $w buts bottom 0\
	    OK "destroy $w" 

    set name $w.text
    set scr $w.scroll

    text $name -relief raised -bd 2 -yscrollcommand "$scr set"
    scrollbar $scr -command "$name yview"
    pack $scr -side right -fill y
    pack $name -side left

    $name delete 1.0 end
    set fid [open $filename r]

    while {![eof $fid]} {
	$name insert end [read $fid]
    }
    close $fid
    $name config -state disabled
}

## Show the state of the pirate global variables.
## This is probably only useful for system debugging.
proc pirShowGlobals {} {
    set w .showglobals
    catch {destroy $w}
    toplevel $w -class Dialog

    wm title $w "Internal Variables"
    button_row $w buts bottom 0\
	    OK "destroy $w" 

    set name $w.text
    set scr $w.scroll

    text $name -relief raised -bd 2 -yscrollcommand "$scr set"
    scrollbar $scr -command "$name yview"
    pack $scr -side right -fill y
    pack $name -side left

    $name delete 1.0 end

    set globals [info globals pir*]

    foreach glo $globals {
	global $glo
	upvar #0 $glo bal
	if [catch {array names bal} elems] {
	    $name insert end "$glo : "
	    insertValues $name $bal
	} else {
	    foreach elem $elems {
		$name insert end "$glo\($elem\) : "
		insertValues $name $bal($elem)
		$name insert end "\n"
	    }
	}
	$name insert end "\n"
    }
    $name config -state disabled
}

## recursively insert alist structured data into a text window
proc insertValues {window vals {ind "   "}} {
    if {[string length $vals] < 75} {
	$window insert end "$vals\n"
    } else {
	$window insert end "\n"
	set len [llength $vals]
	set inx 0
	while {$inx < $len} {
	    $window insert end "$ind[lindex $vals $inx]  "
	    incr inx
	    if {$inx == $len} {
		$window insert end "\n"
		break
	    }
	    insertValues $window [lindex $vals $inx] "   $ind"
	    incr inx
	}
    }
}
    
## Display some useful information about any terminals
## that are currently selected (typically the endpoints of 
## an edge to check type compatibility).
proc pirShowTerminals {} {
    global pirDisplay pirNode pirEdge

    set w .showterminals
    catch {destroy $w}

    if {[assoc selectOut pirDisplay] == "" && \
	[assoc selectIn pirDisplay] == ""} {
	pirWarning "No terminals are selected."
	return
    }

    toplevel $w -class Dialog

    wm title $w "Selected Terminals"
    button_row $w buts bottom 0\
	    OK "destroy $w" 

    set name $w.text
    set scr $w.scroll

    text $name -relief raised -bd 2 -yscrollcommand "$scr set"
    scrollbar $scr -command "$name yview"
    pack $scr -side right -fill y
    pack $name -side left

    $name delete 1.0 end
  
    foreach out [assoc selectOut pirDisplay] {
	set node [assoc [string range $out 0 \
                             [expr {[string last ".out" $out] - 1}]] \
	          pirDisplay]
	set port [pirButtonNum $out out]
	tellAbout $node output $port $name
    }

    foreach in [assoc selectIn pirDisplay] {
	set node [assoc [string range $in 0 \
                             [expr {[string last ".in" $in] - 1}]] \
	          pirDisplay]
	set port [pirButtonNum $in in]
	tellAbout $node input $port $name
    }

    $name config -state disabled
}

## Handles formatting of information for pirShowTerminals.
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 01feb98 wmt: not used
proc tellAbout {node in_out port window} {
  global pirNode pirClass

  set name [assoc label pirNode($node)]
  $window insert end "Node $name, $in_out terminal index $port:\n"
  
  set nodeClassName [assoc nodeClassName pirNode($node)]
  set internal $pirClass($nodeClassName)
  if {$in_out == "input"} {
    set labels [assoc inputLabels pirNode($node)]
    set specs [assoc inputs pirNode($node)]
  } else {
    set labels [assoc outputLabels pirNode($node)]
    set specs [assoc outputs pirNode($node)]
  }
  set labels [lindex $labels $port]
  
  if {[llength $labels] > 1} {
    $window insert end "  (Super Terminal of dimension\
        [llength $labels])\n"
  }
  $window insert end "  $labels\n"
  set labels [lindex $labels 0]
  if {[string index $labels 0] == "*"} {
    set spec [assoc * specs]
  } else {
    set spec [assoc $labels specs]
  }
  doConfigInserts $window $spec "    "
  $window insert end "\n\n"
}













