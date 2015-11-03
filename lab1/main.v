`timescale 1ns / 1ps
module main( clk, rst, LED, sw, btnD, btnR, btnU, btnL);

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
  if(rst)
    state <= question_1;
  else if(tri_cont)
    case(state)
      2'b00:
        state <= (q1_state == 2'b10 || q1_state == 2'b11)? question_2 : question_1;
      2'b01:
        state <= (sw[7] == 1)? question_3 : question_2;
      2'b10:
        state <= question_3;
    endcase

reg [2:0] q1_cont;

wire [2:0] wantS, wantE, wantN, wantW;
assign wantS = (btnD && (sw[1:0] == 2'b00)) + (btnR && (sw[3:2] == 2'b00)) + (btnU && (sw[5:4] == 2'b00)) + (btnL && (sw[7:6] == 2'b00));
assign wantE = (btnD && (sw[1:0] == 2'b01)) + (btnR && (sw[3:2] == 2'b01)) + (btnU && (sw[5:4] == 2'b01)) + (btnL && (sw[7:6] == 2'b01));
assign wantN = (btnD && (sw[1:0] == 2'b10)) + (btnR && (sw[3:2] == 2'b10)) + (btnU && (sw[5:4] == 2'b10)) + (btnL && (sw[7:6] == 2'b10));
assign wantW = (btnD && (sw[1:0] == 2'b11)) + (btnR && (sw[3:2] == 2'b11)) + (btnU && (sw[5:4] == 2'b11)) + (btnL && (sw[7:6] == 2'b11));

always@(posedge clk, posedge rst)
  if(rst) begin
    q1_state <= 2'b0;
    q1_cont <= 3'b0;
    LED <= 8'b00000000;
  end
  else if(state == question_2) begin
    case(state)
      question_2: begin
        if(btnD)
          LED[sw[1:0] * 2] <= 1;
        else
          LED <= 8'd0;
      end
      question_3: begin
          LED[0] <= (wantS == 1)? 1 : 0;
          LED[1] <= (wantS  > 1)? 1 : 0;
          LED[2] <= (wantE == 1)? 1 : 0;
          LED[3] <= (wantE  > 1)? 1 : 0;
          LED[4] <= (wantN == 1)? 1 : 0;
          LED[5] <= (wantN  > 1)? 1 : 0;
          LED[6] <= (wantW == 1)? 1 : 0;
          LED[7] <= (wantW  > 1)? 1 : 0;
      end
    endcase
  end
  else if(tri_cont) begin
    case(q1_state)
      2'b00: begin
        LED <= 8'd1;
        q1_state <= q1_state + 1;
      end
      2'b01: begin
        LED <= LED << 1;
        q1_cont <= q1_cont + 1;
        q1_state <= (q1_cont == 3'b110)? 2'b10 : q1_state;
      end
      2'b10: begin
        LED <= 8'hFF;
        q1_state <= q1_state + 1;
      end
      2'b11: begin
        LED <= 8'd0;
        q1_state <= 2'b11;
      end
    endcase
  end

endmodule