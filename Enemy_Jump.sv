module Enemy_Jump2(
	input logic[13:0] platform_change[0:15][0:2],
	input logic[13:0] enemy_loc,
	input logic[1:0] enemy_dir,
	output logic jump
);

always_comb
begin
	jump = 1'b0;
	for (int i = 0; i < 16; i++)
	begin
		if (enemy_dir == 2'b0)
		begin
			for (int j = 0; j < 5; j++)
			begin
				if ((enemy_loc + j) == platform_change[i][0])
					jump = 1'b1;
			end
		end
	end
end
endmodule
