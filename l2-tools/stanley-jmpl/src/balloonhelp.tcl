## balloonhelp.tcl
## Balloon Help Routines
##
## Jeffrey Hobbs
## Initiated: 28 October 1996
##

##------------------------------------------------------------------------
## PROCEDURE
##	balloonhelp
##
## DESCRIPTION
##	Implements a balloon help system
##
## ARGUMENTS
##	balloonhelp <option> ?arg?
##
## clear ?pattern?
##	Stops the specified widgets (defaults to all) from showing balloon
##	help.
##
## delay ?millisecs?
##	Query or set the delay.  The delay is in milliseconds and must
##	be at least 50.  Returns the delay.
##      08dec97 wmt: disable this arg, since each instance has its own delay
##
## disable OR off
##	Disables all balloon help.
##
## enable OR on
##	Enables balloon help for defined widgets.
##
## <widget> ?-index index? ?message?
##	If -index is specified, then <widget> is assumed to be a menu
##	and the index represents what index into the menu (either the
##	numerical index or the label) to associate the balloon help
##	message with.  Balloon help does not appear for disabled menu items.
##	If message is {}, then the balloon help for that
##	widget is removed.  The widget must exist prior to calling
##	balloonhelp.  The current balloon help message for <widget> is
##	returned, if any.
##
## <widget> ?-side side? ?message?                    (ammended - 030ct97 wmt)
##      If -side is specified, the default bottom position of the balloon
##      relative to the widget is changed to one of left, right, top, or bottom. 
##      NOTE: the reason that left and right can convert to top is that if a
##      left otr right balloon extends off the screen and has to be adjusted
##      back on to the screen and overlaps the mouse cursor, the whole
##      balloon area is immediately repainted with the background to 
##      prevent the mouse cursor from being overlaid.
##
## <widget> ?-font font? ?message?                    (ammended - 07dec97 wmt)
##
## <widget> ?-delay delay? ?message?                  (ammended - 07dec97 wmt)
##
## RETURNS: varies (see methods above)
##
## NAMESPACE & STATE
##	The global array BalloonHelp is used.  Procs begin with BalloonHelp.
## The overrideredirected toplevel is named $BalloonHelp(TOPLEVEL).
##
## EXAMPLE USAGE:
##	balloonhelp .button "A Button"
##	balloonhelp .menu -index "Load" "Loads a file"
##
##------------------------------------------------------------------------

## An alternative to binding to all would be to bind to BalloonHelp
## and add that to the bindtags of each widget registered.

## The extra :hide call in <Enter> is necessary to catch moving to
## child widgets where the <Leave> event won't be generated
## 03oct97 wmt: add BalloonSide arg
## 08dec97 wmt: add BalloonFont & BalloonDelay 
bind BalloonHelp <Enter> {
    #BalloonHelp:hide
    set BalloonHelp(LAST) -1
    if {$BalloonHelp(enabled) && [info exists BalloonHelp(%W)]} {
      set BalloonHelp(AFTERID) [after $BalloonDelay([subst "%W"]) \
		[list BalloonHelp:show %W $BalloonHelp([subst "%W"]) \
                    $BalloonSide([subst "%W"]) $BalloonFont([subst "%W"])]]
    }
}

## 03oct97 wmt: add side arg = bottom to show call 
bind BalloonsMenu <Any-Motion> {
    if {$BalloonHelp(enabled)} {
	set cur [%W index active]
	if {$cur == $BalloonHelp(LAST)} return
	set BalloonHelp(LAST) $cur
	BalloonHelp:hide
	if {[info exists BalloonHelp(%W,$cur)] || \
		(![catch {%W entrycget $cur -label} cur] && \
		[info exists BalloonHelp(%W,$cur)])} {
	    set BalloonHelp(AFTERID) [after $BalloonDelay(%W) \
		    [list BalloonHelp:show %W $BalloonHelp(%W,$cur) bottom $cur]]
	}
    }
}

bind all <Leave>		{ BalloonHelp:hide }
bind Balloons <Any-KeyPress>	{ BalloonHelp:hide }
bind Balloons <Any-Button>	{ BalloonHelp:hide }
## DELAY now specified for each instance
## this is done in initialize_graph - here it is redundant
array set BalloonHelp {
    enabled	1
    AFTERID	{}
    LAST	-1
    TOPLEVEL	.__balloonhelp__
}

proc balloonhelp {w args} {
  global BalloonHelp 

    ## delay now specified for each instance
#     delay	{
#       if {[llength $args]} {
#         if {![regexp {^[0-9]+$} $args] || $args<50} {
#           return -code error "BalloonHelp delay must be an\
# 			    integer greater than 50 (delay is in millisecs)"
#         }
#         return [set BalloonHelp(DELAY) $args]
#       } else {
#         return $BalloonHelp(DELAY)
#       }
#     }
  
  switch -- $w {
    clear	{
      if {[llength $args]==0} { set args .* }
      BalloonHelp:clear $args
    }
    off - disable	{
      set BalloonHelp(enabled) 0
      BalloonHelp:hide
    }
    on - enable	{
      set BalloonHelp(enabled) 1
    }
    default	{
      if {[llength $args]} {
        # puts stderr "balloonhelp: w $w"
        set i [uplevel BalloonHelp:register $w $args]
      }
      set b $BalloonHelp(TOPLEVEL)

#       # for testing
#       # catch { destroy $b }
      
      if {![winfo exists $b]} {
        toplevel $b
        wm overrideredirect $b 1
        wm positionfrom $b program
        wm withdraw $b
        pack [label $b.l -highlightthickness 1 -relief flat -justify left \
                  -highlightbackground black \
                  -wraplength 0 \
                  -fg [preferred StanleyBalloonHelpForegroundColor] \
                  -bg [preferred StanleyBalloonHelpBackgroundColor]]
        bind $w <Leave>	 { BalloonHelp:hide }
      }
      if {[info exists BalloonHelp($i)]} { return $BalloonHelp($i) }
    }
  }
}


## 03oct97 wmt: add BalloonSide
## 07dec97 wmt: add BalloonFont
;proc BalloonHelp:register {w args} {
  global BalloonHelp BalloonSide BalloonFont BalloonDelay
  global BalloonDisableHide BalloonHelpBalloon BalloonIconLabel 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "BalloonHelp:register: `$backtrace'"
  set key [lindex $args 0]
  set side bottom
  set font [preferred StanleyTerminalTypeFont]
  set delay 50
  set iconLabelP 0
  while {[string match -* $key]} {
    switch -- $key {
      -index	{
        if {[catch {$w entrycget 1 -label}]} {
          return -code error "widget \"$w\" does not seem to be a\
			    menu, which is required for the -index switch"
        }
        set index [lindex $args 1]
        set args [lreplace $args 0 1]
      }
      -side	{
        if {[lsearch -exact [list left right top bottom] \
                 [lindex $args 1]] == -1} {
          return -code error "-side [lindex $args 1] is not one of\
			    left, right, top, or bottom"
        }
        set side [lindex $args 1]
        set args [lreplace $args 0 1]
      }
      -font	{
        set font [lindex $args 1]
        set args [lreplace $args 0 1]
      }
      -delay	{
        if {(! [regexp {^[0-9]+$} [lindex $args 1]]) || ([lindex $args 1] < 50)} {
          return -code error "BalloonHelp delay must be an\
			    integer greater than 50 (delay is in millisecs)"
        }
        set delay [lindex $args 1]
        set args [lreplace $args 0 1]
      }
      default	{
        return -code error "unknown option \"$key\": should be -index, or -side"
      }
    }
    set key [lindex $args 0]
  }
  if {[llength $args] != 1} {
    return -code error "wrong \# args: should be \"balloonhelp widget\
		?-index index? ?-side side? message\""
  }
  # do not clear balloon for null text entry
#   puts stderr "BalloonHelp:register: key $key "
#   if {[string match {} $key]} {
#     BalloonHelp:clear $w
#   }
  if {![winfo exists $w]} {
    return -code error "bad window path name \"$w\""
  }
  if {[info exists index]} {
    set BalloonHelp($w,$index) $key
    bindtags $w [linsert [bindtags $w] end BalloonsMenu]
    return $w,$index
  } else {
    # puts stderr "BalloonHelp:register: w $w"
    set BalloonHelp($w) $key
    set BalloonSide($w) $side
    set BalloonFont($w) $font
    set BalloonDelay($w) $delay
    bindtags $w [linsert [bindtags $w] end BalloonHelp Balloons]
    return $w
  }
}

;proc BalloonHelp:clear {{pattern .*}} {
    global BalloonHelp
    foreach w [array names BalloonHelp $pattern] {
	unset BalloonHelp($w)
	if {[winfo exists $w]} {
	    set tags [bindtags $w]
	    if {[set i [lsearch $tags Balloons]] != -1} {
		bindtags $w [lreplace $tags $i $i]
	    }
	    ## We don't remove BalloonsMenu because there
	    ## might be other indices that use 
        }
    }
}

## 03oct97 wmt: add side arg
## 10oct97 wmt: allow for multiple lines when balloon goes off screen
##              and -side is right or left
## 07dec97 wmt: add font arg
## 04nov99 wmt: originally designed for one balloon to exist at one time;
##              allow multiple balloons to exist at the same time
;proc BalloonHelp:show {w msg side font {i {}} } {
  if {! [winfo exists $w] || \
          [string compare $w [eval winfo containing \
                                  [winfo pointerxy $w]]]} {
    return
  }
  global BalloonHelp g_NM_schematicMode pirNode g_NM_instanceToNode
  global g_NM_paletteStructureList g_NM_terminalTypeValuesArray 
  global g_NM_vmplTestModeP g_NM_nodeTypeRootWindow
  global g_NM_stepCommandsMonitors g_NM_scenarioDialogRoot
  global g_NM_scenarioNameRootWindow g_NM_editPrefsRootWindow 
  global g_NM_editDSColorPrefsRootWindow g_NM_groundProcessingUnitP 

  if {[string match $msg ""]} {
    return
  }
  # puts stderr "BalloonHelp:show w $w msg `$msg' i `$i'"
  if {[string match $i nil]} { set i {}}
  set reportNotFoundP 0
  set b $BalloonHelp(TOPLEVEL)
  if {[string match $g_NM_schematicMode "operational"] && \
          (! [regexp "lab.icon" $w]) && \
          (! [regexp $g_NM_nodeTypeRootWindow $w]) && \
          (! [regexp $g_NM_scenarioNameRootWindow $w]) && \
          (! [regexp $g_NM_scenarioDialogRoot $w]) && \
          (! [regexp "menus_accels" $w]) && \
          (! [regexp "back.label" $w]) && \
          (! [regexp $g_NM_editPrefsRootWindow $w]) && \
          (! [regexp $g_NM_editDSColorPrefsRootWindow $w])} {
    # do not do this for preferences
    set nodeIndex [getPirNodeIndexFromButtonPath $w]
    set terminalNodeIndex [getTerminalPirNodeIndexFromButtonPath $w]
    # set str "BalloonHelp:show nodeIndex $nodeIndex terminalNodeIndex"
    # puts stderr "$str $terminalNodeIndex w $w"
    if {[string match [assoc nodeClassType pirNode($nodeIndex)] attribute]} {
      set location out; set num 1
    } else {
      getLocation&NumFromButton $w location num
    }
    set terminalFormList [assoc ${location}puts pirNode($nodeIndex)]
    set terminalForm [assoc ${location}$num terminalFormList]
    set terminalType [getTerminalType $terminalForm]
    set attributeList {}
    if {[lsearch -exact $g_NM_paletteStructureList $terminalType] >= 0} {
      set termTypeValueList [assoc-array $terminalType \
                                 g_NM_terminalTypeValuesArray] 
      for {set indx 0} {$indx < [llength $termTypeValueList]} {incr indx 2} {
        lappend attributeList [lindex $termTypeValueList $indx]
      }
    }
    set terminalInstance [assoc terminal_name terminalForm]
    set terminalNodeIndex [assoc-array $terminalInstance g_NM_instanceToNode \
                              $reportNotFoundP]
    if {$terminalNodeIndex == ""} {
      # mouse is over a top-level terminal whose lower level instance has not
      # beeen created yet
      return
    }
    # puts stderr "terminalNodeIndex $terminalNodeIndex terminalInstance $terminalInstance"
    set parentInstance [lindex [assoc parentNodeGroupList \
                                    pirNode($terminalNodeIndex)] 0]
    getComponentModulePirNodeIndex $parentInstance parentNodeIndex nodeClassType
    # puts stderr "parentNodeIndex $parentNodeIndex parentInstance $parentInstance"
    set nodePropList [assoc nodePropList pirNode($parentNodeIndex)]
    # puts stderr "balloon:show: parentNodeIndex $parentNodeIndex nodePropList $nodePropList"
    # discard :values -- replace with :value
    set index [string first "values:" $msg] 
    set msg "[string range $msg 0 [expr {$index - 1}]]values: "
    set valueMsg ""
    set cnt 0; set valueFormList {}; set cmdMonitorValues {}
    set instrumentPair ""
    # check for user Mouse-R selected values
    set valueFormList [assoc $w g_NM_stepCommandsMonitors $reportNotFoundP]  
    # puts stderr "ballonHelp::show: valueFormList $valueFormList"
    set terminalInstanceExpanded [expandStructureTerminalNames terminalForm]
    set cmdMonConstraintP [terminalValuesConstrainedOrInferred terminalForm \
                               $parentNodeIndex cmdMonitorValues]
    set inheritedCmdMonP [assoc inheritedCmdMonP pirNode($terminalNodeIndex) \
                              $reportNotFoundP]
    if {$inheritedCmdMonP == ""} { set inheritedCmdMonP 0 }
    if {$inheritedCmdMonP} {
      set instrumentPair [assoc commandMonitorType terminalForm]
    }
    # puts stderr "BalloonHelp:show: inheritedCmdMonP $inheritedCmdMonP"
    # puts stderr "commandMonitorType [assoc commandMonitorType terminalForm]"
    # when data is from GPU we have no knowledge of exogenous/inferred
    set addExogenousInferredP \
        [expr {$g_NM_vmplTestModeP && (! $g_NM_groundProcessingUnitP) && \
                   $inheritedCmdMonP && ($instrumentPair != "")}]
    foreach propTerminalInstance $terminalInstanceExpanded constraintP $cmdMonConstraintP cmdMonitorVal $cmdMonitorValues {
      if {$valueFormList != ""} {
        set valueForm [lindex $valueFormList $cnt]
        # get proposition value - e.g. pipeIn.pressure.sign = positive
        set index [string last " " $valueForm]
        set value [string range $valueForm [expr {$index + 1}] end]
      } else {
        set attList [assoc $propTerminalInstance nodePropList $reportNotFoundP]
        if {$attList != ""} {
          set value [assoc value attList]
        } else {
          # a standalone top-level terminal has been made private by the user
          # and thus is not inherited up to "test" and does not exist in
          # its nodePropList
          set value ""
        }
      }
      if {! [string match [set att [lindex $attributeList $cnt]] ""]} {
        append valueMsg "$att "
      }
      append valueMsg "$value "
      if {$addExogenousInferredP && ([llength $cmdMonConstraintP] > 1)} {
        if {$constraintP} {
          append valueMsg "(e) "
        } else {
          append valueMsg "(i) "
        }
      }
      # append command value, if it was set in last time step
      if {([lindex $instrumentPair 0] == "commanded") && $constraintP} {
        append valueMsg "($cmdMonitorVal) "
      }
      incr cnt 
    }
    append msg [multiLineList $terminalType $valueMsg values: $addExogenousInferredP] 
    # show user instrumented terminal type
    if {$addExogenousInferredP} {
      append msg "\n[lindex $instrumentPair 0]"
      if {[llength $cmdMonConstraintP] == 1} {
        if {[lindex $cmdMonConstraintP 0]} {
          append msg " => exogenous"
        } else {
          append msg " => inferred"
        }
      } else {
        append msg " => exogenous(e)/inferred(i)"
      }
    }
    # puts stderr "BalloonHelp:show msg $msg"
  }
  $b.l configure -text $msg
  $b.l configure -font $font 
  set numLines [expr {1 + [regsub -all "\\\n" $msg "\n" tmp]}]
  update idletasks
  if {[string compare {} $i]} {
    # menus
    set y [expr {[winfo rooty $w]+[$w yposition $i]+25}]
    if {($y+[winfo reqheight $b])>[winfo screenheight $w]} {
      set y [expr {[winfo rooty $w]+[$w yposition $i]- \
                       [winfo reqheight $b] - 5}]
    }
  } else {
    switch $side {
      left {
        set y [winfo rooty $w] 
      }
      right {
        set y [winfo rooty $w]
      }
      top {
        # rooty is upper left hand corner
        # set y [expr {[winfo rooty $w] - [winfo height $w] - 5}]
        # set y [expr {[winfo rooty $w] - ([winfo height $w]/2) - 10}]
        set y [expr {[winfo rooty $w] - 25}]
      }
      bottom {
        # set y [expr {[winfo rooty $w] + [winfo height $w] + 5}]
        # set y [expr {[winfo rooty $w] + ([winfo height $w]/2) + 10}]
        set y [expr {[winfo rooty $w] + [winfo height $w] + 25}]
      }
    }
    if {($y+[winfo reqheight $b])>[winfo screenheight $w]} {
      set y [expr {[winfo rooty $w]-[winfo reqheight $b]-5}]
    }
  }
  switch $side {
    left {
      set x [expr {[winfo rootx $w] - [winfo reqwidth $b]}]
    }
    right {
      set x [expr {[winfo rootx $w] + [winfo width $w] + 5}]
    }
    top {
      set x [expr [winfo rootx $w]+([winfo width $w]-[winfo reqwidth $b])/2]
      # do not center it -- make it as much like right
      # set x [expr {[winfo rootx $w] + [winfo width $w] + 5}]
    }
    bottom {
      set x [expr [winfo rootx $w]+([winfo width $w]-[winfo reqwidth $b])/2]
      # do not center it -- make it as much like right
      # set x [expr {[winfo rootx $w] + [winfo width $w] + 5}]
    }
  }
  if {$x<0} {
    if {[string match $side left]} {
      # make it a top
      set y [expr {[winfo rooty $w] - ([winfo height $w] * $numLines) - 5}] 
    } 
    set x 0
  } elseif {($x+[winfo reqwidth $b]) >= ([winfo screenwidth $w] - 10)} {
    if {[string match $side right]} {
      # move it below the mouse location, so it will not flicker
      # flicker is caused by attempting to display balloon over cursor
      set y [expr {[winfo rooty $w] + 35}] 
    } 
    set x [expr {[winfo screenwidth $w] - [winfo reqwidth $b] - 15}]
  }
  # puts stderr "BalloonHelp:show: x $x width [winfo reqwidth $b] screen [winfo screenwidth $w] side $side rootx [winfo rootx $w]"
  wm geometry $b +$x+$y
  wm deiconify $b
  raise $b
}

;proc BalloonHelp:hide {} {
  global BalloonHelp 

  #   puts stderr "balloon hide"
  #   set backtrace ""; getBackTrace backtrace
  #   puts stderr "BalloonHelp:hide: `$backtrace'"
  after cancel $BalloonHelp(AFTERID)
  catch {wm withdraw $BalloonHelp(TOPLEVEL)}
}


########################################################################
########################################################################
## following code is by will taylor

####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####
## generalized  balloon help generation for terminals and attributes
## return type values list
## 19nov98 wmt: new
proc terminalBalloonHelp { terminalListRef terminalName labelName type nodeClassType \
                               nodeClassName window {buttonLocation ""} {num ""} \
                               {connectionP 0} {canvasRootId 0} } {
  upvar $terminalListRef terminalList 
  global g_NM_terminalTypeValuesArray 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "terminalBalloonHelp: `$backtrace'"
  set reportNotFoundP 0; set valuesList {}
  set balloonString [getTerminalDirectionPretty $terminalList $nodeClassType \
                         $nodeClassName]
  append balloonString "\n"
  set terminalNameExternal [getExternalNodeName $terminalName]
  if {($labelName != "") && (! [string match $terminalNameExternal $labelName])} {
    set labelName [getTerminalBalloonLabel terminalList]
    append balloonString "label:  $labelName\n" 
  }

  # puts stderr "terminalBalloonHelp: terminalName $terminalName type $type"
  if {[regexp "\\\?" $type]} {
    # type name is a parameter -- type not determined until instantiation
    set paramType [getParameterType $type] 
    append balloonString "name:         $terminalNameExternal\n"
    append balloonString "param type:   $paramType ($type)\n"
    set valuesLabel "param values:"
    set valuesList [assoc-array $paramType g_NM_terminalTypeValuesArray] 
  } else {
    append balloonString "name:   $terminalNameExternal\n"
    append balloonString "type:   $type\n"
    set valuesLabel "values:"
    set valuesList [assoc-array $type g_NM_terminalTypeValuesArray]
  }
  append balloonString "$valuesLabel [multiLineList $type $valuesList $valuesLabel]"

  set balloonWindow $window
  if {! [string match $buttonLocation ""]} {
    set balloonWindow $window.$buttonLocation.b$num
  }
  # puts stderr "terminalBalloonHelp: balloonWindow $balloonWindow"
  if {$connectionP} {
    # for source terminal in terminal connection process
    set balloonWidgetName $terminalName 
    set balloonType connection
    permanentBalloonHelp $balloonWidgetName $balloonWindow $balloonString \
        $balloonType "default" "default" $canvasRootId
  } else {
    # mouse-over-terminal activated
    balloonhelp $balloonWindow -side right \
        -font [preferred StanleyTerminalTypeFont] -delay 100 $balloonString
  }
  return $valuesList 
}


## call terminalBalloonHelp using terminalForm
## 21oct99 wmt: new
proc callTerminalBalloonHelp { terminalFormRef nodeClassType nodeClassName \
                                   window location num } {
  upvar $terminalFormRef terminalForm

  set reportNotFoundP 0
  set terminalName [list [assoc terminal_name terminalForm]]
  set labelName [assoc terminal_label terminalForm $reportNotFoundP]
  set type [getTerminalType $terminalForm]
  set valuesList [terminalBalloonHelp terminalForm $terminalName \
                      $labelName $type $nodeClassType $nodeClassName \
                      $window $location $num]
  return $valuesList 
}


## return balloon help terminal label
## 08jul98 wmt: new
proc getTerminalBalloonLabel { terminalFormRef } {
  upvar $terminalFormRef terminalForm

  set reportNotFoundP 0; set returnIndexP 1
  set terminalLabel [assoc terminal_label terminalForm]
  set index [assoc inherit_classArgsValues terminalForm $reportNotFoundP \
                   $returnIndexP]
  if {$index == -1} {
    return $terminalLabel
  } else {
    # do something different here
    return $terminalLabel 
  }
}


## create a canvas label object to display node icon labels and
## Test mode terminal values
## 01dec99 wmt: new
proc mkCanvasLabelBalloon { nodeWidget xRoot yRoot labelText canvas xPosRef yPosRef \
                                balloonType cmdMonConstraintP \
                                {xOffset "default"} {yOffset "default"} } {
  upvar $xPosRef xPos
  upvar $yPosRef yPos
  global g_NM_vmplTestModeP g_NM_defaultDisplayState

  set winname [uniqueWindowName $canvas]
  if {$balloonType == "iconLabel"} {
    set highlightThickness 0
    set labelBgColor [preferred StanleySchematicCanvasBackgroundColor]
    if {$g_NM_vmplTestModeP} {
      set labelBgColor [preferred StanleyTestCanvasBackgroundColor]
    }
    frame $canvas.$winname -background $labelBgColor \
        -bd 0 -highlightthickness 0
    label $canvas.$winname.label -highlightthickness 0 -relief flat \
        -justify left -font [preferred StanleyComponentLabelFont] -wraplength 0 \
        -text $labelText \
        -fg [preferred StanleyBalloonHelpForegroundColor] -bg $labelBgColor 
    pack $canvas.$winname.label
    set labelWidget $canvas.$winname.label
  } elseif {$balloonType == "testValues"} {
    set highlightThickness 1
    set labelBgColor [preferred StanleyBalloonHelpBackgroundColor]
    frame $canvas.$winname -background $labelBgColor \
        -bd 0 -highlightthickness 0
    # puts stderr "mkCanvasLabelBalloon: labelText $labelText cmdMonConstraintP $cmdMonConstraintP"
    frame $canvas.$winname.labels -background $labelBgColor \
        -bd 0 -highlightthickness $highlightThickness -highlightbackground black 
    for {set i 0} {$i < [llength $labelText]} {incr i} {
      if {[lindex $cmdMonConstraintP $i] || [regexp $g_NM_defaultDisplayState \
                                                 [lindex $labelText $i]]} {
        # this value constrained by user or noData
        set fgColor [preferred StanleyBalloonHelpForegroundColor]
        set bgColor $labelBgColor
      } else {
        # this value is determnined by Livingstone
        set fgColor white
        set bgColor [preferred StanleyTitleBgColor]
      }
      label $canvas.$winname.labels.lab$i -highlightthickness 0 -relief flat \
          -justify left -font [preferred StanleyTerminalTypeFont] -wraplength 0 \
          -text [lindex $labelText $i] \
          -fg $fgColor -bg $bgColor
      pack $canvas.$winname.labels.lab$i -side left
    }
    pack $canvas.$winname.labels
    set labelWidget $canvas.$winname.labels 
  } else {
    error "mkNodeLabelBalloon: balloonType $balloonType not handled"
  }
  # position balloon to default location, unless already positioned
  if {(($balloonType == "iconLabel") && (($xPos == -1) || ($yPos < 5))) || \
          ($balloonType == "testValues")} {
    if {[string match $xOffset "default"]} {
      # center label over widget
      set xOffset [expr {([winfo reqwidth $nodeWidget] - \
                              [winfo reqwidth $labelWidget])/2}]
    }
    if {[string match $yOffset "default"]} {
      set yOffset -25
    }
    set xPos [expr {$xRoot + $xOffset}]
    set yPos [expr {$yRoot + $yOffset}]
  }
  # puts stderr "mkCanvasLabelBalloon: winname $winname xPos $xPos yPos $yPos "
  return $canvas.$winname
}


## use a canvas label to create "permanent" balloon help widget
## 22dec98 wmt: new
proc permanentBalloonHelp { balloonWidgetName window text balloonType \
                                {xOffset "default"} {yOffset "default"} \
                                {canvasRootId 0} {cmdMonConstraintP 0} } {
  global g_NM_permBalloonRootWindow g_NM_vmplTestModeP 
  global g_NM_connectionBalloonWidget g_NM_menuStem
  global g_NM_testValuesBalloons g_NM_testPermBalloonsState
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_testInstanceNameInternal

  # puts stderr "permanentBalloonHelp: window $window balloonWidgetName $balloonWidgetName"
  set reportNotFoundP 0; set oldvalMustExistP 0
  if {($balloonType == "connection") || ($balloonType == "stateViewer")} {
    # balloon window for from terminal connection "permanent" balloon help
    # and state viewer column tags 
    # puts stderr "permanentBalloonHelp: balloonWidgetName $balloonWidgetName"
    set balloonWidgetName [getTclPathNodeName [getExternalNodeName $balloonWidgetName]]
    set b $g_NM_permBalloonRootWindow.$balloonWidgetName
    if {[winfo exists $b]} {
      destroy $b
    }
    toplevel $b
    wm overrideredirect $b 1
    wm withdraw $b
    pack [label $b.l -highlightthickness 1 -relief flat -justify left \
              -font [preferred StanleyTerminalTypeFont] \
              -highlightbackground black \
              -wraplength 0 -text $text \
              -fg [preferred StanleyBalloonHelpForegroundColor] \
              -bg [preferred StanleyBalloonHelpBackgroundColor]]
    # position balloon
    if {[string match $xOffset "default"]} {
      set xOffset [winfo width $window]
    }
    if {[string match $yOffset "default"]} {
      set yOffset 0
    }
    set xRoot [winfo rootx $window]
    set yRoot [winfo rooty $window] 
    set xPos [expr {$xRoot + $xOffset}]
    set yPos [expr {$yRoot + $yOffset}]
    wm geometry $b +$xPos+$yPos
    wm deiconify $b
  } elseif {$balloonType == "testValues"} {
    # all test balloons exist on test top-level canvas
    # set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
    set canvas "[getCanvasRoot $canvasRootId].canvas"
    set canvas "$canvas.[getTclPathNodeName ${g_NM_testInstanceNameInternal}].c"
    # puts stderr "permanentBalloonHelp: canvas $canvas"
    # is this a replacement value for an existing balloon, if yes delete it
    set balloonList [assoc-array $window g_NM_testValuesBalloons $reportNotFoundP]
    if {$balloonList != ""} {
      $canvas delete [lindex $balloonList 1]
      destroy [lindex $balloonList 0]
      adel-array $window g_NM_testValuesBalloons
    }
    # canvas label for Test mode terminal value(s) balloons
    # create a canvas text object
    # puts stderr "permanentBalloonHelp: text $text cmdMonConstraintP $cmdMonConstraintP"
    getWindowCanvasXY $canvas $window xRoot yRoot
    set labelWindow [mkCanvasLabelBalloon $window $xRoot $yRoot $text $canvas \
                         xPos yPos $balloonType $cmdMonConstraintP $xOffset $yOffset]
    set labelCanvasId \
        [$canvas create window $xPos $yPos -anchor nw -window $labelWindow \
             -tags testBalloonValues]
    # puts stderr "permanentBalloonHelp: $canvas $canvas labelWindow $labelWindow"
    # draw a line from window to balloon to help user with association
    set lineCanvasId [$canvas create line $xRoot $yRoot $xPos $yPos \
                          -width 1 -fill [preferred StanleyBalloonHelpBackgroundColor] \
                          -tags testBalloonLines]
    arepl-array $window [list $labelWindow $labelCanvasId $text $cmdMonConstraintP] \
        g_NM_testValuesBalloons $reportNotFoundP $oldvalMustExistP
    # puts stderr "permanentBalloonHelp: g_NM_testValuesBalloons $g_NM_testValuesBalloons"
    if {$g_NM_testPermBalloonsState == "hide"} {
      $canvas move $labelCanvasId $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight
      # hide lines from window to balloon to help user with association
      set bgColor [preferred StanleySchematicCanvasBackgroundColor] 
      if {$g_NM_vmplTestModeP} {
        set bgColor [preferred StanleyTestCanvasBackgroundColor]
      }
      $canvas itemconfigure $lineCanvasId -fill $bgColor 
      $canvas lower $lineCanvasId 
    }

  } else {
    error "balloonType $balloonType not handled"
  }
}


## show all perm balloons created by Test->Instantiate
## 15nov99 wmt: new
## 15mar01: not used anymore
proc showTestPermanentBalloons { {canvasRootId 0} } {
  global g_NM_menuStem g_NM_testPermBalloonsState  
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight 

  set canvasRoot [getCanvasRoot $canvasRootId]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  # show test balloons
  # move them from off-screen to where user can see them
  foreach id [$canvas find withtag testBalloonValues] {
    $canvas move $id -$g_NM_absoluteCanvasWidth -$g_NM_absoluteCanvasHeight
  }
  $canvas raise testBalloonValues

  # show lines from window to balloon to help user with association
  foreach id [$canvas find withtag testBalloonLines] {
    $canvas itemconfigure $id -fill [preferred StanleyBalloonHelpBackgroundColor]
  }
  $canvas raise testBalloonLines 

  $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
      -state disabled
  $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
      -state normal
  set g_NM_testPermBalloonsState show
}


## hide all perm balloons created by Test->Instantiate
## 15nov99 wmt: new
## 15mar01: not used anymore
proc hideTestPermanentBalloons { {canvasRootId 0} } {
  global g_NM_menuStem g_NM_testPermBalloonsState 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_vmplTestModeP 

  set canvasRoot [getCanvasRoot $canvasRootId]
  set menuRoot $canvasRoot.$g_NM_menuStem 
  set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  # hide test balloons
  # move them off-screen to where user can not see them
  foreach id [$canvas find withtag testBalloonValues] {
    $canvas move $id $g_NM_absoluteCanvasWidth $g_NM_absoluteCanvasHeight
  }
  
  # hide lines from window to balloon to help user with association
  set bgColor [preferred StanleySchematicCanvasBackgroundColor] 
  if {$g_NM_vmplTestModeP} {
    set bgColor [preferred StanleyTestCanvasBackgroundColor]
  }
  foreach id [$canvas find withtag testBalloonLines] {
    $canvas itemconfigure $id -fill $bgColor 
  }
  $canvas lower testBalloonLines 

  $menuRoot.tools.m entryconfigure "Hide Test Permanent Balloons" \
      -state disabled
  $menuRoot.tools.m entryconfigure "Show Test Permanent Balloons" \
      -state normal
  set g_NM_testPermBalloonsState hide
}


## "permanently" pop-up all icon label balloons
## for the current canvas
## 04nov99 wmt: new
proc showIconLabelBalloons { caller {canvasRootId 0} } {
  global pirNode pirNodes
  global g_NM_showIconLabelBalloonsP g_NM_acceleratorStem
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight 

  set reportNotFoundP 0
  if {[string match $caller "mainWindow"]} {
    set g_NM_showIconLabelBalloonsP 1
    set canvasRoot [getCanvasRoot $canvasRootId]
    set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
    $acceleratorRoot.show_labels.label config -state disabled
    $acceleratorRoot.hide_labels.label config -state normal
  }
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  append currentCanvas ".c"
  # special handling for ? & .
  set currentCanvasRegexp [getMplRegExpression $currentCanvas]
  # puts stderr "\nshowIconLabelBalloons: currentCanvasRegexp $currentCanvasRegexp"
  foreach pirNodeIndex $pirNodes {
    set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $reportNotFoundP]
#     if {[regexp svName [assoc nodeInstanceName pirNode($pirNodeIndex)]]} {
#       puts stderr "showIconLabelBalloons: nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)] regexp [regexp $currentCanvasRegexp [assoc window pirNode($pirNodeIndex)]] labelWindowSeenP [assoc labelWindowSeenP  pirNode($pirNodeIndex)]"
#     }
    if {($labelCanvasId != "") && \
            [regexp $currentCanvasRegexp [assoc window pirNode($pirNodeIndex)]] && \
            ([assoc nodeClassName pirNode($pirNodeIndex)] != "displayState") && \
            ([assoc nodeState pirNode($pirNodeIndex)] != "parent-link")} {
      if {[assoc labelWindowSeenP  pirNode($pirNodeIndex)] == 0} {
        # move it from off-screen to where user can see it (trailing . already there)
        $currentCanvas move $labelCanvasId -$g_NM_absoluteCanvasWidth \
            -$g_NM_absoluteCanvasHeight
        raise [assoc labelWindow pirNode($pirNodeIndex)]
        # set this to -1 so that selectNode & deselectNode will NOT change the label
        arepl labelWindowSeenP -1 pirNode($pirNodeIndex)
      }
    }
  }
}
    

## hide "permanent" pop-up all icon label balloons
## 04nov99 wmt: new
proc hideIconLabelBalloons { caller {canvasRootId 0} } {
  global pirNode pirNodes
  global g_NM_showIconLabelBalloonsP g_NM_acceleratorStem 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight 

  set reportNotFoundP 0
  if {[string match $caller "mainWindow"]} {
    set g_NM_showIconLabelBalloonsP 0
    set canvasRoot [getCanvasRoot $canvasRootId]
    set acceleratorRoot $canvasRoot.$g_NM_acceleratorStem
    $acceleratorRoot.show_labels.label config -state normal
    $acceleratorRoot.hide_labels.label config -state disabled
  }
  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  append currentCanvas ".c"
  # special handling for ? & .
  set currentCanvasRegexp [getMplRegExpression $currentCanvas]
  # puts stderr "\nhideIconLabelBalloons: currentCanvasRegexp $currentCanvasRegexp"
  foreach pirNodeIndex $pirNodes {
    set labelCanvasId [assoc labelCanvasId pirNode($pirNodeIndex) $reportNotFoundP]
#     if {[regexp svName [assoc nodeInstanceName pirNode($pirNodeIndex)]]} {
#       puts stderr "hideIconLabelBalloons: nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)] regexp [regexp $currentCanvasRegexp [assoc window pirNode($pirNodeIndex)]] labelWindowSeenP [assoc labelWindowSeenP  pirNode($pirNodeIndex)]"
#     }
    if {($labelCanvasId != "") && \
            [regexp $currentCanvasRegexp [assoc window pirNode($pirNodeIndex)]] && \
            ([assoc nodeClassName pirNode($pirNodeIndex)] != "displayState") && \
            ([assoc nodeState pirNode($pirNodeIndex)] != "parent-link")} {
      if {[assoc labelWindowSeenP  pirNode($pirNodeIndex)] == -1} {
        # move it off-screen to where user can not see it
        $currentCanvas move $labelCanvasId $g_NM_absoluteCanvasWidth \
            $g_NM_absoluteCanvasHeight
        # set this to 0 so that selectNode & deselectNode will change the label
        arepl labelWindowSeenP 0 pirNode($pirNodeIndex)
      }
    }
  }
}


## add \n to long lists of type values: var val pairs
## or with addExogenousInferredP = 1, var val e/i triplets
## 17dec99 wmt: new
proc multiLineList { type valuesList header {addExogenousInferredP 0} } {
  global g_NM_paletteStructureList  pirClassStructure
  global pirClassesStructure 

  # puts stderr "multiLineList: type $type valuesList $valuesList"
  set silentP 1
  if {[lsearch -exact $g_NM_paletteStructureList $type] >= 0} {
    # format structured type value lists
    set relValuesList {}; set increment 2
    if {$addExogenousInferredP} {
      set increment 3
    }
    for {set i 0} {$i < [llength $valuesList]} {incr i $increment} {
      append relValuesList "\[[lindex $valuesList $i]\] "
      append relValuesList "[lindex $valuesList [expr {$i + 1}]] "
      if {$addExogenousInferredP} {
        append relValuesList "[lindex $valuesList [expr {$i + 2}]] "
      }
    }
    set valuesList $relValuesList 
  }
  set multiLineValuesString ""
  set cnt 0; set numberPerLine 4
  set headerlen [string length $header]
  foreach val $valuesList {
    set leftSquareBracketP [expr {[string index $val 0] == "\["}]
    if {($cnt > 0) && ((($cnt % $numberPerLine) == 0) || \
                           $leftSquareBracketP)} {
      append multiLineValuesString "\n"
      for {set i 0} {$i <= $headerlen} {incr i} {
        append multiLineValuesString " "
      }
      if {$leftSquareBracketP} {
        set cnt 0
      }
    }
    append multiLineValuesString "$val "
    incr cnt
  }
  
  return $multiLineValuesString 
}


## delete test values balloons whose values are predicted by L2
## 01aug00 wmt
proc deleteL2TestValueBalloons { {canvasRootId 0} }  {
  global g_NM_testValuesBalloons 

  set canvas "[getCanvasRootInfo g_NM_currentCanvas $canvasRootId].c"
  set labelBgColor [preferred StanleyBalloonHelpBackgroundColor]
  set windowDeleteList {}
  for {set indx 1} {$indx < [llength $g_NM_testValuesBalloons]} {incr indx 2} {
    set balloonList [lindex $g_NM_testValuesBalloons $indx]
    set labelWindow [lindex $balloonList 0] 
    set labelCanvasId [lindex $balloonList 1]
    set text [lindex $balloonList 2]
    set cmdMonConstraintP [lindex $balloonList 3]
    # puts stderr "deleteL2TestValueBalloons: labelWindow $labelWindow text `$text' cmdMonConstraintP $cmdMonConstraintP"
    if {[llength $text] == 1} {
      # single valued type
      if {$cmdMonConstraintP == 0} {
        $canvas delete $labelCanvasId 
        destroy $labelWindow
        lappend windowDeleteList [lindex $g_NM_testValuesBalloons \
                                      [expr {$indx - 1}]]
      }
    } else {
      # multiple valued type - change L2 background to user constrained bg
      set l2Count 0
      for {set i 0} {$i < [llength $text]} {incr i} {
        if {[lindex $cmdMonConstraintP $i] == 0} {
          $labelWindow.labels.lab$i configure -text "" -bg $labelBgColor
          incr l2Count 
        }
      }
      if {$l2Count == [llength $text]} {
        # all values are set by L2 - delete window
        lappend windowDeleteList [lindex $g_NM_testValuesBalloons \
                                      [expr {$indx - 1}]]
      }
    }
  }
  foreach window $windowDeleteList {
    adel $window g_NM_testValuesBalloons
  }
}


## display a test value balloon for an assign or progress
## specified by the user
## derived from showCommandMonitorTerminalBalloons
## 01aug00 wmt
proc displayUserTestValueBalloon { propNameAndValue } {
  global g_NM_selectedTestScopeRoot g_NM_testInstanceNameInternal
  global g_NM_moduleToNode g_NM_componentToNode pirNode pirNodes
  global g_NM_vmplUserPropArray 

  set caller "displayUserTestValueBalloon"
  set reportNotFoundP 0
  set balloonType testValues
  set canvasRootId 0
  set pair [split $propNameAndValue "="]
  set propName [lindex $pair 0]
  set value [lindex $pair 1]
  # puts stderr "displayUserTestValueBalloon: propName $propName value $value"
  reduceStructurePropnameToRoot $propName name terminalNodeIndex
  set terminalInstanceName [assoc nodeInstanceName pirNode($terminalNodeIndex)]
  set nodePropList {}
  if {[string match $propName $terminalInstanceName]} {
    # single valued type only
    lappend nodePropList $propName [list value $value]
  } else {
    # multiple valued (structured) type
    # puts stderr "\ndisplayUserTestValueBalloon: propName $propName terminalInstanceName $terminalInstanceName value $value"
    set entry [assoc-array $terminalInstanceName g_NM_vmplUserPropArray \
                   $reportNotFoundP]
    if {$entry == ""} {
      set terminalType [getTerminalInstanceType $terminalNodeIndex terminalForm \
                            $reportNotFoundP]
      set expndPropNameList [expandStructurePropNames $terminalInstanceName \
                                 $terminalType expndStructP]
      # puts stderr "displayUserTestValueBalloon: expndPropNameList $expndPropNameList"
      set entry {}
      foreach name $expndPropNameList {
        lappend entry $name null
      }
    }
    arepl $propName [list value $value] entry
    # puts stderr "displayUserTestValueBalloon: terminalInstanceName $terminalInstanceName entry $entry"
    set g_NM_vmplUserPropArray($terminalInstanceName) $entry
    # we need the other values before we can show the balloon
    if {[regexp "null" $entry]} {
      return
    } else {
      # now process the root name of the structured proposition
      set propName $terminalInstanceName
      set nodePropList $entry
    }
  }
  set currentNodeGroup $g_NM_testInstanceNameInternal
  if {$g_NM_selectedTestScopeRoot == "module"} {
    set groupPirNodeIndex $g_NM_moduleToNode($currentNodeGroup)
  } else {
    set groupPirNodeIndex $g_NM_componentToNode($currentNodeGroup) 
  }
  set foundP 0
  # is this a terminal?
  foreach pirNodeIndex $pirNodes {
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    set nodeState [assoc nodeState pirNode($pirNodeIndex)]
    if {[string match [assoc nodeGroupName pirNode($pirNodeIndex)] \
             $currentNodeGroup] && \
            (! [string match $nodeClassName "displayState"]) && \
            (! [string match $nodeClassType "attribute"]) && \
            (! [string match $nodeState "parent-link"])} {
      if {[string match $nodeClassType "terminal"] && \
              (! [regexp "Declaration" $nodeClassName])} {
        # puts stderr "nodeInstanceName $nodeInstanceName"
        if {[string match [assoc nodeClassName pirNode($pirNodeIndex)] \
                 "input"]} {
          set outputs [assoc outputs pirNode($pirNodeIndex)]
          set terminalForm [assoc out1 outputs]
        } else {
          set inputs [assoc inputs pirNode($pirNodeIndex)]
          set terminalForm [assoc in1 inputs]
        }
        if {[string match $propName [assoc terminal_name terminalForm]]} {
          # puts stderr "displayUserTestValueBalloon: term pirNodeIndex $pirNodeIndex terminalName [assoc terminal_name terminalForm]"
          set foundP 1
          showCommandMonitorTerminalBalloonsDoit \
              "current" $nodeClassType null terminalForm nodePropList \
              $pirNodeIndex null $caller      
          return
        }
      } elseif {[string match $nodeClassType "component"] || \
                    [string match $nodeClassType "module"]} {
        set window [assoc window pirNode($pirNodeIndex)]
        set edgesToList [assoc edgesTo pirNode($pirNodeIndex)]
        set numInputs [assoc numInputs pirNode($pirNodeIndex)]
        set inputs [assoc inputs pirNode($pirNodeIndex)]
        for {set num 1} {$num <= $numInputs} {incr num} {
          if {[string match [lindex $edgesToList [expr {$num - 1}]] ""]} {
            # not connected - thus external, if public
            set buttonPath "${window}.in.b$num"
            set terminalForm [assoc in$num inputs]
            if {([assoc interfaceType terminalForm] == "public") && \
                    [string match $propName [assoc terminal_name terminalForm]]} {
              # puts stderr "displayUserTestValueBalloon: comp/mod in pirNodeIndex $pirNodeIndex terminalName [assoc terminal_name terminalForm]"
              set foundP 1
              showCommandMonitorTerminalBalloonsDoit \
                  "current" $nodeClassType inputs terminalForm nodePropList \
                  $pirNodeIndex $buttonPath $caller   
              return
            }
          }
        }

        set edgesFromList [assoc edgesFrom pirNode($pirNodeIndex)]
        set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
        set outputs [assoc outputs pirNode($pirNodeIndex)]
        for {set num 1} {$num <= $numOutputs} {incr num} {
          if {[string match [lindex $edgesFromList [expr {$num - 1}]] ""]} {
            # not connected - thus external, if public
            set buttonPath "${window}.out.b$num"
            set terminalForm [assoc out$num outputs]
            if {([assoc interfaceType terminalForm] == "public") && \
                    [string match $propName [assoc terminal_name terminalForm]]} {
              # puts stderr "displayUserTestValueBalloon: comp/mod out pirNodeIndex $pirNodeIndex terminalName [assoc terminal_name terminalForm]"
              set foundP 1
              showCommandMonitorTerminalBalloonsDoit \
                  "current" $nodeClassType outputs terminalForm nodePropList \
                  $pirNodeIndex $buttonPath $caller
              return
            }
          }
        }
      }
    }
  }
  if {! $foundP} {
    puts stderr "displayUserTestValueBalloon: proposition $propNameAndValue not handled"
  }
}









