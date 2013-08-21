source 'https://rubygems.org'

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
   gem 'shoulda-matchers', git: 'git@github.com:thoughtbot/shoulda-matchers.git', branch: 'dp-rails-four'
   gem 'capybara'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'pry-debugger'
  gem 'rspec-rails', '~> 2.0'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'guard-bundler'
end
