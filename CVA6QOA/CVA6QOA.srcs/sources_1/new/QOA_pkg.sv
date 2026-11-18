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
  localparam logic [2:0] qoa_quant_tab [0:16] = 
  '{7, 7, 7, 5, 5, 3, 3, 1, /* -8..-1 */
      0,                      /*  0     */
      0, 2, 2, 4, 4, 6, 6, 6  /*  1.. 8 */};
  localparam logic [11:0] qoa_scalefactor_tab [0:15] = 
  '{
      1, 7, 21, 45, 84, 138, 211, 304, 421, 562, 731, 928, 1157, 1419, 1715, 2048
  };
  
  localparam shortint qoa_reciprocal_tab[0:15] = '{
      65536, 9363, 3121, 1457, 781, 475, 311, 216, 156, 117, 90, 71, 57, 47, 39, 32
  };
  
  localparam shortint signed qoa_dequant_tab[0:15][0:7] = '{
      '{   1,    -1,    3,    -3,    5,    -5,     7,     -7},
      '{   5,    -5,   18,   -18,   32,   -32,    49,    -49},
      '{  16,   -16,   53,   -53,   95,   -95,   147,   -147},
      '{  34,   -34,  113,  -113,  203,  -203,   315,   -315},
      '{  63,   -63,  210,  -210,  378,  -378,   588,   -588},
      '{ 104,  -104,  345,  -345,  621,  -621,   966,   -966},
      '{ 158,  -158,  528,  -528,  950,  -950,  1477,  -1477},
      '{ 228,  -228,  760,  -760, 1368, -1368,  2128,  -2128},
      '{ 316,  -316, 1053, -1053, 1895, -1895,  2947,  -2947},
      '{ 422,  -422, 1405, -1405, 2529, -2529,  3934,  -3934},
      '{ 548,  -548, 1828, -1828, 3290, -3290,  5117,  -5117},
      '{ 696,  -696, 2320, -2320, 4176, -4176,  6496,  -6496},
      '{ 868,  -868, 2893, -2893, 5207, -5207,  8099,  -8099},
      '{1064, -1064, 3548, -3548, 6386, -6386,  9933,  -9933},
      '{1286, -1286, 4288, -4288, 7718, -7718, 12005, -12005},
      '{1536, -1536, 5120, -5120, 9216, -9216, 14336, -14336}
  };
  

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
