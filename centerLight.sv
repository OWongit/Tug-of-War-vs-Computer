module centerLight (clk, reset, L, R, NL, NR, lightOn, nextRound);
	input logic clk, reset, nextRound;
	
	// L is true when left key is pressed, R is true when the right key
	// is pressed, NL is true when the light on the left is on, and NR
	// is true when the light on the right is on.
	input logic L, R, NL, NR;
	
	// when lightOn is true, the center light should be on.
	output logic lightOn;
	
	enum{off, on} ns, ps;

	//next state logic
	always_comb begin
		case(ps)
			off: if(NL & R & ~L | NR & L & ~R)  ns = on;
				  else 									ns = off;
			
			on: if(R & ~L | L & ~R) 				ns = off;
				 else										ns = on;
			
		endcase
	end
	
	//output logic
	assign lightOn = ps;
	
	//DFFs
	always_ff @(posedge clk) begin
		if(reset | nextRound) ps <= on;
		else ps <= ns;
	end

endmodule
			

module centerLight_testbench();
	logic clk, reset;
	logic L, R, NL, NR;
	logic lightOn;
	
	centerLight dut (.clk, .reset, .L, .R, .NL, .NR, .lightOn);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		L <= 0; R <= 0; NL <= 0; NR <= 0; 					@(posedge clk);
		reset <= 1;   												@(posedge clk);
		reset <= 0;								repeat(1)		@(posedge clk);
		L <= 1; 														@(posedge clk);
		L <= 0; 														@(posedge clk);
													repeat(1)		@(posedge clk);
		R <= 1; NL <= 1;			 								@(posedge clk);
		R <= 0; NL <= 0;						repeat(1)		@(posedge clk);
		R <= 1; 														@(posedge clk);
		R <= 0; 														@(posedge clk);		
		L <= 1; NR <= 1;			 								@(posedge clk);
		L <= 0; NR <= 0; 						repeat(1)		@(posedge clk);
		L <= 1; 														@(posedge clk);
		L <= 0; 														@(posedge clk);
													repeat(3)		@(posedge clk);
		$stop;
	end
endmodule