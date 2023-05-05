require_relative '../lib/seo-position-tracker'

tracker = SeoPositionTracker.new(
    query='coffee', 
    api_key='5868ece26d41221f5e19ae8b3e355d22db23df1712da675d144760fc30d57988', 
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