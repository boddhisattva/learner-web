source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.1"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"
# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  gem "bullet", "~> 7.2" # help to kill N+1 queries and unused eager loading.

  gem "factory_bot_rails" # DSL for defining and using factories

  gem "pry-byebug", "~> 3.10", ">= 3.10.1" # Useful for debugging purposes

  gem "rspec-rails" # For Automated tests

  gem "rubocop", require: false # Ruby code style checking and code formatting tool.

  gem "rubocop-factory_bot", require: false # Code style checking for factory_bot files

  gem "rubocop-performance", require: false # Write code that's more performant

  gem "rubocop-rails", require: false # Automate usage of best Rails practices

  gem "rubocop-rspec", require: false # Code style checking for RSpec files.

  gem "rubocop-rspec_rails", require: false # RSpec Rails-specific analysis for one's projects

  gem "shoulda-matchers" # Simple One-Liner Tests for Rails

  gem "strong_migrations" # Catch unsafe migrations in development
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "fasterer" # Write more performant code

  gem "flog", require: false # Flog reports the most tortured code in an easy to read pain report

  gem "annotate" # Annotate Rails classes with schema and routes info

  gem "i18n-debug" # Get more clarity on which Internationalisation related translations are looked up
end

group :test do
  gem "rails-controller-testing"
  gem "capybara" # Useful for testing web apps & specifically for writing things like system tests
  gem "selenium-webdriver", "~> 4.25" # Browser automation tool for automated testing of webapps & more
  gem "launchy", "~> 3.0" # Useful for debugging system tests
end

gem "devise", "~> 4.9"
