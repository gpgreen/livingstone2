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

itcl::class DiamondA_impl {
    inherit PortableServer::ServantBase
    public method _Interface {} {
	return "IDL:omg.org/PortableServer/DynamicImplementation:1.0"
    }
    public method _primary_interface {oid poa} {
	return "IDL:diamonda:1.0"
    }
    public method _is_a {repoid} {
	switch $repoid {
	    IDL:diamonda:1.0 { return true }
	}
	return false
    }
    public method invoke {request} {
	switch [$request operation] {
	    opa {
		$request arguments {}
		$request set_result [list string opa]
	    }
	    default {
		throw {IDL:omg.org/CORBA/BAD_OPERATION:1.0 \
			{minor 0 completed COMPLETED_NO}}
	    }
	}
    }
}

itcl::class DiamondB_impl {
    inherit PortableServer::ServantBase
    public method _Interface {} {
	return "IDL:omg.org/PortableServer/DynamicImplementation:1.0"
    }
    public method _primary_interface {oid poa} {
	return "IDL:diamondb:1.0"
    }
    public method _is_a {repoid} {
	switch $repoid {
	    IDL:diamonda:1.0 -
	    IDL:diamondb:1.0 { return true }
	}
	return false
    }
    public method invoke {request} {
	switch [$request operation] {
	    opa {
		$request arguments {}
		$request set_result [list string opa]
	    }
	    opb {
		$request arguments {}
		$request set_result [list string opb]
	    }
	    default {
		throw {IDL:omg.org/CORBA/BAD_OPERATION:1.0 \
			{minor 0 completed COMPLETED_NO}}
	    }
	}
    }
}

itcl::class DiamondC_impl {
    inherit PortableServer::ServantBase
    public method _Interface {} {
	return "IDL:omg.org/PortableServer/DynamicImplementation:1.0"
    }
    public method _primary_interface {oid poa} {
	return "IDL:diamondc:1.0"
    }
    public method _is_a {repoid} {
	switch $repoid {
	    IDL:diamonda:1.0 -
	    IDL:diamondc:1.0 { return true }
	}
	return false
    }
    public method invoke {request} {
	switch [$request operation] {
	    opa {
		$request arguments {}
		$request set_result [list string opa]
	    }
	    opc {
		$request arguments {}
		$request set_result [list string opc]
	    }
	    default {
		throw {IDL:omg.org/CORBA/BAD_OPERATION:1.0 \
			{minor 0 completed COMPLETED_NO}}
	    }
	}
    }
}

itcl::class DiamondD_impl {
    inherit PortableServer::ServantBase
    public method _Interface {} {
	return "IDL:omg.org/PortableServer/DynamicImplementation:1.0"
    }
    public method _primary_interface {oid poa} {
	return "IDL:diamondd:1.0"
    }
    public method _is_a {repoid} {
	switch $repoid {
	    IDL:diamonda:1.0 -
	    IDL:diamondb:1.0 -
	    IDL:diamondc:1.0 -
	    IDL:diamondd:1.0 { return true }
	}
	return false
    }
    public method invoke {request} {
	switch [$request operation] {
	    opa {
		$request arguments {}
		$request set_result [list string opa]
	    }
	    opb {
		$request arguments {}
		$request set_result [list string opb]
	    }
	    opc {
		$request arguments {}
		$request set_result [list string opc]
	    }
	    opd {
		$request arguments {}
		$request set_result [list string opd]
	    }
	    default {
		throw {IDL:omg.org/CORBA/BAD_OPERATION:1.0 \
			{minor 0 completed COMPLETED_NO}}
	    }
	}
    }
}

itcl::class Server_impl {
    inherit PortableServer::ServantBase

    public method _Interface {} {
	return "IDL:omg.org/PortableServer/DynamicImplementation:1.0"
    }

    public method _primary_interface {oid poa} {
	return "IDL:operations:1.0"
    }

    public method _is_a {repoid} {
	switch $repoid {
	    IDL:operations:1.0 { return true }
	}
	return false
    }

    public variable s 42
    public variable ra "Hello World"

    public method square { x } {
	return [expr {$x * $x}]
    }

    public method copy { sin sout_name } {
	upvar $sout_name sout
	set sout $sin
	return [string length $sin]
    }

    public method length { queue oe_name } {
	upvar $oe_name oe
	set res [llength $queue]
	if {[expr $res % 2] == 0} {
	    set oe EVEN
	} else {
	    set oe ODD
	}
	return $res
    }

    public method squares { howmany } {
	set res ""
	for {set i 0} {$i < $howmany} {incr i} {
	    lappend res [list member [expr $i * $i]]
	}
	return $res
    }

    public method reverse { str_name } {
	upvar $str_name str
	set res ""
	foreach c [split $str {}] {
	    set res $c$res
	}
	set str $res
    }

    public method nop {} {
    }

    public method dup {} {
	return [_this]
    }

    public method dup2 {o1 o2_name} {
	upvar $o2_name o2
	set o2 $o1
    }

    public method isme {obj} {
	return [[_this] _is_equivalent $obj]
    }

    public method getdiamond {} {
	set da [DiamondA_impl #auto]
	set db [DiamondB_impl #auto]
	set dc [DiamondC_impl #auto]
	set dd [DiamondD_impl #auto]

	#
	# According to the CORBA 2.3 specs, implicit activation doesn't
	# work for DSI servants. This is probably a bug in the specs and
	# has been reported as an issue.
	#

	set res(a) [$::poa servant_to_reference $da]
	set res(b) [$::poa servant_to_reference $db]
	set res(c) [$::poa servant_to_reference $dc]
	set res(d) [$::poa servant_to_reference $dd]
	set res(abcd) [list $res(a) $res(b) $res(c) $res(d)]

	return [array get res]
    }

    public method DontCallMe {} {
	corba::throw {IDL:Oops:1.0 {what {I said, don't call me!}}}
    }

    public method invoke { request } {
	switch [$request operation] {
	    _get_s {
		$request arguments {}
		$request set_result [list short $s]
	    }

	    _set_s {
		set s [$request arguments {{in {unsigned short}}}]
		$request set_result {void {}}
	    }

	    _get_ra {
		$request arguments {}
		$request set_result [list string $ra]
	    }

	    square {
		set x [$request arguments {{in short}}]
		set res [square $x]
		$request set_result [list {unsigned long} $res]
	    }

	    copy {
		set args [$request arguments {{in string} {out string}}]
		set sin  [lindex $args 0]
		set sout [lindex $args 1]
		set res  [copy $sin $sout]
		$request set_result [list long $res]
	    }

	    length {
		set args [$request arguments {{in {sequence {struct IDL:S:1.0 {member long}}}} {out {enum {ODD EVEN}}}}]
		set queue [lindex $args 0]
		set oe [lindex $args 1]
		set res [length $queue $oe]
		$request set_result [list {unsigned short} $res]
	    }

	    squares {
		set howmany [$request arguments {{in {unsigned short}}}]
		set res [squares $howmany]
		$request set_result [list {sequence {struct IDL:S:1.0 {member long}}} $res]
	    }
	    
	    reverse {
		set str [$request arguments {{inout string}}]
		reverse $str
		$request set_result {void {}}
	    }

	    nop {
		$request arguments {}
		$request set_result {void {}}
	    }

	    dup {
		$request arguments {}
		set res [dup]
		$request set_result [list {Object IDL:operations:1.0} $res]
	    }

	    dup2 {
		set args [$request arguments {{in {Object IDL:omg.org/CORBA/Object:1.0}} {out {Object IDL:omg.org/CORBA/Object:1.0}}}]
		set o1 [lindex $args 0]
		set o2 [lindex $args 1]
		dup2 $o1 $o2
		$request set_result {void {}}
	    }

	    isme {
		set obj [$request arguments {{in {Object IDL:omg.org/CORBA/Object:1.0}}}]
		set res [isme $obj]
		$request set_result [list boolean $res]
	    }

	    getdiamond {
		$request arguments {}
		set res [getdiamond]
		$request set_result [list {struct IDL:diamond:1.0 {a {Object IDL:diamonda:1.0} b {Object IDL:diamondb:1.0} c {Object IDL:diamondc:1.0} d {Object IDL:diamondd:1.0} abcd {sequence {Object IDL:omg.org/CORBA/Object:1.0}}}} $res]
	    }

	    DontCallMe {
		$request arguments {}
		corba::try {
		    DontCallMe
		    $request set_result {void {}}
		} catch {IDL:Oops:1.0 ex} {
		    $request set_exception [list {exception IDL:Oops:1.0 {what string}} $ex]
		}
	    }

	    default {
		corba::throw {IDL:omg.org/CORBA/BAD_OPERATION:1.0 \
			{minor 0 completed COMPLETED_NO}}
	    }
	}
    }

}

#
# Initialize ORB
#

eval corba::init $argv

#
# Create a Server server and activate it
#

set poa [corba::resolve_initial_references RootPOA]
set mgr [$poa the_POAManager]
set srv [Server_impl #auto]
set oid [$poa activate_object $srv]

set reffile [open "server.ior" w]
set ref [$poa id_to_reference $oid]
set str [corba::object_to_string $ref]
puts -nonewline $reffile $str
close $reffile

#
# Activate the POA
#

$mgr activate

#
# .. and start serving requests ...
#

vwait forever

puts "oops"
