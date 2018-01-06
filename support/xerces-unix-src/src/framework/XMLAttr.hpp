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
 * $Log: XMLAttr.hpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:26  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.6  2000/04/10 22:42:53  roddey
 * Extended the buffer reuse to the QName field, to further increase
 * performance of attribute heavy applications.
 *
 * Revision 1.5  2000/03/02 19:54:24  roddey
 * This checkin includes many changes done while waiting for the
 * 1.1.0 code to be finished. I can't list them all here, but a list is
 * available elsewhere.
 *
 * Revision 1.4  2000/02/24 20:00:22  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.3  2000/02/15 01:21:30  roddey
 * Some initial documentation improvements. More to come...
 *
 * Revision 1.2  2000/02/06 07:47:47  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:28  twl
 * Initial checkin
 *
 * Revision 1.2  1999/11/08 20:44:35  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#if !defined(XMLATTR_HPP)
#define XMLATTR_HPP

#include <util/XMLString.hpp>
#include <framework/XMLAttDef.hpp>


/**
 *  This class defines the information about an attribute that will come out
 *  of the scanner during parsing. This information does not depend upon the
 *  type of validator because it is not tied to any scheme/DTD type info. Its
 *  just the raw XML 1.0 information that will be reported about an attribute
 *  in the startElement() callback method of the XMLDocumentHandler class.
 *  Hence it is not intended to be extended or derived from. Its designed to
 *  be used as is.
 *
 *  The 'specified' field of this class indicates whether the attribute was
 *  actually present or whether it was faulted in because it had a fixed or
 *  default value.
 *
 *  The code receiving this information can ask its validator for more info
 *  about the attribute, i.e. get its declaration from the DTD/Schema info.
 *
 *  Because of the heavy use (and reuse) of instances of this class, and the
 *  number of string members it has, this class takes pains to not reallocate
 *  string members unless it has to. It keeps up with how long each buffer
 *  is and only reallocates if the new value won't fit.
 */
class XMLPARSER_EXPORT XMLAttr
{
public:
    // -----------------------------------------------------------------------
    //  Constructors and Destructor
    // -----------------------------------------------------------------------
    /** @name Constructors */
    //@{

    /**
      * The default constructor just setsup an empty attribute to be filled
      * in the later. Though the initial state is a reasonable one, it is
      * not documented because it should not be depended on.
      */
    XMLAttr();

    /**
      * This is the primary constructor which takes all of the information
      * required to construct a complete attribute object.
      *
      * @param  uriId       The id into the validator's URI pool of the URI
      *                     that the prefix mapped to. Only used if namespaces
      *                     are enabled/supported.
      *
      * @param  attrName    The base name of the attribute, i.e. the part
      *                     after any prefix.
      *
      * @param  attrPrefix  The prefix, if any, of this attribute's name. If
      *                     this is empty, then uriID is meaningless as well.
      *
      * @param  attrValue   The value string of the attribute, which should
      *                     be fully normalized by XML rules!
      *
      * @param  type        The type of the attribute. This will indicate
      *                     the type of normalization done and constrains
      *                     the value content. Make sure that the value
      *                     set meets the constraints!
      *
      * @param  specified   Indicates whether the attribute was explicitly
      *                     specified or not. If not, then it was faulted
      *                     in from a FIXED or DEFAULT value.
      */
    XMLAttr
    (
        const   unsigned int        uriId
        , const XMLCh* const        attrName
        , const XMLCh* const        attrPrefix
        , const XMLCh* const        attrValue
        , const XMLAttDef::AttTypes type = XMLAttDef::CData
        , const bool                specified = true
    );
    //@}

    /** @name Destructor */
    //@{
    ~XMLAttr();
    //@}


    // -----------------------------------------------------------------------
    //  Getter methods
    // -----------------------------------------------------------------------

    /** @name Getter methods */
    //@{

    /**
      * This method gets a const pointer tot he name of the attribute. The
      * form of this name is defined by the validator in use.
      */
    const XMLCh* getName() const;

    /**
      * This method will get a const pointer to the prefix string of this
      * attribute. Since prefixes are optional, it may be zero.
      */
    const XMLCh* getPrefix() const;

    /**
      * This method will get the QName of this attribute, which will be the
      * prefix if any, then a colon, then the base name. If there was no
      * prefix, its the same as the getName() method.
      */
    const XMLCh* getQName() const;

    /**
      * This method will get the specified flag, which indicates whether
      * the attribute was explicitly specified or just faulted in.
      */
    bool getSpecified() const;

    /**
      * This method will get the type of the attribute. The available types
      * are defined by the XML specification.
      */
    XMLAttDef::AttTypes getType() const;

    /**
      * This method will get the value of the attribute. The value can be
      * be an empty string, but never null if the object is correctly
      * set up.
      */
    const XMLCh* getValue() const;

    /**
      * This method will get the id of the URI that this attribute's prefix
      * mapped to. If namespaces are not on, then its value is meaningless.
      */
    unsigned int getURIId() const;

    //@}


    // -----------------------------------------------------------------------
    //  Setter methods
    // -----------------------------------------------------------------------

    /** @name Setter methods */
    //@{

    /**
      * This method is called to set up a default constructed object after
      * the fact, or to reuse a previously used object.
      *
      * @param  uriId       The id into the validator's URI pool of the URI
      *                     that the prefix mapped to. Only used if namespaces
      *                     are enabled/supported.
      *
      * @param  attrName    The base name of the attribute, i.e. the part
      *                     after any prefix.
      *
      * @param  attrPrefix  The prefix, if any, of this attribute's name. If
      *                     this is empty, then uriID is meaningless as well.
      *
      * @param  attrValue   The value string of the attribute, which should
      *                     be fully normalized by XML rules according to the
      *                     attribute type.
      *
      * @param  type        The type of the attribute. This will indicate
      *                     the type of normalization done and constrains
      *                     the value content. Make sure that the value
      *                     set meets the constraints!
      *
      * @param  specified   Indicates whether the attribute was explicitly
      *                     specified or not. If not, then it was faulted
      *                     in from a FIXED or DEFAULT value.
      */
    void set
    (
        const   unsigned int        uriId
        , const XMLCh* const        attrName
        , const XMLCh* const        attrPrefix
        , const XMLCh* const        attrValue
        , const XMLAttDef::AttTypes type = XMLAttDef::CData
    );

    /**
      * This method will update just the name related fields of the
      * attribute object. The other fields are left as is.
      *
      * @param  uriId       The id into the validator's URI pool of the URI
      *                     that the prefix mapped to. Only used if namespaces
      *                     are enabled/supported.
      *
      * @param  attrName    The base name of the attribute, i.e. the part
      *                     after any prefix.
      *
      * @param  attrPrefix  The prefix, if any, of this attribute's name. If
      *                     this is empty, then uriID is meaningless as well.
      */
    void setName
    (
        const   unsigned int        uriId
        , const XMLCh* const        attrName
        , const XMLCh* const        attrPrefix
    );

    /**
      * This method will update the specified state of the object.
      *
      * @param  specified   Indicates whether the attribute was explicitly
      *                     specified or not. If not, then it was faulted
      *                     in from a FIXED or DEFAULT value.
      */
    void setSpecified(const bool newValue);

    /**
      * This method will update the attribute type of the object.
      *
      * @param  newType     The type of the attribute. This will indicate
      *                     the type of normalization done and constrains
      *                     the value content. Make sure that the value
      *                     set meets the constraints!
      */
    void setType(const XMLAttDef::AttTypes newType);

    /**
      * This method will update the value field of the attribute.
      *
      * @param  attrValue   The value string of the attribute, which should
      *                     be fully normalized by XML rules according to the
      *                     attribute type.
      */
    void setValue(const XMLCh* const newValue);

    /**
      * This method will set the URI id field of this attribute. This is
      * generally only ever called internally by the parser itself during
      * the parsing process.
      */
    void setURIId(const unsigned int uriId);

    //@}



private :
    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLAttr(const XMLAttr&);
    XMLAttr& operator=(const XMLAttr&);


    // -----------------------------------------------------------------------
    //  Private, helper methods
    // -----------------------------------------------------------------------
    void cleanUp();


    // -----------------------------------------------------------------------
    //  Private instance variables
    //
    //  fName
    //  fNameBufSz
    //      The base part of the name of the attribute, and the current size
    //      of the buffer (minus one, where the null is.)
    //
    //  fPrefix
    //  fPrefixBufSz
    //      The prefix that was applied to this attribute's name, and the
    //      current size of the buffer (minus one for the null.) Prefixes
    //      really don't matter technically but it might be required for
    //      pratical reasons, to recreate the original document for instance.
    //
    //  fQName
    //  fQNameBufSz
    //      This is the QName form of the name, which is faulted in (from the
    //      prefix and name) upon request. The size field indicates the
    //      current size of the buffer (minus one for the null.) It will be
    //      zero until fauled in.
    //
    //  fSpecified
    //      True if this attribute appeared in the element; else, false if
    //      it was defaulted from an AttDef.
    //
    //  fType
    //      The attribute type enum value for this attribute. Indicates what
    //      type of attribute it was.
    //
    //  fValue
    //  fValueBufSz
    //      The attribute value that was given in the attribute instance, and
    //      its current buffer size (minus one, where the null is.)
    //
    //  fURIId
    //      The id of the URI that this attribute belongs to.
    // -----------------------------------------------------------------------
    XMLCh*              fName;
    unsigned int        fNameBufSz;
    XMLCh*              fPrefix;
    unsigned int        fPrefixBufSz;
    XMLCh*              fQName;
    unsigned int        fQNameBufSz;
    bool                fSpecified;
    XMLAttDef::AttTypes fType;
    XMLCh*              fValue;
    unsigned int        fValueBufSz;
    unsigned int        fURIId;
};

// ---------------------------------------------------------------------------
//  XMLAttr: Constructors and Destructor
// ---------------------------------------------------------------------------
inline XMLAttr::~XMLAttr()
{
    cleanUp();
}


// ---------------------------------------------------------------------------
//  XMLAttr: Getter methods
// ---------------------------------------------------------------------------
inline const XMLCh* XMLAttr::getName() const
{
    return fName;
}

inline const XMLCh* XMLAttr::getPrefix() const
{
    return fPrefix;
}

inline bool XMLAttr::getSpecified() const
{
    return fSpecified;
}

inline XMLAttDef::AttTypes XMLAttr::getType() const
{
    return fType;
}

inline const XMLCh* XMLAttr::getValue() const
{
    return fValue;
}

inline unsigned int XMLAttr::getURIId() const
{
    return fURIId;
}


// ---------------------------------------------------------------------------
//  XMLAttr: Setter methods
// ---------------------------------------------------------------------------
inline void XMLAttr::set(const  unsigned int        uriId
                        , const XMLCh* const        attrName
                        , const XMLCh* const        attrPrefix
                        , const XMLCh* const        attrValue
                        , const XMLAttDef::AttTypes type)
{
    // Set the name info and the value via their respective calls
    setName(uriId, attrName, attrPrefix);
    setValue(attrValue);

    // And store the type
    fType = type;
}

inline void XMLAttr::setType(const XMLAttDef::AttTypes newValue)
{
    fType = newValue;
}

inline void XMLAttr::setSpecified(const bool newValue)
{
    fSpecified = newValue;
}

#endif
