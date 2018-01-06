# $Id: emacsEdit.tcl,v 1.1.1.1 2006/04/18 20:17:27 taylor Exp $
####
#### See the file "l2-tools/disclaimers-and-notices.txt" for 
#### information on usage and redistribution of this file, 
#### and for a DISCLAIMER OF ALL WARRANTIES.
####

## apply bindings to tcl text widget to produce Emacs Lisp editing,
## indenting, and paren balancing
## some code adapted from tkbind/tkBindtest
## 23oct97 wmt: new
proc createEmacsTextWidget { dialogId dialogW widgetName nodeType attributeName state \
                                 { pirEdgeIndex 0 } } {
  global g_NM_currentCanvas g_NM_nodeTypeRootWindow
  global STANLEY_ROOT

  set heightBorder 5; set textHeight 19
  if {[string match $attributeName precondition]} {
    set textHeight 11
  }
  set windowHeight [expr {1 + $textHeight}]

  set bgColor [preferred StanleyDialogEntryBackgroundColor]

  set w $dialogW.$widgetName
  frame $w -bg $bgColor
#   frame $w.bottom
#   -xscrollcommand "$w.bottom.sx set" 
  set txt [text $w.t -setgrid true -height $textHeight \
               -yscrollcommand "$w.sy set" \
               -wrap char -font [preferred StanleyDialogEntryFont]]

  scrollbar $w.sy -orient vertical -command "$w.t yview" -relief sunken 
#   scrollbar $w.bottom.sx -orient horizontal -command "$w.t xview" -relief sunken 

#   frame $w.menu -relief raised -bd 2
#   menubutton $w.menu.edit -text {Edit} -menu $w.menu.edit.m -underline 0
#   pack $w.menu.edit -side left
#   menu $w.menu.edit.m
#   $w.menu.edit.m add command -label {Undo} -underline 0 \
#       -command "tkTextUndo $txt" -accelerator "C-x u"
#   $w.menu.edit.m add command -label {Cut} -underline 2 \
#       -command "tkTextCut  $txt" -accelerator "C-w"
#   $w.menu.edit.m add command -label {Copy} -underline 0 \
#       -command "tkTextCopy $txt" -accelerator "M-w"
#   $w.menu.edit.m add command -label {Paste} -underline 0 \
#       -command "tkTextYank $txt" -accelerator "C-y"
#   # pack widgets and create an emacs-like minibuffer
#   pack $w.menu -side top -fill x

  pack [tkBindCreateMesgBuffer $w.mb] -side bottom -fill x 
#   pack $w.bottom.sx -side left -fill x -expand 1
#   pack $w.bottom -side bottom -fill x
  pack $w.sy -side right -fill y
  pack $w.t -side left -fill both -expand 1
  pack $w -side top -fill both -expand 1

  # tkbind package for Emacs bindings
  # tell text widget to use MesgBuffer
  tkBindAttachMesgBuffer $txt $w.mb
  # initialize undo for the text widget
  tkTextUndoSetup $txt
  # beth package for paren balancing
  balancebind $w.mb $w.menu 

  # elsbeth package
  # global Widget Class STANLEY_TCL_TK_LIB
  # set Widget $txt; set Class Text
  # source $STANLEY_TCL_TK_LIB/../elsbeth/bin/lispth
  
#   $w.bottom.sx configure -takefocus 0
  $w.sy configure -takefocus 0

  set canvasHeight [expr {$windowHeight - $heightBorder}]
  # characters
  $w.t config -width 80
  $w.t config -height $canvasHeight

  set attributeText [getTextWidgetText $dialogId $nodeType \
                         $attributeName $pirEdgeIndex]
  set attributeText [string trimleft $attributeText "\{"] 
  set attributeText [string trimright $attributeText "\}"]
  $w.t insert end [string trimright $attributeText "\n"]
  $w.t configure -state $state
}


## atttempt to use tkSteal (tkEmacs) package which uses tcl-DP
## to establish a socket connection between Stanley and Emacs
## Did not work becauce tkEmacs was only compatible with
## tcl7.6/tk4.2 and the required tcl-DP was only compatible 
## with tcl7.4/tk4.0 => need compatibility with tcltk-8.0
# proc createEmacsTextWidget { dialogId w nodeType attributeName state \
#                                  { pirEdgeIndex 0 } } {
#   global g_NM_currentCanvas g_NM_nodeTypeRootWindow
#   global STANLEY_ROOT EMACS_PATH STANLEY_USER_DIR UNIX_BIN 

#   set widthBorder 5; set heightBorder 5; set textHeight 11
#   set windowWidth 64; set windowHeight 12

#   set buttoncolor [preferred StanleyDialogButtonColor]
#   set bgColor [preferred StanleyDialogEntryBackgroundColor]

#   set factFormDir "${STANLEY_USER_DIR}/[preferred livingstone_directory]/tmp/"
#   set tkEmacsDir "${STANLEY_ROOT}/tkemacs/"
#   pushd $tkEmacsDir 
#   set factFormPath "${factFormDir}$dialogId.lisp"
#   set textPath nil; set pirEdgeIndex 0
#   # set className [$entryWidget.fcomponentDefmodulenameentry get]
#   # set title [formatTitleText $className $nodeClassType "" $attributeName $state]
#   set title [capitalizeWord $attributeName]
#   set emacsPath "[file rootname $factFormPath].emacs"
#   exec $UNIX_BIN/rm -f $emacsPath
#   set fid [open $emacsPath  w]
#   # puts $fid "(set-variable 'debug-on-error t)"
#   # for lisp behavior
#   puts $fid "(defun common-lisp-mode () (lisp-mode))"
#   if {[string match $state normal]} {
#     puts $fid "(find-file \"$factFormPath\")"
#   } else {
#     puts $fid "(find-file-read-only \"$factFormPath\")"
#   }
#   # no menu bar
#   puts $fid "(setq menu-bar-mode 0)"
#   puts $fid "(setq set-visited-file-name \"$factFormPath\")"
#   # disable save-buffers-kill-emacs -- C-x,C-c
#   puts $fid "(put 'save-buffers-kill-emacs 'disabled t)"
#   # kill emacs with C-x,C-s after saving file
#   # puts $fid "(global-unset-key \"\\\C-x\\\C-s\")"
#   # puts $fid "(global-set-key \"\\\C-x\\\C-s\" 'save-buffer-exit)"
#   # puts $fid "(defun save-buffer-exit ()"
#   # puts $fid "(interactive)"
#   # puts $fid "(basic-save-buffer)"
#   # puts $fid "(kill-emacs))"
#   # make auto-save timeout 1 sec, rather than 30 sec
#   # so that C-x,C-s is not needed to save work
#   # the update proc for the mega-widget will pickup the work
#   # from the auto-saved file
#   puts $fid "(setq auto-save-timeout 1)"
#   puts $fid "(switch-to-buffer \"[file tail $factFormPath]\")"
#   puts $fid "(set-buffer \"[file tail $factFormPath]\")"
#   if {[string match $state normal]} {
#     puts $fid "(let ((start nil) (stop nil))"
#     puts $fid "  (setq start (point))"
#     puts $fid "  (set-mark start)"
#     puts $fid "  (goto-char (point-max))"
#     puts $fid "  (setq stop (point))"
#     puts $fid "  (indent-region start stop nil))"
#     puts $fid "  (goto-char (point-min))"
#   }
#   # save indenting of form
#   puts $fid "(save-buffer)"
#   puts $fid "(load \"${tkEmacsDir}stig-paren\")"
#   puts $fid "(setq blink-matching-paren nil)"
#   # if {[string match $state normal]} {
#   #   puts $fid "(message \"C-x,C-s to save changes -- C-x,C-c to exit\")"
#   # } else {
#   #   puts $fid "(message \"C-x,C-c to exit\")"
#   # }
#   close $fid
#   set heightLines 10
#   if {[string match $attributeName initially]} {
#     set heightLines 7
#   }

#   tkEmacs $factFormPath -command $EMACS_PATH -lispfile ${tkEmacsDir}tkemacs.el \
#       -height $heightLines -width $windowWidth -reparent 0
#   popd
# }


## create emacs lisp mode window by starting a new emacs process and
## overlaying the window on the Stanley dialog
## 10jul97 wmt: new
## no used anymore 
# proc createEmacsLispWindow { dialogId entryWidget nodeClassType attributeName \
#                                  state xPos yPos } {
#   global STANLEY_USER_DIR UNIX_BIN EMACS_PATH

#   set factFormDir "${STANLEY_USER_DIR}/[preferred livingstone_directory]/tmp/"
#   set stigParenDir "${STANLEY_USER_DIR}/[preferred livingstone_directory]/"
#   set factFormPath "${factFormDir}$dialogId.lisp"
#   set textPath nil; set pirEdgeIndex 0
#   # set className [$entryWidget.fcomponentDefmodulenameentry get]
#   # set title [formatTitleText $className $nodeClassType "" $attributeName $state]
#   set title [capitalizeWord $attributeName]
#   set emacsPath "[file rootname $factFormPath].emacs"
#   exec $UNIX_BIN/rm -f $emacsPath
#   set fid [open $emacsPath  w]
#   # puts $fid "(set-variable 'debug-on-error t)"
#   # for lisp behavior
#   puts $fid "(defun common-lisp-mode () (lisp-mode))"
#   if {[string match $state normal]} {
#     puts $fid "(find-file \"$factFormPath\")"
#   } else {
#     puts $fid "(find-file-read-only \"$factFormPath\")"
#   }
#   puts $fid "(setq set-visited-file-name \"$factFormPath\")"
#   # no menu bar
#   puts $fid "(menu-bar-mode 0)"
#   # disable save-buffers-kill-emacs -- C-x,C-c
#   puts $fid "(put 'save-buffers-kill-emacs 'disabled t)"
#   # kill emacs with C-x,C-s after saving file
#   # puts $fid "(global-unset-key \"\\\C-x\\\C-s\")"
#   # puts $fid "(global-set-key \"\\\C-x\\\C-s\" 'save-buffer-exit)"
#   # puts $fid "(defun save-buffer-exit ()"
#   # puts $fid "(interactive)"
#   # puts $fid "(basic-save-buffer)"
#   # puts $fid "(kill-emacs))"
#   # make auto-save timeout 1 sec, rather than 30 sec
#   # so that C-x,C-s is not needed to save work
#   # the update proc for the mega-widget will pickup the work
#   # from the auto-saved file
#   puts $fid "(setq auto-save-timeout 1)"
#   puts $fid "(switch-to-buffer \"[file tail $factFormPath]\")"
#   puts $fid "(set-buffer \"[file tail $factFormPath]\")"
#   if {[string match $state normal]} {
#     puts $fid "(let ((start nil) (stop nil))"
#     puts $fid "  (setq start (point))"
#     puts $fid "  (set-mark start)"
#     puts $fid "  (goto-char (point-max))"
#     puts $fid "  (setq stop (point))"
#     puts $fid "  (indent-region start stop nil))"
#     puts $fid "  (goto-char (point-min))"
#   }
#   # save indenting of form
#   puts $fid "(save-buffer)"
#   puts $fid "(load \"${stigParenDir}emacs-stig-paren\")"
#   puts $fid "(setq blink-matching-paren nil)"
#   # if {[string match $state normal]} {
#   #   puts $fid "(message \"C-x,C-s to save changes -- C-x,C-c to exit\")"
#   # } else {
#   #   puts $fid "(message \"C-x,C-c to exit\")"
#   # }
#   close $fid
#   set heightLines 10
#   if {[string match $attributeName initially] || \
#       [string match $attributeName background_model]} {
#     set heightLines 7
#   }
#   # overlaid stand-alone emacs window
#   set command "$EMACS_PATH -q -geometry 60x${heightLines}+$xPos+$yPos -name \"$title\""
#   # helvetica not handled properly by emacs - inserts a space between each char
#   # append command " -font -adobe-helvetica-bold-r-normal-*-14-*-*-*-*-*-*-*"
#   append command " -l \"$emacsPath\" -font 10x20"
#   append command " -bg [preferred StanleyDialogEntryBackgroundColor] -fg black &"
#   AutoSat_Schematic_Object_Cmd Call_CSH $command
# }


## 10jul97 wmt: new - improvement over createEmacsLispWindow
## 03nov97 wmt: no new emacs process (too slow); create a new emacs frame from
##              Livingstone and overlay it on the Stanley dialog 
## problems: window mgr causes random mouse cursor placement of frames as 
##           they are created.
##           - the frames are not attached to dialog they are overlaid
## no used anymore
# proc createEmacsFrame { dialogId entryWidget nodeClassType attributeName \
#                                  state xPos yPos } {
#   global STANLEY_USER_DIR UNIX_BIN EMACS_PATH

#   set factFormDir "${STANLEY_USER_DIR}/[preferred livingstone_directory]/tmp/"
#   set factFormPath "${factFormDir}$dialogId.lisp"
#   set textPath nil; set pirEdgeIndex 0
#   set title [capitalizeWord $attributeName]
#   set heightLines 10
#   if {[string match $attributeName initially] || \
#       [string match $attributeName background_model]} {
#     set heightLines 7
#   }
#   # puts stderr "createEmacsFrame: factFormPath $factFormPath"
#   set lispProgramScript "(lep::eval-in-emacs \"(progn"
#   append lispProgramScript " (setq frame (make-frame"
#   append lispProgramScript " '((width . 60) (height . $heightLines)"
#   append lispProgramScript " (name . \\\"$title\\\") (background-color . \\\"bisque\\\")"
#   append lispProgramScript " (visibility . icon))))"
#   append lispProgramScript " (modify-frame-parameters frame '((left . $xPos)"
#   append lispProgramScript " (top . $yPos) (dialog-id . \\\"$dialogId\\\")"
#   append lispProgramScript " (buffer-name . \\\"[file tail $factFormPath]\\\")"
#   append lispProgramScript " (buffer-path . \\\"$factFormPath\\\")"
#   append lispProgramScript "))"
#   append lispProgramScript " (select-frame frame)"
#   append lispProgramScript " (make-frame-visible frame)"
#   if {[string match $state normal]} {
#     set frameFunction find-file
#   } else {
#     set frameFunction find-file-read-only
#   }
#   append lispProgramScript " ($frameFunction \\\"$factFormPath\\\")"
#   append lispProgramScript " (message \\\"\\\")"
#   append lispProgramScript " (switch-to-buffer \\\"[file tail $factFormPath]\\\")"
#   # no menu bar
#   append lispProgramScript " (menu-bar-mode 0)"
#   # disable save-buffers-kill-emacs -- C-x,C-c
#   append lispProgramScript " (put 'save-buffers-kill-emacs 'disabled t)"
#   # make auto-save timeout 1 sec, rather than 30 sec
#   # so that C-x,C-s is not needed to save work
#   # the update proc for the mega-widget will pickup the work
#   # from the auto-saved file
#   append lispProgramScript " (setq auto-save-timeout 1)"
#   # indenting ??
#   append lispProgramScript " (server-edit) nil)\")"
#   AutoSat_Schematic_Object_Cmd Call_EMACS "*common-lisp*" $lispProgramScript
# }


## destroy a Livingstone frame    
## 03nov97 wmt: new
## not used anymore 
# proc killEmacsFrame { frameId } {

#   # puts stderr "killEmacsFrame: frameId $frameId"
#   set lispProgramScript "(lep::eval-in-emacs \"(progn (dolist (frame (frame-list))"
#   append lispProgramScript " (setq parameters (frame-parameters frame))"
#   append lispProgramScript "(when (string-equal (rest (assoc 'dialog-id parameters))"
#   append lispProgramScript " \\\"$frameId\\\")"
#   append lispProgramScript " (switch-to-buffer (rest (assoc 'buffer-name parameters)))"
#   ## (setq auto-save-timeout 1) handles this, since synchronizing save-buffer with
#   ## the dialog update processing is a problem -- but need this to prevent Emacs
#   ## asking to save modified buffer
#   append lispProgramScript " (save-buffer (rest (assoc 'buffer-path parameters)))"
#   append lispProgramScript " (kill-buffer (rest (assoc 'buffer-name parameters)))"
#   append lispProgramScript " (select-frame frame)"
#   append lispProgramScript " (delete-frame frame)"
#   append lispProgramScript " (return t)))"
#   append lispProgramScript " (setq frame-list-len (length (frame-list)))"
#   append lispProgramScript " (if (= frame-list-len 1)"
#   # restore menu bar
#   append lispProgramScript " (menu-bar-mode 1)"
#   # restore killing emacs
#   append lispProgramScript " (put 'save-buffers-kill-emacs 'disabled nil))"
#   append lispProgramScript " (server-edit) nil)\")"
#   AutoSat_Schematic_Object_Cmd Call_EMACS "*common-lisp*" $lispProgramScript
# }














