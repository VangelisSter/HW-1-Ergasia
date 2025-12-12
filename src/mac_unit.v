`timescale 1ns / 1ps
module mac_unit(
    input wire signed[31:0] op1,
    input wire signed[31:0] op2,
    input wire signed[31:0] op3,
    output wire[31:0] total_result,
    output wire zero_mul,
    output wire zero_add,
    output wire ovf_mul,
    output wire ovf_add
);

wire signed[31:0] mul_temp_result;
parameter[3:0] ALUOP_MUL = 4'b0110; //Signed Multiplication
parameter[3:0] ALUOP_ADD = 4'b0100; //Signed Addition

ALU MUL_ALU(
    .zero(zero_mul),
    .result(mul_temp_result),
    .ovf(ovf_mul),
    .op1(op1),
    .op2(op2),
    .alu_op(ALUOP_MUL)
);

ALU ADD_ALU(
    .zero(zero_add),
    .result(total_result),
    .ovf(ovf_add),
    .op1(mul_temp_result),
    .op2(op3),
    .alu_op(ALUOP_ADD)
);

endmodule