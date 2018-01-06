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
 * $Id: NodeImpl.cpp,v 1.1.1.1 2000/09/20 20:40:22 bhudson Exp $
 */

// This class doesn't support having any children, and implements the behavior
// of an empty NodeList as far getChildNodes is concerned.
// The ParentNode subclass overrides this behavior.

#include "NodeImpl.hpp"
#include "AttrImpl.hpp"
#include "DOM_DOMException.hpp"
#include "DOM_Node.hpp"
#include "DOM_DOMImplementation.hpp"
#include "DOMString.hpp"
#include "DStringPool.hpp"
#include "DocumentImpl.hpp"
#include "NodeIDMap.hpp"
#include "stdio.h"
#include "TextImpl.hpp"

static DOMString *s_xml = null;
static DOMString *s_xmlURI = null;
static DOMString *s_xmlns = null;
static DOMString *s_xmlnsURI = null;

const unsigned short NodeImpl::READONLY     = 0x1<<0;
const unsigned short NodeImpl::SYNCDATA     = 0x1<<1;
const unsigned short NodeImpl::SYNCCHILDREN = 0x1<<2;
const unsigned short NodeImpl::OWNED        = 0x1<<3;
const unsigned short NodeImpl::FIRSTCHILD   = 0x1<<4;
const unsigned short NodeImpl::SPECIFIED    = 0x1<<5;
const unsigned short NodeImpl::IGNORABLEWS  = 0x1<<6;
const unsigned short NodeImpl::SETVALUE     = 0x1<<7;
const unsigned short NodeImpl::ID_ATTR      = 0x1<<8;


NodeImpl::NodeImpl(DocumentImpl *ownerDoc)
{
    this->userData = null;
    this->flags = 0;
    // as long as we do not have any owner, ownerNode is our ownerDocument
    this->ownerNode  = ownerDoc;
    
    this->nodeRefCount = 0;
    NodeImpl::gLiveNodeImpls++; 
    NodeImpl::gTotalNodeImpls++;
};  

// This only makes a shallow copy, cloneChildren must also be called for a
// deep clone
NodeImpl::NodeImpl(const NodeImpl &other) {
    this->flags = other.flags;
    this->userData = other.userData;
    this->readOnly(false);
    
    this->nodeRefCount = 0;
    NodeImpl::gLiveNodeImpls++; 
    NodeImpl::gTotalNodeImpls++;
    
    // Need to break the association w/ original parent
    //    this->ownerNode = other.getOwnerDocument(); this doesn't work???
    this->ownerNode = ((NodeImpl*)&other)->getOwnerDocument();
    this->owned(false);
};

    
int  NodeImpl::gLiveNodeImpls = 0;         // Counters for debug & tuning.
int  NodeImpl::gTotalNodeImpls= 0;



NodeImpl::~NodeImpl() {
    NodeImpl::gLiveNodeImpls--;
};


// Dynamic Cast substitute functions
bool NodeImpl::isAttrImpl()              {return false;};
bool NodeImpl::isCDATASectionImpl()      {return false;};
bool NodeImpl::isDocumentFragmentImpl()  {return false;};
bool NodeImpl::isDocumentImpl()          {return false;};
bool NodeImpl::isDocumentTypeImpl()      {return false;};
bool NodeImpl::isElementImpl()           {return false;};
bool NodeImpl::isEntityReference()       {return false;};
bool NodeImpl::isTextImpl()              {return false;};


void NodeImpl::changed() {}     // overridden in subclasses

int NodeImpl::changes()
{
        // overridden in subclasses
//        throw new RuntimeException(
//                  "changes() called on a NodeImpl or one of its subclasses" +
//                  "which doesn't really implement it");
    return 0;
};  


NodeImpl * NodeImpl::appendChild(NodeImpl *newChild)      
{
    return insertBefore(newChild, null);
};


//  NodeImpl::deleteIf is called when a node's reference count goes
//  to 0.  It is separate function from removeRef because removeRef
//  is likely to be in-lined.
//
//  See comments at RefCountedImpl::removeRef().
//
void NodeImpl::deleteIf(NodeImpl *thisNode)
{
    if (thisNode == 0)
        return;

    if (thisNode->owned())
        return;
    
    // Delete this node.  There should be no siblings, as the DOM
    //  supports no node operations that would detach a node from
    //  its parent while retaining siblings.
    //  The target node may have children, in which case they must
    //  be removed from this node before deleting this node.

    // First, if this node is an ID attribute, we need to remove it
    // from the hashtable of element IDs before removing the Attrs
    //   children.  This is because the Attr's children Text nodes
    //   contain the attr's value, which is the hash table key.
    //
    if (thisNode->isAttrImpl() && ((AttrImpl *)thisNode->idAttr()))
    {
        ((AttrImpl *)thisNode)->getOwnerDocument() ->
            getNodeIDMap()->remove((AttrImpl *)thisNode);
    }

    thisNode->readOnly(false);   // removeChild requires node not be readonly.
    NodeImpl *theNextChild;
    for (NodeImpl *child = thisNode->getFirstChild(); child != 0;
         child=theNextChild)
    {
        theNextChild = child->getNextSibling();
        thisNode->removeChild(child);
        if (child->nodeRefCount == 0)
            deleteIf(child);
    }
    delete thisNode;
};



NamedNodeMapImpl * NodeImpl::getAttributes() {
    return 0;                   // overridden in ElementImpl
};


NodeListImpl *NodeImpl::getChildNodes() {
    return this;                // overridden in ParentNode
};



NodeImpl * NodeImpl::getFirstChild() {
    return 0;                   // overridden in ParentNode
}; 


NodeImpl * NodeImpl::getLastChild()
{
    return 0;                   // overridden in ParentNode
}; 


unsigned int NodeImpl::getLength() {
    return 0;                   // overridden in ParentNode
};


NodeImpl * NodeImpl::getNextSibling() {
    return null;                // overridden in ChildNode
}; 



DOMString NodeImpl::getNodeValue()
{
    return null;                // overridden in some subclasses
};


DocumentImpl *NodeImpl::getOwnerDocument()
{
    // if we have an owner simply forward the request
    // otherwise ownerNode is our ownerDocument
    if (owned()) {
        return ownerNode->getDocument();
    } else {
        return (DocumentImpl *) ownerNode;
    }
};  

// unlike getOwnerDocument this is not overriden by DocumentImpl to return null
DocumentImpl *NodeImpl::getDocument()
{
    // if we have an owner simply forward the request
    // otherwise ownerNode is our ownerDocument
    if (owned()) {
        return ownerNode->getDocument();
    } else {
        return (DocumentImpl *) ownerNode;
    }
};  


void NodeImpl::setOwnerDocument(DocumentImpl *doc) {
    // if we have an owner we rely on it to have it right
    // otherwise ownerNode is our ownerDocument
    if (!owned()) {
        ownerNode = doc;
    }
}

NodeImpl * NodeImpl::getParentNode()
{
    return null;                // overridden in ChildNode
};  


NodeImpl*  NodeImpl::getPreviousSibling()
{
    return null;                // overridden in ChildNode
}; 


void *NodeImpl::getUserData()
{
    return userData;
};  


bool NodeImpl::hasChildNodes()
{ 
    return false;
}; 



NodeImpl *NodeImpl::insertBefore(NodeImpl *newChild, NodeImpl *refChild) {
    throw DOM_DOMException(DOM_DOMException::HIERARCHY_REQUEST_ERR,null);
    return 0;
};
  
NodeImpl *NodeImpl::item(unsigned int index) {
    return 0;
};


NodeImpl *NodeImpl::removeChild(NodeImpl *oldChild) 
{
    throw DOM_DOMException(DOM_DOMException::NOT_FOUND_ERR, null);
    return 0;
};
  
  
NodeImpl *NodeImpl::replaceChild(NodeImpl *newChild, NodeImpl *oldChild)
{
    throw DOM_DOMException(DOM_DOMException::HIERARCHY_REQUEST_ERR,null);
    return 0;
};


  void NodeImpl::referenced()
  {
      RefCountedImpl::addRef(this->getOwnerDocument());
  };
  
  
  //
  //    unreferenced  will be called whenever the refernce count on
  //            this node goes from 1 to 0.  This node will only be
  //            directly deleted here  (by deleteIf) if it is outside 
  //            of the document tree.  
  //
  void NodeImpl::unreferenced()
  {
      DocumentImpl *doc = this->getOwnerDocument();
      deleteIf(this);       // This gets nodes outside of the document -
      //   deleteIf() deletes only if the parent
      //   node is null.  
      
      // If this was the last external reference within the document,
      //    the entire document will be deleted as well.
      RefCountedImpl::removeRef(doc);
  };


void NodeImpl::setNodeValue(const DOMString &val)
{
    if (readOnly())
        throw DOM_DOMException(DOM_DOMException::NO_MODIFICATION_ALLOWED_ERR,
                               null);
    // Default behavior is to do nothing, overridden in some subclasses
};



void NodeImpl::setReadOnly(bool readOnl, bool deep)
{
    this->readOnly(readOnl);
    // by default we do not have children, so deep is meaningless
    // this is overridden by ParentNode
}


  void NodeImpl::setUserData(void * val)
  {
      userData = val;
  };  
  
  
  
  DOMString NodeImpl::toString()
  {
      return DOMString("[")+getNodeName()+": "+getNodeValue()+"]";
      // return getNodeName();
  };    
  
//Introduced in DOM Level 2
  
void NodeImpl::normalize()
{
    // does nothing by default, overridden by subclasses
};


bool NodeImpl::supports(const DOMString &feature, const DOMString &version)
{
    return DOM_DOMImplementation::getImplementation().hasFeature(feature, version);
}

DOMString NodeImpl::getNamespaceURI()
{
    return 0;
}

DOMString NodeImpl::getPrefix()
{
    return 0;
}

DOMString NodeImpl::getLocalName()
{
    return 0;
}


void NodeImpl::setPrefix(const DOMString &fPrefix)
{
    throw DOM_DOMException(DOM_DOMException::NAMESPACE_ERR,null);
}


DOMString NodeImpl::getXmlnsString() {
    return DStringPool::getStaticString("xmlns", &s_xmlns);
}

DOMString NodeImpl::getXmlnsURIString() {
    return DStringPool::getStaticString("http://www.w3.org/2000/xmlns/",
                                        &s_xmlnsURI);
}

DOMString NodeImpl::getXmlString() {
    return DStringPool::getStaticString("xml", &s_xml);
}

DOMString NodeImpl::getXmlURIString() {
    return DStringPool::getStaticString("http://www.w3.org/XML/1998/namespace",
                                        &s_xmlURI);
}

//Return a URI mapped from the given prefix and namespaceURI as below
//	prefix   namespaceURI		output
//---------------------------------------------------
//	"xml"      xmlURI            xmlURI
//	"xml"	   otherwise         NAMESPACE_ERR
//	"xmlns"	   xmlnsURI	         xmlnsURI (nType = ATTRIBUTE_NODE only)
//	"xmlns"	   otherwise         NAMESPACE_ERR (nType = ATTRIBUTE_NODE only)
//   != null   null or ""        NAMESPACE_ERR
//	else       any			     namesapceURI
const DOMString& NodeImpl::mapPrefix(const DOMString &prefix,
                                     const DOMString &namespaceURI, short nType)
{
    DOMString xml = DStringPool::getStaticString("xml", &s_xml);
    DOMString xmlURI = DStringPool::getStaticString("http://www.w3.org/XML/1998/namespace", &s_xmlURI);
    DOMString xmlns = DStringPool::getStaticString("xmlns", &s_xmlns);
    DOMString xmlnsURI = DStringPool::getStaticString("http://www.w3.org/2000/xmlns/", &s_xmlnsURI);
    
    if (prefix == null)
        return namespaceURI;
    if (prefix.equals(xml)) {
        if (namespaceURI.equals(xmlURI))
            return *s_xmlURI;
        throw DOM_DOMException(DOM_DOMException::NAMESPACE_ERR, null);
    } else if (nType == DOM_Node::ATTRIBUTE_NODE && prefix.equals(xmlns)) {
        if (namespaceURI.equals(xmlnsURI))
            return *s_xmlnsURI;
        throw DOM_DOMException(DOM_DOMException::NAMESPACE_ERR, null);
    } else if (namespaceURI == null || namespaceURI.length() == 0) {
        throw DOM_DOMException(DOM_DOMException::NAMESPACE_ERR, null);
    } else
        return namespaceURI;
    return namespaceURI;
}
