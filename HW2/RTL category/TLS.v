module TLS(clk, reset, Set, Stop, Jump, Gin, Yin, Rin, Gout, Yout, Rout);
input           clk;
input           reset;
input           Set;
input           Stop;
input           Jump;
input     [3:0] Gin;
input     [3:0] Yin;
input     [3:0] Rin;
output reg      Gout;
output reg      Yout;
output reg      Rout;

reg [1:0] State, NextState;
reg [3:0] Gtime, Ytime, Rtime, count;

parameter green = 2'b00, yellow = 2'b01, red = 2'b10;


// state register
always @(posedge clk or posedge reset) begin
    if(reset)
        State <= 2'b11;
    else begin
        if(!Stop) begin
            State <= NextState;
            count <= count + 1;
        end
        if(State != NextState && !Stop)
            count <= 1;
        if(Set) begin
            Gtime <= Gin;
            Ytime <= Yin;
            Rtime <= Rin;
            State <= green;
            count <= 1;
        end
        if(Jump) begin
            State <= red;
            count <= 1;
        end
    end
end

// next state logic
always @(count or State) begin
    case (State)
        green : begin
            if(count == Gtime)
                NextState <= yellow;
            else
                NextState <= green;
        end 
        yellow : begin
            if(count == Ytime)
                NextState <= red;
            else
                NextState <= yellow;
        end 
        red : begin
            if(count == Rtime)
                NextState <= green;
            else
                NextState <= red;
        end 
        default: 
            NextState <= green;
    endcase
end

// Output logic
always @(State) begin
    case(State)
        green : begin
            Gout <= 1;
            Yout <= 0;
            Rout <= 0;
        end
        yellow : begin
            Gout <= 0;
            Yout <= 1;
            Rout <= 0;
        end
        red : begin
            Gout <= 0;
            Yout <= 0;
            Rout <= 1;
        end
        default begin
            Gout <= 0;
            Yout <= 0;
            Rout <= 0;
        end
    endcase
end

endmodule