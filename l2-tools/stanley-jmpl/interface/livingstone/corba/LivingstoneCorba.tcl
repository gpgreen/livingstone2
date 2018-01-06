#
# This file was automatically generated from LivingstoneCorba.idl
# by idl2tcl. Do not edit.
#

set _ir_LivingstoneCorba \
{{module {IDL:LivingstoneCorba:1.0 LivingstoneCorba 1.0} {{interface\
{IDL:LivingstoneCorba/LivingstoneCommandLine:1.0 LivingstoneCommandLine 1.0}}\
{interface {IDL:LivingstoneCorba/LivingstoneEngineManager:1.0\
LivingstoneEngineManager 1.0} {} {{operation\
{IDL:LivingstoneCorba/LivingstoneEngineManager/describe:1.0 describe 1.0}\
string {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEngineManager/getCommandLine:1.0\
getCommandLine 1.0} IDL:LivingstoneCorba/LivingstoneCommandLine:1.0 {{in\
search_method string} {in max_candidate_classes_returned long} {in\
max_candidates_returned long} {in max_candidates_searched long} {in\
max_cutoff_weight long} {in max_history_cutoff long} {in\
max_trajectories_tracked long} {in progress_cmd_type string} {in fc_cmd_type\
string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEngineManager/getRunningCommandLine:1.0\
getRunningCommandLine 1.0} IDL:LivingstoneCorba/LivingstoneCommandLine:1.0 {}\
{}} {operation {IDL:LivingstoneCorba/LivingstoneEngineManager/exit:1.0 exit\
1.0} void {} {}}}} {exception {IDL:LivingstoneCorba/LivingstoneException:1.0\
LivingstoneException 1.0} {{id long} {description string}} {}} {interface\
{IDL:LivingstoneCorba/LivingstoneEventListener:1.0 LivingstoneEventListener\
1.0}} {interface {IDL:LivingstoneCorba/LivingstoneCommandLine:1.0\
LivingstoneCommandLine 1.0} {} {{operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/command:1.0 command 1.0} void\
{{in command string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/getHistoryTimes:1.0\
getHistoryTimes 1.0} string {} IDL:LivingstoneCorba/LivingstoneException:1.0}\
{operation {IDL:LivingstoneCorba/LivingstoneCommandLine/enableGUIUpdate:1.0\
enableGUIUpdate 1.0} void {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/disableGUIUpdate:1.0\
disableGUIUpdate 1.0} void {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/warpCommands:1.0 warpCommands\
1.0} void {{in commands string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/release:1.0 release 1.0} void {}\
{}} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/addLivingstoneEventListener:1.0\
addLivingstoneEventListener 1.0} void {{in listener\
IDL:LivingstoneCorba/LivingstoneEventListener:1.0}}\
IDL:LivingstoneCorba/LivingstoneException:1.0} {operation\
{IDL:LivingstoneCorba/LivingstoneCommandLine/removeLivingstoneEventListener:1.0\
removeLivingstoneEventListener 1.0} void {{in listener\
IDL:LivingstoneCorba/LivingstoneEventListener:1.0}}\
IDL:LivingstoneCorba/LivingstoneException:1.0}}} {struct\
{IDL:LivingstoneCorba/LivingstoneAttributeReport:1.0\
LivingstoneAttributeReport 1.0}} {struct\
{IDL:LivingstoneCorba/LivingstoneAssignmentReport:1.0\
LivingstoneAssignmentReport 1.0}} {interface\
{IDL:LivingstoneCorba/LivingstoneEventListener:1.0 LivingstoneEventListener\
1.0} {} {{operation {IDL:LivingstoneCorba/LivingstoneEventListener/start:1.0\
start 1.0} void {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/reportVariables:1.0\
reportVariables 1.0} void {{in attributes\
IDL:LivingstoneCorba/LivingstoneAttributeReport:1.0}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/newState:1.0 newState 1.0}\
void {{in time float} {in stateID long} {in transition string} {in\
assignments IDL:LivingstoneCorba/LivingstoneAssignmentReport:1.0}} {}}\
{operation {IDL:LivingstoneCorba/LivingstoneEventListener/viewState:1.0\
viewState 1.0} void {{in time float} {in stateID long} {in transition string}\
{in assignments IDL:LivingstoneCorba/LivingstoneAssignmentReport:1.0}} {}}\
{operation {IDL:LivingstoneCorba/LivingstoneEventListener/asynchronousMsg:1.0\
asynchronousMsg 1.0} void {{in state short} {in msg string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/finish:1.0 finish 1.0} void {}\
{}} {operation {IDL:LivingstoneCorba/LivingstoneEventListener/startReplay:1.0\
startReplay 1.0} void {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/finishReplay:1.0 finishReplay\
1.0} void {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/gotCandidates:1.0\
gotCandidates 1.0} void {{in num long}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/gotInstallCandidate:1.0\
gotInstallCandidate 1.0} void {{in index long}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/gotAssignment:1.0\
gotAssignment 1.0} void {{in monitor string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/gotProgress:1.0 gotProgress\
1.0} void {{in command string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/getModules:1.0 getModules 1.0}\
string {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/loadModule:1.0 loadModule 1.0}\
void {{in moduleName string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/getWorkSpaces:1.0\
getWorkSpaces 1.0} string {} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/loadWorkSpace:1.0\
loadWorkSpace 1.0} void {{in workspace string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/metaDot:1.0 metaDot 1.0} void\
{{in nodeClassType string} {in instanceName string} {in dialogType string}\
{in modeName string}} {}} {operation\
{IDL:LivingstoneCorba/LivingstoneEventListener/getInstances:1.0 getInstances\
1.0} string {{in nodeClassType string} {in componentInstanceName string}}\
{}}}} {struct {IDL:LivingstoneCorba/SingleLivingstoneAttributeReport:1.0\
SingleLivingstoneAttributeReport 1.0}} {struct\
{IDL:LivingstoneCorba/LivingstoneAttributeReport:1.0\
LivingstoneAttributeReport 1.0} {{attributes {sequence\
IDL:LivingstoneCorba/SingleLivingstoneAttributeReport:1.0}}} {}} {struct\
{IDL:LivingstoneCorba/SingleLivingstoneAttributeReport:1.0\
SingleLivingstoneAttributeReport 1.0} {{name string} {range {sequence\
string}} {initialValue string}} {}} {struct\
{IDL:LivingstoneCorba/Assignment:1.0 Assignment 1.0}} {struct\
{IDL:LivingstoneCorba/LivingstoneAssignmentReport:1.0\
LivingstoneAssignmentReport 1.0} {{assignments {sequence\
IDL:LivingstoneCorba/Assignment:1.0}}} {}} {struct\
{IDL:LivingstoneCorba/Assignment:1.0 Assignment 1.0} {{name string} {value\
string} {time long}} {}}}}}

#
# This is just to clear the interp from the ridiculously long string above
#

expr 1

