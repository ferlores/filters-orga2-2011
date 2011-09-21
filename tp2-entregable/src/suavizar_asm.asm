; void suavizar_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global suavizar_asm

%define parte_alta [ebp-16]
%define parte_baja [ebp-32]

;==================================================================================
; Template para recorrer las imagenes controlando el padding
; esi <- *src
; edi <- *dst
; REGISTROS QUE USA PARA ITERAR: eax, ebx, ecx
;==================================================================================
%include "macros.asm"

section .text

suavizar_asm:
	convencion_c_in 64

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	mov edx,16
	pxor xmm6,xmm6
	movd xmm6,edx
	pshufd xmm6,xmm6,0			; xmm6 = 16 (packed word)
	cvtdq2ps xmm6,xmm6


;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   

	mov esi, src		                            ; esi <- *src
	mov edi, dst		                            ; edi <- dst
	mov ecx, h                                      ; ecx <- h
	sub ecx,2
	add edi,row_size		;empiezo de la segunda linea
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
; ejemplo de imagen :
; a0 a1 a2  a3 a4 a5  a6 a7 a8  a9 a10 a11 a12 a13  a14 a15 a16
; b0 b1 b2  b3 b4 b5  b6 b7 b8  b9 b10 b11 b12 b13  b14 b15 b16
; c0 c1 c2  c3 c4 c5  c6 c7 c8  c9 c10 c11 c12 c13  c14 c15 c16
;Cuenta
;	out_b1 = ( a0 + 2a1 + a2 + 2b0 + 4b1 + 2b2 + c0 + 2c1 + c2 ) +_)/ 16 
;
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

	;*******************************************;
	;	  PRIMER LINEA DE LA MATRIZ(ALTA)   ;
	;*******************************************;
	; XMM0 ACUMULADOR PARTE ALTA		    ;	
	;*******************************************;

		movdqu xmm0, [esi+ebx]		; xmm0 = a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16
		movdqu xmm1, [esi+ebx+1]	; xmm1 = a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 xx
		movdqu xmm2, [esi+ebx+2]	; xmm2 = a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15 a16 xx xx

		pxor xmm7,xmm7			; xmm7 = 0		
		punpckhbw xmm0,xmm7		; xmm0 = 0 a0 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7
		movdqu xmm3,xmm0		; xmm3 = xmm0

		punpckhwd xmm0,xmm7		; xmm0 = 0 a0 0 a1 0 a2 0 a3 	
		punpcklwd xmm3,xmm7		; xmm3 = 0 a4 0 a5 0 a6 0 a7

		punpckhbw xmm1,xmm7		; xmm1 = 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8
		movdqu xmm4,xmm1		; xmm4 = xmm1
		punpckhwd xmm1,xmm7		; xmm1 = 0 a1 0 a2 0 a3 0 a4
		punpcklwd xmm4,xmm7		; xmm4 = 0 a5 0 a6 0 a7 0 a8

		punpckhbw xmm2,xmm7		; xmm2 = 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8 0 a9
		movdqu xmm5,xmm2		; xmm5 = xmm2
		punpckhwd xmm2,xmm7		; xmm2 = 0 a2 0 a3 0 a4 0 a5
		punpcklwd xmm5,xmm7		; xmm5 =  0 a6 0 a7 0 a8 0 a9

		paddd xmm0,xmm1			; xmm0 = | a0 + a1 | a1 + a2 | a2 + a3 | a4 + a5 |
		paddd xmm0,xmm1			; xmm0 = | a0 + 2*a1 | a1 + 2*a2 | a2 + 2*a3 | a4 + 2*a5 |
		paddd xmm0,xmm2			; xmm0 = | a0 + 2*a1 + a2 | a1+2*a2+a3| a2+2*a3+a4| a4+2*a5+a6 |
		movdqu parte_alta,xmm0		; parte_alta = xmm0

		addps xmm3,xmm4
		addps xmm3,xmm4
		addps xmm3,xmm5
		movdqu parte_baja,xmm3

	;*******************************************;
	;	 SEGUNDA LINEA DE LA MATRIZ(ALTA)   ;
	;*******************************************;

		add esi, row_size 		; voy a la linea de abajo
		movdqu xmm1, [esi+ebx]		; xmm1 = b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16
		movdqu xmm2, [esi+ebx+1]	; xmm2 = b1 b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 xx
		movdqu xmm3, [esi+ebx+2]	; xmm3 = b2 b3 b4 b5 b6 b7 b8 b9 b10 b11 b12 b13 b14 b15 b16 xx xx
		
		pxor xmm7,xmm7			; xmm7 = 0		
		punpckhbw xmm0,xmm7		; xmm0 = 0 a0 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7
		movdqu xmm3,xmm0
		punpckhwd xmm0,xmm7		
	;	cvtdq2ps xmm0,xmm0
		punpcklwd xmm3,xmm7
	;	cvtdq2ps xmm3,xmm3


		punpckhbw xmm1,xmm7		; xmm1 = 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8
		movdqu xmm4,xmm1	
		punpckhwd xmm1,xmm7		
	;	cvtdq2ps xmm1,xmm1
		punpcklwd xmm4,xmm7
	;	cvtdq2ps xmm4,xmm4		

		punpckhbw xmm2,xmm7		; xmm2 = 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8 0 a9
		movdqu xmm5,xmm2	
		punpckhwd xmm2,xmm7		
	;	cvtdq2ps xmm2,xmm2
		punpcklwd xmm5,xmm7
	;	cvtdq2ps xmm5,xmm5

		paddd xmm0,xmm1
		paddd xmm0,xmm1
		paddd xmm0,xmm1
		paddd xmm0,xmm1
		paddd xmm0,xmm2
		paddd xmm0,xmm2
		movdqu xmm1,parte_alta
		paddd xmm1,xmm0
		movdqu parte_alta,xmm1

		paddd xmm3,xmm4
		paddd xmm3,xmm4
		paddd xmm3,xmm4
		paddd xmm3,xmm4
		paddd xmm3,xmm5
		paddd xmm3,xmm5
		movdqu xmm4,parte_baja
		paddd xmm4,xmm3
		movdqu parte_baja,xmm4
		
	;*******************************************;
	;	 TERCER LINEA DE LA MATRIZ(ALTA)	    ;
	;*******************************************;
		add esi,row_size

		movdqu xmm1, [esi+ebx]		; xmm1 = c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 C14 c15 c16
		movdqu xmm2, [esi+ebx+1]	; xmm2 = c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16 xx
		movdqu xmm3, [esi+ebx+2]	; xmm3 = c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14 c15 c16 xx xx
			
		pxor xmm7,xmm7			; xmm7 = 0		
		punpckhbw xmm0,xmm7		; xmm0 = 0 a0 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7
		movdqu xmm3,xmm0
		punpckhwd xmm0,xmm7		
		punpcklwd xmm3,xmm7
		

		punpckhbw xmm1,xmm7		; xmm1 = 0 a1 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8
		movdqu xmm4,xmm1	
		punpckhwd xmm1,xmm7		
		punpcklwd xmm4,xmm7

		punpckhbw xmm2,xmm7		; xmm2 = 0 a2 0 a3 0 a4 0 a5 0 a6 0 a7 0 a8 0 a9
		movdqu xmm5,xmm2	
		punpckhwd xmm2,xmm7		
	;	cvtdq2ps xmm2,xmm2
		punpcklwd xmm5,xmm7
	;	cvtdq2ps xmm5,xmm5

		paddd xmm0,xmm1
		paddd xmm0,xmm1
		paddd xmm0,xmm2
		movdqu xmm1,parte_alta
		paddd xmm1,xmm0

		paddd xmm3,xmm4
		paddd xmm3,xmm4
		paddd xmm3,xmm5
		movdqu xmm4,parte_baja	
		paddd xmm4,xmm3
				
		cvtdq2ps xmm1,xmm1
		cvtdq2ps xmm4,xmm4

		divps xmm4,xmm6
		divps xmm1,xmm6		
		
		cvttps2dq xmm4,xmm4
		cvttps2dq xmm1,xmm1

		packssdw xmm4,xmm1
		packuswb xmm4,xmm4
	
		; me paro en la primer linea otra vez
		sub esi, row_size
		sub esi, row_size
		
		movdqu [edi+ebx+1 ],xmm4
			   
		add ebx ,8                                 ;        #columnas_p <- #columnas_p + 16
		mov eax, w                          ;        eax <- row_size
		sub eax,2		
		sub eax, ebx                                ;        eax <- row_size - #columnas_p
        
		cmp eax, 8                                 ;        IF (row_size - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
		cmp eax,0                                   ;        IF (row_size - #columnas_p)
		jle termineCol                               ;          BREAK
		
        ;ultimos pixeles
		mov ebx, w                           ;        ebx <- row_size
		sub ebx,8                                  ;        ebx <- row_size - 17
		jmp cicloColumna                            ;      ENDWHILE
	
    termineCol:
		
		add esi,row_size                            ;   src <- src + row_size
		add edi,row_size                            ;   dst <- dst + row_size
       		dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

fin_invertir:
	convencion_c_out 64
	ret

