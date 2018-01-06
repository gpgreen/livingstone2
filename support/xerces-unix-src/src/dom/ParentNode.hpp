#ifndef ParentNode_HEADER_GUARD_
#define ParentNode_HEADER_GUARD_

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

//
//  This file is part of the internal implementation of the C++ XML DOM.
//  It should NOT be included or used directly by application programs.
//
//  Applications should include the file <dom/DOM.hpp> for the entire
//  DOM API, or DOM_*.hpp for individual DOM classes, where the class
//  name is substituded for the *.
//

/*
 * $Id: ParentNode.hpp,v 1.1.1.1 2000/09/20 20:40:23 bhudson Exp $
 */

/**
 * ParentNode inherits from NodeImpl and adds the capability of having child
 * nodes. Not every node in the DOM can have children, so only nodes that can
 * should inherit from this class and pay the price for it.
 * <P>
 * While we have a direct reference to the first child, the last child is
 * stored as the previous sibling of the first child. First child nodes are
 * marked as being so, and getNextSibling hides this fact.
 *
 **/

#include <util/XercesDefs.hpp>
#include "ChildNode.hpp"
#include "DOMString.hpp"

// these are redefined in ChildAndParentNode so that the code can be reused.
#ifndef THIS_CLASS
#define THIS_CLASS ParentNode
#endif
#ifndef PARENT_CLASS
#define PARENT_CLASS NodeImpl
#endif

class CDOM_EXPORT THIS_CLASS: public PARENT_CLASS {
public:
    DocumentImpl            *ownerDocument; // Document this node belongs to

    ChildNode                *firstChild;

    int fChanges;

public:
    THIS_CLASS(DocumentImpl *ownerDocument);
    THIS_CLASS(const THIS_CLASS &other);
    
    virtual DocumentImpl * getOwnerDocument();
    virtual void setOwnerDocument(DocumentImpl *doc);

    virtual int changes();
    virtual void changed();

    virtual NodeListImpl *getChildNodes();
    virtual NodeImpl * getFirstChild();
    virtual NodeImpl * getLastChild();
    virtual unsigned int getLength();
    virtual bool        hasChildNodes();
    virtual NodeImpl    *insertBefore(NodeImpl *newChild, NodeImpl *refChild);
    virtual NodeImpl    *item(unsigned int index);
    virtual NodeImpl    * removeChild(NodeImpl *oldChild);
    virtual NodeImpl    *replaceChild(NodeImpl *newChild, NodeImpl *oldChild);
    virtual void        setReadOnly(bool readOnly, bool deep);

    //Introduced in DOM Level 2
    virtual void	normalize();

    // NON-DOM
    // unlike getOwnerDocument this never returns null, even for Document nodes
    virtual DocumentImpl * getDocument();
protected:
    void cloneChildren(const NodeImpl &other);
    ChildNode * lastChild();
    void lastChild(ChildNode *);
};

#undef THIS_CLASS
#undef PARENT_CLASS
#endif
