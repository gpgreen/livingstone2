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
 * $Log: XMLDOMParseError.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:14  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.2  2000/03/30 02:00:10  abagchi
 * Initial checkin of working code with Copyright Notice
 *
 */

#include "stdafx.h"
#include "xml4com.h"
#include "XMLDOMParseError.h"

HRESULT CXMLDOMParseError::FinalConstruct()
{
	m_CS.Init();
	return S_OK;
}

void CXMLDOMParseError::FinalRelease()	
{
	m_CS.Term(); 
}

void CXMLDOMParseError::SetData( long code,
								 const _bstr_t &url,
								 const _bstr_t &reason,
								 const _bstr_t &source,
								 long  lineNumber,
								 long  linePos,
								 long  filePos)
{
	m_CS.Lock(); 
	m_Code			= code;
	m_url			= url;
	m_Reason		= reason;
	m_Source		= source;
	m_LineNumber	= lineNumber;
	m_LinePos		= linePos;
	m_FilePos		= filePos;
	m_CS.Unlock(); 
}

void CXMLDOMParseError::Reset()
{
	m_CS.Lock(); 
	m_Code			= 0;
	m_url			= _T("");
	m_Reason		= _T("");
	m_Source		= _T("");
	m_LineNumber	= 0;
	m_LinePos		= 0;
	m_FilePos		= 0;
	m_CS.Unlock(); 
}

// IXMLDOMParseError methods
STDMETHODIMP CXMLDOMParseError::get_errorCode(long  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_errorCode\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_Code;
	m_CS.Unlock(); 

	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_url(BSTR  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_url\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_url.copy();
	m_CS.Unlock(); 

	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_reason(BSTR  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_reason\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_Reason.copy();
	m_CS.Unlock(); 

	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_srcText(BSTR  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_srcText\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_Source.copy();
	m_CS.Unlock(); 
	
	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_line(long  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_line\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_LineNumber;
	m_CS.Unlock(); 

	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_linepos(long  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_linepos\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_LinePos;
	m_CS.Unlock(); 
	
	return S_OK;
}

STDMETHODIMP CXMLDOMParseError::get_filepos(long  *pVal)
{
	ATLTRACE(_T("CXMLDOMParseError::get_filepos\n"));

	if (NULL == pVal)
		return E_POINTER;

	m_CS.Lock(); 
	*pVal = m_FilePos;
	m_CS.Unlock(); 

	return S_OK;
}

