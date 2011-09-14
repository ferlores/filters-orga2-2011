; void separar_canales_asm (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size)
%define dst_r [ebp+12]
%define dst_g [ebp+16]
%define dst_b [ebp+20]
%define m [ebp+24]
%define n [ebp+28]
%define src_row_size [ebp+32]
%define dst_row_size [ebp+36]

global separar_canales_asm


%include "macros.asm"

section .text

separar_canales_asm:
    convencion_c_in 0
    
    
    
    
    convencion_c_out 0
	ret
