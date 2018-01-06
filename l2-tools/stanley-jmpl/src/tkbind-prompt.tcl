# $Id: tkbind-prompt.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from tkbind package

# Prompt Package for tkTextEnhanced --
#
# This file should be sourced in the ~/.tkBindrc file
#
# The following bindings are added to the Text widget
#
#    C-x i	Insert file at current position
#    M-x	Prompt for Tcl command to eval
#
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

global tkBind

## 06jan98 wmt: we do not want M-x binding
# if {![info exists tkBind(prompt,bind)] || $tkBind(prompt,bind)} {

#   if $tkBind(emacs) {
#     bind TextCX <KeyPress-i> { tkPromptInsertFile %W }
#     bind TextEsc <KeyPress-x> {tkPromptGetCommand %W}
#     bind Text <$tkBind(meta)-x> {tkPromptGetCommand %W}
#   }

# }

bind Prompt <Return> {set tkPrompt_res 1; break}
if {$tkBind(emacs) && $tkBind(useEsc)} {
  global tkEntry
  lappend tkEntry(cancelhooks) tkBindPromptStringCancel
  proc tkBindPromptStringCancel w { global tkPrompt_res; set tkPrompt_res 0 }
} else {
  bind Prompt <Escape> {set tkPrompt_res 0; break}
}

bind PromptChar <KeyPress> {
  if {[lsearch $tkBind(modKeys) %K] > -1} break
  tkBindPromptCheckChar [string tolower %K]
}
bind PromptChar <Escape> { set tkPrompt_valid 0; set tkPrompt_res {} }
bind PromptChar <Control-g> { set tkPrompt_valid 0; set tkPrompt_res {} }
bind PromptChar <ButtonPress> { eval $tkBind(bell) }

proc tkBindPromptString { w args } {

  global tkBind tkEntry tkPrompt_res tkPrompt_valid

  tkBindParseArgs { \
    {prompt "String?"} \
    {default ""} \
    {dialog 0} \
    {callback ""} \
    {cbargs ""} \
    {fc 0} \
    {oklabel "OK"} \
    {nolabel "Cancel"} \
    {cancelvalue ""} \
  }
  set tkPrompt_res -1
  set tkPrompt_valid 0

  if {$dialog || ![info exists tkBind($w,mesgbuf)]} {

    set cnt 0
    while {[winfo exists .tkprompt_w$cnt]} {incr cnt}

    set top .tkprompt_w$cnt
    toplevel $top -class PromptDialog
    wm protocol $top WM_DELETE_WINDOW "set tkPrompt_res 0"
    wm title $top " "
    if {[string length $w]} { 
      if {!$tkBind(notransient)} {wm transient $top $w}
      set xpos [expr [winfo rootx $w]+[winfo width $w]/3]
      set ypos [expr [winfo rooty $w]+[winfo height $w]/3]
      wm geometry $top +${xpos}+${ypos}
    }

    tkBindSetMesg $w {}
    message $top.prompt -width 300 -anchor w -text $prompt
    entry $top.e -relief sunken
    $top.e delete 0 end
    $top.e insert 0 $default

    if {$fc} {
      bind $top.e <Key-Tab> {
	set f [%W get]
	%W delete 0 end
	%W insert end [tkBindExpandFilename $f]
	break
      }
    } 

    frame $top.b 
    button $top.b.ok -text $oklabel \
	-command "set tkPrompt_res 1"
    if {[string length $oklabel] < 8} {$top.b.ok configure -width 8}
    button $top.b.clear -text "Clear" -width 8 \
	-command "$top.e delete 0 end"
    button $top.b.cancel -text $nolabel \
	-command "set tkPrompt_res 0"
    if {[string length $nolabel] < 8} {$top.b.cancel configure -width 8}
    pack $top.b.ok $top.b.clear $top.b.cancel -side left -padx 10 -pady 10 \
	-ipady 2 -ipadx 5

    pack $top.prompt -side top -fill both -expand true -padx 10 -pady 10
    pack $top.e -side top -fill x -expand true -padx 10 -ipady 3
    frame $top.sep -bd 2 -height 4 -relief sunken
    pack $top.sep -side top -fill x -expand true -pady 10
    pack $top.b -side bottom

    bind $top.e <Return> "$top.b.ok invoke"
    if {$tkBind(emacs) && $tkBind(useEsc)} {
      bind EntryEsc <Escape> "$top.b.cancel invoke"
    } else {
      bind $top.e <Escape> "$top.b.cancel invoke"
    }

    if {[string length $callback]} {eval "$callback $top $cbargs"}

    set savefocus [focus]
    focus $top.e
    after 200 grab $top
    tkwait variable tkPrompt_res
    if $tkPrompt_res { 
      set tkPrompt_res [$top.e get]
      set tkPrompt_valid 1
    } else { set tkPrompt_res $cancelvalue }
    grab release $top
    destroy $top
    focus $savefocus
    return $tkPrompt_res

  } else {
    set top $tkBind($w,mesgbuf)
    $top.e configure -state normal
    $top.l configure -text $prompt
    pack $top.l -side right
    $top.e delete 0 end
    $top.e insert 0 $default

    if {$fc} {
      set savetab [bind $top.e <Key-Tab>]
      bind $top.e <Key-Tab> {
	set f [%W get]
	%W delete 0 end
	%W insert end [tkBindExpandFilename $f]
	break
      }
    } 

    set savetags [bindtags $top.e]
    bindtags $top.e [concat Prompt $savetags]

    set savefocus [focus]
    focus $top.e
    after 200 grab $top.e
    tkwait variable tkPrompt_res
    grab release $top.e
    focus $savefocus
    bindtags $top.e $savetags
    if $tkPrompt_res { 
      set tkPrompt_res [$top.e get]
      set tkPrompt_valid 1
    } else { set tkPrompt_res $cancelvalue }

    if {$fc} { bind $top.e <Key-Tab> $savetab }
    pack forget $top.l
    $top.e delete 0 end
    $top.e configure -state disabled
    return $tkPrompt_res

  }
}

proc tkPromptInsertFile {w {file {}} {ndx insert}} {
  global tkBind tkText

  $w tag remove sel 1.0 end
  set tkText($w,markActive) 0
  set tkBind($w,arg) {}
  set tkText($w,prevCmd) InsertFile

  if {![string length $file]} {
    global tkPrompt_valid
    set file [tkBindPromptString $w -prompt "Filename:" -fc 1]
    if {!$tkPrompt_valid || ![string length $file]} {
      tkBindSetMesg $w Canceled.
      return
    }
  }

  if [catch {open $file r} fid] {
    eval $tkBind(bell)
    tkBindSetMesg $w "ERROR: $fid."
    return
  }

  if [$w compare $ndx == insert] { tkTextSetMark $w insert }
  tkTextInsert $w $ndx [read $fid]
  tkBindSetMesg $w "Inserted file $file."
  close $fid
}

proc tkPromptGetCommand w {
  global tkBind tkPrompt_valid

  set cmd [tkBindPromptString $w -prompt "Command:"]
  if {!$tkPrompt_valid || ![string length $cmd]} {
    tkBindSetMesg $w Canceled.
    return
  }
  puts stderr "tkPromptGetCommand: cmd $cmd"

  set txt [uplevel #0 "eval {$cmd}"]
  regsub -all \n $txt "^J" mtxt
  tkBindSetMesg $w "Eval Result: $mtxt"

  set tkBind($w,arg) {}
  return $txt
}

proc tkBindPromptChar { w args } {

  global tkBind tkPrompt_res tkPrompt_valid tkPrompt_chars

  tkBindParseArgs { \
    {prompt "Char?"} \
    {dialog 0} \
    {callback ""} \
    {cbargs ""} \
    {choices {{Yes y} {No n}}} \
  }

  if ![llength $choices] {
    error "Empty choice list passed to tkBindPromptChar"
  }

  set tkPrompt_res {}
  set tkPrompt_valid -1

  set tkPrompt_chars {}
  foreach choice $choices {
    lassign $choice label char
    if {![string length $char]} {
      set char [string range $label 0 0]
    }
    set char [string tolower $char]
    lappend tkPrompt_chars $char
  }

  set choice [lindex $choices 0]
  lassign $choice label defaultvalue
  if {[llength $choice] < 2} {
    set defaultvalue [string range $label 0 0]
  }
  set defaultvalue [string tolower $defaultvalue]

  if {$dialog || ![info exists tkBind($w,mesgbuf)]} {

    set cnt 0
    while {[winfo exists .tkprompt_w$cnt]} {incr cnt}

    set top .tkprompt_w$cnt
    toplevel $top -class PromptDialog
    wm protocol $top WM_DELETE_WINDOW "tkBindPromptCharDone 0 $top {}"
    wm title $top " "
    if {[string length $w]} { 
      if {!$tkBind(notransient)} {wm transient $top $w}
      set xpos [expr [winfo rootx $w]+[winfo width $w]/3]
      set ypos [expr [winfo rooty $w]+[winfo height $w]/3]
      wm geometry $top +${xpos}+${ypos}
    }

    tkBindSetMesg $w {}
    message $top.prompt -width 300 -anchor w -text $prompt

    frame $top.b 
    set cnt 0
    foreach choice $choices {
      set label [lindex $choice 0]
      set char [lindex $tkPrompt_chars $cnt]

      button $top.b.b$cnt -text $label \
	-command "tkBindPromptCharDone 1 $top $char"
      if {[string length $label] < 8} {$top.b.b$cnt configure -width 8}

      pack $top.b.b$cnt -side left -padx 10 -pady 10 -ipady 2 -ipadx 5
      incr cnt
    }

    pack $top.prompt -side top -fill both -expand true -padx 10 -pady 10
    frame $top.sep -bd 2 -height 4 -relief sunken
    pack $top.sep -side top -fill x -expand true -pady 10
    pack $top.b -side bottom

    bind $top <Return> "tkBindPromptCharDone 1 $top $defaultvalue"
    bind $top <Escape> "tkBindPromptCharDone 0 $top {}"
    bind $top <Control-g> "tkBindPromptCharDone 0 $top {}"

    if {[string length $callback]} {eval "$callback $top $cbargs"}

    set savefocus [focus]
    focus $top
    after 200 grab $top
    tkwait window $top
    focus $savefocus
    return $tkPrompt_res

  } else {
    set top $tkBind($w,mesgbuf)
    tkBindSetMesg $w "$prompt ([join $tkPrompt_chars /])"

    set savetags [bindtags $w]
    bindtags $w [list PromptChar]
    bind PromptChar <Return> "set tkPrompt_valid 1; set tkPrompt_res $defaultvalue"

    focus $w
    after 200 grab $w
    tkwait variable tkPrompt_res
    bindtags $w $savetags
    grab release $w

    tkBindSetMesg $w {}
    if !$tkPrompt_valid { eval $tkBind(bell) }
    return $tkPrompt_res
  }
}

proc tkBindPromptCharDone { valid top char } {
  global tkPrompt_res tkPrompt_valid
  set tkPrompt_valid $valid
  set tkPrompt_res $char
  grab release $top
  destroy $top
}    

proc tkBindPromptCheckChar { char } {
  global tkPrompt_res tkPrompt_chars tkPrompt_valid tkBind
  if {[lsearch -exact $tkPrompt_chars $char] > -1} {
    set tkPrompt_valid 1
    set tkPrompt_res $char
  } else {
    eval $tkBind(bell)
  }
}    
