//--------------------------------------------------------------------------------
// File Name:     spiCheckDE1SoC.sv
// Project:       spiCheck
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       21.09.2016 - 0.1, created
//       18.10.2016 - 0.2, verified in connections with BeagleBone Board and SignalTap
//--------------------------------------------------------------------------------
// DE1-SoC board wrapper
// SPI checker
//--------------------------------------------------------------------------------
module spiCheckDE1SoC              
    ( input  logic            CLOCK_50,
    
      inout  wire  [ 35 : 0 ] GPIO_0 );   
   
   assign GPIO_0[ 0 ] = 1'b0;
   assign GPIO_0[ 1 ] = 1'b0;

   logic  ssel;
   logic  sclk;
   logic  mosi;
   logic  miso;
   // connection with BeagleBone
   assign ssel = ~GPIO_0[ 14 ]; // inverse
   assign sclk =  GPIO_0[ 19 ];
   assign mosi =  GPIO_0[ 15 ];
   assign GPIO_0[ 18 ] = miso;
   
   // just mark the spot
   logic           spiEnd;
   logic [ 7 : 0 ] spiRxData;
   assign GPIO_0     [ 2 ] = spiEnd;
   assign GPIO_0[ 10 : 3 ] = spiRxData;
   
   spiCheck spiCheckInst
       ( .clk       ( CLOCK_50  ),
         .reset     ( 1'b0      ),          
         .ssel      ( ssel      ),
         .sclk      ( sclk      ),
         .mosi      ( mosi      ),
         .miso      ( miso      ),
         .spiEnd    ( spiEnd    ),
         .spiRxData ( spiRxData ) );
         
endmodule