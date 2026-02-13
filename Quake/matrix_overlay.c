/*
 * matrix_overlay.c - Matrix Digital Rain Overlay Effect Implementation
 * Proyecto Quake-Matrix por Fernando Cañete
 * 
 * Compatible con OpenGL fixed pipeline de QuakeSpasm
 */

#include "matrix_overlay.h"
#include <stdlib.h>
#include <math.h>
#include <time.h>

matrixoverlay_t matrixoverlay;

cvar_t r_matrix_overlay = {"r_matrix_overlay", "1", CVAR_ARCHIVE};
cvar_t r_matrix_overlay_intensity = {"r_matrix_overlay_intensity", "0.7", CVAR_ARCHIVE};
cvar_t r_matrix_overlay_speed = {"r_matrix_overlay_speed", "1.0", CVAR_ARCHIVE};
cvar_t r_matrix_overlay_density = {"r_matrix_overlay_density", "0.6", CVAR_ARCHIVE};

#define MATRIX_COLUMNS 80
#define GLYPH_TEX_SIZE 256
#define GLYPH_CHARS 64

// Simula caracteres Matrix (katakana simplificado)
static const char matrix_chars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZｦｧｨｩｪｫｬｭｮｯ";

// Generar número aleatorio
static float randf(void)
{
    return (float)rand() / (float)RAND_MAX;
}

// Generar textura procedural de glyphs Matrix
void MatrixOverlay_GenerateGlyphTexture(void)
{
    int x, y, i;
    int glyph_w = GLYPH_TEX_SIZE / 8;
    int glyph_h = GLYPH_TEX_SIZE / 8;
    
    if (!matrixoverlay.glyph_data)
        return;
    
    // Limpiar textura
    memset(matrixoverlay.glyph_data, 0, GLYPH_TEX_SIZE * GLYPH_TEX_SIZE * 4);
    
    // Generar glyphs simples
    for (i = 0; i < GLYPH_CHARS; i++)
    {
        int gx = (i % 8) * glyph_w;
        int gy = (i / 8) * glyph_h;
        
        // Dibujar glyph simple (líneas verticales y horizontales)
        for (y = 0; y < glyph_h; y++)
        {
            for (x = 0; x < glyph_w; x++)
            {
                int px = gx + x;
                int py = gy + y;
                int idx = (py * GLYPH_TEX_SIZE + px) * 4;
                
                // Patrón de glyph (simplificado)
                if ((x == glyph_w/2 && y > glyph_h/4 && y < 3*glyph_h/4) ||
                    (y == glyph_h/2 && x > glyph_w/4 && x < 3*glyph_w/4) ||
                    (randf() > 0.8))
                {
                    matrixoverlay.glyph_data[idx + 0] = 0;      // R
                    matrixoverlay.glyph_data[idx + 1] = 255;    // G
                    matrixoverlay.glyph_data[idx + 2] = 0;      // B
                    matrixoverlay.glyph_data[idx + 3] = 255;    // A
                }
            }
        }
    }
    
    // Cargar textura en OpenGL
    glBindTexture(GL_TEXTURE_2D, matrixoverlay.matrix_texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, GLYPH_TEX_SIZE, GLYPH_TEX_SIZE, 
                 0, GL_RGBA, GL_UNSIGNED_BYTE, matrixoverlay.glyph_data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

// Inicializar overlay Matrix
void MatrixOverlay_Init(void)
{
    int i;
    
    Con_Printf("Initializing Matrix Overlay System...\n");
    
    memset(&matrixoverlay, 0, sizeof(matrixoverlay));
    
    // Registrar cvars
    Cvar_RegisterVariable(&r_matrix_overlay);
    Cvar_RegisterVariable(&r_matrix_overlay_intensity);
    Cvar_RegisterVariable(&r_matrix_overlay_speed);
    Cvar_RegisterVariable(&r_matrix_overlay_density);
    
    // Inicializar random
    srand((unsigned int)time(NULL));
    
    // Configurar columnas
    matrixoverlay.num_columns = MATRIX_COLUMNS;
    matrixoverlay.column_speeds = (float *)malloc(MATRIX_COLUMNS * sizeof(float));
    matrixoverlay.column_offsets = (float *)malloc(MATRIX_COLUMNS * sizeof(float));
    
    if (!matrixoverlay.column_speeds || !matrixoverlay.column_offsets)
    {
        Con_Printf("MatrixOverlay: Failed to allocate column data\n");
        return;
    }
    
    // Inicializar columnas con velocidades y offsets aleatorios
    for (i = 0; i < MATRIX_COLUMNS; i++)
    {
        matrixoverlay.column_speeds[i] = 0.5f + randf() * 1.5f;
        matrixoverlay.column_offsets[i] = randf() * 100.0f;
    }
    
    // Crear buffer para textura de glyphs
    matrixoverlay.glyph_texture_size = GLYPH_TEX_SIZE;
    matrixoverlay.glyph_data = (unsigned char *)malloc(GLYPH_TEX_SIZE * GLYPH_TEX_SIZE * 4);
    
    if (!matrixoverlay.glyph_data)
    {
        Con_Printf("MatrixOverlay: Failed to allocate glyph texture data\n");
        return;
    }
    
    // Generar textura OpenGL
    glGenTextures(1, (GLuint *)&matrixoverlay.matrix_texture);
    MatrixOverlay_GenerateGlyphTexture();
    
    matrixoverlay.initialized = true;
    matrixoverlay.enabled = r_matrix_overlay.value > 0;
    matrixoverlay.intensity = r_matrix_overlay_intensity.value;
    matrixoverlay.time = 0.0f;
    
    Con_Printf("Matrix Overlay System initialized\n");
}

// Cerrar overlay
void MatrixOverlay_Shutdown(void)
{
    if (!matrixoverlay.initialized)
        return;
    
    if (matrixoverlay.matrix_texture)
    {
        glDeleteTextures(1, (GLuint *)&matrixoverlay.matrix_texture);
        matrixoverlay.matrix_texture = 0;
    }
    
    if (matrixoverlay.column_speeds)
    {
        free(matrixoverlay.column_speeds);
        matrixoverlay.column_speeds = NULL;
    }
    
    if (matrixoverlay.column_offsets)
    {
        free(matrixoverlay.column_offsets);
        matrixoverlay.column_offsets = NULL;
    }
    
    if (matrixoverlay.glyph_data)
    {
        free(matrixoverlay.glyph_data);
        matrixoverlay.glyph_data = NULL;
    }
    
    matrixoverlay.initialized = false;
    Con_Printf("Matrix Overlay System shut down\n");
}

// Actualizar overlay
void MatrixOverlay_Update(float frametime)
{
    int i;
    
    if (!matrixoverlay.initialized)
        return;
    
    matrixoverlay.time += frametime * r_matrix_overlay_speed.value;
    matrixoverlay.intensity = r_matrix_overlay_intensity.value;
    matrixoverlay.enabled = r_matrix_overlay.value > 0;
    
    // Actualizar offsets de columnas
    for (i = 0; i < matrixoverlay.num_columns; i++)
    {
        matrixoverlay.column_offsets[i] += frametime * matrixoverlay.column_speeds[i] * 50.0f;
        
        // Wrap around
        if (matrixoverlay.column_offsets[i] > 100.0f)
            matrixoverlay.column_offsets[i] -= 100.0f;
    }
}

// Dibujar una columna de lluvia Matrix
void MatrixOverlay_DrawColumn(int column, float screen_height)
{
    float x = (float)column / (float)matrixoverlay.num_columns;
    float col_width = 1.0f / (float)matrixoverlay.num_columns;
    float offset = matrixoverlay.column_offsets[column] / 100.0f;
    float trail_length = 0.3f + randf() * 0.2f;
    int num_chars = 15;
    int i;
    
    for (i = 0; i < num_chars; i++)
    {
        float y = fmodf(offset + (float)i / (float)num_chars, 1.0f);
        float char_height = 1.0f / 30.0f;
        float brightness = 1.0f - (float)i / (float)num_chars;
        
        // Verde Matrix con brillo decreciente
        float g = brightness;
        float r = brightness * 0.2f;
        float b = brightness * 0.1f;
        
        // Punta brillante
        if (i == 0)
        {
            r = g = b = 1.0f;
        }
        
        // Aplicar intensidad global
        r *= matrixoverlay.intensity;
        g *= matrixoverlay.intensity;
        b *= matrixoverlay.intensity;
        
        // Dibujar quad con glyph
        glColor4f(r, g, b, brightness * matrixoverlay.intensity);
        
        glBegin(GL_QUADS);
        glTexCoord2f(randf(), randf());
        glVertex2f(x, y);
        
        glTexCoord2f(randf(), randf() + 0.125f);
        glVertex2f(x + col_width, y);
        
        glTexCoord2f(randf() + 0.125f, randf() + 0.125f);
        glVertex2f(x + col_width, y + char_height);
        
        glTexCoord2f(randf() + 0.125f, randf());
        glVertex2f(x, y + char_height);
        glEnd();
    }
}

// Dibujar overlay completo
void MatrixOverlay_Draw(void)
{
    int i;
    
    if (!matrixoverlay.initialized || !matrixoverlay.enabled)
        return;
    
    // Guardar estado OpenGL
    glPushAttrib(GL_ALL_ATTRIB_BITS);
    
    // Configurar para overlay 2D
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0, 1, 1, 0, -1, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    // Configurar blending para overlay
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glDisable(GL_DEPTH_TEST);
    
    // Activar textura de glyphs
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, matrixoverlay.matrix_texture);
    
    // Dibujar columnas
    for (i = 0; i < matrixoverlay.num_columns; i++)
    {
        if (randf() < r_matrix_overlay_density.value)
            MatrixOverlay_DrawColumn(i, 1.0f);
    }
    
    // Overlay verde sutil sobre todo
    glDisable(GL_TEXTURE_2D);
    glColor4f(0.0f, 0.2f, 0.0f, 0.05f * matrixoverlay.intensity);
    glBegin(GL_QUADS);
    glVertex2f(0, 0);
    glVertex2f(1, 0);
    glVertex2f(1, 1);
    glVertex2f(0, 1);
    glEnd();
    
    // Restaurar estado OpenGL
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    
    glPopAttrib();
}
