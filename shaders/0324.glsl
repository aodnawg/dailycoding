precision highp float;

#define MIN_SURF 0.00001
#define MAX_DIST 100.
#define MAX_LOOP 1000
#define PI 3.1415926536

const mat2 myt = mat2(.12121212, .13131313, -.13131313, .12121212);
const vec2 mys = vec2(1e4, 1e6);



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

float random(float n) {
  return fract(sin(n*78.39817)*12.09834);
}
float random(vec2 p) {
  return fract(dot(p,vec2(21.41210, 98.14194))*10.12912)*87.21081;
}

mat2 rot(float a) {
  return mat2(cos(a), sin(a), -sin(a), cos(a));
}

vec3 sky(vec3 rd) {
  float n = max(0., rd.y);
  n += .5;
  return mix(vec3(.43, .65, .89), vec3(.8+sin(iTime*.3)*.1, .85, .93), n);
}

float spc(vec3 ray, vec3 normal, vec3 lightDir) {
	vec3 r = reflect(-lightDir, normal);
	return pow(max(dot(r, -ray), 0.0), 1.0);
}

float sdGyroid(in vec3 p) {
  p.xz *= rot(p.y*.4);
  p.y += iTime;
	float g = dot(sin(p*1.115), cos(p.zyx*1.12));
	return g/5.;
}

float sdSea(in vec3 p) {
  p.y += noise(vec3(p.xy, p.z+iTime*2.))*.2;
  return p.y+1.;
}

float sdSphere(in vec3 p, in bool glass) {
  p.y -= 7.;
  float s = length(p)-7.;
  float g = sdGyroid(p);
  if (glass) g *= -1.;
  s = max(s, g);
  return s;
}

vec3 getSphereNormal(in vec3 p, in bool glass) {
	float d = sdSphere(p, glass);
  vec2 e = vec2(.001, 0);
  vec3 n = d - vec3(sdSphere(p-e.xyy, glass), sdSphere(p-e.yxy, glass), sdSphere(p-e.yyx, glass));
  return normalize(n);
}

float traceSphere(
  in vec3 ro,
  in vec3 rd,
  out bool isHit,
  out float occ,
  in bool glass) {
  float t = 0.;
  occ = 0.;
  isHit = false;
  for(int i = 0; i< MAX_LOOP; i++) {
    vec3 p = ro+rd*t;
    float d = sdSphere(p, glass);
    if(d < MIN_SURF) {
      isHit = true;
      break;
    }
    if(d > MAX_DIST) break;
    t += d;
    occ += 1.;
  }
  occ /= 100.;
  occ = min(1., pow(occ, 1.));
  return t;
}

vec3 makeSphereColor(in vec3 ray, in vec3 n) {
  vec3 albd = vec3(1.);
  vec3 lg = vec3(cos(iTime),1,sin(iTime));
  float sp = spc(ray, n, lg);
  vec3 dif = vec3(.43,.48,.78)*(1.-n.y);
  dif += vec3(.98,.8,.38)*(1.-n.z);
  return albd - dif*.1 + sky(ray)*sp;
}

vec3 makeSeaColor(in vec3 n, in vec3 eye) {
  vec3 dif = vec3(.6,.98,.78)*(1.-n.y);
  return vec3(.92,.95,1.)-dif*2.;
}

vec3 getSeaNormal(in vec3 p) {
	float d = sdSea(p);
    vec2 e = vec2(.001, 0);
    vec3 n = d - vec3(
        sdSea(p-e.xyy),
        sdSea(p-e.yxy),
        sdSea(p-e.yyx));
    return normalize(n);
}

float traceSea(in vec3 ro, in vec3 rd, out bool isHit) {
  float t = 0.;
  isHit = false;
  for(int i = 0; i<MAX_LOOP; i++) {
    vec3 p = ro+rd*t;
    float d = sdSea(p);
    if(d<MIN_SURF) {
      isHit = true;
      break;
    }
    if(d>MAX_DIST) break;
    t += d;
  }
  return t;
}

vec3 makeRay(in vec3 ro, in vec2 uv) {
  float z = .4;
  vec3 lookat = vec3(0,4.+sin(iTime*.2)*2.,0);
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord.xy-.5*iResolution.xy)/iResolution.y;
  float cs = iTime * .1;
  vec3 ro = vec3(sin(cs)*12., 1., cos(cs)*12.);
  vec3 rd = makeRay(ro, uv);
 
  // initialize
  bool isHit; vec3 p, n, col; float t, occ;
  
  // render sky
  col = sky(rd);

  // trace glass
  t = traceSphere(ro, rd, isHit, occ, true);
  if(isHit){
    n = getSphereNormal(ro+rd*t, true);
  }
  rd = makeRay(ro, uv+n.xy);
  
  // tracing sea
  vec3 seP;
  t = traceSea(ro, rd, isHit);

  if(isHit) {
    // render sea
    seP = ro+rd*t;
    vec3 seN = getSeaNormal(seP);
    vec3 eye = normalize(seP - ro);
    vec3 scl = col;
    vec3 ld = vec3(0,1,0);
    p = ro+rd*t+ld*MIN_SURF;
    bool isHit_;
    eye = normalize(p-ro);
    n = getSeaNormal(p);

    // reflection of sphere
    vec3 r = reflect(eye, n);
    float t = traceSphere(p, r, isHit_, occ, false);
    if(isHit_) { 
      p = p+r*t;
      n = getSphereNormal(p, false);
      vec3 c = makeSphereColor(normalize(p-ro), n)*.96;
    } else {
      col += occ;
    }
  }

  // render sphere
  t = traceSphere(ro, makeRay(ro, uv), isHit, occ, true);
  if(isHit) {
    p = ro+rd*t;
    n = getSphereNormal(p, true);
    col += makeSphereColor(normalize(p-ro), n)*.05;
  }
  col += occ/(20.+sin(iTime)*5.);

  float pw = 1.8;
  col = vec3(
    pow(col.r, pw),
    pow(col.g, pw),
    pow(col.b, pw)
  );

  fragColor = vec4(col, 1.);
}