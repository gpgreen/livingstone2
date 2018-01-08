#
# This file was automatically generated from account.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{interface {IDL:Account:1.0 Account 1.0} {} {{exception\
{IDL:Account/Bankrupt:1.0 Bankrupt 1.0} {{balance {unsigned long}} {amount\
{unsigned long}}} {}} {operation {IDL:Account/deposit:1.0 deposit 1.0} void\
{{in amount {unsigned long}}} {}} {operation {IDL:Account/withdraw:1.0\
withdraw 1.0} void {{in amount {unsigned long}}} IDL:Account/Bankrupt:1.0}\
{operation {IDL:Account/balance:1.0 balance 1.0} long {} {}} {operation\
{IDL:Account/destroy:1.0 destroy 1.0} void {} {}}}} {interface {IDL:Bank:1.0\
Bank 1.0} {} {{exception {IDL:Bank/NotAuthorized:1.0 NotAuthorized 1.0} {}\
{}} {operation {IDL:Bank/create:1.0 create 1.0} IDL:Account:1.0 {{in name\
string} {in password string}} IDL:Bank/NotAuthorized:1.0}}}}

