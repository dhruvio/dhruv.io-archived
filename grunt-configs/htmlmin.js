const index = gruntConfig.out.html.index;

module.exports = {
  prod: {
    options: {
      removeComments: true,
      collapseWhitespace: true,
      minifyJS: true,
      minifyCSS: true,
      collapseInlineTagWhitespace: true,
      caseSensitive: true,
      conservativeCollapse: true,
      keepClosingSlash: true
    },
    files: {
      [index]: index
    }
  }
};
