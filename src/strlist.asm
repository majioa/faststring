	.386
	.model flat

	include constant.inc


SetMode proc	near
	;in
	;eax: old mode
	;ecx: new value of count
	;edx: text length
	;out
	;eax: new mode
	ret
SetMode endp

CheckBufferSize proc	near
	;eax: mode of text
	;edx: buffer ptr
	;out
	;edx: new buffer ptr
	ret
CheckBufferSize endp

AnalyseText	proc	near
	;eax: buffer ptr
	;out
	;eax: new mode
	ret
AnalyseText	endp

;int Add(const AnsiString S);
;void __fastcall Append(const FastString S);
@StringList@Add$qqrx10FastString	proc	near
@StringList@Append$qqrx10FastString:
	;in:
	;eax: this
	;edx: FastString *
	;out:
	;eax: index of added string
	ret
@StringList@Add$qqrx10FastString	endp

;int __fastcall AddObject(const FastString S, System::TObject* AObject);
@StringList@AddObject$qqrx10FastStringpv	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;ecx: void * pointer to object
	;out:
	;eax: index of added string
	ret
@StringList@AddObject$qqrx10FastStringpv	endp

;void __fastcall Clear(void);
@StringList@Clear$qqrv	proc	near
	;in:
	;eax: this
	ret
@StringList@Clear$qqrv	endp

;typedef int __fastcall (CALLBACK *TStringListSortCompare)(TStringList* List, int Index1, int Index2);
;void __fastcall CustomSort (TStringListSortCompare Compare);
@StringList@CustomSort$qqrpv	proc	near
	;in:
	;eax: this
	;edx: pointer to callback function
	ret
@StringList@CustomSort$qqrpv	endp

;virtual void __fastcall Delete(int Index);
@StringList@Delete$qqri proc	near
	;in:
	;eax: this
	;edx: pointer to callback function
	ret
@StringList@Delete$qqri endp

;void __fastcall Exchange(int Index1, int Index2);
@StringList@Exchange$qqrii	proc	near
	;in:
	;eax: this
	;edx: Index1
	;ecx: Index2
	ret
@StringList@Exchange$qqrii	endp

;bool __fastcall Find(const FastString S, int &Index);
@StringList@Find$qqrx10FastStringi	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;ecx: Index *
	;out:
	;eax (al): found or not
	ret
@StringList@Find$qqrx10FastStringi	endp

;int __fastcall IndexOf(const FastString S);
@StringList@IndexOf$qqrx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;out:
	;eax: index of string
	ret
@StringList@IndexOf$qqrx10FastString	endp

;void __fastcall Insert(int Index, const FastString S);
@StringList@Insert$qqrix10FastString	proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: FastString *
	ret
@StringList@Insert$qqrix10FastString	endp

;void __fastcall InsertObject(int Index, const FastString S, System::TObject* AObject);
@StringList@InsertObject$qqrix10FastStringpv	proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: FastString *
	;[esp+4]: pointer to object
	ret
@StringList@InsertObject$qqrix10FastStringpv	endp

;void __fastcall Sort(void);
@StringList@Sort$qqrv	proc	near
	;in:
	;eax: this
	ret
@StringList@Sort$qqrv	endp

;__fastcall StringList(void);
@StringList@$bctr$qqrv	proc	near
	;in:
	;eax: this
	;out:
	;eax: this
	ret
@StringList@$bctr$qqrv	endp

;__fastcall ~StringList(void);
@StringList@$bdtr$qqrv	proc	near
	;in:
	;eax: this
	;out:
	;eax: destroyed
	ret
@StringList@$bdtr$qqrv	endp

;void __fastcall AddStrings(StringList* Strings);
@StringList@AddStrings$qqrp10StringList proc	near
	;in:
	;eax: this
	;edx:
	;out:
	;eax: index of added string
	ret
@StringList@AddStrings$qqrp10StringList endp

;void __fastcall Assign(StringList* Source);
@StringList@Assign$qqrp10StringList	proc	near
	;in:
	;eax: this
	;edx: pointer to source StringList
	ret
@StringList@Assign$qqrp10StringList	endp

;void __fastcall BeginUpdate(void);
;void __fastcall EndUpdate(void);

;bool __fastcall Equals(StringList* Strings);
@StringList@Equals$qqrp10StringList	proc	near
	;in:
	;eax: this
	;edx: pointer to other StringList
	;out:
	;eax: value of string lists comparison
	ret
@StringList@Equals$qqrp10StringList	endp

;__property FastString Text = {read=GetText, write=SetText};
;FastString __fastcall GetText(void);
@StringList@GetText$qqrv	proc	near
	;in:
	;eax: this
	;edx: pointer to FastString
	;out:
	;eax: pointer to FastString
	ret
@StringList@GetText$qqrv	endp
;void __fastcall SetText(const FastString);
@StringList@SetText$qqrx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	ret
@StringList@SetText$qqrx10FastString	endp

;int __fastcall IndexOfName(const FastString Name);
@StringList@IndexOfName$qqrx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;out:
	;eax: index of name of string
	ret
@StringList@IndexOfName$qqrx10FastString	endp

;int __fastcall IndexOfObject(System::TObject* AObject);
@StringList@IndexOfObject$qqrpv proc	near
	;in:
	;eax: this
	;edx: pointer to object
	;out:
	;eax: index of object
	ret
@StringList@IndexOfObject$qqrpv endp

;void __fastcall LoadFromFile(const FastString FileName);
@StringList@LoadFromFile$qqrx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	ret
@StringList@LoadFromFile$qqrx10FastString	endp

;virtual void __fastcall LoadFromStream(TStream* Stream);
;void __fastcall Move(int CurIndex, int NewIndex);
@StringList@Move$qqrii	proc	near
	;in:
	;eax: this
	;edx: CurIndex
	;ecx: NewIndex
	ret
@StringList@Move$qqrii	endp

;void __fastcall SaveToFile(const AnsiString FileName);
@StringList@SaveToFile$qqrx10FastString proc	near
	;in:
	;eax: this
	;edx:
	ret
@StringList@SaveToFile$qqrx10FastString endp

;void __fastcall SaveToStream(TStream* Stream);
;__property int Capacity = {read=GetCapacity, write=SetCapacity, nodefault};
;int __fastcall GetCapacity(void);
@StringList@GetCapacity$qqrv	proc	near
	;in:
	;eax: this
	;out:
	;eax: capacity
	ret
@StringList@GetCapacity$qqrv	endp
;void __fastcall SetCapacity(int);
@StringList@SetCapacity$qqri	proc	near
	;in:
	;eax: this
	;edx: capacity
	ret
@StringList@SetCapacity$qqri	endp

;__property FastString CommaText = {read=GetCommaText, write=SetCommaText};

;__property int Count = {read=GetCount, nodefault};
;int __fastcall GetCount(void)
@StringList@GetCount$qqrv	proc	near
	;in:
	;eax: this
	;out:
	;eax: count value
	ret
@StringList@GetCount$qqrv	endp

;__property FastiString DelimitedText = {read=GetDelimitedText, write=SetDelimitedText};
;__property char Delimiter = {read=GetDelimiter, write=SetDelimiter};

;__property FastString Names[int Index] = {read=GetName};
;FastString __fastcall GetName(int Index);
@StringList@GetName$qqri	proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: pointer to output FastString
	;out:
	;eax: pointer to output FastString
	ret
@StringList@GetName$qqri	endp

;__property System::TObject* Objects[int Index] = {read=GetObject, write=PutObject};
;System::TObject* __fastcall GetObject(int Index);
@StringList@GetObject$qqri	proc	near
	;in:
	;eax: this
	;edx: Index
	;out:
	;eax: pointer to object
	ret
@StringList@GetObject$qqri	endp
;void __fastcall SetObject(int Index, System::TObject*);
@StringList@SetObject$qqripv	proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: pointer to object
	;out:
	;eax:
	ret
@StringList@SetObject$qqripv	endp

;__property char QuoteChar = {read=GetQuoteChar, write=SetQuoteChar};
;__property FastString Strings[int Index] = {read=Get, write=Put};
;FastString Strings[int Index] = {read=Get, write=Put};
;FastString __fastcall GetString(int Index);
@StringList@GetString$qqri	proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: output FastString *
	;out:
	;eax: output FastString *
	ret
@StringList@GetString$qqri	endp
;void __fastcall SetString(int Index, FastString String);
@StringList@SetString$qqrx10FastStringi proc	near
	;in:
	;eax: this
	;edx: Index
	;ecx: FastString *
	ret
@StringList@SetString$qqrx10FastStringi endp

;typedef System::DelphiInterface< IStringsAdapter > _di_IStringsAdapter;
;__property _di_IStringsAdapter StringsAdapter = {read=FAdapter, write=SetStringsAdapter};
;__property int UpdateCount = {read=FUpdateCount};
;__property FastString Values[FastString Name] = {read=GetValue, write=SetValue};
;FastString __fastcall GetValue(FastString Name);
@StringList@GetValue$qqrx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;ecx: value of named FastString *
	;out:
	;eax: value of named FastString *
	ret
@StringList@GetValue$qqrx10FastString	endp
;void __fastcall SetValue(FastString Name, FastString Value);
@StringList@SetValue$qqrx10FastStringx10FastString	proc	near
	;in:
	;eax: this
	;edx: FastString *
	;ecx: value of named FastString *
	ret
@StringList@SetValue$qqrx10FastStringx10FastString	endp

end











