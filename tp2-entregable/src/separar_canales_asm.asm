; void separar_canales_asm (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size)

global separar_canales_asm


%include "macros.asm"

section .text

separar_canales_asm:
    convencion_c_in 0
    
    
    
    
    convencion_c_out 0
	ret
