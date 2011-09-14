;************************************************************************************************************
; 												MACROS
;************************************************************************************************************
%macro convencion_c_in 1
	push ebp
	mov ebp, esp
	sub esp, %1
	push esi
	push edi
	push ebx
%endmacro


%macro convencion_c_out 1
	pop ebx
	pop edi
	pop esi
	add esp, %1
	pop ebp
%endmacro
