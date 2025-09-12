shader_type canvas_item;

uniform vec4 color1:source_color ;
uniform vec4 color2:source_color ;
uniform vec4 color3:source_color ;
uniform vec4 color4:source_color ;

uniform vec4 newColor1:source_color ;
uniform vec4 newColor2:source_color ;
uniform vec4 newColor3:source_color ;
uniform vec4 newColor4:source_color ;

uniform float A;


void fragment() {
	bool a = false;
	vec4 auxColor;
	if (distance(COLOR,color1) < A){
		a = true;
		auxColor = newColor1;}
	
	if (distance(COLOR,color2) < A){
		a = true;
		auxColor = newColor2;}
	
	if (distance(COLOR,color3) < A){
		a = true;
		auxColor = newColor3;}
	
	if (distance(COLOR,color4) < A){
		a = true;
		auxColor = newColor4;}
	
	if (a){
		COLOR = auxColor;}
	
}


