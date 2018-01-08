----------------------------------------------------------------------
The "kill" extension for Tcl
----------------------------------------------------------------------

Tcl provides the "exec" command to start processes in the background.
In that case, the command returns a (list of) process identifier(s)
(PIDs).  However, Tcl does not have any other built-in functions to
make use of PIDs.  Sometimes, a Tcl application may want to terminate
the processes that it started.  On Unix, one can always use "exec"
to execute the system's "kill" command.  But that fails on Windows.

The "kill" extension provides a "kill" command that can be used both
on Windows and Unix.  (And presumably MacOSX, although I haven't
tested that.)

A compiled extension that implements the "kill" command is provided
for Windows and Linux/x86.  On other platforms, "kill" is implemented
as a function that calls "exec kill $pid".

Installation:

  Place the "tclkill" directory in your Tcl library directory.
  Alternatively, lappend the tclkill directory to the ::auto_path
  variable.

Usage:

  package require kill ?1.0?
  kill ?pid?

This should work with any PID returned from the "exec" command when
it is used to start a process in the background.

Windows implementation notes
----------------------------

This "kill" command should only be used with console applications.
This extension does not implement the recommended procedure to close
Windows (GUI) applications (which is to post the WM_CLOSE message to
the application's open windows).  See Microsoft KB 178893,
http://support.microsoft.com/kb/178893


Unix implementation notes
-------------------------

The "kill" command sends a SIGTERM signal to the process.  This is
different from typing CTRL-C on the console, which usually sends a
SIGINT instead.  SIGTERM is considered more explicit; however, it
opens the possibility that an application will behave differently
when receiving a SIGTERM vs. SIGINT signal.


Build notes
-----------

This package includes a Makefile.  It is specific to the author's
directory set-up.  Hopefully there will be no need for you to
recompile, but if there is, you will have to edit the Makefile.


License notes
-------------

Written 2008 by Frank Pilhofer.  This extension is so trivial that
I can not assert any copyright.  Consider this package to be in the
public domain.  Contact me at fp@fpx.de (unfortunately, this mailbox
is frequently flooded with spam).
