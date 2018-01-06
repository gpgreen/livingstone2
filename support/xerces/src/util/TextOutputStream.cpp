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
 * $Log: TextOutputStream.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:38:07  kurien
 * XML parser for C++
 *
 *
 * Revision 1.2  2000/02/06 07:48:04  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:05:13  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:15  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/Janitor.hpp>
#include <util/TextOutputStream.hpp>
#include <util/XMLString.hpp>
#include <util/XMLUni.hpp>

#include <math.h>
#include <stdlib.h>


// ---------------------------------------------------------------------------
//  StreamJanitor: Constructors and Destructor
// ---------------------------------------------------------------------------
StreamJanitor::StreamJanitor(TextOutputStream* const toSanitize) :

    fRadix(toSanitize->fRadix)
    , fStream(toSanitize)
{
}

StreamJanitor::~StreamJanitor()
{
    if (fStream)
    {
        fStream->fRadix = fRadix;
    }
}


// ---------------------------------------------------------------------------
//  TextOutputStream: Virtual destructor
// ---------------------------------------------------------------------------
TextOutputStream::~TextOutputStream()
{
}


// ---------------------------------------------------------------------------
//  TextOutputStream: Formatting operators
// ---------------------------------------------------------------------------
TextOutputStream& TextOutputStream::operator<<(const XMLCh* const toWrite)
{
    write(toWrite);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const XMLCh toWrite)
{
    XMLCh szTmp[2];
    szTmp[0] = toWrite;
    szTmp[1] = 0;

    write(szTmp);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const char* const toWrite)
{
    write(toWrite);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const char toWrite)
{
    char szTmp[2];
    szTmp[0] = toWrite;
    szTmp[1] = 0;
    write(szTmp);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const unsigned int toWrite)
{
    XMLCh szTmp[128];
    XMLString::binToText(toWrite, szTmp, 127, fRadix);

    write(szTmp);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const long toWrite)
{
    XMLCh szTmp[128];
    XMLString::binToText(toWrite, szTmp, 127, fRadix);

    write(szTmp);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const unsigned long toWrite)
{
    XMLCh szTmp[128];
    XMLString::binToText(toWrite, szTmp, 127, fRadix);

    write(szTmp);
    return *this;
}

TextOutputStream& TextOutputStream::operator<<(const double& toWrite)
{
    // To avoid portability issues, split into two parts
    double fracPart;
    double intPart;
    intPart = modf(toWrite, &fracPart);

    if (fracPart < 0)
        fracPart *= (double)-1.0;

    XMLCh szTmp[128];
    XMLString::binToText((long)intPart, szTmp, 127, fRadix);
    write(szTmp);

    szTmp[0] = '.';
    szTmp[1] = 0;
    write(szTmp);

    XMLString::binToText((long)fracPart, szTmp, 127, fRadix);
    write(szTmp);
    return *this;
}

TextOutputStream&
TextOutputStream::operator<<(const TextOutputStream::Radices newRadix)
{
    fRadix = newRadix;
    return *this;
}

TextOutputStream&
TextOutputStream::operator<<(const TextOutputStream::SpecialValues newValue)
{
    static const XMLCh newLine[] = { chLF, chNull };

    if (newValue == EndLine)
    {
        write(newLine);
        flush();
    }
    return *this;
}



// ---------------------------------------------------------------------------
//  TextOutputStream: Hidden Constructors and Destructor
// ---------------------------------------------------------------------------
TextOutputStream::TextOutputStream() :

    fRadix(TextOutputStream::decimal)
{
}
