// area 7651
// cycle 541566
module JAM (
input CLK,
input RST,
output reg [2:0] W,
output reg [2:0] J,
input [6:0] Cost,
output reg [3:0] MatchCount,
output reg [9:0] MinCost,
output reg Valid );

reg busy;
reg [2:0] i, j;
reg [2:0] f,b;
reg [3:0] count;
reg [2:0] step;
reg [2:0] min;
reg [2:0] seq[7:0];


reg [9:0] tmpmincost;


always @(posedge CLK) begin

if(RST) begin
    MatchCount <= 0;
    MinCost <= 0;
    Valid <= 0;
    busy <= 1;
    i <= 6;
    seq[0] <= 0;
    seq[1] <= 1;
    seq[2] <= 2;
    seq[3] <= 3;
    seq[4] <= 4;
    seq[5] <= 5;
    seq[6] <= 6;
    seq[7] <= 7;
    MinCost <= 10'b1111111111;
    MatchCount <= 0;
    step <= 3;
    W <= 0;
    J <= seq[0];
    count <= 1;
    tmpmincost <= 0;
    min <= 7;
end
if(busy && !RST) begin
    case(step)
    0: begin //找出替換點
        if(seq[i+1] > seq[i]) begin
            j <= 7;
            min <= 7;
            step <= 1;
        end
        else begin 
            i <= i - 1;
            step <= 0;
        end
    end
    1: begin
        if(i == j) begin
            seq[i] <= seq[min];
            seq[min] <= seq[i];
            step <= 2;
            f <= i + 1;
            b <= 7;
            count <= 0;
            tmpmincost <= 0;
        end
        if(seq[i] > seq[min] || (seq[min] > seq[j] && seq[j] > seq[i])) begin
            min <= j;
        end
        j <= j - 1;
    end
    2: begin // 替換點後翻轉
        if(f >= b) begin
            step <= 3;
        end
        else begin 
            seq[f] <= seq[b];
            seq[b] <= seq[f];
            b <= b - 1;
            f <= f + 1;
        end
        if(count <= i) begin
            W <= count;
            J <= seq[count];
            if(count > 0)
                tmpmincost <= tmpmincost + Cost;
            count <= count + 1;
        end
    end
    3: begin // 獲得成本
        if(count == 9) begin
            if(tmpmincost < MinCost) begin
                MinCost <= tmpmincost;
                MatchCount <= 1;
            end
            else if(tmpmincost == MinCost)
                MatchCount <= MatchCount + 1;

            if(seq[0] == 7 && seq[1] == 6 && seq[2] == 5 && seq[3] == 4 &&seq[4] == 3 && seq[5] == 2
             && seq[6] == 1)
                step <= 4;
            else begin
                i <= 6;
                step <= 0;
            end
        end
        else begin
            W <= count;
            J <= seq[count];
            tmpmincost <= tmpmincost + Cost;
        end
        count <= count + 1;
    end
    default: begin // 輸出
        Valid <= 1;
    end
    endcase
end
end






endmodule


