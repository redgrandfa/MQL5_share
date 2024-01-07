#include <Trade\Trade.mqh>

//| EA初始化函数
int SAR = 0; 

MqlParam params[]; // 存储指标参数的数组                                       |

int OnInit()
{
  //--- 創建sar指標 IndicatorCreate()

  // 设置params的大小和被调用指标参数数量一致
  ArrayResize(params, 2); // sar指標需輸入2個參數
                          // 步长
  params[0].type = TYPE_DOUBLE;
  params[0].double_value = 0.02;
  // 最大值
  params[1].type = TYPE_DOUBLE;
  params[1].double_value = 0.2;

  SAR = IndicatorCreate(Symbol(), 0, IND_SAR, 2, params); //(商品,週期,指標(ENUM_INDICATOR),params參數數量,params數組 )
  //A();
  
  return (0);
}

void OnTick()
{
  A();
}

void A(){
  //--- 獲取指標數據 CopyBuffer()
  double _sar[]; // 儲存數據的數組

  ArraySetAsSeries(_sar, true);
  // 設置索引方法：将数组设置成和时间序列一样，例如数组索引为0的元素
  // 存储最近一个柱形的值，索引为1的元素存储第二近柱形的值，等等。

  // 使用指标句柄将指标的缓存值，复制到数组中，这些数组正是用于这个目的
  if (CopyBuffer(SAR, 0, 0, 20, _sar) < 0)
  {
    Print("CopyBufferSAR error =", GetLastError());
  }
  // CopyBuffer( 要獲取的數據,同OnInit(),
  //             指標緩衝區編號，sar僅有一個所以為0。
  //             初始K棒
  //             要複製的K棒數量
  //             儲存目的地數組

  Print(_sar[0]); // 最近一個K棒的sar值

}

//+------------------------------------------------------------------+