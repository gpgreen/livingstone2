#! /bin/sh
# the next line restarts using tclsh8.5 on unix \
if type tclsh8.5 > /dev/null 2>&1 ; then exec tclsh8.5 "$0" ${1+"$@"} ; fi
# the next line restarts using tclsh85 on Windows using Cygwin \
if type tclsh85 > /dev/null 2>&1 ; then exec tclsh85 "`cygpath --windows $0`" ${1+"$@"} ; fi
# the next line complains about a missing tclsh \
echo "This software requires Tcl 8.5 to run." ; \
echo "Make sure that \"tclsh8.5\" or \"tclsh85\" is in your \$PATH" ; \
exit 1

lappend auto_path ../../orb
package require combat

#
# The Account server
#

itcl::class Account_impl {
    inherit PortableServer::ServantBase

    private variable mybank

    constructor {bank} {
	set mybank $bank
    }

    public method _Interface {} {
	return "::Account"
    }

    private variable balance 0

    public method deposit { amount } {
	set balance [expr $balance + $amount]
    }

    public method withdraw { amount } {
	if {$amount > $balance} {
	    corba::throw [list IDL:Account/Bankrupt:1.0 \
		    [list balance $balance amount $amount]]
	}
	set balance [expr $balance - $amount]
    }

    public method balance {} {
	return $balance
    }

    public method destroy {} {
	set obj [corba::resolve_initial_references POACurrent]
	set poa [$obj get_POA]
	set oid [$obj get_object_id]
	$poa deactivate_object $oid
	$mybank goodbye $oid
	itcl::delete object $this
    }
}

itcl::class Bank_impl {
    inherit PortableServer::ServantBase

    private variable accounts
    private variable mypoa

    constructor {poa} {
	set mypoa $poa
    }

    public method _Interface {} {
	return "::Bank"
    }

    public method create {name password} {
	if {[info exists accounts($name)]} {
	    if {$accounts($name) != $password} {
		corba::throw IDL:Bank/NotAuthorized:1.0
	    }
	    return [$mypoa id_to_reference $name]
	}
	set accounts($name) $password
	set acc [namespace current]::[::Account_impl \#auto $this]
	$mypoa activate_object_with_id $name $acc
	return [$mypoa id_to_reference $name]
    }

    public method goodbye {name} {
	unset accounts($name)
    }
}

#
# Initialize ORB and feed the local Interface Repository
#

eval corba::init $argv
source [file join [file dirname [info script]] account.tcl]

#
# Create a new POA with the USER_ID policy
#

set poa   [corba::resolve_initial_references RootPOA]
set mgr   [$poa the_POAManager]
set mypoa [$poa create_POA MyPOA $mgr {RETAIN USER_ID}]

#
# Create a Bank and activate it
#

set srv [Bank_impl #auto $mypoa]
set oid [$poa activate_object $srv]

#
# write Bank's IOR to file
#

set reffile [open "server.ior" w]
set ref [$poa id_to_reference $oid]
set str [corba::object_to_string $ref]
puts -nonewline $reffile $str
close $reffile

#
# Activate the POAs
#

$mgr activate

#
# .. and serve the bank ...
#

puts "Running."
vwait forever

puts "oops"
