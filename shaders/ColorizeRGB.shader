shader_type canvas_item;

uniform vec4 r0 : hint_color = vec4(0, 0, 0, 1);
uniform vec4 r1 : hint_color = vec4(1, 0, 0, 1);
uniform vec4 g0 : hint_color = vec4(0, 0, 0, 1);
uniform vec4 g1 : hint_color = vec4(0, 1, 0, 1);
uniform vec4 b0 : hint_color = vec4(0, 0, 0, 1);
uniform vec4 b1 : hint_color = vec4(0, 0, 1, 1);

void fragment(){
  vec4 base = texture(TEXTURE, UV);

  if (base.a == 0.0) {
    discard;
  }

  if (base.r > 0.0 && base.g == 0.0 && base.b == 0.0) {
    COLOR = mix(r0, r1, base.r);
  } else if (base.r == 0.0 && base.g > 0.0 && base.b == 0.0) {
    COLOR = mix(g0, g1, base.g);
  } else if (base.r == 0.0 && base.g == 0.0 && base.b > 0.0) {
    COLOR = mix(b0, b1, base.b);
  } else {
    COLOR = base;
  }
}
