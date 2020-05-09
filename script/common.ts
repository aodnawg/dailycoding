import fs from "fs";
import path from "path";

const projectRootPath = path.resolve(__dirname, "..");
const processingSketchPath = path.resolve(projectRootPath, "Shader");

export const pathData = {
  /** projectRoot */
  projectRootPath,
  /** render settings passed to Processing and ffmpeg */
  settingJsonPath: path.resolve(projectRootPath, "setting.json"),
  /** shader source code path */
  shaderSourcePath: path.resolve(projectRootPath, "shaders"),
  /** shader code copied from shader source file */
  nuxtShaderPath: path.resolve(projectRootPath, "web", "shaders"),
  /** Processing sketch path */
  processingSketchPath,
  /** Processing data folder path. This folder has rendering option config (json) */
  processingDataPath: path.resolve(processingSketchPath, "data"),
  /** shader file name used in Proccessing. copied from shader source path. */
  processingSourceShaderName: "frag.glsl",
  /** Proccessing config json file name */
  processingSettingJsonName: "setting.json",
  /** Processing output path */
  sequenceImagePath: path.resolve(processingSketchPath, "sequence"),
  /** Processing thumbnail output path */
  thumbnailImagePath: path.resolve(processingSketchPath, "thumbnail"),
  /** ffmpeg movie out put file */
  movieOutputPath: path.resolve(projectRootPath, "out"),
  /** nuxt shader path */
  shaderWebPath: path.resolve(projectRootPath, "web", "shaders"),
  /** nuxt asset path */
  webAssetPath: path.resolve(projectRootPath, "web", "assets"),
};

export const encoding = "utf-8";

export const getNewestShaderFileName = (): string =>
  fs
    .readdirSync(pathData.shaderSourcePath)
    .sort(
      (a: string, b: string) =>
        fs
          .statSync(path.resolve(pathData.shaderSourcePath, b))
          .mtime.getTime() -
        fs.statSync(path.resolve(pathData.shaderSourcePath, a)).mtime.getTime()
    )[0];

export const glslExt = /\.glsl$/g;

export const listup = () => {
  const list = fs
    .readdirSync(pathData.shaderSourcePath)
    .filter((name) => name.match(glslExt) !== null);
  return list;
};
