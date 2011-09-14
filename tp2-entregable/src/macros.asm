;************************************************************************************************************
; 									     DEFINES PARAMETROS
;************************************************************************************************************

%define src [ebp+8]
%define dst_r [ebp+12]
%define dst_g [ebp+16]
%define dst_b [ebp+20]
%define m [ebp+24]
%define n [ebp+28]
%define row_size [ebp+32]
%define src_row_size [ebp+32]
%define dst_row_size [ebp+36]


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

