# $Id: beth-regions.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

## 23oct97 wmt: taken from beth package

# Assorted functions for regions of text
# 
# These functions assume text can be broken down into regions. Two types of
# regions are supported, local and global regions. Global regions make full
# use of the functions here, and receive some special keybindings, local regions
# may use as much or as little of the functionality here as desired.
#
# There are three functions that must be defined to implement global regions.
# They are:
#
# region_prev t index --- returns the start of the region before index
#				(which may be in or after that region)
#				Returns "" if no previous region exists.
#				(Could return index if index is at beginning)
#
# region_next t index --- returns the start of the region after index
#				or "" if no later region exists.
#				(Should never return index)
#
# region_end t index --- Given the beginning of a region (as in region_prev or
#				region_next), returns that region's ending.

# Returns range of region containing index, or ""
proc group_range {t index {begin_fn region_prev} {end_fn region_end}} {
	set region_begin [$begin_fn $t $index]
	if {$region_begin == ""} {return ""}
	set region_ending [$end_fn $t $region_begin]
	if {[$t compare $region_ending < $index]} {return ""}
	return [list $region_begin $region_ending]
}


# Moves insert to beginning of region, iff in region.
proc group_begin {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}
	move_insert $t [lindex $range 0]
}

# Moves insert to end of region, iff in region
proc group_end {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}
	move_insert $t [lindex $range 1]
}

# Returns beginning of region, or if already there, the beginning of 
# previous region
proc prev_group {t index {prev_fn region_prev}} {
	set region_begin [$prev_fn $t $index]
	if {$region_begin == ""} {return}
	if {[$t compare $region_begin < $index]} {return $region_begin
	} else {return [$prev_fn $t "$region_begin -1c"]}
}

# Selects region with index, or bells.
proc select_group {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}

	catch {$t tag remove sel sel.first sel.last}
	eval $t tag add sel $range
}


# if $edit_flag 

proc kill_group {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}

	global modified	;	set modified 1
	catch {.t_kill delete killed.first killed.last}
	catch {$t tag remove sel sel.first sel.last}
	set offset [string length [eval $t get $range]]
	.t_kill insert 1.0 [eval $t get $range]
	.t_kill tag add sel 1.0 "1.0 +$offset chars"
	.t_kill tag add killed 1.0 "1.0 +$offset chars"
	eval $t delete $range
}

proc delete_group_begin {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}
	delete_range $t [lindex $range 0] $index
}

proc delete_group_end {t index {begin_fn region_prev} {end_fn region_end}} {
	set range [group_range $t $index $begin_fn $end_fn]
	if {$range == ""} {bell ; return}
	delete_range $t $index [lindex $range 1]
}


# end curly-bracket for if $edit_flag start curly-bracket 

# Global region bindings
proc region_bind {f m {name "Region"} {index 0}} {
  global Keys edit_flag region_name
  set region_name $name
  parse_bindings Text \
      C-A			{group_begin %W insert} \
      C-E			{group_end %W insert} \
      C-j			{select_group %W insert} \
      C-N			{move_insert %W [region_next %W insert]} \
      C-P			{move_insert %W [prev_group %W insert]}

  if $edit_flag {	parse_bindings Text \
                            C-D			{delete_group_end %W insert} \
                            C-H			{delete_group_begin %W insert} \
                            C-U			{kill_group %W insert}
  }

#   if {[winfo exists $m]} {
#     parse_menuentries $m.browse.m.move [list [list $name $index "" \
#                                                   {Beginning 0 C-A} \
#                                                   {End 0 C-E} \
#                                                   {Previous 0 C-P} \
#                                                   {Next 0 C-N}]]
#     parse_menuentries $m.browse.m.select [list [list $name $index C-j]]

#     if $edit_flag {
#       parse_menuentries $m.edit.m.kill [list [list $name $index C-U]]
#       parse_menuentries $m.edit.m.delete [list [list $name $index "" \
#                                                     {Previous 0 C-H} \
#                                                     {Next 0 C-D}]]
#     }
#   }
}


# Note the caller of this module must call region_bind, so they can specify what
# to call regions (in the menus).
