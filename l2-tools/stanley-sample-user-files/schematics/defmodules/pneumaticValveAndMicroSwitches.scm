global pirNodes
set pirNodes {149 1 2 4}
global pirNode
set pirNode(149) {edgesFrom {{} {}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.pv.lO2FeedLineOut ?name.positionIndicator} input_terminals {?name.pv.lO2FeedLineIn ?name.pv.pneumaticsLineIn} nodeInstanceName ?name nodeState NIL nodeStateBgColor gray90 nodeClassName pneumaticValveAndMicroSwitches numInputs 2 numOutputs 2 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType module inputs {in1 {type {thresholdValues in} terminal_name ?name.pv.pneumaticsLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public} in2 {type {lO2FeedLine in} terminal_name ?name.pv.lO2FeedLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {openClosedIndicator out} terminal_name ?name.positionIndicator terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public} out2 {type {lO2FeedLine out} terminal_name ?name.pv.lO2FeedLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 112 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName pneumaticValveAndMicroSwitches numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {openClosedIndicator in} terminal_name ?name.positionIndicator terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.positionIndicator nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 310 nodeY 360 labelX 272 labelY 335 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{displayState = pv.displayState;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w8}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pneumaticValveAndMicroSwitches output displayState}
global pirClass
set pirClass(pneumaticValveAndMicroSwitches) {nodeClassType module inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} facts {default {if (pv.valvePosition = open)
   positionIndicator.openIndicator = open &
   positionIndicator.closedIndicator = notClosed;

if (pv.valvePosition = closed)
   positionIndicator.openIndicator = notOpen &
   positionIndicator.closedIndicator = closed;}} input_terminals {default {{thresholdValues ?name.pv.pneumaticsLineIn {}} {lO2FeedLine ?name.pv.lO2FeedLineIn {}}}} output_terminals {default {{openClosedIndicator ?name.positionIndicator {}} {lO2FeedLine ?name.pv.lO2FeedLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}}}}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefmoduleFileName
set g_NM_livingstoneDefmoduleFileName {pneumaticValveAndMicroSwitches}
global g_NM_livingstoneDefmoduleName
set g_NM_livingstoneDefmoduleName {pneumaticValveAndMicroSwitches}
global g_NM_livingstoneDefmoduleNameVar
set g_NM_livingstoneDefmoduleNameVar {?name}
global g_NM_livingstoneDefmoduleArgList
set g_NM_livingstoneDefmoduleArgList {}
global g_NM_livingstoneDefmoduleArgTypeList
set g_NM_livingstoneDefmoduleArgTypeList {}
global g_NM_includedModules
set g_NM_includedModules {?name.pv {nodeClassName pneumaticValve nodeClassType component pirNodeIndex 6 argsValues {} window .master.canvas.?name.c.w10 nodeX 300 nodeY 260 labelX 314 labelY 235 instanceLabel {} inputs {in1 {type {thresholdValues in} terminal_name ?name.pv.pneumaticsLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public} in2 {type {lO2FeedLine in} terminal_name ?name.pv.lO2FeedLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.pv.lO2FeedLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}}}}
