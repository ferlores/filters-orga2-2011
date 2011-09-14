void normalizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size) {
    unsigned char max = 0;
    unsigned char min = 255;
    unsigned char *src2 = src;
    
    //busca max y min
    for(unsigned int i=m*n; i > 0; i--){
        if(*(src) > max) max = *(src);
        if(*(src) < min) min = *(src);
        src++;
    }

    //modifica src
    for(unsigned int i=m*n; i > 0; i--){
        *(dst++) = 255 * ( *(src2++) - min ) / ( max - min );
    }
}

