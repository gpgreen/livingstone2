#! /bin/sh
# \
# the next line restarts using tclsh8.5 on unix \
if type tclsh8.5 > /dev/null 2>&1 ; then exec tclsh8.5 "$0" ${1+"$@"} ; fi
# the next line restarts using tclsh85 on Windows using Cygwin \
if type tclsh85 > /dev/null 2>&1 ; then exec tclsh85 "`cygpath --windows $0`" ${1+"$@"} ; fi
# the next line complains about a missing tclsh \
echo "This software requires Tcl 8.5 to run." ; \
echo "Make sure that \"tclsh8.5\" or \"tclsh85\" is in your \$PATH" ; \
exit 1

#
# Load the Combat package.
#

lappend auto_path ../../orb  ;# Known location of the Combat ORB
package require combat

#
# HelloWorld server implementation
#

itcl::class HelloWorld_impl {
    inherit PortableServer::ServantBase
    
    public method _Interface {} {
	return "::HelloWorld"
    }
  
    public variable messageCounter 0

    public method hello {message} {
	puts "The client says: $message"
	incr messageCounter
    }
}

#
# Initialize the ORB and load the Interface Repository.
#

eval corba::init $argv
source hello.tcl

#
# Obtain a POA pseudo object and retrieve its POA Manager.
#

set poa [corba::resolve_initial_references RootPOA]
set mgr [$poa the_POAManager]

#
# Create a HelloWorld servant and activate it.
#

set srv [HelloWorld_impl #auto]
set oid [$poa activate_object $srv]

#
# Print object reference to the console.
#

set ref [$poa id_to_reference $oid]
set ior [corba::object_to_string $ref]
puts "$ior"

#
# Write the object reference to a file.
#

set iorfile [open "server.ior" w]
puts -nonewline $iorfile $ior
close $iorfile

#
# Activate the POA.
#

$mgr activate

#
# ... and serve ...
#

puts "Running."
vwait forever

#
# This program never exits.
#
