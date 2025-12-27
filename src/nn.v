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
    output reg[2:0] ovf_fsm_state,
    output reg[2:0] zero_fsm_state
);
//Declaring regfile variables
reg[7:0] address_ROM;
reg[DATAWIDTH - 1: 0] RegFileWriteData1;
reg[DATAWIDTH - 1: 0] RegFileWriteData2;
reg[3:0] readReg1, readReg2, readReg3, readReg4, writeReg1, writeReg2;
wire[DATAWIDTH - 1: 0] readData1, readData2, readData3, readData4;
reg[DATAWIDTH - 1: 0] tempReg1, tempReg2;
reg write;
//Declaring ALU variables
wire[1:0] zero_ALU;
wire[1:0] ovf_ALU;
wire signed[31:0] result_ALU1, result_ALU2;
reg signed[31:0] op1_ALU1, op2_ALU1, op1_ALU2, op2_ALU2;
reg[7:0] alu_op_ALU;
//Declaring mac variables
reg signed[31:0] op1_mac1, op2_mac1, op3_mac1, op1_mac2, op2_mac2, op3_mac2;
wire[31:0] total_result_mac1, total_result_mac2;
wire[3:0] zero_mac; //zero_mul_mac1, zero_add_mac1, zero_mul_mac2, zero_add_mac2
wire[3:0] ovf_mac; //ovf_mul_mac1, ovf_add_mac1, ovf_mul_mac2, ovf_add_mac2



//State declaration
parameter Deactivated_State = 3'b000;
parameter Loading_W_B = 3'b001;
parameter Data_Pre_Layer = 3'b010;
parameter Input_Layer = 3'b011;
parameter Output_Layer = 3'b100;
parameter Data_Post_Layer = 3'b101;
parameter Idle_State = 3'b110;

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
    .readData1(readData1),
    .readData2(readData2),
    .readData3(readData3),
    .readData4(readData4)
);

ALU ALU1(
    .zero(zero_ALU[0]),
    .result(result_ALU1),
    .ovf(ovf_ALU[0]),
    .op1(op1_ALU1),
    .op2(op2_ALU1),
    .alu_op(alu_op_ALU[3:0])
);

ALU ALU2(
    .zero(zero_ALU[1]),
    .result(result_ALU2),
    .ovf(ovf_ALU[1]),
    .op1(op1_ALU2),
    .op2(op2_ALU2),
    .alu_op(alu_op_ALU[7:4])
);

mac_unit MAC1(
    .op1(op1_mac1),
    .op2(op2_mac1),
    .op3(op3_mac1),
    .total_result(total_result_mac1),
    .zero_mul(zero_mac[0]),
    .zero_add(zero_mac[1]),
    .ovf_mul(ovf_mac[0]),
    .ovf_add(ovf_mac[1])
);

mac_unit MAC2(
    .op1(op1_mac2),
    .op2(op2_mac2),
    .op3(op3_mac2),
    .total_result(total_result_mac2),
    .zero_mul(zero_mac[2]),
    .zero_add(zero_mac[3]),
    .ovf_mul(ovf_mac[2]),
    .ovf_add(ovf_mac[3])
);

/*WEIGHT_BIAS_MEMORY ROM(
    .clk(clk),
    .addr1(address_ROM),
    .addr2(address_ROM + 4),
    .dout1(RegFileWriteData1),
    .dout2(RegFileWriteData2)
);
*/
reg[2:0] current_state, next_state;

always @ (current_state)
    begin: NEXT_STATE_LOGIC
        if (resetn && enable)
            begin
                        case (current_state)
                            Deactivated_State   : begin
                                if (resetn && enable)
                                    next_state = Loading_W_B;
                            end
                            Loading_W_B         : begin
                                    total_ovf = 0;
                                    total_zero = 0;
                                    write = 1'b1;
                                    writeReg1 = 4'h0;
                                    writeReg2 = 4'h1;
                                    RegFileWriteData1 = 0;
                                    RegFileWriteData2 = 0;
                                    #20
                                    writeReg1 = 4'h2; //shift_bias_1
                                    writeReg2 = 4'h3; //shift_bias_2
                                    #20 //Wait for a clock cycle so that the data passes from the rom to the regfile
                                    address_ROM += 8;
                                    writeReg1 += 2; //weight_1
                                    writeReg2 += 2; //bias_1
                                    #20
                                    address_ROM += 8;
                                    writeReg1 += 2; //weight_2
                                    writeReg2 += 2; //bias_2
                                    #20
                                    address_ROM += 8;
                                    writeReg1 += 2; //weight_3
                                    writeReg2 += 2; //weight_4
                                    #20
                                    address_ROM += 8;
                                    writeReg1 += 2; //bias_3
                                    writeReg2 += 2; //shift_bias_3
                                    #20
                                    //Done loading
                                    write = 1'b0;
                                    next_state = Data_Pre_Layer;
                                    readReg1 = 4'h2;
                                    readReg2 = 4'h3;
                                end
                            Data_Pre_Layer      : begin
                                alu_op_ALU[3:0] = 4'b0010;
                                alu_op_ALU[7:4] = 4'b0010;
                                op1_ALU1 = input_1;
                                op2_ALU1 = readData1;
                                op1_ALU2 = input_2;
                                op2_ALU2 = readData2;
                                tempReg1 = result_ALU1;
                                tempReg2 = result_ALU2;
                                total_zero = |zero_ALU;
                                if (total_zero)
                                    zero_fsm_state = current_state;
                                //Prepare to read the data from regfile for the next state if there is no overflow
                                if (|ovf_ALU)
                                    begin
                                        total_ovf = 1;
                                        ovf_fsm_state = current_state;
                                        final_output = {32{1'b1}};
                                        next_state = Idle_State;
                                    end
                                else
                                    begin
                                        total_ovf = 0;
                                        readReg1 = 4'h4; //weight_1
                                        readReg2 = 4'h5; //bias_1
                                        readReg3 = 4'h6; //weight_2
                                        readReg2 = 4'h7; //bias_2
                                        next_state = Input_Layer; 
                                    end
                                end
                            Input_Layer       : begin
                                op1_mac1 = tempReg1;
                                op2_mac1 = readData1;
                                op3_mac1 = readData2;
                                op1_mac2 = tempReg2;
                                op2_mac2 = readData3;
                                op3_mac2 = readData4;
                                total_zero = |zero_mac;
                                if (total_zero)
                                    zero_fsm_state = current_state;
                                if (|ovf_mac)
                                    begin
                                        total_ovf = 1;
                                        ovf_fsm_state = current_state;
                                        final_output = {32{1'b1}};
                                        next_state = Idle_State;
                                        
                                    end
                                else
                                    begin
                                        total_ovf = 0;
                                        tempReg1 = total_result_mac1;
                                        tempReg2 = total_result_mac2;
                                        readReg1 = 4'h8; //weight_3
                                        readReg2 = 4'h9; //weight_4
                                        readReg3 = 4'hA; //bias_3
                                        next_state = Output_Layer;
                                    end
                            end
                            Output_Layer      : begin
                                op1_mac2 = tempReg2;
                                op2_mac2 = readData2;
                                op3_mac2 = readData3;
                                op1_mac1 = tempReg1;
                                op2_mac1 = readData1;
                                op3_mac1 = total_result_mac2;
                                total_zero = |zero_mac;
                                if (total_zero)
                                    zero_fsm_state = current_state;
                                if (|ovf_mac)
                                    begin
                                        total_ovf = 1;
                                        ovf_fsm_state = current_state;
                                        final_output = {32{1'b1}};
                                        next_state = Idle_State;
                                    end
                                else
                                    begin
                                        total_ovf = 0;
                                        tempReg1 = total_result_mac1;
                                        readReg1 = 4'hB; //shift_bias_3
                                        next_state = Data_Post_Layer;
                                    end 
                            end
                            Data_Post_Layer      : begin
                                next_state = Idle_State;
                            end
                        endcase
            end
    end

always @(input_1, input_2) 
    begin :IDLE_STATE_LOGIC
        if (current_state == Idle_State && enable == 1)
            begin
                next_state = Data_Pre_Layer;
            end
    end

always @ (posedge clk, negedge resetn)
    begin: STATE_MEMORY
        if (~resetn == 1)
            begin
                current_state <= Deactivated_State;
            end
        else
            begin
                current_state <= next_state;
            end
    end

always @ (current_state)
    begin: CALCULATE_OUTPUT
        if (current_state == Data_Post_Layer)
            begin
                op1_ALU1 = tempReg1;
                op2_ALU1 = readData1;
                alu_op_ALU[3:0] = 4'b0011;
                total_zero = zero_ALU[0];
                if (total_zero)
                    zero_fsm_state = current_state;
                if (ovf_ALU[0])
                    begin
                        total_ovf = 1;
                        ovf_fsm_state = current_state;
                        final_output = {32{1'b1}};
                    end
                else
                    begin
                        total_ovf = 0;
                        final_output = result_ALU1;         
                    end
            end
    end
endmodule