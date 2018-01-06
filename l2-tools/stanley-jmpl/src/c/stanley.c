/* $Id: stanley.c,v 1.2 2006/04/29 00:47:38 taylor Exp $ */
/***
 *** See the file "l2-tools/disclaimers-and-notices.txt" for 
 *** information on usage and redistribution of this file, 
 *** and for a DISCLAIMER OF ALL WARRANTIES.
 ***/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h> 

#if !defined(_WINDOWS)
#include <sys/param.h>
#include <sys/signal.h>
#endif

#if !defined(__SVR4) && defined(__sun) && defined(__gcc)
/* missing gcc SunOS 4.1.3 prototypes */
#include "../include/prototypes.h"
#endif

#if defined(__SVR4) && defined(__sun) && defined(__gcc)
/* missing gcc SunOS 5.5 prototypes */
#include "../include/prototypes-solaris.h"
#endif

/* Tcl include files */
#include <tcl.h>
#include <tk.h>
/* #include <tkInt.h> */
/* #include <Dbg.h> */
/* #include <Dbgtk.h> */

/* X include files 
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xatom.h>
#include <X11/Xos.h>
#include <X11/extensions/shape.h>
#include <X11/Xmu/WinUtil.h>
*/

#include "stanley.h"

/* #include "dsimple.h" */

/* for tkTable extension standalone */
extern Tcl_CmdProc TableCmd;

/* AUTOSAT_SCHEMATIC_TCL_CMDS
   02nov95 wmt: new - modified from Ellen Drascher 
   
   create a new AutoSat Schematic access object
   */
int AutoSat_Schematic_Tcl_Cmds( ClientData clientData, Tcl_Interp *interp,
                               int argc, char *argv[])
{
  if DEBUG_TCL
    logEntry( "AutoSat_Schematic_Tcl_Cmds", argc, argv);

  /* check arg count */
  check_arg_count( 1, "AutoSat_Schematic_Tcl_Cmds");

  /* use to respond to Tcl->C commands */
#if defined(_WINDOWS)
  Tcl_CreateCommand( interp, "AutoSat_Schematic_Object_Cmd", AutoSat_Schematic_Object_Cmd,
                     (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL);
#else
  Tcl_CreateCommand( interp, "AutoSat_Schematic_Object_Cmd", AutoSat_Schematic_Object_Cmd,
                     (ClientData *) NULL, (Tcl_CmdDeleteProc *) NULL);
#endif
  /* less overhead in these commands 
  Tcl_CreateObjCommand( interp, "assocValue", Assoc_Value_Cmd,
                        (ClientData *) NULL, (Tcl_CmdDeleteProc *) NULL);
  */
                    
  if DEBUG_TCL
    logExit( "AutoSat_Schematic_Tcl_Cmds");
  return TCL_OK;
}


/* AUTOSAT_SCHEMATIC_OBJECT_CMD
   03nov95 wmt: new - modified from Ellen Drascher
   
   cmd switching for single Tcl cmd    
   */
int AutoSat_Schematic_Object_Cmd( ClientData clientData, Tcl_Interp *interp,
                                 int argc, char *argv[])
{
  if DEBUG_TCL
    logEntry( "AutoSat_Schematic_Object_Cmd", argc, argv);

  /* check arg count 
  check_arg_count( 2, "AutoSat_Schematic_Object_Cmd");
  */

  /*
  if (strcmp( argv[1], "Dbg_On_Immediate") == 0) {
    Dbg_On( interp, 1);
  }
  else if (strcmp( argv[1], "Dbg_On_Next_Cmd") == 0) {
    Dbg_On( interp, 0);
  }
  else if (strcmp( argv[1], "Dbg_Off") == 0) {
    Dbg_Off( interp);
  }
  */
  if (strcmp( argv[1], "Call_CSH") == 0) {
    Call_CSH( interp, argv[2]);
  }
  /*
    now using CORBA for Livingstone interface, either Lisp or C++
  else if (strcmp( argv[1], "Call_EMACS") == 0) { 
    Call_EMACS( interp, argv[2], argv[3]); 
  }
  */
  /*
  else if (strcmp( argv[1], "Raise_X_Window") == 0) {
    Raise_X_Window( interp, argv[2]);
  }
  */
  /* 
  else if (strcmp( argv[1], "Call_FCL") == 0) { 
    Call_FCL( interp, argv[2], argv[3]); 
  }
  */
  /*
  else if (strcmp( argv[1], "Get_Tcl_Colormap") == 0) { 
    Get_Tcl_Colormap( interp); 
  }
  */
  /*
  else if (strcmp( argv[1], "Format_Internal_Time") == 0) {
    Format_Internal_Time( interp, argv[2]);
  }
  */
  else {
    sprintf( interp->result, "`%s' not implemented", argv[1]);
    return TCL_ERROR;
  }
  return 0;
}


/* LOGENTRY 
   04aug95 wmt: new - from Ellen Drascher
   */
void logEntry (char *str, int argc, char *argv[])
{
  printf("$$ entry %s [argc=%d]: ",str, argc);
  while (--argc>0) 
	 printf("%s;%c", *++argv, ' ');
  printf("\n");
}


/* LOGEXIT
   04aug95 wmt: new - from Ellen Drascher
   */
void logExit (char *str)
{
  printf("$$ exit %s \n",str);
}


/* CALL_FCL
   19dec95 wmt: new - call Allegro Common Lisp with cmd string
   no longer used
   */
int Call_FCL( Tcl_Interp *interp, char *lisp_prog_name, char *lisp_prog_script)
{
  char fcl_cmd_string[500];
  char fcl_path[100], lisp_prog_path[100];
  char script_path[100], script_file_path[100];
  FILE *script_file_fp = NULL;

  strcpy( fcl_path, getenv ("LISP_PATH"));
  strcpy( lisp_prog_path, getenv ("STANLEY_ROOT"));
  strcat( lisp_prog_path, "/lisp");
  /* STANLEY_USER_DIR is no longer an env var --  it is set in Edit->Prefereneces
  strcpy( script_path, getenv ("STANLEY_USER_DIR"));
  */
  strcat( script_path, "/modules/");
  strcpy( script_file_path, script_path);
  strcat( script_file_path, lisp_prog_name);
  strcat( script_file_path, ".script");
  /* printf( "script_file %s", script_file_path); */
  sprintf( fcl_cmd_string, "%s -e \"(load (string-downcase (namestring #p(:directory \"%s\" "
          ":name \"%s\" :type \"script\"))))\"", fcl_path, script_path, lisp_prog_name);
  /* write cmd_string to "<lisp_program_name>.script" */
  script_file_fp = fopen( script_file_path, "w");
  fprintf( script_file_fp, "(load \"%s/%s.fasl\")\n", lisp_prog_path, lisp_prog_name);
  fprintf( script_file_fp, "%s\n", lisp_prog_script);
  fprintf( script_file_fp, "(user::exit)\n");
  fclose( script_file_fp);
  
  /* printf( "Call_FCL %s", fcl_cmd_string); */
  system( fcl_cmd_string );

  return 0;
}

/*  fcl -e "(load (string-downcase (namestring #p(:directory "/home/tove/p/autosat/stanley/lisp" :name "def-to-cfg" :type "script"))))"    (user::exit)


  char fcl_cmd_string[] = "/usr/local2/bin/ccl4.2 -e \"(load (string-downcase (namestring #p(:directory \"/home/tove/p/autosat/stanley/lisp\" :name \"def-to-cfg\" :type \"fasl\"))))\"";

 */


/* CALL_EMACS 
   08jan96 wmt: invoke gnu emacs editor with file request

   for tcl asynchronous call:
      set lispProgramScript "<fcl form to evaluate>"
      AutoSat_Schematic_Object_Cmd Call_EMACS "*common-lisp*nohang" $lispProgramScript

   for tcl synchronous call:
      set lispProgramScript "(progn <fcl form to evaluate> "
      append lispProgramScript " (lep::eval-in-emacs \"(progn (server-edit) nil)\"))"
      AutoSat_Schematic_Object_Cmd Call_EMACS "*common-lisp*hang" $lispProgramScript
      raiseStanleyWindows; # needed when Call_EMACS is hang

   no loger used
   */
int Call_EMACS( Tcl_Interp *interp, char *emacs_file_name, char *line_number_or_form)
{
  char cmd_string[500];
  char script_file_path[100];
  FILE *script_file_fp = NULL;

  /* fprintf( stderr, "Call_EMACS: 0 `%c' form `%s'\n",
           line_number_or_form[0], line_number_or_form);
           */
  if ((line_number_or_form[0] == '(')) { /* this is an sexp */
    /* write form to "fcl-form.lisp" */
  /* STANLEY_USER_DIR is no longer an env var --  it is set in Edit->Prefereneces
    strcpy( script_file_path, getenv ("STANLEY_USER_DIR"));
  */
    strcat( script_file_path, "/");
    strcat( script_file_path, getenv ("LIVINGSTONE_SUBDIR"));
    strcat( script_file_path, "/fcl-form.lisp");
    strcpy( cmd_string, "/bin/rm -f ");
    strcat( cmd_string, script_file_path);
    system( cmd_string );
    script_file_fp = fopen( script_file_path, "w");
    fprintf( script_file_fp, "%s", line_number_or_form);
    fclose( script_file_fp);
    strcpy( line_number_or_form, "1");
  }
  strcpy( cmd_string, getenv ("EMACS_CLIENT_PATH"));
  strcat( cmd_string, " +");
  strcat( cmd_string, line_number_or_form);
  strcat( cmd_string, " ");
  strcat( cmd_string, emacs_file_name);
  /* fprintf( stderr, "Call_EMACS %s", cmd_string); */

  system( cmd_string );

  fprintf( stderr, "  Done.\n");
  return 0;
}


/* RAISE_STANLEY_LOG 
   11jan96 wmt: raise Stanley Log xterm window above emacs window
                borrow from Rich Keller - RECOM Technologies
                ~keller/c-lang/xraisemosaic-new.c
*/
/*
int Raise_X_Window( Tcl_Interp *interp, char *window_name)
{
  char cmd_string[100], program_name[50] = "Find_Named_Window";
  Window window;
  int argc = 2;
  char *argv[2] = { 0, 0};

  strcpy( cmd_string, window_name);
  argv[0] = &program_name[0]; argv[1] = &cmd_string[0]; 
  Setup_Display_And_Screen(&argc, argv);
  window = Find_Named_Window( cmd_string);
  */
  /* fprintf( stderr, "cmd_string  %s window %ld\n", cmd_string, window); */
/*
  if (window != 0) {
    XRaiseWindow(dpy,window); 
    XSync(dpy, False);    */      /* Flush the X processing buffer and wait for raise
                                   to happen */
/*
    return 0;
  }
  else 
    return 1;
}
*/


/* FIND_NAMED_WINDOW 
   11jan96 from Rich Keller - RECOM Technologies
                ~keller/c-lang/xraisemosaic-new.c
 * Find_Named_Window: Return the window corresponding with name
 *                "windowname" displayed on the default display/screen.
 *                If no such window is on display, return 0.
 */
/*
Window Find_Named_Window( char *windowname)
{
  Window w=0;
*/
  /* Window root = RootWindow(dpy, screen); */
/*
  w = Window_With_Name(dpy, RootWindow(dpy, screen), windowname);
  if (!w)
    fprintf( stderr, "No window with name %s exists!\n", windowname);
  return(w);
}
*/


/* USAGE
 * Report the syntax for calling Find_Named_Window
 */
/*
int usage()
{
    fprintf (stderr,
	"usage:  %s wname\n\n", program_name);
    fprintf (stderr,
	"           where 'wname' is the window name\n\n");
    fprintf (stderr,
	"        This client raises the X window with the name 'wname'\n\n");
    fprintf (stderr,
	"\n");
    exit (1);
}
*/


/* CALL_CSH
   24jan96 wmt: execute shell cmd this way, since Tcl "exec" does not
                seem to do what I want
   */
int Call_CSH( Tcl_Interp *interp, char *cmd_string)
{
  /* fprintf (stderr, "Call_CSH: cmd_string `%s'\n", cmd_string); */
  system( cmd_string );
  return 0;
}
