;math variant structure constants
MATHVAR_TYPE		=	0
MATHVAR_ERROR		=	2
MATHVAR_REFERENCE	=	3
MATHVAR_VALUE		=	4
SIZE_OF_MATH_VARIANT	=	16

;array structure constants
QUEUE_TYPE		=	0
QUEUE_MODE		=	2
QUEUE_TYPE_SIZE 	=	3
QUEUE_LOW		=	4
QUEUE_BOUNDSCOUNT	=	4
QUEUE_SIZE		=	8
QUEUE_HEAD		=	12
QUEUE_TAIL		=	16
;QUEUE_BUFFER_SIZE	=	20
QUEUE_REFERENCE 	=	20
QUEUE_ERROR		=	24
QUEUE_PTR		=	28
SIZE_OF_QUEUE		=	32

DEFAULT_QUEUE_COUNT	=	2

;queue modes
QUEUE_LOCKED		=	1b
QUEUE_FIXED_LENGTH	=	10b
;queue state
QUEUE_IS_FULL		=	100b

;pointer data structure
PTR_POINTER	EQU	0
PTR_FIRST	EQU	4
PTR_LAST	EQU	8
PTR_DATA	EQU	12

;math variant errors
ERROR_SUCCESS	EQU	0
ERROR_MATH_VARIANT_IS_NOT_AN_ARRAY		 EQU	 -1
ERROR_MATH_VARIANT_TYPE_IS_NOT_ALLOWED		 EQU	 -1
ERROR_MATH_VARIANT_IS_NOT_AN_QUEUE		 EQU	 -1
ERROR_MATH_VARIANT_CANNOT_BE_CONVERTED_TO_STRING EQU	 -1
ERROR_INVALID_POINTER				 EQU	 -1
ERROR_EXTERNAL_ERROR				 EQU	 0ffh

;queue errors
ERROR_QUEUE_ARRAY_IS_LOCKED			=	-1
ERROR_QUEUE_ARRAY_IS_NOT_LOCKED 		=	-1
ERROR_QUEUE_INDEX_IS_OUT_BOUNDS 		=	-1
ERROR_QUEUE_WRONG_INDEX_COUNT			=	-1
ERROR_QUEUE_IS_NOT_IN_QUEUE_MODE		=	-1
ERROR_QUEUE_IS_NOT_IN_ARRAY_MODE		=	-1
ERROR_QUEUE_IS_EMPTY				=	-1
ERROR_QUEUE_BOUNDS_COUNT_IS_TOO_LARGE		=	-1
ERROR_QUEUE_BOUNDS_COUNT_VALUE_IS_EQUAL_TO_ZERO =	-1
ERROR_QUEUE_BOUNDS_COUNT_VALUE_IS_TOO_LARGE	=	-1
ERROR_QUEUE_CANNOT_BE_ASSIGNED			=	-1
ERROR_QUEUE_INDEX_IS_TOO_LARGE			=	-1
ERROR_QUEUE_CANT_BE_RESIZED			=	-1

;ERROR_QUEUE_SIZE_IS_OUT_BOUNDS EQU	0c0140100h
;ERROR_ARRAY_DIMENSION_INDEX_HAS_NEGATIVE_VALUE 	EQU	0c0150000h
;ERROR_ARRAY_DIMENSION_INDEX_IS_TOO_LARGE		EQU	0c0150001h
;ERROR_ARRAY_IS_LOCKED					EQU	0c0150002h
;ERROR_ARRAY_IS_UNLOCKED				EQU	0c0150003h
;ERROR_CANNOT_CONVERT_MATH_VARIANT			EQU	0c0150004h


mvEmpty       EQU     00h
mvNull	      EQU     01h
mvBool	      EQU     02h
mvChar	      EQU     03h
mvByte	      EQU     04h
mvShortInt    EQU     05h
mvWord	      EQU     06h
mvInteger     EQU     07h
mvDword       EQU     08h
mvInt64       EQU     09h
mvQword       EQU     0ah
mvFloat       EQU     0bh
mvDouble      EQU     0ch
mvExtended    EQU     0dh
mvPointer     EQU     0eh
mvString      EQU     0fh
;mvOleStr      EQU     10h
mvVariant     EQU     11h
;mvCurrency    EQU     010h
;mvDateTime    EQU     011h
;mvCommand    EQU     017h	;//
;mvSysCommand	 EQU	 018h	;// are not realized
;mvMathOperator    EQU	   019h ;//
;mvMathFormulae    EQU	   01ah ;//
;mvByRef    EQU     080h
mvValue    EQU	   0ffh
mvArray    EQU	   0100h
mvQueue    EQU	   0200h
mvStack    EQU	   0300h
;mvArrayByRef	 EQU	 0400h
mvArrayValue	EQU	0ff00h


;Global Memory Flags
;GMEM_FIXED	     EQU     0000h
;GMEM_MOVEABLE	     EQU     0002h
;GMEM_NOCOMPACT      EQU     0010h
;GMEM_NODISCARD      EQU     0020h
;GMEM_ZEROINIT	     EQU     0040h
;GMEM_MODIFY	     EQU     0080h
;GMEM_DISCARDABLE    EQU     0100h
;GMEM_NOT_BANKED     EQU     1000h
;GMEM_SHARE	     EQU     2000h
;GMEM_DDESHARE	     EQU     2000h
;GMEM_NOTIFY	     EQU     4000h
;GMEM_LOWER	     EQU     GMEM_NOT_BANKED
;GMEM_VALID_FLAGS    EQU     7F72h
;GMEM_INVALID_HANDLE EQU     8000h

;GHND		     EQU     GMEM_MOVEABLE OR GMEM_ZEROINIT
;GPTR		     EQU     GMEM_FIXED OR GMEM_ZEROINIT

;locale constants
;LOCALE_USER_DEFAULT	 EQU	 400h
;LOCALE_SDECIMAL EQU	 0000000Eh
;LOCALE_SPOSITIVESIGN	 EQU	 00000050h
;LOCALE_SNEGATIVESIGN	 EQU	 00000051h

;NULL	 =	 0

;extern memory routines
;	 EXTRN	 GlobalAlloc:near
;	 EXTRN	 GlobalReAlloc:near
;	 EXTRN	 GlobalSize:near
;	 EXTRN	 GlobalFree:near
;	 EXTRN	 GetLastError:near
;	 EXTRN	 GetLocaleInfoA:near
;	 EXTRN	 GetModuleHandleA:near
;	 EXTRN	 GetProcAddress:near
;	 EXTRN	 LoadLibraryA:near
;	 EXTRN	 FreeLibrary:near
	EXTRN	MemoryAlloc:near
	EXTRN	MemoryReAlloc:near
	EXTRN	MemorySize:near
	EXTRN	MemoryFree:near
;	 EXTRN	 GetLastError:near
;	 EXTRN	 GetLocaleInfoA:near
;	 EXTRN	 GetModuleHandleA:near
;	 EXTRN	 GetProcAddress:near
;	 EXTRN	 LoadLibraryA:near
;	 EXTRN	 FreeLibrary:near

;memory routine macros
getsize macro	param
	mov	eax, param
	call	MemorySize
endm

new	macro	size
	;in	eax: size
	mov	eax, size
	call	MemoryAlloc
endm

resize	macro	param, newsize
	;in	eax: pointer
	;in	edx: newsize
	mov	eax, param
	mov	edx, newsize
	call	MemoryReAlloc
endm

delete	macro	param
	mov	eax, param
	call	MemoryFree
endm

delete_eax	macro	param
	call	MemoryFree
endm

IsByRef1 macro	 reg
;	 test	 byte ptr[reg], mvByRef
	cmp    byte ptr[reg+MATHVAR_REFERENCE], 0
endm

;IsArrayByRef macro   reg
;	test	byte ptr[reg+QUEUE_TYPE+1], mvArrayByRef / 256
;endm

IsQueue macro	reg
	test	byte ptr[reg+QUEUE_TYPE+1], mvQueue / 256
endm

IsString	macro	reg
	cmp	byte ptr[reg+QUEUE_TYPE], mvString
endm

IsArray macro	reg
	test	byte ptr[reg+QUEUE_TYPE+1], mvStack / 256
endm

IsArrayInReg macro   reg
	test	reg, mvStack / 256
endm

IsStack macro	reg
	test	byte ptr[reg+QUEUE_TYPE+1], mvArray / 256
endm


CODEPAGE	struc
	Page	dw	?
	Type	db	?
CODEPAGE	ends

FastString	struc
	RefCount	dd		?
	Length		dd		?
	BufferSize	dd		?
	CodePage	CODEPAGE	?
	Mode		db		?
FastString	ends


FORCE_SIGN	=	1h
;SIGN_INT	=	2h

BOOL_STRING_LENGTH	=	11
INT_STRING_LENGTH	=	21
QWORD_STRING_LENGTH	=	41
FLOAT_STRING_LENGTH	=	161


SIZEOF_CHAR		=	1
SIZEOF_WCHAR_T		=	2
SIZEOF_INT		=	4
SIZEOF_FASTSTRING	=	16

;Code page Flags
;0 - 16 bit
;1 - Win32 supports this function

;Type of a codepage
WINANSICP	=	000b
WIDECHARCP	=	001b
UNIXCP		=	010b
MACCP		=	011b
ISOCP		=	100b

;Ansi codepages
;CP874	Thai
;CP932	Japan
;CP936	Chinese (PRC, Singapore)
;CP949	Korean
;CP950	Chinese (Taiwan, Hong Kong)
;CP1200 Unicode (BMP of ISO 10646)
;CP1250 Windows 3.1 Eastern European
;CP1251 Windows 3.1 Cyrillic
;CP1252 Windows 3.1 Latin 1 (US, Western Europe)
;CP1253 Windows 3.1 Greek
;CP1254 Windows 3.1 Turkish
;CP1255 Hebrew
;CP1256 Arabic
;CP1257 Baltic

;OEM codepages
;CP437	MS-DOS United States
;CP708	Arabic (ASMO 708)
;CP709	Arabic (ASMO 449+, BCON V4)
;CP710	Arabic (Transparent Arabic)
;CP720	Arabic (Transparent ASMO)
;CP737	Greek (formerly 437G)
;CP775	Baltic
;CP850	MS-DOS Multilingual (Latin I)
;CP852	MS-DOS Slavic (Latin II)
;CP855	IBM Cyrillic (primarily Russian)
;CP857	IBM Turkish
;CP860	MS-DOS Portuguese
;CP861	MS-DOS Icelandic
;CP862	Hebrew
;CP863	MS-DOS Canadian-French
;CP864	Arabic
;CP865	MS-DOS Nordic
;CP866	MS-DOS Russian (former USSR)
;CP869	IBM Modern Greek
;CP874	Thai
;CP932	Japan
;CP936	Chinese (PRC, Singapore)
;CP949	Korean
;CP950	Chinese (Taiwan, Hong Kong)
;CP1361 Korean (Johab)

