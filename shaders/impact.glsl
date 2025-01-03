#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_impactPosition;
uniform float u_impactTime;
uniform float u_scale; // Add scale uniform (e.g. 1.0 for normal size, 0.5 for half size)

// Hash function for randomization
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float particle(vec2 st, vec2 center, float seed, float time) {
    float t = time * 2.0;  // Speed up animation
    float angle = hash(vec2(seed)) * 3.14159 * 2.0;
    vec2 dir = vec2(cos(angle), sin(angle));
    
    // Scale the particle movement
    vec2 pos = center + dir * t * 0.1 * u_scale;
    
    // Scale particle size
    float size = 0.0045 * (1.0 - t) * u_scale;
    float dist = length(st - pos);
    
    return smoothstep(size, 0.0, dist) * (1.0 - t);
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 st = screen_coords.xy / u_resolution;
    vec2 impactCenter = u_impactPosition / u_resolution;
    float timeSinceImpact = u_time - u_impactTime;
    
    // Early exit if animation is complete
    if (timeSinceImpact > 0.5) return vec4(0.0);
    
    float particles = 0.0;
    
    // Generate multiple particles
    for (float i = 0.0; i < 12.0; i++) {
        particles += particle(st, impactCenter, i, timeSinceImpact);
    }
    
    vec3 particleColor = vec3(1.0, 0.9, 0.8);
    return vec4(particleColor, particles);
}