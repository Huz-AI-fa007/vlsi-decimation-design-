`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.10.2026 11:53:10
// Design Name: 
// Module Name: cic_filter
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


module cic_filter(
    input clk,reset,//fast clk 4.1mhz one 
    input wire signed [1:0]din, // 2's compliment wrap around so that accumulator doesn't break
    output  wire signed [19:0] dout,
    output reg out_ready
    );
    
//integrator stage 
//using Hogenauer's bound bit-growth we need 24 registers to store things and prevent from overflow


reg signed[23:0] int1,int2;
always@(posedge clk)
begin 
    if(reset)begin 
    int1<=0;
    int2<=0;
    end
    else begin 
    //we declared evrything as signed so it will handle wrap around 
    int1<=int1+din;
    int2<=int2+int1;
    end  
end 

//decimator ,changing 4.096mhz to 2khz coz nyquist is around 2khz for 990 so we consider 2khz 

reg [10:0] count;
reg decimation;

always@(posedge clk)begin 
    if(reset)begin 
        count<=0;
        decimation<=0;
    end 
    else begin 
    if(count==11'd2047)begin 
    count<=0;
    decimation<=1;
    end else begin 
        count<=count+1;
        decimation<=0;
    end
    end 
end 

//comb stage substracting y[n]-y[n-m]

reg signed [23:0] delay1,delay2;//variable to store y[n-2048] as we are doing only one step one so it will hold value before 2048 cycles 
reg signed[23:0] comb1,comb2;//this will hold the substracted value 
// we used 2 of them here same reason as above for better outputs 
always@(posedge clk)begin 
    if(reset) begin 
        delay1<=0;delay2<=0;
        comb1<=0;comb2<=0;out_ready<=0;
    end else if(decimation)begin 
        delay1<=int2;
        comb1<=int2-delay1;
        
        delay2<=comb1;
        comb2<=comb1-delay2;
        
        out_ready<=1;// to signal that  a validdecimated output is ready
    end else begin 
        out_ready<=0;
    end
    end
    
 //output we take are the 20 bits from the 24 which will contain the msb as it provides more info than the lower ones
 assign dout =comb2[23:4]; 
endmodule
