package LivingstoneCorba;


/**
* LivingstoneCorba/_LivingstoneEngineManagerImplBase.java .
* Generated by the IDL-to-Java compiler (portable), version "3.2"
* from LivingstoneCorba.idl
* Thursday, April 20, 2006 4:53:49 PM PDT
*/

public abstract class _LivingstoneEngineManagerImplBase extends org.omg.CORBA.portable.ObjectImpl
                implements LivingstoneCorba.LivingstoneEngineManager, org.omg.CORBA.portable.InvokeHandler
{

  // Constructors
  public _LivingstoneEngineManagerImplBase ()
  {
  }

  private static java.util.Hashtable _methods = new java.util.Hashtable ();
  static
  {
    _methods.put ("describe", new java.lang.Integer (0));
    _methods.put ("getCommandLine", new java.lang.Integer (1));
    _methods.put ("getRunningCommandLine", new java.lang.Integer (2));
    _methods.put ("exit", new java.lang.Integer (3));
  }

  public org.omg.CORBA.portable.OutputStream _invoke (String $method,
                                org.omg.CORBA.portable.InputStream in,
                                org.omg.CORBA.portable.ResponseHandler $rh)
  {
    org.omg.CORBA.portable.OutputStream out = null;
    java.lang.Integer __method = (java.lang.Integer)_methods.get ($method);
    if (__method == null)
      throw new org.omg.CORBA.BAD_OPERATION (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);

    switch (__method.intValue ())
    {
       case 0:  // LivingstoneCorba/LivingstoneEngineManager/describe
       {
         String $result = null;
         $result = this.describe ();
         out = $rh.createReply();
         out.write_string ($result);
         break;
       }

       case 1:  // LivingstoneCorba/LivingstoneEngineManager/getCommandLine
       {
         String search_method = in.read_string ();
         int max_candidate_classes_returned = in.read_long ();
         int max_candidates_returned = in.read_long ();
         int max_candidates_searched = in.read_long ();
         int max_cutoff_weight = in.read_long ();
         int max_history_cutoff = in.read_long ();
         int max_trajectories_tracked = in.read_long ();
         String progress_cmd_type = in.read_string ();
         String fc_cmd_type = in.read_string ();
         LivingstoneCorba.LivingstoneCommandLine $result = null;
         $result = this.getCommandLine (search_method, max_candidate_classes_returned, max_candidates_returned, max_candidates_searched, max_cutoff_weight, max_history_cutoff, max_trajectories_tracked, progress_cmd_type, fc_cmd_type);
         out = $rh.createReply();
         LivingstoneCorba.LivingstoneCommandLineHelper.write (out, $result);
         break;
       }

       case 2:  // LivingstoneCorba/LivingstoneEngineManager/getRunningCommandLine
       {
         LivingstoneCorba.LivingstoneCommandLine $result = null;
         $result = this.getRunningCommandLine ();
         out = $rh.createReply();
         LivingstoneCorba.LivingstoneCommandLineHelper.write (out, $result);
         break;
       }

       case 3:  // LivingstoneCorba/LivingstoneEngineManager/exit
       {
         this.exit ();
         out = $rh.createReply();
         break;
       }

       default:
         throw new org.omg.CORBA.BAD_OPERATION (0, org.omg.CORBA.CompletionStatus.COMPLETED_MAYBE);
    }

    return out;
  } // _invoke

  // Type-specific CORBA::Object operations
  private static String[] __ids = {
    "IDL:LivingstoneCorba/LivingstoneEngineManager:1.0"};

  public String[] _ids ()
  {
    return (String[])__ids.clone ();
  }


} // class _LivingstoneEngineManagerImplBase