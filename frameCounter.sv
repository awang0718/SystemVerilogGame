module frameCounter (
				input  logic 		Clk, Reset,
				input logic 		frame_clk,          // The clock indicating a new frame (~60Hz)
				output logic 		changeFrame);

	logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
				
	logic[6:0] counter, counter_in;
   logic	ChangeFrame, ChangeFrame_in;
	
	always_ff @ (posedge Clk)
   begin
		if (Reset)
		begin
			counter <= 7'd0;
			ChangeFrame <= 1'b0;
		end
		else
		begin
			counter <= counter_in;
			ChangeFrame <= ChangeFrame_in;
		end
   end
	
	always_comb
	begin
		counter_in = counter;
		ChangeFrame_in = changeFrame;
		
		if (frame_clk_rising_edge)
		begin
			if (counter == 7'd59)
				counter_in = 7'd0;
			else
				counter_in = counter + 1'd1;
				
			if (counter % 20 >= 0 && counter % 20 < 10)
				ChangeFrame_in = 1'b0;
			else
				ChangeFrame_in = 1'b1;
		end		
	end
	
	assign changeFrame = ChangeFrame;

endmodule
