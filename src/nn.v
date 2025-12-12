`timescale 1ns / 1ps
module NN
    # (parameter DATAWIDTH = 32)
    (
    input wire signed[31:0] input_1,
    input wire signed[31:0] input_2,
    input wire clk,
    input wire resetn,
    input wire enable,
    output reg[31:0] final_output,
    output reg total_ovf,
    output reg total_zero,
    output reg[2:0] ovf_fsm_stage,
    output reg[2:0] zero_fsm_stage
);

reg[7:0] address_ROM;
reg[DATAWIDTH - 1: 0] = RegFileWriteData1;
reg[DATAWIDTH - 1: 0] = RegFileWriteData2;
reg[3:0] readReg1, readReg2, readReg2, readData3, readData4, writeReg1, writeReg2;
reg write;

initial
    begin
        address_ROM = 8;
        write = 0;
    end

regfile REGFILE(
    .resetn(resetn),
    .clk(clk),
    .readReg1(readReg1),
    .readReg2(readReg2),
    .readReg3(readReg3),
    .readReg4(readReg4),
    .writeReg1(writeReg1),
    .writeReg2(writeReg2),
    .write(write),
    .writeData1(RegFileWriteData1),
    .writeData2(RegFileWriteData2),
);

WEIGHT_BIAS_MEMORY ROM(
    .clk(clk),
    .addr1(address_ROM),
    .addr2(address_ROM + 4),
    .dout1(RegFileWriteData1),
    .dout2(RegFileWriteData2)
);

reg[2:0] fsm_stage;

always @ (posedge clk, negedge resetn)
    begin
        if (~resetn == 1)
            begin
                fsm_stage <= 3'b000;
                final_output <= 32'hFFFFFFFF; //Max 32bit number
                total_ovf <= 1'b0;
                total_zero <= 1'b1;
                ovf_fsm_stage <= 3'b111;
                zero_fsm_stage <= 3'b000;
                //Reset registers
            end
        else
            begin
                case (fsm_stage)
                    3'b000  : begin
                        if (enable == 1'b1)
                            fsm_stage <= 3'b001; // After reset, Load Weights and Biases
                    end

                    3'b001  : begin
                        writeReg1 <= 4'h2; // shift_bias_1
                        writeReg2 <= 4'h3; // shift_bias_2
                        write = 1;
                        #20 // Wait for two clock cycles for them to be written in the regfile
                        address_ROM <= address_ROM + 8;
                        writeReg1 <= 4'h4; // weight_1
                        writeReg2 <= 4'h5; // bias_1
                        #20
                        address_ROM <= address_ROM + 8;
                        writeReg1 <= 4'h6; // weight_2
                        writeReg2 <= 4'h7; // bias_2
                        #20
                        address_ROM <= address_ROM + 8;
                        writeReg1 <= 4'h8; // weight_3
                        writeReg2 <= 4'h9; // weight_4
                        #20
                        address_ROM <= address_ROM + 8;
                        writeReg1 <= 4'h10; // bias_3
                        writeReg2 <= 4'h11; // shift_bias_3
                        #20
                        write = 0;
                        fsm_stage <= 3'b010; // Go to Data Pre-Processing Layer stage
                    end
                    3'b010  : begin
                        
                    end
                endcase
            end
    end

endmodule