// https://github.com/darwinex/mql4-to-mql5-tutorials/blob/master/3-accessing-symbol-information-in-mql5/MQL_SymbolInformation_Tests_1.mq5
// https://www.youtube.com/watch?v=8DVqhmItptU&list=PLv-cA-4O3y9407-3MUxlH6LNa_1XuYlV-&index=3

int OnInit()
{
  // (一)品種資訊
  /* SymbolInfoString() */

  Print("** SymbolInfoString() in BOTH MQL4 and MQL5 **");

  PrintFormat("SYMBOL_CURRENCY_BASE: %s", SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE));
  PrintFormat("SYMBOL_CURRENCY_PROFIT: %s", SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT));
  PrintFormat("SYMBOL_CURRENCY_MARGIN: %s", SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN));
  PrintFormat("SYMBOL_DESCRIPTION: %s", SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION));
  PrintFormat("SYMBOL_PATH: %s", SymbolInfoString(_Symbol, SYMBOL_PATH));

  Print("** SymbolInfoString() only in MQL5 **");

  PrintFormat("SYMBOL_BASIS: %s", SymbolInfoString(_Symbol, SYMBOL_BASIS));
  PrintFormat("SYMBOL_BANK: %s", SymbolInfoString(_Symbol, SYMBOL_BANK));
  PrintFormat("SYMBOL_FORMULA: %s", SymbolInfoString(_Symbol, SYMBOL_FORMULA));
  PrintFormat("SYMBOL_ISIN: %s", SymbolInfoString(_Symbol, SYMBOL_ISIN));
  PrintFormat("SYMBOL_PAGE: %s", SymbolInfoString(_Symbol, SYMBOL_PAGE));

  /* SymbolInfoDouble() */

  Print("** SymbolInfoDouble() in BOTH MQL4 and MQL5 **");

  PrintFormat("SYMBOL_BID: %G", SymbolInfoDouble(_Symbol, SYMBOL_BID));
  PrintFormat("SYMBOL_ASK: %G", SymbolInfoDouble(_Symbol, SYMBOL_ASK));
  PrintFormat("SYMBOL_POINT: %G", SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  PrintFormat("SYMBOL_TRADE_TICK_VALUE: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
  PrintFormat("SYMBOL_TRADE_TICK_SIZE: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
  PrintFormat("SYMBOL_TRADE_CONTRACT_SIZE: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE));
  PrintFormat("SYMBOL_VOLUME_MIN: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
  PrintFormat("SYMBOL_VOLUME_MAX: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
  PrintFormat("SYMBOL_VOLUME_STEP: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
  PrintFormat("SYMBOL_SWAP_LONG: %G", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG)); //隔夜利息 庫存費
  PrintFormat("SYMBOL_SWAP_SHORT: %G", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT));
  PrintFormat("SYMBOL_MARGIN_INITIAL: %G", SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL));
  PrintFormat("SYMBOL_MARGIN_MAINTENANCE: %G", SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_MAINTENANCE));

  Print("** SymbolInfoDouble() only in MQL5 **");

  PrintFormat("SYMBOL_BIDHIGH: %G", SymbolInfoDouble(_Symbol, SYMBOL_BIDHIGH));
  PrintFormat("SYMBOL_BIDLOW: %G", SymbolInfoDouble(_Symbol, SYMBOL_BIDLOW));
  PrintFormat("SYMBOL_ASKHIGH: %G", SymbolInfoDouble(_Symbol, SYMBOL_ASKHIGH));
  PrintFormat("SYMBOL_ASKLOW: %G", SymbolInfoDouble(_Symbol, SYMBOL_ASKLOW));
  PrintFormat("SYMBOL_LAST: %G", SymbolInfoDouble(_Symbol, SYMBOL_LAST));
  PrintFormat("SYMBOL_LASTHIGH: %G", SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH));
  PrintFormat("SYMBOL_LASTLOW: %G", SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW));
  PrintFormat("SYMBOL_VOLUME_REAL: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_REAL));
  PrintFormat("SYMBOL_VOLUMEHIGH_REAL: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUMEHIGH_REAL));
  PrintFormat("SYMBOL_VOLUMELOW_REAL: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUMELOW_REAL));
  PrintFormat("SYMBOL_OPTION_STRIKE: %G", SymbolInfoDouble(_Symbol, SYMBOL_OPTION_STRIKE));
  PrintFormat("SYMBOL_TRADE_TICK_VALUE_PROFIT: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT));
  PrintFormat("SYMBOL_TRADE_TICK_VALUE_LOSS: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS));
  PrintFormat("SYMBOL_TRADE_ACCRUED_INTEREST: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_ACCRUED_INTEREST));
  PrintFormat("SYMBOL_TRADE_FACE_VALUE: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_FACE_VALUE));
  PrintFormat("SYMBOL_TRADE_LIQUIDITY_RATE: %G", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_LIQUIDITY_RATE));
  PrintFormat("SYMBOL_VOLUME_LIMIT: %G", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT));
  PrintFormat("SYMBOL_SESSION_VOLUME: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_VOLUME));
  PrintFormat("SYMBOL_SESSION_TURNOVER: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_TURNOVER));
  PrintFormat("SYMBOL_SESSION_INTEREST: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_INTEREST));
  PrintFormat("SYMBOL_SESSION_BUY_ORDERS_VOLUME: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_BUY_ORDERS_VOLUME));
  PrintFormat("SYMBOL_SESSION_SELL_ORDERS_VOLUME: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_SELL_ORDERS_VOLUME));
  PrintFormat("SYMBOL_SESSION_OPEN: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_OPEN));
  PrintFormat("SYMBOL_SESSION_CLOSE: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_CLOSE));
  PrintFormat("SYMBOL_SESSION_AW: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_AW));
  PrintFormat("SYMBOL_SESSION_PRICE_SETTLEMENT: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_SETTLEMENT));
  PrintFormat("SYMBOL_SESSION_PRICE_LIMIT_MIN: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_LIMIT_MIN));
  PrintFormat("SYMBOL_SESSION_PRICE_LIMIT_MAX: %G", SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_LIMIT_MAX));
  PrintFormat("SYMBOL_MARGIN_HEDGED: %G", SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_HEDGED));

  /* SymbolInfoInteger() */

  Print("** SymbolInfoInteger() in BOTH MQL4 and MQL5 **");

  PrintFormat("SYMBOL_SELECT: %i", SymbolInfoInteger(_Symbol, SYMBOL_SELECT));
  PrintFormat("SYMBOL_VISIBLE: %i", SymbolInfoInteger(_Symbol, SYMBOL_VISIBLE));
  PrintFormat("SYMBOL_TIME: %i", SymbolInfoInteger(_Symbol, SYMBOL_TIME));
  PrintFormat("SYMBOL_DIGITS: %i", SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
  PrintFormat("SYMBOL_SPREAD_FLOAT: %i", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD_FLOAT));
  PrintFormat("SYMBOL_SPREAD: %i", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD));
  PrintFormat("SYMBOL_TRADE_CALC_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE));
  PrintFormat("SYMBOL_TRADE_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE));
  PrintFormat("SYMBOL_START_TIME: %i", SymbolInfoInteger(_Symbol, SYMBOL_START_TIME));
  PrintFormat("SYMBOL_EXPIRATION_TIME: %i", SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_TIME));
  PrintFormat("SYMBOL_TRADE_STOPS_LEVEL: %i", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL));
  PrintFormat("SYMBOL_TRADE_FREEZE_LEVEL: %i", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL));
  PrintFormat("SYMBOL_TRADE_EXEMODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_EXEMODE));
  PrintFormat("SYMBOL_SWAP_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_SWAP_MODE));
  PrintFormat("SYMBOL_SWAP_ROLLOVER3DAYS: %i", SymbolInfoInteger(_Symbol, SYMBOL_SWAP_ROLLOVER3DAYS));

  Print("** SymbolInfoInteger() only in MQL5 **");

  PrintFormat("SYMBOL_CUSTOM: %i", SymbolInfoInteger(_Symbol, SYMBOL_CUSTOM));
  PrintFormat("SYMBOL_BACKGROUND_COLOR: %i", SymbolInfoInteger(_Symbol, SYMBOL_BACKGROUND_COLOR));
  PrintFormat("SYMBOL_CHART_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE));
  PrintFormat("SYMBOL_EXIST: %i", SymbolInfoInteger(_Symbol, SYMBOL_EXIST));
  PrintFormat("SYMBOL_SESSION_DEALS: %i", SymbolInfoInteger(_Symbol, SYMBOL_SESSION_DEALS));
  PrintFormat("SYMBOL_SESSION_BUY_ORDERS: %i", SymbolInfoInteger(_Symbol, SYMBOL_SESSION_BUY_ORDERS));
  PrintFormat("SYMBOL_SESSION_SELL_ORDERS: %i", SymbolInfoInteger(_Symbol, SYMBOL_SESSION_SELL_ORDERS));
  PrintFormat("SYMBOL_VOLUME: %i", SymbolInfoInteger(_Symbol, SYMBOL_VOLUME));
  PrintFormat("SYMBOL_VOLUMEHIGH: %i", SymbolInfoInteger(_Symbol, SYMBOL_VOLUMEHIGH));
  PrintFormat("SYMBOL_VOLUMELOW: %i", SymbolInfoInteger(_Symbol, SYMBOL_VOLUMELOW));
  PrintFormat("SYMBOL_TICKS_BOOKDEPTH: %i", SymbolInfoInteger(_Symbol, SYMBOL_TICKS_BOOKDEPTH));
  PrintFormat("SYMBOL_MARGIN_HEDGED_USE_LEG: %i", SymbolInfoInteger(_Symbol, SYMBOL_MARGIN_HEDGED_USE_LEG));
  PrintFormat("SYMBOL_EXPIRATION_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE));
  PrintFormat("SYMBOL_FILLING_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE));
  PrintFormat("SYMBOL_ORDER_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_ORDER_MODE));
  PrintFormat("SYMBOL_ORDER_GTC_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_ORDER_GTC_MODE));
  PrintFormat("SYMBOL_OPTION_MODE: %i", SymbolInfoInteger(_Symbol, SYMBOL_OPTION_MODE));
  PrintFormat("SYMBOL_OPTION_RIGHT: %i", SymbolInfoInteger(_Symbol, SYMBOL_OPTION_RIGHT));


  //(二)K bar 資訊
  //K bar 法1.
  // https://www.mql5.com/en/docs/series/ihigh

  Print( iTime( _Symbol,_Period, 1  ) ) ;

  Print( iOpen( _Symbol,_Period, 1  ) ) ;
  Print( iHigh( _Symbol,_Period, 1  ) ) ;
  Print( iLow( _Symbol,_Period, 1  ) ) ;
  Print( iClose( _Symbol,_Period, 1  ) ) ;

  Print( iVolume( _Symbol,_Period, 1  ) ) ;
  Print( iTickVolume( _Symbol,_Period, 1  ) ) ;
  Print( iRealVolume( _Symbol,_Period, 1  ) ) ;
  
  
  //K bar 法2.
  double Open[], High[], Low[],  Close[] ;
  long Volume[];
  datetime Time[];

  int count = 2;

  ArraySetAsSeries( Open , true);
  Print( CopyTime(_Symbol,_Period, 0 , count , Time) );

  Print( CopyOpen(_Symbol,_Period, 0 , count , Open) );
  Print( CopyHigh(_Symbol,_Period, 0 , count , High) );
  Print( CopyLow(_Symbol,_Period, 0 , count , Low) );
  Print( CopyClose(_Symbol,_Period, 0 , count , Close) );

  // Print( CopyTickVolume(_Symbol,_Period, 0 , count , Volume) );
  Print( CopyRealVolume(_Symbol,_Period, 0 , count , Volume) );

  //K bar 法3.
  MqlRates _rates[];
  ArraySetAsSeries( _rates , true);
  CopyRates(_Symbol, _Period , 0, 2 , _rates);

  Print( _rates[0].time );
  Print( _rates[0].high );
  Print( _rates[0].low );
  Print( _rates[0].open );
  Print( _rates[0].close );
  // Print( _rates[0].tick_volume );
  Print( _rates[0].real_volume );
  
  // Tick資訊
  MqlTick _tick;
  SymbolInfoTick(_Symbol , _tick);
  
  Print(_tick.ask);
  Print(_tick.bid);
  Print(_tick.time_msc);
  Print(_tick.time);
  
  Print(_tick.volume);
  Print(_tick.volume_real);
  
  Print(_tick.last);
  Print(_tick.flags);

  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
}


void OnTick()
{

}

