//--------------------------------------------------------------------------------
// File Name:     spiSlave.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       19.09.2016 - 0.1, created
//--------------------------------------------------------------------------------
// SPI slave
//--------------------------------------------------------------------------------
module spiSlave
  #( parameter logic CPOL     = 1'b1,  // spi clock polarity mode
               logic CPHA     = 1'b1,  // spi clock phase mode
               int   DATA_WDT = 8 )    // data width in bits                    
   ( input  logic                      clk,
     input  logic                      reset,    // async reset
               
     input  logic                      ssel,     // active low slave select signal
     input  logic                      sclk,     // spi clock
     input  logic                      mosi,     // master out, slave in data line
     output logic                      miso,     // master in, slave out data line
     
     input  logic [ DATA_WDT - 1 : 0 ] txData,   //
     output logic                      txLoad,   //
     output logic [ DATA_WDT - 1 : 0 ] rxData,   //  
     output logic                      rxRdy );  //     

   // active reset depending on reset and ssel
   logic actRes;
   assign actRes = reset | ~ssel;
     
   logic [ 7 : 0 ] txWord;
   logic [ 2 : 0 ] txCnt;
   
   logic sclkNorm;
   assign sclkNorm = ( CPOL ) ? ~sclk : sclk;
   logic clkMiso;
   assign clkMiso = ( CPHA ) ? sclkNorm : ~sclkNorm;
   
   // miso service   
   always @( posedge actRes, posedge clkMiso )
      if ( actRes ) begin
         txLoad <= 1'b0;
         txCnt    <= '0;
         txLoad <= 1'b0;
      end else begin
         if ( ~|txCnt ) begin
            txWord   <= txData;
            txLoad <= 1'b1;
         end else begin
            txWord <= { txWord[ DATA_WDT - 2 : 0 ], 1'b0 };
            if ( txCnt == DATA_WDT / 2 )
               txLoad <= 1'b0;
            if ( txCnt == DATA_WDT - 1 )
               txCnt <= '0;
         end            
      end
   assign miso = ( actRes ) ? 1'bz : txWord[ DATA_WDT - 1 ];
   
   logic clkMosi;
   assign clkMosi = ( CPHA ) ? ~sclkNorm : sclkNorm;
   
   logic [ 7 : 0 ] rxWord;
   logic [ 2 : 0 ] rxCnt;
   
   // mosi service
   always @( posedge actRes, posedge clkMosi )
      if ( actRes ) begin
         rxRdy <= 1'b1;
         rxCnt <= '0;
      end else begin
         if ( ~|rxCnt ) begin
            rxRdy <= 1'b1;
         end else begin
            if ( rxCnt == DATA_WDT / 2 )
               rxRdy <= 1'b0;
            if ( rxCnt == DATA_WDT - 1 ) begin
               rxRdy  <= 1'b1;
               rxCnt  <= '0;
               rxData <= rxWord; // !!!
            end
         end
         rxRdy  <= 1'b0;
         rxWord <= { rxWord[ DATA_WDT - 2 : 0 ], mosi };
      end
   
endmodule