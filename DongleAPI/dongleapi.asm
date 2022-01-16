.486
.model flat, stdcall
option casemap :none ; case sensitive

include           \masm32\include\windows.inc
include           \masm32\include\user32.inc
include           \masm32\include\kernel32.inc
include           \masm32\macros\macros.asm
include           libs\Rockey4ND.inc
include           \masm32\include\shlwapi.inc

includelib        \masm32\lib\user32.lib
includelib        \masm32\lib\kernel32.lib
includelib        \masm32\lib\shlwapi.lib

DlgProc            PROTO :DWORD,:DWORD,:DWORD,:DWORD
RawReadHex         PROTO :DWORD,:DWORD
RockeyAS           PROTO rcode:DWORD

icon               equ 1002

IDC_FIND           equ 1003
IDC_CANCEL         equ 1004
IDC_OPEN           equ 1005
IDC_READ           equ 1006
IDC_READUSERID     equ 1008
IDC_BASICPW1       equ 1009
IDC_BASICPW2       equ 1010

MASK_UPPERCASE     equ 0DFh
MAXSiZE            equ 10h

.data
hexadecimalDigits       db "0123456789ABCDEF",0
errorInputP1P2          db "P1 and P2 must be four-digits hexadecimal numbers, without spaces!", 0
szBasicPW1              db "4839",0
szBasicPW2              db "4BBB",0

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

status                  dd ?

szBufP1                 dd 4 dup(0)
szBufP2                 dd 4 dup(0)

.data?
hInstance               dd ? ; Handle for loaded program

;to drop the dll
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
    invoke DialogBoxParam,hInstance,101,0,ADDR DlgProc,0
    invoke ExitProcess,eax

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
            mov status,0 ; button statut

            ;Drop the Rockey dll from ressource to current dir
            invoke FindResource,hInstance,500,RT_RCDATA 
            mov hResource, eax
            invoke LoadResource,hInstance,hResource
            push eax
            invoke SizeofResource,hInstance,hResource
            mov SizeRes, eax
            pop eax
            invoke LockResource,eax
            push eax
            invoke GlobalAlloc,GPTR,SizeRes
            mov pData, eax
            mov ecx, SizeRes
            mov dword ptr[eax], ecx
            pop esi
            add edi, 4
            mov edi, pData
            rep movsb
            invoke GetModuleFileName,NULL,addr SysDirect,0FFh
            invoke PathRemoveFileSpec,addr SysDirect
            invoke lstrcat,addr SysDirect,chr$('\Rockey4ND.dll')
            invoke DeleteFile,addr SysDirect
            invoke GetLastError
            cmp eax, 5
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

            ;Get the Rockey function address
            invoke LoadLibrary,offset RockeyDll
            xor edx,edx
            mov handle,eax
            mov ebx,eax
            .if ebx
                invoke GetProcAddress,ebx,offset szRockeyFun
                mov Rockey,eax    
            .else
                invoke MessageBox,hWin,CTXT("Rockey4ND.dll not found"),CTXT("put it in same dir !"),MB_ICONINFORMATION
            .endif
            
            invoke SetDlgItemText,hWin,IDC_BASICPW1,addr szBasicPW1
            invoke SetDlgItemText,hWin,IDC_BASICPW2,addr szBasicPW2
    .elseif uMsg == WM_COMMAND
        .if wParam == IDC_FIND
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
            jmp DlgProc_Find

            DlgProc_Command_ErrorP1P2:
            invoke MessageBox,NULL,addr errorInputP1P2,NULL,MB_ICONWARNING


                DlgProc_Find:
            ;Find Rockey
            invoke RockeyAS,RY_FIND
                .if (eax == 0)
                      invoke MessageBox,hWin,CTXT("RY_FIND OK"),CTXT("Result"),MB_OK
                .else
                    invoke MessageBox,hWin,CTXT("RY_FIND BAD"),CTXT("Result"),MB_OK
               .endif

        .elseif wParam == IDC_OPEN    
                .if status == 0
                    invoke SetDlgItemText,hWin,IDC_OPEN,chr$("RY_CLOSE")
                    invoke RockeyAS,RY_OPEN
                    .if (ax ==0)
                        invoke MessageBox,hWin,CTXT("RY_OPEN OK"),CTXT("Result"),MB_OK
                        mov status,1
                    .else
                        invoke MessageBox,hWin,CTXT("RY_OPEN BAD"),CTXT("Result"),MB_OK
                        mov status,0
                    .endif
                .else
                    invoke SetDlgItemText,hWin,IDC_OPEN,chr$("RY_OPEN")
                    invoke RockeyAS,RY_CLOSE
                    .if (ax ==0)
                        invoke MessageBox,hWin,CTXT("RY_CLOSE OK"),CTXT("Result"),MB_OK
                        mov status,0
                    .else
                        invoke MessageBox,hWin,CTXT("RY_CLOSE BAD"),CTXT("Result"),MB_OK
                        mov status,1
                    .ENDIF

                .endif

        .elseif wParam == IDC_READ
                mov p1, 4
                mov p2, 5
                invoke RtlZeroMemory,ADDR buffer, 64
                invoke RockeyAS,RY_READ
                .if (ax ==0)
                    invoke MessageBox,hWin,CTXT("RY_READ OK"),CTXT("Result"),MB_OK
                .else
                    invoke MessageBox,hWin,CTXT("RY_READ BAD"),CTXT("Result"),MB_OK
                .endif
        .elseif wParam == IDC_READUSERID
                invoke RockeyAS,RY_READ_USERID
                .if (ax ==0)
                    invoke MessageBox,hWin,CTXT("RY_READ_USERID OK"),CTXT("Result"),MB_OK
                .else
                    invoke MessageBox,hWin,CTXT("RY_READ_USERID BAD"),CTXT("Result"),MB_OK
                .endif
        .elseif wParam == IDC_CANCEL
                invoke RockeyAS,RY_CLOSE
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