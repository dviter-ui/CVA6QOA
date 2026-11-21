`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 10:24:36
// Design Name: 
// Module Name: qoa_lms_update
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

module qoa_lms_update import qoa_pkg::*;
(
input int sample_i,
input int residual_i,
input lms_state_t lms_i,
output lms_state_t lms_o
    );
    s32_t delta_s;
    assign delta_s = residual_i >>>4;
    //Ne pas utiliser une boucle for dans un always_comb, Icarusverilog plante sinon
    for (genvar i = 0; i<4; i++) begin : g_weights
    assign lms_o.weights[i] = lms_i.weights[i] + ((lms_i.history[i]<0) ? -delta_s : delta_s);
    end
    assign lms_o.history = {lms_i.history[1], lms_i.history[2], lms_i.history[3], s16_t'(sample_i)};
endmodule
