`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Glassmont
// Engineer: Silicondrift
// 
// Create Date: 09.11.2026 09:57:34
// Design Name :
// Module Name: qoa_lms_predict
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

module qoa_lms_predict
import qoa_pkg::*; (
input lms_state_t lms_i,
output int prediction_o
    );
    int sum1_s,sum2_s,sum3_s,sum4_s;
    assign sum1_s = lms_i.history[0] * lms_i.weights[0];
    assign sum2_s = lms_i.history[1] * lms_i.weights[1];
    assign sum3_s = lms_i.history[2] * lms_i.weights[2];
    assign sum4_s = lms_i.history[3] * lms_i.weights[3];
    assign prediction_o = (sum1_s + sum2_s + sum3_s + sum4_s) >>> 13;
    
    
    
endmodule
