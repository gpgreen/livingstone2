# $Id: beth-editbind.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Bindings for simple editing


# Flag set whenever text is modified. Any code that changes text should set
# modified to 1.
set modified 0


# Undo code

# Undos are handled thus: Each cmd that can be undone stores an entry into
# undo_data. This entry contains the code necessary to undo itself, a
# human-readable title to prompt the user with what it did, and a list of
# marks that were created to accomodate the undo code.
set undo_data {}

# Maximum length of undo_data. Once undo_data exceeds this limit, the oldest
# undo entries are purged. Setting to -1 means no limit.
set max_undos -1

# Maximum length of label showing last action done.
set max_undo_label 30

proc look_undo {t f} {
	global undo_data max_undo_label
	if {([llength $undo_data] == 0)} {bell ; return}
	set text "Last: [lindex [lindex $undo_data 0] 1]"
	if {([string length $text] > $max_undo_label)} {
		set text "[string range $text 0 $max_undo_label]..."}
	flash_label $f -text $text
}

proc kill_undo {t} {
	global undo_data
	foreach data $undo_data {
		foreach mark [lindex $data 2] {	$t mark unset $mark}}
	set undo_data ""
}

proc undo {t} {
	global undo_data modified
	if {([llength $undo_data] == 0)} {bell ; return}

	set data [lindex $undo_data 0]
	set undo_data [lrange $undo_data 1 end]

	set modified 1
	eval [lindex $data 0]
	foreach mark [lindex $data 2] {	$t mark unset $mark}
}

proc register_undoable_cmd {t code {name ""} {marks ""}} {
	global undo_data max_undos
	set new_entry [list $code $name $marks]
	set undo_data [concat [list $new_entry] $undo_data]
	if {($max_undos >= 0) && ($max_undos < [llength $undo_data])} {
		set purge_data [lindex $undo_data $max_undos]
		foreach mark [lindex $purge_data 2] {	$t mark unset $mark}
		set undo_data [lrange $undo_data 0 [expr "$max_undos - 1"]]
}}


# Selection code

set kill_mark ""

proc kill_next_line {t} {
	global modified;	set modified 1
	global kill_mark
	if {([$t get insert] == "\n")} {
		set end {insert +1 chars}
	} else {set end {insert lineend}}
	set killed [$t get insert $end]
	$t delete insert $end
	set offset [string length $killed]
	catch {.t_kill tag remove sel sel.first sel.last}

	if {($kill_mark == "") || [$t compare insert != $kill_mark]
		|| ![catch {.t_kill indes sel.first}]} {
		catch ".t_kill delete killed.first killed.last"
		set kill_mark [$t index insert]
	}

	if {[catch ".t_kill index killed.last" index]} {set index 1.0}
	.t_kill insert $index $killed
	.t_kill tag add sel 1.0 "$index +$offset chars"
	.t_kill tag add killed 1.0 "$index +$offset chars"
}

proc kill_region {t} {
	global modified	;	set modified 1
	if {![catch {set m [$t index mark]}]} {
		catch {.t_kill delete killed.first killed.last}
		if {[$t compare $m <= insert]} {
			set start $m
			set end insert
		} else {set start insert
			set end $m}
		catch {$t tag remove sel sel.first sel.last}
		.t_kill insert 1.0 [$t get $start $end]
		set offset [string length [$t get $start $end]]
		.t_kill tag add sel 1.0 "1.0 +$offset chars"
		.t_kill tag add killed 1.0 "1.0 +$offset chars"
		$t delete $start $end
}}

proc paste_selection {t} {
	if {[catch {set chars [$t get sel.first sel.last]}]} {
		if {[catch {set chars [selection get]}]} {
			set chars "" ; bell}}
	$t insert insert $chars
	$t yview -pickplace insert
	figure_out_undo_insert $t $chars
}

proc delete_selection {t} {
	if {[catch "$t index sel.last"]} {bell ; return}
	delete_range $t sel.first sel.last
}


# Quoting

proc unquote {t f c} {
	global modified	Keys ; set modified 1
	$t insert insert $c
	destroy $f.quote
	parse_bindings $t $Keys(A_C_Key) {}
}

proc key_quote {t f c} {
	global Keys
	if {([regexp . $c])} {
		destroy $f.quote ; bell
		parse_bindings $t $Keys(A_C_Key) {}
}}

proc quote_insert {t f} {
	label $f.quote -text "Quote"
	pack append $f $f.quote {right}
	parse_bindings $t \
Key				"key_quote $t $f %A" \
C-Key				"unquote $t $f %A"
}


# Transposition

proc transchars {t} {
	global modified	;	set modified 1
	set c1 [$t get {insert -1 chars}]
	set c2 [$t get insert]
	$t delete {insert -1 chars} {insert +1 chars}
	$t insert insert $c2
	$t insert insert $c1
	$t yview -pickplace insert
	return "$c1 $c2"
}

proc transpose_chars {t} {
	if {([$t compare insert <= 1.0])} {bell ; return}
	set transedchars [transchars $t]
	# Figure out how to undo transpose
	set uinsert [gensym]
	$t mark set $uinsert "insert -1 chars"
	register_undoable_cmd $t [list undo_transpose $t $uinsert transchars] "Transpose $transedchars" "$uinsert"
}

proc transwords {t} {
	set c1 [$t get insert {insert wordend}]
	$t delete insert {insert wordend}
	set c2 [$t get {insert -1 chars wordstart} insert]
	$t delete {insert -1 chars wordstart} insert
	set c3 [$t get {insert -1 chars wordstart} insert]
	$t delete {insert -1 chars wordstart} insert
	$t insert insert $c1
	$t insert insert $c2
	$t insert insert $c3
	$t yview -pickplace insert
	return "$c1$c2$c3"
}

proc transpose_words {t} {
	$t mark set insert {insert wordstart}
	if {([$t compare {insert -2 chars wordstart} <= 1.0])} {bell ; return}
	global modified	;	set modified 1
	set transedwords [transwords $t]
	# Figure out how to undo transpose
	set uinsert [gensym]
	$t mark set $uinsert "insert -1 chars wordstart"
	register_undoable_cmd $t [list undo_transpose $t $uinsert transwords] "Transpose $transedwords" "$uinsert"
}

proc undo_transpose {t uinsert fn} {
	$t mark set insert $uinsert
	$fn $t
}


# Filtering (upper/lowercase

proc filter_word {t filter} {
	if {([catch {$t get sel.first}])} {
		set start insert ; set end "insert wordend"
		set selected 0
	} else {set start sel.first ; set end sel.last
		set selected 1
	}
	set w [$t get $start $end]
	set new_w [$filter $w]

	if {($w == $new_w)} {move_insert $t "insert wordend" ; return}

	set new_wl [string length $new_w]
	$t delete $start $end
	$t insert insert $new_w
	if {($selected)} {$t tag add sel "insert -$new_wl chars" insert}
	$t yview -pickplace insert
	global modified ; set modified 1

	# Figure out how to undo filter
	set ustart [gensym] ; set uend [gensym]
	$t mark set $uend insert
	$t mark set $ustart "insert -$new_wl chars"
	register_undoable_cmd $t [list undo_filter $t $ustart $uend $w] "Case $w" "$ustart $uend"
}

proc undo_filter {t ustart uend w} {
	$t delete $ustart $uend ; $t insert $ustart $w
}


# Misc. editing functions

proc self_insert {t {c ""}} {

  if {(![regexp . $c])} {return}
  $t insert insert $c
  global overwrite_mode
  if $overwrite_mode {if {[$t get insert] != "\n"} {$t delete insert}}
  global modified	;	set modified 1
  $t yview -pickplace insert
}

proc delete_range {t start end {dont_undo ""}} {
	if {([$t compare $start >= $end])} {bell ; return}

	if {($dont_undo == "")} {
		# Figure out how to undo delete
		set dead [$t get $start $end]
		register_undoable_cmd $t [list $t insert [$t index $start] \
					$dead] "Delete $dead"
	}
	$t delete $start $end
	global modified	;	set modified 1
	$t yview -pickplace insert
}

proc newline {t} {
	global modified	;	set modified 1
	$t insert insert \n
	$t yview -pickplace insert
}

proc insert_return_backspace {t} {
	global modified	;	set modified 1
	$t insert insert \n
	move_insert $t {insert -1 chars}
	$t yview -pickplace insert
}

proc indent_with {t l e} {
	set prefix [$e get]
	destroy_f_entry $t $l $e

	if {([catch {$t index sel.first}])} {bell ; return}
	if {($prefix == "")} {bell ; return}
	set mark1 [$t index sel.first]
	set mark2 [$t index sel.last]

	set chars [$t get sel.first sel.last]
	set m1 [gensym] ; set m2 [gensym]
	register_undoable_cmd $t [list undo_filter $t $m1 $m2 $chars] "Indent $chars" "$m1 $m2"

	global modified
	for {set mark [$t index "sel.first linestart"]} \
			{[$t compare $mark < sel.last]} \
			{set mark [$t index "$mark +1 lines linestart"]} {
		$t insert $mark $prefix
		set modified 1
		}
	$t mark set $m1 "sel.first linestart"; $t mark set $m2 sel.last
	$t tag remove sel 1.0 end
	$t tag add sel $m1 $m2
}

# Prefixes every line in selected region with given string.
proc indent_region {t f} {
	global Keys
	create_f_entry $t $f.il $f.ie
	$f.il configure -text "Indent Prefix:"
	parse_bindings $f.ie $Keys(C_m) "indent_with $t $f.il $f.ie"
}

proc insert_file {t index f} {
	global fsBox read_msg last_io
	set path $fsBox(path);	set name $fsBox(name)
	if {([file_prompt $read_msg $f] == 0)} {return 0}
	set last_io "read"

	# Figure out how to undo insert
	set ustart [gensym];	set uend [gensym]
	$t mark set $uend $index
	load_and_insert_file $t $index $f $fsBox(path) $fsBox(name)
	$t mark set $ustart $index
	register_undoable_cmd $t [list $t delete $ustart $uend] "Insert $fsBox(name)" "$ustart $uend"

	global modified ; 	set modified 1
	set fsBox(path) $path;	set fsBox(name) $name
	return 1
}


# Edit bindings. f is a frame widget to put messages in.
proc editbind {f t m} {
	global Keys
	parse_bindings Text \
space			{} \
Key			{self_insert %W %A} \
$Keys(C_Delete)		{delete_selection %W} \
C-c			{+catch {.t_kill delete killed.first killed.last}} \
M-c			{filter_word %W string_capitalize} \
C-d			{delete_range %W insert {insert +1 char} 1} \
M-d			{delete_range %W insert {insert +1 chars wordend}} \
$Keys(C_h)		{delete_range %W {insert -1 char} insert 1} \
M-h			{delete_range %W {insert -2 chars wordstart} insert} \
M-C-i			"insert_file %W insert $f" \
C-k			{kill_next_line %W} \
M-l			{filter_word %W string_tolower} \
$Keys(C_m)		{newline %W} \
C-o			{insert_return_backspace %W} \
C-q			"quote_insert %W $f" \
C-t			{transpose_chars %W} \
M-t			{transpose_words %W} \
M-u			{filter_word %W string_toupper} \
C-w			{kill_region %W} \
$Keys(C_y)		{paste_selection %W}

	parse_bindings all \
C-g			"+catch \{destroy_f_entry $t $f.il $f.ie\}" \
C-i			"indent_region $t $f" \
M-C-k			"kill_undo $t" \
M-C-l			"look_undo $t $f" \
M-C-u			"undo $t"

# 	if {[winfo exists $m]} {
# 		parse_menuentries $m.extras.m {
# 					{"Indent Region" 0 C-i}
# {Undo 1	""				{Undo 0 M-C-u}
# 					{"Last Undo" 0 M-C-l}
# 					{"Kill Undo Log" 0 M-C-k}}}

# 		parse_menuentries $m.edit.m {
# 					{"Open line" 0 C-o}}

# 		parse_menuentries $m.file.m {
# 					{Insert 0 M-C-i}}

# 		$m.edit configure -state normal
# }
}


# editbind $frame $text $menu

# Add modified checkbutton
# catch {destroy $frame.fmb}
# checkbutton $frame.fmb -relief raised -variable modified -state disabled
# pack append $frame $frame.fmb {left}

# # Add 'killbuffer' text
# $text mark set kill_mark 1.0
# catch {text .t_kill}
# .t_kill delete 1.0 end
# .t_kill insert 1.0 "\n"
