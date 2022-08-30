/*==============================*\
Author:mouer
Description: 控制模块
Time:2022.7.30
\*==============================*/
module controler 
(
    input               clk     ,
    input               rst_n   ,

    output      [39:0]   dout    ,//温湿度数据
    output              dout_vld,//数据有效
    //mem port
    output              i2c_scl ,//i2c时钟总线
    inout               i2c_sda  //i2c数据总线
);
 //信号定义

   wire             req             ; 
   wire     [3:0]   cmd             ; 
   wire     [7:0]   wr_data         ; 
   wire     [7:0]   rd_data         ; 
   wire             done            ; 
   wire             slave_ack       ;
   wire             i2c_sda_i       ; 
   wire             i2c_sda_o       ; 
   wire             i2c_sda_oe      ; 
    

//模块例化

    AHT10_rw u_rw_ctrl(
    /*input               */.clk     (clk       ),
    /*input               */.rst_n   (rst_n     ),

    /*output      [39:0]   */.dout    (dout      ),//控制器输出数据
    /*output              */.dout_vld(dout_vld  ),
    /*output              */.req     (req       ),
    /*output      [3:0]   */.cmd     (cmd       ),
    /*output      [7:0]   */.wr_data (wr_data   ),
    /*input       [7:0]   */.rd_data (rd_data   ),
    /*input               */.done    (done      )//传输完成标志
//    /*input               */.ack     (slave_ack ) //i2c从机应答位    
    );

    i2c_master u_i2c(
    /*input               */.clk         (clk       ),
    /*input               */.rst_n       (rst_n     ),

    /*input               */.req         (req       ),
    /*input       [3:0]   */.cmd         (cmd       ),
    /*input       [7:0]   */.din         (wr_data   ),

    /*output      [7:0]   */.dout        (rd_data   ),
    /*output              */.done        (done      ),
    /*output              */.slave_ack   (slave_ack ),

    /*output              */.i2c_scl     (i2c_scl   ),
    /*input               */.i2c_sda_i   (i2c_sda_i ),
    /*output              */.i2c_sda_o   (i2c_sda_o ),
    /*output              */.i2c_sda_oe  (i2c_sda_oe)   
    );

    assign i2c_sda = i2c_sda_oe?i2c_sda_o:1'bz;
    assign i2c_sda_i = i2c_sda;
    
endmodule