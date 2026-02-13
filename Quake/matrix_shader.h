/*
 * matrix_shader.h - Matrix Digital Rain Shader System
 * Proyecto Quake-Matrix por Fernando Cañete
 * 
 * Sistema de shaders para el efecto de "lluvia digital" de Matrix
 */

#ifndef MATRIX_SHADER_H
#define MATRIX_SHADER_H

#include "quakedef.h"
#include "glquake.h"

// Estado del sistema Matrix
typedef struct {
    GLuint program;
    GLuint vertexShader;
    GLuint fragmentShader;
    
    // Ubicaciones de uniforms
    GLint loc_ModelViewProjection;
    GLint loc_ModelView;
    GLint loc_Projection;
    GLint loc_Time;
    GLint loc_Texture;
    GLint loc_Resolution;
    GLint loc_MatrixIntensity;
    GLint loc_EnableMatrix;
    
    // Ubicaciones de atributos
    GLint loc_Position;
    GLint loc_TexCoord;
    GLint loc_Normal;
    
    // Estado
    qboolean initialized;
    qboolean enabled;
    float intensity;
    float time;
} matrixshader_t;

extern matrixshader_t matrixshader;

// Variables de consola
extern cvar_t r_matrix;
extern cvar_t r_matrix_intensity;

// Funciones públicas
void MatrixShader_Init(void);
void MatrixShader_Shutdown(void);
void MatrixShader_Enable(void);
void MatrixShader_Disable(void);
void MatrixShader_Update(float frametime);
void MatrixShader_SetUniforms(void);

// Utilidades de shader
GLuint MatrixShader_LoadShader(GLenum type, const char *source);
GLuint MatrixShader_CreateProgram(GLuint vertexShader, GLuint fragmentShader);
qboolean MatrixShader_LoadFromFile(const char *filename, char **source);

#endif // MATRIX_SHADER_H
