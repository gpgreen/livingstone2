package LivingstoneCorba;


/**
* LivingstoneCorba/LivingstoneAssignmentReportHelper.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from LivingstoneCorba.idl
* Thursday, April 20, 2006 4:53:49 PM PDT
*/

abstract public class LivingstoneAssignmentReportHelper
{
  private static String  _id = "IDL:LivingstoneCorba/LivingstoneAssignmentReport/LivingstoneAssignmentReport:1.0";

  public static void insert (org.omg.CORBA.Any a, LivingstoneCorba.LivingstoneAssignmentReport that)
  {
    org.omg.CORBA.portable.OutputStream out = a.create_output_stream ();
    a.type (type ());
    write (out, that);
    a.read_value (out.create_input_stream (), type ());
  }

  public static LivingstoneCorba.LivingstoneAssignmentReport extract (org.omg.CORBA.Any a)
  {
    return read (a.create_input_stream ());
  }

  private static org.omg.CORBA.TypeCode __typeCode = null;
  private static boolean __active = false;
  synchronized public static org.omg.CORBA.TypeCode type ()
  {
    if (__typeCode == null)
    {
      synchronized (org.omg.CORBA.TypeCode.class)
      {
        if (__typeCode == null)
        {
          if (__active)
          {
            return org.omg.CORBA.ORB.init().create_recursive_tc ( _id );
          }
          __active = true;
          org.omg.CORBA.StructMember[] _members0 = new org.omg.CORBA.StructMember [1];
          org.omg.CORBA.TypeCode _tcOf_members0 = null;
          _tcOf_members0 = LivingstoneCorba.AssignmentHelper.type ();
          _tcOf_members0 = org.omg.CORBA.ORB.init ().create_sequence_tc (0, _tcOf_members0);
          _members0[0] = new org.omg.CORBA.StructMember (
            "assignments",
            _tcOf_members0,
            null);
          __typeCode = org.omg.CORBA.ORB.init ().create_struct_tc (LivingstoneCorba.LivingstoneAssignmentReportHelper.id (), "LivingstoneAssignmentReport", _members0);
          __active = false;
        }
      }
    }
    return __typeCode;
  }

  public static String id ()
  {
    return _id;
  }

  public static LivingstoneCorba.LivingstoneAssignmentReport read (org.omg.CORBA.portable.InputStream istream)
  {
    LivingstoneCorba.LivingstoneAssignmentReport value = new LivingstoneCorba.LivingstoneAssignmentReport ();
    int _len0 = istream.read_long ();
    value.assignments = new LivingstoneCorba.Assignment[_len0];
    for (int _o1 = 0;_o1 < value.assignments.length; ++_o1)
      value.assignments[_o1] = LivingstoneCorba.AssignmentHelper.read (istream);
    return value;
  }

  public static void write (org.omg.CORBA.portable.OutputStream ostream, LivingstoneCorba.LivingstoneAssignmentReport value)
  {
    ostream.write_long (value.assignments.length);
    for (int _i0 = 0;_i0 < value.assignments.length; ++_i0)
      LivingstoneCorba.AssignmentHelper.write (ostream, value.assignments[_i0]);
  }

}
