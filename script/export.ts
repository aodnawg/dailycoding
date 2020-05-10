import fs from "fs";
import path from "path";
import _ from "lodash";

import {
  pathData,
  encoding,
  listup,
  glslExt,
  getNewestShaderFileName,
} from "./common";
import { getMeta } from "./getMeta";

// path
const { shaderSourcePath, shaderWebPath } = pathData;

// const
const listJsonName = "list.json";

const makeListJson = (list_: string[]) => {
  const list = list_.map((name) => name.replace(glslExt, ""));
  return JSON.stringify({ list });
};

const readShaderText = (filePath: string) => {
  const d = fs.readFileSync(filePath, encoding);
  return d;
};

const modifyShaderText = (shaderText: string) => {
  return shaderText.replace(/\r/g, "").replace(/\n/g, "\n");
};

const makeDetailPageMap = (glslName: string) => {
  const pathData = path.resolve(shaderSourcePath, glslName);
  const shaderTextRaw = readShaderText(pathData);
  const shaderText = modifyShaderText(shaderTextRaw);
  return { meta: getMeta({ shaderText }), body: shaderText };
};

const makeDetailPageMapfromList = (list: string[]) => {
  const result = list.map((name) => makeDetailPageMap(name));
  return result;
};

const moveFile = (mapData: object, glslName: string) => {
  fs.writeFile(
    path.resolve(shaderWebPath, glslName.replace(glslExt, ".json")),
    JSON.stringify(mapData),
    () => {
      console.log(`done ${glslName}`);
    }
  );
};

const moveFileList = (list: string[]) => {
  const maps = makeDetailPageMapfromList(list);
  _.zip(maps, list).forEach(([mapData, glslName]) => {
    moveFile(mapData!, glslName!);
  });
};

const exportJson = () => {
  const list = listup();
  const listMap = makeListJson(list);
  fs.writeFileSync(path.resolve(shaderWebPath, listJsonName), listMap, {
    encoding,
  });
  const targetName = getNewestShaderFileName();
  const map = makeDetailPageMap(targetName);
  moveFile(map, targetName);
};

const exportJsonAll = () => {
  const list = listup();
  const listMap = makeListJson(list);
  fs.writeFileSync(path.resolve(shaderWebPath, listJsonName), listMap, {
    encoding,
  });

  moveFileList(list);
};

const main = () => {
  exportJson();
  // exportJsonAll();
};

main();
