; void monocromatizar_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_uno_asm

%include "macros.asm"

section .text


monocromatizar_uno_asm:
	convencion_c_in 0
	
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

		
		movdqu xmm0, [esi+ebx]; xmm0 = B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
		movdqu xmm1, xmm0  ; xmm1 =  B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
		movdqu xmm2, xmm0  ; xmm2 =  B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
				
				
		pslldq	xmm1, 1  ;xmm1 =     G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0
		pslldq  xmm2, 2  ; xmm2 = 	 R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 |0
					 ;xmm0 =     B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
	
		; debo desempaquetar xmm1 shit!
		pxor xmm3, xmm3    ; dos registro con cero	
		movdqu xmm5, xmm1
	
		punpcklbw xmm1, xmm3   ; xmm1 <- G0|0|R0|0|B1|0|G1|0|R1|0|B2|0|G2|0|R2|0
		punpckhbw xmm5, xmm3;    xmm5 <- B3|0|G3|0|R3|0|B4|0|G4|0|R4|0|B5|0|0|0	 
	
		psllw xmm1,1 ; xmm1 <- G0|0|R0|0|B1|0|G1|0|R1|0|B2|0|G2|0|R2|0 *2 de a words
		psllw xmm5,1 ; xmm5 <- B3|0|G3|0|R3|0|B4|0|G4|0|R4|0|B5|0|0|0	*2 de a words 
		; empaqueto de nuevo para tenerlos de byte
		packuswb  xmm1, xmm5 ; xmm1 <- G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 * 2
	
		paddb xmm0,xmm1 ;  llamo "s" a b+2*g+r
		paddb xmm0,xmm2 ;  xmm0 <- s0|x|x|s1|x|x|s2|x|x|s3|x|x|s4|x|x|x 
		; misma historia para multiplicar por 4
		pxor xmm3,xmm3
		movdqu xmm5, xmm0
	
		punpcklbw xmm0,xmm3 ; xmm0 <- s0|0|x|0|x|0|s1|0|x|0|x|0|s2|0|x|0
		punpckhbw xmm5,xmm3  ;xmm5 <-  x|0|s3|0|x|0|x|0|s4|0|x|0|x|0|x|0 
		psrlw xmm0,2	;    xmm0  <- s0|0|x|0|x|0|s1|0|x|0|x|0|s2|0|x|0    /4
		psrlw xmm5,2    ;    xmm5  <-  x|0|s3|0|x|0|x|0|s4|0|x|0|x|0|x|0      /4
	
		;llamo  "c" a la cuenta rara que quria hacer
		packuswb  xmm0,xmm5 ;    c0|x|x|c1|x|x|c2|x|x|c3|x|x|c4|x|x|x
		; hasta aca tengo los resultados para empezar a hacer la logica del programa
		; como voy a procesar con los 4 primero ( hasta c3 la logica es la misma que monocromINF)
		;-----logica-------------------
		movdqu xmm1, xmm0    ; copio el registro para trabajarlo mejor
	
		psrlw xmm1,8   ; xmm1 <-  0 m0 |0 x| 0 x | 0 m2 | 0 x | 0 x | 0 m4 |0 x  shiftee cada word 8 bits logico a derecha
	
		movdqu xmm2, xmm1  ; xmm2 <-  0 m0 |0 x| 0 x | 0 m2 | 0 x | 0 x | 0 m3 |0 x , me guarde una copia de xmm1
	
		psllw xmm0, 8  ;  xmm0 <- x 0 |c1 0|x 0| x 0 | c3 0 | x 0 | x 0 |c5 0
		
		psrlw xmm0, 8  ;  xmm0 <- 0 x |0 c1|0 x| 0 x | 0 c3 | 0 x | 0 x |0 c5
	
		pand xmm1, xmm7 ; xmm1 <- 0 c0 |0 0| 0 0 | 0 c2 | 0 0 | 0 0 | 0 c4 |0 0
	
		psrldq xmm7, 2  ; xmm7 <-  00 |FF  |00 |00 |FF  |00 |00  |FF |
	
		pand xmm0, xmm7 ;  xmm0 <- 0 0|0 c1|0 0|0 0|0 c3|0 0|0 0 |0 c5
	
		pslldq xmm7, 2  ; xmm7 <- |FF  |00 |00 |FF  |00 |00  |FF |00  , shift a iz dos bytes reacomodo mask
	
		por xmm0,xmm1 ; xmm0 <-   0 c0|0 c1|0 0|0 c2|0 c3|0 0|0 c4 |0 c5
	
		pshufd xmm0, xmm0, 01101100b  ; xmm0 <-  0 c0|0 c1|0 c4|0 c5|0 c3|0 0|0 0 |0 c2
	
		pshufhw xmm0, xmm0, 01100011b ; xmm0 <-  0 c0|0 c1|0 mc|0 c5|0 c2|0 c3|0 0 |0 0
	
		pshufd xmm0,xmm0,  11011000b  ; xmm0 <-  0 c0|0 c1|0 c2|0 c3|0 c4|0 c5|0 0 |0 0
	
		psllw xmm0, 8   		 ; xmm0 <-   c0 0|c1 0|c2 0|c3 0|c4 0|c5 0|0 0 |0 0  corri 8 bits cada word
		
		pxor xmm3, xmm3
		
		packuswb xmm0,xmm3 ; xmm0 <-   c0 |c1|c2 |c3 |c4 |c5 |0 |0 |0 |0 |0 |0 |0 |0 |0 |0
	
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
	ret
