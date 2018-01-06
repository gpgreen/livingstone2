# $Id: beth-balancebind.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Bindings for balancing paranethesis (and other character pairs)

# load_library_module regions.tcl

# Returns index of closest previous lone left partner, or "" if unsuccessful.
## 27oct97 wmt: add optional arg matchP -- to return matching left partner
proc find_left_pair {t index {left ""} {right ""} {matchP 0}} {
  global g_NM_leftMatchingParenLocation

  # puts stderr "find_left_pair: left $left right $right"
  if {($left == "") || ($right == "")} {
    global local_balance_list
    set left [lindex $local_balance_list 0]
    set right [lindex $local_balance_list 1]
  }
  set cleftParenCnt 0; set crightParenCnt 0
  set oleftParenCnt 0; set orightParenCnt 0
  set close_trace [$t index $index]
  set open_trace $close_trace
  # puts stderr "find_left_pair: matchP $matchP close_trace $close_trace open_trace $open_trace"
  while (1) {
    if {$matchP} {
      # puts stderr "find_left_pair: left `$left' right `$right'"
      set open_trace [text_string_last_match $t $left $open_trace 1.0 \
                         oleftParenCnt orightParenCnt]
      # puts stderr "find_left_pair(op): oleftParenCnt $oleftParenCnt orightParenCnt $orightParenCnt"
    } else {
      set open_trace [text_string_last $t $left $open_trace]
      set close_trace [text_string_last $t $right $close_trace $open_trace]
    }
    # puts stderr "find_left_pair(w): close_trace $close_trace open_trace $open_trace"
    if {! [string match $close_trace ""]} {
      set g_NM_leftMatchingParenLocation $open_trace
    }
    if {$matchP && ($oleftParenCnt == $orightParenCnt)} {
      return $open_trace 
    }
    if {$open_trace == ""} {
      return ""
    }
    if {$close_trace == ""} {
      return "$open_trace +1c"
    }
  }
}


# Returns index of closest next lone right partner, or "" if unsuccessful.
## 27oct97 wmt: add optional arg matchP -- to return first matching right partner
proc find_right_pair {t index {left ""} {right ""} {matchP 0}} {
  if {($left == "") || ($right == "")} {
    global local_balance_list
    set left [lindex $local_balance_list 0]
    set right [lindex $local_balance_list 1]
  }
  set cleftParenCnt 0; set crightParenCnt 0
  set oleftParenCnt 0; set orightParenCnt 0
  # next stmt does not give correct answer
#  set close_trace [$t index "$index -1c"]
  set close_trace [$t index $index]
  set open_trace $close_trace
  # puts stderr "find_right_pair: close_trace $close_trace open_trace $open_trace"
  while (1) {
    if {$matchP} {
      set close_trace [text_string_first_match $t $right $close_trace end \
                          cleftParenCnt crightParenCnt]
      # puts stderr "find_right_pair(cl): cleftParenCnt $cleftParenCnt crightParenCnt \
      #                   $crightParenCnt"
    } else {
      set open_trace [text_string_first $t $left "$open_trace +1c" $close_trace]
      set close_trace [text_string_first $t $right "$close_trace +1c"]
    }
    # puts stderr "find_right_pair(w): close_trace $close_trace open_trace $open_trace"

    if {$matchP && ($cleftParenCnt == $crightParenCnt)} {
      return $close_trace
    }
    if {$close_trace == ""} {
      return ""
    }
    if {$open_trace == ""} {
      return $close_trace
    }
  }
}


proc find_left_pair_out {t index {left ""} {right ""}} {
	set new [find_left_pair $t $index $left $right]
	if {$new == ""} {return} else {return "$new -1c"}
}

proc find_right_pair_out {t index {left ""} {right ""}} {
	set new [find_right_pair $t "$index +1c" $left $right]
	if {$new == ""} {return} else {return "$new +1c"}
}


# Prompting for a balancing cluster.

proc prompt_for_local_balance_aux {t f cmd c} {
	if {(![regexp . $c])} {return}
	destroy $f.bal
	parse_bindings  $t {Key C-Key M-Key C-M-Key} ""
	global local_balance_list balance_list
	foreach item $balance_list {foreach list_index {0 1} {
		if {$c == [lindex $item $list_index]} {
			set local_balance_list $item
			if {[catch "uplevel #0 [list $cmd]"]} {bell}
			return
	}}}
	bell ; return
}

proc prompt_for_local_balance {t f args} {
	label $f.bal -text "Which cluster?"
	pack append $f $f.bal {right}
	parse_bindings $t \
{Key C-Key M-Key C-M-Key} "prompt_for_local_balance_aux $t $f \{$args\} %A" \
}

proc goto_left_pair {t} {
	set new [find_left_pair $t insert]
	if {$new == ""} {bell ; return}
	move_insert $t $new
}

proc goto_right_pair {t} {
	set new [find_right_pair $t insert]
	if {$new == ""} {bell ; return}
	move_insert $t $new
}


# Highlighting matching paren (which involves ensuring balancing between other
# pairs as well)

# Counts instances of $c between $start and $end in $t
proc char_count {t c start end} {
	set offset 0 ; set count 0
	set c [string trimleft $c \\]
	while {([set trace [text_string_first $t $c $start $end]] != "")} {
		incr count
		set start [$t index "$trace +1c"]
	}
	return $count
}

# Checks if $left and $right occur the same # of times in [$start $end] of $t
proc balance_count {t left right start end} {
	set c1 [char_count $t $left $start $end]
	set c2 [char_count $t $right $start $end]
	if {($c1 > $c2)} {return "[string trimleft $left \\] [expr $c1-$c2]"}
	if {($c2 > $c1)} {return "[string trimleft $right \\] [expr $c2-$c1]"}
	return ""
}


## 27oct97 wmt: return result varible for use in moving to matched parens
##              and optional arg to handle matching partner calls
proc search_left_partner {t f left right {matchP 0} } {
  global balance_list local_balance_list
  global flash_time paren_match_p

  # puts stderr "search_left_partner: left $left right $right"
  catch {$t tag remove balance 1.0 end}
  set local_balance_list [list [string trimleft $left \\] [string trimleft $right \\]]
  set result [find_left_pair $t insert $left $right $matchP]
  # puts stderr "search_left_partner: result $result matchP $matchP"
  if {($result == "")} {
    set msg "No [string trimleft $left \\] found!!!"
    # bell
    # puts stderr "search_left_partner: bell $msg" 
  } else { 
    if {$matchP} {
      $t tag add balance $result "$result +1c"
    } else {
      $t tag add balance "$result -1c" $result
    }
    if {$paren_match_p} {
      # change background of left partner
      $t tag configure balance -background green
    }
    # after $flash_time $t tag remove balance 1.0 end
    foreach pair $balance_list {
      if {($left != [lindex $pair 0])} {
        set char [balance_count $t [lindex $pair 0] \
                      [lindex $pair 1] "$result -1c" insert]
        if {($char != "")} {
          set msg "Excess $char"
          # bell
          # puts stderr "search_left_partner: bell $msg"
          break
        } else {
          # set msg [$t get "$result linestart" $result]
          # this handles multi-line forms
          set msg [$t get 1.0 $result]
        }
      }
    }
  }
  set max_length 20
  if {([string length $msg] < $max_length)} {
    set width [string length $msg]
  } else {
    set width $max_length
  }
  if {! $matchP} {
    # puts stderr "search_left_partner: msg $msg"
    # do not put label in mini-buffer
    # flash_label $f -text $msg -relief raised -width $width -anchor e
  }
  return $result 
}


## move to left partner
## 27oct97 wmt: new
proc move_left_partner {t f left right} {
  global paren_match_p

  if {[textLispModeP $t]} {
    # puts stderr "move_left_partner"
    set matchP 1
    set result [search_left_partner $t $f $left $right $matchP]
    move_insert $t $result
    if {$paren_match_p} {
      # highlight matching paren
      search_right_partner $t $f $left $right $matchP
    }
  }
}


## 27oct97 wmt: adapted from search_left_paratner
proc search_right_partner {t f left right {matchP 0} } {
  global balance_list local_balance_list
  global flash_time paren_match_p

  # puts stderr "search_right_partner: left $left right $right"
  catch {$t tag remove balance 1.0 end}
  set local_balance_list [list [string trimleft $left \\] [string trimleft $right \\]]
  set result [find_right_pair $t insert $left $right $matchP]
  # puts stderr "search_right_partner: result $result matchP $matchP"
  if {($result == "")} {
    set msg "No [string trimleft $left \\] found!!!" ; bell
  } else {
    if {$matchP} {
      $t tag add balance "$result -1c" $result
    } else {
      $t tag add balance "$result +1c" $result
    }
    if {$paren_match_p} {
      # change background of left partner
      $t tag configure balance -background green
    }
    # after $flash_time $t tag remove balance 1.0 end
    foreach pair $balance_list {
      if {($left != [lindex $pair 0])} {
        set char [balance_count $t [lindex $pair 0] \
                      [lindex $pair 1] "$result +1c" insert]
        if {($char != "")} {
          set msg "Excess $char" ; bell ; break
        } else {
          set msg [$t get "$result linestart" $result]
        }
      }
    }
  }
  set max_length 20
  if {([string length $msg] < $max_length)} {
    set width [string length $msg]
  } else {
    set width $max_length
  }
  # do not put label in mini-buffer
  # flash_label $f -text $msg -relief raised -width $width -anchor e
  return $result 
}


## move to right partner
## 27oct97 wmt: new
proc move_right_partner {t f left right} {
  global paren_match_p

  if {[textLispModeP $t]} {
    # puts stderr "move_right_partner"
    set matchP 1
    set result [search_right_partner $t $f $left $right $matchP]
    move_insert $t $result
    if {$paren_match_p} {
      # highlight matching paren
      search_left_partner $t $f $left $right $matchP
    }
  }
}


## check for paren matching error prior to self insertion
## 27oct97 wmt: new
proc search_left_partner_and_insert { t f left right } {

  if {[textLispModeP $t]} {
    set result [search_left_partner $t $f $left $right]
    if {! [string match $result ""]} {
      self_insert $t $right
    }
  } else {
    self_insert $t $right
  }
}


# Balance bindings. f is a frame widget to put messages in.
## these bindings apply to both pure text widgets and Lisp mode
## text widgets, so a check with textLispModeP must be done in
## each function called -- 11dec97 wmt
proc balancebind {f m} {
  global balance_list edit_flag paren_match_p

  #  if {[winfo exists $m]} {make_cascade_entry $m.extras.m Find 0}

  if {$paren_match_p} {
    # use tkbind bindings system
    bind Text <Meta-Control-b> "move_left_partner %W $f \( \)"
    bind Text <Meta-Control-f> "move_right_partner %W $f \( \)"
  }

#   parse_bindings Text \
#       M-A		"prompt_for_local_balance %W $f goto_left_pair %W" \
#       M-E		"prompt_for_local_balance %W $f goto_right_pair %W" \
#       M-J		"prompt_for_local_balance %W $f select_group %W insert \
# 				find_left_pair_out find_right_pair_out"

#   if $edit_flag {parse_bindings Text \
#                      M-D		"prompt_for_local_balance %W $f delete_group_end %W insert \
# 				find_left_pair find_right_pair" \
#                      M-H		"prompt_for_local_balance %W $f delete_group_begin %W insert \
# 				find_left_pair find_right_pair" \
#                      M-U		"prompt_for_local_balance %W $f kill_group %W insert \
# 				find_left_pair_out find_right_pair_out"
#   }

#   if {[winfo exists $m]} {
#     parse_menuentries $m.browse.m.move {
#       {Expression 1 ""	 			{Beginning 0 M-A}
#         {End 0 M-E}}}
#     parse_menuentries $m.browse.m.select {{Expression 1 M-J}}

#     if $edit_flag {
#       parse_menuentries $m.edit.m.kill {{Expression 1 M-U}}
#       parse_menuentries $m.edit.m.delete {
#         {Expression 1 ""				{Previous 0 M-H}
#           {Next 0 M-D}}}
#     }}

  # key-sym insertions
  foreach pair $balance_list {
    set left_key [lindex $pair 0]
    set right_key [lindex $pair 1]
    set right_keysym [lindex $pair 3]
#     bind Text <$right_keysym> "search_left_partner %W $f \
# 						\\$left_key \\%A ;
# 				catch {self_insert %W %A}"
    # do this since above still inserts \) even if error signaled
    bind Text <$right_keysym> "search_left_partner_and_insert %W $f \
						\\$left_key \\$right_key"

#     if {[winfo exists $m]} {
#       make_command_entry $m.extras.m.find "Partner to" \
#           "$right_keysym $right_key"
#     }
  }
}

set balance_list {	{\( \) parenleft parenright}
			{\[ \] bracketleft bracketright}
			{\{ \} braceleft braceright}}
# balancebind $frame $menu

