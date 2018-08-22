Modern websites built with tools like Elm, React, Vue and Ember can offer a better experience to users than static websites. However, they perform the majority of their logic in a user's web browser, not on a server, which makes Search Engine Optimization ("SEO") challenging as crawlers need to evaluate the client-side logic of these websites *before* scraping them for relevant data (e.g. title, description, image). Even though, at the time of writing this post, Single-Page Applications ("SPAs") like these are prevalent across the web, most crawlers still expect the HTML provided by a server to contain complete metadata not dependent on any client-side code. Consequently, SPAs are typically not indexed well by search engines or social media platforms.

This post describes my strategy to solve this problem by demonstrating how any SPA can provide server-rendered HTML to crawlers. This is achieved by building a small server that vends a SPA employing `pushState` routing. The server parses the user agent of each request to determine if the requestor is a crawler. If so, the SPA is rendered on the server-side headlessly using Chromium. If not, it is simply served to the requestor normally, assuming they are a human user. The server has been architected to be stateless, allowing it to be scaled up horizontally to support popular websites.

This blog is an example of this solution in production. The front-end was built in <a href="http://elm-lang.org/" target="_blank">Elm</a> and the back-end server runs on <a href="https://nodejs.org/en/" target="_blank">Node.js</a>. It is deployed using <a href="https://zeit.co/now" target="_blank">Now</a> and <a href="https://www.docker.com/" target="_blank">Docker</a>. The code is <a href="https://github.com/dhruvio/dhruv.io" target="_blank">open-source</a>. This post won't go into the details of how this project was implemented, and is not intended to be a tutorial. Rather, it provides an architectural overview of how this solution works.


### What does SEO look like in HTML?

Given SEO's scope is large, this post is only concerned with populating an HTML page's `<meta>` tags according to the guidelines from search engines and social media platforms. Doing so provides their crawlers with data about your website in a usable way. For example, this blog populates the following tags for each route to support Google's, Facebook's and Twitter's crawlers:

```xml
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="Title goes here.">
<meta property="og:title" content="Title goes here.">
<meta name="description" content="Description goes here.">
<meta name="twitter:description" content="Description goes here.">
<meta property="og:description" content="Description goes here.">
<meta name="twitter:url" content="URL goes here.">
<meta property="og:url" content="URL goes here.">
```

SPAs may load data asynchronously on the client-side to create their user interfaces. Once this data is loaded, it's also possible to populate `<meta>` tags like these using JavaScript. This blog was written in Elm and achieves this using <a href="http://elm-lang.org/docs/syntax#javascript-interop" target="_blank">Ports</a>. You can see the relevant code <a href="https://github.com/dhruvio/dhruv.io/blob/master/src/front-end/elm/Ports.elm" target="_blank">here</a> and <a href="https://github.com/dhruvio/dhruv.io/blob/master/src/front-end/html/index.ejs" target="_blank">here</a>.


### How does the server work?

The server that makes all of this possible might seem complicated, but, in reality, it only has several feature requirements. These have been described in the diagram below:

```text
	   SEO for SPAs: Server
	   +------------------+

             Request
             +--+--+
                |
        +-------+-------+
        |               |
        v               v
      User           Crawler
      +-++           +--+--+
        |               |
        v               v
    Serve SPA     Render Page
    Normally      Headlessly
    +---+---+     with Chromium
        |         +-----+-----+
        |               |
        v               v
  HTML Response.  HTML Response.
  No Metadata.    With Metadata.
  +------------+  +------------+
```

Its logic forks when determining whether a request is coming from a user or a crawler.

When a requestor is a regular user, we want to serve the SPA normally. This means we need to respond with a minimal HTML file that includes a JavaScript bundle and CSS. Once the browser loads the JavaScript, it populates the DOM on the client-side with markup, then sets the relevant, SEO-specific `<meta>` tags on the page. To an end-user, this appears to function like an ordinary website, however, to a crawler, the website seems empty, as the HTML sent by the server has no meaningful content without a browser to render it.

Therefore, when the requestor is a crawler, we render the page on the server-side using Chromium headlessly to generate the necessary markup on the server-side. This enables our server to send a full HTML page with `<meta>` tags to the crawler so it can scrape the meaningful information that it needs.

Take a look at <a href="https://github.com/dhruvio/dhruv.io/blob/master/src/back-end/index.js" target="_blank">this blog's implementation</a> of this server in Node.js. The <a href="https://github.com/dhruvio/dhruv.io/blob/master/src/back-end/util/render-url.js" target="_blank">module</a> that does the server-side rendering with Chromium uses the <a href="https://www.npmjs.com/package/puppeteer" target="_blank">puppeteer</a> NPM package. This server does not rely on any state other than the SPA's build output, which can easily be generated from the source code. This feature is powerful, as it allows the server to be scaled up and down easily to meet performance requirements without the need of syncing state across the nodes of a deployment.


### Putting it all together.

This leaves us with a SPA that populates SEO-specific `<meta>` tags, deployed with a server that knows how to vend the correct HTML to users and crawlers. We can see how this works in production by using `curl` to request the home page of this blog, and comparing the HTML responses for users and crawlers.

First, let's assume the role of a regular user:

```bash
curl 'https://www.dhruv.io'
#Responds with a minimal HTML page without any SEO-specific <meta> tags.
```

Next, let's request the same page, but with the user agent of a crawler:

```bash
curl -H 'User-Agent: Twitterbot' 'https://www.dhruv.io'
#Responds with a full, server-rendered HTML page containing SEO-specific <meta> tags.
```

You can pipe the results of these commands through `grep '<meta'` to get an idea of the metadata present in each of their responses.


### Closing thoughts.

I discovered this solution before Chromium had a headless mode, and <a href="https://github.com/ariya/phantomjs/issues/15344" target="_blank">PhantomJS</a> was still around. I like that it's easy to deploy and scale up, and that there's room for caching to serve responses faster. For example, we could implement logic to cache server-rendered pages in memory as long as they can be invalidated when required.

What is most striking to me is that SPAs are not widely used for content-heavy websites (most are managed by Content Management Systems or are statically generated). I believe crawlers' lack of support for them is a key factor in this outcome. While search and social media giants move in the direction of scraping SPAs effectively, I am using the solution outlined here to enable me to deploy content-driven web applications with strong SEO.
