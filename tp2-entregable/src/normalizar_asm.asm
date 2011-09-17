; void normalizar_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)
global normalizar_asm
extern printf

%include "macros.asm"

section .text

normalizar_asm:
    convencion_c_in 0
    
    mov esi, src                                                ; esi <- *src
            
    
    pcmpeqb xmm6, xmm6                                          ; min <- |FFFF....FFFF|
    pxor xmm5, xmm5                                             ; max <- |0000....0000|
    
	mov eax, w													; eax <- w
	    
	mov edx, eax												; edx <- w
    shl edx, 28
    shr edx, 28                                                 ; edx <- mod(w,16) es shr apropositio porque es un numero positivo
    
    sar eax, 4                                                  ; eax <- floor(w/16)
	
	cmp edx, 0													; IF(mod(w,16)!=0)
	je cont														; DO
	sub edx, 16													;   edx <- mod(w,16)-16
cont:															; ENDIF
	mov ebx, h                                                  ; edx <-h 
    ;-------------------------
    ; eax <- floor(m/16)
    ; ebx <- n
    ; edx <- mod(m/16)-16
    ; xmm6 <- |FFFF....FFFF|
	; xmm6 <- |0000....0000|
    ;-------------------------

;=====================================================
; BUSCA MINIMO Y MAXIMO
;=====================================================     		
busca_h:    
	cmp ebx, 0										;FOR n TIMES DO
	je busca_fin
	
    mov ecx, eax                              		; ecx <- floor(m/16)
    busca_w:                                        ; FOR (m/16) TIMES DO
		;XXXXXXXXX
		movdqu xmm7, [esi]  						;    xmm7 <- *src (16px)
        pminub xmm6, xmm7                           ;    min <- |min(src[i_0]),...,min(src[i_15])|
        pmaxub xmm5, xmm7                           ;    max <- |max(src[i_0]),...,max(src[i_15])|
		;XXXXXXXXX
        lea esi, [esi+16]	                        ;    *src <- *src + 16
		loop busca_w 	                            ; ENDDO
	
	;con esto proceso lo que me estaba faltando de la fila			
	cmp edx, 0										; IF(padding) 
	je busca_cont									; DO
										
	lea esi, [esi + edx]							;    *src <- ultimos_16B_fila(*src)

	;XXXXXXXXX
	movdqu xmm7, [esi]  							;     xmm7 <- *src (16px)
	pminub xmm6, xmm7                           	;     min <- |min(src[i_0]),...,min(src[i_15])|
	pmaxub xmm5, xmm7                           	;     max <- |max(src[i_0]),...,max(src[i_15])|
	;XXXXXXXXX

    mov ecx, edx                                    ; mod_16(m)-16
    neg ecx                                         ; mod_16(m)-16
    
    shl ecx, 30                                     ; uso SHR aproposito porque siempre es positivo
    shr ecx, 30                                     ; ecx <- mod_4(16-mod_16(m))
    
    
	lea esi, [esi + ecx + 16]								;     *src <- *src + row_size-m
	
busca_cont:											; ENDIF
	dec ebx												 
    jmp busca_h										;ENDDO

busca_fin:    

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
    
    
    ;pshufhw xmm6,xmm6, 11111111b                    ; xmm4 <- |min|min|min|min|min|min|min|min|lasts_8B(xmm6)| MASK: 11 11 11 11b    
    
    ;pxor xmm4, xmm4									; xmm4 <- 0h
    ;punpckhbw xmm6, xmm4							; xmm6 <- |0|min|0|min|0|min|0|min|0|min|0|min|0|min|0|min|
    ;pshufd xmm6, xmm6, 11111111b                    ; xmm4 <- |min|min|min|min|min|min|min|min|min|min|min|min|min|min|min|min| MASK: 11 11 11 11b
    
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

    ;pshufhw xmm5,xmm5, 11111111b                    ; xmm5 <- |max|max|max|max|max|max|max|max|lasts_8B(xmm6)| MASK: 11 11 11 11b    
    
    ;pxor xmm4, xmm4									; xmm4 <- 0h
    ;punpckhbw xmm5, xmm4							; xmm5 <- |0|max|0|max|0|max|0|max|0|max|0|max|0|max|0|max|
 
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
    
    
    
 	;~ pextrw ebx, xmm5, 0xF							; bx <- |0|max|
    ;~ pextrw ecx, xmm6, 0xF							; cx <- |min|min|
    ;~ shr cx,8                                         ; cx <- |0|min|
        ;~ 
    ;~ sub bx, cx										; bx <- max - min
;~ 
	;~ 
	;~ push eax										; salva eax
;~ 
    ;~ mov ax, 255										; ax <- 255
    ;~ div bl											; al <- k=255/(max-min)
    ;~ mov ah, 0										; ax <- |0|k|
    ;~ mov cx, ax			   							; cx <- |0|k|
    ;~ shl ecx, 16										; ecx <- |0|k|0|0|
    ;~ mov cx, ax										; ecx <- |0|k|0|k|
     ;~ 
    ;~ pop eax											; recupera eax
;~ 
	;~ pinsrw xmm5, ecx, 0								; xmm5 <- |.....................|0k|0k|0k|0k|
    ;~ pshuflw xmm5, xmm5, 0							; xmm5 <- |.......|0k|0k|0k|0k|
    ;~ pshufd xmm5, xmm5, 0							; xmm5 <- |0k|0k|0k|0k|0k|0k|0k|0k|
    
    
;=====================================================
; ESCRIBO EN LA MATRIZ
;=====================================================
    mov esi, src                                    ; esi <- *src
    mov edi, dst                                    ; edi <- *dst

	mov ebx, h										;ebx <- h

    pxor xmm3, xmm3                             ;    xmm3 <- 0
	;---------------------------------------------
    ; eax <- floor(m/16)
    ; ebx <- n
    ; edx <- mod(m/16)-16
    ; edi <- row_size-m    
	; xmm4 <- k=255/(max-min) (single fp packed)
    ; xmm6 <- min (single fp packed)
    ; xmm3 <- 0h (constante para desempaquetado)
    ; xmm7 <- src[16b]
    ;---------------------------------------------
    
calcula_h:    
	cmp ebx, 0										;FOR n TIMES DO
	je calcula_fin
	
    mov ecx, eax                              		; ecx <- floor(m/16)
    calcula_w:                                        ; FOR (m/16) TIMES DO
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		movdqu xmm7, [esi]  						;    xmm7 <- *src (16px)

    ;-----------------------------
    ; ultimos 8 bytes
    ;----------------------------

        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpckhbw xmm5, xmm3                         ;    xmm5 <- |src[8..15]| (word-packed)
        movdqu xmm2, xmm5     						;    xmm2 <- |src[8..15]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                         ;    xmm5 <- |src[12..15]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[12..15]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[12..15]-min| (single fp packed)
        mulps xmm5, xmm4                           ;    xmm5 <- |k*(src[12..15]-min)| (single fp packed)   <-  src[12..15] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm2, xmm3                         ;    xmm2 <- |src[8..11]| (doubleword-packed)
        cvtdq2ps xmm2, xmm2                         ;    xmm2 <- |src[8..11]| (single fp packed)
        
        subps xmm2, xmm6                            ;    xmm2 <- |src[8..11]-min| (single fp packed)
        mulps xmm2, xmm4                           ;    xmm2 <- |k*(src[8..11]-min)| (single fp packed)    <-  src[8..11] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[12..15]  procesado (double-word packed)
        cvtps2dq xmm2, xmm2                         ;    xmm2 <-  src[8..11]  procesado (double-word packed)

        packssdw xmm2, xmm5                         ;    xmm2 <-  src[8..15] procesado (word packed)        <-  src[8..15] PROCESADO
        
        ; xmm2 <-  src[8..15] PROCESADO (word packed) 
    ;-----------------------------
    ; primeros 8 bytes
    ;----------------------------
        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpcklbw xmm5, xmm3                         ;    xmm5 <- |src[0..7]| (word-packed)
        movdqu xmm1, xmm5     						;    xmm1 <- |src[0..7]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                         ;    xmm5 <- |src[4..7]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[4..7]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[4..7]-min| (single fp packed)
        mulps xmm5, xmm4                           ;    xmm5 <- |k*(src[4..7]-min)| (single fp packed)   <-  src[4..7] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm1, xmm3                         ;    xmm1 <- |src[0..3]| (doubleword-packed)
        cvtdq2ps xmm1, xmm1                         ;    xmm1 <- |src[0..3]| (single fp packed)
        
        subps xmm1, xmm6                            ;    xmm1 <- |src[0..3]-min| (single fp packed)
        mulps xmm1, xmm4                           ;    xmm1 <- |k*(src[0..3]-min)| (single fp packed)    <-  src[0..3] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[4..7]  procesado (double-word packed)
        cvtps2dq xmm1, xmm1                         ;    xmm1 <-  src[0..3]  procesado (double-word packed)

        packssdw xmm1, xmm5                         ;    xmm2 <-  src[0..7] procesado (word packed)        <-  src[0..7] PROCESADO
        
        packuswb xmm1, xmm2                         ;    xmm1 <-  src[0..15] procesado (byte packed)
        
        movdqu [edi], xmm1  						;    dst <- (src-min)*255/(min-max)
        
		;XXXXXXXXX
        lea esi, [esi + 16]	                        ;    *src <- *src + 16
        lea edi, [edi + 16]	                        ;    *dst <- *dst + 16        
		loop calcula_w 	                            ; ENDDO
	
	;con esto proceso lo que me estaba faltando de la fila												
	cmp edx, 0										; IF(padding) 
	je calcula_cont									; DO
	lea esi, [esi + edx]							;    *src <- ultimos_16B_fila(*src)
    lea edi, [edi + edx]	                        ;    *dst <- ultimos_16B_fila(*dst)
    
	;XXXXXXXXX
    movdqu xmm7, [esi]  						;    xmm7 <- *src (16px)

    ;-----------------------------
    ; ultimos 8 bytes
    ;----------------------------

        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpckhbw xmm5, xmm3                         ;    xmm5 <- |src[8..15]| (word-packed)
        movdqu xmm2, xmm5     						;    xmm2 <- |src[8..15]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                         ;    xmm5 <- |src[12..15]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[12..15]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[12..15]-min| (single fp packed)
        mulps xmm5, xmm4                           ;    xmm5 <- |k*(src[12..15]-min)| (single fp packed)   <-  src[12..15] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm2, xmm3                         ;    xmm2 <- |src[8..11]| (doubleword-packed)
        cvtdq2ps xmm2, xmm2                         ;    xmm2 <- |src[8..11]| (single fp packed)
        
        subps xmm2, xmm6                            ;    xmm2 <- |src[8..11]-min| (single fp packed)
        mulps xmm2, xmm4                           ;    xmm2 <- |k*(src[8..11]-min)| (single fp packed)    <-  src[8..11] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[12..15]  procesado (double-word packed)
        cvtps2dq xmm2, xmm2                         ;    xmm2 <-  src[8..11]  procesado (double-word packed)

        packssdw xmm2, xmm5                         ;    xmm2 <-  src[8..15] procesado (word packed)        <-  src[8..15] PROCESADO
        
        ; xmm2 <-  src[8..15] PROCESADO (word packed) 
    ;-----------------------------
    ; primeros 8 bytes
    ;----------------------------
        movdqu xmm5, xmm7     						;    xmm5 <- *src (16px)
                
        punpcklbw xmm5, xmm3                         ;    xmm5 <- |src[0..7]| (word-packed)
        movdqu xmm1, xmm5     						;    xmm1 <- |src[0..7]| (word-packed)

        ; prepara y procesa los ultimos 4 bytes
        punpckhwd xmm5, xmm3                         ;    xmm5 <- |src[4..7]| (doubleword-packed)
        cvtdq2ps xmm5, xmm5                         ;    xmm5 <- |src[4..7]| (single fp packed)
        
        subps xmm5, xmm6                            ;    xmm5 <- |src[4..7]-min| (single fp packed)
        mulps xmm5, xmm4                           ;    xmm5 <- |k*(src[4..7]-min)| (single fp packed)   <-  src[4..7] PROCESADO
            
        ; prepara y procesa los primeros 4 bytes
        punpcklwd xmm1, xmm3                         ;    xmm1 <- |src[0..3]| (doubleword-packed)
        cvtdq2ps xmm1, xmm1                         ;    xmm1 <- |src[0..3]| (single fp packed)
        
        subps xmm1, xmm6                            ;    xmm1 <- |src[0..3]-min| (single fp packed)
        mulps xmm1, xmm4                           ;    xmm1 <- |k*(src[0..3]-min)| (single fp packed)    <-  src[0..3] PROCESADO
        
        cvtps2dq xmm5, xmm5                         ;    xmm5 <-  src[4..7]  procesado (double-word packed)
        cvtps2dq xmm1, xmm1                         ;    xmm1 <-  src[0..3]  procesado (double-word packed)

        packssdw xmm1, xmm5                         ;    xmm2 <-  src[0..7] procesado (word packed)        <-  src[0..7] PROCESADO
        
        packuswb xmm1, xmm2                         ;    xmm1 <-  src[0..15] procesado (byte packed)
        
        movdqu [edi], xmm1  						;    dst <- (src-min)*255/(min-max)

	;XXXXXXXXX
    ;----------------------------
    ; Saltea el padding
    ;----------------------------
    mov ecx, edx                                    ; mod_16(m)-16
    neg ecx                                         ; mod_16(m)-16
    
    shl ecx, 30                                     ; uso SHR aproposito porque quiero perder el signo
    shr ecx, 30                                     ; ecx <- mod_4(16-mod_16(m))
    
	lea esi, [esi + ecx + 16]						; *src <- *src + row_size-m
    lea edi, [edi + ecx + 16]						; *dst <- *dst + row_size-m
	
calcula_cont:										; ENDIF
	dec ebx												 
    jmp calcula_h										;ENDDO

calcula_fin:    
        
    convencion_c_out 0
    ret
