# $Id: tkbind-isearch.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from tkbind package

# ISearch Package for tkTextEnhanced --
#
# This file should be source from the tkTextInitHook in ones ~/.tkBindrc file
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

if {![info exists tkBind(isearch,bind)] || $tkBind(isearch,bind)} {

  bind Text <Control-s> {
    tkTextISearchStart %W -forwards -exact
  }

  bind Text <Control-r> {
    tkTextISearchStart %W -backwards -exact
  }
}

bind TextISearch <Control-s> {
  set tkText(%W,searchDir) -forwards
  tkTextISearchNext %W $tkText(%W,searchStr) insert
  break
}

bind TextISearch <Control-r> {
  set tkText(%W,searchDir) -backwards
  tkTextISearchNext %W $tkText(%W,searchStr) \
      [%W index "$tkText(%W,searchNdx) -1 char"]
  break
}

bind TextISearch <Control-g> {
  tkTextSetCursor %W $tkText(%W,searchHome)
  tkTextISearchStop %W 0
  break
}

bind TextISearch <BackSpace> {tkTextISearchPop %W; break}
bind TextISearch <Delete> {tkTextISearchPop %W; break}

bind TextISearch <KeyPress> {
  if {[lsearch $tkBind(modKeys) %K] > -1} break
  if [string length %A] {
    tkTextISearchAdd %W %A
    break
  } else {
    tkTextISearchStop %W
    continue
  }
}
bind TextISearch <Control-j> { tkTextISearchAdd %W \n; break }
bind TextISearch <Control-w> { 
  tkTextISearchAdd %W [%W get insert [tkTextPlaceWord %W +]]
  break 
}
bind TextISearch <Control-y> { 
  tkTextISearchAdd %W [%W get insert "insert lineend"]
  break 
}

bind TextISearch <Return> { tkTextISearchStop %W; break }
bind TextISearch <ButtonPress> { tkTextISearchStop %W; continue }
bind TextISearch <Alt-KeyPress> { tkTextISearchStop %W; continue }
bind TextISearch <Meta-KeyPress> { tkTextISearchStop %W; continue }
bind TextISearch <Control-KeyPress> { tkTextISearchStop %W; continue }

bind TextISearch <Control-q> {
  bindtags %W [concat TextISQ $tkBind(%W,bindtags)]
  break
}
bind TextISearchQ <KeyPress> {
  if {[lsearch $tkBind(modKeys) %K] > -1} break
  tkTextISearchAdd %W %A
  bindtags %W [concat TextISearch $tkBind(%W,bindtags)]  
  break
}
bind TextISearchQ <ButtonPress> { 
  bindtags %W [concat TextISearch $tkBind(%W,bindtags)]
  eval $tkBind(bell)
  break
}

proc tkTextISearchStart {w dir mode} {
  global tkText tkBind

  set tkText($w,markActive) 0
  set tkText($w,arg) {}

  set tkText($w,searchStr) {}
  set tkText($w,searchStack) {}
  set tkText($w,searchDir) $dir
  set tkText($w,searchMode) $mode
  set tkText($w,searchHome) [$w index insert]
  set tkText($w,searchNdx) [$w index insert]

  if {![llength $tkBind($w,bindtags)]} {
    set tkBind($w,bindtags) [bindtags $w]
  }
  bindtags $w [concat TextISearch $tkBind($w,bindtags)]
  tkBindSetMesg $w {Isearch: }

}

proc tkTextISearchStop {w {setmark 1}} {
  global tkText tkBind

  if {[llength $tkBind($w,bindtags)]} {
    bindtags $w $tkBind($w,bindtags)
    set tkBind($w,bindtags) {}
  }
  if $setmark { 
    tkTextSetMark $w $tkText($w,searchHome) 
    set tkText($w,markActive) 0
  }

  foreach elem [list searchStr searchStack searchDir searchMode \
		    searchHome searchNdx] {
    unset tkText($w,$elem)
  }
  set tkText($w,prevCmd) ISearchStart
}

proc tkTextISearchNext {w str start} {
  global tkText tkBind

  set start [$w index $start]
  if {$tkText($w,searchDir) == "-forwards"} {
    set stop end } else { set stop 1.0 }
  if $tkBind(noCase) { set casesw "-nocase" } else { set casesw "--" }

  set ndx [$w search $tkText($w,searchDir) $tkText($w,searchMode) \
	   $casesw $str $start $stop]
  if [string length $ndx] {
    lvarpush tkText($w,searchStack) \
	[list $tkText($w,searchStr) $tkText($w,searchNdx) [$w index insert]]
    set tkText($w,searchNdx) $ndx
    set tkText($w,searchStr) $str
    tkBindSetMesg $w "Isearch: $str"
    if {$tkText($w,searchDir) == "-forwards"} {
      $w mark set insert \
	  [$w index "$ndx + [string length $tkText($w,searchStr)] chars" ]
    } else {
      $w mark set insert $ndx
    }
    $w see insert
    return 1
  } else {
    eval $tkBind(bell)
    return 0
  }
}

proc tkTextISearchAdd {w A} {
  global tkText tkBind

  if {$tkText($w,searchDir) == "-forwards"} {
    set start [$w index "$tkText($w,searchNdx) -1 char"]
  } else { 
    set start [$w index "insert + [expr [string length $tkText($w,searchStr)]+1] chars" ] 
  }

  set str $tkText($w,searchStr)
  append str $A

  if {[tkTextISearchNext $w $str $start]} {
    lvarpush tkText($w,searchStack) \
	[list $tkText($w,searchStr) $tkText($w,searchNdx) [$w index insert]]
    set tkText($w,searchStr) $str
    tkBindSetMesg $w "Isearch: $str"
    $w see insert
  }
}

proc tkTextISearchPop w {
  global tkText tkBind

  if [llength $tkText($w,searchStack)] {
    lvarpop tkText($w,searchStack)
    set data [lvarpop tkText($w,searchStack)]
    set tkText($w,searchStr) [lindex $data 0]
    set tkText($w,searchNdx) [lindex $data 1]
    $w mark set insert [lindex $data 2]
    tkBindSetMesg $w "Isearch: $tkText($w,searchStr)"
  } else {
    eval $tkBind(bell)
  }
}
