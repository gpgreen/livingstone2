# $Id: alist.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## alist.tcl - assoc list accessors

# find the largest element of a  list
proc lmax lst {
  set themax [lindex $lst 0]
  foreach x $lst {
   if {$x > $themax} {
      set themax $x
      }
 }
 return $themax
}

# find the smallest element of a  list
proc lmin lst {
  set themin [lindex $lst 0]
  foreach x $lst {
   if {$x < $themin} {
      set themin $x
      }
 }
 return $themin
}

# reverse a list
proc lreverse lst {
  set rev {}
  foreach elem $lst {set rev [linsert $rev 0 $elem]}
  return $rev
}

# delete the first occurrence of a (numeric) value in the list
## 27oct96 wmt: replaced by lremove which passes the list
##              by reference
proc ldelete {lst elt} {
  set eindex [lsearch -exact $lst $elt]
  if {$eindex != -1} {
    return [lreplace $lst $eindex $eindex]
  } else {
    return $lst
  }
}

# map: apply a proc to every element in the list
proc lmap {lst f} {
  set r {}
  foreach elt $lst {
   lappend r [$f $elt]
  }
  return $r
}

## search an alist {attribute value attribute value ...}. 
## Note: call by reference
## 13oct95 wmt: do nothing if length of attrib is zero
## 09dec96 wmt: add returnIndexP -- returns -1 if attrib is not found,
##              otherwise the index -- NOT THE VALUE
## 25sep98 wmt: use assocValue to return index and value, rather than
##              making calls to lsearch & lindex (assocValue defined in
##              stanley/c/stanley.c
proc assoc { attrib alistname { reportNotFoundP 1 } { returnIndexP 0 } } {
  upvar $alistname alist

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: assoc attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "assoc: `$backtrace'"
    ## error "assoc"
    return {}
  }
  set i [lsearch -exact $alist $attrib]
  set value {}
#   ## requires tcl/tk 8.0.3
#   ## it is no faster than the lsearch/lindex calls
#   set indexAndValue [assocValue $attrib $alist]
#   # puts stderr "assoc: indexAndValue `$indexAndValue'"
#   set i [lindex $indexAndValue 0]
#   set value [lindex $indexAndValue 1]
#   # puts stderr "assoc: i `$i' value `$value'" 
  if {$i != -1} {
    if {$returnIndexP} {
      return $i
    } else {
      set value [lindex $alist [expr {1+$i}]]
      return $value
    }
  } else {
    if {$returnIndexP} {
      return $i
    } elseif {$reportNotFoundP} {
      set backtrace ""; getBackTrace backtrace
      puts stderr \
          "assoc: `$backtrace': `$attrib' not found in `$alistname'"
      puts stderr "  `$alistname': `$alist'"
    }
    return $value 
  }
}


## search an alist {attribute value attribute value ...}. 
## by attribute -- return value
## Note: call by reference
## Note: this is very slow -- use only for short lists
## 11mar96 wmt: only check attribute fields for attrib 
## 16sep96 wmt: add optional return type arg
proc assoc-exact { attrib alistname { reportNotFoundP 1 } { returnIndexP 0 } } {
  upvar $alistname alist

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: assoc-exact attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "assoc-exact: `$backtrace'"
    return {}
  }
  set retValue ""; set foundP 0
  for {set i 0} {$i < [llength $alist]} \
      {incr i 2} {
    if {[string match [lindex $alist $i] $attrib]} {
      set retValue [lindex $alist [expr {$i + 1}]]
      set foundP 1
      break
    }
  }
  if {$returnIndexP} {
    if {$foundP == 0} {
      set i -1
    }
    return $i
  } elseif {(! $foundP) && $reportNotFoundP} {
      set backtrace ""; getBackTrace backtrace
      puts stderr \
          "assoc-exact: `$backtrace' `$attrib' not found in `$alistname'"
  }
  return $retValue
}


## search an alist {attribute value attribute value ...}. 
## by value -- return attribute
## Note: call by reference
## Note: this is very slow -- use only for short lists
## 29jun98 wmt: new
proc assoc-value-exact { value alistname { reportNotFoundP 1 } { returnIndexP 0 } } {
  upvar $alistname alist

  if {[string length $value] == 0} {
    puts stderr "Stanley Internal Error: assoc-value-exact value length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "assoc-value-exact: `$backtrace'"
    return {}
  }
  set retValue ""; set foundP 0
  for {set i 1} {$i < [llength $alist]} \
      {incr i 2} {
    if {[string match [lindex $alist $i] $value ]} {
      set retValue [lindex $alist [expr {$i - 1}]]
      set foundP 1
      break
    }
  }
  if {$returnIndexP} {
    if {$foundP == 0} {
      set i -1
    }
    return $i
  } elseif {(! $foundP) && $reportNotFoundP} {
      set backtrace ""; getBackTrace backtrace
      puts stderr \
          "assoc-value-exact:: `$backtrace' `$value' not found in `$alistname'"
      puts stderr "  `$alistname': `$alist'"
  }
  return $retValue
}


## insert an attrib/value pair into alist. Note: call by reference
## 13oct95 wmt: do nothing if length of attrib is zero
proc acons {attrib value alistname} {
  upvar $alistname alist;

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: acons attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "assoc: `$backtrace'"
    return {}
  }
  set alist [linsert $alist 0 $attrib $value]
}


## remove the first attrib/value pair from an alist. Return
## the old value. Note: call by ref
## 13oct95 wmt: do nothing if length of attrib is zero
##              prevents corruption of pirDisplay when called
##              by cutNode with null pathname
## 12oct96 wmt: add args callerIsAreplP & reportNotFoundP 
## 03jan97 wmt: replace assoc call with lindex; remove optional arg
##              callerIsAprocP; add optional arg returnOldvalP
proc adel {attrib alistname { reportNotFoundP 1 } { returnOldvalP 0 } } {
  upvar $alistname alist;

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: adel attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "adel: `$backtrace'"
    return ""
  }
  set oldval ""
  set i [lsearch -exact $alist $attrib]
  # puts [format {adel i attrib => %d: %s} $i $attrib]
  if {$i != -1} {
    if {$returnOldvalP} {
      set oldval [lindex $alist [expr {1+$i}]]
    }
    set alist [lreplace $alist $i [expr {$i+1}]]
  } elseif {$reportNotFoundP} {
    set backtrace ""; getBackTrace backtrace
    puts stderr \
        "adel: `$backtrace': `$attrib' not found in `$alistname'"
  }
  return $oldval
}


## search only on key args, not all args -- return old value
## Note: this is very slow -- use only for short lists
## 03oct96 wmt: new
## 10oct96 wmt: add optional return type arg
## 12oct96 wmt: add args callerIsAreplP & reportNotFoundP 
proc adel-exact { attrib alistname { returnIndexP 0 } { reportNotFoundP 1 } } {
  upvar $alistname alist

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: adel-exact attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "adel-exact: `$backtrace'"
    return {}
  }
  set retValue ""; set foundP 0
  for {set i 0} {$i < [llength $alist]} \
      {incr i 2} {
    if {[string match [lindex $alist $i] $attrib]} {
      if {! $returnIndexP} {
        set retValue [lindex $alist [expr {$i + 1}]]
        set alist [lreplace $alist $i [expr {$i + 1}]]
      }
      set foundP 1
      break
    }
  }
  if {(! $foundP) && $reportNotFoundP} {
    set backtrace ""; getBackTrace backtrace
    puts stderr \
        "adel-exact: `$backtrace': `$attrib' not found in `$alistname'"
  }
  if {$returnIndexP} {
    return $i
  } else {
    return $retValue
  }
}

## replace an attrib value pair with a new value. Return old value
## Note: call by ref
## Note: replaces pair at head on list
## 12oct96 wmt: pass callerIsAreplP & reportNotFoundP to adel
## 23oct96 wmt: add optional arg oldvalMustExistP
## 03jan97 wmt: instead of inserting new value at head of list
##              replace the old value with the new value, in place;
##              do not use adel; add optional arg returnOldvalP
proc arepl { attrib newval alistname { reportNotFoundP 1 } \
    { oldvalMustExistP 1 } { returnOldvalP 0 } } {
  upvar $alistname alist;

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: arepl attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "arepl: `$backtrace'"
    return {}
  }
  set oldval "" 
  set i [lsearch -exact $alist $attrib]
  # puts [format {arepl i attrib => %d: %s} $i $attrib]
  if {$i != -1} {
    set valueIndex [expr {1+$i}]
    if {$returnOldvalP} {
      set oldval [lindex $alist $valueIndex]
    }
    set alist [lreplace $alist $valueIndex $valueIndex $newval]
  } else {
    if {$oldvalMustExistP} {
      if {$reportNotFoundP} {
        set backtrace ""; getBackTrace backtrace
        puts stderr \
            "arepl: `$backtrace': `$attrib' not found in `$alistname'"
      }
    } else {
      set alist [linsert $alist end $attrib $newval]
    }
  }
  return $oldval
}


## search only on key args, not all args 
## Note: this is very slow -- use only for short lists
## 30jan98 wmt: derived from arepl
proc arepl-exact { attrib newval alistname { reportNotFoundP 1 } \
    { oldvalMustExistP 1 } { returnOldvalP 0 } } {
  upvar $alistname alist;

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: arepl-exact attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "arepl: `$backtrace'"
    return {}
  }
  set oldval ""; set foundP 0
  for {set i 0} {$i < [llength $alist]} \
      {incr i 2} {
    if {[string match [lindex $alist $i] $attrib]} {
      set foundP 1
      break
    }
  }
  # puts [format {arepl i attrib => %d: %s} $i $attrib]
  if {$foundP} {
    set valueIndex [expr {1+$i}]
    if {$returnOldvalP} {
      set oldval [lindex $alist $valueIndex]
    }
    set alist [lreplace $alist $valueIndex $valueIndex $newval]
  } else {
    if {$oldvalMustExistP} {
      if {$reportNotFoundP} {
        set backtrace ""; getBackTrace backtrace
        puts stderr \
            "arepl: `$backtrace': `$attrib' not found in `$alistname'"
      }
    } else {
      set alist [linsert $alist 0 $attrib $newval]
    }
  }
  return $oldval
}


## insert a value into the head of a list associated with an attrib.
## Note: call by ref
## 13oct95 wmt: do nothing if length of attrib is zero
## 12oct96 wmt: pass callerIsAreplP & reportNotFoundP to adel
## 03jan97 wmt: do not use adel
proc ains {attrib newval alistname { reportNotFoundP 1} } {
  upvar $alistname alist;

  if {[string length $attrib] == 0} {
    puts stderr "Stanley Internal Error: ains attrib length is 0 for $alistname"
    set backtrace ""; getBackTrace backtrace
    puts stderr "ains: `$backtrace'"
    return {}
  }
  set i [lsearch -exact $alist $attrib]
  # puts [format {ains i attrib => %d: %s} $i $attrib]
  if {$i != -1} {
    set valueIndex [expr {1+$i}] 
    set oldvalList [lindex $alist $valueIndex]
    set newvalList [linsert $oldvalList 0 $newval] 
    set alist [lreplace $alist $valueIndex $valueIndex $newvalList]
  } elseif {$reportNotFoundP} {
    set backtrace ""; getBackTrace backtrace
    puts stderr \
        "ains: `$backtrace': `$attrib' not found in `$alistname'"
  }       
  return;
}


## pretty-print an alist
proc aputs {fd alistname } {
  upvar $alistname alist;
  puts $fd "$alistname:"
  for {set i 0} {$i < [llength $alist]} {incr i} {
    set line [format " %s = `%s'" [lindex $alist $i] [lindex $alist [incr i]]];
    puts $fd $line;
  }
  return;
}


## return a list of alist keys
proc alist-keys { alistRef } {
  upvar $alistRef alist

  set keyList {}
  for {set i 0} {$i < [llength $alist]} {incr i 2} {
    lappend keyList [lindex $alist $i]
  }
  return $keyList
}


## return a list of alist values
proc alist-values { alistRef } {
  upvar $alistRef alist

  set valueList {}
  for {set i 0} {$i < [llength $alist]} {incr i 2} {
    lappend valueList [lindex $alist [expr {1 + $i}]]
  }
  return $valueList
}


# Reverse an alist (preserving pair order)
# Note: call by reference
proc alistReverse {alistname} {
  upvar $alistname alist
  set rev {}
  set len [llength $alist]
  set inx 0
  while {$inx < $len} {
    acons [lindex $alist $inx] [lindex $alist [expr $inx+1]] rev
    incr inx 2
  }
  set alist $rev
}

## insert an attrib/value pair into alist at the end.
## Note: call by reference
proc alistAppend {alistname attrib value} {
  upvar $alistname alist;
  lappend alist $attrib $value
}


## remove an element from a list
## the list is passed by reference
## 27oct96 wmt: new
## 02jun97 wmt: return lsearch index
proc lremove { theListRef element } {
  upvar $theListRef theList

  set index -1
  if {[llength $theList] > 0} {
    set index [lsearch -exact $theList $element]
    if {$index >= 0} {
      set theList [lreplace $theList $index $index]
    }
  }
  return $index
}


## remove duplicates from list
## 11jun97 wmt: new
proc lremoveDuplicates { theDupList } {

  set uniqueList {}
  foreach item $theDupList {
    if {[lsearch -exact $uniqueList $item] == -1} {
      lappend uniqueList $item
    }
  }
  return $uniqueList
}









