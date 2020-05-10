// @day 78
// @title Factory
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

// @refs https://iquilezles.org/www/articles/smin/smin.htm
float smin( float a, float b, float k )
{
    a = pow( a, k ); b = pow( b, k );
    return pow( (a*b)/(a+b), 1.0/k );
}

float map(vec3 p) {
  float noise = noise(p+vec3(time, 0., 0.));

  // move
  p.z += time;
  p.x += 10.;

  // z repeat
  float rp = 20.;
  p.z = mod(p.z-rp*.5, rp)-rp*.5;

  // fold
  for(int i=0; i<=4; i++) {
    p.xz = abs(p.xz);
    p.xz -= .5;
    p.xz *= rot(10.);
    p.x += .2+noise*(1./length(p.xz))*.4;
    p.yz *= rot(40.);
    p.yz *= rot(40.);
  }

  // wood
  float tw = p.y*noise*2.;
  p.xz *= rot(tw);
  p.xz = pmod(p.xz, 5.+5.*noise);
  p.z-=.5+noise*.3;
  p.xz *= rot(tw);
  p.xz = pmod(p.xz, 10.+sin(time)*4.);
  p.z-= .3;
  p.xz *= rot(tw);
  p.xz = pmod(p.xz, 10.);
  p.z-=.08;
  p.xz = pmod(p.xz, 10.);
  p.z-=.08;
  float r = length(p.xz)-.05;

  r = min(p.y+5., r);
  return r;
}

void main(void) {
  float noise = noise(vec3(time*.1))*.5;

  vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
  float s = time*3.;
  vec3 ro = vec3(1.2, .1, -3.) + vec3(noise);
  vec3 lookat = vec3(0, 0., 0.);

  // initialize
  vec3 rd = makeRay(ro, lookat, uv);
  vec3 col = vec3(0.);
  float t = 0.;
  vec3 p;

  // ray march
  float step=0.;
  for(int i = 0; i <= MAX_LOOP; i++) {
    p = ro+rd*t;
    float d = map(p);
    if(d>MAX_DIST || d<MIN_SURF) {
      break;
    }
    step += 1.;
    t += d;
  }

  float fog = t/90.;
  fog = pow(fog, 1.2);

  col = vec3(step/120.);
  col = pow(col, vec3(1.6));

  col = mix(col, vec3(1.), min(1., fog));
  gl_FragColor = vec4(col, 1.);
}
