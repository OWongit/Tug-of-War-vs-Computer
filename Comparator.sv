module Comparator(clk, A, B, result);
	input logic clk;
	input logic [9:0] A, B;
	output logic result;
	
	always_ff @(posedge clk) begin
		result <= (A > B);
	end
	
endmodule


module Comparator_testbench();
	logic clk;
	logic [9:0] A, B;
	logic result;
	
	Comparator dut(.clk, .A, .B, .result);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
																@(posedge clk);
		A = 10'b0100000000; B = 10'b0000000010; 	@(posedge clk);
																@(posedge clk);
		B = 10'b1000000000;								@(posedge clk);
																@(posedge clk);
		A = 10'b1000000000;								@(posedge clk);
																@(posedge clk);
																@(posedge clk);
		$stop;
	end
endmodule
