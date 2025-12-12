`timescale 1ns / 1ps
module test1 (
    input wire signed [3:0] a,
    input wire signed [3:0] b,
    output wire signed [7:0] y,
    output wire overflow
);
  //wire ovf;
  //wire signed [7:0] a_signed = a;
  //wire signed [7:0] b_signed = b;
  //assign a_signed = a;
  //assign b_signed = b;
  wire [3:0] low_MSB;
  assign y = a * b;
  assign low_MSB = y[3] ? 4'b1111 : 4'b0000;
  assign overflow = |(y[7:4] ^ low_MSB);
endmodule