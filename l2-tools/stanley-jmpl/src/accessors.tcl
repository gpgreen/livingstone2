# $Id: accessors.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors.tcl : accessor & setter procs
##      for canvas objects
##      for window objects
##      for arbitrary objects


## get files from multiple sub-directories of input directory
## 25apr96 wmt: new
## 23jul96 wmt: add includeDirs: if {}, include all, else only ones in list
proc getFilesFromSubDirectories { directoryPath sourceExt { includeDirs {} } } {

  set fileList {}
  set sub_dirs [glob -nocomplain $directoryPath/*]
  foreach dir_path $sub_dirs {
    if {[file isdirectory $dir_path]} {
      set dir [file tail $dir_path]
      # puts stderr "getFilesFromSubDirectories dir $dir includeDirs $includeDirs"
      if {(! [string match $dir "CVS"]) && \
          (([llength $includeDirs] == 0) || \
          ([lsearch -exact $includeDirs $dir] >= 0))} {       
        set fileList [concat $fileList \
            [glob -nocomplain $directoryPath/$dir/*$sourceExt]]
      }
    }
  }
  return $fileList
}


## utilities for accessing tcl outputl of ipc-recorder
## 31oct96: from Bob Kanefsky
proc getargn {args n} {
    # puts [getargn "{{color red} {flavor cherry}}" 1]
    # ===> cherry
    return [lindex [lindex [lindex $args 0] $n] 1]}

proc getarg {args keyword} {
    # puts [getarg "{{color red} {flavor cherry}}" flavor]
    # ===> cherry
    return [get1 [lindex $args 0] $keyword]}

proc get1 {alist keyword} {
    # puts [get1 "{color red} {flavor cherry}" flavor]
    # ===> cherry
    foreach pair $alist {
        if {[lindex $pair 0] == $keyword} {
            return [lindex $pair 1]}}}
## end kanef utilities


## get canvas from pirNode window
## .slave_1.canvas.?name.c.w54 => slave_1.canvas.?name.c
## 07may97 wmt: new
proc getCanvasFromWindow  { windowPath } {

  set pathList [split $windowPath "."]
  set numElements [llength $pathList]
  return [join [lrange $pathList 0 [expr {$numElements - 2}]] "."]
}


## return schematic file directory
## 28may97 wmt: new
## 02jul97 wmt: add subdirectories
proc getSchematicDirectory { type { family_or_type "" } } {
  global g_NM_classTypesAList 

  # puts stderr "getSchematicDirectory: type $type family_or_type $family_or_type"
  set dir [lindex [preferred STANLEY_USER_DIR] 0]/[preferred schematic_directory]
  set subdir nil
  if {[string match $type "root"]} {
    set type nodeType
  }
  if {[string match $type "family"]} {
    set subdir $family_or_type
  } elseif {[string match $type "nodeType"]} {
    set subdir [assoc $family_or_type g_NM_classTypesAList]
  }
  return $dir/$subdir
}


## return center point of widget
## 14jul97 wmt: new
proc getWidgetCenter { widget xRef yRef deltaXRef deltaYRef } {
  upvar $xRef x
  upvar $yRef y
  upvar $deltaXRef deltaX
  upvar $deltaYRef deltaY

  # puts stderr "getWidgetCenter: geometry widget $widget `[winfo geometry $widget]'"
  scan [winfo geometry $widget] "%dx%d+%d+%d" width height xx yy
  set deltaX [expr {$width / 2}]
  set deltaY [expr {$height / 2}]
  set x [expr {$xx + $deltaX}]
  set y [expr {$yy + $deltaY}]
}


## return x,y for percent distance along line for arrow point and
## x,y for arrow butt
## 14jul97 wmt: new
proc getArrowLocation { startX startY stopX stopY percent arrowLength \
                            xArrowPtRef yArrowPtRef xArrowBtRef yArrowBtRef } {
  upvar $xArrowPtRef xArrowPt
  upvar $yArrowPtRef yArrowPt
  upvar $xArrowBtRef xArrowBt
  upvar $yArrowBtRef yArrowBt

  # puts stderr "getArrowLocation: startX $startX stopX $stopX startY $startY stopY $stopY"
  set oppositeSide [expr {$stopY - $startY}]
  set adjacentSide [expr {$stopX - $startX}]
  # puts stderr "getArrowLocation: oppositeSide $oppositeSide adjacentSide $adjacentSide"
  set hypotenuse [expr {sqrt( ($oppositeSide * $oppositeSide) + \
                                  ($adjacentSide * $adjacentSide))}]
  # puts stderr "getArrowLocation: hypotenuse $hypotenuse"
  set sine [expr {$oppositeSide / $hypotenuse}]
  set cosine [expr {$adjacentSide / $hypotenuse}]
  set xArrowPt [expr {round( $startX + ($percent * $adjacentSide))}]
  set yArrowPt [expr {round( $startY + ($percent * $oppositeSide))}]

  set oppSidePt [expr {$yArrowPt - $startY}] 
  set adjSidePt [expr {$xArrowPt - $startX}]
  set hypotPt [expr {sqrt( ($oppSidePt * $oppSidePt) + \
                               ($adjSidePt * $adjSidePt))}]
  # puts stderr "getArrowLocation: hypotPt $hypotPt"
  set hypotBt [expr {$hypotPt - $arrowLength}]
  # puts stderr "getArrowLocation: hypotBt $hypotBt"
  set xArrowBt [expr {round( $startX + ($cosine * $hypotBt))}]
  set yArrowBt [expr {round( $startY + ($sine * $hypotBt))}]
}


## determine if MIR .jmpl file is older than Stanley
## schemetic file -- .i.e. out-of-date
## 28jul97 wmt: new
## 19sep97 wmt: Lisp files cannot be checked for being out of date since
## schematic can be written for node/link placement changes, 
## which do not trigger Lisp changes => thus the Lisp file
## may be legitimately out-of-date.
proc modelFileOutofDateP { scmFilePathName } {
  global g_NM_classTypesAList
  global g_NM_classDefType g_NM_generatedMPLExtension 

  set livPathname [preferred LIVINGSTONE_MODELS_DIR]
  if {[lsearch -exact [list abstraction structure symbol value] \
           $g_NM_classDefType] >= 0} {
    set familyName [assoc $g_NM_classDefType g_NM_classTypesAList]
    set modelPathname ${livPathname}/${familyName}$g_NM_generatedMPLExtension 
  } else {
    set fileNameRoot [file rootname [file tail $scmFilePathName]]
    set modelPathname ${livPathname}/${fileNameRoot}$g_NM_generatedMPLExtension 
  }
  set scmFileDate [file mtime $scmFilePathName]
  if {! [file exists $modelPathname]} {
    return 1
  }
  set modelFileDate [file mtime $modelPathname]
  return [expr {$scmFileDate > $modelFileDate}]
}


## 19sep97 wmt: new
proc getModelFilePathName { scmFilePathName nodeType } {
  global g_NM_classTypesAList g_NM_generatedMPLExtension

  set livPathname [preferred LIVINGSTONE_MODELS_DIR]
  if {[lsearch -exact [list abstraction relation structure symbol value] \
           $nodeType] >= 0} {
    set familyName [assoc $nodeType g_NM_classTypesAList]
    set modelPathname ${livPathname}/${familyName}$g_NM_generatedMPLExtension 
  } elseif {[string match $nodeType component]} {
    set fileNameRoot [file rootname [file tail $scmFilePathName]]
    set modelPathname ${livPathname}/components/${fileNameRoot}$g_NM_generatedMPLExtension 
  } elseif {[string match $nodeType module]} {
    set fileNameRoot [file rootname [file tail $scmFilePathName]]
    set modelPathname ${livPathname}/modules/${fileNameRoot}$g_NM_generatedMPLExtension 
  } else {
    puts stderr "getModelFilePathName: nodeType $nodeType not handled\!"
    set modelPathname ""
  }
  # puts stderr "getModelFilePathName: modelPathname $modelPathname"
  return $modelPathname
}


## return the root class name
## 07aug97 wmt: new
proc getRootClassNameErrorString { } {
  global g_NM_classDefType g_NM_livingstoneDefcomponentName
  global g_NM_livingstoneDefmoduleName 

  if {[string match $g_NM_classDefType component]} {
    set className $g_NM_livingstoneDefcomponentName
    set classType component
  } elseif {[string match $g_NM_classDefType module]} {
    set className $g_NM_livingstoneDefmoduleName
    set classType module
  } else {
    puts stderr "getRootClassName: g_NM_classDefType $g_NM_classDefType not handled"
    return ""
  }
  return "`$classType class' must be $className"
}


## return numeric id of unique dialog window path
## 14aug97 wmt: new
proc getDialogId { dialogWindow { type window } } {

  if {[lsearch -exact [list window file] $type] == -1} {
    error "getDialogId: type $type not handled"
  }
  set delimiter "."
  if {[string match $type file]} {
    set delimiter "_"
  }
  set index [string last $delimiter $dialogWindow]
  set id [string range $dialogWindow [expr {1 + $index}] end]
  if {[string match $type window]} {
    regsub -all -- "-" $id "_" tmp; set id $tmp
  }
  return $id
}


## get the canvasRootId from the canvas widget path
## .master.master.canvas.root.c ==> 0 & .master
## .slave_1.master.canvas.root.c ==> 1 & .slave_1
## 26aug97 wmt: new
proc getCanvasRootId { canvasPath canvasRootRef } {
  upvar $canvasRootRef canvasRoot

  if {[regsub -all "\\\." $canvasPath "." tmp] < 2} {
    error "getCanvasRootId: canvasPath `$canvasPath' is too short"
  }
  set shortPath [string range $canvasPath 1 end]
  set indexDot [string first "." $shortPath]
  set id [string range $shortPath 6 [expr {$indexDot - 1}]]
  if {[string match $id ""]} {
    set id 0
  }
  set canvasRoot ".[string range $shortPath 0 [expr {$indexDot - 1}]]"
  return $id
}


## get the canvas root from the canvas root id
## 29aug97 wmt: new
proc getCanvasRoot { canvasRootId } {

  if {$canvasRootId == 0} {
    set canvasRoot .master
  } else {
    set canvasRoot .slave_$canvasRootId
  }
  return $canvasRoot 
}


## get value of certain global variables which contain
## canvas root window information
## 26aug97 wmt: new
proc getCanvasRootInfo { variableName { canvasRootId 0 } } {
  global g_NM_schematicMode $variableName g_NM_vmplTestModeP

  # puts stderr "getCanvasRootInfo: g_NM_schematicMode $g_NM_schematicMode"
  # puts stderr "                   g_NM_g_NM_vmplTestModeP $g_NM_vmplTestModeP"
  # set backtrace ""; getBackTrace backtrace
  # puts stderr "getCanvasRootInfo: `$backtrace'"
  set reportNotFoundP 0; set oldvalMustExistP 0
  if {[lsearch -exact [list g_NM_currentCanvas g_NM_parentNodeGroupList \
                           g_NM_currentNodeGroup g_NM_canvasParentNodeIdList] \
           $variableName] == -1} {
    error "getCanvasRootInfo: variableName $variableName not handled"
  }
  switch $variableName {
    g_NM_currentCanvas {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        if {[string match $g_NM_currentCanvas ""]} {
          # set backtrace ""; getBackTrace backtrace
          # puts stderr "getCanvasRootInfo: `$backtrace'"
          error "getCanvasRootInfo: g_NM_currentCanvas"
        }
        return $g_NM_currentCanvas
      } else {
        return [assoc $canvasRootId g_NM_currentCanvas $reportNotFoundP]
      }
    }
    g_NM_parentNodeGroupList {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        return $g_NM_parentNodeGroupList
      } else {
        return [assoc $canvasRootId g_NM_parentNodeGroupList $reportNotFoundP]
      }
    }
    g_NM_currentNodeGroup {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        return $g_NM_currentNodeGroup
      } else {
        return [assoc $canvasRootId g_NM_currentNodeGroup $reportNotFoundP]
      }
    }
    g_NM_canvasParentNodeIdList {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        return $g_NM_canvasParentNodeIdList 
      } else {
        return [assoc $canvasRootId g_NM_canvasParentNodeIdList $reportNotFoundP]
      }
    }
  }
}


## set value of certain global variables which contain
## canvas root window information
## 26aug97 wmt: new
proc setCanvasRootInfo { variableName value { canvasRootId 0 } } {
  global g_NM_schematicMode $variableName g_NM_vmplTestModeP

  # set backtrace ""; getBackTrace backtrace
  # puts stderr "setCanvasRootInfo: `$backtrace'"
  set reportNotFoundP 0; set oldvalMustExistP 0
  if {[lsearch -exact [list g_NM_currentCanvas g_NM_parentNodeGroupList \
                           g_NM_currentNodeGroup g_NM_canvasParentNodeIdList] \
           $variableName] == -1} {
    error "setCanvasRootInfo: variableName $variableName not handled"
  }
  switch $variableName {
    g_NM_currentCanvas {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        set g_NM_currentCanvas $value
      } else {
        arepl $canvasRootId $value g_NM_currentCanvas $reportNotFoundP \
            $oldvalMustExistP 
      }
    }
    g_NM_parentNodeGroupList {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        set g_NM_parentNodeGroupList $value
      } else {
        arepl $canvasRootId $value g_NM_parentNodeGroupList $reportNotFoundP \
            $oldvalMustExistP 
      }
    }
    g_NM_currentNodeGroup {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        set g_NM_currentNodeGroup $value
      } else {
        arepl $canvasRootId $value g_NM_currentNodeGroup $reportNotFoundP \
            $oldvalMustExistP 
      }
    }
    g_NM_canvasParentNodeIdList {
      if {[string match $g_NM_schematicMode layout] || $g_NM_vmplTestModeP} {
        set g_NM_canvasParentNodeIdList $value
      } else {
        arepl $canvasRootId $value g_NM_canvasParentNodeIdList $reportNotFoundP \
            $oldvalMustExistP 
      }
    }
  }
}


## get pirNodeIndex from window path, e.g. .master.canvas.?name.c.w12
## 01sep97 wmt: new
proc getPirNodeIndexFromWindowPath { windowPath } {
  global g_NM_windowPathToPirNode 

  set canvas [getCanvasFromWindow $windowPath]
  set windowPathPirNodeAlist [assoc-array $canvas g_NM_windowPathToPirNode]
  set pirNodeIndex ""
  for {set i 0} {$i < [llength $windowPathPirNodeAlist]} {incr i 2} {
    if {[string match [lindex $windowPathPirNodeAlist $i] $windowPath]} {
      set pirNodeIndex [lindex $windowPathPirNodeAlist [expr {1 + $i}]]
      break
    }
  }
  return $pirNodeIndex
}


## 05nov99 wmt: new
proc getWindowPathFromWidgetPath { widgetPath {canvasRootId 0} } {

  set currentCanvas [getCanvasRootInfo g_NM_currentCanvas $canvasRootId]
  append currentCanvas ".c"
  set canvasLen [string length $currentCanvas]
  set widgetSuffix [string range $widgetPath [expr {$canvasLen + 1}] end]
  set indx2 [string first "." $widgetSuffix]
  return [string range $widgetPath 0 [expr $canvasLen + $indx2]]
}


## get canvas coords from event bound %X & %Y
## 05dec97 wmt: new
proc getCanvasXYFromEventXY { canvas eventX eventY canvasXRef \
                                  canvasYRef } {
  upvar $canvasXRef canvasX
  upvar $canvasYRef canvasY

  set orgx [winfo rootx $canvas]
  set orgy [winfo rooty $canvas]
  set canvasX [$canvas canvasx [expr {$eventX - $orgx}]]
  set canvasY [$canvas canvasy [expr {$eventY - $orgy}]]
}


## get x,y locations for a connection's terminals
## 06mar96 wmt: new
## 09sep97 wmt: for tcltk 8.0 add 1 to x values to get lines to match
##              component/module terminals
proc getTerminalLocations { canvas inButtonWidget outButtonWidget inXRef \
    inYRef outXRef outYRef } {
  upvar $inXRef inX 
  upvar $inYRef inY
  upvar $outXRef outX 
  upvar $outYRef outY
  global pirNode 

  # ensure that nodes between locations are exposed on the canvas
  set pirNodeIndexIn [getPirNodeIndexFromButtonPath $inButtonWidget]
  set inNodeX [assoc nodeX pirNode($pirNodeIndexIn)]
  set inNodeY [assoc nodeY pirNode($pirNodeIndexIn)]
  set pirNodeIndexOut [getPirNodeIndexFromButtonPath $outButtonWidget]
  set outNodeX [assoc nodeX pirNode($pirNodeIndexOut)]
  set outNodeY [assoc nodeY pirNode($pirNodeIndexOut)]
  scrollCanvasToExposeConnectionToBeDrawn $canvas $inNodeX $inNodeY \
      $outNodeX $outNodeY

  getCanvasXYFromEventXY $canvas [winfo rootx $inButtonWidget] \
      [winfo rooty $inButtonWidget] inX inY
  getCanvasXYFromEventXY $canvas [winfo rootx $outButtonWidget] \
      [winfo rooty $outButtonWidget] outX outY 
  set inX [expr {round( $inX + [winfo width $inButtonWidget]/2 + 1)}]
  set inY [expr {round( $inY - 1)}]
  set outX [expr {round( $outX + [winfo width $outButtonWidget]/2 + 1)}]
  set outY [expr {round( $outY + [winfo height $outButtonWidget] + 1)}]
}





    
    
  










