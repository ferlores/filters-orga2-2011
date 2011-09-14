void invertir_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size) {

   
        for(int f = 0 ; f < m ; f++) {
                for(int c = 0 ; c < n ; c++) {
                        dst[ c + (row_size * f)] = 255 - src[c + (row_size * f)];
                }
        }
}
