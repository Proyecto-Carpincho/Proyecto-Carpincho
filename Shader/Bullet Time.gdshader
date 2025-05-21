shader_type canvas_item;

uniform float Amplitud;
uniform float Velocidad;
uniform float Borde;
uniform float Gradiente;
uniform vec4 Color1 : source_color;
uniform vec4 Color2 : source_color;
uniform float Potencia : hint_range(0.0, 1.0, 0.025);

void fragment() {
    float time = sin(TIME * Velocidad) * Amplitud;
    float limit = Borde + time;

    float distX = min(UV.x, 1.0 - UV.x);
    float distY = min(UV.y, 1.0 - UV.y);
    float edgeDist = min(distX, distY); // más cerca del borde general

    if (edgeDist < limit) {

        float t = smoothstep(0.0, Gradiente + time, edgeDist);
        COLOR = mix(Color1, Color2, t);
		COLOR.a = COLOR.a * Potencia;
    } else {
		COLOR = Color2;
        COLOR.a = COLOR.a * Potencia;
    }
}
