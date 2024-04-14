#include <Trade/Trade.mqh>
CTrade trade;

double GetPrice_Current( ENUM_SYMBOL_INFO_DOUBLE priceTypeEnum) 
{ return SymbolInfoDouble(_Symbol, priceTypeEnum); } 
// 	return NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);


bool OpenPosition(ENUM_ORDER_TYPE orderType, double Lot_Order, double Price_Order)
{
   MqlTradeRequest request = {};
   MqlTradeResult result = {};

   // 固定寫死
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.type_filling = ORDER_FILLING_FOK; // ORDER_FILLING_IOC;
   request.deviation = 1111;

   // 變動
   request.type = orderType;
   request.volume = Lot_Order; // 手數若太大，要拆單?
   request.price = Price_Order; //不能市價???

   return OrderSend(request, result); // 應該是【有成功提交訂單】，並非有成交
}


// 市價買
// void OpenBuy(double Lot_Order){
//    trade.Buy(
//       Lot_Order , 
//       NULL, //品種
//       NULL, //null = 市價
//       NULL, //止損
//       NULL, //止盈
//       NULL //註解
//    );
// }

// 市價賣
// void OpenSell(double Lot_Order){
// 	trade.Sell(
//      	Lot_Order , 
//      	NULL, //品種
//       NULL, //null = 市價
//       NULL, //止損
//       NULL, //止盈
// 	  	NULL //註解
//   	);            
// }


//      PositionGetInteger(POSITION_TYPE);
//      POSITION_TYPE_BUY
//      POSITION_TYPE_SELL


// 從最晚的單開始逐一平倉，保留前N部位
void CloseAllExceptFirstN(int n)
{
   Print("關所有部位，保留前"+n+"部位");

   int i = PositionsTotal() - 1;
   while (i >= n)
   {
      // 【索引 > 票】
      ulong ticket = PositionGetTicket(i);
      //automatically selects the position for 
      //further working with it  using functions PositionGetDouble, PositionGetInteger, PositionGetString.

      if (trade.PositionClose(ticket))
         i--;
   }
}
