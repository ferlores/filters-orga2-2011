void separar_canales_c (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size) {
    //recorre el src
    for(unsigned int i=m*n; i > 0; i--){
        *(dst_b++) = *(src++);
        *(dst_g++) = *(src++);
        *(dst_r++) = *(src++);
    }
}

