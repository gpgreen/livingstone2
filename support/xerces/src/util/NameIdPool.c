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
 * $Log: NameIdPool.c,v $
 * Revision 1.1.1.1  2000/04/08 04:38:05  kurien
 * XML parser for C++
 *
 *
 * Revision 1.2  2000/02/06 07:48:02  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:04:47  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:45:10  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#if defined(XML4C_TMPLSINC)
#include <util/NameIdPool.hpp>
#endif

#include <util/IllegalArgumentException.hpp>
#include <util/NoSuchElementException.hpp>
#include <util/RuntimeException.hpp>



// ---------------------------------------------------------------------------
//  NameIdPoolBucketElem: Constructors and Destructor
// ---------------------------------------------------------------------------
template <class TElem> NameIdPoolBucketElem<TElem>::
NameIdPoolBucketElem(TElem* const                           value
                    , NameIdPoolBucketElem<TElem>* const    next) :
    fData(value)
    , fNext(next)
{
}

template <class TElem> NameIdPoolBucketElem<TElem>::~NameIdPoolBucketElem()
{
    // Nothing to do
}


// ---------------------------------------------------------------------------
//  NameIdPool: Constructors and Destructor
// ---------------------------------------------------------------------------
template <class TElem>
NameIdPool<TElem>::NameIdPool(  const   unsigned int    hashModulus
                                , const unsigned int    initSize) :
    fBucketList(0)
    , fIdPtrs(0)
    , fIdPtrsCount(initSize)
    , fIdCounter(0)
    , fHashModulus(hashModulus)
{
    if (!fHashModulus)
        ThrowXML(IllegalArgumentException, XML4CExcepts::Pool_ZeroModulus);

    // Allocate the bucket list and zero them
    fBucketList = new NameIdPoolBucketElem<TElem>*[fHashModulus];
    for (unsigned int index = 0; index < fHashModulus; index++)
        fBucketList[index] = 0;

    //
    //  Allocate the initial id pointers array. We don't have to zero them
    //  out since the fIdCounter value tells us which ones are valid. The
    //  zeroth element is never used (and represents an invalid pool id.)
    //
    if (!fIdPtrsCount)
        fIdPtrsCount = 256;
    fIdPtrs = new TElem*[fIdPtrsCount];
    fIdPtrs[0] = 0;
}

template <class TElem> NameIdPool<TElem>::~NameIdPool()
{
    //
    //  Delete the id pointers list. The stuff it points to will be cleaned
    //  up when we clean the bucket lists.
    //
    delete [] fIdPtrs;

    // Remove all elements then delete the bucket list
    removeAll();
    delete [] fBucketList;
}


// ---------------------------------------------------------------------------
//  NameIdPool: Element management
// ---------------------------------------------------------------------------
template <class TElem> bool
NameIdPool<TElem>::containsKey(const XMLCh* const key) const
{
    unsigned int hashVal;
    const NameIdPoolBucketElem<TElem>* findIt = findBucketElem(key, hashVal);
    return (findIt != 0);
}


template <class TElem> void NameIdPool<TElem>::removeAll()
{
    // Clean up the buckets first
    for (unsigned int buckInd = 0; buckInd < fHashModulus; buckInd++)
    {
        NameIdPoolBucketElem<TElem>* curElem = fBucketList[buckInd];
        NameIdPoolBucketElem<TElem>* nextElem;
        while (curElem)
        {
            // Save the next element before we hose this one
            nextElem = curElem->fNext;

            delete curElem->fData;
            delete curElem;

            curElem = nextElem;
        }

        // Empty out the bucket
        fBucketList[buckInd] = 0;
    }

    // Reset the id counter
    fIdCounter = 0;
}


// ---------------------------------------------------------------------------
//  NameIdPool: Getters
// ---------------------------------------------------------------------------
template <class TElem> TElem*
NameIdPool<TElem>::getByKey(const XMLCh* const key)
{
    unsigned int hashVal;
    NameIdPoolBucketElem<TElem>* findIt = findBucketElem(key, hashVal);
    if (!findIt)
        return 0;
    return findIt->fData;
}

template <class TElem> const TElem*
NameIdPool<TElem>::getByKey(const XMLCh* const key) const
{
    unsigned int hashVal;
    const NameIdPoolBucketElem<TElem>* findIt = findBucketElem(key, hashVal);
    if (!findIt)
        return 0;
    return findIt->fData;
}

template <class TElem> TElem*
NameIdPool<TElem>::getById(const unsigned int elemId)
{
    // If its either zero or beyond our current id, its an error
    if (!elemId || (elemId > fIdCounter))
        ThrowXML(IllegalArgumentException, XML4CExcepts::Pool_InvalidId);

    return fIdPtrs[elemId];
}

template <class TElem>
const TElem* NameIdPool<TElem>::getById(const unsigned int elemId) const
{
    // If its either zero or beyond our current id, its an error
    if (!elemId || (elemId > fIdCounter))
        ThrowXML(IllegalArgumentException, XML4CExcepts::Pool_InvalidId);

    return fIdPtrs[elemId];
}



// ---------------------------------------------------------------------------
//  NameIdPool: Setters
// ---------------------------------------------------------------------------
template <class TElem>
unsigned int NameIdPool<TElem>::put(TElem* const elemToAdopt)
{
    // First see if the key exists already. If so, its an error
    unsigned int hashVal;
    if (findBucketElem(elemToAdopt->getKey(), hashVal))
    {
        ThrowXML1
        (
            IllegalArgumentException
            , XML4CExcepts::Pool_ElemAlreadyExists
            , elemToAdopt->getKey()
        );
    }

    // Create a new bucket element and add it to the appropriate list
    NameIdPoolBucketElem<TElem>* newBucket = new NameIdPoolBucketElem<TElem>
    (
        elemToAdopt
        , fBucketList[hashVal]
    );
    fBucketList[hashVal] = newBucket;

    //
    //  Give this new one the next available id and add to the pointer list.
    //  Expand the list if that is now required.
    //
    if (fIdCounter + 1 == fIdPtrsCount)
    {
        // Create a new count 1.5 times larger and allocate a new array
        unsigned int newCount = (unsigned int)(fIdPtrsCount * 1.5);
        TElem** newArray = new TElem*[newCount];

        // Copy over the old contents to the new array
        memcpy(newArray, fIdPtrs, fIdPtrsCount * sizeof(TElem*));

        // Ok, toss the old array and store the new data
        delete [] fIdPtrs;
        fIdPtrs = newArray;
        fIdPtrsCount = newCount;
    }
    const unsigned int retId = ++fIdCounter;
    fIdPtrs[retId] = elemToAdopt;

    // Set the id on the passed element
    elemToAdopt->setId(retId);

    // Return the id that we gave to this element
    return retId;
}


// ---------------------------------------------------------------------------
//  NameIdPool: Private methods
// ---------------------------------------------------------------------------
template <class TElem>
NameIdPoolBucketElem<TElem>* NameIdPool<TElem>::
findBucketElem(const XMLCh* const key, unsigned int& hashVal)
{
    // Hash the key
    hashVal = XMLString::hash(key, fHashModulus);

    if (hashVal > fHashModulus)
        ThrowXML(RuntimeException, XML4CExcepts::Pool_BadHashFromKey);

    // Search that bucket for the key
    NameIdPoolBucketElem<TElem>* curElem = fBucketList[hashVal];
    while (curElem)
    {
        if (!XMLString::compareString(key, curElem->fData->getKey()))
            return curElem;
        curElem = curElem->fNext;
    }
    return 0;
}

template <class TElem>
const NameIdPoolBucketElem<TElem>* NameIdPool<TElem>::
findBucketElem(const XMLCh* const key, unsigned int& hashVal) const
{
    // Hash the key
    hashVal = XMLString::hash(key, fHashModulus);

    if (hashVal > fHashModulus)
        ThrowXML(RuntimeException, XML4CExcepts::Pool_BadHashFromKey);

    // Search that bucket for the key
    const NameIdPoolBucketElem<TElem>* curElem = fBucketList[hashVal];
    while (curElem)
    {
        if (!XMLString::compareString(key, curElem->fData->getKey()))
            return curElem;

        curElem = curElem->fNext;
    }
    return 0;
}



// ---------------------------------------------------------------------------
//  NameIdPoolEnumerator: Constructors and Destructor
// ---------------------------------------------------------------------------
template <class TElem> NameIdPoolEnumerator<TElem>::
NameIdPoolEnumerator(NameIdPool<TElem>* const toEnum) :

    fCurIndex(0)
    , fToEnum(toEnum)
{
    //
    //  Find the next available bucket element in the pool. We use the id
    //  array since its very easy to enumerator through by just maintaining
    //  an index. If the id counter is zero, then its empty and we leave the
    //  current index to zero.
    //
    if (toEnum->fIdCounter)
        fCurIndex = 1;
}

template <class TElem> NameIdPoolEnumerator<TElem>::
NameIdPoolEnumerator(const NameIdPoolEnumerator<TElem>& toCopy) :

    fCurIndex(toCopy.fCurIndex)
    , fToEnum(toCopy.fToEnum)
{
}

template <class TElem> NameIdPoolEnumerator<TElem>::~NameIdPoolEnumerator()
{
    // We don't own the pool being enumerated, so no cleanup required
}


// ---------------------------------------------------------------------------
//  NameIdPoolEnumerator: Public operators
// ---------------------------------------------------------------------------
template <class TElem> NameIdPoolEnumerator<TElem>& NameIdPoolEnumerator<TElem>::
operator=(const NameIdPoolEnumerator<TElem>& toAssign)
{
    if (this == &toAssign)
        return *this;

    fCurIndex   = toAssign.fCurIndex;
    fToEnum     = toAssign.fToEnum;
    return *this;
}


// ---------------------------------------------------------------------------
//  NameIdPoolEnumerator: Enum interface
// ---------------------------------------------------------------------------
template <class TElem> bool NameIdPoolEnumerator<TElem>::
hasMoreElements() const
{
    // If our index is zero or past the end, then we are done
    if (!fCurIndex || (fCurIndex > fToEnum->fIdCounter))
        return false;
    return true;
}

template <class TElem> TElem& NameIdPoolEnumerator<TElem>::nextElement()
{
    // If our index is zero or past the end, then we are done
    if (!fCurIndex || (fCurIndex > fToEnum->fIdCounter))
        ThrowXML(NoSuchElementException, XML4CExcepts::Enum_NoMoreElements);

    // Return the current element and bump the index
    return *fToEnum->fIdPtrs[fCurIndex++];
}


template <class TElem> void NameIdPoolEnumerator<TElem>::Reset()
{
    fCurIndex = 0;
}
