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

vec3 makeRay(in vec3 ro, in vec3 lookat, in vec2 uv) {
  float z = .5;
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

float smin( float a, float b, float k ){
  float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
  return mix( b, a, h ) - k*h*(1.0-h);
}

vec2 pmod(vec2 p, float r) {
    float a =  atan(p.x, p.y) + PI/r;
    float n = PI*2. / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

// https://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdRing(vec3 p, float d) {
  vec3 tp = p;
  tp.y = abs(tp.y);
  tp.y -= d/30.;
  float r = sdTorus(tp, vec2(d,d/150.));
  vec3 pp = p;
  pp.xz *= rot(p.y*.1);
  pp.xz = pmod(pp.xz, 64.);
  pp.z -= d;
  float rp = length(pp.xz)-d/150.;
  rp = max(tp.y, rp);
  r = smin(r, rp, .1);
  return r;
}

float map(vec3 p) {
  p.xz *= rot(time);
  p.xz *= rot(p.y*.1);
  p.xy *= rot(p.z*.1);

  float r = length(p+vec3(0,sin(time)*.5,0))-1.;
  float d = 2.;
  for(int i=0; i<=7; i++) {
    float idx = floor(random(d)*5.);
    d *= 1.5;
    p.xz *= rot(time*.4);
    float a = idx+2.;
    p.yz = pmod(p.yz, a);
    r = min(r, sdRing(p,d));
  }
  return r/5.;
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
  vec3 ro = vec3(10.,10.,-15.);
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
      col -= vec3(1.-n.y*.2);
      break;
    }
    t += d;
    stp+=1.;
  }

  float m = stp/150.;
  float fog = pow(t/25., 4.);
  col = mix(1.-col, vec3(1.), min(1., max(0., fog)));

  gl_FragColor = vec4(col, 1.);
}