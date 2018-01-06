# $Id: beth-browsebind.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Bindings for browsing (no editing). Includes scrolling, traversal, selection


# Selection code

proc select_next_line {t} {
	if {[catch "$t index sel.last"]} { set start insert
	} elseif {([$t compare insert < sel.first]) ||
		  ([$t compare insert > sel.last])} {
		$t tag remove sel sel.first sel.last
		set start insert
	} else {set start sel.first}
	if {($start == "insert")} {	set near $start
	} else { set near sel.last}
	if {([$t get $near] == "\n")} {
		$t tag add sel $start "$near +1 chars"
		} else {$t tag add sel $start "$near lineend"}
	move_insert $t sel.last
}

proc select_region {t} {
	if {![catch {set m [$t index mark]}]} {
		if {[$t compare $m <= insert]} {
			set start $m
			set end insert
		} else {set start insert
			set end $m}
		catch {$t tag remove sel sel.first sel.last}
		$t tag add sel $start $end
	} else {bell
}}

proc select_all {t} {
	catch "$t tag remove sel sel.first sel.last"
	$t tag add sel 1.0 end
}


# Cursor movement code

# Moves insert specified by index. Returns 1 if successful.
proc move_insert {t index} {
	if {[catch {$t compare insert == $index} flag]} {bell ; return 0}
	if $flag {bell ; return 0}
	$t mark set insert $index
	$t yview -pickplace insert
	return 1
}

# Used to naintain column while traversing across lines that are too short.
set column 0

proc adjacent_line {t d} {
	global column
	scan [$t index insert] "%d.%d" r c
	if {[$t compare insert == "insert $d lines"]} {
		if {([string first "+" $d] != -1)} {
			$t mark set insert end ; bell
		} else {$t mark set insert 1.0 ; bell}
	} elseif {($c < $column) && [$t compare insert == {insert lineend}]} {
		$t mark set insert "insert $d lines linestart"
		if {[$t compare "insert +$column chars" <= "insert lineend"]} {
			$t mark set insert "insert +$column chars"
		} else {$t mark set insert "insert lineend"}
	} elseif {[$t compare "insert $d lines" == "insert $d lines lineend"]} {
		$t mark set insert "insert $d lines"
		set column $c
	} else {$t mark set insert "insert $d lines"}

	if {[$t compare insert != {insert lineend}]} {	set column 0}
	$t yview -pickplace insert
}

proc center_cursor {t {v ""}} {
	if {($v == "")} {set v [lindex [$t configure -height] 4]}
	$t yview "insert -[expr "$v/2"] lines"
}

proc is_cursor_on_screen {t {v ""}} {
	if {($v == "")} {set v [lindex [$t configure -height] 4]}
	if {([$t compare insert < @0,0]) ||
	    ([$t compare insert >= "@0,0 +$v lines"])} {
		return 0} else {return 1
}}

proc ensure_cursor_on_screen {t {v ""}} {
	if {($v == "")} {set v [lindex [$t configure -height] 4]}
	if {![is_cursor_on_screen $t $v]} {
		$t mark set insert "@0,0 +[expr "$v/2"] lines"
}}

proc end_of_page {t} {
	set v [lindex [$t configure -height] 4]
	move_insert $t "@0,0 +$v lines -1 chars"
}

proc page_down {t} {
	set v [lindex [$t configure -height] 4]
	$t yview "@0,0 +[incr v -1] lines"
	ensure_cursor_on_screen $t $v
}

proc page_up {t} {
	set v [lindex [$t configure -height] 4]
	$t yview "@0,0 -[incr v -1] lines"
	ensure_cursor_on_screen $t $v
}


# Misc. browsing functions

proc exchange_dot_and_mark {t} {
	if {[catch {set m [$t index mark]}]} {bell ; return}
	$t mark set mark insert
	$t mark set insert $m
	$t yview -pickplace insert
}

proc goto_where {t l e} {
	set where [$e get]
	if {[regexp {[0-9]*} $where howmuch] && ($howmuch == $where)} {
		set where "$where.0 linestart"
	}
	destroy_f_entry $t $l $e
	move_insert $t $where
}

proc goto {t f} {
	create_f_entry $t $f.gotol $f.gotoe
	$f.gotol configure -text "Goto:"
	global Keys
	parse_bindings $f.gotoe $Keys(C_m) "goto_where $t $f.gotol $f.gotoe"
}

proc quit_beth {} {
	global quit_hook
	if {[info exists quit_hook]} {eval $quit_hook}
	exit
}


# Browse bindings.
proc browsebind {f t m} {
	global Keys
	parse_bindings Text \
C-space			{%W mark set mark insert} \
$Keys(C_a)		{move_insert %W {insert linestart}} \
$Keys(C_b) 		{move_insert %W {insert -1 chars}} \
M-b 			{move_insert %W {insert -1 chars wordstart}} \
C-c 			{%W tag add sel 1.0 ; %W tag remove sel 1.0 end} \
$Keys(C_e)		{move_insert %W {insert lineend}} \
$Keys(C_f)		{move_insert %W {insert +1 chars}} \
M-f			{move_insert %W {insert wordend}} \
{C-K C-k}		{select_next_line %W} \
C-l			{center_cursor %W} \
$Keys(C_n) 		"adjacent_line $t +1" \
$Keys(C_p) 		"adjacent_line $t -1" \
"$Keys(C_W) C-w"	{select_region %W} \
"$Keys(M_w)" 		{select_all %W} \
C-x 			{exchange_dot_and_mark %W} \
$Keys(M_comma) 		{move_insert %W @0,0} \
$Keys(M_period)		{end_of_page %W}

	parse_bindings all \
"$Keys(C_m) Delete" 	{bell} \
$Keys(A_Key)		{if {[regexp . %A]} {bell}} \
M-g			"goto $t $f" \
C-g 			"+ catch \{destroy_f_entry $t $f.gotol $f.gotoe\}" \
M-q 			{quit_beth} \
"$Keys(C_v) space" 	"page_down $t" \
$Keys(M_v) 		"page_up $t" \
C-z	 	"$t yview {@0,0 +1 lines} ; ensure_cursor_on_screen $t" \
M-z 		"$t yview {@0,0 -1 lines} ; ensure_cursor_on_screen $t" \
$Keys(M_less)	 	"move_insert $t 1.0" \
$Keys(M_greater) 	"move_insert $t end"

	if {[winfo exists $m]} {parse_menu $m \
{Browse 0	{Move 0 "" 	{Character 0 ""	{Back 0 C-b}
						{Forward 0 C-f}
						{Up 1 C-p}
						{Down 3 C-n}}
				{Word 0	""	{Back 0 M-b}
						{Forward 0 M-f}}
				{Edge 0	""	{Left 0 C-a}
						{Right 0 C-e}
						{Top 0 {M-comma {,}}} 
						{Bottom 0 {M-period {.}}}}}
		{Scroll 0 ""	{Line 0	""	{Up 0 M-z}
						{Down 0 C-z}}
				{Page 0	""	{Up 0 M-v}
						{Down 0 C-v}}
				{Document 0 ""	{Beginning 0 {M-less {<}}}
						{End 0 {M-greater {>}}}}}
		{Select	1 ""			{Line 0 C-K}
						{Region 0 C-W}
						{All 0 M-w}
						{Clear 0 C-c}}
		{Mark 3	""			{Set 0 {C-space { }}}
						{Exchange 1  C-x}}
						{"Center Cursor" 0 C-l}
						{"Goto Line" 0 M-g}} \
{File 0						{Quit 0 M-q}}
}}


# 27oct97 wmt: use tkbind bindings, rather than these
# browsebind $frame $text $menu
