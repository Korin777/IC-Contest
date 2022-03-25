
`timescale 1ns/10ps
module LBP ( clk, reset, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input   	clk;
input   	reset;
output reg  [13:0] 	gray_addr;
output reg        	gray_req;
input  	gray_ready;
input   [7:0] 	gray_data;
output reg  [13:0] 	lbp_addr;
output reg  	lbp_valid;
output reg  [7:0] 	lbp_data;
output reg  	finish;

reg [8:0] buffer [8:0];
reg [13:0] addr;

reg [13:0] x, y, z;

reg [8:0] out;

reg init;

reg [3:0] count;

reg [3:0] step;

//====================================================================
always @(posedge clk) begin

if(reset) begin
    gray_req <= 0;
    addr <= 0;
    x <= 0;
    y <= 128;
    z <= 256;
    init <= 1;
    count <= 4'b1111;
    finish <= 0;
    lbp_valid <= 0;
    step <= 0;
    lbp_addr <= 0;
end  
else if(gray_ready) begin
    case(step)
    3'b000: begin // 9 input
        gray_req <= 1;
        lbp_valid <= 0;
        if(init) begin
            if(x[1:0] < 3) begin
                x <= x + 1;
                gray_addr <= x;
            end
            else if(y[1:0] < 3) begin
                y <= y + 1;
                gray_addr <= y;
            end
            else if(z[1:0] < 3) begin
                z <= z + 1;
                gray_addr <= z;
            end
            else
                init <= 0;
        end
        else begin
            gray_req <= 0;
            step <= 1;
            count <= 4'b1111;
        end
        count <= count + 1;
        if(count != 4'b1111)
            buffer[count] <= gray_data;
    end
    3'b001: begin // calculate
        out <= {buffer[4] <= buffer[8], buffer[4] <= buffer[7], buffer[4] <= buffer[6]
        , buffer[4] <= buffer[5] ,buffer[4] <= buffer[3] , buffer[4] <= buffer[2], 
        buffer[4] <= buffer[1], buffer[4] <= buffer[0]};
    
        step <= 3; // output   
    end
    3'b010: begin // 3 input
        lbp_valid <= 0;
        gray_req <= 1;
        if(init) begin
            if(count == 4'b1111) begin
                x <= x + 1;
                gray_addr <= x;
            end
            else if(count == 2) begin
                y <= y + 1;
                gray_addr <= y;
            end
            else if(count == 5) begin
                z <= z + 1;
                gray_addr <= z;
            end
            else
                init <= 0;
        end
        else begin
            gray_req <= 0;
            step <= 1;
            count <= 4'b1111;
        end
        count <= count + 3;
        if(count >= 0)
            buffer[count] <= gray_data;
    end
    3'b011: begin // output
        lbp_valid <= 1;
        lbp_addr <= y-2;
        lbp_data <= out;
        init <= 1;
        count <= 4'b1111;

        if(z == 0) begin
            // x <= 0;
            step <= 4;
        end
        else if(x[6:0] == 0) begin
            step <= 0;
        end
        else begin
            buffer[0] <= buffer[1];
            buffer[3] <= buffer[4];
            buffer[6] <= buffer[7];
            buffer[1] <= buffer[2];
            buffer[4] <= buffer[5];
            buffer[7] <= buffer[8];
            step <= 2;
        end
    end
    default: begin
        lbp_valid <= 0;
        finish <= 1;
    end
    endcase
end
end
endmodule