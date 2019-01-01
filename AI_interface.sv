module AI_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AI_READ,					// Avalon-MM Read
	input  logic AI_WRITE,					// Avalon-MM Write
	input  logic AI_CS,						// Avalon-MM Chip Select
	input  logic [1:0] AI_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AI_ADDR,			// Avalon-MM Address
	input  logic [15:0] AI_WRITEDATA,	// Avalon-MM Write Data
	output logic [15:0] AI_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [15:0] EXPORT_DATA,		// Exported Conduit Signal to LEDs
	
	output logic [15:0] Enemy_Data,
	input logic [15:0] Enemy_Loc,
	input logic [15:0] Player_Loc,
	input logic [7:0] keycode
);
	
	//logic[15:0] Enemy_Data, Enemy_Loc, Player_Loc;
	logic[15:0] Register_File[3];
	logic[15:0] AES_DONE_OUT;
	
	always_ff @ (posedge CLK)
	begin
		if (RESET)
			for (int i = 0; i < 3; i++)
				Register_File[i] <= 16'b0;
		else if (AI_WRITE && AI_CS)
		begin
			if (AI_BYTE_EN[1])
				Register_File[0][15:8] <= AI_WRITEDATA[15:8];
			if (AI_BYTE_EN[0])
				Register_File[0][7:0] <= AI_WRITEDATA[7:0];
			Register_File[1] <= Enemy_Loc;
			Register_File[2] <= Player_Loc;
		end
		else
		begin
			Register_File[1][15:0] <= Enemy_Loc;
			Register_File[2][15:0] <= Player_Loc;
			Register_File[0] <= Register_File[0];
		end
		
	end
	
	
	always_comb
	begin
		if (AI_CS && AI_READ)
			AI_READDATA = Register_File[AI_ADDR][15:0];
		else
			AI_READDATA = 16'b0;
	end
	
	assign enemy_data = Register_File[0];
	assign EXPORT_DATA = 16'hffff;
	
endmodule
