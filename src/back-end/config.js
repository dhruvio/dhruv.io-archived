"use strict";

const env = process.NODE_ENV === "development" ? "development" : "production";

module.exports = {
  env,
  host: process.env.X_HOST || "0.0.0.0",
  port: process.env.X_PORT || 3000,
  uiDir: process.env.X_UI_DIR || "./build",
  uiAppFile: process.env.X_UI_APP_FILE || "./build/index.html",
  ui404File: process.env.X_UI_404_FILE || "./build/404.html",
  chromeBin: env === "production" ? undefined : process.env.CHROME_BIN || "chromium"
};
