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
 * $Log: DeepNodeListImpl.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:42  kurien
 * XML parser for C++
 *
 *
 * Revision 1.4  2000/02/06 07:47:31  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.3  2000/02/04 01:49:30  aruna1
 * TreeWalker and NodeIterator changes
 *
 * Revision 1.2  2000/01/22 01:38:29  andyh
 * Remove compiler warnings in DOM impl classes
 *
 * Revision 1.1.1.1  1999/11/09 01:08:42  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:44:23  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#include "DeepNodeListImpl.hpp"
#include "NodeVector.hpp"
#include "NodeImpl.hpp"
#include "ElementImpl.hpp"
#include "DStringPool.hpp"
#include <limits.h>

static DOMString *kAstr;

DeepNodeListImpl::DeepNodeListImpl(NodeImpl *rootNod, const DOMString &tagNam)
{
    changes = 0;
    this->rootNode = rootNod;
    this->tagName = tagNam;
    nodes=new NodeVector();
    matchAll = tagName.equals(DStringPool::getStaticString("*", &kAstr));
    this->namespaceURI = null;	//DOM Level 2
    this->matchAllURI = false;	//DOM Level 2
    this->matchURIandTagname = false;	//DOM Level 2
};


//DOM Level 2
DeepNodeListImpl::DeepNodeListImpl(NodeImpl *rootNod,
    const DOMString &fNamespaceURI, const DOMString &localName)
{
    changes = 0;
    this->rootNode = rootNod;
    this->tagName = localName;
    nodes=new NodeVector();
    matchAll = tagName.equals(DStringPool::getStaticString("*", &kAstr));
    this->namespaceURI = fNamespaceURI;
    this->matchAllURI = fNamespaceURI.equals(DStringPool::getStaticString("*", &kAstr));
    this->matchURIandTagname = true;
};


DeepNodeListImpl::~DeepNodeListImpl()
{
    delete nodes;
};


unsigned int DeepNodeListImpl::getLength()
{
    // Preload all matching elements. (Stops when we run out of subtree!)
    item(INT_MAX);
    return nodes->size();
};



// Start from the first child and count forward, 0-based. index>length-1
// should return null.
//
// Attempts to do only work actually requested, cache work already
// done, and to flush that cache when the tree has changed.
//
// LIMITATION: ????? Unable to tell relevant tree-changes from
// irrelevant ones.  Doing so in a really useful manner would seem
// to involve a tree-walk in its own right, or maintaining our data
// in a parallel tree.
NodeImpl *DeepNodeListImpl::item(unsigned int index)
{
    NodeImpl *thisNode;
    
    if(rootNode->changes != changes)
    {
        nodes->reset();     // Tree changed. Do it all from scratch!
        changes=rootNode->changes;
    }
    
    if(index< nodes->size())      // In the cache
        return nodes->elementAt((int) index);
    else                        // Not yet seen
    {
        if(nodes->size()==0)     // Pick up where we left off
            thisNode=rootNode; // (Which may be the beginning)
        else
            thisNode=nodes->lastElement();

        while(thisNode!=null && index >= nodes->size() && thisNode!=null)
        {
            thisNode=nextMatchingElementAfter(thisNode);
            if(thisNode!=null)
                nodes->addElement(thisNode);
        }
        return thisNode;           // Either what we want, or null (not avail.)
    }
};



/* Iterative tree-walker. When you have a Parent link, there's often no
need to resort to recursion. NOTE THAT only Element nodes are matched
since we're specifically supporting getElementsByTagName().
*/

NodeImpl *DeepNodeListImpl::nextMatchingElementAfter(NodeImpl *current)
{
    NodeImpl *next;
    while (current != null)
    {
        // Look down to first child.
        if (current->hasChildNodes())
        {
            current = current->getFirstChild();
        }
        // Look right to sibling (but not from root!)
        else
        {
            if (current != rootNode && null != (next = current->getNextSibling()))
            {
                current = next;
            }
            // Look up and right (but not past root!)
            else
            {
                next = null;
                for (; current != rootNode; // Stop when we return to starting point
                current = current->getParentNode())
                {
                    next = current->getNextSibling();
                    if (next != null)
                        break;
                }
                current = next;
            }
        }
        
        // Have we found an Element with the right tagName?
        // ("*" matches anything.)
        if (current != null && current != rootNode && current->isElementImpl()) {
	    if (!matchURIandTagname) {	//DOM Level 1
		if (matchAll || ((ElementImpl *)current)->getTagName().equals(tagName))
		    return current;
	    } else {	//DOM Level 2
		if (!matchAllURI && !(current -> getNamespaceURI().equals(namespaceURI)))
		    continue;
		if (matchAll || current -> getLocalName().equals(tagName))
		    return current;
	    }
	}
        
        // Otherwise continue walking the tree
    }
    // Fell out of tree-walk; no more instances found
    return null;
};


//
//  unreferenced()      The RefCountedImpl base class calls back to this function
//                      when the ref count goes to zero.
//
//          
void DeepNodeListImpl::unreferenced()
{
    delete this;
};

