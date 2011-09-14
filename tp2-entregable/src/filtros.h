#ifndef __FILTROS__H__
#define __FILTROS__H__

void invertir_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void monocromatizar_inf_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void monocromatizar_uno_c(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void normalizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void separar_canales_c (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size);
void suavizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void umbralizar_c (unsigned char *src, unsigned char *dst, int m, int n, int row_size, unsigned char umbral_min, unsigned char umbral_max);

void invertir_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void monocromatizar_inf_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void monocromatizar_uno_asm(unsigned char *src, unsigned char *dst, int h, int w, int src_row_size, int dst_row_size);
void normalizar_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void separar_canales_asm (unsigned char *src, unsigned char *dst_r, unsigned char *dst_g, unsigned char *dst_b, int m, int n, int src_row_size, int dst_row_size);
void suavizar_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size);
void umbralizar_asm (unsigned char *src, unsigned char *dst, int m, int n, int row_size, unsigned char umbral_min, unsigned char umbral_max);

#endif /* !__FILTROS__H__ */
