module uInput(clk, reset, key, out);
	//out is true for one cycle when key is pressed(or held)
	output logic out;
	input logic clk, reset, key;
	
	enum {off, on} ps, ns;
	
	//next state logic
	always_comb begin
		case(ps)
			on:	if(key) ns = on;
					else ns = off;
			
			off:	if(key) ns = on;
					else ns = off;
			
		endcase
	end

	//output logic
	assign out = (ps == on & ns == off);
	
	//DFFs
	always_ff @(posedge clk) begin
		if(reset) ps <= off;
		else ps <= ns;
	end
endmodule


module uInput_testbench();
	logic clk, reset;
	logic key;
	logic out;
	
	uInput dut (.clk, .reset, .key, .out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		key <= 0; reset <= 1;	repeat(1) @(posedge clk);
		reset <= 0; 			 				 @(posedge clk);
		key   <= 1;				 				 @(posedge clk);
		key	<= 0;      		 				 @(posedge clk);
		key	<= 1;	repeat(1) 				 @(posedge clk);
		key	<= 0;      		 				 @(posedge clk);
		key	<= 1;	repeat(2) 				 @(posedge clk);
		key	<= 0; repeat(2)      		 @(posedge clk);
		$stop;
	end
endmodule
		