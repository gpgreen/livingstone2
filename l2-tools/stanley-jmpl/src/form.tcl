# $Id: form.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## 11dec95 wmt: new, extracted from mkform
## 16jul97 wmt: always configure -takefocus
## 08aug97 wmt: handle state arg to implement read-only
## 08oct97 wmt: added frames to allow entry slot length to be less
##              than the parent widget; pass in entryWidth
proc mkEntryWidget { widgetPath label description value state \
                         {entryWidth ""} {takeFocus 1} } {
  global g_NM_mkEntryWidgetWidth

  if {[string match $entryWidth ""]} {
    set entryWidth $g_NM_mkEntryWidgetWidth
  }
  set bgcolor [preferred StanleyMenuDialogBackgroundColor]
  frame $widgetPath -bg $bgcolor 
  frame $widgetPath.label -bg $bgcolor 
  label $widgetPath.label.nametype -text $label -anchor w 
  label $widgetPath.label.descrp -text $description  -anchor w 
  pack $widgetPath.label.descrp $widgetPath.label.nametype \
      -side left -fill x 
  pack $widgetPath.label -side top -fill x 

  frame $widgetPath.fentry -bg $bgcolor 
  entry $widgetPath.fentry.entry -width $entryWidth -relief sunken \
      -font [preferred StanleyDialogEntryFont] 
  $widgetPath.fentry.entry insert 0 "$value"
  $widgetPath.fentry.entry configure -state $state
  ## tk_focusNext is bound to <Tab> for all widgets
  pack $widgetPath.fentry.entry -side left -fill x
  pack $widgetPath.fentry -side top -fill x

  frame $widgetPath.pad -bg $bgcolor 
  label $widgetPath.pad.left -text "" -anchor w  -bg $bgcolor \
      -width $g_NM_mkEntryWidgetWidth 
  label $widgetPath.pad.right -text "" -anchor w  -bg $bgcolor
  pack $widgetPath.pad.left $widgetPath.pad.right -side left -fill x
  pack $widgetPath.pad  -side top -fill x
  pack $widgetPath  -side top -fill x

  $widgetPath.fentry.entry configure -takefocus $takeFocus 
}


## strip off descriptive header on readable regexp
## 14sep00 wmt
proc stripOffRegexpHeader { readableString } {

  set index [string first ":" $readableString]
  return [string range $readableString [expr {$index + 2}] end]
}


## entryValueErrorCheck component_name "(_token)" "bplv_a"
## entryValueErrorCheck component_name "(_token)" "bplv-a"
## entryValueErrorCheck mode "(-token)" "stuck-closed"
## entryValueErrorCheck mode "(-token)" "stuck_closed"
## entryValueErrorCheck component_def "(file_name)" "latch-valve-1"
## entryValueErrorCheck component_def "(file_name)" "latch-valve-1$"
## entryValueErrorCheck steady_state_power "(or ON OFF)" "OFF"
## entryValueErrorCheck steady_state_power "(or ON OFF)" "OF"
## entryValueErrorCheck steady_state_power "(of ON OFF)" "OF"
## entryValueErrorCheck fault_modes "(0-n -tokens)" ""
## entryValueErrorCheck fault_modes "(0-n -tokens)" "stuck-open stuck-closed"
## entryvalueerrorcheck fault_modes "(0-n lists of -token pairs)" "{ closed open } {open closed}"
## entryvalueerrorcheck fault_modes "(0-n lists of -token pairs)" "( closed open ) (open closed)"

##              use regexp to validity check user entries
## 12dec95 wmt: new
## 30jul96 wmt: add (token)
## 27aug96 wmt: shortened tk_dialog msgs -- print longer msgs to stderr
## 12sep96 wmt: ensure that lisp forms have parens around them
## 13sep96 wmt: add ?token; allow null entries to be valid for tokens
## 01may97 wmt: added missingQMark to generate better error msg
# [a-zA-Z_][a-zA-Z0-9_]*
proc entryValueErrorCheck { fieldname type newValue } {
  global cfgstr
  global g_NM_readableJavaTokenRegexp g_NM_readableJavaTokenOrQRegexp
  global g_NM_readable01JavaTokenRegexp g_NM_readable1nJavaTokenRegexp
  global g_NM_readableJavaFormRegexp 

  # puts stderr "entryValueErrorCheck: fieldname $fieldname type $type newValue $newValue"
  set missingQMarkP 0; set leadingDigitP 0
  set newValue [string trim $newValue " "]
  if {$type == "(0-1_javaToken)" || ($type == "(javaToken)")} {
    set typePattern [stripOffRegexpHeader $g_NM_readableJavaTokenRegexp]
    if {[string match "" $newValue]} {
      if {$type == "(0-1_javaToken)"} {
      set validP 1
      } else {
        set validP 0
      }
    } elseif {[regexp {^[0-9]+} [string index $newValue 0]]} {
      # no leading digits
      set validP 0; set leadingDigitP 1
    } else {
      set validP [validateToken $newValue {^[a-zA-Z0-9_]+} invalidChar]
    }
  } elseif {[string match "(0-1_?javaToken)" $type] || \
                ($type == "(javaToken_or_?javaToken)")} {
    if {[string match "" $newValue]} {
      if {$type == "(0-1_?javaToken)"} {
        set validP 1
      } else {
        set validP 0
      }
    } elseif {[regexp {^[0-9]+} [string index $newValue 0]]} {
      # no leading digits
      set validP 0; set leadingDigitP 1
    } else {
      set typePattern [stripOffRegexpHeader $g_NM_readableJavaTokenRegexp]
      if {$type == "(0-1_?javaToken)"} {
        if {! [string match [string index $newValue 0] "?"]} {
          set validP 0; set missingQMarkP 1
          set typePattern [stripOffRegexpHeader $g_NM_readableJavaTokenOrQRegexp]
        }
        # strip off ?
        set newValue [string range $newValue 1 end] 
      } else {
        # (javaToken_or_?javaToken)
        if {[string match [string index $newValue 0] "?"]} {
          # strip off ?
          set newValue [string range $newValue 1 end] 
        }
      }
      if {! $missingQMarkP} {
        set validP [validateToken $newValue {^[a-zA-Z0-9_]+} invalidChar]
      }
    }
  } elseif {($type == "(0-n_javaTokens)") || ($type == "(1-n_javaTokens)")} {
    set typePattern [stripOffRegexpHeader $g_NM_readableJavaTokenRegexp] 
    if {$newValue == ""} {
      if {$type == "(0-n_javaTokens)"} {
        set validP 1
      } else {
        set validP 0
      }
    } elseif {[regexp {^[0-9]+} [string index $newValue 0]]} {
      # no leading digits
      set validP 0; set leadingDigitP 1
    } else {
      set validP [errorCheckMultipleTokens $newValue {^[a-zA-Z0-9_]+} invalidChar]
    }
  } elseif {($type == "(0-n_javaMplForms)") || ($type == "(javaMplForm)")} {
    set typePattern [stripOffRegexpHeader $g_NM_readableJavaFormRegexp]
    if {$newValue == ""} {
      if {$type == "(0-n_javaMplForms)"} {
        set validP 1
      } else {
        set validP 0
      }
    } else {
      ## check for matching parens is below
      set jMplFormP 1
      set validP [validateToken $newValue {^[a-zA-Z0-9()\\\{\\\}\\\[\\\] =!&|,:;\\\.\?_]+} \
                      invalidChar $jMplFormP]
    }
  } elseif {[string match "(javaToken_or_number)" $type]} {
    set alphaP [regsub -nocase -all {^[a-z]+} $newValue "A" formSub]
    if {! $alphaP} {
      set type "(number)"
      set typePattern {[0->9], ., +, -, e} 
      set validP [validateToken $newValue {^[0-9\\\.\\\+-e]+} invalidChar]
    } else {;   # token
      set type "(javaToken)"
      if {[regexp {^[0-9]+} [string index $newValue 0]]} {
        # no leading digits
        set validP 0; set leadingDigitP 1
      } else {
        set typePattern [stripOffRegexpHeader $g_NM_readableJavaTokenRegexp] 
        set validP [validateToken $newValue {^[a-zA-Z0-9_]+} invalidChar]
      }
    }
  } elseif {[string match "(number)" $type]} {
    set type "(number)"
    set typePattern {[0->9], ., +, -, e}
    set validP [validateToken $newValue {^[0-9\\\.\\\+-e]+} invalidChar]
  } elseif {[string match "(file_name)" $type] == 1} {
    set typePattern {[A->Z], [a->z], [0->9], ., -}
    set validP [validateToken $newValue {^[A-Za-z0-9\.-]+} invalidChar]
  } elseif {[string match "(directory_name)" $type] == 1} {
    set typePattern {[A->Z], [a->z], [0->9], _, -}
    set validP [validateToken $newValue {^[A-Za-z0-9_-]+} invalidChar]
  } elseif {[string match "(path_name)" $type] == 1} {
    set typePattern {[A->Z], [a->z], [0->9], -, /, .}
    set validP [validateToken $newValue {^[A-Za-z0-9/\.-]+} invalidChar]
  } elseif {[string match "(all_characters)" $type] == 1} {
    set typePattern {all characters}
    set validP 1
  } elseif {([llength $type] > 1) && ([string match "(or" [lindex $type 0]] == 1)} {
    set typePattern ""
    set numMatchesPlus1 [llength $type]
    set validP 0
    for {set i 1} {$i < $numMatchesPlus1} {incr i} {
      if {[string match $newValue [string trim [lindex $type $i] "\)"]] == 1} {
        set validP 1
      }
    }
  } else {
    set msg " FIELDNAME: `$fieldname', VALUE: \"$newValue\",\n"
    set msg "$msg    has unrecognized TYPE: $type.\n"
    puts stderr "entryValueErrorCheck: $msg"
    set shortMsg " FIELDNAME: `$fieldname' has unrecognized\n\n TYPE: $type.\n"
    set dialogList [list tk_dialog .d "ERROR" $shortMsg error 0 {DISMISS}]
    eval $dialogList
    return 0;    
  }
  ##puts "fieldname $fieldname type $type newValue $newValue typePat $typePattern validP $validP "
  if {! $validP} {
    set msg " FIELDNAME: `$fieldname', VALUE: \"$newValue\",\n"
    set msg "$msg    did not pass error checking for TYPE: $type.\n"
    set shortMsg " FIELDNAME: `$fieldname' did not pass error checking for\n"
    append shortMsg "TYPE: $type,\n\n"
    if {$missingQMarkP} {
      set msg "$msg    ? is not first char.\n"
      set shortMsg "$shortMsg ? is not first char.\n"
    } elseif {$leadingDigitP} {
      set msg "$msg    leading digits not allowed.\n"
      set shortMsg "$shortMsg leading digits not allowed.\n"
    } elseif {[string match $newValue ""]} {
      set msg "$msg    `$fieldname' not entered.\n"
      set shortMsg "$shortMsg `$fieldname' not entered.\n"      
    } elseif {! [string match $typePattern ""]} {
      set msg "$msg    invalid character `$invalidChar',\n"
      set shortMsg "$shortMsg invalid character `$invalidChar',\n"
      set msg "$msg    VALID CHARS: $typePattern\n"
      set shortMsg "$shortMsg VALID CHARS: $typePattern\n"
    }
    puts stderr "entryValueErrorCheck: $msg"
    set dialogList [list tk_dialog .d "ERROR" $shortMsg error 0 {DISMISS}]
    eval $dialogList 
  } elseif {([string match "(0-n_javaMplForms)" $type] || \
                 [string match "(javaMplForm)" $type]) && \
                (! [string match "" $newValue])} {
    set msg " FIELDNAME: `$fieldname', VALUE: \"$newValue\",\n"
    set msg "$msg    did not pass error checking for TYPE: $type,"
    set shortMsg " FIELDNAME: `$fieldname' did not pass error checking for\n TYPE: $type,"
    set postMsg ""
    set leftMatchCnt [regsub -nocase -all "\\\(" $newValue "\\\(" formSub]
    set rightMatchCnt [regsub -nocase -all "\\\)" $newValue "\\\)" formSub]
    # puts stderr "entryValueErrorCheck: parenLeft $leftMatchCnt parenRight $rightMatchCnt"
    if {($leftMatchCnt != $rightMatchCnt)} {
      append postMsg "\n    parentheses do not match."
    }
    set leftMatchCnt [regsub -nocase -all "\\\{" $newValue "\\\{" formSub]
    set rightMatchCnt [regsub -nocase -all "\\\}" $newValue "\\\}" formSub]
    # puts stderr "entryValueErrorCheck: curlyLeft $leftMatchCnt curlyRight $rightMatchCnt"
    if {($leftMatchCnt != $rightMatchCnt)} {
      append postMsg "\n    curly brackets do not match."
    }
    set leftMatchCnt [regsub -nocase -all "\\\[" $newValue "\\\[" formSub]
    set rightMatchCnt [regsub -nocase -all "\\\]" $newValue "\\\]" formSub]
    # puts stderr "entryValueErrorCheck: squareLeft $leftMatchCnt squareRight $rightMatchCnt"
    if {($leftMatchCnt != $rightMatchCnt)} {
      append postMsg "\n    square brackets do not match."
    }
    if {$postMsg != ""} {
      append msg $postMsg
      puts stderr "entryValueErrorCheck: $msg"
      append shortMsg $postMsg
      set dialogList [list tk_dialog .d "ERROR" $shortMsg error 0 {DISMISS}]
      eval $dialogList
      set validP 0
    }
  }
  return $validP
}


## parse multiple tokens with error checking
## 13dec95 wmt: new
## 12aug97 wmt: handle ?tokens -- do not use get_alist 
proc errorCheckMultipleTokens { valueString regexpPattern invalidCharRef } {
  upvar $invalidCharRef invalidChar

  set validP 1
  set tokenList $valueString
  set numTokens [llength $tokenList]
  for {set i 0} {$i < $numTokens} {incr i} {
    set validP [validateToken [lindex $tokenList $i] $regexpPattern \
                    invalidChar]
    if {! $validP} {
      break
    }
  }
  return $validP
}


## 14dec95 wmt: new
## 17sep96 wmt: add optional arg initP
## 02may97 wmt: made initP a required arg -- optional args do not get
##              their default value when called as -command value to buttons
## 08oct97 wmt: add variable number of args
proc mkformNodeCancel { widget initP args } {
  global g_NM_mkformNodeCompleteP g_NM_livingstoneDefmoduleName
  global g_NM_livingstoneDefmoduleArgList pirFileInfo
  global g_NM_defmoduleFilePath g_NM_livingstoneDefmoduleFileName
  global g_NM_transitionStartPirIndex g_NM_schematicMode
  global g_NM_livingstoneDefmoduleArgTypeList 

  # puts stderr "mkformNodeCancel: widget $widget initP $initP"
  destroy $widget
  set g_NM_mkformNodeCompleteP 0
  # reset this after a mode edit cancel, so that Mouse-l-release
  # which occurs with Contol-Mouse-l will not invoke mode edit again
  set g_NM_transitionStartPirIndex 0
  ## this is very slow
  ## raiseStanleyWindows 
  if {$initP} {
    set reinit 1
    initialize_graph $reinit
    set g_NM_livingstoneDefmoduleArgList {}
    set g_NM_livingstoneDefmoduleArgTypeList {}
    set g_NM_defmoduleFilePath ""
    set pirFileInfo(filename) ""
    mark_scm_unmodified
    displayDotWindowTitle
  }
}


## ensure that java mpl forms terminate with a ;,
## since trailing } will be trimed off by Stanley
## handling of the form
## 21jan00 wmt: new
proc terminateJmplForm { formRef } {
  upvar $formRef form

  set form [string trimright $form " "]
  set length [string length $form]
  if {$length > 1} {
    set lastChar [string index $form [expr {$length - 1}]]
    if {$lastChar != ";"} {
      append form ";"
    }
  }
}


## validity check tokens with regexp
## 12dec95 wmt: new
## 27aug96 wmt: print out invalid character
## 30may97 wmt: add lispFormP to handle multi-line lisp forms
##              ; & , & ' & . are for imbedded comments
proc validateToken { token regexpString invalidCharRef { jMplFormP 0 } } {
  upvar $invalidCharRef invalidChar

  # puts "validateToken token $token regexpString $regexpString"
  set validP 1; set invalidChar ""; set commentRegionP 0
  set commentRegionSlashSlashP 0; set commentRegionEnableIndx -9
  set commentRegionSlashStarP 0; set commentRegionDisableIndx -9
  # in comment region of jMpl form allow any characters
  # comment regions are // => \n  and /*  => */
  set numChars [string length $token]
  for {set i 0} {$i < $numChars} {incr i} {
    set char [string index $token $i]
    # special handling for regular expression special characters
    set regexpChar [getCharRegExpression $char]
    set validP [regexp $regexpString $regexpChar]
    # puts stderr "validateToken: char `$char' validP $validP commentRegionP $commentRegionP SlashSlash $commentRegionSlashSlashP SlashStar $commentRegionSlashStarP"
    if {(! $validP) && $jMplFormP} {
      if {(! $commentRegionP) && [regexp "/" $regexpChar]} {
        if {($commentRegionEnableIndx + 1) == $i} {
          set commentRegionSlashSlashP 1; set commentRegionP 1
          set commentRegionEnableIndx -9
        } else {
          set commentRegionEnableIndx $i
        }
        set validP 1
      } elseif {$commentRegionP && $commentRegionSlashSlashP && \
                    ([regexp "\n" $regexpChar] || [regexp "\r" $regexpChar])} {
        set commentRegionSlashSlashP 0; set commentRegionP 0
        set validP 1 
      } elseif {[regexp "\n" $regexpChar] || [regexp "\t" $regexpChar] || \
                    [regexp "\r" $regexpChar]} {
        # allow multiple lines
        set validP 1
      } elseif {(! $commentRegionP) && [regexp "\\\*" $regexpChar] && \
                    (($commentRegionEnableIndx + 1) == $i)} {
        set commentRegionEnableIndx -9 ; set commentRegionSlashStarP 1
        set commentRegionP 1; set validP 1 
      } elseif {$commentRegionP && $commentRegionSlashStarP && \
                    [regexp "\\\*" $regexpChar]} {
        set commentRegionDisableIndx $i; set validP 1
      } elseif {$commentRegionP && $commentRegionSlashStarP && \
                    [regexp "/" $regexpChar] && \
                    (($commentRegionDisableIndx + 1) == $i)} {
        set commentRegionSlashStarP 0; set commentRegionP 0
        set commentRegionDisableIndx -9; set validP 1
      } elseif {$commentRegionP} {
        # allow any chars
        set validP 1
      }
    }
    if {! $validP} {
      # puts stderr "validateToken: invalid character `$char'"
      set invalidChar $char 
      break
    }
  }
  return $validP
}












