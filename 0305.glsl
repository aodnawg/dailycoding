#define LOOP_MAX 1000
#define MAX_DIST 10000.
#define MIN_SURF .0001
#define PI 3.141593

float random(float n) {
    return fract(sin(n*217.12312)*398.2121561);
}

float random(vec2 p) {
    return fract(
        sin(dot(p, vec2(98.108171, 49.10821)))*81.20914
    );
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

float sdCircle(in vec2 p, in float r) {
    return length(p)-r;
}

mat2 rot(float a) {
    float c = cos(a), s = sin(a);
    return mat2(c,s,-s,c);
}

vec2 pmod(vec2 p, float r) {
    float a =  atan(p.x, p.y) + PI/r;
    float n = PI*2. / r;
    a = floor(a/n)*n;
    return p*rot(-a);
}

float sdRing(in vec2 p) {
    p = pmod(p, 20.);
    float r_ = -.6;
    p += vec2(0, r_);
    float r = 0.2;
    return sdCircle(p, r);
}

float sdHorn(vec3 p) {
    float noise = fbm(vec3(p.xz, 1.));
    float glitch = step(.9, random(floor(iTime*10.)))*noise*15.;
    p.xz *= .9;
    p.xz *= rot(iTime);
    p.xz *= rot(p.y*(max(0., 4.-iTime*.5)));
    p.xz *= rot(glitch*10.);
    p.xz += vec2(sin(noise*9.12), cos(noise*8.123))*.5;
    p.xz *= 1.+p.y*.3;

    float m = length(p.xz) -.5;
    float n =  sdRing(p.xz);
    return max(m, -n);
}

float map(vec3 p) {
    p.xz *= rot(iTime*.3);
    return sdHorn(p);
}

struct Trace {
    float d; bool isHit; float s;
};
Trace trace(vec3 ro, vec3 rd) {
    Trace mr;
    float t = 0.;
    float s = 0.;
    bool flag;
    for(int i=0; i<LOOP_MAX; i++) {
        vec3 p = ro+rd*t;
        float d = map(p);
        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./200.;
    }
    mr.d = t;
    mr.s = s;
    mr.isHit = flag;
    return mr;
}

struct Camera {
    vec3 ro; vec3 rd; float z;
};
Camera makeCam(in vec2 uv, float s) {
    Camera camera;
    float n = noise(vec3(1.,1.,s));
    vec3 ro = vec3(0,-1.4,min(-10.+iTime*.5, -5.));
    ro += vec3(cos(iTime*.2), 0., sin(iTime*.2));
    vec3 lookat = ro + vec3(0., (sin(s*.2)+1.)*.1, 1.);
    vec3 f = normalize(lookat-ro);
    vec3 r = cross(vec3(0,1,0), f);
    vec3 u = cross(f, r);
    float z = 1.;
    vec3 c = ro+f*z;
    vec3 i = c+r*uv.x+u*uv.y;
    vec3 rd = normalize(i-ro);
    camera.ro = ro;
    camera.rd = rd;
    camera.z = z;
    return camera;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec3 col = vec3(0.);
    vec2 uv = (fragCoord.xy - iResolution.xy*.5)/iResolution.y;
    float s = iTime;
    Camera c = makeCam(uv, s);
    Trace t = trace(c.ro, c.rd);
    float w = mix(.01,.02, sin(iTime)*.5+.5);
    col = vec3(pow(t.s,1.2)*(1.+t.d*w));
    fragColor = vec4(col, 1.);
}