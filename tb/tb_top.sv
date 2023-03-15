/*
This file is the top level module for the test bench
 
this module holds and connects the DUT, test and interface

this module 
	defines the tb clock
	creates the test from the test_file, 
	resets the dut
	then runs the test

the components(generator,driver,monitor,scoreboard...) making up the test can be found in the tb_components file
*/

//import test bench test and control signals
import tb_components::*;
import control_signals::*;

//test are stored in the TEST_FILE
parameter string TEST_FILE = "../tb/test.txt";

//intercae to DUT
interface intf(input logic clk,reset);
	AluCntrl alu_op;		//control

	logic [31:0] in_a;		//input
	logic [31:0] in_b;

	logic [31:0] result;		//output
	
	semaphore key = new(1);		//semaphore to control access
endinterface

//test bench top level module,
//connects test and DUT through the  interface
//start clock
//reset dut 
//starts the test
module tb_top;

	bit clk;
	bit reset;

	always #5 clk = ~clk;			//start clk signal

	initial begin				//reset dut
		reset = 1;
		#5 reset = 0;
	end

	intf i_intf(clk,reset);			//interface

	alu DUT(				//DUT
		.alu_op(i_intf.alu_op),
		.in_a(i_intf.in_a),
		.in_b(i_intf.in_b),
		.result(i_intf.result)
	);

	test t1;				//test


	initial begin 
		t1 = new(i_intf,TEST_FILE);	//create test from test_file
		t1.run();			//run test
	end

endmodule
