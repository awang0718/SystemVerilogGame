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
//				input[13:0] 	top,
				input[13:0] 	platform_change[0:15][0:2],
				
				output 			is_enemy,
				output 		   is_enemy_shield,			 // whether enemy is using shield
				output 	   	is_enemy_attack,		    // whether enemy is attacking 
				output[13:0] 	enemy_location,
				input[13:0] 	player_location,
				
				input 			dead,
				input		 		hit_en	
);

	 parameter [13:0] Enemy_X_Size = 10'd20;        // Enemyx size 
	 parameter [13:0] Enemy_Y_Size = 10'd30;        // Enemyy size
	 parameter [13:0] Enemy_Y_shield = 10'd15;		 // enemyY shrink (from shield);  

    parameter [13:0] Enemy_X_Start = 13'd3600;  // Start position on the X axis
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
	 
	 logic hit, hit_in;
	 logic appears, appears_in;
	 
	 logic[9:0] Enemy_top, Enemy_top_in;
	 logic[16:0] attack_shield, attack_shield_in;
    
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
            // Enemy_X_Motion <= 10'd0;
            Enemy_Y_Motion <= 10'd0;
				location <= Enemy_X_Start;
				Enemy_top <= platform_change[0][1];
				
				shield <= 1'd0;
				attack <= 1'd0;
				attack_shield <= 16'd0;

				hit <= 1'b0;
				appears <= 1'b1;
        end
        else
        begin
            Enemy_X_Pos <= Enemy_X_Pos_in;
            Enemy_Y_Pos <= Enemy_Y_Pos_in;
            // Enemy_X_Motion <= Enemy_X_Motion_in;
            Enemy_Y_Motion <= Enemy_Y_Motion_in;
				location <= location_in;
				Enemy_top <= Enemy_top_in;
				
				shield <= shield_in;
				attack <= attack_in;	
				attack_shield <= attack_shield_in;

				hit <=  hit_in;//ball_HP_in;
				appears <= appears_in;
        end
    end
	 
	 // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Enemy_X_Pos_in = Enemy_X_Pos;
        Enemy_Y_Pos_in = Enemy_Y_Pos;
        // Enemy_X_Motion_in = Enemy_X_Motion;
        Enemy_Y_Motion_in = Enemy_Y_Motion;
		  location_in = location; 
        //Enemy_Y_Motion_in = /*Enemy_Y_Motion +*/ 1'b0;
		  
		  shield_in = shield;
		  attack_in = attack;
		  attack_shield_in = attack_shield;
		  
		  hit_in = hit;
		  appears_in = appears;
		  
		  Enemy_top_in = Enemy_top;
        
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				// Enemy_X_Motion_in = 10'd0;
				Enemy_Y_Motion_in = 10'd0;
				location_in = location;
				
				shield_in = 1'b0;
				attack_in = 1'b0;
				attack_shield_in = location % 3;
				
				Enemy_Y_Pos_in = Enemy_Y_Pos + Enemy_Y_Motion;
			
				// if (location >= Enemy_X_Start - 10'd480 && location <= Enemy_X_Start + 10'd850)
				if (location >= 13'd3120 && location <= 13'd4453)
					appears_in = 1'b1;
				else
					appears_in = 1'b0;
				
				for (int i = 0; i < 15; i++)
					begin
						if ( location >= platform_change[i][0] + Enemy_X_Size && location + Enemy_X_Size < platform_change[i+1][0])
						begin
							Enemy_top_in = platform_change[i][1];			
							break;
						end;
					end

				if (Enemy_Y_Pos + Enemy_Y_Size < /*top*/Enemy_top - 1'b1 /*Enemy_Y_Max*/)
					begin
						// Enemy_X_Pos_in = Enemy_X_Pos + Enemy_X_Motion;
						Enemy_Y_Motion_in = /*Enemy_Y_Motion + 10'd4;*/Enemy_Y_Step; //Enemy_Y_Pos - 10'd240;//
					end
//				else
//					begin
//						Enemy_Y_Pos_in = top - Enemy_Y_Size;
//						Enemy_Y_Motion_in = 0;			
//					end				
		  
            if (Enemy_Y_Pos + Enemy_Y_Motion + Enemy_Y_Size >/*=*/ /*top*/Enemy_top - 1'b1 /*Enemy_Y_Max*/)  // Ball is at the bottom edge
               begin
						// Enemy_Y_Motion_in = (~(Enemy_Y_Step) + 1'b1);
						Enemy_Y_Motion_in = 1'b0;
						Enemy_Y_Pos_in = /*top*/Enemy_top - 1'b1 - Enemy_Y_Size;
					end  // 2's complement.  

            if (Enemy_Y_Pos <= Enemy_Y_Min + 1'b1 + Enemy_Y_Size + Enemy_Y_Motion )  // Ball is at the top edge
               begin
						//Enemy_Y_Motion_in = 1'b0;
						Enemy_Y_Motion_in = Enemy_Y_Step;
					end			
				
				// if (direction == 2'b10 /*&& enemy_can_move*/)	// A: Move left
				if (player_location + Enemy_X_Size < location - Enemy_X_Size)	// A: Move left
					begin
						attack_shield_in = 10'd4;
						if ((can_move) || (!can_move && keycode == 8'd07) || (!can_move && keycode == 8'd00) 
							|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
							begin
								if ((player_location <= Enemy_X_Max/2) && (/*Enemy_X_Pos /*+ Enemy_X_Motion*/ location <= Enemy_X_Min + 1'b1 + Enemy_X_Size)) // Ball is at the left edge
								// if ( enemy_location /*+ Enemy_X_Motion*/ <= Enemy_X_Min + 1'b1 + Enemy_X_Size ) // Ball is at the left edge
									begin	
										Enemy_X_Pos_in = Enemy_X_Min + Enemy_X_Size;
										location_in = Enemy_X_Min + Enemy_X_Size;
									end
								else
									begin
										// Enemy_X_Pos_in = Enemy_X_Pos - Enemy_X_Step;
										location_in = location - Enemy_X_Step;	
										Enemy_X_Pos_in = Ball_X + location - player_location;
									end
							end
						else
							begin	
								// Enemy_X_Pos_in = Enemy_X_Pos;
								location_in = location - Enemy_X_Step;								
								// if (10'd320 + location - player_location - Enemy_X_Size <= 10'd639)
								if (location - player_location <= 10'd320)
									Enemy_X_Pos_in = 10'd320 + location - player_location;
								else
									Enemy_X_Pos_in = Enemy_X_Max + Enemy_X_Size + 10'd3;
								
//								if (location > Enemy_X_Start - 10'd320)
//									begin
//										location_in = location - Enemy_X_Step;		
//										Enemy_X_Pos_in = 10'd320 + location - player_location;
//									end
//								else
//									begin
//										location_in = location;
//										Enemy_X_Pos_in = Enemy_X_Max + Enemy_X_Size + 10'd3;
//									end
//								// Enemy_X_Pos_in = 10'd320 + location - player_location;			
							end			
					end
					
				// if (direction == 2'b01 /*&& enemy_can_move*/)	// D: Move right
				if (player_location - Enemy_X_Size > location + Enemy_X_Size)	// A: Move right
					begin
						attack_shield_in = 10'd4;
						if (can_move || (!can_move && keycode == 8'd04)  || (!can_move && keycode == 8'd00)
							|| (!can_move && keycode == 8'd22) || (!can_move && keycode == 8'd44) || (!can_move && keycode == 8'd26))
							begin
								if((player_location >= Enemy_X_Max*7+10'd6 - Enemy_X_Max/2) && (/*Enemy_X_Pos /*+ Enemy_X_Motion*/ location + Enemy_X_Size >= Enemy_X_Max*7+10'd6 - 1'b1)) // Ball is at the right edge
								// if( enemy_location /*+ Enemy_X_Motion*/ + Enemy_X_Size >= Enemy_X_Max*7 - 1'b1) // Ball is at the right edge
									begin	
										Enemy_X_Pos_in = Enemy_X_Max - Enemy_X_Size;
										location_in = Enemy_X_Max*7+10'd6 - Enemy_X_Size;
									end
								else
									begin
										// Enemy_X_Pos_in = Enemy_X_Pos + Enemy_X_Step;
										location_in = location + Enemy_X_Step;
										Enemy_X_Pos_in = Ball_X + location - player_location;
									end
							end
						else
							begin
								// Enemy_X_Pos_in = Enemy_X_Pos;
								location_in = location + Enemy_X_Step;
								if (10'd320 + location - player_location + Enemy_X_Size <= 10'd320)
									Enemy_X_Pos_in = 10'd320 + location - player_location;
								else
									Enemy_X_Pos_in = (~(Enemy_X_Max) + 1'b1);
									
//								if (location < Enemy_X_Start + 10'd320)
//									begin
//										location_in = location + Enemy_X_Step;		
//										Enemy_X_Pos_in = 10'd320 + location - player_location;
//									end
//								else
//									begin
//										location_in = location;
//										Enemy_X_Pos_in = Enemy_X_Max + Enemy_X_Size + 10'd3;
//									end
//								// Enemy_X_Pos_in = 10'd320 + location - player_location;
							end
					end
					
				if ((player_location + Enemy_X_Size >= location - Enemy_X_Size) || 
					 (player_location - Enemy_X_Size <= location + Enemy_X_Size))
					begin	
					
					if(/*jump*/ attack_shield == 10'd0)	// W: Move up
						begin
							if (Enemy_Y_Pos + Enemy_Y_Size >= /*Enemy_Y_Max*/ Enemy_top - 1'b1)
								Enemy_Y_Motion_in = (~(10'd80) + 1'b1);
							else
								Enemy_Y_Motion_in = Enemy_Y_Step;	
						end
						
					if (/*enemy_shield*/ attack_shield == 10'd1)	// S: Use shield
						begin
							shield_in = 1'b1;
							attack_in = 1'b0;
							Enemy_Y_Motion_in = Enemy_Y_Motion_in;					
						end	
						
					if (/*enemy_attack*/ attack_shield == 10'd2)	// Space: Attack
						begin
							shield_in = 1'b0;
							attack_in = 1'b1;
							Enemy_Y_Motion_in = Enemy_Y_Motion_in;	
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
						hit_in = 1'b1;
					end
				else
					begin
						hit_in = 1'b0;
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
		  // if (DistX <= SizeX && DistY <= SizeY) 
		  if ( (DistX*DistX <= SizeX*SizeX) && (DistY*DistY <= SizeY*SizeY) && appears && ~dead) 
            is_enemy = 1'b1;
        else
            is_enemy = 1'b0;
    end
	 
	 assign enemy_location = location;
	 assign is_enemy_shield = shield;
	 assign is_enemy_attack = attack && hit && appears;

	 // assign ball_health_in = ball_HP_in;
				
endmodule