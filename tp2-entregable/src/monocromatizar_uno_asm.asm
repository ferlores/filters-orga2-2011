; void monocromatizar_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size)

global monocromatizar_uno_asm

%include "macros.asm"

section .text

%define src [ebp + 8]
%define dst [ebp + 12]
%define h [ebp + 16]
%define w [ebp + 20]
%define src_row_size [ebp + 24] ; no sabia que nombre ponerle asi que
%define dst_row_size [ebp + 28]


monocromatizar_uno_asm:
	push ebp
	mov ebp,esp
	push esi
	push edi
	push ebx
	
	
	mov esi, src ;
	mov edi, dst ; 
	
	cicloFilas:
			
			mov edx, w
			
			clicloCols:
				;mov eax,esi
				;mov ecx, w
				;sub ecx, edx

				;lea eax, [eax+ecx] ; podria hacer un add pero "en teoria(segund david)" lea es mas rapido porque tiene una alu aparte
				
			
				movdqu  xmm0, [esi] ; xmm0 = |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
				movdqu xmm1, xmm0  ; xmm1 = |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
				movdqu xmm2, xmm0  ; xmm2 = |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0
				
				
				psrldq	xmm1, 1  ;xmm1 = 	| 0|B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|	; me corro 1 byte pero creo que es a izq
				psrldq  xmm2, 2  ; xmm2 = 	| 0|0 |B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0| ; me corro 2
								; xmm0 = 	|B5|R4|G4|B4|R3|G3|B3|R2|G2|B2|R1|G1|B1|R0|G0|B0 |
				
				
				
	
	
	
	
	
	
	ret
