uniform vec2 iResolution;
uniform float iTime;
uniform float sphereDist = 1;
uniform float timeFactor = 1; 
uniform float clrFactor = 1;
uniform float clrThreshold = .05;
uniform float iterations = 80;
uniform float flashSpeedFactor = 1;

float sdSphere(vec3 p, float s){
    return length(p) -s;
}

float sdBox(vec3 p, vec3 b){
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

mat2 rot2D(float a) {
    return mat2(cos(a), -sin(a), sin(a), cos(a));
}

vec3 rot3D(vec3 p, vec3 axis, float angle){

    return mix(dot(axis,p) * axis, p , cos(angle)) + cross(axis,p) * sin(angle);
}


// circular smoothed minimum
float smin( float a, float b, float k )
{
    k *= 1.0/(1.0-sqrt(0.5));
    float h = max( k-abs(a-b), 0.0 )/k;
    return min(a,b) - k*0.5*(1.0+h-sqrt(1.0-h*(h-2.0)));
}

vec3 palette(float t){

    vec3 a = vec3(0.821 * clrFactor, 0.328, 0.242); 
    vec3 b = vec3(0.659 * clrFactor, 0.481, 0.896); 
    vec3 c = vec3(-0.782 * clrFactor, 1.000, 1.000); 
    vec3 d = vec3(-2.752 * clrFactor, 0.333, 0.667);
    
    //makes colors flash
    c+= timeFactor * 555.  * sin(55.55  * iTime) / 555555. * flashSpeedFactor;
    
    return a + b*cos(6.28318*(c*t+d));;

}

// Maps 3d objects in scene
float map(vec3 p) {

    float time = iTime * timeFactor;

    float y = 1.5 * cos(time * 2.);
    float x = .9 * 10. * (cos(time) / 3.);
    float z = sin(time);
    float maxX = sphereDist;
    x = clamp(x,-maxX,maxX);

    vec3 spherePos = vec3(x,y,z);
    
    vec3 q = p;
    
    float spSize = .8 + .1 * sin(time * .33);
    
    float sphere = sdSphere(p - spherePos, spSize);
    float sphere2 = sdSphere(p + spherePos, spSize);
    
    q.xz *= rot2D(time / .3); //rotates around omitted axis 
    
    float box = sdBox(q, vec3(1.1 + .1 * sin(time * .33)));
    
    float ground = p.y + 3.5;
    
    return smin(ground, smin(box,smin(sphere,sphere2,.15), 0.33),.05);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y;
    
    // Initialization
    vec3 ro = vec3(0, 0, -3.3);         // ray origin
    vec3 rd = normalize(vec3(uv, 1)); // ray direction
    vec3 col = vec3(0);               // final pixel color

    float t = 0.; // total distance travelled
        


    int i;
    
    // Raymarching
    for (i = 0; i < iterations; i++) {
        vec3 p = ro + rd * t;     // position along the ray

        float d = map(p);         // current distance to the scene

        t += d;                   // "march" the ray

        if (d < .001) break;      // early stop if close enough
        if (t > 100.) break;      // early stop if too far
    }

    // Coloring
    col = palette(t*.00046 + float(i)* clrThreshold);
    //col = vec3(t * .46);           // color based on distance
    fragColor = vec4(col, 2);
}

void main() {
mainImage(gl_FragColor,gl_FragCoord.xy);
}

