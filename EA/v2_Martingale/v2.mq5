double Base = 2;
input double Delta = 0.00568;
double CloseCondition = Delta / 0.69314718056;

input int FirstOrderAdditionalUnit = 0;
input double inp_unitToMicroLot = 1;

int firstOrder_microLot = floor(inp_unitToMicroLot * (1 + FirstOrderAdditionalUnit));

#include "../include/EventHandler.mq5";

class GM : public CGameMasterBase
{
private:
protected:
public:
  // v最後一次抓價計算
  double nDelta; // 最後一次'進單價'距離'參照價' 幾倍Delta
  // ^最後一次抓價計算

  GM(bool isLong, int microLot) : CGameMasterBase(isLong, microLot)
  {
  }

  // 根據 限價<->基準價 間的價差，取理想持倉手數
  void FetchPrice_Then_CalcUnitIdeal() override
  {
    price_LastFetch = get_PriceForOpen();
    double priceDiff_Endure = get_priceDiff_Endure();

    nDelta = priceDiff_Endure / Delta;
    // nDelta   0   1   2   3
    //         +1, +1, +2, +4...
    // sum      1   2   4   8  = 2^n
    unitIdeal = MathPow(Base, nDelta) + FirstOrderAdditionalUnit;

    // Print("---進場計算: ");
    // Print("price_LastFetch: ",price_LastFetch);
    // Print("priceDiff_Endure: ", priceDiff_Endure);
    // Print("nDelta: ", nDelta);
    // Print("unitIdeal: ", unitIdeal);
  };

  double virtual get_priceDiff_Endure() = NULL;
  double virtual get_priceDiff_Happy() = NULL;

  bool isGameSatisfied() override
  {
    double priceDiff_Happy = get_priceDiff_Happy();
    bool result = priceDiff_Happy > CloseCondition;
    return result;
  }
};

//===============================

// 多方局管理員
class GM_Long : public GM
{
private:
protected:
public:
  GM_Long(int microLot) : GM(true, microLot)
  {
  }
  double get_priceDiff_Endure() override
  {
    return price_Ref - price_LastFetch;
  }
  double get_priceDiff_Happy() override
  {
    double price_Close = GetPrice_Current(SYMBOL_BID);
    return price_Close - Price_LastOpen;
  }
};

// 空方局管理員
class GM_Short : public GM
{
private:
protected:
public:
  GM_Short(int microLot) : GM(false, microLot)
  {
  }

  double get_priceDiff_Endure() override
  {
    return price_LastFetch - price_Ref;
  }
  double get_priceDiff_Happy() override
  {
    double price_Close = GetPrice_Current(SYMBOL_ASK);
    return Price_LastOpen - price_Close;
  }
};
