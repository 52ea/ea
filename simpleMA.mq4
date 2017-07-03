//+------------------------------------------------------------------+
//|                                                        NTest.mq4 |
//|                                     Copyright 2017, www.52ea.net |
//|                                              http://www.52ea.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, www.52ea.net"
#property link      "http://www.52ea.net"
#property version   "0.1"
#property strict

//- External variables
extern double eLotSize = 0.1;

//- do not set stop loss and take profit. let the market do it.
//extern double eStopLoss = 30;
//extern double eTakeProfit = 200;

extern double eStopLoss = 0;
extern double eTakeProfit = 0;

extern int eSlipPage = 5;
extern int eMagicNumber = 1234567;
extern int eFastMAPeriod = 21;
extern int eSlowMAPeriod = 34;

//- Global variables
int gBuyTicket;
int gSellTicket;

double gUsePoint;
int gUseSlipPage;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //---
      gUsePoint = PipPoint(Symbol());
      gUseSlipPage = GetSlipPage(Symbol(), eSlipPage);
   //---
   return(INIT_SUCCEEDED);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //---
   //- use two line to open order while cross  
   //- Moving averages
   double fastMA = iMA(NULL,0,eFastMAPeriod,0,0,0,0);
   double slowMA = iMA(NULL,0,eSlowMAPeriod,0,0,0,0);
   
   double fastPreMa = iMA(NULL,0,eFastMAPeriod,0,0,0,1);
   double slowPreMa = iMA(NULL,0,eFastMAPeriod,0,0,0,1);
   
   //- for close order
   double closeLots;
   double closePrice;
   bool closed;
   
   //- for open order
   double openPrice;
   double stopLoss;
   double takeProfit;
   
   //CalMADiff(fastMA, slowMA);
   //-CloseByMADiff(fastMA, slowMA);
   
   // add the hedging transaction here. 
   
   //- buy order
   if(fastMA > slowMA && fastPreMa <= slowPreMa && 0 == gBuyTicket){
      OrderSelect(gSellTicket, SELECT_BY_TICKET);
      
      //- close sell order
      if(0 == OrderCloseTime() && 0 < gSellTicket){
         closeLots = eLotSize;
         closePrice = Ask;
         closed = OrderClose(gSellTicket, closeLots,closePrice, gUseSlipPage, Red);
      }
          
      openPrice = Ask;
     //- calculate sotp loss and take profit
      stopLoss = eStopLoss;
     if(0 < eStopLoss){
         stopLoss = openPrice - (eStopLoss * gUsePoint);
     }
     takeProfit = eTakeProfit;
     if(0 < eTakeProfit){
         takeProfit = openPrice + (eTakeProfit * gUsePoint);
     }
     
     // open buy order
     gBuyTicket = OrderSend(Symbol(), OP_BUY, eLotSize, openPrice, gUseSlipPage, stopLoss, takeProfit, "Buy Order", eMagicNumber,Green);
     gSellTicket = 0;    
   }
   
   //- sell order
   if(fastMA < slowMA && fastPreMa >= slowPreMa && 0 == gSellTicket)
   {
      OrderSelect(gBuyTicket, SELECT_BY_TICKET);
        //- close buy order
      if(0 == OrderCloseTime() && 0 < gBuyTicket){
         closeLots = eLotSize;
         closePrice = Bid;
         closed = OrderClose(gBuyTicket, closeLots,closePrice, gUseSlipPage, Red);
      }
           
      //-open buy order
      openPrice = Bid;
      stopLoss = eStopLoss;
      if(0 < eStopLoss){
         stopLoss = openPrice + (eStopLoss * gUsePoint);
      }
      takeProfit = eTakeProfit;
      if(0 < eTakeProfit){
         takeProfit = openPrice - (eTakeProfit * gUsePoint);
      }
      gSellTicket = OrderSend(Symbol(), OP_SELL, eLotSize, openPrice, gUseSlipPage, stopLoss, takeProfit, "Sell Order", eMagicNumber,Green);
      gBuyTicket = 0; 
   }
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Self Defined function                                             |
//+------------------------------------------------------------------+

//-PipPoint function
double PipPoint(string currency)
{
   int calcDigits = (int)MarketInfo(currency, MODE_DIGITS);
   
   //- default for (2 or 3) == calcDigits 
   double calcPoint = 0.01;
   if(4 == calcDigits || 5 == calcDigits){
      calcPoint = 0.0001;
   }
   return(calcPoint);
}

//- GetSlipPage function
int GetSlipPage(string currency, int slipPagePips)
{
   int calcDigits = (int)MarketInfo(currency, MODE_DIGITS);
   
   //- default for (2 or 4) == calcDigits
   double calcSlipPage = slipPagePips;
   if(3 == calcDigits || 5 == calcDigits){
      calcSlipPage = 10 * slipPagePips;
   }
   return(calcSlipPage);
}

//+------------------------------------------------------------------+
  
