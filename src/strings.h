#if !defined(STRINGS_H)
#define STRINGS_H


#define cp866	    0
#define cp1251	    1
#define cp10007     2
#define cpkoi8r     3
#define cpmac	    4
#define cp8859_5    5
#define utf15	    0x8000
#define ruft	    0xc000

typedef unsigned long dword;

class __declspec(dllexport) FastString
{
public:
  // Default Ctr
  __fastcall FastString();

  // Copy Ctr
  __fastcall FastString(const FastString& src);

  // Ctr - From basic C++ types
  __fastcall FastString(const bool src);

  __fastcall FastString(const char src);
  __fastcall FastString(const signed char src);
  __fastcall FastString(const unsigned char src);

  __fastcall FastString(const short src);
  __fastcall FastString(const unsigned short src);

  __fastcall FastString(const int src);
  __fastcall FastString(const long src);
  __fastcall FastString(const unsigned int src);
  __fastcall FastString(const unsigned long src);

  __fastcall FastString(const __int64 src);
  __fastcall FastString(const unsigned __int64 src);

  __fastcall FastString(const float src);
  __fastcall FastString(const double src);
  __fastcall FastString(const long double src);

  // Asciiz pointer
  __fastcall FastString(const char* src);
  __fastcall FastString(wchar_t* src);
//  __fastcall FastString(const AnsiString &src);
//  __fastcall FastString(const WideString &src);

  __fastcall FastString(const void* src);

  __fastcall ~FastString();


  // Assignments
  FastString& __fastcall operator =(const FastString& rhs);

  FastString& __fastcall operator =(const bool src);

  FastString& __fastcall operator =(const char src);
  FastString& __fastcall operator =(const signed char src);
  FastString& __fastcall operator =(const unsigned char src);

  FastString& __fastcall operator =(const short src);
  FastString& __fastcall operator =(const unsigned short src);

  FastString& __fastcall operator =(const int src);
  FastString& __fastcall operator =(const long src);
  FastString& __fastcall operator =(const unsigned int src);
  FastString& __fastcall operator =(const unsigned long src);

  FastString& __fastcall operator =(const __int64 src);
  FastString& __fastcall operator =(const unsigned __int64 src);

  FastString& __fastcall operator =(const float src);
  FastString& __fastcall operator =(const double src);
  FastString& __fastcall operator =(const long double src);

  FastString& __fastcall operator =(const char* src);	       // Treated as pointer Asciiz string
  FastString& __fastcall operator =(wchar_t* src);

//  FastString& __fastcall operator =(const AnsiString &src);
//  FastString& __fastcall operator =(const WideString &src);

  FastString& __fastcall operator =(void* src);

    // Conversion operators
  __fastcall operator bool()		 const;

  __fastcall operator char()		 const;
  __fastcall operator signed char()	 const;
  __fastcall operator unsigned char()	 const;

  __fastcall operator short()		 const;
  __fastcall operator unsigned short()	 const;

  __fastcall operator int()		 const;
  __fastcall operator long()		 const;
  __fastcall operator unsigned int()	 const;
  __fastcall operator unsigned long()	 const;

  __fastcall operator __int64() 	 const;
  __fastcall operator unsigned __int64() const;

  __fastcall operator float()		 const;
  __fastcall operator double()		 const;
  __fastcall operator long double()	 const;

  __fastcall operator char*();
  __fastcall operator wchar_t*();
  __fastcall operator void*()const;

//  __fastcall operator AnsiString();
//  __fastcall operator WideString();

  __fastcall SetCodePage(dword codepage);
  __fastcall ConvertTo(dword codepage);

};


//#pragma option pop

extern "C" int __stdcall GetMemInfoFuncs();


#endif

