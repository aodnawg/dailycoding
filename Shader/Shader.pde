PShader ps;
JSONObject settings;

int FRAME_RATE;
int TOTAL_TIME = 60;
String SAVE_FRAME_PREFIX = month()+"_"+day()+"_"+hour()+"_"+minute();
boolean OUTPUT_SEQUENCE;
int FRAMECOUNT;
int OFFSET = 0;

void settings() {
  settings = loadJSONObject("setting.json");
  size(1000, 1000, P2D);
}

void setup() {
  FRAME_RATE = settings.getInt("frameRate");
  ps = loadShader(settings.getString("shader"));
  ps.set("resolution", float(width), float(height));
  frameRate(FRAME_RATE);
}

void calc() {
  FRAMECOUNT = frameCount + OFFSET * FRAME_RATE;
}

void draw() {
  if(FRAMECOUNT >= TOTAL_TIME*FRAME_RATE) {
    noLoop();
    println("[*] finished!");
  } else {
    render();
    rec();
    calc();
  }
}

void rec() {
  saveFrame("sequence/"+SAVE_FRAME_PREFIX+"/####.tif");
}

void render() {
  ps.set("time", frameCount/float(FRAME_RATE));
  shader(ps);
  rect(0, 0, width, height);
  resetShader();
}
