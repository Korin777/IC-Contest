module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output reg 			valid;
output reg 			encode;
output reg 			finish;
output reg	[3:0] 	offset;
output reg	[2:0] 	match_len;
output reg 	[7:0] 	char_nxt;


reg [7:0] search_buffer[8:0];
reg [7:0] lookahead_buffer[7:0];
reg [7:0] image[2048:0];
reg [11:0] count;
reg busy;
reg [2:0] step;
reg [1:0] findstep;
reg [3:0] count_lb;
reg [3:0] same_lb, same_sb;
reg [3:0] count_sb;
reg [3:0] shiftpos;

/*  search_buffer index
	8 7 6 5 4 3 2 1 0
	lookahead_buffer index
	0 1 2 3 4 5 6 7
*/
always @(posedge clk) begin
	if(reset) begin
		valid <= 0;
		encode <= 0;
		finish <= 0;
		offset <= 0;
		match_len <= 0;
		char_nxt <= 0;
		busy <= 1;
		count <= 0;
		step <= 0;
		count_lb <= 0;
		count_sb <= 8;
		search_buffer[0] = 8'b11111111;
		search_buffer[1] = 8'b11111111;
		search_buffer[2] = 8'b11111111;
		search_buffer[3] = 8'b11111111;
		search_buffer[4] = 8'b11111111;
		search_buffer[5] = 8'b11111111;
		search_buffer[6] = 8'b11111111;
		search_buffer[7] = 8'b11111111;
		search_buffer[8] = 8'b11111111;
	end
	if(busy && !reset) begin
		case(step)
		0: begin // read image
			if(chardata == 8'h24) begin
				step <= 1;
				image[count] <= chardata;
				count <= 0;
				encode <= 1;
			end
			else begin
				image[count] <= chardata;
				count <= count + 1;
			end
		end
		1: begin // fill lookahead_buffer
			valid <= 0;
			if(count_lb[3]) begin // lookahead_buffer full or end of image
				step <= 2;
				offset <= 0;
				match_len <= 0;
				char_nxt <= lookahead_buffer[0];
				same_lb <= 0;
				same_sb <= 8;
				findstep <= 0;
			end
			else begin
				lookahead_buffer[count_lb] <= image[count];
				count <= count + 1;
				count_lb <= count_lb + 1;
				step <= 1;
			end
		end
		2: begin // find longest match string
			case(findstep)
				0: begin
					if(search_buffer[same_sb] == lookahead_buffer[same_lb]) begin
						if(same_sb)
							same_sb <= same_sb - 1;
						else begin
							findstep <= 1;
						end
						if(same_lb == 7)
							findstep <= 2;
						else
							same_lb <= same_lb + 1;
					end
					else
						findstep <= 2;
				end
				1: begin
					if(lookahead_buffer[same_sb] == lookahead_buffer[same_lb]) begin
						same_sb <= same_sb + 1;
						if(same_lb == 7)
							findstep <= 2;
						else
							same_lb <= same_lb + 1;
					end
					else
						findstep <= 2;
				end
				default: begin
					if(same_lb > match_len) begin
						offset <= count_sb;
						match_len <= same_lb;
						char_nxt <= lookahead_buffer[same_lb];
					end
					count_sb <= count_sb - 1;
					same_sb <= count_sb - 1;
					same_lb <= 0;
					findstep <= 0;
					if(count_sb == 0) begin
						count_sb <= 8;
						shiftpos <= 7 - match_len;
						step <= 3;
					end
				end
			endcase
		end
		3: begin // left shift search buffer
			if(shiftpos != 4'b1111) begin
				search_buffer[shiftpos + match_len + 1] <= search_buffer[shiftpos];
				shiftpos <= shiftpos - 1;
			end
			else begin
				step <= 4;
			end
		end
		4: begin // move match string and next char from lookahead_buffer to search_buffer and left shift lookahead_buffer
			if(same_lb + match_len + 1 <= 7 || same_lb <= match_len) begin
				if(same_lb <= match_len)
					search_buffer[match_len - same_lb] <= lookahead_buffer[same_lb];
				if(same_lb + match_len + 1 <= 7)
				lookahead_buffer[same_lb] <= lookahead_buffer[same_lb + match_len + 1];
				same_lb <= same_lb + 1;
			end
			else begin
				step <= 5;
				count_lb <= count_lb - match_len - 1;
				same_lb <= 0;
			end
		end
		5: begin
			if(char_nxt == 8'h24)
				step <= 6;
			else
				step <= 1;
			valid <= 1;
		end
		default: begin
			finish <= 1;
		end
		endcase
	end
end

endmodule

