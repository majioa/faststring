	.386
	model  flat

;	include constant.inc
	PUBLIC	DllEntryPoint1

;	EXTRN	LoadBorlandMemoryFuncs:near
;	EXTRN	FreeBorlandMemoryFuncs:near
;	EXTRN	hBorlandMM:dword
;	EXTRN	GetMemory:dword
;	EXTRN	ReallocMemory:dword
;	EXTRN	FreeMemory:dword

	PUBLIC	MemoryAlloc
	PUBLIC	MemoryReAlloc
	PUBLIC	MemoryFree
	PUBLIC	LoadBorlandMemoryFuncs
	PUBLIC	FreeBorlandMemoryFuncs
	PUBLIC	GetSystemCodepage
	PUBLIC	GetMemInfoFuncs
	PUBLIC	GetDecimalSeparator
	PUBLIC	GetPositiveSign
	PUBLIC	GetNegativeSign
	PUBLIC	decimal_constant
;	PUBLIC	Sign_Symbols
;	PUBLIC	Floating_Point_Symbol

	EXTRN	Floating_point_symbol:byte
	EXTRN	Positive_sign_symbol:byte
	EXTRN	Negative_sign_symbol:byte

;	PUBLIC	hBorlandMM
;	PUBLIC	BorlandAllocMemory
;	PUBLIC	BorlandReallocMemory
;	PUBLIC	BorlandFreeMemory

;Global Memory Flags
	GMEM_FIXED		=	0000h
	GMEM_MOVEABLE		=	0002h
	GMEM_NOCOMPACT		=	0010h
	GMEM_NODISCARD		=	0020h
	GMEM_ZEROINIT		=	0040h
	GMEM_MODIFY		=	0080h
	GMEM_DISCARDABLE	=	0100h
	GMEM_NOT_BANKED 	=	1000h
	GMEM_SHARE		=	2000h
	GMEM_DDESHARE		=	2000h
	GMEM_NOTIFY		=	4000h
	GMEM_LOWER		=	GMEM_NOT_BANKED
	GMEM_VALID_FLAGS	=	7F72h
	GMEM_INVALID_HANDLE	=	8000h
	GHND			=	GMEM_MOVEABLE OR GMEM_ZEROINIT
	GPTR			=	GMEM_FIXED OR GMEM_ZEROINIT

;locale constants
	LOCALE_USER_DEFAULT	=	400h
	LOCALE_SDECIMAL 	=	0000000Eh
	LOCALE_SPOSITIVESIGN	=	00000050h
	LOCALE_SNEGATIVESIGN	=	00000051h
	NULL			=	0

;extern memory routines
	EXTRN	GlobalAlloc:near
	EXTRN	GlobalReAlloc:near
	EXTRN	GlobalSize:near
	EXTRN	GlobalFree:near
	EXTRN	GetLastError:near
	EXTRN	GetLocaleInfoA:near
;	EXTRN	GetModuleHandleA:near
	EXTRN	GetProcAddress:near
	EXTRN	LoadLibraryA:near
	EXTRN	FreeLibrary:near
	EXTRN	GetACP:near
	EXTRN	GetUserDefaultLCID:near

	.code

;entry point
org	0
DllEntryPoint	proc	near
DllEntryPoint1:
	mov	eax, [esp+8]
	sub	eax, 1
	jc	DllEntryPoint_process_detach
	jnz	DllEntryPoint_exit
	;DLL_PROCESS_ATTACH
	pushad
	push	eax
	mov	ebp, esp
	call	GetUserDefaultLCID
	push	eax
	push	1
	push	ebp
	push	LOCALE_SDECIMAL
	push	eax
	call	GetLocaleInfoA
	or	eax, eax
	jnz	DllEntryPoint_enter1
	mov	al, [ebp]
	mov	[Floating_point_symbol], al
DllEntryPoint_enter1:
	push	1
	push	ebp
	push	LOCALE_SNEGATIVESIGN
	push	dword ptr [esp+0ch]
	call	GetLocaleInfoA
	or	eax, eax
	jnz	DllEntryPoint_enter2
	mov	al, [ebp]
	mov	byte ptr [Negative_sign_symbol], al
DllEntryPoint_enter2:
	push	1
	push	ebp
	push	LOCALE_SPOSITIVESIGN
	push	dword ptr [esp+0ch]
	call	GetLocaleInfoA
	or	eax, eax
	jnz	DllEntryPoint_enter3
	mov	al, [ebp]
	mov	byte ptr [Positive_sign_symbol], al
;	call	GetLastError
;	mov	dword ptr[Floating_Point_Symbol+1], eax
DllEntryPoint_enter3:
	pop	eax
	pop	eax
	popad
	cmp	[hBorlandMM], 0
	jnz	short	DllEntryPoint_exit1
	call	LoadBorlandMemoryFuncs
	jmp	short	DllEntryPoint_exit
DllEntryPoint_process_detach:
	;DLL_PROCESS_DETACH
	call	FreeBorlandMemoryFuncs
DllEntryPoint_exit:
	mov	eax, 1
DllEntryPoint_exit1:
	ret	0ch
DllEntryPoint	endp


MemoryAlloc	proc	near
	;in
	;ecx: new size
	;out
	;eax: new memory pointer
	;ecx, edx: destroyed
	push	ecx
	cmp	dword ptr[hBorlandMM], 0
	jz	MemoryAlloc_kernel
	call	[BorlandAllocMemory]
	pop	ecx
	jmp	MemoryAlloc_checkerror
MemoryAlloc_kernel:
	push	GPTR
	call	GlobalAlloc
MemoryAlloc_checkerror:
	or	eax, eax
	jnz	short	MemoryAlloc_exit
;	geterror
	stc
MemoryAlloc_exit:
	ret
MemoryAlloc	endp


MemoryFree	proc	near
	;in
	;eax: memory pointer to destroy
	;out
	;eax, ecx, edx: destroyed
	push	eax
	cmp	dword ptr[hBorlandMM], 0
	jz	MemoryFree_kernel
	call	[BorlandFreeMemory]
	pop	ecx
	jmp	MemoryAlloc_checkerror
MemoryFree_kernel:
	call	GlobalFree
	jmp	MemoryAlloc_checkerror
MemoryFree	endp


MemoryReAlloc	proc	near
	;in
	;eax: memory pointer
	;ecx: new size
	;out
	;eax: new memory pointer
	;ecx, edx: destroyed
	cmp	dword ptr[hBorlandMM], 0
	jz	MemoryReAlloc_kernel
	push	ecx
	push	eax
	call	[BorlandReallocMemory]
	pop	ecx
	pop	ecx
	jmp	MemoryAlloc_checkerror
MemoryReAlloc_kernel:
	push	esi
	push	edi
	mov	esi, eax
	mov	edi, edx
;	resize	eax, edx
	push	GPTR
	push	edx
	push	eax
	call	GlobalReAlloc
	or	eax, eax
	jnz	short	MemoryReAlloc_exit
;	geterror
	call	GetLastError
	cmp	eax, 8 ;ERROR_NOT_ENOUGH_MEMORY
	jnz	short	MemoryReAlloc_error
;	new	edi
	push	edi
	push	GPTR
	call	GlobalAlloc
	or	eax, eax
	jz	short	MemoryReAlloc_error
	mov	edi, eax
	push	edi
	push	esi
	call	GlobalSize
	push	esi
	mov	ecx, eax
	shr	ecx, 2
	repz	movsd
	and	eax, 3
	jz	short	MemoryReAlloc_1
	mov	ecx, eax
	repz	movsb
MemoryReAlloc_1:
;	delete	esi
	call	GlobalFree
	pop	eax
MemoryReAlloc_exit:
	pop	edi
	pop	esi
	ret
;MemoryReAlloc_error1:
;	geterror
MemoryReAlloc_error:
	stc
	pop	edi
	pop	esi
	ret
MemoryReAlloc	endp


LoadBorlandMemoryFuncs	proc	near
	ret
	push	offset BorlandMMDllName
	call	LoadLibraryA
	or	eax, eax
	jz	short	GetMemInfoFuncs_exit
	mov	[hBorlandMM], eax
	push	offset SysGetMemFuncName
	push	eax
	call	GetProcAddress
	or	eax, eax
	jz	short	GetMemInfoFuncs_error
	mov	[BorlandAllocMemory], eax
	push	offset SysReallocMemFuncName
	push	dword ptr [hBorlandMM]
	call	GetProcAddress
	or	eax, eax
	jz	short	GetMemInfoFuncs_error
	mov	[BorlandReallocMemory], eax
	push	offset SysFreeMemFuncName
	push	dword ptr [hBorlandMM]
	call	GetProcAddress
	or	eax, eax
	jz	short	GetMemInfoFuncs_error
	mov	[BorlandFreeMemory], eax
GetMemInfoFuncs_exit:
	ret
GetMemInfoFuncs_error:
	push	dword ptr[hBorlandMM]
	call	FreeLibrary
	mov	[hBorlandMM], 0
	ret
LoadBorlandMemoryFuncs	endp


FreeBorlandMemoryFuncs	proc	near
	mov	eax, [hBorlandMM]
	or	eax, eax
	jz	short	FreeBorlandMemoryFuncs_exit
	push	eax
	call	FreeLibrary
FreeBorlandMemoryFuncs_exit:
	ret
FreeBorlandMemoryFuncs	endp


GetMemInfoFuncs proc
	mov	eax, [hBorlandMM]
	ret
GetMemInfoFuncs endp



GetDecimalSeparator	proc	near
	xor	eax, eax
	push	eax
	mov	eax, esp
	push	2
	push	eax
	push	LOCALE_SDECIMAL
	push	LOCALE_USER_DEFAULT
	call	GetLocaleInfoA
	or	eax, eax
	jnz	short	GetDecimalSeparator_exit
	pop	edx
GetDecimalSeparator_default:
	mov	al, ','
	ret
GetDecimalSeparator_exit:
	pop	eax
	or	eax, eax
	jz	short	GetDecimalSeparator_default
	ret
GetDecimalSeparator	endp


GetPositiveSign proc	near
	xor	eax, eax
	push	eax
	mov	eax, esp
	push	2
	push	eax
	push	LOCALE_SPOSITIVESIGN
	push	LOCALE_USER_DEFAULT
	call	GetLocaleInfoA
	or	eax, eax
	jnz	short	GetPositiveSign_exit
	pop	edx
GetPositiveSign_default:
	mov	al, '+'
	ret
GetPositiveSign_exit:
	pop	eax
	or	eax, eax
	jz	short	GetPositiveSign_default
	ret
GetPositiveSign endp


GetNegativeSign proc	near
	xor	eax, eax
	push	eax
	mov	eax, esp
	push	2
	push	eax
	push	LOCALE_SNEGATIVESIGN
	push	LOCALE_USER_DEFAULT
	call	GetLocaleInfoA
	or	eax, eax
	jnz	short	GetNegativeSign_exit
	pop	edx
GetNegativeSign_default:
	mov	al, '-'
	ret
GetNegativeSign_exit:
	pop	eax
	or	eax, eax
	jz	short	GetNegativeSign_default
	ret
GetNegativeSign endp


GetSystemCodepage	proc	near
	;out
	;eax: codepage
	;ecx, edx: destroyed
	push	edi
	call	GetACP
	lea	edi, WinCP_CP
	mov	ecx, 14
	repnz	scasd
	mov	eax, [WinCP_Decode + ecx*4]
	pop	edi
	ret
GetSystemCodepage	endp

.data
decimal_constant	label	byte
	dd	0ah
;Sign_Symbols	label	word
;	db	'-'
;	db	'+'
;Floating_Point_Symbol	label	byte
;	db	','
BorlandMMDllName	db	'borlndmm.dll',0
SysGetMemFuncName	db	'GetMemory',0
SysReallocMemFuncName	db	'ReallocMemory',0
SysFreeMemFuncName	db	'FreeMemory',0
hBorlandMM		dd	0
BorlandAllocMemory	dd	?
BorlandReallocMemory	dd	?
BorlandFreeMemory	dd	?
WinCP_CP		label	dword
	dd	874
	dd	932
	dd	936
	dd	949
	dd	950
	dd	1200
	dd	1250
	dd	1251
	dd	1252
	dd	1253
	dd	1254
	dd	1255
	dd	1256
	dd	1257
WinCP_Decode		label	dword
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	1
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0
	dd	0

type1 = LOCALE_SNEGATIVESIGN
type2 = LOCALE_SPOSITIVESIGN
type3 = LOCALE_SDECIMAL
buffer1 dd 0,0,0
sizebuf1 = 12

end	DllEntryPoint
