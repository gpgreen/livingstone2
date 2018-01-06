global pirNodes
set pirNodes {152 1 2 4}
global pirNode
set pirNode(152) {edgesFrom {{} {}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.sv.pneumaticLineOut ?name.microSwitch} input_terminals {?name.sv.pneumaticLineIn ?name.sv.valveCmdIn} nodeInstanceName ?name nodeState NIL nodeStateBgColor gray90 nodeClassName solenoidValveAndMicroSwitch numInputs 2 numOutputs 2 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType module inputs {in1 {type {openCloseCommand in} terminal_name ?name.sv.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in2 {type {thresholdValues in} terminal_name ?name.sv.pneumaticLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} outputs {out1 {type {openIndicator out} terminal_name ?name.microSwitch terminal_label {} commandMonitorType {monitored unknown} interfaceType public} out2 {type {thresholdValues out} terminal_name ?name.sv.pneumaticLineOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName solenoidValveAndMicroSwitch numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {openIndicator in} terminal_name ?name.microSwitch terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.microSwitch nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 320 nodeY 360 labelX 294 labelY 335 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{displayState = sv.displayState;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w8}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {solenoidValveAndMicroSwitch output displayState}
global pirClass
set pirClass(solenoidValveAndMicroSwitch) {nodeClassType module inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} facts {default {if (sv.valvePosition = open)
   microSwitch = open;
else
   microSwitch = notOpen;}} input_terminals {default {{openCloseCommand ?name.sv.valveCmdIn {}} {thresholdValues ?name.sv.pneumaticLineIn {}}}} output_terminals {default {{openIndicator ?name.microSwitch {}} {thresholdValues ?name.sv.pneumaticLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}}}}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefmoduleFileName
set g_NM_livingstoneDefmoduleFileName {solenoidValveAndMicroSwitch}
global g_NM_livingstoneDefmoduleName
set g_NM_livingstoneDefmoduleName {solenoidValveAndMicroSwitch}
global g_NM_livingstoneDefmoduleNameVar
set g_NM_livingstoneDefmoduleNameVar {?name}
global g_NM_livingstoneDefmoduleArgList
set g_NM_livingstoneDefmoduleArgList {}
global g_NM_livingstoneDefmoduleArgTypeList
set g_NM_livingstoneDefmoduleArgTypeList {}
global g_NM_includedModules
set g_NM_includedModules {?name.sv {nodeClassName solenoidValve nodeClassType component pirNodeIndex 6 argsValues {} window .master.canvas.?name.c.w10 nodeX 310 nodeY 250 labelX 324 labelY 225 instanceLabel {} inputs {in1 {type {openCloseCommand in} terminal_name ?name.sv.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in2 {type {thresholdValues in} terminal_name ?name.sv.pneumaticLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} outputs {out1 {type {thresholdValues out} terminal_name ?name.sv.pneumaticLineOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}}}}
