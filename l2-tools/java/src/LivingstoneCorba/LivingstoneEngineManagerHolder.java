package LivingstoneCorba;

/**
* LivingstoneCorba/LivingstoneEngineManagerHolder.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from LivingstoneCorba.idl
* Thursday, April 20, 2006 4:53:49 PM PDT
*/

public final class LivingstoneEngineManagerHolder implements org.omg.CORBA.portable.Streamable
{
  public LivingstoneCorba.LivingstoneEngineManager value = null;

  public LivingstoneEngineManagerHolder ()
  {
  }

  public LivingstoneEngineManagerHolder (LivingstoneCorba.LivingstoneEngineManager initialValue)
  {
    value = initialValue;
  }

  public void _read (org.omg.CORBA.portable.InputStream i)
  {
    value = LivingstoneCorba.LivingstoneEngineManagerHelper.read (i);
  }

  public void _write (org.omg.CORBA.portable.OutputStream o)
  {
    LivingstoneCorba.LivingstoneEngineManagerHelper.write (o, value);
  }

  public org.omg.CORBA.TypeCode _type ()
  {
    return LivingstoneCorba.LivingstoneEngineManagerHelper.type ();
  }

}
