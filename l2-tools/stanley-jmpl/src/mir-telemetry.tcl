# $Id: mir-telemetry.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## code for processing MIR telemetry IPC messages

## read IPC messages from a file
## 15oct95 wmt: new
## 30may96 wmt: remove STANLEY_MISSION from pathnames
proc testScenario {} {
  global STANLEY_ROOT g_NM_firstTelemP

  # set fileNameList [glob *.input]
  # listBoxTitle "Test Scenario File to Open" 
  # [listbox .scn]
  # .scn insert $fileNameList
  # pack .scn
  ## set filenm "$STANLEY_ROOT/test-scenario.input"
  set path [pwd]
  set cannedDir \
      "${STANLEY_ROOT}/interface/[preferred livingstone_directory]/[preferred canned_directory]" 
  cd $cannedDir

  # use tk_getOpenFile instead of dirbrowser3 
#   set filenm [dirbrowser3 .dirbrowser -message "IPC File to Open" \
#                   -directory [pwd] -filemask "*.*"]

  # prevent spurios rectangular skeleton from being left on canvas
  enableMouseSelection [getCanvasRootInfo g_NM_currentCanvas]

  if {! [string match $filenm ""]} {
    if {$g_NM_firstTelemP} {
      printTelemetryHeader
      set g_NM_firstTelemP 0
    }
    set fileExtension [file extension $filenm]
    set fileId [open $filenm r]
    while {[gets $fileId message] >= 0} {
      if {[string match $fileExtension ".tuple"]} {
        parseMIRTupleIPCMessage message
      } elseif {[string match $fileExtension ".string"]} {
        regsub -all "\\\(" $message "\{" tmp; set message $tmp
        regsub -all "\\\)" $message "\}" tmp; set message $tmp
        parseMPLPropAttrValList message 
      } else {
        puts stderr "testScenario: fileExtension $fileExtension not handled"
      }
      after 500
    }
    close $fileId
    puts stderr "\nCanned scenario `$filenm' complete."
    cd $path
  }
  # reset everything like mouse-left click on canvas
  set g_NM_processingNodeGroupP 1
  canvasB1Release [getCanvasRootInfo g_NM_currentCanvas 0].c 0 0
  standardMouseClickMsg
}


## process the tuple format IPC message from with 
## GROUND_FROM_TLM_MIR_TELEMETRY or
## MIR_GUI_STATE_UPDATE_RAX
## 16mar98 wmt: extracted out of parseMIRTupleIPCMessage
proc handleCORBAMessage { listOfTokensRef componentModePirNodeIndicesRef \
                            attrValPirNodeIndicesRef caller } {
  upvar $listOfTokensRef listOfTokens
  upvar $componentModePirNodeIndicesRef componentModePirNodeIndices
  upvar $attrValPirNodeIndicesRef attrValPirNodeIndices
  global pirNode g_NM_propsWarnMsgsP g_NM_propositionToNode 
  global goodPropCnt badPropCnt nextPropCnt unknownPropCnt
  global g_NM_propValuesCount g_NM_propValuesArray
  global g_NM_packetTimeTagsList g_NM_groundRefTime
  global g_NM_testInstanceNameInternal g_NM_defaultDisplayState 

  set reportNotFoundP 0
  foreach tokenList $listOfTokens {
    # puts stderr "handleCORBAMessage: tokenList $tokenList"
    set messageType [lindex $tokenList 0]
    set messageArg1 [lindex $tokenList 1]
    set messageArg2 [lindex $tokenList 2]
       
    # set str "handleCORBAMessage: messageType $messageType messageArg1"
    # puts stderr "$str $messageArg1 messageArg2 $messageArg2"
    if {[string match $messageType "timeTag"]} {
      # list of stateId and time
      lappend g_NM_packetTimeTagsList [list $messageArg1 $messageArg2]
    } elseif {[string match $messageType "attrVal"]} {
      set propValue $messageArg2; set propositionSelected 0
      set startStateAttrP 0
      set propAttribute [getInternalNodeName $messageArg1]
      if {$propAttribute == "$g_NM_testInstanceNameInternal.StartState"} {
        ; # do nothing at this time
        set startStateAttrP 1
      }
      if [ catch { set currentList $g_NM_propositionToNode($propAttribute) } ] {
        set pirNodeIndexList {}
        # puts stderr "handleCORBAMessage: failed propAttribute $propAttribute"
      } else {
        set pirNodeIndexList [assoc pirNodeIndices currentList]
        set g_NM_propositionToNode($propAttribute) [list pirNodeIndices \
                                                        $pirNodeIndexList \
                                                        receivedPropP 1]
#         if {[regexp {test\.tk02} $propAttribute]} {
#           puts stderr "handleCORBAMessage: propName $propAttribute propToNodeAlist $currentList"
#         }
        if {$caller == "newState"} {
          # add current value to prop list
          # handle multiple valued propositions like sr-values type
          set dataList [assoc-array $propAttribute g_NM_propValuesArray]
          if {$g_NM_propValuesCount == 0} {
            # replace noData with first message's values
            set val [lindex $dataList 0]
            if {[string match $val $g_NM_defaultDisplayState]} {
              # single valued
              set dataList $propValue
              set storePropValue $propValue 
            } else {
              # multiple valued
              set dataList {}
              lappend dataList [list $val $propValue]
              set storePropValue [list $val $propValue]
              # puts stderr "handleCORBAMessage:0 propName $propAttribute dataList $dataList"
            }
          } else {
            set val [lindex $dataList $g_NM_propValuesCount]
            if {[string match $val ""]} {
              # single valued
              lappend dataList $propValue
              set storePropValue $propValue 
            } else {
              # multiple valued
              set dataList [lrange $dataList 0 [expr {$g_NM_propValuesCount - 1}]]
              lappend dataList [concat $val $propValue]
              set storePropValue [lindex $dataList $g_NM_propValuesCount]
              # puts stderr "handleCORBAMessage:n propName $propAttribute dataList $dataList"
              # puts stderr "   pirNodeIndexList $pirNodeIndexList"
            }
          }
          set g_NM_propValuesArray($propAttribute) $dataList
        }
      }
      if {! $startStateAttrP} {
        if {[llength $pirNodeIndexList] > 0} {
          # puts stderr "pirNodeIndexList `$pirNodeIndexList'"
          set firstTimeP 1
          foreach pirNodeIndex $pirNodeIndexList {
            set instanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
            # set str "handleCORBAMessage: instanceName $instanceName propAttribute"
            # puts stderr "$str $propAttribute pirNodeIndex $pirNodeIndex"
            set propositionSelected 1
            if {$propositionSelected} {
              # set str "handleCORBAMessage: nodeClassType"
              # append str " [assoc nodeClassType pirNode($pirNodeIndex)]"
              # append str " nodeInstanceName"
              # puts stderr "$str [assoc nodeInstanceName pirNode($pirNodeIndex)]"
              # nodeClassType terminal do not have nodePropList slots
              if {! [string match [assoc nodeClassType pirNode($pirNodeIndex)] \
                         "terminal"]} {
                set currentList [assoc nodePropList pirNode($pirNodeIndex)]
                set reportNotFoundP 0; set returnIndexP 1
                # puts stderr "propAttribute $propAttribute currentList $currentList"
                set existingAttrIndex [assoc-exact $propAttribute currentList \
                                           $reportNotFoundP $returnIndexP]
                if {$existingAttrIndex == -1} {
                  # unexpected proposition
                  # this cannot happen now that g_NM_propositionToNode is used to
                  # match incoming propositions
                  if {$g_NM_propsWarnMsgsP} {
                    # puts stderr "parseMIRtelemetryMessage: IGNORED => $tokenList"
                    # puts stderr "handleCORBAMessage: ADDED => $tokenList"
                    set str "... $instanceName: unexpected proposition"
                    puts stderr "$str $propAttribute $propValue"
                    # only add this proposition if $g_NM_propsWarnMsgsP == 1
                    # this in only for testing and since the models are not complete
                    # keep list in alpha order
                    set attList [alist-keys currentList]
                    lappend attList $propAttribute
                    set sortedAttList [lsort -ascii -increasing $attList]
                    set indx [assoc $propAttribute sortedAttList $reportNotFoundP \
                                  $returnIndexP]
                    set currentList [linsert $currentList [expr {$indx * 2}] \
                                         $propAttribute $propValue]
                    # puts stderr [format "%-62s %-12s" \
                        #                  $propAttribute $propValue]
                  }
                } else {
                  if {$g_NM_propsWarnMsgsP && $firstTimeP} {
                    puts stderr [format "%-62s %-12s" \
                                     [getExternalNodeName $propAttribute] $propValue]
                    incr goodPropCnt 
                    set firstTimeP 0
                  }
                }
                set labelValueAList [assoc $propAttribute currentList]
                arepl value $storePropValue labelValueAList
                arepl $propAttribute $labelValueAList currentList 
                arepl nodePropList $currentList pirNode($pirNodeIndex)
                # set str "propAttribute $propAttribute storePropValue $storePropValue label" 
                # puts stderr "$str [assoc label labelValueAList]"
                if {[string match [assoc label labelValueAList] _mode_]} {
                  # component mode change
                  arepl nodeState $propValue pirNode($pirNodeIndex)
                  # update the mode nodes in the component
                  if {[lsearch -exact $componentModePirNodeIndices \
                           $pirNodeIndex] == -1} {
                    lappend componentModePirNodeIndices $pirNodeIndex
                  }
                }
              }
              # update the component/module bg color
              if {[string match [set entries \
                                     [assoc $pirNodeIndex attrValPirNodeIndices \
                                          $reportNotFoundP]] ""]} {
                lappend attrValPirNodeIndices $pirNodeIndex $propAttribute
              } else {
                if {[lsearch -exact $entries $propAttribute] == -1} {
                  lappend entries $propAttribute
                  arepl $pirNodeIndex $entries attrValPirNodeIndices
                }
              }
              # puts stderr "handleCORBAMessage: attrValPirNodeIndices $attrValPirNodeIndices"
            }
          }
        } else {
          if {$g_NM_propsWarnMsgsP} {
            puts stderr "... ${propAttribute}=$propValue not a known proposition "
            incr badPropCnt
          }
        }
      }
    } else {
      if {$g_NM_propsWarnMsgsP} {
        puts stderr "handleCORBAMessage: IGNORED => $tokenList"
        puts stderr "... messageType $messageType is not handled\!"
      }
    }
  }
  if {$g_NM_propsWarnMsgsP} {
    # delimiter between packet groups
    puts stderr "===="
  }
}


## get pirNodeIndex for deviceName, either a component or a module
## 26jul96 wmt: new
## 19nov96 wmt: pass raw message 
## 09dec96 wmt: change from g_NM_instanceToNode to g_NM_componentToNode
## 11dec96 wmt: check for modules
## 15sep97 wmt: use g_NM_moduleToComponent to transfer a module msg to the
##              appropriate component
## 23jan97 wmt: discard g_NM_ignoreInstances & g_NM_moduleToComponent 
proc getPirNodeIndex { maybeNodeInstanceName tupleList } {
  global g_NM_componentToNode g_NM_notComponentModuleList
  global g_NM_propsWarnMsgsP g_NM_moduleToNode g_NM_notComponentModuleList

  # puts stderr "getPirNodeIndex: maybeNodeInstanceName `$maybeNodeInstanceName'"
  set reportNotFoundP 0
  set pirNodeIndex [assoc-array $maybeNodeInstanceName g_NM_componentToNode \
                        $reportNotFoundP]
  if {[string match $pirNodeIndex ""]} {
    set pirNodeIndex [assoc-array $maybeNodeInstanceName g_NM_moduleToNode  \
                          $reportNotFoundP]
    if {[string match $pirNodeIndex ""] && $g_NM_propsWarnMsgsP && \
            ([lsearch -exact $g_NM_notComponentModuleList \
                  $maybeNodeInstanceName] == -1)} {
      lappend g_NM_notComponentModuleList $maybeNodeInstanceName 
      set nodeInstanceName $maybeNodeInstanceName 
      # puts -nonewline stderr "."
      # puts stderr "getPirNodeIndex: IGNORED => $tupleList"
      puts stderr "... $nodeInstanceName not a component or module" 
    }
  }
  return $pirNodeIndex
}


## 23jan97 wmt: derived from getPirNodeIndex 
proc getComponentPirNodeIndex { maybeNodeInstanceName tupleList } {
  global g_NM_componentToNode g_NM_propsWarnMsgsP g_NM_notModuleList

  # puts stderr "getComponentPirNodeIndex: maybeNodeInstanceName `$maybeNodeInstanceName'"
  set reportNotFoundP 0
  set pirNodeIndex [assoc-array $maybeNodeInstanceName g_NM_componentToNode \
                        $reportNotFoundP]
  if {[string match $pirNodeIndex ""] && $g_NM_propsWarnMsgsP && \
          ([lsearch -exact $g_NM_notModuleList \
                $maybeNodeInstanceName] == -1)} {
    lappend g_NM_notModuleList $maybeNodeInstanceName 
    set nodeInstanceName $maybeNodeInstanceName 
    # puts -nonewline stderr "."
    # puts stderr "getComponentPirNodeIndex: IGNORED => $tupleList"
    puts stderr "... $nodeInstanceName not a component" 
  }
  return $pirNodeIndex
} 


## parse string format messages
## which are generated by MIR running on the ground from onboard
## MIR telemetry coming thru DSN
## 21aug97 wmt: new
proc parseMPLPropAttrValList { messageListRef caller } {
  upvar $messageListRef messageList
  global pirNode g_NM_componentFaultIndexList pirEdge 
  global g_NM_propValuesArray g_NM_propValuesCount
  global pirEdges g_NM_componentFaultIndexList_1
  global g_NM_statePropsRootWindow g_NM_raxStartTimeP
  global g_NM_propsWarnMsgsP g_NM_componentFaultDialogRoot
  global g_NM_defaultDisplayState g_NM_propositionToNode 

  catch { unset componentModePirNodeIndices attrValPirNodeIndices }
  set componentModePirNodeIndices {}
  set attrValPirNodeIndices {}
  set fullUpdateP 0
  set reportNotFoundP 0; set g_NM_raxStartTimeP 0
  set oldvalMustExistP 0 
  if {[string match $messageList NIL]} {
    puts stderr "No resulting transitions"
    if {$g_NM_propsWarnMsgsP} {
      # delimiter between packet groups
      puts stderr "===="
    }
    return
  }
  # uncomment next line for testing
  # puts stderr "parseMPLPropAttrValList: messageList $messageList"
  handleCORBAMessage messageList componentModePirNodeIndices \
      attrValPirNodeIndices $caller  

  # the first msg values replaces the noData in the 0th column.
  # extend with the second and subsequent msgs
  incr g_NM_propValuesCount
  if {($g_NM_propValuesCount > 1) && ($caller == "newState")} {
    # propositions which did not get new values from this CORBA message
    foreach propName [array names g_NM_propValuesArray] {
      if {$propName == 0} { continue }
      set dataList [assoc-array $propName g_NM_propValuesArray]
      # puts stderr "parseMPLPropAttrValList: propName $propName len [llength $dataList]"
      if {[set len [llength $dataList]] < $g_NM_propValuesCount} {
        # set extendedValue [lindex $dataList [expr {$len - 1}]]
        ## since L2 updates are total, rather than incremental,
        ## do not extend previous value, indicate that no data was received
        set extendedValue $g_NM_defaultDisplayState
        # set str "parseMPLPropAttrValList: propName $propName value"
        # puts stderr "$str $extendedValue extended"
        lappend dataList $extendedValue
        set g_NM_propValuesArray($propName) $dataList
        # since this is a new value, rather than being extended, we have
        # to update the node's prop list
        set propToNodeAlist $g_NM_propositionToNode($propName)
#         if {[regexp {test\.tk02} $propName]} {
#           puts stderr "parseMPLPropAttrValList: noData propName $propName propToNodeAlist $propToNodeAlist"
#         }
        set pirNodeIndices [assoc pirNodeIndices propToNodeAlist]
        foreach nodeIndex $pirNodeIndices {
          # nodeClassType terminal do not have nodePropList slots
          if {! [string match [assoc nodeClassType pirNode($nodeIndex)] \
                     "terminal"]} {
            # puts stderr "    nodeIndex $nodeIndex"
            set currentList [assoc nodePropList pirNode($nodeIndex)]
            # terminal structured type slots have no nodePropList 
            if {$currentList != ""} {
              set labelValueAList [assoc $propName currentList]
              arepl value $extendedValue labelValueAList
              arepl $propName $labelValueAList currentList 
              arepl nodePropList $currentList pirNode($nodeIndex)
              # mode variable requires special handling
              if {[string match [assoc label labelValueAList] _mode_]} {
                # component mode change
                arepl nodeState $extendedValue pirNode($nodeIndex)
                # update the mode nodes in the component
                if {[lsearch -exact $componentModePirNodeIndices \
                         $nodeIndex] == -1} {
                  lappend componentModePirNodeIndices $nodeIndex
                }
              }
              # update the component/module bg color
              if {[string match [set entries \
                                       [assoc $nodeIndex attrValPirNodeIndices \
                                            $reportNotFoundP]] ""]} {
                lappend attrValPirNodeIndices $nodeIndex $propName
              } else {
                if {[lsearch -exact $entries $propName] == -1} {
                  lappend entries $propName
                  arepl $nodeIndex $entries attrValPirNodeIndices
                }
              }
            }
          }
        }
      }
    }
  }

  # display nodes from data structures modified by complete message
  set g_NM_componentFaultIndexList_1 $g_NM_componentFaultIndexList
  if {[llength $componentModePirNodeIndices] > 0} {
    foreach pirNodeIndex $componentModePirNodeIndices {
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
      set nodeState [assoc nodeState pirNode($pirNodeIndex)]
      # change node state in defcomponent modes
      changeDefcomponentState $pirNodeIndex "update" $nodeState
    }
  }

  # resetTerminalsConnectionsPropHilits

  # puts stderr "parseMPLPropAttrValList: attrValPirNodeIndices $attrValPirNodeIndices"
  # update the component/module bg colors and update nodes
  # because displayStateProc tcl code is evaluated for each component/module
  # the eval order must be from bottom up to handle dependencies on lower nodes
  # first do all "leaf" components and build module level list
  set moduleLevelList {}; set maxLevel 0
  for {set i 0} {$i < [llength $attrValPirNodeIndices]} {incr i 2} {
    set pirNodeIndex [lindex $attrValPirNodeIndices $i]
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)] 
    if {$nodeClassType  == "component"} {
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
      set propNameList [lindex $attrValPirNodeIndices [expr {$i + 1}]]
      componentModulePropChange $pirNodeIndex $nodeInstanceName propNameList \
          $fullUpdateP
    } elseif {$nodeClassType == "module"} {
      set lengthParentNodeGroupList \
          [llength [assoc parentNodeGroupList pirNode($pirNodeIndex)]]
        set level [expr {$lengthParentNodeGroupList - 2}]
      if {$level > $maxLevel} {
        set maxLevel $level
      }
      set levelList [assoc $level moduleLevelList $reportNotFoundP]
      lappend levelList [list $pirNodeIndex $i]
      arepl $level $levelList moduleLevelList $reportNotFoundP $oldvalMustExistP
    }
    # discard nodeClassType == "terminal"
  }
  # puts stderr "parseMPLPropAttrValList: moduleLevelList $moduleLevelList"
  # now do the modules by max level up
  for {set level $maxLevel} {$level >= 0} {incr level -1} {
    foreach pair [assoc $level moduleLevelList $reportNotFoundP] {
      set pirNodeIndex [lindex $pair 0]
      set i [lindex $pair 1]
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
      set propNameList [lindex $attrValPirNodeIndices [expr {$i + 1}]]
      componentModulePropChange $pirNodeIndex $nodeInstanceName propNameList \
          $fullUpdateP
    }
  }

  if {[winfo exists $g_NM_statePropsRootWindow] && \
          ($caller == "newState")} {
    # update all active state viewer windows
    updateStateViewerWindows 
  }

  # show user the components with faults
  # do not pop this up automatically - if already up, display
  # use Tools->component Faults
  if {([llength $g_NM_componentFaultIndexList] > 0) || \
          ([llength $g_NM_componentFaultIndexList_1] > 0)} {
    set diffP 0 
    if {([llength $g_NM_componentFaultIndexList_1] > 0) && \
            ([llength $g_NM_componentFaultIndexList] == 0)} {
      # previous faults have been recovered - show user empty fault dialog
      set diffP 1
    }
    if {(! $diffP) && ([llength $g_NM_componentFaultIndexList] > 0)} {
      # maybe previous faults - are current faults same as previous?
      # different indices?
      foreach index $g_NM_componentFaultIndexList {
        if {[lsearch -exact $g_NM_componentFaultIndexList_1 $index] == -1} {
          # new fault not in previous list
          set diffP 1
          break
        }
      }
    }
    if {$diffP && [winfo exists $g_NM_componentFaultDialogRoot]} {
      set autoCallP 1; set canvasRootId 0
      showComponentFaultList $canvasRootId $autoCallP
    } else {
      ; # either no faults to show or same faults as previous or
      ; # window is not already up
    }
  }
  update; # make sure changes are processed
  return
}


## update all active state viewer windows
proc updateStateViewerWindows { } {
  global g_NM_statePropsRootWindow pirNode 

  foreach stateWindow [winfo children $g_NM_statePropsRootWindow] {
    set updateP 1
    set index [string last "." $stateWindow]
    set nodeInstanceName [string range $stateWindow [expr {$index + 1}] end]
    # convert test_node to test.node
    regsub -all "_" $nodeInstanceName "." tmp; set nodeInstanceName $tmp
    getComponentModulePirNodeIndex $nodeInstanceName pirNodeIndex nodeClassType
    set stateViewerCall [assoc stateViewerProc pirNode($pirNodeIndex)]
    set window [assoc window pirNode($pirNodeIndex)]
    lappend stateViewerCall $window $pirNodeIndex $nodeClassType $updateP
    eval $stateViewerCall
    raise $stateWindow 
  }
}


## test changing component state
## 09oct95 wmt: new
## 05mar96 wmt: correct bug
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
proc testComponentStateChange {} {
  global pirDisplay pirNode 
  global g_NM_moduleGroupsUpdatedSinceReset

  set nodeLabelList {}; set newNodeState {}; set selectionList {}
  set nodes [assoc selectedNodes pirDisplay]
  if {[llength $nodes] == 0} {
    set dialogList [list tk_dialog .d "ERROR" "select one or more components first" \
                        error 0 {DISMISS}]
    eval $dialogList
    return
  }
  foreach node $nodes {
    set alist $pirNode($node)
    set nodeClassType [assoc nodeClassType pirNode($node)]
    if {[string match $nodeClassType "component"]} {
      lappend nodeLabelList [assoc nodeInstanceName alist]
    }
  }
  if {[llength $nodeLabelList] == 0} {
    set dialogList [list tk_dialog .d "ERROR" "no components selected" error \
        0 {DISMISS}]
    eval $dialogList
    return
  }    
  set dialog [list tk_dialog .d "select" "component name --" "" -1]
  set labelIndex [eval [concat $dialog $nodeLabelList]]
  set nodeLabelToChange [lindex $nodeLabelList $labelIndex]
  set pirNodeIndex [lindex $nodes $labelIndex]
  set alist $pirNode($pirNodeIndex)
  if {[string match [assoc nodeInstanceName alist] $nodeLabelToChange]} {
    set nodeClassName [assoc nodeClassName alist]
    set nodeClassType [assoc nodeClassType alist]
    set internalVars [getClass $nodeClassType $nodeClassName]
    set classVars [assoc class_variables internalVars]
    set okModesList [getClassVarDefaultValue ok_modes classVars]
    set faultModesList [getClassVarDefaultValue fault_modes classVars]
    set dialog [list tk_dialog .d "select" "type of mode --" "" -1]
    if {[llength $okModesList] > 0} {
      lappend selectionList ok-mode
    }
    if {[llength $faultModesList] > 0} {
      lappend selectionList fault-mode
    }
    lappend selectionList cancel
    foreach item $selectionList {
      append dialog " \{${item}\} "
    }
    ## puts stderr "testComponentStateChange dialog $dialog"
    set dialogIndex [eval $dialog]
    if {[string match [lindex $selectionList $dialogIndex] "ok-mode"]} {
      set dialog [list tk_dialog .d "select" "an ok mode --" "" -1]
      set okModeIndex [eval [concat $dialog $okModesList]]
      set newNodeState [lindex $okModesList $okModeIndex]
    } elseif {[string match [lindex $selectionList $dialogIndex] "fault-mode"]} {
      set dialog [list tk_dialog .d "select" "a fault mode --" "" -1]
      set faultModeIndex [eval [concat $dialog $faultModesList]]
      set newNodeState [lindex $faultModesList $faultModeIndex]
    }
  }
  if {[string length $newNodeState] != 0} {
    arepl nodeState $newNodeState pirNode($pirNodeIndex)
    set updateBGColorP 1
    set nodeGroupName [assoc nodeGroupName pirNode($pirNodeIndex)]
    if {[lsearch -exact $g_NM_moduleGroupsUpdatedSinceReset \
             $nodeGroupName] == -1} {
      lappend g_NM_moduleGroupsUpdatedSinceReset $nodeGroupName
    }
    componentModeChange $pirNodeIndex $nodeLabelToChange $updateBGColorP
  }
}

## change component state for tuple packet interface
## 09oct95 wmt: new
## 24oct95 wmt: if newNodeState = OK and component has OK as
##              an okMode, change to that mode
## 05dec95 wmt: add  state_color_config updating
## 05mar96 wmt: add state pop-up window updating
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 20mar96 wmt: use g_NM_instanceToNode instead of looping thru
##              pirNodes to find node struct for nodeLabelToChange
## 10jun96 wmt: add call to updateParentModuleBGColors
## 28jun96 wmt: remove check for "OK" $newNodeState - parseNewNodeState takes
##              care of it now
## 25jul96 wmt: revise handling to reflect R2S3 MIR Problem Statement
## 27aug96 wmt: ACS-MODE-A => ACS-A
## 03dec96 wmt: add g_NM_acsModeRCSDVStatus g_NM_acsModeSRUACQStatus
##              & g_NM_acsModeIDLEStatus
## 03jan97 wmt: add optional arg updateBGColorP
## 08jan97 wmt: update component properties window, if displayed
## 10mar98 wmt: name changed from componentStateChange to componentModeChange 
##              proposition stuff moved to componentModulePropChange
proc componentModeChange { pirNodeIndex nodeInstanceName { updateBGColorP 0 } } {
  global pirNode pirActiveFamilyName pirDisplay pirNode
  global g_NM_statePropsRootWindow g_NM_propsWarnMsgsP 
  global g_NM_defaultDisplayState
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset 
  global g_NM_componentPropsRootWindow g_NM_canvasRootIdCnt

  set alist $pirNode($pirNodeIndex)
  set reportNotFoundP 0
  set nodeState [assoc nodeState pirNode($pirNodeIndex)]
  set tmpNodeInstanceName $nodeInstanceName 
  # puts "componentModeChange nodeInstanceName $nodeInstanceName nodeState $nodeState"
  if {([string match $nodeState "parent-link"]) || \
      ([string match $nodeState "NIL"])} {
    # this is a defmodule or a parent link
    return
  }
  if {$g_NM_propsWarnMsgsP} {
    if {[string match $nodeInstanceName "ACS-A"]} {
      set nodePropList [assoc nodePropList pirNode($pirNodeIndex)]
      set controlHealthStatus [assoc-exact $nodeState nodePropList $reportNotFoundP]
      if {[string match $controlHealthStatus ""]} {
        set controlHealthStatus $g_NM_defaultDisplayState
      }
      puts stderr [format "%-38s %-23s %-12s" \
                       $tmpNodeInstanceName $nodeState $controlHealthStatus]
    } else {
      # puts stderr [format "%-38s %-23s %-12s %-3s" \
                #     $tmpNodeInstanceName $nodeState $nodeHealthState $nodePower]
      puts stderr [format "%-38s %-23s" \
                       $tmpNodeInstanceName $nodeState]
    }
  }
  # change node state in defcomponent modes
  changeDefcomponentState $pirNodeIndex "update" $nodeState

  # change node mode in component state window, if exists
  set stateWindow $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
  if {[winfo exists $stateWindow]} {
    set updateP 1
    set stateViewerCall [assoc stateViewerProc pirNode($pirNodeIndex)]
    lappend stateViewerCall [assoc window pirNode($pirNodeIndex)] $pirNodeIndex \
        [assoc nodeClassType pirNode($pirNodeIndex)] $updateP 
    eval $stateViewerCall
    raise $stateWindow 
  }
}


## respond to component & module proposition changes
proc componentModulePropChange { pirNodeIndex nodeInstanceName propNameListRef \
                                   fullUpdateP } {
  upvar $propNameListRef propNameList
  global pirNode pirActiveFamilyName pirDisplay pirNode pirEdge 
  global g_NM_statePropsRootWindow g_NM_paletteStructureList
  global g_NM_defaultDisplayState
  global g_NM_propsTerminalConnectionsSet
  global g_NM_showModeInstances 


  set reportNotFoundP 0; set oldvalMustExistP 0
  set nodeState [assoc nodeState pirNode($pirNodeIndex)]
  set tmpNodeInstanceName $nodeInstanceName 
  # set str "componentModulePropChange: nodeInstanceName $nodeInstanceName"
  # puts stderr "$str pirNodeIndex $pirNodeIndex"
  if {[string match $nodeState "parent-link"]} {
    # this is a parent link
    return
  }
  # determine new background color
  set window [assoc window pirNode($pirNodeIndex)]
  set numInputs [assoc numInputs pirNode($pirNodeIndex)]
  set numOutputs [assoc numOutputs pirNode($pirNodeIndex)]
  set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  # for components/modules this color is determined by value of
  # the displayStatePropName proposition
  set nodeStateBgColor [getNodeStateBgColor $pirNodeIndex]
  arepl nodeStateBgColor $nodeStateBgColor pirNode($pirNodeIndex)

  node_config_all $window $pirNodeIndex $numInputs $numOutputs color

  # set str "componentModulePropChange: nodeClassType $nodeClassType"
  # puts stderr "$str nodeClassName $nodeClassName"
  # puts stderr "   propNameList $propNameList"
  set componentModuleTerminalP \
      [expr {[lsearch -exact [list component module terminal] \
                  [assoc nodeClassType pirNode($pirNodeIndex)]] >= 0}]
  set componentModuleP \
      [expr {[lsearch -exact [list component module] \
                  [assoc nodeClassType pirNode($pirNodeIndex)]] >= 0}]
          
  foreach propName $propNameList {
    set attList [assoc $propName g_NM_showModeInstances $reportNotFoundP]
    # modify component/module label based on dependent terminal
    if {(! [string match $attList ""]) && \
            [string match [assoc displayNode attList] $nodeInstanceName]} {
      set nodePropList [assoc nodePropList pirNode($pirNodeIndex)]
      set attList [assoc $propName nodePropList]
      modifyComponentModuleLabel $propName "update" [assoc value attList]
    }
    # color buttons and connections, if attaced to two colored buttons
#     # skip props which reference the nodeClassName - indicates the mode
#     set indx [string first "~" $propName]
#     set maybeClassName [string range $propName 1 [expr {$indx - 1}]]
#     if {(! $fullUpdateP) && $componentModuleTerminalP && \
#             (! [string match $nodeClassName $maybeClassName])} {
#       # color the terminal and connection of the proposition
#       set expndStructureP 0; set matchFoundP 0; set isAttributeP 0
#       if {$componentModuleP && \
#               [lsearch -exact [assoc attributes pirNode($pirNodeIndex)] \
#                    $propName] >= 0} {
#         set isAttributeP 1
#         # do nothing for attributes
#       } else {
#         set outputsAndInputs [concat [assoc outputs pirNode($pirNodeIndex)] \
#                                   [assoc inputs pirNode($pirNodeIndex)]]
#         # regexp does not work as expected if ()s are in the form, so
#         set propNameTest $propName
#         lispListToTcl propNameTest
#         for {set i 1} {$i < [llength $outputsAndInputs]} { incr i 2} {
#           set terminalForm [lindex $outputsAndInputs $i]
#           set termId [lindex $outputsAndInputs [expr {$i - 1}]]
#           set terminalName [assoc terminal_name terminalForm]
#           regsub -all " " $terminalName "~" tmp; set terminalName $tmp
#           # set str "componentModulePropChange: propName `$propName'"
#           # puts stderr "$str terminalName `$terminalName'"
#           # do regexp check rather than string match check to handle
#           # structure types, e.g.
#           # (z-coord (estimated-attitude sru-a)) => (estimated-attitude sru-a)
#           # [string match $terminalName $propName]
#           # However, regexp does no work as expected if ()s are in the form, so
#           lispListToTcl terminalName
#           if {[regexp -nocase $terminalName $propNameTest]} {
#             set matchFoundP 1
# #             set terminalType [getTerminalType $terminalForm]
# #             if {[lsearch -exact $g_NM_paletteStructureList \
# #                      $terminalType] >= 0} {
# #               # puts stderr "terminalType $terminalType"
# #               set expndStructureP 1
# #             }
#             break
#           }
#         }
#       }
#       if {! $matchFoundP} {
#         if {! $isAttributeP} {
#           set str "componentModulePropChange: terminal MATCH NOT FOUND"
#           puts stderr "$str for propName $propName"
#         }
#       } else {
#         # puts stderr "componentModulePropChange: termId $termId terminalForm $terminalForm"
#         if {[regexp -nocase "in" $termId]} {
#           set buttonLocation "in"; set edgesLocation To
#           set buttonStartIndex 2
#           set buttonDirection To; set buttonOtherDirection From
#         } else {
#           set buttonLocation "out"; set edgesLocation From
#           set buttonStartIndex 3
#           set buttonDirection From; set buttonOtherDirection To 
#         }
#         set buttonNum [string range $termId $buttonStartIndex end]
#         set window [assoc window pirNode($pirNodeIndex)]
#         set termButton "$window.$buttonLocation.b$buttonNum"
#         set edgeCanvasIdList {}; set pirEdgeIndexList {}
#         set buttonFoundDirection ""; set buttonFoundOtherDir ""
#         # look for multiple connections
#         foreach elist [assoc edges$edgesLocation pirNode($pirNodeIndex)] {
#           foreach pirEdgeIndex $elist {
#             set buttonFoundDirectionP 0
#             if {! [string match $pirEdgeIndex ""]} {
#               if {[string match [assoc button$buttonDirection pirEdge($pirEdgeIndex)] \
#                        $termButton]} {
#                 set buttonFoundDirection $buttonDirection
#                 set buttonFoundOtherDir $buttonOtherDirection
#                 set buttonFoundDirectionP 1
#               } elseif {[string match [assoc button$buttonOtherDirection \
#                                            pirEdge($pirEdgeIndex)] $termButton]} {
#                 set buttonFoundDirection $buttonOtherDirection
#                 set buttonFoundOtherDir $buttonDirection
#                 set buttonFoundDirectionP 1
#               }
#               if {$buttonFoundDirectionP} {
#                 lappend edgeCanvasIdList [assoc canvasId pirEdge($pirEdgeIndex)]
#                 lappend pirEdgeIndexList $pirEdgeIndex
#               }
#             }
#           }
#         }
#         # note that some buttons have no edges connected
#         # set str "componentModulePropChange: pirNodeIndex $pirNodeIndex termButton"
#         # set str "$str $termButton edgeCanvasIdList $edgeCanvasIdList"
#         # set str "$str pirEdgeIndexList $pirEdgeIndexList"
#         # set str "$str buttonDirection $buttonDirection $buttonFoundDirection"
#         # puts stderr "$str buttonOtherDirection $buttonOtherDirection $buttonFoundOtherDir"

#         # color button 
#         $termButton configure -fg [preferred NM_propsTerminalConnectionColor]

#         if {[llength $edgeCanvasIdList] > 0} {
#           # color connections, if they exist, and if both buttons are set by
#           # propositions
#           foreach edgeCanvasId $edgeCanvasIdList pirEdgeIndex $pirEdgeIndexList {
#             arepl button${buttonFoundDirection}PropSelP 1 pirEdge($pirEdgeIndex) \
#                 $reportNotFoundP $oldvalMustExistP
#             # set otherTermP [assoc button${buttonFoundOtherDir}PropSelP \
#             #                     pirEdge($pirEdgeIndex) $reportNotFoundP]
#             # puts stderr "componentModulePropChange: otherTermP $otherTermP"
#             if {! [string match [assoc button${buttonFoundOtherDir}PropSelP \
#                                      pirEdge($pirEdgeIndex) $reportNotFoundP] ""]} {
#               set canvas [getCanvasFromButton $termButton] 
#               $canvas itemconfigure $edgeCanvasId \
#                   -fill [preferred NM_propsTerminalConnectionColor] 
#               # in case it is under other edges
#               $canvas raise $edgeCanvasId
#               # mark pirEdgeIndex for deselectEdge
#               arepl propSelectedP 1 pirEdge($pirEdgeIndex) $reportNotFoundP \
#                   $oldvalMustExistP 
#               lappend g_NM_propsTerminalConnectionsSet [list $termButton $edgeCanvasId \
#                                                             $pirEdgeIndex]
#             } else {
#               lappend g_NM_propsTerminalConnectionsSet [list $termButton 0 0] 
#             }
#           }
#         } else {
#           lappend g_NM_propsTerminalConnectionsSet [list $termButton 0 0]
#         }
#       }
#     }
  }
  # puts stderr "   g_NM_propsTerminalConnectionsSet $g_NM_propsTerminalConnectionsSet"
}


## reset any terminals/connections highlighted by receiving their propositions
## 23jan99 wmt: new
proc resetTerminalsConnectionsPropHilits { } {
  global pirEdge pirEdges g_NM_propsTerminalConnectionsSet 

  set reportNotFoundP 0
  foreach triple $g_NM_propsTerminalConnectionsSet {
    set termButton [lindex $triple 0]
    $termButton configure -fg [preferred StanleyNodeLabelForegroundColor]
    # puts stderr "resetTerminalsConnectionsPropHilits: termButton $termButton"
    set edgeCanvasId [lindex $triple 1]
    set pirEdgeIndex [lindex $triple 2] 
    # check if all edges have been redrawn by Edit->Preferences
    # and propposition highlight information has been lost
    if {([lsearch -exact $pirEdges $pirEdgeIndex] >= 0) && \
            ($edgeCanvasId > 0)} {
      [getCanvasFromButton $termButton] itemconfigure $edgeCanvasId \
          -fill [preferred StanleyNodeConnectionBgColor]
      adel propSelectedP pirEdge($pirEdgeIndex) $reportNotFoundP 
      adel buttonFromPropSelP pirEdge($pirEdgeIndex) $reportNotFoundP
      adel buttonToPropSelP pirEdge($pirEdgeIndex) $reportNotFoundP
    }
  }
  set g_NM_propsTerminalConnectionsSet {}
}


## reset all components to initial states
## 10oct95 wmt: new
## 19mar96 wmt: add pirClass - to contain common info of pirNode instances
## 17jun96 wmt: reset defmodule nodes as well
## 28jun96 wmt: add special processing for component acs-mode-a
## 25jul96 wmt: revise handing to reflect R2S3 MIR Problem Statement
## 27aug96 wmt: ACS-MODE-A => ACS-A
## 03dec96 wmt: add g_NM_acsModeRCSDVStatus g_NM_acsModeSRUACQStatus
##              & g_NM_acsModeIDLEStatus
## 13dec96 wmt: revise to speed up; do not call parseNewNodeState;
##              only process g_NM_componentToNode, rather than pirNodes;
##              only reset values that can be changed by parseMIRtelemetryMessage
## 08jan97 wmt: reset props windows
## 22jul97 wmt: use classVars initial_mode, rather than 
##              g_NM_defaultComponentClassMode 
## 22jan97 wmt: reset modes & power states to unknown. Rely on
##              MIR_TELEMETRY to set initial states
proc resetComponents { modeFlag canvasRootId } {
  global pirNodes pirNode pirActiveFamilyName pirDisplay
  global g_NM_powerMaxAvailable pirNode pirEdges 
  global g_NM_xWindowMgrOffset g_NM_yWindowMgrOffset
  global g_NM_statePropsRootWindow pirFileInfo
  global g_NM_currentNodeGroup g_NM_componentFaultDialogRoot
  global g_NM_componentToNode g_NM_canvasRootIdCnt
  global g_NM_componentPropsRootWindow g_NM_defaultDisplayState
  global g_NM_moduleGroupsUpdatedSinceReset g_NM_firstTelemP
  global g_NM_moduleToNode g_NM_rootInstanceName pirEdge 
  global g_NM_notComponentModuleList g_NM_notModuleList 
  global g_NM_propositionToNode g_NM_inhibitPirWarningP
  global goodPropCnt badPropCnt nextPropCnt unknownPropCnt
  global g_NM_componentFaultIndexList g_NM_win32P
  global g_NM_propValuesCount g_NM_propValuesArray
  global g_NM_instanceToNode g_NM_packetTimeTagsList
  global g_NM_showModeInstances g_NM_groundRefTime

  set goodPropCnt 0; set badPropCnt 0; set nextPropCnt 0
  set unknownPropCnt 0; set reportNotFoundP 0
  set oldvalMustExistP 0
  if {$g_NM_win32P} {
    .master.canvas config -cursor watch 
  } else {
    .master.canvas config -cursor { watch red yellow }
  }
  set severity 1; set msg2 ""
  pirWarning [format {Please Wait: %s schematic being reset --} \
      [workname $pirFileInfo(filename)]] $msg2 $severity
  set g_NM_inhibitPirWarningP 1
  update

  # reset proposition telemetry - init values set by resetPropostionList 
  set g_NM_propValuesCount 0
  catch { unset g_NM_propValuesArray }
  set g_NM_propValuesArray(0) 1
  catch { unset g_NM_propositionToNode }
  set g_NM_propositionToNode(0) 1
  set g_NM_packetTimeTagsList {}
  set g_NM_groundRefTime 0

#   if {[string match $modeFlag "reset"]} {
#     resetTerminalsConnectionsPropHilits
#   }

  foreach element [array names g_NM_componentToNode] {
    if {[string match $element 0]} { continue }
    set pirNodeIndex $g_NM_componentToNode($element)
    set pirNodeAList $pirNode($pirNodeIndex)
    set nodeClassName [assoc nodeClassName pirNodeAList]
    set nodeClassType [assoc nodeClassType pirNodeAList]
    set classVars [getClassValue $nodeClassType $nodeClassName class_variables]
    # set defaultComponentMode [getClassVarDefaultValue initial_mode classVars]
    set defaultComponentMode $g_NM_defaultDisplayState
    set nodeInstanceName [assoc nodeInstanceName pirNodeAList]
    # change colors and mode (state)
    arepl nodeState $g_NM_defaultDisplayState pirNode($pirNodeIndex)

    resetPropostionList $pirNodeIndex 

    arepl nodeStateBgColor [preferred StanleyNodataStateBgColor] pirNode($pirNodeIndex)

    set numInputs [assoc numInputs pirNodeAList] 
    set numOutputs [assoc numOutputs pirNodeAList]
    set masterWindow [assoc window pirNodeAList] 

    node_config_all $masterWindow $pirNodeIndex $numInputs $numOutputs color

    # change node state in defcomponent modes
    # reset display label and highlighting of top level components/modules
    changeDefcomponentState $pirNodeIndex $modeFlag 

    # change node state & props in mode window, if exists
    set stateWindow $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
    if {[winfo exists $stateWindow]} {
      set stateViewerCall [assoc stateViewerProc pirNodeAList]
      lappend stateViewerCall $masterWindow $pirNodeIndex $nodeClassType 
      eval $stateViewerCall
      update
    }
    # if displayStateProc does not exist, create from displayState attribute
    generateDisplayStateProc $pirNodeIndex 
  }

  foreach element [array names g_NM_moduleToNode] {
    if {[string match $element 0]} { continue }
    set pirNodeIndex $g_NM_moduleToNode($element)
    set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
    set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)] 
    if {(! [string match [assoc nodeState pirNode($pirNodeIndex)] \
               "parent-link"]) && \
            (! [string match $nodeInstanceName $g_NM_rootInstanceName])} {
      set pirNodeAList $pirNode($pirNodeIndex)
      set nodeClassType [assoc nodeClassType pirNodeAList]

      resetPropostionList $pirNodeIndex 

      arepl nodeStateBgColor [preferred StanleyNodataStateBgColor] \
          pirNode($pirNodeIndex)

      set numInputs [assoc numInputs pirNodeAList] 
      set numOutputs [assoc numOutputs pirNodeAList]
      set masterWindow [assoc window pirNodeAList] 

      node_config_all $masterWindow $pirNodeIndex $numInputs $numOutputs color

      # change node state & props in mode window, if exists
      set stateWindow $g_NM_statePropsRootWindow.[getTclPathNodeName $nodeInstanceName]
      if {[winfo exists $stateWindow]} {
        set stateViewerCall [assoc stateViewerProc pirNodeAList]
        lappend stateViewerCall $masterWindow $pirNodeIndex $nodeClassType 
        eval $stateViewerCall
        update
      }
      # if displayStateProc does not exist, create from displayState attribute
      generateDisplayStateProc $pirNodeIndex 
    }
  }
  # add terminal nodes to g_NM_propositionToNode lists
  # note that for structrured types, all its slots are entries
  # in g_NM_instanceToNode -- therefore, use pirNodes
  foreach pirNodeIndex $pirNodes {
    set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
    if {[string match $nodeClassType "terminal"]} {
      set nodeClassName [assoc nodeClassName pirNode($pirNodeIndex)]
      if {(! [regexp "declaration" $nodeClassName])} {
        resetPropostionList $pirNodeIndex
      }
    }
  }

  set g_NM_notComponentModuleList {}
  set g_NM_notModuleList {}
  set  g_NM_componentFaultIndexList {}
  if {[string match $modeFlag "reset"]} {
    if {[winfo exists $g_NM_componentFaultDialogRoot]} {
      set autoCallP 1
      showComponentFaultList $canvasRootId $autoCallP 
    }
  }

  # updatePowerAvailable $g_NM_powerMaxAvailable

#   not used any more 03mar98
#   if {[string match $modeFlag init]} {
#     initDefmoduleStates "init" {}
#   } elseif {[string match $modeFlag reset]} {
#     initDefmoduleStates "reset" g_NM_moduleGroupsUpdatedSinceReset
#   } else {
#     error "resetComponents: modeFlag $modeFlag not handled\!"
#   }

  .master.canvas config -cursor top_left_arrow
  set g_NM_inhibitPirWarningP 0
  standardMouseClickMsg
  update;   # make sure changes are processed
  set g_NM_moduleGroupsUpdatedSinceReset {}
  set g_NM_firstTelemP 1;  # output log msg header again
  puts stderr "\nRESET Complete \n"
}
 

## print telemetry header
## 12sep97 wmt: new
proc printTelemetryHeader { } {

  puts stderr \
      "\n<DEVICE>                               <MODE>                  <SUB MODE>"
  #      1234567890123456789012345678901234567890123456789012345678901234567890
  #               1         2         3         4         5         6         7
  puts stderr \
      "<PROP ATTR>                                                      <VALUE>"
  #    1234567890123456789012345678901234567890123456789012345678901234567890
  #             1         2         3         4         5         6         7
  puts stderr \
      "-------------------------------------------------------------------------------"
}


## notify user of components/modules with default display-state 
## 25feb97 wmt: new
proc showNodesWithDefaultDisplayState { } {
  global g_NM_nodeGroupToInstances g_NM_componentToNode
  global g_NM_moduleToNode pirNode g_NM_rootInstanceName
  global g_NM_defaultDisplayState

  set componentList {}; set moduleList {}; set reportNotFoundP 0
  foreach element [array names g_NM_nodeGroupToInstances] {
    if {[string match $element 0]} { continue }
    set nodeGroupName $g_NM_nodeGroupToInstances($element)
    if {(! [string match $nodeGroupName root]) && \
            (! [string match $nodeGroupName $g_NM_rootInstanceName])} {
      set nodeGroupPirNodeIndex [assoc-array $nodeGroupName g_NM_componentToNode \
                                     $reportNotFoundP]
      set nodeGroupType component
      if {[string match $nodeGroupPirNodeIndex ""]} {
        set nodeGroupPirNodeIndex [assoc-array $nodeGroupName g_NM_moduleToNode]
        set nodeGroupType module
      }
      if {! [string match $nodeGroupPirNodeIndex ""]} {
        set nodeClassName [assoc nodeClassName pirNode($nodeGroupPirNodeIndex)]
        set nodeInstanceName [assoc nodeInstanceName \
                                  pirNode($nodeGroupPirNodeIndex)]
        # set str "showNodesWithDefaultDisplayState: nodeGroupName $nodeGroupName"
        # puts stderr "$str nodeClassName $nodeClassName nodeInstanceName $nodeInstanceName"
        set displayStatePirNodeIndex [getDisplayStatePirNodeIndex \
                                          $nodeGroupName]
        set defaultStateP 0
        if {$displayStatePirNodeIndex == 0} {
          set defaultStateP 1; set facts ""
        } else {
          set facts [assoc facts pirNode($displayStatePirNodeIndex)]
          if {[regexp "\\\($g_NM_defaultDisplayState" $facts]} {
            set defaultStateP 1
          }
        }
        # set str "showNodesWithDefaultDisplayState: displayStatePirNodeIndex"
        # set str "$str $displayStatePirNodeIndex facts $facts g_NM_defaultDisplayState"
        # puts stderr "$str $g_NM_defaultDisplayState defaultStateP $defaultStateP"
        if {$defaultStateP} {
          if {[string match $nodeGroupType component]} {
            lappend componentList $nodeInstanceName
          } else {
            lappend moduleList $nodeInstanceName
          }
        }
      }
    }
  }
  if {([llength $componentList] > 0) || ([llength $moduleList] > 0)} {
    set firstComp 1; set firstMod 1
    set textString "These instances will always show the"
    append textString " $g_NM_defaultDisplayState state:\n\n"
    append textString "components =>"
    foreach component $componentList {
      if {$firstComp} {
        set firstComp 0
      } else {
        append textString ","
      }
      append textString " $component"
    }
    append textString "\n\nmodules =>"
    foreach module $moduleList {
      if {$firstMod} {
        set firstMod 0
      } else {
        append textString ","
      }
      append textString " $module"
    }
    puts stderr "showNodesWithDefaultDisplayState: components => $componentList"
    puts stderr "showNodesWithDefaultDisplayState: modules => $moduleList"
    set titleString "WARNING: $g_NM_defaultDisplayState state"
    append titleString " instances"
    adviseUser $titleString $textString
  }
}


## Change current mode to newNodeState -- if
## none supplied, set to default
## 20aug97 wmt: new
proc changeDefcomponentState { pirNodeIndex modeFlag { newNodeState "" } } {
  global pirNode g_NM_nodeGroupToInstances
  global g_NM_canvasRootIdCnt g_NM_componentFaultIndexList
  global g_NM_showModeInstances 

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "changeDefcomponentState: `$backtrace'"

  # puts stderr "\nchangeDefcomponentState: pirNodeIndex $pirNodeIndex modeFlag $modeFlag"
  set reportNotFoundP 0
  set nodeGroupName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)]
  set nodeGroupAlist [assoc-array $nodeGroupName g_NM_nodeGroupToInstances]
  if {[string match $newNodeState ""]} {
    set pirClassIndex [assoc nodeClassName pirNode($pirNodeIndex)]
    set classVars [getClassValue $nodeClassType $pirClassIndex class_variables]
    set newNodeState [getClassVarDefaultValue mode classVars]
  }
  set unselectedColor [preferred StanleyNonCurrentModeBgColor]
  set nodeHealthState ""; set nodeState {}
  # reset colors in pirNodes
  foreach nodeIndex [alist-values nodeGroupAlist] {
    set nodeClassType [assoc nodeClassType pirNode($nodeIndex)]
    if {[string match $nodeClassType "mode"]} {
      set nodeClassName [assoc nodeClassName pirNode($nodeIndex)] 
      set modeName [getComponentModeLabel [assoc nodeInstanceName \
                                               pirNode($nodeIndex)]]
      set currBGColor [assoc nodeStateBgColor pirNode($nodeIndex)] 
      # puts stderr "changeDefcomponentState: modeName $modeName newNodeState $newNodeState"
      # puts stderr "    currBGColor $currBGColor unselectedColor $unselectedColor"
      if {[string match $modeFlag "update"]} {
        if {[string match $modeName $newNodeState]} {
          if {($nodeClassName == "faultMode") && \
                  ([lsearch -exact $g_NM_componentFaultIndexList $nodeIndex] == -1)} {
            # add to fault list
            # puts stderr "    add $nodeIndex"
            lappend g_NM_componentFaultIndexList $nodeIndex 
          }
          set nodeStateBgColor [getNodeStateBgColor $nodeIndex]
          # puts stderr "    nodeStateBgColor $nodeStateBgColor"
        } else {
          # new mode is not this mode
          if {($nodeClassName == "faultMode") && \
                  ([lsearch -exact $g_NM_componentFaultIndexList $nodeIndex] >= 0)} {
            # remove from fault list
            # puts stderr "    remove $nodeIndex"
            lremove g_NM_componentFaultIndexList $nodeIndex 
          }
          set nodeStateBgColor $unselectedColor 
        }
        arepl nodeStateBgColor $nodeStateBgColor pirNode($nodeIndex)
      } else {
        # modeFlag = init or reset
        if {! [string match $currBGColor $unselectedColor]} {
          # puts stderr "    init or reset -- set nodeStateBgColor to $unselectedColor"
          arepl nodeStateBgColor $unselectedColor pirNode($nodeIndex)
        }
      }
    }
  }
  # change display label and highlighting of top level components/modules
  # based on descendent modes
  if {! [string match [assoc $nodeGroupName g_NM_showModeInstances $reportNotFoundP] \
             ""]} {
    modifyComponentModuleLabel $nodeGroupName $modeFlag $newNodeState 
  }
  # update the windows
  set numInputs 0; set numOutputs 0
  foreach nodeIndex [alist-values nodeGroupAlist] {
    set nodeClassType [assoc nodeClassType pirNode($nodeIndex)]
    if {[string match $nodeClassType "mode"]} {
      set masterWindow [assoc window pirNode($nodeIndex)]

      node_config_all $masterWindow $nodeIndex $numInputs $numOutputs color
    }
  }
}


## add the names of all nodes of nodeClassType terminal or attribute
## to nodePropList; and set values for g_NM_propositionToNode which
## handles the incoming propositions
## 09mar98 wmt: new
proc resetPropostionList { pirNodeIndex } {
  global pirNode g_NM_propositionToNode g_NM_instanceToNode 
  global g_NM_paletteStructureList pirClassesComponent pirClassComponent 
  global g_NM_propValuesArray pirClassesModule pirClassModule
  global g_NM_paletteDefvalueList
  global g_NM_paletteStructureList g_NM_defaultDisplayState 

  set reportNotFoundP 0; set silentP 1
  set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)]
  set nodeClassType [assoc nodeClassType pirNode($pirNodeIndex)] 
#   if {$nodeInstanceName == "test.emaController1"} {
#     puts stderr "\n\nresetPropostionList: pirNodeIndex $pirNodeIndex nodeInstanceName $nodeInstanceName"
#   }
  set pirNodeAlist $pirNode($pirNodeIndex)
  set nodeLabelName [getDisplayLabel pirNodeAlist labelP]
  set pirNodeAList $pirNode($pirNodeIndex)
  set propNameList {}; set nodePropList {}; set propExpndStructPList {}
  if {! [string match $nodeClassType "terminal"]} {
    # puts stderr "\nresetPropostionList: nodeClassType $nodeClassType nodeInstanceName $nodeInstanceName pirNodeIndex $pirNodeIndex "

    if {($nodeClassType == "component") || ($nodeClassType == "module")} {
      # parameter variables which are not component/module class names
      set pirClassIndex [assoc nodeClassName pirNode($pirNodeIndex)]
      if {$nodeClassType == "component"} {
        set classList $pirClassesComponent
      } else {
        set classList $pirClassesModule
      }
      if {[lsearch -exact $classList $pirClassIndex] == -1} {
        read_workspace $nodeClassType $pirClassIndex $silentP
      }
      if {$nodeClassType == "component"} {
        set classVars [assoc class_variables pirClassComponent($pirClassIndex)]
      } else {
        set classVars [assoc class_variables pirClassModule($pirClassIndex)]
      }
      set nodeInstanceName [assoc nodeInstanceName pirNode($pirNodeIndex)] 
      set argsList [getClassVarDefaultValue args classVars]
      set argTypesList [getClassVarDefaultValue argTypes classVars]
      foreach arg $argsList argType $argTypesList {
        if {(([lsearch -exact $g_NM_paletteDefvalueList $argType] >= 0) || \
                 ([lsearch -exact $g_NM_paletteStructureList $argType] >= 0)) && \
                (! [structIsTerminalTypeParamP $argType])} {
          # do not put parameterized terminal types in propNameList
          convertQMarkVarsForMPL arg
          set propNameList [concat $propNameList \
                                [expandStructurePropNames "${nodeInstanceName}.$arg" \
                                     $argType expndStructPList]]
          set propExpndStructPList [concat $propExpndStructPList \
                                        $expndStructPList]
        }
      }
    }
    # puts stderr "resetPropostionList: propNameList $propNameList"
    # puts stderr "                     propExpndStructPList $propExpndStructPList"
    # attributes include displayState which is not determined by L2
    # it is done internally by Stanley
    set attPropNames [assoc attributes pirNode($pirNodeIndex)]
    if {[llength $attPropNames] > 0} {
      foreach propName $attPropNames {
        set attributeNodeIndex [assoc-array $propName g_NM_instanceToNode]
        set terminalForm [lindex [assoc outputs pirNode($attributeNodeIndex)] 1]
        set terminalName [assoc terminal_name terminalForm]
        set terminalType [getTerminalType $terminalForm]
        set propNameList [concat $propNameList \
                              [expandStructurePropNames $terminalName \
                                   $terminalType expndStructPList]]
        set propExpndStructPList [concat $propExpndStructPList \
                                      $expndStructPList]
      }
    }

    # nodeClassType == module is computed below by getInheritedPropositions
    if {$nodeClassType == "component"} {
      # need both inputs and outputs since user may have moved terminals
      set inputsAndOutputs [concat [assoc inputs  pirNode($pirNodeIndex)] \
                                [assoc outputs  pirNode($pirNodeIndex)]]
      set inputPropNames [assoc input_terminals pirNode($pirNodeIndex)]
      #     if {$nodeInstanceName == "test.emaController1"} {
      #        puts stderr "inputPropNames $inputPropNames"
      #     }
      if {[llength $inputPropNames] > 0} {
        foreach propName $inputPropNames {
          # no input declarations
          if {(! [regexp "\\\&ID" $propName])} {
            #           if {$nodeInstanceName == "test.emaController1"} {
            #             puts stderr "resetPropostionList: IN propName $propName"
            #           }
            # check for structure type, rather than defvalues type
            set matchFoundP 0
            for {set i 1} {$i < [llength $inputsAndOutputs]} { incr i 2} {
              set terminalForm [lindex $inputsAndOutputs $i]
              set terminalName [assoc terminal_name terminalForm]
              #             if {$nodeInstanceName == "test.emaController1"} {
              #               puts stderr "terminalName $terminalName propName $propName "
              #             }
              if {[string match $terminalName $propName]} {
                set matchFoundP 1
                set terminalType [getTerminalType $terminalForm]
                set propNameList [concat $propNameList \
                                      [expandStructurePropNames $terminalName \
                                           $terminalType expndStructPList]]
                set propExpndStructPList [concat $propExpndStructPList \
                                              $expndStructPList]
                break
              }
            }
            if {! $matchFoundP} {
              puts stderr "resetPropostionList: MATCH NOT FOUND for input propName $propName"
              puts stderr "   nodeInstanceName $nodeInstanceName"
            }
          }
        }
      }

      # need both inputs and outputs since user may have moved terminals
      set outputsAndInputs [concat [assoc outputs  pirNode($pirNodeIndex)] \
                                [assoc inputs  pirNode($pirNodeIndex)]]
      set outputPropNames [assoc output_terminals pirNode($pirNodeIndex)]
      #   if {($pirNodeIndex == 427) || ($pirNodeIndex == 434)} {
      #     puts stderr "outputPropNames $outputPropNames"
      #   }
      if {[llength $outputPropNames] > 0} {
        foreach propName $outputPropNames {
          # no output declarations
          if {(! [regexp "\\\&OD" $propName])} {
            # check for structure type, rather than defvalues type
            set matchFoundP 0
            for {set i 1} {$i < [llength $outputsAndInputs]} { incr i 2} {
              set terminalForm [lindex $outputsAndInputs $i]
              set terminalName [assoc terminal_name terminalForm]
              # puts stderr "resetPropostionList: OUT propName $propName terminalName $terminalName"
              if {[string match $terminalName $propName]} {
                set matchFoundP 1
                set terminalType [getTerminalType $terminalForm]
                set propNameList [concat $propNameList \
                                      [expandStructurePropNames $terminalName \
                                           $terminalType expndStructPList]]
                set propExpndStructPList [concat $propExpndStructPList \
                                              $expndStructPList]
                break
              }
            }
            if {! $matchFoundP} {
              puts stderr "resetPropostionList: MATCH NOT FOUND for output propName $propName"
              puts stderr "   nodeInstanceName $nodeInstanceName"
            }
          }
        }
      }

      set outputsAndInputs [concat [assoc outputs  pirNode($pirNodeIndex)] \
                                [assoc inputs  pirNode($pirNodeIndex)]]
      #   if {($pirNodeIndex == 427) || ($pirNodeIndex == 434)} {
      #     puts stderr "outputs [assoc outputs  pirNode($pirNodeIndex)]"
      #     puts stderr "inputs [assoc inputs  pirNode($pirNodeIndex)]"
      #   }
      set portPropNames [assoc port_terminals pirNode($pirNodeIndex)]
      if {[llength $portPropNames] > 0} {
        foreach propName $portPropNames {
          # no port declarations
          if {(! [regexp "\\\&PD" $propName])} {
            # check for structure type, rather than defvalues type
            set matchFoundP 0
            for {set i 1} {$i < [llength $outputsAndInputs]} { incr i 2} {
              set terminalForm [lindex $outputsAndInputs $i]
              set terminalName [assoc terminal_name terminalForm]
              if {[string match $terminalName $propName]} {
                set matchFoundP 1
                set terminalType [getTerminalType $terminalForm]
                set propNameList [concat $propNameList \
                                      [expandStructurePropNames $terminalName \
                                           $terminalType expndStructPList]]
                set propExpndStructPList [concat $propExpndStructPList \
                                              $expndStructPList]
                break
              }
            }
            if {! $matchFoundP} {
              puts stderr "resetPropostionList: MATCH NOT FOUND for port propName $propName"
            }
          }
        }
      }
    }
#     if {$nodeInstanceName == "test.emaController1"} {
#       puts stderr "resetPropostionList: nodeInstanceName $nodeInstanceName"
#       puts stderr "    propNameList $propNameList"
#     }
    # puts stderr "    propNameList $propNameList"
    # puts stderr "  pirNodeAlist $pirNodeAlist"
    if {[string match $nodeClassType "component"]} {
      set inheritedPropNameList {}
    } else {
      # check for inherited terminals which occur in inputs/outputs, not in
      # input_terminals/output_terminals/port_terminals
      set pirNodeAlist $pirNode($pirNodeIndex)
      set structPList {}
      set inheritedPropNameList [getInheritedPropositions pirNodeAlist]
    }
#     if {$nodeInstanceName == "test.emaController1"} {
#       puts stderr "     inheritedPropNameList $inheritedPropNameList"
#     }
#     foreach prop $propNameList {
#       set foundP 0
#       foreach pair $inheritedPropNameList {
#         set inheritProp [lindex $pair 0]
#         if {[string match $prop $inheritProp]} {
#           set foundP 1
#           break
#         }
#       }
#       if {! $foundP} {
#         puts stderr "not found in inherit list: $prop"
#       }
#     }

    # check for duplicates
    foreach pair $inheritedPropNameList {
      set prop [lindex $pair 0]
      if {[lsearch -exact $propNameList $prop] == -1} {
        lappend propNameList $prop
        lappend propExpndStructPList [lindex $pair 1]
      } else {
        puts stderr "resetPropostionList: nodeInstanceName $nodeInstanceName - DUP $prop"
      }
    }

    # if a component, add MPL "short" mode proposition (i.e. no arguments)
    # and L2 modeTransition proposition 
    set modePropName ""
    if {[string match $nodeClassType "component"]} {
      # modePropName is referenced below
      set modePropName "${nodeInstanceName}.mode"
      lappend propNameList $modePropName
      lappend propExpndStructPList 0
      lappend propNameList "${nodeInstanceName}.modeTransition" 
      lappend propExpndStructPList 0
    }
  } else {
    # handle nodeClassType = terminal
    set terminalType [getTerminalInstanceType $pirNodeIndex terminalForm]
    set terminalName [assoc terminal_name terminalForm]
    set propNameList [concat $propNameList \
                          [expandStructurePropNames $terminalName \
                               $terminalType expndStructPList]]
    set propExpndStructPList [concat $propExpndStructPList \
                                  $expndStructPList]
    set modePropName ""
    # puts stderr "resetPropostionList: terminalName $terminalName "
  }

#   if {[regexp "tk02" $nodeInstanceName]} {
#     puts stderr "resetPropostionList: nodeInstanceName $nodeInstanceName propNameList $propNameList"
#   }

  if {[llength $propNameList] != [llength $propExpndStructPList]} {
    puts stderr "propNameList $propNameList"
    puts stderr "propExpndStructPList $propExpndStructPList"
    error "resetPropostionList: mismatched lists"
  }
  if {! [string match $propNameList "{}"]} {
    for {set i 0} {$i < [llength $propNameList]} {incr i} {
      set propName [lindex $propNameList $i]
      if {! [string match $nodeClassType "terminal"]} {
        set expndStructureP [lindex $propExpndStructPList $i]
        if {[string match $propName $modePropName]} {
          set propLabel _mode_ 
        } else {
#           set propLabel [getPropositionDisplayLabel $propName $nodeInstanceName \
#                              $nodeLabelName $expndStructureP]
          # do this instead of getPropositionDisplayLabel for now
          set propLabel [getExternalNodeName $propName]
          # structure type propositions can be expanded from node instance name
          # pipeIn => pipeIn.pressure.sign
          if {[string match [assoc-array $propName g_NM_instanceToNode \
                                 $reportNotFoundP] ""]} {
            reduceStructurePropnameToRoot $propName terminalInstanceName \
                terminalNodeIndex 
            if {[string match $terminalNodeIndex ""]} {
              set str "resetPropostionList: reduced prop name $propName not"
              set str "$str found in g_NM_instanceToNode"
              puts stderr "$str terminalInstanceName $terminalInstanceName"
              # puts stderr "    [array names g_NM_instanceToNode]"
            } else {
              # puts stderr "resetPropostionList: propName $propName now in g_NM_instanceToNode"
              set g_NM_instanceToNode($propName) $terminalNodeIndex
            }
          }
        }
        lappend nodePropList $propName [list label $propLabel value \
                                            $g_NM_defaultDisplayState]
      }
      # fill proposition to node array for use by parseMPLPropAttrValList
      # tcl arrays are implemented as hash tables
      # array indices have ()s
      # since terminals can be inherited, their propositions can
      # occur in more than one component/module
      # tcl wraps {} around the array indices when displaying them
      # with array names
      # {THROW-STATE~MOD-TEST-A}  ==> {{THROW-STATE~MOD-TEST-A}}
      if [ catch { set g_NM_propositionToNode($propName) } ] {
        set g_NM_propositionToNode($propName) \
            [list pirNodeIndices $pirNodeIndex receivedPropP 0]
        set g_NM_propValuesArray($propName) [list $g_NM_defaultDisplayState]
      } else {
        set currentList $g_NM_propositionToNode($propName)
        set pirNodeIndices [assoc pirNodeIndices currentList]
        # structure slot propnames have the same pirIndex
        if {[lsearch -exact $pirNodeIndices $pirNodeIndex] == -1} {
          lappend pirNodeIndices $pirNodeIndex
          set g_NM_propositionToNode($propName) \
              [list pirNodeIndices $pirNodeIndices receivedPropP 0]
        }
      }
#       if {[regexp {temperature\.gradient} $propName]} {
#         puts stderr "resetPropostionList: propName $propName pirNodeIndex $pirNodeIndex"
#       }
    }
  }
  if {! [string match $nodeClassType "terminal"]} {
    arepl nodePropList $nodePropList pirNode($pirNodeIndex)
    # puts stderr "resetPropostionList: pirNodeIndex $pirNodeIndex nodePropList $nodePropList"
  }
}


## write file of proposition handlers not invoked
## 24aug98 wmt: new
## writeUnReceivedPropositions "$STANLEY_ROOT/user-template/unreceived-prop-attrs.log"
proc writeUnReceivedPropositions { pathname } {
  global g_NM_propositionToNode

  set fid [open $pathname w]
  foreach prop [array names g_NM_propositionToNode] {
    if {(! [regexp -nocase "color-state" $prop]) && \
            (! [regexp -nocase "display-state" $prop])} { 
      set currentList $g_NM_propositionToNode($prop)
      #puts stderr "writeUnhandledPropositions: prop $prop currentList $currentList"
      if {(! [string match $prop "0"]) && (! [assoc receivedPropP currentList])} {
        puts $fid $prop
      }
    }
  }
  close $fid
}


## list select propositions
## 22oct98 wmt: new
## listSelectedPropositions "cmd-in"
## 
proc listSelectedPropositions { pattern { replaceTildesP 1 } } {
  global g_NM_propositionToNode

  if {[regexp " " $pattern]} {
    error "listSelectedPropositions: pattern `$pattern' contains blank(s)"
  }
  set output {}
  foreach prop [array names g_NM_propositionToNode] {
    if {(! [regexp -nocase "color-state" $prop]) && \
            (! [regexp -nocase "display-state" $prop])} { 
      set currentList $g_NM_propositionToNode($prop)
      #puts stderr "listSelectedPropositions: prop $prop currentList $currentList"
      if {(! [string match $prop "0"]) && (! [assoc receivedPropP currentList]) && \
              [regexp -nocase -- $pattern $prop]} {
        if {$replaceTildesP} {
        }
        # puts stderr $prop
        lappend output $prop
      }
    }
  }
  return $output
}


## modify component/module labels based descendent component mode, or terminal
## 16mar99 wmt: new
proc modifyComponentModuleLabel { nodeInstanceName modeFlag { labelValue "" } } {
  global g_NM_showModeInstances g_NM_componentToNode 
  global pirNode 

  # puts stderr "modifyComponentModuleLabel: nodeInstanceName $nodeInstanceName"
  set canvasRootId 0
  set assocList [assoc $nodeInstanceName g_NM_showModeInstances]
  set displayNode [assoc displayNode assocList]
  getComponentModulePirNodeIndex $displayNode nodeIndex nodeClassType
  set window [assoc window pirNode($nodeIndex)]
  set instanceLabel [assoc instanceLabel pirNode($nodeIndex)]
  # puts stderr "componentModeChange: nodeInstanceName $nodeInstanceName modeFlag $modeFlag"
  # puts stderr "componentModeChange: displayNode $displayNode nodeIndex $nodeIndex"
  if {[string match $modeFlag "update"]} {
    set displayLabel [assoc displayLabel assocList]
    set labelFont [lindex [$window.lab.label configure -font] 4]
    set labelWidthPixels [font measure $labelFont " $instanceLabel "]
    if {[string match $nodeInstanceName ACS-A] || \
            [string match $nodeInstanceName (RCS-MODE~ACS-A)]} {
      # special handling for ACS & (RCS-MODE~ACS-A)
      # which provide labelValue for ACS-MODULE
      if {[string match $nodeInstanceName ACS-A]} {
        if {[string match $labelValue RCS]} {
          set pirNodeIndex [assoc-array (RCS-MODE~ACS-A) g_NM_componentToNode]
          append labelValue " - [assoc nodeState pirNode($pirNodeIndex)]"
        }
      } else {
        set pirNodeIndex [assoc-array ACS-A g_NM_componentToNode]
        if {[string match [assoc nodeState pirNode($pirNodeIndex)] RCS]} { 
          set labelValue "RCS - $labelValue"
        }
      }
    }
    set text " $displayLabel: $labelValue "
    # pad with blanks to keep label length the same -- which keeps the connections
    # properly lined up
    set cnt 0
    while {[font measure $labelFont $text] < $labelWidthPixels} {
      if {$cnt % 2} {
        set text " $text"
      } else {
        set text "$text "
      }
      # puts stderr "width $labelWidthPixels text `$text' new [font measure $labelFont $text]"
      incr cnt
    }
  } else {
    set text " $instanceLabel "
  }
  $window.lab.label configure -text $text
}


   










