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
 * $Log: XMLBufferMgr.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:26  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.5  2000/03/02 19:54:24  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.4  2000/02/24 20:00:23  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.3  2000/02/15 01:21:30  roddey
 * Some initial documentation improvements. More to come...
 *
 * Revision 1.2  2000/02/06 07:47:47  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:30  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:36  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


#if !defined(XMLBUFFERMGR_HPP)
#define XMLBUFFERMGR_HPP

#include <util/XercesDefs.hpp>
#include <framework/XMLBuffer.hpp>

class XMLBufBid;

/**
 *  There are many places where XMLBuffer objects are needed. In order to
 *  avoid either constantly creating and destroying them or maintaining a
 *  fixed set and worrying about accidental reuse, a buffer manager can
 *  provide a pool of buffers which can be temporarily used and then put
 *  back into the pool. This provides a good compromise between performance
 *  and easier maintenance.
 */
class XMLPARSER_EXPORT XMLBufferMgr
{
public :
    // -----------------------------------------------------------------------
    //  Constructors and Destructor
    // -----------------------------------------------------------------------

    /** @name Constructor */
    //@{
    XMLBufferMgr();
    //@}

    /** @name Destructor */
    //@{
    ~XMLBufferMgr();
    //@}


    // -----------------------------------------------------------------------
    //  Buffer management
    // -----------------------------------------------------------------------
    XMLBuffer& bidOnBuffer();
    void releaseBuffer(XMLBuffer& toRelease);


private :
    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fBufCount
    //      The count of buffers that have been allocated so far.
    //
    //  fBufList;
    //      The list of pointers to buffers that are loaned out. There will
    //      never be a lot of them, so a flat list is good enough.
    // -----------------------------------------------------------------------
    unsigned int    fBufCount;
    XMLBuffer**     fBufList;
};


/**
 *  XMLBufBid is a scoped based janitor that allows the scanner code to ask
 *  for a buffer on a scoped basis and then insure that it gets freed back
 *  into the pool no matter how the scope is exited (exception or normal exit.)
 */
class XMLBufBid
{
public :
    // -----------------------------------------------------------------------
    //  Constructors and Destructor
    // -----------------------------------------------------------------------
    XMLBufBid(XMLBufferMgr* const srcMgr) :

        fBuffer(srcMgr->bidOnBuffer())
        , fMgr(srcMgr)
    {
    }

    ~XMLBufBid()
    {
        fMgr->releaseBuffer(fBuffer);
    }



    // -----------------------------------------------------------------------
    //  Buffer access
    // -----------------------------------------------------------------------
    void append(const XMLCh toAppend)
    {
        fBuffer.append(toAppend);
    }

    void append(const XMLCh* const toAppend, const unsigned int count = 0)
    {
        fBuffer.append(toAppend, count);
    }

    const XMLBuffer& getBuffer() const
    {
        return fBuffer;
    }

    XMLBuffer& getBuffer()
    {
        return fBuffer;
    }

    const XMLCh* getRawBuffer() const
    {
        fBuffer.fBuffer[fBuffer.fIndex] = 0;
        return fBuffer.fBuffer;
    }

    XMLCh* getRawBuffer()
    {
        fBuffer.fBuffer[fBuffer.fIndex] = 0;
        return fBuffer.fBuffer;
    }

    unsigned int getLen() const
    {
        return fBuffer.fIndex;
    }

    bool isEmpty()
    {
        return (fBuffer.fIndex == 0);
    }

    void reset()
    {
        fBuffer.reset();
    }

    void set(const XMLCh* const chars, const unsigned int count = 0)
    {
        fBuffer.set(chars, count);
    }


private :
    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fBuffer
    //      This is the buffer we got, and which we will release.
    //
    //  fMgr
    //      This is the buffer manager we got the buffer from. This is needed
    //      to release the buffer later.
    // -----------------------------------------------------------------------
    XMLBuffer&          fBuffer;
    XMLBufferMgr* const fMgr;
};

#endif
