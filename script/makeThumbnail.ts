import { openFolder, makeThumbnail } from "./make";

const cli = () => {
  openFolder(makeThumbnail());
  console.log("[*] done ✨");
};

cli();
