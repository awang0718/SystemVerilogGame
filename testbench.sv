module testbench();

	timeunit 10ns;	// Half clock cycle at 50 MHz
				// This is the amount of time represented by #1 
	timeprecision 1ns;

	logic Clk;
	logic frame_clk;
	logic Reset;
	logic [3:0]  KEY;          //bit 0 is set up as Reset
	logic [7:0] keycode;

	top_level_pball tp(.*);
	
	always begin : CLOCK_GENERATION
		#1 Clk = ~Clk;
	end

	always begin : FRAME_CLOCK_GEN
		#2 frame_clk = ~frame_clk;
	end

	initial begin: CLOCK_INITIALIZATION
		Clk = 0;
		frame_clk = 0;
	end

	initial begin: TEST_VECTORS
		Reset = 0;
		
		#2 Reset = 1;
		#4 Reset = 0;
		
//		#2 keycode = 8'd07;
//		#400 keycode = 8'd4;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
//		#20 keycode = 8'd04;
//		#10 keycode = 8'd07;
		#200 keycode = 8'd07;
		#200 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		#1000 keycode = 8'd07;
		#500 keycode = 8'd26;
		
	end

endmodule
