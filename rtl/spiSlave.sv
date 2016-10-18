//--------------------------------------------------------------------------------
// File Name:     spiCore.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       21.09.2016 - 0.1, created
//       22.09.2016 - 0.2, base functionality, verified with external arm processor
//       23.09.2016 - 0.3, minor changes in spi core
//--------------------------------------------------------------------------------
// SPI slave interface
//    - spi core sync with spi sclk  
//    - synchronizer to internal clk
//
// for timing diagram and spi description : 
// https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
//--------------------------------------------------------------------------------
module spiSlave                                       
  #( parameter logic CPOL     = 1'b0,                 // spi clock polarity mode
               logic CPHA     = 1'b0,                 // spi clock phase mode
               int   DATA_WDT = 8 )                   // data width in bits                    
   ( input  logic                       clk,          
     input  logic                       reset,        // async reset
                                                      
     // spi line                                      
     input  logic                       ssel,         // active low slave select signal
     input  logic                       sclk,         // spi clock
     input  logic                       mosi,         // master out, slave in data line
     output logic                       miso,         // master in,  slave out data line
                                                      
     // part sync with clk                            
     output logic                       spiBusy,      // high when spi is busy ( ssel low )
     output logic                       spiStart,     // tick when transfer start
     output logic                       spiEnd,       // tick when transfer end
     output logic                       spiTxLoad,    // tick when txData ( data to master ) is loaded, insert next data here
                                                      // first tick at same time with spiStart
     output logic                       spiRxRdy,     // tick when rxData ( data from master ) is rdy
     
     input  logic  [ DATA_WDT - 1 : 0 ] spiTxData,    // data to master   ( miso )
     output logic  [ DATA_WDT - 1 : 0 ] spiRxData  ); // data from master ( mosi )

   logic asyncTxLoadFirst;
   logic asyncTxLoadFollow;
   logic asyncRxRdy;
   
   // spi line control
   spiCore 
      #( .CPOL        ( CPOL     ),   
         .CPHA        ( CPHA     ),
         .DATA_WDT    ( DATA_WDT ) )      
   spiCoreInst
       ( .reset        ( reset             ),          
         .ssel         ( ssel              ),
         .sclk         ( sclk              ),
         .mosi         ( mosi              ),
         .miso         ( miso              ),     
         .txLoadFirst  ( asyncTxLoadFirst  ),
         .txLoadFollow ( asyncTxLoadFollow ),
         .txData       ( spiTxData         ),
         .rxRdy        ( asyncRxRdy        ),
         .rxData       ( spiRxData         ) );
   
   localparam int SYNC_DEPTH = 3; // number of registers in sync chain ( >= 2 )
   // spi synchronizer to internal clock
   spiSync
     #( .SYNC_DEPTH        ( SYNC_DEPTH       ) )
   spiSyncInst
      ( .clk               ( clk               ), 
        .reset             ( reset             ),       
        .ssel              ( ssel              ),
        .asyncTxLoadFirst  ( asyncTxLoadFirst  ),
        .asyncTxLoadFollow ( asyncTxLoadFollow ),
        .asyncRxRdy        ( asyncRxRdy        ),
        .spiBusy           ( spiBusy           ),
        .spiStart          ( spiStart          ),
        .spiEnd            ( spiEnd            ),
        .spiTxLoad         ( spiTxLoad         ),
        .spiRxRdy          ( spiRxRdy          ) );   
   
endmodule