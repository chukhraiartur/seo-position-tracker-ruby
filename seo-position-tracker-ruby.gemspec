Gem::Specification.new do |s|
    s.name                      = "seo-position-tracker-ruby"
    s.version                   = "0.1.1"
    s.platform                  = Gem::Platform::RUBY
    s.date                      = Time.now.strftime("%Y-%m-%d")
    s.license                   = "BSD 3-Clause"
    s.summary                   = "Ruby SEO Position Tracker"
    s.homepage                  = "https://github.com/chukhraiartur/seo-position-tracker-ruby"
    s.description               = "A simple Ruby CLI and in-code SEO position tracking tool for Google and 5 other search engines."
    s.authors                   = ["Artur Chukhrai"]
    s.email                     = ["chukhraiartur@gmail.com"]
    s.required_ruby_version     = ">= 3.0.0"
    s.add_dependency            "google_search_results", "~> 2.2"
    s.files                     = Dir.glob("{lib,bin}/**/*")
    s.require_path              = "lib"
    s.executables               = ["seo"]
end