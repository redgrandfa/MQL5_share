/*
下單/開倉
平倉所有部位

跑回測後，後台測試tab->右鍵->打開的圖表-> HTML -> 找個地方存報告檔
*/
#include <Trade\Trade.mqh>

void OnTick()
{
  double myAccountInfoBalance = AccountInfoDouble(ACCOUNT_BALANCE);
  double myAccountInfoProfit = AccountInfoDouble(ACCOUNT_PROFIT);
  double myAccountInfoEquity = AccountInfoDouble(ACCOUNT_EQUITY);

  Comment(
      "myAccountInfo Balance: ", myAccountInfoBalance, "\n",
      "myAccountInfo Profit: ", myAccountInfoProfit, "\n",
      "myAccountInfo Equity: ", myAccountInfoEquity);

  if (!PositionSelect(_Symbol))
  {
    MqlTradeRequest request = {};
    MqlTradeResult result = {};

    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_BUY;
    request.symbol = _Symbol;
    request.volume = 0.01;
    request.type_filling = ORDER_FILLING_FOK;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.deviation = 111;

    OrderSend(request, result);
    
     
    MqlTradeRequest request2 = {};
    MqlTradeResult result2 = {};    
    
    request2.action = TRADE_ACTION_DEAL;
    request2.type = ORDER_TYPE_BUY;
    request2.symbol = _Symbol;
    request2.volume = 0.02;
    request2.type_filling = ORDER_FILLING_FOK;
    request2.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request2.deviation = 111;
    
    OrderSend(request2, result2);
  }

  if (myAccountInfoEquity - myAccountInfoBalance > 2)
  {
    CloseAllOrders();
  }
}

void CloseAllOrders()
{
  CTrade trade;
  int i = PositionsTotal() - 1;
  while (i >= 0)
  {
    if (trade.PositionClose(PositionGetSymbol(i)))
      i--;
  }
}

