const makeConfig = debug => ({
  options: { debug },
  files: {
    [gruntConfig.out.js]: `${gruntConfig.src.elm}/Main.elm`
  }
});

module.exports = {
  dev: makeConfig(true),
  prod: makeConfig(false)
};
