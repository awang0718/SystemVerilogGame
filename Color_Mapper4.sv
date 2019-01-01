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
module  color_mapper4 (input              is_ball,            // Whether current pixel belongs to ball
							  input					is_shield,			 // whether player is using shield
														is_attack[0:3],		    // whether player is attacking
							  input	logic [2:0] health_out, 
							  input					is_enemy[0:3],
							  input					is_enemy_shield[0:3],			 // whether enemy is using shield
														is_enemy_attack[0:3],		    // whether enemy is attacking 					
							  input					game_over,
														dead[0:3],
														all_dead,
							  input 					is_platform,
							  input					direction[0:3],
							  
							  input					changeFrame,
							  
//							  input  logic [4:0] data_Out,
//							  output logic [18:0]read_address,
							  
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

    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    
    // Assign color based on is_ball signal
    always_comb
    begin
        if (is_ball == 1'b1) 
        begin
				if (is_attack[0] == 1'b1 || is_attack[1] == 1'b1 || is_attack[2] == 1'b1 || is_attack[3] == 1'b1)
				begin
					// Red ball
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'h00;
				end
				else if (is_shield == 1'b1)
				begin
					// Green ball
					Red = 8'h00;
					Green = 8'hff;
					Blue = 8'h00;
				end			
				else if (game_over == 1'b1)
				begin
					// Black ball
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end				
				else 
				begin
					// White ball
					Red = 8'hff;
					Green = 8'hff;
					Blue = 8'hff;
				end
        end
//		  // else if (is_enemy[0] == 1'b1 || is_enemy[1] == 1'b1 || is_enemy[2] == 1'b1 || is_enemy[3] == 1'b1)
//		  // begin
//			  for (int i = 0; i < 4; i++)
//			  begin
//				  if (is_enemy[i] == 1'b1)
//				  begin			
//						if (is_enemy_attack[i] == 1'b1)
//						begin
//							// Magenta enemy
//							Red = 8'hff;
//							Green = 8'h00;
//							Blue = 8'hff;
//						end
//						else if (is_enemy_shield[i] == 1'b1)
//						begin
//							// Dark Green enemy
//							Red = 8'h00;
//							Green = 8'h64;
//							Blue = 8'h00;
//						end
//						else if (dead[i] == 1'b1)
//						begin
//							// Black ball
//							Red = 8'h00;
//							Green = 8'h00;
//							Blue = 8'h00;
//						end
//						else 
//						begin
//							// Grey enemy
//							Red = 8'h80;
//							Green = 8'h80;
//							Blue = 8'h80;
//						end
//				  end
//			  end
		  // end 
		  // else 
		  else if (is_enemy[0] == 1'b1)
		  begin			
				if (is_enemy_attack[0] == 1'b1)
				begin
					// Magenta enemy
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end
				else if (is_enemy_shield[0] == 1'b1)
				begin
					// Dark Green enemy
					Red = 8'h00;
					Green = 8'h64;
					Blue = 8'h00;
				end
				else if (dead[0] == 1'b1)
				begin
					// Black ball
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				else 
				begin
					// Grey enemy
					Red = 8'h80;
					Green = 8'h80;
					Blue = 8'h80;
				end
		  end
		  else if (is_enemy[1] == 1'b1)
		  begin			
				if (is_enemy_attack[1] == 1'b1)
				begin
					// Magenta enemy
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end
				else if (is_enemy_shield[1] == 1'b1)
				begin
					// Dark Green enemy
					Red = 8'h00;
					Green = 8'h64;
					Blue = 8'h00;
				end
				else if (dead[1] == 1'b1)
				begin
					// Black ball
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				else 
				begin
					// Grey enemy
					Red = 8'h80;
					Green = 8'h80;
					Blue = 8'h80;
				end
		  end
		  else if (is_enemy[2] == 1'b1)
		  begin			
				if (is_enemy_attack[2] == 1'b1)
				begin
					// Magenta enemy
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end
				else if (is_enemy_shield[2] == 1'b1)
				begin
					// Dark Green enemy
					Red = 8'h00;
					Green = 8'h64;
					Blue = 8'h00;
				end
				else if (dead[2] == 1'b1)
				begin
					// Black ball
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				else 
				begin
					// Grey enemy
					Red = 8'h80;
					Green = 8'h80;
					Blue = 8'h80;
				end
		  end
		  		  else if (is_enemy[3] == 1'b1)
		  begin			
				if (is_enemy_attack[3] == 1'b1)
				begin
					// Magenta enemy
					Red = 8'hff;
					Green = 8'h00;
					Blue = 8'hff;
				end
				else if (is_enemy_shield[3] == 1'b1)
				begin
					// Dark Green enemy
					Red = 8'h00;
					Green = 8'h64;
					Blue = 8'h00;
				end
				else if (dead[3] == 1'b1)
				begin
					// Black ball
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
				else 
				begin
					// Grey enemy
					Red = 8'h80;
					Green = 8'h80;
					Blue = 8'h80;
				end
		  end
		  else if (is_platform == 1'b1)
		  begin
				// blue platform
				Red = 8'hff;
				Green = 8'h63;
				Blue = 8'h47;
		  end
        else // if (is_ball == 1'b0 || is_enemy[0] == 1'b0 || is_enemy[1] == 1'b0 || is_enemy[2] == 1'b0 || is_enemy[3] == 1'b0 || is_platform == 1'b0)
        begin
            // Background with nice color gradient
//            Red = 8'h3f; 
//            Green = 8'h00;
//            Blue = 8'h7f - {1'b0, DrawX[9:3]};
				Red = 8'h00; 
            Green = 8'hbf;
            Blue = 8'hff - {1'b0, DrawX[9:3]};
        end
    end 
    
endmodule
