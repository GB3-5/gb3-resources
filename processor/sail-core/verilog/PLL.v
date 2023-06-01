module PLL(clk,
        clk_pll);

input clk;
output clk_pll;

SB_PLL40_CORE PLL_inst(.REFERENCECLK(clk),
                         .PLLOUTGLOBAL(clk_pll),
                         .EXTFEEDBACK(),
                         .DYNAMICDELAY(),
                         .RESETB(1'b0),
                         .BYPASS(1'b0),
                         .LATCHINPUTVALUE(1'b1),
                         .LOCK(),
                         .SDI(),
                         .SDO(),
                         .SCLK());

//\\ Fin=48, Fout=16;
defparam PLL_inst.DIVR = 4'b0010;
defparam PLL_inst.DIVF = 7'b0111111;
defparam PLL_inst.DIVQ = 3'b110;
defparam PLL_inst.FILTER_RANGE = 3'b001;
defparam PLL_inst.FEEDBACK_PATH = "SIMPLE";
defparam PLL_inst.DELAY_ADJUSTMENT_MODE_FEEDBACK = "FIXED";
defparam PLL_inst.FDA_FEEDBACK = 4'b0000;
defparam PLL_inst.DELAY_ADJUSTMENT_MODE_RELATIVE = "FIXED";
defparam PLL_inst.FDA_RELATIVE = 4'b0000;
defparam PLL_inst.SHIFTREG_DIV_MODE = 2'b00;
defparam PLL_inst.PLLOUT_SELECT = "GENCLK";
defparam PLL_inst.ENABLE_ICEGATE = 1'b1;

endmodule
