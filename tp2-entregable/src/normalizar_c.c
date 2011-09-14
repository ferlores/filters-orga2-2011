void normalizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size) {
    unsigned char max = 0;
    unsigned char min = 255;
    unsigned char *src2 = src;
    
    //busca max y min
    for(unsigned int i=0; i < m; i++){
        for(unsigned int j=0; j < n; j++){
            unsigned char val= src[i*row_size+j];
            if(val > max) max = val;
            if(val < min) min = val;
        }
    }
    //modifica src
    for(unsigned int i=0; i < m; i++){
        for(unsigned int j=0; j < n; j++){
            dst[i*row_size +j] = 255 * ( src[i*row_size+j] - min ) / ( max - min );
        }
    }
}
