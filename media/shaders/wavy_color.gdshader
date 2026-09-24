shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.2, 0.6, 1.0, 1.0);
uniform vec4 highlight_color : source_color = vec4(0.1, 0.2, 0.5, 1.0);
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float liquid_speed : hint_range(0.1, 5.0) = 0.4;

float rand(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);

    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a) * u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float liquid_pattern(vec2 uv, float time) {
    vec2 uv1 = uv * 3.0;
    uv1.x += sin(time + uv1.y);
    uv1.y += cos(time + uv1.x);
    vec2 uv2 = uv * 4.0 + uv1 * 0.5; 
    
    uv2.x -= cos(time - uv2.y) * 0.6;
    uv2.y -= sin(time - uv2.x) * 0.6;
    
    float n1 = noise(uv1);
    float n2 = noise(uv2);
    
    return (n1 * n2) * 0.5 + 0.5;
}

void fragment() {
    float t = TIME * liquid_speed;
    float pattern = liquid_pattern(UV * 0.8, t);
    pattern = smoothstep(0.0, 1.0, pattern);
    vec4 final_color = mix(highlight_color, base_color, pattern);
    
    COLOR.rgb = final_color.rgb * brightness;
    COLOR.a = final_color.a;
}