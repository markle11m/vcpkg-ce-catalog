#pragma once

// MFCActiveXControl1PropPage.h : Declaration of the CMFCActiveXControl1PropPage property page class.


// CMFCActiveXControl1PropPage : See MFCActiveXControl1PropPage.cpp for implementation.

class CMFCActiveXControl1PropPage : public COlePropertyPage
{
	DECLARE_DYNCREATE(CMFCActiveXControl1PropPage)
	DECLARE_OLECREATE_EX(CMFCActiveXControl1PropPage)

// Constructor
public:
	CMFCActiveXControl1PropPage();

// Dialog Data
	enum { IDD = IDD_PROPPAGE_MFCACTIVEXCONTROL1 };

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Message maps
protected:
	DECLARE_MESSAGE_MAP()
};

