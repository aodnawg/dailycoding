precision highp float;

#define MIN_SURF 0.000001
#define MAX_DIST 300.
#define MAX_LOOP 1000
#define PI 3.1415926536

float random(float n) {
  return fract(sin(n*78.39817)*12.09834);
}

float random(vec2 p) {
  return fract(dot(p,vec2(21.41210, 98.14194))*10.12912)*87.21081;
}

mat2 rot(float a) {
  return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float sdGyroid(in vec3 p) {
  p.xz *= rot(p.y*.4);
  p.y += iTime;
	float g = dot(sin(p*1.115), cos(p.zyx*1.12));
	return g/5.;
}

vec3 makeRay(in vec3 ro, in vec3 lookat, in vec2 uv) {
  float z = .4;
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

float map(vec3 p) {
  p.xy *= rot(p.z*.1+iTime*p.z*.01);
  p = mod(p-5., 10.)-5.;
  float g = sdGyroid(p);
  float r= length(p*.5)-1.7;
  r = max(g, r);
  return r/10.;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy)/iResolution.y;
  float s = iTime*3.;
  vec3 ro = vec3(0,0,-3)+vec3(0,0,s);
  vec3 lookat = vec3(0)+vec3(0,0,s);

  // glitch
  float glt = step(.6, random(floor(iTime*10.)))*random(iTime)*50.;
  float glt2 = step(.85, random(floor(iTime*10.)+12.412))*50.;
  uv += sin(random(floor(uv*glt)))*.01*glt2;

  // initialize
  vec3 rd = makeRay(ro, lookat, uv);
  vec3 col;
  float t = 0., stp=0.;
  vec3 p;

  // ray march
  for(int i = 0; i <= MAX_LOOP; i++) {
    p = ro+rd*t;
    float d = map(p);
    d = max(0.00002, abs(d));
    if(d>MAX_DIST||d<MIN_SURF) break;
    t += d;
    stp+=1.;
  }

  float m = stp/1000.;
  m = mix(m, 0., t/150.); // fog
  m = pow(m, 5.5); // contrast
  col = mix(vec3(.43, .65, .89), vec3(.8+sin(iTime*.3)*.1, .85, .93), m);

  fragColor = vec4(col, 1.);
}