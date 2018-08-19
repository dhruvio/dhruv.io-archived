"use strict";

const makeLogger = require("../util/logger");

module.exports = (domain = "log") => {
  const info = makeLogger(domain);
  const error = makeLogger(domain, "error");
  const debug = makeLogger(domain, "debug");
  const prefixWithId = (logFn, id) => msg => logFn(`[${id}]\t\t${msg}`);
  return (req, res, next) => {
    req.log = {
      info: prefixWithId(info, req.id),
      error: prefixWithId(error, req.id),
      debug: prefixWithId(debug, req.id)
    };
    req.log.info(`${req.method} ${req.url}`);
    next();
  };
};
