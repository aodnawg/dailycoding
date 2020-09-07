// @day 87
// @title
// @tag raymarching,digitalart,glsl,shader,creativecoding,cgi,generativeart

precision highp float;

uniform vec2 resolution;
uniform float time;
uniform vec2 mouse;

#define MIN_SURF 0.0001
#define MAX_DIST 100.
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
  float z = 1.;
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

vec2 pmod(vec2 p, float r) {
    float a =  atan(p.x, p.y) + PI/r;
    float n = PI*2. / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

float smin( float a, float b, float k ){
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

float torus(vec3 p) {
  p.xy *= rot(p.z*.4);
  p.xy *= rot(p.z*noise(time*.1*vec3(1.)*10.-20.));
  vec2 cp = vec2(length(p.xz)-2., p.y);
  cp *= rot(atan(p.z,p.x)*2.+time*.4);
  cp = pmod(cp, mix(1.,3.,noise(time*vec3(1.))))+vec2(0.,-1.);
  float d = length(cp)-.05;
  d /= 1.4+length(p);
  return d;
}

float map(vec3 p) {
  float d = torus(p);
  vec3 p_ = p;
  for(float i=0.;i<=3.;i++) {
    p_.xz *= rot(PI*.3);
    p_.xy *= rot(PI*.3*time);
    d = smin(d, torus(p_),.1);
  }
  return d;
}

void main(void) {
  vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
  float rt = time *.3 + 7891.22;
  float tn = noise(vec3(rt))*5.;
  vec3 ro = vec3(0.,0.,8.);
  vec3 lookat = vec3(0., 0., 0.);

  // initialize
  vec3 rd = makeRay(ro, lookat, uv);
  vec3 col = vec3(0.);
  float t = 0.;
  vec3 p;

  // ray march
  float s2=0.;
  for(int i = 0; i <= MAX_LOOP; i++) {
    p = ro+rd*t;
    float d = map(p);
    if(d>MAX_DIST) {
      col = vec3(1.);
      break;
    }
    if(d<MIN_SURF){
      break;
    }
    t += d;
    s2 += 1.;
  }

  col += vec3(.003)*s2;
  gl_FragColor = vec4(col, 1.);
}
