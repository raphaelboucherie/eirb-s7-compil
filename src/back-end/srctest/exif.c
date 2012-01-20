int main()
{
  int a;
	int b;
  a= 42;
  b= 35;
	if (a < b)
		a = b;
	if (a == b)
		b *= 2;
		b += a;
	if (a > b)
		a = b;
  return 1;
}
