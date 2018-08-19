module.exports = {
  svg: {
    options: {
      replacements: [
        {
          pattern: /\s+/g,
          replacement: " "
        }
      ]
    },
    files: {
      [gruntConfig.out.svg]: gruntConfig.out.svg
    }
  }
};
