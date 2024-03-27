string filename = "L1\\ru.txt";
int h;
// [File Exist]
//  if (!FileIsExist(filename))
//  {
//     PrintFormat("%s file not exists!", filename);
//  }

int OnStart()
{
  h = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_UNICODE | FILE_TXT);
  if (h == INVALID_HANDLE)
  {
    PrintFormat("Failed to open file. Error code=%d", GetLastError());
    return 0;
  }

  // [File Read a line as string]
  int lineCount = 0;
  while (!FileIsEnding(h))
  {
    // Reading  a single file line.   from a text file (opened with the FILE_TXT flag)
    string str = FileReadString(h);
    Print(str);

    lineCount++;
  }

  // [File Append]
  // relocate the pointer to the end of the file before writing:
  FileSeek(h, 0, SEEK_END);
  FileWrite(h, "line"+ lineCount);
  FileClose(h);

  return 0;
}
