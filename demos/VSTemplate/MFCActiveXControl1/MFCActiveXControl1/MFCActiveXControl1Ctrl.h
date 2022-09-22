#pragma once

// MFCActiveXControl1Ctrl.h : Declaration of the CMFCActiveXControl1Ctrl ActiveX Control class.


// CMFCActiveXControl1Ctrl : See MFCActiveXControl1Ctrl.cpp for implementation.

class CMFCActiveXControl1Ctrl : public COleControl
{
	DECLARE_DYNCREATE(CMFCActiveXControl1Ctrl)

// Constructor
public:
	CMFCActiveXControl1Ctrl();

// Overrides
public:
	virtual void OnDraw(CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid);
	virtual void DoPropExchange(CPropExchange* pPX);
	virtual void OnResetState();

// Implementation
protected:
	~CMFCActiveXControl1Ctrl();

	DECLARE_OLECREATE_EX(CMFCActiveXControl1Ctrl)    // Class factory and guid
	DECLARE_OLETYPELIB(CMFCActiveXControl1Ctrl)      // GetTypeInfo
	DECLARE_PROPPAGEIDS(CMFCActiveXControl1Ctrl)     // Property page IDs
	DECLARE_OLECTLTYPE(CMFCActiveXControl1Ctrl)		// Type name and misc status

// Message maps
	DECLARE_MESSAGE_MAP()

// Dispatch maps
	DECLARE_DISPATCH_MAP()

	afx_msg void AboutBox();

// Event maps
	DECLARE_EVENT_MAP()

// Dispatch and event IDs
public:
	enum {
	};
};

