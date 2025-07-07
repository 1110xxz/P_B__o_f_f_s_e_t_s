//+------------------------------------------------------------------+
//| Converted from MQL4 to MQL5                                     |
//+------------------------------------------------------------------+

// MQL5 converted version
if((_Period == PERIOD_H1) && (StringFind(_Symbol, "EURUSD", 0) >= 0) && (HistoryTotal() < 1) && (PositionsTotal() == 0))
{
   // Check if trading is allowed
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED) || !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Print("Trading not allowed at the moment.");
      return;
   }
   
   // In MQL5, there's no IsTradeContextBusy(), but we can check if trading is allowed
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
   {
      Print("Expert trading is not allowed.");
      return;
   }
   
   double lotSize = 0.01;
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   Print("MinLot=", minLot, " MaxLot=", maxLot, " LotStep=", lotStep);
   
   // Normalize lotSize
   lotSize = MathMax(lotSize, minLot);
   lotSize = MathMin(lotSize, maxLot);
   lotSize = NormalizeDouble(lotSize, 2);
   
   // Align to lotStep
   lotSize = minLot + MathFloor((lotSize - minLot) / lotStep) * lotStep;
   lotSize = NormalizeDouble(lotSize, 2);
   
   Print("Adjusted lotSize=", lotSize);
   
   // Get current prices
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol, tick))
   {
      Print("Failed to get tick data");
      return;
   }
   
   double ask = tick.ask;
   double StopLossValue = NormalizeDouble(ask - 100 * _Point, _Digits);
   double TakeProfitValue = NormalizeDouble(ask + 100 * _Point, _Digits);
   
   // Prepare trade request
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = lotSize;
   request.type = ORDER_TYPE_BUY;
   request.price = ask;
   request.sl = StopLossValue;
   request.tp = TakeProfitValue;
   request.comment = "SodobeScalperBuy";
   request.magic = 0;
   request.deviation = 3;
   
   // Send the order
   if(!OrderSend(request, result))
   {
      Print("OrderSend failed with error #", GetLastError());
      Print("Return code: ", result.retcode);
      Print("Comment: ", result.comment);
      ResetLastError();
   }
   else
   {
      if(result.retcode == TRADE_RETCODE_DONE || result.retcode == TRADE_RETCODE_PLACED)
      {
         Print("Order opened successfully with ticket #", result.order);
         Print("Deal ticket: ", result.deal);
      }
      else
      {
         Print("Order failed with return code: ", result.retcode);
         Print("Comment: ", result.comment);
      }
   }
}