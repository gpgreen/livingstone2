# $Id: debug.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

########################################################################### 
### debugging and profiling procs 
########################################################################### 

proc nodesToWindows { } {
  global pirNodes pirNode

  foreach node $pirNodes {
    puts "node $node window [assoc window pirNode($node)]"
  }
}


proc nodesToAttVals { attribute } {
  global pirNodes pirNode

  foreach node $pirNodes {
    puts [format {node %3d %s %s} $node $attribute \
              [assoc $attribute pirNode($node)]]
  }
}


proc nodesToNames { } {
  global pirNodes pirNode

  foreach node $pirNodes {
    set str "node $node nodeName [assoc nodeInstanceName pirNode($node)]"
    set str "$str \([assoc nodeClassName pirNode($node)]\)"
    set str "$str \([assoc nodeState pirNode($node)]\)"
    set parentNodeGroupList [assoc parentNodeGroupList pirNode($node)]
    set nodeGroupLevel [expr {[llength $parentNodeGroupList] - 1}]
    puts stderr "$str \(groupLevel $nodeGroupLevel\)"
  }
}


proc nodesToNodeGroup { } {
  global pirNodes pirNode

  foreach node $pirNodes {
    set str2 "nodesToNodeGroup: node $node parentNodeGroupList"
    puts stderr "$str2 [assoc parentNodeGroupList pirNode($node)]"
  }
}


proc edgesToNodeNames { } {
  global pirNode pirEdges pirEdge

  foreach edge $pirEdges {
    set nodeFrom [assoc nodeFrom pirEdge($edge)]
    set nodeTo [assoc nodeTo pirEdge($edge)]
    set buttonFrom [assoc buttonFrom pirEdge($edge)]
    set buttonTo [assoc buttonTo pirEdge($edge)]
    set nodeFromName [assoc nodeInstanceName pirNode($nodeFrom)]
    set nodeToName [assoc nodeInstanceName pirNode($nodeTo)]
    set str "edge $edge nodeFromName $nodeFromName ($nodeFrom) buttonFrom $buttonFrom"
    puts "$str nodeToName $nodeToName ($nodeTo) buttonTo $buttonTo"
  }
}


##  set backtrace ""; getBackTrace backtrace
##  puts stderr "checkFileModificationDates: `$backtrace'"

## pass "" as arg to this proc to get proc backtrace
proc getBackTrace { backTraceRef } {
  upvar $backTraceRef backTrace
  
  set startLevel [expr {[info level] - 2}]
  for {set level 1} {$level <= $startLevel} {incr level} {
    append backTrace "[lindex [info level $level] 0] => "
  }
}


# trace variable
# global traceValueOrig traceVarName 
# set traceValueOrig $g_NM_currentCanvas
# set traceVarName g_NM_currentCanvas 
# trace variable $traceVarName rwu tracePrint
# puts stderr "TRACE $traceVarName: $traceValueOrig" 

proc tracePrint { varname index operation } {
  upvar $varname var
  global traceValueOrig traceVarName 

  switch $operation {
    r { puts stderr "TRACE read $traceVarName: `$var'"
    }
    w { puts stderr "TRACE write $traceVarName: `$var'"
    }
    u { puts stderr "TRACE unset $traceVarName" }
  }
  set backtrace ""; getBackTrace backtrace
  puts stderr "     `$backtrace'"
}


##===================================PROFILING===========

## must link with Tcl X for this to work
proc profileOn { } {

  profile on
}


## put profile report in ~/junk/$fileName-$sortBy.rep
## sortBy: calls cpu real
## 02jan97 wmt: new
proc profileOff { fileName { sortBy cpu } } {
  global env

  set profileData(0) 1
  profile off profileData 
  set path "$env(HOME)/junk"
  profrep profileData $sortBy "$path/$fileName.rep"
}


## accumulate total time spend in a proc in all call 
## stack contexts
## read TclX profile cpu sorted report
## 17sep97 wmt: new
proc accumulateProfileCpu { fileName } {
  global env

  set path "$env(HOME)/junk"
  set pathName $path/$fileName 
  set cpuTimeArray(0) 0
  set callsArray(0) 0
  set fileId [open $pathName r]
  while {[gets $fileId line] >= 0} {
    if {[llength $line] == 4} {
      set procName [lindex $line 0]
      if {[lsearch -exact [array names cpuTimeArray] $procName] == -1} {
        set cpuTimeArray($procName) [lindex $line 3]
        set callsArray($procName) [lindex $line 1]
      } else {
        incr cpuTimeArray($procName) [lindex $line 3]
        incr callsArray($procName) [lindex $line 1]
      }
    }
  }
  close $fileId
  # sort
  set sortedList {}
  foreach procName [array names cpuTimeArray] {
    lappend sortedList [list $procName $cpuTimeArray($procName) \
                            $callsArray($procName)]
  }
  set sortedList [lsort -command integerNameSort $sortedList]
  set reportName "[file rootname $fileName]-accum.rep"
  set pathName $path/$reportName
  set fileId [open $pathName w]
  puts $fileId [format "%40s  %12s  %10s  %14s" procName totalCpuTime \
                    totalCalls averageCpuTime]
  foreach pairList $sortedList {
    if {[lindex $pairList 2] != 0} {
      puts $fileId [format "%40s  %12d  %10d  %14d" \
                        [lindex $pairList 0] [lindex $pairList 1] \
                        [lindex $pairList 2] [expr {round( [lindex $pairList 1] / \
                                                               [lindex $pairList 2])}]]
    }
  }
  close $fileId
}


## sort a list of {name totalCpuTime totalCalls } in descending order
## by totalCpuTime 
## 17sep97 wmt: new
proc integerNameSort { a b } {

  set aTime [lindex $a 1]
  set bTime [lindex $b 1]
  if {$aTime == $bTime} {
    return 0
  } elseif {$aTime < $bTime} {
    return +1
  } else {
    return -1
  }
}

## eval in TkCon
## list values of pirNode key argsValues for all components
proc mapComponentNodes { attribute } {
  global g_NM_componentToNode pirNode

  # encapsulate in proc so it will not be evaluated when loaded
  foreach index [array names g_NM_componentToNode] {
    if {[string match $index 0]} { continue }
    set attributeValue [assoc $attribute pirNode($g_NM_componentToNode($index))]
    puts stderr "nodeInstanceName $index $attribute $attributeValue"
  }
}


## eval in TkCon
proc mapModuleNodes { attributeList } {
  global g_NM_moduleToNode pirNode

  set reportNotFoundP 0
  # encapsulate in proc so it will not be evaluated when loaded
  foreach index [array names g_NM_moduleToNode] {
    if {[string match $index 0]} { continue }
    set pirNodeIndex $g_NM_moduleToNode($index)
    puts stderr "nodeInstanceName $index"
    foreach attribute $attributeList {
      set attributeValue [assoc $attribute pirNode($pirNodeIndex) \
                             $reportNotFoundP]
      puts stderr "    $attribute $attributeValue"
    }
  }
}


## eval in TkCon
proc mapAllNodes { attributeList } {
  global g_NM_instanceToNode pirNode

  set reportNotFoundP 0
  # encapsulate in proc so it will not be evaluated when loaded
  foreach index [array names g_NM_instanceToNode] {
    if {[string match $index 0]} { continue }
    set pirNodeIndex $g_NM_instanceToNode($index)
    puts stderr "nodeInstanceName $index"
    foreach attribute $attributeList {
      set attributeValue [assoc $attribute pirNode($pirNodeIndex)]
      puts stderr "    $attribute $attributeValue"
    }
  }
}

## find sub-level schematic by class name
## > assoc-array RCS-THRUSTER-CONTROL-MODE g_NM_classToInstances
##       (RCS-MODE~ACS-A) 1653 ACS-MODULE_P1654 1656

## > openCanvasToInstanceParent 1653 0


## print number of component module classes
proc componentModuleCount { } {
  global g_NM_componentToNode g_NM_moduleToNode pirNode 
  global g_NM_testInstanceName 

  set componentCnt 0
  foreach name [array names g_NM_componentToNode] {
    if {[string match $name 0]} { continue }
    puts stderr "component $name"
    incr componentCnt
  }
  puts stderr "components: $componentCnt\n"

  set moduleCnt 0
  foreach name [array names g_NM_moduleToNode] {
    if {[string match $name 0]} { continue }
    set index [assoc-array $name g_NM_moduleToNode]
    if {([assoc nodeState pirNode($index)] != "parent-link") && \
            ($name != "?name")} {
      puts stderr "module $name"
      incr moduleCnt
    }
  }
  puts stderr "modules: $moduleCnt"
}


### Tcl Profiler
## in tkcon: ::profiler::reset, then run something, then printProfile ....
proc printProfile { fileName {sortBy totalRuntime} {pattern *}} {

  set fid [open $fileName w]
  puts $fid [::profiler::print $pattern $sortBy]
  close $fid
}

  
