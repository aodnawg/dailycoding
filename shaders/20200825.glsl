// @day 85
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

float makeA(vec3 p) {
  return length(p)-2.;
}

float makeB(vec3 p) {
  p.z -= .48;
  return length(p)-1.7;
}

float makeC(vec3 p) {
  p.z -= 2.;
  return length(p)-.45;
}

struct I {
  float d;
  vec3 c;
};

I preMap(vec3 p) {
  // p.xy *= rot(noise(vec3(time*.1, 0., 0.))*30.);
  p.zx *= rot(noise(vec3(0., time*.1, 0.))*50.);

  float a = makeA(p);
  float b = makeB(p);
  float c = makeC(p);

  I i;
  float result = max(min(a, b), -c)/1.;
  vec3 color = result < a ?
    vec3(.93,.98,.96) :
    result < c ? vec3(1.,0.03,0.09) :
    vec3(0.22,.16,.97);

  i.d = result;
  i.c = color;

  return i;
}

I map(vec3 p) {
  p.xy *= rot(p.z*.01);

  p.z += time*10.;
  p = mod(p-20., 50.) - 20.;

  p.xz *= rot(time);
  vec3 p2 = p;
  vec3 p3 = p;

  float tnoise = noise(vec3(time));
  float n = 5.;

  p.yz = pmod(p.yz, 10.);
  p.z -= 10.;
  I result = preMap(p*1.4);

  p2.yz = pmod(p2.yz, 7.);
  p2.z -= 10.;
  p2.y += .5;
  I result2 = preMap(p2*1.2);

  p3.yz *= rot(time);
  p3.yz = pmod(p3.yz, 9.);
  p3.z -= 10.;
  p3.x += noise(p);
  I result3 = preMap(p3*.9);

  I r;
  r.d = smin(smin(result.d, result2.d, 2.), result3.d, 2.)/1.5;
  r.d /= 1.+length(p.xy)*.05;
  r.c = result.d > result2.d ? result2.c : result.c;
  return r;
}

void main(void) {
  vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
  float rt = time *.3 + 7891.22;
  float tn = noise(vec3(rt))*5.;
  vec3 ro = vec3(0.,0.,50.);

  vec3 lookat = vec3(0, noise(vec3(time*.3))*3., 0.);

  // initialize
  vec3 rd = makeRay(ro, lookat, uv);
  vec3 col = vec3(0.);
  float t = 0.;
  vec3 p;

  // ray march
  I intersect;
  float s2=0.;
  for(int i = 0; i <= MAX_LOOP; i++) {
    p = ro+rd*t;
    intersect = map(p);
    float d = intersect.d;
    if(d>MAX_DIST) {
      intersect.c = vec3(0.);
      break;
    }
    if(d<MIN_SURF){
      break;
    }
    t += d;
    s2 += 1.;
  }

  col = intersect.c - (1.-vec3(0.02)*s2);
  gl_FragColor = vec4(col, 1.);
}
