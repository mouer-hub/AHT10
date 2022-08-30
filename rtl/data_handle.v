/*==============================*\
Author:mouer
Description: 数据处理
Time:2022.7.30
\*==============================*/
module data_handle(
    input            clk,
    input            rst_n,

    input   [39:0]   din,//温湿度数据
    input            din_vld,
   
    output  [23:0]   dout  ,//输出到数码管数据
    input            busy,  //串口发送忙标志
    output           tx_byte_vld,//数据有效标志
    output  [7:0]    tx_byte  //发送到串口数据
);

reg [39:0] data;
wire [30:0] temp;//温度
wire [30:0] humi;//湿度
wire [7:0] t1;
wire [7:0] t2;
wire [7:0] t3;
wire [7:0] h1;
wire [7:0] h2;
wire [7:0] h3;

reg  [7:0] tx;
reg    [4:0]    cnt    ;
wire            add_cnt;
wire            end_cnt;
reg flag;
// wire [19:0] humi_r;
// wire [19:0] temp_r;
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        data<=1'b0;
    end
    else if(din_vld)begin
        data<=din; 
    end
    else begin
        data<=data; 
    end
end

assign humi = ((data[39:20] << 9)
                        +(data[39:20] << 8)
                        +(data[39:20] << 7)
                        +(data[39:20] << 6)
                        +(data[39:20] << 5)
                        +(data[39:20] << 3)) >> 20;
    

assign temp = (((data[19:0] << 10)
                            +(data[19:0] << 9)
                            +(data[19:0] << 8)
                            +(data[19:0] << 7)
                             +(data[19:0] << 6)
                            +(data[19:0] << 4))>> 20 ) - 500;

// assign humi_r=data[39:20];
// assign temp_r=data[19:0];
// assign humi=(humi_r*1000)>>12;
// assign temp=(temp_r*2000)>>12-500;


assign t1[3:0]=temp/100&10;
assign t2[3:0]=temp/10%10;
assign t3[3:0]=temp%10;
assign h1[3:0]=humi/100%10;
assign h2[3:0]=humi/10%10;
assign h3[3:0]=humi%10;

assign dout={4'b1010,t1[3:0],t2[3:0],4'b1011,h1[3:0],h2[3:0]};

assign tx_byte=tx;
assign tx_byte_vld=add_cnt;


always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cnt<=1'b0;
    end
    else if(add_cnt)begin
        if(end_cnt)begin
            cnt<=1'b0;
        end
        else begin
            cnt<=cnt+1'b1;
        end
    end
    else begin
        cnt<=cnt;
    end
end
assign add_cnt= flag&&!busy;
assign end_cnt=add_cnt&&cnt==11 ;
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        flag<=1'b0;
    end
    else if(din_vld)begin
        flag<=1'b1; 
    end
    else if(end_cnt)
        flag<=1'b0;
    else begin
        flag<=flag; 
    end
end


always@(*)begin
    // if(!rst_n)begin
    //     tx<=0;
    // end
    if(flag)begin
         case(cnt)
            0: tx<=t1+8'd48;
            1: tx<=t2+8'd48;
            2: tx<=8'd46;
            3: tx<=t3+8'd48;
            4: tx<=8'ha1;
            5: tx<=8'he6;
            6: tx<=8'd32;//空格
            7: tx<=h1+8'd48;
            8: tx<=h2+8'd48;
            9: tx<=8'd46;
            10: tx<=h3+8'd48;
            11:tx<=8'd37;
            default:tx<=0;
         endcase
    end
end
endmodule