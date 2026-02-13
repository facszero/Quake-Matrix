#version 120

// Atributos de entrada
attribute vec3 in_position;
attribute vec2 in_texcoord;
attribute vec3 in_normal;
attribute vec4 in_color;

// Variables de salida para el fragment shader
varying vec2 v_texcoord;
varying vec3 v_normal;
varying vec3 v_position;
varying vec4 v_color;
varying float v_depth;

// Matrices de transformación
uniform mat4 u_modelViewProjection;
uniform mat4 u_modelView;
uniform mat3 u_normalMatrix;

void main() {
    // Transformar posición a clip space
    gl_Position = u_modelViewProjection * vec4(in_position, 1.0);
    
    // Pasar coordenadas de textura
    v_texcoord = in_texcoord;
    
    // Transformar normal al view space
    v_normal = normalize(u_normalMatrix * in_normal);
    
    // Posición en view space para cálculos de iluminación
    vec4 viewPos = u_modelView * vec4(in_position, 1.0);
    v_position = viewPos.xyz;
    
    // Profundidad para efectos de fade
    v_depth = -viewPos.z;
    
    // Pasar color de vértice
    v_color = in_color;
}
