uniform vec2 iResolution;
uniform float iTime;

vec3 palette(float t){

    vec3 a = vec3(0.000 ,0.500, 0.5008); 
    vec3 b = vec3(0.791, 0.555, 1.075); 
    vec3 c = vec3(5.147, 0.558, 0.485); 
    vec3 d = vec3(-0.922,-0.255, -0.422);
    
    //makes colors pulse inwards/outwards
    c+= 555. * sin(5.55 * iTime) / 55555555.;
    
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
    
    //kudos to MV10 for this code, adds some rotation to the bkg
    const float pi_deg = 3.141592 / 180.0;
    float angle = iTime * 5.0 / (.3 * max(uv0.x,uv0.y)) * pi_deg;
    float s=sin(angle), c=cos(angle);
    uv *= mat2(c, -s, s, c);

   
    float d = length(uv);
        
    //Creates a scrolling color pattern
    vec3 col = palette(length(uv0) + iTime * .333 + max(uv.y/2.,uv0.x) - min(uv.x/2.,uv0.y));
    
    d = sin(d*3. * (sin(d * iTime / .3) + 1.3) + iTime) / 9.;
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