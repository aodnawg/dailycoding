import fs from "fs";
import path from "path";
import assert from "assert";
import child_process from "child_process";
import openNpm from "open";

import { pathData, encoding, getNewestShaderFileName } from "./common";
const {
  settingJsonPath,
  shaderSourcePath,
  processingSketchPath,
  processingDataPath,
  processingSourceShaderName,
  processingSettingJsonName,
  sequenceImagePath,
  movieOutputPath,
} = pathData;

import { getMetaFromComment } from "./getMetaFromComment";

const getTimestamp = () => new Date().getTime();

const checkTargetShader = (targetShaderPath: string) => {
  const result = fs.existsSync(targetShaderPath);
  assert(result, `[*] ${targetShaderPath} does not exist.`);
  return targetShaderPath;
};

const copyTargetShader = (targetShaderName: string) => {
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

interface Setting {
  width: number;
  height: number;
  totalTime: number;
  frameRate: number;
}

const loadSetting = (): Setting => {
  const fileData = fs.readFileSync(settingJsonPath, encoding);
  return JSON.parse(fileData.toString());
};

interface makeProcessingJsonParam extends Setting {
  timestamp: number;
}

interface SetupParam extends Setting {
  timestamp: number;
  targetShaderPath: string;
}
const setup = (): SetupParam => {
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

  return params;
};

const makeProcessingSettingMap = ({
  timestamp,
  ...rest
}: SetupParam): ProcessingParam => {
  const map = {
    timestamp: `${timestamp}`,
    shader: processingSourceShaderName,
    ...rest,
  };
  return map;
};

const inputSettingJson = (jsonString: string) => {
  const jsonPath = path.resolve(processingDataPath, processingSettingJsonName);
  if (fs.existsSync(jsonPath)) {
    fs.unlinkSync(jsonPath);
    console.log("[*] removed old setting.");
  }
  fs.writeFileSync(jsonPath, jsonString, { encoding });
  console.log("[*] input rendering option.");
};

interface ProcessingParam extends Omit<SetupParam, "timestamp"> {
  timestamp: string;
  shader: string;
}

const execProcessing = (params: SetupParam) => {
  const processingParam = makeProcessingSettingMap(params);
  const jsonString = JSON.stringify(processingParam);
  inputSettingJson(jsonString);
  console.log("[*] exec Processing.");
  const cmd = `processing-java --sketch=${processingSketchPath} --run`;
  child_process.execSync(cmd);
  console.log("[*] complete exec Processing.");
  return true;
};

const execEncoding = ({ width, height, timestamp, frameRate }: SetupParam) => {
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

const dumpMetaInfo = ({ targetShaderPath, timestamp }: SetupParam) => {
  const { day, tag, title: titleText } = getMetaFromComment(targetShaderPath);
  const dayText = day && `Day ${day}`;
  const tagText = tag && `${tag.map((t: string) => `#${t}`).join(" ")}`;
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

const openFolder = ({ timestamp }: SetupParam) => {
  const openpath = path.resolve(movieOutputPath, `${timestamp}`);
  openNpm(openpath);
};

const main = () => {
  // setup
  const params = setup();
  // exec
  execProcessing(params);
  // encoding
  execEncoding(params);
  // meta
  dumpMetaInfo(params);
  // open folder
  openFolder(params);
  console.log("[*] done ✨");
};

main();
