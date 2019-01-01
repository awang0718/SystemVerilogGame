module enemy_health4 (
				input  logic 		Clk, Reset, 
				input logic 		enemy_hit_en[0:3], is_enemy_shield[0:3],
				input logic 		frame_clk,          // The clock indicating a new frame (~60Hz)
				output logic 		dead[0:3],
				output logic		all_dead);

	logic frame_clk_delayed, frame_clk_rising_edge;
   always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
   end
				
	logic[2:0] health[0:3], health_in[0:3];
	logic[6:0] counter, counter_in;
	
	always_ff @ (posedge Clk)
   begin
		if (Reset)
			begin
				health <= '{3'b101, 3'b101, 3'b101, 3'b111};
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
					counter_in = 7'd119;
				else
					counter_in = counter - 1'd1;
				
				for (int i = 0; i < 4; i++)
				begin
					if (health[i] == 3'b00)
						health_in[i] = 3'b00;
					else if (enemy_hit_en[i] && ~is_enemy_shield[i] && counter == 7'd0)		// Enemy can only take damage every 2 seconds when hit
						health_in[i] = health[i] - 1'b1;
					else
						health_in[i] = health[i];
				end
			end
			
	end
	
	// assign health_out = health;
	always_comb
	begin
		for (int i = 0; i < 4; i++)
		begin
			if (health[i] == 3'b0)
				dead[i] = 1'b1;
			else
				dead[i] = 1'b0;
		end
	end
	
	assign all_dead = dead[0] & dead[1] & dead[2] & dead[3];

endmodule
