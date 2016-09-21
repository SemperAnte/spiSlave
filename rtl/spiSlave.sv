//--------------------------------------------------------------------------------
// File Name:     spiCore.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       21.09.2016 - 0.1, created
//--------------------------------------------------------------------------------
// SPI slave interface
//--------------------------------------------------------------------------------
module spiSlave
  #( parameter logic CPOL     = 1'b0,              // spi clock polarity mode
               logic CPHA     = 1'b0,              // spi clock phase mode
               int   DATA_WDT = 8 )                // data width in bits                    
   ( input  logic                       clk,
     input  logic                       reset,     // async reset
     
     // spi line
     input  logic                       ssel,      // active low slave select signal
     input  logic                       sclk,      // spi clock
     input  logic                       mosi,      // master out, slave in data line
     output logic                       miso,      // master in,  slave out data line
     
     // part sync with clk
     output logic                       spiBusy,   // high when spi is busy ( ssel low )
     output logic                       spiStart,  // tick when transfer start
     output logic                       spiEnd,    // tick when transfer end
     output logic                       spiTxLoad, // tick when txData is loaded, insert next data here
     output logic                       spiRxRdy,  // tick when rxData is rdy
     
     input  logic  [ DATA_WDT - 1 : 0 ] spiTxData,
     output logic  [ DATA_WDT - 1 : 0 ] spiRxData  );

   logic asyncTxLoad;
   logic asyncRxRdy;
   
   // spi line control
   spiCore 
      #( .CPOL     ( CPOL     ),   
         .CPHA     ( CPHA     ),
         .DATA_WDT ( DATA_WDT ) )      
   spiCoreInst
       ( .reset   ( reset       ),          
         .ssel    ( ssel        ),
         .sclk    ( sclk        ),
         .mosi    ( mosi        ),
         .miso    ( miso        ),     
         .txLoad  ( asyncTxLoad ),
         .txData  ( spiTxData   ),
         .rxRdy   ( asyncRxRdy  ),
         .rxData  ( spiRxData   ) );
         
   // spi synchronizer to internal clock
   spiSync spiSyncInst
      ( .clk         ( clk         ), 
        .reset       ( reset       ),       
        .ssel        ( ssel        ),
        .asyncTxLoad ( asyncTxLoad ),
        .asyncRxRdy  ( asyncRxRdy  ),
        .spiBusy     ( spiBusy     ),
        .spiStart    ( spiStart    ),
        .spiEnd      ( spiEnd      ),
        .spiTxLoad   ( spiTxLoad   ),
        .spiRxRdy    ( spiRxRdy    ) );   
   
endmodule