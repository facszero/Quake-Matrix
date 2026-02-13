/*
 * matrix_overlay.h - Matrix Digital Rain Overlay Effect
 * Proyecto Quake-Matrix por Fernando Cañete
 * 
 * Sistema de overlay Matrix compatible con OpenGL fixed pipeline
 */

#ifndef MATRIX_OVERLAY_H
#define MATRIX_OVERLAY_H

#include "quakedef.h"
#include "glquake.h"

// Estado del overlay Matrix
typedef struct {
    qboolean initialized;
    qboolean enabled;
    float intensity;
    float time;
    
    // Textura de código Matrix
    int matrix_texture;
    
    // Parámetros de animación
    float *column_speeds;
    float *column_offsets;
    int num_columns;
    
    // Buffer para generar texturas procedurales
    unsigned char *glyph_data;
    int glyph_texture_size;
} matrixoverlay_t;

extern matrixoverlay_t matrixoverlay;

// Variables de consola
extern cvar_t r_matrix_overlay;
extern cvar_t r_matrix_overlay_intensity;
extern cvar_t r_matrix_overlay_speed;
extern cvar_t r_matrix_overlay_density;

// Funciones públicas
void MatrixOverlay_Init(void);
void MatrixOverlay_Shutdown(void);
void MatrixOverlay_Update(float frametime);
void MatrixOverlay_Draw(void);

// Utilidades
void MatrixOverlay_GenerateGlyphTexture(void);
void MatrixOverlay_DrawColumn(int column, float screen_height);

#endif // MATRIX_OVERLAY_H
