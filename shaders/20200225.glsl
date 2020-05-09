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

////////////////////////

struct Camera {
    vec3 ro; vec3 rd; float z;
};
Camera makeCam(in vec2 uv, float s) {
    Camera camera;
    vec3 ro = vec3(0,0,-3);
    ro = vec3(cos(s),0,sin(s))*3.;
    vec3 lookat = vec3(0);
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



////////////////////////

float sdNoise(vec3 p) {
    p *= 1.;
    p.z += iTime;
    float n = fbm(p + fbm(vec3(p.xy, p.z + iTime)));
    return pow(length(n)-.3, 1.0);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float map(vec3 p) {
    float n = sdNoise(p);
    // return length(p)-1.;

    float m = length(p)-5.;
    return max(n,m);
}

// float mapS(vec3 p) {
//     float r=.5;
//     r *= 1.+fbm(p*.2)*5.;
//     float s = length(p)-r;
//     return s;
// }

float mapS(vec3 p) {
    float r=.5;
    r *= 1.+fbm(p*.2 + fbm(vec3(p.xy, iTime*2.))*.3)*5.;
    float s = length(p)-r*.7;
    return s;
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
        d = max(abs(MIN_SURF+0.001), d);
        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./1000.;
    }
    mr.d = t;
    mr.s = s;
    mr.isHit = flag;
    return mr;
}

Trace sTrace(vec3 ro, vec3 rd) {
    Trace mr;

    float t = 0.;
    float s = 0.;

    bool flag;
    for(int i=0; i<100; i++) {
        vec3 p = ro+rd*t;
        float d = mapS(p);

        if(d<0.001) {
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
    return mr;
}

vec3 getNormal(vec3 p){
    float d = 0.0001;
    return normalize(vec3(
        map(p + vec3(  d, 0.0, 0.0)) - map(p + vec3( -d, 0.0, 0.0)),
        map(p + vec3(0.0,   d, 0.0)) - map(p + vec3(0.0,  -d, 0.0)),
        map(p + vec3(0.0, 0.0,   d)) - map(p + vec3(0.0, 0.0,  -d))
    ));
}

vec3 getSNormal(vec3 p){
    float d = 0.0001;
    return normalize(vec3(
        mapS(p + vec3(  d, 0.0, 0.0)) - mapS(p + vec3( -d, 0.0, 0.0)),
        mapS(p + vec3(0.0,   d, 0.0)) - mapS(p + vec3(0.0,  -d, 0.0)),
        mapS(p + vec3(0.0, 0.0,   d)) - mapS(p + vec3(0.0, 0.0,  -d))
    ));
}

void main() {
    vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);
    float s = iTime * .1;

    Camera cam = makeCam(uv, s);
    Trace trace_ = trace(cam.ro, cam.rd); 

    // vec3 n;
    // if(trace_.isHit) n = getNormal(cam.ro+cam.rd*trace_.d);
    // col = n;

    Trace sd = sTrace(cam.ro, cam.rd);
    vec3 sp = cam.ro+cam.rd*sd.d;
    vec3 spN = getSNormal(sp);
    if (sd.d<MAX_DIST) {
        col = spN;
        Trace t_ = trace(sp, spN);
        col = vec3(t_.s);
        col += vec3(sd.s)*.2;
    }

    col += vec3(trace(cam.ro, cam.rd).s)*.1;

    gl_FragColor = vec4(col, 1.);
}
