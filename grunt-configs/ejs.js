const _ = require("lodash");

const config = {
  apiHost: process.env.FRONT_END_API_HOST || ""
};

module.exports = {
  devIndex: {
    options: _.assign({}, config, {
      inlineCss: false,
      inlineJs: false
    }),
    src: [ `${gruntConfig.src.html}/index.ejs` ],
    dest: gruntConfig.out.html.index,
    ext: ".html"
  },
  prodIndex: {
    options: _.assign({}, config, {
      inlineCss: true,
      inlineJs: true
    }),
    src: [ `${gruntConfig.src.html}/index.ejs` ],
    dest: gruntConfig.out.html.index,
    ext: ".html"
  }
};
