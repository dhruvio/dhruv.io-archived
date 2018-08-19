"use strict";

const { chromeBin } = require("../config");
const puppeteer = require("puppeteer");

module.exports = async url => {
  const browser = await puppeteer.launch({
    executablePath: chromeBin,
    args: [
      "--no-sandbox"
    ]
  });
  const page = await browser.newPage();
  await page.goto(url, {
    waitUntil: 'networkidle2'
  });
  const content = await page.content();
  await browser.close();
  return content;
};
