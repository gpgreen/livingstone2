#! /bin/sh
# the next line restarts using wish8.5 on unix \
if type wish8.5 > /dev/null 2>&1 ; then exec wish8.5 "$0" ${1+"$@"} ; fi
# the next line restarts using wish85 on Windows using Cygwin \
if type wish85 > /dev/null 2>&1 ; then exec wish85 "`cygpath --windows $0`" ${1+"$@"} ; fi
# the next line complains about a missing wish \
echo "This software requires Tcl/Tk 8.5 to run." ; \
echo "Make sure that \"wish8.5\" or \"wish85\" is in your \$PATH" ; \
exit 1

lappend auto_path ../../orb
package require Tk
package require combat

#
# ----------------------------------------------------------------------
#

set balance "(no account)"
set bank 0
set account 0
set name ""

#
# ----------------------------------------------------------------------
#
# GUI
#
# ----------------------------------------------------------------------
#

wm title . "Banking Application"
menu .menu -tearoff 0
menu .menu.file -tearoff 0
menu .menu.acc -tearoff 0
.menu add cascade -label "File" -menu .menu.file -underline 0
.menu add cascade -label "Account" -menu .menu.acc -underline 0
.menu.file add command -label "Exit" -command exit -underline 0
.menu.acc add command -label "Open" -command Open -underline 0
.menu.acc add command -label "Destroy" -command Destroy -underline 0
. configure -menu .menu

frame .balance
label .balance.title -justify center -anchor center -width 20 \
	-font -Adobe-Helvetica-Bold-R-Normal--*-180-*-*-*-*-*-* \
	-text "Current Balance:"
label .balance.balance -justify center -anchor center -width 10 -padx 5mm \
	-font -Adobe-Helvetica-Bold-R-Normal--*-180-*-*-*-*-*-* \
	-textvariable balance
pack .balance.title .balance.balance -side left -fill x -expand true
pack .balance -side top -fill x -expand true

frame .buttons
frame .buttons.deposit
button .buttons.deposit.but -justify left -anchor w \
	-relief raised -bd 1 -width 20 \
	-command Deposit -text "Deposit:"
entry .buttons.deposit.entry
pack .buttons.deposit.but -side left -fill x -expand true
pack .buttons.deposit.entry -side left -fill both -expand true
pack .buttons.deposit -side top -fill both -expand true
bind .buttons.deposit.entry <Return> Deposit

frame .buttons.withdraw
button .buttons.withdraw.but -justify left -anchor w \
	-relief raised -bd 1 -width 20 \
	-command Withdraw -text "Withdraw:"
entry .buttons.withdraw.entry
pack .buttons.withdraw.but -side left -fill x -expand true
pack .buttons.withdraw.entry -side left -fill both -expand true
pack .buttons.withdraw -side top -fill both -expand true
pack .buttons -side top -fill both -expand true
bind .buttons.withdraw.entry <Return> Withdraw

label .status -justify left -anchor w -relief raised -bd 2
pack .status -side top -fill x -expand true

update

#
# ----------------------------------------------------------------------
#
# Initialize ORB
#
# ----------------------------------------------------------------------
#

eval corba::init $argv
source [file join [file dirname [info script]] account.tcl]

#
# Connect to the Bank. Its reference is in ./server.ior
#

.status configure -text "Connecting to Bank ..."
update

if {[catch {set bank [corba::string_to_object file://[pwd]/server.ior]} err]} {
    tk_dialog .oops "Cannot connect to Bank" "Connecting the Bank has\
	    failed. I was expecting to find the IOR in the file\
	    [pwd]/server.ior. Error message is \"$err\"" error 0 Ok
    exit 1
}

.status configure -text "Ok. Open Account to continue."
update

#
# ----------------------------------------------------------------------
#
# Commands for User Actions
#
# ----------------------------------------------------------------------
#

#
# Open an account
#

proc Open {} {
    global bank account name mutex

    toplevel .open
    wm title .open "Open Account"
    frame .open.name
    label .open.name.text -justify left -anchor w -width 20 \
	    -text "Account Name" 
    entry .open.name.entry
    pack .open.name.text .open.name.entry -side left -fill x -expand true

    frame .open.pwd
    label .open.pwd.text -justify left -anchor w -width 20 \
	    -text "Password"
    entry .open.pwd.entry
    pack .open.pwd.text .open.pwd.entry -side left -fill x -expand true

    frame .open.but -relief raised -bd 1
    button .open.but.open -justify center -anchor center \
	    -text "Open Account" -command "set ::mutex open"
    button .open.but.cancel -justify center -anchor center \
	    -text "Cancel" -command "set ::mutex cancel"
    pack .open.but.open .open.but.cancel -side left -fill both -expand true

    pack .open.name .open.pwd -side top -fill x -expand true
    pack .open.but -side top -fill both -expand true

    grab .open
    focus .open.name.text

    .status configure -text "Opening Account ..."

    vwait mutex

    grab release .open

    if {$mutex == "cancel"} {
	destroy .open
	return
    }

    set newname [.open.name.entry get]
    set pwd [.open.pwd.entry get]

    .status configure -text "Opening Account $newname ..."

    corba::try {
	set account [$bank create $newname $pwd]
	set name $newname
	.status configure -text "Using Account $name."
    } catch {IDL:Bank/NotAuthorized:1.0} {
	tk_dialog .oops "Not Authorized" \
		"You are not authorized to open account $newname.\
		The password was probably wrong." \
		error 0 Ok
    } catch {... err} {
	tk_dialog .oops "Error Opening Account" \
		"An error occured opening the account: \"$err\"" \
		error 0 Ok
    }

    UpdateBalance
    destroy .open
    return
}

#
# Destroy an Account
#

proc Destroy {} {
    global name account

    if {$account == 0} {
	tk_dialog .oops "No Open Account" \
		"You cannot destroy an account, because you have not\
		openend an account." \
		error 0 Ok
	return
    }

    set idx [tk_dialog .oops "Destroy Account $name" \
	    "Are you sure that you want to destroy the account $name?" \
	    warning 1 Yes No Cancel]

    if {$idx != 0} {
	return
    }

    corba::try {
	$account destroy
	set account 0
	.status configure -text "No Account."
    } catch {... err} {
	tk_dialog .oops "Error Destroying Account" \
		"An error occured destroying the account: \"$err\"" \
		error 0 Ok
    }

    UpdateBalance
}

proc Deposit {} {
    global account

    if {$account == 0} {
	tk_dialog .oops "No Open Account" \
		"Open an account first!" \
		error 0 Ok
	return
    }
    
    set amount [.buttons.deposit.entry get]

    if {$amount == "" || ![string is integer $amount] || $amount < 0} {
	tk_dialog .oops "Invalid Value" \
		"Cannot deposit $amount: not a number." \
		error 0 Ok
	return
    }

    .status configure -text "Depositing $amount ..."

    corba::try {
	$account deposit $amount
    } catch {... err} {
	tk_dialog .oops "Error Depositing" \
		"An error occured while depositing: \"$err\"" \
		error 0 Ok
    }

    .status configure -text "Deposited $amount."
    .buttons.deposit.entry delete 0 end
    UpdateBalance
}

proc Withdraw {} {
    global account

    if {$account == 0} {
	tk_dialog .oops "No Open Account" \
		"Open an account first!" \
		error 0 Ok
	return
    }
    
    set amount [.buttons.withdraw.entry get]

    if {$amount == "" || ![string is integer $amount] || $amount < 0} {
	tk_dialog .oops "Invalid Value" \
		"Cannot withdraw $amount: not a number." \
		error 0 Ok
	return
    }

    .status configure -text "Withdrawing $amount ..."

    corba::try {
	$account withdraw $amount
    } catch {IDL:Account/Bankrupt:1.0 err} {
	array set ex [lindex $err 1]
	tk_dialog .oops "Error Withdrawing" \
		"You cannot withdraw $ex(amount) because the balance\
		of your account is only $ex(balance)." \
		error 0 Ok
	unset ex
    } catch {... err} {
	tk_dialog .oops "Error Withdrawing" \
		"An error occured while depositing: \"$err\"" \
		error 0 Ok
    }

    .status configure -text "Withdrew $amount."
    .buttons.withdraw.entry delete 0 end
    UpdateBalance
}


proc UpdateBalance {} {
    global account name balance

    if {$account == 0} {
	set balance "(no account)"
	set name ""
	return
    }

    corba::try {
	set balance [$account balance]
    } catch {...} {
    }
}

proc UpdateLoop {} {
    UpdateBalance
    after 5000 UpdateLoop
}

#
# ----------------------------------------------------------------------
#
# Enter Event Loop
#
# ----------------------------------------------------------------------
#

UpdateLoop

