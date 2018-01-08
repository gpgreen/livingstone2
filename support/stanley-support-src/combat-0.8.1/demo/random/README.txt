
Note: at the time of this writing (November 2008), the CORBA interface to
the random number service is not functional, and the Web site below only
says "to do."

This demo retrieves true random numbers from a CORBA server on the internet,
so running the client requires a live internet connection.

  See http://www.random.org/
  and http://www.random.org/clients/corba/

The client retrieves the server's object reference from
http://www.random.org/Random.ior and thus requires the http package to
be available.

The file "Random.idl" contains the server's IDL description, a copy of
http://www.random.org/Random.idl.  "Random.tcl" is just the result of
running `idl2tcl Random.idl'.

Run `./random'.

If the client fails to connect to the server, please check the above URLs
to see if the object reference's address or the IDL has changed.

