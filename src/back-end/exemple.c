
void foo(int c, int z);
void foo(int c, int z)
{
	int a;
	a=42;
	if (a > 12)
	{
		int b;
		b = 12;
		a+=b;
		b+=c;
	}
	return ;
}


int main() 
{ 
	int a;
	int b;
	float c;
	a=2;
	b=5;
	c=1;
	if (a<b) 
	{
		if (a>1)
		{
			foo(a,b);
			a=3;
		}
		a+=3;	
	}
	b=10;
WHILE0:
	if (b<=0)
		goto WHILE1;
	if (b--== a)
		goto WHILE0;
WHILE1:
	b++;
	return ;
}

