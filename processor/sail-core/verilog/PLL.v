module PLL(
	input wire clk,
	output wire clk_pll
	);

	SB_PLL40_CORE #(
		.FEEDBACK_PATH("SIMPLE"),
		.DIVQ(7'b0000000),	// DIVQ = 0, VCO clock divider (divide by 1)
		.DIVR(4'b1110),		// DIVR = 15, reference clock divider (divide by 15)
		.ENABLE_ICEGATE(1'b1)	// Enable ICEGATE, PLL is in low power mode
	) PLL_inst (
		.REFERENCECLK(clk),
		.PLLOUTGLOBAL(clk_pll)
	);

endmodule

