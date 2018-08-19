"use strict";

const crypto = require("crypto");

module.exports = () => (req, res, next) => {
  const hash = crypto.createHash("sha1");
  hash.update(Math.random().toString(), "utf8");
  const digestedHash = hash.digest("base64");
  req.id = digestedHash;
  next();
};
