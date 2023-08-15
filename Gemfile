source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.2'

gem 'rails', '~> 7.0.6'

gem 'bootsnap', require: false
gem 'faker'
gem 'importmap-rails'
gem 'jbuilder'
gem 'pg', '~> 1.1'
gem 'pry'
gem 'puma', '~> 5.0'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
