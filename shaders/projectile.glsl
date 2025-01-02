extern vec3 u_color;
extern float u_time;
extern vec2 u_resolution;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = screen_coords / u_resolution;
    
    // Calculate distance from center
    float dist = length(uv - vec2(0.5));
    
    // Enhanced inner glow with faster pulsing
    float innerGlow = 1.2 / (dist * dist);
    innerGlow = smoothstep(0.0, 1.0, innerGlow);
    innerGlow *= 1.0 + 0.3 * sin(u_time * 12.0);
    
    // Add outer yellow-white glow
    float outerGlow = 0.8 / (dist * dist * dist);
    outerGlow = smoothstep(0.0, 0.8, outerGlow);
    vec3 glowColor = vec3(1.0, 1.0, 0.7); // Yellowish white
    
    // Faster S-curve distortion
    float distortionAmount = sin(u_time * 8.0) * 0.15;
    float yOffset = (uv.y - 0.5) * 2.0;
    float xOffset = sin(yOffset * 3.14159) * distortionAmount;
    uv.x += xOffset;
    
    // Faster wobble
    float wobble = sin(uv.y * 10.0 + u_time * 15.0) * 0.03;
    uv.x += wobble;
    
    // Mix inner and outer glows
    vec3 finalColor = u_color * innerGlow * (1.0 + 0.5 * sin(u_time * 8.0));
    finalColor += glowColor * outerGlow * 0.5; // Add outer glow
    finalColor = clamp(finalColor, vec3(0.3), vec3(1.0));
    
    return vec4(finalColor, 1.0);
}