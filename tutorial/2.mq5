// https://www.youtube.com/watch?v=duvNkw_Uyic&list=PLV8YK-9p3TcM1gb106qDgzvwPExB5Fxra&index=13&ab_channel=MQL5Tutorial

#include <Trade\Trade.mqh>


//執行前決定 輸入參數
//可以回測到一半時，暫停改參數。
input double lotSize = 0.01;

CTrade trade;

void OnTick()
  {
   double Ask = NormalizeDouble( SymbolInfoDouble(_Symbol, SYMBOL_ASK)  ,_Digits);
   double Balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   if(Equity >= Balance){
      trade.Buy(lotSize, NULL, Ask, 0 ,Ask+100*_Point, NULL);
   }
}

