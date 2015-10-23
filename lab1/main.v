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
wire [2:0] wantS, wantE, wantN, wantW;
assign wantS = (btnD && (sw_S == 2'b00)) + (btnR && (sw_E == 2'b00)) + (btnU && (sw_N == 2'b00)) + (btnL && (sw_W == 2'b00));
assign wantE = (btnD && (sw_S == 2'b01)) + (btnR && (sw_E == 2'b01)) + (btnU && (sw_N == 2'b01)) + (btnL && (sw_W == 2'b01));
assign wantN = (btnD && (sw_S == 2'b10)) + (btnR && (sw_E == 2'b10)) + (btnU && (sw_N == 2'b10)) + (btnL && (sw_W == 2'b10));
assign wantW = (btnD && (sw_S == 2'b11)) + (btnR && (sw_E == 2'b11)) + (btnU && (sw_N == 2'b11)) + (btnL && (sw_W == 2'b11));

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
          LED[0] <= (wantS == 1)? 1 : 0;
          LED[1] <= (wantS  > 1)? 0 : 1;
          LED[2] <= (wantE == 1)? 1 : 0;
          LED[3] <= (wantE  > 1)? 0 : 1;
          LED[4] <= (wantN == 1)? 1 : 0;
          LED[5] <= (wantN  > 1)? 0 : 1;
          LED[6] <= (wantW == 1)? 1 : 0;
          LED[7] <= (wantW  > 1)? 0 : 1;
      end
    endcase
  end

endmodule