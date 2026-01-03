`timescale 1ns / 1ps
module test1_tb();
    reg signed [3:0] a_tb, b_tb;
    wire signed [7:0] y_tb;
    wire overflow_tb;

test1 DUT(
    .y(y_tb),
    .a(a_tb),
    .b(b_tb),
    .overflow(overflow_tb)
);
wire [3:0] WTF = 4'b1010;
wire [31:0] smth ={ {32{1'b1 & WTF[0]}} };


initial 
    begin
    $dumpfile("wave.vcd");
    $dumpvars(0, test1_tb);
    $display("WTF IS THIS %b", WTF[0]);
    /*a_tb = 0; b_tb = 0;
    #1
    $display("a=%b, b=%b, y=%b, ovf=%b", a_tb, b_tb, y_tb, ovf_tb);
    #9
    a_tb = 0; b_tb = 1;
    #1
    $display("a=%b, b=%b, y=%b, ovf=%b", a_tb, b_tb, y_tb, ovf_tb);
    #9
    a_tb = 1; b_tb = 0;
    #1
    $display("a=%b, b=%b, y=%b, ovf=%b", a_tb, b_tb, y_tb, ovf_tb);
    #9
    a_tb = 1; b_tb = 1;
    #1
    $display("a=%b, b=%b, y=%b, ovf=%b", a_tb, b_tb, y_tb, ovf_tb);
    #9*/
    $display("debug=%b", smth);
    a_tb = 4'd0010; b_tb = 4'd0010;//2 and 1
    #1
    $display("a=%d, b=%d, y=%d, overflow=%b", a_tb, b_tb, y_tb, overflow_tb);
    #9
    a_tb = ~a_tb +  1; b_tb = ~b_tb + 1;//-2 and -5
    #1
    $display("a=%d, b=%d, y=%d, overflow=%b", a_tb, b_tb, y_tb, overflow_tb);
    #9

    $finish;
    end
endmodule