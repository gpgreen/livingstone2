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
  * $Log: XMLDocumentHandler.hpp,v $
  * Revision 1.1.1.1  2000/04/08 04:37:54  kurien
  * XML parser for C++
  *
  *
  * Revision 1.7  2000/02/24 20:00:23  abagchi
  * Swat for removing Log from API docs
  *
  * Revision 1.6  2000/02/16 20:29:20  aruna1
  * API Doc++ summary changes in
  *
  * Revision 1.5  2000/02/16 19:48:56  roddey
  * More documentation updates
  *
  * Revision 1.4  2000/02/15 01:21:30  roddey
  * Some initial documentation improvements. More to come...
  *
  * Revision 1.3  2000/02/09 19:47:27  abagchi
  * Added docs for startElement
  *
  * Revision 1.2  2000/02/06 07:47:48  rahulj
  * Year 2K copyright swat.
  *
  * Revision 1.1.1.1  1999/11/09 01:08:31  twl
  * Initial checkin
  *
  * Revision 1.3  1999/11/08 20:44:37  rahul
  * Swat for adding in Product name and CVS comment log variable.
  *
  */


#if !defined(XMLDOCUMENTHANDLER_HPP)
#define XMLDOCUMENTHANDLER_HPP

#include <util/XML4CDefs.hpp>
#include <util/RefVectorOf.hpp>
#include <framework/XMLAttr.hpp>

class XMLElementDecl;
class XMLEntityDecl;

/**
  * This abstract class provides the interface for the scanner to return
  * XML document information up to the parser as it scans through the
  * document. 
  * 
  * The interface is very similar to org.sax.DocumentHandler, but
  * has some extra methods required to get all the data out.
  */
class XMLPARSER_EXPORT XMLDocumentHandler
{
public:
    // -----------------------------------------------------------------------
    //  Constructors are hidden, just the virtual destructor is exposed
    // -----------------------------------------------------------------------
    /** @name Destructor */
    //@{
    virtual ~XMLDocumentHandler()
    {
    }
    //@}

    /** @name The document handler interface */
    //@{
    /** Receive notification of character data.
      *
      * <p>The scanner will call this method to report each chunk of
      * character data. The scanner may return all contiguous character
      * data in a single chunk, or they may split it into several
      * chunks; however, all of the characters in any single event
      * will come from the same external entity, so that the Locator
      * provides useful information.</p>
      *
      * <p>The parser must not attempt to read from the array
      * outside of the specified range.</p>
      *
      * @param  chars           The content (characters) between markup from the XML
      *                         document.
      * @param  length          The number of characters to read from the array.
      * @param  cdataSection    Indicates that this data is inside a CDATA
      *                         section.
      * @see #ignorableWhitespace 
      * @see Locator
      */
    virtual void docCharacters
    (
        const   XMLCh* const    chars
        , const unsigned int    length
        , const bool            cdataSection
    ) = 0;

    /** Receive notification of comments in the XML content being parsed.
      *
      * This scanner will call this method for any comments found in the
      * content of the document.
      *
      * @param comment The text of the comment.
      */
    virtual void docComment
    (
        const   XMLCh* const    comment
    ) = 0;

    /** Receive notification of PI's parsed in the XML content.
      *
      * The scanner will call this method for any PIs it finds within the
      * content of the document.
      *
      * @param  target  The name of the PI.
      * @param  data    The body of the PI. This may be an empty string since
      *                 the body is optional.
      */
    virtual void docPI
    (
        const   XMLCh* const    target
        , const XMLCh* const    data
    ) = 0;

    /** Receive notification after the scanner has parsed the end of the
      * document.
      *
      * The scanner will call this method when the current document has been
      * fully parsed. The handler may use this opportunity to do something with
      * the data, clean up temporary data, etc...
      */
    virtual void endDocument() = 0;

    /** Receive notification of the end of an element.
      *
      * This method is called when scanner encounters the end of element tag.
      * There will be a corresponding startElement() event for every
      * endElement() event, but not necessarily the other way around. For
      * empty tags, there is only a startElement() call.
      *
      * @param  elementDecl The name of the element whose end tag was just
      *                     parsed.
      * @param  uriId       The ID of the URI in the URI pool (only valid if 
      *                     name spaces is enabled)
      * @param  isRoot      Indicates if this is the root element.
      */
    virtual void endElement
    (
        const   XMLElementDecl& elemDecl
        , const unsigned int    uriId
        , const bool            isRoot
    ) = 0;

    /** Receive notification when a referenced entity's content ends
      *
      * This method is called when scanner encounters the end of an entity
      * reference.
      *
      * @param  entityName  The name of the entity reference just scanned.
      */
    virtual void endEntityReference
    (
        const   XMLEntityDecl&  entDecl
    ) = 0;

    /** Receive notification of ignorable whitespace in element content.
      *
      * <p>Validating Parsers must use this method to report each chunk
      * of ignorable whitespace (see the W3C XML 1.0 recommendation,
      * section 2.10): non-validating parsers may also use this method
      * if they are capable of parsing and using content models.</p>
      *
      * <p>The scanner may return all contiguous whitespace in a single
      * chunk, or it may split it into several chunks; however, all of
      * the characters in any single event will come from the same
      * external entity, so that the Locator provides useful
      * information.</p>
      *
      * <p>The parser must not attempt to read from the array
      * outside of the specified range.</p>
      *
      * @param  chars       The whitespace characters from the XML document.
      * @param  length      The number of characters to read from the array.
      * @param  cdataSection Indicates that this data is inside a CDATA
      *                     section.
      * @see #characters
      */
    virtual void ignorableWhitespace
    (
        const   XMLCh* const    chars
        , const unsigned int    length
        , const bool            cdataSection
    ) = 0;

    /** Reset the document handler's state, if required
      *
      * This method is used to give the registered document handler a
      * chance to reset itself. Its called by the scanner at the start of
      * every parse.
      */
    virtual void resetDocument() = 0;

    /** Receive notification of the start of a new document
      *
      * This method is the first callback called the scanner at the
      * start of every parse. This is before any content is parsed.
      */
    virtual void startDocument() = 0;

    /** Receive notification of a new start tag
      *
      * This method is called when scanner encounters the start of an element tag.
      * All elements must always have a startElement() tag. Empty tags will
      * only have the startElement() tag and no endElement() tag.
      *
      * @param  elementDecl The name of the element whose start tag was just
      *                     parsed.
      * @param  uriId       The ID of the URI in the URI pool (only valid if 
      *                     name spaces is enabled)
      * @param  prefixName  The string representing the prefix name
      * @param  attrList    List of attributes in the element
      * @param  attrCount   Count of the attributes in the element
      * @param  isEmpty     Indicates if the element is empty, in which case
      *                     you should not expect an endElement() event.
      * @param  isRoot      Indicates if this is the root element.
      */
    virtual void startElement
    (
        const   XMLElementDecl&         elemDecl
        , const unsigned int            uriId
        , const XMLCh* const            prefixName
        , const RefVectorOf<XMLAttr>&   attrList
        , const unsigned int            attrCount
        , const bool                    isEmpty
        , const bool                    isRoot
    ) = 0;

    /** Receive notification when the scanner hits an entity reference.
      *
      * This is currently useful only to DOM parser configurations as SAX
      * does not provide any api to return this information.
      *
      * @param  entityName  The name of the entity that was referenced.
      */
    virtual void startEntityReference(const XMLEntityDecl& entDecl) = 0;

    /** Receive notification of an XML declaration
      *
      * Currently neither DOM nor SAX provide API's to return back this
      * information.
      *
      * @param  versionStr      The value of the <code>version</code> attribute
      *                         of the XML decl.
      * @param  encodingStr     The value of the <code>encoding</code> attribute
      *                         of the XML decl.
      * @param  standaloneStr   The value of the <code>standalone</code>
      *                         attribute of the XML decl.
      * @param  autoEncodingStr The encoding string auto-detected by the
      *                         scanner. In absence of any 'encoding' attribute in the
      *                         XML decl, the XML standard specifies how a parser can
      *                         auto-detect. If there is no <code>encodingStr</code>
      *                         this is what will be used to try to decode the file.
      */
    virtual void XMLDecl
    (
        const   XMLCh* const    versionStr
        , const XMLCh* const    encodingStr
        , const XMLCh* const    standaloneStr
        , const XMLCh* const    autoEncodingStr
    ) = 0;
    //@}



protected :
    // -----------------------------------------------------------------------
    //  Hidden Constructors
    // -----------------------------------------------------------------------
    XMLDocumentHandler()
    {
    }


private:
    // -----------------------------------------------------------------------
    //  Unimplemented constructors and operators
    // -----------------------------------------------------------------------
    XMLDocumentHandler(const XMLDocumentHandler&);
    void operator=(const XMLDocumentHandler&);
};

#endif
