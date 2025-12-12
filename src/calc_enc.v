`timescale 1ns / 1ps
module alu_op_enc(
    output wire[3:0] alu_op,
    input wire btnl_enc,
    input wire btnr_enc,
    input wire btnd_enc
);

wire btnl_n, btnr_n, btnd_n; //NOT gates of inputs

not N1 (btnl_n, btnl_enc);
not N2 (btnr_n, btnr_enc);
not N3 (btnd_n, btnd_enc);

//alu_op[0] calculation
wire m01, mo2, mo3; // intermediate gate outputs for alu_op[0]
and A01 (mo1, btnl_enc, btnr_enc);
and A02 (mo2, btnl_n, btnd_enc);
and A03 (mo3, mo1, btnd_n);
or O01 (alu_op[0], mo2, mo3);

//alu_op[1] calculation
wire m11;
or O11 (m11, btnr_n, btnd_n);
and A11 (alu_op[1], m11, btnl_enc);

//alu_op[2] calculation
wire m21, m22, m22_n, m23;
and A21 (m21, btnl_n, btnr_enc);
xor XO21 (m22, btnr_enc, btnd_enc);
not N21 (m22_n, m22);
and A22 (m23, btnl_enc, m22_n);
or O21 (alu_op[2], m21, m23);

//alu_op[3] calculation
wire m31, m32;
and A31 (m31, btnl_enc, btnr_enc);
and A32 (m32, btnl_enc, btnd_enc);
or O31 (alu_op[3], m31, m32);

endmodule