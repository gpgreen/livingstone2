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
 * $Log: DTDAttDef.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:57  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.3  2000/02/24 20:16:48  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.2  2000/02/09 21:42:37  abagchi
 * Copyright swat
 *
 * Revision 1.1.1.1  1999/11/09 01:03:26  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:45:39  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#if !defined(DTDATTDEF_HPP)
#define DTDATTDEF_HPP

#include <util/XMLString.hpp>
#include <framework/XMLAttDef.hpp>


//
//  This class is a derivative of the core XMLAttDef class. This class adds
//  any DTD specific data members and provides DTD specific implementations
//  of any underlying attribute def virtual methods.
//
//  In the DTD we don't do namespaces, so the attribute names are just the
//  QName literally from the DTD. This is what we return as the full name,
//  which is what is used to key these in any name keyed collections.
//
class VALIDATORS_EXPORT DTDAttDef : public XMLAttDef
{
public :
    // -----------------------------------------------------------------------
    //  Constructors and Destructors
    // -----------------------------------------------------------------------
    DTDAttDef();
    DTDAttDef
    (
        const   XMLCh* const            attName
        , const XMLAttDef::AttTypes     type = CData
        , const XMLAttDef::DefAttTypes  defType = Implied
    );
    DTDAttDef
    (
        const   XMLCh* const            attName
        , const XMLCh* const            attValue
        , const XMLAttDef::AttTypes     type
        , const XMLAttDef::DefAttTypes  defType
        , const XMLCh* const            enumValues = 0
    );
    ~DTDAttDef();


    // -----------------------------------------------------------------------
    //  Implementation of the XMLAttDef interface
    // -----------------------------------------------------------------------
    virtual const XMLCh* getFullName() const;


    // -----------------------------------------------------------------------
    //  Getter methods
    // -----------------------------------------------------------------------
    unsigned int getElemId() const;


    // -----------------------------------------------------------------------
    //  Setter methods
    // -----------------------------------------------------------------------
    void setElemId(const unsigned int newId);
    void setName(const XMLCh* const newName);


private :
    // -----------------------------------------------------------------------
    //  Private data members
    //
    //  fElemId
    //      This is the id of the element (the id is into the element decl
    //      pool) of the element this attribute def said it belonged to.
    //      This is used later to link back to the element, mostly for
    //      validation purposes.
    //
    //  fName
    //      This is the name of the attribute. Since we don't do namespaces
    //      in the DTD, its just the fully qualified name.
    // -----------------------------------------------------------------------
    unsigned int    fElemId;
    XMLCh*          fName;
};


// ---------------------------------------------------------------------------
//  DTDAttDef: Implementation of the XMLAttDef interface
// ---------------------------------------------------------------------------
inline const XMLCh* DTDAttDef::getFullName() const
{
    return fName;
}


// ---------------------------------------------------------------------------
//  DTDAttDef: Getter methods
// ---------------------------------------------------------------------------
inline unsigned int DTDAttDef::getElemId() const
{
    return fElemId;
}


// ---------------------------------------------------------------------------
//  DTDAttDef: Setter methods
// ---------------------------------------------------------------------------
inline void DTDAttDef::setElemId(const unsigned int newId)
{
    fElemId = newId;
}

#endif
