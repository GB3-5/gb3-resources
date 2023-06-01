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
 *	RISC-V instruction memory
 */


/*
module instruction_memory(addr, out);
	input [31:0]		addr;
	output [31:0]		out;

	/*
	 *	Size the instruction memory.
	 *
	 *	(Bad practice: The constant should be a `define).
	 */
	reg [31:0]		instruction_memory[0:2**12-1]; // it was 0:2**12-1, change it back

	/*
	 *	According to the "iCE40 SPRAM Usage Guide" (TN1314 Version 1.0), page 5:
	 *
	 *		"SB_SPRAM256KA RAM does not support initialization through device configuration."
	 *
	 *	The only way to have an initializable memory is to use the Block RAM.
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		/*
		 *	read from "program.hex" and store the instructions in instruction memory
		 */
		$readmemh("verilog/program.hex",instruction_memory);
	end

	assign out = instruction_memory[addr >> 2];
endmodule
*/

module instruction_memory (
    input [7:0] addr,
    input we,
    input [15:0] wdata,
    input [15:0] mask,
    input clk,
    input clke,
    input [7:0] raddr,
    input re,
    input rclk,
    input rclke,
    output [15:0] rdata
);
    reg [15:0] bram_data [0:255];

    // Instantiate the BRAM modules
    genvar i;
    generate
        for (i = 0; i < 10; i = i + 1) begin : BRAM_INST
            bram_module #(   ///////////////////////// does bram_module need to be replaced by something
                .DATA_WIDTH(16),  // Set the data width to 16 bits
                .ADDR_WIDTH(8)    // Set the address width to 8 bits
            ) bram_inst (
                .WDATA(wdata),
                .MASK(mask),
                .WADDR(addr),
                .WE(we),
                .WCLKE(clke),
                .WCLK(clk),
                .RDATA(rdata),
                .RADDR(raddr),
                .RE(re),
                .RCLK(rclk),
                .RCLKE(rclke)
            );
        end
    endgenerate

    // Connect the BRAM outputs to the instruction memory output
    //////////////////////// assign out = bram_data[addr]; DK IF THIS SHOULD BE HERE OR THE NEXT LINE BELOW
	assign inst_mem_out = bram_data[addr];

    // Initialize the BRAM data
    initial begin
        $readmemh("verilog/program.hex", bram_data);
    end
endmodule
