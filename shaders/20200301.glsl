uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define LOOP_MAX 100000
#define MAX_DIST 10.
#define MIN_SURF .00001
#define PI 3.141593

const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
const vec2 mys = vec2(1e4, 1e6);

vec2 rhash(vec2 uv) {
  uv *= myt;
  uv *= mys;
  return fract(fract(uv / mys) * uv);
}

vec3 hash(vec3 p) {
  return fract(
      sin(vec3(dot(p, vec3(1.0, 57.0, 113.0)), dot(p, vec3(57.0, 113.0, 1.0)),
               dot(p, vec3(113.0, 1.0, 57.0)))) *
      43758.5453);
}

vec3 voronoi3d(const in vec3 x) {
  vec3 p = floor(x);
  vec3 f = fract(x);

  float id = 0.0;
  vec2 res = vec2(100.0);
  for (int k = -1; k <= 1; k++) {
    for (int j = -1; j <= 1; j++) {
      for (int i = -1; i <= 1; i++) {
        vec3 b = vec3(float(i), float(j), float(k));
        vec3 r = vec3(b) - f + hash(p + b);
        float d = dot(r, r);

        float cond = max(sign(res.x - d), 0.0);
        float nCond = 1.0 - cond;

        float cond2 = nCond * max(sign(res.y - d), 0.0);
        float nCond2 = 1.0 - cond2;

        id = (dot(p + b, vec3(1.0, 57.0, 113.0)) * cond) + (id * nCond);
        res = vec2(d, res.x) * cond + res * nCond;

        res.y = cond2 * d + nCond2 * res.y;
      }
    }
  }

  return vec3(sqrt(res), abs(id));
}
float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < 7; ++i) {
		v += a * voronoi3d(x).x;
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
  vec2 q = vec2(length(p.xy)-t.x,p.z);
  return length(q)-t.y;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

vec3 fold(vec3 p, float s) {
    p = mod(p, 3.) -1.5;
    float o = -.001;
    p = abs(p);
    p += vec3(o,0.,0.);
    p.yz *= rot(s);
    p = abs(p);
    p += vec3(0.,o,0.);
    p.xz *= rot(s);
    p = abs(p);
    p += vec3(0.,0., o);
    p.xy *= rot(s);
    return p;
}

float sdSea(vec3 p) {
    float h = fbm(p*.7+fbm(vec3(p.xy, p.z+iTime)))*.7;
    return max(p.y+h+.5, p.z-10.);
}

float sdMask(vec3 p) {
    p.xz *= rot(p.y*4.+iTime);
    p.x += .5;
    return length(p.xz)-.4;
}

float map(vec3 p) {    
    p.yz *= rot(PI*.5);
    vec3 p_ = p;
    p_ *= 1.;
    float m = fbm(p_+fbm(vec3(p_.xy, p_.z+iTime)))-.5;
    float msk = sdMask(p);
    // return msk;
    return max(m, msk);
}

struct Trace {
    float d; bool isHit; float s;
};
Trace trace(vec3 ro, vec3 rd, float g) {
    Trace mr;
    float t = 0.;
    float s = 0.;
    bool flag;


    for(int i=0; i<LOOP_MAX; i++) {
        vec3 p = ro+rd*t;
        float d = map(p);
        if(g > 0.) {
            d = max(abs(MIN_SURF+0.01), d);
        }
        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./200.;
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
    vec3 ro = vec3(0.,0.,-3.+s);
    // ro += noise(vec3(uv, s))*.01;
    // ro = vec3(cos(s),0,sin(s))*3.;
    vec3 lookat = vec3(0.,0.,+s);
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
    float g_ = step(.85, random(floor(iTime*5.)+38.1412));
    if(g_ > 0.) {
        uv.y += sin(step(.8, random(fract(uv.y*5.)+iTime)))*.01;
    }

    vec3 col = vec3(0.);
    float g = step(.25, random(floor(iTime*10.)));


    float s = iTime;
    Camera cam = makeCam(uv, s);
    Trace t_ = trace(cam.ro, cam.rd, g);

    vec3 tp = cam.ro+cam.rd*t_.d;

    float m = t_.s;
    col += vec3(m);

    


    gl_FragColor = vec4(col, 1.);
}