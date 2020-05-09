uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define PI 3.141593

precision highp float;
const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
const vec2 mys = vec2(1e4, 1e6);

float random(float n) {
    return fract(sin(n*318.154121)*31.134131);
}

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
	for (int i = 0; i < 5; ++i) {
		v += a * voronoi3d(x).x;
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

void makeRoRd(in vec2 uv, out vec3 ro, out vec3 rd) {
    ro = vec3(0,0,-5);
    // vec2 mou = (iMouse.xy/iResolution.xy-.5) * 10.;
    vec3 lookat = vec3(0,0,0);
    vec3 f = normalize(lookat-ro);
    float z = 1.;
    vec3 c = ro+f*z;
    vec3 r = cross(vec3(0,1,0), f);
    vec3 u = cross(f, r);
    vec3 i = c + uv.x * r + uv.y * u;
    rd = normalize(i-ro);
}

mat2 rot (float a) {
    return mat2(
        cos(a), sin(a),
        -sin(a), cos(a)
    );
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdNoise(vec3 p) {
    float wave = sin(iTime)*.05;
    float d2 = fbm(vec3(p.x+iTime*2., p.yz))-.15 + wave;
    float r = .5;
    return length(d2)-r;
}

float getDist(in vec3 p) {
    p.y += iTime*.1;
    p.xz *= rot(iTime*.1);
    // p.yz *= rot(iTime*.3);
    p.xz *= rot(p.y+iTime);
    // p.yz *= rot(iTime*.1);
    // vec3 nP = p * p.y;
    float n = sdNoise((p+vec3(iTime*.1,0.,0.)));
    float tick = .5 + (sin(iTime)+1.);
    float mask = max(
        -sdBox(p, vec3(1.,1000.,1.)),
        sdBox(p, vec3(1.+tick,1000.,1.+tick))
    );
    float d = max(-n, mask);
    return d;
}

void march(
    out vec3 hitPos,
    out float step,
    out vec3 col_,
    in vec3 ro,
    in vec3 rd
) {
    float t=0.;
    for(int i=0; i<=3500; i++) {
        vec3 p = ro+rd*t;
        float dS = getDist(p);
        // dS = max(0.0002, abs(dS));
        if(dS<0.00001) {
            hitPos = p;
            col_ = vec3(1.,.5,.01);
            break;
        }
        if(t>1000.) {
            hitPos = vec3(100000.);
            col_ = vec3(0.);
            break;
        };
        t += dS;
        step += 1./150.;
    }
}

vec3 GetNormal(vec3 p) {
	float d = getDist(p);
    vec2 e = vec2(.00001, 0);
    vec3 n = d - vec3(
        getDist(p-e.xyy),
        getDist(p-e.yxy),
        getDist(p-e.yyx));
    
    return normalize(n);
}



void main()
{
    vec2 uv = (gl_FragCoord.xy-.5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);

    vec3 ro,rd;
    makeRoRd(uv, ro, rd);

    float t=0., step_=0.;
    vec3 hitPos, col_;
    march(hitPos, step_, col_, ro, rd);

    float light = pow(step_, 1.8 + sin(iTime)*1.);
    float m = dot(vec3(0,5,0), GetNormal(hitPos));
    float cnd = step(.5, random(floor(iTime*5.)));
    if ( cnd > .5) {
        col += vec3(m)*.01;
    }
    
    col += vec3(1.)*light*4.;

    gl_FragColor = vec4(col,1.0);
}