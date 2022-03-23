`timescale 1ns/10ps
/*
 * IC Contest Computational System (CS)
*/
module CS(Y, X, reset, clk);

input clk, reset; 
input [7:0] X;
reg [7:0] x[8:0];
reg [9:0] xavg;
reg [11:0] tmp;
reg [11:0] sum;
reg [11:0] tmpy;
integer i;
output reg [9:0] Y;
always@(posedge clk)
begin
  if(reset == 1)
  begin
    Y = 10'b0000000000;
    x[0] = 8'b00000000;
    x[1] = 8'b00000000;
    x[2] = 8'b00000000;
    x[3] = 8'b00000000;
    x[4] = 8'b00000000;
    x[5] = 8'b00000000;
    x[6] = 8'b00000000;
    x[7] = 8'b00000000;
    x[8] = 8'b00000000;
    xavg = 10'b0000000000;
    tmp = 12'b000000000000;
    sum = 12'b000000000000;
    tmpy = 12'b000000000000;
    //i = 4'b0000;
  end
  else
  begin
  x[0] = x[1];
  x[1] = x[2];
  x[2] = x[3];
  x[3] = x[4];
  x[4] = x[5];
  x[5] = x[6];
  x[6] = x[7];
  x[7] = x[8];
  x[8] = X;
  // 828 92 62
  sum = x[0] + x[1] + x[2] + x[3] + x[4] + x[5] + x[6] + x[7] + x[8];
  xavg = sum / 9;
  tmp = 12'b000000000000;
  
  for(i = 0; i < 9; i = i+1)
  begin
    if(xavg == x[i])
    begin
        tmp = xavg;
    end
    else 
    begin
      if(xavg > x[i])
      begin
        if(tmp < x[i])
        begin
          tmp = x[i];
        end
        else
        begin
          tmp = tmp;
        end
      end
      else
      begin
          tmp = tmp;
      end
    end
  end
  tmpy = sum + (tmp << 3) + tmp;
  tmpy = tmpy >> 3;
  Y = tmpy;
  end
end
 
endmodule

