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


    movdqu xmm6, xmm7                               ; xmm6 <- |00|FF|00|00|FF|00|00|FF|
    psrldq xmm6, 2	                                ; xmm6 <- |00|00|FF|00|00|FF|00|00|
    
	; xmm7 <- mascara_B
	; xmm <- mascara_G
	
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   

	mov esi, src		                            ; esi <- *src
	
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
		; Prepara los datos
		;-----------------
        
		movdqu xmm1, xmm0							; xmm1 <- |BR|GB|RG|BR|GB|RG|BR|GB|
		
		psllw xmm1, 8					 			; 
		psrlw xmm1, 8					 			; xmm1 <- |0R|0B|0G|0R|0B|0G|0R|0B|
		psrlw xmm0, 8					 			; xmm0 <- |0B|0G|0R|0B|0G|0R|0B|0G|
		
        ; GUARDO LOS REGISTROS
        movdqu xmm3, xmm1							; xmm3 <- |0R|0B|0G|0R|0B|0G|0R|0B|
        movdqu xmm2, xmm0							; xmm2 <- |0B|0G|0R|0B|0G|0R|0B|0G|
        
		;-----------------
		; Proceso B
		;-----------------        
        mov edi, dst_b		                        ; edi <- dst_b
        
                                                    ; xmm7 <- |00|FF|00|00|FF|00|00|FF|
		pand xmm1, xmm7								; xmm1 <- |00|0B|00|00|0B|00|00|0B|
		
		pslldq xmm7, 1								; xmm7 <- |FF|00|00|FF|00|00|FF|00| ajusto mascara
		pand xmm0, xmm7								; xmm0 <- |0B|00|00|0B|00|00|0B|00|

        
		
		; xmm0 <- |0B|00|00|0B|00|00|0B|00|
		; xmm1 <- |00|0B|00|00|0B|00|00|0B|
		por xmm0, xmm1								; xmm0 <- |B6|B5|00|B4|B3|00|B2|B1|
		
		pshufd xmm0, xmm0, 11000110b				; xmm0 <- |B6|B5|B2|B1|B3|00|00|B4|
		pshuflw xmm0, xmm0, 00110110b   			; xmm0 <- |B6|B5|B2|B1|B4|B3|00|00|
		pshufd xmm0, xmm0, 11011000b				; xmm0 <- |B6|B5|B4|B3|B2|B1|00|00| (word-packed)
		
		packuswb xmm0, xmm0							; xmm0 <- |B6|B5|B4|B3|B2|B1|0|0|B6|B5|B4|B3|B2|B1|0|0| (byte-packed)
		
		psrldq xmm0, 2								; xmm0 <- |0|0|B6|B5|B4|B3|B2|B1|0|0|B6|B5|B4|B3|B2|B1| (byte-packed)	
		movd eax, xmm0								; eax <- |B4|B3|B2|B1|

		mov [edi+edx], eax 						

        ;-----------------
		; Proceso R
		;-----------------        
        mov edi, dst_r		                        ; edi <- dst_b

        movdqu xmm1, xmm3							; xmm3 <- |0R|0B|0G|0R|0B|0G|0R|0B|
        movdqu xmm0, xmm2							; xmm2 <- |0B|0G|0R|0B|0G|0R|0B|0G|
        
                                                    ; xmm7 <- |FF|00|00|FF|00|00|FF|00|
		pand xmm1, xmm7								; xmm1 <- |0R|00|00|0R|00|00|0R|00|
		
                                                    ; xmm6 <- |00|00|FF|00|00|FF|00|00|
		pand xmm0, xmm6								; xmm0 <- |00|00|0R|00|00|0R|00|00|

		
        ; xmm0 <- |00|00|0R|00|00|0R|00|00|
        ; xmm1 <- |0R|00|00|0R|00|00|0R|00|
		por xmm0, xmm1								; xmm0 <- |R5|00|R4|R3|00|R2|R1|00|
		
        pshuflw xmm0, xmm0, 11001001b   			; xmm0 <- |R5|00|R4|R3|00|00|R2|R1|
		pshufd xmm0, xmm0, 11011000b				; xmm0 <- |R5|00|00|00|R4|R3|R2|R1|

		packuswb xmm0, xmm0							; xmm0 <- |R5|0|0|0|R4|R3|R2|R1|R5|0|0|0|R4|R3|R2|R1| (byte-packed)
		
		movd eax, xmm0								; eax <- |R4|R3|R2|R1|

		mov [edi+edx], eax 						
        

        ;-----------------
		; Proceso G
		;-----------------        
        psrldq xmm7, 1								; xmm7 <- |00|FF|00|00|FF|00|00|FF| retorno mascara        
        
        mov edi, dst_g		                        ; edi <- dst_b

		pand xmm2, xmm7								; xmm0 <- |00|0G|00|00|0G|00|00|0G|
		
                                                    ; xmm6 <- |00|00|FF|00|00|FF|00|00|
		pand xmm3, xmm6								; xmm1 <- |00|00|0G|00|00|0G|00|00|

		
        ; xmm0 <- |00|0G|00|00|0G|00|00|0G|
        ; xmm1 <- |00|00|0G|00|00|0G|00|00|
		por xmm2, xmm3								; xmm0 <- |00|G5|G4|00|G3|G2|00|G1|
		
        pshuflw xmm2, xmm2, 01111000b   			; xmm0 <- |00|G5|G4|00|00|G3|G2|G1|
		pshufd xmm2, xmm2, 01101100b				; xmm0 <- |00|G3|G4|00|00|G5|G2|G1|
        pshufhw xmm2, xmm2, 11000110b   			; xmm0 <- |00|00|G4|G3|00|G5|G2|G1|
        pshufd xmm2, xmm2, 11011000b				; xmm0 <- |00|00|00|G5|G4|G3|G2|G1|

		packuswb xmm2, xmm2							; xmm0 <- |00|00|00|G5|G4|G3|G2|G1|00|00|00|G5|G4|G3|G2|G1| (byte-packed)
		
		movd eax, xmm2								; eax <- |G4|G3|G2|G1|

		mov [edi+edx], eax 						
        
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add edx ,4                                  ;        #columnas_p_dst <- #columnas_p_dst + 4
		add ebx ,12                                 ;        #columnas_p_src <- #columnas_p_src + 12
		
		mov eax, w			                        ;        eax <- w
		lea eax, [eax + 2*eax]						;        eax <- 3*w
		
		sub eax, ebx                                ;        eax <- 3*w - #columnas_p_src
        
		cmp eax, 16                                 ;        IF (3*w - #columnas_p_src) < 16
		jge cicloColumna                            ;          CONTINUE
		
        cmp eax, 4                                  ;        IF (3*w - #columnas_p_src) == 0
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        add ebx, eax		                        ;        ebx <- 3*w
        sub ebx,16                                  ;        ebx <- 3*w - 17

		
        mov edx, w			                        ;        edx <- dst_row_size
        sub edx,4                                   ;        edx <- dst_row_size - 4

		movdqu xmm0, [esi+ebx]						;        xmm0 <- ultimos_16b(src) |RB|GR   |BG|RB|GR|BG|RB|GR|
		psrldq xmm0, 4								
		
        jmp carga_distinto_ultima_columna           ;      ENDWHILE

	
    termineCol:
		
		add esi, src_row_size                       ;   src <- src + src_row_size
        
        mov edi, dst_row_size
		add dst_b, edi           	                ;   dst_b <- dst + dst_row_size
        add dst_g, edi 	                            ;   dst_g <- dst + dst_row_size
        add dst_r, edi       	                    ;   dst_r <- dst + dst_row_size
        
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 0
	ret

