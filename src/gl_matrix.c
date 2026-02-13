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

// gl_matrix.c - Implementación del sistema de renderizado Matrix

#include "quakedef.h"
#include "gl_matrix.h"

// Variables globales
matrixshader_t matrixShader;
charAtlas_t charAtlas;
matrixConfig_t matrixConfig;

// CVars
cvar_t matrix_enable = {"matrix_enable", "1", CVAR_ARCHIVE};
cvar_t matrix_rainspeed = {"matrix_rainspeed", "2.5", CVAR_ARCHIVE};
cvar_t matrix_density = {"matrix_density", "20.0", CVAR_ARCHIVE};
cvar_t matrix_color_r = {"matrix_color_r", "0.0", CVAR_ARCHIVE};
cvar_t matrix_color_g = {"matrix_color_g", "1.0", CVAR_ARCHIVE};
cvar_t matrix_color_b = {"matrix_color_b", "0.2", CVAR_ARCHIVE};
cvar_t matrix_glow = {"matrix_glow", "1.2", CVAR_ARCHIVE};
cvar_t matrix_trail_length = {"matrix_trail_length", "0.6", CVAR_ARCHIVE};

static float matrixTime = 0.0f;

/*
================
Matrix_Init

Inicializa el sistema Matrix
================
*/
void Matrix_Init(void)
{
    Con_Printf("Initializing Matrix rendering system...\n");
    
    // Registrar CVars
    Cvar_RegisterVariable(&matrix_enable);
    Cvar_RegisterVariable(&matrix_rainspeed);
    Cvar_RegisterVariable(&matrix_density);
    Cvar_RegisterVariable(&matrix_color_r);
    Cvar_RegisterVariable(&matrix_color_g);
    Cvar_RegisterVariable(&matrix_color_b);
    Cvar_RegisterVariable(&matrix_glow);
    Cvar_RegisterVariable(&matrix_trail_length);
    
    // Inicializar configuración
    memset(&matrixShader, 0, sizeof(matrixShader));
    memset(&charAtlas, 0, sizeof(charAtlas));
    memset(&matrixConfig, 0, sizeof(matrixConfig));
    
    Matrix_UpdateConfig();
    
    // Cargar shaders
    if (!Matrix_LoadShaders())
    {
        Con_Printf("WARNING: Failed to load Matrix shaders\n");
        matrix_enable.value = 0;
        return;
    }
    
    // Cargar atlas de caracteres
    if (!Matrix_LoadCharAtlas())
    {
        Con_Printf("WARNING: Failed to load character atlas, generating...\n");
        if (!Matrix_GenerateCharAtlas())
        {
            Con_Printf("ERROR: Failed to generate character atlas\n");
            matrix_enable.value = 0;
            return;
        }
    }
    
    Con_Printf("Matrix rendering system initialized successfully\n");
}

/*
================
Matrix_Shutdown

Libera recursos del sistema Matrix
================
*/
void Matrix_Shutdown(void)
{
    Matrix_UnloadShaders();
    Matrix_UnloadCharAtlas();
}

/*
================
Matrix_UpdateConfig

Actualiza la configuración desde CVars
================
*/
void Matrix_UpdateConfig(void)
{
    matrixConfig.enabled = (matrix_enable.value != 0);
    matrixConfig.rainSpeed = matrix_rainspeed.value;
    matrixConfig.charDensity = matrix_density.value;
    matrixConfig.color[0] = matrix_color_r.value;
    matrixConfig.color[1] = matrix_color_g.value;
    matrixConfig.color[2] = matrix_color_b.value;
    matrixConfig.glowIntensity = matrix_glow.value;
    matrixConfig.trailLength = matrix_trail_length.value;
}

/*
================
Matrix_LoadShaderFile

Carga un archivo de shader desde disco
================
*/
const char* Matrix_LoadShaderFile(const char *filename)
{
    char path[256];
    FILE *f;
    long length;
    char *source;
    
    q_snprintf(path, sizeof(path), "assets/shaders/%s", filename);
    
    f = fopen(path, "rb");
    if (!f)
    {
        Con_Printf("ERROR: Could not open shader file: %s\n", path);
        return NULL;
    }
    
    fseek(f, 0, SEEK_END);
    length = ftell(f);
    fseek(f, 0, SEEK_SET);
    
    source = (char*)malloc(length + 1);
    if (!source)
    {
        fclose(f);
        return NULL;
    }
    
    fread(source, 1, length, f);
    source[length] = '\0';
    fclose(f);
    
    return source;
}

/*
================
Matrix_PrintShaderLog

Imprime el log de compilación de un shader
================
*/
void Matrix_PrintShaderLog(GLuint shader)
{
    GLint logLength;
    char *log;
    
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 1)
    {
        log = (char*)malloc(logLength);
        glGetShaderInfoLog(shader, logLength, NULL, log);
        Con_Printf("Shader compile log:\n%s\n", log);
        free(log);
    }
}

/*
================
Matrix_PrintProgramLog

Imprime el log de linkeo de un programa
================
*/
void Matrix_PrintProgramLog(GLuint program)
{
    GLint logLength;
    char *log;
    
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 1)
    {
        log = (char*)malloc(logLength);
        glGetProgramInfoLog(program, logLength, NULL, log);
        Con_Printf("Program link log:\n%s\n", log);
        free(log);
    }
}

/*
================
Matrix_CompileShader

Compila un shader GLSL
================
*/
GLuint Matrix_CompileShader(GLenum type, const char *source)
{
    GLuint shader;
    GLint compiled;
    
    shader = glCreateShader(type);
    if (shader == 0)
    {
        Con_Printf("ERROR: glCreateShader failed\n");
        return 0;
    }
    
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled)
    {
        Con_Printf("ERROR: Shader compilation failed\n");
        Matrix_PrintShaderLog(shader);
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

/*
================
Matrix_LinkProgram

Linkea un programa GLSL
================
*/
GLuint Matrix_LinkProgram(GLuint vertShader, GLuint fragShader)
{
    GLuint program;
    GLint linked;
    
    program = glCreateProgram();
    if (program == 0)
    {
        Con_Printf("ERROR: glCreateProgram failed\n");
        return 0;
    }
    
    glAttachShader(program, vertShader);
    glAttachShader(program, fragShader);
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked)
    {
        Con_Printf("ERROR: Program linking failed\n");
        Matrix_PrintProgramLog(program);
        glDeleteProgram(program);
        return 0;
    }
    
    return program;
}

/*
================
Matrix_LoadShaders

Carga y compila los shaders de Matrix
================
*/
qboolean Matrix_LoadShaders(void)
{
    const char *vertSource, *fragSource;
    
    Con_Printf("Loading Matrix shaders...\n");
    
    // Cargar código fuente
    vertSource = Matrix_LoadShaderFile("matrix_vertex.glsl");
    if (!vertSource)
    {
        Con_Printf("ERROR: Failed to load vertex shader\n");
        return false;
    }
    
    fragSource = Matrix_LoadShaderFile("matrix_fragment.glsl");
    if (!fragSource)
    {
        Con_Printf("ERROR: Failed to load fragment shader\n");
        free((void*)vertSource);
        return false;
    }
    
    // Compilar shaders
    matrixShader.vertexShader = Matrix_CompileShader(GL_VERTEX_SHADER, vertSource);
    free((void*)vertSource);
    
    if (matrixShader.vertexShader == 0)
    {
        free((void*)fragSource);
        return false;
    }
    
    matrixShader.fragmentShader = Matrix_CompileShader(GL_FRAGMENT_SHADER, fragSource);
    free((void*)fragSource);
    
    if (matrixShader.fragmentShader == 0)
    {
        glDeleteShader(matrixShader.vertexShader);
        return false;
    }
    
    // Linkear programa
    matrixShader.program = Matrix_LinkProgram(matrixShader.vertexShader, 
                                              matrixShader.fragmentShader);
    if (matrixShader.program == 0)
    {
        glDeleteShader(matrixShader.vertexShader);
        glDeleteShader(matrixShader.fragmentShader);
        return false;
    }
    
    // Obtener locations de uniforms
    matrixShader.u_modelViewProjection = glGetUniformLocation(matrixShader.program, 
                                                               "u_modelViewProjection");
    matrixShader.u_modelView = glGetUniformLocation(matrixShader.program, 
                                                     "u_modelView");
    matrixShader.u_normalMatrix = glGetUniformLocation(matrixShader.program, 
                                                        "u_normalMatrix");
    matrixShader.u_texture = glGetUniformLocation(matrixShader.program, "u_texture");
    matrixShader.u_charAtlas = glGetUniformLocation(matrixShader.program, "u_charAtlas");
    matrixShader.u_time = glGetUniformLocation(matrixShader.program, "u_time");
    matrixShader.u_matrixColor = glGetUniformLocation(matrixShader.program, "u_matrixColor");
    matrixShader.u_rainSpeed = glGetUniformLocation(matrixShader.program, "u_rainSpeed");
    matrixShader.u_charDensity = glGetUniformLocation(matrixShader.program, "u_charDensity");
    matrixShader.u_glowIntensity = glGetUniformLocation(matrixShader.program, "u_glowIntensity");
    matrixShader.u_trailLength = glGetUniformLocation(matrixShader.program, "u_trailLength");
    matrixShader.u_matrixEnabled = glGetUniformLocation(matrixShader.program, "u_matrixEnabled");
    
    // Obtener locations de atributos
    matrixShader.a_position = glGetAttribLocation(matrixShader.program, "in_position");
    matrixShader.a_texcoord = glGetAttribLocation(matrixShader.program, "in_texcoord");
    matrixShader.a_normal = glGetAttribLocation(matrixShader.program, "in_normal");
    matrixShader.a_color = glGetAttribLocation(matrixShader.program, "in_color");
    
    Con_Printf("Matrix shaders loaded successfully\n");
    return true;
}

/*
================
Matrix_UnloadShaders

Libera los recursos de los shaders
================
*/
void Matrix_UnloadShaders(void)
{
    if (matrixShader.program)
    {
        glDeleteProgram(matrixShader.program);
        matrixShader.program = 0;
    }
    
    if (matrixShader.vertexShader)
    {
        glDeleteShader(matrixShader.vertexShader);
        matrixShader.vertexShader = 0;
    }
    
    if (matrixShader.fragmentShader)
    {
        glDeleteShader(matrixShader.fragmentShader);
        matrixShader.fragmentShader = 0;
    }
}

/*
================
Matrix_BeginFrame

Inicia el renderizado Matrix para el frame actual
================
*/
void Matrix_BeginFrame(void)
{
    if (!matrixConfig.enabled)
        return;
    
    // Actualizar tiempo
    matrixTime += host_frametime;
    
    // Actualizar configuración desde CVars
    Matrix_UpdateConfig();
    
    // Activar shader
    Matrix_BindShader(&matrixShader);
    
    // Pasar matrices al shader
    Matrix_SetMatrices();
}

/*
================
Matrix_EndFrame

Finaliza el renderizado Matrix
================
*/
void Matrix_EndFrame(void)
{
    if (!matrixConfig.enabled)
        return;
    
    // Desactivar shader (volver a fixed pipeline)
    glUseProgram(0);
}

/*
================
Matrix_SetMatrices

Pasa las matrices de transformación al shader
================
*/
void Matrix_SetMatrices(void)
{
    GLfloat modelview[16];
    GLfloat projection[16];
    GLfloat mvp[16];
    GLint loc;
    int i, j;
    
    // Obtener matrices actuales de OpenGL
    glGetFloatv(GL_MODELVIEW_MATRIX, modelview);
    glGetFloatv(GL_PROJECTION_MATRIX, projection);
    
    // Calcular MVP = Projection * ModelView
    for (i = 0; i < 4; i++)
    {
        for (j = 0; j < 4; j++)
        {
            mvp[i*4 + j] = 
                projection[i*4 + 0] * modelview[0*4 + j] +
                projection[i*4 + 1] * modelview[1*4 + j] +
                projection[i*4 + 2] * modelview[2*4 + j] +
                projection[i*4 + 3] * modelview[3*4 + j];
        }
    }
    
    // Pasar matrices al shader
    loc = glGetUniformLocation(matrixShader.program, "u_modelViewProjection");
    if (loc >= 0)
        glUniformMatrix4fv(loc, 1, GL_FALSE, mvp);
    
    loc = glGetUniformLocation(matrixShader.program, "u_modelView");
    if (loc >= 0)
        glUniformMatrix4fv(loc, 1, GL_FALSE, modelview);
    
    // Calcular y pasar matriz normal (inversa-transpuesta de modelview 3x3)
    // Por simplicidad, usamos modelview directamente (válido para transformaciones uniformes)
    loc = glGetUniformLocation(matrixShader.program, "u_normalMatrix");
    if (loc >= 0)
        glUniformMatrix4fv(loc, 1, GL_FALSE, modelview);
}
