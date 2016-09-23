//--------------------------------------------------------------------------------
// File Name:     spiCore.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       19.09.2016 - 0.1, created
//       21.09.2016 - 0.2, added base functionality
//--------------------------------------------------------------------------------
// SPI slave core
// sync to external spi clock
//--------------------------------------------------------------------------------
module spiCore
  #( parameter logic CPOL,                          // spi clock polarity mode
               logic CPHA,                          // spi clock phase mode
               int   DATA_WDT )                     // data width in bits                    
   ( input  logic                      reset,       // async reset
               
     input  logic                      ssel,        // active low slave select signal
     input  logic                      sclk,        // spi clock
     input  logic                      mosi,        // master out, slave in data line
     output logic                      miso,        // master in,  slave out data line
     
     // txLoad - transition low-high when txData is loaded to internal register
     output logic                      txLoadFirst, // first word is loaded, for start signal
     output logic                      txLoadNext,  // next words
     input  logic [ DATA_WDT - 1 : 0 ] txData,      // transmit data to master
     output logic                      rxRdy,       // transition high-low when rxData is ready    
     output logic [ DATA_WDT - 1 : 0 ] rxData );    // receive data from master

   // active reset depending on reset and ssel
   logic  actRes;
   assign actRes = reset | ssel;
   
   // normalize sclk based on CPOL parameter
   logic  sclkNorm;
   assign sclkNorm = ( CPOL ) ? ~sclk : sclk;

   localparam int CNT_WDT = $clog2( DATA_WDT );
   logic [ DATA_WDT - 2 : 0 ] txShift;
   logic [  CNT_WDT - 1 : 0 ] txCnt;
   logic                      txBitNext;  // skip first clock for CPHA = 1'b1
   logic                      txWordNext; // txLoadFirst or txLoadNext
   
   // slave data output service ( transmit )
   logic  clkMiso;
   assign clkMiso = ( CPHA ) ? sclkNorm : ~sclkNorm;
   
   always_ff @( posedge actRes, posedge clkMiso )
      if ( actRes ) begin
         txLoadFirst <= 1'b0;
         txLoadNext  <= 1'b0;
         txShift     <= '0;
         txCnt       <= '0;
         txBitNext   <= ~CPHA;
         txWordNext  <= 1'b0;
      end else begin        
         if ( ~txBitNext ) begin // skip first clock for CPHA = 1'b1
            txBitNext <= 1'b1;
         end else begin
            txCnt <= txCnt + 1'd1;
            if ( ~|txCnt ) begin // = 0
               if ( ~txWordNext )
                  txLoadFirst <= 1'b1;
               else
                  txLoadNext  <= 1'b1;
               txWordNext <= 1'b1;
               txShift    <= txData[ DATA_WDT - 2 : 0 ];                           
            end else begin
               txShift <= { txShift[ DATA_WDT - 3 : 0 ], 1'b0 };
               if ( txCnt == DATA_WDT / 2 ) begin
                  txLoadFirst <= 1'b0;      
                  txLoadNext  <= 1'b0;
               end
               if ( txCnt == DATA_WDT - 1 ) begin
                  txCnt  <= '0;               
               end
            end
         end
      end
   assign miso = ( actRes  ) ? 1'bz :
                 ( ~|txCnt ) ? txData[ DATA_WDT - 1 ] :
                 txShift[ DATA_WDT - 2 ];
    
   logic [ DATA_WDT - 2 : 0 ] rxShift;
   logic [  CNT_WDT - 1 : 0 ] rxCnt;   
   
   // slave data input service ( receive )
   logic clkMosi;
   assign clkMosi = ( CPHA ) ? ~sclkNorm : sclkNorm;
   
   always_ff @( posedge actRes, posedge clkMosi )
      if ( actRes ) begin
         rxRdy   <= 1'b0;
         rxShift <= '0;
         rxCnt   <= '0;         
      end else begin
         rxShift <= { rxShift[ DATA_WDT - 3 : 0 ], mosi };
         rxCnt   <= rxCnt + 1'd1;
         if ( ~|rxCnt ) begin // = 0
            rxRdy <= 1'b0;
         end else begin
            if ( rxCnt == DATA_WDT / 2 )
               rxRdy <= 1'b1;
            if ( rxCnt == DATA_WDT - 1 ) begin
               rxRdy  <= 1'b0;
               rxCnt  <= '0;
               rxData <= { rxShift, mosi };
            end
         end         
      end
   
endmodule