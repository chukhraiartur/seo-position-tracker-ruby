require_relative '../lib/seo-position-tracker'

tracker = SeoPositionTracker.new(
    query='coffee', 
    api_key='5868ece26d41221f5e19ae8b3e355d22db23df1712da675d144760fc30d57988', 
    keywords=['coffee', 'starbucks'], 
    websites=['starbucks.com']
)

google_results = tracker.scrape_google

tracker.save_to_csv(google_results)
tracker.print(google_results)