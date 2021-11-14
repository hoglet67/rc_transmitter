`timescale 1ns/1ns

module test_transmitter();

   reg clock = 0;
   reg sw1 = 0;
   reg sw2 = 0;
   reg sw3 = 0;
   wire transmit;
   wire rf;

   // Test at 10MHz
   always #(50) clock = ~clock;
   transmitter #(10) u1(clock, sw1, sw2, sw3, transmit, rf);

   // Test for 100ms
   initial begin
      $dumpvars();
      # 100000000;
      $finish;
   end

endmodule
