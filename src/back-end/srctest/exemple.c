void foo();

int bar(int a, int b)
{
	int c;
	c+=a;
	c+=b;
	return c;
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
	foo();
	a = bar(4,5);
	a= 35;
	return 1;
}
