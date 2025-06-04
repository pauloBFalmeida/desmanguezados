shader_type canvas_item;

uniform sampler2D viewport_tex;

void fragment() {
    // Sample using nearest-neighbor style logic
    vec2 tex_size = vec2(textureSize(viewport_tex, 0));
    vec2 pixel_uv = floor(UV * tex_size) / tex_size;
    COLOR = texture(viewport_tex, pixel_uv);
}
