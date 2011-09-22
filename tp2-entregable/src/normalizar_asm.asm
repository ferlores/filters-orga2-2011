; void normalizar_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)
global normalizar_asm

%include "macros.asm"

section .text

normalizar_asm:
	convencion_c_in 0
	mov esi, src		                            ; esi <- *src
	mov edi, dst		                            ; edi <- dst
	mov ecx, h                                      ; ecx <- h
    
        
    pcmpeqb xmm6, xmm6                                          ; min <- |FFFF....FFFF|
    pxor xmm5, xmm5                                             ; max <- |0000....0000|
 
    ;----------------------------------
    ; esi <- *src
    ; edi <- dst
    ; ecx <- h
    ; ebx <- #columnas_procesada
    ;----------------------------------
b_cicloFila:                                          ; WHILE(h!=0) DO
	xor ebx,ebx                                     ;     #columnas_p <- 0    
	b_cicloColumna:	                                ;     WHILE(#columnas_p < row_size) DO

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       BUSCA MAXIMO Y MINIMO
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        movdqu xmm7, [esi+ebx]  						;    xmm7 <- *src (16px)
        pminub xmm6, xmm7                           ;    min <- |min(src[i_0]),...,min(src[i_15])|
        pmaxub xmm5, xmm7                           ;    max <- |max(src[i_0]),...,max(src[i_15])|
        

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add ebx ,16                                 ;        #columnas_p <- #columnas_p + 16
		mov eax, w                                  ;        eax <- w
		sub eax, ebx                                ;        eax <- w - #columnas_p
        
		cmp eax, 16                                 ;        IF (w - #columnas_p) < 16
		jge b_cicloColumna                            ;          CONTINUE
		
        cmp eax,0                                   ;        IF (w - #columnas_p)
		je b_termineCol                               ;          BREAK
		
        ;ultimos pixeles
        mov ebx, w                                  ;        ebx <- w
        sub ebx, 16                                 ;        ebx <- row_size - 16
        jmp b_cicloColumna                            ;      ENDWHILE
	
    b_termineCol:
		
		add esi,row_size                            ;   src <- src + row_size
        dec ecx                                     ;   h--
		jnz b_cicloFila                               ; ENDWHILE


;=====================================================
; CALCULO EL MINIMO
;=====================================================
    pshufd xmm4, xmm6, 01001110b                    ; xmm4 <- |lasts_8B(xmm6)|firsts_8B(xmm6)| MASK: 01 00 11 10b
    pminub xmm6, xmm4                               ; xmm6 <- |min(lasts_8B(xmm6), firsts_8B(xmm6))|min(lasts_8B(xmm6), firsts_8B(xmm6))|
    
    pshufhw xmm4,xmm6, 01001110b                    ; xmm4 <- |lasts_4B(xmm6)|firsts_4B(xmm6)|lasts_8B(xmm6)| MASK: 01 00 11 10b
    pminub xmm6, xmm4                               ; xmm6 <- |min(lasts_4B(xmm6), firsts_4B(xmm6))|min(lasts_4B(xmm6), firsts_4B(xmm6))|lasts_8B(xmm6)|    
    
    pshufhw xmm4,xmm6, 10110001b                    ; xmm4 <- |word2(xmm6)|word3(xmm6)|word0(xmm6)|word1(xmm6)|lasts_8B(xmm6)| MASK: 10 11 00 01b    
    pminub xmm6, xmm4                               ; xmm6 <- |min_2B(xmm6)|min_2B(xmm6)|min_2B(xmm6)|min_2B(xmm6)|lasts_8B(xmm6)|     
    
    movdqu xmm4, xmm6                                                
    psllq xmm4, 8                                   ; desfaso los dos bytes que me faltan comparar
    pminub xmm6, xmm4                               ; xmm6 <- |min|........|     
    
    psrldq xmm6, 3                                  ; xmm6 <- |0|0|0|min|..............| (byte packed)
    pshufd xmm6, xmm6, 11111111b                    ; xmm6 <- |min|min|min|min| MASK: 11 11 11 11b (double-word packed)
    cvtdq2ps xmm6, xmm6                             ; xmm6 <- |min|min|min|min| (single floating-point packed)
    
	;-----------------------------------------------
    ; xmm6 <- min (single floating-point packed)
	;-----------------------------------------------

;=====================================================
; CALCULO EL MAXIMO
;=====================================================
    pshufd xmm4, xmm5, 01001110b                    ; xmm4 <- |lasts_8B(xmm6)|firsts_8B(xmm6)| MASK: 01 00 11 10b
    pmaxub xmm5, xmm4                               ; xmm6 <- |max(lasts_8B(xmm6), firsts_8B(xmm6))|max(lasts_8B(xmm6), firsts_8B(xmm6))|
    
    pshufhw xmm4,xmm5, 01001110b                    ; xmm4 <- |lasts_4B(xmm6)|firsts_4B(xmm6)|lasts_8B(xmm6)| MASK: 01 00 11 10b
    pmaxub xmm5, xmm4                               ; xmm6 <- |max(lasts_4B(xmm6), firsts_4B(xmm6))|max(lasts_4B(xmm6), firsts_4B(xmm6))|lasts_8B(xmm6)|    
    
    pshufhw xmm4,xmm5, 10110001b                    ; xmm4 <- |word2(xmm6)|word3(xmm6)|word0(xmm6)|word1(xmm6)|lasts_8B(xmm6)| MASK: 10 11 00 01b    
    pmaxub xmm5, xmm4                               ; xmm6 <- |max_2B(xmm6)|max_2B(xmm6)|max_2B(xmm6)|max_2B(xmm6)|lasts_8B(xmm6)|     
    
    movdqu xmm4, xmm5                                                
    psllq xmm5, 8                                   ; desfaso los dos bytes que me faltan comparar
    pmaxub xmm5, xmm4                               ; xmm6 <- |max|........|     
    
    psrldq xmm5, 3                                  ; xmm5 <- |0|0|0|max|..............| (byte packed)
    pshufd xmm5, xmm5, 11111111b                    ; xmm5 <- |max|max|max|max| MASK: 11 11 11 11b (double-word packed)
    cvtdq2ps xmm5, xmm5                             ; xmm5 <- |max|max|max|max| (single floating-point packed)

	;---------------------------------------------
    ; xmm5 <- max (single floating-point packed)
	;---------------------------------------------
    
;=====================================================
; CALCULA LA CONSTANTE DE NORMALIZACION
;=====================================================
 
    subps xmm5, xmm6                                    ; xmm5 <- max-min (single fp packed)
    
    mov ecx, 255                                        ; ecx <- 255
    cvtsi2ss xmm4, ecx                                  ; xmm4 <- 255 (scalar) 
    pshufd xmm4, xmm4, 0                                ; xmm5 <- |255|255|255|255| MASK: 00 00 00 00b (single fp packed) 

    divps xmm4, xmm5                                    ; xmm4 <- |K|K|K|K| con K=255*(max-min)
    


;=====================================================
; ESCRIBO EN LA MATRIZ
;=====================================================

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
        movdqu xmm7, [esi+ebx]  						;    xmm7 <- *src (16px)

    ;-----------------------------
    ; ultimos 8 bytes
    ;----------------------------

        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpckhbw xmm5, xmm3                        ;    xmm5 <- |src[8..15]| (word-packed)
        movdqu xmm2, xmm5     						;    xmm2 <- |src[8..15]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                        ;    xmm5 <- |src[12..15]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[12..15]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[12..15]-min| (single fp packed)
        mulps xmm5, xmm4                            ;    xmm5 <- |k*(src[12..15]-min)| (single fp packed)   <-  src[12..15] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm2, xmm3                        ;    xmm2 <- |src[8..11]| (doubleword-packed)
        cvtdq2ps xmm2, xmm2                         ;    xmm2 <- |src[8..11]| (single fp packed)
        
        subps xmm2, xmm6                            ;    xmm2 <- |src[8..11]-min| (single fp packed)
        mulps xmm2, xmm4                            ;    xmm2 <- |k*(src[8..11]-min)| (single fp packed)    <-  src[8..11] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[12..15]  procesado (double-word packed)
        cvtps2dq xmm2, xmm2                         ;    xmm2 <-  src[8..11]  procesado (double-word packed)

        packssdw xmm2, xmm5                         ;    xmm2 <-  src[8..15] procesado (word packed)        <-  src[8..15] PROCESADO
        
        ; xmm2 <-  src[8..15] PROCESADO (word packed) 
    ;-----------------------------
    ; primeros 8 bytes
    ;----------------------------
        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpcklbw xmm5, xmm3                        ;    xmm5 <- |src[0..7]| (word-packed)
        movdqu xmm1, xmm5     						;    xmm1 <- |src[0..7]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                        ;    xmm5 <- |src[4..7]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[4..7]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[4..7]-min| (single fp packed)
        mulps xmm5, xmm4                            ;    xmm5 <- |k*(src[4..7]-min)| (single fp packed)   <-  src[4..7] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm1, xmm3                        ;    xmm1 <- |src[0..3]| (doubleword-packed)
        cvtdq2ps xmm1, xmm1                         ;    xmm1 <- |src[0..3]| (single fp packed)
        
        subps xmm1, xmm6                            ;    xmm1 <- |src[0..3]-min| (single fp packed)
        mulps xmm1, xmm4                            ;   xmm1 <- |k*(src[0..3]-min)| (single fp packed)    <-  src[0..3] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[4..7]  procesado (double-word packed)
        cvtps2dq xmm1, xmm1                         ;    xmm1 <-  src[0..3]  procesado (double-word packed)

        packssdw xmm1, xmm5                         ;    xmm2 <-  src[0..7] procesado (word packed)        <-  src[0..7] PROCESADO
        
        packuswb xmm1, xmm2                         ;    xmm1 <-  src[0..15] procesado (byte packed)
        
        movdqu [edi+ebx], xmm1 						;    dst <- (src-min)*255/(min-max)
        

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX				   
		add ebx ,16                                 ;        #columnas_p <- #columnas_p + 16
		mov eax, w                                  ;        eax <- w
		sub eax, ebx                                ;        eax <- w - #columnas_p
        
		cmp eax, 16                                 ;        IF (w - #columnas_p) < 16
		jge cicloColumna                            ;          CONTINUE
		
        cmp eax,0                                   ;        IF (w - #columnas_p)
		je termineCol                               ;          BREAK
		
        ;ultimos pixeles
        mov ebx, w                                  ;        ebx <- w
        sub ebx, 16                                  ;        ebx <- row_size - 16
        jmp cicloColumna                            ;      ENDWHILE
	
    termineCol:
		
		add esi,row_size                            ;   src <- src + row_size
		add edi,row_size                            ;   dst <- dst + row_size
        dec ecx                                     ;   h--
		jnz cicloFila                               ; ENDWHILE

	convencion_c_out 0
	ret

