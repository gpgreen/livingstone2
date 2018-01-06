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
 * $Log: MemBufInputSource.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:25  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.5  2000/02/24 20:00:22  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.4  2000/02/15 23:59:06  roddey
 * More updated documentation of Framework classes.
 *
 * Revision 1.3  2000/02/15 01:21:30  roddey
 * Some initial documentation improvements. More to come...
 *
 * Revision 1.2  2000/02/06 07:47:46  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1  2000/01/12 00:13:26  roddey
 * These were moved from internal/ to framework/, which was something that should have
 * happened long ago. They are really framework type of classes.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:10  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:43  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


#if !defined(MEMBUFINPUTSOURCE_HPP)
#define MEMBUFINPUTSOURCE_HPP

#include <sax/InputSource.hpp>

class BinInputStream;


/**
 *  This class is a derivative of the standard InputSource class. It provides
 *  for the parser access to data stored in a memory buffer. The type of
 *  buffer and its host specific attributes are of little concern here. The
 *  only real requirement is that the memory be readable by the current
 *  process.
 *
 *  Note that the memory buffer size is expressed in <b>bytes</b>, not in
 *  characters. If you pass it text data, you must account for the bytes
 *  per character when indicating the buffer size.
 *
 *  As with all InputSource derivatives. The primary objective of an input
 *  source is to create an input stream via which the parser can spool in
 *  data from the referenced source. In this case, there are two options
 *  available.
 *
 *  The passed buffer can be adopted or merely referenced. If it is adopted,
 *  then it must be dynamically allocated and will be destroyed when the
 *  input source is destroyed (no reference counting!.) If not adopted, the
 *  caller must insure that it remains valid until the input source object
 *  is destroyed.
 *
 *  The other option indicates whether each stream created for this input
 *  source should get its own copy of the data, or whether it should just
 *  stream the data directly from this object's copy of the data. The same
 *  rules apply here, in that the buffer must either be copied by the
 *  stream or it must remain valid until the stream is destroyed.
 */
class XMLPARSER_EXPORT MemBufInputSource : public InputSource
{
public :
    // -----------------------------------------------------------------------
    //  Constructors and Destructor
    // -----------------------------------------------------------------------

    /** @name Constructors */
    //@{

    /**
      * A memory buffer input source is constructed from a buffer of byte
      * data, and the count of bytes in that buffer. The parser will parse
      * from this memory buffer until it has eaten the indicated number of
      * bytes.
      *
      * Note that the system id provided serves two purposes. Firstly it is
      * going to be displayed in error messages as the source of the error.
      * And secondly, any entities which are refered to from this entity
      * via relative paths/URLs will be relative to this fake system id.
      *
      * @param  srcDocBytes     The actual data buffer to be parsed from.
      * @param  byteCount       The count of bytes (not characters, bytes!)
      *                         in the buffer.
      * @Param  bufId           A fake system id for the buffer.
      * @Param  adoptBuffer     Indicates whether this object should adopt
      *                         the buffer (i.e. make a copy of it) or just
      *                         use it in place.
      */
    MemBufInputSource
    (
        const   XMLByte* const  srcDocBytes
        , const unsigned int    byteCount
        , const XMLCh* const    bufId
        , const bool            adoptBuffer = false
    );

    /**
      * This constructor is identical to the previous one, except that it takes
      * the fake system id in local code page form and transcodes it internally.
      */
    MemBufInputSource
    (
        const   XMLByte* const  srcDocBytes
        , const unsigned int    byteCount
        , const char* const     bufId
        , const bool            adoptBuffer = false
    );
    //@}

    /** @name Destructor */
    //@{
    /**
      * If the buffer was adopted, the copy made during construction is deleted
      * at this point.
      */
    ~MemBufInputSource();
    //@}


    // -----------------------------------------------------------------------
    //  Virtual input source interface
    // -----------------------------------------------------------------------

    /** @name Virtual methods */
    //{@

    /**
      * This method will return a binary input stream derivative that will
      * parse from the memory buffer. If setCopyBufToStream() has been set,
      * then the stream will make its own copy. Otherwise, it will use the
      * buffer as is (in which case it must remain valid until the stream
      * is no longer in use, i.e. the parse completes.)
      *
      * @return A dynamically allocated binary input stream derivative that
      *         can parse from the memory buffer.
      */
    BinInputStream* makeStream() const;

    //@}


    // -----------------------------------------------------------------------
    //  Setter methods
    // -----------------------------------------------------------------------

    /** @name Setter methods */

    //{@

    /**
      * By default, for safety's sake, each newly created stream from this
      * input source will make its own copy of the buffer to stream from. This
      * avoids having to deal with aliasing of the buffer for simple work. But,
      * for higher performance applications or for large buffers, this is
      * obviously not optimal.
      *
      * In such cases, you can call this method to turn off that default
      * action. Once turned off, the streams will just get a pointer to the
      * buffer and parse directly from that. In this case, you must insure that
      * the buffer remains valid for as long as any parse events are still
      * using it.
      *
      * @param  newState    The new boolean flag state to set.
      */
    void setCopyBufToStream(const bool newState);

    //@}


private :
    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fAdopted
    //      Indicates whether the buffer is adopted or not. If so, then it
    //      is destroyed when the input source is destroyed.
    //
    //  fByteCount
    //      The size of the source document.
    //
    //  fCopyBufToStream
    //      This defaults to true (the safe option), which causes it to
    //      give a copy of the buffer to any streams it creates. If you set
    //      it to false, it will allow the streams to just reference the
    //      buffer (in which case this input source must stay alive as long
    //      as the buffer is in use by the stream.)
    //
    //  fSrcBytes
    //      The source memory buffer that is being spooled from. Whether it
    //      belongs to the this input source or not is controlled by the
    //      fAdopted flag.
    // -----------------------------------------------------------------------
    bool            fAdopted;
    unsigned int    fByteCount;
    bool            fCopyBufToStream;
    const XMLByte*  fSrcBytes;
};


inline void MemBufInputSource::setCopyBufToStream(const bool newState)
{
    fCopyBufToStream = newState;
}

#endif
