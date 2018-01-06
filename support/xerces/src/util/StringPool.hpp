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
 * $Log: StringPool.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:38:06  kurien
 * XML parser for C++
 *
 *
 * Revision 1.3  2000/02/24 20:05:25  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.2  2000/02/06 07:48:04  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:05:11  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:15  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#if !defined(STRINGPOOL_HPP)
#define STRINGPOOL_HPP

#include <util/RefHashTableOf.hpp>

//
//  This class implements a string pool, in which strings can be added and
//  given a unique id by which they can be refered. It has to provide fast
//  access both mapping from a string to its id and mapping from an id to
//  its string. This requires that it provide two separate data structures.
//  The map one is a hash table for quick storage and look up by name. The
//  other is an array ordered by unique id which maps to the element in the
//  hash table.
//
//  This works because strings cannot be removed from the pool once added,
//  other than flushing it completely, and because ids are assigned
//  sequentially from 1.
//
class XMLUTIL_EXPORT XMLStringPool
{
public :
    // -----------------------------------------------------------------------
    //  Constructors and Destructor
    // -----------------------------------------------------------------------
    XMLStringPool
    (
        const   unsigned int    modulus = 109
    );
    ~XMLStringPool();


    // -----------------------------------------------------------------------
    //  Pool management methods
    // -----------------------------------------------------------------------
    unsigned int addOrFind(const XMLCh* const newString);
    bool exists(const XMLCh* const newString) const;
    void flushAll();
    unsigned int getId(const XMLCh* const toFind) const;
    const XMLCh* getValueForId(const unsigned int id) const;


private :
    // -----------------------------------------------------------------------
    //  Private data types
    // -----------------------------------------------------------------------
    class PoolElem
    {
        public :
            PoolElem(const XMLCh* const string, const unsigned int id);
            ~PoolElem();

            const XMLCh* getKey() const;
            void reset(const XMLCh* const string, const unsigned int id);

            unsigned int    fId;
            XMLCh*          fString;
    };


    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLStringPool(const XMLStringPool&);
    void operator=(const XMLStringPool&);


    // -----------------------------------------------------------------------
    //  Private helper methods
    // -----------------------------------------------------------------------
    unsigned int addNewEntry(const XMLCh* const newString);


    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fIdMap
    //      This is an array of pointers to the pool elements. It is ordered
    //      by unique id, so using an id to index it gives instant access to
    //      the string of that id. This is grown as required.
    //
    //  fHashTable
    //      This is the hash table used to store and quickly access the
    //      strings.
    //
    //  fMapCapacity
    //      The current capacity of the id map. When the current id hits this
    //      value the map must must be expanded.
    //
    //  fCurId
    //      This is the counter used to assign unique ids. It is just bumped
    //      up one for each new string added.
    // -----------------------------------------------------------------------
    PoolElem**                  fIdMap;
    RefHashTableOf<PoolElem>*   fHashTable;
    unsigned int                fMapCapacity;
    unsigned int                fCurId;
};

#endif
