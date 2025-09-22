shader_type canvas_item;


uniform vec4 colors[20] :source_color;
uniform vec4 newColors[20] :source_color;
uniform float Tolerancia;
uniform vec4 modulate :source_color;

void fragment() {
	
 	bool changed = false;
 	vec4 auxColor = texture(TEXTURE, UV);

	for (int i = 0; i < colors.length(); i++) {
		if (distance(COLOR, colors[i]) < Tolerancia) {
			auxColor = newColors[i];
			changed = true;
			break;
		}
	}

	if (changed) {
		COLOR = auxColor * modulate;
    }
}

