#define MICRO 0.01
input ushort timer_offset=10;

input uint delay_Seconds = 0;
input uint delay_Minutes = 0;
input uint delay_Hours = 0;
input uint delay_Days = 0;
input uint delay_Weeks = 0;

uint total_delay_Seconds = delay_Seconds
  +delay_Minutes*60
  +delay_Hours*3600
  +delay_Days*86400
  +delay_Weeks*86400*7;


#include "CSarHelper.mq5"
#include "Lib_Trade.mq5"
#include "CGameMasterBase.mq5";

CGameMasterBase *gm = NULL;


datetime dt;
MqlDateTime now;
int NewGameCount = 0;
int StopLossGameCount = 0;

//-------(一)事件函數--------------------------------------------
int OnInit()
{
  OnTimerCall = OnTimer_Game1Before;
  OnTickCall = OnTick_Game1Before;

  CSarHelper::Preset();

  Print("total_delay_Seconds : ", total_delay_Seconds );
  if( EventSetTimer(1 + total_delay_Seconds ) )
    return (INIT_SUCCEEDED);
  else
    return (INIT_PARAMETERS_INCORRECT);
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
  datetime dt_end = TimeTradeServer(now);

  Print("StopLossGame次數 : ", StopLossGameCount );
  // return -StopLossGameCount; 

  return TesterStatistics(STAT_PROFIT)/TesterStatistics(STAT_EQUITY_DD)*3600*24*365/
    ( uint(dt_end - dt) - total_delay_Seconds );
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

  dt = TimeTradeServer(now);
  int TimerSec = loopPeriodSec - (now.min * 60 + now.sec + timer_offset) % loopPeriodSec;

  
  EventKillTimer();
  Print("設定定時器", TimerSec, "秒，以抓到"+TimerSec/60+"分"+TimerSec%60+"秒。有兩倍時間bug");
  if(MQLInfoInteger(MQL_TESTER)){
    EventSetTimer(TimerSec);
    // V  debug on history
    // V  profiling on history
    // v  optimization
  }else{
    // X  profiling on real、real
    EventSetTimer(TimerSec/2);
  }
}
void OnTimer_Game1Setted()
{
  OnTimer_EnsurePositonEnough(); // 先執行一次

  EventKillTimer();
  EventSetTimer(loopPeriodSec);
  Print("設定定時器", loopPeriodSec/60, "分鐘。");

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

  if (gm.isGameTakeProfit()){
    Print("=========停利======");
    NextGame();
  }

  if (enableStopLoss && gm.isGameStopLoss()){
    Print("=========停損======");
    StopLossGameCount++;
    NextGame();
  }
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
    Print("!!!!!次局方向沒變，首單[假平倉]省點差，假調整 Price_LastOpen");
    CloseAllExceptFirstN(1);

    InitGame(newIsLong, firstOrder_microLot);
    Price_LastOpen = gm.price_Ref;
  }
  else
  {
    Print("次局反向，全出場");
    CloseAllExceptFirstN(0);
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
