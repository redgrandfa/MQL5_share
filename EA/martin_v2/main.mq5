// Game: 局
// EURUSD
// 每15分鐘判斷是否要進單
// 任何tick判斷是否要出單

#include <Trade\Trade.mqh>

//-------EA參數------------------------------------------
// _Symbol
// _Point
// _Digits
// _Period

MqlDateTime now;
int NewGameCount = 0;

#include "Lib_MartinGM.mq5";
MartinGM_Base *martinGM = NULL;



//-------(一)事件函數--------------------------------------------
int OnInit()
{
   Print(__FUNCSIG__);

   OnTimerCall = OnTimer_Game1Before;
   OnTickCall = OnTick_Game1Before;

   SarHelper::Preset();

   EventSetTimer(1);
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   EventKillTimer();
   delete martinGM;
   martinGM = NULL;

   Print("最大曾經 持倉手數MicroLot_Holding_MAX: ", MicroLot_Holding_MAX);
   Print("發生時間MicroLot_Holding_MAX_Time: ", MicroLot_Holding_MAX_Time);
}
double OnTester(void){
   //跑回測時，模擬使用者行為
   // TesterWithdrawal()
   // TesterDeposit()
   // TesterStop(); //關EA 

   // 理想： maximal equity dd發生時， profit / maximal equity dd ?

   return TesterStatistics(STAT_PROFIT) / TesterStatistics(STAT_EQUITY_DD);
}


// 因SAR無法在OnInit取值，且OnTick理論上有可能不發生 => 在OnTimer開 EA首局
void OnTimer() { OnTimerCall(); }
void OnTick() { OnTickCall(); }

//-------(二)事件函數 分支--------------------------------------------
// 自訂 function pointer型別， 指向  void xxx(){} 方法
typedef void (*T_Action)();
T_Action OnTimerCall;

void OnTimer_Game1Before()
{
   SetNewGame( DecideSide() , 0 );

   OnTimerCall = OnTimer_Game1Setted;
   OnTickCall = OnTick_Game1Setted;

   TimeTradeServer(now);
   int TimerSec = 900 - (now.min * 60 + now.sec + 2) % 900;

   EventKillTimer();

#ifdef _DEBUG
   Print("_DEBUG");
   EventSetTimer(TimerSec);
#else
   Print("not _DEBUG");
   EventSetTimer(TimerSec / 2);
#endif

   Print("設定定時器", TimerSec, "秒，以抓到14:50");
}
void OnTimer_Game1Setted()
{
   OnTimer_EnsurePositonEnough(); // 先執行一次

   EventKillTimer();
   EventSetTimer(900);
   Print("設定定時器", 15, "分鐘。第一次觸發有兩倍時間bug");

   OnTimerCall = OnTimer_EnsurePositonEnough;
}

void OnTimer_EnsurePositonEnough()
{
   if(martinGM == NULL) return;

   martinGM.EnsurePositonEnough();
}

T_Action OnTickCall;
void OnTick_Game1Before(){}
void OnTick_Game1Setted()
{
   if(martinGM == NULL) return;

   if( !martinGM.isGameSatisfied()) return;

   Print("===========結束局======");

   bool oldIsLong = martinGM.isLong;
   delete martinGM;
   martinGM = NULL;

   bool newIsLong = DecideSide();

   if (oldIsLong == newIsLong)
   {
      Print("!!!!!次局方向沒變，首單[假平倉]省點差，需額外調整 Price_LastOpen");
      CloseAllExceptFirstN(1);
      SetNewGame( newIsLong , 2 + FirstOrderUnitAdjust );
      Price_LastOpen = martinGM.price_Ref;
   }
   else
   {
      Print("次局反向，全出場");
      CloseAllPositions();
      SetNewGame( newIsLong , 0 );
   }
}



