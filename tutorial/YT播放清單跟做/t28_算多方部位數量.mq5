#include <Trade/Trade.mqh>
CTrade trade;
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnTick()
  {

  }

int countBuyPos(){
   int c= 0;
   for(int i = PositionsTotal()-1; i>=0 ; i-- ){
      
      //部位的品種?
      //automatically selects the position for 
      //further working with it  using functions PositionGetDouble, PositionGetInteger, PositionGetString.
      string currencyPair = PositionGetSymbol(i);//開倉部位的列表索引值
      
      //position type?
      int positionDirection = PositionGetInteger(POSITION_TYPE);
      
      if(_Symbol == currencyPair)
      if(positionDirection==POSITION_TYPE_BUY) //多部位 標識符
      {
        c++;  
      }
      
      
   }
   
   return c;
}