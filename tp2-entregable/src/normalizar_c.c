void normalizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size) {
    unsigned char max = 0;
    unsigned char min = 255;
    
    //busca max y min
    for(unsigned int i=0; i < m; i++){
        for(unsigned int j=0; j < n; j++){
            unsigned char val= src[i*row_size+j];
            if(val > max) max = val;
            if(val < min) min = val;
        }
    }
    
    float k = 255/(float)(max-min);
    
    //modifica src
    for(unsigned int i=0; i < m; i++){
        for(unsigned int j=0; j < n; j++){
            
            dst[i*row_size +j] = k* (float)( src[i*row_size+j] - min );
        }
    }
    //printf("min:%d, max:%d, k:%30.30f\n", min, max, k);
}
