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

section data
mask1  dq 0x0FFFFF0EFFFF0DFF, 0xFF0CFFFF0BFFFF0A					; pshufb |BGR|BGR|BGR|BGR|BGR|B|, mask1 -> |BBBBBB|00000|00000|
      
mask2  dq 0xFFFF09FFFF08FFFF				; pshufb |GR|BGR|BGR|BGR|BGR|BG|, mask2 -> |000000|BBBBB|00000|
mask2b dq 0x07FFFF06FFFF05FF				; 
	  
mask3  dq 0xFF04FFFF03FFFF02				; pshufb |R|BGR|BGR|BGR|BGR|BGR|, mask3 -> |000000|00000|BBBBB|
mask3b dq 0xFFFF01FFFF00FFFF

section .text

separar_canales_asm:
    convencion_c_in 0
    mov esi, src												; esi <- *src
    mov edi, dst_r												; edi <- *dst_r
    mov ebx, dst_g												; ebx <- *dst_g
    mov edx, dst_b												; edx <- *dst_b
            
	mov ecx, m													; ecx <- m	
	sar ecx, 4													; ecx <- m/16
	
	;crea mascaras
	pcmpeqb xmm1, xmm1											; xmm1 <- |FFFF....FFFF|
	
	
ciclo: 															;WHILE(ecx < m/16)
	;CARGA 16px del src
	movdqu xmm5, [esi]											; xmm5 <- *src      |BGR|BGR|BGR|BGR|BGR|B|
	movdqu xmm6, [esi+16]										; xmm6 <- *src+16	|GR|BGR|BGR|BGR|BGR|BG|
	movdqu xmm7, [esi+32]										; xmm7 <- *src+32	|R|BGR|BGR|BGR|BGR|BGR|											
    
    ;ORDENA BYTES
    movdqu xmm4, xmm5											; xmm4 <- *src      |BGR|BGR|BGR|BGR|BGR|B|
    ;pshufb xmm4, mask1											; xmm4 <-|BBBBBB|00000|00000|    mask1

    movdqu xmm3, xmm6											; xmm3 <- *src+16	|GR|BGR|BGR|BGR|BGR|BG|
    ;pshufb xmm3, mask2											; xmm3 <-|000000|BBBBB|00000|    mask2

	por xmm4, xmm3												; xmm4 <-|BBBBBB|BBBBB|00000|
	
	movdqu xmm3, xmm7											; xmm3 <- *src+32	|R|BGR|BGR|BGR|BGR|BGR|											
    ;pshufb xmm3, mask3											; xmm3 <-|000000|00000|BBBBB|    mask3

	por xmm4, xmm3												; xmm4 <-|BBBBBB|BBBBB|BBBBB|
	
    movdqu [edx], xmm4											; dst_b <- |BBBBBB|BBBBB|BBBBB|
    
    add esi, 48													; *src <- *src + 48
    add edi, 16													; *dst_r <- *dst_r + 16
    add ebx, 16													; *dst_g <- *dst_g + 16 
    add edx, 16													; *dst_b <- *dst_b + 16
    
																; ecx--
    loop ciclo													;ENDWHILE
    
    convencion_c_out 0
	ret
