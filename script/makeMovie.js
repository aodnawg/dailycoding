// @ts-check

const fs = require("fs");
const path = require("path");
const assert = require("assert");
const child_process = require("child_process");
const open = require("open");

const {
  pathData: {
    settingJsonPath,
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
 * @typedef {Object} Setting
 * @property {number} width
 * @property {number} height
 * @property {number} totalTime
 * @property {number} frameRate
 */
/**
 * @return {Setting}
 */
const loadSetting = () =>
  /** @type {Setting} */ JSON.parse(fs.readFileSync(settingJsonPath, encoding));

/**
 * @typedef {Object} SetupOnlyOaram
 * @property {number} timestamp
 * @property {string} targetShaderPath
 * @typedef {Setting & SetupOnlyOaram} SetupParam
 */
/**
 * @param {SetupParam} param
 */
const makeProcessingSettingJson = ({ timestamp, ...rest }) => {
  const map = {
    timestamp: `${timestamp}`,
    shader: processingSourceShaderName,
    ...rest,
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
 * @return {SetupParam}
 */
const setup = () => {
  const setting = loadSetting();

  const targetShaderName = process.argv[2] || getNewestShaderFileName();
  const targetShaderPath = path.resolve(shaderSourcePath, targetShaderName);
  console.log(`[*] setup ${targetShaderPath}`);
  checkTargetShader(targetShaderPath);
  copyTargetShader(targetShaderName);
  const timestamp = getTimestamp();
  const params = {
    timestamp,
    targetShaderPath,
    ...setting,
  };
  const jsonString = makeProcessingSettingJson(params);
  inputSettingJson(jsonString);
  return params;
};

const execProcessing = () => {
  console.log("[*] exec Processing.");
  const cmd = `processing-java --sketch=${processingSketchPath} --run`;
  child_process.execSync(cmd);
  console.log("[*] complete exec Processing.");
  return true;
};

/**
 * @param {SetupParam} ffmpegParams
 */
const execEncoding = ({ width, height, timestamp, frameRate }) => {
  console.log("[*] exec movie encoding");
  const sourcePath = path.resolve(sequenceImagePath, `${timestamp}`);
  const outputDir = path.resolve(movieOutputPath, `${timestamp}`);
  fs.mkdirSync(outputDir);
  const movieFileName = path.resolve(outputDir, `${timestamp}.mp4`);
  const cmd = `ffmpeg -s ${width}x${height} -framerate ${frameRate} -i ${sourcePath}\\%04d.tif -vcodec libx264 -pix_fmt yuv420p ${movieFileName}`;
  child_process.execSync(cmd);
  console.log("[*] complete movie encoding");
  return true;
};

/**
 * @param {SetupParam} param
 */
const dumpMetaInfo = ({ targetShaderPath, timestamp }) => {
  const { day, tag, title: titleText } = getMetaFromComment(targetShaderPath);
  const dayText = day && `Day ${day}`;
  const tagText = tag && `${tag.map((t) => `#${t}`).join(" ")}`;
  const text = [dayText, titleText, tagText].filter((t) => !!t).join("\n\n");
  const log = `----------------

${text}

----------------`;

  console.log(log);

  fs.writeFileSync(
    path.resolve(movieOutputPath, `${timestamp}`, `${timestamp}.meta.txt`),
    text,
    encoding
  );

  return text;
};

const openFolder = ({ timestamp }) => {
  const openpath = path.resolve(movieOutputPath, `${timestamp}`);
  open(openpath);
};

const main = () => {
  // setup
  const params = setup();
  // exec
  execProcessing();
  // encoding
  execEncoding(params);
  // meta
  dumpMetaInfo(params);
  // open folder
  openFolder(params);
  console.log("[*] done ✨");
};

main();
