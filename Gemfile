# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Used to calculate PI in our test job:
gem 'gmp', '~> 0.7.43'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
end

group :development do
  gem 'listen', '~> 3.2'

  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  # Support for Ruby IDE tools - including "Ruby for Visual Studio Code"
  gem 'debase', '~> 0.2.4.1'
  gem 'reek', '~> 6.0', '>= 6.0.1'
  gem 'rubocop', '~> 0.88.0'
  gem 'ruby-debug-ide', '~> 0.7.2'

  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.39.12'
end

group :test do
  gem 'capybara', '~> 3.33'
  gem 'cuprite', '~> 0.10'
  gem 'selenium-webdriver', '~> 3.142', '>= 3.142.7' # We’ll be able to remove this gem in Rails 6.1.
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
