global pirNodes
set pirNodes {114 1 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30 32}
global pirNode
set pirNode(114) {edgesFrom {{} {} {} {}} edgesTo {{} {} {} {} {} {} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.ggPressure ?name.turbineInletTemp ?name.rp1Out ?name.loxOut} input_terminals {?name.ipsPurgeGheIn ?name.ggPyroCmd ?name.ggRp1In ?name.ggLoxIn ?name.spinStartGheIn ?name.mainRp1In ?name.mainLoxIn} nodeInstanceName ?name nodeState stopped nodeStateBgColor gray90 nodeClassName turbopumpAssembly numInputs 7 numOutputs 4 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pipe in} terminal_name ?name.mainLoxIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} in2 {type {pipe in} terminal_name ?name.mainRp1In terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} in3 {type {pipe in} terminal_name ?name.spinStartGheIn terminal_label {} commandMonitorType {commanded {low positive low positive}} interfaceType public} in4 {type {pipe in} terminal_name ?name.ggLoxIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} in5 {type {pipe in} terminal_name ?name.ggRp1In terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} in6 {type {onOffCommand in} terminal_name ?name.ggPyroCmd terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in7 {type {pipe in} terminal_name ?name.ipsPurgeGheIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {pipe out} terminal_name ?name.loxOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} out2 {type {pipe out} terminal_name ?name.rp1Out terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} out3 {type {temperatureValues out} terminal_name ?name.turbineInletTemp terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public} out4 {type {pressureValues out} terminal_name ?name.ggPressure terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 148 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName turbopumpAssembly numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.mainLoxIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.mainLoxIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 210 nodeY 80 labelX 190 labelY 55 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.loxOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.loxOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 210 nodeY 500 labelX 199 labelY 475 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.mainRp1In terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.mainRp1In nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 280 nodeY 80 labelX 260 labelY 55 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.rp1Out terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.rp1Out nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 280 nodeY 500 labelX 269 labelY 475 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.spinStartGheIn terminal_label {} commandMonitorType {commanded {low positive low positive}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.spinStartGheIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 370 nodeY 80 labelX 335 labelY 55 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.ggLoxIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ggLoxIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 460 nodeY 80 labelX 446 labelY 55 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.ggRp1In terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ggRp1In nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 530 nodeY 80 labelX 516 labelY 55 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {onOffCommand out} terminal_name ?name.ggPyroCmd terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ggPyroCmd nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 610 nodeY 80 labelX 590 labelY 55 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {temperatureValues in} terminal_name ?name.turbineInletTemp terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.turbineInletTemp nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 550 nodeY 500 labelX 509 labelY 475 window .master.canvas.?name.c.w22}

set pirNode(20) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressureValues in} terminal_name ?name.ggPressure terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ggPressure nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 630 nodeY 500 labelX 607 labelY 475 window .master.canvas.?name.c.w24}

set pirNode(22) {edgesFrom {} edgesTo {} transitions {{startNode 22 stopNode 26 lineId 34 arrowId 35 defs {startTurbine {documentation {} when {this.spinStartGheIn.pressure.sign = positive;
this.spinStartGheIn.pressure.rel = nominal;
this.spinStartGheIn.flow.sign = positive;
this.spinStartGheIn.flow.rel = nominal;} next spinStart cost 0}}} {startNode 24 stopNode 22}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.mainRp1In.equal(this.rp1Out);
this.mainLoxIn.equal(this.loxOut);}} nodeDescription {Before startup, RP-1 and LO2 just flow through.} nodeClassType mode nodeInstanceName ?name.stopped nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 240 nodeY 250 labelX 232 labelY 225 window .master.canvas.?name.c.w26}

set pirNode(24) {edgesFrom {} edgesTo {} transitions {{startNode 26 stopNode 24} {startNode 24 stopNode 22 lineId 36 arrowId 37 defs {shutdown {documentation {The turbopump stops when the flow of RP-1 and/or LO2 into the gas generator 
is cut off.} when {this.ggLoxIn.flow.sign = zero |
this.ggRp1In.flow.sign = zero;} next stopped cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.mainLoxIn.flow.equal(this.loxOut.flow);
this.mainRp1In.flow.equal(this.rp1Out.flow);}} nodeDescription {Need to describe increase in outlet pressure.} nodeClassType mode nodeInstanceName ?name.running nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 500 nodeY 250 labelX 492 labelY 225 window .master.canvas.?name.c.w28}

set pirNode(26) {edgesFrom {} edgesTo {} transitions {{startNode 22 stopNode 26} {startNode 26 stopNode 24 lineId 38 arrowId 39 defs {firePyro {documentation {There must be RP-1 and liquid oxygen present when the pyro is fired to start
up the turbopump.} when {this.ggPyroCmd = on;
this.ggLoxIn.flow.sign = positive;
this.ggLoxIn.flow.rel = nominal;
this.ggRp1In.flow.sign = positive;
this.ggRp1In.flow.rel = nominal;} next running cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.spinStart nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 370 nodeY 190 labelX 356 labelY 165 window .master.canvas.?name.c.w30}

set pirNode(28) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {Generic catch-all mode; add specific failures later.} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 370 nodeY 310 labelX 365 labelY 285 window .master.canvas.?name.c.w32}

set pirNode(30) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = unknown)
  displayState = unknown;
else
  displayState = ok;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 60 nodeY 230 labelX 37 labelY 205 window .master.canvas.?name.c.w34}

set pirNode(32) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.ipsPurgeGheIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ipsPurgeGheIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 690 nodeY 80 labelX 658 labelY 55 window .master.canvas.?name.c.w36}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {turbopumpAssembly input output okMode faultMode displayState}
global pirClass
set pirClass(turbopumpAssembly) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{pipe ?name.mainLoxIn {}} {pipe ?name.mainRp1In {}} {pipe ?name.spinStartGheIn {}} {pipe ?name.ggLoxIn {}} {pipe ?name.ggRp1In {}} {onOffCommand ?name.ggPyroCmd {}} {pipe ?name.ipsPurgeGheIn {}}}} output_terminals {default {{pipe ?name.loxOut {}} {pipe ?name.rp1Out {}} {temperatureValues ?name.turbineInletTemp {}} {pressureValues ?name.ggPressure {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default stopped} ok_modes {default {stopped running spinStart}} fault_modes {default unknownFault} mode_transitions {default {{stopped spinStart} {running stopped} {spinStart running}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default stopped} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(input) {cfg_file input.cfg terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {turbopumpAssembly}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {turbopumpAssembly}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
