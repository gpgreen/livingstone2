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
 * $Log: XMLDOMEntity.cpp,v $
 * Revision 1.1.1.1  2000/09/20 20:40:13  bhudson
 * Importing xerces 1.2.0
 *
 * Revision 1.2  2000/03/30 02:00:11  abagchi
 * Initial checkin of working code with Copyright Notice
 *
 */

#include "stdafx.h"
#include "xml4com.h"
#include "XMLDOMEntity.h"

// IXMLDOMEntity methods
STDMETHODIMP CXMLDOMEntity::get_publicId(VARIANT  *pVal)
{
	ATLTRACE(_T("CXMLDOMEntity::get_publicId\n"));

	if (NULL == pVal)
		return E_POINTER;

	::VariantInit(pVal);

	try
	{
		V_VT(pVal)   = VT_BSTR;
		V_BSTR(pVal) = SysAllocString(entity.getPublicId().rawBuffer());
	}
	catch(...)
	{
		return E_FAIL;
	}
	
	return S_OK;
}

STDMETHODIMP CXMLDOMEntity::get_systemId(VARIANT  *pVal)
{
	ATLTRACE(_T("CXMLDOMEntity::get_systemId\n"));

	if (NULL == pVal)
		return E_POINTER;

	::VariantInit(pVal);

	try
	{
		V_VT(pVal)   = VT_BSTR;
		V_BSTR(pVal) = SysAllocString(entity.getSystemId().rawBuffer());
	}
	catch(...)
	{
		return E_FAIL;
	}
	
	return S_OK;
}

STDMETHODIMP CXMLDOMEntity::get_notationName(BSTR  *pVal)
{
	ATLTRACE(_T("CXMLDOMEntity::get_notationName\n"));

	if (NULL == pVal)
		return E_POINTER;

	*pVal = NULL; 

	try
	{
		*pVal = SysAllocString(entity.getNotationName().rawBuffer());
	}
	catch(...)
	{
		return E_FAIL;
	}

	return S_OK;
}
