# $Id: tkbind-rectangle.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from tkbind package

# Rectangle Package for tkTextEnhanced --
#
# Use of these routines will have unpredictable results in
# non-fixed fonts are used. Correct processing of tabs is not
# yet implemented. 
# 
# The following bindings should work as in standard emacs
#
#	C-x r o		open-rectangle
#	C-x r y		yank-rectangle
#	C-x r d		delete-rectangle
#	C-x r k		kill-rectangle
#	C-x r c		clear-rectangle
#	C-x r t		string-rectangle
#
# These bindings work differently than in emacs at this time
#
#	C-x r r		copy-rectangle
#
#		Not a copy to a register but just a copy to the
#		normal rectangle kill buffer. This may change once
#		a register package is written.
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

global tkText tkBind

## tkBindRequire prompt

if {![info exists tkBind(rect,bind)] || $tkBind(rect,bind)} {

  if $tkBind(emacs) {

    bind TextCX <KeyPress-r> { 
      tkBindSetStateKey %W TextCXR {C-x r}
    }
    bind TextCXR <KeyPress> {
      if {[lsearch $tkBind(modKeys) %K] > -1} break
      set $tkBind(%W,mesgvar) "C-x r [tkBindGetMod %s]%K not bound."
      eval $tkBind(bell)
    }
    bind TextCXR <ButtonPress> {
      set $tkBind(%W,mesgvar) "C-x r [tkBindGetMod %s]mouse-%b not bound."
      eval $tkBind(bell)
    }

    bind TextCXR <KeyPress-c> {
      tkBindRectangleKill %W 0 0 1
    }
    bind TextCXR <KeyPress-d> {
      tkBindRectangleKill %W 1 0 0
    }
    bind TextCXR <KeyPress-k> {
      tkBindRectangleKill %W 1 1 0
    }
    bind TextCXR <KeyPress-o> {
      tkBindRectangleKill %W 0 0 1 1
    }
    bind TextCXR <KeyPress-r> {
      tkBindRectangleKill %W 0 1 0
    }
    bind TextCXR <KeyPress-t> {
      set tkBind(rect,prefix) [tkBindPromptString %W -prompt "Prefix string:"]
      if $tkPrompt_valid {
	tkBindRectangleKill %W 0 1 0 1 $tkBind(rect,prefix)
      }
    }
    bind TextCXR <KeyPress-y> {
      tkBindRectangleYank %W
    }
  }
}

proc tkBindRectangleKill {w {kill 1} {save 1} {clear 0} {ins 0} {prefix {}}} {
  global tkText tkBind

  if {[$w tag nextrange sel 1.0 end] != ""} {
    set top [$w index sel.first]
    set bot [$w index sel.last]
  } else {
    tkTextCheckMark $w 1
    if [$w compare emacs < insert] {
      set top [$w index emacs]; set bot [$w index insert]
    } else {
      set top [$w index insert]; set bot [$w index emacs]
    }
  }
  $w tag remove sel 1.0 end

  scan $top "%d.%d" topline topcol
  scan $bot "%d.%d" botline botcol
  if { $topcol < $botcol } {
    set fcol $topcol; set lcol $botcol; set len [expr $botcol-$topcol]
  } else {
    set fcol $botcol; set lcol $botcol; set len [expr $topcol-$botcol]
  }

  if $clear {
    set blanks {}
    for {set i 0} { $i < $len} {incr i} { append blanks " " }
    if $ins { set prefix $blanks }
  }

  tkTextUndoBeginGroup $w rectkill
  if $save { set tkText(killRect) {} }
  for {set line $topline} {$line <= $botline} {incr line} {
    if $ins {
      tkTextInsert $w $line.$fcol $prefix
    } else {
      set txt [$w get $line.$fcol $line.$lcol]
      # process tabs here
      # set txt [string range $txt 0 $len]
      while {[string length $txt] < $len} {
	append txt " "
      }
      if $kill { tkTextDelete $w $line.$fcol $line.$lcol }
      if $clear { tkTextReplace $w $line.$fcol $line.$lcol $blanks }
      if $save { lappend tkText(killRect) $txt }
    }
  }
  tkTextUndoEndGroup $w rectkill

  set tkText($w,markActive) 0
  tkBindSetMesg $w "Killed rectangle"
  set tkText($w,prevCmd) RectKill
}

proc tkBindRectangleYank w {
  global tkBind tkText

  if [info exists tkText(killRect)] {
    $w tag remove sel 1.0 end
    scan [$w index insert] "%d.%d" line col

    tkTextUndoBeginGroup $w rectyank
    foreach txt $tkText(killRect) {
      set prefix {}
      if [$w compare $line.$col >= end] { set prefix \n }
      scan [$w index "$line.$col"] "%d.%d" cline ccol
      while {$ccol < $col} { append prefix " "; incr ccol }
      tkTextInsert $w $line.$col $prefix$txt
      incr line
    }
    tkTextUndoEndGroup $w rectyank
    
    set tkText($w,markActive) 0
    tkBindSetMesg $w "Yanked rectangle"
    set tkText($w,prevCmd) RectYank
  } else {
    tkBindSetMesg $w "No rectangle in kill buffer."
  }
}



