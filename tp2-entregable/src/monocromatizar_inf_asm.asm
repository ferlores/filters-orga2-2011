; void monocromatizar_inf_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_inf_asm

section .text

monocromatizar_inf_asm:


%include "macros.asm"
convencion_c_in 0

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX



;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   

	mov esi, src		                            ; esi <- *src
	mov edi, dst		                            ; edi <- dst
	mov ecx, h                                      ; ecx <- h
    ;----------------------------------
    ; esi <- *src
    ; edi <- dst
    ; ecx <- h
    ; ebx <- #columnas_procesada
    ;----------------------------------

    
cicloFila:                                          ; WHILE(h!=0) DO
	xor ebx,ebx                                     ;     #columnas_p <- 0    
	cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA ITERAR AQUI!


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		movdqu xmm0, [esi+ebx]
		
		movdqu xmm1, xmm0  	;  
		movdqu xmm2, xmm0   ; xmm0 =     B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
		
		pslldq	xmm1, 1  	;xmm1  =     G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0
		pslldq  xmm2, 2  	; xmm2 = 	 R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 |0 
		
		pmaxub xmm0,xmm1	; xmm0 =     max{B0,GO,R0)}|G0|R0|max{B1,G1,R1}|--|--|max ...|G2|R2|max..|G3|R3|max..|G4|R4|B5
		pmaxub xmm0, xmm2 
		
		pxor xmm3, xmm3
		punpcklbw xmm3, xmm0	;  xmm3 =     0 m1 | 0 x | 0 x | 0 m2  |0 x  | 0 x | 0 m3 | 0 x
		pxor xmm4, xmm4
		pxor xmm4, xmm0
		punpckhbw xmm4, xmm0    ;  xmm4 =       0 x | 0 m4 | 0 x | 0 x  |0 m5  | 0 x | 0 x | 0 m6
		
		pshuflw xmm3, xmm3, 11101100b  ;  xmm3 =     0 m1 | 0m2 | 0 x | 0 m2  |0 x  | 0 x | 0 m3 | 0 x
		pshufhw xmm3, xmm3, 11100110b  ;  xmm3 =     0 m1 | 0m2 | 0 x | 0 m2  |0 m3  | 0 x | 0 m3 | 0 x
		
		pshufd  xmm3, xmm3, 11101000b   ;   xmm3 =    
		
		packuswb xmm3, xmm3  			;  xmm3 =    0 | m1 | 0| m2 | 0|  x | 0 | m2 | 0 |  m3  |0|  x |0|  m3  | 0|  x 
		
			
		
		

		movdqu [edi+ebx],xmm0
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add ebx ,16                                 ;        #columnas_p <- #columnas_p + 16
		mov eax, row_size                           ;        eax <- row_size
		sub eax, ebx                                ;        eax <- row_size - #columnas_p
        
		cmp eax, 16                                 ;        IF (row_size - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
        cmp eax,0                                   ;        IF (row_size - #columnas_p)
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        mov ebx, row_size                           ;        ebx <- row_size
        sub ebx,17                                  ;        ebx <- row_size - 17
        jmp cicloColumna                            ;      ENDWHILE
	
    termineCol:
		
		add esi,row_size                            ;   src <- src + row_size
		add edi,row_size                            ;   dst <- dst + row_size
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 0
	
