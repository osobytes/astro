extern vec2 u_resolution;
extern float u_time;
extern vec2 u_explosionPosition;
extern float u_explosionTime;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

vec2 randomDir(float seed) {
    float angle = hash(vec2(seed)) * 3.14159 * 2.0;
    return vec2(cos(angle), sin(angle));
}

vec3 celShade(vec3 color, int levels) {
    return floor(color * float(levels)) / float(levels);
}

float centerFlash(vec2 st, vec2 center, float timeNorm) {
    float flashDuration = 0.15;
    float fade = 1.0 - smoothstep(0.0, flashDuration, timeNorm);
    float dist = length(st - center);
    return exp(-dist * 50.0) * fade;
}

float shockWave(vec2 st, vec2 center, float timeNorm) {
    vec2 dir = randomDir(42.0) * 0.05;
    vec2 waveCenter = center + dir * 0.5 * timeNorm;
    float dist = length(st - waveCenter);
    float waveRadius = mix(0.0, 0.5, timeNorm);
    float ring = smoothstep(waveRadius, waveRadius - 0.015, dist)
               * smoothstep(waveRadius - 0.02, waveRadius, dist);
    return ring;
}

float debris(vec2 st, vec2 center, float timeNorm) {
    float sparkCount = 12.0;
    float accum = 0.0;
    for (float i = 0.0; i < 12.0; i++) {
        vec2 dir = randomDir(i + 7.123);
        float speed = 0.1 + 0.4 * hash(vec2(i + 1.0));
        vec2 sparkPos = center + dir * timeNorm * speed;
        float dist = length(st - sparkPos);
        float size = 0.015 * (1.0 - timeNorm);
        float glow = exp(-dist * 50.0);
        float spark = smoothstep(size, 0.0, dist) + glow * 0.2;
        accum += spark;
    }
    return accum * (1.0 - timeNorm);
}

vec3 fireballColor(vec2 st, vec2 center, float timeNorm) {
    float dist = length(st - center);
    float radius = timeNorm * 0.35;
    float val = 1.0 - smoothstep(radius * 0.2, radius, dist);
    vec3 color = vec3(1.0, 0.6, 0.2) * val;
    float outerVal = 1.0 - smoothstep(radius * 0.6, radius * 1.2, dist);
    vec3 color2 = vec3(1.0, 0.4, 0.0) * outerVal;
    vec3 result = color + color2;
    result = celShade(result, 4);
    result *= (1.0 - timeNorm * 0.8);
    return result;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 st = screen_coords / u_resolution;
    vec2 center = u_explosionPosition / u_resolution;
    float timeSinceExplosion = u_time - u_explosionTime;

    float flash = centerFlash(st, center, timeSinceExplosion);
    float wave = shockWave(st, center, timeSinceExplosion);
    float sparks = debris(st, center, timeSinceExplosion);
    vec3 fireball = fireballColor(st, center, timeSinceExplosion);

    float alpha = flash * 0.5 + wave + sparks * 0.5;
    vec3 finalColor = fireball 
                    + vec3(1.0, 0.9, 0.7) * flash * 0.6
                    + vec3(1.0, 0.5, 0.2) * wave * 0.4;
    finalColor += vec3(1.0, 0.8, 0.5) * sparks * 0.2;
    finalColor = celShade(finalColor, 4);

    return vec4(finalColor, alpha) * color;
}
