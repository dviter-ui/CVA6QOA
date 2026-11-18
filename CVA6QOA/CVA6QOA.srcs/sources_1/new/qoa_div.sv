`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 11:27:43
// Design Name: 
// Module Name: qoa_div
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module qoa_div import qoa_pkg::*;
(
input s32_t val_i,
input [3:0] scalefactor_i,
output s32_t val_o
    );
    s64_t prod_s;
    s32_t val_s;
    // produit sur 64 bits pour éviter tout débordement avant le décalage
    assign prod_s = s64_t'(val_i) * s64_t'(qoa_reciprocal_tab[scalefactor_i]);
    assign val_s  = s32_t'((prod_s + (s64_t'(1) <<< 15)) >>> 16);
    // arrondi en s'éloignant de 0 : n + sign(v) - sign(n)
    assign val_o = val_s + (s32_t'(val_i > 0) - s32_t'(val_i < 0))
                         - (s32_t'(val_s > 0) - s32_t'(val_s < 0));
endmodule
