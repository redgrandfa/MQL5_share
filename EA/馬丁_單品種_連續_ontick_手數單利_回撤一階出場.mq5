#include <Trade\Trade.mqh>
// Game: 局
// Price： double，價位
// Lot： int，手數

// 每15分鐘判斷是否要進單
// 任何tick判斷是否要出單

//-------EA參數------------------------------------------
// 假設 EURUSD ，M15 ，0.01手

ENUM_TIMEFRAMES Period_SAR = PERIOD_H1;
// ENUM_TIMEFRAMES Period_Strategy = PERIOD_M15;

int SAR = 0;
MqlParam params[]; // 存储指标参数的数组

MqlDateTime now;

double Base = 2.0;            // 底數
double Price_Delta = 0.00350; // 注意商品小數位

//-------每一局參數-----------------------------------
bool isLong = NULL; // t = 做多中 , f = 做空中 , (無方向??)
string isLongStringify() { return isLong ? "多" : "空"; }

ENUM_SYMBOL_INFO_DOUBLE Sided_Symbol_Price;
ENUM_ORDER_TYPE Sided_ORDER_TYPE;
void AfterSided()
{
   Sided_Symbol_Price = isLong ? SYMBOL_ASK : SYMBOL_BID;
   Sided_ORDER_TYPE = isLong ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
}

double Price_Ref = NULL; // 每局 基準價
input int FirstOrderMicroLot = 2;

//-------每一單參數------------------------------------------
double Price_LastOpen = NULL; // 最後一次進單價
double nDelta = NULL;         // 最後一次'進單價'距離'基準價' 幾倍Delta

double Micro = 0.01; // 微手 轉 標準手 // 標準手(Lots)。迷你手(Mini Lot) 微型手(Micro Lot) 毫微手(Nano Lot)
int MicroLot_Current = 0;
int MicroLot_Current_MAX = 0; // 可記錄MicroLot_Current的最大出現過的值，了解多嘎。 給人類判斷優化參數用
datetime MicroLot_Current_MAX_Time;

// ===優化用的資訊
int NewGameCount = 0;

//-------(一)事件函數--------------------------------------------
int OnInit()
{
   // 檢查持倉
   // 1. 已有持倉(延續)
   // if ( PositionsTotal() > 0 ){ 持倉反推狀態延續(); }
   // 2. 無持倉(開新局)
   // else{

   OnTimerCall = OnTimer_Game1Before;
   OnTickCall = OnTick_Game1Before;

   //--- 創建sar指標 IndicatorCreate()
   // 设置params的大小和被调用指标参数数量一致
   ArrayResize(params, 2); // sar指標需輸入2個參數
                           // 步长
   params[0].type = TYPE_DOUBLE;
   params[0].double_value = 0.02;
   // 最大值
   params[1].type = TYPE_DOUBLE;
   params[1].double_value = 0.2;

   //(商品,週期,指標(ENUM_INDICATOR),params參數數量,params數組 )
   SAR = IndicatorCreate(_Symbol, Period_SAR, IND_SAR, 2, params);

   EventSetTimer(1);
   return (INIT_SUCCEEDED);
   //}
}
void OnDeinit(const int reason)
{
   Print("最大曾經 持倉手數MicroLot_Current_MAX: ", MicroLot_Current_MAX);
   Print("發生時間MicroLot_Current_MAX_Time: ", MicroLot_Current_MAX_Time);
   EventKillTimer();
}

// 因SAR無法在OnInit取值，且OnTick理論上有可能不發生 => 在OnTimer開 EA首局
void OnTimer() { OnTimerCall(); }
void OnTick() { OnTickCall(); }

//-------(一)事件函數 分支--------------------------------------------
// 自訂 function pointer型別， 指向  void xxx(){} 方法
typedef void (*T_Action)();
T_Action OnTimerCall;

void OnTimer_Game1Before()
{
   SetNewGameSide();
   OpenPosition_ThenRecord(FirstOrderMicroLot, Price_Ref);

   OnTimerCall = OnTimer_Game1Setted;
   OnTickCall = OnTick_Game1Setted;

   // TimeCurrent() 【only gets updated when a new Tick arrives】.
   // TimeTraderServer() "simulates" the server's time using the PC clock,  even when the tick does not come
   // (datetime)SymbolInfoInteger(_Symbol,SYMBOL_TIME)
   TimeTradeServer(now);
   int TimerSec = 900 - (now.min * 60 + now.sec + 10) % 900;

   EventKillTimer();
   EventSetTimer(TimerSec / 2);
   Print("設定定時器", TimerSec, "秒，以抓到14:50");
}
void OnTimer_Game1Setted()
{
   EventKillTimer();
   EventSetTimer(900);
   Print("設定定時器", 15, "分鐘。第一次觸發有兩倍時間bug");

   OnTimerCall = OnTimer_OverWeight;
   OnTimer_OverWeight(); // 先執行一次
}
// 【週期性 判斷是否加碼進場】
void OnTimer_OverWeight()
{
   // 檢查點差，太大放棄
   // if ( SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > 9 ) return;

   // 抓價 算距離->算量->進單
   double Price_Current = GetPrice_Current();
   // 缺幾手
   int MicroLot_Lack = GetMicroLot_Ideal(Price_Current) - MicroLot_Current;
   if (MicroLot_Lack > 0)
   {
      Print("----------加碼 ", isLongStringify(), MicroLot_Lack, " 微手-----");
      OpenPosition_ThenRecord(MicroLot_Lack, Price_Current);
   }
}

T_Action OnTickCall;
void OnTick_Game1Before()
{}
void OnTick_Game1Setted()
{
   if (CheckForCloseGame())
   {
      Print("===========結束局======");
      // 【檢查新局方向】
      bool OldSideIsLong = isLong;
      SetNewGameSide();

      if (OldSideIsLong == isLong)
      {
         Print("!!!!!次局方向沒變，首單[假平倉]省點差，需額外調整 Price_LastOpen");

         CloseAllExceptFirstN(1);
         nDelta = NULL;

         Price_LastOpen = Price_Ref;
         MicroLot_Current = FirstOrderMicroLot;
      }
      else
      {
         Print("全出場，反向");

         CloseAllPositions_ThenRecord();
         OpenPosition_ThenRecord(FirstOrderMicroLot, Price_Ref);
      }
   }
}

//-------(二)策略函數------------------------------------------------------------
// 先無視點差，不特定用BID / ASK -> 比較SAR -> 決定 isLong
void SetNewGameSide() // double Price_Current_IgnoreSpread
{
   double sar = GetSAR();
   // Print("sar: ", sar);
   double Price_Current = GetPrice_Current();
   // Print("與sar比，現價:", Price_Current);

   isLong = Price_Current > sar;
   Print("===========新局#", ++NewGameCount, "方向：", isLongStringify());
   AfterSided();

   Price_Ref = GetPrice_Current();
   Print("基準價Price_Ref:", Price_Ref);
}

// 【sar無法在init取得】
double GetSAR()
{
   //--- 獲取指標數據 CopyBuffer()
   double _sar[]; // 儲存數據的數組

   ArraySetAsSeries(_sar, true);
   // 設置索引方法：将数组设置成和时间序列一样，例如数组索引为0的元素
   // 存储最近一个柱形的值，索引为1的元素存储第二近柱形的值，等等。

   // 使用指标句柄将指标的缓存值，复制到数组中，这些数组正是用于这个目的
   if (CopyBuffer(SAR, 0, 0, 20, _sar) < 0)
   {
      Print("CopyBufferSAR error =", GetLastError());
   }
   // CopyBuffer( 要獲取的數據,同OnInit(),
   //             指標緩衝區編號，sar僅有一個所以為0。
   //             初始K棒
   //             要複製的K棒數量
   //             儲存目的地數組

   return _sar[0]; // 最近一個K棒的sar值
}

double Calc_nDelta(double Price)
{
   // 價差
   double Price_Shift = Price - Price_Ref;

   // 忍受價差 : 以錯誤方向為正
   double Price_Shift_Endure = Price_Shift;

   // 往錯的方向位移多少價位。
   if (isLong)
      Price_Shift_Endure = -Price_Shift;

   return Price_Shift_Endure / Price_Delta;
}
// 根據 限價<->基準價 間的價差，取理想持倉手數
int GetMicroLot_Ideal(double Price)
{
   nDelta = Calc_nDelta(Price);
   //    0   1   2   3
   //   +x, +2, +4, +8... = x + 2^(n+1) -2
   int temp = floor(MathPow(Base, nDelta + 1));
   int MicroLot_Ideal = temp - 2 + FirstOrderMicroLot;

   if (MicroLot_Ideal > MicroLot_Current)
   {
      // Print("扛價差:", Price_Shift_Endure);
      Print("幾倍基準距離 nDelta: ", nDelta);
      Print("理想 ", MicroLot_Ideal, " 微手，大於現在持倉 ", MicroLot_Current, "微手");
   }

   return MicroLot_Ideal;
}

void OpenPosition_ThenRecord(int MicroLot_Order, double Price_Order)
{
   double Lot_Order = MicroLot_Order * Micro;
   if (OpenPosition(Lot_Order, Price_Order))
   {
      Price_LastOpen = Price_Order; // 會有偏差
      Print("最後進場價Price_LastOpen: ", Price_LastOpen);

      MicroLot_Current += MicroLot_Order;
      Print("持倉 MicroLot_Current:", MicroLot_Current, "微手");
      if (MicroLot_Current > MicroLot_Current_MAX)
      {
         MicroLot_Current_MAX = MicroLot_Current;
         MicroLot_Current_MAX_Time = TimeTradeServer();
      }
   }
}

// 檢查全出場條件 (要確定是 【onTick】 還是 【週期性】 )
bool CheckForCloseGame()
{
   double p = GetPrice_Current();
   bool result = ( p - Price_LastOpen) * (isLong ? 1 : -1 ) >  Price_Delta ; 

   // if (result)
   // {
   //    Print("isLong: ", isLongStringify());
   //    Print("p: ", p);
   //    Print("Price_LastOpen: ", Price_LastOpen);
   //    Print("Price_Delta: ", Price_Delta);
   // }

   return result;
}

void CloseAllPositions_ThenRecord()
{
   CloseAllPositions();
   Price_LastOpen = NULL;
   nDelta = NULL;
   MicroLot_Current = 0;
}
// void 持倉反推狀態延續(){}

// =====(三)Library (不受策略邏輯影響)================================================
double GetPrice_Current() { return SymbolInfoDouble(_Symbol, Sided_Symbol_Price); } // 需要有宣告Sided_Symbol_Price
// Library：市價單開倉( 微手數, 價)
bool OpenPosition(double Lot_Order, double Price_Order)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   // 固定
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.type_filling = ORDER_FILLING_FOK; // ORDER_FILLING_IOC;
   request.deviation = 1111;

   // 變動
   request.type = Sided_ORDER_TYPE;
   // 手數若太大，要拆單?
   request.volume = Lot_Order;
   request.price = Price_Order;

   return OrderSend(request, result); // 應該是【有成功提交訂單】，並非有成交
   // OrderSendAsync
}

// Library：執行全出場
void CloseAllPositions()
{
   Print("關所有部位");
   CTrade trade;
   int i = PositionsTotal() - 1;
   while (i >= 0)
   {
      if (trade.PositionClose(PositionGetSymbol(i)))
         i--;
   }
}
// Library：從最晚的單開始逐一平倉，保留前N部位
void CloseAllExceptFirstN(int n)
{
   CTrade trade;
   int i = PositionsTotal() - 1;
   while (i >= n)
   {
      // 【索引 > 票】
      ulong ticket = PositionGetTicket(i);
      if (trade.PositionClose(ticket))
         i--;
   }
}

// 可以用magic number篩選屬於此EA的部位
// Library：出場所有屬於此EA的部位
// void CloseAllPositions_ByMagicNumber(){}