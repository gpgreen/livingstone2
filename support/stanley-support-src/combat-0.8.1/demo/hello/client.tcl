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
# Initialize the ORB.
#

set argv [eval corba::init $argv]

#
# Get a message from the command line.
#

if {[llength $argv] == 0} {
    puts stderr "usage: $argv0 <message>"
    exit 1
}

set message $argv

#
# Load the Interface Repository.
#

source hello.tcl

#
# The server's object reference is in the file "./server.ior" in the
# current directory.
#

if {![file exists "server.ior"]} {
    puts stderr "Oops: File \"server.ior\" does not exist."
    exit 1
}

set obj [corba::string_to_object file://[pwd]/server.ior]

#
# Say Hello World!
#

$obj hello $message

#
# Print the server's messageCounter attribute.
#

set messageCounter [$obj messageCounter]
puts "The server's message counter is $messageCounter."

#
# Release the object reference.
#

corba::release $obj
