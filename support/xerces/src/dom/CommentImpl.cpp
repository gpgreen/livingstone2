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
 * $Log: CommentImpl.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:41  kurien
 * XML parser for C++
 *
 *
 * Revision 1.2  2000/02/06 07:47:27  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:41  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:11  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

/**
 * Represents an XML (or HTML) comment.
 *
 * @author Rania Y. Khalaf
 * @author Joseph Kesselman 
 * @since  PR-DOM-Level-1-19980818.
 */

#include "CommentImpl.hpp"
#include "CharacterDataImpl.hpp"
#include "DOM_Node.hpp"
#include "DocumentImpl.hpp"
#include "DStringPool.hpp"

static DOMString *gComment;   // will be lazily initialized to point to "#comment"

CommentImpl::CommentImpl(DocumentImpl *ownerDoc, const DOMString &data) :
CharacterDataImpl(ownerDoc, DStringPool::getStaticString("#comment", &gComment),
                  DOM_Node::COMMENT_NODE, data)
{
};


CommentImpl::CommentImpl(const CommentImpl &other, bool deep)
: CharacterDataImpl(other, deep)
{
};


CommentImpl::~CommentImpl() {
};



NodeImpl * CommentImpl::cloneNode(bool deep)
{
        return new CommentImpl(*this, deep);
};
