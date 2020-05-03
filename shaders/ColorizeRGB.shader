shader_type canvas_item;

uniform vec3 colorR;
uniform vec3 colorG;
uniform vec3 colorB;

void fragment(){
  vec4 base = texture(TEXTURE, UV);

  if (!(base.a > 0.0)) {
    discard;
  }

  if (base.r > 0.0 && base.g == 0.0 && base.b == 0.0) {
    COLOR = vec4(base.r * colorR, 1.0);
  } else if (base.r == 0.0 && base.g > 0.0 && base.b == 0.0) {
    COLOR = vec4(base.g * colorG, 1.0);
  } else if (base.r == 0.0 && base.g == 0.0 && base.b > 0.0) {
    COLOR = vec4(base.b * colorB, 1.0);
  } else {
    COLOR = base;
  }
}