/*==============================*\
Author:mouer
Description: 顶层
Time:2022.7.30
\*==============================*/
module top(
    input    clk,
    input    rst_n,
    
    //数码管
    output   [5:0] seg_sel,//片选信号
    output   [7:0] seg_dig,//位选信号
    //i2c
    output   scl,//i2c时钟总线
    inout    sda,//i2c数据总线
    //uart
    input    rx,
    output   tx
);
//信号定义
wire  [39:0]  dout;
wire          dout_vld;
wire  [23:0]  din;
wire  [7:0]   tx_byte;
wire          busy;
wire          tx_byte_vld;
data_handle u_data_handle(
   /*input           */.clk     (clk),
   /*input           */.rst_n   (rst_n),

   /*input   [39:0]  */.din     (dout),
   /*input           */.din_vld (dout_vld),

   /*output  [23:0]  */.dout    (din),
                       .busy    (busy),
                       .tx_byte_vld (tx_byte_vld),
                       .tx_byte     (tx_byte)  
);



seg_driver u_seg_driver(
	/*input            */.clk     (clk),
	/*input            */.rst_n   (rst_n),
	/*input [23:0]     */.din     (din),

	/*output reg[5:0]  */.seg_sel (seg_sel),
	/*output reg[7:0]  */.seg_dig (seg_dig)

);    

controler  u_controler
(
    /*input               */.clk     (clk),
    /*input               */.rst_n   (rst_n) ,

    /*//user port*/
    /*output      [39:0]  */. dout   (dout)  ,
    /*output              */.dout_vld(dout_vld),
    /*//mem port*/
    /*output              */.i2c_scl (scl),
    /*inout               */.i2c_sda (sda)
); 
uart_tx u_uart_tx(
    /*input               */.clk         (clk        ),
    /*input               */.rst_n       (rst_n      ),
    /*input       [1:0]   */.baud_sel    (2'd3   ),//选择波特率
    /*input               */.tx_byte_vld (tx_byte_vld),//相当于一个发送请求
    /*input       [7:0]   */.tx_byte     (tx_byte    ),
    /*output              */.busy        (busy       ),//忙状态指示  握手信号
    /*output              */.tx_dout     (tx_dout    )
);
assign tx=tx_dout;
endmodule