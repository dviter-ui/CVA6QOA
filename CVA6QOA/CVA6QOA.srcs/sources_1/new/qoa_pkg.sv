`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.11.2026 09:06:30
// Design Name: 
// Module Name: QOA_pkg
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


package qoa_pkg;

  localparam int MAX_CHANNELS     = 8;
  localparam int SLICE_LEN        = 20;
  localparam int SLICES_PER_FRAME = 256;
  localparam int LMS_LEN          = 4;

  //Icarusverilog ne supporte pas les unpacked array, on les remplacent donc par une fonction.

  function automatic logic [2:0] qoa_quant(input int idx);
    case (idx)
      0, 1, 2 : return 3'd7;
      3, 4    : return 3'd5;
      5, 6    : return 3'd3;
      7       : return 3'd1;
      8, 9    : return 3'd0;
      10, 11  : return 3'd2;
      12, 13  : return 3'd4;
      default : return 3'd6;   // 14..16
    endcase
  endfunction

  function automatic logic [11:0] qoa_scalefactor(input logic [3:0] sf);
    case (sf)
      4'd0  : return 12'd1;
      4'd1  : return 12'd7;
      4'd2  : return 12'd21;
      4'd3  : return 12'd45;
      4'd4  : return 12'd84;
      4'd5  : return 12'd138;
      4'd6  : return 12'd211;
      4'd7  : return 12'd304;
      4'd8  : return 12'd421;
      4'd9  : return 12'd562;
      4'd10 : return 12'd731;
      4'd11 : return 12'd928;
      4'd12 : return 12'd1157;
      4'd13 : return 12'd1419;
      4'd14 : return 12'd1715;
      4'd15 : return 12'd2048;
    endcase
  endfunction

  function automatic int qoa_reciprocal(input logic [3:0] sf);
    case (sf)
      4'd0  : return 65536;
      4'd1  : return 9363;
      4'd2  : return 3121;
      4'd3  : return 1457;
      4'd4  : return 781;
      4'd5  : return 475;
      4'd6  : return 311;
      4'd7  : return 216;
      4'd8  : return 156;
      4'd9  : return 117;
      4'd10 : return 90;
      4'd11 : return 71;
      4'd12 : return 57;
      4'd13 : return 47;
      4'd14 : return 39;
      4'd15 : return 32;
    endcase
  endfunction

  // Chaque ligne de la table est faite de paires (+v, -v) : on stocke la
  // magnitude indexée par q[2:1] et on applique le signe avec q[0]
  function automatic shortint qoa_dequant(input logic [3:0] sf, input logic [2:0] q);
    shortint mag;
    case (sf)
      4'd0  : case (q[2:1]) 2'd0: mag =    1; 2'd1: mag =    3; 2'd2: mag =    5; default: mag =     7; endcase
      4'd1  : case (q[2:1]) 2'd0: mag =    5; 2'd1: mag =   18; 2'd2: mag =   32; default: mag =    49; endcase
      4'd2  : case (q[2:1]) 2'd0: mag =   16; 2'd1: mag =   53; 2'd2: mag =   95; default: mag =   147; endcase
      4'd3  : case (q[2:1]) 2'd0: mag =   34; 2'd1: mag =  113; 2'd2: mag =  203; default: mag =   315; endcase
      4'd4  : case (q[2:1]) 2'd0: mag =   63; 2'd1: mag =  210; 2'd2: mag =  378; default: mag =   588; endcase
      4'd5  : case (q[2:1]) 2'd0: mag =  104; 2'd1: mag =  345; 2'd2: mag =  621; default: mag =   966; endcase
      4'd6  : case (q[2:1]) 2'd0: mag =  158; 2'd1: mag =  528; 2'd2: mag =  950; default: mag =  1477; endcase
      4'd7  : case (q[2:1]) 2'd0: mag =  228; 2'd1: mag =  760; 2'd2: mag = 1368; default: mag =  2128; endcase
      4'd8  : case (q[2:1]) 2'd0: mag =  316; 2'd1: mag = 1053; 2'd2: mag = 1895; default: mag =  2947; endcase
      4'd9  : case (q[2:1]) 2'd0: mag =  422; 2'd1: mag = 1405; 2'd2: mag = 2529; default: mag =  3934; endcase
      4'd10 : case (q[2:1]) 2'd0: mag =  548; 2'd1: mag = 1828; 2'd2: mag = 3290; default: mag =  5117; endcase
      4'd11 : case (q[2:1]) 2'd0: mag =  696; 2'd1: mag = 2320; 2'd2: mag = 4176; default: mag =  6496; endcase
      4'd12 : case (q[2:1]) 2'd0: mag =  868; 2'd1: mag = 2893; 2'd2: mag = 5207; default: mag =  8099; endcase
      4'd13 : case (q[2:1]) 2'd0: mag = 1064; 2'd1: mag = 3548; 2'd2: mag = 6386; default: mag =  9933; endcase
      4'd14 : case (q[2:1]) 2'd0: mag = 1286; 2'd1: mag = 4288; 2'd2: mag = 7718; default: mag = 12005; endcase
      4'd15 : case (q[2:1]) 2'd0: mag = 1536; 2'd1: mag = 5120; 2'd2: mag = 9216; default: mag = 14336; endcase
    endcase
    return q[0] ? -mag : mag;
  endfunction
  

  typedef logic signed [15:0] s16_t;   // élément signé : history[i] reste signé
  typedef logic signed [31:0] s32_t;
  typedef logic signed [63:0] s64_t;

  // 64 bits
  typedef struct packed {
    logic [31:0] magic;      // "qoaf" = 32'h716F6166
    logic [31:0] samples;    // échantillons par canal, sur tout le fichier
  } file_header_t;

  // 64 bits
  typedef struct packed {
    logic [7:0]  num_channels;
    logic [23:0] samplerate;
    logic [15:0] fsamples;   // échantillons par canal dans cette frame
    logic [15:0] fsize;      // taille de la frame en octets
  } frame_header_t;

  // 128 bits, un par canal
  typedef struct packed {
    s16_t [0:LMS_LEN-1] history;
    s32_t [0:LMS_LEN-1] weights;
  } lms_state_t;

  // 64 bits
  typedef struct packed {
    logic [3:0]                sf_quant;
    logic [0:SLICE_LEN-1][2:0] qr;   // qr[0] = premier résidu (poids fort)
  } slice_t;

endpackage : qoa_pkg
