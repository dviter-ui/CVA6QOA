package wav_pkg;

  // Identifiants de chunks, dans l'ordre des octets du fichier
  localparam logic [31:0] ID_RIFF = "RIFF";
  localparam logic [31:0] ID_WAVE = "WAVE";
  localparam logic [31:0] ID_FMT  = "fmt ";
  localparam logic [31:0] ID_DATA = "data";

  localparam logic [15:0] FORMAT_PCM        = 16'h0001;
  localparam logic [15:0] FORMAT_EXTENSIBLE = 16'hFFFE;

  // En-tête générique de chunk : 8 octets
  typedef struct packed {
    logic [31:0] id;        // déjà dans le bon ordre (caractères)
    logic [31:0] size_le;   // taille du corps, little endian
  } chunk_header_t;

  // En-tête RIFF : 12 octets
  typedef struct packed {
    chunk_header_t header;  // id = "RIFF"
    logic [31:0]   format;  // "WAVE"
  } riff_header_t;

  // Corps du chunk "fmt " en PCM : 16 octets
  typedef struct packed {
    logic [15:0] audio_format_le;     // 1 = PCM
    logic [15:0] num_channels_le;
    logic [31:0] sample_rate_le;
    logic [31:0] byte_rate_le;        // sample_rate * block_align
    logic [15:0] block_align_le;      // num_channels * bits_per_sample / 8
    logic [15:0] bits_per_sample_le;
  } fmt_pcm_t;

  // Échantillon PCM 16 bits (signé ; attention, le PCM 8 bits est non signé)
  typedef logic signed [15:0] pcm16_t;

  // Conversion little endian -> valeur
  function automatic logic [15:0] le16(input logic [15:0] x);
    return {x[7:0], x[15:8]};
  endfunction

  function automatic logic [31:0] le32(input logic [31:0] x);
    return {x[7:0], x[15:8], x[23:16], x[31:24]};
  endfunction

endpackage : wav_package