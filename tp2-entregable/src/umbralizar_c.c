void umbralizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size, unsigned char umbral_min, unsigned char umbral_max) {
      for(int f = 0 ; f < m ; f++) {
        for(int c = 0 ; c < n ; c++) {
            
			if(src[ c + (row_size * f)] <= umbral_min){
				dst[c + (row_size * f)] = 0;
                
			}else if(src[ c + (row_size * f)] > umbral_max){
                dst[c + (row_size * f)] = 255;
                
            }else{
                dst[c + (row_size * f)] = 128;
            }
		}
	}
}
