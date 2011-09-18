; void umbralizar_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size, unsigned char umbral_min, unsigned char umbral_max)

global umbralizar_asm

%include "macros.asm"

section .text

umbralizar_asm:
	convencion_c_in 0

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA INICIALIZAR VARIABLES AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    pxor xmm7, xmm7                                 ; xmm7 <- 0
    
    ;-----------------------
    ; Mascara con 128
    ;-----------------------
    
    mov eax, 80808080h                              ; eax <- 128 (byte packed)
    movd xmm6, eax                                  ; xmm6 <- |0..0|128| (byte packed)
    pshufd xmm6, xmm6, 0                            ; xmm6 <- 128 (byte packed)

    ;-----------------------
    ; Mascara umbral minimo
    ;-----------------------
    mov eax, [ebp+28]                               ; eax <- umbral_min
    mov ebx, eax
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx                                    ; eax <- umbral_min (byte packed)
    
    movd xmm5, eax                                  ; xmm5 <- |0..0|umbral_min| (byte packed)
    pshufd xmm5, xmm5, 0                            ; xmm5 <- umbral_min (byte packed)

    ;-----------------------
    ; Mascara umbral maximo
    ;-----------------------
    mov eax, [ebp+32]                               ; eax <- umbral_max
    mov ebx, eax
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx
    
    shl eax, 8
    add eax, ebx                                    ; eax <- umbral_max (byte packed)
    
    movd xmm4, eax                                  ; xmm4 <- |0..0|umbral_max| (byte packed)
    pshufd xmm4, xmm4, 0                            ; xmm4 <- umbral_max (byte packed)


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
		movdqu xmm0, [esi+ebx]                      ; xmm1 <- src[16]

        ;----------------------------------
        ; xmm0 <- src[16] 
        ; xmm7 <- 0
        ; xmm6 <- 128 (byte packed)
        ; xmm5 <- umbral_min (byte packed)
        ; xmm4 <- umbral_max (byte packed)
        ;----------------------------------
        
        movdqu xmm3, xmm4                           ; xmm3 <- umbral_max
        psubusb xmm3, xmm0                          ; xmm3 <- umbral_max - src[16]
        pcmpeqb xmm3, xmm7                          ; xmm1 <- |F..0..F..F..0| tengo F donde me sirve
        ;xmm3 <- mascara maxima
        
        psubusb xmm0, xmm5                          ; xmm0 <- src[16] -umbral_min
        pcmpeqb xmm0, xmm7                          ; xmm0 <- |F..0..F..F..0| tengo F donde me sirve
        ;xmm0 <- mascara minima

     
        por xmm0, xmm3                              ; xmm0 <- |F..0..F..F..0| tengo 0 donde me sirve
        ;xmm0 <- mascara con 0 en medios y F en extremos
        
        pcmpeqb xmm0, xmm7                          ; xmm0 <- |F..0..F..F..0| tengo F donde me sirve
        
        movdqu xmm2, xmm6                           ; xmm2 <- 128 (byte packed)
        pand xmm2, xmm0                          ; xmm2 <- |128..0..128..128..0| tengo 128 donde me sirve
        
        por xmm2, xmm3                              ; xmm2 <- |128..0..F..128..F..0| tengo 0 donde me sirve
        

		movdqu [edi+ebx],xmm2
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

