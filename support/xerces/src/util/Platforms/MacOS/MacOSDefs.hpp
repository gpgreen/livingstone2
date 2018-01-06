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
 * $Log: MacOSDefs.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:38:19  kurien
 * XML parser for C++
 *
 *
 * Revision 1.2  2000/02/06 07:48:28  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:06:51  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:30  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
// NOTE:
//
//    XML4C is not officially supported on Macintosh. This file was sent
//    in by one of the Macintosh users and is included in the distribution
//    just for convenience. Please send any defects / modification
//    reports to xml4c@us.ibm.com
// ---------------------------------------------------------------------------


#ifndef MACOS_DEFS_HPP
#define MACOS_DEFS_HPP

#include <resources.h>

class XMLMacAbstractFile
{
    public:
        XMLMacAbstractFile() {}
        virtual ~XMLMacAbstractFile() {}
        
        virtual unsigned int currPos() = 0;
        virtual void close() = 0;
        virtual unsigned int size() = 0;
        virtual void open(const char* const) = 0;
        virtual unsigned int read(const unsigned int, XMLByte* const) = 0;
        virtual void reset() = 0;
};

class XMLMacFile : public XMLMacAbstractFile
{
    public:
        XMLMacFile() : valid(0), fileRef(0) {}
        virtual ~XMLMacFile();
        
        unsigned int currPos();
        void close();
        unsigned int size();
        void open(const char* const);
        unsigned int read(const unsigned int, XMLByte* const);
        void reset();
        
    protected:
        short fileRef;
        short valid;
        unsigned char pStr[300];
};

class XMLResFile : public XMLMacAbstractFile
{
    public:
        XMLResFile() : valid(0), type(0), id(0), pos(0), len(0) {}
        virtual ~XMLResFile();
        
        unsigned int currPos();
        void close();
        unsigned int size();
        void open(const char* const);
        unsigned int read(const unsigned int, XMLByte* const);
        void reset();
        
    protected:
        short valid;
        unsigned long type;
        short id;
        unsigned char name[300];
        Handle data;
        long pos;
        long len;
};


// ---------------------------------------------------------------------------
//  MacOS runs in big endian mode.
// ---------------------------------------------------------------------------
#define ENDIANMODE_BIG


// ---------------------------------------------------------------------------
//  Define all the required platform types
// ---------------------------------------------------------------------------
typedef XMLMacAbstractFile*   FileHandle;


int stricmp(const char *s1, const char *s2);
int strnicmp(const char *s1, const char *s2, int n);

#endif
