"use strict";

const config = require("../config");

module.exports = (prefix, level = "info") => msg => {
  if (config.env === "production" && level !== "info" && level !== "error") return;
  console.log(`[${prefix}:${level}]\t\t${msg}`);
};
