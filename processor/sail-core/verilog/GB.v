module GB(
	input wire clk_pll,
	output wire sys_clk
	);

	SB_GB GB_inst(
        .USER_SIGNAL_TO_GLOBAL_BUFFER(clk_pll),
        .GLOBAL_BUFFER_OUTPUT(sys_clk)
	);
	
endmodule