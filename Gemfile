source 'https://rubygems.org'
ruby "2.0.0"

gem 'rails', '4.0.0'
gem 'pg'
gem 'bcrypt-ruby', '~> 3.0.0'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'active_model_serializers'
gem 'maruku'
gem 'ims-lti'
gem 'simple_form', '~> 3.0.0.beta1'
gem 'nokogiri'
gem 'ransack'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'anjlab-bootstrap-rails', :require => 'bootstrap-rails',
                              :github => 'anjlab/bootstrap-rails',
                              :branch => '3.0.0'
gem 'font-awesome-rails'

gem 'omniauth-twitter'
gem 'omniauth-facebook'
gem 'omniauth-github'
gem 'omniauth-google-oauth2'

# gem 'will_paginate', '~> 3.0'
gem 'will_paginate-bootstrap'
gem 'paranoia', '~> 2.0'
gem 'paranoia_uniqueness_validator', '1.0.0'

gem 'reverse_markdown'
gem 'rails_12factor', group: :production

gem 'ick'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  gem 'guard-rspec'
  gem 'quiet_assets'
  gem 'guard-embertools', '~> 0.2.1'
end

group :test do
   gem 'capybara'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-debugger'
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'guard-bundler'
end
