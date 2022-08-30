/*==============================*\
Author:
Description: 温湿度传感器控制读写
Time: 2022.7.30
\*==============================*/
`include "param.v"

module AHT10_rw (
    input               clk     ,
    input               rst_n   ,
    
    output      [39:0]  dout    ,//温湿度
    output       reg    dout_vld,

    output              req     ,//操作使能
    output      [3:0]   cmd     ,//操作命令
    output      [7:0]   wr_data ,//写数据
    input       [7:0]   rd_data ,//读数据
    input               done     //传输完成标志
  
);

//参数定义
localparam  WAIT     =8'b0000_0001,//上电等待40ms
            IDLE     =8'b0000_0010,//空闲状态
            CAL_STATE=8'b0000_0100,//判断校验使能
            INIT     =8'b0000_1000,//初始化
            MEASURE  =8'b0001_0000,//触发测量
            MEA_WAIT =8'b0010_0000,//等待测量80ms
            READ     =8'b0100_0000,//读温湿度
            DELAY    =8'b1000_0000;//延时读取

parameter   T_40MS   =21'd2_000_000,//40ms;
            T_80MS   =22'd4_000_000,
            T_DELAY    =28'd50_000_000;

//信号定义
//状态转移
reg    [7:0] state_c;
reg    [7:0] state_n;
//状态条件定义
wire         wait2idle        ;
wire         idle2cal_state   ;
wire         init2cal_state   ;
wire         cal_state2init   ;
wire         cal_state2measure;
wire         measure2mea_wait ;
wire         mea_wait2read    ;
wire         read2delay       ;
wire         delay2idle        ;
//等待时间计数
reg    [27:0]   cnt_ms    ;
wire            add_cnt_ms;
wire            end_cnt_ms;
//字节计数
reg    [4:0]    cnt_byte    ;
wire            add_cnt_byte;
wire            end_cnt_byte;

//task
reg             req_r;
reg    [3:0]    cmd_r;
reg    [7:0]    data_r;
//温湿度数据
reg    [39:0]   data;
//flag1
reg    flag;
reg   [27:0]   TIME;
//状态机 
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        state_c<=WAIT;
    end
    else begin
        state_c<=state_n;
    end
end

always@(*)begin
    case(state_c)
        WAIT:   begin
            if(wait2idle)
                state_n=IDLE;
            else
                state_n=state_c; 
        end
        IDLE:   begin
            if(idle2cal_state)
                state_n=CAL_STATE;
            else
                state_n=state_c;     
        end
        INIT:    begin
            if(init2cal_state)
                state_n=CAL_STATE;
            else
                state_n=state_c;
        end
        CAL_STATE:begin  
            if(cal_state2measure)
                state_n=MEASURE;
            else if(cal_state2init)
                state_n=INIT;
            else
                state_n=state_c;
        end
        MEASURE: begin
            if(measure2mea_wait)
                state_n=MEA_WAIT;
            else
                state_n=state_c;
        end
        MEA_WAIT:begin
            if(mea_wait2read)
                state_n=READ;
            else
                state_n=state_c;
        end
        READ:    begin
            if(read2delay)
                state_n=DELAY;
            else
                state_n=state_c;
        end
        DELAY:  begin
            if(delay2idle)
                state_n=IDLE;
            else
                state_n=state_c;
        end
        default:state_n=WAIT ;
    endcase
end

assign wait2idle          =state_c==WAIT     &&end_cnt_ms    ;
assign idle2cal_state     =state_c==IDLE     &&1'b1          ;
assign init2cal_state     =state_c==INIT     &&end_cnt_byte&&done    ;

assign cal_state2init     =state_c==CAL_STATE&&end_cnt_byte&&~rd_data[3]&&done   ;
assign cal_state2measure  =state_c==CAL_STATE&&end_cnt_byte&&rd_data[3]&&done   ; 

assign measure2mea_wait   =state_c==MEASURE  &&end_cnt_byte&&done    ; 
assign mea_wait2read      =state_c==MEA_WAIT &&end_cnt_ms    ;
assign read2delay         =state_c==READ     &&end_cnt_byte&&done     ;
assign delay2idle         =state_c==DELAY    &&end_cnt_ms     ;

//flag
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        flag<=1'b0;
    end
    else begin
        flag=rd_data&8'd8;
    end
end

//等待时间计数40ms/80ms
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cnt_ms<=1'b0;
    end
    else if(add_cnt_ms)begin
        if(end_cnt_ms)begin
            cnt_ms<=1'b0;
        end
        else begin
            cnt_ms=cnt_ms+1'b1;
        end
    end
    else begin
        cnt_ms<=cnt_ms;
    end
end
assign add_cnt_ms=state_c==WAIT||state_c==MEA_WAIT||state_c==DELAY;
assign end_cnt_ms=add_cnt_ms&&cnt_ms==TIME ;

always@(*)begin
    if(state_c==WAIT)begin
        TIME=T_40MS;
    end
    else if(state_c==MEA_WAIT)begin
        TIME=T_80MS; 
    end
    else if(state_c==DELAY)begin
        TIME=T_DELAY;
    end
    else
        TIME=0;
end
//字节计数

always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        cnt_byte<=1'b0;
    end
    else if(add_cnt_byte)begin
        if(end_cnt_byte)begin
            cnt_byte<=1'b0;
        end
        else begin
            cnt_byte<=cnt_byte+1'b1;
        end
    end
    else begin
        cnt_byte<=cnt_byte;
    end
end
assign add_cnt_byte=(state_c==CAL_STATE||state_c==INIT ||state_c==MEASURE||state_c==READ)&&done;
assign end_cnt_byte=add_cnt_byte&&cnt_byte==(state_c==READ?7:4)-1;


//读写字节输出
always@(*)begin
    // if(!rst_n)begin
    //     TX(1'b0,4'b0,8'b0);
    // end
    if(state_c==CAL_STATE)begin
         case (cnt_byte)
            0:TX(1'b1,{`CMD_START|`CMD_WRITE},{`I2C_ADR,`WR_BIT});//发起始位，发写控制字
            1:TX(1'b1,{`CMD_WRITE},`CMD_STATE);//发命令 0x71
            2:TX(1'b1,{`CMD_START|`CMD_WRITE},{`I2C_ADR,`RD_BIT});////发起始位，发读控制字
            3:TX(1'b1,{`CMD_READ|`CMD_STOP},0);//读数据，发停止位 
            default: TX(1'b0,{`CMD_READ},0);//
         endcase
    end
    else if(state_c==INIT)begin
         case(cnt_byte)
            0:TX(1'b1,{`CMD_START|`CMD_WRITE},{`I2C_ADR,`WR_BIT});//发起始位，发写控制字
            1:TX(1'b1,{`CMD_WRITE},`CMD_INIT);//发命令 0xE1
            2:TX(1'b1,{`CMD_WRITE},{`CMD_INIT_1});//发init参数第一字节
            3:TX(1'b1,{`CMD_WRITE|`CMD_STOP},{`CMD_INIT_2});//发init参数第二字节,发停止位
            default: TX(1'b0,{`CMD_READ},0);
         endcase
    end
    else if(state_c==MEASURE)begin
          case(cnt_byte)
            0:TX(1'b1,{`CMD_START|`CMD_WRITE},{`I2C_ADR,`WR_BIT});//发起始位，发写控制字
            1:TX(1'b1,{`CMD_WRITE},`CMD_MEA);//发命令 0xAC
            2:TX(1'b1,{`CMD_WRITE},{`CMD_MEA_1});//发init参数第一字节
            3:TX(1'b1,{`CMD_WRITE|`CMD_STOP},{`CMD_MEA_2});//发init参数第二字节,发停止位
            default: TX(1'b0,{`CMD_READ},0);
         endcase
    end
    else if(state_c==READ)begin
        case (cnt_byte)
            // 0:TX(1'b1,{`CMD_START|`CMD_WRITE},{`I2C_ADR,`WR_BIT});//发起始位，发写控制字
            // 1:TX(1'b1,{`CMD_WRITE},`CMD_STATE);//发命令 0x71
            0:TX(1'b1,{`CMD_START| `CMD_WRITE},{`I2C_ADR,`RD_BIT});////发起始位，发读控制字
            1:TX(1'b1,{`CMD_READ},0);//读数据 读状态
            2:TX(1'b1,{`CMD_READ},0);//读数据  湿度数据
            3:TX(1'b1,{`CMD_READ},0);//读数据  湿度数据
            4:TX(1'b1,{`CMD_READ},0);//读数据  湿度 温度数剧
            5:TX(1'b1,{`CMD_READ},0);//读数据  温度数据
            6:TX(1'b1,{`CMD_READ|`CMD_STOP},0);//读数据 温度数据，发停止位
            default: TX(1'b0,{`CMD_READ},0);//读
        endcase
    end
    else begin
         TX(1'b0,cmd_r,data_r);
    end
end
//任务
task TX;
    input req1;
    input [3:0] cmd1;
    input [7:0] data1;
    begin
        req_r=req1;
        cmd_r=cmd1;
        data_r=data1;
    end
endtask

//接收数据
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
         data<=40'd0;
    end
    else if(state_c==READ&&done&&cnt_byte>1&&cnt_byte<7)begin
         data<={data[31:0],rd_data};
    end
    else begin
         data<=data;
    end
end
always@(posedge clk,negedge rst_n)begin
    if(!rst_n)begin
        dout_vld<=1'b0;
    end
    else if(state_c==READ&&done&&end_cnt_byte)begin
        dout_vld<=1'b1; 
    end
    else begin
        dout_vld<=1'b0;  
    end
end
//输出
assign dout=data;
// assign dout_vld=state_c==READ&&done&&end_cnt_byte;
assign req=req_r;
assign cmd=cmd_r;
assign wr_data=data_r;
endmodule

