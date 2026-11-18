`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 15:51:35
// Design Name: 
// Module Name: qoa_encode_frame
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


module qoa_slice_encoder
  import qoa_pkg::*;
(
  input  logic       clk,
  input  logic       rst_n,

  input  logic       start,
  input  s16_t       samples [0:SLICE_LEN-1],
  input  logic [4:0] slice_len,    // 1..20 (moins de 20 seulement pour la dernière slice)
  input  lms_state_t       lms_i,        // état LMS du canal (poids 32 bits)
  input  logic [3:0] prev_sf_i,

  output logic       done,
  output slice_t slice_o,      // déjà décalée si slice_len < 20
  output lms_state_t       lms_o,        // best_lms
  output logic [3:0] best_sf_o     // devient le prev_sf de la slice suivante
);
logic reg_rst_s;
logic write_reg_error_s, write_reg_sf_s;
logic [3:0] best_sf_s; 
logic [3:0] cnt_s;

s32_t best_error_s;
s32_t calculated_error_s;

register #(.bus_size(3)) best_sf (.clk_i(clk),.rst_i(rst_n),.data_i(cnt_s),.data_o(best_sf_s),.write_i(write_reg_sf_s));

register #(.bus_size(31)) best_error (.clk_i(clk),.rst_i(rst_n),.data_i(calculated_error_s),.data_o(best_error_s),.write_i(calculated_error_s));



always_ff @(posedge clk)begin

if (cnt_s <16)begin
cnt_s += 1;
for (int i = 0; i<slice_len;i++){

}
end
else begin
done <= 1'b1; 
best_sf_o <= best_sf_s;
end

end

endmodule 
