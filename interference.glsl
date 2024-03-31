uniform vec2 iResolution;
uniform float iTime;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / (iResolution.y);

   
    float d = length(uv);
    d = sin(d * 7. + iTime) / 10.;
    d = abs(d);
    
    d = smoothstep(0.01,.2,d);
    
    d = 0.02 / d;
    
    //Creates a scrolling color pattern
    vec3 col = tan(iTime+uv.yyy-vec3(0,2,1) + sin(uv.yyy * iTime * 20.2));    
    
    //Mix colors with b/w circle pattern
    col*= d;

    // Output to screen
    fragColor = vec4(col,1.);
}


void main() {
mainImage(gl_FragColor,gl_FragCoord.xy);
}