# $Id: accessors-array.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors-array.tcl - array accessors & setters


## 09oct98 wmt: new - for assoc lists converted to arrays
##              adapted from assoc
proc assoc-array { element arraynameRef { reportNotFoundP 1 } { returnIndexP 0 } } {
  upvar $arraynameRef arrayname

  if {[string length $element] == 0} {
    puts stderr "Stanley Internal Error: assoc-array element length is 0 for $arraynameRef"
    set backtrace ""; getBackTrace backtrace
    puts stderr "assoc-array: `$backtrace'"
    return {}
  }
  set i 1; set value {}
  if [catch { set value $arrayname($element) } ] {
    set i -1
  }
  if {$i != -1} {
    if {$returnIndexP} {
      return $i
    } else {
      return $value
    }
  } else {
    if {$returnIndexP} {
      return $i
    } elseif {$reportNotFoundP} {
      set backtrace ""; getBackTrace backtrace
      puts stderr \
          "assoc-array: `$backtrace': `$element' not found in `$arraynameRef'"
      # puts stderr "  `$arrayname': `$alist'"
    }
    return $value 
  }
}


## 09oct98 wmt: new - for assoc lists converted to arrays
##              adapted from adel
proc adel-array { element arraynameRef { reportNotFoundP 1 } { returnOldvalP 0 } } {
  upvar $arraynameRef arrayname

  if {[string length $element] == 0} {
    puts stderr "Stanley Internal Error: adel-array element length is 0 for $arraynameRef"
    set backtrace ""; getBackTrace backtrace
    puts stderr "adel-array: `$backtrace'"
    return ""
  }
  set oldval ""; set i 1
  if [catch { set value $arrayname($element) } ] {
    set i -1
  }

  if {$i != -1} {
    if {$returnOldvalP} {
      set oldval $value
    }
    unset arrayname($element)
  } elseif {$reportNotFoundP} {
    set backtrace ""; getBackTrace backtrace
    puts stderr \
        "adel-array: `$backtrace': `$element' not found in `$arraynameRef'"
  }
  return $oldval
}


## 09oct98 wmt: new - for assoc lists converted to arrays
##              adapted from arepl
proc arepl-array { element newval arraynameRef { reportNotFoundP 1 } \
    { oldvalMustExistP 1 } { returnOldvalP 0 } } {
  upvar $arraynameRef arrayname

  if {[string length $element] == 0} {
    puts stderr "Stanley Internal Error: arepl-array element length is 0 for $arraynameRef"
    set backtrace ""; getBackTrace backtrace
    puts stderr "arepl-array: `$backtrace'"
    return {}
  }
  set oldval ""; set i 1
  if [catch { set value $arrayname($element) } ] {
    set i -1
  }

  if {$i != -1} {
    if {$returnOldvalP} {
      set oldval $value
    }
    set arrayname($element) $newval 
  } else {
    if {$oldvalMustExistP} {
      if {$reportNotFoundP} {
        set backtrace ""; getBackTrace backtrace
        puts stderr \
            "arepl-array: `$backtrace': `$element' not found in `$arraynameRef'"
      }
    } else {
      set arrayname($element) $newval 
    }
  }
  return $oldval
}


