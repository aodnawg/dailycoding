import { setup, MakeMode, execProcessing, openFolder } from "./make";

export const makeThumbnail = (filePath?: string) => {
  // setup
  const params = setup(MakeMode.Thumbnail, filePath);
  // exec
  execProcessing(params);
  return params;
};

const cli = () => {
  openFolder(makeThumbnail());
  console.log("[*] done ✨");
};
cli();
