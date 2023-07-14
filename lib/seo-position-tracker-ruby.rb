require 'google_search_results'
require 'optparse'
require 'json'
require 'csv'
require 'set'

module SeoPositionTracker
    class CLI
        def initialize(argv)
            @argv = argv
        end

        def run
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
                opts.banner = "Usage: seo [options]"
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
            end.parse!(@argv)
            
            tracker = SeoPositionTracker::Scraper.new(
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
        end
    end

    class Scraper
        attr_accessor :query, :api_key, :keywords, :websites, :language, :country, :location, :domain
        
        def initialize(query, api_key, keywords, websites, language = nil, country = nil, location = nil, domain = nil)
            @query = query
            @api_key = api_key
            @keywords = keywords
            @websites = websites
            @language = language
            @country = country
            @location = location
            @domain = domain
        end
        
        def scrape_google(language = 'en', country = 'us', location = 'United States', domain = 'google.com')
            language, country, location, domain = check_params(language=language, country=country, location=location, domain=domain)
    
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                q: @query,                        # search query
                engine: 'google',                 # search engine
                google_domain: domain,            # Google domain to use
                hl: language,                     # language of the search
                gl: country,                      # country of the search
                location: location,               # location of the search
                num: 100                          # 100 results from Google search
            }
            
            search = GoogleSearch.new(params)     # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'google')
        end
    
        def scrape_bing(country = 'us', location = 'United States')
            country, location = check_params(country=country, location=location)
    
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                q: @query,                        # search query
                engine: 'bing',                   # search engine
                cc: country,                      # country of the search
                location: location,               # location of the search
                count: 50                         # 50 results from Bing search
            }
            
            search = BingSearch.new(params)       # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'bing')
        end
    
        def scrape_duckduckgo(location = 'us-en')
            location = check_params(location=location)
    
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                q: @query,                        # search query
                engine: 'duckduckgo',             # search engine
                kl: location                      # location of the search
            }
            
            search = DuckduckgoSearch.new(params) # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'duckduckgo')
        end
        
        def scrape_yahoo(language = 'language_en', country = 'us', domain = 'uk')
            language, country, domain = check_params(language=language, country=country, domain=domain)
    
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                p: @query,                        # search query
                engine: 'yahoo',                  # search engine
                yahoo_domain: domain,             # Yahoo! domain to use
                vl: language,                     # language of the search
                vc: country                       # country of the search
            }
            
            search = YahooSearch.new(params)      # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'yahoo')
        end
    
        def scrape_yandex(language = 'en', domain = 'yandex.com')
            language, domain = check_params(language=language, domain=domain)
    
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                text: @query,                     # search query
                engine: 'yandex',                 # search engine
                yandex_domain: domain,            # Yandex domain to use
                language: language                # language of the search
            }
            
            search = YandexSearch.new(params)     # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'yandex')
        end
    
        def scrape_naver
            params = {
                api_key: @api_key,                # https://serpapi.com/manage-api-key
                query: @query,                    # search query
                engine: 'naver',                  # search engine
                where: 'web'                      # web organic results
            }
            
            search = NaverSearch.new(params)      # data extraction on the SerpApi backend
            results = search.get_hash             # JSON -> Ruby hash
            
            find_positions(results, 'naver')
        end
    
        def save_to_csv(data)
            keys = data[0].keys
        
            File.open("#{@query.gsub(' ', '_')}.csv", 'w', encoding: 'utf-8') do |csv_file|
                writer = CSV.new(csv_file)
                writer << keys
                data.each { |row| writer << row.values }
            end
        end
        
        def save_to_json(data)
            File.open("#{@query.gsub(' ', '_')}.json", 'w', encoding: 'utf-8') do |json_file|
                json_file.write(JSON.pretty_generate(data))
            end
        end
        
        def save_to_txt(data)
            File.open("#{@query.gsub(' ', '_')}.txt", 'w', encoding: 'utf-8') do |txt_file|
                data.each do |element|
                    txt_file.puts("#{element[:engine]}, #{element[:position]}, #{element[:title]}, #{element[:link]}")
                end
            end
        end
    
        def print(data)
            puts JSON.pretty_generate(data)
        end
    
        private
    
        def find_positions(results, engine)
            data = Set.new                        # to get rid of repetitive results
            
            @keywords&.each do |keyword|
                @websites&.each do |website|
                    results[:organic_results]&.each do |result|
                        check = result[:title].downcase.include?(keyword.downcase) && result[:link].include?(website)
    
                        next unless check
            
                        data.add({
                            engine: engine,
                            position: result[:position],
                            title: result[:title],
                            link: result[:link]
                        })
                    end
                end
            end
    
            data.to_a
        end
    
        def check_params(lang = nil, country = nil, location = nil, domain = nil)
            checked_params = []
            
            if lang
                checked_params << @lang ? @lang : lang
            end
    
            if country
                checked_params << @country ? @country : country
            end
            
            if location
                checked_params << @location ? @location : location
            end
            
            if domain
                checked_params << @domain ? @domain : domain
            end
    
            checked_params.length == 1 ? checked_params[0] : checked_params
        end
    end
end
