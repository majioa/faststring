	.386
	.model flat

	include constant.inc

	PUBLIC	@FastString@$oo$xqqrv
	PUBLIC	@FastString@$oc$xqqrv
	PUBLIC	@FastString@$ozc$xqqrv
	PUBLIC	@FastString@$ouc$xqqrv
	PUBLIC	@FastString@$os$xqqrv
	PUBLIC	@FastString@$ous$xqqrv
	PUBLIC	@FastString@$oi$xqqrv
	PUBLIC	@FastString@$ol$xqqrv
	PUBLIC	@FastString@$oui$xqqrv
	PUBLIC	@FastString@$oul$xqqrv
	PUBLIC	@FastString@$oj$xqqrv
	PUBLIC	@FastString@$ouj$xqqrv
	PUBLIC	@FastString@$of$xqqrv
	PUBLIC	@FastString@$od$xqqrv
	PUBLIC	@FastString@$og$xqqrv
	PUBLIC	@FastString@$opv$xqqrv
	PUBLIC	@FastString@$opb$qqrv
	PUBLIC	@FastString@$opc$qqrv
	PUBLIC	@FastString@$o17System@AnsiString$qqrv
	PUBLIC	@FastString@$o17System@WideString$qqrv
	PUBLIC	@FastString@ConvertTo$qqrul
	PUBLIC	@FastString@SetCodePage$qqrul


	PUBLIC	Floating_point_symbol
	PUBLIC	Positive_sign_symbol
	PUBLIC	Negative_sign_symbol


	EXTRN	decimal_constant:dword
;	EXTRN	GetDecimalSeparator:near
;	EXTRN	GetPositiveSign:near
;	EXTRN	GetNegativeSign:near

;	PUBLIC	StringBufferSize
;	PUBLIC	StringCopy
;	PUBLIC	OleStrBufferSize
;	PUBLIC	OleStrCopy
;	PUBLIC	ToString
;	PUBLIC	ToOleStr

PARAMETER_SYMBOL	=	1
FUNCTION_SYMBOL 	=	2
;MINUS_SIGN	=	80h
POS_VALUE	=	40h
NEG_VALUE	=	80h
;HEX_SIGN	=	40h
FLOAT_VALUE	=	1
EXP_VALUE	=	2
HEX_VALUE	=	3
OCTAL_VALUE	=	4
BIN_VALUE	=	5

;POSTFIX_FLAG	=	1
SIGN_FLAG	=	1
FLOAT_DOT_FLAG	=	2
SEPARATOR_FLAG	=	4
MODE_FLAG	=	8
EXP_FLAG	=	16
NUMBER_FLAG	=	32
MODE_ZERO_FLAG	=	64
ZERO_FLAG	=	128


;CHECKSYMVALUE	union
;Function	dd	?
;Symbol		dw	?
;CHECKSYMVALUE	ends

;CHECKSYMBOL	struc
;Symbol	db		?
;Value		CHECKSYMVALUE	?
;Value		dd		?
;ExitCode	db		?
;Flag		db		?
;CHECKSYMBOL	ends
SYMBOL	struc
Byte	db	?	;Symbol 8 bit
Byte_ru	db	?	;Symbol 8 bit russian
Word	db	?	;Symbol 16 bit
Rutf	db	?	;Symbol Rutf
SYMBOL	ends

CHECKSYMBOL	struc
Ptr	dd	?	;ptr to symbol for check
Value	db	?	;value of symbol
SymType	db	?	;type of symbol
Mask	db	?	;mask allowing following symbols
Degree	db	?	;degree of divider
CHECKSYMBOL	ends


RUSSIAN_CP_COUNT	=	6

	.code

GetStrLenForConvert	proc	near
ConvertInit:
	;in
	;esi: buffer
	;ecx: maximum strlen
	;ebp: -1: signed value, 1: unsigned value
	;out
	;ecx: number length
	;ebp: sign
	;edx: destroyed
	;ebx: 1
	;df: true
	;edi: 0
	;eax: 0: end of string found, 1: floating point found
	stc
	rcl	ebp, 1
	xor	ebx, ebx
	push	ecx
;	call	GetNegativeSign
	cmp	al, [esi]
	jz	short	GetStrLenForConvert_loop1
GetStrLenForConvert_plus:
	dec	ebp
;	call	GetPositiveSign
	cmp	al, [esi]
	jnz	short	GetStrLenForConvert_loop2
GetStrLenForConvert_loop1:
	inc	esi
GetStrLenForConvert_loop2:
;	call	GetDecimalSeparator
	mov	edx, eax
	pop	ecx
GetStrLenForConvert_loop:
	lodsb
	or	al, al
	jz	short	GetStrLenForConvert_loop_exit2
	cmp	al, 'e'
	jz	short	GetStrLenForConvert_loop_exit
	cmp	al, 'E'
	jz	short	GetStrLenForConvert_loop_exit
	cmp	al, dl
	jz	short	GetStrLenForConvert_loop_exit1
	cmp	al, '9'
	ja	short	GetStrLenForConvert_error
	cmp	al, '0'
	jb	short	GetStrLenForConvert_error
GetStrLenForConvert_next:
	inc	ch
	cmp	cl, ch
	jb	short	GetStrLenForConvert_error
	jmp	short	GetStrLenForConvert_loop
GetStrLenForConvert_loop_exit:
	inc	ebx
GetStrLenForConvert_loop_exit1:
	inc	ebx
;	xor	eax, eax
;	inc	eax
;	jmp	short	GetStrLenForConvert_loop_exit2
GetStrLenForConvert_loop_exit2:
;	xor	eax, eax
;GetStrLenForConvert_loop_exit3:
	mov	eax, ebx
	xchg	cl, ch
	xor	ch, ch
	pushf
	or	byte ptr[esp+1], 4
	popf
	sub	esi, 2
	xor	ebx, ebx
	mov	edi, ebx
	inc	ebx
	ret
GetStrLenForConvert_error:
	stc
	ret
GetStrLenForConvert	endp


InitFloatConvert	proc	near
	ret
InitFloatConvert	endp


StringToFloat	proc	near
	;in
	;eax: input string
	;st(0): default value
	pushf
	push	ebx
	push	esi
	push	edi
	push	ebp
	mov	esi, eax
	xor	eax, eax
	sub	esp, 12*4+4
	lea	ebp, [esp+12*4+4-12]
	mov	ecx, 3
StringToFloat_loop:
	push	ecx
	push	ebp
	pushf
	mov	cl, 20
	call	ConvertInit
	jnc	short	StringToFloat_init_ok
	or	eax, eax
	jz	short	StringToFloat_error1
StringToFloat_init_ok:
	push	eax
	call	QwordConvert
	pop	ebx
	jc	short	StringToFloat_error1
	popf
	pop	ebp
	mov	[ebp],eax
	mov	[ebp+4],edx
	mov	[ebp+8],ecx
	sub	ebp, 12
	pop	ecx
	mov	[esp+ecx+12*4-1], bl
	or	ebx, ebx
	loopz	short	StringToFloat_loop
	jnz	short	StringToFloat_pop_exit
	mov	cl, 2
	lea	ebp, [esp+12*3]
	fld	qword ptr[ebp]
	xor	ebx, ebx
StringToFloat_loop1:
	sub	ebp, 12
	mov	bl, [esp+ecx+12*4-1]
	or	ebx, ebx
	jz	short	StringToFloat_loop1_exit
	dec	ebx
	jnz	short	StringToFloat_loop1_exp
	fild	qword ptr[ebp]
	fild	dword ptr[ebp+8]
	fldl2t
	fmulp
	f2xm1
	fdivp
	faddp
	jmp	short	StringToFloat_loop1_next
StringToFloat_loop1_exp:
	fld	qword ptr[ebp]
	fscale
StringToFloat_loop1_next:
	loop	short	StringToFloat_loop1
StringToFloat_loop1_exit:
;StringToFloat_pop_exit1:
;	pop	edx
;	pop	eax
	ffree	st(1)
StringToFloat_pop_exit:
	add	esp, 12*4+4
	pop	ebp
	pop	edi
	pop	esi
	pop	ebx
	popf
	ret
StringToFloat_error1:
	popf
	pop	ebp
	pop	ecx
	jmp	short	StringToFloat_pop_exit
;StringToFloat_floating_point:
;	mov	esi, eax
;	mov	ecx, 10
;	call	InitFloatConvert
;	jc	StringToInt_error
;StringToFloat_loop1:
;	xor	eax, eax
;	lodsb
;	sub	al, '0'
;	mul	ebx
;	or	edx, edx
;	jnz	StringToInt_error
;	add	edi, eax
;	dec	ecx
;	jecxz	short	StringToFloat_loop1_exit
;	mov	eax, 10
;	mul	ebx
;	mov	ebx, eax
;	jmp	short	StringToFloat_loop1
;StringToFloat_loop1_exit:
;	mov	eax, edi
;	or	ebp, ebp
;	jz	short	StringToInt_pop_exit
;	neg	eax
;	jns	short	StringToInt_error;///??? comp to 0????
;	jmp	short	StringToInt_pop_exit
StringToFloat	endp


StringToQword	proc	near
	;in
	;eax: input string
	;edx: ecx: default value
	pushf
	push	ebx
	push	esi
	push	edi
	push	ebp
	push	edx
	push	ecx
	mov	esi, eax
	mov	ecx, 20
	call	ConvertInit
	jc	short	StringToQword_pop_exit
	call	QwordConvert
	jc	short	StringToQword_pop_exit
	mov	[esp], eax
	mov	[esp+4], edx
StringToQword_pop_exit:
	pop	eax
	pop	edx
	pop	ebp
	pop	edi
	pop	esi
	pop	ebx
	popf
	ret
StringToQword	endp


StringToInt	proc	near
	;in
	;eax: input string
	;edx: default value
	pushf
	push	ebx
	push	esi
	push	edi
	push	edx
	mov	esi, eax
	mov	ecx, 10
	call	ConvertInit
	jc	short	StringToInt_error
StringToInt_loop1:
	xor	eax, eax
	lodsb
	sub	al, '0'
	mul	ebx
	or	edx, edx
	jnz	short	StringToInt_error
	add	edi, eax
	dec	ecx
	jecxz	short	StringToInt_loop1_exit
	mov	eax, [decimal_constant]
	mul	ebx
	mov	ebx, eax
	jmp	short	StringToInt_loop1
StringToInt_loop1_exit:
	mov	eax, edi
	test	ebp, eax
	js	short	StringToInt_error;///??? comp to 0????
	shr	ebp, 1
	jnc	short	StringToInt_pop_exit
	neg	eax
	jns	short	StringToInt_error;///??? comp to 0????
StringToInt_pop_exit:
	mov	[esp], eax
StringToInt_error:
	pop	eax
	pop	edi
	pop	esi
	pop	ebx
	popf
	ret
StringToInt	endp


StringToWord	proc	near
	;in
	;eax: input string
	;edx: default value
	push	esi
	push	edx
	mov	esi, eax
	mov	ecx, 5
	call	ConvertInit
	jc	short	StringToWord_error
StringToWord_loop1:
	xor	eax, eax
	lodsb
	sub	al, '0'
	mul	bx
	or	dx, dx
	jnz	short	StringToWord_error
	add	di, ax
	dec	ecx
	jecxz	short	StringToWord_loop1_exit
	mov	eax, [decimal_constant]
	mul	ebx
	mov	ebx, eax
	jmp	short	StringToWord_loop1
StringToWord_loop1_exit:
	mov	ax, di
	test	bp, ax
	js	short	StringToWord_error;///??? comp to 0????
	shr	ebp, 1
	jnc	short	StringToWord_pop_exit
	neg	ax
	jns	short	StringToWord_error;///??? comp to 0????
StringToWord_pop_exit:
	mov	[esp], eax
StringToWord_error:
	pop	eax
	pop	esi
	ret
StringToWord	endp


StringToByte	proc	near
	;in
	;eax: input string
	;edx: default value
	push	esi
	push	edx
	mov	esi, eax
	mov	ecx, 3
	call	ConvertInit
	jc	short	StringToWord_error
	xor	eax, eax
StringToByte_loop1:
	lodsb
	sub	al, '0'
	mul	bl
	or	ah, ah
	jnz	short	StringToWord_error
	add	edi, eax
	dec	ecx
	jecxz	short	StringToByte_loop1_exit
	mov	al, byte ptr[decimal_constant]
	mul	bl
	mov	bl, al
	jmp	short	StringToByte_loop1
StringToByte_loop1_exit:
	mov	eax, edi
	mov	ebx, ebp
	test	bl, al
	js	short	StringToWord_error;///??? comp to 0????
	shr	ebp, 1
	jnc	StringToWord_pop_exit
	neg	al
	jns	StringToWord_error;///??? comp to 0????
	jmp	StringToWord_pop_exit
StringToByte	endp


;convert long values
;ftol  proc  near
;  fstcw [flags]
;  mov al,byte ptr[flags+1]
;  or byte ptr[flags+1],0ch
;  fldcw [flags]
;  fistp qword ptr[temp]
;  mov byte ptr[flags+1],al
;  fldcw [flags]
;  mov eax, [temp]
;  mov edx, [temp+4]
;  ret
;ftol  endp

;ftoqw proc  near
;  fstcw [flags]
;  mov al,byte ptr[flags+1]
;  or byte ptr[flags+1],0ch
;  fldcw [flags]
;  fistp qword ptr[temp]
;  mov byte ptr[flags+1],al
;  fldcw [flags]
;  mov eax, [temp]
;  mov edx, [temp+4]
;  ret
;ftoqw endp



QwordConvert	proc	near
	push	ecx
	push	ebp
	xor	eax, eax
	inc	eax
	push	eax
	dec	eax
	push	    eax
QwordConvert_loop:
	xor	eax, eax
	lodsb
	sub	al, '0'
	mov	ebx, eax
	mul	dword ptr [esp+4]
	push	eax
	push	edx
	mov	eax, ebx
	mul	dword ptr [esp+8]
	or	edx, edx
	jnz	short	QwordConvert_error2
	add	[esp], eax
	pop	edx
	pop	eax
	add	edi, eax
	adc	ebp, edx
	jc	short	QwordConvert_error1
	dec	ecx
	jecxz	short	QwordConvert_loop_exit
	pop	ebx
	pop	eax
	mul	dword ptr [decimal_constant]
	push	eax
	or	ebx, ebx
	jz	short	QwordConvert_significant_zero
	push	edx
	mov	eax, [decimal_constant]
	mul	ebx
	add	[esp], eax
	jmp	short	QwordConvert_loop
QwordConvert_significant_zero:
	push	edx
	jmp	short	QwordConvert_loop
QwordConvert_loop_exit:
	pop	eax
	pop	eax
	mov	eax, edi
	mov	edx, ebp
	pop	ebp
	test	ebp, edx
	js	short	QwordConvert_error;///??? comp to 0????
	shr	ebp, 1
	jnc	short	QwordConvert_pop_exit
	not	edx
	not	eax
	inc	eax
	adc	edx, 0
	jns	short	QwordConvert_error;///??? comp to 0????
QwordConvert_pop_exit:
	ret
QwordConvert_error2:
	pop	eax
	pop	eax
QwordConvert_error1:
	pop	eax
	pop	eax
	pop	ebp
	pop	ecx
QwordConvert_error:
	stc
	ret
QwordConvert	endp



OleStrToString	proc  near
	;in
	;esi: ole string
	;edi: string buffer
	;out
	;eax: destroyed

	push esi
	push edi
	xor eax, eax
OleStrToString_loop:
	lodsw
	stosb
	loop short OleStrToString_loop
	pop edi
	pop esi
	ret
OleStrToString	endp


StringToOleStr	proc  near
  ;in
  ;esi: string
  ;edi: ole string buffer
  ;out
  ;eax: destroyed

  push esi
  push edi
  xor eax, eax
StringToOleStr_loop:
  lodsb
  stosw
  loop short StringToOleStr_loop
  pop edi
  pop esi
  ret
StringToOleStr	endp


FloatToString proc  near
	;in
	;st[0]: float number
	;edi: string buffer
	;out
	;eax: destroyed
	push	eax
	push	edx
	fxtract
	fistp	qword ptr[esp]
	mov	eax,[esp]
	mov	edx,[esp+4]
	clc
	call	Int64ToString
	fistp	qword ptr[esp]
	mov	eax,[esp]
	mov	edx,[esp+4]
	stc
	call	Int64ToString
	pop	eax
	pop	eax
	ret
FloatToString endp


Int64ToString proc  near
  ;in
  ;edx:eax: int64
  ;edi: string buffer
  ;out
  ;edx, eax: destroyed

  push eax
  mov al,'-'
  rcl edx,1
  jc short Int64ToString_sign
  test edx,1
  jz short Int64ToString_calc
  mov al,'+'
Int64ToString_sign:
  stosb
Int64ToString_calc:
  shr edx,1
  pop eax
  jmp short Qword_cvt
Int64ToString endp


QwordToString proc  near
  ;in
  ;edx:eax: qword
  ;edi: string buffer
  ;out
  ;edx, eax: destroyed

  jnc QwordToString_calc
  mov byte ptr[edi],'+'
  inc edi
QwordToString_calc:
  jmp short Qword_cvt
QwordToString endp

Qword_cvt proc	near
  push ebx
  push eax
  mov eax, edx
  mov ebx, 10
Qword_cvt_loop1:
  xor edx, edx
  div ebx
  or eax, eax
  jz short Qword_cvt_loop1_exit
  add edx, '0'
  mov [edi],dl
  inc edi
  jmp short Qword_cvt_loop1
Qword_cvt_loop1_exit:
  pop eax
Qword_cvt_loop2:
  xor edx, edx
  div ebx
  add edx, '0'
  mov [edi],dl
  inc edi
  or eax, eax
  jnz short Qword_cvt_loop2
  stosb
  pop ebx
  ret
Qword_cvt endp


;StringToQword proc  near
  ;in
  ;esi: string
  ;out
  ;edx:eax: qword

;  jnc QwordToString_calc
;  mov byte ptr[edi],'+'
;  inc edi
;StringToQword_calc:
;  jmp short StrQword_cvt
;StringToQword endp


StrQword_cvt proc  near
  push ebx
  push ecx
  push esi
  cmp byte ptr[esi],'-'
  jnz short StrQword_cvt_1
  mov ebx, 80000001h
  jmp short StrQword_cvt_2
StrQword_cvt_1:
  mov ebx, 1
  cmp byte ptr[esi],'+'
  jnz short StrQword_cvt_3
StrQword_cvt_2:
  inc esi
StrQword_cvt_3:
  xor edx,edx
  mov ebx, 10
StrQword_search:
  lodsb
  cmp al,'0'
  jb StrQword_search_exit
  cmp al,'9'
  jbe StrQword_search
  mul ebx
StrQword_search_exit:
StrQword_loop1:
  dec esi
  xor eax,eax
  mov al,[esi]
  mul ebx
  or edx,edx
  jnz short StrQword_loop1_exit
  add ecx,eax
  mul ebx
  jmp StrQword_loop1
StrQword_loop1_exit:

StrQword_cvt endp



OleStrBufferSize  proc	near
	;in
	;edi: ole string
	;out
	;edi, edx: destroyed
	;eax: buffer size

	xor	eax, eax
	xor	ecx, ecx
	dec	ecx
	repnz	scasw
	neg	ecx
	dec	ecx
	mov	eax, ecx
	shl	eax, 1
	ret
OleStrBufferSize  endp


StringBufferSize  proc	near
	;in
	;edi: string
	;out
	;edi, edx: destroyed
	;eax: buffer size

	xor	eax, eax
	xor	ecx, ecx
	dec	ecx
	repnz	scasb
	neg	ecx
	dec	ecx
	mov	eax, ecx
	ret
StringBufferSize  endp


StringCopy  proc  near
  ;in
  ;esi: source string
  ;edi: destination buffer
  ;out
  ;eax, esi, edi: destroyed

;  push esi
;  push edi
StringCopy_loop:
  lodsb
  stosb
  or al,al
  jnz short StringCopy_loop
;  pop edi
;  pop esi
  ret
StringCopy  endp


OleStrCopy  proc  near
  ;in
  ;esi: source ole string
  ;edi: destination buffer
  ;out
  ;eax, esi, edi: destroyed

;  push esi
;  push edi
  xor eax,eax
OleStrCopy_loop:
  lodsw
  stosw
  or eax, eax
  jnz short OleStrCopy_loop
;  pop edi
;  pop esi
  ret
OleStrCopy  endp


ToString  proc	near
	;in
	;ebx: this
	;out
	;eax(al): bool value
	;c=1 if error
	;edi, esi: destroyed
	mov	cl,[ebx]
	cmp	cl, mvNull
	jbe	ToString_error
	cmp	cl, mvString
	jz	ToString_exit
;	 cmp	 cl, mvOleStr;??
	ja	ToString_error
	jb	short ToString_tochar
	push	esi
	push	edi
	mov	edi, [ebx+MATHVAR_VALUE]
	call	OleStrBufferSize
	cmp	eax,[ebx+MATHVAR_VALUE+4]
	jbe	ToString_strcopy
	resize	edi, eax
	mov	[ebx+MATHVAR_VALUE+4], eax
ToString_strcopy:
	mov	esi, edi
	call	OleStrToString
	pop	edi
	pop	esi
	jmp	short ToString_exit
ToString_tochar:
	cmp	cl, mvChar
	jnz	short	ToString_toshort
ToString_char:
	movsx	eax, byte ptr[ebx+MATHVAR_VALUE]
	jmp	short	ToString_IntCvt
ToString_toshort:
	cmp	cl, mvShortInt
	jnz	short	ToString_toint
ToString_short:
	movsx	eax, word ptr[ebx+MATHVAR_VALUE]
	jmp	short	ToString_IntCvt
ToString_toint:
	cmp	cl, mvInteger
	jnz	short	ToString_toint64
ToString_int:
	mov	eax,[ebx+MATHVAR_VALUE]
	jmp	short	ToString_IntCvt
ToString_toint64:
	cmp	cl, mvInt64
	jnz	short ToString_tofloat
	mov	eax,[ebx+MATHVAR_VALUE]
	mov	edx,[ebx+MATHVAR_VALUE+4]
	jmp	short	ToString_IntCvt
ToString_tofloat:
	cmp	cl, mvFloat
	jnz	short	ToString_todouble
	fld	dword ptr[ebx+MATHVAR_VALUE]
	jmp	short	ToString_FloatCvt
ToString_todouble:
	cmp	cl, mvDouble
	jnz	short	ToString_toextended
	fld	qword ptr[ebx+MATHVAR_VALUE]
	jmp	short	ToString_FloatCvt
ToString_toextended:
	cmp	cl, mvExtended
	jnz	short	ToString_WordCvt
	fld	tbyte ptr [ebx+MATHVAR_VALUE]
ToString_FloatCvt:
	call	FloatToString
	jmp	short	ToString_exit
ToString_IntCvt:
	xor	edx, edx
	call	Int64ToString
	jmp	short	ToString_exit
ToString_WordCvt:
	mov	eax,[ebx+MATHVAR_VALUE]
	mov	edx,[ebx+MATHVAR_VALUE+4]
	call	QwordToString
ToString_exit:
	mov	dword ptr [ebx+MATHVAR_ERROR], ERROR_SUCCESS
	clc
	ret
ToString_error:
	mov	dword ptr [ebx+MATHVAR_ERROR], ERROR_MATH_VARIANT_CANNOT_BE_CONVERTED_TO_STRING
	stc
	ret
ToString  endp



;ToString	proc	near
	;in
	;[edx:]eax | st[0]: input value
	;out
	;eax: string



;ToString	endp


ToOleStr  proc	near
ToOleStr  endp




;----------------------------------------------------new functions----------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------

CheckString	proc	near
	;in
	;esi: input string buffer
	;out
	;c: error
	;bl: value type
	;dl: value sign
	;esi: output string buffer
	;ecx: length of string buffer
	;temporary
	;bl: plus sign
	;bh: minus sign
	;ah: floating  point sign
	xor	edx, edx
	xor	ebp, ebp
	xor	edi, edi
	push	edx
	push	ebp
	cmp	ecx, 255
	ja	CheckString_error
	mov	ah, MODE_ZERO_FLAG OR ZERO_FLAG OR NUMBER_FLAG OR MODE_FLAG OR SEPARATOR_FLAG OR FLOAT_DOT_FLAG OR SIGN_FLAG OR EXP_FLAG
CheckString_loop:
	call	GetSymbol
	test	ah, MODE_ZERO_FLAG OR ZERO_FLAG
	jz	CheckString_1
	cmp	al, '0'
	jz	CheckString_next
;CheckString_zero_flg:
;	test	ah, ZERO_FLAG
;	test	ah, NUMBER_FLAG
;	jz	CheckString_1
;	cmp	al, '0'
;	jnz	CheckString_1
;	jz	CheckString_next
;	or	ebp, ebp
;	jz	CheckString_next
;	jmp	CheckString_inc_next
CheckString_1:
	test	ah, NUMBER_FLAG
	jz	CheckString_error
	mov	ebx, offset CheckRange
CheckString_1_1:
	cmp	byte ptr [ebx], 0
	jz	CheckString_2
	cmp	al, [ebx]
	jb	CheckString_1_2
	cmp	al, [ebx + 1]
	jbe	CheckString_inc_next
CheckString_1_2:
	add	ebx, 4
	jmp	CheckString_1_1

;	cmp	al, '1'
;	jb	CheckString_2
;	cmp	al, '9'
;	ja	CheckString_2
;	mov	edi, esi
;	jmp	CheckString_inc_next
;	jbe	CheckString_inc_next
CheckString_2:
	test	ah, MODE_FLAG OR FLOAT_DOT_FLAG OR SIGN_FLAG OR EXP_FLAG
	jz	CheckString_error
	mov	ebx, offset CheckTable - 5
CheckString_2_1:
	add	ebx, 5
	cmp	byte ptr [ebx.Symbol], 0
	jz	CheckString_separator
	cmp	al, [ebx.Symbol]
	jnz	CheckString_2_1
	test	ah, [ebx.Type]
	jz	CheckString_error
	mov	ch, [ebx.Degree]
	mov	dl, [ebx.Value]
	and	ah, [ebx.Mask]
	or	dh, dh
	jns	CheckString_2_2
	shl	edi, 8
	mov	dh, 0
CheckString_2_2:
	inc	edi
;	or	ah, [ebx.Mask]
;	test	dh, byte ptr[ebx.Mask]
;	jnz	CheckString_error
;	test	byte ptr[ebx.Flags], POSTFIX_FLAG
;	jz	CheckString_2_2
;	or	dh, byte ptr[ebx.Value]
	jmp	CheckString_next
;CheckString_2_2:
;	mov	dl, [ebx.Value]
;	and	ah, [ebx.Flags]
;	jmp	CheckString_next
CheckString_separator:
	test	ah, SEPARATOR_FLAG
	jz	CheckString_error
	dec	esi
	jmp	CheckString_exit
;	dec	bl
;	jnz	CheckString_2_1

;	cmp	al, ah
;	jz	CheckString_float_exit
;	or	ebp, ebp
;	jnz	CheckString_2_1
;	cmp	al, bh
;	jz	CheckString_next
;	cmp	al, bl
;	jnz	CheckString_3
;	or	dl, MINUS_SIGN
;	jmp	CheckString_next
;CheckString_2_1:
;CheckString_3:
;	cmp	al, 'e'
;	jz	CheckString_exp_exit
;	cmp	al, 'E'
;	jz	CheckString_exp_exit
;	cmp	al, 'h'
;	jz	CheckString_hex_exit
;	cmp	al, 'H'
;	jz	CheckString_hex_exit
;	cmp	al, 'q'
;	jz	CheckString_octal_exit
;	cmp	al, 'Q'
;	jz	CheckString_octal_exit
;	cmp	al, 'b'
;	jz	CheckString_bin_exit
;	cmp	al, 'B'
;	jz	CheckString_bin_exit
;	cmp	al, 'x'
;	jz	CheckString_set_hex
;	cmp	al, 'X'
;	jnz	CheckString_error
;CheckString_set_hex:
;	or	dl, HEX_SIGN
;	jmp	CheckString_next
CheckString_inc_next:
	or	dh, dh
	js	CheckString_inc_next_1
	shl	ebp, 8
	not	dh
CheckString_inc_next_1:
	inc	ebp
	mov	ch, [ebx+2]
	and	ah, NOT (MODE_ZERO_FLAG OR ZERO_FLAG)
;;	mov	[esp], ebx
CheckString_next:
;	loop	CheckString_loop
	dec	cl
	jnz	CheckString_loop
;;	test	dl, HEX_SIGN
;;	jz	CheckString_exit
;;	mov	dh, HEX_VALUE
CheckString_exit:
	mov	ecx, ebp
	test	dh, dh
	js	CheckString_clear_break_sym
	shrd	edi, eax, 8
	shr	eax, 24
	sub	esi, eax
CheckString_clear_break_sym:
;	mov	ecx, ebp
;	lea	esi, [edi - 1]
	dec	esi
	pushfd
	or	dword ptr [esp], 400h
	popfd
	mov	[esp], dl
	and	dl, 80h
	mov	[esp+7], dl
	pop	ebx
	pop	ebp
	ret
;CheckString_bin_exit:
;	mov	dh, BIN_VALUE
;CheckString_octal_exit:
;	mov	dh, OCTAL_VALUE
;CheckString_hex_exit:
;	mov	dh, HEX_VALUE
;CheckString_exp_exit:
;	mov	dh, EXP_VALUE
;CheckString_float_exit:
;	mov	dh, FLOAT_VALUE
;	test	dl, HEX_SIGN
;	jz	CheckString_exit
CheckString_error:
	stc
	pop	ebx
	pop	ebp
	ret


	;in
	;esi: input string buffer
	;ebx: base
	;edx: CheckTable
	;ebp: exitcode
	;edi: ??
	;out
	;c: error
	;bl: value type
	;dl: value sign
	;esi: output string buffer
	;ecx: length of string buffer
;	xor	ebx, ebx
;	xor	edx, edx
;	xor	ebp, ebp
;	call	TableConversion
;CheckString_loop:
;	lodsb
;	call	CheckBase
;	jnc	ok
;	call	CheckSymbol
;	jc	error
;	or	al, al
;	inc	ebp
;CheckString_next:
;	loop	CheckString_loop

CheckString	endp


;CheckBase	proc	near
	;ebx: base
	;eax: symbol
;	cmp	eax, '0'
;	jb	CheckBase_error
;	cmp	eax, '9'
;	jbe	CheckBase1
;	cmp	eax, 'A'
;	jb	CheckBase_error
;CheckBase1:
;	cmp	ebx, eax
;CheckBase_error:
;	ret
;CheckBase	endp


;ToUpperReg	proc	near
;	cmp	eax, 'a'
;	jb	ToUpperReg_exit
;	cmp	eax, 'z'
;	ja	ToUpperReg_exit
;	sub	eax, 20h
;ToUpperReg_exit:
;	ret
;ToUpperReg	endp


;CheckSymbol	proc	near
;	ret
;CheckSymbol	endp
GetSymbol8	proc	near
	;out
	;eax:	symbol
	xor	eax, eax
	lodsb
;	test	al, al
;	js	
;	sub	al, '0'
	ret
GetSymbol8	endp

GetSymbol16	proc	near
	;out
	;eax:	symbol
	xor	eax, eax
	lodsw
;	test	ax, ax
;	js	
;	sub	al, '0'
	ret
GetSymbol16	endp

GetSymbolRutf	proc	near
	;out
	;eax:	symbol
	xor	eax, eax
	lodsb
	test	al, al
	jns	GetSymbolRutf_exit
;	shl	eax, 8
	ror	eax, 7
	lodsb
	test	al, al
	jns	GetSymbolRutf_exit1
;	shr	eax, 16
	ror	eax, 7
	lodsw
	ror	eax, 18
	jmp	GetSymbolRutf_exit
GetSymbolRutf_exit1:
	rol	eax, 7
GetSymbolRutf_exit:
	ret
GetSymbolRutf	endp

HexString2Qword proc	near
	;in
	;esi: pointer to string (in backward direction)
	;ecx: string size
	;ebp: sign check
	;out
	;edx:eax: number
	;edi, ecx, ebx: destoryed
	xor	eax, eax
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 16
	ja	HexString2Qword_error
	push	ecx
HexString2Qword_next:
	lodsb
	sub	al, 'A'
	jc	HexString2Qword_digit
	sub	al, 'a' - 'A' + 10
	jnc	HexString2Qword_write
	add	al, 'a' - 'A' + 10
	jmp	HexString2Qword_write
HexString2Qword_digit:
	add	al, 'A' - '0'
HexString2Qword_write:
	shrd	edx, ebx, 4
	ror	eax, 4
	or	edx, eax
	loop	HexString2Qword_next
	pop	ecx
	lea	ecx, [ecx * 4 ]
HexString2Qword_count_cvts:
	xor	cl, 1111111b
	inc	cl
	shrd	edx, ebx, cl
	test	cl, 100000b
	jz	HexString2Qword_32xcgh
	xchg	ebx, edx
HexString2Qword_32xcgh:
	mov	eax, ebx
	jmp	String2Int_sign_fix
HexString2Qword_error:
	xor	eax, eax
	xor	edx, edx
	ret
HexString2Qword endp


BinString2Qword proc	near
	;in
	;esi: pointer to string (in backward direction)
	;ecx: string size
	;ebp: sign check
	;out
	;edx:eax: number
	;edi, ecx, ebx: destoryed
	xor	eax, eax
	xor	ecx, ecx
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 64
	ja	HexString2Qword_error
	push	ecx
BinString2Qword_next:
	call	GetSymbol
	shr	eax, 1
	rcr	edx, 1
	rcr	ebx, 1
	loop	BinString2Qword_next
	pop	ecx
	jmp	HexString2Qword_count_cvts
;	xor	cl, 1111111b
;	shrd	edx, ebx, cl
;	test	cl, 100000b
;	jz	HexString2Qword_32xcgh
;	xchg	ebx, edx
;HexString2Qword_32xcgh:
;	mov	eax, ebx
;	jmp	String2Int_sign_fix
BinString2Qword endp


OctalString2Qword proc	near
	xor	eax, eax
	xor	ecx, ecx
	xor	ebx, ebx
	xor	edx, edx
	cmp	ecx, 22
	ja	HexString2Qword_error
	push	ecx
OctalString2Qword_next:
	call	GetSymbol
	cmp	edi, 22
	jnz	OctalString2Qword_signed_digit
	pop	ecx
	cmp	al, 1
	ja	HexString2Qword_error
	shr	eax, 1
	rcr	edx, 1
	rcr	ebx, 1
	jmp	HexString2Qword_count_cvts
OctalString2Qword_signed_digit:
	shrd	edx, ebx, 3
	ror	eax, 3
	or	edx, eax
	loop	OctalString2Qword_next
	pop	ecx
	ja	HexString2Qword_error
	lea	ecx, [ecx + ecx * 2]
	jmp	HexString2Qword_count_cvts
OctalString2Qword endp


IntString2Qword proc	near
	;in
	;esi: pointer to string (in backward direction)
	;cl(!ecx): string size
	;eax: base
	;ebp: sign check
	push	ebx
	push	ebp
	push	eax
	xor	eax, eax
	push	eax
	push	eax
	mov	edi, 1
	xor	ebp, ebp
String2Int_loop:
	xor	eax, eax
	call	GetSymbol
	mov	ebx, eax
	mul	edi
	add	[esp+4], eax
	adc	[esp], edx
	jc	String2Int_error
	mov	eax, ebx
	mul	ebp
	or	edx, edx
	jnz	String2Int_error
	add	[esp], eax
	jc	String2Int_error
	dec	cl
	jz	String2Int_loop_exit
	mov	eax, edi
	mul	dword ptr [esp+8]
	mov	edi, eax
	xchg	ebp, edx
	or	edx, edx
	jz	String2Int_loop
	imul	edx, dword ptr [esp+8]
	add	ebp, edx
	jmp	String2Int_loop
String2Int_loop_exit:
	pop	edx
	pop	eax
	pop	edi
	pop	ebp
	pop	ebx
String2Int_sign_fix:
	test	ebp, edx
	js	String2Int_error1;///??? comp to 0????
	test	ebp, ebp
	jns	String2Int_pop_exit
	not	edx
	not	eax
	inc	eax
	adc	edx, 0
	jns	String2Int_error1;///??? comp to 0????
String2Int_pop_exit:
	ret
String2Int_error:
	pop	eax
	pop	edx
	pop	edi
	pop	ebp
	pop	ebx
String2Int_error1:
	stc
	ret
IntString2Qword endp


@FastString@$oo$xqqrv	proc	near
@FastString@$oo$xqqrv	endp
@FastString@$oc$xqqrv	proc	near
@FastString@$ozc$xqqrv:
@FastString@$oc$xqqrv	endp
@FastString@$ouc$xqqrv	proc	near
@FastString@$ouc$xqqrv	endp
@FastString@$os$xqqrv	proc	near
@FastString@$os$xqqrv	endp
@FastString@$ous$xqqrv	proc	near
@FastString@$ous$xqqrv	endp
@FastString@$oi$xqqrv	proc	near
@FastString@$ol$xqqrv:
	;in
	;eax: this
	;out
	;eax: integer value
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@$oi$xqqrv_nullval
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	or	ecx, ecx
	jz	@FastString@$oi$xqqrv_nulllen
	push	ebx
	push	esi
	push	edi
	push	ebp
	pushfd
	mov	esi, eax
	call	CheckString
	jc	@FastString@$oi$xqqrv_CheckString_error
	jmp	[ebx * 4 + ToIntTable]
@FastString@$oi$xqqrv_FromInt:
	mov	eax, [decimal_constant]
	call	IntString2Qword
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_FromExp:
	mov	eax, [decimal_constant]
	call	IntString2Qword
	push	ecx
	push	ebp
	fild	qword ptr[esp]
	pop	ecx
	pop	ecx
	dec	esi
	fldl2t
	fmulp
	fstsw	ax
	test	ah, 1000b
	jz	@FastString@$oi$xqqrv_FromExp_1
	fchs
@FastString@$oi$xqqrv_FromExp_1:
	fld	st(0)
	frndint
	fsub	st(1), st(0)
;	fld1
;	fscale
	fxch
	f2xm1
	fld1
	faddp
	fscale
	jz	@FastString@$oi$xqqrv_FromExp_2
	fld1
	fdivrp	st(1)
@FastString@$oi$xqqrv_FromExp_2:
;	movzx	eax, dh
;	sub	esi, eax
	stc
@FastString@$oi$xqqrv_FromFloat:
	pushfd
;	movzx	eax, bl
;	sub	esi, eax
	push	edi
	mov	edi, ebp
	xor	ebp, ebp
	mov	eax, [decimal_constant]
	call	IntString2Qword
	push	ebp
	push	edi
	fild	qword ptr[esp]
	push	edx
	push	eax
	fild	qword ptr[esp]
	
;	and	edi, 0ffh
;	sub	esi, edi
	sub	esi, [esp+16]
	mov	eax, [decimal_constant]
	fdivrp
;	dec	esi
;	movzx	eax, bl
;	sub	esi, eax
	mov	ebp, ebx
;	mov	ebp, [esp+16]
	shr	ecx, 8
	call	IntString2Qword
	push	edx
	push	eax
	fild	qword ptr[esp]
	faddp
	add	esp, 24
	pop	edi
	popfd
	jnc	@FastString@$oi$xqqrv_exit
	fmulp
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_FromHex:
	call	HexString2Qword
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_FromOctal:
	call	OctalString2Qword
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_FromBinary:
	call	BinString2Qword
@FastString@$oi$xqqrv_exit:
	popfd
	pop	ebp
	pop	edi
	pop	esi
	pop	ebx
	ret
@FastString@$oi$xqqrv_CheckString_error:
	xor	eax, eax
	jmp	@FastString@$oi$xqqrv_exit
@FastString@$oi$xqqrv_nulllen:
	xor	eax, eax
@FastString@$oi$xqqrv_nullval:
	ret
@FastString@$oi$xqqrv	endp
@FastString@$oui$xqqrv	proc	near
@FastString@$oul$xqqrv:
@FastString@$oui$xqqrv	endp
@FastString@$oj$xqqrv	proc	near
@FastString@$oj$xqqrv	endp
@FastString@$ouj$xqqrv	proc	near
@FastString@$ouj$xqqrv	endp
@FastString@$of$xqqrv	proc	near
@FastString@$of$xqqrv	endp
@FastString@$od$xqqrv	proc	near
@FastString@$od$xqqrv	endp
@FastString@$og$xqqrv	proc	near
@FastString@$og$xqqrv	endp
@FastString@$opv$xqqrv	proc	near
@FastString@$opv$xqqrv	endp
@FastString@$opb$qqrv	proc	near
@FastString@$opb$qqrv	endp
@FastString@$opc$qqrv	proc	near
@FastString@$opc$qqrv	endp
@FastString@$o17System@AnsiString$qqrv	proc	near
@FastString@$o17System@AnsiString$qqrv	endp
@FastString@$o17System@WideString$qqrv	proc	near
@FastString@$o17System@WideString$qqrv	endp


;---------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------

;@FastString@ConvertTo$qqrul:
@FastString@ConvertTo$qqrul	proc	near
@FastString@ChangeCodePage$qqrul:
	;in
	;eax: this
	;edx: codepage
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@ConvertTo$qqrui_empty
	;simple convert
	push	esi
	push	edi
	mov	esi, eax
	mov	edi, eax
	mov	ecx, [eax - SIZEOF_FASTSTRING + FastString.Length]
	xchg	dx, [eax - SIZEOF_FASTSTRING + FastString.CodePage.Page]
	movzx	eax, word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page]
;	movzx	eax, word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page]
;	mov	word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page], dx
	xchg	eax, edx
	cmp	eax, edx
	jz	@FastString@ConvertTo$qqrui_dontcvt
	test	ah, dh
	js	@FastString@ConvertTo$qqrui_utf
	call	Convert8_8
@FastString@ConvertTo$qqrui_dontcvt:
	pop	edi
	pop	esi
@FastString@ConvertTo$qqrui_empty:
	ret
@FastString@ConvertTo$qqrui_utf:
	test	ah, ah
	js	@FastString@ConvertTo$qqrui_ruft
	test	ah, 40h
	jnz	@FastString@ConvertTo$qqrui_uft16
	test	dh, dh
	js	@FastString@ConvertTo$qqrui_to_ruft
	call	Convert8_16
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_to_ruft:
	call	Convert8_8P
	jmp	@FastString@ConvertTo$qqrui_dontcvt

@FastString@ConvertTo$qqrui_uft16:
	test	dh, dh
	jnz	@FastString@ConvertTo$qqrui_utf16_to_ruft
	call	Convert16_8
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_utf16_to_ruft:
	call	Convert16_8P
	jmp	@FastString@ConvertTo$qqrui_dontcvt

@FastString@ConvertTo$qqrui_ruft:
	test	dh, 40h
	jnz	@FastString@ConvertTo$qqrui_rutf_to_uft16
	call	Convert8P_8
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrui_rutf_to_uft16:
	call	Convert8P_16
	jmp	@FastString@ConvertTo$qqrui_dontcvt
@FastString@ConvertTo$qqrul	endp




;@FastString@SetCodePage$qqrul:
@FastString@SetCodePage$qqrul	proc	near
	;in
	;eax: this
	;edx: codepage
	mov	eax, [eax]
	or	eax, eax
	jz	@FastString@SetCodePage$qqrui_empty
	mov	word ptr[eax - SIZEOF_FASTSTRING + FastString.CodePage.Page], dx
@FastString@SetCodePage$qqrui_empty:
	ret
@FastString@SetCodePage$qqrul	endp



Convert8_8:
	;in
	;eax: input codepage
	;edx: output codepage
	;esi: input string
	;edi: output string
	;ecx: input count
	;out
	;esi: new input string
	;esi: new output string
	;ecx, eax, edx: destroyed
	push	ebx
	push	ebp
	imul	eax, RUSSIAN_CP_COUNT * 4
;	shl	edx, 2
;	lea	esi, [RussianConvertTable8_8 + eax*4 + edx*4]
	mov	ebx, [RussianConvertTable8_8 + edx*4 + eax]
	push	ebx
	xor	eax, eax
	mov	ebp, ecx
Convert8_8_enter:
	lodsb
	mov	ebx, [esp]
	movzx	ecx, byte ptr[ebx]
Convert8_8_a:
;	lodsw
	mov	dx, [ebx+1]
	cmp	al, dl
	jb	Convert8_8_b
	cmp	al, dh
	ja	Convert8_8_b
	sub	al, dl
	mov	al, [ebx+eax+3]
	jmp	Convert8_8_next
Convert8_8_b:
	sub 	dh, dl
	shr	edx, 8
	lea	ebx, [ebx+edx+3]
	loop	Convert8_8_a
Convert8_8_next:
	stosb
	dec	ebp
	jnz	Convert8_8_enter
	pop	ebx
	pop	ebp
	pop	ebx
	ret
Convert8_16:
	;eax: input codepage
	lea	esi, [RussianConvertTable8_16 + eax*4]
	ret
Convert8_8P:
Convert16_8:
	;edx: output codepage
	lea	esi, [RussianConvertTable16_8 + edx*4]
	ret
Convert16_8P:
Convert8P_8:
Convert8P_16:



.data
RussianConvertTable8_8	label	dword
	dd	0, Cp866_Cp1251_tbl, Cp866_Mac_tbl, Cp866_Koi8r_tbl, Cp866_Mac_tbl, Cp866_Cp8859_5_tbl
	dd	Cp1251_Cp866_tbl, 0, Cp1251_Cp10007_tbl, Cp1251_Koi8r_tbl, Cp1251_Mac_tbl, Cp1251_Cp8859_5_tbl
	dd	Cp10007_Cp866_tbl, Cp10007_Cp1251_tbl, 0, Cp10007_Koi8r_tbl, 0, Cp10007_Cp8859_5_tbl
	dd	Koi8r_Cp866_tbl, Koi8r_Cp1251_tbl, Koi8r_Cp10007_tbl, 0, Koi8r_Mac_tbl, Koi8r_Cp8859_5_tbl
	dd	Mac_Cp866_tbl, Mac_Cp1251_tbl, 0, Cp10007_Koi8r_tbl, 0, Cp10007_Cp8859_5_tbl
	dd	Cp8859_5_Cp866_tbl, Cp8859_5_Cp1251_tbl, Cp8859_5_Mac_tbl, Cp8859_5_Koi8r_tbl, Cp8859_5_Mac_tbl, 0
RussianConvertTable8_16	label	dword
	dd	Cp866_Utf16_tbl, Cp1251_Utf16_tbl, Cp10007_Utf16_tbl, Koi8r_Utf16_tbl, Mac_Utf16_tbl, Cp8859_5_Utf16_tbl
RussianConvertTable8_8P	label	dword
;	dd	Cp866_Cutf_tbl, Cp1251_Cutf_tbl, Cp10007_Cutf_tbl, Koi8r_Cutf_tbl, Mac_Cutf_tbl, Cp8859_5_Cutf_tbl
RussianConvertTable16_8	label	dword
	dd	Utf16_Cp866_tbl, Utf16_Cp1251_tbl, Utf16_Cp10007_tbl, Utf16_Koi8r_tbl, Utf16_Mac_tbl, Utf16_Cp8859_5_tbl
RussianConvertTable16_8P	label	dword
;	dd	Utf16_Cutf_tbl
RussianConvertTable8P_8	label	dword
;	dd	Cutf_Cp866_tbl, Cutf_Cp1251_tbl, Cutf_Cp10007_tbl, Cutf_Koi8r_tbl, Cutf_Mac_tbl, Cutf_Cp8859_5_tbl
RussianConvertTable8P_16	label	dword
;	dd	Cutf_Utf16_tbl

;0->1
Cp866_Cp1251_tbl:
	db	5h
	db	80h, 0afh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh
	db	0e0h, 0f8h, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0a8h, 0b8h, 0aah, 0bah, 0afh, 0bfh, 0a1h, 0a2h, 0b0h
	db	0fah, 0fah, 0b7h
	db	0fch, 0fdh, 0b9h, 0a4h
	db	0ffh, 0ffh, 0a0h

;0->2+4
Cp866_Mac_tbl:
	db	4h
	db	0a0h, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh
	db	0e0h, 0f8h, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0ddh, 0deh, 0b8h, 0b9h, 0bah, 0bbh, 0d8h, 0d9h, 0a1h
	db	0fbh, 0fdh, 0c3h, 0dch, 0ffh
	db	0ffh, 0ffh, 0cah

;0->3
Cp866_Koi8r_tbl:
	db	3h
	db	80h, 0f1h, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 090h, 091h, 092h, 081h, 087h, 0b2h, 0b4h, 0a7h, 0a6h, 0b5h, 0a1h, 0a8h, 0aeh, 0adh, 0ach, 083h, 084h, 089h, 088h, 086h, 080h, 08ah, 0afh, 0b0h, 0abh, 0a5h, 0bbh, 0b8h, 0b1h, 0a0h, 0beh, 0b9h, 0bah, 0b6h, 0b7h, 0aah, 0a9h, 0a2h, 0a4h, 0bdh, 0bch, 085h, 082h, 08dh, 08ch, 08eh, 08fh, 08bh, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h, 0b3h, 0a3h
	db	0f8h, 0fbh, 09ch, 095h, 09eh, 096h
	db	0feh, 0ffh, 094h, 09ah

;0->5
Cp866_Cp8859_5_tbl:
	db	5h
	db	080h, 0afh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh
	db	0f0h, 0f0h, 0a1h
	db	0f2h, 0f7h, 0a4h, 0f4h, 0a7h, 0f7h, 0aeh, 0feh
	db	0fch, 0fch, 0f0h
	db	0ffh, 0ffh, 0a0h

;1->0
Cp1251_Cp866_tbl:
	db	7h
	db	0a0h, 0a2h, 0ffh, 0f6h, 0f7h
	db	0a4h, 0a4h, 0fdh
	db	0a8h, 0a8h, 0f0h
	db	0aah, 0aah, 0f2h
	db	0afh, 0b0h, 0f4h, 0f8h
	db	0b7h, 0bah, 0fah, 0f1h, 0fch, 0f3h
	db	0bfh, 0ffh, 0f5h, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh

;1->2
Cp1251_Cp10007_tbl:
	db	0ch
	db	080h, 081h, 0abh, 0aeh
	db	083h, 086h, 0afh, 0d7h, 0c9h, 0a0h
	db	08ah, 08ah, 0bch
	db	08ch, 09ah, 0beh, 0cdh, 0cbh, 0dah, 0ach, 0d4h, 0d5h, 0d2h, 0d3h, 0a5h, 0d0h, 0d1h, 0aah, 0bdh, 0h
	db	09ch, 0a4h, 0bfh, 0ceh, 0cch, 0dbh, 0cah, 0d8h, 0d9h, 0b7h, 0ffh
	db	0a7h, 0a8h, 0a4h, 0ddh
	db	0aah, 0ach, 0b8h, 0c7h, 0c2h
	db	0aeh, 0b0h, 0a8h, 0bah, 0a1h
	db	0b2h, 0b3h, 0a7h, 0b4h
	db	0b6h, 0b6h, 0a6h
	db	0b8h, 0dfh, 0deh, 0dch, 0b9h, 0c8h, 0c0h, 0c1h, 0cfh, 0bbh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh
	db	0ffh, 0ffh, 0dfh

;1->3
Cp1251_Koi8r_tbl:
	db	5h
	db	0a0h, 0a0h, 09ah
	db	0a8h, 0a9h, 0b3h, 0bfh
	db	0b0h, 0b0h, 09ch
	db	0b7h, 0b8h, 09eh, 0a3h
	db	0c0h, 0ffh, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h

;1->4
Cp1251_Mac_tbl:
	db	0eh
	db	080h, 081h, 0abh, 0aeh
	db	083h, 086h, 0afh, 0d7h, 0c9h, 0a0h
	db	088h, 088h, 0ffh
	db	08ah, 08ah, 0bch
	db	08ch, 09ah, 0beh, 0cdh, 0cbh, 0dah, 0ach, 0d4h, 0d5h, 0d2h, 0d3h, 0a5h, 0d0h, 0d1h, 0aah, 0bdh, 0efh
	db	09ch, 0a3h, 0bfh, 0ceh, 0cch, 0dbh, 0cah, 0d8h, 0d9h, 0b7h
	db	0a5h, 0a5h, 0a2h
	db	0a7h, 0a8h, 0a4h, 0ddh
	db	0aah, 0ach, 0b8h, 0c7h, 0c2h
	db	0aeh, 0b0h, 0a8h, 0bah, 0a1h
	db	0b2h, 0b4h, 0a7h, 0b4h, 0b6h
	db	0b6h, 0b6h, 0a6h
	db	0b8h, 0dfh, 0deh, 0dch, 0b9h, 0c8h, 0c0h, 0c1h, 0cfh, 0bbh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh
	db	0ffh, 0ffh, 0dfh

;1->5
Cp1251_Cp8859_5_tbl:
	db	0dh
	db	080h, 081h, 0a2h, 0a3h
	db	083h, 083h, 0f3h
	db	08ah, 08ah, 0a9h
	db	08ch, 090h, 0aah, 0ach, 0abh, 0afh, 0f2h
	db	09ah, 09ah, 0f9h
	db	09ch, 09fh, 0fah, 0fch, 0fbh, 0ffh
	db	0a1h, 0a3h, 0aeh, 0feh, 0a8h
	db	0a7h, 0a8h, 0fdh, 0a1h
	db	0aah, 0aah, 0a4h
	db	0afh, 0afh, 0a7h
	db	0b2h, 0b3h, 0a6h, 0f6h
	db	0b8h, 0bah, 0f1h, 0f0h, 0f4h
	db	0bch, 0ffh, 0f8h, 0a5h, 0f5h, 0f7h, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh

;2->0
Cp10007_Cp866_tbl:
	db	6h
	db	0a1h, 0a1h, 0f8h
	db	0b8h, 0bbh, 0f2h, 0f3h, 0f4h, 0f5h
	db	0c3h, 0c3h, 0fbh
	db	0cah, 0cah, 0ffh
	db	0d8h, 0d9h, 0f6h, 0f7h
	db	0dch, 0ffh, 0fch, 0f0h, 0f1h, 0efh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0fdh


;2->1
Cp10007_Cp1251_tbl:
	db	9h
	db	080h, 0a1h, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 086h, 0b0h
	db	0a4h, 0a8h, 0a7h, 095h, 0b6h, 0b2h, 0aeh
	db	0aah, 0ach, 099h, 080h, 090h
	db	0aeh, 0afh, 081h, 083h
	db	0b4h, 0b4h, 0b3h
	db	0b7h, 0c2h, 0a3h, 0aah, 0bah, 0afh, 0bfh, 08ah, 09ah, 08ch, 09ch, 0bch, 0bdh, 0ach
	db	0c7h, 0d5h, 0abh, 0bbh, 085h, 0a0h, 08eh, 09eh, 08dh, 09dh, 0beh, 096h, 098h, 093h, 094h, 091h, 092h
	db	0d7h, 0dfh, 084h, 0a1h, 0a2h, 08fh, 09fh, 0b9h, 0a8h, 0b8h, 0ffh
	db	0ffh, 0ffh, 0a4h

;2+4->3
Cp10007_Koi8r_tbl:
	db	9h
	db	080h, 09fh, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h
	db	0a1h, 0a1h, 09ch
	db	0a9h, 0a9h, 0bfh
	db	0b2h, 0b3h, 098h, 099h
	db	0c3h, 0c3h, 096h
	db	0c5h, 0c5h, 097h
	db	0cah, 0cah, 09ah
	db	0d6h, 0d6h, 09fh
	db	0ddh, 0feh, 0b3h, 0a3h, 0d1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h

;2+4->5
Cp10007_Cp8859_5_tbl:
	db	9h
	db	080h, 09fh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh
	db	0a4h, 0a4h, 0fdh
	db	0a7h, 0a7h, 0a6h
	db	0abh, 0ach, 0a2h, 0f2h
	db	0aeh, 0afh, 0a3h, 0f3h
	db	0b4h, 0b4h, 0f6h
	db	0b7h, 0c1h, 0a8h, 0a4h, 0f4h, 0a7h, 0f7h, 0a9h, 0f9h, 0aah, 0fah, 0f8h, 0a5h
	db	0cah, 0cfh, 0a0h, 0abh, 0fbh, 0ach, 0fch, 0f5h
	db	0d8h, 0feh, 0aeh, 0feh, 0afh, 0ffh, 0f0h, 0a1h, 0f1h, 0efh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh

;3->0
Koi8r_Cp866_tbl:
	db	7h
	db	080h, 092h, 0c4h, 0b3h, 0dah, 0bfh, 0c0h, 0d9h, 0c3h, 0b4h, 0c2h, 0c1h, 0c5h, 0dfh, 0dch, 0dbh, 0ddh, 0deh, 0b0h, 0b1h, 0b2h
	db	094h, 096h, 0feh, 0f9h, 0fbh
	db	09ah, 09ah, 0ffh
	db	09ch, 09ch, 0f8h
	db	09eh, 09eh, 0fah
	db	0a0h, 0beh, 0cdh, 0bah, 0d5h, 0f1h, 0d6h, 0c9h, 0b8h, 0b7h, 0bbh, 0d4h, 0d3h, 0c8h, 0beh, 0bdh, 0bch, 0c6h, 0c7h, 0cch, 0b5h, 0f0h, 0b6h, 0b9h, 0d1h, 0d2h, 0cbh, 0cfh, 0d0h, 0cah, 0d8h, 0d7h, 0ceh
	db	0c0h, 0ffh, 0eeh, 0a0h, 0a1h, 0e6h, 0a4h, 0a5h, 0e4h, 0a3h, 0e5h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0efh, 0e0h, 0e1h, 0e2h, 0e3h, 0a6h, 0a2h, 0ech, 0ebh, 0a7h, 0e8h, 0edh, 0e9h, 0e7h, 0eah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3->1
Koi8r_Cp1251_tbl:
	db	6h
	db	09ah, 09ah, 0a0h
	db	09ch, 09ch, 0b0h
	db	09eh, 09eh, 0b7h
	db	0a3h, 0a3h, 0b8h
	db	0b3h, 0b3h, 0a8h
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0ffh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 0deh, 0c0h, 0c1h, 0d6h, 0c4h, 0c5h, 0d4h, 0c3h, 0d5h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0dfh, 0d0h, 0d1h, 0d2h, 0d3h, 0c6h, 0c2h, 0dch, 0dbh, 0c7h, 0d8h, 0ddh, 0d9h, 0d7h, 0dah

;3->2
Koi8r_Cp10007_tbl:
	db	6h
	db	096h, 09ah, 0c3h, 0c5h, 0b2h, 0b3h, 0cah
	db	09ch, 09ch, 0a1h
	db	09fh, 09fh, 0d6h
	db	0a3h, 0a3h, 0deh
	db	0b3h, 0b3h, 0ddh
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0dfh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3->4
Koi8r_Mac_tbl:
	db	6h
	db	096h, 09ah, 0c3h, 0c5h, 0b2h, 0b3h, 0cah
	db	09ch, 09ch, 0a1h
	db	09fh, 09fh, 0d6h
	db	0a3h, 0a3h, 0deh
	db	0b3h, 0b3h, 0ddh
	db	0bfh, 0ffh, 0a9h, 0feh, 0e0h, 0e1h, 0f6h, 0e4h, 0e5h, 0f4h, 0e3h, 0f5h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0dfh, 0f0h, 0f1h, 0f2h, 0f3h, 0e6h, 0e2h, 0fch, 0fbh, 0e7h, 0f8h, 0fdh, 0f9h, 0f7h, 0fah, 09eh, 080h, 081h, 096h, 084h, 085h, 094h, 083h, 095h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 09fh, 090h, 091h, 092h, 093h, 086h, 082h, 09ch, 09bh, 087h, 098h, 09dh, 099h, 097h, 09ah

;3->5
Koi8r_Cp8859_5_tbl:
	db	5h
	db	09ah, 09ah, 0a0h
	db	0a3h, 0a3h, 0f1h
	db	0b3h, 0b3h, 0a1h
	db	0c0h, 0d5h, 0eeh, 0d0h, 0d1h, 0e6h, 0d4h, 0d5h, 0e4h, 0d3h, 0e5h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0efh, 0e0h, 0e1h, 0e2h, 0e3h
	db	0d7h, 0ffh, 0d2h, 0ech, 0ebh, 0d7h, 0e8h, 0edh, 0e9h, 0e7h, 0eah, 0ceh, 0b0h, 0b1h, 0c6h, 0b4h, 0b5h, 0c4h, 0b3h, 0c5h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0cfh, 0c0h, 0c1h, 0c2h, 0c3h, 0b6h, 0b2h, 0cch, 0cbh, 0b7h, 0c8h, 0cdh, 0c9h, 0c7h, 0cah

;4->0
Mac_Cp866_tbl:
	db	6h
	db	0a1h, 0a1h, 0f8h
	db	0b8h, 0bbh, 0f2h, 0f3h, 0f4h, 0f5h
	db	0c3h, 0c3h, 0fbh
	db	0cah, 0cah, 0ffh
	db	0d8h, 0d9h, 0f6h, 0f7h
	db	0dch, 0feh, 0fch, 0f0h, 0f1h, 0efh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh

;4->1
Mac_Cp1251_tbl:
	db	9h
	db	080h, 0a2h, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 086h, 0b0h, 0a5h
	db	0a4h, 0a8h, 0a7h, 095h, 0b6h, 0b2h, 0aeh
	db	0aah, 0ach, 099h, 080h, 090h
	db	0aeh, 0afh, 081h, 083h
	db	0b4h, 0b4h, 0b3h
	db	0b6h, 0c2h, 0b4h, 0a3h, 0aah, 0bah, 0afh, 0bfh, 08ah, 09ah, 08ch, 09ch, 0bch, 0bdh, 0ach
	db	0c7h, 0d5h, 0abh, 0bbh, 085h, 0a0h, 08eh, 09eh, 08dh, 09dh, 0beh, 096h, 098h, 093h, 094h, 091h, 092h
	db	0d7h, 0dfh, 084h, 0a1h, 0a2h, 08fh, 09fh, 0b9h, 0a8h, 0b8h, 0ffh
	db	0ffh, 0ffh, 088h


;5->0
Cp8859_5_Cp866_tbl:
	db	9h
	db	0a0h, 0a1h, 0ffh, 0f0h
	db	0a4h, 0a4h, 0f2h
	db	0a7h, 0a7h, 0f4h
	db	0aeh, 0aeh, 0f6h
	db	0b0h, 0dfh, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh
	db	0f0h, 0f0h, 0fch
	db	0f4h, 0f4h, 0f3h
	db	0f7h, 0f7h, 0f5h
	db	0feh, 0feh, 0f7h

;5->1
Cp8859_5_Cp1251_tbl:
	db	2h
	db	0a1h, 0ach, 0a8h, 080h, 081h, 0aah, 0bdh, 0b2h, 0afh, 0a3h, 08ah, 08ch, 08eh, 08dh
	db	0aeh, 0ffh, 0a1h, 08fh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0b9h, 0b8h, 090h, 083h, 0bah, 0beh, 0b3h, 0bfh, 0bch, 09ah, 09ch, 09eh, 09dh, 0a7h, 0a2h, 09fh

;5->2+4
Cp8859_5_Mac_tbl:
	db	2h
	db	0a0h, 0ach, 0cah, 0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh
	db	0aeh, 0ffh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0dch, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0a4h, 0d9h, 0dbh

;5->3
Cp8859_5_Koi8r_tbl:
	db	4h
	db	0a0h, 0a1h, 09ah, 0b3h
	db	0b0h, 0d5h, 0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h
	db	0d7h, 0efh, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h
	db	0f1h, 0f1h, 0a3h





;wchar->0
Utf16_Cp866_tbl:
	db	01eh
	dw	0a0h, 0a0h
	db	0ffh
	dw	0a4h, 0a4h
	db	0fdh
	dw	0b0h, 0b0h
	db	0f8h
	dw	0b7h, 0b7h
	db	0fah
	dw	0401h, 0401h
	db	0f0h
	dw	0404h, 0404h
	db	0f2h
	dw	0407h, 0407h
	db	0f4h
	dw	040eh, 0451h
	db	0f6h, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0a0h, 0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f1h, 0h, 0h
	dw	0454h, 0454h
	db	0f3h
	dw	0457h, 0457h
	db	0f5h
	dw	045eh, 045eh
	db	0f7h
	dw	02116h, 02116h
	db	0fch
	dw	02219h, 0221ah
	db	0f9h, 0fbh
	dw	02500h, 02501h
	db	0c4h, 0b3h
	dw	0250ch, 0250ch
	db	0dah
	dw	02510h, 02510h
	db	0bfh
	dw	02514h, 02514h
	db	0c0h
	dw	02518h, 02518h
	db	0d9h
	dw	0251ch, 0251ch
	db	0c3h
	dw	02524h, 02524h
	db	0b4h
	dw	0252ch, 0252ch
	db	0c2h
	dw	02534h, 02534h
	db	0c1h
	dw	0253ch, 0253ch
	db	0c5h
	dw	02550h, 0256ch
	db	0cdh, 0bah, 0d5h, 0d6h, 0c9h, 0b8h, 0b7h, 0bbh, 0d4h, 0d3h, 0c8h, 0beh, 0bdh, 0bch, 0c6h, 0c7h, 0cch, 0b5h, 0b6h, 0b9h, 0d1h, 0d2h, 0cbh, 0cfh, 0d0h, 0cah, 0d8h, 0d7h, 0ceh
	dw	02580h, 02580h
	db	0dfh
	dw	02584h, 02584h
	db	0dch
	dw	02588h, 02588h
	db	0dbh
	dw	0258ch, 0258ch
	db	0ddh
	dw	02590h, 02593h
	db	0deh, 0b0h, 0b1h, 0b2h
	dw	025a0h, 025a0h
	db	0feh

Utf16_Cp1251_tbl:
;wchar->1
	db	0ch
	dw	00401h, 045fh
	db	0a8h, 080h, 081h, 0aah, 0bdh, 0b2h, 0afh, 0a3h, 08ah, 08ch, 08eh, 08dh, 0a1h, 08fh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0ffh, 0b8h, 090h, 083h, 0bah, 0beh, 0b3h, 0bfh, 0bch, 09ah, 09ch, 09eh, 09dh, 0a2h, 09fh, 0h, 0h, 0h
	dw	0490h, 0491h
	db	0a5h, 0b4h
	dw	02013h, 02014h
	db	096h, 098h
	dw	02018h, 0201ah
	db	091h, 092h, 082h
	dw	0201ch, 0201eh
	db	093h, 094h, 084h
	dw	02020h, 02022h
	db	086h, 087h, 095h
	dw	02026h, 02026h
	db	085h
	dw	02030h, 02030h
	db	089h
	dw	02039h, 0203ah
	db	08bh, 09bh
	dw	020ach, 020ach
	db	088h
	dw	02116h, 02116h
	db	0b9h
	dw	02122h, 02122h
	db	099h

;wchar->2
Utf16_Cp10007_tbl:
	db	019h
	dw	0a0h, 0a0h
	db	0cah
	dw	0a4h, 0a4h
	db	0ffh
	dw	0a7h, 0a7h
	db	0a4h
	dw	0abh, 0ach
	db	0c7h, 0c2h
	dw	0aeh, 0b0h
	db	0a8h, 0a1h, 084h
	dw	0b6h, 0b6h
	db	0a6h
	dw	0bbh, 0bbh
	db	0c8h
	dw	0f7h, 0f7h
	db	0d6h
	dw	0192h, 0192h
	db	0c4h
	dw	0401h, 045fh
	db	0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0d9h, 0dbh, 0h, 0h, 0h
	dw	02013h, 02014h
	db	0d0h, 0d1h
	dw	02018h, 02019h
	db	0d4h, 0d5h
	dw	0201ch, 0201eh
	db	0d2h, 0d3h, 0d7h
	dw	02020h, 02020h
	db	0a0h
	dw	02022h, 02022h
	db	0a5h
	dw	02026h, 02026h
	db	0c9h
	dw	02116h, 02116h
	db	0dch
	dw	02122h, 02122h
	db	0aah
	dw	02202h, 02202h
	db	0b6h
	dw	02206h, 02206h
	db	0c6h
	dw	0221ah, 0221ah
	db	0c3h
	dw	0221eh, 0221eh
	db	0b0h
	dw	02248h, 02248h
	db	0c5h
	dw	02260h, 02260h
	db	0adh
	dw	02264h, 02265h
	db	0b2h, 0b3h

;wchar->3
Utf16_Koi8r_tbl:
	db	01dh
	dw	0a0h, 0a0h
	db	09ah
	dw	0a9h, 0a9h
	db	0bfh
	dw	0b0h, 0b0h
	db	09ch
	dw	0b2h, 0b2h
	db	09dh
	dw	0b7h, 0b7h
	db	09eh
	dw	0f7h, 0f7h
	db	09fh
	dw	0401h, 0401h
	db	0b3h
	dw	0410h, 0451h
	db	0e1h, 0e2h, 0f7h, 0e7h, 0e4h, 0e5h, 0f6h, 0fah, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f2h, 0f3h, 0f4h, 0f5h, 0e6h, 0e8h, 0e3h, 0feh, 0fbh, 0fdh, 0ffh, 0f9h, 0f8h, 0fch, 0e0h, 0f1h, 0c1h, 0c2h, 0d7h, 0c7h, 0c4h, 0c5h, 0d6h, 0dah, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d2h, 0d3h, 0d4h, 0d5h, 0c6h, 0c8h, 0c3h, 0deh, 0dbh, 0ddh, 0dfh, 0d9h, 0d8h, 0dch, 0c0h, 0d1h, 0a3h, 0f1h
	dw	02219h, 0221ah
	db	095h, 096h
	dw	02248h, 02248h
	db	097h
	dw	02264h, 02265h
	db	098h, 099h
	dw	02320h, 02321h
	db	093h, 09bh
	dw	02500h, 02502h
	db	080h, 081h, 0d7h
	dw	0250ch, 0250ch
	db	082h
	dw	02510h, 02510h
	db	083h
	dw	02514h, 02514h
	db	084h
	dw	02518h, 02518h
	db	085h
	dw	0251ch, 0251ch
	db	086h
	dw	02524h, 02524h
	db	087h
	dw	0252ch, 0252ch
	db	088h
	dw	02534h, 02534h
	db	089h
	dw	0253ch, 0253ch
	db	08ah
	dw	02550h, 0256ch
	db	0a0h, 0a1h, 0a2h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0adh, 0aeh, 0afh, 0b0h, 0b1h, 0b2h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh
	dw	02580h, 02580h
	db	08bh
	dw	02584h, 02584h
	db	08ch
	dw	02588h, 02588h
	db	08dh
	dw	0258ch, 0258ch
	db	08eh
	dw	02590h, 02593h
	db	08fh, 090h, 091h, 092h
	dw	025a0h, 025a0h
	db	094h

;wchar->4
Utf16_Mac_tbl:
	db	019h
	dw	0a0h, 0a0h
	db	0cah
	db	0a7h, 0a7h
	dw	0a4h
	dw	0abh, 0ach
	db	0c7h, 0c2h
	dw	0aeh, 0b0h
	db	0a8h, 0a1h, 082h
	dw	0b6h, 0b6h
	db	0a6h
	dw	0bbh, 0bbh
	db	0c8h
	dw	0f7h, 0f7h
	db	0d6h
	dw	0192h, 0192h
	db	0c4h
	dw	0401h, 045fh
	db	0ddh, 0abh, 0aeh, 0b8h, 0c1h, 0a7h, 0bah, 0b7h, 0bch, 0beh, 0cbh, 0cdh, 0d8h, 0dah, 080h, 081h, 082h, 083h, 084h, 085h, 086h, 087h, 088h, 089h, 08ah, 08bh, 08ch, 08dh, 08eh, 08fh, 090h, 091h, 092h, 093h, 094h, 095h, 096h, 097h, 098h, 099h, 09ah, 09bh, 09ch, 09dh, 09eh, 09fh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f0h, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0fdh, 0feh, 0dfh, 0deh, 0ach, 0afh, 0b9h, 0cfh, 0b4h, 0bbh, 0c0h, 0bdh, 0bfh, 0cch, 0ceh, 0d9h, 0dbh, 0h, 0h, 0h
	dw	0490h, 0491h
	db	0a2h, 0b6h
	dw	02013h, 02014h
	db	0d0h, 0d1h
	dw	02018h, 02019h
	db	0d4h, 0d5h
	dw	0201ch, 0201eh
	db	0d2h, 0d3h, 0d7h
	dw	02020h, 02020h
	db	0a0h
	dw	02022h, 02022h
	db	0a5h
	dw	02026h, 02026h
	db	0c9h
	dw	020ach, 020ach
	db	0ffh
	dw	02116h, 02116h
	db	0dch
	dw	02122h, 02122h
	db	0aah
	dw	02206h, 02206h
	db	0c6h
	dw	0221ah, 0221ah
	db	0c3h
	dw	0221eh, 0221eh
	db	0b0h
	dw	02248h, 02248h
	db	0c5h
	dw	02260h, 02260h
	db	0adh
	dw	02264h, 02265h
	db	0b2h, 0b3h

;wchar->5
Utf16_Cp8859_5_tbl:
	db	3h
	dw	0a7h, 0a7h
	db	0fdh
	dw	0401h, 045fh
	db	0a1h, 0a2h, 0a3h, 0a4h, 0a5h, 0a6h, 0a7h, 0a8h, 0a9h, 0aah, 0abh, 0ach, 0aeh, 0afh, 0b0h, 0b1h, 0b2h, 0b3h, 0b4h, 0b5h, 0b6h, 0b7h, 0b8h, 0b9h, 0bah, 0bbh, 0bch, 0bdh, 0beh, 0bfh, 0c0h, 0c1h, 0c2h, 0c3h, 0c4h, 0c5h, 0c6h, 0c7h, 0c8h, 0c9h, 0cah, 0cbh, 0cch, 0cdh, 0ceh, 0cfh, 0d0h, 0d1h, 0d2h, 0d3h, 0d4h, 0d5h, 0d6h, 0d7h, 0d8h, 0d9h, 0dah, 0dbh, 0dch, 0ddh, 0deh, 0dfh, 0e0h, 0e1h, 0e2h, 0e3h, 0e4h, 0e5h, 0e6h, 0e7h, 0e8h, 0e9h, 0eah, 0ebh, 0ech, 0edh, 0eeh, 0efh, 0f1h, 0f2h, 0f3h, 0f4h, 0f5h, 0f6h, 0f7h, 0f8h, 0f9h, 0fah, 0fbh, 0fch, 0feh, 0ffh, 0h, 0h, 0h
	dw	02116h, 02116h
	db	0f0h


;0->wchar
Cp866_Utf16_tbl:
	db	1h
	db	080h, 0ffh
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 02591h, 02592h, 02593h, 02502h, 02524h, 02561h, 02562h, 02556h, 02555h, 02563h, 02551h, 02557h, 0255dh, 0255ch, 0255bh, 02510h, 02514h, 02534h, 0252ch, 0251ch, 02500h, 0253ch, 0255eh, 0255fh, 0255ah, 02554h, 02569h, 02566h, 02560h, 02550h, 0256ch, 02567h, 02568h, 02564h, 02565h, 02559h, 02558h, 02552h, 02553h, 0256bh, 0256ah, 02518h, 0250ch, 02588h, 02584h, 0258ch, 02590h, 02580h, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh, 0401h, 0451h, 0404h, 0454h, 0407h, 0457h, 040eh, 045eh, 0b0h, 02219h, 0b7h, 0221ah, 02116h, 0a4h, 025a0h, 0a0h

;1->wchar
Cp1251_Utf16_tbl:
	db	0ah
	db	080h, 096h
	dw	0402h, 0403h, 0201ah, 0453h, 0201eh, 02026h, 02020h, 02021h, 020ach, 02030h, 0409h, 02039h, 040ah, 040ch, 040bh, 040fh, 0452h, 02018h, 02019h, 0201ch, 0201dh, 02022h, 02013h
	db	098h, 09fh
	dw	02014h, 02122h, 0459h, 0203ah, 045ah, 045ch, 045bh, 045fh
	db	0a1h, 0a3h
	dw	040eh, 045eh, 0408h
	db	0a5h, 0a5h
	dw	0490h
	db	0a8h, 0a8h
	dw	0401h
	db	0aah, 0aah
	dw	0404h
	db	0afh, 0afh
	dw	0407h
	db	0b2h, 0b4h
	dw	0406h, 0456h, 0491h
	db	0b8h, 0bah
	dw	0451h, 02116h, 0454h
	dw	0bch, 0ffh, 0458h, 0405h, 0455h, 0457h, 0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh

;2->wchar
Cp10007_Utf16_tbl:
	db	5h
	db	080h, 0a1h
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 02020h, 0b0h
	db	0a4h, 0a8h
	dw	0a7h, 02022h, 0b6h, 0406h, 0aeh
	db	0aah, 0b0h
	dw	02122h, 0402h, 0452h, 02260h, 0403h, 0453h, 0221eh
	db	0b2h, 0b4h
	dw	02264h, 02265h, 0456h
	db	0b6h, 0ffh
	dw	02202h, 0408h, 0404h, 0454h, 0407h, 0457h, 0409h, 0459h, 040ah, 045ah, 0458h, 0405h, 0ach, 0221ah, 0192h, 02248h, 02206h, 0abh, 0bbh, 02026h, 0a0h, 040bh, 045bh, 040ch, 045ch, 0455h, 02013h, 02014h, 0201ch, 0201dh, 02018h, 02019h, 0f7h, 0201eh, 040eh, 045eh, 040fh, 045fh, 02116h, 0401h, 0451h, 044fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 0a4h

;3->wchar
Koi8r_Utf16_tbl:
	db	1h
	db	080h, 0ffh
	dw	02500h, 02502h, 0250ch, 02510h, 02514h, 02518h, 0251ch, 02524h, 0252ch, 02534h, 0253ch, 02580h, 02584h, 02588h, 0258ch, 02590h, 02591h, 02592h, 02593h, 02320h, 025a0h, 02219h, 0221ah, 02248h, 02264h, 02265h, 0a0h, 02321h, 0b0h, 0b2h, 0b7h, 0f7h, 02550h, 02551h, 02552h, 0451h, 02553h, 02554h, 02555h, 02556h, 02557h, 02558h, 02559h, 0255ah, 0255bh, 0255ch, 0255dh, 0255eh, 0255fh, 02560h, 02561h, 0401h, 02562h, 02563h, 02564h, 02565h, 02566h, 02567h, 02568h, 02569h, 0256ah, 0256bh, 0256ch, 0a9h, 044eh, 0430h, 0431h, 0446h, 0434h, 0435h, 0444h, 0433h, 0445h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 044fh, 0440h, 0441h, 0442h, 0443h, 0436h, 0432h, 044ch, 044bh, 0437h, 0448h, 044dh, 0449h, 0447h, 044ah, 042eh, 0410h, 0411h, 0426h, 0414h, 0415h, 0424h, 0413h, 0425h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 042fh, 0420h, 0421h, 0422h, 0423h, 0416h, 0412h, 042ch, 042bh, 0417h, 0428h, 042dh, 0429h, 0427h, 042ah
	
;4->wchar
Mac_Utf16_tbl:
	db	5h
	db	080h, 0a2h
	dw	0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 02020h, 0b0h, 0490h
	db	0a4h, 0a8h
	dw	0a7h, 02022h, 0b6h, 0406h, 0aeh
	db	0aah, 0b0h
	dw	02122h, 0402h, 0452h, 02260h, 0403h, 0453h, 0221eh
	db	0b2h, 0b4h
	dw	02264h, 02265h, 0456h
	db	0b6h, 0ffh
	dw	0491h, 0408h, 0404h, 0454h, 0407h, 0457h, 0409h, 0459h, 040ah, 045ah, 0458h, 0405h, 0ach, 0221ah, 0192h, 02248h, 02206h, 0abh, 0bbh, 02026h, 0a0h, 040bh, 045bh, 040ch, 045ch, 0455h, 02013h, 02014h, 0201ch, 0201dh, 02018h, 02019h, 0f7h, 0201eh, 040eh, 045eh, 040fh, 045fh, 02116h, 0401h, 0451h, 044fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 020ach

;5->wchar
Cp8859_5_Utf16_tbl:
	db	2h
	db	0a1h, 0ach
	dw	0401h, 0402h, 0403h, 0404h, 0405h, 0406h, 0407h, 0408h, 0409h, 040ah, 040bh, 040ch
	db	0aeh, 0ffh
	dw	040eh, 040fh, 0410h, 0411h, 0412h, 0413h, 0414h, 0415h, 0416h, 0417h, 0418h, 0419h, 041ah, 041bh, 041ch, 041dh, 041eh, 041fh, 0420h, 0421h, 0422h, 0423h, 0424h, 0425h, 0426h, 0427h, 0428h, 0429h, 042ah, 042bh, 042ch, 042dh, 042eh, 042fh, 0430h, 0431h, 0432h, 0433h, 0434h, 0435h, 0436h, 0437h, 0438h, 0439h, 043ah, 043bh, 043ch, 043dh, 043eh, 043fh, 0440h, 0441h, 0442h, 0443h, 0444h, 0445h, 0446h, 0447h, 0448h, 0449h, 044ah, 044bh, 044ch, 044dh, 044eh, 044fh, 02116h, 0451h, 0452h, 0453h, 0454h, 0455h, 0456h, 0457h, 0458h, 0459h, 045ah, 045bh, 045ch, 0a7h, 045eh, 045fh


CheckRange	label	dword
	db	Range_0_9_8, Range_0_9_8r, Range_0_9_16, Range_0_9_rutf, 10, 0
	db	Range_a_f_8, Range_a_f_8r, Range_a_f_16, Range_a_f_rutf, 16, 10 
	db	Range_A_F_8, Range_A_F_8r, Range_A_F_16, Range_A_F_rutf, 16, 10 
	db	0

CheckTable	label	dword
;	CHECKSYMBOL	<FUNCTION_SYMBOL,GetPlusSign,0,0>
;	CHECKSYMBOL	<FUNCTION_SYMBOL,GetMinusSign,0,MINUS_SIGN>
;	CHECKSYMBOL	<FUNCTION_SYMBOL,GetFloationPointSign,FLOAT_VALUE,0>
	CHECKSYMBOL	<Symbol_e, EXP_VALUE, EXP_FLAG, SIGN_FLAG OR NUMBER_FLAG, 10>
	CHECKSYMBOL	<Symbol_ec, EXP_VALUE, EXP_FLAG, SIGN_FLAG OR NUMBER_FLAG, 10>
	CHECKSYMBOL	<Symbol_h, HEX_VALUE, MODE_FLAG, SEPARATOR_FLAG, 16>
	CHECKSYMBOL	<Symbol_hc,HEX_VALUE, MODE_FLAG, SEPARATOR_FLAG, 16>
	CHECKSYMBOL	<Symbol_x, HEX_VALUE, MODE_FLAG, NUMBER_FLAG OR ZERO_FLAG, 16>
	CHECKSYMBOL	<Symbol_xc, HEX_VALUE, MODE_FLAG, NUMBER_FLAG OR ZERO_FLAG, 16>
	CHECKSYMBOL	<Symbol_q, OCTAL_VALUE, MODE_FLAG, SEPARATOR_FLAG, 8>
	CHECKSYMBOL	<Symbol_qc, OCTAL_VALUE, MODE_FLAG, SEPARATOR_FLAG, 8>
	CHECKSYMBOL	<Symbol_b, BIN_VALUE, MODE_FLAG, SEPARATOR_FLAG, 2>
	CHECKSYMBOL	<Symbol_bc, BIN_VALUE, MODE_FLAG, SEPARATOR_FLAG, 2>
Floating_point_symbol:
	CHECKSYMBOL	<Symbol_es, FLOAT_VALUE, FLOAT_DOT_FLAG, NUMBER_FLAG OR SEPARATOR_FLAG OR EXP_FLAG, 10>
Positive_sign_symbol:
	CHECKSYMBOL	<Symbol_ps, POS_VALUE, SIGN_FLAG, NUMBER_FLAG OR MODE_FLAG OR FLOAT_DOT_FLAG OR ZERO_FLAG OR MODE_ZERO_FLAG, 0>
Negative_sign_symbol:
	CHECKSYMBOL	<Symbol_ms, NEG_VALUE, SIGN_FLAG, NUMBER_FLAG OR MODE_FLAG OR FLOAT_DOT_FLAG OR ZERO_FLAG OR MODE_ZERO_FLAG, 0>
	db	0

;	CHECKSYMBOL	<PARAMETER_SYMBOL,'E',FLOAT_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'E',FLOAT_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'e',FLOAT_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'H',HEX_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'h',HEX_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'X',HEX_VALUE,HEX_SIGN>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'x',HEX_VALUE,HEX_SIGN>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'Q',OCTAL_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'q',OCTAL_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'B',BIN_VALUE,0>
;	CHECKSYMBOL	<PARAMETER_SYMBOL,'b',BIN_VALUE,0>
	db	0

;Range_0_9_8	label	byte
;	db	'0', '9'
;Range_0_9_8r	label	byte
;	db	26h, 2fh
;Range_0_9_16	label	word
;	dw	'0', '9'
;Range_0_9_rutf	label	dword
;	dd	26h, 2fh
Range_0_9	SYMBOL	<>,<>
Range_a_f	SYMBOL	<>,<>
Range_ac_fc	SYMBOL	<>,<>

;Range_a_f_8	label	byte
;	db	'a', 'f'
;Range_a_f_8r	label	byte
;	db	80h, 85h
;Range_a_f_16	label	word
;	dw	'a', 'f'
;Range_a_f_rutf	label	dword
;	dd	80h, 85h

;Range_ac_fc_8	label	byte
;	db	'A', 'F'
;Range_ac_fc_8r	label	byte
;	db	0a0h, 0a5h
;Range_ac_fc_16	label	word
;	dw	'A', 'F'
;Range_ac_fc_rutf	label	dword
;	dd	0a0h, 0a5h

Symbol_e	SYMBOL	<'e', 084h, 'e', 084h>

Symbol_ec	SYMBOL	<'E', 0a4h, 'E', 0a4h>

Symbol_h	SYMBOL	<'h', 84h, 'h', 84h>

Symbol_hc	SYMBOL	<'H',0a4h,'H',0a4h>

Symbol_x	SYMBOL	<'x',84h,'x',84h>

Symbol_xc	SYMBOL	<'X',0a4h,'X',0a4h>

Symbol_q	SYMBOL	<'q',84h,'q',84h>

Symbol_qc	SYMBOL	<'Q',0a4h,'Q',0a4h>

Symbol_b	SYMBOL	<'b',81h,'b',81h>

Symbol_bc	SYMBOL	<'B',0a1h,'B',0a1h>

Symbol_ms	SYMBOL	<'-',0a1h,'-',0a1h>

Symbol_ps	SYMBOL	<'+',0a1h,'+',0a1h>

Symbol_es	SYMBOL	<',',0a1h,',',0a1h>


ToIntTable	label	dword
	dd	@FastString@$oi$xqqrv_FromInt
	dd	@FastString@$oi$xqqrv_FromFloat
	dd	@FastString@$oi$xqqrv_FromExp
	dd	@FastString@$oi$xqqrv_FromHex
	dd	@FastString@$oi$xqqrv_FromOctal
	dd	@FastString@$oi$xqqrv_FromBinary

end
