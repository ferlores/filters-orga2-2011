;************************************************************************************************************
; 									     DEFINES PARAMETROS GENERICOS
;************************************************************************************************************

%define src [ebp+8]
%define dst [ebp+12]
%define m [ebp+16]
%define n [ebp+20]
%define row_size [ebp+24]


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

