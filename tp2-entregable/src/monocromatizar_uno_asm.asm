; void monocromatizar_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_uno_asm

%define src_row_size [ebp+24]
%define dst_row_size [ebp+28]

%include "macros.asm"


section .text


monocromatizar_uno_asm:
	convencion_c_in 0
	
pxor xmm7, xmm7									
	mov ecx, 0xFFFFFFFF								
	pinsrw xmm7, ecx, 0								
	pinsrw xmm7, ecx, 3
	pinsrw xmm7, ecx, 6								; xmm7 <- |FF|00|00|FF|00|00|FF|00
													; xmm7 <- |00|FF|00|00|FF|00|00|FF
 
pxor xmm3, xmm3         ; xmm3 <- 0 util para desempaquetado y empaquetados
	
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
	xor edx, edx                                    ;     #columnas_p_dst <- 0    
	
	cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

		
		movdqu xmm0, [esi+ebx]; xmm0 <-     B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
		
	
		carga_distinto_ultima_columna:
		
		movdqu xmm1, xmm0       ; xmm1 <- B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
		movdqu xmm2, xmm0       ; xmm2 <- B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
				
		psrldq	xmm1, 1         ; xmm1 <- 0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0| (byte packed)
		psrldq  xmm2, 2         ; xmm2 <- 0 |0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0| (byte packed)
		
		

        ;-------------------------------------------------------------------------
		; xmm0 <- src_0 = |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0| (byte packed)
		; xmm1 <- src_1 = |0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0| (byte packed)
		; xmm2 <- src_2 = |0 |0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0| (byte packed)
		; xmm3 <- 0
        ;-------------------------------------------------------------------------

		movdqu xmm5, xmm1       ; xmm5 <- 0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|
	
		punpcklbw xmm1, xmm3    ; xmm1 <- 0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|  (word packed)   xmm1 parte baja de operndo 2
		punpckhbw xmm5, xmm3    ; xmm5 <- 0| 0|0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|0|B3|  (word packed)     xmm5 parte alta de operando2	 
	
		psllw xmm1,1            ; xmm1 <- 0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|         *2 de a words
		psllw xmm5,1            ; xmm5 <- 0|0|0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|0|B3           *2 de a words
		
        ;-------------------------------------------------------------------------
		; xmm1 <- src_1_l = |0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0| (word packed)
		; xmm5 <- src_1_h = |0| 0|0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|0|B3| (word packed)
        ;-------------------------------------------------------------------------
        

		movdqu xmm4, xmm0      
		punpcklbw xmm0, xmm3    ; xmm0 <- |0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|0|B0|   xmm0 parte baja de operando 1 
		punpckhbw xmm4, xmm3    ; xmm4 <- |0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|0|B3|0|R2|     xmm4 pate alta de operando1
		
        ;-------------------------------------------------------------------------
		; xmm0 <- src_0_l = |0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|0|B0| (word packed)
		; xmm4 <- src_0_h = |0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|0|B3|0|R2| (word packed)
        ;-------------------------------------------------------------------------
		
		movdqu xmm6, xmm2       ; xmm6 <- |0 |0|B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|   
		
		punpcklbw xmm2, xmm3    ; xmm2 <- |0|B3|0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|    xmm2 parte baja de operando 3
		punpckhbw xmm6, xmm3    ; xmm6 <- |0|0 |0|0 |0|B5|0|R4|0|G4|0|B4|0|R3|0|G3|  xmm6 parte alta de operando 3 
		
        ;-------------------------------------------------------------------------
		; xmm2 <- src_2_l = |0|B3|0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0| (word packed)
		; xmm6 <- src_2_h = |0|0 |0|0 |0|B5|0|R4|0|G4|0|B4|0|R3|0|G3| (word packed)
        ;-------------------------------------------------------------------------
        
        
		;sumemos partes bajas
		paddw xmm0,xmm1         ;xmm0 <-  +  |0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|0|B0|
                                ;         +  |0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|0|G0|   *2 de a words
		paddw xmm0,xmm2         ;		     |0|B3|0|R2|0|G2|0|B2|0|R1|0|G1|0|B1|0|R0|
                                ;xmm0 <-     |xxxx|  S2|xxxx|xxxx|  S1|xxxx|xxxx|  S0|   donde S = B+2*G+R   
		
        ; xmm0 suma partes bajas  llamo "s" a la suma sin la division por 4
		
		paddw xmm4, xmm6        ;xmm4 suma partes altas
		paddw xmm4, xmm5	    ;xmm4 <-     |xxxx|xxxx|xxxx|  S4|xxxx|xxxx|  S3|xxxx|   donde S = B+2*G+R   
			
			; divido por 4 casa suma y tengo la cuenta que queria llamo c a la cuenta que quiero
		
		psrlw xmm0, 2           ;xmm0 <- |xx|C2|xx|xx|C1|xx|xx|C0|   donde C = (B+2*G+R)/16
		psrlw xmm4, 2           ;xmm4 <- |xx|xx|xx|C4|xx|xx|C3|xx|   donde C = (B+2*G+R)/16

	
        
                                        ; xmm7 <- |00|FF|00|00|FF|00|00|FF|
		pand xmm0,xmm7                  ; xmm0 <- |00|c2|00|00|c1|00|00|c0|  (word packed)
		
		pslldq xmm7, 2                  ; xmm7 <- |FF|00|00|FF|00|00|FF|00|
		pand xmm4, xmm7                 ; xmm4 <- |xx|00|00|c4|00|00|c3|00|  (word packed)
	
		psrldq xmm7, 2                  ; xmm7 <- |00|FF|00|00|FF|00|00|FF| , shift a iz dos bytes reacomodo mask

		por xmm0, xmm4                  ; xmm0 <- |xx|c2|00|c4|c1|00|c3|c0|
		pshuflw xmm0, xmm0,  10011100b  ; xmm0 <- |xx|c2|00|c4|00|c3|c1|c0|
		pshufd xmm0,xmm0,  11011000b    ; xmm0 <- |xx|c2|00|c3|00|c4|c1|c0|
		pshufhw xmm0, xmm0,  11010010b  ; xmm0 <- |xx|00|c3|c2|00|c4|c1|c0|
		pshufd xmm0, xmm0, 11011000b    ; xmm0 <- |xx|00|00|c4|c3|c2|c1|c0| (word packed)
		
		packuswb xmm0,xmm3     	        ; xmm0 <- |0 |0| 0| 0 |0 |0| 0| 0| 0|0|x|c4|c3|c2|c1|c0
        movd [edi+edx], xmm0
		
        psrldq xmm0, 4
        movd eax, xmm0								; eax <- |0|0|0|c4|

		mov [edi+edx+4], al 						
        
        		
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add edx ,5                                 ;        #columnas_p_dst <- #columnas_p_dst + 4
	                              ;        #columnas_p <- #columnas_p + 16
		add ebx ,15
		
		
		mov eax, w			                        ;        eax <- w
		lea eax, [eax + 2*eax]						;        eax <- 3*w
	
		sub eax, ebx                                ;        eax <- 3*w - #columnas_p
        
		cmp eax, 16                                 ;        IF (3*w - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
		
        cmp eax, 1                                   ;        IF (3*w - #columnas_p)
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        add ebx, eax		                        ;        ebx <- 3*w
        sub ebx,16                                  ;        ebx <- 3*w - 16
         mov edx, w			                        ;        edx <- dst_row_size
        sub edx,5                                   ;        edx <- dst_row_size - 5

		movdqu xmm0, [esi+ebx]						;        xmm0 <- ultimos_16b(src) |R   B|GR|BG|RB|GR|BG|RB|GR|
		psrldq xmm0, 1								
		
        jmp carga_distinto_ultima_columna           ;      ENDWHILE
	
    termineCol:
		
		add esi,src_row_size                            ;   src <- src + row_size
		add edi,dst_row_size                            ;   dst <- dst + row_size
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

		
fin_invertir:
	convencion_c_out 0
	ret
