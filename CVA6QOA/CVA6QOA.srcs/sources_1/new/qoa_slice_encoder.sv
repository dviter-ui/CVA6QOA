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

//Signaux combinatoires

s32_t sample, predicted, residual, scaled, clamped, quantized, dequantized;
logic signed [63:0] weights_penalty_tmp, weights_penalty;
s32_t reconstructed;
logic [127:0] error;
logic [63:0] error_sq;

//Registres

lms_state_t lms;
lms_state_t best_lms;
lms_state_t lms_next;
logic [3:0] scalefactor;
logic [5:0] sample_index;
slice_t best_slice;
slice_t slice;
logic [63:0] best_error;
logic [63:0] best_rank;
logic [3:0] best_scalefactor;
logic [63:0] current_rank;
logic [63:0] current_error;



typedef enum {IDLE,IN_PROGRESS,FINISH} encoder_state_t;
encoder_state_t state;
//FSM
always_ff @( posedge clk ) begin : FSM
  case(state)
  IDLE : begin
  best_error <= 1000000;
  best_rank <= '1;
  best_slice <= 0;
  best_scalefactor <= 0;
  scalefactor <=0;
  sample_index<=0;
  current_rank  <= 0;
  current_error <= 0;
  slice         <= 0;
  done          <= 0;
  lms <= lms_i;
  if (start) state <= IN_PROGRESS;
  end
  IN_PROGRESS :begin
  current_rank <= current_rank + error_sq + weights_penalty * weights_penalty;
  current_error <= current_error + error_sq;

  slice <= (slice << 3) | quantized;
  if (current_rank > best_rank) state <=FINISH;
  if (sample_index == 5'd19) state <= FINISH;
  lms <= lms_next;
  sample_index<= sample_index+1;
  end
  FINISH : begin
  if (current_rank<best_rank)begin
  best_rank <= current_rank;
  best_error <= current_error;
  best_slice <= slice;
  best_lms <= lms;
  best_scalefactor<=scalefactor;
  end
  slice <= 64'(scalefactor + 4'd1);
  lms <= lms_i;
  sample_index <=0;
  if (scalefactor == 15) begin 
  state <= IDLE;
  done <= 1'b1;
  slice_o <= (current_rank < best_rank) ? slice : best_slice;
  best_sf_o <= (current_rank < best_rank) ? scalefactor : best_scalefactor;
  lms_o <= (current_rank < best_rank) ? lms : best_lms;
  end
  else state <= IN_PROGRESS;
  current_error <= 0;
  current_rank <= 0;
  scalefactor<= scalefactor + 1;
  end
  default : state <= IDLE;
  endcase
end

//Bloc combinatoire

assign sample = samples[sample_index];
qoa_lms_predict u_predict (.lms_i(lms),.prediction_o(predicted));
assign residual = sample - predicted;
qoa_div u_qoadiv (.scalefactor_i(scalefactor),.val_i(residual),.val_o(scaled));
qoa_clamp u_qoaclamp (.val_i(scaled),.val_o(clamped),.min_i(-8),.max_i(8));
assign quantized = qoa_quant_tab[clamped + 8];
assign dequantized = qoa_dequant_tab[scalefactor][quantized];
qoa_clamp u_qoaclamp16 (.val_i(dequantized+predicted),.val_o(reconstructed),.min_i(-32768),.max_i(32767));
assign weights_penalty_tmp = ((lms.weights[0] * lms.weights[0] + lms.weights[1] 
* lms.weights[1] + lms.weights[2] 
* lms.weights[2] + lms.weights[3] * lms.weights[3]) >>>18) - 32'sh8ff;
assign weights_penalty = (weights_penalty_tmp>=0) ? weights_penalty_tmp : 0;
assign error = (sample - reconstructed);
assign error_sq = (error * error);
qoa_lms_update u_upd (.sample_i(reconstructed), .residual_i(dequantized), .lms_i(lms), .lms_o(lms_next));



endmodule : qoa_slice_encoder
