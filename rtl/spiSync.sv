//--------------------------------------------------------------------------------
// File Name:     spiSync.sv
// Project:       spiSlave
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       21.09.2016 - 0.1, created
//--------------------------------------------------------------------------------
// SPI synchronizer
// synchronize data from external spi clock to internal clock
//--------------------------------------------------------------------------------
module spiSync
  #( parameter int SYNC_DEPTH )        // number of registers in sync chain ( >= 2 )
   ( input  logic  clk,
     input  logic  reset,              // async reset
     
     // part sync with sclk
     input  logic  ssel,               // active low slave select signal     
     input  logic  asyncTxLoadFirst,   // first word is loaded
     input  logic  asyncTxLoadFollow,  // following words are loaded
     input  logic  asyncRxRdy,         // transition high-low when rxData is ready 
     
     // part sync with clk
     output logic  spiBusy,            // high when spi is busy ( ssel low )
     output logic  spiStart,           // tick when transfer start
     output logic  spiEnd,             // tick when transfer end
     output logic  spiTxLoad,          // tick when txData is loaded, insert next data here
     output logic  spiRxRdy );         // tick when rxData is rdy
     
   // check parameters
   initial begin
      if ( SYNC_DEPTH < 2 ) begin
         $error( "Not correct parameter, SYNC_DEPTH" );
         $stop;
      end
   end

   logic [ SYNC_DEPTH : 0 ] syncBusy; // SYNC_DEPTH + 1 for edge detection
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncBusy <= '0;         
      end else begin
         syncBusy <= { syncBusy[ SYNC_DEPTH - 1 : 0 ], ~ssel };
      end         
   assign spiEnd  = syncBusy[ SYNC_DEPTH ] & ~syncBusy[ SYNC_DEPTH - 1 ]; // falling edge ssel
   assign spiBusy = spiStart | syncBusy[ SYNC_DEPTH - 1 ] | spiEnd;
   
   logic [ SYNC_DEPTH : 0 ] syncTxLoadFirst;
   logic [ SYNC_DEPTH : 0 ] syncTxLoadFollow; // following
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncTxLoadFirst  <= '0;
         syncTxLoadFollow <= '0;
      end else begin
         syncTxLoadFirst  <= { syncTxLoadFirst[ SYNC_DEPTH - 1 : 0 ], asyncTxLoadFirst };
         syncTxLoadFollow <= { syncTxLoadFollow [ SYNC_DEPTH - 1 : 0 ], asyncTxLoadFollow  };
      end         
   assign spiStart  = ~syncTxLoadFirst[ SYNC_DEPTH ] & syncTxLoadFirst[ SYNC_DEPTH - 1 ]; // rising edge
   assign spiTxLoad = spiStart | ( ~syncTxLoadFollow[ SYNC_DEPTH ] & syncTxLoadFollow[ SYNC_DEPTH - 1 ] );
   
   logic [ SYNC_DEPTH : 0 ] syncRxRdy;
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncRxRdy <= '0;
      end else begin
         syncRxRdy <= { syncRxRdy[ SYNC_DEPTH - 1 : 0 ], asyncRxRdy };
      end
   assign spiRxRdy = syncRxRdy[ SYNC_DEPTH ] & ~syncRxRdy[ SYNC_DEPTH - 1 ];
   
endmodule