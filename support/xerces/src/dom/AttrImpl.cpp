
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
 * $Log: AttrImpl.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:41  kurien
 * XML parser for C++
 *
 *
 * Revision 1.5  2000/02/06 07:47:27  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.4  2000/02/03 23:07:27  andyh
 * Add several new functions from Robert Weir to DOMString.
 *
 * Revision 1.3  2000/01/22 01:38:29  andyh
 * Remove compiler warnings in DOM impl classes
 *
 * Revision 1.2  1999/11/30 21:16:24  roddey
 * Changes to add the transcode() method to DOMString, which returns a transcoded
 * version (to local code page) of the DOM string contents. And I changed all of the
 * exception 'throw by pointer' to 'throw by value' style.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:39  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:44:10  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#include "AttrImpl.hpp"
#include "DOM_DOMException.hpp"
#include "DocumentImpl.hpp"
#include "TextImpl.hpp"


#define null 0

AttrImpl::AttrImpl(DocumentImpl *ownerDoc, const DOMString &aName) 
:  NodeImpl (ownerDoc, aName, DOM_Node::ATTRIBUTE_NODE, false, DOMString())
{
    specified = true;
    ownerElement = null;    //DOM Level 2
};

//DOM Level 2
AttrImpl::AttrImpl(DocumentImpl *ownerDoc,   //DOM Level 2
    const DOMString &fNamespaceURI, const DOMString &qualifiedName)
:  NodeImpl (ownerDoc, fNamespaceURI, qualifiedName, DOM_Node::ATTRIBUTE_NODE, false, DOMString())
{
    specified = true;
    ownerElement = null;    //DOM Level 2
};

AttrImpl::AttrImpl(const AttrImpl &other, bool deep)
: NodeImpl(other, deep)
{
    specified = false;
    ownerElement = null;    //DOM Level 2
};


AttrImpl::~AttrImpl() {
};


NodeImpl * AttrImpl::cloneNode(bool deep) 
{
    AttrImpl *newnode;
    newnode = new AttrImpl(*this, deep);
    return newnode;
};


DOMString AttrImpl::getName()
{
    return name;
};



DOMString AttrImpl::getNodeValue()
{
    return getValue();
};



bool AttrImpl::getSpecified() 
{
    return specified;
};




DOMString AttrImpl::getValue() 
{
    int             length = 0;
    NodeImpl        *node;
    for (node = getFirstChild(); node != null; node = node->getNextSibling())
        length += node->getNodeValue().length();
    
    DOMString retString;
	retString.reserve(length);
    for (node = getFirstChild(); node != null; node = node->getNextSibling())
    {
        retString.appendData(node->getNodeValue());
    };
    
    return retString;
};


bool AttrImpl::isAttrImpl()
{
    return true;
};


void AttrImpl::setNodeValue(const DOMString &val)
{
    setValue(val);
};



void AttrImpl::setSpecified(bool arg)
{
    specified = arg;
};



void AttrImpl::setValue(const DOMString &val)
{
    if (readOnly)
    {
        throw DOM_DOMException
        (
            DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null
        );
    }
    
    NodeImpl *kid;
    while ((kid = getFirstChild()) != null)         // Remove existing kids
    {
        removeChild(kid);
        if (kid->nodeRefCount == 0)
            NodeImpl::deleteIf(kid);
    }

    if (val != null)              // Create and add the new one
        appendChild(ownerDocument->createTextNode(val));
    specified = true;
    changed();
};



DOMString AttrImpl::toString()
{
    DOMString retString;
    
    retString.appendData(name);
    retString.appendData(DOMString("=\""));
    retString.appendData(getValue());
    retString.appendData(DOMString("\""));
    return retString;
}


//Introduced in DOM Level 2

ElementImpl *AttrImpl::getOwnerElement()
{
    return ownerElement;
}


//internal use by parser only
void AttrImpl::setOwnerElement(ElementImpl *ownerElem)
{
    ownerElement = ownerElem;
}
