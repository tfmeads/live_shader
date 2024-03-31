uniform vec2 iResolution;
uniform float iTime;
uniform float sizeFactor = 1;
uniform float clrFactor = 3;
uniform float timeFactor = 1;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / (iResolution.y);
   
    //Start 'ahead' in time to start effects earlier
    float time = (iTime + 77.);
    
    float d = length(uv);
    d = sin(d * (7. * sizeFactor) + time * timeFactor) / (13. * sizeFactor);
    d = abs(d);
    
    d = smoothstep(0.01,.1,d);
    
    d = 0.02 / d;
    
    //Creates a scrolling color pattern
    vec3 col = clrFactor * 3 * tan((time * .0555)+uv.xxx-vec3(0,2,1) + 555. * tan(uv.xxx * time) * .0005);
    
    //Adds an LED/pixelation effect
    col *= sin(uv.xyx * time * 0.002 * timeFactor);
    
    
    //Mix colors with b/w circle pattern
    col*= d;

    // Output to screen
    fragColor = vec4(col,1.);
}

void main() {
mainImage(gl_FragColor,gl_FragCoord.xy);
}