module LFSR10(clk, reset, Q);
	input logic clk, reset;	
	output logic [9:0] Q;
	logic Q_xnor;
	
	assign Q_xnor = (Q[0] ~^ Q[3]);
	
	always_ff @(posedge clk) begin
		if(reset)
			Q <= 10'b0000000000;
		else
			Q <= {Q_xnor, Q[9:1]};
		end
	endmodule
	
	module LFSR10_testbench();
		logic [9:0] Q;
		logic clk, reset;
		
		LFSR10 dut(.clk, .reset, .Q);
		
		// Set up a simulated clock.
		parameter CLOCK_PERIOD=100;
		initial begin
			clk <= 0;
			forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
		end
	
		initial begin
			reset <= 1;		@(posedge clk);
			reset <= 0;		@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
								@(posedge clk);
			$stop;
		end
	endmodule
