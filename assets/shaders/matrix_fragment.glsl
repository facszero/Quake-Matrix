#version 120

// Inputs del vertex shader
varying vec2 v_texcoord;
varying vec3 v_normal;
varying vec3 v_position;
varying vec4 v_color;
varying float v_depth;

// Texturas
uniform sampler2D u_texture;
uniform sampler2D u_charAtlas;

// Parámetros del efecto Matrix
uniform float u_time;
uniform vec3 u_matrixColor;
uniform float u_rainSpeed;
uniform float u_charDensity;
uniform float u_glowIntensity;
uniform float u_trailLength;
uniform int u_matrixEnabled;

// Constantes
const float GRID_SIZE = 16.0;  // 16x16 caracteres en el atlas
const float CHAR_COUNT = 256.0;

// Generador de números pseudo-aleatorios
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Hash mejorado para mejor distribución
float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

// Función para obtener UV del carácter en el atlas
vec2 getCharacterUV(vec2 screenUV, float time) {
    // Calcular posición en el grid de caracteres
    vec2 gridPos = floor(screenUV * u_charDensity);
    
    // Semilla única para cada columna
    float columnSeed = hash(vec2(gridPos.x, 0.0));
    
    // Velocidad de caída variable por columna
    float fallSpeed = (0.5 + columnSeed * 1.5) * u_rainSpeed;
    
    // Offset vertical animado
    float yOffset = fract(time * fallSpeed + columnSeed * 10.0);
    float rowPos = gridPos.y + yOffset * u_charDensity;
    
    // Selección de carácter (cambia con el tiempo)
    float charSeed = hash(vec2(gridPos.x, floor(rowPos)));
    float charChange = floor(time * 10.0 + charSeed * 100.0);
    float charIndex = floor(hash(vec2(charSeed, charChange)) * CHAR_COUNT);
    
    // Convertir índice a coordenadas del atlas
    float charX = mod(charIndex, GRID_SIZE);
    float charY = floor(charIndex / GRID_SIZE);
    vec2 charBaseUV = vec2(charX, charY) / GRID_SIZE;
    
    // UV local dentro del carácter
    vec2 localUV = fract(screenUV * u_charDensity) / GRID_SIZE;
    
    return charBaseUV + localUV;
}

// Calcular intensidad del trail (rastro de caracteres)
float getTrailIntensity(vec2 screenUV, float time) {
    vec2 gridPos = floor(screenUV * u_charDensity);
    float columnSeed = hash(vec2(gridPos.x, 0.0));
    float fallSpeed = (0.5 + columnSeed * 1.5) * u_rainSpeed;
    
    float yOffset = fract(time * fallSpeed + columnSeed * 10.0);
    float rowInColumn = fract(screenUV.y * u_charDensity);
    
    // Distancia desde la cabeza del stream
    float distFromHead = rowInColumn - yOffset;
    if (distFromHead < 0.0) distFromHead += 1.0;
    
    // Fade basado en distancia
    float fade = 1.0 - smoothstep(0.0, u_trailLength, distFromHead);
    
    return fade;
}

// Efecto de "carácter brillante" en la cabeza del stream
float getHeadGlow(vec2 screenUV, float time) {
    vec2 gridPos = floor(screenUV * u_charDensity);
    float columnSeed = hash(vec2(gridPos.x, 0.0));
    float fallSpeed = (0.5 + columnSeed * 1.5) * u_rainSpeed;
    
    float yOffset = fract(time * fallSpeed + columnSeed * 10.0);
    float rowInColumn = fract(screenUV.y * u_charDensity);
    
    float distFromHead = abs(rowInColumn - yOffset);
    
    // Glow muy intenso en la cabeza
    return exp(-distFromHead * 50.0) * u_glowIntensity;
}

void main() {
    vec3 finalColor;
    float alpha = 1.0;
    
    if (u_matrixEnabled == 1) {
        // Modo Matrix activado
        vec2 charUV = getCharacterUV(v_texcoord, u_time);
        
        // Samplear el carácter del atlas
        float charMask = texture2D(u_charAtlas, charUV).r;
        
        // Intensidad del trail
        float trailIntensity = getTrailIntensity(v_texcoord, u_time);
        
        // Glow de la cabeza
        float headGlow = getHeadGlow(v_texcoord, u_time);
        
        // Atenuación por profundidad
        float depthFade = 1.0 - smoothstep(10.0, 100.0, v_depth);
        
        // Factor de iluminación basado en normal
        float normalFactor = max(0.3, dot(v_normal, vec3(0.0, 0.0, 1.0)));
        
        // Color base Matrix
        vec3 baseColor = u_matrixColor * charMask;
        
        // Aplicar trail fade
        baseColor *= trailIntensity * depthFade * normalFactor;
        
        // Añadir glow de cabeza
        vec3 glowColor = vec3(0.5, 1.0, 0.5) * headGlow * charMask;
        
        finalColor = baseColor + glowColor;
        alpha = charMask * trailIntensity * depthFade;
        
    } else {
        // Modo normal (textura original de Quake)
        vec4 texColor = texture2D(u_texture, v_texcoord);
        finalColor = texColor.rgb * v_color.rgb;
        alpha = texColor.a;
    }
    
    gl_FragColor = vec4(finalColor, alpha);
}
