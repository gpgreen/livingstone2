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
 * $Log: Iconv390TransService.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:54  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.7  2000/03/02 19:55:35  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.6  2000/02/14 19:32:15  abagchi
 * Reintroduced bug-fix in 1.4
 *
 * Revision 1.5  2000/02/14 17:59:49  abagchi
 * Reused iconv descriptors
 *
 * Revision 1.4  2000/02/11 03:10:20  rahulj
 * Fixed defect in compare[N]IString function. Defect and fix reported
 * by Bill Schindler from developer@bitranch.com.
 * Replaced tabs with appropriate number of spaces.
 *
 * Revision 1.3  2000/02/10 00:23:04  abagchi
 * Eliminated references to ibm-1047
 *
 * Revision 1.2  2000/02/09 01:31:22  abagchi
 * Fixed calcRequiredSize() for OS390BATCH
 *
 * Revision 1.1  2000/02/08 02:14:11  abagchi
 * Initial checkin
 *
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/XMLUni.hpp>
#include "Iconv390TransService.hpp"

#include <wchar.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#ifdef OS390BATCH
#include <unistd.h>
#endif
#include <ctype.h>
//
//  Cannot use the OS/390 c/c++ towupper and towlower functions in the
//  Unicode environment. We will use mytowupper and mytowlower here.
//
#undef towupper
#undef towlower
#define towupper mytowupper
#define towlower mytowlower

// ---------------------------------------------------------------------------
//  Local, const data
// ---------------------------------------------------------------------------
static const int gTempBuffArraySize = 1024;
static const XMLCh  gMyServiceId[] =
{
    chLatin_I, chLatin_C, chLatin_o, chLatin_n, chLatin_v, chNull
};
// ---------------------------------------------------------------------------
//  gUnicodeToIBM037XlatTable
//      This is the translation table for Unicode to ibm-037. This table
//      contains 255 entries.
// ---------------------------------------------------------------------------
static const XMLByte gUnicodeToIBM037XlatTable[256] =
{
        0x00, 0x01, 0x02, 0x03, 0x37, 0x2D, 0x2E, 0x2F
    ,   0x16, 0x05, 0x25, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
    ,   0x10, 0x11, 0x12, 0x13, 0x3C, 0x3D, 0x32, 0x26
    ,   0x18, 0x19, 0x3F, 0x27, 0x1C, 0x1D, 0x1E, 0x1F
    ,   0x40, 0x5A, 0x7F, 0x7B, 0x5B, 0x6C, 0x50, 0x7D
    ,   0x4D, 0x5D, 0x5C, 0x4E, 0x6B, 0x60, 0x4B, 0x61
    ,   0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7
    ,   0xF8, 0xF9, 0x7A, 0x5E, 0x4C, 0x7E, 0x6E, 0x6F
    ,   0x7C, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7
    ,   0xC8, 0xC9, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6
    ,   0xD7, 0xD8, 0xD9, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6
    ,   0xE7, 0xE8, 0xE9, 0xBA, 0xE0, 0xBB, 0xB0, 0x6D
    ,   0x79, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87
    ,   0x88, 0x89, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96
    ,   0x97, 0x98, 0x99, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6
    ,   0xA7, 0xA8, 0xA9, 0xC0, 0x4F, 0xD0, 0xA1, 0x07
    ,   0x20, 0x21, 0x22, 0x23, 0x24, 0x15, 0x06, 0x17
    ,   0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x09, 0x0A, 0x1B
    ,   0x30, 0x31, 0x1A, 0x33, 0x34, 0x35, 0x36, 0x08
    ,   0x38, 0x39, 0x3A, 0x3B, 0x04, 0x14, 0x3E, 0xFF
    ,   0x41, 0xAA, 0x4A, 0xB1, 0x9F, 0xB2, 0x6A, 0xB5
    ,   0xBD, 0xB4, 0x9A, 0x8A, 0x5F, 0xCA, 0xAF, 0xBC
    ,   0x90, 0x8F, 0xEA, 0xFA, 0xBE, 0xA0, 0xB6, 0xB3
    ,   0x9D, 0xDA, 0x9B, 0x8B, 0xB7, 0xB8, 0xB9, 0xAB
    ,   0x64, 0x65, 0x62, 0x66, 0x63, 0x67, 0x9E, 0x68
    ,   0x74, 0x71, 0x72, 0x73, 0x78, 0x75, 0x76, 0x77
    ,   0xAC, 0x69, 0xED, 0xEE, 0xEB, 0xEF, 0xEC, 0xBF
    ,   0x80, 0xFD, 0xFE, 0xFB, 0xFC, 0xAD, 0xAE, 0x59
    ,   0x44, 0x45, 0x42, 0x46, 0x43, 0x47, 0x9C, 0x48
    ,   0x54, 0x51, 0x52, 0x53, 0x58, 0x55, 0x56, 0x57
    ,   0x8C, 0x49, 0xCD, 0xCE, 0xCB, 0xCF, 0xCC, 0xE1
    ,   0x70, 0xDD, 0xDE, 0xDB, 0xDC, 0x8D, 0x8E, 0xDF
};
iconvconverter * converterList;
XMLMutex  converterListMutex;

iconvconverter * addConverter(const char* const EncodingName
                             ,XMLTransService::Codes& resValue)
{
    XMLMutexLock lockConverterlist(&converterListMutex);
    iconvconverter *tconv=converterList;
    while ( (tconv) &&
            (strcmp(tconv->name,EncodingName)) )
      tconv = tconv->nextconverter;

    if (tconv) {
      tconv->usecount++;
    }
    else {
      tconv = new iconvconverter;
      strcpy(tconv->name,EncodingName);
      tconv->usecount=1;
      tconv->fIconv390Descriptor = iconv_open("UCS-2",EncodingName);
      if (tconv->fIconv390Descriptor == (iconv_t)(-1)) {
         resValue = XMLTransService::UnsupportedEncoding;
         delete tconv;
         return 0;
      }
      tconv->nextconverter = converterList;
      converterList = tconv;
    }
    return tconv;
}

void removeConverter(iconvconverter* const converter)
{
    iconvconverter *pconv,*tconv;
    tconv = 0;
    if (converter) {
      XMLMutexLock lockConverterlist(&converterListMutex);
      if (--converter->usecount==0) {
        tconv = converterList;
        pconv = (iconvconverter*)&converterList;
        while ( (tconv) && (tconv!=converter) ) {
          pconv=tconv;
          tconv=tconv->nextconverter;
        }

        pconv->nextconverter=tconv->nextconverter;
      }
    }

    if (tconv) {
      iconv_close(tconv->fIconv390Descriptor);
      delete tconv;
    }
}

// ---------------------------------------------------------------------------
//  Local methods
// ---------------------------------------------------------------------------
static unsigned int  getWideCharLength(const XMLCh* const src)
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
//  Iconv390TransService: Constructors and Destructor
// ---------------------------------------------------------------------------
Iconv390TransService::Iconv390TransService()
{
}

Iconv390TransService::~Iconv390TransService()
{
}


// ---------------------------------------------------------------------------
//  Iconv390TransService: The virtual transcoding service API
// ---------------------------------------------------------------------------
int Iconv390TransService::compareIString(  const   XMLCh* const    comp1
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

int Iconv390TransService::compareNIString( const   XMLCh* const    comp1
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

const XMLCh* Iconv390TransService::getId() const
{
    return gMyServiceId;
}

bool Iconv390TransService::isSpace(const XMLCh toCheck) const
{
    return (iswspace(toCheck) != 0);
}


XMLLCPTranscoder* Iconv390TransService::makeNewLCPTranscoder()
{
    XMLTransService::Codes resValue;
    // native MVS default code page is IBM-037
    iconvconverter *tconv=addConverter("IBM-037",resValue);

    if (tconv == 0) {
        return 0;
    }

    return new Iconv390LCPTranscoder(tconv);
}

bool Iconv390TransService::supportsSrcOfs() const
{
    return true;
}


// ---------------------------------------------------------------------------
//  Iconv390TransService: The protected virtual transcoding service API
// ---------------------------------------------------------------------------
XMLTranscoder*
Iconv390TransService::makeNewXMLTranscoder(const   XMLCh* const            encodingName
                                        ,       XMLTransService::Codes& resValue
                                        , const unsigned int            )
{
    //
    //  Translate the input encodingName from Unicode XMLCh format into
    //  ibm-037 char format via the lookup table.
    //
    char charEncodingName[256];
    const XMLCh*  srcPtr = encodingName;
    char*         outPtr = charEncodingName;
    while (*srcPtr != 0)
        *outPtr++ = toupper(gUnicodeToIBM037XlatTable[*srcPtr++]);
    *outPtr=0;

    iconvconverter *tconv=addConverter(charEncodingName,resValue);

    return new Iconv390Transcoder(tconv, encodingName, 0);
}

void Iconv390TransService::upperCase(XMLCh* const toUpperCase) const
{
    XMLCh* outPtr = toUpperCase;
    while (*outPtr != 0) {
	if ((*outPtr >= 0x61) && (*outPtr <= 0x7A))
	    *outPtr = *outPtr - 0x20;
	outPtr++;
    }
}

// ---------------------------------------------------------------------------
unsigned int Iconv390LCPTranscoder::calcRequiredSize(const char* const srcText)
{
    unsigned int retVal;

    if (!srcText)
        return 0;

#ifdef OS390BATCH
    //
    // Cannot use mbstowcs in a non-POSIX environment(???).
    //
    if (!__isPosixOn()) {
        const unsigned charLen = mblen(srcText, MB_CUR_MAX);
        if (charLen == -1)
            return 0;
        else {
            if (charLen != 0)
                retVal = strlen(srcText)/charLen;
            else
                retVal = charLen;
        }
    }
    else
#endif
        retVal = ::mbstowcs(NULL, srcText, 0);

    if (retVal == -1)
        return 0;
    return retVal;
}


unsigned int Iconv390LCPTranscoder::calcRequiredSize(const XMLCh* const srcText)
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

    if (retVal == -1)
        return 0;
    return retVal;
}



char* Iconv390LCPTranscoder::transcode(const XMLCh* const toTranscode)
{
    if (!toTranscode)
        return 0;

    char* retVal = 0;
    if (toTranscode)
    {
        unsigned int  wLent = getWideCharLength(toTranscode);
	//
	//  Translate the input from Unicode XMLCh format into
	//  ibm-037 char format via the lookup table.
	//
        retVal = new char[wLent + 1];
        const XMLCh *srcPtr = toTranscode;
        char *outPtr = retVal;

	while (*srcPtr != 0)
	    *outPtr++ = gUnicodeToIBM037XlatTable[*srcPtr++];
	*outPtr=0;
    }
    else
    {
        retVal = new char[1];
        retVal[0] = 0;
    }
    return retVal;
}


bool Iconv390LCPTranscoder::transcode( const   XMLCh* const    toTranscode
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

    const XMLCh *srcPtr = toTranscode;
    char *outPtr = toFill;
    int bytectr = maxBytes;

    while (bytectr--)
       *outPtr++ = gUnicodeToIBM037XlatTable[*srcPtr++];
    *outPtr=0;

    return true;
}



XMLCh* Iconv390LCPTranscoder::transcode(const char* const toTranscode)
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

        retVal = new XMLCh[len + 1];

        size_t retCode;
        char *tmpInPtr = (char*) toTranscode;
        char *tmpOutPtr = (char*) retVal;
        size_t inByteLeft = len;
        size_t outByteLeft = len*2;
        {
         XMLMutexLock lockConverter(&converter->fMutex);
         retCode = iconv(converter->fIconv390Descriptor, &tmpInPtr, &inByteLeft, &tmpOutPtr, &outByteLeft);
        }
        if (retCode == -1) {
            delete [] retVal;
            return 0;
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


bool Iconv390LCPTranscoder::transcode( const   char* const     toTranscode
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

    size_t retCode;
    char *tmpInPtr = (char*) toTranscode;
    char *tmpOutPtr = (char*) toFill;
    size_t inByteLeft = maxChars;
    size_t outByteLeft = maxChars*2;
    {
     XMLMutexLock lockConverter(&converter->fMutex);
     retCode = iconv(converter->fIconv390Descriptor, &tmpInPtr, &inByteLeft, &tmpOutPtr, &outByteLeft);
    }
    if ( (retCode == -1) && (outByteLeft!=0) ) {
        return false;
    }
    toFill[maxChars] = 0x00;
    return true;
}



// ---------------------------------------------------------------------------
//  Iconv390LCPTranscoder: Constructors and Destructor
// ---------------------------------------------------------------------------
Iconv390LCPTranscoder::Iconv390LCPTranscoder()
{
}

Iconv390LCPTranscoder::Iconv390LCPTranscoder(iconvconverter_t* const toAdopt) :
        converter (toAdopt)
{
}

Iconv390LCPTranscoder::~Iconv390LCPTranscoder()
{
    removeConverter(converter);
    converter=0;
}

// ---------------------------------------------------------------------------
//  Iconv390Transcoder: Constructors and Destructor
// ---------------------------------------------------------------------------
Iconv390Transcoder::Iconv390Transcoder(const  XMLCh* const    encodingName
                                , const unsigned int    blockSize) :
    XMLTranscoder(encodingName, blockSize)
{
}

Iconv390Transcoder::Iconv390Transcoder(iconvconverter_t* const toAdopt
				,const XMLCh* const encodingName
				,const unsigned int blockSize) :
 	XMLTranscoder(encodingName, blockSize)
       ,converter (toAdopt)
{
}

Iconv390Transcoder::~Iconv390Transcoder()
{
    removeConverter(converter);
    converter=0;
}


// ---------------------------------------------------------------------------
//  Iconv390Transcoder: Implementation of the virtual transcoder API
// ---------------------------------------------------------------------------
XMLCh Iconv390Transcoder::transcodeOne(const   XMLByte* const     srcData
                                    , const unsigned int    srcBytes
                                    ,       unsigned int&   bytesEaten)
{
    wchar_t  toFill;

    size_t retCode;
    char *tmpInPtr = (char*) srcData;
    char *tmpOutPtr = (char*)&toFill;
    size_t inByteLeft = srcBytes;
    size_t outByteLeft = 2;
    {
     XMLMutexLock lockConverter(&converter->fMutex);
     retCode = iconv(converter->fIconv390Descriptor, &tmpInPtr, &inByteLeft, &tmpOutPtr, &outByteLeft);
    }
    if (retCode == -1) {
        bytesEaten = 0;
        return 0;
    }
    int eaten = srcBytes-inByteLeft;
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
Iconv390Transcoder::transcodeXML(  const   XMLByte* const             srcData
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

    size_t retCode;
    char *tmpInPtr = (char *) srcData;
    char *tmpOutPtr = (char *) toFill;
    size_t inByteLeft = srcCount;
    size_t outByteLeft = maxChars*2;
    {
     XMLMutexLock lockConverter(&converter->fMutex);
     retCode = iconv(converter->fIconv390Descriptor, &tmpInPtr, &inByteLeft, &tmpOutPtr, &outByteLeft);
    }
    if (retCode == -1)
    {
	return 0;
    }

    // Give back the counts of eaten and transcoded
    bytesEaten = srcCount-inByteLeft;
    return maxChars-outByteLeft/2;

}
