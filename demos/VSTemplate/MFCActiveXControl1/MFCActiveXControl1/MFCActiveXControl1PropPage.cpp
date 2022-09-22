// MFCActiveXControl1PropPage.cpp : Implementation of the CMFCActiveXControl1PropPage property page class.

#include "pch.h"
#include "framework.h"
#include "MFCActiveXControl1.h"
#include "MFCActiveXControl1PropPage.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

IMPLEMENT_DYNCREATE(CMFCActiveXControl1PropPage, COlePropertyPage)

// Message map

BEGIN_MESSAGE_MAP(CMFCActiveXControl1PropPage, COlePropertyPage)
END_MESSAGE_MAP()

// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMFCActiveXControl1PropPage, "MFCACTIVEXCONT.MFCActiveXControl1PropPage.1",
	0xeafdaf0b,0x0934,0x4eec,0x93,0xb1,0x01,0x04,0xe3,0xc1,0x90,0x0b)

// CMFCActiveXControl1PropPage::CMFCActiveXControl1PropPageFactory::UpdateRegistry -
// Adds or removes system registry entries for CMFCActiveXControl1PropPage

BOOL CMFCActiveXControl1PropPage::CMFCActiveXControl1PropPageFactory::UpdateRegistry(BOOL bRegister)
{
	if (bRegister)
		return AfxOleRegisterPropertyPageClass(AfxGetInstanceHandle(),
			m_clsid, IDS_MFCACTIVEXCONTROL1_PPG);
	else
		return AfxOleUnregisterClass(m_clsid, nullptr);
}

// CMFCActiveXControl1PropPage::CMFCActiveXControl1PropPage - Constructor

CMFCActiveXControl1PropPage::CMFCActiveXControl1PropPage() :
	COlePropertyPage(IDD, IDS_MFCACTIVEXCONTROL1_PPG_CAPTION)
{
}

// CMFCActiveXControl1PropPage::DoDataExchange - Moves data between page and properties

void CMFCActiveXControl1PropPage::DoDataExchange(CDataExchange* pDX)
{
	DDP_PostProcessing(pDX);
}

// CMFCActiveXControl1PropPage message handlers
