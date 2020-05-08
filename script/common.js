// @ts-check

const path = require("path");
const fs = require("fs");

const projectRootPath = path.resolve(__dirname, "..");
const processingSketchPath = path.resolve(projectRootPath, "Shader");

/**
 * @typedef {Object} PathData
 * @property {string} projectRootPath  projectRoot
 * @property {string} settingJsonPath  render settings passed to Processing and ffmpeg
 * @property {string} shaderSourcePath  shader source code path
 * @property {string} nuxtShaderPath  shader code copied from shader source file
 * @property {string} processingSketchPath  Processing sketch path
 * @property {string} processingDataPath  Processing data folder path. This folder has rendering option config (json)
 * @property {string} processingSourceShaderName  shader file name used in Proccessing. copied from shader source path.
 * @property {string} processingSettingJsonName  Proccessing config json file name
 * @property {string} sequenceImagePath  Processing output path
 * @property {string} movieOutputPath  ffmpeg movie out put file
 */
/** @type {PathData} */
const pathData = {
  projectRootPath,
  settingJsonPath: path.resolve(projectRootPath, "setting.json"),
  shaderSourcePath: path.resolve(projectRootPath, "shaders"),
  nuxtShaderPath: path.resolve(projectRootPath, "web", "shaders"),
  processingSketchPath,
  processingDataPath: path.resolve(processingSketchPath, "data"),
  processingSourceShaderName: "frag.glsl",
  processingSettingJsonName: "setting.json",
  sequenceImagePath: path.resolve(processingSketchPath, "sequence"),
  movieOutputPath: path.resolve(projectRootPath, "out"),
};

const encoding = "utf-8";

/**
 * @typedef {function} GetNewestShaderFileFn
 * @return {string} last updated shader source
 */
const getNewestShaderFileName = () =>
  fs
    .readdirSync(pathData.shaderSourcePath)
    .sort(
      (a, b) =>
        fs
          .statSync(path.resolve(pathData.shaderSourcePath, b))
          .mtime.getTime() -
        fs.statSync(path.resolve(pathData.shaderSourcePath, a)).mtime.getTime()
    )[0];

/**
 * @typedef {Object} CommonModule
 * @property {PathData} pathData
 * @property {string} encoding
 * @property {GetNewestShaderFileFn} getNewestShaderFileName
 */
/** @type {CommonModule} */
module.exports = {
  pathData,
  encoding,
  getNewestShaderFileName,
};
