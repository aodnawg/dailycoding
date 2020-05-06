uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define LOOP_MAX 1000
#define MAX_DIST 10000.
#define MIN_SURF .00001
#define PI 3.141593


float random(float n) { return fract(sin(n*217.12312)*398.2121561); }
float random(vec2 p) { return fract(sin(dot(p, vec2(98.108171, 49.10821)))*81.20914); }
float random(vec3 p) { return random(random(p.xy) + p.z); }
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
		x = x * 2. + shift;
		a *= 0.5555;
	}
	return v;
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c,s,-s,c);
}

vec2 pmod(vec2 p, float r) {
    float a =  atan(p.x, p.y) + PI/r;
    float n = PI*2. / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float smin( float a, float b, float k )
{
    a = pow( a, k ); b = pow( b, k );
    return pow( (a*b)/(a+b), 1.0/k );
}

float sdGyroid(in vec3 p, in float z) {
    return dot(sin(p*3.115*z), cos(p.zyx*3.12*z))/z*3.;
}

float map(vec3 p, vec3 ro, vec3 rd,  out vec3 cp) {
    cp = vec3(0.);
    float w = (sin(iTime)*.5+.5)*.5;
    p.y *= 1.-w;
    p.xz *= rot(p.y*sin(iTime)*10.);
    // p.zy *= rot(p.y*sin(iTime)*20.);
    float m = length(p)-1.;
    // p *= 10.;
    float z = 10.;
    vec3 gp = p+vec3(iTime*1.);
    float gl = pow(sin(iTime*.4)*.5+.5, 30.)*1.;
	float g = sdGyroid(gp, 2.*(1.+gl));
    float shape = sdBox(p, vec3(.2))/3.;
    float result = (shape-gl*.05)+g*.05+sdGyroid(gp, 3.)*.1;
    return result/2.5;
}

struct Trace {
    float d; bool isHit; float s;
};
Trace trace(vec3 ro, vec3 rd, out vec3 cp) {
    Trace mr;
    float t = 0.;
    float s = 0.;
    bool flag;
    for(int i=0; i<LOOP_MAX; i++) {
        vec3 p = ro+rd*t;
        float d = map(p, ro, rd, cp);
        // d = max(MIN_SURF+.0003+sin(iTime)*.00015, d);
        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./100.;
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
    // ro += vec3(0,0,0);
    vec3 lookat = vec3(0.);
    vec3 f = normalize(lookat-ro);
    vec3 r = cross(vec3(0,1,0), f);
    vec3 u = cross(f, r);
    float z = 1.2;
    vec3 c = ro+f*z;
    vec3 i = c+r*uv.x+u*uv.y;
    vec3 rd = normalize(i-ro);
    camera.ro = ro;
    camera.rd = rd;
    camera.z = z;
    return camera;
}

void main() {
    vec3 col = vec3(0.);
    vec2 uv = (gl_FragCoord.xy - iResolution.xy*.5)/iResolution.y;
    float s = iTime;
    Camera c = makeCam(uv, s);
    vec3 cp;
    Trace t = trace(c.ro, c.rd, cp);
    vec3 p =  c.ro+c.rd*t.d;
    float w = mix(.01,.02, sin(iTime)*.5+.5)*1.;
    // vec3 wc = w*vec3(.3+sin(iTime),.21,.32+sin(t.d*.5-iTime*30.)*.3)*1.;
    if(t.isHit) {
        col = vec3(.2)+cos(iTime*4.)*.05;
        float a = length(p-cp-vec3(sin(iTime)*.4, cos(iTime), 0.));
        float b = length(p-cp-vec3(0., cos(iTime)*.2, sin(iTime*.1)));
        float c = length(p-cp-vec3(cos(iTime)*.5, 0., sin(iTime*.4)));
        col += vec3(.4,1.,.2)*a*.3;
        col += vec3(.85,.3,1.)*b*.4;
        col += vec3(.56,.63,.2)*c*.3;
    } else {
        col = vec3(.2)+vec3(mix(vec3(.98,.68,.58),vec3(.98,.57,.68), noise(vec3(uv.y+iTime*.3,sin(iTime),1.))));
        
    }
    float v = pow(t.s,1.)*(t.d*w);
    float l = .1 + noise(vec3(iTime))*.4;
    col -= vec3(t.s*l);

    // col = cp;
    gl_FragColor = vec4(1.-col, 1.);
}