#
# This file was automatically generated from test.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{valuetype {IDL:EmptyValue:1.0 EmptyValue 1.0} 0 {} {} {} {} {}} {valuetype\
{IDL:Date:1.0 Date 1.0} 0 {} {} {} {} {{valuemember {IDL:Date/day:1.0 day\
1.0} {unsigned short} public} {valuemember {IDL:Date/month:1.0 month 1.0}\
{unsigned short} public} {valuemember {IDL:Date/year:1.0 year 1.0} {unsigned\
short} public}}} {valuetype {IDL:BaseType:1.0 BaseType 1.0} 0 {} {} {} {}\
{{valuemember {IDL:BaseType/name:1.0 name 1.0} string public}}} {valuetype\
{IDL:DerivedType:1.0 DerivedType 1.0} IDL:BaseType:1.0 {} {} {} {}\
{{valuemember {IDL:DerivedType/value:1.0 value 1.0} {unsigned long} public}\
{valuemember {IDL:DerivedType/anothername:1.0 anothername 1.0} string\
public}}} {valuetype {IDL:TreeNode:1.0 TreeNode 1.0} 0 {} {} {} {}\
{{valuemember {IDL:TreeNode/nv:1.0 nv 1.0} IDL:BaseType:1.0 public}\
{valuemember {IDL:TreeNode/left:1.0 left 1.0} IDL:TreeNode:1.0 public}\
{valuemember {IDL:TreeNode/right:1.0 right 1.0} IDL:TreeNode:1.0 public}}}\
{interface {IDL:ValueTest:1.0 ValueTest 1.0} {} {{attribute\
{IDL:ValueTest/ev:1.0 ev 1.0} IDL:EmptyValue:1.0} {attribute\
{IDL:ValueTest/d:1.0 d 1.0} IDL:Date:1.0} {attribute {IDL:ValueTest/bt:1.0 bt\
1.0} IDL:BaseType:1.0} {attribute {IDL:ValueTest/dt:1.0 dt 1.0}\
IDL:DerivedType:1.0} {attribute {IDL:ValueTest/tn:1.0 tn 1.0}\
IDL:TreeNode:1.0} {attribute {IDL:ValueTest/vb:1.0 vb 1.0} {value base}}}}}

