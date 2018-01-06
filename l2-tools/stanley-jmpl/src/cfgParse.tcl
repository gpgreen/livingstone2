# $Id: cfgParse.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## cfgParse.tcl

# Swallow up the "define module_class ..." statement from a module.cfg
# file and return a corresponding structure of nested a-lists.
proc chomp_cfg {file} {
    global cfgstr
    set grand_alist {}

    set fid [open $file r]
    set cfgstr [read $fid]
    close $fid
    trim
    find_define
    set mod_decl [get_name]
    set class_name [get_name]
    set grand_alist [get_alist]
    acons $mod_decl $class_name grand_alist
    return $grand_alist
}


## Scan for the keyword "define".
proc find_define {} {
    global cfgstr

    set place [string first define $cfgstr]
  trim [expr {$place + 6}]
}


## scan past /* */ style comments, taking no action.
proc skip_comment {} {
    global cfgstr

    if [regexp {^\/\*} $cfgstr] {
	set close [string first "*/" $cfgstr]
      trim [expr {$close+2}]
    }
}


## Set the parse string to start at the next "interesting"
## token after the given offset, skipping comments, whitespace
## and trailing semicolons.
proc trim {{start 0}} {
    global cfgstr

    if {$start > 0} {
	set cfgstr [string range $cfgstr $start end]
    }
    set cfgstr [string trimleft $cfgstr]
    skip_comment
    if [regexp {^;} $cfgstr] {
	trim 1
    }
}

## extract the next identifier token from the parse string.
## Square brackets, underscores, hyphens, decimal points OK.
## 12dec95 wmt: change call to error with tk_dialog 
proc get_name {} {
  global cfgstr
  set name ""
  regexp {^[][a-zA-Z0-9.*_-]+} $cfgstr name
  set len [string length $name]
  if {$len == 0} {
    ##error "cfg problem: name not found near:\n[string range $cfgstr 0 50]"
    set msg "PARSING PROBLEM: name not found near:\n[string range $cfgstr 0 50]"
    set dialogList [list tk_dialog .d "ERROR" $msg error 0 {DISMISS}]
    eval $dialogList
    return ""
  }
  trim $len
  return $name
}


## Return a quote-delimited string from head of parse string.
## 12dec95 wmt: change call to error with tk_dialog 
proc get_string {} {
  global cfgstr

  if {[string index $cfgstr 0] != "\"" } {
    ## error "cfg problem: \" expected near:\n[string range $cfgstr 0 50]"
    set msg "PARSING PROBLEM: \" expected near:\n[string range $cfgstr 0 50]"
    set dialogList [list tk_dialog .d "ERROR" $msg error 0 {DISMISS}]
    eval $dialogList
    return ""
  } 
  set close [string first "\"" [string range $cfgstr 1 end]]
  set literal [string range $cfgstr 1 $close]
  trim [expr {$close+2}]
  return $literal
}


## Parse out an alist value field, which may be a nested alist,
## a string or a name.
proc get_value {} {
    global cfgstr

    if {[string index $cfgstr 0] == "\{" } {
	return [get_alist]
    } elseif {[string index $cfgstr 0] == "\"" } {
	return [get_string]
    } else {
	return [get_name]
    }
}

## Parse out a {}-delimited alist from parse string.
## 01dec95 wmt: parse 1-deep nested {}-delimited alists
## 12dec95 wmt: change call to error with tk_dialog 
proc get_alist {} {
  global cfgstr

  if {[string index $cfgstr 0] != "\{" } {
    ## error "cfg problem: \{ expected near:\n[string range $cfgstr 0 50]"
    set msg "PARSING PROBLEM: \{ expected near:\n[string range $cfgstr 0 50]"
    set dialogList [list tk_dialog .d "ERROR" $msg error 0 {DISMISS}]
    eval $dialogList
    return ""
  }
  
  trim 1
  set mylist {}
  while {[string index $cfgstr 0] != "\}" } {

    while {[string index $cfgstr 0] == "\{" } {
      set mylist [lappend mylist [get_alist]]
    }
    if {[string index $cfgstr 0] == "\}" } {
      trim 1
      return $mylist 
    }

    set attr [get_name]
    if {[string index $cfgstr 0] == "\}" } {
      lappend mylist $attr   ;# must be a different type of list
      break
    }
    set val [get_value]
    alistAppend mylist $attr $val
  }
  trim 1

  return $mylist
}




    
