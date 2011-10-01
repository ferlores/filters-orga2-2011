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
		
		movdqu xmm1, [esi+ebx]		; xmm1 <- a15|a14|a13|a12|a11|a10|a9|a8|a7|a6|a5|a4|a3|a2|a1|a0
		movdqu xmm2, [esi+ebx+1]	; xmm2 <- a16|a15|a14|a13|a12|a11|a10|a9|a8|a7|a6|a5|a4|a3|a2|a1|
		movdqu xmm3, [esi+ebx+2]	; xmm3 <- a17|a16|a15|a14|a13|a12|a11|a10|a9|a8|a7|a6|a5|a4|a3|a2|
		movdqu xmm4,xmm1			; xmm4 <- xmm1
		movdqu xmm5,xmm2			; xmm5 <- xmm2
		movdqu xmm6,xmm3			; xmm6 <- xmm3

		;desempaqueto y me quedo con los primeros pixeles
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		; parte baja xmm1 <- |0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|0 a1|0 a0|
		punpcklbw xmm2,	xmm7		; parte baja xmm2 <- |0 a8|0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|0 a1|
		punpcklbw xmm3,	xmm7		; parte baja xmm3 <- |0 a9|0 a8|0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|
		punpckhbw xmm4,xmm7			; parte alta xmm4 <- |0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|0 a9|0 a8|
		punpckhbw xmm5,xmm7			; parte alta xmm5 <- |0 a16|0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|0 a9|
		punpckhbw xmm6,xmm7			; parte alta xmm6 <- |0 a17|0 a16|0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|

		;hago cuentas en la parte baja
		psllw xmm2,1			;|0 a8|0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|0 a1| *2 
		
		paddw xmm1,xmm3			;xmm1 <- |0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|0 a1|0 a0|
								;xmm3 <- |0 a9|0 a8|0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|
		paddw xmm1,xmm2							;-------------------------------------------------
								;xmm1 <- |a7+a9|a6+a8|a5+a7|a4+a6|a3+a5|a2+a4|a1+a3|a0+a2|
								;xmm2 <- |0 a8|0 a7|0 a6|0 a5|0 a4|0 a3|0 a2|0 a1|
								;-------------------------------------------------------
								;xmm1 <-|a7+a9+a8|a6+a8+a7|a5+a7+a6|a4+a6+a5|a3+a5+a4|a2+a4+a3|a1+a3+a2|a0+a2+a1|  xmm1 <- xmm1 + xmm3 + 2*xmm2 ( primer fila de la matriz armada)			
		
		;hago cuentas en la parte alta
		psllw xmm5,1					;xmm5 <- |0 a16|0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|0 a9| * 2 
		paddw xmm4,xmm5					;xmm4 <-|0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|0 a9|0 a8|
		paddw xmm4,xmm6					;------------------------------------------------------------
										;xmm4 <-| a15+a16|a14+a15|a13+a14|a12+a13|a11+a12|a10+a11|a9+a10|a8+a9|
										;xmm6 <-|0 a17|0 a16|0 a15|0 a14|0 a13|0 a12|0 a11|0 a10|
										;---------------------------------------------------------------------
										;xmm4 <-| a15+a16+a17|a14+a15+a16|a13+a14+a15|a12+a13+a14|a11+a12+a13|a10+a11+a12|a9+a10+a11|a8+a9+a10|
		
		
		movdqu xmm0,xmm1		;xmm0 <-|a7+a9+a8|a6+a8+a7|a5+a7+a6|a4+a6+a5|a3+a5+a4|a2+a4+a3|a1+a3+a2|a0+a2+a1|   guardo en xmm0 mi valor 
		movdqu parte_baja,xmm4     
		
		
		
		
		
		;calculo lo correspondiente a la segunda fila de la matriz
		add esi,row_size		;paso a la segunda fila
		movdqu xmm1, [esi+ebx]		; xmm1 <- b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|b1|b0
		movdqu xmm2, [esi+ebx+1]	; xmm2 <- b16|b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|b1|
		movdqu xmm3, [esi+ebx+2]	; xmm3 <- b17|b16|b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|
		
		
		movdqu xmm4,xmm1		; xmm4 <- b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|b1|b0
		movdqu xmm5,xmm2		; xmm5 <- b16|b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|b1|
		movdqu xmm6,xmm3		; xmm6 <- b17|b16|b15|b14|b13|b12|b11|b10|b9|b8|b7|b6|b5|b4|b3|b2|
		;desempaqueto y me quedo con los primeros pixeles
		
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		;xmm1 <- |0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1|0 b0|;parte baja xmm1
		punpcklbw xmm2,	xmm7		;xmm2 <- |0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1|;parte baja xmm2
		punpcklbw xmm3,	xmm7		;xmm3 <- |0 b9|0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|;parte baja xmm3
		punpckhbw xmm4,xmm7			;xmm4<-  |0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|0 b9|0 b8|;parte alta xmm1
		punpckhbw xmm5,xmm7			;xmm5 <- |0 b16|0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|0 b9|;parte alta xmm2
		punpckhbw xmm6,xmm7			;xmm6 <- |0 b17|0 b16|0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|;parte alta xmm3	

		
		
		psllw xmm1,1			;xmm1 <- |0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1|0 b0| * 2
		psllw xmm2,2			;xmm2 <- |0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1| * 4
		psllw xmm3,1			;xmm3 <- |0 b9|0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2| * 2
	
		psllw xmm4,1			;xmm4<-  |0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|0 b9|0 b8| * 2
		psllw xmm5,2			;xmm5 <- |0 b16|0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|0 b9|* 4
		psllw xmm6,1			;xmm6 <- |0 b17|0 b16|0 b15|0 b14|0 b13|0 b12|0 b11|0 b10|*2
		
		
		;trabajo parte baja
		paddw xmm1,xmm2			;xmm1 <- |0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1|0 b0| * 2
		paddw xmm1,xmm3			;xmm2 <- |0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2|0 b1| * 4
		paddw xmm0,xmm1			;---------------------------------------------------------
								;xmm1 <- |b7+b8|b6+b7|b5+b6|b4+b5|b3+b4|b2+b3|b1+b2|b0+b1|
								;xmm3 <- |0 b9|0 b8|0 b7|0 b6|0 b5|0 b4|0 b3|0 b2| * 2
								;------------------------------------------------------------
								;xmm1 <- |b7+b8+b9|b6+b7+b8|b5+b6+b7|b4+b5+b6|b3+b4+b5|b2+b3+b4|b1+b2+b3|b0+b1+b2|
								;xmm0 <- |a[7:9].b[7:9]|a[6:8].b[6:9]|a[5:7].b[5:7]||a[4:6].b[4:6]|a[3:5].b[3:5]|a[2:4].b[2:4]|a[1:3].b[1:3]|a[0:2].b[0:2]|   guardo en xmm0 mi valor de a+b's
								
		
		
		;trabajo parte alta
		movdqu xmm7,parte_baja 	;xmm7<-| a15+a16+a17|a14+a15+a16|a13+a14+a15|a12+a13+a14|a11+a12+a13|a10+a11+a12|a9+a10+a11|a8+a9+a10|
		paddw xmm7,xmm4			;xmm7<-| a15+a16+a17|a14+a15+a16|a13+a14+a15|a12+a13+a14|a11+a12+a13|a10+a11+a12|a9+a10+a11|a8+a9+a10|
		paddw xmm7,xmm5
		paddw xmm7,xmm6			;xmm7<-|a[15:17].b[15:17]|a[14:16].b[14:16]|a[13:15].b[13:15]||a[12:14].b[12:14]|a[11:13].b[11:13]|a[10:12].b[10:12]|a[9:11].b[9:11]|a[8:10].b[8:10]|
		
		
		
		movdqu parte_baja , xmm7 	;parte baja<-|a[15:17].b[15:17]|a[14:16].b[14:16]|a[13:15].b[13:15]||a[12:14].b[12:14]|a[11:13].b[11:13]|a[10:12].b[10:12]|a[9:11].b[9:11]|a[8:10].b[8:10]|

		;paso a la tercer fila de la matriz para calcular (Igual a la primer fila.)
		add esi,row_size

		movdqu xmm1, [esi+ebx]		; xmm1 <- c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|c1|c0
		movdqu xmm2, [esi+ebx+1]	; xmm2 <- c16|c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|c1|
		movdqu xmm3, [esi+ebx+2]	; xmm3 <- c17|c16|c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|
		movdqu xmm4,xmm1			; xmm4 <- c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|c1|c0
		movdqu xmm5,xmm2			; xmm5 <- c16|c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|c1|
		movdqu xmm6,xmm3			; xmm6 <- c17|c16|c15|c14|c13|c12|c11|c10|c9|c8|c7|c6|c5|c4|c3|c2|

		;desempaqueto y me quedo con los primeros pixeles
		pxor xmm7,xmm7			
		punpcklbw xmm1,	xmm7		;xmm1 <- |0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|0 c1|0 c0|
		punpcklbw xmm2,	xmm7		;xmm2 <- |0 c8|0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|0 c1|
		punpcklbw xmm3,	xmm7		;xmm3 <- |0 c9|0 c8|0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|
		punpckhbw xmm4,xmm7			;xmm4<-  |0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|0 c9|0 c8| 
		punpckhbw xmm5,xmm7			;xmm5<-  |0 c16|0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|0 c9| 
		punpckhbw xmm6,xmm7			;xmm6<-  |0 c17|0 c16|0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|
		
		psllw xmm2,1			;xmm2 <- |0 c8|0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|0 c1|*2
		
		
		paddw xmm1,xmm3				;xmm1 <- |0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|0 c1|0 c0|
		paddw xmm1,xmm2				;xmm3 <- |0 c9|0 c8|0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|
		paddw xmm0,xmm1				;----------------------------------------------------
									;xmm1 <- |c7+c9|c6+c8|c5+c7|c4+c6|c3+c5|c2+c4|c1+c3|c0+c2|
									;xmm2 <- |0 c8|0 c7|0 c6|0 c5|0 c4|0 c3|0 c2|0 c1|
									;-----------------------------------------------------
									;xmm1 <- |c7+c8+c9|c6+c7+c8|c5+c6+c7|c4+c5+c6|c3+c4+c5|c2+c3+c4|c1+c2+c3|c0+c1+c2|
									;xmm0 <- |a[7:9].b[7:9].c[7:9] |a[6:8].b[6:9].c[6:9]|a[5:7].b[5:7].c[5:7]||a[4:6].b[4:6].c[4:6] |a[3:5].b[3:5].c[3:5] |a[2:4].b[2:4].c[2:4] |a[1:3].b[1:3].c[1:3]|a[0:2].b[0:2].c[0:2]|
									
		
		
		psllw xmm5,1				;xmm5<-  |0 c16|0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|0 c9| 
		paddw xmm4,xmm5				;xmm4<-  |0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|0 c9|0 c8| 
		paddw xmm4,xmm6				;----------------------------------------------------------------
		movdqu xmm7,parte_baja		;xmm4<-  |c15+c16|c14+c15|c13+c14|c12+c13|c11+c12|c10+c11|c9+c10|c8+c9| 
		paddw xmm7,xmm4				;xmm6<-  |0 c17|0 c16|0 c15|0 c14|0 c13|0 c12|0 c11|0 c10|
									;-----------------------------------------------------------------------
									;xmm4<- |c15+c16+c17|c14+c15+c16|c13+c14+c15|c12+c13+c14|c11+c12+c13|c10+c11+c12|c9+c10+c11|c8+c9+c10| 
									;xmm7<-|a[15:17].b[15:17].c[15:17]|a[14:16].b[14:16].c[14:16]|a[13:15].b[13:15].c[13:15]||a[12:14].b[12:14].c[12:14]|a[11:13].b[11:13].c[11:13]|a[10:12].b[10:12].c[10:12]|a[9:11].b[9:11].c[9:11]|a[8:10].b[8:10].c[8:10]|



		psrlw xmm0,4				;xmm0 <- |a[7:9].b[7:9].c[7:9] |a[6:8].b[6:9].c[6:9]|a[5:7].b[5:7].c[5:7]||a[4:6].b[4:6].c[4:6] |a[3:5].b[3:5].c[3:5] |a[2:4].b[2:4].c[2:4] |a[1:3].b[1:3].c[1:3]|a[0:2].b[0:2].c[0:2]|  / 16
		psrlw xmm7,4				;xmm7 <- |a[15:17].b[15:17].c[15:17]|a[14:16].b[14:16].c[14:16]|a[13:15].b[13:15].c[13:15]||a[12:14].b[12:14].c[12:14]|a[11:13].b[11:13].c[11:13]|a[10:12].b[10:12].c[10:12]|a[9:11].b[9:11].c[9:11]|a[8:10].b[8:10].c[8:10]| / 16
		packuswb xmm0,xmm7			;xmm0 <- |res15 res14|res13 res12|res11 res10|res9 res8|res7 res6|res5 res4|res3 res2|res1 res0| 

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

