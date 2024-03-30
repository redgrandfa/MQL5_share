struct CanFileWrite
{
  datetime date;
  int a;
  double b;

  int a_arr[3];

  void ShowInfo(){
    Print(this.a);
    Print(this.b);
    Print(this.date);

    int size = ArraySize(this.a_arr) ;
    for(int i = 0 ; i< size ; i++){
      Print(this.a_arr[i]);
    }
  }
};

string filename = "structWR.txt";
int h;
CanFileWrite toWrite;
CanFileWrite readTo;

int OnInit()
{
  toWrite.a = 1;
  toWrite.b = 3.3;
  toWrite.date = D'2024.03.27 12:30:01';
  toWrite.a_arr[0] = 3;
  toWrite.a_arr[1] = 5;
  toWrite.a_arr[2] = 7;

  // WRITE
  ResetLastError();
  h = FileOpen(filename, FILE_WRITE | FILE_BIN);
  if (h == INVALID_HANDLE)
  {
    PrintFormat("Failed to open file. Error code=%d", GetLastError());
    return INIT_FAILED;
  }

  int byteCount = FileWriteStruct(h, toWrite);
  PrintFormat("%d bytes is written to %s file", byteCount, filename);

  FileClose(h);
  // toWrite = NULL;
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
  // READ
  ResetLastError();
  h = FileOpen(filename, FILE_READ | FILE_BIN);
  if (h == INVALID_HANDLE)
  {
    PrintFormat("Failed to open file. Error code=%d", GetLastError());
    return;
  }

  while (!FileIsEnding(h))
  {
    FileReadStruct(h, readTo);

    readTo.ShowInfo();
  }

  FileClose(h);
}
