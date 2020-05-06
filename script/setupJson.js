const fs = require("fs");
const path = require("path");

const targetPath = path.resolve(__dirname, "../shaders/20200505.glsl");
const glsl = fs
  .readFileSync(targetPath, "utf-8")
  .replace(/\r/g, "")
  .replace(/\n/g, "\n");
const jsonData = JSON.stringify({
  body: glsl,
});
const source = JSON.parse(jsonData).body;

fs.writeFileSync(path.resolve(__dirname, "../sample.json"), jsonData);
console.log(jsonData);
