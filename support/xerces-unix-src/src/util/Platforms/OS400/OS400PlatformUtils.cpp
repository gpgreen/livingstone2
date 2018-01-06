/*
 * The Apache Software License, Version 1.1
 * 
 * Copyright (c) 1999-2000 The Apache Software Foundation.  All rights
 * reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer. 
 * 
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 * 
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:  
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 * 
 * 4. The names "Xerces" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written 
 *    permission, please contact apache\@apache.org.
 * 
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 * 
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 * 
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation, and was
 * originally based on software copyright (c) 1999, International
 * Business Machines, Inc., http://www.ibm.com .  For more information
 * on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

/**
 * $Log: OS400PlatformUtils.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:51  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.3  2000/03/18 00:00:01  roddey
 * Initial updates for two way transcoding support
 *
 * Revision 1.2  2000/03/02 21:10:38  abagchi
 * Added empty function platformTerm()
 *
 * Revision 1.1  2000/02/10 17:58:07  abagchi
 * Initial checkin
 *
 */

// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#define MY_XP_CPLUSPLUS
#include    "OS400PlatformUtils.hpp" 
#include    <pthread.h>
#include    <util/PlatformUtils.hpp>
#include    <util/RuntimeException.hpp>
#include    <util/Janitor.hpp>
#include    <util/XMLString.hpp>
#include    <stdio.h>
#include    <stdlib.h>
#include    <errno.h>
#include    <unistd.h>
#include    <qp0z1170.h>
#include    <mimchint.h>
#include    <string.h>
#include    <qmhsndpm.h>
#include    <except.h>

#if defined (XML_USE_ICONV400_TRANSCODER)
    #include <util/Transcoders/Iconv400/Iconv400TransService.hpp>
#elif defined (XML_USE_ICU_TRANSCODER)
    #include <util/Transcoders/ICU/ICUTransService.hpp>
#else
 Transcoder not Specified - FOr OS/400 must be either ICU or Iconv400 
#endif

#if defined(XML_USE_MSGFILE_MESSAGELOADER)
	 #include <util/MsgLoaders/MsgFile/MsgLoader.hpp>
#elif defined(XML_USE_INMEM_MESSAGELOADER)
	 #include <util/MsgLoaders/InMemory/InMemMsgLoader.hpp>
#else 
	 #include <util/MsgLoaders/ICU/ICUMsgLoader.hpp>
#endif



char* PackingRepText(const char * const repText1,
		     const char * const repText2,
		     const char * const repText3,
		     const char * const repText4);
// ---------------------------------------------------------------------------
//  Local Methods
// ---------------------------------------------------------------------------

static void WriteCharStr( FILE* stream, const char* const toWrite)
{
    if (fputs(toWrite, stream) == EOF)
    {
	ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Strm_StdErrWriteFailure);
    }
}


static void WriteUStrStdErr( const XMLCh* const toWrite)
{
    char* tmpVal = XMLString::transcode(toWrite);
    ArrayJanitor<char> janText(tmpVal);
    if (fputs(tmpVal, stderr) == EOF)
    {
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Strm_StdErrWriteFailure);
    }
}

static void WriteUStrStdOut( const XMLCh* const toWrite)
{

	char* tmpVal = XMLString::transcode(toWrite);
    ArrayJanitor<char> janText(tmpVal);
    if (fputs(tmpVal, stdout) == EOF)
    {
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Strm_StdOutWriteFailure);
    }
}
XMLNetAccessor* XMLPlatformUtils::makeNetAccessor()
{
    return 0;
}



// ---------------------------------------------------------------------------
//  XMLPlatformUtils: Platform init method
// ---------------------------------------------------------------------------
static pthread_mutex_t* gAtomicOpMutex =0 ;

void XMLPlatformUtils::platformInit()
{
    //
    // The gAtomicOpMutex mutex needs to be created 
	// because compareAndSwap and incrementlocation and decrementlocation 
	// does not have the atomic system calls for usage
    // Normally, mutexes are created on first use, but there is a
    // circular dependency between compareAndExchange() and
    // mutex creation that must be broken.

    gAtomicOpMutex = new pthread_mutex_t;	

    if (pthread_mutex_init(gAtomicOpMutex, NULL))
        panic( XMLPlatformUtils::Panic_SystemInit );
}
//
//  This method is called very early in the bootstrapping process. This guy
//  must create a transcoding service and return it. It cannot use any string
//  methods, any transcoding services, throw any exceptions, etc... It just
//  makes a transcoding service and returns it, or returns zero on failure.
//

XMLTransService* XMLPlatformUtils::makeTransService()
#if defined (XML_USE_ICU_TRANSCODER)
{
    return new ICUTransService;
}
#elif defined (XML_USE_ICONV400_TRANSCODER)
{
    return new Iconv400TransService;
}
#else
{
    return new IconvTransService;
}
#endif

//
//  This method is called by the platform independent part of this class
//  when client code asks to have one of the supported message sets loaded.
//  In our case, we use the ICU based message loader mechanism.
//
XMLMsgLoader* XMLPlatformUtils::loadAMsgSet(const XMLCh* const msgDomain)
{
    XMLMsgLoader* retVal;
    try
    {
#if defined(XML_USE_MSGFILE_MESSAGELOADER)
        #include <util/MsgLoaders/MsgFile/MsgLoader.hpp>
        retVal = new MsgCatalogLoader(msgDomain);
#elif defined (XML_USE_ICU_MESSAGELOADER)
	retVal = new ICUMsgLoader(msgDomain);
#elif defined (XML_USE_ICONV_MESSAGELOADER)
	retVal = new MsgCatalogLoader(msgDomain);
#else
	retVal = new InMemMsgLoader(msgDomain);
#endif
    }

    catch(...)
    {
        panic( XMLPlatformUtils::Panic_NoDefTranscoder );
    }
    return retVal;
}

// ---------------------------------------------------------------------------
//  XMLPlatformUtils: The panic method
// ---------------------------------------------------------------------------
void XMLPlatformUtils::panic(const PanicReasons reason)
{
    //
    //  We just print a message and exit, Note we are currently dependent on
    // the number of reasons being under 10 for this teo work
    //
    {
struct reason_code
 {
    char reason_char;
    char endofstring;
 }
 reason_code;
 reason_code.reason_char = '0';
 reason_code.endofstring = '\0';
 reason_code.reason_char = reason_code.reason_char + reason;
 send_message((char*)&reason_code,GENERAL_PANIC_MESSAGE,'e'); 
}
}
// ---------------------------------------------------------------------------
//  XMLPlatformUtils: File Methods
// ---------------------------------------------------------------------------
unsigned int XMLPlatformUtils::curFilePos(FileHandle theFile)
{
    // Get the current position
    int curPos = ftell( (FILE*)theFile);
    if (curPos == -1)
	ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotGetSize);

    return (unsigned int)curPos;
}

void XMLPlatformUtils::closeFile(FileHandle theFile)
{
    if (fclose((FILE*)theFile))
	ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotCloseFile);
}


unsigned int XMLPlatformUtils::fileSize(FileHandle theFile)
{
    // Get the current position
    long  int curPos = ftell((FILE*)theFile);
    if (curPos == -1)
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotGetCurPos);

    // Seek to the end and save that value for return
     if (fseek( (FILE*)theFile, 0, SEEK_END) )
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotSeekToEnd);

    long int retVal = ftell( (FILE*)theFile);
    if (retVal == -1)
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotSeekToEnd);

    // And put the pointer back
    if (fseek( (FILE*)theFile, curPos, SEEK_SET) )
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotSeekToPos);

    return (unsigned int)retVal;
}

#include <qmhrtvm.h>
#include <qusec.h>
FileHandle XMLPlatformUtils::openFile(const XMLCh* const fileName)
{   char errno_id[7];
    const char* tmpFileName = XMLString::transcode(fileName);
    ArrayJanitor<char> janText((char*)tmpFileName);
    errno = 0;
    FileHandle retVal = (FILE*)fopen( tmpFileName , "rb" );

    if (retVal == NULL)
    {
     send_message((char*)tmpFileName,FILE_OPEN_PROBLEMS,'d');
     convert_errno(errno_id,errno);
     send_message(NULL,errno_id,'d');
        return 0;
    }
    return retVal;
}

FileHandle XMLPlatformUtils::openFile(const char* const fileName)
{   char errno_id[7];
    errno = 0;
    FileHandle retVal = (FILE*)fopen( fileName , "rb" );

    if (retVal == NULL)
    {
     send_message((char*)fileName,FILE_OPEN_PROBLEMS,'d');
     convert_errno(errno_id,errno);
     send_message(NULL,errno_id,'d');
        return 0;
    }
    return retVal;
}


unsigned int
XMLPlatformUtils::readFileBuffer(  FileHandle      theFile
                                , const unsigned int    toRead
                                , XMLByte* const  toFill)
{
    size_t noOfItemsRead = fread( (void*) toFill, 1, toRead, (FILE*)theFile);

    if(ferror((FILE*)theFile))
    {
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotReadFromFile);
    }
    return (unsigned int)noOfItemsRead;
}


void XMLPlatformUtils::resetFile(FileHandle theFile)
{
    // Seek to the start of the file
    if (fseek((FILE*)theFile, 0, SEEK_SET) )
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotResetFile);
}





// ---------------------------------------------------------------------------
//  XMLPlatformUtils: Timing Methods
// ---------------------------------------------------------------------------
unsigned long XMLPlatformUtils::getCurrentMillis()
{
 _MI_Time mt; 
         struct timeval tv; 
         int rc; 

         mattod(mt);
   rc = Qp0zCvtToTimeval(&tv, mt, QP0Z_CVTTIME_TO_TIMESTAMP);
   return((tv.tv_sec*1000 )+ (tv.tv_usec/1000));
}
/* since we do not have the realpath function on AS/400 and it appears
to no be important that we convert the name to the real path we will
only verify that the path exists  - note that this may make AS/400 output a different error for the pathname but customer should
be able to determine what the name is suppose to be*/
#include <unistd.h>
#include <errno.h>
#include <string.h>
char *realpath(const char *file_name, char *resolved_name)
{
 if (file_name== NULL)
 {
   errno = EINVAL;
   return(NULL);
 }
 if (access(file_name,F_OK)) /* verify that the file exists*/
 {
  errno = EACCES;
  return(NULL);
 }
 else
 /* code says that we make a copy of the file name so do it */
  strcpy(resolved_name,file_name);
  return(resolved_name);
}




XMLCh* XMLPlatformUtils::getFullPath(const XMLCh* const srcPath)
{
 
    //
    //  NOTE: THe path provided has always already been opened successfully,
    //  so we know that its not some pathological freaky path. It comes in
    //  in native format, and goes out as Unicode always
    //
    char* newSrc = XMLString::transcode(srcPath);
     ArrayJanitor<char> janText(newSrc);
    // Use a local buffer that is big enough for the largest legal path
    char *absPath = new char[256];
	//get the absolute path 
    char* retPath = realpath(newSrc, absPath);	
    ArrayJanitor<char> janText2(retPath);
	
    if (!retPath)
    {
		ThrowXML(XMLPlatformUtilsException, XML4CExcepts::File_CouldNotGetBasePathName);
    }
    return XMLString::transcode(absPath);


}
bool XMLPlatformUtils::isRelative(const XMLCh* const toCheck)
{
    // Check for pathological case of empty path
    if (!toCheck[0])
        return false;

    //
    //  If it starts with a slash, then it cannot be relative. This covers
    //  both something like "\Test\File.xml" and an NT Lan type remote path
    //  that starts with a node like "\\MyNode\Test\File.xml".
    //
    if (*toCheck == chForwardSlash)
        return false;

    // Else assume its a relative path
    return true;
}
XMLCh* XMLPlatformUtils::weavePaths
    (
        const   XMLCh* const    basePath
        , const XMLCh* const    relativePath
    )
{
// Create a buffer as large as both parts and empty it
    XMLCh* tmpBuf = new XMLCh[XMLString::stringLen(basePath)
                              + XMLString::stringLen(relativePath)
                              + 2];
    *tmpBuf = 0;

    //
    //  If we have no base path, then just take the relative path as
    //  is.
    //
    if (!basePath)
    {
        XMLString::copyString(tmpBuf, relativePath);
        return tmpBuf;
    }

    if (!*basePath)
    {
        XMLString::copyString(tmpBuf, relativePath);
        return tmpBuf;
    }

    if (*relativePath == chForwardSlash)
    {
        XMLString::copyString(tmpBuf, relativePath);
        return tmpBuf;
    }

    const XMLCh* basePtr = basePath + (XMLString::stringLen(basePath) - 1);
    if ((*basePtr != chForwardSlash)
    &&  (*basePtr != chBackSlash))
    {
        while ((basePtr >= basePath)
        &&     ((*basePtr != chForwardSlash) && (*basePtr != chBackSlash)))
        {
            basePtr--;
        }
    }

    // There is no relevant base path, so just take the relative part
    if (basePtr < basePath)
    {
        XMLString::copyString(tmpBuf, relativePath);
        return tmpBuf;
    }

    // After this, make sure the buffer gets handled if we exit early
    ArrayJanitor<XMLCh> janBuf(tmpBuf);

    //
    //  We have some path part, so we need to check to see if we ahve to
    //  weave any of the parts together.
    //
    const XMLCh* pathPtr = relativePath;
    while (true)
    {
		// If it does not start with some period, then we are done
        if (*pathPtr != chPeriod)
            break;

        unsigned int periodCount = 1;
        pathPtr++;
        if (*pathPtr == chPeriod)
        {
            pathPtr++;
            periodCount++;
        }

        // Has to be followed by a \ or / or the null to mean anything
        if ((*pathPtr != chForwardSlash) && (*pathPtr != chBackSlash)
        &&  *pathPtr)
        {
            break;
        }
        if (*pathPtr)
            pathPtr++;

        // If its one period, just eat it, else move backwards in the base
        if (periodCount == 2)
        {
            basePtr--;
            while ((basePtr >= basePath)
            &&     ((*basePtr != chForwardSlash) && (*basePtr != chBackSlash)))
            {
                basePtr--;
            }

            // The base cannot provide enough levels, so its in error/
            if (basePtr < basePath)
                ThrowXML(PlatformUtilsException, File_BasePathUnderflow);
        }
    }

    // Copy the base part up to the base pointer
    XMLCh* bufPtr = tmpBuf;
    const XMLCh* tmpPtr = basePath;
    while (tmpPtr <= basePtr)
        *bufPtr++ = *tmpPtr++;

    // And then copy on the rest of our path
    XMLString::copyString(bufPtr, pathPtr);

    // Orphan the buffer and return it
    janBuf.orphan();
	return tmpBuf;
}



void send_message (char * text, char * messageid, char type)
{


           short textsize;
           char* buffer;
           char* anchor;
           char* id;
           char message_id[8] = "CPF9897";/* id for raw txt
                                             message                */
           char message_file_name[21];
           char message_type[11] ="*DIAG     ";/* send diagnostic
                                                           message   */
           char call_stack[11] ="*         " ;/* current callstack*/
           int call_stack_counter= 0;/* sent to current call stack */
           char message_key[4]; /* return value - not used          */
            struct {
             int bytes_available;
             int bytes_used;
             char exception_id[7];
             char reserved;
             char exception_data[1];
                    } error_code;
           int msg_size;
          char* msg_type;
         error_code.bytes_available = sizeof(error_code);
/* check input parameters and set up the message information */
         if (messageid != 0)  /* was a message id passed   */
	 {
           if (strncmp(messageid,"CPF",3) &&
               strncmp(messageid,"CPE",3))
             strcpy(message_file_name,"QXMLMSG   *LIBL     ");
           else
             strcpy(message_file_name,"QCPFMSG   QSYS      ");


           id = messageid; /* yes - use the id, will be
                           in QCPFMSG                              */

	 }
 
         else  /* just use what we have for immediate text          */
	 {
           id = &message_id[0];
           strcpy(message_file_name,"QCPFMSG   QSYS      ");

	 }
         if (type == 'e')  /* is this the terminating exception     */
              msg_type = "*COMP      ";/* set it as completion      */
         else            /* currently all other messages are
                             diagnostics                             */
              msg_type = "*DIAG      ";     
         if (text != 0)                  /* was a text field passed           */ 
 
         {
          textsize = strlen(text);
          msg_size = textsize + sizeof(short);
          buffer = (char*)malloc(msg_size);
          anchor = buffer;
          memcpy(buffer, (void*)&textsize, sizeof(short));
          buffer +=sizeof(short);
          memcpy(buffer, text, textsize);
         }
         else
           msg_size = 0;
         #pragma exception_handler(jsendprob, 0, _C1_ALL, _C2_ALL,_CTLA_HANDLE)

              QMHSNDPM((char *)id,&message_file_name,anchor,
                     msg_size,(char*)msg_type,(char*)&call_stack,
                     call_stack_counter,&message_key,&error_code);

   jsendprob:

#pragma disable_handler

    return ;

}

void abnormal_termination(int termcode)
{
   send_message(NULL,"CPF9899",'e'); /* send final exception that we have terminated*/ 
}
// -----------------------------------------------------------------------
//  Mutex methods 
// -----------------------------------------------------------------------

#if !defined (APP_NO_THREADS)

class  RecursiveMutex
{
public:
    pthread_mutex_t   mutex;
    int               recursionCount;
    pthread_t         tid;

    RecursiveMutex() { 
		       if (pthread_mutex_init(&mutex, NULL))
			    ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Mutex_CouldNotCreate);
                       recursionCount = 0;
                       tid.reservedHiId = 0;
		       tid.reservedLoId = 0;
                       tid.reservedHandle = 0;
                     };

    ~RecursiveMutex() {
			if (pthread_mutex_destroy(&mutex))
			    ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Mutex_CouldNotDestroy);
                      };

     void lock()      {
			  if (pthread_equal(tid, pthread_self()))
			  {
			      recursionCount++;
			      return;
			  }
			  if (pthread_mutex_lock(&mutex) != 0)
			      ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Mutex_CouldNotLock);
			  tid = pthread_self();
			  recursionCount = 1;
		      };


     void unlock()    {
                          if (--recursionCount > 0)
                              return;

			  if (pthread_mutex_unlock(&mutex) != 0)
			      ThrowXML(XMLPlatformUtilsException, XML4CExcepts::Mutex_CouldNotUnlock);
                          tid.reservedHandle= 0;
			  tid.reservedHiId = 0;
			  tid.reservedLoId = 0;
                       };
   };

void* XMLPlatformUtils::makeMutex()
{
    return new RecursiveMutex;
};


void XMLPlatformUtils::closeMutex(void* const mtxHandle)
{
    if (mtxHandle == NULL)
        return;
    RecursiveMutex *rm = (RecursiveMutex *)mtxHandle;
    delete rm;
};


void XMLPlatformUtils::lockMutex(void* const mtxHandle)
{
    if (mtxHandle == NULL)
        return;
    RecursiveMutex *rm = (RecursiveMutex *)mtxHandle;
    rm->lock();
}

void XMLPlatformUtils::unlockMutex(void* const mtxHandle)
{
    if (mtxHandle == NULL)
        return;
    RecursiveMutex *rm = (RecursiveMutex *)mtxHandle;
    rm->unlock();
}

// -----------------------------------------------------------------------
//  Miscellaneous synchronization methods
// -----------------------------------------------------------------------
//atomic system calls in Solaris is only restricted to kernel libraries 
//So, to make operations thread safe we implement static mutex and lock 
//the atomic operations. It makes the process slow but what's the alternative!
void* XMLPlatformUtils::compareAndSwap ( void**      toFill , 
                    const void* const newValue , 
                    const void* const toCompare)
{
    //return ((void*)cas32( (uint32_t*)toFill,  (uint32_t)toCompare, (uint32_t)newValue) );
    // the below calls are temporarily made till the above functions are part of user library
    // Currently its supported only in the kernel mode

    if (pthread_mutex_lock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);

    void *retVal = *toFill;
    if (*toFill == toCompare)
              *toFill = (void *)newValue;

    if (pthread_mutex_unlock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);

    return retVal;
}

int XMLPlatformUtils::atomicIncrement(int &location)
{
    //return (int)atomic_add_32_nv( (uint32_t*)&location, 1);

    if (pthread_mutex_lock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);

    int tmp = ++location;

    if (pthread_mutex_unlock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);

    return tmp;
}
int XMLPlatformUtils::atomicDecrement(int &location)
{
    //return (int)atomic_add_32_nv( (uint32_t*)&location, -1);

    if (pthread_mutex_lock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);
	
    int tmp = --location;

    if (pthread_mutex_unlock( gAtomicOpMutex))
        panic(XMLPlatformUtils::Panic_SynchronizationErr);

    return tmp;
}

#else // #if !defined (APP_NO_THREADS)

void XMLPlatformUtils::closeMutex(void* const mtxHandle)
{
}

void XMLPlatformUtils::lockMutex(void* const mtxHandle)
{
}

void* XMLPlatformUtils::makeMutex()
{
        return 0;
}

void XMLPlatformUtils::unlockMutex(void* const mtxHandle)
{
}

void* XMLPlatformUtils::compareAndSwap ( void**      toFill,
                                   const void* const newValue,
                                   const void* const toCompare)
{
    void *retVal = *toFill;
    if (*toFill == toCompare)
       *toFill = (void *)newValue;
    return retVal;
}

int XMLPlatformUtils::atomicIncrement(int &location)
{
    return ++location;
}

int XMLPlatformUtils::atomicDecrement(int &location)
{
    return --location;
}

#endif // APP_NO_THREADS


/*
 * convert the errno value to a cpf message identifier by converting the
 * error to its decimal equivalent and appending "CPE" to the front
 * note that the caller passes the storage for the message id as a parm
 */
void convert_errno(char* errno_id,int errnum)
	      {
sprintf(errno_id,"CPE%d04" ,errnum );
return;
	      }

FileHandle XMLPlatformUtils::openStdInHandle()
{
    return (FileHandle)fdopen(dup(0), "rb");
}

void XMLPlatformUtils::platformTerm()
{
    // We don't have any termination requirements at this time
}

