global pirNodes
set pirNodes {23 1 2 4 6 8 10 12 14 16 18 20}
global pirNode
set pirNode(23) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes {?name.valvePosition ?name.displayState} port_terminals {} output_terminals ?name.pressurizationLineOut input_terminals {?name.pressurizationLineIn ?name.valveCmdIn} nodeInstanceName ?name nodeState closed nodeStateBgColor gray90 nodeClassName pressurizationLineSolenoidValve numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {openCloseCommand in} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in2 {type {pressurizationLine in} terminal_name ?name.pressurizationLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {pressurizationLine out} terminal_name ?name.pressurizationLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName pressurizationLineSolenoidValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = open)
   displayState = open;
else {
  if (mode = closed)
    displayState = closed;
  else {
    if (mode = stuckOpen | mode = stuckClosed)
      displayState = failed;
    else
      displayState = unknown;
}
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 40 nodeY 90 labelX 17 labelY 65 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 4} {startNode 4 stopNode 8 lineId -1 arrowId 22 defs {open {documentation {} when {valveCmdIn = open;} next open cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.closed nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 430 nodeY 180 labelX 425 labelY 155 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openCloseCommand out} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.valveCmdIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 200 nodeY 50 labelX 177 labelY 25 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 4 lineId 23 arrowId 24 defs {close {documentation {} when {valveCmdIn = close;} next closed cost 0}}} {startNode 4 stopNode 8}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{valvePosition = open;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.open nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 270 nodeY 180 labelX 271 labelY 155 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressurizationLine out} terminal_name ?name.pressurizationLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressurizationLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 360 nodeY 90 labelX 307 labelY 65 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressurizationLine in} terminal_name ?name.pressurizationLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressurizationLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 360 nodeY 340 labelX 304 labelY 315 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability rare model {{valvePosition = open;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckOpen nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 270 nodeY 250 labelX 256 labelY 225 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unlikely model {{valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckClosed nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 430 nodeY 250 labelX 410 labelY 225 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openClosedValues out} terminal_name ?name.valvePosition terminal_label {} commandMonitorType ?name.valvePosition interfaceType {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.valvePosition nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 100 nodeY 260 labelX 74 labelY 235 window .master.canvas.?name.c.w22}

set pirNode(20) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 560 nodeY 250 labelX 552 labelY 225 window .master.canvas.?name.c.w24}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pressurizationLineSolenoidValve displayState okMode input output faultMode attribute}
global pirClass
set pirClass(pressurizationLineSolenoidValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{openCloseCommand ?name.valveCmdIn {}} {pressurizationLine ?name.pressurizationLineIn {}}}} output_terminals {default {{pressurizationLine ?name.pressurizationLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState} {openClosedValues ?name.valvePosition {}}}} mode {default closed} ok_modes {default {closed open}} fault_modes {default {stuckOpen stuckClosed unknownFault}} mode_transitions {default {{closed open} {open closed}}} background_model {default {if (valvePosition = open)
   pressurizationLineOut = pressurizationLineIn;

if (valvePosition = closed)
   pressurizationLineOut.contents = tankMixture;}} background_documentation {default {}} initially {default {}} initial_mode {default closed} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(attribute) {cfg_file attribute.cfg attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {pressurizationLineSolenoidValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {pressurizationLineSolenoidValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
