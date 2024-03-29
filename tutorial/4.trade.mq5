//https://www.youtube.com/watch?v=2ozNIz06vB0&list=PLv-cA-4O3y9407-3MUxlH6LNa_1XuYlV-&index=4&ab_channel=Darwinex

#include <Trade\Trade.mqh> 
input int InpMagicNumber = 2000001; // ID for this EA


//CTrade *Trade;

void OnTick()
{
/*
  https://www.mql5.com/en/docs/trading\

  ----Order訂單相關

    ulong OrderGetTicket( int  index )   //Return the ticket of a corresponding order
    bool  OrderSelect( ulong   ticket )

    // Checks if there are enough funds to execute
    bool OrderCheck(    
      MqlTradeRequest&       request,
      MqlTradeCheckResult&   result
    );

    bool  OrderSend(    
      MqlTradeRequest&  request,
      MqlTradeResult&   result
    );
    //'true' means only that the order has been successfully placed in the trading system

    bool  OrderSendAsync


    https://www.mql5.com/en/docs/constants/structures/mqltraderequest
    https://www.mql5.com/en/docs/constants/structures/mqltraderesult

  ----Position 倉位相關
    bool PositionSelect( string  symbol );  //Chooses an open position

    ulong PositionGetTicket(
      int  index      // index in the list of open positions
    );
    
    bool PositionSelectByTicket( ulong   ticket )

  ----History 交易紀錄相關
    HistorySelect

*/



  //---空0.01
  
  MqlTradeRequest request={};
  MqlTradeResult  result={};
  
  //https://www.mql5.com/en/docs/constants/tradingconstants/enum_trade_request_actions
  request.action   =TRADE_ACTION_DEAL;                     // type of trade operation
  request.symbol   =Symbol();                              // symbol
  request.volume   =0.01;                                   // volume of 0.2 lot
  request.type     =ORDER_TYPE_SELL;                       // order type
  request.price    =SymbolInfoDouble(Symbol(),SYMBOL_BID); // price for opening
  request.deviation=111;                                     // allowed deviation偏差 from the price
  request.magic    =InpMagicNumber;                        // MagicNumber of the order 應該可同時跑多個EA，用Magic number來代表每個EA
  
  //檢查是否有足夠的餘額進行交易
  //---OrderCheck
  
  //--- send the request 發送市價單 ，檢查是否成功下單
  if(!OrderSend(request,result))
    PrintFormat("OrderSend error %d",GetLastError()); 
  //--- information about the operation
  PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
  
  //--- 修改訂單
  
  //---平此空單
  
  //---平一部分?

  //---平所有訂單
  CloseAllOrders();

  // result.deal 
  //  Deal ticket,  if a deal has been performed. It is available for a trade operation of TRADE_ACTION_DEAL type
  // result.order 
  //  Order ticket, if a ticket has been placed. It is available for a trade operation of TRADE_ACTION_PENDING type
  

  // result.price//Deal price
  // result.volume//Deal volume. It depends on the order filling type https://www.mql5.com/en/docs/constants/tradingconstants/orderproperties#enum_order_type_filling
  
  // result.request_id
  // result.retcode
  // result.retcode_external
  // result.comment
  
}

void OnTrade() //moment of the order processing
  {
  }
  
//OnTradeTransaction handler will be called several times when executing one trade request.
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
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