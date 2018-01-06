# $Id: version.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## version.tcl

## version control code. The RCS release of this module IS the release
##   number for the builder.
## Upward compatibility is provided as follows:
##    pirSetVersion sets the "version" field in pirDisplay
##    pirGetVersion returns the n.n release number
##    pirUpVersion checks two release numbers and if different, attempts
##       to convert the old data structures into the new ones.
##    For upward compatibility, each version should provide a proc to
##       convert upward from the preceding release. That proc should be named
##       pirUpward_{$oldRelease} and return the new release number.

## (re-)establish the global version field in pirDisplay 
## and return the V/R value
proc pirSetVersion {} {
  global pirDisplay

  set reportNotFoundP 0; set oldvalMustExistP 0
  ## when changing versions, add conversion function below
  ##arepl version {$Id: version.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $} pirDisplay
  arepl version {Stanley VJMPL version L2_2.7.8.2 2006/04/20 11:49:27 taylor} \
      pirDisplay $reportNotFoundP $oldvalMustExistP 
  return [pirGetVersion]
}

## return the current version.release number
proc pirGetVersion {} {
  global pirDisplay
  return [lindex [assoc version pirDisplay] 3]
}

## upward compatibility support
## 16jul97 wmt: not used anymore
proc pirUpVersion {oldRelease newRelease} {
  global pirDisplay
  if {$oldRelease==$newRelease} return;
  set application [assoc application pirDisplay]
  if {![regexp {^([0-9]+).([0-9]+)} $oldRelease unused oldv oldr]} {
    error "Source for $application is obsolete -- Upward compatibility not supported (Sorry)."
  }

  regexp {^([0-9]+).([0-9]+)} $newRelease unused newv newr
  tk_dialog .dd "OUT OF DATE" "Source for $application is obsolescent. Upgrade will be attempted." {} 0 {OK};
  ## puts "oldv $oldv newv $newv oldr $oldr newr $newr"
  while {($oldv < $newv) || (($oldv == $newv) && ($oldr < $newr))} {
    if [lsearch -exact [info procs] pirUpward_{$oldRelease}] {
      set oldRelease [pirUpward_{$oldRelease} $application]
      regexp {^([0-9]+).([0-9]+)} $oldRelease unused oldv oldr
    } else {
      error "*** No module found to Upgrade from $oldRelease to $newRelease!";
    }
  }
  pirWarning "Upgrade successful!"
}



## upgrade 1.0 -> 1.1 sample with data structure changes
#proc pirUpward_{1.0} {application} {
#    global pirPreferences
#    puts -nonewline stderr "Upgrading $application from version 1.0 to 1.1..."
#    set completeCol [assoc editingCompleteColor pirPreferences]
#    adel editingCompleteColor pirPreferences
#    if {[assoc nodeCompleteColor pirPreferences] == ""} {
#	acons nodeCompleteColor $completeCol pirPreferences
#	acons nodeConnectionBgColor $completeCol pirPreferences
#    }
#    puts stderr "Done."
#    return 1.1
#}

## upgrade 1.0 -> 1.1
proc pirUpward_{1.0} {application} {
  global pirFileInfo

  puts stderr "${application}$pirFileInfo(suffix) upgraded from version 1.0 to 1.1"
  mark_scm_modified
  return 1.1
}


## upgrade 1.1 -> 1.5
proc pirUpward_{1.1} {application} {
  global pirFileInfo

  puts stderr "${application}$pirFileInfo(suffix) upgraded from version 1.1 to 1.5"
  mark_scm_modified
  return 1.5
}


## upgrade 1.5 -> 1.6
proc pirUpward_{1.5} {application} {
  global pirFileInfo

  puts stderr "${application}$pirFileInfo(suffix) upgraded from version 1.5 to 1.6"
  mark_scm_modified
  return 1.6
}


## upgrade 1.6 -> 2.0
proc pirUpward_{1.6} {application} {
  global pirFileInfo

  puts stderr "${application}$pirFileInfo(suffix) upgraded from version 1.6 to 2.0"
  mark_scm_modified
  return 2.0
}


## upgrade 2.0 -> 2.5
proc pirUpward_{2.0} {application} {
  global pirFileInfo

  puts stderr "${application}$pirFileInfo(suffix) upgraded from version 2.0 to 2.5"
  mark_scm_modified
  return 2.5
}
