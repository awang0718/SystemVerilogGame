//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball2 ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input [7:0]   keycode,				// Keyboard input
					input 		  can_move,
					input logic[13:0] top,
					input logic[13:0] platform_change[0:15][0:2],
					input logic[13:0] excess,
					input logic[13:0] top_left,
					input logic[13:0] top_right,
					
               output logic  is_ball,            // Whether current pixel belongs to ball or background
					output logic  is_shield,			 // whether player is using shield
					output logic  is_attack,		    // whether player is attacking
					output logic[13:0] player_location,
					output logic  is_move,
					output logic[13:0] excess_is_move
              );
    
	 parameter [9:0] Ball_X_Size = 10'd15;        // BallX size 
	 parameter [9:0] Ball_Y_Size = 10'd30;        // BallY size
	 parameter [9:0] Ball_Y_shield = 10'd15;		 // BallY shrink (from shield);  

    parameter [9:0] Ball_X_Start = 10'd320;  // Start position on the X axis
    //parameter [13:0] Ball_X_Start = 10'd2700;  // Start position on the X axis
    //parameter [9:0] Ball_Y_Start = 10'd479 - Ball_Y_Size;  	// Start position on the Y axis
	 parameter [13:0] Ball_Y_Start = 10'd300 - Ball_Y_Size;  	// Start position on the Y axis
	 //parameter [13:0] Ball_Y_Start = 10'd340 - Ball_Y_Size;  	// Start position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step = 10'd6;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step = 10'd6;      // Step size on the Y axis   
    
	 
    logic[13:0] Ball_X_Pos, Ball_Y_Pos, Ball_Y_Motion;
    logic[13:0] Ball_X_Pos_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic[13:0] location, location_in;
	 
	 logic shield, shield_in, attack, attack_in;
	 logic Ball_Y_SizeReal, Ball_Y_SizeReal_in;
	 
	 logic[13:0] OOB;
	 
	 //DEBUG
	 logic debugb1, debugb2, debugb3, debugb4, debugb5;
	 logic debugb1_in, debugb2_in, debugb3_in, debugb4_in, debugb5_in;
	 logic[9:0] debugb_Y;
	 
	 //logic[13:0] excess_is_move_in;
	 
	 //logic is_move_in;
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
            Ball_X_Pos <= Ball_X_Start;
            Ball_Y_Pos <= Ball_Y_Start;
            //Ball_Y_Motion <= 10'd0;	
				location <= Ball_X_Start;
				//excess_is_move <= 0;
				shield <= 1'd0;
				attack <= 1'd0;
				
				
				//is_move <= 1'b1;
				
				//Ball_Y_SizeReal = Ball_Y_Size;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            //Ball_Y_Motion <= Ball_Y_Motion_in;
				location <= location_in;
				//excess_is_move <= excess_is_move_in;
				shield <= shield_in;
				attack <= attack_in;	
				
				//is_move <= is_move_in;
				// Ball_Y_SizeReal = Ball_Y_SizeReal_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        //Ball_Y_Motion_in = Ball_Y_Motion;
		  location_in = location; 
		  is_move = 1'b1;
		  excess_is_move = 14'b0;
		  OOB = 14'b0;
		  
		  shield_in = shield;
		  attack_in = attack;
		  debugb1 = 1'b0;
		  debugb2 = 1'b0;
		  debugb3 = 1'b0;
		  debugb4 = 1'b0;
		  debugb5 = 1'b0;
		  debugb_Y = 10'b0;
		  
		  // Ball_Y_SizeReal_in = Ball_Y_SizeReal;
        
		  
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				shield_in = 1'b0;
				attack_in = 1'b0;
				
					
				if ( (Ball_Y_Pos + Ball_Y_Size < top - 1'b1) && (Ball_Y_Pos + Ball_Y_Size < top_left - 1'b1) && (Ball_Y_Pos + Ball_Y_Size < top_right - 1'b1))
					begin
						Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Step;
					end
					
		  
            if( Ball_Y_Pos + Ball_Y_Step + Ball_Y_Size > top - 1'b1 )  // Ball is at the bottom edge
               begin
						Ball_Y_Pos_in = top - 1'b1 - Ball_Y_Size;
					end  // 2's complement.  

//            if ( Ball_Y_Pos <= Ball_Y_Min + 1'b1 + Ball_Y_Size )  // Ball is at the top edge
//               begin
//						Ball_Y_Motion_in = ~(Ball_Y_Step);
//					end
//					 						
				if (keycode == 8'd04)	// A: Move left
				begin
					if (can_move)
						begin
							if ( Ball_X_Pos <= Ball_X_Min + 1'b1 + Ball_X_Size ) // Ball is at the left edge
								begin	
									Ball_X_Pos_in = Ball_X_Min + Ball_X_Size;
									location_in = Ball_X_Min + Ball_X_Size;
								end
							else
								begin
									Ball_X_Pos_in = Ball_X_Pos - Ball_X_Step;
									location_in = location - Ball_X_Step;					
								end
						end
					else if (!can_move)
						begin
							Ball_X_Pos_in = Ball_X_Start - excess;
							location_in = location - Ball_X_Step;
						end

					for (int i = 1; i < 16; i++)
					begin
						if ((location - Ball_X_Size) < platform_change[i][0])
						begin
							if (i == 1)
							begin
								excess_is_move = 14'b0;
								is_move = 1'b1;
								break;
							end
							if ((location - Ball_X_Step - Ball_X_Size) <= platform_change[i-1][0])
							begin
								if (Ball_Y_Pos > platform_change[i-2][1] && Ball_Y_Pos < platform_change[i-2][2])
								begin
									if (can_move)
									begin
										Ball_X_Pos_in = Ball_X_Pos - (location - platform_change[i-1][0] + 1'b1);
										excess_is_move = 14'b0;
									end
									else if (!can_move)
									begin
										Ball_X_Pos_in = Ball_X_Start;
										excess_is_move = location - (platform_change[i-1][0] + 1'b1 + Ball_X_Size);
									end
									location_in = platform_change[i-1][0] + 1'b1 + Ball_X_Size;
									is_move = 1'b0;
								end
								else if ((Ball_Y_Pos - Ball_Y_Size) > platform_change[i-2][1] && (Ball_Y_Pos - Ball_Y_Size) < platform_change[i-2][2])
								begin
									if (can_move)
									begin
										Ball_X_Pos_in = Ball_X_Pos - (location - platform_change[i-1][0] + 1'b1);
										excess_is_move = 14'b0;
									end
									else if (!can_move)
									begin
										Ball_X_Pos_in = Ball_X_Start;
										excess_is_move = location - (platform_change[i-1][0] + 1'b1 + Ball_X_Size);
										//Ball_X_Pos - Ball_X_Start;  
									end
									location_in = platform_change[i-1][0] + 1'b1 + Ball_X_Size;
									is_move = 1'b0;
								end
								else if ((Ball_Y_Pos + Ball_Y_Size) > platform_change[i-2][1] && (Ball_Y_Pos + Ball_Y_Size) < platform_change[i-2][2])
								begin
									if (can_move)
									begin
										Ball_X_Pos_in = Ball_X_Pos - (location - platform_change[i-1][0] + 1'b1);
										excess_is_move = 14'b0;
									end
									else if (!can_move)
									begin
										Ball_X_Pos_in = Ball_X_Start;
										excess_is_move = location - (platform_change[i-1][0] + 1'b1 + Ball_X_Size);
									end
									location_in = platform_change[i-1][0] + 1'b1 + Ball_X_Size;
									is_move = 1'b0;
								end
							end
							else
							begin
								excess_is_move = 14'b0;
								is_move = 1'b1;
							end
							break;
						end
						else
						begin
							is_move = 1'b1;
						end
					end
						
				end
					
				if (keycode == 8'd07)	// D: Move right
				begin
					if (can_move)
					begin
						if( Ball_X_Pos + Ball_X_Size >= Ball_X_Max - 1'b1) // Ball is at the right edge
						begin	
							Ball_X_Pos_in = Ball_X_Max - Ball_X_Size;
							location_in = Ball_X_Max*7 - Ball_X_Size;
						end
						else
						begin
							
							Ball_X_Pos_in = Ball_X_Pos + Ball_X_Step;
							location_in = location + Ball_X_Step;
						end
					end
					else if (!can_move)
					begin
						Ball_X_Pos_in = Ball_X_Start + excess;
						location_in = location + Ball_X_Step;
					end
			
				
						for (int i = 1; i < 16; i++)
						begin
							if ((location + Ball_X_Size) < platform_change[i][0])
							begin
								debugb_Y = Ball_Y_Pos;
								//debugb_loc = location;
								debugb1 = 1'b1;
								if (i == 15)
								begin
									excess_is_move = 14'b0;
									is_move = 1'b1;
									break;
								end
								if ((location + Ball_X_Step + Ball_X_Size) >= platform_change[i][0])
								begin
									if (Ball_Y_Pos > platform_change[i][1] && Ball_Y_Pos < platform_change[i][2])
									begin
										if (can_move)
										begin
											Ball_X_Pos_in = Ball_X_Pos + ((platform_change[i][0] - location)- 1'b1);
											excess_is_move = 14'b0;
										end
										else if (!can_move)
										begin
											Ball_X_Pos_in = Ball_X_Start;
											excess_is_move = (platform_change[i][0] - 1'b1 - Ball_X_Size) - location;
											//Ball_X_Start - Ball_X_Pos;
										end
										location_in = platform_change[i][0] - 1'b1 - Ball_X_Size;
										is_move = 1'b0;
									end
									else if ((Ball_Y_Pos - Ball_Y_Size) > platform_change[i][1] && (Ball_Y_Pos - Ball_Y_Size) < platform_change[i][2])
									begin
										if (can_move)
										begin
											Ball_X_Pos_in = Ball_X_Pos + ((platform_change[i][0] - location)- 1'b1);
											excess_is_move = 14'b0;
										end
										else if (!can_move)
										begin
											Ball_X_Pos_in = Ball_X_Start;
											excess_is_move = (platform_change[i][0] - 1'b1 - Ball_X_Size) - location;
										end
										location_in = platform_change[i][0] - 1'b1 - Ball_X_Size;
										is_move = 1'b0;
									end
									else if ((Ball_Y_Pos + Ball_Y_Size) > platform_change[i][1] && (Ball_Y_Pos + Ball_Y_Size) < platform_change[i][2])
									begin
										if (can_move)
										begin
											Ball_X_Pos_in = Ball_X_Pos + ((platform_change[i][0] - location)- 1'b1);
											excess_is_move = 14'b0;
										end
										else if (!can_move)
										begin
											Ball_X_Pos_in = Ball_X_Start;
											excess_is_move = (platform_change[i][0] - 1'b1 - Ball_X_Size) - location;
										end
										location_in = platform_change[i][0] - 1'b1 - Ball_X_Size;
										is_move = 1'b0;
									end
								end
								else
								begin
									excess_is_move = 14'b0;
									is_move = 1'b1;
								end
								break;
							end
							else
								is_move = 1'b1;
						end
					end
					
				if(keycode == 8'd26)	// W: Move up
					begin
						OOB = Ball_Y_Pos - 10'd200;
						if (Ball_Y_Pos + Ball_Y_Size >= top - 1'b1)
						begin
							if ((OOB == 0) || OOB[13] == 1'b1)
								Ball_Y_Pos_in = Ball_Y_Min + Ball_Y_Size;
							else
								Ball_Y_Pos_in = Ball_Y_Pos - 10'd200;
						end
						else
							Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Step;	
		
					end
					
				if (keycode ==	8'd22)	// S: Use shield
					begin
						shield_in = 1'b1;
						attack_in = 1'b0;
						//if( Ball_Y_Pos + /*Ball_Y_SizeReal*/ Ball_Y_Size >= Ball_Y_Max - 1'b1 )  // Ball is at the bottom edge
						//	Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
						//else				
					end	
					
				if (keycode == 8'd44)	// Space: Attack
					begin
						shield_in = 1'b0;
						attack_in = 1'b1;	
					end
					
				// if (keycode != 8'd22) shield_in = 1'b0;
        end
		  else
			is_move = 1'b1;
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, SizeX, SizeY;
	 assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign SizeX = Ball_X_Size;
	 assign SizeY = Ball_Y_Size;
    always_comb begin
		  // if (DistX <= SizeX && DistY <= SizeY) 
		  if ( (DistX*DistX <= SizeX*SizeX) && (DistY*DistY <= SizeY*SizeY) ) 
            is_ball = 1'b1;
        else
            is_ball = 1'b0;
    end
	 
	 assign player_location = location;
	 assign is_shield = shield;
	 assign is_attack = attack;
    
endmodule
