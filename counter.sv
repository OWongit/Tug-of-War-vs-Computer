module counter(clk, reset, L, R, LEDL, LEDR, hex0, hex1, nextRound);
	input logic clk, reset;
	input logic L, R, LEDL, LEDR;
	output logic [6:0] hex0, hex1;
	output logic nextRound;
	
	logic [2:0] p1Count;
	logic [2:0] p2Count;
	
	enum {off, p1, p2} ns, ps;
	
	always_comb begin
		case(ps)
				off: if(LEDL & L & ~R) ns = p2;
					  else if(LEDR & R & ~L) ns = p1;
					  else ns = off;
				p1: ns = p1;
				p2: ns = p2;
		endcase
		
		//score keeping for player
		if(p1Count == 3'b000)
			hex0 = 7'b1000000; 		//0
		else if(p1Count == 3'b001)
			hex0 = 7'b1111001; 		//1
		else if(p1Count == 3'b010)
			hex0 = 7'b0100100; 		//2
		else if(p1Count == 3'b011)
			hex0 = 7'b0110000; 		//3
		else if(p1Count == 3'b100)
			hex0 = 7'b0011001; 		//4
		else if(p1Count == 3'b101)
			hex0 = 7'b0010010; 		//5
		else if(p1Count == 3'b110)
			hex0 = 7'b0000010; 		//6
		else
			hex0 = 7'b1111000; 		//7

		//score keeping for computer	
		if(p2Count == 3'b000)
			hex1 = 7'b1000000; 		//0
		else if(p2Count == 3'b001)
			hex1 = 7'b1111001; 		//1
		else if(p2Count == 3'b010)
			hex1 = 7'b0100100; 		//2
		else if(p2Count == 3'b011)
			hex1 = 7'b0110000; 		//3
		else if(p2Count == 3'b100)
			hex1 = 7'b0011001; 		//4
		else if(p2Count == 3'b101)
			hex1 = 7'b0010010; 		//5
		else if(p2Count == 3'b110)
			hex1 = 7'b0000010; 		//6
		else
			hex1 = 7'b1111000; 		//7
	end
	
	always_ff @(posedge clk) begin
		if(ps == off & ns == p1) begin
			p1Count <= p1Count + 1;
		end
		else if(ps == off & ns == p2) begin
			p2Count <= p2Count + 1;
		end
		else begin
			p1Count <= p1Count;
			p2Count <= p2Count;
		end
		
		if(reset) begin
			ps <= off;
			nextRound <= 0;
			p1Count <= 3'b000;
			p2Count <= 3'b000;
		end
		else if(nextRound) begin
				nextRound <= 0;
				ps <= off;
		end
		else
			ps <= ns;
			
		if(ps != off)
			nextRound <= 1;
		else
			nextRound <= 0;
	end

endmodule

module counter_testbench();
	logic clk, reset;
	logic L, R, LEDL, LEDR;
	logic [6:0] hex0, hex1;
	logic nextRound;
	
	counter dut (.clk(clk), .reset, .L, .R, .LEDL, .LEDR, .hex0, .hex1, .nextRound);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		L <= 0; R <= 0; LEDL <= 0; LEDR <= 0; reset <= 1;  @(posedge clk);
																			@(posedge clk);
		reset <= 0;								repeat(1)			@(posedge clk);
		LEDL <= 1;														@(posedge clk);
		L <= 1;															@(posedge clk);
		L <= 0; LEDL <= 0;  											@(posedge clk);
													repeat(3)			@(posedge clk); //counter @ 1(for player 2)
		LEDR <= 1;														@(posedge clk);
		R <= 1;															@(posedge clk);
		R <= 0; LEDR <= 0;				 							@(posedge clk);
													repeat(3)			@(posedge clk); //counter @ 1(for player 1)
		LEDL <= 1;														@(posedge clk);
		L <= 1;															@(posedge clk);
		L <= 0; LEDL <= 0;  											@(posedge clk);
													repeat(3)			@(posedge clk); //counter @ 2 (for player 2)...
		LEDL <= 1;														@(posedge clk);
		L <= 1;															@(posedge clk);
		L <= 0; LEDL <= 0;  											@(posedge clk);
													repeat(3)			@(posedge clk); //counter @ 3
		LEDL <= 1;														@(posedge clk);
		L <= 1;															@(posedge clk);
		L <= 0; LEDL <= 0;  											@(posedge clk);
													repeat(3)			@(posedge clk); //counter @ 4
		$stop;
	end
endmodule
		