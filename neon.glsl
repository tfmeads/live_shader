uniform vec2 iResolution;
uniform float iTime;

vec3 palette(float t){

    vec3 a = vec3(0.821, 0.328, 0.242); 
    vec3 b = vec3(0.659, 0.481, 0.896); 
    vec3 c = vec3(-0.782, 1.000, 1.000); 
    vec3 d = vec3(-2.752, 0.333, 0.667);
    
    //makes colors pulse inwards/outwards
    c+= 55. * sin(55.55 * iTime) / 5555.;
    
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
    vec3 col = palette(length(uv0) + iTime * .05);
    
    d = sin(d*15. + iTime) / 18.;
    d = abs(d);
    
    //using exponential function helps colors pop (brights get brighter, darks darker)
    d = pow(0.025 / d, 1.3);

    //Mix colors with b/w circle pattern
    col*= d;

    // Output to screen
    fragColor = vec4(col,1.);
}

void main() {
mainImage(gl_FragColor,gl_FragCoord.xy);
}