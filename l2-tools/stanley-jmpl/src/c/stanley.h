/* $Id: stanley.h,v 1.2 2006/04/29 00:47:39 taylor Exp $ */
/***
 *** See the file "l2-tools/disclaimers-and-notices.txt" for 
 *** information on usage and redistribution of this file, 
 *** and for a DISCLAIMER OF ALL WARRANTIES.
 ***/

/* to be included by stanley.c */

#ifndef __STANLEY_H
#define __STANLEY_H

#ifdef DEBUG_TCL
#define DEBUG_TCL (1) 
#else
#define DEBUG_TCL (0) 
#endif

/* verify the argc value */
#define check_arg_count(n, fname) \
  if (argc != n) { \
    sprintf(interp->result, "%s : wrong # args, expected %d, got %d", \
	    fname, n, argc); \
    return TCL_ERROR; \
  }

#define check_arg_count_at_least(n, fname) \
  if (argc < n) { \
    sprintf(interp->result, "%s : wrong # args, expected %d or more, got %d", \
	    fname, n, argc); \
    return TCL_ERROR; \
  }
 


/* function prototypes for stanley.c */

int AutoSat_Schematic_Tcl_Cmds( ClientData clientData, Tcl_Interp *interp,
                               int argc, char *argv[]);

int AutoSat_Schematic_Object_Cmd( ClientData clientData, Tcl_Interp *interp,
                                 int argc, char *argv[]);

void logEntry (char *str, int argc, char *argv[]);

void logExit (char *str);

int Call_FCL( Tcl_Interp *interp, char *lisp_prog_name, char *lisp_prog_script);

int Call_EMACS( Tcl_Interp *interp, char *emacs_file_name, char *line_number_or_form);

/*
int Raise_X_Window( Tcl_Interp *interp, char *window_name);

Window Find_Named_Window( char *windowname);

int usage();
*/

int Call_CSH( Tcl_Interp *interp, char *cmd_string);


#endif
