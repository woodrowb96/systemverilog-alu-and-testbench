package control_signals;

	typedef enum logic[3:0]{
		ALU_ADD,
		ALU_SUB,
		ALU_SHIFT_LL,
		ALU_SHIFT_RL,
		ALU_SHIFT_RA,
		ALU_SET_LT,
		ALU_SET_LTU,
		ALU_XOR,
		ALU_OR,
		ALU_AND,
		ALU_PASS_A,
		ALU_PASS_B,
		ALU_PC_INC,
		ALU_X = 'x
	}AluCntrl;

	AluCntrl string_to_alu_cntrl[string] = '{
		"ALU_ADD" : ALU_ADD,
		"ALU_SUB" : ALU_SUB,
		"ALU_SHIFT_LL" : ALU_SHIFT_LL,
		"ALU_SHIFT_RL" : ALU_SHIFT_RL,
		"ALU_SHIFT_RA" : ALU_SHIFT_RA,
		"ALU_SET_LT" : ALU_SET_LT,
		"ALU_SET_LTU" : ALU_SET_LTU,
		"ALU_XOR" : ALU_XOR,
		"ALU_OR" : ALU_OR,
		"ALU_AND" : ALU_AND,
		"ALU_PASS_A" : ALU_PASS_A,
		"ALU_PASS_B" : ALU_PASS_B,
		"ALU_PC_INC" : ALU_PC_INC,
		"ALU_X" : ALU_X
	};

endpackage
