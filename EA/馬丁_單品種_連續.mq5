#include <Trade\Trade.mqh>

// Price： double，圖表上的價格
// Quantity： int，"份"數，不是手數

//-------EA參數------------------------------------------
ENUM_TIMEFRAMES Period = PERIOD_M15;

input int Base = 2;                     // 底數
input double PriceShift_Base = 0.00350; // 注意商品小數位，這邊是歐美對
input int TakeProfitPoint = 11;         // 用於出場條件， ACCOUNT_PROFIT > 持倉手數的p倍 ，ex.  持有0.64手 => 浮盈超過 p* 0.64美金時

//-------每一局參數-----------------------------------
bool isLong = true;                                      // t = 做多中 , f = 做空中 , (無方向??)
ENUM_SYMBOL_INFO_DOUBLE Sided_Symbol_Price = SYMBOL_BID; // SYMBOL_ASK
ENUM_ORDER_TYPE Sided_ORDER_TYPE = ORDER_TYPE_BUY;
void ToggleSide()
{
   isLong = !isLong;
   Sided_Symbol_Price = isLong ? SYMBOL_BID : SYMBOL_ASK;
   Sided_ORDER_TYPE = isLong ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
}

double Price_Start = 0.0;    // Price_Reference   // 每局 重新抓 起點價 (參照/中心/平衡...)
double Price_LastOpen = 0.0; // 無縫接軌新局用  最後一次進單價

double Lot_Multiplier = 0.01; // 手數乘數，可與當前結餘成正比。  (我回測先用 每份0.01手，3000初始本金 )

//-------每一週期參數------------------------------------------
int Quantity_Current = 0;

//-------------------------------------------------------------------
int OnInit()
{
   // 檢查持倉
   // 1. 已有持倉(延續)
   // if ( PositionsTotal() > 0 ){
   //...//持倉反推狀態延續();
   //}

   // 2. 無持倉(開新局? 抓前15分鐘狀態設定新局狀態)
   // else{
   Price_LastOpen = iOpen(_Symbol, Period, 1); // 抓前一K棒開盤價?
   // Print("Init Price_LastOpen:", Price_LastOpen);
   RestartGame();
   //}

   EventSetTimer(900);
   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

// void OnTick()
void OnTimer() // 可能無法控制精確時間
{
   //   double myAccountInfoBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   //   double myAccountInfoProfit = AccountInfoDouble(ACCOUNT_PROFIT);
   //   double myAccountInfoEquity = AccountInfoDouble(ACCOUNT_EQUITY);

   //   Comment(
   //       TimeCurrent(), "\n\r",
   //       "Balance: ", myAccountInfoBalance, "\n",
   //       "Profit: ", myAccountInfoProfit, "\n",
   //       "Equity: ", myAccountInfoEquity);

   // 出場 + 設定新局
   if (CheckForCloseAllPositions())
   {
      CloseAllPositions();
      RestartGame(); // 更新 起點價
   }

   // 抓價 算距離->算量->進單
   double Price_Current = SymbolInfoDouble(_Symbol, Sided_Symbol_Price);

   int Q_Order = GetQuantity_Ideal(Price_Current) - Quantity_Current;

   if (Q_Order > 0)
   {
      OpenPosition(Q_Order, Price_Current);
   }
}

// 成交 => 更新持倉量 ?  會不會平倉也觸發?
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   // if (trans.deal_type == DEAL_TYPE_BALANCE ) {
   //    Quantity_Current = 0;
   // }
   // else{
   //    Quantity_Current + =trans.volume ;
   // }
}

//-------------------------------------------------------------------

void RestartGame() // SetNewGame
{
   // 設定新局狀態
   // double Account_Balance = AccountInfoDouble(ACCOUNT_BALANCE);
   // Lot_Multiplier = NormalizeDouble(Account_Balance/2000 * 0.01, 2 ); // 隨著本金，手數自動變大
   // Print("Lot_Multiplier:", Lot_Multiplier);

   // 抓最後峰值價 換方向...?
   Price_Start = Price_LastOpen;
   Print("Price_Start:", Price_Start);

   ToggleSide();
}

// 檢查點差，太大放棄
// if ( SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) > 9 )
//  return;
int GetQuantity_Ideal(double Price_Current)
{
   double PriceShift = MathAbs(Price_Current - Price_Start);
   // Print("PriceShift:", PriceShift);

   double Q_Ideal = MathPow(Base, PriceShift / PriceShift_Base) - 1;
   // Print("Q_Ideal:", Q_Ideal);

   return floor(Q_Ideal);
}
void OpenPosition(int Quantity_Order, double Price_Order)
{
   // Print("Price_Order:" , Price_Order);
   // Print("Quantity_Order:" , Quantity_Order);

   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   // 固定
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.type_filling = ORDER_FILLING_FOK; // ORDER_FILLING_IOC;//
   request.deviation = 11;

   // 變動
   request.type = Sided_ORDER_TYPE;
   request.volume = Quantity_Order * Lot_Multiplier; // 手數若太大，要拆單?
   request.price = Price_Order;

   if (OrderSend(request, result)) // 應該是【有成功提交訂單】，並非有成交
   {
      // Print("Open", request.volume, "lot");
      Price_LastOpen = Price_Order; // 會有偏差，甚至 滑點 超出偏差而沒進單；考慮使用OnTradeTransaction
      // Print("Price_LastOpen", Price_LastOpen);

      Quantity_Current += Quantity_Order;
   }
   // Print("Quantity_Current:", Quantity_Current);
}

bool CheckForCloseAllPositions() // PROFIT > lots的某倍
{
   double Account_Profit = AccountInfoDouble(ACCOUNT_PROFIT);
   // return (Account_Profit > 0 );

   return (Account_Profit > TakeProfitPoint * Quantity_Current * Lot_Multiplier); //  ex.  0.64手 => 浮盈超過 p* 0.64美金時

   // 回測382條件
}

void CloseAllPositions()
{
   CTrade trade;
   int i = PositionsTotal() - 1;
   while (i >= 0)
   {
      if (trade.PositionClose(PositionGetSymbol(i)))
         i--;
   }

   // Print(TimeCurrent(), "Close All. Quantity: " , Quantity_Current , ". Lots:  ", Quantity_Current* Lot_Multiplier);

   // 更新 持倉量
   Quantity_Current = 0;
   // Print("Quantity_Current:", Quantity_Current);
}

// void 持倉反推狀態延續()
//{
// }