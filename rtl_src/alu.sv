/*
this file contains code for an alu 

control: alu operation is controlled by a 4 bit alu_op signal

input: alu operations are done on the 2 32 bit inputs, in_a and in_b

output: the result of the operation is output on the 32 bit result signal
*/

import control_signals::*;	//import alu control

module alu(
	input AluCntrl alu_op,		//control

	input logic [31:0] in_a, 	//input
	input logic [31:0] in_b,  

	output logic  [31:0] result 	//output
);

	always_comb begin	
		case(alu_op) 
			ALU_ADD:	result = in_a + in_b;				//addition
			ALU_SUB:	result = in_a - in_b;				//subtraction 

			//shift amounts are determined by lowest 5 bits of in_b 
			ALU_SHIFT_LL:	result = in_a <<  in_b[4:0];			//logical left shift
			ALU_SHIFT_RL:	result = in_a >>  in_b[4:0];			//logical right shift
			ALU_SHIFT_RA:	result = $signed(in_a) >>> in_b[4:0];		//arithmetic right shift
		
			ALU_SET_LT:	result = $signed(in_a) < $signed(in_b);		//set less than
			ALU_SET_LTU:	result = $unsigned(in_a) < $unsigned(in_b);	//set less than unsigned
	
			ALU_XOR:	result = in_a ^ in_b; 				//xor
			ALU_OR:		result = in_a | in_b;				//or
			ALU_AND:	result = in_a & in_b;				//and

			ALU_PASS_A:	result = in_a;					//pass a
			ALU_PASS_B:	result = in_b;					//pass b

			ALU_PC_INC:	result = in_a + 32'd4;				//inc a by 4
			default:	result = 'x;
		endcase 
	end

endmodule
