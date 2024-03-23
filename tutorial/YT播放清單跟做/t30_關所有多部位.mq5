#include <Trade/Trade.mqh>
CTrade trade;
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnTick()
  {

  }

void closeAllBuyPos(){
   for(int i = PositionsTotal()-1; i>=0 ; i-- ){
		//取票號

      //部位的品種?
      //automatically selects the position for 
      //further working with it  using functions PositionGetDouble, PositionGetInteger, PositionGetString.
      ulong ticket = PositionGetTicket(i);//開倉部位的列表索引值
      
      //position type?
      int positionDirection = PositionGetInteger(POSITION_TYPE);
      
      if(positionDirection==POSITION_TYPE_BUY)
      {
         trade.PositionClose(ticket)
      }
   }
   
}