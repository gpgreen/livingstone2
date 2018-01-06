# $Id: README-SCHEMATIC.txt,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

Contents
--------
o SCHEMATIC OBJECTS
o CREATING SCHEMATICS & GENERATING JMPL CODE
o RENAMING COMPONENT OR MODULE DEFINITIONS
o DISPLAY STATE COLORING
o INSTRUMENTING AND COMPILING GENERATED JMPL CODE

o SCENARIO MANAGER
o TESTING BY INTERACTIVELY SETTING MONITOR/COMMAND VALUES 
o TESTING USING SCENARIO SCRIPTS
o VIEWING TEST RESULTS IN STANLEY

o COMMENTARY ON DEVELOPING THE CAR SCHEMATIC

o FILES CREATED BY STANLEY
o CVS CHECK-IN OF STANLEY USER WORKSPACE FILES


SCHEMATIC OBJECTS 
-----------------
Types:
  JMPL types all entities as in Java.  Stanley allows the
user to define these types.  Component and module definitions
become JMPL class types. Value, and structure definitions define
connection types in Stanley and become variable types in
JMPL.

Primitives:
  attributes -- have a value or structure type.  They have JMPL
    constraints on input/output terminals and/or component
    modes.  May define and set JMPL variables.  They cannot
    be connected to any other schematic objects, and cannot
    be inherited to instantiated containing components or 
    modules.
  modes -- only components have mode states.  They define
    constraints on input/output terminals and attributes.
    There are two kinds of modes: ok and fault.  Fault modes
    are required to have a probability of occurrence, which
    may be a symbolic value defined by a symbol class, or
    may be a numeric value.
  transitions -- these define mode state changes with a
    precondition and a numeric cost.  Transitions may be
    defined between two ok modes, two fault modes, or from 
    a fault mode to an ok mode.  L2 does the state changes
    from ok modes to fault modes.
  terminals -- have a value or structure type; an external
    accessibility of either commanded or monitored, which 
    defines a default value; and an interface type of either
    public or private.  A value of public means that the
    terminal will be inherited to the instantiated containing
    component or module.  Private terminal are not inherited.
    When defined in components, they may not be connected to
    any other objects.  When defined in modules, they may be 
    connected to the inherited terminals on instantiated
    components and modules.

User defined classes:
  abstractions -- these allow the user to connect disparate 
    terminal types, by defining an appropriate mapping.
  components -- leaf nodes of schematic hierarchy, which contain
    modes, transitions, terminals, and attributes.
  modules -- non-leaf nodes of schematic hierarchy, which contain
    terminals, attributes, components, and modules.
  relations -- allow definition of arbitrary relations between
    typed variables.
  structures -- define terminal connection types as sets of 
    enumerated sets of values.
  symbols -- define simple mappings of symbols to numeric values.
    Primarily used to define symbolic fault mode probabilities.
  values -- define terminal connection types as sets of enumerated 
    values.

Parameterized terminal types:
  - define a "structure" class which will be common to the 
    "child" classes, of which this class will be the "parent" 
    ("File->New Definition->Structure").
    Set "Parameterized Terminal Type" to "yes".  This class 
    will have an "<unspecified>" parent type.
  - define two or more "child" structure classes, each with
    at least one argument.  Set "Parent Type" to the "parent"
    class you just defined.
  - add a parameter variable with this new "parent" type to
    the appropriate component/module parameter list
    ("Edit->Header->Name, Variables, and Documentation").
  - in the component/module, create terminals whose type field 
    is the parameter  variable ("File->Edit->Instantiate->
    Terminal->{input | output}").  The parameter variable will 
    be available in the terminal type option menu.
  - instantiate ("Edit->Instantiate->{Component | Module}->...")
    the component/module in an enclosing module
    and you will be prompted for a value for the
    parameter type, which will be one of the set of "child" 
    structure classes comprising the parameter variable type.


CREATING SCHEMATICS & GENERATING JMPL CODE
---------------------------------------------
The basic assumption is that the user will be creating
schematics, which will then be used by Stanley to generate
the JMPL code for abstraction, module, component, value,
relation, symbol, and structure class definitions in the 
Livingstone model directory: {workspace root}/livingstone/models.

% cd {released-root}/l2-tools/stanley-jmpl/interface
% ./stanley

The Stanley window will come to the top, indicating that 
the user can begin creating schematics/JMPL code.

 1) Tell Stanley what kind of defintion you are building
  a> Menu select: "File => New Definition =>
     { Abtraction Component Module Relation Structure Symbol Value }
  b> Selecting Component or Module will reinitialize and
     clear the canvas.
  c> Selecting Abtraction, Relation, Structure, Symbol, or Value will
     pop-up a dialog for creating a new class instance -- 
     clicking OK on the dialog will save the
     Stanley representation for it.  Since editing these class
     definitions does not reinitialize the canvas, it can
     be done during the building of a Component or Module.

Subheadings 2) -> 11) apply only to components and modules.

 2) Use menu selection "Edit => Header =>
  - Name, Arguments, & Documentation: only Name is required;
  - Display Attribute: optional;
  - Facts: optional; (modules only)
  - Background Model: optional; (components only)
  - Initial Conditions: only Initial Mode is required;
            (components only) 
  at any time prior to selecting "File => Save Defintion".

 3) Instantiate class definitions by using menu selection
  Edit => Instantiate =>
  - Attribute: enabled for components & modules;
  - Component: enabled for modules;
  - Mode: enabled for components;
  - Module: enabled for modules;
  - Terminal: enabled for components & modules;
  all except Attribute will have "cascading" selections.

 4) You will be presented with a dialog, in which you enter:
  - Attribute: 
       Name, & Type -- required;
       Label, Facts, & Documentation -- optional;
  - Component: 
       Name, and maybe parameter values -- required;
       Label -- optional;
  - Mode => ok-mode:
       Name -- required;
       Model, & Documentation -- optional;
  - Mode => fault-mode:
       Name, & Probability -- required;
       Model, & Documentation -- optional;
  - Module: 
       Name, and maybe parameter values -- required;
       Label -- optional;
  - Terminal => Input/Output: 
       Name, Type, Comamnded or Monitored, & Cmd/Mon Default Value -- required;
       Label, & Documentation -- optional;

  Name entries are checked for uniqueness. Dialog fields whose
  contents are Java-like code can take advantage of the proposition
  "cut-and-paste" facility for modes, terminals and attributes.
  Place the mouse cursor over the mode icons, the small triangles 
  for terminals or over the rectangle for attributes, and select
  the proposition from the cascading menu "copy {node} proposition"
  using the right mouse button.  Also, "cut-and-paste" is enabled 
  in the code fields of all dialogs -- multiple dialogs can be 
  concurrently displayed.

  Mouse-Left on "OK" completes the dialog.

 5) Repeat steps 3) and 4) to instantiate more components,
  modules, attributes, modes, and terminals.  By default,
  all component and module nodes are displayed as rectangles.
  Optionally, they can be displayed as bitmap images with 
  transparancy:

  {workspace-root}/bitmaps/ optionally will contain
  pairs of files:
  {nodeClassName} => bitmap; 1 = foreground; 0 = background 
      (created by bitmap utility)
  {nodeClassName}-mask => bitmap; 1 = show fg/bg; 0 = transparent 
      (created by bitmap utility ) 

 6) Connect appropriate terminals between the component/
  module/terminal nodes, by Mouse-Middle clicking on one of the
  two terminals, holding down, dragging to the other terminal
  and releasing.  Balloon help pop-ups will show each potential
  terminal's type, so that matching types can be connected.
  The two terminals must be of opposite direction: typically one 
  an output (V on bottom of a node), and one an input (V on top 
  of a node).  Since terminal "buttons" on components and modules
  can be moved from top to bottom, or bottom to top, the down-
  pointing triangle can become an up-pointing triangle. 
  Non-matching types may be connected by defining Abstractions,
  which can be done "on-the-fly".  The default number of connection
  line breaks is two. Connection Mouse-Right menu selection
  "toggle num breaks" will transform it to a four-break from a
  two-break connection, and vicea-versa.  See the "Attention" area 
  for more operations on connections.

  Each terminal has a public/private property, which defaults to:
  standalone terminals and unconnected component/module terminals 
  are public -- and inherited up one hierarchical level; connected
  component/module terminals are private -- and not inherited.  
  This property may be changed using the Mouse-Right "public/private
  toggle" menu selection.  The small terminal icon meanings are: filled 
  up/down triangles => public; outline up/down triangles => private.
  
 7) Nodes and connection segments can be "dragged" to new 
  locations by clicking Mouse-Left, holding, moving, and 
  releasing.

 8) Use Control-Mouse-Left on a componenet or module to
  "open" it, entering the next lower hierarchical level.  
  To return to next higher hierarchical level, you click 
  Mouse-Left on the "<= Back" accelerator button located
  under the pull-down menu buttons.

 9) Use menu selection "Edit => Instances => Location Gridding Off" 
  to allow the exact horizontal alignment of a connection between two
  nodes.  When done, menu selection 
  "Edit => Instances => Location Gridding On" returns to the default 
  placement mechanism, which is to snap your placement of nodes to 
  an x/y grid with a resolution of 10 pixels.

10) Use menu selection "Edit => Delete" to remove nodes and their 
  connections, after they have been selected by "dragging" Mouse-Left 
  to encompass them.  Ech node can be separately deleted by
  selecting "delete {label}" from the Mouse-Right menu.

11) Use menu selection "File => Save Definition" to save
  your module or component class definition schematic file (".scm"
  extension).  Also written is a special standalone instantiatable 
  schematic file with a ".i-scm" extension. and a file used to 
  determine terminal inheritance (".terms").  For modules only, an 
  included component/module file (".inc"), is written.

  JMPL code for each component and module is written to a separate file, 
  using the user defined class definition name.  Its file extension
  is ".jmpl".  

  If you have not defined "Edit => Header =>Display Attribute", you
  will be prompted to enter the appropriate code, or use the default
  which will hard-code the display state to "indeterminate".  See the
  section "Display State Coloring" in this file and section
  "Component/Module Mode State Names and Colors" in file
  "l2-tools/stanley-jmpl/README-STANLEY-VJMPL.txt" or in 
  "HELP->Help...->Setting up and Running Stanley" for details.

12) The abstractions, relations, symbols, structures, and values are each 
  written as a group to a file named for their class type, each time
  one is added, deleted, or modified, by using menu selections
  "File => New Definition => {Abstraction Relation Symbol Structure Value}"
  "File => Delete Definition => {Abstraction Relation Symbol Structure Value}"
  "File => Open Definition => {Abstraction Relation Symbol Structure 
Value}"

13) Use menu selection "Tools => Raise All Non-Canvas Windows" to 
  "find" active dialogs that have been buried by other windows.

14) Use menu selection "Edit => Preferences" to change default
  values for fonts, colors, and sizes.  Some apply to both Stanley
  VJMPL and OPS configurations, and others apply to one or the
  other.


RENAMING COMPONENT OR MODULE DEFINITIONS
------------------------------------------------------------
Stanley does not have a "File->Rename Definition" operation.  The
following describes a series of steps to accomplish it:

- Use "File->Open Definition" to load the old definition, call it
  x-def;
- Use "Edit->Header->Name, Args & Documentation to change
  x-def to say, new-x-def, and use "File->Save Definition" 
  to save new-x-def.  Now both the x-def and new-x-def definitions 
  will exist.

- Exit Stanley

- Delete files <workspace-root>/schematics/defcomponents/
    <component-name>{.i-scm|.dep|.terms} 
  or
    <workspace-root>/schematics/defmodules/
         <module-name>{.i-scm|.dep|.terms}

- Edit <workspace-root>/schematics/defcomponents/<component-name>.scm
  or
       <workspace-root>/schematics/defmodules/<module-name>.scm
  globally replace "x-def" with "new-x-def"

- Restart Stanley

- Use "File->Delete Definition" to attempt to delete the x-def 
  definition.  

If the deletion is successful, you are done. If you get a warning
dialog specifying dependencies on the x-def definition, do this:

- Use "File->Open Definition" to load each definition which has a
  dependency on x-def; select and "Edit->Delete" the x-def instance(s);
  "Edit->Instantiate" an instance or instances of new-x-def and
  "File->Save Definition" the modified dependent definition.  This 
  removes the dependencies on x-def.
- Use "File->Delete->Definition" to delete x-def.  Since the dependencies
  have been removed from the other definitions, Stanley will delete all 
  of x-def's files, both schematic (.scm, .i-scm, .terms, & .inc) and 
  JMPL (.jmpl).  


DISPLAY STATE COLORING
----------------------
The states of modules and components can be displayed as different
background colors representing the current Livingstone mode states. 
JMPL code can be written to use the component modes and other
variables to set the "displayState" value (color name) for each 
component and module.  This is done using pull-down menu 
"Edit-Header->Display Attribute ..."

Display state color names `noData', `indeterminate', and
  `unknownL2Value' are reserved such that they are set by 
  "Edit->Preferences->L2Tools/User/Workspace"
  (StanleyNodataStateBgColor, StanleyIndeterminateStateBgColor, &
  StanleyUnknownL2ValueStateBgColor), but cannot be changed by 
  "Edit->Preferences->Workspace Display State Colors".
  The latter pull-down menu option manages all other display
  state colors, which are saved in the workspace file:
  display-state-color-prefs.  The reserved display states are 
  defined thusly:

  noData - Stanley has received no value from L2
  indeterminate - Stanley cannot determine the display state color
  unknownL2Value - Stanley has received the value "unknown" from L2
                   (could not determine which of the variable's
                    propositions was true)

  The default display state is hard-coded to "indeterminate".  
  User defined JMPL style display state code does not need to set 
  any of the reserved states, as they are handled by Stanley.


INSTRUMENTING AND COMPILING GENERATED JMPL CODE
------------------------------------------------------------
"Instrument" the component and module terminals in the 
module hierarchy which are to be tested, i.e. "File =>
Open Definition", then select "edit {label}" from the Mouse-Right
menu of each terminal nodes, and specifying values for
"Commanded or Monitored" and "Cmd/Monitor Default Value".

"Commanded or Monitored" values:
- commanded - use its default value for the "Step" transition, if 
              user does not specify a value; if user specifies a 
              value, use it for the "Step" transition, then return
              to the default value.
- monitored - initially has its default value, and if user specifies
              a value, it uses this value for the "Step" transition
              and maintains it until changed by user.

Use menu selection "Test => Scope" to select the scope of JMPL
code which will be compiled and executed.  The selected module 
scope will appear in the bottom banner: "Scope: {selection}".

This enables the "Compile" operation.  Use the menu selection 
"Test => Compile" to compile the JMPL code for the selected
scope.  This is done by the JMPL to XMPL compiler -- you will 
see any compile error messages.  Compile errors are resolved by 
correcting the JMPL code fragments entered into the schematics, 
and recompiling using "Test => Compile".

Use menu selection "Test => Clean" to delete all compiled files,
so that a "clean" compilation can be done.

"Test => Load & Go" will cause Livingstone to load these files created
by Stanley:
o the "test harness" file defining the "commanded" and "monitored" 
  terminals which you specified (extension ".hrn");
o the compiled XML model file (extension ".xmpl); 
o the initialization file containing inital component mode values
  and other initial constraint assigments (extension ".ini"); and
o the L2 search parameters file (extension ".params")
and to create the Scenario Manager.


SCENARIO MANAGER
----------------
The Stanley Scenario Manager supports script command execution via:
o the SINGLE button -- send the command on the green line to 
  Livingstone, and check for L2 theory consistency;
o the STEP button -- send the commands from the "green" line to 
  the next fc command, or next break point, to Livingstone;
o the RUN button -- send the commands from the "green" line to 
  the end of the script, or next break point, to Livingstone;
o the WARP button -- the same as RUN, except that the L2
  tools, including Stanley, do not process them and do not reflect
  the state of Livingstone, which executes them as fast as possible.
  The user must them use SINGLE or STEP to execute a find candidates
  command, in order for the L2 tools, including Stanley to
  show the current state of Livingstone;
o the RESET button -- terminates execution of STEP, RUN, or WARP
  buttons, saves any outstanding scenario files, and creates a
  new instance of the Scenario Manager.

The Scenario Manager supports interactive editing via line marking activated 
by clicking Mouse-left (the line's background becomes yellow).
Insertions via "Edit->Insert Command", "Edit->Insert Comment", and 
Mouse-right selections on component command/monitor terminals, are 
inserted *before* the edit mark line.  "Edit->Delete Line" will 
remove the edit mark line.

The Scenario Manager also supports break points.  BP tokens appear 
in the first column of statements which can have break points set.  
Clicking on a token will set the break point and turn the token
background color to red.  Clicking on a token whose background color
is red will turn off the break point.  Break points are saved in a 
companion file to script-name.scr: script-name.dbg, and thus are 
available after RESETs and in successive Stanley sessions.

"File->New Scenario", "File->Open Scenario", "File->Save Scenario", and 
"File->Delete Scenario" support the running, creation, and deletion
of scenario files.

 
TESTING BY INTERACTIVELY SETTING MONITOR/COMMAND VALUES 
------------------------------------------------------------
To specify "instrumented" values, place the mouse cursor over the small
triangles of each terminal.  A temporary balloon pop-up will show the 
name, label, type, value, and either commanded or monitored 
(the instrument type).  The terminals which are not "instrumented" will 
not have the commanded or monitored field in the balloon pop-up.  Also the 
"Attention" area will show {Mouse-R menu}: select value(s).  Press down the 
right mouse button to get a list of possible values -- select one or
more (for structured types) by releasing over it.  "Instrumented" 
terminals for which you do not specify a value, will have default 
values determined by Livingstone.

Selections will be added to the Scenario Manager window as you make them.

Once you have specified the desired terminal values, click on the 
SINGLE/STEP/RUN buttons and your selected forms will be executed in 
Livingstone.  The results of the SINGLE/STEP/RUN buttons will be shown 
as one or more candidates in the L2Tools Candidate Manager, and as 
the predicted values for those terminals for which you did not constrain.  
The semi-permanent balloon pop-ups will reflect the predicted values set 
by Livingstone, by changing their backgrounds from light-yellow to maroon.
By default, the semi-permanent balloon pop-ups are buried, and can be
viewed using "Tools->Show Test Permanent Balloons".

You may make more terminal selections, and/or use "Edit->Insert Command"
to place L2 commands into the interactive script.  These commands will 
be executed when you next click on SINGLE/STEP/RUN.

At any time after the execution of the first step, you may select
"File->Save Scenario" from the Scenario Manager to save your 
interactive commands as a named script, which may be invoked later.  
You will be prompted for a script name.


TESTING USING SCENARIO SCRIPTS
------------------------------------------------------------

Rather than interactively setting monitored/commanded values and 
"stepping",  you may create with your text editor, script files
(extension ".scr") which invoke "progress", "assign", "truncate", 
"fc", etc operations.  These files should be located in 
{workspace-root}/livingstone/models/scenarios/.  The file name 
should be the same as the scenario name defined in the first
line of the file, i.e.
scenario {scenario_name} {component/module_name}
  ....

will be in file {scenario_name}.scr.  Scenario Manager buttons 
SINGLE/STEP/RUN/WARP may be used to execute the scenario selected
by Scenario Manager pull-down menu "File->Open Scenario".

You may also configure break points by defining a companion file
to the .scr file: {scenario_name}.dbg, with one entry per line for
each break point.  The line number (starting with line 1, not 0)
will be the next line to be executed when you continue from the
break point, i.e.
breakPoint_6
breakPoint_9
...

Rather than creating scenario files and break point files with 
your favorite text editor, you may just select "File->Save Scenario" 
on the Scenario Manager to save interactive script and break point
files, as described above.


VIEWING TEST RESULTS IN STANLEY
------------------------------------------------------------

Livingstone will send the propositional values of changed terminals back
to Stanley, when you have clicked on SINGLE, STEP, and RUN. It will
*not* do this if you have clicked on WARP.  These values can be viewed 
by placing the mouse cursor over components or modules and selecting 
"show {mode and} propositions" from the Mouse-Right menu.  This brings 
up the current "state viewer".  Individual terminal values can be viewed
 by placing the mouse cursor over the triangle icons.

The currently displayed L2Tools time stamp is displayed on the far 
right of the lower legend bar, and on each State Viewer dialog.


COMMENTARY ON DEVELOPING THE CAR SCHEMATIC
------------------------------------------
The default workspace contains a simple schematic named "car".  The
following is some commentary on its development.

Creating the Model
The task is to create a very simple model of a car. Specifically, assume you 
are able to observe the operation of the car's radio, clock, and engine and 
assume that you have access to the battery, electrical fuse, and starter motor. 
You want to be able to determine, based on your observations and your actions 
taken to troubleshoot the car, which system(s) have failed. Assume that the key 
is in the "accessories" position initially so that the car is receiving 
electrical power but the engine is not running.

The following features and restrictions apply: the radio may be turned on and 
off and can fail; initially the radio is off; the (electrical) clock is 
normally on but can fail; the clock and radio operate off of the same fuse; 
the state of the fuse is not observable but it can be replaced; the battery 
may be jumpstarted; when the ignition key is turned, it starts a starter motor 
which causes the engine to turn; the starter motor may fail but the engine 
cannot fail.

Testing the Model
Scenarios have been created to answer the following questions:

carTest1:
Let's say you turn the radio on but don't hear anything. Assume you don't look 
at the clock for the moment. What is the diagnosis? Install the candidates and 
see what is predicted for the other observations. Now, let's say that you glance 
over to the clock and see that the clock is on. How does that modify the diagnosis? 

carTest2:
You look at the clock but it doesn't display the time. What is the diagnosis? 
You turn on the radio but it's not working. The diagnosis? Now, you turn the 
ignition key to start the engine and observe that the engine is running. How 
does that modify the diagnosis? Finally, you replace the fuse and the radio and 
clock come on. 

carTest3:
You don't bother turning on the radio and fuzzy dice obstruct your view of the 
clock. You attempt to turn on the engine but nothing happens. What is the 
diagnosis? You're just itching to try out your new jumper cables so you hop out 
of the car jumpstart the battery and the engine roars to life?

carTest4:
You hop in the car and turn the key but nothin' doin'.  Initial diagnosis? You 
look at the clock and it's telling you that you are way late for an appointment. 
Modified diagnosis? 


FILES CREATED BY STANLEY
------------------------------------------------------------
Stanley will create schematic files in
{workspace-root}/schematics/
   {abstractions defcomponents defmodules defrelations structures 
     defsymbols defvalues}

{xx}.scm        ## root schematic files which are sourced by
                ## "File->Open Class Defintion"
{xx}.i-scm      ## instantiation schematic files which are
                ## sourced by instantiating a Stanley
                ## created defmodule or defcomponent.
                
{xx}.scm files contain all the information needed to create the
other generated files, so that the {xx}.i-scm files are automatically 
created by Stanley, if not present.  Also true for {xx}.terms and
{xx}.inc files.

JMPL Java-like syntax files created in {workspace-root}/livingstone/models/*
are also automatically created from the {xx}.scm files, if not present.


CVS CHECK-IN OF STANLEY USER WORKSPACE FILES
-----------------------------------------------------------------
To check your user workspace files into CVS, add these files:

{workspace-root}/display-state-color-prefs
{workspace-root}/workspacePrefs
{workspace-root}/bitmaps/*
{workspace-root}/schematics/abstractions/*.scm
{workspace-root}/schematics/defcomponents/*.scm
{workspace-root}/schematics/defmodules/*.scm
{workspace-root}/schematics/defrelations/*.scm
{workspace-root}/schematics/defsymbols/*.scm
{workspace-root}/schematics/defvalues/*.scm
{workspace-root}/schematics/structures/*.scm
{workspace-root}/livingstone/models/*.jmpl
{workspace-root}/livingstone/models/components/*.jmpl
{workspace-root}/livingstone/models/modules/*.jmpl
{workspace-root}/livingstone/models/scenarios/*.scr













