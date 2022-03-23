module lcd_ctrl(clk, reset, datain, cmd, cmd_valid, dataout, output_valid, busy);
input           clk;
input           reset;
input   [7:0]   datain;
input   [2:0]   cmd;
input           cmd_valid;
output reg  [7:0]   dataout;
output reg         output_valid;
output reg         busy;

reg [2:0] cur_cmd;
reg [7:0] img [35:0];
reg [7:0] outputnum;
reg [5:0] tmp;
reg [5:0] i;
reg [1:0] x, y;
reg [1:0] tmpx,tmpy;
reg shift, load;




always@(posedge clk)
begin
if(reset)
begin
    for(i = 0; i < 36; i = i + 1)
    begin
      img[i] <= 0;  
    end
    x <= 2;
    y <= 2;
    tmpx <= 0;
    tmpy <= 0;
    tmp <= 0;
    busy <= 0;
    output_valid <= 0;
    cur_cmd <= 0;
    shift <= 0;
    outputnum <= 0;
end
else if(cmd_valid && !busy)
begin
  cur_cmd = cmd;
  tmp = 0;
  tmpx = 0;
  tmpy = 0;
  busy = 1;
  shift = 1;
  load = 1;
end
else if(busy) // exec cmd
begin
  if(outputnum >= 9)
  begin
    busy = 0;
    tmpx = 0;
    tmpy = 0;
    output_valid = 0;
    outputnum = 0;
  end
  else
  begin
  case(cur_cmd)
    3'd0 : //refresh
    begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
    end
    3'd1 : //load data
    begin
      if(load)
      begin
        x = 2;
        y = 2;
        load = 0;
      end
      if(tmp < 36)
      begin
        img[tmp] = datain;
        tmp <= tmp + 1;
      end
      else
      begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
      end
    end
    3'd2 : //shift right
    begin
      if(shift && x < 3)
      begin
        x = x + 1;
        shift = 0;
      end
      else
      begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
      end
    end
    3'd3 : //shift left
    begin
        if(shift && x > 0)
        begin
          x = x - 1;
          shift = 0;
        end
        else
      begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
      end
    end
    3'd4 : // shift up
    begin
      if(shift && y > 0)
      begin
        y = y - 1;
        shift = 0;
      end
      else
      begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
      end
    end
    default : //shift down
    begin
      if(shift && y < 3)
      begin
        y = y + 1;
        shift = 0;
      end
      else
      begin
        dataout = img[(y+tmpy)*6 + x + tmpx];
        outputnum = outputnum + 1;
        output_valid = 1;
        if(tmpx > 1)
        begin
          tmpx = 0;
          tmpy = tmpy + 1;
        end
        else
          tmpx = tmpx + 1;
      end
    end
  endcase
  end
end  
end                                                                               
endmodule
