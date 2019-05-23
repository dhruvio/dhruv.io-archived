"use strict";

const fs = require("fs");
const path = require("path");
const express = require("express");

const config = require("./config");
const makeLogger = require("./util/logger");
const renderUrl = require("./util/render-url");
const handleThunk = require("./util/handle-thunk");

const log = {
  info: makeLogger("server"),
  error: makeLogger("server", "error"),
  debug: makeLogger("server", "debug")
};

const app = express();

//generate unique ids for each request
app.use(require("./middleware/request-id")());

//pad request with logger
app.use(require("./middleware/logger")("request"));

const crawlerAgents = [
  "facebookexternalhit/\\d\\.\\d",
  "Facebot",
  "Twitterbot",
  "bingbot/\\d\\.\\d",
  "BingPreview/\\d\\.\\d",
  "DuckDuckBot/\\d\\.\\d",
  "APIs-Google",
  "Mediapartners-Google",
  "Adsbot-Google-Mobile-Apps",
  "Adsbot-Google-Mobile",
  "Adsbot-Google",
  "Googlebot-Image",
  "Googlebot-News",
  "Googlebot-Video",
  "Googlebot"
];

const validRoutes = [
  /^\/$/,
  /^\/posts\/(.+?)\/?$/
];

const isCrawler = userAgent => {
  return crawlerAgents.reduce((match, agent) => match || !!userAgent.match(new RegExp(agent, "i")), false);
};

const isValidRoute = path => {
  return validRoutes.reduce((match, route) => match || !!path.match(route), false);
};

const sendCrawlerResponse = async (req, res) => {
  req.log.debug("send crawler response");
  const url = `${req.protocol}://${req.get("host")}${req.originalUrl}`;
  req.log.debug(`crawler url: ${url}`);
  res.set("content-type", "text/html")
     .status(200)
     .send(await renderUrl(url));
};

const send404 = (file, opts, req, res) => {
  req.log.debug("send 404");
  res.status(404)
     .sendFile(file, opts);
};

app.use((req, res, next) => {
  const thunk = async (req, res) => {
    const file = path.join(config.uiDir, req.path);
    const exists = fs.existsSync(file) && fs.statSync(file).isFile();
    const isRoute = !exists && isValidRoute(req.path);
    const sendFileOptions = { root: process.cwd() };
    const userAgent = req.get("user-agent");
    req.log.debug(`file: ${file}`);
    req.log.debug(`exists: ${exists}`);
    req.log.debug(`isRoute: ${isRoute}`);
    req.log.debug(`user-agent: ${userAgent}`);
    if (exists) res.sendFile(file, sendFileOptions);
    else if (!isRoute) send404(config.ui404File, sendFileOptions, req, res);
    else if (isCrawler(userAgent)) await sendCrawlerResponse(req, res);
    else res.sendFile(config.uiAppFile, sendFileOptions);
    return null;
  };
  handleThunk(thunk, req, res, next);
});

module.exports = app;
