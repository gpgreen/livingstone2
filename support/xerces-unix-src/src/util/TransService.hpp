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
 * $Log: TransService.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:37  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.11  2000/04/12 22:57:45  roddey
 * A couple of fixes to comments and parameter names to make them
 * more correct.
 *
 * Revision 1.10  2000/03/28 19:43:19  roddey
 * Fixes for signed/unsigned warnings. New work for two way transcoding
 * stuff.
 *
 * Revision 1.9  2000/03/17 23:59:54  roddey
 * Initial updates for two way transcoding support
 *
 * Revision 1.8  2000/03/02 19:54:46  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.7  2000/02/24 20:05:25  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.6  2000/02/06 07:48:04  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.5  2000/01/25 22:49:55  roddey
 * Moved the supportsSrcOfs() method from the individual transcoder to the
 * transcoding service, where it should have been to begin with.
 *
 * Revision 1.4  2000/01/25 19:19:07  roddey
 * Simple addition of a getId() method to the xcode and netacess abstractions to
 * allow each impl to give back an id string.
 *
 * Revision 1.3  1999/12/18 00:18:10  roddey
 * More changes to support the new, completely orthagonal support for
 * intrinsic encodings.
 *
 * Revision 1.2  1999/12/15 19:41:28  roddey
 * Support for the new transcoder system, where even intrinsic encodings are
 * done via the same transcoder abstraction as external ones.
 *
 * Revision 1.1.1.1  1999/11/09 01:05:16  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:16  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#ifndef TRANSSERVICE_HPP
#define TRANSSERVICE_HPP

#include <util/XercesDefs.hpp>


// Forward references
class XMLPlatformUtils;
class XMLLCPTranscoder;
class XMLTranscoder;


//
//  This class is an abstract base class which are used to abstract the
//  transcoding services that Xerces uses. The parser's actual transcoding
//  needs are small so it is desirable to allow different implementations
//  to be provided.
//
//  The transcoding service has to provide a couple of required string
//  and character operations, but its most important service is the creation
//  of transcoder objects. There are two types of transcoders, which are
//  discussed below in the XMLTranscoder class' description.
//
class XMLUTIL_EXPORT XMLTransService
{
public :
    // -----------------------------------------------------------------------
    //  Class specific types
    // -----------------------------------------------------------------------
    enum Codes
    {
        Ok
        , UnsupportedEncoding
        , InternalFailure
        , SupportFilesNotFound
    };

    struct TransRec
    {
        XMLCh       intCh;
        XMLByte     extCh;
    };


    // -----------------------------------------------------------------------
    //  Public constructors and destructor
    // -----------------------------------------------------------------------
    virtual ~XMLTransService();


    // -----------------------------------------------------------------------
    //  Non-virtual API
    // -----------------------------------------------------------------------
    XMLTranscoder* makeNewTranscoderFor
    (
        const   XMLCh* const            encodingName
        ,       XMLTransService::Codes& resValue
        , const unsigned int            blockSize
    );

    XMLTranscoder* makeNewTranscoderFor
    (
        const   char* const             encodingName
        ,       XMLTransService::Codes& resValue
        , const unsigned int            blockSize
    );


    // -----------------------------------------------------------------------
    //  The virtual transcoding service API
    // -----------------------------------------------------------------------
    virtual int compareIString
    (
        const   XMLCh* const    comp1
        , const XMLCh* const    comp2
    ) = 0;

    virtual int compareNIString
    (
        const   XMLCh* const    comp1
        , const XMLCh* const    comp2
        , const unsigned int    maxChars
    ) = 0;

    virtual const XMLCh* getId() const = 0;

    virtual bool isSpace(const XMLCh toCheck) const = 0;

    virtual XMLLCPTranscoder* makeNewLCPTranscoder() = 0;

    virtual bool supportsSrcOfs() const = 0;

    virtual void upperCase(XMLCh* const toUpperCase) const = 0;


protected :
    // -----------------------------------------------------------------------
    //  Hidden constructors
    // -----------------------------------------------------------------------
    XMLTransService();


    // -----------------------------------------------------------------------
    //  Protected virtual methods.
    // -----------------------------------------------------------------------
    virtual XMLTranscoder* makeNewXMLTranscoder
    (
        const   XMLCh* const            encodingName
        ,       XMLTransService::Codes& resValue
        , const unsigned int            blockSize
    ) = 0;


private :
    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLTransService(const XMLTransService&);
    void operator=(const XMLTransService&);


    // -----------------------------------------------------------------------
    //  Hidden init method for platform utils to call
    // -----------------------------------------------------------------------
    friend class XMLPlatformUtils;
    void initTransService();
};



//
//  This type of transcoder is for non-local code page encodings, i.e.
//  named encodings. These are used internally by the scanner to internalize
//  raw XML into the internal Unicode format, and by writer classes to
//  convert that internal Unicode format (which comes out of the parser)
//  back out to a format that the receiving client code wants to use.
//
class XMLUTIL_EXPORT XMLTranscoder
{
public :
    // -----------------------------------------------------------------------
    //  This enum is used by the transcodeTo() method to indicate how to
    //  react to unrepresentable characters. The transcodeFrom() method always
    //  works the same. It will consider any invalid data to be an error and
    //  throw.
    //
    //  The options mean:
    //      Throw   - Throw an exception
    //      RepChar - Use the replacement char
    // -----------------------------------------------------------------------
    enum UnRepOpts
    {
        UnRep_Throw
        , UnRep_RepChar
    };


    // -----------------------------------------------------------------------
    //  Public constructors and destructor
    // -----------------------------------------------------------------------
    virtual ~XMLTranscoder();


    // -----------------------------------------------------------------------
    //  The virtual transcoding interface
    // -----------------------------------------------------------------------
    virtual unsigned int transcodeFrom
    (
        const   XMLByte* const          srcData
        , const unsigned int            srcCount
        ,       XMLCh* const            toFill
        , const unsigned int            maxChars
        ,       unsigned int&           bytesEaten
        ,       unsigned char* const    charSizes
    ) = 0;

    virtual unsigned int transcodeTo
    (
        const   XMLCh* const    srcData
        , const unsigned int    srcCount
        ,       XMLByte* const  toFill
        , const unsigned int    maxBytes
        ,       unsigned int&   charsEaten
        , const UnRepOpts       options
    ) = 0;

    virtual bool canTranscodeTo
    (
        const   unsigned int    toCheck
    )   const = 0;


    // -----------------------------------------------------------------------
    //  Getter methods
    // -----------------------------------------------------------------------
    unsigned int getBlockSize() const;

    const XMLCh* getEncodingName() const;


protected :
    // -----------------------------------------------------------------------
    //  Hidden constructors
    // -----------------------------------------------------------------------
    XMLTranscoder
    (
        const   XMLCh* const    encodingName
        , const unsigned int    blockSize
    );


    // -----------------------------------------------------------------------
    //  Protected helper methods
    // -----------------------------------------------------------------------
    void checkBlockSize(const unsigned int toCheck);


private :
    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLTranscoder(const XMLTranscoder&);
    void operator=(const XMLTranscoder&);


    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fBlockSize
    //      This is the block size indicated in the constructor. This lets
    //      the derived class preallocate appopriately sized buffers. This
    //      sets the maximum number of characters which can be internalized
    //      per call to transcodeFrom() and transcodeTo().
    //
    //  fEncodingName
    //      This is the name of the encoding this encoder is for. All basic
    //      XML transcoder's are for named encodings.
    // -----------------------------------------------------------------------
    unsigned int    fBlockSize;
    XMLCh*          fEncodingName;
};


//
//  This class is a specialized transcoder that only transcodes between
//  the internal XMLCh format and the local code page. It is specialized
//  for the very common job of translating data from the client app's
//  native code page to the internal format and vice versa.
//
class XMLUTIL_EXPORT XMLLCPTranscoder
{
public :
    // -----------------------------------------------------------------------
    //  Public constructors and destructor
    // -----------------------------------------------------------------------
    virtual ~XMLLCPTranscoder();


    // -----------------------------------------------------------------------
    //  The virtual transcoder API
    //
    //  NOTE:   All these APIs don't include null terminator characters in
    //          their parameters. So calcRequiredSize() returns the number
    //          of actual chars, not including the null. maxBytes and maxChars
    //          parameters refer to actual chars, not including the null so
    //          its assumed that the buffer is physically one char or byte
    //          larger.
    // -----------------------------------------------------------------------
    virtual unsigned int calcRequiredSize(const char* const srcText) = 0;

    virtual unsigned int calcRequiredSize(const XMLCh* const srcText) = 0;

    virtual char* transcode(const XMLCh* const toTranscode) = 0;

    virtual XMLCh* transcode(const char* const toTranscode) = 0;

    virtual bool transcode
    (
        const   char* const     toTranscode
        ,       XMLCh* const    toFill
        , const unsigned int    maxChars
    ) = 0;

    virtual bool transcode
    (
        const   XMLCh* const    toTranscode
        ,       char* const     toFill
        , const unsigned int    maxBytes
    ) = 0;


protected :
    // -----------------------------------------------------------------------
    //  Hidden constructors
    // -----------------------------------------------------------------------
    XMLLCPTranscoder();


private :
    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLLCPTranscoder(const XMLLCPTranscoder&);
    void operator=(const XMLLCPTranscoder&);
};


// ---------------------------------------------------------------------------
//  XMLTranscoder: Protected helper methods
// ---------------------------------------------------------------------------
inline unsigned int XMLTranscoder::getBlockSize() const
{
    return fBlockSize;
}

inline const XMLCh* XMLTranscoder::getEncodingName() const
{
    return fEncodingName;
}

#endif
