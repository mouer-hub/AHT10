`timescale 1ns/1ns
/*==============================*\
Author:
Description: 
Time:
\*==============================*/
module top_tb();
  reg clk;
  reg rst_n;

  wire [5:0] seg_sel;
  wire [7:0] seg_dig;
  wire scl;
  wire  sda;
  reg sda_r;

  parameter CYCLE=20;
  defparam  u_top.u_controler.u_rw_ctrl.T_40MS=10;
  defparam  u_top.u_controler.u_rw_ctrl.T_80MS=20;
  defparam  u_top.u_controler.u_rw_ctrl.T_DELAY=20;
  always #(CYCLE/2) clk=~clk;

  initial begin
    clk=1'b1;
    rst_n=1'b1;
    #(CYCLE);
    rst_n=1'b0;
    #(CYCLE);
    rst_n=1'b1;
  
    sda_r=1'b1;
  
  end  
assign sda=sda_r;
top u_top(
    /*input   */.clk    (clk),
    /*input   */.rst_n  (rst_n),

    /*output  [5:0] */.seg_sel(seg_sel),
    /*output  [7:0] */.seg_dig(seg_dig),
    /*//i2c
    /*output  */.scl (scl),
    /*inout   */.sda (sda),
        //uart
    /*input   */. rx(rx),
    /*output  */. tx(tx)
);
endmodule