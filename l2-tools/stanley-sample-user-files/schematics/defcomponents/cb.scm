global pirNodes
set pirNodes {56 1 2 4 6 8 10 12 14 16 18}
global pirNode
set pirNode(56) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.currentOut input_terminals {?name.currentIn ?name.cmdIn} nodeInstanceName ?name nodeState off nodeStateBgColor gray90 nodeClassName cb numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {cbCmd in} terminal_name ?name.cmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in2 {type {onOffState in} terminal_name ?name.currentIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} outputs {out1 {type {onOffState out} terminal_name ?name.currentOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName cb numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {cbCmd out} terminal_name ?name.cmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {Command to CB} nodeClassType terminal nodeInstanceName ?name.cmdIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 310 nodeY 140 labelX 302 labelY 115 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {onOffState out} terminal_name ?name.currentIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {Current flowing into CB.} nodeClassType terminal nodeInstanceName ?name.currentIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 480 nodeY 130 labelX 460 labelY 105 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {onOffState in} terminal_name ?name.currentOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {Current flowing out of CB.} nodeClassType terminal nodeInstanceName ?name.currentOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 390 nodeY 350 labelX 367 labelY 325 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 10 lineId 20 arrowId 21 defs {turnOff {documentation {} when {cmdIn = off;} next off cost 1}}} {startNode 10 stopNode 8}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{currentOut = currentIn;}} nodeDescription {Turn on CB} nodeClassType mode nodeInstanceName ?name.on nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 270 nodeY 230 labelX 277 labelY 205 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 10} {startNode 12 stopNode 10} {startNode 10 stopNode 8 lineId -1 arrowId 22 defs {turnOn {documentation {} when {cmdIn=on;} next on cost 1}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{currentOut = off;}} nodeDescription {Turn off CB} nodeClassType mode nodeInstanceName ?name.off nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 380 nodeY 220 labelX 384 labelY 195 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {} transitions {{startNode 12 stopNode 10 lineId 23 arrowId 24 defs {performReset {documentation {} when {cmdIn = reset;} next off cost 1}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability lessLikely model {{currentOut = off;}} nodeDescription {Resettable failure} nodeClassType mode nodeInstanceName ?name.tripped nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 510 nodeY 220 labelX 502 labelY 195 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unlikely model {{currentOut = off;}} nodeDescription {Blown CB} nodeClassType mode nodeInstanceName ?name.blown nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 150 labelX 608 labelY 125 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {Any behavior can occur here.} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 290 labelX 581 labelY 265 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = on)
  displayState = nominal;
else {
  if (mode = off)
    displayState = closed;
  else {
    if (mode = tripped | mode = blown)
      displayState = failed;
    else
      displayState = unknown;
  }
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w22}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {cb input output okMode faultMode displayState}
global pirClass
set pirClass(cb) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{cbCmd ?name.cmdIn {}} {onOffState ?name.currentIn {}}}} output_terminals {default {{onOffState ?name.currentOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}} mode {default off} ok_modes {default {on off}} fault_modes {default {tripped blown unknownFault}} mode_transitions {default {{on off} {off on} {tripped off}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default off} recovery_modes {default {tripped}}}}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {cb}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {cb}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
