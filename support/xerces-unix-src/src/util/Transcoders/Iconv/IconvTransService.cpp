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
 * $Log: IconvTransService.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:53  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.18  2000/06/09 23:45:02  rahulj
 * More PTX port related changes submitted by
 * Sumit Chawla <sumitc@us.ibm.com>.
 *
 * Revision 1.17  2000/03/28 19:43:24  roddey
 * Fixes for signed/unsigned warnings. New work for two way transcoding
 * stuff.
 *
 * Revision 1.16  2000/03/13 21:48:04  abagchi
 * Changed XML_GNUG to XML_GCC
 *
 * Revision 1.15  2000/03/02 19:55:35  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.14  2000/02/16 18:37:03  aruna1
 * Made changes to upperCase function in Transcoding services
 *
 * Revision 1.13  2000/02/11 03:10:19  rahulj
 * Fixed defect in compare[N]IString function. Defect and fix reported
 * by Bill Schindler from developer@bitranch.com.
 * Replaced tabs with appropriate number of spaces.
 *
 * Revision 1.12  2000/02/06 07:48:33  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.11  2000/01/25 22:49:57  roddey
 * Moved the supportsSrcOfs() method from the individual transcoder to the
 * transcoding service, where it should have been to begin with.
 *
 * Revision 1.10  2000/01/25 20:56:51  abagchi
 * Now at least compiles
 *
 * Revision 1.9  2000/01/25 19:19:08  roddey
 * Simple addition of a getId() method to the xcode and netacess abstractions to
 * allow each impl to give back an id string.
 *
 * Revision 1.8  2000/01/06 01:21:34  aruna1
 * Transcoding services modified.
 *
 * Revision 1.7  2000/01/05 23:30:38  abagchi
 * Fixed the new class IconvLCPTranscoder functions. Tested on Linux only.
 *
 * Revision 1.6  1999/12/18 00:22:32  roddey
 * Changes to support the new, completely orthagonal, transcoder architecture.
 *
 * Revision 1.5  1999/12/14 23:53:35  rahulj
 * Removed the offending Ctrl-M's from the commit message
 * logs which was giving packaging problems.
 *
 * PR:
 * Obtained from:
 * Submitted by:
 * Reviewed by:
 *
 * Revision 1.4  1999/12/02 20:20:16  rahulj
 * Fixed incorrect comparision of int with a pointer.
 * Got burnt because definition of NULL varies on different platforms,
 * though use of NULL was not correct in the first place.
 *
 * Revision 1.3  1999/11/20 00:28:19  rahulj
 * Added code for case-insensitive wide character string compares
 *
 * Revision 1.2  1999/11/17 21:52:49  abagchi
 * Changed wcscasecmp() to wcscmp() to make it work on Solaris and AIX
 * PR:
 * Obtained from:
 * Submitted by:
 * Reviewed by:
 *
 * Revision 1.1.1.1  1999/11/09 01:06:10  twl
 * Initial checkin
 *
 * Revision 1.7  1999/11/08 20:45:34  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/XMLUni.hpp>
#include "IconvTransService.hpp"
#include <wchar.h>
#if defined (XML_GCC) || defined (XML_PTX)
#include <wctype.h>
#endif
#include <string.h>
#include <stdlib.h>
#include <stdio.h>


// ---------------------------------------------------------------------------
//  Local, const data
// ---------------------------------------------------------------------------
static const int    gTempBuffArraySize = 1024;
static const XMLCh  gMyServiceId[] =
{
    chLatin_I, chLatin_C, chLatin_o, chLatin_n, chLatin_v, chNull
};


// ---------------------------------------------------------------------------
//  Local methods
// ---------------------------------------------------------------------------
static unsigned int getWideCharLength(const XMLCh* const src)
{
    if (!src)
        return 0;

    unsigned int len = 0;
    const XMLCh* pTmp = src;
    while (*pTmp++)
        len++;
    return len;
}



// ---------------------------------------------------------------------------
//  IconvTransService: Constructors and Destructor
// ---------------------------------------------------------------------------
IconvTransService::IconvTransService()
{
}

IconvTransService::~IconvTransService()
{
}


// ---------------------------------------------------------------------------
//  IconvTransService: The virtual transcoding service API
// ---------------------------------------------------------------------------
int IconvTransService::compareIString(  const   XMLCh* const    comp1
                                        , const XMLCh* const    comp2)
{
    const XMLCh* cptr1 = comp1;
    const XMLCh* cptr2 = comp2;

    while ( (*cptr1 != 0) && (*cptr2 != 0) )
    {
        wint_t wch1 = towupper(*cptr1);
        wint_t wch2 = towupper(*cptr2);
        if (wch1 != wch2)
            break;
        
        cptr1++;
        cptr2++;
    }
    return (int) ( towupper(*cptr1) - towupper(*cptr2) );
}


int IconvTransService::compareNIString( const   XMLCh* const    comp1
                                        , const XMLCh* const    comp2
                                        , const unsigned int    maxChars)
{
    unsigned int  n = 0;
    const XMLCh* cptr1 = comp1;
    const XMLCh* cptr2 = comp2;

    while ( (*cptr1 != 0) && (*cptr2 != 0) && (n < maxChars) )
    {
        wint_t wch1 = towupper(*cptr1);
        wint_t wch2 = towupper(*cptr2);
        if (wch1 != wch2)
            break;
        
        cptr1++;
        cptr2++;
        n++;
    }
    return (int) ( towupper(*cptr1) - towupper(*cptr2) );
}


const XMLCh* IconvTransService::getId() const
{
    return gMyServiceId;
}


bool IconvTransService::isSpace(const XMLCh toCheck) const
{
    return (iswspace(toCheck) != 0);
}


XMLLCPTranscoder* IconvTransService::makeNewLCPTranscoder()
{
    // Just allocate a new transcoder of our type
    return new IconvLCPTranscoder;
}

bool IconvTransService::supportsSrcOfs() const
{
    return true;
}


// ---------------------------------------------------------------------------
//  IconvTransService: The protected virtual transcoding service API
// ---------------------------------------------------------------------------
XMLTranscoder*
IconvTransService::makeNewXMLTranscoder(const   XMLCh* const            encodingName
                                        ,       XMLTransService::Codes& resValue
                                        , const unsigned int            )
{
    //
    //  NOTE: We don't use the block size here
    //
    //  This is a minimalist transcoding service, that only supports a local
    //  default transcoder. All named encodings return zero as a failure,
    //  which means that only the intrinsic encodings supported by the parser
    //  itself will work for XML data.
    //
    resValue = XMLTransService::UnsupportedEncoding;
    return 0;
}

void IconvTransService::upperCase(XMLCh* const toUpperCase) const
{
    XMLCh* outPtr = toUpperCase;
    while (*outPtr)
    {
        *outPtr = towupper(*outPtr);
        outPtr++;
    }
}



// ---------------------------------------------------------------------------
//  IconvLCPTranscoder: The virtual transcoder API
// ---------------------------------------------------------------------------
unsigned int IconvLCPTranscoder::calcRequiredSize(const char* const srcText)
{
    if (!srcText)
        return 0;

    const unsigned int retVal = ::mbstowcs(NULL, srcText, 0);

    if (retVal == ~0)
        return 0;
    return retVal;
}


unsigned int IconvLCPTranscoder::calcRequiredSize(const XMLCh* const srcText)
{
    if (!srcText)
        return 0;

    unsigned int  wLent = getWideCharLength(srcText);
    wchar_t       tmpWideCharArr[gTempBuffArraySize];
    wchar_t*      allocatedArray = 0;
    wchar_t*      wideCharBuf = 0;

    if (wLent >= gTempBuffArraySize)
        wideCharBuf = allocatedArray = new wchar_t[wLent + 1];
    else
        wideCharBuf = tmpWideCharArr;

    for (unsigned int i = 0; i < wLent; i++)
    {
        wideCharBuf[i] = srcText[i];
    }
    wideCharBuf[wLent] = 0x00;

    const unsigned int retVal = ::wcstombs(NULL, wideCharBuf, 0);
    delete [] allocatedArray;

    if (retVal == ~0)
        return 0;
    return retVal;
}


char* IconvLCPTranscoder::transcode(const XMLCh* const toTranscode)
{
    if (!toTranscode)
        return 0;

    char* retVal = 0;
    if (toTranscode)
    {
        unsigned int  wLent = getWideCharLength(toTranscode);

        wchar_t       tmpWideCharArr[gTempBuffArraySize];
        wchar_t*      allocatedArray = 0;
        wchar_t*      wideCharBuf = 0;

        if (wLent >= gTempBuffArraySize)
            wideCharBuf = allocatedArray = new wchar_t[wLent + 1];
        else
            wideCharBuf = tmpWideCharArr;

        for (unsigned int i = 0; i < wLent; i++)
        {
            wideCharBuf[i] = toTranscode[i];
        }
        wideCharBuf[wLent] = 0x00;

        // Calc the needed size.
        const size_t neededLen = ::wcstombs(NULL, wideCharBuf, 0);
        if (neededLen == 0)
        {
            delete [] allocatedArray;
            return 0;
        }

        retVal = new char[neededLen + 1];
        ::wcstombs(retVal, wideCharBuf, neededLen);
        retVal[neededLen] = 0;
        delete [] allocatedArray;
    }
    else
    {
        retVal = new char[1];
        retVal[0] = 0;
    }
    return retVal;
}


bool IconvLCPTranscoder::transcode( const   XMLCh* const    toTranscode
                                    ,       char* const     toFill
                                    , const unsigned int    maxBytes)
{
    // Watch for a couple of pyscho corner cases
    if (!toTranscode || !maxBytes)
    {
        toFill[0] = 0;
        return true;
    }

    if (!*toTranscode)
    {
        toFill[0] = 0;
        return true;
    }

    wchar_t       tmpWideCharArr[gTempBuffArraySize];
    wchar_t*      allocatedArray = 0;
    wchar_t*      wideCharBuf = 0;

    if (maxBytes >= gTempBuffArraySize)
        wideCharBuf = allocatedArray = new wchar_t[maxBytes + 1];
    else
        wideCharBuf = tmpWideCharArr;

    for (unsigned int i = 0; i < maxBytes; i++)
    {
        wideCharBuf[i] = toTranscode[i];
    }
    wideCharBuf[maxBytes] = 0x00;

    // Ok, go ahead and try the transcoding. If it fails, then ...
    if (::wcstombs(toFill, wideCharBuf, maxBytes) == -1)
    {
        delete [] allocatedArray;
        return false;
    }

    // Cap it off just in case
    toFill[maxBytes] = 0;
    delete [] allocatedArray;
    return true;
}



XMLCh* IconvLCPTranscoder::transcode(const char* const toTranscode)
{
    XMLCh* retVal = 0;
    if (toTranscode)
    {
        const unsigned int len = calcRequiredSize(toTranscode);
        if (len == 0)
            return 0;

        wchar_t       tmpWideCharArr[gTempBuffArraySize];
        wchar_t*      allocatedArray = 0;
        wchar_t*      wideCharBuf = 0;

        if (len >= gTempBuffArraySize)
            wideCharBuf = allocatedArray = new wchar_t[len + 1];
        else
            wideCharBuf = tmpWideCharArr;

        ::mbstowcs(wideCharBuf, toTranscode, len);
        retVal = new XMLCh[len + 1];
        for (unsigned int i = 0; i < len; i++)
        {
            retVal[i] = (XMLCh) wideCharBuf[i];
        }
        retVal[len] = 0x00;
        delete [] allocatedArray;
    }
    else
    {
        retVal = new XMLCh[1];
        retVal[0] = 0;
    }
    return retVal;
}


bool IconvLCPTranscoder::transcode( const   char* const     toTranscode
                                    ,       XMLCh* const    toFill
                                    , const unsigned int    maxChars)
{
    // Check for a couple of psycho corner cases
    if (!toTranscode || !maxChars)
    {
        toFill[0] = 0;
        return true;
    }

    if (!*toTranscode)
    {
        toFill[0] = 0;
        return true;
    }

    wchar_t       tmpWideCharArr[gTempBuffArraySize];
    wchar_t*      allocatedArray = 0;
    wchar_t*      wideCharBuf = 0;

    if (maxChars >= gTempBuffArraySize)
        wideCharBuf = allocatedArray = new wchar_t[maxChars + 1];
    else
        wideCharBuf = tmpWideCharArr;

    if (::mbstowcs(wideCharBuf, toTranscode, maxChars) == -1)
    {
        delete [] allocatedArray;
        return false;
    }

    for (unsigned int i = 0; i < maxChars; i++)
    {
        toFill[i] = (XMLCh) wideCharBuf[i];
    }
    toFill[maxChars] = 0x00;
    delete [] allocatedArray;
    return true;
}



// ---------------------------------------------------------------------------
//  IconvLCPTranscoder: Constructors and Destructor
// ---------------------------------------------------------------------------
IconvLCPTranscoder::IconvLCPTranscoder()
{
}

IconvLCPTranscoder::~IconvLCPTranscoder()
{
}

// ---------------------------------------------------------------------------
//  IconvTranscoder: Constructors and Destructor
// ---------------------------------------------------------------------------
IconvTranscoder::IconvTranscoder(const  XMLCh* const    encodingName
                                , const unsigned int    blockSize) :

    XMLTranscoder(encodingName, blockSize)
{
}

IconvTranscoder::~IconvTranscoder()
{
}


// ---------------------------------------------------------------------------
//  IconvTranscoder: Implementation of the virtual transcoder API
// ---------------------------------------------------------------------------
XMLCh IconvTranscoder::transcodeOne(const   XMLByte* const  srcData
                                    , const unsigned int    srcBytes
                                    ,       unsigned int&   bytesEaten)
{
    wchar_t  toFill;
    int eaten = ::mbtowc(&toFill, (const char*)srcData, srcBytes);
    if (eaten == -1)
    {
        bytesEaten = 0;
        return 0;
    }

    // Return the bytes we ate and the resulting char.
    bytesEaten = eaten;
    return toFill;
}


unsigned int
IconvTranscoder::transcodeXML(  const   XMLByte* const          srcData
                                , const unsigned int            srcCount
                                ,       XMLCh* const            toFill
                                , const unsigned int            maxChars
                                ,       unsigned int&           bytesEaten
                                ,       unsigned char* const    charSizes)
{
    //
    //  For this one, because we have to maintain the offset table, we have
    //  to do them one char at a time until we run out of source data.
    //
    unsigned int countIn = 0;
    unsigned int countOut = 0;
    while (countOut < maxChars)
    {
        wchar_t   oneWideChar;
        const int bytesEaten =
            ::mbtowc(&oneWideChar, (const char*)&srcData[countIn], srcCount - countIn);

        // We are done, so break out
        if (bytesEaten == -1)
            break;
        toFill[countOut] = (XMLCh) oneWideChar;
        countIn += (unsigned int) bytesEaten;
        countOut++;
    }

    // Give back the counts of eaten and transcoded
    bytesEaten = countIn;
    return countOut;
}
