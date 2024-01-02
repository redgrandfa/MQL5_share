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

  MqlTradeRequest request = {};
  MqlTradeResult result = {};

  if (!PositionSelect(_Symbol))
  {

    request.action = TRADE_ACTION_DEAL;
    request.type = ORDER_TYPE_BUY;
    request.symbol = _Symbol;
    request.volume = lotSize;
    request.type_filling = ORDER_FILLING_FOK;
    request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    request.tp = 0;
    request.deviation = 11;

    OrderSend(request, result);
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

