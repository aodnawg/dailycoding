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
  thumbnailImagePath,
} = pathData;

import { getMeta } from "./getMeta";

const ThumbnailSize = 512; // TODO: move setting

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

export enum MakeMode {
  Movie = 0,
  Thumbnail = 1,
}

interface SetupParam extends Setting {
  mode: MakeMode;
  timestamp: number;
  targetShaderPath: string;
  targetShaderName: string;
}

const makeSetupParam = (
  mode: MakeMode,
  targetShaderName: string,
  targetShaderPath: string,
  { width: width_, height: height_, ...rest }: Setting
): SetupParam => {
  const timestamp = getTimestamp();

  const width = mode === MakeMode.Movie ? width_ : ThumbnailSize;
  const height = mode === MakeMode.Movie ? height_ : ThumbnailSize;

  return {
    mode,
    timestamp,
    targetShaderName,
    targetShaderPath,
    width,
    height,
    ...rest,
  };
};

export const setup = (mode: MakeMode, fileName?: string): SetupParam => {
  const setting = loadSetting();

  const targetShaderName = fileName || getNewestShaderFileName();
  const targetShaderPath = path.resolve(shaderSourcePath, targetShaderName);
  console.log(`[*] setup ${targetShaderPath}`);

  checkTargetShader(targetShaderPath);
  copyTargetShader(targetShaderName);

  const params = makeSetupParam(
    mode,
    targetShaderName,
    targetShaderPath,
    setting
  );

  return params;
};

interface ProcessingParam
  extends Omit<SetupParam, "timestamp" | "targetShaderName"> {
  timestamp: string;
  shader: string;
  mode: MakeMode;
  thumbnailDirName: string;
}

const makeProcessingParam = ({
  timestamp,
  targetShaderName,
  ...rest
}: SetupParam): ProcessingParam => {
  const map = {
    timestamp: `${timestamp}`,
    shader: processingSourceShaderName,
    thumbnailDirName: targetShaderName.replace(`.glsl`, ""),
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

export const execProcessing = (params: SetupParam) => {
  const processingParam = makeProcessingParam(params);
  const jsonString = JSON.stringify(processingParam);
  console.log(jsonString);
  inputSettingJson(jsonString);
  console.log("[*] exec Processing.");
  const cmd = `processing-java --sketch=${processingSketchPath} --run`;
  child_process.execSync(cmd);
  console.log("[*] complete exec Processing.");
  return true;
};

export const execEncoding = ({
  width,
  height,
  timestamp,
  frameRate,
}: SetupParam) => {
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

export const dumpMetaInfo = ({
  targetShaderPath: filePath,
  timestamp,
}: SetupParam) => {
  const result = getMeta({ filePath });
  const { day, tag, title: titleText } = result;
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

export const openFolder = ({
  timestamp,
  mode,
  targetShaderName,
}: Pick<SetupParam, "timestamp" | "mode" | "targetShaderName">) => {
  const dirPath =
    mode === MakeMode.Movie
      ? path.resolve(movieOutputPath, `${timestamp}`)
      : path.resolve(thumbnailImagePath, targetShaderName.replace(/.glsl/, ""));
  openNpm(dirPath);
};

export const makeThumbnail = (fileName?: string) => {
  // setup
  const params = setup(MakeMode.Thumbnail, fileName);
  // exec
  execProcessing(params);
  return params;
};
