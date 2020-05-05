vec3 makeRay(in vec3 ro, in vec2 uv) {
  float z = 1.;
  vec3 lookat = vec3(0.);
  vec3 f = normalize(lookat-ro);
  vec3 r = cross(vec3(0,1,0), f);
  vec3 u = cross(f, r);
  vec3 c = ro+f*z;
  vec3 i = c+r*uv.x+u*uv.y;
  vec3 rd = normalize(i-ro);
  return rd;
}

mat2 rot(float a){
  return mat2(cos(a), sin(a), -sin(a), cos(a));
}

float map(in vec3 p) {
  p = mod(p, 4.)-2.;


  p.xy *= rot(p.z);
  p.y += 1.;
  p.z = mod(p.z, 1.)-.5;
  float r = length(p)-.5;
  return r/24.;
}

float makeSpecular(in vec3 n, in vec3 ray, in vec3 light) {
	vec3 r = reflect(-light, n);
	return pow(max(dot(r, -ray), 0.0), 3.0);
}

vec3 getSphereNormal(in vec3 p) {
	float d = map(p);
  vec2 e = vec2(.001, 0);
  vec3 n = d - vec3(map(p-e.xyy), map(p-e.yxy), map(p-e.yyx));
  return normalize(n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord.xy - .5*iResolution.xy)/iResolution.y;
  vec3 ro = vec3(0,0,-3);
  vec3 rd = makeRay(ro, uv);
  vec3 col = vec3(0.);

  vec3 p;
  float t = 0.;
  float step = 0.;
  for(int i=0; i<=100; i++){
    p = ro+rd*t;
    float d = map(p);
    if(d < 0.001 || d > 100.) break;
    t += d;
    step += 1.;
  }

  float spc = makeSpecular(
    normalize(p-ro),
    getSphereNormal(p),
    vec3(0,1,0)
  );

  col = vec3(step)/100.;
  col += spc;

  fragColor = vec4(col, 1.);
}