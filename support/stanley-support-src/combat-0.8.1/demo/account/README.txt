This demo illustrates implementing a CORBA server using Combat, and a
graphical client that uses Combat to access the server via CORBA.

First, run server.tcl.  The server writes its object reference to the
file "server.ior" in the current directory, prints "Running." to the
console, and then runs until terminated.

While the server is running, run client.tcl.  The client brings up a
simple graphical user interface.  It reads the server's object reference
from the file "server.ior" in the current directory.  Open an account
using "Open" from the "Account" menu, and I'm sure you'll figure out the
rest.
