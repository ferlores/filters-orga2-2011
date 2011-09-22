; void monocromatizar_inf_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_inf_asm

%define src_row_size [ebp+24]
%define dst_row_size [ebp+28]

%include "macros.asm"

section .text

monocromatizar_inf_asm:

convencion_c_in 0

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;mask : 		dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000 no funciono pero podria haber funcionado con los movs adecuados probemos mejor por la idea de fer
pxor xmm7, xmm7									
	mov ecx, 0xFFFFFFFF								
	pinsrw xmm7, ecx, 0								
	pinsrw xmm7, ecx, 3
	pinsrw xmm7, ecx, 6								; xmm7 <- |FF|00|00|FF|00|00|FF|00

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
	xor ebx,ebx                                     ;     #columnas_p_src <- 0    
    xor edx, edx                                    ;     #columnas_p_dst <- 0    
	cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA ITERAR AQUI!


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		movdqu xmm0, [esi+ebx]
		
    carga_distinto_ultima_columna:
        
		movdqu xmm1, xmm0  	;  
		movdqu xmm2, xmm0   
							; xmm0 <-     B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
		
		psrldq	xmm1, 1  	; xmm1  <-    0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|
		psrldq  xmm2, 2  	; xmm2 <- 	  0 |0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|
		
		pmaxub xmm0,xmm1	
		pmaxub xmm0, xmm2   ;xmm0 <-   B5|x|x|max|x|x|max|x|x|max|x|x|max|x|x|max
		; xmm0 <-   max{B0,GO,R0)}|G0|R0|max{B1,G1,R1}|--|--|max ...|G2|R2|max..|G3|R3|max..|G4|R4|B5
		
		movdqu xmm1, xmm0    ; lo copio porque lo voy a usar despues pero por ahora me olvido
		
		psllw xmm1,8   	; xmm1 <-  x 0 |m4 0| x 0 | x 0 |m2 0 | x 0 | x 0 |m0 0
		
		movdqu xmm2, xmm1  	; xmm1 <-  x 0 |m4 0| x 0 | x 0 |m2 0 | x 0 | x 0 |m0 0
		
		psrlw xmm0, 8  ;  xmm0 <- 0 m5|0 x|0 x| 0 m3 | 0 x | 0 x| 0 m1|0 x
	
		
		psllw xmm0, 8  ;  xmm0 <- m5 0|x 0|x 0| m3 0| x 0 | x 0| m1 0| x 0
		
		
		pand xmm1, xmm7 ;xmm1 <-  0 0|m4 0| 0 0 | 0 0 |m2 0 | 0 0 | 0 0 |m0 0  hasta aca ok
		
		
		pslldq xmm7, 2  ; xmm7 <-  |00 |00 |FF  |00 |00  |FF |00
		
		pand xmm0, xmm7 ;  xmm0 <- 0 0|0 0|0 0| m3 0| 0 0 | 0 0| m1 0| 0 0
		
		
		psrldq xmm7, 2  ; xmm7 <- 00 |FF  |00 |00 |FF  |00 |00  |FF | , shift a iz dos bytes reacomodo mask
		
		por xmm0,xmm1 ; xmm0 <- m5 0|m4 0|0 0| m3 0| m2 0 | 0 0| m1 0| m0 0  ; no ok vr si es 0 y arrastrar
		
		
		pshufd xmm0, xmm0, 01101100b ;xmm0 <- m2 0|0 0|0 0| m3 0| m5 0 |m4 0| m1 0| m0 0
		
		
		pshufhw xmm0, xmm0, 01100011b ;xmm0 <- 0 0|0 0|m3 0| m2 0| m5 0 |m4 0| m1 0| m0 0  si  no s car esta bien
		
		
		pshufd xmm0,xmm0,  11011000b  ;xmm0 <- 0 0|0 0|m5 0| m4 0| m3 0 |m2 0| m1 0| m0 0
		
		
		psrlw xmm0, 8   		;xmm0 <- 0 0|0 0|0 m5| 0 m4| 0 m3 |0 m2| 0 m1| 0 m0
		
		
		pxor xmm3, xmm3
		
		packuswb xmm0,xmm3 	; xmm0 <-  0 |0| 0| 0 |0 |0| 0| 0| 0|0|m5|m4|m3|m2|m1|m0
		
	
		
		movd eax, xmm0	
		

		mov [edi+edx], eax  ; copio de a 4
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
        add edx ,4                                  ;        #columnas_p_dst <- #columnas_p_dst + 4
		add ebx ,12                                 ;        #columnas_p <- #columnas_p + 16

		mov eax, w			                        ;        eax <- w
		lea eax, [eax + 2*eax]						;        eax <- 3*w
	
		sub eax, ebx                                ;        eax <- 3*w - #columnas_p
        
		cmp eax, 16                                 ;        IF (3*w - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
        cmp eax, 4                                   ;        IF (3*w - #columnas_p)
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        add ebx, eax		                        ;        ebx <- 3*w
        sub ebx,16                                  ;        ebx <- 3*w - 17
         mov edx, w			                        ;        edx <- dst_row_size
        sub edx,4                                   ;        edx <- dst_row_size - 5

		movdqu xmm0, [esi+ebx]						;        xmm0 <- ultimos_16b(src) |RB|GR   |BG|RB|GR|BG|RB|GR|
		psrldq xmm0, 4								
		
        jmp carga_distinto_ultima_columna           ;      ENDWHILE
	
    termineCol:
		
		add esi,src_row_size                            ;   src <- src + row_size
		add edi,dst_row_size                            ;   dst <- dst + row_size
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 0
        ret
	
