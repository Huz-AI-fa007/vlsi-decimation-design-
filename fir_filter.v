`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 17:22:00
// Design Name: 
// Module Name: fir_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fir_filter(
    input clk,reset,enable,//enable to connect to cic
    input signed[19:0] din,//din input from cic
    output reg signed [19:0]dout,//final flattened output 
    output reg out
    );
//number of coefficients used 
parameter NCOEFF=51;

//delay line and coefficients
reg signed[19:0]shift_reg[0:NCOEFF-1];
wire signed [19:0]coeff[0: NCOEFF-1];
reg signed [47:0]sum;
reg signed [47:0] temp_data;//adding these 2 variables so that when doing the multiplication bits count is same and verilog doesn't truncate bits 
reg signed [47:0] temp_coeff;

//coefficients from matlab 
assign coeff[0]  =  20'sd1122;
assign coeff[1]  = -20'sd389;
assign coeff[2]  =  20'sd453;
assign coeff[3]  = -20'sd520;
assign coeff[4]  =  20'sd590;
assign coeff[5]  = -20'sd662;
assign coeff[6]  =  20'sd737;
assign coeff[7]  = -20'sd812;
assign coeff[8]  =  20'sd889;
assign coeff[9]  = -20'sd964;
assign coeff[10] =  20'sd1038;
assign coeff[11] = -20'sd1110;
assign coeff[12] =  20'sd1177;
assign coeff[13] = -20'sd1239;
assign coeff[14] =  20'sd1293;
assign coeff[15] = -20'sd1337;
assign coeff[16] =  20'sd1367;
assign coeff[17] = -20'sd1378;
assign coeff[18] =  20'sd1360;
assign coeff[19] = -20'sd1298;
assign coeff[20] =  20'sd1158;
assign coeff[21] = -20'sd872;
assign coeff[22] =  20'sd254;
assign coeff[23] =  20'sd1296;
assign coeff[24] = -20'sd6599;
assign coeff[25] =  20'sd43546;
assign coeff[26] = -20'sd6599;
assign coeff[27] =  20'sd1296;
assign coeff[28] =  20'sd254;
assign coeff[29] = -20'sd872;
assign coeff[30] =  20'sd1158;
assign coeff[31] = -20'sd1298;
assign coeff[32] =  20'sd1360;
assign coeff[33] = -20'sd1378;
assign coeff[34] =  20'sd1367;
assign coeff[35] = -20'sd1337;
assign coeff[36] =  20'sd1293;
assign coeff[37] = -20'sd1239;
assign coeff[38] =  20'sd1177;
assign coeff[39] = -20'sd1110;
assign coeff[40] =  20'sd1038;
assign coeff[41] = -20'sd964;
assign coeff[42] =  20'sd889;
assign coeff[43] = -20'sd812;
assign coeff[44] =  20'sd737;
assign coeff[45] = -20'sd662;
assign coeff[46] =  20'sd590;
assign coeff[47] = -20'sd520;
assign coeff[48] =  20'sd453;
assign coeff[49] = -20'sd389;
assign coeff[50] =  20'sd1122;


integer i;
    
    
//fir hardware logic

always@(posedge clk)
begin 
    if(reset)begin 
        for(i=0; i<NCOEFF; i=i+1)begin 
            shift_reg[i]<=0;
        end 
        dout<=0;
        out<=0;
    end else if(enable)begin 
        // Shifting old data backwards (from 150 down to 1)
        for(i=NCOEFF-1; i>0; i=i-1)begin 
            shift_reg[i] <= shift_reg[i-1];
        end
        shift_reg[0] <= din;
        
        //accumulating 
        sum = 0;
        for(i=0; i<NCOEFF; i=i+1)begin 
        temp_data = shift_reg[i];//sign extend 48 bits 
            temp_coeff = coeff[i];//sign extend 48 bits
            sum = sum + (temp_data * temp_coeff);    
        end
        // dividing by 2^15 as when i imported coefficients from matlab i multiplied by 2^15 as numbers wee very small and verilog causes issues in decimal stuff
        dout <= sum[34:15];
        out <= 1;  
    end else begin 
        out <= 0;
    end
end


endmodule
