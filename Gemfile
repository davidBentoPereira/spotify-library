source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.6"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  # Unit test framework
  gem "rspec-rails", "~> 6.0"
  # factory_bot is a fixtures replacement with a straightforward definition syntax
  gem "factory_bot_rails"
  # Allow to generate fake data easily
  gem "faker"
  # Shim to load environment variables from .env into ENV in development.
  gem 'dotenv-rails'
  # Useful for debugging
  gem "pry"
  gem "pry-nav", "~> 1.0"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  # A ruby linter focused on enforcing Rails best practices and coding conventions.
  gem "rubocop-rails"
  # A rubocop add-on allowing to disable some ruby syntaxe
  gem "rubocop-disable_syntax"
  # Performance optimization analysis for your projects, as an extension to RuboCop.
  gem "rubocop-performance", require: false
  # Add a comment summarizing the current schema to the top or bottom of each of your files
  gem "annotate"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "rails-controller-testing", "~> 1.0"
  gem "rspec-sidekiq", "~> 4.1"
  gem "selenium-webdriver"
  gem "webdrivers"
end

# Brakeman analyzes our code for security vulnerabilities
gem "brakeman"

# bundler-audit enables bundle audit which analyzes our dependencies for known vulnerabilities
gem "bundler-audit"
# lograge changes Rails' logging to a more traditional one-line-per-event format
gem "lograge"
# Flexible authentication solution for Rails
gem "devise"
# A ruby wrapper for the Spotify Web API
gem "rspotify"

gem "omniauth-rails_csrf_protection"

# Pagination
gem "kaminari", "~> 1.2"
# Jobs
gem "sidekiq", "~> 7.2", ">= 7.2.2"
# Tags
gem "acts-as-taggable-on", "~> 10.0"
# Icons
gem "heroicon", "~> 1.0"
# A library for bulk inserting data using ActiveRecord.
gem "activerecord-import", "~> 1.6"
