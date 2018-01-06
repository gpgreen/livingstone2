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
 * $Log: CoreTests_CountedPointer.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:38:33  kurien
 * XML parser for C++
 *
 *
 * Revision 1.3  2000/02/06 07:48:39  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/01/19 00:59:06  roddey
 * Get rid of dependence on old utils output streams.
 *
 * Revision 1.1.1.1  1999/11/09 01:01:50  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:42:26  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  XML4C2 Includes
// ---------------------------------------------------------------------------
#include "CoreTests.hpp"
#include <util/CountedPointer.hpp>


// ---------------------------------------------------------------------------
//  A local class used for testing
// ---------------------------------------------------------------------------
class TestClass
{
public :
    static unsigned int gCounter;

    TestClass()
    {
        gCounter++;
    }

    ~TestClass()
    {
        gCounter--;
    }

    void addRef()
    {
        refCount++;
    }

    void removeRef()
    {
        refCount--;
        if (refCount == 0)
            delete this;
    }

private :
    unsigned int refCount;
};

unsigned int TestClass::gCounter = 0;


// ---------------------------------------------------------------------------
//  Force a full instantiation to test syntax
// ---------------------------------------------------------------------------
template class CountedPointerTo<TestClass>;


// ---------------------------------------------------------------------------
//  Test entry point
// ---------------------------------------------------------------------------
bool testCountedPointer()
{
    std::wcout  << L"----------------------------------\n"
                << L"Testing CountedPointerTo class\n"
                << L"----------------------------------" << std::endl;

    bool retVal = true;

    try
    {
    }

    catch(const XMLException& toCatch)
    {
        std::wcout << L"  ERROR: Unexpected exception!\n   Msg: "
                   << toCatch.getMessage() << std::endl;
        return false;
    }
    return retVal;
}
