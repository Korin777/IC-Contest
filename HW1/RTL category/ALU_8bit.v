module ALU_8bit(result, zero, overflow, ALU_src1, ALU_src2, Ainvert, Binvert, op);
input  [7:0] ALU_src1;
input  [7:0] ALU_src2;
input        Ainvert;
input        Binvert;
input  [1:0] op;
output [7:0] result;
output       zero;
output       overflow;

wire trash;
wire [7:0] carry;
wire set;

ALU_1bit alu0(.result(result[0]), .c_out(carry[0]), .set(trash), .overflow(trash), .a(ALU_src1[0]), .b(ALU_src2[0]), .less(overflow ? ALU_src1[7] : set), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(Binvert), .op(op));
ALU_1bit alu1(.result(result[1]), .c_out(carry[1]), .set(trash), .overflow(trash), .a(ALU_src1[1]), .b(ALU_src2[1]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[0]), .op(op));
ALU_1bit alu2(.result(result[2]), .c_out(carry[2]), .set(trash), .overflow(trash), .a(ALU_src1[2]), .b(ALU_src2[2]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[1]), .op(op));
ALU_1bit alu3(.result(result[3]), .c_out(carry[3]), .set(trash), .overflow(trash), .a(ALU_src1[3]), .b(ALU_src2[3]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[2]), .op(op));
ALU_1bit alu4(.result(result[4]), .c_out(carry[4]), .set(trash), .overflow(trash), .a(ALU_src1[4]), .b(ALU_src2[4]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[3]), .op(op));
ALU_1bit alu5(.result(result[5]), .c_out(carry[5]), .set(trash), .overflow(trash), .a(ALU_src1[5]), .b(ALU_src2[5]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[4]), .op(op));
ALU_1bit alu6(.result(result[6]), .c_out(carry[6]), .set(trash), .overflow(trash), .a(ALU_src1[6]), .b(ALU_src2[6]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[5]), .op(op));
ALU_1bit alu7(.result(result[7]), .c_out(carry[7]), .set(set), .overflow(overflow), .a(ALU_src1[7]), .b(ALU_src2[7]), .less(0), .Ainvert(Ainvert), .Binvert(Binvert), .c_in(carry[6]), .op(op));
assign zero = ~(result[0] | result[1] | result[2] | result[3] | result[4] | result[5] | result[6] | result[7]); 

endmodule
