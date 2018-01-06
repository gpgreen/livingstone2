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
 * $Log: DOM_DOMImplementation.hpp,v $
 * Revision 1.1.1.1  2000/04/08 04:37:45  kurien
 * XML parser for C++
 *
 *
 * Revision 1.6  2000/02/24 20:11:27  abagchi
 * Swat for removing Log from API docs
 *
 * Revision 1.5  2000/02/17 17:47:24  andyh
 * Update Doc++ API comments
 * NameSpace update to track W3C
 * Changes were made by Chih Hsiang Chou
 *
 * Revision 1.4  2000/02/10 23:35:11  andyh
 * Update DOM_DOMImplementation::CreateDocumentType and
 * DOM_DocumentType to match latest from W3C
 *
 * Revision 1.3  2000/02/06 07:47:28  rahulj
 * Year 2K copyright swat.
 *
 * Revision 1.2  2000/01/05 01:16:07  andyh
 * DOM Level 2 core, namespace support added.
 *
 * Revision 1.1.1.1  1999/11/09 01:08:57  twl
 * Initial checkin
 *
 * Revision 1.3  1999/11/08 20:44:15  rahul
 * Swat for adding in Product name and CVS comment log variable.
 *
 */

#ifndef DOMImplementation_HEADER_GUARD_
#define DOMImplementation_HEADER_GUARD_

#include <util/XML4CDefs.hpp>
#include <dom/DOMString.hpp>

class DOM_Document;
class DOM_DocumentType;

/**
 *   This class provides a way to query the capabilities of an implementation
 *   of the DOM
 */


class CDOM_EXPORT DOM_DOMImplementation {
 private:
    DOM_DOMImplementation(const DOM_DOMImplementation &other);

 public:
/** @name Constructors and assignment operators */
//@{  
 /**
   * Construct a DOM_Implementation reference variable, which should
   * be assigned to the return value from 
   * <code>DOM_Implementation::getImplementation()</code>.
   */
    DOM_DOMImplementation();

 /**
   * Assignment operator
   *
   */
    DOM_DOMImplementation & operator = (const DOM_DOMImplementation &other);
//@}

  /** @name Destructor */
  //@{  
  /**
    * Destructor.  The object being destroyed is a reference to the DOMImplemenentation,
    * not the underlying DOMImplementation object itself, which is owned by
    * the implementation code.
    *
    */

    ~DOM_DOMImplementation();
	//@}

  /** @name Getter functions */
  //@{

 /**
   * Test if the DOM implementation implements a specific feature.
   *
   * @param feature The string of the feature to test (case-insensitive). The legal 
   *        values are defined throughout this specification. The string must be 
   *        an <EM>XML name</EM> (see also Compliance).
   * @param version This is the version number of the package name to test.  
   *   In Level 1, this is the string "1.0". If the version is not specified, 
   *   supporting any version of the  feature will cause the method to return 
   *   <code>true</code>. 
   * @return <code>true</code> if the feature is implemented in the specified 
   *   version, <code>false</code> otherwise.
   */
 bool  hasFeature(const DOMString &feature,  const DOMString &version);


  /** Return a reference to a DOM_Implementation object for this 
    *  DOM implementation. 
    *
    * Intended to support applications that may be
    * using DOMs retrieved from several different sources, potentially
    * with different underlying implementations.
    */
 static DOM_DOMImplementation &getImplementation();
  
 //@}

    /** @name Functions introduced in DOM Level 2. */
    //@{
    /**
     * Creates an empty <code>DOM_DocumentType</code> node.
     * Entity declarations and notations are not made available.
     * Entity reference expansions and default attribute additions
     * do not occur. It is expected that a future version of the DOM
     * will provide a way for populating a <code>DOM_DocumentType</code>.
     *
     * <p><b>"Experimental - subject to change"</b></p>
     *
     * @param qualifiedName The <em>qualified name</em>
     * of the document type to be created.
     * @param publicId The external subset public identifier.
     * @param systemId The external subset system identifier.
     * @return A new <code>DOM_DocumentType</code> node with
     * <code>Node.ownerDocument</code> set to <code>null</code>.
     * @exception DOMException
     *   INVALID_CHARACTER_ERR: Raised if the specified qualified name
     *      contains an illegal character.
     * <br>
     *   NAMESPACE_ERR: Raised if the <code>qualifiedName</code> is malformed.
     */
    DOM_DocumentType createDocumentType(const DOMString &qualifiedName,
	const DOMString &publicId, const DOMString &systemId);

    /**
     * Creates an XML <code>DOM_Document</code> object of the specified type
     * with its document element.
     *
     * <p><b>"Experimental - subject to change"</b></p>
     *
     * @param namespaceURI The <em>namespace URI</em> of
     * the document element to create, or <code>null</code>.
     * @param qualifiedName The <em>qualified name</em>
     * of the document element to be created.
     * @param doctype The type of document to be created or <code>null</code>.
     * <p>When <code>doctype</code> is not <code>null</code>, its
     * <code>Node.ownerDocument</code> attribute is set to the document
     * being created.
     * @return A new <code>DOM_Document</code> object.
     * @exception DOMException
     *   INVALID_CHARACTER_ERR: Raised if the specified qualified name
     *      contains an illegal character.
     * <br>
     *   NAMESPACE_ERR: Raised if the <CODE>qualifiedName</CODE> is 
     *      malformed, or if the <CODE>qualifiedName</CODE> has a prefix that is 
     *      "xml" and the <CODE>namespaceURI</CODE> is different from 
     *      "http://www.w3.org/XML/1998/namespace".
     * <br>
     *   WRONG_DOCUMENT_ERR: Raised if <code>doctype</code> has already
     *   been used with a different document.
     */
    DOM_Document createDocument(const DOMString &namespaceURI,
	const DOMString &qualifiedName, const DOM_DocumentType &doctype);
    //@}

};

#endif
