import fs from "fs";
import path from "path";
import _ from "lodash";

import { pathData, encoding, listup, glslExt } from "./common";
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

const makeDetailPageMap = (list: string[]) => {
  const result = list
    .map((name) => path.resolve(shaderSourcePath, name))
    .map((d) => readShaderText(d))
    .map((d) => modifyShaderText(d))
    .map((d) => ({ meta: getMeta({ shaderText: d }), body: d }));
  return result;
};

const exportFile = (list: string[]) => {
  const d = makeDetailPageMap(list);
  _.zip(d, list).forEach(([d, name]) => {
    fs.writeFile(
      path.resolve(shaderWebPath, name!.replace(glslExt, ".json")),
      JSON.stringify(d),
      () => {
        console.log(`done ${name}`);
      }
    );
  });
};

const main = () => {
  const list = listup();
  const meta = makeListJson(list);
  fs.writeFileSync(path.resolve(shaderWebPath, listJsonName), meta, {
    encoding,
  });

  const d = exportFile(list);
};
main();
