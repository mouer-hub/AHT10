
//i2c命令参数
`define CMD_START   4'b0001
`define CMD_WRITE   4'b0010
`define CMD_READ    4'b0100
`define CMD_STOP    4'b1000

`define CMD_STATE   8'b0111_0001//0x71
`define CMD_INIT    8'b1110_0001//0xE1
`define CMD_INIT_1  8'b0000_1000//0x08
`define CMD_INIT_2  8'b0000_0000//0x00
`define CMD_MEA     8'b1010_1100//0xAC
`define CMD_MEA_1   8'b0011_0011//0x33
`define CMD_MEA_2   8'b0000_0000//0x00
/*==============================*/
//i2c时钟参数
`define  SCL_PERIOD  250
`define  SCL_HALF    125
`define  LOW_HLAF    65 
`define  HIGH_HALF   190
/*==============================*/
//I2C外设地址参数定义
`define     I2C_ADR 7'b0111_000 //0x38  
`define     WR_BIT  1'b0    //bit0
`define     RD_BIT  1'b1    //bit0
/*================================*/
//串口参数定义
`define  BAUD_9600   5208
`define  BAUD_19200  2604
`define  BAUD_38400  1302
`define  BAUD_115200 434
