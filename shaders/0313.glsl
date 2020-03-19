#define LOOP_MAX 1000
#define MAX_DIST 10000.
#define MIN_SURF .00001
#define PI 3.141593

float random(float n) {
    return fract(sin(n*217.12312)*398.2121561);
}

float random(vec2 p) {
    return fract(
        sin(dot(p, vec2(98.108171, 49.10821)))*81.20914
    );
}

float random(vec3 p) {
    return random(random(p.xy) + p.z);
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
		x = x * 2. + shift;
		a *= 0.5555;
	}
	return v;
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

float sdBox( in vec2 p, in vec2 b )
{
    vec2 d = abs(p)-b;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdRoundBox( vec3 p, vec3 b, float r )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sdGyroid(vec3 p, float r) {
	p += vec3(0.,0.,iTime);
	float scale = 10.;
	float g = dot(sin(p*2.115), cos(p.zyx*14.12))/20.;
	// float thick = mix(0.01, 0.05, r);
	return abs(g)-.005;

}

float smin( float a, float b, float k )
{
    a = pow( a, k ); b = pow( b, k );
    return pow( (a*b)/(a+b), 1.0/k );
}

float map(vec3 p, vec3 ro) {
    // p = mod(p, 4.)-2.;
    vec3 p_ = p;
    // p.yz *= rot(PI*.5);
	float z = 2.;
    // p.y += iTime;
    if(random(floor(iTime*3.)) > .75) {
        p *= mix(.1, .6, fbm(p+vec3(0.,0.,iTime*3.)));
    }
    float a = 30. + noise(vec3(1.,1.,iTime*2.))*50.;
    p.xz *= rot(length(p)*a);
    p.xy *= rot(length(p)*a);
    p.yz *= rot(length(p)*a);
	float s = length(p)-.5;
	// s = abs(s);
	float g = sdGyroid(p, 1.);
	
	float result = max(s, g)/1.5;
    result += sdGyroid(p*3., 1.)/3.;
    result += sdGyroid(p*6., 1.)/6.;
    result = max(p_.z-10., result);
    return result;
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
        float d = map(p, ro);
        d = max(MIN_SURF+.0003+sin(iTime)*.00015, d);

        if(d<MIN_SURF) {
            flag=true;
            break;
        }
        if(t>MAX_DIST) {
            break;
        }
        flag=false;
        t += d;
        s += 1./1200.;
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
    vec3 ro = vec3(0,0,-3);
    // ro += vec3(0,0,0);
    vec3 lookat = vec3(0.);
    vec3 f = normalize(lookat-ro);
    vec3 r = cross(vec3(0,1,0), f);
    vec3 u = cross(f, r);
    float z = 1.2;
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
    vec3 p =  c.ro+c.rd*t.d;
    float w = mix(.01,.02, sin(iTime)*.5+.5)*.1;
    vec3 wc = w*vec3(.3+sin(iTime),.21,.32+sin(t.d*.5-iTime*30.)*.3)*10.;
    
    float v = pow(t.s,2.)*(t.d*w);
    col = vec3(1.+sin(iTime*8.)*.3,4.,5.)*v;
    col -= vec3(.1,2.,2.)*pow(v,3.)*.3;


    

    fragColor = vec4(1.-col, 1.);
}