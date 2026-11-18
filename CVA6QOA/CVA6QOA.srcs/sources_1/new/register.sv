`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.11.2026 13:41:41
// Design Name: 
// Module Name: register
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


module register#(int bus_size = 3)(
    input logic rst_i,
    input logic clk_i,
    input logic write_i,
    input logic [bus_size:0] data_i,
    output logic [bus_size:0] data_o);

logic [bus_size:0] data_s;

always_ff @(posedge clk_i, negedge rst_i )begin
if (rst_i == 1) data_s <= 1'b0000;
else begin
if (write_i) data_s <= data_i;
else data_o <= data_s;
end
end

endmodule
