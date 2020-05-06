const fs = require("fs");
const path = require("path");
const _ = require("lodash");

// path
const projectRootPath = path.resolve(__dirname, "..");
const shaderAssetsPath = path.resolve(projectRootPath, "shaders");
const nuxtShaderPath = path.resolve(projectRootPath, "web", "shaders");

// const
const glslExt = /\.glsl$/g;
const encoding = "utf-8";
const metaJsonName = "meta.json";

const listup = () => {
  const list = fs
    .readdirSync(shaderAssetsPath)
    .filter((name) => name.match(glslExt) !== null);
  return list;
};

const makeMetaJson = (list_) => {
  const list = list_.map((name) => name.replace(glslExt, ""));
  return JSON.stringify({ list });
};

const readShaderText = (filePath) => {
  const d = fs.readFileSync(filePath, encoding);
  return d;
};

const modifyShaderText = (shaderText) => {
  return shaderText.replace(/\r/g, "").replace(/\n/g, "\n");
};

const maikeDetailJsons = (list) => {
  return list
    .map((name) => path.resolve(shaderAssetsPath, name))
    .map((d) => readShaderText(d))
    .map((d) => modifyShaderText(d))
    .map((body) => JSON.stringify({ body }));
};

const main = () => {
  const list = listup();
  const meta = makeMetaJson(list);
  fs.writeFileSync(path.resolve(nuxtShaderPath, metaJsonName), meta, {
    encoding,
  });

  const d = maikeDetailJsons(list);
  _.zip(d, list).forEach(([d, name]) => {
    fs.writeFile(
      path.resolve(nuxtShaderPath, name.replace(glslExt, ".json")),
      d,
      () => {
        console.log(`done ${name}`);
      }
    );
  });
};
main();

// const targetPath = path.resolve(__dirname, "../shaders/20200505.glsl");
// const glsl = fs
//   .readFileSync(targetPath, "utf-8")
//
// const jsonData = JSON.stringify({
//   body: glsl,
// });
// const source = JSON.parse(jsonData).body;

// fs.writeFileSync(path.resolve(__dirname, "../sample.json"), jsonData);
// console.log(jsonData);
