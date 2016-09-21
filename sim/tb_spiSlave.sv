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

   localparam int T_CLK  = 10;
   
   localparam logic CPOL     = 1'b0; // spi clock polarity mode
   localparam logic CPHA     = 1'b0; // spi clock phase mode
   localparam int   DATA_WDT = 8;    // data width in bits     

   logic                      clk;
   logic                      reset;         // async reset      
   logic                      ssel = 1'b1;   // active low slave select signal
   logic                      sclk = CPOL;   // spi clock
   logic                      mosi = 1'bz;   // master out, slave in data line
   logic                      miso;          // master in, slave out data line   
   logic                      spiBusy; 
   logic                      spiStart;
   logic                      spiEnd;  
   logic                      spiTxLoad;
   logic                      spiRxRdy;     
   logic [ DATA_WDT - 1 : 0 ] spiTxData;           
   logic [ DATA_WDT - 1 : 0 ] spiRxData;                     

   spiSlave
     #( .CPOL     ( CPOL     ),
        .CPHA     ( CPHA     ),
        .DATA_WDT ( DATA_WDT ) )
   uut
      ( .clk       ( clk       ),
        .reset     ( reset     ),      
        .ssel      ( ssel      ),
        .sclk      ( sclk      ),
        .mosi      ( mosi      ),
        .miso      ( miso      ),
        .spiBusy   ( spiBusy   ),
        .spiStart  ( spiStart  ),
        .spiEnd    ( spiEnd    ),
        .spiTxLoad ( spiTxLoad ),
        .spiRxRdy  ( spiRxRdy  ),
        .spiTxData ( spiTxData ),
        .spiRxData ( spiRxData ) );
      
   always begin   
      clk = 1'b1;
      #( T_CLK / 2 );
      clk = 1'b0;
      #( T_CLK / 2 );
   end
   
   initial begin   
      reset = 1'b1;
      #( 10 * T_CLK + T_CLK / 2 );
      reset = 1'b0;
   end
   
   logic [ DATA_WDT - 1 : 0 ] wrData;
   logic [ DATA_WDT - 1 : 0 ] rdData;  
   // write and read through spi random data
   task spiMasterRandom ( realtime T_SCLK   = 20,
                          int      BYTE_NUM = 2 );                        
      
      if ( CPHA ) begin // CPHA = 1'b1
         ssel = 1'b0;
         sclk = CPOL;
         mosi = 1'bx;
         
         for ( int spiWord = 0; spiWord < BYTE_NUM; spiWord++ ) begin
            wrData = $urandom();
            $display( "wrData = %8b", wrData );
            for ( int spiBit = 0; spiBit < DATA_WDT; spiBit++ ) begin
               # ( T_SCLK / 2 ); 
               sclk = ~sclk;
               mosi = wrData[ DATA_WDT - 1 - spiBit ];
               # ( T_SCLK / 2 );
               sclk = ~sclk;
               rdData[ DATA_WDT - 1 - spiBit ] = miso;
            end
         end         
         
         # ( T_SCLK / 2 );
         ssel = 1'b1;
         mosi = 1'bz;
         
      end else begin // CPHA = 1'b0
         ssel   = 1'b0;
         sclk   = CPOL;
         
         for ( int spiWord = 0; spiWord < BYTE_NUM; spiWord++ ) begin
            wrData = $urandom();
            $display( "wrData = %8b", wrData );
            for ( int spiBit = 0; spiBit < DATA_WDT; spiBit++ ) begin
               mosi = wrData[ DATA_WDT - 1 - spiBit ];
               # ( T_SCLK / 2 );
               sclk = ~sclk;
               rdData[ DATA_WDT - 1 - spiBit ] = miso;
               # ( T_SCLK / 2 );
               sclk = ~sclk;
            end
         end
         
         mosi = 1'bx;
         #( T_SCLK / 2 );
         ssel = 1'b1;
         mosi = 1'bz;         
      end

   endtask
   
   initial begin
      logic [ DATA_WDT - 1 : 0 ] data;
      
      spiTxData = 8'b01011011;   
      
      @ ( negedge reset );
      # ( 10 * T_CLK );
      
      spiMasterRandom( 9 );
      
   end
   
endmodule