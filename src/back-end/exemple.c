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
		if (a>3)
		{
			a=3;
		}
		a+=3;	
	}
	b=10;
WHILE0:
	if (b<=0)
		goto WHILE1;
	b--;
	goto WHILE0;
WHILE1:
	b++;
	return ;
}
