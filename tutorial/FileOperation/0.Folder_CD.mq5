// 有[共同路徑] 和一般路徑 兩種選項

// input
bool common_flag = false;
int flag = common_flag ? FILE_COMMON : 0;
string working_folder;

string folder_path = "L1";

int OnInit()
{
   if (common_flag)
      working_folder = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\MQL5\\Files";
   else
      working_folder = TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files";

   // Folder Create
   ResetLastError();
   if (!FolderCreate(folder_path, flag))
   {
      PrintFormat("Failed to create folder %s. Error code=%d", folder_path, GetLastError());
      return (INIT_FAILED);
   }
   PrintFormat("Created folder %s", working_folder + "\\" + folder_path);

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   // Folder Delete
   if (!FolderDelete(folder_path, flag))
   {
      PrintFormat("Failed to delete folder %s. Error code=%d", folder_path, GetLastError());
      return;
   }
   PrintFormat("Delete folder %s", working_folder + "\\" + folder_path);
}
