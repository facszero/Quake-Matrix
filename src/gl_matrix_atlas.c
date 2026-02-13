/*
Copyright (C) 2026 Fernando Cañete
Continuación de gl_matrix.c - Atlas de caracteres y renderizado
*/

// Caracteres para el atlas Matrix (japonés, símbolos, números)
static const char* matrixChars[] = {
    // Katakana
    "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ",
    "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト",
    "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ",
    "マ", "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ",
    "ル", "レ", "ロ", "ワ", "ヲ", "ン",
    // Números
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    // Símbolos
    ":", "・", "\"", "=", "*", "+", "-", "<", ">", "¦",
    "Z", ":", ".", "\"", "=", "*", "+", "-", "|", "_",
    // Letras latinas (algunas invertidas)
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
    "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
    "U", "V", "W", "X", "Y", "Z"
};

static const int matrixCharCount = sizeof(matrixChars) / sizeof(matrixChars[0]);

/*
================
Matrix_GenerateCharAtlas

Genera un atlas de caracteres proceduralmente
Si no hay fuente Matrix disponible, crea caracteres simples
================
*/
qboolean Matrix_GenerateCharAtlas(void)
{
    int atlasSize = 512;  // 512x512 para 16x16 grid de caracteres
    int charSize = atlasSize / 16;
    unsigned char *pixels;
    int i, x, y, cx, cy;
    
    Con_Printf("Generating character atlas...\n");
    
    pixels = (unsigned char*)malloc(atlasSize * atlasSize);
    if (!pixels)
    {
        Con_Printf("ERROR: Failed to allocate atlas memory\n");
        return false;
    }
    
    // Limpiar a negro
    memset(pixels, 0, atlasSize * atlasSize);
    
    // Generar caracteres simples (líneas verticales y patrones)
    for (i = 0; i < 256; i++)
    {
        cx = (i % 16) * charSize;
        cy = (i / 16) * charSize;
        
        // Diferentes patrones según el índice
        int pattern = i % 8;
        
        for (y = 0; y < charSize; y++)
        {
            for (x = 0; x < charSize; x++)
            {
                int px = cx + x;
                int py = cy + y;
                unsigned char val = 0;
                
                switch (pattern)
                {
                    case 0: // Línea vertical
                        if (x >= charSize/3 && x <= charSize*2/3)
                            val = 255;
                        break;
                    case 1: // Línea horizontal
                        if (y >= charSize/3 && y <= charSize*2/3)
                            val = 255;
                        break;
                    case 2: // Cruz
                        if ((x >= charSize/3 && x <= charSize*2/3) ||
                            (y >= charSize/3 && y <= charSize*2/3))
                            val = 255;
                        break;
                    case 3: // Diagonal
                        if (abs(x - y) < charSize/4)
                            val = 255;
                        break;
                    case 4: // Círculo
                        {
                            int dx = x - charSize/2;
                            int dy = y - charSize/2;
                            int dist = dx*dx + dy*dy;
                            int radius = charSize/3;
                            if (dist < radius*radius && dist > (radius-2)*(radius-2))
                                val = 255;
                        }
                        break;
                    case 5: // Puntos
                        if ((x % 4 == 0) && (y % 4 == 0))
                            val = 255;
                        break;
                    case 6: // Líneas diagonales
                        if ((x + y) % 4 == 0)
                            val = 255;
                        break;
                    case 7: // Patrón aleatorio
                        val = ((x * 7 + y * 13 + i) % 256) > 128 ? 255 : 0;
                        break;
                }
                
                pixels[py * atlasSize + px] = val;
            }
        }
    }
    
    // Crear textura OpenGL
    glGenTextures(1, &charAtlas.texture);
    glBindTexture(GL_TEXTURE_2D, charAtlas.texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, atlasSize, atlasSize, 
                 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, pixels);
    
    free(pixels);
    
    charAtlas.width = atlasSize;
    charAtlas.height = atlasSize;
    charAtlas.charSize = charSize;
    charAtlas.loaded = true;
    
    Con_Printf("Character atlas generated: %dx%d\n", atlasSize, atlasSize);
    
    return true;
}

/*
================
Matrix_LoadCharAtlas

Intenta cargar el atlas de caracteres desde archivo
================
*/
qboolean Matrix_LoadCharAtlas(void)
{
    // Por ahora, siempre genera proceduralmente
    // TODO: Implementar carga desde archivo de imagen
    return false;
}

/*
================
Matrix_UnloadCharAtlas

Libera el atlas de caracteres
================
*/
void Matrix_UnloadCharAtlas(void)
{
    if (charAtlas.texture)
    {
        glDeleteTextures(1, &charAtlas.texture);
        charAtlas.texture = 0;
    }
    charAtlas.loaded = false;
}

/*
================
Matrix_BeginFrame

Llamado al inicio de cada frame de renderizado
================
*/
void Matrix_BeginFrame(void)
{
    // Actualizar tiempo
    matrixTime += host_frametime;
    
    // Actualizar configuración si cambió
    Matrix_UpdateConfig();
}

/*
================
Matrix_EndFrame

Llamado al final de cada frame de renderizado
================
*/
void Matrix_EndFrame(void)
{
    // Nada por ahora
}

/*
================
Matrix_BindShader

Activa el shader de Matrix y configura uniforms
================
*/
void Matrix_BindShader(void)
{
    if (!matrixConfig.enabled || !matrixShader.program)
        return;
    
    glUseProgram(matrixShader.program);
    
    // Configurar uniforms de tiempo y parámetros
    if (matrixShader.u_time >= 0)
        glUniform1f(matrixShader.u_time, matrixTime);
    
    if (matrixShader.u_matrixColor >= 0)
        glUniform3f(matrixShader.u_matrixColor, 
                   matrixConfig.color[0],
                   matrixConfig.color[1],
                   matrixConfig.color[2]);
    
    if (matrixShader.u_rainSpeed >= 0)
        glUniform1f(matrixShader.u_rainSpeed, matrixConfig.rainSpeed);
    
    if (matrixShader.u_charDensity >= 0)
        glUniform1f(matrixShader.u_charDensity, matrixConfig.charDensity);
    
    if (matrixShader.u_glowIntensity >= 0)
        glUniform1f(matrixShader.u_glowIntensity, matrixConfig.glowIntensity);
    
    if (matrixShader.u_trailLength >= 0)
        glUniform1f(matrixShader.u_trailLength, matrixConfig.trailLength);
    
    if (matrixShader.u_matrixEnabled >= 0)
        glUniform1i(matrixShader.u_matrixEnabled, matrixConfig.enabled ? 1 : 0);
    
    // Bind del atlas de caracteres
    if (charAtlas.loaded && matrixShader.u_charAtlas >= 0)
    {
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, charAtlas.texture);
        glUniform1i(matrixShader.u_charAtlas, 1);
        glActiveTexture(GL_TEXTURE0);
    }
}

/*
================
Matrix_UnbindShader

Desactiva el shader de Matrix
================
*/
void Matrix_UnbindShader(void)
{
    glUseProgram(0);
}

/*
================
Matrix_SetMatrices

Configura las matrices de transformación en el shader
================
*/
void Matrix_SetMatrices(void)
{
    float mvp[16], mv[16], nm[9];
    
    // Obtener matrices actuales de OpenGL
    // TODO: Implementar obtención correcta de matrices desde QuakeSpasm
    
    // Por ahora, usar matrices de identidad como placeholder
    // Esto se implementará correctamente cuando se integre con gl_rmain.c
}
