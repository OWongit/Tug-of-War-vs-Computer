module cyberPlayer(clk, SW, Q, out);
	input logic clk;
	input logic [9:0] Q;
	input logic [8:0] SW;
	output logic out;
	
	logic [9:0] SWPlus;
	assign SWPlus = {1'b0, SW};
	
	Comparator comp (.clk, .A(SWPlus), .B(Q), .result(out));
	
endmodule


module cyberPlayer_testbench();
	logic clk;
	logic [9:0] Q;
	logic [8:0] SW;
	logic out;
	
	cyberPlayer dut(.clk, .SW, .Q, .out);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
																	@(posedge clk);
		Q <= 10'b0010000000; SW <= 9'b000000010;		@(posedge clk);
																	@(posedge clk);		
		SW <= 9'b100000000;									@(posedge clk);
																	@(posedge clk);
		Q <= 10'b0100000000;									@(posedge clk);												
																	@(posedge clk);
																	@(posedge clk);
		$stop;
	end
endmodule

