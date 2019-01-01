module top_level_pball( input    Clk,
					input		frame_clk,
					input		Reset,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
				 input			[7:0] keycode
);

	logic Reset_h;
    
	 logic [7:0]  VGA_R,        //VGA Red
								VGA_G,        //VGA Green
								VGA_B;        //VGA Blue
	 logic        VGA_CLK,      //VGA Clock
								VGA_SYNC_N,   //VGA Sync signal
								VGA_BLANK_N,  //VGA Blank signal
								VGA_VS,       //VGA virtical sync signal
								VGA_HS;       //VGA horizontal sync signal
	     
    // assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 
	 //wires to and from interface
	 logic[15:0] enemy_data;
	 logic[15:0] export_data;	 
	 assign export_data = 16'hffff;
	 
	 //wires to and from ball
	 logic [9:0] DrawX, DrawY;
	 logic is_ball, is_shield, is_attack[0:3], is_move;
	 logic [13:0] player_location;	 
	 logic [2:0] health_in, health_out;
	 logic game_over;
	 logic [13:0] excess_is_move;
	 
	 //wires to and from platform
	 logic[9:0] start_X, start_Y;
	 logic is_platform, can_move;
    logic[13:0] bot, top;
	 logic[13:0] platform_change[0:15][0:2];
	 logic[13:0] excess;
	 logic[13:0] top_left, top_right;
	 logic ball_direction;
	 logic[13:0] Ball_X, Ball_Y;
	 
	 //wires to and from enemy
	 logic is_enemy[0:3], is_enemy_shield[0:3], is_enemy_attack[0:3];
	 logic[13:0] enemy_loc[0:3];
	 logic direction[0:3];
	 logic[13:0] Enemy_X[0:3], Enemy_Y[0:3];
	 
	 //wires to and from enemy_heatlh
	 logic dead[0:3], all_dead;
	 
	 //wires to and from frameCounter
	 logic changeFrame;
	 
	 //wires to and from ram
	 logic [4:0] data_In, data_Out;
	 logic [18:0] write_address, read_address;
	 assign we = 1'b0;

    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    
// Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.*,
                           .Reset(Reset_h),
									.VGA_CLK(VGA_CLK)     // 25 MHz VGA clock input
	 );
    
    // Player character
    ball4 ball_instance(.*,                
									.Reset(Reset_h),             
									.frame_clk(VGA_VS),
									.enemy_location(enemy_loc),
									.enemy_hit_en(is_enemy_shield), // {is_enemy_shield[0], is_enemy_shield[1],is_enemy_shield[2],is_enemy_shield[3]})
									.is_ball(is_ball)
	);
	 
	 // 4 enemies
	 enemy4 enemy (.*,
				.Reset(Reset_h),
				.frame_clk(VGA_VS),	
				.is_enemy_shield(is_enemy_shield),
//				.enemy_can_move(enemy_data[0]),	
//				.enemy_shield(enemy_data[1]),
//				.enemy_attack(enemy_data[2]),
//				.direction(enemy_data[4:3]),
//				.jump(enemy_jump),
				.enemy_location(enemy_loc),
				.hit_en(~is_shield)	
	 );
	 
	 // Platform scrolling
    platform plat(.*,
						 .Clk(Clk), 
						 .Reset(Reset_h),
						 .frame_clk(VGA_VS),
						 .keycode(keycode),
						 .DrawX(DrawX),
						 .DrawY(DrawY),
						 .player_location(player_location),
						 .start_X(start_X),
						 .start_Y(start_Y),
						 .is_platform(is_platform),
						 .can_move(can_move),
						 .top(top),
						 .bot(bot),
						 .platform_change(platform_change)
	 );
	 
	 // Health of player
	 health player_health(.*,
									.frame_clk(VGA_VS),
									.Reset(Reset_h),
									.hit_en(is_enemy_attack[0] || is_enemy_attack[1] || is_enemy_attack[2] || is_enemy_attack[3]),
									.game_over(game_over)
	 );
	 
	 // Health of enemies
	 enemy_health4 enemy_health(.*,
									.frame_clk(VGA_VS),
									.Reset(Reset_h),
									.enemy_hit_en(is_attack),
									.dead(dead)
	 );
	 
	 // Frame counter
	 frameCounter frame_count(.*, 
									.frame_clk(VGA_VS),
									.Reset(Reset_h)
	 );
	 
    color_mapper4Sprite color_instance(.*);
	 
	 // Frame ram
	 frameRAM ram(.*);
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode[3:0], HEX0);
    HexDriver hex_inst_1 (keycode[7:4], HEX1);
    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule