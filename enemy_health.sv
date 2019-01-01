module enemy_health (
				input  logic 		Clk, Reset, enemy_hit_en,
				input logic 		frame_clk,          // The clock indicating a new frame (~60Hz)
            // input  logic[2:0] health_in,
            // output logic[2:0] enemy_health_out,
				output logic 		dead);

	logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
				
	logic[2:0] health, health_in;
	logic[6:0] counter, counter_in;
	
	always_ff @ (posedge Clk)
   begin
		if (Reset)
			begin
				health <= 3'b101;
				counter <= 7'd119;
			end
		else
			begin
				health <= health_in;
				counter <= counter_in;
			end
   end
	
	always_comb
	begin
		health_in = health;
		counter_in = counter;
		if (frame_clk_rising_edge)
			begin
				if (counter == 7'd0)
					counter_in = 7'd117;
				else
					counter_in = counter - 1'd1;
					
				if (health == 3'b00)
					health_in = 3'b00;
				else if (enemy_hit_en && counter == 7'd0)		// Enemy can only take damage every second when hit
					health_in = health - 1'b1;
				else
					health_in = health;
			end
			
	end
	
	assign health_out = health;
	 
	always_comb
	begin
		if (health == 3'b0)
			dead = 1'b1;
		else
			dead = 1'b0;
	end

endmodule
