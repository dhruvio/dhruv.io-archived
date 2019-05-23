"use strict";

const path = require("path");
const env = process.NODE_ENV === "development" ? "development" : "production";
const uiDir = "dist";

module.exports = {
  env,
  uiDir,
  uiAppFile: path.join(uiDir, "index.html"),
  ui404File: path.join(uiDir, "404.html"),
  chromeBin: env === "production" ? undefined : process.env.CHROME_BIN || "chromium"
};
