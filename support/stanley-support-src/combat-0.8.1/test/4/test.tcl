#
# This file was automatically generated from test.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{enum {IDL:E:1.0 E 1.0} {ODD EVEN}} {struct {IDL:S:1.0 S 1.0} {{member\
long}} {}} {typedef {IDL:Q:1.0 Q 1.0} {sequence IDL:S:1.0}} {exception\
{IDL:Oops:1.0 Oops 1.0} {{what string}} {}} {interface {IDL:diamonda:1.0\
diamonda 1.0} {} {{operation {IDL:diamonda/opa:1.0 opa 1.0} string {} {}}}}\
{interface {IDL:diamondb:1.0 diamondb 1.0} IDL:diamonda:1.0 {{operation\
{IDL:diamondb/opb:1.0 opb 1.0} string {} {}}}} {interface {IDL:diamondc:1.0\
diamondc 1.0} IDL:diamonda:1.0 {{operation {IDL:diamondc/opc:1.0 opc 1.0}\
string {} {}}}} {interface {IDL:diamondd:1.0 diamondd 1.0} {IDL:diamondb:1.0\
IDL:diamondc:1.0} {{operation {IDL:diamondd/opd:1.0 opd 1.0} string {} {}}}}\
{struct {IDL:diamond:1.0 diamond 1.0} {{a IDL:diamonda:1.0} {b\
IDL:diamondb:1.0} {c IDL:diamondc:1.0} {d IDL:diamondd:1.0} {abcd {sequence\
Object}}} {}} {interface {IDL:operations:1.0 operations 1.0} {} {{attribute\
{IDL:operations/s:1.0 s 1.0} short} {attribute {IDL:operations/ra:1.0 ra 1.0}\
string readonly} {operation {IDL:operations/square:1.0 square 1.0} {unsigned\
long} {{in x short}} {}} {operation {IDL:operations/copy:1.0 copy 1.0} long\
{{in sin string} {out sout string}} {}} {operation {IDL:operations/length:1.0\
length 1.0} {unsigned short} {{in queue IDL:Q:1.0} {out oe IDL:E:1.0}} {}}\
{operation {IDL:operations/squares:1.0 squares 1.0} IDL:Q:1.0 {{in howmany\
{unsigned short}}} {}} {operation {IDL:operations/reverse:1.0 reverse 1.0}\
void {{inout str string}} {}} {operation {IDL:operations/nop:1.0 nop 1.0}\
void {} {} oneway} {operation {IDL:operations/dup:1.0 dup 1.0}\
IDL:operations:1.0 {} {}} {operation {IDL:operations/dup2:1.0 dup2 1.0} void\
{{in o1 Object} {out o2 Object}} {}} {operation {IDL:operations/isme:1.0 isme\
1.0} boolean {{in obj Object}} {}} {operation {IDL:operations/getdiamond:1.0\
getdiamond 1.0} IDL:diamond:1.0 {} {}} {operation\
{IDL:operations/DontCallMe:1.0 DontCallMe 1.0} void {} IDL:Oops:1.0}}}}

