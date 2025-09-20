shader_type canvas_item;

uniform int num_subdivisions : hint_range(1, 100) = 4; // cuántos “trosos” en Y
uniform float speed : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    float step = 1.0 / float(num_subdivisions);
    int index = int(UV.y / step);

    vec2 uv = UV;

    if (index % 2 == 0) {
        uv.x += sin(TIME * speed) * 0.005; // mueve hacia la derecha/izquierda según senoidal
    } else {
        uv.x -= sin(TIME * speed) * 0.005; // mueve en dirección opuesta
    }

    COLOR = texture(TEXTURE, uv);
}
