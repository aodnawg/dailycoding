// @ts-check

const fs = require("fs");
const path = require("path");
const assert = require("assert");

/** @type {import("./common").CommonModule} */
const {
  pathData: { shaderSourcePath },
  getNewestShaderFileName,
  encoding,
} = require("./common");

/**
 *
 * @param {string} [filePath]
 */
const getShaderText = (filePath) => {
  const pathData =
    filePath || path.resolve(shaderSourcePath, getNewestShaderFileName());

  const shaderText = fs.readFileSync(pathData, encoding);
  return shaderText;
};

/**
 * @param {Array<string>} prefixes
 * @param {string} comment
 * @return {string}
 */
const removePrefix = (prefixes, comment) => {
  return comment.replace(new RegExp(`^// @(${prefixes.join("|")}) `), "");
};

/**
 * @param {Array<string>} prefixes
 * @param {string} shaderText
 * @param {string} target
 * @return {string|null}
 */
const getMeta = (prefixes, shaderText, target) => {
  assert(prefixes.includes(target), "[*] error: invalid prefix");
  const regexpInput = `^// @(${target}) (.*)$`;
  const regex = new RegExp(regexpInput, "gm");
  const result = shaderText.match(regex);
  if (!result) {
    return null;
  }
  return removePrefix(prefixes, shaderText.match(regex)[0]);
};

/**
 * @param {string} tagRawText
 * @return {Array<string>}
 */
const parseTag = (tagRawText) => tagRawText.split(",");

/**
 * @typedef ShaderMetaData
 * @property {string} day
 * @property {Array<string>} tag
 * @property {string} title
 */
/**
 * @param {string} [filePath]
 * @return {ShaderMetaData}
 */
const getMetaFromComment = (filePath) => {
  const shaderText = getShaderText(filePath);
  const prefixes = ["day", "tag", "title"];
  const [day, tag_, title] = prefixes.map((prefix) =>
    getMeta(prefixes, shaderText, prefix)
  );
  return { day, tag: tag_ && parseTag(tag_), title };
};

module.exports = getMetaFromComment;
