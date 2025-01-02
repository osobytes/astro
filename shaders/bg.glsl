#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;  // Screen resolution
uniform float u_time;       // Time (to animate the stars)

// Random generator based on coordinates
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Function to draw a cross shape
float drawCross(vec2 st, vec2 position, float size) {
    vec2 d = abs(st - position);
    float cross = step(d.x, size) * step(d.y, size * 0.2) + step(d.y, size) * step(d.x, size * 0.2);
    return cross;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 st = screen_coords.xy / u_resolution;

    // Control the number of stars
    float numStars = 200.0;

    // Initialize the color
    vec3 starColor = vec3(0.0);

    // Generate stars
    for (float i = 0.0; i < numStars; i++) {
        // Random star position
        vec2 starPos = vec2(
            random(vec2(i, 0.0)) * u_resolution.x, 
            random(vec2(0.0, i)) * u_resolution.y
        );

        // Move the stars based on time (create motion)
        float speed = 100 + random(vec2(i)) * 0.5; // Randomize star speed
        starPos.y += u_time * speed;

        // Wrap around the screen
        starPos.y = mod(starPos.y, u_resolution.y);

        // Calculate distance to the star
        float dist = length(st * u_resolution - starPos);

        // Star size and brightness
        float starSize = 2.0 + random(vec2(i)) * 2.0;  // Vary star size
        float brightness = drawCross(st * u_resolution, starPos, starSize);

        // Accumulate star color
        starColor += vec3(1.0) * brightness;
    }

    return vec4(starColor, 1.0);
}