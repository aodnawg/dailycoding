// @ts-check

const fs = require("fs");
const path = require("path");
const assert = require("assert");
const child_process = require("child_process");

const {
  pathData: {
    shaderSourcePath,
    processingSketchPath,
    processingDataPath,
    processingSourceShaderName,
    processingSettingJsonName,
    sequenceImagePath,
    movieOutputPath,
  },
  encoding,
  getNewestShaderFileName,
} = require("./common");

const getMetaFromComment = require("./getMetaFromComment");

const getTimestamp = () => new Date().getTime();

/**
 * @param {string} targetShaderPath
 */
const checkTargetShader = (targetShaderPath) => {
  const result = fs.existsSync(targetShaderPath);
  assert(result, `[*] ${targetShaderPath} does not exist.`);
  return targetShaderPath;
};

/**
 * @param {string} targetShaderName
 */
const copyTargetShader = (targetShaderName) => {
  const destinationPath = path.resolve(
    processingDataPath,
    processingSourceShaderName
  );
  if (fs.existsSync(destinationPath)) {
    fs.unlinkSync(destinationPath);
    console.log("[*] removed old shader.");
  }
  fs.copyFileSync(
    path.resolve(shaderSourcePath, targetShaderName),
    destinationPath
  );
};

/**
 * @param {string} timestamp
 * @return {string} json
 */
const makeSettingJson = (timestamp) => {
  const map = {
    timestamp,
    width: 1000,
    height: 1000,
    frameRate: 4,
    totalTime: 1,
    shader: processingSourceShaderName,
  };
  return JSON.stringify(map);
};

/**
 * @param {string} jsonString
 */
const inputSettingJson = (jsonString) => {
  const jsonPath = path.resolve(processingDataPath, processingSettingJsonName);
  if (fs.existsSync(jsonPath)) {
    fs.unlinkSync(jsonPath);
    console.log("[*] removed old setting.");
  }
  fs.writeFileSync(jsonPath, jsonString, { encoding });
  console.log("[*] input rendering option.");
};

/**
 * @typedef {Object} SetupedParam
 * @property {string} timestamp
 * @property {string} targetShaderPath
 * @property {string} frameRate
 */
/**
 * @return {SetupedParam}
 */
const setup = () => {
  const targetShaderName = process.argv[2] || getNewestShaderFileName();
  const targetShaderPath = path.resolve(shaderSourcePath, targetShaderName);
  console.log(`[*] setup ${targetShaderPath}`);
  checkTargetShader(targetShaderPath);
  copyTargetShader(targetShaderName);
  const timestamp = `${getTimestamp()}`;
  const jsonString = makeSettingJson(timestamp);
  inputSettingJson(jsonString);
  return { timestamp, targetShaderPath, frameRate: "24" }; //TODO: import frameRate
};

const execProcessing = () => {
  console.log("[*] exec Processing.");
  const cmd = `processing-java --sketch=${processingSketchPath} --run`;
  child_process.execSync(cmd);
  console.log("[*] complete exec Processing.");
  return true;
};

/**
 *
 * @typedef {Object} FfmpegParams - parameters required for ffmpeg
 * @property {string} timestamp
 * @property {string} frameRate
 */
/**
 * @param {FfmpegParams} ffmpegParams
 */
const execEncoding = ({ timestamp, frameRate }) => {
  console.log("[*] exec movie encoding");
  const sourcePath = path.resolve(sequenceImagePath, `${timestamp}`);
  const movieFileName = path.resolve(movieOutputPath, `${timestamp}.mp4`);
  const cmd = `ffmpeg -s 1000x1000 -framerate ${frameRate} -i ${sourcePath}\\%04d.tif -vcodec libx264 -pix_fmt yuv420p ${movieFileName}`;
  child_process.execSync(cmd);
  console.log("[*] complete movie encoding");
  return true;
};

/**
 * @param {string} targetShaderName
 */
const dumpMetaInfo = (targetShaderName) => {
  const { day, tag, title: titleText } = getMetaFromComment(targetShaderName);
  const dayText = day && `Day ${day}`;
  const tagText = tag && `${tag.map((t) => `#${t}`).join(" ")}`;
  return [dayText, titleText, tagText].filter((t) => !!t).join("\n\n");
};

const main = () => {
  // setup
  const { timestamp, frameRate, targetShaderPath } = setup();
  // exec
  execProcessing();
  // encoding
  execEncoding({ timestamp, frameRate });
  // meta
  const result = dumpMetaInfo(targetShaderPath);
  console.log(result);
  console.log("[*] done ✨");
};

main();
