const _ = require("lodash");

module.exports = {
  dev: {
    options: {
      inlineCss: false,
      inlineJs: false,
      googleAnalyticsTrackingId: "null"
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
      inlineJs: true,
      googleAnalyticsTrackingId: process.env.GA_TRACKING_ID
    },
    src: [ `${gruntConfig.src.html}/*.ejs` ],
    dest: gruntConfig.out.html,
    ext: ".html",
    expand: true,
    flatten: true
  }
};
