uniform vec2 iResolution;
uniform float iTime;


vec3 palette(float t){

    vec3 a = vec3(0.361, -0.132, -0.218); 
    vec3 b = vec3(0.791, 0.577, 1.075); 
    vec3 c = vec3(5.147, 0.558, 0.485); 
    vec3 d = vec3(-0.943, 1.834, -1.465);
    
    //makes colors pulse inwards/outwards
    c+= 55. * sin(5.55 * iTime) / 5555.;
    
    return a + b*cos(6.28318*(c*t+d));;
    
    }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / (iResolution.y);
    
    //Keep track of original unit vector
    vec2 uv0 = uv;

    //Double unit vector before fract to center image
    uv = fract(uv0 * 2.2) - 0.5;
   
    float d = length(uv);
        
    //Creates a scrolling color pattern
    vec3 col = palette(length(uv0) + iTime * .2);
    
    d = sin(d*8. + iTime) / 8.;
    d = abs(d);
    
    //using exponential function helps colors pop (brights get brighter, darks darker)
    d = pow(0.015 / d, 3.);

    //Mix colors with b/w circle pattern
    col*= d;

    // Output to screen
    fragColor = vec4(col,1.);
}


void main() {
mainImage(gl_FragColor,gl_FragCoord.xy);
}
