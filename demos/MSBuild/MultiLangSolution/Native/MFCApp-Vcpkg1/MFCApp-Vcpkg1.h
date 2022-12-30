
// MFCApp-Vcpkg1.h : main header file for the MFCApp-Vcpkg1 application
//
#pragma once

#ifndef __AFXWIN_H__
	#error "include 'pch.h' before including this file for PCH"
#endif

#include "resource.h"       // main symbols


// CMFCAppVcpkg1App:
// See MFCApp-Vcpkg1.cpp for the implementation of this class
//

class CMFCAppVcpkg1App : public CWinAppEx
{
public:
	CMFCAppVcpkg1App() noexcept;


// Overrides
public:
	virtual BOOL InitInstance();
	virtual int ExitInstance();

// Implementation
	UINT  m_nAppLook;
	BOOL  m_bHiColorIcons;

	virtual void PreLoadState();
	virtual void LoadCustomState();
	virtual void SaveCustomState();

	afx_msg void OnAppAbout();
	DECLARE_MESSAGE_MAP()
};

extern CMFCAppVcpkg1App theApp;
