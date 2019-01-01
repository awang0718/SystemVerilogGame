module enemy4_2 (
				input 			Clk, Reset, frame_clk,
				input[9:0]   	DrawX, DrawY,         // Current pixel coordinates
				
				input[7:0]   	keycode,					 // Keyboard input	
				input[13:0]		Ball_X,	
				input				can_move,				
				input[13:0] 	platform_change[0:15][0:2],
				input[13:0] 	player_location,
				input		 		hit_en, 
				
				output logic	is_enemy[0:3],
				output logic   is_enemy_shield[0:3],			 // whether enemy is using shield
				output logic	is_enemy_attack[0:3],		    // whether enemy is attacking 
				output logic[13:0] enemy_location[0:3],	
				output logic	direction[0:3],
				input logic		dead[0:3]					
);

	 parameter [13:0] Enemy_X_Size = 10'd20;        // Enemyx size 
	 parameter [13:0] Enemy_Y_Size = 10'd30;        // Enemyy size

    logic [13:0] Enemy_X_Start[0:3];
	 assign Enemy_X_Start = '{13'd120, 13'd1500, 13'd2400, 13'd3800};  // Start positions on the X axis
	 logic [13:0] Enemy_Y_Start[0:3];
	 assign Enemy_Y_Start = '{10'd449, 10'd449, 10'd449, 10'd449};  // Start positions on the Y axis
	 
    parameter [13:0] Enemy_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [13:0] Enemy_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [13:0] Enemy_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [13:0] Enemy_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [13:0] Enemy_X_Step = 10'd4;      // Step size on the X axis
    parameter [13:0] Enemy_Y_Step = 10'd6;      // Step size on the Y axis   
    parameter [13:0] Ball_X_Step = 10'd6;		  // Step size on the X axis of the ball
	 
	 logic [13:0] Border[0:3][0:1];
	 assign Border = '{'{13'd20, 13'd375},
							'{13'd1350, 13'd1630},
							'{13'd2220, 13'd2580},
							'{13'd3125, 13'd4453} };
    
	 logic[13:0] Enemy_X_Pos[0:3], Enemy_Y_Pos[0:3], Enemy_Y_Motion[0:3];
    logic[13:0] Enemy_X_Pos_in[0:3], Enemy_Y_Pos_in[0:3], Enemy_Y_Motion_in[0:3];
	 logic[13:0] location[0:3], location_in[0:3];
	 logic direction_[0:3], direction_in[0:3];
	 
	 logic[16:0] attack_shield[0:3], attack_shield_in[0:3];
	 
	 logic shield[0:3], shield_in[0:3];
	 logic attack[0:3], attack_in[0:3];
	 logic hit[0:3], hit_in[0:3];
	 
	 logic appears[0:3], appears_in[0:3];
	 
	 logic[9:0] Enemy_top[0:3], Enemy_top_in[0:3];
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Enemy_X_Pos <= Enemy_X_Start;
            Enemy_Y_Pos <= Enemy_Y_Start;
            Enemy_Y_Motion <= '{14'd0, 14'd0, 14'd0, 14'd0};
				location <= Enemy_X_Start;
				direction_ <= '{1'b1, 1'b0, 1'b0, 1'b0};
				
				Enemy_top <= '{platform_change[0][1], platform_change[0][1], platform_change[0][1], platform_change[0][1]};
				
				attack_shield <= '{16'd0, 16'd0, 16'd0, 16'd0};
				shield <= '{16'd0, 16'd0, 16'd0, 16'd0};
				attack <= '{16'd0, 16'd0, 16'd0, 16'd0};
				hit <= '{1'b0, 1'b0, 1'b0, 1'b0};
				appears <= '{1'b1, 1'b1, 1'b1, 1'b1};
        end
        else
        begin
            Enemy_X_Pos <= Enemy_X_Pos_in;
            Enemy_Y_Pos <= Enemy_Y_Pos_in;
            Enemy_Y_Motion <= Enemy_Y_Motion_in;
				location <= location_in;
				direction_ <= direction_in;
				
				Enemy_top <= Enemy_top_in;
				
				attack_shield <= attack_shield_in;
				shield <= shield_in;
				attack <= attack_in;		
				hit <=  hit_in;
				appears <= appears_in;
        end
    end
	 
	 // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Enemy_X_Pos_in = Enemy_X_Pos;
        Enemy_Y_Pos_in = Enemy_Y_Pos;
        Enemy_Y_Motion_in = Enemy_Y_Motion;
		  location_in = location; 
		  direction_in = direction_;
		  
		  attack_shield_in = attack_shield;
		  shield_in = shield;
		  attack_in = attack;  
		  hit_in = hit;
		  appears_in = appears;
		  
		  Enemy_top_in = Enemy_top;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				Enemy_Y_Motion_in = '{14'd0, 14'd0, 14'd0, 14'd0};
				location_in = location;
				
				attack_shield_in = '{location[0] % 3, location[1] % 3, location[2] % 3, location[3] % 3};
				shield_in = '{1'b0, 1'b0, 1'b0, 1'b0};
				attack_in = '{1'b0, 1'b0, 1'b0, 1'b0};
				
				for (int i = 0; i < 4; i++)
				begin
					Enemy_Y_Pos_in[i] = Enemy_Y_Pos[i] + Enemy_Y_Motion[i];
				
					// if (location[i] >= 13'd3120 && location[i] <= 13'd4453)
					if (location[i] >= Border[i][0] && location[i] <= Border[i][1] && ~dead[i])
						appears_in[i] = 1'b1;
					else
						appears_in[i] = 1'b1;
						
					if (location[i] <= player_location[i])
						direction_in[i] = 1'b1;
					else
						direction_in[i] = 1'b0;
					
					for (int j = 0; j < 15; j++) // Set floor
						begin
							if (location[i] >= platform_change[j][0] + Enemy_X_Size[i] && location[i] + Enemy_X_Size[i] < platform_change[j+1][0])
							begin
								Enemy_top_in[i] = platform_change[j][1];			
								break;
							end;
						end

					if (Enemy_Y_Pos[i] + Enemy_Y_Size[i] < Enemy_top[i] - 1'b1)	// Set gravity
						begin
							Enemy_Y_Motion_in[i] = Enemy_Y_Step;
						end			
			  
					if (Enemy_Y_Pos[i] + Enemy_Y_Motion[i] + Enemy_Y_Size > Enemy_top[i] - 1'b1)  // Ball is at the bottom edge
						begin
							Enemy_Y_Motion_in[i] = 1'b0;
							Enemy_Y_Pos_in[i] = Enemy_top[i] - 1'b1 - Enemy_Y_Size;
						end 

					if (Enemy_Y_Pos[i] <= Enemy_Y_Min + 1'b1 + Enemy_Y_Size + Enemy_Y_Motion[i])  // Ball is at the top edge
						begin
							Enemy_Y_Motion_in[i] = Enemy_Y_Step;
						end			
					
					if (player_location + Enemy_X_Size < location[i] - Enemy_X_Size)// Move left
						begin
							attack_shield_in[i] = 10'd4;
							if (location[i] >= Border[i][0])
							begin
								if ((can_move) || (!can_move && keycode == 8'd07) || (!can_move && keycode == 8'd00) 
									|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
									begin
										if ((player_location <= Enemy_X_Max/2) && (location[i] <= Enemy_X_Min + 1'b1 + Enemy_X_Size)) // Ball is at the left edge
											begin	
												Enemy_X_Pos_in[i] = Enemy_X_Min + Enemy_X_Size;
												location_in[i] = Enemy_X_Min + Enemy_X_Size;
											end
										else
											begin
												location_in[i] = location[i] - Enemy_X_Step;	
												Enemy_X_Pos_in[i] = Ball_X + location[i] - player_location;
											end
									end
								else
									begin	
										location_in[i] = location[i] - Enemy_X_Step;								
										if (location[i] - player_location <= 10'd320)
											Enemy_X_Pos_in[i] = 10'd320 + location[i] - player_location;
										else
											Enemy_X_Pos_in[i] = Enemy_X_Max + Enemy_X_Size + 10'd3;			
									end			
							end
							else //
								begin
									location_in[i] = location[i];
									Enemy_X_Pos_in[i] = Ball_X + location[i] - player_location;
								end
						end
						
					if (player_location - Enemy_X_Size > location[i] + Enemy_X_Size) // Move right
						begin
							attack_shield_in[i] = 10'd4;
							if (location[i] <= Border[i][1])
							begin
								if (can_move || (!can_move && keycode == 8'd04)  || (!can_move && keycode == 8'd00)
									|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
									begin
										if((player_location >= Enemy_X_Max*7+10'd6 - Enemy_X_Max/2) && (location[i] + Enemy_X_Size >= Enemy_X_Max*7+10'd6 - 1'b1)) // Ball is at the right edge
											begin	
												Enemy_X_Pos_in[i] = Enemy_X_Max - Enemy_X_Size;
												location_in[i] = Enemy_X_Max*7+10'd6 - Enemy_X_Size;
											end
										else
											begin
												location_in[i] = location[i] + Enemy_X_Step;
												Enemy_X_Pos_in[i] = Ball_X + location[i] - player_location;
											end
									end
								else
									begin
										location_in[i] = location[i] + Enemy_X_Step;
										if (10'd320 + location[i] - player_location + Enemy_X_Size <= 10'd320)
											Enemy_X_Pos_in[i] = 10'd320 + location[i] - player_location;
										else
											Enemy_X_Pos_in[i] = (~(Enemy_X_Max) + 1'b1);
									end
							end
							else //
								begin
									location_in[i] = location[i];
									Enemy_X_Pos_in[i] = Ball_X + location[i] - player_location;
								end
						end
						
					if ((player_location + Enemy_X_Size >= location[i] - Enemy_X_Size) || 
						 (player_location - Enemy_X_Size <= location[i] + Enemy_X_Size))
						begin	
						
						if(attack_shield[i] == 10'd0)	// Move up
							begin
								if (Enemy_Y_Pos[i] + Enemy_Y_Size >= Enemy_top[i] - 1'b1)
									Enemy_Y_Motion_in[i] = (~(10'd80) + 1'b1);
								else
									Enemy_Y_Motion_in[i] = Enemy_Y_Step;	
							end
							
						if (attack_shield[i] == 10'd1)	// Use shield
							begin
								shield_in[i] = 1'b1;
								attack_in[i] = 1'b0;
								Enemy_Y_Motion_in[i] = Enemy_Y_Motion_in[i];					
							end	
							
						if (attack_shield[i] == 10'd2)	// Attack
							begin
								shield_in[i] = 1'b0;
								attack_in[i] = 1'b1;
								Enemy_Y_Motion_in[i] = Enemy_Y_Motion_in[i];	
							end
						
						end
					
					if (((player_location + Enemy_X_Size <= location[i] + Enemy_X_Size 
							&&	player_location + Enemy_X_Size >= location[i] - Enemy_X_Size) 
							||	(player_location - Enemy_X_Size <= location[i] + Enemy_X_Size
							&& player_location - Enemy_X_Size >= location[i] - Enemy_X_Size)) 
						&&	((player_location + Enemy_Y_Size <= location[i] + Enemy_Y_Size 
							&& player_location + Enemy_Y_Size >= location[i] - Enemy_Y_Size)
							|| (player_location - Enemy_Y_Size <= location[i] + Enemy_Y_Size
							&& player_location - Enemy_Y_Size >= location[i] - Enemy_Y_Size))
						&& hit_en && attack[i] && appears[i] && location[i] >= Border[i][0] && location[i] <= Border[i][1])
						begin
							hit_in[i] = 1'b1;
						end
					else
						begin
							hit_in[i] = 1'b0;
						end
					
				end
        end
    end
    
    // Compute whether the pixel corresponds to enemy or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX[0:3], DistY[0:3], SizeX, SizeY;
	 assign DistX[0] = DrawX - Enemy_X_Pos[0]; //location;
	 assign DistY[0] = DrawY - Enemy_Y_Pos[0];
	 assign DistX[1] = DrawX - Enemy_X_Pos[1]; //location;
	 assign DistY[1] = DrawY - Enemy_Y_Pos[1];
	 assign DistX[2] = DrawX - Enemy_X_Pos[2]; //location;
	 assign DistY[2] = DrawY - Enemy_Y_Pos[2];
	 assign DistX[3] = DrawX - Enemy_X_Pos[3]; //location;
	 assign DistY[3] = DrawY - Enemy_Y_Pos[3];
    assign SizeX = Enemy_X_Size;
	 assign SizeY = Enemy_Y_Size;
    always_comb begin
		for (int i = 0; i < 4; i++)
		begin
		  if ( (DistX[i]*DistX[i] <= SizeX*SizeX) && (DistY[i]*DistY[i] <= SizeY*SizeY) && appears[i] && ~dead[i]) 
            is_enemy[i] = 1'b1;
        else
            is_enemy[i] = 1'b0;
		end
    end
	 
	 assign enemy_location = location;
	 assign direction = direction_;
	 assign is_enemy_shield[0] = shield[0];
	 assign is_enemy_shield[1] = shield[1];
	 assign is_enemy_shield[2] = shield[2];
	 assign is_enemy_shield[3] = shield[3];
	 assign is_enemy_attack[0] = attack[0] & hit[0] & appears[0];
	 assign is_enemy_attack[1] = attack[1] & hit[1] & appears[1];
	 assign is_enemy_attack[2] = attack[2] & hit[2] & appears[2];
	 assign is_enemy_attack[3] = attack[3] & hit[3] & appears[3];
				
endmodule