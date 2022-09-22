// MFCActiveXControl1Ctrl.cpp : Implementation of the CMFCActiveXControl1Ctrl ActiveX Control class.

#include "pch.h"
#include "framework.h"
#include "MFCActiveXControl1.h"
#include "MFCActiveXControl1Ctrl.h"
#include "MFCActiveXControl1PropPage.h"
#include "afxdialogex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

IMPLEMENT_DYNCREATE(CMFCActiveXControl1Ctrl, COleControl)

// Message map

BEGIN_MESSAGE_MAP(CMFCActiveXControl1Ctrl, COleControl)
	ON_OLEVERB(AFX_IDS_VERB_PROPERTIES, OnProperties)
END_MESSAGE_MAP()

// Dispatch map

BEGIN_DISPATCH_MAP(CMFCActiveXControl1Ctrl, COleControl)
	DISP_FUNCTION_ID(CMFCActiveXControl1Ctrl, "AboutBox", DISPID_ABOUTBOX, AboutBox, VT_EMPTY, VTS_NONE)
END_DISPATCH_MAP()

// Event map

BEGIN_EVENT_MAP(CMFCActiveXControl1Ctrl, COleControl)
END_EVENT_MAP()

// Property pages

// TODO: Add more property pages as needed.  Remember to increase the count!
BEGIN_PROPPAGEIDS(CMFCActiveXControl1Ctrl, 1)
	PROPPAGEID(CMFCActiveXControl1PropPage::guid)
END_PROPPAGEIDS(CMFCActiveXControl1Ctrl)

// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMFCActiveXControl1Ctrl, "MFCACTIVEXCONTRO.MFCActiveXControl1Ctrl.1",
	0x1fb2728a,0x8948,0x4058,0x81,0x72,0x15,0x06,0x5a,0x9a,0xb9,0x5b)

// Type library ID and version

IMPLEMENT_OLETYPELIB(CMFCActiveXControl1Ctrl, _tlid, _wVerMajor, _wVerMinor)

// Interface IDs

const IID IID_DMFCActiveXControl1 = {0x27364db4,0x876a,0x40cd,{0xa2,0x43,0x53,0x78,0x14,0xbc,0x63,0x41}};
const IID IID_DMFCActiveXControl1Events = {0xef6b1b5c,0x78f1,0x4459,{0xb4,0x7e,0x29,0xac,0xbd,0x7f,0xfb,0x95}};

// Control type information

static const DWORD _dwMFCActiveXControl1OleMisc =
	OLEMISC_ACTIVATEWHENVISIBLE |
	OLEMISC_SETCLIENTSITEFIRST |
	OLEMISC_INSIDEOUT |
	OLEMISC_CANTLINKINSIDE |
	OLEMISC_RECOMPOSEONRESIZE;

IMPLEMENT_OLECTLTYPE(CMFCActiveXControl1Ctrl, IDS_MFCACTIVEXCONTROL1, _dwMFCActiveXControl1OleMisc)

// CMFCActiveXControl1Ctrl::CMFCActiveXControl1CtrlFactory::UpdateRegistry -
// Adds or removes system registry entries for CMFCActiveXControl1Ctrl

BOOL CMFCActiveXControl1Ctrl::CMFCActiveXControl1CtrlFactory::UpdateRegistry(BOOL bRegister)
{
	// TODO: Verify that your control follows apartment-model threading rules.
	// Refer to MFC TechNote 64 for more information.
	// If your control does not conform to the apartment-model rules, then
	// you must modify the code below, changing the 6th parameter from
	// afxRegApartmentThreading to 0.

	if (bRegister)
		return AfxOleRegisterControlClass(
			AfxGetInstanceHandle(),
			m_clsid,
			m_lpszProgID,
			IDS_MFCACTIVEXCONTROL1,
			IDB_MFCACTIVEXCONTROL1,
			afxRegApartmentThreading,
			_dwMFCActiveXControl1OleMisc,
			_tlid,
			_wVerMajor,
			_wVerMinor);
	else
		return AfxOleUnregisterClass(m_clsid, m_lpszProgID);
}


// CMFCActiveXControl1Ctrl::CMFCActiveXControl1Ctrl - Constructor

CMFCActiveXControl1Ctrl::CMFCActiveXControl1Ctrl()
{
	InitializeIIDs(&IID_DMFCActiveXControl1, &IID_DMFCActiveXControl1Events);
	// TODO: Initialize your control's instance data here.
}

// CMFCActiveXControl1Ctrl::~CMFCActiveXControl1Ctrl - Destructor

CMFCActiveXControl1Ctrl::~CMFCActiveXControl1Ctrl()
{
	// TODO: Cleanup your control's instance data here.
}

// CMFCActiveXControl1Ctrl::OnDraw - Drawing function

void CMFCActiveXControl1Ctrl::OnDraw(
			CDC* pdc, const CRect& rcBounds, const CRect& /* rcInvalid */)
{
	if (!pdc)
		return;

	// TODO: Replace the following code with your own drawing code.
	pdc->FillRect(rcBounds, CBrush::FromHandle((HBRUSH)GetStockObject(WHITE_BRUSH)));
	pdc->Ellipse(rcBounds);
}

// CMFCActiveXControl1Ctrl::DoPropExchange - Persistence support

void CMFCActiveXControl1Ctrl::DoPropExchange(CPropExchange* pPX)
{
	ExchangeVersion(pPX, MAKELONG(_wVerMinor, _wVerMajor));
	COleControl::DoPropExchange(pPX);

	// TODO: Call PX_ functions for each persistent custom property.
}


// CMFCActiveXControl1Ctrl::OnResetState - Reset control to default state

void CMFCActiveXControl1Ctrl::OnResetState()
{
	COleControl::OnResetState();  // Resets defaults found in DoPropExchange

	// TODO: Reset any other control state here.
}


// CMFCActiveXControl1Ctrl::AboutBox - Display an "About" box to the user

void CMFCActiveXControl1Ctrl::AboutBox()
{
	CDialogEx dlgAbout(IDD_ABOUTBOX_MFCACTIVEXCONTROL1);
	dlgAbout.DoModal();
}


// CMFCActiveXControl1Ctrl message handlers
