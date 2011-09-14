void separar_canales_c (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size) {
    //recorre el src
    for(unsigned int i=0; i < m; i++){
        for(unsigned int j=0; j < n; j++){
            dst_b[i*dst_row_size+j] = src[i*src_row_size+3*j];
            dst_g[i*dst_row_size+j] = src[i*src_row_size+3*j+1];
            dst_r[i*dst_row_size+j] = src[i*src_row_size+3*j+2];
        }
    }
    /*********************************************
     * Implementacion con mejor acceso a memoria
     *********************************************/
     
    /*
    src_row_size = src_row_size-3*n;
    dst_row_size = dst_row_size-n;

    //recorre el src
    for(unsigned int i=m; i > 0; i--){
        for(unsigned int j=n; j > 0; j--){
            *(dst_b++) = *(src++);
            *(dst_g++) = *(src++);
            *(dst_r++) = *(src++);
        }
        
        src += src_row_size;
        dst_b += dst_row_size;
        dst_g += dst_row_size;
        dst_r += dst_row_size;
        
    }
    */
    
}

