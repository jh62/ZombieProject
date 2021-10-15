shader_type canvas_item;

uniform vec2 mouse_position;
uniform vec4 color: hint_color = vec4(0.3, 0.3, 0.0, 1);
uniform float dist1 = 0.05;
uniform float dist2 = 0.15;

uniform float mult = 1.7;

void fragment(){
	float transp = 0.0;
	float val = distance(vec2(UV.x - 0.5,(UV.y - 0.5) * mult), vec2(mouse_position.x ,mouse_position.y * mult));
	
	if(val < dist1){
		transp = 0.0;
	}else if(val < dist2){
		transp = 0.5;
	} else {
		transp = 1.0;
	}
	
	COLOR = vec4(color.x,color.y,color.z,transp);
}