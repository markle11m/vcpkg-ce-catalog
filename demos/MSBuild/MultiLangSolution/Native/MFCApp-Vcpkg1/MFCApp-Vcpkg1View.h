
// MFCApp-Vcpkg1View.h : interface of the CMFCAppVcpkg1View class
//

#pragma once


class CMFCAppVcpkg1View : public CView
{
protected: // create from serialization only
	CMFCAppVcpkg1View() noexcept;
	DECLARE_DYNCREATE(CMFCAppVcpkg1View)

// Attributes
public:
	CMFCAppVcpkg1Doc* GetDocument() const;

// Operations
public:

// Overrides
public:
	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual BOOL PreCreateWindow(CREATESTRUCT& cs);
protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);

// Implementation
public:
	virtual ~CMFCAppVcpkg1View();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;
#endif

protected:

// Generated message map functions
protected:
	afx_msg void OnFilePrintPreview();
	afx_msg void OnRButtonUp(UINT nFlags, CPoint point);
	afx_msg void OnContextMenu(CWnd* pWnd, CPoint point);
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG  // debug version in MFCApp-Vcpkg1View.cpp
inline CMFCAppVcpkg1Doc* CMFCAppVcpkg1View::GetDocument() const
   { return reinterpret_cast<CMFCAppVcpkg1Doc*>(m_pDocument); }
#endif

