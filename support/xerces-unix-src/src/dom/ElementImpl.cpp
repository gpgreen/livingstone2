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
 * $Id: ElementImpl.cpp,v 1.1.1.1 2000/09/20 20:40:21 bhudson Exp $
 */

#include "DeepNodeListImpl.hpp"
#include "DocumentImpl.hpp"
#include "DocumentTypeImpl.hpp"
#include "DOM_DOMException.hpp"
#include "DStringPool.hpp"
#include "ElementImpl.hpp"
#include "ElementDefinitionImpl.hpp"
#include "NamedNodeMapImpl.hpp"
#include "NodeVector.hpp"


ElementImpl::ElementImpl(DocumentImpl *ownerDoc, const DOMString &eName)
    : ChildAndParentNode(ownerDoc)
{
    name = eName.clone();
    attributes = null;
};


ElementImpl::ElementImpl(const ElementImpl &other, bool deep)
    : ChildAndParentNode(other)
{
    name = other.name.clone();
	attributes = null;
    if (deep)
        cloneChildren(other);
	if (other.attributes != null)
		attributes = other.attributes->cloneMap(this);
};


ElementImpl::~ElementImpl()
{
    if (attributes)
    {
        attributes->removeAll();
        NamedNodeMapImpl::removeRef(attributes);
    }
};


NodeImpl *ElementImpl::cloneNode(bool deep)
{
    return new ElementImpl(*this, deep);
};


/**
 * NON-DOM
 * set the ownerDocument of this node, its children, and its attributes
 */
void ElementImpl::setOwnerDocument(DocumentImpl *doc) {
    ChildAndParentNode::setOwnerDocument(doc);
	if (attributes != null)
		attributes->setOwnerDocument(doc);
}


DOMString ElementImpl::getNodeName() {
    return name;
};


short ElementImpl::getNodeType() {
    return DOM_Node::ELEMENT_NODE;
};


DOMString ElementImpl::getAttribute(const DOMString &nam)
{
    static DOMString *emptyString = 0;
    AttrImpl * attr=null;

    if (attributes != null)
	attr=(AttrImpl *)(attributes->getNamedItem(nam));

    return (attr==null) ? DStringPool::getStaticString("", &emptyString) : attr->getValue();
};



AttrImpl *ElementImpl::getAttributeNode(const DOMString &nam)
{
    return (attributes == null) ? null : (AttrImpl *)(attributes->getNamedItem(nam));
};


NamedNodeMapImpl *ElementImpl::getAttributes()
{
    return attributes;
};



DeepNodeListImpl *ElementImpl::getElementsByTagName(const DOMString &tagname)
{
    return new DeepNodeListImpl(this,tagname);
};


DOMString ElementImpl::getTagName()
{
    return name;
}  


bool ElementImpl::isElementImpl()
{
    return true;
};


void ElementImpl::removeAttribute(const DOMString &nam)
{
    if (readOnly())
        throw DOM_DOMException(
        DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);

    if (attributes != null)
    {    
    	AttrImpl *att = (AttrImpl *) attributes->getNamedItem(nam);
    	// Remove it
    	if (att != null)
    	{
    	    attributes->removeNamedItem(nam);
    	    if (att->nodeRefCount == 0)
    	        NodeImpl::deleteIf(att);
    	}
    }
};



AttrImpl *ElementImpl::removeAttributeNode(AttrImpl *oldAttr)
{
    if (readOnly())
        throw DOM_DOMException(
        DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
    
    if (attributes != null)
    {
	    AttrImpl *found = (AttrImpl *) attributes->getNamedItem(oldAttr->getName());
    
	    // If it is in fact the right object, remove it.
    
	    if (found == oldAttr)
	    {
	        attributes->removeNamedItem(oldAttr->getName());
	        return found;
	    }
	    else
	        throw DOM_DOMException(DOM_DOMException::NOT_FOUND_ERR, null);
	}
	return null;	// just to keep the compiler happy
};



AttrImpl *ElementImpl::setAttribute(const DOMString &nam, const DOMString &val)
{
    if (readOnly())
        throw DOM_DOMException(
        DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
    
    AttrImpl* newAttr = (AttrImpl*)getAttributeNode(nam);
    if (!newAttr)
    {
		if (attributes == null)
			attributes = new NamedNodeMapImpl(this);
        newAttr = (AttrImpl*)ownerDocument->createAttribute(nam);
        attributes->setNamedItem(newAttr);
    }

    newAttr->setNodeValue(val);       // Note that setNodeValue on attribute
                                      //   nodes takes care of deleting
                                      //   any previously existing children.
    return newAttr;
};



AttrImpl * ElementImpl::setAttributeNode(AttrImpl *newAttr)
{
    if (readOnly())
        throw DOM_DOMException(
        DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
    
    if (!(newAttr->isAttrImpl()))
        throw DOM_DOMException(DOM_DOMException::WRONG_DOCUMENT_ERR, null);
	if (attributes == null)
		attributes = new NamedNodeMapImpl(this);
    AttrImpl *oldAttr =
      (AttrImpl *) attributes->getNamedItem(newAttr->getName());
    // This will throw INUSE if necessary
    attributes->setNamedItem(newAttr);
    
    // Attr node reference counting note:
    // If oldAttr's refcount is zero at this point, here's what happens...
    // 
    //      oldAttr is returned from this function to DOM_Attr::setAttributeNode,
    //      which wraps a DOM_Attr around the returned pointer and sends it
    //      up to application code, incrementing the reference count in the process.
    //      When the app DOM_Attr's destructor runs, the reference count is
    //      decremented back to zero and oldAttr will be deleted at that time.

    return oldAttr;
};


void ElementImpl::setNodeValue(const DOMString &x)
{
    throw DOM_DOMException(DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
};



void ElementImpl::setReadOnly(bool readOnl, bool deep)
{
    ChildAndParentNode::setReadOnly(readOnl,deep);
    attributes->setReadOnly(readOnl,true);
};


//Introduced in DOM Level 2
DOMString ElementImpl::getAttributeNS(const DOMString &fNamespaceURI,
	const DOMString &fLocalName)
{
    AttrImpl * attr=
      (AttrImpl *)(attributes->getNamedItemNS(fNamespaceURI, fLocalName));
    return (attr==null) ? DOMString(null) : attr->getValue();
}


AttrImpl *ElementImpl::setAttributeNS(const DOMString &fNamespaceURI,
	const DOMString &qualifiedName, const DOMString &fValue)
{
    if (readOnly())
        throw DOM_DOMException(
	    DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
    
    AttrImpl *newAttr =
      (AttrImpl *) ownerDocument->createAttributeNS(fNamespaceURI,
                                                    qualifiedName);
    newAttr->setNodeValue(fValue);
	if (attributes == null)
		attributes = new NamedNodeMapImpl(this);
    AttrImpl *oldAttr = (AttrImpl *)attributes->setNamedItem(newAttr);

    if (oldAttr) {
	if (oldAttr->nodeRefCount == 0)
	    NodeImpl::deleteIf(oldAttr);
    }
    return newAttr;
}


void ElementImpl::removeAttributeNS(const DOMString &fNamespaceURI,
	const DOMString &fLocalName)
{
    if (readOnly())
        throw DOM_DOMException(
	    DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
 
    if (attributes != null)
    {   
		AttrImpl *att =
		  (AttrImpl *) attributes->getNamedItemNS(fNamespaceURI, fLocalName);
		// Remove it 
		if (att != null) {
			attributes->removeNamedItemNS(fNamespaceURI, fLocalName);
			if (att->nodeRefCount == 0)
				NodeImpl::deleteIf(att);
		}
	}
}


AttrImpl *ElementImpl::getAttributeNodeNS(const DOMString &fNamespaceURI,
	const DOMString &fLocalName)
{
    return (AttrImpl *)(attributes->getNamedItemNS(fNamespaceURI, fLocalName));
}


AttrImpl *ElementImpl::setAttributeNodeNS(AttrImpl *newAttr)
{
    if (readOnly())
        throw DOM_DOMException(
	    DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR, null);
    
    if (newAttr -> getOwnerDocument() != this -> getOwnerDocument())
        throw DOM_DOMException(DOM_DOMException::WRONG_DOCUMENT_ERR, null);
	if (attributes == null)
		attributes = new NamedNodeMapImpl(this);
    AttrImpl *oldAttr = (AttrImpl *) attributes->getNamedItemNS(newAttr->getNamespaceURI(), newAttr->getLocalName());
    
    // This will throw INUSE if necessary
    attributes->setNamedItemNS(newAttr);
    
    // Attr node reference counting note:
    // If oldAttr's refcount is zero at this point, here's what happens...
    // 
    //      oldAttr is returned from this function to DOM_Attr::setAttributeNode,
    //      which wraps a DOM_Attr around the returned pointer and sends it
    //      up to application code, incrementing the reference count in the process.
    //      When the app DOM_Attr's destructor runs, the reference count is
    //      decremented back to zero and oldAttr will be deleted at that time.

    return oldAttr;
}


DeepNodeListImpl *ElementImpl::getElementsByTagNameNS(const DOMString &fNamespaceURI,
	const DOMString &fLocalName)
{
    return new DeepNodeListImpl(this,fNamespaceURI, fLocalName);
}

// DOM_NamedNodeMap UTILITIES
NamedNodeMapImpl *ElementImpl::NNM_cloneMap(NodeImpl *ownerNode) 
{
	return (getAttributes() == null) ? null : ownerNode->getAttributes()->cloneMap(ownerNode);
}

int ElementImpl::NNM_findNamePoint(const DOMString &name)
{
	return (getAttributes() == null) ? -1 : getAttributes()->findNamePoint(name);
}

unsigned int ElementImpl::NNM_getLength()
{
	return (getAttributes() == null) ? 0 : getAttributes()->getLength();
}

NodeImpl *ElementImpl::NNM_getNamedItem(const DOMString &name)
{
	return (getAttributes() == null) ? null : getAttributes()->getNamedItem(name);
}

NodeImpl *ElementImpl::NNM_item(unsigned int index)
{
	return (getAttributes() == null) ? null : getAttributes()->item(index);
}

void ElementImpl::NNM_removeAll() 
{
	if (getAttributes() != null)
		getAttributes()->removeAll();
}

NodeImpl *ElementImpl::NNM_removeNamedItem(const DOMString &name)
{
	if (getAttributes() == null)
		throw DOM_DOMException(DOM_DOMException::NOT_FOUND_ERR, null);
	else
		return getAttributes()->removeNamedItem(name);
	return null;
}

NodeImpl *ElementImpl::NNM_setNamedItem(NodeImpl *arg)
{
	if (getAttributes() == null)
		attributes = new NamedNodeMapImpl(this);
	return attributes->setNamedItem(arg);
}

void ElementImpl::NNM_setReadOnly(bool readOnly, bool deep)
{
	if (getAttributes() != null)
		getAttributes()->setReadOnly(readOnly, deep);
}

int ElementImpl::NNM_findNamePoint(const DOMString &namespaceURI, const DOMString &localName)
{
	return (getAttributes() == null) ? -1 : getAttributes()->findNamePoint(namespaceURI, localName);
}

NodeImpl *ElementImpl::NNM_getNamedItemNS(const DOMString &namespaceURI, const DOMString &localName)
{
	return (getAttributes() == null) ? null : getAttributes()->getNamedItemNS(namespaceURI, localName);
}

NodeImpl *ElementImpl::NNM_setNamedItemNS(NodeImpl *arg)
{
	if (getAttributes() == null)
		attributes = new NamedNodeMapImpl(this);
	return getAttributes()->setNamedItemNS(arg);
}

NodeImpl *ElementImpl::NNM_removeNamedItemNS(const DOMString &namespaceURI, const DOMString &localName)
{
	if (getAttributes() == null)
        throw DOM_DOMException(DOM_DOMException::NOT_FOUND_ERR, null);
	else
		return getAttributes()->removeNamedItemNS(namespaceURI, localName);
	return null;
}

void ElementImpl::NNM_setOwnerDocument(DocumentImpl *doc)
{
	if (getAttributes() != null)
		getAttributes()->setOwnerDocument(doc);
}
