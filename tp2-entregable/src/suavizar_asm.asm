; void suavizar_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global suavizar_asm

%define parte_baja [ebp-16]

;==================================================================================
; Template para recorrer las imagenes controlando el padding
; esi <- *src
; edi <- *dst
; REGISTROS QUE USA PARA ITERAR: eax, ebx, ecx
;==================================================================================
%include "macros.asm"

section .text

suavizar_asm:
	convencion_c_in 16

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;      				 INICIALIZAR VARIABLES
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	mov esi, src		                            ; esi <- *src
	mov edi, dst		                            ; edi <- dst
	mov ecx, h                                      ; ecx <- h
	sub ecx,2
	add edi,row_size		;empiezo de la segunda linea

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   

    ;----------------------------------
    ; esi <- *src
    ; edi <- dst
    ; ecx <- h
    ; ebx <- #columnas_procesada
    ;----------------------------------

    
cicloFila:                                          ; WHILE(h7,!=0) DO
	xor ebx,ebx                                     ;     #columnas_p <- 0    
	

	cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA ITERAR AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
; matriz de imagen :
; a0 a1 a2  
; b0 b1 b2 
; c0 c1 c2  
;Cuenta
;	out_b1 = ( a0 + 2a1 + a2 + 2b0 + 4b1 + 2b2 + c0 + 2c1 + c2 ) +_)/ 16 
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	;*******************************************;
	;	  PRIMER LINEA DE LA MATRIZ(ALTA)   ;
	;*******************************************;
	; XMM0 ACUMULADOR PARTE ALTA		    ;	
	;*******************************************;
		
		movdqu xmm1, [esi+ebx]		; xmm1 = a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16
		movdqu xmm2, [esi+ebx+1]	; xmm2 = a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 xx
		movdqu xmm3, [esi+ebx+2]	; xmm3 = a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 xx xx
		movdqu xmm4,xmm1		; xmm4 = xmm1
		movdqu xmm5,xmm2		; xmm5 = xmm2
		movdqu xmm6,xmm3		; xmm6 = xmm3

		;desempaqueto y me quedo con los primeros pixeles
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		; parte baja xmm1 = |0 a9|0 a10|0 a11|0 a12|0 a13|0 a14|0 a15|0 a16|
		punpcklbw xmm2,	xmm7		; parte baja xmm2 = |0 a10|0 a11|0 a12|0 a13|0 a14|0 a15|0 a16|a 17|
		punpcklbw xmm3,	xmm7		; parte baja xmm3 = |0 a11|0 a12|0 a13|0 a14|0 a15|0 a16|a a17|a 18|
		punpckhbw xmm4,xmm7		; parte alta xmm4 = |0 a0|0  a1|0 a2|0 a3|0 a4|0 a5|0 a6|0 a7|0 a8|
		punpckhbw xmm5,xmm7		; parte alta xmm5 = |0 a1|0 a2|0 a3 |0 a4|0 a5|0 a6|0 a7|0 a8|0 a9|
		punpckhbw xmm6,xmm7		; parte alta xmm6 = |0 a2|0 a3|0 a4|0 a5|0 a6|0 a7|0 a8|0 a9|0 a10|

		;hago cuentas en la parte baja
		psllw xmm2,1			;xmm2 * 2 
		paddw xmm1,xmm3			;xmm1 = xmm1 + xmm3
		paddw xmm1,xmm2			; xmm1 = xmm1 + xmm3 + 2*xmm2 ( primer fila de la matriz armada)
		;hago cuentas en la parte alta
		psllw xmm5,1
		paddw xmm4,xmm5
		paddw xmm4,xmm6
	
		movdqu xmm0,xmm1		;guardo en xmm0 mi valor 
		movdqu parte_baja,xmm4
		;calculo lo correspondiente a la segunda fila de la matriz
		add esi,row_size		;paso a la segunda fila
		movdqu xmm1, [esi+ebx]		; xmm0 = b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16
		movdqu xmm2, [esi+ebx+1]	; xmm1 = b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 xx
		movdqu xmm3, [esi+ebx+2]	; xmm2 = b2 b3 b4 b5 b6 b7 b8 b9 a10 a11 b12 b13 b14 b15 b16 xx xx
		movdqu xmm4,xmm1		; xmm4 = xmm1
		movdqu xmm5,xmm2		; xmm5 = xmm2
		movdqu xmm6,xmm3		; xmm6 = xmm3
		;desempaqueto y me quedo con los primeros pixeles
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		;parte baja xmm1
		punpcklbw xmm2,	xmm7		;parte baja xmm2
		punpcklbw xmm3,	xmm7		;parte baja xmm3
		punpckhbw xmm4,xmm7		;parte alta xmm1
		punpckhbw xmm5,xmm7		;parte alta xmm2
		punpckhbw xmm6,xmm7		;parte alta xmm3	

		psllw xmm1,1			;multiplico por 2 a xmm1
		psllw xmm2,2			;multiplico por 4 a xmm2
		psllw xmm3,1			;multiplico por 2 a xmm3
	
		psllw xmm4,1			;multiplico por 2 a xmm1
		psllw xmm5,2			;multiplico por 4 a xmm2
		psllw xmm6,1			;multiplico por 2 a xmm3
		;trabajo parte baja
		paddw xmm1,xmm2			;sumo xmm0 = 2*xmm1 + 4*xmm2 + 2*xmm3
		paddw xmm1,xmm3
		paddw xmm0,xmm1
		;trabajo parte alta
		movdqu xmm7,parte_baja
		paddw xmm7,xmm4
		paddw xmm7,xmm5
		paddw xmm7,xmm6
		movdqu parte_baja , xmm7 	;guardo variable local

		;paso a la tercer fila de la matriz para calcular (Igual a la primer fila.)
		add esi,row_size

		movdqu xmm1, [esi+ebx]		
		movdqu xmm2, [esi+ebx+1]	
		movdqu xmm3, [esi+ebx+2]	
		movdqu xmm4,xmm1
		movdqu xmm5,xmm2
		movdqu xmm6,xmm3

		;desempaqueto y me quedo con los primeros pixeles
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		; xmm1 = |0 a0|0  a1|0 a2|0 a3|0 a4|0 a5|0 a6|0 a7|0 a8|
		punpcklbw xmm2,	xmm7		; xmm2 = |0 a1|0 a2|0 a3 |0 a4|0 a5|0 a6|0 a7|0 a8|0 a9|
		punpcklbw xmm3,	xmm7		; xmm3 = |0 a2|0 a3|0 a4|0 a5|0 a6|0 a7|0 a8|0 a9|0 a10|
		punpckhbw xmm4,xmm7
		punpckhbw xmm5,xmm7
		punpckhbw xmm6,xmm7
		
		psllw xmm2,1
		paddw xmm1,xmm3
		paddw xmm1,xmm2
		paddw xmm0,xmm1

		psllw xmm5,1
		paddw xmm4,xmm5
		paddw xmm4,xmm6
		movdqu xmm7,parte_baja
		paddw xmm7,xmm4
		

		psrlw xmm0,4
		psrlw xmm7,4
		packuswb xmm0,xmm7

		; me paro en la primer linea otra vez
		sub esi, row_size
		sub esi, row_size
		
		movdqu [edi+ebx+1 ],xmm0
		
		add ebx ,15                                ;        #columnas_p <- #columnas_p + 16
		 mov eax, w                          	    ;        eax <- row_size
		sub eax,2		
		 sub eax, ebx  
			   
		;~ add ebx ,16                                 ;        #columnas_p <- #columnas_p + 16
		;~ mov eax, w                          	    ;        eax <- row_size
		;~ sub eax,2		
		;~ sub eax, ebx                                ;        eax <- row_size - #columnas_p
        
		cmp eax, 16                                 ;        IF (row_size - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
		cmp eax,0                                   ;        IF (row_size - #columnas_p)
		jle termineCol                              ;          BREAK
		
        mov ebx, w                          	    ;        ebx <- row_size
		 sub ebx,16                                 ;        ebx <- row_size - 17
		jmp cicloColumna     
        
        ;ultimos pixeles
		;~ mov ebx, w                          	    ;        ebx <- row_size
		;~ sub ebx,16                                  ;        ebx <- row_size - 17
		;~ jmp cicloColumna                            ;      ENDWHILE
	
    termineCol:
		
		add esi,row_size                            ;   src <- src + row_size
		add edi,row_size                            ;   dst <- dst + row_size
       		dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 16
	ret

