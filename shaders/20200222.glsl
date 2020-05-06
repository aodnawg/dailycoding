uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define MAX_MARCH_LOOP 100000
#define MIN_SURF 0.000001
#define MAX_DIST 10000.

precision highp float;

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

float random(in vec2 p) {
    return fract(sin(dot(p, vec2(13.12918, 54.12928))*12414.1214)*3857.100291);
}

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
		v += a * voronoi3d(x).x;
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void makeRoRd(out vec3 ro, out vec3 rd, in vec2 uv) {
    ro = vec3(0,-15,-3.4);
    
    vec2 mouse = (iMouse.xy-.5*iResolution.xy)/iResolution.y;
    vec3 lookat = vec3(mouse*10.,0);
    lookat = vec3(0, -5, 0);
    
    vec3 f = normalize(lookat-ro);
    vec3 r = cross(vec3(0,1,0),f);
    float z = 1.;
    vec3 u = cross(f,r);
    vec3 c = ro+f*z;
    vec3 i = c + uv.x*r + uv.y*u;
    rd = normalize(i-ro);
}

mat2 rot (float a) {
    return mat2(
        sin(a), cos(a), -sin(a), cos(a)
    );
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere(vec3 p) {
    return length(p-vec3(0))-1.; 
}

float sdNoise(vec3 p) {
    // p.xz *= rot(p.y);
    float wave = sin(iTime)*.05;
    //p.xz *= rot(iTime);
    vec3 p_ = p;

    p_ += iTime*.3;
    float d2 = fbm(p_)-.2;
    float t = 10.;
    float r = .3;
    return length(max(vec2(d2,abs(p.y)-t),0.0))-r;
}

float getDist(vec3 p) {
    // p.xz *= rot(iTime);

    float n = sdNoise(p*.5);
    p *= 1.+n*.2;
    float s = sdBox(p, vec3(1.8, 1000.,2.5));
    // s *= n;
    // return (s,max(n, s));
    return s;
}

void march(out vec3 hitPos, out float steps, in vec3 ro, in vec3 rd) {
    float t;
    vec3 p;
    for(int i=0; i <= MAX_MARCH_LOOP; i++) {
        p = ro+t*rd;
        float distance = getDist(p);
        distance = max(0.001, abs(distance));
        if(distance < MIN_SURF || distance > MAX_DIST) {
            break;
        }
        t += distance;
        steps += 1.; 
    }
    hitPos = p;
}

vec3 getNormal(vec3 p) {
	float d = getDist(p);
    vec2 e = vec2(.0001, 0);
    vec3 n = d - vec3(
        getDist(p-e.xyy),
        getDist(p-e.yxy),
        getDist(p-e.yyx));
    return normalize(n);
}

void main() {
    vec2 uv = (gl_FragCoord.xy - .5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);

    vec3 ro, rd;
    makeRoRd(ro, rd, uv);

    vec3 hitPos;
    float steps;
    march(hitPos, steps, ro, rd);

    vec3 n = getNormal(hitPos);

    // col = length(hitPos) < 1000. ? vec3(1,0,0) : vec3(0);
    float w = sin(iTime) * .25;
    col += pow(steps/600.,2.3+w);
    // col = n;


    vec3 f = (hitPos-ro);
    vec3 r = f+2.*n;
    vec3 lightPos = vec3(sin(iTime)*5.,5,cos(iTime)*5.); 
    // float s = clamp(0.,1.,dot(r, lightPos));
    // float def = clamp(0.,1.,dot(n, lightPos));
    // col += vec3(s)*.1+vec3(def)*.1;

    gl_FragColor = vec4(col, 1.);
}