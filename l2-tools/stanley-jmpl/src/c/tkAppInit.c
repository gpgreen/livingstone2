/* $Id: tkAppInit.c,v 1.2 2006/04/29 00:47:39 taylor Exp $ */
/***
 *** See the file "l2-tools/disclaimers-and-notices.txt" for 
 *** information on usage and redistribution of this file, 
 *** and for a DISCLAIMER OF ALL WARRANTIES.
 ***/

/* 
 * tkAppInit.c -- from ~/TclTk/tk4.1/unix/tkAppInit.c 
 *
 *	Provides a default version of the Tk_AppInit procedure for
 *	use in wish and similar Tk-based applications.
 *
 * Copyright (c) 1993 The Regents of the University of California.
 * Copyright (c) 1994 Sun Microsystems, Inc.
 *
 * See the file "license.terms" for information on usage and redistribution
 * of this file, and for a DISCLAIMER OF ALL WARRANTIES.
 *
 * SCCS: @(#) tkAppInit.c 1.21 96/03/26 16:47:07
 */

/* #include "tk.h" 03nov95 wmt: & added next three lines */
#include <tcl.h>
#include <tk.h>
#include <itcl.h>
/* #include <Dbg.h> */
/* #include <Dbgtk.h> */
#include <stdio.h>

/* build TkSteal (tkEmacs -- embedded Emacs)
   USE_XACCESS defined in Makefile
   also uncomment  cSOURCES += $(ROOT)/ra/mir/gui/stanley/tksteal/tkXAccess.c
   and TKSTEAL_INC = -I$(ROOT)/ra/mir/gui/stanley/tksteal
   in Makefile
   */
#ifdef USE_XACCESS
#include "tkXAccess.h" 
#endif

/* build Tcl-DP (distributed processing - required by tkEmacs
   USE_TCL_DP defined in Makefile
   */
#ifdef USE_TCL_DP
#include "dp.h"
#endif

/* unccomment next line at Ames to build with TclX (profiling)
 also uncommnet cEXTERNLIBS += -L$(STANLEY_TCL_TK_LIB) -ltclx8.0.0 in Makefile 
#define TCL_X
*/

#ifdef TCL_X 
#include <tclExtend.h>
#endif

/* unccomment next line at Ames to build with TIX
 also uncommnet cEXTERNLIBS += -L$(STANLEY_TCL_TK_LIB) -ltix4.1.8.0 in Makefile
#define TIX
*/

#ifdef TIX 
#include <tix.h> 
#endif

#if !defined(__SVR4) && defined(__sun)
/* missing gcc SunOS 4.1.3 prototypes */
#include "../../prototypes.h"
#endif

#if defined(_WINDOWS)
Tcl_CmdProc AutoSat_Schematic_Tcl_Cmds;
#else
EXTERN Tcl_CmdProc AutoSat_Schematic_Tcl_Cmds;
/*   
 * The following variable is a special hack that is needed in order for
 * Sun shared libraries to be used for Tcl.
 */
extern int matherr(void);
int *tclDummyMathPtr = (int *) matherr;
#endif

#ifdef TK_TEST
EXTERN int		Tktest_Init _ANSI_ARGS_((Tcl_Interp *interp));
#endif /* TK_TEST */

#ifdef TCL_X
EXTERN int		Tclx_Init _ANSI_ARGS_((Tcl_Interp *interp));
#endif /* TCL_X */

/*
 *----------------------------------------------------------------------
 *
 * main --
 *
 *	This is the main program for the application.
 *
 * Results:
 *	None: Tk_Main never returns here, so this procedure never
 *	returns either.
 *
 * Side effects:
 *	Whatever the application does.
 *
 *----------------------------------------------------------------------
 */
/* 03nov95 wmt: changed to ANSI standard */
int main( int argc, char **argv)
    /* int argc;			Number of command-line arguments. */
    /* char **argv;		Values of command-line arguments. */
{
    Tk_Main(argc, argv, Tcl_AppInit);
    return 0;			/* Needed only to prevent compiler warning. */
}

/*
 *----------------------------------------------------------------------
 *
 * Tcl_AppInit --
 *
 *	This procedure performs application-specific initialization.
 *	Most applications, especially those that incorporate additional
 *	packages, will have their own version of this procedure.
 *
 * Results:
 *	Returns a standard Tcl completion code, and leaves an error
 *	message in interp->result if an error occurs.
 *
 * Side effects:
 *	Depends on the startup script.
 *
 *----------------------------------------------------------------------
 */
/* 03nov95 wmt: changed to ANSI standard & added stuff from Brent Welch p.403-404 */

int Combat_Init (Tcl_Interp *);
int Tktable_Init (Tcl_Interp *);

int Tcl_AppInit( Tcl_Interp *interp)
    /* Tcl_Interp *interp;		Interpreter for application. */
{
  /* Tk_Window main = Tk_MainWindow( interp); */
  Display *display;

  /* check for proper linking of X11 libraries in -static mode 
  display = XOpenDisplay("serengeti.arc.nasa.gov:0.0"); 
  if (display == NULL ) { 
    fprintf( stderr, " XOpenDisplay: NULL\n"); 
  } 
  */

  /* Tcl */
  if (Tcl_Init(interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tcl_Init\n");
    return TCL_ERROR;
  }

#ifdef STANLEY_CORBA_P 
  /* Build CORBA interface */

    /* Itcl */
  if (Itcl_Init(interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Itcl_Init\n");
    return TCL_ERROR;
  }
  Tcl_StaticPackage(interp, "Itcl", Itcl_Init, Itcl_SafeInit);

  /*
     *  This is itclsh, so import all [incr Tcl] commands by
     *  default into the global namespace.  Set the "itcl::native"
     *  variable so we can do the same kind of import automatically
     *  during the "auto_mkindex" operation.
     */
  if (Tcl_Import(interp, Tcl_GetGlobalNamespace(interp),
                 "::itcl::*", /* allowOverwrite */ 1) != TCL_OK) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tcl_Import\n");
    return TCL_ERROR;
  }

  if (!Tcl_SetVar(interp, "::itcl::native", "1", TCL_LEAVE_ERR_MSG)) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tcl_SetVar\n");
    return TCL_ERROR;
  }

#if !defined(_WINDOWS) && COMBAT_VER != COMBAT_VER_0_8_1
  /* Combat ORB - formerly TclMico */
  if (Combat_Init (interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Combat_Init\n");
    return TCL_ERROR;
  }

  Tcl_StaticPackage (interp, "Combat", Combat_Init,
                     (Tcl_PackageInitProc *) NULL);
#endif /* _WINDOWS && STANLEY_COMBAT_VERSION */

#endif /* STANLEY_CORBA_P */

  /* Tk */
  if (Tk_Init(interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tk_Init\n");
    return TCL_ERROR;
  }
  Tcl_StaticPackage(interp, "Tk", Tk_Init, (Tcl_PackageInitProc *) NULL);
  /* TkTable */
  if (Tktable_Init(interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tktable_Init\n");
    return TCL_ERROR;
  }
  Tcl_StaticPackage(interp, "Tktable", Tktable_Init,
                    (Tcl_PackageInitProc *) NULL);
  /*
  if (Blt_Init(interp) != TCL_OK) { 
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Blt_Init\n"); 
    return TCL_ERROR; 
  }
  */

#ifdef TK_TEST
  if (Tktest_Init(interp) == TCL_ERROR) {
      return TCL_ERROR;
  }
  Tcl_StaticPackage(interp, "Tktest", Tktest_Init,
          (Tcl_PackageInitProc *) NULL);
#endif /* TK_TEST */

#ifdef TCL_X
    if (Tclx_Init (interp) == TCL_ERROR) {
      fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tclx_Init\n");
      return TCL_ERROR;
    }
    Tcl_StaticPackage (interp, "Tclx", Tclx_Init, Tclx_SafeInit);
#endif /* TCL_X */

#ifdef TIX
    if (Tix_Init(interp) == TCL_ERROR) {
      return TCL_ERROR;
    }
    Tcl_StaticPackage(interp, "Tix", Tix_Init, (Tcl_PackageInitProc *) NULL);
#endif /* TIX */

#ifdef USE_TCL_DP 
    if (Dp_Init(interp) == TCL_ERROR) { 
      fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Tdp_Init\n"); 
      return TCL_ERROR; 
    }
#endif

#ifdef USE_XACCESS
    if (TkSteal_Init(interp) == TCL_ERROR) {
      fprintf( stderr, "TCL_ERROR in Tcl_AppInit from TkSteal_Init\n");
      return TCL_ERROR;
    }
#endif
  /*
   * Call the init procedures for included packages.  Each call should
   * look like this:
   *
   * if (Mod_Init(interp) == TCL_ERROR) {
   *     return TCL_ERROR;
   * }
   *
   * where "Mod" is the name of the module.
   */

  /* add blt to the app  
     if (Blt_Init(interp) != TCL_OK) {
     printf("no blt\n");
     return TCL_ERROR;
     }
     */
  /*
  if (Dbg_InitTk(interp) == TCL_ERROR) {
    fprintf( stderr, "TCL_ERROR in Tcl_AppInit from Dbg_InitTk\n");
    return TCL_ERROR;
  }
  */
  /*
   * Call Tcl_CreateCommand for application-specific commands, if
   * they weren't already created by the init procedures called above.
   */
   Tcl_CreateCommand( interp, "AutoSat_Schematic_Tcl_Cmds", AutoSat_Schematic_Tcl_Cmds,
                     (ClientData) Tk_MainWindow( interp), (Tcl_CmdDeleteProc *) NULL);                

  /* this affects X resource names */
  /* Tk_SetClass( tkwin, "AutoSatSchematic");
     does not work for Tk4.1 */

  /* need tclExtend for this 
     tclAppName = "AutoSatSchematic";
     tclAppLongName = "AutoSatSchematic-Tcl-Tk-TclDbg-TkDbg";
     tclAppVersion = 1.0;
  */
  /*
   * Specify a user-specific startup file to invoke if the application
   * is run interactively.  Typically the startup file is "~/.apprc"
   * where "app" is the name of the application.  If this line is deleted
   * then no user-specific startup file will be run under any conditions.
   Tcl_SetVar(interp, "tcl_rcFileName", "~/.wishrc", TCL_GLOBAL_ONLY);
   */
  /*
     if we are going to be interactive, set up SIGINT handling
     need tclExtend for this 
  value = Tcl_GetVar( interp, "tcl_interactive", TCL_GLOBAL_ONLY);
  if ((value != NULL) && (value[0] != '0'))
    Tcl_SetupSigInt( );
     */

  return TCL_OK;
}

/* ======================================================= */






