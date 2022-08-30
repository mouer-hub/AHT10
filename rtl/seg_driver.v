/*==============================*\
Author:mouer
Description: 数码管显示
Time:2022.7.30
\*==============================*/

module seg_driver(
	input clk,
	input rst_n,
	input [23:0] din,
	
	output reg[5:0] seg_sel,
	output reg[7:0] seg_dig

);

reg [15:0] cnt_t;    //0.01s计时
reg [2:0]  cnt_scan;//数码管计数
reg [3:0] value;
reg dot;//是否有小数点

wire add_cnt_t;
wire end_cnt_t;
wire add_scan;
wire end_scan;
parameter	 MAX_DELAY=16'd50_0000,//0.01s/10ms
				ZERO	=	7'b100_0000,
				ONE 	=	7'b111_1001,
				TWO     =	7'b010_0100,
				THREE   =	7'b011_0000,
				FOUR	=	7'b001_1001,
				FIVE	=	7'b001_0010,
				SIX	    =	7'b000_0010,
				SEVEN   =	7'b111_1000,
				EIGHT   =	7'b000_0000,
				NINE	=	7'b001_0000,
				A       =   7'b000_1000,
				B		=	7'b000_0011,
				O		=	7'b100_0000,
				U		=	7'b100_0001,
				F		=	7'b111_1111;
 
//数码管延迟计数
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		cnt_t<=1'b0;
	else if(add_cnt_t)
		if(end_cnt_t)
			cnt_t<=1'b0;
		else
			cnt_t<=cnt_t+1'b1;
	else
		cnt_t<=cnt_t;
end
assign add_cnt_t=1'b1;
assign end_cnt_t=add_cnt_t&&cnt_t==MAX_DELAY-1;

//扫描对应数码管计数
always@(posedge clk,negedge rst_n)begin
	if(!rst_n)
		cnt_scan<=1'b0;
	else if(add_scan)
		if(end_scan)
			cnt_scan<=1'b0;
		else
			cnt_scan<=cnt_scan+1'b1;
	else
		cnt_scan<=cnt_scan;
end
assign add_scan=end_cnt_t;
assign end_scan=add_scan&&cnt_scan==3'd5;

//切换数码管位选信号
always@(posedge clk, negedge rst_n)begin
	if(!rst_n)
		seg_sel<=6'b111_110;
	else if(end_cnt_t)
		seg_sel<={seg_sel[4:0],seg_sel[5]};
	else
		seg_sel<=seg_sel;

end

always@(posedge clk,negedge rst_n)begin
	if(!rst_n)begin
		value<=4'b0000;
		dot<=1'b0;
	end	
	else
		case(cnt_scan)
			3'd0:begin value<=din[23:20];	dot<=1'b1;end
			3'd1:begin value<=din[19:16];	dot<=1'b1;end
			3'd2:begin value<=din[15:12];	dot<=1'b1;end
			3'd3:begin value<=din[11:8];	dot<=1'b1;end
			3'd4:begin value<=din[7:4];	dot<=1'b1;end
			3'd5:begin value<=din[3:0];	dot<=1'b1;end
			default:begin value<=0 ;dot<=1'b1;end
		endcase
			
end
always@(posedge clk,negedge rst_n) begin
	if(!rst_n)
		seg_dig<={dot,ZERO};
	else	
		case(value)
			4'd0:seg_dig<={dot,ZERO};
			4'd1:seg_dig<={dot,ONE};
			4'd2:seg_dig<={dot,TWO};
			4'd3:seg_dig<={dot,THREE};
			4'd4:seg_dig<={dot,FOUR};
			4'd5:seg_dig<={dot,FIVE};
			4'd6:seg_dig<={dot,SIX};
			4'd7:seg_dig<={dot,SEVEN};
			4'd8:seg_dig<={dot,EIGHT};
			4'd9:seg_dig<={dot,NINE};
			4'd10:seg_dig<={dot,A};
			4'd11:seg_dig<={dot,B};
			4'd12:seg_dig<={dot,O};
			4'd13:seg_dig<={dot,U};
			4'd14:seg_dig<={dot,F};
			default seg_dig<={dot,ZERO};
		endcase

end

endmodule
