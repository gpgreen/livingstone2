#
# This file was automatically generated from test.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{enum {IDL:E_:1.0 E_ 1.0} {A B C D}} {typedef {IDL:E:1.0 E 1.0} IDL:E_:1.0}\
{union {IDL:Union1:1.0 Union1 1.0} short {{0 a short} {-1 b string} {1 b\
string} {-2 c IDL:E:1.0} {2 c IDL:E:1.0}} {}} {union {IDL:Union2:1.0 Union2\
1.0} IDL:E:1.0 {{A av short} {B bv string} {C cv {unsigned long}} {D dv\
IDL:E:1.0}} {}} {union {IDL:Union3:1.0 Union3 1.0} boolean {{1 a {unsigned\
short}} {0 b long}} {}} {union {IDL:Union4:1.0 Union4 1.0} boolean {{1 a\
{unsigned short}} {(default) b long}} {}} {union {IDL:Union5:1.0 Union5 1.0}\
short {{1 a {unsigned short}} {2 b string} {3 b string} {(default) c\
IDL:E:1.0}} {}} {union {IDL:Union6:1.0 Union6 1.0}} {union {IDL:Union6:1.0\
Union6 1.0} boolean {{1 s {sequence IDL:Union6:1.0}} {0 l long}} {}} {union\
{IDL:Union7:1.0 Union7 1.0} short {{1 u IDL:Union7/subu:1.0} {(default) d\
IDL:Union7/subs:1.0}} {{union {IDL:Union7/subu:1.0 subu 1.0} boolean {{1 l\
long}} {}} {struct {IDL:Union7/subs:1.0 subs 1.0} {{l string}} {}}}}\
{interface {IDL:unions:1.0 unions 1.0} {} {{attribute {IDL:unions/u1:1.0 u1\
1.0} IDL:Union1:1.0} {attribute {IDL:unions/u2:1.0 u2 1.0} IDL:Union2:1.0}\
{attribute {IDL:unions/u3:1.0 u3 1.0} IDL:Union3:1.0} {attribute\
{IDL:unions/u4:1.0 u4 1.0} IDL:Union4:1.0} {attribute {IDL:unions/u5:1.0 u5\
1.0} IDL:Union5:1.0} {attribute {IDL:unions/u6:1.0 u6 1.0} IDL:Union6:1.0}\
{attribute {IDL:unions/u7:1.0 u7 1.0} IDL:Union7:1.0}}}}

