;Fast String code page support functions

	.386
	.model flat


_TEXT	segment dword public use32 'CODE'

WinMain1 segment virtual
@WinMain1:
	ret
WinMain1 ends

_TEXT	ends


_DATA	segment dword public use32 'DATA'
_DATA	ends


_BSS	segment dword public use32 'BSS'
_BSS	ends


DGROUP	group	_BSS,_DATA

end
