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



/*
 *		Branch Predictor FSM
 */

// module branch_predictor(
// 		clk,
// 		actual_branch_decision,
// 		branch_decode_sig,
// 		branch_mem_sig,
// 		in_addr,
// 		offset,
// 		branch_addr,
// 		prediction
// 	);

// 	/*
// 	 *	inputs
// 	 */
// 	input		clk;
// 	input		actual_branch_decision;
// 	input		branch_decode_sig;
// 	input		branch_mem_sig;
// 	input [31:0]	in_addr;
// 	input [31:0]	offset;

// 	/*
// 	 *	outputs
// 	 */
// 	output [31:0]	branch_addr;
// 	output		prediction;
// 	/*
// 	 *	internal state
// 	 */
// 	reg [1:0]	s;

// 	reg		branch_mem_sig_reg;

// 	initial begin
// 		s = 2'b00;
// 		branch_mem_sig_reg = 1'b0;
// 	end

// 	always @(negedge clk) begin
// 		branch_mem_sig_reg <= branch_mem_sig;
// 	end

// 	/*
// 	 *	Using this microarchitecture, branches can't occur consecutively
// 	 *	therefore can use branch_mem_sig as every branch is followed by
// 	 *	a bubble, so a 0 to 1 transition
// 	 */
// 	always @(posedge clk) begin
// 		if (branch_mem_sig_reg) begin
// 			s[1] <= (s[1]&s[0]) | (s[0]&actual_branch_decision) | (s[1]&actual_branch_decision);
// 			s[0] <= (s[1]&(!s[0])) | ((!s[0])&actual_branch_decision) | (s[1]&actual_branch_decision);
// 		end
// 	end

// 	assign branch_addr = in_addr + offset;
// 	assign prediction = s[1] & branch_decode_sig;
// endmodule

/*
 *		Branch Predictor FSM with Branch History Table for local branch prediction
 */

// module branch_predictor(
// 		clk,
// 		actual_branch_decision,
// 		branch_decode_sig,
// 		branch_mem_sig,
// 		in_addr,
// 		offset,
// 		branch_addr,
// 		prediction
// 	);

// 	/*
// 	 *	inputs
// 	 */
// 	input		clk;
// 	input		actual_branch_decision;
// 	input		branch_decode_sig;
// 	input		branch_mem_sig;
// 	input [31:0]	in_addr;
// 	input [31:0]	offset;

// 	/*
// 	 *	outputs
// 	 */
// 	output [31:0]	branch_addr;
// 	output		prediction;

// 	reg		branch_mem_sig_reg;

// 	// branch history table, each entry is a 2-bit saturating counter
// 	reg [1:0] bht [31:0];
// 	wire [4:0] bht_index;
	
// 	initial begin
// 		branch_mem_sig_reg = 1'b0;
//   	end

// 	assign bht_index = in_addr[4:0];
	
// 	always @(negedge clk) begin
// 		branch_mem_sig_reg <= branch_mem_sig;
// 	end

// 	always @(posedge clk) begin
// 		if (branch_mem_sig_reg) begin
// 			// update 2-bit saturating counter inside each entry of bht based on actual branch decision
// 			if (actual_branch_decision == 1) begin
// 				if (bht[bht_index] < 3) begin
// 					bht[bht_index] <= bht[bht_index] + 1;
// 				end
// 			end else begin
// 				if (bht[bht_index] > 0) begin
// 					bht[bht_index] <= bht[bht_index] - 1;
// 				end
// 			end
// 		end
// 	end

// 	assign branch_addr = in_addr + offset;
// 	assign prediction = bht[bht_index][1] & branch_decode_sig;
// endmodule

/*
 *		Branch Predictor FSM with local & global branch prediction with tournament predictor
 */

module branch_predictor(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		branch_addr,
		prediction
	);

	// inputs
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;
	// outputs
	output [31:0]	branch_addr;
	output			prediction;
	wire 			local_prediction;
	wire 			global_prediction;

	reg		branch_mem_sig_reg;
	// branch history table, each entry is a 2-bit saturating counter
	reg [1:0] bht [31:0];
	// global branch history table, each entry is a 2-bit saturating counter
	reg [1:0] gbht [31:0];
	// tournament history table, each entry is a 2-bit saturating counter
	reg [1:0] tournament_ht [31:0];
	// global history register, only 5 bits as gbht would be too large otherwise 
	reg [4:0] ghr;
	wire [4:0] bht_index;
	wire [4:0] gbht_index;
	
	initial begin
		branch_mem_sig_reg = 1'b0;
  	end

	assign bht_index = in_addr[4:0];
	assign gbht_index = in_addr[4:0] ^ ghr;
	assign branch_addr = in_addr + offset;
	assign local_prediction = bht[bht_index][1];
	assign global_prediction = gbht[gbht_index][1];
	
	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			// update 2-bit saturating counter inside 
			// each entry of bht or gbht based on actual branch decision
			if (actual_branch_decision == 1) begin
				if (bht[bht_index] < 3) begin
					bht[bht_index] <= bht[bht_index] + 1;
				end

				if (gbht[gbht_index] < 3) begin
					gbht[gbht_index] <= gbht[gbht_index] + 1;
				end
			end 
			
			else begin
				if (bht[bht_index] > 0) begin
					bht[bht_index] <= bht[bht_index] - 1;
				end

				if (gbht[gbht_index] > 0) begin
					gbht[gbht_index] <= gbht[gbht_index] - 1;
				end
			end
		end
		ghr <= {ghr[3:0], actual_branch_decision};
	end

	// tournament predictor
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			if (actual_branch_decision == 1) begin
				// 10 & 11 corresponds to local prediction being taken
				// 00 & 01 corresponds to global prediction being taken
				// Can use bht_index as index for tournament_ht as well
				if (local_prediction == 1 && global_prediction == 0) begin
					if (tournament_ht[bht_index] < 3) begin
						tournament_ht[bht_index] <= tournament_ht[bht_index] + 1;
					end
				end else if (local_prediction == 0 && global_prediction == 1) begin
					if (tournament_ht[bht_index] > 0) begin
						tournament_ht[bht_index] <= tournament_ht[bht_index] - 1;
					end 
				end
			end

			else if (actual_branch_decision == 0) begin
				if (local_prediction == 1 && global_prediction == 0) begin
					if (tournament_ht[bht_index] > 0) begin
						tournament_ht[bht_index] <= tournament_ht[bht_index] - 1;
					end
				end else if (local_prediction == 0 && global_prediction == 1) begin
					if (tournament_ht[bht_index] < 3) begin
						tournament_ht[bht_index] <= tournament_ht[bht_index] + 1;
					end 
				end
			end
		end
	end
	assign prediction = tournament_ht[bht_index][1] & branch_decode_sig;
endmodule

// /*
//  *		Branch Predictor FSM with global branch prediction
//  */
//  */

// module branch_predictor(
// 		clk,
// 		actual_branch_decision,
// 		branch_decode_sig,
// 		branch_mem_sig,
// 		in_addr,
// 		offset,
// 		branch_addr,
// 		prediction
// 	);

// 	/*
// 	 *	inputs
// 	 */
// 	input		clk;
// 	input		actual_branch_decision;
// 	input		branch_decode_sig;
// 	input		branch_mem_sig;
// 	input [31:0]	in_addr;
// 	input [31:0]	offset;

// 	/*
// 	 *	outputs
// 	 */
// 	output [31:0]	branch_addr;
// 	output		prediction;

// 	reg		branch_mem_sig_reg;

// 	// global branch history table, each entry is a 2-bit saturating counter
// 	reg [1:0] gbht [31:0];
// 	reg [4:0] ghr;
// 	wire [4:0] gbht_index;
	
// 	initial begin
// 		branch_mem_sig_reg = 1'b0;
//   	end
	
// 	always @(negedge clk) begin
// 		branch_mem_sig_reg <= branch_mem_sig;
// 	end

//  //(TO-DO) Test without the XOR, does it make a difference??

// 	assign gbht_index = in_addr[4:0] ^ ghr;

// 	always @(posedge clk) begin
// 		if (branch_mem_sig_reg) begin
// 			// update 2-bit saturating counter inside each entry of bht or gbht based on actual branch decision
// 			if (actual_branch_decision == 1) begin
// 				if (gbht[gbht_index] < 3) begin
// 					gbht[gbht_index] <= gbht[gbht_index] + 1;
// 				end
// 			end 
			
// 			else begin
// 				if (gbht[gbht_index] > 0) begin
// 					gbht[gbht_index] <= gbht[gbht_index] - 1;
// 				end
// 			end
// 		end
// 		ghr <= {ghr[3:0], actual_branch_decision};
// 	end

// 	assign branch_addr = in_addr + offset;
// 	assign prediction = gbht[gbht_index][1] & branch_decode_sig;
// endmodule