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

float getDist (in vec3 p, in float s) {
    p.yz *= rot(PI*.45 + sin(s)*.1);
    p.xz *= rot(cos(s)*.1);
    p.y += s*.5+sin(s)*.2;
    float dw = fbm(p+fbm(vec3(p.xy*rot(fbm(p)*PI), p.z+s)));
    p *= 1. + mix(-.5, .5, dw)*(2.5 + sin(s)*.5);
    float b = sdCylinder(p, vec3(.5));
    float n = sdNoise(p);
    return b;
}

// vec3 getNormal(vec3 p) {
// 	float d = getDist(p);
//     vec2 e = vec2(.0001, 0);
//     vec3 n = d - vec3(
//         getDist(p-e.xyy),
//         getDist(p-e.yxy),
//         getDist(p-e.yyx));
//     return normalize(n);
// }

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
        result.blur += 1./100.;
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
    vec3 ro = vec3(.5, 0., 3.);
    vec3 lookat = vec3(.5, 0., 0.);
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

void mainImage(out vec4 fragColor, in vec2 flragCoord) {
    vec2 uv = (flragCoord.xy-.5*iResolution.xy)/iResolution.y;
    vec2 mouse = (iMouse.xy-.5*iResolution.xy)/iResolution.y;
    vec3 col = vec3(0.);

    float glitch = step(.95, random(floor(iTime*3.)));
    float d = 0.001 + glitch;
    uv += step(.9, random(floor(uv*vec2(.2, 200.)+random(iTime)*10.)))*glitch*.1;

    float r = getFrame(uv, iTime);
    float g = getFrame(uv, iTime+d);
    float b = getFrame(uv, iTime-d);
    
    col = vec3(r, g, b);

    fragColor = vec4(col, 1.);
}