#version 120

// Post-processing shader para efectos de glow/bloom estilo Matrix

varying vec2 v_texcoord;

uniform sampler2D u_screenTexture;
uniform float u_bloomIntensity;
uniform vec2 u_screenSize;

// Kernel gaussiano para blur
const float kernel[9] = float[](
    0.0625, 0.125, 0.0625,
    0.125,  0.25,  0.125,
    0.0625, 0.125, 0.0625
);

vec3 sampleBlur() {
    vec2 texelSize = 1.0 / u_screenSize;
    vec3 result = vec3(0.0);
    
    int index = 0;
    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(float(x), float(y)) * texelSize;
            result += texture2D(u_screenTexture, v_texcoord + offset).rgb * kernel[index];
            index++;
        }
    }
    
    return result;
}

void main() {
    // Color original
    vec3 original = texture2D(u_screenTexture, v_texcoord).rgb;
    
    // Bloom
    vec3 bloom = sampleBlur();
    
    // Extraer solo las partes brillantes para bloom
    float brightness = dot(bloom, vec3(0.2126, 0.7152, 0.0722));
    bloom *= smoothstep(0.5, 1.0, brightness);
    
    // Combinar
    vec3 finalColor = original + bloom * u_bloomIntensity;
    
    // Ajuste de color Matrix (añadir tinte verde)
    finalColor.g *= 1.1;
    
    gl_FragColor = vec4(finalColor, 1.0);
}
