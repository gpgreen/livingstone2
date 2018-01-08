#
# This file was automatically generated from test.idl
# by idl2tcl. Do not edit.
#

package require combat

combat::ir add \
{{enum {IDL:Enum1:1.0 Enum1 1.0} {A B C D E}} {enum {IDL:Enum2:1.0 Enum2 1.0}\
{Z Y X W V}} {typedef {IDL:datum:1.0 datum 1.0} {unsigned long}} {struct\
{IDL:Struct1:1.0 Struct1 1.0} {{s short} {e1 IDL:Enum1:1.0} {q string}} {}}\
{struct {IDL:Struct2:1.0 Struct2 1.0} {{b boolean} {s1 IDL:Struct1:1.0} {e2\
IDL:Enum2:1.0} {ul {unsigned long}}} {}} {struct {IDL:Struct3_:1.0 Struct3_\
1.0} {{s1 IDL:Struct1:1.0} {s2 IDL:Struct2:1.0}} {}} {typedef\
{IDL:Struct3:1.0 Struct3 1.0} IDL:Struct3_:1.0} {struct {IDL:Struct4:1.0\
Struct4 1.0}} {struct {IDL:Struct4:1.0 Struct4 1.0} {{name string} {left\
{sequence IDL:Struct4:1.0 1}} {right {sequence IDL:Struct4:1.0 1}}} {}}\
{typedef {IDL:Seq1:1.0 Seq1 1.0} {sequence IDL:Struct1:1.0}} {typedef\
{IDL:Seq2:1.0 Seq2 1.0} {sequence IDL:Struct2:1.0 2}} {typedef {IDL:Seq3:1.0\
Seq3 1.0} {sequence char 16}} {typedef {IDL:Seq4:1.0 Seq4 1.0} {sequence\
octet 8}} {typedef {IDL:Arr1:1.0 Arr1 1.0} {array IDL:Enum1:1.0 3}} {typedef\
{IDL:Arr2:1.0 Arr2 1.0} {array {array IDL:Enum2:1.0 3} 2}} {typedef\
{IDL:Arr3:1.0 Arr3 1.0} {array char 16}} {typedef {IDL:Arr4:1.0 Arr4 1.0}\
{array octet 8}} {typedef {IDL:OctSeq:1.0 OctSeq 1.0} {sequence octet}}\
{interface {IDL:composed:1.0 composed 1.0} {} {{attribute\
{IDL:composed/e1:1.0 e1 1.0} IDL:Enum1:1.0} {attribute {IDL:composed/e2:1.0\
e2 1.0} IDL:Enum2:1.0} {attribute {IDL:composed/d:1.0 d 1.0} IDL:datum:1.0}\
{attribute {IDL:composed/s1:1.0 s1 1.0} IDL:Struct1:1.0} {attribute\
{IDL:composed/s2:1.0 s2 1.0} IDL:Struct2:1.0} {attribute {IDL:composed/s3:1.0\
s3 1.0} IDL:Struct3:1.0} {attribute {IDL:composed/s4:1.0 s4 1.0}\
IDL:Struct4:1.0} {attribute {IDL:composed/q1:1.0 q1 1.0} IDL:Seq1:1.0}\
{attribute {IDL:composed/q2:1.0 q2 1.0} IDL:Seq2:1.0} {attribute\
{IDL:composed/q3:1.0 q3 1.0} IDL:Seq3:1.0} {attribute {IDL:composed/q4:1.0 q4\
1.0} IDL:Seq4:1.0} {attribute {IDL:composed/a1:1.0 a1 1.0} IDL:Arr1:1.0}\
{attribute {IDL:composed/a2:1.0 a2 1.0} IDL:Arr2:1.0} {attribute\
{IDL:composed/a3:1.0 a3 1.0} IDL:Arr3:1.0} {attribute {IDL:composed/a4:1.0 a4\
1.0} IDL:Arr4:1.0} {attribute {IDL:composed/os:1.0 os 1.0} IDL:OctSeq:1.0}}}}

