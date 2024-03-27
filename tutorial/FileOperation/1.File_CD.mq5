string filename = "L1\\ttt.txt";

int OnInit()
{
   // [File Create]
   int h = FileOpen(filename, FILE_WRITE | FILE_UNICODE  | FILE_TXT);
   if (h == INVALID_HANDLE)
   {
      PrintFormat("Failed to open file. Error code=%d", GetLastError());
      return (INIT_FAILED);
   }
   PrintFormat("Create %s", filename);

   //寫n行 作範例
   for(int i=1;i<=3;i++){
      FileWrite(h,"Line-"+IntegerToString(i));
   }

   FileClose(h);
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // [File Delete]
   ResetLastError();
   if (!FileDelete(filename))
   {
      PrintFormat("Failed to delete filename %s. Error code=%d", filename, GetLastError());
      return;
   }
   PrintFormat("Delete %s", filename);
}
