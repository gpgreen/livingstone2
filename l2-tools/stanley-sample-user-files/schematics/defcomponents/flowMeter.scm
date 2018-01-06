global pirNodes
set pirNodes {47 1 2 4 6 8 10 12}
global pirNode
set pirNode(47) {edgesFrom {{} {}} edgesTo {{}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.pipeOut ?name.flowReading} input_terminals ?name.pipeIn nodeInstanceName ?name nodeState ok nodeStateBgColor gray90 nodeClassName flowMeter numInputs 1 numOutputs 2 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pipe in} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {flowValues out} terminal_name ?name.flowReading terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public} out2 {type {pipe out} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName flowMeter numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{pipeIn.equal(pipeOut);}} nodeDescription {this.pipeIn.flow.equal(this.flowReading);} nodeClassType mode nodeInstanceName ?name.ok nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 330 nodeY 250 labelX 337 labelY 225 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (this.mode = unknownFault)
  this.displayState = unknown;
else {
if (this.pipeIn.flow.rel = high)
  this.displayState = high;
else {
if (this.pipeIn.flow.rel = nominal)
  this.displayState = nominal;
else {
if (this.pipeIn.flow.rel = low)
  this.displayState = low;
else {
if (this.pipeIn.flow.sign = zero)
  this.displayState = zero;
else {
if (this.pipeIn.flow.sign = negative)
  this.displayState = negative;
}}}}};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 70 labelX 27 labelY 45 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 250 labelX 605 labelY 225 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {flowValues in} terminal_name ?name.flowReading terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.flowReading nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 560 nodeY 380 labelX 534 labelY 355 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 470 nodeY 120 labelX 459 labelY 95 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 390 nodeY 380 labelX 376 labelY 355 window .master.canvas.?name.c.w16}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {flowMeter okMode displayState faultMode output input}
global pirClass
set pirClass(flowMeter) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default ?context} documentation {default {}} input_terminals {default {{pipe ?name.pipeIn {}}}} output_terminals {default {{flowValues ?name.flowReading {}} {pipe ?name.pipeOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default ok} ok_modes {default ok} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default ok} recovery_modes {default {}} argTypes {default contextValue}}}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {flowMeter}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {flowMeter}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {?context}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {contextValue}
