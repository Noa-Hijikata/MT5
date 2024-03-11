//+------------------------------------------------------------------+
//|                                           SendStochasticData.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

input string Address = "127.0.0.1";
input int Port = 8080;
input uint Timeout = 1000;
int socket;

input int Kperiod = 5;
input int Dperiod = 3;
input int Slowing = 3;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   socket = SocketCreate();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   SocketClose(socket);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   socket = SocketCreate();
   if (socket != INVALID_HANDLE) {
      if (SocketConnect(socket, Address, Port, Timeout)) {
         Print("Connected To ", Address, ":", Port);
         
         string message = CreateMessage();
         if (SockSend(socket, message)) {
            Print("Sent Message: " + message);
            
            if (!SockReceive(socket, Timeout)) {
               Print("Failed to get a response, error: ", GetLastError());
            }
         }
         else {
            Print("Failed to send request, error: ", GetLastError());
         }
         
      }
      else {
         Print("Connection to ", Address, ":", Port, "failed, error: ", GetLastError());
      }
      SocketClose(socket);
   }
   else {
      Print("Socket creation error ",GetLastError());
   }
  }
//+------------------------------------------------------------------+

bool SockSend(int sock,string request) 
 {
  char req[];
  int  len=StringToCharArray(request,req)-1;
  if(len<0) return(false);
  return(SocketSend(sock,req,len)==len); 
 }
 
bool SockReceive(int sock, uint timeout) 
 {
  char rsp[];
  string result;
  uint timeout_check = GetTickCount() + timeout;

  do {
     uint len = SocketIsReadable(sock);
     if (len) {
        int rsp_len;
        rsp_len = SocketRead(sock, rsp, len, timeout);
        if (rsp_len>0){
           result += CharArrayToString(rsp, 0, rsp_len);
        }
     } 
  } while (GetTickCount() < timeout_check && !IsStopped());
  Print(result);
  return (false);
 }
 
 string CreateMessage()
  {   
   double main[];
   double signal[];
   
   ArraySetAsSeries(main, true);
   ArraySetAsSeries(signal, true);
   
   int StockDef = iStochastic(_Symbol, _Period, Kperiod, Dperiod, Slowing, MODE_SMA, STO_LOWHIGH);
   
   CopyBuffer(StockDef, 0, 0, 3, main);
   CopyBuffer(StockDef, 1, 0, 3, signal);
   
   float mainValue = main[0];
   float signalValue = signal[0];
   
   return (string)mainValue + "," + (string)signalValue;
  }
