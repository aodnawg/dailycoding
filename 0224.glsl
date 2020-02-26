#define MAX_LOOP 1000
#define MIN_SURF 0.0001
#define MAX_DIST 10000.
#define PI 3.141593

precision highp float;

mat2 rot(float a) {
    return mat2(
        cos(a), sin(a), -sin(a), cos(a)
    );
}

vec3 getRayDirection(in vec3 ro, in vec3 lookat, in vec2 uv, float z) {
    vec3 f = normalize(lookat-ro);
    vec3 r = normalize(cross(vec3(0,1,0),f));
    vec3 u = cross(f,r);
    vec3 c = ro+f*z;
    vec3 i = c+u*uv.y+r*uv.x;
    return normalize(i-ro);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float hash(vec2 n)
{
    return fract(sin(dot(n, vec2(123.0, 458.0))) * 43758.5453);
}

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
	for (int i = 0; i < 7; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

float sdNoise(vec3 p) {
    p = floor(p * 4.);
    float n_ = hash(p.xy * p.z*98.114);
    float d2 = n_;
    float r = .5;
    return length(max(vec2(d2),0.0))-r;
}

float sdCylinder( vec3 p, vec3 c )
{
  return length(p.xz-c.xy)-c.z;
}

float sdTotem(vec3 p) {
    // p.xz  = fract(p.xz * 3.)-.5;
    vec2 gv = fract(p.xz*.4)-.5;
    float noise = fbm(vec3(gv, p.y*30.));
    float m = length(gv);
    float r = .001;
    // r *= noise;
    return length(max(vec2(m),0.0))-r;
}

float getDist (in vec3 p, in float s) {
    p *= 1. + fbm(p)*sin(s);
    p.xz *= rot(p.y);
    float t = sdTotem(p+vec3(0.,0.,iTime));
    float room = 10.;
    float b = sdBox(p, vec3(room, 100., room));
    // float w = p.z-5.
    return max(t, b);
}

struct MarchResult {
    bool isHit;
    float d;
    float blur;
};

MarchResult march (
    in vec3 ro,
    in vec3 rd,
    in float s
) {
    MarchResult result;
    float t=0.;
    result.blur = 0.;
    for (int i=0; i<MAX_LOOP; i++) {
        vec3 p = ro+t*rd;
        float d = getDist(p, s);
        result.blur += 1./50.;
        d = max(MIN_SURF+0.00001, abs(d));
        if(d < MIN_SURF ) {
            result.isHit = true;
            break;
        }
        if(t > MAX_DIST) {
            result.isHit = false;
            break;
        }
        result.isHit = false;
        t += d;
    }
    
    result.d = t;
    return result;
}

float getFrame(in vec2 uv, in float s) {
    float back = (3. + sin(s*.3)*3.)*.7;
    vec3 ro = vec3(sin(s*.3)*back, 0., cos(s*.3)*back);
    vec3 lookat = vec3(0.);
    float z = .3;
    vec3 rd = getRayDirection(ro, lookat, uv, z);
    MarchResult mr = march(ro, rd, s);
    float m = mr.blur;
    m = m / 2.5;
    return pow(m, 1.4);
}

float random(float n) {
    return fract(sin(n*21.4121)*98.99313);
}

float random(vec2 p) {
    float n = dot(p, vec2(21.15081, 98.121411));
    return fract(sin(n*21.4121)*98.99313);
}

float glitchNoise(in vec2 uv) {
    float n = fbm(vec3(uv*vec2(10., 500.), iTime*20.*random(iTime)));
    // return random(floor(uv*vec2(.2, 200.)+random(iTime)*10.));
    return n*.3;
}

void mainImage(out vec4 fragColor, in vec2 flragCoord) {
    vec2 uv = (flragCoord.xy-.5*iResolution.xy)/iResolution.y;
    vec2 mouse = (iMouse.xy-.5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);

    float glitch = step(.95, random(floor(iTime*3.)));
    float d = 0.001 + glitch;
    uv += glitchNoise(uv)*glitch;

    float m = getFrame(uv, iTime);
    m = pow(m, 2.2);

    if(
        step(.95, random(floor(iTime*3.+900.321))) > 0.
    ) {
        m = 1.-m;
    }
    
    col = vec3(m);
    // col = 1.-col;

    fragColor = vec4(col, 1.);
}