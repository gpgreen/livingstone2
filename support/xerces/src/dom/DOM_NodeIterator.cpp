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
 * $Log: DOM_NodeIterator.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:47  kurien
 * XML parser for C++
 *
 *
 * Revision 1.3  2000/02/06 07:47:30  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/02/04 01:49:28  aruna1
 * TreeWalker and NodeIterator changes
 *
 * Revision 1.1.1.1  1999/11/09 01:09:01  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:20  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#include "DOM_NodeIterator.hpp"
#include "NodeIteratorImpl.hpp"
#include "RefCountedImpl.hpp"




DOM_NodeIterator::DOM_NodeIterator()
{
    fImpl = 0;
}


DOM_NodeIterator::DOM_NodeIterator(NodeIteratorImpl *impl)
{
    fImpl = impl;
    RefCountedImpl::addRef(fImpl);
}


DOM_NodeIterator::DOM_NodeIterator(const DOM_NodeIterator &other)
{
	  this->fImpl = other.fImpl;
    RefCountedImpl::addRef(fImpl);
}


DOM_NodeIterator & DOM_NodeIterator::operator = (const DOM_NodeIterator &other)
{
    if (this->fImpl != other.fImpl)
    {
        RefCountedImpl::removeRef(this->fImpl);
        this->fImpl = other.fImpl;
        RefCountedImpl::addRef(this->fImpl);
    }
    return *this;
};


DOM_NodeIterator & DOM_NodeIterator::operator = (const DOM_NullPtr *other)
{
    RefCountedImpl::removeRef(this->fImpl);
    this->fImpl = 0;
    return *this;
};



DOM_NodeIterator::~DOM_NodeIterator()
{
    RefCountedImpl::removeRef (this->fImpl);
    fImpl = 0;
};

//
//      Comparison operators.  Equivalent of Java object reference ==
//                                         Null references compare ==.
//
bool       DOM_NodeIterator::operator != (const DOM_NodeIterator & other) const
{
    return this->fImpl != other.fImpl;
};


bool       DOM_NodeIterator::operator == (const DOM_NodeIterator & other) const
{
    return this->fImpl == other.fImpl;
};

bool       DOM_NodeIterator::operator != (const DOM_NullPtr * other) const
{
    return this->fImpl != 0;
};


bool       DOM_NodeIterator::operator == (const DOM_NullPtr * other) const
{
    return this->fImpl == 0;
}


void DOM_NodeIterator::detach ()
{
	fImpl->detach();
}



unsigned long DOM_NodeIterator::getWhatToShow ()
{
	  return fImpl->getWhatToShow();
}


DOM_NodeFilter*     DOM_NodeIterator::getFilter() {
    return fImpl->getFilter();
}

/** Get the expandEntity reference flag. */
bool DOM_NodeIterator::getExpandEntityReferences()
{
    if (fImpl !=0)
        return fImpl->getExpandEntityReferences();
    return false;
}


DOM_Node            DOM_NodeIterator::nextNode() {
    return fImpl->nextNode();
}


DOM_Node            DOM_NodeIterator::previousNode() {
  return fImpl->previousNode();
}
