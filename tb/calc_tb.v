`timescale 1ns / 1ps
module calc_tb();
    reg clk_tb;
    reg btnc_tb;
    reg btnac_tb;
    reg btnl_tb;
    reg btnr_tb;
    reg btnd_tb;
    reg[15:0] sw_tb;
    wire[15:0] led_tb;
    wire[3:0] alu_op_calc_tb;

calc DUT(
    .clk(clk_tb),
    .btnc(btnc_tb),
    .btnac(btnac_tb),
    .btnl(btnl_tb),
    .btnr(btnr_tb),
    .btnd(btnd_tb),
    .sw(sw_tb),
    .led(led_tb)
    //.alu_op_calc(alu_op_calc_tb)
);

    initial 
        begin
            clk_tb = 1'b0;
            btnac_tb = 1'b0;
        end
    
    always
        begin
            #1 clk_tb = ~clk_tb;
        end
    
    initial
        begin
            $dumpfile("calc.vcd");
            $dumpvars(0, calc_tb);
            #2 btnac_tb = 1'b1;
            #4 //Here we need 2 periods: 1 for the Accumulator to take the value and 1 to output it and the ALU ta take its output
            $display("Reset function, btnac=%b, accumulator=0x%h", btnac_tb, led_tb);
            btnac_tb = 1'b0; //Here we need it because at this posedge, alu_reslt changes so have to disable the FF
            btnc_tb = 1'b1; btnl_tb = 1'b0; btnr_tb = 1'b1; btnd_tb = 1'b0; sw_tb = 16'h285a;
            #2 btnc_tb = 1'b0;
            #2 // I have to await another period so that the output of the accumulator passes to the led
            $display("1)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b1; btnr_tb = 1'b1; btnd_tb = 1'b1; sw_tb = 16'h04c8;
            #2 btnc_tb = 1'b0;
            #2
            $display("2)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b0; btnr_tb = 1'b0; btnd_tb = 1'b0; sw_tb = 16'h0005;
            #2 btnc_tb = 1'b0;
            #2
            $display("3)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b1; btnr_tb = 1'b0; btnd_tb = 1'b1; sw_tb = 16'ha085;
            #2 btnc_tb = 1'b0;
            #2
            $display("4)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b1; btnr_tb = 1'b0; btnd_tb = 1'b0; sw_tb = 16'h07fe;
            #2 btnc_tb = 1'b0;
            #2
            $display("5)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b0; btnr_tb = 1'b0; btnd_tb = 1'b1; sw_tb = 16'h0004;
            #2 btnc_tb = 1'b0;
            #2
            $display("6)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b1; btnr_tb = 1'b1; btnd_tb = 1'b0; sw_tb = 16'hfa65;
            #2 btnc_tb = 1'b0;
            #2
            $display("7)Result=0x%h", led_tb);
            btnc_tb = 1'b1; btnl_tb = 1'b0; btnr_tb = 1'b1; btnd_tb = 1'b1; sw_tb = 16'hb2e4;
            #2 btnc_tb = 1'b0;
            #2
            $display("8)Result=0x%h", led_tb);
            #10
            $finish;
        end
endmodule