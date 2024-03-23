#include <Trade/Trade.mqh>
CTrade trade;
int OnInit()
  {

   return(INIT_SUCCEEDED);
  }

void OnTick()
  {

  }

void ChangePositionSize(double Ask){ //

	//帳戶結餘
	double balance = AccountInfoDouble(ACCOUNT_BALANCE);
	
	//帳戶權益?
   double Equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   for(int i = PositionsTotal()-1 ; i>=0 ; i--){
   	string symbol = PositionGetSymbol(i);
   	if(_symbol==symbol){
   		ulong positionTicket= PositionGetInteger(POSITION_TICKET);
   		
   		int positionDir = PositionGetInteger(POSITION_TYPE);
   		
   		if(positionDir==POSITION_TYPE_BUY){
   			if(balance < ( Equity+10*_Point ) ){
   				//重點
   				trade.PositionClosePartial(positionTicket , 0.01 , -1) //deviation 偏差點
   			}
   		}
   	}
   }
   
}