; void monocromatizar_inf_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_inf_asm

section .text

monocromatizar_inf_asm:


%include "macros.asm"
convencion_c_in 0

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;mask : 		dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000 no funciono pero podria haber funcionado con los movs adecuados probemos mejor por la idea de fer
pxor xmm7, xmm7									
	mov ecx, 0xFF000000								
	pinsrw xmm7, ecx, 0								
	pinsrw xmm7, ecx, 3
	pinsrw xmm7, ecx, 6								; xmm7 <- |FF|00|00|FF|00|00|FF|00

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
		movdqu xmm2, xmm0   ; xmm0 <-     B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
		
		pslldq	xmm1, 1  	;xmm1  <-     G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0
		pslldq  xmm2, 2  	; xmm2 <- 	 R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 |0 
		
		pmaxub xmm0,xmm1	
		pmaxub xmm0, xmm2   ; xmm0 <-   max{B0,GO,R0)}|G0|R0|max{B1,G1,R1}|--|--|max ...|G2|R2|max..|G3|R3|max..|G4|R4|B5
		
		movdqu xmm1, xmm0    ; lo copio porque lo voy a usar despues pero por ahora me olvido
		
		psrlw xmm1,8   ; xmm1 <-  0 m0 |0 x| 0 x | 0 m2 | 0 x | 0 x | 0 m4 |0 x  shiftee cada word 8 bits logico a derecha
		
		movdqu xmm2, xmm1  ; xmm2 <-  0 m0 |0 x| 0 x | 0 m2 | 0 x | 0 x | 0 m3 |0 x , me guarde una copia de xmm1
		
		psllw xmm0, 8  ;  xmm0 <- x 0 |m1 0|x 0| x 0 | m3 0 | x 0 | x 0 |m5 0
		
		psrlw xmm0, 8  ;  xmm0 <- 0 x |0 m1|0 x| 0 x | 0 m3 | 0 x | 0 x |0 m5
		
		pand xmm1, xmm7 ; xmm1 <- 0 m0 |0 0| 0 0 | 0 m2 | 0 0 | 0 0 | 0 m4 |0 0
		
		psrldq xmm7, 2  ; xmm7 <-  00 |FF  |00 |00 |FF  |00 |00  |FF |
		
		pand xmm0, xmm7 ;  xmm0 <- 0 0|0 m1|0 0|0 0|0 m3|0 0|0 0 |0 m5
		
		pslldq xmm7, 2  ; xmm7 <- |FF  |00 |00 |FF  |00 |00  |FF |00  , shift a iz dos bytes reacomodo mask
		
		por xmm0,xmm1 ; xmm0 <-   0 m0|0 m1|0 0|0 m2|0 m3|0 0|0 m4 |0 m5
		
		pshufd xmm0, xmm0, 01101100b  ; xmm0 <-  0 m0|0 m1|0 m4|0 m5|0 m3|0 0|0 0 |0 m2
		
		pshufhw xmm0, xmm0, 01100011b ; xmm0 <-  0 m0|0 m1|0 m4|0 m5|0 m2|0 m3|0 0 |0 0
		
		pshufd xmm0,xmm0,  11011000b  ; xmm0 <-  0 m0|0 m1|0 m2|0 m3|0 m4|0 m5|0 0 |0 0
		
		psllw xmm0, 8   		 ; xmm0 <-   m0 0|m1 0|m2 0|m3 0|m4 0|m5 0|0 0 |0 0  corri 8 bits cada word
		
		pxor xmm3, xmm3
		
		packuswb xmm0,xmm3 ; xmm0 <-   m0 |m1|m2 |m3 |m4 |m5 |0 |0 |0 |0 |0 |0 |0 |0 |0 |0
		
	

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
	
