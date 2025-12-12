`timescale 1ns / 1ps
module alu_tb();
    reg signed [31:0] op1_tb, op2_tb;
    reg [3:0] alu_op_tb;
    wire zero_tb, ovf_tb;
    wire signed [31:0] result_tb;
    reg[15:0] something = -1;
    reg[31:0] something_extended;//= { {16{something[15]}}, something};

    ALU DUT(
        .result(result_tb),
        .zero(zero_tb),
        .ovf(ovf_tb),
        .alu_op(alu_op_tb),
        .op1(op1_tb),
        .op2(op2_tb)
    );
    parameter[3:0] ALUOP_AND = 4'b1000;
    parameter[3:0] ALUOP_OR = 4'b1001;
    parameter[3:0] ALUOP_NOR = 4'b1010;
    parameter[3:0] ALUOP_NAND = 4'b1011;
    parameter[3:0] ALUOP_XOR = 4'b1100;
    parameter[3:0] ALUOP_ADD = 4'b0100; //Signed Addition
    parameter[3:0] ALUOP_SUB = 4'b0101; //Signed Subtraction
    parameter[3:0] ALUOP_MUL = 4'b0110; //Signed Multiplication
    parameter[3:0] ALUOP_LRS = 4'b0000; //Logical Right Shift by op2 bits
    parameter[3:0] ALUOP_LLS = 4'b0001; //Logical Left Shift by op2 bits
    parameter[3:0] ALUOP_ARS = 4'b0010; //Arithmetic(?) Right Shift by op2 bits
    parameter[3:0] ALUOP_ALS = 4'b0011; //Arithmetic(?) Left Shift by op2 bits
    parameter[31:0] INT_MAX = (1 << 31) - 1; //Max 32bit Signed integer
    parameter[31:0] INT_MIN = -(1 << 31);
    parameter[31:0] ONE = 1;
    parameter[31:0] MINUS_ONE = {32{1'b1}};
    
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);
        something_extended = { {16{something[15]}}, something};
        #5
        $display("something=%b, something_extended=%b", something, something_extended);
        
        //Test addition function and overflow
        $display("Addition");
        alu_op_tb = ALUOP_ADD; op2_tb = INT_MAX; op1_tb = ONE;//Overflow from positive to negative
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%d", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op2_tb = INT_MIN; op1_tb = MINUS_ONE; //Overflow from negative to positive
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%d", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = {32{1'b0}}; op2_tb = op1_tb; //Check zero functionality
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test substraction function and overflow
        $display("Substraction");
        alu_op_tb = ALUOP_SUB; op1_tb = INT_MAX; op2_tb = MINUS_ONE; //INT_MAX - MINUS_ONE
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = INT_MIN; op2_tb = ONE; //INT_MIN - ONE
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = ONE; op2_tb = ONE; //ONE - ONE
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test multiplication function and overflow
        $display("Multiplication");
        alu_op_tb = ALUOP_MUL; op1_tb = INT_MAX; op2_tb = 2; //INT_MAX * 2
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = INT_MAX; op2_tb = 0; //INT_MAX * 0
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test logical AND
        $display("AND");
        alu_op_tb = ALUOP_AND; op1_tb = 0; op2_tb = 0;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = 0; op2_tb = 1;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        op1_tb = 1; op2_tb = 1;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test Logical Shift Left
        $display("Logical Shift Left");
        alu_op_tb = ALUOP_LLS; op1_tb = INT_MIN; op2_tb = 1;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test Logical Shift Right
        $display("Logical Shift Right");
        alu_op_tb = ALUOP_LRS; op1_tb = INT_MIN; op2_tb = 1;
        #10
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        //Test Arithmetic Shift Left
        $display("Arithmetic Shift Left");
        alu_op_tb = ALUOP_ALS; op1_tb = INT_MIN + 1; op2_tb = 1;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        $display("Arithmetic Right Left");
        alu_op_tb = ALUOP_ARS; op1_tb = INT_MIN + 1; op2_tb = 1;
        #5
        $display("op1=%b, op2=%b, result=%b, ovf=%b, zero=%b", op1_tb, op2_tb, result_tb, ovf_tb, zero_tb);
        $finish;
    end
endmodule