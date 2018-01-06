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

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <parsers/SAXParser.hpp>
#include <parsers/DOMParser.hpp>
#include <util/PlatformUtils.hpp>
#include <sax/HandlerBase.hpp>
#include <framework/MemBufInputSource.hpp>

#include <dom/DOM.hpp>



//------------------------------------------------------------------------------
//
//   Windows specific code for starting threads
//
//------------------------------------------------------------------------------
#ifdef PLATFORM_WIN32

#include "Windows.h"
#include "process.h"



typedef void (*ThreadFunc)(void *);

class ThreadFuncs           // This class isolates OS dependent threading
{                           //   functions from the rest of ThreadTest program.
public:
    static void Sleep(int millis) {::Sleep(millis);};
    static void startThread(ThreadFunc, void *param);
};

void ThreadFuncs::startThread(ThreadFunc func, void *param)
{
    unsigned long x;
    x = _beginthread(func, 0x10000, param);
    if (x == -1)
    {
        fprintf(stderr, "Error starting thread.  Errno = %d\n", errno);
        exit(-1);
    }
}


#elif defined (AIX) || defined(SOLARIS) || defined(LINUX) || defined(HPUX)
#include <pthread.h>
#include <unistd.h>
#include <errno.h>


//------------------------------------------------------------------------------
//
//   UNIX specific code for starting threads
//
//------------------------------------------------------------------------------


typedef void (*ThreadFunc)(void *);
typedef void *(*pthreadfunc)(void *);

class ThreadFuncs           // This class isolates OS dependent threading
{                           //   functions from the rest of ThreadTest program.
public:
    static void Sleep(int millis); 
    static void startThread(ThreadFunc, void *param);
};

void ThreadFuncs::Sleep(int millis)
{
   int seconds = millis/1000;
   if (seconds <= 0) seconds = 1;
   ::sleep(seconds);
}


void ThreadFuncs::startThread(ThreadFunc func, void *param)
{
    unsigned long x;

    pthread_t tId;
    //thread_t tId;
#if defined(_HP_UX) && defined(XML_USE_DCE)
    x = pthread_create( &tId, pthread_attr_default,  (pthreadfunc)func,  param);
#else
    pthread_attr_t attr;
    pthread_attr_init(&attr); 
    x = pthread_create( &tId, &attr,  (pthreadfunc)func,  param);
#endif
    //x = thr_create( NULL, NULL,  (pthreadfunc)func,  param, NULL, &tId);
    if (x == -1)
    {
        fprintf(stderr, "Error starting thread.  Errno = %d\n", errno);
        exit(-1);
    }
    
    //pthread_join(tId, NULL);
}    
#else
#error This platform is not supported
#endif



//------------------------------------------------------------------------------
//
//  struct InFileInfo   One of these structs will be set up for each file listed
//                      on the command line.  Once set, the data is unchanging
//                      and can safely be referenced by the test threads without
//                      use of synchronization.
//
//------------------------------------------------------------------------------
struct InFileInfo
{
    char    *fileName;
    char    *fileContent;    // If doing an in-memory parse, this field points
                             //   to an allocated string containing the entire file
                             //   contents.  Otherwise it's 0.
    size_t  fileSize;        // The file length.  Only initialized when doing
                             //   an in-memory test.
    int     checkSum;        // The XML checksum.  Set up by the main thread for
                             //   each file before the worker threads are started.
};

//------------------------------------------------------------------------------
//
//  struct runInfo     Holds the info extracted from the command line.
//                     There is only one of these, and it is static, and
//                     unchanging once the command line has been parsed.
//                     During the test, the threads will access this info without
//                     any synchronization.
//
//------------------------------------------------------------------------------
const int MAXINFILES = 25;
struct RunInfo
{
    bool        quiet;
    bool        verbose;
    int         numThreads;
    bool        validating;
    bool        dom;
    bool        reuseParser;
    bool        inMemory;
    bool        dumpOnErr;
    int         totalTime;
    int         numInputFiles;
    InFileInfo  files[MAXINFILES];
};


//------------------------------------------------------------------------------
//
//  struct threadInfo  Holds information specific to an individual thread.
//                     One of these is set up for each thread in the test.
//                     The main program monitors the threads by looking
//                     at the status stored in these structs.
//
//------------------------------------------------------------------------------
struct ThreadInfo
{
    bool    fHeartBeat;     // Set true by the thread each time it finishes
                            //   parsing a file.
    int     fParses;        // Number of parses completed.
    int     fThreadNum;     // Identifying number for this thread.
    ThreadInfo() {
        fHeartBeat = false;
        fParses = 0;
        fThreadNum = -1;
    }
};


//
//------------------------------------------------------------------------------
//
//  Global Data
//
//------------------------------------------------------------------------------
RunInfo         gRunInfo;
ThreadInfo      *gThreadInfo;



//------------------------------------------------------------------------------
//
//  class ThreadParser   Bundles together a SAX parser and the SAX handlers
//                       and contains the API that the rest of this test
//                       program uses for creating parsers and doing parsing.
//
//                       Multiple instances of this class can operate concurrently
//                       in different threads.
//
//-------------------------------------------------------------------------------
class ThreadParser: public HandlerBase
{
private:
    int           fCheckSum;
    SAXParser*    fSAXParser;
    DOMParser*    fDOMParser;


public:                               //  This is the API used by the rest of the test program
    ThreadParser();
    ~ThreadParser();

    int parse(int fileNum);           // Parse the specified file.  fileNum is an index
                                      //   into the gRunInfo.files array.
                                      //  return the XML checksum, or
                                      //  0 if a parse error occured.

    int reCheck();                    // Try to compute the checksum again.
                                      //  for DOM, re-walk the tree.
                                      //  for SAX, can't do, just return previous value.

    void domPrint(const DOM_Node &node); // Dump out the contents of a node,
    void domPrint();                   //   including any children.  Default (no param)
                                       //   version dumps the entire document.

private:
    ThreadParser(const ThreadParser &); // No copy constructor
    const ThreadParser & operator =(const ThreadParser &); // No assignment.

    void  addToCheckSum(const XMLCh *chars, int len=-1);
    void  domCheckSum(const DOM_Node &);


public:                               // Not really public,
                                      //  These are the SAX call-back functions
                                      //  that this class implements.
    void startElement(const XMLCh* const name, AttributeList& attributes);
    void characters(const XMLCh* const chars, const unsigned int length) {
        addToCheckSum(chars, length);};
    void ignorableWhitespace(const XMLCh* const chars, const unsigned int length) {
        addToCheckSum(chars, length);};
    void resetDocument() {};

    void warning(const SAXParseException& exception)     {
        fprintf(stderr, "*** Warning ");
        throw;};

    void error(const SAXParseException& exception)       {
        fprintf(stderr, "*** Error ");
        throw;};

    void fatalError(const SAXParseException& exception)  {
        fprintf(stderr, "***** Fatal error ");
        throw;};
};



//
//  ThreadParser constructor.  Invoked by the threads of the test program
//                              to create parsers.
//
ThreadParser::ThreadParser()
{
    fSAXParser = 0;
    fDOMParser = 0;
    if (gRunInfo.dom) {
        // Set up to use a DOM parser
        fDOMParser = new DOMParser;
        fDOMParser->setDoValidation(gRunInfo.validating);
        fDOMParser->setErrorHandler(this);
    }
    else
    {
        // Set up to use a SAX parser.
        fSAXParser = new SAXParser;
        fSAXParser->setDoValidation(gRunInfo.validating);
        fSAXParser->setDocumentHandler(this);
        fSAXParser->setErrorHandler(this);
    }
    
}



ThreadParser::~ThreadParser()
{
     delete fSAXParser; 
     delete fDOMParser;
}

//------------------------------------------------------------------------
//
//  parse   - This is the method that is invoked by the rest of
//            the test program to actually parse an XML file.
//
//------------------------------------------------------------------------
int ThreadParser::parse(int fileNum)
{
    MemBufInputSource *mbis = 0;
    InFileInfo        *fInfo = &gRunInfo.files[fileNum];

    fCheckSum = 0;

    if (gRunInfo.inMemory) {
        mbis = new  MemBufInputSource((const XMLByte *) fInfo->fileContent,
                                       fInfo->fileSize,
                                       fInfo->fileName,
                                       false);
    }
        
    try
    {
        if (gRunInfo.dom) {
            // Do a DOM parse
            if (gRunInfo.inMemory) 
                fDOMParser->parse(*mbis);
            else
                fDOMParser->parse(fInfo->fileName);
            DOM_Document doc = fDOMParser->getDocument();
            domCheckSum(doc);
        }
        else
        {
            // Do a SAX parse 
            if (gRunInfo.inMemory) 
                fSAXParser->parse(*mbis);
            else
                fSAXParser->parse(fInfo->fileName);
        }
    }
    
    catch (const XMLException& e)
    {
        char *exceptionMessage = XMLString::transcode(e.getMessage());
        fprintf(stderr, " during parsing: %s \n Exception message is: %s \n",
            fInfo->fileName, exceptionMessage);
        delete exceptionMessage;
    }
    
    delete mbis;
    return fCheckSum;
}


//
//  addToCheckSum - private function, used within ThreadParser in
//                  computing the checksum of the XML file.
//
//                  Unichar Strings to be added to the checksum
//                  can either be null terminated (omit len param, which
//                  will then default to -1), or provide an explicit
//                  length.
//
void ThreadParser::addToCheckSum(const XMLCh *chars, int len)
{
    if (len = -1)
    {
        // Null terminated string.
        while (*chars != 0)
        {
            fCheckSum = fCheckSum*5 + *chars;
            chars++;
        }
    }
    else
    {
        // String with character count.
        int i;
        for (i=0; i<len; i++)
            fCheckSum = fCheckSum*5 + chars[i];
    }
}


//
// startElement - our SAX handler callback function for element starts.
//                update the document checksum with the element name
//                and any attribute names and values.
//
void ThreadParser::startElement(const XMLCh *const name, AttributeList &attributes)
{
    addToCheckSum(name);

    int n = attributes.getLength();
    int i;
    for (i=0; i<n; i++)
    {
        const XMLCh *attNam = attributes.getName(i);
        addToCheckSum(attNam);
        const XMLCh *attVal = attributes.getValue(i);
        addToCheckSum(attVal);
    }
}


//
// domCheckSum  -  Compute the check sum for a DOM node.
//                 Works recursively - initially called with a document node.
//
void ThreadParser::domCheckSum(const DOM_Node &node)
{
    DOMString         s;
    DOM_Node          child;
    DOM_NamedNodeMap  attributes;

    switch (node.getNodeType() ) 
    {
    case DOM_Node::ELEMENT_NODE: 
        {
            s = node.getNodeName();   // the element name

            attributes = node.getAttributes();  // Element's attributes
            int numAttributes = attributes.getLength();
            int i;
            for (i=0; i<numAttributes; i++)
                domCheckSum(attributes.item(i));

            addToCheckSum(s.rawBuffer(), s.length());  // Content and Children
            for (child=node.getFirstChild(); child!=0; child=child.getNextSibling())
                domCheckSum(child);

            break;
        }


    case DOM_Node::ATTRIBUTE_NODE:
        {
            s = node.getNodeName();  // The attribute name
            addToCheckSum(s.rawBuffer(), s.length());
            s = node.getNodeValue();  // The attribute value
            if (s != 0)
                addToCheckSum(s.rawBuffer(), s.length());
            break;
        }


    case DOM_Node::TEXT_NODE:
    case DOM_Node::CDATA_SECTION_NODE:
        {
            s = node.getNodeValue();
            addToCheckSum(s.rawBuffer(), s.length());
            break;
        }

    case DOM_Node::ENTITY_REFERENCE_NODE:
    case DOM_Node::DOCUMENT_NODE:
        {
            // For entity references and the document, nothing is dirctly
            //  added to the checksum, but we do want to process the chidren nodes.
            //
            for (child=node.getFirstChild(); child!=0; child=child.getNextSibling())
                domCheckSum(child);
            break;
        }
    }
}
 

//
// Recompute the checksum.  Meaningful only for DOM, will tell us whether
//  a failure is transient, or whether the DOM data is permanently corrupted.
//
int ThreadParser::reCheck()
{
    if (gRunInfo.dom) {
        fCheckSum = 0;
        DOM_Document doc = fDOMParser->getDocument();
        domCheckSum(doc);
    }
    return fCheckSum;
}

//
// domPrint  -  Dump the contents of a DOM node.
//              For debugging failures, when all else fails.
//                 Works recursively - initially called with a document node.
//
void ThreadParser::domPrint()
{
    DOMString("Begin DOMPrint ...\n").print();
    if (gRunInfo.dom)
        domPrint(fDOMParser->getDocument());
    DOMString("End DOMPrint\n").print();
}

void ThreadParser::domPrint(const DOM_Node &node)
{

    DOMString         s;
    DOM_Node          child;
    DOM_NamedNodeMap  attributes;

    switch (node.getNodeType() ) 
    {
    case DOM_Node::ELEMENT_NODE: 
        {
            DOMString("<").print();
            node.getNodeName().print();   // the element name

            attributes = node.getAttributes();  // Element's attributes
            int numAttributes = attributes.getLength();
            int i;
            for (i=0; i<numAttributes; i++) {
                domPrint(attributes.item(i));
            }
            DOMString(">").print();

            for (child=node.getFirstChild(); child!=0; child=child.getNextSibling())
                domPrint(child);
            
            DOMString("</").print();
            node.getNodeName().print();
            DOMString(">").print();
            break;
        }


    case DOM_Node::ATTRIBUTE_NODE:
        {
            DOMString(" ").print();
            node.getNodeName().print();   // The attribute name
            DOMString("= \"").print();
            node.getNodeValue().print();  // The attribute value
            DOMString("\"").print();
            break;
        }


    case DOM_Node::TEXT_NODE:
    case DOM_Node::CDATA_SECTION_NODE:
        {
            node.getNodeValue().print();
            break;
        }

    case DOM_Node::ENTITY_REFERENCE_NODE:
    case DOM_Node::DOCUMENT_NODE:
        {
            // For entity references and the document, nothing is dirctly
            //  printed, but we do want to process the chidren nodes.
            //
            for (child=node.getFirstChild(); child!=0; child=child.getNextSibling())
                domPrint(child);
            break;
        }
    }
}
 



//----------------------------------------------------------------------
//
//   parseCommandLine   Read through the command line, and save all
//                      of the options in the gRunInfo struct.
//
//                      Display the usage message if the command line
//                      is no good.
//
//                      Probably ought to be a member function of RunInfo.
//
//----------------------------------------------------------------------

void parseCommandLine(int argc, char **argv)
{
    gRunInfo.quiet = false;               // Set up defaults for run.
    gRunInfo.verbose = false;
    gRunInfo.numThreads = 2;
    gRunInfo.validating = false;
    gRunInfo.dom = false;
    gRunInfo.reuseParser = false;
    gRunInfo.inMemory = false;
    gRunInfo.dumpOnErr = false;
    gRunInfo.totalTime = 0;
    gRunInfo.numInputFiles = 0;
    
    try             // Use exceptions for command line syntax errors.
    {
        int argnum = 1;
        while (argnum < argc)
        {
            if (strcmp(argv[argnum], "-quiet") == 0)
                gRunInfo.quiet = true;
            else if (strcmp(argv[argnum], "-verbose") == 0)
                gRunInfo.verbose = true;
            else if (strcmp(argv[argnum], "-v") == 0)
                gRunInfo.validating = true;
            else if (strcmp(argv[argnum], "-dom") == 0)
                gRunInfo.dom = true;
            else if (strcmp(argv[argnum], "-reuse") == 0)
                gRunInfo.reuseParser = true;
            else if (strcmp(argv[argnum], "-dump") == 0)
                gRunInfo.dumpOnErr = true;
            else if (strcmp(argv[argnum], "-mem") == 0) 
                gRunInfo.inMemory = true;
            else if (strcmp(argv[argnum], "-threads") == 0)
            {
                ++argnum;
                if (argnum >= argc)
                    throw 1;
                gRunInfo.numThreads = atoi(argv[argnum]);
                if (gRunInfo.numThreads < 0)
                    throw 1;
            }
            else if (strcmp(argv[argnum], "-time") == 0)
            {
                ++argnum;
                if (argnum >= argc)
                    throw 1;
                gRunInfo.totalTime = atoi(argv[argnum]);
                if (gRunInfo.numThreads < 1)
                    throw 1;
            }
            else  if (argv[argnum][0] == '-')
            {
                fprintf(stderr, "Unrecognized command line option.  Scanning \"%s\"\n",
                    argv[argnum]);
                throw 1;
            }
            else
            {
                gRunInfo.numInputFiles++;
                if (gRunInfo.numInputFiles >= MAXINFILES)
                {
                    fprintf(stderr, "Too many input files.  Limit is %d\n", MAXINFILES);
                    throw 1;
                }
                gRunInfo.files[gRunInfo.numInputFiles-1].fileName = argv[argnum];
            }
            argnum++; 
        }
        
        // We've made it through the command line.
        //  Verify that at least one input file to be parsed was specified.
        if (gRunInfo.numInputFiles == 0)
        {
            fprintf(stderr, "No input XML file specified on command line.\n");
            throw 1;
        };
        
        
    }
    catch (int)
    {
        fprintf(stderr, "usage:  threadtest [-v] [-threads nnn] [-time nnn] [-quiet] [-verbose] xmlfile...\n"
            "     -v             Use validating parser.  Non-validating is default. \n"
            "     -dom           Use a DOM parser.  Default is SAX. \n"
            "     -quiet         Suppress periodic status display. \n"
            "     -verbose       Display extra messages. \n"
            "     -reuse         Retain and reuse parser.  Default creates new for each parse.\n"
            "     -threads nnn   Number of threads.  Default is 2. \n"
            "     -time nnn      Total time to run, in seconds.  Default is forever.\n"
            "     -dump          Dump DOM tree on error.\n"
            "     -mem           Read files into memory once only, and parse them from there.\n"
            );
        exit(1);
    }
}


//---------------------------------------------------------------------------
//
//   ReadFilesIntoMemory   For use when parsing from memory rather than
//                          reading the files each time, here is the code that
//                          reads the files into local memory buffers.
//
//                          This function is only called once, from the main
//                          thread, before all of the worker threads are started.
//
//---------------------------------------------------------------------------
void ReadFilesIntoMemory()
{
    int     fileNum;
    FILE    *fileF;
    size_t  t;
    
    if (gRunInfo.inMemory)
    {
        for (fileNum = 0; fileNum <gRunInfo.numInputFiles; fileNum++)
        {
            InFileInfo *fInfo = &gRunInfo.files[fileNum];
            fileF = fopen( fInfo->fileName, "rb" );
            if (fileF == 0) {
                fprintf(stderr, "Can not open file \"%s\".\n", fInfo->fileName);
                exit(-1);
            }
            fseek(fileF, 0, SEEK_END);
            fInfo->fileSize = ftell(fileF);
            fseek(fileF, 0, SEEK_SET);
            fInfo->fileContent = new char[fInfo->fileSize + 1];
            t = fread(fInfo->fileContent, 1, fInfo->fileSize, fileF);
            if (t != fInfo->fileSize) {
                fprintf(stderr, "Error reading file \"%s\".\n", fInfo->fileName);
                exit(-1);
            }
            fclose(fileF);
            fInfo->fileContent[fInfo->fileSize] = 0;
        }
    }
}



//----------------------------------------------------------------------
//
//  threadMain   The main function for each of the swarm of test threads.
//               Run in an infinite loop, parsing each of the documents
//               given on the command line in turn.
//
//               There is no return from this fuction, and no graceful
//               thread termination.  Threads are stuck running here
//               until the OS shuts them down as a consequence of the
//               main thread of the process (which never calls this
//               function) exiting.
//
//----------------------------------------------------------------------

void threadMain (void *param)
{
    ThreadInfo   *thInfo = (ThreadInfo *)param;
    ThreadParser *thParser = 0;

    if (gRunInfo.verbose)
        printf("Thread #%d: starting\n", thInfo->fThreadNum);

    int docNum = gRunInfo.numInputFiles;

    //
    // Each time through this loop, one file will be parsed and its checksum
    // computed and compared with the precomputed value for that file.
    //
    while (true)
    {
        
        if (thParser == 0)
            thParser = new ThreadParser;
        
        docNum++;
        
        if (docNum >= gRunInfo.numInputFiles)
            docNum = 0;
        
        InFileInfo *fInfo = &gRunInfo.files[docNum];
        
        if (gRunInfo.verbose )
            printf("Thread #%d: starting file %s\n", thInfo->fThreadNum, fInfo->fileName);
        
        
        int checkSum = 0;
        checkSum = thParser->parse(docNum);
        
        if (checkSum != gRunInfo.files[docNum].checkSum)
        {
            fprintf(stderr, "\nThread %d: Parse Check sum error on file  \"%s\".  Expected %x,  got %x\n",
                thInfo->fThreadNum, fInfo->fileName, fInfo->checkSum, checkSum);
            
            // Revisit - let the loop continue to run?
            int secondTryCheckSum = thParser->reCheck();
            fprintf(stderr, "   Retry checksum is %x\n", secondTryCheckSum);
            if (gRunInfo.dumpOnErr)
                thParser->domPrint();
            fflush(stdout);
            exit(-1);
        }
        
        if (gRunInfo.reuseParser == false)
        {
            delete thParser;
            thParser = 0;
        }
        
        
        thInfo->fHeartBeat = true;
    }
}




//----------------------------------------------------------------------
//
//   main
//
//----------------------------------------------------------------------

int main (int argc, char **argv)
{   
    

    parseCommandLine(argc, argv);

    //
    // Initialize the XML system.
    //
    try
    {
         XMLPlatformUtils::Initialize();
    }
    catch (...)
    {
        fprintf(stderr, "Exception from XMLPlatfromUtils::Initialize.\n");
        return 1;
    }


    //
    // If we will be parsing from memory, read each of the input files
    //  into memory now.
    //
    ReadFilesIntoMemory();


    //
    // While we are still single threaded, parse each of the documents
    //  once, to check for errors, and to note the checksum.
    // Blow off the rest of the test if there are errors.
    //
    ThreadParser *mainParser = new ThreadParser;
    int     n;
    bool    errors = false;
    int     cksum;


    for (n = 0; n < gRunInfo.numInputFiles; n++)
    {
        char *fileName = gRunInfo.files[n].fileName;
        if (gRunInfo.verbose)
            printf("%s checksum is ", fileName);

        cksum = mainParser->parse(n);

        if (cksum == 0)
        {
            fprintf(stderr, "An error occured while initially parsing %s\n",
                fileName);
            errors = true;
        };

        gRunInfo.files[n].checkSum = cksum;
        if (gRunInfo.verbose )
            printf("%x\n", cksum);
        if (gRunInfo.dumpOnErr && errors)
            mainParser->domPrint();

    }
    if (errors)
        exit(1);

    //
    //  Fire off the requested number of parallel threads
    //

    if (gRunInfo.numThreads == 0)
        exit(0);
    
    gThreadInfo = new ThreadInfo[gRunInfo.numThreads];
    
    int threadNum;
    for (threadNum=0; threadNum < gRunInfo.numThreads; threadNum++)
    {
        gThreadInfo[threadNum].fThreadNum = threadNum;
        ThreadFuncs::startThread(threadMain, &gThreadInfo[threadNum]);
    }

    //
    //  Loop, watching the heartbeat of the worker threads.
    //    Each second, display "+" when all threads have completed a parse
    //                 display "." if some thread hasn't since previous "+"
    //
    
    unsigned long startTime = XMLPlatformUtils::getCurrentMillis();
    int elapsedSeconds = 0;
    while (gRunInfo.totalTime == 0 || gRunInfo.totalTime > elapsedSeconds)
    {
        ThreadFuncs::Sleep(1000);
        if (gRunInfo.quiet == false && gRunInfo.verbose == false)
        {
            char c = '+';
            int threadNum;
            for (threadNum=0; threadNum < gRunInfo.numThreads; threadNum++)
            {
                if (gThreadInfo[threadNum].fHeartBeat == false)
                {
                    c = '.';
                    break;
                };
            }
            fputc(c, stdout);
            fflush(stdout);
            if (c == '+')
                for (threadNum=0; threadNum < gRunInfo.numThreads; threadNum++)
                    gThreadInfo[threadNum].fHeartBeat = false;
        }
        elapsedSeconds = (XMLPlatformUtils::getCurrentMillis() - startTime) / 1000;
    };
    
    //
    //  Time's up, we are done.  The threads are still running; we just return
    //   and leave it to the operating sytem to kill them.
    //
    return 0;
}


