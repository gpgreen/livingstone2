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
 * $Log: XMLDOMDocument.h,v $
 * Revision 1.1.1.1  2000/09/20 20:40:12  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.4  2000/06/19 20:05:58  rahulj
 * Changes for increased conformance and stability. Submitted by
 * Curt.Arnold@hyprotech.com. Verified by Joe Polastre.
 *
 * Revision 1.3  2000/06/03 00:28:57  andyh
 * COM Wrapper changes from Curt Arnold
 *
 * Revision 1.2  2000/03/30 02:00:11  abagchi
 * Initial checkin of working code with Copyright Notice
 *
 */

#ifndef ___xmldomdocument_h___
#define ___xmldomdocument_h___

#include <dom/DOM_Document.hpp>
#include "IXMLDOMNodeImpl.h"

#include "resource.h"       // main symbols
#include "XMLDOMParseError.h"

#include <sax/ErrorHandler.hpp>
#include "xml4comCP.h"

class SAXParseException;

class ATL_NO_VTABLE CXMLDOMDocument : 
	public CComObjectRootEx<CComSingleThreadModel>,
	public CComCoClass<CXMLDOMDocument, &CLSID_DOMDocument>,
	public IObjectSafetyImpl<CXMLDOMDocument, INTERFACESAFE_FOR_UNTRUSTED_CALLER>,
	public IXMLDOMNodeImpl<IXMLDOMDocument, &IID_IXMLDOMDocument, &LIBID_Xerces>,
	public IObjectWithSiteImpl<CXMLDOMDocument>,
	public ISupportErrorInfo,
	public CProxyXMLDOMDocumentEvents< CXMLDOMDocument >,
	public IConnectionPointContainerImpl<CXMLDOMDocument>,
	public IProvideClassInfo2Impl<&CLSID_DOMDocument, &DIID_XMLDOMDocumentEvents, &LIBID_Xerces>,
	public CWindowImpl<CXMLDOMDocument, CWindow, CWinTraits<0,0> >,
	ErrorHandler
{
public:
	CXMLDOMDocument();

	HRESULT FinalConstruct();
	void	FinalRelease();

	virtual DOM_Node&   get_DOM_Node()			 { return m_Document;} 
	virtual DOMNodeType get_DOMNodeType() const  { return NODE_DOCUMENT; }

	virtual void resetErrors() {};

	//DECLARE_REGISTRY_RESOURCEID(IDR_XMLDOCUMENT)
	static HRESULT WINAPI UpdateRegistry(BOOL bRegister);

DECLARE_NOT_AGGREGATABLE(CXMLDOMDocument)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CXMLDOMDocument)
	COM_INTERFACE_ENTRY(IXMLDOMDocument)
	COM_INTERFACE_ENTRY(IXMLDOMNode)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(IIBMXMLDOMNodeIdentity)
	COM_INTERFACE_ENTRY(IObjectSafety)
	COM_INTERFACE_ENTRY(IObjectWithSite)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY_IMPL(IConnectionPointContainer)
	COM_INTERFACE_ENTRY(IProvideClassInfo)
	COM_INTERFACE_ENTRY(IProvideClassInfo2)
END_COM_MAP()

BEGIN_CONNECTION_POINT_MAP(CXMLDOMDocument)
	CONNECTION_POINT_ENTRY(DIID_XMLDOMDocumentEvents)
END_CONNECTION_POINT_MAP()

	DECLARE_WND_CLASS(_T("XMLParseMonitor")) 

BEGIN_MSG_MAP(CMonitorWnd)
	MESSAGE_HANDLER(MSG_READY_STATE_CHANGE,	OnReadyStateChange)
END_MSG_MAP()

	LRESULT OnReadyStateChange(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);

	// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

	// IXMLDOMDocument methods
	STDMETHOD(get_doctype)(IXMLDOMDocumentType  * *pVal);
	STDMETHOD(get_implementation)(IXMLDOMImplementation  * *pVal);
	STDMETHOD(get_documentElement)(IXMLDOMElement  * *pVal);
	STDMETHOD(putref_documentElement)(IXMLDOMElement  *newVal);
	STDMETHOD(createElement)(BSTR tagName, IXMLDOMElement  * *element);
	STDMETHOD(createDocumentFragment)(IXMLDOMDocumentFragment  * *docFrag);
	STDMETHOD(createTextNode)(BSTR data, IXMLDOMText  * *text);
	STDMETHOD(createComment)(BSTR data, IXMLDOMComment  * *comment);
	STDMETHOD(createCDATASection)(BSTR data, IXMLDOMCDATASection  * *cdata);
	STDMETHOD(createProcessingInstruction)(BSTR target, BSTR data, IXMLDOMProcessingInstruction  * *pVal);
	STDMETHOD(createAttribute)(BSTR name, IXMLDOMAttribute  * *attr);
	STDMETHOD(createEntityReference)(BSTR name, IXMLDOMEntityReference  * *entityRef);
	STDMETHOD(getElementsByTagName)(BSTR tagName, IXMLDOMNodeList  * *resultList);
	STDMETHOD(createNode)(VARIANT type, BSTR name, BSTR namespaceURI, IXMLDOMNode  * *node);
	STDMETHOD(nodeFromID)(BSTR idString, IXMLDOMNode  * *node);
	STDMETHOD(load)(VARIANT xmlSource, VARIANT_BOOL  *isSuccessful);
	STDMETHOD(get_readyState)(long  *pVal);
	STDMETHOD(get_parseError)(IXMLDOMParseError  * *pVal);
	STDMETHOD(get_url)(BSTR  *pVal);
	STDMETHOD(get_async)(VARIANT_BOOL  *pVal);
	STDMETHOD(put_async)(VARIANT_BOOL newVal);
	STDMETHOD(abort)(void);
	STDMETHOD(loadXML)(BSTR bstrXML, VARIANT_BOOL  *success);
	STDMETHOD(save)(VARIANT location);
	STDMETHOD(get_validateOnParse)(VARIANT_BOOL  *pVal);
	STDMETHOD(put_validateOnParse)(VARIANT_BOOL newVal);
	STDMETHOD(get_resolveExternals)(VARIANT_BOOL  *pVal);
	STDMETHOD(put_resolveExternals)(VARIANT_BOOL newVal);
	STDMETHOD(get_preserveWhiteSpace)(VARIANT_BOOL  *pVal);
	STDMETHOD(put_preserveWhiteSpace)(VARIANT_BOOL newVal);
	STDMETHOD(put_onreadystatechange)(VARIANT newVal);
	STDMETHOD(put_ondataavailable)(VARIANT newVal);
	STDMETHOD(put_ontransformnode)(VARIANT newVal);

	// Error handling
	virtual void warning(const SAXParseException& exception);
	virtual void error(const SAXParseException& exception);
    virtual void fatalError(const SAXParseException& exception);

	bool IsAbort() const { return m_bAbort; }

	DOM_Document		  m_Document;

private:

	bool				  m_bValidate;
	long				  m_lReadyState;
	_bstr_t			      m_url;
	CXMLDOMParseErrorObj *m_pParseError;
	bool			      m_bAsync;	
	bool				  m_bAbort;
	HANDLE				  m_hParseThread;
	LPDISPATCH			  m_pOnReadyStateChange;
	LPDISPATCH			  m_pOnDataAvailable;
	LPDISPATCH			  m_pOnTransformNode;

	// thread data
	_bstr_t				  m_FileName;
	_bstr_t				  m_xml;
	DOM_Document		  m_TmpDocument;
	bool			      m_bParseError;
	bool				  m_bThreadValidate;
	bool                  m_bPreserveWhiteSpace;
	
	HRESULT GetBaseURL(_bstr_t &baseURL);
	
	static UINT APIENTRY ParseThread(void *pParm);
};

typedef CComObject<CXMLDOMDocument> CXMLDOMDocumentObj;

#endif // ___xmldomdocument_h___