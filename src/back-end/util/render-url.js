"use strict";

const { chromeBin } = require("../config");
const chrome = require("chrome-aws-lambda");
const puppeteer = require("puppeteer-core");

module.exports = async url => {
  const browser = await puppeteer.launch({
    executablePath: chromeBin || await chrome.executablePath,
    args: chrome.args,
    headless: chrome.headless
  });
  const page = await browser.newPage();
  await page.goto(url, {
    waitUntil: 'networkidle2'
  });
  const content = await page.content();
  await browser.close();
  return content;
};
