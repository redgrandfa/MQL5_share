#include <Trade/Trade.mqh>

CTrade trade; //物件

void OnTick()
  {
      //get  price
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      
      MqlRates PriceInfo[]; //
      
      //排序?? 先排蠟燭?
      ArraySetAsSeries(PriceInfo , true); //true=倒敘
      
      //填入
      int PriceData = CopyRates(_Symbol , _Period , 0 , 3 , PriceInfo);
   
      //判斷 牛
      if(PriceInfo[1].close > PriceInfo[1].open ){
         //空倉 才開
         if(PositionsTotal() == 0){
            //2參 可以指定品名
               trade.Buy(
               0.01 , 
               NULL , 
               Ask , 
               Ask-300*_Point , 
               Ask+150*_Point, 
               NULL
            );
         }
      }
  }
//+------------------------------------------------------------------+
