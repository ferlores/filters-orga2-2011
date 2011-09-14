void suavizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size) {

    for(unsigned int i=1; i < m-1; i++){
        for(unsigned int j=1; j < n-1 ; j++){
            float res=0;
            
            res += (src[(i-1)*row_size+(j-1)] + 2*src[(i-1)*row_size+j] + src[(i-1)*row_size+(j+1)])/16;
            res += (2*src[i*row_size+(j-1)] + 4*src[i*row_size+j] + 2*src[i*row_size+(j+1)])/16;
            res += (src[(i+1)*row_size+(j-1)] + 2*src[(i+1)*row_size+j] + src[(i+1)*row_size+(j+1)])/16;
            
            dst[i*row_size+j] = (unsigned char)res;
        }
    }
}
