uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define LOOP_MAX 1000
#define MAX_DIST 1000.
#define MIN_SURF .0001
float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}
float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}
float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < 7; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

mat2 rot(float a) {
    return mat2(
        cos(a), sin(a), -sin(a), cos(a)
    );
}

float smin( float a, float b, float k )
{
    a = pow( a, k ); b = pow( b, k );
    return pow( (a*b)/(a+b), 1.0/k );
}

float random(float n) {
    return fract(sin(n*217.12312)*398.2121561);
}

float random(vec2 p) {
    return fract(
        sin(dot(p, vec2(98.108171, 49.10821)))*81.20914
    );
}

float random(vec3 p) {
    return random(random(p.xy) + p.z);
}

float sdTorus( vec3 p, vec2 t )
{
    float glitch = random(floor(iTime*8.))*1.5;
    p.z += iTime;
    p.xy *= rot(iTime+.01);
    p.xy *= rot(length(p*glitch*.1));
    p = mod(p, 4.) - 2.;
  vec2 q = vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}

float sdMoon(vec3 p, float s) {
    float r = random(floor(length(p*2.)));
    p.xz *= rot(r)+iTime;

    vec3 bodyP = p;
    float glitch = random(floor(s*.5))*1.5;
    float bn = 1.+fbm(bodyP*8.*fract(s))*glitch;
    float body = length(p+vec3(0,sin(iTime)*.1,0))-.5*bn;

    vec3 satP = p;
    satP += vec3(sin(s),0.,cos(s));
    satP.xy *= rot(s*2.+iTime);
    float sat = length(satP)-.1;

    vec3 satP2 = p;
    satP2 += vec3(cos(s),0.,sin(s))*1.5;
    satP2.xy *= rot(s*4.+iTime);
    float sat2 = length(satP2)-.1;

    float smin1 = smin(body, sat, 30.+sin(s*2.)*10.);
    float smin2 = smin(smin1, sat2, 30.+sin(s*2.)*10.);

    return smin2;
}

float sdSea(vec3 p) {
    return max(p.y-0.2, p.z-10.) + fbm(vec3(p.xy, p.z+fbm(p)*fract(iTime)*10.))*2.;
}

float map(vec3 p) {
    float torus = sdTorus(p, vec2(.5, .1));
    vec3 sp = p;
    float glitch = step(.6, random(floor(iTime*.5)))*2.;
    float bn = 1.+fbm(sp*8.*fract(iTime))*glitch;
    float moon = length(sp) - .5-bn*.5 * abs(sin(random(floor(sp.y*20.))+iTime));


    return min(torus, moon);
}

struct Trace {
    float d; bool isHit; float s;
};
Trace trace(vec3 ro, vec3 rd) {
    Trace mr;
    float t = 0.;
    float s = 0.;
    bool flag;
    for(int i=0; i<LOOP_MAX; i++) {
        vec3 p = ro+rd*t;
        float d = map(p);
        // d = max(abs(MIN_SURF+0.001), d);
        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./150.;
    }
    mr.d = t;
    mr.s = s;
    mr.isHit = flag;
    return mr;
}

struct Camera {
    vec3 ro; vec3 rd; float z;
};
Camera makeCam(in vec2 uv, float s) {
    Camera camera;
    vec3 ro = vec3(0,0,-3);
    // ro = vec3(cos(s),0,sin(s))*3.;
    vec3 lookat = vec3(0,0,0);
    vec3 f = normalize(lookat-ro);
    vec3 r = cross(vec3(0,1,0), f);
    vec3 u = cross(f, r);
    float z = 1.;
    vec3 c = ro+f*z;
    vec3 i = c+r*uv.x+u*uv.y;
    vec3 rd = normalize(i-ro);

    camera.ro = ro;
    camera.rd = rd;
    camera.z = z;
    return camera;
}

vec3 getNormal(vec3 p){
    float d = 0.0001;
    return normalize(vec3(
        sdSea(p + vec3(  d, 0.0, 0.0)) - sdSea(p + vec3( -d, 0.0, 0.0)),
        sdSea(p + vec3(0.0,   d, 0.0)) - sdSea(p + vec3(0.0,  -d, 0.0)),
        sdSea(p + vec3(0.0, 0.0,   d)) - sdSea(p + vec3(0.0, 0.0,  -d))
    ));
}

void main() {
    vec2 uv = (gl_FragCoord.xy-iResolution.xy*.5)/iResolution.y;
    vec3 col = vec3(0.);


    float s = iTime;
    Camera cam = makeCam(uv, s);
    Trace t_ = trace(cam.ro, cam.rd);

    vec3 tp = cam.ro+cam.rd*t_.d;
    vec3 tn = getNormal(tp);
    Trace ref = trace(tp, tn);

    // col = tn;

    if(ref.isHit) {
        col = vec3(ref.s)*10.;
        col = vec3(0);
    }

    float m = t_.s;
    col += vec3(m);

    if(!t_.isHit) {
        col = vec3(pow(1.-uv.y-.3, 1.5 + sin(iTime)*.1));
    }

    gl_FragColor = vec4(col, 1.);
}
