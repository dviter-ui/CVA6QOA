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


module register #(int WIDTH = 4)(
    input  logic             rst_i,    // reset asynchrone, actif bas
    input  logic             clk_i,
    input  logic             write_i,
    input  logic [WIDTH-1:0] data_i,
    output logic [WIDTH-1:0] data_o);

logic [WIDTH-1:0] data_s;

always_ff @(posedge clk_i, negedge rst_i) begin
  if (!rst_i)       data_s <= '0;
  else if (write_i) data_s <= data_i;
end

assign data_o = data_s;

endmodule
