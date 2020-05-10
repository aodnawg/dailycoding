PShader ps;
JSONObject settings;

int FRAME_RATE;
int TOTAL_TIME;
String TIMESTAMP;
boolean OUTPUT_SEQUENCE;
int FRAMECOUNT;
int OFFSET = 0;
int WIDTH;
int HEIHGT;
int MODE; // 0: movie,  1: thumbnail
String THUMBNAIL_DIR_NAME;

void settings() {
  settings = loadJSONObject("setting.json");
  WIDTH = settings.getInt("width");
  HEIHGT = settings.getInt("height");
  size(WIDTH, HEIHGT, P2D);
}

void setup() {
  FRAME_RATE = settings.getInt("frameRate");
  TOTAL_TIME = settings.getInt("totalTime");
  MODE = settings.getInt("mode");
  THUMBNAIL_DIR_NAME = settings.getString("thumbnailDirName");
  TIMESTAMP = settings.getString("timestamp");
  ps = loadShader(settings.getString("shader"));
  ps.set("resolution", float(WIDTH), float(HEIHGT));
  frameRate(FRAME_RATE);
}

void calc() {
  FRAMECOUNT = frameCount + OFFSET * FRAME_RATE;
}

void draw() {
  if(MODE == 0) {
    makeMovie();
  } else if (MODE == 1) {
    makeThumbnail();
  } else {
    println("[*] processing error: invalid mode");
    exit();
  }
}

void makeThumbnail() {
  if(frameCount > 1) {
    noLoop();
    println("[*] finished!");
    exit();
  } else {
    renderThumbnail();
    saveThumbnail();
    calc();
  }
}

void makeMovie() {
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

void saveThumbnail() {
  saveFrame("thumbnail/"+THUMBNAIL_DIR_NAME+"/####.png");
}

void render() {
  ps.set("time", frameCount/float(FRAME_RATE));
  shader(ps);
  rect(0, 0, width, height);
  resetShader();
}

void renderThumbnail() {
  ps.set("time", frameCount*500.);
  shader(ps);
  rect(0, 0, width, height);
  resetShader();
}
