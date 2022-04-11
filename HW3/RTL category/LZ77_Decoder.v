module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 		[2:0] 	code_len;
input 		[7:0] 	chardata;
output reg  			encode;
output reg  			finish;
output reg	 	[7:0] 	char_nxt;


reg [7:0] search_buffer[8:0];
reg [2:0] count;
reg busy;
reg [2:0] step;



always @(posedge clk) begin
	if(reset) begin
		encode <= 0;
		finish <= 0;
		char_nxt <= 0;
		busy <= 1;
		count <= 0;
		step <= 0;
		count <= 0;
	end
	if(busy && !reset) begin
		if(count == 0)
			count <= code_len;
		else
			count <= count - 1;
		search_buffer[8] <= search_buffer[7];
		search_buffer[7] <= search_buffer[6];
		search_buffer[6] <= search_buffer[5];
		search_buffer[5] <= search_buffer[4];
		search_buffer[4] <= search_buffer[3];
		search_buffer[3] <= search_buffer[2];
		search_buffer[2] <= search_buffer[1];
		search_buffer[1] <= search_buffer[0];
		if(count == 1 || code_len == 0) begin
			if(chardata == 8'h24)
				finish <= 1;
			search_buffer[0] <= chardata;
			char_nxt <= chardata;
		end
		else begin
			search_buffer[0] <= search_buffer[code_pos];
			char_nxt <= search_buffer[code_pos];
		end
	end
end



/*
	Write Your Design Here ~
*/




endmodule

