.486
.model	flat, stdcall
option	casemap :none   ; case sensitive

include		base.inc

.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	invoke	DialogBoxParam, hInstance, 101, 0, ADDR DlgProc, 0
	invoke	ExitProcess, eax
; -----------------------------------------------------------------------
DlgProc	proc	hWin	:DWORD,
		uMsg	:DWORD,
		wParam	:DWORD,
		lParam	:DWORD

	.if	uMsg == WM_INITDIALOG
			invoke	LoadIcon,hInstance,200
			invoke	SendMessage, hWin, WM_SETICON, 1, eax
	.elseif uMsg==WM_COMMAND
			
			.if	wParam == IDC_OK
; -----------------------------------------------------------------------
;			TODO
; -----------------------------------------------------------------------
        .elseif	wParam == IDC_IDCANCEL
			invoke EndDialog,hWin,0
		.endif
	.elseif	uMsg == WM_CLOSE
		invoke	EndDialog,hWin,0
	.endif

	xor	eax,eax
	ret
DlgProc	endp

end start
