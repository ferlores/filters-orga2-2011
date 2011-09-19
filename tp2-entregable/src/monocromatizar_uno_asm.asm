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
	
				
	movdqu  xmm0, [esi] ; xmm0 = B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
	movdqu xmm1, xmm0  ; xmm1 =  B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
	movdqu xmm2, xmm0  ; xmm2 =  B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
				
				
	pslldq	xmm1, 1  ;xmm1 =     G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0
	pslldq  xmm2, 2  ; xmm2 = 	 R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 |0
					 ;xmm0 =     B0|G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5
	
	; debo desempaquetar
	
	
	; multiplico por dos el xmm2			
	psrlw xmm1,1      ; multiplico por dos cada word del xmm1 = G0|R0|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|0 *2 
	paddb xmm0,xmm1 ;
	paddb xmm0,xmm2 ;
	
	psllw xmm0 ,2 ; divido por 4 cada word => xmm0 = (B0+2*G0+R0)/4|  G0  |  R0|  (B1+2*G1+R1)/4| G1|R1|B2 +2*...  |G2|R2|B3+2* ..|G3|R3|B4+2* ..|G4|R4|B5
	
	;pand xmm0,  0xFF0000FF0000FF0000FF0000FF0000FF	
	; ahora como los meto:		
						;xmm0=cuentapix0  | 0 | 0| cuentapix1 |0 |0 | cuentapix2 | 0 |0 | cuenta pix3 | 0| 0| cuenta pix4 | 0 |0 | ??? 
	
	movdqu xmm2, xmm0  	;xmm2= cuentapix0 | 0 | 0| cuentapix1 |0 |0 | cuentapix2 | 0 |0 | cuenta pix3 | 0| 0| cuenta pix4 | 0 |0 | ??? 
	movdqu xmm3, xmm0;  	;xmm3= cuentapix0 | 0 | 0| cuentapix1 |0 |0 | cuentapix2 | 0 |0 | cuenta pix3 | 0| 0| cuenta pix4 | 0 |0 | ??? 
	
	psrldq xmm2, 1     ;xmm2=           0 |cuentapix0 | 0 | 0| cuentapix1 |0 |0 | cuentapix2 | 0 |0 | cuenta pix3 | 0| 0| cuenta pix4 | 0 |0 |
	psrldq xmm3, 2     ;xmm2=      0 | 0  |cuentapix0 | 0 | 0| cuentapix1 |0 |0 | cuentapix2 | 0 |0 | cuenta pix3 | 0| 0| cuenta pix4 | 0 |
	
	
	
	pop ebx
	pop edi
	pop esi
	pop ebp
	
	ret
