#define MICRO 0.01

#include "SarHelper.mq5"
#include "Lib_Trade.mq5"


// double BaseUSD = 200.00; //每營利 x 可出金
double Base = 2;
input double Delta = 0.00571;//0.00350;

// input double n = 1/0.69314718056; //回測Delta/n  終局 //1.44269504
// double CloseCondition = Delta*n; 
double CloseCondition = Delta/0.69314718056;

input int FirstOrderUnitAdjust = 54; //首單預設2單位，此處調整
double Price_LastOpen = NULL;

int MicroLot_Holding_MAX = 0;
datetime MicroLot_Holding_MAX_Time = NULL;



class MartinGM_Base
{
private:
protected:
public:
   bool isLong;
   ENUM_SYMBOL_INFO_DOUBLE priceTypeEnum_Open;
   ENUM_SYMBOL_INFO_DOUBLE priceTypeEnum_Close;
   ENUM_ORDER_TYPE orderType;

   double price_Ref; // 本局參照價

   // v最後一次抓價計算
   double price_LastFetch; 
   double nDelta;     // 最後一次'進單價'距離'參照價' 幾倍Delta
   double unitIdeal; // 應持倉單位  Unit
   // ^最後一次抓價計算

   double unitToMicroLot;
   int microLot_Holding;

   MartinGM_Base( int microLot ){
      unitToMicroLot = 1;     //0.01* floor(AccountInfoDouble(ACCOUNT_BALANCE) / BaseUSD);
      microLot_Holding = microLot;
   }

   void AfterSided()
   {
      price_Ref = get_PriceForOpen();

      Print("基準價Price_Ref:", price_Ref);
      EnsurePositonEnough();
   }


   void EnsurePositonEnough(){
      FetchPrice_Then_CalcUnitIdeal();
      int microLot_Ideal = floor(unitIdeal * unitToMicroLot) ; 
      int microLot_Lack = microLot_Ideal - microLot_Holding;
      if ( microLot_Lack > 0 )
      {
         Print("理想 ", microLot_Ideal, " 微手，大於現在持倉 ", microLot_Holding, "微手");
         Print("---------要加碼 ", microLot_Lack, " 微手-----");

         OpenPosition_ThenRecord( 
            microLot_Lack, 
            price_LastFetch);
      }
   }

   // 根據 限價<->基準價 間的價差，取理想持倉手數
   void FetchPrice_Then_CalcUnitIdeal(){
      price_LastFetch = get_PriceForOpen();
      //扛價差
      double priceDiff_Endure = get_priceDiff_Endure();

      //      0   1   2   3
      //     +2, +2, +4, +8...  
      //sum   2   4   8   16  = 2^(n+1)

      nDelta = priceDiff_Endure / Delta;
      unitIdeal = MathPow(Base, nDelta + 1 ) + FirstOrderUnitAdjust;

      // Print("price_LastFetch: ",price_LastFetch);
      // Print("priceDiff_Endure: ", priceDiff_Endure);
      // Print("nDelta: ", nDelta);
      // Print("unitIdeal: ", unitIdeal);
   };
   
   double get_PriceForOpen(){
      return GetPrice_Current(priceTypeEnum_Open);
   }

   double virtual get_priceDiff_Endure()=NULL;

   void OpenPosition_ThenRecord(int MicroLot_Order, double Price_Order)
   {
      // double Price_Order = price_LastFetch;
      double Lot_Order = MicroLot_Order * MICRO;

      //應該僅是檢查是否成功提交訂單
      if (OpenPosition( orderType , Lot_Order, Price_Order))
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

   double virtual get_priceDiff_Happy()=NULL;

   bool isGameSatisfied() {
      double priceDiff_Happy = get_priceDiff_Happy();
      bool result = priceDiff_Happy > CloseCondition ;
      return result;
   }

   ~MartinGM_Base()
   {   }
};


//===============================

// 多方局管理員
class MartinGM_Long : public MartinGM_Base
{
private:
protected:
public:
   MartinGM_Long(int microLot) : MartinGM_Base(microLot)
   {
      isLong = true;
      priceTypeEnum_Open = SYMBOL_ASK;
      priceTypeEnum_Close = SYMBOL_BID;
      orderType = ORDER_TYPE_BUY;

      AfterSided();
   }
   // 根據 限價<->基準價 間的價差，取理想持倉手數
   double get_priceDiff_Endure() override
   {
      return price_Ref - price_LastFetch;
   }
   double get_priceDiff_Happy() override //double price_Close
   {
      double price_Close = GetPrice_Current(SYMBOL_BID);
      return price_Close - Price_LastOpen ;
   }
};

// 空方局管理員
class MartinGM_Short : public MartinGM_Base
{
private:
protected:
public:
   MartinGM_Short(int microLot) : MartinGM_Base(microLot)
   {
      isLong = false;
      priceTypeEnum_Open = SYMBOL_BID;
      priceTypeEnum_Close = SYMBOL_ASK;
      orderType = ORDER_TYPE_SELL;

      AfterSided();
   }

   double get_priceDiff_Endure() override
   {
      return price_LastFetch - price_Ref;
   }
   double get_priceDiff_Happy() override //double price_Close
   {
      double price_Close = GetPrice_Current(SYMBOL_ASK);
      return Price_LastOpen - price_Close;
   }
};



// ==========
bool DecideSide(){
   // 先無視點差，不特定用BID / ASK -> 比較SAR -> 決定 isLong
   double sar = SarHelper::GetSAR();
   double Price_Current = GetPrice_Current(SYMBOL_BID);

   bool isLong = Price_Current > sar;

   return isLong;
}

void SetNewGame(bool isLong , int microLot) {
   if(isLong){
      Print("===========新局#", ++NewGameCount, "：多方" );
      martinGM = new MartinGM_Long(microLot);
   }else{
      Print("===========新局#", ++NewGameCount, "：空方" );
      martinGM = new MartinGM_Short(microLot);
   }
}