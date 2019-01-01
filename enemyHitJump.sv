module enemy (
				input 			Clk, Reset, frame_clk,
				input[9:0]   	DrawX, DrawY,         // Current pixel coordinates
				input[7:0]   	keycode,					 // Keyboard input	
				
				input[13:0]		Ball_X,	
//				input		 		enemy_shield,
//				input				enemy_attack,
//				input[1:0]		direction,
//				input				jump,
				input				can_move,
				input [13:0]   left_bound,
				input [13:0] 	right_bound,
				
//				input[13:0] 	top,
				input[13:0] 	platform_change[0:15][0:2],
				
				output 			is_enemy,
				output 		   is_enemy_shield,			 // whether enemy is using shield
				output 	   	is_enemy_attack,		    // whether enemy is attacking 
				output[13:0] 	enemy_location,
				
				input[13:0] 	player_location,
				input		 		hit_en,
				input[2:0]		ball_health_out,
				output[2:0]		ball_health_in		
);

	 parameter [13:0] Enemy_X_Size = 10'd20;        // Enemyx size 
	 parameter [13:0] Enemy_Y_Size = 10'd30;        // Enemyy size
	 parameter [13:0] Enemy_Y_shield = 10'd15;		 // enemyY shrink (from shield);  

    parameter [13:0] Enemy_X_Start = 14'd3639 - Enemy_X_Size;  // Start position on the X axis
    parameter [13:0] Enemy_Y_Start = 10'd479 - Enemy_Y_Size;  	// Start position on the Y axis
    parameter [13:0] Enemy_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [13:0] Enemy_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [13:0] Enemy_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [13:0] Enemy_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [13:0] Enemy_X_Step = 10'd4;      // Step size on the X axis
    parameter [13:0] Enemy_Y_Step = 10'd6;      // Step size on the Y axis   
    parameter [13:0] Ball_X_Step = 10'd6;		  // Step size on the X axis of the ball
    logic [13:0] Enemy_X_Pos, Enemy_X_Motion, Enemy_Y_Pos, Enemy_Y_Motion;
    logic [13:0] Enemy_X_Pos_in, Enemy_X_Motion_in, Enemy_Y_Pos_in, Enemy_Y_Motion_in;
	 logic[13:0] location, location_in, location_motion_in;
	 
	 logic shield, shield_in, attack, attack_in;
	 logic Enemy_Y_SizeReal, Enemy_Y_SizeReal_in;
	 	 
	 logic [2:0] ball_HP, ball_HP_in; 
	 
	 logic[9:0] Enemy_top, Enemy_top_in, Enemy_top_left, Enemy_top_left_in, Enemy_top_right, Enemy_top_right_in;
	 logic[16:0] attack_shield, attack_shield_in;
    
	 logic[13:0] OOB;
	 
	 //DEBUG
	 logic debug1, debug2, debug3, debug4, debug5, debug6, debug7, debug8, debug9, debug10, debug11, debug12;
	 logic[13:0] debug_plat1, debug_plat2;
	 
	 
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
            //Enemy_Y_Motion <= 10'd0;
				location <= Enemy_X_Start;
				Enemy_top <= platform_change[0][1];
				Enemy_top_right <= platform_change[0][1];
				Enemy_top_left <= platform_change[0][1];
				shield <= 1'd0;
				attack <= 1'd0;
				attack_shield <= 16'd0;

				ball_HP <= ball_health_out;			
        end
        else
        begin
            Enemy_X_Pos <= Enemy_X_Pos_in;
            Enemy_Y_Pos <= Enemy_Y_Pos_in;
           // Enemy_Y_Motion <= Enemy_Y_Motion_in;
				location <= location_in;
				Enemy_top <= Enemy_top_in;
				Enemy_top_right <= Enemy_top_right_in;
				Enemy_top_left <= Enemy_top_right_in;
				shield <= shield_in;
				attack <= attack_in;	
				attack_shield <= attack_shield_in;

				ball_HP <=  ball_health_out;//ball_HP_in;
        end
    end
	 
	 // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
		  debug1 = 1'b0;
		  debug2 = 1'b0;
		  debug3 = 1'b0;
		  debug4 = 1'b0;
		  debug5 = 1'b0;
		  debug6 = 1'b0;
		  debug7 = 1'b0;
		  debug8 = 1'b0;
		  debug9 = 1'b0;
		  debug10 = 1'b0;
		  debug11 = 1'b0;
		  debug12 = 1'b0;
		  debug_plat1 = 14'b0;
		  debug_plat2 = 14'b0;
		  
		  OOB = 14'b0;
        Enemy_X_Pos_in = Enemy_X_Pos;
        Enemy_Y_Pos_in = Enemy_Y_Pos;
        //Enemy_Y_Motion_in = Enemy_Y_Motion;
		  location_in = location; 
		  
		  shield_in = shield;
		  attack_in = attack;
		  attack_shield_in = attack_shield;
		  
		  ball_HP_in = ball_HP;
		  
		  Enemy_top_in = Enemy_top;
		  Enemy_top_right_in = Enemy_top_right;
		  Enemy_top_left_in = Enemy_top_left;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				//Enemy_Y_Motion_in = 10'd0;
				location_in = location;
				
				shield_in = 1'b0;
				attack_in = 1'b0;
				attack_shield_in = location % 3;
				
				//Enemy_Y_Pos_in = Enemy_Y_Pos + Enemy_Y_Motion;	
				
				for (int i = 0; i < 15; i++)
				begin
					if ( location >= platform_change[i][0] + Enemy_X_Size && location + Enemy_X_Size < platform_change[i+1][0])
					begin
						Enemy_top_in = platform_change[i][1];			
						break;
					end;
				end
				
				for (int i = 1; i < 16; i++)		//get the top and bot based off player location
				begin
					if ((location - Enemy_X_Size) < platform_change[i][0])
					begin
						Enemy_top_left_in = platform_change[i-1][1];
						break;
					end
				end
				
				for (int i = 1; i < 16; i++)		//get the top and bot based off player location
				begin
					if ((location + Enemy_X_Size) < platform_change[i][0])
					begin
						Enemy_top_right_in = platform_change[i-1][1];
						break;
					end
				end

				if ((Enemy_Y_Pos + Enemy_Y_Size) < Enemy_top - 1'b1 && (Enemy_Y_Pos + Enemy_Y_Size) < Enemy_top_left - 1'b1 && (Enemy_Y_Pos + Enemy_Y_Size) < Enemy_top_right - 1'b1)
					begin
						Enemy_Y_Pos_in = Enemy_Y_Pos + Enemy_Y_Step; 
					end
		  
            if (Enemy_Y_Pos + Enemy_Y_Step + Enemy_Y_Size > Enemy_top - 1'b1 )  // Ball is at the bottom edge
               begin
						//Enemy_Y_Motion_in = 1'b0;
						Enemy_Y_Pos_in = Enemy_top - 1'b1 - Enemy_Y_Size;
					end
//
//            if (Enemy_Y_Pos <= Enemy_Y_Min + 1'b1 + Enemy_Y_Size + Enemy_Y_Motion )  // Ball is at the top edge
//               begin
//						Enemy_Y_Motion_in = Enemy_Y_Step;
//					end
//					 						
				if (player_location + Enemy_X_Size < location - Enemy_X_Size)	// A: Move left
				begin
					attack_shield_in = 10'd4;
					if ((can_move) || (!can_move && keycode == 8'd07) || (!can_move && keycode == 8'd00) 
						|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
					begin
						if ((player_location <= Enemy_X_Max/2) && (location <= Enemy_X_Min + 1'b1 + Enemy_X_Size)) // Ball is at the left edge
						begin
							location_in = Enemy_X_Min + Enemy_X_Size;
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = Enemy_X_Min + Enemy_X_Size;
							else
								Enemy_X_Pos_in = - (14'd30);
							
						end
						else
						begin
							location_in = location - Enemy_X_Step;	
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = location_in - left_bound;
							else
								Enemy_X_Pos_in = - (14'd30);
						end
					end
					else
					begin	
						location_in = location - Enemy_X_Step;
						if (location_in >= left_bound && location_in <= right_bound)
							Enemy_X_Pos_in = location_in - left_bound;
						else
							Enemy_X_Pos_in = - (14'd30);
						//Enemy_X_Pos_in = 10'd320 + location - player_location;	
					end
					
					//HIT DETECT LEFT
					for (int i = 1; i < 16; i++)
					begin
						if ((location - Enemy_X_Size) < platform_change[i][0])
						begin
							if (i == 1)
							begin
								debug6 = 1'b1;
								break;
							end
							
							//JUMP
							if ((location - Enemy_X_Step - Enemy_X_Size - 2'd2) <= platform_change[i-1][0])
							begin
								OOB = Enemy_Y_Pos - 10'd200;
								if (Enemy_Y_Pos + Enemy_Y_Size >= Enemy_top - 1'b1)
								begin
									if (OOB == 0 || OOB[13] == 1'b1)
										Enemy_Y_Pos_in = Enemy_Y_Min + Enemy_Y_Size;
									else
										Enemy_Y_Pos_in = Enemy_Y_Pos - (10'd200);
								end
								else
									Enemy_Y_Pos_in = Enemy_Y_Pos + Enemy_Y_Step;	
							end
								
							if ((location - Enemy_X_Step - Enemy_X_Size) <= platform_change[i-1][0])
							begin
								debug10 = 1'b1;
								if (Enemy_Y_Pos > platform_change[i-2][1] && Enemy_Y_Pos < platform_change[i-2][2])
								begin
									debug7 = 1'b1;
									location_in = platform_change[i-1][0] + 1'b1 + Enemy_X_Size;
									if (location_in >= left_bound && location_in <= right_bound)
										Enemy_X_Pos_in = location_in - left_bound;
									else
										Enemy_X_Pos_in = - (14'd30);
								end
								else if ((Enemy_Y_Pos - Enemy_Y_Size) > platform_change[i-2][1] && (Enemy_Y_Pos - Enemy_Y_Size) < platform_change[i-2][2])
								begin
									debug8 = 1'b1;
									location_in = platform_change[i-1][0] + 1'b1 + Enemy_X_Size;
									if (location_in >= left_bound && location_in <= right_bound)
									begin
										debug11 = 1'b1;
										Enemy_X_Pos_in = location_in - left_bound;
									end
									else
									begin
										debug12 = 1'b1;
										Enemy_X_Pos_in = - (14'd30);
									end
								end
								else if ((Enemy_Y_Pos + Enemy_Y_Size) > platform_change[i-2][1] && (Enemy_Y_Pos + Enemy_Y_Size) < platform_change[i-2][2])
								begin
									debug9 = 1'b1;
									location_in = platform_change[i-1][0] + 1'b1 + Enemy_X_Size;
									if (location_in >= left_bound && location_in <= right_bound)
										Enemy_X_Pos_in = location_in - left_bound;
									else
										Enemy_X_Pos_in = - (14'd30);
								end
							end
							break;
						end
					end
				end
					
				if (player_location - Enemy_X_Size > location + Enemy_X_Size)	// A: Move right
				begin
					attack_shield_in = 10'd4;
					if (can_move || (!can_move && keycode == 8'd04)  || (!can_move && keycode == 8'd00)
						|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
					begin
						if((player_location >= Enemy_X_Max*7+10'd6 - Enemy_X_Max/2) && (location + Enemy_X_Size >= Enemy_X_Max*7+10'd6 - 1'b1)) // Ball is at the right edge
						begin	
							location_in = Enemy_X_Max*7+10'd6 - Enemy_X_Size;
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = location_in - left_bound;
							else
								Enemy_X_Pos_in = - (14'd30);
						end
						else
						begin
							location_in = location + Enemy_X_Step;
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = location_in - left_bound;
							else
								Enemy_X_Pos_in = - (14'd30);
						end
					end
					else
					begin
						location_in = location + Enemy_X_Step;
						if (10'd320 + location - player_location + Enemy_X_Size <= 10'd320)
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = location_in - left_bound;
							else
								Enemy_X_Pos_in = - (14'd30);
						else
							if (location_in >= left_bound && location_in <= right_bound)
								Enemy_X_Pos_in = location_in - left_bound;
							else
								Enemy_X_Pos_in = - (14'd30);
					end
					
					//HIT DETECT RIGHT
					for (int i = 1; i < 16; i++)
					begin
						if ((location + Enemy_X_Size) < platform_change[i][0])
						begin
							if (i == 15)
							begin
								debug1 = 1'b1;
								break;
							end
							
							//JUMP
							if ((location + Enemy_X_Step + Enemy_X_Size + 2'd2) >= platform_change[i][0])
							begin
								OOB = Enemy_Y_Pos - 10'd200;
								if (Enemy_Y_Pos + Enemy_Y_Size >=Enemy_top - 1'b1)
								begin
									if (OOB == 0 || OOB[13] == 1'b1)
										Enemy_Y_Pos_in = Enemy_Y_Min + Enemy_Y_Step;
									else
										Enemy_Y_Pos_in = Enemy_Y_Pos - 10'd200;
								end
								else
									Enemy_Y_Pos_in = Enemy_Y_Pos + Enemy_Y_Step;
							end
							
							if ((location + Enemy_X_Step + Enemy_X_Size) >= platform_change[i][0])
							begin
								debug2 = 1'b1;
								if (Enemy_Y_Pos > platform_change[i][1] && Enemy_Y_Pos < platform_change[i][2])
								begin
									debug3 = 1'b1;
									debug_plat1 = platform_change[i][1];
									location_in = platform_change[i][0] - 1'b1 - Enemy_X_Size;
									if (location_in >= left_bound && location_in <= right_bound)
										Enemy_X_Pos_in = location_in - left_bound;
									else
										Enemy_X_Pos_in = - (14'd30);
								end
								else if ((Enemy_Y_Pos - Enemy_Y_Size) > platform_change[i][1] && (Enemy_Y_Pos - Enemy_Y_Size) < platform_change[i][2])
								begin
									debug4 = 1'b1;
									location_in = platform_change[i][0] - 1'b1 - Enemy_X_Size;
									if (Enemy_Y_Pos > platform_change[i][1] && Enemy_Y_Pos < platform_change[i][2])
									begin
										location_in = platform_change[i][0] - 1'b1 - Enemy_X_Size;
										if (location_in >= left_bound && location_in <= right_bound)
											Enemy_X_Pos_in = location_in - left_bound;
										else
											Enemy_X_Pos_in = - (14'd30);
									end
								end
								else if ((Enemy_Y_Pos + Enemy_Y_Size) > platform_change[i][1] && (Enemy_Y_Pos + Enemy_Y_Size) < platform_change[i][2])
								begin
									debug5 = 1'b1;
									location_in = platform_change[i][0] - 1'b1 - Enemy_X_Size;
									if (location_in >= left_bound && location_in <= right_bound)
										Enemy_X_Pos_in = location_in - left_bound;
									else
										Enemy_X_Pos_in = - (14'd30);
								end
							end
							break;
						end
					end
				end
					
				if ((player_location + Enemy_X_Size >= location - Enemy_X_Size) || 
					 (player_location - Enemy_X_Size <= location + Enemy_X_Size))
				begin	
					
//					if( attack_shield == 10'd0)	// W: Move up
//					begin
//						if (Enemy_Y_Pos + Enemy_Y_Size >=  Enemy_top - 1'b1)
//							Enemy_Y_Motion_in = (~(10'd80) + 1'b1);
//						else
//							Enemy_Y_Motion_in = Enemy_Y_Step;	
//					end
						
					if ( attack_shield == 10'd1)	// S: Use shield
					begin
						shield_in = 1'b1;
						attack_in = 1'b0;
						//Enemy_Y_Motion_in = Enemy_Y_Motion_in;					
					end	
						
					if ( attack_shield == 10'd2)	// Space: Attack
					begin
						shield_in = 1'b0;
						attack_in = 1'b1;
						//Enemy_Y_Motion_in = Enemy_Y_Motion_in;	
					end
					
				end
				
				if (((player_location + Enemy_X_Size <= location + Enemy_X_Size 
						&&	player_location + Enemy_X_Size >= location - Enemy_X_Size) 
						||	(player_location - Enemy_X_Size <= location + Enemy_X_Size
						&& player_location - Enemy_X_Size >= location - Enemy_X_Size)) 
						&&	((player_location + Enemy_Y_Size <= location + Enemy_Y_Size 
						&& player_location + Enemy_Y_Size >= location - Enemy_Y_Size)
						|| (player_location - Enemy_Y_Size <= location + Enemy_Y_Size
						&& player_location - Enemy_Y_Size >= location - Enemy_Y_Size))
						&& hit_en && attack)
				begin
					ball_HP_in = 3'b1;
				end
				else
				begin
					ball_HP_in = 3'b0;
				end
        end
    end
    
    // Compute whether the pixel corresponds to enemy or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, SizeX, SizeY;
	 assign DistX = DrawX - Enemy_X_Pos; //location;
    assign DistY = DrawY - Enemy_Y_Pos;
    assign SizeX = Enemy_X_Size;
	 assign SizeY = Enemy_Y_Size;
    always_comb begin
		  is_enemy = 1'b0;
		  if ( (DistX*DistX <= SizeX*SizeX) && (DistY*DistY <= SizeY*SizeY)) 
            is_enemy = 1'b1;
		  else
				is_enemy = 1'b0;
    end
	 
	 assign enemy_location = location;
	 assign is_enemy_shield = shield;
	 assign is_enemy_attack = attack;
	 
	 assign ball_health_in = ball_HP_in;
				
endmodule