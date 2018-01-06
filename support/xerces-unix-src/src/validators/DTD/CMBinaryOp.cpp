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
 * $Log: CMBinaryOp.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:56  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.3  2000/03/02 19:55:37  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.2  2000/02/09 21:42:36  abagchi
 * Copyright swatswat
 *
 * Revision 1.1.1.1  1999/11/09 01:03:00  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:35  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <util/XercesDefs.hpp>
#include <util/RuntimeException.hpp>
#include <validators/DTD/ContentSpecNode.hpp>
#include <validators/DTD/CMBinaryOp.hpp>
#include <validators/DTD/CMStateSet.hpp>


// ---------------------------------------------------------------------------
//  CMBinaryOp: Constructors
// ---------------------------------------------------------------------------
CMBinaryOp::CMBinaryOp( const   ContentSpecNode::NodeTypes  type
                        ,       CMNode* const               leftToAdopt
                        ,       CMNode* const               rightToAdopt) :
    CMNode(type)
    , fLeftChild(leftToAdopt)
    , fRightChild(rightToAdopt)
{
    // Insure that its one of the types we require
    if ((type != ContentSpecNode::Choice)
    &&  (type != ContentSpecNode::Sequence))
    {
        ThrowXML(RuntimeException, XMLExcepts::CM_BinOpHadUnaryType);
    }
}

CMBinaryOp::~CMBinaryOp()
{
    delete fLeftChild;
    delete fRightChild;
}


// ---------------------------------------------------------------------------
//  CMBinaryOp: Getter methods
// ---------------------------------------------------------------------------
const CMNode* CMBinaryOp::getLeft() const
{
    return fLeftChild;
}

CMNode* CMBinaryOp::getLeft()
{
    return fLeftChild;
}

const CMNode* CMBinaryOp::getRight() const
{
    return fRightChild;
}

CMNode* CMBinaryOp::getRight()
{
    return fRightChild;
}


// ---------------------------------------------------------------------------
//  CMBinaryOp: Implementation of the public CMNode virtual interface
// ---------------------------------------------------------------------------
bool CMBinaryOp::isNullable() const
{
    //
    //  If its an alternation, then if either child is nullable then
    //  this node is nullable. If its a concatenation, then both of
    //  them have to be nullable.
    //
    if (getType() == ContentSpecNode::Choice)
        return (fLeftChild->isNullable() || fRightChild->isNullable());

    return (fLeftChild->isNullable() && fRightChild->isNullable());
}


// ---------------------------------------------------------------------------
//  CMBinaryOp: Implementation of the protected CMNode virtual interface
// ---------------------------------------------------------------------------
void CMBinaryOp::calcFirstPos(CMStateSet& toSet) const
{
    if (getType() == ContentSpecNode::Choice)
    {
        // Its the the union of the first positions of our children.
        toSet = fLeftChild->getFirstPos();
        toSet |= fRightChild->getFirstPos();
    }
     else if (getType() == ContentSpecNode::Sequence)
    {
        //
        //  If our left child is nullable, then its the union of our
        //  children's first positions. Else is our left child's first
        //  positions.
        //
        toSet = fLeftChild->getFirstPos();
        if (fLeftChild->isNullable())
            toSet |= fRightChild->getFirstPos();
    }
}

void CMBinaryOp::calcLastPos(CMStateSet& toSet) const
{
    if (getType() == ContentSpecNode::Choice)
    {
        // Its the the union of the first positions of our children.
        toSet = fLeftChild->getLastPos();
        toSet |= fRightChild->getLastPos();
    }
     else if (getType() == ContentSpecNode::Sequence)
    {
        //
        //  If our right child is nullable, then its the union of our
        //  children's last positions. Else is our right child's last
        //  positions.
        //
        toSet = fRightChild->getLastPos();
        if (fRightChild->isNullable())
            toSet |= fLeftChild->getLastPos();
    }
}
