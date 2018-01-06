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
 * $Id: AttrImpl.cpp,v 1.1.1.1 2000/09/20 20:40:15 bhudson Exp $
 */

#include "AttrImpl.hpp"
#include "DOM_DOMException.hpp"
#include "DocumentImpl.hpp"
#include "TextImpl.hpp"
#include "ElementImpl.hpp"
#include "DStringPool.hpp"
#include "NodeIDMap.hpp"


AttrImpl::AttrImpl(DocumentImpl *ownerDoc, const DOMString &aName) 
    : ParentNode (ownerDoc)
{
    name = aName.clone();
    specified(true);
};

AttrImpl::AttrImpl(const AttrImpl &other, bool deep)
    : ParentNode(other)
{
    name = other.name.clone();
	
    specified(true);
    if (other.idAttr())
    {
        idAttr(true);
        this->getOwnerDocument()->getNodeIDMap()->add(this);
    }
    
	cloneChildren(other);
};


AttrImpl::~AttrImpl() {
};


NodeImpl * AttrImpl::cloneNode(bool deep) 
{
    return new AttrImpl(*this, deep);
};


DOMString AttrImpl::getNodeName() {
    return name;
};


short AttrImpl::getNodeType() {
    return DOM_Node::ATTRIBUTE_NODE;
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
    return specified();
};




DOMString AttrImpl::getValue() 
{
    if (firstChild == null) {
        return 0; // return "";
    }
    ChildNode *node = firstChild->nextSibling;
    if (node == null) {
        return firstChild->getNodeValue().clone();
    }
    int             length = 0;
    for (node = firstChild; node != null; node = node->nextSibling)
        length += node->getNodeValue().length();
    
    DOMString retString;
    retString.reserve(length);
    for (node = firstChild; node != null; node = node->nextSibling)
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
    specified(arg);
};



void AttrImpl::setValue(const DOMString &val)
{
    if (readOnly())
    {
        throw DOM_DOMException
        (
            DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null
        );
    }
    
    //  If this attribute was of type ID and in the map, take it out,
    //    then put it back in with the new name.  For now, we don't worry
    //    about what happens if the new name conflicts
    //
    if (idAttr())
        this->getOwnerDocument()->getNodeIDMap()->remove(this);

    NodeImpl *kid;
    while ((kid = firstChild) != null)         // Remove existing kids
    {
        removeChild(kid);
        if (kid->nodeRefCount == 0)
            NodeImpl::deleteIf(kid);
    }

    if (val != null)              // Create and add the new one
        appendChild(ownerDocument->createTextNode(val));
    specified(true);
    changed();
    
    if (idAttr())
        this->getOwnerDocument()->getNodeIDMap()->add(this);

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
    // if we have an owner, ownerNode is our ownerElement, otherwise it's
    // our ownerDocument and we don't have an ownerElement
    return (ElementImpl *) (owned() ? ownerNode : null);
}


//internal use by parser only
void AttrImpl::setOwnerElement(ElementImpl *ownerElem)
{
    ownerNode = ownerElem;
    owned(false);
}
