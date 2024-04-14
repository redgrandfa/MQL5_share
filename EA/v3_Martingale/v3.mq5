// 指數函數進單，回測比例停利

double Base = 2;

// -500停損：點差10 
// 2015/03/30~2024/03/30 
// input double Delta = 0.00950;
// input double CloseCondition = 0.510;
// input double FirstOrderAdditionalUnit = 18;
/*
Profit          13507.31    => 年化報酬 1.44233632
EquityDD max    3724.57
EquityDD abs    3 096.54
-500停損次數     27
Total Trades    1231

Recovery Factor 3.63
Profit factor   1.89
Expected Payoff 10.97
Sharp ratio     0.58
Complex         80.6
*/

// -2000停損：點差6  SAR H1
input uint loopPeriodSec = 900;
input double priceEndure_To_nDelta = 120; 
input double CloseCondition = 0.515;
input double inp_unitToMicroLot = 1;
input int positionMultiplier = 1;
input int timeFrameIndex = 11; 


double FirstOrderAdditionalUnit = 0;
int firstOrder_microLot = floor(inp_unitToMicroLot * (1 + FirstOrderAdditionalUnit));
double SL_Condition = -2000;
#include "../include/EventHandler.mq5";

class GM : public CGameMasterBase
{
private:
protected:
public:
  // v最後一次抓價計算
  double nDelta; // 最後一次[進單價]距離[參照價] 幾倍Delta
  // ^最後一次抓價計算

  GM(bool isLong, int microLot) : CGameMasterBase(isLong, microLot)
  {
  }

  // 根據 限價<->基準價 間的價差，取理想持倉手數
  void FetchPrice_Then_CalcUnitIdeal() override
  {
    price_LastFetch = get_PriceForOpen();
    double priceDiff_Endure = get_priceDiff_Endure();

    nDelta = priceDiff_Endure * priceEndure_To_nDelta;
    // nDelta   0   1   2   3
    //         +1, +1, +2, +4...
    // sum      1   2   4   8  = 2^n
    unitIdeal = MathPow(Base, nDelta) + FirstOrderAdditionalUnit;

    // Print("---進場計算: ");
    // Print("price_LastFetch: ", price_LastFetch);
    // Print("priceDiff_Endure: ", priceDiff_Endure);
    // Print("nDelta: ", nDelta);
    // Print("unitIdeal: ", unitIdeal);
  };

  double virtual get_priceDiff_Endure() = NULL;
  double virtual get_priceDiff_Happy() = NULL;
  double virtual get_priceDiff_LastOpenEndure() = NULL;

  bool isGameTakeProfit() override
  {
    double priceDiff_Happy = get_priceDiff_Happy();

    double denominator = get_priceDiff_LastOpenEndure();

    bool result;
    if (denominator > 0)
    {
      double proportion = priceDiff_Happy / denominator;
      // Print("proportion: " , proportion);

      result = proportion > CloseCondition;
    }
    else if (denominator == 0)
    {
      result = priceDiff_Happy > 0;
    }

    // if (result)
    // {
    //   Print("出場計算: ");
    //   Print("price_Ref: ", price_Ref);
    //   Print("Price_LastOpen: ", Price_LastOpen);
    //   //Print("price_Close: ", price_Close);

    //   Print("priceDiff_Happy: ", priceDiff_Happy);
    //   Print("denominator: ", denominator);
    // }

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
  double get_priceDiff_LastOpenEndure() override
  {
    return price_Ref - Price_LastOpen;
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
  double get_priceDiff_LastOpenEndure() override
  {
    return Price_LastOpen - price_Ref;
  }
};
