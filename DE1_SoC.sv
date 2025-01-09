module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input logic 			CLOCK_50; // 50MHz clock.
	output logic [6:0]   HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]   LEDR;
	input logic [3:0] 	KEY; // True when not pressed, False when pressed
	input logic [9:0] 	SW;
	
	logic keyStable0, keyStable3, keyInput0, keyInput3; //logic for updated inputs after going through stabilizer and input modules
	
	//clock divider
	logic [31:0] div_clk;
	parameter whichClock = 15; // 0.75 Hz clock
	clock_divider cdiv (.clock(CLOCK_50), .reset(reset), .divided_clocks(div_clk));
	
	//clock selection:
	assign clk = CLOCK_50;  			//for sim
	//assign clk = div_clk[15];		//for board
	

	assign HEX2 = 7'b1111111;
	assign HEX3 = 7'b1111111;
	assign HEX4 = 7'b1111111;
	assign HEX5 = 7'b1111111;
	assign LEDR[0] = 1'b0;
	
	//create CyberPlayer
	logic [9:0] Q;
	
	LFSR10 ran (.clk(clk), .reset(SW[9]), .Q(Q));
	cyberPlayer ROBO(.clk(clk), .SW(SW[8:0]), .Q(Q), .out(cyberButt));
	
	
	//deal with metastability
	stabilizer stable0 (.clk(clk), .reset(SW[9]), .key(~KEY[0]), .out(keyStable0));
	stabilizer stable3 (.clk(clk), .reset(SW[9]), .key(cyberButt), .out(keyStable3));
	
	//assign one true value/pulse for each press/hold of the key
	uInput input0 (.clk(clk), .reset(SW[9]), .key(keyStable0), .out(keyInput0));
	uInput input3 (.clk(clk), .reset(SW[9]), .key(keyStable3), .out(keyInput3));
	
	//assign light values
	normalLight one   (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[2]), .NR(LEDR[0]), .lightOn(LEDR[1]), .nextRound(nextRound));
	normalLight two   (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[3]), .NR(LEDR[1]), .lightOn(LEDR[2]), .nextRound(nextRound));
	normalLight three (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[4]), .NR(LEDR[2]), .lightOn(LEDR[3]), .nextRound(nextRound));
	normalLight four  (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[5]), .NR(LEDR[3]), .lightOn(LEDR[4]), .nextRound(nextRound));
	centerLight five  (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[6]), .NR(LEDR[4]), .lightOn(LEDR[5]), .nextRound(nextRound));
	normalLight six   (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[7]), .NR(LEDR[5]), .lightOn(LEDR[6]), .nextRound(nextRound)); 
	normalLight seven (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[8]), .NR(LEDR[6]), .lightOn(LEDR[7]), .nextRound(nextRound)); 
	normalLight eight (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(LEDR[9]), .NR(LEDR[7]), .lightOn(LEDR[8]), .nextRound(nextRound));
	normalLight nine  (.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .NL(1'b0), .NR(LEDR[8]), .lightOn(LEDR[9]), .nextRound(nextRound)); 

	//determine winner
	counter winner 	(.clk(clk), .reset(SW[9]), .L(keyInput3), .R(keyInput0), .LEDL(LEDR[9]), .LEDR(LEDR[1]), .hex0(HEX0), .hex1(HEX1), .nextRound(nextRound));
	
endmodule

module DE1_SoC_testbench();
	logic 		CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;

	DE1_SoC dut (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	end
	
	// Test the design.
		initial begin
		KEY[0] <= 1;				 LEDR[0] = 0;	@(posedge CLOCK_50);
		SW[9] <= 1;										@(posedge CLOCK_50);
		SW[9] <= 0;	SW[8:0] <= 9'b000001000;	@(posedge CLOCK_50);
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50);
										repeat(3)		@(posedge CLOCK_50);
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50);
										repeat(3)		@(posedge CLOCK_50);
		SW[9] <= 1;										@(posedge CLOCK_50);
		SW[9] <= 0;	SW[8:0] <= 9'b111000000;	@(posedge CLOCK_50);
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50);
										repeat(3)		@(posedge CLOCK_50);
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50); 
		KEY[0] <= 0;									@(posedge CLOCK_50);
		KEY[0] <= 1;									@(posedge CLOCK_50);
										repeat(37)		@(posedge CLOCK_50);

		
		$stop;
	end

endmodule