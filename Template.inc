; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Include Files
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

include windows.inc
include kernel32.inc
include user32.inc
include comctl32.inc
include comdlg32.inc
include shell32.inc
include shlwapi.inc
include d:\masm32\macros\macros.asm


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Include libraries
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

includelib kernel32.lib
includelib user32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib shell32.lib
includelib shlwapi.lib


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Function Prototypes
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc		proto	:HWND, :UINT, :WPARAM, :LPARAM		
GetFileName proto   :HWND, :LPSTR, :LPSTR
PIPE_PROC	proto	:HWND, :DWORD, :DWORD