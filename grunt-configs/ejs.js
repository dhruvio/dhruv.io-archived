const _ = require("lodash");

module.exports = {
  dev: {
    options: {
      inlineCss: false,
      inlineJs: false
    },
    src: `${gruntConfig.src.html}/**/*.ejs`,
    dest: gruntConfig.out.html,
    ext: ".html",
    expand: true,
    flatten: true
  },
  prod: {
    options: {
      inlineCss: true,
      inlineJs: true
    },
    src: [ `${gruntConfig.src.html}/*.ejs` ],
    dest: gruntConfig.out.html,
    ext: ".html",
    expand: true,
    flatten: true
  }
};
