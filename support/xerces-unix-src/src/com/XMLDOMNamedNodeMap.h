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
 * $Log: XMLDOMNamedNodeMap.h,v $
 * Revision 1.1.1.1  2000/09/20 20:40:13  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.3  2000/06/03 00:29:00  andyh
 * COM Wrapper changes from Curt Arnold
 *
 * Revision 1.2  2000/03/30 02:00:10  abagchi
 * Initial checkin of working code with Copyright Notice
 *
 */

#ifndef ___xmldomnamednodemap_h___
#define ___xmldomnamednodemap_h___

#include <dom/DOM_NamedNodeMap.hpp>
#include "NodeContainerImpl.h"

class ATL_NO_VTABLE CXMLDOMNamedNodeMap : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public IDispatchImpl<IXMLDOMNamedNodeMap, &IID_IXMLDOMNamedNodeMap, &LIBID_Xerces>,
	public NodeContainerImpl<DOM_NamedNodeMap>
{
public:
	CXMLDOMNamedNodeMap()
	{}

	void FinalRelease()
	{
		ReleaseOwnerDoc();
	}

DECLARE_NOT_AGGREGATABLE(CXMLDOMNamedNodeMap)
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CXMLDOMNamedNodeMap)
	COM_INTERFACE_ENTRY(IXMLDOMNamedNodeMap)
	COM_INTERFACE_ENTRY(IDispatch)
END_COM_MAP()
  
	// IXMLDOMNamedNodeMap methods
	STDMETHOD(getNamedItem)(BSTR name, IXMLDOMNode  * *namedItem);
	STDMETHOD(setNamedItem)(IXMLDOMNode  *newItem, IXMLDOMNode  * *nameItem);
	STDMETHOD(removeNamedItem)(BSTR name, IXMLDOMNode  * *namedItem);
	STDMETHOD(get_item)(long index, IXMLDOMNode  * *pVal);
	STDMETHOD(get_length)(long  *pVal);
	STDMETHOD(getQualifiedItem)(BSTR baseName, BSTR namespaceURI, IXMLDOMNode  * *node);
	STDMETHOD(removeQualifiedItem)(BSTR baseName, BSTR namespaceURI, IXMLDOMNode  * *node);
	STDMETHOD(nextNode)(IXMLDOMNode  * *nextItem);
	STDMETHOD(reset)();
	STDMETHOD(get__newEnum)(IUnknown  * *pVal);
};

typedef CComObject<CXMLDOMNamedNodeMap> CXMLDOMNamedNodeMapObj;

#endif // ___xmldomnamednodemap_h___