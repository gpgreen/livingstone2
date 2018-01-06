rem
rem See the file "l2-tools/disclaimers-and-notices.txt" for 
rem information on usage and redistribution of this file, 
rem and for a DISCLAIMER OF ALL WARRANTIES.
rem
rem when running under Windows
rem create-stanley-user-dirs.bat is called via exec from
rem askNewWorkspaceUpdate
rem error checking for user_dir existence and status msgs are done there

rem Creation Of User Instantiation Of Stanley User Dirs

echo off

rem $1 -- Stanley User directory
set user_dir=%1
rem $2 -- copyP (1 - copy files into directory structure)
set copyP=%2

rem build Stanley User directory tree

if "%copyP%"=="0" goto :cont1
  rem copy color preferences
  copy ..\..\stanley-sample-user-files\display-state-color-prefs $user_dir 
:cont1

rem component\module bitmaps (built with bitmap) to replace triangles
mkdir %user_dir%\bitmaps
if "%copyP%"=="0" goto :cont2
  set bitmaps_dir=..\..\stanley-sample-user-files\bitmaps
  xcopy %bitmaps_dir% %user_dir%\bitmaps
:cont2

rem generated JMPL code will go here 
mkdir %user_dir%\livingstone
mkdir %user_dir%\livingstone\models
mkdir %user_dir%\livingstone\models\components
mkdir %user_dir%\livingstone\models\modules
mkdir %user_dir%\livingstone\models\scenarios

rem generated schematics will go here
mkdir %user_dir%\schematics
mkdir %user_dir%\schematics\abstractions
mkdir %user_dir%\schematics\defcomponents
mkdir %user_dir%\schematics\defmodules
mkdir %user_dir%\schematics\defrelations
mkdir %user_dir%\schematics\defsymbols
mkdir %user_dir%\schematics\defvalues
mkdir %user_dir%\schematics\structures

if "%copyP%"=="0" goto :cont3
  rem copy basic defs
  set abstractions_dir=..\..\stanley-sample-user-files\schematics\abstractions
  xcopy %abstractions_dir%\*.scm %user_dir%\schematics\abstractions

  set defrelations_dir=..\..\stanley-sample-user-files\schematics\defrelations
  xcopy %defrelations_dir%\*.scm %user_dir%\schematics\defrelations

  set defsymbols_dir=..\..\stanley-sample-user-files\schematics\defsymbols
  xcopy %defsymbols_dir%\*.scm %user_dir%\schematics\defsymbols

  set defvalues_dir=..\..\stanley-sample-user-files\schematics\defvalues
  xcopy %defvalues_dir%\*.scm %user_dir%\schematics\defvalues

  set structures_dir=..\..\stanley-sample-user-files\schematics\structures
  xcopy %structures_dir%\*.scm %user_dir%\schematics\structures
:cont3

if "%copyP%"=="1" goto :cont4
  set defvalues_dir=..\..\stanley-sample-user-files\schematics\defvalues
  xcopy %defvalues_dir%\displayStateValues.scm %user_dir%\schematics\defvalues

  set defsymbols_dir=..\..\stanley-sample-user-files\schematics\defsymbols
  xcopy %defsymbols_dir%\unknownFaultRank.scm %user_dir%\schematics\defsymbols
:cont4