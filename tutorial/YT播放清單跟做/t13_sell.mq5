#include <Trade/Trade.mqh>

CTrade trade; //物件

void OnTick()
  {
      //get  price
      double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
      
      MqlRates PriceInfo[]; //
      
      //排序?? 先排蠟燭?
      ArraySetAsSeries(PriceInfo , true); //true=倒敘
      
      //填入
      int PriceData = CopyRates(_Symbol , _Period , 0 , 3 , PriceInfo);
      //以上和教學12一樣
      
      //判斷 熊
      if(PriceInfo[1].close < PriceInfo[1].open ){
         //空倉 才開
         if(PositionsTotal() == 0){
            //2參 可以指定品名
            trade.Sell(
               0.01 , 
               NULL , 
               Bid , 
               Bid+300*_Point ,  //空單止損 較高
               Bid-150*_Point,   //空單止盈 較低
               NULL
            );
         }
      }
  }
//+------------------------------------------------------------------+
