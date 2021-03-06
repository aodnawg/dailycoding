precision highp float;

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;
#define iResolution resolution
#define iTime time
#define iMouse mouse

#define MIN_SURF 0.0001
#define MAX_DIST 300.
#define MAX_LOOP 1000
#define PI 3.141593

mat2 rot(float a) {
  return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float random(float n) {
    return fract(sin(n*318.154121)*31.134131);
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

vec3 makeRay(in vec3 ro, in vec3 lookat, in vec2 uv) {
  float z = .3;
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

float map(vec3 p) {
  float n = noise(p*1.5);
  p.xy *= rot(dot(p.y, dot(p.z, p.y))*.01);
  p.z += time;
  float z = 3.;
  p = mod(p, z)-z*.5;

  float g = .1+step(.8, random(floor(time*3.)));
  float b = 0.01+n*g;
  float r = length(p.xz)-b;
  r = min(r, length(p.xy)-b);
  r = min(r, length(p.yz)-b);

  return r/6.;
}

vec3 getNormal(vec3 p){
    float d = 0.001;
    return normalize(vec3(
        map(p + vec3(  d, 0.0, 0.0)) - map(p + vec3( -d, 0.0, 0.0)),
        map(p + vec3(0.0,   d, 0.0)) - map(p + vec3(0.0,  -d, 0.0)),
        map(p + vec3(0.0, 0.0,   d)) - map(p + vec3(0.0, 0.0,  -d))
    ));
}

void main(void) {
  vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
  float s = time*3.;
  vec3 ro = vec3(0.,0.,-3);
  vec3 lookat = vec3(0);

  // initialize
  vec3 rd = makeRay(ro, lookat, uv);
  vec3 col = vec3(0.);
  float t = 0., stp=0.;
  vec3 p;

  // ray march
  for(int i = 0; i <= MAX_LOOP; i++) {
    p = ro+rd*t;
    float d = map(p);
    if(d>MAX_DIST) break;
    if(d<MIN_SURF) {
      vec3 n = getNormal(p);
      n*=.5;
      n+=.5;
      col = vec3(1.);
      col -= vec3(1.-n.y*.1);
      break;
    }
    t += d;
    stp+=1.;
  }

  float m = stp/250.;
  m = pow(m, 1.2)*.3;
  col -= m*vec3(sin(t*1.2),sin(t*.1),cos(t*.98))*vec3(.87,.78,.91);
  float fog = pow(t/15., 6.);
  col = mix(1.-col, vec3(1.), min(1., max(0., fog)));

  col = pow(col, vec3(2.2,1.52,.51));

  gl_FragColor = vec4(col, 1.);
}