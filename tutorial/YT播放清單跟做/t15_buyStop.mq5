#include <Trade/Trade.mqh>

CTrade trade; //物件

void OnTick()
  {
      //get  price
      double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
      
      if( (OrdersTotal()==0 )  && ( PositionsTotal()==0 ) ){
         //bool  BuyLimit(  
         //   double                volume,                       // ??交易量 
         //   double                price,                        // ??价格 
         //   const string          symbol=NULL,                  // 品名 
         //   double                sl=0.0,                       // 止?价 
         //   double                tp=0.0,                       // 止盈价 
         //   ENUM_ORDER_TYPE_TIME  type_time=ORDER_TIME_GTC,     // ??生命周期 
         //   datetime              expiration=0,                 // ???期?? 
         //   const string          comment=""                    // 注? 
         //   )
         trade.BuyStop(  //參數和 BuyLimit一模一樣 
               0.01 , 
               Ask+150*_Point , //漲後，突破
               NULL , //NULL會使用 目前品種
               0 ,   //0應該是不設定
               Ask+450*_Point, 
               ORDER_TIME_GTC, //till cancel
               0,
               NULL
            );
      }
  }
//+------------------------------------------------------------------+
