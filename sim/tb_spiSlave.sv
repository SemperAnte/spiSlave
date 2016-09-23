//--------------------------------------------------------------------------------
// File Name:     tb_spiSlave.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       19.09.2016 - 0.1, created
//       23.09.2016 - 0.2, auto-checking
//--------------------------------------------------------------------------------
// SPI slave testbench
//--------------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module tb_spiSlave ();

   localparam int T_CLK  = 10;
   
   localparam logic CPOL     = 1'b1; // spi clock polarity mode
   localparam logic CPHA     = 1'b1; // spi clock phase mode
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
   logic [ DATA_WDT - 1 : 0 ] spiTxData = $urandom();           
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
   
   logic [ DATA_WDT - 1 : 0 ] masterTxData, masterTxDataPrev;
   logic [ DATA_WDT - 1 : 0 ] masterRxData;
   logic                      masterRxRdy = 1'b0;
   // write and read through spi random data ( spi master emulation )
   task spiMasterRandom ( realtime T_SCLK   = 20,
                          int      BYTE_NUM = 2 );                        
      logic [ DATA_WDT - 1 : 0 ] txData;
      logic [ DATA_WDT - 1 : 0 ] rxData; 
      
      if ( CPHA ) begin // CPHA = 1'b1
         ssel = 1'b0;
         sclk = CPOL;
         mosi = 1'bx;
         
         for ( int spiWord = 0; spiWord < BYTE_NUM; spiWord++ ) begin
            txData = $urandom();            
            masterTxData = txData;
            for ( int spiBit = 0; spiBit < DATA_WDT; spiBit++ ) begin
               # ( T_SCLK / 2 ); 
               sclk = ~sclk;
               mosi = txData[ DATA_WDT - 1 - spiBit ];
               # ( T_SCLK / 2 );
               sclk = ~sclk;
               rxData[ DATA_WDT - 1 - spiBit ] = miso;
            end
            masterRxData = rxData;
            masterRxRdy  = 1'b1;
            masterRxRdy <= #T_CLK 1'b0;
            masterTxDataPrev = masterTxData;
         end         
         
         # ( T_SCLK / 2 );
         ssel = 1'b1;
         mosi = 1'bz;
         
      end else begin // CPHA = 1'b0
         ssel   = 1'b0;
         sclk   = CPOL;
         
         for ( int spiWord = 0; spiWord < BYTE_NUM; spiWord++ ) begin
            txData = $urandom();            
            masterTxData = txData;
            for ( int spiBit = 0; spiBit < DATA_WDT; spiBit++ ) begin
               mosi = txData[ DATA_WDT - 1 - spiBit ];
               # ( T_SCLK / 2 );
               sclk = ~sclk;
               rxData[ DATA_WDT - 1 - spiBit ] = miso;
               # ( T_SCLK / 2 );
               sclk = ~sclk;
            end
            masterRxData = rxData;
            masterRxRdy  = 1'b1;
            masterRxRdy <= #T_CLK 1'b0;
            masterTxDataPrev = masterTxData;
         end
         
         mosi = 1'bx;
         #( T_SCLK / 2 );
         ssel = 1'b1;
         mosi = 1'bz;         
      end

   endtask
   
   initial begin
      logic [ DATA_WDT - 1 : 0 ] data;
      
      @ ( negedge reset );
      # ( 10 * T_CLK );
      
      repeat ( 5 ) begin
         spiMasterRandom( $urandom_range( 20, 5 ), $urandom_range( 5, 1 ) );      
         # ( $urandom_range( 10, 2 ) * T_CLK );
      end
      
   end
   
   logic [ DATA_WDT - 1 : 0 ] spiTxDataPrev;
   always_ff @( negedge spiTxLoad )
   begin
      spiTxData     <= $urandom();
      spiTxDataPrev <= spiTxData;
   end
   
   always_ff @( posedge masterRxRdy )
      if ( spiTxDataPrev != masterRxData )
         $warning( "slave tx / master rx  data : not equal : %b / %b", spiTxDataPrev, masterRxData );
      else
         $display( "slave tx / master rx  data : correct" );
         
   always_ff @( posedge spiRxRdy )
      if ( spiRxData != masterTxDataPrev )
         $warning( "slave rx / master tx  data : not equal : %b / %b", spiRxData, masterTxDataPrev );
      else
         $display( "slave rx / master tx  data : correct" );
   
   
endmodule