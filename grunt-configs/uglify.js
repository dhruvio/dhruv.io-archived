module.exports = {
  prod: {
    files: {
      [gruntConfig.out.js]: [
        gruntConfig.out.js
      ]
    },
    options: {
      mangle: true
    }
  }
};
