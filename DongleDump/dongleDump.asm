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

DlgProc                 PROTO :DWORD,:DWORD,:DWORD,:DWORD
CommaSeparatedHex       PROTO :DWORD,:DWORD,:DWORD,:DWORD
WriteHex                PROTO :DWORD,:DWORD
RawReadHex              PROTO :DWORD,:DWORD
List                    PROTO :DWORD,:DWORD
RockeyAS                PROTO rcode:DWORD

.const
icon                    equ 1002

IDB_DUMP                equ 1003
IDB_QUIT                equ 1004
IDB_HELP                equ 1044
IDC_BASICPW1            equ 1042
IDC_BASICPW2            equ 1043
IDC_LISTBOX             equ 1007
IDC_STATIC1045          equ 1045
IDC_STATIC1046          equ 1046
IDC_STATIC1049          equ 1049

CHAR_CARRIAGE_RETURN    equ 13
CHAR_COMMA              equ 44
CHAR_DOUBLE_QUOTES      equ 34
CHAR_LINE_FEED          equ 10
CHAR_SLASH_BACKWARD     equ 92

MAXSiZE                 equ 10h
MASK_UPPERCASE          equ 0DFh
SIZE_GENERAL            equ 8096

SIZE_REG                equ 500
WRAP_REG                equ 16

.data
; Filename for dump
DumpBeginingName        db "Dumped_",0
DumpExt                 db ".dng",0

; ROCKEY4ND Function Prototype and Definition
RockeyDll               db "Rockey4ND.dll",0
szRockeyFun             db 'Rockey',0
Rockey                  dd 0
handle                  dd 0
lp1                     dd 0
lp2                     dd 0
p1                      dw 0C44Ch ; ROCKEY4ND Demo Password1
p2                      dw 0C8F8h ; ROCKEY4ND Demo Password2
p3                      dw 00799h ; ROCKEY4ND Demo Password3
p4                      dw 0C43Bh ; ROCKEY4ND Demo Password4
buffer                  db 1024 dup(0)

buffer2                 db 1024 dup(0)
UDZ1                    db 1600 dup(0)
UDZ2                    db 1600 dup(0)

; Listbox text infos
sziNFO1                 db "Rockey4ND Dongle Dumper v0.1",0
sziNFO2                 db ">>>> START DONGLE DUMPING <<<<",0
sziNFOEnd               db ">>>> END DONGLE DUMPING <<<<",0
sziNFO3                 db "Searching Rockey4ND Dongle attached to computer...",0
szbad1                  db "BAD P1",0
nullz                   db " ",0
szbad2                  db "BAD P2",0
szbad3                  db "open the dongle with specified passwords: BAD",0
szbad4                  db "Reading memory zone 1: BAD",0
szbad5                  db "Failed to read dongle UID",0
sznotFound              db "Dongle not found",0
szbad6                  db "ROCKEY4ND found, with incorrect basic password",0
sziNFO4                 db "HardwareID (HID): ",0
sziNFO5                 db "UserID (UID): ",0
sziNFO6                 db "open the dongle with specified passwords: OK",0
sziNFO7                 db "Reading memory zone 1: OK",0
sziNFO8                 db "Reading memory zone 2: OK",0
sziNFO9                 db "Saving: ",0
szabout1                db "USAGE:",0
szabout2                db "1. Insert Rockey4ND Dongle into the USB port.",0
szabout3                db "2. Enter Pass1 and Pass2 (hex) example (1234 ABCD).",0
szabout4                db "3. push 'Backup Dongle' button.",0
szabout5                db "4. all data will be saved in same folder as this exe.",0
szabout6                db "Enjoy!!!",0

; Dialog text
szCtrlTxt_p1            db "P1:",0
szCtrlTxt_p2            db "P2:",0
szCtrlBtn_Help          db "?",0
szCtrlBtn_Backup        db "Backup Dongle",0
szCtrlBtn_Quit          db "Quit",0
szCtrlDlg_Title         db "Rockey4ND Dongle Dumper v0.1",0
szCtrlTxt_Author        db "x!",0
szCtrlTxt_Setp1         db "4839",0
szCtrlTxt_Setp2         db "4BBB",0

; General Buffers
DumpFileName            db 60 dup(0)
tmpbuffer               db 60 dup(0)
tmpuserID               db 10 dup(0)
tmphardID               db 10 dup(0)
BufHIDlogs              db 30 dup(0)
BufUIDlogs              db 30 dup(0)
Bufsavelogs             db 40 dup(0)

szBufP1                 dd 4 dup(0) ; Buffer for what the user enter in input
szBufP2                 dd 4 dup(0) ; Buffer for what the user enter in input
szSuccess2              db "Open Rockey successed",0
errorInputP1P2          db "P1 and P2 must be four-digits hexadecimal numbers, without spaces!", 0

reg                     db 500 dup (032h) 
hexadecimalDigits       db "0123456789ABCDEF",0

; dump skelleton
info1                   db "REGEDIT4", 13, 10, 13, 10,
                        "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\R4ndKeys\Dumps\",0      
info2                   db "]", 13, 10, 34, "Name", 34, "=", 34, "Dump for ",0
info3                   db " dongle", 34, 13, 10, 34, "Copyright", 34, "=", 34, "None",34, 13, 10, 34,
                        "Created", 34, "=", 34, 0
info4                   db 34, 13, 10, 34, "Pass1", 34, "=dword:0000",0
info5                   db 13, 10, 34, "Pass2", 34, "=dword:0000",0
info6                   db 13, 10, 34, "HardwareID", 34, "=dword:",0
info7                   db 13, 10, 34, "UserID", 34, "=dword:",0
info8                   db 13, 10, 13, 10, 34, "UDZ1", 34, "=hex:", 05Ch, 13, 10,0
info9                   db 13, 10, 34, "UDZ2", 34, "=hex:", 05Ch, 13, 10,0

singleComma             db CHAR_COMMA,0
backwardSlash           db CHAR_SLASH_BACKWARD,0
lineBreak               db 13,10,0

bufferstring            db 1024 dup(0)
bufferDate              db 100 dup(0)
formatDate              db "dd-MM-yyyy",0

.data?
hInstance               dd ? ; Handle for loaded program
hFile                   dd ? ; Handle for output file

arrayGeneral            dd ? ; Pointer to general-purpose array
arrayHexDigits          dd ? ; Pointer to array for hex digits
arrayUDZ1               dd ? ; Pointer to general-purpose array

countWritten            dd ? ; Counter for bytes written to file

processHeap             dd ? ; Handle to the process heap

timeRaw                 SYSTEMTIME<>
NumOfBytesWritten       DWORD ?

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
    mov hInstance,eax
    invoke GetProcessHeap
    mov processHeap,eax
    invoke HeapAlloc,processHeap,HEAP_ZERO_MEMORY,SIZE_GENERAL
    mov arrayGeneral,eax
    invoke DialogBoxParam,hInstance,101,0,addr DlgProc,0
    invoke HeapFree,processHeap,0,arrayGeneral
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

CommaSeparatedHex proc arrayInput    :DWORD,
                       lengthInput   :DWORD,
                       lengthWrap    :DWORD,
                       arrayOutput   :DWORD

    push ebx
    push esi
    push edi

    xor eax,eax
    cmp lengthInput,eax
    jz CommaSeparatedHex_End

    lea ebx,[hexadecimalDigits]
    mov esi,arrayInput
    mov edi,arrayOutput

    ; ecx is the counter that controls the text wrap
    xor ecx,ecx

CommaSeparatedHex_Loop:

    sub lengthInput,1
    add ecx,1

    mov al,[esi]
    add esi,1

    ror al,4
    movzx edx,al
    and edx,00Fh
    mov dl,[ebx+edx]
    mov [edi],dl
    add edi,1

    ror al,4
    movzx edx,al
    and edx,00Fh
    mov dl,[ebx+edx]
    mov [edi],dl
    add edi,1

    xor eax,eax
    cmp eax,lengthInput
    jz CommaSeparatedHex_End

    mov al,CHAR_COMMA
    mov [edi],al
    add edi,1

    cmp ecx,lengthWrap
    jnz CommaSeparatedHex_Loop

    mov al,CHAR_SLASH_BACKWARD
    mov [edi],al
    add edi,1

    mov al,CHAR_CARRIAGE_RETURN
    mov [edi],al
    add edi,1

    mov al,CHAR_LINE_FEED
    mov [edi],al
    add edi,1

    xor ecx,ecx

    jmp CommaSeparatedHex_Loop

CommaSeparatedHex_End:

    mov al,CHAR_CARRIAGE_RETURN
    mov [edi],al
    add edi,1

    mov al,CHAR_LINE_FEED
    mov [edi],al
    add edi,1

    xor al,al
    mov [edi],al

CommaSeparatedHex_return:

    pop edi
    pop esi
    pop ebx
    ret

CommaSeparatedHex EndP


DlgProc proc    hWin    :DWORD,
                uMsg    :DWORD,
                wParam  :DWORD,
                lParam  :DWORD
    .if uMsg == WM_INITDIALOG
            invoke LoadIcon,hInstance,icon
            invoke SendMessage,hWin,WM_SETICON,1,eax

            ; Set the control texts
            invoke SetWindowText,hWin,addr szCtrlDlg_Title ; Set the window title text
            invoke SetDlgItemText,hWin,IDB_DUMP,addr szCtrlBtn_Backup
            invoke SetDlgItemText,hWin,IDB_QUIT,addr szCtrlBtn_Quit
            invoke SetDlgItemText,hWin,IDB_HELP,addr szCtrlBtn_Help
            invoke SetDlgItemText,hWin,IDC_STATIC1045,addr szCtrlTxt_p1
            invoke SetDlgItemText,hWin,IDC_STATIC1046,addr szCtrlTxt_p2
            invoke SetDlgItemText,hWin,IDC_STATIC1049,addr szCtrlTxt_Author
            invoke SetDlgItemText,hWin,IDC_BASICPW1,addr szCtrlTxt_Setp1
            invoke SetDlgItemText,hWin,IDC_BASICPW2,addr szCtrlTxt_Setp2

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
                invoke GetDlgItem,hWin,IDB_DUMP
                invoke EnableWindow,eax,FALSE
            .endif

            invoke List,hWin,addr sziNFO1
            invoke List,hWin,addr nullz

    .elseif uMsg == WM_COMMAND
        .if wParam == IDB_DUMP
            invoke List,hWin,addr sziNFO2
            ; Check that P1 and P2 are good
            invoke GetDlgItemText,hWin,IDC_BASICPW1,addr szBufP1,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2
            invoke GetDlgItemText,hWin,IDC_BASICPW2,addr szBufP2,MAXSiZE
            cmp eax, 4
            jnz DlgProc_Command_ErrorP1P2
            
            ; Put the passwords in variable p1 and p2
            invoke RawReadHex,addr szBufP1,addr p1
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2
            invoke RawReadHex,addr szBufP2,addr p2
            cmp eax, 0
            jnz DlgProc_Command_ErrorP1P2
            jmp DlgProc_Dump

            DlgProc_Command_ErrorP1P2:
            invoke MessageBox,NULL,addr errorInputP1P2,NULL,MB_ICONWARNING
            jmp endz

                DlgProc_Dump:
                     ; P1 and P2 Looks good, let's find the dongle
                     invoke List,hWin,addr sziNFO3
                     invoke RockeyAS,RY_FIND
                        .if (ax == 0)
                            ; Get the HWID
                             invoke WriteHex,lp1, addr tmphardID
                             invoke lstrcat,offset BufHIDlogs,addr sziNFO4
                             invoke lstrcat,offset BufHIDlogs,addr tmphardID
                             invoke List,hWin,addr BufHIDlogs
                        .elseif (ax == 4)
                             ; Bad dongle passwords
                             invoke List,hWin,addr szbad6
                             jmp endz
                        .else
                             ; Dongle not found
                             invoke List,hWin,addr sznotFound
                             jmp endz
                        .endif

                        ; Open Rockey dongle
                        invoke RockeyAS,RY_OPEN
                        .if (ax !=0)
                            invoke List,hWin,addr szbad3
                            jmp endz
                        .endif

                        ; Read USER ID
                        xor eax, eax
                        mov lp1, eax
                        invoke RockeyAS,RY_READ_USERID
                        .if (ax ==0)
                            ; Clean the buffers, format the uid, format output filename with hwid
                            invoke RtlZeroMemory,addr DumpFileName,sizeof DumpFileName
                            invoke RtlZeroMemory,addr tmpuserID,sizeof tmpuserID
                            invoke WriteHex,lp1, addr tmpuserID
                            invoke lstrcat,offset BufUIDlogs,addr sziNFO5
                            invoke lstrcat,offset BufUIDlogs,addr tmpuserID
                            invoke List,hWin,addr BufUIDlogs
                            invoke lstrcat,addr DumpFileName,addr DumpBeginingName
                            invoke lstrcat,addr DumpFileName,addr tmphardID
                            invoke lstrcat,addr DumpFileName,addr DumpExt
                        .else
                            invoke List,hWin,addr szbad5
                            jmp endz
                        .endif

                        ; Read user zone 1
                        mov p1,0 ; Start offset
                        mov p2,500 ; Size
                        invoke RtlZeroMemory,addr buffer,500
                        invoke RockeyAS,RY_READ
                        .if (ax ==0)
                           invoke List,hWin,addr sziNFO7
                        .else
                           invoke List,hWin,addr szbad4
                           jmp endz
                        .endif

                        invoke GetLocalTime, addr timeRaw
                        invoke GetDateFormat,LOCALE_USER_DEFAULT,NULL,addr timeRaw,addr formatDate,addr bufferDate,sizeof bufferDate

                        ; Format the output file content
                        invoke lstrcat,offset bufferstring,offset info1
                        invoke lstrcat,offset bufferstring,offset tmphardID
                        invoke lstrcat,offset bufferstring,offset info2
                        invoke lstrcat,offset bufferstring,offset tmphardID
                        invoke lstrcat,offset bufferstring,offset info3
                        invoke lstrcat,offset bufferstring,offset bufferDate
                        invoke lstrcat,offset bufferstring,offset info4
                        invoke lstrcat,offset bufferstring,offset szBufP1
                        invoke lstrcat,offset bufferstring,offset info5
                        invoke lstrcat,offset bufferstring,offset szBufP2
                        invoke lstrcat,offset bufferstring,offset info6
                        invoke lstrcat,offset bufferstring,offset tmphardID
                        invoke lstrcat,offset bufferstring,offset info7
                        invoke lstrcat,offset bufferstring,offset tmpuserID
                        invoke lstrcat,offset bufferstring,offset info8
                        invoke lstrcat,arrayGeneral,offset bufferstring
                        invoke CommaSeparatedHex,addr buffer,SIZE_REG,WRAP_REG,addr UDZ1
                        invoke lstrcat,arrayGeneral,offset UDZ1
                        invoke lstrcat,arrayGeneral,offset info9

                        ; Read user zone 2
                        mov p1,500 ; Start offset
                        mov p2,500 ; Size
                        invoke RtlZeroMemory,addr buffer,500
                        invoke RockeyAS,RY_READ
                        .if (ax ==0)
                           invoke List,hWin,addr sziNFO8
                        .else
                           invoke List,hWin,addr szbad4
                           jmp endz
                        .endif

                        ; Format the output file content
                        invoke CommaSeparatedHex,addr buffer,SIZE_REG,WRAP_REG,addr UDZ2
                        invoke lstrcat, arrayGeneral,offset UDZ2
                        invoke lstrcat,offset Bufsavelogs,addr sziNFO9
                        invoke lstrcat,offset Bufsavelogs,addr DumpFileName
                        invoke List,hWin,addr Bufsavelogs

                        invoke CreateFile,addr DumpFileName,GENERIC_READ OR GENERIC_WRITE,FILE_SHARE_READ OR FILE_SHARE_WRITE,0,OPEN_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
                        mov hFile,eax
                        invoke lstrlen,arrayGeneral
                        invoke WriteFile,hFile,arrayGeneral,eax,offset countWritten,NULL
                        invoke CloseHandle,hFile

                endz:
                     ; Try to disconect and clean buffers
                     invoke RockeyAS,RY_CLOSE
                     invoke RtlZeroMemory,addr buffer, sizeof buffer
                     invoke RtlZeroMemory,addr arrayGeneral,sizeof arrayGeneral
                     invoke RtlZeroMemory,addr bufferstring,sizeof bufferstring
                     invoke RtlZeroMemory,addr p4,sizeof p4
                     invoke RtlZeroMemory,addr p3,sizeof p3
                     invoke RtlZeroMemory,addr p2,sizeof p2
                     invoke RtlZeroMemory,addr p1,sizeof p1
                     invoke RtlZeroMemory,addr lp2,sizeof lp2
                     invoke RtlZeroMemory,addr lp1,sizeof lp1
                     invoke RtlZeroMemory,addr BufHIDlogs,sizeof BufHIDlogs
                     invoke RtlZeroMemory,addr BufUIDlogs,sizeof BufUIDlogs
                     invoke RtlZeroMemory,addr Bufsavelogs,sizeof Bufsavelogs
                     invoke List,hWin,addr sziNFOEnd
                     invoke List,hWin,addr nullz
         .elseif wParam == IDB_HELP
            invoke List,hWin,addr nullz
            invoke List,hWin,addr szabout1
            invoke List,hWin,addr szabout2
            invoke List,hWin,addr szabout3
            invoke List,hWin,addr szabout4
            invoke List,hWin,addr szabout5
            invoke List,hWin,addr nullz
            invoke List,hWin,addr szabout6
            invoke List,hWin,addr nullz
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

List proc hWnd:HWND, pMsg:DWORD
    invoke SendDlgItemMessage,hWnd,IDC_LISTBOX,LB_ADDSTRING,0,pMsg 
    invoke SendDlgItemMessage,hWnd,IDC_LISTBOX,WM_VSCROLL,SB_BOTTOM,0
    ret
List EndP

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