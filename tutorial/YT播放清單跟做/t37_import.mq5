#include "t37_someSourceFile.mq5" //不可含有 特殊函數

//<>是library  同

void OnTick()
  {
  	//引入函數
  	
   int sum = Add(3,6);
   
   Comment("sum: " , sum);
  }
