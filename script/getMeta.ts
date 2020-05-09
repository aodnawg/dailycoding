import fs from "fs";
import path from "path";
import assert from "assert";

import { pathData, getNewestShaderFileName, encoding } from "./common";

const { shaderSourcePath } = pathData;

const getShaderText = (filePath: string) => {
  const pathData =
    filePath || path.resolve(shaderSourcePath, getNewestShaderFileName());

  const shaderText = fs.readFileSync(pathData, encoding);
  return shaderText;
};

const removePrefix = (prefixes: string[], comment: string) => {
  return comment.replace(new RegExp(`^// @(${prefixes.join("|")}) `), "");
};

const getMetaFromText = (
  prefixes: string[],
  shaderText: string,
  target: string
) => {
  assert(prefixes.includes(target), "[*] error: invalid prefix");
  const regexpInput = `^// @(${target}) (.*)$`;
  const regex = new RegExp(regexpInput, "gm");
  const result = shaderText.match(regex);
  if (!result) {
    return null;
  }
  const comment = result[0];
  return removePrefix(prefixes, comment);
};

const parseTag = (tagRawText: string) => tagRawText.split(",");

type getMetaParam = {
  filePath?: string;
  shaderText?: string;
};

export const getMeta = ({
  filePath,
  shaderText: shaderText_,
}: getMetaParam) => {
  if (!shaderText_ && !filePath) {
    return {};
  }
  const shaderText = shaderText_ || getShaderText(filePath!);
  const prefixes = ["day", "tag", "title"];
  const [day, tag_, title] = prefixes.map((prefix) =>
    getMetaFromText(prefixes, shaderText, prefix)
  );
  return { day, tag: tag_ && parseTag(tag_), title };
};
