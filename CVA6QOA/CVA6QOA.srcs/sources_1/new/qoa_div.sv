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

import qoa_pkg::*;
module qoa_div(
input s16_t val_i,
input [3:0] scalefactor_i,
output s16_t val_o
    );
    s16_t val_s;
    assign val_s = 
    (val_i * qoa_reciprocal_tab[scalefactor_i] + (1 <<< 15)) >>> 16;
    assign val_o = val_s + ((val_i > 0) - (val_i < 0)) - ((val_s > 0 ) - (val_s < 0));
endmodule
