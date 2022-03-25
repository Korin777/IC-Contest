//area 21802
module geofence ( clk,reset,X,Y,valid,is_inside);
input clk;
input reset;
input [9:0] X;
input [9:0] Y;
output reg valid;
output reg is_inside;

reg [9:0] x[5:0];
reg [9:0] y[5:0];
reg [9:0] px,py;
reg [1:0] count;
reg start, busy, calculate;
reg [2:0] sequence[5:0];
reg [2:0] p, s;
reg [3:0] step;

wire signed [20:0] mul;

reg signed [20:0] tmp;
reg signed [10:0] a,b;

assign mul = a*b;

always @(posedge clk) begin

if(reset) begin
    valid <= 0;
    is_inside <= 0;
    start <= 1;
    count <= 0;
    s <= 3'b111;
    busy <= 0;
    calculate <= 0;
end
if(start && !busy && !reset && !calculate) begin
    case(s)
    3'b110: begin
        count <= 0;
        busy <= 1;
        p <= 2;
        s <= 1;
        step <= 1;
    end
    3'b111: begin
        px = X;
        py = Y;
        s <= 0;
        sequence[0] <= 0;
    end
    default begin
        x[s] = X;
        y[s] = Y;
        s <= s + 1;
    end
    endcase
end
if(busy) begin
    if(count == 2) begin
        count <= 0;
        if(p + 1 == step)
            p <= p + 2;
        else
            p <= p + 1;
        if(tmp < mul)
            s <= s + 1;
    end
    else
        count <= count + 1;
    case(step)
    6: begin
        step <= 0;
        s <= 1;
        count <= 0;
        p <= 1;
        busy <= 0;
        calculate <= 1;
    end
    default: begin
        if(count == 0) begin
            a <= x[step] - x[0];
            b <= y[p] - y[0];
        end
        else if(count == 1) begin
            tmp <= mul;
            a <= x[p] - x[0];
            b <= y[step] - y[0];
        end

        if(p > 5) begin
            step <= step + 1;
            sequence[s] <= step;
            s <= 1;
            count <= 0;
            p <= 1;
        end

    end
    endcase
end
if(calculate) begin
    case(step)
    6 : begin
        is_inside <= 1;
        valid <= 1;
        step <= 8;
    end
    7 : begin
        is_inside <= 0;
        valid <= 1;
        step <= 8;
    end
    8 : begin
        valid <= 0;
        calculate <= 0;
        s <= 3'b111;
    end
    default : begin
        if(count == 0) begin
            a <= x[sequence[step]] - px;
            b <= y[sequence[p]] - y[sequence[step]];
        end
        else if(count == 1) begin
            tmp <= mul;
            a <= x[sequence[p]] - x[sequence[step]];
            b <= y[sequence[step]] - py;
        end
    end
    endcase
    if(step < 6) begin
        if(count == 2) begin
            count <= 0;
            if(p == 5)
                p <= 0;
            else
                p <= p + 1;
            if(tmp < mul) begin // 跳出來
                step <= 7;
            end
            else begin
                step <= step + 1;
            end
        end
        else
            count <= count + 1;
    end
end
end
endmodule

