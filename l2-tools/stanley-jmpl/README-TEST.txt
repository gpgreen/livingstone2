# $Id: README-TEST.txt,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

#####################################################################
UNIT TESTS FOR MIR_GUI (Stanley)
#####################################################################

X-term-1: Start Stanley in operational mode
------------------------------------
% cd  $DS1_ROOT/user-template
% ./RUN-STANLEY-OPS.csh -mir-gui-ipc -warn
# two xterms are created: "STANLEY OPS" & "Emacs-Livingstone"

X-term-2: Start RAX FSC to GND TELEM
(only needed if GROUND_FROM_TLM_MIR_TELEMETRY msgs are being sent)
---------------------------------
% setenv CENTRALHOST <host>:<port>
% cd $DS1_ROOT 
% source gcc.csh.official
% cd rax-gnd/bin
% ./ground.unix -nocentral
#

-------------------------------------------------------
MIR_TELEMETRY -- BASIC TESTS WITH SCHEMATIC 
------------------------------------------------------------------

Enter # (.......) cmds in the "Emacs-Livingstone" *common-lisp* buffer window

Output:
&& Stanley log file output in RUN-STANELY-ops.csh xterm
%% Stanley schematic changes

Stanley schematic mouse cmds:
Mouse-Right on components/modoles to bring up "Mode/State/Properties" window
Control-Mouse-Left on components to redraw canvas with mode state diagram 
Control-Mouse-Left on modules to open next lower level

*********
NOTE: Use publish-mir-telemetry-tuples, rather than publish-mir-state-update 
      to test GROUND_FROM_TLM_MIR_TELEMETRY, rather than
      MIR_GUI_STATE_UPDATE_RAX
*********

   <DEVICE>                               <MODE>                  <SUB MODE>
   <PROP NAME>                                                    <VALUE>
   -------------------------------------------------------------------------------
# simple tuple test -- GROUND_FROM_TLM_MIR_TELEMETRY
====================================================
# >(publish-mir-telemetry-tuples
        '((attr-val (unrecoverable-remote-terminal (rt sru-a)) unknown)
          (component-mode (rt sru-a) nominal))
        :lisp-syntax t) 

# simple tests -- MIR_GUI_STATE_UPDATE_RAX
================================================
# mod-1 test
(publish-mir-state-update '((attr-val (cmd-2 mod-test-x) on)
                            (attr-val (cmd-in sw-2) on)))
# change non-mode/non-display-state proposition
(publish-mir-state-update '((attr-val (reset-cmd-in (rt pde-a)) not-asserted)))
# change display-state proposition
(publish-mir-state-update '((attr-val (display-state pde-module) ok-unk)))
# change mode proposition 
(publish-mir-state-update '((attr-val (unrecoverable-remote-terminal (rt pde-a)) nominal)))
# change attribute
(publish-mir-state-update '((attr-val (health-state pdu-a) ok)))
# test toplevel input & output terminal propositions
(publish-mir-state-update `((attr-val (sru-status pdu-mgr) on)
                            (attr-val (pasm-cmd pdu-mgr) on)))
# defrelation 1 arg type 
(publish-mir-state-update `((attr-val (z-coord (estimated-attitude-in acs-a)) low)))
# defrelation 1 arg type with inheritance
(publish-mir-state-update `((attr-val (z-coord (estimated-attitude sru-a)) low)))
# defvalues arg type with inheritance 
(publish-mir-state-update `((attr-val (power-input sru-a) on)))
# no match problem
(publish-mir-state-update `((attr-val (cmd-in (thrstr-valve (palette-a rcs-a) z)) nominal)))
# double vauled defrelation
(publish-mir-state-update `((attr-val (thrust (thruster (palette-d rcs-a) z)) positive)
                            (attr-val (thrust (thruster (palette-d rcs-a) z)) high)
                            (attr-val (cmd-in (thrstr-valve (palette-d rcs-a) z)) nominal)))
(publish-mir-state-update `((attr-val (thrust (thruster (palette-d rcs-a) z)) negative)
                            (attr-val (thrust (thruster (palette-d rcs-a) z)) low)
                            (attr-val (cmd-in (thrstr-valve (palette-d rcs-a) z)) not-nominal))) 
# power on micas
(publish-mir-state-update `((attr-val (power-cmd-in pdu-mgr) on)
                            (attr-val (cam-elec-cmd pdu-mgr) on)
                            (attr-val (bus-cmd-in (cmd-in fsc_cam_elec_sw1)) on)
                            (attr-val (bus-cmd-out (cmd-in fsc_cam_elec_sw1)) on)
                            (attr-val (cmd-in fsc_cam_elec_sw1) on)
                            (attr-val (status-out fsc_cam_elec_sw1) on)
                            (attr-val (bus-data-in (status-out fsc_cam_elec_sw1)) on)
                            (attr-val (bus-data-out (status-out fsc_cam_elec_sw1)) on)
                            (attr-val (cam-elec-status pdu-mgr) on)
                            (attr-val (pdu-switch-monitor pdu-mgr) on)
                            (attr-val (power-output fsc_cam_elec_sw1) on)
                            (attr-val (power-input cam-a) on)
                            (attr-val (micas cam-a) nominal)
                            (attr-val (display-state cam-a) ok-on)))
# power off micas
(publish-mir-state-update `((attr-val (power-cmd-in pdu-mgr) off)
                            (attr-val (cam-elec-cmd pdu-mgr) off)
                            (attr-val (bus-cmd-in (cmd-in fsc_cam_elec_sw1)) off)
                            (attr-val (bus-cmd-out (cmd-in fsc_cam_elec_sw1)) off)
                            (attr-val (cmd-in fsc_cam_elec_sw1) off)
                            (attr-val (power-output fsc_cam_elec_sw1) off)
                            (attr-val (power-input cam-a) off)
                            (attr-val (micas cam-a) nominal)
                            (attr-val (display-state cam-a) ok-off))) 

-------------------------------------------------------------------------------

# extensive string test -- MIR_GUI_STATE_UPDATE_RAX
================================================
# pop-up Mode/State/Propositions dialogs for `LOW POWER EXPERIMENT' & '(RT LPE-A)'
# (publish-mir-state-update '((attr-val (power-input (rt lpe-a)) on)
                              (attr-val (reset-cmd-in (rt lpe-a)) asserted)
                              (attr-val (comm-status-out (rt lpe-a)) comm) 
                              (attr-val (reset-effective (rt lpe-a)) nil) 
                              (attr-val (color-state (rt lpe-a)) ok-on)
                              (attr-val (display-state (rt-module lpe-a)) ok-on)
                              (attr-val (remote-terminal (rt lpe-a)) nominal)))
                              
&& (REMOTE-TERMINAL (RT LPE-A))                                   NOMINAL     
&& (COLOR-STATE (RT-MODULE LPE-A))                                OK-ON       
&& (COLOR-STATE (RT LPE-A))                                       OK-ON       
&& (POWER-INPUT (RT LPE-A))                                       ON          
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from dark blue to green
%% NOMINAL mode of (RT LPE-A) changes from gray to green
%% `LOW POWER EXPERIMENT' & (RT LPE-A) propositions change from NO-DATA to ---
%% (RT LPE-A) dialog mode changes from NO-DATA to NOMINAL

# (publish-mir-state-update '((attr-val (color-state (rt lpe-a)) recoverable)
                              (attr-val (display-state (rt-module lpe-a)) recoverable)
                              (attr-val (remote-terminal (rt lpe-a)) resettable-failure)
                              (attr-val (comm-status-out (rt lpe-a)) no-comm)))
                              
&& (COMM-STATUS-OUT (RT LPE-A))                                   NO-COMM     
&& (REMOTE-TERMINAL (RT LPE-A))                                   RESETTABLE-FAILURE
&& (COLOR-STATE (RT-MODULE LPE-A))                                RECOVERABLE 
&& (COLOR-STATE (RT LPE-A))                                       RECOVERABLE 
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from green to yellow
%% NOMINAL mode of (RT LPE-A) changes from green to gray
%% RESETTABLE-FAILURE mode of (RT LPE-A) changes from gray to red
%% `LOW POWER EXPERIMENT' & (RT LPE-A) comm-status-out propositions change from
%%                                      COMM to NO-COMM
%% (RT LPE-A) dialog mode changes from NOMINAL to RESETTABLE-FAILURE 

# (publish-mir-state-update '((attr-val (color-state (rt lpe-a)) ok-on)
                              (attr-val (display-state (rt-module lpe-a)) ok-on)
                              (attr-val (remote-terminal (rt lpe-a)) nominal)
                              (attr-val (comm-status-out (rt lpe-a)) comm)
                              (attr-val (reset-effective (rt lpe-a)) t)))
&& (COMM-STATUS-OUT (RT LPE-A))                                   COMM        
&& (REMOTE-TERMINAL (RT LPE-A))                                   NOMINAL     
&& (COLOR-STATE (RT-MODULE LPE-A))                                OK-ON       
&& (COLOR-STATE (RT LPE-A))                                       OK-ON       
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from yellow to green
%% NOMINAL mode of (RT LPE-A) changes from gray to green 
%% RESETTABLE-FAILURE mode of (RT LPE-A) changes from red to gray
%% `LOW POWER EXPERIMENT' & (RT LPE-A) comm-status-out propositions change from
%%                                      NO-COMM to COMM
%% (RT LPE-A)dialog  mode changes from RESETTABLE-FAILURE to NOMINAL 

# (publish-mir-state-update '((attr-val (color-state (rt lpe-a)) ok-off)
                              (attr-val (display-state (rt-module lpe-a)) ok-off)
                              (attr-val (power-input (rt lpe-a)) off)))
&& (POWER-INPUT (RT LPE-A))                                       OFF         
&& (COLOR-STATE (RT-MODULE LPE-A))                                OK-OFF      
&& (COLOR-STATE (RT LPE-A))                                       OK-OFF      
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from green to light blue
%% NOMINAL mode of (RT LPE-A) stays green
%% `LOW POWER EXPERIMENT' & (RT LPE-A) power-input propositions change from
%%                                      ON to OFF
%% (RT LPE-A) dialog mode stays NOMINAL 

# (publish-mir-state-update '((attr-val (color-state (rt lpe-a)) ok-unk)
                              (attr-val (display-state (rt-module lpe-a)) ok-unk)
                              (attr-val (power-input (rt lpe-a)) off)))
&& (POWER-INPUT (RT LPE-A))                                       OFF         
&& (COLOR-STATE (RT-MODULE LPE-A))                                OK-UNK      
&& (COLOR-STATE (RT LPE-A))                                       OK-UNK      
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from light blue to gray
%% NOMINAL mode of (RT LPE-A) stays green
%% (RT LPE-A) dialog mode stays NOMINAL 

# (publish-mir-state-update '((attr-val (color-state (rt lpe-a)) failed)
                              (attr-val (display-state (rt-module lpe-a)) failed)
                              (attr-val (remote-terminal (rt lpe-a)) permanent-failure)
                              (attr-val (reset-cmd-in (rt lpe-a)) not-asserted)))
&& (RESET-CMD-IN (RT LPE-A))                                      NOT-ASSERTED
&& (REMOTE-TERMINAL (RT LPE-A))                                   PERMANENT-FAILURE
&& (COLOR-STATE (RT-MODULE LPE-A))                                FAILED      
&& (COLOR-STATE (RT LPE-A))                                       FAILED      
%% `LOW POWER EXPERIMENT' & (RT LPE-A) colors change from light blue to red
%% NOMINAL mode of (RT LPE-A) changes from green to gray
%% PERMANENT-FAILURE mode of (RT LPE-A) changes from gray to red
%% `LOW POWER EXPERIMENT' & (RT LPE-A) reset-cmd-in propositions change from
%%                                      ASSERTED to NOT-ASSERTED 
%% (RT LPE-A) dialog mode changes from NOMINAL to PERMANENT-FAILURE 

# (publish-mir-state-update '((attr-val (color-state sru-a) failed)
                              (attr-val (star-tracker sru-a) unknown)))


>>>>>>>>>> not tested yet -- below

... (FAILED (RCS (CONTROL-MODE ACS-A))) not a known proposition 
... (RCS-X-FOR-Y (ACS-THRUSTER-MODE-CMD-IN ACS-A)) not a known proposition RCS-Z-FOR-Y NO-COMMAND
... (DEGRADED (RCS-X-FOR-Y (THRUSTER-CONTROL-MODE ACS-A))) not a known proposition 
... (RCS-X-FOR-Y (THRUSTER-CONTROL-MODE ACS-A)) not a known proposition 

# (let ((component-modes '(RCS SUN-STANDBY-SRU EARTH-STANDBY TVC UNKNOWN)))
        (dolist (mode component-modes)
          (publish-mir-state-update `((attr-val (acs-control-mode acs-a) ,mode)  ;; mode
                                      (attr-val (acs-mode-cmd-in acs-a) ,mode)   ;; terminal
                                      (attr-val (control-mode acs-a) ,mode)      ;; terminal
                                        ))))
&& (CONTROL-MODE ACS-A)                                           RCS         
&& (ACS-MODE-CMD-IN ACS-A)                                        RCS         
&& (ACS-CONTROL-MODE ACS-A)                                       RCS         
&& (CONTROL-MODE ACS-A)                                           SUN-STANDBY-SRU
&& (ACS-MODE-CMD-IN ACS-A)                                        SUN-STANDBY-SRU
&& (ACS-CONTROL-MODE ACS-A)                                       SUN-STANDBY-SRU
&& (CONTROL-MODE ACS-A)                                           EARTH-STANDBY
&& (ACS-MODE-CMD-IN ACS-A)                                        EARTH-STANDBY
&& (ACS-CONTROL-MODE ACS-A)                                       EARTH-STANDBY
&& (CONTROL-MODE ACS-A)                                           TVC         
&& (ACS-MODE-CMD-IN ACS-A)                                        TVC         
&& (ACS-CONTROL-MODE ACS-A)                                       TVC         
&& (CONTROL-MODE ACS-A)                                           UNKNOWN     
&& (ACS-MODE-CMD-IN ACS-A)                                        UNKNOWN     
&& (ACS-CONTROL-MODE ACS-A)                                       UNKNOWN     

# (publish-mir-state-update `((attr-val (acs-control-mode acs-a rcs-thruster-valves)
                                                                sun-standby-sru)  ;; mode
                              (attr-val (acs-mode-cmd-in acs-a) sun-standby-sru) ;; input
                              (attr-val (control-mode acs-a) sun-standby-sru)      ;; output
                              (attr-val (sun-standby-sru (control-mode acs-a)) failed) ;; submode
                              (attr-val (color-state acs-a) failed)
                              (attr-val (display-state acs-module) failed)))

&& (DISPLAY-STATE ACS-MODULE)                                     FAILED      
&& (COLOR-STATE ACS-A)                                            FAILED      
&& (SUN-STANDBY-SRU (CONTROL-MODE ACS-A))                         FAILED      
&& (CONTROL-MODE ACS-A)                                           SUN-STANDBY-SRU
&& (ACS-MODE-CMD-IN ACS-A)                                        SUN-STANDBY-SRU
&& (ACS-CONTROL-MODE ACS-A RCS-THRUSTER-VALVES)                   SUN-STANDBY-SRU
%% ACS-A & ACS-MODULE color changes from dark blue to red 
%% ACS-A mode changes from NO-DATA to SUN-STANDBY-SRU 
%% ACS-A submode changes from NO-DATA to FAILED
%% props acs-mode.acs-mode  & (sun-standby-sru (control-mode acs-a)) change
%%              from NO-DATA/NO-DATA to SUN-STANDBY-SRU/FAILED

# (publish-mir-state-update `((attr-val (rcs-thruster-control-mode (rcs-mode acs-a) acs-a)
                                                        rcs-x-for-y)  ;; mode
                              (attr-val (acs-thruster-mode-cmd-in (rcs-mode acs-a))
                                                        rcs-x-for-y) ;; input
                              (attr-val (thruster-control-mode (rcs-mode acs-a))
                                                        rcs-x-for-y)      ;; output
                              (attr-val (rcs-x-for-y (thruster-control-mode (rcs-mode acs-a)))
                                                        failed) ;; submode
                              (attr-val (display-state (rcs-mode acs-a)) failed)
                              (attr-val (display-state acs-module) failed)))
&& (DISPLAY-STATE ACS-MODULE)                                     FAILED      
&& (DISPLAY-STATE (RCS-MODE ACS-A))                               FAILED      
&& (RCS-X-FOR-Y (THRUSTER-CONTROL-MODE (RCS-MODE ACS-A)))         FAILED      
&& (THRUSTER-CONTROL-MODE (RCS-MODE ACS-A))                       RCS-X-FOR-Y 
&& (ACS-THRUSTER-MODE-CMD-IN (RCS-MODE ACS-A))                    RCS-X-FOR-Y 
&& (RCS-THRUSTER-CONTROL-MODE (RCS-MODE ACS-A) ACS-A)             RCS-X-FOR-Y 




# (publish-mir-state-update `((:COMPONENT_MODE :ACS_A :RCS_Z_FOR_Y)
                                   (:attr_val
                                   :LP__RCS_Z_FOR_Y__LP__CONTROL_MODE__ACS_A__RP__RP
                                   :OK)))
&& proposition - attr RCS-Z-FOR-Y device (CONTROL-MODE ACS-A) value OK
&& ACS-A                                  RCS-Z-FOR-Y             OK          
%% ACS-A color changes from red to lawn green
%% ACS-A state changes from RCS-X-FOR-Y to RCS-Z-FOR-Y 

# (publish-mir-state-update `((:COMPONENT_MODE :ACS_A :RCS_Z_FOR_Y)
                                  (:attr_val
                                   :LP__RCS_Z_FOR_Y__LP__CONTROL_MODE__ACS_A__RP__RP
                                   :DEGRADED)))
&& proposition - attr RCS-Z-FOR-Y device (CONTROL-MODE ACS-A) value DEGRADED
&& ACS-A                                  RCS-Z-FOR-Y             DEGRADED    
%% ACS-A color changes from lawn green to purple
%% ACS-A state remains RCS-Z-FOR-Y

>>>>>>>>>> not tested yet -- above

** done to here 27jan98 wmt

# (publish-mir-state-update `((:COMPONENT_MODE :WTS_HGA :UNKNOWN)
                                  (:attr_val
                                   :LP__WTS_HGA__RP
                                   :UNKNOWN))) 
&& proposition - attr BOOLEAN device WTS-HGA value UNKNOWN
&& WTS-HGA                                UNKNOWN                 UNKNOWN      ON 
%% CML => <Control-Mouse-Left> 
%% ML => <Mouse-Left> 
%% CML on TELCOM-A => CML on WTS-A => CML on WTS-HGA => ML on PROPS => boolean: UNKNOWN 
%% WTS-HGA color changes from lawn green to dark blue


Use Stanley menu select: "Tools => Reset All Definition Instances" to
reset all components to their default modes.
%% all top-level modules will be dark blue


(publish-mir-state-update '((component-mode (status-throw fsc_pdu_neb1_sw1) unknown))
                                  :lisp-syntax t)
&& (STATUS-THROW FSC_PDU_NEB1_SW1)     UNKNOWN                 UNKNOWN      ON 
%% PDU-MODULE color changes from lawn green to dark blue
%% FSC_PDU_NEB1_SW1 mode changes from nominal to unknown



(publish-mir-state-update '((component-mode (current-sensor x-sspa) failed))
                                  :lisp-syntax t) 
&& (CURRENT-SENSOR X-SSPA)                FAILED                  FAILED       ON 
%% TELECOM-A color changes from lawn green to red
%% (CURRENT-SENSOR X-SSPA) mode changes from nominal to failed


Use Stanley menu select: "Tools => Reset All Definition Instances" to
reset all components to their default modes.
%% some top-level modules will be gray, rather than lawn green



OVERALL TESTS WITH SCHEMATIC ds1-spacecraft.scm (GROUND_FROM_TLM_MIR_TELEMETRY)
-----------------------------------------------
# (SEND-ALL-COMPONENT-MODES :num-tuples-per-msg 1)       ;;; each msg processed separately
# (SEND-ALL-COMPONENT-MODES :num-tuples-per-msg 50)       ;;; many small msgs
# (SEND-ALL-COMPONENT-MODES :num-tuples-per-msg 600)      ;;; one large msg

# (SEND-ALL-PROPOSITIONS :num-tuples-per-msg 50 :total-num-tuples 10)
# (SEND-ALL-PROPOSITIONS :num-tuples-per-msg 50)        ;;; many small msgs
# (SEND-ALL-PROPOSITIONS :num-tuples-per-msg 1000)      ;;; one large msg


# (SEND-ALL-POWER-ON-PROPOSITIONS)
%% all top-level modules will be lawn green

GENERATE ALL PROPOSITION COMBINATIONS
# 50 props per messge
(publish-mir-state-update (generate-attr-val-ground-list))
# send only first 10 props
(publish-mir-state-update (generate-attr-val-ground-list) :total-num-states 10)
                    
GENERATE ALL ATTRIBUTES WITH ONE VALUE IN ONE MSG
(publish-mir-state-update (generate-single-valued-attr-val-ground-list) :num-states-per-msg 1000)

MPL tricks
----------
(cprops 'sru-a) => currrent values of all attributes which contain sru-a

(defun get-mode-props (cmp-name)
  (let ((cmp (find-component cmp-name)))
    (mapcar #'(lambda (mode) (list (mode-name mode) cmp-name))
         (append (component-ok-modes cmp) (component-fault-modes cmp)))))

(system-components *system*)


PUT SPACECRAFT IN PROPER STATE FOR DO-CMD
-----------------------------------------
(load "/home/serengeti/id0/taylor/autosat/R3-branch/rax/src/mir/livingstone/ds3/models/create-module.lisp") 

(defun create-spacecraft ()
  (instantiate-module '(visual-completion-top))
  (assert-optimizing-wffs) 
  (define-spacecraft-cmds-and-monitors) 
  (define-proposition-monitors )
  (init-proposition-monitors *system* )
  (achieve-init-state )
  (all-propositions-monitored )
  (send-props-to-vmpl (changed-proposition-monitors *system* ))
  )

# MIR defined commands
(maphash #'(lambda( k v)
                     (format t "~%k ~A v ~A" k v))
                 (command-table-ht (system-command-table *system*)))
#
> k (ACS-MODE-CMD-IN ACS-A)  v earth-standby rcs sun-standby-sru tvc no-command
> k (ACS-THRUSTER-MODE-CMD-IN ACS-A) v rcs-z-for-y rcs-x-for-y no-command
> k (IPS-DCIU-REPORT IPS-A) v ??
> k (PDU-BUS-CMD FSC_CAM_ELEC_SW1 PDU-A) v ??
> k (PDU-BUS-CMD FSC_PASM_SW1 PDU-A) v ??
> k (RESET-CMD-IN (RT LPE-A)) v asserted not-asserted

not-used 
k (RESET-CMD-IN (RT SRU-A)) v asserted not-asserted
k (RESET-CMD-IN (RT IPS-A)) v asserted not-asserted 
k (RESET-CMD-IN (RT PDE-A)) v asserted not-asserted 
k (RESET-CMD-IN (RT PDU-A)) v asserted not-asserted 

  
#####################################################################
#####################################################################
## standalone MIR image with Stanley operational mode 

/proj/nm-ds1/Stage/R3_big_3/ra/mir/livingstone/project/bin/sparc-sunos5/acl-4.3/sun4u/mir

CR
> :pac :tp
> (CLASH::clash_defineMsg_FSC_TLM_TELEMETRY_PACKET)

> (SEND-TLM-PKT-MIR_TELEMETRY '((:component_mode :acs_turn_a :transitional_pointing)))

> (SEND-TLM-PKT-MIR_TELEMETRY `((:COMPONENT_MODE :ACS_A :RCS_X_FOR_Y)
                                  (:attr_val
                                   :LP__RCS_X_FOR_Y__LP__CONTROL_MODE__ACS_A__RP__RP
                                   :FAILED)))

> (SEND-TLM-PKT-MIR_TELEMETRY '(
        (:COMPONENT_MODE :LP__POWER_THROW__FSC_PASM_SW1__RP :UNKNOWN)
          (:COMPONENT_MODE :LP__POWER_THROW__FSC_PASM_SW1__RP :STUCK_OFF)
          (:COMPONENT_MODE :LP__POWER_THROW__FSC_PASM_SW1__RP :STUCK_ON)
          (:COMPONENT_MODE :LP__POWER_THROW__FSC_PASM_SW1__RP
           :RECOVERABLY_ON)
         (:COMPONENT_MODE :LP__BATTERY_2__BAT_A__RP :TWO_CELLS_SHORTED)
          (:COMPONENT_MODE :LP__BATTERY_2__BAT_A__RP :ONE_CELL_SHORTED)
          (:COMPONENT_MODE :LP__BATTERY_2__BAT_A__RP :UNKNOWN_SOC)
          (:COMPONENT_MODE :LP__BATTERY_2__BAT_A__RP :DISCHARGED)
          (:COMPONENT_MODE :LP__BATTERY_2__BAT_A__RP :NOMINAL)
         (:ATTR_VAL :LP__HEALTH_STATE__SDST_A__RP :OK)
          (:ATTR_VAL :LP__HEALTH_STATE__SDST_A__RP :UNKNOWN)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_HGA_LGA__RP :FAILED)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_HGA_LGA__RP :RECOVERABLE)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_HGA_LGA__RP :OK)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_HGA_LGA__RP :UNKNOWN)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_LGA_PX_PZ__RP :FAILED)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_LGA_PX_PZ__RP :RECOVERABLE)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_LGA_PX_PZ__RP :OK)
          (:ATTR_VAL :LP__HEALTH_STATE__WTS_LGA_PX_PZ__RP :UNKNOWN)))
         
#####################################################################
#####################################################################
BUGS   (SEND-ALL-PROPOSITIONS :num-tuples-per-msg 50)


parsing problem
... component (POWER-THROW FSC_PDU_NEB1_S_SW1) (POWER_OUTPUT SC_POWER) (POWER_OUTPUT FSC_PDU_NEB1_S_SW1) (SWITCH_STATE FSC_PDU_NEB1_S_SW1) not in schematic

(publish-mir-state-update `((:ATTR_VAL
    :LP__NEB_THROW__LP__POWER_THROW__FSC_PDU_NEB1_S_SW1__RP__LP__POWER_OUTPUT__SC_POWER__RP__LP__POWER_OUTPUT__FSC_PDU_NEB1_S_SW1__RP__LP__SWITCH_STATE__FSC_PDU_NEB1_S_SW1__RP__RP
    :STUCK_OFF)))


acs-a propositions
-------------------
acs-control-mode: UNKNOWN

proposition - attr ACS-CONTROL-MODE device ACS-A value UNKNOWN

(publish-mir-state-update `((:ATTR_VAL :LP__ACS_CONTROL_MODE__ACS_A__RCS_THRUSTER_VALVES__RP :UNKNOWN)))




