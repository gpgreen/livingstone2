# $Id: README-RELEASE-TEST.txt,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $

####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####
#####################################################################
RELEASE TESTS FOR STANLEY
#####################################################################

Test 01 - Testing: cbAndLeds, cbDiagnosticTest1, STEP & SINGLE
--------------------------------------------------------------
01) File->Open Workspace->"stanley-sample-user-files"
02) Test->Scope->module->cbAndLeds
03) Test->Clean
04) Test->Compile 
    - verify successful compile in pop-up dialog
05) Test->Load & Go
    - click "use defaults" in Modes & Initial Conditions dialog
06) Scenario Mgr->Open Scenario->cbDiagnosticTest1
07) Scenario Mgr->STEP
    - green line moves from "progress test.cb1.cmdIn=on"
      to "assign test.led8.ledState=off"
    - all cbs and leds turn light green
    - current time is 16: Candidate Mgr & Stanley legend line
08) Scenario Mgr->STEP
    - green line moves from "assign test.led8.ledState=off"
      to "assign test.led7.ledState=on"
    - attention msg: "Select candidate from Candidate, or select .. button"
09) Candidate Mgr->click on candidate 0
    - Scenario Mgr attention msg cleared
    - cb15 turns red
10) cb15 icon->Mouse-R->"mode & propositions"
    - Mode: tripped
    - displayState: failed
11) Scenario Mgr->STEP
    - green line moves from "assign test.led7.ledState=on"
      to bottom and vanishes
    - yellow "edit" line is on "-- end-of-buffer --"
    - attention msg: "Select candidate from Candidate, or select .. button"
12) cb8 icon->Mouse-R->"mode & propositions"
    - cb8 State Viewer appears
    - Mode: on
    - displayState: nominal
13) Candidate Mgr->click on candidate 0
    - Scenario Mgr attention msg cleared
    - cb2/cb4/cb6/cb8 turn red
14) cb8 State Viewer 
    - Mode: tripped
    - displayState: failed
15) Scenario Mgr->RESET
16) Repeat steps 06->10
17) Scenario Mgr->SINGLE
    - green line moves from "assign test.led7.ledState=on"
      to "assign test.led5.ledState=on"
    - Scenario Mgr attention msg: "Observations inconsistent ...; run fc"
18) Scenario Mgr->STEP
    - green line moves from "assign test.led5.ledState=on"
      to bottom and vanishes
    - yellow "edit" line is on "-- end-of-buffer --"
    - attention msg: "Select candidate from Candidate, or select .. button"
19) Candidate Mgr->click on candidate 0
    - Scenario Mgr attention msg cleared
    - cb2/cb4/cb6/cb8 turn red
20) cb8 State Viewer 
    - Mode: tripped
    - displayState: failed

Test 02 - Testing: mainPropulsionSystem, pressurizeThenVent, SINGLE
-------------------------------------------------------------------
01) Test->Scope->module->mainPropulsionSystem
02) Test->Clean
03) Test->Compile 
    - verify successful compile in pop-up dialog
04) Test->Load & Go
    - click "use defaults" in Modes & Initial Conditions dialog
05) Scenario Mgr->Open Scenario->pressurizeThenVent
06) sv03 icon
    - color is gray
    - ctrl-Mouse-L on sv03 icon
07) sv icon
    - Mouse-R: Show sv mode & propositions
08) sv03.sv State Viewer
    - time: 1
    - "Instance test.sv03.sv" background color gray
    - mode: closed
    - valveCmdIn value is noCommand
09) Scenario Mgr->SINGLE
    - green line moves from "progress test.sv03.sv.valveCmdIn=open"
      to "fc"
    - State Viewer time: 2
    - State Viewer "Instance test.sv03.sv" background color white
    - State Viewer mode: open
    - Candidate Mgr current time is blank
10) Scenario Mgr->SINGLE
    - green line moves from "fc" to
      "progress test.sv03.sv.valveCmdIn=close"
    - sv03.sv State Viewer does not change
    - Candidate Mgr current time is 2
11) Scenario Mgr->SINGLE
    - green line moves from "progress test.sv03.sv.valveCmdIn=close"
      to "fc"
    - State Viewer time: 3
    - State Viewer "Instance test.sv03.sv" background color gray
    - State Viewer mode: closed
    - Candidate Mgr current time is blank
12) Scenario Mgr->SINGLE
    - green line moves from "fc" to
      "progress test.sv03.sv.valveCmdIn=open"
    - sv03.sv State Viewer does not change
    - Candidate Mgr current time is 3
13) Scenario Mgr->SINGLE
    - green line moves from "progress test.sv03.sv.valveCmdIn=open"
      to "fc"
    - State Viewer time: 4
    - State Viewer "Instance test.sv03.sv" background color white
    - State Viewer mode: open
    - Candidate Mgr current time is blank
14) Scenario Mgr->SINGLE
    - green line moves from "fc" to bottom and vanishes
    - yellow "edit" line is on "-- end-of-buffer --"
    - sv03.sv State Viewer does not change
    - Candidate Mgr current time is 4
15) Scenario Mgr->RESET
16) Repeat steps 05->14

Test 03 - Scenario Editing & Saving
-----------------------------------



#####################################################################

Stanley pull-down menus
=======================

File
----
   New Definition
   --------------
      Abstraction/Relation/Structure/Symbol/Value 
      -------------------------------------------
      Component/Module
      ----------------
   Open Definition 
   ---------------
      Abstraction/Relation/Structure/Symbol/Value 
      -------------------------------------------
      Component/Module
      ----------------
   Save Definition
   ---------------
      Abstraction/Relation/Structure/Symbol/Value 
      -------------------------------------------
      Component/Module
      ----------------
   Delete Definition 
   -----------------
      Abstraction/Relation/Structure/Symbol/Value 
      -------------------------------------------
      Component/Module
      ----------------
   Print Definition 
   ----------------

   New Workspace
   -------------
   Open Workspace 
   --------------


Edit (Component/Module only)
----------------------------
   Header
   ------
      Name, Variables, & Documentation
      --------------------------------
      Display Attribute
      -----------------
      Facts (Module only)
      ---------------------------
      Background Model (Component only) 
      -----------------------------------------
      Initial Conditions (Component only) 
      -------------------------------------------
   Instantiate
   -----------
      Attribute 
      ---------
      Component (Module only) 
      -------------------------------
      Mode (Component only)
      -----------------------------
      Module (Module only) 
      ----------------------------
      Terminal
      --------
   Delete
   ------
   Location Gridding On/Off
   ------------------------
   Preferences
   -----------


Test
----
   Scope
   -----
      Component
      ---------
      Module
      ------
   Compile
   -------
   Load & Go
   ---------
   Write IDD
   ---------
   Clean
   -----

Tools
-----
   Raise All Non-Canvas Windows
   ----------------------------
   Display Mode State Legend
   -------------------------
   Show/Hide Test Permanent Balloons
   ---------------------------------
   Delete All View Dialogs
   -----------------------
   Display Toplevel State Viewer Windows
   -------------------------------------
   Delete All State Viewer Windows 
   -------------------------------
   Component Faults
   ----------------

L2Tools
-----
   Browse
   ------
      Components
      ----------
      Modules
      -------


Scenario Manager pull-down menus (generated by Test->Load & Go)
===============================================================

File
----
   Open Scenario
   -------------
   Save Scenario
   -------------
   Delete Scenario
   ---------------
Edit
----
   Insert Cmd
   ----------
   Delete Line
   -----------
   Proposition Logging On/Off
   --------------------------

Scenario Manager button commands 
================================

SINGLE
------
STEP
---
RUN
---
RESET
-----









