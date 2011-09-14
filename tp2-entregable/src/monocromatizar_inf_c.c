#define max(a, b) ((a)>(b))?(a):(b)

void monocromatizar_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size) {
	int contadorFilas=0;
	int contadorColumnas=0;
	int desplazamiento=0; // me pasan una "martiz" en realidad es un vector muy grande de los cuales tengo que fijarme que hacer
	int desplazamientoEnDestino=0;

	while(contadorFilas<h){
		contadorColumnas=0;
		desplazamiento=0;
		desplazamientoEnDestino=0;	
		
		while(contadorColumnas<w){//cada pixel esta compuesto por 3 bytes en la matriz de src
			// estan en el orden B| G | R |
			int blue = src[desplamiento+(contadorFilas*src_row_size)];  
			int green = src[desplazamiento+(contadorFilas*src_row_size)+1];
			int red= src[desplazamiento+(contadorFilas*src_row_size)+2];
			
			int maxTemporal = max(blue,green);
			int resultado = max(red,maxTemporal);
			
			dst[desplazamientoEnDestino+(contadorFilas*dst_row_size)] = resultado;

			desplazamiento = desplazamiento+3;
			
			desplazamientoEnDestino++;
			contadorColumnas++;
		}
		contadorFilas++;
	}
}
