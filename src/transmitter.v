module transmitter
  (
   input  clock,
   input  sw1,
   input  sw2,
   input  sw3,
   output reg transmit,
   output rf
   );

   parameter FREQ = 27;

   localparam S_C1_OFF = 0;
   localparam S_C1_ON = 1;
   localparam S_C2_OFF = 2;
   localparam S_C2_ON = 3;
   localparam S_SYNC_OFF = 4;
   localparam S_SYNC_ON = 5;

   // Frame time is 20ms
   localparam FRAME_TIME = FREQ *  20000 - 1;

   // Off time is 0.5ms
   localparam OFF_TIME   = FREQ *  500 - 1;

   // On time is 0.5ms -> 1.5ms
   // (i.e. 0.5ms + value * 1.0ms whete value 0..1)
   localparam ON_0_TIME   = FREQ *  500 - 1;
   localparam ON_1_TIME   = FREQ * 1000 - 1;
   localparam ON_2_TIME   = FREQ * 1500 - 1;


   // State machine cycling through the two channels
   reg [2:0] state = S_C1_OFF;

   // Max counter1 is ~20ms * 27MHz = 540,000
   reg [19:0] counter1 = 0;

   // Max counter2 is ~1.5ms * 27MHz = 40,500
   reg [15:0] counter2 = 0;

   reg        c1 = 0;
   reg        c2 = 0;
   reg        c3 = 0;
   reg        c4 = 0;


   assign rf = transmit & clock;

   always @(posedge clock) begin

      c1 <= sw1 & !sw3;
      c2 <= sw2 & !sw3;
      c3 <= sw1 &  sw3;
      c4 <= sw2 &  sw3;

      if (counter1 == 0) begin
         counter1 <= FRAME_TIME;
      end else begin
         counter1 <= counter1 - 1;
      end

      if (counter1 == 0) begin
         state    <= S_C1_OFF;
         counter2 <= OFF_TIME;
         transmit <= 1'b0;
      end else begin
         if (counter2 == 0) begin
            case (state)
              S_C1_OFF:
                begin
                   state <= S_C1_ON;
                   if (c1)
                     counter2 <= ON_0_TIME;
                   else if (c2)
                     counter2 <= ON_2_TIME;
                   else
                     counter2 <= ON_1_TIME;
                   transmit <= 1'b1;
                end
              S_C1_ON:
                begin
                   state <= S_C2_OFF;
                   counter2 <= OFF_TIME;
                   transmit <= 1'b0;
                end
              S_C2_OFF:
                begin
                   state <= S_C2_ON;
                   if (c3)
                     counter2 <= ON_0_TIME;
                   else if (c4)
                     counter2 <= ON_2_TIME;
                   else
                     counter2 <= ON_1_TIME;
                   transmit <= 1'b1;
                end
              S_C2_ON:
                begin
                   state <= S_SYNC_OFF;
                   counter2 <= OFF_TIME;
                   transmit <= 1'b0;
                end
              S_SYNC_OFF:
                begin
                   state <= S_SYNC_ON;
                   transmit <= 1'b1;
                end
              S_SYNC_ON:
                begin
                   counter2 <= 0;
                   transmit <= 1'b1;
                end
            endcase


        end else begin
           counter2 <= counter2 - 1;
        end
      end
   end
endmodule
