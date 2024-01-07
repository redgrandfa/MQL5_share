MqlDateTime now;
int TimerSec = 1;

int timerTriggerCount = 0;
int TicksReceivedCount = 0;

int OnInit()
{
  EventSetTimer(TimerSec);

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  EventKillTimer();
}

void OnTimer()
{
  if(TimerSec == 1){
    //Print( TimerSec );

    // TimeCurrent(now);
    TimeTradeServer(now);
    if (  now.min % 15 == 14 && now.sec == 50)
    {
      EventKillTimer();
      Print("----Kill Timer 1 Sec------------");

      TimerSec = 900;
      EventSetTimer(TimerSec);
    }
    return;
  }
  
  timerTriggerCount++;
  Print( timerTriggerCount);
}

void OnTick()
{
  TicksReceivedCount++;
  Print( TicksReceivedCount);
}