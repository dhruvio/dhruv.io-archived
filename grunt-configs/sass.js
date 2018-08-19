module.exports = {
  options: {
    sourceMap: false
  },
  dist: {
    files: {
      [gruntConfig.out.css]: `${gruntConfig.src.sass}/main.scss`
    }
  }
};
