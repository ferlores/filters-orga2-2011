; void separar_canales_asm (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size)

global separar_canales_asm

%include "macros.asm"

%define dst_r [ebp+12]
%define dst_g [ebp+16]
%define dst_b [ebp+20]
%define h [ebp+24]
%define w [ebp+28]
%define src_row_size [ebp+32]
%define dst_row_size [ebp+36]


section .text

separar_canales_asm:
	convencion_c_in 0

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	pxor xmm7, xmm7									; xmm7 <- |00...00|
	mov ecx, 0xFFFFFFFF								; ecx <- 0
	pinsrw xmm7, ecx, 0								
	pinsrw xmm7, ecx, 3
	pinsrw xmm7, ecx, 6								; xmm7 <- |00|FF|00|00|FF|00|00|FF|

	; xmm7 <- mascara_B
	
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   

	mov esi, src		                            ; esi <- *src
	mov edi, dst_b		                            ; edi <- dst
	mov ecx, h                                      ; ecx <- h
    ;----------------------------------
    ; esi <- *src
    ; edi <- dst
    ; ecx <- h
    ; ebx <- #columnas_procesada_src
    ; edx <- #columnas_procesada_dst    
    ;----------------------------------

    
cicloFila:                                          ; WHILE(h!=0) DO
	xor ebx, ebx                                    ;     #columnas_p_src <- 0    
	xor edx, edx                                    ;     #columnas_p_dst <- 0    
	cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA ITERAR AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

		movdqu xmm0, [esi+ebx]						; xmm0 <- src 

carga_distinto_ultima_columna:
		;-----------------
		; Proceso B
		;-----------------
		movdqu xmm1, xmm0							; xmm1 <- |BG|RB|GR|BG|RB|GR|BG|RB|
		
		psllw xmm1, 8					 			; 
		psrlw xmm1, 8					 			; xmm1 <- |xx|0B|xx|xx|0B|xx|xx|0B|
		psrlw xmm0, 8					 			; xmm0 <- |0B|xx|xx|0B|xx|xx|0B|xx|
		
		
													; xmm7 <- |00|FF|00|00|FF|00|00|FF| mascara actual
		pand xmm1, xmm7								; xmm1 <- |00|0B|00|00|0B|00|00|0B|
		
		pslldq xmm7, 1								; xmm7 <- |FF|00|00|FF|00|00|FF|00| ajusto mascara
		pand xmm0, xmm7								; xmm0 <- |0B|00|00|0B|00|00|0B|00|

		psrldq xmm7, 1								; xmm7 <- |00|FF|00|00|FF|00|00|FF| retorno mascara
	
		
		; xmm0 <- |0B|00|00|0B|00|00|0B|00|
		; xmm1 <- |00|0B|00|00|0B|00|00|0B|
		por xmm0, xmm1								; xmm0 <- |B1|B2|00|B3|B4|00|B5|B6|
		
		pshufd xmm0, xmm0, 11000110b				; xmm0 <- |B1|B2|B5|B6|B4|00|00|B3|
		pshuflw xmm0, xmm0, 00110110b    			; xmm0 <- |B1|B2|B5|B6|B3|B4|00|00|
		pshufd xmm0, xmm0, 11011000b				; xmm0 <- |B1|B2|B3|B4|B5|B6|00|00| (word-packed)
		
		packuswb xmm0, xmm0							; xmm0 <- |B1|B2|B3|B4|B5|B6|0|0|B1|B2|B3|B4|B5|B6|0|0| (byte-packed)
		
		psrldq xmm0, 4								; xmm0 <- |0|0|0|0|B1|B2|B3|B4|B5|B6|0|0|B1|B2|B3|B4| (byte-packed)	
		movd eax, xmm0								; eax <- |B1|B2|B3|B4|

		;~ movdqu [edi+edx],xmm0
		mov dword [edi+edx], eax 						
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add edx ,4                                  ;        #columnas_p_dst <- #columnas_p_dst + 4
		add ebx ,12                                 ;        #columnas_p_src <- #columnas_p_src + 12
		mov eax, src_row_size                       ;        eax <- row_size_src
		sub eax, ebx                                ;        eax <- row_size - #columnas_p_src
        
		cmp eax, 16                                 ;        IF (row_size - #columnas_p_src) < 16
		jge cicloColumna                            ;          CONTINUE
		
        cmp eax, 5                                   ;        IF (row_size - #columnas_p_src) == 0
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        mov ebx, src_row_size                       ;        ebx <- src_row_size
        sub ebx,17                                  ;        ebx <- src_row_size - 13

		
		
        mov edx, dst_row_size                       ;        edx <- dst_row_size
        sub edx,5                                   ;        edx <- dst_row_size - 5

		movdqu xmm0, [esi+ebx]						;        xmm0 <- ultimos_16b(src) |RB|GR|BG|RB|GR|BG|RB|GR|
		pslldq xmm0, 4								
		
        jmp carga_distinto_ultima_columna           ;      ENDWHILE

	
    termineCol:
		
		add esi, src_row_size                       ;   src <- src + row_size
		add edi, dst_row_size                       ;   dst <- dst + row_size
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 0
	ret

