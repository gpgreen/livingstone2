# $Id: tkbind-bindxtnd.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from tkbind package

# bindxtnd.tcl -

# This file defines code shared by all widget bindings in the
# BindExtended package
#
#  Copyright 1995 by Paul Raines (raines@slac.stanford.edu)
#
#  Permission to use, copy, modify, and distribute this software and
#  its documentation for any purpose and without fee is hereby
#  granted, provided that the above copyright notice appear in all
#  copies.  The University of Pennsylvania, Stanford University, and
#  Stanford Linear Accelerator Center makes no representations
#  about the suitability of this software for any purpose.  It is
#  provided "as is" without express or implied warranty.
# 
# Following procedures ripped off shamelessly from Jay Sekora's jlibrary.tcl
# 	tkBindParseArgs, tkBindExpandFilename, tkBindLongestMatch
#
# Copyright 1992-1994 by Jay Sekora.  All rights reserved, except 
# that this file may be freely redistributed in whole or in part 
# for non-profit, noncommercial use.

#-------------------------------------------------------------------------
# Elements of tkBind used by all widgets. These can be set in
# a user's ~/.tkbindrc file.
#
# emacs -		Make emacs-like bindings
# notWord -		Regular expression saying what characters are not
#			to be considered a word
# fillBreak -		String containing the characters upon which paragraph
#			filling is allowed to break on
# meta -		What should be considered meta for emacs bindings,
#			either Meta or Alt
# useEsc -		Bind to Escape key as a prefix Meta key
# killRing -		List storing kill buffers
# killLen -		Length of kill ring
# killPtr -		Index of buffer in kill ring to use for next yank
# killMax -		Maximum number of buffers to store in kill ring
# undoMax -		Maximum number of buffers to store in undo list
# bindUndo -		Whether undo ring should be on by default
# bell -		Command to use instead of ring bell for errors
# modKeys -		List of keysyms for your keyboards modifier keys
#			Any keysyms listed in 'xmodmap -pm' should go here
# delSel -		If set true, any current selection is deleted
#			an a character insertion or character deletion
# insertAtClick -	Whether a mouse insert should be done at the position
#			of the mouse click or current insert mark
# noCase -		Set to 1 to make search case insensitive, 0 for not
# path -		List of paths to search for tkBind packages
# required -		List of packages already required
# notransient -		Tells packages not to use "wm transient"
#-------------------------------------------------------------------------
# Widget specific elements of tkBind for internal use only.
#
# bindtags -		Bindtags saved for a  widget when in state key
# prebindtags -		Bindtags to prepend to list when widget goes into
#			state key mode
# postbindtags -	Bindtags to append to list when widget goes into
#			state key mode
# mesg -		A variable that these procedure write informational
#			messages to. Good to use for -textvariable.
# mesgvar -
# mesgbuf -
#-------------------------------------------------------------------------
global tkBind tk_strictMotif

set tk_strictMotif 0

if [string length [glob -nocomplain ~/.tkbindrc]] {
  if {[file readable [glob -nocomplain ~/.tkbindrc]]} {
    source [glob -nocomplain ~/.tkbindrc]
  }
} else {
  if [string length [glob -nocomplain ~/tk/tkBind/init]] {
    if {[file readable [glob -nocomplain ~/tk/tkBind/init]]} {
      source [glob -nocomplain ~/tk/tkBind/init]
    }
  }
}

# tkBindDefVar --
# Set the element 'elem' in the tkBind array to 'def' only if 
# it does not already exist. Useful to allow developer to override
# defaults before this file is sourced

proc tkBindDefVar {elem def} {
  global tkBind
  if {![info exists tkBind($elem)]} {
    set tkBind($elem) $def
  }
}

# tkBindGetFullPath --

proc tkBindGetFullPath file {
  set cwd [pwd]
  cd [file dirname $file]
  set path [pwd]
  cd $cwd
  return $path
}

tkBindDefVar emacs [expr !$tk_strictMotif]
tkBindDefVar path [tkBindGetFullPath [info script]]
tkBindDefVar notWord {[^a-zA-Z_0-9]}
tkBindDefVar fillBreak " \t-"
tkBindDefVar meta Meta
tkBindDefVar useEsc 1
tkBindDefVar undoMax 150
tkBindDefVar killMax 25
tkBindDefVar killRing {}
tkBindDefVar killLen 0
tkBindDefVar killPtr 0
tkBindDefVar bindUndo 0
tkBindDefVar bell bell
tkBindDefVar delSel 1
tkBindDefVar insertAtClick 0
tkBindDefVar noCase 1
tkBindDefVar required {}
tkBindDefVar notransient 0
tkBindDefVar modKeys [list Control_L Control_R Meta_R Meta_L Alt_R Alt_L \
			  Shift_L Shift_R Caps_Lock Multi_key Super_L Super_R]

# tkBindRequire --

proc tkBindRequire {pkg {nocomplain 0} {bind 1}} {
  global tkBind
  
  set indir [file dirname $pkg]
  set pkg [file tail $pkg]

  if {![string length [file extension $pkg]]} {
    append pkg .tcl
  }
  if {[lsearch -exact $tkBind(required) $pkg] > -1} {return 2}

  set tkBind([file rootname $pkg],bind) $bind

  foreach dir [concat $indir [glob -nocomplain ~/tk/tkBind] $tkBind(path)] {
    if {[string length $dir] && [file exists $dir/$pkg]} {
      source $dir/$pkg
      lappend tkBind(required) $pkg
      return 1
    }
  }
  if {!$nocomplain} { error "Cannot find tkBindExtend package $pkg." }
  return 0
}

# tkBindNoBind -- 
# If not a modifier key, signal a non-bound key
proc tkBindNoBind {w k s} {
  global tkBind
  if {[lsearch $tkBind(modKeys) $k] < 0} {
    tkBindSetMesg $w "[tkBindGetMod $s]$k not bound."
    eval $tkBind(bell)
  }
}

# tkBindGetMod --

proc tkBindGetMod s {
  set mod {}
  if {$s &  1} { append mod "Shift-" }
  if {$s &  2} { append mod "Lock-" }
  if {$s &  4} { append mod "Control-" }
  if {$s &  8} { append mod "Mod1-" }
  if {$s & 16} { append mod "Mod2-" }
  if {$s & 32} { append mod "Mod3-" }
  if {$s & 64} { append mod "Mod4-" }
  return $mod
}

# tkBindCancelStateKey --
# Cancel the current state key in widget 'w'

proc tkBindCancelStateKey w {
  global tkBind errorInfo
  if {[llength $tkBind($w,bindtags)]} {
    bindtags $w $tkBind($w,bindtags)
    set tkBind($w,bindtags) {}
  }
}

# tkBindSetStateKey --
# Arm the state key 's' in widget 'w' echoing 'd' to message area

proc tkBindSetStateKey {w s d} {
  global tkBind errorInfo
  if {![llength $tkBind($w,bindtags)]} {
    set tkBind($w,bindtags) [bindtags $w]
  }
  bindtags $w [concat $tkBind($w,prebindtags) BindState $s $tkBind($w,postbindtags)]
  tkBindSetMesg $w $d
}

bind BindState <KeyPress> {
  if {[lsearch $tkBind(modKeys) %K] > -1} break
  tkBindCancelStateKey %W
}
bind BindState <ButtonPress> {
  tkBindCancelStateKey %W
}

######################################################################
# Fake TclX procedures if you don't have them.
# Should work good enough for their use in these bindings
######################################################################

if {[catch "infox version"]} {

  proc lassign { vallist args } {
    set cnt 0
    set len [llength $vallist]
    foreach var $args {
      if {$cnt < $len} {
	set val [lindex $vallist $cnt]
	uplevel "set $var \{$val\}"
      } else {
	uplevel "set $var {}"
      }
      incr cnt
    }
    return [lrange $vallist $cnt $len]
  }
  
  # won't insert an empty string
  proc lvarpop { var {ndx 0} {str {}} } {
    upvar $var vlist
    set ndx [string trim $ndx]
    if {$ndx == "end" } { 
      set ndx [expr [llength $vlist]-1]
    } elseif {$ndx == "len"} {
      set ndx [llength $vlist]
    }
    set tmp [lindex $vlist $ndx]
    if {[string length $str]} {
      set vlist [lreplace $vlist $ndx $ndx $str]
    } else {
      set vlist [lreplace $vlist $ndx $ndx]
    }
    return $tmp
  }
  
  proc lvarpush {  var str {ndx 0}  } {
    upvar $var vlist
    if {![info exists vlist]} {set vlist {}}
    set ndx [string trim $ndx]
    if { $ndx == "end" } { 
      set ndx [expr [llength $vlist]-1]
    } elseif { $ndx == "len" } { 
      set ndx [llength $vlist]
    }
    set vlist [linsert $vlist $ndx $str]
    return
  }
  
}

# tkBindDefArg --
# Default handler for modifying a repeat count by the current buffer
# arg count. The repeat count will only be modified if it is a plus
# or minus sign.
#
# Arguments:
# w -		The window in which to modify count
# n -		The repeat count to be modified
# def -		Default if there is no emacs argument

proc tkBindDefArg {w n {def 1}} {
  global tkBind

  if {![string length $tkBind($w,arg)]} { 
    set tkBind($w,arg) $def
  } elseif {$tkBind($w,arg) == "-"} {
    set tkBind($w,arg) -1
  } elseif {$tkBind($w,arg) == "+"} {
    set tkBind($w,arg) 1
  }
  if {$n == "+"} {
    set n $tkBind($w,arg)
  } elseif {$n == "-"} {
    set n [expr -1*$tkBind($w,arg)]
  }
  set tkBind($w,arg) {}
  return $n
}

# tkBindArgKey --
#
# Arguments:
# w -		The window in which to yank
# a -		The ascii character of key ( a minus sign or decimal number)

proc tkBindArgKey { w a } {
  global tkBind
  if {$a == "-"} {
    if {$tkBind($w,arg) == "-"} {
      set tkBind($w,arg) "+"
    } elseif {$tkBind($w,arg) == "+"} {
      set tkBind($w,arg) "-"
    } elseif [string length $tkBind($w,arg)] {
      set tkBind($w,arg) [expr -1*$tkBind($w,arg)]
    } else {
      set tkBind($w,arg) "-"
    }
    tkBindSetMesg $w "arg: $tkBind($w,arg)"
    return
  }
  if {![string length $tkBind($w,arg)]} {
    tkBindSetMesg $w "arg: "
  }
  append tkBind($w,arg) $a
  uplevel #0 append $tkBind($w,mesgvar) $a
}

# tkBindSetMesgVar --
#
# Arguments:
# w -		The window for which to associate message variable
# var -		Variable to be used by window for messages

proc tkBindSetMesgVar {w var} {
  global tkBind
  if [info exists tkBind($w,mesgvar)] {
    uplevel #0 set $var "{[set $tkBind($w,mesgvar)]}"
  }
  set tkBind($w,mesgvar) $var
}

# tkBindSetMesg --
#
# Arguments:
# w -		The window for which to write mesg
# msg -		The message itself

proc tkBindSetMesg {w msg} {
  global tkBind
  uplevel #0 set $tkBind($w,mesgvar) "{$msg}"
}

## 07nov97 wmt: add Stanley background color
proc tkBindCreateMesgBuffer {w args} {
  regsub {\.} $w _ mesgvar
  set mesgvar mesg$mesgvar
  frame $w
  label $w.l -anchor w -wraplength 0 -height 1
  entry $w.e -textvariable $mesgvar -relief flat -state disabled 
  pack $w.e -side right -fill x -expand true
  if {[string length $args]} { 
    eval "$w.e configure $args" 
    eval "$w.l configure $args" 
  }
  return $w
}

proc tkBindAttachMesgBuffer {w mesgbuf} {
  global tkBind
  regsub {\.} $mesgbuf _ mesgvar
  set mesgvar mesg$mesgvar
  if [info exists tkBind($w,mesgvar)] {
    uplevel #0 set $mesgvar "{[set $tkBind($w,mesgvar)]}"
  }
  set tkBind($w,mesgvar) $mesgvar
  set tkBind($w,mesgbuf) $mesgbuf
}

# tkBindParseArgs arglist - parse arglist in parent procedure
#
# Arguments:
#   arglist is a list of option names (without leading "-");
#   this proc puts their values (if any) into variables (named after
#   the option name) in d parent procedure
#   Any element of arglist can also be a list consisting of an option
#   name and a default value.

proc tkBindParseArgs {arglist} {
  upvar args args

  foreach pair $arglist {
    set option [lindex $pair 0]
    set default [lindex $pair 1]		;# will be null if not supplied
    set index [lsearch -exact $args "-$option"]
    if {$index != -1} {
      set index1 [expr {$index + 1}]
      set value [lindex $args $index1]
      uplevel 1 [list set $option $value]	;# caller's variable "$option"
      set args [lreplace $args $index $index1]
    } else {
      uplevel 1 [list set $option $default]	;# caller's variable "$option"
    }
  }
}

# tkBindLongestMatch - longest common initial string in list l
#   used by tab-expansion in filename dialogue box

proc tkBindLongestMatch { l } {
  case [llength $l] in {
    {0} { return {} }
    {1} { return [lindex $l 0] }
  }
  set first [lindex $l 0]
  set matchto [expr {[string length $first] - 1}]
  for {set i 1} {$i < [llength $l]} {incr i} {
    set current [lindex $l $i]
    # if they don't match up to matchto, find new matchto
    if { [string compare \
           [string range $first 0 $matchto] \
           [string range $current 0 $matchto]] } {
      # loop, decreasing matchto until the strings match that far
      for {} \
          {[string compare \
              [string range $first 0 $matchto] \
              [string range $current 0 $matchto]] } \
          {incr matchto -1 } \
          {}			;# don't need to do anything in body
    } ;# end if they didn't already match up to matchto
  } ;# end for each element in list
  if {$matchto < 0} then {
    return {}
  } else {
    return [string range $first 0 $matchto]
  }
}

# tkBindExpandFilename f - expand filename prefix as much as possible
# note: if the filename has *, ?, or [...] in it, they will be used
#       as part of the globbing pattern.  i declare this a feature.

proc tkBindExpandFilename { f } {
  set expansion [tkBindLongestMatch [glob -nocomplain "${f}*"]]
  if {$expansion == ""} {return $f}
  # make sure it doesn't already end in "/"
  set expansion [string trimright $expansion "/"]
  if {[llength [glob -nocomplain "${expansion}*"]] < 2} {
    if [file isdirectory $expansion] {append expansion "/"}
  }
  return $expansion
}








