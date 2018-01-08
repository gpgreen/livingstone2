#
# This file was automatically generated from test.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{enum {IDL:MyEnum:1.0 MyEnum 1.0} {A B C D}} {struct {IDL:MyStruct:1.0\
MyStruct 1.0} {{s short} {e IDL:MyEnum:1.0} {q string}} {}} {typedef\
{IDL:MySequence:1.0 MySequence 1.0} {sequence IDL:MyStruct:1.0}} {typedef\
{IDL:MyArray:1.0 MyArray 1.0} {array IDL:MyEnum:1.0 3}} {union\
{IDL:NoDefault:1.0 NoDefault 1.0} boolean {{1 e IDL:MyEnum:1.0} {0 s\
IDL:MyStruct:1.0}} {}} {union {IDL:ExplicitDefault:1.0 ExplicitDefault 1.0}\
{unsigned short} {{0 e IDL:MyEnum:1.0} {1 e IDL:MyEnum:1.0} {(default) q\
string}} {}} {union {IDL:WithoutDefault:1.0 WithoutDefault 1.0} boolean {{1 e\
IDL:MyEnum:1.0}} {}} {interface {IDL:AnyTest:1.0 AnyTest 1.0} {} {{attribute\
{IDL:AnyTest/value:1.0 value 1.0} any}}}}

