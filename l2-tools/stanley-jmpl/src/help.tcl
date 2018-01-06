# $Id: help.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## help.tcl
## Help/Documentation Facility

## help table of contents
## 30jan96 wmt: attach dialog to ., so it cannot get "lost"
proc pirHelp {{w .help}} {
  global g_NM_schematicMode

  if {[winfo exists $w]} {
    raise $w
    return
  }
  toplevel $w -class Dialog 
  wm title $w "Help Table of Contents"
  wm geometry $w +200+100
  wm group $w [winfo toplevel [winfo parent $w]]

  message $w.m -text "Select Help Page(s) from the list below using the buttons to the left." \
    -width 400 -font [preferred StanleyHelpFont] \
      -background [preferred StanleyMenuDialogBackgroundColor] 
  pack $w.m -side top -fill x

  # Help pages
  frame $w.f1 -relief flat -background [preferred StanleyMenuDialogBackgroundColor]
  pack $w.f1 -side top -fill x
  set pageId 1vmpl
  if {[string match $g_NM_schematicMode "operational"]} {
    set pageId 1ops
  }
  button $w.f1.f  -relief raised -bd 2 -text ">" \
      -command "pirHelpPage $w $pageId $w.f1.l" 
  label  $w.f1.l -text "Setting up and Running Stanley" 
  pack $w.f1.f $w.f1.l -side left -padx 2 

    frame $w.f2 -relief flat -background [preferred StanleyMenuDialogBackgroundColor]
    pack $w.f2 -side top -fill x
    button $w.f2.f  -relief raised -bd 2 -text ">" \
        -command "pirHelpPage $w 2 $w.f2.l" 
    label  $w.f2.l -text "Building Schematics with Stanley VMPL" 
    pack $w.f2.f $w.f2.l -side left -padx 2 
  

#   if {[string match $g_NM_schematicMode "operational"]} {
#     frame $w.f3 -relief flat -background [preferred StanleyMenuDialogBackgroundColor]
#     pack $w.f3 -side top -fill x
#     button $w.f3.f  -relief raised -bd 4 -text " > " \
#         -command "pirHelpPage $w 3 $w.f3.l" 
#     label  $w.f3.l -text "Testing Livingstone's IPC Messages" 
#     pack $w.f3.f $w.f3.l -side left -padx 2 
#   }

  frame $w.f4 -relief flat -background [preferred StanleyMenuDialogBackgroundColor]
  pack $w.f4 -side top -fill x
  button $w.f4.f  -relief raised -bd 2 -text ">" \
    -command "pirHelpPage $w 4 $w.f4.l" 
  label  $w.f4.l -text "Mouse and Menu Conventions" 
  pack $w.f4.f $w.f4.l -side left -padx 2 

#  frame $w.f5 -relief flat 
#  pack $w.f5 -side top -fill x
#  button $w.f5.f  -relief raised -bd 4 -text " > " \
#    -command "pirHelpPage $w 5 $w.f5.l"
#  label  $w.f5.l -text "Reference: Menu Selections"
#  pack $w.f5.f $w.f5.l -side left -padx 2 

#  frame $w.f6 -relief flat 
#  pack $w.f6 -side top -fill x
#  button $w.f6.f  -relief raised -bd 4 -text " > " \
#    -command "pirHelpPage $w 6  $w.f6.l"
#  label  $w.f6.l -text "Internals"
#  pack $w.f6.f $w.f6.l -side left -padx 2 

  # bottom buttons
  frame $w.bot -bd 2 -background [preferred StanleyMenuDialogBackgroundColor]
  pack $w.bot -side top -fill x
  button $w.bot.dismiss -text DISMISS -relief raised \
     -command "destroy $w" 
  pack $w.bot.dismiss  -side left -expand 1
##     -side left -padx 5m -pady 2m -ipadx 2m -ipady 2m -expand 1

}


## obtain the description of a page from the label
proc pirHelpDescription {label} {
  return [lindex [$label config -text] 4]
}


## display a help page
## 30jan96 wmt: attach dialog to ., so it cannot get "lost"
proc pirHelpPage {ww page label} {
  global STANLEY_ROOT

  # exec .... does not work
  # this works except that if Netscape is in a different workspace
  # than Stanley, the Netscapw window is no shown to the user
  # AutoSat_Schematic_Object_Cmd Call_CSH "/opt/local/bin/netscape4.5 -raise -remote 'openFile(/home/serengeti/id0/taylor/web/report/2000.May.rax.html)'"
  # return

  set w $ww.p$page
  if {[winfo exists $w]} {
    raise $w
    return
  }
  toplevel $w -class Dialog 
  wm title $w [pirHelpDescription $label]
  wm geometry $w +200+100
  wm group $w [winfo toplevel [winfo parent $w]]

  frame $w.f -relief ridge -bd 2 
  set f $w.f
  pack $f -side top -fill x
  text $f.text -relief flat -bd 5 -yscrollcommand "$f.scroll set" \
      -background [preferred StanleyDialogEntryBackgroundColor]
  scrollbar $f.scroll -command "$f.text yview" 
  pack $f.scroll -side right -fill y
  pack $f.text -side left
  set path "$STANLEY_ROOT/help$page.txt"

  set file [open "$path" r]; # generates an error if fails
  while {![eof $file]} {
    $f.text insert end [read $file 1000]
  }
  close $file
  $f.text config -font [preferred StanleyHelpFont] \
             -state disabled
  frame $w.bot -bd 2 -background [preferred StanleyMenuDialogBackgroundColor]
  pack $w.bot -side bottom -fill x
  button $w.bot.dismiss -text DISMISS -relief raised \
     -command "destroy $w" 
  pack $w.bot.dismiss -side left -expand 1 
  ##   -side left -padx 5m -pady 2m -ipadx 2m -ipady 2m -expand 1
}
