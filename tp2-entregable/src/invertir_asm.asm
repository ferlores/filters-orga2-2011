; void invertir_asm (unsigned char *src, unsigned char *dst, int h, int w, int row_size)

global invertir_asm

%include "macros.asm"

section .text

invertir_asm:
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

;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
;       INSERTE SU CODIGO PARA ITERAR AQUI!
;XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
		movdqu xmm0, [esi+ebx]
        
        pcmpeqb xmm7, xmm7                          ; xmm7 <- |FFFF....FFFF|
        
        psubb xmm7, xmm0                            ; xmm0 <- |255-src[i]|

		movdqu [edi+ebx],xmm7

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

fin_invertir:
	convencion_c_out 0
	ret

