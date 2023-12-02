; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; UPX GUI 0.1 By Lahar
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

.686p					;Use 686 instuction set to have all intel commands
.model flat, stdcall	;Use flat memory model since we are in 32bit 
option casemap: none	;Variables and others are case sensitive

include Template.inc	;Include our files containing libraries

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our initialised variables will go into in this .data section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.data
	szAppName			db	"UPX GUI 0.1",0
	szMpressTitle		db	"Select UPX file...",0
	szExeTitle			db	"Select file to compress...",0
	szFileExtFilters	db	"EXE Files (*.exe)",0,"*.exe",0,0
	szExeExtFilters		db	"EXE Files (*.exe)",0,"*.exe",0
						db	"DLL Files (*.dll)",0,"*.dll",0,0
	szFileName			db	300 dup (0)	
	szExeFileName		db	300 dup (0)	
	
	szLocationSection	db  "UPX",0,0
	szLocationKey		db	"Location",0,0,0
	szIniName			db	"UpxConfig.ini",0
	szArgSection		db  "ARGUMENTS",0,0
	szArgKey			db	"Arg",0,0,0
	szCreatePipeError	db	"Error",0
	szFormat			db	"%hS",0
	szInfo				db	"           UPX GUI 0.1 By Lahar", 13,10
						db  "---------------------------------------------------",13,10
						db  "   UPX is a free sofware packer. It has ",13,10
						db	"good compression ratio for the majority  ",13,10
						db  "of PE formats available today.	",13,10
						db	"---------------------------------------------------",13,10
						db	"   This tool comes with absolutely no warranty.",13,10
						db	"I am not responsible for whatever the enduser",13,10
						db  "may do with this tool or whatever his/her    ",13,10
						db  "system face. Its the sole responsibility of  ",13,10
						db	"the person who using it.",13,10
						db	"---------------------------------------------------",13,10
						db	"UPX site : http://upx.sourceforge.net/",13,10
						db  "Greetz to all winasm members.",13,10
						db	"---------------------------------------------------",13,10
						db	"      Contact : Laharrush@yahoo.com          ",0	


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our uninitialised variables will go into in this .data? section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.data?
	hInstance		HINSTANCE	?
	stOpenFileName	OPENFILENAME 	<?>
	stOpenFileName2	OPENFILENAME 	<?>
	ext					db	10 dup(?)
	szExeExt			db	10 dup(?)
	szFileNameOnly		db	120 dup(?)
	szParameters		db	120 dup(?)
	szExtraParameters 	db	120 dup(?)
	stFindData		WIN32_FIND_DATA <?>
	szLocation			db	120	dup(?)
	szCurrentDir		db	120	dup(?)
	szINILocation		db	120	dup(?)
	szFull				db	120	dup(?)
	szOutput			db  120	dup(?)
	szQuottedFile		db	255 dup (?)

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Our constant values will go onto this section
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.const
	IDD_DLGBOX				equ	1001
	;Edit Boxes
	IDC_MPRESSLOCATION		equ 1005
	IDC_SELECTFILE 			equ 1008
	IDC_COMMANDS 			equ 1011
	IDC_LOGWINDOW			equ	1014
	;Buttons
	IDC_COMPRESS 			equ 1012
	IDC_OPENMPRESS 			equ 1006
	IDC_OPENFILE 			equ 1009
	IDC_SAVEARGUMENTS		equ	1013
	IDC_ABOUT				equ	1015
	IDC_EXIT				equ	1002
	;Icon
	APP_ICON				equ	2000
	

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; This is the section to write our main code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
.code

start:	
	invoke GetModuleHandle, NULL
	mov hInstance, eax
	invoke InitCommonControls
	invoke DialogBoxParam, hInstance, IDD_DLGBOX, NULL, addr DlgProc, NULL
	invoke ExitProcess, NULL

DlgProc		proc	hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

    LOCAL pMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL hFile  :DWORD

	.if uMsg == WM_INITDIALOG
		invoke SetWindowText, hWnd, addr szAppName
		invoke LoadIcon, hInstance, APP_ICON
		invoke SendMessage, hWnd, WM_SETICON, 1, eax
		
		;Get the location of .ini file
		invoke GetCurrentDirectory,120, addr szCurrentDir
		invoke lstrcat, addr szINILocation, addr szCurrentDir
		invoke lstrcat, addr szINILocation, SADD("\")
		invoke lstrcat, addr szINILocation, addr szIniName
		
		;Fing if 'Config.ini' file exists if yes read ini file and show the data in the text boxes
		invoke FindFirstFile, addr szIniName, addr stFindData
		.if eax	!= (-1)
			invoke GetPrivateProfileString, addr szLocationSection, addr szLocationKey, 0, addr szLocation, 120, addr szINILocation
			invoke GetDlgItem, hWnd, IDC_MPRESSLOCATION
			invoke EnableWindow, eax,FALSE
			invoke SetDlgItemText, hWnd, IDC_MPRESSLOCATION, addr szLocation
			invoke GetPrivateProfileString, addr szArgSection, addr szArgKey, 0, addr szExtraParameters, 120, addr szINILocation
			invoke SetDlgItemText, hWnd, IDC_COMMANDS, addr szExtraParameters
		.else
			invoke GetDlgItem, hWnd, IDC_MPRESSLOCATION
			invoke EnableWindow, eax,TRUE
		.endif	
	.elseif uMsg == WM_COMMAND
		mov eax, wParam
		.if eax == IDC_EXIT
			invoke SendMessage, hWnd, WM_CLOSE, 0, 0
			
		;Select UPX Location	
		.elseif eax == IDC_OPENMPRESS	
			invoke RtlZeroMemory, addr szFileName, sizeof szFileName
				
			mov stOpenFileName.lStructSize, SIZEOF stOpenFileName
			mov stOpenFileName.hwndOwner, NULL
			mov stOpenFileName.hInstance, offset hInstance
			mov stOpenFileName.lpstrFilter, offset szFileExtFilters
			mov stOpenFileName.lpstrCustomFilter, NULL
			mov stOpenFileName.nFilterIndex,1
			mov stOpenFileName.lpstrFile, offset szFileName
			mov stOpenFileName.nMaxFile, SIZEOF szFileName
			mov stOpenFileName.lpstrTitle,offset szMpressTitle
			mov stOpenFileName2.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
			mov stOpenFileName.lpstrDefExt, offset ext
		
			invoke GetOpenFileName,addr stOpenFileName
			.if eax == TRUE
				;Set the MPRESS location into Config.ini file 
				invoke SetDlgItemText, hWnd, IDC_MPRESSLOCATION, addr szFileName
				invoke WritePrivateProfileString, addr szLocationSection, addr szLocationKey, addr szFileName, addr szINILocation
				;Also store the parameters info
				invoke GetDlgItemText, hWnd, IDC_COMMANDS, addr szExtraParameters, 40
				invoke WritePrivateProfileString, addr szArgSection, addr szArgKey, addr szExtraParameters, addr szINILocation		
			.endif
		
		;Select the file to compress
		.elseif eax == IDC_OPENFILE
		
			invoke RtlZeroMemory, addr szExeFileName, sizeof szExeFileName
			invoke RtlZeroMemory, addr szFileNameOnly, sizeof szFileNameOnly
			
			mov stOpenFileName2.lStructSize, SIZEOF stOpenFileName2
			mov stOpenFileName2.hwndOwner, NULL
			mov stOpenFileName2.hInstance, offset hInstance
			mov stOpenFileName2.lpstrFilter, offset szExeExtFilters
			mov stOpenFileName2.lpstrCustomFilter, NULL
			mov stOpenFileName2.nFilterIndex,1
			mov stOpenFileName2.lpstrFile, offset szExeFileName
			mov stOpenFileName2.nMaxFile, SIZEOF szExeFileName
			mov stOpenFileName2.lpstrTitle,offset szExeTitle
			mov stOpenFileName2.Flags,OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or OFN_EXPLORER or OFN_HIDEREADONLY
			mov stOpenFileName.lpstrDefExt, offset szExeExt
			
			invoke GetOpenFileName,addr stOpenFileName2
			.if eax != 0
				invoke GetFileName, hWnd, addr szExeFileName, addr szFileNameOnly
				invoke SetDlgItemText, hWnd, IDC_SELECTFILE, offset szExeFileName	
				invoke lstrcpy, addr szQuottedFile, addr szFileNameOnly
				invoke PathQuoteSpaces, addr szQuottedFile
			.endif
			
		;Compress Button
		.elseif eax == IDC_COMPRESS
			invoke RtlZeroMemory, addr szParameters, sizeof szParameters
			invoke GetDlgItemText, hWnd, IDC_COMMANDS, addr szExtraParameters, 40
			invoke lstrcat, addr szParameters, SADD(" ")
			invoke lstrcat, addr szParameters, addr szExtraParameters
			invoke lstrcat, addr szParameters, SADD(" ")
			invoke lstrcat, addr szParameters, addr szQuottedFile
			invoke GetPrivateProfileString, addr szLocationSection, addr szLocationKey, 0, addr szLocation, 120, addr szINILocation
			;invoke ShellExecute,hWnd, SADD("open"), addr szLocation, addr szParameters,NULL, SW_SHOW
			;invoke SetDlgItemText, hWnd, IDC_SELECTFILE, offset szParameters
			invoke SetDlgItemText,hWnd,1014,SADD(" ")
			invoke PIPE_PROC,hWnd,OFFSET szLocation, OFFSET szParameters
		
		;Save Extra Parameters	
		.elseif eax == IDC_SAVEARGUMENTS
			invoke GetDlgItemText, hWnd, IDC_COMMANDS, addr szExtraParameters, 40
			invoke WritePrivateProfileString, addr szArgSection, addr szArgKey, addr szExtraParameters, addr szINILocation		
		
		;About
		.elseif eax == IDC_ABOUT
			invoke MessageBox,hWnd, addr szInfo, addr szAppName, MB_OK+MB_ICONINFORMATION
		.endif
	.elseif uMsg == WM_CLOSE
		invoke EndDialog, hWnd, NULL
	.endif
	
	xor eax, eax				 
	Ret
DlgProc EndP

;This section is used to contact with console and the GUI
;Thanks to the creator of this function.
PIPE_PROC PROC hWnd:DWORD, ExeFile:DWORD, RunExc :DWORD
LOCAL rect			:RECT
LOCAL hRead			:DWORD
LOCAL hWrite		:DWORD
LOCAL startupinfo	:STARTUPINFO
LOCAL pinfo			:PROCESS_INFORMATION
LOCAL buffer[1024]	:BYTE
LOCAL bytesRead		:DWORD
LOCAL hdc			:DWORD
LOCAL sat			:SECURITY_ATTRIBUTES

        mov sat.nLength,sizeof SECURITY_ATTRIBUTES
        mov sat.lpSecurityDescriptor,NULL
        mov sat.bInheritHandle,TRUE
        invoke CreatePipe,addr hRead,addr  hWrite, addr sat,NULL
     .if eax==NULL
        invoke MessageBox,hWnd,addr szCreatePipeError,addr szAppName,MB_ICONERROR+MB_OK
       .else
        mov startupinfo.cb,sizeof STARTUPINFO
        invoke GetStartupInfo,addr startupinfo
        mov eax,hWrite
        mov startupinfo.hStdOutput,eax
        mov startupinfo.hStdError,eax
        mov startupinfo.dwFlags,STARTF_USESHOWWINDOW+STARTF_USESTDHANDLES
        mov startupinfo.wShowWindow,SW_HIDE

        invoke CreateProcess,ExeFile,RunExc,0,0 ,TRUE,0,0,0,addr startupinfo,addr pinfo
        .if eax==NULL
           invoke MessageBox,hWnd,addr szCreatePipeError,addr szAppName,MB_ICONERROR+MB_OK
         .else
            invoke CloseHandle,hWrite
         .while TRUE
          invoke RtlZeroMemory,addr buffer,1024
          invoke ReadFile,hRead,addr buffer,1023,addr bytesRead,NULL
          
         .if eax==NULL
          .break
         .else
        invoke wsprintf, addr szOutput, addr szFormat,addr buffer
        invoke SendDlgItemMessage,hWnd, 1014,EM_SETSEL,-1,0
        invoke SendDlgItemMessage,hWnd,1014,EM_REPLACESEL,FALSE,addr szOutput
     .endif
     .endw
    .endif
        invoke CloseHandle,hRead
        invoke CloseHandle,pinfo.hProcess
        invoke CloseHandle,pinfo.hThread
 .endif
ret
PIPE_PROC ENDP

;Function retrieves the Exe Name of the file to be compressed.
GetFileName proc hWnd:HWND, fileName:LPSTR, exeName:LPSTR

LOCAL tempName[120] : BYTE

		invoke lstrlen, fileName
		mov ecx, eax
		xor esi, esi
		
loopedd:	
		mov eax, fileName
		lea edi, tempName
		
		mov bl, byte ptr ds:[eax+ecx-1]
		cmp bl, 5ch							;Is it '/'
		jnz saved
		jmp LetJump
saved:	
		mov byte ptr ds:[edi+esi], bl
		inc esi
		dec ecx
		jnz loopedd
LetJump:	
		xor edi, edi
		xor edx, edx	
		xor ecx, ecx		
		lea eax, tempName
		mov ecx, exeName
Correct:		
		mov dl, byte ptr ds:[eax+esi-1]
		mov byte ptr ds:[ecx+edi], dl
		inc edi
		dec esi
		jnz Correct
		

	Ret
GetFileName EndP

end start	
	 