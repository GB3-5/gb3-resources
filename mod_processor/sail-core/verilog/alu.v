/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/



`include "../include/rv32i-defines.v"
`include "../include/sail-core-defines.v"

// There is no need to import any extra libraries to use the FPGA's hard primimtives? Doesn't seem so.
// FPGA primitive for ALU addition/subtraction is deliberately instantiated here, as OG implementation does not automatically infer the use of the DSP. 
// See output_no_dsp.txt for confirmation of the above. 



/*
 *	Description:
 *
 *		This module implements the ALU for the RV32I.

 *		Personal notes:
 *		- 32-bit ALU, 7-bit control signal, 2 32-bit inputs, 1 32-bit output
 *		- There is no need to import any extra libraries to use the FPGA's hard primimtives? Doesn't seem so.
 * 		- FPGA primitive for ALU addition/subtraction is deliberately instantiated here, as OG implementation does not automatically infer the use of the DSP. 
 *		- See output_no_dsp.txt for confirmation of the above. 
 */



/*
 *	Not all instructions are fed to the ALU. As a result, the ALUctl
 *	field is only unique across the instructions that are actually
 *	fed to the ALU.
 */
module alu(ALUctl, A, B, ALUOut, Branch_Enable, clk);
	input [6:0]		ALUctl;
	input [31:0]		A;
	input [31:0]		B;
	input 				clk;
	output reg [31:0]	ALUOut;
	output reg		Branch_Enable;

	/* 
	 * 	Instantiate the DSP for addition
	 * 	Configuration complete (not checked), port mapping incomplete (not checked)
	 *  Use the DSP in unegistered mode for now, since the ALU is purely combinatorial
	 */

	// DSP for ADDITION	
	// reg add_CE = 1'b1;
	// reg add_IRSTTOP = 1'b0;
	// reg add_IRSTBOT = 1'b0;
	// reg add_ORSTTOP = 1'b0;
	// reg add_ORSTBOT = 1'b0;
	// reg add_AHOLD = 1'b0;
	// reg add_BHOLD = 1'b0;
	// reg add_CHOLD = 1'b0;
	// reg add_DHOLD = 1'b0;
	// reg add_OHOLDTOP = 1'b0;
	// reg add_OHOLDBOT = 1'b0;
	// reg add_OLOADTOP = 1'b0;
	// reg add_OLOADBOT = 1'b0;
	// reg add_ADDSUBTOP = 1'b0;
	// reg add_ADDSUBBOT = 1'b0;
	// reg add_ZERO = 1'b0;
	wire add_CO;
	// reg add_CI = 1'b0;
	// reg [31:0] add_ACCUMCI = 1'b0;
	// reg [31:0] add_ACCUMCO = 1'b0;
	// reg [31:0] add_SIGNEXTIN = 1'b0;
	// reg [31:0] add_SIGNEXTOUT = 1'b0;
	reg [15:0] A_in; 
	reg [15:0] B_in;
	reg [15:0] C_in;
	reg [15:0] D_in;
	wire [31:0] add_dsp_out;
	// Does using the hack below reduce logic cell usage?
	reg zero_reg = 1'b0;
	reg one_reg = 1'b1;

	SB_MAC16 add_dsp
		( 		// port interfaces
		.A(A_in),
		.B(B_in),
		.C(C_in),
		.D(D_in),
		.O(add_dsp_out),
		.CLK(clk),
		.CE(one_reg),
		.IRSTTOP(zero_reg),
		.IRSTBOT(zero_reg),
		.ORSTTOP(zero_reg),
		.ORSTBOT(zero_reg),
		.AHOLD(zero_reg),
		.BHOLD(zero_reg),
		.CHOLD(zero_reg),
		.DHOLD(zero_reg),
		.OHOLDTOP(zero_reg),
		.OHOLDBOT(zero_reg),
		.OLOADTOP(zero_reg),
		.OLOADBOT(zero_reg),
		.ADDSUBTOP(zero_reg),
		.ADDSUBBOT(zero_reg),
		.CO(add_CO),
		.CI(zero_reg),
		.ACCUMCI(),
		.ACCUMCO(),
		.SIGNEXTIN(),
		.SIGNEXTOUT()
		);
		defparam add_dsp.NEG_TRIGGER = 1'b0;
		defparam add_dsp.C_REG = 1'b0;
		defparam add_dsp.A_REG = 1'b0;
		defparam add_dsp.B_REG = 1'b0;
		defparam add_dsp.D_REG = 1'b0;
		defparam add_dsp.TOP_8x8_MULT_REG = 1'b0;
		defparam add_dsp.BOT_8x8_MULT_REG = 1'b0;
		defparam add_dsp.PIPELINE_16x16_MULT_REG1 = 1'b0;
		defparam add_dsp.PIPELINE_16x16_MULT_REG2 = 1'b0;
		defparam add_dsp.TOPOUTPUT_SELECT = 2'b00; // accum register output at O[31:16]
		defparam add_dsp.TOPADDSUB_LOWERINPUT = 2'b00;

		// Check this one "defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1;"
		defparam add_dsp.TOPADDSUB_UPPERINPUT = 1'b1;

		// Check this one also "defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b11;"
		defparam add_dsp.TOPADDSUB_CARRYSELECT = 2'b10;

		defparam add_dsp.BOTOUTPUT_SELECT = 2'b00; // accum regsiter output at O[15:0]
		defparam add_dsp.BOTADDSUB_LOWERINPUT = 2'b00;
		defparam add_dsp.BOTADDSUB_UPPERINPUT = 1'b1;
		defparam add_dsp.BOTADDSUB_CARRYSELECT = 2'b00;
		defparam add_dsp.MODE_8x8 = 1'b1;
		defparam add_dsp.A_SIGNED = 1'b1;
		defparam add_dsp.B_SIGNED = 1'b1;


	// DSP for SUBTRACTION
	// reg sub_CE = 1'b1;
	// reg sub_IRSTTOP = 1'b0;
	// reg sub_IRSTBOT = 1'b0;
	// reg sub_ORSTTOP = 1'b0;
	// reg sub_ORSTBOT = 1'b0;
	// reg sub_AHOLD = 1'b0;
	// reg sub_BHOLD = 1'b0;
	// reg sub_CHOLD = 1'b0;
	// reg sub_DHOLD = 1'b0;
	// reg sub_OHOLDTOP = 1'b0;
	// reg sub_OHOLDBOT = 1'b0;
	// reg sub_OLOADTOP = 1'b0;
	// reg sub_OLOADBOT = 1'b0;
	// reg sub_ADDSUBTOP = 1'b1;
	// reg sub_ADDSUBBOT = 1'b1;
	// reg sub_ZERO = 1'b0;
	wire sub_CO;
	// reg sub_CI = 1'b0;
	// reg [31:0] sub_ACCUMCI = 1'b0;
	// reg [31:0] sub_ACCUMCO = 1'b0;
	// reg [31:0] sub_SIGNEXTIN = 1'b0;
	// reg [31:0] sub_SIGNEXTOUT = 1'b0;
	wire [31:0] sub_dsp_out;

	SB_MAC16 sub_dsp
		( 		// port interfaces
		.A(A_in),
		.B(B_in),
		.C(C_in),
		.D(D_in),
		.O(sub_dsp_out),
		.CLK(clk),
		.CE(one_reg),
		.IRSTTOP(zero_reg),
		.IRSTBOT(zero_reg),
		.ORSTTOP(zero_reg),
		.ORSTBOT(zero_reg),
		.AHOLD(zero_reg),
		.BHOLD(zero_reg),
		.CHOLD(zero_reg),
		.DHOLD(zero_reg),
		.OHOLDTOP(zero_reg),
		.OHOLDBOT(zero_reg),
		.OLOADTOP(zero_reg),
		.OLOADBOT(zero_reg),
		.ADDSUBTOP(one_reg),
		.ADDSUBBOT(one_reg),
		.CO(sub_CO),
		.CI(zero_reg),
		.ACCUMCI(),
		.ACCUMCO(),
		.SIGNEXTIN(),
		.SIGNEXTOUT()
		);
		defparam sub_dsp.NEG_TRIGGER = 1'b0;
		defparam sub_dsp.C_REG = 1'b0;
		defparam sub_dsp.A_REG = 1'b0;
		defparam sub_dsp.B_REG = 1'b0;
		defparam sub_dsp.D_REG = 1'b0;
		defparam sub_dsp.TOP_8x8_MULT_REG = 1'b0;
		defparam sub_dsp.BOT_8x8_MULT_REG = 1'b0;
		defparam sub_dsp.PIPELINE_16x16_MULT_REG1 = 1'b0;
		defparam sub_dsp.PIPELINE_16x16_MULT_REG2 = 1'b0;
		defparam sub_dsp.TOPOUTPUT_SELECT = 2'b00; // accum register output at O[31:16]
		defparam sub_dsp.TOPADDSUB_LOWERINPUT = 2'b00;

		// Check this one "defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1;"
		defparam sub_dsp.TOPADDSUB_UPPERINPUT = 1'b1;

		// Check this one also "defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b11;"
		defparam sub_dsp.TOPADDSUB_CARRYSELECT = 2'b10;

		defparam sub_dsp.BOTOUTPUT_SELECT = 2'b00; // accum regsiter output at O[15:0]
		defparam sub_dsp.BOTADDSUB_LOWERINPUT = 2'b00;
		defparam sub_dsp.BOTADDSUB_UPPERINPUT = 1'b1;
		defparam sub_dsp.BOTADDSUB_CARRYSELECT = 2'b00;
		defparam sub_dsp.MODE_8x8 = 1'b1;
		defparam sub_dsp.A_SIGNED = 1'b1;
		defparam sub_dsp.B_SIGNED = 1'b1;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		ALUOut = 32'b0;
		Branch_Enable = 1'b0;
	end

	/*
	 *	For the basic ALU operations, the case statement arguments are op-codes derived from the included sail-core-defines.v file.
	 * 	When using the DSP, the same structure can be used, just with the DSP being invoked. 
	 */
	
	always @(posedge(clk)) begin
		A_in <= A[31:16];
		B_in <= A[15:0];
		C_in <= B[31:16];
		D_in <= B[15:0];

		case (ALUctl[3:0])
			/*
			 *	AND (the fields also match ANDI and LUI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_AND:	ALUOut = A & B;

			/*
			 *	OR (the fields also match ORI)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_OR:	ALUOut = A | B;

			/*
			 *	ADD (the fields also match AUIPC, all loads, all stores, and ADDI)
			 * 	Can be done with the DSP
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_ADD:	ALUOut = add_dsp_out;

			/*
			 *	SUBTRACT (the fields also matches all branches)
			 *	Can be done with the DSP
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SUB:	ALUOut = sub_dsp_out;

			/*
			 *	SLT (the fields also matches all the other SLT variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLT:	ALUOut = $signed(A) < $signed(B) ? 32'b1 : 32'b0;

			/*
			 *	SRL (the fields also matches the other SRL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRL:	ALUOut = A >> B[4:0];

			/*
			 *	SRA (the fields also matches the other SRA variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SRA:	ALUOut = $signed(A) >>> B[4:0];

			/*
			 *	SLL (the fields also match the other SLL variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_SLL:	ALUOut = A << B[4:0];

			/*
			 *	XOR (the fields also match other XOR variants)
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_XOR:	ALUOut = A ^ B;

			/*
			 *	CSRRW  only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRW:	ALUOut = A;

			/*
			 *	CSRRS only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRS:	ALUOut = A | B;

			/*
			 *	CSRRC only
			 */
			`kSAIL_MICROARCHITECTURE_ALUCTL_3to0_CSRRC:	ALUOut = (~A) & B;

			/*
			 *	Should never happen.
			 */
			default:					ALUOut = 0;
		endcase
	end

	always @(posedge(clk)) begin
		/*
		 *	ALU used here to carry out mathematical operations to determine if a branch should be taken.
		 */

		case (ALUctl[6:4])
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BEQ:	Branch_Enable = (ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BNE:	Branch_Enable = !(ALUOut == 0);
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLT:	Branch_Enable = ($signed(A) < $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGE:	Branch_Enable = ($signed(A) >= $signed(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BLTU:	Branch_Enable = ($unsigned(A) < $unsigned(B));
			`kSAIL_MICROARCHITECTURE_ALUCTL_6to4_BGEU:	Branch_Enable = ($unsigned(A) >= $unsigned(B));

			default:					Branch_Enable = 1'b0;
		endcase
	end
endmodule
