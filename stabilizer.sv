module stabilizer (clk, reset, key, out);

	input logic clk, reset;
	input logic key;
	output logic out;
	
	logic out1;
	
	always_ff @(posedge clk) begin
		out1 <= key;
	end
	
	always_ff @(posedge clk) begin
		if(reset) out <= 0;
		else out <= out1;
	end
	
endmodule

module stabilizer_testbench();
	logic clk, reset;
	logic key;
	logic out;
	
	stabilizer dut (.clk, .reset, .key, .out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		key <= 0; reset <= 1;	repeat(1) @(posedge clk);
		reset <= 0; 				repeat(2) @(posedge clk);
		key   <= 1;				 				 @(posedge clk);
		key	<= 0;      		 				 @(posedge clk);
		key	<= 1;	repeat(1) 				 @(posedge clk);
		key	<= 0;      		 				 @(posedge clk);
		key	<= 1;	repeat(2) 				 @(posedge clk);
		key	<= 0; repeat(4)      		 @(posedge clk);
		$stop;
	end
endmodule