;==================================================================================
; Template para recorrer las imagenes controlando el padding
; esi <- *src
; edi <- dst
; ecx <- h
; ebx <- #columnas_procesada
;==================================================================================

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
		;~ movdqu xmm3,[mascara_255]
		;~ psubd xmm0,xmm3

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

