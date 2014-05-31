## What is it?

This is a silly repo to deal with a silly problem. The "Robot Co-op" sites
listsofbests.com and allconsuming.net are going to be shutting down after May
31, 2014. In other words, in about 9 hours from the time of this writing. The
code here is two screen scraper scripts to pull data out of those sites before
they implode. Tomorrow this repo will be interesting only as a demonstration of
how to write messy Ruby screen scraping code for html that no longer exists on
the web.

## What does it do?

Each script will generate 1) an html file and 2) a JSON file for the data on
their respective sites. The listsofbests script just outputs lists with items,
but the allconsuming script grabs lists with descriptions, dates and tags for
each item.

## What do I need?

* Firefox
* Ruby 1.9+ (you have this if you're on a recent version of MacOS)

## Installation and use

```bash
# Clone this repo
git clone https://github.com/tristil/robots_sites_scrapers.git

cd robots_sites_scrapers

# Get Bundler if you don't have it already
gem install bundler

# Install the required gems
bundle install

ruby scrape_allconsuming.rb <USERNAME> <PASSWORD>
ruby scrape_listsofbests.rb <USERNAME> <PASSWORD>
```

**Note:** It is very likely that the above instructions will fail, or that the
script will run into an unexpected issue. If you are actually trying to use
this in the next ~9 hours I will be happy to help out, time permitting. Just
open up an issue and I'll see it and respond as I can. Good luck!
