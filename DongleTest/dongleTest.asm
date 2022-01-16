.386
.model    flat, stdcall
option    casemap :none ; case sensitive

include           \masm32\include\windows.inc
include           \masm32\include\user32.inc
include           \masm32\include\kernel32.inc
include           \masm32\macros\macros.asm
include           libs\Rockey4ND.inc
include           \masm32\include\shlwapi.inc

includelib        \masm32\lib\shlwapi.lib
includelib        \masm32\lib\user32.lib
includelib        \masm32\lib\kernel32.lib

DlgProc            PROTO :DWORD,:DWORD,:DWORD,:DWORD
RawReadHex         PROTO :DWORD,:DWORD
WriteHex           PROTO :DWORD,:DWORD
RockeyAS           PROTO rcode:DWORD

.const
icon                    equ 1002

IDB_TEST                equ 1003
IDB_QUIT                equ 1004
IDC_P1                  equ 1042
IDC_P2                  equ 1043
IDC_P3                  equ 1044
IDC_P4                  equ 1045
IDC_STATIC1046          equ 1046
IDC_STATIC1047          equ 1047
IDC_STATIC1048          equ 1048
IDC_STATIC1049          equ 1049

MASK_UPPERCASE          equ 0DFh
MAXSiZE                 equ 10h

.data
szFmt1                  db "%d",0
szFmt2                  db "%s",0
szFmt3                  db "%d-%d-%d-%d",0
szFmt4                  db "%d-%d",0

; dlg success/fail messages
errorInputP1P2P3P4      db "P1 and P2 must be four-digits hexadecimal numbers, without spaces!", 0
szSuccess1              db "Find dongle success: 0x",0
szFailNF1               db "Find Rockey failed, plug it to your USB port!",0
szFailBad1              db "Dongle found but Bad passwords!",0
szSuccess2              db "Open Rockey: Success",0
szFail2                 db "Open Rockey failed",0
szSuccess3              db "Write 'Hello' to Rockey memory zone 1: Success",0
szFail3                 db "Write 'Hello' to Rockey memory zone 1: failed",0
szSuccess4              db "Read Rockey: ",0
szFail4                 db "Read Rockey: failed",0
szSuccess5              db "Create random: ",0
szFail5                 db "Create random: failed",0
szSuccess6              db "Generate seed code: ",0
szFail6                 db "Generate seed code: failed",0
szSuccess7              db "Write USER ID: ",0
szFail7                 db "Write USER ID failed",0
szSuccess8              db "Read USER ID: ",0
szFail8                 db "Read USER ID failed",0
szFail9                 db "Set module failed",0
szFail10                db "Read module failed",0
szSuccess11             db "Write arithmetic: Success",0
szFail11                db "Write arithmetic: failed",0
szSuccess12             db "Calculate arithmetic result: ",0
szFail12                db "Calculate arithmetic failed",0
sz1                     db "Set Moudle 7: Value =",0
sz2                     db "Check Moudle 7: ",0
szFail14                db "Disconnect: failed",0
szSuccess14             db "Disconnect: Success",0

;Dlg ctrl text
szCtrlDlg_Title         db "Dongle tester",0
szCtrlBtn_Test          db "Read/Write test",0
szCtrlBtn_Quit          db "Quit",0
szCtrlLbl_P1            db "P1:",0
szCtrlLbl_P2            db "P2:",0
szCtrlLbl_P3            db "P3:",0
szCtrlLbl_P4            db "P4:",0

hexadecimalDigits       db "0123456789ABCDEF",0

;Password in hard for my rockey dongle
szBasicPW1              db "4839",0
szBasicPW2              db "4BBB",0
szAdvancedPW1           db "4B31",0
szAdvancedPW2           db "4847",0

; ROCKEY4ND Function Prototype and Definition
RockeyDll               db "Rockey4ND.dll",0
szRockeyFun             db "Rockey",0
Rockey                  dd 0
handle                  dd 0
lp1                     dd 0
lp2                     dd 0
p1                      dw 0C44Ch ; ROCKEY4ND Demo Password1
p2                      dw 0C8F8h ; ROCKEY4ND Demo Password2
p3                      dw 00799h ; ROCKEY4ND Demo Password3
p4                      dw 0C43Bh ; ROCKEY4ND Demo Password4
buffer                  db 1024 dup(0)

; Buffers for read/write passwords
szBufP1                 dd 4 dup(0)
szBufP2                 dd 4 dup(0)
szBufP3                 dd 4 dup(0)
szBufP4                 dd 4 dup(0)

tmpbuffer               db 60 dup(0)
tmpbuffer1              db 120 dup(0)
tmphardID               db 10 dup(0)
BufHIDlogs              db 30 dup(0)
tmpuserID               db 10 dup(0)
BufUIDlogs              db 30 dup(0)
retcode                 dw 0
rc                      dw 4 dup(0)
cmd                     db "H=H^H, A=A*23, F=B*17, A=A+F, A=A+G, A=A<C, A=A^D, B=B^B, C=C^C, D=D^D", 0
info1                   db "Hello"

.data?
hInstance               dd ? ; Handle for loaded program

; To drop the dll
SizeRes                 dd ?
hResource               dd ?
pData                   dd ?
Handle2                 dd ?
Bytes                   dd ?
SysDirect               db 100h dup(?)

.code
start:
    invoke GetModuleHandle,NULL
    mov hInstance, eax
    invoke DialogBoxParam,hInstance,101,0,addr DlgProc,0
    invoke ExitProcess,eax

WriteHex proc  integer    :DWORD,
               Bufferhex  :DWORD

    mov ecx,Bufferhex
    mov al,[hexadecimalDigits]
    mov edx,8

WriteHex_ForwardLoop:

    cmp edx,0
    jz WriteHex_ForwardEnd

    sub edx,1
    mov [ecx],al
    add ecx,1
    jmp WriteHex_ForwardLoop

WriteHex_ForwardEnd:

    xor al,al
    mov [ecx],al
    mov eax,integer

    push ebx
    lea ebx,[hexadecimalDigits]

WriteHex_BackwardLoop:

    sub ecx,1

    mov edx,eax
    and edx,00Fh

    shr eax,4

    mov dl,[ebx+edx]
    mov [ecx],dl

    cmp eax,0
    jnz WriteHex_BackwardLoop

WriteHex_BackwardEnd:

    pop ebx

WriteHex_return:

    ret

WriteHex EndP

RawReadHex proc arrayInput      :DWORD,
                pointerOutput   :DWORD

    xor eax,eax

    push ebx
    push esi

    mov esi,arrayInput

RawReadHex_Loop:

    mov dl,[esi]
    add esi,1

    cmp dl,0
    jz RawReadHex_End

    cmp dl,'0'
    jb RawReadHex_Error

    cmp dl,'9'
    jbe RawReadHex_DigitFound

    and dl,MASK_UPPERCASE

    cmp dl,'A'
    jb RawReadHex_Error

    cmp dl,'F'
    jbe RawReadHex_DigitFound

    jmp RawReadHex_Error

RawReadHex_DigitFound:

    lea ebx,[hexadecimalDigits]
    xor ecx,ecx

RawReadHex_DigitFound_LoopValue:

    cmp dl,[ebx]
    jz RawReadHex_DigitFound_EndValue

    add ebx,1
    add ecx,1
    jmp RawReadHex_DigitFound_LoopValue

RawReadHex_DigitFound_EndValue:

    shl eax,4
    add eax,ecx
    jmp RawReadHex_Loop

RawReadHex_End:

    mov ebx,pointerOutput
    mov word ptr [ebx],ax

    xor eax,eax

RawReadHex_return:

    pop esi
    pop ebx
    ret

RawReadHex_Error:

    ;invoke MessageBox,NULL,arrayInput,NULL,MB_ICONWARNING
    xor eax,eax
    not eax
    jmp RawReadHex_return

RawReadHex EndP


DlgProc proc hWin    :DWORD,
             uMsg    :DWORD,
             wParam  :DWORD,
             lParam  :DWORD

    .if uMsg == WM_INITDIALOG
        invoke LoadIcon,hInstance,icon
        invoke SendMessage,hWin,WM_SETICON,1,eax

        ; Drop the Rockey dll from ressource to current dir
        invoke FindResource,hInstance,500,RT_RCDATA 
        mov hResource,eax
        invoke LoadResource,hInstance,hResource
        push eax
        invoke SizeofResource,hInstance,hResource
        mov SizeRes,eax
        pop eax
        invoke LockResource,eax
        push eax
        invoke GlobalAlloc,GPTR,SizeRes
        mov pData,eax
        mov ecx,SizeRes
        mov dword ptr[eax],ecx
        pop esi
        add edi,4
        mov edi,pData
        rep movsb
        invoke GetModuleFileName,NULL,addr SysDirect,0FFh
        invoke PathRemoveFileSpec,addr SysDirect
        invoke lstrcat,addr SysDirect,chr$('\Rockey4ND.dll')
        invoke DeleteFile,addr SysDirect
        invoke GetLastError
        cmp eax,5
        jz _end_
        invoke CreateFile,addr SysDirect,GENERIC_ALL,0,0,CREATE_ALWAYS,FILE_ATTRIBUTE_HIDDEN,0
        mov Handle2,eax
        cmp eax, -1
        jnz @F
        invoke MessageBox,hWin,chr$('Cannot create file Rockey4ND.dll!'),0,MB_ICONERROR
        jmp _end_1
        @@:invoke WriteFile,eax,pData,SizeRes,offset Bytes,0
        cmp eax, -1
        jnz _end_1
        invoke MessageBox,hWin,chr$('Cannot write data into Rockey4ND.dll!'),0,MB_ICONERROR
        _end_1:invoke CloseHandle,Handle2

        _end_:
        ; Get the Rockey function address
        invoke LoadLibrary,offset RockeyDll
        xor edx,edx
        mov handle,eax
        mov ebx,eax
        .if ebx
            invoke GetProcAddress,ebx,offset szRockeyFun
            mov Rockey,eax    
        .else
            invoke MessageBox,hWin,CTXT("Rockey4ND.dll not found"),CTXT("put it in same dir !"),MB_ICONINFORMATION
            invoke GetDlgItem,hWin,IDB_TEST
            invoke EnableWindow,eax,FALSE
        .endif
        invoke SetWindowText,hWin,addr szCtrlDlg_Title ; Set the window title text
        invoke SetDlgItemText,hWin,IDC_P1,addr szBasicPW1
        invoke SetDlgItemText,hWin,IDC_P2,addr szBasicPW2
        invoke SetDlgItemText,hWin,IDC_P3,addr szAdvancedPW1
        invoke SetDlgItemText,hWin,IDC_P4,addr szAdvancedPW2
        invoke SetDlgItemText,hWin,IDB_TEST,addr szCtrlBtn_Test
        invoke SetDlgItemText,hWin,IDB_QUIT,addr szCtrlBtn_Quit
        
        invoke SetDlgItemText,hWin,IDC_STATIC1046,addr szCtrlLbl_P1
        invoke SetDlgItemText,hWin,IDC_STATIC1047,addr szCtrlLbl_P2
        invoke SetDlgItemText,hWin,IDC_STATIC1048,addr szCtrlLbl_P3
        invoke SetDlgItemText,hWin,IDC_STATIC1049,addr szCtrlLbl_P4

    .elseif uMsg == WM_COMMAND
        .if wParam == IDB_TEST
            ; Check that P1,P2,P3,P4 are okish
            invoke GetDlgItemText,hWin,IDC_P1,addr szBufP1,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke GetDlgItemText,hWin,IDC_P2,addr szBufP2,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke GetDlgItemText,hWin,IDC_P3,addr szBufP3,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke GetDlgItemText,hWin,IDC_P4,addr szBufP4,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2P3P4
            
            ; Put the passwords in variable p1, p2, p3, p4
            invoke RawReadHex,addr szBufP1,addr p1
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke RawReadHex,addr szBufP2,addr p2
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke RawReadHex,addr szBufP3,addr p3
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2P3P4
            invoke RawReadHex,addr szBufP4,addr p4
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2P3P4

            jmp DlgProc_Test

            DlgProc_Command_ErrorP1P2P3P4:
            invoke MessageBox,NULL,addr errorInputP1P2P3P4,NULL,MB_ICONWARNING
            jmp endz

                DlgProc_Test:
            ; P1 and P2 Looks good, let's find the dongle

            ; Find Rockey
            invoke RockeyAS,RY_FIND
                .if (ax == 0)
                    ; Get the HWID
                    invoke WriteHex,lp1, addr tmphardID
                    invoke lstrcat,offset BufHIDlogs,addr szSuccess1
                    invoke lstrcat,offset BufHIDlogs,addr tmphardID
                    invoke SetDlgItemText,hWin,1005,addr BufHIDlogs
                    invoke RtlZeroMemory,addr tmphardID,sizeof tmphardID
                    invoke RtlZeroMemory,addr BufHIDlogs,sizeof BufHIDlogs
                .elseif (ax == 4)
                    ; Bad dongle passwords
                    invoke SetDlgItemText,hWin,1005,addr szFailBad1
                    jmp endz
                .else
                    ; Dongle not found
                    invoke SetDlgItemText,hWin,1005,addr szFailNF1
                    jmp endz
                .endif

            ; Open Rockey
            invoke RockeyAS,RY_OPEN
                .if (ax == 0)
                    invoke SetDlgItemText,hWin,1007,addr szSuccess2
                .else
                    invoke SetDlgItemText,hWin,1007,addr szFail2
                .endif

            ; Write Rockey
            mov p1,4
            mov p2,5
            invoke lstrcpy, ADDR buffer, ADDR info1
            invoke RockeyAS,RY_WRITE
                .if (ax == 0)
                    invoke SetDlgItemText,hWin,1009,addr szSuccess3
                .else
                    invoke SetDlgItemText,hWin,1009,addr szFail3
                .endif

            ; Read
            mov p1,4
            mov p2,5
            invoke RtlZeroMemory,ADDR buffer, 64
            invoke RockeyAS,RY_READ
                .if (ax == 0)
                    invoke lstrcat,addr tmpbuffer1,addr szSuccess4
                    invoke lstrcat,addr tmpbuffer1,addr buffer
                    invoke SetDlgItemText,hWin,1011,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                .else
                    invoke SetDlgItemText,hWin,1011,addr szFail4
                .endif

            ; Random
            invoke RockeyAS,RY_RANDOM
                .if (ax == 0)
                    invoke wsprintf,addr tmpbuffer1,addr szFmt2,addr szSuccess5 
                    invoke wsprintf,addr tmpbuffer,addr szFmt1,addr p1
                    invoke lstrcat,addr tmpbuffer1,addr tmpbuffer
                    invoke SetDlgItemText,hWin,1013,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer,sizeof tmpbuffer
                .else
                    invoke SetDlgItemText,hWin,1013,addr szFail5
                .endif

            ; Seed code
            mov lp2,12345678h
            invoke RockeyAS,RY_RANDOM
                .if (ax == 0)
                    invoke wsprintf,addr tmpbuffer1,addr szFmt2,addr szSuccess6 
                    invoke wsprintf,addr tmpbuffer,addr szFmt3,addr p1,addr p2,addr p3,addr p4
                    invoke lstrcat,addr tmpbuffer1,addr tmpbuffer
                    invoke SetDlgItemText,hWin,1015,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer,sizeof tmpbuffer
                .else
                    invoke SetDlgItemText,hWin,1015,addr szFail6
                .endif

            ; Write USER ID
            mov lp1,088888888h
            invoke RockeyAS,RY_WRITE_USERID
                .if (ax == 0)
                    invoke WriteHex,lp1, addr tmpuserID
                    invoke lstrcat,offset BufUIDlogs,addr szSuccess7
                    invoke lstrcat,offset BufUIDlogs,addr tmpuserID
                    invoke SetDlgItemText,hWin,1017,addr BufUIDlogs
                    invoke RtlZeroMemory,addr tmpuserID,sizeof tmpuserID
                    invoke RtlZeroMemory,addr BufUIDlogs,sizeof BufUIDlogs
                .else
                    invoke SetDlgItemText,hWin,1017,addr szFail7
                .endif

            ; Read USER ID
            xor eax,eax
            mov lp1,eax
            invoke RockeyAS,RY_READ_USERID
                .if (ax == 0)
                    invoke WriteHex,lp1, addr tmpuserID
                    invoke lstrcat,offset BufUIDlogs,addr szSuccess8
                    invoke lstrcat,offset BufUIDlogs,addr tmpuserID
                    invoke SetDlgItemText,hWin,1019,addr BufUIDlogs
                    invoke RtlZeroMemory,addr tmpuserID,sizeof tmpuserID
                    invoke RtlZeroMemory,addr BufUIDlogs,sizeof BufUIDlogs
                .else
                    invoke SetDlgItemText,hWin,1019,addr szFail8
                .endif

            ; Set module
            mov p1,7
            mov p2,2121h
            mov p3,0
            invoke RockeyAS,RY_SET_MOUDLE
                .if (ax == 0)
                    invoke wsprintf,addr tmpbuffer1,addr szFmt2,addr sz1
                    invoke wsprintf,addr tmpbuffer,addr szFmt1,addr p2
                    invoke lstrcat,addr tmpbuffer1,addr tmpbuffer
                    invoke SetDlgItemText,hWin,1021,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer,sizeof tmpbuffer
                .else
                    invoke SetDlgItemText,hWin,1021,addr szFail9
                .endif

            ; Check module
            mov p1,7
            invoke RockeyAS,RY_CHECK_MOUDLE
                .if (ax == 0)
                    invoke wsprintf,addr tmpbuffer1,addr szFmt2,addr sz2
                    invoke wsprintf,addr tmpbuffer,addr szFmt4,addr p2,addr p3
                    invoke lstrcat,addr tmpbuffer1,addr tmpbuffer
                    invoke SetDlgItemText,hWin,1023,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer,sizeof tmpbuffer
                .else
                    invoke SetDlgItemText,hWin,1023,addr szFail10
                .endif

            ; Write arithmetic
            mov p1,0
            invoke lstrcpy, ADDR buffer, ADDR cmd
            invoke RockeyAS, RY_WRITE_ARITHMETIC
                .if (ax == 0)
                    invoke SetDlgItemText,hWin,1025,addr szSuccess11
                .else
                    invoke SetDlgItemText,hWin,1025,addr szFail11
                .endif

            ; To calculate arithmetic
            mov lp1,0
            mov lp2,7
            mov p1,5
            mov p2,3
            mov p3,1
            mov p4,0ffffh
            invoke RockeyAS, RY_CALCULATE1
                .if (ax == 0)
                    invoke wsprintf,addr tmpbuffer1,addr szFmt2,addr szSuccess12
                    invoke wsprintf,addr tmpbuffer,addr szFmt3,addr byte ptr p1,addr byte ptr p2,addr byte ptr p3,addr byte ptr p4
                    invoke lstrcat,addr tmpbuffer1,addr tmpbuffer
                    invoke SetDlgItemText,hWin,1027,addr tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer1,sizeof tmpbuffer1
                    invoke RtlZeroMemory,addr tmpbuffer,sizeof tmpbuffer
                .else
                    invoke SetDlgItemText,hWin,1027,addr szFail12
                .endif
                endz:

            ; Close dongle handle
            invoke RockeyAS, RY_CLOSE
                .if (ax == 0)
                    invoke SetDlgItemText,hWin,1028,addr szSuccess14
                .else
                    invoke SetDlgItemText,hWin,1028,addr szFail14
                .endif

        .elseif wParam == IDB_QUIT
            invoke SendMessage,hWin,WM_CLOSE,0,0
        .endif
    .elseif uMsg == WM_CLOSE
            invoke FreeLibrary,handle
            invoke DeleteFile,addr SysDirect
            invoke GetLastError
            cmp eax,-1
            jnz @F
               invoke MessageBox,hWin,chr$('Cannot delete file Rockey4ND.dll!'),0,MB_ICONERROR
            @@:
            invoke EndDialog,hWin,0
    .endif

    xor eax,eax
    ret
DlgProc EndP

RockeyAS proc stdcall USES ebx,rcode:DWORD
    push offset buffer
    push offset p4
    push offset p3
    push offset p2
    push offset p1
    push offset lp2
    push offset lp1
    push offset handle
    mov ebx,rcode
    push ebx
    call Rockey

    ret
RockeyAS EndP

end start