module.exports = [
  "clean:build",
  "copy:static",
  "svgstore",
  "string-replace:svg",
  "sass",
  "postcss:prefix"
];
