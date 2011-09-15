void monocromatizar_uno_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size) {

	// me pasan una "martiz" en realidad es un vector muy grande de los cuales tengo que fijarme que hacer
	
	
	//  obs usar i filas, i columnas inv: forall i, j src[i][j] == dst[i][j-3] AND  i <h, j<w AND
//	blue == src[i][j] 	AND green == src[i][j+1] AND red == src[i][j+2] 
	
	for(int contadorFilas=0;contadorFilas<h;contadorFilas++){

		int desplazamiento=0;	
		
		for(int contadorColumnas =0;contadorColumnas<w;contadorColumnas++){
			//cada pixel esta compuesto por 3 bytes en la matriz de src
			// estan en el orden B| G | R |
			int blue = src[desplazamiento+(contadorFilas*src_row_size)];  
			int green = src[desplazamiento+(contadorFilas*src_row_size)+1];
			int red= src[desplazamiento+(contadorFilas*src_row_size)+2];
			
			int resultado = (red+(2*green)+blue)/4;
			
			dst[contadorColumnas+(contadorFilas*dst_row_size)] = resultado;
			desplazamiento = desplazamiento+3;
			
		}
	}
}
