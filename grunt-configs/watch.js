module.exports = {
  options: {
    interrupt: true,
    debounceDelay: 250
  },
  dev: {
    files: [
      `${gruntConfig.src.elm}/**`,
      `${gruntConfig.src.sass}/**`,
      `${gruntConfig.src.static}/**`,
      `${gruntConfig.src.html}/**`
    ],
    tasks: [
      "build",
      "ejs:devIndex",
      "elm:dev",
      "inline:all"
    ]
  }
};
