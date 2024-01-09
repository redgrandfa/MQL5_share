typedef int (*TFunc)(int, int);
TFunc func_ptr;

int sub(int x, int y) { return (x - y); }
int add(int x, int y) { return (x + y); }

int OnInit()
{
  func_ptr = sub;
  Print(func_ptr(10, 5));

  func_ptr = add;
  Print(func_ptr(10, 5));

  // func_ptr = (int x, int y) => { return (x /y);};
  // Print(func_ptr(10, 5));

  return (INIT_SUCCEEDED);
}