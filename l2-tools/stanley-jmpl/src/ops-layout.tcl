# $Id: ops-layout.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## graphical layout items for operational mode


## pop-up window to show node defcomponent mode (nodeState)
## show current value of all propositions
## 11oct95 wmt: new
## 04mar96 wmt: redone to pop-up window, rather than replacing label with state
## 06apr96 wmt: add special processing for component acs-mode-a
## 04jun96 wmt: do nothing if "parent-link" defmodule
## 25jul96 wmt: revise handing to reflect R2S3 MIR Problem Statement
## 27aug96 wmt: ACS-MODE-A => ACS-A
## 20nov96 wmt: change proc name from nodeShowState to nodeShowModeAndProps
## 03dec96 wmt: add g_NM_acsModeRCSDVStatus g_NM_acsModeSRUACQStatus
##              & g_NM_acsModeIDLEStatus
proc nodeShowModeAndProps { labelWidget pirNodeIndex nodeClassType \
                                { updateP 0 } } {
  global pirNode g_NM_statePropsRootWindow propNameValueArray
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_l2toolsCurrentTime g_NM_selectedTestModule
  global g_NM_selectedTestScopeRoot

  # to delete all windows
  # foreach wind [winfo children $g_NM_statePropsRootWindow] {
  #   destroy $wind
  # }
  # disable Mouse-Left click & motion for bindtags $window.top.table => class Table
  bind Table <Button-1> {}
  bind Table <B1-Motion> {}

  set reportNotFoundP 0; set oldvalMustExistP 0
  arepl stateViewerProc "nodeShowModeAndProps" pirNode($pirNodeIndex) \
      $reportNotFoundP $oldvalMustExistP
  set canvasRoot {}; set trimP 1
  set pirNodeAList $pirNode($pirNodeIndex)
  set canvasRootId [getCanvasRootId $labelWidget canvasRoot]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set componentMode [assoc nodeState pirNode($pirNodeIndex)]
  set propsAList [assoc nodePropList pirNodeAList]
  set acsRcsOutTerminalName ""
  set stateBgColor [assoc nodeStateBgColor pirNode($pirNodeIndex)]
  set window $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
  # for separate window -- but is has the same info 
  # append window _$canvasRootId
  if {[winfo exists $window]} {
    # save y scroll position for redrawn table
    if {[winfo exists $window.top.left.table]} {
      # timeline or waveform viewer
      set yScrollFraction [lindex [$window.top.left.table yview] 0]
    } else {
      # current viewer
      set yScrollFraction [lindex [$window.top.table yview] 0]
    }
    set xPos [expr {[winfo rootx $window] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $window] - $g_NM_yWindowMgrOffset}]
  } else {
    set yScrollFraction 0.0; set xOffset 50
    set xPos -1; set yPos -1
    # set xPos [expr [winfo rootx $labelWidget] + $xOffset - $g_NM_xWindowMgrOffset]
    # set yPos [expr [winfo rooty $labelWidget] - $g_NM_yWindowMgrOffset]
  }

  set parentNodeGroupList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
  # puts stderr "level [llength $parentNodeGroupList]"
  if {[llength $parentNodeGroupList] > 2} {
    set instanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  } else {
    set instanceName [getDisplayLabel pirNodeAList labelP $trimP]
  }
  if {! $updateP} {
    catch {destroy $window};      # only one instance can be created
    toplevel $window -class Dialog
    if { [winfo viewable [winfo toplevel [winfo parent $window]]] } {
      wm transient $window [winfo toplevel [winfo parent $window]]
    }    
    wm geometry $window +${xPos}+${yPos}
    wm title $window "State Viewer - time: $g_NM_l2toolsCurrentTime"

    frame $window.header -bd 2 -bg $stateBgColor -relief flat
    set instanceText "Instance: [getExternalNodeName $instanceName]" 
    if {$g_NM_selectedTestScopeRoot == "component"} {
      append instanceText ".$g_NM_selectedTestModule"
    }
    label $window.header.label -anchor w -bg $stateBgColor \
        -text $instanceText -font [preferred propStateLabelFont]
    if {[string match $nodeClassType component]} {
      label $window.header.mode -anchor w -bg $stateBgColor \
          -text "Mode: $componentMode" -font [preferred propStateLabelFont]
      grid $window.header.label - -sticky ew
      grid $window.header.mode  - -sticky ew
    } else {
      grid $window.header.label  - -sticky ew
    }
    grid $window.header - -sticky ew
  } else {
    wm title $window "State Viewer - time: $g_NM_l2toolsCurrentTime"
    $window.header configure -bg $stateBgColor 
    $window.header.label configure -bg $stateBgColor
    if {[string match $nodeClassType component]} {
      $window.header.mode configure -bg $stateBgColor -text "Mode: $componentMode"
    }
  }

  # puts stderr "pirNodeIndex $pirNodeIndex propsAList $propsAList"
  # StanleyDialogEntryFont is a fixed width font => number of chars
  #     determines the max number of pixels
  # propStateLabelFont is a variable width font => which chars are in
  #     the string, as well as number of them, determines max number of pixels
  set propValueList {}; set maxLabelWidthPixels 0
  set maxValueString ""; set maxValueWidth 0; set rowNum 0
  for {set i 1} {$i < [llength $propsAList]} {incr i 2} {
    set labelValueList [lindex $propsAList $i] 
    set propLabel [forceColorStateLabel [assoc label labelValueList]]
    # trim left the instance name of each fully qualified attribute
    if {[regexp "\\\." $propLabel]} {
      # not a label -- a qualified name, remove instance name
      regsub [getMplRegExpression "[getExternalNodeName $instanceName]."] \
          $propLabel "" tmp
      set propLabel $tmp
    }
    set lenPixels [expr {[font measure [preferred propStateLabelFont] \
                              $propLabel] + 4}]
    if {$lenPixels > $maxLabelWidthPixels} {
      set maxLabelWidthPixels $lenPixels
    }
    # set propValue "[assoc value labelValueList]$rowNum"
    set propValue [assoc value labelValueList]
    set len [string length $propValue] 
    if {$len > $maxValueWidth} {
      set maxValueWidth $len
      set maxValueString $propValue
    }
    if {(! [string match $propLabel "_mode_"]) && \
            (! [string match $propLabel "no_label"])} {
      lappend propValueList [list $propLabel $propValue]
    }
    incr rowNum 
  }
  set maxValueWidthPixels [expr {[font measure [preferred StanleyDialogEntryFont] \
                                      "${maxValueString}"] + 4}]
  set maxLabelHeightPixels [font metrics [preferred propStateLabelFont] -linespace]
  set maxLabelValuePixels [font metrics [preferred StanleyDialogEntryFont] -linespace]
  set rowHeightPixels $maxLabelHeightPixels
  if {$maxLabelValuePixels > $rowHeightPixels} {
    set rowHeightPixels $maxLabelValuePixels
  }

  global propNameValueArray$pirNodeIndex 
  if {! $updateP} {
    catch { unset propNameValueArray$pirNodeIndex }
  }
  # table title row
  set [subst propNameValueArray$pirNodeIndex](-1,0) "Attribute"
  set [subst propNameValueArray$pirNodeIndex](-1,2) "Value"
  # maxRows is an odd number because of title row, and data rows are pairs
  # of data & divider
  set rowNum 0; set maxRows 11
  foreach linePair [lsort -command labelSort $propValueList] {
    # puts stderr "nodeShowModeAndProps: linePair $linePair"
    set [subst propNameValueArray$pirNodeIndex](${rowNum},0) [lindex $linePair 0]
    # vertical divider
    set [subst propNameValueArray$pirNodeIndex](${rowNum},1) ""
    set [subst propNameValueArray$pirNodeIndex](${rowNum},2) [lindex $linePair 1]
    # horizontal divider
    set [subst propNameValueArray$pirNodeIndex]([expr {$rowNum + 1}],0) ""
    set [subst propNameValueArray$pirNodeIndex]([expr {$rowNum + 1}],1) ""
    set [subst propNameValueArray$pirNodeIndex]([expr {$rowNum + 1}],2) ""
    incr rowNum 2
  }

  if {! $updateP} {
    # show propositions
    set bgcolor [preferred StanleyMenuDialogBackgroundColor]
    frame $window.top -bd 2 -bg $bgcolor -relief flat
    scrollbar $window.top.sy -orient vertical -relief sunken \
        -command [list scrollYViewPropState [list $window.top.table]]
    # to modify bindings on table
    # bindtags .stateprops.mod-test-a.top.table ==> 
    #     .stateprops.mod-test-a.top.table Table .stateprops.mod-test-a all
    # bind Table => all bound events
    # bind Table <Button-1> shows code for binding
    table $window.top.table -rows [expr {$rowNum + 1}] -cols 3 \
        -width 3 -height $maxRows -yscrollcommand "$window.top.sy set" \
        -colstretchmode last -titlerows 1 -roworigin -1 \
        -variable propNameValueArray$pirNodeIndex -anchor w -state disabled \
        -bg $bgcolor -coltagcommand colNumTagProc -rowtagcommand oddRowProc \
        -font [preferred StanleyDialogEntryFont]
    # not really nededed since there is only one table
    $window.top.table height -1 -$rowHeightPixels
    for {set i 0} {$i <= $rowNum} {incr i 2} {
      $window.top.table height $i -$rowHeightPixels
    }
    # must specify font or option default font is used instead
    $window.top.table tag configure col0Tag -bg [preferred propStateLabelBgColor] \
        -font [preferred propStateLabelFont] 
    # set black horizontal dividing line between entries
    for {set i 1} {$i <= $rowNum} {incr i 2} {
      $window.top.table height $i -4
    }
    $window.top.table tag config oddRowTag -bg black
    # color column 1 black
    $window.top.table tag configure col1Tag -bg black
    # color column 2 white - (must specify font or option default font is used instead)
    $window.top.table tag configure col2Tag -bg [preferred StanleyDialogEntryBackgroundColor] \
        -font [preferred StanleyDialogEntryFont] 
    # center column titles - (must specify font or option default font is used instead) 
    $window.top.table tag configure titleRowTag -anchor c \
        -font [preferred StanleyDialogEntryFont] -background $bgcolor -foreground black 
    
    if {$rowNum <= $maxRows} {
      grid $window.top.table -sticky news
    } else {
      grid $window.top.table $window.top.sy -sticky news
      # restore y scroll position
      $window.top.table yview moveto $yScrollFraction
    }
    grid $window.top - -sticky news
  }

  # allow user to expand table with window manager in y direction
  grid rowconfig $window.top 0 -weight 1
  grid rowconfig $window 1 -weight 1

  # set widths in update mode, as well as create
  $window.top.table width 0 -$maxLabelWidthPixels 1 -3 2 -$maxValueWidthPixels

  if {! $updateP} {
    frame $window.buttons -bg $bgcolor -bd 2 -relief flat
#     frame $window.buttons.left -bg $bgcolor -bd 2 -relief flat
#     button $window.buttons.left.current -text "CURRENT" -relief raised \
#         -command "nodeShowModeAndProps $labelWidget $pirNodeIndex $nodeClassType" \
#         -state disabled
#     $window.buttons.left.current configure -takefocus 0
#     button $window.buttons.left.timeline -text "TIMELINE" -relief raised \
#         -command "nodeShowTimelineProps $labelWidget $pirNodeIndex $nodeClassType" 
#     $window.buttons.left.timeline configure -takefocus 0

    frame $window.buttons.right -bg $bgcolor -bd 2 -relief flat
#     button $window.buttons.right.waveform -text "WAVEFORM" -relief raised \
#         -command "nodeShowWaveformProps $labelWidget $pirNodeIndex $nodeClassType" 
#     $window.buttons.right.waveform configure -takefocus 0
    button $window.buttons.right.dismiss -text "DISMISS" -relief raised \
        -command "destroy $window"
    $window.buttons.right.dismiss configure -takefocus 0
#     grid $window.buttons.left.current -row 3 -col 0 
#     grid $window.buttons.left.timeline -row 4 -col 0 

#     grid $window.buttons.right.waveform -row 3 -col 1 -padx 10
    grid $window.buttons.right.dismiss -row 4 -col 1 -padx 10 -ipadx 12
#     grid $window.buttons.left $window.buttons.right - -sticky ew
    grid $window.buttons.right - -sticky ew
    grid $window.buttons - -sticky ew

    keepDialogOnScreen $window $xPos $yPos 
  }
  update
}


## 04nov98 wmt: new
proc nodeShowWaveformProps { labelWidget pirNodeIndex nodeClassType \
                                { updateP 0 } } {
  global pirNode g_NM_statePropsRootWindow g_NM_instanceToNode
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_terminalTypeValuesArray g_NM_packetTimeTagsList 
  global g_NM_absoluteCanvasWidth g_NM_absoluteCanvasHeight
  global g_NM_propValuesCount g_NM_propValuesArray g_NM_propsWarnMsgsP
  global g_NM_defaultDisplayState 


  # to delete all windows
  # foreach wind [winfo children $g_NM_statePropsRootWindow] {
  #   destroy $wind
  # }
  set reportNotFoundP 0; set oldvalMustExistP 0
  arepl stateViewerProc "nodeShowWaveformProps" pirNode($pirNodeIndex) \
      $reportNotFoundP $oldvalMustExistP
  set canvasRoot {}; set trimP 1
  set pirNodeAList $pirNode($pirNodeIndex)
  set canvasRootId [getCanvasRootId $labelWidget canvasRoot]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set componentMode [assoc nodeState pirNode($pirNodeIndex)]
  set propsAList [assoc nodePropList pirNodeAList]
  set acsRcsOutTerminalName ""
  set stateBgColor [assoc nodeStateBgColor pirNode($pirNodeIndex)]
  set window $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
  # for separate window -- but is has the same info 
  # append window _$canvasRootId
  if {[winfo exists $window]} {
    # save y scroll position for redrawn table
    if {[winfo exists $window.top.left.table]} {
      # timeline or waveform viewer
      set yScrollFraction [lindex [$window.top.left.table yview] 0]
    } else {
      # current viewer
      set yScrollFraction [lindex [$window.top.table yview] 0]
    }
    set xPos [expr {[winfo rootx $window] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $window] - $g_NM_yWindowMgrOffset}]
  } else {
    set yScrollFraction 0.0
    set xPos -1; set yPos -1
    # set xPos [expr [winfo rootx $labelWidget] + $xOffset - $g_NM_xWindowMgrOffset]
    # set yPos [expr [winfo rooty $labelWidget] - $g_NM_yWindowMgrOffset]
  }
  if {! $updateP} {
    catch {destroy $window};      # only one instance can be created
    toplevel $window -class Dialog 
    wm geometry $window +${xPos}+${yPos}
    wm title $window "State Viewer - waveform"
    wm transient $window [winfo toplevel [winfo parent $window]]

    set parentNodeGroupList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
    # puts stderr "level [llength $parentNodeGroupList]"
    if {[llength $parentNodeGroupList] > 2} {
      set instanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    } else {
      set instanceName [getDisplayLabel pirNodeAList labelP $trimP]
    }
    frame $window.header -bd 2 -bg $stateBgColor -relief flat
    label $window.header.label -anchor w -bg $stateBgColor \
        -text "Instance: $instanceName" \
        -font [preferred propStateLabelFont]
    if {[string match $nodeClassType component]} {
      label $window.header.mode -anchor w -bg $stateBgColor \
          -text "Mode: $componentMode" -font [preferred propStateLabelFont]
      grid $window.header.label 
      grid $window.header.mode 
    } else {
      grid $window.header.label 
    }
    grid $window.header - -sticky ew
  } else {
    $window.header configure -bg $stateBgColor 
    $window.header.label configure -bg $stateBgColor
    if {[string match $nodeClassType component]} {
      $window.header.mode configure -bg $stateBgColor -text "Mode: $componentMode"
    }
  }

  # puts stderr "pirNodeIndex $pirNodeIndex propsAList $propsAList"
  # determine header alignment spacing
  # StanleyDialogEntryFont is a fixed width font => number of chars
  #     determines the max number of pixels
  # propStateLabelFont is a variable width font => which chars are in
  #     the string, as well as number of them, determines max number of pixels
  set maxLabelWidthPixels 0
  for {set i 1} {$i < [llength $propsAList]} {incr i 2} {
    set propName [lindex $propsAList [expr {$i - 1}]]
    set labelValueList [lindex $propsAList $i] 
    set propLabel [forceColorStateLabel [assoc label labelValueList]]
    if {(! [string match $propLabel "_mode_"]) && \
            (! [string match $propLabel "no_label"])} {
      set propNamePirIndex [assoc-array $propName g_NM_instanceToNode]
      set propType [getTerminalInstanceType $propNamePirIndex terminalForm]
      # puts stderr "propName $propName propType $propType"
      set typeValuesList [assoc-array $propType g_NM_terminalTypeValuesArray]
      if {[lsearch -exact $typeValuesList "unknown"] == -1} {
        lappend typeValuesList "unknown"
      }
      if {[lsearch -exact $typeValuesList $g_NM_defaultDisplayState] == -1} {
        lappend typeValuesList $g_NM_defaultDisplayState 
      }
      foreach typeValue $typeValuesList {
        set lenPixels [expr {[font measure [preferred propStateLabelFont] \
                                  $typeValue] + 4}]
        if {$lenPixels > $maxLabelWidthPixels} {
          set maxLabelWidthPixels $lenPixels 
        }
      }
      set lenPixels [expr {[font measure [preferred propStateLabelFont] \
                                $propLabel] + 4}] 
      if {$lenPixels > $maxLabelWidthPixels} {
        set maxLabelWidthPixels $lenPixels 
      }
    }
  }

  # sort propositions by labels
  set propNameLabelPairList {}
  foreach propName [alist-keys propsAList] {
    set propList [assoc $propName propsAList]
    lappend propNameLabelPairList [list [assoc label propList] $propName]
  }
  set sortedPropNameLabelPairs [lsort -command labelSort $propNameLabelPairList]

  set propRowLabelList {}; set propRowNameLabelList {}
  set propDataList {}; set numRows 0
  foreach propNameLabel $sortedPropNameLabelPairs {
    set propName [lindex $propNameLabel 1]
    set labelValueList [assoc $propName propsAList]
    set propLabel [assoc label labelValueList]
    set propLabel [forceColorStateLabel $propLabel]
    if {(! [string match $propLabel "_mode_"]) && \
            (! [string match $propLabel "no_label"])} {
      set propNamePirIndex [assoc-array $propName g_NM_instanceToNode]
      set propType [getTerminalInstanceType $propNamePirIndex terminalForm]
      set typeValuesList [assoc-array $propType g_NM_terminalTypeValuesArray]
      if {[string match $propType proposition]} {
        lappend typeValuesList "true" "false"
      }
      if {[lsearch -exact $typeValuesList "unknown"] == -1} {
        lappend typeValuesList "unknown"
      }
      if {[lsearch -exact $typeValuesList $g_NM_defaultDisplayState] == -1} {
        lappend typeValuesList $g_NM_defaultDisplayState 
      }
      set tokenList [list $propLabel]
      set tokenList [concat $tokenList $typeValuesList]
      lappend propRowLabelList $numRows 
      # proplabels are not required to be unique
      lappend propRowNameLabelList [list $numRows $propName $propLabel]
      foreach token $tokenList {
        lappend propDataList $token
        incr numRows
      }
    }
  }

  global propNameValueArrayH$pirNodeIndex 
  global propNameValueArrayV$pirNodeIndex 
  if {! $updateP} {
    catch { unset propNameValueArrayH$pirNodeIndex }
    catch { unset propNameValueArrayV$pirNodeIndex }
  }
  # table title row
  set [subst propNameValueArrayH$pirNodeIndex](-1,0) "Attribute"
  # header row is part of maxRows
  set rowNum 0; set maxRows 12
  set barWidth [expr {[font metrics [preferred propStateLabelFont] -linespace] \
                          * 2}]
  set maxCols 12
  foreach token $propDataList {
    set [subst propNameValueArrayH$pirNodeIndex](${rowNum},0) $token
    # vertical divider
    set [subst propNameValueArrayH$pirNodeIndex](${rowNum},1) ""
    incr rowNum 
  }

  # waveform data
#   set propValueListINPUT { on off noCommand off on noCommand unknown \
#                              on off noCommand off on noCommand unknown } ; # TEST
  #   set colNum 14               ; # TEST
  # g_NM_propValuesArray : keys are proposition names
  set colNum $g_NM_propValuesCount 
  
  # fill displayed columns even if no data is present
  if {$colNum < $maxCols} {
    set colNum $maxCols
  }
  # table title row
  for {set col 0} {$col <= $colNum} {incr col} {
    # set [subst propNameValueArrayV$pirNodeIndex](-1,$col) $col
    set [subst propNameValueArrayV$pirNodeIndex](-1,$col) \
        [lindex [lindex $g_NM_packetTimeTagsList $col] 0]
  }
  if {! $updateP} {
    # show propositions
    set bgcolor [preferred StanleyMenuDialogBackgroundColor]
    frame $window.top -bd 2 -bg $bgcolor -relief flat
    frame $window.top.left -bg $bgcolor -relief flat
    scrollbar $window.top.sy -orient vertical -relief sunken \
        -command [list scrollYViewPropState [list $window.top.left.table \
                                                 $window.top.right.table]]
    label $window.top.left.filler -bg $bgcolor -relief flat 
    # to modify bindings on table
    # bindtags .stateprops.mod-test-a.top.left.table ==> 
    #     .stateprops.mod-test-a.top.left.table Table .stateprops.mod-test-a all
    # bind Table => all bound events
    # bind Table <Button-1> shows code for binding
    table $window.top.left.table -rows [expr {$rowNum + 1}] -cols 2 \
        -bg [preferred propStateLabelBgColor] \
        -width 2 -height $maxRows -yscrollcommand "$window.top.sy set" \
        -variable propNameValueArrayH$pirNodeIndex -anchor w -state disabled \
        -rowtagcommand rowNumTagProc \
        -titlerows 1 -roworigin -1 -coltagcommand colNumTagProc \
        -highlightthickness 0 -font [preferred propStateLabelFont]
    $window.top.left.table width 0 -$maxLabelWidthPixels 1 -4
    # color column 1 black
    # this does not work since row tags take precedence over column tags, use cell tags
    # $window.top.left.table tag configure col1Tag -bg black
    $window.top.left.table tag config vertDivider -bg black
    for {set row 0} {$row <= $rowNum} {incr row} {
      $window.top.left.table tag cell vertDivider ${row},1
    }
    for {set row -1} {$row <= [expr {$rowNum + 1}]} {incr row} {
      if {$row < 0} {
        # center column title - (must specify font or option default font is used instead)
        $window.top.left.table tag configure row${row}Tag -anchor c \
            -font [preferred StanleyDialogEntryFont]
      } elseif {[lsearch -exact $propRowLabelList $row] >= 0} {
        ; # do nothing
      } else {
        # align all type values to the right & lighter color
        $window.top.left.table tag config row${row}Tag -anchor e \
            -font [preferred propStateLabelFont] -bg $bgcolor 
      }
    }

    frame $window.top.right -bg $bgcolor -relief flat
    scrollbar $window.top.right.sx -orient horizontal \
        -command "$window.top.right.table xview" -relief sunken
    table $window.top.right.table -rows [expr {$rowNum + 1}] -cols $colNum \
        -width $maxCols -height $maxRows -yscrollcommand "$window.top.sy set" \
        -xscrollcommand "$window.top.right.sx set" \
        -anchor w -state disabled -colwidth -$barWidth \
        -rowtagcommand rowNumTagProc \
        -titlerows 1 -roworigin -1 -variable propNameValueArrayV$pirNodeIndex \
        -bg [preferred StanleyDialogEntryBackgroundColor] \
        -highlightthickness 0 -colstretchmode last \
        -font [preferred propStateLabelFont]
    for {set row -1} {$row <= [expr {$rowNum + 1}]} {incr row} {
      if {$row < 0} {
        # center column title - (must specify font or option default font is used instead)
        $window.top.right.table tag configure row${row}Tag -anchor c \
            -font [preferred StanleyDialogEntryFont]
      } elseif {[lsearch -exact $propRowLabelList $row] >= 0} {
        # use darker bg color for all label rows
        $window.top.right.table tag config row${row}Tag \
            -bg [preferred propStateLabelBgColor] 
      }
    }
    # establish value colors
    # font must be specified, since option font (StanleyDefaultFont) will
    # be used otherwise
    $window.top.right.table tag config histColor -bg [preferred StanleyPropsWaveformColor] \
        -font [preferred propStateLabelFont]
  }   

  if {$updateP} {
    # update table with latest column
    $window.top.right.table configure -cols $colNum 
  }
  # scroll values to the right to show latest values
  showLatestPropValues $window.top.right.table $maxCols

  # apply to data
  foreach triple $propRowNameLabelList {
    set headerRow [lindex $triple 0]
    set propName [lindex $triple 1]
    set propLabel [lindex $triple 2]
    # puts stderr "propLabel $propLabel propName $propName "
    set propNamePirIndex [assoc-array $propName g_NM_instanceToNode]
    set propType [getTerminalInstanceType $propNamePirIndex terminalForm]
    set typeValuesList [assoc-array $propType g_NM_terminalTypeValuesArray]
    if {[string match $propType proposition]} {
      lappend typeValuesList "true" "false"
    }
    if {[lsearch -exact $typeValuesList "unknown"] == -1} {
      lappend typeValuesList "unknown"
    }
    if {[lsearch -exact $typeValuesList $g_NM_defaultDisplayState] == -1} {
      lappend typeValuesList $g_NM_defaultDisplayState 
    }
    # puts stderr "propType $propType typeValuesList $typeValuesList "
    set numValues [llength $typeValuesList]
    set rowMin [expr {$headerRow + $numValues}]
    set rowMax [expr {$headerRow + 1}]
    set col 0
    # set str "nodeShowWaveformProps: propName $propName values"
    # puts stderr "$str [assoc-array $propName g_NM_propValuesArray]" 
    foreach dataValueList [assoc-array $propName g_NM_propValuesArray] {
      # this may be a multiple value
      foreach dataValue $dataValueList {
        # puts stderr "dataValue $dataValue rowMin $rowMin rowMax $rowMax col $col"
        set dataRow [lsearch -exact $typeValuesList $dataValue]
        if {$dataRow != -1} {
          # for {set row $rowMin} { $row > [expr $headerRow + $dataRow]} {incr row -1} {
          #   # puts stderr "row $row col $col "
          #   $window.top.right.table tag cell histColor ${row},$col
          # }
          $window.top.right.table tag cell histColor \
              [expr {$headerRow + $dataRow + 1}],$col
        } elseif {$g_NM_propsWarnMsgsP && \
                      (! [string match $dataValue $g_NM_defaultDisplayState])} {
          set str "nodeShowWaveformProps: typeValue not found for $propLabel for"
          puts stderr "$str $dataValue in ``$typeValuesList''"
        }
      }
      incr col
    }
  }
  if {! $updateP} {
    # puts stderr "rowNum $rowNum colNum $colNum"
    grid $window.top.left.table -sticky ns
    grid $window.top.left.filler
    grid $window.top.left -row 1 -col 0 -sticky ns
    grid $window.top.right.table -sticky news
    # always create x scroll so that auto x expansion does not have to worry about it
    grid $window.top.right.sx -sticky ew
    grid $window.top.right -row 1 -col 1 -sticky news 

    if {$rowNum > $maxRows} {
      grid $window.top.sy -row 1 -col 2 -sticky ns
      # restore y scroll position
      $window.top.left.table yview moveto $yScrollFraction
      $window.top.right.table yview moveto $yScrollFraction
    }
    grid $window.top - -sticky news

    # allow user to expand table with window manager in x direction
    grid columnconfig $window.top.right 0 -weight 1
    grid columnconfig $window.top 1 -weight 1
    grid columnconfig $window 0 -weight 1
    # allow user to expand table with window manager in y direction
    grid rowconfig $window.top.left 0 -weight 1
    grid rowconfig $window.top.right 0 -weight 1
    grid rowconfig $window.top 1 -weight 1
    grid rowconfig $window 1 -weight 1

    frame $window.buttons -bg $bgcolor -bd 2 -relief flat
    frame $window.buttons.top -bg $bgcolor -bd 2 -relief flat
    button $window.buttons.top.current -text "CURRENT" -relief raised \
        -command "nodeShowModeAndProps $labelWidget $pirNodeIndex $nodeClassType" 
    $window.buttons.top.current configure -takefocus 0
    button $window.buttons.top.waveform -text "WAVEFORM" -relief raised \
        -command "nodeShowWaveformProps $labelWidget $pirNodeIndex $nodeClassType" \
        -state disabled
    $window.buttons.top.waveform configure -takefocus 0

    frame $window.buttons.bottom -bg $bgcolor -bd 2 -relief flat
    button $window.buttons.bottom.timeline -text "TIMELINE" -relief raised \
        -command "nodeShowTimelineProps $labelWidget $pirNodeIndex $nodeClassType" 
    $window.buttons.bottom.timeline configure -takefocus 0
    button $window.buttons.bottom.dismiss -text "DISMISS" -relief raised \
        -command "destroy $window"
    $window.buttons.bottom.dismiss configure -takefocus 0

    grid $window.buttons.top.current -row 2 -col 0  -padx 10
    grid $window.buttons.bottom.timeline -row 2 -col 1 -padx 10
    grid $window.buttons.top.waveform -row 2 -col 2 -padx 10
    grid $window.buttons.bottom.dismiss -row 2 -col 3 -padx 10 
    grid $window.buttons.top $window.buttons.bottom - -sticky ew
    grid $window.buttons - -sticky ew

    keepDialogOnScreen $window $xPos $yPos
  }
  update
}


## assign tag to odd numbered rows
## 09nov98 wmt: new
proc oddRowProc { row } {

  if {$row < 0} {
    return titleRowTag
  } elseif {($row > 0) && ($row % 2)} {
    return oddRowTag
  }
}


## tag all columns with column number
## 10nov98 wmt:new
proc colNumTagProc { col } {

  return "col${col}Tag"
}


## tag all rows with row number
## 10nov98 wmt:new
proc rowNumTagProc { row } {

  return "row${row}Tag"
}


## discard leading (, {, & . characters for sort
## 05nov98 wmt: new
proc labelSort { a b } {

  set aLabelMaybe [string trimleft [lindex $a 0] "\{\(."]
  set bLabelMaybe [string trimleft [lindex $b 0] "\{\(."] 
  # puts stderr "labelSort $aLabelMaybe $bLabelMaybe"
  return [string compare $aLabelMaybe $bLabelMaybe]
}


## force colorState/displayState attribute to be a label
## 22jan99 wmt: new
proc forceColorStateLabel { propLabel } {

  if {[regexp "colorState" $propLabel] || \
          [regexp "displayState" $propLabel]} {
    # force label
    set propLabel "displayState"
  }
  return $propLabel 
}

## display balloon help with packet generation time for column under mouse
## 24jan99 wmt: new
proc displayTableCellBalloon { widget x y } {
  global g_NM_currentTableWidgetCol g_NM_groundRefTime 
  global g_NM_packetTimeTagsList 
  global g_NM_vmplTestModeP g_NM_instanceToNode pirNode
  global g_NM_propValuesArray 

  # puts stderr "displayCellBalloon: widget $widget"
  if {[regexp "\\\.right\\\." $widget]} {
    # select only timeline and waveform windows
    set colNum [$widget index @$x,$y col]
    set rowNum [$widget index @$x,$y row]
    if {$rowNum == -1} {
      if {$colNum != $g_NM_currentTableWidgetCol} {
        # puts stderr "displayCellBalloon: colNum $colNum rowNum $rowNum"
        destroyTableCellBalloon 
        set g_NM_currentTableWidgetCol $colNum
        set idTimePair [lindex $g_NM_packetTimeTagsList $colNum]
        if {! [string match $idTimePair ""]} {
          set text "time [lindex $idTimePair 1]"
        } else {
          set text ""
        }
        # adjust for x scrolling
        # first get nodeInstanceName from widget
        # .stateprops.test_led1.top.right.table
        set uscoreInstanceName [lindex [split $widget "."] 2]
        regsub -all "_" $uscoreInstanceName "." nodeInstanceName
        set pirNodeIndex [assoc-array $nodeInstanceName g_NM_instanceToNode] 
        set propsAList [assoc nodePropList pirNode($pirNodeIndex)]
        set propName ""
        for {set i 0} {$i < [llength $propsAList]} {incr i 2} {
          set propName [lindex $propsAList $i]
          if {! [regexp "displayState" $propName]} {
            # display state may not have continuous values
            break
          }
        }
        if {$propName == ""} { return }
        set maxCols [llength [assoc-array $propName g_NM_propValuesArray]]
        set widgetWidth [$widget width 0]
        set xScrollExtent [expr {$maxCols * - ($widgetWidth - 2)}]
        # puts stderr "\ndisplayTableCellBalloon: maxCols $maxCols xScrollExtent $xScrollExtent"
        # set widgetHeight [$widget height 0]
        # does not give consistent values -- use next line instead
        set widgetHeight [lindex [$widget configure -height] 4]
        # allow for scrolling
        set xviewPair [$widget xview]
        set xOffset [expr {$colNum *  - ($widgetWidth - 2)}]
        # puts stderr "xview [$widget xview] old $xOffset widget $widget widgetWidth $widgetWidth"
        set xOffset [expr {$xOffset - round($xScrollExtent * [lindex $xviewPair 0])}] 
        set yOffset [expr {- ($widgetHeight + 6)}]
        # puts stderr "displayCellBalloon: widget $widget xOffset $xOffset yOffset $yOffset"
        set balloonType stateViewer
        permanentBalloonHelp "table-$colNum" $widget $text $balloonType \
            $xOffset $yOffset 
      }
    } else {
      destroyTableCellBalloon 
    }
  }
}


## destroy the tkTable header row balloon
## 24jan99 wmt: new
proc destroyTableCellBalloon { } {
  global g_NM_currentTableWidgetCol g_NM_permBalloonRootWindow 

  deleteAllPopUpWindows $g_NM_permBalloonRootWindow
  set g_NM_currentTableWidgetCol -99
}

  
## 05Nov98 wmt: new
proc nodeShowTimelineProps { labelWidget pirNodeIndex nodeClassType \
                                 { updateP 0 } } {
  global pirNode g_NM_statePropsRootWindow propNameValueArray
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_propValuesColorMap g_NM_instanceToNode
  global g_NM_terminalTypeValuesArray g_NM_propsWarnMsgsP
  global g_NM_propValuesCount g_NM_propValuesArray
  global g_NM_packetTimeTagsList 

  # to delete all windows
  # foreach wind [winfo children $g_NM_statePropsRootWindow] {
  #   destroy $wind
  # }
  set reportNotFoundP 0; set oldvalMustExistP 0
  arepl stateViewerProc "nodeShowTimelineProps" pirNode($pirNodeIndex) \
      $reportNotFoundP $oldvalMustExistP
  set canvasRoot {}; set trimP 1
  set pirNodeAList $pirNode($pirNodeIndex)
  set canvasRootId [getCanvasRootId $labelWidget canvasRoot]
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set componentMode [assoc nodeState pirNode($pirNodeIndex)]
  set propsAList [assoc nodePropList pirNodeAList]
  set acsRcsOutTerminalName ""
  set stateBgColor [assoc nodeStateBgColor pirNode($pirNodeIndex)]
  set window $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
  # for separate window -- but is has the same info 
  # append window _$canvasRootId
  if {[winfo exists $window]} {
    # save y scroll position for redrawn table
    if {[winfo exists $window.top.left.table]} {
      # timeline or waveform viewer
      set yScrollFraction [lindex [$window.top.left.table yview] 0]
    } else {
      # current viewer
      set yScrollFraction [lindex [$window.top.table yview] 0]
    }
    set xPos [expr {[winfo rootx $window] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $window] - $g_NM_yWindowMgrOffset}]
  } else {
    set yScrollFraction 0.0
    set xPos -1; set yPos -1
    # set xPos [expr [winfo rootx $labelWidget] + $xOffset - $g_NM_xWindowMgrOffset]
    # set yPos [expr [winfo rooty $labelWidget] - $g_NM_yWindowMgrOffset]
  }
  if {! $updateP} {
    catch {destroy $window};      # only one instance can be created
    toplevel $window -class Dialog 
    wm geometry $window +${xPos}+${yPos}
    wm title $window "State Viewer - timeline"
    wm transient $window [winfo toplevel [winfo parent $window]]

    set parentNodeGroupList [getCanvasRootInfo g_NM_parentNodeGroupList $canvasRootId]
    # puts stderr "level [llength $parentNodeGroupList]"
    if {[llength $parentNodeGroupList] > 2} {
      set instanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
    } else {
      set instanceName [getDisplayLabel pirNodeAList labelP $trimP]
    }
    frame $window.header -bd 2 -bg $stateBgColor -relief flat
    label $window.header.label -anchor w -bg $stateBgColor \
        -text "Instance: $instanceName" \
        -font [preferred propStateLabelFont]
    if {[string match $nodeClassType component]} {
      label $window.header.mode -anchor w -bg $stateBgColor \
          -text "Mode: $componentMode" -font [preferred propStateLabelFont]
      grid $window.header.label 
      grid $window.header.mode 
    } else {
      grid $window.header.label 
    }
    grid $window.header - -sticky ew
  } else {
    $window.header configure -bg $stateBgColor 
    $window.header.label configure -bg $stateBgColor
    if {[string match $nodeClassType component]} {
      $window.header.mode configure -bg $stateBgColor -text "Mode: $componentMode"
    }
  }
  # puts stderr "pirNodeIndex $pirNodeIndex propsAList $propsAList"
  # StanleyDialogEntryFont is a fixed width font => number of chars
  #     determines the max number of pixels
  # propStateLabelFont is a variable width font => which chars are in
  #     the string, as well as number of them, determines max number of pixels
  set propDataList {}; set maxLabelWidthPixels 0
  set maxValueString(1) ""; set maxValueWidth(1) 0; set rowNum 0
  # set propValueListINPUT { on off no-command off on no-command unknown } ; # TEST
  # set propValueListINPUT { noData unknown } ; # TEST
  for {set i 1} {$i < [llength $propsAList]} {incr i 2} {
    set propName [lindex $propsAList [expr {$i - 1}]]
    set labelValueList [lindex $propsAList $i] 
    set propLabel [forceColorStateLabel [assoc label labelValueList]]
    if {(! [string match $propLabel "_mode_"]) && \
            (! [string match $propLabel "no_label"])} {
      set colNum 0
      set lenPixels [expr {[font measure [preferred propStateLabelFont] \
                                $propLabel] + 4}]
      if {$lenPixels > $maxLabelWidthPixels} {
        set maxLabelWidthPixels $lenPixels
      }
      # set propValue "[assoc value labelValueList]$rowNum"
      set propValueList {}
      # rotate dummy input values
      # set first [lindex $propValueListINPUT 0] ; # TEST
      # set propValueListINPUT [lrange $propValueListINPUT 1 end]  ; # TEST
      # lappend propValueListINPUT $first ; # TEST
      # set str "nodeShowTimelineProps: propName $propName values"
      # puts stderr "$str [assoc-array $propName g_NM_propValuesArray]"
      foreach propValue [assoc-array $propName g_NM_propValuesArray] {
        # append propValue "${rowNum},$colNum" ; # TEST
        set len [string length $propValue]
        lappend propValueList $propValue
        if {! [info exists maxValueWidth($colNum)]} {
          set maxValueWidth($colNum) 0
          set maxValueString($colNum) ""
        }
        if {$len > $maxValueWidth($colNum)} {
          set maxValueWidth($colNum) $len
          set maxValueString($colNum) $propValue
        }
        incr colNum 
      }
      lappend propDataList [list $propLabel $propValueList $propName]
      incr rowNum 
    }
  }
  # puts stderr "colNum $colNum "
  for {set col 0} {$col < $colNum} {incr col} {
    # puts stderr "col $col $maxValueString($col)"
    set maxValueWidthPixels($col) [expr {[font measure [preferred StanleyDialogEntryFont] \
                                              $maxValueString($col)] + 4}]
  }
  set maxLabelHeightPixels [font metrics [preferred propStateLabelFont] -linespace]
  set maxLabelValuePixels [font metrics [preferred StanleyDialogEntryFont] -linespace]
  set rowHeightPixels $maxLabelHeightPixels
  if {$maxLabelValuePixels > $rowHeightPixels} {
    set rowHeightPixels $maxLabelValuePixels
  }

  global propNameValueArrayH$pirNodeIndex 
  global propNameValueArrayV$pirNodeIndex 
  if {! $updateP} {
    catch { unset propNameValueArrayH$pirNodeIndex }
    catch { unset propNameValueArrayV$pirNodeIndex }
  }
  # maxRows is an odd number because of title row, and data rows are pairs
  # of data & divider
  set rowNum 0; set maxRows 13; set maxCols 5
  # fill displayed columns even if no data is present
  if {$colNum < $maxCols} {
    set indx [expr { $colNum - 1 }]
    for {set col $colNum} {$col <= $maxCols} {incr col} {
      set maxValueWidthPixels($col) [expr {[font measure [preferred StanleyDialogEntryFont] \
                                                $maxValueString($indx)] + 4}]
    }
    set colNum $maxCols
  }
  # table title row
  set [subst propNameValueArrayH$pirNodeIndex](-1,0) "Attribute"
  for {set col 0} {$col < $colNum} {incr col} {
    # set [subst propNameValueArrayV$pirNodeIndex](-1,$col) $col
    # g_NM_packetTimeTagsList pairs of stateId & time
    set [subst propNameValueArrayV$pirNodeIndex](-1,$col) \
        [lindex [lindex $g_NM_packetTimeTagsList $col] 0]
  }
  # table data rows
  set propRowNameLabelList {}
  foreach triple [lsort -command labelSort $propDataList] {
    set [subst propNameValueArrayH$pirNodeIndex](${rowNum},0) \
        [lindex $triple 0]
    set [subst propNameValueArrayH$pirNodeIndex]([expr {$rowNum + 1}],0) ""

    set lineValues [lindex $triple 1]
    for {set col 0} {$col < $colNum} {incr col } {
      set [subst propNameValueArrayV$pirNodeIndex](${rowNum},$col) \
          [lindex $lineValues $col] 
      set [subst propNameValueArrayV$pirNodeIndex]([expr {$rowNum + 1}],$col) ""
    }
    # triple of row propname and proplabel
    # proplabels are not required to be unique
    lappend propRowNameLabelList [list $rowNum [lindex $triple 2] \
                                      [lindex $triple 0]]
    # increment for horizontal divider as well
    incr rowNum 2
  }
  # show propositions
  if {! $updateP} {
    set bgcolor [preferred StanleyMenuDialogBackgroundColor]
    frame $window.top -bd 2 -bg $bgcolor -relief flat
    frame $window.top.left -bg $bgcolor -relief flat
    scrollbar $window.top.sy -orient vertical -relief sunken \
        -command [list scrollYViewPropState [list $window.top.left.table \
                                                 $window.top.right.table]]
    # to modify bindings on table
    # bindtags .stateprops.mod-test-a.top.left.table ==> 
    #     .stateprops.mod-test-a.top.left.table Table .stateprops.mod-test-a all
    # bind Table => all bound events
    # bind Table <Button-1> shows code for binding
    table $window.top.left.table -rows [expr {$rowNum + 1}] -cols 2 \
        -width 2 -height $maxRows -yscrollcommand "$window.top.sy set" \
        -variable propNameValueArrayH$pirNodeIndex -anchor w -state disabled \
        -bg [preferred propStateLabelBgColor] -titlerows 1 -roworigin -1 \
        -highlightthickness 0 -rowtagcommand oddRowProc \
        -coltagcommand colNumTagProc -colstretchmode last \
        -font [preferred propStateLabelFont] 
    label $window.top.left.filler -bg $bgcolor -relief flat 
    # set column widths
    $window.top.left.table width 0 -$maxLabelWidthPixels 1 -3
    # equalize row heights with values table
    $window.top.left.table height -1 -$rowHeightPixels
    for {set i 0} {$i <= $rowNum} {incr i 2} {
      $window.top.left.table height $i -$rowHeightPixels
    }
    # set black horizontal dividing line between entries
    for {set i 1} {$i <= $rowNum} {incr i 2} {
      $window.top.left.table height $i -4
    }
    $window.top.left.table tag config oddRowTag -bg black
    # color column 1 black
    $window.top.left.table tag configure col1Tag -bg black
    # center column titles - (must specify font or option default font is used instead)
    $window.top.left.table tag configure titleRowTag -anchor c \
        -font [preferred StanleyDialogEntryFont] -background $bgcolor -foreground black 

    frame $window.top.right -bg $bgcolor -relief flat
    scrollbar $window.top.right.sx -orient horizontal \
        -command "$window.top.right.table xview" -relief sunken
    table $window.top.right.table -rows [expr {$rowNum + 1}] -cols $colNum \
        -width $maxCols -height $maxRows -yscrollcommand "$window.top.sy set" \
        -xscrollcommand "$window.top.right.sx set" \
        -variable propNameValueArrayV$pirNodeIndex \
        -anchor w -state disabled -rowtagcommand oddRowProc \
        -bg [preferred StanleyDialogEntryBackgroundColor] -titlerows 1 -roworigin -1 \
        -highlightthickness 0 -coltagcommand colNumTagProc \
        -font [preferred StanleyDialogEntryFont] -colstretchmode last 
    # equalize row heights with label table
    for {set i 0} {$i <= $rowNum} {incr i 2} {
      $window.top.right.table height $i -$rowHeightPixels
    }
    # set black horizontal dividing line between entries
    for {set i 1} {$i <= $rowNum} {incr i 2} {
      $window.top.right.table height $i -4
    }
    $window.top.right.table tag config oddRowTag -bg black
    # center column titles - (must specify font or option default font is used instead)
    $window.top.right.table tag configure titleRowTag -anchor c \
        -font [preferred StanleyDialogEntryFont] -bg $bgcolor -fg black 

    # establish value colors
    set colorIndex 0
    foreach color $g_NM_propValuesColorMap {
      # font must be specified, since option font (StanleyDefaultFont) will
      # be used otherwise
      $window.top.right.table tag config color$colorIndex -bg $color \
          -font [preferred StanleyDialogEntryFont] 
      incr colorIndex 
    }
  }
  # set column widths
  for {set col 0} {$col < $colNum} {incr col} {
    # puts stderr "col $col $maxValueWidthPixels($col)"
    $window.top.right.table width $col -$maxValueWidthPixels($col)
  }
  if {$updateP} {
    # update table with latest column
    $window.top.right.table configure -cols $colNum 
  }
  # scroll values to the right to show latest values
  showLatestPropValues $window.top.right.table $maxCols

  # apply colors to timeline values
  # puts stderr "propRowNameLabelList $propRowNameLabelList"
#   foreach triple $propRowNameLabelList {
#     set row [lindex $triple 0]
#     set propName [lindex $$triple 1]
#     set propLabel [lindex $triple 2]
#     # puts stderr "propLabel $propLabel propName $propName row $row"
#     set propNamePirIndex [assoc-array $propName g_NM_instanceToNode]
#     set propType [getTerminalInstanceType $propNamePirIndex terminalForm]
#     set typeValuesList [assoc-array $propType \
#                             g_NM_terminalTypeValuesArray]
#     if {! [string match [assoc-array $propType \
#                              g_NM_expandedStructureArray $reportNotFoundP] ""]} {
#       set typeValuesList [lindex $typeValuesList 0]
#     }
#     lappend typeValuesList "unknown"
#     # puts stderr "propType $propType typeValuesList $typeValuesList "
#     for {set col 0} {$col < $colNum} {incr col } {
#       set typeValue [subst $[subst propNameValueArrayV$pirNodeIndex](${row},$col)]
#       set colorIndex [lsearch -exact $typeValuesList $typeValue]
#       if {$colorIndex != -1} {
#         # puts stderr "typeValue $typeValue colorIndex $colorIndex row $row col $col "
#         $window.top.right.table tag cell color$colorIndex ${row},$col
#       } elseif {$g_NM_propsWarnMsgsP && (! [string match $typeValue "no-data"]) && \
#                     (! [string match $typeValue ""])} {
#         # NEED TO FIGURE OUT SCHEME TO COLORIZE VALUES WHICH WILL HANDLE
#         # PAIRED VALUES, AS WELL -- LIKE ( POSITIVE HIGH )
#         # set str "nodeShowTimelineProps: colorIndex not found for $propLabel for"
#         # puts stderr "$str $typeValue in ``$typeValuesList''"
#       }
#     }
#   }
  # puts stderr "rowNum $rowNum colNum $colNum"
  if {! $updateP} {
    grid $window.top.left.table -sticky ns
    grid $window.top.left.filler 
    grid $window.top.left -row 1 -col 0 -sticky ns
    grid $window.top.right.table -sticky news
    # always create x scroll so that auto x expansion does not have to worry about it
    grid $window.top.right.sx -sticky ew
    grid $window.top.right -row 1 -col 1 -sticky news 
    if {$rowNum > $maxRows} {
      grid $window.top.sy -row 1 -col 2 -sticky ns
      # restore y scroll position
      $window.top.left.table yview moveto $yScrollFraction
      $window.top.right.table yview moveto $yScrollFraction
    }
    grid $window.top - -sticky news

    # allow user to expand table with window manager in x direction
    grid columnconfig $window.top.right 0 -weight 1
    grid columnconfig $window.top 1 -weight 1
    grid columnconfig $window 0 -weight 1
    # allow user to expand table with window manager in y direction
    grid rowconfig $window.top.left 0 -weight 1
    grid rowconfig $window.top.right 0 -weight 1
    grid rowconfig $window.top 1 -weight 1
    grid rowconfig $window 1 -weight 1

    frame $window.buttons -bg $bgcolor -bd 2 -relief flat
    frame $window.buttons.left -bg $bgcolor -bd 2 -relief flat
    button $window.buttons.left.current -text "CURRENT" -relief raised \
        -command "nodeShowModeAndProps $labelWidget $pirNodeIndex $nodeClassType" 
    $window.buttons.left.current configure -takefocus 0
    button $window.buttons.left.timeline -text "TIMELINE" -relief raised \
        -command "nodeShowTimelineProps $labelWidget $pirNodeIndex $nodeClassType" \
        -state disabled
    $window.buttons.left.timeline configure -takefocus 0

    frame $window.buttons.right -bg $bgcolor -bd 2 -relief flat
    button $window.buttons.right.waveform -text "WAVEFORM" -relief raised \
        -command "nodeShowWaveformProps $labelWidget $pirNodeIndex $nodeClassType" 
    $window.buttons.right.waveform configure -takefocus 0
    button $window.buttons.right.dismiss -text "DISMISS" -relief raised \
        -command "destroy $window"
    $window.buttons.right.dismiss configure -takefocus 0

    grid $window.buttons.left.current -row 2 -col 0  -padx 10
    grid $window.buttons.left.timeline -row 2 -col 1 -padx 10
    grid $window.buttons.right.waveform -row 2 -col 2 -padx 10
    grid $window.buttons.right.dismiss -row 2 -col 3 -padx 10 
    grid $window.buttons.left $window.buttons.right - -sticky ew
    grid $window.buttons - -sticky ew

    keepDialogOnScreen $window $xPos $yPos
  }
  update
}


## scroll multiple widgets in y direction
## 05nov98 wmt:new - from p. 324 of Welch
proc scrollYViewPropState { widgetList args } {

  # puts stderr "scrollYViewPropState: B args $args"
  # force scroll bar to scroll 2 units rather than one
  # to skip over narrow black horizontal rows
  if {[regexp "scroll" $args]} {
    regsub "1 units" $args "2 units" tmp; set args $tmp
  }
  # puts stderr "scrollYViewPropState: A args $args"
  foreach widget $widgetList {
    eval { $widget yview } $args
  }
}


## scroll values table to show latest values (g_NM_propValuesCount)
## 12nov98 wmt: new
proc showLatestPropValues { tableWidget colsDisplayed } {
  global g_NM_propValuesCount

  # g_NM_propValuesCount is one based
  # col is zero based
  if {($g_NM_propValuesCount - 1) < $colsDisplayed} {
    set col 0
  } else {
    set col [expr {$g_NM_propValuesCount - 1}]
  }
  # puts stderr "showLatestPropValues: colsDisplayed $colsDisplayed col $col"
  # puts stderr "   g_NM_propValuesCount $g_NM_propValuesCount"
  # put $col at the left edge of $colsDisplayed 
  $tableWidget xview $col
}


## power available thermometer
## 16oct95 wmt: new
## 01nov95 wmt: add  -highlightthickness 0 to all widgets (Tk4.0)
## 05feb96 wmt: destroy old copies of this widget
# proc powerThermometer {} {
#   global g_NM_powerAvailableWidth g_NM_powerAvailable g_NM_powerMaxScale
#   global g_NM_powerAvailableWidgetPaths g_NM_powerAvailableSliderTag
#   global g_NM_powerMaxAvailable g_NM_powerAvailableSliderMaxTag
#   set numTicks 5; set borderwidth 4

#   set subWidth $g_NM_powerAvailableWidth
#   set subHeight [expr {$g_NM_powerAvailableWidth / 10.0}]
#   set sliderHeight [expr {$subHeight / 2.0}] 
#   set w .power
#   catch {destroy $w}
#   toplevel $w -class Dialog

#   ## not specifying wm geometry ..., asks the user to place window with mouse
#   wm title $w "MI Power Available"
#   wm iconname $w "MI Power"

#   frame $w.therm -borderwidth $borderwidth -relief flat \
#       -width [expr $subWidth + $subHeight] \
#       -height [expr $subHeight + $sliderHeight] 
#   frame $w.digital -borderwidth $borderwidth -relief sunken \
#       -width $subHeight -height $subHeight 
#   canvas $w.therm.scale -width [expr $subWidth + $subHeight] -height $subHeight \
#        -highlightthickness 0
#   $w.therm.scale config -background [preferred canvasBackgroundColor]
#   frame $w.therm.slider -width [expr $subWidth + $subHeight] \
#       -height $sliderHeight
#   canvas $w.therm.slider.slide -width $subWidth -height $sliderHeight \
#        -highlightthickness 0
#   canvas $w.therm.slider.filler -width [expr $subHeight + $sliderHeight] \
#       -height $sliderHeight  -highlightthickness 0
#   $w.therm.slider.slide config -background [preferred NM_powerAvailableSliderBg]
#   $w.therm.slider.filler config -background [preferred canvasBackgroundColor]
#   $w.therm.scale create line 0 [expr $subHeight - 1] $subWidth \
#       [expr $subHeight - 1] -width 2
#   set xPixelIncrement [expr (1.0 * $subWidth) / [expr $numTicks - 1]]
#   set xValueIncrement [expr (1.0 * $g_NM_powerMaxScale) / [expr $numTicks - 1]]
#   for {set i 0} {$i < $numTicks} {incr i} {
#     set x [expr ($i + 1) * $xPixelIncrement]
#     $w.therm.scale create line $x $subHeight $x $sliderHeight -width 2
#     $w.therm.scale create text [expr ($i * $xPixelIncrement) + $borderwidth] \
#         [expr (2 * $sliderHeight) - 1] -text [expr int( $i * $xValueIncrement)] \
#         -anchor sw
#   }
#   set maxAvailableLength \
#         [expr int((( 1.0 * $g_NM_powerMaxAvailable) / $g_NM_powerMaxScale) * \
#         $subWidth)]
#   set g_NM_powerAvailableSliderMaxTag \
#       [$w.therm.slider.slide create line $maxAvailableLength 0 \
#       $maxAvailableLength $subHeight -width 2 -fill \
#       [preferred NM_powerAvailableSliderMaxFg]]
#   set g_NM_powerAvailableSliderTag \
#       [$w.therm.slider.slide create rectangle 0 0 0 $subHeight \
#       -fill [preferred NM_powerAvailableSliderFg]]
#   label $w.digital.label -text [format {%3d} $g_NM_powerAvailable] \
#       -background [preferred NM_powerAvailableLabelBg] \
#       -foreground [preferred NM_powerAvailableLabelFg] -highlightthickness 0
#   pack $w.digital.label -side top -fill x
#   pack $w.therm.slider.slide $w.therm.slider.filler -side left
#   pack $w.therm.slider $w.therm.scale -side top -fill x
#   pack $w.therm -side left -fill x
#   pack $w.digital -side left -fill x -padx $borderwidth
#   set g_NM_powerAvailableWidgetPaths [list {.power.therm.slider.slide} \
#       {.power.digital.label}]
# }
      

## update power available digital value and slider
## 17oct95 wmt: new
# proc updatePowerAvailable { powerAvailableInput {updateMaxLineP 0}} {
#   global g_NM_powerAvailable g_NM_powerAvailableWidth
#   global g_NM_powerAvailableWidgetPaths g_NM_powerAvailableSliderTag
#   global g_NM_powerMaxAvailable g_NM_powerMaxScale g_NM_powerAvailableSliderMaxTag

#   if {[llength $g_NM_powerAvailableWidgetPaths] > 0} {
#     set g_NM_powerAvailable [expr round( $powerAvailableInput)]
#     set sliderPath [lindex $g_NM_powerAvailableWidgetPaths 0]
#     set labelPath [lindex $g_NM_powerAvailableWidgetPaths 1]
#     set subWidth $g_NM_powerAvailableWidth
#     set subHeight [expr $g_NM_powerAvailableWidth / 10.0]
#     set sliderHeight [expr $subHeight / 2.0]
#     if {$updateMaxLineP} {
#       set maxAvailableLength \
#         [expr int((( 1.0 * $g_NM_powerMaxAvailable) / $g_NM_powerMaxScale) * \
#         $subWidth)]
#       ${sliderPath} delete $g_NM_powerAvailableSliderMaxTag
#       set g_NM_powerAvailableSliderMaxTag \
#           [${sliderPath} create line $maxAvailableLength 0 \
#           $maxAvailableLength $subHeight -width 2 \
#           -fill [preferred NM_powerAvailableSliderMaxFg]]
#     }
#     set sliderLength \
#         [expr int((( 1.0 * $g_NM_powerAvailable) / $g_NM_powerMaxScale) * \
#         $subWidth)]
#     ## puts [format {updatePowerAvailable powerAvailableInput %f sliderLength %d} \
#     ##     $powerAvailableInput $sliderLength]
#     ${labelPath} config -text [format {%3d} $g_NM_powerAvailable]
#     ${sliderPath} delete $g_NM_powerAvailableSliderTag
#     set g_NM_powerAvailableSliderTag \
#         [${sliderPath} create rectangle 0 0 $sliderLength $subHeight \
#         -fill [preferred NM_powerAvailableSliderFg]]
#     update;   # make sure changes are processed
#   }
# }


## show user which components have faults
## clicking on a entry will open  canvas to that component
## 29jun98 wmt: new
proc showComponentFaultList { { canvasRootId 0 } { autoCallP 0 } } {
  global g_NM_componentFaultIndexList g_NM_componentFaultDialogRoot
  global pirNode g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset 

  set heightBorder 5; set textHeight 11; set initP 0
  set windowHeight [expr {1 + $textHeight}]
  set faultBgColor [preferred StanleyCurrentFaultModeBgColor]
  set bgColor [preferred StanleyMenuDialogBackgroundColor]
  set trimP 1

  set dialogW $g_NM_componentFaultDialogRoot
  set redrawP 0
  if {[winfo exists $dialogW]} {
    set xPos [expr {[winfo rootx $dialogW] - $g_NM_xWindowMgrOffset}]
    set yPos [expr {[winfo rooty $dialogW] - $g_NM_yWindowMgrOffset}]
  } else {
    set canvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
    set xPos [winfo pointerx $canvas]
    set yPos [winfo pointery $canvas] 
  }
  if {[winfo exists $dialogW]} {
    if {$autoCallP} {
      # delete current text and output new faults, since
      # this is called automatically by
      # incoming proposition handling routines, and user wants to see
      # the latest updates to the fault list
      set redrawP 1
    } else {
      # called by user via menu
      raise $dialogW
      return
    }
  }

  set w $dialogW.textWidget.text
  set textWidth 40
  if {! $redrawP} {
    toplevel $dialogW -class Dialog 
    wm title $dialogW "Component Faults"
    wm group $dialogW [winfo toplevel [winfo parent $dialogW]]
    wm geometry $dialogW +${xPos}+${yPos}

    frame $dialogW.textWidget
    frame $dialogW.textWidget.text -bg $bgColor
    #   frame $w.bottom
    #   -xscrollcommand "$w.bottom.sx set"
    set t [text $w.t -setgrid true -height $textHeight -background $bgColor \
               -yscrollcommand "$w.sy set" \
               -font [preferred StanleyDialogEntryFont] \
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
    $w.t config -height $canvasHeight
  } else {
    # erase existing text
    $w.t configure -state normal
    $w.t delete 1.0 end
  }

  # sort by nodeInstanceName 
  set preSortPairList {}
  for {set i 0} {$i < [llength $g_NM_componentFaultIndexList]} {incr i} {
    set pirNodeIndex [lindex $g_NM_componentFaultIndexList $i]
    lappend preSortPairList \
        [list [assoc nodeInstanceName pirNode($pirNodeIndex)] $pirNodeIndex]
  }
  set preSortPairList [lsort -ascii -index 0 $preSortPairList]

  foreach pair $preSortPairList {
    set pirNodeIndex [lindex $pair 1]
#    set pirNodeAList $pirNode($pirNodeIndex)
#    set displayLabel [getDisplayLabel pirNodeAList labelP $trimP]
    # show hierarchy name
    set displayLabel [getExternalNodeName \
                          [assoc nodeInstanceName pirNode($pirNodeIndex)]]
    # puts stderr "showComponentFaultList: displayLabel `$displayLabel'"
    $w.t insert end "$displayLabel\n" $pirNodeIndex
    $w.t tag bind $pirNodeIndex <Button-1> \
        "openCanvasToInstanceParent $pirNodeIndex $canvasRootId"
    $w.t tag bind $pirNodeIndex <Enter> \
        "enterComponentFault $w.t $pirNodeIndex [list $displayLabel] $canvasRootId"
    $w.t tag bind $pirNodeIndex <Leave> \
        "leaveComponentFault $w.t $pirNodeIndex $canvasRootId"
    if {[string length $displayLabel] > $textWidth} {
      set textWidth [string length $displayLabel]
    }
  }
  $w.t configure -width [expr {$textWidth + 1}]
  $w.t configure -state disabled

  if {! $redrawP} {
    frame $dialogW.textWidget.buttons -bg $faultBgColor 
    button $dialogW.textWidget.buttons.dismiss -text DISMISS -relief raised \
        -command "mkformNodeCancel $dialogW $initP"
    $dialogW.textWidget.buttons.dismiss configure -takefocus 0
    pack $dialogW.textWidget.buttons.dismiss -side left -padx 5m -ipadx 2m -expand 1
    pack $dialogW.textWidget.buttons -side bottom -expand 1 -fill x
    pack $dialogW.textWidget
  }
  
  keepDialogOnScreen $dialogW $xPos $yPos
}


## color this line as selected
## 30jun98 wmt: new
proc enterComponentFault { textWidget tag displayLabel canvasRootId } {

  set msg "<Mouse-L click>: open $displayLabel"
  set msg2 ""; set severity 0
  $textWidget tag configure $tag -background [preferred StanleySelectedColor]
  pirWarning $msg $msg2 $severity $canvasRootId
}


## color this line as selected
## 30jun98 wmt: new
proc leaveComponentFault { textWidget tag canvasRootId } {

  set msg ""; set msg2 ""; set severity 0
  $textWidget tag configure $tag -background [preferred StanleyMenuDialogBackgroundColor]
  pirWarning $msg $msg2 $severity $canvasRootId
}


## display state viewers for vmpl test mode
## 22dec98 wmt: new
proc displayVmplTestViewers { } {
  global g_NM_componentToNode g_NM_moduleToNode pirNode
  global g_NM_vmplTestModeP

  if {$g_NM_vmplTestModeP} {
    set pirNodeIndices {}
    foreach nodeInstanceName [array names g_NM_componentToNode] {
      if {$nodeInstanceName == 0} { continue }
      set pirNodeIndex [assoc-array $nodeInstanceName g_NM_componentToNode]
      set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
      set nodeGroupLevel [expr {[llength $parentNodeGroupList] - 1}]
      if {($nodeGroupLevel == 1) || ($nodeGroupLevel == 2)} {
        lappend pirNodeIndices $pirNodeIndex
      }
    }
    foreach nodeInstanceName [array names g_NM_moduleToNode] {
      if {$nodeInstanceName == 0} { continue }
      set pirNodeIndex [assoc-array $nodeInstanceName g_NM_moduleToNode]
      set parentNodeGroupList [assoc parentNodeGroupList pirNode($pirNodeIndex)]
      set nodeGroupLevel [expr {[llength $parentNodeGroupList] - 1}]
      if {(! [string match [assoc nodeState pirNode($pirNodeIndex)] \
                  "parent-link"]) && \
              (($nodeGroupLevel == 1) || ($nodeGroupLevel == 2))} {
        lappend pirNodeIndices $pirNodeIndex
      }
    }

    foreach pirNodeIndex $pirNodeIndices {
      set window [assoc window pirNode($pirNodeIndex)]
      set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)] 

      nodeShowModeAndProps $window.lab.label $pirNodeIndex $nodeClassType
    }
  }
}


## parse floating point number into whole and fracional parts
## 23mar99 wmt: from packetview-proc-util.tcl
proc parseFloat { float wholePartRef fractionPartRef \
                      { fractionalDigits 3} } {
  upvar $wholePartRef wholePart
  upvar $fractionPartRef fractionPart

  set index [string first "." $float]
  if {$index == -1} {
    append float "."
    for {set i 0} {$i < $fractionalDigits} {incr i} {
      append float "0"
    }
    set index [string first "." $float]
    # puts stderr "float $float index $index"
  }
  set wholePart [string range $float 0 [expr {$index - 1}]]
  set fractionPart "1[string range $float $index [expr {$index + $fractionalDigits + 1}]]"
  set fractionPart [expr {round ( $fractionPart * 1000)}]
  set fractionPart [string range $fractionPart 1 4]
  # puts stderr "parseFloat: wholePart $wholePart fractionPart $fractionPart"
}


## simple time duration formatting
## 23mar99 wmt: from packetview-proc-util.tcl
proc duration { time { fullFormatP 0 } { fractionalDigits 3} } {

  parseFloat $time wholePart fractionPart $fractionalDigits
  set fractionPart [string trimleft $fractionPart "0"]
  if {[string match $fractionPart ""]} {
    set fractionPart 0
  }
  set time $wholePart 
  set min_secs 60; set hr_secs 3600; set day_secs 86400
  if {$time < $min_secs} {
    if {$fullFormatP} {
      return [format "000:00:00:%02d.%0${fractionalDigits}d" \
                  $time $fractionPart]
    } else {
      return [format ":%02d.%0${fractionalDigits}d" $time $fractionPart]
    }
  } elseif {$time < $hr_secs} {
    set mins [expr {$time / $min_secs}]
    set secs [expr {$time % $min_secs}]
    if {$fullFormatP} {
      return [format "000:00:%02d:%02d.%0${fractionalDigits}d" \
                  $mins $secs $fractionPart]
    } else {
      return [format "%02d:%02d.%0${fractionalDigits}d" \
                  $mins $secs $fractionPart] 
    }
  } elseif {$time < $day_secs} {
    set hrs [expr {$time / $hr_secs}]
    set minsSecs [expr {$time % $hr_secs}]
    set mins [expr {$minsSecs / $min_secs}]
    set secs [expr {$minsSecs % $min_secs}]
    if {$fullFormatP} {
      return [format "000:%02d:%02d:%02d.%0${fractionalDigits}d" \
                  $hrs $mins $secs $fractionPart]
    } else {
      return [format "%02d:%02d:%02d.%0${fractionalDigits}d" \
                  $hrs $mins $secs $fractionPart]
    }
  } else {
    set days [expr {$time / $day_secs}]
    set hrsMins [expr {$time % $day_secs}] 
    set hrs [expr {$hrsMins / $hr_secs}]
    set minsSecs [expr {$time % $hr_secs}]
    set mins [expr {$minsSecs / $min_secs}]
    set secs [expr {$minsSecs % $min_secs}]
    return [format "%03d:%02d:%02d:%02d.%0${fractionalDigits}d" \
                $days $hrs $mins $secs $fractionPart]
  }
}

  











