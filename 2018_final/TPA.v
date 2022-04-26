// area: 277911
// time: 11623500457
module TPA(clk, reset_n, 
	   SCL, SDA, 
	   cfg_req, cfg_rdy, cfg_cmd, cfg_addr, cfg_wdata, cfg_rdata);
input 		clk; 
input 		reset_n;
// Two-Wire Protocol slave interface 
input 		SCL;  
inout		SDA;

// Register Protocal Master interface 
input		cfg_req;
output reg		cfg_rdy;
input		cfg_cmd;
input	[7:0]	cfg_addr;
input	[15:0]	cfg_wdata;
output reg	[15:0]  cfg_rdata;

reg	[15:0] Register_Spaces	[0:255];

// ===== Coding your RTL below here ================================= 

reg [3:0]step;
reg [3:0] tw_step;
reg [3:0]tw_counter;

reg [7:0] tw_waddr;
reg [15:0] tw_wdata;

reg link;
reg sda;
reg busy;
reg conflict;
reg [7:0] rim_addr;

assign SDA = link ? sda : 1'bz;

always @(posedge clk) begin
	if(!reset_n) begin
		cfg_rdata <= 0;
		step <= 0;
		busy <= 1;
		tw_counter <= 0;
		link <= 0;
		sda <= 1;
		conflict <= 0;
		tw_step <= 0;
	end
	if(busy && reset_n) begin
		case (step)
		0: begin
			if(cfg_req) begin
				if(cfg_cmd) begin// write
					Register_Spaces[cfg_addr] <= cfg_wdata;
				end
				else begin // read
					cfg_rdata <= Register_Spaces[cfg_addr];
				end
				cfg_rdy <= 1;
				step <= 1;
			end
		end
		1: begin
			step <= 2;
		end
		2: begin
			cfg_rdy <= 0;
			step <= 0;
		end
		endcase
		case(tw_step)
		0: begin // idle
			if(SDA == 0) begin
				tw_step <= 1;
			end
		end
		1: begin
			if(cfg_req && cfg_cmd) begin
				conflict <= 1;
				rim_addr <= cfg_addr;
			end
			else
				conflict <= 0;
			if(SDA)
				tw_step <= 2;
			else
				tw_step <= 3;
		end
		2: begin // write addr
			tw_waddr[tw_counter] <= SDA;
			if(tw_counter == 7) begin
				tw_counter <= 0;
				tw_step <= 4;
			end
			else 
				tw_counter <= tw_counter + 1;
		end
		4: begin
			tw_wdata[tw_counter] <= SDA;
			if(tw_counter == 15) begin
				tw_step <= 10;
			end
				tw_counter <= tw_counter + 1;
		end
		3: begin // read addr
			tw_waddr[tw_counter] <= SDA;
			if(tw_counter == 7) begin
				tw_counter <= 0;
				tw_step <= 5;
			end
			else 
				tw_counter <= tw_counter + 1;
		end
		5: begin
			tw_step <= 6;
		end
		6: begin
			link <= 1;
			sda <= 1;
			tw_step <= 7;
		end
		7: begin
			sda <= 0;
			tw_step <= 8;
		end
		8: begin
			sda <= Register_Spaces[tw_waddr][tw_counter];
			tw_counter <= tw_counter + 1;
			if(tw_counter == 15) begin
				tw_step <= 9;
			end
		end	
		9: begin
			sda <= 1;
			link <= 0;
			tw_step <= 0;
		end
		10: begin
			if(!conflict || rim_addr != tw_waddr)
				Register_Spaces[tw_waddr] <= tw_wdata;
			tw_step <= 0;
		end
		endcase
	end
end

endmodule
