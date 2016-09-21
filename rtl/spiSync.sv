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
   ( input  logic  clk,
     input  logic  reset,        // async reset
     
     // part sync with sclk
     input  logic  ssel,         // active low slave select signal
     input  logic  asyncTxLoad,  // transition low-high when txData is loaded to internal register
     input  logic  asyncRxRdy,   // transition high-low when rxData is ready 
     
     // part sync with clk
     output logic  spiBusy,      // high when spi is busy ( ssel low )
     output logic  spiStart,     // tick when transfer start
     output logic  spiEnd,       // tick when transfer end
     output logic  spiTxLoad,    // tick when txData is loaded, insert next data here
     output logic  spiRxRdy );   // tick when rxData is rdy

   logic [ 3 : 0 ] syncBusy;
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncBusy <= '0;         
      end else begin
         syncBusy <= { syncBusy[ 2 : 0 ], ~ssel };
      end         
   assign spiStart = ~syncBusy[ 3 ] &&  syncBusy[ 2 ];
   assign spiEnd   =  syncBusy[ 3 ] && ~syncBusy[ 2 ];
   assign spiBusy  =  syncBusy[ 2 ] | spiEnd;
   
   logic [ 3 : 0 ] syncTxLoad;
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncTxLoad <= '0;
      end else begin
         syncTxLoad <= { syncTxLoad[ 2 : 0 ], asyncTxLoad };
      end         
   assign spiTxLoad = ~syncTxLoad[ 3 ] && syncTxLoad[ 2 ];
   
   logic [ 3 : 0 ] syncRxRdy;
   always_ff @( posedge reset, posedge clk )
      if ( reset ) begin
         syncRxRdy <= '0;
      end else begin
         syncRxRdy <= { syncRxRdy[ 2 : 0 ], asyncRxRdy };
      end
   assign spiRxRdy = syncRxRdy[ 3 ] && ~syncRxRdy[ 2 ];
   
endmodule