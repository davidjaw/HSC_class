`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:31 10/22/2015 
// Design Name: 
// Module Name:    yo 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module yo( clk, rst, LED, sw, btnD, btnR, btnU, btnL);

input clk, rst, btnD, btnR, btnU, btnL;
input [7:0] sw;
output reg [7:0] LED;

reg [26:0] cont;
reg tri_cont;
// 除頻 100M = 27'b 101,1111,0101,1110,0001,0000,0000
always@(posedge clk, posedge rst)
  if(rst) begin
    tri_cont <= 0;
    cont <= 0;
  end
  else begin
    tri_cont <= ( cont[25] )? 1 : 0;
    cont <= (cont[25])? 0 : cont + 1;
  end

reg [1:0] state;
reg [1:0] q1_state;

parameter question_1 = 2'b00;
parameter question_2 = 2'b01;
parameter question_3 = 2'b10;
always@(posedge clk, posedge rst)
  if(rst) begin
    state <= question_1;
  end
  else if(tri_cont) begin
    case(state)
      2'b00: begin
        state <= (q1_state == 2'b10)? question_2 : question_1;
      end
      2'b01: begin
        state <= (sw[7] == 1)? question_3 : question_2;
      end
      2'b10: begin
        state <= question_3;
      end
    endcase
  end

reg [2:0] q1_cont;

wire [1:0] sw_S, sw_E, sw_N, sw_W;
wire argueS, argueE, argueN, argueW;
assign argueS = ((( 2'b00 != sw_E ) && ( 2'b00 != sw_N ) && ( 2'b00 != sw_W )) || 
                  (( 2'b00 != sw_S ) && ( 2'b00 != sw_N ) && ( 2'b00 != sw_W )) ||
                  (( 2'b00 != sw_E ) && ( 2'b00 != sw_S ) && ( 2'b00 != sw_W )) ||
                  (( 2'b00 != sw_E ) && ( 2'b00 != sw_N ) && ( 2'b00 != sw_S )) )? 1:0;
assign argueE =  ((( 2'b01 != sw_E ) && ( 2'b01 != sw_N ) && ( 2'b01 != sw_W )) || 
                  (( 2'b01 != sw_S ) && ( 2'b01 != sw_N ) && ( 2'b01 != sw_W )) ||
                  (( 2'b01 != sw_E ) && ( 2'b01 != sw_S ) && ( 2'b01 != sw_W )) ||
                  (( 2'b01 != sw_E ) && ( 2'b01 != sw_N ) && ( 2'b01 != sw_S )) )? 1:0;
assign argueN =  ((( 2'b10 != sw_E ) && ( 2'b10 != sw_N ) && ( 2'b10 != sw_W )) || 
                  (( 2'b10 != sw_S ) && ( 2'b10 != sw_N ) && ( 2'b10 != sw_W )) ||
                  (( 2'b10 != sw_E ) && ( 2'b10 != sw_S ) && ( 2'b10 != sw_W )) ||
                  (( 2'b10 != sw_E ) && ( 2'b10 != sw_N ) && ( 2'b10 != sw_S )) )? 1:0;
assign argueW =  ((( 2'b11 != sw_E ) && ( 2'b11 != sw_N ) && ( 2'b11 != sw_W )) || 
                  (( 2'b11 != sw_S ) && ( 2'b11 != sw_N ) && ( 2'b11 != sw_W )) ||
                  (( 2'b11 != sw_E ) && ( 2'b11 != sw_S ) && ( 2'b11 != sw_W )) ||
                  (( 2'b11 != sw_E ) && ( 2'b11 != sw_N ) && ( 2'b11 != sw_S )) )? 1:0;
always@(posedge clk, posedge rst)
  if(rst) begin
    q1_state <= 2'b0;
    q1_cont <= 3'b0;
    LED <= 8'b00000000;
  end
  else if(tri_cont) begin
    case(state)
      question_1:
        case(q1_state)
          2'b00: begin
            LED <= 8'd1;
            q1_state <= q1_state + 1;
          end
          2'b01: begin
            LED <= LED << 1;
            q1_cont <= q1_cont + 1;
            q1_state <= (q1_cont == 3'b111)? 2'b10 : q1_state;
          end
          2'b10: begin
            LED <= 8'hFF;
            q1_state <= q1_state + 1;
          end
          2'b11: begin
            LED <= 8'd0;
            q1_state <= 2'd0;
          end
        endcase
      question_2: begin
        if(btnD)
          case(sw_S)
            2'b00:
              LED[0] <= 1;
            2'b01:
              LED[2] <= 1;
            2'b10:
              LED[4] <= 1;
            2'b11:
              LED[6] <= 1;
          endcase
        else
          LED <= 8'd0;
      end
      question_3: begin
        if( btnD || btnR || btnU || btnL) begin
          LED[0] <= (argueS)? 0 : 1;
          LED[1] <= (argueS)? 1 : 0;
          LED[2] <= (argueE)? 0 : 1;
          LED[3] <= (argueE)? 1 : 0;
          LED[4] <= (argueN)? 0 : 1;
          LED[5] <= (argueN)? 1 : 0;
          LED[6] <= (argueW)? 0 : 1;
          LED[7] <= (argueW)? 1 : 0;
        end
      end
    endcase
  end

endmodule