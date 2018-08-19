module.exports = {
  store: {
    options: {
      prefix: "svg-",
      svg: {
        "class": "svg-store",
        xmlns: "http://www.w3.org/2000/svg"
      }
    },
    files: {
      [gruntConfig.out.svg]: [
        `${gruntConfig.src.svg}/*.svg`
      ]
    }
  }
};
