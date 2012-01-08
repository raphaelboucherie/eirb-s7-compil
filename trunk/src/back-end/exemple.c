void main() 
{ 
  int a;
  int b;
  a=2;
  b=5;
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
  return ;
}
