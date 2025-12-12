`timescale 1ns / 1ps
module calc(
    input wire clk,
    input wire btnc,
    input wire btnac,
    input wire btnl,
    input wire btnr,
    input wire btnd,
    input wire[15:0] sw,
    output reg[15:0] led
);

wire zero_calc, ovf_calc;
wire[31:0] alu_result;
reg[15:0] accumulator;
reg[31:0] accumulator_extended;
wire[31:0] sw_extended;
wire[3:0] alu_op_calc;


alu_op_enc enc (.alu_op(alu_op_calc),
 .btnl_enc(btnl),
 .btnr_enc(btnr),
 .btnd_enc(btnd)
 );

 ALU alu (.zero(zero_calc), .result(alu_result), .ovf(ovf_calc),
 .op1(accumulator_extended),
 .op2(sw_extended),
 .alu_op(alu_op_calc)
 );

assign sw_extended = { {16{sw[15]}}, sw};

always @ (posedge clk)
    begin
        if (btnac == 1'b1)
            accumulator <= {16{1'b0}};
        else if (btnc == 1'b1)
            //$display("Here");
            accumulator <= alu_result[15:0];
        accumulator_extended <= { {16{accumulator[15]}}, accumulator};
        led <= accumulator;
    end

endmodule