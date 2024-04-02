#define MICRO 0.01

// #include "../include/CSarHelper.mq5"
// #include "../include/Lib_Trade.mq5"
// #include "../include/CGameMasterBase.mq5";
#include "CSarHelper.mq5"
#include "Lib_Trade.mq5"
#include "CGameMasterBase.mq5";

CGameMasterBase *gm = NULL;

extern int MicroLot_Holding_MAX;
extern datetime MicroLot_Holding_MAX_Time;




MqlDateTime now;
int NewGameCount = 0;

//-------(一)事件函數--------------------------------------------
int OnInit()
{
  OnTimerCall = OnTimer_Game1Before;
  OnTickCall = OnTick_Game1Before;

  CSarHelper::Preset();

  EventSetTimer(1);
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
  EventKillTimer();
  delete gm;
  gm = NULL;

  Print("最大曾經 持倉手數MicroLot_Holding_MAX: ", MicroLot_Holding_MAX);
  Print("發生時間MicroLot_Holding_MAX_Time: ", MicroLot_Holding_MAX_Time);
}
double OnTester(void)
{
  return TesterStatistics(STAT_PROFIT) / TesterStatistics(STAT_EQUITY_DD);
  // return TesterStatistics(STAT_EQUITY_DD);
}

void OnTimer() { OnTimerCall(); }
void OnTick() { OnTickCall(); }

//-------(二)事件函數 分支--------------------------------------------
// 自訂 function pointer型別， 指向  void xxx(){} 方法
typedef void (*T_Action)();
T_Action OnTimerCall;

void OnTimer_Game1Before()
{
  InitGame(DecideSide(), 0);

  OnTimerCall = OnTimer_Game1Setted;
  OnTickCall = OnTick_Game1Setted;

  TimeTradeServer(now);
  int TimerSec = 900 - (now.min * 60 + now.sec + 10) % 900;

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
  if (gm == NULL)
    return;

  gm.EnsurePositonEnough();
}

T_Action OnTickCall;
void OnTick_Game1Before() {}
void OnTick_Game1Setted()
{
  if (gm == NULL)
    return;

  if (!gm.isGameSatisfied())
    return;

  Print("===========結束局======");
  NextGame();
}




// ==================
bool DecideSide()
{
  // 先無視點差，不特定用BID / ASK -> 比較SAR -> 決定 isLong
  double sar = CSarHelper::GetSAR();
  double Price_Current = GetPrice_Current(SYMBOL_BID);

  bool isLong = Price_Current > sar;

  return isLong;
}


void NextGame(){
  bool oldIsLong = gm.isLong;
  delete gm;
  gm = NULL;

  bool newIsLong = DecideSide();

  if (oldIsLong == newIsLong)
  {
    Print("!!!!!次局方向沒變，首單[假平倉]省點差，需額外調整 Price_LastOpen");
    CloseAllExceptFirstN(1);

    InitGame(newIsLong, firstOrder_microLot);
    Price_LastOpen = gm.price_Ref;
  }
  else
  {
    Print("次局反向，全出場");
    CloseAllPositions();
    InitGame(newIsLong, 0);
  }
}


void InitGame(bool isLong, int microLot)
{
	if (isLong)
	{
		Print("===========新局#", ++NewGameCount, "：多方");
		gm = new GM_Long(microLot);
	}
	else
	{
		Print("===========新局#", ++NewGameCount, "：空方");
		gm = new GM_Short(microLot);
	}
  gm.EnsurePositonEnough();
}

// void ContinueGame(bool isLong , int microLot , double priceRef){
//    if(isLong){
//       Print("===========續斷局#", ++NewGameCount, "：多方" );
//       gm = new GM_Long(microLot, );
//    }else{
//       Print("===========續斷局#", ++NewGameCount, "：空方" );
//       gm = new GM_Short(microLot,);
//    }
// }
