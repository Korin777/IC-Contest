
module ALU_1bit(result, c_out, set, overflow, a, b, less, Ainvert, Binvert, c_in, op);
input        a;
input        b;
input        less;
input        Ainvert;
input        Binvert;
input        c_in;
input  [1:0] op;
output       result;
output       c_out;
output       set;                 
output       overflow;

reg regresult;

wire wireresult;
wire x,y;

always @(a or b or less or Ainvert or Binvert or op or c_in) begin
	case(op)
		2'b00 : begin
		if(Ainvert && Binvert)begin // Nor
			regresult = ~a & ~b;
		end
		else begin // And
			regresult = a & b;
		end
		end
		2'b01 : begin
		if(Ainvert && Binvert)begin // Nand
			regresult = ~a | ~b;
		end
		else begin // Or
			regresult = a | b;
		end
		end
		default : ;
	endcase
end

assign x = Ainvert ? ~a : a;
assign y = Binvert ? ~b : b;
FA fulladder(.s(wireresult), .carry_out(c_out), .x(x), .y(y),.carry_in(c_in)); // handle add or sub
assign result = (op == 2'b10) ? wireresult : (op == 2'b11) ? less : regresult;
assign overflow = c_out ^ c_in;
assign set = wireresult;

endmodule
