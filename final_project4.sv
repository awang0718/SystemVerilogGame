//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------

// USE THIS
module /*final_project*/ lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK      //SDRAM Clock
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
    
    assign Clk = CLOCK_50;
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
	 logic is_ball, is_shield, is_punch, is_attack[0:3], is_move;
	 logic [13:0] player_location;	 
	 logic [2:0] health_in, health_out;
	 logic game_over;
	 logic [13:0] excess_is_move;
	 
	 //wires to and from platform
	 logic[9:0] start_X, start_Y;
	 logic is_platform, can_move;
    logic[13:0] bot, top;
	 logic[13:0] platform_change[0:15][0:2];
	 logic[13:0] left_bound, right_bound;
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
	 
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
//									  .enemy_data_new_signal(enemy_data),
									  .enemy_loc_new_signal({2'b0, enemy_loc[0]}),
//									  .export_data_new_signal(export_data),
									  .player_loc_new_signal({2'b0, player_location}),
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
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
	 
	 // Color mapper for everything
    color_mapper4Sprite color_instance(.*,
									.Reset(Reset_h)
	 );
	 
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
