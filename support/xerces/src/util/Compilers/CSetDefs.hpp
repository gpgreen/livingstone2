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
 * $Log: CSetDefs.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:38:12  kurien
 * XML parser for C++
 *
 *
 * Revision 1.6  2000/02/06 07:48:17  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.5  2000/01/14 02:28:16  aruna1
 * Added L"string" support for cset compiler
 *
 * Revision 1.4  2000/01/12 19:11:49  aruna1
 * XMLCh now defined to wchar_t
 *
 * Revision 1.3  1999/11/12 20:36:51  rahulj
 * Changed library name to xerces-c.lib.
 *
 * Revision 1.1.1.1  1999/11/09 01:07:31  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:45:22  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
// Define these away for this platform
// ---------------------------------------------------------------------------
#define PLATFORM_EXPORT
#define PLATFORM_IMPORT

// ---------------------------------------------------------------------------
//  Supports L"" prefixed constants. There are places
//  where it is advantageous to use the L"" where it supported, to avoid
//  unnecessary transcoding. xlC_r does support this, so we define this token.
//  If your compiler does not support it, don't define this.
// ---------------------------------------------------------------------------
#define XML_LSTRSUPPORT

// ---------------------------------------------------------------------------
// Indicate that we do not support native bools
// ---------------------------------------------------------------------------
#define NO_NATIVE_BOOL


// ---------------------------------------------------------------------------
//  Define our version of the XML character
// ---------------------------------------------------------------------------
//typedef unsigned short XMLCh;
typedef wchar_t XMLCh;

// ---------------------------------------------------------------------------
//  Define unsigned 16 and 32 bits integers
// ---------------------------------------------------------------------------
typedef unsigned short XMLUInt16;
typedef unsigned int   XMLUInt32;


// ---------------------------------------------------------------------------
//  Force on the XML4C debug token if it was on in the build environment
// ---------------------------------------------------------------------------
#if 0
#define XML4C_DEBUG
#endif


// ---------------------------------------------------------------------------
//  Provide some common string ops that are different/notavail on CSet
// ---------------------------------------------------------------------------
inline char toupper(const char toUpper) 
{
    if ((toUpper >= 'a') && (toUpper <= 'z'))
        return char(toUpper - 0x20);
    return toUpper;
}

inline char tolower(const char toLower)
{
    if ((toLower >= 'A') && (toLower <= 'Z'))
        return char(toLower + 0x20);
    return toLower;
}

int stricmp(const char* const str1, const char* const  str2);
int strnicmp(const char* const str1, const char* const  str2, const unsigned int count);



// ---------------------------------------------------------------------------
//  The name of the DLL that is built by the CSet C++ version of the system.
// ---------------------------------------------------------------------------
const char* const XML4C_DLLName = "libxerces-c";
