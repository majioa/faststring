#include "../strings.h"

#include <windows.h>
#ifdef __BORLANDC__
  #pragma argsused
#endif
int APIENTRY WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow )
{
  FastString a("123.3");
  int i = a;
/*  char c = a;
  short s = a;
  float f = a;
  double d = a;
  long double extendedf = a;
  void *p = a;
  char *s1 = (char *)p;*/
  return 0;
}
