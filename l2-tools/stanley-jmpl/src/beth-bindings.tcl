# $Id: beth-bindings.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Menu creation procedures
# and some binding routines.

global expand_binding_pairs 
set expand_binding_pairs {{C Control} {M Meta} {K Key} {S Shift} {A Any}}

# Expands M- into Meta-, C- into Control-, etc.
proc expand_binding {binding} {
	global expand_binding_pairs
	foreach pair $expand_binding_pairs {
		if {[string match "[lindex $pair 0]-*" $binding]} {
			return "[lindex $pair 1]-[expand_binding [string range \
				$binding 2 end]]"}}
	return $binding
}

# Returns a keybinding's generalization (Ex: Control-x -> Control-Key)
proc general_bind {binding} {
	set list [split $binding {-}]
	set length [llength $list]
	incr length -2
	if {$length == -1} {return Key
	} else {return "[join [lrange $list 0 $length] {-}]-Key"}
}

# Protects certain chars by preceding them with a \.
proc char_protect {c} {
	if {($c == {[}) || ($c == {]}) || ($c == " ") ||
		($c == "{") || ($c == "}")} {
		return "\\$c"} else {return $c}
}

# Given a key, returns its keybinding in the current widget.
proc return_menubinding {binding {c ""}} {
	set key_binding [general_bind $binding]
	if {[string length $binding] == 1} {set binding "Key-$binding"}
	set widget [focus]
	foreach spec "$widget [winfo class $widget] all" {
		if {[set cmd [bind $spec <$binding>]] != ""} {break}
		if {[set cmd [bind $spec <$key_binding>]] != ""} {break}
	}
	if {$cmd == ""} {bell ; return}		

	if {[regsub -all {%K} $cmd $binding new_cmd]} {set cmd $new_cmd}
	if {[regsub -all {%W} $cmd $widget new_cmd]} {set cmd $new_cmd}
	if {$c != ""} {if {[regsub -all {%A} $cmd [char_protect $c] new_cmd]} {
				set cmd $new_cmd}}
	return $cmd
}

# Binds winspec to all args. Args is in the following format:
# args = bindings command bindings command ...
# bindpair = {bindings command}
# bindings = {binding binding ...}
proc parse_bindings {winspec args} {
	set l [llength $args]
	for {set i 0} {$i < $l} {incr i 2} {
		foreach binding [lindex $args $i] {
			bind $winspec <[expand_binding $binding]> \
				[lindex $args [expr $i + 1]]
}}}


# Menu parsing.
# These routines make a set of menus from a quick menu list.
# Menu parsing is in the following format:
# menubutton = {name underline menuentries...}
# menuentries = menuentry menuentry...
# menuentry = {name underline "" menuentries} for cascade menuentrys
# menuentry = separator for separator entries
# menuentry = {name underline binding} for command entries.
# binding = {bind [char]}
# If char is different from keysym in bind, then include it.

# Creates a menubutton in the menubar, returns menubutton
proc make_menubutton {menu label {underline -1}} {
	set new_menubutton "$menu.[string tolower [lindex $label 0]]"
	set new_menu "$new_menubutton.m"
	menubutton $new_menubutton -menu $new_menu -text $label
	if {$underline >= 0} {$new_menubutton configure -underline $underline}
	menu $new_menu
	pack $new_menubutton -in $menu -side left
	return $new_menu
}

# Creates a cascade menu child, and adds it to its parent, with given label &
# underline, its parent must already exist.
# proc make_cascade_entry {menu label {underline -1}} {
# 	set cascade_menu $menu.[string tolower [lindex $label 0]]
#   puts stderr "make_cascade_entry: cascade_menu $cascade_menu"
# 	menu $cascade_menu
# 	$menu add cascade -label $label -menu $cascade_menu
# 	if {$underline >= 0} {
# 		$menu entryconfigure $label -underline $underline}
# 	return $cascade_menu
# }

proc make_cascade_entry {menu label {underline -1}} {

  set new_menu [make_menubutton $menu [lindex $label 0]]

  set cascade_menu $new_menu.[string tolower [lindex $label 0]]
  puts stderr "make_cascade_entry: cascade_menu $cascade_menu"
  # menu $cascade_menu
  $new_menu add cascade -label $label -menu $cascade_menu
  if {$underline >= 0} {
    $new_menu entryconfigure $label -underline $underline}
  return $cascade_menu
}

# Adds a command to menu.
proc make_command_entry {menu label binding {underline -1}} {
	set char ""
	if {[llength $binding] > 1} {	set char [lindex $binding 1]}
	set bind [expand_binding [lindex $binding 0]]
	set bindwords [split $bind {-}]
	set i [expr [llength $bindwords] -1]
	if {$char != ""} {				set accel $char
	} else {set accel [lindex $bindwords $i]
		if {[string length $accel] == 1} {	set char $accel}}
	set char [char_protect $char]
	for {incr i -1} {$i >= 0} {incr i -1} {
		set accel "[string index [lindex $bindwords $i] 0]-$accel"}
	$menu add command -label $label -accelerator $accel \
		-command "eval \[return_menubinding $bind $char\]"
	if {$underline >= 0} {
		$menu entryconfigure $label -underline $underline
}}

# Parses a menubutton
proc parse_menu {menu args} {
	foreach menubutton $args {
		set new_menu [make_menubutton $menu [lindex $menubutton 0] \
						[lindex $menubutton 1]]
		parse_menuentries $new_menu [lrange $menubutton 2 end]}
	eval tk_menuBar $menu [winfo children $menu]
}

# Parses a menuentries
proc parse_menuentries {menu entries} {
	foreach entry $entries {parse_menuentry $menu $entry
}}

# Parses a menuentry
proc parse_menuentry {menu entry} {
  puts stderr "parse_menuentry: entry $entry"
	if {$entry == "separator"} {
		$menu add separator
	} elseif {[lindex $entry 2] != ""} {
		make_command_entry $menu [lindex $entry 0] [lindex $entry 2] \
				[lindex $entry 1]
	} else {set c_menu [make_cascade_entry $menu [lindex $entry 0] \
							[lindex $entry 1]]
		foreach menuentry [lrange $entry 3 end] {
			parse_menuentry $c_menu $menuentry
}}}


# Other menu routines

# Activates or deactivates a series of entries (args) in a menu.
proc menuentries_change_state {m state args} {
	if {[winfo exists $m]} {foreach index $args {
		$m entryconfigure $index -state $state
}}}

# Create the menu frame (if it is not counterindicated)
# if {(![info exists dont_make_menubar])} {
# 	set menu .menu
# 	catch {frame $menu -relief raised}
#	pack $menu -side top -fill x
# wmt
# 	parse_bindings all \
# K-F10			{tk_firstMenu %W} \
# A-M-Key			{tk_traverseToMenu %W %A}
# } else {set menu 0}

# # Some important keys (that get duplicate bindings)
# set Keys(A_C_Key) {Key C-Key}
# set Keys(A_Key) "$Keys(A_C_Key) M-Key C-M-Key"
# set Keys(C_Delete) {C-Delete Button1-Delete}
# set Keys(C_a) {C-a S-Left}
# set Keys(C_b) {C-b Left}
# set Keys(C_e) {C-e S-Right}
# set Keys(C_f) {C-f Right}
# set Keys(C_h) {C-h Delete}
# set Keys(C_m) {C-m Return KP_Enter}
# set Keys(C_n) {C-n Down}
# set Keys(C_p) {C-p Up}
# set Keys(C_r) {C-r S-Find}
# set Keys(C_s) {C-s Find}
# set Keys(C_v) {C-v Next}
# set Keys(M_v) {M-v Prior}
# set Keys(C_W) {C-W Select}
# set Keys(M_w) {M-w S-Select}
# set Keys(C_y) {C-y Insert ButtonRelease-3}
# set Keys(M_comma) {M-comma S-Up}
# set Keys(M_period) {M-period S-Down}
# set Keys(M_less) {M-less S-Prior}
# set Keys(M_greater) {M-greater S-Next}
# set Keys(C_bracketleft) {C-bracketleft C-Up}
# set Keys(C_braceleft) {C-braceleft C-Down}
# set Keys(C_bracketright) {C-bracketright C-Left}
# set Keys(C_braceright) {C-braceright C-Right}
# set Keys(M_bracketright) {M-bracketright M-Left}
# set Keys(M_braceright) {M-braceright M-Right}
# set Keys(M_bracketleft) {M-bracketleft M-Up}
# set Keys(M_braceleft) {M-braceleft M-Down}
# set Keys(C_M_bracketright) {C-M-bracketright C-M-Left}
# set Keys(C_M_bracketleft) {C-M-bracketleft C-M-Up}
