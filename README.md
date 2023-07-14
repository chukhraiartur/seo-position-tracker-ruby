<div align="center">
<p>Special thanks to:</p>
<div>
   <img src="https://user-images.githubusercontent.com/81998012/231172985-81515e8b-bc41-46b4-83fa-d129d5f3e718.svg" width="60" alt="SerpApi">
</div>
<a href="https://serpapi.com">
  <b>API to get search engine results with ease.</b>
</a>
</div>

<h1 align="center">Ruby SEO Position Tracker</h1>

<p align="center">A simple Ruby CLI and in-code SEO position tracking tool for Google and 5 other search engines.</p>

This tool uses [SerpApi](https://serpapi.com/) as a tool to parse data from search engines. 

You can use provided API key that will be available after installation, however, it's purely for testing purposes to see if the tool fits your needs. If you'll be using it for your own purpose (personal or commercial), you have to use [your own SerpApi key](https://serpapi.com/manage-api-key).



## 🔎 Current search engines support

- Google Search - first 100 organic results.
- Bing Search - first 50 organic results.
- DuckDuckGo Search - up to 30 organic results.
- Yahoo! Search - first 10 organic results.
- Yandex Search - up to 15 organic results.
- Naver Search - first 15 organic results.


## ⚙️Installation

```bash
$ gem install seo-position-tracker-ruby
```


## 🤹‍♂️Usage

```bash
$ seo -h
```

<details>
<summary>
Available arugments
</summary>

```lang-none
Usage: seo [options]
    -q, --query QUERY                Search query. Default "coffee".
    -k, --target-keywords KEYWORDS   Target keywords to track. Default "coffee".
    -w, --target-websites WEBSITES   Target websites to track. Default "starbucks.com".
    -e, --search-engine ENGINES      Choosing a search engine to track: "google", "bing", "duckduckgo", "yahoo", "yandex", "naver". You can select multiple search engines by separating them with a comma: google,bing. All search engines are selected by default.
    -a, --api-key API_KEY            Your SerpApi API key: https://serpapi.com/manage-api-key. Default is a test API key to test CLI.
    -l, --language LANGUAGE          Language of the search. Supported only for "google", "yahoo" and "yandex" engines. Default is nil.
    -c, --country COUNTRY            Country of the search. Supported only for "google", "bing" and "yahoo" engines. Default is nil.
    -p, --location LOCATION          Location of the search. Supported only for "google", "bing", "duckduckgo" and "yandex" engines. Default is nil.
    -d, --domain DOMAIN              Search engine domain to use. Supported only for "google", "yahoo" and "yandex" engines. Default is nil.
    -s, --save-to SAVE               Saves the results in the current directory in the selected format (CSV, JSON, TXT). Default CSV.
```

</details>

## 🤹‍♂️Examples

#### Extracting positions from all search engines for a given query with a target website and a target keyword:

```bash
$ seo --api-key=<your_serpapi_api_key> \
-q "minecraft" \
-k official \
-w minecraft.net
```

```json
[
  {
    "engine": "google",
    "position": 1,
    "title": "Welcome to the Minecraft Official Site | Minecraft",
    "link": "https://www.minecraft.net/en-us"
  },
  {
    "engine": "bing",
    "position": 1,
    "title": "Welcome to the Minecraft Official Site | Minecraft",
    "link": "https://www.minecraft.net/"
  },
  {
    "engine": "duckduckgo",
    "position": 1,
    "title": "Welcome to the Minecraft Official Site | Minecraft",
    "link": "https://www.minecraft.net/"
  },
  {
    "engine": "yahoo",
    "position": 1,
    "title": "Welcome to the Minecraft Official Site | Minecraft",
    "link": "https://www.minecraft.net/"
  },
  {
    "engine": "yandex",
    "position": 1,
    "title": "Welcome to the Minecraft Official Site | Minecraft",
    "link": "https://www.minecraft.net/"
  }
]
```

#### Extracting positions from 3 search engines with default arguments and saving to CSV:

```bash
$ seo --api-key=<your_serpapi_api_key> \
-e google,bing,duckduckgo \
-s CSV
```

```json
[
  {
    "engine": "google",
    "position": 7,
    "title": "Starbucks Coffee Company",
    "link": "https://www.starbucks.com/"
  },
  {
    "engine": "bing",
    "position": 4,
    "title": "Starbucks Coffee Company",
    "link": "https://www.starbucks.com/"
  },
  {
    "engine": "bing",
    "position": 13,
    "title": "The Best Coffee from Starbucks Coffee: Starbucks Coffee Company",
    "link": "https://www.starbucks.com/coffee/"
  },
  {
    "engine": "duckduckgo",
    "position": 2,
    "title": "Starbucks Coffee Company",
    "link": "https://www.starbucks.com/"
  },
  {
    "engine": "duckduckgo",
    "position": 11,
    "title": "The Best Coffee from Starbucks Coffee: Starbucks Coffee Company",
    "link": "https://www.starbucks.com/coffee/"
  }
]
Saving data in CSV format...
Data successfully saved to coffee.csv file.
```

#### Extracting positions from one engine with all arguments for it:

```bash       
$ seo --api-key=<your_serpapi_api_key> \
-q serpapi \
-k "Google Search API" \
-w "https://serpapi.com/" \
-e google \
-l de \
-c de \
--location Germany \
-d google.de \
-s txt
```

```json
[
  {
    "engine": "google",
    "position": 1,
    "title": "SerpApi: Google Search API",
    "link": "https://serpapi.com/"
  }
]
Saving data in TXT format...
Data successfully saved to serpapi.txt file.
```

#### Extracting positions from all search engines manually (without CLI):

```ruby
require "seo-position-tracker-ruby"

tracker = SeoPositionTracker::Scraper.new(
    query='coffee', 
    api_key='<your_serpapi_api_key>', 
    keywords=['coffee', 'starbucks'], 
    websites=['starbucks.com', 'wikipedia.org']
)

position_data = []

google_results = tracker.scrape_google(lang='en', country='us', location='United States', domain='google.com')
position_data.concat(google_results)

bing_results = tracker.scrape_bing(country='us', location='United States')
position_data.concat(bing_results)

duckduckgo_results = tracker.scrape_duckduckgo(location='us-en')
position_data.concat(duckduckgo_results)

yahoo_results = tracker.scrape_yahoo(lang='lang_en', country='us', domain='uk')
position_data.concat(yahoo_results)

yandex_results = tracker.scrape_yandex(lang='en', domain='yandex.com')
position_data.concat(yandex_results)

naver_results = tracker.scrape_naver()
position_data.concat(naver_results)

tracker.save_to_csv(position_data)
tracker.save_to_json(position_data)
tracker.save_to_txt(position_data)

tracker.print(position_data)
```

## 💡Issues or suggestions

Visit [issues](https://github.com/chukhraiartur/seo-position-tracker-ruby/issues) page.

## 📜 Licence

Ruby SEO Position Tracker is released under the [BSD-3-Clause Licence](https://github.com/chukhraiartur/seo-position-tracker-ruby/blob/main/LICENSE).
