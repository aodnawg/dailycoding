PShader ps;
JSONObject settings;

int FRAME_RATE;
int TOTAL_TIME;
String TIMESTAMP;
boolean OUTPUT_SEQUENCE;
int FRAMECOUNT;
int OFFSET = 0;

void settings() {
  settings = loadJSONObject("setting.json");
  size(1000, 1000, P2D);
}

void setup() {
  FRAME_RATE = settings.getInt("frameRate");
  TOTAL_TIME = settings.getInt("totalTime");
  TIMESTAMP = settings.getString("timestamp");
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
    exit();
  } else {
    render();
    rec();
    calc();
  }
}

void rec() {
  saveFrame("sequence/"+TIMESTAMP+"/####.tif");
}

void render() {
  ps.set("time", frameCount/float(FRAME_RATE));
  shader(ps);
  rect(0, 0, width, height);
  resetShader();
}
