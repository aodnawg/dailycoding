const fs = require("fs");
const path = require("path");
const assert = require("assert");
const child_process = require("child_process");

const encoding = "utf-8";
const shaderDirPath = path.resolve(__dirname, "..", "shaders");
const processingSketchPath = path.resolve(__dirname, "..", "Shader");
const processingDataPath = path.resolve(processingSketchPath, "data");
/** shader reffered in processing */
const sourceShaderName = "frag.glsl";
/** rendering config loaded processing */
const settingJsonName = "setting.json";
/** frame image sequence path */
const sequenceImagePath = path.resolve(processingSketchPath, "sequence");
/** output movie destination */
const outputPath = path.resolve(__dirname, "..", "out");

const getTimestamp = () => new Date().getTime();

const checkTargetShader = (targetShaderName) => {
  const result = fs.existsSync(path.resolve(shaderDirPath, targetShaderName));
  assert(result, `[*] ${targetShaderName} does not exist.`);
  return targetShaderName;
};

const copyTargetShader = (targetShaderName) => {
  const destinationPath = path.resolve(processingDataPath, sourceShaderName);
  if (fs.existsSync(destinationPath)) {
    fs.unlinkSync(destinationPath);
    console.log("[*] removed old shader.");
  }
  fs.copyFileSync(
    path.resolve(shaderDirPath, targetShaderName),
    destinationPath
  );
};

const makeSettingJson = (timestamp) => {
  const map = {
    timestamp,
    width: 1000,
    height: 1000,
    frameRate: 24,
    totalTime: 30,
    shader: sourceShaderName,
  };
  return JSON.stringify(map);
};

const inputSettingJson = (jsonString) => {
  const jsonPath = path.resolve(processingDataPath, settingJsonName);
  if (fs.existsSync(jsonPath)) {
    fs.unlinkSync(jsonPath);
    console.log("[*] removed old setting.");
  }
  fs.writeFileSync(jsonPath, jsonString, { encoding });
  console.log("[*] input rendering option.");
};

const getNewestShaderFile = () =>
  fs
    .readdirSync(shaderDirPath)
    .sort(
      (a, b) =>
        fs.statSync(path.resolve(shaderDirPath, b)).mtime.getTime() -
        fs.statSync(path.resolve(shaderDirPath, a)).mtime.getTime()
    )[0];

const setup = () => {
  const targetShaderName = process.argv[2] || getNewestShaderFile();
  console.log(`[*] setup ${targetShaderName}`);
  checkTargetShader(targetShaderName);
  copyTargetShader(targetShaderName);
  const timestamp = `${getTimestamp()}`;
  const jsonString = makeSettingJson(timestamp);
  inputSettingJson(jsonString);
  return { timestamp };
};

const execProcessing = () => {
  console.log("[*] exec Processing.");
  const cmd = `processing-java --sketch=${processingSketchPath} --run`;
  child_process.execSync(cmd);
  console.log("[*] complete exec Processing.");
  return true;
};

const execEncoding = (timestamp) => {
  console.log("[*] exec movie encoding");
  const sourcePath = path.resolve(sequenceImagePath, `${timestamp}`);
  const movieFileName = path.resolve(outputPath, `${timestamp}.mp4`);
  const cmd = `ffmpeg -s 1000x1000 -framerate 24 -i ${sourcePath}\\%04d.tif -vcodec libx264 -pix_fmt yuv420p ${movieFileName}`;
  child_process.execSync(cmd);
  console.log("[*] complete movie encoding");
  return true;
};

const main = () => {
  // setup
  const { timestamp, frameRate } = setup();
  // exec
  execProcessing();
  // encoding
  execEncoding(timestamp, frameRate);
  console.log("[*] done ✨");
};

main();
