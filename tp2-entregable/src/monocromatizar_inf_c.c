#define max(a, b) ((a)>(b))?(a):(b)

void monocromatizar_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size) {
	
	for(int contadorFilas=0; contadorFilas<h;contadorFilas++){
		int desplazamiento=0;
		
		//cada pixel esta compuesto por 3 bytes en la matriz de src
			// estan en el orden B| G | R |
		for(int contadorColumnas=0;	contadorColumnas<w;contadorColumnas++){
			int blue = src[desplazamiento+(contadorFilas*src_row_size)];  
			int green = src[desplazamiento+(contadorFilas*src_row_size)+1];
			int red= src[desplazamiento+(contadorFilas*src_row_size)+2];
			
			int resultado = max(red,max(blue,green));
			
			dst[contadorColumnas+(contadorFilas*dst_row_size)] = resultado;
			desplazamiento = desplazamiento+3;
		}
	}
}
