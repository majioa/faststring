;Fast String standalone methods

	.386
	.model flat


_TEXT	segment dword public use32 'CODE'

WinMain segment virtual
@WinMain:
	ret
WinMain ends

_TEXT	ends


_DATA	segment dword public use32 'DATA'
_DATA	ends


_BSS	segment dword public use32 'BSS'
_BSS	ends


DGROUP	group	_BSS,_DATA

end
