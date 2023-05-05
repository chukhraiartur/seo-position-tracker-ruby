require_relative '../lib/seo-position-tracker'

tracker = SeoPositionTracker.new(
    query='coffee', 
    api_key='<your_serpapi_api_key>', 
    keywords=['coffee', 'starbucks'], 
    websites=['starbucks.com']
)

google_results = tracker.scrape_google

tracker.save_to_csv(google_results)
tracker.print(google_results)