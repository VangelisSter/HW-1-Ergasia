`timescale 1ns / 1ps
module tb_nn();
    parameter DATAWIDTH = 32;
    reg signed[31:0] input_1_tb;
    reg signed[31:0] input_2_tb;
    reg clk_tb;
    reg resetn_tb;
    reg enable_tb;
    wire signed[31:0] final_output_tb;
    wire total_ovf_tb;
    wire total_zero_tb;
    wire [2:0] ovf_fsm_state_tb;
    wire [2:0] zero_fsm_state_tb;
    reg signed[31:0] nn_model_output;
    reg [2:0] count;
    reg [7:0] iteration;
    reg [15:0] passed_count, failed_count;

NN DUT(
    .input_1(input_1_tb),
    .input_2(input_2_tb),
    .clk(clk_tb),
    .resetn(resetn_tb),
    .enable(enable_tb),
    .final_output(final_output_tb),
    .total_ovf(total_ovf_tb),
    .total_zero(total_zero_tb),
    .ovf_fsm_state(ovf_fsm_state_tb),
    .zero_fsm_state(zero_fsm_state_tb)
);

`include "nn_model.v"

parameter signed [31:0] MAX_POS =  2147483647;
parameter signed [31:0] MIN_NEG = -2147483648;

initial
    begin
        clk_tb = 0;
        resetn_tb = 0;
        enable_tb = 0;
        count = 0;
        iteration = 0;
        passed_count = 0;
        failed_count = 0;
        $timeformat(-9, 2, " ns", 20);
        $dumpfile("nn.vcd");
        $dumpvars(0, tb_nn);
        input_1_tb = 0;
        input_2_tb = 0;
        #10
        resetn_tb = 1;
        enable_tb = 1;

    end

always 
    begin
        #5 clk_tb = ~clk_tb; //10ns clock period with 50% duty cycle
    end

always @(final_output_tb) begin
    if (final_output_tb == nn_model_output)
        begin
            $display("Passed");
            passed_count = passed_count + 1;
        end
    else
        begin
            failed_count = failed_count + 1;
            $display("Failed");
            $display("My nn output: %d", final_output_tb);
            $display("nn_model output: %d", nn_model_output);
            $display("======================");
        end
    if (iteration <= 100)
        begin
            $display("Iteration #: %d", iteration);
            $display("Starts at: %0t", $realtime);
            case (count)
                0: begin
                    input_1_tb = $urandom_range(8191, 0) - 4096;
                    input_2_tb = $urandom_range(8191, 0) - 4096;
                    $display("Case 1 (Small): A=%d, B=%d", input_1_tb, input_2_tb);
                    count = 1;
                end
                1: begin
                    input_1_tb = $urandom_range(MAX_POS, MAX_POS / 2);
                    input_2_tb = $urandom_range(MAX_POS, MAX_POS / 2);
                    $display("Case 2 (Pos Ovf): A=%d, B=%d", input_1_tb, input_2_tb);
                    count = 2;
                end
                2: begin
                    input_1_tb = -1 * $urandom_range(2147483647, 1073741824);
                    input_2_tb = -1 * $urandom_range(2147483647, 1073741824);
                    $display("Case 3 (Neg Ovf): A=%d, B=%d", input_1_tb, input_2_tb);  
                    count = 0;
                end
            endcase
        iteration = iteration + 1;
        nn_model_output = nn_model(input_1_tb, input_2_tb);
        end
    else
        begin
            $display("Passed: %d", passed_count);
            $display("Failed: %d", failed_count);
            $finish;
        end
end
initial begin
    #100000;
    $display("Error: Timeout - Output never received!");
    $finish;
end
endmodule