//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper4Sprite (// input              is_ball,            // Whether current pixel belongs to ball
							  input 					Clk,		//ADD
							  input 					Reset,	//ADD
							  input					is_shield,			 // whether player is using shield
														is_attack[0:3],		    // whether player is attacking
							  input	logic [2:0] health_out, 
							  input	logic[13:0] Ball_X, Ball_Y, 
							  input 					ball_direction,
														game_over,

							  // input					is_enemy[0:3],
							  input					is_enemy_shield[0:3],			 // whether enemy is using shield
														is_enemy_attack[0:3],		    // whether enemy is attacking 					
							  input					dead[0:3],
														all_dead,
							  input	logic[13:0] Enemy_X[0:3], Enemy_Y[0:3], 	
							  input					direction[0:3],
														
							  input 					is_platform,
							  input	logic[13:0] left_bound,								//ADD
							  input  logic[13:0] platform_change[0:15][0:2],		//ADD
							  
							  input[7:0]			keycode,
							  
							  input					changeFrame,
							  
							  input  logic [4:0] data_Out,
							  output logic [18:0]read_address,
							  
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output	  
                     );
    
    logic [7:0] Red, Green, Blue;
	 
	 logic [23:0] palette_hex[0:19];
	 /*assign pallete_hex = 
	 '{24'hffffff, 24'h7b100c, 24'hc58564, 24'hca6225, 24'hfd9737, 24'hf4cda0, 24'h4b1400, 24'h000000, 
		24'hff0000, 24'h888888, 24'h323232};*/
	 
	 assign palette_hex = '{24'hffffff, 24'h000000, 24'h323232, 24'h888888, 24'h7b100c, 
									24'hff0000, 24'hc58564, 24'h4b1400, 24'hbb8044, 24'hc58f5c, 
									24'hc99869, 24'hca6225, 24'hc25820, 24'hf79534, 24'hF9953B,
									24'hfb9533, 24'hfd9737, 24'hf5cea1, 24'h80be1f, 24'h93db24}; 

	 parameter [9:0] Ball_X_Size = 10'd20;        // BallX size 
	 parameter [9:0] Ball_Y_Size = 10'd30;        // BallY size
	 parameter [9:0] Enemy_X_Size = 10'd20;       // EnemyX size 
	 parameter [9:0] Enemy_Y_Size = 10'd30;       // EnemyY size
	 
	 
	 parameter [9:0] idle_SpriteX = 10'd0;
	 parameter [9:0] move_SpriteX = 10'd40;
	 parameter [9:0] attack_SpriteX = 10'd160;
	 parameter [9:0] shield_SpriteX = 10'd200;
	 parameter [9:0] dead_SpriteX = 10'd40;
	 
	 parameter [9:0] player_RightY = 10'd0;
	 parameter [9:0] player_LeftY = 10'd60;
	 parameter [9:0] enemy_RightY = 10'd120;
	 parameter [9:0] enemy_LeftY = 10'd180;
	 parameter [9:0] otherY = 10'd240;
				
				
	 logic is_ball, is_enemy[0:3];
	 logic [9:0] SpriteX, SpriteY;
	 
	 logic [13:0] top;
	 logic [7:0] countX, countX_in, countX_prev, countX_beg;
	 logic [13:0] y_diff;
	 logic [13:0] left_bound_prev, left_bound_prev_in;
									
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, SizeX, SizeY, ShapeX, ShapeY;
	 assign DistX = DrawX - Ball_X;
    assign DistY = DrawY - Ball_Y;
    assign SizeX = Ball_X_Size;
	 assign SizeY = Ball_Y_Size;
	 assign ShapeX = Ball_X - SizeX;
	 assign ShapeY = Ball_Y - SizeY;
	 
	 int Enemy_DistX[0:3], Enemy_DistY[0:3], Enemy_SizeX, Enemy_SizeY, Enemy_ShapeX[0:3], Enemy_ShapeY[0:3];
	 assign Enemy_DistX[0] = DrawX - Enemy_X[0]; //location;
	 assign Enemy_DistY[0] = DrawY - Enemy_Y[0];
	 assign Enemy_DistX[1] = DrawX - Enemy_X[1]; //location;
	 assign Enemy_DistY[1] = DrawY - Enemy_Y[1];
	 assign Enemy_DistX[2] = DrawX - Enemy_X[2]; //location;
	 assign Enemy_DistY[2] = DrawY - Enemy_Y[2];
	 assign Enemy_DistX[3] = DrawX - Enemy_X[3]; //location;
	 assign Enemy_DistY[3] = DrawY - Enemy_Y[3];
    assign Enemy_SizeX = Enemy_X_Size;
	 assign Enemy_SizeY = Enemy_Y_Size;
	 assign Enemy_ShapeX[0] = Enemy_X[0] - Enemy_SizeX;
	 assign Enemy_ShapeY[0] = Enemy_Y[0] - Enemy_SizeY;
	 assign Enemy_ShapeX[1] = Enemy_X[1] - Enemy_SizeX;
	 assign Enemy_ShapeY[1] = Enemy_Y[1] - Enemy_SizeY;
	 assign Enemy_ShapeX[2] = Enemy_X[2] - Enemy_SizeX;
	 assign Enemy_ShapeY[2] = Enemy_Y[2] - Enemy_SizeY;
	 assign Enemy_ShapeX[3] = Enemy_X[3] - Enemy_SizeX;
	 assign Enemy_ShapeY[3] = Enemy_Y[3] - Enemy_SizeY;
	 
	 always_ff @ (posedge Clk)
	 begin
		if (countX == 8'd39 || Reset)
		begin
			countX <= 8'b0;
			countX_beg <= 8'b0;
		end
		else if (DrawX == 10'b0 && DrawY == 10'b0)
		begin
			countX_beg <= countX_prev + (left_bound - left_bound_prev);
			countX <= countX;
		end
		else if (DrawX == 10'b0)
		begin
			countX <= countX_beg;
			countX_beg <= countX_beg;
		end
		else
		begin
			countX_beg <= countX_beg;
			countX <= countX_in;
		end
	 end
	 
	 always_ff @ (posedge Clk)
	 begin
		if (Reset)
		begin
			left_bound_prev <= 10'b0;
			countX_prev <= 8'b0;
		end

		else if (DrawY == 10'd479 && DrawX == 10'd639)
		begin
			left_bound_prev <= left_bound;
			countX_prev <= countX_beg;
		end
		else
			left_bound_prev <= left_bound_prev;
			countX_prev <= countX_prev;
	 end
	 
	 
    always_comb begin
		  // Player sprite '
		  y_diff = 14'b0;
		  top = 14'b0;
		  if ((DistX*DistX <= SizeX*SizeX) && (DistY*DistY <= SizeY*SizeY)) 
		  begin
            is_ball = 1'b1;
				is_enemy[0] = 1'b0;
				is_enemy[1] = 1'b0;
				is_enemy[2] = 1'b0;
				is_enemy[3] = 1'b0;
				
				
				if (ball_direction == 1'b1)	// Player is moving right
				begin
					if (keycode == 8'd07)
					begin
						SpriteX = move_SpriteX + (DrawX - ShapeX);
						SpriteY = player_RightY + (DrawY - ShapeY);
					end
					else if (is_attack[0] == 1'b1 || is_attack[1] == 1'b1 || is_attack[2] == 1'b1 || is_attack[3] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - ShapeX);
						SpriteY = player_RightY + (DrawY - ShapeY);
					end	
					else if (is_shield == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - ShapeX);
						SpriteY = player_RightY + (DrawY - ShapeY);
					end			
					else if (game_over == 1'b1)
					begin
						SpriteX = dead_SpriteX + (DrawX - ShapeX);
						SpriteY = otherY + (DrawY - ShapeY);
					end				
					else 
					begin
						SpriteX = idle_SpriteX + (DrawX - ShapeX);
						SpriteY = player_RightY + (DrawY - ShapeY);
					end
				end
				else 						// Player is moving left
				begin
					if (keycode == 8'd04)
					begin
						SpriteX = move_SpriteX + (DrawX - ShapeX);
						SpriteY = player_LeftY + (DrawY - ShapeY);
					end
					else if (is_attack[0] == 1'b1 || is_attack[1] == 1'b1 || is_attack[2] == 1'b1 || is_attack[3] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - ShapeX);
						SpriteY = player_LeftY + (DrawY - ShapeY);
					end	
					else if (is_shield == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - ShapeX);
						SpriteY = player_LeftY + (DrawY - ShapeY);
					end			
					else if (game_over == 1'b1)
					begin
						SpriteX = dead_SpriteX + (DrawX - ShapeX);
						SpriteY = otherY + (DrawY - ShapeY);
					end				
					else 
					begin
						SpriteX = idle_SpriteX + (DrawX - ShapeX);
						SpriteY = player_LeftY + (DrawY - ShapeY);
					end
				end	
        end
		  // Enemy sprites
		  else if ((Enemy_DistX[0]*Enemy_DistX[0] <= Enemy_SizeX*Enemy_SizeX) && 
					  (Enemy_DistY[0]*Enemy_DistY[0] <= Enemy_SizeY*Enemy_SizeY) && ~dead[0])
		  begin
				is_ball = 1'b0;
				is_enemy[0] = 1'b1;
				is_enemy[1] = 1'b0;
				is_enemy[2] = 1'b0;
				is_enemy[3] = 1'b0;
				
				if (direction[0] == 1'b1)	// Enemy0 is moving right
				begin
					if (is_enemy_attack[0] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[0]);
					end	
					else if (is_enemy_shield[0] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[0]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[0]);
					end
				end
				else 					// Enemy0 is moving left
				begin
					if (is_enemy_attack[0] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[0]);
					end	
					else if (is_enemy_shield[0] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[0]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[0]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[0]);
					end
				end	
		  end
		  else if ((Enemy_DistX[1]*Enemy_DistX[1] <= Enemy_SizeX*Enemy_SizeX) && 
					  (Enemy_DistY[1]*Enemy_DistY[1] <= Enemy_SizeY*Enemy_SizeY) && ~dead[1])
		  begin
				is_ball = 1'b0;
				is_enemy[0] = 1'b0;
				is_enemy[1] = 1'b1;
				is_enemy[2] = 1'b0;
				is_enemy[3] = 1'b0;
			
				if (direction[1] == 1'b1)	// Enemy1 is moving right
				begin
					if (is_enemy_attack[1] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[1]);
					end	
					else if (is_enemy_shield[1] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[1]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[1]);
					end
				end
				else 								// Enemy1 is moving left
				begin
					if (is_enemy_attack[1] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[1]);
					end	
					else if (is_enemy_shield[1] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[1]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[1]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[1]);
					end
				end	
		  end
		  else if ((Enemy_DistX[2]*Enemy_DistX[2] <= Enemy_SizeX*Enemy_SizeX) && 
					  (Enemy_DistY[2]*Enemy_DistY[2] <= Enemy_SizeY*Enemy_SizeY) && ~dead[2])
		  begin
				is_ball = 1'b0;
				is_enemy[0] = 1'b0;
				is_enemy[1] = 1'b0;
				is_enemy[2] = 1'b1;
				is_enemy[3] = 1'b0;
				
				if (direction[2] == 1'b1)	// Enemy2 is moving right
				begin
					if (is_enemy_attack[2] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[2]);
					end	
					else if (is_enemy_shield[2] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[2]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[2]);
					end
				end
				else 							// Enemy2 is moving left
				begin
					if (is_enemy_attack[2] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[2]);
					end	
					else if (is_enemy_shield[2] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[2]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[2]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[2]);
					end
				end	
		  end
		  else if ((Enemy_DistX[3]*Enemy_DistX[3] <= Enemy_SizeX*Enemy_SizeX) && 
					  (Enemy_DistY[3]*Enemy_DistY[3] <= Enemy_SizeY*Enemy_SizeY) && ~dead[3])
		  begin
				is_ball = 1'b0;
				is_enemy[0] = 1'b0;
				is_enemy[1] = 1'b0;
				is_enemy[2] = 1'b0;
				is_enemy[3] = 1'b1;
				
				if (direction[3] == 1'b1)	// Enemy3 is moving right
				begin
					if (is_enemy_attack[3] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[3]);
					end	
					else if (is_enemy_shield[3] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[3]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_RightY + (DrawY - Enemy_ShapeY[3]);
					end
				end
				else 							// Enemy3 is moving left
				begin
					if (is_enemy_attack[3] == 1'b1)
					begin
						SpriteX = attack_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[3]);
					end	
					else if (is_enemy_shield[3] == 1'b1)
					begin
						SpriteX = shield_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[3]);
					end							
					else 
					begin
						SpriteX = move_SpriteX + (DrawX - Enemy_ShapeX[3]);
						SpriteY = enemy_LeftY + (DrawY - Enemy_ShapeY[3]);
					end
				end	
		  end
		  // Platform sprites
		  else if (is_platform)
		  begin
				for (int i = 1; i < 16; i++)		//get the top and bot based off player location
				begin
					if (DrawX + left_bound < platform_change[i][0])
					begin
						top = platform_change[i-1][1];
						break;
					end
				end
				if (DrawY >= top + 8'd40)
				begin
					y_diff = DrawY - top;
					SpriteY = (y_diff % 8'd41);
					SpriteX = countX + 19'd62040;
					countX_in = countX + 1'b1;
					
				end
				else
				begin
					y_diff = DrawY - top;
					SpriteY = (y_diff % 8'd41);
					SpriteX = countX + 19'd62000;
					countX_in = countX + 1'b1;
				end
		  end
		  else 
		  begin
				is_ball = 1'b0;
				is_enemy[0] = 1'b0;
				is_enemy[1] = 1'b0;
				is_enemy[2] = 1'b0;
				is_enemy[3] = 1'b0;
		  
//				SpriteX = 10'd121;
//				SpriteY = 10'd271;
				
				SpriteX = 10'd0;
				SpriteY = 10'd0;
		  end
    end

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 assign read_address = (is_ball == 1'b1)? (SpriteY - 1'b1) * 10'd240 + (SpriteX) : SpriteY * 10'd240 + SpriteX;
    
    // Assign color based on is_ball signal
    always_comb
    begin
		if (palette_hex[data_Out] != 24'hffffff && is_platform != 1'b1)
		begin
		  Red = palette_hex[data_Out][23:16];
		  Green = palette_hex[data_Out][15:8];
		  Blue = palette_hex[data_Out][7:0];
		end
//		if (is_platform != 1'b1)
//		begin
//			if (palette_hex[data_Out] != 24'hffffff)	
//			begin
//				Red = palette_hex[data_Out][23:16];
//				Green = palette_hex[data_Out][15:8];
//				Blue = palette_hex[data_Out][7:0];
//			end
//			else
//			begin
//				Red = 8'h00; 
//				Green = 8'hbf;
//				Blue = 8'hff - {1'b0, DrawX[9:3]};
//			end
//		end
		else if (is_platform == 1'b1)
		begin
			Red = palette_hex[data_Out][23:16];
			Green = palette_hex[data_Out][15:8];
			Blue = palette_hex[data_out][7:0];
		end
		
		else if (DrawY <= 10'd10 && DrawX <= 10'd50)
		begin
			if (DrawX <= (health_out*10)
			begin
				Red = 8'b00;
				Green = 8'hff;
				Blue = 8'h00;
			end
			else
			begin
				Red = 8'hff;
				Green = 8'h00;
				Blue = 8'h00;
			end
		end
		
		else  
		begin
			Red = 8'h00; 
			Green = 8'hbf;
			Blue = 8'hff - {1'b0, DrawX[9:3]};
		end
	end 
 
endmodule
