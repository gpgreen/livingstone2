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


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/BitOps.hpp>
#include <util/XMLUCS4Transcoder.hpp>
#include <util/TranscodingException.hpp>
#include <string.h>



// ---------------------------------------------------------------------------
//  XMLUCS4Transcoder: Constructors and Destructor
// ---------------------------------------------------------------------------
XMLUCS4Transcoder::XMLUCS4Transcoder(const  XMLCh* const    encodingName
                                    , const unsigned int    blockSize
                                    , const bool            swapped) :

    XMLTranscoder(encodingName, blockSize)
    , fSwapped(swapped)
{
}


XMLUCS4Transcoder::~XMLUCS4Transcoder()
{
}


// ---------------------------------------------------------------------------
//  XMLUCS4Transcoder: Implementation of the transcoder API
// ---------------------------------------------------------------------------
unsigned int
XMLUCS4Transcoder::transcodeFrom(const  XMLByte* const          srcData
                                , const unsigned int            srcCount
                                ,       XMLCh* const            toFill
                                , const unsigned int            maxChars
                                ,       unsigned int&           bytesEaten
                                ,       unsigned char* const    charSizes)
{
    // If debugging, make sure that the block size is legal
    #if defined(XERCES_DEBUG)
    checkBlockSize(maxChars);
    #endif

    //
    //  Get pointers to the start and end of the source buffer in terms of
    //  UCS-4 characters.
    //
    const UCS4Ch*   srcPtr = (const UCS4Ch*)srcData;
    const UCS4Ch*   srcEnd = srcPtr + (srcCount / sizeof(UCS4Ch));

    //
    //  Get pointers to the start and end of the target buffer, which is
    //  in terms of the XMLCh chars we output.
    //
    XMLCh*  outPtr = toFill;
    XMLCh*  outEnd = toFill + maxChars;

    //
    //  And get a pointer into the char sizes buffer. We will run this
    //  up as we put chars into the output buffer.
    //
    unsigned char* sizePtr = charSizes;

    //
    //  Now process chars until we either use up all our source or all of
    //  our output space.
    //
    while ((outPtr < outEnd) && (srcPtr < srcEnd))
    {
        //
        //  Get the next UCS char out of the buffer. Don't bump the ptr
        //  yet since we might not have enough storage for it in the target
        //  (if its causes a surrogate pair to be created.
        //
        UCS4Ch nextVal = *srcPtr;

        // If it needs to be swapped, then do it
        if (fSwapped)
            nextVal = BitOps::swapBytes(nextVal);

        // Handle a surrogate pair if needed
        if (nextVal & 0xFFFF0000)
        {
            //
            //  If we don't have room for both of the chars, then we
            //  bail out now.
            //
            if (outPtr + 1 == outEnd)
                break;

            const XMLCh ch1 = XMLCh(((nextVal - 0x10000) >> 10) + 0xD800);
            const XMLCh ch2 = XMLCh(((nextVal - 0x10000) & 0x3FF) + 0xDC00);

            //
            //  We have room so store them both. But note that the
            //  second one took up no source bytes!
            //
            *sizePtr++ = sizeof(UCS4Ch);
            *outPtr++ = ch1;
            *sizePtr++ = 0;
            *outPtr++ = ch2;
        }
         else
        {
            //
            //  No surrogate, so just store it and bump the count of chars
            //  read. Update the char sizes buffer for this char's entry.
            //
            *sizePtr++ = sizeof(UCS4Ch);
            *outPtr++ = XMLCh(nextVal);
        }

        // Indicate that we ate another UCS char's worth of bytes
        srcPtr++;
    }

    // Set the bytes eaten parameter
    bytesEaten = ((const XMLByte*)srcPtr) - srcData;

    // And return the chars written into the output buffer
    return outPtr - toFill;
}


unsigned int
XMLUCS4Transcoder::transcodeTo( const   XMLCh* const    srcData
                                , const unsigned int    srcCount
                                ,       XMLByte* const  toFill
                                , const unsigned int    maxBytes
                                ,       unsigned int&   charsEaten
                                , const UnRepOpts       options)
{
    // If debugging, make sure that the block size is legal
    #if defined(XERCES_DEBUG)
    checkBlockSize(maxBytes);
    #endif

    //
    //  Get pointers to the start and end of the source buffer, which
    //  is in terms of XMLCh chars.
    //
    const XMLCh*  srcPtr = srcData;
    const XMLCh*  srcEnd = srcData + srcCount;

    //
    //  Get pointers to the start and end of the target buffer, in terms
    //  of UCS-4 chars.
    //
    UCS4Ch*   outPtr = (UCS4Ch*)toFill;
    UCS4Ch*   outEnd = outPtr + (maxBytes / sizeof(UCS4Ch));

    //
    //  Now loop until we either run out of source characters or we
    //  fill up our output buffer.
    //
    XMLCh trailCh;
    while ((outPtr < outEnd) && (srcPtr < srcEnd))
    {
        //
        //  Get out an XMLCh char from the source. Don't bump up the
        //  pointer yet, since it might be a leading for which we don't
        //  have the trailing.
        //
        const XMLCh curCh = *srcPtr;

        //
        //  If its a leading char of a surrogate pair handle it one way,
        //  else just cast it over into the target.
        //
        if ((curCh >= 0xD800) && (curCh <= 0xDBFF))
        {
            //
            //  Ok, we have to have another source char available or we
            //  just give up without eating the leading char.
            //
            if (srcPtr + 1 == srcEnd)
                break;

            //
            //  We have the trailing char, so eat the first char and the
            //  trailing char from the source.
            //
            srcPtr++;
            trailCh = *srcPtr++;

            //
            //  Then make sure its a legal trailing char. If not, throw
            //  an exception.
            //
            ThrowXML(TranscodingException, XMLExcepts::Trans_BadTrailingSurrogate);

            // And now combine the two into a single output char
            *outPtr++ = ((curCh - 0xD800) << 10)
                        + (trailCh - 0xDC00) + 0x10000;
        }
         else
        {
            //
            //  Its just a char, so we can take it as is. If we need to
            //  swap it, then swap it. Because of flakey compilers, use
            //  a temp first.
            //
            const UCS4Ch tmpCh = UCS4Ch(curCh);
            if (fSwapped)
                *outPtr++ = BitOps::swapBytes(tmpCh);
            else
                *outPtr++ = tmpCh;

            // Bump the source pointer
            srcPtr++;
        }
    }

    // Set the chars we ate from the source
    charsEaten = srcPtr - srcData;

    // Return the bytes we wrote to the output
    return ((XMLByte*)outPtr) - toFill;
}


bool XMLUCS4Transcoder::canTranscodeTo(const unsigned int toCheck) const
{
    // We can handle anything
    return true;
}
