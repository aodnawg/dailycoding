help
CANCEL
POST
99
        s += 1./200.;
100
    }
101
    mr.d = t;
102
    mr.s = s;
103
    mr.isHit = flag;
104
    return mr;
105
}
106
​
107
struct Camera {
108
    vec3 ro; vec3 rd; float z;
109
};
110
Camera makeCam(in vec2 uv, float s) {
111
    Camera camera;
112
    vec3 ro = vec3(1.,2.,-2.+s);
113
    vec3 lookat = ro+vec3(0.,-1.,1.8);
114
    vec3 f = normalize(lookat-ro);
115
    vec3 r = cross(vec3(0,1,0), f);
116
    vec3 u = cross(f, r);
117
    float z = 1.;
118
    vec3 c = ro+f*z;
119
    vec3 i = c+r*uv.x+u*uv.y;
120
    vec3 rd = normalize(i-ro);
121
    camera.ro = ro;
122
    camera.rd = rd;
123
    camera.z = z;
124
    return camera;
125
}
126
​
127
void main() {
128
    vec3 col = vec3(0.);
129
    vec2 uv = (gl_FragCoord.xy - resolution.xy*.5)/resolution.y;
130
    float s = time;
131
    Camera c = makeCam(uv, s);
132
    Trace t = trace(c.ro, c.rd);
133
    float w = mix(.01,.02, sin(time)*.5+.5)*8.;
134
    col = vec3(1.,.3,.1)*.4*vec3(pow(t.s,1.)*(1.+t.d*.1*w*(1.-vec3(.2,.1,.2))*.4));
135
    gl_FragColor = vec4(1.-col, 1.);
136
}

autorenew