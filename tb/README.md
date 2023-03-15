This folder contains code used to construct a directed test, test bench, used to test the alu.

The test bench is made up of the following components. 
* test_cases: A class which reads in and stores test cases, stored in the test.txt file.
* transaction: Sent between tb componets, containing test values to be driven onto the DUT.
* generator: Generates transactions from test_cases, sends transactions to driver.
* driver: Drives transactions onto DUT, through an interface.
* monitor: Reads sets of input and output, on the DUT interface. Turns each set into a transaction, that is sent to the scoreboard. *scoreboard: Determins and records test outcome by comparing transaction output agains expected output,from the test_cases class.
* environment: Initializes, and holds the generator,driver,monitor, and scoreboard.
* test: Creates the environment, and facilitates the test.

The test bench top level module is in the tb_top.sv file. 
Test bench components can be found in the tb_components.sv file.
Test cases are stored in the tests.txt file.
