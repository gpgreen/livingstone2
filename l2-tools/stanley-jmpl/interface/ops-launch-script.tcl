# $Id: ops-launch-script.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## configuration script to launch multiple slave windows,
## open them to designated node group, shrink them, and
## place them per directions.

## this file is referenced by env variable OPS_LAUNCH_SCRIPT
## in RUN-STANLEY-ops.csh

## use configurable parameters are between "## -----"s

## MASTER WINDOW
################
set canvasRootId 0
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 1
#################
## -----
set xPos 562; set yPos 0
set instancePathNameList [list "(RT-MODULE PASM-A)" "(RT PASM-A)"]
## -----
incr canvasRootId 
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 2
#################
## -----
set xPos 1; set yPos 1
set instancePathNameList [list "RCS-A" "(PALETTE-A RCS-A)"]
## -----
incr canvasRootId
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 3
#################
## -----
set xPos 0; set yPos 346
set instancePathNameList [list "RCS-A" "(PALETTE-A RCS-A)" "(THRSTR-VALVE (PALETTE-A RCS-A) X)"]
## -----
incr canvasRootId
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 4
#################
## -----
set xPos 0; set yPos 676
set instancePathNameList [list "PDU-MODULE" "FSC_CAM_ELEC_SW1" "(POWER-THROW FSC_CAM_ELEC_SW1)"]
## -----
incr canvasRootId
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 5
#################
## -----
set xPos 696; set yPos 676
set instancePathNameList [list "IPS-A"]
## -----
incr canvasRootId
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## SLAVE WINDOW 6
#################
## -----
set xPos 824; set yPos 346
set instancePathNameList [list "ACS-A"]
## -----
incr canvasRootId
createNewRootCanvas $xPos $yPos
openCanvasToInstance $instancePathNameList $canvasRootId 
resizeCanvas $canvasRootId shrink

## MASTER WINDOW -- move to the center of the screen
################
## -----
  set xPos 404; set yPos 346
## -----
wm geometry .master +$xPos+$yPos 
raise .master
raise .slave_4
raise .slave_5








