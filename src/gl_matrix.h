/*
Copyright (C) 2026 Fernando Cañete

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

// gl_matrix.h - Sistema de renderizado Matrix

#ifndef GL_MATRIX_H
#define GL_MATRIX_H

// Estructura para el shader de Matrix
typedef struct {
    GLuint program;
    GLuint vertexShader;
    GLuint fragmentShader;
    
    // Locations de uniforms
    GLint u_modelViewProjection;
    GLint u_modelView;
    GLint u_normalMatrix;
    GLint u_texture;
    GLint u_charAtlas;
    GLint u_time;
    GLint u_matrixColor;
    GLint u_rainSpeed;
    GLint u_charDensity;
    GLint u_glowIntensity;
    GLint u_trailLength;
    GLint u_matrixEnabled;
    
    // Locations de atributos
    GLint a_position;
    GLint a_texcoord;
    GLint a_normal;
    GLint a_color;
} matrixshader_t;

// Estructura para el atlas de caracteres
typedef struct {
    GLuint texture;
    int width;
    int height;
    int charSize;
    qboolean loaded;
} charAtlas_t;

// Estructura para configuración Matrix
typedef struct {
    qboolean enabled;
    float rainSpeed;
    float charDensity;
    vec3_t color;
    float glowIntensity;
    float trailLength;
} matrixConfig_t;

// Variables globales
extern matrixshader_t matrixShader;
extern charAtlas_t charAtlas;
extern matrixConfig_t matrixConfig;

// CVars
extern cvar_t matrix_enable;
extern cvar_t matrix_rainspeed;
extern cvar_t matrix_density;
extern cvar_t matrix_color_r;
extern cvar_t matrix_color_g;
extern cvar_t matrix_color_b;
extern cvar_t matrix_glow;
extern cvar_t matrix_trail_length;

// Funciones principales
void Matrix_Init(void);
void Matrix_Shutdown(void);
void Matrix_UpdateConfig(void);

// Gestión de shaders
qboolean Matrix_LoadShaders(void);
void Matrix_UnloadShaders(void);
GLuint Matrix_CompileShader(GLenum type, const char *source);
GLuint Matrix_LinkProgram(GLuint vertShader, GLuint fragShader);

// Gestión de atlas de caracteres
qboolean Matrix_LoadCharAtlas(void);
void Matrix_UnloadCharAtlas(void);
qboolean Matrix_GenerateCharAtlas(void);

// Renderizado
void Matrix_BeginFrame(void);
void Matrix_EndFrame(void);
void Matrix_SetMatrices(void);
void Matrix_BindShader(void);
void Matrix_UnbindShader(void);

// Utilidades
const char* Matrix_LoadShaderFile(const char *filename);
void Matrix_PrintShaderLog(GLuint shader);
void Matrix_PrintProgramLog(GLuint program);

#endif // GL_MATRIX_H
