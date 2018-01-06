#ifndef DOMStringImpl_HEADER_GUARD_
#define DOMStringImpl_HEADER_GUARD_

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

/*
 * $Log: DOMStringImpl.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:43  kurien
 * XML parser for C++
 *
 *
 * Revision 1.6  2000/02/24 20:11:27  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.5  2000/02/06 07:47:27  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.4  2000/02/04 05:46:31  andyh
 * Change offsets and lengths form signed to unsigned
 *
 * Revision 1.3  2000/01/29 00:39:08  andyh
 * Redo synchronization in DOMStringHandle allocator.  There
 * was a bug in the use of Compare and Swap.  Switched to mutexes.
 *
 * Changed a few plain deletes to delete [].
 *
 * Revision 1.2  2000/01/12 19:55:14  aruna1
 * Included header for size_t
 *
 * Revision 1.1  2000/01/05 22:16:26  robweir
 * Move DOMString implementation class declarations into a new
 * file: DOMStringImpl.hpp.  Include this header in DOMString.hpp
 * for XML_DEBUG builds so the underlying character array will be
 * visible in the debugger.  <robert_weir@lotus.com>
 *
 *
 */


//
//  This file is part of the internal implementation of the C++ XML DOM.
//  It should NOT be included or used directly by application programs.
//


#include <util/XML4CDefs.hpp>
#include <util/Mutexes.hpp>
#include <stdio.h>


class   DOMStringData
{
public:
    unsigned int        fBufferLength;
    int                 fRefCount;
    XMLCh               fData[1];
    
    static DOMStringData *allocateBuffer(unsigned int length);
    inline void         addRef();
    inline void         removeRef();
};

class  DOMStringHandle
{
public:
            unsigned int     fLength;
            int              fRefCount;
            DOMStringData    *fDSData;

    void    *operator new( size_t sizeToAlloc);
    void    operator delete( void *pvMem );
private:
    static  void *freeListPtr;
public:
    static  DOMStringHandle  *createNewStringHandle(unsigned int bufLength);
            DOMStringHandle  *cloneStringHandle();
    inline  void             addRef();
    inline  void             removeRef();
                             ~DOMStringHandle() {};
private:
    inline                   DOMStringHandle() {};
    static inline  XMLMutex &getMutex();
};


#endif
    
