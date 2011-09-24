#include <getopt.h>
#include <highgui.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "filtros.h"
#include "tiempo.h"
#include "utils.h"

const char* nombre_programa;

void imprimir_ayuda ( );
void imprimir_tiempos_ejecucion(unsigned long long int start, unsigned long long int end, int cant_iteraciones);

void aplicar_invertir (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada);
void aplicar_monocromatizar_inf (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada);
void aplicar_monocromatizar_uno (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada);
void aplicar_normalizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada);
void aplicar_separar_canales (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada);
void aplicar_suavizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada);
void aplicar_umbralizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char* nomb_arch_entrada, unsigned char umbral_min, unsigned char umbral_max);

void initialize(unsigned char *dst, int m, int row_size);

int main( int argc, char** argv ) {
	int siguiente_opcion;

	// Opciones
	const char* const op_cortas = "hi:vt:";

	const struct option op_largas[] = {
		{ "help", 0, NULL, 'h' },
		{ "implementacion", 1, NULL, 'i' },
		{ "verbose", 0, NULL, 'v' },
		{ "tiempo", 1, NULL, 't' },
		{ NULL, 0, NULL, 0 }
	};

	// Parametros
	const char* nombre_implementacion = NULL;
	int cant_iteraciones = 0;

	// Flags de opciones
	int verbose = 0;
	int tiempo = 0;

	// Guardar nombre del programa para usarlo en la ayuda
	nombre_programa = argv[0];

	// Si se ejecuta sin parametros ni opciones
	if (argc == 1) {
		imprimir_ayuda ( );

		exit ( EXIT_SUCCESS );
	}

	// Procesar opciones
	while (1) {
		siguiente_opcion = getopt_long ( argc, argv, op_cortas, op_largas, NULL);

		// No hay mas opciones
		if ( siguiente_opcion == -1 )
			break;

		// Procesar opcion
		switch ( siguiente_opcion ) {
			case 'h' : /* -h o --help */
				imprimir_ayuda ( );
				exit ( EXIT_SUCCESS );
				break;
			case 'i' : /* -i o --implementacion */
				nombre_implementacion = optarg;
				break;
			case 't' : /* -t o --tiempo */
				tiempo = 1;
				cant_iteraciones = atoi ( optarg );
				break;
			case 'v' : /* -v o --verbose */
				verbose = 1;
				break;
			case '?' : /* opcion no valida */
				imprimir_ayuda ( );
				exit ( EXIT_SUCCESS );
			default : /* opcion no valida */
				abort ( );
		}
	}

	// Verifico nombre del proceso
	char *nomb_proceso = argv[optind++];

	if (nomb_proceso == NULL ||
		(strcmp(nomb_proceso, "invertir") != 0 &&
		strcmp(nomb_proceso, "monocromatizar_inf") != 0 &&
		strcmp(nomb_proceso, "monocromatizar_uno") != 0 &&
		strcmp(nomb_proceso, "normalizar") != 0 &&
		strcmp(nomb_proceso, "normalizar") != 0 &&
		strcmp(nomb_proceso, "separar_canales") != 0 &&
		strcmp(nomb_proceso, "suavizar") != 0 &&		
		strcmp(nomb_proceso, "umbralizar") != 0)) {
		imprimir_ayuda ( );

		exit ( EXIT_SUCCESS );
	}

	// Verifico nombre de la implementacion
	if (nombre_implementacion == NULL ||
		(strcmp(nombre_implementacion, "c") != 0 &&
		strcmp(nombre_implementacion, "asm") != 0)) {
		imprimir_ayuda ( );

		exit ( EXIT_SUCCESS );
	}

	// Verifico nombre de archivo
	const char *nomb_arch_entrada = argv[optind++];

	if (nomb_arch_entrada == NULL) {
		imprimir_ayuda ( );

		exit ( EXIT_SUCCESS );
	}

	if (access( nomb_arch_entrada, F_OK ) == -1) {
		printf("Error al intentar abrir el archivo: %s.\n", nomb_arch_entrada);
		
		exit ( EXIT_SUCCESS );
	}


	// Imprimo info
	if ( verbose ) {
		printf ( "Procesando imagen...\n");
		printf ( "  Filtro             : %s\n", nomb_proceso);
		printf ( "  Implementación     : %s\n", nombre_implementacion);
		printf ( "  Archivo de entrada : %s\n", nomb_arch_entrada);
	}

	// Procesar imagen
	if (strcmp(nomb_proceso, "invertir") == 0)
	{
		aplicar_invertir(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);
	}
	else if (strcmp(nomb_proceso, "monocromatizar_inf") == 0)
	{
		aplicar_monocromatizar_inf(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);	
	}
	else if (strcmp(nomb_proceso, "monocromatizar_uno") == 0)		
	{
		aplicar_monocromatizar_uno(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);
	}
	else if (strcmp(nomb_proceso, "normalizar") == 0)
	{
		aplicar_normalizar(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);
	}
	else if (strcmp(nomb_proceso, "separar_canales") == 0)
	{
		aplicar_separar_canales(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);
	}
	else if (strcmp(nomb_proceso, "suavizar") == 0)
	{
		aplicar_suavizar(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada);
	}
	else if (strcmp(nomb_proceso, "umbralizar") == 0)
	{
		int umbral_min;
		int umbral_max;

		umbral_min = atoi(argv[optind++]);
		umbral_max = atoi(argv[optind++]);

		if ( !(umbral_min >= 0 && umbral_min <=255) ||
			 !(umbral_max >= 0 && umbral_max <=255) ||
			 !(umbral_min <= umbral_max) ) {

			imprimir_ayuda();

			exit ( EXIT_SUCCESS );
		}

		aplicar_umbralizar(tiempo, cant_iteraciones, nombre_implementacion, nomb_arch_entrada, (unsigned char) umbral_min, (unsigned char) umbral_max);
	}

	return 0;
}

void imprimir_ayuda ( ) {
	printf ( "Uso: %s opciones filtro nombre_archivo_entrada parametros_filtro                                            \n", nombre_programa );
	printf ( "    Los filtros que se pueden aplicar son:                                                                  \n" );
	printf ( "       * invertir                                                                                           \n" );
	printf ( "       * monocromatizar_inf                                                                                 \n" );
	printf ( "       * monocromatizar_uno                                                                                 \n" );
	printf ( "       * normalizar                                                                                         \n" );
	printf ( "       * separar_canales                                                                                    \n" );
	printf ( "       * suavizar                                                                                           \n" );
	printf ( "       * umbralizar                                                                                         \n" );
	printf ( "           Parámetros     : umbral_minino [0, 255], umbral_maximo [0, 255] (umbral_minino <= umbral_maximo) \n" );
	printf ( "           Ejemplo de uso : %s -i c umbralizar lena.bmp 65 140                                              \n", nombre_programa );
	printf ( "                                                                                                            \n" );
	printf ( "    -h, --help                                 Imprime esta ayuda                                           \n" );
	printf ( "                                                                                                            \n" );
	printf ( "    -i, --implementacion NOMBRE_MODO           Implementación sobre la que se ejecutará el filtro           \n" );
	printf ( "                                               seleccionado. Los implementaciones disponibles               \n" );
	printf ( "                                               son: c, asm                                                  \n" );
	printf ( "                                                                                                            \n" );
	printf ( "    -t, --tiempo CANT_ITERACIONES              Mide el tiempo que tarda en ejecutar el filtro sobre la      \n" );
	printf ( "                                               imagen de entrada una cantidad de veces igual a              \n" );
	printf ( "                                               CANT_ITERACIONES                                             \n" );
	printf ( "                                                                                                            \n" );
	printf ( "    -v, --verbose                              Imprime información adicional                                \n" );
	printf ( "                                                                                                            \n" );
}

void imprimir_tiempos_ejecucion(unsigned long long int start, unsigned long long int end, int cant_iteraciones) {
	unsigned long long int cant_ciclos = end-start;
	
	printf("Tiempo de ejecución:\n");
	printf("  Comienzo                          : %llu\n", start);
	printf("  Fin                               : %llu\n", end);
	printf("  # iteraciones                     : %d\n", cant_iteraciones);
	printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
	printf("  # de ciclos insumidos por llamada : %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);	
}

void aplicar_invertir (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (invertir_fn_t) (unsigned char*, unsigned char*, int, int, int);

	invertir_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = invertir_c;
	} else {
		proceso = invertir_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.invertir.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void aplicar_monocromatizar_inf (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_COLOR)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);
        
        
    initialize( (unsigned char*)dst->imageData, dst->height, dst->widthStep);


	typedef void (monocromatizar_inf_fn_t) (unsigned char*, unsigned char*, int, int, int, int);

	monocromatizar_inf_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = monocromatizar_inf_c;
	} else {
		proceso = monocromatizar_inf_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.monocromatizar_inf.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void aplicar_monocromatizar_uno (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_COLOR)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (monocromatizar_uno_fn_t) (unsigned char*, unsigned char*, int, int, int, int);

	monocromatizar_uno_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = monocromatizar_uno_c;
	} else {
		proceso = monocromatizar_uno_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, dst->widthStep);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.monocromatizar_uno.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void aplicar_normalizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (normalizar_fn_t) (unsigned char*, unsigned char*, int, int, int);

	normalizar_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = normalizar_c;
	} else {
		proceso = normalizar_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.normalizar.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void aplicar_separar_canales (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst_r = 0;
	IplImage *dst_g = 0;
	IplImage *dst_b = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_COLOR)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst_r = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst_g = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst_b = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (separar_canales_fn_t) (unsigned char*, unsigned char*, unsigned char*, unsigned char*, int, int, int, int);

	separar_canales_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = separar_canales_c;
	} else {
		proceso = separar_canales_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst_r->imageData, (unsigned char*)dst_g->imageData, (unsigned char*)dst_b->imageData, src->height, src->width, src->widthStep, dst_r->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst_r->imageData, (unsigned char*)dst_g->imageData, (unsigned char*)dst_b->imageData, src->height, src->width, src->widthStep, dst_r->widthStep);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida_r[256];
	char nomb_arch_salida_g[256];
	char nomb_arch_salida_b[256];

	memset(nomb_arch_salida_r, 0, 256);
	memset(nomb_arch_salida_g, 0, 256);
	memset(nomb_arch_salida_b, 0, 256);

	sprintf(nomb_arch_salida_r, "%s.separar_canales.canal-r.%s.bmp", nomb_arch_entrada, nomb_impl);
	sprintf(nomb_arch_salida_g, "%s.separar_canales.canal-g.%s.bmp", nomb_arch_entrada, nomb_impl);
	sprintf(nomb_arch_salida_b, "%s.separar_canales.canal-b.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida_r, dst_r, NULL);
	cvSaveImage(nomb_arch_salida_g, dst_g, NULL);
	cvSaveImage(nomb_arch_salida_b, dst_b, NULL);

	cvReleaseImage(&dst_r);
	cvReleaseImage(&dst_g);
	cvReleaseImage(&dst_b);

	cvReleaseImage(&src);
}

void aplicar_suavizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (suavizar_fn_t) (unsigned char*, unsigned char*, int, int, int);

	suavizar_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = suavizar_c;
	} else {
		proceso = suavizar_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);
	}

	copiar_bordes((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep);

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.suavizar.%s.bmp", nomb_arch_entrada, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void aplicar_umbralizar (int tiempo, int cant_iteraciones, const char *nomb_impl, const char *nomb_arch_entrada, unsigned char umbral_min, unsigned char umbral_max) {
	IplImage *src = 0;
	IplImage *dst = 0;

	// Cargo la imagen
	if( (src = cvLoadImage (nomb_arch_entrada, CV_LOAD_IMAGE_GRAYSCALE)) == 0 )
		exit(EXIT_FAILURE);

	// Creo una IplImage para cada salida esperada
	if( (dst = cvCreateImage (cvGetSize (src), IPL_DEPTH_8U, 1) ) == 0 )
		exit(EXIT_FAILURE);

	typedef void (umbralizar_fn_t) (unsigned char*, unsigned char*, int, int, int, unsigned char, unsigned char);

	umbralizar_fn_t *proceso;

	if (strcmp(nomb_impl, "c") == 0) {
		proceso = umbralizar_c;
	} else {
		proceso = umbralizar_asm;
	}

	if (tiempo) {
		unsigned long long int start, end;

		MEDIR_TIEMPO_START(start);

		for(int i=0; i<cant_iteraciones; i++) {
			proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, umbral_min, umbral_max);
		}

		MEDIR_TIEMPO_STOP(end);

		imprimir_tiempos_ejecucion(start, end, cant_iteraciones);
	} else {
		proceso((unsigned char*)src->imageData, (unsigned char*)dst->imageData, src->height, src->width, src->widthStep, umbral_min, umbral_max);
	}

	// Guardo imagen y libero las imagenes
	char nomb_arch_salida[256];

	memset(nomb_arch_salida, 0, 256);

	sprintf(nomb_arch_salida, "%s.umbralizar.min-%d.max-%d.%s.bmp", nomb_arch_entrada, (int) umbral_min, (int) umbral_max, nomb_impl);

	cvSaveImage(nomb_arch_salida, dst, NULL);

	cvReleaseImage(&src);
	cvReleaseImage(&dst);
}

void initialize(unsigned char *dst, int n, int row_size){
    for(int f = 0 ; f < n*row_size; f++) {
        dst[f] = 255;
    }
}
