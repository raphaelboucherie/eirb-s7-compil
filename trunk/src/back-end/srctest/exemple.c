int bar(int a, int b)
{
	int c;
	c+=a;
	if ( c < b )
		return 1;
	return 0;
}

void foo()
{
	int b;
	b = 21;
	return ;
}

int main()
{
	int a;
	a= 42;
	foo();
	a= 35;
	return 1;
}
