int bar(int a, int b)
{
  int c;
	c = 0;
  c+=a;
  if ( c < b )
    return 1;
  return 0;
}

int main()
{
  int a;
	int c;
	a = bar(3,4);
	c = 0;
  return 0;
}
