require_relative 'lib/seo-position-tracker'
require 'optparse'

options = {
    query: 'coffee',
    target_keywords: ['coffee'],
    target_websites: ['starbucks.com'],
    search_engine: ['google', 'bing', 'duckduckgo', 'yahoo', 'yandex', 'naver'],
    api_key: '5868ece26d41221f5e19ae8b3e355d22db23df1712da675d144760fc30d57988',
    language: nil,
    country: nil,
    location: nil,
    domain: nil,
    save_to: 'CSV'
}

OptionParser.new do |opts|
    opts.banner = "Usage: ruby #{File.basename($PROGRAM_NAME)} [options]"
    opts.on('-q', '--query QUERY', String, 'Search query. Default "coffee".') { |q| options[:query] = q }
    opts.on('-k', '--target-keywords KEYWORDS', Array, 'Target keywords to track. Default "coffee".') { |k| options[:target_keywords] = k }
    opts.on('-w', '--target-websites WEBSITES', Array, 'Target websites to track. Default "starbucks.com".') { |w| options[:target_websites] = w }
    opts.on('-e', '--search-engine ENGINES', Array, 'Choosing a search engine to track: "google", "bing", "duckduckgo", "yahoo", "yandex", "naver". You can select multiple search engines by separating them with a comma: google,bing. All search engines are selected by default.') { |e| options[:search_engine] = e }
    opts.on('-a', '--api-key API_KEY', String, 'Your SerpApi API key: https://serpapi.com/manage-api-key. Default is a test API key to test CLI.') { |a| options[:api_key] = a }
    opts.on('-l', '--language LANGUAGE', String, 'Language of the search. Supported only for "google", "yahoo" and "yandex" engines. Default is nil.') { |l| options[:language] = l }
    opts.on('-c', '--country COUNTRY', String, 'Country of the search. Supported only for "google", "bing" and "yahoo" engines. Default is nil.') { |c| options[:country] = c }
    opts.on('-p', '--location LOCATION', String, 'Location of the search. Supported only for "google", "bing", "duckduckgo" and "yandex" engines. Default is nil.') { |p| options[:location] = p }
    opts.on('-d', '--domain DOMAIN', String, 'Search engine domain to use. Supported only for "google", "yahoo" and "yandex" engines. Default is nil.') { |d| options[:domain] = d }
    opts.on('-s', '--save-to SAVE', String, 'Saves the results in the current directory in the selected format (CSV, JSON, TXT). Default CSV.') { |s| options[:save_to] = s }
end.parse!

tracker = SeoPositionTracker.new(
    query=options[:query],
    api_key=options[:api_key],
    keywords=options[:target_keywords],
    websites=options[:target_websites],
    language=options[:language],
    country=options[:country],
    location=options[:location],
    domain=options[:domain]
)

position_data = []

options[:search_engine]&.each do |engine|
    case engine
    when 'google'
        data = tracker.scrape_google
        position_data.concat(data)
    when 'bing'
        data = tracker.scrape_bing
        position_data.concat(data)
    when 'duckduckgo'
        data = tracker.scrape_duckduckgo
        position_data.concat(data)
    when 'yahoo'
        data = tracker.scrape_yahoo
        position_data.concat(data)
    when 'yandex'
        data = tracker.scrape_yandex
        position_data.concat(data)
    when 'naver'
        data = tracker.scrape_naver
        position_data.concat(data)
    else
        puts "\"#{engine}\" is an unknown search engine."
    end
end

if position_data.any?
    tracker.print(position_data)
    puts "Saving data in #{options[:save_to].upcase} format..."

    case options[:save_to].upcase
    when 'CSV'
        tracker.save_to_csv(position_data)
    when 'JSON'
        tracker.save_to_json(position_data)
    when 'TXT'
        tracker.save_to_txt(position_data)
    end

    puts "Data successfully saved to #{options[:query].gsub(" ", "_")}.#{options[:save_to].downcase} file."
else
    puts "Unfortunately, no matches were found."
end
