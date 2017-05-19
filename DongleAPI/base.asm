; ---- skeleton -----------------------------------------------------------
.386
.model	flat, stdcall
option	casemap :none ; case sensitive

; ---- Include ------------------------------------------------------------

uselib	MACRO	libname
	include		libname.inc
	includelib	libname.lib
ENDM

include \WinAsm\dongle\test\Rockey4ND.inc
include	\masm32\include\windows.inc
include \masm32\macros\macros.asm

uselib	user32
uselib	kernel32

; -------------------------------------------------------------------------
DlgProc			PROTO :DWORD,:DWORD,:DWORD,:DWORD
RockeyAS		PROTO rcode:DWORD

icon			equ	1002
IDC_FIND		equ	1003
IDC_CANCEL	 	equ	1004
IDC_OPEN	 	equ	1005
IDC_READ	 	equ	1006
IDC_CLOSE	 	equ	1007
IDC_READUSERID 	equ	1008

; ---- Initialized data ---------------------------------------------------
.data
RockeyDll db "Rockey4ND.dll",0
szRockeyFun db 'Rockey',0
szFmt1 db '%d',0
szFmt2 db '%s',0
szFmt3 db '%d-%d-%d-%d',0
szFmt4 db '%d-%d',0
Rockey dd 0
handle  dd 0
lp1     dd 0
lp2     dd 0
p1      dw 0XXXXh ;needed for read
p2      dw 0XXXXh ;needed for read
p3      dw 0XXXXh ;needed for write
p4      dw 0XXXXh ;needed for write
buffer  db 1024 dup(0)
tmpbuffer db 60 dup(0)
tmpbuffer1 db 120 dup(0)
retcode dw 0
rc      dw 4 dup(0)
cmd     db "H=H^H, A=A*23, F=B*17, A=A+F, A=A+G, A=A<C, A=A^D, B=B^B, C=C^C, D=D^D", 0
status 						dd ?

; ---- Uninitialized data -------------------------------------------------
.data?
hInstance		dd		?	;dd can be written as dword

; ---- Code ---------------------------------------------------------------
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
		
		
;Get the Rockey function address
invoke 	LoadLibrary,offset RockeyDll

xor edx,edx
mov handle,edx
mov ebx,eax

.if ebx
	invoke GetProcAddress,ebx,offset szRockeyFun
	mov Rockey,eax	
.else
	invoke MessageBox,hWin,CTXT("Rockey4ND.dll not found"),CTXT("nigga"),MB_ICONINFORMATION
	invoke ExitProcess,1	
.endif	

.if uMsg == WM_INITDIALOG
	invoke LoadIcon,hInstance,icon
	invoke SendMessage,hWin,WM_SETICON,1,eax
	mov status,1 ; button statut
	.elseif	uMsg == WM_COMMAND
		.if	wParam == IDC_FIND
; -----------------------------------------------------------------------
;Find Rockey
invoke RockeyAS,RY_FIND
    .IF (eax == 0)
  	invoke MessageBox,hWin,CTXT("RY_FIND OK"),CTXT("nigga"),MB_OK
    .else
     invoke MessageBox,hWin,CTXT("RY_FIND BAD"),CTXT("nigga"),MB_OK
        invoke ExitProcess,1
   .endif
; -----------------------------------------------------------------------
        .elseif	wParam == IDC_OPEN
			.if status == 1
				invoke SetDlgItemText,hWin,IDC_OPEN,chr$("RY_CLOSE")
				invoke RockeyAS,RY_OPEN
    .if (ax ==0)
    	invoke MessageBox,hWin,CTXT("RY_OPEN OK"),CTXT("nigga"),MB_OK
    .else
    	invoke MessageBox,hWin,CTXT("RY_OPEN BAD"),CTXT("nigga"),MB_OK
.endif
				mov status,0
			.else
				invoke SetDlgItemText,hWin,IDC_OPEN,chr$("RY_OPEN")
				invoke RockeyAS, RY_CLOSE
.if (ax ==0)
        invoke MessageBox,hWin,CTXT("RY_CLOSE OK"),CTXT("nigga"),MB_OK
    .else
    	invoke MessageBox,hWin,CTXT("RY_CLOSE BAD"),CTXT("nigga"),MB_OK
.ENDIF
				mov status,1
			.endif

        .elseif	wParam == IDC_READ
mov p1, 4
mov p2, 5
invoke RtlZeroMemory,ADDR buffer, 64
invoke RockeyAS, RY_READ
    .if (ax ==0)
    	invoke MessageBox,hWin,CTXT("RY_READ OK"),CTXT("nigga"),MB_OK
    .else
    	invoke MessageBox,hWin,CTXT("RY_READ BAD"),CTXT("nigga"),MB_OK
.endif

        .elseif	wParam == IDC_CLOSE

        .elseif	wParam == IDC_READUSERID

invoke RockeyAS, RY_READ_USERID
.if (ax ==0)
        invoke MessageBox,hWin,CTXT("RY_READ_USERID OK"),CTXT("nigga"),MB_OK
    .else
    	invoke MessageBox,hWin,CTXT("RY_READ_USERID BAD"),CTXT("nigga"),MB_OK
.ENDIF
        .elseif	wParam == IDC_CANCEL
        invoke RockeyAS, RY_CLOSE
			invoke EndDialog,hWin,0
		.endif
	.elseif	uMsg == WM_CLOSE
		invoke RockeyAS, RY_CLOSE
		invoke	EndDialog,hWin,0
	.endif

	xor	eax,eax
	ret
DlgProc	endp

RockeyAS proc stdcall USES ebx,rcode:DWORD

push offset buffer
push offset p2
push offset p1
push offset lp2
push offset lp1
push offset handle
mov ebx,rcode
push ebx
call Rockey

ret

RockeyAS endp

end start
