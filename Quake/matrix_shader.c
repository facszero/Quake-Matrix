/*
 * matrix_shader.c - Matrix Digital Rain Shader System Implementation
 * Proyecto Quake-Matrix por Fernando Cañete
 */

#include "matrix_shader.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

matrixshader_t matrixshader;

cvar_t r_matrix = {"r_matrix", "1", CVAR_ARCHIVE};
cvar_t r_matrix_intensity = {"r_matrix_intensity", "1.0", CVAR_ARCHIVE};

// Shader sources embebidos (fallback si no se encuentran archivos)
static const char *matrix_vertex_shader_src = 
"#version 120\n"
"attribute vec3 in_Position;\n"
"attribute vec2 in_TexCoord;\n"
"attribute vec3 in_Normal;\n"
"uniform mat4 u_ModelViewProjection;\n"
"uniform mat4 u_ModelView;\n"
"uniform mat4 u_Projection;\n"
"uniform float u_Time;\n"
"varying vec2 v_TexCoord;\n"
"varying vec3 v_WorldPos;\n"
"varying vec3 v_Normal;\n"
"varying vec3 v_ViewPos;\n"
"void main() {\n"
"    gl_Position = u_ModelViewProjection * vec4(in_Position, 1.0);\n"
"    v_TexCoord = in_TexCoord;\n"
"    v_WorldPos = in_Position;\n"
"    v_Normal = in_Normal;\n"
"    vec4 viewPos = u_ModelView * vec4(in_Position, 1.0);\n"
"    v_ViewPos = viewPos.xyz;\n"
"}\n";

// Función para leer archivo de shader
qboolean MatrixShader_LoadFromFile(const char *filename, char **source)
{
    FILE *file;
    long filesize;
    char *buffer;
    
    file = fopen(filename, "rb");
    if (!file) {
        Con_DPrintf("MatrixShader: Could not open %s\n", filename);
        return false;
    }
    
    fseek(file, 0, SEEK_END);
    filesize = ftell(file);
    fseek(file, 0, SEEK_SET);
    
    buffer = (char *)malloc(filesize + 1);
    if (!buffer) {
        fclose(file);
        return false;
    }
    
    fread(buffer, 1, filesize, file);
    buffer[filesize] = '\0';
    fclose(file);
    
    *source = buffer;
    return true;
}

// Compilar shader
GLuint MatrixShader_LoadShader(GLenum type, const char *source)
{
    GLuint shader;
    GLint compiled;
    
    shader = glCreateShader(type);
    if (shader == 0) {
        Con_Printf("MatrixShader: Error creating shader\n");
        return 0;
    }
    
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);
    if (!compiled) {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            Con_Printf("MatrixShader: Error compiling shader:\n%s\n", infoLog);
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

// Crear programa de shader
GLuint MatrixShader_CreateProgram(GLuint vertexShader, GLuint fragmentShader)
{
    GLuint program;
    GLint linked;
    
    program = glCreateProgram();
    if (program == 0) {
        Con_Printf("MatrixShader: Error creating program\n");
        return 0;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(program, infoLen, NULL, infoLog);
            Con_Printf("MatrixShader: Error linking program:\n%s\n", infoLog);
            free(infoLog);
        }
        
        glDeleteProgram(program);
        return 0;
    }
    
    return program;
}

// Inicializar sistema de shaders Matrix
void MatrixShader_Init(void)
{
    char *vertSource = NULL;
    char *fragSource = NULL;
    qboolean vertLoaded = false;
    qboolean fragLoaded = false;
    
    Con_Printf("Initializing Matrix Shader System...\n");
    
    memset(&matrixshader, 0, sizeof(matrixshader));
    
    // Registrar cvars
    Cvar_RegisterVariable(&r_matrix);
    Cvar_RegisterVariable(&r_matrix_intensity);
    
    // Intentar cargar shaders desde archivos
    vertLoaded = MatrixShader_LoadFromFile("shaders/matrix.vert", &vertSource);
    fragLoaded = MatrixShader_LoadFromFile("shaders/matrix.frag", &fragSource);
    
    // Si no se cargaron, usar fuentes embebidas
    if (!vertLoaded) {
        Con_DPrintf("MatrixShader: Using embedded vertex shader\n");
        vertSource = (char *)matrix_vertex_shader_src;
    }
    
    if (!fragLoaded) {
        Con_DPrintf("MatrixShader: Using embedded fragment shader (simplified)\n");
        // En caso de no encontrar el archivo, usamos una versión simplificada
        fragSource = (char *)
        "#version 120\n"
        "uniform sampler2D u_Texture;\n"
        "uniform float u_Time;\n"
        "uniform vec2 u_Resolution;\n"
        "uniform float u_MatrixIntensity;\n"
        "uniform int u_EnableMatrix;\n"
        "varying vec2 v_TexCoord;\n"
        "void main() {\n"
        "    vec4 texColor = texture2D(u_Texture, v_TexCoord);\n"
        "    if (u_EnableMatrix == 0) {\n"
        "        gl_FragColor = texColor;\n"
        "        return;\n"
        "    }\n"
        "    vec2 screenUV = gl_FragCoord.xy / u_Resolution;\n"
        "    float rain = fract(screenUV.y + u_Time * 0.5);\n"
        "    vec3 green = vec3(0.0, rain, 0.0);\n"
        "    vec3 final = mix(texColor.rgb, green, u_MatrixIntensity * 0.5);\n"
        "    gl_FragColor = vec4(final, texColor.a);\n"
        "}\n";
    }
    
    // Compilar shaders
    matrixshader.vertexShader = MatrixShader_LoadShader(GL_VERTEX_SHADER, vertSource);
    matrixshader.fragmentShader = MatrixShader_LoadShader(GL_FRAGMENT_SHADER, fragSource);
    
    // Liberar memoria si se cargaron desde archivo
    if (vertLoaded && vertSource) free(vertSource);
    if (fragLoaded && fragSource) free(fragSource);
    
    if (matrixshader.vertexShader == 0 || matrixshader.fragmentShader == 0) {
        Con_Printf("MatrixShader: Failed to compile shaders\n");
        matrixshader.initialized = false;
        return;
    }
    
    // Crear programa
    matrixshader.program = MatrixShader_CreateProgram(
        matrixshader.vertexShader, 
        matrixshader.fragmentShader
    );
    
    if (matrixshader.program == 0) {
        Con_Printf("MatrixShader: Failed to create program\n");
        matrixshader.initialized = false;
        return;
    }
    
    // Obtener ubicaciones de uniforms
    matrixshader.loc_ModelViewProjection = glGetUniformLocation(matrixshader.program, "u_ModelViewProjection");
    matrixshader.loc_ModelView = glGetUniformLocation(matrixshader.program, "u_ModelView");
    matrixshader.loc_Projection = glGetUniformLocation(matrixshader.program, "u_Projection");
    matrixshader.loc_Time = glGetUniformLocation(matrixshader.program, "u_Time");
    matrixshader.loc_Texture = glGetUniformLocation(matrixshader.program, "u_Texture");
    matrixshader.loc_Resolution = glGetUniformLocation(matrixshader.program, "u_Resolution");
    matrixshader.loc_MatrixIntensity = glGetUniformLocation(matrixshader.program, "u_MatrixIntensity");
    matrixshader.loc_EnableMatrix = glGetUniformLocation(matrixshader.program, "u_EnableMatrix");
    
    // Obtener ubicaciones de atributos
    matrixshader.loc_Position = glGetAttribLocation(matrixshader.program, "in_Position");
    matrixshader.loc_TexCoord = glGetAttribLocation(matrixshader.program, "in_TexCoord");
    matrixshader.loc_Normal = glGetAttribLocation(matrixshader.program, "in_Normal");
    
    matrixshader.initialized = true;
    matrixshader.enabled = r_matrix.value > 0;
    matrixshader.intensity = r_matrix_intensity.value;
    matrixshader.time = 0.0f;
    
    Con_Printf("Matrix Shader System initialized successfully\n");
    Con_Printf("  r_matrix: %s\n", r_matrix.string);
    Con_Printf("  r_matrix_intensity: %s\n", r_matrix_intensity.string);
}

// Cerrar sistema de shaders
void MatrixShader_Shutdown(void)
{
    if (!matrixshader.initialized)
        return;
    
    if (matrixshader.program) {
        glDeleteProgram(matrixshader.program);
        matrixshader.program = 0;
    }
    
    if (matrixshader.vertexShader) {
        glDeleteShader(matrixshader.vertexShader);
        matrixshader.vertexShader = 0;
    }
    
    if (matrixshader.fragmentShader) {
        glDeleteShader(matrixshader.fragmentShader);
        matrixshader.fragmentShader = 0;
    }
    
    matrixshader.initialized = false;
    Con_Printf("Matrix Shader System shut down\n");
}

// Activar shader Matrix
void MatrixShader_Enable(void)
{
    if (!matrixshader.initialized)
        return;
    
    glUseProgram(matrixshader.program);
    matrixshader.enabled = true;
}

// Desactivar shader Matrix
void MatrixShader_Disable(void)
{
    glUseProgram(0);
    matrixshader.enabled = false;
}

// Actualizar estado del shader
void MatrixShader_Update(float frametime)
{
    if (!matrixshader.initialized)
        return;
    
    matrixshader.time += frametime;
    matrixshader.intensity = r_matrix_intensity.value;
    matrixshader.enabled = r_matrix.value > 0;
}

// Establecer uniforms del shader
void MatrixShader_SetUniforms(void)
{
    if (!matrixshader.initialized || !matrixshader.enabled)
        return;
    
    // Tiempo
    if (matrixshader.loc_Time >= 0) {
        glUniform1f(matrixshader.loc_Time, matrixshader.time);
    }
    
    // Resolución
    if (matrixshader.loc_Resolution >= 0) {
        glUniform2f(matrixshader.loc_Resolution, (float)glwidth, (float)glheight);
    }
    
    // Intensidad Matrix
    if (matrixshader.loc_MatrixIntensity >= 0) {
        glUniform1f(matrixshader.loc_MatrixIntensity, matrixshader.intensity);
    }
    
    // Habilitar Matrix
    if (matrixshader.loc_EnableMatrix >= 0) {
        glUniform1i(matrixshader.loc_EnableMatrix, matrixshader.enabled ? 1 : 0);
    }
    
    // Textura
    if (matrixshader.loc_Texture >= 0) {
        glUniform1i(matrixshader.loc_Texture, 0);
    }
}
