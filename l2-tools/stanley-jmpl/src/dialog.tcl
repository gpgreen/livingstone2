# $Id: dialog.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# dialog.tcl --
# the first part of this file comes from tclTk8.3/lib/tk8.3/dialog.tcl
# release tclTk8.3.2
# use my preferences to set font
## locate dialog window beside pointerx/y, rather than in middle of canvas
#
#
# This file defines the procedure tk_dialog, which creates a dialog
# box containing a bitmap, a message, and one or more buttons.
#
# SCCS: @(#) dialog.tcl 1.26 96/05/07 09:30:31
#
# Copyright (c) 1992-1993 The Regents of the University of California.
# Copyright (c) 1994-1996 Sun Microsystems, Inc.
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#

#
# tk_dialog:
#
# This procedure displays a dialog box, waits for a button in the dialog
# to be invoked, then returns the index of the selected button.  If the
# dialog somehow gets destroyed, -1 is returned.
#
# Arguments:
# w -		Window to use for dialog top-level.
# title -	Title to display in dialog's decorative frame.
# text -	Message to display in dialog.
# bitmap -	Bitmap to display in dialog (empty string means none).
# default -	Index of button that is to display the default ring
#		(-1 means none).
# args -	One or more strings to display in buttons across the
#		bottom of the dialog box.

proc tk_dialog {w title text bitmap default args} {
  global tkPriv tcl_platform g_NM_currentCanvas

    # Check that $default was properly given
    if {[string is int $default]} {
	if {$default >= [llength $args]} {
	    return -code error "default button index greater than number of\
		    buttons specified for tk_dialog"
	}
    } elseif {[string equal {} $default]} {
	set default -1
    } else {
	set default [lsearch -exact $args $default]
    }

  # 1. Create the top-level window and divide it into top
  # and bottom parts.

  catch {destroy $w}
  toplevel $w -class Dialog
  wm title $w $title
  wm iconname $w Dialog
  wm protocol $w WM_DELETE_WINDOW 

  # Dialog boxes should be transient with respect to their parent,
  # so that they will always stay on top of their parent window.  However,
  # some window managers will create the window as withdrawn if the parent
  # window is withdrawn or iconified.  Combined with the grab we put on the
  # window, this can hang the entire application.  Therefore we only make
  # the dialog transient if the parent is viewable.
  #
  if { [winfo viewable [winfo toplevel [winfo parent $w]]] } {
    wm transient $w [winfo toplevel [winfo parent $w]]
  }    

  if {[string equal $tcl_platform(platform) "macintosh"]} {
    unsupported1 style $w dBoxProc
  }

  frame $w.bot
  frame $w.top
  if {[string equal $tcl_platform(platform) "unix"]} {
    $w.bot configure -relief raised -bd 1
    $w.top configure -relief raised -bd 1
  }
  pack $w.bot -side bottom -fill both
  pack $w.top -side top -fill both -expand 1

  # 2. Fill the top part with bitmap and message (use the option
  # database for -wraplength so that it can be overridden by
  # the caller).

  # do this in resetOptionDatabase
#   option add *Dialog.msg.wrapLength 3i widgetDefault

#   if {[string equal $tcl_platform(platform) "macintosh"]} {
#     option add *Dialog.msg.font system widgetDefault
#   } else {
#     option add *Dialog.msg.font {Times 12} widgetDefault
#   }

  label $w.msg -justify left -text $text  
  pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 3m -pady 3m
  if {[string compare $bitmap ""]} {
    if {[string equal $tcl_platform(platform) "macintosh"] && \
            [string equal $bitmap "error"]} {
      set bitmap "stop"
    }
    label $w.bitmap -bitmap $bitmap
    pack $w.bitmap -in $w.top -side left -padx 3m -pady 3m
  }

  # 3. Create a row of buttons at the bottom of the dialog.

  set i 0
  foreach but $args {
    button $w.button$i -text $but -command [list set tkPriv(button) $i]
    if {$i == $default} {
      $w.button$i configure -default active
    } else {
      $w.button$i configure -default normal
    }
    grid $w.button$i -in $w.bot -column $i -row 0 -sticky ew -padx 10
    grid columnconfigure $w.bot $i
    # We boost the size of some Mac buttons for l&f
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      set tmp [string tolower $but]
      if {[string equal $tmp "ok"] || [string equal $tmp "cancel"]} {
        grid columnconfigure $w.bot $i -minsize [expr {59 + 20}]
      }
    }
    incr i
  }

  # 4. Create a binding for <Return> on the dialog if there is a
  # default button.

  if {$default >= 0} {
    bind $w <Return> "
	[list $w.button$default] configure -state active -relief sunken
	update idletasks
	after 100
	set tkPriv(button) $default
	"
  }

  # 5. Create a <Destroy> binding for the window that sets the
  # button variable to -1;  this is needed in case something happens
  # that destroys the window, such as its parent window being destroyed.

  bind $w <Destroy> {set tkPriv(button) -1}

  # 6. Withdraw the window, then update all the geometry information
  # so we know how big it wants to be, then center the window in the
  # display and de-iconify it.

  wm withdraw $w
  update idletasks

  if [catch { getCanvasRootInfo g_NM_currentCanvas } currentCanvas] {
    set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
                     - [winfo vrootx [winfo parent $w]]}]
    set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
                     - [winfo vrooty [winfo parent $w]]}]
    wm geom $w +$x+$y
  } else {
    set x [winfo pointerx $currentCanvas] 
    set y [winfo pointery $currentCanvas]
    if {($y + [winfo reqheight $w] + 25) > [winfo screenheight $w]} {
      set y [expr {$y - [winfo reqheight $w] - 15}]
    }
    if {($x + [winfo reqwidth $w] + 25) > [winfo screenwidth $w]} {
      set x [expr {$x - [winfo reqwidth $w] - 15}]
    }
    wm geometry $w "+[expr {$x + 20}]+${y}"
  }

  wm deiconify $w

  # 7. Set a grab and claim the focus too.

  set oldFocus [focus]
  set oldGrab [grab current $w]
  if {[string compare $oldGrab ""]} {
    set grabStatus [grab status $oldGrab]
  }
  grab $w
  if {$default >= 0} {
    focus $w.button$default
  } else {
    focus $w
  }

  # 8. Wait for the user to respond, then restore the focus and
  # return the index of the selected button.  Restore the focus
  # before deleting the window, since otherwise the window manager
  # may take the focus away so we can't redirect it.  Finally,
  # restore any grab that was in effect.

  tkwait variable tkPriv(button)
  catch {focus $oldFocus}
  catch {
    # It's possible that the window has already been destroyed,
    # hence this "catch".  Delete the Destroy handler so that
    # tkPriv(button) doesn't get reset by it.

    bind $w <Destroy> {}
    destroy $w
  }
  if {[string compare $oldGrab ""]} {
    if {[string compare $grabStatus "global"]} {
      grab $oldGrab
    } else {
      grab -global $oldGrab
    }
  }
  return $tkPriv(button)
}


## =============================================================

## use while Emacs Lisp editing is going on
proc tk_dialogNoGrab {w title text bitmap default args} {
  global tkPriv tcl_platform 

  # Check that $default was properly given
  if {[string is int $default]} {
    if {$default >= [llength $args]} {
      return -code error "default button index greater than number of\
		    buttons specified for tk_dialog"
    }
  } elseif {[string equal {} $default]} {
    set default -1
  } else {
    set default [lsearch -exact $args $default]
  }

  # 1. Create the top-level window and divide it into top
  # and bottom parts.

  catch {destroy $w}
  toplevel $w -class Dialog
  wm title $w $title
  wm iconname $w Dialog
  wm protocol $w WM_DELETE_WINDOW { }

  # Dialog boxes should be transient with respect to their parent,
  # so that they will always stay on top of their parent window.  However,
  # some window managers will create the window as withdrawn if the parent
  # window is withdrawn or iconified.  Combined with the grab we put on the
  # window, this can hang the entire application.  Therefore we only make
  # the dialog transient if the parent is viewable.
  #
  if { [winfo viewable [winfo toplevel [winfo parent $w]]] } {
    wm transient $w [winfo toplevel [winfo parent $w]]
  }    

  if {[string equal $tcl_platform(platform) "macintosh"]} {
    unsupported1 style $w dBoxProc
  }

  frame $w.bot
  frame $w.top
  if {[string equal $tcl_platform(platform) "unix"]} {
    $w.bot configure -relief raised -bd 1
    $w.top configure -relief raised -bd 1
  }
  pack $w.bot -side bottom -fill both
  pack $w.top -side top -fill both -expand 1

  # 2. Fill the top part with bitmap and message (use the option
  # database for -wraplength so that it can be overridden by
  # the caller).

  # do this in resetOptionDatabase
#   option add *Dialog.msg.wrapLength 3i widgetDefault
#   if {[string equal $tcl_platform(platform) "macintosh"]} {
#     option add *Dialog.msg.font system widgetDefault
#   } else {
#     option add *Dialog.msg.font {Times 12} widgetDefault
#   }

  label $w.msg -justify left -text $text 
  pack $w.msg -in $w.top -side right -expand 1 -fill both -padx 3m -pady 3m
  if {[string compare $bitmap ""]} {
    if {[string equal $tcl_platform(platform) "macintosh"] && \
            [string equal $bitmap "error"]} {
      set bitmap "stop"
    }
    label $w.bitmap -bitmap $bitmap
    pack $w.bitmap -in $w.top -side left -padx 3m -pady 3m
  }

  # 3. Create a row of buttons at the bottom of the dialog.

  set i 0
  foreach but $args {
    button $w.button$i -text $but -command [list set tkPriv(button) $i]
    if {$i == $default} {
      $w.button$i configure -default active
    } else {
      $w.button$i configure -default normal
    }
    grid $w.button$i -in $w.bot -column $i -row 0 -sticky ew -padx 10
    grid columnconfigure $w.bot $i
    # We boost the size of some Mac buttons for l&f
    if {[string equal $tcl_platform(platform) "macintosh"]} {
      set tmp [string tolower $but]
      if {[string equal $tmp "ok"] || [string equal $tmp "cancel"]} {
        grid columnconfigure $w.bot $i -minsize [expr {59 + 20}]
      }
    }
    incr i
  }

  # 4. Create a binding for <Return> on the dialog if there is a
  # default button.

  if {$default >= 0} {
    bind $w <Return> "
	[list $w.button$default] configure -state active -relief sunken
	update idletasks
	after 100
	set tkPriv(button) $default
	"
  }

  # 5. Create a <Destroy> binding for the window that sets the
  # button variable to -1;  this is needed in case something happens
  # that destroys the window, such as its parent window being destroyed.

  bind $w <Destroy> {set tkPriv(button) -1}

  # 6. Withdraw the window, then update all the geometry information
  # so we know how big it wants to be, then center the window in the
  # display and de-iconify it.

  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
                   - [winfo vrootx [winfo parent $w]]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
                   - [winfo vrooty [winfo parent $w]]}]
  wm geom $w +$x+$y
  wm deiconify $w

  # 7. Set a grab and claim the focus too.

#   set oldFocus [focus]
#   set oldGrab [grab current $w]
#   if {[string compare $oldGrab ""]} {
#     set grabStatus [grab status $oldGrab]
#   }
#   grab $w
#   if {$default >= 0} {
#     focus $w.button$default
#   } else {
#     focus $w
#   }

  # 8. Wait for the user to respond, then restore the focus and
  # return the index of the selected button.  Restore the focus
  # before deleting the window, since otherwise the window manager
  # may take the focus away so we can't redirect it.  Finally,
  # restore any grab that was in effect.

  tkwait variable tkPriv(button)
#   catch {focus $oldFocus}

  catch {
    # It's possible that the window has already been destroyed,
    # hence this "catch".  Delete the Destroy handler so that
    # tkPriv(button) doesn't get reset by it.

    bind $w <Destroy> {}
    destroy $w
  }
#   if {[string compare $oldGrab ""]} {
#     if {[string compare $grabStatus "global"]} {
#       grab $oldGrab
#     } else {
#       grab -global $oldGrab
#     }
#   }
  return $tkPriv(button)
}


## simpler advisory dialog
## 08aug97 wmt: new
proc advisoryDialog { refWindow title message1 { message2 "" } } {
  global g_NM_advisoryRootWindow 

  set window ${g_NM_advisoryRootWindow}.[pirGenSym "adv"]
  if {[winfo exists $window]} {
    raise $window
    return
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  # set xPos [expr {[winfo rootx $refWindow] + [winfo width $refWindow] + 10}]
  set xPos [expr {[winfo rootx $refWindow] + 10}]
  set yPos [winfo rooty $refWindow]
  toplevel $window -class Dialog 
  wm title $window $title
  if { [winfo viewable [winfo toplevel [winfo parent $window]]] } {
    wm transient $window [winfo toplevel [winfo parent $window]]
  }    
  $window config -bg $bgcolor
  frame $window.label&button -bd 0 -bg $bgcolor -relief ridge 
  frame $window.label&button.l -bd 0 -bg $bgcolor -relief ridge 
  label $window.label&button.l.label2 -anchor w \
      -text "\n  $message1  \n" -font [preferred StanleyDefaultFont]
  if {! [string match $message2 ""]} {
    label $window.label&button.l.label3 -anchor w \
        -text "\n  $message2  \n" -font [preferred StanleyDefaultFont] 
    pack $window.label&button.l.label2 $window.label&button.l.label3 -side top -fill x
  } else {
    pack $window.label&button.l.label2 -side top -fill x
  }
  pack $window.label&button.l -side top -fill x
  frame $window.label&button.b -bd 0 -bg $bgcolor -relief ridge 
  button $window.label&button.b.cancel -text " DISMISS " -relief raised \
      -command "destroy $window" -padx 0 -pady 0
  pack $window.label&button.b.cancel -side bottom -padx 0 -ipadx 0 -expand 1
  pack $window.label&button.b -side top -fill x
  pack $window.label&button.l -side top -fill x
  pack $window.label&button -fill both -expand true

  keepDialogOnScreen $window 
}


## put up text widget to advise user
## 27feb98 wmt: new
proc adviseUser { titleString textString } {

  set heightBorder 5; set textHeight 11; set textWidth 80; set initP 0
  set windowHeight [expr {1 + $textHeight}]
  set bgColor [preferred StanleyDialogEntryBackgroundColor]

  set dialogW .advise[pirGenInt]
  toplevel $dialogW -class Dialog 
  wm title $dialogW $titleString 
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  frame $dialogW.textWidget
  frame $dialogW.textWidget.text -bg $bgColor
  set w $dialogW.textWidget.text
#   frame $w.bottom
#   -xscrollcommand "$w.bottom.sx set"
  set t [text $w.t -setgrid true -height $textHeight -background $bgColor \
             -yscrollcommand "$w.sy set" \
             -wrap char -font [preferred StanleyDialogEntryFont] \
             -selectbackground [preferred StanleySelectedColor]]
  scrollbar $w.sy -orient vertical -command "$w.t yview" -relief sunken 
#   scrollbar $w.bottom.sx -orient horizontal -command "$w.t xview" -relief sunken 
#   pack $w.bottom.sx -side left -fill x -expand 1
#   pack $w.bottom -side bottom -fill x
  pack $w.sy -side right -fill y
  pack $w.t -side left -fill both -expand 1
  pack $w -side top

#   $w.bottom.sx configure -takefocus 0
  $w.sy configure -takefocus 0

  set canvasHeight [expr {$windowHeight - $heightBorder}] 
  # characters
  $w.t config -width $textWidth
  $w.t config -height $canvasHeight

  set textString [string trimleft $textString "\{"] 
  set textString [string trimright $textString "\}"]
  set textString [string trimright $textString "\n"]
  $w.t insert end $textString
  $w.t configure -state disabled

  frame $dialogW.textWidget.buttons -bg $bgColor 
  button $dialogW.textWidget.buttons.dismiss -text DISMISS -relief raised \
      -command "mkformNodeCancel $dialogW $initP"
  $dialogW.textWidget.buttons.dismiss configure -takefocus 0
  pack $dialogW.textWidget.buttons.dismiss -side left -padx 5m -ipadx 2m -expand 1
  pack $dialogW.textWidget.buttons -side bottom -expand 1 -fill x
  pack $dialogW.textWidget

  keepDialogOnScreen $dialogW
}


## based on tk_optionMenu from tcl-tk7642/lib/tk4.2/optMenu.tcl
## option menu for terminal node dialog types and
## edge dialog abstractions
## 02may97 wmt: pass menu items by reference, rather than by value
##              passing a list by value gets {} wrapped around it
##              which makes the first foreach value be the whole list.
##              reduce size; build cascaded menus based on alphabet
##  tk_alphaOptionMenuCascade .master.menus_accels.menu value "unspecified" x
proc tk_alphaOptionMenuCascade { optionMenuWidget varName firstValue \
                                     argsRef state { cmdMonTypeP 1 } \
                                     { dialogW nil } } {
  upvar #0 $varName var
  upvar $argsRef args

  # set str "tk_alphaOptionMenuCascade: args $args state $state cmdMonTypeP"
  # puts stderr "$str $cmdMonTypeP dialogW $dialogW"
#   if ![info exists var] {
#     set var $firstValue
#   }
  ## do not retain previous value
  global $varName 
  set $varName $firstValue
  set minAlphaListLength 15

  menubutton $optionMenuWidget -textvariable $varName -indicatoron 1 \
      -menu $optionMenuWidget.menu \
      -relief raised -bd 2 -highlightthickness 2 -anchor c \
      -font [preferred StanleyDialogEntryFont] -state $state 
  set m [menu $optionMenuWidget.menu -tearoff 0 \
             -font [preferred StanleyDialogEntryFont]]
  if {[string match $state normal]} {
    if {[llength $args] < $minAlphaListLength} {
      if {([llength $args] > 1) || \
              (([llength $args] == 1) && ($firstValue == "<unspecified>"))} {
        foreach item [lsort -ascii $args] {
          set command "tk_alphaOptionMenuCascadeUpdate $varName $item "
          append command "$optionMenuWidget $state $cmdMonTypeP $dialogW"
          $m add command -label $item -command $command
        }
      }
    } else {
      set alphabet {A B C D E F G H I J K L M N O P Q R S T U V W X Y Z}
      catch { unset alphaSortArray }
      set alphaSortArray(0) 1
      foreach alpha $alphabet {
        set alphaSortArray($alpha) {}
      }
      set alphaSortArray(Other) {}
      foreach i $args {
        set alpha [string toupper [string range $i 0 0]]
        if {([charToAscii $alpha] >= 65) && \
                       ([charToAscii $alpha] <= 90)} {
          lappend alphaSortArray($alpha) $i
        } else {
          lappend alphaSortArray(Other) $i
        }
      }
      set bins [concat $alphabet Other]
      foreach alpha $bins {
        # puts stderr "tk_alphaOptionMenuCascade: alpha $alpha array $alphaSortArray($alpha)"
        if {[llength $alphaSortArray($alpha)] > 0} {
          $m add cascade -label $alpha -menu $m.sub$alpha 
          set subM [menu $m.sub$alpha -tearoff 0 \
                        -font [preferred StanleyDialogEntryFont]]
          foreach item [lsort -ascii $alphaSortArray($alpha)] {
            set command "tk_alphaOptionMenuCascadeUpdate $varName $item "
            append command "$optionMenuWidget $state $cmdMonTypeP $dialogW"
            $subM add command -label $item -command $command  
          }
        }
      }
    }
  }
  # puts stderr "tk_alphaOptionMenuCascade: focus [focus]"
  return $optionMenuWidget.menu
}


## update option menu selection and terminal node balloon help update
## 10dec97 wmt: new
proc tk_alphaOptionMenuCascadeUpdate { varName value optionMenuWidget \
                                         state cmdMonTypeP dialogW } {
  global g_NM_terminalTypeValuesArray $varName g_NM_commandMonitorTypesList
  global pirClassesStructure pirClassStructure g_NM_terminalTypeList
  global g_NM_paletteDefcomponentList g_NM_paletteDefmoduleList
  global g_NM_paletteStructureList g_NM_paletteDefvalueList 

  set defaultValue [set $varName]
  set $varName $value
  set reportNotFoundP 0; set silentP 1
  set dialogId [getDialogId $dialogW]
  # puts stderr "\ntk_alphaOptionMenuCascadeUpdate: value $value varName $varName"
  # puts stderr "tk_alphaOptionMenuCascadeUpdate: defaultValue $defaultValue dialogW $dialogW"
  if {[winfo exists $optionMenuWidget]} {
    # handle terminal/attribute edit dialogs, and
    # abstraction edit dialogs 
    if {([regexp "g_NM_optMenuTypeValue_" $varName] && \
             (! [regexp "_moduleParam" $varName]) && \
             (! [regexp "_termTypeParamP" $varName])) || \
            [regexp "g_NM_optMenuWidgetValueTo_" $varName] || \
            [regexp "g_NM_optMenuWidgetValueFrom_" $varName]} {
      if {[regexp "\\\?" $value]} {
        # type name is a parameter -- type not determined until instantiation
        set valuesList [assoc-array [getParameterType $value] \
                            g_NM_terminalTypeValuesArray]
      } else {
        set valuesList [assoc-array $value g_NM_terminalTypeValuesArray]
      }
      balloonhelp $optionMenuWidget -side right \
          "values: [multiLineList $value $valuesList values:]"
    }
    if {$cmdMonTypeP} {
      if {[regexp "g_NM_optMenuTypeValue_" $varName] && \
              [string match $state normal]} {
        $dialogW.typeCommandMon.fCmdmon.optMenuButton configure -state normal
        $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton configure -state normal 
        $dialogW.typeCommandMon.fCmdmonIntTyp.optMenuButton configure -state normal 
      }

      # (! [string match $defaultValue "<unspecified>"])
      if {[regexp "g_NM_optMenuCmdMonValue_" $varName] || \
              ([regexp "g_NM_optMenuTypeValue_" $varName])} {
        global g_NM_optMenuTypeValue_$dialogId
        global g_NM_commandMonitorTypeValuesList_$dialogId
        global g_NM_optMenuCmdMonValue_$dialogId

        if {! [regexp "g_NM_optMenuCmdMonValue_" $varName]} {
          set value [subst $[subst g_NM_optMenuCmdMonValue_$dialogId]]
        }
        # set Cmd/Mon Default Value & g_NM_commandMonitorTypeValuesList_$dialogId
        set typeVal [subst $[subst g_NM_optMenuTypeValue_$dialogId]] 

        if {[regexp "\\\?" $typeVal]} {
          # type name is a parameter -- type not determined until instantiation
          set typeValues [assoc-array [getParameterType $typeVal] \
                              g_NM_terminalTypeValuesArray] 
        } else {
          set typeValues [assoc-array $typeVal g_NM_terminalTypeValuesArray]
        }
        set g_NM_commandMonitorTypeValuesList_$dialogId $typeValues
        switch $value {
          commanded {
            set commandMonitorTypeValueDefault "noCommand"
            if {[lsearch -exact [subst $[subst g_NM_commandMonitorTypeValuesList_$dialogId]] \
                     "noCommand"] == -1} {
              # L2 requires that commanded terminal types have noCommand
              set str "Type `$typeVal' does not include `noCommand':"
              append str "\n  [subst $[subst g_NM_commandMonitorTypeValuesList_$dialogId]]"
              set dialogList [list tk_dialog .d "Warning" $str warning 0 {DISMISS}] 
              eval $dialogList
              set g_NM_optMenuTypeValue_$dialogId "<unspecified>"
              set g_NM_commandMonitorTypeValuesList_$dialogId {}
              # clear the values of the type option menu widget
              regsub "\.fCmdmon\." $optionMenuWidget ".fType." cmdMonTypeWidget
              balloonhelp $cmdMonTypeWidget -side right \
                  "values: [multiLineList $value {} values:]"
            }
          }
          monitored {
            set commandMonitorTypeValueDefault "unknown"
            if {[lsearch -exact [subst $[subst g_NM_commandMonitorTypeValuesList_$dialogId]] \
                     "unknown"] == -1} {
              lappend g_NM_commandMonitorTypeValuesList_$dialogId "unknown"
            }
          }
          prop-monitored {
            set commandMonitorTypeValueDefault "<unspecified>"
          }
           <unspecified> {
            set commandMonitorTypeValueDefault "<unspecified>"
          }
         default {
            error "tk_alphaOptionMenuCascadeUpdate: value $value not handled"
          }
        }
        # reset "Cmd/Mon Default Value" option menu
        destroy $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton 
        tk_alphaOptionMenuCascade $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton \
            g_NM_optMenuCmdMonDefValue_$dialogId \
            $commandMonitorTypeValueDefault g_NM_commandMonitorTypeValuesList_$dialogId \
            disabled
            # $state
        pack $dialogW.typeCommandMon.fCmdmonDefVal.optMenuButton
        pack $dialogW.typeCommandMon.fCmdmonDefVal
      }
    }
    # structure Edit parent class type, which is a structure type
    # add to local args & argTypes, if any, with parent args & argTypes,
    # which will be disabled
    if {[regexp "_nameParentType" $varName]} {
      set indx [string last "." $dialogW]
      set baseWidget [string range $dialogW 0 [expr {$indx - 1}]]
      # dialogId is determined in editStructureForm at one level above
      # option menu path
      set indx [string last "." $dialogW]
      set dialogWUp1 [string range $dialogW 0 [expr {$indx -1}]]
      set dialogId [getDialogId $dialogWUp1]
      if {$value != "<unspecified>"} {
        set pirClassIndex $value
        set state disabled
        set i 0; set numBaseArgs 0
        while {[winfo exists $baseWidget.param$i]} {
          set entry [$baseWidget.param$i.var.fentry.entry get]
          set entry [string trim $entry " "]
          set entryLength [string length $entry]
          if {$entryLength > 0} {
            incr numBaseArgs
          }
          incr i
        }
      } else {
        # use current structure name
        set pirClassIndex [$baseWidget.name_parentType.fstructureName.fentry.entry get]
        set pirClassIndex [string trim $pirClassIndex " "]
        set state normal
        # clear out existing slots and refill with local slots
        set i 0
        while {[winfo exists $baseWidget.param$i]} {
          set entry [$baseWidget.param$i.var.fentry.entry get]
          set entry [string trim $entry " "]
          set entryLength [string length $entry]
          # un disable parent slots -- allow them to be deleted
          $baseWidget.param$i.var.fentry.entry configure -state normal
          $baseWidget.param$i.var.fentry.entry delete 0 $entryLength
          $baseWidget.param$i.fType.optMenuButton configure -state normal
          global g_NM_optMenuTypeValue_${dialogId}_param$i
          set g_NM_optMenuTypeValue_${dialogId}_param$i ""
          balloonhelp $baseWidget.param$i.fType.optMenuButton -side right "values: "
          incr i
        }
        set numBaseArgs 0
      }
      # puts stderr "tk_alphaOptionMenuCascadeUpdate: pirClassIndex `$pirClassIndex'"
      if {[lsearch -exact $pirClassesStructure $pirClassIndex] == -1} {
        read_workspace structure $pirClassIndex $silentP
      }
      set classVars [assoc class_variables pirClassStructure($pirClassIndex)]
      set argsList [getClassVarDefaultValue args classVars]
      set numArgs [llength $argsList]
      set argTypesList [getClassVarDefaultValue argTypes classVars]
      set parentType [getClassVarDefaultValue parentType classVars] 
      set argLocationsList [generateStructureArgsLocations $parentType \
                 $argsList $argTypesList]
      # puts stderr "    numBaseArgs $numBaseArgs numArgs $numArgs"
      # puts stderr "    argsList $argsList argTypesList $argTypesList"
      # puts stderr "    argLocationsList $argLocationsList"
      set baseIndex 0; set argsIndex 0
      for {set i 0} {$i < ($numBaseArgs + $numArgs)} { incr i} {
        if {! [winfo exists $baseWidget.param$i]} {
          set str "tk_alphaOptionMenuCascadeUpdate: not enough slots exist (i = $i)"
          set dialogList [list tk_dialog .d "ERROR" $str error 0 {DISMISS}]
          eval $dialogList
          break
        }
        set entry [$baseWidget.param$i.var.fentry.entry get]
        set entry [string trim $entry " "]
        set entryLength [string length $entry]
        # puts stderr "entryLength $entryLength i $i baseIndex $baseIndex"
        if {[string length $entry] > 0} {
          # is parent arg/type same as local arg/type
          global g_NM_optMenuTypeValue_${dialogId}_param$i
          set entryType [subst $[subst g_NM_optMenuTypeValue_${dialogId}_param$i]]
          # puts stderr "entry $entry entryType $entryType"
          # puts stderr "arg [lindex $argsList $argsIndex] argType [lindex $argTypesList $argsIndex]"
          if {[string match $entry [lindex $argsList $argsIndex]] && \
                  [string match $entryType [lindex $argTypesList $argsIndex]]} {
            $baseWidget.param$i.var.fentry.entry configure -state disabled
            $baseWidget.param$i.fType.optMenuButton configure -state disabled 
            incr argsIndex
          }
          incr baseIndex
          continue
        } else {
          if {($i < ([llength $argsList] + $baseIndex)) && \
                ($argsIndex < [llength $argsList])} {
            # puts stderr "i $i arg [lindex $argsList $argsIndex]"
            if {($value != "<unspecified>") || \
                    (($value == "<unspecified>") && \
                         ([lindex $argLocationsList $argsIndex] == "local"))} {
              $baseWidget.param$i.var.fentry.entry insert 0 \
                  [lindex $argsList $argsIndex]
              $baseWidget.param$i.var.fentry.entry configure -state $state
              set defaultTypeValue [lindex $argTypesList $argsIndex] 
              destroy $baseWidget.param$i.fType.optMenuButton
              tk_alphaOptionMenuCascade $baseWidget.param$i.fType.optMenuButton \
                  g_NM_optMenuTypeValue_${dialogId}_param$i \
                  $defaultTypeValue g_NM_terminalTypeList $state \
                  $cmdMonTypeP $baseWidget.param$i
              global g_NM_optMenuTypeValue_${dialogId}_param$i
              set g_NM_optMenuTypeValue_${dialogId}_param$i $defaultTypeValue
              set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 
              balloonhelp $baseWidget.param$i.fType.optMenuButton -side right \
                  "values: [multiLineList $defaultTypeValue $valuesList values:]"
              pack $baseWidget.param$i.fType.optMenuButton -side top -fill x 
              pack $baseWidget.param$i.fType
            }
            incr argsIndex
          } else {
            break
          }
        }
      }
    }
    # module param type can be either a value/struct type or a class type
    if {[regexp "moduleParam" $optionMenuWidget]} {
      set indx [string last "." $dialogW]
      set baseWidget [string range $dialogW 0 [expr {$indx - 1}]]
      # dialogId is determined in askLivingstoneDefmoduleParams at one level above
      # option menu path
      set indx [string last "." $dialogW]
      set dialogWUp1 [string range $dialogW 0 [expr {$indx -1}]]
      set dialogId [getDialogId $dialogWUp1]
      set classTypeList [concat $g_NM_paletteDefcomponentList \
                             $g_NM_paletteDefmoduleList <unspecified>]
      set structValueTypeList [concat $g_NM_paletteStructureList \
                                   $g_NM_paletteDefvalueList <unspecified>]

      set cmdMonP 0
      for {set i 0} {$i < 10} { incr i} {
        if {[winfo exists $baseWidget.moduleParam$i]} {
          global g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_value
          global g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_class
          global g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default
          set valueType \
              [subst $[subst g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_value]]
          set classType \
              [subst $[subst g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_class]]
          # only one type - one overrides the other
          set type \
              [subst $[subst g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default]]
          # puts stderr "$i -- valueType $valueType classType $classType type $type"
          getClassValueDefaultValues $type $valueType $classType \
              defaultType defaultTypeValue defaultTypeClass 
              
          # puts stderr "defaultTypeValue $defaultTypeValue defaultTypeClass $defaultTypeClass defaultType $defaultType"
          set g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_default $defaultType

          set valueWidget \
              [subst $[subst baseWidget.moduleParam$i.typeParam.value.optMenuButton]]
          destroy $valueWidget 
          tk_alphaOptionMenuCascade $valueWidget \
              g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_value \
              $defaultTypeValue structValueTypeList normal \
              $cmdMonTypeP $baseWidget.moduleParam$i
          set valuesList [assoc-array $defaultTypeValue g_NM_terminalTypeValuesArray] 
          balloonhelp $valueWidget -side right \
              "values: [multiLineList $defaultTypeValue $valuesList values:]"
          pack $valueWidget -side top -fill x 
          pack $baseWidget.moduleParam$i.typeParam.value

          set classWidget \
              [subst $[subst baseWidget.moduleParam$i.typeParam.class.optMenuButton]]
          destroy $classWidget 
          tk_alphaOptionMenuCascade $classWidget \
              g_NM_optMenuTypeValue_${dialogId}_moduleParam${i}_class \
              $defaultTypeClass classTypeList normal \
              $cmdMonTypeP $baseWidget.moduleParam$i
          pack $classWidget -side top -fill x 
          pack $baseWidget.moduleParam$i.typeParam.class
        } else {
          break
        }
      }
    }
  }
}


## determine overriding of value and class types to get the default
## 20apr wmt
proc getClassValueDefaultValues { type valueType classType defaultTypeRef \
                                      defaultTypeValueRef defaultTypeClassRef } {
  upvar $defaultTypeRef defaultType
  upvar $defaultTypeValueRef defaultTypeValue
  upvar $defaultTypeClassRef defaultTypeClass

  set defaultTypeClass "<unspecified>"
  set defaultTypeValue "<unspecified>"
  set defaultType "<unspecified>" 
  if {(! [string match $type $valueType]) && \
          ($valueType != "<unspecified>")} {
    set defaultTypeValue $valueType
    set defaultType $valueType 
    set defaultTypeClass "<unspecified>"
  } elseif {[string match $type $valueType]} {
    if {$classType != "<unspecified>"} {
      set defaultTypeValue "<unspecified>" 
      set defaultTypeClass $classType
      set defaultType $classType
    } else {
      set defaultTypeValue $valueType 
      set defaultTypeClass $classType
      set defaultType $valueType 
    }
  } elseif {(! [string match $type $classType]) && \
                ($classType != "<unspecified>")} {
    set defaultTypeClass $classType
    set defaultType $classType 
    set defaultTypeValue "<unspecified>"
  } elseif {[string match $type $classType]} {
    if {$valueType != "<unspecified>"} {
      set defaultTypeClass "<unspecified>" 
      set defaultTypeValue $valueType
      set defaultType $valueType
    } else {
      set defaultTypeClass $classType 
      set defaultTypeValue $valueType 
      set defaultType $classType 
    }
  }
}


## selecton menu for binding to object's right mouse click
## selectLabelList & selectCmdList are ALists with
## l1 l2 ... & c1 c2 ... as keys
## multiple commands have a standalone \; separating them in the calling form
## {}'s added by list function in passing them here
## 28oct99 wmt: new
proc operationMenu { widget pirNodeIndexOrType selectLabelList selectCmdList } {
  global pirNode g_NM_instanceToNode g_NM_schematicMode
  global g_NM_rootInstanceName g_NM_vmplTestModeP 

  if {[llength $selectLabelList] != [llength $selectCmdList]} {
    error "operationMenu: selectLabelList & selectCmdList not equal"
  }
  # puts stderr "operationMenu: widget $widget selectLabelList $selectLabelList"
  # puts stderr "operationMenu: selectCmdList $selectCmdList"
  set dialogW .selectoperation
  destroy $dialogW 
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  set reportNotFoundP 0
  # not a top level window -- just as menu selection 
  set menu $dialogW
  menubutton $menu -menu $menu.m -relief flat    
  set rootMenu [menu $menu.m -tearoff 0]
  set subMenu $rootMenu
  $subMenu config -font [preferred StanleyTerminalTypeFont]
  # substitute edit or view for editOrView in selectLabelList
  if {[string match $g_NM_schematicMode "layout"]} {
    if {(! [string match $g_NM_rootInstanceName \
                [getCanvasRootInfo g_NM_currentNodeGroup]]) || \
            [componentModuleDefReadOnlyP]} {
      set operation view
    } else {
      set operation edit
    }
  } else {
    # operational mode
    set operation view
  }
  regsub -all "editOrView" $selectLabelList "$operation" tmp
  set selectLabelList $tmp
  # substitute value of display label for displayLabel & modeDisplayLabel,
  # since on a rename, a new node is not created for
  # attributes, terminals, and modes (components & modules are treated
  # the same here, for consistency)
  if {($pirNodeIndexOrType != "edge") && ($pirNodeIndexOrType != "transition")} {
    set displayLabel [getDisplayLabel pirNode($pirNodeIndexOrType) labelP]
    if {[assoc nodeClassType pirNode($pirNodeIndexOrType)] == "mode"} {
      set modeDisplayLabel [getExternalNodeName \
                                [assoc nodeInstanceName pirNode($pirNodeIndexOrType)]]
      regsub -all modeDisplayLabel $selectLabelList $modeDisplayLabel tmp
    } else {
       regsub -all displayLabel $selectLabelList $displayLabel tmp
    }
    set selectLabelList $tmp 
  }
  # multiple commands have a standalone \; separating them in the calling form
  # {}'s added by list function in passing them here
  regsub -all "{;}" $selectCmdList ";" tmp
  set selectCmdList $tmp
  # fill menu
  set numOps [expr {[llength $selectLabelList] / 2}]
  for {set num 1} {$num <= $numOps} {incr num} {
    # handle `edit {(cmd-in ?name)}' & 'select  {(cmd-in ?name)} proposition'
    regsub "\{" [assoc l$num selectLabelList] "" tmp
    regsub "\}" $tmp "" selectLabel 
    set selectCmd [assoc c$num selectCmdList]
    if {[string match $operation "view"] && \
            ([string match [lindex $selectCmd 0] "deleteNode"] || \
                 [string match [lindex $selectCmd 0] "unmkEdge"])} {
      continue
    }
    # puts stderr "operationMenu: selectLabel `$selectLabel' selectCmd `$selectCmd'"
    if {([lindex $selectCmd 0] == "deleteNode") || \
          ($selectLabel == "delete connection")} {
      $subMenu add command -label $selectLabel -command $selectCmd \
          -activebackground red
    } elseif {[string match [lindex $selectCmd 0] "selectTerminalPropMenu"]} {
      # cascade menu for propositions
      set subMenu $rootMenu.props
      $rootMenu add cascade -label $selectLabel -menu $subMenu 
      menu $subMenu -tearoff 0
      $subMenu config -font [preferred StanleyTerminalTypeFont]
      set terminalForm [lindex $selectCmd 1]
      set terminalName [assoc terminal_name terminalForm]
      set type [getTerminalType $terminalForm]
      set valuesList [lindex $selectCmd 2]
      set terminalWidget [lindex $selectCmd 3]
      set pirNodeIndex [lindex $selectCmd 4]
      set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
      if {$g_NM_vmplTestModeP && (! [string match $nodeClassType "mode"])} {
        set valueNum 1; set valueList nil
        selectTerminalProposition $terminalName $type $valuesList $terminalWidget \
            $pirNodeIndex $valueNum $valueList $subMenu $dialogW 
      } else {
        fillPropositionSubMenu $nodeClassType $terminalForm $subMenu \
            $terminalWidget $dialogW $valuesList
      }
    } else {
      # default -activebackground is set by resetOptionDatabase
      $subMenu add command -label $selectLabel -command "$selectCmd"
    }
  }
 
  pack $menu -side top -fill x

  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas]
  set x [winfo pointerx $currentCanvas] 
  set y [winfo pointery $currentCanvas]
  # make sure that menu has been properly created before poping it up
  # not sure why this is a problem, but this fixes it
  if {[winfo exists $menu.m] } {
    tk_popup $menu.m [expr {$x + 10}] $y 
    update
  }
}


## scrollableCanvasOfOptionMenus "Initial Conditions" [getOrderedComponentModes cbAndLeds]
## scrollableCanvasOfOptionMenus "Initial Conditions" {{test.cb1.mode on {on off tripped blown unknownCbFault}} {test.cb10.mode on {on off tripped blown unknownCbFault}}}
## create a y-scrollable canvas containing labelled option menus
## triples are label defaultValue valueSet
## 23may00 wmt
proc scrollableCanvasOfOptionMenus { titleText tripletListRef \
                                         {dismissLabel DISMISS} } {
  upvar $tripletListRef tripletList
  global g_NM_nodeTypeRootWindow g_NM_win32P
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_commandMonitorConstraints g_NM_stanleyCurrentTime 

  set initP 0
  set reportNotFoundP 0; set oldvalMustExistP 0
  set dialogW $g_NM_nodeTypeRootWindow.scrolledOptionMenus_[pirGenInt]
  set dialogId [getDialogId $dialogW]
  toplevel $dialogW -class Dialog
  wm title $dialogW "$titleText"
  wm group $dialogW [winfo toplevel [winfo parent $dialogW]]

  set bgcolor [preferred StanleyMenuDialogBackgroundColor]

  # the buttons
  $dialogW config -bg $bgcolor
  frame $dialogW.buttons -bg $bgcolor
  set cmd "scrollableCanvasOfOptionMenusUpdate $dialogW $tripletListRef [list $tripletList]" 
  button $dialogW.buttons.ok -text "OK" -relief raised \
      -command $cmd
  $dialogW.buttons.ok configure -takefocus 0
  button $dialogW.buttons.cancel -text "$dismissLabel" -relief raised \
      -command "mkformNodeCancel $dialogW $initP" 
  $dialogW.buttons.cancel configure -takefocus 0

  pack $dialogW.buttons.ok $dialogW.buttons.cancel -side left -padx 5m \
      -ipadx 2m -expand 1
  pack $dialogW.buttons -side bottom -pady 10 

  # the y-scrollable canvas
  frame $dialogW.canvas -bg $bgcolor
  canvas $dialogW.canvas.c \
      -scrollregion [list 0 0 $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight] \
      -yscrollcommand "$dialogW.canvas.yscroll set" -bg $bgcolor -bd 2
  scrollbar $dialogW.canvas.yscroll -command "$dialogW.canvas.c yview" \
      -relief sunk -bd 2  
  pack $dialogW.canvas.yscroll -side right -fill y
  pack $dialogW.canvas.c -side left -fill both -expand 1
  pack $dialogW.canvas -side top 

  # the label/optionMenu pairs
  set state normal; set cmdMonTypeP 0
  set x 0; set yDiff 30
  set maxCharWidth 0
  set numTriplets [llength $tripletList]
  for {set i 0} {$i < $numTriplets} { incr i} {
    set triplet [lindex $tripletList $i]
    set isAModeP [regexp "mode" $triplet]
    set label [lindex $triplet 0]
    set defaultValue [lindex $triplet 1]
    set valueSet [lindex $triplet 2]
    # indent label by number of "."s minus 1  -- if it is a mode
    set dotCnt [expr {[regsub -all "\\\." $label "" tmp] - 1}]
    for {set j 0} {$j < $dotCnt} {incr j} {
      if {$isAModeP} {
        set label "^$label"
      }
    }
    if {! $isAModeP} {
      # an initial condition -- mark it as exogenous
      # only monitored vars can be set in initial conditions
      set cmdMonConstraintList [assoc-array $g_NM_stanleyCurrentTime \
                                    g_NM_commandMonitorConstraints]
      if {$cmdMonConstraintList == ""} {
        set cmdMonConstraintList [list $label $valueSet]
      } else {
        arepl $label $valueSet \
            cmdMonConstraintList $reportNotFoundP $oldvalMustExistP
      }
      set g_NM_commandMonitorConstraints($g_NM_stanleyCurrentTime) \
          $cmdMonConstraintList
    }
    set labelWidth [string length $label]
    set charWidth $labelWidth
    foreach value $valueSet {
      set testWidth [expr {$labelWidth + [string length $value]}]
      if {$testWidth > $charWidth} {
        set charWidth $testWidth
      }
    }
    if {$charWidth > $maxCharWidth} {
      set maxCharWidth $charWidth
    }
    frame $dialogW.canvas.c.initValue$i -bg $bgcolor 
    label $dialogW.canvas.c.initValue$i.label -text $label -relief flat -anchor w \
        -font [preferred StanleyDialogEntryFont]
    $dialogW.canvas.c.initValue$i.label configure -takefocus 0
    if {$defaultValue == ""} { set defaultValue "<unspecified>" }
    tk_alphaOptionMenuCascade $dialogW.canvas.c.initValue$i.optMenuButton \
        g_NM_optMenuInitValue_${dialogId}_initValue$i \
        $defaultValue valueSet $state $cmdMonTypeP $dialogW.canvas.c.initValue$i
    pack $dialogW.canvas.c.initValue$i.label \
        $dialogW.canvas.c.initValue$i.optMenuButton -side left -fill x
    # place it on canvas as a "canvas window"
    set canvasId \
        [$dialogW.canvas.c create window $x [expr {$i * $yDiff}] -anchor nw \
         -tags initValue -window $dialogW.canvas.c.initValue$i]
  }
  
  # adjust height/width of dialog in pixels
  set canvasWindowHeight 200
  $dialogW.canvas.c config -height $canvasWindowHeight 
  # puts stderr "scrollableCanvasOfOptionMenus: maxCharWidth $maxCharWidth "
  set testString "        " ; # allow for extra spacing between label and option menu
  for {set i 0} {$i < $maxCharWidth} {incr i} {
    append testString " "
  }
  if {! $g_NM_win32P} {
    # Windows does not support the font we are using
    $dialogW.canvas.c config -width [font measure [preferred StanleyDialogEntryFont] \
        $testString]
  }
  # reduce scroll region to just include entries
  set canvasHeight [expr {($numTriplets + 1) * $yDiff}]
  if {$canvasHeight < $canvasWindowHeight} {
    set canvasHeight $canvasWindowHeight
  }
  set scrollRegion [list 0 0 $g_NM_absoluteCanvasWidth $canvasHeight]
  $dialogW.canvas.c config -scrollregion $scrollRegion 

  keepDialogOnScreen $dialogW 
  if {[winfo exists $dialogW]} {
    tkwait window $dialogW
  }
}


## 23may00 wmt
proc scrollableCanvasOfOptionMenusUpdate { dialogW tripletListVar tripletList } {

  set dialogId [getDialogId $dialogW]
  set numTriplets [llength $tripletList]
  set newTripletList {}
  for {set i 0} {$i < $numTriplets} { incr i} {
    set triplet [lindex $tripletList $i]
    set label [lindex $triplet 0]
    set valueSet [lindex $triplet 2]
    global g_NM_optMenuInitValue_${dialogId}_initValue$i
    set defaultValue [subst $[subst g_NM_optMenuInitValue_${dialogId}_initValue$i]]
    lappend newTripletList [list $label $defaultValue $valueSet]
  }
  # puts stderr "scrollableCanvasOfOptionMenusUpdate: newTripletList $newTripletList"
  # give user access to results
  global $tripletListVar 
  set $tripletListVar $newTripletList 
  destroy $dialogW 
}




