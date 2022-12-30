
// MFCApp-Vcpkg1View.cpp : implementation of the CMFCAppVcpkg1View class
//

#include "pch.h"
#include "framework.h"
// SHARED_HANDLERS can be defined in an ATL project implementing preview, thumbnail
// and search filter handlers and allows sharing of document code with that project.
#ifndef SHARED_HANDLERS
#include "MFCApp-Vcpkg1.h"
#endif

#include "MFCApp-Vcpkg1Doc.h"
#include "MFCApp-Vcpkg1View.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif


// CMFCAppVcpkg1View

IMPLEMENT_DYNCREATE(CMFCAppVcpkg1View, CView)

BEGIN_MESSAGE_MAP(CMFCAppVcpkg1View, CView)
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_DIRECT, &CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, &CMFCAppVcpkg1View::OnFilePrintPreview)
	ON_WM_CONTEXTMENU()
	ON_WM_RBUTTONUP()
END_MESSAGE_MAP()

// CMFCAppVcpkg1View construction/destruction

CMFCAppVcpkg1View::CMFCAppVcpkg1View() noexcept
{
	// TODO: add construction code here

}

CMFCAppVcpkg1View::~CMFCAppVcpkg1View()
{
}

BOOL CMFCAppVcpkg1View::PreCreateWindow(CREATESTRUCT& cs)
{
	// TODO: Modify the Window class or styles here by modifying
	//  the CREATESTRUCT cs

	return CView::PreCreateWindow(cs);
}

// CMFCAppVcpkg1View drawing

void CMFCAppVcpkg1View::OnDraw(CDC* /*pDC*/)
{
	CMFCAppVcpkg1Doc* pDoc = GetDocument();
	ASSERT_VALID(pDoc);
	if (!pDoc)
		return;

	// TODO: add draw code for native data here
}


// CMFCAppVcpkg1View printing


void CMFCAppVcpkg1View::OnFilePrintPreview()
{
#ifndef SHARED_HANDLERS
	AFXPrintPreview(this);
#endif
}

BOOL CMFCAppVcpkg1View::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

void CMFCAppVcpkg1View::OnBeginPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add extra initialization before printing
}

void CMFCAppVcpkg1View::OnEndPrinting(CDC* /*pDC*/, CPrintInfo* /*pInfo*/)
{
	// TODO: add cleanup after printing
}

void CMFCAppVcpkg1View::OnRButtonUp(UINT /* nFlags */, CPoint point)
{
	ClientToScreen(&point);
	OnContextMenu(this, point);
}

void CMFCAppVcpkg1View::OnContextMenu(CWnd* /* pWnd */, CPoint point)
{
#ifndef SHARED_HANDLERS
	theApp.GetContextMenuManager()->ShowPopupMenu(IDR_POPUP_EDIT, point.x, point.y, this, TRUE);
#endif
}


// CMFCAppVcpkg1View diagnostics

#ifdef _DEBUG
void CMFCAppVcpkg1View::AssertValid() const
{
	CView::AssertValid();
}

void CMFCAppVcpkg1View::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CMFCAppVcpkg1Doc* CMFCAppVcpkg1View::GetDocument() const // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CMFCAppVcpkg1Doc)));
	return (CMFCAppVcpkg1Doc*)m_pDocument;
}
#endif //_DEBUG


// CMFCAppVcpkg1View message handlers
