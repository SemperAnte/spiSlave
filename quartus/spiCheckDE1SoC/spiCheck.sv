//--------------------------------------------------------------------------------
// File Name:     spiCheck.sv
// Project:       spiCheck
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       21.09.2016 - 0.1, created
//--------------------------------------------------------------------------------
// SPI checker
// just send 4 bytes
//--------------------------------------------------------------------------------
module spiCheck               
   ( input  logic                       clk,
     input  logic                       reset,     // async reset
     
     // spi line
     input  logic                       ssel,      // active low slave select signal
     input  logic                       sclk,      // spi clock
     input  logic                       mosi,      // master out, slave in data line
     output logic                       miso,     // master in,  slave out data line
     
     output logic            spiEnd,
     output logic  [ 7 : 0 ] spiRxData );

   localparam logic [ 7 : 0 ] data [ 4 ] = '{ 8'ha2, 8'h37, 8'h27, 8'hf5 };
   
   logic spiStart;
   logic spiTxLoad;
   logic [ 7 : 0 ] spiTxData;
  // logic [ 7 : 0 ] spiRxData;
   logic [ 1 : 0 ] i;
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         spiTxData <= data[ 0 ];
         i         <= 1'd1;
      end else begin
         if ( spiStart ) begin
            spiTxData <= data[ 0 ];
            i <= 1'd1;
         end
         if ( spiTxLoad ) begin
            spiTxData <= data[ i ];
            i         <= i + 1'd1;
         end
      end
   
   // spi slave
   spiSlave
      #( .CPOL     ( 1'b1 ),   
         .CPHA     ( 1'b1 ),
         .DATA_WDT ( 8    ) )      
   spiSlaveInst
       ( .clk       ( clk       ),
         .reset     ( reset     ),          
         .ssel      ( ssel      ),
         .sclk      ( sclk      ),
         .mosi      ( mosi      ),
         .miso      ( miso      ),
         .spiEnd    ( spiEnd    ),
         .spiStart  ( spiStart  ),
         .spiTxLoad ( spiTxLoad ),
         .spiTxData ( spiTxData ),
         .spiRxData ( spiRxData ) );
         
endmodule