#version 120

// Matrix Digital Rain - Vertex Shader
// Proyecto Quake-Matrix por Fernando Cañete

attribute vec3 in_Position;
attribute vec2 in_TexCoord;
attribute vec3 in_Normal;

uniform mat4 u_ModelViewProjection;
uniform mat4 u_ModelView;
uniform mat4 u_Projection;
uniform float u_Time;

varying vec2 v_TexCoord;
varying vec3 v_WorldPos;
varying vec3 v_Normal;
varying vec3 v_ViewPos;

void main()
{
    gl_Position = u_ModelViewProjection * vec4(in_Position, 1.0);
    
    v_TexCoord = in_TexCoord;
    v_WorldPos = in_Position;
    v_Normal = in_Normal;
    
    // Posición en espacio de vista para efectos
    vec4 viewPos = u_ModelView * vec4(in_Position, 1.0);
    v_ViewPos = viewPos.xyz;
}
