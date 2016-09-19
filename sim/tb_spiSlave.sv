//--------------------------------------------------------------------------------
// File Name:     tb_spiSlave.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       19.09.2016 - 0.1, created
//--------------------------------------------------------------------------------
// SPI slave testbench
//--------------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module tb_spiSlave ();

   localparam int T = 10;
   
   localparam logic CPOL     = 1'b1; // spi clock polarity mode
   localparam logic CPHA     = 1'b1; // spi clock phase mode
   localparam int   DATA_WDT = 8;    // data width in bits     

   logic                      clk;
   logic                      reset;         // async reset      
   logic                      ssel = 1'b1;   // active low slave select signal
   logic                      sclk = CPOL;   // spi clock
   logic                      mosi = 1'b1;   // master out, slave in data line
   logic                      miso;          // master in, slave out data line   
   logic [ DATA_WDT - 1 : 0 ] txData;        //
   logic                      txLoad;        //
   logic [ DATA_WDT - 1 : 0 ] rxData;        //  
   logic                      rxRdy;         //   

   spiSlave uut
      ( .clk    ( clk    ),
        .reset  ( reset  ),      
        .ssel   ( ssel   ),
        .sclk   ( sclk   ),
        .mosi   ( mosi   ),
        .miso   ( miso   ),
        .txData ( txData ),
        .txLoad ( txLoad ),
        .rxData ( rxData ),
        .rxRdy  ( rxRdy  ) );
      
   always begin   
      clk = 1'b1;
      #( T / 2 );
      clk = 1'b0;
      #( T / 2 );
   end
   
   initial begin   
      reset = 1'b1;
      #( 10 * T + T / 2 );
      reset = 1'b0;
   end
   
endmodule