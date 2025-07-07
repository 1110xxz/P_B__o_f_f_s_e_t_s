//+------------------------------------------------------------------+
//|                                           Converted to MQL5     |
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

CTrade trade;

void OnTick()
{
   // Convert the validation logic to MQL5
   if((_Period == PERIOD_H1) && (StringFind(_Symbol, "EURUSD", 0) >= 0) && 
      (HistoryDealsTotal() < 1) && (PositionsTotal() == 0))
   {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      {
         Print("Trading not allowed at the moment.");
         return;
      }
   
      // In MQL5, trade context busy check is handled automatically by CTrade class
      // But we can still check if needed
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
      {
         Print("Trade operations not allowed.");
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
      
      // Get lot step digits for proper normalization
      int lotDigits = (int)MathLog10(1.0 / lotStep);
      lotSize = NormalizeDouble(lotSize, lotDigits);
   
      // Align to lotStep
      lotSize = minLot + MathFloor((lotSize - minLot) / lotStep) * lotStep;
      lotSize = NormalizeDouble(lotSize, lotDigits);
   
      Print("Adjusted lotSize=", lotSize);
   
      // Get current prices
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
      double StopLossValue = NormalizeDouble(ask - 100 * point, digits);
      double TakeProfitValue = NormalizeDouble(ask + 100 * point, digits);
   
      // Use CTrade class for order placement
      trade.SetExpertMagicNumber(0);
      trade.SetDeviationInPoints(3);
      
      if(trade.Buy(lotSize, _Symbol, ask, StopLossValue, TakeProfitValue, "SodobeScalperBuy"))
      {
         Print("Order opened successfully with ticket #", trade.ResultOrder());
      }
      else
      {
         Print("OrderSend failed with error #", trade.ResultRetcode(), " - ", trade.ResultRetcodeDescription());
      }
   }
}