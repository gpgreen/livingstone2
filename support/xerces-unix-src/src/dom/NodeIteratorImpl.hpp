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
 * $Log: NodeIteratorImpl.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:23  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.5  2000/02/24 20:11:30  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.4  2000/02/15 23:17:37  andyh
 * Update Doc++ API comments
 * NameSpace bugfix and update to track W3C
 * Chih Hsiang Chou
 *
 * Revision 1.3  2000/02/06 07:47:33  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/02/04 01:49:26  aruna1
 * TreeWalker and NodeIterator changes
 *
 * Revision 1.1.1.1  1999/11/09 01:09:16  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:30  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#ifndef NodeIteratorImpl_HEADER_GUARD_
#define NodeIteratorImpl_HEADER_GUARD_


// NodeIteratorImpl.hpp: interface for the NodeIteratorImpl class.
//
//////////////////////////////////////////////////////////////////////

#include "DOM_Node.hpp"
#include "DOM_NodeIterator.hpp"
#include "RefCountedImpl.hpp"


class CDOM_EXPORT NodeIteratorImpl : public RefCountedImpl {
	protected:
		NodeIteratorImpl ();

	public:
		virtual ~NodeIteratorImpl ();
		NodeIteratorImpl (
            DOM_Node root, 
            unsigned long whatToShow, 
            DOM_NodeFilter* nodeFilter,
            bool expandEntityRef);

        NodeIteratorImpl ( const NodeIteratorImpl& toCopy);
		
        NodeIteratorImpl& operator= (const NodeIteratorImpl& other);
		
        unsigned long getWhatToShow ();
		DOM_NodeFilter* getFilter ();

		DOM_Node nextNode ();
		DOM_Node previousNode ();
		bool acceptNode (DOM_Node node);
		DOM_Node matchNodeOrParent (DOM_Node node);
		DOM_Node nextNode (DOM_Node node, bool visitChildren);
		DOM_Node previousNode (DOM_Node node);
		void removeNode (DOM_Node node);

		void unreferenced();

		void detach ();

        // Get the expandEntity reference flag.
        bool getExpandEntityReferences();


	private:
		//
		// Data
		//
		// The root.
		DOM_Node fRoot;

		// The whatToShow mask.
		unsigned long fWhatToShow;

		// The NodeFilter reference.
		DOM_NodeFilter* fNodeFilter;

        // The expandEntity reference flag.
        bool  fExpandEntityReferences;

		bool fDetached;

		//
		// Iterator state - current node and direction.
		//
		// Note: The current node and direction are sufficient to implement
		// the desired behaviour of the current pointer being _between_
		// two nodes. The fCurrentNode is actually the last node returned,
		// and the
		// direction is whether the pointer is in front or behind this node.
		// (usually akin to whether the node was returned via nextNode())
		// (eg fForward = true) or previousNode() (eg fForward = false).

		// The last Node returned.
		DOM_Node fCurrentNode;

		// The direction of the iterator on the fCurrentNode.
		//  <pre>
		//  nextNode()  ==      fForward = true;
		//  previousNode() ==   fForward = false;
		//  </pre>
		bool fForward;


};

#endif
