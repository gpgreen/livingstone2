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
 * $Log: XMLEntityDecl.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:55  kurien
 * XML parser for C++
 *
 *
 * Revision 1.2  2000/02/06 07:47:48  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:32  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:38  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/XMLUni.hpp>
#include <util/XMLString.hpp>
#include <framework/XMLEntityDecl.hpp>


// ---------------------------------------------------------------------------
//  XMLEntityDecl: Constructors and Destructor
// ---------------------------------------------------------------------------
XMLEntityDecl::XMLEntityDecl() :

    fName(0)
    , fNotationName(0)
    , fPublicId(0)
    , fSystemId(0)
    , fValue(0)
    , fValueLen(0)
{
}

XMLEntityDecl::XMLEntityDecl(const XMLCh* const entName) :

    fName(0)
    , fNotationName(0)
    , fPublicId(0)
    , fSystemId(0)
    , fValue(0)
    , fValueLen(0)
{
    fName = XMLString::replicate(entName);
}

XMLEntityDecl::XMLEntityDecl(const  XMLCh* const    entName
                            , const XMLCh* const    value) :
    fName(0)
    , fNotationName(0)
    , fPublicId(0)
    , fSystemId(0)
    , fValue(0)
    , fValueLen(0)
{
    try
    {
        fName = XMLString::replicate(entName);
        fValue = XMLString::replicate(value);
        fValueLen = XMLString::stringLen(value);
    }

    catch(...)
    {
        cleanUp();
    }
}

XMLEntityDecl::XMLEntityDecl(const  XMLCh* const    entName
                            , const XMLCh           value) :
    fName(0)
    , fNotationName(0)
    , fPublicId(0)
    , fSystemId(0)
    , fValue(0)
    , fValueLen(0)
{
    try
    {
        fValue = new XMLCh[2];
        fValue[0] = value;
        fValue[1] = chNull;
        fValueLen = 1;
        fName = XMLString::replicate(entName);
    }

    catch(...)
    {
        cleanUp();
    }
}

XMLEntityDecl::~XMLEntityDecl()
{
    cleanUp();
}


// ---------------------------------------------------------------------------
//  XMLEntityDecl: Setter methods
// ---------------------------------------------------------------------------
void XMLEntityDecl::setName(const XMLCh* const entName)
{
    // Clean up the current name stuff
    delete [] fName;
    fName = 0;
    fName = XMLString::replicate(entName);
}


// ---------------------------------------------------------------------------
//  XMLEntityDecl: Private helper methods
// ---------------------------------------------------------------------------
void XMLEntityDecl::cleanUp()
{
    delete [] fName;
    delete [] fNotationName;
    delete [] fValue;
    delete [] fPublicId;
    delete [] fSystemId;
}
