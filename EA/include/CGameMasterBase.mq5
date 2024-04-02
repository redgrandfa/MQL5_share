int MicroLot_Holding_MAX = 0;
datetime MicroLot_Holding_MAX_Time = NULL;

double Price_LastOpen = NULL;

class CGameMasterBase
{
public:
  bool isLong;
  ENUM_SYMBOL_INFO_DOUBLE priceTypeEnum_Open;
  ENUM_SYMBOL_INFO_DOUBLE priceTypeEnum_Close;
  ENUM_ORDER_TYPE orderType;

  double price_Ref;

  // v最後一次抓價計算
  double price_LastFetch;
  double unitIdeal; // 應持倉單位  Unit
  // ^最後一次抓價計算

  double unitToMicroLot;
  int microLot_Holding;
  

  CGameMasterBase(bool isLong, int microLot)
  {
    if (isLong)
    {
      this.isLong = true;
      priceTypeEnum_Open = SYMBOL_ASK;
      priceTypeEnum_Close = SYMBOL_BID;
      orderType = ORDER_TYPE_BUY;
    }
    else
    {
      this.isLong = false;
      priceTypeEnum_Open = SYMBOL_BID;
      priceTypeEnum_Close = SYMBOL_ASK;
      orderType = ORDER_TYPE_SELL;
    }


    price_Ref = get_PriceForOpen();
		Print("基準價Price_Ref:", price_Ref);

		unitToMicroLot = inp_unitToMicroLot;
    microLot_Holding = microLot;
  }


  // static CGameMasterBase CreateInstance();

	double get_PriceForOpen()
	{
		return GetPrice_Current(priceTypeEnum_Open);
	}

  void EnsurePositonEnough()
  {
    FetchPrice_Then_CalcUnitIdeal();
    int microLot_Ideal = floor(unitIdeal * unitToMicroLot);
    int microLot_Lack = microLot_Ideal - microLot_Holding;
    if (microLot_Lack > 0)
    {
      Print("-------加碼:-------");
      Print("price_LastFetch: ", price_LastFetch);

      Print("理想 ", microLot_Ideal, " 微手，大於現在持倉 ", microLot_Holding, "微手");
      Print("---------下單 ", microLot_Lack, " 微手:-----");

      OpenPosition_ThenRecord(
          microLot_Lack,
          price_LastFetch);
    }
  }

  // void virtual FetchPrice_Then_CalcUnitIdeal(){
  //   Print(__FUNCSIG__);
  // }
  void virtual FetchPrice_Then_CalcUnitIdeal() = NULL;

  void OpenPosition_ThenRecord(int MicroLot_Order, double Price_Order)
  {
    // double Price_Order = price_LastFetch;
    double Lot_Order = MicroLot_Order * MICRO;

    // 應該僅是檢查是否成功提交訂單
    if (OpenPosition(orderType, Lot_Order, Price_Order))
    {
      Price_LastOpen = Price_Order;
      Print("最後進場價Price_LastOpen: ", Price_LastOpen);

      microLot_Holding += MicroLot_Order;
      Print("持倉 microLot_Holding:", microLot_Holding, "微手");

      if (microLot_Holding > MicroLot_Holding_MAX)
      {
        MicroLot_Holding_MAX = microLot_Holding;
        MicroLot_Holding_MAX_Time = TimeTradeServer();
      }
    }
  }

  bool virtual isGameSatisfied() = NULL;
};
