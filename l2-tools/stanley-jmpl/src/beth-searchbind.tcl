# $Id: beth-searchbind.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Bindings for incremental and regexp search

# Functionally equivalent to saying [string first $string [$t get $start $end]]
# except the index of the found string is returned, not just a character offset.
# However, it runs faster when $start and $end are far apart and $string is
# close to $start.
#
# It seems that [$t get $start $end] is slow when start and end are far apart.
# So this routine searches first the line after start,
# then the next line after it, then the next two lines, the next four lines,
# on to the end, returning whenever the string is found.
# Since it does a line-by-line search, the string cannot contain newlines.
## 27oct97 wmt: check for "" start & end
proc text_string_first {t string {start 1.0} {end end}} {

  if {[string match $start ""] || [string match $end ""]} {
    return ""
  }
  set leftParenCnt 0; set rightParenCnt 0
  set start [$t index $start]
  set end [$t index $end]
  if {[$t compare "$start lineend" == "$end lineend"]} {
    set first_end $end
  } else {
    set first_end "$start lineend"
  }
  set result [string first $string [$t get $start $first_end]]
  if {$result != -1} {
    return "$start +$result chars"
  }
  # Not on line with start, start traversing down.
  scan $start "%d.%d" row dummy
  scan $end "%d.%d" end_row dummy
  if {$row == $end_row} {return ""}
  set incr_factor 1
  for {incr row} {[expr {$row + $incr_factor}] < $end_row} \
      {incr row $incr_factor
    set incr_factor [expr {$incr_factor * 2}]} {
      set result [string first $string [$t get "$row.0" \
                                            "$row.0 +$incr_factor lines -1c"]]
      if {$result != -1} {
        return "$row.0 + $result chars"
      }
    }
  # Not on any line, except maybe last.
  set result [string first $string [$t get "$row.0" $end]]
  if {$result != -1} {
    return "$row.0 + $result chars"
  } else {
    return ""
  }
}


## count (, {, [ in form
## 16mar00 wmt: new
proc incrLeftChar { stringRef leftCntRef char } {
  upvar $stringRef string
  upvar $leftCntRef leftCnt

  if {$char == "\("} {
    incr leftCnt [regsub -all "\\\(" $string "\(" tmp]
  } elseif {$char == "\{"} {
    incr leftCnt [regsub -all "\\\{" $string "\{" tmp]
  } elseif {$char == "\["} {
    incr leftCnt [regsub -all "\\\[" $string "\[" tmp]
  } else {
    puts stderr "incrLeftChar: char `$char' not handled"
  }
}
     
 
## count ), }, ] in form
## 16mar00 wmt: new
proc incrRightChar { stringRef rightCntRef char } {
  upvar $stringRef string
  upvar $rightCntRef rightCnt

  if {$char == "\)"} {
    incr rightCnt [regsub -all "\\\)" $string "\)" tmp]
  } elseif {$char == "\}"} {
    incr rightCnt [regsub -all "\\\}" $string "\}" tmp]
  } elseif {$char == "\]"} {
    incr rightCnt [regsub -all "\\\]" $string "\]" tmp]
  } else {
    puts stderr "incrRightChar: char `$char' not handled"
  }
}
     
 
## 16mar00 wmt: new
proc matchingChar {  char } {

  if {$char == "\("} {
    return "\)"
  } elseif {$char == "\{"} {
    return "\}"
  } elseif {$char == "\["} {
    return "\]"
  } elseif {$char == "\)"} {
    return "\("
  } elseif {$char == "\}"} {
    return "\{"
  } elseif {$char == "\]"} {
    return "\["
  } else {
    puts stderr "matchingChar : char `$char' not handled"
  }
}

  
## 27oct97 wmt: check for first matching s-exp => matching right paren
proc text_string_first_match {t string {start 1.0} {end end} leftParenCntRef \
                                  rightParenCntRef} {
  upvar $leftParenCntRef leftParenCnt
  upvar $rightParenCntRef rightParenCnt

  if {[string match $start ""] || [string match $end ""]} {
    return ""
  }
  set start [$t index $start]
  set end [$t index $end]
  if {[$t compare "$start lineend" == "$end lineend"]} {
    set first_end $end
  } else {
    set first_end "$start lineend"
  }
  set textString [$t get $start $first_end]
  # puts stderr "text_string_first_match: 1 textString `$textString'"
  set result [string first $string $textString]
  if {$result != -1} {
    if {[findRightParen $string $textString result leftParenCnt \
             rightParenCnt]} {
      return "$start +$result chars"
    }
  } else {
    # no right parens, are there left parens
    incrLeftChar textString leftParenCnt [matchingChar $string]
  }
  # Not on line with start, start traversing down.
  scan $start "%d.%d" row dummy
  scan $end "%d.%d" end_row dummy
  if {$row == $end_row} {
    return ""
  }
  # set str "text_string_first_match: end_row $end_row leftParenCnt"
  # puts stderr "$str $leftParenCnt rightParenCnt $rightParenCnt"
  for {incr row} {$row < $end_row} {incr row} {
    set textString [$t get "$row.0" "$row.0 lineend"] 
    # puts stderr "text_string_first_match: 2 row $row textString `$textString'"
    set result [string first $string $textString]
    if {$result != -1} {
      if {[findRightParen $string $textString result leftParenCnt \
               rightParenCnt]} {
        return "$row.0 + $result chars"
      }
    } else {
      # no right parens, are there left parens
      incrLeftChar textString leftParenCnt [matchingChar $string] 
    }      
    # set str "text_string_first_match: row $row leftParenCnt"
    # puts stderr "$str $leftParenCnt rightParenCnt $rightParenCnt"
  }
  # Not on any line, except maybe last.
  set textString [$t get "$row.0" $end] 
  # puts stderr "text_string_first_match: 3 row $row textString `$textString'"
  set result [string first $string $textString]
  if {$result != -1} {
    if {[findRightParen $string $textString result leftParenCnt \
             rightParenCnt]} {
      return "$row.0 + $result chars"
    } else {
      return ""
    }
  } else {
    # no right parens, are there left parens
    incrLeftChar textString leftParenCnt [matchingChar $string] 
    return ""
  }
}


## 10nov97 wmt: find right paren in textString; update leftParenCnt,
##              rightParenCnt, & result and return parenMatchP. 
##              If parenMatchP == 0, result will reflect position
##              at the end of textString.
proc findRightParen { paren textString resultRef leftParenCntRef \
                          rightParenCntRef } {
  upvar $resultRef result
  upvar $leftParenCntRef leftParenCnt
  upvar $rightParenCntRef rightParenCnt

  # puts stderr "\n\nfindRightParen1-in: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
  # puts stderr "findRightParen1-in: textString `$textString'"
  set parenMatchP 0
  set lenTextString [string length $textString]
  set tmpString [string range $textString 0 $result] 
  # puts stderr "findRightParen: tmpString `$tmpString'"
  incrLeftChar tmpString leftParenCnt [matchingChar $paren]
  incrRightChar tmpString rightParenCnt $paren 
  # puts stderr "findRightParen1: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
  incr result
  if {($leftParenCnt - $rightParenCnt) > 0} {
    set i 0
    while {1} {
      set tmpString [string range $textString $result end]
      # puts stderr "findRightParen: result $result tmpString `$tmpString'"
      set subResult [string first $paren $tmpString]
      if {$subResult != -1} {
        set subTmpString [string range $tmpString 0 $subResult]
        # puts stderr "findRightParen: subResult $subResult subTmpString `$subTmpString'"
        incrLeftChar subTmpString leftParenCnt [matchingChar $paren]
        incrRightChar subTmpString rightParenCnt $paren 
        # puts stderr "findRightParen2: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
        if {$leftParenCnt == $rightParenCnt} {
          set parenMatchP 1 
          break
        }
      } else {
        # no right parens, are there left parens
        incrLeftChar tmpString leftParenCnt [matchingChar $paren]
        set subResult [expr {[string length $tmpString] - 1}]
      }
      incr result [expr {1 + $subResult}]
      # puts stderr "findRightParen: result $result lenTextString $lenTextString"
      if {$result >= $lenTextString} {
        break
      }
      incr i
      if {$i > 100} {
        puts stderr "findRightParen: error in paren logic"
        break
      }
    }
    incr result 
  } else {
    set parenMatchP 1
  }
  return $parenMatchP 
}


# Like [string last [$t get $start $end]], but more efficient if $string is
# close to $end.
## 27oct97 wmt: check for "" start & end
proc text_string_last {t string {end end} {start 1.0}} {

  if {[string match $start ""] || [string match $end ""]} {
    return ""
  }
  set start [$t index $start]
  set end [$t index $end]
  if {[$t compare "$start linestart" == "$end linestart"]} {
    set first_start $start
  } else {set first_start "$end linestart"}
  set result [string last $string [$t get $first_start $end]]
  if {$result != -1} {return "$first_start +$result chars"}
  # Not on line with end, start traversing up
  scan $start "%d.%d" start_row dummy
  scan $end "%d.%d" row dummy
  if {$row == $start_row} {return ""}
  set incr_factor 1
  for {incr row -1} {[expr {$row - $incr_factor}] > $start_row} \
      {set incr_factor [expr {$incr_factor * 2}]
    incr row -$incr_factor} {
      set result [string last $string [$t get "$row.0" \
                                           "$row.0 +$incr_factor lines -1c"]]
      if {$result != -1} {return "$row.0 + $result chars"}
    }
  # Not on any line, except maybe first
  incr row $incr_factor
  set result [string last $string [$t get $start "$row.0 -1c"]]
  if {$result != -1} {return "$start + $result chars"
  } else {return ""}
}


## 27oct97 wmt: check for first matching s-exp => matching left paren
## 14nov97 wmt: added countAllParensP, which is used by tkTextInsertChar
##              to insert blanks for Lisp indenting
proc text_string_last_match {t string {end end} {start 1.0} leftParenCntRef \
                                 rightParenCntRef {countAllParensP 0} } {
  upvar $leftParenCntRef leftParenCnt
  upvar $rightParenCntRef rightParenCnt

  if {[string match $start ""] || [string match $end ""]} {
    return ""
  }
  # puts stderr "text_string_last_match1: start $start end $end"
  set start [$t index $start]
  set end [$t index $end]
  if {[$t compare "$start linestart" == "$end linestart"]} {
    set first_start $start
  } else {
    set first_start "$end linestart"
  }
  # puts stderr "text_string_last_match1: first_start $first_start end $end"
  set textString [$t get $first_start $end] 
  # puts stderr "text_string_last_match: string `$string' textString `$textString'" 
  set result [string last $string $textString] 
  # puts stderr "text_string_last_match: B result $result"
  if {$result != -1} { 
    if {[findLeftParen $string $textString result leftParenCnt \
             rightParenCnt $countAllParensP]} {
      if {! $countAllParensP} {
        return "$first_start +$result chars"
      }
    }
  } else {
    # no left parens, are there right parens
    incrRightChar textString rightParenCnt [matchingChar $string]
  }
  # puts stderr "text_string_last_match: A result $result"
  # Not on line with end, start traversing up
  scan $start "%d.%d" start_row dummy
  scan $end "%d.%d" row dummy
  if {$row == $start_row} {
    return ""
  }
  # set str "text_string_last_match: start_row $start_row leftParenCnt"
  # puts stderr "$str $leftParenCnt rightParenCnt $rightParenCnt"
  for {incr row -1} {$row > $start_row} { incr row -1} {
      set textString [$t get "$row.0" "$row.0 lineend"] 
    # puts stderr "text_string_last_match: row $row textString `$textString'"
    set result [string last $string $textString]
    if {$result != -1} {
      if {[findLeftParen $string $textString result leftParenCnt \
               rightParenCnt $countAllParensP]} {
        if {! $countAllParensP} {
          return "$row.0 + $result chars"
        }
      }
    } else {
      # no left parens, are there right parens
      incrRightChar textString rightParenCnt [matchingChar $string]
    }      
    # set str "text_string_last_match: row $row leftParenCnt"
    # puts stderr "$str $leftParenCnt rightParenCnt $rightParenCnt"
  }
  # Not on any line, except maybe first
  set textString [$t get $start "$row.0 lineend"] 
  set result [string last $string $textString]
  # puts stderr "text_string_last_match0: row $row textString `$textString'"
  if {$result != -1} {
    if {[findLeftParen $string $textString result leftParenCnt \
             rightParenCnt $countAllParensP]} {
      return "$start + $result chars"
    } else {
      return ""
    }
  } else {
    # no left parens, are there right parens
    incrRightChar textString rightParenCnt [matchingChar $string]
    return ""
  }
}


## 10nov97 wmt: find left paren in textString; update leftParenCnt,
##              rightParenCnt, & result and return parenMatchP. 
##              If parenMatchP == 0, result will reflect position
##              at the end of textString.
## 14nov97 wmt: added countAllParensP, which is used by tkTextInsertChar
##              to insert blanks for Lisp indenting
proc findLeftParen { paren textString resultRef leftParenCntRef \
                         rightParenCntRef {countAllParensP 0} } {
  upvar $resultRef result
  upvar $leftParenCntRef leftParenCnt
  upvar $rightParenCntRef rightParenCnt

  # puts stderr "findLeftParen1-in: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
  # puts stderr "findLeftParen1-in: textString `$textString'"
  set parenMatchP 0
  set tmpString [string range $textString $result end] 
  # puts stderr "findLeftParen: tmpString `$tmpString'"
  incrLeftChar tmpString leftParenCnt $paren
  incrRightChar tmpString rightParenCnt [matchingChar $paren]
  # puts stderr "findLeftParen1: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
  if {$countAllParensP || (($rightParenCnt - $leftParenCnt) > 0)} {
    set i 0; incr result -1 
    while {1} {
      set tmpString [string range $textString 0 $result]
      set subResult [string last $paren $tmpString]
      # puts stderr "findLeftParen: result $result subResult $subResult tmpString `$tmpString'"
      if {$subResult == -1} {
        break
      }
#       if {$subResult != 0} {
#         incr subResult -1
#       }
      if {$subResult != -1} {
        set subTmpString [string range $tmpString $subResult end]
        # puts stderr "findLeftParen: subResult $subResult subTmpString `$subTmpString'"
        incrLeftChar subTmpString leftParenCnt $paren
        incrRightChar subTmpString rightParenCnt [matchingChar $paren] 
        # puts stderr "findLeftParen2: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
        if {(! $countAllParensP) && ($leftParenCnt == $rightParenCnt)} {
          set result $subResult
          # puts stderr "findLeftParen2: result $result"
          set parenMatchP 1 
          break
        }
      } else {
        # no left parens, are there right parens
        incrRightChar tmpString rightParenCnt [matchingChar $paren] 
        set subResult 1
      }
      set result [expr ($subResult - 1)]
      # puts stderr "findLeftParen: break result $result"
      if {$result < 0} {
        break
      }
      incr i
      if {$i > 100} {
        puts stderr "findLeftParen: error in paren logic"
        break
      }
    }
  } else {
    set parenMatchP 1
  }
  # puts stderr "findLeftParenR: leftParenCnt $leftParenCnt rightParenCnt $rightParenCnt"
  return $parenMatchP 
}


# Find_forward and find_reverse can be used by other procedures; they have
# no visible effects.

# Finds first occurrence of string after point in text widget t
# Returns start and end of occurance or "" if unsuccessful.
proc find_forward {t point string} {
	set answer [text_string_first $t $string $point]
	if {($answer == "")} {return ""
	} else {return [list "$answer" "$answer +[string length $string] chars"]
}}

# Finds first occurrence of string before point in text widget t
# Returns start and end of occurance or "" if unsuccessful.
proc find_reverse {t point string} {
	set answer [text_string_last $t $string $point]
	if {($answer == "")} {return ""
	} else {return [list $answer "$answer +[string length $string] chars"]
}}

# A regular expression searcher
# Finds first occurrence of regular expression after point in text widget t
# Returns start and end of first occurance or "" if unsuccessful.
proc regexp_find_forward {t point exp} {
	if {[catch {set success [regexp -indices $exp [$t get $point end] where]}]} {set success 0}
	if {($success == 0)} {return ""
	} else {return [list "$point +[lindex $where 0] chars" \
				"$point +[lindex $where 1] chars +1 chars"]
}}

# Informs user of success or failure of search and resets search tag.
proc search_any {t f success_msg failure_msg search_fn search_string direction} {
	set was_search_area [$t tag nextrange search 1.0 end]
	if {[llength $was_search_area] == 2} {
		eval $t tag remove search $was_search_area
		eval $t tag add was_search $was_search_area
	}
	set length [string length $search_string]
	if {($length == 0)} {return 0}

	set slist [$search_fn $t insert $search_string]
	if {($slist != "")} {
		$t tag add search [lindex $slist 0] [lindex $slist 1]
		$f.s configure -text $success_msg
		if {($direction == "s")} {	$t mark set insert search.first
		} else {			$t mark set insert search.last}
		$t yview -pickplace insert
		return 1
	} else {$f.s configure -text $failure_msg ; bell
		return 0
}}

# Direction we're searching. "s" == forward, "r" == reverse
set direction "s"

proc re_search {t f success_msg failure_msg search_fn search_string d} {
	global direction
	set direction $d
	set new_index [$t index insert]

	if {($d == "s")} {
		if {[lindex [$f.s configure -text] 4] == $failure_msg} {
			$t mark set insert 1.0
		} else {$t mark set insert {insert +1 chars}
			if {[catch {set new_index [$t index search.last]}]} {
				set new_index [$t index "insert +1 chars"]}}
	} else {
		if {[lindex [$f.s configure -text] 4] == $failure_msg} {
			$t mark set insert end
		} else {$t mark set insert {insert -1 chars}
			if {[catch {set new_index [$t index search.first]}]} {
				set new_index [$t index "insert -1 chars"]}}
	}

	search_any $t $f $success_msg $failure_msg $search_fn \
				$search_string $direction
	if {[lindex [$f.s configure -text] 4] == $failure_msg} {
		$t mark set insert $new_index}
}

proc exit_search {t f c} {
	if {![regexp . $c]} {return}
	$t tag remove search 1.0 end
	$t tag remove was_search 1.0 end
	destroy_f_entry $t $f.s $f.ss
	global menu ; menuentries_change_state $menu.search.m normal 3 4 6
}

# Messages
set search_msg "Search: "
set reverse_search_msg "Reverse Search: "
set search_failed_msg "Search failed: "
set reverse_search_failed_msg "Reverse Search failed: "
set regexp_msg "Regexp Search: "
set regexp_failed_msg "Regexp Search Failed: "

# The string currently being searched for (it's bound to the search entry)
set search_string ""

# Called whenever key is hit in entry during incremental search.
proc revise_search {t f c} {
	global search_msg reverse_search_msg direction
	global search_failed_msg reverse_search_failed_msg search_string
	if {![regexp . $c]} {return}
	if {($direction == "s")} {set result [search_any $t $f $search_msg $search_failed_msg find_forward $search_string $direction]
	}  else {$t mark set insert {insert +1 chars}
		set result [search_any $t $f $reverse_search_msg $reverse_search_failed_msg find_reverse $search_string $direction]}
}

proc make_search_incremental {t f} {
	foreach binding [bind Entry] {
		if {([bind $f.ss $binding] == "")} {
			bind $f.ss $binding "[bind Entry $binding]
						revise_search $t $f %A"}}
}

# For any general type of search
proc search_setup {t f success_msg failure_msg search_function} {
	global Keys
	create_f_entry $t $f.s $f.ss
	$f.ss configure -textvariable search_string
	parse_bindings $f.ss \
$Keys(C_m)	"exit_search $t $f x" \
$Keys(C_s)	"re_search $t $f \"$success_msg\" \"$failure_msg\" \
					 $search_function \[$f.ss get\] s"
}

# For regular expression searches
proc regexp_search_setup {t f m} {
	global regexp_msg regexp_failed_msg
	search_setup $t $f $regexp_msg $regexp_failed_msg regexp_find_forward
	$f.s configure -text $regexp_msg
}

# For forward and reverse searching
## 27ocy97 wmt: do a catch on was_search 
proc bidirectional_search_setup {t f d} {
  global search_msg reverse_search_msg direction Keys
  global search_failed_msg reverse_search_failed_msg search_string

  catch { $t tag lower was_search }
  search_setup $t $f $search_msg $search_failed_msg find_forward

  if {($d == "s")} {$f.s configure -text $search_msg
  } else {	$f.s configure -text $reverse_search_msg}
  set direction $d

  parse_bindings $f.ss $Keys(C_r) "re_search $t $f \"$reverse_search_msg\" \"$reverse_search_failed_msg\" find_reverse \[$f.ss get\] r"
}

proc reset_search {} {	global search_string ; set search_string ""}


# Search bindings. f is a frame widget to put messages in.
proc searchbind {f t m} {
	global Keys
	parse_bindings all \
C-g		"+ catch \{exit_search $t $f x\}" \
$Keys(C_r)	"reset_search ; \
	bidirectional_search_setup $t $f r ; make_search_incremental $t $f" \
$Keys(C_s)	"reset_search ; \
	bidirectional_search_setup $t $f s ; make_search_incremental $t $f" \
C-R "bidirectional_search_setup $t $f r ; make_search_incremental $t $f" \
C-S "bidirectional_search_setup $t $f s ; make_search_incremental $t $f" \
C-M-s		"set search_string {} ; regexp_search_setup $t $f $m"

# 	if {[winfo exists $m]} {parse_menu $m \
# {Search 0			{"Search Forward" 0 C-s}
# 				{"Reverse Search" 0 C-r}
# 			separator
# 				{"Search Previous" 5 C-S}
# 				{"Reverse Search Previous" 2 C-R}
# 			separator
# 				{"Search Regular Expression" 15 M-C-s}}

# # Set the menuoptions to C-S, C-R, and M-C-s to be disabled upon entering search
# 		global search_bindings
# 		parse_bindings all \
# $search_bindings "+ menuentries_change_state $m.search.m disabled 3 4 6"
# }
}


# set search_bindings "$Keys(C_r) $Keys(C_s) M-C-s"

# searchbind $frame $text $menu
