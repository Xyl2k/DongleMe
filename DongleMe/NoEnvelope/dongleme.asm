.486
.model flat, stdcall
option casemap :none ; case sensitive

include           \masm32\include\windows.inc
include           \masm32\include\user32.inc
include           \masm32\include\kernel32.inc
include           \masm32\include\winmm.inc
include           \masm32\macros\macros.asm
include           libs\Rockey4ND.inc
include           libs\ufmod.inc
include           \masm32\include\shlwapi.inc

includelib        \masm32\lib\shlwapi.lib
includelib        \masm32\lib\user32.lib
includelib        \masm32\lib\kernel32.lib
includelib        \masm32\lib\winmm.lib
includelib        libs\ufmod.lib

DlgProc           PROTO :DWORD,:DWORD,:DWORD,:DWORD
RockeyAS          PROTO rcode:DWORD

.const
IDB_QUIT                   equ 1003
IDB_ACTIVATE               equ 1004
IDC_LBL_USERID             equ 1020
IDC_LBL_HARDWAREID         equ 1018
IDC_LBL_DONGLESTATUT       equ 1017
IDC_LBL_REGISTRATIONSTATUT equ 1021
IDC_TUNE                   equ 488

.data
;dialog text
szSuccess1              db 'DONGLE FOUND !',0
szSuccess2              db 'Registered to: ',0
szFail1                 db 'DONGLE NOT FOUND OR WRONG DONGLE!',0
szFail2                 db 'FAiLED - UNREGiSTERED !',0

;tied dongle info
szGoodHWiD              db "5F0E5CA0",0
szGoodUiD               db "00001337",0

;dongle sdk stuff
RockeyDll               db "Rockey4ND.dll",0
szRockeyFun             db 'Rockey',0
Rockey                  dd 0
handle                  dd 0
lp1                     dd 0
lp2                     dd 0
p1                      dw 04839h
p2                      dw 04BBBh
p3                      dw 0h
p4                      dw 0h
buffer                  db 1024 dup(0)

;buffers
szRegister              db 50 dup(0)
tmpuserID               db 10 dup(0)
tmphardID               db 10 dup(0)

hexadecimal_digits      db "0123456789ABCDEF",0

.data?
hInstance               dd ? ;dd can be written as dword

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

WriteHex proc integer:DWORD, Bufferhex:DWORD
    ; This procedure produces a string with the hex representation of an
    ; unsigned 32-bit integer into the provided buffer, padded with zeros 
    mov ecx,Bufferhex
    mov al,[hexadecimal_digits]
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
    lea ebx,[hexadecimal_digits]
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
WriteHex endp


DlgProc proc    hWin    :DWORD,
                uMsg    :DWORD,
                wParam  :DWORD,
                lParam  :DWORD

    .if uMsg == WM_INITDIALOG
            invoke LoadIcon,hInstance,200
            invoke SendMessage, hWin, WM_SETICON, 1, eax

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
                invoke GetDlgItem,hWin,IDB_ACTIVATE
                invoke EnableWindow, eax, FALSE
            .endif
            invoke uFMOD_PlaySong,IDC_TUNE,hInstance,XM_RESOURCE

    .elseif uMsg==WM_COMMAND
            .if wParam == IDB_QUIT
            invoke SendMessage,hWin,WM_CLOSE,0,0
            .elseif wParam == IDB_ACTIVATE
            mov p1, 4839h
            mov p2, 4BBBh
                invoke RockeyAS,RY_FIND
                   .if (ax == 0)
                         invoke SetDlgItemText,hWin,IDC_LBL_DONGLESTATUT,addr szSuccess1
                         invoke WriteHex,lp1, addr tmphardID
                         invoke SetDlgItemText,hWin,IDC_LBL_HARDWAREID,addr tmphardID
                         ;Open Rockey
                         invoke RockeyAS,RY_OPEN
                            .if (ax ==0)
                                  ;Read USER ID
                                  xor eax, eax
                                  mov lp1, eax
                                  invoke RockeyAS, RY_READ_USERID
                                      .if (ax ==0)
                                            invoke RtlZeroMemory,addr tmpuserID,sizeof tmpuserID
                                            invoke WriteHex,lp1, addr tmpuserID
                                            invoke SetDlgItemText,hWin,IDC_LBL_USERID,addr tmpuserID
                                            invoke lstrcmpi,addr szGoodHWiD,addr tmphardID
                                                 .if eax!=0
                                                       invoke SetDlgItemText,hWin,IDC_LBL_REGISTRATIONSTATUT,addr szFail2
                                                 .else
                                                       invoke lstrcmpi,addr szGoodUiD,addr tmpuserID
                                                              .if eax!=0
                                                                     invoke SetDlgItemText,hWin,IDC_LBL_REGISTRATIONSTATUT,addr szFail2
                                                              .else
                                                                     ;Read
                                                                     invoke RtlZeroMemory,ADDR szRegister,sizeof szRegister
                                                                     mov p1, 0 ; depart
                                                                     mov p2, 20h ;taile total
                                                                     invoke RtlZeroMemory,ADDR buffer,50
                                                                     invoke RockeyAS, RY_READ
                                                                         .if (ax ==0)
                                                                            invoke lstrcat,addr szRegister,addr szSuccess2
                                                                            invoke lstrcat,addr szRegister,addr buffer
                                                                            invoke SetDlgItemText,hWin,IDC_LBL_REGISTRATIONSTATUT,addr szRegister
                                                                         .else
                                                                            invoke SetDlgItemText,hWin,IDC_LBL_REGISTRATIONSTATUT,addr szFail2
                                                                         .endif  
                                                              .endif
                                                 .endif
                                      .else
                                          invoke SetDlgItemText,hWin,IDC_LBL_USERID,addr szFail2
                                      .endif                   
                            .else
                                invoke SetDlgItemText,hWin,1007,addr szFail2
                            .endif
                   .else
                       invoke SetDlgItemText,hWin,IDC_LBL_DONGLESTATUT,addr szFail1
                       invoke SetDlgItemText,hWin,IDC_LBL_HARDWAREID,addr tmphardID
                   .endif
                   invoke RockeyAS, RY_CLOSE
            .endif

    .elseif uMsg == WM_CLOSE
            invoke FreeLibrary,handle
            invoke DeleteFile,addr SysDirect
            invoke GetLastError
            cmp eax,-1
            jnz @F
               invoke MessageBox,hWin,chr$('Cannot delete file Rockey4ND.dll!'),0,MB_ICONERROR
            @@:
            invoke uFMOD_PlaySong,0,0,0
            invoke EndDialog,hWin,0
    .endif

    xor eax,eax
    ret
DlgProc endp

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
RockeyAS endp

end start
