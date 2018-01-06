global pirNodes
set pirNodes {141 1 2 4 6 8 10 12}
global pirNode
set pirNode(141) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.powerOut input_terminals ?name.jumperCmdIn nodeInstanceName ?name nodeState charged nodeStateBgColor gray90 nodeClassName battery numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {jumperCmd in} terminal_name ?name.jumperCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} outputs {out1 {type {onOffState out} terminal_name ?name.powerOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 136 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName battery numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} transitions {{startNode 4 stopNode 2}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{powerOut = on;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.charged nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 190 nodeY 190 labelX 182 labelY 165 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} transitions {{startNode 4 stopNode 2 lineId 14 arrowId 15 defs {jumpStart {documentation {} when {jumperCmdIn = jump;} next charged cost 1}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability 0.1 model {{powerOut = off;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.discharged nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 310 nodeY 190 labelX 296 labelY 165 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {jumperCmd out} terminal_name ?name.jumperCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.jumperCmdIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 250 nodeY 80 labelX 230 labelY 55 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {onOffState in} terminal_name ?name.powerOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.powerOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 250 nodeY 320 labelX 233 labelY 295 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = charged)
   displayState = nominal;
else {
   if ( mode = discharged )
      displayState = failed;
   else
      displayState = unknown;
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 400 nodeY 190 labelX 392 labelY 165 window .master.canvas.?name.c.w16}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {battery okMode faultMode input output displayState}
global pirClass
set pirClass(battery) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{jumperCmd ?name.jumperCmdIn {}}}} output_terminals {default {{onOffState ?name.powerOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}} mode {default charged} ok_modes {default charged} fault_modes {default {discharged unknownFault}} mode_transitions {default {{discharged charged}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default charged} recovery_modes {default {discharged}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {battery}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {battery}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
