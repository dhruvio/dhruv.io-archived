"use strict";

const _ = require("lodash");

module.exports = (thunk, req, res, next) => {
  Promise
    .resolve(req.thunk)
    .then(thunk => thunk(req, res, next))
    .then(data => data && res.status(200).send(data))
    .catch(errorMessage => {
      req.log.error(`request failed`);
      req.log.error(errorMessage);
      errorMessage = _.get(errorMessage, "message", errorMessage);
      res.status(400).send(errorMessage);
    });
};
