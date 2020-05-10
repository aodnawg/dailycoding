import path from "path";
import fs from "fs";
import assert from "assert";
import _ from "lodash";
import { makeThumbnail } from "./make";
import { listup, pathData } from "./common";

const { thumbnailImagePath, webAssetPath } = pathData;

const makeCopyTargets = (thumbnailNames: string[], copyTargetDir: string) => {
  const copyTargets = thumbnailNames.map((name) =>
    path.resolve(copyTargetDir, name)
  );
  return copyTargets;
};

const makeCopyDestination = (webAssetPath: string, targetName: string) => {
  const copyDestination = path.resolve(
    webAssetPath,
    "thumbnail",
    targetName.replace(/\.glsl/, "")
  );
  return copyDestination;
};

const makeDestDir = (copyDestination: string) => {
  if (!fs.existsSync(copyDestination)) {
    fs.mkdirSync(copyDestination);
  }
};

const copyFile = (
  copyTargets: string[],
  thumbnailNames: string[],
  copyDestination: string
) => {
  return _.zip(copyTargets, thumbnailNames).map(([t, n]) => {
    const dest = path.resolve(copyDestination, n!);
    fs.copyFileSync(t!, path.resolve(copyDestination, n!));
    return dest;
  });
};

const makeCopyTargetDirName = (targetName: string) => {
  return path.resolve(thumbnailImagePath, targetName.replace(/\.glsl/, ""));
};

const exportThumnbnailPerGlsl = (targetName: string) => {
  const copyTargetDirName = makeCopyTargetDirName(targetName);
  const thumbnailNames = fs.readdirSync(copyTargetDirName);
  const copyTargets = makeCopyTargets(thumbnailNames, copyTargetDirName);
  const copyDestination = makeCopyDestination(webAssetPath, targetName);
  makeDestDir(copyDestination);
  const result = copyFile(copyTargets, thumbnailNames, copyDestination);

  // test
  result.forEach((dest) => {
    assert(fs.existsSync(dest), "[*] error: faild copy.");
  });

  console.log(`[*] done ${targetName}`);
};

const makeThumbnailAll = (targetList: string[]) => {
  const result = targetList.map((t) => {
    makeThumbnail(t);
    return t;
  });

  // test
  result.forEach((targetName) => {
    const filePath = makeCopyTargetDirName(targetName);
    assert(fs.existsSync(filePath), "[*] error: faild make thumbnail.");
  });
};

const exportThumnbnailAll = (targetList: string[]) => {
  targetList.forEach((t) => exportThumnbnailPerGlsl(t));
};

const main = () => {
  const targetList = listup();
  makeThumbnailAll(targetList);
  exportThumnbnailAll(targetList);
};
main();
