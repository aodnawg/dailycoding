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

vec3 fold(vec3 p) {
  vec3 n = normalize(vec3(1.,0.,13.));
    p -= 2.0 * min(0.0, dot(p, n)) * n;
    return p;
}

float sdBox( vec3 p, vec3 b ) {
  vec3 q = abs(p) - b;
  return length(p.xy)-1.;
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

float map(vec3 p) {
  p.z += iTime*3.;
  p.xy *= rot(iTime*.3);
  p.xy *= rot(p.z*.1);
  float rs = length(p.xy)-1.;
  rs = 1.;
  float s = 2.;
  float os = 10.;
  for(int i=0; i<=4; i++) {
    s *= .6-sin(iTime)*.2-cos(iTime*2.)*.08+sin(iTime*3.)*.04;
    p.xy = pmod(p.xy, 3.);
    // p.xy *= rot(p.z*.01);

    p.y -= os*s*2.;
    rs = min(rs, length(p.xy)-s);
  }
  return rs/3.;
}

void main(void) {
  vec2 uv = (gl_FragCoord.xy-.5*resolution.xy)/resolution.y;
  float s = time*3.;
  vec3 ro = vec3(5.,5.,-15.)*1.+vec3(cos(iTime*.7), sin(iTime*.3), 0.)*4.;
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
    if(d>MAX_DIST||d<MIN_SURF) break;
    t += d;
    stp+=1.;
  }

  float m = stp/150.;
  col = vec3(pow(m,1.5));

  col = vec3(m);
  float fog = pow(t/60., 4.);
  col = mix(1.-col, vec3(0.), min(1., max(0., fog)));

  gl_FragColor = vec4(col, 1.);
}