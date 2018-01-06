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
 * $Log: ElemStack.cpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:56  kurien
 * XML parser for C++
 *
 *
 * Revision 1.4  2000/02/08 19:38:58  roddey
 * xmlns:xxx="" should affect the mapping of the prefixes of sibling attributes,
 * which was not being done.
 *
 * Revision 1.3  2000/02/06 07:47:52  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/01/19 00:55:45  roddey
 * Changes to get rid of dependence on old utils standard streams classes
 * and a small fix in the progressive parseFirst() call.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:04  twl
 * Initial checkin
 *
 * Revision 1.4  1999/11/08 20:44:41  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <memory.h>
#include <string.h>
#include <util/EmptyStackException.hpp>
#include <util/NoSuchElementException.hpp>
#include <framework/XMLElementDecl.hpp>
#include <internal/ElemStack.hpp>


// ---------------------------------------------------------------------------
//  ElemStack: Constructors and Destructor
// ---------------------------------------------------------------------------
ElemStack::ElemStack() :

    fEmptyNamespaceId(0)
    , fGlobalNamespaceId(0)
    , fGlobalPoolId(0)
    , fStack(0)
    , fStackCapacity(32)
    , fStackTop(0)
    , fUnknownNamespaceId(0)
    , fXMLNamespaceId(0)
    , fXMLPoolId(0)
    , fXMLNSNamespaceId(0)
    , fXMLNSPoolId(0)
{
    // Do an initial allocation of the stack and zero it out
    fStack = new StackElem*[fStackCapacity];
    memset(fStack, 0, fStackCapacity * sizeof(StackElem*));
}

ElemStack::~ElemStack()
{
    //
    //  Start working from the bottom of the stack and clear it out as we
    //  go up. Once we hit an uninitialized one, we can break out.
    //
    for (unsigned int stackInd = 0; stackInd < fStackCapacity; stackInd++)
    {
        // If this entry has been set, then lets clean it up
        if (!fStack[stackInd])
            break;

        // Delete the row for this entry, then delete the row structure
        delete [] fStack[stackInd]->fChildIds;
        delete fStack[stackInd];
    }

    // Delete the stack array itself now
    delete [] fStack;
}


// ---------------------------------------------------------------------------
//  ElemStack: Stack access
// ---------------------------------------------------------------------------
unsigned int ElemStack::addLevel()
{
    // See if we need to expand the stack
    if (fStackTop == fStackCapacity)
        expandStack();

    // If this element has not been initialized yet, then initialize it
    if (!fStack[fStackTop])
    {
        fStack[fStackTop] = new StackElem;
        fStack[fStackTop]->fChildCapacity = 0;
        fStack[fStackTop]->fChildIds = 0;
        fStack[fStackTop]->fMapCapacity = 0;
        fStack[fStackTop]->fMap = 0;
    }

    // Set up the new top row
    fStack[fStackTop]->fThisElement = 0;
    fStack[fStackTop]->fReaderNum = 0xFFFFFFFF;
    fStack[fStackTop]->fChildCount = 0;
    fStack[fStackTop]->fMapCount = 0;

    // Bump the top of stack
    fStackTop++;

    return fStackTop-1;
}


unsigned int
ElemStack::addLevel(XMLElementDecl* const toSet, const unsigned int readerNum)
{
    // See if we need to expand the stack
    if (fStackTop == fStackCapacity)
        expandStack();

    // If this element has not been initialized yet, then initialize it
    if (!fStack[fStackTop])
    {
        fStack[fStackTop] = new StackElem;
        fStack[fStackTop]->fChildCapacity = 0;
        fStack[fStackTop]->fChildIds = 0;
        fStack[fStackTop]->fMapCapacity = 0;
        fStack[fStackTop]->fMap = 0;
    }

    // Set up the new top row
    fStack[fStackTop]->fThisElement = 0;
    fStack[fStackTop]->fReaderNum = 0xFFFFFFFF;
    fStack[fStackTop]->fChildCount = 0;
    fStack[fStackTop]->fMapCount = 0;

    // And store the new stuff
    fStack[fStackTop]->fThisElement = toSet;
    fStack[fStackTop]->fReaderNum = readerNum;

    // Bump the top of stack
    fStackTop++;

    return fStackTop-1;
}



const XMLElementDecl& ElemStack::elemAt(const unsigned int index) const
{
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_EmptyStack);

    if (index >= fStack[fStackTop-1]->fChildCount)
        ThrowXML(ArrayIndexOutOfBoundsException, XML4CExcepts::ElemStack_BadIndex);

    return *(fStack[fStackTop-1]->fThisElement);
}


const ElemStack::StackElem* ElemStack::popTop()
{
    // Watch for an underflow error
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_StackUnderflow);

    fStackTop--;
    return fStack[fStackTop];
}


void
ElemStack::setElement(XMLElementDecl* const toSet, const unsigned int readerNum)
{
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_EmptyStack);

    fStack[fStackTop - 1]->fThisElement = toSet;
    fStack[fStackTop - 1]->fReaderNum = readerNum;
}


// ---------------------------------------------------------------------------
//  ElemStack: Stack top access
// ---------------------------------------------------------------------------
unsigned int ElemStack::addChild(const unsigned int childId, const bool toParent)
{
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_EmptyStack);

    //
    //  If they want to add to the parent, then we have to have at least two
    //  elements on the stack.
    //
    if (toParent && (fStackTop < 2))
        ThrowXML(NoSuchElementException, XML4CExcepts::ElemStack_NoParentPushed);

    // Get a convenience pointer to the stack top row
    StackElem* curRow = toParent
                        ? fStack[fStackTop - 2] : fStack[fStackTop - 1];

    // See if we need to expand this row's child array
    if (curRow->fChildCount == curRow->fChildCapacity)
    {
        // Increase the capacity by a quarter and allocate a new row
        const unsigned int newCapacity = curRow->fChildCapacity ? 
                                         (unsigned int)(curRow->fChildCapacity * 1.25) :
                                         32;
        unsigned int* newRow = new unsigned int[newCapacity];

        //
        //  Copy over the old contents. We don't have to initialize the new
        //  part because The current child count is used to know how much of
        //  it is valid.
        //
        //  Only both doing this if there is any current content, since
        //  this code also does the initial faulting in of the array when
        //  both the current capacity and child count are zero.
        //
        if (curRow->fChildCount)
        {
            memcpy
            (
                newRow
                , curRow->fChildIds
                , curRow->fChildCapacity * sizeof(unsigned int)
            );
        }

        // Clean up the old children and store the new info
        delete [] curRow->fChildIds;
        curRow->fChildIds = newRow;
        curRow->fChildCapacity = newCapacity;
    }

    // Add this id to the end of the row's child id array and bump the count
    curRow->fChildIds[curRow->fChildCount++] = childId;

    // Return the level of the index we just filled (before the bump)
    return curRow->fChildCount - 1;
}

const ElemStack::StackElem* ElemStack::topElement() const
{
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_EmptyStack);

    return fStack[fStackTop - 1];
}


// ---------------------------------------------------------------------------
//  ElemStack: Prefix map methods
// ---------------------------------------------------------------------------
void ElemStack::addPrefix(  const   XMLCh* const    prefixToAdd
                            , const unsigned int    uriId)
{
    if (!fStackTop)
        ThrowXML(EmptyStackException, XML4CExcepts::ElemStack_EmptyStack);

    // Get a convenience pointer to the stack top row
    StackElem* curRow = fStack[fStackTop - 1];

    // Map the prefix to its unique id
    const unsigned int prefId = fPrefixPool.addOrFind(prefixToAdd);

    //
    //  Add a new element to the prefix map for this element. If its full,
    //  then expand it out.
    //
    if (curRow->fMapCount == curRow->fMapCapacity)
        expandMap(curRow);

    //
    //  And now add a new element for this prefix. Watch for the special case
    //  of xmlns=="", and force it to ""=[globalid]
    //
    curRow->fMap[curRow->fMapCount].fPrefId = prefId;
    if ((prefId == fGlobalPoolId) && (uriId == fEmptyNamespaceId))
        curRow->fMap[curRow->fMapCount].fURIId = fGlobalNamespaceId;
    else
        curRow->fMap[curRow->fMapCount].fURIId = uriId;

    // Bump the map count now
    curRow->fMapCount++;
}


unsigned int ElemStack::mapPrefixToURI( const   XMLCh* const    prefixToMap
                                        , const MapModes        mode
                                        ,       bool&           unknown) const
{
    // Assume we find it
    unknown = false;

    //
    //  Map the prefix to its unique id, from the prefix string pool. If its
    //  not a valid prefix, then its a failure.
    //
    unsigned int prefixId = fPrefixPool.getId(prefixToMap);
    if (!prefixId)
    {
        unknown = true;
        return fUnknownNamespaceId;
    }

    //
    //  If the prefix is empty, and we are in attribute mode, then we assign
    //  it to the global namespace because the default namespace does not
    //  apply to attributes.
    //
    if (!*prefixToMap && (mode == Mode_Attribute))
        return fGlobalNamespaceId;

    //
    //  Check for the special prefixes 'xml' and 'xmlns' since they cannot
    //  be overridden.
    //
    if (prefixId == fXMLPoolId)
        return fXMLNamespaceId;
    else if (prefixId == fXMLNSPoolId)
        return fXMLNSNamespaceId;

    //
    //  Start at the stack top and work backwards until we come to some
    //  element that mapped this prefix.
    //
    int startAt = (int)(fStackTop - 1);
    for (int index = startAt; index >= 0; index--)
    {
        // Get a convenience pointer to the current element
        StackElem* curRow = fStack[index];

        // If no prefixes mapped at this level, then go the next one
        if (!curRow->fMapCount)
            continue;

        // Search the map at this level for the passed prefix
        for (unsigned int mapIndex = 0; mapIndex < curRow->fMapCount; mapIndex++)
        {
            if (curRow->fMap[mapIndex].fPrefId == prefixId)
                return curRow->fMap[mapIndex].fURIId;
        }
    }

    //
    //  If the prefix is an empty string, then we will return the special
    //  global namespace id. This can be overridden, but no one has or we
    //  would have not gotten here.
    //
    if (!*prefixToMap)
        return fGlobalNamespaceId;

    // Oh well, don't have a clue so return the unknown id
    unknown = true;
    return fUnknownNamespaceId;
}


// ---------------------------------------------------------------------------
//  ElemStack: Miscellaneous methods
// ---------------------------------------------------------------------------
void ElemStack::reset(  const   unsigned int    emptyId
                        , const unsigned int    globalId
                        , const unsigned int    unknownId
                        , const unsigned int    xmlId
                        , const unsigned int    xmlNSId)
{
    // Flush the prefix pool and put back in the standard prefixes
    fPrefixPool.flushAll();
    fGlobalPoolId = fPrefixPool.addOrFind(XMLUni::fgZeroLenString);
    fXMLPoolId = fPrefixPool.addOrFind(XMLUni::fgXMLString);
    fXMLNSPoolId = fPrefixPool.addOrFind(XMLUni::fgXMLNSString);

    // Reset the stack top to clear the stack
    fStackTop = 0;

    // And store the new special URI ids
    fEmptyNamespaceId = emptyId;
    fGlobalNamespaceId = globalId;
    fUnknownNamespaceId = unknownId;
    fXMLNamespaceId = xmlId;
    fXMLNSNamespaceId = xmlNSId;
}


// ---------------------------------------------------------------------------
//  ElemStack: Private helpers
// ---------------------------------------------------------------------------
void ElemStack::expandMap(StackElem* const toExpand)
{
    // For convenience get the old map size
    const unsigned int oldCap = toExpand->fMapCapacity;

    //
    //  Expand the capacity by 25%, or initialize it to 16 if its currently
    //  empty. Then allocate a new temp buffer.
    //
    const unsigned int newCapacity = oldCap ?
                                     (unsigned int)(oldCap * 1.25) : 16;
    PrefMapElem* newMap = new PrefMapElem[newCapacity];

    //
    //  Copy over the old stuff. We DON'T have to zero out the new stuff
    //  since this is a by value map and the current map index controls what
    //  is relevant.
    //
    memcpy(newMap, toExpand->fMap, oldCap * sizeof(PrefMapElem));

    // Delete the old map and store the new stuff
    delete [] toExpand->fMap;
    toExpand->fMap = newMap;
    toExpand->fMapCapacity = newCapacity;
}

void ElemStack::expandStack()
{
    // Expand the capacity by 25% and allocate a new buffer
    const unsigned int newCapacity = (unsigned int)(fStackCapacity * 1.25);
    StackElem** newStack = new StackElem*[newCapacity];

    // Copy over the old stuff
    memcpy(newStack, fStack, fStackCapacity * sizeof(StackElem*));

    //
    //  And zero out the new stuff. Though we use a stack top, we reuse old
    //  stack contents so we need to know if elements have been initially
    //  allocated or not as we push new stuff onto the stack.
    //
    memset
    (
        &newStack[fStackCapacity]
        , 0
        , (newCapacity - fStackCapacity) * sizeof(StackElem*)
    );

    // Delete the old array and update our members
    delete [] fStack;
    fStack = newStack;
    fStackCapacity = newCapacity;
}
