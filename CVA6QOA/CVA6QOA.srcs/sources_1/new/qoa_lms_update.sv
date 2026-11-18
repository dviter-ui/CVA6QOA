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
    lms_state_t lms_s;
    assign delta_s = residual_i >>>4;
    
    always_comb begin
    for (int i = 0; i<4; i++) 
    lms_s.weights[i] = lms_i.weights[i] + ((lms_i.history[i]<0) ? -delta_s : delta_s);
    
    for (int i = 0 ; i<3; i++)
    lms_s.history[i] = lms_i.history[i+1];
    lms_s.history[3] = sample_i;
    end
    
    assign lms_o = lms_s;
    
    

    
endmodule
