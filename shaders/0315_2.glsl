#define LOOP_MAX 1000
#define MAX_DIST 1000.
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

float sdGyroid(in vec3 p, in float z) {
    return dot(sin(p*3.115*z), cos(p.zyx*3.12*z))/z*3.;
}

float map(vec3 p) {
    p.x *= 1.4;
    p.xz *= rot(p.y*5.*sin(10.)+iTime*.1);
    p.y *= .1;
    float r = 1.;
    float glt = pow(noise(vec3(iTime*5.)), 1.5);
    // r *= 1.-glt*sin(p.y*100.);
    float s = length(p)-r;
    vec3 gp = p+vec3(0,0,iTime);
    s += sdGyroid(gp, .5)*.02;
    float gl = 1.+pow(abs(sin(iTime*.1)),30.)*1.5;
    s -= pow(fbm(p*glt), 4.)*gl;
    return s/8.;
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
        float d = map(p);
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

vec3 getNormal(vec3 p){
    float d = 0.001;
    return normalize(vec3(
        map(p + vec3(  d, 0.0, 0.0)) - map(p + vec3( -d, 0.0, 0.0)),
        map(p + vec3(0.0,   d, 0.0)) - map(p + vec3(0.0,  -d, 0.0)),
        map(p + vec3(0.0, 0.0,   d)) - map(p + vec3(0.0, 0.0,  -d))
    ));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord.xy - iResolution.xy*.5)/iResolution.y;
    vec3 col = vec3(0.);
    float s = iTime;
    Camera c = makeCam(uv, s);
    vec3 cp;
    Trace t = trace(c.ro, c.rd, cp);
    vec3 p =  c.ro+c.rd*t.d;
    float w = mix(.01,.02, sin(iTime)*.5+.5)*1.;
    if(t.isHit) {
        vec3 n = getNormal(p)*.5+.5;
        n*=.3+sin(iTime)*.1;
        col = vec3(.2);
        col += dot(n, vec3(cos(iTime),sin(iTime), 0.))*vec3(.7,.1,.8)*1.;
        col += dot(n, vec3(0.,cos(iTime*.4),sin(iTime*.2 + 10.)))*vec3(1.,.3,.2)*1.;
        col += dot(n, vec3(0.,cos(iTime*2.+12.54),sin(iTime*3.+19.56)))*vec3(1.,.3,.65)*1.;
        col -= t.s*length(p.xz)*.1;
    }

    fragColor = vec4(col, 1.);
}