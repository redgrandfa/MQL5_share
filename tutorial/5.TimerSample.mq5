int Count = 0;


int OnInit()
  {
   EventSetTimer(60);
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

void OnTimer()
  {
   Count++;
   string msg = Count + ": " + TimeCurrent() + "\n\r" ;

   Comment(msg);
   Print(msg);
  }
