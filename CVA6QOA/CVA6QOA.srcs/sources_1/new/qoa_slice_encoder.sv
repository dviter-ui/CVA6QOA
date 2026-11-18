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
typedef enum {IDLE,IN_PROGRESS,FINISH} encoder_state_t;
encoder_state state_t;

logic slice;
lms_state_t lms;

s32_t slice_len = 20;
s32_t slice_start = 0;
s32_t slice_end = 19;
logic [63:0] best_rank = -1;
logic [63:0] current_rank;

logic [63:0] best_error;
logic [63:0] current_error;
slice_t best_slice;
slice_t slice;
logic [3:0] best_scalefactor = 0;
lms_state_t best_lms;

logic [4:0] scalefactor = 0;
logic [5:0] cnt_slice = 0;

always_ff @(posedge clk)begin
  case(state_t)
  IDLE : begin
    current_rank <= 0;
    slice<=cnt;
    lms <= lms_i;
    current_error <= 0;
    state_t <= IN_PROGRESS;
  end
  IN_PROGRESS : begin
  
  cnt_slice <= cnt_slice +1;
  if (cnt_slice == 19) state_t <= FINISH;
  

  end
  FINISH : begin
    if (current_rank<best_rank)begin
    best_rank <= current_rank;
    best_error <= current_error;
    best_slice <= slice;
    best_lms <= lms;
    best_scalefactor <= scalefactor;
    end
    current_rank <= 0;
    slice <=scalefactor;
    if (scalefactor == 15)begin
    done <= 1'b1;
    lms_o <= best_lms;
    best_sf_o <= best_scalefactor;
    slice_o <= best_slice;
    state_t <= IDLE;
    end
    
  end
  default : state_t <= IDLE;

  endcase

end
qoa_lms_predict franck (.lms_i(lms),.prediction_o(predicted));
qoa_div franck1 (.val_i(residual),.scalefactor_i(cnt),.val_o(scaled));

always_comb begin : blockName
  case (state_t)
  IN_PROGRESS : begin
    for(int i = 0; i<slice_len;i++)begin
      s16_t sample = samples[i];
      s32_t predicted; 
      s16_t residual = sample - predicted;
      s16_t scaled;
      
    end
  end
  default;
  endcase
end

endmodule : qoa_slice_encoder
