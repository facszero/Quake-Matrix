#version 120

// Matrix Digital Rain - Fragment Shader
// Proyecto Quake-Matrix por Fernando Cañete
// Inspirado en el código Matrix de la película

uniform sampler2D u_Texture;
uniform float u_Time;
uniform vec2 u_Resolution;
uniform float u_MatrixIntensity; // 0.0 = normal, 1.0 = full Matrix
uniform int u_EnableMatrix;

varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec3 v_Normal;
varying vec3 v_ViewPos;

// Colores Matrix auténticos
const vec3 MATRIX_GREEN_BRIGHT = vec3(0.8, 1.0, 0.8);  // Verde brillante
const vec3 MATRIX_GREEN_MID = vec3(0.0, 1.0, 0.0);     // Verde medio
const vec3 MATRIX_GREEN_DARK = vec3(0.0, 0.5, 0.0);    // Verde oscuro
const vec3 MATRIX_GREEN_GLOW = vec3(0.5, 1.0, 0.5);    // Verde glow

// Parámetros de la lluvia de código
const float RAIN_SPEED = 2.0;
const float RAIN_DENSITY = 40.0;
const float GLYPH_SIZE = 0.015;
const int NUM_COLUMNS = 80;

// Generador de números pseudo-aleatorios
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Ruido 2D
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Simula un glifo Matrix (katakana/caracteres)
float matrixGlyph(vec2 uv, float columnSeed) {
    // Crear una cuadrícula de glyphs
    vec2 glyphCoord = fract(uv * vec2(NUM_COLUMNS, NUM_COLUMNS * 1.5));
    
    // Animación de cambio de caracteres
    float glyphChange = floor(u_Time * 10.0 + columnSeed * 100.0);
    float glyphPattern = random(floor(uv * vec2(NUM_COLUMNS, NUM_COLUMNS * 1.5)) + glyphChange);
    
    // Forma del glyph (simulado)
    float glyph = 0.0;
    
    // Líneas verticales (simulando trazos de katakana)
    if (glyphPattern > 0.3) {
        glyph += smoothstep(0.45, 0.5, glyphCoord.x) * smoothstep(0.55, 0.5, glyphCoord.x);
    }
    
    // Líneas horizontales
    if (glyphPattern > 0.6) {
        float hLine = smoothstep(0.45, 0.5, glyphCoord.y) * smoothstep(0.55, 0.5, glyphCoord.y);
        glyph += hLine * 0.7;
    }
    
    // Detalles adicionales
    if (glyphPattern > 0.8) {
        vec2 detailCoord = fract(glyphCoord * 2.0);
        glyph += step(0.7, detailCoord.x) * step(0.7, detailCoord.y) * 0.5;
    }
    
    return clamp(glyph, 0.0, 1.0);
}

// Genera la "lluvia" en una columna
float rainColumn(vec2 uv, float columnIndex) {
    float columnSeed = random(vec2(columnIndex, 0.0));
    
    // Velocidad variable por columna
    float speed = RAIN_SPEED * (0.5 + columnSeed);
    
    // Posición de la "gota" de lluvia
    float rainPos = fract(uv.y + u_Time * speed * 0.1 + columnSeed);
    
    // Longitud de la gota
    float dropLength = 0.3 + columnSeed * 0.4;
    
    // Intensidad de la lluvia (brillo que decrece desde la punta)
    float intensity = 0.0;
    
    if (rainPos < dropLength) {
        // Punta brillante
        float tipDistance = rainPos / dropLength;
        intensity = 1.0 - tipDistance;
        
        // Cursor brillante en la punta
        if (tipDistance > 0.95) {
            intensity = 1.5;
        }
    }
    
    return intensity;
}

// Efecto de bloom/glow
vec3 bloom(vec3 color, float intensity) {
    return color * (1.0 + intensity * 0.5);
}

void main()
{
    // Obtener color de textura original
    vec4 texColor = texture2D(u_Texture, v_TexCoord);
    
    if (u_EnableMatrix == 0) {
        // Modo normal sin efecto Matrix
        gl_FragColor = texColor;
        return;
    }
    
    // Coordenadas de pantalla normalizadas
    vec2 screenUV = gl_FragCoord.xy / u_Resolution;
    
    // Determinar columna
    float columnIndex = floor(screenUV.x * float(NUM_COLUMNS));
    float columnUV = fract(screenUV.x * float(NUM_COLUMNS));
    
    // Calcular intensidad de la lluvia en esta posición
    float rainIntensity = rainColumn(screenUV, columnIndex);
    
    // Generar glyph
    float glyph = matrixGlyph(screenUV, columnIndex);
    
    // Combinar lluvia y glyph
    float matrixValue = rainIntensity * glyph;
    
    // Agregar ruido para variación
    float noiseValue = noise(screenUV * 100.0 + u_Time * 2.0) * 0.1;
    matrixValue += noiseValue;
    
    // Color Matrix basado en intensidad
    vec3 matrixColor = vec3(0.0);
    
    if (matrixValue > 0.8) {
        // Punta brillante (blanco-verde)
        matrixColor = MATRIX_GREEN_BRIGHT;
    } else if (matrixValue > 0.3) {
        // Verde medio
        matrixColor = MATRIX_GREEN_MID * matrixValue;
    } else if (matrixValue > 0.1) {
        // Verde oscuro
        matrixColor = MATRIX_GREEN_DARK * matrixValue;
    }
    
    // Bloom effect
    matrixColor = bloom(matrixColor, matrixValue);
    
    // Mezclar con textura original según intensidad del efecto
    vec3 baseColor = texColor.rgb;
    
    // Convertir color base a escala de grises y luego a verde
    float luminance = dot(baseColor, vec3(0.299, 0.587, 0.114));
    vec3 greenBase = vec3(0.0, luminance, 0.0);
    
    // Mezcla final
    vec3 finalColor = mix(baseColor, matrixColor + greenBase * 0.3, u_MatrixIntensity);
    
    // Agregar glow ambiental verde
    finalColor += MATRIX_GREEN_GLOW * 0.05 * u_MatrixIntensity;
    
    // Vignette sutil
    vec2 vignetteUV = screenUV * 2.0 - 1.0;
    float vignette = 1.0 - dot(vignetteUV, vignetteUV) * 0.2;
    finalColor *= vignette;
    
    gl_FragColor = vec4(finalColor, texColor.a);
}
