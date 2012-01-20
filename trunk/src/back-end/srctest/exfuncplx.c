void foo() {
	int a;
	a = 4;
	return ;
}

int bar(int a, int b)
{
  int c;
	c = 0;
  c+=a;
	foo();
  if ( c < b )
    return 1;
  return 0;
}


int main()
{
  int a;
	int b;
	int c;
  a= 42;
  b= 35;
	c = bar(a,b);
  return 1;
}
