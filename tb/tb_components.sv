/*
This file contains all componmets used to create a directed test, test bench

Tests are read in from a test.txt file, then a test is created from the following components
	
	transaction: used to send signals between components, and to/from DUT through an interface

	test_case:used to store a single test cases information, read in from the test_file

	test_cases:usec to hold all test_cases read in from the test_file

	generator:generates transactions from test_cases, sends those transactions to the driver

	driver:drives transactions into DUT through interface

	monitor:reads input and output on the DUT interface, turns them into transactions, sent to scoreboard

	scoreboard:compares transaction output,with exepcted output from test_case to determine the outcome of the test

	environment:creates and hold test_cases,generator,driver,monitor,scoreboard and defines test operation

	test:creates environment and starts directed test
*/

package tb_components;

	//import cntrl signals 	
	import control_signals::*;

	//enumerate a typedef to represent test outcome
	typedef enum {PASS,FAIL} Outcome;
	
	//seperators, used to formate terminal output	
	parameter string MSG_SEP_LRG = "#######################################################################################";
	parameter string MSG_SEP_M =   "****************************************************";
	parameter string MSG_SEP_SM =  "------------------------";

	//tests cases can be stored in the test file, using the following radixes
	parameter string BIN = "binary";
	parameter string DEC = "decimal";
	parameter string HEX = "hex";

	//test cases, are formated in the test file, in the following ways
	parameter string TEST_FORMAT_D = "{ alu_op: %s , in_a: %d , in_b: %d , result: %d }"; 
	parameter string TEST_FORMAT_B = "{ alu_op: %s , in_a: %b , in_b: %b , result: %b }";
	parameter string TEST_FORMAT_H = "{ alu_op: %s , in_a: %h , in_b: %h , result: %h }";

	//test radix, and descriptions are formated in the test file in the following ways
	parameter string RADIX_FORMAT = "{ radix: %s }";
	parameter string MSG_FORMAT = "{ msg: %s }";


/**************************************************** TRANSACTION **********************************************************/

	//transactions to be sent between tb components
	class transaction;

		AluCntrl alu_op;		//control
		int in_a,in_b;		//input
		logic [31:0] result;		//output

		function new(AluCntrl alu_op = ALU_X, logic [31:0] in_a = 'x, in_b = 'x);
			this.alu_op = alu_op;
			this.in_a = in_a;
			this.in_b = in_b;
		endfunction
	
		function void display(string location,int test_number);
			$display(MSG_SEP_SM);				//display
			$display("- Test Num:%d",test_number);		//test number
			$display("- Location:%s",location);		//location of trans in tb
			$display("- time:%t",$time);			//simulation time
			$display("- alu_op = %s",alu_op.name());	//control
			$display("- in_a = %d",in_a);			//input
			$display("- in_b = %d",in_b);
			$display("- result = %d",result);		//output
		endfunction

		//drive input and control signals onto interface
		task drive_input(virtual intf vif);
			vif.alu_op = alu_op;
			vif.in_a = in_a;
			vif.in_b = in_b;
		endtask

		//read input and control signals from interface
		task read_input(virtual intf vif);
			alu_op = vif.alu_op;
			in_a = vif.in_a;
			in_b = vif.in_b;
		endtask
	
		//read output signals from interface
		task read_output(virtual intf vif);
			result = vif.result;
		endtask

	endclass

/********************************************** TEST_CASE ***********************************************************/

	//this class holds information for a single test case,read in from the test file	
	class test_case;

		int number; 			//test number		
		string description,radix;	//description and test radix
		
		AluCntrl alu_op; 		//control
		int in_a,in_b;		//input
		logic [31:0] expected_result;	//expected output of test
		
		time end_time;			//simulation time when outcome is calculated in scoreboard
		Outcome outcome;		//PASS for a succesfull test, FAIL for failed test

		function new(int number);
			this.number = number;
		endfunction

		//generate a transaction, from test case values	
		function transaction gen_transaction();
			transaction trans = new(alu_op,in_a,in_b);
			return trans;
		endfunction			

		//calc test outcome by comparing transaction and expected result
		function void calc_outcome(transaction trans);
			if(expected_result == trans.result) outcome = PASS;
			else outcome = FAIL;
		endfunction

		//read one test case from the test file
		//return Pass to indicate succesfull read, else False
		function Outcome read_test(int file);			

			string alu_op_str;	//read in alu_op as a string,convert to AluCntrl later

			//read in test radix	
			if($fscanf(file,RADIX_FORMAT,radix) != 1) return FAIL;	
			
			//looks at radix to determin how to read in test values
			unique case(radix)
				BIN: if($fscanf(file,TEST_FORMAT_B,alu_op_str,in_a,in_b,expected_result) != 4) return FAIL;
				DEC: if($fscanf(file,TEST_FORMAT_D,alu_op_str,in_a,in_b,expected_result) != 4) return FAIL;
				HEX: if($fscanf(file,TEST_FORMAT_H,alu_op_str,in_a,in_b,expected_result) != 4) return FAIL;
			endcase				
			
			alu_op = string_to_alu_cntrl[alu_op_str];	//conv string to AluCntrl
	
			//finally read in test description	
			if($fscanf(file,MSG_FORMAT,description) != 1) description = "None";			

			return PASS;
		endfunction

		function void display_outcome(transaction trans);		//display
			$display("- Test Outcome: %s",outcome);			//outcome
			$display("\t- Expected: \t\t%d",expected_result);		//expected output dec
			$display("\t- Actual: \t\t%d",trans.result);		//actual output dec
			$display("\t- Expected: \t\t%b",expected_result);		//expected output bin
			$display("\t- Actual: \t\t%b",trans.result);		//actual output bin
		endfunction

		//display briefe information about test
		function void display_description();
			$display(MSG_SEP_SM);					//display
			$display("- Test Number: %d",number);			//test number
			$display("- Simulation Time: %t",end_time);		//end time
			$display("- Test Description: \n\t%s",description);	//descritpion
		endfunction
	endclass

/************************************************* TEST_CASES *************************************************************/

	//this class hold all test cases, for the generator and scoreboard to accesss 
	//it also hold all test wich failed, and passed in there own qeues to be displayed at the end of simulation
	class test_cases;

		test_case cases[$];	//all test cases
		test_case fails[$];	//test cases that failed
		test_case passes[$];	//test cases that passed
	
		//construct test_cases from test_file
		function new(string test_file);				
			int file = $fopen(test_file,"r");
			if(!file) $display("File -%s NOT opended sucesfully",test_file);
		
			read_test_file(file);
		
			$fclose(test_file);
		endfunction

		//read the test file
		function void read_test_file(int file);			
			forever begin					//loop forever
				test_case t = new(cases.size());
				if(t.read_test(file) == PASS) 		//read in test cases
					cases.push_back(t);		//push test_cases onto cases
				else
					 break;				//break once a test fails to be read in
			end
		endfunction
		
		function void display_outcomes();				//display
			$display(MSG_SEP_M);
			$display("- Passes: %d",passes.size());			//num passes
			$display("- Fails: %d",fails.size()); 			//num fails
			$display(MSG_SEP_M);
			$display("FAILED TESTS");
			foreach(fails[i]) fails[i].display_description();	//each failed test
			$display(MSG_SEP_M);
		endfunction
	endclass

/************************************************ GENERATOR *************************************************************/

	//this class generates transactions, from test cases
	//then sends transactions to driver	
	class generator;
		
		test_cases tests;	//generate transactions from test cases
		mailbox gen2driv;	//mailbox to send transaction to driver
		event ended;		//indicates all transactions have been generated

		function new(mailbox gen2driv,test_cases tests);
			this.gen2driv = gen2driv;
			this.tests = tests;
		endfunction

		//generate transactions from test cases 
		task main();
			//gen transactions, send them to driver
			foreach(tests.cases[i]) gen2driv.put(tests.cases[i].gen_transaction());	
			
			//signal end of generation
			-> ended;						
		endtask
	endclass

/************************************************* DRIVER ****************************************************************/

	//this class recieves transactions from generator and
	//drives transactions into DUT through interface
	class driver;
		
		virtual intf vif;	//interface, to be driven
		mailbox gen2driv;	//recieve transactions from generator
		int test_number;	//total number of tests driven


		function new(virtual intf vif,mailbox gen2driv);
			this.vif = vif;
			this.gen2driv = gen2driv;
		endfunction

		//wait through reset proccess, in tb_top
		task reset;
			wait(vif.reset);
			$display(MSG_SEP_M);
			$display("[Driver] ----- Reset Started -----\n- time: %t",$time);
			wait(!vif.reset);
			$display("[Driver] ----- Reset Ended -----\n- time: %t",$time);
			$display(MSG_SEP_M);
		endtask
	
		//get transactions from generator
		//drive trans onto interface	
		//then read the result
		task main;
			forever begin
				transaction trans;
				gen2driv.get(trans);		//get transaction
		
				/****** drive interface ****/	
				vif.key.get(1);			//lock interface
				@(posedge vif.clk);		//wait one clk cycle
				trans.drive_input(vif);		//drive interface
				vif.key.put(1);			//unlock interface

				/****** read output ********/		
				@(posedge vif.clk);		//wait one clock cycle
				trans.read_output(vif);		//read output
				
				//trans.display("[Driver]",test_number);
				test_number++;			//move on to next transaction	
			end
		endtask
	endclass

/************************************************** MONITOR *****************************************************************/

	//this class monitors monitors the DUTs interface
	//it then turns each set of inputs and outputs transactions, 
	//and sends them to the scoreboard 
	class monitor;
		
		virtual intf vif;	//DUTS interface
		mailbox mon2scb;	//mailbox used to send transactions to scoreboard
		int test_number;	//number of tests

		function new(virtual intf vif,mailbox mon2scb);
			this.vif = vif;
			this.mon2scb = mon2scb;
		endfunction

		//read interface input
		//read interface output
		//create and send transaction to scoreboard
		task main;
			forever begin
				transaction trans = new();		//create new tranasction
			
				/****** read input ******/		
				@(posedge vif.clk);			//wait one clk cycle
				vif.key.get(1);				//lock interface 	
				trans.read_input(vif);			//read interface input
				vif.key.put(1);				//unlock interface	

				/****** read output *****/	
				@(posedge vif.clk);			//wait one clk cyle	
				trans.read_output(vif);			//read output
				
				mon2scb.put(trans);			//send transaction to scoreboard
				
				//trans.display("[Monitor]",test_number);
				test_number++; 				//move on to next test;
			end
		endtask

	endclass

/********************************************* **** SCOREBOARD ***************************************************************/

	//this class recieves transactions from monitor
	//compares the transactions output, with the expected output
	//uses comparesson to determine,recode and display outcome
	class scoreboard;

		test_cases tests;	//test_cases with expected outputs

		mailbox mon2scb;	//recieve transactions from monitor
		int test_number;

		function new(mailbox mon2scb,test_cases tests);
			this.mon2scb = mon2scb;
			this.tests = tests;
		endfunction

		//get transactions from the monitor, 
		//calculate and record outcome
		//display outcome
		task main;

			transaction trans;
			test_case current_test;	
			
			forever begin
				mon2scb.get(trans);				//get and display transaction
				trans.display("[Scoreboard]",test_number);	
	
				current_test = tests.cases[test_number];	//get the current test case
				current_test.end_time = $time;			//record test_cases end time
	
				calc_outcome(current_test,trans);		//calc and record outcome
				display_outcome(current_test,trans);		//display outcome	

				test_number++;					//move on to next test	
			end
		endtask

		//use transactions output and expected output to calculate test outcome
		//record the outcome in test_cases class
		task calc_outcome(test_case current_test,transaction trans);

			current_test.calc_outcome(trans);			//calc outcome
			
			unique case(current_test.outcome)			//record outcome by pushing test case onto 
				PASS: tests.passes.push_back(current_test);	//passes or
				FAIL: tests.fails.push_back(current_test);	//fails
			endcase
		endtask	
	
		task display_outcome(test_case current_test,transaction trans);	
			$display(MSG_SEP_SM);						//display
			$display("- Test Description: %s",current_test.description);	//test description
			$display(MSG_SEP_SM);
			current_test.display_outcome(trans);				//test outcome
			$display(MSG_SEP_M);
		endtask
	endclass

/****************************************************** ENVIRONMENT ************************************************************/

	//this class is used to hold and creates elements of the tb except the interface and DUT
	//it also defines pre_test,test,post_test tasks that the tb executes
	class environment;

		test_cases tests;	//test cases	
		
		generator gen;		//tb componetnts
		driver driv;
		monitor mon;
		scoreboard scb;

		mailbox gen2driv;	//mailboxes
		mailbox mon2scb;
	
		virtual intf vif;

		//create all parts of test bench environment
		function new(virtual intf vif,string test_file);
			this.vif = vif;

			gen2driv = new();		//construct mailboxes
			mon2scb = new();
			tests = new(test_file);		//construct tests from test file

			gen = new(gen2driv,tests);	//construct components from tests and mailboxes
			driv = new(vif,gen2driv);
			mon = new(vif,mon2scb);
			scb = new(mon2scb,tests);
		endfunction

		//this function hanldes the pre test
		task pre_test();
			$display(MSG_SEP_LRG);
			$display("- PRE TEST REPORT");
			$display(MSG_SEP_LRG);
			driv.reset();			//reset DUT
		endtask

		//this task facilitates the test	
		task test();
			$display(MSG_SEP_LRG);
			$display("- TEST REPORT");
			$display(MSG_SEP_LRG);

			//start each tb component as a seperate thread
			fork
				gen.main();
				driv.main();
				mon.main();
				scb.main();
			join_any
		endtask

		//this task facilitates the post test
		task post_test();
			wait(gen.ended.triggered);			//wait for test to be over
			wait(tests.cases.size() == driv.test_number);
			wait(tests.cases.size() == scb.test_number);
			
			$display(MSG_SEP_LRG);				
			$display("- POST TEST REPORT");	
			$display(MSG_SEP_LRG);
			tests.display_outcomes();			//display test outcomes	
			$display(MSG_SEP_LRG);
		endtask

		//this task runs the pre_test,test and post tests
		task run;
			pre_test();
			test();
			post_test();
			$stop;			//stop simulation, once post_test is over
		endtask

	endclass

/*********************************************************** TEST **************************************************************/

	//the test class holds the testing environment and starts the testing process
	class test;
		environment env;

		function new(virtual intf vif,string test_file);
			env = new(vif,test_file);
		endfunction

		task run();
			env.run();
		endtask
	endclass

endpackage
