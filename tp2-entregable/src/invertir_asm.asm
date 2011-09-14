; void invertir_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)


global invertir_asm

%include "macros.asm"

%define src [ebp+8]
%define dst [ebp+12]
%define alto [ebp+16]
%define ancho [ebp+20]
%define RZ [ebp+24]
section .text

invertir_asm:
	convencion_c_in 0
	
  ; mov esi, src
  ; mov edi, dst
  ; xor edx,edx

;cicloFila:
  ; xor ecx,ecx
 ;  mov eax, ALTO
  ; cmp edi, eax
	
  ; cicloColumna:
	 ;  mov eax, RZ
		



	convencion_c_out 0
	ret
