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
 * $Log: TreeWalkerImpl.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:52  kurien
 * XML parser for C++
 *
 *
 * Revision 1.5  2000/02/24 20:11:31  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.4  2000/02/15 23:17:37  andyh
 * Update Doc++ API comments
 * NameSpace bugfix and update to track W3C
 * Chih Hsiang Chou
 *
 * Revision 1.3  2000/02/06 07:47:34  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/02/04 01:49:24  aruna1
 * TreeWalker and NodeIterator changes
 *
 * Revision 1.1.1.1  1999/11/09 01:09:20  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:44:34  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#ifndef TreeWalkerImpl_HEADER_GUARD_
#define TreeWalkerImpl_HEADER_GUARD_


#include "DOM_TreeWalker.hpp"
#include "RefCountedImpl.hpp"


class CDOM_EXPORT TreeWalkerImpl : public RefCountedImpl {

	public:
    // Implementation Note: No state is kept except the data above
    // (fWhatToShow, fNodeFilter, fCurrentNode, fRoot) such that
    // setters could be created for these data values and the
    // implementation will still work.

    /** Public constructor */
    TreeWalkerImpl (
        DOM_Node root, 
        unsigned long whatToShow, 
        DOM_NodeFilter* nodeFilter,
        bool expandEntityRef);
    TreeWalkerImpl (const TreeWalkerImpl& twi);
    TreeWalkerImpl& operator= (const TreeWalkerImpl& twi);

    // Return the whatToShow value.
    unsigned long  getWhatToShow ();

    // Return the NodeFilter.
    DOM_NodeFilter* getFilter ();

	void detach ();

    // Return the current DOM_Node.
    DOM_Node getCurrentNode ();

    // Return the current Node.
    void setCurrentNode (DOM_Node node);

    // Return the parent Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node parentNode ();

    // Return the first child Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node firstChild ();

    // Return the last child Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node lastChild ();

    // Return the previous sibling Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node previousSibling ();

    // Return the next sibling Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.

    DOM_Node nextSibling ();
    // Return the previous Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node previousNode ();

    // Return the next Node from the current node,
    //  after applying filter, whatToshow.
    //  If result is not null, set the current Node.
    DOM_Node nextNode ();

    void unreferenced ();
    
    // Get the expandEntity reference flag.
    bool getExpandEntityReferences();

protected:

    // Internal function.
    //  Return the parent Node, from the input node
    //  after applying filter, whatToshow.
    //  The current node is not consulted or set.
    DOM_Node getParentNode (DOM_Node node);

    // Internal function.
    //  Return the nextSibling Node, from the input node
    //  after applying filter, whatToshow.
    //  The current node is not consulted or set.
    DOM_Node getNextSibling (DOM_Node node);

    // Internal function.
    //  Return the previous sibling Node, from the input node
    //  after applying filter, whatToshow.
    //  The current node is not consulted or set.
    DOM_Node getPreviousSibling (DOM_Node node);

    // Internal function.
    //  Return the first child Node, from the input node
    //  after applying filter, whatToshow.
    //  The current node is not consulted or set.
    DOM_Node getFirstChild (DOM_Node node);

    // Internal function.
    //  Return the last child Node, from the input node
    //  after applying filter, whatToshow.
    //  The current node is not consulted or set.
    DOM_Node getLastChild (DOM_Node node);

    // The node is accepted if it passes the whatToShow and the filter.
    short acceptNode (DOM_Node node);

    		
private:
    // The whatToShow mask.
    unsigned long fWhatToShow;

    // The NodeFilter reference.
    DOM_NodeFilter* fNodeFilter;

    // The current Node.
    DOM_Node fCurrentNode;

    // The root Node.
    DOM_Node fRoot;

    // The expandEntity reference flag.
    bool fExpandEntityReferences;

	bool fDetached;
};

#endif
