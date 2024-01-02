int TicksReceivedCount = 0;

void OnTick()
  {
    TicksReceivedCount++;

     Comment(
          "Symbol: ", Symbol(), "\n\r",
          "MT5 Server Time: ", TimeCurrent(), "\n\r",
          "Ticks Received: ", TicksReceivedCount
     );
  }