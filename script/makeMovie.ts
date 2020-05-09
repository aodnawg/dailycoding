import {
  setup,
  MakeMode,
  execProcessing,
  execEncoding,
  dumpMetaInfo,
  openFolder,
} from "./make";

const main = () => {
  // setup
  const params = setup(MakeMode.Movie);
  // exec
  execProcessing(params);
  // encoding
  execEncoding(params);
  // meta
  dumpMetaInfo(params);
  // open folder
  openFolder(params);
  console.log("[*] done ✨");
};
main();
