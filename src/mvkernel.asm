	.386
	model  flat

;	include constant.inc
	PUBLIC	DllEntryPoint1
	PUBLIC	@FastString@$bdtr$qqrv
	PUBLIC	@FastString@$bctr$qqrpxc

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
	PUBLIC	GetMemInfoFuncs
	PUBLIC	GetDecimalSeparator
	PUBLIC	GetPositiveSign
	PUBLIC	GetNegativeSign

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
	cmp	[hBorlandMM], 0
	jnz	short	DllEntryPoint_exit1
;!	call	LoadBorlandMemoryFuncs
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




@FastString@$bctr$qqrv	proc	near
	mov	dword ptr [eax], 0
	ret
@FastString@$bctr$qqrv	endp


@FastString@$bdtr$qqrv	proc	near
StringFree:
	;in
	;eax: this
	mov	eax, [eax]
	or	eax, eax
	jz	StringFree_exit
;	call	MemoryFree
	push	eax
	call	GlobalFree
	call	GetLastError
StringFree_exit:
	ret
@FastString@$bdtr$qqrv	endp

@FastString@$basg$qqrrx17System@AnsiString	proc	near
@FastString@$bctr$qqrpxc:
	push	ebx
	mov	ebx, eax
	push	24h
	push	40h
	call	GlobalAlloc
	mov	[ebx],eax
	pop	ebx
	ret
@FastString@$basg$qqrrx17System@AnsiString	endp


.data
BorlandMMDllName	db	'borlndmm.dll',0
SysGetMemFuncName	db	'GetMemory',0
SysReallocMemFuncName	db	'ReallocMemory',0
SysFreeMemFuncName	db	'FreeMemory',0
hBorlandMM		dd	0
BorlandAllocMemory	dd	?
BorlandReallocMemory	dd	?
BorlandFreeMemory	dd	?


end	DllEntryPoint
