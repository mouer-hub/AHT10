/*==============================*\
Author:mouer
Description: fpga发送数据
Time: 2022.7.22
\*==============================*/
`include "param.v"
module uart_tx (
    input               clk         ,
    input               rst_n       ,
    input       [1:0]   baud_sel    ,//选择波特率
    input               tx_byte_vld ,//相当于一个发送请求
    input       [7:0]   tx_byte     ,
    output              busy        ,//忙状态指示  握手信号
    output              tx_dout     
); 
//信号定义
//波特率计数
reg    [12:0]   cnt_baud    ;
wire            add_cnt_baud;
wire            end_cnt_baud;
//bit计数
reg    [3:0]    cnt_bit    ;
wire            add_cnt_bit;
wire            end_cnt_bit;
//输出数据寄存
reg             tx_dout_r;
//开始传输数据标志
reg             flag;
//波特率
reg    [12:0]   baud;  
//寄存数据，拼接
reg    [9:0]    data;      
//波特率选择
always @(*)begin 
    case (baud_sel)
        0:baud = `BAUD_9600  ;
        1:baud = `BAUD_19200 ;
        2:baud = `BAUD_38400 ;
        3:baud = `BAUD_115200; 
        default:baud = `BAUD_9600  ;
    endcase
end 

//检测有效数据到来，开始传输标志检测
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        flag<=1'b0;
    end
    else if(tx_byte_vld)begin
        flag<=1'b1;
    end
    else if(end_cnt_bit)
        flag<=1'b0;
    else begin
        flag<=flag; 
    end
end
//寄存数据
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
       data<=1'b0;
    end
    else if(tx_byte_vld)begin
       data<={1'b1,tx_byte,1'b0};  
    end
    else begin
       data<=data; 
    end
end
//波特率计数
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cnt_baud<=1'b0;
    end
    else if(add_cnt_baud)begin
        if(end_cnt_baud)begin
            cnt_baud<=1'b0;
        end
        else begin
            cnt_baud<=cnt_baud+1'b1;
        end
    end
    else begin
        cnt_baud<=cnt_baud;
    end
end
assign add_cnt_baud=flag;
assign end_cnt_baud=add_cnt_baud&&cnt_baud==baud-1 ; 
//比特计数
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cnt_bit<=1'b0;
    end
    else if(add_cnt_bit)begin
        if(end_cnt_bit)begin
            cnt_bit=1'b0;
        end
        else begin
            cnt_bit<=cnt_bit+1'b1;
        end
    end
    else begin
        cnt_bit<=cnt_bit;
    end
end
assign add_cnt_bit= end_cnt_baud;
assign end_cnt_bit=add_cnt_bit&&cnt_bit== 9;

//并串转换
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        tx_dout_r<=1'b1;
    end
    else if(end_cnt_bit)
        tx_dout_r<=1'b1;
    else if(flag)begin
        tx_dout_r<=data[cnt_bit];
    end
    else begin
        tx_dout_r<=1'b1; 
    end
end

//输出
assign tx_dout=tx_dout_r;
assign busy=flag;
endmodule