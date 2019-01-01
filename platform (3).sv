module platform(
input logic Clk,			//clock
input logic Reset,		//reset
input logic frame_clk,	//clock for vga frame
input logic[7:0] keycode,					//keys from keyboard
input logic[9:0] DrawX, DrawY,			//inputs for color mapper
input logic is_move,
input logic[13:0] excess_is_move,
input logic[13:0] player_location,		//input from character module for position of the player relative 
													//to the whole map
//input logic		stop;							//the char is stopped, player cannot move
output logic[9:0] start_X,					//start position of player
output logic[9:0] start_Y,					//start position of player
output logic is_platform,					//color mapper output
output logic can_move,						//output to player module to see if char can move relative to screen
output logic[13:0] top,						//output that is top and bot for current player location
output logic[13:0] top_left,
output logic[13:0] top_right,
output logic[13:0] bot,
output logic[13:0] excess,
output logic [13:0] platform_change[0:3][0:2]		//output of platform changes, hopefully for the collision
);


	//copied straight from ball.sv
	logic frame_clk_delayed, frame_clk_rising_edge;
	always_ff @ (posedge Clk) begin
		frame_clk_delayed <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
	end

	//parameters
	parameter [9:0] Ball_X_Size = 10'd15;  
	parameter [9:0] Y_Min = 10'd0;       // Topmost point on the Y axis
	parameter [9:0] Y_Max = 10'd479;     // Bottommost point on the Y axis
	parameter [9:0] X_Max = 10'd639;   
	parameter [9:0] X_Min = 10'd0;
	parameter [9:0] speed = 10'd6;		// speed of player
	parameter [13:0] platform_length = (7*X_Max)+6;		//length of total map
	//logic[3:0] change_num = 4'b0011;
	//	integer change_num;
	//assign change_num = 32'd3;
//	logic [13:0] platform_change[0:2][0:2];	//instantiate array that contains changes in platform heights + thickness
	//logic [13:0] location_of_player;
	logic [13:0] left_bound;						//left bound of screen relative to map
	logic [13:0] right_bound;						//right bound of screen relative to map
//	logic [9:0] upper_bound;						
//	logic [9:0] lower_bound;
	
	//logic [13:0] location_of_player_in;
	logic [13:0] left_bound_in;					//inputs to the registers updated in always_comb
	logic [13:0] right_bound_in;
	//logic [13:0] top_in, top_left_in, top_right_in;
	//logic [13:0] bot_in;
	//logic can_move_in;
	//logic[13:0] excess_in;
	logic[13:0] OOB;
	//assign stop = 1'b0;
	//assign stop_draw = 1'b0;
	
	//DEBUG
	logic debug1, debug3, debug2, debug4, debug5, debug6;
	logic debug1_in, debug3_in, debug2_in, debug4_in, debug5_in, debug6_in;
	logic[9:0] debug_comb, debug_comb_in;
	
	
	//logic topbot_change, draw_change;
					
	assign start_X = 10'd100;						//player start position
	assign start_Y = 10'd300;
	
	//CREATING ALL PLATFORM CHANGES (x coordinate, top height, bot height)
	assign platform_change = '{'{14'b0, 14'd300, 14'd350},
										'{14'd400, 14'd400, 14'd450},
										'{14'd500, 14'd300, 14'd350},
										'{platform_length, 14'd300, 14'd350} };
										
	always_ff @ (posedge Clk)			//register for the values
	begin
		if (Reset)
			begin
				//excess <= 4'b0;
				left_bound <= 14'b0;
				right_bound <= 14'd639;
				//top <= 10'd300;
				//top_left <= 10'd300;
				//top_right <= 10'd300;
				//bot <= 10'd350;
				//can_move <= 1'b0;
				
				//DEBUG
				debug1 <= 1'b0;
				debug2 <= 1'b0;
				debug3 <= 1'b0;
				debug4 <= 1'b0;
				debug5 <= 1'b0;
				debug6 <= 1'b0;
				debug_comb <= 10'b0;
		end
		else
		begin	
				//excess <= excess_in;
				left_bound <= left_bound_in;
				right_bound <= right_bound_in;
				//bot <= bot_in;
				//top <= top_in;
				//top_left <= top_left_in;
				//top_right <= top_right_in;
				//can_move <= can_move_in;
				
				//DEBUG
				debug1 <= debug1_in;
				debug2 <= debug2_in;
				debug3 <= debug3_in;
				debug4 <= debug4_in;
				debug5 <= debug5_in;
				debug6 <= debug6_in;
				debug_comb <= debug_comb_in;
		end
	end


	
	always_comb
	begin
		//change_num = 32'd3;
		OOB = left_bound - speed;
		debug1_in = debug1;
		debug2_in = debug2;
		debug3_in = debug3;
		debug4_in = debug4;
		debug5_in = debug5;
		debug6_in = is_move;
		debug_comb_in = debug_comb + 1'b1;
		left_bound_in = left_bound;					//default nothing changes
		right_bound_in = right_bound;
		//top_in = top;
		//top_right_in = top_right;
		//top_left_in = top_left;
		top = 14'b0;
		top_right = 14'b0;
		top_left = 14'b0;
		bot = 14'b0;
		excess = 14'b0;
		can_move = 1'b0;
		if (frame_clk_rising_edge)
		begin
			
			unique case (keycode)						//takes keycode only for left and right
				8'd04:	// A: Move left
				begin
					if (left_bound == 0)					//if at left edge already, dont change bounds
					begin
						debug1_in = 1'b1;
						excess = 14'b0;
						//left_bound_in = left_bound;
						//right_bound_in = right_bound;
						can_move = 1'b1;				//player can move
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else if (OOB == 0 || OOB[13] == 1)			//if not at left edge, but player movement + speed is past
																			//left edge
					begin
						debug2_in = 1'b1;
						if (is_move)
						begin
							left_bound_in = 14'b0;
							right_bound_in = 14'd639;			//change bounds to be right on left edge
							excess = 14'd320 - (player_location - speed);
						end
						can_move = 1'b0;							//player can move
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)				//get top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else if (right_bound == platform_length && (player_location > (platform_length - 14'd319)))
					begin
						can_move = 1'b1;
						excess = 14'b0;
						if (is_move)
						begin
							if ((player_location - speed) < ((right_bound + left_bound)/2))
							begin
								left_bound_in = left_bound - (((right_bound + left_bound)/2) - (platform_length - 14'd319));
								right_bound_in = right_bound - (((right_bound + left_bound)/2) - (platform_length - 14'd319));
								can_move = 1'b0;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else													//if not even close to edge
					begin
						debug3_in = 1'b1;
						excess = 14'b0;
						if (is_move)
						begin
							debug4_in = 1'b1;
							left_bound_in = left_bound - speed;		//bounds change based off player speed
							right_bound_in = right_bound - speed;
						end
						else if (!is_move)
						begin
							debug5_in = 1'b1;
							left_bound_in = left_bound - excess_is_move;
							right_bound_in = right_bound - excess_is_move;
						end
						can_move = 1'b0;							//player can move
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)				//get top and bot based off player location
						begin
							if (player_location < platform_change[i][0])		//get top and bot based off player location
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
				end
				8'd07:	// D: Move right
				begin
					if (right_bound == (platform_length))			//if at right edge already, dont change bounds
					begin
						excess = 14'b0;
						//left_bound_in = left_bound;
						//right_bound_in = right_bound;
						can_move = 1'b1;								//player can move
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)					//get top and bot based off player location
						begin
							if (player_location  < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else if ((right_bound + speed) >= (platform_length))		//if not at right edge, but player movement + 
																								//speed is past right edge
					begin
						if (is_move)
						begin
							left_bound_in = platform_length - 14'd640;			//change right bound to all the way right
							right_bound_in = platform_length;
							excess = (player_location + speed) - (platform_length - 319);
						end
						can_move = 1'b0;
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)				//get top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else if (left_bound == 0 && (player_location < 14'd320))
					begin
						excess = 14'b0;
						can_move = 1'b1;
						if (is_move)
						begin
							if ((player_location + speed) > 14'd320)
							begin
								left_bound_in = left_bound + ((player_location + speed) - 14'd320);
								right_bound_in = right_bound + ((player_location + speed) - 14'd320);
								can_move = 1'b0;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
					else										//if not close to edge
					begin
						excess = 14'b0;
						if (is_move)
						begin
							left_bound_in = left_bound + speed;		//bounds change based off player speed
							right_bound_in = right_bound + speed;
						end
						else if (!is_move)
						begin
							left_bound_in = left_bound + excess_is_move;
							right_bound_in = right_bound + excess_is_move;
						end
						can_move = 1'b0;								//player can move
						//topbot_change = 1'b1;
						for (int i = 1; i < 4; i++)			//get top and bot based off player location
						begin
							if (player_location < platform_change[i][0])
							begin
								top = platform_change[i-1][1];
								bot = platform_change[i-1][2];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location - Ball_X_Size) < platform_change[i][0])
							begin
								top_left = platform_change[i-1][1];
								break;
							end
						end
						for (int i = 1; i < 4; i++)		//get the top and bot based off player location
						begin
							if ((player_location + Ball_X_Size) < platform_change[i][0])
							begin
								top_right = platform_change[i-1][1];
								break;
							end
						end
					end
				end
				default:
				begin
					left_bound_in = left_bound;					//default nothing changes
					right_bound_in = right_bound;
					//can_move_in = can_move;
					//top_in = top;
					//top_right_in = top_right;
					//top_left_in = top_left;
					//bot_in = bot;
					//excess_in = 14'b0;
				end
			endcase
			
		end
	end
	
	always_comb 			//for color mapper
	begin
		//change_num = 32'd3;
		is_platform = 1'b0;			//default: not a platform
		
		for (int i = 1; i < 4; i++)		//run through the platform change
		begin
			if (DrawX + left_bound < platform_change[i][0])			//find drawX position in platform change
			begin
				if (DrawY <= platform_change[i-1][2] && DrawY >= platform_change[i-1][1])	//if between upper and lower bounds
																												//of Y coordinates
				begin
					is_platform = 1'b1;			//becomes platform
					break;
				end
				else
				begin
					is_platform = 1'b0;
					break;
				end
			end
			else	
				is_platform = 1'b0;
		end
		//draw_change = 1'b1;
	end
	
endmodule
