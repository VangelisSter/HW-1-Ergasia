`timescale 1ns / 1ps
module ALU(
    output reg zero,
    output reg signed[31:0] result,
    output reg ovf,
    input wire signed[31:0] op1,
    input wire signed[31:0] op2,
    input wire[3:0] alu_op
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
parameter[3:0] ALUOP_ARS = 4'b0010; //Arithmetic Right Shift by op2 bits
parameter[3:0] ALUOP_ALS = 4'b0011; //Arithmetic Left Shift by op2 bits
//buffer_bits = 31'b0

reg signed [63:0] extended_product;
reg [31:0] prod_low_MSB_ext;//, shift_bits;
//reg temp_sign;

always @ (op1, op2, alu_op)
    begin
        case (alu_op)
            ALUOP_AND   : result = op1 & op2;
            ALUOP_OR    : result = op1 | op2;
            ALUOP_NOR   : result = ~(op1 | op2);
            ALUOP_NAND  : result = ~(op1 & op2);
            ALUOP_XOR   : result = op1 ^ op2;
            ALUOP_ADD   : begin 
                result = op1 + op2;
                ovf = (op1[31] == op2[31]) && (result[31] != op1[31]);
            end
            ALUOP_SUB   : begin 
                result = op1 + (~op2 + 1); //two's complement of op2
                ovf = (op1[31] != op2[31]) && (result[31] != op1[31]);
            end
            ALUOP_MUL   : begin
                extended_product = op1 * op2;
                prod_low_MSB_ext = extended_product[31] ? {32{1'b1}} : {32{1'b0}};
                ovf = |(extended_product[63:32] ^ prod_low_MSB_ext);
                result = extended_product[31:0];
            end
            ALUOP_LLS   : begin
                result = op1 << op2[4:0];
                ovf = (op1[31] == result[31]) ? 0 : 1;
            end
            ALUOP_LRS   : begin
                result = op1 >> op2[4:0];
                ovf = (op1[31] == result[31]) ? 0 : 1;
            end
            ALUOP_ALS   : begin
                result = op1 <<< op2[4:0];
                ovf = 0;
            end
            ALUOP_ARS   : begin
                result = op1 >>> op2[4:0];
                ovf = (op1[31] == result[31]) ? 0 : 1;
            end
            default     : begin
                result = {32{1'b0}};
                zero = 1'b1;
                ovf = 0;
            end
        endcase
        zero = 0;
        if (result == {32{1'b0}})
            zero = 1;
    end
endmodule
