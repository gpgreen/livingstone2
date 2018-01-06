# $Id: accessors-class.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## accessors.tcl : accessor & setter procs

## Get default value from node configuration structure - class_variables
## Note: nodeConfig is call by reference
## 08oct95 wmt: new
## 18dec95 wmt: changed from index to assoc
proc getClassVarDefaultValue { varName classVarsName } {
  upvar $classVarsName classVars

  set varDeflist [assoc $varName classVars]
  set defaultValue [assoc default varDeflist]
##  puts [format {getClassVarDefaultValue $varName default value => %s} $defaultValue]
  return $defaultValue
}


## set default value in node configuration structure - class_variables
## Note: nodeConfig is call by reference
## 16sep96 wmt: new
proc setClassVarDefaultValue { varName varValue classVarsName } {
  upvar $classVarsName classVars

  set varDeflist [assoc $varName classVars]
  arepl default $varValue varDeflist
  arepl $varName $varDeflist classVars 
}


## get class attribute value for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc getClassValue { classType className varName { reportNotFoundP 1 } } {
  global pirClassComponent 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol 
  global pirClassValue pirClassRelation 

  # puts stderr "getClassValue: classType $classType className $className varName $varName"
  switch $classType {
    component
    { assoc $varName pirClassComponent($className) $reportNotFoundP }
    module
    { assoc $varName pirClassModule($className) $reportNotFoundP } 
    abstraction 
    { assoc $varName pirClassAbstraction($className) $reportNotFoundP } 
    relation
    { assoc $varName pirClassRelation($className) $reportNotFoundP } 
    structure 
    { assoc $varName pirClassStructure($className) $reportNotFoundP } 
    symbol
    { assoc $varName pirClassSymbol($className) $reportNotFoundP } 
    value
    { assoc $varName pirClassValue($className) $reportNotFoundP }
    default
    { puts stderr "getClassValue: classType $classType not handled\!" }
  }
}

## set class attribute value for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc setClassValue { classType className varName varValue { reportNotFoundP 1 } \
                         { oldvalMustExistP 1 } { returnOldvalP 0 } } {
  global pirClassComponent g_NM_classDefType 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol pirClassRelation 
  global pirClassValue

  switch $classType {
    component {
      arepl $varName $varValue pirClassComponent($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    }
    module {
      arepl $varName $varValue pirClassModule($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    } 
    abstraction {
      arepl $varName $varValue pirClassAbstraction($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    } 
    relation {
      arepl $varName $varValue pirClassRelation($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    } 
    structure {
      arepl $varName $varValue pirClassStructure($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    } 
    symbol {
      arepl $varName $varValue pirClassSymbol($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    } 
    value {
      arepl $varName $varValue pirClassValue($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    }
    mode {
      arepl $varName $varValue pirClassComponent($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        arepl $varName $varValue pirClassComponent($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
      } elseif {[string match $g_NM_classDefType module]} {
        arepl $varName $varValue pirClassModule($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
      } else {
        puts stderr "setClassValue: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        arepl $varName $varValue pirClassComponent($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
      } elseif {[string match $g_NM_classDefType module]} {
        arepl $varName $varValue pirClassModule($className) \
          $reportNotFoundP $oldvalMustExistP $returnOldvalP 
      } else {
        puts stderr "setClassValue: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    default
    { puts stderr "setClassValue: classType $classType not handled\!" }
  }
}

## get list of class names for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc getClasses { classType } {
  global pirClassesComponent 
  global pirClassesModule 
  global pirClassesAbstraction pirClassesStructure 
  global pirClassesSymbol pirClassesRelation
  global pirClassesValue g_NM_classDefType

  switch $classType {
    component {
      return $pirClassesComponent
    }
    module {
      return $pirClassesModule
    } 
    abstraction {
      return $pirClassesAbstraction
    } 
    relation {
      return $pirClassesRelation
    } 
    structure {
      return $pirClassesStructure
    } 
    symbol {
      return $pirClassesSymbol
    } 
    value {
      return $pirClassesValue
    }
    mode {
      return $pirClassesComponent
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        return $pirClassesComponent
      } elseif {[string match $g_NM_classDefType module]} {
        return $pirClassesModule
      } else {
        puts stderr "getClasses: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        return $pirClassesComponent
      } elseif {[string match $g_NM_classDefType module]} {
        return $pirClassesModule
      } else {
        puts stderr "getClasses: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    default
    { puts stderr "getClasses: classType $classType not handled\!"
    }
  }
}


## concatenate a list of class names with current list for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc concatClasses { classType pirClasses } {
  global pirClassesComponent 
  global pirClassesModule 
  global pirClassesAbstraction pirClassesStructure 
  global pirClassesSymbol pirClassesRelation
  global pirClassesValue

  switch $classType {
    component
    { set pirClassesComponent [concat $pirClassesComponent $pirClasses]}
    module
    { set pirClassesModule [concat $pirClassesModule $pirClasses]} 
    abstraction 
    { set pirClassesAbstraction [concat $pirClassesAbstraction $pirClasses]} 
    relation 
    { set pirClassesRelation [concat $pirClassesRelation $pirClasses]} 
    structure 
    { set pirClassesStructure [concat $pirClassesStructure $pirClasses]} 
    symbol
    { set pirClassesSymbol [concat $pirClassesSymbol $pirClasses]} 
    value
    { set pirClassesValue [concat $pirClassesValue $pirClasses]}
    default
    { puts stderr "concatClasses: classType $classType not handled\!" }
  }
}


## append class name to current list for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc lappendClasses { classType class } {
  global pirClassesComponent 
  global pirClassesModule 
  global pirClassesAbstraction pirClassesStructure 
  global pirClassesSymbol pirClassesRelation
  global pirClassesValue g_NM_classDefType 

  switch $classType {
    component {
      lappend pirClassesComponent $class
    }
    module {
      lappend pirClassesModule $class
    } 
    abstraction {
      lappend pirClassesAbstraction $class
    } 
    relation {
      lappend pirClassesRelation $class
    } 
    structure {
      lappend pirClassesStructure $class
    } 
    symbol {
      lappend pirClassesSymbol $class
    } 
    value {
      lappend pirClassesValue $class
    }
    mode {
      lappend pirClassesComponent $class
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        lappend pirClassesComponent $class
      } elseif {[string match $g_NM_classDefType module]} {
        lappend pirClassesModule $class
      } else {
        puts stderr "lappendClasses: g_NM_classDefType $g_NM_classDefType not handled\!"
      }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        lappend pirClassesComponent $class
      } elseif {[string match $g_NM_classDefType module]} {
        lappend pirClassesModule $class
      } else {
        puts stderr "lappendClasses: g_NM_classDefType $g_NM_classDefType not handled\!"
      }
    }
    default
    { puts stderr "lappendClasses: classType $classType not handled\!" }
  }
}


## remove class name to current list for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc lremoveClasses { classType class } {
  global pirClassesComponent 
  global pirClassesModule 
  global pirClassesAbstraction pirClassesStructure 
  global pirClassesSymbol pirClassesRelation
  global pirClassesValue g_NM_classDefType 

  switch $classType {
    component {
      lremove pirClassesComponent $class
    }
    module {
      lremove pirClassesModule $class
    } 
    abstraction {
      lremove pirClassesAbstraction $class
    } 
    relation {
      lremove pirClassesRelation $class
    } 
    structure {
      lremove pirClassesStructure $class
    } 
    symbol {
      lremove pirClassesSymbol $class
    } 
    value {
      lremove pirClassesValue $class
    }
    mode {
      lremove pirClassesComponent $class
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        lremove pirClassesComponent $class
      } elseif {[string match $g_NM_classDefType module]} {
        lremove pirClassesModule $class
      } else {
        puts stderr "lremoveClasses: g_NM_classDefType $g_NM_classDefType not handled\!"
      }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        lremove pirClassesComponent $class
      } elseif {[string match $g_NM_classDefType module]} {
        lremove pirClassesModule $class
      } else {
        puts stderr "lremoveClasses: g_NM_classDefType $g_NM_classDefType not handled\!"
      }
    }
    default
    { puts stderr "lremoveClasses: classType $classType not handled\!" }
  }
}


## return "array get <array-name>" for class array for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc getClassArrayContents { classType } {
  global pirClassComponent 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol pirClassRelation 
  global pirClassValue

  switch $classType {
    component
    { return [array get pirClassComponent] }
    module
    { return [array get pirClassModule] } 
    abstraction 
    { return [array get pirClassAbstraction] } 
    relation
    { return [array get pirClassRelation] } 
    structure 
    { return [array get pirClassStructure] } 
    symbol
    { return [array get pirClassSymbol] } 
    value
    { return [array get pirClassValue] }
    default
    { puts stderr "getClassArrayContents: classType $classType not handled\!" }
  }
}


## set class contents for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc setClass { classType className alistRef } {
  upvar $alistRef alist
  global pirClassComponent 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol pirClassRelation
  global pirClassValue g_NM_classDefType 

  switch $classType {
    component {
      set pirClassComponent($className) $alist
    }
    module {
      set pirClassModule($className) $alist
    } 
    abstraction {
      set pirClassAbstraction($className) $alist
    } 
    relation {
      set pirClassRelation($className) $alist
    } 
    structure {
      set pirClassStructure($className) $alist
    } 
    symbol {
      set pirClassSymbol($className) $alist
    } 
    value {
      set pirClassValue($className) $alist
    }
    mode {
      set pirClassComponent($className) $alist
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        set pirClassComponent($className) $alist
      } elseif {[string match $g_NM_classDefType module]} {
        set pirClassModule($className) $alist
      } else {
        puts stderr "setClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        set pirClassComponent($className) $alist
      } elseif {[string match $g_NM_classDefType module]} {
        set pirClassModule($className) $alist
      } else {
        puts stderr "setClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    default
    { puts stderr "setClass: classType $classType not handled\!" }
  }
}


## unset class contents for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc unsetClass { classType className } {
  global pirClassComponent 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol pirClassRelation
  global pirClassValue g_NM_classDefType 

  switch $classType {
    component {
      catch { unset pirClassComponent($className) }
    }
    module {
      catch { unset pirClassModule($className) }
    } 
    abstraction {
      catch { unset pirClassAbstraction($className) }
    } 
    relation {
      catch { unset pirClassRelation($className) }
    } 
    structure {
      catch { unset pirClassStructure($className) }
    } 
    symbol {
      catch { unset pirClassSymbol($className) }
    } 
    value {
      catch { unset pirClassValue($className) }
    }
    mode {
      catch { unset pirClassComponent($className) }
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        catch { unset pirClassComponent($className) }
      } elseif {[string match $g_NM_classDefType module]} {
        catch { unset pirClassModule($className) }
      } else {
        puts stderr "unsetClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        catch { unset pirClassComponent($className) }
      } elseif {[string match $g_NM_classDefType module]} {
        catch { unset pirClassModule($className) }
      } else {
        puts stderr "unsetClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    default
    { puts stderr "unsetClass: classType $classType not handled\!" }
  }
}


## get class contents for class type
## separate class name spaces for component, module, structure,
## symbol, & value
## 31jan98 : wmt new
proc getClass { classType className } {
  global pirClassComponent 
  global pirClassModule 
  global pirClassAbstraction pirClassStructure 
  global pirClassSymbol pirClassRelation
  global pirClassValue g_NM_classDefType 

  switch $classType {
    component {
      return $pirClassComponent($className) 
    }
    module {
      return $pirClassModule($className) 
    } 
    abstraction {
      return $pirClassAbstraction($className) 
    } 
    relation {
      return $pirClassRelation($className) 
    } 
    structure {
      return $pirClassStructure($className) 
    } 
    symbol {
      return $pirClassSymbol($className) 
    } 
    value {
      return $pirClassValue($className) 
    }
    mode {
      return $pirClassComponent($className) 
    }
    attribute {
      if {[string match $g_NM_classDefType component]} {
        return $pirClassComponent($className) 
      } elseif {[string match $g_NM_classDefType module]} {
        return $pirClassModule($className) 
      } else {
        puts stderr "getClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    terminal {
      if {[string match $g_NM_classDefType component]} {
        return $pirClassComponent($className) 
      } elseif {[string match $g_NM_classDefType module]} {
        return $pirClassModule($className) 
      } else {
        puts stderr "getClass: g_NM_classDefType $g_NM_classDefType not handled\!" }
    }
    default
    { puts stderr "getClass: classType $classType not handled\!" }
  }
}








