`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 13:26:13
// Design Name: 
// Module Name: qoa_clamp
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


module qoa_clamp(
input s32_t val_i,
input s32_t min_i,
input s32_t max_i,
output s32_t val_o

    );
    always_comb begin
    if (val_i < min_i) val_o = min_i;
    else if (val_i>max_i) val_o = max_i;
    else val_o = val_i;
    end
endmodule
