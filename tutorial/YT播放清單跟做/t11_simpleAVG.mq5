void OnTick()
  {
      double arr[];
      
      int MA_Definition = iMA(_Symbol , _Period, 20 , 0 ,MODE_SMA , PRICE_CLOSE);
      
      //20根算
      //SMA = simple moving average 
      //燭的多種price
      
      CopyBuffer(MA_Definition , 0 ,0,3, arr);
      
      float x = arr[1];
      
      Comment("最後20根" , x);
  }
