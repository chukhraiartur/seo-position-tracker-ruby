require 'google_search_results'
require 'json'
require 'csv'
require 'set'


class SeoPositionTracker
    attr_accessor :query, :api_key, :keywords, :websites, :language, :country, :location, :domain
    
    def initialize(query, api_key, keywords, websites, language, country, location, domain)
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