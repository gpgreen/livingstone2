#!/bin/csh -f
# -f Fast start. do not read the  .cshrc  file

# $Id: create-stanley-user-dirs.csh,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

# create-stanley-user-dirs.csh is called via exec from
# askNewWorkspaceUpdate
# error checking for user_dir existence and status msgs are done there

# Creation Of User Instantiation Of Stanley User Dirs
#
# $1 -- Stanley User directory
set user_dir = $1
# $2 -- copyP (1 - copy files into directory structure)
set copyP = $2

# build Stanley User directory tree

if ($copyP) then
  # copy color preferences
  cp ../../stanley-sample-user-files/display-state-color-prefs $user_dir 
endif

# component/module bitmaps (built with bitmap) to replace triangles
mkdir $user_dir/bitmaps
if ($copyP) then
  set bitmaps_dir = ../../stanley-sample-user-files/bitmaps
  foreach file ($bitmaps_dir/*)
    if ("$file" != "../../stanley-sample-user-files/bitmaps/CVS") then
      cp $file  $user_dir/bitmaps
    endif
  end
endif

# generated JMPL code will go here 
mkdir $user_dir/livingstone
mkdir $user_dir/livingstone/models
mkdir $user_dir/livingstone/models/components
mkdir $user_dir/livingstone/models/modules
mkdir $user_dir/livingstone/models/scenarios

# generated schematics will go here
mkdir $user_dir/schematics
mkdir $user_dir/schematics/abstractions
mkdir $user_dir/schematics/defcomponents
mkdir $user_dir/schematics/defmodules
mkdir $user_dir/schematics/defrelations
mkdir $user_dir/schematics/defsymbols
mkdir $user_dir/schematics/defvalues
mkdir $user_dir/schematics/structures

if ($copyP) then
  # copy basic defs
  set abstractions_dir = ../../stanley-sample-user-files/schematics/abstractions
  cp ${abstractions_dir}/*.scm \
      $user_dir/schematics/abstractions

  set defrelations_dir = ../../stanley-sample-user-files/schematics/defrelations
  cp ${defrelations_dir}/*.scm \
      $user_dir/schematics/defrelations

  set defsymbols_dir = ../../stanley-sample-user-files/schematics/defsymbols
  cp ${defsymbols_dir}/*.scm \
      $user_dir/schematics/defsymbols

  set defvalues_dir = ../../stanley-sample-user-files/schematics/defvalues
  cp ${defvalues_dir}/*.scm \
      $user_dir/schematics/defvalues

  set structures_dir = ../../stanley-sample-user-files/schematics/structures
  cp ${structures_dir}/*.scm \
      $user_dir/schematics/structures
else

  set defvalues_dir = ../../stanley-sample-user-files/schematics/defvalues
  cp ${defvalues_dir}/displayStateValues.scm \
      $user_dir/schematics/defvalues

  set defsymbols_dir = ../../stanley-sample-user-files/schematics/defsymbols
  cp ${defsymbols_dir}/unknownFaultRank.scm \
      $user_dir/schematics/defsymbols

endif


