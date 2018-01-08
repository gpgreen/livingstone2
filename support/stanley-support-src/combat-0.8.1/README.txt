
----------------------------------------------------------------------
The Combat ORB
----------------------------------------------------------------------

Combat is a CORBA Object Request Broker (ORB) that allows the
implementation of CORBA clients and servers in the Tcl programming
language.

On the client side, Combat is not only useful to easily test-drive
existing CORBA servers, including rapid prototyping, the ability
for rapid protodypting or to interactively interface with servers
from a console, but makes Tcl an exciting language for distributed
programming.  Also, Tk allows to quickly develop attractive user
interfaces accessing CORBA services.  Server-side scripting using
[incr Tcl] classes also offers a wide range of possibilities.

Combat is compatible with the CORBA 3.0 specification including the
IIOP protocol, and has been tested to interoperate with a wide range
of open-source and commercial ORBs, including Mico, TAO and
ORBexpress.

Combat is written in purte Tcl, allowing it to run on all platforms
supported by Tcl, which is a much wider range than supported by any
other ORB.

Combat has the following features:

 - IIOP / GIOP 1.0, 1.1 and 1.2 (unidirectional only).
 - All IDL data types, including Type Codes, Objects by Value and
   recursive data types.
 - Asynchronous invocations, callbacks and timeouts.
 - Codeset negotiation when using GIOP 1.2. Thanks to Tcl's encoding
   system, a wide range of character sets is supported.
 - IOR:, corbaloc:, corbaname:, file: and http: object URL formats.
 - Server-side scripting with full Portable Object Adapter (POA)
   support.
 - Downloading of Interface Repository information at runtime, if
   an Interface Repository is available or if the server supports
   the CORBA Reflection specification.
 - Fully event based.


Installation
------------

Installation has to be performed manually:

(1) Make sure that the "orb" subdirectory is picked up by
    "package require".  This can be achieved by either:

    - copying the orb directory to your existing Tcl library location
      ([info library]),
    - adding the orb directory to your TCLLIBPATH environment variable,
      or
    - adding the orb directory to the auto_path variable at runtime.

    Correct installation can be verified by starting a Tcl or Wish
    console and typing:

      package require combat

    If this returns Combat's version number, installation was
    successful.

(2) Install idl2tcl and iordump by:

    - Editing the top of both scripts so that they use your tclsh of
      choice.
    - Making sure that the executable bit is set for both files
      ("chmod +x").
    - Adding Combat's "bin" subdirectory to your search path.

    Alternatively, you can copy both scripts into a directory in your
    search path.  However, then you will also have to install the
    "tclkill" package into a location where it is picked up by "package
    require" (see above) -- idl2tcl requires this package and normally
    picks it up from "../tclkill".

    Installation is successful when you can run "idl2tcl" in your console
    (when started without command-line options, it will just print a brief
    usage message).


Note that all "executable scripts" in this package assume the availability
of Tcl 8.5 and require either "tclsh8.5" or "tclsh85" to be in your $PATH
(i.e., they all do the equivalent of "#! tclsh8.5").  This applies to
"idl2tcl", "iordump", the "server.tcl" and "client.tcl" scripts for each
demo, and the "dotest" and "server.tcl" files for each test.  If you want
to run the demos or tests but use a different version of Tcl, then you
might want to edit these files to use your preferred Tcl version instead.
Or you can start the correct Tcl interptreter explicitly, e.g.,
"tclsh8.4 server.tcl".


More Information
----------------

Documentation is available in the "doc" subdirectory.  There are a few
small demonstrations in the "demo" directory.  Finally, there is the
Combat homepage: http://www.fpx.de/Combat/


License
-------

The Combat package is copyrighted by its author, Frank Pilhofer, and
is released under BSD license, without any warranties.


--------------
Frank Pilhofer
fp@fpx.de
